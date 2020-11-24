
; IDirectDrawVideo interface definition
;
Interface IDirectDrawVideo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSwitches(a.l)
  SetSwitches(a.l)
  GetCaps(a.l)
  GetEmulatedCaps(a.l)
  GetSurfaceDesc(a.l)
  GetFourCCCodes(a.l, b.l)
  SetDirectDraw(a.l)
  GetDirectDraw(a.l)
  GetSurfaceType(a.l)
  SetDefault()
  UseScanLine(a.l)
  CanUseScanLine(a.l)
  UseOverlayStretch(a.l)
  CanUseOverlayStretch(a.l)
  UseWhenFullScreen(a.l)
  WillUseFullScreen(a.l)
EndInterface

; IQualProp interface definition
;
Interface IQualProp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_FramesDroppedInRenderer(a.l)
  get_FramesDrawn(a.l)
  get_AvgFrameRate(a.l)
  get_Jitter(a.l)
  get_AvgSyncOffset(a.l)
  get_DevSyncOffset(a.l)
EndInterface

; IFullScreenVideo interface definition
;
Interface IFullScreenVideo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CountModes(a.l)
  GetModeInfo(a.l, b.l, c.l, d.l)
  GetCurrentMode(a.l)
  IsModeAvailable(a.l)
  IsModeEnabled(a.l)
  SetEnabled(a.l, b.l)
  GetClipFactor(a.l)
  SetClipFactor(a.l)
  SetMessageDrain(a.l)
  GetMessageDrain(a.l)
  SetMonitor(a.l)
  GetMonitor(a.l)
  HideOnDeactivate(a.l)
  IsHideOnDeactivate()
  SetCaption(a.l)
  GetCaption(a.l)
  SetDefault()
EndInterface

; IFullScreenVideoEx interface definition
;
Interface IFullScreenVideoEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CountModes(a.l)
  GetModeInfo(a.l, b.l, c.l, d.l)
  GetCurrentMode(a.l)
  IsModeAvailable(a.l)
  IsModeEnabled(a.l)
  SetEnabled(a.l, b.l)
  GetClipFactor(a.l)
  SetClipFactor(a.l)
  SetMessageDrain(a.l)
  GetMessageDrain(a.l)
  SetMonitor(a.l)
  GetMonitor(a.l)
  HideOnDeactivate(a.l)
  IsHideOnDeactivate()
  SetCaption(a.l)
  GetCaption(a.l)
  SetDefault()
  SetAcceleratorTable(a.l, b.l)
  GetAcceleratorTable(a.l, b.l)
  KeepPixelAspectRatio(a.l)
  IsKeepPixelAspectRatio(a.l)
EndInterface

; IBaseVideoMixer interface definition
;
Interface IBaseVideoMixer
  SetLeadPin(a.l)
  GetLeadPin(a.l)
  GetInputPinCount(a.l)
  IsUsingClock(a.l)
  SetUsingClock(a.l)
  GetClockPeriod(a.l)
  SetClockPeriod(a.l)
EndInterface
