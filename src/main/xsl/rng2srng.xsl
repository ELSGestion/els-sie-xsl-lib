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
J'ai laissé xmlns:nsp="namespace_declaration" en tête de fichier (c’est utilisé plus tard dans un template),
car je voulais voir si ça pouvait nous être utile (en remplaçant nsp par xfe par exemple), 
mais je n’ai pas eu le temps de tester, donc tu peux sans doute virer la déclaration et les deux endroits où ça figure dans le code.
Pour bien comprendre à quoi correspond chaque step, j’ai mis en commentaire la spec iso.
J’ai corrigé un bug dans le step7.9 et simplifié certains matches en tenant compte des facilités de xslt 3.0 
Je comptais simplifier l’étape de renommage des steps 7.19 et 7.20 qui est un peu en « brute force » par emploi de generate-id() 
(j’ai dans un autre fichier de test du code xsl qui sort a peu près ce que sort jing, mais je n’ai pas eu le temps de l’adapter pour simplification.xsl)-->


<xsl:stylesheet 
  xmlns="http://relaxng.org/ns/structure/1.0"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xfe="http://els.eu/ns/xmlfirst/xmlEditor"
  xmlns:nsp="namespace_declaration"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
  version="3.0">
  
  <xsl:output method="xml" indent="yes"/>
  
  <!-- ******************************************************************* -->
  <!--                           MAIN                                      -->
  <!-- ******************************************************************* -->
  
  <xsl:template match="/">
    <xsl:call-template name="apply-steps">
      <xsl:with-param name="input" select="."/>
      <xsl:with-param name="step" select="2"/>
      <xsl:with-param name="last-step" select="22"/>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template name="apply-steps">
    <xsl:param name="input"/>
    <xsl:param name="step" select="2"/>
    <xsl:param name="last-step" select="22"/>
    <xsl:message>Simplification called at step <xsl:value-of select="$step"/></xsl:message>
    <xsl:variable name="output">
      <xsl:choose>
        <!-- un gros switch puisque XSLT n'accepte pas les modes dynamiques -->
        <xsl:when test="$step &lt; 2" ><xsl:message terminate="yes">Valeur de step incorrecte: <xsl:value-of select="$step"/></xsl:message></xsl:when>
        <xsl:when test="$step=2" ><xsl:apply-templates select="$input" mode="step7.2" /></xsl:when>
        <xsl:when test="$step=3" ><xsl:apply-templates select="$input" mode="step7.3" /></xsl:when>
        <xsl:when test="$step=4" ><xsl:apply-templates select="$input" mode="step7.4" /></xsl:when>
        <xsl:when test="$step=5" ><xsl:apply-templates select="$input" mode="step7.5" /></xsl:when>
        <xsl:when test="$step=6" ><xsl:apply-templates select="$input" mode="step7.6" /></xsl:when>
        <xsl:when test="$step=7" ><xsl:apply-templates select="$input" mode="step7.7" /></xsl:when>
        <xsl:when test="$step=8" ><xsl:apply-templates select="$input" mode="step7.8" /></xsl:when>
        <xsl:when test="$step=9" ><xsl:apply-templates select="$input" mode="step7.9" /></xsl:when>
        <xsl:when test="$step=10"><xsl:apply-templates select="$input" mode="step7.10"/></xsl:when>
        <xsl:when test="$step=11"><xsl:apply-templates select="$input" mode="step7.11"/></xsl:when>
        <xsl:when test="$step=12"><xsl:apply-templates select="$input" mode="step7.12"/></xsl:when>
        <xsl:when test="$step=13"><xsl:apply-templates select="$input" mode="step7.13"/></xsl:when>
        <xsl:when test="$step=14"><xsl:apply-templates select="$input" mode="step7.14"/></xsl:when>
        <xsl:when test="$step=15"><xsl:apply-templates select="$input" mode="step7.15"/></xsl:when>
        <xsl:when test="$step=16"><xsl:apply-templates select="$input" mode="step7.16"/></xsl:when>
        <xsl:when test="$step=17"><xsl:apply-templates select="$input" mode="step7.17"/></xsl:when>
        <xsl:when test="$step=18"><xsl:apply-templates select="$input" mode="step7.18"/></xsl:when>
        <xsl:when test="$step=19"><xsl:apply-templates select="$input" mode="step7.19"/></xsl:when>
        <xsl:when test="$step=20"><xsl:apply-templates select="$input" mode="step7.20"/></xsl:when>
        <xsl:when test="$step=21"><xsl:apply-templates select="$input" mode="step7.21"/></xsl:when>
        <xsl:when test="$step=22"><xsl:apply-templates select="$input" mode="step7.22"/></xsl:when>
        <xsl:when test="$step &gt; 22" ><xsl:message terminate="yes">Valeur de step incorrecte: <xsl:value-of select="$step"/></xsl:message></xsl:when>
        <xsl:otherwise><xsl:sequence select="$input"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:result-document href="{concat('log/step7.', $step, '.rng')}" method="xml" indent="yes">
      <xsl:copy-of select="$output"/>
    </xsl:result-document>
    <xsl:choose>
      <xsl:when test="$step &lt; $last-step">
        <xsl:call-template name="apply-steps">
          <xsl:with-param name="input" select="$output"/>
          <xsl:with-param name="step" select="$step + 1"/>
          <xsl:with-param name="last-step" select="$last-step"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$output"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- ******************************************************************* -->
  <!--                       ISO/IEC DIS 19757-2                           -->
  <!-- ******************************************************************* -->  
  <!--     7 Simplification                                                -->
  <!-- ******************************************************************* -->
  
  <!-- ******************************************************************* -->
  <!--     7.1 General                                                     -->
  <!-- ******************************************************************* -->
  <!-- 
    The full syntax given in the previous clause is transformed into a simpler syntax by applying the following
   transformation rules in order. The effect shall be as if each rule was applied to all elements in the schema before
   the next rule is applied. A transformation rule may also specify constraints that shall be satisfied by a correct
   schema. The transformation rules are applied at the data model level. Before the transformations are applied, the
   schema is parsed into an element in the data model.
  -->
  
  <!-- ******************************************************************* -->
  <!--     7.2 Annotations                                                 -->
  <!-- ******************************************************************* -->
  <!--
    Foreign attributes and elements are removed.
    NOTE It is safe to remove xml:base attributes at this stage because xml:base attributes are used in determining the [base
    URI] of an element information item, which is in turn used to construct the base URI of the context of an element. Thus, after a
    document has been parsed into an element in the data model, xml:base attributes can be discarded.
  -->
  
  <xsl:mode name="step7.2" on-no-match="deep-skip"/>
 
  <xsl:template mode="step7.2" match="/|rng:*|nsp:*|text()|@*[namespace-uri()='']">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template> 
  
  <!-- ******************************************************************* -->
  <!--     7.3 Whitespace                                                  -->
  <!-- ******************************************************************* --> 
  <!--
    For each element other than value and param, each child that is a string containing only whitespace characters is
    removed.
    Leading and trailing whitespace characters are removed from the value of each name, type and combine attribute
    and from the content of each name element.
  -->
  
  <xsl:mode name="step7.3" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.3" match="text()[normalize-space(.)='' and not(parent::rng:param or parent::rng:value)]"/>
  
  <xsl:template mode="step7.3" match="@name|@type|@combine">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template mode="step7.3" match="rng:name/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.4 datatypeLibrary attribute                                   -->
  <!-- ******************************************************************* -->
  <!--
    The value of each datatypeLibary attribute is transformed by escaping disallowed characters as specified in
    Section 5.4 of W3C XLink.
    For any data or value element that does not have a datatypeLibrary attribute, a datatypeLibrary attribute is added.
    The value of the added datatypeLibrary attribute is the value of the datatypeLibrary attribute of the nearest
    ancestor element that has a datatypeLibrary attribute, or the empty string if there is no such ancestor. Then, any
    datatypeLibrary attribute that is on an element other than data or value is removed.
  -->
  
  <xsl:mode name="step7.4" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.4" match="@datatypeLibrary"/>
  
  <xsl:template mode="step7.4" match="rng:data|rng:value">
    <xsl:copy>
      <xsl:attribute name="datatypeLibrary">
        <xsl:value-of select="ancestor-or-self::*[@datatypeLibrary][1]/@datatypeLibrary"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.5 type attribute of value element                             -->
  <!-- ******************************************************************* -->
  <!--
    For any value element that does not have a type attribute, a type attribute is added with value token and the value
    of the datatypeLibrary attribute is changed to the empty string.
  -->
  
  <xsl:mode name="step7.5" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.5" match="rng:value[not(@type)]/@datatypeLibrary"/>
  
  <xsl:template mode="step7.5" match="rng:value[not(@type)]">
    <value type="token" datatypeLibrary="">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </value>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.6 href attribute                                              -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.6" on-no-match="shallow-copy"/>
  
  <!-- ******************************************************************* -->
  <!--     7.7 externalRef element                                         -->
  <!-- ******************************************************************* -->
  <!--
    An externalRef element is transformed as follows. An element is constructed using the URI reference that is the
    value of href attribute as specified in 7.6. This element shall match the syntax for pattern. The element is
    transformed by recursively applying the rules from this subclauses and from previous subclauses of this clause.
    This shall not result in a loop. In other words, the transformation of the referenced element shall not require the
    dereferencing of an externalRef attribute with an href attribute with the same value.
    Any ns attribute on the externalRef element is transferred to the referenced element if the referenced element
    does not already have an ns attribute. The externalRef element is then replaced by the referenced element.
  -->
  
  <xsl:mode name="step7.7" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.7" match="rng:externalRef">
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
  
  <!-- ******************************************************************* -->
  <!--     7.8 include element                                             -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.8" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.8" match="rng:include">
    <div>
      <xsl:copy-of select="@*[name() != 'href']"/>
      <xsl:copy-of select="*"/>
      <xsl:copy-of select="document(@href)/rng:grammar/rng:start[not(current()/rng:start)]"/>
      <xsl:copy-of select="document(@href)/rng:grammar/rng:define[not(@name = current()/rng:define/@name)]"/>
    </div>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.9 name attribute of element and attribute elements            -->
  <!-- ******************************************************************* -->
  <!--
    The name attribute on an element or attribute element is transformed into a name child element.
    If an attribute element has a name attribute but no ns attribute, then an ns="" attribute is added to the name child
    element.
  -->
  
  <xsl:mode name="step7.9" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.9" match="@name[parent::rng:element|parent::rng:attribute]"/>
  
  <!-- Correction d'un bug du code original: déplacement du xsl:if -->
  <xsl:template mode="step7.9" match="(rng:element|rng:attribute)[@name]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <name>
        <xsl:if test="self::rng:attribute and not(@ns)">
          <xsl:attribute name="ns"/>
        </xsl:if>
        <xsl:value-of select="@name"/>
      </name>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.10 ns attribute                                               -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.10" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.10" match="@ns"/>
  
  <xsl:template mode="step7.10" match="rng:name|rng:nsName|rng:value">
    <xsl:copy>
      <xsl:attribute name="ns">
        <xsl:value-of select="ancestor-or-self::*[@ns][1]/@ns"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.11 QNames                                                     -->
  <!-- ******************************************************************* -->
  <!--
    For any name element containing a prefix, the prefix is removed and an ns attribute is added replacing any
    existing ns attribute. The value of the added ns attribute is the value to which the namespace map of the context
    of the name element maps the prefix. The context shall have a mapping for the prefix.
  -->
  
  <xsl:mode name="step7.11" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.11" match="rng:name[contains(., ':')]">
    <xsl:variable name="prefix" select="substring-before(., ':')"/>
    <name>
      <xsl:attribute name="ns">
        <xsl:for-each select="ancestor-or-self::*[nsp:namespace]/nsp:namespace">
          <xsl:if test="current()/@prefix = $prefix">
            <xsl:value-of select="current()/@uri"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:value-of select="substring-after(., ':')"/>
    </name>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.12 div element                                                -->
  <!-- ******************************************************************* -->
  <!--
    Each div element is replaced by its children.
  -->
  
  <xsl:mode name="step7.12" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.12" match="rng:div">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.13 Number of child elements                                   -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.13" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.13" match="(rng:define|rng:oneOrMore|rng:zeroOrMore|rng:optional|rng:list|rng:mixed)[count(*)>1]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="reduce7.13">
        <xsl:with-param name="node-name" select="'group'"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.13" match="rng:except[count(*)>1]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="reduce7.13">
        <xsl:with-param name="node-name" select="'choice'"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.13" match="rng:attribute[count(*) =1]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*" mode="#current"/>
      <text/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.13" match="rng:element[count(*)>2]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="*[1]" mode="#current"/>
      <xsl:call-template name="reduce7.13">
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
  
  <xsl:template mode="step7.13" match="(rng:group|rng:choice|rng:interleave)[count(*)=1]">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>
  
  <xsl:template name="reduce7.13" mode="step7.13" match="(rng:group|rng:choice|rng:interleave)[count(*)>2]">
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
            <xsl:copy-of select="$out"/>
            <xsl:apply-templates select="$left" mode="#current"/>
          </xsl:element>
        </xsl:variable>
        <xsl:call-template name="reduce7.13">
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
  
  <!-- ******************************************************************* -->
  <!--     7.14 mixed element                                              -->
  <!-- ******************************************************************* -->
  <!--
    A mixed element is transformed into an interleaving with a text element:
    <mixed> p </mixed>
    is transformed into
    <interleave> p <text/> </interleave>
  -->
  
  <xsl:mode name="step7.14" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.14" match="rng:mixed">
    <interleave>
      <xsl:apply-templates mode="#current"/>
      <text/>
    </interleave>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.15 optional element                                           -->
  <!-- ******************************************************************* -->
  <!--
    An optional element is transformed into a choice with empty:
    <optional> p </optional>
    s transformed into
    <choice> p <empty/> </choice>
  -->
  
  <xsl:mode name="step7.15" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.15" match="rng:optional">
    <choice>
      <xsl:apply-templates mode="#current"/>
      <empty/>
    </choice>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.16 zeroOrMore element                                         -->
  <!-- ******************************************************************* -->
  <!--
    A zeroOrMore element is transformed into a choice between oneOrMore and empty:
    <zeroOrMore> p </zeroOrMore>
    is transformed into
    <choice> <oneOrMore> p </oneOrMore> <empty/> </choice>
  -->
  
  <xsl:mode name="step7.16" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.16" match="rng:zeroOrMore">
    <choice>
      <oneOrMore>
        <xsl:apply-templates mode="#current"/>
      </oneOrMore>
      <empty/>
    </choice>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.17 Constraints                                                -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.17" on-no-match="shallow-copy"/>
  
  <!-- ******************************************************************* -->
  <!--     7.18 combine attribute                                          -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.18" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.18" match="@combine"/>
  
  <xsl:template mode="step7.18" match="rng:start[preceding-sibling::rng:start]|rng:define[@name=preceding-sibling::rng:define/@name]"/>
  
  <xsl:template mode="step7.18" match="rng:start[not(preceding-sibling::rng:start) and following-sibling::rng:start]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="start7.18"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="start7.18">
    <xsl:param name="left" select="following-sibling::rng:start[2]"/>
    <xsl:param name="node-name" select="parent::*/rng:start/@combine"/>
    <xsl:param name="out">
      <xsl:element name="{$node-name}">
        <xsl:apply-templates select="*" mode="step7.18"/>
        <xsl:apply-templates select="following-sibling::rng:start[1]/*" mode="step7.18"/>
      </xsl:element>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$left/*">
        <xsl:variable name="newOut">
          <xsl:element name="{$node-name}">
            <xsl:copy-of select="$out"/>
            <xsl:apply-templates select="$left/*" mode="step7.18"/>
          </xsl:element>
        </xsl:variable>
        <xsl:call-template name="start7.18">
          <xsl:with-param name="left" select="$left/following-sibling::rng:start[1]"/>
          <xsl:with-param name="node-name" select="$node-name"/>
          <xsl:with-param name="out" select="$newOut"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$out"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="step7.18" match="rng:define[not(@name=preceding-sibling::rng:define/@name) and @name=following-sibling::rng:define/@name]">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:call-template name="define7.18"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="define7.18">
    <xsl:param name="left" select="following-sibling::rng:define[@name=current()/@name][2]"/>
    <xsl:param name="node-name" select="parent::*/rng:define[@name=current()/@name]/@combine"/>
    <xsl:param name="out">
      <xsl:element name="{$node-name}">
        <xsl:apply-templates select="*" mode="step7.18"/>
        <xsl:apply-templates select="following-sibling::rng:define[@name=current()/@name][1]/*" mode="step7.18"/>
      </xsl:element>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="$left/*">
        <xsl:variable name="newOut">
          <xsl:element name="{$node-name}">
            <xsl:copy-of select="$out"/>
            <xsl:apply-templates select="$left/*" mode="step7.18"/>
          </xsl:element>
        </xsl:variable>
        <xsl:call-template name="define7.18">
          <xsl:with-param name="left" select="$left/following-sibling::rng:define[@name=current()/@name][1]"/>
          <xsl:with-param name="node-name" select="$node-name"/>
          <xsl:with-param name="out" select="$newOut"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$out"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.19 grammar element                                            -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.19" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.19" match="/rng:grammar">
    <grammar>
      <xsl:apply-templates mode="#current"/>
      <xsl:apply-templates select="//rng:define" mode="step7.19-define"/>
    </grammar>
  </xsl:template>
  
  <xsl:template mode="step7.19" match="/*[not(self::rng:grammar)]">
    <grammar>
      <start>
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </start>
    </grammar>
  </xsl:template>
  
  <xsl:template mode="step7.19" match="rng:define|rng:define/@name|rng:ref/@name|rng:parentRef/@name"/>
  
  <xsl:template mode="step7.19-define" match="rng:define">
    <xsl:copy>
      <xsl:attribute name="name">
        <xsl:value-of select="concat(@name, '-', generate-id())"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="step7.19"/>
      <xsl:apply-templates mode="step7.19"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.19" match="rng:grammar">
    <xsl:apply-templates select="rng:start/*" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="step7.19" match="rng:ref">
    <xsl:copy>
      <xsl:attribute name="name">
        <xsl:value-of select="concat(@name, '-', generate-id(ancestor::rng:grammar[1]/rng:define[@name=current()/@name]))"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.19" match="rng:parentRef">
    <ref>
      <xsl:attribute name="name">
        <xsl:value-of select="concat(@name, '-', generate-id(ancestor::rng:grammar[2]/rng:define[@name=current()/@name]))"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </ref>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.20 define and ref elements                                    -->
  <!-- ******************************************************************* -->
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
  
  <xsl:mode name="step7.20" on-no-match="shallow-copy"/>
  
  <xsl:template mode="step7.20" match="/rng:grammar">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
      <xsl:apply-templates select="//rng:element[not(parent::rng:define)]" mode="step7.20-define"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.20-define" match="rng:element">
    <define name="__{rng:name}-elt-{generate-id()}">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="step7.20"/>
        <xsl:apply-templates mode="step7.20"/>
      </xsl:copy>
    </define>
  </xsl:template>
  
  <xsl:template mode="step7.20" match="rng:element[not(parent::rng:define)]">
    <ref name="__{rng:name}-elt-{generate-id()}"/>
  </xsl:template>
  
  <xsl:template mode="step7.20" match="rng:define[not(rng:element)]"/>
  
  <xsl:template mode="step7.20" match="rng:ref[@name=/*/rng:define[not(rng:element)]/@name]">
    <xsl:apply-templates select="/*/rng:define[@name=current()/@name]/*" mode="#current"/>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.21 notAllowed element                                         -->
  <!-- ******************************************************************* -->
  <!--
    In this rule, the grammar is transformed so that a notAllowed element occurs only as the child of a start or
    element element. An attribute, list, group, interleave, or oneOrMore element that has a notAllowed child element
    is transformed into a notAllowed element. A choice element that has two notAllowed child elements is
    transformed into a notAllowed element. A choice element that has one notAllowed child element is transformed
    into its other child element. An except element that has a notAllowed child element is removed. The preceding
    transformations are applied repeatedly until none of them is applicable any more. Any define element that is no
    longer reachable is removed.
  -->
  
  <xsl:template mode="step7.21" match="*|text()|@*">
    <xsl:param name="updated" select="0"/>
    <xsl:copy>
      <xsl:if test="$updated != 0">
        <xsl:attribute name="updated"><xsl:value-of select="$updated"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.21" match="@updated"/>
  
  <xsl:template mode="step7.21" match="/rng:grammar">
    <xsl:variable name="thisIteration-rtf">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:variable name="thisIteration" select="$thisIteration-rtf"/>
    <xsl:choose>
      <xsl:when test="$thisIteration//@updated|$thisIteration//processing-instruction('updated')">
        <xsl:apply-templates select="$thisIteration/rng:grammar" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$thisIteration-rtf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="step7.21" match="rng:choice[count(rng:notAllowed)=1]">
    <xsl:apply-templates select="*[not(self::rng:notAllowed)]" mode="#current">
      <xsl:with-param name="updated" select="1"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="step7.21" match="(rng:attribute|rng:list|rng:group|rng:interleave|rng:oneOrMore)[rng:notAllowed]|rng:choice[count(rng:notAllowed)=2]">
    <notAllowed updated="1"/>
  </xsl:template>
  
  <xsl:template mode="step7.21" match="rng:except[rng:notAllowed]">
    <xsl:processing-instruction name="updated"/>
  </xsl:template>
  
  <!-- ******************************************************************* -->
  <!--     7.22 empty element                                              -->
  <!-- ******************************************************************* -->
  <!--
    In this rule, the grammar is transformed so that an empty element does not occur as a child of a group, interleave,
    or oneOrMore element or as the second child of a choice element. A group, interleave or choice element that has
    two empty child elements is transformed into an empty element. A group or interleave element that has one
    empty child element is transformed into its other child element. A choice element whose second child element is
    an empty element is transformed by interchanging its two child elements. A oneOrMore element that has an
    empty child element is transformed into an empty element. The preceding transformations are applied repeatedly
    until none of them is applicable any more.
  -->
 
   <xsl:template mode="step7.22" match="*|text()|@*">
    <xsl:param name="updated" select="0"/>
    <xsl:copy>
      <xsl:if test="$updated != 0">
        <xsl:attribute name="updated"><xsl:value-of select="$updated"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.22"  match="@updated"/>
  
  <xsl:template  mode="step7.22" match="/rng:grammar">
    <xsl:variable name="thisIteration-rtf">
      <xsl:copy>
        <xsl:apply-templates select="@*" mode="#current"/>
        <xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:variable name="thisIteration" select="$thisIteration-rtf"/>
    <xsl:choose>
      <xsl:when test="$thisIteration//@updated">
        <xsl:apply-templates select="$thisIteration/rng:grammar" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$thisIteration-rtf"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="step7.22"  match="rng:choice[*[1][not(self::rng:empty)] and *[2][self::rng:empty]]">
    <xsl:copy>
      <xsl:attribute name="updated">1</xsl:attribute>
      <xsl:apply-templates select="*[2]"  mode="#current"/>
      <xsl:apply-templates select="*[1]"  mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="step7.22"  match="(rng:group|rng:interleave)[count(rng:empty)=1]">
    <xsl:apply-templates select="*[not(self::rng:empty)]" mode="#current">
      <xsl:with-param name="updated" select="1"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template mode="step7.22"  match="(rng:group|rng:interleave|rng:choice)[count(rng:empty)=2]|rng:oneOrMore[rng:empty]">
    <empty updated="1"/>
  </xsl:template>

</xsl:stylesheet>