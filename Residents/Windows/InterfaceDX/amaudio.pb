
; IAMDirectSound interface definition
;
Interface IAMDirectSound
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDirectSoundInterface(a.l)
  GetPrimaryBufferInterface(a.l)
  GetSecondaryBufferInterface(a.l)
  ReleaseDirectSoundInterface(a.l)
  ReleasePrimaryBufferInterface(a.l)
  ReleaseSecondaryBufferInterface(a.l)
  SetFocusWindow(a.l, b.l)
  GetFocusWindow(a.l, b.l)
EndInterface
