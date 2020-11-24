Enumeration   ; GtkTreeModelFlags
  #GTK_TREE_MODEL_ITERS_PERSIST = 1<<0
  #GTK_TREE_MODEL_LIST_ONLY = 1<<1
EndEnumeration

Structure GtkTreeIter
  stamp.l        ; gint
  PB_Align(0, 4)
  user_data.i    ; gpointer
  user_data2.i   ; gpointer
  user_data3.i   ; gpointer
EndStructure

Structure GtkTreeModelIface
  g_iface.GTypeInterface
 *row_changed
 *row_inserted
 *row_has_child_toggled
 *row_deleted
 *rows_reordered
 *get_flags
 *get_n_columns
 *get_column_type
 *get_iter
 *get_path
 *get_value
 *iter_next
 *iter_children
 *iter_has_child
 *iter_n_children
 *iter_nth_child
 *iter_parent
 *ref_node
 *unref_node
EndStructure

