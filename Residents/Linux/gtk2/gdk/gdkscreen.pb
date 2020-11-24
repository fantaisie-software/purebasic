Structure GdkScreen
  parent_instance.GObject
  packed_flags.l
  ; closed:1
  PB_Align(0, 4)
 *normal_gcs.GdkGC[32]
 *exposure_gcs.GdkGC[32]
 *font_options
  resolution.d
EndStructure

Structure GdkScreenClass
  parent_class.GObjectClass
 *size_changed
 *composited_changed
 *monitors_changed
EndStructure
