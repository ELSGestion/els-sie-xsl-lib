<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  version="3.0">
  
  <xsl:import href="../../../main/xsl/xml2json/xjson2json.xsl"/>
  
  <!--Override this rule to avoid xsl:result-document which cause the following error with XSPEC:
  XTDE1480: Cannot execute xsl:result-document while evaluating variable-->
  <xsl:template match="/" mode="xslLib:xjson2json">
    <!--no @href cause we juste want to use the xsl:output defined for json on the main result-->
    <!--<xsl:result-document format="xslLib:xjson2json">-->
      <xsl:sequence select="xslLib:xjson2json(fn:*)"/>
    <!--</xsl:result-document>-->
  </xsl:template>
  
</xsl:stylesheet>