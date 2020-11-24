;#G_CSET_A_2_Z = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
;#G_CSET_a_2_z = "abcdefghijklmnopqrstuvwxyz"
;#G_CSET_DIGITS = "0123456789"
;#G_CSET_LATINC = "\300\301\302\303\304\305\306"\
;#G_CSET_LATINS = "\337\340\341\342\343\344\345\346"\
Enumeration   ; GErrorType
  #G_ERR_UNKNOWN
  #G_ERR_UNEXP_EOF
  #G_ERR_UNEXP_EOF_IN_STRING
  #G_ERR_UNEXP_EOF_IN_COMMENT
  #G_ERR_NON_DIGIT_IN_CONST
  #G_ERR_DIGIT_RADIX
  #G_ERR_FLOAT_RADIX
  #G_ERR_FLOAT_MALFORMED
EndEnumeration

Enumeration   ; '
  #G_TOKEN_EOF = 0
  #G_TOKEN_LEFT_PAREN = '('
  #G_TOKEN_RIGHT_PAREN = ')'
  #G_TOKEN_LEFT_CURLY = '{'
  #G_TOKEN_RIGHT_CURLY = '}'
  #G_TOKEN_LEFT_BRACE		= '['
  #G_TOKEN_RIGHT_BRACE		= ']'
  #G_TOKEN_EQUAL_SIGN		= '='
  #G_TOKEN_COMMA			= ','
  #G_TOKEN_NONE			= 256
  #G_TOKEN_ERROR
  #G_TOKEN_CHAR
  #G_TOKEN_BINARY
  #G_TOKEN_OCTAL
  #G_TOKEN_INT
  #G_TOKEN_HEX
  #G_TOKEN_FLOAT
  #G_TOKEN_STRING
  #G_TOKEN_SYMBOL
  #G_TOKEN_IDENTIFIER
  #G_TOKEN_IDENTIFIER_NULL
  #G_TOKEN_COMMENT_SINGLE
  #G_TOKEN_COMMENT_MULTI
  #G_TOKEN_LAST
EndEnumeration


Structure GTokenValue
  StructureUnion
    v_symbol.l
   *v_identifier
    v_binary.l
    v_octal.l
    v_int.l
    v_int64.q
    v_float.d
    v_hex.l
    *v_string
    *v_comment
    v_char.b
    v_error.l
  EndStructureUnion
EndStructure

Structure GScannerConfig
 *cset_skip_characters
 *cset_identifier_first
 *cset_identifier_nth
 *cpair_comment_single
  packed_flags.l
 ; case_sensitive:1
 ; skip_comment_multi:1
 ; skip_comment_single:1
 ; scan_comment_multi:1
 ; scan_identifier:1
 ; scan_identifier_1char:1
 ; scan_identifier_NULL:1
 ; scan_symbols:1
 ; scan_binary:1
 ; scan_octal:1
 ; scan_float:1
 ; scan_hex:1
 ; scan_hex_dollar:1
 ; scan_string_sq:1
 ; scan_string_dq:1
 ; numbers_2_int:1
 ; int_2_float:1
 ; identifier_2_string:1
 ; char_2_token:1
 ; symbol_2_token:1
 ; scope_0_fallback:1
 ; store_int64:1
  padding_dummy.l
EndStructure

Structure GScanner
  user_data.i        ; gpointer
  max_parse_errors.l ; guint
  parse_errors.l     ; guint
 *input_name
 *qdata.GData
 *config.GScannerConfig
  token.l
  PB_Align(0, 4, 0)
  value.GTokenValue
  line.l             ; guint
  position.l         ; guint
  next_token.l
  PB_Align(0, 4, 1)
  next_value.GTokenValue
  next_line.l        ; guint
  next_position.l    ; guint
 *symbol_table.GHashTable
  input_fd.l         ; gint
  PB_Align(0, 4, 2)
 *text
 *text_end
 *buffer
  scope_id.l         ; guint
  PB_Align(0, 4, 3)
 *msg_handler
EndStructure

