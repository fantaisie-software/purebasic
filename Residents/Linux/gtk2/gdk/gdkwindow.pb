Enumeration   ; GdkWindowClass
  #GDK_INPUT_OUTPUT
  #GDK_INPUT_ONLY
EndEnumeration

Enumeration   ; GdkWindowType
  #GDK_WINDOW_ROOT
  #GDK_WINDOW_TOPLEVEL
  #GDK_WINDOW_CHILD
  #GDK_WINDOW_TEMP
  #GDK_WINDOW_FOREIGN
  #GDK_WINDOW_OFFSCREEN
EndEnumeration


Enumeration   ; GdkWindowAttributesType
  #GDK_WA_TITLE = 1<<1
  #GDK_WA_X = 1<<2
  #GDK_WA_Y = 1<<3
  #GDK_WA_CURSOR = 1<<4
  #GDK_WA_COLORMAP = 1<<5
  #GDK_WA_VISUAL = 1<<6
  #GDK_WA_WMCLASS = 1<<7
  #GDK_WA_NOREDIR = 1<<8
EndEnumeration

Enumeration   ; GdkWindowHints
  #GDK_HINT_POS = 1<<0
  #GDK_HINT_MIN_SIZE = 1<<1
  #GDK_HINT_MAX_SIZE = 1<<2
  #GDK_HINT_BASE_SIZE = 1<<3
  #GDK_HINT_ASPECT = 1<<4
  #GDK_HINT_RESIZE_INC = 1<<5
  #GDK_HINT_WIN_GRAVITY = 1<<6
  #GDK_HINT_USER_POS = 1<<7
  #GDK_HINT_USER_SIZE = 1<<8
EndEnumeration

Enumeration   ; GdkWindowTypeHint
  #GDK_WINDOW_TYPE_HINT_NORMAL
  #GDK_WINDOW_TYPE_HINT_DIALOG
  #GDK_WINDOW_TYPE_HINT_MENU
  #GDK_WINDOW_TYPE_HINT_TOOLBAR
  #GDK_WINDOW_TYPE_HINT_SPLASHSCREEN
  #GDK_WINDOW_TYPE_HINT_UTILITY
  #GDK_WINDOW_TYPE_HINT_DOCK
  #GDK_WINDOW_TYPE_HINT_DESKTOP
EndEnumeration

Enumeration   ; GdkWMDecoration
  #GDK_DECOR_ALL = 1<<0
  #GDK_DECOR_BORDER = 1<<1
  #GDK_DECOR_RESIZEH = 1<<2
  #GDK_DECOR_TITLE = 1<<3
  #GDK_DECOR_MENU = 1<<4
  #GDK_DECOR_MINIMIZE = 1<<5
  #GDK_DECOR_MAXIMIZE = 1<<6
EndEnumeration

Enumeration   ; GdkWMFunction
  #GDK_FUNC_ALL = 1<<0
  #GDK_FUNC_RESIZE = 1<<1
  #GDK_FUNC_MOVE = 1<<2
  #GDK_FUNC_MINIMIZE = 1<<3
  #GDK_FUNC_MAXIMIZE = 1<<4
  #GDK_FUNC_CLOSE = 1<<5
EndEnumeration

Enumeration   ; GdkGravity
  #GDK_GRAVITY_NORTH_WEST = 1
  #GDK_GRAVITY_NORTH
  #GDK_GRAVITY_NORTH_EAST
  #GDK_GRAVITY_WEST
  #GDK_GRAVITY_CENTER
  #GDK_GRAVITY_EAST
  #GDK_GRAVITY_SOUTH_WEST
  #GDK_GRAVITY_SOUTH
  #GDK_GRAVITY_SOUTH_EAST
  #GDK_GRAVITY_STATIC
EndEnumeration

Enumeration   ; GdkWindowEdge
  #GDK_WINDOW_EDGE_NORTH_WEST
  #GDK_WINDOW_EDGE_NORTH
  #GDK_WINDOW_EDGE_NORTH_EAST
  #GDK_WINDOW_EDGE_WEST
  #GDK_WINDOW_EDGE_EAST
  #GDK_WINDOW_EDGE_SOUTH_WEST
  #GDK_WINDOW_EDGE_SOUTH
  #GDK_WINDOW_EDGE_SOUTH_EAST
EndEnumeration

Structure GdkWindowAttr
 *title
  event_mask.l ; gint
  x.l					 ; gint
  y.l					 ; gint
  width.l			 ; gint
  height.l		 ; gint
  wclass.l		 ; GdkWindowClass enum
 *visual.GdkVisual
 *colormap.GdkColormap
  window_type.l ; GdkWindowType enum
  PB_Align(0, 4)
 *cursor.GdkCursor
 *wmclass_name
 *wmclass_class
  override_redirect.l ; gboolean
  type_hint.l         ; GdkWindowTypeHint enum
EndStructure

Structure GdkGeometry
  min_width.l
  min_height.l
  max_width.l
  max_height.l
  base_width.l
  base_height.l
  width_inc.l
  height_inc.l
  min_aspect.d
  max_aspect.d
  win_gravity.l ; GdkGravity enum
  PB_Align(0, 4)
EndStructure

Structure GdkPointerHooks
 *get_pointer
 *window_at_pointer
EndStructure

Structure GdkWindowObject
  parent_instance.GdkDrawable
 *impl.GdkDrawable
 *parent.GdkWindowObject
  user_data.i  ; gpointer
  x.l					 ; gint
  y.l					 ; gint
  extension_events.l ; gint
  PB_Align(0, 4, 0)
 *filters.GList
 *children.GList
  bg_color.GdkColor
  PB_Align(0, 4, 1) ; GdkColor is 12 bytes long, even on x64
 *bg_pixmap.GdkPixmap
 *paint_stack.GSList
 *update_area.GdkRegion
  update_freeze_count.l ; guint
  window_type.b
  depth.b
  resize_count.b
  PB_Align(1, 1, 2)
  state.l  ; GdkWindowState enum
  packed_flags.l
  ; guffaw_gravity:1
  ; input_only:1
  ; modal_hint:1
  ; destroyed:2
  ; accept_focus:1
  event_mask.l                          ; GdkEventMask enum
  update_and_descendants_freeze_count.l ; guint
  *redirect
EndStructure

Structure GdkWindowObjectClass
  parent_class.GdkDrawableClass
EndStructure

