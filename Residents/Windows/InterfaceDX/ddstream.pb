
; IDirectDrawMediaStream interface definition
;
Interface IDirectDrawMediaStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMultiMediaStream(a.l)
  GetInformation(a.l, b.l)
  SetSameFormat(a.l, b.l)
  AllocateSample(a.l, b.l)
  CreateSharedSample(a.l, b.l, c.l)
  SendEndOfStream(a.l)
  GetFormat(a.l, b.l, c.l, d.l)
  SetFormat(a.l, b.l)
  GetDirectDraw(a.l)
  SetDirectDraw(a.l)
  CreateSample(a.l, b.l, c.l, d.l)
  GetTimePerFrame(a.l)
EndInterface

; IDirectDrawStreamSample interface definition
;
Interface IDirectDrawStreamSample
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMediaStream(a.l)
  GetSampleTimes(a.l, b.l, c.l)
  SetSampleTimes(a.l, b.l)
  Update(a.l, b.l, c.l, d.l)
  CompletionStatus(a.l, b.l)
  GetSurface(a.l, b.l)
  SetRect(a.l)
EndInterface
