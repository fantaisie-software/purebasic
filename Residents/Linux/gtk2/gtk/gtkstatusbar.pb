Structure GtkStatusbar
  parent_widget.GtkHBox
 *frame.GtkWidget
 *label.GtkWidget
 *messages.GSList
 *keys.GSList
  seq_context_id.l
  seq_message_id.l
 *grip_window.GdkWindow
  packed_flags.l
  ; has_resize_grip:1
  PB_Align(0, 4)
EndStructure

Structure GtkStatusbarClass
  parent_class.GtkHBoxClass
 *messages_mem_chunk.GMemChunk
 *text_pushed
 *text_popped
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

