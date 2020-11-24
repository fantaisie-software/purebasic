Enumeration   ; GtkCellType
  #GTK_CELL_EMPTY
  #GTK_CELL_TEXT
  #GTK_CELL_PIXMAP
  #GTK_CELL_PIXTEXT
  #GTK_CELL_WIDGET
EndEnumeration

Enumeration   ; GtkCListDragPos
  #GTK_CLIST_DRAG_NONE
  #GTK_CLIST_DRAG_BEFORE
  #GTK_CLIST_DRAG_INTO
  #GTK_CLIST_DRAG_AFTER
EndEnumeration

Enumeration   ; GtkButtonAction
  #GTK_BUTTON_IGNORED = 0
  #GTK_BUTTON_SELECTS = 1<<0
  #GTK_BUTTON_DRAGS = 1<<1
  #GTK_BUTTON_EXPANDS = 1<<2
EndEnumeration

Structure GtkCListCellInfo
  row.l
  column.l
EndStructure

Structure GtkCListDestInfo
  cell.GtkCListCellInfo
  insert_pos.l
EndStructure

Structure GtkCList
  container.GtkContainer
  flags.w
  PB_Align(2, 6)
 *row_mem_chunk.GMemChunk
 *cell_mem_chunk.GMemChunk
  freeze_count.l
  PB_Align(0, 4, 1)
  internal_allocation.GdkRectangle
  rows.l
  row_height.l
 *row_list.GList
 *row_list_end.GList
  columns.l
  PB_Align(0, 4, 2)
  column_title_area.GdkRectangle
 *title_window.GdkWindow
 *column.GtkCListColumn
 *clist_window.GdkWindow
  clist_window_width.l
  clist_window_height.l
  hoffset.l
  voffset.l
  shadow_type.l
  selection_mode.l
 *selection.GList
 *selection_end.GList
 *undo_selection.GList
 *undo_unselection.GList
  undo_anchor.l
  button_actions.b[5]
  drag_button.b
  PB_Align(2, 6, 3)
  click_cell.GtkCListCellInfo
 *hadjustment.GtkAdjustment
 *vadjustment.GtkAdjustment
 *xor_gc.GdkGC
 *fg_gc.GdkGC
 *bg_gc.GdkGC
 *cursor_drag.GdkCursor
  x_drag.l
  focus_row.l
  focus_header_column.l
  anchor.l
  anchor_state.l
  drag_pos.l
  htimer.l
  vtimer.l
  sort_type.l  ; GtkSortType enum
  PB_Align(0, 4, 4)
 *compare
  sort_column.l
  drag_highlight_row.l
  drag_highlight_pos.l
  PB_Align(0, 4, 5)
EndStructure

Structure GtkCListClass
  parent_class.GtkContainerClass
 *set_scroll_adjustments
 *refresh
 *select_row
 *unselect_row
 *row_move
 *click_column
 *resize_column
 *toggle_focus_row
 *select_all
 *unselect_all
 *undo_selection
 *start_selection
 *end_selection
 *extend_selection
 *scroll_horizontal
 *scroll_vertical
 *toggle_add_mode
 *abort_column_resize
 *resync_selection
 *selection_find
 *draw_row
 *draw_drag_highlight
 *clear
 *fake_unselect_all
 *sort_list
 *insert_row
 *remove_row
 *set_cell_contents
 *cell_size_request
EndStructure

Structure GtkCListColumn
 *title
  area.GdkRectangle
 *button.GtkWidget
 *window.GdkWindow
  width.l
  min_width.l
  max_width.l
  justification.l
  packed_flags.l
  ; visible:1
  ; width_set:1
  ; resizeable:1
  ; auto_resize:1
  ; button_passive:1
  PB_Align(0, 4)
EndStructure

Structure GtkCListRow
 *cell.GtkCell
  state.l  ; GtkStateType enum
  PB_Align(0, 4)
  foreground.GdkColor
  background.GdkColor
 *style.GtkStyle
  data.i   ; gpointer
 *destroy
  packed_flags.l
  ; fg_set:1
  ; bg_set:1
  ; selectable:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkCellText
  type.l
  vertical.w
  horizontal.w
 *style.GtkStyle
 *text
EndStructure

Structure GtkCellPixmap
  type.l
  vertical.w
  horizontal.w
 *style.GtkStyle
 *pixmap.GdkPixmap
 *mask.GdkBitmap
EndStructure

Structure GtkCellPixText
  type.l
  vertical.w
  horizontal.w
 *style.GtkStyle
 *text
  spacing.b
  PB_Align(3, 7)
 *pixmap.GdkPixmap
 *mask.GdkBitmap
EndStructure

Structure GtkCellWidget
  type.l
  vertical.w
  horizontal.w
 *style.GtkStyle
 *widget.GtkWidget
EndStructure

Structure GtkCell_pm
  *pixmap.GdkPixmap
  *mask.GdkPixmap
EndStructure
          
Structure GtkCell_pt
 *text
  spacing.b
  PB_Align(3, 7)
 *pixmap.GdkPixmap
 *mask.GdkBitmap
EndStructure

Structure GtkCell
  type.l      ; GtkCellType enum
  vertical.w
  horizontal.w
 *style.GtkStyle
  StructureUnion
   *text
   pm.GtkCell_pm
   pt.GtkCell_pt
   *widget.GtkWidget
  EndStructureUnion
EndStructure

