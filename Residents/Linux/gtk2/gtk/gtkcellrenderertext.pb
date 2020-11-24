Structure GtkCellRendererText
  parent.GtkCellRenderer
 *text
 *font.PangoFontDescription
  font_scale.d
  foreground.PangoColor ; Warning 'PangoColor' is only 6 bytes, even on x64, so it gets packed together and need an alignment
  background.PangoColor ;
  PB_Align(0, 4)
 *extra_attrs.PangoAttrList
  underline_style.l ; PangoUnderline enum
  rise.l
  fixed_height_rows.l
  packed_flags.l
  ; strikethrough:1
  ; editable:1
  ; scale_set:1
  ; foreground_set:1
  ; background_set:1
  ; underline_set:1
  ; rise_set:1
  ; strikethrough_set:1
  ; editable_set:1
  ; calc_fixed_height:1
EndStructure

Structure GtkCellRendererTextClass
  parent_class.GtkCellRendererClass
 *edited
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

