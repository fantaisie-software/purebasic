
; IMarshal interface definition
;
Interface IMarshal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetUnmarshalClass(a.l, b.l, c.l, d.l, e.l, f.l)
  GetMarshalSizeMax(a.l, b.l, c.l, d.l, e.l, f.l)
  MarshalInterface(a.l, b.l, c.l, d.l, e.l, f.l)
  UnmarshalInterface(a.l, b.l, c.l)
  ReleaseMarshalData(a.l)
  DisconnectObject(a.l)
EndInterface

; IMarshal2 interface definition
;
Interface IMarshal2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetUnmarshalClass(a.l, b.l, c.l, d.l, e.l, f.l)
  GetMarshalSizeMax(a.l, b.l, c.l, d.l, e.l, f.l)
  MarshalInterface(a.l, b.l, c.l, d.l, e.l, f.l)
  UnmarshalInterface(a.l, b.l, c.l)
  ReleaseMarshalData(a.l)
  DisconnectObject(a.l)
EndInterface

; IMalloc interface definition
;
Interface IMalloc
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Alloc(a.l)
  Realloc(a.l, b.l)
  Free(a.l)
  GetSize(a.l)
  DidAlloc(a.l)
  HeapMinimize()
EndInterface

; IMallocSpy interface definition
;
Interface IMallocSpy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IStdMarshalInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassForHandler(a.l, b.l, c.l)
EndInterface

; IExternalConnection interface definition
;
Interface IExternalConnection
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddConnection(a.l, b.l)
  ReleaseConnection(a.l, b.l, c.l)
EndInterface

; IMultiQI interface definition
;
Interface IMultiQI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryMultipleInterfaces(a.l, b.l)
EndInterface

; AsyncIMultiQI interface definition
;
Interface AsyncIMultiQI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin_QueryMultipleInterfaces(a.l, b.l)
  Finish_QueryMultipleInterfaces(a.l)
EndInterface

; IInternalUnknown interface definition
;
Interface IInternalUnknown
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryInternalInterface(a.l, b.l)
EndInterface

; IEnumUnknown interface definition
;
Interface IEnumUnknown
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IBindCtx interface definition
;
Interface IBindCtx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IEnumMoniker
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IRunnableObject interface definition
;
Interface IRunnableObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetRunningClass(a.l)
  Run(a.l)
  IsRunning()
  LockRunning(a.l, b.l)
  SetContainedObject(a.l)
EndInterface

; IRunningObjectTable interface definition
;
Interface IRunningObjectTable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IPersist
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
EndInterface

; IPersistStream interface definition
;
Interface IPersistStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  IsDirty()
  Load(a.l)
  Save(a.l, b.l)
  GetSizeMax(a.l)
EndInterface

; IMoniker interface definition
;
Interface IMoniker
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  IsDirty()
  Load(a.l)
  Save(a.l, b.l)
  GetSizeMax(a.l)
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
Interface IROTData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetComparisonData(a.l, b.l, c.l)
EndInterface

; IEnumString interface definition
;
Interface IEnumString
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; ISequentialStream interface definition
;
Interface ISequentialStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Read(a.l, b.l, c.l)
  Write(a.l, b.l, c.l)
EndInterface

; IStream interface definition
;
Interface IStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Read(a.l, b.l, c.l)
  Write(a.l, b.l, c.l)
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
Interface IEnumSTATSTG
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IStorage interface definition
;
Interface IStorage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IPersistFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  IsDirty()
  Load(a.p-unicode, b.l)
  Save(a.p-unicode, b.l)
  SaveCompleted(a.p-unicode)
  GetCurFile(a.l)
EndInterface

; IPersistStorage interface definition
;
Interface IPersistStorage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  IsDirty()
  InitNew(a.l)
  Load(a.p-unicode)
  Save(a.p-unicode, b.l)
  SaveCompleted(a.p-unicode)
  HandsOffStorage()
EndInterface

; ILockBytes interface definition
;
Interface ILockBytes
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IEnumFORMATETC
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumSTATDATA interface definition
;
Interface IEnumSTATDATA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IRootStorage interface definition
;
Interface IRootStorage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SwitchToFile(a.p-unicode)
EndInterface

; IAdviseSink interface definition
;
Interface IAdviseSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnDataChange(a.l, b.l)
  OnViewChange(a.l, b.l)
  OnRename(a.l)
  OnSave()
  OnClose()
EndInterface

; AsyncIAdviseSink interface definition
;
Interface AsyncIAdviseSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IAdviseSink2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnDataChange(a.l, b.l)
  OnViewChange(a.l, b.l)
  OnRename(a.l)
  OnSave()
  OnClose()
  OnLinkSrcChange(a.l)
EndInterface

; AsyncIAdviseSink2 interface definition
;
Interface AsyncIAdviseSink2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IDataObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IDataAdviseHolder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Advise(a.l, b.l, c.l, d.l, e.l)
  Unadvise(a.l)
  EnumAdvise(a.l)
  SendOnDataChange(a.l, b.l, c.l)
EndInterface

