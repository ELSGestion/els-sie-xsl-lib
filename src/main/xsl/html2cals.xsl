<?xml version="1.0" encoding="UTF-8"?>
<!--
	# =============================================================================
	# Copyright © 2010 Typéfi Systems. All rights reserved.
	# Copyright © 2013 ISO. All rights reserved.
	#
	# $LastChangedRevision: 28275 $
  # $LastChangedDate: 2013-01-24 16:21:39 +0100 (Thu, 24 Jan 2013) $
  # Unless required by applicable law or agreed to in writing, software
	# is distributed on an "as is" basis, without warranties or conditions of any
	# kind, either express or implied.
	# =============================================================================
-->

<!-- This is a library of templates to convert XHTML tables to oasis CALS tables -->

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:cals="-//OASIS//DTD XML Exchange Table Model 19990315//EN"
	xmlns="-//OASIS//DTD XML Exchange Table Model 19990315//EN"
	xmlns:css="http://www.iso.org/ns/css-parser" 
	xmlns:css2cals="http://www.iso.org/ns/css2cals"
	xpath-default-namespace="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="#all">

	<xsl:import href="css-parser.xsl"/>

	<xsl:param name="cals.ns.uri" select="'-//OASIS//DTD XML Exchange Table Model 19990315//EN'" as="xs:string"/>
	
	<!-- ===================================================================-->
	<!-- MAIN mode "xhtml2cals" -->
	<!-- ===================================================================-->
	
	<xsl:template match="table" mode="xhtml2cals">
		<xsl:message>processing table <xsl:value-of select="../@id"/></xsl:message>
		<!-- Expand out all the spans -->
		<!--<xsl:variable name="expanded-spans-table">
			<xsl:apply-templates select="self::*" mode="expand-spans"/>
		</xsl:variable>
		<xsl:apply-templates select="$expanded-spans-table" mode="convert-to-cals"/>-->
		<xsl:apply-templates select="." mode="convert-to-cals"/>
	</xsl:template>

	<xsl:template match="node() | @*" mode="xhtml2cals">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- ===================================================================-->
	<!-- MAIN mode "convert-to-cals" -->
	<!-- ===================================================================-->
	
	<xsl:template match="table" mode="convert-to-cals">
		<xsl:variable name="num-cols">
			<xsl:choose>
				<xsl:when test=".//col">
					<!-- take col definitions -->
					<xsl:value-of select="count(.//col[not(@colspan)]) + sum(.//col/@colspan)"/>
				</xsl:when>
				<xsl:when test="./thead">
					<!-- take first row of table header -->
					<xsl:value-of select="count(./thead/tr[1]/th[not(@colspan)]) + sum(./thead/tr[1]/th/@colspan)"/>
				</xsl:when>
				<xsl:when test="not(./thead) and ./tbody">
					<!-- take first row of table body -->
					<xsl:value-of select="count(./tbody/tr[1]/td[not(@colspan)]) + sum(./tbody/tr[1]/td/@colspan)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="yes">unable to determine column number</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--<xsl:element name="table" namespace="{$ns.uri}">-->
			<!--<xsl:call-template name="compute-table-borders"/>
			<xsl:call-template name="compute-rowsep-colsep-defaults"/>
			<xsl:if test="caption">
				<!-\- CALS pur : title, CALS OM : titre -\->
				<xsl:element name="titre" namespace="{$ns.uri}">
					<xsl:apply-templates select="caption/node()"/>
				</xsl:element>
			</xsl:if>-->
			<xsl:element name="tgroup" namespace="{$cals.ns.uri}">
				<xsl:attribute name="cols" select="$num-cols"/>
				<xsl:if test="not(.//col)">
					<xsl:for-each select="1 to $num-cols">
						<xsl:element name="colspec" namespace="{$cals.ns.uri}">
							<xsl:attribute name="colnum" select="."/>
							<xsl:attribute name="colname" select="concat('col', .)"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:if>
				<xsl:apply-templates select="* except caption" mode="convert-to-cals"/>
			</xsl:element>
		<!--</xsl:element>-->
	</xsl:template>

	<xsl:template name="compute-table-borders">
		<xsl:attribute name="frame">
			<xsl:choose>
				<xsl:when test="@frame and (not(@border) or @border != '0')">
					<xsl:choose>
						<xsl:when test="@frame = 'box'">all</xsl:when>
						<xsl:when test="@frame = 'above'">top</xsl:when>
						<xsl:when test="@frame = 'below'">bottom</xsl:when>
						<xsl:when test="@frame = 'border'">all</xsl:when>
						<xsl:when test="@frame = 'hsides'">topbot</xsl:when>
						<xsl:when test="@frame = 'lhs'">none</xsl:when>
						<xsl:when test="@frame = 'rhs'">none</xsl:when>
						<xsl:when test="@frame = 'void'">none</xsl:when>
						<xsl:when test="@frame = 'vsides'">sides</xsl:when>
						<xsl:otherwise>all</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="not(@frame) and @border != '0'">all</xsl:when>
				<xsl:otherwise>none</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="compute-rowsep-colsep-defaults">
		<xsl:choose>
			<xsl:when test="@border != '0' and not(@rules)">
				<xsl:attribute name="colsep">1</xsl:attribute>
				<xsl:attribute name="rowsep">1</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rules">
				<xsl:choose>
					<xsl:when test="@rules = 'all'">
						<xsl:attribute name="colsep">1</xsl:attribute>
						<xsl:attribute name="rowsep">1</xsl:attribute>
					</xsl:when>
					<xsl:when test="@rules = 'rows'">
						<xsl:attribute name="colsep">0</xsl:attribute>
						<xsl:attribute name="rowsep">1</xsl:attribute>
					</xsl:when>
					<xsl:when test="@rules = 'cols'">
						<xsl:attribute name="colsep">1</xsl:attribute>
						<xsl:attribute name="rowsep">0</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="colsep">0</xsl:attribute>
						<xsl:attribute name="rowsep">0</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="colsep">0</xsl:attribute>
				<xsl:attribute name="rowsep">0</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- Create colspec element from cols.  Convert to % based widths as this makes life easier in print -->
	<!-- ===================================================================-->

	<xsl:template match="col" mode="convert-to-cals">
		<xsl:variable name="colnum" select="count(preceding-sibling::*) + 1"/>
		<xsl:element name="colspec" namespace="{$cals.ns.uri}">
			<xsl:attribute name="colnum" select="$colnum"/>
			<xsl:attribute name="colname" select="concat('col', $colnum)"/>
			<xsl:copy-of select="@align"/>
			<xsl:copy-of select="@char"/>
			<xsl:copy-of select="@charoff"/>
			<xsl:if test="@width">
				<xsl:attribute name="colwidth" select="@width"/>
			</xsl:if>
		</xsl:element>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- Do a 1-to-1 transform of all the matching elements						      -->
	<!-- ===================================================================-->
	
	<xsl:template match="thead" mode="convert-to-cals">
		<xsl:element name="thead" namespace="{$cals.ns.uri}">
			<xsl:apply-templates mode="convert-to-cals"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tbody" mode="convert-to-cals">
		<xsl:element name="tbody" namespace="{$cals.ns.uri}">
			<xsl:apply-templates mode="convert-to-cals"/>
			<!-- add tfooter rows at the end of tbody -->
			<xsl:apply-templates select="../tfoot/tr" mode="convert-to-cals"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tfoot" mode="convert-to-cals">
		<!-- done in tbody -->
	</xsl:template>

	<xsl:template match="tr" mode="convert-to-cals">
		<xsl:element name="row" namespace="{$cals.ns.uri}">
			<xsl:apply-templates mode="convert-to-cals"/>
		</xsl:element>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- processes the cells.  Convert across all the attributes and copy the contents  -->
	<!-- ===================================================================-->

	<xsl:template match="td | th" mode="convert-to-cals">
		<xsl:element name="entry" namespace="{$cals.ns.uri}">
			<xsl:variable name="curr-col-num" as="xs:integer" select="count(preceding-sibling::*) + 1"/>
			<!-- copy attributes with same name -->
			<!-- If no @valign use col/@valign, @valign="baseline" has no correspondence in CALS -->
			<xsl:copy-of select=" (@valign, (../../..//col)[$curr-col-num]/@valign)[1][not(. = 'baseline')]"/>
			<xsl:copy-of select="@align"/>
			<xsl:copy-of select="@char"/>
			<xsl:copy-of select="@charoff"/>
			<xsl:if test="@rowspan">
				<xsl:attribute name="morerows" select="number(@rowspan) - 1"/>
			</xsl:if>
			<xsl:attribute name="namest" select="concat('col', count(preceding-sibling::*) + 1)"/>
			<xsl:attribute name="nameend">
				<xsl:choose>
					<xsl:when test="not(string(@xcolspan))">
						<xsl:value-of select="concat('col', count(preceding-sibling::*) + 1)"/>
					</xsl:when>
					<xsl:when test="@xcolspan = 1">
						<xsl:value-of select="concat('col', count(preceding-sibling::*) + 1)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat('col', count(preceding-sibling::*) + @xcolspan)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<!-- check CSS for definition of col or row separator -->
			<xsl:variable name="rowspan" as="xs:integer">
				<xsl:choose>
					<xsl:when test="@rowspan">
						<xsl:value-of select="@rowspan"/>
					</xsl:when>
					<xsl:otherwise>1</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- the CSS of the next col or row can have an impact on the separator settings -->
			<xsl:variable name="css-next-col" select="css:parse(following-sibling::*[not(@spanCellCol)][1]/@style)"/>
			<xsl:variable name="css-next-row" select="css:parse(../following-sibling::*[$rowspan]/*[$curr-col-num]/@style)"/>
			<xsl:variable name="css" select="css:parse(@style)"/>
			<!-- take into account rules setting of table -->
			<xsl:variable name="old-forced-rowsep" as="xs:boolean">
				<xsl:choose>
					<!-- force separator for last row in header and body and footer -->
					<xsl:when test="ancestor::table[1]/@rules = 'groups' and not(../following-sibling::tr)">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:when test="ancestor::table[1]/@rules = 'rows'"><xsl:text>true</xsl:text></xsl:when>
					<xsl:when test="ancestor::table[1]/@rules = 'all'"><xsl:text>true</xsl:text></xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="forced-rowsep" as="xs:boolean" select="false()"/>
			<xsl:variable name="old-forced-colsep" as="xs:boolean">
				<xsl:choose>
					<xsl:when test="ancestor::table[1]/@rules = 'cols'"><xsl:text>true</xsl:text></xsl:when>
					<xsl:when test="ancestor::table[1]/@rules = 'all'"><xsl:text>true</xsl:text></xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="forced-colsep" as="xs:boolean" select="false()"/>
			<xsl:choose>
				<xsl:when test="$forced-colsep or css2cals:definesBorderRight($css) or css2cals:definesBorderLeft($css-next-col)">
					<xsl:choose>
						<xsl:when test="$forced-colsep or css2cals:showBorderRight($css) or css2cals:showBorderLeft($css-next-col)">
							<xsl:attribute name="colsep"><xsl:text>1</xsl:text></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="colsep"><xsl:text>0</xsl:text></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$forced-rowsep or css2cals:definesBorderBottom($css) or css2cals:definesBorderTop($css-next-row)">
					<xsl:choose>
						<xsl:when test="$forced-rowsep or css2cals:showBorderBottom($css) or css2cals:showBorderTop($css-next-row)">
							<xsl:attribute name="rowsep"><xsl:text>1</xsl:text></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="rowsep"><xsl:text>0</xsl:text></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
			<xsl:copy-of select="child::node()"/>
		</xsl:element>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- Drop the padding cells 							        -->
	<!-- ===================================================================-->

	<xsl:template match="td[@spanCellCol = 'yes']" mode="convert-to-cals" priority="15"/>
	<xsl:template match="td[@spanCellRow = 'yes']" mode="convert-to-cals" priority="10"/>
	<xsl:template match="th[@spanCellCol = 'yes']" mode="convert-to-cals" priority="15"/>
	<xsl:template match="th[@spanCellRow = 'yes']" mode="convert-to-cals" priority="10"/>


	<!-- ===================================================================-->
	<!-- Per default all existing nodes should be copied into the result document 			        -->
	<!-- ===================================================================-->

	<xsl:template match="node() | @*" mode="expand-spans" priority="1">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@* | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- thead, tbody and tfoot has their tr elements padded out with dummy cells 			        -->
	<!-- ===================================================================-->

	<xsl:template match="thead | tbody | tfoot" mode="expand-spans">
		<xsl:element name="{local-name(.)}" inherit-namespaces="no">
			<xsl:copy-of select="@*" copy-namespaces="no"/>
			<xsl:call-template name="process-block">
				<xsl:with-param name="source-rows" select="self::*"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- Expand out the spans in a blocks of tr nodes -->
	<!-- ===================================================================-->
	
	<xsl:template name="process-block">
		<!-- Source tr elements pre-padding -->
		<xsl:param name="source-rows" as="element()+"/>
		<!-- Altered tr elements after padding -->
		<xsl:param name="processed-row" as="element()*"/>
		<!-- row being padded-->
		<xsl:param name="row-count" as="xs:integer">1</xsl:param>
		<xsl:choose>
			<xsl:when test="count($source-rows/tr) &lt; $row-count">
				<!-- stop padding when all the rows are done -->
			</xsl:when>
			<xsl:when test="count($processed-row/node()) = 0">
				<!-- First row is different as it will have no preceding rowspans -->
				<xsl:variable name="first-row" as="element()+">
					<xsl:element name="tr" inherit-namespaces="no">
						<xsl:copy-of select="cals:expand-col-spans($source-rows/tr[1])"/>
					</xsl:element>
				</xsl:variable>
				<xsl:copy-of select="$first-row"/>
				<xsl:call-template name="process-block">
					<xsl:with-param name="source-rows" select="$source-rows"/>
					<xsl:with-param name="processed-row" select="$first-row"/>
					<xsl:with-param name="row-count">2</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- process the rest -->
				<xsl:variable name="row" as="element()">
					<xsl:copy-of select="cals:expand-table-row($source-rows, $processed-row, $row-count)"/>
				</xsl:variable>
				<xsl:copy-of select="$row"/>
				<xsl:call-template name="process-block">
					<xsl:with-param name="source-rows" select="$source-rows"/>
					<xsl:with-param name="processed-row" select="$row"/>
					<xsl:with-param name="row-count" select="$row-count + 1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ===================================================================-->
	<!-- Expand out the spans in sinlge tr node 								        -->
	<!--  This is done by first expanding the rowspans down and then expanding the colspans accross        -->
	<!-- ===================================================================-->

	<xsl:function name="cals:expand-table-row" as="element()">
		<!-- block of Source tr nodes -->
		<xsl:param name="table-block" as="element()+"/>
		<!-- row being created that has preexpanded content -->
		<xsl:param name="expanding-row" as="element()"/>
		<!-- row being expanded -->
		<xsl:param name="row" as="xs:integer"/>
		<!-- expand the row spans first -->
		<xsl:variable name="next-row">
			<xsl:element name="tr" inherit-namespaces="no">
				<xsl:copy-of select="cals:expand-row-spans($table-block/tr[$row], $expanding-row)"/>
			</xsl:element>
		</xsl:variable>
		<!-- use the row with expanded rowspans and expand out the colspans-->
		<xsl:variable name="next-row-expanded" as="element()">
			<xsl:element name="tr" inherit-namespaces="no">
				<xsl:copy-of select="cals:expand-col-spans($next-row/node())"/>
			</xsl:element>
		</xsl:variable>
		<xsl:copy-of select="$next-row-expanded"/>
	</xsl:function>

	<!-- ===================================================================-->
	<!-- Expand out the colspans in sinlge tr node 							        -->
	<!--  This is done by adding extra cells to fully padout the row.  Inserted cells have a special attrib         -->
	<!-- ===================================================================-->

	<xsl:function name="cals:expand-col-spans" as="item()+">
		<!-- row will have colspans expanded -->
		<xsl:param name="source-row" as="element()"/>
		<xsl:variable name="expand-columns">
			<xsl:for-each select="$source-row/*">
				<xsl:variable name="element-name" select="local-name()"/>
				<xsl:variable name="current-cell" select="self::node()"/>
				<xsl:element name="{$element-name}" inherit-namespaces="no">
					<xsl:copy-of select="$current-cell/@*[not(name() = 'colspan')]" copy-namespaces="no"/>
					<xsl:attribute name="xcolspan" select="$current-cell/@colspan"/>
					<xsl:copy-of select="$current-cell/child::node()" copy-namespaces="no"/>
				</xsl:element>
				<!-- If there is a colspan add padding cells  -->
				<xsl:for-each select="2 to (xs:integer(@colspan))">
					<xsl:element name="{$element-name}" inherit-namespaces="no">
						<xsl:attribute name="spanCellCol">yes</xsl:attribute>
						<xsl:copy-of select="$current-cell/@*[not(name() = 'colspan')]" copy-namespaces="no"/>
						<xsl:comment>
							<xsl:copy-of select="$current-cell/child::node()" copy-namespaces="no"/>
						</xsl:comment>
					</xsl:element>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:copy-of select="$expand-columns"/>
	</xsl:function>

	<!-- ===================================================================-->
	<!-- Expand out the rowspans in single tr node to the next tr node					        -->
	<!-- This is done by adding extra cells to fully padout the row below or copying cells across.         -->
	<!-- ===================================================================-->

	<xsl:function name="cals:expand-row-spans" as="item()+">
		<xsl:param name="source-rows" as="element()+"/>
		<!-- source table rows to copy from -->
		<xsl:param name="modified-row" as="element()"/>
		<!-- new row being created when expanding the rowspans -->
		<xsl:for-each select="$modified-row/*">
			<xsl:choose>
				<!-- if the rowspan of the cell aobve is greater than 1 create a padding cell.  Decrement the rowspan for the dummy cell -->
				<xsl:when test="matches(@rowspan, '^\d+$') and @rowspan > 1">
					<xsl:element name="{local-name()}">
						<xsl:attribute name="spanCellRow">yes</xsl:attribute>
						<xsl:copy-of select="@*[not(name() = 'rowspan')]" copy-namespaces="no"/>
						<xsl:attribute name="rowspan" select="number(@rowspan) - 1"/>
						<xsl:comment><xsl:copy-of select="child::node()"/></xsl:comment>
					</xsl:element>
				</xsl:when>
				<!-- if there are no spans just copy from the original cell -->
				<xsl:otherwise>
					<xsl:variable name="current-column" select="count(preceding-sibling::*) + 1"/>
					<xsl:variable name="spanned-row-cells" select="count(preceding-sibling::*[matches(@rowspan, '^\d+$') and @rowspan > 1])"/>
					<xsl:copy-of select="cals:select-cell($current-column - $spanned-row-cells, $source-rows, 1, 0)" copy-namespaces="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:function>

	<xsl:function name="cals:select-cell">
		<!-- Current Column Being Processed  -->
		<xsl:param name="src-column-no" as="xs:integer"/>
		<!-- Current table show being processed -->
		<xsl:param name="row" as="element()+"/>
		<!-- Current column being examised to copy -->
		<xsl:param name="current-column-count" as="xs:integer"/>
		<!-- Total of the spans already checked -->
		<xsl:param name="current-span-col-total" as="xs:double"/>
		<!-- colspan of the current cell being examined-->
		<xsl:variable name="current-span">
			<xsl:choose>
				<xsl:when test="$row/*[$current-column-count]/@colspan">
					<xsl:value-of select="$row/*[$current-column-count]/@colspan"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<!-- Current column being processed matches the end of the span. i.e. span finishes here.  Output cell -->
			<xsl:when test="$src-column-no = $current-span-col-total + $current-span">
				<xsl:copy-of select="$row/*[$current-column-count]" copy-namespaces="no"/>
			</xsl:when>
			<!-- The span total exceeds the current colum.   This means the current cell is not a span boundry & we have gone past -->
			<xsl:when test="$src-column-no &lt; $current-span-col-total + $current-span">
				<!-- do nothing and exit the recurssion -->
			</xsl:when>
			<!-- The span total is less than the current colum. This means the current cell is not a span boundry. Try the next cell  -->
			<xsl:when test="$src-column-no > $current-span-col-total + $current-span">
				<xsl:copy-of select="cals:select-cell($src-column-no, $row, $current-column-count + 1, $current-span + $current-span-col-total)" copy-namespaces="no"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="no">Error in table conversion.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:definesBorderRight" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<xsl:when test="$css/css:border or $css/css:border-right or $css/css:border-right-style">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:definesBorderLeft" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<xsl:when test="$css/css:border or $css/css:border-left or $css/css:border-left-style">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:definesBorderBottom" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<xsl:when test="$css/css:border or $css/css:border-bottom or $css/css:border-bottom-style">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:definesBorderTop" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<xsl:when test="$css/css:border or $css/css:border-top or $css/css:border-top-style">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:showBorderRight" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<!-- specific settings for border-right overwrite general -->
			<xsl:when
				test="
					not(($css/css:border-right-style,
					$css/css:border-right,
					$css/css:border-style,
					$css/css:border)[1]/(css:none,
					css:hidden)) and ($css/css:border-right-width/css:dimension,
					$css/css:border-right/css:dimension[1],
					$css/css:border/css:dimension[1])[1] > 0">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:showBorderLeft" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<!-- specific settings for border-right overwrite general -->
			<xsl:when
				test="
					not(($css/css:border-left-style,
					$css/css:border-left,
					$css/css:border-style,
					$css/css:border)[1]/(css:none,
					css:hidden)) and ($css/css:border-left-width/css:dimension,
					$css/css:border-left/css:dimension[1],
					$css/css:border/css:dimension[1])[1] > 0">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:showBorderBottom" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<!-- specific settings for border-bottom overwrite general -->
			<xsl:when
				test="
					not(($css/css:border-bottom-style,
					$css/css:border-bottom,
					$css/css:border-style,
					$css/css:border)[1]/(css:none,
					css:hidden)) and ($css/css:border-bottom-width/css:dimension,
					$css/css:border-bottom/css:dimension[1],
					$css/css:border/css:dimension[1])[1] > 0">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="css2cals:showBorderTop" as="xs:boolean">
		<xsl:param name="css" as="element(css:css)"/>
		<xsl:choose>
			<!-- specific settings for border-bottom overwrite general -->
			<xsl:when
				test="
					not(($css/css:border-top-style,
					$css/css:border-top,
					$css/css:border-style,
					$css/css:border)[1]/(css:none,
					css:hidden)) and ($css/css:border-top-width/css:dimension,
					$css/css:border-top/css:dimension[1],
					$css/css:border/css:dimension[1])[1] > 0">
				<xsl:copy-of select="true()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="false()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>