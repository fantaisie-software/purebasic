
; IAMCollection interface definition
;
Interface IAMCollection
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  Item(a.l, b.l)
  get__NewEnum(a.l)
EndInterface

; IMediaControl interface definition
;
Interface IMediaControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Run()
  Pause()
  Stop()
  GetState(a.l, b.l)
  RenderFile(a.p-bstr)
  AddSourceFilter(a.p-bstr, b.l)
  get_FilterCollection(a.l)
  get_RegFilterCollection(a.l)
  StopWhenReady()
EndInterface

; IMediaEvent interface definition
;
Interface IMediaEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetEventHandle(a.l)
  GetEvent(a.l, b.l, c.l, d.l)
  WaitForCompletion(a.l, b.l)
  CancelDefaultHandling(a.l)
  RestoreDefaultHandling(a.l)
  FreeEventParams(a.l, b.l, c.l)
EndInterface

; IMediaEventEx interface definition
;
Interface IMediaEventEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetEventHandle(a.l)
  GetEvent(a.l, b.l, c.l, d.l)
  WaitForCompletion(a.l, b.l)
  CancelDefaultHandling(a.l)
  RestoreDefaultHandling(a.l)
  FreeEventParams(a.l, b.l, c.l)
  SetNotifyWindow(a.l, b.l, c.l)
  SetNotifyFlags(a.l)
  GetNotifyFlags(a.l)
EndInterface

; IMediaPosition interface definition
;
Interface IMediaPosition
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Duration(a.l)
  put_CurrentPosition(a.l)
  get_CurrentPosition(a.l)
  get_StopTime(a.l)
  put_StopTime(a.l)
  get_PrerollTime(a.l)
  put_PrerollTime(a.l)
  put_Rate(a.d)
  get_Rate(a.l)
  CanSeekForward(a.l)
  CanSeekBackward(a.l)
EndInterface

; IBasicAudio interface definition
;
Interface IBasicAudio
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

; IVideoWindow interface definition
;
Interface IVideoWindow
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  put_Caption(a.p-bstr)
  get_Caption(a.l)
  put_WindowStyle(a.l)
  get_WindowStyle(a.l)
  put_WindowStyleEx(a.l)
  get_WindowStyleEx(a.l)
  put_AutoShow(a.l)
  get_AutoShow(a.l)
  put_WindowState(a.l)
  get_WindowState(a.l)
  put_BackgroundPalette(a.l)
  get_BackgroundPalette(a.l)
  put_Visible(a.l)
  get_Visible(a.l)
  put_Left(a.l)
  get_Left(a.l)
  put_Width(a.l)
  get_Width(a.l)
  put_Top(a.l)
  get_Top(a.l)
  put_Height(a.l)
  get_Height(a.l)
  put_Owner(a.l)
  get_Owner(a.l)
  put_MessageDrain(a.l)
  get_MessageDrain(a.l)
  get_BorderColor(a.l)
  put_BorderColor(a.l)
  get_FullScreenMode(a.l)
  put_FullScreenMode(a.l)
  SetWindowForeground(a.l)
  NotifyOwnerMessage(a.l, b.l, c.l, d.l)
  SetWindowPosition(a.l, b.l, c.l, d.l)
  GetWindowPosition(a.l, b.l, c.l, d.l)
  GetMinIdealImageSize(a.l, b.l)
  GetMaxIdealImageSize(a.l, b.l)
  GetRestorePosition(a.l, b.l, c.l, d.l)
  HideCursor(a.l)
  IsCursorHidden(a.l)
EndInterface

