Structure GtkMenuShell
  container.GtkContainer
 *children.GList
 *active_menu_item.GtkWidget
 *parent_menu_shell.GtkWidget
  button.l
  activate_time.l
  packed_flags.l
  ; active:1
  ; have_grab:1
  ; have_xgrab:1
  ; ignore_leave:1
  ; menu_flag:1
  ; ignore_enter:1
  PB_Align(0, 4)
EndStructure

Structure GtkMenuShellClass
  parent_class.GtkContainerClass
  packed_flags.l
  ; submenu_placement:1
  PB_Align(0, 4)
 *deactivate
 *selection_done
 *move_current
 *activate_current
 *cancel
 *select_item
 *insert
 *get_popup_delay
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
EndStructure

