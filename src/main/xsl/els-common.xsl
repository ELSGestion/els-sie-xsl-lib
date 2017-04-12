<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:functx="http://www.functx.com" 
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>Librairies de fonctions générique utilisées aux ELS</xd:p>
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
      <xd:p>Variable double quot ou quot simple, peut être utile dans un concat par exemple</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="els:dquot" as="xs:string">"</xsl:variable>
  <xsl:variable name="els:quot" as="xs:string">'</xsl:variable>

  <xd:doc>
    <xd:desc>
      <xd:p>Variable utile "regAnySpace" : espace insécable, fine ou autre</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="els:regAnySpace">\p{Z}</xsl:variable>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Variable utile "regAnyPonctuation" : point, virgule, point virgule ou autre</xd:p>
      <xd:p>(voir http://www.regular-expressions.info/unicode.html)</xd:p>
    </xd:desc>
  </xd:doc>  
  <xsl:variable name="els:regAnyPonctuation">\p{P}</xsl:variable>  
  
  <xd:doc>
    <xd:desc>
      <xd:p>Variable "fin de mot" (équivalent \b en regex)</xd:p>
    </xd:desc>
  </xd:doc>  
  <xsl:variable name="els:regWordBoundery"><xsl:value-of select="$els:regAnySpace"/>|<xsl:value-of select="$els:regAnyPonctuation"/></xsl:variable>  
  
  <xd:doc>
    <xd:desc>
      <xd:p>ESPACES TYPOGRAPHIQUE</xd:p>
    </xd:desc>
  </xd:doc>  
  <!--tous les espaces en tailles décroissante : &#x2000 (taille du M) => &#x200b (espace nulle sécable)-->
  <!--conseil : utilisez l'application "SC UNIPAD" pour visualiser/convertir les espaces-->
  <!--cf. http://theme.unblog.fr/2007/05/18/ponctuation/-->
  <xsl:variable name="els:EN_QUAD" as="xs:string"><!--(1/8 cadratin)-->
    <xsl:text>&#x2000;</xsl:text><!--= " "-->
  </xsl:variable>
  <xsl:variable name="els:NARROW_NO_BREAK_SPACE" as="xs:string">
    <xsl:text>&#x202f;</xsl:text><!--= " "-->
  </xsl:variable>
  <xsl:variable name="els:NO_BREAK_SPACE" as="xs:string">
    <xsl:text>&#x00a0;</xsl:text><!--= " "-->
  </xsl:variable>
  <xsl:variable name="els:ZERO_WIDTH_SPACE" as="xs:string">
    <xsl:text>&#x200b;</xsl:text><!--= "​​"-->
  </xsl:variable>
  <xsl:variable name="els:ZERO_WIDTH_NO_BREAK_SPACE" as="xs:string"><!--(non matché par '\p{Z}')-->
    <xsl:text>&#xfeff;</xsl:text><!--="﻿"-->
  </xsl:variable>
  <xsl:variable name="els:HAIR_SPACE" as="xs:string"><!--("espace ultra fine sécable")-->
    <xsl:text>&#x200A;</xsl:text><!--=" "-->
  </xsl:variable>
  <xsl:variable name="els:PONCTUATION_SPACE" as="xs:string"><!--(1/3 de cadratin ?)-->
    <xsl:text>&#x2008;</xsl:text><!--=" "-->
  </xsl:variable>
  <xsl:variable name="els:THIN_SPACE" as="xs:string"><!--(espaces fine ou quart de cadratin?)-->
    <xsl:text>&#x2009;</xsl:text><!--=" "-->
  </xsl:variable>
  <xsl:variable name="els:EN_SPACE" as="xs:string"><!-- https://www.cs.sfu.ca/~ggbaker/reference/characters/#space -->
    <xsl:text>&#x2002;</xsl:text>
  </xsl:variable>
  
  <!--===================================================  -->
  <!-- DATES -->
  <!--===================================================  -->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Variable mois</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="els:months.fr" select="('janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre')"/>
  <xsl:variable name="els:monthsShort.fr" select="('janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juill.', 'août', 'sept.', 'oct.', 'nov.', 'déc.')" as="xs:string+"/>
  
  <xsl:function name="els:getCurrentIsoDate" as="xs:string">
    <xsl:sequence select="format-dateTime(current-dateTime(),'[Y0001]-[M01]-[D01]')"/>
  </xsl:function>
  
  <!--AAAA-MM-JJ => AAAA-->
  <xsl:function name="els:getYearFromIsoDate" as="xs:string">
    <xsl:param name="isoDate" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:isIsoDate($isoDate)">
        <xsl:value-of select="tokenize($isoDate, '-')[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getYearFromIsoDate] param $isoDate="<xsl:value-of select="$isoDate"/>" n'est pas au forma ISO "AAAA-MM-JJ"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--AAAA-MM-JJ => MM-->
  <xsl:function name="els:getMonthFromIsoDate" as="xs:string">
    <xsl:param name="isoDate" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:isIsoDate($isoDate)">
        <xsl:value-of select="tokenize($isoDate, '-')[2]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getMonthFromIsoDate] param $isoDate="<xsl:value-of select="$isoDate"/>" n'est pas au forma ISO "AAAA-MM-JJ"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--AAAA-MM-JJ => JJ-->
  <xsl:function name="els:getDayFromIsoDate" as="xs:string">
    <xsl:param name="isoDate" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:isIsoDate($isoDate)">
        <xsl:value-of select="tokenize($isoDate, '-')[3]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getDayFromIsoDate] param $isoDate="<xsl:value-of select="$isoDate"/>" n'est pas au forma ISO "AAAA-MM-JJ"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="els:isIsoDate" as="xs:boolean">
    <xsl:param name="dateString" as="xs:string"/>
    <xsl:sequence select="matches($dateString, '^\d\d\d\d-\d\d-\d\d$')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns an ISO date (xs:date) from a string formatted as YYYYMMDD.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:makeIsoDateFromYYYYMMDD" as="xs:string?">
    <xsl:param name="date" as="xs:string"/>
    <xsl:variable name="day" select="substring($date, 7, 2)"/>
    <xsl:variable name="month" select="substring($date, 5, 2)"/>
    <xsl:variable name="year" select="number(substring($date, 1, 4))"/>    
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
  
  <xd:doc>
    <xd:desc>
      <xd:p>verbalisation du mois</xd:p>
    </xd:desc>
    <xd:param name="monthNumber">[String] Le numéro du mois sous la forme XX ou X</xd:param>
    <xd:return>[String] Le nom du mois en français et en minuscule</xd:return>
  </xd:doc>
  <xsl:function name="els:verbalizeMonthFromNum" as="xs:string">
    <xsl:param name="monthNumString" as="xs:string"/>
    <xsl:variable name="monthNumInt" select="if($monthNumString castable as xs:integer) then(xs:integer($monthNumString)) else(0)" as="xs:integer"/>
    <xsl:variable name="result" select="$els:months.fr[$monthNumInt]"/>
    <xsl:choose>
      <xsl:when test="exists($result)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[ErreurMois]</xsl:text>
        <xsl:message>[ERROR][els:verbalizeMonthFromNum] Impossible de déterminer le mois à partir de '<xsl:value-of select="$monthNumString"/>'</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="els:getMonthNumFromVerbalizeMonth" as="xs:integer">
    <xsl:param name="monthString" as="xs:string"/>
    <xsl:variable name="result" select="index-of($els:months.fr, $monthString)"/>
    <xsl:choose>
      <xsl:when test="exists($result)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
        <xsl:message>[ERROR][els:getMonthNumFromVerbalizeMonth] Impossible de déterminer le chiffre du mois à partir de la string '<xsl:value-of select="$monthString"/>'</xsl:message>
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
    
  <xsl:function name="els:date-number-slash">
    <xsl:param name="param" as="xs:string"/>
    <xsl:variable name="jour" select="substring($param, 9, 2)"/>
    <xsl:variable name="mois" select="substring($param, 6, 2)"/>
    <xsl:variable name="annee" select="substring($param, 1, 4)"/>
    <xsl:value-of select="concat($jour, '/',$mois, '/', $annee)"/>
  </xsl:function>
  
  <xsl:function name="els:date-number-dash">
    <xsl:param name="param" as="xs:string"/>
    <xsl:variable name="jour" select="substring($param, 9, 2)"/>
    <xsl:variable name="mois" select="substring($param, 6, 2)"/>
    <xsl:variable name="annee" select="substring($param, 1, 4)"/>
    <xsl:value-of select="concat($jour, '-',$mois, '-', $annee)"/>
  </xsl:function>
  
  <xsl:function name="els:date-string">
    <xsl:param name="param" as="xs:string"/>
    <xsl:variable name="jour" select="number(substring($param, 9, 2))"/>
    <xsl:variable name="mois" select="els:verbalizeMonthFromNum(substring($param, 6, 2))"/>
    <xsl:variable name="annee" select="number(substring($param,1, 4))"/>
    <xsl:value-of select="concat($jour, ' ',$mois, ' ', $annee)"/>
  </xsl:function>
  
  <!-- Traduit en français une date 
        Entrée : YYYYMMD
        sortie DD M YYYY 
      Ex : 19750910 => "10 Septembre 1975" -->
  <xsl:function name="els:displayDate">
    <xsl:param name="param" as="xs:string"/>
    <!-- Récupération du jour -->
    <xsl:variable name="jour" select="number(substring($param, 7, 2))"/>
    <!-- Récupération du mois (en français) -->
    <xsl:variable name="mois" select="els:verbalizeMonthFromNum(substring($param, 5, 2))"/>
    <!-- Récupération de l'année -->
    <xsl:variable name="annee" select="number(substring($param, 1, 4))"/>
    <!-- Confection de la date -->
    <xsl:value-of select="concat($jour, ' ', $mois, ' ', $annee)"/>
  </xsl:function>  
  
  <xd:doc>
    <xd:desc>
      <xd:p>Converti une date sous un format "DD Mois YYYY" en format "DD/MM/AAAA"</xd:p>
      <xd:param name="dateVerbalized">string d'entrée en format : DD Mois YYYY</xd:param>
      <xd:param name="shortMonth">Mois abrégé ou pas</xd:param>
    </xd:desc>
    <xd:return>La date au format : DD/MM/YYYY</xd:return>
  </xd:doc>
  <!-- Ex : 10 septembre 1975 => 10/09/1975
        1er janv. 1975 => 01/01/1975  -->
  <!--FIXME : fonction format-date() le fait déjà ?-->
  <xsl:function name="els:date-string-to-number-slash">
    <xsl:param name="dateVerbalized" as="xs:string"/>
    <xsl:param name="shortMonth" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="empty($dateVerbalized) or count(tokenize($dateVerbalized, $els:regAnySpace)) &lt; 3">
        <xsl:text>[ErreurDate]</xsl:text>
        <xsl:message>[ERROR][els:date-string-to-number-slash] Impossible de déterminer la date à partir de '<xsl:value-of select="$dateVerbalized"/>'</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="dateVerbalized.token" select="tokenize($dateVerbalized, $els:regAnySpace)" as="xs:string*"/>
        <xsl:variable name="day" select="$dateVerbalized.token[1]" as="xs:string"/>
        <xsl:variable name="month" select="$dateVerbalized.token[2]" as="xs:string"/>
        <xsl:variable name="year" select="$dateVerbalized.token[3]" as="xs:string"/>
        <xsl:variable name="day">
          <xsl:choose>
            <xsl:when test="$day = '1er'">
              <xsl:value-of select="'01'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="format-number($day cast as xs:integer, '00')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>    
        <xsl:variable name="month">
          <xsl:value-of select="format-number(els:getMonthNumFromVerbalizeMonth($month), '00')"/>
        </xsl:variable>
        <xsl:value-of select="string-join(($day, $month, $year), '/')"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:function>
  
  <xsl:function name="els:date-string-to-number-slash">
    <xsl:param name="dateVerbalized" as="xs:string"/>
    <xsl:sequence select="els:date-string-to-number-slash($dateVerbalized, false())"/>
  </xsl:function>
  
  <!--===================================================  -->
  <!-- STRINGS -->
  <!--===================================================  -->

  <xd:doc>
    <xd:desc>
      <xd:p>Get a field from an logic id and a key</xd:p>
    </xd:desc>
    <xd:param>logic-id : logic id</xd:param>
    <xd:param>key : key of the search field</xd:param>
  </xd:doc>
  <xsl:function name="els:get-logic-id-value" as="xs:string?">
    <xsl:param name="logic-id" as="xs:string"/>
    <xsl:param name="key" as="xs:string"/>
    <xsl:variable name="chunk" as="xs:string*" select="tokenize($logic-id, '\|')[matches(., concat('^', $key, ':'))]"/>
    <xsl:sequence select="if (count($chunk) &gt;= 1) then tokenize($chunk,':')[2] else ()"/>
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
  <xsl:function name="els:reccursivReplace">
    <xsl:param name="Text"/>
    <xsl:param name="SequenceDeTriplets" as="element(els:Triplet)*"/>
    <xsl:variable name="FirstTriplet" select="$SequenceDeTriplets[1]" as="element(els:Triplet)"/>
    <xsl:variable name="ResteDesTriplets" select="subsequence($SequenceDeTriplets,2)" as="element(els:Triplet)*"/>
    <xsl:variable name="Type" select="$FirstTriplet/els:Type"/>
    <xsl:message use-when="false()">
      <xsl:text>$Type : </xsl:text>
      <xsl:value-of select="$Type"/>
    </xsl:message>
    <xsl:variable name="RegExp" select="$FirstTriplet/els:RegExp"/>
    <xsl:message use-when="false()">
      <xsl:text>$RegExp : </xsl:text>
      <xsl:value-of select="$RegExp"/>
      <xsl:text>    $Text : </xsl:text>
      <xsl:value-of select="$Text"/>
    </xsl:message>
    <xsl:variable name="ReplaceText" select="$FirstTriplet/els:ReplaceText"/>
    <xsl:message use-when="false()">
      <xsl:text>$ReplaceText : </xsl:text>
      <xsl:text>'</xsl:text>
      <xsl:value-of select="$ReplaceText"/>
      <xsl:text>'</xsl:text>
    </xsl:message>
    <xsl:variable name="Result">
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
      <xd:p>Exemple : els:normalize-no-diacritic('éêèàœç')='eeeaœc'</xd:p>
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
      <xd:p>"carriage return line feed" : renvoie N retour charriots</xd:p>
    </xd:desc>
    <xd:param name="n">nombre de retour charriots à renvoyer</xd:param>
  </xd:doc>
  <xsl:function name="els:crlf" as="xs:string*">
    <xsl:param name="n" as="xs:integer"/>
    <!--pas de sens pour les chiffres négatifs-->
    <xsl:if test="$n gt 0">
      <xsl:for-each select="1 to $n">
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Signature 0 args de els:crlf() : renvoie par défaut 1 retour chariot.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:crlf" as="xs:string">
    <xsl:sequence select="els:crlf(1)"/>
  </xsl:function>
  
  <xsl:function name="els:getFirstChar" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <!--<xsl:value-of select="substring($s,1,1)"/>-->
    <xsl:sequence select="els:getFirstChar($s,1)"/>
  </xsl:function>
  
  <xsl:function name="els:getFirstChar" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:param name="n" as="xs:integer"/>
    <xsl:value-of select="substring($s,1,$n)"/>
  </xsl:function>
  
  <xsl:function name="els:getStringButFirstChar" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="substring($s,2)"/>
  </xsl:function>
  
  <xsl:function name="els:capFirst_lowercase" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="concat(upper-case(els:getFirstChar($s)),lower-case(els:getStringButFirstChar($s)))"/>
  </xsl:function>
  
  <xsl:function name="els:capFirst" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:value-of select="concat(upper-case(els:getFirstChar($s)), els:getStringButFirstChar($s))"/>
  </xsl:function>
  
  <!--<xsl:function name="els:substring-before-match" as="xs:string">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="regex" as="xs:string"/>
    <xsl:sequence select="tokenize($arg,$regex)[1]"/>
  </xsl:function>
  
  <xsl:function name="els:substring-after-match" as="xs:string?">
    <xsl:param name="arg" as="xs:string?"/>
    <xsl:param name="regex" as="xs:string"/>
    <xsl:sequence select="replace($arg,concat('^.*?',$regex),'')"/>
  </xsl:function>-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Return the string value of a node, normalizing white-spaces for each descendant text()</xd:p>
      <xd:p>The default separator between 2 text() is an espace, it can be overrided</xd:p>
    </xd:desc>
    <xd:param name="node">Any node (but it makes sens if the node has text() descendants)</xd:param>
    <xd:return>Normalize string value of the node</xd:return>
  </xd:doc>
  <xsl:function name="els:normalized-string" as="xs:string">
    <xsl:param name="node" as="node()?"/>
    <xsl:param name="separator" as="xs:string"/>
    <xsl:sequence select="string-join($node//text()[normalize-space(.)], $separator)"/>
  </xsl:function>
  
  <!--By default the separator isa whitespace character, just like &lt;xsl:value-of--> 
  <xsl:function name="els:normalized-string" as="xs:string">
    <xsl:param name="node" as="node()?"/>
    <xsl:sequence select="els:normalized-string($node, ' ')"/>
  </xsl:function>
  
  <!--=====================-->
  <!-- MODE els:UPPERCASE -->
  <!--=====================-->
  <!--mode pour passer en uppercase (tout en conservant les enrichissements)-->
  
  <xsl:template match="text()" mode="els:uppercase" priority="1">
    <xsl:value-of select="upper-case(.)"/>  
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:uppercase">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--===================================================  -->
  <!--                    XML                              -->
  <!--===================================================  -->
  
  <!--Récupère le chemin Xpath complet du noeud courant dans le fichier XML avec les prédicats de position ([n])-->
  <!--cf. http://www.xsltfunctions.com/xsl/functx_path-to-node-with-pos.html-->
  <xsl:template match="*" name="els:get-xpath" mode="get-xpath">
    <xsl:param name="node" select="." as="node()"/>
    <xsl:param name="nsprefix" select="''"/>
    <xsl:param name="display_position" select="true()"/>
    <xsl:for-each select="$node/ancestor-or-self::*">
      <xsl:variable name="id" select="generate-id(.)"/>
      <xsl:variable name="name" select="name()"/>
      <xsl:choose>
        <xsl:when test="not(contains(name(),':'))">
          <xsl:value-of select="concat('/',if ($nsprefix!='') then (concat($nsprefix,':')) else(''), name())"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('/', name())"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:for-each select="../*[name()=$name]">
        <xsl:if test="generate-id(.)=$id and $display_position">
          <!--ajouter and position() != 1 si on veut virer les [1]-->
          <xsl:text>[</xsl:text>
          <xsl:value-of select="format-number(position(),'0')"/>
          <xsl:text>]</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:if test="not($node/self::*)">
      <xsl:value-of select="concat('/@',name($node))"/>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>fonction els:get-xpath renvoie un chemin xpath du noeud courant</xd:p>
      <xd:p>Si la fonction saxon:path() est disponible alors on l'utilisera nativement. 
        Sinon  ou on utilisera le template els:get-xpath</xd:p>
    </xd:desc>
    <xd:param name="node">noeud dont on veut le xpath</xd:param>
    <xd:return>Chemin xpath de $node</xd:return>
  </xd:doc>
  <xsl:function name="els:get-xpath" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:choose>
      <xsl:when test="function-available('saxon:path')">
        <xsl:value-of select="saxon:path($node)" use-when="function-available('saxon:path')"/>
        <!--Pour éviter un warning à la compilation on prévoit le cas (impossible dans ce when) du use-when inverse 
        (sinon saxon indiquera qu'une des branch de la condition pourrait ne pas renvoyer un string)-->
        <xsl:value-of select="'This will never happen here'" use-when="not(function-available('saxon:path'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="xpath">
          <xsl:call-template name="els:get-xpath">
            <xsl:with-param name="node" select="$node"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$xpath"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>fonction els:get-xpath avec des arguments plus nombreux 
        (on fait alors appele au template els:get-xpath plutôt que la fonction saxon:path)</xd:p>
    </xd:desc>
    <xd:param name="node">noeud dont on veut le xpath</xd:param>
    <xd:param name="nsprefix">ajout d'un prefixe devant les noeud</xd:param>
    <xd:param name="display_position">affiche la position dans le chemin xpath généré</xd:param>
    <xd:return>Chemin xpath de $node formaté comme indiqué par $nsprefix et $display_position</xd:return>
  </xd:doc>
  <xsl:function name="els:get-xpath" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="nsprefix" as="xs:string"/>
    <xsl:param name="display_position" as="xs:boolean"/>
    <xsl:variable name="xpath">
      <xsl:call-template name="els:get-xpath">
        <xsl:with-param name="node" select="$node"/>
        <xsl:with-param name="nsprefix" select="$nsprefix"/>
        <xsl:with-param name="display_position" select="$display_position"/>
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
    <xd:param name="String">Any string with pseudo attributes</xd:param>
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
      <xd:p>Get a pseudo attribute value within a string</xd:p>
      <xd:p>Exemple : els:getPiAtt('&lt;?xml version= "1.0" encoding="UTF-8"?>','encoding')='utf-8'</xd:p>
    </xd:desc>
    <xd:param name="String">Any string with pseudo attributes</xd:param>
    <xd:param name="attName">Name of the attribute</xd:param>
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
  
  <xsl:function name="els:hasAncestor" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="top" as="element()"/>
    <xsl:sequence select="some $anc in $node/ancestor::* satisfies ($anc is $top)"/>  
  </xsl:function>
  
  <xsl:function name="els:hasStyle" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="style" as="xs:string"/>
    <xsl:sequence select="tokenize($e/@style, '\s+') = $style"/>
  </xsl:function>
  
  <xsl:function name="els:hasClass" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class" as="xs:string*"/>
    <xsl:sequence select="tokenize($e/@class, '\s+') = $class"/>
  </xsl:function>
  
  <!--Exemple d'utilisation :
  <xsl:copy>
    <xsl:copy-of select="@*"/> <!-\-"except @class" n'est pas nécessaire en fait, il sera surchargé-\->
    <xsl:attribute name="class" select="els:addClass(., 'monClass')"/>
    <xsl:apply-templates/>
  </xsl:copy>-->
  <xsl:function name="els:addClass" as="attribute(class)">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class" as="xs:string"/>
    <xsl:choose>
      <!--Si l'élément a déjà la class que l'on veut ajouter, on ne fait rien, on renvoi l'attribut tel quel-->
      <xsl:when test="els:hasClass($e, $class)">
        <xsl:attribute name="class" select="$e/@class"/>
      </xsl:when>
      <!--Sinon : que l'attribut @class existe ou pas on renvoi un attribut marqueurs qui concatène la valeur d'origine et le nouveau marqueur-->
      <xsl:otherwise>
        <xsl:attribute name="class" select="normalize-space(concat($e/@class, ' ', $class))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Copie un élément et ses attributs et "continue" le traitement dans le mode courant (ou sans mode si
        absent)</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template name="els:copyAndContinue">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Fonction qui affiche un noeud (élément, attribut ...) sous forme de string lisible</xd:p>
    </xd:desc>
    <xd:param name="node">Le noeud a affiché</xd:param>
    <xd:return>Un représentation textuelle du noeud</xd:return>
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
      <xd:p>Applique (ssi saxon:eval est disponible) de la fonction saxon:evaluate à un contexte donné, retourne la séquence correspondantes</xd:p>
    </xd:desc>
    <xd:param name="xpath">xpath a évaluer</xd:param>
    <xd:param name="e">noeud contexte</xd:param>
  </xd:doc>
  <xsl:function name="els:evaluate-xpath" as="item()*">
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:param name="e" as="element()"/>
    <!--<xsl:sequence use-when="function-available('saxon:evaluate')" select="$e/saxon:evaluate($xpath)"/>-->
    <xsl:sequence use-when="function-available('saxon:eval') and function-available('saxon:expression')" 
      select="$e/saxon:eval(saxon:expression($xpath, $e))"/>
    <!--le 2e argument de saxon:expression permets de définir le namespace par défaut-->
    <xsl:message use-when="not(function-available('saxon:eval')) or not(function-available('saxon:expression'))"
      terminate="yes"
      >[FATAL][els-common.xsl] function els:evaluate-xpath() has crashed because saxon:eval (saxon:expression) in not available.
      You must be using SAXON EE or PE to run this function</xsl:message>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>template permettant de faire la même chose que saxon:serialize(node, xsl:output/@name) mais :
        - sur plusieurs nœuds (pratique pour sérialiser du contenu mixte)
        - par contre pas de choix sur les options de sérialisation tel que le xsl:output le permet</xd:p>
    </xd:desc>
    <xd:param name="nodes">Noeuds XML (typiquement du contenu mixte)</xd:param>
    <xd:param name="outputName">Nom d'un xsl:ouput qui détermine la sérialisation à appliquer</xd:param>
    <xd:return>le xml en string</xd:return>
  </xd:doc>
  <xsl:function name="els:serialize" as="xs:string">
    <xsl:param name="nodes" as="node()*"/>
    <!--<xsl:param name="outputName" as="xs:string"/>-->
    <xsl:variable name="serialize-xml-as-string" as="xs:string*">
      <xsl:apply-templates select="$nodes" mode="els:serialize">
        <!--<xsl:with-param name="outputName" select="$outputName" tunnel="yes" as="xs:string"/>-->
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:sequence select="string-join($serialize-xml-as-string, '')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Serialise du XML en string</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="*" mode="els:serialize">
    <!--fixme : utilisation de saxon:serialize ? oui mais il faut passer le output et je n'y arrive pas-->
      <!--<xsl:param name="outputName" required="yes" tunnel="yes" as="xs:string"/>
      <xsl:value-of select="saxon:serialize(., $outputName)"/>-->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
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
  
  <!--===================================================  -->
  <!-- FILES -->
  <!--===================================================  -->

  <xd:doc>
    <xd:desc>
      <xd:p>Renvoi le nom du fichier à partir de son path absolu ou relatif</xd:p>
      <xd:p>Si filePath est vide, renvoi une string vide (non pas empty sequence)</xd:p>
    </xd:desc>
    <xd:param name="filePath">path du fichier</xd:param>
    <xd:param name="withExt">avec ou sans extension</xd:param>
    <xd:return>Nom du fichier avec ou sans extension</xd:return>
  </xd:doc>
  <xsl:function name="els:getFileName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="withExt" as="xs:boolean"/>
    <!-- -->
    <xsl:variable name="fileNameWithExt" select="functx:substring-after-last-match($filePath,'/')"/>
    <xsl:variable name="fileNameNoExt" select="functx:substring-before-last-match($fileNameWithExt,'\.')"/>
    <xsl:variable name="ext" select="els:getFileExt($fileNameWithExt)"/>
    <xsl:sequence select="concat('', $fileNameNoExt, if ($withExt) then (concat('.',$ext)) else (''))"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Signature 1arg de els:getFileName. Par défaut l'extension du fichier est présente</xd:p>
    </xd:desc>
    <xd:param name="filePath">path du fichier</xd:param>
    <xd:return>Nom du fichier avec extension</xd:return>
  </xd:doc>
  <xsl:function name="els:getFileName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:sequence select="els:getFileName($filePath,true())"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Renvoi l'extension d'un fichier à partir de son path absolu ou relatif</xd:p>
      <xd:p>Si $filePath est vide, renvoi une string vide (non pas empty sequence)</xd:p>
    </xd:desc>
    <xd:param name="filePath">Path du fichier</xd:param>
    <xd:return>Extension du fichier</xd:return>
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

  <!--par défaut donne le nom du dossier parent-->
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
  
  <!--****************************************************************************************-->
  <!-- MATH AND NUMBER-->
  <!--****************************************************************************************-->
  
  <!--conversion roman2numeric adapté de http://users.atw.hu/xsltcookbook2/xsltckbk2-chp-3-sect-3.html-->
  
  <xsl:variable name="els:roman-value">
    <els:roman value="1">I</els:roman>
    <els:roman value="5">V</els:roman>
    <els:roman value="10">X</els:roman>
    <els:roman value="50">L</els:roman>
    <els:roman value="100">C</els:roman>
    <els:roman value="500">D</els:roman>
    <els:roman value="1000">M</els:roman>
  </xsl:variable>
  
  <xsl:template name="els:roman-to-number-impl">
    <xsl:param name="roman"/>
    <xsl:param name="value" select="0"/>
    <xsl:variable name="len" select="string-length($roman)"/>
    <xsl:choose>
      <xsl:when test="not($len)">
        <xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:when test="$len = 1">
        <xsl:value-of select="$value + $els:roman-value/*[. = $roman]/@value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="roman-num" select="$els:roman-value/*[. = substring($roman, 1, 1)]"/>
        <xsl:choose>
          <xsl:when test="$roman-num/following-sibling::els:roman = substring($roman, 2, 1)">
            <xsl:call-template name="els:roman-to-number-impl">
              <xsl:with-param name="roman" select="substring($roman,2,$len - 1)"/>
              <xsl:with-param name="value" select="$value - $roman-num/@value"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="els:roman-to-number-impl">
              <xsl:with-param name="roman" select="substring($roman,2,$len - 1)"/>
              <xsl:with-param name="value" select="$value + $roman-num/@value"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="els:roman2numeric" as="xs:string">
    <xsl:param name="roman" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="translate($roman,string-join($els:roman-value/*/text(),''),'')">
        <xsl:text>NaN</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="els:roman-to-number-impl">
          <xsl:with-param name="roman" select="$roman"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
    <!--debug test : 
    <xsl:for-each select="('I','II','III','IV','V','VI','VII','VIII','IX','X','XI','XII','XIII','XIV','XV','XVI','XVII','XVIII','XIX','XX')">
      <xsl:call-template name="lf"/>
      <xsl:value-of select="."/><xsl:text>=</xsl:text><xsl:value-of select="els:roman2numeric(.)"/>
    </xsl:for-each>-->
  </xsl:function>
  
  <xsl:function name="els:litteral2numeric" as="xs:integer">
    <xsl:param name="lit" as="xs:string"/>
    <xsl:value-of select="index-of(('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'), upper-case($lit))"/>
  </xsl:function>
  
  <xsl:function name="els:isNumber" as="xs:boolean">
    <xsl:param name="s"/>
    <xsl:value-of select="number($s)=number($s)"/>
    <!--cf. http://www.xsltfunctions.com/xsl/functx_is-a-number.html-->
  </xsl:function>
  
  <xsl:function name="els:isInteger" as="xs:boolean">
    <xsl:param name="s"/>
    <xsl:value-of select="$s castable as xs:integer"/>
  </xsl:function>
  
  <xsl:function name="els:round" as="xs:integer">
    <xsl:param name="number" as="xs:double"/>
    <xsl:value-of select="els:round($number,0) cast as xs:integer"/>
  </xsl:function>
  
  <xsl:function name="els:round" as="xs:double">
    <xsl:param name="number" as="xs:double"/>
    <xsl:param name="precision" as="xs:integer"/>
    <xsl:variable name="multiple" select="number(concat('10E',string($precision - 1))) cast as xs:integer" as="xs:integer"/> <!--for $i to $precision return 10-->
    <xsl:value-of select="round($number*$multiple) div $multiple"/>
    <!--cf. http://www.xsltfunctions.com/xsl/fn_round.html mais pas de précision-->
    <!--FIXME voir fonction native round-half-to-even($arg,$precision) ??
    ça fait exactement la même chose... http://www.liafa.jussieu.fr/~carton/Enseignement/XML/Cours/XPath/index.html
    -->
  </xsl:function>
  
  <!-- Nombre hexa -> décimal -->
  <xsl:function name="els:hexToDec">
    <xsl:param name="str"/>
    <xsl:if test="$str != ''">
      <xsl:variable name="len" select="string-length($str)"/>
      <xsl:value-of select="
        if ( $len &lt; 2 ) then
        string-length(substring-before('0 1 2 3 4 5 6 7 8 9 AaBbCcDdEeFf',$str)) idiv 2
        else
        els:hexToDec(substring($str,1,$len - 1))*16+els:hexToDec(substring($str,$len))
        "/>
    </xsl:if>
  </xsl:function>
  
  <!-- Nombre décimal -> hexadécimal -->
  <xsl:function name="els:decToHex">
    <xsl:param name="in"/>
    <xsl:sequence
      select="if ($in eq 0)
      then '0'
      else
      concat(if ($in gt 16)
      then els:decToHex($in idiv 16)
      else '',
      substring('0123456789ABCDEF',
      ($in mod 16) + 1, 1))"/>
  </xsl:function>
  
</xsl:stylesheet>
