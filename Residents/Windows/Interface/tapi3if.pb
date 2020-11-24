
; ITTAPI interface definition
;
Interface ITTAPI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Initialize()
  Shutdown()
  get_Addresses(a.l)
  EnumerateAddresses(a.l)
  RegisterCallNotifications(a.l, b.l, c.l, d.l, e.l, f.l)
  UnregisterNotifications(a.l)
  get_CallHubs(a.l)
  EnumerateCallHubs(a.l)
  SetCallHubTracking(a.p-variant, b.l)
  EnumeratePrivateTAPIObjects(a.l)
  get_PrivateTAPIObjects(a.l)
  RegisterRequestRecipient(a.l, b.l, c.l)
  SetAssistedTelephonyPriority(a.p-bstr, b.l)
  SetApplicationPriority(a.p-bstr, b.l, c.l)
  put_EventFilter(a.l)
  get_EventFilter(a.l)
EndInterface

; ITTAPI2 interface definition
;
Interface ITTAPI2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Initialize()
  Shutdown()
  get_Addresses(a.l)
  EnumerateAddresses(a.l)
  RegisterCallNotifications(a.l, b.l, c.l, d.l, e.l, f.l)
  UnregisterNotifications(a.l)
  get_CallHubs(a.l)
  EnumerateCallHubs(a.l)
  SetCallHubTracking(a.p-variant, b.l)
  EnumeratePrivateTAPIObjects(a.l)
  get_PrivateTAPIObjects(a.l)
  RegisterRequestRecipient(a.l, b.l, c.l)
  SetAssistedTelephonyPriority(a.p-bstr, b.l)
  SetApplicationPriority(a.p-bstr, b.l, c.l)
  put_EventFilter(a.l)
  get_EventFilter(a.l)
  get_Phones(a.l)
  EnumeratePhones(a.l)
  CreateEmptyCollectionObject(a.l)
EndInterface

; ITMediaSupport interface definition
;
Interface ITMediaSupport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_MediaTypes(a.l)
  QueryMediaType(a.l, b.l)
EndInterface

; ITPluggableTerminalClassInfo interface definition
;
Interface ITPluggableTerminalClassInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Company(a.l)
  get_Version(a.l)
  get_TerminalClass(a.l)
  get_CLSID(a.l)
  get_Direction(a.l)
  get_MediaTypes(a.l)
EndInterface

; ITPluggableTerminalSuperclassInfo interface definition
;
Interface ITPluggableTerminalSuperclassInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_CLSID(a.l)
EndInterface

; ITTerminalSupport interface definition
;
Interface ITTerminalSupport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_StaticTerminals(a.l)
  EnumerateStaticTerminals(a.l)
  get_DynamicTerminalClasses(a.l)
  EnumerateDynamicTerminalClasses(a.l)
  CreateTerminal(a.p-bstr, b.l, c.l, d.l)
  GetDefaultStaticTerminal(a.l, b.l, c.l)
EndInterface

; ITTerminalSupport2 interface definition
;
Interface ITTerminalSupport2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_StaticTerminals(a.l)
  EnumerateStaticTerminals(a.l)
  get_DynamicTerminalClasses(a.l)
  EnumerateDynamicTerminalClasses(a.l)
  CreateTerminal(a.p-bstr, b.l, c.l, d.l)
  GetDefaultStaticTerminal(a.l, b.l, c.l)
  get_PluggableSuperclasses(a.l)
  EnumeratePluggableSuperclasses(a.l)
  get_PluggableTerminalClasses(a.p-bstr, b.l, c.l)
  EnumeratePluggableTerminalClasses(a.l, b.l, c.l)
EndInterface

