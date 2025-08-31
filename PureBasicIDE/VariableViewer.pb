; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

DataSection
  
  ; Those items that can be displayed in the variable viewer
  ;
  #VariableViewer_NbOptions = 8
  
  VariableViewer_OptionMap:
  Data.l #ITEM_Variable
  Data.l #ITEM_Array
  Data.l #ITEM_LinkedList
  Data.l #ITEM_Map
  Data.l #ITEM_Constant
  Data.l #ITEM_Prototype
  Data.l #ITEM_Structure
  Data.l #ITEM_Interface
  
EndDataSection

Structure VariableViewerData Extends ToolsPanelEntry
  IsEnabled.l
  ShowAllFiles.l
  ShowProject.l
  
  Current.l ; current displayed option index
  Type.l    ; current displayed #ITEM_ type
  
  Combo.i   ; combobox
  Filter.i  ; string gadget
  List.i    ; listicon gadget
  
  Prefs_ShowAllFiles.l
  Prefs_ShowProject.l
  
  ; gadget in preferences
  PrefsText.i
  PrefsSourceOnly.i
  PrefsProjectOnly.i
  PrefsProjectAllFiles.i
  PrefsAllFiles.i
EndStructure

Global *VariableViewer.VariableViewerData
Global *VariableViewerOptionMap.PTR = ?VariableViewer_OptionMap

Global NewList VariableViewerItems.s()

Procedure.s VariableViewer_OptionName(index)
  Restore SourceItem_Names
  For i = 0 To *VariableViewerOptionMap\l[index]
    Read.s Result$
  Next i
  ProcedureReturn Result$
EndProcedure

Procedure VariableViewer_AddFromTree(*Node.RadixNode, ModuleName$)
  Static NewList *SourceItems()
  
  RadixEnumerateAll(*Node, *SourceItems())
  
  ForEach *SourceItems()
    *Item.SourceItem = *SourceItems()
    AddElement(VariableViewerItems())
    VariableViewerItems() = ModulePrefix(*Item\Name$, ModuleName$)
  Next *SourceItems()
EndProcedure

