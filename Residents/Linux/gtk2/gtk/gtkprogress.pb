Structure GtkProgress
  widget.GtkWidget
 *adjustment.GtkAdjustment
 *offscreen_pixmap.GdkPixmap
 *format
  x_align.f
  y_align.f
  packed_flags.l
  ; show_text:1
  ; activity_mode:1
  ; use_text_format:1
  PB_Align(0, 4)
EndStructure

Structure GtkProgressClass
  parent_class.GtkWidgetClass
 *paint
 *update
 *act_mode_enter
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

