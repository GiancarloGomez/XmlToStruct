/**
* @output false
*
* Original Script
* Author: Anuj Gakhar
* Last Updated: March 12, 2008 11:04 AM
* Version: 1.0
* http://xml2struct.riaforge.org/
*
* This function converts XML variables into Coldfusion Structures. It also
* returns the attributes for each XML node.
*
* Updated By : Giancarlo Gomez 03/03/2015
* Changed to script and fixed issue when child elements have attributes for each
*/
component {

	/**
	* @hint 	Parse raw XML response body into ColdFusion structs and arrays and return it.
	* @output 	false
	*/
	public struct function convertXmlToStruct(
		required any xmlString,
		struct str = {}
	){
		var i 				= 0;
		var axml 			= arguments.xmlString;
		var astr 			= arguments.str;
		var n 				= "";
		var tmpContainer 	= "";
		var child 			= {};

		// only do search on first request where it comes in as a string
		axml = isSimpleValue(arguments.xmlString) ? XmlSearch(XmlParse(arguments.xmlString),"/node()") : arguments.xmlString;
		axml = axml[1];

		// START : for each children of context node
		for (var i = 1; i <= arrayLen(axml.XmlChildren); i++){

			// Read XML node name without namespace
			n = replace(axml.XmlChildren[i].XmlName, axml.XmlChildren[i].XmlNsPrefix&":", "");

			// If key with that name exists within output struct
			if (structKeyExists(astr, n)){

				// if is not an array
				if (!isArray(astr[n])){
					// get this item into temp variable
					tmpContainer 	= astr[n];
					// setup array for this item beacuse we have multiple items with same name
					// and reassing temp item as a first element of new array
					astr[n] 		= [tmpContainer];
				}

				// recurse call: get complex item
				if (arrayLen(axml.XmlChildren[i].XmlChildren)){
					astr[n][arrayLen(astr[n])+1] = ConvertXmlToStruct(axml.XmlChildren[i]);
				}
				// process node
				else {
					astr[n][arrayLen(astr[n])+1] = processXMLChild(aXml.XmlChildren[i],n);
				}

			}
			// This is not a struct. This may be first tag with some name.
			// This may also be one and only tag with this name.
			else {

				// recurse call: get complex item
				if (arrayLen(axml.XmlChildren[i].XmlChildren)){
					astr[n] = ConvertXmlToStruct(axml.XmlChildren[i]);
				}
				// process node
				else {
					astr[n] = processXMLChild(aXml.XmlChildren[i],n);
				}

			}

		}
		// END : for each children of context node

		return astr;
	}

	/**
	* @hint 	Process a child node and return as a struct if attributes exists for node or as simple string value if not.
	* @output 	false
	*/
	private any function processXMLChild(
		required any element,
		string key = "value"
	){
		var result = "";
		// if there are any attributes on this element
		if (structKeyExists(arguments.element,"XmlAttributes") && isStruct(arguments.element.XmlAttributes) && structCount(arguments.element.XmlAttributes)){

			result = {
				"#arguments.key#" : arguments.element.XmlText
			};

			// get attributes
			attrib_list = structKeylist(arguments.element.XmlAttributes);

			for (var attrib in attrib_list){
				// check if there are no attributes with xmlns: , we dont want namespaces to be in the response
				if(!attrib contains "xmlns:"){
					result[attrib] = arguments.element.XmlAttributes[attrib];
				}
			}

		} else if (structKeyExists(arguments.element,"XmlText")){
			// assign plain value
			result = arguments.element.XmlText;
		}
		// return converted element
		return result;
	}

}
