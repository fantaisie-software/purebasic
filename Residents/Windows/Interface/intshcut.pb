
; IUniformResourceLocatorA interface definition
;
Interface IUniformResourceLocatorA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetURL(a.s, b.l)
  GetURL(a.l)
  InvokeCommand(a.l)
EndInterface

; IUniformResourceLocatorW interface definition
;
Interface IUniformResourceLocatorW
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetURL(a.l, b.l)
  GetURL(a.l)
  InvokeCommand(a.l)
EndInterface
