Structure GSource
  callback_data.i ; gpointer
 *callback_funcs.GSourceCallbackFuncs
 *source_funcs.GSourceFuncs
  ref_count.l ; guint
  PB_Align(0, 4)
 *context.GMainContext
  priority.l  ; gint
  flags.l     ; guint
  source_id.l ; guint
  PB_Align(0, 4, 1)
 *poll_fds.GSList
 *prev.GSource
 *next.GSource
  reserved1.i ; gpointer
  reserved2.i ; gpointer
EndStructure

Structure GSourceCallbackFuncs
 *ref
 *unref
 *get
EndStructure

Structure GSourceFuncs
 *prepare
 *check
 *dispatch
 *finalize
 *closure_callback.GSourceFunc
 *closure_marshal.GSourceDummyMarshal
EndStructure

Structure GPollFD
  fd.l
  events.w
  revents.w
EndStructure

#G_PRIORITY_HIGH    = -100
#G_PRIORITY_DEFAULT = 0
#G_PRIORITY_HIGH_IDLE = 100
#G_PRIORITY_DEFAULT_IDLE = 200
#G_PRIORITY_LOW = 300
