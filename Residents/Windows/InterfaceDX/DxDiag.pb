
; IDxDiagProvider interface definition
;
Interface IDxDiagProvider Extends IUnknown
  Initialize(a.l)
  GetRootContainer(a.l)
EndInterface

; IDxDiagContainer interface definition
;
Interface IDxDiagContainer Extends IUnknown
  GetNumberOfChildContainers(a.l)
  EnumChildContainerNames(a.l, b.l, c.l)
  GetChildContainer(a.l, b.l)
  GetNumberOfProps(a.l)
  EnumPropNames(a.l, b.l, c.l)
  GetProp(a.l, b.l)
EndInterface
