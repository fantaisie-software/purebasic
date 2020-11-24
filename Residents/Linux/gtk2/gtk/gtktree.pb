Enumeration   ; GtkTreeViewMode
  #GTK_TREE_VIEW_LINE
  #GTK_TREE_VIEW_ITEM
EndEnumeration

Structure GtkTree
  container.GtkContainer
 *children.GList
 *root_tree.GtkTree
 *tree_owner.GtkWidget
 *selection.GList
  level.l
  indent_value.l
  current_indent.l
  packed_flags.l
  ; selection_mode:2
  ; view_mode:1
  ; view_line:1
EndStructure

Structure GtkTreeClass
  parent_class.GtkContainerClass
 *selection_changed
 *select_child
 *unselect_child
EndStructure

