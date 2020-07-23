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
    <xsl:sequence select="index-of(('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'), upper-case($lit))"/>
  </xsl:function>
  
  <xd:doc>Check if atomic value is an "number"</xd:doc>
  <!--FIXME : cf. http://www.xsltfunctions.com/xsl/functx_is-a-number.html-->
  <xsl:function name="els:isNumber" as="xs:boolean">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="empty($s)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="number($s) = number($s)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>Check if atomic value is an integer</xd:doc>
  <xsl:function name="els:isInteger" as="xs:boolean">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="empty($s)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$s castable as xs:integer"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>Check if atomic value is an anyURI</xd:doc>
  <xsl:function name="els:isAnyUri" as="xs:boolean">
    <xsl:param name="item" as="item()?"/>
    <xsl:choose>
      <xsl:when test="empty($item)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$item castable as xs:anyURI"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>1 arg signature of els:round. Default $precision = 0 (that's why it returns an integer)</xd:doc>
  <xsl:function name="els:round" as="xs:integer">
    <xsl:param name="number" as="xs:double"/>
    <xsl:sequence select="els:round($number,0) cast as xs:integer"/>
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
      <xd:p>DEPRECATED FUNCTION : USE els:convertAtomicValueToCanonicalBooleanValue($var,'fr') INSTEAD.</xd:p>
      <xd:p>Convert an atomic value to a boolean</xd:p>
      <xd:p>If the value is equal to "TRUE", "OUI", "VRAI", it returns true()</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:convertToBoolean" as="xs:boolean">
    <xsl:param name="var" as="item()?" />
    <xsl:message>[WARNING] Function els:convertToBoolean($var) is deprecated and may be removed from future releases. Use els:convertAtomicValueToCanonicalBooleanValue($var,'fr') instead.</xsl:message>
    <xsl:sequence select="els:convertAtomicValueToCanonicalBooleanValue($var,'fr')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Converts an atomic value to a xs:boolean in its canonical form (true() / false()).</xd:p>
      <xd:p>The <xd:ref name="lang" type="parameter">$lang</xd:ref> parameter allows the conversion of non-canonical string forms:</xd:p>
      <xd:ul>
        <xd:li>$lang = 'fr': 'OUI' / 'VRAI'.</xd:li>
        <xd:li>$lang = 'en': 'YES'.</xd:li>
      </xd:ul>
    </xd:desc>
    <xd:param name="var">[item()?] An atomic value.</xd:param>
    <xd:param name="lang">[xs:string] A language code for non-canonical string forms.</xd:param>
    <xd:return>[xs:boolean] The boolean converted atomic value in its canonical form.</xd:return>
  </xd:doc>
  <xsl:function name="els:convertAtomicValueToCanonicalBooleanValue" as="xs:boolean">
    <xsl:param name="var" as="item()?"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:sequence select="if (not(exists($var))) then (false())
                          else (
                            if ($var castable as xs:boolean) then ($var cast as xs:boolean)
                            else (
                              if ($var instance of xs:string and $lang = 'fr') then (boolean(upper-case($var) = 'OUI' or upper-case($var) = 'VRAI'))
                              else (
                                if ($var instance of xs:string and $lang = 'en') then (boolean(upper-case($var) = 'YES'))
                                else (false())
                              )
                            )
                          )"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Converts an atomic value to a xs:boolean in its canonical form (true() / false()).</xd:p>
      <xd:p>The <xd:ref name="lang" type="parameter">$lang</xd:ref> parameter allows the conversion of non-canonical string forms.</xd:p>
      <xd:p>The <xd:ref name="lang" type="parameter">$lang</xd:ref> default value is "fr".</xd:p>
    </xd:desc>
    <xd:param name="var">[item()?] An atomic value.</xd:param>
    <xd:return>[xs:boolean] The boolean converted atomic value in its canonical form.</xd:return>
  </xd:doc>
  <xsl:function name="els:convertAtomicValueToCanonicalBooleanValue" as="xs:boolean">
    <xsl:param name="var" as="item()?"/>
    <xsl:sequence select="els:convertAtomicValueToCanonicalBooleanValue($var,'fr')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Converts an atomic value to a xs:boolean in its integer form (1 / 0).</xd:p>
      <xd:p>The <xd:ref name="lang" type="parameter">$lang</xd:ref> parameter allows the conversion of non-canonical string forms:</xd:p>
      <xd:ul>
        <xd:li>$lang = 'fr': 'OUI' / 'VRAI'.</xd:li>
        <xd:li>$lang = 'en': 'YES'.</xd:li>
      </xd:ul>
    </xd:desc>
    <xd:param name="var">[item()?] An atomic value.</xd:param>
    <xd:param name="lang">[xs:string] A language code for non-canonical string forms.</xd:param>
    <xd:return>[xs:integer] The boolean converted atomic value in its integer form.</xd:return>
  </xd:doc>
  <xsl:function name="els:convertAtomicValueToIntegerBooleanValue" as="xs:integer">
    <xsl:param name="var" as="item()?"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:sequence select="if (not(exists($var))) then (0)
                          else (
                            if ($var castable as xs:boolean) then (els:convertCanonicalBooleanValueToIntegerBooleanValue($var cast as xs:boolean))
                            else (
                              if ($var instance of xs:string and $lang = 'fr') then (els:convertCanonicalBooleanValueToIntegerBooleanValue(upper-case($var) = 'OUI' or upper-case($var) = 'VRAI'))
                              else (
                                if ($var instance of xs:string and $lang = 'en') then (els:convertCanonicalBooleanValueToIntegerBooleanValue(upper-case($var) = 'YES'))
                                else (0)
                              )
                            )
                          )"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Converts an atomic value to a xs:boolean in its integer form (1 / 0).</xd:p>
      <xd:p>The <xd:ref name="lang" type="parameter">$lang</xd:ref> parameter allows the conversion of non-canonical string forms.</xd:p>
      <xd:p>The <xd:ref name="lang" type="parameter">$lang</xd:ref> default value is "fr".</xd:p>
    </xd:desc>
    <xd:param name="var">[item()?] An atomic value.</xd:param>
    <xd:return>[xs:integer] The boolean converted atomic value in its integer form.</xd:return>
  </xd:doc>
  <xsl:function name="els:convertAtomicValueToIntegerBooleanValue" as="xs:integer">
    <xsl:param name="var" as="item()?"/>
    <xsl:sequence select="els:convertAtomicValueToIntegerBooleanValue($var,'fr')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Converts an xs:boolean in its canonical form (true() / false()) to its integer form (1 / 0).</xd:p>
    </xd:desc>
    <xd:param name="val">[xs:boolean] A boolean value.</xd:param>
    <xd:return>[xs:integer] The boolean value in its integer form.</xd:return>
  </xd:doc>
  <xsl:function name="els:convertCanonicalBooleanValueToIntegerBooleanValue" as="xs:integer">
    <xsl:param name="val" as="xs:boolean"/>
    <xsl:sequence select="if ($val = true()) then (1) else (0)"/>
  </xsl:function>
  
</xsl:stylesheet>