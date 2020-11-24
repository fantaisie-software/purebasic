
; IMAPIAdviseSink interface definition
;
Interface IMAPIAdviseSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnNotify(a.l, b.l)
EndInterface

; IMAPIProgress interface definition
;
Interface IMAPIProgress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Progress(a.l, b.l)
  GetFlags(a.l)
  GetMax(a.l)
  GetMin(a.l)
  SetLimits(a.l, b.l, c.l)
EndInterface

; IMAPIProp interface definition
;
Interface IMAPIProp
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
EndInterface

; IMAPITable interface definition
;
Interface IMAPITable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  Advise(a.l, b.l, c.l)
  Unadvise(a.l)
  GetStatus(a.l, b.l)
  SetColumns(a.l, b.l)
  QueryColumns(a.l, b.l)
  GetRowCount(a.l, b.l)
  SeekRow(a.l, b.l, b.l)
  SeekRowApprox(a.l, b.l)
  QueryPosition(a.l, b.l, c.l)
  FindRow(a.l, b.l, c.l)
  Restrict(a.l, b.l)
  CreateBookmark(a.l)
  FreeBookmark(a.l)
  SortTable(a.l, b.l)
  QuerySortOrder(a.l)
  QueryRows(a.l, b.l, c.l)
  Abort()
  ExpandRow(a.l, b.l, c.l, d.l, e.l, f.l)
  CollapseRow(a.l, b.l, c.l, d.l)
  WaitForCompletion(a.l, b.l, c.l)
  GetCollapseState(a.l, b.l, c.l, d.l, e.l)
  SetCollapseState(a.l, b.l, c.l, d.l)
EndInterface

; IProfSect interface definition
;
Interface IProfSect
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
EndInterface

; IMAPIStatus interface definition
;
Interface IMAPIStatus
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
  ValidateState(a.l, b.l)
  SettingsDialog(a.l, b.l)
  ChangePassword(a.l, b.l, c.l)
  FlushQueues(a.l, b.l, c.l, d.l)
EndInterface

