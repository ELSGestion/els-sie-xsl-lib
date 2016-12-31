<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns="http://relaxng.org/ns/structure/1.0"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="els-common.xsl"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>XSLT functions/templates library to extract information or transform Relax NG schema</xd:p>
      <xd:p>The RNG schema provided should be simplified (cf. http://www.relaxng.org/spec-20011203.html), 
        there should be at least one element by define and one define by element.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--FIXME : adding a check on (s)rng format before proceding each step/function ?-->
  
  <xsl:key name="rng:getDefineByName" match="define" use="@name"/>
  <xsl:key name="rng:getRefByName" match="ref" use="@name"/>
  
  <xsl:function name="rng:getRootNamespaceUri" as="xs:string">
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:choose>
      <xsl:when test="$grammar/start/choice/ref">
        <xsl:value-of select="(rng:getDefine($grammar/start/choice/ref[1])/element/ancestor-or-self::*[@ns][1]/@ns, $grammar/descendant-or-self::*[@ns][last()])[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="(rng:getDefine($grammar/start/ref[1])/element/ancestor-or-self::*[@ns][1]/@ns, $grammar/descendant-or-self::*[@ns][last()])[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="rng:getDefine" as="element(define)*">
    <xsl:param name="ref" as="element(ref)"/>
    <xsl:sequence select="key('rng:getDefineByName', $ref/@name, $ref/root())"/>
  </xsl:function>
  
  <xsl:function name="rng:defineHasRefName" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <xsl:param name="refName" as="xs:string"/>
    <xsl:sequence select="count($define//ref[@name = $refName]) != 0"/>
  </xsl:function>
  
  <xsl:function name="rng:isInline" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <!--no parent (no ref) for root element--> 
    <xsl:param name="rngParent" as="element(element)?"/>
    <!--<xsl:variable name="ref" select="$rngParent//ref[rng:getDefine(.)/element is $rngElement]" as="element(ref)?"/>
    => FIXME : cette solution devrait être le bonne, on ne peut pas se baser sur le nom de l'élément comme ci-dessous!-->
    <xsl:variable name="ref" select="rng:getRef($rngParent, $rngElement/@name)" as="element(ref)?"/>
    <!--see http://relaxng.org/spec-20011203.html#IDA0FZR-->
    <!--
      2 possibilité : 
      - mixed qui est converti (srng) en interleave {pattern} text
      ex :
      <interleave>
        <text/>
        <zeroOrMore>
          <choice>
            <ref name="e"/>
            <ref name="ind"/>
      - une autre structure de type 
      ex : 
        <oneOrMore>
          <choice>
            <text/>
            <ref name="ITAL"/>-->
    <xsl:sequence select="exists($ref/ancestor::interleave/text) or exists($ref/parent::*/text)"/>
  </xsl:function>
  
  <xsl:function name="rng:isInlineOnly" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:variable name="rngDefine" select="$rngElement/parent::define" as="element(define)"/>
    <xsl:sequence 
      select="every $rngParent in $rngElement/root()//define//ref[@name = $rngDefine/@name]/ancestor::define/rng:element[1] 
      satisfies rng:isInline($rngElement, $rngParent)"/>
  </xsl:function>
  
  <xsl:function name="rng:isBlockOnly" as="xs:boolean">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:variable name="rngDefine" select="$rngElement/parent::define" as="element(define)"/>
    <xsl:sequence 
      select="every $rngParent in $rngElement/root()//define//ref[@name = $rngDefine/@name]/ancestor::define/rng:element[1] 
      satisfies not(rng:isInline($rngElement, $rngParent))"/>
  </xsl:function>
  
  <xsl:function name="rng:defineHasCircularRef" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <xsl:variable name="define.name" select="$define/@name" as="xs:string"/>
    <xsl:sequence select="exists($define//ref[@name = $define.name])"/>
  </xsl:function>
  
  <xsl:function name="rng:getSRNGdataModelFromXmlElement" as="element(rng:element)">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:sequence select="rng:getSRNGdataModelFromXpath(els:get-xpath($e, '',  false()), $grammar)"/>
  </xsl:function>
  
  <!--Attention cette fonction est gourmande, elle parcours tout le schema pour 1 élément xml-->
  <xsl:function name="rng:getSRNGdataModelFromXpath" as="element(rng:element)">
    <xsl:param name="xpath" as="xs:string"/> <!--attention xpath doit être absolu ici ! ("/a/b/c", pas de "//a" ou "b/c")-->
    <xsl:param name="grammar" as="element(rng:grammar)"/>
    <xsl:variable name="xpath.tokenized" select="tokenize($xpath, '/')" as="xs:string*"/>
    <xsl:variable name="xpath.rootName" select="$xpath.tokenized[2]" as="xs:string"/>
    <xsl:variable name="grammar.start" select="$grammar/start" as="element(rng:start)"/>
    <!--dans start on cherche la référence à xpath.rootName-->
    <xsl:variable name="rngRootRef" select="$grammar/start//ref[rng:getDefine(.)/element[1]/@name = $xpath.rootName]" as="element(rng:ref)?"/>
    <xsl:choose>
      <!--Il y en a une ref dans le start, tout va bien : on peut initialiser rng:getSRNGdataModelReccurse()-->
      <xsl:when test="count($rngRootRef) = 1">
        <xsl:sequence select="rng:getSRNGdataModelReccurse(rng:getDefine($rngRootRef)/element[1], string-join($xpath.tokenized[position() gt 2], '/'))"/>
      </xsl:when>
      <xsl:when test="count($rngRootRef) = 0">
        <xsl:message terminate="yes">[ERROR] Aucun rng:ref trouvé dans le start pour <xsl:value-of select="$xpath.rootName"/>, xpath=<xsl:value-of select="$xpath"/>, snrg uri : <xsl:value-of select="base-uri($grammar)"/> </xsl:message>
      </xsl:when>
    </xsl:choose>
    <!--<xsl:sequence select="rng:getSRNGdataModelReccurse(rng:getDefine($grammar/start/ref[1])/element[1], string-join($xpath.tokenized[position() gt 2], '/'))"/>-->
  </xsl:function>
  
  <!--Fonction "PRIVATE" utilisée uniquement pour résoudre rng:getSRNGdataModel()-->
  <xsl:function name="rng:getSRNGdataModelReccurse" as="element(rng:element)">
    <xsl:param name="rngParentElement" as="element(rng:element)"/> <!--<element name="a"/>-->
    <xsl:param name="xpathFromDataModel" as="xs:string"/> <!--(a)/b/c/d-->
    <xsl:message use-when="false()">rng:getSRNGdataModelReccurse(<xsl:value-of select="els:displayNode($rngParentElement)"/>, '<xsl:value-of select="$xpathFromDataModel"/>')</xsl:message>
    <xsl:variable name="xpathFromDataModel.tokenized" select="tokenize($xpathFromDataModel, '/')" as="xs:string*"/>
    <xsl:choose>
      <!--on a résolu le xpath, donc à l'étape précédente on était bon => rngParentElement-->
      <xsl:when test="count($xpathFromDataModel.tokenized) = 0">
        <xsl:sequence select="$rngParentElement"/>
      </xsl:when>
      <!--Sinon on appele la même fonction réccursivement-->
      <xsl:otherwise>
        <xsl:variable name="currentName" select="$xpathFromDataModel.tokenized[1]" as="xs:string"/>
        <!--Dans a je cherche la référence à b-->
        <xsl:variable name="rngRef" select="rng:getRef($rngParentElement, $currentName)" as="element(rng:ref)?"/>
        <xsl:choose>
          <!--Il y en a une ref, tout va bien : on continue avec <element name="b"> et xpath = c/d  -->
          <xsl:when test="count($rngRef) = 1">
            <xsl:sequence select="rng:getSRNGdataModelReccurse(rng:getDefine($rngRef[1])/element[1], string-join($xpathFromDataModel.tokenized[not(position() = 1)], '/'))"/>
          </xsl:when>
          <xsl:when test="count($rngRef) = 0">
            <xsl:message terminate="yes">[ERROR] Aucun rng:ref trouvé pour <xsl:value-of select="els:get-xpath($rngParentElement)"/>, xpath=<xsl:value-of select="$xpathFromDataModel"/>, currentName=<xsl:value-of select="$currentName"/>, snrg uri : <xsl:value-of select="base-uri($rngParentElement)"/> </xsl:message>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="rng:getRef" as="element(rng:ref)?">
    <xsl:param name="rngElement" as="element(rng:element)"/>
    <xsl:param name="refName" as="xs:string"/>
    <xsl:variable name="rngRef" select="$rngElement//ref[rng:getDefine(.)[element[1]/@name = $refName]]" as="element(rng:ref)*"/>
    <xsl:if test="count($rngRef) gt 1">
      <xsl:message>[WARNING][rng:getRef()] <xsl:value-of select="count($rngRef)"/> rng:ref name="<xsl:value-of select="$refName"/>" trouvés dans <xsl:value-of select="els:get-xpath($rngElement)"/>, on a pris la 1ere</xsl:message>
      <!--FIXME : ce cas de figure est tout à fait possible quand il y a un choose, ou un mixed, il faut pour cela parser le XML en même temps pour savoir où on est
      => utiliser une vraie librairie RNG !-->
    </xsl:if>
    <xsl:sequence select="($rngRef)[1]"/>
  </xsl:function>
  
  <!--========== rng:clean ==========--> 
  <!--nettoyage du rng (après manip manuelle dessus) pour le garder valide on espère-->
  
  <!--Attention le / est très important, on initie rng:clean sur un document-node(), mais ensuite l'apply-template ci-dessous ne repasse pas par là 
  car on travail avec element(grammar) ci-dessous, ce qui évite une boucle récursive infinie-->
  <xsl:template match="/grammar" mode="rng:clean">
    <xsl:variable name="step1.deleteOrphansDefine" as="element(grammar)">
      <xsl:call-template name="rng:deleteOrphansDefine">
        <xsl:with-param name="tree" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="step2.deleteEmptyStructuralInstructionInDataModel" as="element(grammar)">
      <xsl:call-template name="rng:deleteEmptyStructuralInstructionInDataModel">
        <xsl:with-param name="tree" select="$step1.deleteOrphansDefine"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:apply-templates select="$step2.deleteEmptyStructuralInstructionInDataModel" mode="#current"/>
  </xsl:template>
  
  <!--Déduplication sur ref dans les choice -->
  <xsl:template match="choice/ref" mode="rng:clean">
    <xsl:if test="not(preceding-sibling::ref[@name = current()/@name])">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <!--Déduplication sur element dans les choice -->
  <xsl:template match="choice/element" mode="rng:clean">
    <xsl:if test="not(preceding-sibling::element[deep-equal(., current())])">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>
  
  <!--=== mode rng:deleteOrphansDefine ===-->
  <!--Suppression des <define> orphelins-->
  
  <!--Un template nommé pour initier la récursivité, puis passage dans un mode du même nom-->
  <xsl:template name="rng:deleteOrphansDefine">
    <xsl:param name="tree" required="yes" as="element()"/>
    <xsl:param name="iteration" select="1" />
    <xsl:message>[DEBUG][rng:deleteOrphansDefine] iteration = <xsl:value-of select="$iteration"/></xsl:message>
    <xsl:variable name="tree.new" as="element()">
      <xsl:apply-templates select="$tree" mode="rng:deleteOrphansDefine"/>
    </xsl:variable>
    <xsl:choose>
      <!--Il reste des éléments vide après traitement, on repasse le traitement-->
      <xsl:when test="$tree.new//define[rng:isOrphanDefine(.)]">
        <xsl:call-template name="rng:deleteOrphansDefine">
          <xsl:with-param name="tree" select="$tree.new"/>
          <xsl:with-param name="iteration" select="$iteration + 1"/>
        </xsl:call-template>
      </xsl:when>
      <!--sinon, on renvoi l'arbre final-->
      <xsl:otherwise>
        <xsl:sequence select="$tree.new"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="define[rng:isOrphanDefine(.)]" mode="rng:deleteOrphansDefine">
    <xsl:message>[INFO][deleteOrphansDefine] Delete <xsl:value-of select="els:displayNode(.)"/></xsl:message>
  </xsl:template>
  
  <!--FIXME : ça ne permets pas de supprimer A qui reférence B qui référence A
  => il faudrait revoir l'algo global => partit du start et aller jusqu'à la fin du modèle en suivant les ref
  En déduire une liste de define utiles et supprimer tous les autres !-->
  <xsl:function name="rng:isOrphanDefine" as="xs:boolean">
    <xsl:param name="define" as="element(define)"/>
    <!--Le 3e arg de key() doit $etre un document-node() : on force la chose puisque tree est un element()-->
    <xsl:variable name="virtual.root" as="document-node()">
      <xsl:document>
        <xsl:sequence select="$define/root()"/>
      </xsl:document>
    </xsl:variable>
    <!--Il n'existe pas de référence à ce define qui ne soit pas déjà dans ce define (cas de ref circulaire)-->
    <xsl:sequence select="not(exists(
      key('rng:getRefByName', $define/@name, $virtual.root)[not(ancestor::*[. is $define])]
      ))"/>
  </xsl:function>
  
  <!--=== mode rng:deleteEmptyStructuralInstructionInDataModel ===-->
  
  <!--Un template nommé pour initier la récursivité, puis passage dans un mode du même nom-->
  <xsl:template name="rng:deleteEmptyStructuralInstructionInDataModel">
    <xsl:param name="tree" required="yes" as="element()"/>
    <xsl:param name="iteration" select="1" />
    <!--<xsl:message>[DEBUG][rng:deleteEmptyStructuralInstructionInDataModel] iteration = <xsl:value-of select="$iteration"/></xsl:message>-->
    <xsl:variable name="tree.new" as="element()">
      <xsl:apply-templates select="$tree" mode="rng:deleteEmptyStructuralInstructionInDataModel"/>
    </xsl:variable>
    <xsl:choose>
      <!--Il reste des éléments vide après traitement, on repasse le traitement-->
      <xsl:when test="$tree.new//*[rng:isEmptyStructuralInstructionInDataModel(.)]">
        <xsl:call-template name="rng:deleteEmptyStructuralInstructionInDataModel">
          <xsl:with-param name="tree" select="$tree.new"/>
          <xsl:with-param name="iteration" select="$iteration + 1"/>
        </xsl:call-template>
      </xsl:when>
      <!--sinon, on renvoi l'arbre final-->
      <xsl:otherwise>
        <xsl:sequence select="$tree.new"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*[rng:isEmptyStructuralInstructionInDataModel(.)]" mode="rng:deleteEmptyStructuralInstructionInDataModel">
    <!--<xsl:message>[INFO] Delete <xsl:value-of select="els:displayNode(.)"/></xsl:message>-->
  </xsl:template>
  
  <!-- === FONCTIONS utile au mode rng:clean === -->
  
  <!--Tous les éléments qui servent à construire le data model, à l'exclusion de ce qui forme le contenu (<attribute/>, <element/>, <text/>, ...)
  FIXME : quid des ref ?-->
  <xsl:function name="rng:isStructuralInstructionInDataModel" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="local-name($e) = ('optional', 'zeroOrMore', 'oneOrMore', 'group', 'interleave', 'choice')"/>
  </xsl:function>
  
  <xsl:function name="rng:isEmptyStructuralInstructionInDataModel" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="rng:isStructuralInstructionInDataModel($e) and not($e/*)"/>
  </xsl:function>
  
  <!--copie par défaut dans le mode rng:clean-->
  <xsl:template match="node() | @*" mode="rng:clean rng:deleteEmptyStructuralInstructionInDataModel rng:deleteOrphansDefine">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Réordonne les define d'un fichier RNG simplifié, en se basant sur le nom de l'élément</xd:p>
    </xd:desc>
  </xd:doc>
  <!--FIXME : impossible d'appeler cette xsl avec initial mode = rng:reorder avec saxon
  il semble que le nom du mode ne peut pas être préfixé-->
  
  <xsl:param name="rng:reorder_renameDefineRef" select="true()" as="xs:boolean"/>
  
  <xsl:template match="/grammar" mode="rng:reorder rng_reorder">
    <xsl:message>[INFO] rng:reorder sur <xsl:value-of select="local-name()"/></xsl:message>
    <xsl:variable name="rng_reorder_step1" as="document-node()">
      <xsl:document>
        <xsl:copy copy-namespaces="yes">
          <xsl:namespace name="xfe">http://www.lefebvre-sarrut.eu/ns/xmlfirst/xmlEditor</xsl:namespace>
          <xsl:apply-templates select="@*" mode="#current"/>
          <xsl:apply-templates select="start" mode="#current"/>
          <xsl:apply-templates select="define" mode="#current">
            <xsl:sort select="concat(element[1]/@name | element[1]/name/text(), '_', element[1]//attribute[@name = 'class']/value/text())"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:document>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rng:reorder_renameDefineRef">
        <xsl:apply-templates select="$rng_reorder_step1" mode="rng:renameDefineAndRefByElementNameAndOrder"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$rng_reorder_step1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="define" mode="rng:reorder rng_reorder">
    <xsl:message use-when="false()">[INFO][rng:reorder] define "<xsl:value-of select="concat(element[1]/@name | element[1]/name/text(), '_', element[1]//attribute[@name = 'class']/value/text())"/>"</xsl:message>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="rng:reorder rng_reorder">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--tmp pour diff-->
  <!--<xsl:template match="@datatypeLibrary" mode="rng:reorder rng_reorder"/>
  <xsl:template match="@ns" mode="rng:reorder rng_reorder"/>-->
  <!--<xsl:template match="group | optional" mode="rng:reorder rng_reorder">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Rename define and ref by element name and order in the rng document</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="/grammar" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:message>[INFO] rng:renameDefineAndRefByElementNameAndOrder sur <xsl:value-of select="local-name()"/></xsl:message>
    <xsl:next-match/>
  </xsl:template>
  
  <xsl:template match="define/@name" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:variable name="define" select="parent::define" as="element()"/>
    <xsl:variable name="elementName" select="($define/element[1]/@name, $define/element[1]/name)[1]" as="xs:string"/>
    <xsl:variable name="count" select="count($define/preceding-sibling::define[(element[1]/@name, element[1]/name)[1] = $elementName])" as="xs:integer"/>
    <xsl:attribute name="{name(.)}">
      <xsl:choose>
        <xsl:when test="$count = 0">
          <xsl:sequence select="$elementName"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="concat($elementName, '_', $count + 1)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template match="ref/@name" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:variable name="ref" select="parent::ref" as="element()"/>
    <xsl:apply-templates select="rng:getDefine($ref)/@name" mode="#current"/>
  </xsl:template>
  
  <!-- FIXME mricaud : version gmarichal, je n'arrive pas à la faire fonctionner (version oXygen ?)--> 
  <!--<xsl:variable name="xfe:jingRenameMapping" as="map(xs:string, xs:string?)">
    <xsl:map>
      <xsl:for-each-group select="//define/element" group-by="@name">
        <xsl:for-each select="current-group()">
          <xsl:choose>
            <xsl:when test="count(current-group()) &gt; 1">
              <xsl:map-entry key="../@name" select="concat(xs:string(@name), '_', position())"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:map-entry key="../@name" select="xs:string(@name)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each-group>
    </xsl:map>
  </xsl:variable>
  
  <xsl:template match="define|ref" mode="xfe:adaptSrng">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="map:contains($xfe:jingRenameMapping, @name)">
          <xsl:message>WHEN</xsl:message>
          <xsl:attribute name='name' select="map:get($xfe:jingRenameMapping, @name)"/>
          <xsl:apply-templates select="@* except @name|node()" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>OTW</xsl:message>
          <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:template match="node() | @*" mode="rng:renameDefineAndRefByElementNameAndOrder">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>