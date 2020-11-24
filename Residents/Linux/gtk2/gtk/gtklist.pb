Structure GtkList
  container.GtkContainer
 *children.GList
 *selection.GList
 *undo_selection.GList
 *undo_unselection.GList
 *last_focus_child.GtkWidget
 *undo_focus_child.GtkWidget
  htimer.l
  vtimer.l
  anchor.l
  drag_pos.l
  anchor_state.l
  packed_flags.l
  ; selection_mode:2
  ; drag_selection:1
  ; add_mode:1
EndStructure

Structure GtkListClass
  parent_class.GtkContainerClass
 *selection_changed
 *select_child
 *unselect_child
EndStructure

