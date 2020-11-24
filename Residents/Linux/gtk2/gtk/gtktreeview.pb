Enumeration   ; GtkTreeViewDropPosition
  #GTK_TREE_VIEW_DROP_BEFORE
  #GTK_TREE_VIEW_DROP_AFTER
  #GTK_TREE_VIEW_DROP_INTO_OR_BEFORE
  #GTK_TREE_VIEW_DROP_INTO_OR_AFTER
EndEnumeration

Structure GtkTreeView
  parent.GtkContainer
 *priv.GtkTreeViewPrivate
EndStructure

Structure GtkTreeViewClass
  parent_class.GtkContainerClass
 *set_scroll_adjustments
 *row_activated
 *test_expand_row
 *test_collapse_row
 *row_expanded
 *row_collapsed
 *columns_changed
 *cursor_changed
 *move_cursor
 *select_all
 *unselect_all
 *select_cursor_row
 *toggle_cursor_row
 *expand_collapse_cursor_row
 *select_cursor_parent
 *start_interactive_search
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
 *_gtk_reserved5
EndStructure

