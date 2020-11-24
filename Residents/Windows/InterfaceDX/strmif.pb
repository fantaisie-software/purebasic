
; ICreateDevEnum interface definition
;
Interface ICreateDevEnum
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateClassEnumerator(a.l, b.l, c.l)
EndInterface

; IPin interface definition
;
Interface IPin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l)
  ReceiveConnection(a.l, b.l)
  Disconnect()
  ConnectedTo(a.l)
  ConnectionMediaType(a.l)
  QueryPinInfo(a.l)
  QueryDirection(a.l)
  QueryId(a.l)
  QueryAccept(a.l)
  EnumMediaTypes(a.l)
  QueryInternalConnections(a.l, b.l)
  EndOfStream()
  BeginFlush()
  EndFlush()
  NewSegment(a.q, b.q, c.d)
EndInterface

; IEnumPins interface definition
;
Interface IEnumPins
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IEnumMediaTypes interface definition
;
Interface IEnumMediaTypes
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IFilterGraph interface definition
;
Interface IFilterGraph
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddFilter(a.l, b.l)
  RemoveFilter(a.l)
  EnumFilters(a.l)
  FindFilterByName(a.p-unicode, b.l)
  ConnectDirect(a.l, b.l, c.l)
  Reconnect(a.l)
  Disconnect(a.l)
  SetDefaultSyncSource()
EndInterface

; IEnumFilters interface definition
;
Interface IEnumFilters
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IMediaFilter interface definition
;
Interface IMediaFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  Stop()
  Pause()
  Run(a.q)
  GetState(a.l, b.l)
  SetSyncSource(a.l)
  GetSyncSource(a.l)
EndInterface

; IBaseFilter interface definition
;
Interface IBaseFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  Stop()
  Pause()
  Run(a.q)
  GetState(a.l, b.l)
  SetSyncSource(a.l)
  GetSyncSource(a.l)
  EnumPins(a.l)
  FindPin(a.l, b.l)
  QueryFilterInfo(a.l)
  JoinFilterGraph(a.l, b.l)
  QueryVendorInfo(a.l)
EndInterface

; IReferenceClock interface definition - Already defined in dmusicc.pb
;


; IReferenceClock2 interface definition
;
Interface IReferenceClock2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTime(a.l)
  AdviseTime(a.q, b.q, c.l, d.l)
  AdvisePeriodic(a.q, b.q, c.l, d.l)
  Unadvise(a.l)
EndInterface

; IMediaSample interface definition
;
Interface IMediaSample
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPointer(a.l)
  GetSize()
  GetTime(a.l, b.l)
  SetTime(a.l, b.l)
  IsSyncPoint()
  SetSyncPoint(a.l)
  IsPreroll()
  SetPreroll(a.l)
  GetActualDataLength()
  SetActualDataLength(a.l)
  GetMediaType(a.l)
  SetMediaType(a.l)
  IsDiscontinuity()
  SetDiscontinuity(a.l)
  GetMediaTime(a.l, b.l)
  SetMediaTime(a.l, b.l)
EndInterface

; IMediaSample2 interface definition
;
Interface IMediaSample2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPointer(a.l)
  GetSize()
  GetTime(a.l, b.l)
  SetTime(a.l, b.l)
  IsSyncPoint()
  SetSyncPoint(a.l)
  IsPreroll()
  SetPreroll(a.l)
  GetActualDataLength()
  SetActualDataLength(a.l)
  GetMediaType(a.l)
  SetMediaType(a.l)
  IsDiscontinuity()
  SetDiscontinuity(a.l)
  GetMediaTime(a.l, b.l)
  SetMediaTime(a.l, b.l)
  GetProperties(a.l, b.l)
  SetProperties(a.l, b.l)
EndInterface

; IMemAllocator interface definition
;
Interface IMemAllocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetProperties(a.l, b.l)
  GetProperties(a.l)
  Commit()
  Decommit()
  GetBuffer(a.l, b.l, c.l, d.l)
  ReleaseBuffer(a.l)
EndInterface

; IMemAllocatorCallbackTemp interface definition
;
Interface IMemAllocatorCallbackTemp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetProperties(a.l, b.l)
  GetProperties(a.l)
  Commit()
  Decommit()
  GetBuffer(a.l, b.l, c.l, d.l)
  ReleaseBuffer(a.l)
  SetNotify(a.l)
  GetFreeCount(a.l)
EndInterface

; IMemAllocatorNotifyCallbackTemp interface definition
;
Interface IMemAllocatorNotifyCallbackTemp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  NotifyRelease()
EndInterface

; IMemInputPin interface definition
;
Interface IMemInputPin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetAllocator(a.l)
  NotifyAllocator(a.l, b.l)
  GetAllocatorRequirements(a.l)
  Receive(a.l)
  ReceiveMultiple(a.l, b.l, c.l)
  ReceiveCanBlock()
EndInterface

; IAMovieSetup interface definition
;
Interface IAMovieSetup
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Register()
  Unregister()
EndInterface

; IMediaSeeking interface definition
;
Interface IMediaSeeking
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCapabilities(a.l)
  CheckCapabilities(a.l)
  IsFormatSupported(a.l)
  QueryPreferredFormat(a.l)
  GetTimeFormat(a.l)
  IsUsingTimeFormat(a.l)
  SetTimeFormat(a.l)
  GetDuration(a.l)
  GetStopPosition(a.l)
  GetCurrentPosition(a.l)
  ConvertTimeFormat(a.l, b.l, c.q, d.l)
  SetPositions(a.l, b.l, c.l, d.l)
  GetPositions(a.l, b.l)
  GetAvailable(a.l, b.l)
  SetRate(a.d)
  GetRate(a.l)
  GetPreroll(a.l)
EndInterface

