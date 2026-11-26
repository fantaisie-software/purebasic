
; IOleAdviseHolder interface definition
;
Interface IOleAdviseHolder Extends IUnknown
  Advise(a.l, b.l)
  Unadvise(a.l)
  EnumAdvise(a.l)
  SendOnRename(a.l)
  SendOnSave()
  SendOnClose()
EndInterface

; IOleCache interface definition
;
Interface IOleCache Extends IUnknown
  Cache(a.l, b.l, c.l)
  Uncache(a.l)
  EnumCache(a.l)
  InitCache(a.l)
  SetData(a.l, b.l, c.l)
EndInterface

; IOleCache2 interface definition
;
Interface IOleCache2 Extends IOleCache
  UpdateCache(a.l, b.l, c.l)
  DiscardCache(a.l)
EndInterface

; IOleCacheControl interface definition
;
Interface IOleCacheControl Extends IUnknown
  OnRun(a.l)
  OnStop()
EndInterface

; IParseDisplayName interface definition
;
Interface IParseDisplayName Extends IUnknown
  ParseDisplayName(a.l, b.p-unicode, c.l, d.l)
EndInterface

; IOleContainer interface definition
;
Interface IOleContainer Extends IParseDisplayName
  EnumObjects(a.l, b.l)
  LockContainer(a.l)
EndInterface

; IOleClientSite interface definition
;
Interface IOleClientSite Extends IUnknown
  SaveObject()
  GetMoniker(a.l, b.l, c.l)
  GetContainer(a.l)
  ShowObject()
  OnShowWindow(a.l)
  RequestNewObjectLayout()
EndInterface

; IOleObject interface definition
;
Interface IOleObject Extends IUnknown
  SetClientSite(a.l)
  GetClientSite(a.l)
  SetHostNames(a.l, b.l)
  Close(a.l)
  SetMoniker(a.l, b.l)
  GetMoniker(a.l, b.l, c.l)
  InitFromData(a.l, b.l, c.l)
  GetClipboardData(a.l, b.l)
  DoVerb(a.l, b.l, c.l, d.l, e.l, f.l)
  EnumVerbs(a.l)
  Update()
  IsUpToDate()
  GetUserClassID(a.l)
  GetUserType(a.l, b.l)
  SetExtent(a.l, b.l)
  GetExtent(a.l, b.l)
  Advise(a.l, b.l)
  Unadvise(a.l)
  EnumAdvise(a.l)
  GetMiscStatus(a.l, b.l)
  SetColorScheme(a.l)
EndInterface

; IOleWindow interface definition
;
Interface IOleWindow Extends IUnknown
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
EndInterface

; IOleLink interface definition
;
Interface IOleLink Extends IUnknown
  SetUpdateOptions(a.l)
  GetUpdateOptions(a.l)
  SetSourceMoniker(a.l, b.l)
  GetSourceMoniker(a.l)
  SetSourceDisplayName(a.l)
  GetSourceDisplayName(a.l)
  BindToSource(a.l, b.l)
  BindIfRunning()
  GetBoundSource(a.l)
  UnbindSource()
  Update(a.l)
EndInterface

; IOleItemContainer interface definition
;
Interface IOleItemContainer Extends IOleContainer
  GetObject(a.p-unicode, b.l, c.l, d.l, e.l)
  GetObjectStorage(a.p-unicode, b.l, c.l, d.l)
  IsRunning(a.p-unicode)
EndInterface

; IOleInPlaceUIWindow interface definition
;
Interface IOleInPlaceUIWindow Extends IOleWindow
  GetBorder(a.l)
  RequestBorderSpace(a.l)
  SetBorderSpace(a.l)
  SetActiveObject(a.l, b.l)
EndInterface

; IOleInPlaceActiveObject interface definition
;
Interface IOleInPlaceActiveObject Extends IOleWindow
  TranslateAccelerator(a.l)
  OnFrameWindowActivate(a.l)
  OnDocWindowActivate(a.l)
  ResizeBorder(a.l, b.l, c.l)
  EnableModeless(a.l)
EndInterface

; IOleInPlaceFrame interface definition
;
Interface IOleInPlaceFrame Extends IOleInPlaceUIWindow
  InsertMenus(a.l, b.l)
  SetMenu(a.l, b.l, c.l)
  RemoveMenus(a.l)
  SetStatusText(a.l)
  EnableModeless(a.l)
  TranslateAccelerator(a.l, b.l)
EndInterface

; IOleInPlaceObject interface definition
;
Interface IOleInPlaceObject Extends IOleWindow
  InPlaceDeactivate()
  UIDeactivate()
  SetObjectRects(a.l, b.l)
  ReactivateAndUndo()
EndInterface

; IOleInPlaceSite interface definition
;
Interface IOleInPlaceSite Extends IOleWindow
  CanInPlaceActivate()
  OnInPlaceActivate()
  OnUIActivate()
  GetWindowContext(a.l, b.l, c.l, d.l, e.l)
  Scroll(a.l)
  OnUIDeactivate(a.l)
  OnInPlaceDeactivate()
  DiscardUndoState()
  DeactivateAndUndo()
  OnPosRectChange(a.l)
EndInterface

; IContinue interface definition
;
Interface IContinue Extends IUnknown
  FContinue()
EndInterface

; IViewObject interface definition
;
Interface IViewObject Extends IUnknown
  Draw(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l)
  GetColorSet(a.l, b.l, c.l, d.l, e.l, f.l)
  Freeze(a.l, b.l, c.l, d.l)
  Unfreeze(a.l)
  SetAdvise(a.l, b.l, c.l)
  GetAdvise(a.l, b.l, c.l)
EndInterface

; IViewObject2 interface definition
;
Interface IViewObject2 Extends IViewObject
  GetExtent(a.l, b.l, c.l, d.l)
EndInterface

; IDropSource interface definition
;
Interface IDropSource Extends IUnknown
  QueryContinueDrag(a.l, b.l)
  GiveFeedback(a.l)
EndInterface

; IDropTarget interface definition
;
Interface IDropTarget Extends IUnknown
  DragEnter(a.l, b.l, c.l, d.l)
  DragOver(a.l, b.l, c.l)
  DragLeave()
  Drop(a.l, b.l, c.l, d.l)
EndInterface

; IEnumOLEVERB interface definition
;
Interface IEnumOLEVERB Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface
