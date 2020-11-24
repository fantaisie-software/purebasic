Enumeration   ; GtkCellRendererState
  #GTK_CELL_RENDERER_SELECTED = 1<<0
  #GTK_CELL_RENDERER_PRELIT = 1<<1
  #GTK_CELL_RENDERER_INSENSITIVE = 1<<2
  #GTK_CELL_RENDERER_SORTED = 1<<3
  #GTK_CELL_RENDERER_FOCUSED = 1<<4
EndEnumeration

Enumeration   ; GtkCellRendererMode
  #GTK_CELL_RENDERER_MODE_INERT
  #GTK_CELL_RENDERER_MODE_ACTIVATABLE
  #GTK_CELL_RENDERER_MODE_EDITABLE
EndEnumeration

Structure GtkCellRenderer
  parent.GtkObject
  xalign.f
  yalign.f
  width.l
  height.l
  xpad.w
  ypad.w
  packed_flags.l
  ; mode:2
  ; visible:1
  ; is_expander:1
  ; is_expanded:1
  ; cell_background_set:1
EndStructure

Structure GtkCellRendererClass
  parent_class.GtkObjectClass
 *get_size
 *render
 *activate
 *start_editing
 *editing_canceled
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
EndStructure

