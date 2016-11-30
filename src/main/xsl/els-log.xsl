<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:functx="http://www.functx.com" 
	xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
	exclude-result-prefixes="#all"
	version="2.0">
	
	
  <xsl:import href="els-common.xsl"/>
  
  
  <xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p>Librairie de fonctions / templates pour la gestion des logs aux ELS.</xd:p>
		</xd:desc>
	</xd:doc>
  
  
  <!--===================================================	-->
  <!--								PARAMS															-->
  <!--===================================================	-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Niveau à partir duquel les logs sont</xd:p>
      <xd:ul>
        <xd:li>affichés sur la console via un xsl:message (log.level.alert)</xd:li>
        <xd:li>génèrés via un élément "log" dans le document source (log.level.markup)</xd:li>
      </xd:ul>
      <xd:p>La valeur de ces paramètres est à définir dans la XSLT utilisant les logs</xd:p>
      <xd:p>Si ce n'est pas le cas, ce sont les valeurs des paramêtres alert et markup dans la f° de log qui définissent seuls la génération des logs. </xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="els:log.level.alert" as="xs:string?" required="no"/>
  <xsl:param name="els:log.level.markup" as="xs:string?" required="no"/>


  <!--===================================================	-->
  <!--							LOG and MESSAGES											-->
  <!--===================================================	-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Log des erreurs ou warning xslt</xd:p>
    </xd:desc>
    <xd:param name="xsltName">Nom de la xslt appelante. Typiquement : "<xsl:variable name="xsltName" select="tokenize(static-base-uri(),'/')[last()]"/>"</xd:param>
    <xd:param name="level">Level du log : (info | debug | warning | error | fatal | fixme | todo)</xd:param>
    <xd:param name="code">Code erreur pour s'y retrouver plus facilement (peut servir à filter les erreurs "dpm / dsi" ainsi qu'a faire des requête xpath pour compter le nombre d'erreurs d'un code spécifique</xd:param>
    <xd:param name="alert">Détermine si on génère un xsl:message ou pas</xd:param>
    <xd:param name="markup">Détermine si on génère un élément "log" en sortie ou pas</xd:param>
    <xd:param name="description">Description de l'erreur</xd:param>
    <xd:param name="xpath">XPath spécifique. Si omis le xpath est calculé en fonction du contexte courant</xd:param>
    <xd:param name="base-uri">URI du fichier pour lequel le log est créé</xd:param>
  </xd:doc>
  <xsl:template name="els:log">
    <xsl:param name="xsltName" as="xs:string" required="yes"/>
    <xsl:param name="level" select="'info'" as="xs:string"/>
    <xsl:param name="code" select="'undefined'" as="xs:string"/>
    <xsl:param name="alert"
               select="if ($level = 'error' or $level = 'fatal') then (true()) else (false())"
               as="xs:boolean"/>
    <xsl:param name="markup" select="true()" as="xs:boolean"/>
    <xsl:param name="description" as="item()*"/>
    <xsl:param name="logXpath" select="false()" as="xs:boolean"/>
    <xsl:param name="xpathContext" select="." as="item()"/>
    <xsl:param name="xpath" as="xs:string?" required="no"/>
    <xsl:param name="base-uri" as="xs:string?" required="no"/>
    <!--Si $logXpath=false() pas la peine de risquer une erreur sur un $xpathContext "." qui pourrait ne pas exister (dans un analyze-string par exemple "." est un string pas un context xpath)-->
    <xsl:variable name="xpath"
                  select=" if (exists($xpath)) then ($xpath) else (if ($logXpath) then (els:get-xpath($xpathContext)) else (''))"
                  as="xs:string"/>
    
    <!--checking param-->
    <xsl:variable name="levelValues"
      select="('info','debug','warning','error', 'fatal','fixme','todo')" as="xs:string*"/>
    <xsl:if test="not(some $levelName in $levelValues satisfies $level = $levelName)">
      <xsl:call-template name="els:log">
        <!--<xsl:with-param name="xsltName" select="tokenize(static-base-uri(),'/')[last()]"/> ne fonctionne pas en java pour hervé Rolland -->
        <xsl:with-param name="xsltName" select="'eflCommon.xsl'"/>
        <xsl:with-param name="alert" select="true()"/>
        <xsl:with-param name="markup" select="false()"/>
        <xsl:with-param name="description" xml:space="preserve">Appel du template log avec valeur du parametre level = "<xsl:value-of select="$level"/>" non autorisé</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
    <!--logging par xsl:message si $alert (c'est-à-dire explicitement demandé ou level approprié) et niveau de log configuré pour être traité -->
    <xsl:variable name="alertWithLevelToProcess"
                  select="if (exists($els:log.level.alert)) 
                          then (els:isLogToBeProcessed($level, $els:log.level.alert)) 
                          else ($alert)"/>
    <xsl:if test="$alertWithLevelToProcess">
      <xsl:variable name="msg">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="upper-case($level)"/>
        <xsl:text>][</xsl:text>
        <xsl:if test="exists($base-uri)">
          <xsl:value-of select="concat(tokenize($base-uri, '/')[last()], ' / ')"/>
        </xsl:if>
        <xsl:value-of select="$xsltName"/>
        <xsl:text>][</xsl:text>
        <xsl:value-of select="$code"/>
        <xsl:text>] </xsl:text>
        <!--suppression des accents car mal géré au niveau des invites de commande-->
        <xsl:sequence select="els:normalize-no-diacritic($description)"/>
        <xsl:if test="$logXpath">
          <xsl:text>&#10; xpath=</xsl:text>
          <xsl:value-of select="$xpath"/>
        </xsl:if>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$level = 'fatal'">
          <!--<xsl:message terminate="yes" select="$msg"/>-->
          <xsl:message terminate="no" select="$msg"/>
          <!--On préfère ne jamais tuer le process, on pourra compter le nombre d'erreurs fatal mais si risque d'effet "boule de neige"-->
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="no" select="$msg"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <!--logging via balise log si $markup et niveau de log configuré pour être traité -->
    <xsl:variable name="markupAndLevelToProcess"
                  select="if (exists($els:log.level.markup)) then ($markup and els:isLogToBeProcessed($level, $els:log.level.markup)) else ($markup)"/>
    <xsl:if test="$markupAndLevelToProcess">
      <els:log level="{$level}" code="{$code}" xsltName="{$xsltName}">
        <xsl:if test="$logXpath">
          <xsl:attribute name="xpath" select="$xpath"/>
        </xsl:if>
        <xsl:if test="$xpathContext instance of node()">
          <!--que l'on soit sur un noeud attribut ou element ou autre, on créer un attribut avec le nom de l'élément "courant"-->
          <xsl:attribute name="element" select="name(ancestor-or-self::*[1])"/>
        </xsl:if>
        <!-- Mise en commentaire permet d'éviter d'ajouter du contenu textuel-->
        <!-- (Même si $description contient déjà un commentaire ou un "double tiret", la serialisation xsl:comment fonctionnera ! (testé) ) -->
        <xsl:comment><xsl:sequence select="$description"/></xsl:comment>
      </els:log>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Récupération de la priorité d'un niveau</xd:desc>
  </xd:doc>
  <xsl:function name="els:getLevelPriority" as="xs:integer">
    <xsl:param name="level" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$level='fatal'">50000</xsl:when>
      <xsl:when test="$level='error'">40000</xsl:when>
      <xsl:when test="$level='warning'">30000</xsl:when>
      <xsl:when test="$level='info'">20000</xsl:when>
      <xsl:when test="$level='debug'">10000</xsl:when>
      <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Vérifie si les logs d'un niveau donné sont à traiter en fonction d'un flag indiquant quels niveaux sont à traiter</xd:desc>
    <xd:desc>
      <xd:p>Ce flag correspond </xd:p>
      <xd:ul>
        <xd:li>
          <xd:p>soit au premier niveau dans l'ordre des priorités pour lequel les logs doivent être traités</xd:p>
          <xd:p>- log d'un niveau avec priorité supérieure ou égale : traité</xd:p>
          <xd:p>- log d'un niveau avec priorité inférieure : non traité</xd:p>
        </xd:li>
        <xd:li>soit à "all" : tous les logs, quel que soit leur niveau, sont à traiter</xd:li>
        <xd:li>soit à "off" : aucun log, quel que soit son niveau, n'est à traiter</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:isLogToBeProcessed" as="xs:boolean">
    <xsl:param name="level" as="xs:string"/>
    <xsl:param name="levelProcessFlag" as="xs:string"/>
    <xsl:value-of
      select="if ($levelProcessFlag = 'all') then (true()) 
              else (if ($levelProcessFlag = 'off') then (false()) 
              else (boolean(els:getLevelPriority($level) >= els:getLevelPriority($levelProcessFlag))))"/>
  </xsl:function>
	
</xsl:stylesheet>