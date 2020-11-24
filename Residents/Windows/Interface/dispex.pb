
; IDispatchEx interface definition
;
Interface IDispatchEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetDispID(a.p-bstr, b.l, c.l)
  InvokeEx(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  DeleteMemberByName(a.p-bstr, b.l)
  DeleteMemberByDispID(a.l)
  GetMemberProperties(a.l, b.l, c.l)
  GetMemberName(a.l, b.l)
  GetNextDispID(a.l, b.l, c.l)
  GetNameSpaceParent(a.l)
EndInterface

; IDispError interface definition
;
Interface IDispError
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryErrorInfo(a.l, b.l)
  GetNext(a.l)
  GetHresult(a.l)
  GetSource(a.l)
  GetHelpInfo(a.l, b.l)
  GetDescription(a.l)
EndInterface

; IVariantChangeType interface definition
;
Interface IVariantChangeType
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ChangeType(a.l, b.l, c.l, d.l)
EndInterface

; IObjectIdentity interface definition
;
Interface IObjectIdentity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsEqualObject(a.l)
EndInterface

; IProvideRuntimeContext interface definition
;
Interface IProvideRuntimeContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCurrentSourceContext(a.l, b.l)
EndInterface
