
; IMarshal interface definition
;
Interface IMarshal Extends IUnknown
  GetUnmarshalClass(a.l, b.l, c.l, d.l, e.l, f.l)
  GetMarshalSizeMax(a.l, b.l, c.l, d.l, e.l, f.l)
  MarshalInterface(a.l, b.l, c.l, d.l, e.l, f.l)
  UnmarshalInterface(a.l, b.l, c.l)
  ReleaseMarshalData(a.l)
  DisconnectObject(a.l)
EndInterface

; IMarshal2 interface definition
;
Interface IMarshal2 Extends IMarshal
EndInterface

; IMalloc interface definition
;
Interface IMalloc Extends IUnknown
  Alloc(a.l)
  Realloc(a.l, b.l)
  Free(a.l)
  GetSize(a.l)
  DidAlloc(a.l)
  HeapMinimize()
EndInterface

; IMallocSpy interface definition
;
Interface IMallocSpy Extends IUnknown
  PreAlloc(a.l)
  PostAlloc(a.l)
  PreFree(a.l, b.l)
  PostFree(a.l)
  PreRealloc(a.l, b.l, c.l, d.l)
  PostRealloc(a.l, b.l)
  PreGetSize(a.l, b.l)
  PostGetSize(a.l, b.l)
  PreDidAlloc(a.l, b.l)
  PostDidAlloc(a.l, b.l, c.l)
  PreHeapMinimize()
  PostHeapMinimize()
EndInterface

; IStdMarshalInfo interface definition
;
Interface IStdMarshalInfo Extends IUnknown
  GetClassForHandler(a.l, b.l, c.l)
EndInterface

; IExternalConnection interface definition
;
Interface IExternalConnection Extends IUnknown
  AddConnection(a.l, b.l)
  ReleaseConnection(a.l, b.l, c.l)
EndInterface

; IMultiQI interface definition
;
Interface IMultiQI Extends IUnknown
  QueryMultipleInterfaces(a.l, b.l)
EndInterface

; AsyncIMultiQI interface definition
;
Interface AsyncIMultiQI Extends IUnknown
  Begin_QueryMultipleInterfaces(a.l, b.l)
  Finish_QueryMultipleInterfaces(a.l)
EndInterface

; IInternalUnknown interface definition
;
Interface IInternalUnknown Extends IUnknown
  QueryInternalInterface(a.l, b.l)
EndInterface

; IEnumUnknown interface definition
;
Interface IEnumUnknown Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IBindCtx interface definition
;
Interface IBindCtx Extends IUnknown
  RegisterObjectBound(a.l)
  RevokeObjectBound(a.l)
  ReleaseBoundObjects()
  SetBindOptions(a.l)
  GetBindOptions(a.l)
  GetRunningObjectTable(a.l)
  RegisterObjectParam(a.p-unicode, b.l)
  GetObjectParam(a.p-unicode, b.l)
  EnumObjectParam(a.l)
  RevokeObjectParam(a.p-unicode)
EndInterface

; IEnumMoniker interface definition
;
Interface IEnumMoniker Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IRunnableObject interface definition
;
Interface IRunnableObject Extends IUnknown
  GetRunningClass(a.l)
  Run(a.l)
  IsRunning()
  LockRunning(a.l, b.l)
  SetContainedObject(a.l)
EndInterface

; IRunningObjectTable interface definition
;
Interface IRunningObjectTable Extends IUnknown
  Register(a.l, b.l, c.l, d.l)
  Revoke(a.l)
  IsRunning(a.l)
  GetObject(a.l, b.l)
  NoteChangeTime(a.l, b.l)
  GetTimeOfLastChange(a.l, b.l)
  EnumRunning(a.l)
EndInterface

; IPersist interface definition
;
Interface IPersist Extends IUnknown
  GetClassID(a.l)
EndInterface

; IPersistStream interface definition
;
Interface IPersistStream Extends IPersist
  IsDirty()
  Load(a.l)
  Save(a.l, b.l)
  GetSizeMax(a.l)
EndInterface