; IBasicVideo interface definition
;
Interface IBasicVideo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_AvgTimePerFrame(a.l)
  get_BitRate(a.l)
  get_BitErrorRate(a.l)
  get_VideoWidth(a.l)
  get_VideoHeight(a.l)
  put_SourceLeft(a.l)
  get_SourceLeft(a.l)
  put_SourceWidth(a.l)
  get_SourceWidth(a.l)
  put_SourceTop(a.l)
  get_SourceTop(a.l)
  put_SourceHeight(a.l)
  get_SourceHeight(a.l)
  put_DestinationLeft(a.l)
  get_DestinationLeft(a.l)
  put_DestinationWidth(a.l)
  get_DestinationWidth(a.l)
  put_DestinationTop(a.l)
  get_DestinationTop(a.l)
  put_DestinationHeight(a.l)
  get_DestinationHeight(a.l)
  SetSourcePosition(a.l, b.l, c.l, d.l)
  GetSourcePosition(a.l, b.l, c.l, d.l)
  SetDefaultSourcePosition()
  SetDestinationPosition(a.l, b.l, c.l, d.l)
  GetDestinationPosition(a.l, b.l, c.l, d.l)
  SetDefaultDestinationPosition()
  GetVideoSize(a.l, b.l)
  GetVideoPaletteEntries(a.l, b.l, c.l, d.l)
  GetCurrentImage(a.l, b.l)
  IsUsingDefaultSource()
  IsUsingDefaultDestination()
EndInterface

; IBasicVideo2 interface definition
;
Interface IBasicVideo2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_AvgTimePerFrame(a.l)
  get_BitRate(a.l)
  get_BitErrorRate(a.l)
  get_VideoWidth(a.l)
  get_VideoHeight(a.l)
  put_SourceLeft(a.l)
  get_SourceLeft(a.l)
  put_SourceWidth(a.l)
  get_SourceWidth(a.l)
  put_SourceTop(a.l)
  get_SourceTop(a.l)
  put_SourceHeight(a.l)
  get_SourceHeight(a.l)
  put_DestinationLeft(a.l)
  get_DestinationLeft(a.l)
  put_DestinationWidth(a.l)
  get_DestinationWidth(a.l)
  put_DestinationTop(a.l)
  get_DestinationTop(a.l)
  put_DestinationHeight(a.l)
  get_DestinationHeight(a.l)
  SetSourcePosition(a.l, b.l, c.l, d.l)
  GetSourcePosition(a.l, b.l, c.l, d.l)
  SetDefaultSourcePosition()
  SetDestinationPosition(a.l, b.l, c.l, d.l)
  GetDestinationPosition(a.l, b.l, c.l, d.l)
  SetDefaultDestinationPosition()
  GetVideoSize(a.l, b.l)
  GetVideoPaletteEntries(a.l, b.l, c.l, d.l)
  GetCurrentImage(a.l, b.l)
  IsUsingDefaultSource()
  IsUsingDefaultDestination()
  GetPreferredAspectRatio(a.l, b.l)
EndInterface

; IDeferredCommand interface definition
;
Interface IDeferredCommand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Cancel()
  Confidence(a.l)
  Postpone(a.l)
  GetHResult(a.l)
EndInterface

; IQueueCommand interface definition
;
Interface IQueueCommand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InvokeAtStreamTime(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  InvokeAtPresentationTime(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
EndInterface

; IFilterInfo interface definition
;
Interface IFilterInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  FindPin(a.p-bstr, b.l)
  get_Name(a.l)
  get_VendorInfo(a.l)
  get_Filter(a.l)
  get_Pins(a.l)
  get_IsFileSource(a.l)
  get_Filename(a.l)
  put_Filename(a.p-bstr)
EndInterface

; IRegFilterInfo interface definition
;
Interface IRegFilterInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  Filter(a.l)
EndInterface

; IMediaTypeInfo interface definition
;
Interface IMediaTypeInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Type(a.l)
  get_Subtype(a.l)
EndInterface

; IPinInfo interface definition
;
Interface IPinInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Pin(a.l)
  get_ConnectedTo(a.l)
  get_ConnectionMediaType(a.l)
  get_FilterInfo(a.l)
  get_Name(a.l)
  get_Direction(a.l)
  get_PinID(a.l)
  get_MediaTypes(a.l)
  Connect(a.l)
  ConnectDirect(a.l)
  ConnectWithType(a.l, b.l)
  Disconnect()
  Render()
EndInterface

; IAMStats interface definition
;
Interface IAMStats
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Reset()
  get_Count(a.l)
  GetValueByIndex(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetValueByName(a.p-bstr, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  GetIndex(a.p-bstr, b.l, c.l)
  AddValue(a.l, b.d)
EndInterface
