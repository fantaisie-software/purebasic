
; IUniformResourceLocatorA interface definition
;
Interface IUniformResourceLocatorA Extends IUnknown
  SetURL(a.s, b.l)
  GetURL(a.l)
  InvokeCommand(a.l)
EndInterface

; IUniformResourceLocatorW interface definition
;
Interface IUniformResourceLocatorW Extends IUnknown
  SetURL(a.l, b.l)
  GetURL(a.l)
  InvokeCommand(a.l)
EndInterface
