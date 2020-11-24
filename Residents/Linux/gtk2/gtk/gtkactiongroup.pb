Structure GtkActionGroup
  parent.GObject
 *private_data.GtkActionGroupPrivate
EndStructure

Structure GtkActionGroupClass
  parent_class.GObjectClass
 *action_name
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

Structure GtkActionEntry
 *name
 *stock_id
 *label
 *accelerator
 *tooltip
 *callback
EndStructure

Structure GtkToggleActionEntry
 *name
 *stock_id
 *label
 *accelerator
 *tooltip
 *callback
  is_active.l ; gboolean
  PB_Align(0, 4)
EndStructure

Structure GtkRadioActionEntry
 *name
 *stock_id
 *label
 *accelerator
 *tooltip
  value.l ; gint
  PB_Align(0, 4)
EndStructure

