<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  version="3.0">
  
  <xsl:import href="../../../main/xsl/xml2json/anyXML2json.xsl"/>
  
  <!--Override this rule to avoid xsl:result-document which cause the following error with XSPEC:
  XTDE1480: Cannot execute xsl:result-document while evaluating variable-->
  <xsl:template match="/" mode="xslLib:anyXML2json">
    <xsl:variable name="root" select="*[1]" as="element()"/>
    <!--<xsl:result-document format="xslLib:xjson2json">-->
      <xsl:sequence select="xslLib:anyXML2json($root)"/>
    <!--</xsl:result-document>-->
  </xsl:template>
 
</xsl:stylesheet>
  