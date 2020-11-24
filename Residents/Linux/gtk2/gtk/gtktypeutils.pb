; #GTK_TYPE_INVALID = #G_TYPE_INVALID
; #GTK_TYPE_NONE = #G_TYPE_NONE
; #GTK_TYPE_ENUM = #G_TYPE_ENUM
; #GTK_TYPE_FLAGS = #G_TYPE_FLAGS
; #GTK_TYPE_CHAR = #G_TYPE_CHAR
; #GTK_TYPE_UCHAR = #G_TYPE_UCHAR
; #GTK_TYPE_BOOL = #G_TYPE_BOOLEAN
; #GTK_TYPE_INT = #G_TYPE_INT
; #GTK_TYPE_UINT = #G_TYPE_UINT
; #GTK_TYPE_LONG = #G_TYPE_LONG
; #GTK_TYPE_ULONG = #G_TYPE_ULONG
; #GTK_TYPE_FLOAT = #G_TYPE_FLOAT
; #GTK_TYPE_DOUBLE = #G_TYPE_DOUBLE
; #GTK_TYPE_STRING = #G_TYPE_STRING
; #GTK_TYPE_BOXED = #G_TYPE_BOXED
; #GTK_TYPE_POINTER = #G_TYPE_POINTER
; #GTK_TYPE_FUNDAMENTAL_LAST = (#G_TYPE_LAST_RESERVED_FUNDAMENTAL-1)
; #GTK_TYPE_FUNDAMENTAL_MAX = (#G_TYPE_FUNDAMENTAL_MAX)
; #GTK_FUNDAMENTAL_TYPE = #G_TYPE_FUNDAMENTAL
; #GTK_STRUCT_OFFSET = #G_STRUCT_OFFSET
; #GTK_CHECK_CAST = #G_TYPE_CHECK_INSTANCE_CAST
; #GTK_CHECK_CLASS_CAST = #G_TYPE_CHECK_CLASS_CAST
; #GTK_CHECK_GET_CLASS = #G_TYPE_INSTANCE_GET_CLASS
; #GTK_CHECK_TYPE = #G_TYPE_CHECK_INSTANCE_TYPE
; #GTK_CHECK_CLASS_TYPE = #G_TYPE_CHECK_CLASS_TYPE

Structure GtkArg_union
  *f ; GtkSignalFunc
  d.i  ; gpointer
EndStructure


Structure GtkArg
  type.i  ; GType
 *name
  StructureUnion
    char_data.b
    uchar_data.b
    bool_data.l
    int_data.l
    uint_data.l
    long_data.i
    ulong_data.i
    float_data.f
    double_data.d
   *string_data
   *object_data.GtkObject
    pointer_data.i
    signal_data.GtkArg_union
  EndStructureUnion
EndStructure

Structure GtkTypeInfo
 *type_name
  object_size.l          ; guint
  class_size.l  			   ; guint
 *class_init_func      ; GtkClassInitFunc
 *object_init_func     ; GtkObjectInitFunc
  reserved_1.i  		     ; gpointer
  reserved_2.i  		     ; gpointer
 *base_class_init_func ; GtkClassInitFunc
EndStructure

