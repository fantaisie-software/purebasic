
; IBDA_NetworkProvider interface definition
;
Interface IBDA_NetworkProvider Extends IUnknown
  PutSignalSource(a.l)
  GetSignalSource(a.l)
  GetNetworkType(a.l)
  PutTuningSpace(a.l)
  GetTuningSpace(a.l)
  RegisterDeviceFilter(a.l, b.l)
  UnRegisterDeviceFilter(a.l)
EndInterface

; IBDA_EthernetFilter interface definition
;
Interface IBDA_EthernetFilter Extends IUnknown
  GetMulticastListSize(a.l)
  PutMulticastList(a.l, b.l)
  GetMulticastList(a.l, b.l)
  PutMulticastMode(a.l)
  GetMulticastMode(a.l)
EndInterface

; IBDA_IPV4Filter interface definition
;
Interface IBDA_IPV4Filter Extends IUnknown
  GetMulticastListSize(a.l)
  PutMulticastList(a.l, b.l)
  GetMulticastList(a.l, b.l)
  PutMulticastMode(a.l)
  GetMulticastMode(a.l)
EndInterface

; IBDA_IPV6Filter interface definition
;
Interface IBDA_IPV6Filter Extends IUnknown
  GetMulticastListSize(a.l)
  PutMulticastList(a.l, b.l)
  GetMulticastList(a.l, b.l)
  PutMulticastMode(a.l)
  GetMulticastMode(a.l)
EndInterface

; IBDA_DeviceControl interface definition
;
Interface IBDA_DeviceControl Extends IUnknown
  StartChanges()
  CheckChanges()
  CommitChanges()
  GetChangeState(a.l)
EndInterface

; IBDA_PinControl interface definition
;
Interface IBDA_PinControl Extends IUnknown
  GetPinID(a.l)
  GetPinType(a.l)
  RegistrationContext(a.l)
EndInterface

; IBDA_SignalProperties interface definition
;
Interface IBDA_SignalProperties Extends IUnknown
  PutNetworkType(a.l)
  GetNetworkType(a.l)
  PutSignalSource(a.l)
  GetSignalSource(a.l)
  PutTuningSpace(a.l)
  GetTuningSpace(a.l)
EndInterface

; IBDA_SignalStatistics interface definition
;
Interface IBDA_SignalStatistics Extends IUnknown
  put_SignalStrength(a.l)
  get_SignalStrength(a.l)
  put_SignalQuality(a.l)
  get_SignalQuality(a.l)
  put_SignalPresent(a.l)
  get_SignalPresent(a.l)
  put_SignalLocked(a.l)
  get_SignalLocked(a.l)
  put_SampleTime(a.l)
  get_SampleTime(a.l)
EndInterface

; IBDA_Topology interface definition
;
Interface IBDA_Topology Extends IUnknown
  GetNodeTypes(a.l, b.l, c.l)
  GetNodeDescriptors(a.l, b.l, c.l)
  GetNodeInterfaces(a.l, b.l, c.l, d.l)
  GetPinTypes(a.l, b.l, c.l)
  GetTemplateConnections(a.l, b.l, c.l)
  CreatePin(a.l, b.l)
  DeletePin(a.l)
  SetMediaType(a.l, b.l)
  SetMedium(a.l, b.l)
  CreateTopology(a.l, b.l)
  GetControlNode(a.l, b.l, c.l, d.l)
EndInterface

; IBDA_VoidTransform interface definition
;
Interface IBDA_VoidTransform Extends IUnknown
  Start()
  Stop()
EndInterface

; IBDA_NullTransform interface definition
;
Interface IBDA_NullTransform Extends IUnknown
  Start()
  Stop()
EndInterface

; IBDA_FrequencyFilter interface definition
;
Interface IBDA_FrequencyFilter Extends IUnknown
  put_Autotune(a.l)
  get_Autotune(a.l)
  put_Frequency(a.l)
  get_Frequency(a.l)
  put_Polarity(a.l)
  get_Polarity(a.l)
  put_Range(a.l)
  get_Range(a.l)
  put_Bandwidth(a.l)
  get_Bandwidth(a.l)
  put_FrequencyMultiplier(a.l)
  get_FrequencyMultiplier(a.l)
EndInterface

; IBDA_LNBInfo interface definition
;
Interface IBDA_LNBInfo Extends IUnknown
  put_LocalOscilatorFrequencyLowBand(a.l)
  get_LocalOscilatorFrequencyLowBand(a.l)
  put_LocalOscilatorFrequencyHighBand(a.l)
  get_LocalOscilatorFrequencyHighBand(a.l)
  put_HighLowSwitchFrequency(a.l)
  get_HighLowSwitchFrequency(a.l)
EndInterface

; IBDA_AutoDemodulate interface definition
;
Interface IBDA_AutoDemodulate Extends IUnknown
  put_AutoDemodulate()
EndInterface

; IBDA_DigitalDemodulator interface definition
;
Interface IBDA_DigitalDemodulator Extends IUnknown
  put_ModulationType(a.l)
  get_ModulationType(a.l)
  put_InnerFECMethod(a.l)
  get_InnerFECMethod(a.l)
  put_InnerFECRate(a.l)
  get_InnerFECRate(a.l)
  put_OuterFECMethod(a.l)
  get_OuterFECMethod(a.l)
  put_OuterFECRate(a.l)
  get_OuterFECRate(a.l)
  put_SymbolRate(a.l)
  get_SymbolRate(a.l)
  put_SpectralInversion(a.l)
  get_SpectralInversion(a.l)
EndInterface

; IBDA_IPSinkControl interface definition
;
Interface IBDA_IPSinkControl Extends IUnknown
  GetMulticastList(a.l, b.l)
  GetAdapterIPAddress(a.l, b.l)
EndInterface

; IBDA_IPSinkInfo interface definition
;
Interface IBDA_IPSinkInfo Extends IUnknown
  get_MulticastList(a.l, b.l)
  get_AdapterIPAddress(a.l)
  get_AdapterDescription(a.l)
EndInterface

; IEnumPIDMap interface definition
;
Interface IEnumPIDMap Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IMPEG2PIDMap interface definition
;
Interface IMPEG2PIDMap Extends IUnknown
  MapPID(a.l, b.l, c.l)
  UnmapPID(a.l, b.l)
  EnumPIDMap(a.l)
EndInterface

; IFrequencyMap interface definition
;
Interface IFrequencyMap Extends IUnknown
  get_FrequencyMapping(a.l, b.l)
  put_FrequencyMapping(a.l, b.l)
  get_CountryCode(a.l)
  put_CountryCode(a.l)
  get_DefaultFrequencyMapping(a.l, b.l, c.l)
  get_CountryCodeList(a.l, b.l)
EndInterface
