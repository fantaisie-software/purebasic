Structure GtkTextTag
  parent_instance.GObject
 *table.GtkTextTagTable
 *name
  priority.l ; int
  PB_Align(0, 4)
 *values.GtkTextAttributes
  packed_flags.l
  ; bg_color_set:1
  ; bg_stipple_set:1
  ; fg_color_set:1
  ; scale_set:1
  ; fg_stipple_set:1
  ; justification_set:1
  ; left_margin_set:1
  ; indent_set:1
  ; rise_set:1
  ; strikethrough_set:1
  ; right_margin_set:1
  ; pixels_above_lines_set:1
  ; pixels_below_lines_set:1
  ; pixels_inside_wrap_set:1
  ; tabs_set:1
  ; underline_set:1
  ; wrap_mode_set:1
  ; bg_full_height_set:1
  ; invisible_set:1
  ; editable_set:1
  ; language_set:1
  ; pad1:1
  ; pad2:1
  ; pad3:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkTextTagClass
  parent_class.GObjectClass
 *event
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkTextAppearance
  bg_color.GdkColor
  fg_color.GdkColor
 *bg_stipple.GdkBitmap
 *fg_stipple.GdkBitmap
  rise.l     ; gint
  PB_Align(0, 4)
  padding1.i ; gpointer
  packed_flags.l
  ; underline:4
  ; strikethrough:1
  ; draw_bg:1
  ; inside_selection:1
  ; is_text:1
  ; pad1:1
  ; pad2:1
  ; pad3:1
  ; pad4:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkTextAttributes
  refcount.l  ; guint
  PB_Align(0, 4)
  appearance.GtkTextAppearance
  justification.l  ; GtkJustification enum
  direction.l      ; GtkTextDirection enum
 *font.PangoFontDescription
  font_scale.d
  left_margin.l        ; gint
  indent.l						 ; gint
  right_margin.l			 ; gint
  pixels_above_lines.l ; gint
  pixels_below_lines.l ; gint
  pixels_inside_wrap.l ; gint
 *tabs.PangoTabArray
  wrap_mode.l 				 ; GtkWrapMode enum
  PB_Align(0, 4, 1)
 *language.PangoLanguage
 *pg_bg_color.GdkColor
  packed_flags.l
  ; invisible:1
  ; bg_full_height:1
  ; editable:1
  ; realized:1
  ; pad1:1
  ; pad2:1
  ; pad3:1
  ; pad4:1
  PB_Align(0, 4, 2)
EndStructure

