Structure GtkViewport
  bin.GtkBin
  shadow_type.l ; GtkShadowType enum
  PB_Align(0, 4)
 *view_window.GdkWindow
 *bin_window.GdkWindow
 *hadjustment.GtkAdjustment
 *vadjustment.GtkAdjustment
EndStructure

Structure GtkViewportClass
  parent_class.GtkBinClass
 *set_scroll_adjustments
EndStructure