; ITAddress interface definition
;
Interface ITAddress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_State(a.l)
  get_AddressName(a.l)
  get_ServiceProviderName(a.l)
  get_TAPIObject(a.l)
  CreateCall(a.p-bstr, b.l, c.l, d.l)
  get_Calls(a.l)
  EnumerateCalls(a.l)
  get_DialableAddress(a.l)
  CreateForwardInfoObject(a.l)
  Forward(a.l, b.l)
  get_CurrentForwardInfo(a.l)
  put_MessageWaiting(a.l)
  get_MessageWaiting(a.l)
  put_DoNotDisturb(a.l)
  get_DoNotDisturb(a.l)
EndInterface

; ITAddress2 interface definition
;
Interface ITAddress2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_State(a.l)
  get_AddressName(a.l)
  get_ServiceProviderName(a.l)
  get_TAPIObject(a.l)
  CreateCall(a.p-bstr, b.l, c.l, d.l)
  get_Calls(a.l)
  EnumerateCalls(a.l)
  get_DialableAddress(a.l)
  CreateForwardInfoObject(a.l)
  Forward(a.l, b.l)
  get_CurrentForwardInfo(a.l)
  put_MessageWaiting(a.l)
  get_MessageWaiting(a.l)
  put_DoNotDisturb(a.l)
  get_DoNotDisturb(a.l)
  get_Phones(a.l)
  EnumeratePhones(a.l)
  GetPhoneFromTerminal(a.l, b.l)
  get_PreferredPhones(a.l)
  EnumeratePreferredPhones(a.l)
  get_EventFilter(a.l, b.l, c.l)
  put_EventFilter(a.l, b.l, c.l)
  DeviceSpecific(a.l, b.l, c.l)
  DeviceSpecificVariant(a.l, b.p-variant)
  NegotiateExtVersion(a.l, b.l, c.l)
EndInterface

; ITAddressCapabilities interface definition
;
Interface ITAddressCapabilities
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_AddressCapability(a.l, b.l)
  get_AddressCapabilityString(a.l, b.l)
  get_CallTreatments(a.l)
  EnumerateCallTreatments(a.l)
  get_CompletionMessages(a.l)
  EnumerateCompletionMessages(a.l)
  get_DeviceClasses(a.l)
  EnumerateDeviceClasses(a.l)
EndInterface

; ITPhone interface definition
;
Interface ITPhone
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Open(a.l)
  Close()
  get_Addresses(a.l)
  EnumerateAddresses(a.l)
  get_PhoneCapsLong(a.l, b.l)
  get_PhoneCapsString(a.l, b.l)
  get_Terminals(a.l, b.l)
  EnumerateTerminals(a.l, b.l)
  get_ButtonMode(a.l, b.l)
  put_ButtonMode(a.l, b.l)
  get_ButtonFunction(a.l, b.l)
  put_ButtonFunction(a.l, b.l)
  get_ButtonText(a.l, b.l)
  put_ButtonText(a.l, b.p-bstr)
  get_ButtonState(a.l, b.l)
  get_HookSwitchState(a.l, b.l)
  put_HookSwitchState(a.l, b.l)
  put_RingMode(a.l)
  get_RingMode(a.l)
  put_RingVolume(a.l)
  get_RingVolume(a.l)
  get_Privilege(a.l)
  GetPhoneCapsBuffer(a.l, b.l, c.l)
  get_PhoneCapsBuffer(a.l, b.l)
  get_LampMode(a.l, b.l)
  put_LampMode(a.l, b.l)
  get_Display(a.l)
  SetDisplay(a.l, b.l, c.p-bstr)
  get_PreferredAddresses(a.l)
  EnumeratePreferredAddresses(a.l)
  DeviceSpecific(a.l, b.l)
  DeviceSpecificVariant(a.p-variant)
  NegotiateExtVersion(a.l, b.l, c.l)
EndInterface

; ITAutomatedPhoneControl interface definition
;
Interface ITAutomatedPhoneControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StartTone(a.l, b.l)
  StopTone()
  get_Tone(a.l)
  StartRinger(a.l, b.l)
  StopRinger()
  get_Ringer(a.l)
  put_PhoneHandlingEnabled(a.l)
  get_PhoneHandlingEnabled(a.l)
  put_AutoEndOfNumberTimeout(a.l)
  get_AutoEndOfNumberTimeout(a.l)
  put_AutoDialtone(a.l)
  get_AutoDialtone(a.l)
  put_AutoStopTonesOnOnHook(a.l)
  get_AutoStopTonesOnOnHook(a.l)
  put_AutoStopRingOnOffHook(a.l)
  get_AutoStopRingOnOffHook(a.l)
  put_AutoKeypadTones(a.l)
  get_AutoKeypadTones(a.l)
  put_AutoKeypadTonesMinimumDuration(a.l)
  get_AutoKeypadTonesMinimumDuration(a.l)
  put_AutoVolumeControl(a.l)
  get_AutoVolumeControl(a.l)
  put_AutoVolumeControlStep(a.l)
  get_AutoVolumeControlStep(a.l)
  put_AutoVolumeControlRepeatDelay(a.l)
  get_AutoVolumeControlRepeatDelay(a.l)
  put_AutoVolumeControlRepeatPeriod(a.l)
  get_AutoVolumeControlRepeatPeriod(a.l)
  SelectCall(a.l, b.l)
  UnselectCall(a.l)
  EnumerateSelectedCalls(a.l)
  get_SelectedCalls(a.l)
EndInterface

; ITBasicCallControl interface definition
;
Interface ITBasicCallControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Connect(a.l)
  Answer()
  Disconnect(a.l)
  Hold(a.l)
  HandoffDirect(a.p-bstr)
  HandoffIndirect(a.l)
  Conference(a.l, b.l)
  Transfer(a.l, b.l)
  BlindTransfer(a.p-bstr)
  SwapHold(a.l)
  ParkDirect(a.p-bstr)
  ParkIndirect(a.l)
  Unpark()
  SetQOS(a.l, b.l)
  Pickup(a.p-bstr)
  Dial(a.p-bstr)
  Finish(a.l)
  RemoveFromConference()
EndInterface

; ITCallInfo interface definition
;
Interface ITCallInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Address(a.l)
  get_CallState(a.l)
  get_Privilege(a.l)
  get_CallHub(a.l)
  get_CallInfoLong(a.l, b.l)
  put_CallInfoLong(a.l, b.l)
  get_CallInfoString(a.l, b.l)
  put_CallInfoString(a.l, b.p-bstr)
  get_CallInfoBuffer(a.l, b.l)
  put_CallInfoBuffer(a.l, b.p-variant)
  GetCallInfoBuffer(a.l, b.l, c.l)
  SetCallInfoBuffer(a.l, b.l, c.l)
  ReleaseUserUserInfo()
EndInterface

; ITCallInfo2 interface definition
;
Interface ITCallInfo2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Address(a.l)
  get_CallState(a.l)
  get_Privilege(a.l)
  get_CallHub(a.l)
  get_CallInfoLong(a.l, b.l)
  put_CallInfoLong(a.l, b.l)
  get_CallInfoString(a.l, b.l)
  put_CallInfoString(a.l, b.p-bstr)
  get_CallInfoBuffer(a.l, b.l)
  put_CallInfoBuffer(a.l, b.p-variant)
  GetCallInfoBuffer(a.l, b.l, c.l)
  SetCallInfoBuffer(a.l, b.l, c.l)
  ReleaseUserUserInfo()
  get_EventFilter(a.l, b.l, c.l)
  put_EventFilter(a.l, b.l, c.l)
EndInterface

; ITTerminal interface definition
;
Interface ITTerminal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_State(a.l)
  get_TerminalType(a.l)
  get_TerminalClass(a.l)
  get_MediaType(a.l)
  get_Direction(a.l)
EndInterface

; ITMultiTrackTerminal interface definition
;
Interface ITMultiTrackTerminal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_TrackTerminals(a.l)
  EnumerateTrackTerminals(a.l)
  CreateTrackTerminal(a.l, b.l, c.l)
  get_MediaTypesInUse(a.l)
  get_DirectionsInUse(a.l)
  RemoveTrackTerminal(a.l)
