
; ISecurityInformation interface definition
;
Interface ISecurityInformation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetObjectInformation(a.l)
  GetSecurity(a.l, b.l, c.l)
  SetSecurity(a.l, b.l)
  GetAccessRights(a.l, b.l, c.l, d.l, e.l)
  MapGeneric(a.l, b.s, c.l)
  GetInheritTypes(a.l, b.l)
  PropertySheetPageCallback(a.l, b.l, c.l)
EndInterface

; ISecurityInformation2 interface definition
;
Interface ISecurityInformation2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsDaclCanonical(a.l)
  LookupSids(a.l, b.l, c.l)
EndInterface

; IEffectivePermission interface definition
;
Interface IEffectivePermission
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetEffectivePermission(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; ISecurityObjectTypeInfo interface definition
;
Interface ISecurityObjectTypeInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetInheritSource(a.l, b.l)
EndInterface
