
; IPersistFolder interface definition
;
Interface IPersistFolder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  Initialize(a.l)
EndInterface

; IPersistFolder2 interface definition
;
Interface IPersistFolder2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  Initialize(a.l)
  GetCurFolder(a.l)
EndInterface

; IPersistIDList interface definition
;
Interface IPersistIDList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClassID(a.l)
  SetIDList(a.l)
  GetIDList(a.l)
EndInterface

; IEnumIDList interface definition
;
Interface IEnumIDList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IShellFolder interface definition
;
Interface IShellFolder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ParseDisplayName(a.l, b.l, c.p-unicode, d.l, e.l, f.l)
  EnumObjects(a.l, b.l, c.l)
  BindToObject(a.l, b.l, c.l, d.l)
  BindToStorage(a.l, b.l, c.l, d.l)
  CompareIDs(a.l, b.l, c.l)
  CreateViewObject(a.l, b.l, c.l)
  GetAttributesOf(a.l, b.l, c.l)
  GetUIObjectOf(a.l, b.l, c.l, d.l, e.l, f.l)
  GetDisplayNameOf(a.l, b.l, c.l)
  SetNameOf(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IEnumExtraSearch interface definition
;
Interface IEnumExtraSearch
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IShellFolder2 interface definition
;
Interface IShellFolder2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ParseDisplayName(a.l, b.l, c.p-unicode, d.l, e.l, f.l)
  EnumObjects(a.l, b.l, c.l)
  BindToObject(a.l, b.l, c.l, d.l)
  BindToStorage(a.l, b.l, c.l, d.l)
  CompareIDs(a.l, b.l, c.l)
  CreateViewObject(a.l, b.l, c.l)
  GetAttributesOf(a.l, b.l, c.l)
  GetUIObjectOf(a.l, b.l, c.l, d.l, e.l, f.l)
  GetDisplayNameOf(a.l, b.l, c.l)
  SetNameOf(a.l, b.l, c.l, d.l, e.l)
  GetDefaultSearchGUID(a.l)
  EnumSearches(a.l)
  GetDefaultColumn(a.l, b.l, c.l)
  GetDefaultColumnState(a.l, b.l)
  GetDetailsEx(a.l, b.l, c.l)
  GetDetailsOf(a.l, b.l, c.l)
  MapColumnToSCID(a.l, b.l)
EndInterface

; IShellView interface definition
;
Interface IShellView
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  TranslateAccelerator(a.l)
  EnableModeless(a.l)
  UIActivate(a.l)
  Refresh()
  CreateViewWindow(a.l, b.l, c.l, d.l, e.l)
  DestroyViewWindow()
  GetCurrentInfo(a.l)
  AddPropertySheetPages(a.l, b.l, c.l)
  SaveViewState()
  SelectItem(a.l, b.l)
  GetItemObject(a.l, b.l, c.l)
EndInterface

; IShellView2 interface definition
;
Interface IShellView2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  TranslateAccelerator(a.l)
  EnableModeless(a.l)
  UIActivate(a.l)
  Refresh()
  CreateViewWindow(a.l, b.l, c.l, d.l, e.l)
  DestroyViewWindow()
  GetCurrentInfo(a.l)
  AddPropertySheetPages(a.l, b.l, c.l)
  SaveViewState()
  SelectItem(a.l, b.l)
  GetItemObject(a.l, b.l, c.l)
  GetView(a.l, b.l)
  CreateViewWindow2(a.l)
  HandleRename(a.l)
  SelectAndPositionItem(a.l, b.l, c.l)
EndInterface

; IFolderView interface definition
;
Interface IFolderView
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCurrentViewMode(a.l)
  SetCurrentViewMode(a.l)
  GetFolder(a.l, b.l)
  Item(a.l, b.l)
  ItemCount(a.l, b.l)
  Items(a.l, b.l, c.l)
  GetSelectionMarkedItem(a.l)
  GetFocusedItem(a.l)
  GetItemPosition(a.l, b.l)
  GetSpacing(a.l)
  GetDefaultSpacing(a.l)
  GetAutoArrange()
  SelectItem(a.l, b.l)
  SelectAndPositionItems(a.l, b.l, c.l, d.l)
EndInterface

; IFolderFilterSite interface definition
;
Interface IFolderFilterSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFilter(a.l)
EndInterface

; IFolderFilter interface definition
;
Interface IFolderFilter
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ShouldShow(a.l, b.l, c.l)
  GetEnumFlags(a.l, b.l, c.l, d.l)
EndInterface

; IShellBrowser interface definition
;
Interface IShellBrowser
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  InsertMenusSB(a.l, b.l)
  SetMenuSB(a.l, b.l, c.l)
  RemoveMenusSB(a.l)
  SetStatusTextSB(a.l)
  EnableModelessSB(a.l)
  TranslateAcceleratorSB(a.l, b.l)
  BrowseObject(a.l, b.l)
  GetViewStateStream(a.l, b.l)
  GetControlWindow(a.l, b.l)
  SendControlMsg(a.l, b.l, c.l, d.l, e.l)
  QueryActiveShellView(a.l)
  OnViewWindowActive(a.l)
  SetToolbarItems(a.l, b.l, c.l)
EndInterface

; IProfferService interface definition
;
Interface IProfferService
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ProfferService(a.l, b.l, c.l)
  RevokeService(a.l)
EndInterface

; IPropertyUI interface definition
;
Interface IPropertyUI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ParsePropertyName(a.l, b.l, c.l, d.l)
  GetCannonicalName(a.l, b.l, c.p-unicode, d.l)
  GetDisplayName(a.l, b.l, c.l, d.p-unicode, e.l)
  GetPropertyDescription(a.l, b.l, c.p-unicode, d.l)
  GetDefaultWidth(a.l, b.l, c.l)
  GetFlags(a.l, b.l, c.l)
  FormatForDisplay(a.l, b.l, c.l, d.l, e.p-unicode, f.l)
  GetHelpInfo(a.l, b.l, c.p-unicode, d.l, e.l)
EndInterface

; ICategoryProvider interface definition
;
Interface ICategoryProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CanCategorizeOnSCID(a.l)
  GetDefaultCategory(a.l, b.l)
  GetCategoryForSCID(a.l, b.l)
  EnumCategories(a.l)
  GetCategoryName(a.l, b.p-unicode, c.l)
  CreateCategory(a.l, b.l, c.l)
EndInterface

; ICategorizer interface definition
;
Interface ICategorizer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDescription(a.p-unicode, b.l)
  GetCategory(a.l, b.l, c.l)
  GetCategoryInfo(a.l, b.l)
  CompareCategory(a.l, b.l, c.l)
EndInterface

; IShellLinkA interface definition
;
Interface IShellLinkA
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPath(a.p-ascii, b.l, c.l, d.l)
  GetIDList(a.l)
  SetIDList(a.l)
  GetDescription(a.i, b.l)
  SetDescription(a.p-ascii)
  GetWorkingDirectory(a.i, b.l)
  SetWorkingDirectory(a.p-ascii)
  GetArguments(a.i, b.l)
  SetArguments(a.p-ascii)
  GetHotkey(a.l)
  SetHotkey(a.l)
  GetShowCmd(a.l)
  SetShowCmd(a.l)
  GetIconLocation(a.i, b.l, c.l)
  SetIconLocation(a.p-ascii, b.l)
  SetRelativePath(a.p-ascii, b.l)
  Resolve(a.l, b.l)
  SetPath(a.p-ascii)
EndInterface

; IShellLinkW interface definition
;
Interface IShellLinkW
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPath(a.i, b.l, c.l, d.l)  ; the user has to pass a buffer, so auto conversion with p-unicode is wrong here
  GetIDList(a.l)
  SetIDList(a.l)
  GetDescription(a.i, b.l)
  SetDescription(a.p-unicode)
  GetWorkingDirectory(a.i, b.l)
  SetWorkingDirectory(a.p-unicode)
  GetArguments(a.i, b.l)
  SetArguments(a.p-unicode)
  GetHotkey(a.l)
  SetHotkey(a.l)
  GetShowCmd(a.l)
  SetShowCmd(a.l)
  GetIconLocation(a.i, b.l, c.l)
  SetIconLocation(a.p-unicode, b.l)
  SetRelativePath(a.p-unicode, b.l)
  Resolve(a.l, b.l)
  SetPath(a.p-unicode)
EndInterface

; IActionProgressDialog interface definition
;
Interface IActionProgressDialog
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l)
  Stop()
