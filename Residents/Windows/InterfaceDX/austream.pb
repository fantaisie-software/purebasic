
; IAudioMediaStream interface definition
;
Interface IAudioMediaStream Extends IMediaStream
  GetFormat(a.l)
  SetFormat(a.l)
  CreateSample(a.l, b.l, c.l)
EndInterface

; IAudioStreamSample interface definition
;
Interface IAudioStreamSample Extends IStreamSample
  GetAudioData(a.l)
EndInterface

; IMemoryData interface definition
;
Interface IMemoryData Extends IUnknown
  SetBuffer(a.l, b.l, c.l)
  GetInfo(a.l, b.l, c.l)
  SetActual(a.l)
EndInterface

; IAudioData interface definition
;
Interface IAudioData Extends IMemoryData
  GetFormat(a.l)
  SetFormat(a.l)
EndInterface
