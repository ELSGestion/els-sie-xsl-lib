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
      <xd:p>ELS-COMMON lib : module "DATES" utilities</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:param name="debug" as="xs:boolean" select="false()"/>
  <xsl:variable name="debugHeader" as="xs:string" select="concat('[debug ',tokenize(static-base-uri(),'/')[last()],']')"/>

  <xsl:import href="els-common_constants.xsl"/>

  <xd:doc>Variables for giving Month in any language</xd:doc>
  <xsl:variable name="els:months.fr" select="('janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre')" as="xs:string+"/>
  <xsl:variable name="els:monthsShort.fr" select="('janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juill.', 'août', 'sept.', 'oct.', 'nov.', 'déc.')" as="xs:string+"/>
  
  <xd:doc>Get the current date as string in ISO format YYYY-MM-DD</xd:doc>
  <xsl:function name="els:getCurrentIsoDate" as="xs:string">
    <xsl:sequence select="format-dateTime(current-dateTime(),'[Y0001]-[M01]-[D01]')"/>
  </xsl:function>
  
  <xd:doc>Get the year as string from any ISO date : YYYY-MM-DD would get "YYYY"</xd:doc>
  <xsl:function name="els:getYearFromIsoDate" as="xs:string?">
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
  <xsl:function name="els:getMonthFromIsoDate" as="xs:string?">
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
  <xsl:function name="els:getDayFromIsoDate" as="xs:string?">
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
  <xsl:function name="els:verbalizeMonthFromNum" as="xs:string?">
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
  <xsl:function name="els:verbalizeMonthFromNum" as="xs:string?">
    <xsl:param name="monthNumString" as="xs:string"/>
    <xsl:param name="months.verbalized" as="xs:string+"/>
    <xsl:variable name="monthNumInt" select="if($monthNumString castable as xs:integer) then(xs:integer($monthNumString)) else(0)" as="xs:integer"/>
    <xsl:variable name="result" select="$months.verbalized[$monthNumInt]" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="exists($result)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:verbalizeMonthFromNum] Unable to get the month string from month number '<xsl:value-of select="$monthNumString"/>'</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>1 arg signature of els:getMonthNumFromVerbalizeMonth : default language is "french"</xd:doc>
  <xsl:function name="els:getMonthNumFromVerbalizeMonth" as="xs:integer?">
    <xsl:param name="monthString" as="xs:string"/>
    <xsl:sequence select="els:getMonthNumFromVerbalizeMonth($monthString, $els:months.fr)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Get the month num as integer from its verbalization</xd:p>
    </xd:desc>
    <xd:param name="monthString">[String] The month string (ex : "january", "février", etc.)</xd:param>
    <xd:param name="months.verbalized">[String+] All months as regex strings verbalized in the good language</xd:param>
    <xd:return>[String] The verbalized month</xd:return>
  </xd:doc>
  <xsl:function name="els:getMonthNumFromVerbalizeMonth" as="xs:integer?">
    <xsl:param name="monthString" as="xs:string"/>
    <xsl:param name="months.verbalized" as="xs:string+"/>
    <xsl:variable name="result" select="$months.verbalized[matches($monthString, ., 'i')]!index-of($months.verbalized, .)" as="xs:integer*"/>
    <!--<xsl:variable name="result" select="index-of($months.verbalized, $monthString)" as="xs:integer*"/>-->
    <xsl:choose>
      <xsl:when test="count($result) = 1">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getMonthNumFromVerbalizeMonth] Unable to get an integer representation of the month from the string '<xsl:value-of select="$monthString"/>' : <xsl:value-of select="count($result)"/> match.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    
  <xd:doc>
    <xd:desc>
      <xd:p>Convert a string with format "JJ/MM/AAAA" (or "JJ-MM-AAAA" or "JJ/MM/AA") to a string representing an ISO date format "AAAA-MM-JJ"</xd:p>
      <xd:param name="s">String to convert as iso date string</xd:param>
      <xd:param name="sep">string representing the separator "/" (or something else) within the original string ($s)</xd:param>
    </xd:desc>
    <xd:return>Iso date of $s as a xs:string (if the conversion fails, it will return the original $s string)</xd:return>
  </xd:doc>
  <xsl:function name="els:makeIsoDate" as="xs:string">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:param name="sep" as="xs:string"/>
    <xsl:variable name="sToken" select="tokenize($s, $sep)" as="xs:string*"/>
    <xsl:variable name="regJJMMAAAA" as="xs:string" select="concat('^\d\d', $sep, '\d\d', $sep, '\d\d\d\d$')"/>
    <xsl:variable name="regJJMMAA" as="xs:string" select="concat('^\d?\d', $sep, '\d?\d', $sep, '\d\d')"/>
    <xsl:variable name="regJMAAAA" as="xs:string" select="concat('^\d?\d', $sep, '\d?\d', $sep, '\d\d\d\d$')"/>
   
    
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
        <xsl:if test="$debug">
          <xsl:message>debug when $regJJMMAAAA</xsl:message>
        </xsl:if>
        <xsl:value-of select="concat($sToken[3], '-', $sToken[2], '-', $sToken[1])"/>
      </xsl:when>
      <!--the day or month is one digit-->
      <xsl:when test="matches($s,$regJMAAAA)">
        <xsl:if test="$debug">
          <xsl:message><xsl:value-of select="$debugHeader"></xsl:value-of> els:makeIsoDate()</xsl:message>
          <xsl:message>when $regJMAAAA</xsl:message>
        </xsl:if>
        <xsl:variable name="month" as="xs:string">
          <xsl:choose>
            <xsl:when test="string-length($sToken[2]) = 1">
              <xsl:value-of select="concat('0',$sToken[2])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sToken[2]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="day" as="xs:string">
          <xsl:choose>
            <xsl:when test="string-length($sToken[1]) = 1">
              <xsl:value-of select="concat('0',$sToken[1])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sToken[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($sToken[3],'-',$month,'-',$day )"/>
      </xsl:when>
      <!--The string $s format day and month are on one digit and the year is on 2 digit "J/M/AA" : convert it to "AAAA-MM-JJ" (trying to guess the century)-->
      <!--ASSUME : if AA is later than current AA, we consider AA was in the last century-->
      <xsl:when test="matches($s, $regJJMMAA)">
        <xsl:if test="$debug">
          <xsl:message><xsl:value-of select="$debugHeader"/> els:makeIsoDate()</xsl:message>
          <xsl:message> when $regJJMMAA</xsl:message>
        </xsl:if>
        <xsl:variable name="month" as="xs:string">
          <xsl:choose>
            <xsl:when test="string-length($sToken[2]) = 1">
              <xsl:value-of select="concat('0',$sToken[2])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sToken[2]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="day" as="xs:string">
          <xsl:choose>
            <xsl:when test="string-length($sToken[1]) = 1">
              <xsl:value-of select="concat('0',$sToken[1])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$sToken[1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="currentAAAA" select="year-from-date(current-date())" as="xs:integer"/>
        <xsl:variable name="currentAA__" select="substring(string($currentAAAA), 1, 2) cast as xs:integer" as="xs:integer"/>
        <xsl:variable name="current__AA" select="substring(string($currentAAAA), 3, 2) cast as xs:integer" as="xs:integer"/>
        <xsl:variable name="AA" select="xs:integer($sToken[3])" as="xs:integer"/>
        <xsl:variable name="AA_str" select="$sToken[3]" as="xs:string"/>
        <xsl:variable name="AAAA" select="if ($AA gt $current__AA) then (concat($currentAA__ -1, $AA_str))  else (concat($currentAA__, $AA_str))" as="xs:string"/>
        
        <xsl:if test="$debug">
          <xsl:message><xsl:value-of select="$debugHeader"/> els:makeIsoDate()</xsl:message>
          <xsl:message>currentAAAA <xsl:value-of select="$currentAAAA"/></xsl:message>
          <xsl:message>currentAA__ <xsl:value-of select="$currentAA__"/></xsl:message>
          <xsl:message>current__AA <xsl:value-of select="$current__AA"/></xsl:message>
          <xsl:message>AA <xsl:value-of select="$AA"/></xsl:message>
          <xsl:message>AA_str <xsl:value-of select="$AA"/></xsl:message>
          <xsl:message>AAAA <xsl:value-of select="$AAAA"/></xsl:message>
        </xsl:if>
 
        
        <xsl:value-of select="concat($AAAA, '-', $month, '-', $day)"/>
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
      <xd:p>Display an event in time in French (overrides els:displayEvent() function).</xd:p>
      <xd:p>Default months list is $els:months.fr.</xd:p>
      <xd:p>Introducers are: "du ... au ..." and "le ...".</xd:p>
    </xd:desc>
    <xd:param name="date.from">[xs:dateTime?] The beginning of the event.</xd:param>
    <xd:param name="date.to">[xs:dateTime?] The end of the event.</xd:param>
    <xd:return>[xs:string?] The event French verbalization.</xd:return>
  </xd:doc>
  <xsl:function name="els:displayEvent.fr" as="xs:string?">
    <xsl:param name="date.from" as="xs:dateTime?"/>
    <xsl:param name="date.to" as="xs:dateTime?"/>
    <xsl:sequence select="els:displayEvent($date.from, $date.to, $els:months.fr, 'du', 'au', 'le')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Display an event in time:</xd:p>
      <xd:ul>
        <xd:li>a multiple day event set between $date.from and $date.to,</xd:li>
        <xd:li>or a single day event ($date.from only).</xd:li>
      </xd:ul>
      <xd:p>Months are fully verbalized according to $months.verbalized.</xd:p>
      <xd:p>$intro.from and $intro.to are used to introduce $date.from and $date.to (ex.: "from xxx to yyy").</xd:p>
      <xd:p>$intro.singleDate is an optional string used to introduce the a single day event (ex.: "le xxx").</xd:p>
      <xd:p>These introducers are optional; if not specified, the dates are verbalized according to the els:displayDate() function, and separated with a space.</xd:p>
    </xd:desc>
    <xd:param name="date.from">[xs:dateTime?] The beginning of the event.</xd:param>
    <xd:param name="date.to">[xs:dateTime?] The end of the event.</xd:param>
    <xd:param name="months.verbalized">[xs:string+] A list of verbalized months.</xd:param>
    <xd:param name="intro.from">[xs:string?] Word(s) introducing the beginning of the event.</xd:param>
    <xd:param name="intro.to">[xs:string?] Word(s) introducing the end of the event.</xd:param>
    <xd:param name="intro.singleDate">[xs:string?] Word(s) introducing a single day event.</xd:param>
    <xd:return>[xs:string?] The verbalized event.</xd:return>
  </xd:doc>
  <xsl:function name="els:displayEvent" as="xs:string?">
    <xsl:param name="date.from" as="xs:dateTime?"/>
    <xsl:param name="date.to" as="xs:dateTime?"/>
    <xsl:param name="months.verbalized" as="xs:string+"/>
    <xsl:param name="intro.from" as="xs:string?"/>
    <xsl:param name="intro.to" as="xs:string?"/>
    <xsl:param name="intro.singleDate" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="exists($date.from) and exists($date.to) and not(els:dateTime-equal-by-days($date.from, $date.to))">
        <xsl:value-of>
          <xsl:if test="exists($intro.from)">
            <xsl:value-of select="normalize-space($intro.from)"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="els:displayDate(replace(els:getIsoDateFromString(string($date.from)),'\D+',''), $months.verbalized)"/>
          <!-- Separate the 2 dates with a space even if $intro.from and $intro.to are empty -->
          <xsl:text> </xsl:text>
          <xsl:if test="exists($intro.to)">
            <xsl:value-of select="normalize-space($intro.to)"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="els:displayDate(replace(els:getIsoDateFromString(string($date.to)),'\D+',''), $months.verbalized)"/>
        </xsl:value-of>
      </xsl:when>
      <xsl:when test="exists($date.from)">
        <xsl:value-of>
          <xsl:if test="exists($intro.singleDate)">
            <xsl:value-of select="normalize-space($intro.singleDate)"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="els:displayDate(replace(els:getIsoDateFromString(string($date.from)),'\D+',''), $months.verbalized)"/>
        </xsl:value-of>
      </xsl:when>
      <xsl:otherwise>
        <!-- Empty sequence -->
        <xsl:message>[ERROR][els:displayEvent] The supplied dates are not valid: "<xsl:value-of select="$date.from"/>" - "<xsl:value-of select="$date.to"/>".</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
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
  <xsl:function name="els:date-string-to-number-slash" as="xs:string?">
    <xsl:param name="dateVerbalized" as="xs:string"/>
    <xsl:param name="shortMonth" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="empty($dateVerbalized) or count(tokenize($dateVerbalized, $els:regAnySpace)) &lt; 3">
        <xsl:message>[ERROR][els:date-string-to-number-slash] Unable to get the date from '<xsl:value-of select="$dateVerbalized"/>'</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="dateVerbalized.token" select="tokenize($dateVerbalized, $els:regAnySpace)" as="xs:string*"/>
        <xsl:variable name="day" select="$dateVerbalized.token[1]" as="xs:string"/>
        <xsl:variable name="month" select="$dateVerbalized.token[2]" as="xs:string"/>
        <xsl:variable name="year" select="$dateVerbalized.token[3]" as="xs:string"/>
        <xsl:variable name="day.as-digit" as="xs:string?">
          <xsl:choose>
            <xsl:when test="$day = '1er'">
              <xsl:value-of select="'01'"/>
            </xsl:when>
            <xsl:when test="$day castable as xs:integer">
              <xsl:value-of select="format-number($day cast as xs:integer, '00')"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="empty($day.as-digit)">
            <xsl:message>[ERROR][els:date-string-to-number-slash] Unable to get a day as digit from '<xsl:value-of select="$dateVerbalized"/>'</xsl:message>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="month.as-digit" select="format-number(els:getMonthNumFromVerbalizeMonth($month, if ($shortMonth) then $els:monthsShort.fr else $els:months.fr ), '00')" as="xs:string"/>
            <xsl:value-of select="string-join(($day.as-digit, $month.as-digit, $year), '/')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:p>1 arg signature of els:date-string-to-number-slash() - Default $shortMonth = false()</xd:p>
  <xsl:function name="els:date-string-to-number-slash" as="xs:string?">
    <xsl:param name="dateVerbalized" as="xs:string"/>
    <xsl:sequence select="els:date-string-to-number-slash($dateVerbalized, false())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Truncate a 4 digit year into a 2 digit year.</xd:p>
    </xd:desc>
    <xd:param name="year">[xs:string] The 4 digit year.</xd:param>
    <xd:return>[xs:string] A 2 digit year (if the input year really was on 4 digits).</xd:return>
  </xd:doc>
  <xsl:function name="els:getYearOn2Digits" as="xs:string?">
    <xsl:param name="year" as="xs:string"/>
    <xsl:variable name="year.norm" select="normalize-space($year)" as="xs:string"/>
    <xsl:sequence select="if    (string-length($year.norm) = 4 and $year.norm castable as xs:integer)
                          then  (substring($year.norm,3,2))
                          else  ()"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Transform a 2 digit year into a 4 digit year.</xd:p>
      <xd:p>If the value of the supplied year is smaller than <xd:ref name="currentCenturyLimit" type="parameter">$currentCenturyLimit</xd:ref>, it is assumed that the year belongs to the current century.</xd:p>
      <xd:p>If the value of the supplied year is bigger than <xd:ref name="currentCenturyLimit" type="parameter">$currentCenturyLimit</xd:ref>, it is assumed that the year belongs to the previous century.</xd:p>
    </xd:desc>
    <xd:param name="year">[xs:string] The 2 digit year.</xd:param>
    <xd:param name="currentCenturyLimit">[xs:integer] The maximum value for a year to belong to the current century.</xd:param>
    <xd:return>[xs:string] A 4 digit year, resolved according to <xd:ref name="currentCenturyLimit" type="parameter">$currentCenturyLimit</xd:ref>.</xd:return>
  </xd:doc>
  <xsl:function name="els:getYearOn4Digits" as="xs:string?">
    <xsl:param name="year" as="xs:string"/>
    <xsl:param name="currentCenturyLimit" as="xs:integer"/>
    <!-- Get the current century -->
    <xsl:variable name="currentCentury" select="substring(string(year-from-date(current-date())),1,2)" as="xs:string"/>
    <xsl:variable name="precedingCentury" select="string(($currentCentury cast as xs:integer) - 1)" as="xs:string"/>
    <!-- "00" is neither a positive nor a negative integer ! -->
    <xsl:variable name="yearInt" select="if ($year castable as xs:integer and not($year castable as xs:negativeInteger)) then ($year cast as xs:integer) else ()" as="xs:integer?"/>
    <xsl:choose>
      <xsl:when test="$yearInt &lt; 100">
        <xsl:variable name="yearNorm" select="format-integer($yearInt,'##')" as="xs:string"/>
        <xsl:sequence select="if    ($yearInt &lt; $currentCenturyLimit)
                              then  (concat($currentCentury,$yearNorm))
                              else  (concat($precedingCentury,$yearNorm))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>[ERROR][els:getYearOn4Digits] The supplied year is not valid: <xsl:value-of select="$year"/>.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Generic function to say if 2 xs:dateTime are equals at specific precision</xd:p>
    </xd:desc>
    <xd:param name="date1">1st date to compare</xd:param>
    <xd:param name="date2">2nd date to compare</xd:param>
    <xd:param name="precision-picture">format-dateTime picture used for comparaison, e.g. [Y0001]-[M01]-[D01] [H01]:[m01]:[s01]:[f001]</xd:param>
    <!--format-dateTime(xs:dateTime('2019-12-17T14:25:33.123'), '[Y0001]-[M01]-[D01] [H01]:[m01]:[s01]:[f001]') = 2019-12-17 14:25:33:123-->
    <xd:return>Boolean</xd:return>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-precision" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:param name="precision-picture" as="xs:string"/>
    <xsl:sequence select="format-dateTime($date1, $precision-picture) = format-dateTime($date2, $precision-picture)" />
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>compare dateTime at year precision</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-years" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:sequence select="els:dateTime-equal-by-precision($date1, $date2, '[Y0001]')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>compare dateTime at month precision</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-months" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:sequence select="els:dateTime-equal-by-precision($date1, $date2, '[Y0001]-[M01]')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>compare dateTime at day precision</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-days" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:sequence select="els:dateTime-equal-by-precision($date1, $date2, '[Y0001]-[M01]-[D01]')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>compare dateTime at minutes precision</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-minutes" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:sequence select="els:dateTime-equal-by-precision($date1, $date2, '[Y0001]-[M01]-[D01] [H01]:[m01]')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>compare dateTime at second precision</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-seconds" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:sequence select="els:dateTime-equal-by-precision($date1, $date2, '[Y0001]-[M01]-[D01] [H01]:[m01]:[s01]')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>compare dateTime at millisecond precision</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:dateTime-equal-by-milliseconds" as="xs:boolean">
    <xsl:param name="date1" as="xs:dateTime"/>
    <xsl:param name="date2" as="xs:dateTime"/>
    <xsl:sequence select="els:dateTime-equal-by-precision($date1, $date2, '[Y0001]-[M01]-[D01] [H01]:[m01]:[s01]:[f001]')"/>
  </xsl:function>
  
</xsl:stylesheet>