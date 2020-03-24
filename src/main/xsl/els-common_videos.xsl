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
      <xd:p>ELS-COMMON lib : module "Videos" utilities.</xd:p>
      <xd:p>Utils Functions to deal with cloud-hosted videos.</xd:p>
      <xd:p>Supported platforms are curently YouTube and Vimeo.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common_http.xsl"/>
  
  <xd:doc>
    <xd:desc>Constant for "Vimeo" Platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:video.vimeo" select="'vimeo'" as="xs:string"/>
  <xsl:variable name="els:video.vimeo.domain" select="'vimeo.com'" as="xs:string"/>
  <xsl:variable name="els:video.vimeo.embed.defaultWidth" select="'640'" as="xs:string"/>
  <xsl:variable name="els:video.vimeo.embed.defaultHeight" select="'465'" as="xs:string"/>
  <xsl:variable name="els:audio.vimeo.embed.URL.prefix" select="'https://player.vimeo.com/video/'" as="xs:string"/>
  <xsl:variable name="els:audio.vimeo.embed.URL.suffix" select="''" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Constant for "YouTube" Platform</xd:desc>
  </xd:doc>
  <xsl:variable name="els:video.youtube" select="'youtube'" as="xs:string"/>  
  <xsl:variable name="els:video.youtube.domain.full" select="'www.youtube.com'" as="xs:string"/>
  <xsl:variable name="els:video.youtube.domain.short" select="'youtu.be'" as="xs:string"/>
  <xsl:variable name="els:video.youtube.embed.defaultWidth" select="'560'" as="xs:string"/>
  <xsl:variable name="els:video.youtube.embed.defaultHeight" select="'315'" as="xs:string"/>  
  <xsl:variable name="els:audio.youtube.embed.URL.prefix" select="'https://www.youtube.com/embed/'" as="xs:string"/>
  <xsl:variable name="els:audio.youtube.embed.URL.suffix" select="''" as="xs:string"/>
  
  <xd:doc>
    <xd:desc>Returns true if the given URL is a link to a web-hosted video.</xd:desc>
    <xd:param name="url">[xs:string] The URL to check</xd:param>
    <xd:return>[xs:boolean] The result of the URL checking.</xd:return>
  </xd:doc>
  <xsl:function as="xs:boolean" name="els:isVideoUrl">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:sequence select="$hostname = ($els:video.vimeo.domain,$els:video.youtube.domain.full,$els:video.youtube.domain.short)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the platform identifier (as defined in the constants above) from the supplied video URL.</xd:p>
      <xd:p>If the URL is not video hosted on a supported platform, returns the empty sequence.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:string?] The platform identifier, if one was recognized.</xd:return>
  </xd:doc>
  <xsl:function as="xs:string?" name="els:video-platformFromUrl">
    <xsl:param name="url" as="xs:string" />
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$hostname = $els:video.vimeo.domain">
        <xsl:sequence select="$els:video.vimeo"/>
      </xsl:when>
      <xsl:when test="$hostname = ($els:video.youtube.domain.full,$els:video.youtube.domain.short)">
        <xsl:sequence select="$els:video.youtube"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the ID of a cloud-hosted video.</xd:p>
      <xd:p>Returns the empty sequence if the URL is not a video URL from a supported platform.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The video clip URL.</xd:param>
    <xd:return>[xs:string?] The ID of the video clip.</xd:return>
  </xd:doc>
  <xsl:function as="xs:string?" name="els:video-idFromUrl">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$hostname = ($els:video.vimeo.domain,$els:video.youtube.domain.short)">
        <xsl:variable name="path" select="els:http-get-path($url)" />
        <!-- The condition below should exclude Vimeo Pages that are not videos, eg "en/pricing" -->
        <xsl:sequence select="if (contains($path,'/')) then () else $path"/>
      </xsl:when>
      <xsl:when test="$hostname = $els:video.youtube.domain.full">
        <xsl:sequence select="els:http-get-param($url,'v')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the video clip.</xd:p>
    </xd:desc>
    <xd:param name="platform">[xs:string] The platform identifier (cf. constants here in els-common_video.xsl).</xd:param>
    <xd:param name="videoId">[xs:string] The ID of the video.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:video-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$platform = $els:video.youtube">
        <xsl:sequence select="els:video-makeYoutubeHtmlEmbed($videoId,$width,$height)"/>
      </xsl:when>
      <xsl:when test="$platform = $els:video.vimeo">
        <xsl:sequence select="els:video-makeVimeoHtmlEmbed($videoId,$width,$height)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the video clip.</xd:p>
      <xd:p>2-Args signature without width/height arguments, that will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="platform">[xs:string] The platform identifier (cf. constants here in els-common_video.xsl).</xd:param>
    <xd:param name="videoId">[xs:string] The ID of the video.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:video-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:sequence select="els:video-makeHtmlEmbed($platform,$videoId,(),())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the video clip.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The video clip URL.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:video-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string" />
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <xsl:sequence select="els:video-makeHtmlEmbed(els:video-platformFromUrl($url),els:video-idFromUrl($url),$width,$height)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the video clip.</xd:p>
      <xd:p>1-Args signature without width/height arguments, that will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The video clip URL.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:video-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string" />
    <xsl:sequence select="els:video-makeHtmlEmbed($url,(),())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Youtube-specific function to generate an iframe embedding the video clip from the given video clip ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="videoId">[xs:string] The ID of the video.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:video-makeYoutubeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe
      width="{if ($width) then $width else $els:video.youtube.embed.defaultWidth}"
      height="{if ($height) then $height else $els:video.youtube.embed.defaultHeight}"
      frameborder="0"
      allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" 
      allowfullscreen="allowfullscreen"
      src="{$els:audio.youtube.embed.URL.prefix || $videoId || $els:audio.youtube.embed.URL.suffix}"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Vimeo-specific function to generate an iframe embedding the video clip from the given video clip ID.</xd:p>
      <xd:p>If width/height params are set to an empty sequence, the platform default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="videoId">[xs:string] The ID of the video.</xd:param>
    <xd:param name="width">[xs:string?] A fixed width.</xd:param>
    <xd:param name="height">[xs:string?] A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the clip.</xd:return>
  </xd:doc>
  <xsl:function name="els:video-makeVimeoHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:param name="width" as="xs:string?"/>
    <xsl:param name="height" as="xs:string?"/>
    <iframe
      width="{if ($width) then $width else $els:video.vimeo.embed.defaultWidth}"
      height="{if ($height) then $height else $els:video.vimeo.embed.defaultHeight}"
      frameborder="0"
      allowfullscreen="allowfullscreen"
      src="{$els:audio.vimeo.embed.URL.prefix || $videoId || $els:audio.vimeo.embed.URL.suffix}" />   
  </xsl:function>
 
</xsl:stylesheet>