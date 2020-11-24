Structure GClosureNotifyData
  data.i ; gpointer
 *notify.GClosureNotify
EndStructure

Structure GClosure
  packed_flags.l
  ; ref_count:15
  ; meta_marshal:1
  ; n_guards:1
  ; n_fnotifiers:2
  ; n_inotifiers:8
  ; in_inotify:1
  ; floating:1
  ; derivative_flag:1
  ; in_marshal:1
  ; is_invalid:1
  PB_Align(0, 4)
 *marshal
  data.i ; gpointer
 *notifiers.GClosureNotifyData
EndStructure

Structure GCClosure
  closure.GClosure
  callback.i ; gpointer
EndStructure

