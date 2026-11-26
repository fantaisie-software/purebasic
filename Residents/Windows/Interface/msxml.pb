
; IXMLDOMImplementation interface definition
;
Interface IXMLDOMImplementation Extends IDispatch
  hasFeature(a.p-bstr, b.p-bstr, c.l)
EndInterface

; IXMLDOMNode interface definition
;
Interface IXMLDOMNode Extends IDispatch
  get_nodeName(a.l)
  get_nodeValue(a.l)
  put_nodeValue(a.p-variant)
  get_nodeType(a.l)
  get_parentNode(a.l)
  get_childNodes(a.l)
  get_firstChild(a.l)
  get_lastChild(a.l)
  get_previousSibling(a.l)
  get_nextSibling(a.l)
  get_attributes(a.l)
  insertBefore(a.l, b.p-variant, c.l)
  replaceChild(a.l, b.l, c.l)
  removeChild(a.l, b.l)
  appendChild(a.l, b.l)
  hasChildNodes(a.l)
  get_ownerDocument(a.l)
  cloneNode(a.l, b.l)
  get_nodeTypeString(a.l)
  get_text(a.l)
  put_text(a.p-bstr)
  get_specified(a.l)
  get_definition(a.l)
  get_nodeTypedValue(a.l)
  put_nodeTypedValue(a.p-variant)
  get_dataType(a.l)
  put_dataType(a.p-bstr)
  get_xml(a.l)
  transformNode(a.l, b.l)
  selectNodes(a.p-bstr, b.l)
  selectSingleNode(a.p-bstr, b.l)
  get_parsed(a.l)
  get_namespaceURI(a.l)
  get_prefix(a.l)
  get_baseName(a.l)
  transformNodeToObject(a.l, b.p-variant)
EndInterface

; IXMLDOMDocumentFragment interface definition
;
Interface IXMLDOMDocumentFragment Extends IXMLDOMNode
EndInterface

; IXMLDOMDocument interface definition
;
Interface IXMLDOMDocument Extends IXMLDOMNode
  get_doctype(a.l)
  get_implementation(a.l)
  get_documentElement(a.l)
  putref_documentElement(a.l)
  createElement(a.p-bstr, b.l)
  createDocumentFragment(a.l)
  createTextNode(a.p-bstr, b.l)
  createComment(a.p-bstr, b.l)
  createCDATASection(a.p-bstr, b.l)
  createProcessingInstruction(a.p-bstr, b.p-bstr, c.l)
  createAttribute(a.p-bstr, b.l)
  createEntityReference(a.p-bstr, b.l)
  getElementsByTagName(a.p-bstr, b.l)
  createNode(a.p-variant, b.p-bstr, c.p-bstr, d.l)
  nodeFromID(a.p-bstr, b.l)
  load(a.p-variant, b.l)
  get_readyState(a.l)
  get_parseError(a.l)
  get_url(a.l)
  get_async(a.l)
  put_async(a.l)
  abort()
  loadXML(a.p-bstr, b.l)
  save(a.p-variant)
  get_validateOnParse(a.l)
  put_validateOnParse(a.l)
  get_resolveExternals(a.l)
  put_resolveExternals(a.l)
  get_preserveWhiteSpace(a.l)
  put_preserveWhiteSpace(a.l)
  put_onreadystatechange(a.p-variant)
  put_ondataavailable(a.p-variant)
  put_ontransformnode(a.p-variant)
EndInterface

; IXMLDOMNodeList interface definition
;
Interface IXMLDOMNodeList Extends IDispatch
  get_item(a.l, b.l)
  get_length(a.l)
  nextNode(a.l)
  reset()
  get__newEnum(a.l)
EndInterface

