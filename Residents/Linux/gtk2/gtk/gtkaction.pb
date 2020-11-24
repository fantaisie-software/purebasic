Structure GtkAction
  object.GObject
 *private_data.GtkActionPrivate
EndStructure

Structure GtkActionClass
  parent_class.GObjectClass
 *activate
  menu_item_type.i    ; GType
  toolbar_item_type.i ; GType
 *create_menu_item
 *create_tool_item
 *connect_proxy
 *disconnect_proxy
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

