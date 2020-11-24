Enumeration   ; GtkWidgetFlags
  #GTK_TOPLEVEL = 1<<4
  #GTK_NO_WINDOW = 1<<5
  #GTK_REALIZED = 1<<6
  #GTK_MAPPED = 1<<7
  #GTK_VISIBLE = 1<<8
  #GTK_SENSITIVE = 1<<9
  #GTK_PARENT_SENSITIVE = 1<<10
  #GTK_CAN_FOCUS = 1<<11
  #GTK_HAS_FOCUS = 1<<12
  #GTK_CAN_DEFAULT = 1<<13
  #GTK_HAS_DEFAULT = 1<<14
  #GTK_HAS_GRAB = 1<<15
  #GTK_RC_STYLE = 1<<16
  #GTK_COMPOSITE_CHILD = 1<<17
  #GTK_NO_REPARENT = 1<<18
  #GTK_APP_PAINTABLE = 1<<19
  #GTK_RECEIVES_DEFAULT = 1<<20
  #GTK_DOUBLE_BUFFERED = 1<<21
  #GTK_NO_SHOW_ALL = 1<<22
EndEnumeration

Enumeration   ; GtkWidgetHelpType
  #GTK_WIDGET_HELP_TOOLTIP
  #GTK_WIDGET_HELP_WHATS_THIS
EndEnumeration

Structure GtkRequisition
  width.l
  height.l
EndStructure

Structure GtkWidget
  object.GtkObject
  private_flags.w
  state.b
  saved_state.b
  PB_Align(0, 4)
 *name
 *style.GtkStyle
  requisition.GtkRequisition
  allocation.GtkAllocation
 *window.GdkWindow
 *parent.GtkWidget
EndStructure

Structure GtkWidgetClass
  parent_class.GtkObjectClass
  activate_signal.l
  set_scroll_adjustments_signal.l
 *dispatch_child_properties_changed
 *show
 *show_all
 *hide
 *hide_all
 *map
 *unmap
 *realize
 *unrealize
 *size_request
 *size_allocate
 *state_changed
 *parent_set
 *hierarchy_changed
 *style_set
 *direction_changed
 *grab_notify
 *child_notify
 *mnemonic_activate
 *grab_focus
 *focus
 *event
 *button_press_event
 *button_release_event
 *scroll_event
 *motion_notify_event
 *delete_event
 *destroy_event
 *expose_event
 *key_press_event
 *key_release_event
 *enter_notify_event
 *leave_notify_event
 *configure_event
 *focus_in_event
 *focus_out_event
 *map_event
 *unmap_event
 *property_notify_event
 *selection_clear_event
 *selection_request_event
 *selection_notify_event
 *proximity_in_event
 *proximity_out_event
 *visibility_notify_event
 *client_event
 *no_expose_event
 *window_state_event
 *selection_get
 *selection_received
 *drag_begin
 *drag_end
 *drag_data_get
 *drag_data_delete
 *drag_leave
 *drag_motion
 *drag_drop
 *drag_data_received
 *popup_menu
 *show_help
 *get_accessible
 *screen_changed
 *can_activate_accel
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
 *_gtk_reserved5
 *_gtk_reserved6
EndStructure

Structure GtkWidgetAuxInfo
  x.l
  y.l
  width.l
  height.l
  packed_flags.l
  ; x_set:1
  ; y_set:1
EndStructure

Structure GtkWidgetShapeInfo
  offset_x.w
  offset_y.w
  PB_Align(0, 4)
 *shape_mask.GdkBitmap
EndStructure

