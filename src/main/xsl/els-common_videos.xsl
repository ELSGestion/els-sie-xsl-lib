<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "Videos" utilities</xd:p>
      <xd:p>Utils Functions to deal with cloud-hosted videos.</xd:p>
      <xd:p>Supported platforms are curently YouTube and Vimeo.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common_http.xsl"/>
  
  <xsl:variable name="els:video.vimeo" select="'vimeo'" />
  <xsl:variable name="els:video.youtube" select="'youtube'" />
  
  <xsl:variable name="els:video.vimeo.domain" select="'vimeo.com'" />
  <xsl:variable name="els:video.youtube.domain.full" select="'www.youtube.com'" />
  <xsl:variable name="els:video.youtube.domain.short" select="'youtu.be'" />
  
 
  <xsl:variable name="els:video.vimeo.embed.defaultWidth" select="560" />
  <xsl:variable name="els:video.vimeo.embed.defaultHeight" select="315" />
  
  <xd:doc>
    <xd:desc>Returns true if the given URL is a link to a web-hosted video.</xd:desc>
    <xd:param name="url">The URL to check</xd:param>
  </xd:doc>
  <xsl:function as="xs:boolean" name="els:isVideoUrl">
    <xsl:param name="url" as="xs:string" />
    <xsl:variable name="hostname" select="els:http-get-host($url)"/>
    <xsl:sequence select="$hostname = ($els:video.vimeo.domain,$els:video.youtube.domain.full,$els:video.youtube.domain.short)" />
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag to the video.</xd:p>
    </xd:desc>
    <xd:param name="platform">Video Platform Name (cf. constants here in els-common_videos.xsl)</xd:param>
    <xd:param name="videoId">The ID of the video</xd:param>
    <xd:param name="width">Fixed Width </xd:param>
    <xd:param name="height">Fixed Height</xd:param>
  </xd:doc>
  <xsl:function name="els:video-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string" />
    <xsl:param name="videoId" as="xs:string" />
    <xsl:param name="width" as="xs:integer" />
    <xsl:param name="height" as="xs:integer" />
    <xsl:choose>
      <xsl:when test="$platform = $els:video.youtube">
        <xsl:sequence select="els:video-makeYoutubeHtmlEmbed($videoId,$width,$height)" />
      </xsl:when>
      <xsl:when test="$platform = $els:video.vimeo">
        <xsl:sequence select="els:video-makeVimeoHtmlEmbed($videoId,$width,$height)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag to the video.</xd:p>
      <xd:p>2-Args signature without width/height arguments, that will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="platform">Video Platform Name (cf. constants here in els-common_videos.xsl)</xd:param>
    <xd:param name="videoId">The ID of the video</xd:param>
    <xd:param name="width">Fixed Width </xd:param>
    <xd:param name="height">Fixed Height</xd:param>
  </xd:doc>
  <xsl:function name="els:video-makeHtmlEmbed" as="element(html:iframe)?">
    <xsl:param name="platform" as="xs:string"/>
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:sequence select="els:video-makeHtmlEmbed($platform,$videoId,0,0)" />
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Youtube-specif function to generate an embeded video tag.</xd:p>
      <xd:p>If width/height params are set to 0, will be the platform's default.</xd:p>
    </xd:desc>
    <xd:param name="videoId">The ID of the video</xd:param>
    <xd:param name="width">Fixed Width </xd:param>
    <xd:param name="height">Fixed Height</xd:param>
  </xd:doc>
  <xsl:function name="els:video-makeYoutubeHtmlEmbed" as="element(html:iframe)">
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:param name="width" as="xs:int" />
    <xsl:param name="height" as="xs:int" />
    <xsl:variable name="defaultWidth" select="560" />
    <xsl:variable name="defaultHeight" select="315" />
    
    <xsl:sequence>
      <html:iframe
        width="{if ($width) then $width else $defaultWidth}"
        height="{if ($height) then $height else $defaultHeight}"
        frameborder="0"
        allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" 
        llowfullscreen="allowfullscreen"
        src="https://www.youtube.com/embed/{$videoId}"/>
    </xsl:sequence>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Vimeo-specif function to generate an embeded video tag.</xd:p>
      <xd:p>If width/height params are set to 0, will be the platform's default.</xd:p>
    </xd:desc>
    <xd:param name="videoId">The ID of the video</xd:param>
    <xd:param name="width">Fixed Width </xd:param>
    <xd:param name="height">Fixed Height</xd:param>
  </xd:doc>
  <xsl:function name="els:video-makeVimeoHtmlEmbed" as="element(html:iframe)">
    <xsl:param name="videoId" as="xs:string"/>
    <xsl:param name="width" as="xs:int" />
    <xsl:param name="height" as="xs:int" />
    <xsl:variable name="defaultWidth" select="640" />
    <xsl:variable name="defaultHeight" select="465" />
    
    <xsl:sequence>
      <html:iframe
        width="{if($width) then $width else $defaultWidth}"
        height="{if($height) then $height else $defaultHeight}"
        frameborder="0"
        allowfullscreen="allowfullscreen"
        src="https://player.vimeo.com/video/{$videoId}" />
    </xsl:sequence>
  </xsl:function>
 
</xsl:stylesheet>