EndInterface

; IHWEventHandler interface definition
;
Interface IHWEventHandler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  HandleEvent(a.l, b.l, c.l)
  HandleEventWithContent(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IQueryCancelAutoPlay interface definition
;
Interface IQueryCancelAutoPlay
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AllowAutoPlay(a.l, b.l, c.l, d.l)
EndInterface

; IActionProgress interface definition
;
Interface IActionProgress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin(a.l, b.l)
  UpdateProgress(a.l, b.l)
  UpdateText(a.l, b.l, c.l)
  QueryCancel(a.l)
  ResetCancel()
  End()
EndInterface

; IShellExtInit interface definition
;
Interface IShellExtInit
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l)
EndInterface

; IShellPropSheetExt interface definition
;
Interface IShellPropSheetExt
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddPages(a.l, b.l)
  ReplacePage(a.l, b.l, c.l)
EndInterface

; IRemoteComputer interface definition
;
Interface IRemoteComputer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l)
EndInterface

; IQueryContinue interface definition
;
Interface IQueryContinue
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryContinue()
EndInterface

; IUserNotification interface definition
;
Interface IUserNotification
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetBalloonInfo(a.l, b.l, c.l)
  SetBalloonRetry(a.l, b.l, c.l)
  SetIconInfo(a.l, b.l)
  Show(a.l, b.l)
  PlaySound(a.l)
