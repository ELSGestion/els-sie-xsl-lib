<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>reorder Xpr - main oXygen projet file</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>

  <!-- default log folder -->
  <xsl:param name="LOG.URI" required="no" select="resolve-uri('log', base-uri(/))" as="xs:string"/>
  <xsl:param name="debug.reorder.xpr" select="false()" as="xs:boolean"/>
  
  <!-- Répertoire d'écriture des logs (avec "/" final) -->
  <xsl:variable name="log.uri" select="if (ends-with($LOG.URI,'/')) then ($LOG.URI) else (concat($LOG.URI,'/'))" as="xs:string"/>

  <!-- ======================================================= -->
  <!-- INIT -->
  <!-- ======================================================= -->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Main template</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="els:reorderXpr"/>
  </xsl:template>

  <!-- ======================================================= -->
  <!-- MAIN - mode="els:reorderXpr" -->
  <!-- ======================================================= -->
  <xd:doc>
    <xd:desc>
      <xd:p>Main template mode="els:reorderXpr"</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/" mode="els:reorderXpr">    
    <xsl:variable name="step" select="." as="document-node()"/>
    <!-- Desactivate @xml:space-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:reorderXpr-removeXmlSpace"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug.reorder.xpr">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-reorderXpr-removeXmlSpace.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!-- remove double white spaces according @xml:space -->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:reorderXpr-normalizeText"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug.reorder.xpr">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-reorderXpr-removeUnsedWhiteSpaces.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!-- create orderBy tag -->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:reorderXpr-createOrderAttribute"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug.reorder.xpr">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-reorderXpr-createAttributeOrder.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!-- order by the orderBy tag -->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:reorderXpr-orderXpr"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug.reorder.xpr">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-reorderXpr-orderXpr.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!-- activate @xml:space-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="els:reorderXpr-activateXmlSpace"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug.reorder.xpr">
      <xsl:variable name="step.log.uri" select="concat($log.uri, 'step-reorderXpr-putXmlSpace.log.xml')" as="xs:string"/>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!-- return sequence -->
    <xsl:sequence select="$step"/>
  </xsl:template>

  <!-- ****************************************** -->
  <!-- mode="els:reorderXpr-removeXmlSpace" -->
  <!-- ****************************************** -->
  <xd:doc>
    <xd:desc>
      <xd:p>Rename the @xml:space to @xmlSpace</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@xml:space" mode="els:reorderXpr-removeXmlSpace">
    <xsl:attribute name="xmlSpace" select="."/>
  </xsl:template>

  <!-- ****************************************** -->
  <!-- mode="els:supress double white space" -->
  <!-- ****************************************** -->
  <xd:doc>
    <xd:desc>
      <xd:p>Normalize text()</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="text()[normalize-space(.)='']" mode="els:reorderXpr-normalizeText">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <!-- ****************************************** -->
  <!-- mode="els:reorderXpr-createOrderAttribute" -->
  <!-- ****************************************** -->
  <xd:doc>
    <xd:desc>
      <xd:p>Create order attributes on children of &lt;scenario-array&gt;</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="scenario-array/*" mode="els:reorderXpr-createOrderAttribute">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="orderBy" select="normalize-space(string-join(., ''))"/>
      <xsl:apply-templates mode="#current"/>      
    </xsl:copy>
  </xsl:template>

  <!-- ****************************************** -->
  <!-- mode="els:reorderXpr-orderXpr" -->
  <!-- ****************************************** -->
  <xd:doc>
    <xd:desc>
      <xd:p>Order children of &lt;scenario-array&gt;</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="scenario-array" mode="els:reorderXpr-orderXpr">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current">
        <xsl:sort select="upper-case(@orderBy)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Order all element according @local-name, @name and @path</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*[child::*/@name | child::*/@path]" mode="els:reorderXpr-orderXpr">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current">
        <xsl:sort select="local-name()"/>
        <xsl:sort select="upper-case(@name)"/>
        <xsl:sort select="upper-case(@path)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
   
  <xd:doc>
    <xd:desc>
      <xd:p>Remove @orderBy</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@orderBy" mode="els:reorderXpr-orderXpr"/>

  <!-- ****************************************** -->
  <!-- mode="els:reorderXpr-activateXmlSpace" -->
  <!-- ****************************************** -->
  <xd:doc>
    <xd:desc>
      <xd:p>Activate @xml:space</xd:p>
      <xd:p>Cuurently no activation, it seems to work during opening Xpr with oXygen</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@xmlSpace" mode="els:reorderXpr-activateXmlSpace">
    <!--<xsl:attribute name="xml:space" select="."/>-->
  </xsl:template>

  <xd:doc>
    <xd:desc>
      <xd:p>Default copy for modes</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="node() | @*" mode="els:reorderXpr-orderXpr
                                          els:reorderXpr-activateXmlSpace
                                          els:reorderXpr-removeXmlSpace
                                          els:reorderXpr-normalizeText
                                          els:reorderXpr-createOrderAttribute
                                          " priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>