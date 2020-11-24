Structure GtkContainer
  widget.GtkWidget
 *focus_child.GtkWidget
  packed_flags.l
  ; border_width:16
  ; need_resize:1
  ; resize_mode:2
  ; reallocate_redraws:1
  ; has_focus_chain:1
  PB_Align(0, 4)
EndStructure

Structure GtkContainerClass
  parent_class.GtkWidgetClass
 *add
 *remove
 *check_resize
 *forall
 *set_focus_child
 *child_type
 *composite_name
 *set_child_property
 *get_child_property
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

