<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all" 
  >
  
  <!--Variable that helps checking dependency to ensure this XSLT is loaded (especially usefull to test XSLT mode avaiable-->
  <xsl:variable name="xslLib:setXmlBase.available" select="true()" static="true"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Set xml:base attribute on the top level element of the document</xd:p>
      <xd:p>This is usefull when initiating a multi-step xslt (with variables containing each step), calling base-uri() in any step will then work fine</xd:p>
      <xd:p>See : https://www.oxygenxml.com/archives/xsl-list/200601/msg00687.html</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:param name="xslLib:baseUri" select="base-uri(/)" as="xs:anyURI"/>
  
  <!--==============================================================================================================================-->
  <!-- INIT -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:setXmlBase"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- MAIN -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/*" mode="xslLib:setXmlBase">
    <xsl:copy>
      <xsl:attribute name="xml:base" select="$xslLib:baseUri"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--copy template-->
  <xsl:template match="* | @* | node()" mode="xslLib:setXmlBase">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>