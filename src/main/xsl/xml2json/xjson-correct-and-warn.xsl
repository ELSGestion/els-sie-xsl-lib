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
      <xd:p>This XSLT takes XJSON file as input and correct and warns some specifics errors that would prevent xjson-to-json conversion</xd:p>
      <xd:p>Normaly XJSON should be valid but in some case one want to send the JSON version and say "I had problem with thoses cases"</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--==============================================-->
  <!--INIT-->
  <!--==============================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:xjson-correct-and-warn"/>
  </xsl:template>
  
  <!--==============================================-->
  <!--MAIN-->
  <!--==============================================-->
  
  <!-- Duplicate key value
    cf. https://www.w3.org/2013/XSL/json
    <xs:unique name="unique-key">
      <xs:selector xpath="*"/>
      <xs:field xpath="@key"/>
      <xs:field xpath="@escaped-key"/>
    </xs:unique>-->
  <xsl:template match="fn:*[@key]" mode="xslLib:xjson-correct-and-warn">
    <xsl:variable name="key" select="@key" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::fn:*[@key = $key])">
        <xsl:next-match/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="msg" as="xs:string*">Duplicate key value "<xsl:value-of select="$key"/>" has been deleted</xsl:variable>
        <xsl:variable name="msg" select="string-join($msg, '')"/>
        <xsl:message select="'[ERROR] ' || $msg"/>
        <xsl:processing-instruction name="error"><xsl:value-of select="$msg"/></xsl:processing-instruction>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="xslLib:xjson-correct-and-warn">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>