EndInterface

; ITFileTrack interface definition
;
Interface ITFileTrack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Format(a.l)
  put_Format(a.l)
  get_ControllingTerminal(a.l)
  get_AudioFormatForScripting(a.l)
  put_AudioFormatForScripting(a.l)
  get_EmptyAudioFormatForScripting(a.l)
EndInterface

; ITMediaPlayback interface definition
;
Interface ITMediaPlayback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_PlayList(a.l)
  get_PlayList(a.l)
EndInterface

; ITMediaRecord interface definition
;
Interface ITMediaRecord
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_FileName(a.p-bstr)
  get_FileName(a.l)
EndInterface

; ITMediaControl interface definition
;
Interface ITMediaControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Start()
  Stop()
  Pause()
  get_MediaState(a.l)
EndInterface

; ITBasicAudioTerminal interface definition
;
Interface ITBasicAudioTerminal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_Volume(a.l)
  get_Volume(a.l)
  put_Balance(a.l)
  get_Balance(a.l)
EndInterface

; ITStaticAudioTerminal interface definition
;
Interface ITStaticAudioTerminal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_WaveId(a.l)
EndInterface

; ITCallHub interface definition
;
Interface ITCallHub
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Clear()
  EnumerateCalls(a.l)
  get_Calls(a.l)
  get_NumCalls(a.l)
  get_State(a.l)
EndInterface

; ITLegacyAddressMediaControl interface definition
;
Interface ITLegacyAddressMediaControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetID(a.p-bstr, b.l, c.l)
  GetDevConfig(a.p-bstr, b.l, c.l)
  SetDevConfig(a.p-bstr, b.l, c.l)
EndInterface

; ITPrivateEvent interface definition
;
Interface ITPrivateEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Address(a.l)
  get_Call(a.l)
  get_CallHub(a.l)
  get_EventCode(a.l)
  get_EventInterface(a.l)
EndInterface

; ITLegacyAddressMediaControl2 interface definition
;
Interface ITLegacyAddressMediaControl2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetID(a.p-bstr, b.l, c.l)
  GetDevConfig(a.p-bstr, b.l, c.l)
  SetDevConfig(a.p-bstr, b.l, c.l)
  ConfigDialog(a.l, b.p-bstr)
  ConfigDialogEdit(a.l, b.p-bstr, c.l, d.l, e.l, f.l)
EndInterface

; ITLegacyCallMediaControl interface definition
;
Interface ITLegacyCallMediaControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  DetectDigits(a.l)
  GenerateDigits(a.p-bstr, b.l)
  GetID(a.p-bstr, b.l, c.l)
  SetMediaType(a.l)
  MonitorMedia(a.l)
EndInterface

; ITLegacyCallMediaControl2 interface definition
;
Interface ITLegacyCallMediaControl2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  DetectDigits(a.l)
  GenerateDigits(a.p-bstr, b.l)
  GetID(a.p-bstr, b.l, c.l)
  SetMediaType(a.l)
  MonitorMedia(a.l)
  GenerateDigits2(a.p-bstr, b.l, c.l)
  GatherDigits(a.l, b.l, c.p-bstr, d.l, e.l)
  DetectTones(a.l, b.l)
  DetectTonesByCollection(a.l)
  GenerateTone(a.l, b.l)
  GenerateCustomTones(a.l, b.l, c.l)
  GenerateCustomTonesByCollection(a.l, b.l)
  CreateDetectToneObject(a.l)
  CreateCustomToneObject(a.l)
  GetIDAsVariant(a.p-bstr, b.l)
EndInterface

; ITDetectTone interface definition
;
Interface ITDetectTone
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_AppSpecific(a.l)
  put_AppSpecific(a.l)
  get_Duration(a.l)
  put_Duration(a.l)
  get_Frequency(a.l, b.l)
  put_Frequency(a.l, b.l)
