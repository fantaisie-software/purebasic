
; IPersistMessage interface definition
;
Interface IPersistMessage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  GetClassID(a.l)
  IsDirty()
  InitNew(a.l, b.l)
  Load(a.l, b.l, c.l, d.l)
  Save(a.l)
EndInterface

; IMAPIMessageSite interface definition
;
Interface IMAPIMessageSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  GetSession(a.l)
  GetStore(a.l)
  GetFolder(a.l)
  GetMessage(a.l)
  GetFormManager(a.l)
  NewMessage(a.l, b.l, c.l, d.l, e.l, f.l)
  CopyMessage(a.l)
  MoveMessage(a.l, b.l, c.l)
  DeleteMessage(a.l, b.l)
  SaveMessage()
  SubmitMessage(a.l)
  GetSiteStatus(a.l)
EndInterface

; IMAPIForm interface definition
;
Interface IMAPIForm
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  SetViewContext(a.l)
  GetViewContext(a.l)
  ShutdownForm(a.l)
  DoVerb(a.l, b.l, c.l)
  Advise(a.l, b.l)
  Unadvise(a.l)
EndInterface

; IMAPIViewContext interface definition
;
Interface IMAPIViewContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  SetAdviseSink(a.l)
  ActivateNext(a.l, b.l)
  GetPrintSetup(a.l, b.l)
  GetSaveStream(a.l, b.l, c.l)
  GetViewStatus(a.l)
EndInterface

; IMAPIFormAdviseSink interface definition
;
Interface IMAPIFormAdviseSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnChange(a.l)
  OnActivateNext(a.l, b.l, c.l, d.l)
EndInterface

; IMAPIViewAdviseSink interface definition
;
Interface IMAPIViewAdviseSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnShutdown()
  OnNewMessage()
  OnPrint(a.l, b.l)
  OnSubmitted()
  OnSaved()
EndInterface

; IMAPIFormInfo interface definition
;
Interface IMAPIFormInfo
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
  CalcFormPropSet(a.l, b.l)
  CalcVerbSet(a.l, b.l)
  MakeIconFromBinary(a.l, b.l)
  SaveForm(a.l)
  OpenFormContainer(a.l)
EndInterface

; IMAPIFormMgr interface definition
;
Interface IMAPIFormMgr
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  LoadForm(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l)
  ResolveMessageClass(a.l, b.l, c.l)
  ResolveMultipleMessageClasses(a.l, b.l, c.l)
  CalcFormPropSet(a.l, b.l, c.l)
  CreateForm(a.l, b.l, c.l, d.l, e.l)
  SelectForm(a.l, b.l, c.l, d.l, e.l)
  SelectMultipleForms(a.l, b.l, c.l, d.l, e.l, f.l)
  SelectFormContainer(a.l, b.l, c.l)
  OpenFormContainer(a.l, b.l, c.l)
  PrepareForm(a.l, b.l, c.l)
  IsInConflict(a.l, b.l, c.l, d.l)
EndInterface

; IMAPIFormContainer interface definition
;
Interface IMAPIFormContainer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  InstallForm(a.l, b.l, c.l)
  RemoveForm(a.l)
  ResolveMessageClass(a.l, b.l, c.l)
  ResolveMultipleMessageClasses(a.l, b.l, c.l)
  CalcFormPropSet(a.l, b.l)
  GetDisplay(a.l, b.l)
EndInterface

; IMAPIFormFactory interface definition
;
Interface IMAPIFormFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLastError(a.l, b.l, c.l)
  CreateClassFactory(a.l, b.l, c.l)
  LockServer(a.l, b.l)
EndInterface
; ExecutableFormat=
; CursorPosition=155
; FirstLine=123
; EOF