# Converting XML to JSON

The XSLT 3.0 specification add features to convert xml to json and json to xml.

Thoses conversion use an intermediate XML format representating of a JSON file.

XJSON is the name we gave to this format with schema : dependency:/eu.els.sie.models+ext-models/ext-models/w3c/xjson/schema-for-json.xsd


## XML to JSON

XPATH 3.0 defines a function xml-to-json($xjson), we will always use it, even if the W3C propose an XSLT (xml-to-json.xsl) that do the job as well.

NB : this function should be called xjson-to-json() because it doesn't take any XML as argument but only "XJSON" XML.

Using  xml-to-json($xjson) is more convenient than the xml-to-json.xsl.

When converting any XML to JSON, the deal is then only to convert the XML to JSON.

JSON has 3 kind of itemps : 

* map (or objet) : which is a object representation with no name but consist of list of named items (string, boolean, other map/objet, list/array, etc.)
* array (or list) : it's just a list of items, this list has a name.
* properties : string, boolean, etc.

Be carefull : within a map, 2 propertie may not have the same name !

The anyXML2json.xsl has a step that convert any XML to xjson : 

* it make a map for each element 
* and each attribute is converted to a string property

The problem with element converted to map is that sometimes there are multiple elements with the same name, sometimes it's a unique element.

The XSLT cannot know that : we have to refer to the schema to choose a map or an array.
That's why it's important to override this XSLT with your own choice depending on the XML format.

## JSON to XML

TODO
