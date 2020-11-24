Structure GtkTable
  container.GtkContainer
 *children.GList
 *rows.GtkTableRowCol
 *cols.GtkTableRowCol
  nrows.w
  ncols.w
  column_spacing.w
  row_spacing.w
  packed_flags.l
  ; homogeneous:1
  PB_Align(0, 4)
EndStructure

Structure GtkTableClass
  parent_class.GtkContainerClass
EndStructure

Structure GtkTableChild
 *widget.GtkWidget
  left_attach.w
  right_attach.w
  top_attach.w
  bottom_attach.w
  xpadding.w
  ypadding.w
  packed_flags.l
  ; xexpand:1
  ; yexpand:1
  ; xshrink:1
  ; yshrink:1
  ; xfill:1
  ; yfill:1
EndStructure

Structure GtkTableRowCol
  requisition.w
  allocation.w
  spacing.w
  packed_flags.w
  ; need_expand:1
  ; need_shrink:1
  ; expand:1
  ; shrink:1
  ; empty:1
EndStructure

