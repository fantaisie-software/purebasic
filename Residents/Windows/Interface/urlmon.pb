
; IPersistMoniker interface definition
;
Interface IPersistMoniker
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  IsDirty()
  Load(a.l, b.l, c.l, d.l)
  Save(a.l, b.l, c.l)
  SaveCompleted(a.l, b.l)
  GetCurMoniker(a.l)
EndInterface

; IMonikerProp interface definition
;
Interface IMonikerProp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  PutProperty(a.l, b.l)
EndInterface

; IBindProtocol interface definition
;
Interface IBindProtocol
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateBinding(a.l, b.l, c.l)
EndInterface

; IBinding interface definition
;
Interface IBinding
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Abort()
  Suspend()
  Resume()
  SetPriority(a.l)
  GetPriority(a.l)
  GetBindResult(a.l, b.l, c.l, d.l)
EndInterface

; IBindStatusCallback interface definition
;
Interface IBindStatusCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnStartBinding(a.l, b.l)
  GetPriority(a.l)
  OnLowResource(a.l)
  OnProgress(a.l, b.l, c.l, d.l)
  OnStopBinding(a.l, b.l)
  GetBindInfo(a.l, b.l)
  OnDataAvailable(a.l, b.l, c.l, d.l)
  OnObjectAvailable(a.l, b.l)
EndInterface

; IAuthenticate interface definition
;
Interface IAuthenticate
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Authenticate(a.l, b.l, c.l)
EndInterface

; IHttpNegotiate interface definition
;
Interface IHttpNegotiate
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  BeginningTransaction(a.l, b.l, c.l, d.l)
  OnResponse(a.l, b.l, c.l, d.l)
EndInterface

; IHttpNegotiate2 interface definition
;
Interface IHttpNegotiate2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  BeginningTransaction(a.l, b.l, c.l, d.l)
  OnResponse(a.l, b.l, c.l, d.l)
  GetRootSecurityId(a.l, b.l, c.l)
EndInterface

; IWinInetFileStream interface definition
;
Interface IWinInetFileStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetHandleForUnlock(a.l, b.l)
  SetDeleteFile(a.l)
EndInterface

; IWindowForBindingUI interface definition
;
Interface IWindowForBindingUI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l, b.l)
EndInterface

; ICodeInstall interface definition
;
Interface ICodeInstall
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l, b.l)
  OnCodeInstallProblem(a.l, b.l, c.l, d.l)
EndInterface

; IWinInetInfo interface definition
;
Interface IWinInetInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryOption(a.l, b.l, c.l)
EndInterface

; IHttpSecurity interface definition
;
Interface IHttpSecurity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l, b.l)
  OnSecurityProblem(a.l)
EndInterface

