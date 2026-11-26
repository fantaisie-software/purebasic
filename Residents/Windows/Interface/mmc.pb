
; IComponentData interface definition
;
Interface IComponentData Extends IUnknown
  Initialize(a.l)
  CreateComponent(a.l)
  Notify(a.l, b.l, c.l, d.l)
  Destroy()
  QueryDataObject(a.l, b.l, c.l)
  GetDisplayInfo(a.l)
  CompareObjects(a.l, b.l)
EndInterface

; IComponent interface definition
;
; Interface IComponent
;   QueryInterface(a.l, b.l)
;   AddRef()
;   Release()
;   Initialize(a.l)
;   Notify(a.l, b.l, c.l, d.l)
;   Destroy(a.l)
;   QueryDataObject(a.l, b.l, c.l)
;   GetResultViewType(a.l, b.l, c.l)
;   GetDisplayInfo(a.l)
;   CompareObjects(a.l, b.l)
; EndInterface

; IResultDataCompare interface definition
;
Interface IResultDataCompare Extends IUnknown
  Compare(a.l, b.l, c.l, d.l)
EndInterface

; IResultOwnerData interface definition
;
Interface IResultOwnerData Extends IUnknown
  FindItem(a.l, b.l)
  CacheHint(a.l, b.l)
  SortItems(a.l, b.l, c.l)
EndInterface

; IConsole interface definition
;
Interface IConsole Extends IUnknown
  SetHeader(a.l)
  SetToolbar(a.l)
  QueryResultView(a.l)
  QueryScopeImageList(a.l)
  QueryResultImageList(a.l)
  UpdateAllViews(a.l, b.l, c.l)
  MessageBox(a.l, b.l, c.l, d.l)
  QueryConsoleVerb(a.l)
  SelectScopeItem(a.l)
  GetMainWindow(a.l)
  NewWindow(a.l, b.l)
EndInterface

; IHeaderCtrl interface definition
;
Interface IHeaderCtrl Extends IUnknown
  InsertColumn(a.l, b.l, c.l, d.l)
  DeleteColumn(a.l)
  SetColumnText(a.l, b.l)
  GetColumnText(a.l, b.l)
  SetColumnWidth(a.l, b.l)
  GetColumnWidth(a.l, b.l)
EndInterface

; IContextMenuCallback interface definition
;
Interface IContextMenuCallback Extends IUnknown
  AddItem(a.l)
EndInterface

; IContextMenuProvider interface definition
;
Interface IContextMenuProvider Extends IContextMenuCallback
  EmptyMenuList()
  AddPrimaryExtensionItems(a.l, b.l)
  AddThirdPartyExtensionItems(a.l)
  ShowContextMenu(a.l, b.l, c.l, d.l)
EndInterface

; IExtendContextMenu interface definition
;
Interface IExtendContextMenu Extends IUnknown
  AddMenuItems(a.l, b.l, c.l)
  Command(a.l, b.l)
EndInterface

; IImageList interface definition
;
Interface IImageListMMC Extends IUnknown ; Renamed to IImageList2 as there is another IImageList (more used) !
  ImageListSetIcon(a.l, b.l)
  ImageListSetStrip(a.l, b.l, c.l, d.l)
EndInterface

; IResultData interface definition
;
Interface IResultData Extends IUnknown
  InsertItem(a.l)
  DeleteItem(a.l, b.l)
  FindItemByLParam(a.l, b.l)
  DeleteAllRsltItems()
  SetItem(a.l)
  GetItem(a.l)
  GetNextItem(a.l)
  ModifyItemState(a.l, b.l, c.l, d.l)
  ModifyViewStyle(a.l, b.l)
  SetViewMode(a.l)
  GetViewMode(a.l)
  UpdateItem(a.l)
  Sort(a.l, b.l, c.l)
  SetDescBarText(a.p-unicode)
  SetItemCount(a.l, b.l)
EndInterface

