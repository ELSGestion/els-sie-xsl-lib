<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
      You may also you the standalone version of this XSLT (without "no-inclusions" extension)
    </xd:p>
    <xd:desc>
      <xd:p>Nest html titles (h1, h2, ..., h6) into a div class="heading"</xd:p>
    </xd:desc>
  </xd:doc>

  <!--===================================================-->  
  <!--INIT-->
  <!--===================================================-->  
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:nest-html-titles.main"/>
  </xsl:template>
  
  <!--===================================================-->
  <!--MAIN-->
  <!--===================================================-->
  
  <xsl:template match="/" mode="xslLib:nest-html-titles.main">
    <xsl:apply-templates select="." mode="xslLib:nest-titles.main"/>
  </xsl:template>
  
  <!--===================================================-->
  <!--OVERRIDE-->
  <!--===================================================-->
  
  <xsl:template name="xslLib:nest-titles.nestTitleAndContinue">
    <xsl:param name="title" as="element()"/>
    <xsl:param name="followings" as="node()*"/>
    <xsl:param name="deepLevel" as="xs:integer"/>
    <div class="heading-{$deepLevel}">
      <xsl:sequence select="$title"/>
      <xsl:call-template name="xslLib:nest-titles">
        <xsl:with-param name="current.seq" select="$followings"/>
      </xsl:call-template>
    </div>
  </xsl:template>
  
  <xsl:function name="xslLib:nest-title.getDeepLevel" as="xs:integer">
    <xsl:param name="e" as="element()"/>
    <xsl:variable name="deepLlevel" as="xs:string">
      <xsl:choose>
        <xsl:when test="matches(local-name($e), '^h\d+$')">
          <xsl:sequence select="substring-after(local-name($e), 'h')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'-1'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$deepLlevel cast as xs:integer"/>
  </xsl:function>
  
</xsl:stylesheet>