; IWinInetHttpInfo interface definition
;
Interface IWinInetHttpInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryOption(a.l, b.l, c.l)
  QueryInfo(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IWinInetCacheHints interface definition
;
Interface IWinInetCacheHints
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetCacheExtension(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IBindHost interface definition
;
Interface IBindHost
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateMoniker(a.p-unicode, b.l, c.l, d.l)
  MonikerBindToStorage(a.l, b.l, c.l, d.l, e.l)
  MonikerBindToObject(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IInternet interface definition
;
Interface IInternet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
EndInterface

; IInternetBindInfo interface definition
;
Interface IInternetBindInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBindInfo(a.l, b.l)
  GetBindString(a.l, b.l, c.l, d.l)
EndInterface

; IInternetProtocolRoot interface definition
;
Interface IInternetProtocolRoot
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Start(a.l, b.l, c.l, d.l, e.l)
  Continue(a.l)
  Abort(a.l, b.l)
  Terminate(a.l)
  Suspend()
  Resume()
EndInterface

; IInternetProtocol interface definition
;
Interface IInternetProtocol
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Start(a.l, b.l, c.l, d.l, e.l)
  Continue(a.l)
  Abort(a.l, b.l)
  Terminate(a.l)
  Suspend()
  Resume()
  Read(a.l, b.l, c.l)
  Seek(a.q, b.l, c.l)
  LockRequest(a.l)
  UnlockRequest()
EndInterface

; IInternetProtocolSink interface definition
;
Interface IInternetProtocolSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Switch(a.l)
  ReportProgress(a.l, b.l)
  ReportData(a.l, b.l, c.l)
  ReportResult(a.l, b.l, c.l)
EndInterface

; IInternetProtocolSinkStackable interface definition
;
Interface IInternetProtocolSinkStackable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SwitchSink(a.l)
  CommitSwitch()
  RollbackSwitch()
EndInterface

; IInternetSession interface definition
;
Interface IInternetSession
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RegisterNameSpace(a.l, b.l, c.l, d.l, e.l, f.l)
  UnregisterNameSpace(a.l, b.l)
  RegisterMimeFilter(a.l, b.l, c.l)
  UnregisterMimeFilter(a.l, b.l)
  CreateBinding(a.l, b.l, c.l, d.l, e.l, f.l)
  SetSessionOption(a.l, b.l, c.l, d.l)
  GetSessionOption(a.l, b.l, c.l, d.l)
EndInterface

; IInternetThreadSwitch interface definition
;
Interface IInternetThreadSwitch
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Prepare()
  Continue()
EndInterface

; IInternetPriority interface definition
;
Interface IInternetPriority
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetPriority(a.l)
  GetPriority(a.l)
EndInterface

; IInternetProtocolInfo interface definition
;
Interface IInternetProtocolInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ParseUrl(a.l, b.l, c.l, d.p-unicode, e.l, f.l, g.l)
  CombineUrl(a.l, b.l, c.l, d.p-unicode, e.l, f.l, g.l)
  CompareUrl(a.l, b.l, c.l)
  QueryInfo(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IInternetSecurityMgrSite interface definition
;
Interface IInternetSecurityMgrSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  EnableModeless(a.l)
EndInterface

; IInternetSecurityManager interface definition
;
Interface IInternetSecurityManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetSecuritySite(a.l)
  GetSecuritySite(a.l)
  MapUrlToZone(a.l, b.l, c.l)
  GetSecurityId(a.l, b.l, c.l, d.l)
  ProcessUrlAction(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  QueryCustomPolicy(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SetZoneMapping(a.l, b.l, c.l)
  GetZoneMappings(a.l, b.l, c.l)
EndInterface

; IInternetSecurityManagerEx interface definition
;
Interface IInternetSecurityManagerEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetSecuritySite(a.l)
  GetSecuritySite(a.l)
  MapUrlToZone(a.l, b.l, c.l)
  GetSecurityId(a.l, b.l, c.l, d.l)
  ProcessUrlAction(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  QueryCustomPolicy(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SetZoneMapping(a.l, b.l, c.l)
  GetZoneMappings(a.l, b.l, c.l)
  ProcessUrlActionEx(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
EndInterface

; IZoneIdentifier interface definition
;
Interface IZoneIdentifier
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetId(a.l)
  SetId(a.l)
  Remove()
EndInterface

; IInternetHostSecurityManager interface definition
;
Interface IInternetHostSecurityManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSecurityId(a.l, b.l, c.l)
  ProcessUrlAction(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  QueryCustomPolicy(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IInternetZoneManager interface definition
;
Interface IInternetZoneManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetZoneAttributes(a.l, b.l)
  SetZoneAttributes(a.l, b.l)
  GetZoneCustomPolicy(a.l, b.l, c.l, d.l, e.l)
  SetZoneCustomPolicy(a.l, b.l, c.l, d.l, e.l)
  GetZoneActionPolicy(a.l, b.l, c.l, d.l, e.l)
  SetZoneActionPolicy(a.l, b.l, c.l, d.l, e.l)
  PromptAction(a.l, b.l, c.l, d.l, e.l)
  LogAction(a.l, b.l, c.l, d.l)
  CreateZoneEnumerator(a.l, b.l, c.l)
  GetZoneAt(a.l, b.l, c.l)
  DestroyZoneEnumerator(a.l)
  CopyTemplatePoliciesToZone(a.l, b.l, c.l)
EndInterface

; IInternetZoneManagerEx interface definition
;
Interface IInternetZoneManagerEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetZoneAttributes(a.l, b.l)
  SetZoneAttributes(a.l, b.l)
  GetZoneCustomPolicy(a.l, b.l, c.l, d.l, e.l)
  SetZoneCustomPolicy(a.l, b.l, c.l, d.l, e.l)
  GetZoneActionPolicy(a.l, b.l, c.l, d.l, e.l)
  SetZoneActionPolicy(a.l, b.l, c.l, d.l, e.l)
  PromptAction(a.l, b.l, c.l, d.l, e.l)
  LogAction(a.l, b.l, c.l, d.l)
  CreateZoneEnumerator(a.l, b.l, c.l)
  GetZoneAt(a.l, b.l, c.l)
  DestroyZoneEnumerator(a.l)
  CopyTemplatePoliciesToZone(a.l, b.l, c.l)
  GetZoneActionPolicyEx(a.l, b.l, c.l, d.l, e.l, f.l)
  SetZoneActionPolicyEx(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; ISoftDistExt interface definition
;
Interface ISoftDistExt
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ProcessSoftDist(a.l, b.l, c.l)
  GetFirstCodeBase(a.l, b.l)
  GetNextCodeBase(a.l, b.l)
  AsyncInstallDistributionUnit(a.l, b.l, c.l, d.l)
EndInterface

; ICatalogFileInfo interface definition
;
Interface ICatalogFileInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCatalogFile(a.l)
  GetJavaTrust(a.l)
EndInterface

; IDataFilter interface definition
;
Interface IDataFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DoEncode(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  DoDecode(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  SetEncodingLevel(a.l)
EndInterface

; IEncodingFilterFactory interface definition
;
Interface IEncodingFilterFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FindBestFilter(a.l, b.l, c.l, d.l)
  GetDefaultFilter(a.l, b.l, c.l)
EndInterface

; IWrappedProtocol interface definition
;
Interface IWrappedProtocol
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWrapperCode(a.l, b.l)
EndInterface
