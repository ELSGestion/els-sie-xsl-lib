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
  version="3.0"
  xml:lang="en">
  
  <!--Variable that helps checking dependency to ensure this XSLT is loaded (especially usefull to test XSLT mode avaiable-->
  <xsl:variable name="xslLib:normalizeCalsTable.no-inclusions.available" select="true()" static="true"/>
  
  <!--Static compilation check for all inclusions to be available (avoid xslt mode not load)-->
  <xsl:variable name="xslLib:normalizeCalsTable.no-inclusions.check-available-inclusions">
    <xsl:sequence select="$calstable:normalize.available"/>
  </xsl:variable>
  
  <xd:doc scope="stylesheet">
    <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
      You may also you the standalone version of this XSLT (without "no-inclusions" extension)
    </xd:p>
    <xd:desc>
      <xd:p>Normalize Cals Table</xd:p>
    </xd:desc>
  </xd:doc>
  
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
        <xsl:apply-templates select="$step" mode="xslLib:normalizeToLowerCaseCals"/>
      </xsl:document>
    </xsl:variable>
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
  <!-- xslLib:normalizeToLowerCaseCals -->
  <!--==================================================================================-->
  
  <xsl:mode name="xslLib:normalizeToLowerCaseCals" on-no-match="shallow-copy"/>
  
  <!--Set all cals element's name to lower-case-->
  <xsl:template match="cals:*" mode="xslLib:normalizeToLowerCaseCals">
    <xsl:element name="{lower-case(local-name())}">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="cals:*/@*[lower-case(name()) = 'id']" mode="xslLib:normalizeToLowerCaseCals">
    <xsl:attribute name="{lower-case(name())}" select="."/>
  </xsl:template>
  
  <!--Set cals attributes name and values to lower-case-->
  <xsl:template mode="xslLib:normalizeToLowerCaseCals"
    match="cals:*[lower-case(local-name())= 'table']/@*[lower-case(local-name()) = ('frame', 'colsep', 'rowsep', 'tocentry', 'shortentry', 'orient', 'pgwide')]
    | cals:*[lower-case(local-name())= 'tgroup']/@*[lower-case(local-name()) = ('cols', 'colsep', 'rowsep', 'align')]
    | cals:*[lower-case(local-name())= 'colspec']/@*[lower-case(local-name()) = ('colwidth', 'colsep', 'rowsep', 'align')]
    | cals:*[lower-case(local-name())= 'spanspec']/@*[lower-case(local-name()) = ('colsep', 'rowsep', 'align')]
    | cals:*[lower-case(local-name())= 'thead']/@*[lower-case(local-name()) = ('valign')]
    | cals:*[lower-case(local-name())= 'tfoot']/@*[lower-case(local-name()) = ('valign')]
    | cals:*[lower-case(local-name())= 'tbody']/@*[lower-case(local-name()) = ('valign')]
    | cals:*[lower-case(local-name())= 'row']/@*[lower-case(local-name()) = ('valign', 'rowsep')]
    | cals:*[lower-case(local-name())= 'entry']/@*[lower-case(local-name()) = ('morerows', 'colsep', 'rowsep', 'align', 'valign', 'rotate')]
    | cals:*[lower-case(local-name())= 'entrytbl']/@*[lower-case(local-name()) = ('cols', 'colsep', 'rowsep', 'align')]"
    >
    <xsl:attribute name="{lower-case(name())}" select="lower-case(.)"/>
  </xsl:template>
  
  <!--Set cals attributes name to lower-case, force keeping values as is -->
  <xsl:template mode="xslLib:normalizeToLowerCaseCals"
    match="cals:*[lower-case(local-name())= 'table']/@*[lower-case(local-name()) = ('tabstyle')]
    | cals:*[lower-case(local-name())= 'tgroup']/@*[lower-case(local-name()) = ('tgroupstyle', 'char', 'charoff')]
    | cals:*[lower-case(local-name())= 'colspec']/@*[lower-case(local-name()) = ('colnum', 'colname', 'char', 'charoff')]
    | cals:*[lower-case(local-name())= 'spanspec']/@*[lower-case(local-name()) = ('namest', 'nameend', 'spanname', 'char', 'charoff')]
    | cals:*[lower-case(local-name())= 'entry']/@*[lower-case(local-name()) = ('colname', 'namest', 'nameend', 'spanname', 'char', 'charoff')]
    | cals:*[lower-case(local-name())= 'entrytbl']/@*[lower-case(local-name()) = ('tgroupstyle', 'colname', 'spanname', 'namest', 'nameend', 'char', 'charoff')]"
    >
    <xsl:attribute name="{lower-case(name())}" select="."/>
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
  
  <!--Normalize yesorno values (yes/no becomes 1/0)-->
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
    <xsl:variable name="result" select="cals:normalize(.)" as="item()*"/>
    <xsl:if test="count($result) != 1">
      <xsl:processing-instruction name="ERROR">cals:normalize(.) should return a single element</xsl:processing-instruction>
    </xsl:if>
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