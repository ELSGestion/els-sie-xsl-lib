<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:rng="http://relaxng.org/ns/structure/1.0"
	xmlns:els="http://els.eu/ns/els"
	xmlns="http://relaxng.org/ns/structure/1.0"
	xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="els-common.xsl"/>
	
	<xsl:key name="rng:getDefineByName" match="define" use="@name"/>
	<xsl:key name="rng:getRefByName" match="ref" use="@name"/>
	
	<xsl:function name="rng:getRootNamespaceUri" as="xs:string">
		<xsl:param name="grammar" as="element(rng:grammar)"/>
		<xsl:value-of select="(rng:getDefine($grammar/start/ref[1])/element/ancestor-or-self::*[@ns][1]/@ns, $grammar/descendant-or-self::*[@ns][last()])[1]"/>
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
		<xsl:sequence select="rng:getSRNGdataModelReccurse(rng:getDefine($grammar/start/ref[1])/element[1], string-join($xpath.tokenized[position() gt 2], '/'))"/>
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
	
</xsl:stylesheet>