<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "XML" utilities</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:import href="els-common_constants.xsl"/>

  <xd:doc>Get the full XML path of any node in an XML with position predicates([n])
    cf. http://www.xsltfunctions.com/xsl/functx_path-to-node-with-pos.html
  </xd:doc>
  <xsl:template match="*" name="els:get-xpath" mode="get-xpath">
    <xsl:param name="node" select="." as="node()"/>
    <xsl:param name="nsprefix" select="''" as="xs:string"/>
    <xsl:param name="display_position" select="true()" as="xs:boolean"/>
    <xsl:variable name="result" as="xs:string*">
      <xsl:for-each select="$node/ancestor-or-self::*">
        <xsl:variable name="id" select="generate-id(.)" as="xs:string"/>
        <xsl:variable name="name" select="name()" as="xs:string"/>
        <xsl:choose>
          <xsl:when test="not(contains($name,':'))">
            <xsl:value-of select="concat('/',if ($nsprefix!='') then (concat($nsprefix,':')) else(''), $name)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('/', $name)"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="../*[name() = $name]">
          <xsl:if test="generate-id(.)=$id and $display_position">
            <!--FIXME : add position() != 1 to get rid of unusfull "[1]" predicates-->
            <xsl:text>[</xsl:text>
            <xsl:value-of select="format-number(position(),'0')"/>
            <xsl:text>]</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:if test="not($node/self::*)">
        <xsl:value-of select="concat('/@',name($node))"/>
      </xsl:if>
    </xsl:variable>
    <xsl:value-of select="string-join($result, '')"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>els:get-xpath return full XML path of the current node</xd:p>
      <xd:p>If saxon:path() is available then it will be used, else we will use the template "els:get-xpath"</xd:p>
    </xd:desc>
    <xd:param name="node">[Node] Node we wan the XML path</xd:param>
    <xd:return>XML path of $node</xd:return>
  </xd:doc>
  <xsl:function name="els:get-xpath" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:choose>
      <xsl:when test="function-available('saxon:path')">
        <xsl:value-of select="saxon:path($node)" use-when="function-available('saxon:path')"/>
        <!--To avoid a saxon warning at compilation time, we plan the case (impossible in this when) of the "inverse" use-when 
        (If not, Saxon will warng of a condition brnanch that could return an empty seq instead of a string-->
        <xsl:value-of select="'This will never happen here'" use-when="not(function-available('saxon:path'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="xpath" as="xs:string">
          <xsl:call-template name="els:get-xpath">
            <xsl:with-param name="node" select="$node" as="node()"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$xpath"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>els:get-xpath with more arguments (call for template els:get-xpath instead of saxon:path)</xd:p>
    </xd:desc>
    <xd:param name="node">[Node] node to get the XML path</xd:param>
    <xd:param name="nsprefix">Adding a prefixe on each path item</xd:param>
    <xd:param name="display_position">Diplay position predicate for each item of the path</xd:param>
    <xd:return>XML path of the $node formated as indicated with $nsprefix and $display_position</xd:return>
  </xd:doc>
  <xsl:function name="els:get-xpath" as="xs:string">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="nsprefix" as="xs:string"/>
    <xsl:param name="display_position" as="xs:boolean"/>
    <xsl:variable name="xpath" as="xs:string">
      <xsl:call-template name="els:get-xpath">
        <xsl:with-param name="node" select="$node" as="node()"/>
        <xsl:with-param name="nsprefix" select="$nsprefix" as="xs:string"/>
        <xsl:with-param name="display_position" select="$display_position" as="xs:boolean"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="string-join(tokenize($xpath,'/'),'/')"/>
  </xsl:function>

  <!--============================-->
  <!--PSEUDO ATTRIBUTES-->
  <!--============================-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Generate xml attribute from a string pseudo attributes</xd:p>
    </xd:desc>
    <xd:param name="str">Any string with pseudo attributes</xd:param>
    <xd:param name="attQuot">Quot used in the pattern to recongnize attributes</xd:param>
    <xd:return>A list of xml attribute, one for each recognized pseudo attribute</xd:return>
  </xd:doc>
  <xsl:function name="els:pseudoAttributes2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:if test="normalize-space($str) != ''">
      <xsl:analyze-string select="$str" regex="([^\s]*)={$attQuot}(.*?){$attQuot}">
        <xsl:matching-substring>
          <xsl:attribute name="{regex-group(1)}" select="regex-group(2)"/>
        </xsl:matching-substring>
      </xsl:analyze-string>
      <!--FIXME : faut-il dissocier le 1er attribut (sans espace devant) des autres ?
      <xsl:analyze-string select="$str" regex="^{$attName}={$attQuot}(.*?){$attQuot}">
        <xsl:matching-substring>
          <xsl:value-of select="regex-group(1)"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:analyze-string select="." regex="\s+{$attName}={$attQuot}(.*?){$attQuot}">
            <xsl:matching-substring>
              <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:non-matching-substring>
      </xsl:analyze-string>-->
    </xsl:if>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:pseudoAttributes2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:sequence select="els:pseudoAttributes2xml($str, $els:dquot)"/>
  </xsl:function>
  
  <!--The same function but for only one attribute name.
  It can return more than one xml attribute in case the string has multiple occurence of the same pseudo attribute-->
  <xsl:function name="els:pseudoAttribute2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:sequence select="els:pseudoAttributes2xml($str, $attQuot)[name(.) = $attName]"/>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:pseudoAttribute2xml" as="attribute()*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="els:pseudoAttribute2xml($str, $attName, $els:dquot)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Get a pseudo attribute value within a string, typicaly a processing-instruction string</xd:p>
      <xd:p>Exemple : els:getPseudoAttributeValue('&lt;?xml version= "1.0" encoding="UTF-8"?>','encoding')='utf-8'</xd:p>
    </xd:desc>
    <xd:param name="str">Any string with pseudo attributes</xd:param>
    <xd:param name="attName">Name of the attribute</xd:param>
    <xd:param name="attQuot">Quot type used in the pseudo attribute (" or ')</xd:param>
    <xd:return>Value of the attribute. 
      If there are multiple attribute with the same name in the string, the it will return several strings of values</xd:return>
  </xd:doc>
  <!--FIXME : il existe une fonction saxon qui fait ça (saxon:getPseudoAttribute)-->
  <xsl:function name="els:getPseudoAttributeValue" as="xs:string*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:for-each select="els:pseudoAttribute2xml($str, $attName, $attQuot)">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:getPseudoAttributeValue" as="xs:string*">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="els:getPseudoAttributeValue($str, $attName, $els:dquot)"/>
  </xsl:function>
  
  <!-- Renvoie true/false si une PI contient un attribut donné -->
  <xsl:function name="els:hasPseudoAttribute" as="xs:boolean">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:param name="attQuot" as="xs:string"/>
    <xsl:sequence select="count(els:pseudoAttribute2xml($str, $attName, $attQuot)) != 0"/>
  </xsl:function>
  
  <!--Default $attQuot is double quot-->
  <xsl:function name="els:hasPseudoAttribute" as="xs:boolean">
    <xsl:param name="str" as="xs:string?"/>
    <xsl:param name="attName" as="xs:string"/>
    <xsl:sequence select="els:hasPseudoAttribute($str, $attName, $els:dquot)"/>
  </xsl:function>
  
  <!--==================-->
  <!--OTHERS XML -->
  <!--==================-->
  
  <xd:doc>Check if a node has a specific ancestor</xd:doc>
  <xsl:function name="els:hasAncestor" as="xs:boolean">
    <xsl:param name="node" as="node()"/>
    <xsl:param name="ancestor" as="element()"/>
    <xsl:sequence select="some $anc in $node/ancestor::* satisfies ($anc is $ancestor)"/>  
  </xsl:function>
  
  <xd:doc>Check if the element has a specific style</xd:doc>
  <xsl:function name="els:hasStyle" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="style" as="xs:string"/>
    <xsl:sequence select="tokenize(normalize-space($e/@style), ';') = normalize-space($style)"/>
  </xsl:function>
  
  <xd:doc>Check if the element has a specific class (several class values might be tested at once)</xd:doc>
  <xsl:function name="els:hasClass" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class" as="xs:string*"/>
    <xsl:sequence select="tokenize($e/@class, '\s+') = $class"/>
  </xsl:function>
  
  <xd:doc>Check if one of the class value of an element matches a specific regex (several class regex might be tested at once)</xd:doc>
  <xsl:function name="els:hasClassMatchingRegex" as="xs:boolean">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class.regex" as="xs:string*"/>
    <xsl:variable name="class.regex.delimited" select="concat('^', $class.regex, '$')" as="xs:string"/>
    <xsl:sequence select="some $class in tokenize($e/@class, '\s+') satisfies matches($class, $class.regex.delimited)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Add a value in class attribute if this value is not already present</xd:p>
      <xd:p>Example of use:
        &lt;xsl:copy>
          &lt;xsl:copy-of select="@*"/> <!--"except @class" is not necessary here it will be overrided-->
          &lt;xsl:attribute name="class" select="els:addClass(., 'myClass')"/>
          &lt;xsl:apply-templates/>
        &lt;/xsl:copy></xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:function name="els:addClass" as="attribute(class)">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="class" as="xs:string"/>
    <xsl:choose>
      <!--If the element has already a class value we want to add, do nothing, keep the attribut as is-->
      <xsl:when test="els:hasClass($e, $class)">
        <xsl:attribute name="class" select="$e/@class"/>
      </xsl:when>
      <!--Else: make a new class attribute with the original class value and the new class added-->
      <xsl:otherwise>
        <xsl:attribute name="class" select="normalize-space(concat($e/@class, ' ', $class))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Delete one class value in a class attribute of the element</xd:p>
    </xd:desc>
    <xd:param name="e">[Element] the element</xd:param>
    <xd:param name="classToRemove">[String] The class value to be removed</xd:param>
    <xd:return>[Attribute]The same class attribute with one removed value</xd:return>
  </xd:doc>
  <xsl:function name="els:removeOneClass" as="attribute(class)?">
    <xsl:param name="e" as="element()"/>
    <xsl:param name="classToRemove" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="els:hasClass($e, $classToRemove)">
        <xsl:attribute name="class" select="string-join(tokenize($e/@class, '\s+')[. != $classToRemove], ' ')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$e/@class"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>Mode to delete indentations</xd:doc>
  <xsl:template match="text()[matches(.,'(\s|\t)*\n(\s|\t)*')]" mode="els:deleteIndentation">
    <xsl:value-of select="replace(.,'(\s|\t)*\n(\s|\t)*', ' ')"/>
  </xsl:template>
  
  <xsl:template match="node() | @*" mode="els:deleteIndentation">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xd:desc>Copy an element and its attributes and "continue" the job in the current mode</xd:desc>
  <xsl:template name="els:copyAndContinue">
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>Generic copy template</xd:doc>
  <xsl:template match="node() | @*" mode="els:copy">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--A template to deal with namespace declaration at root element-->
  <!--param namespaces is a sequences of <els:namespace name="xxx" uri="yyy"/>-->
  <xsl:template match="/*" mode="els:fixNamespaceDeclarations">
    <xsl:param name="namespaces" as="element(els:namespace)*"/>
    <xsl:copy copy-namespaces="no">
      <xsl:for-each select="$namespaces">
        <xsl:namespace name="{@name}" select="@uri"/>  
      </xsl:for-each>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <!--copy template-->
  <xsl:template match="node() | @*" mode="els:fixNamespaceDeclarations" priority="-1">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Display any node (element, attribute, text, pi, etc.) as a readable string</xd:p>
    </xd:desc>
    <xd:param name="node">The node to be displayed</xd:param>
    <xd:return>A textual representation of <xd:ref name="$node" type="parameter">$node</xd:ref></xd:return>
  </xd:doc>
  <xsl:function name="els:displayNode" as="xs:string">
    <xsl:param name="node" as="item()"/>
    <xsl:variable name="tmp" as="xs:string*">
      <xsl:choose>
        <xsl:when test="empty($node)">empty_sequence</xsl:when>
        <xsl:when test="$node/self::*">
          <xsl:text>element():</xsl:text>
          <xsl:value-of select="name($node)"/>
          <xsl:if test="$node/@*">
            <xsl:text>_</xsl:text>
          </xsl:if>
          <xsl:for-each select="$node/@*">
            <xsl:sort/>
            <xsl:value-of select="concat('@',name(),'=',$els:dquot,.,$els:dquot,if (position()!=last()) then ('_') else (''))"/>
          </xsl:for-each>
        </xsl:when>
        <!--FIXME : ce test ne marche pas... ?-->
        <xsl:when test="$node/self::text()">
          <xsl:text>text() </xsl:text>
          <xsl:value-of select="substring($node,1,30)"/>
        </xsl:when>
        <xsl:when test="$node/self::attribute()">
          <xsl:value-of select="'attribute_@' || name($node) || '=' || $els:dquot || $node || $els:dquot"/>
        </xsl:when>
        <xsl:when test="$node/self::comment()">
          <xsl:text>comment() </xsl:text>
          <xsl:value-of select="substring($node,1,30)"/>
        </xsl:when>
        <xsl:when test="$node/self::processing-instruction()">
          <xsl:text>processing-instruction() </xsl:text>
          <xsl:value-of select="substring($node,1,30)"/>
        </xsl:when>
        <xsl:when test="$node/self::document-node()">
          <xsl:text>document-node() </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>unrecognized node type</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="string-join($tmp,'')"/>
  </xsl:function>

  <!-- Application de la fonction saxon:evaluate à un contexte donné, retourne la séquence de noeuds correspondants -->
  <!-- SSI saxon:eval est disponible -->
  <!--Cette écriture est pratique pour certains prédicats où les 2 paramètres sont indépendants-->
  <xd:doc>
    <xd:desc>
      <xd:p>Apply saxon:eval to a given context</xd:p>
    </xd:desc>
    <xd:param name="xpath">[String] xpath to be evaluated</xd:param>
    <xd:param name="e">[Element] Context element</xd:param>
    <xd:return>[item*] result of the evaluation</xd:return>
  </xd:doc>
  <xsl:function name="els:evaluate-xpath" as="item()*">
    <xsl:param name="xpath" as="xs:string"/>
    <xsl:param name="e" as="element()"/>
    <!--<xsl:sequence use-when="function-available('saxon:evaluate')" select="$e/saxon:evaluate($xpath)"/>-->
    <xsl:sequence use-when="function-available('saxon:eval') and function-available('saxon:expression')" 
      select="$e/saxon:eval(saxon:expression($xpath, $e))"/>
    <!--The 2nd argument of saxon:expression permit to define the default namespace-->
    <xsl:message use-when="not(function-available('saxon:eval')) or not(function-available('saxon:expression'))"
      terminate="yes"
      >[FATAL][els-common.xsl] function els:evaluate-xpath() has crashed because saxon:eval (saxon:expression) in not available.
      You must be using SAXON EE or PE to run this function</xsl:message>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Template to do the same thing as saxon:serialize(node, xsl:output/@name) but:
        - can take several nodes (usefull for mixed content)
        - no serialization options, unlike xsl:output</xd:p>
    </xd:desc>
    <xd:param name="nodes">[Nodes] any nodes (typicaly mixed content)</xd:param>
    <xd:param name="copyNS">Determine if we copy namespace declarations on "roots elements" 
      (i.e. elements from <xd:ref name="nodes" type="parameter">$nodes</xd:ref> which have no parent element)</xd:param>
    <!--<xd:param name="format">Name of an xsl:ouput to get serialization options to apply</xd:param>-->
    <xd:return>The XML as a string</xd:return>
  </xd:doc>
  <xsl:function name="els:serialize" as="xs:string">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="copyNS" as="xs:boolean"/>
    <!--<xsl:param name="outputName" as="xs:string"/>-->
    <xsl:variable name="serialize-xml-as-string" as="xs:string*">
      <xsl:apply-templates select="$nodes" mode="els:serialize">
        <!--<xsl:with-param name="outputName" select="$outputName" tunnel="yes" as="xs:string"/>-->
        <xsl:with-param name="copyNSOnRootElements" select="$copyNS" tunnel="yes" as="xs:boolean"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:sequence select="string-join($serialize-xml-as-string, '')"/>
  </xsl:function>
  
  <xd:doc>1 argument signature of els:serialize($nodes as node()*, $copyNS as xs:boolean).
    By default : no copy of the namespace declarations on "roots elements"</xd:doc>
    <!--TODO : $copyNS est à false() par défaut pour conserver un comportement ISO de la signature à 1 argument de la fonction 
                -> voir pour passer sa valeur à true() si pas d'impact.-->
  <xsl:function name="els:serialize" as="xs:string">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:sequence select="els:serialize($nodes,false())"/>
  </xsl:function>
  
  <xd:doc>Mode "els:serialize" for elements</xd:doc>
  <!--TODO : $copyNSOnRootElements conservé avec une valeur par défaut pour rétro-compatibilité (au cas où le template serait appelé en dehors de la fonction).-->
  <xsl:template match="*" mode="els:serialize">
    <xsl:param name="copyNSOnRootElements" tunnel="yes" select="false()" as="xs:boolean"/>
    <!--fixme : utilisation de saxon:serialize ? oui mais il faut passer le output et je n'y arrive pas-->
      <!--<xsl:param name="outputName" required="yes" tunnel="yes" as="xs:string"/>
      <xsl:value-of select="saxon:serialize(., $outputName)"/>-->
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()"/>
      <!-- Copie des déclarations de NS si $copyNSOnRootElements + l'élément n'a pas de parent -->
      <xsl:if test="$copyNSOnRootElements and not(parent::*)">
        <!-- Can't redefine 'xml' prefix (already implicit) -->
        <xsl:for-each select="namespace::node()[name() != 'xml']">
          <xsl:text> xmlns</xsl:text>
          <xsl:if test="name() != ''">
            <xsl:value-of select="concat(':',name())"/>
          </xsl:if>
          <xsl:text>="</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>"</xsl:text>
        </xsl:for-each>
      </xsl:if>
      <xsl:for-each select="@*">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:for-each>
      <xsl:choose>
        <!--auto-fermant-->
        <xsl:when test="empty(node())">
          <xsl:text>/&gt;</xsl:text>
        </xsl:when>
        <!--ou pas-->
        <xsl:otherwise>
          <xsl:text>&gt;</xsl:text>
          <xsl:apply-templates mode="#current"/>
          <xsl:text>&lt;/</xsl:text>
          <xsl:value-of select="name()"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
  <xd:doc>Mode "els:serialize" for text nodes: spaces are normalized</xd:doc>
  <xsl:template match="text()" mode="els:serialize">
    <xsl:if test="starts-with(.,' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:if test="ends-with(.,' ')">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>
  
  <xd:doc>Mode "els:serialize" for comments</xd:doc>
  <xsl:template match="comment()" mode="els:serialize">
    <xsl:text>&lt;!-- </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text> --&gt;</xsl:text>
  </xsl:template>
  
  <xd:doc>Mode "els:serialize" for PI</xd:doc>
  <xsl:template match="processing-instruction()" mode="els:serialize">
    <xsl:text>&lt;?</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>?&gt;</xsl:text>
  </xsl:template>
  
  <!--===============================-->
  <!--GROUP and WRAP XML-->
  <!--===============================-->
  
  <xd:doc>3 args signature of els:wrap-elements-adjacent-by-names()</xd:doc>
  <xsl:function name="els:wrap-elements-adjacent-by-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="adjacent.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:sequence select="els:wrap-elements-adjacent-by-names($context, $adjacent.names, $wrapper, true())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap "adjacent by name" elements into a new  "wrapper" element</xd:p>
      <xd:p>CAUTION : any text, pi, comment within context will be loose</xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the adjacent elements to wrap</xd:param>
    <xd:param name="adjacent.names">sequence of qualified names to set adjacent elements</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context should be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped adjacent element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-adjacent-by-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="adjacent.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:sequence select="els:wrap-elements-adjacent(
      $context,
      function($e) as xs:boolean {name($e) = $adjacent.names},
      $wrapper,
      $keep-context)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap adjacent elements into a new "wrapper" element</xd:p>
      <xd:p>CAUTION : any text, pi, comments within context will be loose</xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the adjacent elements to wrap</xd:param>
    <xd:param name="adjacent.function">Xpath function to set the adjacency condition</xd:param>
    <xd:param name="wrapper">Element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context should be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped adjacent element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-adjacent" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="adjacent.function" as="function(element()) as xs:boolean"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:variable name="content" as="item()*">
      <xsl:for-each-group select="$context/*" group-adjacent="$adjacent.function(.)">
        <xsl:choose>
          <xsl:when test="current-grouping-key()">
            <xsl:copy select="$wrapper">
              <xsl:copy-of select="@*"/>
              <xsl:sequence select="current-group()"/>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="current-group()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$keep-context">
        <xsl:copy select="$context">
          <xsl:copy-of select="@*"/>
          <xsl:sequence select="$content"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>3 args signature of els:wrap-elements-starting-with-names()</xd:doc>
  <xsl:function name="els:wrap-elements-starting-with-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="starts.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:sequence select="els:wrap-elements-starting-with-names($context, $starts.names, $wrapper, true())"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap elements starting with specific names into a new "wrapper" element</xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the elements to wrap</xd:param>
    <xd:param name="starts.names">sequence of names to set starting elements</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context should be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-starting-with-names" as="node()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="starts.names" as="xs:string+"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:sequence select="els:wrap-elements-starting-with(
      $context,
      function($e as element()) as xs:boolean {name($e) = $starts.names}, 
      $wrapper,
      $keep-context)"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>
      <xd:p>Wrap elements starting with specific names into a new "wrapper" element</xd:p>
    </xd:desc>
    <xd:param name="context">Parent of the elements to wrap</xd:param>
    <xd:param name="starts.function">An Xpath function to set the starting group condition</xd:param>
    <xd:param name="wrapper">element wrapper</xd:param>
    <xd:param name="keep-context">Say if the context should be kept or not in the result</xd:param>
    <xd:return>context (or its content) with wrapped element</xd:return>
  </xd:doc>
  <xsl:function name="els:wrap-elements-starting-with" as="element()*">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="starts.function" as="function(element()) as xs:boolean"/>
    <xsl:param name="wrapper" as="element()"/>
    <xsl:param name="keep-context" as="xs:boolean"/>
    <xsl:variable name="content" as="item()*">
      <!--@group-starting-with needs to be converted to boolean as workaround of https://saxonica.plan.io/issues/4636-->
      <xsl:for-each-group select="$context/node()" group-starting-with="*[boolean($starts.function(.))]">
        <xsl:copy select="$wrapper">
          <xsl:copy-of select="@*"/>
          <xsl:sequence select="current-group()"/>
        </xsl:copy>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$keep-context">
        <xsl:copy select="$context">
          <xsl:copy-of select="@*"/>
          <xsl:sequence select="$content"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Check all unordered items of $subsequence is contained in $sequence</xd:p>      
    </xd:desc>
    <xd:param name="subsequence">sequence of items()* to be checked</xd:param>
    <xd:param name="sequence">referential sequence of item()*</xd:param>
    <xd:return>true() is all items are mapped</xd:return>
  </xd:doc>
  <xsl:function name="els:each-subsequence-item-included-into-sequence" as="xs:boolean">
    <xsl:param name="subsequence" as="item()*"/>
    <xsl:param name="sequence" as="item()*"/>
    <xsl:sequence select="every $sub-item in $subsequence satisfies 
      (some $item in $sequence satisfies deep-equal($sub-item, $item))"/>
  </xsl:function>  
 
</xsl:stylesheet>