
; IAccessible interface definition
;
Interface IAccessible
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_accParent(a.l)
  get_accChildCount(a.l)
  get_accChild(a.p-variant, b.l)
  get_accName(a.p-variant, b.l)
  get_accValue(a.p-variant, b.l)
  get_accDescription(a.p-variant, b.l)
  get_accRole(a.p-variant, b.l)
  get_accState(a.p-variant, b.l)
  get_accHelp(a.p-variant, b.l)
  get_accHelpTopic(a.l, b.p-variant, c.l)
  get_accKeyboardShortcut(a.p-variant, b.l)
  get_accFocus(a.l)
  get_accSelection(a.l)
  get_accDefaultAction(a.p-variant, b.l)
  accSelect(a.l, b.p-variant)
  accLocation(a.l, b.l, c.l, d.l, e.p-variant)
  accNavigate(a.l, b.p-variant, c.l)
  accHitTest(a.l, b.l, c.l)
  accDoDefaultAction(a.p-variant)
  put_accName(a.p-variant, b.p-bstr)
  put_accValue(a.p-variant, b.p-bstr)
EndInterface

; IAccessibleHandler interface definition
;
Interface IAccessibleHandler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AccessibleObjectFromID(a.l, b.l, c.l)
EndInterface

; IAccIdentity interface definition
;
Interface IAccIdentity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetIdentityString(a.l, b.l, c.l)
EndInterface

; IAccPropServer interface definition
;
Interface IAccPropServer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPropValue(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IAccPropServices interface definition
;
Interface IAccPropServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetPropValue(a.l, b.l, c.l, d.p-variant)
  SetPropServer(a.l, b.l, c.l, d.l, e.l, f.l)
  ClearProps(a.l, b.l, c.l, d.l)
  SetHwndProp(a.l, b.l, c.l, d.l, e.p-variant)
  SetHwndPropStr(a.l, b.l, c.l, d.l, e.l)
  SetHwndPropServer(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  ClearHwndProps(a.l, b.l, c.l, d.l, e.l)
  ComposeHwndIdentityString(a.l, b.l, c.l, d.l, e.l)
  DecomposeHwndIdentityString(a.l, b.l, c.l, d.l, e.l)
  SetHmenuProp(a.l, b.l, c.l, d.p-variant)
  SetHmenuPropStr(a.l, b.l, c.l, d.l)
  SetHmenuPropServer(a.l, b.l, c.l, d.l, e.l, f.l)
  ClearHmenuProps(a.l, b.l, c.l, d.l)
  ComposeHmenuIdentityString(a.l, b.l, c.l, d.l)
  DecomposeHmenuIdentityString(a.l, b.l, c.l, d.l)
EndInterface
