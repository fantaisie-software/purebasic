
; IDirectMusicBand interface definition
;
Interface IDirectMusicBand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateSegment(a.l)
  Download(a.l)
  Unload(a.l)
EndInterface

; IDirectMusicObject interface definition
;
Interface IDirectMusicObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDescriptor(a.l)
  SetDescriptor(a.l)
  ParseDescriptor(a.l, b.l)
EndInterface

; IDirectMusicLoader interface definition
;
Interface IDirectMusicLoader
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetObject(a.l, b.l, c.l)
  SetObject(a.l)
  SetSearchDirectory(a.l, b.l, c.l)
  ScanDirectory(a.l, b.l, c.l)
  CacheObject(a.l)
  ReleaseObject(a.l)
  ClearCache(a.l)
  EnableCache(a.l, b.l)
  EnumObject(a.l, b.l, c.l)
EndInterface

; IDirectMusicLoader8 interface definition
;
Interface IDirectMusicLoader8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetObject(a.l, b.l, c.l)
  SetObject(a.l)
  SetSearchDirectory(a.l, b.l, c.l)
  ScanDirectory(a.l, b.l, c.l)
  CacheObject(a.l)
  ReleaseObject(a.l)
  ClearCache(a.l)
  EnableCache(a.l, b.l)
  EnumObject(a.l, b.l, c.l)
  CollectGarbage()
  ReleaseObjectByUnknown(a.l)
  LoadObjectFromFile(a.l, b.l, c.l, d.l)
EndInterface

; IDirectMusicGetLoader interface definition
;
Interface IDirectMusicGetLoader
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLoader(a.l)
EndInterface

; IDirectMusicSegment interface definition
;
Interface IDirectMusicSegment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLength(a.l)
  SetLength(a.l)
  GetRepeats(a.l)
  SetRepeats(a.l)
  GetDefaultResolution(a.l)
  SetDefaultResolution(a.l)
  GetTrack(a.l, b.l, c.l, d.l)
  GetTrackGroup(a.l, b.l)
  InsertTrack(a.l, b.l)
  RemoveTrack(a.l)
  InitPlay(a.l, b.l, c.l)
  GetGraph(a.l)
  SetGraph(a.l)
  AddNotificationType(a.l)
  RemoveNotificationType(a.l)
  GetParam(a.l, b.l, c.l, d.l, e.l, f.l)
  SetParam(a.l, b.l, c.l, d.l, e.l)
  Clone(a.l, b.l, c.l)
  SetStartPoint(a.l)
  GetStartPoint(a.l)
  SetLoopPoints(a.l, b.l)
  GetLoopPoints(a.l, b.l)
  SetPChannelsUsed(a.l, b.l)
EndInterface

; IDirectMusicSegment8 interface definition
;
Interface IDirectMusicSegment8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLength(a.l)
  SetLength(a.l)
  GetRepeats(a.l)
  SetRepeats(a.l)
  GetDefaultResolution(a.l)
  SetDefaultResolution(a.l)
  GetTrack(a.l, b.l, c.l, d.l)
  GetTrackGroup(a.l, b.l)
  InsertTrack(a.l, b.l)
  RemoveTrack(a.l)
  InitPlay(a.l, b.l, c.l)
  GetGraph(a.l)
  SetGraph(a.l)
  AddNotificationType(a.l)
  RemoveNotificationType(a.l)
  GetParam(a.l, b.l, c.l, d.l, e.l, f.l)
  SetParam(a.l, b.l, c.l, d.l, e.l)
  Clone(a.l, b.l, c.l)
  SetStartPoint(a.l)
  GetStartPoint(a.l)
  SetLoopPoints(a.l, b.l)
  GetLoopPoints(a.l, b.l)
  SetPChannelsUsed(a.l, b.l)
  SetTrackConfig(a.l, b.l, c.l, d.l, e.l)
  GetAudioPathConfig(a.l)
  Compose(a.l, b.l, c.l, d.l)
  Download(a.l)
  Unload(a.l)
EndInterface

