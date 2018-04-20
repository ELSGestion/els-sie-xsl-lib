<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  version="3.0">
  
  <xsl:import href="../../../main/xsl/els-log-extract.xsl"/>
  
  <!--Override this rule to avoid xsl:result-document which cause the following error with XSPEC:
  XTDE1480: Cannot execute xsl:result-document while evaluating variable-->
  <xsl:template match="/">
    <xsl:apply-templates mode="els:extractLogs">
      <xsl:with-param name="expectedLogLevels" select="('info', 'error')"/>  
    </xsl:apply-templates>    
  </xsl:template>
  
</xsl:stylesheet>