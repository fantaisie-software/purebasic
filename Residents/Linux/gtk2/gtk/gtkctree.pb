Enumeration   ; GtkCTreePos
  #GTK_CTREE_POS_BEFORE
  #GTK_CTREE_POS_AS_CHILD
  #GTK_CTREE_POS_AFTER
EndEnumeration

Enumeration   ; GtkCTreeLineStyle
  #GTK_CTREE_LINES_NONE
  #GTK_CTREE_LINES_SOLID
  #GTK_CTREE_LINES_DOTTED
  #GTK_CTREE_LINES_TABBED
EndEnumeration

Enumeration   ; GtkCTreeExpanderStyle
  #GTK_CTREE_EXPANDER_NONE
  #GTK_CTREE_EXPANDER_SQUARE
  #GTK_CTREE_EXPANDER_TRIANGLE
  #GTK_CTREE_EXPANDER_CIRCULAR
EndEnumeration

Enumeration   ; GtkCTreeExpansionType
  #GTK_CTREE_EXPANSION_EXPAND
  #GTK_CTREE_EXPANSION_EXPAND_RECURSIVE
  #GTK_CTREE_EXPANSION_COLLAPSE
  #GTK_CTREE_EXPANSION_COLLAPSE_RECURSIVE
  #GTK_CTREE_EXPANSION_TOGGLE
  #GTK_CTREE_EXPANSION_TOGGLE_RECURSIVE
EndEnumeration

Structure GtkCTree
  clist.GtkCList
 *lines_gc.GdkGC
  tree_indent.l
  tree_spacing.l
  tree_column.l
  packed_flags.l
  ; line_style:2
  ; expander_style:2
  ; show_stub:1
 *drag_compare
EndStructure

Structure GtkCTreeClass
  parent_class.GtkCListClass
 *tree_select_row
 *tree_unselect_row
 *tree_expand
 *tree_collapse
 *tree_move
 *change_focus_row_expansion
EndStructure

Structure GtkCTreeRow
  row.GtkCListRow
 *parent.GtkCTreeNode
 *sibling.GtkCTreeNode
 *children.GtkCTreeNode
 *pixmap_closed.GdkPixmap
 *mask_closed.GdkBitmap
 *pixmap_opened.GdkPixmap
 *mask_opened.GdkBitmap
  level.w
  packed_flags.w
  ; is_leaf:1
  ; expanded:1
  PB_Align(0, 4)
EndStructure

Structure GtkCTreeNode
  list.GList
EndStructure

