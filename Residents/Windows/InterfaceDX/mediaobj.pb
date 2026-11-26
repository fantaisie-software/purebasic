
; IMediaBuffer interface definition
;
Interface IMediaBuffer Extends IUnknown
  SetLength(a.l)
  GetMaxLength(a.l)
  GetBufferAndLength(a.l, b.l)
EndInterface

; IMediaObject interface definition
;
Interface IMediaObject Extends IUnknown
  GetStreamCount(a.l, b.l)
  GetInputStreamInfo(a.l, b.l)
  GetOutputStreamInfo(a.l, b.l)
  GetInputType(a.l, b.l, c.l)
  GetOutputType(a.l, b.l, c.l)
  SetInputType(a.l, b.l, c.l)
  SetOutputType(a.l, b.l, c.l)
  GetInputCurrentType(a.l, b.l)
  GetOutputCurrentType(a.l, b.l)
  GetInputSizeInfo(a.l, b.l, c.l, d.l)
  GetOutputSizeInfo(a.l, b.l, c.l)
  GetInputMaxLatency(a.l, b.l)
  SetInputMaxLatency(a.l, b.q)
  Flush()
  Discontinuity(a.l)
  AllocateStreamingResources()
  FreeStreamingResources()
  GetInputStatus(a.l, b.l)
  ProcessInput(a.l, b.l, c.l, d.q, e.q)
  ProcessOutput(a.l, b.l, c.l, d.l)
  Lock(a.l)
EndInterface

; IEnumDMO interface definition
;
Interface IEnumDMO Extends IUnknown
  Next(a.l, b.l, c.l, d.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IMediaObjectInPlace interface definition
;
Interface IMediaObjectInPlace Extends IUnknown
  Process(a.l, b.l, c.q, d.l)
  Clone(a.l)
  GetLatency(a.l)
EndInterface

; IDMOQualityControl interface definition
;
Interface IDMOQualityControl Extends IUnknown
  SetNow(a.q)
  SetStatus(a.l)
  GetStatus(a.l)
EndInterface

; IDMOVideoOutputOptimizations interface definition
;
Interface IDMOVideoOutputOptimizations Extends IUnknown
  QueryOperationModePreferences(a.l, b.l)
  SetOperationMode(a.l, b.l)
  GetCurrentOperationMode(a.l, b.l)
  GetCurrentSampleRequirements(a.l, b.l)
EndInterface
