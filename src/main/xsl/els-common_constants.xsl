<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Variable that helps checking dependency to ensure this XSLT is loaded (especially usefull to test XSLT mode avaiable-->
  <xsl:variable name="xslLib:els-common_constants.available" select="true()" static="true"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "CONSTANTS"</xd:p>
    </xd:desc>
  </xd:doc>

  <!--===================================================  -->
  <!--                OUTPUT                              -->
  <!--===================================================  -->
  
  <xsl:output name="els:xml" method="xml"/>
  <xsl:output name="els:xml.indent" method="xml" indent="yes"/>
  <xsl:output name="els:text" method="text"/>
  
  <!--===================================================  -->
  <!--                COMMON VAR      -->
  <!--===================================================  -->
  
  <xd:doc>
    <xd:desc>
      <xd:p>An dummy document-node, might be usefull as 3rg arg of key which may not be empty for instance : 
        key('my-key', 'key-value', ($possible-non-existant-doc, $els:dummy-document-node)[1])
      </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="els:dummy-document-node" as="xs:string">
    <xsl:document>
      <dummyRoot/>
    </xsl:document>
  </xsl:variable>
  
  
  <xd:doc>
    <xd:desc>
      <xd:p>double/simple quot variable, might be usefull within a concat for example</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="els:dquot" as="xs:string">
    <xsl:text>"</xsl:text>
  </xsl:variable>
  <xsl:variable name="els:quot" as="xs:string">
    <xsl:text>'</xsl:text>
  </xsl:variable>

  <xd:p>Variable "regAnySpace" : matches any spaces (non-break space, thin space, etc.)</xd:p>
  <xsl:variable name="els:regAnySpace" select="'\p{Z}'" as="xs:string"/>
  
  <xd:p>Variable "regAnyDash" : matches any dash</xd:p>
  <xsl:variable name="els:regAnyDash" select="'(\p{Pd}|&#x2D;|&#xAD;|&#x2043;|&#x2212;)'" as="xs:string"/>
  
  <xd:p>Variable "regAnyPonctuation" : matches any ponctuation (point, coma, semicolon, etc.)</xd:p>
  <xd:p>(cf. http://www.regular-expressions.info/unicode.html)</xd:p>
  <xsl:variable name="els:regAnyPonctuation" select="'\p{P}'" as="xs:string"/>  
  
  <xd:p>Variable "regAnyNumber" : match any number</xd:p>
  <xd:p>(cf. http://www.regular-expressions.info/unicode.html)</xd:p>
  <xsl:variable name="els:regAnyNumber" select="'\p{N}'" as="xs:string"/>

  <xd:p>Variable "regAnyLetter" : match any letter</xd:p>
  <xd:p>(cf. http://www.regular-expressions.info/unicode.html)</xd:p>
  <xsl:variable name="els:regAnyLetter" select="'\p{L}'" as="xs:string"/>
  
  <xd:p>Variable "end of word" (equivalent to "\b" in regex)</xd:p>
  <xsl:variable name="els:regWordBoundery" select="concat($els:regAnySpace, '|', $els:regAnyPonctuation)" as="xs:string"/>
  
  <xd:p>Variable "regMailAddress" : matches mail address string</xd:p>
  <xsl:variable name="els:regMailAddress" select="'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z-]+$'" as="xs:string"/>
  
  <xd:p>Variable "regAbsUri" : matches absolute uri</xd:p>
  <xsl:variable name="els:regAbsUri" as="xs:string">
    <!--<xsl:text>/^([a-z0-9+.-]+):(?://(?:((?:[a-z0-9-._~!$&amp;'()*+,;=:]|%[0-9A-F]{2})*)@)?((?:[a-z0-9-._~!$&amp;'()*+,;=]|%[0-9A-F]{2})*)(?::(\d*))?(/(?:[a-z0-9-._~!$&amp;'()*+,;=:@/]|%[0-9A-F]{2})*)?|(/?(?:[a-z0-9-._~!$&amp;'()*+,;=:@]|%[0-9A-F]{2})+(?:[a-z0-9-._~!$&amp;'()*+,;=:@/]|%[0-9A-F]{2})*)?)(?:\?((?:[a-z0-9-._~!$&amp;'()*+,;=:/?@]|%[0-9A-F]{2})*))?(?:#((?:[a-z0-9-._~!$&amp;'()*+,;=:/?@]|%[0-9A-F]{2})*))?$</xsl:text>-->
    <!--<xsl:text>^([a-z0-9+.-]+)://?/?.*$</xsl:text>-->
    <xsl:text>^([a-zA-Z0-9+.-]+):/.*$</xsl:text>
  </xsl:variable>
  
  <xd:doc>
    <xd:desc>TYPOGRAPHIC SPACES</xd:desc>
    <xd:p>Every spaces from the largest to the thinest : &amp;#x2000; (same width as letter "M") => &amp;#x200b; (zero width space - breakable)</xd:p>
    <xd:p>Tip : Use the software "SC UNIPAD" to see and convert spaces. cf. http://theme.unblog.fr/2007/05/18/ponctuation/</xd:p>
  </xd:doc>
  <xsl:variable name="els:EN_QUAD" select="'&#x2000;'" as="xs:string"/><!--(1/8 cadratin)= " "-->
  <xsl:variable name="els:NARROW_NO_BREAK_SPACE" select="'&#x202f;'" as="xs:string"/><!--= " "-->
  <xsl:variable name="els:NO_BREAK_SPACE" select="'&#x00a0;'" as="xs:string"/><!-- = " "-->
  <xsl:variable name="els:ZERO_WIDTH_SPACE" select="'&#x200b;'" as="xs:string"/><!-- = "​​"-->
  <xsl:variable name="els:ZERO_WIDTH_NO_BREAK_SPACE" select="'&#xfeff;'" as="xs:string"/><!--(non matché par '\p{Z}') = "﻿"-->
  <xsl:variable name="els:HAIR_SPACE" select="'&#x200A;'" as="xs:string"/><!--("espace ultra fine sécable") = " "-->
  <xsl:variable name="els:PONCTUATION_SPACE" select="'&#x2008;'" as="xs:string"/><!--(1/3 de cadratin ?) = " "-->
  <xsl:variable name="els:THIN_SPACE" select="'&#x2009;'" as="xs:string"/><!--(espaces fine ou quart de cadratin?) = " "-->
  <xsl:variable name="els:EN_SPACE" select="'&#x2002;'" as="xs:string"/><!-- https://www.cs.sfu.ca/~ggbaker/reference/characters/#space -->
  
</xsl:stylesheet>
