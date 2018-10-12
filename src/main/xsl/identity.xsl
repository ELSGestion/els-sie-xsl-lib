<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Generic identity XSLT : the XML output is the same as th XML input</xd:p>
      <xd:p>Usefull for programms (Gaulois Pipe, conf files) that need to refer to an identity XSLT</xd:p> 
      <xd:p>Not worth using it if you already have an XSLT file where you can simply add an identity template or xslt 3.0 shallow-copy)</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:mode name="xslLib:identity" on-no-match="shallow-copy"/>
  
  <!--=======================================================-->
  <!--INIT-->
  <!--=======================================================-->

  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:identity"/>
  </xsl:template>
  
</xsl:stylesheet>