; IXMLDOMNamedNodeMap interface definition
;
Interface IXMLDOMNamedNodeMap Extends IDispatch
  getNamedItem(a.p-bstr, b.l)
  setNamedItem(a.l, b.l)
  removeNamedItem(a.p-bstr, b.l)
  get_item(a.l, b.l)
  get_length(a.l)
  getQualifiedItem(a.p-bstr, b.p-bstr, c.l)
  removeQualifiedItem(a.p-bstr, b.p-bstr, c.l)
  nextNode(a.l)
  reset()
  get__newEnum(a.l)
EndInterface

; IXMLDOMCharacterData interface definition
;
Interface IXMLDOMCharacterData Extends IXMLDOMNode
  get_data(a.l)
  put_data(a.p-bstr)
  get_length(a.l)
  substringData(a.l, b.l, c.l)
  appendData(a.p-bstr)
  insertData(a.l, b.p-bstr)
  deleteData(a.l, b.l)
  replaceData(a.l, b.l, c.p-bstr)
EndInterface

; IXMLDOMAttribute interface definition
;
Interface IXMLDOMAttribute Extends IXMLDOMNode
  get_name(a.l)
  get_value(a.l)
  put_value(a.p-variant)
EndInterface

; IXMLDOMElement interface definition
;
Interface IXMLDOMElement Extends IXMLDOMNode
  get_tagName(a.l)
  getAttribute(a.p-bstr, b.l)
  setAttribute(a.p-bstr, b.p-variant)
  removeAttribute(a.p-bstr)
  getAttributeNode(a.p-bstr, b.l)
  setAttributeNode(a.l, b.l)
  removeAttributeNode(a.l, b.l)
  getElementsByTagName(a.p-bstr, b.l)
  normalize()
EndInterface

; IXMLDOMText interface definition
;
Interface IXMLDOMText Extends IXMLDOMCharacterData
  splitText(a.l, b.l)
EndInterface

; IXMLDOMComment interface definition
;
Interface IXMLDOMComment Extends IXMLDOMCharacterData
EndInterface

; IXMLDOMProcessingInstruction interface definition
;
Interface IXMLDOMProcessingInstruction Extends IXMLDOMNode
  get_target(a.l)
  get_data(a.l)
  put_data(a.p-bstr)
EndInterface

; IXMLDOMCDATASection interface definition
;
Interface IXMLDOMCDATASection Extends IXMLDOMText
EndInterface

; IXMLDOMDocumentType interface definition
;
Interface IXMLDOMDocumentType Extends IXMLDOMNode
  get_name(a.l)
  get_entities(a.l)
  get_notations(a.l)
EndInterface

; IXMLDOMNotation interface definition
;
Interface IXMLDOMNotation Extends IXMLDOMNode
  get_publicId(a.l)
  get_systemId(a.l)
EndInterface

; IXMLDOMEntity interface definition
;
Interface IXMLDOMEntity Extends IXMLDOMNode
  get_publicId(a.l)
  get_systemId(a.l)
  get_notationName(a.l)
EndInterface

; IXMLDOMEntityReference interface definition
;
Interface IXMLDOMEntityReference Extends IXMLDOMNode
EndInterface

; IXMLDOMParseError interface definition
;
Interface IXMLDOMParseError Extends IDispatch
  get_errorCode(a.l)
  get_url(a.l)
  get_reason(a.l)
  get_srcText(a.l)
  get_line(a.l)
  get_linepos(a.l)
  get_filepos(a.l)
EndInterface

; IXTLRuntime interface definition
;
Interface IXTLRuntime Extends IXMLDOMNode
  uniqueID(a.l, b.l)
  depth(a.l, b.l)
  childNumber(a.l, b.l)
  ancestorChildNumber(a.p-bstr, b.l, c.l)
  absoluteChildNumber(a.l, b.l)
  formatIndex(a.l, b.p-bstr, c.l)
  formatNumber(a.l, b.p-bstr, c.l)
  formatDate(a.p-variant, b.p-bstr, c.p-variant, d.l)
  formatTime(a.p-variant, b.p-bstr, c.p-variant, d.l)
EndInterface

