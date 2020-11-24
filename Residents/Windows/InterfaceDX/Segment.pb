
; IMSVidRect interface definition
;
Interface IMSVidRect
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Top(a.l)
  put_Top(a.l)
  get_Left(a.l)
  put_Left(a.l)
  get_Width(a.l)
  put_Width(a.l)
  get_Height(a.l)
  put_Height(a.l)
  get_HWnd(a.l)
  put_HWnd(a.l)
  put_Rect(a.l)
EndInterface

; IMSVidGraphSegmentContainer interface definition
;
Interface IMSVidGraphSegmentContainer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  get_Graph(a.l)
  get_Input(a.l)
  get_Outputs(a.l)
  get_VideoRenderer(a.l)
  get_AudioRenderer(a.l)
  get_Features(a.l)
  get_Composites(a.l)
  get_ParentContainer(a.l)
  Decompose(a.l)
  IsWindowless()
  GetFocus()
EndInterface

; IMSVidGraphSegment interface definition
;
Interface IMSVidGraphSegment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  get_Init(a.l)
  put_Init(a.l)
  EnumFilters(a.l)
  get_Container(a.l)
  put_Container(a.l)
  get_Type(a.l)
  get_Category(a.l)
  Build()
  PreRun()
  PostRun()
  PreStop()
  PostStop()
  OnEventNotify(a.l, b.l, c.l)
  Decompose()
EndInterface

; IMSVidGraphSegmentUserInput interface definition
;
Interface IMSVidGraphSegmentUserInput
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Click()
  DblClick()
  KeyDown(a.l, b.l)
  KeyPress(a.l)
  KeyUp(a.l, b.l)
  MouseDown(a.l, b.l, c.l, d.l)
  MouseMove(a.l, b.l, c.l, d.l)
  MouseUp(a.l, b.l, c.l, d.l)
EndInterface

; IMSVidCompositionSegment interface definition
;
Interface IMSVidCompositionSegment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  get_Init(a.l)
  put_Init(a.l)
  EnumFilters(a.l)
  get_Container(a.l)
  put_Container(a.l)
  get_Type(a.l)
  get_Category(a.l)
  Build()
  PreRun()
  PostRun()
  PreStop()
  PostStop()
  OnEventNotify(a.l, b.l, c.l)
  Decompose()
  Compose(a.l, b.l)
  get_Up(a.l)
  get_Down(a.l)
EndInterface

; IEnumMSVidGraphSegment interface definition
;
Interface IEnumMSVidGraphSegment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IMSVidVRGraphSegment interface definition
;
Interface IMSVidVRGraphSegment
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  get_Init(a.l)
  put_Init(a.l)
  EnumFilters(a.l)
  get_Container(a.l)
  put_Container(a.l)
  get_Type(a.l)
  get_Category(a.l)
  Build()
  PreRun()
  PostRun()
  PreStop()
  PostStop()
  OnEventNotify(a.l, b.l, c.l)
  Decompose()
  put__VMRendererMode(a.l)
  put_Owner(a.l)
  get_Owner(a.l)
  get_UseOverlay(a.l)
  put_UseOverlay(a.l)
  get_Visible(a.l)
  put_Visible(a.l)
  get_ColorKey(a.l)
  put_ColorKey(a.l)
  get_Source(a.l)
  put_Source(a.l)
  get_Destination(a.l)
  put_Destination(a.l)
  get_NativeSize(a.l, b.l)
  get_BorderColor(a.l)
  put_BorderColor(a.l)
  get_MaintainAspectRatio(a.l)
  put_MaintainAspectRatio(a.l)
  Refresh()
  DisplayChange()
  RePaint(a.l)
EndInterface

; IMSVidDevice interface definition
;
Interface IMSVidDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
EndInterface

; IMSVidInputDevice interface definition
;
Interface IMSVidInputDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
EndInterface

; IMSVidDeviceEvent interface definition
;
Interface IMSVidDeviceEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
EndInterface

; IMSVidInputDeviceEvent interface definition
;
Interface IMSVidInputDeviceEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; IMSVidVideoInputDevice interface definition
;
Interface IMSVidVideoInputDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
EndInterface

