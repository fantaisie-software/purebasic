#GDK_CURRENT_TIME = 0
#GDK_PARENT_RELATIVE = 1
#GDK_NONE = 0 ; #_GDK_MAKE_ATOM (0)
Enumeration   ; GdkByteOrder
  #GDK_LSB_FIRST
  #GDK_MSB_FIRST
EndEnumeration

Enumeration   ; GdkModifierType
  #GDK_SHIFT_MASK = 1<<0
  #GDK_LOCK_MASK = 1<<1
  #GDK_CONTROL_MASK = 1<<2
  #GDK_MOD1_MASK = 1<<3
  #GDK_MOD2_MASK = 1<<4
  #GDK_MOD3_MASK = 1<<5
  #GDK_MOD4_MASK = 1<<6
  #GDK_MOD5_MASK = 1<<7
  #GDK_BUTTON1_MASK = 1<<8
  #GDK_BUTTON2_MASK = 1<<9
  #GDK_BUTTON3_MASK = 1<<10
  #GDK_BUTTON4_MASK = 1<<11
  #GDK_BUTTON5_MASK = 1<<12
  #GDK_RELEASE_MASK = 1<<30
  #GDK_MODIFIER_MASK = #GDK_RELEASE_MASK|$1fff
EndEnumeration

Enumeration   ; GdkInputCondition
  #GDK_INPUT_READ = 1<<0
  #GDK_INPUT_WRITE = 1<<1
  #GDK_INPUT_EXCEPTION = 1<<2
EndEnumeration

Enumeration   ; GdkStatus
  #GDK_OK = 0
  #GDK_ERROR = -1
  #GDK_ERROR_PARAM = -2
  #GDK_ERROR_FILE = -3
  #GDK_ERROR_MEM = -4
EndEnumeration

Enumeration   ; GdkGrabStatus
  #GDK_GRAB_SUCCESS = 0
  #GDK_GRAB_ALREADY_GRABBED = 1
  #GDK_GRAB_INVALID_TIME = 2
  #GDK_GRAB_NOT_VIEWABLE = 3
  #GDK_GRAB_FROZEN = 4
EndEnumeration

Structure GdkPoint
  x.l
  y.l
EndStructure

Structure GdkRectangle
  x.l
  y.l
  width.l
  height.l
EndStructure

Structure GdkSegment
  x1.l
  y1.l
  x2.l
  y2.l
EndStructure

Structure GdkSpan
  x.l
  y.l
  width.l
EndStructure

