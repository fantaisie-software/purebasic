Enumeration   ; GtkMessageType
  #GTK_MESSAGE_INFO
  #GTK_MESSAGE_WARNING
  #GTK_MESSAGE_QUESTION
  #GTK_MESSAGE_ERROR
EndEnumeration

Enumeration   ; GtkButtonsType
  #GTK_BUTTONS_NONE
  #GTK_BUTTONS_OK
  #GTK_BUTTONS_CLOSE
  #GTK_BUTTONS_CANCEL
  #GTK_BUTTONS_YES_NO
  #GTK_BUTTONS_OK_CANCEL
EndEnumeration

Structure GtkMessageDialog
  parent_instance.GtkDialog
 *image.GtkWidget
 *label.GtkWidget
EndStructure

Structure GtkMessageDialogClass
  parent_class.GtkDialogClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

