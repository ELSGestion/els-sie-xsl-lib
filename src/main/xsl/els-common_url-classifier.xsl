<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0">
  
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
    <xsl:variable name="host" select="replace(replace($url, 'https?://', ''), '/.*$', '')" as="xs:string"/>
    <xsl:variable name="path" select="replace(replace($url, concat('^https?://', $host), ''), '^/+', '')" as="xs:string"/>
    <xsl:variable name="file" select="replace($url, '^.*/', '')" as="xs:string"/>
    <xsl:variable name="host.reduced" select="replace($host, '^www\.|^validation.', '')" as="xs:string"/>
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
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'back'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'true'"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <!-- === ELS === -->
      <xsl:when test="$host.reduced = 'flash.lefebvre-sarrut.eu'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'back'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <!-- === EFL === -->
      <xsl:when test="$host.reduced = ('efl.fr.s3.amazonaws.com', 'eflfr.s3.eu-west-1.amazonaws.com')">
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
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^(portail/detailActu\.no\?contextID=\d+&amp;searchIndex=\d+&amp;refID=\d+|EFL2/convert/id/\?id=.+)$')"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'aj2web.efl.fr'">  <!-- a priori -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'boutique.efl.fr'">  <!-- boutique efl -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'efl.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^(actualite|pratique)/(.*/)?[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'jurisprudencechiffree.efl.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lab.efl.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'fec-expert.fr'">  <!-- a priori -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'memento.efl.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'pme.efl.fr'">  <!-- boutique -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = ('sim-repo.efl.fr', 'simulateur.efl.fr')"> <!-- calculettes -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'efl'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="'true'"/> <!--on estime qu'un simulateur est un doc-->
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- === EL === -->
      <xsl:when test="$host.reduced = 'actualites-greffiers.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^documentation/Document\?id=.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = ('actuel-ce.fr', 'actuel-direction-juridique.fr', 'actuel-expert-comptable.fr', 'actuel-hse.fr', 'actuel-rh.fr')">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^(content|sites/default/files)/.+')"/>
        <xsl:attribute name="login" select="'false'"/> <!--fixme : pour lire certains article en entier un login est nécessaire-->
      </xsl:when>
      <xsl:when test="$host.reduced = 'bdes.editions-legislatives.fr'">  <!-- a priori -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = ('elnet.fr', 'elnet-ce.fr', 'elnet-rh.fr', 'elnet-direction-juridique.fr', 'elnet-expert-comptable.fr', 'elnet-hse.fr')">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^documentation/(Document\?.*id=.+|hulkStatic/(.*/)?[^/]+)$')"/>
        <xsl:attribute name="login" select="'true'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'editions-legislatives.fr'">  <!-- boutique El -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^actualite/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lemediasocial-emploi.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^article/.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lemediasocial.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '.+_.+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'tsa-quotidien.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="(matches($path, '^(content|sites/default/files/article-files)/.+') 
          and not(matches($file, '^en-quete-de-sens|voix-haute-0|ntic-et-travail-social|le-travail-social-au-dela-des-frontieres$')))"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'vp.elnet.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="(matches($path, '^aboveille/(cc/)?actucontinue/article(_rg|Guide)?\.do\?attId=\d+.*')
          or matches($path, '^aboveille/logon\.do\?.*zone=(CCACTU|AJACTU).*attId=\d+&amp;forward=view(cc)?article(Guide)?$')
          or matches($path, '^aboveille/editdoc\.do\?.*attId=\d+$')
          or matches($path, '^aboveille/actucontinue/source\.do\?.*docId=\d+.*$'))"/>
        <xsl:attribute name="login" select="if($path = '') then ('false') else ('true')"/>
      </xsl:when>
      <!-- === DALLOZ === -->
      <xsl:when test="$host.reduced = 'boutique-dalloz.fr'">  <!-- boutique Dalloz -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^lien\?famille=.+&amp;dochype=[A-Z0-9]+/[A-Z0-9]+/\d+/\d+$')
          or matches($path, '^documentation/Document\?id=.*$')"/>
        <xsl:attribute name="login" select="if($path = '') then ('false') else ('true')"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-actualite.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="matches($path, '^(flash|interview|breve|sites/dalloz-actualite.fr/files/resources/\d+/\d+)/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-avocats.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-bibliotheque.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-coaching'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-etudiant.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'dalloz-revues.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'librairiedalloz.fr'">  <!-- boutique -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'wordpress.dalloz.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'el'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="$env"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- === ELS / LD === -->
      <xsl:when test="$host.reduced = 'backend.gateway-dev.lefebvre-sarrut.eu'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="matches($file, '.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'backend.gateway-ppd.lefebvre-sarrut.eu'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="matches($file, '.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'backend.gateway.lefebvre-sarrut.eu'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($file, '.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!--front gateway : url finale client-->
      <xsl:when test="$host.reduced = 'open.lefebvre-dalloz.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($file, '.+')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- boutique Formation -->
      <xsl:when test="$host.reduced = 'elegia.fr'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'esf-editeur.fr'">  <!-- boutique -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lappelexpert.fr'">  <!-- a priori -->
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'dev'"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced = 'lefebvre-sarrut.kbplatform.com'">
        <xsl:attribute name="els" select="'true'"/>
        <xsl:attribute name="publisher" select="'els'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^Medias/(.*/)?[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- opmaat.sdu.nl hse.sdu.nl  a priori considérées comme externes ? -->
      <!--====================================-->
      <!-- Not Lefebvre-Dalloz websites -->
      <!--====================================-->
      <!-- legifrance -->
      <xsl:when test="$host.reduced = 'circulaire.legifrance.gouv.fr'"> 
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'legifrance'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^(pdf/\d+/\d+/[^/]+\.pdf|codes/article_lc/[^/]+)$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='legifrance.gouv.fr'"> <!-- legifrance -->
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '(LEGIARTI|LEGITEXT|JORFTEXT|JORFDOLE|JORFARTI|JURITEXT|CETATEXT|CNILTEXT|LEGISCTA|KALICONT)\d+')
          or matches($path, '^eli/(loi|decret|arrete|decision|ordonnance)/(.*/)?jo/(texte|article_\d+)(/fr)?')
          or matches($path, '^jorf/jo(/\d+)+')
          or matches($path, '^download/(file/(.*/JOE_TEXTE|pdf/.*/(BOCC|CIRC))|pdf.*\?id=.+)$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <!-- sites ministeriels -->
      <xsl:when test="$host.reduced='solidarites-sante.gouv.fr'">
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^fichiers/bo/\d+/[\d-]+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='travail-emploi.gouv.fr'">
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^publications/picts/bo/\d+/\d+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='journal-officiel.gouv.fr'">
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^publications/bocc/pdf/\d+/\d+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='justice.gouv.fr'">
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^bo/\d+/\d+/[^/]+$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:when test="$host.reduced='bofip.impots.gouv.fr'">
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="'gouv'"/>
        <xsl:attribute name="office" select="'front'"/>
        <xsl:attribute name="env" select="'prod'"/>
        <xsl:attribute name="doc" select="matches($path, '^bofip/\d+-PGP\.html(/identifiant[^/]+)?$')"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="els" select="'false'"/>
        <xsl:attribute name="publisher" select="''"/>
        <xsl:attribute name="office" select="''"/>
        <xsl:attribute name="env" select="''"/>
        <xsl:attribute name="doc" select="'false'"/>
        <xsl:attribute name="login" select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>