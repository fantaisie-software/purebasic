;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


Global Backup_ProcedureBrowserSort, Backup_DisplayProtoType


Procedure UpdateProcedureList()
  
  ; The Issues tool usually needs an update two when the ProcedureBrowser does,
  ; so just do this always from here for simplicity
  UpdateIssueList()
  
  If *ActiveSource = *ProjectInfo Or *ActiveSource\IsCode = 0
    ClearList(ProcedureList())
    ClearGadgetItems(#GADGET_ProcedureBrowser)
    ProcedureReturn
  EndIf
  
  If ProcedureBrowserMode = 1
    
    ; Create our procedurelist from the SourceItems of the current source
    ;
    ClearList(ProcedureList())
    InsideMacro = 0
    ModulePrefix$ = ""
    
    If *ActiveSource\Parser\SourceItemArray
      For i = 0 To *ActiveSource\Parser\SourceItemCount-1
        *Item.SourceItem = *ActiveSource\Parser\SourceItemArray\Line[i]\First
        While *Item
          If InsideMacro = 0
            Select *Item\Type
                
              Case #ITEM_Module, #ITEM_DeclareModule
                ModulePrefix$ = *Item\Name$ + "::"
                
              Case #ITEM_EndModule, #ITEM_EndDeclareModule
                ModulePrefix$ = ""
                
              Case #ITEM_Procedure
                AddElement(ProcedureList())
                ProcedureList()\Name$ = ModulePrefix$ + *Item\Name$
                ProcedureList()\Line  = i+1
                ProcedureList()\Type  = 0
                Procedurelist()\Prototype$ = *Item\Prototype$
                
              Case #ITEM_Macro
                AddElement(ProcedureList())
                ProcedureList()\Name$ = ModulePrefix$ + *Item\Name$
                ProcedureList()\Line  = i+1
                ProcedureList()\Type  = 1
                Procedurelist()\Prototype$ = *Item\Prototype$
                
            EndSelect
          EndIf
          
          ; we recognize comment marks even inside macros, as they cannot screw anything,
          ; since they are comments
          If *Item\Type = #ITEM_CommentMark
            AddElement(ProcedureList())
            ProcedureList()\Name$ = *Item\Name$
            ProcedureList()\Line  = i+1
            ProcedureList()\Type  = 2
            
          ElseIf *Item\Type = #ITEM_Issue
            If SelectElement(Issues(), *Item\Issue)
              If Issues()\InBrowser
                AddElement(ProcedureList())
                ProcedureList()\Name$ = *Item\Name$
                ProcedureList()\Line  = i+1
                ProcedureList()\Type  = 3
              EndIf
            EndIf
            
          ElseIf *Item\Type = #ITEM_Macro
            InsideMacro = 1
          ElseIf *Item\Type = #ITEM_MacroEnd
            InsideMacro = 0
          EndIf
          
          *Item = *Item\Next
        Wend
      Next i
    EndIf
    
    ; first sort the list
    ;
    If ListSize(ProcedureList()) > 1
      Repeat
        Done = 1
        FirstElement(ProcedureList())
        *Previous.ProcedureInfo = @ProcedureList()
        
        While NextElement(ProcedureList())
          Change = 0
          
          If ProcedureBrowserSort = 0
            If ProcedureList()\Line < *Previous\Line
              Change = 1
            EndIf
            
          ElseIf ProcedureBrowserSort = 1
            If ProcedureList()\Type = *Previous\Type
              If ProcedureList()\Line < *Previous\Line
                Change = 1
              EndIf
            ElseIf ProcedureList()\Type < *Previous\Type
              Change = 1
            EndIf
            
          ElseIf ProcedureBrowserSort = 2
            If CompareMemoryString(@ProcedureList()\Name$, @*Previous\Name$, #PB_String_NoCase) < 0
              Change = 1
            EndIf
            
          ElseIf ProcedureBrowserSort = 3
            If ProcedureList()\Type = *Previous\Type
              If CompareMemoryString(@ProcedureList()\Name$, @*Previous\Name$, #PB_String_NoCase) < 0
                Change = 1
              EndIf
            ElseIf ProcedureList()\Type < *Previous\Type
              Change = 1
            EndIf
            
          EndIf
          
          If Change
            SwapElements(ProcedureList(), *Previous, @ProcedureList())
            Done = 0
          EndIf
          
          *Previous = @ProcedureList()
        Wend
        
      Until Done
    EndIf
    
    ;StartGadgetFlickerFix(#GADGET_ProcedureBrowser)
    
    ; preserve the selection if possible
    OldIndex = GetGadgetState(#GADGET_ProcedureBrowser)
    NewIndex = -1
    If OldIndex <> -1
      OldText$ = GetGadgetItemText(#GADGET_ProcedureBrowser, OldIndex)
    EndIf
    
    ; Lock the list update, as on GTK2 it's really slow
    ; Note: we may not call SetGadgetState() after this!
    CompilerIf #CompileLinux
      CompilerIf #GtkVersion = 1
        gtk_clist_freeze_(GadgetID(#GADGET_ProcedureBrowser)) ; on gtk1, its a clist
      CompilerElse
        *tree_model = gtk_tree_view_get_model_(GadgetID(#GADGET_ProcedureBrowser))
        g_object_ref_(*tree_model) ; must be ref'ed or it is destroyed
        gtk_tree_view_set_model_(GadgetID(#GADGET_ProcedureBrowser), #Null) ; disconnect the model for a faster update
      CompilerEndIf
    CompilerEndIf
    
    ClearGadgetItems(#GADGET_ProcedureBrowser)
    ForEach ProcedureList()
      If ProcedureList()\Type = 0
        Text$ = ProcedureList()\Name$
        If DisplayPrototype
          Text$ + ProcedureList()\Prototype$
        EndIf
      ElseIf ProcedureList()\Type = 1
        Text$ = "+ " + ProcedureList()\Name$
        If DisplayPrototype
          Text$ + ProcedureList()\Prototype$
        EndIf
      ElseIf ProcedureList()\Type = 2
        Text$ = "> " + ProcedureList()\Name$
      Else
        Text$ = ProcedureList()\Name$
      EndIf
      
      AddGadgetItem(#GADGET_ProcedureBrowser, -1, Text$)
      
      ; check if this is our old selection
      If CompareMemoryString(@OldText$, @Text$, #PB_String_NoCase) = 0 And OldIndex <> -1
        NewIndex = CountGadgetItems(#GADGET_ProcedureBrowser)-1
      EndIf
    Next ProcedureList()
    
    CompilerIf #CompileLinux
      CompilerIf #GtkVersion = 1
        gtk_clist_thaw_(GadgetID(#GADGET_ProcedureBrowser))
      CompilerElse
        gtk_tree_view_set_model_(GadgetID(#GADGET_ProcedureBrowser), *tree_model) ; reconnect the model
        g_object_unref_(*tree_model)                                              ; release reference
      CompilerEndIf
    CompilerEndIf
    
    ; restore old selection
    If NewIndex <> -1
      SetGadgetState(#GADGET_ProcedureBrowser, NewIndex)
    EndIf
    
    ;StopGadgetFlickerFix(#GADGET_ProcedureBrowser)
    
  EndIf
  
EndProcedure

Procedure FindProcedureFromSorted(*Parser.ParserData, *Name, Type, ModuleName$)
  
  Bucket = GetBucket(*Name)
  
  *Item.SourceItem = *Parser\Modules(UCase(ModuleName$))\Indexed[Type]\Bucket[Bucket]
  While *Item
    Select CompareMemoryString(*Name, @*Item\Name$, #PB_String_NoCase)
      Case #PB_String_Equal
        ProcedureReturn *Item
      Case #PB_String_Greater:
        *Item = *Item\NextSorted
      Default
        Break
    EndSelect
  Wend
  
  ProcedureReturn 0
EndProcedure

Procedure JumpToProcedure() ; return 1 if a jump was done
  Protected *Found.SourceItem
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  ; update the information
  UpdateCursorPosition()
  SortParserData(@*ActiveSource\Parser, *ActiveSource)
  
  ; get the current token
  *StartItem.SourceItem = LocateSourceItem(@*ActiveSource\Parser, *ActiveSource\CurrentLine-1, *ActiveSource\CurrentColumnBytes-1)
  If *StartItem = 0 Or *StartItem\Type <> #ITEM_UnknownBraced
    ; not a procedure
    ProcedureReturn 0
  EndIf
  
  ; Note: We cannot just search all modules, because there could be private implementations
  ;   matching our name, but not publicly visible. So we must first look at the public parts if
  ;   the searched procedure is declared and then look in the implementation for the actual procedure
  ;
  Protected NewList OpenModules.s(), NewList CandidateModules.s()
  *ModuleStart.SourceItem = *StartItem
  ModuleStartLine = *ActiveSource\CurrentLine - 1
  
  If *StartItem\ModulePrefix$ <> ""
    AddElement(OpenModules())
    OpenModules() = *StartItem\ModulePrefix$
    
  ElseIf FindModuleStart(@*ActiveSource\Parser, @ModuleStartLine, @*ModuleStart, OpenModules())
    ; we are inside this module, so directly make it a candidate for implementation search
    AddElement(CandidateModules())
    CandidateModules() = "IMPL::" + *ModuleStart\Name$
    
  Else
    ; directly make the main module a candidate
    AddElement(CandidateModules())
    CandidateModules() = ""
    
  EndIf
  
  
  ; Now check the open modules if they have a public declare that we look for
  ; Here we look for #ITEM_Declare only!
  ;
  ForEach OpenModules()
    
    ; check active source first
    If *ActiveSource <> *ProjectInfo
      If FindProcedureFromSorted(@*ActiveSource\Parser, @*StartItem\Name$, #ITEM_Declare, OpenModules())
        AddElement(CandidateModules())
        CandidateModules() = "IMPL::" + OpenModules()
        Continue ; no need to look more at this module
      EndIf
    EndIf
    
    ; check projects
    If AutoCompleteProject And *ActiveSource\ProjectFile
      ForEach ProjectFiles()
        If ProjectFiles()\Source = 0 And ProjectFiles()\Parser\SortedValid
          *Found = FindProcedureFromSorted(@ProjectFiles()\Parser, @*StartItem\Name$, #ITEM_Declare, OpenModules())
        ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *ActiveSource And ProjectFiles()\Source\Parser\SortedValid
          *Found = FindProcedureFromSorted(@ProjectFiles()\Source\Parser, @*StartItem\Name$, #ITEM_Declare, OpenModules())
        Else
          *Found = 0
        EndIf
        
        If *Found
          AddElement(CandidateModules())
          CandidateModules() = "IMPL::" + OpenModules()
          Break
        EndIf
      Next ProjectFiles()
    EndIf
    
    ; check all other open sources now...
    ;
    If AutoCompleteAllFiles
      ForEach FileList()
        If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And FileList()\Parser\SortedValid And (AutoCompleteProject = 0 Or FileList()\ProjectFile = 0)
          If FindProcedureFromSorted(@FileList()\Parser, @*StartItem\Name$, #ITEM_Declare, OpenModules())
            AddElement(CandidateModules())
            CandidateModules() = "IMPL::" + OpenModules()
            Break
          EndIf
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource) ; important!
    EndIf
    
  Next OpenModules()
  
  ; Now look at the implementations of the actual candidate modules
  ; Here we look for the actual #ITEM_Procedure
  ;
  ForEach CandidateModules()
    
    ; check active source first
    If *ActiveSource <> *ProjectInfo
      *Found = FindProcedureFromSorted(@*ActiveSource\Parser, @*StartItem\Name$, #ITEM_Procedure, CandidateModules())
      If *Found
        Line = *Found\SortedLine + 1
        If *ActiveSource\CurrentLine <> Line ; do not jump if the procedure header was doubleclicked
          ChangeActiveLine(Line, -5)
          
          ; Unfold the procedure block if it was folded
          SendEditorMessage(#SCI_ENSUREVISIBLE, Line)
          
          ProcedureReturn 1
        Else
          ProcedureReturn 0
        EndIf
      EndIf
    EndIf
    
    ; check projects
    If AutoCompleteProject And *ActiveSource\ProjectFile
      ForEach ProjectFiles()
        If ProjectFiles()\Source = 0 And ProjectFiles()\Parser\SortedValid
          *Found = FindProcedureFromSorted(@ProjectFiles()\Parser, @*StartItem\Name$, #ITEM_Procedure, CandidateModules())
        ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *ActiveSource And ProjectFiles()\Source\Parser\SortedValid
          *Found = FindProcedureFromSorted(@ProjectFiles()\Source\Parser, @*StartItem\Name$, #ITEM_Procedure, CandidateModules())
        Else
          *Found = 0
        EndIf
        
        If *Found
          Line = *Found\SortedLine + 1 ; item will be invalid once the file is loaded!
          If LoadSourceFile(ProjectFiles()\FileName$) ; need to load the file
            ChangeActiveLine(Line, -5)
            
            ; Unfold the procedure block if it was folded
            SendEditorMessage(#SCI_ENSUREVISIBLE, Line)
            
            ProcedureReturn 1
          Else
            ProcedureReturn 0
          EndIf
        EndIf
      Next ProjectFiles()
    EndIf
    
    ; check all other open sources now...
    ;
    If AutoCompleteAllFiles
      ForEach FileList()
        If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And FileList()\Parser\SortedValid And (AutoCompleteProject = 0 Or FileList()\ProjectFile = 0)
          *Found = FindProcedureFromSorted(@FileList()\Parser, @*StartItem\Name$, #ITEM_Procedure, CandidateModules())
          If *Found
            Line = *Found\SortedLine+1
            ChangeActiveSourcecode() ; changes *ActiveSource to the current FileList() element
            ChangeActiveLine(Line, -5)
            
            ; Unfold the procedure block if it was folded
            SendEditorMessage(#SCI_ENSUREVISIBLE, Line)
            
            ProcedureReturn 1
          EndIf
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource) ; important!
    EndIf
    
  Next CandidateModules()
  
  ProcedureReturn 0
EndProcedure


;- ToolsPanel plugin functions


Procedure ProcedureBrowser_CreateFunction(*Entry.ToolsPanelEntry, PanelItemID)
  
  ListViewGadget(#GADGET_ProcedureBrowser, 0, 0, 0, 0)
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependantToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_ProcedureBrowser)
  EndIf
  
  ProcedureBrowserMode = 1 ; indicate that the procedurebrowser is present
  
  If *ActiveSource
    UpdateProcedureList()
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_DestroyFunction(*Entry.ToolsPanelEntry)
  
  ProcedureBrowserMode = 0 ; indicate that the procedurebrowser is not enabled
  
EndProcedure


Procedure ProcedureBrowser_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  If *Entry\IsSeparateWindow
    ResizeGadget(#GADGET_ProcedureBrowser, 5, 5, PanelWidth-10, PanelHeight-10)
  Else
    ResizeGadget(#GADGET_ProcedureBrowser, 0, 0, PanelWidth, PanelHeight)
  EndIf
  
EndProcedure



Procedure ProcedureBrowser_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  
  If *ActiveSource <> *ProjectInfo And (*ActiveSource\IsForm = 0 Or (*ActiveSource\IsForm = 1 And FormWindows()\current_view = 0))
    ;
    ; On OSX, for some reason we get events when you type in the Scintilla, so only react when the browser is focused
    ; as else the Caret jumps around to the selected procedure all the time
    ;
    Protected EventValid = #False
    CompilerIf #CompileMac
      If EventGadgetID = #GADGET_ProcedureBrowser And GetActiveGadget() = #GADGET_ProcedureBrowser
        EventValid = #True
      EndIf
    CompilerElse
      If EventGadgetID = #GADGET_ProcedureBrowser
        EventValid = #True
      EndIf
    CompilerEndIf
    
    If EventValid
      index = GetGadgetState(#GADGET_ProcedureBrowser)
      If index <> -1
        SelectElement(ProcedureList(), index)
        ChangeActiveLine(ProcedureList()\Line, 0)
        
        ; Unfold the procedure block if it was folded
        SendEditorMessage(#SCI_ENSUREVISIBLE, ProcedureList()\Line)
        
        CompilerIf #CompileMac
          ; remove selection so the we won't get more jumps to the procedure start! (OSX specific problem)
          SetGadgetState(#GADGET_ProcedureBrowser, -1)
        CompilerEndIf
      EndIf
    EndIf
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_PreferenceLoad(*Entry.ToolsPanelEntry)
  
  PreferenceGroup("ProcedureBrowser")
  ProcedureBrowserSort = ReadPreferenceLong  ("Sort", 0) ; 0=by line, nogroup, 1=by line, group, 2=byname, nogroup  3 = byname, group
  DisplayProtoType     = ReadPreferenceLong  ("Prototype", 0)
  
EndProcedure


Procedure ProcedureBrowser_PreferenceSave(*Entry.ToolsPanelEntry)
  
  PreferenceComment("")
  PreferenceGroup("ProcedureBrowser")
  WritePreferenceLong("Sort", ProcedureBrowserSort)
  WritePreferenceLong("Prototype", DisplayProtoType)
  
EndProcedure


Procedure ProcedureBrowser_PreferenceStart(*Entry.ToolsPanelEntry)
  
  Backup_ProcedureBrowserSort = ProcedureBrowserSort
  Backup_DisplayProtoType = DisplayProtoType
  
EndProcedure


Procedure ProcedureBrowser_PreferenceApply(*Entry.ToolsPanelEntry)
  
  ProcedureBrowserSort = Backup_ProcedureBrowserSort
  DisplayProtoType = Backup_DisplayProtoType
  
EndProcedure


Procedure ProcedureBrowser_PreferenceCreate(*Entry.ToolsPanelEntry)
  
  Top = 10
  CheckBoxGadget(#GADGET_Preferences_ProcedureBrowserSort, 10, 10, 300, 25, Language("Preferences","ProcedureSort"))
  CheckBoxGadget(#GADGET_Preferences_ProcedureBrowserGroup, 10, 40, 300, 25, Language("Preferences","ProcedureGroup"))
  CheckBoxGadget(#GADGET_Preferences_ProcedureProtoType, 10, 70, 300, 25, Language("Preferences", "ProcedurePrototype"))
  
  GetRequiredSize(#GADGET_Preferences_ProcedureBrowserSort, @Width, @Height)
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ProcedureBrowserGroup))
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ProcedureProtoType))
  
  ResizeGadget(#GADGET_Preferences_ProcedureBrowserSort,  10, 10, Width, Height)
  ResizeGadget(#GADGET_Preferences_ProcedureBrowserGroup, 10, 15+Height, Width, Height)
  ResizeGadget(#GADGET_Preferences_ProcedureProtoType,    10, 20+Height*2, Width, Height)
  
  If Backup_ProcedureBrowserSort >= 2
    SetGadgetState(#GADGET_Preferences_ProcedureBrowserSort, 1)
  EndIf
  SetGadgetState(#GADGET_Preferences_ProcedureBrowserGroup, Backup_ProcedureBrowserSort % 2)
  
  SetGadgetState(#GADGET_Preferences_ProcedureProtoType, Backup_DisplayProtoType)
  
EndProcedure


Procedure ProcedureBrowser_PreferenceDestroy(*Entry.ToolsPanelEntry)
  
  Backup_ProcedureBrowserSort  = 2*GetGadgetState(#GADGET_Preferences_ProcedureBrowserSort)
  Backup_ProcedureBrowserSort  + GetGadgetState(#GADGET_PReferences_ProcedureBrowserGroup)
  Backup_DisplayProtoType = GetGadgetState(#GADGET_Preferences_ProcedureProtoType)
  
EndProcedure


Procedure ProcedureBrowser_PreferenceEvents(*Entry.ToolsPanelEntry, EventGadgetID)
  ;
  ; nothing here
  ;
EndProcedure

Procedure ProcedureBrowser_PreferenceChanged(*Entry.ToolsPanelEntry, IsConfigOpen)
  
  If IsConfigOpen
    Sort  = 2*GetGadgetState(#GADGET_Preferences_ProcedureBrowserSort)
    Sort  + GetGadgetState(#GADGET_PReferences_ProcedureBrowserGroup)
    If Sort <> ProcedureBrowserSort
      ProcedureReturn 1
    ElseIf GetGadgetState(#GADGET_Preferences_ProcedureProtoType) <> DisplayProtoType
      ProcedureReturn 1
    EndIf
    
  Else
    If ProcedureBrowserSort <> Backup_ProcedureBrowserSort Or DisplayProtoType <> Backup_DisplayProtoType
      ProcedureReturn 1
    EndIf
    
  EndIf
  
  ProcedureReturn 0
EndProcedure


;- Initialisation code
; This will make this Tool available to the editor
;
ProcedureBrowser_VT.ToolsPanelFunctions

ProcedureBrowser_VT\CreateFunction      = @ProcedureBrowser_CreateFunction()
ProcedureBrowser_VT\DestroyFunction     = @ProcedureBrowser_DestroyFunction()
ProcedureBrowser_VT\ResizeHandler       = @ProcedureBrowser_ResizeHandler()
ProcedureBrowser_VT\EventHandler        = @ProcedureBrowser_EventHandler()
ProcedureBrowser_VT\PreferenceLoad      = @ProcedureBrowser_PreferenceLoad()
ProcedureBrowser_VT\PreferenceSave      = @ProcedureBrowser_PreferenceSave()
ProcedureBrowser_VT\PreferenceStart     = @ProcedureBrowser_PreferenceStart()
ProcedureBrowser_VT\PreferenceApply     = @ProcedureBrowser_PreferenceApply()
ProcedureBrowser_VT\PreferenceCreate    = @ProcedureBrowser_PreferenceCreate()
ProcedureBrowser_VT\PreferenceDestroy   = @ProcedureBrowser_PreferenceDestroy()
ProcedureBrowser_VT\PreferenceEvents    = @ProcedureBrowser_PreferenceEvents()
ProcedureBrowser_VT\PreferenceChanged   = @ProcedureBrowser_PreferenceChanged()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @ProcedureBrowser_VT
AvailablePanelTools()\NeedPreferences      = 1
AvailablePanelTools()\NeedConfiguration    = 1
AvailablePanelTools()\PreferencesWidth     = 320
AvailablePanelTools()\PreferencesHeight    = 100
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "ProcedureBrowser"
AvailablePanelTools()\PanelTitle$          = "ProcedureBrowserShort"
AvailablePanelTools()\ToolName$            = "ProcedureBrowserLong"
