<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xpath-default-namespace="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all" 
  >
  
  <!--<xsl:import href="els-common.xsl"/>-->
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Normalize Cals Table</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--==============================================================================================================================-->
  <!-- INIT -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:normalizeCalsTable"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- MAIN -->
  <!--==============================================================================================================================-->
  
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
  
  <!--add empty colwidth if none exist-->
  <xsl:template match="colspec[not(@colwidth)]" mode="xslLib:normalizeCalsTable">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="colwidth"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Normalize @colwidth value-->
  <xsl:template match="colspec/@colwidth" mode="xslLib:normalizeCalsTable">
    <!--lowercase and no spaces-->
    <xsl:variable name="value.normalized" select="replace(lower-case(.), '\s', '')" as="xs:string"/>
    <!--adding unit "*" if none-->
    <xsl:attribute name="colwidth">
      <xsl:choose>
        <!--no unit-->
        <xsl:when test="replace(., '(\d|\.)', '') = ''">
          <xsl:value-of select="concat($value.normalized, '*')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$value.normalized"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <!--copy template-->
  <xsl:template match="* | @* | node()" mode="xslLib:normalizeCalsTable">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
