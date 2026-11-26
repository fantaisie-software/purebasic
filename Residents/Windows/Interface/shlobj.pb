
; IContextMenu interface definition
;
Interface IContextMenu Extends IUnknown
  QueryContextMenu(a.l, b.l, c.l, d.l, e.l)
  InvokeCommand(a.l)
  GetCommandString(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IContextMenu2 interface definition
;
Interface IContextMenu2 Extends IContextMenu
  HandleMenuMsg(a.l, b.l, c.l)
EndInterface

; IContextMenu3 interface definition
;
Interface IContextMenu3 Extends IContextMenu2
  HandleMenuMsg2(a.l, b.l, c.l, d.l)
EndInterface

; IPersistFolder3 interface definition
;
Interface IPersistFolder3 Extends IPersistFolder2
  InitializeEx(a.l, b.l, c.l)
  GetFolderTargetInfo(a.l)
EndInterface

; IExtractIconA interface definition
;
Interface IExtractIconA Extends IUnknown
  GetIconLocation(a.l, b.l, c.l, d.l, e.l)
  Extract(a.s, b.l, c.l, d.l, e.l)
EndInterface

; IExtractIconW interface definition
;
Interface IExtractIconW Extends IUnknown
  GetIconLocation(a.l, b.l, c.l, d.l, e.l)
  Extract(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IShellIcon interface definition
;
Interface IShellIcon Extends IUnknown
  GetIconOf(a.l, b.l, c.l)
EndInterface

; IShellIconOverlayIdentifier interface definition
;
Interface IShellIconOverlayIdentifier Extends IUnknown
  IsMemberOf(a.l, b.l)
  GetOverlayInfo(a.l, b.l, c.l, d.l)
  GetPriority(a.l)
EndInterface

; IShellIconOverlayManager interface definition
;
Interface IShellIconOverlayManager Extends IUnknown
  GetFileOverlayInfo(a.l, b.l, c.l, d.l)
  GetReservedOverlayInfo(a.l, b.l, c.l, d.l, e.l)
  RefreshOverlayImages(a.l)
  LoadNonloadedOverlayIdentifiers()
  OverlayIndexFromImageIndex(a.l, b.l, c.l)
EndInterface

; IShellIconOverlay interface definition
;
Interface IShellIconOverlay Extends IUnknown
  GetOverlayIndex(a.l, b.l)
  GetOverlayIconIndex(a.l, b.l)
EndInterface

; IShellLinkDataList interface definition
;
Interface IShellLinkDataList Extends IUnknown
  AddDataBlock(a.l)
  CopyDataBlock(a.l, b.l)
  RemoveDataBlock(a.l)
  GetFlags(a.l)
  SetFlags(a.l)
EndInterface

; IResolveShellLink interface definition
;
Interface IResolveShellLink Extends IUnknown
  ResolveShellLink(a.l, b.l, c.l)
EndInterface

; IShellExecuteHookA interface definition
;
Interface IShellExecuteHookA Extends IUnknown
  Execute(a.l)
EndInterface

; IShellExecuteHookW interface definition
;
Interface IShellExecuteHookW Extends IUnknown
  Execute(a.l)
EndInterface

; IURLSearchHook interface definition
;
Interface IURLSearchHook Extends IUnknown
  Translate(a.l, b.l)
EndInterface

; ISearchContext interface definition
;
Interface ISearchContext Extends IUnknown
  GetSearchUrl(a.l)
  GetSearchText(a.l)
  GetSearchStyle(a.l)
EndInterface

; IURLSearchHook2 interface definition
;
Interface IURLSearchHook2
  TranslateWithSearchContext(a.l, b.l, c.l)
EndInterface

; INewShortcutHookA interface definition
;
Interface INewShortcutHookA Extends IUnknown
  SetReferent(a.s, b.l)
  GetReferent(a.l, b.l)
  SetFolder(a.s)
  GetFolder(a.l, b.l)
  GetName(a.l, b.l)
  GetExtension(a.l, b.l)
EndInterface

; INewShortcutHookW interface definition
;
Interface INewShortcutHookW Extends IUnknown
  SetReferent(a.l, b.l)
  GetReferent(a.l, b.l)
  SetFolder(a.l)
  GetFolder(a.l, b.l)
  GetName(a.l, b.l)
  GetExtension(a.l, b.l)
EndInterface

; ICopyHookA interface definition
;
Interface ICopyHookA Extends IUnknown
  CopyCallback(a.l, b.l, c.l, d.s, e.l, f.s, g.l)
EndInterface

; ICopyHookW interface definition
;
Interface ICopyHookW Extends IUnknown
  CopyCallback(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IFileViewerSite interface definition
;
Interface IFileViewerSite Extends IUnknown
  SetPinnedWindow(a.l)
  GetPinnedWindow(a.l)
EndInterface

; ICommDlgBrowser interface definition
;
Interface ICommDlgBrowser Extends IUnknown
  OnDefaultCommand(a.l)
  OnStateChange(a.l, b.l)
  IncludeObject(a.l, b.l)
EndInterface

; ICommDlgBrowser2 interface definition
;
Interface ICommDlgBrowser2 Extends ICommDlgBrowser
  Notify(a.l, b.l)
  GetDefaultMenuText(a.l, b.l, c.l)
  GetViewFlags(a.l)
EndInterface

; IFileSystemBindData interface definition
;
Interface IFileSystemBindData Extends IUnknown
  SetFindData(a.l)
  GetFindData(a.l)
EndInterface

; IShellDetails interface definition
;
Interface IShellDetails Extends IUnknown
  GetDetailsOf(a.l, b.l, c.l)
  ColumnClick(a.l)
EndInterface

; IObjMgr interface definition
;
Interface IObjMgr Extends IUnknown
  Append(a.l)
  Remove(a.l)
EndInterface

; ICurrentWorkingDirectory interface definition
;
Interface ICurrentWorkingDirectory Extends IUnknown
  GetDirectory(a.l, b.l)
  SetDirectory(a.l)
EndInterface

; IACList interface definition
;
Interface IACList Extends IUnknown
  Expand(a.l)
EndInterface

; IACList2 interface definition
;
Interface IACList2
  SetOptions(a.l)
  GetOptions(a.l)
EndInterface

; IProgressDialog interface definition
;
Interface IProgressDialog Extends IUnknown
  StartProgressDialog(a.l, b.l, c.l, d.l)
  StopProgressDialog()
  SetTitle(a.l)
  SetAnimation(a.l, b.l)
  HasUserCancelled()
  SetProgress(a.l, b.l)
  SetProgress64(a.q, b.q)
  SetLine(a.l, b.l, c.l, d.l)
  SetCancelMsg(a.l, b.l)
  Timer(a.l, b.l)
EndInterface

; IInputObjectSite interface definition
;
Interface IInputObjectSite Extends IUnknown
  OnFocusChangeIS(a.l, b.l)
EndInterface

; IInputObject interface definition
;
Interface IInputObject Extends IUnknown
  UIActivateIO(a.l, b.l)
  HasFocusIO()
  TranslateAcceleratorIO(a.l)
EndInterface

; IDockingWindowSite interface definition
;
Interface IDockingWindowSite Extends IOleWindow
  GetBorderDW(a.l, b.l)
  RequestBorderSpaceDW(a.l, b.l)
  SetBorderSpaceDW(a.l, b.l)
EndInterface

; IDockingWindowFrame interface definition
;
Interface IDockingWindowFrame Extends IOleWindow
  AddToolbar(a.l, b.l, c.l)
  RemoveToolbar(a.l, b.l)
  FindToolbar(a.l, b.l, c.l)
EndInterface

; IRunnableTask interface definition
;
Interface IRunnableTask Extends IUnknown
  Run()
  Kill(a.l)
  Suspend()
  Resume()
  IsRunning()
EndInterface

; IShellTaskScheduler interface definition
;
Interface IShellTaskScheduler Extends IUnknown
  AddTask(a.l, b.l, c.l, d.l)
  RemoveTasks(a.l, b.l, c.l)
  CountTasks(a.l)
  Status(a.l, b.l)
EndInterface

; IShellTaskScheduler2 interface definition
;
Interface IShellTaskScheduler2 Extends IUnknown
  AddTask(a.l, b.l, c.l, d.l)
  RemoveTasks(a.l, b.l, c.l)
  CountTasks(a.l)
  Status(a.l, b.l)
  AddTask2(a.l, b.l, c.l, d.l, e.l)
  MoveTask(a.l, b.l, c.l, d.l)
EndInterface

; IThumbnailCapture interface definition
;
Interface IThumbnailCapture
  CaptureThumbnail(a.l, b.l, c.l)
EndInterface

; IEnumShellImageStore interface definition
;
Interface IEnumShellImageStore Extends IUnknown
  Reset()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Clone(a.l)
EndInterface

; IShellImageStore interface definition
;
Interface IShellImageStore Extends IUnknown
  Open(a.l, b.l)
  Create(a.l, b.l)
  ReleaseLock(a.l)
  Close(a.l)
  Commit(a.l)
  IsLocked()
  GetMode(a.l)
  GetCapabilities(a.l)
  AddEntry(a.l, b.l, c.l, d.l)
  GetEntry(a.l, b.l, c.l)
  DeleteEntry(a.l)
  IsEntryInStore(a.l, b.l)
  Enum(a.l)
EndInterface

; IShellFolderBand interface definition
;
Interface IShellFolderBand Extends IUnknown
  InitializeSFB(a.l, b.l)
  SetBandInfoSFB(a.l)
  GetBandInfoSFB(a.l)
EndInterface

; IDeskBarClient interface definition
;
Interface IDeskBarClient Extends IOleWindow
  SetDeskBarSite(a.l)
  SetModeDBC(a.l)
  UIActivateDBC(a.l)
  GetSize(a.l, b.l)
EndInterface

; IActiveDesktop interface definition
;
Interface IActiveDesktop Extends IUnknown
  ApplyChanges(a.l)
  GetWallpaper(a.l, b.l, c.l)
  SetWallpaper(a.l, b.l)
  GetWallpaperOptions(a.l, b.l)
  SetWallpaperOptions(a.l, b.l)
  GetPattern(a.l, b.l, c.l)
  SetPattern(a.l, b.l)
  GetDesktopItemOptions(a.l, b.l)
  SetDesktopItemOptions(a.l, b.l)
  AddDesktopItem(a.l, b.l)
  AddDesktopItemWithUI(a.l, b.l, c.l)
  ModifyDesktopItem(a.l, b.l)
  RemoveDesktopItem(a.l, b.l)
  GetDesktopItemCount(a.l, b.l)
  GetDesktopItem(a.l, b.l, c.l)
  GetDesktopItemByID(a.l, b.l, c.l)
  GenerateDesktopItemHtml(a.l, b.l, c.l)
  AddUrl(a.l, b.l, c.l, d.l)
  GetDesktopItemBySource(a.l, b.l, c.l)
EndInterface

; IActiveDesktopP interface definition
;
Interface IActiveDesktopP Extends IUnknown
  SetSafeMode(a.l)
  EnsureUpdateHTML()
  SetScheme(a.l, b.l)
  GetScheme(a.l, b.l, c.l)
EndInterface

; IADesktopP2 interface definition
;
Interface IADesktopP2 Extends IUnknown
  ReReadWallpaper()
  GetADObjectFlags(a.l, b.l)
  UpdateAllDesktopSubscriptions()
  MakeDynamicChanges(a.l)
EndInterface

; IColumnProvider interface definition
;
Interface IColumnProvider Extends IUnknown
  Initialize(a.l)
  GetColumnInfo(a.l, b.l)
  GetItemData(a.l, b.l, c.l)
EndInterface

; IDropTargetHelper interface definition
;
Interface IDropTargetHelper Extends IUnknown
  DragEnter(a.l, b.l, c.l, d.l)
  DragLeave()
  DragOver(a.l, b.l)
  Drop(a.l, b.l, c.l)
  Show(a.l)
EndInterface

; IDragSourceHelper interface definition
;
Interface IDragSourceHelper Extends IUnknown
  InitializeFromBitmap(a.l, b.l)
  InitializeFromWindow(a.l, b.l, c.l)
EndInterface

; IShellChangeNotify interface definition
;
Interface IShellChangeNotify Extends IUnknown
  OnChange(a.l, b.l, c.l)
EndInterface

; IQueryInfo interface definition
;
Interface IQueryInfo Extends IUnknown
  GetInfoTip(a.l, b.l)
  GetInfoFlags(a.l)
EndInterface

; IDefViewFrame interface definition
;
Interface IDefViewFrame Extends IUnknown
  GetWindowLV(a.l)
  ReleaseWindowLV()
  GetShellFolder(a.l)
EndInterface

; IDocViewSite interface definition
;
Interface IDocViewSite Extends IUnknown
  OnSetTitle(a.l)
EndInterface

; IInitializeObject interface definition
;
Interface IInitializeObject Extends IUnknown
  Initialize()
EndInterface

; IBanneredBar interface definition
;
Interface IBanneredBar Extends IUnknown
  SetIconSize(a.l)
  GetIconSize(a.l)
  SetBitmap(a.l)
  GetBitmap(a.l)
EndInterface

; IShellFolderViewCB interface definition
;
Interface IShellFolderViewCB Extends IUnknown
  MessageSFVCB(a.l, b.l, c.l)
EndInterface

; INamedPropertyBag interface definition
;
Interface INamedPropertyBag Extends IUnknown
  ReadPropertyNPB(a.l, b.l, c.l)
  WritePropertyNPB(a.l, b.l, c.l)
  RemovePropertyNPB(a.l, b.l)
EndInterface
