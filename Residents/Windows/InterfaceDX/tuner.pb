
; ITuningSpaces interface definition
;
Interface ITuningSpaces Extends IDispatch
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  get_EnumTuningSpaces(a.l)
EndInterface

; ITuningSpaceContainer interface definition
;
Interface ITuningSpaceContainer Extends IDispatch
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  put_Item(a.p-variant, b.l)
  TuningSpacesForCLSID(a.p-bstr, b.l)
  _TuningSpacesForCLSID(a.l, b.l)
  TuningSpacesForName(a.p-bstr, b.l)
  FindID(a.l, b.l)
  Add(a.l, b.l)
  get_EnumTuningSpaces(a.l)
  Remove(a.p-variant)
  get_MaxCount(a.l)
  put_MaxCount(a.l)
EndInterface

; ITuningSpace interface definition
;
Interface ITuningSpace Extends IDispatch
  get_UniqueName(a.l)
  put_UniqueName(a.p-bstr)
  get_FriendlyName(a.l)
  put_FriendlyName(a.p-bstr)
  get_CLSID(a.l)
  get_NetworkType(a.l)
  put_NetworkType(a.p-bstr)
  get__NetworkType(a.l)
  put__NetworkType(a.l)
  CreateTuneRequest(a.l)
  EnumCategoryGUIDs(a.l)
  EnumDeviceMonikers(a.l)
  get_DefaultPreferredComponentTypes(a.l)
  put_DefaultPreferredComponentTypes(a.l)
  get_FrequencyMapping(a.l)
  put_FrequencyMapping(a.p-bstr)
  get_DefaultLocator(a.l)
  put_DefaultLocator(a.l)
  Clone(a.l)
EndInterface

; IEnumTuningSpaces interface definition
;
Interface IEnumTuningSpaces Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IDVBTuningSpace interface definition
;
Interface IDVBTuningSpace Extends ITuningSpace
  get_SystemType(a.l)
  put_SystemType(a.l)
EndInterface

; IDVBTuningSpace2 interface definition
;
Interface IDVBTuningSpace2 Extends IDVBTuningSpace
  get_NetworkID(a.l)
  put_NetworkID(a.l)
EndInterface

; IDVBSTuningSpace interface definition
;
Interface IDVBSTuningSpace Extends IDVBTuningSpace2
  get_LowOscillator(a.l)
  put_LowOscillator(a.l)
  get_HighOscillator(a.l)
  put_HighOscillator(a.l)
  get_LNBSwitch(a.l)
  put_LNBSwitch(a.l)
  get_InputRange(a.l)
  put_InputRange(a.p-bstr)
  get_SpectralInversion(a.l)
  put_SpectralInversion(a.l)
EndInterface

; IAuxInTuningSpace interface definition
;
Interface IAuxInTuningSpace Extends ITuningSpace
EndInterface

; IAnalogTVTuningSpace interface definition
;
Interface IAnalogTVTuningSpace Extends ITuningSpace
  get_MinChannel(a.l)
  put_MinChannel(a.l)
  get_MaxChannel(a.l)
  put_MaxChannel(a.l)
  get_InputType(a.l)
  put_InputType(a.l)
  get_CountryCode(a.l)
  put_CountryCode(a.l)
EndInterface

; IATSCTuningSpace interface definition
;
Interface IATSCTuningSpace Extends IAnalogTVTuningSpace
  get_MinMinorChannel(a.l)
  put_MinMinorChannel(a.l)
  get_MaxMinorChannel(a.l)
  put_MaxMinorChannel(a.l)
  get_MinPhysicalChannel(a.l)
  put_MinPhysicalChannel(a.l)
  get_MaxPhysicalChannel(a.l)
  put_MaxPhysicalChannel(a.l)
EndInterface

; IAnalogRadioTuningSpace interface definition
;
Interface IAnalogRadioTuningSpace Extends ITuningSpace
  get_MinFrequency(a.l)
  put_MinFrequency(a.l)
  get_MaxFrequency(a.l)
  put_MaxFrequency(a.l)
  get_Step(a.l)
  put_Step(a.l)
EndInterface

; ITuneRequest interface definition
;
Interface ITuneRequest Extends IDispatch
  get_TuningSpace(a.l)
  get_Components(a.l)
  Clone(a.l)
  get_Locator(a.l)
  put_Locator(a.l)
EndInterface

; IChannelTuneRequest interface definition
;
Interface IChannelTuneRequest Extends ITuneRequest
  get_Channel(a.l)
  put_Channel(a.l)
EndInterface

; IATSCChannelTuneRequest interface definition
;
Interface IATSCChannelTuneRequest Extends IChannelTuneRequest
  get_MinorChannel(a.l)
  put_MinorChannel(a.l)
EndInterface

; IDVBTuneRequest interface definition
;
Interface IDVBTuneRequest Extends ITuneRequest
  get_ONID(a.l)
  put_ONID(a.l)
  get_TSID(a.l)
  put_TSID(a.l)
  get_SID(a.l)
  put_SID(a.l)
EndInterface

; IMPEG2TuneRequest interface definition
;
Interface IMPEG2TuneRequest Extends ITuneRequest
  get_TSID(a.l)
  put_TSID(a.l)
  get_ProgNo(a.l)
  put_ProgNo(a.l)
EndInterface

; IMPEG2TuneRequestFactory interface definition
;
Interface IMPEG2TuneRequestFactory Extends IDispatch
  CreateTuneRequest(a.l, b.l)
EndInterface

; IMPEG2TuneRequestSupport interface definition
;
Interface IMPEG2TuneRequestSupport Extends IUnknown
EndInterface

