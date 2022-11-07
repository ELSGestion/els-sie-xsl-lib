<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "CompareXML"</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common_xml.xsl"/>
  
  <xsl:output indent="true"/>
  
  <xsl:key name="getElementByPath" match="*" use="els:get-xpath(.)"/>
  
  <!--===============================-->
  <!--COMPARE XML-->
  <!--===============================-->
  
  <xd:p>Given doc1 and doc2 this function compares the 2 documents to show out their differences</xd:p>
  
  <xsl:function name="els:compareXML" as="element()">
    <xsl:param name="doc1" as="document-node()"/>
    <xsl:param name="doc2" as="document-node()"/>
    <differences doc1-uri="{($doc1/*/@about, $doc1/base-uri())[1]}" doc2-uri="{($doc2/*/@about, $doc2/base-uri())[1]}">
      <xsl:apply-templates select="$doc1/*" mode="els:compareXML">
        <xsl:with-param name="doc2" select="$doc2" as="document-node()" tunnel="yes"/>
      </xsl:apply-templates>
    </differences>
  </xsl:function>
  
  <xsl:template match="*" mode="els:compareXML">
    <xsl:param name="doc2" as="document-node()" tunnel="yes"/>
    <xsl:variable name="doc1.element.path" select="els:get-xpath(.)" as="xs:string"/>
    <xsl:variable name="doc1.element" select="." as="element()" />
    <xsl:variable name="doc2.element" select="key('getElementByPath', $doc1.element.path , $doc2)" as="element()?" />
    <xsl:variable name="comparison" select="els:compare-2-elements($doc1.element, $doc2.element)"/>
    <xsl:choose>
      <!--If there are differences-->
      <xsl:when test="not(empty($comparison))">
        <found path="{$doc1.element.path}">
          <xsl:copy-of select="$comparison"/>
        </found>
        <xsl:if test="not(empty($doc2.element))">
          <xsl:apply-templates select="*" mode="#current"/>
        </xsl:if>
        <!--OLD code that try to get an element with a same id to get better diff, FIXME : make it better-->
        <!--If current doc1 element has an @id : try to found within doc2, another element with the same id (or one of its descendant) and the same name (ou nearest ancestor)-->
        <!--<!-\-<xsl:variable name="v1" select="$doc2//*[$nd1/@id and @id = (($nd1//@id)[1])]"/>-\->
        <!-\-<xsl:variable name="v2" select="$v1/ancestor-or-self::*[local-name() = local-name($nd1)]"/>-\->
        <xsl:variable name="otherElementsIndoc2" select="if (exists($doc1.element/@id)) then 
          ($doc2//*[@id = $doc1.element/@id]/ancestor-or-self::*[local-name() = local-name($doc1.element)])
          else()"/>
        <xsl:choose>
          <!-\-When this element exists (or many) excluding those whose id='...' (like xspec)-\->
          <xsl:when test="not(empty($otherElementsIndoc2)) and $doc1.element/@id != '...'">
            <found-ID path="{$doc1.element.path}" id="{$doc1.element/@id}">
              <!-\-copy former comparison-\->
              <xsl:copy-of select="$comparison"/>
              <xsl:for-each select="$otherElementsIndoc2">
                <xsl:variable name="otherElementsIndoc2.element" select="." as="element()"/>
                <!-\-Process comparison between each other element found in doc B and the current element in doc1-\-> 
                <xsl:variable name="candidate.comparison" select="els:compare-2-elements($doc1.element, $otherElementsIndoc2.element)"/>
                <xsl:choose>
                  <!-\-If no differences found keep trace of this other element as candidate-\->
                  <xsl:when test="empty($candidate.comparison)">
                    <candidate>
                      <xsl:copy-of select="$doc1.element/*"/>
                      <xsl:copy-of select="$otherElementsIndoc2.element"/>
                    </candidate>
                  </xsl:when>
                  <!-\-If there are differences display them-\->
                  <xsl:otherwise>
                    <xsl:variable name="genId" select="generate-id(.)"/>
                    <found path="{els:get-xpath($otherElementsIndoc2.element)}">
                      <xsl:copy-of select="$candidate.comparison"/>
                    </found>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </found-ID>
          </xsl:when>
          <xsl:otherwise>
            <found path="{$doc1.element.path}">
              <xsl:copy-of select="$comparison"/>
            </found>
            <xsl:if test="not(empty($doc2.element))">
              <xsl:apply-templates select="*" mode="#current"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>-->
        </xsl:when>
      <!--If there are no differences, continue with the children of the current element in doc1-->
      <xsl:otherwise>
        <xsl:apply-templates select="*" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Compare attributes of 2 elements $e1 and $e2</xd:p>
      <xd:p>Attribute order doesn't matter</xd:p>
      <xd:p>If one the the attribute contains '...' then ignore it (like Xspec)</xd:p>
    </xd:desc>
    <xd:return>differences or empty sequence all attributes are the same</xd:return>
  </xd:doc>
  <xsl:function name="els:compare-attributes" as="element(difference)?">
    <xsl:param name="e1" as="element()"/>
    <xsl:param name="e2" as="element()"/>
    <xsl:variable name="att1" as="xs:string*">
      <xsl:for-each select="$e1/@*[string(.) != '...']">
        <xsl:sort select="local-name()"/>
        <!--<xsl:message>fe1 <xsl:value-of select="name()"/></xsl:message>-->
        <xsl:variable name="self" select="." as="attribute()"/>
        <xsl:variable name="e2.att" select="$e2/@*[name() = $self/name()]" as="attribute()?"/>
        <!--keep the attribute except if there an equivalent attribute in e2 whose value = '...'-->
        <xsl:if test="not(exists($e2.att) and string($e2.att) = '...')">
          <xsl:value-of select="concat(local-name(), '=&quot;', string(.), '&quot;')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="att2" as="xs:string*">
      <xsl:for-each select="$e2/@*[string(.) != '...']">
        <xsl:sort select="local-name()"/>
        <!--<xsl:message>fe2 <xsl:value-of select="name()"/></xsl:message>-->
        <xsl:variable name="self" select="." as="attribute()"/>
        <xsl:variable name="e1.att" select="$e1/@*[name() = $self/name()]" as="attribute()?"/>
        <!--keep the attribute except if there an equivalent attribute in e1 whose value = '...'-->
        <xsl:if test="not(exists($e1.att) and string($e1.att) = '...')">
          <xsl:value-of select="concat(local-name(), '=&quot;', string(.), '&quot;')"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <!--<xsl:message>e1 : <xsl:value-of select="els:displayNode($e1)"/> : <xsl:value-of select="$att1"/></xsl:message>-->
    <!--<xsl:message>e2 : <xsl:value-of select="els:displayNode($e2)"/> : <xsl:value-of select="$att2"/></xsl:message>-->
    <!--<xsl:message>same-att = <xsl:value-of select="string-join($att1, '') = string-join($att2, '')"/></xsl:message>-->
    <xsl:if test="not(string-join($att1, '') = string-join($att2, ''))">
      <difference>
        <e1>
          <xsl:value-of select="$att1[not(. = $att2)]" separator=" | "/>
        </e1>
        <e2>
          <xsl:value-of select="$att2[not(. = $att1)]" separator=" | "/>
        </e2>
      </difference>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Compare 2 XML elements e1 and e2 : attributes, children (only elements FIXME pi, comment) and text content</xd:p>
    </xd:desc>
    <xd:param name="e1"></xd:param>
    <xd:param name="e2"></xd:param>
    <xd:return>Return a comparison report</xd:return>
  </xd:doc>
  <xsl:function name="els:compare-2-elements" as="element(difference)?">
    <xsl:param name="e1" as="element()?"/>
    <xsl:param name="e2" as="element()?"/>
    <xsl:variable name="difference" as="element()*">
      <xsl:choose>
        <!--element e1 missing-->
        <xsl:when test="empty($e1)">
          <missing>
            <e1/>
            <e2>
              <xsl:value-of select="name($e2)"/>
            </e2>
          </missing>
        </xsl:when>
        <!--element e2 missing-->
        <xsl:when test="empty($e2)">
          <missing>
            <e1>
              <xsl:value-of select="name($e1)"/>
            </e1>
            <e2/>
          </missing>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message select="els:compare-attributes($e1, $e2)"/>
          <!--ATTRIBUTES-->
          <xsl:variable name="attributes.difference" select="els:compare-attributes($e1, $e2)" as="element(difference)?"/>
          <!--If there are differences in attribute, display them-->
          <xsl:if test="not(empty($attributes.difference))">
            <attributes>
              <xsl:sequence select="$attributes.difference/*"/>
            </attributes>
          </xsl:if>
          <!--CHILDREN-->
          <xsl:variable name="children1.list" select="string-join($e1/*/local-name(), ' | ')"/>
          <xsl:variable name="children2.list" select="string-join($e2/*/local-name(), ' | ')"/>
          <xsl:if test="$children1.list != $children2.list">
            <children>
              <e1>
                <xsl:value-of select="$children1.list"/>
              </e1>
              <e2>
                <xsl:value-of select="$children2.list"/>
              </e2>
            </children>
          </xsl:if>
          <!--TEXT CONTENT-->
          <xsl:if test="normalize-space(string-join($e1/text(), ' ')) != normalize-space(string-join($e2/text(), ' '))">
            <content>
              <e1>
                <xsl:value-of select="normalize-space(string-join($e1/text(), ' '))"/>
              </e1>
              <e2>
                <xsl:value-of select="normalize-space(string-join($e2/text(), ' '))"/>
              </e2>
            </content>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not(empty($difference))">
      <difference>
        <xsl:sequence select="$difference"/>
      </difference>
    </xsl:if>
  </xsl:function>
  
</xsl:stylesheet>