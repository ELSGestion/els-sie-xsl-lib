<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:functx="http://www.functx.com" 
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Generic XSL functions/templates library used at ELS</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:include href="functx.xsl"/>

  <!--===================================================  -->
  <!--                OUTPUT                              -->
  <!--===================================================  -->
  
  <xsl:output name="els:xml" method="xml"/>
  <xsl:output name="els:xml.indent" method="xml" indent="yes"/>
  <xsl:output name="els:text" method="text"/>
  
  <!--===================================================  -->
  <!--                COMMON VAR      -->
  <!--===================================================  -->
  <xd:doc>
    <xd:desc>
      <xd:p>double/simple quot variable, might be usefull within a concat for example</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="els:dquot" as="xs:string">
    <xsl:text>"</xsl:text>
  </xsl:variable>
  <xsl:variable name="els:quot" as="xs:string">
    <xsl:text>'</xsl:text>
  </xsl:variable>

  <xd:p>Variable "regAnySpace" : matches any spaces (non-break space, thin space, etc.)</xd:p>
  <xsl:variable name="els:regAnySpace" select="'\p{Z}'" as="xs:string"/>
  
  <xd:p>Variable "regAnyPonctuation" : matches any ponctuation (point, coma, semicolon, etc.)</xd:p>
  <xd:p>(cf. http://www.regular-expressions.info/unicode.html)</xd:p>
  <xsl:variable name="els:regAnyPonctuation" select="'\p{P}'" as="xs:string"/>  
  
  <xd:p>Variable "end of word" (equivalent to "\b" in regex)</xd:p>
  <xsl:variable name="els:regWordBoundery" select="concat($els:regAnySpace, '|', $els:regAnyPonctuation)" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>TYPOGRAPHIC SPACES</xd:desc>
    <xd:p>Every spaces from the largest to the thinest : &amp;#x2000; (same width as letter "M") => &amp;#x200b; (zero width space - breakable)</xd:p>
    <xd:p>Tip : Use the software "SC UNIPAD" to see and convert spaces. cf. http://theme.unblog.fr/2007/05/18/ponctuation/</xd:p>
  </xd:doc>
  <xsl:variable name="els:EN_QUAD" select="'&#x2000;'" as="xs:string"/><!--(1/8 cadratin)= " "-->
  <xsl:variable name="els:NARROW_NO_BREAK_SPACE" select="'&#x202f;'" as="xs:string"/><!--= " "-->
  <xsl:variable name="els:NO_BREAK_SPACE" select="'&#x00a0;'" as="xs:string"/><!-- = " "-->
  <xsl:variable name="els:ZERO_WIDTH_SPACE" select="'&#x200b;'" as="xs:string"/><!-- = "​​"-->
  <xsl:variable name="els:ZERO_WIDTH_NO_BREAK_SPACE" select="'&#xfeff;'" as="xs:string"/><!--(non matché par '\p{Z}') = "﻿"-->
  <xsl:variable name="els:HAIR_SPACE" select="'&#x200A;'" as="xs:string"/><!--("espace ultra fine sécable") = " "-->
  <xsl:variable name="els:PONCTUATION_SPACE" select="'&#x2008;'" as="xs:string"/><!--(1/3 de cadratin ?) = " "-->
  <xsl:variable name="els:THIN_SPACE" select="'&#x2009;'" as="xs:string"/><!--(espaces fine ou quart de cadratin?) = " "-->
  <xsl:variable name="els:EN_SPACE" select="'&#x2002;'" as="xs:string"/><!-- https://www.cs.sfu.ca/~ggbaker/reference/characters/#space -->
  
  <!--===================================================  -->
  <!-- DATES -->
  <!--===================================================  -->
  
  <xd:doc>Variables for giving Month in any language</xd:doc>
  <xsl:variable name="els:months.fr" select="('janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre')" as="xs:string+"/>
  <xsl:variable name="els:monthsShort.fr" select="('janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juill.', 'août', 'sept.', 'oct.', 'nov.', 'déc.')" as="xs:string+"/>
  
  <xd:doc>Get the current date as string in ISO format YYYY-MM-DD</xd:doc>
  <xsl:function name="els:getCurrentIsoDate" as="xs:string">
    <xsl:sequence select="format-dateTime(current-dateTime(),'[Y0001]-[M01]-[D01]')"/>
  </xsl:function>
  
  <xd:doc>Get the year as string from any ISO date : YYYY-MM-DD would get "YYYY"</xd:doc>
  <xsl:function name="els:getYearFromIsoDate" as="xs:string">
    <xsl:param name="isoDate" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:isIsoDate($isoDate)">
        <xsl:value-of select="tokenize($isoDate, '-')[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getYearFromIsoDate] param $isoDate="<xsl:value-of select="$isoDate"/>" is not an ISO format "YYYY-MM-DD"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>Get the month number as string from any ISO date : YYYY-MM-DD would get "MM"</xd:doc>
  <xsl:function name="els:getMonthFromIsoDate" as="xs:string">
    <xsl:param name="isoDate" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:isIsoDate($isoDate)">
        <xsl:value-of select="tokenize($isoDate, '-')[2]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getMonthFromIsoDate] param $isoDate="<xsl:value-of select="$isoDate"/>" is not an ISO format "YYYY-MM-DD"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>Get the day number as string from any ISO date : YYYY-MM-DD would get "DD"</xd:doc>
  <xsl:function name="els:getDayFromIsoDate" as="xs:string">
    <xsl:param name="isoDate" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:isIsoDate($isoDate)">
        <xsl:value-of select="tokenize($isoDate, '-')[3]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getDayFromIsoDate] param $isoDate="<xsl:value-of select="$isoDate"/>" is not an ISO format "YYYY-MM-DD"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>Determine if a string is of format ISO date "YYYY-MM-DD"</xd:doc>
  <xsl:function name="els:isIsoDate" as="xs:boolean">
    <xsl:param name="dateString" as="xs:string"/>
    <xsl:sequence select="matches($dateString, '^\d\d\d\d-\d\d-\d\d$')"/>
  </xsl:function>
  
  <xd:doc>Returns an ISO date (xs:date) from a string whose format is "YYYYMMDD"</xd:doc>
  <xsl:function name="els:makeIsoDateFromYYYYMMDD" as="xs:string?">
    <xsl:param name="date" as="xs:string"/>
    <xsl:variable name="day" select="substring($date, 7, 2)" as="xs:string"/>
    <xsl:variable name="month" select="substring($date, 5, 2)" as="xs:string"/>
    <xsl:variable name="year" select="number(substring($date, 1, 4))" as="xs:double"/>
    <xsl:sequence select="els:getIsoDateFromString(concat($year, '-', $month, '-', $day))"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns an ISO date (xs:date) from a string (typically: a serialized date), formatted as YYYY-MM-DD.</xd:p>
      <xd:p>The input parameter (<xd:ref name="date" type="parameter">$date</xd:ref>) is tested and must be castable either as xs:date or xs:dateTime.</xd:p>
      <xd:p>If the input parameter can be casted as xs:dateTime, only the substring corresponding to the date part is returned.</xd:p>      
    </xd:desc>
    <xd:param name="date">[xs:string] A string, which must be a serialized xs:date or xs:dateTime.</xd:param>
    <xd:return>[xs:string?] The ISO date value of the input string.</xd:return>
  </xd:doc>
  <xsl:function name="els:getIsoDateFromString" as="xs:string?">
    <xsl:param name="date" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$date castable as xs:dateTime">
        <xsl:value-of select="format-dateTime($date cast as xs:dateTime,'[Y0001]-[M01]-[D01]')"/>
      </xsl:when>
      <xsl:when test="$date castable as xs:date">
        <xsl:value-of select="format-date($date cast as xs:date,'[Y0001]-[M01]-[D01]')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getIsoDateFromString] The input date format is not recognized : '<xsl:value-of select="$date"/>'.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>1 arg signature of els:verbalizeMonthFromNum : default language is "french"</xd:doc>
  <xsl:function name="els:verbalizeMonthFromNum" as="xs:string">
    <xsl:param name="monthNumString" as="xs:string"/>
    <xsl:sequence select="els:verbalizeMonthFromNum($monthNumString, $els:months.fr)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Verbalize a month as number to a string</xd:p>
    </xd:desc>
    <xd:param name="monthNumber">[String] The month number as string "XX" or "X"</xd:param>
    <xd:param name="months.verbalized">[String+] All months verbalized in the good language</xd:param>
    <xd:return>[String] The verbalized month</xd:return>
  </xd:doc>
  <xsl:function name="els:verbalizeMonthFromNum" as="xs:string">
    <xsl:param name="monthNumString" as="xs:string"/>
    <xsl:param name="months.verbalized" as="xs:string+"/>
    <xsl:variable name="monthNumInt" select="if($monthNumString castable as xs:integer) then(xs:integer($monthNumString)) else(0)" as="xs:integer"/>
    <xsl:variable name="result" select="$months.verbalized[$monthNumInt]" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="exists($result)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[ErreurMois]</xsl:text>
        <xsl:message>[ERROR][els:verbalizeMonthFromNum] Unable to get the month string from month number '<xsl:value-of select="$monthNumString"/>'</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>1 arg signature of els:getMonthNumFromVerbalizeMonth : default language is "french"</xd:doc>
  <xsl:function name="els:getMonthNumFromVerbalizeMonth" as="xs:integer">
    <xsl:param name="monthString" as="xs:string"/>
    <xsl:sequence select="els:getMonthNumFromVerbalizeMonth($monthString, $els:months.fr)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Get the month num as integer from its verbalization</xd:p>
    </xd:desc>
    <xd:param name="monthString">[String] The month string (ex : "january", "février", etc.)</xd:param>
    <xd:param name="months.verbalized">[String+] All months as string verbalized in the good language</xd:param>
    <xd:return>[String] The verbalized month</xd:return>
  </xd:doc>
  <xsl:function name="els:getMonthNumFromVerbalizeMonth" as="xs:integer">
    <xsl:param name="monthString" as="xs:string"/>
    <xsl:param name="months.verbalized" as="xs:string+"/>
    <xsl:variable name="result" select="index-of($months.verbalized, $monthString)" as="xs:integer*"/>
    <xsl:choose>
      <xsl:when test="count($result) = 1">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
        <xsl:message>[ERROR][els:getMonthNumFromVerbalizeMonth] Unable to get an integer representation of the month from the string '<xsl:value-of select="$monthString"/>' : <xsl:value-of select="count($result)"/> match.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    
  <xd:doc>
    <xd:desc>
      <xd:p>Convert a string with format "JJ/MM/AAAA" (or "JJ-MM-AAAA" or "JJ/MM/AA") to a string representing an ISO date format "AAAA-MM-JJ"</xd:p>
      <xd:param name="s">String to convert as iso date string</xd:param>
      <xd:param name="sep">string representing the separator "/" (or something els) within the original string ($s)</xd:param>
    </xd:desc>
    <xd:return>Iso date of $s as a xs:string (if the convesion fails, it will return the original $s string)</xd:return>
  </xd:doc>
  <xsl:function name="els:makeIsoDate" as="xs:string">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:param name="sep" as="xs:string"/>
    <xsl:variable name="sToken" select="tokenize($s, $sep)" as="xs:string*"/>
    <xsl:variable name="regJJMMAAAA" as="xs:string" select="concat('^\d\d', $sep, '\d\d', $sep, '\d\d\d\d$')"/>
    <xsl:variable name="regJJMMAA" as="xs:string" select="concat('^\d\d', $sep, '\d\d', $sep, '\d\d')"/>
    <xsl:choose>
      <!--If $s is empty, we can't do anything : return the empty string-->
      <xsl:when test="empty($s)">
        <xsl:value-of select="''"/>
      </xsl:when>
      <!--If $sep is empty, we can't do anything : return the original string $s-->
      <xsl:when test="$sep = ''">
        <xsl:value-of select="$s"/>
      </xsl:when>
      <!--The string $s format is correct "JJ/MM/AAAA" : convert it to "AAAA-MM-JJ" -->
      <xsl:when test="matches($s, $regJJMMAAAA)">
        <xsl:value-of select="concat($sToken[3], '-', $sToken[2], '-', $sToken[1])"/>
      </xsl:when>
      <!--The string $s format is correct except the year which is on 2 digit "JJ/MM/AA" : convert it to "AAAA-MM-JJ" (trying to guess the century)-->
      <!--ASSUME : if AA is later than current AA, we consider AA was in the last century-->
      <xsl:when test="matches($s, $regJJMMAA)">
        <xsl:variable name="currentAAAA" select="year-from-date(current-date())" as="xs:integer"/>
        <xsl:variable name="currentAA__" select="substring(string($currentAAAA), 1, 2) cast as xs:integer" as="xs:integer"/>
        <xsl:variable name="current__AA" select="substring(string($currentAAAA), 3, 2) cast as xs:integer" as="xs:integer"/>
        <xsl:variable name="AA" select="xs:integer($sToken[3])" as="xs:integer"/>
        <xsl:variable name="AAAA" select="if ($AA gt $current__AA) then (concat($currentAA__ -1, $AA))  else (concat($currentAA__, $AA))" as="xs:string"/>
        <xsl:value-of select="concat($AAAA, '-', $sToken[2], '-', $sToken[1])"/>
      </xsl:when>
      <!--Unknown format : return the original string $s--> 
      <xsl:otherwise>
        <xsl:value-of select="$s"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    
  <xsl:function name="els:date-number-slash" as="xs:string">
    <xsl:param name="date" as="xs:string"/>
    <xsl:variable name="jour" select="substring($date, 9, 2)" as="xs:string"/>
    <xsl:variable name="mois" select="substring($date, 6, 2)" as="xs:string"/>
    <xsl:variable name="annee" select="substring($date, 1, 4)" as="xs:string"/>
    <xsl:value-of select="concat($jour, '/',$mois, '/', $annee)"/>
  </xsl:function>
  
  <xsl:function name="els:date-number-dash" as="xs:string">
    <xsl:param name="date" as="xs:string"/>
    <xsl:variable name="jour" select="substring($date, 9, 2)" as="xs:string"/>
    <xsl:variable name="mois" select="substring($date, 6, 2)" as="xs:string"/>
    <xsl:variable name="annee" select="substring($date, 1, 4)" as="xs:string"/>
    <xsl:value-of select="concat($jour, '-',$mois, '-', $annee)"/>
  </xsl:function>
  
  <xsl:function name="els:date-string" as="xs:string">
    <xsl:param name="date" as="xs:string"/>
    <xsl:variable name="jour" select="number(substring($date, 9, 2))" as="xs:double"/>
    <xsl:variable name="mois" select="els:verbalizeMonthFromNum(substring($date, 6, 2))" as="xs:string"/>
    <xsl:variable name="annee" select="number(substring($date,1, 4))" as="xs:double"/>
    <xsl:value-of select="concat($jour, ' ',$mois, ' ', $annee)"/>
  </xsl:function>
  
  <xd:doc>1 arg signature of els:displayDate : default months list is $els:months.fr</xd:doc>
  <xsl:function name="els:displayDate" as="xs:string">
    <xsl:param name="date" as="xs:string"/>
    <xsl:sequence select="els:displayDate($date, $els:months.fr)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Display a date at format YYYYMMDD to a verbalized date. Example: 19750910 => "10 Septembre 1975"</xd:p>
    </xd:desc>
    <xd:param name="date">[String] date a format YYYYMMDD</xd:param>
    <xd:param name="months.verbalized">[String] date</xd:param>
  </xd:doc>
  <xsl:function name="els:displayDate" as="xs:string">
    <xsl:param name="date" as="xs:string"/>
    <xsl:param name="months.verbalized" as="xs:string+"/>
    <xsl:variable name="day" select="number(substring($date, 7, 2))" as="xs:double"/>
    <xsl:variable name="month" select="els:verbalizeMonthFromNum(substring($date, 5, 2), $months.verbalized)" as="xs:string"/>
    <xsl:variable name="year" select="number(substring($date, 1, 4))" as="xs:double"/>
    <xsl:value-of select="concat($day, ' ', $month, ' ', $year)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Convert a verbalized date with format "DD month YYYY" to the format "DD/MM/AAAA"</xd:p>
      <xd:param name="dateVerbalized">[String] verbalized date "DD Month YYYY"</xd:param>
      <xd:param name="shortMonth">[Boolean] determine if the "month" is in a short format or no (ex: janv. instead of janvier)</xd:param>
    </xd:desc>
    <xd:return>[String]The date with format "DD/MM/YYYY"</xd:return>
  </xd:doc>
  <!--FIXME : fonction format-date() le fait déjà ?-->
  <xsl:function name="els:date-string-to-number-slash" as="xs:string">
    <xsl:param name="dateVerbalized" as="xs:string"/>
    <xsl:param name="shortMonth" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="empty($dateVerbalized) or count(tokenize($dateVerbalized, $els:regAnySpace)) &lt; 3">
        <xsl:text>[ErreurDate]</xsl:text>
        <xsl:message>[ERROR][els:date-string-to-number-slash] Unable to get the date from '<xsl:value-of select="$dateVerbalized"/>'</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="dateVerbalized.token" select="tokenize($dateVerbalized, $els:regAnySpace)" as="xs:string*"/>
        <xsl:variable name="day" select="$dateVerbalized.token[1]" as="xs:string"/>
        <xsl:variable name="month" select="$dateVerbalized.token[2]" as="xs:string"/>
        <xsl:variable name="year" select="$dateVerbalized.token[3]" as="xs:string"/>
        <xsl:variable name="day" as="xs:string">
          <xsl:choose>
            <xsl:when test="$day = '1er'">
              <xsl:value-of select="'01'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="format-number($day cast as xs:integer, '00')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>    
        <xsl:variable name="month" select="format-number(els:getMonthNumFromVerbalizeMonth($month), '00')" as="xs:string"/>
        <xsl:value-of select="string-join(($day, $month, $year), '/')"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:function>
  
  <xd:p>1 arg signature of els:date-string-to-number-slash() - Default $shortMonth = false()</xd:p>
  <xsl:function name="els:date-string-to-number-slash" as="xs:string">
    <xsl:param name="dateVerbalized" as="xs:string"/>
    <xsl:sequence select="els:date-string-to-number-slash($dateVerbalized, false())"/>
  </xsl:function>
  
  <!--===================================================  -->
  <!-- STRINGS -->
  <!--===================================================  -->

  <xd:doc>
    <xd:desc>
      <xd:p>Perform successiv regex replacements on a string</xd:p>
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
    <xsl:choose>
      <xsl:when test="empty($replace-list/els:replace)">
        <xsl:sequence select="$string"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="replace-1" select="$replace-list/els:replace[1]" as="element(els:replace)"/>
        <!--Possible regex flags values: 
              m: multiline mode
              s : dot-all mode
              i : case-insensitive
              x : ignore whitespace within the regex-->
        <xsl:variable name="flags" select="string($replace-1/ancestor-or-self::*[@flags][1]/@flags)" as="xs:string"/>
        <xsl:variable name="string.replaced" select="replace($string, string($replace-1/els:pattern), string($replace-1/els:replacement), $flags)" as="xs:string"/>
        <xsl:variable name="replace-list.new" as="element(els:replace-list)">
          <els:replace-list>
            <xsl:copy-of select="$replace-list/@*"/>
            <xsl:sequence select="subsequence($replace-list/els:replace, 2)"/>
          </els:replace-list>
        </xsl:variable>
        <xsl:sequence select="els:replace-multiple($string.replaced, $replace-list.new)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Fonction qui fait les remplacements en regex récursivement</xd:p>
      <xd:p>
        Principe : 
        Chaque regex va être passé SUCCESSIVEMENT sur le texte avec le type de traitement indiqué
        Attention l'ordre est important.
        Type de traitement :
        - remplace-brut = replace(string, regex)
        - remplace-group = replace('text1(reg1)', text1$1)
        - etc.
        Par exemple Type "remplace-group" signifie: on remplace par le ReplaceText, suivi par le 1er groupe reconnu par la regex;
        analogue pour "group-remplace-group", etc. 
      </xd:p>
    </xd:desc>
    <xd:param name="Text">String à traiter</xd:param>
    <xd:param name="SequenceDeTriplets">
      Un sequence d'éléments Triplets de la forme :
      <Triplet xmlns="http://www.lefebvre-sarrut.eu/ns/els">
        <Type>remplace-brut</Type>
        <RegExp>[ ][ ]+</RegExp>
        <ReplaceText>&#x0020;</ReplaceText>
      </Triplet>
      <!--On préfère tout préfixer avec els: pour éviter tout problème de mélange de namespace (notamment lors de l'applatissement des xsl chaine xml)-->
    </xd:param>
  </xd:doc>
  <xsl:function name="els:reccursivReplace" as="xs:string*">
    <xsl:param name="Text" as="xs:string?"/>
    <xsl:param name="SequenceDeTriplets" as="element(els:Triplet)*"/>
    <xsl:variable name="FirstTriplet" select="$SequenceDeTriplets[1]" as="element(els:Triplet)"/>
    <xsl:variable name="ResteDesTriplets" select="subsequence($SequenceDeTriplets,2)" as="element(els:Triplet)*"/>
    <xsl:message>[WARNING][ELSSIEXDC-13] "els:reccursivReplace" is DEPRECATED, please use the more generic function "els:replace-multiple" instead</xsl:message>
    <xsl:variable name="Type" select="$FirstTriplet/els:Type" as="element(els:Type)"/>
    <xsl:variable name="RegExp" select="$FirstTriplet/els:RegExp" as="element(els:RegExp)"/>
    <xsl:variable name="ReplaceText" select="$FirstTriplet/els:ReplaceText" as="element(els:ReplaceText)"/>
    <xsl:variable name="Result" as="xs:string*">
      <xsl:choose>
        <xsl:when test="$Type = 'remplace-brut'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:value-of select="$ReplaceText"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'remplace-group-space'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:value-of select="$ReplaceText"/>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:text> </xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'remplace-group'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:value-of select="$ReplaceText"/>
              <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'group'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'space-group-remplace'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:text> </xsl:text>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="$ReplaceText"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'group-remplace'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="$ReplaceText"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'group-remplace-group'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="$ReplaceText"/>
              <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$Type = 'remplace-group-remplace-group'">
          <xsl:analyze-string regex="{$RegExp}" select="$Text">
            <xsl:matching-substring>
              <xsl:text> </xsl:text>
              <xsl:value-of select="regex-group(1)"/>
              <xsl:value-of select="$ReplaceText"/>
              <xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="if (empty($ResteDesTriplets)) then $Result else els:reccursivReplace($Result, $ResteDesTriplets)"/>
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
    <xsl:param name="s" as="xs:string"/>
    <xsl:sequence select="matches($s, concat('^', $els:regAnySpace, '$'))"/>
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
  
  <!--===================================================  -->
  <!--                    XML                              -->
  <!--===================================================  -->
  
  <xd:doc>Get the full XML path of any node in an XML with position predicates([n])
    cf. http://www.xsltfunctions.com/xsl/functx_path-to-node-with-pos.html
  </xd:doc>
  <xsl:template match="*" name="els:get-xpath" mode="get-xpath">
    <xsl:param name="node" select="." as="node()"/>
    <xsl:param name="nsprefix" select="''" as="xs:string"/>
    <xsl:param name="display_position" select="true()" as="xs:boolean"/>
    <xsl:variable name="result" as="xs:string*">
      <xsl:for-each select="$node/ancestor-or-self::*">
        <xsl:variable name="id" select="generate-id(.)" as="xs:string"/>
        <xsl:variable name="name" select="name()" as="xs:string"/>
        <xsl:choose>
          <xsl:when test="not(contains($name,':'))">
            <xsl:value-of select="concat('/',if ($nsprefix!='') then (concat($nsprefix,':')) else(''), $name)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('/', $name)"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="../*[name() = $name]">
          <xsl:if test="generate-id(.)=$id and $display_position">
            <!--FIXME : add position() != 1 to get rid of unusfull "[1]" predicates-->
            <xsl:text>[</xsl:text>
            <xsl:value-of select="format-number(position(),'0')"/>
            <xsl:text>]</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:if test="not($node/self::*)">
        <xsl:value-of select="concat('/@',name($node))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="string-join($result, '')"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>els:get-xpath return full XML path of the current node</xd:p>
      <xd:p>If saxon:path() is available then it will be used, else we will use the template "els:get-xpath"</xd:p>
    </xd:desc>
    <xd:param name="node">[Node] Node we wan the XML path</xd:param>
    <xd:return>XML path of $node</xd:return>
  </xd:doc>
  <xsl:function name="els:get-xpath" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:choose>
      <xsl:when test="function-available('saxon:path')">
        <xsl:value-of select="saxon:path($node)" use-when="function-available('saxon:path')"/>
        <!--To avoid a saxon warning at compilation time, we plan the case (impossible in this when) of the "inverse" use-when 
        (If not, Saxon will warng of a condition brnanch that could return an empty seq instead of a string-->
        <xsl:value-of select="'This will never happen here'" use-when="not(function-available('saxon:path'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="xpath" as="xs:string">
          <xsl:call-template name="els:get-xpath">
            <xsl:with-param name="node" select="$node" as="node()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$xpath"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>els:get-xpath with more arguments (call for template els:get-xpath instead of saxon:path)</xd:p>
    </xd:desc>
    <xd:param name="node">[Node] node to get the XML path</xd:param>
    <xd:param name="nsprefix">Adding a prefixe on each path item</xd:param>
    <xd:param name="display_position">Diplay position predicate for each item of the path</xd:param>
    <xd:return>XML path of the $node formated as indicated with $nsprefix and $display_position</xd:return>
  </xd:doc>
  <xsl:function name="els:get-xpath" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="nsprefix" as="xs:string"/>
    <xsl:param name="display_position" as="xs:boolean"/>
    <xsl:variable name="xpath" as="xs:string">
      <xsl:call-template name="els:get-xpath">
        <xsl:with-param name="node" select="$node" as="node()"/>
        <xsl:with-param name="nsprefix" select="$nsprefix" as="xs:string"/>
        <xsl:with-param name="display_position" select="$display_position" as="xs:boolean"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="string-join(tokenize($xpath,'/'),'/')"/>
  </xsl:function>

  <!--============================-->
  <!--PSEUDO ATTRIBUTES-->
  <!--============================-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Generate xml attribute from a string pseudo attributes</xd:p>
    </xd:desc>
    <xd:param name="str">Any string with pseudo attributes</xd:param>
    <xd:param name="attQuot">Quot used in the pattern to recongnize attributes</xd:param>
    <xd:return>A list of xml attribute, one for each recognized pseudo attribute</xd:return>
  </xd:doc>
  <xsl:function name="els:pseudoAttributes2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:if test="normalize-space($str) != ''">
      <xsl:analyze-string select="$str" regex="([^\s]*)={$attQuot}(.*?){$attQuot}">
        <xsl:matching-substring>
          <xsl:attribute name="{regex-group(1)}" select="regex-group(2)"/>
        </xsl:matching-substring>
      </xsl:analyze-string>
      <!--FIXME : faut-il dissocier le 1er attribut (sans espace devant) des autres ?
      <xsl:analyze-string select="$str" regex="^{$attName}={$attQuot}(.*?){$attQuot}">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(1)"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:analyze-string select="." regex="\s+{$attName}={$attQuot}(.*?){$attQuot}">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:non-matching-substring>
      </xsl:analyze-string>-->
    </xsl:if>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:pseudoAttributes2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="els:pseudoAttributes2xml($str, $els:dquot)"/>
  </xsl:function>
  
  <!--The same function but for only one attribute name.
  It can return more than one xml attribute in case the string has multiple occurence of the same pseudo attribute-->
  <xsl:function name="els:pseudoAttribute2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:sequence select="els:pseudoAttributes2xml($str, $attQuot)[name(.) = $attName]"/>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:pseudoAttribute2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="els:pseudoAttribute2xml($str, $attName, $els:dquot)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Get a pseudo attribute value within a string, typicaly a processing-instruction string</xd:p>
      <xd:p>Exemple : els:getPseudoAttributeValue('&lt;?xml version= "1.0" encoding="UTF-8"?>','encoding')='utf-8'</xd:p>
    </xd:desc>
    <xd:param name="str">Any string with pseudo attributes</xd:param>
    <xd:param name="attName">Name of the attribute</xd:param>
    <xd:param name="attQuot">Quot type used in the pseudo attribute (" or ')</xd:param>
    <xd:return>Value of the attribute. 
      If there are multiple attribute with the same name in the string, the it will return several strings of values</xd:return>
  </xd:doc>
  <!--FIXME : il existe une fonction saxon qui fait ça (saxon:getPseudoAttribute)-->
  <xsl:function name="els:getPseudoAttributeValue" as="xs:string*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:for-each select="els:pseudoAttribute2xml($str, $attName, $attQuot)">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:getPseudoAttributeValue" as="xs:string*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="els:getPseudoAttributeValue($str, $attName, $els:dquot)"/>
  </xsl:function>
  
  <!-- Renvoie true/false si une PI contient un attribut donné -->
  <xsl:function name="els:hasPseudoAttribute" as="xs:boolean">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:sequence select="count(els:pseudoAttribute2xml($str, $attName, $attQuot)) != 0"/>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:hasPseudoAttribute" as="xs:boolean">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="els:hasPseudoAttribute($str, $attName, $els:dquot)"/>
  </xsl:function>
  
  <!--==================-->
  <!--OTHERS XML -->
  <!--==================-->
  
  <xd:doc>Check if a node has a specific ancestor</xd:doc>
  <xsl:function name="els:hasAncestor" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="ancestor" as="element()"/>
    <xsl:sequence select="some $anc in $node/ancestor::* satisfies ($anc is $ancestor)"/>  
  </xsl:function>
  
  <xd:doc>Check if the element has a specific style</xd:doc>
  <xsl:function name="els:hasStyle" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="style" as="xs:string"/>
    <xsl:sequence select="tokenize(normalize-space($e/@style), ';') = normalize-space($style)"/>
  </xsl:function>
  
  <xd:doc>Check if the element has a specific class (several class values might be tested at once)</xd:doc>
  <xsl:function name="els:hasClass" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class" as="xs:string*"/>
    <xsl:sequence select="tokenize($e/@class, '\s+') = $class"/>
  </xsl:function>
  
  <xd:doc>Check if one of the class value of an element matches a specific regex (several class regex might be tested at once)</xd:doc>
  <xsl:function name="els:hasClassMatchingRegex" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class.regex" as="xs:string*"/>
    <xsl:variable name="class.regex.delimited" select="concat('^', $class.regex, '$')" as="xs:string"/>
    <xsl:sequence select="some $class in tokenize($e/@class, '\s+') satisfies matches($class, $class.regex.delimited)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Add a value in class attribute if this value is not already present</xd:p>
      <xd:p>Example of use:
        &lt;xsl:copy>
          &lt;xsl:copy-of select="@*"/> <!--"except @class" is not necessary here it will be overrided-->
          &lt;xsl:attribute name="class" select="els:addClass(., 'myClass')"/>
          &lt;xsl:apply-templates/>
        &lt;/xsl:copy></xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:addClass" as="attribute(class)">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class" as="xs:string"/>
    <xsl:choose>
      <!--If the element has already a class value we want to add, do nothing, keep the attribut as is-->
      <xsl:when test="els:hasClass($e, $class)">
        <xsl:attribute name="class" select="$e/@class"/>
      </xsl:when>
      <!--Else: make a new class attribute with the original class value and the new class added-->
      <xsl:otherwise>
        <xsl:attribute name="class" select="normalize-space(concat($e/@class, ' ', $class))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Delete one class value in a class attribute of the element</xd:p>
    </xd:desc>
    <xd:param name="e">[Element] the element</xd:param>
    <xd:param name="classToRemove">[String] The class value to be removed</xd:param>
    <xd:return>[Attribute]The same class attribute with one removed value</xd:return>
  </xd:doc>
  <xsl:function name="els:removeOneClass" as="attribute(class)?">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="classToRemove" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:hasClass($e, $classToRemove)">
        <xsl:attribute name="class" select="string-join(tokenize($e/@class, '\s+')[. != $classToRemove], ' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$e/@class"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:desc>Copy an element and its attributes and "continue" the job in the current mode</xd:desc>
  <xsl:template name="els:copyAndContinue">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>Generic copy template</xd:doc>
  <xsl:template match="node() | @*" mode="els:copy">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Display any node (element, attribute, text, pi, etc.) as a readable string</xd:p>
    </xd:desc>
    <xd:param name="node">The node to be displayed</xd:param>
    <xd:return>A textual representation of <xd:ref name="$node" type="parameter">$node</xd:ref></xd:return>
  </xd:doc>
  <xsl:function name="els:displayNode" as="xs:string">
    <xsl:param name="node" as="item()"/>
    <xsl:variable name="tmp" as="xs:string*">
      <xsl:choose>
        <xsl:when test="empty($node)">empty_sequence</xsl:when>
        <xsl:when test="$node/self::*">
          <xsl:text>element():</xsl:text>
          <xsl:value-of select="name($node)"/>
          <xsl:if test="$node/@*">
            <xsl:text>_</xsl:text>
          </xsl:if>
          <xsl:for-each select="$node/@*">
            <xsl:sort/>
            <xsl:value-of select="concat('@',name(),'=',$els:dquot,.,$els:dquot,if (position()!=last()) then ('_') else (''))"/>
          </xsl:for-each>
        </xsl:when>
        <!--FIXME : ce test ne marche pas... ?-->
        <xsl:when test="$node/self::text()">
          <xsl:text>text() </xsl:text>
          <xsl:value-of select="substring($node,1,30)"/>
        </xsl:when>
        <xsl:when test="$node/self::comment()">
          <xsl:text>comment() </xsl:text>
          <xsl:value-of select="substring($node,1,30)"/>
        </xsl:when>
        <xsl:when test="$node/self::processing-instruction()">
          <xsl:text>processing-instruction() </xsl:text>
          <xsl:value-of select="substring($node,1,30)"/>
        </xsl:when>
        <xsl:when test="$node/self::document-node()">
          <xsl:text>document-node() </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>unrecognized node type</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="string-join($tmp,'')"/>
  </xsl:function>

  <!-- Application de la fonction saxon:evaluate à un contexte donné, retourne la séquence de noeuds correspondants -->
  <!-- SSI saxon:eval est disponible -->
  <!--Cette écriture est pratique pour certains prédicats où les 2 paramètres sont indépendants-->
  <xd:doc>
    <xd:desc>
      <xd:p>Apply saxon:eval to a given context</xd:p>
    </xd:desc>
    <xd:param name="xpath">[String] xpath to be evaluated</xd:param>
    <xd:param name="e">[Element] Context element</xd:param>
    <xd:return>[item*] result of the evaluation</xd:return>
  </xd:doc>
  <xsl:function name="els:evaluate-xpath" as="item()*">
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:param name="e" as="element()"/>
    <!--<xsl:sequence use-when="function-available('saxon:evaluate')" select="$e/saxon:evaluate($xpath)"/>-->
    <xsl:sequence use-when="function-available('saxon:eval') and function-available('saxon:expression')" 
      select="$e/saxon:eval(saxon:expression($xpath, $e))"/>
    <!--The 2nd argument of saxon:expression permit to define the default namespace-->
    <xsl:message use-when="not(function-available('saxon:eval')) or not(function-available('saxon:expression'))"
      terminate="yes"
      >[FATAL][els-common.xsl] function els:evaluate-xpath() has crashed because saxon:eval (saxon:expression) in not available.
      You must be using SAXON EE or PE to run this function</xsl:message>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Template to do the same thing as saxon:serialize(node, xsl:output/@name) but:
        - can take several nodes (usefull for mixed content)
        - no serialization options, unlike xsl:output</xd:p>
    </xd:desc>
    <xd:param name="nodes">[Nodes] any nodes (typicaly mixed content)</xd:param>
    <xd:param name="copyNS">Determine if we copy namespace declarations on "roots elements" 
      (i.e. elements from <xd:ref name="nodes" type="parameter">$nodes</xd:ref> which have no parent element)</xd:param>
    <!--<xd:param name="format">Name of an xsl:ouput to get serialization options to apply</xd:param>-->
    <xd:return>The XML as a string</xd:return>
  </xd:doc>
  <xsl:function name="els:serialize" as="xs:string">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="copyNS" as="xs:boolean"/>
    <!--<xsl:param name="outputName" as="xs:string"/>-->
    <xsl:variable name="serialize-xml-as-string" as="xs:string*">
      <xsl:apply-templates select="$nodes" mode="els:serialize">
        <!--<xsl:with-param name="outputName" select="$outputName" tunnel="yes" as="xs:string"/>-->
        <xsl:with-param name="copyNSOnRootElements" select="$copyNS" tunnel="yes" as="xs:boolean"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:sequence select="string-join($serialize-xml-as-string, '')"/>
  </xsl:function>
  
  <xd:doc>1 argument signature of els:serialize($nodes as node()*, $copyNS as xs:boolean).
    By default : no copy of the namespace declarations on "roots elements"</xd:doc>
    <!--TODO : $copyNS est à false() par défaut pour conserver un comportement ISO de la signature à 1 argument de la fonction 
                -> voir pour passer sa valeur à true() si pas d'impact.-->
  <xsl:function name="els:serialize" as="xs:string">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:sequence select="els:serialize($nodes,false())"/>
  </xsl:function>
  
  <xd:doc>Mode "els:serialize" for elements</xd:doc>
  <!--TODO : $copyNSOnRootElements conservé avec une valeur par défaut pour rétro-compatibilité (au cas où le template serait appelé en dehors de la fonction).-->
  <xsl:template match="*" mode="els:serialize">
    <xsl:param name="copyNSOnRootElements" tunnel="yes" select="false()" as="xs:boolean"/>
    <!--fixme : utilisation de saxon:serialize ? oui mais il faut passer le output et je n'y arrive pas-->
      <!--<xsl:param name="outputName" required="yes" tunnel="yes" as="xs:string"/>
      <xsl:value-of select="saxon:serialize(., $outputName)"/>-->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <!-- Copie des déclarations de NS si $copyNSOnRootElements + l'élément n'a pas de parent -->
      <xsl:if test="$copyNSOnRootElements and not(parent::*)">
        <!-- Can't redefine 'xml' prefix (already implicit) -->
        <xsl:for-each select="namespace::node()[name() != 'xml']">
          <xsl:text> xmlns</xsl:text>
          <xsl:if test="name() != ''">
            <xsl:value-of select="concat(':',name())"/>
          </xsl:if>
          <xsl:text>="</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
        </xsl:for-each>
      </xsl:if>
      <xsl:for-each select="@*">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:choose>
        <!--auto-fermant-->
        <xsl:when test="empty(node())">
          <xsl:text>/&gt;</xsl:text>
        </xsl:when>
        <!--ou pas-->
        <xsl:otherwise>
          <xsl:text>&gt;</xsl:text>
          <xsl:apply-templates mode="#current"/>
          <xsl:text>&lt;/</xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <xd:doc>Mode "els:serialize" for text nodes: spaces are normalized</xd:doc>
  <xsl:template match="text()" mode="els:serialize">
    <xsl:if test="starts-with(.,' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="ends-with(.,' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>Mode "els:serialize" for comments</xd:doc>
  <xsl:template match="comment()" mode="els:serialize">
    <xsl:text>&lt;!-- </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text> --&gt;</xsl:text>
  </xsl:template>
  
  <xd:doc>Mode "els:serialize" for PI</xd:doc>
  <xsl:template match="processing-instruction()" mode="els:serialize">
    <xsl:text>&lt;?</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>?&gt;</xsl:text>
  </xsl:template>
  
  <!--===============================-->
  <!--GROUP and WRAP XML-->
  <!--===============================-->
  
  <xd:doc>3 args signature of els:wrap-elements-adjacent-by-names()</xd:doc>
  <xsl:function name="els:wrap-elements-adjacent-by-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="adjacent.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:sequence select="els:wrap-elements-adjacent-by-names($context, $adjacent.names, $wrapper, true())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap "adjacent by name" elements into a new element "wrapper".</xd:p>
      <xd:p>CAUTION : any text, pi, comment within context will be loose !</xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the adjacents elements to wrap</xd:param>
    <xd:param name="adjacent.names">sequence of qualified names to set adjacent elements</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context shoulb be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped adjacents element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-adjacent-by-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="adjacent.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:sequence select="els:wrap-elements-adjacent(
      $context,
      function($e) as xs:boolean {name($e) = $adjacent.names},
      $wrapper,
      $keep-context)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap adjacent elements into a new element "wrapper".</xd:p>
      <xd:p>CAUTION : any text, pi, comment within context will be loose !</xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the adjacents elements to wrap</xd:param>
    <xd:param name="adjacent.function">An Xpath function to set the adjacence condition</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context shoulb be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped adjacents element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-adjacent" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="adjacent.function"/> <!--as="xs:string"-->
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:variable name="content" as="item()*">
      <xsl:for-each-group select="$context/*" group-adjacent="$adjacent.function(.)">
        <xsl:variable name="cg" select="current-group()" as="element()*"/>
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <xsl:for-each select="$wrapper">
              <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:copy-of select="$cg"/>
              </xsl:copy>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$keep-context">
        <xsl:for-each select="$context">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="$content"/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>3 args signature of els:wrap-elements-adjacent-by-names()</xd:doc>
  <xsl:function name="els:wrap-elements-starting-with-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="starts.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:sequence select="els:wrap-elements-starting-with-names($context, $starts.names, $wrapper, true())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap elements starting with specific names into a new element "wrapper" </xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the adjacents elements to wrap</xd:param>
    <xd:param name="starts.names">sequence of names to set starting elements</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context shoulb be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped adjacents element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-starting-with-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="starts.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:sequence select="els:wrap-elements-starting-with(
      $context,
      function($e as element()) as xs:boolean {name($e) = $starts.names}, 
      $wrapper,
      $keep-context)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap elements starting with specific names into a new element "wrapper" </xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the adjacents elements to wrap</xd:param>
    <xd:param name="starts.function">An Xpath function to set the starting group condition</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context shoulb be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped adjacents element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-starting-with" as="element()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="starts.function"/> <!--as="xs:string"-->
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:variable name="content" as="item()*">
      <xsl:for-each-group select="$context/node()" group-starting-with="*[$starts.function(.)]">
        <xsl:variable name="cg" select="current-group()" as="node()*"/>
        <xsl:for-each select="$wrapper">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="$cg"/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$keep-context">
        <xsl:for-each select="$context">
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:sequence select="$content"/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--===================================================  -->
  <!-- FILES -->
  <!--===================================================  -->

  <xd:doc>
    <xd:desc>
      <xd:p>Return the file name from an abolute or a relativ path</xd:p>
      <xd:p>If <xd:ref name="filePath" type="parameter">$filePath</xd:ref> is empty it will retunr an empty string (not an empty sequence)</xd:p>
    </xd:desc>
    <xd:param name="filePath">[String] path of the file (typically string(base-uri())</xd:param>
    <xd:param name="withExt">[Boolean] with or without extension</xd:param>
    <xd:return>File name (with or without extension)</xd:return>
  </xd:doc>
  <xsl:function name="els:getFileName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="withExt" as="xs:boolean"/>
    <xsl:choose>
      <!-- An empty string would lead an error in the next when (because of a empty regex)-->
      <xsl:when test="normalize-space($filePath) = ''">
        <xsl:value-of select="$filePath"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="fileNameWithExt" select="functx:substring-after-last-match($filePath,'/')" as="xs:string?"/>
        <xsl:variable name="fileNameNoExt" select="functx:substring-before-last-match($fileNameWithExt,'\.')" as="xs:string?"/>
        <!-- If the fileName has no extension (ex. : "foo"), els:getFileExt() will return renvoie the file name... which is not what expected
        <xsl:variable name="ext" select="concat('.',els:getFileExt($fileNameWithExt))" as="xs:string"/>-->
        <!-- This works with no extension files -> $ext is an empty string here-->
        <xsl:variable name="ext" select="functx:substring-after-match($fileNameWithExt,$fileNameNoExt)" as="xs:string?"/>
        <xsl:sequence select="concat('', $fileNameNoExt, if ($withExt) then ($ext) else (''))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>1arg signature of els:getFileName. Default : extension is on</xd:doc>
  <xsl:function name="els:getFileName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:sequence select="els:getFileName($filePath,true())"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Get the extension of a file from it an absolute or relativ path</xd:p>
      <xd:p>If <xd:ref name="filePath" type="parameter">$filePath</xd:ref> is empty, it will return an empty string (not an empty sequence)</xd:p>
    </xd:desc>
    <xd:param name="filePath">[String] path of the file (typically string(base-uri())</xd:param>
    <xd:return>The file extension if it has one</xd:return>
  </xd:doc>
  <xsl:function name="els:getFileExt" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:sequence select="concat('',functx:substring-after-last-match($filePath,'\.'))"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Get the folder path of a file path, level can be specified to have the parg</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:param name="level">Tree level as integer, min = 1 (1 = full path, 2 = full path except last folder, etc.)</xd:param>
    <xd:return>Folder Path as string</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderPath" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:variable name="level.normalized" as="xs:integer" select="if ($level ge 1) then ($level) else (1)"/>
    <xsl:value-of select="string-join(tokenize($filePath,'/')[position() le (last() - $level.normalized)],'/')"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>1 arg Signature of els:getFolderPath(). Default is to get the full folder path to the file (level = 1)</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:return>Full folder path of the file path</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderPath" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:sequence select="els:getFolderPath($filePath,1)"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Get the folder name of a file path</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:param name="level">Tree level as integer, min = 1 (1 = parent folder of the file, 2 = "grand-parent-folderName", etc.)</xd:param>
    <xd:return>The folder name of the nth parent folder of file</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:variable name="level.normalized" as="xs:integer" select="if ($level ge 1) then ($level) else (1)"/>
    <xsl:value-of select="tokenize($filePath,'/')[last() - $level.normalized]"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>1 arg signature of els:getFolderName()</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:return>Name of the parent folder of the file</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:value-of select="els:getFolderName($filePath,1)"/>
  </xsl:function>
  
  <!--=========================-->
  <!--RelativeURI-->
  <!--=========================-->
  <!--Adapted from https://github.com/cmarchand/xsl-doc/blob/master/src/main/xsl/lib/common.xsl-->
  <!--FIXME : should parameters be cast as xs:anyUri ??-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the relative path from a source folder to a target file.</xd:p>
      <xd:p>Both source.folder and target.file must be absolute URI</xd:p>
      <xd:p>If there is no way to walk a relative path from the source folder to the target file, then absolute target file URI is returned</xd:p>
    </xd:desc>
    <xd:param name="source.folder">The source folder URI</xd:param>
    <xd:param name="target.file">The target file URI</xd:param>
    <xd:return>The relative path to walk from source.folder to target.file</xd:return>
  </xd:doc>
  <xsl:function name="els:getRelativePath" as="xs:string">
    <xsl:param name="source.folder" as="xs:string"/>
    <xsl:param name="target.file" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="normalize-space($source.folder) eq ''">
        <xsl:message>[ERROR][els:getRelativePath] $source.folder must not be an empty string</xsl:message>
        <xsl:sequence select="($target.file, '')[1]"/>
      </xsl:when>
      <xsl:when test="normalize-space($target.file) eq ''">
        <xsl:message>[ERROR][els:getRelativePath] $target.file must not be an empty string</xsl:message>
        <xsl:sequence select="($target.file, '')[1]"/>
      </xsl:when>
      <xsl:when test="els:isAbsoluteUri($source.folder)">
        <xsl:choose>
          <xsl:when test="not(els:isAbsoluteUri($target.file))"><xsl:sequence select="string-join((tokenize($source.folder,'/'),tokenize($target.file,'/')),'/')"/></xsl:when>
          <xsl:otherwise>
            <!-- If protocols are differents : return $target -->
            <xsl:variable name="protocol" select="els:getUriProtocol($source.folder)" as="xs:string"/>
            <xsl:choose>
              <xsl:when test="$protocol eq els:getUriProtocol($target.file)">
                <!-- How many identical items are there at the beginning of each uri ?-->
                <xsl:variable name="sourceSeq" select="tokenize(substring(els:normalizeFilePath($source.folder),string-length($protocol) +1),'/')" as="xs:string*"/>
                <xsl:variable name="targetSeq" select="tokenize(substring(els:normalizeFilePath($target.file),string-length($protocol) +1),'/')" as="xs:string*"/>
                <xsl:variable name="nbCommonElements" as="xs:integer" select="els:getNbEqualsItems($sourceSeq, $targetSeq)"/>
                <xsl:variable name="goUpLevels" as="xs:integer" select="count($sourceSeq) - $nbCommonElements"/>
                <xsl:variable name="goUp" as="xs:string*" select="(for $i in (1 to $goUpLevels) return '..')" />
                <xsl:sequence select="string-join(($goUp, subsequence($targetSeq, $nbCommonElements+1)),'/')"></xsl:sequence>
              </xsl:when>
              <xsl:otherwise><xsl:sequence select="$target.file"/></xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="absoluteSource" as="xs:string" select="xs:string(resolve-uri($source.folder))"/>
        <xsl:choose>
          <xsl:when test="els:isAbsoluteUri($absoluteSource)">
            <xsl:sequence select="els:getRelativePath($absoluteSource, $target.file)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>[ERROR][els:getRelativePath] $source.folder="<xsl:value-of select="$source.folder"/>" can not be resolved as an absolute URI</xsl:message>
            <xsl:sequence select="($target.file, '')[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Normalize the URI path. I.E. removes any /./ and folder/.. moves</xd:desc>
    <xd:param name="path">The path to normalize</xd:param>
    <xd:return>The normalized path, as a <tt>xs:string</tt></xd:return>
  </xd:doc>
  <xsl:function name="els:normalizeFilePath" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:sequence select="els:removeLeadingDotSlash(els:removeSingleDot(els:removeDoubleDot($path)))"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Removes single dot in path URI. . are always a self reference, so ./ can always be removed safely</xd:desc>
    <xd:param name="path">The path to remove single dots from</xd:param>
    <xd:return>The clean path, as xs:string</xd:return>
  </xd:doc>
  <xsl:function name="els:removeSingleDot" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="temp" select="replace($path, '/\./','/')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="matches($temp, '/\./')">
        <xsl:sequence select="els:removeSingleDot($temp)"/>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$temp"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Removes the leading "./" from the path</xd:desc>
    <xd:param name="path">The path to clean</xd:param>
    <xd:return>The clean path</xd:return>
  </xd:doc>
  <xsl:function name="els:removeLeadingDotSlash" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="temp" select="replace($path, '^\./','')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="starts-with($temp, './')">
        <xsl:sequence select="els:removeLeadingDotSlash($temp)"/>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$temp"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Removes .. in an URI when it is preceded by a folder reference. So, removes /xxxx/.. </xd:desc>
    <xd:param name="path">The path to clean</xd:param>
    <xd:return>The clean path</xd:return>
  </xd:doc>
  <xsl:function name="els:removeDoubleDot" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="temp" as="xs:string" select="replace($path,'/[^./]*/\.\./','/')"/>
    <xsl:choose>
      <xsl:when test="matches($temp,'/[^./]*/\.\./')">
        <xsl:sequence select="els:removeDoubleDot($temp)"></xsl:sequence>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$temp"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Returns true if the provided URI is absolute, false otherwise</xd:desc>
    <xd:param name="path">The URI to test</xd:param>
    <xd:return><tt>true</tt> if the URI is absolute</xd:return>
  </xd:doc>
  <xsl:function name="els:isAbsoluteUri" as="xs:boolean">
    <xsl:param name="path" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$path eq ''">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="matches($path,'[a-zA-Z0-9]+:.*')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Returns the protocol of an URI</xd:desc>
    <xd:param name="path">The URI to check</xd:param>
    <xd:return>The protocol of the URI</xd:return>
  </xd:doc>
  <xsl:function name="els:getUriProtocol" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="protocol" select="substring-before($path,':')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="string-length($protocol) gt 0"><xsl:sequence select="$protocol"/></xsl:when>
      <xsl:otherwise><xsl:message>[ERROR][els:protocol] $path="<xsl:value-of select="$path"/>" must be an absolute URI</xsl:message></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Compare pair to pair seq1 and seq2 items, and returns the numbers of deeply-equals items</xd:desc>
    <xd:param name="seq1">The first sequence</xd:param>
    <xd:param name="seq2">The second sequence</xd:param>
  </xd:doc>
  <xsl:function name="els:getNbEqualsItems" as="xs:integer">
    <xsl:param name="seq1" as="item()*"/>
    <xsl:param name="seq2" as="item()*"/>
    <xsl:choose>
      <xsl:when test="deep-equal($seq1[1],$seq2[1])">
        <xsl:sequence select="els:getNbEqualsItems(els:tail($seq1), els:tail($seq2))+1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--FIXME : utiliser la fonction tail native en xpath3.0 (https://www.w3.org/TR/xpath-functions-30/#func-tail)-->
  <xsl:function name="els:tail" as="item()*">
    <xsl:param name="seq" as="item()*"/>
    <xsl:sequence select="subsequence($seq, 2)"/>
  </xsl:function>
  
  <!--****************************************************************************************-->
  <!-- MATH AND NUMBER-->
  <!--****************************************************************************************-->
  
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

  <!-- Conversion d'un item en boolean. -->
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
