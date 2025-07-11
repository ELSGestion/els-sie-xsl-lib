<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  xmlns:els-common_url-classifier="http://www.lefebvre-sarrut.eu/ns/els/els-common_url-classifier.xsl"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Static compilation check for all inclusions to be available (avoid xslt mode not load)-->
  <xsl:variable name="xslLib:els-common_url-classifier.no-inclusions.check-available-inclusions">
    <xsl:sequence select="$xslLib:els-common_http.available"/>
  </xsl:variable>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>This XSLT is NOT standalone so you can deal with inclusions yourself (and avoid multiple inclusion of the same XSLT module)
        You may also you the standalone version of this XSLT (without "no-inclusions" extension)
      </xd:p>
      <xd:p>ELS-COMMON lib : module "URL classifier"</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:param name="els-common_url-classifier:debug" as="xs:boolean" select="false()" />
  
  <xsl:function name="els:url-is-lefebvre-dalloz" as="xs:boolean">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:sequence select="xs:boolean(els:url-classifier($url)[name() = 'els'])"/>
  </xsl:function>
  
  <xsl:function name="els:url-is-a-publishing-document" as="xs:boolean">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:sequence select="xs:boolean(els:url-classifier($url)[name() = 'doc'])"/>
  </xsl:function>
  
  <xsl:function name="els:url-access-needs-login" as="xs:boolean">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:sequence select="xs:boolean(els:url-classifier($url)[name() = 'login'])"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Analyze an URL to classify it</xd:p>
      <xd:param name="url">[xs:string?] any web URL</xd:param>
      <xd:return>[(xs:boolean, xs:boolean, xs:boolean, xs:string)] A sequence of attributes :</xd:return>
      <xd:ul>
        <xd:li>@els[boolean]: true if the url is one of Lefebvre-Dalloz company (and other linked company), else false</xd:li>
        <xd:li>@publisher [string]: 'efl', 'el', 'dalloz', 'els' (Lefebvre-dalloz), other publisher might be added</xd:li>
        <xd:li>@office[string]:  'back', 'front'</xd:li>
        <xd:li>@env[string]:  'prod', 'dev', 'test', 'preprod'</xd:li>
        <xd:li>@doc: 2nd value: boolean is true
          <xd:ul>
            <xd:li>For a Lefebvre-Dalloz URL ("internal") : if it's pointing a editorial document</xd:li>
            <xd:li>For other URL ("external"): if it's pointing an editorial document which has an equivalent version (ex. Jurisprudence) as a Lefebvre-Dalloz URL ("internal") URL.</xd:li>
          </xd:ul>
        </xd:li>
        <xd:li>@login [boolean]: : true if the url's website requires an authentification login/pwd</xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:url-classifier" as="attribute()*">
    
    <xsl:param name="url" as="xs:string?"/>
    <!--Ex: url = http://www.toto.fr/tata/index.htm?param=1&query=b-->
    
    <xsl:variable name="host" select="els:http-get-host($url)" as="xs:string?"/>
    <!--Ex: host = www.toto.fr-->
    
    <xsl:variable name="full-path" select="substring-after($url,concat($host,'/'))"/>
    <!--Ex: full-full-path = tata/index.htm?param=1&query=b-->
    

    <xsl:variable name="file" select="els:http-get-file($url)" as="xs:string?"/>
    <!--Ex: file = index.htm-->
    
    <xsl:variable name="host.reduced" select="replace($host, '^www\.|^validation.', '')" as="xs:string"/>
    <!--Ex: host.reduced = toto.fr-->
    
    <!--A general variable to get env on els site-->
    <xsl:variable name="env" select="if (matches($host, '^validation\.')) then ('test') else ('prod')" as="xs:string"/>
    
    
    <xsl:choose>
      <!--====================================-->
      <!-- Lefebvre-Dalloz websites -->
      <!--====================================-->
      <!--================-->
      <!-- Back Office -->
      <!--================-->
      <!-- === EL === -->
      <xsl:when test="$host.reduced = 'bo-npa.fr'">
        <!--Sachant que le BO npa est un outil de rédaction interne on va toujours considéré que ce type de lien pointe vers un document, ce n'est pas une URL "ouverte"-->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'back'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'true'"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <!-- === ELS === -->
      <xsl:when test="$host.reduced = 'flash.lefebvre-sarrut.eu'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'back'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <!-- === EFL === -->
      <xsl:when test="$host.reduced = ('efl.fr.s3.amazonaws.com', 'eflfr.s3.eu-west-1.amazonaws.com')">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'back'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!--================-->
      <!-- Front Office -->
      <!--================-->
      <!-- === EFL === -->
      <xsl:when test="$host.reduced = 'abonnes.efl.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^(portail/detailActu\.no\?contextID=\d+&amp;searchIndex=\d+&amp;refID=\d+|EFL2/convert/id/\?id=.+)$')"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'aj2web.efl.fr'">  <!-- a priori -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'boutique.efl.fr'">  <!-- boutique efl -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'efl.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^(actualite|pratique)/(.*/)?[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'jurisprudencechiffree.efl.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lab.efl.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'fec-expert.fr'">  <!-- a priori -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'memento.efl.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'pme.efl.fr'">  <!-- boutique -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = ('sim-repo.efl.fr', 'simulateur.efl.fr')"> <!-- calculettes -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'true'"/> <!--on estime qu'un simulateur est un doc-->
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- === EL === -->
      <xsl:when test="$host.reduced = 'actualites-greffiers.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^documentation/Document\?id=.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = ('actuel-ce.fr', 'actuel-direction-juridique.fr', 'actuel-expert-comptable.fr', 'actuel-hse.fr', 'actuel-rh.fr')">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^(content|sites/default/files)/.+')"/>
        <xsl:attribute name="login" select="'false'"/> <!--fixme : pour lire certains article en entier un login est nécessaire-->
      </xsl:when>
      <xsl:when test="$host.reduced = 'bdes.editions-legislatives.fr'">  <!-- a priori -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = ('elnet.fr', 'elnet-ce.fr', 'elnet-rh.fr', 'elnet-direction-juridique.fr', 'elnet-expert-comptable.fr', 'elnet-hse.fr')">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^documentation/(Document\?.*id=.+|hulkStatic/(.*/)?[^/]+)$')"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'editions-legislatives.fr'">  <!-- boutique El -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^actualite/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lemediasocial-emploi.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^article/.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lemediasocial.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '.+_.+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'tsa-quotidien.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="(matches($full-path, '^(content|sites/default/files/article-files)/.+') 
          and not(matches(tokenize($full-path,'/')[last()], '^en-quete-de-sens|voix-haute-0|ntic-et-travail-social|le-travail-social-au-dela-des-frontieres$')))"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'vp.elnet.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="(matches($full-path, '^aboveille/(cc/)?actucontinue/article(_rg|Guide)?\.do\?attId=\d+.*')
          or matches($full-path, '^aboveille/logon\.do\?.*zone=(CCACTU|AJACTU).*attId=\d+&amp;forward=view(cc)?article(Guide)?$')
          or matches($full-path, '^aboveille/editdoc\.do\?.*attId=\d+$')
          or matches($full-path, '^aboveille/actucontinue/source\.do\?.*docId=\d+.*$'))"/>
        
        <xsl:attribute name="login" select="if($full-path = '') then ('false') else ('true')"/>
      </xsl:when>
      <!-- === DALLOZ === -->
      <xsl:when test="$host.reduced = 'boutique-dalloz.fr'">  <!-- boutique Dalloz -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^lien\?famille=.+&amp;dochype=[A-Z0-9]+/[A-Z0-9]+/\d+/\d+$')
          or matches($full-path, '^documentation/Document\?id=.*$')"/>
        <xsl:attribute name="login" select="if($full-path = '') then ('false') else ('true')"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-actualite.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($full-path, '^(flash|interview|breve|sites/dalloz-actualite.fr/files/resources/\d+/\d+)/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-avocats.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-bibliotheque.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-coaching'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-etudiant.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-revues.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'librairiedalloz.fr'">  <!-- boutique -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'wordpress.dalloz.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- === ELS / LD === -->
      <!--Gateway cf. https://confluence.els-gestion.eu/x/tyN4BQ-->
      <xsl:when test="$host.reduced = 'gateway-backend.int-pld.lefebvre-sarrut.eu'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'integration'"/>
        <!-- it is considered a $doc if there are 3 levels in the subject/theme/document $full-path, 
           the old method with $file didn't work anymore because $file now only returns real files
        -->
        <xsl:attribute name="doc" select="tokenize($full-path,'/')[3] !=''"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'open-dev.lefebvre-dalloz.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="tokenize($full-path,'/')[3] !=''"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'open-ppd.lefebvre-dalloz.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'preprod'"/>
        <xsl:attribute name="doc" select="tokenize($full-path,'/')[3] !=''"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'open-validation.lefebvre-dalloz.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod-validation'"/>
        <xsl:attribute name="doc" select="tokenize($full-path,'/')[3] !=''"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!--front gateway : url finale client-->
      <xsl:when test="$host.reduced = 'open.lefebvre-dalloz.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="tokenize($full-path,'/')[3] !=''"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- boutique Formation -->
      <xsl:when test="$host.reduced = 'elegia.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'esf-editeur.fr'">  <!-- boutique -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lappelexpert.fr'">  <!-- a priori -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lefebvre-sarrut.kbplatform.com'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^Medias/(.*/)?[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- opmaat.sdu.nl hse.sdu.nl  a priori considérées comme externes ? -->
      <!--====================================-->
      <!-- Not Lefebvre-Dalloz websites -->
      <!--====================================-->
      <!-- legifrance -->
      <xsl:when test="$host.reduced = 'circulaire.legifrance.gouv.fr'"> 
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'legifrance'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^(pdf/\d+/\d+/[^/]+\.pdf|codes/article_lc/[^/]+)$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='legifrance.gouv.fr'"> <!-- legifrance -->
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '(LEGIARTI|LEGITEXT|JORFTEXT|JORFDOLE|JORFARTI|JURITEXT|CETATEXT|CNILTEXT|LEGISCTA|KALICONT)\d+')
          or matches($full-path, '^eli/(loi|decret|arrete|decision|ordonnance)/(.*/)?jo/(texte|article_\d+)(/fr)?')
          or matches($full-path, '^jorf/jo(/\d+)+')
          or matches($full-path, '^download/(file/(.*/JOE_TEXTE|pdf/.*/(BOCC|CIRC))|pdf.*\?id=.+)$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- sites ministeriels -->
      <xsl:when test="$host.reduced='solidarites-sante.gouv.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^fichiers/bo/\d+/[\d-]+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='travail-emploi.gouv.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^publications/picts/bo/\d+/\d+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='journal-officiel.gouv.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^publications/bocc/pdf/\d+/\d+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='justice.gouv.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^bo/\d+/\d+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='bofip.impots.gouv.fr'">
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($full-path, '^bofip/\d+-PGP\.html(/identifiant[^/]+)?$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$els-common_url-classifier:debug">
          <xsl:call-template name="debug">
            <xsl:with-param name="host" select="$host"/>
            <xsl:with-param name="host.reduced" select="$host.reduced"/>
            <xsl:with-param name="full-path" select="$full-path"/>
            <xsl:with-param name="file" select="$file"/>
            <xsl:with-param name="env" select="$env"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="''"/>
        <xsl:attribute name="office" select="''"/>
        <xsl:attribute name="env" select="''"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="debug">
    <xsl:param name="host" as="xs:string?"/>
    <xsl:param name="host.reduced" as="xs:string"/>
    <xsl:param name="full-path" as="xs:string?"/>
    <xsl:param name="file" as="xs:string?"/>
    <xsl:param name="env" as="xs:string"/>
    <xsl:attribute name="host" select="$host"/>
    <xsl:attribute name="host.reduced" select="$host.reduced"/>
    <xsl:attribute name="full-path" select="$full-path"/>
    <xsl:attribute name="file" select="$file"/>
    <xsl:attribute name="var.env" select="$env"/>
  </xsl:template>
  
</xsl:stylesheet>