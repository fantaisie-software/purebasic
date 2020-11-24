Structure GtkTreeModelSort
  parent.GObject
  root.i        ; gpointer
  stamp.l       ; gint
  child_flags.l ; guint
 *child_model.GtkTreeModel
  zero_ref_count.l ; gint
  PB_Align(0, 4, 0)
 *sort_list.GList
  sort_column_id.l ; gint
  order.l          ; GtkSortType enum
 *default_sort_func
  default_sort_data.i    ; gpointer
 *default_sort_destroy
  changed_id.l           ; guint
  inserted_id.l          ; guint
  has_child_toggled_id.l ; guint
  deleted_id.l           ; guint
  reordered_id.l         ; guint
  PB_Align(0, 4, 1)
EndStructure

Structure GtkTreeModelSortClass
  parent_class.GObjectClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

