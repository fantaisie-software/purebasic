
; IDirectShowStream interface definition
;
Interface IDirectShowStream Extends IDispatch
  get_FileName(a.l)
  put_FileName(a.p-bstr)
  get_Video(a.l)
  put_Video(a.l)
  get_Audio(a.l)
  put_Audio(a.l)
EndInterface

; IAMMultiMediaStream interface definition
;
Interface IAMMultiMediaStream Extends IMultiMediaStream
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
Interface IAMMediaStream Extends IMediaStream
  Initialize(a.l, b.l, c.l, d.l)
  SetState(a.l)
  JoinAMMultiMediaStream(a.l)
  JoinFilter(a.l)
  JoinFilterGraph(a.l)
EndInterface

; IMediaStreamFilter interface definition
;
Interface IMediaStreamFilter Extends IBaseFilter
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
Interface IDirectDrawMediaSampleAllocator Extends IUnknown
  GetDirectDraw(a.l)
EndInterface

; IDirectDrawMediaSample interface definition
;
Interface IDirectDrawMediaSample Extends IUnknown
  GetSurfaceAndReleaseLock(a.l, b.l)
  LockMediaSamplePointer()
EndInterface

; IAMMediaTypeStream interface definition
;
Interface IAMMediaTypeStream Extends IMediaStream
  GetFormat(a.l, b.l)
  SetFormat(a.l, b.l)
  CreateSample(a.l, b.l, c.l, d.l, e.l)
  GetStreamAllocatorRequirements(a.l)
  SetStreamAllocatorRequirements(a.l)
EndInterface

; IAMMediaTypeSample interface definition
;
Interface IAMMediaTypeSample Extends IStreamSample
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
