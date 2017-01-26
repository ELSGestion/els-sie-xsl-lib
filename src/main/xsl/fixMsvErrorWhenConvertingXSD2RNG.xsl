<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://relaxng.org/ns/structure/1.0"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:xf="http://www.lefebvre-sarrut.eu/ns/xmlfirst"
  xmlns:fixMsvErrorWhenConvertingXSD2RNG="http://www.lefebvre-sarrut.eu/ns/els/xslLib/fixMsvErrorWhenConvertingXSD2RNG"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="rng-common.xsl"/>
  
  <xsl:output indent="yes"/>
  
  <!--Par défaut les log sont écris à côté du xml-->
  <xsl:param name="LOG.URI" select="resolve-uri('log', base-uri(.))" as="xs:string"/>
  <xsl:variable name="log.uri" select="if(ends-with($LOG.URI, '/')) then ($LOG.URI) else(concat($LOG.URI, '/'))" as="xs:string"/>
  <xsl:param name="debug" select="false()" as="xs:boolean"/>
  <xsl:param name="startFrom" select="''" as="xs:string"/>

  <xsl:variable name="reStart" select="$startFrom != ''" as="xs:boolean"/>
  
  <!--=============================================================================================-->
  <!--INIT-->
  <!--=============================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="fixMsvErrorWhenConvertingXSD2RNG:main"/>
  </xsl:template>
  
  <!--=============================================================================================-->
  <!--MAIN-->
  <!--=============================================================================================-->

  <xsl:template match="/" mode="fixMsvErrorWhenConvertingXSD2RNG:main">
    <xsl:variable name="step1" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="fixMsvErrorWhenConvertingXSD2RNG:step1"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$debug">
      <xsl:variable name="step1.log.uri" select="resolve-uri(concat('fixMsvErrorWhenConvertingXSD2RNG.step1.', els:getFileName(base-uri(), false()),'.log.xml'), $log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step1.log.uri"/></xsl:message>
      <xsl:result-document href="{$step1.log.uri}">
        <xsl:sequence select="$step1"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:apply-templates select="$step1" mode="fixMsvErrorWhenConvertingXSD2RNG:step2"/>
  </xsl:template>
  
  <!--========================================================-->
  <!--STEP 1-->
  <!--========================================================-->
  
  <!-- ===== redefinition du start =====-->
  
  <xsl:template match="start[$reStart]" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <ref name="{$startFrom}"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ===== Simplification =====-->
  
  <!--je ne sais pas pourquoi MSV mets systématiquement la structure choice/notAllowed (peut être par rapport au start ?)-->
  <xsl:template match="choice[notAllowed]" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="notAllowed[parent::choice]" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- ===== Suppression des <mixed> imbriqués =====-->
  
  <!--<xsl:template match="mixed[mixed]">
    <xsl:apply-templates/>
  </xsl:template>-->
  <!--Contre-exemple :
  <define name="renvoiAutrui">
    <choice>
      <notAllowed/>
      <element name="renvoiAutrui">
        <mixed>
          <mixed>
            <ref name="renvoiAttGrp"/>
          </mixed>
          <zeroOrMore>
            <ref name="baseTextGroup"/>
          </zeroOrMore>
        </mixed>
      </element>
    </choice>
  </define>
  => ici mieux vaut supprimer le mixed/mixed
  -->
  
  <xsl:template match="mixed/mixed" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="mixed[count(*) = 1 and ref][fixMsvErrorWhenConvertingXSD2RNG:isMixed(rng:getDefine(ref[1]))]" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!--===== Co-constraint sur les id =====-->
  
  <!--Cela peut venir d'un xsd laxiste avec juste <xs:element name="x"/> qui force à créé du any en rng, le mieux est de corriger le xsd-->
  <!--http://zvon.org/xxl/XMLSchemaTutorial/Output/ser_import_st1.html ?? @lax-->
  
  <!-- ===== Element sans @name =====-->
  
  <!--Exemple 
  <define name="_1">
    <element>
      <nsName ns="http://www.w3.org/1999/xhtml"/>
      <interleave>
        <text/>
        <zeroOrMore>
          <choice>
            <ref name="_1"/>
            <attribute>
              <nsName ns="http://www.w3.org/1999/xhtml"/>
              <text/>
            </attribute>
          </choice>
        </zeroOrMore>
      </interleave>
    </element>
  </define>
  qui vient de 
  <xs:element name="xhtmlReference">
    <xs:annotation>
      <xs:documentation>objet multimedia distante référencé via une portion de code XHTML</xs:documentation>
    </xs:annotation>
    <xs:complexType>
      <xs:choice maxOccurs="unbounded">
        <xs:any namespace="http://www.w3.org/1999/xhtml" processContents="skip"/>
      </xs:choice>
    </xs:complexType>
  </xs:element>-->
  <!--A éviter pour la lib rng... même si ce n'est pas faux !-->
  <xsl:template match="define[element[not(@name)]]" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <xsl:message>[WARNING]Suppression de define '<xsl:value-of select="@name"/>' !</xsl:message>
  </xsl:template>
  
  <xsl:template match="ref[rng:getDefine(.)[element[not(@name)]]]" mode="fixMsvErrorWhenConvertingXSD2RNG:step1">
    <empty/>
  </xsl:template>
  
  <!--========================================================-->
  <!--STEP 2-->
  <!--========================================================-->
  
  <!-- ===== UnAttach attribute involved in mixed content =====-->
  <!--
  Example : 
  <define name="refDocReprise">
    <element name="refDocReprise">
      <mixed>
        <optional>
          <attribute name="enVigueur">
            <data type="boolean"/>
          </attribute>
        </optional>
        <zeroOrMore>
          <ref name="baseTextGroup"/>
        </zeroOrMore>
      </mixed>
    </element>
  </define>
  
  Will be transformed into : 
  
  <define name="refDocReprise">
    <element name="refDocReprise">
      <optional>
        <attribute name="enVigueur">
          <data type="boolean"/>
        </attribute>
      </optional>
      <mixed>
        <zeroOrMore>
          <ref name="baseTextGroup"/>
        </zeroOrMore>
      </mixed>
    </element>
  </define>
  
  The same for an attribute which is not optional and for ref to only attribute define
  
  -->
  
  <xsl:template match="mixed[optional[count(*)= count(attribute)]] | mixed[attribute] | mixed[ref[fixMsvErrorWhenConvertingXSD2RNG:isOnlyAttributesDefine(rng:getDefine(.))]]" mode="fixMsvErrorWhenConvertingXSD2RNG:step2">
    <xsl:variable name="attributeContent" select="optional[count(*)= count(attribute)] | attribute | ref[fixMsvErrorWhenConvertingXSD2RNG:isOnlyAttributesDefine(rng:getDefine(.))]" as="element()+"/>
    <xsl:variable name="mixedContent" as="element()*">
      <xsl:sequence select="* except $attributeContent"/>
    </xsl:variable>
    <xsl:apply-templates select="$attributeContent" mode="#current"/>
    <xsl:choose>
      <xsl:when test="count($mixedContent) = 0">
        <xsl:message terminate="yes">define <xsl:value-of select="ancestor::define/@name"/> : 0 mixed element inside</xsl:message>
      </xsl:when>
      <!--Only one ref-->
      <xsl:when test="count($mixedContent) = 1 and $mixedContent/self::ref">
        <xsl:choose>
          <!--And this ref is a <mixed>-->
          <xsl:when test="rng:getDefine($mixedContent/self::ref)/mixed">
            <xsl:copy-of select="$mixedContent"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy copy-namespaces="no">
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="$mixedContent" mode="#current"/>
            </xsl:copy>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="$mixedContent" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--================================-->
  <!--COMMON-->
  <!--================================-->
  
  <xsl:function name="fixMsvErrorWhenConvertingXSD2RNG:isMixed" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <xsl:choose>
      <xsl:when test="count($define/*) = 1 and $define/mixed">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="fixMsvErrorWhenConvertingXSD2RNG:isOnlyAttributesDefine" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <xsl:variable name="define.derivated.byAttribute" as="element()*">
      <xsl:apply-templates select="$define/*" mode="fixMsvErrorWhenConvertingXSD2RNG:refToAttributeOnly"/>
    </xsl:variable>
    <xsl:sequence select="every $rngElement in $define.derivated.byAttribute satisfies $rngElement/self::attribute"/>
  </xsl:function>
  
  <xsl:template match="*[rng:isStructuralInstructionInDataModel(.)]" mode="fixMsvErrorWhenConvertingXSD2RNG:refToAttributeOnly">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="text()" mode="fixMsvErrorWhenConvertingXSD2RNG:refToAttributeOnly"/>
  
  <xsl:template match="node() | @*" mode="fixMsvErrorWhenConvertingXSD2RNG:refToAttributeOnly" priority="-1">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Default copy-->
  <xsl:template match="node() | @*" mode="fixMsvErrorWhenConvertingXSD2RNG:step1 fixMsvErrorWhenConvertingXSD2RNG:step2">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>