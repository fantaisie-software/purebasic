
; IDxDiagProvider interface definition
;
Interface IDxDiagProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  GetRootContainer(a.l)
EndInterface

; IDxDiagContainer interface definition
;
Interface IDxDiagContainer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNumberOfChildContainers(a.l)
  EnumChildContainerNames(a.l, b.l, c.l)
  GetChildContainer(a.l, b.l)
  GetNumberOfProps(a.l)
  EnumPropNames(a.l, b.l, c.l)
  GetProp(a.l, b.l)
EndInterface
