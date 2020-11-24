
; IKsClockPropertySet interface definition
;
Interface IKsClockPropertySet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsGetTime(a.l)
  KsSetTime(a.q)
  KsGetPhysicalTime(a.l)
  KsSetPhysicalTime(a.q)
  KsGetCorrelatedTime(a.l)
  KsSetCorrelatedTime(a.l)
  KsGetCorrelatedPhysicalTime(a.l)
  KsSetCorrelatedPhysicalTime(a.l)
  KsGetResolution(a.l)
  KsGetState(a.l)
EndInterface

; IKsAllocator interface definition
;
Interface IKsAllocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsGetAllocatorHandle()
  KsGetAllocatorMode()
  KsGetAllocatorStatus(a.l)
  KsSetAllocatorMode(a.l)
EndInterface

; IKsAllocatorEx interface definition
;
Interface IKsAllocatorEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsGetProperties()
  KsSetProperties(a.l)
  KsSetAllocatorHandle(a.l)
  KsCreateAllocatorAndGetHandle(a.l)
EndInterface

; IKsPin interface definition
;
Interface IKsPin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsQueryMediums(a.l)
  KsQueryInterfaces(a.l)
  KsCreateSinkPinHandle(a.l, b.l)
  KsGetCurrentCommunication(a.l, b.l, c.l)
  KsPropagateAcquire()
  KsDeliver(a.l, b.l)
  KsMediaSamplesCompleted(a.l)
  KsPeekAllocator(a.l)
  KsReceiveAllocator(a.l)
  KsRenegotiateAllocator()
  KsIncrementPendingIoCount()
  KsDecrementPendingIoCount()
  KsQualityNotify(a.l, b.q)
EndInterface

; IKsPinEx interface definition
;
Interface IKsPinEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsNotifyError(a.l, b.l)
EndInterface

; IKsPinPipe interface definition
;
Interface IKsPinPipe
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsGetPinFramingCache(a.l, b.l, c.l)
  KsSetPinFramingCache(a.l, b.l, c.l)
  KsGetConnectedPin()
  KsGetPipe(a.l)
  KsSetPipe(a.l)
  KsGetPipeAllocatorFlag()
  KsSetPipeAllocatorFlag(a.l)
  KsGetPinBusCache()
  KsSetPinBusCache(a.l)
  KsGetPinName()
  KsGetFilterName()
EndInterface

; IKsPinFactory interface definition
;
Interface IKsPinFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsPinFactory(a.l)
EndInterface

; IKsDataTypeHandler interface definition
;
Interface IKsDataTypeHandler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsCompleteIoOperation(a.l, b.l, c.l, d.l)
  KsIsMediaTypeInRanges(a.l)
  KsPrepareIoOperation(a.l, b.l, c.l)
  KsQueryExtendedSize(a.l)
  KsSetMediaType(a.l)
EndInterface

; IKsDataTypeCompletion interface definition
;
Interface IKsDataTypeCompletion
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsCompleteMediaType(a.l, b.l, c.l)
EndInterface

; IKsInterfaceHandler interface definition
;
Interface IKsInterfaceHandler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsSetPin(a.l)
  KsProcessMediaSamples(a.l, b.l, c.l, d.l, e.l)
  KsCompleteIo(a.l)
EndInterface

; IKsObject interface definition
;
Interface IKsObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsGetObjectHandle()
EndInterface

; IKsQualityForwarder interface definition
;
Interface IKsQualityForwarder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsFlushClient(a.l)
EndInterface

; IKsNotifyEvent interface definition
;
Interface IKsNotifyEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsNotifyEvent(a.l, b.l, c.l)
EndInterface

; IKsPropertySet interface definition - Already defined in dsound.pb
;


; IKsControl interface definition - Already defined in dmksctrl.pb
;


; IKsAggregateControl interface definition
;
Interface IKsAggregateControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KsAddAggregate(a.l)
  KsRemoveAggregate(a.l)
EndInterface

; IKsTopology interface definition
;
Interface IKsTopology
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateNodeInstance(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface
