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
      <xd:p>This XSLT include all librairies at once so it's convenient to use them all
        But you can also import each librairy separaltely and deal yoursef with dependencies between them</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:import href="functx.xsl"/>
  <xsl:import href="els-common_constants.xsl"/>
  <xsl:import href="els-common_dates.no-inclusions.xsl"/>
  <xsl:import href="els-common_strings.no-inclusions.xsl"/>
  <xsl:import href="els-common_xml.no-inclusions.xsl"/>
  <xsl:import href="els-common_files.no-inclusions.xsl"/>
  <xsl:import href="els-common_convert-cast.xsl"/>
  <xsl:import href="els-common_http.xsl"/>
  <xsl:import href="els-common_videos.no-inclusions.xsl"/>
  <xsl:import href="els-common_social-network.no-inclusions.xsl"/>
  <xsl:import href="els-common_audio.no-inclusions.xsl"/>
  <xsl:import href="els-common_infographic.no-inclusions.xsl"/>
  <xsl:import href="els-common_url-classifier.no-inclusions.xsl"/>
  <xsl:import href="els-common_compareXML.no-inclusions.xsl"/>
  
</xsl:stylesheet>