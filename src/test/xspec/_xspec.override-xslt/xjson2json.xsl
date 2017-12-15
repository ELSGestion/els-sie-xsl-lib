<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  version="3.0">
  
  <xsl:import href="../../../main/xsl/xml2json/xjson2json.xsl"/>
  
  <!--Override this rule to avoid xsl:result-document which cause the following error with XSPEC:
  XTDE1480: Cannot execute xsl:result-document while evaluating variable-->
  <xsl:template name="xslLib:xjson2json.serialize-as-json">
    <xsl:param name="json" required="yes" as="xs:string"/>
    <!--<xsl:result-document format="xslLib:xjson2json">-->
      <xsl:sequence select="$json"/>
    <!--</xsl:result-document>-->
  </xsl:template>
  
</xsl:stylesheet>