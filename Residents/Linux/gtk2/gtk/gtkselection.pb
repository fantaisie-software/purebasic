Structure GtkSelectionData
  selection.i ; GdkAtom
  target.i    ; GdkAtom
  type.i      ; GdkAtom
  format.l    ; gint
  PB_Align(0, 4)
 *data
  length.l    ; gint
  PB_Align(0, 4, 1)
 *display.GdkDisplay
EndStructure

Structure GtkTargetEntry
 *target
  flags.l
  info.l
EndStructure

Structure GtkTargetList
 *list.GList
  ref_count.l ; guint
  PB_Align(0, 4)
EndStructure

Structure GtkTargetPair
  target.i  ; GdkAtom
  flags.l   ; guint
  info.l    ; guint
EndStructure

