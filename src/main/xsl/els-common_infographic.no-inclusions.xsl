<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Static compilation check for all inclusions to be available (avoid xslt mode not load)-->
  <xsl:variable name="xslLib:els-common_infographic.no-inclusions.check-available-inclusions">
    <xsl:sequence select="$xslLib:els-common_http.available"/>
  </xsl:variable>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
        You may also you the standalone version of this XSLT (without "no-inclusions" extension)
      </xd:p>
      <xd:p>ELS-COMMON lib : "Infographic" module.</xd:p>
      <xd:p>Utility functions to deal with infographic content.</xd:p>
      <xd:p>Supported platforms are curently: infogram, datawrapper, piktochart, knightlab (timelines only).</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xd:doc>
    <xd:desc>Constants for "infogram" platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:infographic.infogram" select="'infogram'" as="xs:string"/>
  <xsl:variable name="els:infographic.infogram.domain" select="'e.infogram.com'" as="xs:string"/>
  <xsl:variable name="els:infographic.infogram.embed.defaultWidth" select="'640'" as="xs:string"/>
  <xsl:variable name="els:infographic.infogram.embed.defaultHeight" select="'465'" as="xs:string"/>
  <xsl:variable name="els:infographic.infogram.embed.URL.prefix" select="'https://e.infogram.com/'" as="xs:string"/>
  <xsl:variable name="els:infographic.infogram.embed.URL.suffix" select="'?src=embed'" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Constants for "datawrapper" platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:infographic.datawrapper" select="'datawrapper'" as="xs:string"/>
  <xsl:variable name="els:infographic.datawrapper.domain" select="'www.datawrapper.de'" as="xs:string"/>
  <xsl:variable name="els:infographic.datawrapper.embed.defaultWidth" select="'640'" as="xs:string"/>
  <xsl:variable name="els:infographic.datawrapper.embed.defaultHeight" select="'465'" as="xs:string"/>
  <xsl:variable name="els:infographic.datawrapper.embed.URL.prefix" select="'//datawrapper.dwcdn.net/'" as="xs:string"/>
  <xsl:variable name="els:infographic.datawrapper.embed.URL.suffix" select="'/1/'" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Constants for "piktochart" platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:infographic.piktochart" select="'piktochart'" as="xs:string"/>
  <xsl:variable name="els:infographic.piktochart.domain" select="'create.piktochart.com'" as="xs:string"/>
  <xsl:variable name="els:infographic.piktochart.embed.defaultWidth" select="'640'" as="xs:string"/>
  <xsl:variable name="els:infographic.piktochart.embed.defaultHeight" select="'465'" as="xs:string"/>
  <xsl:variable name="els:infographic.piktochart.embed.URL.prefix" select="'https://create.piktochart.com/embed/'" as="xs:string"/>
  <xsl:variable name="els:infographic.piktochart.embed.URL.suffix" select="''" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Constants for "knightlab" (timelines) platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:infographic.knightlab-timeline" select="'knightlab-timeline'" as="xs:string"/>
  <xsl:variable name="els:infographic.knightlab-timeline.domain" select="'cdn.knightlab.com'" as="xs:string"/>
  <xsl:variable name="els:infographic.knightlab-timeline.embed.defaultWidth" select="'640'" as="xs:string"/>
  <xsl:variable name="els:infographic.knightlab-timeline.embed.defaultHeight" select="'600'" as="xs:string"/>
  <xsl:variable name="els:infographic.knightlab-timeline.embed.URL.prefix" select="'https://cdn.knightlab.com/libs/timeline3/latest/embed/?source='" as="xs:string"/>
  <xsl:variable name="els:infographic.knightlab-timeline.embed.URL.suffix" select="''" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Returns true if the given URL is a link to an infographic.</xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:boolean] The result of the URL checking.</xd:return>
  </xd:doc>
  <xsl:function name="els:isInfographicUrl" as="xs:boolean">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:sequence select="$hostname = ($els:infographic.infogram.domain, $els:infographic.datawrapper.domain, $els:infographic.piktochart.domain, $els:infographic.knightlab-timeline.domain)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the platform identifier (as defined in the constants above) from the supplied infographic URL.</xd:p>
      <xd:p>If the host in the URL is unknown, returns an empty sequence.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:string?] The platform identifier, if one was recognized.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-platformFromUrl" as="xs:string?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$hostname = $els:infographic.infogram.domain">
        <xsl:sequence select="$els:infographic.infogram"/>
      </xsl:when>
      <xsl:when test="$hostname = $els:infographic.datawrapper.domain">
        <xsl:sequence select="$els:infographic.datawrapper"/>
      </xsl:when>
      <xsl:when test="$hostname = $els:infographic.piktochart.domain">
        <xsl:sequence select="$els:infographic.piktochart"/>
      </xsl:when>
      <xsl:when test="$hostname = $els:infographic.knightlab-timeline.domain">
        <xsl:sequence select="$els:infographic.knightlab-timeline"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the ID of an infographic.</xd:p>
      <xd:p>Returns an empty sequence if the URL is not an infographic URL from a supported platform.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The infographic URL.</xd:param>
    <xd:return>[xs:string?] The ID of the infographic.</xd:return>
  </xd:doc>
  <xsl:function as="xs:string?" name="els:infographic-idFromUrl">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <!-- INFOGRAM : https://e.infogram.com/ + infographie-id + ?src=embed -->
      <xsl:when test="$hostname = $els:infographic.infogram.domain">
        <xsl:sequence select="els:http-get-path($url)"/>
      </xsl:when>
      <!-- DATAWRAPPER : https://www.datawrapper.de/ + _/ + infographie-id + / -->
      <xsl:when test="$hostname = $els:infographic.datawrapper.domain">
        <xsl:sequence select="tokenize(els:http-get-path($url), '/')[2]"/>
      </xsl:when>
      <!-- PIKTOCHART :  https://create.piktochart.com/ + output/ + infographie-id -->
      <xsl:when test="$hostname = $els:infographic.piktochart.domain">
        <xsl:sequence select="tokenize(els:http-get-path($url), '/')[2]"/>
      </xsl:when>
      <!-- TIMELINE (KNIGHTLAB) :  https://cdn.knightlab.com/ + libs/timeline3/latest/embed/?source= + timeline-id -->
      <!-- /!\ To be reworked if another Knightlab service is added, because the hostname will be the same -->
      <xsl:when test="$hostname = $els:infographic.knightlab-timeline.domain">
        <xsl:sequence select="tokenize(els:http-get-query-string($url),'&amp;')[matches(.,'^source=')]!substring-after(.,'source=')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the infographic.</xd:p>
    </xd:desc>
    <xd:param name="platform">[xs:string] The platform identifier (cf. constants here in els-common_infographic.xsl).</xd:param>
    <xd:param name="infographicId">[xs:string] The ID of the infographic.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="infographicId" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$platform = $els:infographic.infogram">
        <xsl:sequence select="els:infographic-makeInfogramHtmlEmbed($infographicId,$width,$height)"/>
      </xsl:when>
      <xsl:when test="$platform = $els:infographic.datawrapper">
        <xsl:sequence select="els:infographic-makeDatawrapperHtmlEmbed($infographicId,$width,$height)"/>
      </xsl:when>
      <xsl:when test="$platform = $els:infographic.piktochart">
        <xsl:sequence select="els:infographic-makePiktochartHtmlEmbed($infographicId,$width,$height)"/>
      </xsl:when>
      <xsl:when test="$platform = $els:infographic.knightlab-timeline">
        <xsl:sequence select="els:infographic-makeKnightlabTimelineHtmlEmbed($infographicId,$width,$height)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the infographic.</xd:p>
      <xd:p>2-args signature without width/height arguments, which will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="platform">[xs:string] The platform identifier (cf. constants here in els-common_infographic.xsl).</xd:param>
    <xd:param name="infographicId">[xs:string] The ID of the infographic.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="infographicId" as="xs:string"/>
    <xsl:sequence select="els:infographic-makeHtmlEmbed($platform,$infographicId,(),())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the infographic.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The infographic URL.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <xsl:sequence select="els:infographic-makeHtmlEmbed(els:infographic-platformFromUrl($url),els:infographic-idFromUrl($url),$width,$height)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the infographic.</xd:p>
      <xd:p>1-arg signature without width/height arguments, which will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The infographic URL.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:sequence select="els:infographic-makeHtmlEmbed($url,(),())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Infogram-specific function to generate an iframe embedding the Infogram infographic given its ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="infographicId">[xs:string] The ID of the Infogram infographic.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the Infogram infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeInfogramHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="infographicId" as="xs:string?"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe 
      src="{$els:infographic.infogram.embed.URL.prefix || $infographicId || $els:infographic.infogram.embed.URL.suffix}"
      title=""
      width="{if ($width) then $width else $els:infographic.infogram.embed.defaultWidth}"
      height="{if ($height) then $height else $els:infographic.infogram.embed.defaultHeight}"
      scrolling="no"
      frameborder="0"
      style="border:none;"
      allowfullscreen="allowfullscreen"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Datawrapper-specific function to generate an iframe embedding the Datawrapper infographic given its ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="infographicId">[xs:string] The ID of the Datawrapper infographic.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the Datawrapper infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeDatawrapperHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="infographicId" as="xs:string?"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe 
      title=""
      aria-label=""
      src="{$els:infographic.datawrapper.embed.URL.prefix || $infographicId || $els:infographic.datawrapper.embed.URL.suffix}"
      scrolling="no"
      frameborder="0"
      style="border: none;"
      width="{if ($width) then $width else $els:infographic.datawrapper.embed.defaultWidth}" 
      height="{if ($height) then $height else $els:infographic.datawrapper.embed.defaultHeight}"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Piktochart-specific function to generate an iframe embedding the Piktochart infographic given its ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="infographicId">[xs:string] The ID of the Piktochart infographic.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the Piktochart infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makePiktochartHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="infographicId" as="xs:string?"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe 
      width="{if ($width) then $width else $els:infographic.piktochart.embed.defaultWidth}"
      height="{if ($height) then $height else $els:infographic.piktochart.embed.defaultHeight}"
      frameborder="0"
      scrolling="no"
      style="overflow-y:hidden;"
      src="{$els:infographic.piktochart.embed.URL.prefix || $infographicId || $els:infographic.piktochart.embed.URL.suffix}"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Knightlab-specific function to generate an iframe embedding the Knightlab timeline infographic given its ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="infographicId">[xs:string] The ID of the Knightlab timeline infographic.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the Knightlab timeline infographic.</xd:return>
  </xd:doc>
  <xsl:function name="els:infographic-makeKnightlabTimelineHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="infographicId" as="xs:string?"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe 
      width="{if ($width) then $width else $els:infographic.knightlab-timeline.embed.defaultWidth}"
      height="{if ($height) then $height else $els:infographic.knightlab-timeline.embed.defaultHeight}"
      frameborder="0"
      scrolling="no"
      src="{$els:infographic.knightlab-timeline.embed.URL.prefix || $infographicId || $els:infographic.knightlab-timeline.embed.URL.suffix}"/>
  </xsl:function>
 
</xsl:stylesheet>