; IMSVidPlayback interface definition
;
Interface IMSVidPlayback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
  get_EnableResetOnStop(a.l)
  put_EnableResetOnStop(a.l)
  Run()
  Pause()
  Stop()
  get_CanStep(a.l, b.l)
  Step(a.l)
  put_Rate(a.d)
  get_Rate(a.l)
  put_CurrentPosition(a.l)
  get_CurrentPosition(a.l)
  put_PositionMode(a.l)
  get_PositionMode(a.l)
  get_Length(a.l)
EndInterface

; IMSVidPlaybackEvent interface definition
;
Interface IMSVidPlaybackEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  EndOfMedia(a.l)
EndInterface

; IMSVidTuner interface definition
;
Interface IMSVidTuner
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
  get_Tune(a.l)
  put_Tune(a.l)
  get_TuningSpace(a.l)
  put_TuningSpace(a.l)
EndInterface

; IMSVidTunerEvent interface definition
;
Interface IMSVidTunerEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  TuneChanged(a.l)
EndInterface

; IMSVidAnalogTuner interface definition
;
Interface IMSVidAnalogTuner
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
  get_Tune(a.l)
  put_Tune(a.l)
  get_TuningSpace(a.l)
  put_TuningSpace(a.l)
  get_Channel(a.l)
  put_Channel(a.l)
  get_VideoFrequency(a.l)
  get_AudioFrequency(a.l)
  get_CountryCode(a.l)
  put_CountryCode(a.l)
  get_SAP(a.l)
  put_SAP(a.l)
  ChannelAvailable(a.l, b.l, c.l)
EndInterface

; IMSVidAnalogTunerEvent interface definition
;
Interface IMSVidAnalogTunerEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  TuneChanged(a.l)
EndInterface

; IMSVidFilePlayback interface definition
;
Interface IMSVidFilePlayback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
  get_EnableResetOnStop(a.l)
  put_EnableResetOnStop(a.l)
  Run()
  Pause()
  Stop()
  get_CanStep(a.l, b.l)
  Step(a.l)
  put_Rate(a.d)
  get_Rate(a.l)
  put_CurrentPosition(a.l)
  get_CurrentPosition(a.l)
  put_PositionMode(a.l)
  get_PositionMode(a.l)
  get_Length(a.l)
  get_FileName(a.l)
  put_FileName(a.p-bstr)
EndInterface

; IMSVidFilePlaybackEvent interface definition
;
Interface IMSVidFilePlaybackEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  EndOfMedia(a.l)
EndInterface