; ITuner interface definition
;
Interface ITuner Extends IUnknown
  get_TuningSpace(a.l)
  put_TuningSpace(a.l)
  EnumTuningSpaces(a.l)
  get_TuneRequest(a.l)
  put_TuneRequest(a.l)
  Validate(a.l)
  get_PreferredComponentTypes(a.l)
  put_PreferredComponentTypes(a.l)
  get_SignalStrength(a.l)
  TriggerSignalEvents(a.l)
EndInterface

; IScanningTuner interface definition
;
Interface IScanningTuner Extends ITuner
  SeekUp()
  SeekDown()
  ScanUp(a.l)
  ScanDown(a.l)
  AutoProgram()
EndInterface

; IComponentType interface definition
;
Interface IComponentType Extends IDispatch
  get_Category(a.l)
  put_Category(a.l)
  get_MediaMajorType(a.l)
  put_MediaMajorType(a.p-bstr)
  get__MediaMajorType(a.l)
  put__MediaMajorType(a.l)
  get_MediaSubType(a.l)
  put_MediaSubType(a.p-bstr)
  get__MediaSubType(a.l)
  put__MediaSubType(a.l)
  get_MediaFormatType(a.l)
  put_MediaFormatType(a.p-bstr)
  get__MediaFormatType(a.l)
  put__MediaFormatType(a.l)
  get_MediaType(a.l)
  put_MediaType(a.l)
  Clone(a.l)
EndInterface

; ILanguageComponentType interface definition
;
Interface ILanguageComponentType Extends IComponentType
  get_LangID(a.l)
  put_LangID(a.l)
EndInterface

; IMPEG2ComponentType interface definition
;
Interface IMPEG2ComponentType Extends ILanguageComponentType
  get_StreamType(a.l)
  put_StreamType(a.l)
EndInterface

; IATSCComponentType interface definition
;
Interface IATSCComponentType Extends IMPEG2ComponentType
  get_Flags(a.l)
  put_Flags(a.l)
EndInterface

; IEnumComponentTypes interface definition
;
Interface IEnumComponentTypes Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IComponentTypes interface definition
;
Interface IComponentTypes Extends IDispatch
  get_Count(a.l)
  get__NewEnum(a.l)
  EnumComponentTypes(a.l)
  get_Item(a.p-variant, b.l)
  put_Item(a.p-variant, b.l)
  Add(a.l, b.l)
  Remove(a.p-variant)
  Clone(a.l)
EndInterface

; IComponent interface definition
;
Interface IComponent Extends IDispatch
  get_Type(a.l)
  put_Type(a.l)
  get_DescLangID(a.l)
  put_DescLangID(a.l)
  get_Status(a.l)
  put_Status(a.l)
  get_Description(a.l)
  put_Description(a.p-bstr)
  Clone(a.l)
EndInterface

; IMPEG2Component interface definition
;
Interface IMPEG2Component Extends IComponent
  get_PID(a.l)
  put_PID(a.l)
  get_PCRPID(a.l)
  put_PCRPID(a.l)
  get_ProgramNumber(a.l)
  put_ProgramNumber(a.l)
EndInterface

; IEnumComponents interface definition
;
Interface IEnumComponents Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IComponents interface definition
;
Interface IComponents Extends IDispatch
  get_Count(a.l)
  get__NewEnum(a.l)
  EnumComponents(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l, b.l)
  Remove(a.p-variant)
  Clone(a.l)
EndInterface

; ILocator interface definition
;
Interface ILocator Extends IDispatch
  get_CarrierFrequency(a.l)
  put_CarrierFrequency(a.l)
  get_InnerFEC(a.l)
  put_InnerFEC(a.l)
  get_InnerFECRate(a.l)
  put_InnerFECRate(a.l)
  get_OuterFEC(a.l)
  put_OuterFEC(a.l)
  get_OuterFECRate(a.l)
  put_OuterFECRate(a.l)
  get_Modulation(a.l)
  put_Modulation(a.l)
  get_SymbolRate(a.l)
  put_SymbolRate(a.l)
  Clone(a.l)
EndInterface

; IATSCLocator interface definition
;
Interface IATSCLocator Extends ILocator
  get_PhysicalChannel(a.l)
  put_PhysicalChannel(a.l)
  get_TSID(a.l)
  put_TSID(a.l)
EndInterface

; IDVBTLocator interface definition
;
Interface IDVBTLocator Extends ILocator
  get_Bandwidth(a.l)
  put_Bandwidth(a.l)
  get_LPInnerFEC(a.l)
  put_LPInnerFEC(a.l)
  get_LPInnerFECRate(a.l)
  put_LPInnerFECRate(a.l)
  get_HAlpha(a.l)
  put_HAlpha(a.l)
  get_Guard(a.l)
  put_Guard(a.l)
  get_Mode(a.l)
  put_Mode(a.l)
  get_OtherFrequencyInUse(a.l)
  put_OtherFrequencyInUse(a.l)
EndInterface

; IDVBSLocator interface definition
;
Interface IDVBSLocator Extends ILocator
  get_SignalPolarisation(a.l)
  put_SignalPolarisation(a.l)
  get_WestPosition(a.l)
  put_WestPosition(a.l)
  get_OrbitalPosition(a.l)
  put_OrbitalPosition(a.l)
  get_Azimuth(a.l)
  put_Azimuth(a.l)
  get_Elevation(a.l)
  put_Elevation(a.l)
EndInterface

; IDVBCLocator interface definition
;
Interface IDVBCLocator Extends ILocator
EndInterface

; IBroadcastEvent interface definition
;
Interface IBroadcastEvent Extends IUnknown
  Fire(a.l)
EndInterface
