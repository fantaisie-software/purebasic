Structure GtkSocket
  container.GtkContainer
  request_width.w
  request_height.w
  current_width.w
  current_height.w
 *plug_window.GdkWindow
 *plug_widget.GtkWidget
  xembed_version.w
  packed_flags.w
  ; same_app:1
  ; focus_in:1
  ; have_size:1
  ; need_map:1
  ; is_mapped:1
  ; active:1
  PB_Align(0, 4)
 *accel_group.GtkAccelGroup
 *toplevel.GtkWidget
EndStructure

Structure GtkSocketClass
  parent_class.GtkContainerClass
 *plug_added
 *plug_removed
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

