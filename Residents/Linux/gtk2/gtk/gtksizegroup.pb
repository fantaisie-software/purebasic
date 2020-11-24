Structure GtkSizeGroup
  parent_instance.GObject
 *widgets.GSList
  mode.b
  pad.b
  packed_flags.w
  ; have_width:1
  ; have_height:1
  PB_Align(0, 4)
  requisition.GtkRequisition
EndStructure

Structure GtkSizeGroupClass
  parent_class.GObjectClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Enumeration   ; GtkSizeGroupMode
  #GTK_SIZE_GROUP_NONE
  #GTK_SIZE_GROUP_HORIZONTAL
  #GTK_SIZE_GROUP_VERTICAL
  #GTK_SIZE_GROUP_BOTH
EndEnumeration

