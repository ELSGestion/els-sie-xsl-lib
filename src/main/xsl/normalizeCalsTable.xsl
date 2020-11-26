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
      <xd:p>Normalize Cals Table</xd:p>
    </xd:desc>
  </xd:doc>
  
  
  <xsl:import href="normalize.xsl"/>
  
  <!--==================================================================================-->
  <!-- INIT -->
  <!--==================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:normalizeCalsTable.main"/>
  </xsl:template>
  
  <!--==================================================================================-->
  <!-- MAIN -->
  <!--==================================================================================-->
  
  <xsl:template match="/" mode="xslLib:normalizeCalsTable.main">
    <xsl:variable name="step" select="." as="document-node()"/>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:normalizeCalsTable"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:normalizeCalsTable.transpec-normalization"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:normalizeCalsTable.finally"/>
      </xsl:document>
    </xsl:variable>
    <xsl:sequence select="$step"/>
  </xsl:template>
  
  <!--==================================================================================-->
  <!-- xslLib:normalizeCalsTable -->
  <!--==================================================================================-->
  
  <xsl:mode name="xslLib:normalizeCalsTable" on-no-match="shallow-copy"/>
  
  <!--Default frame value is "all"-->
  <xsl:template match="table[not(@frame)]" mode="xslLib:normalizeCalsTable">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="frame" select="'all'"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Normalize yesorno values (0/false or 1/true becomes yes/no)-->
  <xsl:template match="
    table/@colsep | table/@rowsep | table/@tocentry | table/@shortentry | table/@pgwide |
    tgroup/@colsep | tgroup/@rowsep |
    colspec/@colsep | colspec/@rowsep |
    spanspec/@colsep | spanspec/@rowsep |
    row/@rowsep  |
    entrytbl/@colsep | entrytbl/@rowsep |
    entry/@colsep | entry/@rowsep | entry/@rotate" mode="xslLib:normalizeCalsTable">
    <xsl:choose>
      <xsl:when test=". = ('0', '1')">
        <xsl:next-match/>
      </xsl:when>
      <xsl:when test=". = ('yes', 'no')">
        <xsl:attribute name="{name(.)}" select="if(. = 'yes') then ('1') else('0')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][normalizeCalsTable.xsl] attribute <xsl:value-of select="name()"/>="<xsl:value-of select="."/>" should be a boolean value, it has been ignored </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--add colwidth="1*" if none exist (this is the official CALS default value)-->
  <xsl:template match="colspec[not(@colwidth)]" mode="xslLib:normalizeCalsTable">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="colwidth" select="'1*'"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Normalize @colwidth value-->
  <xsl:template match="colspec/@colwidth" mode="xslLib:normalizeCalsTable">
    <!--value should be lowercase without spaces-->
    <xsl:variable name="value.normalized" select="replace(lower-case(.), '\s', '')" as="xs:string"/>
    <xsl:attribute name="colwidth">
      <xsl:choose>
        <!--adding unit "*" no unit-->
        <xsl:when test="replace(., '(\d|\.)', '') = ''">
          <xsl:value-of select="concat($value.normalized, '*')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$value.normalized"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <!--Delete colname when namest and nameend are setted (it's an error to have both - cf. cals schematron-->
  <xsl:template match="entry[@namest and @nameend]/@colname" mode="xslLib:normalizeCalsTable"/>
  
  <!--==================================================================================-->
  <!-- transpec-normalization -->
  <!--==================================================================================-->
  
  <xsl:mode name="xslLib:normalizeCalsTable.transpec-normalization" on-no-match="shallow-copy"/>
  
  <xsl:template match="tgroup" mode="xslLib:normalizeCalsTable.transpec-normalization" >
    <xsl:sequence select="cals:normalize(.)"/>
  </xsl:template>
  
  <!--==================================================================================-->
  <!-- Finally -->
  <!--==================================================================================-->
  
  <xsl:mode name="xslLib:normalizeCalsTable.finally" on-no-match="shallow-copy"/>
  
  <xsl:template match="@calstable:namest | @calstable:nameend | @calstable:spanname | @calstable:morerows"
    mode="xslLib:normalizeCalsTable.finally">
    <xsl:attribute name="{local-name()}" select="."/>
  </xsl:template>
  
  <!--pretty print : namespace at root element-->
  <xsl:template match="/*" mode="xslLib:normalizeCalsTable.finally">
    <xsl:copy copy-namespaces="yes">
      <xsl:namespace name="calstable">http://docs.oasis-open.org/ns/oasis-exchange/table</xsl:namespace>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>