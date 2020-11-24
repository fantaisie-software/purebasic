Structure GtkPaned
  container.GtkContainer
 *child1.GtkWidget
 *child2.GtkWidget
 *handle.GdkWindow
 *xor_gc.GdkGC
  cursor_type.l
  handle_pos.GdkRectangle
  child1_size.l
  last_allocation.l
  min_position.l
  max_position.l
  packed_flags.l
  ; position_set:1
  ; in_drag:1
  ; child1_shrink:1
  ; child1_resize:1
  ; child2_shrink:1
  ; child2_resize:1
  ; orientation:1
  ; in_recursion:1
  ; handle_prelit:1
 *last_child1_focus.GtkWidget
 *last_child2_focus.GtkWidget
 *priv.GtkPanedPrivate
  drag_pos.l
  original_position.l
EndStructure

Structure GtkPanedClass
  parent_class.GtkContainerClass
 *cycle_child_focus
 *toggle_handle_focus
 *move_handle
 *cycle_handle_focus
 *accept_position
 *cancel_position
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

