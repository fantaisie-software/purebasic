Enumeration   ; GtkDialogFlags
  #GTK_DIALOG_MODAL = 1<<0
  #GTK_DIALOG_DESTROY_WITH_PARENT = 1<<1
  #GTK_DIALOG_NO_SEPARATOR = 1<<2
EndEnumeration

Enumeration   ; GtkResponseType
  #GTK_RESPONSE_NONE = -1
  #GTK_RESPONSE_REJECT = -2
  #GTK_RESPONSE_ACCEPT = -3
  #GTK_RESPONSE_DELETE_EVENT = -4
  #GTK_RESPONSE_OK = -5
  #GTK_RESPONSE_CANCEL = -6
  #GTK_RESPONSE_CLOSE = -7
  #GTK_RESPONSE_YES = -8
  #GTK_RESPONSE_NO = -9
  #GTK_RESPONSE_APPLY = -10
  #GTK_RESPONSE_HELP = -11
EndEnumeration

Structure GtkDialog
  window.GtkWindow
 *vbox.GtkWidget
 *action_area.GtkWidget
 *separator.GtkWidget
EndStructure

Structure GtkDialogClass
  parent_class.GtkWindowClass
 *response
 *close
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

