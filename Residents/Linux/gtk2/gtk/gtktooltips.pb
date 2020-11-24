Structure GtkTooltipsData
 *tooltips.GtkTooltips
 *widget.GtkWidget
 *tip_text
 *tip_private
EndStructure

Structure GtkTooltips
  parent_instance.GtkObject
 *tip_window.GtkWidget
 *tip_label.GtkWidget
 *active_tips_data.GtkTooltipsData
 *tips_data_list.GList
  packed_flags.l[2]
  ; delay:30
  ; enabled:1
  ; have_grab:1
  ; use_sticky_delay:1
  timer_tag.l ; guint
  PB_Align(0, 4)
  last_popdown.GTimeVal
EndStructure

Structure GtkTooltipsClass
  parent_class.GtkObjectClass
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

