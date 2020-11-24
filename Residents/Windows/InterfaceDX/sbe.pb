
; IStreamBufferInitialize interface definition
;
Interface IStreamBufferInitialize
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetHKEY(a.l)
  SetSIDs(a.l, b.l)
EndInterface

; IStreamBufferSink interface definition
;
Interface IStreamBufferSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  LockProfile(a.l)
  CreateRecorder(a.l, b.l, c.l)
  IsProfileLocked()
EndInterface

; IStreamBufferSource interface definition
;
Interface IStreamBufferSource
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetStreamSink(a.l)
EndInterface

; IStreamBufferRecordControl interface definition
;
Interface IStreamBufferRecordControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Start(a.l)
  Stop(a.q)
  GetRecordingStatus(a.l, b.l, c.l)
EndInterface

; IStreamBufferRecComp interface definition
;
Interface IStreamBufferRecComp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l)
  Append(a.l)
  AppendEx(a.l, b.q, c.q)
  GetCurrentLength(a.l)
  Close()
  Cancel()
EndInterface

; IStreamBufferRecordingAttribute interface definition
;
Interface IStreamBufferRecordingAttribute
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAttribute(a.l, b.l, c.l, d.l, e.l)
  GetAttributeCount(a.l, b.l)
  GetAttributeByName(a.l, b.l, c.l, d.l, e.l)
  GetAttributeByIndex(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  EnumAttributes(a.l)
EndInterface

; IEnumStreamBufferRecordingAttrib interface definition
;
Interface IEnumStreamBufferRecordingAttrib
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IStreamBufferConfigure interface definition
;
Interface IStreamBufferConfigure
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetDirectory(a.l)
  GetDirectory(a.l)
  SetBackingFileCount(a.l, b.l)
  GetBackingFileCount(a.l, b.l)
  SetBackingFileDuration(a.l)
  GetBackingFileDuration(a.l)
EndInterface

; IStreamBufferMediaSeeking interface definition
;
Interface IStreamBufferMediaSeeking
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCapabilities(a.l)
  CheckCapabilities(a.l)
  IsFormatSupported(a.l)
  QueryPreferredFormat(a.l)
  GetTimeFormat(a.l)
  IsUsingTimeFormat(a.l)
  SetTimeFormat(a.l)
  GetDuration(a.l)
  GetStopPosition(a.l)
  GetCurrentPosition(a.l)
  ConvertTimeFormat(a.l, b.l, c.q, d.l)
  SetPositions(a.l, b.l, c.l, d.l)
  GetPositions(a.l, b.l)
  GetAvailable(a.l, b.l)
  SetRate(a.d)
  GetRate(a.l)
  GetPreroll(a.l)
EndInterface