EndInterface

; IItemNameLimits interface definition
;
Interface IItemNameLimits
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetValidCharacters(a.l, b.l)
  GetMaxLength(a.l, b.l)
EndInterface

; INetCrawler interface definition
;
Interface INetCrawler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Update(a.l)
EndInterface

; IExtractImage interface definition
;
Interface IExtractImage
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLocation(a.p-unicode, b.l, c.l, d.l, e.l, f.l)
  Extract(a.l)
EndInterface

; IExtractImage2 interface definition
;
Interface IExtractImage2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetLocation(a.p-unicode, b.l, c.l, d.l, e.l, f.l)
  Extract(a.l)
  GetDateStamp(a.l)
EndInterface

; IUserEventTimerCallback interface definition
;
Interface IUserEventTimerCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  UserEventTimerProc(a.l, b.l)
EndInterface

; IUserEventTimer interface definition
;
Interface IUserEventTimer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetUserEventTimer(a.l, b.l, c.l, d.l, e.l)
  KillUserEventTimer(a.l, b.l)
  GetUserEventTimerElapsed(a.l, b.l, c.l)
  InitTimerTickInterval(a.l)
EndInterface

; IDockingWindow interface definition
;
Interface IDockingWindow
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  ShowDW(a.l)
  CloseDW(a.l)
  ResizeBorderDW(a.l, b.l, c.l)
EndInterface

; IDeskBand interface definition
;
Interface IDeskBand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  ShowDW(a.l)
  CloseDW(a.l)
  ResizeBorderDW(a.l, b.l, c.l)
  GetBandInfo(a.l, b.l, c.l)
EndInterface

; ITaskbarList interface definition
;
Interface ITaskbarList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  HrInit()
  AddTab(a.l)
  DeleteTab(a.l)
  ActivateTab(a.l)
  SetActiveAlt(a.l)
EndInterface

; ITaskbarList2 interface definition
;
Interface ITaskbarList2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  HrInit()
  AddTab(a.l)
  DeleteTab(a.l)
  ActivateTab(a.l)
  SetActiveAlt(a.l)
  MarkFullscreenWindow(a.l, b.l)
EndInterface

; ; ICDBurn interface definition
; ;
; Interface ICDBurn
;   QueryInterface(a.l, b.l)
;   AddRef()
;   Release()
;   GetRecorderDriveLetter(a.p-unicode, b.l)
;   Burn(a.l)
;   HasRecordableDrive(a.l)
; EndInterface

; IWizardSite interface definition
;
Interface IWizardSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPreviousPage(a.l)
  GetNextPage(a.l)
  GetCancelledPage(a.l)
EndInterface

; IWizardExtension interface definition
;
Interface IWizardExtension
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddPages(a.l, b.l, c.l)
  GetFirstPage(a.l)
  GetLastPage(a.l)
EndInterface

; IWebWizardExtension interface definition
;
Interface IWebWizardExtension
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddPages(a.l, b.l, c.l)
  GetFirstPage(a.l)
  GetLastPage(a.l)
  SetInitialURL(a.l)
  SetErrorURL(a.l)
EndInterface

; IPublishingWizard interface definition
;
Interface IPublishingWizard
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddPages(a.l, b.l, c.l)
  GetFirstPage(a.l)
  GetLastPage(a.l)
  Initialize(a.l, b.l, c.l)
  GetTransferManifest(a.l, b.l)
EndInterface

; IFolderViewHost interface definition
;
Interface IFolderViewHost
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l)
EndInterface

; IAutoCompleteDropDown interface definition
;
Interface IAutoCompleteDropDown
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDropDownStatus(a.l, b.l)
  ResetEnumerator()
EndInterface

; IModalWindow interface definition
;
Interface IModalWindow
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Show(a.l)
EndInterface

; IPassportWizard interface definition
;
Interface IPassportWizard
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Show(a.l)
  SetOptions(a.l)
