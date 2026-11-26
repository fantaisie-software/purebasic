
; IPersistFolder interface definition
;
Interface IPersistFolder Extends IPersist
  Initialize(a.l)
EndInterface

; IPersistFolder2 interface definition
;
Interface IPersistFolder2 Extends IPersistFolder
  GetCurFolder(a.l)
EndInterface

; IPersistIDList interface definition
;
Interface IPersistIDList Extends IPersist
  SetIDList(a.l)
  GetIDList(a.l)
EndInterface

; IEnumIDList interface definition
;
Interface IEnumIDList Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IShellFolder interface definition
;
Interface IShellFolder Extends IUnknown
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
Interface IEnumExtraSearch Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IShellFolder2 interface definition
;
Interface IShellFolder2 Extends IShellFolder
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
Interface IShellView Extends IOleWindow
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
Interface IShellView2 Extends IShellView
  GetView(a.l, b.l)
  CreateViewWindow2(a.l)
  HandleRename(a.l)
  SelectAndPositionItem(a.l, b.l, c.l)
EndInterface

; IFolderView interface definition
;
Interface IFolderView Extends IUnknown
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
Interface IFolderFilterSite Extends IUnknown
  SetFilter(a.l)
EndInterface

; IFolderFilter interface definition
;
Interface IFolderFilter Extends IUnknown
  ShouldShow(a.l, b.l, c.l)
  GetEnumFlags(a.l, b.l, c.l, d.l)
EndInterface

; IShellBrowser interface definition
;
Interface IShellBrowser Extends IOleWindow
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
Interface IProfferService Extends IUnknown
  ProfferService(a.l, b.l, c.l)
  RevokeService(a.l)
EndInterface

; IPropertyUI interface definition
;
Interface IPropertyUI Extends IUnknown
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
Interface ICategoryProvider Extends IUnknown
  CanCategorizeOnSCID(a.l)
  GetDefaultCategory(a.l, b.l)
  GetCategoryForSCID(a.l, b.l)
  EnumCategories(a.l)
  GetCategoryName(a.l, b.p-unicode, c.l)
  CreateCategory(a.l, b.l, c.l)
EndInterface

; ICategorizer interface definition
;
Interface ICategorizer Extends IUnknown
  GetDescription(a.p-unicode, b.l)
  GetCategory(a.l, b.l, c.l)
  GetCategoryInfo(a.l, b.l)
  CompareCategory(a.l, b.l, c.l)
EndInterface

; IShellLinkA interface definition
;
Interface IShellLinkA Extends IUnknown
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
Interface IShellLinkW Extends IUnknown
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
Interface IActionProgressDialog Extends IUnknown
  Initialize(a.l, b.l, c.l)
  Stop()
EndInterface

