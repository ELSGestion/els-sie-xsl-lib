<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "STRINGS" utilities</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:import href="els-common_constants.xsl"/>

  <xd:doc>
    <xd:desc>
      <xd:p>Perform successiv regex replacements on a string with 2 parameters</xd:p>
    </xd:desc>
    <xd:param name="string">The string to work on</xd:param>
    <xd:param name="replace-list">An element els:replace-list with any els:replace as children. 
      Example:
      <xd:pre>
      &lt;replace-list flags="[optionnal attribut for regex flags]" xmlns="http://www.lefebvre-sarrut.eu/ns/els">
        &lt;replace flags="[optionnal attribut for regex flags]">
          &lt;pattern>[any regex]&lt;/pattern>
          &lt;replacement>[replacement using $1, $2, etc. as regex-group replacement, like replace() third arg]&lt;/replacement>
        &lt;/replace>
        &lt;replace flags="x">
          &lt;pattern>(x) (x) (x)&lt;/pattern>
          &lt;replacement>Y$2Y&lt;/replacement>
        &lt;/replace>
      &lt;/replace-list>
      </xd:pre>
    </xd:param>
    <xd:return>The string after performing all regex replacements succesively</xd:return>
  </xd:doc>
  <xsl:function name="els:replace-multiple" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:param name="replace-list" as="element(els:replace-list)"/>
    <xsl:sequence select="els:replace-multiple($string, $replace-list, 1)"></xsl:sequence>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Perform successiv regex replacements on a string with 3 parameters</xd:p>
    </xd:desc>
    <xd:param name="string">The string to work on</xd:param>
    <xd:param name="replace-list">An element els:replace-list with any els:replace as children. 
      Example:
      <xd:pre>
      &lt;replace-list flags="[optionnal attribut for regex flags]" xmlns="http://www.lefebvre-sarrut.eu/ns/els">
        &lt;replace flags="[optionnal attribut for regex flags]">
          &lt;pattern>[any regex]&lt;/pattern>
          &lt;replacement>[replacement using $1, $2, etc. as regex-group replacement, like replace() third arg]&lt;/replacement>
        &lt;/replace>
        &lt;replace flags="x">
          &lt;pattern>(x) (x) (x)&lt;/pattern>
          &lt;replacement>Y$2Y&lt;/replacement>
        &lt;/replace>
      &lt;/replace-list>
      </xd:pre>
    </xd:param>
    <xd:param name="nextPos">Position of the first executed &lt;els:replace&gt;</xd:param>
    <xd:return>The string after performing regex following $nextPos replacements succesively</xd:return>
  </xd:doc>
  <xsl:function name="els:replace-multiple" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:param name="replace-list" as="element(els:replace-list)"/>
    <xsl:param name="nextPos" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="empty($replace-list/els:replace[$nextPos])">
        <xsl:sequence select="$string"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="current-replace" select="$replace-list/els:replace[$nextPos]" as="element(els:replace)"/>
        <!--Possible regex flags values: 
              m: multiline mode
              s : dot-all mode
              i : case-insensitive
              x : ignore whitespace within the regex
              Note: add ";j" at the end of the @flags set the java regex process.
            -->
        <xsl:variable name="string.replaced" select="replace(
          $string, 
          string($current-replace/els:pattern), 
          string($current-replace/els:replacement), 
          string($current-replace/ancestor-or-self::*[@flags][1]/@flags)
          )" as="xs:string"/>
        <xsl:sequence select="els:replace-multiple($string.replaced, $replace-list, $nextPos + 1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Normalize the string: remove diacritic marks.</xd:p>
      <xd:p>Example: els:normalize-no-diacritic('éêèàœç')='eeeaœc'</xd:p>
    </xd:desc>
    <xd:param name="string"/>
    <xd:return>the <xd:b>string</xd:b> normalized</xd:return>
  </xd:doc>
  <xsl:function name="els:normalize-no-diacritic" as="xs:string">
    <xsl:param name="string" as="xs:string"/>
    <xsl:sequence select="replace(normalize-unicode($string, 'NFD'), '[\p{M}]', '')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <!--FIXME : difference with els:normalize-no-diacritic ? this function has been copied from Flash SAS EFL-->
      <xd:p>Normalize the string by removing accents</xd:p>
    </xd:desc>
    <xd:param name="string">The string to normalize</xd:param>
  </xd:doc>
  <xsl:function name="els:strip-accent" as="xs:string">
    <xsl:param name="string" as="xs:string?"/>
    <xsl:value-of select="normalize-unicode(replace(normalize-unicode($string, 'NFD'), '\p{Mn}', ''), 'NFC')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>"carriage return line feed" : generates N carriage return</xd:p>
    </xd:desc>
    <xd:param name="n">[Integer] number of carriage return to generate (should be positiv)</xd:param>
  </xd:doc>
  <xsl:function name="els:crlf" as="xs:string*">
    <xsl:param name="n" as="xs:integer"/>
    <!--Ignore negativ $n-->
    <xsl:if test="$n gt 0">
      <xsl:for-each select="1 to $n">
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>0 args Signature for els:crlf() : by default only one carriage return</xd:doc>
  <xsl:function name="els:crlf" as="xs:string">
    <xsl:sequence select="els:crlf(1)"/>
  </xsl:function>
  
  <xd:doc>1 args Signature for els:getFirstChar : by default the first 1 character</xd:doc>
  <xsl:function name="els:getFirstChar" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <!--<xsl:value-of select="substring($s,1,1)"/>-->
    <xsl:sequence select="els:getFirstChar($s,1)"/>
  </xsl:function>
  
  <xd:doc>Get the first $n characters of a string</xd:doc>
  <xsl:function name="els:getFirstChar" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:param name="n" as="xs:integer"/>
    <xsl:value-of select="substring($s,1,$n)"/>
  </xsl:function>
  
  <xd:doc>Get the rest of the string after removing the first character</xd:doc>
  <xsl:function name="els:getStringButFirstChar" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="substring($s,2)"/>
  </xsl:function>
  
  <xd:doc>Express any string with a capital as first letter, force the rest letters in lowercase</xd:doc>
  <xsl:function name="els:capFirst_lowercase" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="concat(upper-case(els:getFirstChar($s)),lower-case(els:getStringButFirstChar($s)))"/>
  </xsl:function>
  
  <xd:doc>Express any string with a capital as first letter, let the rest letters as is</xd:doc>
  <xsl:function name="els:capFirst" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="concat(upper-case(els:getFirstChar($s)), els:getStringButFirstChar($s))"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Determin if a string is kind of empty considering any whitespace as empty characters</xd:p>
    </xd:desc>
    <xd:param name="s">Any string</xd:param>
    <xd:return>Boolean : true() if $s is the empty string '' or if it only contains whitespaces, else false()</xd:return>
  </xd:doc>
  <xsl:function name="els:is-empty-or-whitespace" as="xs:boolean">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:sequence select="matches($s, concat('^', $els:regAnySpace, '*$'))"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Return the string value of a node, normalizing white-spaces for each descendant text()</xd:p>
      <xd:p>The default separator between 2 text() is an espace, it can be overrided</xd:p>
    </xd:desc>
    <xd:param name="node">Any node (but it makes sens if the node has text() descendants)</xd:param>
    <xd:param name="separator">Separator between text() nodes</xd:param>
    <xd:return>Normalize string value of the node</xd:return>
  </xd:doc>
  <xsl:function name="els:normalized-string" as="xs:string">
    <xsl:param name="node" as="node()?"/>
    <xsl:param name="separator" as="xs:string"/>
    <xsl:sequence select="string-join($node/descendant::text()[normalize-space(.)], $separator)"/>
  </xsl:function>
  
  <xd:doc>By default the separator is a whitespace character (just like &lt;xsl:value-of)</xd:doc> 
  <xsl:function name="els:normalized-string" as="xs:string">
    <xsl:param name="node" as="node()?"/>
    <xsl:sequence select="els:normalized-string($node, ' ')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Check the text existance of an element except his children</xd:p>
    </xd:desc>
    <xd:param name="e">element to check</xd:param>
    <xd:return>true() if there is not texte, otherwise false()</xd:return>
  </xd:doc>
  <xsl:function name="els:hasNoTextChildExceptWhiteSpace" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:sequence select="els:is-empty-or-whitespace(normalize-space(string-join($e/text(), '')))"/>      
  </xsl:function>
  
  <!--=====================-->
  <!-- MODE els:UPPERCASE -->
  <!--=====================-->
  <!--a specific mode to go uppercase on text keeping existing inline elements-->
  
  <xsl:template match="text()" mode="els:uppercase" priority="1">
    <xsl:value-of select="upper-case(.)"/>  
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:uppercase">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--=====================-->
  <!-- MODE els:LOWERCASE -->
  <!--=====================-->
  <!--a specific mode to go lowercase on text keeping existing inline elements-->
  
  <xsl:template match="text()" mode="els:lowercase" priority="1">
    <xsl:value-of select="lower-case(.)"/>  
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:lowercase">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>