<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is standalone, use the "no-inclusions" version if you want to deal with multiple inclusion in your project
        (and thus avoid "Stylesheet module xxx.xsl is included or imported more than once" error)</xd:p>
      <xd:p>MSV is a programm that can convert XSD to RNG model, this XSLT adapt the result of this conversion to make it correct</xd:p>
      <xd:p>See more documentation in the "no-inclusions" version</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="fixMsvErrorWhenConvertingXSD2RNG.no-inclusions.xsl"/>
  
  <!--Required inclusions for standalone usage-->
  <xsl:import href="rng-common.no-inclusions.xsl"/>
  <xsl:import href="els-common_constants.xsl"/>
  <xsl:import href="els-common_xml.no-inclusions.xsl"/>
  <xsl:import href="els-common_strings.no-inclusions.xsl"/>
  <xsl:import href="els-common_files.no-inclusions.xsl"/>
  <xsl:import href="functx.xsl"/>
  
</xsl:stylesheet>