Procedure UpdateVariableViewer()
  
  If *VariableViewer\IsEnabled And *ActiveSource
    If *ActiveSource = *ProjectInfo Or *ActiveSource\IsCode = 0
      ClearGadgetItems(*VariableViewer\List)
      
    Else
      
      ;StartGadgetFlickerFix(*VariableViewer\List)
      
      Type = *VariableViewer\Type
      ClearList(VariableViewerItems())
      
      ; Generate the sorted index for the active source
      ; does nothing if the data is already indexed
      SortParserData(@*ActiveSource\Parser, *ActiveSource)
      
      ; add ActiveSource items
      ForEach *ActiveSource\Parser\Modules()
        If Left(MapKey(*ActiveSource\Parser\Modules()), 6) <> "IMPL::"
          VariableViewer_AddFromTree(*ActiveSource\Parser\Modules()\Indexed[Type], *ActiveSource\Parser\Modules()\Name$)
        EndIf
      Next *ActiveSource\Parser\Modules()
      
      ; Add items from project sources
      If *VariableViewer\ShowProject And *ActiveSource\ProjectFile
        ForEach ProjectFiles()
          ForEach ProjectFiles()\Parser\Modules()
            If Left(MapKey(ProjectFiles()\Parser\Modules()), 6) <> "IMPL::"
              If ProjectFiles()\Source = 0
                VariableViewer_AddFromTree(ProjectFiles()\Parser\Modules()\Indexed[Type], ProjectFiles()\Parser\Modules()\Name$)
              ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *ActiveSource
                VariableViewer_AddFromTree(ProjectFiles()\Source\Parser\Modules()\Indexed[Type], ProjectFiles()\Parser\Modules()\Name$)
              EndIf
            EndIf
          Next ProjectFiles()\Parser\Modules()
        Next ProjectFiles()
      EndIf
      
      ; Add items from open files
      If *VariableViewer\ShowAllFiles
        ForEach FileList()
          If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And (*VariableViewer\ShowProject = 0 Or FileList()\ProjectFile = 0)
            ForEach FileList()\Parser\Modules()
              If Left(MapKey(FileList()\Parser\Modules()), 6) <> "IMPL::"
                VariableViewer_AddFromTree(FileList()\Parser\Modules()\Indexed[Type], FileList()\Parser\Modules()\Name$)
              EndIf
            Next FileList()\Parser\Modules()
          EndIf
        Next FileList()
        ChangeCurrentElement(FileList(), *ActiveSource) ; important!
      EndIf
      
      ; Filter and sort the list
      Filter$ = GetGadgetText(*VariableViewer\Filter)
      If Filter$
        ForEach VariableViewerItems()
          If FindString(VariableViewerItems(), Filter$, 1, #PB_String_NoCase) = 0
            DeleteElement(VariableViewerItems())
          EndIf
        Next VariableViewerItems()
      EndIf
      SortList(VariableViewerItems(), #PB_Sort_Ascending | #PB_Sort_NoCase)
      
      ; Update the gadget and eliminate doubles
      OldCount = CountGadgetItems(*VariableViewer\List)
      index    = 0
      *Last    = @""
      
      ForEach VariableViewerItems()
        ; The PeekI is because @StringList() is a pointer to the list element
        If CompareMemoryString(*Last, PeekI(@VariableViewerItems()), #PB_String_NoCaseAscii) <> #PB_String_Equal
          *Last = PeekI(@VariableViewerItems())
          
          If index < OldCount
            SetGadgetItemText(*VariableViewer\List, index, VariableViewerItems())
          Else
            AddGadgetItem(*VariableViewer\List, index, VariableViewerItems())
          EndIf
          index + 1
        EndIf
      Next VariableViewerItems()
      
      ; remove any additional items
      If index < OldCount
        For i = OldCount-1 To index Step -1
          RemoveGadgetItem(*VariableViewer\List, i)
        Next i
      EndIf
      
      ClearList(VariableViewerItems())
      ;StopGadgetFlickerFix(*VariableViewer\List)
    EndIf
  EndIf
  
EndProcedure

Procedure VariableViewer_CreateFunction(*Entry.VariableViewerData)
  
  *Entry\Combo = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
  For i = 0 To #VariableViewer_NbOptions-1
    AddGadgetItem(*Entry\Combo, -1, Language("Preferences","Option_"+VariableViewer_OptionName(i)))
  Next i
  
  *Entry\Filter = StringGadget(#PB_Any, 0, 0, 0, 0, #Empty$)
  *Entry\List = ListViewGadget(#PB_Any, 0, 0, 0, 0)
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(*Entry\List)
  EndIf
  
  If *Entry\Current < 0 Or *Entry\Current >= #VariableViewer_NbOptions
    *Entry\Current = 0
  EndIf
  
  SetGadgetState(*Entry\Combo, *Entry\Current)
  *Entry\Type = *VariableViewerOptionMap\l[*Entry\Current]
  *Entry\IsEnabled = 1
  
  UpdateVariableViewer()
EndProcedure

Procedure VariableViewer_DestroyFunction(*Entry.VariableViewerData)
  
  FreeGadget(*Entry\Combo)
  FreeGadget(*Entry\Filter)
  FreeGadget(*Entry\List)
  
  *Entry\IsEnabled = 0
  
EndProcedure

Procedure VariableViewer_ResizeHandler(*Entry.VariableViewerData, PanelWidth, PanelHeight)
  
  If *Entry\IsSeparateWindow
    ComboHeight = GetRequiredHeight(*Entry\Combo)
    FilterHeight = GetRequiredHeight(*Entry\Combo)
    ResizeGadget(*Entry\Combo, 5, 5, PanelWidth-10, ComboHeight)
    ResizeGadget(*Entry\Filter, 5, ComboHeight + 7, PanelWidth - 10, FilterHeight)
    ResizeGadget(*Entry\List, 5, 10 + ComboHeight + FilterHeight + 3, PanelWidth - 10, PanelHeight - 15 - ComboHeight - FilterHeight)
  Else
    ComboHeight = GetRequiredHeight(*Entry\Combo)
    FilterHeight = GetRequiredHeight(*Entry\Combo)
    ResizeGadget(*Entry\Combo, 0, 0, PanelWidth, ComboHeight)
    ResizeGadget(*Entry\Filter, 0, ComboHeight + 1, PanelWidth, FilterHeight)
    ResizeGadget(*Entry\List, 0, ComboHeight + FilterHeight + 2, PanelWidth, PanelHeight-ComboHeight-FilterHeight-2)
  EndIf
  
EndProcedure

Procedure VariableViewer_EventHandler(*Entry.VariableViewerData, EventGadgetID)
  
  If EventGadgetID = *Entry\List
    If EventType() = #PB_EventType_LeftDoubleClick And GetGadgetState(*Entry\List) <> -1
      If *ActiveSource <> *ProjectInfo
        InsertCodeString(GetGadgetItemText(*Entry\List, GetGadgetState(*Entry\List), 0))
      EndIf
    ElseIf EventType() = #PB_EventType_DragStart And GetGadgetState(*Entry\List) <> -1
      DragText(GetGadgetItemText(*Entry\List, GetGadgetState(*Entry\List), 0), #PB_Drag_Copy)
    EndIf
    
  ElseIf EventGadgetID = *Entry\Combo
    State = GetGadgetState(*Entry\Combo)
    If State <> -1 And State <> *Entry\Current
      *Entry\Current = State
      *Entry\Type    = *VariableViewerOptionMap\l[State]
      SetGadgetState(*Entry\List, -1) ; we change the content, do not preserve the state
      UpdateVariableViewer()
    EndIf
    
  ElseIf EventGadgetID = *Entry\Filter
    If EventType() = #PB_EventType_Change And Len(GetGadgetText(*Entry\Filter)) <> 1
      SetGadgetState(*Entry\List, -1) ; we change the content, do not preserve the state
      UpdateVariableViewer()
      
    EndIf
    
  EndIf
  
EndProcedure

Procedure VariableViewer_PreferenceLoad(*Entry.VariableViewerData)
  
  PreferenceGroup("VariableViewer")
  *Entry\ShowAllFiles   = ReadPreferenceLong("ShowAllFiles", 0)
  *Entry\ShowProject    = ReadPreferenceLong("ShowProject", 1)
  
  Current$ = UCase(ReadPreferenceString("Current", "Variable"))
  *Entry\Current = 0
  
  For i = 0 To #VariableViewer_NbOptions-1
    If Current$ = UCase(VariableViewer_OptionName(i))
      *Entry\Current = i
      Break
    EndIf
  Next i
  
EndProcedure

Procedure VariableViewer_PreferenceSave(*Entry.VariableViewerData)
  
  PreferenceComment("")
  PreferenceGroup("VariableViewer")
  WritePreferenceLong("ShowAllFiles", *Entry\ShowAllFiles)
  WritePreferenceLong("ShowProject", *Entry\ShowProject)
  WritePreferenceString("Current", VariableViewer_OptionName(*Entry\Current))
  
EndProcedure

Procedure VariableViewer_PreferenceStart(*Entry.VariableViewerData)
  
  *Entry\Prefs_ShowAllFiles = *Entry\ShowAllFiles
  *Entry\Prefs_ShowProject  = *Entry\ShowProject
  
EndProcedure

Procedure VariableViewer_PreferenceApply(*Entry.VariableViewerData)
  
  *Entry\ShowAllFiles = *Entry\Prefs_ShowAllFiles
  *Entry\ShowProject  = *Entry\Prefs_ShowProject
  
EndProcedure

Procedure VariableViewer_PreferenceCreate(*Entry.VariableViewerData)
  
  PrefsText                   = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Preferences","AddFrom"))
  *Entry\PrefsSourceOnly      = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Preferences","SourceOnly"))
  *Entry\PrefsProjectOnly     = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Preferences","ProjectOnly"))
  *Entry\PrefsProjectAllFiles = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Preferences","ProjectAllFiles"))
  *Entry\PrefsAllFiles        = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Preferences","AllFiles"))
  
  GetRequiredSize(PrefsText, @TextWidth, @TextHeight)
  GetRequiredSize(*Entry\PrefsSourceOnly, @Width, @Height)
  
  Width = Max(Width, GetRequiredWidth(*Entry\PrefsSourceOnly))
  Width = Max(Width, GetRequiredWidth(*Entry\PrefsProjectOnly))
  Width = Max(Width, GetRequiredWidth(*Entry\PrefsProjectAllFiles))
  Width = Max(Width, GetRequiredWidth(*Entry\PrefsAllFiles))
  Width = Max(Width+15, TextWidth) ; indent
  
  Top = 10
  ResizeGadget(PrefsText, 10, Top, Width, TextHeight): Top + TextHeight + 2
  ResizeGadget(*Entry\PrefsSourceOnly,      25, Top, Width-15, Height): Top + Height
  ResizeGadget(*Entry\PrefsProjectOnly,     25, Top, Width-15, Height): Top + Height
  ResizeGadget(*Entry\PrefsProjectAllFiles, 25, Top, Width-15, Height): Top + Height
  ResizeGadget(*Entry\PrefsAllFiles,        25, Top, Width-15, Height): Top + Height
  
  *VariableViewer\PreferencesWidth  = Max(320, Width+20) ; update the values so the scrollarea is properly sized
  *VariableViewer\PreferencesHeight = Top+10
  
  If *Entry\Prefs_ShowProject = 0 And *Entry\Prefs_ShowAllFiles = 0
    SetGadgetState(*Entry\PrefsSourceOnly, 1)
  ElseIf *Entry\Prefs_ShowProject And *Entry\Prefs_ShowAllFiles = 0
    SetGadgetState(*Entry\PrefsProjectOnly, 1)
  ElseIf *Entry\Prefs_ShowProject And *Entry\Prefs_ShowAllFiles
    SetGadgetState(*Entry\PrefsProjectAllFiles, 1)
  Else
    SetGadgetState(*Entry\PrefsAllFiles, 1)
  EndIf
  
EndProcedure

Procedure VariableViewer_PreferenceDestroy(*Entry.VariableViewerData)
  
  If GetGadgetState(*Entry\PrefsSourceOnly)
    *Entry\Prefs_ShowProject  = 0
    *Entry\Prefs_ShowAllFiles = 0
  ElseIf GetGadgetState(*Entry\PrefsProjectOnly)
    *Entry\Prefs_ShowProject  = 1
    *Entry\Prefs_ShowAllFiles = 0
  ElseIf GetGadgetState(*Entry\PrefsProjectAllFiles)
    *Entry\Prefs_ShowProject  = 1
    *Entry\Prefs_ShowAllFiles = 1
  Else
    *Entry\Prefs_ShowProject  = 0
    *Entry\Prefs_ShowAllFiles = 1
  EndIf
  
EndProcedure

Procedure VariableViewer_PreferenceEvents(*Entry.VariableViewerData, EventGadgetID)
  ;
  ; no events processed
  ;
EndProcedure

Procedure VariableViewer_PreferenceChanged(*Entry.VariableViewerData, IsConfigOpen)
  
  If IsConfigOpen
    If GetGadgetState(*Entry\PrefsSourceOnly)
      If *Entry\ShowProject Or *Entry\ShowAllFiles: ProcedureReturn 1: EndIf
    ElseIf GetGadgetState(*Entry\PrefsProjectOnly)
      If *Entry\ShowProject = 0 Or *Entry\ShowAllFiles: ProcedureReturn 1: EndIf
    ElseIf GetGadgetState(*Entry\PrefsProjectAllFiles)
      If *Entry\ShowProject = 0 Or *Entry\ShowAllFiles = 0: ProcedureReturn 1: EndIf
    Else
      If *Entry\ShowProject Or *Entry\ShowAllFiles = 0: ProcedureReturn 1: EndIf
    EndIf
    
  Else
    If *Entry\ShowAllFiles <> *Entry\Prefs_ShowAllFiles Or *Entry\ShowProject <> *Entry\Prefs_ShowProject
      ProcedureReturn 1
    EndIf
    
  EndIf
  
  ProcedureReturn 0
EndProcedure

;- Initialisation code
; This will make this Tool available to the editor
;
VariableViewer_VT.ToolsPanelFunctions

VariableViewer_VT\CreateFunction      = @VariableViewer_CreateFunction()
VariableViewer_VT\DestroyFunction     = @VariableViewer_DestroyFunction()
VariableViewer_VT\ResizeHandler       = @VariableViewer_ResizeHandler()
VariableViewer_VT\EventHandler        = @VariableViewer_EventHandler()
VariableViewer_VT\PreferenceLoad      = @VariableViewer_PreferenceLoad()
VariableViewer_VT\PreferenceSave      = @VariableViewer_PreferenceSave()
VariableViewer_VT\PreferenceStart     = @VariableViewer_PreferenceStart()
VariableViewer_VT\PreferenceApply     = @VariableViewer_PreferenceApply()
VariableViewer_VT\PreferenceCreate    = @VariableViewer_PreferenceCreate()
VariableViewer_VT\PreferenceDestroy   = @VariableViewer_PreferenceDestroy()
VariableViewer_VT\PreferenceEvents    = @VariableViewer_PreferenceEvents()
VariableViewer_VT\PreferenceChanged   = @VariableViewer_PreferenceChanged()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @VariableViewer_VT
AvailablePanelTools()\NeedPreferences      = 1
AvailablePanelTools()\NeedConfiguration    = 1
AvailablePanelTools()\PreferencesWidth     = 320
AvailablePanelTools()\PreferencesHeight    = 200
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "VariableViewer"
AvailablePanelTools()\PanelTitle$          = "VariableViewerShort"
AvailablePanelTools()\ToolName$            = "VariableViewerLong"

*VariableViewer = @AvailablePanelTools()  ; needed for the update function