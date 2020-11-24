Enumeration   ; GtkNotebookTab
  #GTK_NOTEBOOK_TAB_FIRST
  #GTK_NOTEBOOK_TAB_LAST
EndEnumeration

Structure GtkNotebook
  container.GtkContainer
 *cur_page.GtkNotebookPage
 *children.GList
 *first_tab.GList
 *focus_tab.GList
 *menu.GtkWidget
 *event_window.GdkWindow
  timer.l
  tab_hborder.w
  tab_vborder.w
  packed_flags.l
  ; show_tabs:1
  ; homogeneous:1
  ; show_border:1
  ; tab_pos:2
  ; scrollable:1
  ; in_child:3
  ; click_child:3
  ; button:2
  ; need_timer:1
  ; child_has_focus:1
  ; have_visible_child:1
  ; focus_out:1
  ; has_before_previous:1
  ; has_before_next:1
  ; has_after_previous:1
  ; has_after_next:1
  PB_Align(0, 4)
EndStructure

Structure GtkNotebookClass
  parent_class.GtkContainerClass
 *switch_page
 *select_page
 *focus_tab
 *change_current_page
 *move_focus_out
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

