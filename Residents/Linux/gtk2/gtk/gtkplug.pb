Structure GtkPlug
  window.GtkWindow
 *socket_window.GdkWindow
 *modality_window.GtkWidget
 *modality_group.GtkWindowGroup
 *grabbed_keys.GHashTable
  packed_flags.l
  ; same_app:1
  PB_Align(0, 4)
EndStructure

Structure GtkPlugClass
  parent_class.GtkWindowClass
 *embedded
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

