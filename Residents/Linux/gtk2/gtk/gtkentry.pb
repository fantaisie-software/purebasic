Structure GtkEntry
  widget.GtkWidget
 *text
  packed_flags.l
  ; editable:1
  ; visible:1
  ; overwrite_mode:1
  ; in_drag:1
  text_length.w
  text_max_length.w
 *text_area.GdkWindow
 *im_context.GtkIMContext
 *popup_menu.GtkWidget
  current_pos.l
  selection_bound.l
 *cached_layout.PangoLayout
  packed_flags_2.l
  ; cache_includes_preedit:1
  ; need_im_reset:1
  ; has_frame:1
  ; activates_default:1
  ; cursor_visible:1
  ; in_click:1
  ; is_cell_renderer:1
  ; editing_canceled:1
  ; mouse_cursor_obscured:1
  ; select_words:1
  ; select_lines:1
  ; resolved_dir:4
  button.l
  blink_timeout.l
  recompute_idle.l
  scroll_offset.l
  ascent.l
  descent.l
  text_size.w
  n_bytes.w
  preedit_length.w
  preedit_cursor.w
  dnd_position.l
  drag_start_x.l
  drag_start_y.l
  invisible_char.b
  pad.b[3]
  width_chars.l
EndStructure

Structure GtkEntryClass
  parent_class.GtkWidgetClass
 *populate_popup
 *activate
 *move_cursor
 *insert_at_cursor
 *delete_from_cursor
 *cut_clipboard
 *copy_clipboard
 *paste_clipboard
 *toggle_overwrite
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

