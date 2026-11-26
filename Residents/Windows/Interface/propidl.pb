
; IPropertyStorage interface definition
;
Interface IPropertyStorage Extends IUnknown
  ReadMultiple(a.l, b.l, c.l)
  WriteMultiple(a.l, b.l, c.l, d.l)
  DeleteMultiple(a.l, b.l)
  ReadPropertyNames(a.l, b.l, c.p-unicode)
  WritePropertyNames(a.l, b.l, c.l)
  DeletePropertyNames(a.l, b.l)
  Commit(a.l)
  Revert()
  Enum(a.l)
  SetTimes(a.l, b.l, c.l)
  SetClass(a.l)
  Stat(a.l)
EndInterface

; IPropertySetStorage interface definition
;
Interface IPropertySetStorage Extends IUnknown
  Create(a.l, b.l, c.l, d.l, e.l)
  Open(a.l, b.l, c.l)
  Delete(a.l)
  Enum(a.l)
EndInterface

; IEnumSTATPROPSTG interface definition
;
Interface IEnumSTATPROPSTG Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumSTATPROPSETSTG interface definition
;
Interface IEnumSTATPROPSETSTG Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface
