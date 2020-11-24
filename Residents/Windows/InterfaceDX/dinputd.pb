
; IDirectInputEffectDriver interface definition
;
Interface IDirectInputEffectDriver
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DeviceID(a.l, b.l, c.l, d.l, e.l)
  GetVersions(a.l)
  Escape(a.l, b.l, c.l)
  SetGain(a.l, b.l)
  SendForceFeedbackCommand(a.l, b.l)
  GetForceFeedbackState(a.l, b.l)
  DownloadEffect(a.l, b.l, c.l, d.l, e.l)
  DestroyEffect(a.l, b.l)
  StartEffect(a.l, b.l, c.l, d.l)
  StopEffect(a.l, b.l)
  GetEffectStatus(a.l, b.l, c.l)
EndInterface

; IDirectInputJoyConfig interface definition
;
Interface IDirectInputJoyConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Acquire()
  Unacquire()
  SetCooperativeLevel(a.l, b.l)
  SendNotify()
  EnumTypes(a.l, b.l)
  GetTypeInfo(a.l, b.l, c.l)
  SetTypeInfo(a.l, b.l, c.l)
  DeleteType(a.l)
  GetConfig(a.l, b.l, c.l)
  SetConfig(a.l, b.l, c.l)
  DeleteConfig(a.l)
  GetUserValues(a.l, b.l)
  SetUserValues(a.l, b.l)
  AddNewHardware(a.l, b.l)
  OpenTypeKey(a.l, b.l, c.l)
  OpenConfigKey(a.l, b.l, c.l)
EndInterface

; IDirectInputJoyConfig8 interface definition
;
Interface IDirectInputJoyConfig8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Acquire()
  Unacquire()
  SetCooperativeLevel(a.l, b.l)
  SendNotify()
  EnumTypes(a.l, b.l)
  GetTypeInfo(a.l, b.l, c.l)
  SetTypeInfo(a.l, b.l, c.l, d.l)
  DeleteType(a.l)
  GetConfig(a.l, b.l, c.l)
  SetConfig(a.l, b.l, c.l)
  DeleteConfig(a.l)
  GetUserValues(a.l, b.l)
  SetUserValues(a.l, b.l)
  AddNewHardware(a.l, b.l)
  OpenTypeKey(a.l, b.l, c.l)
  OpenAppStatusKey(a.l)
EndInterface
