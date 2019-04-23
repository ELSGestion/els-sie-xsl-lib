<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Generic XSL functions/templates library used at ELS</xd:p>
    </xd:desc>
  </xd:doc>

  <!--<xsl:import href="functx.xsl"/> already imported within modules-->
  <xsl:import href="els-common_constants.xsl"/>
  <xsl:import href="els-common_dates.xsl"/>
  <xsl:import href="els-common_strings.xsl"/>
  <xsl:import href="els-common_xml.xsl"/>
  <xsl:import href="els-common_files.xsl"/>
  <xsl:import href="els-common_convert-cast.xsl"/>
  <xsl:import href="els-common_http.xsl"/>

</xsl:stylesheet>