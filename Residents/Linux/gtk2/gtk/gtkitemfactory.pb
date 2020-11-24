Structure GtkItemFactory
  object.GtkObject
 *path
 *accel_group.GtkAccelGroup
 *widget.GtkWidget
 *items.GSList
 *translate_func
  translate_data.i ; gpointer
 *translate_notify
EndStructure

Structure GtkItemFactoryClass
  object_class.GtkObjectClass
 *item_ht.GHashTable
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkItemFactoryEntry
 *path
 *accelerator
 *callback
  callback_action.l ; guint
  PB_Align(0, 4)
 *item_type
 *extra_data
EndStructure

Structure GtkItemFactoryItem
 *path
 *widgets.GSList
EndStructure

Structure GtkMenuEntry
 *path
 *accelerator
 *callback
  callback_data.i ; gpointer
 *widget.GtkWidget
EndStructure

