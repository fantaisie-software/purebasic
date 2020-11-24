Structure GtkUIManager
  parent.GObject
 *private_data.GtkUIManagerPrivate
EndStructure

Structure GtkUIManagerClass
  parent_class.GObjectClass
 *add_widget
 *actions_changed
 *connect_proxy
 *disconnect_proxy
 *pre_activate
 *post_activate
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Enumeration   ; GtkUIManagerItemType
  #GTK_UI_MANAGER_AUTO = 0
  #GTK_UI_MANAGER_MENUBAR = 1<<0
  #GTK_UI_MANAGER_MENU = 1<<1
  #GTK_UI_MANAGER_TOOLBAR = 1<<2
  #GTK_UI_MANAGER_PLACEHOLDER = 1<<3
  #GTK_UI_MANAGER_POPUP = 1<<4
  #GTK_UI_MANAGER_MENUITEM = 1<<5
  #GTK_UI_MANAGER_TOOLITEM = 1<<6
  #GTK_UI_MANAGER_SEPARATOR = 1<<7
  #GTK_UI_MANAGER_ACCELERATOR = 1<<8
EndEnumeration

