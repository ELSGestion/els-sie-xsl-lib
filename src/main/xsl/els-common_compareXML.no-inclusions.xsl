<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Static compilation check for all inclusions to be available (avoid xslt mode not load)-->
  <xsl:variable name="xslLib:els-common_compareXML.no-inclusions.check-available-inclusions">
    <xsl:sequence select="$xslLib:els-common_constants.available"/>
    <xsl:sequence select="$xslLib:els-common_xml.no-inclusions.available"/>
    <xsl:sequence select="$xslLib:els-common_strings.no-inclusions.available"/>
  </xsl:variable>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
        You may also you the standalone version of this XSLT (without "no-inclusions" extension)
      </xd:p>
      <xd:p>ELS-COMMON lib : module "CompareXML"</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:key name="getElementByPath" match="*" use="els:get-xpath(.)"/>
  
  <xsl:param name="els:compareXML.ignore-comments-diff" select="false()" as="xs:boolean"/>
  <xsl:param name="els:compareXML.ignore-comments-order" select="false()" as="xs:boolean"/>
  <xsl:param name="els:compareXML.ignore-processing-instructions-diff" select="false()" as="xs:boolean"/>
  <xsl:param name="els:compareXML.ignore-processing-instructions-order" select="false()" as="xs:boolean"/>
  <xsl:param name="els:compareXML.ignore-text-content-diff" select="false()" as="xs:boolean"/>
  <xsl:param name="els:compareXML.ignore-attributes-diff" select="false()" as="xs:boolean"/>
  
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
    <xd:return>differences or empty sequence if every attributes are the same</xd:return>
  </xd:doc>
  <xsl:function name="els:compare-attributes" as="element(difference)?">
    <xsl:param name="e1" as="element()"/>
    <xsl:param name="e2" as="element()"/>
    <xsl:if test="not($els:compareXML.ignore-attributes-diff)">
      <xsl:variable name="att1" as="xs:string*">
        <xsl:for-each select="$e1/@*[string(.) != '...']">
          <xsl:sort select="local-name()"/>
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
          <xsl:variable name="self" select="." as="attribute()"/>
          <xsl:variable name="e1.att" select="$e1/@*[name() = $self/name()]" as="attribute()?"/>
          <!--keep the attribute except if there an equivalent attribute in e1 whose value = '...'-->
          <xsl:if test="not(exists($e1.att) and string($e1.att) = '...')">
            <xsl:value-of select="concat(local-name(), '=&quot;', string(.), '&quot;')"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
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
    </xsl:if>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Compare comments of 2 elements $e1 and $e2</xd:p>
      <xd:p>If one the the comment contains '...' then ignore it (like Xspec)</xd:p>
    </xd:desc>
    <xd:return>differences or empty sequence if all comments are the same</xd:return>
  </xd:doc>
  <xsl:function name="els:compare-comments" as="element(differences)?">
    <xsl:param name="e1" as="element()"/>
    <xsl:param name="e2" as="element()"/>
    <xsl:if test="not($els:compareXML.ignore-comments-diff)">
      <xsl:variable name="e1.comments" select="$e1/comment()" as="comment()*"/>
      <xsl:variable name="e2.comments" select="$e2/comment()" as="comment()*"/>
      <xsl:variable name="comment1.differences" as="element(differences)">
        <differences>
          <xsl:for-each select="$e1.comments">
            <xsl:variable name="position" select="position()" as="xs:integer"/>
            <xsl:variable name="e1.comment" select="." as="comment()"/>
            <xsl:variable name="e2.comment" select="$e2.comments[position() = $position]" as="comment()?"/>
            <xsl:if test="not(exists($e2.comment))">
              <missing>
                <e1><xsl:sequence select="els:displayNode(.)"/></e1>
                <e2/>
              </missing>
            </xsl:if>
            <xsl:if test="string($e1.comment) != '...' and string($e2.comment) != '...' and $e1.comment != $e2.comment">
              <comment>
                <e1><xsl:sequence select="els:displayNode($e1.comment)"/></e1>
                <e2><xsl:sequence select="els:displayNode($e2.comment)"/></e2>
              </comment>
            </xsl:if>
          </xsl:for-each>
        </differences>
      </xsl:variable>
      <xsl:variable name="comment2.differences" as="element(differences)">
        <differences>
          <xsl:for-each select="$e2.comments">
            <xsl:variable name="position" select="position()" as="xs:integer"/>
            <xsl:variable name="e2.comment" select="." as="comment()"/>
            <xsl:variable name="e1.comment" select="$e1.comments[position() = $position]" as="comment()?"/>
            <xsl:if test="not(exists($e1.comment))">
              <comment>
                <missing>
                  <e1/>
                  <e2><xsl:sequence select="els:displayNode(.)"/></e2>
                </missing>
              </comment>
            </xsl:if>
            <!--This difference has already been raised in the 1st variable comment1.differences-->
            <!--<xsl:if test="string($e1.comment) != '...' and string($e2.comment) != '...' and $e2.comment != $e1.comment">
            <comment>
              <e1><xsl:sequence select="els:displayNode($e1.comment)"/></e1>
              <e2><xsl:sequence select="els:displayNode($e2.comment)"/></e2>
            </comment>
          </xsl:if>-->
          </xsl:for-each>
        </differences>
      </xsl:variable>
      <xsl:if test="not(empty(($comment1.differences/*, $comment2.differences/*)))">
        <differences>
          <xsl:sequence select="($comment1.differences/*, $comment2.differences/*)"/>
        </differences>
      </xsl:if>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Compare comments of 2 elements $e1 and $e2</xd:p>
      <xd:p>If one the the comment contains '...' then ignore it (like Xspec)</xd:p>
    </xd:desc>
    <xd:return>differences or empty sequence if all comments are the same</xd:return>
  </xd:doc>
  <xsl:function name="els:compare-processing-instructions" as="element(differences)?">
    <xsl:param name="e1" as="element()"/>
    <xsl:param name="e2" as="element()"/>
    <xsl:variable name="e1.pis" select="$e1/processing-instruction()" as="processing-instruction()*"/>
    <xsl:variable name="e2.pis" select="$e2/processing-instruction()" as="processing-instruction()*"/>
    <xsl:if test="not($els:compareXML.ignore-processing-instructions-diff)">
      <xsl:variable name="pi1.differences" as="element(differences)">
        <differences>
          <xsl:for-each select="$e1.pis">
            <xsl:variable name="position" select="position()" as="xs:integer"/>
            <xsl:variable name="e1.pi" select="." as="processing-instruction()"/>
            <xsl:variable name="e2.pi" select="$e2.pis[position() = $position]" as="processing-instruction()?"/>
            <xsl:if test="not(exists($e2.pi))">
              <missing>
                <e1><xsl:sequence select="els:displayNode(.)"/></e1>
                <e2/>
              </missing>
            </xsl:if>
            <xsl:if test="string($e1.pi) != '...' and string($e2.pi) != '...' and ($e1.pi != $e2.pi or $e1.pi/name() != $e2.pi/name())">
              <processing-instruction>
                <e1><xsl:sequence select="els:displayNode($e1.pi)"/></e1>
                <e2><xsl:sequence select="els:displayNode($e2.pi)"/></e2>
              </processing-instruction>
            </xsl:if>
          </xsl:for-each>
        </differences>
      </xsl:variable>
      <xsl:variable name="pi2.differences" as="element(differences)">
        <differences>
          <xsl:for-each select="$e2.pis">
            <xsl:variable name="position" select="position()" as="xs:integer"/>
            <xsl:variable name="e2.pi" select="." as="processing-instruction()"/>
            <xsl:variable name="e1.pi" select="$e1.pis[position() = $position]" as="processing-instruction()?"/>
            <xsl:if test="not(exists($e1.pi))">
              <missing>
                <e1/>
                <e2><xsl:sequence select="els:displayNode(.)"/></e2>
              </missing>
            </xsl:if>
            <!--This difference has already been raised in the 1st variable comment1.differences-->
            <!--<xsl:if test="string($e1.pi) != '...' and string($e2.pi) != '...' and ($e2.pi != $e1.pi or $e2.pi/name() != $e1.pi/name())">
              <processing-instruction>
                <e1><xsl:sequence select="els:displayNode($e1.pi)"/></e1>
                <e2><xsl:sequence select="els:displayNode($e2.pi)"/></e2>
              </processing-instruction>
            </xsl:if>-->
          </xsl:for-each>
        </differences>
      </xsl:variable>
      <xsl:if test="not(empty(($pi1.differences/*, $pi2.differences/*)))">
        <differences>
          <xsl:sequence select="($pi1.differences/*, $pi2.differences/*)"/>
        </differences>
      </xsl:if>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Compare 2 XML elements e1 and e2 : attributes, children, processing-instruction, comment and text content</xd:p>
    </xd:desc>
    <xd:param name="e1">Element 1</xd:param>
    <xd:param name="e2">Element 2</xd:param>
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
          <!--ATTRIBUTES-->
          <xsl:variable name="attributes.differences" select="els:compare-attributes($e1, $e2)" as="element(difference)?"/>
          <!--If there are differences in attribute, display them-->
          <xsl:if test="not(empty($attributes.differences))">
            <attributes>
              <xsl:sequence select="$attributes.differences/*"/>
            </attributes>
          </xsl:if>
          <!--CHILDREN-->
          <xsl:variable name="children.differences" select="els:compare-children($e1, $e2)" as="element(differences)?"/>
          <!--If there are differences in attribute, display them-->
          <xsl:if test="not(empty($children.differences))">
            <xsl:sequence select="$children.differences/*"/>
          </xsl:if>
          <!--COMMENTS-->
          <xsl:variable name="comments.differences" select="els:compare-comments($e1, $e2)" as="element(differences)?"/>
          <xsl:if test="not(empty($comments.differences))">
            <xsl:sequence select="$comments.differences/*"/>
          </xsl:if>
          <!--PROCESSING-INSTRUCTIONS-->
          <xsl:variable name="processing-instruction.differences" select="els:compare-processing-instructions($e1, $e2)" as="element(differences)?"/>
          <xsl:if test="not(empty($processing-instruction.differences))">
            <xsl:sequence select="$processing-instruction.differences/*"/>
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
  
  <xsl:function name="els:compare-children" as="element(differences)?">
    <xsl:param name="e1" as="element()"/>
    <xsl:param name="e2" as="element()"/>
    <xsl:variable name="childNodes1.toCompare.text-list" select="els:get-childNodes-text-list($e1)" as="xs:string?"/>
    <xsl:variable name="childNodes2.toCompare.text-list" select="els:get-childNodes-text-list($e2)" as="xs:string?"/>
    <xsl:if test="$childNodes1.toCompare.text-list != $childNodes2.toCompare.text-list">
      <differences>
        <children>
          <e1>
            <xsl:value-of select="$childNodes1.toCompare.text-list"/>
          </e1>
          <e2>
            <xsl:value-of select="$childNodes2.toCompare.text-list"/>
          </e2>
        </children>
      </differences>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="els:get-childNodes-text-list" as="xs:string?">
    <xsl:param name="e" as="element()"/>
    <xsl:variable name="childNodes" select="$e/node()[not(self::text())]" as="node()*"/>
    <xsl:variable name="childNodes.filtered" as="node()*" 
      select="$childNodes except $childNodes
      [self::processing-instruction()[$els:compareXML.ignore-processing-instructions-order]]
      [self::comment()[$els:compareXML.ignore-comments-order]]"/>
    <xsl:variable name="result" as="xs:string*">
      <xsl:for-each select="$childNodes.filtered">
        <xsl:choose>
          <xsl:when test="self::*">
            <xsl:sequence select="name()"/>
          </xsl:when>
          <xsl:when test="self::comment()">
            <xsl:sequence select="'comment()'"/>
          </xsl:when>
          <xsl:when test="self::processing-instruction()">
            <xsl:variable name="tmp" as="xs:string*">
              <xsl:text>processing-instruction('</xsl:text>
              <xsl:value-of select="name()"/>
              <xsl:text>')</xsl:text>
            </xsl:variable>
            <xsl:sequence select="string-join($tmp, '')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="string-join($result, ' | ')"/>
  </xsl:function>
  
</xsl:stylesheet>