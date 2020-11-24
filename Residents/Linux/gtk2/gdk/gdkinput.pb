Enumeration   ; GdkExtensionMode
  #GDK_EXTENSION_EVENTS_NONE
  #GDK_EXTENSION_EVENTS_ALL
  #GDK_EXTENSION_EVENTS_CURSOR
EndEnumeration

Enumeration   ; GdkInputSource
  #GDK_SOURCE_MOUSE
  #GDK_SOURCE_PEN
  #GDK_SOURCE_ERASER
  #GDK_SOURCE_CURSOR
EndEnumeration

Enumeration   ; GdkInputMode
  #GDK_MODE_DISABLED
  #GDK_MODE_SCREEN
  #GDK_MODE_WINDOW
EndEnumeration

Enumeration   ; GdkAxisUse
  #GDK_AXIS_IGNORE
  #GDK_AXIS_X
  #GDK_AXIS_Y
  #GDK_AXIS_PRESSURE
  #GDK_AXIS_XTILT
  #GDK_AXIS_YTILT
  #GDK_AXIS_WHEEL
  #GDK_AXIS_LAST
EndEnumeration

Structure GdkDeviceKey
  keyval.l
  modifiers.l
EndStructure

Structure GdkDeviceAxis
  use.l  ; GdkAxisUse enum
  PB_Align(0, 4)
  min.d
  max.d
EndStructure

Structure GdkDevice
  parent_instance.GObject
 *name
  source.l     ; GdkInputSource enum
  mode.l       ; GdkInputMode enum
  has_cursor.l ; gboolean
  num_axes.l   ; gint
 *axes.GdkDeviceAxis
  num_keys.l   ; gint
  PB_Align(0, 4)
 *keys.GdkDeviceKey
EndStructure

#GDK_MAX_TIMECOORD_AXES = 128
Structure GdkTimeCoord
  time.l ; guint
  PB_Align(0, 4)
  axes.d[#GDK_MAX_TIMECOORD_AXES]
EndStructure

