Structure GtkAccelLabel
  label.GtkLabel
  gtk_reserved.l
  accel_padding.l
 *accel_widget.GtkWidget
 *accel_closure.GClosure
 *accel_group.GtkAccelGroup
 *accel_string
  accel_string_width.w
  PB_Align(2, 6)
EndStructure

Structure GtkAccelLabelClass
  parent_class.GtkLabelClass
 *signal_quote1
 *signal_quote2
 *mod_name_shift
 *mod_name_control
 *mod_name_alt
 *mod_separator
 *accel_seperator
  packed_flags.l
  ; latin1_to_char:1
  PB_Align(0, 4)
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
EndStructure

