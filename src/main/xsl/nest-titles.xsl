<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:functx="http://www.functx.com" 
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>When titles elements are flat, this XSLT nest them reccusrively by deep-level</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common.xsl"/>
  
  <!--===================================================-->
  <!--MAIN-->
  <!--===================================================-->

  <!--ELSSIEXDC-18 : don't use a default <xsl:template match="/"> for transformation libraries-->

  <xsl:template match="*[*[xslLib:nest-title.getDeepLevel(.) != 0]]" mode="xslLib:nest-titles.main">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="xslLib:nest-titles"/>
    </xsl:copy>
  </xsl:template>
  
  <!--default copy--> 
  <xsl:template match="node() | @*" mode="xslLib:nest-titles.main">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="xslLib:nest-titles">
    <xsl:param name="current.seq" required="no" select="node()" as="node()*"/> <!--sequence of elements (or nodes) to work on-->
    <xsl:param name="current.deepLevel" required="no" select="(min($current.seq[self::*[xslLib:nest-title.isTitle(.)]]/xslLib:nest-title.getDeepLevel(.)), -1)[1]" as="xs:integer"/>
    <xsl:choose>
      <!--No titles in the sequence-->
      <xsl:when test="$current.deepLevel = -1">
        <xsl:apply-templates select="$current.seq" mode="xslLib:nest-titles.main"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each-group select="$current.seq" group-starting-with="*[xslLib:nest-title.getDeepLevel(.) = $current.deepLevel]">
          <xsl:variable name="cg" select="current-group()" as="node()*"/>
          <xsl:choose>
            <!--No elements in the current-group-->
            <xsl:when test="count($cg[self::*[xslLib:nest-title.isTitle(.)]]) = 0">
              <xsl:apply-templates select="$cg" mode="xslLib:nest-titles.main"/>
            </xsl:when>
            <!--First group might start with 
              - an non element (text, pi, comments) 
              - or might contains title from a higher deep level-->
            <xsl:when test="not($cg[1]/self::*[xslLib:nest-title.isTitle(.)]) or $cg[1]/self::*[xslLib:nest-title.getDeepLevel(.) gt $current.deepLevel]">
              <!--Reccusrion : call back the template incrementing the deep level-->
              <xsl:call-template name="xslLib:nest-titles">
                <xsl:with-param name="current.seq" select="$cg" as="node()*"/>
                <xsl:with-param name="current.deepLevel" select="$current.deepLevel + 1" as="xs:integer"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <!--Nest this Title-->
              <xsl:call-template name="xslLib:nest-titles.nestTitleAndContinue">
                <xsl:with-param name="title" select="$cg[1]" as="element()"/>
                <xsl:with-param name="followings" select="$cg except $cg[1]" as="node()*"/>
                <xsl:with-param name="deepLevel" select="$current.deepLevel" as="xs:integer"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--Do not override this function, it's for ease of use within this XSLT-->  
  <xsl:function name="xslLib:nest-title.isTitle" as="xs:boolean">
    <!--FIXME : override="false" : SXWN9014: The xsl:function/@override attribute is deprecated; use override-extension-function-->
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="xslLib:nest-title.getDeepLevel($e) ne -1"/>
  </xsl:function>
  
  <!--===================================================-->
  <!--INTERFACES-->
  <!--===================================================-->
  <!--to be overrided-->
  
  <xsl:template name="xslLib:nest-titles.nestTitleAndContinue">
    <xsl:param name="title" as="element()"/>
    <xsl:param name="followings" as="node()*"/>
    <xsl:param name="deepLevel" as="xs:integer"/>
    <xsl:message terminate="yes">[FATAL] Please implement an overriding template for "xslLib:nest-titles.nestTitleAndContinue" in your own XSLT</xsl:message>
    <nest level="{$deepLevel}">
      <xsl:sequence select="$title"/>
      <xsl:call-template name="xslLib:nest-titles">
        <xsl:with-param name="current.seq" select="$followings"/>
      </xsl:call-template>
    </nest>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Get the deep level of title element, so it can be used for nesting titles</xd:p>
    </xd:desc>
    <xd:param name="e">Any XML element</xd:param>
    <xd:return>An positive (or null) integer reprenting the element deepness - 
      if the element is not a title, it <xd:b>must</xd:b> return -1</xd:return>
  </xd:doc>
  <xsl:function name="xslLib:nest-title.getDeepLevel" as="xs:integer">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="-1"/>
    <xsl:message terminate="yes">[FATAL] Please implement an overriding function for xslLib:nest-title.getDeepLevel() in your own XSLT</xsl:message>
  </xsl:function>
  
</xsl:stylesheet>