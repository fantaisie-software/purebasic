Enumeration   ; GHookFlagMask
  #G_HOOK_FLAG_ACTIVE = 1<<0
  #G_HOOK_FLAG_IN_CALL = 1<<1
  #G_HOOK_FLAG_MASK = $0f
EndEnumeration

#G_HOOK_FLAG_USER_SHIFT = (4)
Structure GHookList
  seq_id.i ; gulong
  packed_flags.l
  ; hook_size:16
  ; is_setup:1
  PB_Align(0, 4)
 *hooks.GHook
 *hook_memchunk.GMemChunk
 *finalize_hook.GHookFinalizeFunc
  dummy.i[2]
EndStructure

Structure GHook
  data.i      ; gpointer
 *next.GHook
 *prev.GHook
  ref_count.l ; guint
  PB_Align(0, 4, 0)
  hook_id.i   ; gulong
  flags.l     ; guint
  PB_Align(0, 4, 1)
  func.i      ; gpointer
 *destroy
EndStructure