; IMoniker interface definition
;
Interface IMoniker Extends IPersistStream
  BindToObject(a.l, b.l, c.l, d.l)
  BindToStorage(a.l, b.l, c.l, d.l)
  Reduce(a.l, b.l, c.l, d.l)
  ComposeWith(a.l, b.l, c.l)
  Enum(a.l, b.l)
  IsEqual(a.l)
  Hash(a.l)
  IsRunning(a.l, b.l, c.l)
  GetTimeOfLastChange(a.l, b.l, c.l)
  Inverse(a.l)
  CommonPrefixWith(a.l, b.l)
  RelativePathTo(a.l, b.l)
  GetDisplayName(a.l, b.l, c.l)
  ParseDisplayName(a.l, b.l, c.p-unicode, d.l, e.l)
  IsSystemMoniker(a.l)
EndInterface

; IROTData interface definition
;
Interface IROTData Extends IUnknown
  GetComparisonData(a.l, b.l, c.l)
EndInterface

; IEnumString interface definition
;
Interface IEnumString Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; ISequentialStream interface definition
;
Interface ISequentialStream Extends IUnknown
  Read(a.l, b.l, c.l)
  Write(a.l, b.l, c.l)
EndInterface

; IStream interface definition
;
Interface IStream Extends ISequentialStream
  Seek(a.q, b.l, c.l)
  SetSize(a.q)
  CopyTo(a.l, b.q, c.l, d.l)
  Commit(a.l)
  Revert()
  LockRegion(a.q, b.q, c.l)
  UnlockRegion(a.q, b.q, c.l)
  Stat(a.l, b.l)
  Clone(a.l)
EndInterface

; IEnumSTATSTG interface definition
;
Interface IEnumSTATSTG Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IStorage interface definition
;
Interface IStorage Extends IUnknown
  CreateStream(a.l, b.l, c.l, d.l, e.l)
  OpenStream(a.l, b.l, c.l, d.l, e.l)
  CreateStorage(a.l, b.l, c.l, d.l, e.l)
  OpenStorage(a.l, b.l, c.l, d.l, e.l, f.l)
  CopyTo(a.l, b.l, c.l, d.l)
  MoveElementTo(a.l, b.l, c.l, d.l)
  Commit(a.l)
  Revert()
  EnumElements(a.l, b.l, c.l, d.l)
  DestroyElement(a.l)
  RenameElement(a.l, b.l)
  SetElementTimes(a.l, b.l, c.l, d.l)
  SetClass(a.l)
  SetStateBits(a.l, b.l)
  Stat(a.l, b.l)
EndInterface

; IPersistFile interface definition
;
Interface IPersistFile Extends IPersist
  IsDirty()
  Load(a.p-unicode, b.l)
  Save(a.p-unicode, b.l)
  SaveCompleted(a.p-unicode)
  GetCurFile(a.l)
EndInterface

; IPersistStorage interface definition
;
Interface IPersistStorage Extends IPersist
  IsDirty()
  InitNew(a.l)
  Load(a.p-unicode)
  Save(a.p-unicode, b.l)
  SaveCompleted(a.p-unicode)
  HandsOffStorage()
EndInterface

; ILockBytes interface definition
;
Interface ILockBytes Extends IUnknown
  ReadAt(a.q, b.l, c.l, d.l)
  WriteAt(a.q, b.l, c.l, d.l)
  Flush()
  SetSize(a.q)
  LockRegion(a.q, b.q, c.l)
  UnlockRegion(a.q, b.q, c.l)
  Stat(a.l, b.l)
EndInterface

; IEnumFORMATETC interface definition
;
Interface IEnumFORMATETC Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumSTATDATA interface definition
;
Interface IEnumSTATDATA Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IRootStorage interface definition
;
Interface IRootStorage Extends IUnknown
  SwitchToFile(a.p-unicode)
EndInterface

; IAdviseSink interface definition
;
Interface IAdviseSink Extends IUnknown
  OnDataChange(a.l, b.l)
  OnViewChange(a.l, b.l)
  OnRename(a.l)
  OnSave()
  OnClose()
EndInterface

; AsyncIAdviseSink interface definition
;
Interface AsyncIAdviseSink Extends IUnknown
  Begin_OnDataChange(a.l, b.l)
  Finish_OnDataChange()
  Begin_OnViewChange(a.l, b.l)
  Finish_OnViewChange()
  Begin_OnRename(a.l)
  Finish_OnRename()
  Begin_OnSave()
  Finish_OnSave()
  Begin_OnClose()
  Finish_OnClose()
EndInterface

; IAdviseSink2 interface definition
;
Interface IAdviseSink2 Extends IAdviseSink
  OnLinkSrcChange(a.l)
