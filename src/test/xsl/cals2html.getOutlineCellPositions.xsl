<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns:calstable="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>XSLT to test function xslLib:cals2html.getOutlineCellPositions()</xd:p>
      <xd:p>From any CALS table (with ghost entries) it write inside each cell the output of the function</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="../../main/xsl/cals2html.xsl"/>
  
  <xsl:param name="xslLib:cals2html-keep-unmatched-attributes" select="true()" as="xs:boolean"/>
  
  <xsl:template match="/">
    <xsl:variable name="step" select="." as="document-node()"/>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:normalizeCalsTable.main"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:test-cals2html.getOutlineCellPositions"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:cals2html"/>
      </xsl:document>
    </xsl:variable>
    <xsl:sequence select="$step"/>
  </xsl:template>
  
  <!--==============================================-->
  <!--Mode normalizeCalsTable-->
  <!--==============================================-->
  
  <!--cf. cals2html.xsl-->
  
  <!--==============================================-->
  <!--Mode test-cals2html.getOutlineCellPositions-->
  <!--==============================================-->
  
  <xsl:mode name="xslLib:test-cals2html.getOutlineCellPositions" on-no-match="shallow-copy"/>
  
  <xsl:template match="entry[not(@calstable:rid)]" mode="xslLib:test-cals2html.getOutlineCellPositions">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:variable name="outlineCellPosition" select="xslLib:cals2html.getOutlineCellPositions(.)" as="xs:string*"/>
      <xsl:if test="not(empty($outlineCellPosition))">
        <xsl:attribute name="position" select="$outlineCellPosition"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Delete ghost cells and attributes coming from normalization-->
  <xsl:template match="entry[@calstable:rid]| entry/@calstable:id" 
    mode="xslLib:test-cals2html.getOutlineCellPositions"/>
  
</xsl:stylesheet>