; IHWEventHandler interface definition
;
Interface IHWEventHandler Extends IUnknown
  Initialize(a.l)
  HandleEvent(a.l, b.l, c.l)
  HandleEventWithContent(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IQueryCancelAutoPlay interface definition
;
Interface IQueryCancelAutoPlay Extends IUnknown
  AllowAutoPlay(a.l, b.l, c.l, d.l)
EndInterface

; IActionProgress interface definition
;
Interface IActionProgress Extends IUnknown
  Begin(a.l, b.l)
  UpdateProgress(a.l, b.l)
  UpdateText(a.l, b.l, c.l)
  QueryCancel(a.l)
  ResetCancel()
  End()
EndInterface

; IShellExtInit interface definition
;
Interface IShellExtInit Extends IUnknown
  Initialize(a.l, b.l, c.l)
EndInterface

; IShellPropSheetExt interface definition
;
Interface IShellPropSheetExt Extends IUnknown
  AddPages(a.l, b.l)
  ReplacePage(a.l, b.l, c.l)
EndInterface

; IRemoteComputer interface definition
;
Interface IRemoteComputer Extends IUnknown
  Initialize(a.l, b.l)
EndInterface

; IQueryContinue interface definition
;
Interface IQueryContinue Extends IUnknown
  QueryContinue()
EndInterface

; IUserNotification interface definition
;
Interface IUserNotification Extends IUnknown
  SetBalloonInfo(a.l, b.l, c.l)
  SetBalloonRetry(a.l, b.l, c.l)
  SetIconInfo(a.l, b.l)
  Show(a.l, b.l)
  PlaySound(a.l)
EndInterface

; IItemNameLimits interface definition
;
Interface IItemNameLimits Extends IUnknown
  GetValidCharacters(a.l, b.l)
  GetMaxLength(a.l, b.l)
EndInterface

; INetCrawler interface definition
;
Interface INetCrawler Extends IUnknown
  Update(a.l)
EndInterface

; IExtractImage interface definition
;
Interface IExtractImage Extends IUnknown
  GetLocation(a.p-unicode, b.l, c.l, d.l, e.l, f.l)
  Extract(a.l)
EndInterface

; IExtractImage2 interface definition
;
Interface IExtractImage2 Extends IExtractImage
  GetDateStamp(a.l)
EndInterface

; IUserEventTimerCallback interface definition
;
Interface IUserEventTimerCallback Extends IUnknown
  UserEventTimerProc(a.l, b.l)
EndInterface

; IUserEventTimer interface definition
;
Interface IUserEventTimer Extends IUnknown
  SetUserEventTimer(a.l, b.l, c.l, d.l, e.l)
  KillUserEventTimer(a.l, b.l)
  GetUserEventTimerElapsed(a.l, b.l, c.l)
  InitTimerTickInterval(a.l)
EndInterface

; IDockingWindow interface definition
;
Interface IDockingWindow Extends IOleWindow
  ShowDW(a.l)
  CloseDW(a.l)
  ResizeBorderDW(a.l, b.l, c.l)
EndInterface

; IDeskBand interface definition
;
Interface IDeskBand Extends IDockingWindow
  GetBandInfo(a.l, b.l, c.l)
EndInterface

; ITaskbarList interface definition
;
Interface ITaskbarList Extends IUnknown
  HrInit()
  AddTab(a.l)
  DeleteTab(a.l)
  ActivateTab(a.l)
  SetActiveAlt(a.l)
EndInterface

; ITaskbarList2 interface definition
;
Interface ITaskbarList2 Extends ITaskbarList
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
Interface IWizardSite Extends IUnknown
  GetPreviousPage(a.l)
  GetNextPage(a.l)
  GetCancelledPage(a.l)
EndInterface

; IWizardExtension interface definition
;
Interface IWizardExtension Extends IUnknown
  AddPages(a.l, b.l, c.l)
  GetFirstPage(a.l)
  GetLastPage(a.l)
EndInterface

; IWebWizardExtension interface definition
;
Interface IWebWizardExtension Extends IWizardExtension
  SetInitialURL(a.l)
  SetErrorURL(a.l)
EndInterface

; IPublishingWizard interface definition
;
Interface IPublishingWizard Extends IWizardExtension
  Initialize(a.l, b.l, c.l)
  GetTransferManifest(a.l, b.l)
EndInterface

; IFolderViewHost interface definition
;
Interface IFolderViewHost Extends IUnknown
  Initialize(a.l, b.l, c.l)
EndInterface

; IAutoCompleteDropDown interface definition
;
Interface IAutoCompleteDropDown Extends IUnknown
  GetDropDownStatus(a.l, b.l)
  ResetEnumerator()
EndInterface

; IModalWindow interface definition
;
Interface IModalWindow Extends IUnknown
  Show(a.l)
EndInterface

; IPassportWizard interface definition
;
Interface IPassportWizard Extends IUnknown
  Show(a.l)
  SetOptions(a.l)
EndInterface

; ICDBurnExt interface definition
;
Interface ICDBurnExt Extends IUnknown
  GetSupportedActionTypes(a.l)
EndInterface

; IDVGetEnum interface definition
;
Interface IDVGetEnum Extends IUnknown
  SetEnumReadyCallback(a.l, b.l)
  CreateEnumIDListFromContents(a.l, b.l, c.l)
EndInterface

; IInsertItem interface definition
;
Interface IInsertItem Extends IUnknown
  InsertItem(a.l)
EndInterface

; IDeskBar interface definition
;
Interface IDeskBar Extends IOleWindow
  SetClient(a.l)
  GetClient(a.l)
  OnPosRectChangeDB(a.l)
EndInterface

; IMenuBand interface definition
;
Interface IMenuBand Extends IUnknown
  IsMenuMessage(a.l)
  TranslateMenuMessage(a.l, b.l)
EndInterface

; IFolderBandPriv interface definition
;
Interface IFolderBandPriv Extends IUnknown
  SetCascade(a.l)
  SetAccelerators(a.l)
  SetNoIcons(a.l)
  SetNoText(a.l)
EndInterface

; IBandSite interface definition
;
Interface IBandSite Extends IUnknown
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
Interface INamespaceWalkCB Extends IUnknown
  FoundItem(a.l, b.l)
  EnterFolder(a.l, b.l)
  LeaveFolder(a.l, b.l)
  InitializeProgressDialog(a.l, b.l)
EndInterface

; INamespaceWalk interface definition
;
Interface INamespaceWalk Extends IUnknown
  Walk(a.l, b.l, c.l, d.l)
  GetIDArrayResult(a.l, b.l)
EndInterface

; IRegTreeItem interface definition
;
Interface IRegTreeItem Extends IUnknown
  GetCheckState(a.l)
  SetCheckState(a.l)
EndInterface

; IMenuPopup interface definition
;
Interface IMenuPopup Extends IDeskBar
  Popup(a.l, b.l, c.l)
  OnSelect(a.l)
  SetSubMenu(a.l, b.l)
EndInterface

; IShellItem interface definition
;
Interface IShellItem Extends IUnknown
  BindToHandler(a.l, b.l, c.l, d.l)
  GetParent(a.l)
  GetDisplayName(a.l, b.l)
  GetAttributes(a.l, b.l)
  Compare(a.l, b.l, c.l)
EndInterface

; IImageRecompress interface definition
;
Interface IImageRecompress Extends IUnknown
  RecompressImage(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IDefViewSafety interface definition
;
Interface IDefViewSafety Extends IUnknown
  IsSafePage()
EndInterface

; IContextMenuSite interface definition
;
Interface IContextMenuSite Extends IUnknown
  DoContextMenuPopup(a.l, b.l, c.l)
EndInterface

; IDelegateFolder interface definition
;
Interface IDelegateFolder Extends IUnknown
  SetItemAlloc(a.l)
EndInterface

; IBrowserFrameOptions interface definition
;
Interface IBrowserFrameOptions Extends IUnknown
  GetFrameOptions(a.l, b.l)
EndInterface

; INewWindowManager interface definition
;
Interface INewWindowManager Extends IUnknown
  EvaluateNewWindow(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IShellMenuCallback interface definition
;
Interface IShellMenuCallback Extends IUnknown
  CallbackSM(a.l, b.l, c.l, d.l)
EndInterface

; IAttachmentExecute interface definition
;
Interface IAttachmentExecute Extends IUnknown
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
Interface IShellMenu Extends IUnknown
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
