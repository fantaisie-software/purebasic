
; IKsControl interface definition - Already defined in dmksctrl.pb
;

; IKsReferenceClock interface definition
;
Interface IKsReferenceClock
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTime()
  GetPhysicalTime()
  GetCorrelatedTime(a.l)
  GetCorrelatedPhysicalTime(a.l)
  GetResolution(a.l)
  GetState(a.l)
EndInterface
