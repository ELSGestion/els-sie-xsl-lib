<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Because XSPEC doesn't care about the xsl:output, this XSLT tries to simulate the method="xhtml"</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--If the original XSLT has an specific encoding, pass it as parameter-->
  <xsl:param name="encoding" select="'UTF-8'" as="xs:string"/>
  
  <xsl:template match="/">
    <xsl:variable name="step1" as="document-node()">
      <xsl:document>
        <!--applying the xslt that import this one-->
        <xsl:apply-imports/>
      </xsl:document>
    </xsl:variable>
    <xsl:apply-templates select="$step1" mode="els:xspec.adapt.xhtml-output"/>
  </xsl:template>
  
  <!--The default (x)html output add an encoding meta in the head element-->
  <xsl:template match="html/head" mode="els:xspec.adapt.xhtml-output">
    <xsl:message>[XSPEC] Simulate html serialisation : adding meta charset </xsl:message>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <meta http-equiv="Content-Type" content="text/html; charset={$encoding}" />
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:xspec.adapt.xhtml-output">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>