<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Convert any XML to HTML div/span based on text occurence</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--==================================================-->
  <!--MAIN-->
  <!--==================================================-->

  <!--ELSSIEXDC-18 : don't use a default <xsl:template match="/"> for transformation libraries-->
  
  <xsl:template match="*" mode="els:xml2simpleHtml">
    <xsl:variable name="element.name" as="xs:string">
      <xsl:choose>
        <xsl:when test="preceding-sibling::text()[normalize-space(.)] or following-sibling::text()[normalize-space(.)]">
          <xsl:text>span</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>div</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$element.name}">
      <xsl:attribute name="class" select="local-name()"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@*" mode="els:xml2simpleHtml">
    <xsl:attribute name="{concat('data-xml-', local-name(.))}" select="."/>
  </xsl:template>
  
</xsl:stylesheet>