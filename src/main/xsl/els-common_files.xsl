<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:functx="http://www.functx.com" 
  xmlns:els="http://www.lefebvre-sarrut.eu/ns/els"
  exclude-result-prefixes="#all"
  version="3.0"
  xml:lang="en">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p>ELS-COMMON lib : module "FILES" utilities</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:import href="functx.xsl"/>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Return the file name from an abolute or a relativ path</xd:p>
      <xd:p>If <xd:ref name="filePath" type="parameter">$filePath</xd:ref> is empty it will retunr an empty string (not an empty sequence)</xd:p>
    </xd:desc>
    <xd:param name="filePath">[String] path of the file (typically string(base-uri())</xd:param>
    <xd:param name="withExt">[Boolean] with or without extension</xd:param>
    <xd:return>File name (with or without extension)</xd:return>
  </xd:doc>
  <xsl:function name="els:getFileName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="withExt" as="xs:boolean"/>
    <xsl:choose>
      <!-- An empty string would lead an error in the next when (because of a empty regex)-->
      <xsl:when test="normalize-space($filePath) = ''">
        <xsl:value-of select="$filePath"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="fileNameWithExt" select="functx:substring-after-last-match($filePath,'/')" as="xs:string?"/>
        <xsl:variable name="fileNameNoExt" select="functx:substring-before-last-match($fileNameWithExt,'\.')" as="xs:string?"/>
        <!-- If the fileName has no extension (ex. : "foo"), els:getFileExt() will return renvoie the file name... which is not what expected
        <xsl:variable name="ext" select="concat('.',els:getFileExt($fileNameWithExt))" as="xs:string"/>-->
        <!-- This works with no extension files -> $ext is an empty string here-->
        <xsl:variable name="ext" select="functx:substring-after-match($fileNameWithExt,$fileNameNoExt)" as="xs:string?"/>
        <xsl:sequence select="concat('', $fileNameNoExt, if ($withExt) then ($ext) else (''))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>1arg signature of els:getFileName. Default : extension is on</xd:doc>
  <xsl:function name="els:getFileName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:sequence select="els:getFileName($filePath,true())"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Get the extension of a file from it an absolute or relativ path</xd:p>
      <xd:p>If <xd:ref name="filePath" type="parameter">$filePath</xd:ref> is empty, it will return an empty string (not an empty sequence)</xd:p>
    </xd:desc>
    <xd:param name="filePath">[String] path of the file (typically string(base-uri())</xd:param>
    <xd:return>The file extension if it has one</xd:return>
  </xd:doc>
  <xsl:function name="els:getFileExt" as="xs:string?">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:choose>
      <xsl:when test="not(matches(functx:substring-after-last-match($filePath,'/'), '\.'))">
        <!-- To return an empty string (not an empty sequence) -->
        <xsl:text/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('',functx:substring-after-last-match($filePath,'\.'))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Get the folder path of a file path, level can be specified to have the parg</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:param name="level">Tree level as integer, min = 1 (1 = full path, 2 = full path except last folder, etc.)</xd:param>
    <xd:return>Folder Path as string</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderPath" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:variable name="level.normalized" as="xs:integer" select="if ($level ge 1) then ($level) else (1)"/>
    <xsl:value-of select="string-join(tokenize($filePath,'/')[position() le (last() - $level.normalized)],'/')"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>1 arg Signature of els:getFolderPath(). Default is to get the full folder path to the file (level = 1)</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:return>Full folder path of the file path</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderPath" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:sequence select="els:getFolderPath($filePath,1)"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>Get the folder name of a file path</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:param name="level">Tree level as integer, min = 1 (1 = parent folder of the file, 2 = "grand-parent-folderName", etc.)</xd:param>
    <xd:return>The folder name of the nth parent folder of file</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:param name="level" as="xs:integer"/>
    <xsl:variable name="level.normalized" as="xs:integer" select="if ($level ge 1) then ($level) else (1)"/>
    <xsl:value-of select="tokenize($filePath,'/')[last() - $level.normalized]"/>
  </xsl:function>

  <xd:doc>
    <xd:desc>
      <xd:p>1 arg signature of els:getFolderName()</xd:p>
    </xd:desc>
    <xd:param name="filePath">File path as xs:string (use string(base-uri()) if necessary)</xd:param>
    <xd:return>Name of the parent folder of the file</xd:return>
  </xd:doc>
  <xsl:function name="els:getFolderName" as="xs:string">
    <xsl:param name="filePath" as="xs:string?"/>
    <xsl:value-of select="els:getFolderName($filePath,1)"/>
  </xsl:function>
  
  <!--=========================-->
  <!--RelativeURI-->
  <!--=========================-->
  <!--Adapted from https://github.com/cmarchand/xsl-doc/blob/master/src/main/xsl/lib/common.xsl-->
  <!--FIXME : should parameters be cast as xs:anyUri ??-->
  
  <xd:doc>
    <xd:desc>
      <xd:p>Returns the relative path from a source folder to a target file.</xd:p>
      <xd:p>Both source.folder and target.file must be absolute URI</xd:p>
      <xd:p>If there is no way to walk a relative path from the source folder to the target file, then absolute target file URI is returned</xd:p>
    </xd:desc>
    <xd:param name="source.folder">The source folder URI</xd:param>
    <xd:param name="target.file">The target file URI</xd:param>
    <xd:return>The relative path to walk from source.folder to target.file</xd:return>
  </xd:doc>
  <xsl:function name="els:getRelativePath" as="xs:string">
    <xsl:param name="source.folder" as="xs:string"/>
    <xsl:param name="target.file" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="normalize-space($source.folder) eq ''">
        <xsl:message>[ERROR][els:getRelativePath] $source.folder must not be an empty string</xsl:message>
        <xsl:sequence select="($target.file, '')[1]"/>
      </xsl:when>
      <xsl:when test="normalize-space($target.file) eq ''">
        <xsl:message>[ERROR][els:getRelativePath] $target.file must not be an empty string</xsl:message>
        <xsl:sequence select="($target.file, '')[1]"/>
      </xsl:when>
      <xsl:when test="els:isAbsoluteUri($source.folder)">
        <xsl:choose>
          <xsl:when test="not(els:isAbsoluteUri($target.file))"><xsl:sequence select="string-join((tokenize($source.folder,'/'),tokenize($target.file,'/')),'/')"/></xsl:when>
          <xsl:otherwise>
            <!-- If protocols are differents : return $target -->
            <xsl:variable name="protocol" select="els:getUriProtocol($source.folder)" as="xs:string"/>
            <xsl:choose>
              <xsl:when test="$protocol eq els:getUriProtocol($target.file)">
                <!-- How many identical items are there at the beginning of each uri ?-->
                <xsl:variable name="sourceSeq" select="tokenize(substring(els:normalizeFilePath($source.folder),string-length($protocol) +1),'/')" as="xs:string*"/>
                <xsl:variable name="targetSeq" select="tokenize(substring(els:normalizeFilePath($target.file),string-length($protocol) +1),'/')" as="xs:string*"/>
                <xsl:variable name="nbCommonElements" as="xs:integer" select="els:getNbEqualsItems($sourceSeq, $targetSeq)"/>
                <xsl:variable name="goUpLevels" as="xs:integer" select="count($sourceSeq) - $nbCommonElements"/>
                <xsl:variable name="goUp" as="xs:string*" select="(for $i in (1 to $goUpLevels) return '..')" />
                <xsl:sequence select="string-join(($goUp, subsequence($targetSeq, $nbCommonElements+1)),'/')"></xsl:sequence>
              </xsl:when>
              <xsl:otherwise><xsl:sequence select="$target.file"/></xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="absoluteSource" as="xs:string" select="xs:string(resolve-uri($source.folder))"/>
        <xsl:choose>
          <xsl:when test="els:isAbsoluteUri($absoluteSource)">
            <xsl:sequence select="els:getRelativePath($absoluteSource, $target.file)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>[ERROR][els:getRelativePath] $source.folder="<xsl:value-of select="$source.folder"/>" can not be resolved as an absolute URI</xsl:message>
            <xsl:sequence select="($target.file, '')[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Normalize the URI path. I.E. removes any /./ and folder/.. moves</xd:desc>
    <xd:param name="path">The path to normalize</xd:param>
    <xd:return>The normalized path, as a <tt>xs:string</tt></xd:return>
  </xd:doc>
  <xsl:function name="els:normalizeFilePath" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:sequence select="els:removeLeadingDotSlash(els:removeSingleDot(els:removeDoubleDot($path)))"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Removes single dot in path URI. . are always a self reference, so ./ can always be removed safely</xd:desc>
    <xd:param name="path">The path to remove single dots from</xd:param>
    <xd:return>The clean path, as xs:string</xd:return>
  </xd:doc>
  <xsl:function name="els:removeSingleDot" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="temp" select="replace($path, '/\./','/')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="matches($temp, '/\./')">
        <xsl:sequence select="els:removeSingleDot($temp)"/>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$temp"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Removes the leading "./" from the path</xd:desc>
    <xd:param name="path">The path to clean</xd:param>
    <xd:return>The clean path</xd:return>
  </xd:doc>
  <xsl:function name="els:removeLeadingDotSlash" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="temp" select="replace($path, '^\./','')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="starts-with($temp, './')">
        <xsl:sequence select="els:removeLeadingDotSlash($temp)"/>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$temp"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Removes .. in an URI when it is preceded by a folder reference. So, removes /xxxx/.. </xd:desc>
    <xd:param name="path">The path to clean</xd:param>
    <xd:return>The clean path</xd:return>
  </xd:doc>
  <xsl:function name="els:removeDoubleDot" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="temp" as="xs:string" select="replace($path,'/[^./]*/\.\./','/')"/>
    <xsl:choose>
      <xsl:when test="matches($temp,'/[^./]*/\.\./')">
        <xsl:sequence select="els:removeDoubleDot($temp)"></xsl:sequence>
      </xsl:when>
      <xsl:otherwise><xsl:sequence select="$temp"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Returns true if the provided URI is absolute, false otherwise</xd:desc>
    <xd:param name="path">The URI to test</xd:param>
    <xd:return><tt>true</tt> if the URI is absolute</xd:return>
  </xd:doc>
  <xsl:function name="els:isAbsoluteUri" as="xs:boolean">
    <xsl:param name="path" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$path eq ''">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="matches($path,'[a-zA-Z0-9]+:.*')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Returns the protocol of an URI</xd:desc>
    <xd:param name="path">The URI to check</xd:param>
    <xd:return>The protocol of the URI</xd:return>
  </xd:doc>
  <xsl:function name="els:getUriProtocol" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:variable name="protocol" select="substring-before($path,':')" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="string-length($protocol) gt 0"><xsl:sequence select="$protocol"/></xsl:when>
      <xsl:otherwise><xsl:message>[ERROR][els:protocol] $path="<xsl:value-of select="$path"/>" must be an absolute URI</xsl:message></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Compare pair to pair seq1 and seq2 items, and returns the numbers of deeply-equals items</xd:desc>
    <xd:param name="seq1">The first sequence</xd:param>
    <xd:param name="seq2">The second sequence</xd:param>
  </xd:doc>
  <xsl:function name="els:getNbEqualsItems" as="xs:integer">
    <xsl:param name="seq1" as="item()*"/>
    <xsl:param name="seq2" as="item()*"/>
    <xsl:choose>
      <xsl:when test="deep-equal($seq1[1],$seq2[1])">
        <xsl:sequence select="els:getNbEqualsItems(els:tail($seq1), els:tail($seq2))+1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--FIXME : utiliser la fonction tail native en xpath3.0 (https://www.w3.org/TR/xpath-functions-30/#func-tail)-->
  <xsl:function name="els:tail" as="item()*">
    <xsl:param name="seq" as="item()*"/>
    <xsl:sequence select="subsequence($seq, 2)"/>
  </xsl:function>
 
</xsl:stylesheet>