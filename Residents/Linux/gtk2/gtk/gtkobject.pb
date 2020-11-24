Enumeration   ; GtkObjectFlags
  #GTK_IN_DESTRUCTION = 1<<0
  #GTK_FLOATING = 1<<1
  #GTK_RESERVED_1 = 1<<2
  #GTK_RESERVED_2 = 1<<3
EndEnumeration

Structure GtkObject
  parent_instance.GObject
  flags.l ; guint
  PB_Align(0, 4)
EndStructure

Structure GtkObjectClass
  parent_class.GObjectClass
 *set_arg
 *get_arg
 *destroy
EndStructure

Enumeration   ; GtkArgFlags
  #GTK_ARG_READABLE = #G_PARAM_READABLE
  #GTK_ARG_WRITABLE = #G_PARAM_WRITABLE
  #GTK_ARG_CONSTRUCT = #G_PARAM_CONSTRUCT
  #GTK_ARG_CONSTRUCT_ONLY = #G_PARAM_CONSTRUCT_ONLY
  #GTK_ARG_CHILD_ARG = 1<<4
EndEnumeration

#GTK_ARG_READWRITE = (#GTK_ARG_READABLE|#GTK_ARG_WRITABLE)
