
; IWMIExtension interface definition
;
Interface IWMIExtension
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_WMIObjectPath(a.l)
  GetWMIObject(a.l)
  GetWMIServices(a.l)
EndInterface
