
; ISecurityInformation interface definition
;
Interface ISecurityInformation Extends IUnknown
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
Interface ISecurityInformation2 Extends IUnknown
  IsDaclCanonical(a.l)
  LookupSids(a.l, b.l, c.l)
EndInterface

; IEffectivePermission interface definition
;
Interface IEffectivePermission Extends IUnknown
  GetEffectivePermission(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; ISecurityObjectTypeInfo interface definition
;
Interface ISecurityObjectTypeInfo Extends IUnknown
  GetInheritSource(a.l, b.l)
EndInterface