; IEnumRegFilters interface definition
;
Interface IEnumRegFilters
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IFilterMapper interface definition
;
Interface IFilterMapper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RegisterFilter(a.l, b.l, c.l)
  RegisterFilterInstance(a.l, b.l, c.l)
  RegisterPin(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  RegisterPinType(a.l, b.l, c.l, d.l)
  UnregisterFilter(a.l)
  UnregisterFilterInstance(a.l)
  UnregisterPin(a.l, b.l)
  EnumMatchingFilters(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
EndInterface

; IFilterMapper2 interface definition
;
Interface IFilterMapper2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateCategory(a.l, b.l, c.l)
  UnregisterFilter(a.l, b.p-unicode, c.l)
  RegisterFilter(a.l, b.l, c.l, d.l, e.p-unicode, f.l)
  EnumMatchingFilters(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l, l.l, m.l, n.l, o.l)
EndInterface

; IFilterMapper3 interface definition
;
Interface IFilterMapper3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateCategory(a.l, b.l, c.l)
  UnregisterFilter(a.l, b.p-unicode, c.l)
  RegisterFilter(a.l, b.l, c.l, d.l, e.p-unicode, f.l)
  EnumMatchingFilters(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l, l.l, m.l, n.l, o.l)
  GetICreateDevEnum(a.l)
EndInterface

; IQualityControl interface definition
;
Interface IQualityControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Notify(a.l, b.l)
  SetSink(a.l)
EndInterface

; IOverlayNotify interface definition
;
Interface IOverlayNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnPaletteChange(a.l, b.l)
  OnClipChange(a.l, b.l, c.l)
  OnColorKeyChange(a.l)
  OnPositionChange(a.l, b.l)
EndInterface

; IOverlayNotify2 interface definition
;
Interface IOverlayNotify2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnPaletteChange(a.l, b.l)
  OnClipChange(a.l, b.l, c.l)
  OnColorKeyChange(a.l)
  OnPositionChange(a.l, b.l)
  OnDisplayChange(a.l)
EndInterface

; IOverlay interface definition
;
Interface IOverlay
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPalette(a.l, b.l)
  SetPalette(a.l, b.l)
  GetDefaultColorKey(a.l)
  GetColorKey(a.l)
  SetColorKey(a.l)
  GetWindowHandle(a.l)
  GetClipList(a.l, b.l, c.l)
  GetVideoPosition(a.l, b.l)
  Advise(a.l, b.l)
  Unadvise()
EndInterface

; IMediaEventSink interface definition
;
Interface IMediaEventSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Notify(a.l, b.l, c.l)
EndInterface

; IFileSourceFilter interface definition
;
Interface IFileSourceFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Load(a.l, b.l)
  GetCurFile(a.l, b.l)
EndInterface

; IFileSinkFilter interface definition
;
Interface IFileSinkFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFileName(a.p-unicode, b.l)
  GetCurFile(a.l, b.l)
EndInterface

; IFileSinkFilter2 interface definition
;
Interface IFileSinkFilter2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFileName(a.p-unicode, b.l)
  GetCurFile(a.l, b.l)
  SetMode(a.l)
  GetMode(a.l)
EndInterface

; IGraphBuilder interface definition
;
Interface IGraphBuilder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddFilter(a.l, b.l)
  RemoveFilter(a.l)
  EnumFilters(a.l)
  FindFilterByName(a.p-unicode, b.l)
  ConnectDirect(a.l, b.l, c.l)
  Reconnect(a.l)
  Disconnect(a.l)
  SetDefaultSyncSource()
  Connect(a.l, b.l)
  Render(a.l)
  RenderFile(a.l, b.l)
  AddSourceFilter(a.l, b.l, c.l)
  SetLogFile(a.l)
  Abort()
  ShouldOperationContinue()
EndInterface

; ICaptureGraphBuilder interface definition
;
Interface ICaptureGraphBuilder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFiltergraph(a.l)
  GetFiltergraph(a.l)
  SetOutputFileName(a.l, b.p-unicode, c.l, d.l)
  FindInterface(a.l, b.l, c.l, d.l)
  RenderStream(a.l, b.l, c.l, d.l)
  ControlStream(a.l, b.l, c.l, d.l, e.l, f.l)
  AllocCapFile(a.l, b.l)
  CopyCaptureFile(a.p-unicode, b.p-unicode, c.l, d.l)
EndInterface

; IAMCopyCaptureFileProgress interface definition
;
Interface IAMCopyCaptureFileProgress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Progress(a.l)
EndInterface

; ICaptureGraphBuilder2 interface definition
;
Interface ICaptureGraphBuilder2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFiltergraph(a.l)
  GetFiltergraph(a.l)
  SetOutputFileName(a.l, b.p-unicode, c.l, d.l)
  FindInterface(a.l, b.l, c.l, d.l, e.l)
  RenderStream(a.l, b.l, c.l, d.l, e.l)
  ControlStream(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  AllocCapFile(a.l, b.q)
  CopyCaptureFile(a.p-unicode, b.p-unicode, c.l, d.l)
  FindPin(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IFilterGraph2 interface definition
;
Interface IFilterGraph2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddFilter(a.l, b.l)
  RemoveFilter(a.l)
  EnumFilters(a.l)
  FindFilterByName(a.p-unicode, b.l)
  ConnectDirect(a.l, b.l, c.l)
  Reconnect(a.l)
  Disconnect(a.l)
  SetDefaultSyncSource()
  Connect(a.l, b.l)
  Render(a.l)
  RenderFile(a.l, b.l)
  AddSourceFilter(a.l, b.l, c.l)
  SetLogFile(a.l)
  Abort()
  ShouldOperationContinue()
  AddSourceFilterForMoniker(a.l, b.l, c.l, d.l)
  ReconnectEx(a.l, b.l)
  RenderEx(a.l, b.l, c.l)
EndInterface

; IStreamBuilder interface definition
;
Interface IStreamBuilder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Render(a.l, b.l)
  Backout(a.l, b.l)
EndInterface

; IAsyncReader interface definition
;
Interface IAsyncReader
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RequestAllocator(a.l, b.l, c.l)
  Request(a.l, b.l)
  WaitForNext(a.l, b.l, c.l)
  SyncReadAligned(a.l)
  SyncRead(a.q, b.l, c.l)
  Length(a.l, b.l)
  BeginFlush()
  EndFlush()
EndInterface

; IGraphVersion interface definition
;
Interface IGraphVersion
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryVersion(a.l)
EndInterface

; IResourceConsumer interface definition
;
Interface IResourceConsumer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AcquireResource(a.l)
  ReleaseResource(a.l)
EndInterface

; IResourceManager interface definition
;
Interface IResourceManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Register(a.l, b.l, c.l)
  RegisterGroup(a.l, b.l, c.l, d.l)
  RequestResource(a.l, b.l, c.l)
  NotifyAcquire(a.l, b.l, c.l)
  NotifyRelease(a.l, b.l, c.l)
  CancelRequest(a.l, b.l)
  SetFocus(a.l)
  ReleaseFocus(a.l)
EndInterface

; IDistributorNotify interface definition
;
Interface IDistributorNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Stop()
  Pause()
  Run(a.q)
  SetSyncSource(a.l)
  NotifyGraphChange()
EndInterface

; IAMStreamControl interface definition
;
Interface IAMStreamControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  StartAt(a.l, b.l)
  StopAt(a.l, b.l, c.l)
  GetInfo(a.l)
EndInterface

; ISeekingPassThru interface definition
;
Interface ISeekingPassThru
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l)
EndInterface

; IAMStreamConfig interface definition
;
Interface IAMStreamConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFormat(a.l)
  GetFormat(a.l)
  GetNumberOfCapabilities(a.l, b.l)
  GetStreamCaps(a.l, b.l, c.l)
EndInterface

; IConfigInterleaving interface definition
;
Interface IConfigInterleaving
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_Mode(a.l)
  get_Mode(a.l)
  put_Interleaving(a.l, b.l)
  get_Interleaving(a.l, b.l)
EndInterface

; IConfigAviMux interface definition
;
Interface IConfigAviMux
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetMasterStream(a.l)
  GetMasterStream(a.l)
  SetOutputCompatibilityIndex(a.l)
  GetOutputCompatibilityIndex(a.l)
EndInterface

; IAMVideoCompression interface definition
;
Interface IAMVideoCompression
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_KeyFrameRate(a.l)
  get_KeyFrameRate(a.l)
  put_PFramesPerKeyFrame(a.l)
  get_PFramesPerKeyFrame(a.l)
  put_Quality(a.d)
  get_Quality(a.l)
  put_WindowSize(a.l)
  get_WindowSize(a.l)
  GetInfo(a.l, b.l, c.p-unicode, d.l, e.l, f.l, g.l, h.l)
  OverrideKeyFrame(a.l)
  OverrideFrameSize(a.l, b.l)
EndInterface

; IAMVfwCaptureDialogs interface definition
;
Interface IAMVfwCaptureDialogs
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  HasDialog(a.l)
  ShowDialog(a.l, b.l)
  SendDriverMessage(a.l, b.l, c.l, d.l)
EndInterface

; IAMVfwCompressDialogs interface definition
;
Interface IAMVfwCompressDialogs
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ShowDialog(a.l, b.l)
  GetState(a.l, b.l)
  SetState(a.l, b.l)
  SendDriverMessage(a.l, b.l, c.l)
EndInterface

; IAMDroppedFrames interface definition
;
Interface IAMDroppedFrames
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNumDropped(a.l)
  GetNumNotDropped(a.l)
  GetDroppedInfo(a.l, b.l, c.l)
  GetAverageFrameSize(a.l)
EndInterface

; IAMAudioInputMixer interface definition
;
Interface IAMAudioInputMixer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_Enable(a.l)
  get_Enable(a.l)
  put_Mono(a.l)
  get_Mono(a.l)
  put_MixLevel(a.d)
  get_MixLevel(a.l)
  put_Pan(a.d)
  get_Pan(a.l)
  put_Loudness(a.l)
  get_Loudness(a.l)
  put_Treble(a.d)
  get_Treble(a.l)
  get_TrebleRange(a.l)
  put_Bass(a.d)
  get_Bass(a.l)
  get_BassRange(a.l)
EndInterface

; IAMBufferNegotiation interface definition
;
Interface IAMBufferNegotiation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SuggestAllocatorProperties(a.l)
  GetAllocatorProperties(a.l)
EndInterface

; IAMAnalogVideoDecoder interface definition
;
Interface IAMAnalogVideoDecoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_AvailableTVFormats(a.l)
  put_TVFormat(a.l)
  get_TVFormat(a.l)
  get_HorizontalLocked(a.l)
  put_VCRHorizontalLocking(a.l)
  get_VCRHorizontalLocking(a.l)
  get_NumberOfLines(a.l)
  put_OutputEnable(a.l)
  get_OutputEnable(a.l)
EndInterface

; IAMVideoProcAmp interface definition
;
Interface IAMVideoProcAmp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetRange(a.l, b.l, c.l, d.l, e.l, f.l)
  Set(a.l, b.l, c.l)
  Get(a.l, b.l, c.l)
EndInterface

; IAMCameraControl interface definition
;
Interface IAMCameraControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetRange(a.l, b.l, c.l, d.l, e.l, f.l)
  Set(a.l, b.l, c.l)
  Get(a.l, b.l, c.l)
EndInterface

; IAMVideoControl interface definition
;
Interface IAMVideoControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l, b.l)
  SetMode(a.l, b.l)
  GetMode(a.l, b.l)
  GetCurrentActualFrameRate(a.l, b.l)
  GetMaxAvailableFrameRate(a.l, b.l, c.l, d.l)
  GetFrameRateList(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IAMCrossbar interface definition
;
Interface IAMCrossbar
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_PinCounts(a.l, b.l)
  CanRoute(a.l, b.l)
  Route(a.l, b.l)
  get_IsRoutedTo(a.l, b.l)
  get_CrossbarPinInfo(a.l, b.l, c.l, d.l)
EndInterface

; IAMTuner interface definition
;
Interface IAMTuner
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_Channel(a.l, b.l, c.l)
  get_Channel(a.l, b.l, c.l)
  ChannelMinMax(a.l, b.l)
  put_CountryCode(a.l)
  get_CountryCode(a.l)
  put_TuningSpace(a.l)
  get_TuningSpace(a.l)
  Logon(a.l)
  Logout()
  SignalPresent(a.l)
  put_Mode(a.l)
  get_Mode(a.l)
  GetAvailableModes(a.l)
  RegisterNotificationCallBack(a.l, b.l)
  UnRegisterNotificationCallBack(a.l)
EndInterface

; IAMTunerNotification interface definition
;
Interface IAMTunerNotification
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnEvent(a.l)
EndInterface

; IAMTVTuner interface definition
;
Interface IAMTVTuner
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_Channel(a.l, b.l, c.l)
  get_Channel(a.l, b.l, c.l)
  ChannelMinMax(a.l, b.l)
  put_CountryCode(a.l)
  get_CountryCode(a.l)
  put_TuningSpace(a.l)
  get_TuningSpace(a.l)
  Logon(a.l)
  Logout()
  SignalPresent(a.l)
  put_Mode(a.l)
  get_Mode(a.l)
  GetAvailableModes(a.l)
  RegisterNotificationCallBack(a.l, b.l)
  UnRegisterNotificationCallBack(a.l)
  get_AvailableTVFormats(a.l)
  get_TVFormat(a.l)
  AutoTune(a.l, b.l)
  StoreAutoTune()
  get_NumInputConnections(a.l)
  put_InputType(a.l, b.l)
  get_InputType(a.l, b.l)
  put_ConnectInput(a.l)
  get_ConnectInput(a.l)
  get_VideoFrequency(a.l)
  get_AudioFrequency(a.l)
EndInterface

; IBPCSatelliteTuner interface definition
;
Interface IBPCSatelliteTuner
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  put_Channel(a.l, b.l, c.l)
  get_Channel(a.l, b.l, c.l)
  ChannelMinMax(a.l, b.l)
  put_CountryCode(a.l)
  get_CountryCode(a.l)
  put_TuningSpace(a.l)
  get_TuningSpace(a.l)
  Logon(a.l)
  Logout()
  SignalPresent(a.l)
  put_Mode(a.l)
  get_Mode(a.l)
  GetAvailableModes(a.l)
  RegisterNotificationCallBack(a.l, b.l)
  UnRegisterNotificationCallBack(a.l)
  get_DefaultSubChannelTypes(a.l, b.l)
  put_DefaultSubChannelTypes(a.l, b.l)
  IsTapingPermitted()
EndInterface

; IAMTVAudio interface definition
;
Interface IAMTVAudio
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetHardwareSupportedTVAudioModes(a.l)
  GetAvailableTVAudioModes(a.l)
  get_TVAudioMode(a.l)
  put_TVAudioMode(a.l)
  RegisterNotificationCallBack(a.l, b.l)
  UnRegisterNotificationCallBack(a.l)
EndInterface

; IAMTVAudioNotification interface definition
;
Interface IAMTVAudioNotification
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnEvent(a.l)
EndInterface

; IAMAnalogVideoEncoder interface definition
;
Interface IAMAnalogVideoEncoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_AvailableTVFormats(a.l)
  put_TVFormat(a.l)
  get_TVFormat(a.l)
  put_CopyProtection(a.l)
  get_CopyProtection(a.l)
  put_CCEnable(a.l)
  get_CCEnable(a.l)
EndInterface

; IKsPropertySet interface definition - Already defined in dsound.pb
;

; IMediaPropertyBag interface definition
;
Interface IMediaPropertyBag
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Read(a.l, b.l, c.l)
  Write(a.l, b.l)
  EnumProperty(a.l, b.l, c.l)
EndInterface

; IPersistMediaPropertyBag interface definition
;
Interface IPersistMediaPropertyBag
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  InitNew()
  Load(a.l, b.l)
  Save(a.l, b.l, c.l)
EndInterface

; IAMPhysicalPinInfo interface definition
;
Interface IAMPhysicalPinInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPhysicalType(a.l, b.l)
EndInterface

; IAMExtDevice interface definition
;
Interface IAMExtDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCapability(a.l, b.l, c.l)
  get_ExternalDeviceID(a.l)
  get_ExternalDeviceVersion(a.l)
  put_DevicePower(a.l)
  get_DevicePower(a.l)
  Calibrate(a.l, b.l, c.l)
  put_DevicePort(a.l)
  get_DevicePort(a.l)
EndInterface

; IAMExtTransport interface definition
;
Interface IAMExtTransport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCapability(a.l, b.l, c.l)
  put_MediaState(a.l)
  get_MediaState(a.l)
  put_LocalControl(a.l)
  get_LocalControl(a.l)
  GetStatus(a.l, b.l)
  GetTransportBasicParameters(a.l, b.l, c.l)
  SetTransportBasicParameters(a.l, b.l, c.l)
  GetTransportVideoParameters(a.l, b.l)
  SetTransportVideoParameters(a.l, b.l)
  GetTransportAudioParameters(a.l, b.l)
  SetTransportAudioParameters(a.l, b.l)
  put_Mode(a.l)
  get_Mode(a.l)
  put_Rate(a.d)
  get_Rate(a.l)
  GetChase(a.l, b.l, c.l)
  SetChase(a.l, b.l, c.l)
  GetBump(a.l, b.l)
  SetBump(a.l, b.l)
  get_AntiClogControl(a.l)
  put_AntiClogControl(a.l)
  GetEditPropertySet(a.l, b.l)
  SetEditPropertySet(a.l, b.l)
  GetEditProperty(a.l, b.l, c.l)
  SetEditProperty(a.l, b.l, c.l)
  get_EditStart(a.l)
  put_EditStart(a.l)
EndInterface

; IAMTimecodeReader interface definition
;
Interface IAMTimecodeReader
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTCRMode(a.l, b.l)
  SetTCRMode(a.l, b.l)
  put_VITCLine(a.l)
  get_VITCLine(a.l)
  GetTimecode(a.l)
EndInterface

; IAMTimecodeGenerator interface definition
;
Interface IAMTimecodeGenerator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTCGMode(a.l, b.l)
  SetTCGMode(a.l, b.l)
  put_VITCLine(a.l)
  get_VITCLine(a.l)
  SetTimecode(a.l)
  GetTimecode(a.l)
EndInterface

; IAMTimecodeDisplay interface definition
;
Interface IAMTimecodeDisplay
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTCDisplayEnable(a.l)
  SetTCDisplayEnable(a.l)
  GetTCDisplay(a.l, b.l)
  SetTCDisplay(a.l, b.l)
EndInterface

; IAMDevMemoryAllocator interface definition
;
Interface IAMDevMemoryAllocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetInfo(a.l, b.l, c.l, d.l)
  CheckMemory(a.l)
  Alloc(a.l, b.l)
  Free(a.l)
  GetDevMemoryObject(a.l, b.l)
EndInterface

; IAMDevMemoryControl interface definition
;
Interface IAMDevMemoryControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryWriteSync()
  WriteSync()
  GetDevId(a.l)
EndInterface

; IAMStreamSelect interface definition
;
Interface IAMStreamSelect
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Count(a.l)
  Info(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Enable(a.l, b.l)
EndInterface

; IAMResourceControl interface definition
;
Interface IAMResourceControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Reserve(a.l, b.l)
EndInterface

; IAMClockAdjust interface definition
;
Interface IAMClockAdjust
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetClockDelta(a.q)
EndInterface

; IAMFilterMiscFlags interface definition
;
Interface IAMFilterMiscFlags
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMiscFlags()
EndInterface

; IDrawVideoImage interface definition
;
Interface IDrawVideoImage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DrawVideoImageBegin()
  DrawVideoImageEnd()
  DrawVideoImageDraw(a.l, b.l, c.l)
EndInterface

; IDecimateVideoImage interface definition
;
Interface IDecimateVideoImage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetDecimationImageSize(a.l, b.l)
  ResetDecimationImageSize()
EndInterface

; IAMVideoDecimationProperties interface definition
;
Interface IAMVideoDecimationProperties
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryDecimationUsage(a.l)
  SetDecimationUsage(a.l)
EndInterface

; IVideoFrameStep interface definition
;
Interface IVideoFrameStep
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Step(a.l, b.l)
  CanStep(a.l, b.l)
  CancelStep()
EndInterface

; IAMLatency interface definition
;
Interface IAMLatency
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLatency(a.l)
EndInterface

; IAMPushSource interface definition
;
Interface IAMPushSource
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLatency(a.l)
  GetPushSourceFlags(a.l)
  SetPushSourceFlags(a.l)
  SetStreamOffset(a.q)
  GetStreamOffset(a.l)
  GetMaxStreamOffset(a.l)
  SetMaxStreamOffset(a.q)
EndInterface

; IAMDeviceRemoval interface definition
;
Interface IAMDeviceRemoval
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DeviceInfo(a.l, b.l)
  Reassociate()
  Disassociate()
EndInterface

; IDVEnc interface definition
;
Interface IDVEnc
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_IFormatResolution(a.l, b.l, c.l, d.l, e.l)
  put_IFormatResolution(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IIPDVDec interface definition
;
Interface IIPDVDec
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_IPDisplay(a.l)
  put_IPDisplay(a.l)
EndInterface

; IDVRGB219 interface definition
;
Interface IDVRGB219
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRGB219(a.l)
EndInterface

; IDVSplitter interface definition
;
Interface IDVSplitter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DiscardAlternateVideoFrames(a.l)
EndInterface

; IAMAudioRendererStats interface definition
;
Interface IAMAudioRendererStats
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetStatParam(a.l, b.l, c.l)
EndInterface

; IAMGraphStreams interface definition
;
Interface IAMGraphStreams
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FindUpstreamInterface(a.l, b.l, c.l, d.l)
  SyncUsingStreamOffset(a.l)
  SetMaxGraphLatency(a.q)
EndInterface

; IAMOverlayFX interface definition
;
Interface IAMOverlayFX
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryOverlayFXCaps(a.l)
  SetOverlayFX(a.l)
  GetOverlayFX(a.l)
EndInterface

; IAMOpenProgress interface definition
;
Interface IAMOpenProgress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryProgress(a.l, b.l)
  AbortOperation()
EndInterface

; IMpeg2Demultiplexer interface definition
;
Interface IMpeg2Demultiplexer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateOutputPin(a.l, b.p-unicode, c.l)
  SetOutputPinMediaType(a.p-unicode, b.l)
  DeleteOutputPin(a.p-unicode)
EndInterface

; IEnumStreamIdMap interface definition
;
Interface IEnumStreamIdMap
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IMPEG2StreamIdMap interface definition
;
Interface IMPEG2StreamIdMap
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  MapStreamId(a.l, b.l, c.l, d.l)
  UnmapStreamId(a.l, b.l)
  EnumStreamIdMap(a.l)
EndInterface

; IRegisterServiceProvider interface definition
;
Interface IRegisterServiceProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RegisterService(a.l, b.l)
EndInterface

; IAMClockSlave interface definition
;
Interface IAMClockSlave
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetErrorTolerance(a.l)
  GetErrorTolerance(a.l)
EndInterface

; IAMGraphBuilderCallback interface definition
;
Interface IAMGraphBuilderCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SelectedFilter(a.l)
  CreatedFilter(a.l)
EndInterface

; ICodecAPI interface definition
;
Interface ICodecAPI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsSupported(a.l)
  IsModifiable(a.l)
  GetParameterRange(a.l, b.l, c.l, d.l)
  GetParameterValues(a.l, b.l, c.l)
  GetDefaultValue(a.l, b.l)
  GetValue(a.l, b.l)
  SetValue(a.l, b.l)
  RegisterForEvent(a.l, b.l)
  UnregisterForEvent(a.l)
  SetAllDefaults()
  SetValueWithNotify(a.l, b.l, c.l, d.l)
  SetAllDefaultsWithNotify(a.l, b.l)
  GetAllSettings(a.l)
  SetAllSettings(a.l)
  SetAllSettingsWithNotify(a.l, b.l, c.l)
EndInterface

; IGetCapabilitiesKey interface definition
;
Interface IGetCapabilitiesKey
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCapabilitiesKey(a.l)
EndInterface

; IEncoderAPI interface definition
;
Interface IEncoderAPI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsSupported(a.l)
  IsAvailable(a.l)
  GetParameterRange(a.l, b.l, c.l, d.l)
  GetParameterValues(a.l, b.l, c.l)
  GetDefaultValue(a.l, b.l)
  GetValue(a.l, b.l)
  SetValue(a.l, b.l)
EndInterface

; IVideoEncoder interface definition
;
Interface IVideoEncoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsSupported(a.l)
  IsAvailable(a.l)
  GetParameterRange(a.l, b.l, c.l, d.l)
  GetParameterValues(a.l, b.l, c.l)
  GetDefaultValue(a.l, b.l)
  GetValue(a.l, b.l)
  SetValue(a.l, b.l)
EndInterface

; IAMDecoderCaps interface definition
;
Interface IAMDecoderCaps
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDecoderCaps(a.l, b.l)
EndInterface

; IAMCertifiedOutputProtection interface definition
;
Interface IAMCertifiedOutputProtection
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  KeyExchange(a.l, b.l, c.l)
  SessionSequenceStart(a.l)
  ProtectionCommand(a.l)
  ProtectionStatus(a.l, b.l)
EndInterface

; IDvdControl interface definition
;
Interface IDvdControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  TitlePlay(a.l)
  ChapterPlay(a.l, b.l)
  TimePlay(a.l, b.l)
  StopForResume()
  GoUp()
  TimeSearch(a.l)
  ChapterSearch(a.l)
  PrevPGSearch()
  TopPGSearch()
  NextPGSearch()
  ForwardScan(a.d)
  BackwardScan(a.d)
  MenuCall(a.l)
  Resume()
  UpperButtonSelect()
  LowerButtonSelect()
  LeftButtonSelect()
  RightButtonSelect()
  ButtonActivate()
  ButtonSelectAndActivate(a.l)
  StillOff()
  PauseOn()
  PauseOff()
  MenuLanguageSelect(a.l)
  AudioStreamChange(a.l)
  SubpictureStreamChange(a.l, b.l)
  AngleChange(a.l)
  ParentalLevelSelect(a.l)
  ParentalCountrySelect(a.l)
  KaraokeAudioPresentationModeChange(a.l)
  VideoModePreferrence(a.l)
  SetRoot(a.l)
  MouseActivate(a.l)
  MouseSelect(a.l)
  ChapterPlayAutoStop(a.l, b.l, c.l)
EndInterface

; IDvdInfo interface definition
;
Interface IDvdInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCurrentDomain(a.l)
  GetCurrentLocation(a.l)
  GetTotalTitleTime(a.l)
  GetCurrentButton(a.l, b.l)
  GetCurrentAngle(a.l, b.l)
  GetCurrentAudio(a.l, b.l)
  GetCurrentSubpicture(a.l, b.l, c.l)
  GetCurrentUOPS(a.l)
  GetAllSPRMs(a.l)
  GetAllGPRMs(a.l)
  GetAudioLanguage(a.l, b.l)
  GetSubpictureLanguage(a.l, b.l)
  GetTitleAttributes(a.l, b.l)
  GetVMGAttributes(a.l)
  GetCurrentVideoAttributes(a.l)
  GetCurrentAudioAttributes(a.l)
  GetCurrentSubpictureAttributes(a.l)
  GetCurrentVolumeInfo(a.l, b.l, c.l, d.l)
  GetDVDTextInfo(a.l, b.l, c.l)
  GetPlayerParentalLevel(a.l, b.l)
  GetNumberOfChapters(a.l, b.l)
  GetTitleParentalLevels(a.l, b.l)
  GetRoot(a.l, b.l, c.l)
EndInterface

; IDvdCmd interface definition
;
Interface IDvdCmd
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  WaitForStart()
  WaitForEnd()
EndInterface

; IDvdState interface definition
;
Interface IDvdState
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDiscID(a.l)
  GetParentalLevel(a.l)
EndInterface

; IDvdControl2 interface definition
;
Interface IDvdControl2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  PlayTitle(a.l, b.l, c.l)
  PlayChapterInTitle(a.l, b.l, c.l, d.l)
  PlayAtTimeInTitle(a.l, b.l, c.l, d.l)
  Stop()
  ReturnFromSubmenu(a.l, b.l)
  PlayAtTime(a.l, b.l, c.l)
  PlayChapter(a.l, b.l, c.l)
  PlayPrevChapter(a.l, b.l)
  ReplayChapter(a.l, b.l)
  PlayNextChapter(a.l, b.l)
  PlayForwards(a.d, b.l, c.l)
  PlayBackwards(a.d, b.l, c.l)
  ShowMenu(a.l, b.l, c.l)
  Resume(a.l, b.l)
  SelectRelativeButton(a.l)
  ActivateButton()
  SelectButton(a.l)
  SelectAndActivateButton(a.l)
  StillOff()
  Pause(a.l)
  SelectAudioStream(a.l, b.l, c.l)
  SelectSubpictureStream(a.l, b.l, c.l)
  SetSubpictureState(a.l, b.l, c.l)
  SelectAngle(a.l, b.l, c.l)
  SelectParentalLevel(a.l)
  SelectParentalCountry(a.l)
  SelectKaraokeAudioPresentationMode(a.l)
  SelectVideoModePreference(a.l)
  SetDVDDirectory(a.l)
  ActivateAtPosition(a.l)
  SelectAtPosition(a.l)
  PlayChaptersAutoStop(a.l, b.l, c.l, d.l, e.l)
  AcceptParentalLevelChange(a.l)
  SetOption(a.l, b.l)
  SetState(a.l, b.l, c.l)
  PlayPeriodInTitleAutoStop(a.l, b.l, c.l, d.l, e.l)
  SetGPRM(a.l, b.l, c.l, d.l)
  SelectDefaultMenuLanguage(a.l)
  SelectDefaultAudioLanguage(a.l, b.l)
  SelectDefaultSubpictureLanguage(a.l, b.l)
EndInterface

; IDvdInfo2 interface definition
;
Interface IDvdInfo2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCurrentDomain(a.l)
  GetCurrentLocation(a.l)
  GetTotalTitleTime(a.l, b.l)
  GetCurrentButton(a.l, b.l)
  GetCurrentAngle(a.l, b.l)
  GetCurrentAudio(a.l, b.l)
  GetCurrentSubpicture(a.l, b.l, c.l)
  GetCurrentUOPS(a.l)
  GetAllSPRMs(a.l)
  GetAllGPRMs(a.l)
  GetAudioLanguage(a.l, b.l)
  GetSubpictureLanguage(a.l, b.l)
  GetTitleAttributes(a.l, b.l, c.l)
  GetVMGAttributes(a.l)
  GetCurrentVideoAttributes(a.l)
  GetAudioAttributes(a.l, b.l)
  GetKaraokeAttributes(a.l, b.l)
  GetSubpictureAttributes(a.l, b.l)
  GetDVDVolumeInfo(a.l, b.l, c.l, d.l)
  GetDVDTextNumberOfLanguages(a.l)
  GetDVDTextLanguageInfo(a.l, b.l, c.l, d.l)
  GetDVDTextStringAsNative(a.l, b.l, c.l, d.l, e.l, f.l)
  GetDVDTextStringAsUnicode(a.l, b.l, c.l, d.l, e.l, f.l)
  GetPlayerParentalLevel(a.l, b.l)
  GetNumberOfChapters(a.l, b.l)
  GetTitleParentalLevels(a.l, b.l)
  GetDVDDirectory(a.p-unicode, b.l, c.l)
  IsAudioStreamEnabled(a.l, b.l)
  GetDiscID(a.l, b.l)
  GetState(a.l)
  GetMenuLanguages(a.l, b.l, c.l)
  GetButtonAtPosition(a.l, b.l)
  GetCmdFromEvent(a.l, b.l)
  GetDefaultMenuLanguage(a.l)
  GetDefaultAudioLanguage(a.l, b.l)
  GetDefaultSubpictureLanguage(a.l, b.l)
  GetDecoderCaps(a.l)
  GetButtonRect(a.l, b.l)
  IsSubpictureStreamEnabled(a.l, b.l)
EndInterface

; IDvdGraphBuilder interface definition
;
Interface IDvdGraphBuilder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFiltergraph(a.l)
  GetDvdInterface(a.l, b.l)
  RenderDvdVideoVolume(a.l, b.l, c.l)
EndInterface

; IDDrawExclModeVideo interface definition
;
Interface IDDrawExclModeVideo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetDDrawObject(a.l)
  GetDDrawObject(a.l, b.l)
  SetDDrawSurface(a.l)
  GetDDrawSurface(a.l, b.l)
  SetDrawParameters(a.l, b.l)
  GetNativeVideoProps(a.l, b.l, c.l, d.l)
  SetCallbackInterface(a.l, b.l)
EndInterface

; IDDrawExclModeVideoCallback interface definition
;
Interface IDDrawExclModeVideoCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnUpdateOverlay(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  OnUpdateColorKey(a.l, b.l)
  OnUpdateSize(a.l, b.l, c.l, d.l)
EndInterface

; IPinConnection interface definition
;
Interface IPinConnection
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DynamicQueryAccept(a.l)
  NotifyEndOfStream(a.l)
  IsEndPin()
  DynamicDisconnect()
EndInterface

; IPinFlowControl interface definition
;
Interface IPinFlowControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Block(a.l, b.l)
EndInterface

; IGraphConfig interface definition
;
Interface IGraphConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Reconnect(a.l, b.l, c.l, d.l, e.l, f.l)
  Reconfigure(a.l, b.l, c.l, d.l)
  AddFilterToCache(a.l)
  EnumCacheFilter(a.l)
  RemoveFilterFromCache(a.l)
  GetStartTime(a.l)
  PushThroughData(a.l, b.l, c.l)
  SetFilterFlags(a.l, b.l)
  GetFilterFlags(a.l, b.l)
  RemoveFilterEx(a.l, b.l)
EndInterface

; IGraphConfigCallback interface definition
;
Interface IGraphConfigCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Reconfigure(a.l, b.l)
EndInterface

; IFilterChain interface definition
;
Interface IFilterChain
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  StartChain(a.l, b.l)
  PauseChain(a.l, b.l)
  StopChain(a.l, b.l)
  RemoveChain(a.l, b.l)
EndInterface

; IVMRImagePresenter interface definition
;
Interface IVMRImagePresenter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  StartPresenting(a.l)
  StopPresenting(a.l)
  PresentImage(a.l, b.l)
EndInterface

; IVMRSurfaceAllocator interface definition
;
Interface IVMRSurfaceAllocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AllocateSurface(a.l, b.l, c.l, d.l)
  FreeSurface(a.l)
  PrepareSurface(a.l, b.l, c.l)
  AdviseNotify(a.l)
EndInterface

; IVMRSurfaceAllocatorNotify interface definition
;
Interface IVMRSurfaceAllocatorNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AdviseSurfaceAllocator(a.l, b.l)
  SetDDrawDevice(a.l, b.l)
  ChangeDDrawDevice(a.l, b.l)
  RestoreDDrawSurfaces()
  NotifyEvent(a.l, b.l, c.l)
  SetBorderColor(a.l)
EndInterface

; IVMRWindowlessControl interface definition
;
Interface IVMRWindowlessControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNativeVideoSize(a.l, b.l, c.l, d.l)
  GetMinIdealVideoSize(a.l, b.l)
  GetMaxIdealVideoSize(a.l, b.l)
  SetVideoPosition(a.l, b.l)
  GetVideoPosition(a.l, b.l)
  GetAspectRatioMode(a.l)
  SetAspectRatioMode(a.l)
  SetVideoClippingWindow(a.l)
  RepaintVideo(a.l, b.l)
  DisplayModeChanged()
  GetCurrentImage(a.l)
  SetBorderColor(a.l)
  GetBorderColor(a.l)
  SetColorKey(a.l)
  GetColorKey(a.l)
EndInterface

; IVMRMixerControl interface definition
;
Interface IVMRMixerControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAlpha(a.l, b.f)
  GetAlpha(a.l, b.l)
  SetZOrder(a.l, b.l)
  GetZOrder(a.l, b.l)
  SetOutputRect(a.l, b.l)
  GetOutputRect(a.l, b.l)
  SetBackgroundClr(a.l)
  GetBackgroundClr(a.l)
  SetMixingPrefs(a.l)
  GetMixingPrefs(a.l)
EndInterface

; IVMRMonitorConfig interface definition
;
Interface IVMRMonitorConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetMonitor(a.l)
  GetMonitor(a.l)
  SetDefaultMonitor(a.l)
  GetDefaultMonitor(a.l)
  GetAvailableMonitors(a.l, b.l, c.l)
EndInterface

; IVMRFilterConfig interface definition
;
Interface IVMRFilterConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetImageCompositor(a.l)
  SetNumberOfStreams(a.l)
  GetNumberOfStreams(a.l)
  SetRenderingPrefs(a.l)
  GetRenderingPrefs(a.l)
  SetRenderingMode(a.l)
  GetRenderingMode(a.l)
EndInterface

; IVMRAspectRatioControl interface definition
;
Interface IVMRAspectRatioControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetAspectRatioMode(a.l)
  SetAspectRatioMode(a.l)
EndInterface

; IVMRDeinterlaceControl interface definition
;
Interface IVMRDeinterlaceControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNumberOfDeinterlaceModes(a.l, b.l, c.l)
  GetDeinterlaceModeCaps(a.l, b.l, c.l)
  GetDeinterlaceMode(a.l, b.l)
  SetDeinterlaceMode(a.l, b.l)
  GetDeinterlacePrefs(a.l)
  SetDeinterlacePrefs(a.l)
  GetActualDeinterlaceMode(a.l, b.l)
EndInterface

; IVMRMixerBitmap interface definition
;
Interface IVMRMixerBitmap
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAlphaBitmap(a.l)
  UpdateAlphaBitmapParameters(a.l)
  GetAlphaBitmapParameters(a.l)
EndInterface

; IVMRImageCompositor interface definition
;
Interface IVMRImageCompositor
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitCompositionTarget(a.l, b.l)
  TermCompositionTarget(a.l, b.l)
  SetStreamMediaType(a.l, b.l, c.l)
  CompositeImage(a.l, b.l, c.l, d.q, e.q, f.l, g.l, h.l)
EndInterface

; IVMRVideoStreamControl interface definition
;
Interface IVMRVideoStreamControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetColorKey(a.l)
  GetColorKey(a.l)
  SetStreamActiveState(a.l)
  GetStreamActiveState(a.l)
EndInterface

; IVMRSurface interface definition
;
Interface IVMRSurface
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsSurfaceLocked()
  LockSurface(a.l)
  UnlockSurface()
  GetSurface(a.l)
EndInterface

; IVMRImagePresenterConfig interface definition
;
Interface IVMRImagePresenterConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRenderingPrefs(a.l)
  GetRenderingPrefs(a.l)
EndInterface

; IVMRImagePresenterExclModeConfig interface definition
;
Interface IVMRImagePresenterExclModeConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRenderingPrefs(a.l)
  GetRenderingPrefs(a.l)
  SetXlcModeDDObjAndPrimarySurface(a.l, b.l)
  GetXlcModeDDObjAndPrimarySurface(a.l, b.l)
EndInterface

; IVPManager interface definition
;
Interface IVPManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetVideoPortIndex(a.l)
  GetVideoPortIndex(a.l)
EndInterface
