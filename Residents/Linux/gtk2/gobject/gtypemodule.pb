Structure GTypeModule
  parent_instance.GObject
  use_count.l ; guint
  PB_Align(0,4)
 *type_infos.GSList
 *interface_infos.GSList
 *name
EndStructure

Structure GTypeModuleClass
  parent_class.GObjectClass
 *load
 *unload
 *reserved
 *reserved2
 *reserved3
 *reserved4
EndStructure