EndInterface

; AsyncIAdviseSink2 interface definition
;
Interface AsyncIAdviseSink2 Extends IUnknown
  Begin_OnDataChange(a.l, b.l)
  Finish_OnDataChange()
  Begin_OnViewChange(a.l, b.l)
  Finish_OnViewChange()
  Begin_OnRename(a.l)
  Finish_OnRename()
  Begin_OnSave()
  Finish_OnSave()
  Begin_OnClose()
  Finish_OnClose()
  Begin_OnLinkSrcChange(a.l)
  Finish_OnLinkSrcChange()
EndInterface

; IDataObject interface definition
;
Interface IDataObject Extends IUnknown
  GetData(a.l, b.l)
  GetDataHere(a.l, b.l)
  QueryGetData(a.l)
  GetCanonicalFormatEtc(a.l, b.l)
  SetData(a.l, b.l, c.l)
  EnumFormatEtc(a.l, b.l)
  DAdvise(a.l, b.l, c.l, d.l)
  DUnadvise(a.l)
  EnumDAdvise(a.l)
EndInterface

; IDataAdviseHolder interface definition
;
Interface IDataAdviseHolder Extends IUnknown
  Advise(a.l, b.l, c.l, d.l, e.l)
  Unadvise(a.l)
  EnumAdvise(a.l)
  SendOnDataChange(a.l, b.l, c.l)
EndInterface

; IMessageFilter interface definition
;
Interface IMessageFilter Extends IUnknown
  HandleInComingCall(a.l, b.l, c.l, d.l)
  RetryRejectedCall(a.l, b.l, c.l)
  MessagePending(a.l, b.l, c.l)
EndInterface

; IRpcChannelBuffer interface definition
;
Interface IRpcChannelBuffer Extends IUnknown
  GetBuffer(a.l, b.l)
  SendReceive(a.l, b.l)
  FreeBuffer(a.l)
  GetDestCtx(a.l, b.l)
  IsConnected()
EndInterface

; IRpcChannelBuffer2 interface definition
;
Interface IRpcChannelBuffer2 Extends IRpcChannelBuffer
  GetProtocolVersion(a.l)
EndInterface

; IAsyncRpcChannelBuffer interface definition
;
Interface IAsyncRpcChannelBuffer Extends IRpcChannelBuffer2
  Send(a.l, b.l, c.l)
  Receive(a.l, b.l)
  GetDestCtxEx(a.l, b.l, c.l)
EndInterface

; IRpcChannelBuffer3 interface definition
;
Interface IRpcChannelBuffer3 Extends IRpcChannelBuffer2
  Send(a.l, b.l)
  Receive(a.l, b.l, c.l)
  Cancel(a.l)
  GetCallContext(a.l, b.l, c.l)
  GetDestCtxEx(a.l, b.l, c.l)
  GetState(a.l, b.l)
  RegisterAsync(a.l, b.l)
EndInterface

; IRpcSyntaxNegotiate interface definition
;
Interface IRpcSyntaxNegotiate Extends IUnknown
  NegotiateSyntax(a.l)
EndInterface

; IRpcProxyBuffer interface definition
;
Interface IRpcProxyBuffer Extends IUnknown
  Connect(a.l)
  Disconnect()
EndInterface

; IRpcStubBuffer interface definition
;
Interface IRpcStubBuffer Extends IUnknown
  Connect(a.l)
  Disconnect()
  Invoke(a.l, b.l)
  IsIIDSupported(a.l)
  CountRefs()
  DebugServerQueryInterface(a.l)
  DebugServerRelease(a.l)
EndInterface

; IPSFactoryBuffer interface definition
;
Interface IPSFactoryBuffer Extends IUnknown
  CreateProxy(a.l, b.l, c.l, d.l)
  CreateStub(a.l, b.l, c.l)
EndInterface

