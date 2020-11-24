Enumeration   ; GtkToolbarChildType
  #GTK_TOOLBAR_CHILD_SPACE
  #GTK_TOOLBAR_CHILD_BUTTON
  #GTK_TOOLBAR_CHILD_TOGGLEBUTTON
  #GTK_TOOLBAR_CHILD_RADIOBUTTON
  #GTK_TOOLBAR_CHILD_WIDGET
EndEnumeration

Structure GtkToolbarChild
  type.l ; GtkToolbarChildType enum
  PB_Align(0, 4)
 *widget.GtkWidget
 *icon.GtkWidget
 *label.GtkWidget
EndStructure

Enumeration   ; GtkToolbarSpaceStyle
  #GTK_TOOLBAR_SPACE_EMPTY
  #GTK_TOOLBAR_SPACE_LINE
EndEnumeration

Structure GtkToolbar
  container.GtkContainer
  num_children.l ; gint
  PB_Align(0, 4)
 *children.GList
  orientation.l ; GtkOrientation enum
  style.l       ; GtkToolbarStyle enum
  icon_size.l   ; GtkIconSize enum
  PB_Align(0, 4, 1)
 *tooltips.GtkTooltips
  button_maxw.l    ; gint
  button_maxh.l    ; gint
  _gtk_reserved1.l ; guint
  _gtk_reserved2.l ; guint
  packed_flags.l
  ; style_set:1
  ; icon_size_set:1
  PB_Align(0, 4, 2)
EndStructure

Structure GtkToolbarClass
  parent_class.GtkContainerClass
 *orientation_changed
 *style_changed
 *popup_context_menu
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
EndStructure

