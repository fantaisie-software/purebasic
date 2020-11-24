Structure GtkTextLayout
  parent_instance.GObject
  screen_width.l
  width.l
  height.l
 *buffer.GtkTextBuffer
 *default_style.GtkTextAttributes
 *ltr_context.PangoContext
 *rtl_context.PangoContext
 *one_style_cache.GtkTextAttributes
 *one_display_cache.GtkTextLineDisplay
  wrap_loop_count.l
  packed_flags.l
  ; cursor_visible:1
  ; cursor_direction:2
  ; keyboard_direction:2
 *preedit_string
 *preedit_attrs.PangoAttrList
  preedit_len.l
  preedit_cursor.l
EndStructure

Structure GtkTextLayoutClass
  parent_class.GObjectClass
 *invalidated
 *changed
 *wrap
 *get_log_attrs
 *invalidate
 *free_line_data
 *allocate_child
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkTextAttrAppearance
  attr.l ; PangoAttribute
  appearance.l ; GtkTextAppearance
EndStructure

Structure GtkTextCursorDisplay
  x.l
  y.l
  height.l
  packed_flags.l
  ; is_strong:1
  ; is_weak:1
EndStructure

Structure GtkTextLineDisplay
 *layout.PangoLayout
 *cursors.GSList
 *shaped_objects.GSList
  direction.l ; GtkTextDirection
  width.l
  total_width.l
  height.l
  x_offset.l
  left_margin.l
  right_margin.l
  top_margin.l
  bottom_margin.l
  insert_index.l
  size_only.l
 *line.GtkTextLine
EndStructure

