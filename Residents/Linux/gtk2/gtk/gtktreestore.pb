Structure GtkTreeStore
  parent.GObject
  stamp.l  			   ; gint
  PB_Align(0, 4, 0)
  root.i   			   ; gpointer
  last.i   				 ; gpointer
  n_columns.l      ; gint
  sort_column_id.l ; gint
 *sort_list.GList
  order.l          ; GtkSortType enum
  PB_Align(0, 4, 1)
 *column_headers
 *default_sort_func
  default_sort_data.i ; gpointer
 *default_sort_destroy
  packed_flags.l
  ; columns_dirty:1
  PB_Align(0, 4, 2)
EndStructure

Structure GtkTreeStoreClass
  parent_class.GObjectClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

