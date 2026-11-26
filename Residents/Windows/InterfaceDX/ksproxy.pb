
; IKsClockPropertySet interface definition
;
Interface IKsClockPropertySet Extends IUnknown
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
Interface IKsAllocator Extends IUnknown
  KsGetAllocatorHandle()
  KsGetAllocatorMode()
  KsGetAllocatorStatus(a.l)
  KsSetAllocatorMode(a.l)
EndInterface

; IKsAllocatorEx interface definition
;
Interface IKsAllocatorEx Extends IUnknown
  KsGetProperties()
  KsSetProperties(a.l)
  KsSetAllocatorHandle(a.l)
  KsCreateAllocatorAndGetHandle(a.l)
EndInterface

; IKsPin interface definition
;
Interface IKsPin Extends IUnknown
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
Interface IKsPinEx Extends IUnknown
  KsNotifyError(a.l, b.l)
EndInterface

; IKsPinPipe interface definition
;
Interface IKsPinPipe Extends IUnknown
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
Interface IKsPinFactory Extends IUnknown
  KsPinFactory(a.l)
EndInterface

; IKsDataTypeHandler interface definition
;
Interface IKsDataTypeHandler Extends IUnknown
  KsCompleteIoOperation(a.l, b.l, c.l, d.l)
  KsIsMediaTypeInRanges(a.l)
  KsPrepareIoOperation(a.l, b.l, c.l)
  KsQueryExtendedSize(a.l)
  KsSetMediaType(a.l)
EndInterface

; IKsDataTypeCompletion interface definition
;
Interface IKsDataTypeCompletion Extends IUnknown
  KsCompleteMediaType(a.l, b.l, c.l)
EndInterface

; IKsInterfaceHandler interface definition
;
Interface IKsInterfaceHandler Extends IUnknown
  KsSetPin(a.l)
  KsProcessMediaSamples(a.l, b.l, c.l, d.l, e.l)
  KsCompleteIo(a.l)
EndInterface

; IKsObject interface definition
;
Interface IKsObject Extends IUnknown
  KsGetObjectHandle()
EndInterface

; IKsQualityForwarder interface definition
;
Interface IKsQualityForwarder Extends IUnknown
  KsFlushClient(a.l)
EndInterface

; IKsNotifyEvent interface definition
;
Interface IKsNotifyEvent Extends IUnknown
  KsNotifyEvent(a.l, b.l, c.l)
EndInterface

; IKsPropertySet interface definition - Already defined in dsound.pb
;


; IKsControl interface definition - Already defined in dmksctrl.pb
;


; IKsAggregateControl interface definition
;
Interface IKsAggregateControl Extends IUnknown
  KsAddAggregate(a.l)
  KsRemoveAggregate(a.l)
EndInterface

; IKsTopology interface definition
;
Interface IKsTopology Extends IUnknown
  CreateNodeInstance(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface
