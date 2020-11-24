Enumeration   ; GParamFlags
  #G_PARAM_READABLE = 1<<0
  #G_PARAM_WRITABLE = 1<<1
  #G_PARAM_CONSTRUCT = 1<<2
  #G_PARAM_CONSTRUCT_ONLY = 1<<3
  #G_PARAM_LAX_VALIDATION = 1<<4
  #G_PARAM_PRIVATE = 1<<5
EndEnumeration

#G_PARAM_READWRITE = (#G_PARAM_READABLE|#G_PARAM_WRITABLE)
#G_PARAM_MASK = ($000000ff)
#G_PARAM_USER_SHIFT = (8)
Structure GParamSpec
  g_type_instance.GTypeInstance
 *name
  flags.l ; GParamFlags enum
  PB_Align(0, 4)
  value_type.i ; gulong
  owner_type.i ; gulong
 *_nick
 *_blurb
 *qdata.GData
  ref_count.l
  param_id.l
EndStructure

Structure GParamSpecClass
  g_type_class.GTypeClass
  value_type.i ; GType
 *finalize
 *value_set_default
 *value_validate
 *values_cmp
  dummy.i[4]
EndStructure

Structure GParameter
 *name
  value.GValue
EndStructure

Structure GParamSpecTypeInfo
  instance_size.w
  n_preallocs.w
  PB_Align(0, 4)
 *instance_init
  value_type.i ; GType
 *finalize
 *value_set_default
 *value_validate
 *values_cmp
EndStructure

