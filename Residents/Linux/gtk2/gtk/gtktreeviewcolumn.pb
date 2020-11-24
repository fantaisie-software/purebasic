Enumeration   ; GtkTreeViewColumnSizing
  #GTK_TREE_VIEW_COLUMN_GROW_ONLY
  #GTK_TREE_VIEW_COLUMN_AUTOSIZE
  #GTK_TREE_VIEW_COLUMN_FIXED
EndEnumeration

Structure GtkTreeViewColumn
  parent.GtkObject
 *tree_view.GtkWidget
 *button.GtkWidget
 *child.GtkWidget
 *arrow.GtkWidget
 *alignment.GtkWidget
 *window.GdkWindow
 *editable_widget.GtkCellEditable
  xalign.f
  property_changed_signal.l
  spacing.l
  column_type.l ; GtkTreeViewColumnSizing enum
  requested_width.l
  button_request.l
  resized_width.l
  width.l
  fixed_width.l
  min_width.l
  max_width.l
  drag_x.l
  drag_y.l
  PB_Align(0, 4)
 *title
 *cell_list.GList
  sort_clicked_signal.l
  sort_column_changed_signal.l
  sort_column_id.l
  sort_order.l   ; GtkSortType enum
  packed_flags.l
  ; visible:1
  ; resizable:1
  ; clickable:1
  ; dirty:1
  ; show_sort_indicator:1
  ; maybe_reordered:1
  ; reorderable:1
  ; use_resized_width:1
  ; expand:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkTreeViewColumnClass
  parent_class.GtkObjectClass
 *clicked
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

