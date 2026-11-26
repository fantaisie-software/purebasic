
; IDirectInputEffect interface definition
;
Interface IDirectInputEffect Extends IUnknown
  Initialize(a.l, b.l, c.l)
  GetEffectGuid(a.l)
  GetParameters(a.l, b.l)
  SetParameters(a.l, b.l)
  Start(a.l, b.l)
  Stop()
  GetEffectStatus(a.l)
  Download()
  Unload()
  Escape(a.l)
EndInterface

; IDirectInputDeviceW interface definition
;
Interface IDirectInputDeviceW Extends IUnknown
  GetCapabilities(a.l)
  EnumObjects(a.l, b.l, c.l)
  GetProperty(a.l, b.l)
  SetProperty(a.l, b.l)
  Acquire()
  Unacquire()
  GetDeviceState(a.l, b.l)
  GetDeviceData(a.l, b.l, c.l, d.l)
  SetDataFormat(a.l)
  SetEventNotification(a.l)
  SetCooperativeLevel(a.l, b.l)
  GetObjectInfo(a.l, b.l, c.l)
  GetDeviceInfo(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l, c.l)
EndInterface

; IDirectInputDeviceA interface definition
;
Interface IDirectInputDeviceA Extends IUnknown
  GetCapabilities(a.l)
  EnumObjects(a.l, b.l, c.l)
  GetProperty(a.l, b.l)
  SetProperty(a.l, b.l)
  Acquire()
  Unacquire()
  GetDeviceState(a.l, b.l)
  GetDeviceData(a.l, b.l, c.l, d.l)
  SetDataFormat(a.l)
  SetEventNotification(a.l)
  SetCooperativeLevel(a.l, b.l)
  GetObjectInfo(a.l, b.l, c.l)
  GetDeviceInfo(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l, c.l)
EndInterface

; IDirectInputDevice2W interface definition
;
Interface IDirectInputDevice2W Extends IDirectInputDeviceW
  CreateEffect(a.l, b.l, c.l, d.l)
  EnumEffects(a.l, b.l, c.l)
  GetEffectInfo(a.l, b.l)
  GetForceFeedbackState(a.l)
  SendForceFeedbackCommand(a.l)
  EnumCreatedEffectObjects(a.l, b.l, c.l)
  Escape(a.l)
  Poll()
  SendDeviceData(a.l, b.l, c.l, d.l)
EndInterface

; IDirectInputDevice2A interface definition
;
Interface IDirectInputDevice2A Extends IDirectInputDeviceA
  CreateEffect(a.l, b.l, c.l, d.l)
  EnumEffects(a.l, b.l, c.l)
  GetEffectInfo(a.l, b.l)
  GetForceFeedbackState(a.l)
  SendForceFeedbackCommand(a.l)
  EnumCreatedEffectObjects(a.l, b.l, c.l)
  Escape(a.l)
  Poll()
  SendDeviceData(a.l, b.l, c.l, d.l)
EndInterface

; IDirectInputDevice7W interface definition
;
Interface IDirectInputDevice7W Extends IDirectInputDevice2W
  EnumEffectsInFile(a.l, b.l, c.l, d.l)
  WriteEffectToFile(a.l, b.l, c.l, d.l)
EndInterface

; IDirectInputDevice7A interface definition
;
Interface IDirectInputDevice7A Extends IDirectInputDevice2A
  EnumEffectsInFile(a.s, b.l, c.l, d.l)
  WriteEffectToFile(a.s, b.l, c.l, d.l)
EndInterface

; IDirectInputDevice8W interface definition
;
Interface IDirectInputDevice8W Extends IUnknown
  GetCapabilities(a.l)
  EnumObjects(a.l, b.l, c.l)
  GetProperty(a.l, b.l)
  SetProperty(a.l, b.l)
  Acquire()
  Unacquire()
  GetDeviceState(a.l, b.l)
  GetDeviceData(a.l, b.l, c.l, d.l)
  SetDataFormat(a.l)
  SetEventNotification(a.l)
  SetCooperativeLevel(a.l, b.l)
  GetObjectInfo(a.l, b.l, c.l)
  GetDeviceInfo(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l, c.l)
  CreateEffect(a.l, b.l, c.l, d.l)
  EnumEffects(a.l, b.l, c.l)
  GetEffectInfo(a.l, b.l)
  GetForceFeedbackState(a.l)
  SendForceFeedbackCommand(a.l)
  EnumCreatedEffectObjects(a.l, b.l, c.l)
  Escape(a.l)
  Poll()
  SendDeviceData(a.l, b.l, c.l, d.l)
  EnumEffectsInFile(a.l, b.l, c.l, d.l)
  WriteEffectToFile(a.l, b.l, c.l, d.l)
  BuildActionMap(a.l, b.l, c.l)
  SetActionMap(a.l, b.l, c.l)
  GetImageInfo(a.l)
