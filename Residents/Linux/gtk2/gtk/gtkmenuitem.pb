Structure GtkMenuItem
  item.GtkItem
 *submenu.GtkWidget
 *event_window.GdkWindow
  toggle_size.w
  accelerator_width.w
  PB_Align(0, 4)
 *accel_path
  packed_flags.l
  ; show_submenu_indicator:1
  ; submenu_placement:1
  ; submenu_direction:1
  ; right_justify:1
  ; timer_from_keypress:1
  timer.l
EndStructure

Structure GtkMenuItemClass
  parent_class.GtkItemClass
  packed_flags.l
  ; hide_on_activate:1
  PB_Align(0, 4)
 *activate
 *activate_item
 *toggle_size_request
 *toggle_size_allocate
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

