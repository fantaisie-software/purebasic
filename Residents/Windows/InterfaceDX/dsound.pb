
; IReferenceClock interface definition - Already defined in dmusicc.pb
;


; IDirectSound interface definition
;
Interface IDirectSound
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateSoundBuffer(a.l, b.l, c.l)
  GetCaps(a.l)
  DuplicateSoundBuffer(a.l, b.l)
  SetCooperativeLevel(a.l, b.l)
  Compact()
  GetSpeakerConfig(a.l)
  SetSpeakerConfig(a.l)
  Initialize(a.l)
EndInterface

; IDirectSound8 interface definition
;
Interface IDirectSound8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateSoundBuffer(a.l, b.l, c.l)
  GetCaps(a.l)
  DuplicateSoundBuffer(a.l, b.l)
  SetCooperativeLevel(a.l, b.l)
  Compact()
  GetSpeakerConfig(a.l)
  SetSpeakerConfig(a.l)
  Initialize(a.l)
  VerifyCertification(a.l)
EndInterface

; IDirectSoundBuffer interface definition
;
Interface IDirectSoundBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l)
  GetCurrentPosition(a.l, b.l)
  GetFormat(a.l, b.l, c.l)
  GetVolume(a.l)
  GetPan(a.l)
  GetFrequency(a.l)
  GetStatus(a.l)
  Initialize(a.l, b.l)
  Lock(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Play(a.l, b.l, c.l)
  SetCurrentPosition(a.l)
  SetFormat(a.l)
  SetVolume(a.l)
  SetPan(a.l)
  SetFrequency(a.l)
  Stop()
  Unlock(a.l, b.l, c.l, d.l)
  Restore()
EndInterface

; IDirectSoundBuffer8 interface definition
;
Interface IDirectSoundBuffer8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l)
  GetCurrentPosition(a.l, b.l)
  GetFormat(a.l, b.l, c.l)
  GetVolume(a.l)
  GetPan(a.l)
  GetFrequency(a.l)
  GetStatus(a.l)
  Initialize(a.l, b.l)
  Lock(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Play(a.l, b.l, c.l)
  SetCurrentPosition(a.l)
  SetFormat(a.l)
  SetVolume(a.l)
  SetPan(a.l)
  SetFrequency(a.l)
  Stop()
  Unlock(a.l, b.l, c.l, d.l)
  Restore()
  SetFX(a.l, b.l, c.l)
  AcquireResources(a.l, b.l, c.l)
  GetObjectInPath(a.l, b.l, c.l, d.l)
EndInterface

; IDirectSound3DListener interface definition
;
Interface IDirectSound3DListener
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetAllParameters(a.l)
  GetDistanceFactor(a.l)
  GetDopplerFactor(a.l)
  GetOrientation(a.l, b.l)
  GetPosition(a.l)
  GetRolloffFactor(a.l)
  GetVelocity(a.l)
  SetAllParameters(a.l, b.l)
  SetDistanceFactor(a.f, b.l)
  SetDopplerFactor(a.f, b.l)
  SetOrientation(a.f, b.f, c.f, d.f, e.f, f.f, g.l)
  SetPosition(a.f, b.f, c.f, d.l)
  SetRolloffFactor(a.f, b.l)
  SetVelocity(a.f, b.f, c.f, d.l)
  CommitDeferredSettings()
EndInterface

; IDirectSound3DBuffer interface definition
;
Interface IDirectSound3DBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetAllParameters(a.l)
  GetConeAngles(a.l, b.l)
  GetConeOrientation(a.l)
  GetConeOutsideVolume(a.l)
  GetMaxDistance(a.l)
  GetMinDistance(a.l)
  GetMode(a.l)
  GetPosition(a.l)
  GetVelocity(a.l)
  SetAllParameters(a.l, b.l)
  SetConeAngles(a.l, b.l, c.l)
  SetConeOrientation(a.f, b.f, c.f, d.l)
  SetConeOutsideVolume(a.l, b.l)
  SetMaxDistance(a.f, b.l)
  SetMinDistance(a.f, b.l)
  SetMode(a.l, b.l)
  SetPosition(a.f, b.f, c.f, d.l)
  SetVelocity(a.f, b.f, c.f, d.l)
EndInterface

; IDirectSoundCapture interface definition
;
Interface IDirectSoundCapture
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateCaptureBuffer(a.l, b.l, c.l)
  GetCaps(a.l)
  Initialize(a.l)
EndInterface

; IDirectSoundCaptureBuffer interface definition
;
Interface IDirectSoundCaptureBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l)
  GetCurrentPosition(a.l, b.l)
  GetFormat(a.l, b.l, c.l)
  GetStatus(a.l)
  Initialize(a.l, b.l)
  Lock(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Start(a.l)
  Stop()
  Unlock(a.l, b.l, c.l, d.l)
EndInterface

; IDirectSoundCaptureBuffer8 interface definition
;
Interface IDirectSoundCaptureBuffer8
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l)
  GetCurrentPosition(a.l, b.l)
  GetFormat(a.l, b.l, c.l)
  GetStatus(a.l)
  Initialize(a.l, b.l)
  Lock(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Start(a.l)
  Stop()
  Unlock(a.l, b.l, c.l, d.l)
  GetObjectInPath(a.l, b.l, c.l, d.l)
  GetFXStatus(a.l)
EndInterface

; IDirectSoundNotify interface definition
;
Interface IDirectSoundNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetNotificationPositions(a.l, b.l)
EndInterface

; IKsPropertySet interface definition
;
Interface IKsPropertySet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Get(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Set(a.l, b.l, c.l, d.l, e.l, f.l)
  QuerySupport(a.l, b.l, c.l)
EndInterface

; IDirectSoundFXGargle interface definition
;
Interface IDirectSoundFXGargle
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXChorus interface definition
;
Interface IDirectSoundFXChorus
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXFlanger interface definition
;
Interface IDirectSoundFXFlanger
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXEcho interface definition
;
Interface IDirectSoundFXEcho
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXDistortion interface definition
;
Interface IDirectSoundFXDistortion
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXCompressor interface definition
;
Interface IDirectSoundFXCompressor
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXParamEq interface definition
;
Interface IDirectSoundFXParamEq
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundFXI3DL2Reverb interface definition
;
Interface IDirectSoundFXI3DL2Reverb
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
  SetPreset(a.l)
  GetPreset(a.l)
  SetQuality(a.l)
  GetQuality(a.l)
EndInterface

; IDirectSoundFXWavesReverb interface definition
;
Interface IDirectSoundFXWavesReverb
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
EndInterface

; IDirectSoundCaptureFXAec interface definition
;
Interface IDirectSoundCaptureFXAec
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
  GetStatus(a.l)
  Reset()
EndInterface

; IDirectSoundCaptureFXNoiseSuppress interface definition
;
Interface IDirectSoundCaptureFXNoiseSuppress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAllParameters(a.l)
  GetAllParameters(a.l)
  Reset()
EndInterface

; IDirectSoundFullDuplex interface definition
;
Interface IDirectSoundFullDuplex
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface
