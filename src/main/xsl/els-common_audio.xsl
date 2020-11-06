<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : "Audio" module.</xd:p>
      <xd:p>Utility functions to deal with cloud-hosted audio links and embed content.</xd:p>
      <xd:p>Supported platforms are curently: Soundcloud.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common_http.xsl"/>
  
  <xd:doc>
    <xd:desc>Constants for "Soundcloud" platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:audio.soundcloud" select="'soundcloud'" as="xs:string"/>
  <xsl:variable name="els:audio.soundcloud.domain" select="'w.soundcloud.com'" as="xs:string"/>
  <xsl:variable name="els:audio.soundcloud.embed.defaultWidth" select="'100%'" as="xs:string"/>
  <xsl:variable name="els:audio.soundcloud.embed.defaultHeight" select="'166'" as="xs:string"/>
  <xsl:variable name="els:audio.soundcloud.embed.URL.prefix" select="'https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/'" as="xs:string"/>
  <xsl:variable name="els:audio.soundcloud.embed.URL.suffix" select="''" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Constants for "Ausha" platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:audio.ausha" select="'ausha'" as="xs:string"/>
  <xsl:variable name="els:audio.ausha.domain" select="'player.ausha.co'" as="xs:string"/>
  <xsl:variable name="els:audio.ausha.alt.domain" select="'widget.ausha.co'" as="xs:string"/>
  <xsl:variable name="els:audio.ausha.embed.defaultWidth" select="'100%'" as="xs:string"/>
  <xsl:variable name="els:audio.ausha.embed.defaultHeight" select="'200'" as="xs:string"/>
  <xsl:variable name="els:audio.ausha.embed.URL.prefix" select="'https://player.ausha.co/index.html?podcastId='" as="xs:string"/>
  <xsl:variable name="els:audio.ausha.embed.URL.suffix" select="'&amp;color=%23ffcd1b&amp;v=2&amp;display=horizontal'" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Returns true if the given URL is a link to a cloud-hosted audio clip.</xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:boolean] The result of the URL checking.</xd:return>
  </xd:doc>
  <xsl:function name="els:isAudioUrl" as="xs:boolean">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:sequence select="$hostname = ($els:audio.soundcloud.domain, $els:audio.ausha.domain, $els:audio.ausha.alt.domain)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the platform identifier (as defined in the constants above) from the supplied cloud-hosted audio clip URL.</xd:p>
      <xd:p>If the host in the URL is unknown, returns an empty sequence.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:string?] The platform identifier, if one was recognized.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-platformFromUrl" as="xs:string?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$hostname = $els:audio.soundcloud.domain">
        <xsl:sequence select="$els:audio.soundcloud"/>
      </xsl:when>
      <xsl:when test="$hostname = ($els:audio.ausha.domain, $els:audio.ausha.alt.domain)">
        <xsl:sequence select="$els:audio.ausha"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the ID of a cloud-hosted audio clip.</xd:p>
      <xd:p>Returns an empty sequence if the URL is not a cloud-hosted audio clip URL from a supported platform.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The cloud-hosted audio clip URL.</xd:param>
    <xd:return>[xs:string?] The ID of the cloud-hosted audio clip.</xd:return>
  </xd:doc>
  <xsl:function as="xs:string?" name="els:audio-idFromUrl">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <!-- SOUNDCLOUD : https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/ + ID + &amp;color=... ou ?src=... -->
      <xsl:when test="$hostname = $els:audio.soundcloud.domain">
        <!-- FIXME : make it better! --> 
        <xsl:sequence select="tokenize(substring-after($url, 'tracks/'), '(\?|&amp;)')[1]"/>
      </xsl:when>
      <!-- AUSHA : https://player.ausha.co/index.html?showId=...&color=...&v=2&display=horizontal&podcastId=yJderFGXmEdY -->
      <xsl:when test="$hostname = ($els:audio.ausha.domain, $els:audio.ausha.alt.domain)">
        <!-- FIXME : make it better! --> 
        <xsl:sequence select="tokenize(substring-after($url, 'podcastId='), '(&amp;)')[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the cloud-hosted audio clip.</xd:p>
    </xd:desc>
    <xd:param name="platform">[xs:string] The platform identifier (cf. constants here in els-common_audio.xsl).</xd:param>
    <xd:param name="audioId">[xs:string] The ID of the cloud-hosted audio clip.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="audioId" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$platform = $els:audio.soundcloud">
        <xsl:sequence select="els:audio-makeSoundcloudHtmlEmbed($audioId,$width,$height)"/>
      </xsl:when>
      <xsl:when test="$platform = $els:audio.ausha">
        <xsl:sequence select="els:audio-makeAushaHtmlEmbed($audioId,$width,$height)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the cloud-hosted audio clip.</xd:p>
      <xd:p>2-args signature without width/height arguments, which will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="platform">[xs:string] The platform identifier (cf. constants here in els-common_audio.xsl).</xd:param>
    <xd:param name="audioId">[xs:string] The ID of the cloud-hosted audio clip.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="audioId" as="xs:string"/>
    <xsl:sequence select="els:audio-makeHtmlEmbed($platform,$audioId,(),())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the cloud-hosted audio clip.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The cloud-hosted audio clip URL.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <xsl:sequence select="els:audio-makeHtmlEmbed(els:audio-platformFromUrl($url),els:audio-idFromUrl($url),$width,$height)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the cloud-hosted audio clip.</xd:p>
      <xd:p>1-arg signature without width/height arguments, which will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The cloud-hosted audio clip URL.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:sequence select="els:audio-makeHtmlEmbed($url,(),())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Soundcloud-specific function to generate an iframe embedding the audio clip from the given audio clip ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="audioId">[xs:string] The ID of the Soundcloud audio clip.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the Soundcloud audio-clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-makeSoundcloudHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="audioId" as="xs:string?"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe
      width="{if ($width) then $width else $els:audio.soundcloud.embed.defaultWidth}"
      height="{if ($height) then $height else $els:audio.soundcloud.embed.defaultHeight}"
      scrolling="no"
      frameborder="no"
      src="{$els:audio.soundcloud.embed.URL.prefix || $audioId || $els:audio.soundcloud.embed.URL.suffix}"/>   
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Ausha-specific function to generate an iframe embedding the audio clip from the given audio clip ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="audioId">[xs:string] The ID of the Ausha audio clip.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the Ausha audio-clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:audio-makeAushaHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="audioId" as="xs:string?"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe
      width="{if ($width) then $width else $els:audio.ausha.embed.defaultWidth}"
      height="{if ($height) then $height else $els:audio.ausha.embed.defaultHeight}"
      scrolling="no"
      frameborder="no"
      src="{$els:audio.ausha.embed.URL.prefix || $audioId || $els:audio.ausha.embed.URL.suffix}"/>   
  </xsl:function>
 
</xsl:stylesheet>