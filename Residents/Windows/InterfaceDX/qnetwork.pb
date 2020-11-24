
; IAMNetShowConfig interface definition
;
Interface IAMNetShowConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_BufferingTime(a.l)
  put_BufferingTime(a.d)
  get_UseFixedUDPPort(a.l)
  put_UseFixedUDPPort(a.l)
  get_FixedUDPPort(a.l)
  put_FixedUDPPort(a.l)
  get_UseHTTPProxy(a.l)
  put_UseHTTPProxy(a.l)
  get_EnableAutoProxy(a.l)
  put_EnableAutoProxy(a.l)
  get_HTTPProxyHost(a.l)
  put_HTTPProxyHost(a.l)
  get_HTTPProxyPort(a.l)
  put_HTTPProxyPort(a.l)
  get_EnableMulticast(a.l)
  put_EnableMulticast(a.l)
  get_EnableUDP(a.l)
  put_EnableUDP(a.l)
  get_EnableTCP(a.l)
  put_EnableTCP(a.l)
  get_EnableHTTP(a.l)
  put_EnableHTTP(a.l)
EndInterface

; IAMChannelInfo interface definition
;
Interface IAMChannelInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_ChannelName(a.l)
  get_ChannelDescription(a.l)
  get_ChannelURL(a.l)
  get_ContactAddress(a.l)
  get_ContactPhone(a.l)
  get_ContactEmail(a.l)
EndInterface

; IAMNetworkStatus interface definition
;
Interface IAMNetworkStatus
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_ReceivedPackets(a.l)
  get_RecoveredPackets(a.l)
  get_LostPackets(a.l)
  get_ReceptionQuality(a.l)
  get_BufferingCount(a.l)
  get_IsBroadcast(a.l)
  get_BufferingProgress(a.l)
EndInterface

; IAMExtendedSeeking interface definition
;
Interface IAMExtendedSeeking
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_ExSeekCapabilities(a.l)
  get_MarkerCount(a.l)
  get_CurrentMarker(a.l)
  GetMarkerTime(a.l, b.l)
  GetMarkerName(a.l, b.l)
  put_PlaybackSpeed(a.d)
  get_PlaybackSpeed(a.l)
EndInterface

; IAMNetShowExProps interface definition
;
Interface IAMNetShowExProps
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_SourceProtocol(a.l)
  get_Bandwidth(a.l)
  get_ErrorCorrection(a.l)
  get_CodecCount(a.l)
  GetCodecInstalled(a.l, b.l)
  GetCodecDescription(a.l, b.l)
  GetCodecURL(a.l, b.l)
  get_CreationDate(a.l)
  get_SourceLink(a.l)
EndInterface

; IAMExtendedErrorInfo interface definition
;
Interface IAMExtendedErrorInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_HasError(a.l)
  get_ErrorDescription(a.l)
  get_ErrorCode(a.l)
EndInterface

; IAMMediaContent interface definition
;
Interface IAMMediaContent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_AuthorName(a.l)
  get_Title(a.l)
  get_Rating(a.l)
  get_Description(a.l)
  get_Copyright(a.l)
  get_BaseURL(a.l)
  get_LogoURL(a.l)
  get_LogoIconURL(a.l)
  get_WatermarkURL(a.l)
  get_MoreInfoURL(a.l)
  get_MoreInfoBannerImage(a.l)
  get_MoreInfoBannerURL(a.l)
  get_MoreInfoText(a.l)
EndInterface

; IAMMediaContent2 interface definition
;
Interface IAMMediaContent2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_MediaParameter(a.l, b.l, c.l)
  get_MediaParameterName(a.l, b.l, c.l)
  get_PlaylistCount(a.l)
EndInterface

; IAMNetShowPreroll interface definition
;
Interface IAMNetShowPreroll
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_Preroll(a.l)
  get_Preroll(a.l)
EndInterface

; IDShowPlugin interface definition
;
Interface IDShowPlugin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_URL(a.l)
  get_UserAgent(a.l)
EndInterface
