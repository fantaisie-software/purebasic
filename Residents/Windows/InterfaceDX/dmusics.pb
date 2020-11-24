
; IDirectMusicSynth interface definition
;
Interface IDirectMusicSynth
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Open(a.l)
  Close()
  SetNumChannelGroups(a.l)
  Download(a.l, b.l, c.l)
  Unload(a.l, b.l, c.l, d.l)
  PlayBuffer(a.q, b.l, c.l)
  GetRunningStats(a.l)
  GetPortCaps(a.l)
  SetMasterClock(a.l)
  GetLatencyClock(a.l)
  Activate(a.l)
  SetSynthSink(a.l)
  Render(a.l, b.l, c.q)
  SetChannelPriority(a.l, b.l, c.l)
  GetChannelPriority(a.l, b.l, c.l)
  GetFormat(a.l, b.l)
  GetAppend(a.l)
EndInterface

; IDirectMusicSynth8 interface definition
;
Interface IDirectMusicSynth8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Open(a.l)
  Close()
  SetNumChannelGroups(a.l)
  Download(a.l, b.l, c.l)
  Unload(a.l, b.l, c.l, d.l)
  PlayBuffer(a.q, b.l, c.l)
  GetRunningStats(a.l)
  GetPortCaps(a.l)
  SetMasterClock(a.l)
  GetLatencyClock(a.l)
  Activate(a.l)
  SetSynthSink(a.l)
  Render(a.l, b.l, c.q)
  SetChannelPriority(a.l, b.l, c.l)
  GetChannelPriority(a.l, b.l, c.l)
  GetFormat(a.l, b.l)
  GetAppend(a.l)
  PlayVoice(a.q, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
  StopVoice(a.q, b.l)
  GetVoiceState(a.l, b.l, c.l)
  Refresh(a.l, b.l)
  AssignChannelToBuses(a.l, b.l, c.l, d.l)
EndInterface

; IDirectMusicSynthSink interface definition
;
Interface IDirectMusicSynthSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l)
  SetMasterClock(a.l)
  GetLatencyClock(a.l)
  Activate(a.l)
  SampleToRefTime(a.q, b.l)
  RefTimeToSample(a.q, b.l)
  SetDirectSound(a.l, b.l)
  GetDesiredBufferSize(a.l)
EndInterface
