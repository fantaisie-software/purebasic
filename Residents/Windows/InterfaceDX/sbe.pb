
; IStreamBufferInitialize interface definition
;
Interface IStreamBufferInitialize Extends IUnknown
  SetHKEY(a.l)
  SetSIDs(a.l, b.l)
EndInterface

; IStreamBufferSink interface definition
;
Interface IStreamBufferSink Extends IUnknown
  LockProfile(a.l)
  CreateRecorder(a.l, b.l, c.l)
  IsProfileLocked()
EndInterface

; IStreamBufferSource interface definition
;
Interface IStreamBufferSource Extends IUnknown
  SetStreamSink(a.l)
EndInterface

; IStreamBufferRecordControl interface definition
;
Interface IStreamBufferRecordControl Extends IUnknown
  Start(a.l)
  Stop(a.q)
  GetRecordingStatus(a.l, b.l, c.l)
EndInterface

; IStreamBufferRecComp interface definition
;
Interface IStreamBufferRecComp Extends IUnknown
  Initialize(a.l, b.l)
  Append(a.l)
  AppendEx(a.l, b.q, c.q)
  GetCurrentLength(a.l)
  Close()
  Cancel()
EndInterface

; IStreamBufferRecordingAttribute interface definition
;
Interface IStreamBufferRecordingAttribute Extends IUnknown
  SetAttribute(a.l, b.l, c.l, d.l, e.l)
  GetAttributeCount(a.l, b.l)
  GetAttributeByName(a.l, b.l, c.l, d.l, e.l)
  GetAttributeByIndex(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  EnumAttributes(a.l)
EndInterface

; IEnumStreamBufferRecordingAttrib interface definition
;
Interface IEnumStreamBufferRecordingAttrib Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IStreamBufferConfigure interface definition
;
Interface IStreamBufferConfigure Extends IUnknown
  SetDirectory(a.l)
  GetDirectory(a.l)
  SetBackingFileCount(a.l, b.l)
  GetBackingFileCount(a.l, b.l)
  SetBackingFileDuration(a.l)
  GetBackingFileDuration(a.l)
EndInterface

; IStreamBufferMediaSeeking interface definition
;
Interface IStreamBufferMediaSeeking Extends IMediaSeeking
EndInterface
