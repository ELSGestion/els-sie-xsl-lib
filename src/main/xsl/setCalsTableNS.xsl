<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns:calstable="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xpath-default-namespace="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Set CALS namespace on CALS table elements</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:variable as="xs:string*" name="xslLib:cals-table-elements-names"
    select="('table', 'tgroup', 'colspec', 'spanspec', 'thead', 
    'tfoot', 'tbody', 'row', 'entrytbl', 'entry')"/>
  
  <!--==================================================================================-->
  <!-- INIT -->
  <!--==================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:setCalsTableNS.main"/>
  </xsl:template>
  
  <!--==================================================================================-->
  <!-- MAIN -->
  <!--==================================================================================-->
  
  <xsl:mode name="xslLib:setCalsTableNS.main" on-no-match="shallow-copy"/>
  
  <!--Convert cals candidate elements to the cals namespace-->
  <xsl:template 
    match="*
    [(:exclude element that are already in cals namespace:) not(self::cals:*)]
    [(:avoid matching - and testing - every elements:) xslLib:hasCalsTableElementLocalName(.)]
    [xslLib:isCandidateCalsTableElement(.)]" mode="xslLib:setCalsTableNS.main">
    <xsl:element name="{local-name(.)}" namespace="http://docs.oasis-open.org/ns/oasis-exchange/table">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!--==================================================================================-->
  <!-- COMMON -->
  <!--==================================================================================-->
  
  <!--Indicates if an element looks like a cals table element-->
  <xsl:function name="xslLib:isCandidateCalsTableElement" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="
      (:check element's name:)
      xslLib:hasCalsTableElementLocalName($e) 
      (:also check global structure - avoid converting an html table to cals table for instance:)
      and ($e/ancestor-or-self::*[lower-case(local-name())= 'table'][*[lower-case(local-name()) = 'tgroup']])"/>
  </xsl:function>
  
  <!--Indicates if an element has the same local name as a CALS table element-->
  <xsl:function name="xslLib:hasCalsTableElementLocalName" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="(lower-case(local-name($e)) = $xslLib:cals-table-elements-names)"/>
  </xsl:function>
  
</xsl:stylesheet>