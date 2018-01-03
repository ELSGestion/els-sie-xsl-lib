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
      <xd:p>ELS-COMMON lib : module "CONVERSION AND CASTING" utilities</xd:p>
    </xd:desc>
  </xd:doc>
  
  <!--conversion roman2numeric adapted from http://users.atw.hu/xsltcookbook2/xsltckbk2-chp-3-sect-3.html-->
  
  <!--An XML map decimal/roman numerals-->
  <xsl:variable name="els:roman-value" as="element(els:roman)+">
    <els:roman value="1">I</els:roman>
    <els:roman value="5">V</els:roman>
    <els:roman value="10">X</els:roman>
    <els:roman value="50">L</els:roman>
    <els:roman value="100">C</els:roman>
    <els:roman value="500">D</els:roman>
    <els:roman value="1000">M</els:roman>
  </xsl:variable>
  
  <xd:doc>Implementation : recursiv template to convert roman numerals to decimal numbers</xd:doc>
  <xsl:template name="els:roman-to-number-impl" as="xs:string" visibility="private">
    <xsl:param name="roman" as="xs:string"/>
    <xsl:param name="value" select="0" as="xs:integer"/>
    <xsl:variable name="len" select="string-length($roman)" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="not($len)">
        <xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:when test="$len = 1">
        <xsl:value-of select="$value + $els:roman-value[. = $roman]/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="roman-num" select="$els:roman-value[. = substring($roman, 1, 1)]" as="element(els:roman)?"/>
        <xsl:choose>
          <xsl:when test="$roman-num/following-sibling::els:roman = substring($roman, 2, 1)">
            <xsl:call-template name="els:roman-to-number-impl">
              <xsl:with-param name="roman" select="substring($roman,2,$len - 1)" as="xs:string"/>
              <xsl:with-param name="value" select="$value - xs:integer($roman-num/@value)" as="xs:integer"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="els:roman-to-number-impl">
              <xsl:with-param name="roman" select="substring($roman, 2, $len - 1)" as="xs:string"/>
              <xsl:with-param name="value" select="$value + xs:integer($roman-num/@value)" as="xs:integer"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>Converts roman numerals to decimal numbers</xd:doc>
  <xsl:function name="els:roman2numeric" as="xs:string">
    <xsl:param name="roman" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="translate($roman, string-join($els:roman-value/text(), ''), '') != ''">
        <xsl:text>NaN</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="els:roman-to-number-impl">
          <xsl:with-param name="roman" select="$roman" as="xs:string"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!--debug test : 
    <xsl:for-each select="('I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX')">
      <xsl:call-template name="els:crlf"/>
      <xsl:value-of select="."/><xsl:text>=</xsl:text><xsl:value-of select="els:roman2numeric(.)"/>
    </xsl:for-each>-->
  </xsl:function>
  
  <xd:doc>Convert a one character string to an numeric (representing the position in the alphabet)</xd:doc>
  <xsl:function name="els:litteral2numeric" as="xs:integer">
    <xsl:param name="lit" as="xs:string"/>
    <xsl:value-of select="index-of(('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'), upper-case($lit))"/>
  </xsl:function>
  
  <xd:doc>Check if atomic value is an "number"</xd:doc>
  <xsl:function name="els:isNumber" as="xs:boolean">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="number($s) = number($s)"/>
    <!--cf. http://www.xsltfunctions.com/xsl/functx_is-a-number.html-->
  </xsl:function>
  
  <xd:doc>Check if atomic value is an integer</xd:doc>
  <xsl:function name="els:isInteger" as="xs:boolean">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="$s castable as xs:integer"/>
  </xsl:function>
  
  <xd:doc>Check if atomic value is an anyURI</xd:doc>
  <xsl:function name="els:isAnyUri" as="xs:boolean">
    <xsl:param name="item" as="item()?"/>
    <xsl:value-of select="$item castable as xs:anyURI"/>
  </xsl:function>
  
  <xd:doc>1 arg signature of els:round. Default $precision = 0 (that's why it returns an integer)</xd:doc>
  <xsl:function name="els:round" as="xs:integer">
    <xsl:param name="number" as="xs:double"/>
    <xsl:value-of select="els:round($number,0) cast as xs:integer"/>
  </xsl:function>
  
  <xd:doc>Get the round number of any $number with the specified $precision</xd:doc>
  <xsl:function name="els:round" as="xs:double">
    <xsl:param name="number" as="xs:double"/>
    <xsl:param name="precision" as="xs:integer"/>
    <xsl:variable name="multiple" select="number(concat('10E',string($precision - 1))) cast as xs:integer" as="xs:integer"/> <!--for $i to $precision return 10-->
    <xsl:value-of select="round($number*$multiple) div $multiple"/>
    <!--cf. http://www.xsltfunctions.com/xsl/fn_round.html but no precision-->
    <!--FIXME : check the nativ function round-half-to-even($arg,$precision)
      It seems to do exactly the sampe : http://www.liafa.jussieu.fr/~carton/Enseignement/XML/Cours/XPath/index.html -->
  </xsl:function>
  
  <xd:doc>Converts hexadecimal number to decimal number</xd:doc>
  <xsl:function name="els:hexToDec" as="xs:integer?">
    <xsl:param name="str" as="xs:string"/>
    <xsl:if test="$str != ''">
      <xsl:variable name="len" select="string-length($str)" as="xs:integer"/>
      <xsl:value-of select="
        if ( $len lt 2 ) then
          string-length(substring-before('0 1 2 3 4 5 6 7 8 9 AaBbCcDdEeFf', $str)) idiv 2
        else
        xs:integer(els:hexToDec(substring($str, 1, $len - 1)))  * 16 + xs:integer(els:hexToDec(substring($str, $len)))"/>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>Converts decimal number to hexadecimal number</xd:doc>
  <xsl:function name="els:decToHex" as="xs:string">
    <xsl:param name="n.decimal" as="xs:integer"/>
    <xsl:sequence
      select="if ($n.decimal eq 0) then '0'
        else concat( if ($n.decimal gt 16) then els:decToHex($n.decimal idiv 16) else '', substring('0123456789ABCDEF', ($n.decimal mod 16) + 1, 1))"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Convert an atomic value to a boolean</xd:p>
      <xd:p>If the value is equal to "TRUE", "OUI", "VRAI", it returns true()</xd:p>
    </xd:desc>
  </xd:doc>
  <!--FIXME : use castable as xs:boolean and treat only specific values + language parameter = fr ?-->
  <xsl:function name="els:convertToBoolean" as="xs:boolean">
    <xsl:param name="var" as="item()?" />
    <xsl:value-of 
      select="if (not(exists($var))) then (false())
              else (if ($var instance of xs:boolean) then ($var)
                   else (if ($var instance of xs:integer) then (boolean($var))
                     else (if ($var instance of xs:string) then (boolean(upper-case($var)='OUI' or upper-case($var)='TRUE' or upper-case($var)='VRAI'))
                           else (false())
              )))"/>
  </xsl:function>
  
</xsl:stylesheet>
