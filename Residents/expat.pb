; -------------------------------------------------------------------------
;
; Converted from the expat 2.01 package (http://expat.sourceforge.net/)
;
; -------------------------------------------------------------------------
;
; Copyright (c) 1998, 1999, 2000 Thai Open Source Software Center Ltd
;                                And Clark Cooper
; Copyright (c) 2001, 2002, 2003, 2004, 2005, 2006 Expat maintainers.
;
; Permission is hereby granted, free of charge, To any person obtaining
; a copy of this software And associated documentation files (the
; "Software"), To deal in the Software without restriction, including
; without limitation the rights To use, copy, modify, merge, publish,
; distribute, sublicense, And/Or sell copies of the Software, And To
; permit persons To whom the Software is furnished To do so, subject To
; the following conditions:
;
; The above copyright notice And this permission notice shall be included
; in all copies Or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS Or IMPLIED, INCLUDING BUT Not LIMITED To THE WARRANTIES OF
; MERCHANTABILITY, FITNESS For A PARTICULAR PURPOSE And NONINFRINGEMENT.
; IN NO EVENT SHALL THE AUTHORS Or COPYRIGHT HOLDERS BE LIABLE For ANY
; CLAIM, DAMAGES Or OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
; TORT Or OTHERWISE, ARISING FROM, OUT OF Or IN CONNECTION With THE
; SOFTWARE Or THE USE Or OTHER DEALINGS IN THE SOFTWARE.
;

#XML_MAJOR_VERSION = 2
#XML_MINOR_VERSION = 0
#XML_MICRO_VERSION = 1

#XML_TRUE = 1
#XML_FALSE = 0

#XML_STATUS_ERROR = 0
#XML_STATUS_OK = 1


Enumeration ; XML_Parsing
  #XML_INITIALIZED
  #XML_PARSING
  #XML_FINISHED
  #XML_SUSPENDED
EndEnumeration


Enumeration ; XML_ParamEntityParsing
  #XML_PARAM_ENTITY_PARSING_NEVER
  #XML_PARAM_ENTITY_PARSING_UNLESS_STANDALONE
  #XML_PARAM_ENTITY_PARSING_ALWAYS
EndEnumeration


Enumeration ; XML_Content_Type
  #XML_CTYPE_EMPTY = 1
  #XML_CTYPE_ANY
  #XML_CTYPE_MIXED
  #XML_CTYPE_NAME
  #XML_CTYPE_CHOICE
  #XML_CTYPE_SEQ
EndEnumeration


Enumeration ; XML_Content_Quant
  #XML_CQUANT_NONE
  #XML_CQUANT_OPT
  #XML_CQUANT_REP
  #XML_CQUANT_PLUS
EndEnumeration


Enumeration ; XML_FeatureEnum
  #XML_FEATURE_END = 0
  #XML_FEATURE_UNICODE
  #XML_FEATURE_UNICODE_WCHAR_T
  #XML_FEATURE_DTD
  #XML_FEATURE_CONTEXT_BYTES
  #XML_FEATURE_MIN_SIZE
  #XML_FEATURE_SIZEOF_XML_CHAR
  #XML_FEATURE_SIZEOF_XML_LCHAR
  #XML_FEATURE_NS
  #XML_FEATURE_LARGE_SIZE
EndEnumeration


Enumeration ; XML_Error
  #XML_ERROR_NONE
  #XML_ERROR_NO_MEMORY
  #XML_ERROR_SYNTAX
  #XML_ERROR_NO_ELEMENTS
  #XML_ERROR_INVALID_TOKEN
  #XML_ERROR_UNCLOSED_TOKEN
  #XML_ERROR_PARTIAL_CHAR
  #XML_ERROR_TAG_MISMATCH
  #XML_ERROR_DUPLICATE_ATTRIBUTE
  #XML_ERROR_JUNK_AFTER_DOC_ELEMENT
  #XML_ERROR_PARAM_ENTITY_REF
  #XML_ERROR_UNDEFINED_ENTITY
  #XML_ERROR_RECURSIVE_ENTITY_REF
  #XML_ERROR_ASYNC_ENTITY
  #XML_ERROR_BAD_CHAR_REF
  #XML_ERROR_BINARY_ENTITY_REF
  #XML_ERROR_ATTRIBUTE_EXTERNAL_ENTITY_REF
  #XML_ERROR_MISPLACED_XML_PI
  #XML_ERROR_UNKNOWN_ENCODING
  #XML_ERROR_INCORRECT_ENCODING
  #XML_ERROR_UNCLOSED_CDATA_SECTION
  #XML_ERROR_EXTERNAL_ENTITY_HANDLING
  #XML_ERROR_NOT_STANDALONE
  #XML_ERROR_UNEXPECTED_STATE
  #XML_ERROR_ENTITY_DECLARED_IN_PE
  #XML_ERROR_FEATURE_REQUIRES_XML_DTD
  #XML_ERROR_CANT_CHANGE_FEATURE_ONCE_PARSING
  ;/* Added in 1.95.7. */
  #XML_ERROR_UNBOUND_PREFIX
  ;/* Added in 1.95.8. */
  #XML_ERROR_UNDECLARING_PREFIX
  #XML_ERROR_INCOMPLETE_PE
  #XML_ERROR_XML_DECL
  #XML_ERROR_TEXT_DECL
  #XML_ERROR_PUBLICID
  #XML_ERROR_SUSPENDED
  #XML_ERROR_NOT_SUSPENDED
  #XML_ERROR_ABORTED
  #XML_ERROR_FINISHED
  #XML_ERROR_SUSPEND_PE
  ;/* Added in 2.0. */
  #XML_ERROR_RESERVED_PREFIX_XML
  #XML_ERROR_RESERVED_PREFIX_XMLNS
  #XML_ERROR_RESERVED_NAMESPACE_URI
EndEnumeration


; Prototypes are not supported in residents
; Prototype.l XML_Encoding_convert(*pdata, s.p-ascii)
; Prototype   XML_Encoding_release(*pdata)

Structure XML_Encoding
  xmlmap.l[256]
 *pdata
 *convert ; XML_Encoding_convert
 *release ; XML_Encoding_release
EndStructure


Structure XML_Feature
  feature.l
 *name.WORD      ; this is always a unicode string, even in ascii mode!
  value.l
EndStructure


Structure XML_Expat_Version
  major.l
  minor.l
  micro.l
EndStructure


Structure XML_Content
  type.l
  quant.l
 *name.Character
  numchildren.l
 *children.XML_Content
EndStructure


Structure XML_cp Extends XML_Content: EndStructure


Structure XML_Memory_Handling_Suite
  *malloc_fcn  ; void *(XMLCALL *malloc_fcn)(size_t size);
  *realloc_fcn; void *(XMLCALL *realloc_fcn)(void *ptr, size_t size);
  *free_fcn    ;void (XMLCALL *free_fcn)(void *ptr);
EndStructure


Structure XML_ParsingStatus
  parsing.l      ; XML_Parsing
  finalBuffer.l  ; bool
EndStructure

; defined as a macro in the expat headers as well
;
Macro XML_GetUserData_(p)
  PeekL(p)
EndMacro



