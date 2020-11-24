
; ICreateTypeInfo interface definition
;
Interface ICreateTypeInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetGuid(a.l)
  SetTypeFlags(a.l)
  SetDocString(a.p-unicode)
  SetHelpContext(a.l)
  SetVersion(a.l, b.l)
  AddRefTypeInfo(a.l, b.l)
  AddFuncDesc(a.l, b.l)
  AddImplType(a.l, b.l)
  SetImplTypeFlags(a.l, b.l)
  SetAlignment(a.l)
  SetSchema(a.p-unicode)
  AddVarDesc(a.l, b.l)
  SetFuncAndParamNames(a.l, b.l, c.l)
  SetVarName(a.l, b.p-unicode)
  SetTypeDescAlias(a.l)
  DefineFuncAsDllEntry(a.l, b.p-unicode, c.p-unicode)
  SetFuncDocString(a.l, b.p-unicode)
  SetVarDocString(a.l, b.p-unicode)
  SetFuncHelpContext(a.l, b.l)
  SetVarHelpContext(a.l, b.l)
  SetMops(a.l, b.p-bstr)
  SetTypeIdldesc(a.l)
  LayOut()
EndInterface

; ICreateTypeInfo2 interface definition
;
Interface ICreateTypeInfo2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetGuid(a.l)
  SetTypeFlags(a.l)
  SetDocString(a.p-unicode)
  SetHelpContext(a.l)
  SetVersion(a.l, b.l)
  AddRefTypeInfo(a.l, b.l)
  AddFuncDesc(a.l, b.l)
  AddImplType(a.l, b.l)
  SetImplTypeFlags(a.l, b.l)
  SetAlignment(a.l)
  SetSchema(a.p-unicode)
  AddVarDesc(a.l, b.l)
  SetFuncAndParamNames(a.l, b.l, c.l)
  SetVarName(a.l, b.p-unicode)
  SetTypeDescAlias(a.l)
  DefineFuncAsDllEntry(a.l, b.p-unicode, c.p-unicode)
  SetFuncDocString(a.l, b.p-unicode)
  SetVarDocString(a.l, b.p-unicode)
  SetFuncHelpContext(a.l, b.l)
  SetVarHelpContext(a.l, b.l)
  SetMops(a.l, b.p-bstr)
  SetTypeIdldesc(a.l)
  LayOut()
  DeleteFuncDesc(a.l)
  DeleteFuncDescByMemId(a.l, b.l)
  DeleteVarDesc(a.l)
  DeleteVarDescByMemId(a.l)
  DeleteImplType(a.l)
  SetCustData(a.l, b.l)
  SetFuncCustData(a.l, b.l, c.l)
  SetParamCustData(a.l, b.l, c.l, d.l)
  SetVarCustData(a.l, b.l, c.l)
  SetImplTypeCustData(a.l, b.l, c.l)
  SetHelpStringContext(a.l)
  SetFuncHelpStringContext(a.l, b.l)
  SetVarHelpStringContext(a.l, b.l)
  Invalidate()
  SetName(a.p-unicode)
EndInterface

; ICreateTypeLib interface definition
;
Interface ICreateTypeLib
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateTypeInfo(a.p-unicode, b.l, c.l)
  SetName(a.p-unicode)
  SetVersion(a.l, b.l)
  SetGuid(a.l)
  SetDocString(a.p-unicode)
  SetHelpFileName(a.p-unicode)
  SetHelpContext(a.l)
  SetLcid(a.l)
  SetLibFlags(a.l)
  SaveAllChanges()
EndInterface

; ICreateTypeLib2 interface definition
;
Interface ICreateTypeLib2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateTypeInfo(a.p-unicode, b.l, c.l)
  SetName(a.p-unicode)
  SetVersion(a.l, b.l)
  SetGuid(a.l)
  SetDocString(a.p-unicode)
  SetHelpFileName(a.p-unicode)
  SetHelpContext(a.l)
  SetLcid(a.l)
  SetLibFlags(a.l)
  SaveAllChanges()
  DeleteTypeInfo(a.p-unicode)
  SetCustData(a.l, b.l)
  SetHelpStringContext(a.l)
  SetHelpStringDll(a.p-unicode)
EndInterface

; IDispatch interface definition
;
Interface IDispatch
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; IEnumVARIANT interface definition
;
Interface IEnumVARIANT
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; ITypeComp interface definition
;
Interface ITypeComp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Bind(a.p-unicode, b.l, c.l, d.l, e.l, f.l)
  BindType(a.p-unicode, b.l, c.l, d.l)
EndInterface

