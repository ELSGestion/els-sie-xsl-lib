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
      <xd:p>ELS-COMMON lib : "Social network" module.</xd:p>
      <xd:p>Utility functions to deal with social networks links and embed content.</xd:p>
      <xd:p>Supported platforms are curently: Twitter.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:import href="els-common_http.xsl"/>
  
  <xd:doc>
    <xd:desc>Constants for "Twitter" platform.</xd:desc>
  </xd:doc>
  <xsl:variable name="els:social-network.twitter" select="'twitter'" as="xs:string"/>
  <xsl:variable name="els:social-network.twitter.domain" select="'twitter.com'" as="xs:string"/>
  <xsl:variable name="els:social-network.twitter.embed.defaultWidth" select="450" as="xs:integer"/>
  <xsl:variable name="els:social-network.twitter.embed.defaultHeight" select="250" as="xs:integer"/>
  
  <xd:doc>
    <xd:desc>Returns true if the given URL is a link to a social network platform.</xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:boolean] The result of the URL checking.</xd:return>
  </xd:doc>
  <xsl:function name="els:isSocialNetworkUrl" as="xs:boolean">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:sequence select="$hostname = ($els:social-network.twitter.domain)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the platform identifier (as defined in the constants above) from the supplied social network URL.</xd:p>
      <xd:p>If the host in the URL is unknown, returns an empty sequence.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The URL to check.</xd:param>
    <xd:return>[xs:string?] The platform identifier, if one was recognized.</xd:return>
  </xd:doc>
  <xsl:function name="els:social-network-platformFromUrl" as="xs:string?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$hostname = $els:social-network.twitter.domain">
        <xsl:sequence select="$els:social-network.twitter"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the ID of a social network post.</xd:p>
      <xd:p>Returns an empty sequence if the URL is not a social network URL from a supported platform.</xd:p>
    </xd:desc>
    <xd:param name="url">[xs:string] The social network URL.</xd:param>
    <xd:return>[xs:string?] The ID of a social network post.</xd:return>
  </xd:doc>
  <xsl:function as="xs:string?" name="els:social-network-idFromUrl">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="hostname" select="els:http-get-host($url)" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="$hostname = $els:social-network.twitter.domain">
        <xsl:sequence select="tokenize(els:http-get-path($url), '/')[3]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the social network post.</xd:p>
    </xd:desc>
    <xd:param name="url">The social network URL of the post.</xd:param>
    <xd:param name="width">A fixed width.</xd:param>
    <xd:param name="height">A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the post.</xd:return>
  </xd:doc>
  <xsl:function name="els:social-network-makeHtmlEmbedFromUrl" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="height" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="els:social-network-platformFromUrl($url) = $els:social-network.twitter">
        <xsl:sequence select="els:social-network-makeTwitterHtmlEmbedFromUrl($url,$width,$height)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Function that a returns a generated web-integration-ready html tag embedding the social network post.</xd:p>
      <xd:p>1-arg signature without width/height arguments, which will be set to the platform default.</xd:p>
    </xd:desc>
    <xd:param name="url">The social network URL of the post.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the post.</xd:return>
  </xd:doc>
  <xsl:function name="els:social-network-makeHtmlEmbedFromUrl" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:sequence select="els:social-network-makeHtmlEmbedFromUrl($url,0,0)" />
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Twitter-specific function to generate an iframe embeding the tweet from the given URL.</xd:p>
      <xd:p>If width/height params are set to 0, the platform's default values will be used.</xd:p>
    </xd:desc>
    <xd:param name="url">The URL of the tweet.</xd:param>
    <xd:param name="width">A fixed width.</xd:param>
    <xd:param name="height">A fixed height.</xd:param>
    <xd:return>[element(html:iframe)?] The web-integration-ready html tag of the tweet.</xd:return>
  </xd:doc>
  <xsl:function name="els:social-network-makeTwitterHtmlEmbedFromUrl" as="element(html:iframe)?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="height" as="xs:integer"/>
    <!-- Twitter's "publish.twitter.com/oembed" API returns a nasty HTML5 tag soup so we use the service Twitframe which does everything for us -->
    <iframe 
      title=""
      aria-label=""
      src="https://twitframe.com/show?url={$url}"
      scrolling="1"
      frameborder="0"
      width="{if ($width != 0) then $width else $els:social-network.twitter.embed.defaultWidth}"
      height="{if ($height != 0) then $height else $els:social-network.twitter.embed.defaultHeight}"/>   
  </xsl:function>
 
</xsl:stylesheet>