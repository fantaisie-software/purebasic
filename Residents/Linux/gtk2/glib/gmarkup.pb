Enumeration   ; GMarkupError
  #G_MARKUP_ERROR_BAD_UTF8
  #G_MARKUP_ERROR_EMPTY
  #G_MARKUP_ERROR_PARSE
  #G_MARKUP_ERROR_UNKNOWN_ELEMENT
  #G_MARKUP_ERROR_UNKNOWN_ATTRIBUTE
  #G_MARKUP_ERROR_INVALID_CONTENT
EndEnumeration

Enumeration   ; GMarkupParseFlags
  #G_MARKUP_DO_NOT_USE_THIS_UNSUPPORTED_FLAG = 1<<0
EndEnumeration

Structure GMarkupParser
 *start_element
 *end_element
 *text
 *passthrough
 *error
EndStructure

