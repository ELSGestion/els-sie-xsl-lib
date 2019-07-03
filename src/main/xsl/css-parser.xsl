<xsl:stylesheet version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  exclude-result-prefixes="xs">
  
  <xd:doc  scope="stylesheet">
    <xd:desc>
      <xd:p>CSS parser by Grit Rolewskim heavily modified by ELS</xd:p>
      <xd:p>The xml css representation looks like this :
        <css:css xmlns:css="http://www.w3.org/1996/css">
          <css:border-right-ruleset>
            <css:border-right-width>
              <css:dimension unit="px">1</css:dimension>
            </css:border-right-width>
            <css:border-right-style>
              <css:solid/>
            </css:border-right-style>
          </css:border-right-ruleset>
          <css:border-bottom-ruleset>
            <css:border-bottom-width>
              <css:dimension unit="px">1</css:dimension>
            </css:border-bottom-width>
            <css:border-bottom-style>
              <css:solid/>
            </css:border-bottom-style>
          </css:border-bottom-ruleset>
          <css:border-left-color>
            <css:black/>
          </css:border-left-color>
          <css:text-align-ruleset>
            <css:text-align>
              <css:left/>
            </css:text-align>
          </css:text-align-ruleset>
          <css:padding-right-ruleset>
            <css:padding-right>
              <css:dimension unit="px">0</css:dimension>
            </css:padding-right>
          </css:padding-right-ruleset>
          <css:padding-ruleset>
            <css:padding>
              <css:dimension unit="px">0</css:dimension>
            </css:padding>
          </css:padding-ruleset>
          <css:width-ruleset>
            <css:width>
              <css:dimension unit="%">100</css:dimension>
            </css:width>
          </css:width-ruleset>
        </css:css>
      </xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:function name="css:parse-inline" as="element(*)*">
    <xsl:param name="css:inline" as="xs:string*" />
    <xsl:choose>
      <xsl:when test="empty($css:inline)"/>
      <xsl:otherwise>
        <xsl:variable name="uncommented-css">
          <!-- On élimine les commentaires -->
          <xsl:analyze-string select="$css:inline" regex="/\*.*?\*/">
            <xsl:matching-substring/>
            <xsl:non-matching-substring>
              <xsl:value-of select="."/>  
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="declaration-block" select="if (contains($uncommented-css, '{')) then $uncommented-css else concat('{', $uncommented-css, '}')"/>
        <xsl:element name="css:css">
          <xsl:for-each select="tokenize(normalize-space($declaration-block), '\}')[matches(., '\S')]">
            <xsl:choose>
              <!-- On ne traite pas les déclarations at-rules : -->
              <xsl:when test="matches(normalize-space(.), '^@')"/>
              <!-- On ne traite pas les déclarations avec classe : -->
              <xsl:when test="matches(normalize-space(.), '^\.')"/>
              <!-- On ne traite pas les déclarations avec pseudo-classe : -->
              <xsl:when test="matches(normalize-space(.), '^:')"/>
              <xsl:otherwise>
                <xsl:call-template name="declarations">
                  <xsl:with-param name="raw-declarations" select="normalize-space(substring-after(., '{'))" />
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Note: on ne vas pas traiter la partie optionelle en !important car cela ne semble pas utile ici 
       néanmoins, ou pourrait la mettre en attribut si nécessaire -->
  <xsl:template name="declarations">
    <xsl:param name="raw-declarations" />
    <xsl:for-each select="tokenize($raw-declarations, ';\s*')[matches(., '\S')]">
      <xsl:variable name="prop" select="substring-before(., ':')" as="xs:string"/>
      <xsl:variable name="val" select="substring-after(., ':') => normalize-space() => replace('\s?!important', '') => replace('rgb\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)', 'rgb($1,$2,$3)')" as="xs:string"/>
      <xsl:variable name="val-seq" select="tokenize($val, ' ')" as="xs:string*"/>
      <xsl:variable name="vals-count" select="count($val-seq)" as="xs:integer"/>
      <xsl:choose>
        <xsl:when test="normalize-space($prop) = ''">
          <css:error code="ERROR-1">Erreur pas de propriété associée à la valeur: "<xsl:value-of select="$val" />"</css:error>
        </xsl:when>
        <xsl:when test="$vals-count = 0">
          <css:error code="ERROR-2">Erreur pas de valeur associée à la propriété: "<xsl:value-of select="$prop" />"</css:error>
        </xsl:when>
        <xsl:when test="$prop='border'">
          <xsl:choose>
            <xsl:when test="$vals-count le 3">
              <xsl:element name="css:{$prop}-ruleset">
                <xsl:call-template name="border-vals">
                  <xsl:with-param name="all-pos" select="'top right bottom left'" />
                  <xsl:with-param name="val" select="$val" />
                </xsl:call-template>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <css:error code="ERROR-3">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</css:error>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$prop=('border-style', 'border-width')">
          <xsl:variable name="new-props">
            <props count="1"><top seq="1" /><right seq="1" /><bottom seq="1" /><left seq="1" /></props>
            <props count="2"><top seq="1" /><right seq="2" /><bottom seq="1" /><left seq="2" /></props>
            <props count="3"><top seq="1" /><right seq="2" /><bottom seq="3" /><left seq="2" /></props>
            <props count="4"><top seq="1" /><right seq="2" /><bottom seq="3" /><left seq="4" /></props>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$vals-count le 4">
              <xsl:element name="css:{$prop}-ruleset">
                <xsl:for-each select="$new-props/props[number(@count) eq $vals-count]/*">
                  <xsl:element name="css:{concat(replace($prop, '-.*$', ''), '-', name(), substring-after($prop, 'border'))}" >
                    <xsl:copy-of select="css:build-generic-values($val-seq[position() eq number(current()/@seq)])" />
                  </xsl:element>
              </xsl:for-each>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <css:error code="ERROR-4">Erreur dans la propriété "<xsl:value-of select="$prop" />": <xsl:value-of select="$val" /></css:error>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$prop=('border-top', 'border-left', 'border-bottom', 'border-right')">
          <xsl:element name="css:{$prop}-ruleset">
            <xsl:choose>
              <xsl:when test="$vals-count le 3">
                <xsl:call-template name="border-vals">
                  <xsl:with-param name="all-pos" select="substring-after($prop, 'border-')" />
                  <xsl:with-param name="val" select="$val" />
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <css:error code="ERROR-5">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</css:error>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$prop=('border-top-style', 'border-left-style', 'border-bottom-style', 'border-right-style')">
          <xsl:element name="css:{$prop}-ruleset">
            <xsl:choose>
              <xsl:when test="$vals-count le 1">
                <xsl:element name="css:{$prop}">
                  <xsl:copy-of select="css:build-generic-values($val)" />
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <css:error code="ERROR-6">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</css:error>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$prop=('border-top-width', 'border-left-width', 'border-bottom-width', 'border-right-width')">
          <xsl:element name="css:{$prop}-ruleset">
            <xsl:choose>
              <xsl:when test="$vals-count le 1">
                <xsl:element name="css:{$prop}">
                  <xsl:copy-of select="css:build-generic-values($val)" />
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <css:error code="ERROR-7">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</css:error>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:when>
        <!--FIXME : added by mricaud so every property is represented in xml, but why so much complexity here ?-->
        <xsl:otherwise>
          <xsl:element name="css:{$prop}-ruleset">
            <xsl:choose>
              <xsl:when test="$vals-count le 1">
                <xsl:element name="css:{$prop}">
                  <xsl:copy-of select="css:build-generic-values($val)" />
                </xsl:element>
              </xsl:when>
              <xsl:otherwise>
                <css:error code="ERROR-8">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</css:error>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="border-vals">
    <xsl:param name="all-pos" />
    <xsl:param name="val" />
    <xsl:variable name="new-vals">
      <vals>
        <style pos-vals="(none|hidden|dotted|dashed|solid|double|groove|ridge|inset|outset|initial|inherit)" />
        <width pos-vals="(thin|medium|thick|initial|inherit|^[.0-9]+)" />
        <color pos-vals="(transparent|initial|inherit|\(|[a-z]+|#[0-9a-z]+)" />
      </vals>
    </xsl:variable>
    <xsl:for-each select="tokenize($all-pos, '\s+')">
      <xsl:variable name="current-pos" select="." />
      <xsl:for-each select="tokenize(replace($val, ',\s+', ','), '\s+')">
        <xsl:variable name="current-val">
          <xsl:choose>
            <xsl:when test="matches(., $new-vals//style/@pos-vals)">style</xsl:when>
            <xsl:when test="matches(., $new-vals//width/@pos-vals)">width</xsl:when>
            <xsl:when test="matches(., $new-vals//color/@pos-vals)">color</xsl:when>
            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
          <xsl:element name="css:{concat('border-', $current-pos, '-', $current-val)}">
           <xsl:copy-of select="css:build-generic-values(.)" />
            </xsl:element>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="css:build-generic-values" as="element()*">
    <xsl:param name="value-string"/>
    <xsl:variable name="css-prop-name-pattern">^[a-z][a-z0-9\-]+$</xsl:variable>
    <xsl:for-each select="tokenize($value-string, '\s')">
      <xsl:variable name="css-prop-value" select="normalize-space(.)"/>
      <xsl:choose>
        <xsl:when test="matches($css-prop-value, '^(\d+\.?\d*)(cm|mm|in|px|pt|pc|em|ex|ch|rem|vh|vw|vmin|vmax|%)?$')">
          <xsl:analyze-string select="$css-prop-value" regex="^(\d+\.?\d*)(cm|mm|in|px|pt|pc|em|ex|ch|rem|vh|vw|vmin|vmax|%)?$">
            <xsl:matching-substring>
              <xsl:element name="css:dimension">
                <xsl:choose>
                  <xsl:when test="regex-group(2)">
                    <xsl:attribute name="unit" select="regex-group(2)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="unit">px</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="regex-group(1)"/>
              </xsl:element>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="matches($css-prop-value, '^rgb\((\d+),(\d+),(\d+)\)$')">
          <xsl:analyze-string select="$css-prop-value" regex="^rgb\((\d+),(\d+),(\d+)\)">
            <xsl:matching-substring>
              <css:rgb red="{regex-group(1)}" green="{regex-group(2)}" blue="{regex-group(3)}"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="matches($css-prop-value, '^([a-z]+)\((.*)\)$')">
          <xsl:analyze-string select="$css-prop-value" regex="^([a-z]+)\((.*)\)$">
            <xsl:matching-substring>
              <xsl:element name="css:{regex-group(1)}">
                <xsl:value-of select="regex-group(2)"/>
              </xsl:element>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="starts-with($css-prop-value, '#') or matches($css-prop-value, 'rgb\((\d+),(\d+),(\d+)\)')">
          <css:color><xsl:value-of select="$css-prop-value"/></css:color>
        </xsl:when>
        <xsl:when test="contains($css-prop-value,':')">
          <css:error>invalid style-value found: <xsl:value-of select="$css-prop-value"/></css:error>
        </xsl:when>
        <xsl:when test="not(matches($css-prop-value,$css-prop-name-pattern))">
          <css:error>invalid style-value found: <xsl:value-of select="$css-prop-value"/></css:error>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="css:{$css-prop-value}"/>                                            
        </xsl:otherwise>            
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:function name="css:definesBorderRight" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-right-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:definesBorderLeft" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-left-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:definesBorderBottom" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-bottom-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:definesBorderTop" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-top-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderTop" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:variable name="style" select="
      ($css/(css:border-top-style-ruleset, css:border-top-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-top-style)[last()]" as="element()?"/>
    <xsl:variable name="width" select="
      ($css/(css:border-top-width-ruleset, css:border-top-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-top-width)[last()]" as="element()?"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="empty($style) or $style/(css:none, css:hidden)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <!--there is a border-->
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$width/css:dimension = '0'">
            <xsl:sequence select="false()"/>
          </xsl:when>
          <xsl:otherwise>
            <!--there is no width (browsers show border by default in this case)-->
            <xsl:sequence select="true()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderBottom" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:variable name="style" select="
      ($css/(css:border-bottom-style-ruleset, css:border-bottom-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-bottom-style)[last()]" as="element()?"/>
    <xsl:variable name="width" select="
      ($css/(css:border-bottom-width-ruleset, css:border-bottom-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-bottom-width)[last()]" as="element()?"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="empty($style) or $style/(css:none, css:hidden)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <!--there is a border-->
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$width/css:dimension = '0'">
            <xsl:sequence select="false()"/>
          </xsl:when>
          <xsl:otherwise>
            <!--there is no width (browsers show border by default in this case)-->
            <xsl:sequence select="true()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderRight" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:variable name="style" select="
      ($css/(css:border-right-style-ruleset, css:border-right-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-right-style)[last()]" as="element()?" />
    <xsl:variable name="width" select="
      ($css/(css:border-right-width-ruleset, css:border-right-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-right-width)[last()]" as="element()?"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="empty($style) or $style/(css:none, css:hidden)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <!--there is a border-->
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$width/css:dimension = '0'">
            <xsl:sequence select="false()"/>
          </xsl:when>
          <xsl:otherwise>
            <!--there is no width (browsers show border by default in this case)-->
            <xsl:sequence select="true()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderLeft" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:variable name="style" select="
      ($css/(css:border-left-style-ruleset, css:border-left-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-left-style)[last()]" as="element()?"/>
    <xsl:variable name="width" select="
      ($css/(css:border-left-width-ruleset, css:border-left-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-left-width)[last()]" as="element()?"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="empty($style) or $style/(css:none, css:hidden)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <!--there is a border-->
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$width/css:dimension = '0'">
            <xsl:sequence select="false()"/>
          </xsl:when>
          <xsl:otherwise>
            <!--there is no width (browsers show border by default in this case)-->
            <xsl:sequence select="true()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showAllBorders" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:choose>
      <xsl:when test="css:showBorderTop($css) and css:showBorderRight($css) and css:showBorderBottom($css) and css:showBorderLeft($css)">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--=== CSS UTILITIES ===-->
  
  <!--
    FIXME : this is completly wrong, but it works for the cases we have.
    TODO : NEED GLOBAL REFACTORING ! actually the full XSL needs it :
      - take into account every multivalued properties (padding, margin) not only borders
      - parse the css to really get the good values when twice (last one has precedancy) -->
  
  <!--Get the value of a property-->
  <!--If the property doesn't exist return the empty string-->
  <!--FIXME : css:getPropertyValue($style.css, 'background-color') renvoi toujours "color"-->
  <xsl:function name="css:getPropertyValue" as="xs:string">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:variable name="property" select="css:getProperty($css, $name)" as="element()*"/>
    <xsl:choose>
      <!--Single properties values (which may appear several times) or sub-properties (like border-top-style under border-ruleset)-->
      <xsl:when test="count(distinct-values($property/local-name(.))) = 1">
        <xsl:variable name="value" as="xs:string*">
          <xsl:apply-templates select="$property[last()]/css:*" mode="css:parsed-to-string"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space(string-join($value, ''))"/>
      </xsl:when>
      <!--Multivalued property value like padding, border-style -->
      <xsl:otherwise>
        <!--assume : properties are in the good css defined order : top, right, left, right-->
        <xsl:variable name="values" as="xs:string*">
          <xsl:for-each select="$property/*">
            <xsl:variable name="value" as="xs:string?">
              <xsl:apply-templates select="$property/css:*" mode="css:parsed-to-string"/>
            </xsl:variable>
            <xsl:value-of select="normalize-space($value)"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($values, ' ')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:getPropertyName" as="xs:string">
    <xsl:param name="property" as="element(*)"/> <!--ex : <css:text-align-ruleset>-->
    <xsl:sequence select="substring-before(local-name($property), '-ruleset')"/>
  </xsl:function>
  
  <xsl:function name="css:getProperty" as="element()*">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:param name="name" as="xs:string"/>
    <!--<xsl:choose>
      <!-\-Single properties (ruleset property)-\->
      <xsl:when test="$css/css:*[local-name() = concat($name, '-ruleset')]">
        <xsl:sequence select="$css/css:*[local-name() = concat($name, '-ruleset')]"/>
      </xsl:when>
      <!-\-Multivalued property : look sub-properties within ruleset (ex : border-style-ruleset has border-top-style child property)-\->
      <xsl:otherwise>
        <xsl:sequence select="$css/css:*/css:*[local-name() = $name]"/>
      </xsl:otherwise>
    </xsl:choose>-->
    <xsl:sequence select="$css/css:*/css:*[local-name() = $name]"/>
  </xsl:function>
  
  <xsl:function name="css:getProperties" as="element()*">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:sequence select="$css/*"/>
  </xsl:function>
  
  <xsl:function name="css:removeProperties" as="element()*">
    <xsl:param name="css" as="element(css:css)?"/>
    <xsl:param name="properties.names" as="xs:string*"/>
    <xsl:apply-templates select="$css" mode="css:removeProperties">
      <xsl:with-param name="properties.names" select="$properties.names" as="xs:string*" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:function>
  
  <xsl:mode name="css:removeProperties" on-no-match="shallow-copy"/>
  
  <xsl:template match="css:css/*" mode="css:removeProperties">
    <xsl:param name="properties.names" as="xs:string*" tunnel="true"/>
    <!--Assume : the more long is the css property name are the more precise it is : 
    removing "border" will remove border-right, border-bottom, and any border-*-ruleset-->
    <xsl:choose>
      <xsl:when test="some $name in $properties.names satisfies starts-with(local-name(), $name)">
        <!--delete the property-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--==== css:parsed-to-string ====-->
  
  <xd:p>Convert back css:css element to css string</xd:p>
  <xsl:function name="css:parsed-to-string" as="xs:string">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:variable name="css" as="xs:string*">
      <xsl:apply-templates select="$css" mode="css:parsed-to-string"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space(string-join($css, ''))"/>
  </xsl:function>
  
  <!--FIXME : border color is lost here (and border-with / border-style are normalized to 1px solid)--> 
  <xsl:template match="css:css" mode="css:parsed-to-string">
    <xsl:choose>
      <xsl:when test="css:showAllBorders(.)">
        <xsl:text>border:1px solid; </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="css:showBorderLeft(.)">
          <xsl:text>border-left:1px solid; </xsl:text>
        </xsl:if>
        <xsl:if test="css:showBorderRight(.)">
          <xsl:text>border-right:1px solid; </xsl:text>
        </xsl:if>
        <xsl:if test="css:showBorderTop(.)">
          <xsl:text>border-top:1px solid; </xsl:text>
        </xsl:if>
        <xsl:if test="css:showBorderBottom(.)">
          <xsl:text>border-bottom:1px solid; </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="css:*" mode="#current"/>
  </xsl:template>
  
  <!-- Example :
  <css:text-align-ruleset>
    <css:text-align>
      <css:left/>
    </css:text-align>
  </css:text-align-ruleset>
  <css:padding-ruleset>
    <css:padding>
      <css:dimension unit="px">0</css:dimension>
    </css:padding>
  </css:padding-ruleset>
  -->
  
  <xsl:template match="css:*[starts-with(local-name(), 'border')]" mode="css:parsed-to-string" priority="2">
    <!--rulset for border has already been processed in css:css match-->
  </xsl:template>
  
  <xsl:template match="css:*[ends-with(local-name(), '-ruleset')]" mode="css:parsed-to-string" priority="1">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="css:*[ends-with(local-name(), '-ruleset')]/css:*" mode="css:parsed-to-string">
    <xsl:sequence select="concat(local-name(), ':')"/>
    <xsl:apply-templates select="css:*" mode="#current"/>
    <xsl:text>; </xsl:text>
  </xsl:template>
  
  <xsl:template match="css:*[ends-with(local-name(), '-ruleset')]/css:*/css:*" mode="css:parsed-to-string">
    <xsl:sequence select="local-name()"/>
  </xsl:template>
  
  <xsl:template match="css:rgb" mode="css:parsed-to-string" priority="1">
    <xsl:text>rbg(</xsl:text>
    <xsl:value-of select="@red"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@green"/>
    <xsl:text>,</xsl:text>
    <xsl:value-of select="@blue"/>
    <xsl:text>)</xsl:text>
  </xsl:template>
  
  <xsl:template match="css:dimension" mode="css:parsed-to-string" priority="1">
    <xsl:sequence select="concat(text(), @unit)"/>
  </xsl:template>
  
</xsl:stylesheet>