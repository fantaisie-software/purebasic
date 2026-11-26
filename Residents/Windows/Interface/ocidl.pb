
; IEnumConnections interface definition
;
Interface IEnumConnections Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IConnectionPoint interface definition
;
Interface IConnectionPoint Extends IUnknown
  GetConnectionInterface(a.l)
  GetConnectionPointContainer(a.l)
  Advise(a.l, b.l)
  Unadvise(a.l)
  EnumConnections(a.l)
EndInterface

; IEnumConnectionPoints interface definition
;
Interface IEnumConnectionPoints Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IConnectionPointContainer interface definition
;
Interface IConnectionPointContainer Extends IUnknown
  EnumConnectionPoints(a.l)
  FindConnectionPoint(a.l, b.l)
EndInterface

; IClassFactory2 interface definition
;
Interface IClassFactory2 Extends IClassFactory
  GetLicInfo(a.l)
  RequestLicKey(a.l, b.l)
  CreateInstanceLic(a.l, b.l, c.l, d.p-bstr, e.l)
EndInterface

; IProvideClassInfo interface definition
;
Interface IProvideClassInfo Extends IUnknown
  GetClassInfo(a.l)
EndInterface

; IProvideClassInfo2 interface definition
;
Interface IProvideClassInfo2 Extends IProvideClassInfo
  GetGUID(a.l, b.l)
EndInterface