EndInterface

; IDirectInputDevice8A interface definition
;
Interface IDirectInputDevice8A Extends IUnknown
  GetCapabilities(a.l)
  EnumObjects(a.l, b.l, c.l)
  GetProperty(a.l, b.l)
  SetProperty(a.l, b.l)
  Acquire()
  Unacquire()
  GetDeviceState(a.l, b.l)
  GetDeviceData(a.l, b.l, c.l, d.l)
  SetDataFormat(a.l)
  SetEventNotification(a.l)
  SetCooperativeLevel(a.l, b.l)
  GetObjectInfo(a.l, b.l, c.l)
  GetDeviceInfo(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l, c.l)
  CreateEffect(a.l, b.l, c.l, d.l)
  EnumEffects(a.l, b.l, c.l)
  GetEffectInfo(a.l, b.l)
  GetForceFeedbackState(a.l)
  SendForceFeedbackCommand(a.l)
  EnumCreatedEffectObjects(a.l, b.l, c.l)
  Escape(a.l)
  Poll()
  SendDeviceData(a.l, b.l, c.l, d.l)
  EnumEffectsInFile(a.s, b.l, c.l, d.l)
  WriteEffectToFile(a.s, b.l, c.l, d.l)
  BuildActionMap(a.l, b.s, c.l)
  SetActionMap(a.l, b.s, c.l)
  GetImageInfo(a.l)
EndInterface

; IDirectInputW interface definition
;
Interface IDirectInputW Extends IUnknown
  CreateDevice(a.l, b.l, c.l)
  EnumDevices(a.l, b.l, c.l, d.l)
  GetDeviceStatus(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l)
EndInterface

; IDirectInputA interface definition
;
Interface IDirectInputA Extends IUnknown
  CreateDevice(a.l, b.l, c.l)
  EnumDevices(a.l, b.l, c.l, d.l)
  GetDeviceStatus(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l)
EndInterface

; IDirectInput2W interface definition
;
Interface IDirectInput2W Extends IDirectInputW
  FindDevice(a.l, b.l, c.l)
EndInterface

; IDirectInput2A interface definition
;
Interface IDirectInput2A Extends IDirectInputA
  FindDevice(a.l, b.s, c.l)
EndInterface

; IDirectInput7W interface definition
;
Interface IDirectInput7W Extends IDirectInput2W
  CreateDeviceEx(a.l, b.l, c.l, d.l)
EndInterface

; IDirectInput7A interface definition
;
Interface IDirectInput7A Extends IDirectInput2A
  CreateDeviceEx(a.l, b.l, c.l, d.l)
EndInterface

; IDirectInput8W interface definition
;
Interface IDirectInput8W Extends IUnknown
  CreateDevice(a.l, b.l, c.l)
  EnumDevices(a.l, b.l, c.l, d.l)
  GetDeviceStatus(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l)
  FindDevice(a.l, b.l, c.l)
  EnumDevicesBySemantics(a.l, b.l, c.l, d.l, e.l)
  ConfigureDevices(a.l, b.l, c.l, d.l)
EndInterface

; IDirectInput8A interface definition
;
Interface IDirectInput8A Extends IUnknown
  CreateDevice(a.l, b.l, c.l)
  EnumDevices(a.l, b.l, c.l, d.l)
  GetDeviceStatus(a.l)
  RunControlPanel(a.l, b.l)
  Initialize(a.l, b.l)
  FindDevice(a.l, b.s, c.l)
  EnumDevicesBySemantics(a.s, b.l, c.l, d.l, e.l)
  ConfigureDevices(a.l, b.l, c.l, d.l)
EndInterface
