
; IDirectMusic interface definition
;
Interface IDirectMusic
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumPort(a.l, b.l)
  CreateMusicBuffer(a.l, b.l, c.l)
  CreatePort(a.l, b.l, c.l, d.l)
  EnumMasterClock(a.l, b.l)
  GetMasterClock(a.l, b.l)
  SetMasterClock(a.l)
  Activate(a.l)
  GetDefaultPort(a.l)
  SetDirectSound(a.l, b.l)
EndInterface

; IDirectMusic8 interface definition
;
Interface IDirectMusic8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumPort(a.l, b.l)
  CreateMusicBuffer(a.l, b.l, c.l)
  CreatePort(a.l, b.l, c.l, d.l)
  EnumMasterClock(a.l, b.l)
  GetMasterClock(a.l, b.l)
  SetMasterClock(a.l)
  Activate(a.l)
  GetDefaultPort(a.l)
  SetDirectSound(a.l, b.l)
  SetExternalMasterClock(a.l)
EndInterface

; IDirectMusicBuffer interface definition
;
Interface IDirectMusicBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Flush()
  TotalTime(a.l)
  PackStructured(a.q, b.l, c.l)
  PackUnstructured(a.q, b.l, c.l, d.l)
  ResetReadPtr()
  GetNextEvent(a.l, b.l, c.l, d.l)
  GetRawBufferPtr(a.l)
  GetStartTime(a.l)
  GetUsedBytes(a.l)
  GetMaxBytes(a.l)
  GetBufferFormat(a.l)
  SetStartTime(a.q)
  SetUsedBytes(a.l)
EndInterface

; IDirectMusicInstrument interface definition
;
Interface IDirectMusicInstrument
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPatch(a.l)
  SetPatch(a.l)
EndInterface

; IDirectMusicDownloadedInstrument interface definition
;
Interface IDirectMusicDownloadedInstrument
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
EndInterface

; IDirectMusicCollection interface definition
;
Interface IDirectMusicCollection
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetInstrument(a.l, b.l)
  EnumInstrument(a.l, b.l, c.l, d.l)
EndInterface

; IDirectMusicDownload interface definition
;
Interface IDirectMusicDownload
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBuffer(a.l, b.l)
EndInterface

; IDirectMusicPortDownload interface definition
;
Interface IDirectMusicPortDownload
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBuffer(a.l, b.l)
  AllocateBuffer(a.l, b.l)
  GetDLId(a.l, b.l)
  GetAppend(a.l)
  Download(a.l)
  Unload(a.l)
EndInterface

; IDirectMusicPort interface definition
;
Interface IDirectMusicPort
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  PlayBuffer(a.l)
  SetReadNotificationHandle(a.l)
  Read(a.l)
  DownloadInstrument(a.l, b.l, c.l, d.l)
  UnloadInstrument(a.l)
  GetLatencyClock(a.l)
  GetRunningStats(a.l)
  Compact()
  GetCaps(a.l)
  DeviceIoControl(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SetNumChannelGroups(a.l)
  GetNumChannelGroups(a.l)
  Activate(a.l)
  SetChannelPriority(a.l, b.l, c.l)
  GetChannelPriority(a.l, b.l, c.l)
  SetDirectSound(a.l, b.l)
  GetFormat(a.l, b.l, c.l)
EndInterface

; IDirectMusicThru interface definition
;
Interface IDirectMusicThru
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ThruChannel(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IReferenceClock interface definition
;
Interface IReferenceClock
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTime(a.l)
  AdviseTime(a.q, b.q, c.l, d.l)
  AdvisePeriodic(a.q, b.q, c.l, d.l)
  Unadvise(a.l)
EndInterface
