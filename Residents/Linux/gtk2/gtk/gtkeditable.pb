Structure GtkEditableClass
  base_iface.GTypeInterface
 *insert_text
 *delete_text
 *changed
 *do_insert_text
 *do_delete_text
 *get_chars
 *set_selection_bounds
 *get_selection_bounds
 *set_position
 *get_position
EndStructure

; Note: it's an old structure found in gtkoldeditable.h, but the GTK2 doc still mention it..
;
Structure GtkEditable
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


