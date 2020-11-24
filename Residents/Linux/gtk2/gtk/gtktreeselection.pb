Structure GtkTreeSelection
  parent.GObject
 *tree_view.GtkTreeView
  type.l  ; GtkSelectionMode enum
  PB_Align(0, 4)
 *user_func
  user_data.i ; gpointer
 *destroy
EndStructure

Structure GtkTreeSelectionClass
  parent_class.GObjectClass
 *changed
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

