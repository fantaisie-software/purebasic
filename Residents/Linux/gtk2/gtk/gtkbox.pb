Structure GtkBox
  container.GtkContainer
 *children.GList
  spacing.w
  packed_flags.w
  ; homogeneous:1
  PB_Align(0, 4)
EndStructure

Structure GtkBoxClass
  parent_class.GtkContainerClass
EndStructure

Structure GtkBoxChild
 *widget.GtkWidget
  padding.w
  packed_flags.w
  ; expand:1
  ; fill:1
  ; pack:1
  ; is_secondary:1
  PB_Align(0, 4)
EndStructure