; IChannelHook interface definition
;
Interface IChannelHook Extends IUnknown
  ClientGetSize(a.l, b.l, c.l)
  ClientFillBuffer(a.l, b.l, c.l, d.l)
  ClientNotify(a.l, b.l, c.l, d.l, e.l, f.l)
  ServerNotify(a.l, b.l, c.l, d.l, e.l)
  ServerGetSize(a.l, b.l, c.l, d.l)
  ServerFillBuffer(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IClientSecurity interface definition
;
Interface IClientSecurity Extends IUnknown
  QueryBlanket(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  SetBlanket(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CopyProxy(a.l, b.l)
EndInterface

; IServerSecurity interface definition
;
Interface IServerSecurity Extends IUnknown
  QueryBlanket(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  ImpersonateClient()
  RevertToSelf()
  IsImpersonating()
EndInterface

; IClassActivator interface definition
;
Interface IClassActivator Extends IUnknown
  GetClassObject(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IRpcOptions interface definition
;
Interface IRpcOptions Extends IUnknown
  Set(a.l, b.l, c.l)
  Query(a.l, b.l, c.l)
EndInterface

; IFillLockBytes interface definition
;
Interface IFillLockBytes Extends IUnknown
  FillAppend(a.l, b.l, c.l)
  FillAt(a.q, b.l, c.l, d.l)
  SetFillSize(a.q)
  Terminate(a.l)
EndInterface

; IProgressNotify interface definition
;
Interface IProgressNotify Extends IUnknown
  OnProgress(a.l, b.l, c.l, d.l)
EndInterface

; ILayoutStorage interface definition
;
Interface ILayoutStorage Extends IUnknown
  LayoutScript(a.l, b.l, c.l)
  BeginMonitor()
  EndMonitor()
  ReLayoutDocfile(a.l)
  ReLayoutDocfileOnILockBytes(a.l)
EndInterface

; IBlockingLock interface definition
;
Interface IBlockingLock Extends IUnknown
  Lock(a.l)
  Unlock()
EndInterface

; ITimeAndNoticeControl interface definition
;
Interface ITimeAndNoticeControl Extends IUnknown
  SuppressChanges(a.l, b.l)
EndInterface

; IOplockStorage interface definition
;
Interface IOplockStorage Extends IUnknown
  CreateStorageEx(a.l, b.l, c.l, d.l, e.l, f.l)
  OpenStorageEx(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; ISurrogate interface definition
;
Interface ISurrogate Extends IUnknown
  LoadDllServer(a.l)
  FreeSurrogate()
EndInterface

; IGlobalInterfaceTable interface definition
;
Interface IGlobalInterfaceTable Extends IUnknown
  RegisterInterfaceInGlobal(a.l, b.l, c.l)
  RevokeInterfaceFromGlobal(a.l)
  GetInterfaceFromGlobal(a.l, b.l, c.l)
EndInterface

; IDirectWriterLock interface definition
;
Interface IDirectWriterLock Extends IUnknown
  WaitForWriteAccess(a.l)
  ReleaseWriteAccess()
  HaveWriteAccess()
EndInterface

; ISynchronize interface definition
;
Interface ISynchronize Extends IUnknown
  Wait(a.l, b.l)
  Signal()
  Reset()
EndInterface

; ISynchronizeHandle interface definition
;
Interface ISynchronizeHandle Extends IUnknown
  GetHandle(a.l)
EndInterface

; ISynchronizeEvent interface definition
;
Interface ISynchronizeEvent Extends ISynchronizeHandle
  SetEventHandle(a.l)
EndInterface

; ISynchronizeContainer interface definition
;
Interface ISynchronizeContainer Extends IUnknown
  AddSynchronize(a.l)
  WaitMultiple(a.l, b.l, c.l)
EndInterface

; ISynchronizeMutex interface definition
;
Interface ISynchronizeMutex Extends ISynchronize
  ReleaseMutex()
EndInterface

; ICancelMethodCalls interface definition
;
Interface ICancelMethodCalls Extends IUnknown
  Cancel(a.l)
  TestCancel()
EndInterface

; IAsyncManager interface definition
;
Interface IAsyncManager Extends IUnknown
  CompleteCall(a.l)
  GetCallContext(a.l, b.l)
  GetState(a.l)
EndInterface

; ICallFactory interface definition
;
Interface ICallFactory Extends IUnknown
  CreateCall(a.l, b.l, c.l, d.l)
EndInterface

; IRpcHelper interface definition
;
Interface IRpcHelper Extends IUnknown
  GetDCOMProtocolVersion(a.l)
  GetIIDFromOBJREF(a.l, b.l)
EndInterface

; IReleaseMarshalBuffers interface definition
;
Interface IReleaseMarshalBuffers Extends IUnknown
  ReleaseMarshalBuffer(a.l, b.l, c.l)
EndInterface

; IWaitMultiple interface definition
;
Interface IWaitMultiple Extends IUnknown
  WaitMultiple(a.l, b.l)
  AddSynchronize(a.l)
EndInterface

; IUrlMon interface definition
;
Interface IUrlMon Extends IUnknown
  AsyncGetClassBits(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
EndInterface

; IForegroundTransfer interface definition
;
Interface IForegroundTransfer Extends IUnknown
  AllowForegroundTransfer(a.l)
EndInterface

; IAddrTrackingControl interface definition
;
Interface IAddrTrackingControl Extends IUnknown
  EnableCOMDynamicAddrTracking()
  DisableCOMDynamicAddrTracking()
EndInterface

; IAddrExclusionControl interface definition
;
Interface IAddrExclusionControl Extends IUnknown
  GetCurrentAddrExclusionList(a.l, b.l)
  UpdateAddrExclusionList(a.l)
EndInterface

; IPipeByte interface definition
;
Interface IPipeByte Extends IUnknown
  Pull(a.l, b.l, c.l)
  Push(a.l, b.l)
EndInterface

; AsyncIPipeByte interface definition
;
Interface AsyncIPipeByte Extends IUnknown
  Begin_Pull(a.l)
  Finish_Pull(a.l, b.l)
  Begin_Push(a.l, b.l)
  Finish_Push()
EndInterface

; IPipeLong interface definition
;
Interface IPipeLong Extends IUnknown
  Pull(a.l, b.l, c.l)
  Push(a.l, b.l)
EndInterface

; AsyncIPipeLong interface definition
;
Interface AsyncIPipeLong Extends IUnknown
  Begin_Pull(a.l)
  Finish_Pull(a.l, b.l)
  Begin_Push(a.l, b.l)
  Finish_Push()
EndInterface

; IPipeDouble interface definition
;
Interface IPipeDouble Extends IUnknown
  Pull(a.l, b.l, c.l)
  Push(a.l, b.l)
EndInterface

; AsyncIPipeDouble interface definition
;
Interface AsyncIPipeDouble Extends IUnknown
  Begin_Pull(a.l)
  Finish_Pull(a.l, b.l)
  Begin_Push(a.l, b.l)
  Finish_Push()
EndInterface

; IThumbnailExtractor interface definition
;
Interface IThumbnailExtractor Extends IUnknown
  ExtractThumbnail(a.l, b.l, c.l, d.l, e.l, f.l)
  OnFileUpdated(a.l)
EndInterface

; IDummyHICONIncluder interface definition
;
Interface IDummyHICONIncluder Extends IUnknown
  Dummy(a.l, b.l)
EndInterface

; IEnumContextProps interface definition
;
Interface IEnumContextProps Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
  Count(a.l)
EndInterface

; IContext interface definition
;
Interface IContext Extends IUnknown
  SetProperty(a.l, b.l, c.l)
  RemoveProperty(a.l)
  GetProperty(a.l, b.l, c.l)
  EnumContextProps(a.l)
EndInterface

; IObjContext interface definition
;
Interface IObjContext Extends IContext
  Reserved1()
  Reserved2()
  Reserved3()
  Reserved4()
  Reserved5()
  Reserved6()
  Reserved7()
EndInterface

; IProcessLock interface definition
;
Interface IProcessLock Extends IUnknown
  AddRefOnProcess()
  ReleaseRefOnProcess()
EndInterface

; ISurrogateService interface definition
;
Interface ISurrogateService Extends IUnknown
  Init(a.l, b.l, c.l)
  ApplicationLaunch(a.l, b.l)
  ApplicationFree(a.l)
  CatalogRefresh(a.l)
  ProcessShutdown(a.l)
EndInterface

; IComThreadingInfo interface definition
;
Interface IComThreadingInfo Extends IUnknown
  GetCurrentApartmentType(a.l)
  GetCurrentThreadType(a.l)
  GetCurrentLogicalThreadId(a.l)
  SetCurrentLogicalThreadId(a.l)
EndInterface

; IProcessInitControl interface definition
;
Interface IProcessInitControl Extends IUnknown
  ResetInitializerTimeout(a.l)
EndInterface

; IInitializeSpy interface definition
;
Interface IInitializeSpy Extends IUnknown
  PreInitialize(a.l, b.l)
  PostInitialize(a.l, b.l, c.l)
  PreUninitialize(a.l)
  PostUninitialize(a.l)
EndInterface