; IConsoleNameSpace interface definition
;
Interface IConsoleNameSpace Extends IUnknown
  InsertItem(a.l)
  DeleteItem(a.l, b.l)
  SetItem(a.l)
  GetItem(a.l)
  GetChildItem(a.l, b.l, c.l)
  GetNextItem(a.l, b.l, c.l)
  GetParentItem(a.l, b.l, c.l)
EndInterface

; IConsoleNameSpace2 interface definition
;
Interface IConsoleNameSpace2 Extends IConsoleNameSpace
  Expand(a.l)
  AddExtension(a.l, b.l)
EndInterface

; IPropertySheetCallback interface definition
;
Interface IPropertySheetCallback Extends IUnknown
  AddPage(a.l)
  RemovePage(a.l)
EndInterface

; IPropertySheetProvider interface definition
;
Interface IPropertySheetProvider Extends IUnknown
  CreatePropertySheet(a.l, b.l, c.l, d.l, e.l)
  FindPropertySheet(a.l, b.l, c.l)
  AddPrimaryPages(a.l, b.l, c.l, d.l)
  AddExtensionPages()
  Show(a.l, b.l)
EndInterface

; IExtendPropertySheet interface definition
;
Interface IExtendPropertySheet Extends IUnknown
  CreatePropertyPages(a.l, b.l, c.l)
  QueryPagesFor(a.l)
EndInterface

; IControlbar interface definition
;
Interface IControlbar Extends IUnknown
  Create(a.l, b.l, c.l)
  Attach(a.l, b.l)
  Detach(a.l)
EndInterface

; IExtendControlbar interface definition
;
Interface IExtendControlbar Extends IUnknown
  SetControlbar(a.l)
  ControlbarNotify(a.l, b.l, c.l)
EndInterface

; IToolbar interface definition
;
Interface IToolbar Extends IUnknown
  AddBitmap(a.l, b.l, c.l, d.l, e.l)
  AddButtons(a.l, b.l)
  InsertButton(a.l, b.l)
  DeleteButton(a.l)
  GetButtonState(a.l, b.l, c.l)
  SetButtonState(a.l, b.l, c.l)
EndInterface

; IConsoleVerb interface definition
;
Interface IConsoleVerb Extends IUnknown
  GetVerbState(a.l, b.l, c.l)
  SetVerbState(a.l, b.l, c.l)
  SetDefaultVerb(a.l)
  GetDefaultVerb(a.l)
EndInterface

; ISnapinAbout interface definition
;
Interface ISnapinAbout Extends IUnknown
  GetSnapinDescription(a.l)
  GetProvider(a.l)
  GetSnapinVersion(a.l)
  GetSnapinImage(a.l)
  GetStaticFolderImage(a.l, b.l, c.l, d.l)
EndInterface

; IMenuButton interface definition
;
Interface IMenuButton Extends IUnknown
  AddButton(a.l, b.p-unicode, c.p-unicode)
  SetButton(a.l, b.p-unicode, c.p-unicode)
  SetButtonState(a.l, b.l, c.l)
EndInterface

; ISnapinHelp interface definition
;
Interface ISnapinHelp Extends IUnknown
  GetHelpTopic(a.l)
EndInterface

