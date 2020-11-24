
; IPropertySetter interface definition
;
Interface IPropertySetter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  LoadXML(a.l)
  PrintXML(a.l, b.l, c.l, d.l)
  CloneProps(a.l, b.q, c.q)
  AddProp(a.l, b.l)
  GetProps(a.l, b.l, c.l)
  FreeProps(a.l, b.l, c.l)
  ClearProps()
  SaveToBlob(a.l, b.l)
  LoadFromBlob(a.l, b.l)
  SetProps(a.l, b.q)
  PrintXMLW(a.l, b.l, c.l, d.l)
EndInterface

; IDxtCompositor interface definition
;
Interface IDxtCompositor
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Capabilities(a.l)
  get_Progress(a.l)
  put_Progress(a.f)
  get_StepResolution(a.l)
  get_Duration(a.l)
  put_Duration(a.f)
  get_OffsetX(a.l)
  put_OffsetX(a.l)
  get_OffsetY(a.l)
  put_OffsetY(a.l)
  get_Width(a.l)
  put_Width(a.l)
  get_Height(a.l)
  put_Height(a.l)
  get_SrcOffsetX(a.l)
  put_SrcOffsetX(a.l)
  get_SrcOffsetY(a.l)
  put_SrcOffsetY(a.l)
  get_SrcWidth(a.l)
  put_SrcWidth(a.l)
  get_SrcHeight(a.l)
  put_SrcHeight(a.l)
EndInterface

; IDxtAlphaSetter interface definition
;
Interface IDxtAlphaSetter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Capabilities(a.l)
  get_Progress(a.l)
  put_Progress(a.f)
  get_StepResolution(a.l)
  get_Duration(a.l)
  put_Duration(a.f)
  get_Alpha(a.l)
  put_Alpha(a.l)
  get_AlphaRamp(a.l)
  put_AlphaRamp(a.d)
EndInterface

; IDxtJpeg interface definition
;
Interface IDxtJpeg
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Capabilities(a.l)
  get_Progress(a.l)
  put_Progress(a.f)
  get_StepResolution(a.l)
  get_Duration(a.l)
  put_Duration(a.f)
  get_MaskNum(a.l)
  put_MaskNum(a.l)
  get_MaskName(a.l)
  put_MaskName(a.p-bstr)
  get_ScaleX(a.l)
  put_ScaleX(a.d)
  get_ScaleY(a.l)
  put_ScaleY(a.d)
  get_OffsetX(a.l)
  put_OffsetX(a.l)
  get_OffsetY(a.l)
  put_OffsetY(a.l)
  get_ReplicateX(a.l)
  put_ReplicateX(a.l)
  get_ReplicateY(a.l)
  put_ReplicateY(a.l)
  get_BorderColor(a.l)
  put_BorderColor(a.l)
  get_BorderWidth(a.l)
  put_BorderWidth(a.l)
  get_BorderSoftness(a.l)
  put_BorderSoftness(a.l)
  ApplyChanges()
  LoadDefSettings()
EndInterface

; IDxtKey interface definition
;
Interface IDxtKey
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Capabilities(a.l)
  get_Progress(a.l)
  put_Progress(a.f)
  get_StepResolution(a.l)
  get_Duration(a.l)
  put_Duration(a.f)
  get_KeyType(a.l)
  put_KeyType(a.l)
  get_Hue(a.l)
  put_Hue(a.l)
  get_Luminance(a.l)
  put_Luminance(a.l)
  get_RGB(a.l)
  put_RGB(a.l)
  get_Similarity(a.l)
  put_Similarity(a.l)
  get_Invert(a.l)
  put_Invert(a.l)
EndInterface

; IMediaLocator interface definition
;
Interface IMediaLocator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FindMediaFile(a.p-bstr, b.p-bstr, c.l, d.l)
  AddFoundLocation(a.p-bstr)
EndInterface

