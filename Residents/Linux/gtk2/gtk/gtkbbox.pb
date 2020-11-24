Structure GtkButtonBox
  box.GtkBox
  child_min_width.l  ; gint
  child_min_height.l ; gint
  child_ipad_x.l     ; gint
  child_ipad_y.l     ; gint
  layout_style.l     ; GtkButtonBoxStyle enum
  PB_Align(0, 4)
EndStructure

Structure GtkButtonBoxClass
  parent_class.GtkBoxClass
EndStructure

