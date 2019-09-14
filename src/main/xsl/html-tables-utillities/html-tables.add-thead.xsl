<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Add thead element when missing on html tables. The rule applied are :</xd:p>
      <xd:ul>
        <xd:li>get the maximum raws in the thead</xd:li> 
        <xd:li>each raw within thead must only contains th elements</xd:li>
        <xd:li>the table structure must be valid obviously</xd:li>
      </xd:ul>
      <xd:p>NB: the table structure must be in HTML namespace</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--===================================================-->
  <!--INIT-->
  <!--===================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:html-table-add-thead.main"/>
  </xsl:template>
  
  <!--===================================================-->
  <!--MAIN-->
  <!--===================================================-->
  
  <xsl:mode name="xslLib:html-table-add-thead.main" on-no-match="shallow-copy"/>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Add automatic thead</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="table[not(thead)]" mode="xslLib:html-table-add-thead.main">
    <xsl:variable name="number-tr-in-thead" as="xs:integer" 
      select="max((count(tr[xslLib:isTrEligibleToThead(.)]), count(tbody/tr[xslLib:isTrEligibleToThead(.)])))"/>
    <xsl:message use-when="false()">number-tr-in-thead = <xsl:value-of select="$number-tr-in-thead"/></xsl:message>
    <xsl:apply-templates select="." mode="xslLib:html-table-add-thead">
      <xsl:with-param name="number-tr-in-thead" tunnel="true" as="xs:integer" select="$number-tr-in-thead"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:mode name="xslLib:html-table-add-thead" on-no-match="shallow-copy"/>
  
  <xsl:template match="table[not(tbody)]" mode="xslLib:html-table-add-thead">
    <xsl:param name="number-tr-in-thead" tunnel="true" as="xs:integer"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="name() = 'tr' and count(preceding-sibling::tr) lt $number-tr-in-thead">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <thead>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </thead>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="tbody" mode="xslLib:html-table-add-thead">
    <xsl:param name="number-tr-in-thead" tunnel="true" as="xs:integer"/>
    <xsl:variable name="self" select="." as="element(tbody)"/>
    <xsl:for-each-group select="*" group-adjacent="name() = 'tr' and count(preceding-sibling::tr) lt $number-tr-in-thead">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <thead>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </thead>
        </xsl:when>
        <xsl:otherwise>
          <tbody>
            <xsl:apply-templates select="$self/@*" mode="#current"/>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </tbody>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns true() if a tr is "eligible" to be moved to the thead. Conditions:</xd:p>
      <xd:ul>
        <xd:li>The tr must have some th only and no td</xd:li>
        <xd:li>All preceding siblings tr should also be eligible (this is a recursive function)</xd:li>
        <xd:li>When tr has rowspan cells : they must not "intersect" with non-eligible tr</xd:li>
      </xd:ul>
    </xd:desc>
    <xd:param name="tr">The current tr</xd:param>
    <xd:param name="check-rowspan">Check rowspan intersection (it's usefull to be able to set it to false to avoid infinite recursion)</xd:param>
  </xd:doc>
  <xsl:function name="xslLib:isTrEligibleToThead" as="xs:boolean">
    <xsl:param name="tr" as="element(tr)"/>
    <!--A param to allow stoping recursion check on rowspan-->
    <xsl:param name="check-rowspan" as="xs:boolean"/>
    <xsl:variable name="hasTd" as="xs:boolean" select="exists($tr/td)"/>
    <xsl:variable name="precedingRow1.isEligible" as="xs:boolean"
      select="if($tr/preceding-sibling::tr[1]) then(xslLib:isTrEligibleToThead($tr/preceding-sibling::tr[1], false())) else(true())"/>
    <xsl:variable name="rowspan.max" select="max(($tr/*/@rowspan, 0))" as="xs:double"/>
    <xsl:choose>
      <!--must not have <td> (means it has only <th> - if html valid)-->
      <xsl:when test="$hasTd">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="not($precedingRow1.isEligible)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$rowspan.max = 0">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="not($check-rowspan)">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <!--we have rowspan here, we have to check if it doesn't intersect with a tr that is not eligible-->
        <xsl:sequence select="every $sibling-tr in ($tr/following-sibling::tr)[position() lt $rowspan.max] satisfies xslLib:isTrEligibleToThead($sibling-tr, false())"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:p>1 arg signature</xd:p>
  <xsl:function name="xslLib:isTrEligibleToThead" as="xs:boolean">
    <xsl:param name="tr" as="element(tr)"/>
    <xsl:sequence select="xslLib:isTrEligibleToThead($tr, true())"/>
  </xsl:function>
  
</xsl:stylesheet>