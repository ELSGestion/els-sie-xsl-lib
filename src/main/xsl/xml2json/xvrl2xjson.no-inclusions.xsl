<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:xvrl="http://www.lefebvre-sarrut.eu/ns/els/xvrl"
  xmlns="http://www.lefebvre-sarrut.eu/ns/els/xvrl"
  xpath-default-namespace="http://www.lefebvre-sarrut.eu/ns/els/xvrl"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Static compilation check for all inclusions to be available (avoid xslt mode not load)-->
  <xsl:variable name="xslLib:xvrl2xjson.no-inclusions.check-available-inclusions">
    <xsl:sequence select="$xslLib:anyXML2json.available"/>
    <xsl:sequence select="$xslLib:xjson2json.available"/>
  </xsl:variable>
  
  <xd:doc scope="stylesheet">
    <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
      You may also you the standalone version of this XSLT (without "no-inclusions" extension)
    </xd:p>
    <xd:desc>
      <xd:p>This XSLT convert XVRL to an JSON xml representation (XJSON)</xd:p>
      <xd:p>XVRL is a XML Validation Report Language : els-models:/els-models/xvrl/xvrl.rng</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--================================-->
  <!--INIT-->
  <!--================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:xvrl2xjson"/>
  </xsl:template>
  
  <!--================================-->
  <!--MAIN-->
  <!--================================-->
  
  <xsl:template match="/" mode="xslLib:xvrl2xjson">
    <xsl:apply-templates select="." mode="xslLib:anyXML2xjson"/>
  </xsl:template>
  
  <!--================================-->
  <!--OVERRIDE MODE xslLib:anyXML2xjson-->
  <!--================================-->
  
  <xsl:template match="xvrl:validation-reports" mode="xslLib:anyXML2xjson">
    <fn:map>
      <xsl:call-template name="xslLib:add-schema-for-json.xsd.att"/>
      <xsl:apply-templates select="xvrl:metadata" mode="#current"/>
      <fn:array key="validation-reports">
        <xsl:apply-templates select="xvrl:validation-report" mode="#current">
          <xsl:with-param name="key" select="false()" as="xs:boolean"/>
        </xsl:apply-templates>
      </fn:array>
    </fn:map>
  </xsl:template>
  
  <xsl:template match="xvrl:validation-report" mode="xslLib:anyXML2xjson">
    <fn:map>
      <xsl:apply-templates select="xvrl:metadata" mode="#current"/>
      <fn:array key="reports">
        <xsl:apply-templates select="xvrl:report" mode="#current">
          <xsl:with-param name="key" select="false()" as="xs:boolean"/>
        </xsl:apply-templates>
      </fn:array>
    </fn:map>
  </xsl:template>
  
  <xsl:template match="xvrl:report" mode="xslLib:anyXML2xjson">
    <fn:map>
      <xsl:apply-templates select="@*" mode="#current"/>
      <fn:array key="message">
        <xsl:apply-templates select="xvrl:message" mode="#current">
          <xsl:with-param name="key" select="false()" as="xs:boolean"/>
        </xsl:apply-templates>
      </fn:array>
    </fn:map>
  </xsl:template>
  
  <xsl:template match="xvrl:result/@valid" mode="xslLib:anyXML2xjson">
    <xsl:next-match>
      <xsl:with-param name="as" select="'boolean'" as="xs:string"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="xvrl:*/@*[name(.) = ('line', 'column', 'errors', 'warnings')]" mode="xslLib:anyXML2xjson">
    <xsl:next-match>
      <xsl:with-param name="as" select="'number'" as="xs:string"/>
    </xsl:next-match>
  </xsl:template>
  
</xsl:stylesheet>