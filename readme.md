# XSL COMMON LIBRARY

This repo contains generics XSLT libraries XSLT.
They must not have no relationship with any specific ELS project !
They can only be linked to any official XML technology (cals, css, etc.)

There are 2 libraries types :

* Libraries (eg. `els-common.xsl`) that offers a set of functions, named
  templates and variables : they need a specific namespace prefix so they
  can be called widthout conflicts from any other XSLT.
* Libraries (eg. `cals2html.xsl`) that implement a full specific treatment:
  they need a specific initial mode (-im in saxon) so they can be called
  widthout conflicts from any other XSLT.

## Set of functions libraries

* `els-common.xsl` : Common library of XSLT functions, templates and variables.

  The file is group by theme : 
  
    * COMMON VAR
    * DATE
    * STRING
    * XML
    * FILE
    * MATH and NUMBERS

* `functx.xsl` : This is a common library from http://www.xsltfunctions.com/

* `css-parser.xsl` : This library is linked to `html2cals.xsl`, it helps
  parsing the css style attributes.

* `rng-common.xsl` : Library that helps parsing Relax NG schema

## Treatment libraries

* `cals2html.xsl` : Converts any CALS table to HTML table.

    The CALS table elements in the xml document must be in CALS namespace
    (`http://docs.oasis-open.org/ns/oasis-exchange/table`)
    Other elements are copied as is.

* `html2cals.xsl` : Converts as CALS table any HTML table within an XML/XHTML document.
    
    The HTML table elements in the xml document must be in HTML namespace
    ("`http://www.w3.org/1999/xhtml`") and the style properties must be within a
    style attribute, not in an external css file. Other elements are copied as is.
  
* [xml2json](xml2json/README.md) : conversion tools for xml to json (may be used as standalone treatment XSLT or library)
    
    * `xjson2json.xsl` : convert any valid XJSON (w3c XML representation of JSON) to json
    * `anyXML2json.xsl` : tries to convert any XML element to JSON.

        When the XML element is not convertable, an error is raised. One then, need to add ovrerides rule to make the appropriate JSON.
    
    * `xvrl2xjson.xsl` : overriding XSLT to anyXML2json.xsl that treats the XVRL format as input

        XVRL is a XML Validation Report Language : `els-models:/els-models/xvrl/xvrl.rng`

