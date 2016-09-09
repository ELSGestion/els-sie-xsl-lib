<?xml version="1.0" encoding="UTF-8"?>
<schema 
  xmlns="http://purl.oclc.org/dsdl/schematron" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:local="checkXSLTstyle.sch" 
  queryBinding="xslt2" 
  id="checkXSLTstyle"
  >
  
  <!--TODO : 
    - voir : https://google.github.io/styleguide/xmlstyle.html
    - http://blog.xml.rocks/xslt-naming-conventions
    - http://blog.xml.rocks/structuring-xslt-code
    - distinguer l'utilisation de template nommés (création d'éléments) / function (renvois valeurs atomiques)
    - ordre des template (copy template à la fin, groupement des modes)
    - template inutiles (match=/ apply-template)
    - utilisation de value-of au lieu de sequence ?
    - écriture : 
      - indentation avec espace 
      - pas de saut de ligne dans les templates
      - espace devant les opérateurs ( =, +, > etc)
      
  -->
    
  <!--<xsl:include href="../../developpements/commun/lib/efl-common.xsl"/>-->
  
  <ns prefix="xsl" uri="http://www.w3.org/1999/XSL/Transform"/>
  <ns prefix="xd" uri="http://www.oxygenxml.com/ns/doc/xsl"/>
  <ns prefix="els" uri="http://els.eu/ns/els"/>
  <ns prefix="saxon" uri="http://saxon.sf.net/"/>
  <ns prefix="local" uri="checkXSLTstyle.sch"/>
  
  <xsl:key name="getElementById" match="*" use="@id"/>
  
  <!--====================================-->
  <!--            DIAGNOSTICS             -->
  <!--====================================-->
  
  <diagnostics>
    <diagnostic id="addType">Add @as attribute</diagnostic>
  </diagnostics>
  
  <!--====================================-->
  <!--              PHASE                 -->
  <!--====================================-->
  
  <!--<phase id="test">
		<active pattern="common"/>
	</phase>-->

  <!--====================================-->
  <!--              MAIN                 -->
  <!--====================================-->
  
  <!--cf. http://gandhimukul.tripod.com/xslt/xslquality.html-->
  <!--TODO : implémenter les exemples avec quickFix ou diagnostic ?
  http://www.schematron-quickfix.com/quickFix/guide.html-->
  <pattern id="xslqual">
    <!--Rules that has not been reproduced, not usefull
      - xslqual-NullOutputFromStylesheet
      - xslqual-DontUseNodeSetExtension
      - xslqual-ShortNames
      - xslqual-NameStartsWithNumeric
    -->
    <rule context="xsl:stylesheet">
      <assert id="xslqual-RedundantNamespaceDeclarations"
        test="every $s in in-scope-prefixes(.)[not(. = 'xml' or . = '')] satisfies 
        exists(//(*[not(xsl:stylesheet)] | @*[not(parent::xsl:*)] | @select[parent::xsl:*] 
        | @as | @name[parent::xsl:*])[starts-with(name(), concat($s, ':')) 
        or starts-with(., concat($s, ':'))])" 
        role="warning">
        <!--[xslqual] There are redundant namespace declarations in the xsl:stylesheet element-->
        [xslqual] There namespace prefixes that are declared in the xsl:stylesheet element but never used anywhere 
      </assert>
      <!--<report id="xslqual-TooManySmallTemplates"
        test="count(//xsl:template[@match and not(@name)][count(*) &lt; 3]) &gt;= 10"
        role="warning">
        [xslqual] Too many low granular templates in the stylesheet (10 or more)
      </report>-->
      <report id="xslqual-MonolithicDesign" 
        test="count(//xsl:template | //xsl:function) = 1" 
        role="warning">
        [xslqual] Using a single template/function in the stylesheet. You can modularize the code.
      </report>
      <!--<report id="xslqual-NotUsingSchemaTypes" 
        test="(@version = '2.0') and not(some $x in .//@* satisfies contains($x, 'xs:'))"
        role="warning">
        [xslqual] The stylesheet is not using any of the built-in Schema types (xs:string etc.), when working in XSLT 2.0 mode
      </report>-->
    </rule>
    <rule context="xsl:output">
      <report id="xslqual-OutputMethodXml"
        test="(@method = 'xml') and starts-with(//xsl:template[.//html or .//HTML]/@match, '/')">
        [xslqual] Using the output method 'xml' when generating HTML code
      </report>
    </rule>
    <rule context="xsl:variable">
      <report id="xslqual-SettingValueOfVariableIncorrectly"
        test="(count(*) = 1) and (count(xsl:value-of) = 1)">
        [xslqual] Assign value to a variable using the 'select' syntax if assigning a value with xsl:value-of
      </report>
      <report id="UnusedVariable"
        test="not(some $att in //@* satisfies contains($att, concat('$', @name)))">
        [xslqual] Variable is unused in the stylesheet
      </report>
    </rule>
    <rule context="xsl:param">
      <report id="xslqual-SettingValueOfParamIncorrectly"
        test="(count(*) = 1) and (count(xsl:value-of | xsl:sequence) = 1)">
        [xslqual] Assign value to a parameter using the 'select' syntax if assigning a value with xsl:value-of
      </report>
      <report id="xslqual-UnusedFunctionTemplateParameter"
        test="(parent::xsl:function or parent::xsl:template) and not(some $x in ..//(node() | @*) satisfies contains($x, concat('$', @name)))">
        [xslqual] Function or template parameter is unused in the function/template body
      </report>
    </rule>
    <rule context="xsl:for-each | xsl:if | xsl:when | xsl:otherwise">
      <report id="xslqual-EmptyContentInInstructions" 
        test="(count(node()) = count(text())) and (normalize-space() = '')">
        [xslqual] Don't use empty content for instructions like 'xsl:for-each' 'xsl:if' 'xsl:when' etc.
      </report>
    </rule>
    <rule context="xsl:function">
      <report id="xslqual-UnusedFunction"
        test="not(some $x in //(@match | @select) satisfies contains($x, @name))">
        [xslqual] Stylesheet function is unused
      </report>
      <report id="xslqual-FunctionComplexity"
        test="count(.//xsl:*) &gt; 50">
        Funcrion's size/complexity is high. There is need for refactoring the code.
      </report>
    </rule>
    <rule context="xsl:template">
      <report id="xslqual-UnusedNamedTemplate"
        test="@name and not(@match) and not(//xsl:call-template/@name = @name)">
        [xslqual] Named template in stylesheet in unused
      </report>
      <report id="xslqual-TemplateComplexity"
        test="count(.//xsl:*) &gt; 50"
        role="info">
        [xslqual] Template's size/complexity is high. There is need for refactoring the code.
      </report>
    </rule>
    <rule context="xsl:element">
      <report id="xslqual-NotCreatingElementCorrectly"
        test="not(contains(@name, '$') or (contains(@name, '(') and contains(@name, ')')) or 
        (contains(@name, '{') and contains(@name, '}')))">
        [xslqual] Creating an element node using the xsl:element instruction when could have been possible directly
      </report>
    </rule>
    <rule context="xsl:apply-templates">
      <report id="xslqual-AreYouConfusingVariableAndNode"
        test="some $var in ancestor::xsl:template[1]//xsl:variable satisfies 
        (($var &lt;&lt; .) and starts-with(@select, $var/@name))">
        [xslqual] You might be confusing a variable reference with a node reference
      </report>
    </rule>
    <rule context="@*">
      <report id="xslqual-DontUseDoubleSlashOperatorNearRoot"
        test="local-name(.)= ('match', 'select') and (not(matches(., '^''.*''$')))
        and starts-with(., '//')" role="warning">
        [xslqual] Avoid using the operator // near the root of a large tree
      </report>
      <report id="xslqual-DontUseDoubleSlashOperator"
        test="local-name(.)= ('match', 'select') and (not(matches(., '^''.*''$')))
        and not(starts-with(., '//')) and contains(., '//')" role="warning">
        [xslqual] Avoid using the operator // in XPath expressions
      </report>
      <report id="xslqual-UsingNameOrLocalNameFunction" 
        test="contains(., 'name(') or contains(., 'local-name(')" role="info">
        [xslqual] Using name() function when local-name() could be appropriate (and vice-versa)
      </report>
      <report id="xslqual-IncorrectUseOfBooleanConstants" 
        test="local-name(.)= ('match', 'select') and not(parent::xsl:attribute)
        and ((contains(., 'true') and not(contains(., 'true()'))) or (contains(., 'false') and not(contains(., 'false()'))))">
        [xslqual] Incorrectly using the boolean constants as 'true' or 'false'
      </report>
      <report id="xslqual-UsingNamespaceAxis" 
        test="/xsl:stylesheet/@version = '2.0' and local-name(.)= ('match', 'select') and contains(., 'namespace::')">
        [xslqual] Using the deprecated namespace axis, when working in XSLT 2.0 mode
      </report>
      <!--<report id="xslqual-CanUseAbbreviatedAxisSpecifier" 
        test="local-name(.) = ('match', 'select') and contains(., 'child::') or contains(., 'attribute::') or contains(., 'parent::node()')">
        [xslqual] Using the lengthy axis specifiers like child::, attribute:: or parent::node()
      </report>-->
      <report id="xslqual-UsingDisableOutputEscaping" 
        test="local-name(.) = 'disable-output-escaping' and . = 'yes'">
        [xslqual] Have set the disable-output-escaping attribute to 'yes'. Please relook at the stylesheet logic.
      </report>
    </rule>
  </pattern>
  
  <pattern id="common_els">
    <rule context="/xsl:stylesheet">
      <assert test="xd:doc[@scope = 'stylesheet']">
        [ELS] Please add a documentation block for the whole stylesheet : &lt;xd:doc scope="stylesheet">
      </assert>
    </rule>
    <rule context="xsl:variable | xsl:param">
      <assert test="@as" diagnostics="addType">
        [ELS] <name/> is not typed
      </assert>
    </rule>
    <rule context="xsl:template[@name]">
      <assert test="matches(@name, '^\w+:.*')" role="warning">
        [ELS] Named template should be namespaces prefixed, so they don't generate conflict with imported XSLT
      </assert>
    </rule>
    <rule context="@match | @select">
      <report test="contains(., '*:')">
        [ELS] Use a namespace prefix instead of *:
      </report>
    </rule>
    <rule context="xsl:for-each">
      <report test="ancestor::xsl:template 
        and not(starts-with(@select, '$'))
        and not(matches(@select, '\d'))" 
        role="warning">
        [ELS] Use xsl:apply-template instead of xsl:for-each 
      </report>
    </rule>
    <rule context="xsl:attribute">
      <report id="els-SettingValueOfXslAttributeIncorrectly"
        test="(count(*) = 1) and (count(xsl:value-of | xsl:sequence) = 1)">
        [xslqual] Assign value to an xsl:attribute using the 'select' syntax if assigning a value with xsl:value-of
      </report>
    </rule>
  </pattern>
  
</schema>