; ITypeInfo interface definition
;
Interface ITypeInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeAttr(a.l)
  GetTypeComp(a.l)
  GetFuncDesc(a.l, b.l)
  GetVarDesc(a.l, b.l)
  GetNames(a.l, b.l, c.l, d.l)
  GetRefTypeOfImplType(a.l, b.l)
  GetImplTypeFlags(a.l, b.l)
  GetIDsOfNames(a.l, b.l, c.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetDocumentation(a.l, b.l, c.l, d.l, e.l)
  GetDllEntry(a.l, b.l, c.l, d.l, e.l)
  GetRefTypeInfo(a.l, b.l)
  AddressOfMember(a.l, b.l, c.l)
  CreateInstance(a.l, b.l, c.l)
  GetMops(a.l, b.l)
  GetContainingTypeLib(a.l, b.l)
  ReleaseTypeAttr(a.l)
  ReleaseFuncDesc(a.l)
  ReleaseVarDesc(a.l)
EndInterface

; ITypeInfo2 interface definition
;
Interface ITypeInfo2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeAttr(a.l)
  GetTypeComp(a.l)
  GetFuncDesc(a.l, b.l)
  GetVarDesc(a.l, b.l)
  GetNames(a.l, b.l, c.l, d.l)
  GetRefTypeOfImplType(a.l, b.l)
  GetImplTypeFlags(a.l, b.l)
  GetIDsOfNames(a.l, b.l, c.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetDocumentation(a.l, b.l, c.l, d.l, e.l)
  GetDllEntry(a.l, b.l, c.l, d.l, e.l)
  GetRefTypeInfo(a.l, b.l)
  AddressOfMember(a.l, b.l, c.l)
  CreateInstance(a.l, b.l, c.l)
  GetMops(a.l, b.l)
  GetContainingTypeLib(a.l, b.l)
  ReleaseTypeAttr(a.l)
  ReleaseFuncDesc(a.l)
  ReleaseVarDesc(a.l)
  GetTypeKind(a.l)
  GetTypeFlags(a.l)
  GetFuncIndexOfMemId(a.l, b.l, c.l)
  GetVarIndexOfMemId(a.l, b.l)
  GetCustData(a.l, b.l)
  GetFuncCustData(a.l, b.l, c.l)
  GetParamCustData(a.l, b.l, c.l, d.l)
  GetVarCustData(a.l, b.l, c.l)
  GetImplTypeCustData(a.l, b.l, c.l)
  GetDocumentation2(a.l, b.l, c.l, d.l, e.l)
  GetAllCustData(a.l)
  GetAllFuncCustData(a.l, b.l)
  GetAllParamCustData(a.l, b.l, c.l)
  GetAllVarCustData(a.l, b.l)
  GetAllImplTypeCustData(a.l, b.l)
EndInterface

; ITypeLib interface definition
;
Interface ITypeLib
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount()
  GetTypeInfo(a.l, b.l)
  GetTypeInfoType(a.l, b.l)
  GetTypeInfoOfGuid(a.l, b.l)
  GetLibAttr(a.l)
  GetTypeComp(a.l)
  GetDocumentation(a.l, b.l, c.l, d.l, e.l)
  IsName(a.p-unicode, b.l, c.l)
  FindName(a.p-unicode, b.l, c.l, d.l, e.l)
  ReleaseTLibAttr(a.l)
EndInterface

; ITypeLib2 interface definition
;
Interface ITypeLib2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount()
  GetTypeInfo(a.l, b.l)
  GetTypeInfoType(a.l, b.l)
  GetTypeInfoOfGuid(a.l, b.l)
  GetLibAttr(a.l)
  GetTypeComp(a.l)
  GetDocumentation(a.l, b.l, c.l, d.l, e.l)
  IsName(a.p-unicode, b.l, c.l)
  FindName(a.p-unicode, b.l, c.l, d.l, e.l)
  ReleaseTLibAttr(a.l)
  GetCustData(a.l, b.l)
  GetLibStatistics(a.l, b.l)
  GetDocumentation2(a.l, b.l, c.l, d.l, e.l)
  GetAllCustData(a.l)
EndInterface

; ITypeChangeEvents interface definition
;
Interface ITypeChangeEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RequestTypeChange(a.l, b.l, c.p-unicode, d.l)
  AfterTypeChange(a.l, b.l, c.p-unicode)
EndInterface

; IErrorInfo interface definition
;
Interface IErrorInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetGUID(a.l)
  GetSource(a.l)
  GetDescription(a.l)
  GetHelpFile(a.l)
  GetHelpContext(a.l)
EndInterface

; ICreateErrorInfo interface definition
;
Interface ICreateErrorInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetGUID(a.l)
  SetSource(a.p-unicode)
  SetDescription(a.p-unicode)
  SetHelpFile(a.p-unicode)
  SetHelpContext(a.l)
EndInterface

; ISupportErrorInfo interface definition
;
Interface ISupportErrorInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InterfaceSupportsErrorInfo(a.l)
EndInterface

; ITypeFactory interface definition
;
Interface ITypeFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateFromTypeInfo(a.l, b.l, c.l)
EndInterface

; ITypeMarshal interface definition
;
Interface ITypeMarshal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Size(a.l, b.l, c.l, d.l)
  Marshal(a.l, b.l, c.l, d.l, e.l, f.l)
  Unmarshal(a.l, b.l, c.l, d.l, e.l)
  Free(a.l)
EndInterface

; IRecordInfo interface definition
;
Interface IRecordInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RecordInit(a.l)
  RecordClear(a.l)
  RecordCopy(a.l, b.l)
  GetGuid(a.l)
  GetName(a.l)
  GetSize(a.l)
  GetTypeInfo(a.l)
  GetField(a.l, b.l, c.l)
  GetFieldNoCopy(a.l, b.l, c.l, d.l)
  PutField(a.l, b.l, c.l, d.l)
  PutFieldNoCopy(a.l, b.l, c.l, d.l)
  GetFieldNames(a.l, b.l)
  IsMatchingType(a.l)
  RecordCreate()
  RecordCreateCopy(a.l, b.l)
  RecordDestroy(a.l)
EndInterface

; IErrorLog interface definition
;
Interface IErrorLog
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddError(a.l, b.l)
EndInterface

; IPropertyBag interface definition
;
Interface IPropertyBag
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Read(a.l, b.l, c.l)
  Write(a.l, b.l)
EndInterface