; IExtendPropertySheet2 interface definition
;
Interface IExtendPropertySheet2 Extends IExtendPropertySheet
  GetWatermarks(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IHeaderCtrl2 interface definition
;
Interface IHeaderCtrl2 Extends IHeaderCtrl
  SetChangeTimeOut(a.l)
  SetColumnFilter(a.l, b.l, c.l)
  GetColumnFilter(a.l, b.l, c.l)
EndInterface

; ISnapinHelp2 interface definition
;
Interface ISnapinHelp2 Extends ISnapinHelp
  GetLinkedTopics(a.l)
EndInterface

; IEnumTASK interface definition
;
Interface IEnumTASK Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IExtendTaskPad interface definition
;
Interface IExtendTaskPad Extends IUnknown
  TaskNotify(a.l, b.l, c.l)
  EnumTasks(a.l, b.p-unicode, c.l)
  GetTitle(a.p-unicode, b.l)
  GetDescriptiveText(a.p-unicode, b.l)
  GetBackground(a.p-unicode, b.l)
  GetListPadInfo(a.p-unicode, b.l)
EndInterface

; IConsole2 interface definition
;
Interface IConsole2 Extends IConsole
  Expand(a.l, b.l)
  IsTaskpadViewPreferred()
  SetStatusText(a.p-unicode)
EndInterface

; IDisplayHelp interface definition
;
Interface IDisplayHelp Extends IUnknown
  ShowTopic(a.p-unicode)
EndInterface

; IRequiredExtensions interface definition
;
Interface IRequiredExtensions Extends IUnknown
  EnableAllExtensions()
  GetFirstExtension(a.l)
  GetNextExtension(a.l)
EndInterface

; IStringTable interface definition
;
Interface IStringTable Extends IUnknown
  AddString(a.l, b.l)
  GetString(a.l, b.l, c.p-unicode, d.l)
  GetStringLength(a.l, b.l)
  DeleteString(a.l)
  DeleteAllStrings()
  FindString(a.l, b.l)
  Enumerate(a.l)
EndInterface

; IColumnData interface definition
;
Interface IColumnData Extends IUnknown
  SetColumnConfigData(a.l, b.l)
  GetColumnConfigData(a.l, b.l)
  SetColumnSortData(a.l, b.l)
  GetColumnSortData(a.l, b.l)
EndInterface

; IMessageView interface definition
;
Interface IMessageView Extends IUnknown
  SetTitleText(a.l)
  SetBodyText(a.l)
  SetIcon(a.l)
  Clear()
EndInterface

; IResultDataCompareEx interface definition
;
Interface IResultDataCompareEx Extends IUnknown
  Compare(a.l, b.l)
EndInterface

; IComponentData2 interface definition
;
Interface IComponentData2 Extends IComponentData
  QueryDispatch(a.l, b.l, c.l)
EndInterface

; IComponent2 interface definition
;
Interface IComponent2 Extends IUnknown
  Initialize(a.l)
  Notify(a.l, b.l, c.l, d.l)
  Destroy(a.l)
  QueryDataObject(a.l, b.l, c.l)
  GetResultViewType(a.l, b.l, c.l)
  GetDisplayInfo(a.l)
  CompareObjects(a.l, b.l)
  QueryDispatch(a.l, b.l, c.l)
  GetResultViewType2(a.l, b.l)
  RestoreResultView(a.l, b.l)
EndInterface

; IContextMenuCallback2 interface definition
;
Interface IContextMenuCallback2 Extends IUnknown
  AddItem(a.l)
EndInterface

; IMMCVersionInfo interface definition
;
Interface IMMCVersionInfo Extends IUnknown
  GetMMCVersion(a.l, b.l)
EndInterface

; IExtendView interface definition
;
Interface IExtendView Extends IUnknown
  GetViews(a.l, b.l)
EndInterface

; IViewExtensionCallback interface definition
;
Interface IViewExtensionCallback Extends IUnknown
  AddView(a.l)
EndInterface

; IConsolePower interface definition
;
Interface IConsolePower Extends IUnknown
  SetExecutionState(a.l, b.l)
  ResetIdleTimer(a.l)
EndInterface

; IConsolePowerSink interface definition
;
Interface IConsolePowerSink Extends IUnknown
  OnPowerBroadcast(a.l, b.l, c.l)
EndInterface

; INodeProperties interface definition
;
Interface INodeProperties Extends IUnknown
  GetProperty(a.l, b.p-bstr, c.l)
EndInterface

; IConsole3 interface definition
;
Interface IConsole3 Extends IConsole2
  RenameScopeItem(a.l)
EndInterface

; IResultData2 interface definition
;
Interface IResultData2 Extends IResultData
  RenameResultItem(a.l)
EndInterface
; ExecutableFormat=
; CursorPosition=30
; FirstLine=1
; EOF
