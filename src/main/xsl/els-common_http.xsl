<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  xmlns:xslLib="http://www.lefebvre-sarrut.eu/ns/els/xslLib"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <!--Variable that helps checking dependency to ensure this XSLT is loaded (especially usefull to test XSLT mode avaiable-->
  <xsl:variable name="xslLib:els-common_http.available" select="true()" static="true"/>
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "HTTP" utilities</xd:p>
    </xd:desc>
  </xd:doc>
   
  <xd:doc >
    <xd:desc>
      <xd:p>
        Extracts a parameter value from an URL using the
        <xd:i>application/x-www-form-urlencoded</xd:i> format
      </xd:p>
      <xd:p>This function assumes that the Query String is well-formed.</xd:p>
    </xd:desc>
    <xd:param name="url">The URL to extract the param from</xd:param>
    <xd:param name="param">The name of parameter to extract value</xd:param>
    <xd:return>The value of the parameter.</xd:return>
  </xd:doc>
  <xsl:function name="els:http-get-param" as="xs:string?">
    <xsl:param name="url" as="xs:string" />
    <xsl:param name="param" as="xs:string" />
    <xsl:variable name="query-string" as="xs:string" select="els:http-get-query-string($url)"/>   
    <xsl:variable name="params-sequence" select="tokenize($query-string,'&amp;')" ></xsl:variable>
    <xsl:variable name="required-param-string" select="$params-sequence[starts-with(.,$param)]" />
    <xsl:variable name="required-param-value" select="tokenize($required-param-string,'=')[2]"/>   
    <xsl:sequence select="$required-param-value" />
  </xsl:function>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Return the resource path from an URL </xd:p>
      <xd:p>For the given URL : <xd:pre>http://foo.bar/baz/some/page.html</xd:pre>,
        the path is <xd:pre>baz/some/page.html</xd:pre></xd:p>
    </xd:desc>
    <xd:param name="url">The input URL</xd:param>
  </xd:doc>
  <xsl:function name="els:http-get-path" as="xs:string?">
    <xsl:param name="url" as="xs:string" />
    <xsl:variable name="plain-url" select="tokenize($url,'(https?:)?//')[2]"/>
    <xsl:variable name="path-and-query" select="substring-after($plain-url,'/')" />
    <xsl:sequence select="tokenize($path-and-query,'\?')[1]" />
  </xsl:function>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Return the resource file from an URL </xd:p>
      <xd:p>For the given URL : <xd:pre>http://foo.bar/baz/some/page.html</xd:pre>,
        the file is <xd:pre>page.html</xd:pre></xd:p>
    </xd:desc>
    <xd:param name="url">The input URL</xd:param>
  </xd:doc>
  <xsl:function name="els:http-get-file" as="xs:string?">
    <xsl:param name="url" as="xs:string"/>
    <xsl:variable name="query" select="tokenize(els:http-get-path($url), '/')[last()]"/>
    <xsl:variable name="filename" select="
      if (matches($query, '^[\w,\s_-]+\.[A-Za-z]{3,4}$')) then $query
      else ''"/>
    <xsl:sequence select="$filename"/>
  </xsl:function>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Return the host name from an URL </xd:p>
      <xd:p>For the given URL : <xd:pre>http://foo.bar:9090/baz?p1=v1&amp;p2=v2</xd:pre>,
        the host name is <xd:pre>foo.bar</xd:pre></xd:p>
    </xd:desc>
    <xd:param name="url">The input URL</xd:param>
  </xd:doc>
  <xsl:function name="els:http-get-host" as="xs:string?">
    <xsl:param name="url" as="xs:string" />
    <xsl:variable name="plain-url" select="tokenize($url,'(https?:)?//')[2]"/>
    <xsl:variable name="host-and-port" select="tokenize($plain-url,'/')[1]"/>   
    <xsl:sequence select="tokenize($host-and-port,':')[1]" />
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Return the port number of an URL if it is specified (Empty sequence otherwise) </xd:p>
      <xd:p>For the given URL : <xd:pre>http://foo.bar:9090/baz?p1=v1&amp;p2=v2</xd:pre>,
        the port number is <xd:pre>9090</xd:pre></xd:p>
    </xd:desc>
    <xd:param name="url">The input URL</xd:param>
  </xd:doc>
  <xsl:function name="els:http-get-port" as="xs:string?">
    <xsl:param name="url" as="xs:string" />
    <xsl:variable name="plain-url" select="tokenize($url,'(https?:)?//')[2]"/>
    <xsl:variable name="host-and-port" select="tokenize($plain-url,'/')[1]"/>
    <xsl:sequence select="tokenize($host-and-port,':')[2]" />
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Return the query string of an URL</xd:p>
      <xd:p>For the given URL : <xd:pre>http://foo.bar/baz?p1=v1&amp;p2=v2</xd:pre>,
        the query-string is <xd:pre>p1=v1&amp;p2=v2</xd:pre></xd:p>
    </xd:desc>
    <xd:param name="url">The input URL</xd:param>
  </xd:doc>
  <xsl:function name="els:http-get-query-string" as="xs:string?">
    <xsl:param name="url" as="xs:string" />
    <xsl:sequence select="substring-after(tokenize($url,'/')[last()],'?')"/>
  </xsl:function>
 
</xsl:stylesheet>