; IDirectMusicSegmentState interface definition
;
Interface IDirectMusicSegmentState
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetRepeats(a.l)
  GetSegment(a.l)
  GetStartTime(a.l)
  GetSeek(a.l)
  GetStartPoint(a.l)
EndInterface

; IDirectMusicSegmentState8 interface definition
;
Interface IDirectMusicSegmentState8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetRepeats(a.l)
  GetSegment(a.l)
  GetStartTime(a.l)
  GetSeek(a.l)
  GetStartPoint(a.l)
  SetTrackConfig(a.l, b.l, c.l, d.l, e.l)
  GetObjectInPath(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IDirectMusicAudioPath interface definition
;
Interface IDirectMusicAudioPath
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetObjectInPath(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Activate(a.l)
  SetVolume(a.l, b.l)
  ConvertPChannel(a.l, b.l)
EndInterface

; IDirectMusicPerformance interface definition
;
Interface IDirectMusicPerformance
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l, c.l)
  PlaySegment(a.l, b.l, c.l, d.l)
  Stop(a.l, b.l, c.l, d.l)
  GetSegmentState(a.l, b.l)
  SetPrepareTime(a.l)
  GetPrepareTime(a.l)
  SetBumperLength(a.l)
  GetBumperLength(a.l)
  SendPMsg(a.l)
  MusicToReferenceTime(a.l, b.l)
  ReferenceToMusicTime(a.q, b.l)
  IsPlaying(a.l, b.l)
  GetTime(a.l, b.l)
  AllocPMsg(a.l, b.l)
  FreePMsg(a.l)
  GetGraph(a.l)
  SetGraph(a.l)
  SetNotificationHandle(a.l, b.q)
  GetNotificationPMsg(a.l)
  AddNotificationType(a.l)
  RemoveNotificationType(a.l)
  AddPort(a.l)
  RemovePort(a.l)
  AssignPChannelBlock(a.l, b.l, c.l)
  AssignPChannel(a.l, b.l, c.l, d.l)
  PChannelInfo(a.l, b.l, c.l, d.l)
  DownloadInstrument(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Invalidate(a.l, b.l)
  GetParam(a.l, b.l, c.l, d.l, e.l, f.l)
  SetParam(a.l, b.l, c.l, d.l, e.l)
  GetGlobalParam(a.l, b.l, c.l)
  SetGlobalParam(a.l, b.l, c.l)
  GetLatencyTime(a.l)
  GetQueueTime(a.l)
  AdjustTime(a.q)
  CloseDown()
  GetResolvedTime(a.q, b.l, c.l)
  MIDIToMusic(a.l, b.l, c.l, d.l, e.l)
  MusicToMIDI(a.l, b.l, c.l, d.l, e.l)
  TimeToRhythm(a.l, b.l, c.l, d.l, e.l, f.l)
  RhythmToTime(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IDirectMusicPerformance8 interface definition
;
Interface IDirectMusicPerformance8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l, c.l)
  PlaySegment(a.l, b.l, c.l, d.l)
  Stop(a.l, b.l, c.l, d.l)
  GetSegmentState(a.l, b.l)
  SetPrepareTime(a.l)
  GetPrepareTime(a.l)
  SetBumperLength(a.l)
  GetBumperLength(a.l)
  SendPMsg(a.l)
  MusicToReferenceTime(a.l, b.l)
  ReferenceToMusicTime(a.q, b.l)
  IsPlaying(a.l, b.l)
  GetTime(a.l, b.l)
  AllocPMsg(a.l, b.l)
  FreePMsg(a.l)
  GetGraph(a.l)
  SetGraph(a.l)
  SetNotificationHandle(a.l, b.q)
  GetNotificationPMsg(a.l)
  AddNotificationType(a.l)
  RemoveNotificationType(a.l)
  AddPort(a.l)
  RemovePort(a.l)
  AssignPChannelBlock(a.l, b.l, c.l)
  AssignPChannel(a.l, b.l, c.l, d.l)
  PChannelInfo(a.l, b.l, c.l, d.l)
  DownloadInstrument(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Invalidate(a.l, b.l)
  GetParam(a.l, b.l, c.l, d.l, e.l, f.l)
  SetParam(a.l, b.l, c.l, d.l, e.l)
  GetGlobalParam(a.l, b.l, c.l)
  SetGlobalParam(a.l, b.l, c.l)
  GetLatencyTime(a.l)
  GetQueueTime(a.l)
  AdjustTime(a.q)
  CloseDown()
  GetResolvedTime(a.q, b.l, c.l)
  MIDIToMusic(a.l, b.l, c.l, d.l, e.l)
  MusicToMIDI(a.l, b.l, c.l, d.l, e.l)
  TimeToRhythm(a.l, b.l, c.l, d.l, e.l, f.l)
  RhythmToTime(a.l, b.l, c.l, d.l, e.l, f.l)
  InitAudio(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  PlaySegmentEx(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StopEx(a.l, b.l, c.l)
  ClonePMsg(a.l, b.l)
  CreateAudioPath(a.l, b.l, c.l)
  CreateStandardAudioPath(a.l, b.l, c.l, d.l)
  SetDefaultAudioPath(a.l)
  GetDefaultAudioPath(a.l)
  GetParamEx(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IDirectMusicGraph interface definition
;
Interface IDirectMusicGraph
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  StampPMsg(a.l)
  InsertTool(a.l, b.l, c.l, d.l)
  GetTool(a.l, b.l)
  RemoveTool(a.l)
EndInterface

; IDirectMusicStyle interface definition
;
Interface IDirectMusicStyle
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBand(a.l, b.l)
  EnumBand(a.l, b.l)
  GetDefaultBand(a.l)
  EnumMotif(a.l, b.l)
  GetMotif(a.l, b.l)
  GetDefaultChordMap(a.l)
  EnumChordMap(a.l, b.l)
  GetChordMap(a.l, b.l)
  GetTimeSignature(a.l)
  GetEmbellishmentLength(a.l, b.l, c.l, d.l)
  GetTempo(a.l)
EndInterface

; IDirectMusicStyle8 interface definition
;
Interface IDirectMusicStyle8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBand(a.l, b.l)
  EnumBand(a.l, b.l)
  GetDefaultBand(a.l)
  EnumMotif(a.l, b.l)
  GetMotif(a.l, b.l)
  GetDefaultChordMap(a.l)
  EnumChordMap(a.l, b.l)
  GetChordMap(a.l, b.l)
  GetTimeSignature(a.l)
  GetEmbellishmentLength(a.l, b.l, c.l, d.l)
  GetTempo(a.l)
  EnumPattern(a.l, b.l, c.l)
EndInterface

; IDirectMusicChordMap interface definition
;
Interface IDirectMusicChordMap
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetScale(a.l)
EndInterface

; IDirectMusicComposer interface definition
;
Interface IDirectMusicComposer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ComposeSegmentFromTemplate(a.l, b.l, c.l, d.l, e.l)
  ComposeSegmentFromShape(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  ComposeTransition(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  AutoTransition(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  ComposeTemplateFromShape(a.l, b.l, c.l, d.l, e.l, f.l)
  ChangeChordMap(a.l, b.l, c.l)
EndInterface

; IDirectMusicPatternTrack interface definition
;
Interface IDirectMusicPatternTrack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateSegment(a.l, b.l)
  SetVariation(a.l, b.l, c.l)
  SetPatternByName(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IDirectMusicScript interface definition
;
Interface IDirectMusicScript
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l)
  CallRoutine(a.l, b.l)
  SetVariableVariant(a.l, b.l, c.l, d.l)
  GetVariableVariant(a.l, b.l, c.l)
  SetVariableNumber(a.l, b.l, c.l)
  GetVariableNumber(a.l, b.l, c.l)
  SetVariableObject(a.l, b.l, c.l)
  GetVariableObject(a.l, b.l, c.l, d.l)
  EnumRoutine(a.l, b.l)
  EnumVariable(a.l, b.l)
EndInterface

; IDirectMusicContainer interface definition
;
Interface IDirectMusicContainer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumObject(a.l, b.l, c.l, d.l)
EndInterface
