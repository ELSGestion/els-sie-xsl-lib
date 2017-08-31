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
  version="2.0">
  
  <xsl:import href="els-common.xsl"/>
  <xsl:import href="css-parser.xsl"/>
  
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
  
  <xsl:param name="xslLib:cals.ns.uri" select="'http://docs.oasis-open.org/ns/oasis-exchange/table'" as="xs:string"/>
  
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
    <xsl:variable name="step1" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="xhtml2cals:normalize-to-xhtml"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step2" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step1" mode="xhtml2cals:expand-spans"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step3" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step2" mode="xhtml2cals:convert-to-cals"/>
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="step4" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step3" mode="xhtml2cals:optimize-cals"/>
      </xsl:document>
    </xsl:variable>
    <!--FINALY-->
    <xsl:choose>
      <!--Element has already been created in cals namespace (default xsl namespace) which is the intended one-->
      <xsl:when test="$xslLib:cals.ns.uri = 'http://docs.oasis-open.org/ns/oasis-exchange/table'">
        <xsl:sequence select="$step4"/>
      </xsl:when>
      <!--if not : convert cals element to the intended namespace--> 
      <xsl:otherwise>
        <xsl:apply-templates select="$step3" mode="xhtml2cals:convert-cals-namespace"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <!-- ======================================================================-->
    <!-- Mode normalize-to-xhtml: normalisation de la structure de table xhtml -->
    <!-- ======================================================================-->
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
        <xsl:when test="colgroup | col">
          <xsl:apply-templates select="colgroup | col" mode="#current"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- On normalise en ajoutant un colgroup générique -->
          <colgroup xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="span" select="xhtml2cals:nb-cols(.)"/>
          </colgroup>
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

  <!--Default copy-->
  <xsl:template match="node() | @*" mode="xhtml2cals:normalize-to-xhtml">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ===================================================================-->
    <!-- Mode expand-spans: expansion des attributs colspan et rowspan      -->
    <!-- ===================================================================-->
  </xd:doc>
  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>En mode <xd:i>expand-spans</xd:i> on va parcourir les lignes et expanser celles avec un
        attribut colspan ou rowspan.</xd:p>
      <xd:p>Ce template est appellé sur les blocs de lignes d'une table xhtml normalisée (thead, tfoot
        et le ou les tbody).</xd:p>
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
      <xd:p>L'algorithme est le suivant: On parcourt ligne à ligne. Lorsqu'on se trouve sur une
        cellule, on vérifie s'il ne faut pas d'abord procéder a l'expansion verticale de la cellule
        située au dessus (et pour ce faire, on va avoir la ligne du dessus expansée en paramêtre à la
        procédure), sinon, on regarde s'il faut expanser la cellule horizontalement.</xd:p>
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
      <xsl:when test="$index &gt; count($source-block/tr)">
        <!-- Indice supérieur au nombre de lignes: on a traité toute les lignes -->
      </xsl:when>
      <xsl:when test="count($processed-row/node()) = 0">
        <!-- Pas de ligne encore expansée. On est donc à la première ligne du bloc et donc seuls les colspan sont à traiter. -->
        <xsl:variable name="first-row" as="element()+">
          <tr xmlns="http://www.w3.org/1999/xhtml">
            <xsl:copy-of select="xhtml2cals:expand-colspans($source-block/tr[1])"/>
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
  
  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>Expanse une ligne, en traitant d'abord les rowspans, puis les colspans.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:expand-table-row" as="element()">
    <xsl:param name="source-row" as="element()"/>
    <xsl:param name="processed-row" as="element()"/>
    <!-- On traite d'abors les rowspans -->
    <xsl:variable name="expanding-row">
      <tr xmlns="http://www.w3.org/1999/xhtml">
        <xsl:copy-of select="xhtml2cals:expand-rowspans($source-row, $processed-row)"/>
      </tr>
    </xsl:variable>
    <!-- et dans la ligne ou les rowspans ont été expansés, on traite ensuite les colspans -->
    <xsl:variable name="expanded-row" as="element()">
      <tr xmlns="http://www.w3.org/1999/xhtml">
        <xsl:copy-of select="xhtml2cals:expand-colspans($expanding-row/node())"/>
      </tr>
    </xsl:variable>
    <xsl:copy-of select="$expanded-row"/>
  </xsl:function>

  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>Expanse les colspans s'une ligne. On crée des cellules avec l'attribut xhtml2cals:DummyCell pour
        expanser. L'attribut est converti en xhtml2cals:colspan.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:expand-colspans-test" as="item()+">
    <xsl:param name="source-row" as="element()"/>
    <xsl:for-each select="$source-row/*">
      <xsl:variable name="cell" select="." as="element()"/>
      <xsl:choose>
        <xsl:when test="@colspan &gt; 1">
          <xsl:copy>
            <xsl:copy-of select="@* except @colspan"/>
            <xsl:attribute name="xhtml2cals:colspan" select="@colspan"/>
            <xsl:copy-of select="node()"/>
          </xsl:copy>
          <xsl:for-each select="reverse(1 to (xs:integer(@colspan) - 1))">
            <xsl:element name="{$cell/name()}">
              <xsl:attribute name="xhtml2cals:DummyCell">yes</xsl:attribute>
              <xsl:copy-of select="$cell/(@* except @colspan)"/>
              <xsl:attribute name="xhtml2cals:colspan" select="."/>
              <xsl:comment>
                <xsl:copy-of select="$cell/node()"/>
              </xsl:comment>
            </xsl:element>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
  
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
          <xsl:copy-of select="$current-cell/child::node()" copy-namespaces="no"/>
        </xsl:element>
        <!-- If there is a colspan add padding cells  -->
        <xsl:for-each select="2 to (xs:integer(@colspan))">
          <xsl:element name="{$element-name}" namespace="http://www.w3.org/1999/xhtml"
            inherit-namespaces="no">
            <xsl:attribute name="xhtml2cals:DummyCell" select="'yes'"/>
            <xsl:copy-of select="$current-cell/@*[not(name() = 'colspan')]" copy-namespaces="no"/>
            <xsl:attribute name="xhtml2cals:colspan" select="$current-cell/@colspan +1 - ."/>
            <xsl:comment>
              <xsl:copy-of select="$current-cell/child::node()" copy-namespaces="no"/>
            </xsl:comment>
          </xsl:element>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy-of select="$expand-columns"/>
  </xsl:function>
  
  <xd:doc scope="component" xml:lang="fr">
    <xd:desc>
      <xd:p>Expanse une ligne, en tenant compte des expansions verticales de la ligne précédente.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="xhtml2cals:expand-rowspans" as="item()+">
    <xsl:param name="source-row" as="element()+"/>
    <xsl:param name="processed-row" as="element()"/>
    <!-- On parcourt suivant la ligne déjà processée, car elle va porter les attributs xhtml2cals:rowspan
      indiquant qu'il va y avoir des cellules à expanser dans la ligne cible -->
    <xsl:for-each select="$processed-row/*">
      <xsl:choose>
        <xsl:when test="@xhtml2cals:rowspan &gt; 1">
          <!-- une cellule à insérer -->
          <xsl:copy>
            <xsl:attribute name="xhtml2cals:DummyCell" select="'yes'"/>
            <xsl:copy-of select="@* except @xhtml2cals:rowspan"/>
            <xsl:attribute name="xhtml2cals:rowspan" select="number(@xhtml2cals:rowspan) - 1"/>
            <xsl:comment>
              <xsl:copy-of select="node()"/>
            </xsl:comment>
          </xsl:copy>
        </xsl:when>
        <xsl:otherwise>
          <!-- Pas de cellule à insérer, on va copier la cellule de la ligne source  -->
          <xsl:variable name="current-column" select="count(preceding-sibling::*) + 1" as="xs:integer"/>
          <xsl:variable name="spanned-row-cells"
            select="count(preceding-sibling::*[@xhtml2cals:rowspan &gt; 1])" as="xs:integer"/>
          <xsl:choose>
            <xsl:when test="count(xhtml2cals:select-cell($current-column - $spanned-row-cells, $source-row, 1, 0)) != 0">
              <xsl:copy-of
                select="xhtml2cals:select-cell($current-column - $spanned-row-cells, $source-row, 1, 0)"
                copy-namespaces="no"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:message terminate="no">ERROR $current-column= <xsl:value-of select="$current-column"/>, $spanned-row-cells= <xsl:value-of select="$spanned-row-cells"/> </xsl:message>
            </xsl:otherwise>
          </xsl:choose>
          <!--<xsl:copy-of
            select="xhtml2cals:select-cell($current-column - $spanned-row-cells, $source-row, 1, 0)"
            copy-namespaces="no"/>-->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="xhtml2cals:select-cell">
    <!-- Current Column Being Processed  -->
    <xsl:param name="src-column-no" as="xs:integer"/>
    <!-- Current table show being processed -->
    <xsl:param name="source-row" as="element()+"/>
    <!-- Current column being examised to copy -->
    <xsl:param name="current-column-count" as="xs:integer"/>
    <!-- Total of the spans already checked -->
    <xsl:param name="current-span-col-total" as="xs:double"/>
    <!-- colspan of the current cell being examined-->
    <xsl:variable name="current-cell" select="$source-row/*[$current-column-count]"/> <!--as="element()*"-->
    <xsl:variable name="current-span"> <!-- as="xs:integer" select="($current-cell/@colspan[. castable as xs:integer], 1)[1]"-->
      <xsl:choose>
        <xsl:when test="$current-cell/@colspan">
          <xsl:value-of select="$current-cell/@colspan"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- Current column being processed matches the end of the span. i.e. span finishes here.  Output cell -->
      <xsl:when test="$src-column-no = $current-span-col-total + $current-span">
        <xsl:choose>
          <xsl:when test="$current-cell/@rowspan">
            <td xmlns="http://www.w3.org/1999/xhtml">
              <xsl:attribute name="xhtml2cals:rowspan" select="$current-cell/@rowspan"/>
              <xsl:copy-of select="$current-cell/(@* except @rowspan)"/>
              <xsl:copy-of select="$current-cell/node()"/>
            </td>
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
    <!-- ===================================================================-->
    <!-- Mode convert-to-cals  -->
    <!-- ===================================================================-->
  </xd:doc>

  <xsl:template match="table" mode="xhtml2cals:convert-to-cals">
    <table>
      <xsl:copy-of select="@id | @class | @align | @width" copy-namespaces="no"/>
      <xsl:call-template name="xhtml2cals:compute-table-borders"/>
      <xsl:call-template name="xhtml2cals:compute-rowsep-colsep-defaults"/>
      <xsl:copy-of select="processing-instruction()|comment()"/>
      <xsl:apply-templates select="caption" mode="#current"/>
      <tgroup>
        <xsl:attribute name="cols" select="xhtml2cals:nb-cols(.)"/>
        <xsl:call-template name="xhtml2cals:make-colspec">
          <xsl:with-param name="context" select="colgroup | col"/>
        </xsl:call-template>
        <!-- FIXME à rebrancher quand on gérera mieux les spanspec dans le modèle -->
        <!-- <xsl:call-template name="make-spanspec">
          <xsl:with-param name="context" select="colgroup | col"/>
        </xsl:call-template> -->
        <xsl:apply-templates select="thead, tfoot, tbody" mode="#current"/>
      </tgroup>
    </table>
  </xsl:template>
  
  <xsl:template name="xhtml2cals:compute-table-borders">
    <xsl:attribute name="frame">
      <xsl:choose>
        <xsl:when test="@frame and (not(@border) or @border!=0)">
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
        <xsl:when test="not(@frame) and @border != 0">all</xsl:when>
        <xsl:when test="@style">
          <xsl:variable name="style.parsed" select="css:parse-inline(@style)" as="element(css:css)"/>
          <!--cf. http://www.datypic.com/sc/cals/a-nons_frame.html-->
          <xsl:choose>
            <xsl:when test="css:definesBorderTop($style.parsed) and css:definesBorderRight($style.parsed) and css:definesBorderBottom($style.parsed) and css:definesBorderLeft($style.parsed)">
              <xsl:text>all</xsl:text>
            </xsl:when>
            <xsl:when test="css:definesBorderTop($style.parsed) and not(css:definesBorderRight($style.parsed)) and css:definesBorderBottom($style.parsed) and not(css:definesBorderLeft($style.parsed))">
              <xsl:text>topbot</xsl:text>
            </xsl:when>
            <xsl:when test="not(css:definesBorderTop($style.parsed)) and css:definesBorderRight($style.parsed) and not(css:definesBorderBottom($style.parsed)) and css:definesBorderLeft($style.parsed)">
              <xsl:text>sides</xsl:text>
            </xsl:when>
            <xsl:when test="css:definesBorderTop($style.parsed) and not(css:definesBorderRight($style.parsed)) and not(css:definesBorderBottom($style.parsed)) and not(css:definesBorderLeft($style.parsed))">
              <xsl:text>top</xsl:text>
            </xsl:when>
            <xsl:when test="not(css:definesBorderTop($style.parsed)) and not(css:definesBorderRight($style.parsed)) and css:definesBorderBottom($style.parsed) and not(css:definesBorderLeft($style.parsed))">
              <xsl:text>bottom</xsl:text>
            </xsl:when>
            <xsl:when test="not(css:definesBorderTop($style.parsed)) and not(css:definesBorderRight($style.parsed)) and not(css:definesBorderBottom($style.parsed)) and not(css:definesBorderLeft($style.parsed))">
              <xsl:text>none</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>none</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
  
  <xsl:template name="xhtml2cals:compute-rowsep-colsep-defaults">
    <xsl:choose>
      <xsl:when test="@border !=0 and not(@rules)">
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
  
  <!-- template recursif: On parcourt un element col ou colgroup, on génère le ou les colspec 
        correspondant, -->
  <xsl:template name="xhtml2cals:make-colspec">
    <!-- colgroup list or col list -->
    <xsl:param name="context" as="element()*"/>
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
              <colspec colname="{concat('col', ($colnum + .))}">
                <xsl:if test=". = 1">
                  <!-- GMA ou pour tous? -->
                  <xsl:copy-of select="$context[$index]/(@align | @charoff | @char)"/>
                </xsl:if>
                <xsl:if test="$context[$index]/@width">
                  <xsl:attribute name="colwidth" select="$context[$index]/@width"/>
                </xsl:if>
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
  
  <!-- template recursif: On parcourt la un element col ou colgroup, on génère le ou les spanspec 
        correspondant, -->
  <xsl:template name="xhtml2cals:make-spanspec">
    <!-- colgroup list or col list -->
    <xsl:param name="context" as="element()*"/>
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
        <xsl:if
          test="(count($context[$index]/col) &gt; 1) or ((count($context[$index]/col) = 0) and ($span &gt; 1))">
          <spanspec 
            spanname="{concat('span', ($colnum + 1), '-', $span)}" 
            namest="{concat('col', ($colnum + 1))}" 
            nameend="{concat('col', ($colnum + $span))}">
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
        <!-- Tail recursion -->
        <xsl:call-template name="xhtml2cals:make-spanspec">
          <xsl:with-param name="context" select="$context"/>
          <xsl:with-param name="index" select="$index + 1"/>
          <xsl:with-param name="colnum" select="$colnum + $span"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="caption" mode="xhtml2cals:convert-to-cals">
    <title>
      <xsl:copy-of select="@id | @class | @style" copy-namespaces="no"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </title>
  </xsl:template>
  
  <xsl:template match="thead" mode="xhtml2cals:convert-to-cals">
    <thead>
      <xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign"
        copy-namespaces="no"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </thead>
  </xsl:template>
  
  <xsl:template match="tfoot" mode="xhtml2cals:convert-to-cals">
    <tfoot>
      <xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign"
        copy-namespaces="no"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </tfoot>
  </xsl:template>
  
  <xsl:template match="tbody" mode="xhtml2cals:convert-to-cals">
    <tbody>
      <xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign"
        copy-namespaces="no"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </tbody>
  </xsl:template>
  
  <xsl:template match="tr" mode="xhtml2cals:convert-to-cals">
    <row>
      <xsl:copy-of select="@id | @class | @style | @align | @char | @charoff | @valign"
        copy-namespaces="no"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </row>
  </xsl:template>
  
  <xsl:template match="td|th" mode="xhtml2cals:convert-to-cals">
    <entry>
      <xsl:variable name="curr-col-num" as="xs:integer" select="count(preceding-sibling::*) + 1"/>            
      <!-- copy attributes with same name -->            
      <!-- If no @valign use col/@valign, @valign="baseline" has no correspondence in CALS -->
      <xsl:copy-of select="(@valign, (../../..//col)[$curr-col-num]/@valign)[1][not(. = 'baseline')]"/>
      <xsl:copy-of select="@id | @class | @align | @char | @charoff "/>
      <xsl:if test="not(@xhtml2cals:DummyCell)">
        <xsl:if test="@xhtml2cals:rowspan &gt; 1">
          <xsl:attribute name="morerows" select="number(@xhtml2cals:rowspan)-1"/>
        </xsl:if>
        <xsl:if test="@xhtml2cals:colspan &gt; 1">
          <xsl:attribute name="namest" select="concat('col', count(preceding-sibling::*)+1)"/>
          <xsl:attribute name="nameend" select="concat('col', count(preceding-sibling::*)+@xhtml2cals:colspan)"/>
        </xsl:if>
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
          <xsl:when test="ancestor::table[1]/@rules = 'groups' and not(../following-sibling::tr)"><xsl:sequence select="true()"/></xsl:when>
          <xsl:when test="ancestor::table[1]/@rules = 'rows'"><xsl:sequence select="true()"/></xsl:when>
          <xsl:when test="ancestor::table[1]/@rules = 'all'"><xsl:sequence select="true()"/></xsl:when>
          <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
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
  
  <xsl:template match="td[@xhtml2cals:DummyCell='yes'] | th[@xhtml2cals:DummyCell='yes']" mode="xhtml2cals:convert-to-cals" priority="15"/>
  
  <xsl:template match="@* | node()" mode="xhtml2cals:convert-to-cals">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <!-- ======================================================================-->
    <!-- Mode xhtml2cals:optimize-cals-->
    <!-- ======================================================================-->
  </xd:doc>
  
  <xsl:template match="@*|node()" mode="xhtml2cals:optimize-cals">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
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
  
  <!--convert data-cals attributes to cals format when le html originaly comes from ths cals2html.xsl of the repo-->
  <xsl:template match="@*[starts-with(local-name(), 'data-cals-')]" mode="xhtml2cals:optimize-cals">
    <xsl:attribute name="{substring-after(local-name(), 'data-cals-')}" select="."/>
  </xsl:template>
  
  <xsl:template match="@class" mode="xhtml2cals:optimize-cals">
    <xsl:variable name="new-class" as="xs:string*">
      <xsl:for-each select="tokenize(., '\s+')">
        <xsl:variable name="value" select="." as="xs:string"/>
        <xsl:choose>
          <xsl:when test="starts-with($value, 'cals_')">
            <!--delete cals specific cals attribute value inerited from conversion cals2html.xsl--> 
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
  
  <xd:doc>
    <!-- ======================================================================-->
    <!-- Mode xhtml2cals:convert-cals-namespace -->
    <!-- ======================================================================-->
  </xd:doc>
  
  <xsl:template match="cals:*" mode="xhtml2cals:convert-cals-namespace">
    <xsl:element name="{local-name(.)}" namespace="{$xslLib:cals.ns.uri}">
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