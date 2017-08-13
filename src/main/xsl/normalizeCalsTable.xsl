<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xpath-default-namespace="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all" 
  >
  
  <!--<xsl:import href="els-common.xsl"/>-->
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Normalize Cals Table</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--==============================================================================================================================-->
  <!-- INIT -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:normalizeCalsTable"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- MAIN -->
  <!--==============================================================================================================================-->
  
  <!--copy template-->
  <xsl:template match="* | @* | node()" mode="xslLib:normalizeCalsTable">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