; XMLDOMDocumentEvents interface definition
;
Interface XMLDOMDocumentEvents Extends IDispatch
EndInterface

; IXMLHttpRequest interface definition
;
Interface IXMLHttpRequest Extends IDispatch
  open(a.p-bstr, b.p-bstr, c.p-variant, d.p-variant, e.p-variant)
  setRequestHeader(a.p-bstr, b.p-bstr)
  getResponseHeader(a.p-bstr, b.l)
  getAllResponseHeaders(a.l)
  send(a.p-variant)
  abort()
  get_status(a.l)
  get_statusText(a.l)
  get_responseXML(a.l)
  get_responseText(a.l)
  get_responseBody(a.l)
  get_responseStream(a.l)
  get_readyState(a.l)
  put_onreadystatechange(a.l)
EndInterface

; IXMLDSOControl interface definition
;
Interface IXMLDSOControl Extends IDispatch
  get_XMLDocument(a.l)
  put_XMLDocument(a.l)
  get_JavaDSOCompatible(a.l)
  put_JavaDSOCompatible(a.l)
  get_readyState(a.l)
EndInterface

; IXMLElementCollection interface definition
;
Interface IXMLElementCollection Extends IDispatch
  put_length(a.l)
  get_length(a.l)
  get__newEnum(a.l)
  item(a.p-variant, b.p-variant, c.l)
EndInterface

; IXMLDocument interface definition
;
Interface IXMLDocument Extends IDispatch
  get_root(a.l)
  get_fileSize(a.l)
  get_fileModifiedDate(a.l)
  get_fileUpdatedDate(a.l)
  get_URL(a.l)
  put_URL(a.p-bstr)
  get_mimeType(a.l)
  get_readyState(a.l)
  get_charset(a.l)
  put_charset(a.p-bstr)
  get_version(a.l)
  get_doctype(a.l)
  get_dtdURL(a.l)
  createElement(a.p-variant, b.p-variant, c.l)
EndInterface

; IXMLDocument2 interface definition
;
Interface IXMLDocument2 Extends IDispatch
  get_root(a.l)
  get_fileSize(a.l)
  get_fileModifiedDate(a.l)
  get_fileUpdatedDate(a.l)
  get_URL(a.l)
  put_URL(a.p-bstr)
  get_mimeType(a.l)
  get_readyState(a.l)
  get_charset(a.l)
  put_charset(a.p-bstr)
  get_version(a.l)
  get_doctype(a.l)
  get_dtdURL(a.l)
  createElement(a.p-variant, b.p-variant, c.l)
  get_async(a.l)
  put_async(a.l)
EndInterface

; IXMLElement interface definition
;
Interface IXMLElement Extends IDispatch
  get_tagName(a.l)
  put_tagName(a.p-bstr)
  get_parent(a.l)
  setAttribute(a.p-bstr, b.p-variant)
  getAttribute(a.p-bstr, b.l)
  removeAttribute(a.p-bstr)
  get_children(a.l)
  get_type(a.l)
  get_text(a.l)
  put_text(a.p-bstr)
  addChild(a.l, b.l, c.l)
  removeChild(a.l)
EndInterface

; IXMLElement2 interface definition
;
Interface IXMLElement2 Extends IDispatch
  get_tagName(a.l)
  put_tagName(a.p-bstr)
  get_parent(a.l)
  setAttribute(a.p-bstr, b.p-variant)
  getAttribute(a.p-bstr, b.l)
  removeAttribute(a.p-bstr)
  get_children(a.l)
  get_type(a.l)
  get_text(a.l)
  put_text(a.p-bstr)
  addChild(a.l, b.l, c.l)
  removeChild(a.l)
  get_attributes(a.l)
EndInterface

; IXMLAttribute interface definition
;
Interface IXMLAttribute Extends IDispatch
  get_name(a.l)
  get_value(a.l)
EndInterface

; IXMLError interface definition
;
Interface IXMLError Extends IUnknown
  GetErrorInfo(a.l)
EndInterface
