
; IDirectMusicTool interface definition
;
Interface IDirectMusicTool
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l)
  GetMsgDeliveryType(a.l)
  GetMediaTypeArraySize(a.l)
  GetMediaTypes(a.l, b.l)
  ProcessPMsg(a.l, b.l)
  Flush(a.l, b.l, c.q)
EndInterface

; IDirectMusicTool8 interface definition
;
Interface IDirectMusicTool8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l)
  GetMsgDeliveryType(a.l)
  GetMediaTypeArraySize(a.l)
  GetMediaTypes(a.l, b.l)
  ProcessPMsg(a.l, b.l)
  Flush(a.l, b.l, c.q)
  Clone(a.l)
EndInterface

; IDirectMusicTrack interface definition
;
Interface IDirectMusicTrack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l)
  InitPlay(a.l, b.l, c.l, d.l, e.l)
  EndPlay(a.l)
  Play(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetParam(a.l, b.l, c.l, d.l)
  SetParam(a.l, b.l, c.l)
  IsParamSupported(a.l)
  AddNotificationType(a.l)
  RemoveNotificationType(a.l)
  Clone(a.l, b.l, c.l)
EndInterface

; IDirectMusicTrack8 interface definition
;
Interface IDirectMusicTrack8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l)
  InitPlay(a.l, b.l, c.l, d.l, e.l)
  EndPlay(a.l)
  Play(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetParam(a.l, b.l, c.l, d.l)
  SetParam(a.l, b.l, c.l)
  IsParamSupported(a.l)
  AddNotificationType(a.l)
  RemoveNotificationType(a.l)
  Clone(a.l, b.l, c.l)
  PlayEx(a.l, b.q, c.q, d.q, e.l, f.l, g.l, h.l)
  GetParamEx(a.l, b.q, c.l, d.l, e.l, f.l)
  SetParamEx(a.l, b.q, c.l, d.l, e.l)
  Compose(a.l, b.l, c.l)
  Join(a.l, b.l, c.l, d.l, e.l)
EndInterface
