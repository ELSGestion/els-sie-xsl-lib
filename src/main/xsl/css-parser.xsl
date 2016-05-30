<?xml version="1.0" encoding="UTF-8"?>
<!--
	# =============================================================================
	# Copyright © 2013 ISO. All rights reserved.
	#
	# $LastChangedRevision: 28276 $
  # $LastChangedDate: 2013-01-24 16:22:27 +0100 (Thu, 24 Jan 2013) $
  #
  # Unless required by applicable law or agreed to in writing, software
	# is distributed on an "as is" basis, without warranties or conditions of any
	# kind, either express or implied.
	# =============================================================================
-->
<!--
	This is a library to parse CSS definitions into XML. The tranformation will convert CSS property
	names and values to element names. For example the CSS definition "border: solid 1px" will be converted into  
	<css:border>
	   <css:solid>
	   <css:dimension unit="px">1</css:dimension>
	</css:border>
	
	Any parsing error will result in a <css:error> element containting the error message.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:css="http://www.iso.org/ns/css-parser" version="2.0">
    <xsl:variable name="css-prop-name-pattern">^[a-z][a-z0-9\-]+$</xsl:variable>
    <xsl:function name="css:parse" as="element(css:css)*">
        <xsl:param name="style"/>
        <css:css>
            <xsl:if test="normalize-space($style)">                
                <xsl:for-each select="tokenize($style, ';')">
                    <xsl:variable name="css-def" select="."/>
                    <xsl:variable name="css-prop-name" select="normalize-space(substring-before($css-def,':'))"/>
                    <xsl:variable name="css-prop-values" select="normalize-space(substring-after($css-def,':'))"/>
                    <xsl:choose>
                        <xsl:when test="not($css-def)">
                            <!-- can be empty due to starting or ending ; -->
                        </xsl:when>
                        <xsl:when test="not($css-prop-values)">
                            <css:error>css property without values: <xsl:value-of select="$css-def"/></css:error>
                        </xsl:when>
                        <xsl:when test="not($css-prop-name)">
                            <css:error>empty css property name found before colon <xsl:value-of select="$css-def"/></css:error>
                        </xsl:when>
                        <xsl:when test="not(matches($css-prop-name,$css-prop-name-pattern))">
                            <css:error>invalid css property name: '<xsl:value-of select="$css-prop-name"/>'</css:error>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="css:{$css-prop-name}">
                                <xsl:choose>
                                    <xsl:when test="$css-prop-name = 'font-family'">
                                        <xsl:copy-of select="css:build-font-family-values($css-prop-values)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="css:build-generic-values($css-prop-values)"/>                                        
                                    </xsl:otherwise>
                                </xsl:choose>                                
                            </xsl:element>                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
        </css:css>
    </xsl:function>
    
    <xsl:function name="css:build-generic-values" as="element()*">
        <xsl:param name="value-string"/>
        <xsl:for-each select="tokenize($value-string, '\s')">
            <xsl:variable name="css-prop-value" select="normalize-space(.)"/>
            <xsl:choose>
                <xsl:when test="matches($css-prop-value, '^(\d+\.?\d*)(px|pt|em)?$')">
                    <xsl:analyze-string select="$css-prop-value" regex="^(\d+\.?\d*)(px|pt|em)?$">
                        <xsl:matching-substring>
                            <css:dimension>
                                <xsl:choose>
                                    <xsl:when test="regex-group(2)">
                                        <xsl:attribute name="unit" select="regex-group(2)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="unit">px</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:value-of select="regex-group(1)"/>
                            </css:dimension>
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
    
    <xsl:function name="css:build-font-family-values" as="element()*">
        <xsl:param name="value-string"/>
        <xsl:for-each select="tokenize($value-string, ',')">
            <css:font name="{.}"/>
        </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>
