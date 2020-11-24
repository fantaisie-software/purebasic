Structure GtkScale
  range.GtkRange
  digits.l
  packed_flags.l
  ; draw_value:1
  ; value_pos:2
EndStructure

Structure GtkScaleClass
  parent_class.GtkRangeClass
 *format_value
 *draw_value
 *get_layout_offsets
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
EndStructure

