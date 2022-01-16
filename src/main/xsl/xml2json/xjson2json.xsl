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
      <xd:p>XJSON is the name we gave to the W3C xml JSON representation with schema : dependency:/eu.els.sie.models+ext-models/ext-models/w3c/xjson/schema-for-json.xsd</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--Named output so it does't take precedence when this XSLT is called.
    This XSLT produce a JSON string so the output should be "text" :
    - "json" output would be wrong cause it will escape the json string one more time
    - "xml" would also work with omit-xml-declaration setted to true
  -->
  <xsl:output method="text" name="xslLib:xjson2json"/>
  
  <!--Default serialization option for json-->
  <!--cf. https://www.w3.org/TR/xslt-30/#func-xml-to-json-->
  <xsl:param name="xslLib:xjson2json.options" select="map{'indent':false()}" as="map(*)"/>
  <!--Will break the process when an error is encountered while json conversion, if set to false, the error will only be exposed within the json result-->
  <xsl:param name="xslLib:xjson2json.break-on-error" select="false()" as="xs:boolean"/>
  
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
    <xsl:choose>
      <xsl:when test="fn:*">
        <xsl:call-template name="xslLib:xjson2json.serialize-as-json">
          <xsl:with-param name="json" select="xslLib:xjson2json(fn:*)" as="xs:string"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR] calling / mode "xslLib:xjson2json" with /* not fn:*</xsl:message>
        <xsl:message terminate="yes"><xsl:copy-of select="*"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--Specific template to serialize to JSON with
    Has been made specific because XSPEC would raise the error : XTDE1480: Cannot execute xsl:result-document while evaluating variable
    (xspec creates a variable with the ouput) 
    When using XSPEC : override this template (get rid of the xsl:result-document here)
  -->
  <xsl:template name="xslLib:xjson2json.serialize-as-json">
    <xsl:param name="json" required="yes" as="xs:string"/>
    <!--no @href cause we juste want to use the xsl:output defined for json on the main result-->
    <xsl:result-document format="xslLib:xjson2json">
      <xsl:sequence select="$json"/>
    </xsl:result-document>
  </xsl:template>
  
  <!--1 arg signature-->
  <xsl:function name="xslLib:xjson2json" as="xs:string">
    <xsl:param name="xjson" as="element()"/> <!--fn:map or fn:array-->
    <xsl:sequence select="xslLib:xjson2json($xjson, $xslLib:xjson2json.options)"/>
  </xsl:function>
  
  <xsl:function name="xslLib:xjson2json" as="xs:string">
    <xsl:param name="xjson" as="element()"/><!--fn:map or fn:array-->
    <xsl:param name="options" as="map(*)"/>
    <xsl:try select="xml-to-json($xjson, $options)">
      <xsl:catch>
        <xsl:variable name="error" select="$err:code || ' : ' || $err:description" as="xs:string"/>
        <!--conversion errors are also jsonified-->
        <xsl:variable name="err" as="element()">
          <fn:map><fn:string key="error"><xsl:value-of select="$error"/></fn:string></fn:map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($err, $options)"/>
        <xsl:choose>
          <xsl:when test="$xslLib:xjson2json.break-on-error">
            <xsl:message terminate="true">[ERROR][xslLib:xjson2json] <xsl:value-of select="$error"/></xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>[ERROR][xslLib:xjson2json] <xsl:value-of select="$error"/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:catch>
    </xsl:try>
  </xsl:function>
  
</xsl:stylesheet>
