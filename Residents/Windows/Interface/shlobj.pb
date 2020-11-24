
; IContextMenu interface definition
;
Interface IContextMenu
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryContextMenu(a.l, b.l, c.l, d.l, e.l)
  InvokeCommand(a.l)
  GetCommandString(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IContextMenu2 interface definition
;
Interface IContextMenu2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryContextMenu(a.l, b.l, c.l, d.l, e.l)
  InvokeCommand(a.l)
  GetCommandString(a.l, b.l, c.l, d.l, e.l)
  HandleMenuMsg(a.l, b.l, c.l)
EndInterface

; IContextMenu3 interface definition
;
Interface IContextMenu3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryContextMenu(a.l, b.l, c.l, d.l, e.l)
  InvokeCommand(a.l)
  GetCommandString(a.l, b.l, c.l, d.l, e.l)
  HandleMenuMsg(a.l, b.l, c.l)
  HandleMenuMsg2(a.l, b.l, c.l, d.l)
EndInterface

; IPersistFolder3 interface definition
;
Interface IPersistFolder3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  Initialize(a.l)
  GetCurFolder(a.l)
  InitializeEx(a.l, b.l, c.l)
  GetFolderTargetInfo(a.l)
EndInterface

; IExtractIconA interface definition
;
Interface IExtractIconA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetIconLocation(a.l, b.l, c.l, d.l, e.l)
  Extract(a.s, b.l, c.l, d.l, e.l)
EndInterface

; IExtractIconW interface definition
;
Interface IExtractIconW
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetIconLocation(a.l, b.l, c.l, d.l, e.l)
  Extract(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IShellIcon interface definition
;
Interface IShellIcon
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetIconOf(a.l, b.l, c.l)
EndInterface

; IShellIconOverlayIdentifier interface definition
;
Interface IShellIconOverlayIdentifier
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsMemberOf(a.l, b.l)
  GetOverlayInfo(a.l, b.l, c.l, d.l)
  GetPriority(a.l)
EndInterface

; IShellIconOverlayManager interface definition
;
Interface IShellIconOverlayManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFileOverlayInfo(a.l, b.l, c.l, d.l)
  GetReservedOverlayInfo(a.l, b.l, c.l, d.l, e.l)
  RefreshOverlayImages(a.l)
  LoadNonloadedOverlayIdentifiers()
  OverlayIndexFromImageIndex(a.l, b.l, c.l)
EndInterface

; IShellIconOverlay interface definition
;
Interface IShellIconOverlay
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetOverlayIndex(a.l, b.l)
  GetOverlayIconIndex(a.l, b.l)
EndInterface

; IShellLinkDataList interface definition
;
Interface IShellLinkDataList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddDataBlock(a.l)
  CopyDataBlock(a.l, b.l)
  RemoveDataBlock(a.l)
  GetFlags(a.l)
  SetFlags(a.l)
EndInterface

; IResolveShellLink interface definition
;
Interface IResolveShellLink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ResolveShellLink(a.l, b.l, c.l)
EndInterface

; IShellExecuteHookA interface definition
;
Interface IShellExecuteHookA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Execute(a.l)
EndInterface

; IShellExecuteHookW interface definition
;
Interface IShellExecuteHookW
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Execute(a.l)
EndInterface

; IURLSearchHook interface definition
;
Interface IURLSearchHook
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Translate(a.l, b.l)
EndInterface

; ISearchContext interface definition
;
Interface ISearchContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface INewShortcutHookA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetReferent(a.s, b.l)
  GetReferent(a.l, b.l)
  SetFolder(a.s)
  GetFolder(a.l, b.l)
  GetName(a.l, b.l)
  GetExtension(a.l, b.l)
EndInterface

; INewShortcutHookW interface definition
;
Interface INewShortcutHookW
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetReferent(a.l, b.l)
  GetReferent(a.l, b.l)
  SetFolder(a.l)
  GetFolder(a.l, b.l)
  GetName(a.l, b.l)
  GetExtension(a.l, b.l)
EndInterface

; ICopyHookA interface definition
;
Interface ICopyHookA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CopyCallback(a.l, b.l, c.l, d.s, e.l, f.s, g.l)
EndInterface

; ICopyHookW interface definition
;
Interface ICopyHookW
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CopyCallback(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IFileViewerSite interface definition
;
Interface IFileViewerSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetPinnedWindow(a.l)
  GetPinnedWindow(a.l)
EndInterface

; ICommDlgBrowser interface definition
;
Interface ICommDlgBrowser
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnDefaultCommand(a.l)
  OnStateChange(a.l, b.l)
  IncludeObject(a.l, b.l)
EndInterface

; ICommDlgBrowser2 interface definition
;
Interface ICommDlgBrowser2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnDefaultCommand(a.l)
  OnStateChange(a.l, b.l)
  IncludeObject(a.l, b.l)
  Notify(a.l, b.l)
  GetDefaultMenuText(a.l, b.l, c.l)
  GetViewFlags(a.l)
EndInterface

; IFileSystemBindData interface definition
;
Interface IFileSystemBindData
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFindData(a.l)
  GetFindData(a.l)
EndInterface

; IShellDetails interface definition
;
Interface IShellDetails
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDetailsOf(a.l, b.l, c.l)
  ColumnClick(a.l)
EndInterface

; IObjMgr interface definition
;
Interface IObjMgr
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Append(a.l)
  Remove(a.l)
EndInterface

; ICurrentWorkingDirectory interface definition
;
Interface ICurrentWorkingDirectory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDirectory(a.l, b.l)
  SetDirectory(a.l)
EndInterface

; IACList interface definition
;
Interface IACList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IProgressDialog
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IInputObjectSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnFocusChangeIS(a.l, b.l)
EndInterface

; IInputObject interface definition
;
Interface IInputObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  UIActivateIO(a.l, b.l)
  HasFocusIO()
  TranslateAcceleratorIO(a.l)
EndInterface

; IDockingWindowSite interface definition
;
Interface IDockingWindowSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  GetBorderDW(a.l, b.l)
  RequestBorderSpaceDW(a.l, b.l)
  SetBorderSpaceDW(a.l, b.l)
EndInterface

; IDockingWindowFrame interface definition
;
Interface IDockingWindowFrame
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  AddToolbar(a.l, b.l, c.l)
  RemoveToolbar(a.l, b.l)
  FindToolbar(a.l, b.l, c.l)
EndInterface

; IRunnableTask interface definition
;
Interface IRunnableTask
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Run()
  Kill(a.l)
  Suspend()
  Resume()
  IsRunning()
EndInterface

; IShellTaskScheduler interface definition
;
Interface IShellTaskScheduler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddTask(a.l, b.l, c.l, d.l)
  RemoveTasks(a.l, b.l, c.l)
  CountTasks(a.l)
  Status(a.l, b.l)
EndInterface

; IShellTaskScheduler2 interface definition
;
Interface IShellTaskScheduler2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IEnumShellImageStore
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Reset()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Clone(a.l)
EndInterface

; IShellImageStore interface definition
;
Interface IShellImageStore
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IShellFolderBand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitializeSFB(a.l, b.l)
  SetBandInfoSFB(a.l)
  GetBandInfoSFB(a.l)
EndInterface

; IDeskBarClient interface definition
;
Interface IDeskBarClient
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  SetDeskBarSite(a.l)
  SetModeDBC(a.l)
  UIActivateDBC(a.l)
  GetSize(a.l, b.l)
EndInterface

; IActiveDesktop interface definition
;
Interface IActiveDesktop
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IActiveDesktopP
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetSafeMode(a.l)
  EnsureUpdateHTML()
  SetScheme(a.l, b.l)
  GetScheme(a.l, b.l, c.l)
EndInterface

; IADesktopP2 interface definition
;
Interface IADesktopP2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ReReadWallpaper()
  GetADObjectFlags(a.l, b.l)
  UpdateAllDesktopSubscriptions()
  MakeDynamicChanges(a.l)
EndInterface

; IColumnProvider interface definition
;
Interface IColumnProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  GetColumnInfo(a.l, b.l)
  GetItemData(a.l, b.l, c.l)
EndInterface

; IDropTargetHelper interface definition
;
Interface IDropTargetHelper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DragEnter(a.l, b.l, c.l, d.l)
  DragLeave()
  DragOver(a.l, b.l)
  Drop(a.l, b.l, c.l)
  Show(a.l)
EndInterface

; IDragSourceHelper interface definition
;
Interface IDragSourceHelper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitializeFromBitmap(a.l, b.l)
  InitializeFromWindow(a.l, b.l, c.l)
EndInterface

; IShellChangeNotify interface definition
;
Interface IShellChangeNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnChange(a.l, b.l, c.l)
EndInterface

; IQueryInfo interface definition
;
Interface IQueryInfo
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetInfoTip(a.l, b.l)
  GetInfoFlags(a.l)
EndInterface

; IDefViewFrame interface definition
;
Interface IDefViewFrame
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindowLV(a.l)
  ReleaseWindowLV()
  GetShellFolder(a.l)
EndInterface

; IDocViewSite interface definition
;
Interface IDocViewSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  OnSetTitle(a.l)
EndInterface

; IInitializeObject interface definition
;
Interface IInitializeObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize()
EndInterface

; IBanneredBar interface definition
;
Interface IBanneredBar
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetIconSize(a.l)
  GetIconSize(a.l)
  SetBitmap(a.l)
  GetBitmap(a.l)
EndInterface

; IShellFolderViewCB interface definition
;
Interface IShellFolderViewCB
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  MessageSFVCB(a.l, b.l, c.l)
EndInterface

; INamedPropertyBag interface definition
;
Interface INamedPropertyBag
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ReadPropertyNPB(a.l, b.l, c.l)
  WritePropertyNPB(a.l, b.l, c.l)
  RemovePropertyNPB(a.l, b.l)
EndInterface
