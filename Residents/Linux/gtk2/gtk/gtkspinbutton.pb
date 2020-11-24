Enumeration   ; GtkSpinButtonUpdatePolicy
  #GTK_UPDATE_ALWAYS
  #GTK_UPDATE_IF_VALID
EndEnumeration

Enumeration   ; GtkSpinType
  #GTK_SPIN_STEP_FORWARD
  #GTK_SPIN_STEP_BACKWARD
  #GTK_SPIN_PAGE_FORWARD
  #GTK_SPIN_PAGE_BACKWARD
  #GTK_SPIN_HOME
  #GTK_SPIN_END
  #GTK_SPIN_USER_DEFINED
EndEnumeration

Structure GtkSpinButton
  entry.GtkEntry
 *adjustment.GtkAdjustment
 *panel.GdkWindow
  timer.l  ; guint
  PB_Align(0, 4)
  climb_rate.d
  timer_step.d
  update_policy.l
  packed_flags.l
  ; in_child:2
  ; click_child:2
  ; button:2
  ; need_timer:1
  ; timer_calls:3
  ; digits:10.l
  ; numeric:1
  ; wrap:1
  ; snap_to_ticks:1
EndStructure

Structure GtkSpinButtonClass
  parent_class.GtkEntryClass
 *input
 *output
 *value_changed
 *change_value
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

