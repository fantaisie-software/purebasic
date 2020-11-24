Structure GtkFileSelection
  parent_instance.GtkDialog
 *dir_list.GtkWidget
 *file_list.GtkWidget
 *selection_entry.GtkWidget
 *selection_text.GtkWidget
 *main_vbox.GtkWidget
 *ok_button.GtkWidget
 *cancel_button.GtkWidget
 *help_button.GtkWidget
 *history_pulldown.GtkWidget
 *history_menu.GtkWidget
 *history_list.GList
 *fileop_dialog.GtkWidget
 *fileop_entry.GtkWidget
 *fileop_file
  cmpl_state.i  ; gpointer
 *fileop_c_dir.GtkWidget
 *fileop_del_file.GtkWidget
 *fileop_ren_file.GtkWidget
 *button_area.GtkWidget
 *action_area.GtkWidget
 *selected_names.GPtrArray
 *last_selected
EndStructure

Structure GtkFileSelectionClass
  parent_class.GtkDialogClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

