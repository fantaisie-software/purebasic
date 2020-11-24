Structure GEnumClass
  g_type_class.GTypeClass
  minimum.l  ; gint
  maximum.l  ; gint
  n_values.l ; guint
  PB_Align(0, 4)
 *values.GEnumValue
EndStructure

Structure GFlagsClass
  g_type_class.GTypeClass
  mask.l
  n_values.l
 *values.GFlagsValue
EndStructure

Structure GEnumValue
  value.l ; gint
  PB_Align(0, 4)
 *value_name
 *value_nick
EndStructure

Structure GFlagsValue
  value.l ; guint
  PB_Align(0, 4)
 *value_name
 *value_nick
EndStructure

