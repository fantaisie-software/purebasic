Structure GtkCheckMenuItem
  menu_item.GtkMenuItem
  packed_flags.l
  ; active:1
  ; always_show_toggle:1
  ; inconsistent:1
  ; draw_as_radio:1
  PB_Align(0, 4)
EndStructure

Structure GtkCheckMenuItemClass
  parent_class.GtkMenuItemClass
 *toggled
 *draw_indicator
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

