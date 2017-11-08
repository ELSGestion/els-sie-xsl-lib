<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all" 
  >
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Remove xml:base attribute on the top level element of the document</xd:p>
      <xd:p>This XSLT in the reverse of setXmlBase.xsl. It is usefull for XSPEC testing of multi-step XSLT
        where the xml:base is usefull during processing but should be delete at the end so xspec does't complain.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--==============================================================================================================================-->
  <!-- INIT -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:removeXmlBase"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- MAIN -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/*" mode="xslLib:removeXmlBase">
    <xsl:copy>
      <xsl:apply-templates select="@* except @xml:base | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--copy template-->
  <xsl:template match="* | @* | node()" mode="xslLib:removeXmlBase">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>