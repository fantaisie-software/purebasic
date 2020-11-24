Structure GdkDisplay
  parent_instance.GObject
 *queued_events.GList
 *queued_tail.GList
  button_click_time.l[2]  ; guint
 *button_window.GdkWindow[2]
  button_number.l[2]      ; gint
  double_click_time.l     ; guint
  PB_Align(0, 4)
 *core_pointer.GdkDevice
 *pointer_hooks.GdkDisplayPointerHooks
  packed_flags.l
  ; closed:1
  double_click_distance.l ; guint
  button_x.l[2]           ; gint
  button_y.l[2]           ; gint
EndStructure

Structure GdkDisplayClass
  parent_class.GObjectClass
 *get_display_name
 *get_n_screens
 *get_screen
 *get_default_screen
 *closed
EndStructure

Structure GdkDisplayPointerHooks
 *get_pointer
 *window_get_pointer
 *window_at_pointer
EndStructure

