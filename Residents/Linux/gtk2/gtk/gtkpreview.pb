Structure GtkPreview
  widget.GtkWidget
 *buffer
  buffer_width.w
  buffer_height.w
  bpp.w
  rowstride.w
  dither.l
  packed_flags.l
  ; type:1
  ; expand:1
EndStructure

Structure GtkPreviewInfo
 *lookup
  gamma.d
EndStructure

Structure GtkPreviewClass
  parent_class.GtkWidgetClass
  info.GtkPreviewInfo
EndStructure

