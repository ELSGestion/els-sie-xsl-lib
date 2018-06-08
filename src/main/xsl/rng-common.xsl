<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns="http://relaxng.org/ns/structure/1.0"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:import href="els-common.xsl"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>XSLT functions/templates library to extract information or transform Relax NG schema</xd:p>
      <xd:p>The RNG schema provided should be simplified (cf. http://www.relaxng.org/spec-20011203.html), 
        there should be at least one element by define and one define by element.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--FIXME : adding a check on (s)rng format before proceding each step/function ?-->
  
  <xsl:key name="rng:getDefineByName" match="define" use="@name"/>
  <xsl:key name="rng:getRefByName" match="ref" use="@name"/>
  
  <!--
    NEED context item here !
    <xsl:function name="rng:getDefineByName" as="element(define)*">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="key('rng:getDefineByName', $name)"/>
  </xsl:function>
  
  <xsl:function name="rng:getRefByName" as="element(define)*">
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="key('rng:getRefByName', $name)"/>
  </xsl:function>-->
  
  <xsl:function name="rng:getRootNamespaceUri" as="xs:string">
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:choose>
      <xsl:when test="$grammar/start/choice/ref">
        <xsl:value-of select="(rng:getDefine($grammar/start/choice/ref[1])/element/ancestor-or-self::*[@ns][1]/@ns, $grammar/descendant-or-self::*[@ns][last()])[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="(rng:getDefine($grammar/start/ref[1])/element/ancestor-or-self::*[@ns][1]/@ns, $grammar/descendant-or-self::*[@ns][last()])[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc xml:lang="en">
    <xd:desc>
      <xd:p>Indicates if there is only one possible root element for a given grammar</xd:p>
    </xd:desc>
    <xd:param name="grammar">SRNG grammar element</xd:param>
    <xd:return>true/false</xd:return>
  </xd:doc>
  <xsl:function name="rng:rootIsSingle" as="xs:boolean">
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <!-- in SRNG, each element is in a new define, attributes are expanded, so the start has only ref to elements-->
    <xsl:value-of select="count($grammar/start//ref) = 1"/>
  </xsl:function>
  
  <xsl:function name="rng:getRootDefines" as="element(define)*">
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:sequence select="$grammar/start//ref/rng:getDefine(.)"/>
  </xsl:function>
  
  <xsl:function name="rng:getRootElementsName" as="xs:string*">
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:sequence select="rng:getRootDefines($grammar)[1]/rng:element/@name"/>
  </xsl:function>
  
  <xsl:function name="rng:getDefine" as="element(define)*">
    <xsl:param name="ref" as="element(ref)"/>
    <xsl:sequence select="key('rng:getDefineByName', $ref/@name, $ref/root())"/>
  </xsl:function>
  
  <xsl:function name="rng:defineHasRefName" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <xsl:param name="refName" as="xs:string"/>
    <xsl:sequence select="count($define//ref[@name = $refName]) != 0"/>
  </xsl:function>
  
  <xsl:function name="rng:isInline" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <!--no parent (no ref) for root element--> 
    <xsl:param name="rngParent" as="element(element)?"/>
    <xsl:variable name="rngRefs" select="$rngParent//ref[rng:getDefine(.)/element is $rngElement]" as="element(ref)+"/>
    <xsl:choose>
      <xsl:when test="count($rngRefs) = 0">
        <xsl:message terminate="yes">[ERROR][rng:isInline] No rng:ref found for rngElement "<xsl:value-of select="$rngElement/@name"/>" and $rngParent "<xsl:value-of select="$rngParent/@name"/>"</xsl:message>
      </xsl:when>
      <xsl:when test="count($rngRefs) = 1">
        <xsl:sequence select="rng:refIsInline($rngRefs)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="rngRef.1.isInline" select="rng:refIsInline($rngRefs[1])" as="xs:boolean"/>
        <xsl:choose>
          <!--Every ref has the same type (inline or not inline) so we just return the first one-->
          <xsl:when test="every $rngRef in $rngRefs satisfies rng:refIsInline($rngRef) = $rngRef.1.isInline">
            <xsl:sequence select="$rngRef.1.isInline"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">[ERROR][rng:isInline] <xsl:value-of select="count($rngRefs)"/> rng:ref found, some are inline and some are not ! rngElement "<xsl:value-of select="$rngElement/@name"/>" and $rngParent "<xsl:value-of select="$rngParent/@name"/>"</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="rng:refIsInline" as="xs:boolean">
    <xsl:param name="ref" as="element(rng:ref)"/>
    <!--see http://relaxng.org/spec-20011203.html#IDA0FZR-->
    <!--
      2 possibilités : 
      - mixed qui est converti (srng) en interleave {pattern} text
      ex :
      <interleave>
        <text/>
        <zeroOrMore>
          <choice>
            <ref name="e"/>
            <ref name="ind"/>
      - une autre structure de type 
      ex : 
        <oneOrMore>
          <choice>
            <text/>
            <ref name="ITAL"/>
    -->
    <xsl:sequence select="exists($ref/ancestor::interleave/text) or exists($ref/parent::*/text)"/>
  </xsl:function>
  
  <xsl:function name="rng:isInlineOnly" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:variable name="rngDefine" select="$rngElement/parent::define" as="element(define)"/>
    <xsl:sequence 
      select="every $rngParent in $rngElement/root()//define//ref[@name = $rngDefine/@name]/ancestor::define/rng:element[1] 
      satisfies rng:isInline($rngElement, $rngParent)"/>
  </xsl:function>

  <xsl:function name="rng:isInlineOnly" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="parents.name.scope" as="xs:string*"/>
    <xsl:variable name="rngDefine" select="$rngElement/parent::define" as="element(define)"/>
    <xsl:sequence 
      select="every $rngParent in $rngElement/root()//define//ref[@name = $rngDefine/@name]/ancestor::define/rng:element[1][@name = $parents.name.scope] 
      satisfies rng:isInline($rngElement, $rngParent)"/>
  </xsl:function>

  <xsl:function name="rng:isBlockOnly" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:variable name="rngDefine" select="$rngElement/parent::define" as="element(define)"/>
    <xsl:sequence 
      select="every $rngParent in $rngElement/root()//define//ref[@name = $rngDefine/@name]/ancestor::define/rng:element[1] 
      satisfies not(rng:isInline($rngElement, $rngParent))"/>
  </xsl:function>
  
  <xsl:function name="rng:isBlockOnly" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="parents.name.scope" as="xs:string*"/>
    <xsl:variable name="rngDefine" select="$rngElement/parent::define" as="element(define)"/>
    <xsl:sequence 
      select="every $rngParent in $rngElement/root()//define//ref[@name = $rngDefine/@name]/ancestor::define/rng:element[1][@name = $parents.name.scope] 
      satisfies not(rng:isInline($rngElement, $rngParent))"/>
  </xsl:function>
  
  <xsl:function name="rng:defineHasCircularRef" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <xsl:variable name="define.name" select="$define/@name" as="xs:string"/>
    <xsl:sequence select="exists($define//ref[@name = $define.name])"/>
  </xsl:function>
  
  <xsl:function name="rng:getSRNGdataModelFromXmlElement" as="element(rng:element)?">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:sequence select="rng:getSRNGdataModelFromXpath(els:get-xpath($e, '',  false()), $grammar, ())"/>
  </xsl:function>
  
  <!--2 args signature-->
  <xsl:function name="rng:getSRNGdataModelFromXpath" as="element(rng:element)?">
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:sequence select="rng:getSRNGdataModelFromXpath($xpath, $grammar, ())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Given an xpath and a (simplified) rng:grammar, this function tries to get the associated "rng:define/rng:element"</xd:p>
    </xd:desc>
    <xd:param name="xpath">Absolute xpath of form "/a/b/c" (not "//a" neither "b/c")</xd:param>
    <xd:param name="grammar">the (simplified) RNG root element</xd:param>
    <xd:param name="predicate">[OPTIONAL] Specific predicate on the tested element (i.e. "c" if a/b/c)
      like @foo='bar' (it may helps finding the last ref by discriminating the targeted defines)</xd:param>
    <xd:return>Should return the rng:element (within the rng:grammar) corresponding to the xpath</xd:return>
  </xd:doc>
  <xsl:function name="rng:getSRNGdataModelFromXpath" as="element(rng:element)?">
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:param name="predicate" as="xs:string?"/>
    <xsl:param name="excludeDefinesWithAttributeNotInPredicates" as="xs:boolean"/>
    <xsl:variable name="xpath.tokenized" select="tokenize($xpath, '/')" as="xs:string*"/>
    <xsl:variable name="xpath.rootName" select="$xpath.tokenized[2]" as="xs:string"/>
    <!--dans start on cherche la référence à xpath.rootName-->
    <xsl:variable name="rngRootRef" select="$grammar/start//ref[rng:getDefine(.)/element[1]/@name = $xpath.rootName]" as="element(rng:ref)?"/>
    <xsl:choose>
      <!--Il y en a une ref dans le start, tout va bien : on peut initialiser rng:getSRNGdataModelReccurse()-->
      <xsl:when test="count($rngRootRef) = 1">
        <xsl:variable name="getSRNGdataModelReccurse" select="rng:getSRNGdataModelReccurse(rng:getDefine($rngRootRef)/element[1], string-join($xpath.tokenized[position() gt 2], '/'), $predicate, $excludeDefinesWithAttributeNotInPredicates)" as="element(rng:element)?"/>
        <xsl:sequence select="$getSRNGdataModelReccurse"/>
        <!--<xsl:choose>
          <xsl:when test="count($getSRNGdataModelReccurse) = 0">
            <xsl:sequence select="$getSRNGdataModelReccurse"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>
              <xsl:message terminate="yes">
                <xsl:text>[ERROR] No rng:ref found in rng:start element for </xsl:text><xsl:value-of select="$xpath.rootName"/>
                <xsl:text>&#10;      xpath=</xsl:text><xsl:value-of select="$xpath"/>
                <xsl:text>&#10;      srng uri :</xsl:text><xsl:value-of select="base-uri($grammar)"/> 
              </xsl:message>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>-->
      </xsl:when>
      <xsl:when test="count($rngRootRef) = 0">
        <xsl:message terminate="no">
          <xsl:text>[ERROR] No rng:ref found in rng:start element for </xsl:text><xsl:value-of select="$xpath.rootName"/>
          <xsl:text>&#10;      xpath=</xsl:text><xsl:value-of select="$xpath"/>
          <xsl:text>&#10;      srng uri :</xsl:text><xsl:value-of select="base-uri($grammar)"/> 
        </xsl:message>
      </xsl:when>
    </xsl:choose>
    <!--<xsl:sequence select="rng:getSRNGdataModelReccurse(rng:getDefine($grammar/start/ref[1])/element[1], string-join($xpath.tokenized[position() gt 2], '/'))"/>-->
  </xsl:function>
  
  <xsl:function name="rng:getSRNGdataModelFromXpath" as="element(rng:element)?">
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:param name="predicate" as="xs:string?"/>
    <xsl:sequence select="rng:getSRNGdataModelFromXpath($xpath, $grammar, $predicate, false())"/>
  </xsl:function>
  
  <!--Fonction "PRIVATE" utilisée uniquement pour résoudre rng:getSRNGdataModel()-->
  <xsl:function name="rng:getSRNGdataModelReccurse" as="element(rng:element)?">
    <xsl:param name="rngParentElement" as="element(rng:element)"/> <!--<element name="a"/>-->
    <xsl:param name="xpathFromDataModel" as="xs:string"/> <!--(a)/b/c/d-->
    <xsl:param name="predicates" as="xs:string*"/> <!--multi-string like "@foo = 'bar'"-->
    <xsl:param name="excludeDefinesWithAttributeNotInPredicates" as="xs:boolean"/>
    <xsl:message use-when="false()">rng:getSRNGdataModelReccurse(<xsl:value-of select="els:displayNode($rngParentElement)"/>, '<xsl:value-of select="$xpathFromDataModel"/>')</xsl:message>
    <xsl:variable name="xpathFromDataModel.tokenized" select="tokenize($xpathFromDataModel, '/')" as="xs:string*"/>
    <xsl:choose>
      <!--on a résolu le xpath, donc à l'étape précédente on était bon => rngParentElement-->
      <xsl:when test="count($xpathFromDataModel.tokenized) = 0">
        <xsl:sequence select="$rngParentElement"/>
      </xsl:when>
      <!--Sinon on appele la même fonction réccursivement-->
      <xsl:otherwise>
        <xsl:variable name="currentName" select="$xpathFromDataModel.tokenized[1]" as="xs:string"/>
        <!--Dans a je cherche la référence à b-->
        <xsl:variable name="rngRef" as="element(rng:ref)?">
          <xsl:choose>
            <!--Last step = end of the xpath = tested element : one may add the predicate-->
            <xsl:when test="count($xpathFromDataModel.tokenized) = 1">
              <xsl:sequence select="rng:getRefByElementName($rngParentElement, $currentName, $predicates, $excludeDefinesWithAttributeNotInPredicates)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="rng:getRefByElementName($rngParentElement, $currentName)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <!--Il y en a une ref, tout va bien : on continue avec <element name="b"> et xpath = c/d  -->
          <xsl:when test="count($rngRef) = 1">
            <xsl:sequence select="rng:getSRNGdataModelReccurse(rng:getDefine($rngRef[1])/element[1], string-join($xpathFromDataModel.tokenized[not(position() = 1)], '/'), $predicates)"/>
          </xsl:when>
          <xsl:when test="count($rngRef) = 0">
            <xsl:message terminate="no">
              <xsl:text>[ERROR] No rng:ref found for </xsl:text><xsl:value-of select="els:get-xpath($rngParentElement)"/>
              <xsl:text>&#10;      xpath : </xsl:text><xsl:value-of select="$xpathFromDataModel"/>
              <xsl:text>&#10;      predicate : </xsl:text><xsl:value-of select="$predicates" separator=", "/>
              <xsl:text>&#10;      currentName : </xsl:text><xsl:value-of select="$currentName"/>
              <xsl:text>&#10;      srng uri :</xsl:text><xsl:value-of select="base-uri($rngParentElement)"/> 
            </xsl:message>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--3 args signature of rng:getSRNGdataModelReccurse-->
  <xsl:function name="rng:getSRNGdataModelReccurse" as="element(rng:element)?">
    <xsl:param name="rngParentElement" as="element(rng:element)"/> <!--<element name="a"/>-->
    <xsl:param name="xpathFromDataModel" as="xs:string"/> <!--(a)/b/c/d-->
    <xsl:param name="predicates" as="xs:string*"/> <!--multi-string like "@foo = 'bar'"-->
    <xsl:sequence select="rng:getSRNGdataModelReccurse($rngParentElement, $xpathFromDataModel, $predicates, false())"/>
  </xsl:function>
  
  <xsl:function name="rng:getRefByElementName" as="element(rng:ref)?">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="ref.elementName" as="xs:string"/>
    <xsl:param name="predicates" as="xs:string*"/>
    <xsl:param name="excludeDefinesWithAttributeNotInPredicates" as="xs:boolean"/>
    <xsl:message use-when="false()">[INFO] CALLING rng:getRefByElementName(<xsl:value-of select="els:displayNode($rngElement)"/>, <xsl:value-of select="$ref.elementName"/>, <xsl:value-of select="$predicates"/>)</xsl:message>
    <xsl:variable name="rngRef.tmp1" select="$rngElement//ref[rng:getDefine(.)[element[1]/@name = $ref.elementName]]" as="element(rng:ref)*"/>
    <xsl:variable name="rngRef.tmp2" as="element(rng:ref)*">
      <xsl:choose>
        <xsl:when test="count($rngRef.tmp1) = 1 ">
          <xsl:sequence select="$rngRef.tmp1"/>
        </xsl:when>
        <xsl:when test="count($predicates[normalize-space(.)]) != 0">
          <!--If the predicates is of kind @foo = 'bar', maybe there is such a static define in the schema (<attribute name="foo"><value>bar</value></attribute>)
            (and no other same element's name with the same attribute's name which may have the same value)-->
          <xsl:variable name="xpath.attributeValueTest.reg" as="xs:string">
            <xsl:text>^@(.*?)\s*=\s*'(.*?)'</xsl:text>
          </xsl:variable>
          <xsl:variable name="predicates-as-xml-map" as="element(predicate)*">
            <xsl:for-each select="$predicates">
              <xsl:analyze-string select="." regex="{$xpath.attributeValueTest.reg}">
                <xsl:matching-substring>
                  <predicate att.name="{regex-group(1)}" att.value="{regex-group(2)}"/>
                </xsl:matching-substring>
              </xsl:analyze-string>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="rngRef.tmp1.predicate-filtered" as="element()*">
            <xsl:for-each select="$predicates-as-xml-map">
              <xsl:variable name="predicate" select="." as="xs:string"/>
              <xsl:variable name="att.name" select="@att.name" as="xs:string"/>
              <xsl:variable name="att.value" select="@att.value" as="xs:string"/>
              <xsl:message use-when="false()">[DEBUG] MATCHES <xsl:value-of select="$predicate"/> [name=<xsl:value-of select="$att.name"/>][value=<xsl:value-of select="$att.value"/>]</xsl:message>
              <xsl:for-each select="$rngRef.tmp1/rng:getDefine(.)">
                <define name="{@name}" predicate="{$predicate}" test-attribute.name="{$att.name}" test-attribute.value="{$att.value}">
                  <xsl:attribute name="candidate">
                    <xsl:choose>
                      <!--The attribute is defined with the expected value : it's a possible candidate-->
                      <xsl:when test=".//rng:attribute[@name = $att.name][.//rng:value = $att.value]">
                        <xsl:text>true</xsl:text>
                      </xsl:when>
                      <!--The attribute is defined with values but the expected one is not there : it's not a candidate-->
                      <xsl:when test=".//rng:attribute[@name = $att.name][.//rng:value]">
                        <xsl:text>false</xsl:text>
                      </xsl:when>
                      <!--The attribute is not defined att all : it's not a candidate-->
                      <xsl:when test="not(.//rng:attribute[@name = $att.name])">
                        <xsl:text>false</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <!--The attribute is defined, its value is not constrained with <rng:value> : it's a possible candidate-->
                        <xsl:text>true</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </define>
              </xsl:for-each>
            </xsl:for-each>
            <xsl:if test="$excludeDefinesWithAttributeNotInPredicates">
              <!--Let's exclude defines that have a mandotary attribute which is not present in the predicate--> 
              <xsl:for-each select="$rngRef.tmp1/rng:getDefine(.)">
                <xsl:variable name="define" select="." as="element(rng:define)"/>
                <!--check if each mandatory attribute of the define is present in the predicates-->
                <xsl:for-each select="rng:attribute[not(ancestor::rng:optional)]">
                  <xsl:if test="not(@name = $predicates-as-xml-map/@att.name)">
                    <define name="{$define/@name}" candidate="false" test-attribute="{@name}" excludeDefinesWithAttributeNotInPredicates="true"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:for-each>
            </xsl:if>
          </xsl:variable>
          <xsl:message use-when="false()">
            <debug excludeDefinesWithAttributeNotInPredicates="{$excludeDefinesWithAttributeNotInPredicates}">
              <info>[INFO] CALLING rng:getRefByElementName(<xsl:value-of select="els:displayNode($rngElement)"/>, <xsl:value-of select="$ref.elementName"/>, <xsl:value-of select="$predicates"/>)</info>
              <xsl:copy-of select="$rngRef.tmp1.predicate-filtered"/>
            </debug>
          </xsl:message>
          <xsl:variable name="defines.selected" as="xs:string*">
            <xsl:for-each select="$rngRef.tmp1/rng:getDefine(.)/@name">
              <xsl:variable name="defineName" select="." as="xs:string"/>
              <xsl:if test="count($rngRef.tmp1.predicate-filtered[@name = $defineName][@candidate = 'false']) = 0">
                <xsl:value-of select="$defineName"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="count($defines.selected) != 0">
              <xsl:sequence select="$rngRef.tmp1[@name = $defines.selected]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$rngRef.tmp1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$rngRef.tmp1"/>
        </xsl:otherwise>
      </xsl:choose>  
    </xsl:variable>
    <xsl:message use-when="false()">DEBUG <xsl:value-of select="$ref.elementName"/> : COUNT  <xsl:value-of select="count($rngRef.tmp2)"/></xsl:message>
    <xsl:message use-when="false()">
      <xsl:for-each select="$rngRef.tmp2/rng:getDefine(.)">
        <xsl:value-of select="@name"/> : <xsl:value-of select="count(.//attribute)"/> attributes (dont <xsl:value-of select="count(.//attribute[.//value])"/> avec value)
      </xsl:for-each>
    </xsl:message>
    <xsl:choose>
      <xsl:when test="count($rngRef.tmp2) = 0">
        <!--<xsl:message terminate="yes">[FATAL] rng:getRefByElementName : unable to get any ref !</xsl:message>-->
      </xsl:when>
      <xsl:when test="count($rngRef.tmp2) = 1">
        <xsl:sequence select="$rngRef.tmp2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="rngRef.min.static-attributes" select="(min($rngRef.tmp2/rng:getDefine(.)/count(.//attribute[.//value])), 0)[1]" as="xs:integer"/>
        <xsl:variable name="rngRef" select="($rngRef.tmp2)[rng:getDefine(.)/count(.//attribute[.//value]) = $rngRef.min.static-attributes]" as="element(rng:ref)*"/>
        <!--($rngRef)[last()] may be empty, keep the last of $rngRef.tmp2 if so-->
        <xsl:sequence select="(($rngRef)[1], $rngRef.tmp2[1])[1]"/>
        <!--<xsl:sequence select="$rngRef.tmp2[1]"/>-->
        <xsl:if test="count($rngRef) gt 1">
          <xsl:message>[WARNING][rng:getRefByElementName()] <xsl:value-of select="count($rngRef)"/> rng:ref to define with element's name="<xsl:value-of select="$ref.elementName"/>" found within "<xsl:value-of select="$rngElement/@name"/>" at <xsl:value-of select="els:get-xpath($rngElement)"/>, fallback on last occurence</xsl:message>
          <!--FIXME : ce cas de figure est tout à fait possible quand il y a un choose, ou un mixed, il faut pour cela parser le XML en même temps pour savoir où on est
           => utiliser une vraie librairie RNG !-->
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--3 args signature of rng:getRefByElementName-->
  <xsl:function name="rng:getRefByElementName" as="element(rng:ref)?">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="ref.elementName" as="xs:string"/>
    <xsl:param name="predicates" as="xs:string*"/>
    <xsl:sequence select="rng:getRefByElementName($rngElement, $ref.elementName, $predicates, false())"/>
  </xsl:function>
  
  <!--2 args signature of rng:getRefByElementName-->
  <xsl:function name="rng:getRefByElementName" as="element(rng:ref)?">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="refName" as="xs:string"/>
    <xsl:sequence select="rng:getRefByElementName($rngElement, $refName, ())"/>
  </xsl:function>
  
  <xsl:function name="rng:getAttributeDataType" as="xs:string?">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="$rngElement//attribute[@name = $attName]/data/@type"/>
  </xsl:function>
  
  <!--===========================================================-->
  <!-- rng:mergeIdenticalDefine -->
  <!--===========================================================-->
    
  <xsl:template match="grammar" mode="rng:mergeIdenticalDefine">
    <xsl:message>[INFO] rng:mergeIdenticalDefine on <xsl:value-of select="local-name()"/></xsl:message>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="rng:mergeIdenticalDefine.step1"/>
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="$step" mode="rng:mergeIdenticalDefine.step2"/>
  </xsl:template>
  
  <!-- === STEP1 === -->
  
  <xsl:template match="define" mode="rng:mergeIdenticalDefine.step1">
    <xsl:variable name="current.define" select="." as="element(define)"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:variable name="is-identical-with" 
        select="parent::grammar/define[deep-equal(rng:normalizeDefine4Comparing(.), rng:normalizeDefine4Comparing($current.define))]/@name" 
        as="xs:string*"/>
        <!--[not(. is $current.define)]-->
      <xsl:if test="count($is-identical-with) gt 1">
        <xsl:attribute name="is-identical-with" select="$is-identical-with"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- === STEP2 === -->
  
  <!--keep only the first define when they are multiple identical occurence of it-->
  <xsl:template match="define[preceding-sibling::define[@is-identical-with = current()/@is-identical-with]]" mode="rng:mergeIdenticalDefine.step2"/>
  
  <!--redirect every ref to the first occurence of the multiple define-->
  <xsl:template match="ref[rng:getDefine(.)/@is-identical-with]" mode="rng:mergeIdenticalDefine.step2">
    <xsl:variable name="self" select="." as="element(ref)"/>
    <xsl:variable name="define" select="rng:getDefine(.)" as="element(define)"/>
    <xsl:variable name="define.is-identical-with.token" select="tokenize($define/@is-identical-with, '\s+')" as="xs:string+"/>
    <xsl:variable name="identical.define" select="for $name in $define.is-identical-with.token return key('rng:getDefineByName', $name, $self/root())" as="element(define)+"/>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="name" select="$identical.define[1]/@name"/>
    </xsl:copy>
  </xsl:template>

  <!--delete tmp attribute-->
  <xsl:template match="@is-identical-with" mode="rng:mergeIdenticalDefine.step2"/>
  
  <!--default copy-->
  <xsl:template match="node() | @*" 
    mode="rng:mergeIdenticalDefine.step1 
          rng:mergeIdenticalDefine.step2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="rng:normalizeDefine4Comparing" as="element(define)">
    <xsl:param name="define" as="element(define)"/>
    <define>
      <!--@name must be deleted for comparaison-->
      <xsl:apply-templates select="$define/*" mode="rng:normalizeDefine4Comparing"/>
    </define>
  </xsl:function>

  <xsl:template match="*" mode="rng:normalizeDefine4Comparing">
    <xsl:copy copy-namespaces="no">
      <xsl:for-each select="@*">
        <xsl:sort/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="*" mode="#current">
        <!--<xsl:sort/> NO, it would change the define-->
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!--Sorting on "choice" is ok-->
  <xsl:template match="choice" mode="rng:normalizeDefine4Comparing">
    <xsl:copy copy-namespaces="no">
      <xsl:for-each select="@*">
        <xsl:sort/>
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="*" mode="#current">
        <xsl:sort/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!--===========================================================-->
  <!-- rng:clean -->
  <!--===========================================================-->
  <!--nettoyage du rng (après manip manuelle dessus) pour le garder valide on espère-->
  
  <!--Attention le / est très important, on initie rng:clean sur un document-node(), mais ensuite l'apply-template ci-dessous ne repasse pas par là 
  car on travail avec element(grammar) ci-dessous, ce qui évite une boucle récursive infinie-->
  <xsl:template match="/grammar" mode="rng:clean">
    <xsl:param name="rng:clean_mergeIdenticalDefines" select="false()" as="xs:boolean"/>
    <xsl:message>[INFO] rng:clean on <xsl:value-of select="local-name()"/></xsl:message>
    <xsl:variable name="step" as="element(grammar)">
      <xsl:call-template name="rng:deleteOrphansDefine">
        <xsl:with-param name="tree" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="step" as="element(grammar)">
      <xsl:call-template name="rng:deleteEmptyStructuralInstructionInDataModel">
        <xsl:with-param name="tree" select="$step"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="step" as="element(grammar)">
      <xsl:apply-templates select="$step" mode="#current"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rng:clean_mergeIdenticalDefines">
        <xsl:apply-templates select="$step" mode="rng:mergeIdenticalDefine"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$step"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--Déduplication sur ref dans les choice -->
  <xsl:template match="choice/ref" mode="rng:clean">
    <xsl:if test="not(preceding-sibling::ref[@name = current()/@name])">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <!--Déduplication sur element dans les choice -->
  <xsl:template match="choice/element" mode="rng:clean">
    <xsl:if test="not(preceding-sibling::element[deep-equal(., current())])">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <!--choice within choice is useless-->
  <xsl:template match="choice/choice" mode="rng:clean">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!--=== mode rng:deleteOrphansDefine ===-->
  <!--Suppression des <define> orphelins-->
  
  <!--Un template nommé pour initier la récursivité, puis passage dans un mode du même nom-->
  <xsl:template name="rng:deleteOrphansDefine">
    <xsl:param name="tree" required="yes" as="element()"/>
    <xsl:param name="iteration" select="1" as="xs:integer"/>
    <xsl:variable name="tree.new" as="element()">
      <xsl:apply-templates select="$tree" mode="rng:deleteOrphansDefine"/>
    </xsl:variable>
    <xsl:choose>
      <!--Il reste des éléments vide après traitement, on repasse le traitement-->
      <xsl:when test="$tree.new//define[rng:isOrphanDefine(.)]">
        <xsl:call-template name="rng:deleteOrphansDefine">
          <xsl:with-param name="tree" select="$tree.new"/>
          <xsl:with-param name="iteration" select="$iteration + 1"/>
        </xsl:call-template>
      </xsl:when>
      <!--sinon, on renvoi l'arbre final-->
      <xsl:otherwise>
        <xsl:sequence select="$tree.new"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="define[rng:isOrphanDefine(.)]" mode="rng:deleteOrphansDefine">
    <xsl:message>[INFO][deleteOrphansDefine] Delete <xsl:value-of select="els:displayNode(.)"/></xsl:message>
  </xsl:template>
  
  <!--FIXME : ça ne permets pas de supprimer A qui reférence B qui référence A
  => il faudrait revoir l'algo global => partit du start et aller jusqu'à la fin du modèle en suivant les ref
  En déduire une liste de define utiles et supprimer tous les autres !-->
  <xsl:function name="rng:isOrphanDefine" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <!--Le 3e arg de key() doit $etre un document-node() : on force la chose puisque tree est un element()-->
    <xsl:variable name="virtual.root" as="document-node()">
      <xsl:document>
        <xsl:sequence select="$define/root()"/>
      </xsl:document>
    </xsl:variable>
    <!--Il n'existe pas de référence à ce define qui ne soit pas déjà dans ce define (cas de ref circulaire)-->
    <xsl:sequence select="not(exists(
      key('rng:getRefByName', $define/@name, $virtual.root)[not(ancestor::*[. is $define])]
      ))"/>
  </xsl:function>
  
  <!--=== mode rng:deleteEmptyStructuralInstructionInDataModel ===-->
  
  <!--Un template nommé pour initier la récursivité, puis passage dans un mode du même nom-->
  <xsl:template name="rng:deleteEmptyStructuralInstructionInDataModel">
    <xsl:param name="tree" required="yes" as="element()"/>
    <xsl:param name="iteration" select="1" as="xs:integer"/>
    <!--<xsl:message>[DEBUG][rng:deleteEmptyStructuralInstructionInDataModel] iteration = <xsl:value-of select="$iteration"/></xsl:message>-->
    <xsl:variable name="tree.new" as="element()">
      <xsl:apply-templates select="$tree" mode="rng:deleteEmptyStructuralInstructionInDataModel"/>
    </xsl:variable>
    <xsl:choose>
      <!--Il reste des éléments vide après traitement, on repasse le traitement-->
      <xsl:when test="$tree.new//*[rng:isEmptyStructuralInstructionInDataModel(.)]">
        <xsl:call-template name="rng:deleteEmptyStructuralInstructionInDataModel">
          <xsl:with-param name="tree" select="$tree.new"/>
          <xsl:with-param name="iteration" select="$iteration + 1"/>
        </xsl:call-template>
      </xsl:when>
      <!--sinon, on renvoi l'arbre final-->
      <xsl:otherwise>
        <xsl:sequence select="$tree.new"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[rng:isEmptyStructuralInstructionInDataModel(.)]" mode="rng:deleteEmptyStructuralInstructionInDataModel">
    <!--<xsl:message>[INFO] Delete <xsl:value-of select="els:displayNode(.)"/></xsl:message>-->
  </xsl:template>
  
  <!-- === FONCTIONS utile au mode rng:clean === -->
  
  <!--Tous les éléments qui servent à construire le data model, à l'exclusion de ce qui forme le contenu (<attribute/>, <element/>, <text/>, ...)
  FIXME : quid des ref ?-->
  <xsl:function name="rng:isStructuralInstructionInDataModel" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="
      namespace-uri($e) = 'http://relaxng.org/ns/structure/1.0' 
      and local-name($e) = ('optional', 'zeroOrMore', 'oneOrMore', 'group', 'interleave', 'choice')"/>
  </xsl:function>
  
  <xsl:function name="rng:isEmptyStructuralInstructionInDataModel" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="rng:isStructuralInstructionInDataModel($e) and not($e/*)"/>
  </xsl:function>
  
  <!--copie par défaut dans le mode rng:clean-->
  <xsl:template match="node() | @*" mode="rng:clean rng:deleteEmptyStructuralInstructionInDataModel rng:deleteOrphansDefine">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--===========================================================-->
  <!-- rng:reorder -->
  <!--===========================================================-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>mode="rng:reorder"</xd:p>
      <xd:p>Réordonne les define d'un fichier RNG simplifié, en se basant sur le nom de l'élément</xd:p>
      <xd:p>Si 2 éléments ont le même nom, l'ordre pourra se faire sur la valeur d'un attribut, par défaut @class</xd:p>
    </xd:desc>
  </xd:doc>
  <!--FIXME : impossible d'appeler cette xsl avec initial mode = rng:reorder avec saxon
  il semble que le nom du mode ne peut pas être préfixé-->
  
  <xsl:param name="rng:reorder_renameDefineRef" select="true()" as="xs:boolean"/>
  
  <xsl:template match="/" mode="rng:reorder">
    <xsl:param name="rng:reorder_byAttributeName" select="'class'" as="xs:string?"/>
    <xsl:param name="rng:reorder_addRootNamespaces" as="node()*">
      <!--NB : http://markmail.org/message/gfmje533lawarcsg-->
      <!--<xsl:namespace name="rng">http://relaxng.org/ns/structure/1.0</xsl:namespace>-->
    </xsl:param>
    <xsl:apply-templates mode="#current">
      <xsl:with-param name="rng:reorder_byAttributeName" select="$rng:reorder_byAttributeName"/>
      <xsl:with-param name="rng:reorder_addGrammarNamespaces" select="$rng:reorder_addRootNamespaces"/>
    </xsl:apply-templates>
  </xsl:template> 
  
  <xsl:template match="/grammar" mode="rng:reorder">
    <xsl:param name="rng:reorder_byAttributeName" as="xs:string?"/>
    <xsl:param name="rng:reorder_addGrammarNamespaces" as="node()*"/>
    <xsl:message>[INFO] rng:reorder sur <xsl:value-of select="local-name()"/></xsl:message>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:copy copy-namespaces="yes">
          <xsl:copy-of select="$rng:reorder_addGrammarNamespaces"/>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:apply-templates select="start" mode="#current"/>
          <xsl:apply-templates select="define" mode="#current">
            <!--when converting dtd2rng trang.jar generates <define name="attlist.elementName">, so we keep this next to the define <define name="elementName">
              => Not really usefull because in this case trang.jar  already order defines in a good way !--> 
            <xsl:sort 
              select="concat(
              (element[1]/@name, element[1]/name)[1]/lower-case(replace(., '^attlist\.', '')), 
               '_',
               element[1]//attribute[@name = $rng:reorder_byAttributeName]/value/text()
               )"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:document>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rng:reorder_renameDefineRef">
        <xsl:apply-templates select="$step" mode="rng:renameDefineAndRefByElementNameAndOrder"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$step"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="rng:reorder">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Rename define and ref by element name and order in the rng document</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="/grammar" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:message>[INFO] rng:renameDefineAndRefByElementNameAndOrder sur <xsl:value-of select="local-name()"/></xsl:message>
    <xsl:next-match/>
  </xsl:template>
  
  <!--Exception : here we accept an non simplified RNG schema, so we add a filter on define[element]--> 
  <xsl:template match="define[element]/@name" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:variable name="define" select="parent::define" as="element()"/>
    <xsl:variable name="elementName" select="($define/element[1]/@name, $define/element[1]/name)[1]" as="xs:string"/>
    <xsl:variable name="count" select="count($define/preceding-sibling::define[(element[1]/@name, element[1]/name)[1] = $elementName])" as="xs:integer"/>
    <xsl:attribute name="{name(.)}">
      <xsl:choose>
        <xsl:when test="$count = 0">
          <xsl:sequence select="$elementName"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="concat($elementName, '_', $count + 1)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="ref/@name" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:variable name="ref" select="parent::ref" as="element()"/>
    <xsl:apply-templates select="rng:getDefine($ref)/@name" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--===========================================================-->
  <!-- rng:getXpathFromDataModel -->
  <!--===========================================================-->
  <!--/!\ WARNING : please use this function only for testing, it's just a Proof Of Concept, but this is really greedy !
                    PLEASE NEVER USE IT IN REAL CODE !
  -->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns a list of xpath that matches a rng:element definition in the schema</xd:p>
    </xd:desc>
    <xd:param name="element">Any rng:element in a simplified RNG schema</xd:param>
    <xd:param name="xpath.level">Indicate which level of xpath to go up from the element</xd:param>
    <xd:return>A list of xpath</xd:return>
  </xd:doc>
  <xsl:function name="rng:getXpathFromDataModel" as="xs:string*">
    <xsl:param name="element" as="element(rng:element)"/>
    <xsl:param name="xpath.level" as="xs:integer"/>
    <xsl:for-each select="distinct-values(rng:getXpathFromDataModel_debug($element, $xpath.level)/descendant-or-self::xpath/@value)">
      <xsl:sort/>
      <xsl:sequence select="."/>
    </xsl:for-each>
  </xsl:function>
  
  <!--1 arg signature-->
  <xsl:function name="rng:getXpathFromDataModel" as="xs:string*">
    <xsl:param name="element" as="element(rng:element)"/>
    <xsl:sequence select="rng:getXpathFromDataModel($element, -1)"/><!-- "-1" means infinite-->
  </xsl:function>
  
  <xsl:function name="rng:getXpathFromDataModel_debug" as="element(ref)*">
    <xsl:param name="element" as="element(rng:element)"/>
    <xsl:param name="xpath.level" as="xs:integer"/>
    <xsl:apply-templates select="$element/parent::define" mode="rng:backToStartXpath">
      <xsl:with-param name="xpath.maxLevel" select="$xpath.level" tunnel="yes"/>
      <xsl:with-param name="xpath.level" select="1"/> <!--init-->
    </xsl:apply-templates>
  </xsl:function>
  
  <xsl:template match="define" mode="rng:backToStartXpath">
    <xsl:param name="reverse.xpath" as="xs:string?"/> <!--empty at first iteration-->
    <xsl:param name="ref.iterated" as="element(rng:ref)*"/>
    <xsl:param name="xpath.level" required="yes" as="xs:integer"/>
    <xsl:variable name="element" select="element" as="element(rng:element)"/>
    <xsl:variable name="refToThis" select="ancestor::grammar//ref[rng:getDefine(.) is current()]" as="element(rng:ref)*"/>
    <xsl:variable name="refToThis.notCircular" select="$refToThis[not(ancestor::define is current())]" as="element(rng:ref)*"/>
    <xsl:choose>
      <xsl:when test="$refToThis.notCircular intersect $ref.iterated">
        <stop cause="circularRef"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$refToThis.notCircular" mode="#current">
          <xsl:with-param name="reverse.xpath" as="xs:string">
            <xsl:choose>
              <!--init on first iteration-->
              <xsl:when test="count($reverse.xpath) = 0">
                <xsl:value-of select="$element/@name"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($reverse.xpath, '\', $element/@name)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="ref.iterated" select="$ref.iterated"/>
          <xsl:with-param name="xpath.level" select="$xpath.level + 1"/> 
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="ref" mode="rng:backToStartXpath">
    <xsl:param name="reverse.xpath" as="xs:string"/>
    <xsl:param name="ref.iterated" as="element(rng:ref)*"/>
    <xsl:param name="xpath.level" as="xs:integer"/>
    <xsl:param name="xpath.maxLevel" as="xs:integer" tunnel="yes"/>
    <ref reverse.xpath="{$reverse.xpath}" current-ref="{@name}" current-define="{ancestor::define/@name}" xpath.level="{$xpath.level}">
      <xsl:choose>
        <!--<xsl:when test="self::ref intersect $ref.iterated">
          <xsl:message>[STOP] on est déjà passé par le ref name="<xsl:value-of select="@name"/>" dans le define "<xsl:value-of select="ancestor::define/@name"/>"</xsl:message>
          <xsl:variable name="reverse.xpath.tokenized" select="tokenize($reverse.xpath, '\\')" as="xs:string*"/>
          <xsl:variable name="reverse.xpath.tokenized.reverse" select="reverse($reverse.xpath.tokenized)" as="xs:string*"/>
          <xpath debug="w1" value="{concat('//', string-join($reverse.xpath.tokenized.reverse, '/'))}"/>
        </xsl:when>-->
        <xsl:when test="ancestor::start">
          <xsl:variable name="reverse.xpath.tokenized" select="tokenize($reverse.xpath, '\\')" as="xs:string*"/>
          <xsl:variable name="reverse.xpath.tokenized.reverse" select="reverse($reverse.xpath.tokenized)" as="xs:string*"/>
          <xpath debug="w2" value="{concat('/', string-join($reverse.xpath.tokenized.reverse, '/'))}"/>
        </xsl:when>
        <xsl:when test="($xpath.maxLevel gt -1) and ($xpath.level gt $xpath.maxLevel)">
          <stop cause="maxLevel" xpath.level="{$xpath.level}"/>
          <xsl:variable name="reverse.xpath.tokenized" select="tokenize($reverse.xpath, '\\')" as="xs:string*"/>
          <xsl:variable name="reverse.xpath.tokenized.reverse" select="reverse($reverse.xpath.tokenized)" as="xs:string*"/>
          <xpath debug="w3" value="{string-join($reverse.xpath.tokenized.reverse, '/')}"/>
        </xsl:when>
        <xsl:when test="ancestor::define">
          <xsl:apply-templates select="ancestor::define" mode="#current">
            <xsl:with-param name="reverse.xpath" select="$reverse.xpath" as="xs:string"/>
            <xsl:with-param name="ref.iterated" select="($ref.iterated, .)" as="element(rng:ref)*"/>
            <xsl:with-param name="xpath.level" select="$xpath.level"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">[ERROR] no ancestor define for <xsl:value-of select="els:get-xpath(.)"/></xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </ref>
  </xsl:template>
  
</xsl:stylesheet>