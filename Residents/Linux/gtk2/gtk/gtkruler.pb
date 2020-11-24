Structure GtkRuler
  widget.GtkWidget
 *backing_store.GdkPixmap
 *non_gr_exp_gc.GdkGC
 *metric.GtkRulerMetric
  xsrc.l        ; gint
  ysrc.l        ; gint
  slider_size.l ; gint
  PB_Align(0, 4)
  lower.d
  upper.d
  position.d
  max_size.d
EndStructure

Structure GtkRulerClass
  parent_class.GtkWidgetClass
 *draw_ticks
 *draw_pos
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkRulerMetric
 *metric_name
 *abbrev
  pixels_per_unit.d
  ruler_scale.d[10]
  subdivide.l[5]
  PB_Align(0, 4)
EndStructure

