Enumeration   ; GdkCapStyle
  #GDK_CAP_NOT_LAST
  #GDK_CAP_BUTT
  #GDK_CAP_ROUND
  #GDK_CAP_PROJECTING
EndEnumeration

Enumeration   ; GdkFill
  #GDK_SOLID
  #GDK_TILED
  #GDK_STIPPLED
  #GDK_OPAQUE_STIPPLED
EndEnumeration

Enumeration   ; GdkFunction
  #GDK_COPY
  #GDK_INVERT
  #GDK_XOR
  #GDK_CLEAR
  #GDK_AND
  #GDK_AND_REVERSE
  #GDK_AND_INVERT
  #GDK_NOOP
  #GDK_OR
  #GDK_EQUIV
  #GDK_OR_REVERSE
  #GDK_COPY_INVERT
  #GDK_OR_INVERT
  #GDK_NAND
  #GDK_NOR
  #GDK_SET
EndEnumeration

Enumeration   ; GdkJoinStyle
  #GDK_JOIN_MITER
  #GDK_JOIN_ROUND
  #GDK_JOIN_BEVEL
EndEnumeration

Enumeration   ; GdkLineStyle
  #GDK_LINE_SOLID
  #GDK_LINE_ON_OFF_DASH
  #GDK_LINE_DOUBLE_DASH
EndEnumeration

Enumeration   ; GdkSubwindowMode
  #GDK_CLIP_BY_CHILDREN = 0
  #GDK_INCLUDE_INFERIORS = 1
EndEnumeration

Enumeration   ; GdkGCValuesMask
  #GDK_GC_FOREGROUND = 1<<0
  #GDK_GC_BACKGROUND = 1<<1
  #GDK_GC_FONT = 1<<2
  #GDK_GC_FUNCTION = 1<<3
  #GDK_GC_FILL = 1<<4
  #GDK_GC_TILE = 1<<5
  #GDK_GC_STIPPLE = 1<<6
  #GDK_GC_CLIP_MASK = 1<<7
  #GDK_GC_SUBWINDOW = 1<<8
  #GDK_GC_TS_X_ORIGIN = 1<<9
  #GDK_GC_TS_Y_ORIGIN = 1<<10
  #GDK_GC_CLIP_X_ORIGIN = 1<<11
  #GDK_GC_CLIP_Y_ORIGIN = 1<<12
  #GDK_GC_EXPOSURES = 1<<13
  #GDK_GC_LINE_WIDTH = 1<<14
  #GDK_GC_LINE_STYLE = 1<<15
  #GDK_GC_CAP_STYLE = 1<<16
  #GDK_GC_JOIN_STYLE = 1<<17
EndEnumeration

Structure GdkGCValues
  foreground.GdkColor
  background.GdkColor
 *font.GdkFont
  function.l
  fill.l
 *tile.GdkPixmap
 *stipple.GdkPixmap
 *clip_mask.GdkPixmap
  subwindow_mode.l
  ts_x_origin.l
  ts_y_origin.l
  clip_x_origin.l
  clip_y_origin.l
  graphics_exposures.l
  line_width.l
  line_style.l
  cap_style.l
  join_style.l
EndStructure

Structure GdkGC
  parent_instance.GObject
  clip_x_origin.l
  clip_y_origin.l
  ts_x_origin.l
  ts_y_origin.l
 *colormap.GdkColormap
EndStructure

Structure GdkGCClass
  parent_class.GObjectClass
 *get_values
 *set_values
 *set_dashes
 *_gdk_reserved
 *_gdk_reserved2
 *_gdk_reserved3
 *_gdk_reserved4
EndStructure