; IMediaDet interface definition
;
Interface IMediaDet
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_Filter(a.l)
  put_Filter(a.l)
  get_OutputStreams(a.l)
  get_CurrentStream(a.l)
  put_CurrentStream(a.l)
  get_StreamType(a.l)
  get_StreamTypeB(a.l)
  get_StreamLength(a.l)
  get_Filename(a.l)
  put_Filename(a.p-bstr)
  GetBitmapBits(a.d, b.l, c.l, d.l, e.l)
  WriteBitmapBits(a.d, b.l, c.l, d.p-bstr)
  get_StreamMediaType(a.l)
  GetSampleGrabber(a.l)
  get_FrameRate(a.l)
  EnterBitmapGrabMode(a.d)
EndInterface

; IGrfCache interface definition
;
Interface IGrfCache
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  AddFilter(a.l, b.q, c.l, d.l)
  ConnectPins(a.l, b.q, c.l, d.q, e.l)
  SetGraph(a.l)
  DoConnectionsNow()
EndInterface

; IRenderEngine interface definition
;
Interface IRenderEngine
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetTimelineObject(a.l)
  GetTimelineObject(a.l)
  GetFilterGraph(a.l)
  SetFilterGraph(a.l)
  SetInterestRange(a.q, b.q)
  SetInterestRange2(a.d, b.d)
  SetRenderRange(a.q, b.q)
  SetRenderRange2(a.d, b.d)
  GetGroupOutputPin(a.l, b.l)
  ScrapIt()
  RenderOutputPins()
  GetVendorString(a.l)
  ConnectFrontEnd()
  SetSourceConnectCallback(a.l)
  SetDynamicReconnectLevel(a.l)
  DoSmartRecompression()
  UseInSmartRecompressionGraph()
  SetSourceNameValidation(a.p-bstr, b.l, c.l)
  Commit()
  Decommit()
  GetCaps(a.l, b.l)
EndInterface

; IRenderEngine2 interface definition
;
Interface IRenderEngine2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetResizerGUID(a.l)
EndInterface

; IFindCompressorCB interface definition
;
Interface IFindCompressorCB
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCompressor(a.l, b.l, c.l)
EndInterface

; ISmartRenderEngine interface definition
;
Interface ISmartRenderEngine
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetGroupCompressor(a.l, b.l)
  GetGroupCompressor(a.l, b.l)
  SetFindCompressorCB(a.l)
EndInterface

; IAMTimelineObj interface definition
;
Interface IAMTimelineObj
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetStartStop(a.l, b.l)
  GetStartStop2(a.l, b.l)
  FixTimes(a.l, b.l)
  FixTimes2(a.l, b.l)
  SetStartStop(a.q, b.q)
  SetStartStop2(a.l, b.l)
  GetPropertySetter(a.l)
  SetPropertySetter(a.l)
  GetSubObject(a.l)
  SetSubObject(a.l)
  SetSubObjectGUID(a.l)
  SetSubObjectGUIDB(a.p-bstr)
  GetSubObjectGUID(a.l)
  GetSubObjectGUIDB(a.l)
  GetSubObjectLoaded(a.l)
  GetTimelineType(a.l)
  SetTimelineType(a.l)
  GetUserID(a.l)
  SetUserID(a.l)
  GetGenID(a.l)
  GetUserName(a.l)
  SetUserName(a.p-bstr)
  GetUserData(a.l, b.l)
  SetUserData(a.l, b.l)
  GetMuted(a.l)
  SetMuted(a.l)
  GetLocked(a.l)
  SetLocked(a.l)
  GetDirtyRange(a.l, b.l)
  GetDirtyRange2(a.l, b.l)
  SetDirtyRange(a.q, b.q)
  SetDirtyRange2(a.l, b.l)
  ClearDirty()
  Remove()
  RemoveAll()
  GetTimelineNoRef(a.l)
  GetGroupIBelongTo(a.l)
  GetEmbedDepth(a.l)
EndInterface

; IAMTimelineEffectable interface definition
;
Interface IAMTimelineEffectable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EffectInsBefore(a.l, b.l)
  EffectSwapPriorities(a.l, b.l)
  EffectGetCount(a.l)
  GetEffect(a.l, b.l)
EndInterface

; IAMTimelineEffect interface definition
;
Interface IAMTimelineEffect
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EffectGetPriority(a.l)
EndInterface

; IAMTimelineTransable interface definition
;
Interface IAMTimelineTransable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  TransAdd(a.l)
  TransGetCount(a.l)
  GetNextTrans(a.l, b.l)
  GetNextTrans2(a.l, b.l)
  GetTransAtTime(a.l, b.q, c.l)
  GetTransAtTime2(a.l, b.l, c.l)
EndInterface

; IAMTimelineSplittable interface definition
;
Interface IAMTimelineSplittable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SplitAt(a.q)
  SplitAt2(a.l)
EndInterface

; IAMTimelineTrans interface definition
;
Interface IAMTimelineTrans
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCutPoint(a.l)
  GetCutPoint2(a.l)
  SetCutPoint(a.q)
  SetCutPoint2(a.l)
  GetSwapInputs(a.l)
  SetSwapInputs(a.l)
  GetCutsOnly(a.l)
  SetCutsOnly(a.l)
EndInterface

; IAMTimelineSrc interface definition
;
Interface IAMTimelineSrc
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetMediaTimes(a.l, b.l)
  GetMediaTimes2(a.l, b.l)
  ModifyStopTime(a.q)
  ModifyStopTime2(a.l)
  FixMediaTimes(a.l, b.l)
  FixMediaTimes2(a.l, b.l)
  SetMediaTimes(a.q, b.q)
  SetMediaTimes2(a.l, b.l)
  SetMediaLength(a.q)
  SetMediaLength2(a.l)
  GetMediaLength(a.l)
  GetMediaLength2(a.l)
  GetMediaName(a.l)
  SetMediaName(a.p-bstr)
  SpliceWithNext(a.l)
  GetStreamNumber(a.l)
  SetStreamNumber(a.l)
  IsNormalRate(a.l)
  GetDefaultFPS(a.l)
  SetDefaultFPS(a.d)
  GetStretchMode(a.l)
  SetStretchMode(a.l)
EndInterface

; IAMTimelineTrack interface definition
;
Interface IAMTimelineTrack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SrcAdd(a.l)
  GetNextSrc(a.l, b.l)
  GetNextSrc2(a.l, b.l)
  MoveEverythingBy(a.q, b.q)
  MoveEverythingBy2(a.l, b.l)
  GetSourcesCount(a.l)
  AreYouBlank(a.l)
  GetSrcAtTime(a.l, b.q, c.l)
  GetSrcAtTime2(a.l, b.l, c.l)
  InsertSpace(a.q, b.q)
  InsertSpace2(a.l, b.l)
  ZeroBetween(a.q, b.q)
  ZeroBetween2(a.l, b.l)
  GetNextSrcEx(a.l, b.l)
EndInterface

; IAMTimelineVirtualTrack interface definition
;
Interface IAMTimelineVirtualTrack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  TrackGetPriority(a.l)
  SetTrackDirty()
EndInterface

; IAMTimelineComp interface definition
;
Interface IAMTimelineComp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  VTrackInsBefore(a.l, b.l)
  VTrackSwapPriorities(a.l, b.l)
  VTrackGetCount(a.l)
  GetVTrack(a.l, b.l)
  GetCountOfType(a.l, b.l, c.l)
  GetRecursiveLayerOfType(a.l, b.l, c.l)
  GetRecursiveLayerOfTypeI(a.l, b.l, c.l)
  GetNextVTrack(a.l, b.l)
EndInterface

