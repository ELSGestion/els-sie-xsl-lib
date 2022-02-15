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
    <xsl:sequence select="els:url-classifier($url)[1]"/>
  </xsl:function>
  
  <xsl:function name="els:url-is-an-publishing-document" as="xs:boolean">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:sequence select="els:url-classifier($url)[2]"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Analyze an URL to classify it</xd:p>
      <xd:param name="url">[xs:string?] any web URL</xd:param>
      <xd:return>[(xs:boolean, xs:boolean)] A sequence of 2 boolean </xd:return>
      <xd:ul>
        <xd:li>The first boolean is true if the url is one of Lefebvre-Dalloz companty (and other linked company), else false</xd:li>
        <xd:li>The second boolean is true
          <xd:ul>
            <xd:li>For a Lefebvre-Dalloz URL ("internal") : if it's pointing a editorial document</xd:li>
            <xd:li>For other URL ("external"): if it's pointing a editorial document that might also be accessed through a Lefebvre-Dalloz URL ("internal") URL.</xd:li>
          </xd:ul>
        </xd:li>
      </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:url-classifier" as="xs:boolean+" visibility="private">
    <xsl:param name="url" as="xs:string?"/>
    <xsl:variable name="site" select="replace(replace($url, 'https?://', ''), '/.*$', '')" as="xs:string"/>
    <xsl:variable name="path" select="replace(replace($url, concat('^https?://', $site), ''), '^/+', '')" as="xs:string"/>
    <xsl:variable name="file" select="replace($url, '^.*/', '')" as="xs:string"/>
    <xsl:variable name="reduced-site" select="replace($site, '^www\.|^validation.', '')" as="xs:string"/>
    <xsl:choose>
      <!--====================================-->
      <!-- Lefebvre-Dalloz websites -->
      <!--====================================-->
      <xsl:when test="$reduced-site = 'abonnes.efl.fr'">
        <xsl:sequence select="(true(), matches($path, '^(portail/detailActu\.no\?contextID=\d+&amp;searchIndex=\d+&amp;refID=\d+|EFL2/convert/id/\?id=.+)$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'actualites-greffiers.fr'">(true(), matches($path, "^documentation/Document\?id=.+"))
        <xsl:sequence select="(true(), matches($path, '^documentation/Document\?id=.+'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = ('actuel-ce.fr', 'actuel-direction-juridique.fr', 'actuel-expert-comptable.fr', 'actuel-hse.fr', 'actuel-rh.fr')">
        <xsl:sequence select="(true(), matches($path, '^(content|sites/default/files)/.+'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'aj2web.efl.fr'">  <!-- a priori -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'backend.gateway-dev.lefebvre-sarrut.eu'">
        <xsl:sequence select="(true(), matches($file, '.+'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'bdes.editions-legislatives.fr'">  <!-- a priori -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'boutique.efl.fr'">  <!-- boutique efl -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'boutique-dalloz.fr'">  <!-- boutique Dalloz -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), matches($path, '^lien\?famille=.+&amp;dochype=[A-Z0-9]+/[A-Z0-9]+/\d+/\d+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz-actualite.fr'">
        <xsl:sequence select="(true(), matches($path, '^(flash|interview|sites/dalloz-actualite.fr/files/resources/\d+/\d+)/[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz-avocats.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz-bibliotheque.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz-coaching'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz-etudiant.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'dalloz-revues.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'editions-legislatives.fr'">  <!-- boutique El -->
        <xsl:sequence select="(true(), matches($path, '^actualite/[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'efl.fr'">
        <xsl:sequence select="(true(), matches($path, '^(actualite|pratique)/(.*/)?[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = ('efl.fr.s3.amazonaws.com', 'eflfr.s3.eu-west-1.amazonaws.com')">
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'elegia.fr'">  <!-- boutique Formation -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = ('elnet.fr', 'elnet-ce.fr', 'elnet-rh.fr', 'elnet-direction-juridique.fr', 'elnet-expert-comptable.fr', 'elnet-hse.fr')">
        <xsl:sequence select="(true(), matches($path, '^documentation/(Document\?.*id=.+|hulkStatic/(.*/)?[^/]+)$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'esf-editeur.fr'">  <!-- boutique -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'fec-expert.fr'">  <!-- a priori -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'flash.lefebvre-sarrut.eu'">
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'jurisprudencechiffree.efl.fr'">  <!-- a priori -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'lab.efl.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'lappelexpert.fr'">  <!-- a priori -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'lefebvre-sarrut.kbplatform.com'">
        <xsl:sequence select="(true(), matches($path, '^Medias/(.*/)?[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'lemediasocial-emploi.fr'">
        <xsl:sequence select="(true(), matches($path, '^article/.+'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'lemediasocial.fr'">
        <xsl:sequence select="(true(), matches($path, '.+_.+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'librairiedalloz.fr'">  <!-- boutique -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'memento.efl.fr'">  <!-- a améliorer sur un échantillon représentatif -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'pme.efl.fr'">  <!-- boutique -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = ('sim-repo.efl.fr', 'simulateur.efl.fr')"> <!-- calculettes -->
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'tsa-quotidien.fr'">
        <xsl:sequence select="(true(), (matches($path, '^(content|sites/default/files/article-files)/.+') 
          and not(matches($file, '^en-quete-de-sens|voix-haute-0|ntic-et-travail-social|le-travail-social-au-dela-des-frontieres$'))))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'vp.elnet.fr'">
        <xsl:sequence select="(true(), (matches($path, '^aboveille/(cc/)?actucontinue/article(_rg|Guide)?\.do\?attId=\d+.*')
          or matches($path, '^aboveille/logon\.do\?.*zone=(CCACTU|AJACTU).*attId=\d+&amp;forward=view(cc)?article(Guide)?$')
          or matches($path, '^aboveille/editdoc\.do\?.*attId=\d+$')
          or matches($path, '^aboveille/actucontinue/source\.do\?.*docId=\d+.*$')))"/>
      </xsl:when>
      <xsl:when test="$reduced-site = 'wordpress.dalloz.fr'">
        <xsl:sequence select="(true(), false())"/>
      </xsl:when>
      <!-- opmaat.sdu.nl hse.sdu.nl  a priori considérées comme externes ? -->
      <!--====================================-->
      <!-- Not Lefebvre-Dalloz websites -->
      <!--====================================-->
      <!-- legifrance -->
      <xsl:when test="$reduced-site = 'circulaire.legifrance.gouv.fr'"> 
        <xsl:sequence select="(false(), matches($path, '^(pdf/\d+/\d+/[^/]+\.pdf|codes/article_lc/[^/]+)$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site='legifrance.gouv.fr'"> <!-- legifrance -->
        <xsl:sequence select="(false(), matches($path, '(LEGIARTI|LEGITEXT|JORFTEXT|JORFDOLE|JORFARTI|JURITEXT|CETATEXT|CNILTEXT|LEGISCTA|KALICONT)\d+')
          or matches($path, '^eli/(loi|decret|arrete|decision|ordonnance)/(.*/)?jo/(texte|article_\d+)(/fr)?')
          or matches($path, '^jorf/jo(/\d+)+')
          or matches($path, '^download/(file/(.*/JOE_TEXTE|pdf/.*/(BOCC|CIRC))|pdf.*\?id=.+)$'))"/>
      </xsl:when>
      <!-- sites ministeriels -->
      <xsl:when test="$reduced-site='solidarites-sante.gouv.fr'">
        <xsl:sequence select="(false(), matches($path, '^fichiers/bo/\d+/[\d-]+/[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site='travail-emploi.gouv.fr'">
        <xsl:sequence select="(false(), matches($path, '^publications/picts/bo/\d+/\d+/[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site='journal-officiel.gouv.fr'">
        <xsl:sequence select="(false(), matches($path, '^publications/bocc/pdf/\d+/\d+/[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site='justice.gouv.fr'">
        <xsl:sequence select="(false(), matches($path, '^bo/\d+/\d+/[^/]+$'))"/>
      </xsl:when>
      <xsl:when test="$reduced-site='bofip.impots.gouv.fr'">
        <xsl:sequence select="(false(), matches($path, '^bofip/\d+-PGP\.html(/identifiant[^/]+)?$'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="(false(), false())"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>