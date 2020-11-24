Structure GObject
  g_type_instance.GTypeInstance
  ref_count.l ; guint
  PB_Align(0, 4)
 *qdata.GData
EndStructure

Structure GObjectClass
  g_type_class.GTypeClass
 *construct_properties.GSList
 *constructor
 *set_property
 *get_property
 *dispose
 *finalize
 *dispatch_properties_changed
 *notify
 *constructed
  pdummy.i[7]
EndStructure

Structure GObjectConstructParam
 *pspec.GParamSpec
 *value.GValue
EndStructure

