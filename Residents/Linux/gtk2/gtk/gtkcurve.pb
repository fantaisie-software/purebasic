Structure GtkCurve
  graph.GtkDrawingArea
  cursor_type.l ; gint
  min_x.f
  max_x.f
  min_y.f
  max_y.f
  PB_Align(0, 4)
 *pixmap.GdkPixmap
  curve_type.l ; GtkCurveType enum
  height.l
  grab_point.l
  last.l
  num_points.l
  PB_Align(0, 4, 1)
 *point.GdkPoint
  num_ctlpoints.l
  PB_Align(0, 4, 2)
 *ctlpoint[1]
EndStructure


Structure GtkCurveClass
  parent_class.GtkDrawingAreaClass
  *curve_type_changed
  *_gtk_reserved1
  *_gtk_reserved2
  *_gtk_reserved3
  *_gtk_reserved4
EndStructure

