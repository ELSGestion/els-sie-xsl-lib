<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Delete thead element from html tables (usefull to simplify table edition under TinyMCE for instance)</xd:p>
      <xd:ul>
        <xd:li>Convert td to th when it was within thead (so one can add thead back with html-tables.add-thead.xsl)</xd:li>
        <xd:li>One should also delete tbody so the file is valide : here we add a global tbody</xd:li>
        <xd:li>Attributes and style on thead (and tbody) are dropt down to children elements (tr)</xd:li>
      </xd:ul>
      <xd:p>NB: this is not a safe conversion because tables maight not look the same after, but it's usefull in combination with html-tables.add-thead.xsl</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--===================================================-->
  <!--INIT-->
  <!--===================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:html-table-delete-thead.main"/>
  </xsl:template>
  
  <!--===================================================-->
  <!--MAIN-->
  <!--===================================================-->
  
  <xsl:mode name="xslLib:html-table-delete-thead.main" on-no-match="shallow-copy"/>
  
  <!--Delete thead in tables to make table edition easier, the tbody must also be deleted so the table structure is valid-->
  <xsl:template match="table[thead]/*[local-name() = ('thead', 'tbody')]" mode="xslLib:html-table-delete-thead.main">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!--Keep (or add) a global tbody-->
  <xsl:template match="table[thead]" mode="xslLib:html-table-delete-thead.main">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="*" group-adjacent="local-name() = ('thead', 'tbody', 'tr')">
        <!--there might be a thead without tbody, only tr after it-->
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <tbody xmlns="http://www.w3.org/1999/xhtml">
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </tbody>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group> 
    </xsl:copy>
  </xsl:template>
  
  <!--copy thead (or tbody) style to tr (prevent loosing any information)-->
  <xsl:template match="table/*[local-name() = ('thead', 'tbody')]/tr" mode="xslLib:html-table-delete-thead.main">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="parent::*/(@style, @align, @valign)" mode="#current"/>
      <!--FIXME : one should merge thead and tr style if both have one-->
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--convert td inside thead to th (if not one could not distinguish them and rebuild le thead properly)-->
  <xsl:template match="table/thead/tr/td" mode="xslLib:html-table-delete-thead.main">
    <th xmlns="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </th>
  </xsl:template>
  
</xsl:stylesheet>