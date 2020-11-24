Structure GtkFrame
  bin.GtkBin
 *label_widget.GtkWidget
  shadow_type.w
  PB_Align(2, 2, 0)
  label_xalign.f
  label_yalign.f
  PB_Align(0, 4, 1)
  child_allocation.GtkAllocation
EndStructure

Structure GtkFrameClass
  parent_class.GtkBinClass
 *compute_child_allocation
EndStructure

