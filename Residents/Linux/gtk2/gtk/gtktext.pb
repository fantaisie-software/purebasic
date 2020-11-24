Structure GtkPropertyMark
 *property.GList
  offset.l
  index.l
EndStructure

Structure GtkText
  old_editable.GtkOldEditable
 *text_area.GdkWindow
 *hadj.GtkAdjustment
 *vadj.GtkAdjustment
 *gc.GdkGC
 *line_wrap_bitmap.GdkPixmap
 *line_arrow_bitmap.GdkPixmap
  StructureUnion
   *wc
   *ch
  EndStructureUnion
  text_len.l			; guint
  gap_position.l  ; guint
  gap_size.l      ; guint
  text_end.l			; guint
 *line_start_cache.GList
  first_line_start_index.l   ; guint
  first_cut_pixels.l         ; guint
  first_onscreen_hor_pixel.l ; guint
  first_onscreen_ver_pixel.l ; guint
  packed_flags.l
  ; line_wrap:1
  ; word_wrap:1
  ; use_wchar:1
  freeze_count.l ; guint
 *text_properties.GList
 *text_properties_end.GList
  point.GtkPropertyMark
  StructureUnion
   *wc2
   *ch2
  EndStructureUnion
  scratch_buffer_len.l ; guint
  last_ver_value.l     ; guint
  cursor_pos_x.l       ; gint
  cursor_pos_y.l       ; gint
  cursor_mark.GtkPropertyMark
  cursor_char.l
  cursor_char_offset.b
  PB_Align(3, 3)
  cursor_virtual_x.l
  cursor_drawn_level.l
 *current_line.GList
 *tab_stops.GList
  default_tab_width.l ; gint
  PB_Align(0, 4, 1)
 *current_font.GtkTextFont
  timer.l   ; gint
  button.l  ; guint
 *bg_gc.GdkGC
EndStructure

Structure GtkTextClass
  parent_class.GtkOldEditableClass
 *set_scroll_adjustments
EndStructure

