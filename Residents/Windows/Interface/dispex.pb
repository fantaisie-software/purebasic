
; IDispatchEx interface definition
;
Interface IDispatchEx Extends IDispatch
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
Interface IDispError Extends IUnknown
  QueryErrorInfo(a.l, b.l)
  GetNext(a.l)
  GetHresult(a.l)
  GetSource(a.l)
  GetHelpInfo(a.l, b.l)
  GetDescription(a.l)
EndInterface

; IVariantChangeType interface definition
;
Interface IVariantChangeType Extends IUnknown
  ChangeType(a.l, b.l, c.l, d.l)
EndInterface

; IObjectIdentity interface definition
;
Interface IObjectIdentity Extends IUnknown
  IsEqualObject(a.l)
EndInterface

; IProvideRuntimeContext interface definition
;
Interface IProvideRuntimeContext Extends IUnknown
  GetCurrentSourceContext(a.l, b.l)
EndInterface
