Enumeration   ; GtkTextWindowType
  #GTK_TEXT_WINDOW_PRIVATE
  #GTK_TEXT_WINDOW_WIDGET
  #GTK_TEXT_WINDOW_TEXT
  #GTK_TEXT_WINDOW_LEFT
  #GTK_TEXT_WINDOW_RIGHT
  #GTK_TEXT_WINDOW_TOP
  #GTK_TEXT_WINDOW_BOTTOM
EndEnumeration

#GTK_TEXT_VIEW_PRIORITY_VALIDATE = (#GDK_PRIORITY_REDRAW+5)
Structure GtkTextView
  parent_instance.GtkContainer
 *layout.GtkTextLayout
 *buffer.GtkTextBuffer
  selection_drag_handler.l ; guint
  scroll_timeout.l				 ; guint
  pixels_above_lines.l     ; gint
  pixels_below_lines.l		 ; gint
  pixels_inside_wrap.l		 ; gint
  wrap_mode.l 						 ; GtkWrapMode enum
  justify.l								 ; GtkJustification enum
  left_margin.l						 ; gint
  right_margin.l					 ; gint
  indent.l								 ; gint
 *tabs.PangoTabArray
  packed_flags.l
  ; editable:1
  ; overwrite_mode:1
  ; cursor_visible:1
  ; need_im_reset:1
  ; accepts_tab:1
  ; reserved:1
  ; onscreen_validated:1
  ; mouse_cursor_obscured:1
  PB_Align(0, 4)
 *text_window.GtkTextWindow
 *left_window.GtkTextWindow
 *right_window.GtkTextWindow
 *top_window.GtkTextWindow
 *bottom_window.GtkTextWindow
 *hadjustment.GtkAdjustment
 *vadjustment.GtkAdjustment
  xoffset.l
  yoffset.l
  width.l
  height.l
  virtual_cursor_x.l
  virtual_cursor_y.l
 *first_para_mark.GtkTextMark
  first_para_pixels.l  ; gint
  PB_Align(0, 4, 1)
 *dnd_mark.GtkTextMark
  blink_timeout.l							; guint
  first_validate_idle.l				; guint
  incremental_validate_idle.l ; guint
  PB_Align(0, 4, 2)
 *im_context.GtkIMContext
 *popup_menu.GtkWidget
  drag_start_x.l
  drag_start_y.l
 *children.GSList
 *pending_scroll.GtkTextPendingScroll
  pending_place_cursor_button.l ; gint
  PB_Align(0, 4, 3)
EndStructure

Structure GtkTextViewClass
  parent_class.GtkContainerClass
 *set_scroll_adjustments
 *populate_popup
 *move_cursor
 *page_horizontally
 *set_anchor
 *insert_at_cursor
 *delete_from_cursor
 *cut_clipboard
 *copy_clipboard
 *paste_clipboard
 *toggle_overwrite
 *move_focus
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
 *_gtk_reserved5
 *_gtk_reserved6
 *_gtk_reserved7
 *_gtk_reserved8
EndStructure

