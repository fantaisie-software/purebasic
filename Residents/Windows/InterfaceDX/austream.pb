
; IAudioMediaStream interface definition
;
Interface IAudioMediaStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMultiMediaStream(a.l)
  GetInformation(a.l, b.l)
  SetSameFormat(a.l, b.l)
  AllocateSample(a.l, b.l)
  CreateSharedSample(a.l, b.l, c.l)
  SendEndOfStream(a.l)
  GetFormat(a.l)
  SetFormat(a.l)
  CreateSample(a.l, b.l, c.l)
EndInterface

; IAudioStreamSample interface definition
;
Interface IAudioStreamSample
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMediaStream(a.l)
  GetSampleTimes(a.l, b.l, c.l)
  SetSampleTimes(a.l, b.l)
  Update(a.l, b.l, c.l, d.l)
  CompletionStatus(a.l, b.l)
  GetAudioData(a.l)
EndInterface

; IMemoryData interface definition
;
Interface IMemoryData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetBuffer(a.l, b.l, c.l)
  GetInfo(a.l, b.l, c.l)
  SetActual(a.l)
EndInterface

; IAudioData interface definition
;
Interface IAudioData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetBuffer(a.l, b.l, c.l)
  GetInfo(a.l, b.l, c.l)
  SetActual(a.l)
  GetFormat(a.l)
  SetFormat(a.l)
EndInterface
