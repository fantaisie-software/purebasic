
Structure GValue_union
  StructureUnion
    v_int.l
    v_uint.l
    v_long.l
    v_ulong.l
    v_int64.q
    v_uint64.q
    v_float.f
    v_double.d
    v_pointer.i
  EndStructureUnion
EndStructure

Structure GValue
  g_type.i ; gulong
  data.GValue_union[2]
EndStructure

#G_VALUE_NOCOPY_CONTENTS = (1<<27)