; IMessageFilter interface definition
;
Interface IMessageFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  HandleInComingCall(a.l, b.l, c.l, d.l)
  RetryRejectedCall(a.l, b.l, c.l)
  MessagePending(a.l, b.l, c.l)
EndInterface

; IRpcChannelBuffer interface definition
;
Interface IRpcChannelBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBuffer(a.l, b.l)
  SendReceive(a.l, b.l)
  FreeBuffer(a.l)
  GetDestCtx(a.l, b.l)
  IsConnected()
EndInterface

; IRpcChannelBuffer2 interface definition
;
Interface IRpcChannelBuffer2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBuffer(a.l, b.l)
  SendReceive(a.l, b.l)
  FreeBuffer(a.l)
  GetDestCtx(a.l, b.l)
  IsConnected()
  GetProtocolVersion(a.l)
EndInterface

; IAsyncRpcChannelBuffer interface definition
;
Interface IAsyncRpcChannelBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBuffer(a.l, b.l)
  SendReceive(a.l, b.l)
  FreeBuffer(a.l)
  GetDestCtx(a.l, b.l)
  IsConnected()
  GetProtocolVersion(a.l)
  Send(a.l, b.l, c.l)
  Receive(a.l, b.l)
  GetDestCtxEx(a.l, b.l, c.l)
EndInterface

; IRpcChannelBuffer3 interface definition
;
Interface IRpcChannelBuffer3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBuffer(a.l, b.l)
  SendReceive(a.l, b.l)
  FreeBuffer(a.l)
  GetDestCtx(a.l, b.l)
  IsConnected()
  GetProtocolVersion(a.l)
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
Interface IRpcSyntaxNegotiate
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  NegotiateSyntax(a.l)
EndInterface

; IRpcProxyBuffer interface definition
;
Interface IRpcProxyBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l)
  Disconnect()
EndInterface

; IRpcStubBuffer interface definition
;
Interface IRpcStubBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IPSFactoryBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateProxy(a.l, b.l, c.l, d.l)
  CreateStub(a.l, b.l, c.l)
EndInterface

