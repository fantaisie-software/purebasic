Structure GtkCombo
  hbox.GtkHBox
 *entry.GtkWidget
 *button.GtkWidget
 *popup.GtkWidget
 *popwin.GtkWidget
 *list.GtkWidget
  entry_change_id.l
  list_change_id.l
  packed_flags.w
  ; value_in_list:1
  ; ok_if_empty:1
  ; case_sensitive:1
  ; use_arrows:1
  ; use_arrows_always:1
  current_button.w
  activate_id.l
EndStructure

Structure GtkComboClass
  parent_class.GtkHBoxClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

