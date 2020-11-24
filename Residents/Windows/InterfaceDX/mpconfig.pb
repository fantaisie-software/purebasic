
; IMixerPinConfig interface definition
;
Interface IMixerPinConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRelativePosition(a.l, b.l, c.l, d.l)
  GetRelativePosition(a.l, b.l, c.l, d.l)
  SetZOrder(a.l)
  GetZOrder(a.l)
  SetColorKey(a.l)
  GetColorKey(a.l, b.l)
  SetBlendingParameter(a.l)
  GetBlendingParameter(a.l)
  SetAspectRatioMode(a.l)
  GetAspectRatioMode(a.l)
  SetStreamTransparent(a.l)
  GetStreamTransparent(a.l)
EndInterface

; IMixerPinConfig2 interface definition
;
Interface IMixerPinConfig2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRelativePosition(a.l, b.l, c.l, d.l)
  GetRelativePosition(a.l, b.l, c.l, d.l)
  SetZOrder(a.l)
  GetZOrder(a.l)
  SetColorKey(a.l)
  GetColorKey(a.l, b.l)
  SetBlendingParameter(a.l)
  GetBlendingParameter(a.l)
  SetAspectRatioMode(a.l)
  GetAspectRatioMode(a.l)
  SetStreamTransparent(a.l)
  GetStreamTransparent(a.l)
  SetOverlaySurfaceColorControls(a.l)
  GetOverlaySurfaceColorControls(a.l)
EndInterface
