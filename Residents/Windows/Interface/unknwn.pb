
; IUnknown interface definition
;
Interface IUnknown
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
EndInterface

; AsyncIUnknown interface definition
;
Interface AsyncIUnknown
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin_QueryInterface(a.l)
  Finish_QueryInterface(a.l)
  Begin_AddRef()
  Finish_AddRef()
  Begin_Release()
  Finish_Release()
EndInterface

; IClassFactory interface definition
;
Interface IClassFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateInstance(a.l, b.l, c.l)
  LockServer(a.l)
EndInterface
