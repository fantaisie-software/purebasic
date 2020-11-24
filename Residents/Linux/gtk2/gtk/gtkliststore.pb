Structure GtkListStore
  parent.GObject
  stamp.l 				 ; gint
  PB_Align(0, 4)
  seq.i  					 ; gpointer
  _gtk_reserved1.i ; gpointer
 *sort_list.GList
  n_columns.l			 ; gint
  sort_column_id.l ; gint
  order.l          ; GtkSortType enum
  PB_Align(0, 4, 1)
 *column_headers
  length.l         ; gint
  PB_Align(0, 4, 2)
 *default_sort_func ; GtkTreeIterCompareFunc
  default_sort_data.i ; gpointer
 *default_sort_destroy
  packed_flags.l
  ; columns_dirty:1
  PB_Align(0, 4, 3)
EndStructure

Structure GtkListStoreClass
  parent_class.GObjectClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

