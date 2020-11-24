Structure GtkBindingSet
 *set_name
  priority.l  ; gint
  PB_Align(0, 4)
 *widget_path_pspecs.GSList
 *widget_class_pspecs.GSList
 *class_branch_pspecs.GSList
 *entries.GtkBindingEntry
 *current.GtkBindingEntry
  packed_flags.l
  ; parsed:1
  PB_Align(0, 4, 1)
EndStructure

Structure GtkBindingEntry
  keyval.l
  modifiers.l
 *binding_set.GtkBindingSet
  packed_flags.l
  ; destroyed:1
  ; in_emission:1
  PB_Align(0, 4)
 *set_next.GtkBindingEntry
 *hash_next.GtkBindingEntry
 *signals.GtkBindingSignal
EndStructure

Structure GtkBindingSignal
 *next.GtkBindingSignal
 *signal_name
  n_args.l ; guint
  PB_Align(0, 4)
 *args.GtkBindingArg
EndStructure

Structure GtkBindingArg
  arg_type.i ; GType
  StructureUnion
    long_data.i
    double_data.d
   *string_data
  EndStructureUnion
EndStructure

