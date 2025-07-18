<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Variable that helps checking dependency to ensure this XSLT is loaded (especially usefull to test XSLT mode avaiable-->
  <xsl:variable name="xslLib:anyXML2json.available" select="true()" static="true"/>
  
  <!--Static compilation check for all inclusions to be available (avoid xslt mode not load)-->
  <xsl:variable name="xslLib:anyXML2json.check-available-inclusions">
    <xsl:sequence select="$xslLib:xjson2json.available"/>
  </xsl:variable>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
        You may also you the standalone version of this XSLT (without "no-inclusions" extension)
      </xd:p>
      <xd:p>This XSLT convert any XML structure to JSON</xd:p>
      <xd:p>It uses XSLT 3.0 xml-to-json($e) function, which need as $e a valid XJSON xml.</xd:p>
      <xd:p>As a first step this XSLT convert any XML to it XJSON representation, and then apply the xml-to-json() fonction</xd:p>
      <xd:p>CAUTION : XML2JSON is not always obvious ! You would be very lucky to be able to use this XSLT as is and getting the JSON you expected.</xd:p>
      <xd:p>XJSON VALIDITY IS NOT GUARANTED !</xd:p>
      <xd:p>Please override any templates in mode="xslLib:anyXML2xjson" of this XSLT so you get a valid XJSON representation</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--Default serialization option for json-->
  <xsl:param name="xslLib:anyXML2json.options" select="map{'indent':false()}" as="map(*)"/>
  
  <!--==============================================-->
  <!--INIT-->
  <!--==============================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:anyXML2json"/>
  </xsl:template>
  
  <!--==============================================-->
  <!--MAIN-->
  <!--==============================================-->
  
  <xsl:template match="/" mode="xslLib:anyXML2json">
    <xsl:variable name="root" select="*[1]" as="element()"/>
    <xsl:call-template name="xslLib:xjson2json.serialize-as-json">
      <xsl:with-param name="json" select="xslLib:anyXML2json($root)" as="xs:string"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:function name="xslLib:anyXML2json" as="xs:string">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="xslLib:anyXML2json($e, $xslLib:anyXML2json.options)"/>
  </xsl:function>
  
  <xsl:function name="xslLib:anyXML2json" as="xs:string">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="options" as="map(*)"/> <!--json options-->
    <xsl:variable name="xjson" as="element(fn:map)">
      <xsl:apply-templates select="$e" mode="xslLib:anyXML2xjson"/>
    </xsl:variable>
    <xsl:sequence select="xslLib:xjson2json($xjson, $options)"/>
  </xsl:function>
  
  <!--=============================-->
  <!--MODE anyXML2xjson-->
  <!--=============================-->
  
  <xsl:template name="xslLib:add-schema-for-json.xsd.att">
    <xsl:attribute name="xsi:schemaLocation"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      select="'http://www.w3.org/2005/xpath-functions dependency:/eu.els.sie.models+ext-models/ext-models/w3c/xjson/schema-for-json.xsd'"/>
  </xsl:template>
  
  <xsl:template match="/*" mode="xslLib:anyXML2xjson">
    <fn:map>
      <xsl:call-template name="xslLib:add-schema-for-json.xsd.att"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </fn:map>
  </xsl:template>
  
  <!--Override me : if the XML allow multiple elements with the same name here, one should make wrap them in a fn:map here-->
  <xsl:template match="*" mode="xslLib:anyXML2xjson">
    <xsl:param name="key" select="true()" as="xs:boolean"/>
    <fn:map>
      <xsl:if test="$key">
        <xsl:attribute name="key" select="name(.)"/>
      </xsl:if>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </fn:map>
  </xsl:template>
  
  <xsl:template match="@*" mode="xslLib:anyXML2xjson">
    <xsl:param name="as" select="'string'" as="xs:string"/>
    <xsl:element name="{concat('fn:', $as)}">
      <xsl:attribute name="key" select="name(.)"/>
      <xsl:value-of select="."/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space(.) != '']" mode="xslLib:anyXML2xjson">
    <fn:string 
      key="text{if(preceding-sibling::text()[normalize-space(.)!='']) 
      then(count(preceding-sibling::text()[normalize-space(.)!=''])) 
      else('')}">
      <xsl:value-of select="."/>
    </fn:string>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space(.) = '']" mode="xslLib:anyXML2xjson"/>
  
</xsl:stylesheet>
  
