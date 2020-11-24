Enumeration   ; GSignalFlags
  #G_SIGNAL_RUN_FIRST = 1<<0
  #G_SIGNAL_RUN_LAST = 1<<1
  #G_SIGNAL_RUN_CLEANUP = 1<<2
  #G_SIGNAL_NO_RECURSE = 1<<3
  #G_SIGNAL_DETAILED = 1<<4
  #G_SIGNAL_ACTION = 1<<5
  #G_SIGNAL_NO_HOOKS = 1<<6
EndEnumeration

#G_SIGNAL_FLAGS_MASK = $7f
Enumeration   ; GConnectFlags
  #G_CONNECT_AFTER = 1<<0
  #G_CONNECT_SWAPPED = 1<<1
EndEnumeration

Enumeration   ; GSignalMatchType
  #G_SIGNAL_MATCH_ID = 1<<0
  #G_SIGNAL_MATCH_DETAIL = 1<<1
  #G_SIGNAL_MATCH_CLOSURE = 1<<2
  #G_SIGNAL_MATCH_FUNC = 1<<3
  #G_SIGNAL_MATCH_DATA = 1<<4
  #G_SIGNAL_MATCH_UNBLOCKED = 1<<5
EndEnumeration

#G_SIGNAL_MATCH_MASK = $3f
;#G_SIGNAL_TYPE_STATIC_SCOPE = (#G_TYPE_FLAG_RESERVED_ID_BIT)
Structure GSignalInvocationHint
  signal_id.l
  detail.l
  run_type.l
EndStructure

Structure GSignalQuery
  signal_id.l ; guint
  PB_Align(0, 4, 0)
 *signal_name
  itype.i        ; GType
  signal_flags.l ; GSignalFlags enum
  PB_Align(0, 4, 1)
  return_type.i  ; GType
  n_params.l     ; guint
  PB_Align(0, 4, 2)
 *param_types
EndStructure

