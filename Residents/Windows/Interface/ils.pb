
; IIlsServer interface definition
;
Interface IIlsServer Extends IUnknown
  SetAuthenticationMethod(a.l)
  SetLogonName(a.l)
  SetLogonPassword(a.l)
  SetDomain(a.l)
  SetCredential(a.l)
  SetTimeout(a.l)
  SetBaseDN(a.l)
EndInterface

; IIlsMain interface definition
;
Interface IIlsMain Extends IUnknown
  Initialize()
  CreateServer(a.l, b.l)
  CreateUser(a.l, b.l, c.l)
  GetUser(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  EnumUserNames(a.l, b.l, c.l, d.l)
  EnumUsers(a.l, b.l, c.l, d.l, e.l)
  Abort(a.l)
  CreateAttributes(a.l, b.l)
  CreateFilter(a.l, b.l, c.l)
  StringToFilter(a.l, b.l)
  Uninitialize()
EndInterface

; IIlsNotify interface definition
;
Interface IIlsNotify Extends IUnknown
  GetUserResult(a.l, b.l, c.l)
  EnumUserNamesResult(a.l, b.l, c.l)
  EnumUsersResult(a.l, b.l, c.l)
EndInterface

; IIlsUser interface definition
;
Interface IIlsUser Extends IUnknown
  GetState(a.l)
  GetStandardAttribute(a.l, b.l)
  SetStandardAttribute(a.l, b.l)
  GetExtendedAttribute(a.l, b.l)
  SetExtendedAttribute(a.l, b.l)
  RemoveExtendedAttribute(a.l)
  GetAllExtendedAttributes(a.l)
  IsWritable(a.l)
  Register(a.l, b.l)
  Unregister(a.l)
  Update(a.l)
  GetVisible(a.l)
  SetVisible(a.l)
  GetGuid(a.l)
  SetGuid(a.l)
  CreateProtocol(a.l, b.l, c.l, d.l)
  AddProtocol(a.l, b.l)
  RemoveProtocol(a.l, b.l)
  GetProtocol(a.l, b.l, c.l, d.l)
  EnumProtocols(a.l, b.l, c.l, d.l)
  Clone(a.l)
EndInterface

; IIlsProtocol interface definition
;
Interface IIlsProtocol Extends IUnknown
  IsWritable(a.l)
  GetPortNumber(a.l)
  GetStandardAttribute(a.l, b.l)
  SetStandardAttribute(a.l, b.l)
  GetExtendedAttribute(a.l, b.l)
  SetExtendedAttribute(a.l, b.l)
  RemoveExtendedAttribute(a.l)
  GetAllExtendedAttributes(a.l)
  Update(a.l)
EndInterface

; IIlsProtocolNotify interface definition
;
Interface IIlsProtocolNotify Extends IUnknown
  UpdateResult(a.l, b.l)
EndInterface

; IIlsUserNotify interface definition
;
Interface IIlsUserNotify Extends IUnknown
  RegisterResult(a.l, b.l)
  UpdateResult(a.l, b.l)
  ProtocolChangeResult(a.l, b.l)
  GetProtocolResult(a.l, b.l, c.l)
  EnumProtocolsResult(a.l, b.l, c.l)
  StateChanged(a.l, b.l)
EndInterface

; IIlsAttributes interface definition
;
Interface IIlsAttributes Extends IUnknown
  SetAttribute(a.l, b.l)
  GetAttribute(a.l, b.l)
  EnumAttributes(a.l)
  SetAttributeName(a.l)
EndInterface

; IIlsFilter interface definition
;
Interface IIlsFilter Extends IUnknown
  AddSubFilter(a.l)
  RemoveSubFilter(a.l)
  GetCount(a.l)
  SetStandardAttributeName(a.l)
  SetExtendedAttributeName(a.l)
  SetAttributeValue(a.l)
EndInterface

; IEnumIlsProtocols interface definition
;
Interface IEnumIlsProtocols Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumIlsUsers interface definition
;
Interface IEnumIlsUsers Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumIlsNames interface definition
;
Interface IEnumIlsNames Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface
