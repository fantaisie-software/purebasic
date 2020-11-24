#GTK_MAX_COMPOSE_LEN = 7
Structure GtkIMContextSimple
  object.GtkIMContext
 *tables.GSList
  compose_buffer.l[#GTK_MAX_COMPOSE_LEN+1]
  tentative_match.l ; gunichar
  tentative_match_len.l
  packed_flags.l
  ; in_hex_sequence:1
  ; modifiers_dropped:1
  PB_Align(0, 4)
EndStructure

Structure GtkIMContextSimpleClass
  parent_class.GtkIMContextClass
EndStructure

