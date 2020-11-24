Structure GtkTipsQuery
  label.GtkLabel
  packed_flags.l
  ; emit_always:1
  ; in_query:1
  PB_Align(0, 4)
 *label_inactive
 *label_no_tip
 *caller.GtkWidget
 *last_crossed.GtkWidget
 *query_cursor.GdkCursor
EndStructure

Structure GtkTipsQueryClass
  parent_class.GtkLabelClass
 *start_query
 *stop_query
 *widget_entered
 *widget_selected
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

