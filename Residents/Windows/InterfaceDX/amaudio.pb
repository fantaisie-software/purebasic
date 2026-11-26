
; IAMDirectSound interface definition
;
Interface IAMDirectSound Extends IUnknown
  GetDirectSoundInterface(a.l)
  GetPrimaryBufferInterface(a.l)
  GetSecondaryBufferInterface(a.l)
  ReleaseDirectSoundInterface(a.l)
  ReleasePrimaryBufferInterface(a.l)
  ReleaseSecondaryBufferInterface(a.l)
  SetFocusWindow(a.l, b.l)
  GetFocusWindow(a.l, b.l)
EndInterface
