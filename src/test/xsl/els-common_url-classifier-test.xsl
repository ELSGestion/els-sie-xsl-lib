<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>XSLT to test function els:classify-url()</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="../../main/xsl/els-common_url-classifier.xsl"/>
  
  <xsl:template match="*[@href]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="is-lefebvre-dalloz" select="els:url-is-lefebvre-dalloz(@href)"/>
      <xsl:attribute name="is-an-publishing-document" select="els:url-is-a-publishing-document(@href)"/>
      <xsl:attribute name="needs-login" select="els:url-access-needs-login(@href)"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!--Copy template-->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*"/>
    </xsl:copy>
  </xsl:template>
 
</xsl:stylesheet>