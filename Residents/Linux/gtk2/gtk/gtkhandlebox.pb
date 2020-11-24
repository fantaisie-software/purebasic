Structure GtkHandleBox
  bin.GtkBin
 *bin_window.GdkWindow
 *float_window.GdkWindow
  shadow_type.l
  packed_flags.l
  ; handle_position:2
  ; float_window_mapped:1
  ; child_detached:1
  ; in_drag:1
  ; shrink_on_detach:1
  deskoff_x.l
  deskoff_y.l
  attach_allocation.GtkAllocation
  float_allocation.GtkAllocation
EndStructure

Structure GtkHandleBoxClass
  parent_class.GtkBinClass
 *child_attached
 *child_detached
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

