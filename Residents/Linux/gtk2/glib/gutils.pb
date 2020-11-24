;#G_DIR_SEPARATOR_S = "\"
;#G_SEARCHPATH_SEPARATOR_S = ";"
#G_DIR_SEPARATOR_S = "/"
#G_SEARCHPATH_SEPARATOR_S = ":"
Structure GDebugKey
 *key
  value.l ; guint
  PB_Align(0, 4)
EndStructure

Structure GTrashStack
 *next.GTrashStack
EndStructure

