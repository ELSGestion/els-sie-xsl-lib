<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:functx="http://www.functx.com" 
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT convert XJSON xml representation to text JSON</xd:p>
      <xd:p>It uses XSLT 3.0 xml-to-json($e) function, which need as $e a valid XJSON xml.</xd:p>
      <xd:p>XJSON is the name we gave to the W3C xml JSON representation with schema : ext-models:/ext-models/w3c/xjson/schema-for-json.xsd</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--Use the xml method so the output might be indented with oXygen-->
  <!--<xsl:output method="xml" omit-xml-declaration="yes"/>-->
  <xsl:output method="json"/>
  
  <!--==============================================-->
  <!--INIT-->
  <!--==============================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:xjson2json"/>
  </xsl:template>
  
  <!--==============================================-->
  <!--MAIN-->
  <!--==============================================-->
  
  <xsl:template match="/" mode="xslLib:xjson2json">
    <xsl:sequence select="xslLib:xjson2json(fn:*)"/>
  </xsl:template>
  
  <xsl:function name="xslLib:xjson2json" as="xs:string">
    <xsl:param name="xjson" as="element(fn:map)"/>
    <xsl:try select="xml-to-json($xjson)">
      <xsl:catch>
        <!--conversion erros are also jsonified-->
        <xsl:variable name="err" as="element()">
          <fn:map><fn:string key="error"><xsl:value-of select="$err:code || ' : ' || $err:description"/></fn:string></fn:map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($err)"/>
      </xsl:catch>
    </xsl:try>
  </xsl:function>
  
</xsl:stylesheet>