; IProvideMultipleClassInfo interface definition
;
Interface IProvideMultipleClassInfo Extends IProvideClassInfo2
  GetMultiTypeInfoCount(a.l)
  GetInfoOfIndex(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IOleControl interface definition
;
Interface IOleControl Extends IUnknown
  GetControlInfo(a.l)
  OnMnemonic(a.l)
  OnAmbientPropertyChange(a.l)
  FreezeEvents(a.l)
EndInterface

; IOleControlSite interface definition
;
Interface IOleControlSite Extends IUnknown
  OnControlInfoChanged()
  LockInPlaceActive(a.l)
  GetExtendedControl(a.l)
  TransformCoords(a.l, b.l, c.l)
  TranslateAccelerator(a.l, b.l)
  OnFocus(a.l)
  ShowPropertyFrame()
EndInterface

; IPropertyPage interface definition
;
Interface IPropertyPage Extends IUnknown
  SetPageSite(a.l)
  Activate(a.l, b.l, c.l)
  Deactivate()
  GetPageInfo(a.l)
  SetObjects(a.l, b.l)
  Show(a.l)
  Move(a.l)
  IsPageDirty()
  Apply()
  Help(a.l)
  TranslateAccelerator(a.l)
EndInterface

; IPropertyPage2 interface definition
;
Interface IPropertyPage2 Extends IPropertyPage
  EditProperty(a.l)
EndInterface

; IPropertyPageSite interface definition
;
Interface IPropertyPageSite Extends IUnknown
  OnStatusChange(a.l)
  GetLocaleID(a.l)
  GetPageContainer(a.l)
  TranslateAccelerator(a.l)
EndInterface

; IPropertyNotifySink interface definition
;
Interface IPropertyNotifySink Extends IUnknown
  OnChanged(a.l)
  OnRequestEdit(a.l)
EndInterface

; ISpecifyPropertyPages interface definition
;
Interface ISpecifyPropertyPages Extends IUnknown
  GetPages(a.l)
EndInterface

; IPersistMemory interface definition
;
Interface IPersistMemory Extends IPersist
  IsDirty()
  Load(a.l, b.l)
  Save(a.l, b.l, c.l)
  GetSizeMax(a.l)
  InitNew()
EndInterface

; IPersistStreamInit interface definition
;
Interface IPersistStreamInit Extends IPersist
  IsDirty()
  Load(a.l)
  Save(a.l, b.l)
  GetSizeMax(a.l)
  InitNew()
EndInterface

; IPersistPropertyBag interface definition
;
Interface IPersistPropertyBag Extends IPersist
  InitNew()
  Load(a.l, b.l)
  Save(a.l, b.l, c.l)
EndInterface

; ISimpleFrameSite interface definition
;
Interface ISimpleFrameSite Extends IUnknown
  PreMessageFilter(a.l, b.l, c.l, d.l, e.l, f.l)
  PostMessageFilter(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IFont interface definition
;
Interface IFont Extends IUnknown
  get_Name(a.l)
  put_Name(a.p-bstr)
  get_Size(a.l)
  put_Size(a.l)
  get_Bold(a.l)
  put_Bold(a.l)
  get_Italic(a.l)
  put_Italic(a.l)
  get_Underline(a.l)
  put_Underline(a.l)
  get_Strikethrough(a.l)
  put_Strikethrough(a.l)
  get_Weight(a.l)
  put_Weight(a.l)
  get_Charset(a.l)
  put_Charset(a.l)
  get_hFont(a.l)
  Clone(a.l)
  IsEqual(a.l)
  SetRatio(a.l, b.l)
  QueryTextMetrics(a.l)
  AddRefHfont(a.l)
  ReleaseHfont(a.l)
  SetHdc(a.l)
EndInterface

; IPicture interface definition
;
Interface IPicture Extends IUnknown
  get_Handle(a.l)
  get_hPal(a.l)
  get_Type(a.l)
  get_Width(a.l)
  get_Height(a.l)
  Render(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
  set_hPal(a.l)
  get_CurDC(a.l)
  SelectPicture(a.l, b.l, c.l)
  get_KeepOriginalFormat(a.l)
  put_KeepOriginalFormat(a.l)
  PictureChanged()
  SaveAsFile(a.l, b.l, c.l)
  get_Attributes(a.l)
EndInterface

; IFontEventsDisp interface definition
;
Interface IFontEventsDisp Extends IDispatch
EndInterface

; IFontDisp interface definition
;
Interface IFontDisp Extends IDispatch
EndInterface

; IPictureDisp interface definition
;
Interface IPictureDisp Extends IDispatch
EndInterface

; IOleInPlaceObjectWindowless interface definition
;
Interface IOleInPlaceObjectWindowless Extends IOleInPlaceObject
  OnWindowMessage(a.l, b.l, c.l, d.l)
  GetDropTarget(a.l)
EndInterface

; IOleInPlaceSiteEx interface definition
;
Interface IOleInPlaceSiteEx Extends IOleInPlaceSite
  OnInPlaceActivateEx(a.l, b.l)
  OnInPlaceDeactivateEx(a.l)
  RequestUIActivate()
EndInterface

; IOleInPlaceSiteWindowless interface definition
;
Interface IOleInPlaceSiteWindowless Extends IOleInPlaceSiteEx
  CanWindowlessActivate()
  GetCapture()
  SetCapture(a.l)
  GetFocus()
  SetFocus(a.l)
  GetDC(a.l, b.l, c.l)
  ReleaseDC(a.l)
  InvalidateRect(a.l, b.l)
  InvalidateRgn(a.l, b.l)
  ScrollRect(a.l, b.l, c.l, d.l)
  AdjustRect(a.l)
  OnDefWindowMessage(a.l, b.l, c.l, d.l)
EndInterface

; IViewObjectEx interface definition
;
Interface IViewObjectEx Extends IViewObject2
  GetRect(a.l, b.l)
  GetViewStatus(a.l)
  QueryHitPoint(a.l, b.l, c.l, d.l, e.l)
  QueryHitRect(a.l, b.l, c.l, d.l, e.l)
  GetNaturalExtent(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IOleUndoUnit interface definition
;
Interface IOleUndoUnit Extends IUnknown
  Do(a.l)
  GetDescription(a.l)
  GetUnitType(a.l, b.l)
  OnNextAdd()
EndInterface

; IOleParentUndoUnit interface definition
;
Interface IOleParentUndoUnit Extends IOleUndoUnit
  Open(a.l)
  Close(a.l, b.l)
  Add(a.l)
  FindUnit(a.l)
  GetParentState(a.l)
EndInterface

; IEnumOleUndoUnits interface definition
;
Interface IEnumOleUndoUnits Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IOleUndoManager interface definition
;
Interface IOleUndoManager Extends IUnknown
  Open(a.l)
  Close(a.l, b.l)
  Add(a.l)
  GetOpenParentState(a.l)
  DiscardFrom(a.l)
  UndoTo(a.l)
  RedoTo(a.l)
  EnumUndoable(a.l)
  EnumRedoable(a.l)
  GetLastUndoDescription(a.l)
  GetLastRedoDescription(a.l)
  Enable(a.l)
EndInterface

; IPointerInactive interface definition
;
Interface IPointerInactive Extends IUnknown
  GetActivationPolicy(a.l)
  OnInactiveMouseMove(a.l, b.l, c.l, d.l)
  OnInactiveSetCursor(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IObjectWithSite interface definition
;
Interface IObjectWithSite Extends IUnknown
  SetSite(a.l)
  GetSite(a.l, b.l)
EndInterface

; IPerPropertyBrowsing interface definition
;
Interface IPerPropertyBrowsing Extends IUnknown
  GetDisplayString(a.l, b.l)
  MapPropertyToPage(a.l, b.l)
  GetPredefinedStrings(a.l, b.l, c.l)
  GetPredefinedValue(a.l, b.l, c.l)
EndInterface

; IPropertyBag2 interface definition
;
Interface IPropertyBag2 Extends IUnknown
  Read(a.l, b.l, c.l, d.l, e.l)
  Write(a.l, b.l, c.l)
  CountProperties(a.l)
  GetPropertyInfo(a.l, b.l, c.l, d.l)
  LoadObject(a.l, b.l, c.l, d.l)
EndInterface

; IPersistPropertyBag2 interface definition
;
Interface IPersistPropertyBag2 Extends IPersist
  InitNew()
  Load(a.l, b.l)
  Save(a.l, b.l, c.l)
  IsDirty()
EndInterface

; IAdviseSinkEx interface definition
;
Interface IAdviseSinkEx Extends IAdviseSink
  OnViewStatusChange(a.l)
EndInterface

; IQuickActivate interface definition
;
Interface IQuickActivate Extends IUnknown
  QuickActivate(a.l, b.l)
  SetContentExtent(a.l)
  GetContentExtent(a.l)
EndInterface
