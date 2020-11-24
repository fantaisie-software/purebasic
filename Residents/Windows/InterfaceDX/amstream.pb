
; IDirectShowStream interface definition
;
Interface IDirectShowStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_FileName(a.l)
  put_FileName(a.p-bstr)
  get_Video(a.l)
  put_Video(a.l)
  get_Audio(a.l)
  put_Audio(a.l)
EndInterface

; IAMMultiMediaStream interface definition
;
Interface IAMMultiMediaStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetInformation(a.l, b.l)
  GetMediaStream(a.l, b.l)
  EnumMediaStreams(a.l, b.l)
  GetState(a.l)
  SetState(a.l)
  GetTime(a.l)
  GetDuration(a.l)
  Seek(a.q)
  GetEndOfStreamEventHandle(a.l)
  Initialize(a.l, b.l, c.l)
  GetFilterGraph(a.l)
  GetFilter(a.l)
  AddMediaStream(a.l, b.l, c.l, d.l)
  OpenFile(a.l, b.l)
  OpenMoniker(a.l, b.l, c.l)
  Render(a.l)
EndInterface

; IAMMediaStream interface definition
;
Interface IAMMediaStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMultiMediaStream(a.l)
  GetInformation(a.l, b.l)
  SetSameFormat(a.l, b.l)
  AllocateSample(a.l, b.l)
  CreateSharedSample(a.l, b.l, c.l)
  SendEndOfStream(a.l)
  Initialize(a.l, b.l, c.l, d.l)
  SetState(a.l)
  JoinAMMultiMediaStream(a.l)
  JoinFilter(a.l)
  JoinFilterGraph(a.l)
EndInterface

; IMediaStreamFilter interface definition
;
Interface IMediaStreamFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  Stop()
  Pause()
  Run(a.q)
  GetState(a.l, b.l)
  SetSyncSource(a.l)
  GetSyncSource(a.l)
  EnumPins(a.l)
  FindPin(a.l, b.l)
  QueryFilterInfo(a.l)
  JoinFilterGraph(a.l, b.l)
  QueryVendorInfo(a.l)
  AddMediaStream(a.l)
  GetMediaStream(a.l, b.l)
  EnumMediaStreams(a.l, b.l)
  SupportSeeking(a.l)
  ReferenceTimeToStreamTime(a.l)
  GetCurrentStreamTime(a.l)
  WaitUntil(a.q)
  Flush(a.l)
  EndOfStream()
EndInterface

; IDirectDrawMediaSampleAllocator interface definition
;
Interface IDirectDrawMediaSampleAllocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDirectDraw(a.l)
EndInterface

; IDirectDrawMediaSample interface definition
;
Interface IDirectDrawMediaSample
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSurfaceAndReleaseLock(a.l, b.l)
  LockMediaSamplePointer()
EndInterface

; IAMMediaTypeStream interface definition
;
Interface IAMMediaTypeStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMultiMediaStream(a.l)
  GetInformation(a.l, b.l)
  SetSameFormat(a.l, b.l)
  AllocateSample(a.l, b.l)
  CreateSharedSample(a.l, b.l, c.l)
  SendEndOfStream(a.l)
  GetFormat(a.l, b.l)
  SetFormat(a.l, b.l)
  CreateSample(a.l, b.l, c.l, d.l, e.l)
  GetStreamAllocatorRequirements(a.l)
  SetStreamAllocatorRequirements(a.l)
EndInterface

; IAMMediaTypeSample interface definition
;
Interface IAMMediaTypeSample
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMediaStream(a.l)
  GetSampleTimes(a.l, b.l, c.l)
  SetSampleTimes(a.l, b.l)
  Update(a.l, b.l, c.l, d.l)
  CompletionStatus(a.l, b.l)
  SetPointer(a.l, b.l)
  GetPointer(a.l)
  GetSize()
  GetTime(a.l, b.l)
  SetTime(a.l, b.l)
  IsSyncPoint()
  SetSyncPoint(a.l)
  IsPreroll()
  SetPreroll(a.l)
  GetActualDataLength()
  SetActualDataLength(a.l)
  GetMediaType(a.l)
  SetMediaType(a.l)
  IsDiscontinuity()
  SetDiscontinuity(a.l)
  GetMediaTime(a.l, b.l)
  SetMediaTime(a.l, b.l)
EndInterface