EndInterface

; ITCustomTone interface definition
;
Interface ITCustomTone
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Frequency(a.l)
  put_Frequency(a.l)
  get_CadenceOn(a.l)
  put_CadenceOn(a.l)
  get_CadenceOff(a.l)
  put_CadenceOff(a.l)
  get_Volume(a.l)
  put_Volume(a.l)
EndInterface

; IEnumPhone interface definition
;
Interface IEnumPhone
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumTerminal interface definition
;
Interface IEnumTerminal
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumTerminalClass interface definition
;
Interface IEnumTerminalClass
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumCall interface definition
;
Interface IEnumCall
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumAddress interface definition
;
Interface IEnumAddress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumCallHub interface definition
;
Interface IEnumCallHub
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumBstr interface definition
;
Interface IEnumBstr
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumPluggableTerminalClassInfo interface definition
;
Interface IEnumPluggableTerminalClassInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; IEnumPluggableSuperclassInfo interface definition
;
Interface IEnumPluggableSuperclassInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITPhoneEvent interface definition
;
Interface ITPhoneEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Phone(a.l)
  get_Event(a.l)
  get_ButtonState(a.l)
  get_HookSwitchState(a.l)
  get_HookSwitchDevice(a.l)
  get_RingMode(a.l)
  get_ButtonLampId(a.l)
  get_NumberGathered(a.l)
  get_Call(a.l)
EndInterface

