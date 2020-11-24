Structure GtkMenu
  menu_shell.GtkMenuShell
 *parent_menu_item.GtkWidget
 *old_active_menu_item.GtkWidget
 *accel_group.GtkAccelGroup
 *accel_path
 *position_func
  position_func_data.i ; gpointer
  toggle_size.l        ; guint
  PB_Align(0, 4)
 *toplevel.GtkWidget
 *tearoff_window.GtkWidget
 *tearoff_hbox.GtkWidget
 *tearoff_scrollbar.GtkWidget
 *tearoff_adjustment.GtkAdjustment
 *view_window.GdkWindow
 *bin_window.GdkWindow
  scroll_offset.l
  saved_scroll_offset.l
  scroll_step.l
  timeout_id.l
 *navigation_region.GdkRegion
  navigation_timeout.l
  packed_flags.l
  ; needs_destruction_ref_count:1
  ; torn_off:1
  ; tearoff_active:1
  ; scroll_fast:1
  ; upper_arrow_visible:1
  ; lower_arrow_visible:1
  ; upper_arrow_prelight:1
  ; lower_arrow_prelight:1
EndStructure

Structure GtkMenuClass
  parent_class.GtkMenuShellClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

