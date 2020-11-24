
; ITVETrigger interface definition
;
Interface ITVETrigger
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Parent(a.l)
  get_Service(a.l)
  get_IsValid(a.l)
  get_URL(a.l)
  get_Name(a.l)
  get_Expires(a.l)
  get_Executes(a.l)
  get_Script(a.l)
  get_TVELevel(a.l)
  get_Rest(a.l)
  ParseTrigger(a.l)
EndInterface

; ITVETrigger_Helper interface definition
;
Interface ITVETrigger_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectParent(a.l)
  get_CRC(a.l, b.l)
  UpdateFrom(a.l, b.l)
  RemoveYourself()
  DumpToBSTR(a.l)
EndInterface

; ITVETrack interface definition
;
Interface ITVETrack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Parent(a.l)
  get_Service(a.l)
  get_Trigger(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  AttachTrigger(a.l)
  ReleaseTrigger()
  CreateTrigger(a.l)
EndInterface

; ITVETrack_Helper interface definition
;
Interface ITVETrack_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectParent(a.l)
  RemoveYourself()
  DumpToBSTR(a.l)
EndInterface

; ITVETracks interface definition
;
Interface ITVETracks
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
  RemoveAll()
  Insert(a.l, b.l)
EndInterface

; ITVEVariation interface definition
;
Interface ITVEVariation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Parent(a.l)
  get_Service(a.l)
  get_Tracks(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  get_IsValid(a.l)
  get_MediaName(a.l)
  get_MediaTitle(a.l)
  get_FileIPAdapter(a.l)
  get_FileIPAddress(a.l)
  get_FilePort(a.l)
  get_TriggerIPAdapter(a.l)
  get_TriggerIPAddress(a.l)
  get_TriggerPort(a.l)
  get_Languages(a.l)
  get_SDPLanguages(a.l)
  get_Bandwidth(a.l)
  get_BandwidthInfo(a.l)
  get_Attributes(a.l)
  get_Rest(a.l)
  Initialize(a.p-bstr)
EndInterface

; ITVEVariation_Helper interface definition
;
Interface ITVEVariation_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectParent(a.l)
  DefaultTo(a.l)
  SetTriggerIPAdapter(a.p-bstr)
  SetFileIPAdapter(a.p-bstr)
  SubParseSDP(a.l, b.l)
  ParseCBTrigger(a.p-bstr)
  FinalParseSDP()
  UpdateVariation(a.l, b.l)
  InitAsXOver()
  NewXOverLink(a.p-bstr)
  RemoveYourself()
  put_MediaTitle(a.p-bstr)
  put_IsValid(a.l)
  DumpToBSTR(a.l)
EndInterface

; ITVEVariations interface definition
;
Interface ITVEVariations
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
  RemoveAll()
  Insert(a.l, b.l)
EndInterface

; ITVEEnhancement interface definition
;
Interface ITVEEnhancement
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Parent(a.l)
  get_Service(a.l)
  get_Variations(a.l)
  get_IsValid(a.l)
  get_ProtocolVersion(a.l)
  get_SessionUserName(a.l)
  get_SessionId(a.l)
  get_SessionVersion(a.l)
  get_SessionIPAddress(a.l)
  get_SessionName(a.l)
  get_EmailAddresses(a.l)
  get_PhoneNumbers(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  get_DescriptionURI(a.l)
  get_UUID(a.l)
  get_StartTime(a.l)
  get_StopTime(a.l)
  get_IsPrimary(a.l)
  get_Type(a.l)
  get_TveType(a.l)
  get_TveSize(a.l)
  get_TveLevel(a.l)
  get_Attributes(a.l)
  get_Rest(a.l)
  get_SAPHeaderBits(a.l)
  get_SAPAuthLength(a.l)
  get_SAPMsgIDHash(a.l)
  get_SAPSendingIP(a.l)
  get_SAPAuthData(a.l)
  ParseAnnouncement(a.p-bstr, b.l, c.l, d.l)
EndInterface

; ITVEEnhancement_Helper interface definition
;
Interface ITVEEnhancement_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectParent(a.l)
  Activate()
  Deactivate()
  UpdateEnhancement(a.l, b.l)
  InitAsXOver()
  NewXOverLink(a.p-bstr)
  RemoveYourself()
  DumpToBSTR(a.l)
EndInterface

; ITVEEnhancements interface definition
;
Interface ITVEEnhancements
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
  RemoveAll()
  Insert(a.l, b.l)
EndInterface

; ITVEService interface definition
;
Interface ITVEService
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Parent(a.l)
  get_Enhancements(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  Activate()
  Deactivate()
  get_XOverLinks(a.l)
  get_XOverEnhancement(a.l)
  NewXOverLink(a.p-bstr)
  get_ExpireOffset(a.l)
  put_ExpireOffset(a.l)
  get_ExpireQueue(a.l)
  ExpireForDate(a.l)
  get_IsActive(a.l)
  put_Property(a.p-bstr, b.p-bstr)
  get_Property(a.p-bstr, b.l)
EndInterface

; ITVEService_Helper interface definition
;
Interface ITVEService_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectParent(a.l)
  ParseCBAnnouncement(a.p-bstr, b.l)
  SetAnncIPValues(a.p-bstr, b.p-bstr, c.l)
  GetAnncIPValues(a.l, b.l, c.l)
  InitXOverEnhancement()
  AddToExpireQueue(a.l, b.l)
  ChangeInExpireQueue(a.l, b.l)
  RemoveFromExpireQueue(a.l)
  RemoveEnhFilesFromExpireQueue(a.l)
  get_ExpireQueueChangeCount(a.l)
  RemoveYourself()
  DumpToBSTR(a.l)
EndInterface

; ITVEFeature interface definition
;
Interface ITVEFeature
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Parent(a.l)
  get_Enhancements(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  Activate()
  Deactivate()
  get_XOverLinks(a.l)
  get_XOverEnhancement(a.l)
  NewXOverLink(a.p-bstr)
  get_ExpireOffset(a.l)
  put_ExpireOffset(a.l)
  get_ExpireQueue(a.l)
  ExpireForDate(a.l)
  get_IsActive(a.l)
  put_Property(a.p-bstr, b.p-bstr)
  get_Property(a.p-bstr, b.l)
  TuneTo(a.p-bstr, b.p-bstr)
  ReTune(a.l)
  BindToSupervisor(a.l)
  NotifyTVETune(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyTVEEnhancementNew(a.l)
  NotifyTVEEnhancementUpdated(a.l, b.l)
  NotifyTVEEnhancementStarting(a.l)
  NotifyTVEEnhancementExpired(a.l)
  NotifyTVETriggerNew(a.l, b.l)
  NotifyTVETriggerUpdated(a.l, b.l, c.l)
  NotifyTVETriggerExpired(a.l, b.l)
  NotifyTVEPackage(a.l, b.l, c.p-bstr, d.l, e.l)
  NotifyTVEFile(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyTVEAuxInfo(a.l, b.p-bstr, c.l, d.l)
EndInterface

; ITVEServices interface definition
;
Interface ITVEServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
  RemoveAll()
  Insert(a.l, b.l)
EndInterface

; ITVESupervisor interface definition
;
Interface ITVESupervisor
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Services(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  TuneTo(a.p-bstr, b.p-bstr)
  ReTune(a.l)
  NewXOverLink(a.p-bstr)
  ExpireForDate(a.l)
  InitStats()
  GetStats(a.l)
EndInterface

; ITVESupervisor_Helper interface definition
;
Interface ITVESupervisor_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectParent(a.l)
  GetActiveService(a.l)
  GetMCastManager(a.l)
  UnpackBuffer(a.l, b.l, c.l)
  NotifyEnhancement(a.l, b.l, c.l)
  NotifyTrigger(a.l, b.l, c.l)
  NotifyPackage(a.l, b.l, c.p-bstr, d.l, e.l)
  NotifyFile(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyTune(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyAuxInfo(a.l, b.p-bstr, c.l, d.l)
  NotifyEnhancement_XProxy(a.l, b.l, c.l)
  NotifyTrigger_XProxy(a.l, b.l, c.l)
  NotifyPackage_XProxy(a.l, b.l, c.p-bstr, d.l, e.l)
  NotifyFile_XProxy(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyTune_XProxy(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyAuxInfo_XProxy(a.l, b.p-bstr, c.l, d.l)
  get_HaltFlags(a.l)
  put_HaltFlags(a.l)
  RemoveAllListenersOnAdapter(a.p-bstr)
  get_PossibleIPAdapterAddress(a.l, b.l)
  DumpToBSTR(a.l)
  get_SupervisorGITProxy(a.l)
EndInterface

; ITVESupervisorGITProxy interface definition
;
Interface ITVESupervisorGITProxy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_Supervisor(a.l)
  put_Supervisor(a.l)
EndInterface

; ITVEAttrMap interface definition
;
Interface ITVEAttrMap
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  get_Key(a.p-variant, b.l)
  Add(a.p-bstr, b.p-bstr)
  Replace(a.p-bstr, b.p-bstr)
  Remove(a.p-variant)
  RemoveAll()
  Add1(a.p-bstr)
  DumpToBSTR(a.l)
EndInterface

; ITVEAttrTimeQ interface definition
;
Interface ITVEAttrTimeQ
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  get_Key(a.p-variant, b.l)
  Add(a.l, b.l)
  Remove(a.p-variant)
  RemoveAll()
  Update(a.l, b.l)
  LockRead()
  LockWrite()
  Unlock()
  RemoveSimple(a.p-variant)
  DumpToBSTR(a.l)
EndInterface

; ITVEMCast interface definition
;
Interface ITVEMCast
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_IPAdapter(a.l)
  put_IPAdapter(a.p-bstr)
  get_IPAddress(a.l)
  put_IPAddress(a.p-bstr)
  get_IPPort(a.l)
  put_IPPort(a.l)
  Join()
  Leave()
  get_IsJoined(a.l)
  get_IsSuspended(a.l)
  Suspend(a.l)
  get_PacketCount(a.l)
  get_ByteCount(a.l)
  KeepStats(a.l)
  ResetStats()
  SetReadCallback(a.l, b.l, c.l)
  ConnectManager(a.l)
  get_Manager(a.l)
  get_QueueThreadId(a.l)
  put_QueueThreadId(a.l)
  get_WhatType(a.l)
  put_WhatType(a.l)
EndInterface

; ITVEMCasts interface definition
;
Interface ITVEMCasts
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get__NewEnum(a.l)
  get_Count(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
  RemoveAll()
EndInterface

; ITVEMCastManager interface definition
;
Interface ITVEMCastManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_MCasts(a.l)
  get_Supervisor(a.l)
  put_Supervisor(a.l)
  AddMulticast(a.l, b.p-bstr, c.p-bstr, d.l, e.l, f.l, g.l)
  FindMulticast(a.p-bstr, b.p-bstr, c.l, d.l, e.l)
  RemoveMulticast(a.l)
  JoinAll()
  LeaveAll()
  SuspendAll(a.l)
  Lock_()
  Unlock_()
  DumpStatsToBSTR(a.l, b.l)
  get_HaltFlags(a.l)
  put_HaltFlags(a.l)
EndInterface

; ITVEMCastManager_Helper interface definition
;
Interface ITVEMCastManager_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DumpString(a.p-bstr)
  CreateQueueThread()
  KillQueueThread()
  PostToQueueThread(a.l, b.l, c.l)
  GetPacketCounts(a.l, b.l, c.l)
EndInterface

; ITVEMCastCallback interface definition
;
Interface ITVEMCastCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  SetMCast(a.l)
  ProcessPacket(a.l, b.l, c.l)
  PostPacket(a.l, b.l, c.l)
EndInterface

; ITVECBAnnc interface definition
;
Interface ITVECBAnnc
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Init(a.p-bstr, b.l)
EndInterface

; ITVECBTrig interface definition
;
Interface ITVECBTrig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Init(a.l)
EndInterface

; ITVECBFile interface definition
;
Interface ITVECBFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Init(a.l, b.l)
EndInterface

; ITVECBDummy interface definition
;
Interface ITVECBDummy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Init(a.l)
EndInterface

; ITVEFile interface definition
;
Interface ITVEFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  InitializeFile(a.l, b.p-bstr, c.p-bstr, d.l)
  InitializePackage(a.l, b.p-bstr, c.p-bstr, d.l)
  get_Description(a.l)
  get_Location(a.l)
  get_ExpireTime(a.l)
  get_IsPackage(a.l)
  get_Variation(a.l)
  get_Service(a.l)
  RemoveYourself()
  DumpToBSTR(a.l)
EndInterface

; ITVENavAid interface definition
;
Interface ITVENavAid
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_WebBrowserApp(a.l)
  get_WebBrowserApp(a.l)
  get_TVETriggerCtrl(a.l)
  put_EnableAutoTriggering(a.l)
  get_EnableAutoTriggering(a.l)
  get_ActiveVariation(a.l)
  put_ActiveVariation(a.l)
  get_TVEFeature(a.l)
  get_CacheState(a.l)
  put_CacheState(a.p-bstr)
  NavUsingTVETrigger(a.l, b.l, c.l)
  ExecScript(a.p-bstr, b.p-bstr)
  Navigate(a.l, b.l, c.l, d.l, e.l)
  get_CurrTVEName(a.l)
  get_CurrTVEURL(a.l)
  NotifyTVETune(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyTVEEnhancementNew(a.l)
  NotifyTVEEnhancementUpdated(a.l, b.l)
  NotifyTVEEnhancementStarting(a.l)
  NotifyTVEEnhancementExpired(a.l)
  NotifyTVETriggerNew(a.l, b.l)
  NotifyTVETriggerUpdated(a.l, b.l, c.l)
  NotifyTVETriggerExpired(a.l, b.l)
  NotifyTVEPackage(a.l, b.l, c.p-bstr, d.l, e.l)
  NotifyTVEFile(a.l, b.l, c.p-bstr, d.p-bstr)
  NotifyTVEAuxInfo(a.l, b.p-bstr, c.l, d.l)
  NotifyStatusTextChange(a.p-bstr)
  NotifyProgressChange(a.l, b.l)
  NotifyCommandStateChange(a.l, b.l)
  NotifyDownloadBegin()
  NotifyDownloadComplete()
  NotifyTitleChange(a.p-bstr)
  NotifyPropertyChange(a.p-bstr)
  NotifyBeforeNavigate2(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  NotifyNewWindow2(a.l, b.l)
  NotifyNavigateComplete2(a.l, b.l)
  NotifyDocumentComplete(a.l, b.l)
  NotifyOnQuit()
  NotifyOnVisible(a.l)
  NotifyOnToolBar(a.l)
  NotifyOnMenuBar(a.l)
  NotifyOnStatusBar(a.l)
  NotifyOnFullScreen(a.l)
  NotifyOnTheaterMode(a.l)
EndInterface

; ITVENavAid_NoVidCtl interface definition
;
Interface ITVENavAid_NoVidCtl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_NoVidCtl_Supervisor(a.l)
  get_NoVidCtl_Supervisor(a.l)
EndInterface

; ITVENavAid_Helper interface definition
;
Interface ITVENavAid_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  LocateVidAndTriggerCtrls(a.l, b.l)
  NotifyTVETriggerUpdated_XProxy(a.l, b.l, c.l)
  ReInitCurrNavState(a.l)
EndInterface

; ITVEFilter interface definition
;
Interface ITVEFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_SupervisorPunk(a.l)
  get_IPAdapterAddress(a.l)
  put_IPAdapterAddress(a.p-bstr)
  get_StationID(a.l)
  put_StationID(a.p-bstr)
  get_MulticastList(a.l)
  get_AdapterDescription(a.l)
  ReTune()
  get_HaltFlags(a.l)
  put_HaltFlags(a.l)
  ParseCCBytePair(a.l, b.l, c.l)
  get_IPSinkAdapterAddress(a.l)
EndInterface

; ITVEFilter_Helper interface definition
;
Interface ITVEFilter_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
EndInterface

; ITVETriggerCtrl interface definition
;
Interface ITVETriggerCtrl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_enabled(a.l)
  get_enabled(a.l)
  get_sourceID(a.l)
  put_releasable(a.l)
  get_releasable(a.l)
  get_backChannel(a.l)
  get_contentLevel(a.l)
EndInterface

; ITVETriggerCtrl_Helper interface definition
;
Interface ITVETriggerCtrl_Helper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_sourceID(a.p-bstr)
  get_TopLevelPage(a.l)
EndInterface

; _ITVEEvents interface definition
;
Interface _ITVEEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; _ITVETriggerCtrlEvents interface definition
;
Interface _ITVETriggerCtrlEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface
