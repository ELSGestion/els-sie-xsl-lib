<?xml version="1.0" encoding="UTF-8"?>
<!--
  
XSL mise à jour aux ELS après adaptation de plusieurs sources : 
- http://debeissat.nicolas.free.fr/relaxng_simplification.php
- http://downloads.xmlschemata.org/relax-ng/utilities/simplification.xsl
- https://btw.mangalamresearch.org/static/lib/salve/rng-simplification

Notes de Gilles Marichal :
A priori, l'essentiel vient d'ici: http://downloads.xmlschemata.org/relax-ng/utilities/simplification.xsl
Mais j'y suis arrivé à partir d'ici: http://debeissat.nicolas.free.fr/relaxng_simplification.php 
(il fait des corrections aux feuilles, mais elle ne me semblent pas justes pour l'essentiel)
A la base, celui qui l'a fait est Eric van der Vlist
Sa correction pour le step 15, je l'ai gardée, mais pas celles du step 14 
(cf: http://stackoverflow.com/questions/5102313/limitations-of-eric-van-der-vlists-relaxng-simplicification) 
Mais le bout pour l'avant dernier step vient d'ailleurs, c'était aussi basé sur le code d'Eric van der Vlist, 
mais pas mal modifié pour des besoins particuliers : https://btw.mangalamresearch.org/static/lib/salve/rng-simplification

-->

<!--FIXME gmarichal :
Pour bien comprendre à quoi correspond chaque step, j’ai mis en commentaire la spec iso.
J’ai corrigé un bug dans le step7.9 et simplifié certains matches en tenant compte des facilités de xslt 3.0 
Je comptais simplifier l’étape de renommage des steps 7.19 et 7.20 qui est un peu en « brute force » par emploi de generate-id() 
(j’ai dans un autre fichier de test du code xsl qui sort a peu près ce que sort jing, mais je n’ai pas eu le temps de l’adapter pour simplification.xsl)-->

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:rng2srng="http://relaxng.org/ns/rng2srng"
  xmlns="http://relaxng.org/ns/structure/1.0"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
  version="3.0">
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:param name="rng2srng:log.uri" select="resolve-uri('log/', base-uri(.))" as="xs:anyURI" />
  <xsl:param name="rng2srng:debug" select="true()" as="xs:boolean" />
  
  <!-- =================================================================== -->
  <!--                           INIT                                      -->
  <!-- =================================================================== -->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="rng2srng:main"/>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--                           MAIN                                      -->
  <!-- =================================================================== -->
  
  <xsl:template match="/" mode="rng2srng:main">
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="rng2srng:step7.2"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.2..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.3"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.3..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.4"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.4..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.5"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.5..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.6"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.6..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.7"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.7..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.8"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.8..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.9"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.9..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.10"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.10..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.11"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.11..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.12"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.12..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.13"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.13..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.14"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.14..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.15"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.15..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.16"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.16..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.17"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.17..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.18"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.18..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.19"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.19..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.20"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.20..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="rng2srng:step7.21"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$rng2srng:debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('rng2srng.step7.21..rng', $rng2srng:log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--FINALY-->
    <xsl:apply-templates select="$step" mode="rng2srng:step7.22"/>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--                       ISO/IEC DIS 19757-2                           -->
  <!-- =================================================================== -->  
  <!--     7 Simplification                                                -->
  <!-- =================================================================== -->
  
  <!-- =================================================================== -->
  <!--     7.1 General                                                     -->
  <!-- =================================================================== -->
  <!--
    cf. http://www.relaxng.org/spec-20011203.html
    
    The full syntax given in the previous clause is transformed into a simpler syntax by applying the following
   transformation rules in order. The effect shall be as if each rule was applied to all elements in the schema before
   the next rule is applied. A transformation rule may also specify constraints that shall be satisfied by a correct
   schema. The transformation rules are applied at the data model level. Before the transformations are applied, the
   schema is parsed into an element in the data model.
   
  -->
  
  <!-- =================================================================== -->
  <!--     7.2 Annotations                                                 -->
  <!-- =================================================================== -->
  <!--
    Foreign attributes and elements are removed.
    NOTE It is safe to remove xml:base attributes at this stage because xml:base attributes are used in determining the [base
    URI] of an element information item, which is in turn used to construct the base URI of the context of an element. Thus, after a
    document has been parsed into an element in the data model, xml:base attributes can be discarded.
  -->
  
  <!--  <xsl:mode name="rng2srng:step7.2" on-no-match="deep-skip"/>-->
  <xsl:template match="* | @*" mode="rng2srng:step7.2"/>
 
  <xsl:template  match="/ | text() | rng:* | @*[namespace-uri()='']" mode="rng2srng:step7.2">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.3 Whitespace                                                  -->
  <!-- =================================================================== --> 
  <!--
    For each element other than value and param, each child that is a string containing only whitespace characters is
    removed.
    Leading and trailing whitespace characters are removed from the value of each name, type and combine attribute
    and from the content of each name element.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.3" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.3">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space(.)='' and not(parent::param or parent::value)]"
    mode="rng2srng:step7.3"/>
  
  <xsl:template match="@name | @type | @combine" mode="rng2srng:step7.3">
    <xsl:attribute name="{name()}" select="normalize-space(.)"/>
  </xsl:template>
  
  <xsl:template match="name/text()" mode="rng2srng:step7.3">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.4 datatypeLibrary attribute                                   -->
  <!-- =================================================================== -->
  <!--
    The value of each datatypeLibary attribute is transformed by escaping disallowed characters as specified in
    Section 5.4 of W3C XLink.
    For any data or value element that does not have a datatypeLibrary attribute, a datatypeLibrary attribute is added.
    The value of the added datatypeLibrary attribute is the value of the datatypeLibrary attribute of the nearest
    ancestor element that has a datatypeLibrary attribute, or the empty string if there is no such ancestor. Then, any
    datatypeLibrary attribute that is on an element other than data or value is removed.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.4" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.4">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@datatypeLibrary" mode="rng2srng:step7.4"/>
  
  <xsl:template match="data|value" mode="rng2srng:step7.4">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="datatypeLibrary" select="ancestor-or-self::*[@datatypeLibrary][1]/@datatypeLibrary"/>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.5 type attribute of value element                             -->
  <!-- =================================================================== -->
  <!--
    For any value element that does not have a type attribute, a type attribute is added with value token and the value
    of the datatypeLibrary attribute is changed to the empty string.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.5" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.5">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="value[not(@type)]/@datatypeLibrary" mode="rng2srng:step7.5"/>
  
  <xsl:template match="value[not(@type)]" mode="rng2srng:step7.5">
    <value type="token" datatypeLibrary="">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </value>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.6 href attribute                                              -->
  <!-- =================================================================== -->
  <!--
    The value of the href attribute on an externalRef or include element is first transformed by escaping disallowed
    characters as specified in Section 5.4 of W3C XLink. The URI reference is then resolved into an absolute form as
    described in Section 5.2 of IETF RFC 2396 using the base URI from the context of the element that bears the href
    attribute.
    The value of the href attribute is used to construct an element (as specified in Clause 5). This shall be done as
    follows. The URI reference consists of the URI itself and an optional fragment identifier. The resource identified by
    the URI is retrieved. The result is a MIME entity (see IETF RFC 2045): a sequence of bytes labeled with a MIME
    media type (see IETF RFC 2046). The media type determines how an element is constructed from the MIME
    entity and optional fragment identifier. When the media type is application/xml or text/xml, the MIME entity shall
    be parsed as an XML document in accordance with the applicable RFC (at the term of writing IETF RFC 3023)
    and an element constructed from the result of the parse as specified in Clause 5. In particular, the charset
    parameter shall be handled as specified by the RFC. This specification does not define the handling of media
    types other than application/xml and text/xml. The href attribute shall not include a fragment identifier unless the
    registration of the media type of the resource identified by the attribute defines the interpretation of fragment
    identifiers for that media type.
    NOTE IETF RFC 3023 does not define the interpretation of fragment identifiers for application/xml or text/xml.
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.6" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.6">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.7 externalRef element                                         -->
  <!-- =================================================================== -->
  <!--
    An externalRef element is transformed as follows. An element is constructed using the URI reference that is the
    value of href attribute as specified in 7.6. This element shall match the syntax for pattern. The element is
    transformed by recursively applying the rules from this subclauses and from previous subclauses of this clause.
    This shall not result in a loop. In other words, the transformation of the referenced element shall not require the
    dereferencing of an externalRef attribute with an href attribute with the same value.
    Any ns attribute on the externalRef element is transferred to the referenced element if the referenced element
    does not already have an ns attribute. The externalRef element is then replaced by the referenced element.
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.7" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.7">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="externalRef" mode="rng2srng:step7.7">
    <xsl:element name="{local-name(document(@href)/*)}" namespace="http://relaxng.org/ns/structure/1.0">
      <xsl:if test="not(document(@href)/*/@ns) and @ns">
        <xsl:attribute name="ns">
          <xsl:value-of select="@ns"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="document(@href)/*/@*"/>
      <xsl:copy-of select="document(@href)/*/*|document(@href)/*/text()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.8 include element                                             -->
  <!-- =================================================================== -->
  <!--
    An include element is transformed as follows. An element is constructed using the URI reference that is the value
    of href attribute as specified in 7.6. This element shall be a grammar element, matching the syntax for grammar.
    This grammar element is transformed by recursively applying the rules from this subclause and from previous
    subclauses of this clause. This shall not result in a loop. In other words, the transformation of the grammar
    element shall not require the dereferencing of an include attribute with an href attribute with the same value.
    Define the components of an element to be the children of the element together with the components of any div
    child elements. If the include element has a start component, then the grammar element shall have a start
    component. If the include element has a start component, then all start components are removed from the
    grammar element. If the include element has a define component, then the grammar element shall have a define
    component with the same name. For every define component of the include element, all define components with
    the same name are removed from the grammar element.
    The include element is transformed into a div element. The attributes of the div element are the attributes of the
    include element other than the href attribute. The children of the div element are the grammar element (after the
    removal of the start and define components described by the preceding paragraph) followed by the children of the
    include element. The grammar element is then renamed to div.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.8" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.8">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="include" mode="rng2srng:step7.8">
    <div>
      <xsl:copy-of select="@*[name() != 'href']"/>
      <xsl:copy-of select="*"/>
      <xsl:copy-of select="document(@href)/grammar/start[not(current()/start)]"/>
      <xsl:copy-of select="document(@href)/grammar/define[not(@name = current()/define/@name)]"/>
    </div>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.9 name attribute of element and attribute elements            -->
  <!-- =================================================================== -->
  <!--
    The name attribute on an element or attribute element is transformed into a name child element.
    If an attribute element has a name attribute but no ns attribute, then an ns="" attribute is added to the name child
    element.
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.9" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.9">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@name[parent::element|parent::attribute]" mode="rng2srng:step7.9"/>
  
  <!-- [gmarichal] Correction d'un bug du code original: déplacement du xsl:if -->
  <xsl:template match="element[@name] | attribute[@name]" mode="rng2srng:step7.9">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <name>
        <xsl:if test="self::attribute and not(@ns)">
          <xsl:attribute name="ns"/>
        </xsl:if>
        <xsl:value-of select="@name"/>
      </name>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.10 ns attribute                                               -->
  <!-- =================================================================== -->
  <!--
    For any name, nsName or value element that does not have an ns attribute, an ns attribute is added. The value
    of the added ns attribute is the value of the ns attribute of the nearest ancestor element that has an ns attribute,
    or the empty string if there is no such ancestor. Then, any ns attribute that is on an element other than name,
    nsName or value is removed.
    NOTE 1 The value of the ns attribute is not transformed either by escaping disallowed characters, or in any other way,
    because the value of the ns attribute is compared against namespace URIs in the instance, which are not subject to any
    transformation.
    NOTE 2 Since include and externalRef elements are resolved after datatypeLibrary attributes are added but before ns
    attributes are added, ns attributes are inherited into external schemas but datatypeLibrary attributes are not.
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.10" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.10">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@ns" mode="rng2srng:step7.10"/>
  
  <xsl:template match="name | nsName | value" mode="rng2srng:step7.10">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="ns" select="ancestor-or-self::*[@ns][1]/@ns"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.11 QNames                                                     -->
  <!-- =================================================================== -->
  <!--
    For any name element containing a prefix, the prefix is removed and an ns attribute is added replacing any
    existing ns attribute. The value of the added ns attribute is the value to which the namespace map of the context
    of the name element maps the prefix. The context shall have a mapping for the prefix.
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.11" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.11">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="name[contains(., ':')]" mode="rng2srng:step7.11">
    <xsl:variable name="prefix" select="substring-before(., ':')" as="xs:string"/>
    <name>
      <xsl:attribute name="ns">
        <xsl:for-each select="namespace::*">
          <xsl:if test="name() = $prefix">
            <xsl:value-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:value-of select="substring-after(., ':')"/>
    </name>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.12 div element                                                -->
  <!-- =================================================================== -->
  <!--
    Each div element is replaced by its children.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.12" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.12">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="div" mode="rng2srng:step7.12">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.13 Number of child elements                                   -->
  <!-- =================================================================== -->
  <!--    
    A define, oneOrMore, zeroOrMore, optional, list or mixed element is transformed so that it has exactly one child
    element. If it has more than one child element, then its child elements are wrapped in a group element. Similarly,
    an element element is transformed so that it has exactly two child elements, the first being a name class and the
    second being a pattern. If it has more than two child elements, then the child elements other than the first are
    wrapped in a group element.
    A except element is transformed so that it has exactly one child element. If it has more than one child element,
    then its child elements are wrapped in a choice element.
    If an attribute element has only one child element (a name class), then a text element is added.
    A choice, group or interleave element is transformed so that it has exactly two child elements. If it has one child
    element, then it is replaced by its child element. If it has more than two child elements, then the first two child
    elements are combined into a new element with the same name as the parent element and with the first two child
    elements as its children. For example,
    <choice> p1 p2 p3 </choice>
    is transformed to
    <choice> <choice> p1 p2 </choice> p3 </choice>
    This reduces the number of child elements by one. The transformation is applied repeatedly until there are exactly
    two child elements.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.13" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.13">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template 
    match="define[count(*) > 1] | oneOrMore[count(*) > 1] | zeroOrMore[count(*) > 1] | 
    optional[count(*) > 1] | list[count(*) > 1] | mixed[count(*) > 1]"
    mode="rng2srng:step7.13">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="rng2srng:reduce7.13">
        <xsl:with-param name="node-name" select="'group'"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="except[count(*) > 1]" mode="rng2srng:step7.13">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="rng2srng:reduce7.13">
        <xsl:with-param name="node-name" select="'choice'"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="attribute[count(*) = 1]" mode="rng2srng:step7.13">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*" mode="#current"/>
      <text/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="element[count(*) > 2]" mode="rng2srng:step7.13">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*[1]" mode="#current"/>
      <xsl:call-template name="rng2srng:reduce7.13">
        <xsl:with-param name="left" select="*[4]"/>
        <xsl:with-param name="node-name" select="'group'"/>
        <xsl:with-param name="out">
          <group>
            <xsl:apply-templates select="*[2]" mode="#current"/>
            <xsl:apply-templates select="*[3]" mode="#current"/>
          </group>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="group[count(*) = 1] | choice[count(*) = 1] | interleave[count(*) = 1]" 
    mode="rng2srng:step7.13">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>
  
  <xsl:template name="rng2srng:reduce7.13" 
    match="group[count(*) > 2] | choice[count(*) > 2] | interleave[count(*) > 2]"
    mode="rng2srng:step7.13">
    <xsl:param name="left" select="*[3]"/>
    <xsl:param name="node-name" select="name()"/>
    <xsl:param name="out">
      <xsl:element name="{$node-name}">
        <xsl:apply-templates select="*[1]" mode="#current"/>
        <xsl:apply-templates select="*[2]" mode="#current"/>
      </xsl:element>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$left">
        <xsl:variable name="newOut">
          <xsl:element name="{$node-name}">
            <!--<xsl:message>[rng2srng][reduce7.13] with param node-name = <xsl:value-of select="$node-name"/></xsl:message>
            <xsl:comment>[rng2srng][reduce7.13] with param node-name = <xsl:value-of select="$node-name"/></xsl:comment>-->
            <xsl:copy-of select="$out"/>
            <xsl:apply-templates select="$left" mode="#current"/>
          </xsl:element>
        </xsl:variable>
        <xsl:call-template name="rng2srng:reduce7.13">
          <xsl:with-param name="left" select="$left/following-sibling::*[1]"/>
          <xsl:with-param name="out" select="$newOut"/>
          <xsl:with-param name="node-name" select="$node-name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$out"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.14 mixed element                                              -->
  <!-- =================================================================== -->
  <!--
    A mixed element is transformed into an interleaving with a text element:
    <mixed> p </mixed>
    is transformed into
    <interleave> p <text/> </interleave>
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.14" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.14">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mixed" mode="rng2srng:step7.14">
    <interleave>
      <xsl:apply-templates mode="#current"/>
      <text/>
    </interleave>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.15 optional element                                           -->
  <!-- =================================================================== -->
  <!--
    An optional element is transformed into a choice with empty:
    <optional> p </optional>
    s transformed into
    <choice> p <empty/> </choice>
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.15" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.15">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="optional" mode="rng2srng:step7.15">
    <choice>
      <xsl:apply-templates mode="#current"/>
      <empty/>
    </choice>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.16 zeroOrMore element                                         -->
  <!-- =================================================================== -->
  <!--
    A zeroOrMore element is transformed into a choice between oneOrMore and empty:
    <zeroOrMore> p </zeroOrMore>
    is transformed into
    <choice> <oneOrMore> p </oneOrMore> <empty/> </choice>
  -->
  
  <!--<xsl:mode name="rng2srng:step7.16" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.16">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="zeroOrMore" mode="rng2srng:step7.16">
    <choice>
      <oneOrMore>
        <xsl:apply-templates mode="#current"/>
      </oneOrMore>
      <empty/>
    </choice>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.17 Constraints                                                -->
  <!-- =================================================================== -->
  <!--
    In this rule, no transformation is performed, but various constraints are checked.
    NOTE 1 The constraints in this subclause, unlike the constraints specified in Clause 10, can be checked without resolving
    any ref elements, and are accordingly applied even to patterns that will disappear during later stages of simplification because
    they are not reachable (see 7.20) or because of notAllowed (see 7.21).
    An except element that is a child of an anyName element shall not have any anyName descendant elements. An
    except element that is a child of an nsName element shall not have any nsName or anyName descendant
    elements.
    A name element that occurs as the first child of an attribute element or as the descendant of the first child of an
    attribute element and that has an ns attribute with value equal to the empty string shall not have content equal to
    xmlns.
    A name or nsName element that occurs as the first child of an attribute element or as the descendant of the first
    child of an attribute element shall not have an ns attribute with value http://www.w3.org/2000/xmlns.
    NOTE 2 The W3C XML-Infoset defines the namespace URI of namespace declaration attributes to be http://www.w3.
    org/2000/xmlns.
    A data or value element shall be correct in its use of datatypes. Specifically, the type attribute shall identify a
    datatype within the datatype library identified by the value of the datatypeLibrary attribute. For a data element, the
    parameter list shall be one that is allowed by the datatype (see 9.3.8).
  -->
  
 <!-- <xsl:mode name="rng2srng:step7.17" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.17">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.18 combine attribute                                          -->
  <!-- =================================================================== -->
  <!--
    For each grammar element, all define elements with the same name are combined together. For any name, there
    shall not be more than one define element with that name that does not have a combine attribute. For any name,
    if there is a define element with that name that has a combine attribute with the value choice, then there shall not
    also be a define element with that name that has a combine attribute with the value interleave. Thus, for any
    name, if there is more than one define element with that name, then there is a unique value for the combine
    attribute for that name. After determining this unique value, the combine attributes are removed. A pair of
    definitions
    <define name="n">
        p1
    </define>
    <define name="n">
       p2
    </define>
    is combined into
    <define name="n">
    <c>
       p1
       p2
    </c>
    </define>
    where c is the value of the combine attribute. Pairs of definitions are combined until there is exactly one define
    element for each name.
    Similarly, for each grammar element all start elements are combined together. There shall not be more than one
    start element that does not have a combine attribute. If there is a start element that has a combine attribute with
    the value choice, there shall not also be a start element that has a combine attribute with the value interleave.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.18" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.18">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@combine" mode="rng2srng:step7.18"/>
  
  <xsl:template match="start[preceding-sibling::start]|define[@name=preceding-sibling::define/@name]"
    mode="rng2srng:step7.18"/>
  
  <xsl:template match="start[not(preceding-sibling::start) and following-sibling::start]"
    mode="rng2srng:step7.18">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="rng2srng:start7.18"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="rng2srng:start7.18">
    <xsl:param name="left" select="following-sibling::start[2]"/>
    <xsl:param name="node-name" select="parent::*/start/@combine"/>
    <xsl:param name="out">
      <xsl:element name="{$node-name}">
        <xsl:apply-templates select="*" mode="rng2srng:step7.18"/>
        <xsl:apply-templates select="following-sibling::start[1]/*" mode="rng2srng:step7.18"/>
      </xsl:element>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$left/*">
        <xsl:variable name="newOut">
          <xsl:element name="{$node-name}">
            <xsl:copy-of select="$out"/>
            <xsl:apply-templates select="$left/*" mode="rng2srng:step7.18"/>
          </xsl:element>
        </xsl:variable>
        <xsl:call-template name="rng2srng:start7.18">
          <xsl:with-param name="left" select="$left/following-sibling::start[1]"/>
          <xsl:with-param name="node-name" select="$node-name"/>
          <xsl:with-param name="out" select="$newOut"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$out"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="define[not(@name=preceding-sibling::define/@name) and @name=following-sibling::define/@name]"
    mode="rng2srng:step7.18">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="rng2srng:define7.18"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="rng2srng:define7.18">
    <xsl:param name="left" select="following-sibling::define[@name=current()/@name][2]"/>
    <xsl:param name="node-name" select="parent::*/define[@name=current()/@name]/@combine"/>
    <xsl:param name="out">
      <xsl:element name="{$node-name}">
        <xsl:apply-templates select="*" mode="rng2srng:step7.18"/>
        <xsl:apply-templates select="following-sibling::define[@name=current()/@name][1]/*" mode="rng2srng:step7.18"/>
      </xsl:element>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$left/*">
        <xsl:variable name="newOut">
          <xsl:element name="{$node-name}">
            <xsl:copy-of select="$out"/>
            <xsl:apply-templates select="$left/*" mode="rng2srng:step7.18"/>
          </xsl:element>
        </xsl:variable>
        <xsl:call-template name="rng2srng:define7.18">
          <xsl:with-param name="left" select="$left/following-sibling::define[@name=current()/@name][1]"/>
          <xsl:with-param name="node-name" select="$node-name"/>
          <xsl:with-param name="out" select="$newOut"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$out"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.19 grammar element                                            -->
  <!-- =================================================================== -->
  <!--
    In this rule, the schema is transformed so that its top-level element is grammar and so that it has no other
    grammar elements.
    Define the in-scope grammar for an element to be the nearest ancestor grammar element. A ref element refers to
    a define element if the value of their name attributes is the same and their in-scope grammars are the same. A
    parentRef element refers to a define element if the value of their name attributes is the same and the in-scope
    grammar of the in-scope grammar of the parentRef element is the same as the in-scope grammar of the define
    element. Every ref or parentRef element shall refer to a define element. A grammar shall have a start child
    element.
    First, transform the top-level pattern p into <grammar><start>p</start></grammar>. Next, rename define
    elements so that no two define elements anywhere in the schema have the same name. To rename a define
    element, change the value of its name attribute and change the value of the name attribute of all ref and
    parentRef elements that refer to that define element. Next, move all define elements to be children of the top-level
    grammar element, replace each nested grammar element by the child of its start element and rename each
    parentRef element to ref.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.19" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.19">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/grammar" mode="rng2srng:step7.19">
    <grammar>
      <xsl:apply-templates mode="#current"/>
      <xsl:apply-templates select="//define" mode="rng2srng:step7.19-define"/>
    </grammar>
  </xsl:template>
  
  <xsl:template match="/*[not(self::grammar)]" mode="rng2srng:step7.19">
    <grammar>
      <start>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </start>
    </grammar>
  </xsl:template>
  
  <xsl:template match="define|define/@name|ref/@name|parentRef/@name" mode="rng2srng:step7.19"/>
  
  <xsl:template match="define" mode="rng2srng:step7.19-define">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="name">
        <xsl:value-of select="concat(@name, '-', generate-id())"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="rng2srng:step7.19"/>
      <xsl:apply-templates mode="rng2srng:step7.19"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="grammar" mode="rng2srng:step7.19">
    <xsl:apply-templates select="start/*" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="ref" mode="rng2srng:step7.19">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="name" select="concat(@name, '-', generate-id(ancestor::grammar[1]/define[@name=current()/@name]))"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="rng2srng:step7.19" match="parentRef">
    <ref>
      <xsl:attribute name="name" select="concat(@name, '-', generate-id(ancestor::grammar[2]/define[@name=current()/@name]))"/>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </ref>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.20 define and ref elements                                    -->
  <!-- =================================================================== -->
  <!--
    In this rule, the grammar is transformed so that every element element is the child of a define element, and the
    child of every define element is an element element.
    First, remove any define element that is not reachable. A define element is reachable if there is reachable ref
    element referring to it. A ref element is reachable if it is the descendant of the start element or of a reachable
    define element. Now, for each element element that is not the child of a define element, add a define element to
    the grammar element, and replace the element element by a ref element referring to the added define element.
    The value of the name attribute of the added define element shall be different from value of the name attribute of
    all other define elements. The child of the added define element is the element element.
    Define a ref element to be expandable if it refers to a define element whose child is not an element element. For
    each ref element that is expandable and is a descendant of a start element or an element element, expand it by
    replacing the ref element by the child of the define element to which it refers and then recursively expanding any
    expandable ref elements in this replacement. This shall not result in a loop. In other words expanding the
    replacement of a ref element having a name with value n shall not require the expansion of ref element also
    having a name with value n. Finally, remove any define element whose child is not an element element.
  -->
  
  <!--<xsl:mode name="rng2srng:step7.20" on-no-match="shallow-copy"/>-->
  <xsl:template match="node() | @*" mode="rng2srng:step7.20">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/grammar" mode="rng2srng:step7.20">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
      <xsl:apply-templates select="//element[not(parent::define)]" mode="rng2srng:step7.20-define"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Note : new mode (adding "define" in the mode name) : a way to indirectly "move" the definition-->
  <xsl:template match="element" mode="rng2srng:step7.20-define">
    <define name="__{(@name, name)[1]}-elt-{generate-id()}">
      <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*" mode="rng2srng:step7.20"/>
        <xsl:apply-templates mode="rng2srng:step7.20"/>
      </xsl:copy>
    </define>
  </xsl:template>
  
  <xsl:template match="element[not(parent::define)]" mode="rng2srng:step7.20">
    <ref name="__{(@name, name)[1]}-elt-{generate-id()}"/>
  </xsl:template>
  
  <xsl:template match="define[not(element)]" mode="rng2srng:step7.20"/>
  
  <xsl:template match="ref[@name=/*/define[not(element)]/@name]" mode="rng2srng:step7.20">
    <xsl:apply-templates select="/*/define[@name=current()/@name]/*" mode="#current"/>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.21 notAllowed element                                         -->
  <!-- =================================================================== -->
  <!--
    In this rule, the grammar is transformed so that a notAllowed element occurs only as the child of a start or
    element element. An attribute, list, group, interleave, or oneOrMore element that has a notAllowed child element
    is transformed into a notAllowed element. A choice element that has two notAllowed child elements is
    transformed into a notAllowed element. A choice element that has one notAllowed child element is transformed
    into its other child element. An except element that has a notAllowed child element is removed. The preceding
    transformations are applied repeatedly until none of them is applicable any more. Any define element that is no
    longer reachable is removed.
  -->
  
  <xsl:template match="* | text() | @*" mode="rng2srng:step7.21">
    <xsl:param name="updated" select="0"/>
    <xsl:copy copy-namespaces="no">
      <xsl:if test="$updated != 0">
        <xsl:attribute name="updated" select="$updated"/>
      </xsl:if>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@updated" mode="rng2srng:step7.21"/>
  
  <xsl:template match="/grammar" mode="rng2srng:step7.21">
    <xsl:variable name="thisIteration-rtf">
      <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:variable name="thisIteration" select="$thisIteration-rtf"/>
    <xsl:choose>
      <xsl:when test="$thisIteration//@updated|$thisIteration//processing-instruction('updated')">
        <xsl:apply-templates select="$thisIteration/grammar" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$thisIteration-rtf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="choice[count(notAllowed)=1]" mode="rng2srng:step7.21">
    <xsl:apply-templates select="*[not(self::notAllowed)]" mode="#current">
      <xsl:with-param name="updated" select="1"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="attribute[notAllowed] | list[notAllowed] | group[notAllowed] |  
                       interleave[notAllowed] | oneOrMore[notAllowed] | choice[count(notAllowed)=2]"
                       mode="rng2srng:step7.21">
    <notAllowed updated="1"/>
  </xsl:template>
  
  <xsl:template match="except[notAllowed]" mode="rng2srng:step7.21">
    <xsl:processing-instruction name="updated"/>
  </xsl:template>
  
  <!-- =================================================================== -->
  <!--     7.22 empty element                                              -->
  <!-- =================================================================== -->
  <!--
    In this rule, the grammar is transformed so that an empty element does not occur as a child of a group, interleave,
    or oneOrMore element or as the second child of a choice element. A group, interleave or choice element that has
    two empty child elements is transformed into an empty element. A group or interleave element that has one
    empty child element is transformed into its other child element. A choice element whose second child element is
    an empty element is transformed by interchanging its two child elements. A oneOrMore element that has an
    empty child element is transformed into an empty element. The preceding transformations are applied repeatedly
    until none of them is applicable any more.
  -->
 
  <xsl:template match="* | text() | @*" mode="rng2srng:step7.22">
    <xsl:param name="updated" select="0"/>
    <xsl:copy copy-namespaces="no">
      <xsl:if test="$updated != 0">
        <xsl:attribute name="updated" select="$updated"/>
      </xsl:if>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@updated" mode="rng2srng:step7.22"/>
  
  <xsl:template match="/grammar" mode="rng2srng:step7.22">
    <xsl:variable name="thisIteration-rtf">
      <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:variable name="thisIteration" select="$thisIteration-rtf"/>
    <xsl:choose>
      <xsl:when test="$thisIteration//@updated">
        <xsl:apply-templates select="$thisIteration/grammar" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$thisIteration-rtf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="choice[*[1][not(self::empty)] and *[2][self::empty]]" mode="rng2srng:step7.22">
    <xsl:copy copy-namespaces="no">
      <xsl:attribute name="updated" select="'1'"/>
      <xsl:apply-templates select="*[2]"  mode="#current"/>
      <xsl:apply-templates select="*[1]"  mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="group[count(empty)=1] | interleave[count(empty)=1]" mode="rng2srng:step7.22">
    <xsl:apply-templates select="*[not(self::empty)]" mode="#current">
      <xsl:with-param name="updated" select="1"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="group[count(empty)=2] | interleave[count(empty)=2] | choice[count(empty)=2] | oneOrMore[empty]" mode="rng2srng:step7.22">
    <empty updated="1"/>
  </xsl:template>

</xsl:stylesheet>