; IMSVidWebDVD interface definition
;
Interface IMSVidWebDVD
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
  get_EnableResetOnStop(a.l)
  put_EnableResetOnStop(a.l)
  Run()
  Pause()
  Stop()
  get_CanStep(a.l, b.l)
  Step(a.l)
  put_Rate(a.d)
  get_Rate(a.l)
  put_CurrentPosition(a.l)
  get_CurrentPosition(a.l)
  put_PositionMode(a.l)
  get_PositionMode(a.l)
  get_Length(a.l)
  OnDVDEvent(a.l, b.l, c.l)
  PlayTitle(a.l)
  PlayChapterInTitle(a.l, b.l)
  PlayChapter(a.l)
  PlayChaptersAutoStop(a.l, b.l, c.l)
  PlayAtTime(a.p-bstr)
  PlayAtTimeInTitle(a.l, b.p-bstr)
  PlayPeriodInTitleAutoStop(a.l, b.p-bstr, c.p-bstr)
  ReplayChapter()
  PlayPrevChapter()
  PlayNextChapter()
  StillOff()
  get_AudioLanguage(a.l, b.l, c.l)
  ShowMenu(a.l)
  Resume()
  ReturnFromSubmenu()
  get_ButtonsAvailable(a.l)
  get_CurrentButton(a.l)
  SelectAndActivateButton(a.l)
  ActivateButton()
  SelectRightButton()
  SelectLeftButton()
  SelectLowerButton()
  SelectUpperButton()
  ActivateAtPosition(a.l, b.l)
  SelectAtPosition(a.l, b.l)
  get_ButtonAtPosition(a.l, b.l, c.l)
  get_NumberOfChapters(a.l, b.l)
  get_TotalTitleTime(a.l)
  get_TitlesAvailable(a.l)
  get_VolumesAvailable(a.l)
  get_CurrentVolume(a.l)
  get_CurrentDiscSide(a.l)
  get_CurrentDomain(a.l)
  get_CurrentChapter(a.l)
  get_CurrentTitle(a.l)
  get_CurrentTime(a.l)
  DVDTimeCode2bstr(a.l, b.l)
  get_DVDDirectory(a.l)
  put_DVDDirectory(a.p-bstr)
  IsSubpictureStreamEnabled(a.l, b.l)
  IsAudioStreamEnabled(a.l, b.l)
  get_CurrentSubpictureStream(a.l)
  put_CurrentSubpictureStream(a.l)
  get_SubpictureLanguage(a.l, b.l)
  get_CurrentAudioStream(a.l)
  put_CurrentAudioStream(a.l)
  get_AudioStreamsAvailable(a.l)
  get_AnglesAvailable(a.l)
  get_CurrentAngle(a.l)
  put_CurrentAngle(a.l)
  get_SubpictureStreamsAvailable(a.l)
  get_SubpictureOn(a.l)
  put_SubpictureOn(a.l)
  get_DVDUniqueID(a.l)
  AcceptParentalLevelChange(a.l, b.p-bstr, c.p-bstr)
  NotifyParentalLevelChange(a.l)
  SelectParentalCountry(a.l, b.p-bstr, c.p-bstr)
  SelectParentalLevel(a.l, b.p-bstr, c.p-bstr)
  get_TitleParentalLevels(a.l, b.l)
  get_PlayerParentalCountry(a.l)
  get_PlayerParentalLevel(a.l)
  Eject()
  UOPValid(a.l, b.l)
  get_SPRM(a.l, b.l)
  get_GPRM(a.l, b.l)
  put_GPRM(a.l, b.l)
  get_DVDTextStringType(a.l, b.l, c.l)
  get_DVDTextString(a.l, b.l, c.l)
  get_DVDTextNumberOfStrings(a.l, b.l)
  get_DVDTextNumberOfLanguages(a.l)
  get_DVDTextLanguageLCID(a.l, b.l)
  RegionChange()
  get_DVDAdm(a.l)
  DeleteBookmark()
  RestoreBookmark()
  SaveBookmark()
  SelectDefaultAudioLanguage(a.l, b.l)
  SelectDefaultSubpictureLanguage(a.l, b.l)
  get_PreferredSubpictureStream(a.l)
  get_DefaultMenuLanguage(a.l)
  put_DefaultMenuLanguage(a.l)
  get_DefaultSubpictureLanguage(a.l)
  get_DefaultAudioLanguage(a.l)
  get_DefaultSubpictureLanguageExt(a.l)
  get_DefaultAudioLanguageExt(a.l)
  get_LanguageFromLCID(a.l, b.l)
  get_KaraokeAudioPresentationMode(a.l)
  put_KaraokeAudioPresentationMode(a.l)
  get_KaraokeChannelContent(a.l, b.l, c.l)
  get_KaraokeChannelAssignment(a.l, b.l)
  RestorePreferredSettings()
  get_ButtonRect(a.l, b.l)
  get_DVDScreenInMouseCoordinates(a.l)
  put_DVDScreenInMouseCoordinates(a.l)
EndInterface

; IMSVidWebDVDEvent interface definition
;
Interface IMSVidWebDVDEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  EndOfMedia(a.l)
  DVDNotify(a.l, b.p-variant, c.p-variant)
  PlayForwards(a.l)
  PlayBackwards(a.l)
  ShowMenu(a.l, b.l)
  Resume(a.l)
  SelectOrActivateButton(a.l)
  StillOff(a.l)
  PauseOn(a.l)
  ChangeCurrentAudioStream(a.l)
  ChangeCurrentSubpictureStream(a.l)
  ChangeCurrentAngle(a.l)
  PlayAtTimeInTitle(a.l)
  PlayAtTime(a.l)
  PlayChapterInTitle(a.l)
  PlayChapter(a.l)
  ReplayChapter(a.l)
  PlayNextChapter(a.l)
  Stop(a.l)
  ReturnFromSubmenu(a.l)
  PlayTitle(a.l)
  PlayPrevChapter(a.l)
  ChangeKaraokePresMode(a.l)
  ChangeVideoPresMode(a.l)
EndInterface

