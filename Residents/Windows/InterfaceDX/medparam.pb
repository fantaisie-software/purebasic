
; IMediaParamInfo interface definition
;
Interface IMediaParamInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetParamCount(a.l)
  GetParamInfo(a.l, b.l)
  GetParamText(a.l, b.l)
  GetNumTimeFormats(a.l)
  GetSupportedTimeFormat(a.l, b.l)
  GetCurrentTimeFormat(a.l, b.l)
EndInterface

; IMediaParams interface definition
;
Interface IMediaParams
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetParam(a.l, b.l)
  SetParam(a.l, b.l)
  AddEnvelope(a.l, b.l, c.l)
  FlushEnvelope(a.l, b.q, c.q)
  SetTimeFormat(a.l, b.l)
EndInterface