; IMAPIContainer interface definition
;
Interface IMAPIContainer
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
  GetContentsTable(a.l, b.l)
  GetHierarchyTable(a.l, b.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  SetSearchCriteria(a.l, b.l, c.l)
  GetSearchCriteria(a.l, b.l, c.l, d.l)
EndInterface

;  interface definition
;
Interface IABContainer
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
  GetContentsTable(a.l, b.l)
  GetHierarchyTable(a.l, b.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  SetSearchCriteria(a.l, b.l, c.l)
  GetSearchCriteria(a.l, b.l, c.l, d.l)
  CreateEntry(a.l, b.l, c.l, d.l)
  CopyEntries(a.l, b.l, c.l, d.l)
  DeleteEntries(a.l, b.l)
  ResolveNames(a.l, b.l, c.l, d.l)
EndInterface

; IMailUser interface definition
;
Interface IMailUser
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
EndInterface

; IDistList interface definition
;
Interface IDistList
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
  GetContentsTable(a.l, b.l)
  GetHierarchyTable(a.l, b.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  SetSearchCriteria(a.l, b.l, c.l)
  GetSearchCriteria(a.l, b.l, c.l, d.l)
  CreateEntry(a.l, b.l, c.l, d.l)
  CopyEntries(a.l, b.l, c.l, d.l)
  DeleteEntries(a.l, b.l)
  ResolveNames(a.l, b.l, c.l, d.l)
EndInterface

; IMAPIFolder interface definition
;
Interface IMAPIFolder
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
  GetContentsTable(a.l, b.l)
  GetHierarchyTable(a.l, b.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  SetSearchCriteria(a.l, b.l, c.l)
  GetSearchCriteria(a.l, b.l, c.l, d.l)
  CreateMessage(a.l, b.l, c.l)
  CopyMessages(a.l, b.l, c.l, d.l, e.l, f.l)
  DeleteMessages(a.l, b.l, c.l, d.l)
  CreateFolder(a.l, b.l, c.l, d.l, e.l, f.l)
  CopyFolder(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  DeleteFolder(a.l, b.l, c.l, d.l, f.l)
  SetReadFlags(a.l, b.l, c.l, d.l)
  GetMessageStatus(a.l, b.l, c.l, d.l)
  SetMessageStatus(a.l, b.l, c.l, d.l, e.l)
  SaveContentsSort(a.l, b.l)
  EmptyFolder(a.l, b.l, c.l)
EndInterface

;  IMsgStore interface definition
;
Interface IMsgStore
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
  Advise(a.l, b.l, c.l, d.l, e.l)
  Unadvise(a.l)
  CompareEntryIDs(a.l, b.l, c.l, d.l, e.l, f.l)
  OpenEntry(a.l, b.l, c.l, d.l, e.l, f.l)
  SetReceiveFolder(a.l, b.l, c.l, d.l)
  GetReceiveFolder(a.l, b.l, c.l, d.l, e.l)
  GetReceiveFolderTable(a.l, b.l)
  StoreLogoff(a.l)
  AbortSubmit(a.l, b.l, c.l)
  GetOutgoingQueue(a.l, b.l)
  SetLockState(a.l, b.l)
  FinishedMsg(a.l, b.l, c.l)
  NotifyNewMail(a.l)
EndInterface

; IMessage interface definition
;
Interface IMessage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_BCC(a.l)
  put_BCC(a.p-bstr)
  get_CC(a.l)
  put_CC(a.p-bstr)
  get_FollowUpTo(a.l)
  put_FollowUpTo(a.p-bstr)
  get_From(a.l)
  put_From(a.p-bstr)
  get_Keywords(a.l)
  put_Keywords(a.p-bstr)
  get_MimeFormatted(a.l)
  put_MimeFormatted(a.l)
  get_Newsgroups(a.l)
  put_Newsgroups(a.p-bstr)
  get_Organization(a.l)
  put_Organization(a.p-bstr)
  get_ReceivedTime(a.l)
  get_ReplyTo(a.l)
  put_ReplyTo(a.p-bstr)
  get_DSNOptions(a.l)
  put_DSNOptions(a.l)
  get_SentOn(a.l)
  get_Subject(a.l)
  put_Subject(a.p-bstr)
  get_To(a.l)
  put_To(a.p-bstr)
  get_TextBody(a.l)
  put_TextBody(a.p-bstr)
  get_HTMLBody(a.l)
  put_HTMLBody(a.p-bstr)
  get_Attachments(a.l)
  get_Sender(a.l)
  put_Sender(a.p-bstr)
  get_Configuration(a.l)
  put_Configuration(a.l)
  putref_Configuration(a.l)
  get_AutoGenerateTextBody(a.l)
  put_AutoGenerateTextBody(a.l)
  get_EnvelopeFields(a.l)
  get_TextBodyPart(a.l)
  get_HTMLBodyPart(a.l)
  get_BodyPart(a.l)
  get_DataSource(a.l)
  get_Fields(a.l)
  get_MDNRequested(a.l)
  put_MDNRequested(a.l)
  AddRelatedBodyPart(a.p-bstr, b.p-bstr, c.l, d.p-bstr, e.p-bstr, f.l)
  AddAttachment(a.p-bstr, b.p-bstr, c.p-bstr, d.l)
  CreateMHTMLBody(a.p-bstr, b.l, c.p-bstr, d.p-bstr)
  Forward(a.l)
  Post()
  PostReply(a.l)
  Reply(a.l)
  ReplyAll(a.l)
  Send()
  GetStream(a.l)
  GetInterface(a.p-bstr, b.l)
EndInterface

; IAttach interface definition
;
Interface IAttach
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
EndInterface

; IMAPIControl interface definition
;
Interface IMAPIControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  Activate(a.l, b.l)
  GetState(a.l, b.l)
EndInterface

; IProviderAdmin interface definition
;
Interface IProviderAdmin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  GetProviderTable(a.l, b.l)
  CreateProvider(a.l, b.l, c.l, d.l, e.l, f.l)
  DeleteProvider(a.l)
  OpenProfileSection(a.l, b.l, c.l, d.l)
EndInterface
; ExecutableFormat=
; CursorPosition=343
; FirstLine=331
; EOF