EndInterface

; ICDBurnExt interface definition
;
Interface ICDBurnExt
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSupportedActionTypes(a.l)
EndInterface

; IDVGetEnum interface definition
;
Interface IDVGetEnum
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetEnumReadyCallback(a.l, b.l)
  CreateEnumIDListFromContents(a.l, b.l, c.l)
EndInterface

; IInsertItem interface definition
;
Interface IInsertItem
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InsertItem(a.l)
EndInterface

; IDeskBar interface definition
;
Interface IDeskBar
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  SetClient(a.l)
  GetClient(a.l)
  OnPosRectChangeDB(a.l)
EndInterface

; IMenuBand interface definition
;
Interface IMenuBand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsMenuMessage(a.l)
  TranslateMenuMessage(a.l, b.l)
EndInterface

; IFolderBandPriv interface definition
;
Interface IFolderBandPriv
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetCascade(a.l)
  SetAccelerators(a.l)
  SetNoIcons(a.l)
  SetNoText(a.l)
EndInterface

; IBandSite interface definition
;
Interface IBandSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AddBand(a.l)
  EnumBands(a.l, b.l)
  QueryBand(a.l, b.l, c.l, d.p-unicode, e.l)
  SetBandState(a.l, b.l, c.l)
  RemoveBand(a.l)
  GetBandObject(a.l, b.l, c.l)
  SetBandSiteInfo(a.l)
  GetBandSiteInfo(a.l)
EndInterface

; INamespaceWalkCB interface definition
;
Interface INamespaceWalkCB
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FoundItem(a.l, b.l)
  EnterFolder(a.l, b.l)
  LeaveFolder(a.l, b.l)
  InitializeProgressDialog(a.l, b.l)
EndInterface

; INamespaceWalk interface definition
;
Interface INamespaceWalk
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Walk(a.l, b.l, c.l, d.l)
  GetIDArrayResult(a.l, b.l)
EndInterface

; IRegTreeItem interface definition
;
Interface IRegTreeItem
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCheckState(a.l)
  SetCheckState(a.l)
EndInterface

; IMenuPopup interface definition
;
Interface IMenuPopup
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetWindow(a.l)
  ContextSensitiveHelp(a.l)
  SetClient(a.l)
  GetClient(a.l)
  OnPosRectChangeDB(a.l)
  Popup(a.l, b.l, c.l)
  OnSelect(a.l)
  SetSubMenu(a.l, b.l)
EndInterface

; IShellItem interface definition
;
Interface IShellItem
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  BindToHandler(a.l, b.l, c.l, d.l)
  GetParent(a.l)
  GetDisplayName(a.l, b.l)
  GetAttributes(a.l, b.l)
  Compare(a.l, b.l, c.l)
EndInterface

; IImageRecompress interface definition
;
Interface IImageRecompress
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RecompressImage(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IDefViewSafety interface definition
;
Interface IDefViewSafety
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsSafePage()
EndInterface

; IContextMenuSite interface definition
;
Interface IContextMenuSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  DoContextMenuPopup(a.l, b.l, c.l)
EndInterface

; IDelegateFolder interface definition
;
Interface IDelegateFolder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetItemAlloc(a.l)
EndInterface

; IBrowserFrameOptions interface definition
;
Interface IBrowserFrameOptions
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFrameOptions(a.l, b.l)
EndInterface

; INewWindowManager interface definition
;
Interface INewWindowManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EvaluateNewWindow(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IShellMenuCallback interface definition
;
Interface IShellMenuCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CallbackSM(a.l, b.l, c.l, d.l)
EndInterface

; IAttachmentExecute interface definition
;
Interface IAttachmentExecute
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetClientTitle(a.l)
  SetClientGuid(a.l)
  SetLocalPath(a.l)
  SetFileName(a.l)
  SetSource(a.l)
  SetReferrer(a.l)
  CheckPolicy()
  Prompt(a.l, b.l, c.l)
  Save()
  Execute(a.l, b.l, c.l)
  SaveWithUI(a.l)
  ClearClientState()
EndInterface

; IShellMenu interface definition
;
Interface IShellMenu
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l, d.l)
  GetMenuInfo(a.l, b.l, c.l, d.l)
  SetShellFolder(a.l, b.l, c.l, d.l)
  GetShellFolder(a.l, b.l, c.l, d.l)
  SetMenu(a.l, b.l, c.l)
  GetMenu(a.l, b.l, c.l)
  InvalidateItem(a.l, b.l)
  GetState(a.l)
  SetMenuToolbar(a.l, b.l)
EndInterface
