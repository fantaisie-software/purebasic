
; IAMWstDecoder interface definition
;
Interface IAMWstDecoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDecoderLevel(a.l)
  GetCurrentService(a.l)
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
  SetAnswerMode(a.l)
  GetAnswerMode(a.l)
  SetHoldPage(a.l)
  GetHoldPage(a.l)
  GetCurrentPage(a.l)
  SetCurrentPage(a.l)
EndInterface
