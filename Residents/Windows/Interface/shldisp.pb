
; IFolderViewOC interface definition
;
Interface IFolderViewOC Extends IDispatch
  SetFolderView(a.l)
EndInterface

; DShellFolderViewEvents interface definition
;
Interface DShellFolderViewEvents Extends IDispatch
EndInterface

; DFConstraint interface definition
;
Interface DFConstraint Extends IDispatch
  get_Name(a.l)
  get_Value(a.l)
EndInterface

; ISearchCommandExt interface definition
;
Interface ISearchCommandExt Extends IDispatch
  ClearResults()
  NavigateToSearchResults()
  get_ProgressText(a.l)
  SaveSearch()
  GetErrorInfo(a.l, b.l)
  SearchFor(a.l)
  GetScopeInfo(a.p-bstr, b.l)
  RestoreSavedSearch(a.l)
  Execute(a.l, b.l, c.l)
  AddConstraint(a.p-bstr, b.p-variant)
  GetNextConstraint(a.l, b.l)
EndInterface

; FolderItem interface definition
;
Interface FolderItem Extends IDispatch
  get_Application(a.l)
  get_Parent(a.l)
  get_Name(a.l)
  put_Name(a.p-bstr)
  get_Path(a.l)
  get_GetLink(a.l)
  get_GetFolder(a.l)
  get_IsLink(a.l)
  get_IsFolder(a.l)
  get_IsFileSystem(a.l)
  get_IsBrowsable(a.l)
  get_ModifyDate(a.l)
  put_ModifyDate(a.l)
  get_Size(a.l)
  get_Type(a.l)
  Verbs(a.l)
  InvokeVerb(a.p-variant)
EndInterface

; FolderItems interface definition
;
Interface FolderItems Extends IDispatch
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
EndInterface

; FolderItemVerb interface definition
;
Interface FolderItemVerb Extends IDispatch
  get_Application(a.l)
  get_Parent(a.l)
  get_Name(a.l)
  DoIt()
EndInterface

; FolderItemVerbs interface definition
;
Interface FolderItemVerbs Extends IDispatch
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
EndInterface

