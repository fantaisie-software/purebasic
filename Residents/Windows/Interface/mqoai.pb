
; IMSMQQuery interface definition
;
Interface IMSMQQuery Extends IDispatch
  LookupQueue(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
EndInterface

; IMSMQQueueInfo interface definition
;
Interface IMSMQQueueInfo Extends IDispatch
  get_QueueGuid(a.l)
  get_ServiceTypeGuid(a.l)
  put_ServiceTypeGuid(a.p-bstr)
  get_Label(a.l)
  put_Label(a.p-bstr)
  get_PathName(a.l)
  put_PathName(a.p-bstr)
  get_FormatName(a.l)
  put_FormatName(a.p-bstr)
  get_IsTransactional(a.l)
  get_PrivLevel(a.l)
  put_PrivLevel(a.l)
  get_Journal(a.l)
  put_Journal(a.l)
  get_Quota(a.l)
  put_Quota(a.l)
  get_BasePriority(a.l)
  put_BasePriority(a.l)
  get_CreateTime(a.l)
  get_ModifyTime(a.l)
  get_Authenticate(a.l)
  put_Authenticate(a.l)
  get_JournalQuota(a.l)
  put_JournalQuota(a.l)
  get_IsWorldReadable(a.l)
  Create(a.l, b.l)
  Delete()
  Open(a.l, b.l, c.l)
  Refresh()
  Update()
EndInterface

; IMSMQQueueInfo2 interface definition
;
Interface IMSMQQueueInfo2 Extends IDispatch
  get_QueueGuid(a.l)
  get_ServiceTypeGuid(a.l)
  put_ServiceTypeGuid(a.p-bstr)
  get_Label(a.l)
  put_Label(a.p-bstr)
  get_PathName(a.l)
  put_PathName(a.p-bstr)
  get_FormatName(a.l)
  put_FormatName(a.p-bstr)
  get_IsTransactional(a.l)
  get_PrivLevel(a.l)
  put_PrivLevel(a.l)
  get_Journal(a.l)
  put_Journal(a.l)
  get_Quota(a.l)
  put_Quota(a.l)
  get_BasePriority(a.l)
  put_BasePriority(a.l)
  get_CreateTime(a.l)
  get_ModifyTime(a.l)
  get_Authenticate(a.l)
  put_Authenticate(a.l)
  get_JournalQuota(a.l)
  put_JournalQuota(a.l)
  get_IsWorldReadable(a.l)
  Create(a.l, b.l)
  Delete()
  Open(a.l, b.l, c.l)
  Refresh()
  Update()
  get_PathNameDNS(a.l)
  get_Properties(a.l)
  get_Security(a.l)
  put_Security(a.p-variant)
EndInterface

; IMSMQQueueInfo3 interface definition
;
Interface IMSMQQueueInfo3 Extends IDispatch
  get_QueueGuid(a.l)
  get_ServiceTypeGuid(a.l)
  put_ServiceTypeGuid(a.p-bstr)
  get_Label(a.l)
  put_Label(a.p-bstr)
  get_PathName(a.l)
  put_PathName(a.p-bstr)
  get_FormatName(a.l)
  put_FormatName(a.p-bstr)
  get_IsTransactional(a.l)
  get_PrivLevel(a.l)
  put_PrivLevel(a.l)
  get_Journal(a.l)
  put_Journal(a.l)
  get_Quota(a.l)
  put_Quota(a.l)
  get_BasePriority(a.l)
  put_BasePriority(a.l)
  get_CreateTime(a.l)
  get_ModifyTime(a.l)
  get_Authenticate(a.l)
  put_Authenticate(a.l)
  get_JournalQuota(a.l)
  put_JournalQuota(a.l)
  get_IsWorldReadable(a.l)
  Create(a.l, b.l)
  Delete()
  Open(a.l, b.l, c.l)
  Refresh()
  Update()
  get_PathNameDNS(a.l)
  get_Properties(a.l)
  get_Security(a.l)
  put_Security(a.p-variant)
  get_IsTransactional2(a.l)
  get_IsWorldReadable2(a.l)
  get_MulticastAddress(a.l)
  put_MulticastAddress(a.p-bstr)
  get_ADsPath(a.l)
EndInterface

; IMSMQQueue interface definition
;
Interface IMSMQQueue Extends IDispatch
  get_Access(a.l)
  get_ShareMode(a.l)
  get_QueueInfo(a.l)
  get_Handle(a.l)
  get_IsOpen(a.l)
  Close()
  Receive(a.l, b.l, c.l, d.l, e.l)
  Peek(a.l, b.l, c.l, d.l)
  EnableNotification(a.l, b.l, c.l)
  Reset()
  ReceiveCurrent(a.l, b.l, c.l, d.l, e.l)
  PeekNext(a.l, b.l, c.l, d.l)
  PeekCurrent(a.l, b.l, c.l, d.l)
EndInterface

; IMSMQQueue2 interface definition
;
Interface IMSMQQueue2 Extends IDispatch
  get_Access(a.l)
  get_ShareMode(a.l)
  get_QueueInfo(a.l)
  get_Handle(a.l)
  get_IsOpen(a.l)
  Close()
  Receive_v1(a.l, b.l, c.l, d.l, e.l)
  Peek_v1(a.l, b.l, c.l, d.l)
  EnableNotification(a.l, b.l, c.l)
  Reset()
  ReceiveCurrent_v1(a.l, b.l, c.l, d.l, e.l)
  PeekNext_v1(a.l, b.l, c.l, d.l)
  PeekCurrent_v1(a.l, b.l, c.l, d.l)
  Receive(a.l, b.l, c.l, d.l, e.l, f.l)
  Peek(a.l, b.l, c.l, d.l, e.l)
  ReceiveCurrent(a.l, b.l, c.l, d.l, e.l, f.l)
  PeekNext(a.l, b.l, c.l, d.l, e.l)
  PeekCurrent(a.l, b.l, c.l, d.l, e.l)
  get_Properties(a.l)
EndInterface

; IMSMQMessage interface definition
;
Interface IMSMQMessage Extends IDispatch
  get_Class(a.l)
  get_PrivLevel(a.l)
  put_PrivLevel(a.l)
  get_AuthLevel(a.l)
  put_AuthLevel(a.l)
  get_IsAuthenticated(a.l)
  get_Delivery(a.l)
  put_Delivery(a.l)
  get_Trace(a.l)
  put_Trace(a.l)
  get_Priority(a.l)
  put_Priority(a.l)
  get_Journal(a.l)
  put_Journal(a.l)
  get_ResponseQueueInfo(a.l)
  putref_ResponseQueueInfo(a.l)
  get_AppSpecific(a.l)
  put_AppSpecific(a.l)
  get_SourceMachineGuid(a.l)
  get_BodyLength(a.l)
  get_Body(a.l)
  put_Body(a.p-variant)
  get_AdminQueueInfo(a.l)
  putref_AdminQueueInfo(a.l)
  get_Id(a.l)
  get_CorrelationId(a.l)
  put_CorrelationId(a.p-variant)
  get_Ack(a.l)
  put_Ack(a.l)
  get_Label(a.l)
  put_Label(a.p-bstr)
  get_MaxTimeToReachQueue(a.l)
  put_MaxTimeToReachQueue(a.l)
  get_MaxTimeToReceive(a.l)
  put_MaxTimeToReceive(a.l)
  get_HashAlgorithm(a.l)
  put_HashAlgorithm(a.l)
  get_EncryptAlgorithm(a.l)
  put_EncryptAlgorithm(a.l)
  get_SentTime(a.l)
  get_ArrivedTime(a.l)
  get_DestinationQueueInfo(a.l)
  get_SenderCertificate(a.l)
  put_SenderCertificate(a.p-variant)
  get_SenderId(a.l)
  get_SenderIdType(a.l)
  put_SenderIdType(a.l)
  Send(a.l, b.l)
  AttachCurrentSecurityContext()
EndInterface

; IMSMQQueueInfos interface definition
;
Interface IMSMQQueueInfos Extends IDispatch
  Reset()
  Next(a.l)
EndInterface

; IMSMQQueueInfos2 interface definition
;
Interface IMSMQQueueInfos2 Extends IDispatch
  Reset()
  Next(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQQueueInfos3 interface definition
;
Interface IMSMQQueueInfos3 Extends IDispatch
  Reset()
  Next(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQEvent interface definition
;
Interface IMSMQEvent Extends IDispatch
EndInterface

; IMSMQEvent2 interface definition
;
Interface IMSMQEvent2 Extends IMSMQEvent
  get_Properties(a.l)
EndInterface

; IMSMQEvent3 interface definition
;
Interface IMSMQEvent3 Extends IMSMQEvent2
EndInterface

; IMSMQTransaction interface definition
;
Interface IMSMQTransaction Extends IDispatch
  get_Transaction(a.l)
  Commit(a.l, b.l, c.l)
  Abort(a.l, b.l)
EndInterface

; IMSMQCoordinatedTransactionDispenser interface definition
;
Interface IMSMQCoordinatedTransactionDispenser Extends IDispatch
  BeginTransaction(a.l)
EndInterface

; IMSMQTransactionDispenser interface definition
;
Interface IMSMQTransactionDispenser Extends IDispatch
  BeginTransaction(a.l)
EndInterface

; IMSMQQuery2 interface definition
;
Interface IMSMQQuery2 Extends IDispatch
  LookupQueue(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
  get_Properties(a.l)
EndInterface

; IMSMQQuery3 interface definition
;
Interface IMSMQQuery3 Extends IDispatch
  LookupQueue_v2(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
  get_Properties(a.l)
  LookupQueue(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l, l.l)
EndInterface

; IMSMQMessage2 interface definition
;
Interface IMSMQMessage2 Extends IDispatch
  get_Class(a.l)
  get_PrivLevel(a.l)
  put_PrivLevel(a.l)
  get_AuthLevel(a.l)
  put_AuthLevel(a.l)
  get_IsAuthenticated(a.l)
  get_Delivery(a.l)
  put_Delivery(a.l)
  get_Trace(a.l)
  put_Trace(a.l)
  get_Priority(a.l)
  put_Priority(a.l)
  get_Journal(a.l)
  put_Journal(a.l)
  get_ResponseQueueInfo_v1(a.l)
  putref_ResponseQueueInfo_v1(a.l)
  get_AppSpecific(a.l)
  put_AppSpecific(a.l)
  get_SourceMachineGuid(a.l)
  get_BodyLength(a.l)
  get_Body(a.l)
  put_Body(a.p-variant)
  get_AdminQueueInfo_v1(a.l)
  putref_AdminQueueInfo_v1(a.l)
  get_Id(a.l)
  get_CorrelationId(a.l)
  put_CorrelationId(a.p-variant)
  get_Ack(a.l)
  put_Ack(a.l)
  get_Label(a.l)
  put_Label(a.p-bstr)
  get_MaxTimeToReachQueue(a.l)
  put_MaxTimeToReachQueue(a.l)
  get_MaxTimeToReceive(a.l)
  put_MaxTimeToReceive(a.l)
  get_HashAlgorithm(a.l)
  put_HashAlgorithm(a.l)
  get_EncryptAlgorithm(a.l)
  put_EncryptAlgorithm(a.l)
  get_SentTime(a.l)
  get_ArrivedTime(a.l)
  get_DestinationQueueInfo(a.l)
  get_SenderCertificate(a.l)
  put_SenderCertificate(a.p-variant)
  get_SenderId(a.l)
  get_SenderIdType(a.l)
  put_SenderIdType(a.l)
  Send(a.l, b.l)
  AttachCurrentSecurityContext()
  get_SenderVersion(a.l)
  get_Extension(a.l)
  put_Extension(a.p-variant)
  get_ConnectorTypeGuid(a.l)
  put_ConnectorTypeGuid(a.p-bstr)
  get_TransactionStatusQueueInfo(a.l)
  get_DestinationSymmetricKey(a.l)
  put_DestinationSymmetricKey(a.p-variant)
  get_Signature(a.l)
  put_Signature(a.p-variant)
  get_AuthenticationProviderType(a.l)
  put_AuthenticationProviderType(a.l)
  get_AuthenticationProviderName(a.l)
  put_AuthenticationProviderName(a.p-bstr)
  put_SenderId(a.p-variant)
  get_MsgClass(a.l)
  put_MsgClass(a.l)
  get_Properties(a.l)
  get_TransactionId(a.l)
  get_IsFirstInTransaction(a.l)
  get_IsLastInTransaction(a.l)
  get_ResponseQueueInfo(a.l)
  putref_ResponseQueueInfo(a.l)
  get_AdminQueueInfo(a.l)
  putref_AdminQueueInfo(a.l)
  get_ReceivedAuthenticationLevel(a.l)
EndInterface

; IMSMQMessage3 interface definition
;
Interface IMSMQMessage3 Extends IDispatch
  get_Class(a.l)
  get_PrivLevel(a.l)
  put_PrivLevel(a.l)
  get_AuthLevel(a.l)
  put_AuthLevel(a.l)
  get_IsAuthenticated(a.l)
  get_Delivery(a.l)
  put_Delivery(a.l)
  get_Trace(a.l)
  put_Trace(a.l)
  get_Priority(a.l)
  put_Priority(a.l)
  get_Journal(a.l)
  put_Journal(a.l)
  get_ResponseQueueInfo_v1(a.l)
  putref_ResponseQueueInfo_v1(a.l)
  get_AppSpecific(a.l)
  put_AppSpecific(a.l)
  get_SourceMachineGuid(a.l)
  get_BodyLength(a.l)
  get_Body(a.l)
  put_Body(a.p-variant)
  get_AdminQueueInfo_v1(a.l)
  putref_AdminQueueInfo_v1(a.l)
  get_Id(a.l)
  get_CorrelationId(a.l)
  put_CorrelationId(a.p-variant)
  get_Ack(a.l)
  put_Ack(a.l)
  get_Label(a.l)
  put_Label(a.p-bstr)
  get_MaxTimeToReachQueue(a.l)
  put_MaxTimeToReachQueue(a.l)
  get_MaxTimeToReceive(a.l)
  put_MaxTimeToReceive(a.l)
  get_HashAlgorithm(a.l)
  put_HashAlgorithm(a.l)
  get_EncryptAlgorithm(a.l)
  put_EncryptAlgorithm(a.l)
  get_SentTime(a.l)
  get_ArrivedTime(a.l)
  get_DestinationQueueInfo(a.l)
  get_SenderCertificate(a.l)
  put_SenderCertificate(a.p-variant)
  get_SenderId(a.l)
  get_SenderIdType(a.l)
  put_SenderIdType(a.l)
  Send(a.l, b.l)
  AttachCurrentSecurityContext()
  get_SenderVersion(a.l)
  get_Extension(a.l)
  put_Extension(a.p-variant)
  get_ConnectorTypeGuid(a.l)
  put_ConnectorTypeGuid(a.p-bstr)
  get_TransactionStatusQueueInfo(a.l)
  get_DestinationSymmetricKey(a.l)
  put_DestinationSymmetricKey(a.p-variant)
  get_Signature(a.l)
  put_Signature(a.p-variant)
  get_AuthenticationProviderType(a.l)
  put_AuthenticationProviderType(a.l)
  get_AuthenticationProviderName(a.l)
  put_AuthenticationProviderName(a.p-bstr)
  put_SenderId(a.p-variant)
  get_MsgClass(a.l)
  put_MsgClass(a.l)
  get_Properties(a.l)
  get_TransactionId(a.l)
  get_IsFirstInTransaction(a.l)
  get_IsLastInTransaction(a.l)
  get_ResponseQueueInfo_v2(a.l)
  putref_ResponseQueueInfo_v2(a.l)
  get_AdminQueueInfo_v2(a.l)
  putref_AdminQueueInfo_v2(a.l)
  get_ReceivedAuthenticationLevel(a.l)
  get_ResponseQueueInfo(a.l)
  putref_ResponseQueueInfo(a.l)
  get_AdminQueueInfo(a.l)
  putref_AdminQueueInfo(a.l)
  get_ResponseDestination(a.l)
  putref_ResponseDestination(a.l)
  get_Destination(a.l)
  get_LookupId(a.l)
  get_IsAuthenticated2(a.l)
  get_IsFirstInTransaction2(a.l)
  get_IsLastInTransaction2(a.l)
  AttachCurrentSecurityContext2()
  get_SoapEnvelope(a.l)
  get_CompoundMessage(a.l)
  put_SoapHeader(a.p-bstr)
  put_SoapBody(a.p-bstr)
EndInterface

; IMSMQQueue3 interface definition
;
Interface IMSMQQueue3 Extends IDispatch
  get_Access(a.l)
  get_ShareMode(a.l)
  get_QueueInfo(a.l)
  get_Handle(a.l)
  get_IsOpen(a.l)
  Close()
  Receive_v1(a.l, b.l, c.l, d.l, e.l)
  Peek_v1(a.l, b.l, c.l, d.l)
  EnableNotification(a.l, b.l, c.l)
  Reset()
  ReceiveCurrent_v1(a.l, b.l, c.l, d.l, e.l)
  PeekNext_v1(a.l, b.l, c.l, d.l)
  PeekCurrent_v1(a.l, b.l, c.l, d.l)
  Receive(a.l, b.l, c.l, d.l, e.l, f.l)
  Peek(a.l, b.l, c.l, d.l, e.l)
  ReceiveCurrent(a.l, b.l, c.l, d.l, e.l, f.l)
  PeekNext(a.l, b.l, c.l, d.l, e.l)
  PeekCurrent(a.l, b.l, c.l, d.l, e.l)
  get_Properties(a.l)
  get_Handle2(a.l)
  ReceiveByLookupId(a.p-variant, b.l, c.l, d.l, e.l, f.l)
  ReceiveNextByLookupId(a.p-variant, b.l, c.l, d.l, e.l, f.l)
  ReceivePreviousByLookupId(a.p-variant, b.l, c.l, d.l, e.l, f.l)
  ReceiveFirstByLookupId(a.l, b.l, c.l, d.l, e.l)
  ReceiveLastByLookupId(a.l, b.l, c.l, d.l, e.l)
  PeekByLookupId(a.p-variant, b.l, c.l, d.l, e.l)
  PeekNextByLookupId(a.p-variant, b.l, c.l, d.l, e.l)
  PeekPreviousByLookupId(a.p-variant, b.l, c.l, d.l, e.l)
  PeekFirstByLookupId(a.l, b.l, c.l, d.l)
  PeekLastByLookupId(a.l, b.l, c.l, d.l)
  Purge()
  get_IsOpen2(a.l)
EndInterface

; IMSMQPrivateEvent interface definition
;
Interface IMSMQPrivateEvent Extends IDispatch
  get_Hwnd(a.l)
  FireArrivedEvent(a.l, b.l)
  FireArrivedErrorEvent(a.l, b.l, c.l)
EndInterface

; _DMSMQEventEvents interface definition
;
Interface _DMSMQEventEvents Extends IDispatch
EndInterface

; IMSMQTransaction2 interface definition
;
Interface IMSMQTransaction2 Extends IMSMQTransaction
  InitNew(a.p-variant)
  get_Properties(a.l)
EndInterface

; IMSMQTransaction3 interface definition
;
Interface IMSMQTransaction3 Extends IMSMQTransaction2
  get_ITransaction(a.l)
EndInterface

; IMSMQCoordinatedTransactionDispenser2 interface definition
;
Interface IMSMQCoordinatedTransactionDispenser2 Extends IDispatch
  BeginTransaction(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQCoordinatedTransactionDispenser3 interface definition
;
Interface IMSMQCoordinatedTransactionDispenser3 Extends IDispatch
  BeginTransaction(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQTransactionDispenser2 interface definition
;
Interface IMSMQTransactionDispenser2 Extends IDispatch
  BeginTransaction(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQTransactionDispenser3 interface definition
;
Interface IMSMQTransactionDispenser3 Extends IDispatch
  BeginTransaction(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQApplication interface definition
;
Interface IMSMQApplication Extends IDispatch
  MachineIdOfMachineName(a.p-bstr, b.l)
EndInterface

; IMSMQApplication2 interface definition
;
Interface IMSMQApplication2 Extends IMSMQApplication
  RegisterCertificate(a.l, b.l)
  MachineNameOfMachineId(a.p-bstr, b.l)
  get_MSMQVersionMajor(a.l)
  get_MSMQVersionMinor(a.l)
  get_MSMQVersionBuild(a.l)
  get_IsDsEnabled(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQApplication3 interface definition
;
Interface IMSMQApplication3 Extends IMSMQApplication2
  get_ActiveQueues(a.l)
  get_PrivateQueues(a.l)
  get_DirectoryServiceServer(a.l)
  get_IsConnected(a.l)
  get_BytesInAllQueues(a.l)
  put_Machine(a.p-bstr)
  get_Machine(a.l)
  Connect()
  Disconnect()
  Tidy()
EndInterface

; IMSMQDestination interface definition
;
Interface IMSMQDestination Extends IDispatch
  Open()
  Close()
  get_IsOpen(a.l)
  get_IADs(a.l)
  putref_IADs(a.l)
  get_ADsPath(a.l)
  put_ADsPath(a.p-bstr)
  get_PathName(a.l)
  put_PathName(a.p-bstr)
  get_FormatName(a.l)
  put_FormatName(a.p-bstr)
  get_Destinations(a.l)
  putref_Destinations(a.l)
  get_Properties(a.l)
EndInterface

; IMSMQPrivateDestination interface definition
;
Interface IMSMQPrivateDestination Extends IDispatch
  get_Handle(a.l)
  put_Handle(a.p-variant)
EndInterface

; IMSMQCollection interface definition
;
Interface IMSMQCollection Extends IDispatch
  Item(a.l, b.l)
  get_Count(a.l)
  _NewEnum(a.l)
EndInterface

; IMSMQManagement interface definition
;
Interface IMSMQManagement Extends IDispatch
  Init(a.l, b.l, c.l)
  get_FormatName(a.l)
  get_Machine(a.l)
  get_MessageCount(a.l)
  get_ForeignStatus(a.l)
  get_QueueType(a.l)
  get_IsLocal(a.l)
  get_TransactionalStatus(a.l)
  get_BytesInQueue(a.l)
EndInterface

; IMSMQOutgoingQueueManagement interface definition
;
Interface IMSMQOutgoingQueueManagement Extends IMSMQManagement
  get_State(a.l)
  get_NextHops(a.l)
  EodGetSendInfo(a.l)
  Resume()
  Pause()
  EodResend()
EndInterface

; IMSMQQueueManagement interface definition
;
Interface IMSMQQueueManagement Extends IMSMQManagement
  get_JournalMessageCount(a.l)
  get_BytesInJournal(a.l)
  EodGetReceiveInfo(a.l)
EndInterface
