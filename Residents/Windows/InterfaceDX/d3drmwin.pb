
; IDirect3DRMWinDevice interface definition
;
Interface IDirect3DRMWinDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Clone(a.l, b.l, c.l)
  AddDestroyCallback(a.l, b.l)
  DeleteDestroyCallback(a.l, b.l)
  SetAppData(a.l)
  GetAppData()
  SetName(a.s)
  GetName(a.l, b.l)
  GetClassName(a.l, b.l)
  HandlePaint(a.l)
  HandleActivate(a.l)
EndInterface