; IAMTimelineGroup interface definition
;
Interface IAMTimelineGroup
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetTimeline(a.l)
  GetTimeline(a.l)
  GetPriority(a.l)
  GetMediaType(a.l)
  SetMediaType(a.l)
  SetOutputFPS(a.d)
  GetOutputFPS(a.l)
  SetGroupName(a.p-bstr)
  GetGroupName(a.l)
  SetPreviewMode(a.l)
  GetPreviewMode(a.l)
  SetMediaTypeForVB(a.l)
  GetOutputBuffering(a.l)
  SetOutputBuffering(a.l)
  SetSmartRecompressFormat(a.l)
  GetSmartRecompressFormat(a.l)
  IsSmartRecompressFormatSet(a.l)
  IsRecompressFormatDirty(a.l)
  ClearRecompressFormatDirty()
  SetRecompFormatFromSource(a.l)
EndInterface

; IAMTimeline interface definition
;
Interface IAMTimeline
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateEmptyNode(a.l, b.l)
  AddGroup(a.l)
  RemGroupFromList(a.l)
  GetGroup(a.l, b.l)
  GetGroupCount(a.l)
  ClearAllGroups()
  GetInsertMode(a.l)
  SetInsertMode(a.l)
  EnableTransitions(a.l)
  TransitionsEnabled(a.l)
  EnableEffects(a.l)
  EffectsEnabled(a.l)
  SetInterestRange(a.q, b.q)
  GetDuration(a.l)
  GetDuration2(a.l)
  SetDefaultFPS(a.d)
  GetDefaultFPS(a.l)
  IsDirty(a.l)
  GetDirtyRange(a.l, b.l)
  GetCountOfType(a.l, b.l, c.l, d.l)
  ValidateSourceNames(a.l, b.l, c.l)
  SetDefaultTransition(a.l)
  GetDefaultTransition(a.l)
  SetDefaultEffect(a.l)
  GetDefaultEffect(a.l)
  SetDefaultTransitionB(a.p-bstr)
  GetDefaultTransitionB(a.l)
  SetDefaultEffectB(a.p-bstr)
  GetDefaultEffectB(a.l)
EndInterface

; IXml2Dex interface definition
;
Interface IXml2Dex
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CreateGraphFromFile(a.l, b.l, c.p-bstr)
  WriteGrfFile(a.l, b.p-bstr)
  WriteXMLFile(a.l, b.p-bstr)
  ReadXMLFile(a.l, b.p-bstr)
  Delete(a.l, b.d, c.d)
  WriteXMLPart(a.l, b.d, c.d, d.p-bstr)
  PasteXMLFile(a.l, b.d, c.p-bstr)
  CopyXML(a.l, b.d, c.d)
  PasteXML(a.l, b.d)
  Reset()
  ReadXML(a.l, b.l)
  WriteXML(a.l, b.l)
EndInterface

; IAMErrorLog interface definition
;
Interface IAMErrorLog
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  LogError(a.l, b.p-bstr, c.l, d.l, e.l)
EndInterface

; IAMSetErrorLog interface definition
;
Interface IAMSetErrorLog
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_ErrorLog(a.l)
  put_ErrorLog(a.l)
EndInterface

; ISampleGrabberCB interface definition
;
Interface ISampleGrabberCB
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SampleCB(a.d, b.l)
  BufferCB(a.d, b.l, c.l)
EndInterface

; ISampleGrabber interface definition
;
Interface ISampleGrabber
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetOneShot(a.l)
  SetMediaType(a.l)
  GetConnectedMediaType(a.l)
  SetBufferSamples(a.l)
  GetCurrentBuffer(a.l, b.l)
  GetCurrentSample(a.l)
  SetCallback(a.l, b.l)
EndInterface

; IResize interface definition
;
Interface IResize
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_Size(a.l, b.l, c.l)
  get_InputSize(a.l, b.l)
  put_Size(a.l, b.l, c.l)
  get_MediaType(a.l)
  put_MediaType(a.l)
EndInterface
