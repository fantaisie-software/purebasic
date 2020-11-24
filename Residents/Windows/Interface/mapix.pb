
; IMAPISession interface definition
;
Interface IMAPISession
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  GetMsgStoresTable(a.l, b.l)
  OpenMsgStore(a.l, b.l, c.l, d.l, e.l, f.l)
  OpenAddressBook(a.l, b.l, c.l, d.l)
  OpenProfileSection(a.l, b.l, c.l, d.l)
  GetStatusTable(a.l, b.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  CompareEntryIDs(a.l, b.l, c.l, d.l, e.l, f.l)
  Advise(a.l, b.l, c.l, d.l, e.l)
  Unadvise(a.l)
  MessageOptions(a.l, b.l, c.l, d.l)
  QueryDefaultMessageOpt(a.l, b.l, c.l, d.l)
  EnumAdrTypes(a.l, b.l, c.l)
  QueryIdentity(a.l, b.l)
  Logoff(a.l, b.l, c.l)
  SetDefaultStore(a.l, b.l, c.l)
  AdminServices(a.l, b.l)
  ShowForm(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l)
  PrepareForm(a.l, b.l, c.l)
EndInterface

; IAddrBook interface definition
;
Interface IAddrBook
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  SaveChanges(a.l)
  GetProps(a.l, b.l, c.l, d.l)
  GetPropList(a.l, b.l)
  OpenProperty(a.l, b.l, c.l, d.l, e.l)
  SetProps(a.l, b.l, c.l)
  DeleteProps(a.l, b.l)
  CopyTo(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  CopyProps(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetNamesFromIDs(a.l, b.l, c.l, d.l, e.l)
  GetIDsFromNames(a.l, b.l, c.l, d.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  CompareEntryIDs(a.l, b.l, c.l, d.l, e.l, f.l)
  Advise(a.l, b.l, c.l, d.l, e.l)
  Unadvise(a.l)
  CreateOneOff(a.l, b.l, c.l, d.l, e.l, f.l)
  NewEntry(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  ResolveName(a.l, b.l, c.l, d.l)
  Address(a.l, b.l, c.l)
  Details(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  RecipOptions(a.l, b.l, c.l)
  QueryDefaultRecipOpt(a.l, b.l, c.l, d.l)
  GetPAB(a.l, b.l)
  SetPAB(a.l, b.l)
  GetDefaultDi(a.l, b.l)
  SetDefaultDir(a.l, b.l)
  GetSearchPath(a.l, b.l)
  SetSearchPath(a.l, b.l)
  PrepareRecips(a.l, b.l, c.l)
EndInterface

; IProfAdmin interface definition
;
Interface IProfAdmin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  GetProfileTable(a.l, b.l)
  CreateProfile(a.l, b.l, c.l, d.l)
  DeleteProfile(a.l, b.l)
  ChangeProfilePassword(a.l, b.l, c.l, d.l)
  CopyProfile(a.l, b.l, c.l, d.l, e.l)
  RenameProfile(a.l, b.l, c.l, d.l, e.l)
  SetDefaultProfile(a.l, b.l)
  AdminServices(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IMsgServiceAdmin Interface definition
;
Interface IMsgServiceAdmin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  GetMsgServiceTable(a.l, b.l)
  CreateMsgService(a.l, b.l, c.l, d.l)
  DeleteMsgService(a.l)
  CopyMsgService(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  RenameMsgService(a.l, b.l, c.l)
  ConfigureMsgService(a.l, b.l, c.l, d.l, e.l)
  OpenProfileSection(a.l, b.l, c.l, d.l)
  MsgServiceTransportOrder(a.l, b.l, c.l)
  AdminProviders(a.l, b.l, c.l)
  SetPrimaryIdentity(a.l, b.l)
  GetProviderTable(a.l, b.l)
EndInterface
; ExecutableFormat=
; CursorPosition=99
; FirstLine=85
; EOF