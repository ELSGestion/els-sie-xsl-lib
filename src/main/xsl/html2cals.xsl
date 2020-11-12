<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:xhtml2cals="http://www.lefebvre-sarrut.eu/ns/els/xhtml2cals"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  xmlns="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all" 
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p xml:lang="fr">Cette feuille de style va traiter la conversion de tables xhtml en tables CALS.</xd:p>
      <xd:p xml:lang="fr">Les tables xhtml à convertir sont supposées valides.</xd:p>
      <xd:p xml:lang="fr">
        <xd:b>Note sur les tables (x)html:</xd:b> leur modèle de contenu à varié avec les specs W3C. <xd:ul>
          <xd:li><xd:pre>[xhtml 1.0] table ::= caption?, (colgroup*|col*), ((thead?, tfoot?, tbody+) | tr+)</xd:pre></xd:li>
          <xd:li><xd:pre>[xhtml 2.0] table ::= caption?, title?, summary?, (colgroup*|col*), ((thead?, tfoot?, tbody+) | tr+)</xd:pre></xd:li>
          <xd:li><xd:pre>[html 4.0] identique au modèle xhtml 1.0</xd:pre></xd:li>
          <xd:li><xd:pre>[html 5.0]  table ::= (caption?, colgroup*, thead?, ((tbody* | tr+) &amp; tfoot?)) +(script | template)</xd:pre></xd:li>
          <xd:li><xd:pre>[html 5.1]  table ::= (caption?, colgroup*, thead?, (tbody* | tr+), tfoot?) +(script | template)</xd:pre></xd:li>
          <xd:li><xd:pre>[html 5.2] identique au modèle html 5.1</xd:pre></xd:li>
        </xd:ul>
      </xd:p>
      <xd:p xml:lang="fr">En html 4.0 le contenu final est en fait <xd:i>(thead?, tfoot?, tbody+)</xd:i> 
        mais la minimisation de <xd:i>tbody</xd:i> impose un modèle de contenu modifié en xhtml.
        Le modèle xhtml 2.0 qui n'a pas eu de suite, ne sera que partiellement pris en compte ici.</xd:p>
      <xd:p xml:lang="fr">On supposera que l'on n'a pas d'élément <xd:i>script</xd:i> et <xd:i>template</xd:i> 
        dans nos données et on va se placer dans le cadre d'un modèle compatible avec le maximum de cas :
        <xd:pre>table ::= (caption?, colgroup*, thead?, ((tbody* | tr+) &amp; tfoot?))</xd:pre></xd:p>
      <xd:p xml:lang="fr">La structure des tableaux CALS résultant de la transformation est la suivante:
        <xd:pre>table ::= title? tgroup+ (ou tgroup ::= colspec*,spanspec*,thead?,tfoot?,tbody)</xd:pre>
        Le contenu des lignes des tableaux CALS sera limité à l'élément <xd:i>entry</xd:i> 
        (i.e. pas d'élément <xd:i>entrytbl</xd:i>)</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common.xsl"/>
  <xsl:import href="html4Table2html5Table.xsl"/>
  <xsl:import href="css-parser.xsl"/>
  
  <xsl:param name="xslLib:html2cals.debug" select="false()" as="xs:boolean"/>
  <!--Par défaut les log sont écrits à côté du xml-->
  <xsl:param name="xslLib:html2cals.LOG.URI" select="resolve-uri('log', base-uri(.))" as="xs:string"/>
  <xsl:variable name="xslLib:html2cals.log.uri" select="if(ends-with($xslLib:html2cals.LOG.URI, '/')) then ($xslLib:html2cals.LOG.URI) else(concat($xslLib:html2cals.LOG.URI, '/'))" as="xs:string"/>
  
  <xsl:param name="xslLib:html2cals.cals.ns.uri" select="'http://docs.oasis-open.org/ns/oasis-exchange/table'" as="xs:string"/>
  <!--set the pattern for the value of rowsep/colsep attributes : when false the default values are 0 or 1 as says the CALS spec-->
  <xsl:param name="xslLib:html2cals.use-yesorno-values-for-colsep-rowsep" select="false()" as="xs:boolean"/>
  <!--When table are not in html namespace one can force every tableaux to be converted to this namespace-->
  <xsl:param name="xslLib:html2cals.force-html-table-conversion" select="false()" as="xs:boolean"/>
  <xsl:param name="xslLib:html2cals.generate-upper-case-cals-elements" select="false()" as="xs:boolean"/>
  <!--Cals spec uses * instead of %, this param allow this conversion--> 
  <xsl:param name="xslLib:html2cals.convertWidthPercentsToStars" select="true()" as="xs:boolean"/>
  <!--force to split single tgroup to multiple tgroup when encountering header's rows (with only <th> inside)-->
  <xsl:param name="xslLib:html2cals.splitTgroupsByHeaders" select="true()" as="xs:boolean"/>
  
  <!--==============================================================================================================================-->
  <!-- INIT -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="xslLib:xhtml2cals"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- MAIN -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/" mode="xslLib:xhtml2cals">
    <xsl:variable name="step" select="." as="document-node()"/>
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:html2cals.force-html-table-conversion">
          <xsl:document>
            <xsl:apply-templates select="." mode="xhtml2cals:force-html-table-conversion"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step1.force-html-table-conversion.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xhtml2cals:lowercase-html"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step2.lowercase-html.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xhtml2cals:normalize-to-xhtml"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step3.normalize-to-xhtml.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xhtml2cals:expand-spans"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step4.expand-spans.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:html4table2html5table"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step5.html4table2html5table.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xhtml2cals:convert-to-cals"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step6.convert-to-cals.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:html2cals.splitTgroupsByHeaders">
          <xsl:document>
            <xsl:apply-templates select="$step" mode="xhtml2cals:splitTgroupsByHeaders"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step7.splitTgroupsByHeaders.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:html2cals.splitTgroupsByHeaders">
          <!--After spliting tgroups by headers, some tgroups may have too much cols with systematic spanning-->
          <xsl:document>
            <xsl:apply-templates select="$step" mode="xhtml2cals:reduceNumberOfCols"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step8.reduceNumberOfCols.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xhtml2cals:optimize-cals"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step9.optimize-cals.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:html2cals.generate-upper-case-cals-elements">
          <xsl:document>
            <xsl:apply-templates select="$step" mode="xhtml2cals:convert-upper-case-cals"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:html2cals.debug">
      <xsl:variable name="log.uri" select="resolve-uri('html2cals.step10.convert-upper-case-cals.log.xml', $xslLib:html2cals.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$log.uri"/></xsl:message>
      <xsl:result-document href="{$log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--FINALY-->
    <xsl:choose>
      <!--Element has already been created in cals namespace (default xsl namespace) which is the intended one-->
      <xsl:when test="$xslLib:html2cals.cals.ns.uri = 'http://docs.oasis-open.org/ns/oasis-exchange/table'">
        <xsl:sequence select="$step"/>
      </xsl:when>
      <!--if not : convert cals element to the intended namespace--> 
      <xsl:otherwise>
        <xsl:apply-templates select="$step" mode="xhtml2cals:convert-cals-namespace"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 1 : Mode force-html-table-conversion: force every table to be converted to html namespace -->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <xsl:template match="*[lower-case(local-name(.)) = ('table', 'thead', 'tbody', 'tr', 'th', 'td')]" mode="xhtml2cals:force-html-table-conversion">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="xhtml2cals:force-html-table-conversion">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 2 : Mode lowercase-html: convert html table elements to lower-case -->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <xsl:template match="TABLE | THEAD | TBODY | TR | TH | TD" mode="xhtml2cals:lowercase-html">
    <xsl:element name="{lower-case(name(.))}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="(TABLE | THEAD | TBODY | TR | TH | TD)/@*" mode="xhtml2cals:lowercase-html">
    <xsl:attribute name="{lower-case(name(.))}" select="."/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="xhtml2cals:lowercase-html">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 3 : Mode normalize-to-xhtml: normalisation de la structure de table xhtml -->
    <!-- ==============================================================================================-->
  </xd:doc>

  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>Cette template va normaliser un tableau xhtml valide. En sortie, on aura un tableau
        conforme au modèle suivant:
        <xd:pre>table ::= caption?, colgroup+, thead?, tfoot?, tbody+</xd:pre> Les éléments
        supplémentaires définis en xhtml 2.0 ou html 5 seront éliminés.</xd:p>
      <xd:p>Les tables qui ont toutes leurs lignes situées dans le header et/ou dans le footer (ce qui
        semble possible depuis html 5) seront éliminées. On pourrait définir une heuristique pour les
        traiter, mais ce n'est probablement utile avec nos données.</xd:p>
      <xd:p>On passe le contexte au template afin de vérifier son type.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="table[(tbody/tr)|tr]" mode="xhtml2cals:normalize-to-xhtml">
    <xsl:copy>
      <xsl:apply-templates select="@* | processing-instruction() | comment()" mode="#current"/>
      <xsl:apply-templates select="caption" mode="#current"/>
      <xsl:choose>
        <xsl:when test="colgroup[col] | col">
          <xsl:apply-templates select="colgroup | col" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- On normalise en ajoutant un colgroup générique -->
          <colgroup span="{xhtml2cals:nb-cols(.)}" xmlns="http://www.w3.org/1999/xhtml"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="thead, tfoot" mode="#current"/>
      <xsl:choose>
        <xsl:when test="tbody">
          <xsl:apply-templates select="tbody" mode="#current"/>
        </xsl:when>
        <xsl:when test="tr">
          <!-- On normalise en ajoutant un tbody -->
          <!-- cela simplifie le traitement en bloc en mode expand-spans -->
          <tbody xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="tr" mode="#current"/>
          </tbody>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>Calcule le taille (en nombre de cellules) d'une table xhtml. Pour calculer, on se base sur
        les éléments <xd:i>colgroup</xd:i> et <xd:i>col</xd:i> s'il y en a, et sinon, sur le contenu
        de la première ligne. La méthode du W3C prévoit dans ce dernier cas de prendre le max des
        tailles de toutes les lignes, mais on peut se limiter à la première dans notre cas, puisque le
        tableau est valide.</xd:p>
    </xd:desc>
    <xd:param name="table">html table</xd:param>
  </xd:doc>
  <xsl:function name="xhtml2cals:nb-cols" as="xs:integer">
    <xsl:param name="table" as="element(table)"/>
    <xsl:choose>
      <!-- Cas d'une table avec des cols -->
      <xsl:when test="$table//col">
        <xsl:sequence select="(count($table//col[not(@span)]) + sum($table//(colgroup|col)/@span)) cast as xs:integer"/>
      </xsl:when>
      <!-- Cas d'une table sans cols, mais avec des tr                            -->
      <!-- Comme nos tables sont valides, il suffit de regarder la première ligne -->
      <xsl:otherwise>
        <xsl:sequence select="(count(($table//tr)[1]/(th|td)[not(@colspan)]) + sum(($table//tr)[1]/(th|td)/@colspan)) cast as xs:integer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--CALS entry are left aligned by default, whereas html headers are centered by default, so we have to force this center alignment when th has no align-->
  <!--no need to force any aligment with td because CALS and HTML use the same default value (left)-->
  <xsl:template match="th[css:getPropertyValue(css:parse-inline(@style), 'text-align') = '']" mode="xhtml2cals:normalize-to-xhtml">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="style" select="string-join((@style, 'text-align:center;'), '; ')"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Default copy-->
  <xsl:template match="node() | @*" mode="xhtml2cals:normalize-to-xhtml">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 4 : Mode expand-spans: expansion des attributs colspan et rowspan -->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>En mode <xd:i>expand-spans</xd:i> on va parcourir les lignes et expanser celles avec un attribut colspan ou rowspan.</xd:p>
      <xd:p>Ce template est appellé sur les blocs de lignes d'une table xhtml normalisée (thead, tfoot et le ou les tbody).</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="thead | tfoot | tbody" mode="xhtml2cals:expand-spans">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:call-template name="process-block">
        <xsl:with-param name="source-block" select="."/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>On expanse les attributs colspan et rowspan d'un bloc de lignes.</xd:p>
      <xd:p>L'algorithme est le suivant: On parcourt ligne à ligne. Lorsqu'on se trouve sur une cellule, on vérifie s'il ne faut pas d'abord procéder 
        à l'expansion verticale de la cellule située au dessus (et pour ce faire, on va avoir la ligne du dessus expansée en paramètre à la procédure),
        sinon, on regarde s'il faut expanser la cellule horizontalement.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template name="process-block">
    <!-- Bloc de lignes à expanser -->
    <xsl:param name="source-block" as="element()+"/>
    <!-- Indice de la ligne à expanser dans le bloc -->
    <xsl:param name="index" as="xs:integer">1</xsl:param>
    <!-- Dernière ligne venant d'être expansée -->
    <xsl:param name="processed-row" as="element()?"/>
    <xsl:choose>
      <xsl:when test="$index > count($source-block/tr)">
        <!-- Indice supérieur au nombre de lignes: on a traité toute les lignes -->
      </xsl:when>
      <xsl:when test="count($processed-row/node()) = 0">
        <!-- Pas de ligne encore expansée. On est donc à la première ligne du bloc et donc seuls les colspan sont à traiter. -->
        <xsl:variable name="first-row-tmp" as="element()+">
          <xsl:copy-of select="xhtml2cals:expand-colspans($source-block/tr[1])"/>
        </xsl:variable>
        <!-- ELSSIEXDC-23 / Les éventuels @rowspan de la 1ère ligne deviennent des @xhtml2cals:rowspan, nécessaires pour la suite de la transformation
             FIXME: A factoriser -->
        <xsl:variable name="first-row" as="element()">
          <tr xmlns="http://www.w3.org/1999/xhtml">
            <xsl:for-each select="$first-row-tmp">
              <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml" inherit-namespaces="no">
                <xsl:copy-of select="@*[not(name() = 'rowspan')]" copy-namespaces="no"/>
                <xsl:if test="@rowspan">
                  <xsl:attribute name="xhtml2cals:rowspan" select="@rowspan"/>
                </xsl:if>
                <xsl:copy-of select="node()" copy-namespaces="no"/>
              </xsl:element>
            </xsl:for-each>
          </tr>
        </xsl:variable>
        <!-- On retourne la première ligne expansée et on fait un appel récursif à la procédure pour traiter la ligne suivante. -->
        <xsl:copy-of select="$first-row"/>
        <xsl:call-template name="process-block">
          <xsl:with-param name="source-block" select="$source-block"/>
          <xsl:with-param name="index" as="xs:integer">2</xsl:with-param>
          <xsl:with-param name="processed-row" select="$first-row"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- On à déjà expansé des lignes. On expanse la ligne passée en paramètre -->
        <xsl:variable name="newly-processed-row" as="element()">
          <xsl:copy-of select="xhtml2cals:expand-table-row($source-block/tr[$index], $processed-row)"/>
          <!-- <xsl:copy-of select="xhtml2cals:expand-table-row($source-block, $processed-row, $index)"/> -->
        </xsl:variable>
        <!-- On retourne la ligne expansée et on fait un appel récursif à la procédure pour traiter la ligne suivante. -->
        <xsl:copy-of select="$newly-processed-row"/>
        <xsl:call-template name="process-block">
          <xsl:with-param name="source-block" select="$source-block"/>
          <xsl:with-param name="index" as="xs:integer" select="$index + 1"/>
          <xsl:with-param name="processed-row" select="$newly-processed-row"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Expand a table row by first process the rowspans then the colspans.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:expand-table-row" as="element()">
    <xsl:param name="source-row" as="element()"/>
    <xsl:param name="processed-row" as="element()"/>
    <!-- On traite d'abors les rowspans -->
    <xsl:variable name="expanding-row" as="element()">
      <tr xmlns="http://www.w3.org/1999/xhtml">
        <xsl:copy-of select="xhtml2cals:expand-rowspans($source-row, $processed-row)"/>
      </tr>
    </xsl:variable>
    <!-- et dans la ligne ou les rowspans ont été expansés, on traite ensuite les colspans -->
    <xsl:variable name="expanded-row" as="element()">
      <tr xmlns="http://www.w3.org/1999/xhtml">
        <xsl:copy-of select="xhtml2cals:expand-colspans($expanding-row)"/>
      </tr>
    </xsl:variable>
    <xsl:sequence select="$expanded-row"/>
  </xsl:function>

  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Expand colspans. Created cell will have an attribut "xhtml2cals:DummyCell". L'attribut est converti en xhtml2cals:colspan.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:expand-colspans" as="item()+">
    <!-- row will have colspans expanded -->
    <xsl:param name="source-row" as="element()"/>
    <xsl:variable name="expand-columns" as="element()*">
      <xsl:for-each select="$source-row/*">
        <xsl:variable name="element-name" select="local-name()" as="xs:string"/>
        <xsl:variable name="current-cell" select="self::*" as="element()"/>
        <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml" inherit-namespaces="no">
          <xsl:copy-of select="$current-cell/@*[not(name() = 'colspan')]" copy-namespaces="no"/>
          <xsl:if test="$current-cell/@colspan">
            <xsl:attribute name="xhtml2cals:colspan" select="$current-cell/@colspan"/>
          </xsl:if>
          <xsl:copy-of select="$current-cell/node()" copy-namespaces="no"/>
        </xsl:element>
        <!-- If there is a colspan add padding cells  -->
        <xsl:for-each select="2 to (xs:integer(@colspan))">
          <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml" inherit-namespaces="no">
            <xsl:attribute name="xhtml2cals:DummyCell" select="'yes'"/>
            <xsl:copy-of select="$current-cell/@*[not(name() = 'colspan')]" copy-namespaces="no"/>
            <xsl:attribute name="xhtml2cals:colspan" select="$current-cell/@colspan +1 - ."/>
            <xsl:comment>
              <xsl:copy-of select="$current-cell/node()" copy-namespaces="no"/>
            </xsl:comment>
          </xsl:element>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy-of select="$expand-columns" copy-namespaces="no"/>
  </xsl:function>
  
  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Expand a row by taking into acount the rowspans of the preceding row</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:expand-rowspans" as="item()+">
    <xsl:param name="current-row" as="element()+"/>
    <xsl:param name="preceding-row" as="element()"/>
    <xsl:for-each select="$preceding-row/*">
      <xsl:choose>
        <xsl:when test="@xhtml2cals:rowspan > 1">
          <!--Insert a cell-->
          <xsl:copy>
            <xsl:attribute name="xhtml2cals:DummyCell" select="'yes'"/>
            <xsl:copy-of select="@* except @xhtml2cals:rowspan"/>
            <xsl:attribute name="xhtml2cals:rowspan" select="number(@xhtml2cals:rowspan) - 1"/>
          </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
          <!-- No cell to insert, copy the current cell-->
          <xsl:variable name="current-column" select="count(preceding-sibling::*) + 1" as="xs:integer"/>
          <xsl:variable name="spanned-row-cells" select="count(preceding-sibling::*[@xhtml2cals:rowspan > 1])" as="xs:integer"/>
          <xsl:sequence select="xhtml2cals:select-cell($current-column - $spanned-row-cells, $current-row, 1, 0)"/>
          <!-- FIXME
            <xsl:choose>
            <xsl:when test="count(xhtml2cals:select-cell($current-column - $spanned-row-cells, $current-row, 1, 0)) != 0">
              <xsl:sequence select="xhtml2cals:select-cell($current-column - $spanned-row-cells, $current-row, 1, 0)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message terminate="no">ERROR $current-column= <xsl:value-of select="$current-column"/>, $spanned-row-cells= <xsl:value-of select="$spanned-row-cells"/> </xsl:message>
            </xsl:otherwise>
          </xsl:choose>-->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xd:doc scope="component">
    <xd:desc>
      <xd:p>Expand a row by taking into acount the rowspans of the preceding rows</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:select-cell">
    <!-- Current Column Being Processed  -->
    <xsl:param name="src-column-no" as="xs:integer"/>
    <!-- Current table row being processed -->
    <xsl:param name="source-row" as="element()+"/>
    <!-- Current column being examised to copy -->
    <xsl:param name="current-column-count" as="xs:integer"/>
    <!-- Total of the spans already checked -->
    <xsl:param name="current-span-col-total" as="xs:double"/>
    <!-- colspan of the current cell being examined-->
    <xsl:variable name="current-cell" select="$source-row/*[$current-column-count]"/> <!--as="element()*"-->
    <xsl:variable name="current-span" select="($current-cell/@colspan[. castable as xs:integer], 1)[1]" as="xs:integer">
      <!--<xsl:choose>
        <xsl:when test="$current-cell/@colspan">
          <xsl:value-of select="$current-cell/@colspan"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>-->
    </xsl:variable>
    <xsl:choose>
      <!-- Current column being processed matches the end of the span. i.e. span finishes here. Output cell -->
      <xsl:when test="$src-column-no = $current-span-col-total + $current-span">
        <xsl:choose>
          <xsl:when test="$current-cell/@rowspan">
            <xsl:element name="{local-name($current-cell)}" namespace="http://www.w3.org/1999/xhtml">
              <xsl:attribute name="xhtml2cals:rowspan" select="$current-cell/@rowspan"/>
              <xsl:copy-of select="$current-cell/(@* except @rowspan)"/>
              <xsl:copy-of select="$current-cell/node()"/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$current-cell" copy-namespaces="no"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- The span total exceeds the current colum.   This means the current cell is not a span boundry & we have gone past -->
      <xsl:when test="$src-column-no lt $current-span-col-total + $current-span">
        <!-- do nothing and exit the recurssion -->
      </xsl:when>
      <!-- The span total is less than the current colum. This means the current cell is not a span boundry. Try the next cell  -->
      <xsl:when test="$src-column-no > $current-span-col-total + $current-span">
        <xsl:copy-of
          select="xhtml2cals:select-cell($src-column-no, $source-row, $current-column-count + 1, $current-span + $current-span-col-total)"
          copy-namespaces="no"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">Error in table conversion.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>En mode <xd:i>expand-spans</xd:i>: recopie par défaut</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="@* | node()" mode="xhtml2cals:expand-spans">
    <xsl:copy copy-namespaces="yes">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 5 : Mode "xslLib:html4table2html5table" -->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <!--html4Table2html5Table.xsl -->
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 6 : Mode convert-to-cals  -->
    <!-- ==============================================================================================-->
  </xd:doc>

  <xsl:template match="table" mode="xhtml2cals:convert-to-cals">
    <table>
      <xsl:apply-templates select="@* except @data-cals-tgroupstyle" mode="xhtml2cals:convert-attributes-to-cals"/>
      <!--<xsl:copy-of select="@id | @class | @align | @width" copy-namespaces="no"/>-->
      <xsl:call-template name="xhtml2cals:compute-table-borders"/>
      <xsl:call-template name="xhtml2cals:compute-rowsep-colsep-defaults"/>
      <xsl:copy-of select="processing-instruction()|comment()"/>
      <xsl:apply-templates select="caption" mode="#current"/>
      <tgroup>
        <xsl:apply-templates select="@data-cals-tgroupstyle" mode="xhtml2cals:convert-attributes-to-cals"/>
        <xsl:attribute name="cols" select="xhtml2cals:nb-cols(.)"/>
        <xsl:call-template name="xhtml2cals:make-colspec">
          <xsl:with-param name="context" select="colgroup | col"/>
        </xsl:call-template>
        <!-- FIXME à rebrancher quand on gérera mieux les spanspec dans le modèle -->
        <!-- <xsl:call-template name="make-spanspec">
          <xsl:with-param name="context" select="colgroup | col"/>
        </xsl:call-template> -->
        <xsl:variable name="css" select="css:parse-inline(@style)" as="element(css:css)?"/>
        <xsl:apply-templates select="thead, tfoot, tbody" mode="#current">
          <xsl:with-param name="table.valign" select="css:getPropertyValue($css, 'vertical-align')" as="xs:string*"/>
        </xsl:apply-templates>
      </tgroup>
    </table>
  </xsl:template>
  
  <xsl:template name="xhtml2cals:compute-table-borders">
    <xsl:attribute name="frame">
      <xsl:choose>
        <xsl:when test="@frame and (not(@border) or @border != 0)">
          <xsl:choose>
            <xsl:when test="@frame='box'">all</xsl:when>
            <xsl:when test="@frame='above'">top</xsl:when>
            <xsl:when test="@frame='below'">bottom</xsl:when>
            <xsl:when test="@frame='border'">all</xsl:when>
            <xsl:when test="@frame='hsides'">topbot</xsl:when>
            <xsl:when test="@frame='lhs'">none</xsl:when>
            <xsl:when test="@frame='rhs'">none</xsl:when>
            <xsl:when test="@frame='void'">none</xsl:when>
            <xsl:when test="@frame='vsides'">sides</xsl:when>
            <xsl:otherwise>all</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="not(@frame) and @border != 0">
          <xsl:text>all</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="style.parsed" select="css:parse-inline(@style)" as="element(css:css)"/>
          <!--cf. http://www.datypic.com/sc/cals/a-nons_frame.html-->
          <!--NB : at step 4 every rowspan/colspan has been expanded to "dummyCell" : this is quite usefull here to guess the table border looking at every corner cells-->
          <!--FIXME : assume border-collapse:collapse here : add a param ?-->
          <!--border-top-->
          <xsl:variable name="border-top.by-table" select="css:showBorderTop($style.parsed)" as="xs:boolean"/>
          <xsl:variable name="border-top.by-cells" select="every $cell in (.//tr)[1]/(th|td) satisfies css:showBorderTop(css:parse-inline($cell/@style))" as="xs:boolean"/>
          <xsl:variable name="border-top" select="$border-top.by-table or $border-top.by-cells" as="xs:boolean"/>
          <!--border-right-->
          <xsl:variable name="border-right.by-table" select="css:showBorderRight($style.parsed)" as="xs:boolean"/>
          <xsl:variable name="border-right.by-cells" select="every $cell in .//tr/(th|td)[last()] satisfies css:showBorderRight(css:parse-inline($cell/@style))" as="xs:boolean"/>
          <xsl:variable name="border-right" select="$border-right.by-table or $border-right.by-cells" as="xs:boolean"/>
          <!--border-bottom-->
          <xsl:variable name="border-bottom.by-table" select="css:showBorderBottom($style.parsed)" as="xs:boolean"/>
          <xsl:variable name="border-bottom.by-cells" select="every $cell in (.//tr)[last()]/(th|td) satisfies css:showBorderBottom(css:parse-inline($cell/@style))" as="xs:boolean"/>
          <xsl:variable name="border-bottom" select="$border-bottom.by-table or $border-bottom.by-cells" as="xs:boolean"/>
          <!--border-left-->
          <xsl:variable name="border-left.by-table" select="css:showBorderLeft($style.parsed)" as="xs:boolean"/>
          <xsl:variable name="border-left.by-cells" select="every $cell in .//(tr/(th|td))[1] satisfies css:showBorderLeft(css:parse-inline($cell/@style))" as="xs:boolean"/>
          <xsl:variable name="border-left" select="$border-left.by-table or $border-left.by-cells" as="xs:boolean"/>
          <xsl:message use-when="false()">border-top : <xsl:value-of select="$border-top"/></xsl:message>
          <xsl:message use-when="false()">border-right : <xsl:value-of select="$border-right"/></xsl:message>
          <xsl:message use-when="false()">border-bottom : <xsl:value-of select="$border-bottom"/></xsl:message>
          <xsl:message use-when="false()">border-left : <xsl:value-of select="$border-left"/></xsl:message>
          <xsl:choose>
            <xsl:when test="$border-top and $border-right and $border-bottom and $border-left">
              <xsl:text>all</xsl:text>
            </xsl:when>
            <xsl:when test="$border-top and not($border-right) and $border-bottom and not($border-left)">
              <xsl:text>topbot</xsl:text>
            </xsl:when>
            <xsl:when test="not($border-top) and $border-right and not($border-bottom) and $border-left">
              <xsl:text>sides</xsl:text>
            </xsl:when>
            <xsl:when test="$border-top and not($border-right) and not($border-bottom) and not($border-left)">
              <xsl:text>top</xsl:text>
            </xsl:when>
            <xsl:when test="not($border-top) and not($border-right) and $border-bottom and not($border-left)">
              <xsl:text>bottom</xsl:text>
            </xsl:when>
            <xsl:when test="not($border-top) and not($border-right) and not($border-bottom) and not($border-left)">
              <xsl:text>none</xsl:text>
            </xsl:when>
            <!--in CALS the table's border-right and border-bottom (ONLY) can also be setted by the cells instead of the table frame
            Let's consider theses cases together with frame specific values-->
            <xsl:when test="not($border-top) and $border-right and $border-bottom.by-cells and $border-left">
              <xsl:text>sides</xsl:text>
            </xsl:when>
            <xsl:when test="$border-top and $border-right.by-cells and $border-bottom and not($border-left)">
              <xsl:text>topbot</xsl:text>
            </xsl:when>
            <xsl:when test="$border-top and $border-right.by-cells and $border-bottom.by-cells and not($border-left)">
              <xsl:text>top</xsl:text>
            </xsl:when>
            <xsl:when test="$border-top and $border-right.by-cells and not($border-bottom) and not($border-left)">
              <xsl:text>top</xsl:text>
            </xsl:when>
            <xsl:when test="not($border-top) and $border-right.by-cells and $border-bottom and not($border-left)">
              <xsl:text>bottom</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>all</xsl:text>
              <xsl:message>ERROR : unable to set cals:table @frame attribute properly, set to "all" by default</xsl:message>
              <xsl:message>border-top : <xsl:value-of select="$border-top"/></xsl:message>
              <xsl:message>border-right : <xsl:value-of select="$border-right"/></xsl:message>
              <xsl:message>border-bottom : <xsl:value-of select="$border-bottom"/></xsl:message>
              <xsl:message>border-left : <xsl:value-of select="$border-left"/></xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template name="xhtml2cals:compute-rowsep-colsep-defaults">
    <xsl:choose>
      <xsl:when test="@border != 0 and not(@rules)">
        <xsl:attribute name="colsep" select="'1'"/>
        <xsl:attribute name="rowsep" select="'1'"/>
      </xsl:when>
      <xsl:when test="@rules">
        <xsl:choose>
          <xsl:when test="@rules = 'all'">
            <xsl:attribute name="colsep" select="'1'"/>
            <xsl:attribute name="rowsep" select="'1'"/>
          </xsl:when>
          <xsl:when test="@rules = 'rows'">
            <xsl:attribute name="colsep" select="'0'"/>
            <xsl:attribute name="rowsep" select="'1'"/>
          </xsl:when>
          <xsl:when test="@rules = 'cols'">
            <xsl:attribute name="colsep" select="'1'"/>
            <xsl:attribute name="rowsep" select="'0'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="colsep" select="'0'"/>
            <xsl:attribute name="rowsep" select="'0'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="colsep" select="'0'"/>
        <xsl:attribute name="rowsep" select="'0'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- template recursif: On parcourt un element col ou colgroup, on génère le ou les colspec correspondant-->
  <xsl:template name="xhtml2cals:make-colspec">
    <!-- colgroup list or col list -->
    <xsl:param name="context" as="element()*"/> <!--colgroup or col-->
    <!-- index in the list of the colgroup or col to be processed -->
    <xsl:param name="index" select="1" as="xs:integer"/>
    <!-- next colspec number -->
    <xsl:param name="colnum" select="0" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="count($context) = 0"><!--no operation--></xsl:when>
      <xsl:when test="$index > count($context)"><!--no operation--></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="span" as="xs:integer">
          <xsl:choose>
            <xsl:when test="$context[$index]/col">
              <xsl:value-of select="count($context[$index]/col[not(@span)]) + sum($context[$index]/col/@span)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="max(($context[$index]/@span, 1))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$context[$index]/col">
            <xsl:call-template name="xhtml2cals:make-colspec">
              <xsl:with-param name="context" select="$context[$index]/col"/>
              <xsl:with-param name="index" select="1"/>
              <xsl:with-param name="colnum" select="$colnum"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="1 to xs:integer($span)">
              <colspec colname="{concat('c', ($colnum + .))}">
                <!--<xsl:if test=". = 1">
                  <!-\- GMA ou pour tous? -\->
                  <xsl:copy-of select="$context[$index]/(@align | @charoff | @char)"/>
                </xsl:if>
                <xsl:if test="$context[$index]/@width">
                  <xsl:attribute name="colwidth" select="$context[$index]/@width"/>
                </xsl:if>-->
                <xsl:apply-templates select="$context[$index]/@*" mode="xhtml2cals:convert-attributes-to-cals"/>
              </colspec>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
        <!-- Tail recursion -->
        <xsl:call-template name="xhtml2cals:make-colspec">
          <xsl:with-param name="context" select="$context"/>
          <xsl:with-param name="index" select="$index + 1"/>
          <xsl:with-param name="colnum" select="$colnum + $span"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- template recursif: On parcourt la un element col ou colgroup, on génère le ou les spanspec correspondant-->
  <!--<xsl:template name="xhtml2cals:make-spanspec">
    <xsl:param name="context" as="element()*"/><!-\- colgroup* or col* -\->
    <!-\- index in the list of the colgroup or col to be processed -\->
    <xsl:param name="index" select="1" as="xs:integer"/>
    <!-\- next colspec number -\->
    <xsl:param name="colnum" select="0" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="count($context) = 0"><!-\-no operation-\-></xsl:when>
      <xsl:when test="$index > count($context)"><!-\-no operation-\-></xsl:when>
      <xsl:otherwise>
        <xsl:variable name="span" as="xs:integer">
          <xsl:choose>
            <xsl:when test="$context[$index]/col">
              <xsl:value-of select="count($context[$index]/col[not(@span)]) + sum($context[$index]/col/@span)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="max(($context[$index]/@span, 1))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if
          test="(count($context[$index]/col) > 1) or ((count($context[$index]/col) = 0) and ($span > 1))">
          <spanspec 
            spanname="{concat('span', ($colnum + 1), '-', $span)}" 
            namest="{concat('c', ($colnum + 1))}" 
            nameend="{concat('c', ($colnum + $span))}">
            <xsl:copy-of select="@align | @charoff | @char"/>
            <xsl:if test="@width">
              <xsl:attribute name="colwidth" select="@width"/>
            </xsl:if>
          </spanspec>
        </xsl:if>
        <xsl:if test="$context[$index]/col">
          <xsl:call-template name="xhtml2cals:make-spanspec">
            <xsl:with-param name="context" select="$context[$index]/col"/>
            <xsl:with-param name="index" select="1"/>
            <xsl:with-param name="colnum" select="$colnum"/>
          </xsl:call-template>
        </xsl:if>
        <!-\- Tail recursion -\->
        <xsl:call-template name="xhtml2cals:make-spanspec">
          <xsl:with-param name="context" select="$context"/>
          <xsl:with-param name="index" select="$index + 1"/>
          <xsl:with-param name="colnum" select="$colnum + $span"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->
  
  <xsl:template match="caption" mode="xhtml2cals:convert-to-cals">
    <!--<title>
      <xsl:apply-templates select="@*" mode="xhtml2cals:convert-attributes-to-cals"/>
      <!-\-<xsl:copy-of select="@id | @class | @style" copy-namespaces="no"/>-\->
      <xsl:apply-templates select="node()" mode="#current"/>
    </title>-->
    <!--FIXME : title doesn't exist in cals model-->
    <xsl:message terminate="no">[ERROR] caption can not be converted as cals element, there is no equivalent in cals model</xsl:message>
  </xsl:template>
  
  <xsl:template match="thead" mode="xhtml2cals:convert-to-cals">
    <xsl:param name="table.valign" as="xs:string*"/>
    <xsl:variable name="css" select="css:parse-inline(@style)" as="element(css:css)?"/>
    <!--FIXME : after html4Table2html5Table.xsl there is no more @valign attribute-->
    <thead>
      <xsl:apply-templates select="@*" mode="xhtml2cals:convert-attributes-to-cals"/>
      <xsl:if test="$table.valign='' and css:getPropertyValue($css, 'vertical-align') = ''">
        <!--Default HTML valign is middle, we have to say it explicitely in cals-->
        <xsl:attribute name="valign" select="'middle'"/>
      </xsl:if>
      <!--<xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign" copy-namespaces="no"/>-->
      <xsl:apply-templates select="node()" mode="#current"/>
    </thead>
  </xsl:template>
  
  <xsl:template match="tfoot" mode="xhtml2cals:convert-to-cals">
    <xsl:param name="table.valign" as="xs:string*"/>
    <xsl:variable name="css" select="css:parse-inline(@style)" as="element(css:css)?"/>
    <tfoot>
      <xsl:apply-templates select="@*" mode="xhtml2cals:convert-attributes-to-cals"/>
      <xsl:if test="$table.valign='' and css:getPropertyValue($css, 'vertical-align') = ''">
        <!--Default HTML valign is middle, we have to say it explicitely in cals-->
        <xsl:attribute name="valign" select="'middle'"/>
      </xsl:if>
      <!--<xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign" copy-namespaces="no"/>-->
      <xsl:apply-templates select="node()" mode="#current"/>
    </tfoot>
  </xsl:template>
  
  <xsl:template match="tbody" mode="xhtml2cals:convert-to-cals">
    <xsl:param name="table.valign" as="xs:string*"/>
    <xsl:variable name="css" select="css:parse-inline(@style)" as="element(css:css)?"/>
    <tbody>
      <xsl:apply-templates select="@*" mode="xhtml2cals:convert-attributes-to-cals"/>
      <xsl:if test="$table.valign='' and css:getPropertyValue($css, 'vertical-align') = ''">
        <!--Default HTML valign is middle, we have to say it explicitely in cals-->
        <xsl:attribute name="valign" select="'middle'"/>
      </xsl:if>
      <!--<xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign" copy-namespaces="no"/>-->
      <xsl:apply-templates select="node()" mode="#current"/>
    </tbody>
  </xsl:template>
  
  <xsl:template match="tr" mode="xhtml2cals:convert-to-cals">
    <row>
      <xsl:apply-templates select="@*" mode="xhtml2cals:convert-attributes-to-cals"/>
      <!--<xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign" copy-namespaces="no"/>-->
      <xsl:apply-templates select="node()" mode="#current"/>
    </row>
  </xsl:template>
  
  <xsl:template match="td | th" mode="xhtml2cals:convert-to-cals">
    <entry>
      <xsl:variable name="curr-col-num" as="xs:integer" select="count(preceding-sibling::*) + 1"/>
      <!-- copy attributes with same name -->            
      <!-- If no @valign use col/@valign, @valign="baseline" has no correspondence in CALS -->
      <!--<xsl:copy-of select="(@valign, (../../..//col)[$curr-col-num]/@valign)[1][not(. = 'baseline')]"/>
      <xsl:copy-of select="@id | @class | @align | @char | @charoff "/>-->
      <xsl:apply-templates select="@*" mode="xhtml2cals:convert-attributes-to-cals"/>
      <xsl:attribute name="xhtml2cals:htmlname" select="local-name()"/>
      <xsl:if test="not(@xhtml2cals:DummyCell)">
        <xsl:if test="@xhtml2cals:rowspan > 1">
          <xsl:attribute name="morerows" select="number(@xhtml2cals:rowspan)-1"/>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="@xhtml2cals:colspan > 1">
            <xsl:attribute name="namest" select="concat('c', count(preceding-sibling::*) + 1)"/>
            <xsl:attribute name="nameend" select="concat('c', count(preceding-sibling::*) + @xhtml2cals:colspan)"/>            
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="colname" select="concat('c', count(preceding-sibling::*) + 1)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <!-- check CSS for definition of col or row separator -->
      <xsl:variable name="rowspan" select="(@xhtml2cals:rowspan, 1)[1]" as="xs:integer"/>
      <!-- the CSS of the next col or row can have an impact on the separator settings -->
      <xsl:variable name="css-next-col" select="css:parse-inline(following-sibling::*[not(@xhtml2cals:DummyCell)][1]/@style)" as="element(css:css)?"/>
      <xsl:variable name="css-next-row" select="css:parse-inline(../following-sibling::*[$rowspan]/*[$curr-col-num]/@style)" as="element(css:css)?"/>
      <xsl:variable name="css" select="css:parse-inline(@style)" as="element(css:css)?"/>
      <!-- take into account rules setting of table -->
      <xsl:variable name="forced-rowsep" as="xs:boolean">
        <xsl:choose>
          <!-- force separator for last row in header and body and footer -->
          <xsl:when test="ancestor::table[1]/@rules = 'groups' and not(../following-sibling::tr)">
            <xsl:sequence select="true()"/>
          </xsl:when>
          <xsl:when test="ancestor::table[1]/@rules = ('rows', 'all')">
            <xsl:sequence select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="forced-colsep" select="(ancestor::table[1]/@rules = 'cols') or (ancestor::table[1]/@rules = 'all')" as="xs:boolean"/>
      <xsl:choose>
        <xsl:when test="$forced-colsep or css:definesBorderRight($css) or css:definesBorderLeft($css-next-col)">
          <xsl:attribute name="colsep" select="if ($forced-colsep or css:showBorderRight($css) or css:showBorderLeft($css-next-col)) then('1') else('0')"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$forced-rowsep or css:definesBorderBottom($css) or css:definesBorderTop($css-next-row)">
          <xsl:attribute name="rowsep" select="if ($forced-rowsep or css:showBorderBottom($css) or css:showBorderTop($css-next-row)) then ('1') else ('0')"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="node()" mode="#current"/>
    </entry>
  </xsl:template>
  
  <!-- Keep ghost cells here at this point because we need these dummyCells to compute colwidth and for cols reduction
  they will be delete later at step "cals-optimize"--> 
  <xsl:template match="td[@xhtml2cals:DummyCell] | th[@xhtml2cals:DummyCell]" mode="xhtml2cals:convert-to-cals" priority="1">
    <entry>
      <xsl:attribute name="xhtml2cals:htmlname" select="local-name()"/>
      <xsl:copy-of select="@*"/>
    </entry>
  </xsl:template>
  
  <!-- === Converting attributes === -->
  
  <!--Attributes which has the same name in html and cals are beeing copied-->
  <xsl:template match="@align | @valign | @char | @charoff" mode="xhtml2cals:convert-attributes-to-cals">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!--keep some specific attributes-->
  <xsl:template match="@id" mode="xhtml2cals:convert-attributes-to-cals">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!--some class values might come from cals2html conversion, delete them but keep others class values-->
  <xsl:template match="@class" mode="xhtml2cals:convert-attributes-to-cals">
    <xsl:variable name="class.token" select="tokenize(., '\s+')" as="xs:string*"/>
    <xsl:variable name="class.except-cals" select="string-join($class.token[not(starts-with(., 'cals_'))], ' ')" as="xs:string"/>
    <xsl:if test="$class.except-cals">
      <xsl:attribute name="class" select="$class.except-cals"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="@*[starts-with(local-name(), 'data-cals-')]" mode="xhtml2cals:convert-attributes-to-cals">
    <xsl:attribute name="{substring-after(local-name(), 'data-cals-')}" select="."/>
  </xsl:template>
  
  <xsl:template match="*[not(self::css:*)]/@style" mode="xhtml2cals:convert-attributes-to-cals">
    <xsl:variable name="e" select="parent::*" as="element()"/>
    <xsl:variable name="css" select="css:parse-inline(.)" as="element(css:css)?"/>
    <xsl:for-each select="css:getProperties($css)">
      <xsl:choose>
        <xsl:when test="css:getPropertyName(.) = 'width'">
          <xsl:variable name="width" select="css:getPropertyValue($css, 'width')" as="xs:string"/>
          <xsl:choose>
            <xsl:when test="$e/self::table">
              <!--There's no tablewidth attribute in CALS, the only value that can use here is pgwide="1" when the table is fullwith-->
              <xsl:if test="$width = '100%'">
                <xsl:attribute name="pgwide" select="'1'"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="normalized-width" as="xs:string">
                <xsl:choose>
                  <xsl:when test="$xslLib:html2cals.convertWidthPercentsToStars and ends-with($width, '%')">
                    <xsl:variable name="table" select="$e/ancestor::table[1]" as="element()"/>
                    <xsl:variable name="nb-cols" select="xhtml2cals:nb-cols($table)" as="xs:integer"/>
                    <xsl:variable name="percent" select="substring-before($width, '%') cast as xs:double" as="xs:double"/>
                    <!--table % is applied to the width of the html table
                        if a table has 4 cols, the whole width is "4*" then 1* is equivalent 25%
                            100% -> nb-cols *
                            N%   -> (N x nb-cols / 100) *
                        NB : we could actually just replace % by * when every width is specified, which could be false-->
                    <xsl:sequence select="els:round($percent * $nb-cols div 100, 3) || '*'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:sequence select="$width"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:choose>
                <!--When the width is set on html:col, keep it for cals colspec-->
                <xsl:when test="$e/self::col">
                  <xsl:attribute name="colwidth" select="$normalized-width"/>
                </xsl:when>
                <!--When the width is set on html cells, we will have to compute it on cals colspec later-->
                <xsl:otherwise>
                  <!--keep the width so we can compute it later-->
                  <xsl:attribute name="html-width" select="$normalized-width"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="css:getPropertyName(.) = 'text-align'">
          <xsl:attribute name="align" select="css:getPropertyValue($css, 'text-align')"/>
        </xsl:when>
        <xsl:when test="css:getPropertyName(.) = 'vertical-align'">
          <xsl:choose>
            <xsl:when test="css:getPropertyValue($css, 'vertical-align') = ('center', 'central')">
              <xsl:attribute name="valign" select="'middle'"/>
            </xsl:when>
            <xsl:when test="css:getPropertyValue($css, 'vertical-align') = 'baseline'">
              <!--"baseline" has no correspondence in CALS-->
              <xsl:attribute name="valign" select="'bottom'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="valign" select="css:getPropertyValue($css, 'vertical-align')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="starts-with(css:getPropertyName(.), 'border')">
          <!--rowsep and colsep has already been processed-->
        </xsl:when>
        <xsl:when test="css:getPropertyName(.) = 'background-color'">
          <!--<css:background-color-ruleset><css:background-color><css:color>#d8d8d8</css:color></css:background-color></css:background-color-ruleset>-->
          <xsl:attribute name="bgcolor" select="css:getProperty($css, 'background-color')//text()"/>
        </xsl:when>
        <xsl:when test="css:getPropertyName(.) => starts-with('padding')">
          <!--Ignore - no equivalent in CALS-->
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>[WARNING][html2cals.xsl] unmatched css property "<xsl:value-of select="css:getPropertyName(.)"/>"</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <!--attributes to delete-->
  <xsl:template match="colgroup/@span | @colspan | @rowspan | @xhtml2cals:colspan | @xhtml2cals:rowspan" mode="xhtml2cals:convert-attributes-to-cals"/>
  
  <!--default copy template-->
  <xsl:template match="@*" mode="xhtml2cals:convert-attributes-to-cals">
    <xsl:message>[WARNING][html2cals.xsl] @<xsl:value-of select="name()"/> unmatched in mode="xhtml2cals:convert-attributes-to-cals"</xsl:message>
  </xsl:template>
  
  <!--default copy template-->
  <xsl:template match="@* | node()" mode="xhtml2cals:convert-to-cals">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 7 : Mode xhtml2cals:splitTgroupsByHeaders-->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <xsl:template match="cals:tgroup[*/cals:row[xslLib:html2cals.rowIsHeader(.)]]" mode="xhtml2cals:splitTgroupsByHeaders">
    <xsl:for-each-group select="descendant::cals:row" 
      group-starting-with="cals:row[xslLib:html2cals.rowIsHeader(.)][not(preceding-sibling::cals:row[1]/xslLib:html2cals.rowIsHeader(.))]">
      <xsl:variable name="cg1" select="current-group()[1]" as="element(cals:row)"/>
      <xsl:variable name="theadOrTboby" select="($cg1/ancestor::cals:thead[1], $cg1/ancestor::cals:tbody[1])[1]" as="element()"/>
      <xsl:variable name="tgroup" select="$cg1/ancestor::cals:tgroup[1]" as="element(cals:tgroup)"/>
      <tgroup>
        <xsl:apply-templates select="$tgroup/@*" mode="#current"/>
        <xsl:apply-templates select="$tgroup/cals:colspec" mode="#current"/>
        <thead>
          <xsl:apply-templates select="$theadOrTboby/@*" mode="#current"/>
          <xsl:apply-templates select="current-group()[xslLib:html2cals.rowIsHeader(.)]" mode="#current"/>
        </thead>
        <tbody>
          <xsl:apply-templates select="$theadOrTboby/@*" mode="#current"/>
          <xsl:apply-templates select="current-group()[not(xslLib:html2cals.rowIsHeader(.))]" mode="#current"/>
        </tbody>
      </tgroup>
    </xsl:for-each-group> 
  </xsl:template>
  
  <!--Delete temporary attribute-->
  <xsl:template match="@xhtml2cals:htmlname" mode="xhtml2cals:splitTgroupsByHeaders"/>
    
  <xsl:function name="xslLib:html2cals.rowIsHeader" as="xs:boolean">
    <xsl:param name="row" as="element(cals:row)"/>
    <xsl:sequence select="every $entry in $row/cals:entry satisfies $entry/@xhtml2cals:htmlname = 'th'"/>
  </xsl:function>
  
  <!--copy template-->
  <xsl:template match="node() | @*" mode="xhtml2cals:splitTgroupsByHeaders">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 8 : Mode xhtml2cals:reduceNumberOfCols-->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <!--After spliting tgroups by headers, some tgroups may have too much colums (with spanning entries on each row) 
  The algo here will only check 1st left cell of each row, if all of them are spanned (namest+nameend or morerows) 
  then that mean there's an extra unuseful row which can be deleted
  We could use cals:normalize(.) to simplify the algo but at this point, there are already some DummyCell that has been added 
  from the HTML normalisation, let's count on this instead.
  -->
  
  <xsl:template match="cals:tgroup" mode="xhtml2cals:reduceNumberOfCols">
    <xsl:variable name="rows" select="descendant::cals:row" as="element(cals:row)*"/>
    <xsl:variable name="minColspanGhostCells" as="xs:integer"
      select="min($rows/count(cals:entry[xslLib:html2cals.isColspanGhostEntry(.)]))"/>
    <!--Get the positions of those ghost cells : they indicate expanded cols and rows-->
    <xsl:variable name="minColspanGhostCells.position" as="xs:integer*" select="
      for $ghostEntry in ($rows[count(cals:entry[xslLib:html2cals.isColspanGhostEntry(.)]) = $minColspanGhostCells][1]/cals:entry[xslLib:html2cals.isColspanGhostEntry(.)]) 
      return count($ghostEntry/preceding-sibling::cals:entry) + 1"/>
    <xsl:variable name="cols2delete" as="xs:integer*">
      <xsl:for-each select="$minColspanGhostCells.position">
        <xsl:variable name="pos" select="." as="xs:integer"/>
        <xsl:if test="every $entry in $rows/cals:entry[position() = $pos] satisfies xslLib:html2cals.isColspanGhostEntry($entry)">
          <xsl:sequence select="$pos"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy>
      <!--<xsl:attribute name="minColspanGhostCells" select="$minColspanGhostCells"/>
      <xsl:attribute name="minColspanGhostCells.position" select="$minColspanGhostCells.position"/>
      <xsl:attribute name="cols2delete" select="$cols2delete"/>-->
      <xsl:apply-templates select="@* | node()" mode="#current">
        <xsl:with-param name="cols2delete" as="xs:integer*" select="$cols2delete" tunnel="true"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <!--Indicate if an entry is a ghost one because of a colspan in html--> 
  <xsl:function name="xslLib:html2cals.isColspanGhostEntry" as="xs:boolean">
    <xsl:param name="entry" as="element(cals:entry)"/>
    <xsl:sequence select="$entry/@xhtml2cals:DummyCell and $entry/@xhtml2cals:colspan"/>
  </xsl:function>
  
  <!--Update tgroup/@cols-->
  <xsl:template match="cals:tgroup/@cols" mode="xhtml2cals:reduceNumberOfCols">
    <xsl:param name="cols2delete" as="xs:integer*" tunnel="true"/>
    <xsl:attribute name="cols" select="xs:integer(.) - count($cols2delete)"/>
  </xsl:template>
  
  <!--Delete colspec that have been reduced-->
  <xsl:template match="cals:colspec" mode="xhtml2cals:reduceNumberOfCols">
    <xsl:param name="cols2delete" as="xs:integer*" tunnel="true"/>
    <xsl:choose>
      <xsl:when test="empty($cols2delete)">
        <xsl:next-match/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="position" as="xs:integer" select="count(preceding-sibling::cals:colspec) + 1"/>
        <xsl:if test="not($position = $cols2delete)">
          <xsl:variable name="followingColspecToDelete" as="element()*" 
            select="following-sibling::cals:colspec[not($position = $cols2delete)]"/>
          <xsl:copy copy-namespaces="false">
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:variable name="colwidths" select="(@colwidth, $followingColspecToDelete/@colwidth)" as="xs:string*"/>
            <xsl:variable name="colwidths.units" select="$colwidths ! xslLib:html2cals.getWidthUnit(.)" as="xs:string*"/>
            <xsl:variable name="colwidths.values" select="$colwidths ! xslLib:html2cals.getWidthAsNumber(.)" as="xs:double*"/>
            <xsl:if test="count($colwidths) != 0 and count(distinct-values($colwidths.units)) = 1">
              <xsl:attribute name="colwidth" select="sum($colwidths.values) || $colwidths.units[1]"/>
            </xsl:if>
            <xsl:apply-templates select="node()" mode="#current"/>
          </xsl:copy>
        </xsl:if>
        <!--if not, delete it-->
        <!--debug : set use-when="true()"-->
        <xsl:if test="$position = $cols2delete" use-when="false()">
          <xsl:copy copy-namespaces="false">
            <xsl:attribute name="delete" select="'true'"/>
            <xsl:copy-of select="@*"/>
          </xsl:copy>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--calculate new values for entry @nameend after cols reduction--> 
  <xsl:template match="cals:entry[not(@xhtml2cals:DummyCell)][@nameend]" mode="xhtml2cals:reduceNumberOfCols">
    <xsl:param name="cols2delete" as="xs:integer*" tunnel="true"/>
    <xsl:variable name="nameend" as="xs:string" select="@nameend"/>
    <xsl:variable name="colspec-list" as="element(cals:colspec)*" select="ancestor::cals:tgroup[1]/cals:colspec"/>
    <xsl:variable name="colspec" as="element(cals:colspec)" select="$colspec-list[@colname = $nameend]"/>
    <xsl:variable name="colspec.position" as="xs:integer" select="count($colspec/preceding-sibling::cals:colspec) + 1"/>
    <xsl:choose>
      <!--When the @nameend arrive on a deleted col-->
      <xsl:when test="$colspec.position = $cols2delete">
        <!--e.g: cols2delete = (2, 3, 4, 8, 9, 11)
        there are actually 3 adjacent groups of col to delete here : (2, 3, 4) (8, 9) and (11)
        This cols are to be deleted because every rows has entries that spanned at minimun over it
        For this reason, none of the @nameend can be 2, 3 or 8. @nameend can only be 4 or 9 or 11.
        These @nameend has to be changed to the first col available (not deleted) on the left 
        (it can't be on the right because that would merge entries that are not spanned to the left)
        That means here: 
        - nameend="c4" will be changed to "c1"
        - nameend="c9" will be changed to "c7"
        - nameend="c11" will be changed to "c10"
        The first entry (c1) will never had to be deleted, in the way the algorithm is written, if c1, c2  rows are always spanned, 
        then c2 will be deleted. Actually @nameend can never be equals to c1 in CALS. 
        -->
        <xsl:variable name="cols2delete.index" as="xs:integer*" select="index-of($cols2delete, $colspec.position)"/>
        <xsl:variable name="cols2delete.group" as="xs:integer*" select="subsequence($cols2delete, 1, $cols2delete.index)"/>
        <xsl:variable name="last-available-colspec" as="element(cals:colspec)?" 
          select="$colspec-list[xslLib:html2cals.getLastAvailableColPosition($cols2delete.group)]"/>
        <xsl:variable name="nameend.new" as="xs:string">
          <xsl:choose>
            <xsl:when test="exists($last-available-colspec)">
              <xsl:value-of select="$last-available-colspec/@colname"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>error : unable to get last available colspec</xsl:text>
              <xsl:message>[ERROR][html2cals.xsl][xhtml2cals:reduceNumberOfCols] unable to get new nameend</xsl:message>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!--Inverse use-when true/false to debug-->
        <xsl:copy copy-namespaces="false" use-when="false()">
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="colspec.position" select="$colspec.position"/>
          <xsl:attribute name="cols2delete.index" select="$cols2delete.index"/>
          <xsl:attribute name="cols2delete.group" select="$cols2delete.group"/>
          <xsl:attribute name="nameend.new" select="$nameend.new"/>
          <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
        <xsl:copy copy-namespaces="false" use-when="true()">
          <xsl:choose>
            <xsl:when test="empty($nameend.new)">
              <xsl:attribute name="error" select="'unable to get new nameend'"/>
              <xsl:message>[ERROR][html2cals.xsl][xhtml2cals:reduceNumberOfCols] unable to get new nameend</xsl:message>
            </xsl:when>
            <xsl:when test="@namest = $nameend.new">
              <xsl:attribute name="colname" select="@namest"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="@namest"/>
              <xsl:attribute name="nameend" select="$nameend.new"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates select="@* except (@namest | @nameend)" mode="#current"/>
          <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--Get the last col available (not to delete)
    It actually get the 1st integer (in reverse order) that is not in the sequence, going back from 1 to 1 step
  (3, 6, 8, 9) => 7
  (3, 5, 6) => 4
  (1, 2, 3, 10) => 9-->
  <xsl:function name="xslLib:html2cals.getLastAvailableColPosition" as="xs:integer">
    <xsl:param name="cols2delete" as="xs:integer*"/>
    <xsl:choose>
      <xsl:when test="$cols2delete[last() - 1] = $cols2delete[last()] - 1">
        <xsl:sequence select="xslLib:html2cals.getLastAvailableColPosition($cols2delete[not(position() = last())])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$cols2delete[last()] - 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="node() | @*" mode="xhtml2cals:reduceNumberOfCols">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ==============================================================================================-->
    <!-- STEP 9 : Mode xhtml2cals:optimize-cals-->
    <!-- ==============================================================================================-->
  </xd:doc>
  
  <xsl:template match="cals:entry[@xhtml2cals:DummyCell]" mode="xhtml2cals:optimize-cals" priority="1"/>
  
  <!--Rename colname to c1, c2, c3 ... sequentially  because step reduceNumberOfCols may have created gaps
  This is purely "esthetic" to finished step reduceNumberOfCols in a clean manner-->
  <xsl:template match="cals:colspec/@colname" mode="xhtml2cals:optimize-cals">
    <xsl:variable name="colspec" select="parent::cals:colspec" as="element(cals:colspec)"/>
    <xsl:attribute name="colname" select="'c' || count($colspec/preceding-sibling::cals:colspec) + 1"/>
  </xsl:template>
  
  <xsl:template match="cals:entry/@*[local-name(.) = ('colname', 'namest', 'nameend')]" mode="xhtml2cals:optimize-cals">
    <xsl:variable name="value" select="." as="xs:string"/>
    <xsl:variable name="colspec" select="ancestor::cals:tgroup/cals:colspec[@colname = $value]" as="element(cals:colspec)*"/>
    <xsl:attribute name="{local-name(.)}">
      <xsl:choose>
        <xsl:when test="count($colspec) = 1">
          <xsl:value-of select="'c' || count($colspec/preceding-sibling::cals:colspec) + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <!--In case the colspec is not found, don't change anything-->
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <!--delete @html-width on cals elements, they had been added to compute colwidth (see after)-->
  <xsl:template match="cals:*/@html-width" mode="xhtml2cals:optimize-cals"/>
  
  <!--When colspec has no colwidth (from html:col/@width) try to get it from the cell(s) : the col will have the size of the max size cell (if size is consistent)-->
  <!--At this point an html-width attribute has been added on each cells : this value has been normalized to x* if the size was %-->
  <!--We have to check first the consistency of width of the selected cells (as we could't know if 2cm is larger than 1*)-->
  <xsl:template match="cals:colspec[not(@colwidth)][following-sibling::*/cals:row/cals:entry[@html-width]]" mode="xhtml2cals:optimize-cals">
    <xsl:variable name="position" select="count(preceding-sibling::cals:colspec) + 1" as="xs:integer"/>
    <xsl:variable name="col.unspanned-entries" as="element(cals:entry)*"
      select="following-sibling::*/cals:row/cals:entry[$position]
      [(@namest, '')[1] = (@nameend, '')[1]] (:ignore width of spanned cells:)" />
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="xslLib:html2cals.entriesWidthUnitAreTheSame($col.unspanned-entries)">
        <xsl:variable name="col.unspanned-entries.width" as="xs:double*"
          select="$col.unspanned-entries/@html-width ! xslLib:html2cals.getWidthAsNumber(.)" />
        <xsl:attribute name="colwidth" select="max($col.unspanned-entries.width) || $col.unspanned-entries[@html-width][1]/@html-width/xslLib:html2cals.getWidthUnit(.)"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <!--Check if every @html-width units of an entries list are consistent (the same)-->
  <xsl:function name="xslLib:html2cals.entriesWidthUnitAreTheSame" as="xs:boolean" visibility="private">
    <xsl:param name="entries" as="element(cals:entry)*"/>
    <xsl:variable name="entry-1.unit" select="$entries[@html-width][1]/@html-width/xslLib:html2cals.getWidthUnit(.)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="count($entries) = 0 or count($entry-1.unit) = 0">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="every $unit in $entries/@html-width/xslLib:html2cals.getWidthUnit(.) 
          satisfies $unit = $entry-1.unit"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--From a width with its unit (like 10px), get the unit (px)-->
  <!--FIXME : this function has been duplicated from cals2html one-->
  <xsl:function name="xslLib:html2cals.getWidthUnit" as="xs:string">
    <xsl:param name="width" as="xs:string"/>
    <xsl:sequence select="replace($width, '\d|\.', '')"/>
  </xsl:function>
  
  <!--10px => 10-->
  <xsl:function name="xslLib:html2cals.getWidthAsNumber" as="xs:double">
    <xsl:param name="width" as="xs:string"/>
    <xsl:sequence select="replace($width, '^((\d|\.)+).*', '$1') => xs:double()"/>
  </xsl:function>
  
  <!--colsep/rowsep : use 'yes' or 'no' instead of '1' or '0'-->
  <xsl:template match="cals:*/@colsep | cals:*/@rowsep" mode="xhtml2cals:optimize-cals">
    <xsl:choose>
      <xsl:when test="$xslLib:html2cals.use-yesorno-values-for-colsep-rowsep">
        <xsl:attribute name="{name(.)}" select="if(. = '1') then('yes') else('no')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--When the HTML come from xslLib:cals2html, one can convert the div class="cals_table" to an englobing cals table element, 
    every html table inside has been converted to a cals tgroup-->
  <xsl:template match="div[els:hasClass(., 'cals_table')][cals:table]" mode="xhtml2cals:optimize-cals">
    <table>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:apply-templates select="cals:table[1]/@*" mode="#current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </table>
  </xsl:template>
  
  <xsl:template match="div[els:hasClass(., 'cals_table')]/cals:table" mode="xhtml2cals:optimize-cals">
    <xsl:variable name="precedingTable" select="preceding-sibling::cals:table[1]" as="element(cals:table)?"/>
    <!--Vérification de principe-->
    <xsl:if test="exists($precedingTable)">
      <xsl:for-each select="@*">
        <xsl:variable name="att.name" select="name(.)" as="xs:string"/>
        <xsl:variable name="att.value" select="." as="xs:string"/>
        <xsl:if test="exists($precedingTable/@*[name() = $att.name]) and not($precedingTable/@*[name() = $att.name] = $att.value)">
          <xsl:message>[ERROR] Attribute <xsl:value-of select="$att.name"/>="<xsl:value-of select="$att.value"/>" is not equal to preceding-sibling table attribute <xsl:value-of select="$att.value"/></xsl:message>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="#current"/>
  </xsl:template>
  
  <!--convert data-cals attributes to cals format when le html originaly comes from ths cals2html.xsl of this repo-->
  <xsl:template match="@*[starts-with(local-name(), 'data-cals-')]" mode="xhtml2cals:optimize-cals">
    <xsl:attribute name="{substring-after(local-name(), 'data-cals-')}" select="."/>
  </xsl:template>
  
  <xsl:template match="@class" mode="xhtml2cals:optimize-cals">
    <xsl:variable name="new-class" as="xs:string*">
      <xsl:for-each select="tokenize(., '\s+')">
        <xsl:variable name="value" select="." as="xs:string"/>
        <xsl:choose>
          <xsl:when test="starts-with($value, 'cals_')">
            <!--delete cals specific class attribute value inerited from conversion cals2html.xsl--> 
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="count($new-class) != 0">
      <xsl:attribute name="class" select="string-join($new-class, ' ')"/>
    </xsl:if>
  </xsl:template>
  
  <!--copy template-->
  <xsl:template match="@* | node()" mode="xhtml2cals:optimize-cals">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ======================================================================-->
    <!-- STEP 10 : Mode xhtml2cals:convert-upper-case-cals -->
    <!-- ======================================================================-->
  </xd:doc>
  
  <xsl:template match="cals:tgroup | cals:table | cals:thead | cals:tbody | cals:row | cals:entry | cals:col | cals:colspec" mode="xhtml2cals:convert-upper-case-cals">
    <xsl:element name="{upper-case(name(.))}">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="(cals:tgroup | cals:table | cals:thead | cals:tbody | cals:row | cals:entry | cals:col | cals:colspec)/@*" mode="xhtml2cals:convert-upper-case-cals">
    <xsl:attribute name="{upper-case(name(.))}" select="upper-case(.)"/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="xhtml2cals:convert-upper-case-cals">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ======================================================================-->
    <!-- STEP 11 : Mode xhtml2cals:convert-cals-namespace -->
    <!-- ======================================================================-->
  </xd:doc>
  
  <xsl:template match="cals:*" mode="xhtml2cals:convert-cals-namespace">
    <xsl:element name="{local-name(.)}" namespace="{$xslLib:html2cals.cals.ns.uri}">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!--default copy-->
  <xsl:template match="@*|node()" mode="xhtml2cals:convert-cals-namespace">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>