; IMSVidWebDVDAdm interface definition
;
Interface IMSVidWebDVDAdm
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  ChangePassword(a.p-bstr, b.p-bstr, c.p-bstr)
  SaveParentalLevel(a.l, b.p-bstr, c.p-bstr)
  SaveParentalCountry(a.l, b.p-bstr, c.p-bstr)
  ConfirmPassword(a.p-bstr, b.p-bstr, c.l)
  GetParentalLevel(a.l)
  GetParentalCountry(a.l)
  get_DefaultAudioLCID(a.l)
  put_DefaultAudioLCID(a.l)
  get_DefaultSubpictureLCID(a.l)
  put_DefaultSubpictureLCID(a.l)
  get_DefaultMenuLCID(a.l)
  put_DefaultMenuLCID(a.l)
  get_BookmarkOnStop(a.l)
  put_BookmarkOnStop(a.l)
EndInterface

; IMSVidOutputDevice interface definition
;
Interface IMSVidOutputDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
EndInterface

; IMSVidOutputDeviceEvent interface definition
;
Interface IMSVidOutputDeviceEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
EndInterface

; IMSVidFeature interface definition
;
Interface IMSVidFeature
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
EndInterface

; IMSVidFeatureEvent interface definition
;
Interface IMSVidFeatureEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
EndInterface

; IMSVidEncoder interface definition
;
Interface IMSVidEncoder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  get_VideoEncoderInterface(a.l)
  get_AudioEncoderInterface(a.l)
EndInterface

; IMSVidXDS interface definition
;
Interface IMSVidXDS
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
EndInterface

; IMSVidDataServices interface definition
;
Interface IMSVidDataServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
EndInterface

; IMSVidDataServicesEvent interface definition
;
Interface IMSVidDataServicesEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
EndInterface

; IMSVidClosedCaptioning interface definition
;
Interface IMSVidClosedCaptioning
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  get_Enable(a.l)
  put_Enable(a.l)
EndInterface

; IMSVidClosedCaptioning2 interface definition
;
Interface IMSVidClosedCaptioning2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  get_Enable(a.l)
  put_Enable(a.l)
  get_Service(a.l)
  put_Service(a.l)
EndInterface

; IMSVidVideoRenderer interface definition
;
Interface IMSVidVideoRenderer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  get_CustomCompositorClass(a.l)
  put_CustomCompositorClass(a.p-bstr)
  get__CustomCompositorClass(a.l)
  put__CustomCompositorClass(a.l)
  get__CustomCompositor(a.l)
  put__CustomCompositor(a.l)
  get_MixerBitmap(a.l)
  get__MixerBitmap(a.l)
  put_MixerBitmap(a.l)
  put__MixerBitmap(a.l)
  get_MixerBitmapPositionRect(a.l)
  put_MixerBitmapPositionRect(a.l)
  get_MixerBitmapOpacity(a.l)
  put_MixerBitmapOpacity(a.l)
  SetupMixerBitmap(a.l, b.l, c.l)
  get_SourceSize(a.l)
  put_SourceSize(a.l)
  get_OverScan(a.l)
  put_OverScan(a.l)
  get_AvailableSourceRect(a.l)
  get_MaxVidRect(a.l)
  get_MinVidRect(a.l)
  get_ClippedSourceRect(a.l)
  put_ClippedSourceRect(a.l)
  get_UsingOverlay(a.l)
  put_UsingOverlay(a.l)
  Capture(a.l)
  get_FramesPerSecond(a.l)
  get_DecimateInput(a.l)
  put_DecimateInput(a.l)
EndInterface

; IMSVidVideoRendererEvent interface definition
;
Interface IMSVidVideoRendererEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
  OverlayUnavailable()
EndInterface

; IMSVidStreamBufferRecordingControl interface definition
;
Interface IMSVidStreamBufferRecordingControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_StartTime(a.l)
  put_StartTime(a.l)
  get_StopTime(a.l)
  put_StopTime(a.l)
  get_RecordingStopped(a.l)
  get_RecordingStarted(a.l)
  get_RecordingType(a.l)
  get_RecordingAttribute(a.l)
EndInterface

; IMSVidStreamBufferSink interface definition
;
Interface IMSVidStreamBufferSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  get_ContentRecorder(a.p-bstr, b.l)
  get_ReferenceRecorder(a.p-bstr, b.l)
  get_SinkName(a.l)
  put_SinkName(a.p-bstr)
  NameSetLock()
  get_SBESink(a.l)
EndInterface

; IMSVidStreamBufferSinkEvent interface definition
;
Interface IMSVidStreamBufferSinkEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
  CertificateFailure()
  CertificateSuccess()
  WriteFailure()
EndInterface

