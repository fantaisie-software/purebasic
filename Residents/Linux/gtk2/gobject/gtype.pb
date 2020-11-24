;#G_TYPE_FUNDAMENTAL_MAX = (255<<#G_TYPE_FUNDAMENTAL_SHIFT)
;#G_TYPE_INVALID = #G_TYPE_MAKE_FUNDAMENTAL (0)
;#G_TYPE_NONE = #G_TYPE_MAKE_FUNDAMENTAL (1)
;#G_TYPE_INTERFACE = #G_TYPE_MAKE_FUNDAMENTAL (2)
;#G_TYPE_CHAR = #G_TYPE_MAKE_FUNDAMENTAL (3)
;#G_TYPE_UCHAR = #G_TYPE_MAKE_FUNDAMENTAL (4)
;#G_TYPE_BOOLEAN = #G_TYPE_MAKE_FUNDAMENTAL (5)
;#G_TYPE_INT = #G_TYPE_MAKE_FUNDAMENTAL (6)
;#G_TYPE_UINT = #G_TYPE_MAKE_FUNDAMENTAL (7)
;#G_TYPE_LONG = #G_TYPE_MAKE_FUNDAMENTAL (8)
;#G_TYPE_ULONG = #G_TYPE_MAKE_FUNDAMENTAL (9)
;#G_TYPE_INT64 = #G_TYPE_MAKE_FUNDAMENTAL (10)
;#G_TYPE_UINT64 = #G_TYPE_MAKE_FUNDAMENTAL (11)
;#G_TYPE_ENUM = #G_TYPE_MAKE_FUNDAMENTAL (12)
;#G_TYPE_FLAGS = #G_TYPE_MAKE_FUNDAMENTAL (13)
;#G_TYPE_FLOAT = #G_TYPE_MAKE_FUNDAMENTAL (14)
;#G_TYPE_DOUBLE = #G_TYPE_MAKE_FUNDAMENTAL (15)
;#G_TYPE_STRING = #G_TYPE_MAKE_FUNDAMENTAL (16)
;#G_TYPE_POINTER = #G_TYPE_MAKE_FUNDAMENTAL (17)
;#G_TYPE_BOXED = #G_TYPE_MAKE_FUNDAMENTAL (18)
;#G_TYPE_PARAM = #G_TYPE_MAKE_FUNDAMENTAL (19)
;#G_TYPE_OBJECT = #G_TYPE_MAKE_FUNDAMENTAL (20)
;#G_TYPE_FUNDAMENTAL_SHIFT = (2)
;#G_TYPE_RESERVED_GLIB_FIRST = (21)
;#G_TYPE_RESERVED_GLIB_LAST = (31)
;#G_TYPE_RESERVED_BSE_FIRST = (32)
;#G_TYPE_RESERVED_BSE_LAST = (48)
;#G_TYPE_RESERVED_USER_FIRST = (49)
Structure GTypeClass
  g_type.i ; gulong
EndStructure

Structure GTypeInstance
 *g_class.GTypeClass
EndStructure

Structure GTypeInterface
  g_type.i          ; GType
  g_instance_type.i ; GType
EndStructure

Structure GTypeQuery
  type.i ; GType
 *type_name
  class_size.l    ; guint
  instance_size.l ; guint
EndStructure

Enumeration   ; GTypeDebugFlags
  #G_TYPE_DEBUG_NONE = 0
  #G_TYPE_DEBUG_OBJECTS = 1<<0
  #G_TYPE_DEBUG_SIGNALS = 1<<1
  #G_TYPE_DEBUG_MASK = $03
EndEnumeration

Enumeration   ; GTypeFundamentalFlags
  #G_TYPE_FLAG_CLASSED = (1<<0)
  #G_TYPE_FLAG_INSTANTIATABLE = (1<<1)
  #G_TYPE_FLAG_DERIVABLE = (1<<2)
  #G_TYPE_FLAG_DEEP_DERIVABLE = (1<<3)
EndEnumeration

Enumeration   ; GTypeFlags
  #G_TYPE_FLAG_ABSTRACT = (1<<4)
  #G_TYPE_FLAG_VALUE_ABSTRACT = (1<<5)
EndEnumeration

Structure GTypeInfo
  class_size.w     ; guint16
  PB_Align(2, 6)
 *base_init.GBaseInitFunc
 *base_finalize.GBaseFinalizeFunc
 *class_init.GClassInitFunc
 *class_finalize.GClassFinalizeFunc
 *class_data.gconstpointer
  instance_size.w ; guint16
  n_preallocs.w   ; guint16
  PB_Align(0, 4, 1)
 *instance_init.GInstanceInitFunc
 *value_table.GTypeValueTable
EndStructure

Structure GTypeFundamentalInfo
  type_flags.l
EndStructure

Structure GInterfaceInfo
 *interface_init.GInterfaceInitFunc
 *interface_finalize.GInterfaceFinalizeFunc
  interface_data.i ; gpointer
EndStructure

Structure GTypeValueTable
 *value_init
 *value_free
 *value_copy
 *value_peek_pointer
 *collect_format
 *collect_value
 *lcopy_format
 *lcopy_value
EndStructure

