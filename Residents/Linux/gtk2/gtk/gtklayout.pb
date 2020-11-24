Structure GtkLayout
  container.GtkContainer
 *children.GList
  width.l
  height.l
 *hadjustment.GtkAdjustment
 *vadjustment.GtkAdjustment
 *bin_window.GdkWindow
  visibility.l
  scroll_x.l
  scroll_y.l
  freeze_count.l
EndStructure

Structure GtkLayoutClass
  parent_class.GtkContainerClass
 *set_scroll_adjustments
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

