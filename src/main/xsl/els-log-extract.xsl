<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is standalone, use the "no-inclusions" version if you want to deal with multiple inclusion in your project
        (and thus avoid "Stylesheet module xxx.xsl is included or imported more than once" error)</xd:p>
      <xd:p>Extraction logs from XML file which contains &lt;els:log&gt;</xd:p>
      <xd:p>See more documentation in the "no-inclusions" version</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:include href="els-log-extract.no-inclusions.xsl"/>
  
  <!--Required inclusions for standalone usage-->
  <xsl:import href="functx.xsl"/>
 
</xsl:stylesheet>