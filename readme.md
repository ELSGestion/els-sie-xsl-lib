# XSL COMMON LIBRARY

This repo contains generics XSLT libraries XSLT.
They must not have no relationship with any specific ELS project !
They can only be linked to any official XML technology (cals, css, etc.)

There are 2 libraries types:

* Libraries (eg. `els-common.xsl`) that offers a set of functions, named
  templates and variables: they need a specific namespace prefix so they
  can be called widthout conflicts from any other XSLT.
* Libraries (eg. `cals2html.xsl`) that implement a full specific treatment:
  they need a specific initial mode (-im in saxon) so they can be called
  widthout conflicts from any other XSLT.

## XSL Documentation

This Maven project is build by jenkins which generates a [site](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site) 

#### Common utilies

* [`functx.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/functx.html)
* [`els-common.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common.html)

    * [`els-common_constants.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common_constants.html)
    * [`els-common_dates.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common_dates.html)
    * [`els-common_strings.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common_strings.html)
    * [`els-common_xml.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common_xml.html)
    * [`els-common_files.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common_files.html)
    * [`els-common_convert-cast.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-common_convert-cast.html)

* [setXmlBase.xsl](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/setXmlBase.html)
* [removeXmlBase.xsl](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/removeXmlBase.html)

#### Log utilities

* [els-log.xsl](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/els-log.html)

#### XSPEC utilities

* [`xspec.simulate.xhtml-output.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/xspec.simulate.xhtml-output.html)

#### TABLES utilies

* [`html2cals.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/html2cals.html)
* [`cals2html.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/cals2html.html)
* [`html4Table2html5Table.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/html4Table2html5Table.html)
* [`normalizeCalsTable.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/normalizeCalsTable.html)

#### Relax NG utilies 

* [`rng-common.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/rng-common.html)
* [`rng2srng.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/rng2srng.html)

#### JSON utilies

* [`anyXML2json.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/anyXML2json.html)
* [`xjson2json.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/xjson2json.html)
* [`xvrl2xjson.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/xvrl2xjson.html)
* [`xvrl2xjson.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/xvrl2xjson.html)

#### CSS utilities

* [`css-parser.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/css-parser.html)

#### Other utilities
* [`nest-titles.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/nest-titles.html)
* [`nest-html-titles.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/nest-html-titles.html)
* [`xml2simpleHtml.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/xml2simpleHtml.html)
* [`fixMsvErrorWhenConvertingXSD2RNG.xsl`](http://srvicprd:8080/view/Libs/job/SIE-LIB-XSL-COMMON_BUILD/site/xsldoc/fixMsvErrorWhenConvertingXSD2RNG.html)


## Set of functions libraries

* `els-common.xsl`: Common library of XSLT functions, templates and variables.

  The file is splitted into 6 submodules: 
  
    * COMMON VAR
    * DATE
    * STRING
    * XML
    * FILE
    * MATH and NUMBERS

    Each modules might be used independantly.

* `functx.xsl`: This is a common library from http://www.xsltfunctions.com/

* `css-parser.xsl`: This library is linked to `html2cals.xsl`, it helps
  parsing the css style attributes.

* `rng-common.xsl`: Library that helps parsing Relax NG schema

## Treatment libraries

* `cals2html.xsl`: Converts any CALS table to HTML table.

    The CALS table elements in the xml document must be in CALS namespace
    (`http://docs.oasis-open.org/ns/oasis-exchange/table`)
    Other elements are copied as is.

* `html2cals.xsl`: Converts as CALS table any HTML table within an XML/XHTML document.
    
    The HTML table elements in the xml document must be in HTML namespace
    ("`http://www.w3.org/1999/xhtml`") and the style properties must be within a
    style attribute, not in an external css file. Other elements are copied as is.
  
* [xml2json](https://bitbucket.org/elsgestion/sie-lib-xsl-common/src/305270397bf24ce466bc5be804fe91ac3f6eefdd/src/main/xsl/xml2json/?at=master): conversion tools for xml to json (may be used as standalone treatment XSLT or library)
    
    * `xjson2json.xsl`: convert any valid XJSON (w3c XML representation of JSON) to json
    * `anyXML2json.xsl`: tries to convert any XML element to JSON.

        When the XML element is not convertable, an error is raised. One then, need to add ovrerides rule to make the appropriate JSON.
    
    * `xvrl2xjson.xsl`: overriding XSLT to anyXML2json.xsl that treats the XVRL format as input

        XVRL is a XML Validation Report Language: `els-models:/els-models/xvrl/xvrl.rng`

* `nest-titles.xsl`: a generic XSLT aiming at nesting title in an XML document
  
    * `nest-html-titles.xsl`: is an example of using the generic XSLT. It needs to implement 2 interfaces (a function and a template).
