
; IFolderViewOC interface definition
;
Interface IFolderViewOC
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  SetFolderView(a.l)
EndInterface

; DShellFolderViewEvents interface definition
;
Interface DShellFolderViewEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; DFConstraint interface definition
;
Interface DFConstraint
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Name(a.l)
  get_Value(a.l)
EndInterface

; ISearchCommandExt interface definition
;
Interface ISearchCommandExt
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface FolderItem
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface FolderItems
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
EndInterface

; FolderItemVerb interface definition
;
Interface FolderItemVerb
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Application(a.l)
  get_Parent(a.l)
  get_Name(a.l)
  DoIt()
EndInterface

; FolderItemVerbs interface definition
;
Interface FolderItemVerbs
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
EndInterface

; Folder interface definition
;
Interface Folder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface Folder2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface Folder3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface FolderItem2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface FolderItems2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Count(a.l)
  get_Application(a.l)
  get_Parent(a.l)
  Item(a.p-variant, b.l)
  _NewEnum(a.l)
  InvokeVerbEx(a.p-variant, b.p-variant)
EndInterface

; FolderItems3 interface definition
;
Interface FolderItems3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface IShellLinkDual
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface IShellLinkDual2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
  get_Target(a.l)
EndInterface

; IShellFolderViewDual interface definition
;
Interface IShellFolderViewDual
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface IShellFolderViewDual2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Application(a.l)
  get_Parent(a.l)
  get_Folder(a.l)
  SelectedItems(a.l)
  get_FocusedItem(a.l)
  SelectItem(a.l, b.l)
  PopupItemMenu(a.l, b.p-variant, c.p-variant, d.l)
  get_Script(a.l)
  get_ViewOptions(a.l)
  get_CurrentViewMode(a.l)
  put_CurrentViewMode(a.l)
  SelectItemRelative(a.l)
EndInterface

; IShellDispatch interface definition
;
Interface IShellDispatch
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface IShellDispatch2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface IShellDispatch3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
  IsRestricted(a.p-bstr, b.p-bstr, c.l)
  ShellExecute(a.p-bstr, b.p-variant, c.p-variant, d.p-variant, e.p-variant)
  FindPrinter(a.p-bstr, b.p-bstr, c.p-bstr)
  GetSystemInformation(a.p-bstr, b.l)
  ServiceStart(a.p-bstr, b.p-variant, c.l)
  ServiceStop(a.p-bstr, b.p-variant, c.l)
  IsServiceRunning(a.p-bstr, b.l)
  CanStartStopService(a.p-bstr, b.l)
  ShowBrowserBar(a.p-bstr, b.p-variant, c.l)
  AddToRecent(a.p-variant, b.p-bstr)
EndInterface

; IShellDispatch4 interface definition
;
Interface IShellDispatch4
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
  IsRestricted(a.p-bstr, b.p-bstr, c.l)
  ShellExecute(a.p-bstr, b.p-variant, c.p-variant, d.p-variant, e.p-variant)
  FindPrinter(a.p-bstr, b.p-bstr, c.p-bstr)
  GetSystemInformation(a.p-bstr, b.l)
  ServiceStart(a.p-bstr, b.p-variant, c.l)
  ServiceStop(a.p-bstr, b.p-variant, c.l)
  IsServiceRunning(a.p-bstr, b.l)
  CanStartStopService(a.p-bstr, b.l)
  ShowBrowserBar(a.p-bstr, b.p-variant, c.l)
  AddToRecent(a.p-variant, b.p-bstr)
  WindowsSecurity()
  ToggleDesktop()
  ExplorerPolicy(a.p-bstr, b.l)
  GetSetting(a.l, b.l)
EndInterface

; DSearchCommandEvents interface definition
;
Interface DSearchCommandEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; IFileSearchBand interface definition
;
Interface IFileSearchBand
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  SetFocus()
  SetSearchParameters(a.l, b.l, c.l, d.l)
  get_SearchID(a.l)
  get_Scope(a.l)
  get_QueryFile(a.l)
EndInterface

; IWebWizardHost interface definition
;
Interface IWebWizardHost
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
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
Interface INewWDEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  FinalBack()
  FinalNext()
  Cancel()
  put_Caption(a.p-bstr)
  get_Caption(a.l)
  put_Property(a.p-bstr, b.l)
  get_Property(a.p-bstr, b.l)
  SetWizardButtons(a.l, b.l, c.l)
  SetHeaderText(a.p-bstr, b.p-bstr)
  PassportAuthenticate(a.p-bstr, b.l)
EndInterface

; IPassportClientServices interface definition
;
Interface IPassportClientServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  MemberExists(a.p-bstr, b.p-bstr, c.l)
EndInterface

; IAutoComplete interface definition
;
Interface IAutoComplete
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l, c.l, d.l)
  Enable(a.l)
EndInterface

; IAutoComplete2 interface definition
;
Interface IAutoComplete2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Init(a.l, b.l, c.l, d.l)
  Enable(a.l)
  SetOptions(a.l)
  GetOptions(a.l)
EndInterface

; IEnumACString interface definition
;
Interface IEnumACString
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
  NextItem(a.p-unicode, b.l, c.l)
  SetEnumOptions(a.l)
  GetEnumOptions(a.l)
EndInterface

; IAsyncOperation interface definition
;
Interface IAsyncOperation
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAsyncMode(a.l)
  GetAsyncMode(a.l)
  StartOperation(a.l)
  InOperation(a.l)
  EndOperation(a.l, b.l, c.l)
EndInterface
