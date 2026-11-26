
; IDirectPlayVoiceClient interface definition
;
Interface IDirectPlayVoiceClient Extends IUnknown
  Initialize(a.l, b.l, c.l, d.l, e.l)
  Connect(a.l, b.l, c.l)
  Disconnect(a.l)
  GetSessionDesc(a.l)
  GetClientConfig(a.l)
  SetClientConfig(a.l)
  GetCaps(a.l)
  GetCompressionTypes(a.l, b.l, c.l, d.l)
  SetTransmitTargets(a.l, b.l, c.l)
  GetTransmitTargets(a.l, b.l, c.l)
  Create3DSoundBuffer(a.l, b.l, c.l, d.l, e.l)
  Delete3DSoundBuffer(a.l, b.l)
  SetNotifyMask(a.l, b.l)
  GetSoundDeviceConfig(a.l, b.l)
EndInterface

; IDirectPlayVoiceServer interface definition
;
Interface IDirectPlayVoiceServer Extends IUnknown
  Initialize(a.l, b.l, c.l, d.l, e.l)
  StartSession(a.l, b.l)
  StopSession(a.l)
  GetSessionDesc(a.l)
  SetSessionDesc(a.l)
  GetCaps(a.l)
  GetCompressionTypes(a.l, b.l, c.l, d.l)
  SetTransmitTargets(a.l, b.l, c.l, d.l)
  GetTransmitTargets(a.l, b.l, c.l, d.l)
  SetNotifyMask(a.l, b.l)
EndInterface

; IDirectPlayVoiceTest interface definition
;
Interface IDirectPlayVoiceTest Extends IUnknown
  CheckAudioSetup(a.l, b.l, c.l, d.l)
EndInterface
