Structure GtkTreeItem
  item.GtkItem
 *subtree.GtkWidget
 *pixmaps_box.GtkWidget
 *plus_pix_widget.GtkWidget
 *minus_pix_widget.GtkWidget
 *pixmaps.GList
  packed_flags.l
  ; expanded:1
  PB_Align(0, 4)
EndStructure

Structure GtkTreeItemClass
  parent_class.GtkItemClass
 *expand
 *collapse
EndStructure

