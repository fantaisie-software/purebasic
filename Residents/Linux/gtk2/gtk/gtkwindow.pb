Structure GtkWindow
  bin.GtkBin
 *title
 *wmclass_name
 *wmclass_class
 *wm_role
 *focus_widget.GtkWidget
 *default_widget.GtkWidget
 *transient_parent.GtkWindow
 *geometry_info.GtkWindowGeometryInfo
 *frame.GdkWindow
 *group.GtkWindowGroup
  configure_request_count.w
  pad.w
  packed_flags.l
  ; allow_shrink:1
  ; allow_grow:1
  ; configure_notify_received:1
  ; need_default_position:1
  ; need_default_size:1
  ; position:3
  ; type:4
  ; has_user_ref_count:1
  ; has_focus:1
  ; modal:1
  ; destroy_with_parent:1
  ; has_frame:1
  ; iconify_initially:1
  ; stick_initially:1
  ; maximize_initially:1
  ; decorated:1
  ; type_hint:3
  ; gravity:5
  ; is_active:1
  ; has_toplevel_focus:1
  frame_left.l
  frame_top.l
  frame_right.l
  frame_bottom.l
  keys_changed_handler.l
  mnemonic_modifier.l
 *screen.GdkScreen
EndStructure

Structure GtkWindowClass
  parent_class.GtkBinClass
 *set_focus
 *frame_event
 *activate_focus
 *activate_default
 *move_focus
 *keys_changed
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkWindowGroup
  parent_instance.GObject
 *grabs.GSList
EndStructure

Structure GtkWindowGroupClass
  parent_class.GObjectClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

