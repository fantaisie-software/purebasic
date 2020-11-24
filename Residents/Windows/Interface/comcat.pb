
; IEnumGUID interface definition
;
Interface IEnumGUID
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumCATEGORYINFO interface definition
;
Interface IEnumCATEGORYINFO
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; ICatRegister interface definition
;
Interface ICatRegister
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RegisterCategories(a.l, b.l)
  UnRegisterCategories(a.l, b.l)
  RegisterClassImplCategories(a.l, b.l, c.l)
  UnRegisterClassImplCategories(a.l, b.l, c.l)
  RegisterClassReqCategories(a.l, b.l, c.l)
  UnRegisterClassReqCategories(a.l, b.l, c.l)
EndInterface

; ICatInformation interface definition
;
Interface ICatInformation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumCategories(a.l, b.l)
  GetCategoryDesc(a.l, b.l, c.l)
  EnumClassesOfCategories(a.l, b.l, c.l, d.l, e.l)
  IsClassOfCategories(a.l, b.l, c.l, d.l, e.l)
  EnumImplCategoriesOfClass(a.l, b.l)
  EnumReqCategoriesOfClass(a.l, b.l)
EndInterface
