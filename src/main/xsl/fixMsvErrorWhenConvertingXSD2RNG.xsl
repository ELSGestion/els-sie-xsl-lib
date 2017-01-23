<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://relaxng.org/ns/structure/1.0"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xf="http://www.lefebvre-sarrut.eu/ns/xmlfirst"
  xmlns:local="local"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="rng-common.xsl"/>
  
  <xsl:output indent="yes"/>
  
  <xsl:param name="startFrom" select="''" as="xs:string"/>
  <xsl:variable name="reStart" select="$startFrom != ''" as="xs:boolean"/>
  
  <!--================================-->
  <!--MAIN-->
  <!--================================-->

  <!-- ===== redefinition du start =====-->
  
  <xsl:template match="start[$reStart]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <ref name="{$startFrom}"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ===== Simplification =====-->
  <!--je ne sais pas pourquoi MSV mets systématiquement la structure choice/notAllowed (peut être par rapport au start ?)-->
  <xsl:template match="choice[notAllowed]">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="notAllowed[parent::choice]">
    <xsl:apply-templates/>
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
  
  <xsl:template match="mixed/mixed">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mixed[count(*) = 1 and ref][local:isMixed(rng:getDefine(ref[1]))]">
    <xsl:apply-templates/>
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
  <xsl:template match="define[element[not(@name)]]">
    <xsl:message>[WARNING]Suppression de define '<xsl:value-of select="@name"/>' !</xsl:message>
  </xsl:template>
  
  <xsl:template match="ref[rng:getDefine(.)[element[not(@name)]]]">
    <empty/>
  </xsl:template>
  
  <!--================================-->
  <!--COMMON-->
  <!--================================-->
  
  <xsl:function name="local:isMixed" as="xs:boolean">
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
  
  <!--copie par défaut-->
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>