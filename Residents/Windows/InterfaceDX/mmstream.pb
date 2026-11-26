
; IMultiMediaStream interface definition
;
Interface IMultiMediaStream Extends IUnknown
  GetInformation(a.l, b.l)
  GetMediaStream(a.l, b.l)
  EnumMediaStreams(a.l, b.l)
  GetState(a.l)
  SetState(a.l)
  GetTime(a.l)
  GetDuration(a.l)
  Seek(a.q)
  GetEndOfStreamEventHandle(a.l)
EndInterface

; IMediaStream interface definition
;
Interface IMediaStream Extends IUnknown
  GetMultiMediaStream(a.l)
  GetInformation(a.l, b.l)
  SetSameFormat(a.l, b.l)
  AllocateSample(a.l, b.l)
  CreateSharedSample(a.l, b.l, c.l)
  SendEndOfStream(a.l)
EndInterface

; IStreamSample interface definition
;
Interface IStreamSample Extends IUnknown
  GetMediaStream(a.l)
  GetSampleTimes(a.l, b.l, c.l)
  SetSampleTimes(a.l, b.l)
  Update(a.l, b.l, c.l, d.l)
  CompletionStatus(a.l, b.l)
EndInterface
