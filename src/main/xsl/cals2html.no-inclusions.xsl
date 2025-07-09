<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns:calstable="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all"
  version="3.0"
  >
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Convert CALS Table to HTML table</xd:p>
      <xd:p>Each cals:table will be converted to an html:div, then each cals:tgroup will be converted to an html:table</xd:p>
      <xd:p>/!\ Cals elements must be in cals namespace before proceding, other elements will be copied as is, 
        set param $xslLib:cals2html.set-cals-ns to true if you want to let this XSLT preform this namespace operation</xd:p>
      <xd:p>Upper or lower-case cals structure will be converted the same thanks to lower-case normalization</xd:p>
      <xd:p>CALS specification interpretation : </xd:p>
      <xd:ul>table/@frame is applied on each tgroups (not the whole table)</xd:ul>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common.xsl"/>
  <xsl:import href="setXmlBase.xsl"/>
  <xsl:import href="removeXmlBase.xsl"/>
  <xsl:import href="setCalsTableNS.xsl"/>
  <xsl:import href="normalizeCalsTable.xsl"/>
  
  <!--KEYS-->
  <xsl:key name="xslLib:cals2html.getGhostEntriesByRid" match="entry[@calstable:rid]" use="@calstable:rid"/>
  
  <!--PARAMETERS-->
  <!--common-->
  <xsl:param name="xslLib:cals2html.log.uri" select="resolve-uri('log/', base-uri())" as="xs:string"/>
  <xsl:param name="xslLib:cals2html.debug" select="false()" as="xs:boolean"/>
  <xsl:param name="xslLib:cals2html.set-cals-ns" select="false()" as="xs:boolean"/>
  <!--structure-->
  <xsl:param name="xslLib:cals2html.html-version" select="5" as="xs:double"/> <!--4 or 5 for example-->
  <xsl:param name="xslLib:cals2html.use-style-insteadOf-class" select="true()" as="xs:boolean"/>
  <xsl:param name="xslLib:cals2html-keep-unmatched-attributes" select="false()" as="xs:boolean"/>
  <xsl:param name="xslLib:cals2html-unmatched-attributes-prefix" select="'data-cals2html-'" as="xs:string"/>
  <xsl:param name="xslLib:cals2html.compute-column-width-as-width-attribute" select="true()" as="xs:boolean"/> <!--@width is used for html4 output-->
  <xsl:param name="xslLib:cals2html.compute-column-width-within-colgroup" select="true()" as="xs:boolean"/>
  <!--If the number of columns is greater than $nb-cols-max-before-font-reduction then the font needs to be reduced-->
  <xsl:param name="xslLib:cals2html.nb-cols-max-before-font-reduction" select="8" as="xs:integer"/>
  <xsl:param name="xslLib:cals2html.nb-cols-max-before-large-font-reduction" select="14" as="xs:integer"/>
  <!--default colsep/rowsep-->
  <xsl:param name="xslLib:cals2html.default-colsep" select="'yes'" as="xs:string"/>
  <xsl:param name="xslLib:cals2html.default-rowsep" select="'yes'" as="xs:string"/>
  <!--default align/valign-->
  <xsl:param name="xslLib:cals2html.default-tgroup-align" select="'left'" as="xs:string"/>
  <xsl:param name="xslLib:cals2html.default-td-align" select="'left'" as="xs:string"/><!--default browser value-->
  <xsl:param name="xslLib:cals2html.default-th-align" select="'center'" as="xs:string"/><!--default browser value-->
  <xsl:param name="xslLib:cals2html.default-tgroup-valign" select="'top'" as="xs:string"/><!--default cals value-->
  <xsl:param name="xslLib:cals2html.default-td-valign" select="'middle'" as="xs:string"/><!--default browser value-->
  <xsl:param name="xslLib:cals2html.default-th-valign" select="'middle'" as="xs:string"/><!--default browser value-->
  <!-- force @align / @valign default values to be specified in HTML (as class or css)-->
  <xsl:param name="xslLib:cals2html.default-align-force-explicit" select="false()" as="xs:boolean"/>
  <xsl:param name="xslLib:cals2html.default-valign-force-explicit" select="false()" as="xs:boolean"/>
  <!--force to merge multiple tgroup table into a single html table: be carefull this might have side effect 
    (loose tgroupstyle or adding colspan that will make the table look a bit different)-->
  <xsl:param name="xslLib:cals2html.forceMergingMultipleTgroup" select="false()" as="xs:boolean"/>
  <!--When html border collapse (table border and cells borders are collapsing) one can set borders on cells only and set no border at table-->
  <xsl:param name="xslLib:cals2html.html-border-collapse" select="false()" as="xs:boolean"/>
  
  <!--==============================================================================================================================-->
  <!-- INIT -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/">
    <xsl:apply-templates select="/" mode="xslLib:cals2html"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- DRIVER -->
  <!--==============================================================================================================================-->
  
  <xsl:template match="/" mode="xslLib:cals2html">
    <!--STEP1 : set xml:base to init multi-step-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="xslLib:setXmlBase"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step1.setXmlBase.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP2 : add cals namespace on table elements if asked for-->
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:cals2html.set-cals-ns">
          <xsl:document>
            <xsl:apply-templates select="." mode="xslLib:setCalsTableNS.main"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step2.setCalsTableNS.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP3 : normalize cals table-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:normalizeCalsTable.main"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step3.normalizeCalsTable.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP4 : move attributes down to entries-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:cals2html.moveAttributesDownEntries"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step4.moveAttributesDownEntries.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>    
    <!--STEP5 : merge tgroup if asked-->
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:cals2html.forceMergingMultipleTgroup">
          <xsl:document>
            <xsl:apply-templates select="$step" mode="xslLib:cals2html.mergeTgroups"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step5.mergeTgroups-if-asked.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP6 : cals2html.main-->
    <xsl:variable name="step" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step" mode="xslLib:cals2html.main"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step6.cals2html.main.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP7 : convert class2style-->
    <xsl:variable name="step" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:cals2html.use-style-insteadOf-class">
          <xsl:document>
            <xsl:apply-templates select="$step" mode="xslLib:cals2html.class2style"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step7.class2style.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step"/>
      </xsl:result-document>
    </xsl:if>
    <!--FINALY-->
    <xsl:apply-templates select="$step" mode="xslLib:removeXmlBase"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- STEP 1 : set xml:base to init multi-step -->
  <!--==============================================================================================================================-->
  
  <!--see setXmlBase.xsl-->
  
  <!--==============================================================================================================================-->
  <!-- STEP 2 : add cals namespace on table elements if asked for -->
  <!--==============================================================================================================================-->
  
  <!--see setCalsTableNS.xsl-->
  
  <!--==============================================================================================================================-->
  <!-- STEP 3 : normalize cals table -->
  <!--==============================================================================================================================-->
  
  <!--see normalizeCalsTable.xsl-->
  
  <!--==============================================================================================================================-->
  <!-- STEP 4 : move attributes down to entries-->
  <!--==============================================================================================================================-->
  
  <!--copy template-->
  <xsl:template match="node() | @*" mode="xslLib:cals2html.moveAttributesDownEntries">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Add explicit cals attributes value on entry by resolving cals attributs inheritance for 
  'colsep', 'rowsep', 'align', 'valign' except (FIXME) : 'char', 'charoff'--> 
  <xsl:template match="entry[not(@calstable:rid)]" mode="xslLib:cals2html.moveAttributesDownEntries">
    <xsl:variable name="current-colspec-list" select="xslLib:cals2html.get-colspecs(.)" as="element(colspec)*"/>
    <xsl:variable name="tgroup" select="ancestor::tgroup[1]" as="element(tgroup)"/>
    <xsl:variable name="table" select="ancestor::table[1]" as="element(table)"/>
    <xsl:variable name="colsep-current" as="xs:string">
      <xsl:choose>
        <!--when tgroup merge is asked, and there are multiple tgroup in the current table
        and the entry is one that touch right border of the table, table frame setting wins-->
        <xsl:when test="$xslLib:cals2html.forceMergingMultipleTgroup and count($table/tgroup) gt 1 
          and xslLib:cals2html.getOutlineCellPositions(.) = 'right'">
          <xsl:choose>
            <xsl:when test="$table/@frame = ('all', 'sides')">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@colsep">
          <xsl:value-of select="@colsep"/>
        </xsl:when>
        <!-- FIXME : que se passe-t-il lors d'un colspan ? a priori c'est le namest qui gagne-->
        <xsl:when test="$current-colspec-list[1]/@colsep">
          <xsl:value-of select="$current-colspec-list[1]/@colsep" />
        </xsl:when>
        <xsl:when test="ancestor::cals:*/@colsep">
          <xsl:value-of select="ancestor::cals:*[@colsep][1]/@colsep" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xslLib:cals2html.default-colsep"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rowsep-current" as="xs:string">
      <xsl:choose>
        <!--when tgroup merge is asked, and there are multiple tgroup in the current table
        and the entry is one that touch the bottom border of the table, table frame setting wins-->
        <xsl:when test="$xslLib:cals2html.forceMergingMultipleTgroup and count($table/tgroup) gt 1 
          and xslLib:cals2html.getOutlineCellPositions(.) = 'bottom'">
          <xsl:choose>
            <xsl:when test="$table/@frame = ('all', 'bottom', 'topbot')">
              <!--info : we could also add "and $tgroup/following-sibling::tgroup" here, it would work too-->
              <xsl:text>1</xsl:text>
            </xsl:when>
            <!--We are here at the end of a tgroup, if there's a following tgroup
            and if frame is top we must set rowsep at bottom (to "simulate" top border of next tgroup)-->
            <xsl:when test="$table/@frame = 'top' and $tgroup/following-sibling::tgroup">
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@rowsep">
          <xsl:value-of select="@rowsep"/>
        </xsl:when>
        <!-- FIXME : que se passe-t-il lors d'un colspan ? a priori c'est le namest qui gagne-->
        <xsl:when test="$current-colspec-list[1]/@rowsep">
          <xsl:value-of select="$current-colspec-list[1]/@rowsep"/>
        </xsl:when>
        <!--@rowsep allowed on table|tgroup|row-->
        <xsl:when test="ancestor::cals:*/@rowsep">
          <xsl:value-of select="ancestor::cals:*[@rowsep][1]/@rowsep"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xslLib:cals2html.default-rowsep"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="align-current" as="xs:string">
      <xsl:choose>
        <xsl:when test="@align">
          <xsl:value-of select="@align"/>
        </xsl:when>
        <!-- FIXME : que se passe-t-il lors d'un colspan ? a priori c'est le namest qui gagne-->
        <xsl:when test="$current-colspec-list[1]/@align">
          <xsl:value-of select="$current-colspec-list[1]/@align"/>
        </xsl:when>
        <!--@align is allowed on tgroup only (not table, thead, tbody, tfoot,row)-->
        <xsl:when test="ancestor::cals:*/@align">
          <xsl:value-of select="ancestor::cals:*[@align][1]/@align"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xslLib:cals2html.default-tgroup-align"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="valign-current" as="xs:string">
      <xsl:choose>
        <xsl:when test="@valign">
          <xsl:value-of select="@valign"/>
        </xsl:when>
        <!--@valign is actually not allowed on colspec--> 
        <!--<xsl:when test="$current-colspec-list[1]/@valign">
          <xsl:value-of select="$current-colspec-list[1]/@valign" />
        </xsl:when>-->
        <xsl:when test="ancestor::cals:*/@valign">
          <xsl:value-of select="ancestor::cals:*[@valign][1]/@valign" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xslLib:cals2html.default-tgroup-valign"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy copy-namespaces="false">
      <!--copy current attributes (cals attribute will be overwritten afterwards in this template)-->
      <xsl:apply-templates select="@*" mode="#current"/>
      <!--Set cals attributes values-->
      <xsl:attribute name="colsep" select="$colsep-current"/>
      <xsl:attribute name="rowsep" select="$rowsep-current"/>
      <xsl:attribute name="align" select="$align-current"/>
      <xsl:attribute name="valign" select="$valign-current"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Delete attributes that have been moved to entries-->
  <xsl:template match="cals:*[not(self::entry)]/@*[name() = ('colsep', 'rowsep', 'align', 'valign', 'char', 'charoff')]"
    mode="xslLib:cals2html.moveAttributesDownEntries"/>
  
  <!--==============================================================================================================================-->
  <!-- STEP 5 : merge tgroups-->
  <!--==============================================================================================================================-->
  
  <xsl:mode name="xslLib:cals2html.mergeTgroups" on-no-match="shallow-copy"/>
  
  <!--Merge tgroups except when there are tfoot (which is difficult to merge here, FIXME later ?)-->
  <xsl:template match="table[count(tgroup) gt 1][not(tgroup/tfoot)]"
    mode="xslLib:cals2html.mergeTgroups">
    <xsl:variable name="max.cols" select="xs:integer(max(tgroup/@cols))" as="xs:integer"/>
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*" mode="#current"/>
      <!--adjacency condition : name is tgroup, keep other foreign markup if any --> 
      <xsl:for-each-group select="*" group-adjacent="local-name(.)">
        <xsl:choose>
          <xsl:when test="current-group()[1]/local-name(.) = 'tgroup' and count(current-group()) gt 1">
            <!--At this point align/valign/colsep/rowsep have been moved to entries-->
            <cals:tgroup>
              <!--different @tgroupstyle values might be loosed at this point-->
              <xsl:sequence select="current-group()[1]/@*"/>
              <!--after moveAttributesDownEntries step, colspec is still necessary for colwidth and cells spanning (entry/@namest and entry/@nameend)
              let's keep the first maxsize one, it will drive some colwidth all allong the new table--> 
              <xsl:apply-templates select="(current-group()[xs:integer(@cols) = $max.cols])[1]/colspec" mode="#current"/>
              <!--No more <thead> here, an annotation will be add to keep thead cells information, and later convert them to html:th-->
              <cals:tbody>
                <xsl:apply-templates select="current-group()/*[self::thead or self::tbody]/row" mode="#current">
                  <xsl:with-param name="max.cols" select="$max.cols" as="xs:integer" tunnel="true"/>
                </xsl:apply-templates>
              </cals:tbody>
            </cals:tgroup>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="#current"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group> 
    </xsl:copy>
  </xsl:template>
  
  <!--Add html annotations to be used later in the main cals2html step-->
  <!--FIXME : entrytbl is not implement here-->
  <xsl:template match="table[count(tgroup) gt 1][not(tgroup/tfoot)]/tgroup/*[self::thead or self::tbody]/row/entry"
    mode="xslLib:cals2html.mergeTgroups">
    <xsl:param name="max.cols" as="xs:integer" tunnel="true"/>
    <xsl:variable name="cols" select="xs:integer(ancestor::tgroup[1]/@cols)" as="xs:integer"/>
    <xsl:variable name="nbColsToAdd" select="$max.cols - $cols" as="xs:integer"/>
    <xsl:copy copy-namespaces="false">
      <!--add an annotation to add fictiv cols in the merged cals table-->
      <!--expand 1st entry that have less cols than the merge table--> 
      <xsl:if test="not(preceding-sibling::entry) and $nbColsToAdd != 0">
        <xsl:attribute name="html:colspanToAdd" select="$nbColsToAdd"/>
      </xsl:if>
      <!--Add an annotation to keep the information that this cell was a thead entry-->
      <xsl:if test="parent::row/parent::thead">
        <xsl:attribute name="html:name" select="'th'"/>
      </xsl:if>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Update references to colspec: colname, namest and nameend values-->
  <xsl:template match="table[count(tgroup) gt 1][not(tgroup/tfoot)]/tgroup/*[self::thead or self::tbody]/row/entry
    /@*[local-name() = ('colname', 'namest', 'nameend')]"
    mode="xslLib:cals2html.mergeTgroups">
    <xsl:variable name="value" select="." as="xs:string"/>
    <xsl:variable name="colspec" select="ancestor::tgroup[1]/colspec[@colname = $value]" as="element(colspec)*"/>
    <xsl:choose>
      <xsl:when test="count($colspec) != 1">
        <xsl:message expand-text="true">[ERROR][cals2html.xsl] no colspec found for {name()}="{.}"</xsl:message>
        <xsl:message terminate="true"><xsl:copy-of select="ancestor::tgroup[1]/colspec"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="colspec.position" select="count($colspec/preceding-sibling::colspec) + 1" as="xs:integer"/>
        <xsl:attribute name="{name()}" select="'c' || $colspec.position"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--update colspec : colname-->
  <xsl:template match="table[count(tgroup) gt 1][not(tgroup/tfoot)]/tgroup/colspec/@colname"
    mode="xslLib:cals2html.mergeTgroups">
    <xsl:attribute name="colname" select="'c' || count(../preceding-sibling::colspec) + 1"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- STEP 6 : cal2html.main -->
  <!--==============================================================================================================================-->
  
  <!--<xsl:mode name="xslLib:cals2html.main" on-no-match="shallow-copy" />-->
  
  <!--copy template-->
  <xsl:template match="node() | @*" mode="xslLib:cals2html.main">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- TABLE -->
  <!-- CALS MODEL : table ::= title, tgroup+ -->
  <!-- Inherit rowsep : if @rowsep undefined then inherit it, else use it-->
  <xsl:template match="table" mode="xslLib:cals2html.main">
    <!-- https://www.oasis-open.org/specs/tm9901.html#AEN282 : 
         "All tgroups of a table shall have the same width, so the table frame can surround them uniformly"
          FIXME => adding a table container to ensure this ? (CHAINEXML-872)-->
    <div class="cals_table">
      <!--@id | @tabstyle | @orient | @pgwide | @shortentry | @ tocentry-->
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/>
      <xsl:apply-templates mode="#current"/>
    </div>
  </xsl:template>
  
  <xsl:template match="caption" mode="xslLib:cals2html.main">
    <!-- no operation : everything has already been put within html:table/html:caption element -->
  </xsl:template>
  
  <!-- TGROUP : start Html Table structure -->
  <!-- CALS MODEL : tgroup ::= colspec+, thead?, tbody-->
  <xsl:template match="tgroup" mode="xslLib:cals2html.main">
    <table>
      <!--attributes that doesn't generate @style or @class like : ../@orient | @id ?-->
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/> 
      <xsl:variable name="class.tmp" as="xs:string*">
        <!--Assume : frame is applied on each tgroups (not the whole table)-->
        <xsl:text>cals_tgroup</xsl:text>
        <!--cals:table/@frame ::= none | top | bottom | topbot | sides | all
        default "all" has been set at normalizeCalsTable step-->
        <!--When border collapse, set the frame to "none" because frame border has been set on the cells-->
        <xsl:variable name="frame" as="xs:string" 
          select="if ($xslLib:cals2html.html-border-collapse) then ('none') else (ancestor::table/@frame)"/>
        <xsl:value-of select="'cals_frame-' || $frame"/>
      </xsl:variable>
      <xsl:if test="not(empty($class.tmp))">
        <xsl:attribute name="class" select="string-join($class.tmp, ' ')"/>
      </xsl:if>
      <xsl:variable name="style.tmp" as="xs:string*">
        <xsl:if test="../@pgwide = '1'">
          <xsl:text>width:100%</xsl:text>
        </xsl:if>
      </xsl:variable>
      <xsl:if test="not(empty($style.tmp))">
        <xsl:attribute name="style" select="string-join($style.tmp, ' ')"/>
      </xsl:if>
      <xsl:if test="$xslLib:cals2html.compute-column-width-within-colgroup and exists(colspec)">
        <colgroup>
          <xsl:variable name="colspec" select="colspec" as="element(colspec)*"/>
          <xsl:for-each select="colspec">
            <col>
              <xsl:call-template name="xslLib:cals2html.add-column-width">
                <xsl:with-param name="colspec-list-for-total-width" select="$colspec" as="element(colspec)*"/>
                <xsl:with-param name="colspec-list-for-current-width" select="." as="element(colspec)*"/>
              </xsl:call-template>
            </col>
          </xsl:for-each>
        </colgroup>
      </xsl:if>
      <xsl:if test="normalize-space(@cols) != '' and not(normalize-space(@cols) castable as xs:integer)">
        <xsl:message terminate="no">[ERROR][xslLib:cals2html] @cols="<xsl:value-of select="@cols"/>" is not an integer</xsl:message>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </table>
  </xsl:template>
  
  <!-- Table Head -->
  <!-- CALS MODEL : thead ::= colspec*,row+ -->
  <xsl:template match="thead" mode="xslLib:cals2html.main">
    <thead>
      <xsl:apply-templates mode="#current"/>
    </thead>
  </xsl:template>
  
  <xsl:template match="colspec" mode="xslLib:cals2html.main">
    <!-- no operation -->
  </xsl:template>
  
  <xsl:template match="spanspec" mode="xslLib:cals2html.main">
    <!-- no operation -->
  </xsl:template>
  
  <!-- Table Foot -->
  <!-- CALS MODEL : tfoot ::= colspec*,row+ -->
  <xsl:template match="tfoot" mode="xslLib:cals2html.main">
    <tfoot>
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/>
      <xsl:apply-templates mode="#current"/>
    </tfoot>
  </xsl:template>
  
  <!-- Table body -->
  <!-- CALS MODEL : tbody ::= row+-->
  <xsl:template match="tbody" mode="xslLib:cals2html.main">
    <tbody>
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/>
      <xsl:apply-templates mode="#current"/>
    </tbody>
  </xsl:template>
  
  <!-- Table Row -->
  <!-- CALS MODEL : row ::= entry+ -->
  <xsl:template match="row" mode="xslLib:cals2html.main">
    <tr>
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/> 
      <xsl:variable name="class.tmp" as="xs:string*">
        <!--<xsl:if test="$xslLib:cals2html.add-odd-even-class">
          <xsl:value-of select="if (count(preceding-sibling::row) mod 2 = 0) then 'cals_odd' else 'cals_even'"/>
        </xsl:if>-->
      </xsl:variable>
      <xsl:if test="not(empty($class.tmp))">
        <xsl:attribute name="class" select="string-join($class.tmp, ' ')"/>
      </xsl:if>
      <xsl:variable name="style.tmp" as="xs:string*">
        <!--<xsl:sequence select="@bgcolor"/>-->
      </xsl:variable>
      <xsl:if test="not(empty($style.tmp))">
        <xsl:attribute name="style" select="string-join($style.tmp, ' ')"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </tr>
  </xsl:template>

  <!-- Table Cell -->
  <!-- CALS MODEL : entry ::=  "global model dependent"-->
  
  <!--delete transpect ghost entries-->
  <xsl:template match="entry[@calstable:rid]" mode="xslLib:cals2html.main"/>
  
  <xsl:template match="entry[not(@calstable:rid)]" mode="xslLib:cals2html.main">
    <xsl:variable name="nb-cols" select="ancestor::tgroup[1]/@cols[. castable as xs:integer]" as="xs:integer?"/>
    <xsl:variable name="current-tgroup" select="ancestor::tgroup[1]" as="element()"/>
    <xsl:variable name="current-colspec-list" select="xslLib:cals2html.get-colspecs(.)" as="element(colspec)*"/>
    <xsl:variable name="name" select="if(ancestor::thead or @html:name = 'th') then ('th') else('td')" as="xs:string"/>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/>
      <!--At this point 'colsep', 'rowsep', 'align' and 'valign' have been moved to entries 
        cf. step "xslLib:cals2html.moveAttributesDownEntries"-->
      <xsl:variable name="class.tmp" as="xs:string*">
        <xsl:variable name="colsep" as="xs:string?"
          select="if (@colsep != '0') then ('cals_colsep') else ()"/>
        <xsl:variable name="rowsep" as="xs:string?"
          select="if (@rowsep != '0') then ('cals_rowsep') else ()"/>
        <xsl:choose>
          <xsl:when test="$xslLib:cals2html.html-border-collapse">
            <!--At this point the table @frame has been forced to "none", let's get its original value-->
            <!--if asbent, @frame has been added at normalization-->
            <xsl:variable name="frame" select="ancestor::table[1]/@frame" as="xs:string"/>
            <!--BORDER-RIGHT => COLSEP -->
            <!--When cell border is collapsing with table border we have to apply these rules : 
              - If the cell has no colsep but the table frame defines one at this cell, set it.
              - If the cell has no colsep and the table frame defines an empty one at this cell, keep it
              - If the cell has colsep and the table frame defines an empty one at this cell, keep it
              - If the cell has colsep and the table frame defines one at this cell, keep it-->
            <xsl:choose>
              <xsl:when test="$frame = ('all', 'sides') 
                and xslLib:cals2html.getOutlineCellPositions(.) = 'right' 
                and @colsep = '0'">
                <xsl:text>cals_colsep</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$colsep"/>
              </xsl:otherwise>
            </xsl:choose>
            <!--BORDER-BOTTOM => ROWSEP-->
            <!--When cell border is collapsing with table border we have to apply these rules : 
              - If the cell has no rowsep but the table frame defines one at this cell, set it.
              - If the cell has no rowsep and the table frame defines an empty one at this cell, keep it
              - If the cell has rowsep and the table frame defines an empty one at this cell, keep it
              - If the cell has rowsep and the table frame defines one at this cell, keep it-->
            <xsl:choose>
              <xsl:when test="$frame = ('all', 'bottom', 'topbot')
                (: and not($current-tgroup/following-sibling::tgroup) (:we should check if this is the last tgroup:) :)
                (: NOTE : if so then we shouldn't set the frame (as class) on tgroup (cf. l.440) but on the div class='cals_table'
                Assume : frame is applied on each tgroups (not the whole table) (not the whole table):)
                and xslLib:cals2html.getOutlineCellPositions(.) = 'bottom'
                and @rowsep = '0'">
                <xsl:text>cals_rowsep</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$rowsep"/>
              </xsl:otherwise>
            </xsl:choose>
            <!--BORDER-TOP => no equivalent in CALS-->
            <xsl:if test="$frame = ('all', 'topbot', 'top')
              (: and not($current-tgroup/preceding-sibling::tgroup) (:check this is the 1st tgroup:) :)
              (: NOTE : if so then we shouldn't set the frame (as class) on tgroup (cf. l.440) but on the div class='cals_table'
                 Assume : frame is applied on each tgroups :)
              and xslLib:cals2html.getOutlineCellPositions(.) = 'top'">
              <xsl:text>cals_entry-border-top</xsl:text>
            </xsl:if>
            <!--BORDER-LEFT => no equivalent in CALS-->
            <xsl:if test="$frame = ('all', 'sides')
              and xslLib:cals2html.getOutlineCellPositions(.) = 'left'">
              <xsl:text>cals_entry-border-left</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$colsep"/>
            <xsl:sequence select="$rowsep"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:variable name="align-default" as="xs:string" select="if($name = 'td') then($xslLib:cals2html.default-td-align) else($xslLib:cals2html.default-th-align)"/>
        <xsl:if test="(@align != $align-default) or $xslLib:cals2html.default-align-force-explicit">
          <xsl:value-of select="concat('cals_align-', lower-case(@align))" />
        </xsl:if>
        <xsl:variable name="valign-default" as="xs:string" select="if($name = 'td') then($xslLib:cals2html.default-td-valign) else($xslLib:cals2html.default-th-valign)"/>
        <xsl:if test="(@valign != $valign-default) or $xslLib:cals2html.default-valign-force-explicit">
          <xsl:value-of select="concat('cals_valign-', lower-case(@valign))" />
        </xsl:if>
        <xsl:if test="not(empty($nb-cols))">
          <xsl:if test="$nb-cols > $xslLib:cals2html.nb-cols-max-before-font-reduction
            and $nb-cols lt $xslLib:cals2html.nb-cols-max-before-large-font-reduction">
            <xsl:text>cals_table-font-reduction</xsl:text>
          </xsl:if>
          <xsl:if test="$nb-cols > $xslLib:cals2html.nb-cols-max-before-large-font-reduction">
            <xsl:text>cals_table-max-font-reduction</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:variable>
      <xsl:if test="not(empty($class.tmp))">
        <xsl:attribute name="class" select="string-join($class.tmp, ' ')"/>
      </xsl:if>
      <xsl:variable name="style.tmp" as="xs:string*">
        <!--<xsl:sequence select="@bgcolor"/>-->
      </xsl:variable>
      <xsl:if test="not(empty($style.tmp))">
        <xsl:attribute name="style" select="string-join($style.tmp, ' ')"/>
      </xsl:if>
      <xsl:if test="not($xslLib:cals2html.compute-column-width-within-colgroup)">
        <xsl:call-template name="xslLib:cals2html.add-column-width">
          <xsl:with-param name="colspec-list-for-total-width" select="$current-tgroup/colspec" as="element(colspec)*"/>
          <xsl:with-param name="colspec-list-for-current-width" select="$current-colspec-list" as="element(colspec)*"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="colspan" select="count($current-colspec-list) + xs:integer((@html:colspanToAdd, 0)[1])" as="xs:integer"/>
      <xsl:if test="$colspan > 1">
        <xsl:attribute name="colspan" select="$colspan"/>
      </xsl:if>
      <xsl:if test="normalize-space(@morerows) != '' and normalize-space(@morerows) castable as xs:integer">
        <xsl:attribute name="rowspan" select="xs:integer(@morerows) + 1"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- === COMMON : STEP 4 === -->
  
  <!--Attributes to ignore here because they have already been processed before-->
  <xsl:template match="table/@frame | tgroup/@cols | entry/@namest | entry/@nameend | entry/@colname | entry/@morerows |
    cals:*/@rowsep | cals:*/@colsep | cals:*/@valign | cals:*/@align | table/@pgwide" mode="xslLib:cals2html.attributes"/>
  
  <xsl:template match="table/@orient | table/@tabstyle | table/@shortentry | table/@tocentry | 
    tgroup/@tgroupstyle | entry/@rotate" mode="xslLib:cals2html.attributes" priority="1">
    <!--FIXME : rotate could be done with css3-->
    <xsl:choose>
      <xsl:when test="$xslLib:cals2html.html-version = 5">
        <xsl:attribute name="data-cals-{local-name(.)}" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tgroup/@char | tgroup/@charoff | entry/@char | entry/@charoff" 
    mode="xslLib:cals2html.attributes">
    <xsl:if test="$xslLib:cals2html.html-version le 4">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  <!--delete transpect ghost attributes-->
  <xsl:template match="@calstable:*" mode="xslLib:cals2html.attributes"/>
  
  <!--delete html:name : temporary attribute (used for keeping thead entries information while merging tgroups)-->
  <xsl:template match="@html:name" mode="xslLib:cals2html.attributes"/>
  
  <!--delete html:name : temporary attribute (used for keeping thead entries information while merging tgroups)-->
  <xsl:template match="@html:colspanToAdd" mode="xslLib:cals2html.attributes"/>
  
  <!--Attributes to keep as is-->
  <xsl:template match="@xml:* | @id" mode="xslLib:cals2html.attributes">
    <xsl:copy copy-namespaces="no"/>
  </xsl:template>
  
  <xsl:template match="@*" mode="xslLib:cals2html.attributes">
    <xsl:choose>
      <xsl:when test="$xslLib:cals2html-keep-unmatched-attributes">
        <xsl:attribute name="{concat($xslLib:cals2html-unmatched-attributes-prefix, local-name(.))}" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR] <xsl:value-of select="name(parent::*)"/>/@<xsl:value-of select="name()"/> unmatched in mode "xslLib:cals2html.attributes"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- STEP 7 : convert class2style -->
  <!--==============================================================================================================================-->
  
  <xsl:mode name="xslLib:cals2html.class2style" on-no-match="shallow-copy"/>
  
  <xsl:variable name="xslLib:cals2html.class2style.mapping" as="element()">
    <!--Using cals namespace here so we can match elements with the xpath default namespace-->
    <mapping xmlns="http://docs.oasis-open.org/ns/oasis-exchange/table">
      <!-- frame ne se trouve qu'au niveau de l'élément table -->
      <entry key="cals_frame-top">border-top:1px solid</entry>
      <entry key="cals_frame-bottom">border-bottom:1px solid</entry>
      <entry key="cals_frame-topbot">border-top:1px solid; border-bottom:1px solid</entry>
      <entry key="cals_frame-sides">border-left:1px solid; border-right:1px solid</entry>
      <entry key="cals_frame-all">border:1px solid</entry>
      <entry key="cals_frame-none">border:none</entry>
      <!-- align -->
      <entry key="cals_align-left">text-align:left</entry>
      <entry key="cals_align-right">text-align:right</entry>
      <entry key="cals_align-center">text-align:center</entry>
      <entry key="cals_align-justify">text-align:justify</entry>
      <!-- FIXME sera utile pour les tableaux issus de FrameMaker
      <entry key="cals_alignchar">text-align:left</entry> -->
      <!-- valign -->
      <entry key="cals_valign-top">vertical-align:top</entry>
      <entry key="cals_valign-bottom">vertical-align:bottom</entry>
      <entry key="cals_valign-middle">vertical-align:middle</entry>
      <!-- colsep -->
      <entry key="cals_colsep">border-right:1px solid</entry>
      <!-- rowsep -->
      <entry key="cals_rowsep">border-bottom:1px solid</entry>
      <!--Other values to get the top and left frame when $xslLib:cals2html.html-border-collapse-->
      <entry key="cals_entry-border-top">border-top:1px solid</entry>
      <entry key="cals_entry-border-left">border-left:1px solid</entry>
    </mapping>
  </xsl:variable>
  
  <xsl:template match="html:table[els:hasClass(., 'cals_tgroup')] 
    | html:table[els:hasClass(., 'cals_tgroup')]//*[local-name(.) = ('tr', 'td', 'th', 'thead', 'tbody', 'tfoot')]" 
    mode="xslLib:cals2html.class2style">
    <xsl:copy>
      <xsl:variable name="class" select="tokenize(@class, '\s+')[not(. = $xslLib:cals2html.class2style.mapping/entry/@key)]" as="xs:string*"/>
      <xsl:if test="not(empty($class))">
        <xsl:attribute name="class" select="string-join($class, ' ')"/>
      </xsl:if>
      <xsl:variable name="style" as="xs:string*">
        <xsl:sequence select="tokenize(@style, ';')"/>
        <xsl:for-each select="tokenize(@class, '\s+')[. = $xslLib:cals2html.class2style.mapping/entry/@key]">
          <xsl:variable name="val" select="." as="xs:string*"/>
          <xsl:sequence select="$xslLib:cals2html.class2style.mapping/entry[@key = $val] ! tokenize(., ';')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="not(empty($style))">
        <xsl:attribute name="style" select="string-join($style, '; ')"/>
      </xsl:if>
      <xsl:copy-of select="@* except (@class | @style)"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!--COMMON -->
  <!--==============================================================================================================================-->
  
  <!--cf. https://www.oasis-open.org/specs/tm9901.html#AEN530 : 
    @colwidth might be express in different units :
      - proportinal values like : "5*", "10%"
      - fixed values like : “pt” (points), “cm” (centimeters), “mm” (millimeters), “pi” (picas), and “in” (inches)
    => FIXME mricaud : j'ai l'impression qu'ici on ne gère que les proportionnel, faut-il prévoir les fixes ?
  -->
  <!--FIXME : here we get the new colwidth as percent ("500*, 500*" would be converted as "50%, 50%")
        But we should treat differently by unit :
        - unit : % => let it the same
        - unit : * => make it %
        - unit px  => let it the same (or make it %) ?-->
  
  <!--Add @width or @style="width:..." on current element-->
  <xsl:template name="xslLib:cals2html.add-column-width">
    <xsl:param name="colspec-list-for-total-width" required="yes" as="element(colspec)*"/>
    <xsl:param name="colspec-list-for-current-width" required="yes" as="element(colspec)*"/>
    <xsl:variable name="width" as="xs:string">
      <xsl:choose>
        <xsl:when test="count($colspec-list-for-current-width) = 0">
          <xsl:text>ignore</xsl:text>
        </xsl:when>
        <xsl:when test="xslLib:cals2html.colspecWidthUnitAreTheSame($colspec-list-for-current-width)">
          <xsl:variable name="colspec-list-for-current-width.unit" select="$colspec-list-for-current-width[1]/@colwidth/xslLib:cals2html.getWidthUnit(.)" as="xs:string"/>
          <xsl:choose>
            <!--current unit is fixed-->
            <xsl:when test="xslLib:cals2html.unitIsFixed($colspec-list-for-current-width.unit)">
              <xsl:value-of select="concat(
                sum($colspec-list-for-current-width/@colwidth/xslLib:cals2html.getWidthValue(.)), 
                $colspec-list-for-current-width.unit)"/>
            </xsl:when>
            <!--current unit is proportional-->
            <xsl:otherwise>
              <xsl:choose>
                <!--unit is "%" : keep it the same (just round it)-->
                <xsl:when test="$colspec-list-for-current-width.unit = '%'">
                  <xsl:value-of select="concat(
                    round(sum($colspec-list-for-current-width/@colwidth/xslLib:cals2html.getWidthValue(.))), 
                    $colspec-list-for-current-width.unit)"/>
                </xsl:when>
                <!--unit is "*" : make it "%" (from the total width)-->
                <xsl:otherwise>
                  <xsl:choose>
                    <!--total width units are consistent-->
                    <xsl:when test="xslLib:cals2html.colspecWidthUnitAreTheSame($colspec-list-for-total-width)">
                      <xsl:variable name="colspec-list-for-total-width.unit" select="$colspec-list-for-total-width[1]/@colwidth/xslLib:cals2html.getWidthUnit(.)" as="xs:string"/>
                      <xsl:choose>
                        <!--total width units are consistent with current cell units--> 
                        <xsl:when test="$colspec-list-for-current-width.unit = $colspec-list-for-total-width.unit">
                          <xsl:variable name="total-colwidth-sum" select="sum($colspec-list-for-total-width/@colwidth/xslLib:cals2html.getWidthValue(.))" as="xs:double"/>
                          <xsl:variable name="current-colwidth-sum" select="sum($colspec-list-for-current-width/@colwidth/xslLib:cals2html.getWidthValue(.))" as="xs:double"/>
                          <xsl:sequence select="round($current-colwidth-sum div $total-colwidth-sum * 100) || '%'"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:message terminate="no">[ERROR][cals2html.xsl] total width units are NOT consistent with current cell units at <xsl:sequence select="els:get-xpath($colspec-list-for-current-width[1])"/></xsl:message>
                          <xsl:text>error</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <!--total width units are not consistent-->
                    <xsl:otherwise>
                      <xsl:message terminate="no">[ERROR][cals2html.xsl] total width units are not consistent at <xsl:sequence select="els:get-xpath($colspec-list-for-current-width[1])"/></xsl:message>
                      <xsl:text>error</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!--unconsitent units for the current cells-->
        <xsl:otherwise>
          <xsl:message terminate="no">[ERROR][cals2html.xsl] unconsitent units for the current cells at <xsl:sequence select="els:get-xpath($colspec-list-for-current-width[1])"/></xsl:message>
          <xsl:text>error</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$width = ('ignore', 'error')">
        <!--no width-->
      </xsl:when>
      <xsl:when test="string(xslLib:cals2html.getWidthValue($width)) = ''">
        <xsl:message>[ERROR][cals2html.xsl] Unable to compute width (empty) at <xsl:value-of select="els:get-xpath(.)"/> : <xsl:value-of select="els:displayNode(.)"/></xsl:message>
      </xsl:when>
      <xsl:when test="string(xslLib:cals2html.getWidthValue($width)) = 'NaN'">
        <xsl:message>[ERROR][cals2html.xsl] Unable to compute width (<xsl:value-of select="$width"/>) at <xsl:value-of select="els:get-xpath(.)"/> : <xsl:value-of select="els:displayNode(.)"/></xsl:message>
      </xsl:when>
      <xsl:when test="string(xslLib:cals2html.getWidthValue($width)) = '0'">
        <xsl:message>[WARNING][cals2html.xsl] width=<xsl:value-of select="$width"/> will not be computed</xsl:message>
      </xsl:when>
      <xsl:when test="$xslLib:cals2html.compute-column-width-as-width-attribute">
        <xsl:attribute name="style" select="concat('width:', $width)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="width" select="$width"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--From a width with its unit (like 10px), get the unit (px)-->
  <xsl:function name="xslLib:cals2html.getWidthUnit" as="xs:string">
    <xsl:param name="width" as="xs:string"/>
    <xsl:sequence select="replace($width, '\d|\.', '')"/>
  </xsl:function>
  
  <!--Check if a unit is a proportional one-->
  <xsl:function name="xslLib:cals2html.unitIsProportional" as="xs:boolean">
    <xsl:param name="unit" as="xs:string"/>
    <xsl:sequence select="$unit = ('%', '*')"/>
  </xsl:function>
  
  <!--check if a unit is fixed (not a proportional one)-->
  <xsl:function name="xslLib:cals2html.unitIsFixed" as="xs:boolean">
    <xsl:param name="unit" as="xs:string"/>
    <xsl:sequence select="not(xslLib:cals2html.unitIsProportional($unit))"/>
  </xsl:function>
  
  <!--From a width with its unit (like 10px), get the value (10)-->
  <xsl:function name="xslLib:cals2html.getWidthValue" as="xs:double">
    <xsl:param name="width" as="xs:string"/>
    <xsl:variable name="value.string" select="substring-before($width, xslLib:cals2html.getWidthUnit($width))" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$value.string castable as xs:double">
        <xsl:sequence select="number($value.string)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="xs:double('NaN')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--Check if every units of a colspec list are consistent (the same)-->
  <xsl:function name="xslLib:cals2html.colspecWidthUnitAreTheSame" as="xs:boolean">
    <xsl:param name="colspec-list" as="element(colspec)*"/>
    <xsl:variable name="colspec-1.unit" select="$colspec-list[@colwidth][1]/@colwidth/xslLib:cals2html.getWidthUnit(.)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="count($colspec-list) = 0 or count($colspec-1.unit) = 0">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence 
          select="every $unit in $colspec-list/@colwidth/xslLib:cals2html.getWidthUnit(.) 
          satisfies $unit = $colspec-1.unit"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--Get the @colnum of a colspec. If the attribute doesn't exist, the function will return the position of the colspec amongs the other colspec-->
  <xsl:function name="xslLib:cals2html.get-colnum" as="xs:integer">
    <xsl:param name="entry" as="element(entry)?"/> <!--only for debug-->
    <xsl:param name="colspec" as="element(colspec)?"/>
    <xsl:choose>
      <xsl:when test="exists($colspec)">
        <xsl:sequence select="($colspec/@colnum[normalize-space(.) != ''], count($colspec/preceding-sibling::colspec) + 1)[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">[ERROR][cals2html.xsl] Calling xslLib:cals2html.get-colnum() with $colspec empty argument&#10;<xsl:sequence select="els:get-xpath($entry)"/></xsl:message>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="xslLib:cals2html.get-colspecs" as="element(colspec)*">
    <xsl:param name="entry" as="element(entry)"/>
    <xsl:variable name="current-tgroup" select="$entry/ancestor::tgroup[1]" as="element()"/>
    <xsl:choose>
      <!--First consider @colname-->
      <xsl:when test="$entry/@colname">
        <xsl:variable name="colname.colspec" select="$current-tgroup/colspec[@colname = $entry/@colname]" as="element()*"/>
        <xsl:if test="count($colname.colspec) != 1">
          <xsl:message terminate="no">[ERROR][cals2html.xsl] No colspec exists in the current tgroup with @colname equals to current @colname="<xsl:value-of select="$entry/@colname"/>"</xsl:message>
        </xsl:if>
        <xsl:sequence select="$colname.colspec"/>
      </xsl:when>
      <!-- Then consider @namestart/nameend -->
      <xsl:when test="$entry/@namest and $entry/@nameend">
        <xsl:variable name="namest.colspec" select="$current-tgroup/colspec[@colname = $entry/@namest]" as="element()*"/>
        <xsl:variable name="nameend.colspec" select="$current-tgroup/colspec[@colname = $entry/@nameend]" as="element()*"/>
        <xsl:choose>
          <xsl:when test="count($namest.colspec) != 1">
            <xsl:message terminate="no">[ERROR][cals2html.xsl] No colspec exists in the current tgroup with @colname equals to current @namest="<xsl:value-of select="$entry/@namest"/>"</xsl:message>
          </xsl:when>
          <xsl:when test="count($nameend.colspec) != 1">
            <xsl:message terminate="no">[ERROR][cals2html.xsl] No colspec exists in the current tgroup with @colname equals to current @nameend="<xsl:value-of select="$entry/@nameend"/>"</xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <!--FIXME : a-t-on vraiment besoin de passer par colnum, ne pourrait-on pas prendre les colspec situés entre namest.colspec et nameend.colspec dans le xml ?--> 
            <xsl:variable name="colnumst" select="xslLib:cals2html.get-colnum($entry, $namest.colspec)" as="xs:integer"/>
            <xsl:variable name="colnumend" select="xslLib:cals2html.get-colnum($entry, $nameend.colspec)" as="xs:integer"/>
            <xsl:sequence 
              select="$current-tgroup/colspec
              [xslLib:cals2html.get-colnum($entry, .) ge $colnumst]
              [xslLib:cals2html.get-colnum($entry, .) le $colnumend]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!--If one of the following/preceding entry has a namest/nameend colum, then consider the current colspec *from* this point, example : 
            <tgroup>
              <colspec ... colname="c1"/>
              <colspec ... colname="c2"/>
              <colspec ... colname="c3"/>
              <colspec ... colname="c4"/>
              <colspec ... colname="c5"/>
              <colspec ... colname="c6"/>
              <tbody>
                <row>
                  <entry ... /> => c1
                  <entry ... /> => c2
                  <entry ... namest="c3" nameend="c4"/> => c3/c4
                  <entry ... /> => c5 
                  <entry ... /> => c6
                </row>
              </tbody>
            </tgroup>
        -->
      <!--There is no current namest/nameend, look if there is a preceding entry with a "nameend" column, if so then use the next colspec by position-->
      <xsl:when test="$entry/preceding-sibling::entry[@nameend]">
        <xsl:variable name="psib1.entry-nameend" select="$entry/preceding-sibling::entry[@nameend][1]" as="element()"/>
        <xsl:variable name="distance" select="count($entry/preceding-sibling::entry[. >> $psib1.entry-nameend]) + 1" as="xs:integer"/>
        <xsl:sequence select="$current-tgroup/colspec[@colname = $psib1.entry-nameend/@nameend]/following-sibling::colspec[$distance]"/>
      </xsl:when>
      <!--There is no namest/nameend, look if there is a following entry with a "namest" column, if so then use the preceding colspec by position-->
      <xsl:when test="$entry/following-sibling::entry[@namest]">
        <xsl:variable name="fsib1.entry-namest" select="$entry/following-sibling::entry[@namest][1]" as="element()"/>
        <xsl:variable name="distance" select="count($entry/following-sibling::entry[. &lt;&lt; $fsib1.entry-namest]) + 1" as="xs:integer"/>
        <xsl:sequence select="$current-tgroup/colspec[@colname = $fsib1.entry-namest/@namest]/preceding-sibling::colspec[$distance]"/>
      </xsl:when>
      <!--Finaly consider position-->
      <!--FIXME : check those old messages => does it still make sens ? may it happens after cals normalisation-->
      <xsl:when test="$entry/position() > 1 and $entry/parent::*/entry[@colname]">
        <xsl:message>[ERROR][cals2html.xsl] Unable to get colspec for this entry. @colname might be missing ? (<xsl:value-of select="els:getFileName(string(base-uri($entry)))"/> : <xsl:sequence select="els:get-xpath($entry)" />)</xsl:message>
      </xsl:when>
      <xsl:when test="$entry/position() > 1 and $entry/parent::*/entry[(position() lt last() and (@namest and @nameend))]">
        <xsl:message>[ERROR][cals2html.xsl] Unable to get colspec for this entry. Too much columns (<xsl:value-of select="els:getFileName(string(base-uri($entry)))"/> : <xsl:sequence select="els:get-xpath($entry)" />)</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="pos" select="count($entry/preceding-sibling::entry) + 1" as="xs:integer"/>
        <xsl:sequence select="$current-tgroup/colspec[$pos]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--Cals table need to be first normalized (with ghost entries). This function give the position(s)
  of an outline cell (a cell that touch the table frame). Position can be : top, left, bottom, right.
  It can also have several values, for example corner cell: ('bottom', 'right')-->
  <xsl:function name="xslLib:cals2html.getOutlineCellPositions" as="xs:string*">
    <xsl:param name="entry" as="element(entry)"/>
    <xsl:variable name="row" select="$entry/parent::row" as="element(row)"/>
    <xsl:variable name="tgroup" select="$entry/ancestor::tgroup[1]" as="element(tgroup)"/>
    <!--If this entry is spanning (row or col) let's add all its ghost entries-->
    <xsl:variable name="entries" as="element(entry)+"
      select="if ($entry/@calstable:id) then(
      ($entry, key('xslLib:cals2html.getGhostEntriesByRid', $entry/@calstable:id, $tgroup))
      ) else ($entry)"/>
    <xsl:variable name="top" as="xs:boolean">
      <xsl:choose>
        <!--the current cell row is the last of the current tgroup-->
        <xsl:when test="($tgroup/descendant::row)[1] is $row">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="bottom" as="xs:boolean">
      <xsl:choose>
        <!--one of the entries (including ghost ones) is in the last row of the table-->
        <!--fixme : we should also check for tfoot-->
        <xsl:when test="some $cell in $entries satisfies 
          ($cell/parent::row is ($tgroup/descendant::row)[last()])">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="right" as="xs:boolean">
      <xsl:choose>
        <!--there's no following entries (except ghost ones which doesn't come from a row spanning)
            => we are at the end of the row-->
        <xsl:when test="count($entry/following-sibling::entry except $entry/following-sibling::entry[@calstable:rid][not(@morerows)]) = 0">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="left" as="xs:boolean">
      <xsl:choose>
        <!--there's no preceding entries (except ghost ones which doesn't come from a row spanning)
            => we are at the beginning of the row-->
        <xsl:when test="count($entry/preceding-sibling::entry except $entry/following-sibling::entry[@calstable:rid][not(@morerows)]) = 0">
          <xsl:sequence select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--Result as multiple string-->
    <xsl:sequence select="if ($top) then 'top' else()"/>
    <xsl:sequence select="if ($bottom) then 'bottom' else()"/>
    <xsl:sequence select="if ($right) then 'right' else()"/>
    <xsl:sequence select="if ($left) then 'left' else()"/>
  </xsl:function>
</xsl:stylesheet>