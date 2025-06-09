<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>html4Table2html5Table.xsl + required modules</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="../../../main/xsl/html4Table2html5Table.xsl"/>
  
  <!--Required modules-->
  <xsl:import href="../../../main/xsl/css-parser.xsl"/>
  
</xsl:stylesheet>