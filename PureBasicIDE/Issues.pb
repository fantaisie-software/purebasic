; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Note: the issues stuff has its own prefs panel, so the data is stored in
;   global variables/lists as well for better management

Structure DisplayIssue
  Name$
  Text$
  File$ ; full file name
  Line.l
  Priority.l
EndStructure

Global NewList DisplayedIssues.DisplayIssue()
Global LastIssueExport$

Procedure InitIssueList()
  Style = #STYLE_FirstIssue
  Marker = #MARKER_FirstIssue
  
  ForEach Issues()
    ; Create the RegEx
    ; Note: when in the preferences, the regex is checked for validity, so we do not expect any
    ;       errors at this point. It could only be an error if somebody manually edited the prefs,
    ;       so just ignore this then (a 0 regex is correctly handled later)
    Issues()\Regex = CreateRegularExpression(#PB_Any, Issues()\Expression$)
    
    ; Assign styles and markers
    Issues()\Marker = -1
    Issues()\Style = -1
    
    If Issues()\CodeMode = 1
      Issues()\Style  = Style
      Style + 1
      
    ElseIf Issues()\CodeMode = 2
      ; there is a limit on the available markers
      If Marker <= #MARKER_LastIssue
        Issues()\Marker = Marker
        Marker + 1
      EndIf
      
    EndIf
  Next Issues()
EndProcedure

Procedure ClearIssueList()
  ForEach Issues()
    If Issues()\Regex <> 0
      FreeRegularExpression(Issues()\Regex)
    EndIf
  Next Issues()
EndProcedure

; Scan for issues in a comment (minus the ; character)
; If IsHighlight is #true, returns issues in position order and without any overlap (and only Issues with Style<>-1)
; If IsHighlight is #false, returns issues in any order and with possible overlap
Procedure ScanCommentIssues(Comment$, List Found.FoundIssue(), IsHighlight)
  
  ClearList(Found())
  
  ForEach Issues()
    Regex = Issues()\Regex
    If Regex And (IsHighlight = 0 Or Issues()\Style <> -1) And ExamineRegularExpression(Regex, Comment$)
      While NextRegularExpressionMatch(Regex)
        AddElement(Found())
        Found()\Text$ = RegularExpressionNamedGroup(Regex, "display") ; first look for a named group with display text
        If Found()\Text$ = ""
          Found()\Text$ = RegularExpressionMatchString(Regex) ; if no such group exists, display all text
        EndIf
        Found()\Text$ = Trim(ReplaceString(Found()\Text$, Chr(9), " "))
        
        Found()\Position = RegularExpressionMatchPosition(Regex)
        GroupPosition = RegularExpressionNamedGroupPosition(Regex, "mark") ; look for a group to define the marked string
        If GroupPosition > 0
          Found()\Position + GroupPosition - 1
          Found()\Length = RegularExpressionNamedGroupLength(Regex, "mark")
        Else
          Found()\Length = RegularExpressionMatchLength(Regex)
        EndIf
        
        Found()\Priority = Issues()\Priority
        Found()\Issue    = ListIndex(Issues())
        Found()\Style    = Issues()\Style
      Wend
    EndIf
  Next Issues()
  
  If ListSize(Found()) <= 1 Or IsHighlight = #False
    ProcedureReturn ; nothing more to do
  EndIf
  
  ; sort by priority (low value means high priority)
  SortStructuredList(Found(), #PB_Sort_Ascending, OffsetOf(FoundIssue\Priority), #PB_Long)
  
  ; look for overlap and eliminate the lower priority if any
  ForEach Found()
    *Current.FoundIssue = @Found()
    PushListPosition(Found())
    ; look further ahead
    While NextElement(Found())
      If Not (Found()\Position >= *Current\Position + *Current\Length Or
              Found()\Position + Found()\Length <= *Current\Position)
        DeleteElement(Found()) ; conflict
      EndIf
    Wend
    PopListPosition(Found())
  Next Found()
  
  ; now order by position
  SortStructuredList(Found(), #PB_Sort_Ascending, OffsetOf(FoundIssue\Position), #PB_Long)
  
EndProcedure

Procedure AddIssuesFromParser(File$, *Parser.ParserData, *Source.SourceFile)
  
  ; find out what to filter by
  If SelectedIssue <= 1 Or SelectedIssue = 7
    PriorityFilter = -1
    IssueFilter    = -1
  ElseIf SelectedIssue <= 6
    ; a priority is selected, so display all items with the same or higher (=lower value) priorit    PriorityLimit = SelectedIssue-1
    PriorityFilter = SelectedIssue-2
    IssueFilter    = -1
  Else
    ; a specific issue is selected
    PriorityFilter = -1
    IssueFilter    = SelectedIssue-8
  EndIf
  
  ; ensure it is sorted (does nothing if already sorted)
  SortParserData(*Parser, *Source)
  
  ; walk the sorted issue list for fast access
  *Item.SourceItem = *Parser\SortedIssues
  While *Item
    
    If (IssueFilter = -1 Or IssueFilter = *Item\Issue) And SelectElement(Issues(), *Item\Issue)
      If (PriorityFilter = -1 Or Issues()\Priority = PriorityFilter) And Issues()\InTool
        
        ; add to the list
        AddElement(DisplayedIssues())
        DisplayedIssues()\Name$    = Issues()\Name$
        DisplayedIssues()\Text$    = *Item\Name$
        DisplayedIssues()\File$    = File$
        DisplayedIssues()\Line     = *Item\SortedLine + 1 ; the parser data has 0-based lines
        DisplayedIssues()\Priority = Issues()\Priority
        
      EndIf
    EndIf
    
    *Item = *Item\NextSorted
  Wend
  
EndProcedure

Procedure UpdateIssueList()
  If IssueToolOpen And *ActiveSource
    
    ; remember old selection
    OldIndex = GetGadgetState(#GADGET_Issues_List)
    If OldIndex <> -1 And SelectElement(DisplayedIssues(), OldIndex)
      OldIssue.DisplayIssue = DisplayedIssues()
    EndIf
    
    ClearList(DisplayedIssues())
    
    If IssueMultiFile = 0 And *ActiveSource <> *ProjectInfo And *ActiveSource\IsCode
      
      ; scan only the current file
      AddIssuesFromParser(*ActiveSource\FileName$, @*ActiveSource\Parser, *ActiveSource)
      IsProjectDisplay = 0
      
      
    ElseIf IssueMultiFile And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile)
      
      ; scan all project files (open and closed)
      ForEach ProjectFiles()
        If ProjectFiles()\Source
          AddIssuesFromParser(ProjectFiles()\FileName$, @ProjectFiles()\Source\Parser, ProjectFiles()\Source)
        Else
          AddIssuesFromParser(ProjectFiles()\FileName$, @ProjectFiles()\Parser, 0)
        EndIf
      Next ProjectFiles()
      IsProjectDisplay = 1
      
    ElseIf IssueMultiFile
      
      ; scan all non-project files that are currently open
      ForEach FileList()
        If @FileList() <> *ProjectInfo And FileList()\ProjectFile = 0 And FileList()\IsCode
          AddIssuesFromParser(FileList()\FileName$, @FileList()\Parser, @FileList())
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource) ; important!
      IsProjectDisplay = 0
      
    EndIf
    
    ; check if there is anything to do
    If ListSize(DisplayedIssues()) = 0
      ClearGadgetItems(#GADGET_Issues_List)
      DisableGadget(#GADGET_Issues_Export, 1)
      ProcedureReturn
    EndIf
    
    ; do some sorting
    ; Note: list sorting is stable, so we can repeat the sort to sort by multiple categories
    ;       (start with the least important sort category first)
    If IssueMultiFile
      SortStructuredList(DisplayedIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\Line), #PB_Long)
      SortStructuredList(DisplayedIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\File$), #PB_String)
      SortStructuredList(DisplayedIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\Priority), #PB_Long)
    Else
      SortStructuredList(DisplayedIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\Line), #PB_Long)
      SortStructuredList(DisplayedIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\Priority), #PB_Long)
    EndIf
    
    ; update the list
    NewIndex = -1
    
    ; Lock the list update, as on GTK2 it's really slow
    ; Note: we may not call SetGadgetState() after this!
    CompilerIf #CompileLinuxGtk
      *tree_model = gtk_tree_view_get_model_(GadgetID(#GADGET_Issues_List))
      g_object_ref_(*tree_model) ; must be ref'ed or it is destroyed
      gtk_tree_view_set_model_(GadgetID(#GADGET_Issues_List), #Null) ; disconnect the model for a faster update
    CompilerEndIf
    
    ClearGadgetItems(#GADGET_Issues_List)
    ForEach DisplayedIssues()
      
      ; get the file name to display
      If IsProjectDisplay
        File$ = CreateRelativePath(GetPathPart(ProjectFile$), DisplayedIssues()\File$)
      ElseIf DisplayedIssues()\File$ = ""
        File$ = Language("FileStuff", "NewSource")
      Else
        File$ = GetFilePart(DisplayedIssues()\File$) ; just use the name as it is in the open file list
      EndIf
      
      ; add the item
      Text$ = DisplayedIssues()\Name$ + Chr(10) +
              DisplayedIssues()\Text$ + Chr(10) +
              Str(DisplayedIssues()\Line) + Chr(10) +
              File$ + Chr(10) +
              Language("ToolsPanel", "Prio" + DisplayedIssues()\Priority)
      
      AddGadgetItem(#GADGET_Issues_List, -1, Text$, OptionalImageID(#IMAGE_Priority0 + DisplayedIssues()\Priority))
      
      ; check if this was our last selection
      If NewIndex = -1 And OldIndex <> -1 And
         DisplayedIssues()\Name$ = OldIssue\Name$ And
         DisplayedIssues()\Text$ = OldIssue\Text$ And
         DisplayedIssues()\File$ = OldIssue\File$ And
         DisplayedIssues()\Line  = OldIssue\Line
        
        NewIndex = ListIndex(DisplayedIssues())
      EndIf
      
    Next DisplayedIssues()
    
    CompilerIf #CompileLinuxGtk
      gtk_tree_view_set_model_(GadgetID(#GADGET_Issues_List), *tree_model) ; reconnect the model
      g_object_unref_(*tree_model)                                         ; release reference
    CompilerEndIf
    
    ; restore selection
    If NewIndex <> -1
      SetGadgetState(#GADGET_Issues_List, NewIndex)
    EndIf
    
    DisableGadget(#GADGET_Issues_Export, 0)
    
  EndIf
EndProcedure

Procedure.s CsvEncode(String$)
  If FindString(String$, ",") Or FindString(String$, Chr(34))
    ProcedureReturn Chr(34) + ReplaceString(String$, Chr(34), Chr(34)+Chr(34)) + Chr(34)
  Else
    ProcedureReturn String$
  EndIf
EndProcedure

Procedure ExportIssueList()
  
  If LastIssueExport$ <> ""
    Path$ = LastIssueExport$
  ElseIf *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
    Path$ = GetPathPart(ProjectFile$)
  Else
    Path$ = SourcePath$
  EndIf
  
  FileName$ = SaveFileRequester(Language("FileStuff","ExportIssueTitle"), Path$, Language("FileStuff","ExportIssuePattern"), 0)
  If FileName$ <> ""
    
    If GetExtensionPart(GetFilePart(FileName$)) = "" And SelectedFilePattern() = 0
      FileName$ + ".csv"
    EndIf
    
    If FileSize(FileName$) > -1  ; file exist check
      If MessageRequester(#ProductName$, Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_No
        ProcedureReturn ; abort
      EndIf
    EndIf
    
    LastIssueExport$ = FileName$ ; remember for next time
    
    ; create a local copy of the list to sort it for export
    Protected NewList ExportIssues.DisplayIssue()
    CopyList(DisplayedIssues(), ExportIssues())
    
    ; sort by file and line
    SortStructuredList(ExportIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\Line), #PB_Long)
    SortStructuredList(ExportIssues(), #PB_Sort_Ascending, OffsetOf(DisplayIssue\File$), #PB_String)
    
    If CreateFile(#FILE_ExportIssues, FileName$)
      
      ; write header
      WriteStringN(#FILE_ExportIssues,
                   CsvEncode(Language("Misc", "File")) + "," +
                   CsvEncode(Language("Misc", "Line")) + "," +
                   CsvEncode(Language("ToolsPanel", "IssueName")) + "," +
                   CsvEncode(Language("ToolsPanel", "IssueText")) + "," +
                   CsvEncode(Language("ToolsPanel", "Priority")))
      
      ; write content
      ForEach ExportIssues()
        WriteStringN(#FILE_ExportIssues,
                     CsvEncode(ExportIssues()\File$) + "," +
                     CsvEncode(Str(ExportIssues()\Line)) + "," +
                     CsvEncode(ExportIssues()\Name$) + "," +
                     CsvEncode(ExportIssues()\Text$) + "," +
                     CsvEncode(Language("ToolsPanel", "Prio" + ExportIssues()\Priority)))
      Next ExportIssues()
      
      CloseFile(#FILE_ExportIssues)
    Else
      MessageRequester(#ProductName$, Language("FileStuff","CreateError"), #FLAG_Error)
    EndIf
  EndIf
  
  
EndProcedure


Procedure Issues_CreateFunction(*Entry.ToolsPanelEntry)
  
  ComboBoxGadget(#GADGET_Issues_Filter, 0, 0, 0, 0, #PB_ComboBox_Image)
  AddGadgetItem(#GADGET_Issues_Filter, -1, Language("ToolsPanel", "AllIssues"), OptionalImageID(#IMAGE_AllIssues))
  AddGadgetItem(#GADGET_Issues_Filter, -1, "")
  For i = 0 To 4
    AddGadgetItem(#GADGET_Issues_Filter, -1, Language("ToolsPanel", "Priority") + ": " + Language("ToolsPanel", "Prio" + i), OptionalImageID(#IMAGE_Priority0 + i))
  Next i
  AddGadgetItem(#GADGET_Issues_Filter, -1, "")
  ForEach Issues()
    AddGadgetItem(#GADGET_Issues_Filter, -1, Issues()\Name$, OptionalImageID(#IMAGE_Priority0 + Issues()\Priority))
  Next Issues()
  
  ; sanitize the selection value
  ; (some values in the combobox are just empty for better look)
  If SelectedIssue < 0 Or SelectedIssue = 1 Or SelectedIssue = 7 Or SelectedIssue >= CountGadgetItems(#GADGET_Issues_Filter)
    SelectedIssue = 0
  EndIf
  SetGadgetState(#GADGET_Issues_Filter, SelectedIssue)
  
  ListIconGadget(#GADGET_Issues_List, 0, 0, IssuesCol1, 0, Language("ToolsPanel", "IssueName"), IssuesCol1, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
  AddGadgetColumn(#GADGET_Issues_List, 1, Language("ToolsPanel", "IssueText"), IssuesCol2)
  AddGadgetColumn(#GADGET_Issues_List, 2, Language("Misc", "Line"), IssuesCol3)
  AddGadgetColumn(#GADGET_Issues_List, 3, Language("Misc", "File"), IssuesCol4)
  AddGadgetColumn(#GADGET_Issues_List, 4, Language("ToolsPanel", "Priority"), IssuesCol5)
  
  If EnableAccessibility
    SetActiveGadget(#GADGET_Issues_List)
  EndIf
  
  ButtonImageGadget(#GADGET_Issues_SingleFile, 0, 0, 0, 0, ImageID(#IMAGE_IssueSingleFile), #PB_Button_Toggle)
  ButtonImageGadget(#GADGET_Issues_MultiFile,  0, 0, 0, 0, ImageID(#IMAGE_IssueMultiFile), #PB_Button_Toggle)
  ButtonImageGadget(#GADGET_Issues_Export,     0, 0, 0, 0, ImageID(#IMAGE_IssueExport))
  
  GadgetToolTip(#GADGET_Issues_SingleFile, Language("ToolsPanel", "SingleFile"))
  GadgetToolTip(#GADGET_Issues_MultiFile,  Language("ToolsPanel", "MultiFile"))
  GadgetToolTip(#GADGET_Issues_Export,     Language("ToolsPanel", "Export"))
  
  If EnableAccessibility
    ; Sets a label on the buttons for screen reader users.
    ; This label is only ever seen by screen readers, and never visually shown.
    SetGadgetText(#GADGET_Issues_SingleFile, Language("ToolsPanel", "SingleFile"))
    SetGadgetText(#GADGET_Issues_MultiFile,  Language("ToolsPanel", "MultiFile"))
    SetGadgetText(#GADGET_Issues_Export,     Language("ToolsPanel", "Export"))
  EndIf
  
  If IssueMultiFile
    SetGadgetState(#GADGET_Issues_MultiFile, 1)
  Else
    SetGadgetState(#GADGET_Issues_SingleFile, 1)
  EndIf
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_Issues_List)
  EndIf
  
  IssueToolOpen = 1
  UpdateIssueList()
  
EndProcedure


Procedure Issues_DestroyFunction(*Entry.ToolsPanelEntry)
  
  ; store column sizes for preferences
  IssuesCol1 = GetGadgetItemAttribute(#GADGET_Issues_List, -1, #PB_ListIcon_ColumnWidth, 0)
  IssuesCol2 = GetGadgetItemAttribute(#GADGET_Issues_List, -1, #PB_ListIcon_ColumnWidth, 1)
  IssuesCol3 = GetGadgetItemAttribute(#GADGET_Issues_List, -1, #PB_ListIcon_ColumnWidth, 2)
  IssuesCol4 = GetGadgetItemAttribute(#GADGET_Issues_List, -1, #PB_ListIcon_ColumnWidth, 3)
  IssuesCol5 = GetGadgetItemAttribute(#GADGET_Issues_List, -1, #PB_ListIcon_ColumnWidth, 4)
  
  IssueToolOpen = 0
  
EndProcedure

Procedure Issues_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  GetRequiredSize(#GADGET_Issues_SingleFile, @Width.l, @Height.l)
  FilterHeight = GetRequiredHeight(#GADGET_Issues_Filter)
  
  CompilerIf #CompileWindows
    Space = 3
  CompilerElse
    Space = 6 ; looks better on Linux/OSX with some more space
  CompilerEndIf
  
  If *Entry\IsSeparateWindow
    ; Small hack: If there is enough space, place the buttons next to the 'StayOnTop' checkbox
    If #DEFAULT_CanWindowStayOnTop
      GetRequiredSize(*Entry\ToolStayOnTop, @StayOnTopWidth.l, @StayOnTopHeight.l)
      If StayOnTopWidth < PanelWidth-10-3*Width-2*Space
        PanelHeight = WindowHeight(*Entry\ToolWindowID)
        ResizeGadget(*Entry\ToolStayOnTop, #PB_Ignore, PanelHeight-5-Height+(Height-StayOnTopHeight)/2, StayOnTopWidth, #PB_Ignore)
      EndIf
    EndIf
    
    ResizeGadget(#GADGET_Issues_Filter, 5, 5, PanelWidth-10, FilterHeight)
    ResizeGadget(#GADGET_Issues_List, 5, 10+FilterHeight, PanelWidth-10, PanelHeight-20-FilterHeight-Height)
    
    ResizeGadget(#GADGET_Issues_SingleFile, PanelWidth-5-3*Width-2*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_Issues_MultiFile, PanelWidth-5-2*Width-Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_Issues_Export, PanelWidth-5-Width, PanelHeight-Height-5, Width, Height)
  Else
    ResizeGadget(#GADGET_Issues_Filter, 0, 0, PanelWidth, FilterHeight)
    ResizeGadget(#GADGET_Issues_List, 0, FilterHeight+1, PanelWidth, PanelHeight-FilterHeight-7-Height)
    
    ResizeGadget(#GADGET_Issues_SingleFile, PanelWidth-3*Width-2*Space, PanelHeight-Height-2, Width, Height)
    ResizeGadget(#GADGET_Issues_MultiFile, PanelWidth-2*Width-Space, PanelHeight-Height-2, Width, Height)
    ResizeGadget(#GADGET_Issues_Export, PanelWidth-Width, PanelHeight-Height-2, Width, Height)
  EndIf
  
EndProcedure


Procedure Issues_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  
  Select EventGadgetID
      
    Case #GADGET_Issues_Filter
      NewIssue = GetGadgetState(#GADGET_Issues_Filter)
      If NewIssue < 0 Or NewIssue = 1 Or NewIssue = 7
        ; empty slots for better display
        NewIssue = 0
        SetGadgetState(#GADGET_Issues_Filter, 0)
      EndIf
      If NewIssue <> SelectedIssue
        SelectedIssue = NewIssue
        UpdateIssueList()
      EndIf
      
    Case #GADGET_Issues_List
      If EventType() = #PB_EventType_LeftDoubleClick
        Index = GetGadgetState(#GADGET_Issues_List)
        If Index <> -1 And SelectElement(DisplayedIssues(), Index)
          ; Note: switching the source may cause a re-filling of the issue list, so get the values first
          File$ = DisplayedIssues()\File$
          Line  = DisplayedIssues()\Line
          
          If LoadSourceFile(File$, 1) ; will switch if already loaded
            ChangeActiveLine(Line, -5)
          EndIf
        EndIf
      EndIf
      
    Case #GADGET_Issues_SingleFile
      If IssueMultiFile
        SetGadgetState(#GADGET_Issues_MultiFile, 0)
        SetGadgetState(#GADGET_Issues_SingleFile, 1)
        IssueMultiFile = #False
        UpdateIssueList()
      Else
        ; we want to act the two buttons to act like an option group, so override this change
        SetGadgetState(#GADGET_Issues_SingleFile, 1)
      EndIf
      
    Case #GADGET_Issues_MultiFile
      If IssueMultiFile = 0
        SetGadgetState(#GADGET_Issues_MultiFile, 1)
        SetGadgetState(#GADGET_Issues_SingleFile, 0)
        IssueMultiFile = #True
        UpdateIssueList()
      Else
        ; we want to act the two buttons to act like an option group, so override this change
        SetGadgetState(#GADGET_Issues_MultiFile, 1)
      EndIf
      
    Case #GADGET_Issues_Export
      ExportIssueList()
      
  EndSelect
  
EndProcedure






;- Initialisation code
; This will make this Tool available to the editor
;
Issues_VT.ToolsPanelFunctions

Issues_VT\CreateFunction      = @Issues_CreateFunction()
Issues_VT\DestroyFunction     = @Issues_DestroyFunction()
Issues_VT\ResizeHandler       = @Issues_ResizeHandler()
Issues_VT\EventHandler        = @Issues_EventHandler()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = Issues_VT
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "Issues"
AvailablePanelTools()\PanelTitle$          = "IssuesShort"
AvailablePanelTools()\ToolName$            = "IssuesLong"