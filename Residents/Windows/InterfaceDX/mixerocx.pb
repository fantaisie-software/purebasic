
; IMixerOCXNotify interface definition
;
Interface IMixerOCXNotify Extends IUnknown
  OnInvalidateRect(a.l)
  OnStatusChange(a.l)
  OnDataChange(a.l)
EndInterface

; IMixerOCX interface definition
;
Interface IMixerOCX Extends IUnknown
  OnDisplayChange(a.l, b.l, c.l)
  GetAspectRatio(a.l, b.l)
  GetVideoSize(a.l, b.l)
  GetStatus(a.l)
  OnDraw(a.l, b.l)
  SetDrawRegion(a.l, b.l, c.l)
  Advise(a.l)
  UnAdvise()
EndInterface