; ITCallStateEvent interface definition
;
Interface ITCallStateEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_State(a.l)
  get_Cause(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITPhoneDeviceSpecificEvent interface definition
;
Interface ITPhoneDeviceSpecificEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Phone(a.l)
  get_lParam1(a.l)
  get_lParam2(a.l)
  get_lParam3(a.l)
EndInterface

; ITCallMediaEvent interface definition
;
Interface ITCallMediaEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_Event(a.l)
  get_Error(a.l)
  get_Terminal(a.l)
  get_Stream(a.l)
  get_Cause(a.l)
EndInterface

; ITDigitDetectionEvent interface definition
;
Interface ITDigitDetectionEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_Digit(a.l)
  get_DigitMode(a.l)
  get_TickCount(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITDigitGenerationEvent interface definition
;
Interface ITDigitGenerationEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_GenerationTermination(a.l)
  get_TickCount(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITDigitsGatheredEvent interface definition
;
Interface ITDigitsGatheredEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_Digits(a.l)
  get_GatherTermination(a.l)
  get_TickCount(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITToneDetectionEvent interface definition
;
Interface ITToneDetectionEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_AppSpecific(a.l)
  get_TickCount(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITTAPIObjectEvent interface definition
;
Interface ITTAPIObjectEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_TAPIObject(a.l)
  get_Event(a.l)
  get_Address(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITTAPIObjectEvent2 interface definition
;
Interface ITTAPIObjectEvent2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_TAPIObject(a.l)
  get_Event(a.l)
  get_Address(a.l)
  get_CallbackInstance(a.l)
  get_Phone(a.l)
EndInterface

; ITTAPIEventNotification interface definition
;
Interface ITTAPIEventNotification
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Event(a.l, b.l)
EndInterface

; ITCallHubEvent interface definition
;
Interface ITCallHubEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Event(a.l)
  get_CallHub(a.l)
  get_Call(a.l)
EndInterface

; ITAddressEvent interface definition
;
Interface ITAddressEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Address(a.l)
  get_Event(a.l)
  get_Terminal(a.l)
EndInterface

; ITAddressDeviceSpecificEvent interface definition
;
Interface ITAddressDeviceSpecificEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Address(a.l)
  get_Call(a.l)
  get_lParam1(a.l)
  get_lParam2(a.l)
  get_lParam3(a.l)
EndInterface

; ITFileTerminalEvent interface definition
;
Interface ITFileTerminalEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Terminal(a.l)
  get_Track(a.l)
  get_Call(a.l)
  get_State(a.l)
  get_Cause(a.l)
  get_Error(a.l)
EndInterface

; ITTTSTerminalEvent interface definition
;
Interface ITTTSTerminalEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Terminal(a.l)
  get_Call(a.l)
  get_Error(a.l)
EndInterface

; ITASRTerminalEvent interface definition
;
Interface ITASRTerminalEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Terminal(a.l)
  get_Call(a.l)
  get_Error(a.l)
EndInterface

; ITToneTerminalEvent interface definition
;
Interface ITToneTerminalEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Terminal(a.l)
  get_Call(a.l)
  get_Error(a.l)
EndInterface

; ITQOSEvent interface definition
;
Interface ITQOSEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_Event(a.l)
  get_MediaType(a.l)
EndInterface

; ITCallInfoChangeEvent interface definition
;
Interface ITCallInfoChangeEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_Cause(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITRequest interface definition
;
Interface ITRequest
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  MakeCall(a.p-bstr, b.p-bstr, c.p-bstr, d.p-bstr)
EndInterface

; ITRequestEvent interface definition
;
Interface ITRequestEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_RegistrationInstance(a.l)
  get_RequestMode(a.l)
  get_DestAddress(a.l)
  get_AppName(a.l)
  get_CalledParty(a.l)
  get_Comment(a.l)
EndInterface

; ITCollection interface definition
;
Interface ITCollection
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get_Item(a.l, b.l)
  get__NewEnum(a.l)
EndInterface

; ITCollection2 interface definition
;
Interface ITCollection2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get_Item(a.l, b.l)
  get__NewEnum(a.l)
  Add(a.l, b.l)
  Remove(a.l)
EndInterface

; ITForwardInformation interface definition
;
Interface ITForwardInformation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_NumRingsNoAnswer(a.l)
  get_NumRingsNoAnswer(a.l)
  SetForwardType(a.l, b.p-bstr, c.p-bstr)
  get_ForwardTypeDestination(a.l, b.l)
  get_ForwardTypeCaller(a.l, b.l)
  GetForwardType(a.l, b.l, c.l)
  Clear()
EndInterface

; ITForwardInformation2 interface definition
;
Interface ITForwardInformation2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_NumRingsNoAnswer(a.l)
  get_NumRingsNoAnswer(a.l)
  SetForwardType(a.l, b.p-bstr, c.p-bstr)
  get_ForwardTypeDestination(a.l, b.l)
  get_ForwardTypeCaller(a.l, b.l)
  GetForwardType(a.l, b.l, c.l)
  Clear()
  SetForwardType2(a.l, b.p-bstr, c.l, d.p-bstr, e.l)
  GetForwardType2(a.l, b.l, c.l, d.l, e.l)
  get_ForwardTypeDestinationAddressType(a.l, b.l)
  get_ForwardTypeCallerAddressType(a.l, b.l)
EndInterface

; ITAddressTranslation interface definition
;
Interface ITAddressTranslation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  TranslateAddress(a.p-bstr, b.l, c.l, d.l)
  TranslateDialog(a.l, b.p-bstr)
  EnumerateLocations(a.l)
  get_Locations(a.l)
  EnumerateCallingCards(a.l)
  get_CallingCards(a.l)
EndInterface

; ITAddressTranslationInfo interface definition
;
Interface ITAddressTranslationInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_DialableString(a.l)
  get_DisplayableString(a.l)
  get_CurrentCountryCode(a.l)
  get_DestinationCountryCode(a.l)
  get_TranslationResults(a.l)
EndInterface

; ITLocationInfo interface definition
;
Interface ITLocationInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_PermanentLocationID(a.l)
  get_CountryCode(a.l)
  get_CountryID(a.l)
  get_Options(a.l)
  get_PreferredCardID(a.l)
  get_LocationName(a.l)
  get_CityCode(a.l)
  get_LocalAccessCode(a.l)
  get_LongDistanceAccessCode(a.l)
  get_TollPrefixList(a.l)
  get_CancelCallWaitingCode(a.l)
EndInterface

; IEnumLocation interface definition
;
Interface IEnumLocation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITCallingCard interface definition
;
Interface ITCallingCard
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_PermanentCardID(a.l)
  get_NumberOfDigits(a.l)
  get_Options(a.l)
  get_CardName(a.l)
  get_SameAreaDialingRule(a.l)
  get_LongDistanceDialingRule(a.l)
  get_InternationalDialingRule(a.l)
EndInterface

; IEnumCallingCard interface definition
;
Interface IEnumCallingCard
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITCallNotificationEvent interface definition
;
Interface ITCallNotificationEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Call(a.l)
  get_Event(a.l)
  get_CallbackInstance(a.l)
EndInterface

; ITDispatchMapper interface definition
;
Interface ITDispatchMapper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  QueryDispatchInterface(a.p-bstr, b.l, c.l)
EndInterface

; ITStreamControl interface definition
;
Interface ITStreamControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CreateStream(a.l, b.l, c.l)
  RemoveStream(a.l)
  EnumerateStreams(a.l)
  get_Streams(a.l)
EndInterface

; ITStream interface definition
;
Interface ITStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_MediaType(a.l)
  get_Direction(a.l)
  get_Name(a.l)
  StartStream()
  PauseStream()
  StopStream()
  SelectTerminal(a.l)
  UnselectTerminal(a.l)
  EnumerateTerminals(a.l)
  get_Terminals(a.l)
EndInterface

; IEnumStream interface definition
;
Interface IEnumStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITSubStreamControl interface definition
;
Interface ITSubStreamControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CreateSubStream(a.l)
  RemoveSubStream(a.l)
  EnumerateSubStreams(a.l)
  get_SubStreams(a.l)
EndInterface

; ITSubStream interface definition
;
Interface ITSubStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StartSubStream()
  PauseSubStream()
  StopSubStream()
  SelectTerminal(a.l)
  UnselectTerminal(a.l)
  EnumerateTerminals(a.l)
  get_Terminals(a.l)
  get_Stream(a.l)
EndInterface

; IEnumSubStream interface definition
;
Interface IEnumSubStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITLegacyWaveSupport interface definition
;
Interface ITLegacyWaveSupport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  IsFullDuplex(a.l)
EndInterface

; ITBasicCallControl2 interface definition
;
Interface ITBasicCallControl2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Connect(a.l)
  Answer()
  Disconnect(a.l)
  Hold(a.l)
  HandoffDirect(a.p-bstr)
  HandoffIndirect(a.l)
  Conference(a.l, b.l)
  Transfer(a.l, b.l)
  BlindTransfer(a.p-bstr)
  SwapHold(a.l)
  ParkDirect(a.p-bstr)
  ParkIndirect(a.l)
  Unpark()
  SetQOS(a.l, b.l)
  Pickup(a.p-bstr)
  Dial(a.p-bstr)
  Finish(a.l)
  RemoveFromConference()
  RequestTerminal(a.p-bstr, b.l, c.l, d.l)
  SelectTerminalOnCall(a.l)
  UnselectTerminalOnCall(a.l)
EndInterface

; ITScriptableAudioFormat interface definition
;
Interface ITScriptableAudioFormat
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Channels(a.l)
  put_Channels(a.l)
  get_SamplesPerSec(a.l)
  put_SamplesPerSec(a.l)
  get_AvgBytesPerSec(a.l)
  put_AvgBytesPerSec(a.l)
  get_BlockAlign(a.l)
  put_BlockAlign(a.l)
  get_BitsPerSample(a.l)
  put_BitsPerSample(a.l)
  get_FormatTag(a.l)
  put_FormatTag(a.l)
EndInterface
