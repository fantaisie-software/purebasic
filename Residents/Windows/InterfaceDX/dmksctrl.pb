
; IKsControl interface definition
;
Interface IKsControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsProperty(a.l, b.l, c.l, d.l, e.l)
  KsMethod(a.l, b.l, c.l, d.l, e.l)
  KsEvent(a.l, b.l, c.l, d.l, e.l)
EndInterface
