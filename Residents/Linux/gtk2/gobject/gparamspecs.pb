Structure GParamSpecChar
  parent_instance.GParamSpec
  minimum.b
  maximum.b
  default_value.b
  PB_Align(1, 5)
EndStructure

Structure GParamSpecUChar
  parent_instance.GParamSpec
  minimum.b
  maximum.b
  default_value.b
  PB_Align(1, 5)
EndStructure

Structure GParamSpecBoolean
  parent_instance.GParamSpec
  default_value.l ; gboolean
  PB_Align(0, 4)
EndStructure

Structure GParamSpecInt
  parent_instance.GParamSpec
  minimum.l
  maximum.l
  default_value.l
  PB_Align(0, 4)
EndStructure

Structure GParamSpecUInt
  parent_instance.GParamSpec
  minimum.l
  maximum.l
  default_value.l
  PB_Align(0, 4)
EndStructure

Structure GParamSpecLong
  parent_instance.GParamSpec
  minimum.i
  maximum.i
  default_value.i
EndStructure

Structure GParamSpecULong
  parent_instance.GParamSpec
  minimum.i
  maximum.i
  default_value.i
EndStructure

Structure GParamSpecInt64
  parent_instance.GParamSpec
  minimum.q
  maximum.q
  default_value.q
EndStructure

Structure GParamSpecUInt64
  parent_instance.GParamSpec
  minimum.q
  maximum.q
  default_value.q
EndStructure

Structure GParamSpecUnichar
  parent_instance.GParamSpec
  default_value.l ; gunichar
  PB_Align(0, 4)
EndStructure

Structure GParamSpecEnum
  parent_instance.GParamSpec
 *enum_class.GEnumClass
  default_value.l
  PB_Align(0, 4)
EndStructure

Structure GParamSpecFlags
  parent_instance.GParamSpec
 *flags_class.GFlagsClass
  default_value.l
  PB_Align(0, 4)
EndStructure

Structure GParamSpecFloat
  parent_instance.GParamSpec
  minimum.f
  maximum.f
  default_value.f
  epsilon.f
EndStructure

Structure GParamSpecDouble
  parent_instance.GParamSpec
  minimum.d
  maximum.d
  default_value.d
  epsilon.d
EndStructure

Structure GParamSpecString
  parent_instance.GParamSpec
 *default_value
 *cset_first
 *cset_nth
  substitutor.b
  pad.b
  packed_flags.w
  ; null_fold_if_empty:1
  ; ensure_non_null:1
  PB_Align(0, 4)
EndStructure

Structure GParamSpecParam
  parent_instance.GParamSpec
EndStructure

Structure GParamSpecBoxed
  parent_instance.GParamSpec
EndStructure

Structure GParamSpecPointer
  parent_instance.GParamSpec
EndStructure

Structure GParamSpecValueArray
  parent_instance.GParamSpec
 *element_spec.GParamSpec
  fixed_n_elements.l ; guint
  PB_Align(0, 4)
EndStructure

Structure GParamSpecObject
  parent_instance.GParamSpec
EndStructure

Structure GParamSpecOverride
  parent_instance.GParamSpec
 *overridden.GParamSpec
EndStructure

