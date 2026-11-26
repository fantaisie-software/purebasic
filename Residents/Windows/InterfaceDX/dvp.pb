
; IDDVideoPortContainer interface definition
;
Interface IDDVideoPortContainer Extends IUnknown
  CreateVideoPort(a.l, b.l, c.l, d.l)
  EnumVideoPorts(a.l, b.l, c.l, d.l)
  GetVideoPortConnectInfo(a.l, b.l, c.l)
  QueryVideoPortStatus(a.l, b.l)
EndInterface

; IDirectDrawVideoPort interface definition
;
Interface IDirectDrawVideoPort Extends IUnknown
  Flip(a.l, b.l)
  GetBandwidthInfo(a.l, b.l, c.l, d.l, e.l)
  GetColorControls(a.l)
  GetInputFormats(a.l, b.l, c.l)
  GetOutputFormats(a.l, b.l, c.l, d.l)
  GetFieldPolarity(a.l)
  GetVideoLine(a.l)
  GetVideoSignalStatus(a.l)
  SetColorControls(a.l)
  SetTargetSurface(a.l, b.l)
  StartVideo(a.l)
  StopVideo()
  UpdateVideo(a.l)
  WaitForSync(a.l, b.l, c.l)
EndInterface

; IDirectDrawVideoPortNotify interface definition
;
Interface IDirectDrawVideoPortNotify Extends IUnknown
  AcquireNotification(a.l, b.l)
  ReleaseNotification(a.l)
EndInterface
