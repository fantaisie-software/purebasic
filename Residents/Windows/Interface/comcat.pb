
; IEnumGUID interface definition
;
Interface IEnumGUID Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumCATEGORYINFO interface definition
;
Interface IEnumCATEGORYINFO Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; ICatRegister interface definition
;
Interface ICatRegister Extends IUnknown
  RegisterCategories(a.l, b.l)
  UnRegisterCategories(a.l, b.l)
  RegisterClassImplCategories(a.l, b.l, c.l)
  UnRegisterClassImplCategories(a.l, b.l, c.l)
  RegisterClassReqCategories(a.l, b.l, c.l)
  UnRegisterClassReqCategories(a.l, b.l, c.l)
EndInterface

; ICatInformation interface definition
;
Interface ICatInformation Extends IUnknown
  EnumCategories(a.l, b.l)
  GetCategoryDesc(a.l, b.l, c.l)
  EnumClassesOfCategories(a.l, b.l, c.l, d.l, e.l)
  IsClassOfCategories(a.l, b.l, c.l, d.l, e.l)
  EnumImplCategoriesOfClass(a.l, b.l)
  EnumReqCategoriesOfClass(a.l, b.l)
EndInterface
