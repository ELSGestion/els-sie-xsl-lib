<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  exclude-result-prefixes="xs">
  
  <!-- Heavily modified code from the CSS parser by Grit Rolewski -->
  
  <xsl:function name="css:parse-inline" as="element(*)*">
    <xsl:param name="css:inline" as="xs:string*" />
    <xsl:variable name="uncommented-css">
      <!-- On élimine les commentaires -->
      <xsl:analyze-string select="$css:inline" regex="/\*.*?\*/">
        <xsl:matching-substring/>
        <xsl:non-matching-substring>
          <xsl:copy-of select="."/>  
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
  </xsl:function>
  
  <!-- Note: on ne vas pas traitera la partie optionelle en !important car cela ne semble pas utile ici 
       néanmoins, ou pourrait la mettre en attribut si nécessaire -->
  <xsl:template name="declarations">
    <xsl:param name="raw-declarations" />
    <xsl:for-each select="tokenize($raw-declarations, ';\s*')[matches(., '\S')]">
      <xsl:variable name="prop" select="substring-before(., ':')" />
      <xsl:variable name="val" select="replace(normalize-space(substring-after(., ':')), '\s?!important', '')" />
      <xsl:variable name="val-seq" select="tokenize($val, ' ')" />
      <xsl:variable name="vals-count" select="count($val-seq)" />
      <xsl:choose>
        <xsl:when test="normalize-space($prop) = ''">
          <xsl:element name="css:error">Erreur pas de propriété associée à la valeur: "<xsl:value-of select="$val" />"</xsl:element>
        </xsl:when>
        <xsl:when test="$vals-count = 0">
          <xsl:element name="css:error">Erreur pas de valeur associée à la propriété: "<xsl:value-of select="$prop" />"</xsl:element>
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
              <xsl:element name="css:error">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</xsl:element>
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
              <xsl:element name="css:error">Erreur dans la propriété "<xsl:value-of select="$prop" />": <xsl:value-of select="$val" />
              </xsl:element>
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
                <xsl:element name="css:error">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</xsl:element>
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
                <xsl:element name="css:error">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</xsl:element>
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
                <xsl:element name="css:error">Erreur dans la propriété "<xsl:value-of select="$prop" />: <xsl:value-of select="$val" />"</xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </xsl:when>
        
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
        <xsl:when test="matches($css-prop-value, '^([a-z]+)\((.*)\)$')">
          <xsl:analyze-string select="$css-prop-value" regex="^([a-z]+)\((.*)\)$">
            <xsl:matching-substring>
              <xsl:element name="css:{regex-group(1)}">
                <xsl:value-of select="regex-group(2)"/>
              </xsl:element>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="starts-with($css-prop-value, '#')">
          <xsl:element name="css:color"><xsl:value-of select="$css-prop-value"/></xsl:element>
        </xsl:when>
        <xsl:when test="contains($css-prop-value,':')">
          <xsl:element name="css:error">invalid style-value found: <xsl:value-of select="$css-prop-value"/></xsl:element>
        </xsl:when>
        <xsl:when test="not(matches($css-prop-value,$css-prop-name-pattern))">
          <xsl:element name="css:error">invalid style-value found: <xsl:value-of select="$css-prop-value"/></xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="css:{$css-prop-value}"/>                                            
        </xsl:otherwise>            
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
  
  
  <xsl:function name="css:definesBorderRight" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-right-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:definesBorderLeft" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-left-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:definesBorderBottom" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-bottom-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:definesBorderTop" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:choose>
      <xsl:when test="$css//css:border-top-style"><xsl:sequence select="true()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="false()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderTop" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:variable name="style" select="
      $css/(css:border-top-style-ruleset, css:border-top-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-top-style"/>
    <xsl:variable name="width" select="
      $css/(css:border-top-width-ruleset, css:border-top-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-top-width"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="$style[1]/(css:none, css:hidden)">
        <xsl:copy-of select="false()"/>
      </xsl:when>
      <xsl:when test="$width[1]/css:dimension">
        <xsl:choose>
          <xsl:when test="number($width[1]/css:dimension) &gt; 0">
            <xsl:copy-of select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$width[1]">
        <xsl:copy-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderBottom" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:variable name="style" select="
      $css/(css:border-bottom-style-ruleset, css:border-bottom-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-bottom-style"/>
    <xsl:variable name="width" select="
      $css/(css:border-bottom-width-ruleset, css:border-bottom-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-bottom-width"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="$style[1]/(css:none, css:hidden)">
        <xsl:copy-of select="false()"/>
      </xsl:when>
      <xsl:when test="$width[1][self::css:dimension]">
        <xsl:choose>
          <xsl:when test="xs:integer($width[1]/node()) &gt; 0">
            <xsl:copy-of select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$width[1]">
        <xsl:copy-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderRight" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:variable name="style" select="
      $css/(css:border-right-style-ruleset, css:border-right-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-right-style"/>
    <xsl:variable name="width" select="
      $css/(css:border-right-width-ruleset, css:border-right-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-right-width"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="$style[1]/(css:none, css:hidden)">
        <xsl:copy-of select="false()"/>
      </xsl:when>
      <xsl:when test="$width[1][self::css:dimension]">
        <xsl:choose>
          <xsl:when test="xs:integer($width[1]/node()) &gt; 0">
            <xsl:copy-of select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$width[1]">
        <xsl:copy-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="css:showBorderLeft" as="xs:boolean">
    <xsl:param name="css" as="element(css:css)"/>
    <xsl:variable name="style" select="
      $css/(css:border-left-style-ruleset, css:border-left-ruleset, css:border-style-ruleset, css:border-ruleset)/css:border-left-style"/>
    <xsl:variable name="width" select="
      $css/(css:border-left-width-ruleset, css:border-left-ruleset, css:border-width-ruleset, css:border-ruleset)/css:border-left-width"/>
    <xsl:choose>
      <!-- specific settings for border-bottom overwrite general -->
      <xsl:when test="$style[1]/(css:none, css:hidden)">
        <xsl:copy-of select="false()"/>
      </xsl:when>
      <xsl:when test="$width[1][self::css:dimension]">
        <xsl:choose>
          <xsl:when test="xs:integer($width[1]/node()) &gt; 0">
            <xsl:copy-of select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$width[1]">
        <xsl:copy-of select="true()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
</xsl:stylesheet>