; IMSVidStreamBufferSource interface definition
;
Interface IMSVidStreamBufferSource
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  IsViewable(a.l, b.l)
  View(a.l)
  get_EnableResetOnStop(a.l)
  put_EnableResetOnStop(a.l)
  Run()
  Pause()
  Stop()
  get_CanStep(a.l, b.l)
  Step(a.l)
  put_Rate(a.d)
  get_Rate(a.l)
  put_CurrentPosition(a.l)
  get_CurrentPosition(a.l)
  put_PositionMode(a.l)
  get_PositionMode(a.l)
  get_Length(a.l)
  get_FileName(a.l)
  put_FileName(a.p-bstr)
  get_Start(a.l)
  get_RecordingAttribute(a.l)
  CurrentRatings(a.l, b.l, c.l)
  MaxRatingsLevel(a.l, b.l, c.l)
  put_BlockUnrated(a.l)
  put_UnratedDelay(a.l)
  get_SBESource(a.l)
EndInterface

; IMSVidStreamBufferSourceEvent interface definition
;
Interface IMSVidStreamBufferSourceEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  EndOfMedia(a.l)
  CertificateFailure()
  CertificateSuccess()
  RatingsBlocked()
  RatingsUnblocked()
  RatingsChanged()
  TimeHole(a.l, b.l)
  StaleDataRead()
  ContentBecomingStale()
  StaleFileDeleted()
EndInterface

; IMSVidVideoRenderer2 interface definition
;
Interface IMSVidVideoRenderer2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  get_CustomCompositorClass(a.l)
  put_CustomCompositorClass(a.p-bstr)
  get__CustomCompositorClass(a.l)
  put__CustomCompositorClass(a.l)
  get__CustomCompositor(a.l)
  put__CustomCompositor(a.l)
  get_MixerBitmap(a.l)
  get__MixerBitmap(a.l)
  put_MixerBitmap(a.l)
  put__MixerBitmap(a.l)
  get_MixerBitmapPositionRect(a.l)
  put_MixerBitmapPositionRect(a.l)
  get_MixerBitmapOpacity(a.l)
  put_MixerBitmapOpacity(a.l)
  SetupMixerBitmap(a.l, b.l, c.l)
  get_SourceSize(a.l)
  put_SourceSize(a.l)
  get_OverScan(a.l)
  put_OverScan(a.l)
  get_AvailableSourceRect(a.l)
  get_MaxVidRect(a.l)
  get_MinVidRect(a.l)
  get_ClippedSourceRect(a.l)
  put_ClippedSourceRect(a.l)
  get_UsingOverlay(a.l)
  put_UsingOverlay(a.l)
  Capture(a.l)
  get_FramesPerSecond(a.l)
  get_DecimateInput(a.l)
  put_DecimateInput(a.l)
  get_Allocator(a.l)
  get__Allocator(a.l)
  get_Allocator_ID(a.l)
  SetAllocator(a.l, b.l)
  _SetAllocator(a.l, b.l)
  put_SuppressEffects(a.l)
  get_SuppressEffects(a.l)
EndInterface

; IMSVidVideoRendererEvent2 interface definition
;
Interface IMSVidVideoRendererEvent2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
  OverlayUnavailable()
EndInterface

; IMSVidAudioRenderer interface definition
;
Interface IMSVidAudioRenderer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Status(a.l)
  put_Power(a.l)
  get_Power(a.l)
  get_Category(a.l)
  get_ClassID(a.l)
  get__Category(a.l)
  get__ClassID(a.l)
  IsEqualDevice(a.l, b.l)
  put_Volume(a.l)
  get_Volume(a.l)
  put_Balance(a.l)
  get_Balance(a.l)
EndInterface

; IMSVidAudioRendererEvent interface definition
;
Interface IMSVidAudioRendererEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  StateChange(a.l, b.l, c.l)
EndInterface

; IMSVidInputDevices interface definition
;
Interface IMSVidInputDevices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface

; IMSVidOutputDevices interface definition
;
Interface IMSVidOutputDevices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface

; IMSVidVideoRendererDevices interface definition
;
Interface IMSVidVideoRendererDevices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface

; IMSVidAudioRendererDevices interface definition
;
Interface IMSVidAudioRendererDevices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface

; IMSVidFeatures interface definition
;
Interface IMSVidFeatures
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get__NewEnum(a.l)
  get_Item(a.p-variant, b.l)
  Add(a.l)
  Remove(a.p-variant)
EndInterface
