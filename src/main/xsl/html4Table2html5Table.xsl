<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all" 
  version="3.0">
  
  <!--Required modules (need to be included with this XSLT)-->
  <!--<xsl:import href="css-parser.xsl"/>-->
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT convert any html 4 table to (x)html(1, 2 or 5)</xd:p>
      <xd:p>HTML4 defines a set of attributes like @border, @width, @align etc. on table elements. 
        This attributes are deprecated on next HTML version. This XSLT will then convert those 
        attributes to @style css properties when it's possible or delete it.</xd:p>
      <xd:p></xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--Necessary for xspec (it seems when default namespace is html the xslt processor serialize as html automaticaly)-->
  <xsl:output method="xml" indent="no"/>
  
  <!-- cf. https://www.w3schools.com/TAGs/tag_td.asp
           or https://developer.mozilla.org/en-US/docs/Web/HTML/Element/table -->
  <xsl:variable name="xslLib:html5.unsupported-table-attributes" 
    select="('align', 'valign', 'char', 'charoff', 'bgcolor', 'border', 'cellpadding', 'cellspacing', 'frame', 'rules', 'summary', 
    'width', 'abbr', 'axis', 'height', 'nowrap', 'scope')"
    as="xs:string*"/>
  
  <!--==========================================================-->
  <!-- INIT -->
  <!--==========================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:html4table2html5table"/>
  </xsl:template>
  
  <!--==========================================================-->
  <!-- MAIN -->
  <!--==========================================================-->
  
  <xsl:template 
    match="table | table/colgroup | table/colgroup/col | 
    table/tbody | table/thead | table/tfoot | 
    table/*/tr | table/*/tr/td | table/*/tr/th" 
    mode="xslLib:html4table2html5table">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* except (@style, @*[name() = $xslLib:html5.unsupported-table-attributes])" mode="#current"/>
      <xsl:variable name="css" select="css:parse-inline(@style)" as="element(css:css)?"/>
      <!--@border="1" on table element defines a border for each cell-->
      <xsl:variable name="border" select=" if(ancestor-or-self::table[1]/@border = '1') then(true()) else(false()) " as="xs:boolean"/>
      <xsl:variable name="cellpadding" select=" if(ancestor-or-self::table[1]/@cellpadding) then(replace(ancestor-or-self::table[1]/@cellpadding, 'px', '') cast as xs:double) else(0)" as="xs:double"/>
      <xsl:variable name="style" as="xs:string*">
        <xsl:if test="self::table and $border and not(css:showAllBorders($css))">
          <xsl:text>border:1px solid</xsl:text>
        </xsl:if>
        <xsl:if test="local-name(.) = ('td', 'th') and $border and not(css:showAllBorders($css))">
          <xsl:variable name="borders-to-set" as="xs:string*">
            <!--Here we have to set every unset borders except those from the table itself-->
            <xsl:if test="not(css:showBorderTop($css))"> <!--and (parent::tr/preceding-sibling::tr or (ancestor::table/thead and ancestor::tbody))-->
                <xsl:text>top</xsl:text>
            </xsl:if>
            <xsl:if test="not(css:showBorderRight($css))"> <!--and following-sibling::*[local-name(.) = ('td', 'th')]-->
              <xsl:text>right</xsl:text>
            </xsl:if>
            <xsl:if test="not(css:showBorderBottom($css))"><!--and (parent::tr/following-sibling::tr or (ancestor::table/tbody and ancestor::thead))-->
              <xsl:text>bottom</xsl:text>
            </xsl:if>
            <xsl:if test="not(css:showBorderLeft($css))">  <!--and preceding-sibling::*[local-name(.) = ('td', 'th')]-->
              <xsl:text>left</xsl:text>
            </xsl:if>
          </xsl:variable>
          <!--TODO : process inheritage of border color from the table/@style
          it seems the browser default border color is grey when borders are constructed from @border attribute-->
          <xsl:choose>
            <xsl:when test="deep-equal($borders-to-set, ('top', 'right', 'bottom', 'left'))">
              <xsl:text>border:1px solid</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$borders-to-set = 'top'">
                <xsl:text>border-top:1px solid</xsl:text>
              </xsl:if>
              <xsl:if test="$borders-to-set = 'right'">
                <xsl:text>border-right:1px solid</xsl:text>
              </xsl:if>
              <xsl:if test="$borders-to-set = 'bottom'">
                <xsl:text>border-bottom:1px solid</xsl:text>
              </xsl:if>
              <xsl:if test="$borders-to-set = 'left'">
                <xsl:text>border-left:1px solid</xsl:text>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="local-name(.) = ('td', 'th') and $cellpadding != 0 and not(css:getProperty($css, 'padding'))">
          <xsl:variable name="paddings-to-set" as="xs:string*">
            <!--Here we have to set every unset padding-->
            <xsl:if test="not(css:getProperty($css, 'padding-top'))">
              <xsl:text>top</xsl:text>
            </xsl:if>
            <xsl:if test="not(css:getProperty($css, 'padding-right'))">
              <xsl:text>right</xsl:text>
            </xsl:if>
            <xsl:if test="not(css:getProperty($css, 'padding-bottom'))">
              <xsl:text>bottom</xsl:text>
            </xsl:if>
            <xsl:if test="not(css:getProperty($css, 'padding-left'))">
              <xsl:text>left</xsl:text>
            </xsl:if>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="deep-equal($paddings-to-set, ('top', 'right', 'bottom', 'left'))">
              <xsl:value-of select="concat('padding:', $cellpadding, 'px')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$paddings-to-set = 'top'">
                <xsl:value-of select="concat('padding-top:', $cellpadding, 'px')"/>
              </xsl:if>
              <xsl:if test="$paddings-to-set = 'right'">
                <xsl:value-of select="concat('padding-right:', $cellpadding, 'px')"/>
              </xsl:if>
              <xsl:if test="$paddings-to-set = 'bottom'">
                <xsl:value-of select="concat('padding-bottom:', $cellpadding, 'px')"/>
              </xsl:if>
              <xsl:if test="$paddings-to-set = 'left'">
                <xsl:value-of select="concat('padding-left:', $cellpadding, 'px')"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="@cellspacing and not(css:getProperty($css, 'border-spacing'))">
          <xsl:value-of select="concat('border-spacing:', @cellspacing)"/>
        </xsl:if>
        <xsl:if test="@width and not(css:getProperty($css, 'width'))">
          <xsl:value-of select="concat('width:', if(@width castable as xs:double) then(concat(@width, 'px')) else(@width))"/>
        </xsl:if>
        <xsl:if test="@height and not(css:getProperty($css, 'height'))">
          <xsl:value-of select="concat('height:', @height)"/>
        </xsl:if>
        <xsl:if test="self::table and @align='center' (: ('center', 'middle', 'absmiddle', 'abscenter') :) 
          and not(css:getProperty($css, 'margin-left')) and not(css:getProperty($css, 'margin-right'))">
          <xsl:text>margin-left:auto</xsl:text>
          <xsl:text>margin-right:auto</xsl:text>
        </xsl:if>
        <xsl:if test="self::table and @align='right' 
          and not(css:getProperty($css, 'margin-left')) and not(css:getProperty($css, 'margin-right'))">
          <xsl:text>margin-left:auto</xsl:text>
          <xsl:text>margin-right:0</xsl:text>
        </xsl:if>
        <xsl:if test="not(self::table) and @align and not(css:getProperty($css, 'text-align'))">
          <xsl:value-of select="concat('text-align:', @align)"/>
        </xsl:if>
        <xsl:if test="@valign and not(css:getProperty($css, 'vertical-align'))">
          <xsl:value-of select="concat('vertical-align:', @valign)"/>
        </xsl:if>
        <xsl:if test="@bgcolor and not(css:getProperty($css, 'background-color'))">
          <xsl:value-of select="concat('background-color:', @bgcolor)"/>
        </xsl:if>
        <xsl:if test="normalize-space(@style) != ''">
          <xsl:value-of select="@style"/>
        </xsl:if>
      </xsl:variable>
      <xsl:if test="count($style) != 0">
        <xsl:attribute name="style" select="string-join($style, '; ')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--==========================================================-->
  <!-- COMMON -->
  <!--==========================================================-->
  
  <!--Copy template-->
  <xsl:template match="node() | @*" mode="xslLib:html4table2html5table" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>