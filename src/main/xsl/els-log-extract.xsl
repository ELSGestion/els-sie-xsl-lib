<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:functx="http://www.functx.com"
  exclude-result-prefixes="#all"
  xmlns="http://www.w3.org/1999/xhtml"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Extraction logs from XML file which contains &lt;els:log&gt;</xd:p>
      <xd:p>This package defines several actions :</xd:p>
      <xd:ul>
        <xd:li>
          <xd:p>Creates a default &lt;html&gt; file using mode="els:extractLogs"</xd:p>
          <xd:p>$expectedLevel param must contain a string sequence of expected available levels</xd:p>
        </xd:li>
        <xd:li>remove all &lt;els:log&gt; from the source XML file using mode="els:removeLogs"</xd:li>
      </xd:ul>
      <xd:p>note : templates/functions could be overloaded</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:import href="functx.xsl"/>
 
  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Sequence of all the &lt;els:log&gt; status</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:param name="els:logLevels" select="('info', 'debug', 'warning', 'error', 'fatal', 'fixme', 'todo')" as="xs:string*"/>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Default empty &lt;html:style&gt; element</xd:p>
      <xd:p>The &lt;html:style&gt; variable could be overloaded if is needed</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="html:style" as="element(html:style)"><html:style/></xsl:variable>
 
  <!--==================================================-->
  <!--INIT-->
  <!--==================================================-->
   
  <xd:doc>
    <xd:desc>
      <xd:p>Default main template for testing</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="/">
    <xsl:apply-templates select="." mode="els:extractLogs">
      <xsl:with-param name="expectedLogLevels" select="$els:logLevels"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!--==================================================-->
  <!--MAIN mode="els:extractLogs" -->
  <!--==================================================-->
    
  <xd:doc>
    <xd:desc>
      <xd:p>Main template mode="els:extractLogs"</xd:p>
    </xd:desc>
    <xd:param name="expectedLogLevels">sequence of levels which will be extracted</xd:param>
  </xd:doc>
  <xsl:template match="/*" mode="els:extractLogs">
    <xsl:param name="expectedLogLevels" as="xs:string*" select="$els:logLevels"/>
    <!-- sequence of &lt;els:log&gt;-->
    <xsl:variable name="elsLogs" select="descendant::els:log[@level=$expectedLogLevels]" as="element(els:log)*"/>    
    <xsl:call-template name="els:createLogFile">
      <xsl:with-param name="elsLogs" select="$elsLogs"/>
      <xsl:with-param name="expectedLogLevels" select="$expectedLogLevels"/>
    </xsl:call-template>
  </xsl:template>
  
  <!--==================================================-->
  <!-- mode="els:removeLogs" -->
  <!--==================================================-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Remove the &lt;els:log&gt; of the document</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="els:log" mode="els:removeLogs"/>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Create the log file</xd:p>
      <xd:p>Default template name, can be surcharged</xd:p>
    </xd:desc>
    <xd:param name="elsLogs">sequence of &lt;els:log&gt;</xd:param>
    <xd:param name="expectedLogLevels">levels of logs to be displayed</xd:param>
  </xd:doc>
  <xsl:template name="els:createLogFile">
    <xsl:param name="elsLogs" as="element(els:log)*"/>
    <xsl:param name="expectedLogLevels" as="xs:string*"/>
    <!-- Create the title of html page -->
    <xsl:variable name="html:title" as="item()*">
      <xsl:call-template name="els:getLogHtmlTitle">
        <xsl:with-param name="expectedLogLevels" select="$expectedLogLevels"/>
      </xsl:call-template>
    </xsl:variable>
    <html>
      <head>
        <title>
          <xsl:sequence select="$html:title"/>
        </title>
        <xsl:sequence select="$html:style"/>
      </head>
      <body>
        <h1><xsl:sequence select="$html:title"/></h1>
        <xsl:choose>
          <xsl:when test="not(els:hasLevelsLog(., $expectedLogLevels))">
            <h2>No logs</h2>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="$elsLogs">        
              <xsl:call-template name="els:displayLog">
                <xsl:with-param name="e" select="."/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Default display of each &lt;els:log&gt;</xd:p>
    </xd:desc>
    <xd:param name="e">&lt;els:log&gt; element</xd:param>
  </xd:doc>
  <xsl:template name="els:displayLog" as="item()*">
    <xsl:param name="e" as="element(els:log)"/>
    <xsl:comment>&lt;template name="els:getLogDescription"&gt; must be overloaded</xsl:comment>
    <h2>     
      <b><xsl:sequence select="els:getLogCode($e)"/> - <xsl:sequence select="functx:capitalize-first(els:getLogLevel($e))"/> (<xsl:sequence select="els:geLogtXsltName($e)"/>)</b>
    </h2>
    <xsl:sequence select="$e/node()"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns @xsltName if exists</xd:p>
    </xd:desc>
    <xd:param name="e">&lt;els:log&gt; element</xd:param>
  </xd:doc>
  <xsl:function name="els:geLogtXsltName" as="xs:string?">
    <xsl:param name="e" as="element(els:log)"/>
    <xsl:sequence select="$e/@xsltName"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Returns @level if exists</xd:p>
    </xd:desc>
    <xd:param name="e">&lt;els:log&gt; element</xd:param>
  </xd:doc>
  <xsl:function name="els:getLogLevel" as="xs:string?">
    <xsl:param name="e" as="element(els:log)"/>
    <xsl:sequence select="$e/@level"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns @code if exists</xd:p>
    </xd:desc>
    <xd:param name="e">&lt;els:log&gt; element</xd:param>
  </xd:doc>
  <xsl:function name="els:getLogCode" as="xs:string?">
    <xsl:param name="e" as="element(els:log)"/>
    <xsl:sequence select="$e/@code"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns true() if there is at least one &lt;els:log&gt; with @level = $level</xd:p>
    </xd:desc>
    <xd:param name="e">element and descendants to check</xd:param>
    <xd:param name="levels">sequence of level to check</xd:param>
  </xd:doc>
  <xsl:function name="els:hasLevelsLog" as="xs:boolean">
    <xsl:param name="e" as="element()"/> 
    <xsl:param name="levels" as="xs:string*"/>
    <xsl:sequence select="exists($e/descendant::els:log[@level=$levels])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the default content of &lt;html:title&gt;</xd:p>
    </xd:desc>
    <xd:param name="expectedLogLevels">sequence of expected log levels</xd:param>
  </xd:doc>
  <xsl:template name="els:getLogHtmlTitle" as="item()*">
    <xsl:param name="expectedLogLevels" as="xs:string*"/>
    <xsl:text>Report on the </xsl:text>
    <xsl:variable name="nbr" select="count($expectedLogLevels)" as="xs:integer"/>
    <xsl:for-each select="$expectedLogLevels">
      <xsl:choose>
        <xsl:when test="$nbr &gt; 1 and position() = last()">
          <xsl:text> and </xsl:text>
        </xsl:when>
        <xsl:when test="$nbr &gt; 1 and position() &gt; 1">
          <xsl:text>, </xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text>"</xsl:text>
      <xsl:sequence select="functx:capitalize-first(.)"/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
    <xsl:text> logs</xsl:text>    
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Default mode</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="node() | @*" mode="els:extractLogs els:removeLogs" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>