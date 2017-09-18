<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:cals2html="http://www.lefebvre-sarrut.eu/ns/els/xslLib/cals2html"
  xmlns:cals="http://docs.oasis-open.org/ns/oasis-exchange/table"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://docs.oasis-open.org/ns/oasis-exchange/table"
  exclude-result-prefixes="#all" 
  extension-element-prefixes="xd"
  >
  
  <xsl:import href="els-common.xsl"/>
  <xsl:import href="setXmlBase.xsl"/>
  <xsl:import href="removeXmlBase.xsl"/>
  <xsl:import href="normalizeCalsTable.xsl"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Convert CALS Table to HTML table</xd:p>
      <xd:p>Each cals:table will be converted to an html:div, then each cals:tgroup will be converted to an html:table</xd:p>
      <xd:p>/!\ Cals element must be in cals namespace before proceding, other elements will be copied as is.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--PARAMETERS-->
  <!--common-->
  <xsl:param name="xslLib:cals2html.log.uri" select="resolve-uri('log/', base-uri())" as="xs:string"/>
  <xsl:param name="xslLib:cals2html.debug" select="false()" as="xs:boolean"/>
  <!--structure-->
  <xsl:param name="xslLib:cals2html.html-version" select="5" as="xs:double"/> <!--4 or 5 for example-->
  <xsl:param name="xslLib:cals2html.use-style-insteadOf-class" select="true()" as="xs:boolean"/>
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
  <xsl:param name="xslLib:cals2html.default-tgroup-valign" select="'middle'" as="xs:string"/>
  <xsl:param name="xslLib:cals2html.default-td-valign" select="'middle'" as="xs:string"/><!--default browser value-->
  <xsl:param name="xslLib:cals2html.default-th-valign" select="'middle'" as="xs:string"/><!--default browser value-->

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
    <!--STEP0 : set xml:base to init multi-step-->
    <xsl:variable name="step0" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="." mode="xslLib:setXmlBase"/>
      </xsl:document>
    </xsl:variable>
    <!--STEP1 : normalize cals table-->
    <xsl:variable name="step1" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step0" mode="xslLib:normalizeCalsTable"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step1.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step1"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP2 : cals2html.main-->
    <xsl:variable name="step2" as="document-node()">
      <xsl:document>
        <xsl:apply-templates select="$step1" mode="xslLib:cals2html.main"/>
      </xsl:document>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step2.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step2"/>
      </xsl:result-document>
    </xsl:if>
    <!--STEP3 : convert class2style-->
    <xsl:variable name="step3" as="document-node()">
      <xsl:choose>
        <xsl:when test="$xslLib:cals2html.use-style-insteadOf-class">
          <xsl:document>
            <xsl:apply-templates select="$step2" mode="xslLib:cals2html.class2style"/>
          </xsl:document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$step2"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xslLib:cals2html.debug">
      <xsl:variable name="step.log.uri" select="resolve-uri('cals2html.step3.xml', $xslLib:cals2html.log.uri)" as="xs:anyURI"/>
      <xsl:message>[INFO] writing <xsl:value-of select="$step.log.uri"/></xsl:message>
      <xsl:result-document href="{$step.log.uri}">
        <xsl:sequence select="$step3"/>
      </xsl:result-document>
    </xsl:if>
    <!--FINALY-->
    <xsl:apply-templates select="$step3" mode="xslLib:removeXmlBase"/>
  </xsl:template>
  
  <!--==============================================================================================================================-->
  <!-- STEP 1 -->
  <!--==============================================================================================================================-->
  
  <!--see normalizeCalsTable.xsl-->
  
  <!--==============================================================================================================================-->
  <!-- STEP 2 : cal2html.main -->
  <!--==============================================================================================================================-->
  
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
        <xsl:text>cals_tgroup</xsl:text>
        <!--cals:table/@frame ::= none | top | bottom | topbot | sides | all
        default is "all"-->
        <xsl:value-of select="concat('cals_frame-', (../@frame, 'all')[1])"/>
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
      <xsl:if test="$xslLib:cals2html.compute-column-width-within-colgroup">
        <colgroup>
          <xsl:variable name="total-colwidth-sum" select="xslLib:cals2html.cals_sum-colwidths(colspec)" as="xs:double"/>
          <xsl:for-each select="colspec">
            <xsl:variable name="current-colwidth" select="xslLib:cals2html.cals_sum-colwidths(.)" as="xs:double"/>
            <col>
              <xsl:call-template name="xslLib:cals2html.add-column-width">
                <xsl:with-param name="width" select="concat(round(($current-colwidth div  $total-colwidth-sum) * 100), '%')" as="xs:string"/>
              </xsl:call-template>
            </col>
          </xsl:for-each>
        </colgroup>
      </xsl:if>
      <xsl:if test="normalize-space(@cols) != '' and not(normalize-space(@cols) castable as xs:integer)">
        <xsl:message terminate="no">[ERROR][xslLib:cals2html] @cols="<xsl:value-of select="@cols"/>" is not an integer</xsl:message>
      </xsl:if>
      <xsl:apply-templates mode="xslLib:cals2html.main" select="thead"/>
      <xsl:if test="tfoot">
        <tfoot>
          <xsl:apply-templates select="tfoot" mode="#current"/>
        </tfoot>
      </xsl:if>
      <xsl:apply-templates select="* except (thead, tfoot) (:head and foot has already been processed :)" mode="#current"/>
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
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>
  
  <!-- Table bocy -->
  <!-- CALS MODEL : tbody ::= row+-->
  <xsl:template match="tbody" mode="xslLib:cals2html.main">
    <tbody>
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
  <xsl:template match="entry" mode="xslLib:cals2html.main">
    <xsl:variable name="nb-cols" select="ancestor::tgroup[1]/@cols[. castable as xs:integer]" as="xs:integer?"/>
    <xsl:variable name="entry" select="self::*" as="element(entry)"/>
    <xsl:variable name="current-tgroup" select="ancestor::tgroup[1]" as="element()"/>
    <xsl:variable name="current-colspec-list" as="element(colspec)*">
      <xsl:choose>
        <!-- Firts consider @namestart/nameend -->
        <xsl:when test="@namest and @nameend">
          <xsl:variable name="namest.colspec" select="$current-tgroup/colspec[@colname = current()/@namest]" as="element()*"/>
          <xsl:variable name="nameend.colspec" select="$current-tgroup/colspec[@colname = current()/@nameend]" as="element()*"/>
          <xsl:choose>
            <xsl:when test="count($namest.colspec) != 1">
              <xsl:message terminate="no">[ERROR][cals2html.xsl] No colspec exists in the current tgroup with @colname equals to current @namest="<xsl:value-of select="@namest"/>"</xsl:message>
            </xsl:when>
            <xsl:when test="count($nameend.colspec) != 1">
              <xsl:message terminate="no">[ERROR][cals2html.xsl] No colspec exists in the current tgroup with @colname equals to current @nameend="<xsl:value-of select="@nameend"/>"</xsl:message>
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
        <xsl:when test="preceding-sibling::entry[@nameend]">
          <xsl:variable name="psib1.entry-nameend" select="preceding-sibling::entry[@nameend][1]" as="element()"/>
          <xsl:variable name="distance" select="count(preceding-sibling::entry[. >> $psib1.entry-nameend]) + 1" as="xs:integer"/>
          <xsl:sequence select="$current-tgroup/colspec[@colname = $psib1.entry-nameend/@nameend]/following-sibling::colspec[$distance]"/>
        </xsl:when>
        <!--There is no namest/nameend, look if there is a following entry with a "namest" column, if so then use the preceding colspec by position-->
        <xsl:when test="following-sibling::entry[@namest]">
          <xsl:variable name="fsib1.entry-namest" select="following-sibling::entry[@namest][1]" as="element()"/>
          <xsl:variable name="distance" select="count(following-sibling::entry[. &lt;&lt; $fsib1.entry-namest]) + 1" as="xs:integer"/>
          <xsl:sequence select="$current-tgroup/colspec[@colname = $fsib1.entry-namest/@namest]/preceding-sibling::colspec[$distance]"/>
        </xsl:when>
        <!--There is no namest/nameend at all in the current row, let's consider @colname-->
        <xsl:when test="@colname">
          <xsl:variable name="colname.colspec" select="$current-tgroup/colspec[@colname = current()/@colname]" as="element()*"/>
          <xsl:if test="count($colname.colspec) != 1">
            <xsl:message terminate="no">[ERROR][cals2html.xsl] No colspec exists in the current tgroup with @colname equals to current @colname="<xsl:value-of select="@colname"/>"</xsl:message>
          </xsl:if>
          <xsl:sequence select="$colname.colspec"/>
        </xsl:when>
        <!--Finaly consider position-->
        <xsl:when test="position() > 1 and ../entry[@colname]">
          <xsl:message>[ERROR][cals2html.xsl] Unable to get colspec for this entry. @colname might be missing ? (<xsl:value-of select="els:getFileName(string(base-uri()))"/> : <xsl:sequence select="els:get-xpath(.)" />)</xsl:message>
        </xsl:when>
        <xsl:when test="position() > 1 and ../entry[(position() lt last() and (@namest and @nameend))]">
          <xsl:message>[ERROR][cals2html.xsl] Unable to get colspec for this entry. Too much columns (<xsl:value-of select="els:getFileName(string(base-uri()))"/> : <xsl:sequence select="els:get-xpath(.)" />)</xsl:message>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="pos" select="count(preceding-sibling::entry) + 1" as="xs:integer"/>
          <xsl:sequence select="$current-tgroup/colspec[$pos]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="colsep-current" as="xs:string">
      <xsl:choose>
        <xsl:when test="@colsep">
          <xsl:value-of select="@colsep"/>
        </xsl:when>
        <!-- FIXME : que se passe-t-il lors d'un colspan ? a priori c'est le namest qui gagne-->
        <xsl:when test="$current-colspec-list[1]/@colsep">
          <xsl:value-of select="$current-colspec-list[1]/@colsep" />
        </xsl:when>
        <xsl:when test="ancestor::*/@colsep">
          <xsl:value-of select="ancestor::*[@colsep][1]/@colsep" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xslLib:cals2html.default-colsep"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="rowsep-current" as="xs:string">
      <xsl:choose>
        <xsl:when test="@rowsep">
          <xsl:value-of select="@rowsep"/>
        </xsl:when>
        <!-- FIXME : que se passe-t-il lors d'un colspan ? a priori c'est le namest qui gagne-->
        <xsl:when test="$current-colspec-list[1]/@rowsep">
          <xsl:value-of select="$current-colspec-list[1]/@rowsep"/>
        </xsl:when>
        <xsl:when test="ancestor::*/@rowsep">
          <xsl:value-of select="ancestor::*[@rowsep][1]/@rowsep"/>
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
        <xsl:when test="ancestor::*/@align">
          <xsl:value-of select="ancestor::*[@align][1]/@align"/>
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
        <!-- FIXME : que se passe-t-il lors d'un colspan ? a priori c'est le namest qui gagne-->
        <xsl:when test="$current-colspec-list[1]/@valign">
          <xsl:value-of select="$current-colspec-list[1]/@valign" />
        </xsl:when>
        <xsl:when test="ancestor::*/@valign">
          <xsl:value-of select="ancestor::*[@valign][1]/@valign" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$xslLib:cals2html.default-tgroup-valign"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="name" select="if(ancestor::thead) then ('th') else('td')" as="xs:string"/>
    <xsl:element name="{$name}">
      <xsl:apply-templates select="@*" mode="xslLib:cals2html.attributes"/> 
      <xsl:variable name="class.tmp" as="xs:string*">
        <xsl:if test="$colsep-current != '0'">
          <xsl:text>cals_colsep</xsl:text>
        </xsl:if>
        <xsl:if test="$rowsep-current != '0'">
          <xsl:text>cals_rowsep</xsl:text>
        </xsl:if>
        <xsl:if test="$align-current != (if($name = 'td') then($xslLib:cals2html.default-td-align) else($xslLib:cals2html.default-th-align))">
          <xsl:value-of select="concat('cals_align-', lower-case($align-current))" />
        </xsl:if>
        <xsl:if test="$valign-current != (if($name = 'td') then($xslLib:cals2html.default-td-valign) else($xslLib:cals2html.default-th-valign))">
          <xsl:value-of select="concat('cals_valign-', lower-case($valign-current))" />
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
      <xsl:variable name="total-colwidth-sum" select="xslLib:cals2html.cals_sum-colwidths($current-tgroup/colspec)" as="xs:double"/>
      <xsl:variable name="current-colwidth" select="xslLib:cals2html.cals_sum-colwidths($current-colspec-list)" as="xs:double"/>
      <xsl:if test="not($xslLib:cals2html.compute-column-width-within-colgroup)">
        <xsl:call-template name="xslLib:cals2html.add-column-width">
          <xsl:with-param name="width" select="concat(round(($current-colwidth div  $total-colwidth-sum)*97), '%')" as="xs:string"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="count($current-colspec-list) > 1">
        <xsl:attribute name="colspan" select="count($current-colspec-list)"/>
      </xsl:if>
      <xsl:if test="normalize-space(@morerows) != '' and normalize-space(@morerows) castable as xs:integer">
        <xsl:attribute name="rowspan" select="xs:integer(@morerows) + 1"/>
      </xsl:if>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>

  <!-- === COMMON : STEP 2 === -->
  
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
  
  <!--Attributes to keep as is-->
  <xsl:template match="@xml:* | @id" mode="xslLib:cals2html.attributes">
    <xsl:copy copy-namespaces="no"/>
  </xsl:template>
  
  <xsl:template match="@*" mode="xslLib:cals2html.attributes">
    <xsl:message>[ERROR] <xsl:value-of select="name(parent::*)"/>/@<xsl:value-of select="name()"/> unmatched in mode "xslLib:cals2html.attributes"</xsl:message>
    <!--<xsl:attribute name="data-cals-{local-name(.)}" select="."/>-->
  </xsl:template>
  
  <!--copy template-->
  <xsl:template match="node() | @*" mode="xslLib:cals2html.main">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--==================================-->
  <!--COMMON -->
  <!--==================================-->
  
  <!--cf. https://www.oasis-open.org/specs/tm9901.html#AEN530 : 
    @colwidth might be express in different units :
      - proportinal values like : "5*", "10%"
      - fixed values like : “pt” (points), “cm” (centimeters), “mm” (millimeters), “pi” (picas), and “in” (inches)
    => FIXME mricaud : j'ai l'impression qu'ici on ne gère que les proportionnel, faut-il prévoir les fixes ?
  -->
  
  <!--1 argument signature to initiate reccursion from 0 by additionning colwidth-->
  <xsl:function name="xslLib:cals2html.cals_sum-colwidths" as="xs:double">
    <xsl:param name="colspec-list" as="element(colspec)*"/>
    <xsl:sequence select="xslLib:cals2html.cals_sum-colwidths($colspec-list, 0)"/>
  </xsl:function>
  
  <!--Given a list of colspec, this function make the sum of each colwidth-->
  <xsl:function name="xslLib:cals2html.cals_sum-colwidths" as="xs:double">
    <xsl:param name="colspec-list" as="element(colspec)*"/>
    <xsl:param name="current-sum" as="xs:double"/>
    <xsl:choose>
      <xsl:when test="count($colspec-list) != 0">
        <xsl:variable name="colspec" select="$colspec-list[1]" as="element(colspec)"/>
        <xsl:variable name="colwidth" select="$colspec/@colwidth" as="xs:string?"/>
        <!--<xsl:message>colwidth= <xsl:value-of select="$colwidth"/></xsl:message>-->
        <xsl:variable name="colwidth.normalized" select="replace($colwidth, '(\*|%)', '')" as="xs:string"/>
        <xsl:variable name="colwidth.as-number" select=" if($colwidth.normalized castable as xs:double) then(number($colwidth.normalized)) else(0) " as="xs:double"/>
        <xsl:sequence select="xslLib:cals2html.cals_sum-colwidths($colspec-list[position() gt 1], $current-sum + $colwidth.as-number)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$current-sum" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--Add @width or @style="width:..." on current element-->
  <xsl:template name="xslLib:cals2html.add-column-width">
    <xsl:param name="width" required="yes" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$width = 'NaN%'">
        <xsl:message>[ERROR][cals2html.xsl] Unable to compute width (NaN%) at <xsl:value-of select="els:get-xpath(.)"/> : <xsl:value-of select="els:displayNode(.)"/></xsl:message>
      </xsl:when>
      <xsl:when test="$width = '0%'">
        <xsl:message>[WARNING][cals2html.xsl] width=0 will not be computed</xsl:message>
      </xsl:when>
      <xsl:when test="$xslLib:cals2html.compute-column-width-as-width-attribute">
        <xsl:attribute name="style" select="concat('width:', $width)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="width" select="$width"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
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
  
  <!--==============================================================================================================================-->
  <!-- STEP 3 : class2style -->
  <!--==============================================================================================================================-->
  
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
    </mapping>
  </xsl:variable>
  
  <xsl:template match="html:table[els:hasClass(., 'cals_tgroup')] 
    | html:table[els:hasClass(., 'cals_tgroup')]//*[local-name(.) = ('tr', 'td', 'th', 'thead', 'tbody', 'tfoot')]" 
    mode="xslLib:cals2html.class2style">
    <xsl:copy>
      <xsl:copy-of select="@* except (@class | @style)"/>
      <xsl:variable name="class" select="tokenize(@class, '\s+')[not(. = $xslLib:cals2html.class2style.mapping/entry/@key)]" as="xs:string*"/>
      <xsl:if test="not(empty($class))">
        <xsl:attribute name="class" select="string-join($class, ' ')"/>
      </xsl:if>
      <xsl:variable name="style" as="xs:string*">
        <xsl:sequence select="tokenize(@style, ';')"/>
        <xsl:for-each select="tokenize(@class, '\s+')[. = $xslLib:cals2html.class2style.mapping/entry/@key]">
          <xsl:variable name="val" select="." as="xs:string"/>
          <xsl:sequence select="tokenize($xslLib:cals2html.class2style.mapping/entry[@key = $val], ';')"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="not(empty($style))">
        <xsl:attribute name="style" select="string-join($style, '; ')"/>
      </xsl:if>
      <xsl:copy-of select="@* except (@class | @style)"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--Default copy-->
  <xsl:template match="* | @* | node()" mode="xslLib:cals2html.class2style">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>