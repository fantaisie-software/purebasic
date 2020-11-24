Structure GtkScrolledWindow
  container.GtkBin
 *hscrollbar.GtkWidget
 *vscrollbar.GtkWidget
  packed_flags.w
  ; hscrollbar_policy:2
  ; vscrollbar_policy:2
  ; hscrollbar_visible:1
  ; vscrollbar_visible:1
  ; window_placement:2
  ; focus_out:1
  shadow_type.w
  PB_Align(0, 4)
EndStructure

Structure GtkScrolledWindowClass
  parent_class.GtkBinClass
  scrollbar_spacing.l  ; gint
  PB_Align(0, 4)
 *scroll_child
 *move_focus_out
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

