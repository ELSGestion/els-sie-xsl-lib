<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is standalone, use the "no-inclusions" version if you want to deal with multiple inclusion in your project
        (and thus avoid "Stylesheet module xxx.xsl is included or imported more than once" error)</xd:p>
      <xd:p>ELS-COMMON lib : module "CompareXML"</xd:p>
      <xd:p>See more documentation in the "no-inclusions" version</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="els-common_compareXML.no-inclusions.xsl"/>
  
  <!--Required inclusions for standalone usage-->
  <xsl:import href="els-common_xml.no-inclusions.xsl"/>
  <xsl:import href="els-common_constants.xsl"/>
  <xsl:import href="els-common_strings.no-inclusions.xsl"/>
  
</xsl:stylesheet>