; Folder interface definition
;
Interface Folder Extends IDispatch
  get_Title(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  get_ParentFolder(a.l)
  Items(a.l)
  ParseName(a.p-bstr, b.l)
  NewFolder(a.p-bstr, b.p-variant)
  MoveHere(a.p-variant, b.p-variant)
  CopyHere(a.p-variant, b.p-variant)
  GetDetailsOf(a.p-variant, b.l, c.l)
EndInterface

; Folder2 interface definition
;
Interface Folder2 Extends IDispatch
  get_Title(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  get_ParentFolder(a.l)
  Items(a.l)
  ParseName(a.p-bstr, b.l)
  NewFolder(a.p-bstr, b.p-variant)
  MoveHere(a.p-variant, b.p-variant)
  CopyHere(a.p-variant, b.p-variant)
  GetDetailsOf(a.p-variant, b.l, c.l)
  get_Self(a.l)
  get_OfflineStatus(a.l)
  Synchronize()
  get_HaveToShowWebViewBarricade(a.l)
  DismissedWebViewBarricade()
EndInterface

; Folder3 interface definition
;
Interface Folder3 Extends IDispatch
  get_Title(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  get_ParentFolder(a.l)
  Items(a.l)
  ParseName(a.p-bstr, b.l)
  NewFolder(a.p-bstr, b.p-variant)
  MoveHere(a.p-variant, b.p-variant)
  CopyHere(a.p-variant, b.p-variant)
  GetDetailsOf(a.p-variant, b.l, c.l)
  get_Self(a.l)
  get_OfflineStatus(a.l)
  Synchronize()
  get_HaveToShowWebViewBarricade(a.l)
  DismissedWebViewBarricade()
  get_ShowWebViewBarricade(a.l)
  put_ShowWebViewBarricade(a.l)
EndInterface

; FolderItem2 interface definition
;
Interface FolderItem2 Extends IDispatch
  get_Application(a.l)
  get_Parent(a.l)
  get_Name(a.l)
  put_Name(a.p-bstr)
  get_Path(a.l)
  get_GetLink(a.l)
  get_GetFolder(a.l)
  get_IsLink(a.l)
  get_IsFolder(a.l)
  get_IsFileSystem(a.l)
  get_IsBrowsable(a.l)
  get_ModifyDate(a.l)
  put_ModifyDate(a.l)
  get_Size(a.l)
  get_Type(a.l)
  Verbs(a.l)
  InvokeVerb(a.p-variant)
  InvokeVerbEx(a.p-variant, b.p-variant)
  ExtendedProperty(a.p-bstr, b.l)
EndInterface

; FolderItems2 interface definition
;
Interface FolderItems2 Extends IDispatch
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
  InvokeVerbEx(a.p-variant, b.p-variant)
EndInterface

; FolderItems3 interface definition
;
Interface FolderItems3 Extends IDispatch
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
  InvokeVerbEx(a.p-variant, b.p-variant)
  Filter(a.l, b.p-bstr)
  get_Verbs(a.l)
EndInterface

; IShellLinkDual interface definition
;
Interface IShellLinkDual Extends IDispatch
  get_Path(a.l)
  put_Path(a.p-bstr)
  get_Description(a.l)
  put_Description(a.p-bstr)
  get_WorkingDirectory(a.l)
  put_WorkingDirectory(a.p-bstr)
  get_Arguments(a.l)
  put_Arguments(a.p-bstr)
  get_Hotkey(a.l)
  put_Hotkey(a.l)
  get_ShowCommand(a.l)
  put_ShowCommand(a.l)
  Resolve(a.l)
  GetIconLocation(a.l, b.l)
  SetIconLocation(a.p-bstr, b.l)
  Save(a.p-variant)
EndInterface

; IShellLinkDual2 interface definition
;
Interface IShellLinkDual2 Extends IShellLinkDual
  get_Target(a.l)
EndInterface

; IShellFolderViewDual interface definition
;
Interface IShellFolderViewDual Extends IDispatch
  get_Application(a.l)
  get_Parent(a.l)
  get_Folder(a.l)
  SelectedItems(a.l)
  get_FocusedItem(a.l)
  SelectItem(a.l, b.l)
  PopupItemMenu(a.l, b.p-variant, c.p-variant, d.l)
  get_Script(a.l)
  get_ViewOptions(a.l)
EndInterface

; IShellFolderViewDual2 interface definition
;
Interface IShellFolderViewDual2 Extends IShellFolderViewDual
  get_CurrentViewMode(a.l)
  put_CurrentViewMode(a.l)
  SelectItemRelative(a.l)
EndInterface

; IShellDispatch interface definition
;
Interface IShellDispatch Extends IDispatch
  get_Application(a.l)
  get_Parent(a.l)
  NameSpace(a.p-variant, b.l)
  BrowseForFolder(a.l, b.p-bstr, c.l, d.p-variant, e.l)
  Windows(a.l)
  Open(a.p-variant)
  Explore(a.p-variant)
  MinimizeAll()
  UndoMinimizeALL()
  FileRun()
  CascadeWindows()
  TileVertically()
  TileHorizontally()
  ShutdownWindows()
  Suspend()
  EjectPC()
  SetTime()
  TrayProperties()
  Help()
  FindFiles()
  FindComputer()
  RefreshMenu()
  ControlPanelItem(a.p-bstr)
EndInterface

; IShellDispatch2 interface definition
;
Interface IShellDispatch2 Extends IShellDispatch
  IsRestricted(a.p-bstr, b.p-bstr, c.l)
  ShellExecute(a.p-bstr, b.p-variant, c.p-variant, d.p-variant, e.p-variant)
  FindPrinter(a.p-bstr, b.p-bstr, c.p-bstr)
  GetSystemInformation(a.p-bstr, b.l)
  ServiceStart(a.p-bstr, b.p-variant, c.l)
  ServiceStop(a.p-bstr, b.p-variant, c.l)
  IsServiceRunning(a.p-bstr, b.l)
  CanStartStopService(a.p-bstr, b.l)
  ShowBrowserBar(a.p-bstr, b.p-variant, c.l)
EndInterface

; IShellDispatch3 interface definition
;
Interface IShellDispatch3 Extends IShellDispatch2
  AddToRecent(a.p-variant, b.p-bstr)
EndInterface

; IShellDispatch4 interface definition
;
Interface IShellDispatch4 Extends IShellDispatch3
  WindowsSecurity()
  ToggleDesktop()
  ExplorerPolicy(a.p-bstr, b.l)
  GetSetting(a.l, b.l)
EndInterface

; DSearchCommandEvents interface definition
;
Interface DSearchCommandEvents Extends IDispatch
EndInterface

; IFileSearchBand interface definition
;
Interface IFileSearchBand Extends IDispatch
  SetFocus()
  SetSearchParameters(a.l, b.l, c.l, d.l)
  get_SearchID(a.l)
  get_Scope(a.l)
  get_QueryFile(a.l)
EndInterface

; IWebWizardHost interface definition
;
Interface IWebWizardHost Extends IDispatch
  FinalBack()
  FinalNext()
  Cancel()
  put_Caption(a.p-bstr)
  get_Caption(a.l)
  put_Property(a.p-bstr, b.l)
  get_Property(a.p-bstr, b.l)
  SetWizardButtons(a.l, b.l, c.l)
  SetHeaderText(a.p-bstr, b.p-bstr)
EndInterface

; INewWDEvents interface definition
;
Interface INewWDEvents Extends IWebWizardHost
  PassportAuthenticate(a.p-bstr, b.l)
EndInterface

; IPassportClientServices interface definition
;
Interface IPassportClientServices Extends IDispatch
  MemberExists(a.p-bstr, b.p-bstr, c.l)
EndInterface

; IAutoComplete interface definition
;
Interface IAutoComplete Extends IUnknown
  Init(a.l, b.l, c.l, d.l)
  Enable(a.l)
EndInterface

; IAutoComplete2 interface definition
;
Interface IAutoComplete2 Extends IAutoComplete
  SetOptions(a.l)
  GetOptions(a.l)
EndInterface

; IEnumACString interface definition
;
Interface IEnumACString Extends IEnumString
  NextItem(a.p-unicode, b.l, c.l)
  SetEnumOptions(a.l)
  GetEnumOptions(a.l)
EndInterface

; IAsyncOperation interface definition
;
Interface IAsyncOperation Extends IUnknown
  SetAsyncMode(a.l)
  GetAsyncMode(a.l)
  StartOperation(a.l)
  InOperation(a.l)
  EndOperation(a.l, b.l, c.l)
EndInterface
