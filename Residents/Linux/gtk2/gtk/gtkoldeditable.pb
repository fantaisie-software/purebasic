Structure GtkOldEditable
  widget.GtkWidget
  current_pos.l
  selection_start_pos.l
  selection_end_pos.l
  packed_flags.l
  ; has_selection:1
  ; editable:1
  ; visible:1
 *clipboard_text
EndStructure

Structure GtkOldEditableClass
  parent_class.GtkWidgetClass
 *activate
 *set_editable
 *move_cursor
 *move_word
 *move_page
 *move_to_row
 *move_to_column
 *kill_char
 *kill_word
 *kill_line
 *cut_clipboard
 *copy_clipboard
 *paste_clipboard
 *update_text
 *get_chars
 *set_selection
 *set_position
EndStructure

