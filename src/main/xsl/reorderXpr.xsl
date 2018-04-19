<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>reorderXpr</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:output encoding="UTF-8" indent="yes"/>
  <!--<xsl:strip-space elements="*"/>-->

  <!-- Répertoire d'écriture des logs -> par défaut, /log à côté du XML source ; sinon, emplacement fourni par Spring XD -->
  <xsl:param name="LOG.URI" required="no" select="resolve-uri('log', base-uri(/))" as="xs:string"/>
  
  <xsl:param name="debug" select="false()" as="xs:boolean"/>
  
  <!-- Répertoire d'écriture des logs (avec "/" final) -->
  <xsl:variable name="log.uri" select="if (ends-with($LOG.URI,'/')) then ($LOG.URI) else (concat($LOG.URI,'/'))" as="xs:string"/>

  <xsl:template match="/">
    <xsl:apply-templates select="." mode="els:reorderXpr"/>
  </xsl:template>

  <xsl:template match="/" mode="els:reorderXpr">    
    <xsl:variable name="step" select="." as="document-node()"/>
    
    <!-- remove @xml:space-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:removeXmlSpace"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-removeXmlSpace.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>

    <!-- remove double white spaces according @xml:space -->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:removeUnsedWhiteSpaces"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-removeUnsedWhiteSpaces.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    
    <!-- create orderBy tag -->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:createAttributeOrder"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-createAttributeOrder.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    
    <!-- order by the orderBy tag -->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:orderXpr"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-orderXpr.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>

    <!-- remise de @xml:space-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:putXmlSpace"/>
      </xsl:document>
    </xsl:variable>

    <xsl:sequence select="$step"/>
  </xsl:template>

  <!-- ****************************************** -->
  <!-- mode="els:putXmlSpace" -->
  <!-- ****************************************** -->
  
  <xsl:template match="@xmlSpace" mode="els:putXmlSpace">
    <!--<xsl:attribute name="xml:space" select="."/>-->
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:putXmlSpace" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- ****************************************** -->
  <!-- mode="els:removeXmlSpace" -->
  <!-- ****************************************** -->
  
  <xsl:template match="@xml:space" mode="els:removeXmlSpace">
    <xsl:attribute name="xmlSpace" select="."/>
  </xsl:template>
  
<!--  <xsl:template match="*[text() != ''][count(child::*) = 0]" mode="els:removeXmlSpace">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <!-\-<xsl:attribute name="xml:space">preserve</xsl:attribute>-\->
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:template match="node() | @*" mode="els:removeXmlSpace" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ****************************************** -->
  <!-- mode="els:supress double white space" -->
  <!-- ****************************************** -->
  
  <xsl:template match="node() | @*" mode="els:removeUnsedWhiteSpaces" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space(.)='']" mode="els:removeUnsedWhiteSpaces">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- ****************************************** -->
  <!-- mode="els:createAttributeOrder" -->
  <!-- ****************************************** -->
  
  <xsl:template match="scenario-array/*" mode="els:createAttributeOrder">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="orderBy" select="normalize-space(string-join(., ''))"/>
      <xsl:apply-templates mode="#current"/>      
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:createAttributeOrder" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ****************************************** -->
  <!-- mode="els:orderXpr" -->
  <!-- ****************************************** -->
  
  <xsl:template match="scenario-array" mode="els:orderXpr">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current">
        <xsl:sort select="upper-case(@orderBy)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[child::*/@name | child::*/@path]" mode="els:orderXpr">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current">
        <xsl:sort select="local-name()"/>
        <xsl:sort select="upper-case(@name)"/>
        <xsl:sort select="upper-case(@path)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@orderBy" mode="els:orderXpr"/>

  <xsl:template match="node() | @*" mode="els:orderXpr" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>