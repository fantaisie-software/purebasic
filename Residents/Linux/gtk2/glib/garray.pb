Structure GArray
 *data
  len.l ; guint
  PB_Align(0, 4)
EndStructure

Structure GByteArray
 *data
  len.l ; guint
  PB_Align(0, 4)
EndStructure

Structure GPtrArray
 *pdata
  len.l ; guint
  PB_Align(0, 4)
EndStructure