; IChannelHook interface definition
;
Interface IChannelHook
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ClientGetSize(a.l, b.l, c.l)
  ClientFillBuffer(a.l, b.l, c.l, d.l)
  ClientNotify(a.l, b.l, c.l, d.l, e.l, f.l)
  ServerNotify(a.l, b.l, c.l, d.l, e.l)
  ServerGetSize(a.l, b.l, c.l, d.l)
  ServerFillBuffer(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IClientSecurity interface definition
;
Interface IClientSecurity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryBlanket(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  SetBlanket(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CopyProxy(a.l, b.l)
EndInterface

; IServerSecurity interface definition
;
Interface IServerSecurity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryBlanket(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  ImpersonateClient()
  RevertToSelf()
  IsImpersonating()
EndInterface

; IClassActivator interface definition
;
Interface IClassActivator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassObject(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IRpcOptions interface definition
;
Interface IRpcOptions
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Set(a.l, b.l, c.l)
  Query(a.l, b.l, c.l)
EndInterface

; IFillLockBytes interface definition
;
Interface IFillLockBytes
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FillAppend(a.l, b.l, c.l)
  FillAt(a.q, b.l, c.l, d.l)
  SetFillSize(a.q)
  Terminate(a.l)
EndInterface

; IProgressNotify interface definition
;
Interface IProgressNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnProgress(a.l, b.l, c.l, d.l)
EndInterface

; ILayoutStorage interface definition
;
Interface ILayoutStorage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  LayoutScript(a.l, b.l, c.l)
  BeginMonitor()
  EndMonitor()
  ReLayoutDocfile(a.l)
  ReLayoutDocfileOnILockBytes(a.l)
EndInterface

; IBlockingLock interface definition
;
Interface IBlockingLock
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Lock(a.l)
  Unlock()
EndInterface

; ITimeAndNoticeControl interface definition
;
Interface ITimeAndNoticeControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SuppressChanges(a.l, b.l)
EndInterface

; IOplockStorage interface definition
;
Interface IOplockStorage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateStorageEx(a.l, b.l, c.l, d.l, e.l, f.l)
  OpenStorageEx(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; ISurrogate interface definition
;
Interface ISurrogate
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  LoadDllServer(a.l)
  FreeSurrogate()
EndInterface

; IGlobalInterfaceTable interface definition
;
Interface IGlobalInterfaceTable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RegisterInterfaceInGlobal(a.l, b.l, c.l)
  RevokeInterfaceFromGlobal(a.l)
  GetInterfaceFromGlobal(a.l, b.l, c.l)
EndInterface

; IDirectWriterLock interface definition
;
Interface IDirectWriterLock
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  WaitForWriteAccess(a.l)
  ReleaseWriteAccess()
  HaveWriteAccess()
EndInterface

; ISynchronize interface definition
;
Interface ISynchronize
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Wait(a.l, b.l)
  Signal()
  Reset()
EndInterface

; ISynchronizeHandle interface definition
;
Interface ISynchronizeHandle
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetHandle(a.l)
EndInterface

; ISynchronizeEvent interface definition
;
Interface ISynchronizeEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetHandle(a.l)
  SetEventHandle(a.l)
EndInterface

; ISynchronizeContainer interface definition
;
Interface ISynchronizeContainer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddSynchronize(a.l)
  WaitMultiple(a.l, b.l, c.l)
EndInterface

; ISynchronizeMutex interface definition
;
Interface ISynchronizeMutex
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Wait(a.l, b.l)
  Signal()
  Reset()
  ReleaseMutex()
EndInterface

; ICancelMethodCalls interface definition
;
Interface ICancelMethodCalls
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Cancel(a.l)
  TestCancel()
EndInterface

; IAsyncManager interface definition
;
Interface IAsyncManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CompleteCall(a.l)
  GetCallContext(a.l, b.l)
  GetState(a.l)
EndInterface

; ICallFactory interface definition
;
Interface ICallFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateCall(a.l, b.l, c.l, d.l)
EndInterface

; IRpcHelper interface definition
;
Interface IRpcHelper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDCOMProtocolVersion(a.l)
  GetIIDFromOBJREF(a.l, b.l)
EndInterface

; IReleaseMarshalBuffers interface definition
;
Interface IReleaseMarshalBuffers
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ReleaseMarshalBuffer(a.l, b.l, c.l)
EndInterface

; IWaitMultiple interface definition
;
Interface IWaitMultiple
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  WaitMultiple(a.l, b.l)
  AddSynchronize(a.l)
EndInterface

; IUrlMon interface definition
;
Interface IUrlMon
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AsyncGetClassBits(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
EndInterface

; IForegroundTransfer interface definition
;
Interface IForegroundTransfer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AllowForegroundTransfer(a.l)
EndInterface

; IAddrTrackingControl interface definition
;
Interface IAddrTrackingControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnableCOMDynamicAddrTracking()
  DisableCOMDynamicAddrTracking()
EndInterface

; IAddrExclusionControl interface definition
;
Interface IAddrExclusionControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCurrentAddrExclusionList(a.l, b.l)
  UpdateAddrExclusionList(a.l)
EndInterface

; IPipeByte interface definition
;
Interface IPipeByte
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Pull(a.l, b.l, c.l)
  Push(a.l, b.l)
EndInterface

; AsyncIPipeByte interface definition
;
Interface AsyncIPipeByte
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin_Pull(a.l)
  Finish_Pull(a.l, b.l)
  Begin_Push(a.l, b.l)
  Finish_Push()
EndInterface

; IPipeLong interface definition
;
Interface IPipeLong
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Pull(a.l, b.l, c.l)
  Push(a.l, b.l)
EndInterface

; AsyncIPipeLong interface definition
;
Interface AsyncIPipeLong
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin_Pull(a.l)
  Finish_Pull(a.l, b.l)
  Begin_Push(a.l, b.l)
  Finish_Push()
EndInterface

; IPipeDouble interface definition
;
Interface IPipeDouble
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Pull(a.l, b.l, c.l)
  Push(a.l, b.l)
EndInterface

; AsyncIPipeDouble interface definition
;
Interface AsyncIPipeDouble
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin_Pull(a.l)
  Finish_Pull(a.l, b.l)
  Begin_Push(a.l, b.l)
  Finish_Push()
EndInterface

; IThumbnailExtractor interface definition
;
Interface IThumbnailExtractor
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ExtractThumbnail(a.l, b.l, c.l, d.l, e.l, f.l)
  OnFileUpdated(a.l)
EndInterface

; IDummyHICONIncluder interface definition
;
Interface IDummyHICONIncluder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Dummy(a.l, b.l)
EndInterface

; IEnumContextProps interface definition
;
Interface IEnumContextProps
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
  Count(a.l)
EndInterface

; IContext interface definition
;
Interface IContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetProperty(a.l, b.l, c.l)
  RemoveProperty(a.l)
  GetProperty(a.l, b.l, c.l)
  EnumContextProps(a.l)
EndInterface

; IObjContext interface definition
;
Interface IObjContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetProperty(a.l, b.l, c.l)
  RemoveProperty(a.l)
  GetProperty(a.l, b.l, c.l)
  EnumContextProps(a.l)
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
Interface IProcessLock
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddRefOnProcess()
  ReleaseRefOnProcess()
EndInterface

; ISurrogateService interface definition
;
Interface ISurrogateService
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l, c.l)
  ApplicationLaunch(a.l, b.l)
  ApplicationFree(a.l)
  CatalogRefresh(a.l)
  ProcessShutdown(a.l)
EndInterface

; IComThreadingInfo interface definition
;
Interface IComThreadingInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCurrentApartmentType(a.l)
  GetCurrentThreadType(a.l)
  GetCurrentLogicalThreadId(a.l)
  SetCurrentLogicalThreadId(a.l)
EndInterface

; IProcessInitControl interface definition
;
Interface IProcessInitControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ResetInitializerTimeout(a.l)
EndInterface

; IInitializeSpy interface definition
;
Interface IInitializeSpy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  PreInitialize(a.l, b.l)
  PostInitialize(a.l, b.l, c.l)
  PreUninitialize(a.l)
  PostUninitialize(a.l)
EndInterface
