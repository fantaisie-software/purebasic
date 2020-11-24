Structure GtkToggleButton
  button.GtkButton
  packed_flags.l
  ; active:1
  ; draw_indicator:1
  ; inconsistent:1
  PB_Align(0, 4)
EndStructure

Structure GtkToggleButtonClass
  parent_class.GtkButtonClass
 *toggled
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

