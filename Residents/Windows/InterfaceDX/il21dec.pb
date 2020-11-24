
; IAMLine21Decoder interface definition
;
Interface IAMLine21Decoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDecoderLevel(a.l)
  GetCurrentService(a.l)
  SetCurrentService(a.l)
  GetServiceState(a.l)
  SetServiceState(a.l)
  GetOutputFormat(a.l)
  SetOutputFormat(a.l)
  GetBackgroundColor(a.l)
  SetBackgroundColor(a.l)
  GetRedrawAlways(a.l)
  SetRedrawAlways(a.l)
  GetDrawBackgroundMode(a.l)
  SetDrawBackgroundMode(a.l)
EndInterface
