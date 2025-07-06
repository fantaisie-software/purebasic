; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; The index of the columns for the ListIconView gadget.
Enumeration ProcedureBrowserColumn
  #ProcedureBrowserColumnName
EndEnumeration

; For the list with the names or texts and colors that are colored in the procedure browser.
Structure ProcedureBrowserItemColor
  Text$
  BackColor.i
  FrontColor.i
EndStructure

; The list with the texts and colors of the entries that are colored in the procedure browser.
; The content of the list is saved in the preferences and also filled from there.
Global NewList ProcedureBrowserItemColorList.ProcedureBrowserItemColor()

; Filter text for the procedure list.
Global ProcedureBrowserFilterText$
Global ProcedureBrowserFilter.i

; The status of the buttons. The status is saved in the preference and also loaded.
Global ProcedureBrowserHideModuleName
Global ProcedureBrowserHighlightProcedure
Global ProcedureBrowserScrollProcedure
Global ProcedureBrowserEnableFolding
Global ProcedureBrowserSwitchButtons

; The time interval in milliseconds for the timer. The intervall is saved in the preference and also loaded.
Global ProcedureBrowserHighlightTimer
Global ProcedureBrowserHighlightTimerForce

; The colors for the currently selected entry and comments in the procedure browser.
Global ProcedureBrowserHighlightFrontColor
Global ProcedureBrowserHighlightBackColor
Global ProcedureBrowserCommentFrontColor
Global ProcedureBrowserCommentBackColor

; Variables for managing the previous and currently selected entry in the procedure browser.
Global ProcedureBrowserPreviousBackColor
Global ProcedureBrowserPreviousFrontColor
Global ProcedureBrowserPreviousIndex
Global ProcedureBrowserPreviousType
Global ProcedureBrowserCurrentIndex

Global Backup_ProcedureMulticolor
Global Backup_ProcedureBrowserSort, Backup_DisplayProtoType

;- Functions for coloring, automatic selection and scrolling of entries in the Procezdur browser.

Procedure ProcedureBrowser_DisableColorButtons(Type.i)
  ; Only activate the buttons for coloring for procedures, macros and markers.
  
  State = Bool(Not (Type = 0 Or Type = 1 Or Type = 2))
  DisableGadget(#GADGET_ProcedureBrowser_FrontColor, State)
  DisableGadget(#GADGET_ProcedureBrowser_BackColor, State)
  DisableGadget(#GADGET_ProcedureBrowser_RestoreColor, State)	
  
EndProcedure


Procedure.i ProcedureBrowser_IsLineInside(Line.i, Type.i)
  ; Determines whether the line number is within a procedure or macro.
  
  PushListPosition(ProcedureList())
  
  Index = -1
  
  ForEach ProcedureList() 
    With ProcedureList()
      If \Type = Type ; procedure 0 or macro 1
        If \Line <= Line And \LineEnd >= Line
          ; The line is within the procedure or macro.
          Index = Counter
          Break
        EndIf
      EndIf
    EndWith
    Counter + 1
  Next
  
  PopListPosition(ProcedureList())
  
  
  ProcedureReturn Index
EndProcedure


Procedure.i ProcedureBrowser_ItemColorSet(Index.i, Text$, Type.i)
  ; If there is an entry for coloring with the passed text in the list, this entry is displayed in color.
  
  If Not ProcedureBrowserHideModuleName
    Pos = FindString(Text$, "::")
    If Pos
      Text$ = Mid(Text$, Pos + 2)
    EndIf
  EndIf
  
  ForEach ProcedureBrowserItemColorList()
    With ProcedureBrowserItemColorList()
      If \Text$ = Left(Text$, Len(\Text$))
        If \BackColor <> -1
          SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_BackColor, \BackColor,
            #ProcedureBrowserColumnName)
        Else
          SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_BackColor, ToolsPanelBackColor,
            #ProcedureBrowserColumnName)
        EndIf
        If \FrontColor <> -1
          SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_FrontColor, \FrontColor,
            #ProcedureBrowserColumnName)
        ElseIf Type = 2 ; marker
           SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_FrontColor, ProcedureBrowserCommentFrontColor,
            #ProcedureBrowserColumnName)
       Else
          SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_FrontColor, ToolsPanelFrontColor,
            #ProcedureBrowserColumnName)
        EndIf
        ColorSet = #True
        Break
      EndIf
    EndWith
  Next
  
  ProcedureReturn ColorSet
EndProcedure


Procedure ProcedureBrowser_ItemColorGet(Index.i, Front.i)
  ; Returns the foreground or background color for the entry.

  PushListPosition(ProcedureList())
  
  Color = -1
  
  If SelectElement(ProcedureList(), Index)
    Name$ = ProcedureList()\Name$
    ForEach ProcedureBrowserItemColorList()
      With ProcedureBrowserItemColorList()
        If \Text$ = Name$
          If Front
            Color = \FrontColor
          Else
            Color = \BackColor
          EndIf
          Break
        EndIf
      EndWith
    Next
  EndIf
  
  PopListPosition(ProcedureList())
  
  ProcedureReturn Color
EndProcedure


Procedure ProcedureBrowser_ItemMarker(Index.i, Type.i)
  ; Displays an marker entry in the procedure browser.

  If Index > -1 And Type = 2 ; marker
    SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_BackColor, ProcedureBrowserCommentBackColor,
      #ProcedureBrowserColumnName)
    SetGadgetItemColor(#GADGET_ProcedureBrowser, Index, #PB_Gadget_FrontColor, ProcedureBrowserCommentFrontColor,
      #ProcedureBrowserColumnName)
    Marker = #True
  EndIf
  
  ProcedureReturn Marker
EndProcedure


Procedure ProcedureBrowser_ItemHighlight(Index.i, Type.i)
  ; Displays an entry in the procedure browser in the selected state. A previously selected entry is displayed normally again.
  
  ; Display the previous entry normally again.
  If ProcedureBrowserPreviousIndex > -1 And ProcedureBrowserPreviousIndex < ListSize(ProcedureList())
    If (ProcedureBrowserPreviousIndex < CountGadgetItems(#GADGET_ProcedureBrowser))
      PushListPosition(ProcedureList())
      
      SelectElement(ProcedureList(), ProcedureBrowserPreviousIndex)
      Text$ = ProcedureList()\Name$
      ProcedureBrowser_ItemMarker(ProcedureBrowserPreviousIndex, ProcedureList()\Type)
      If Not ProcedureBrowser_ItemColorSet(ProcedureBrowserPreviousIndex, Text$, ProcedureList()\Type)
        If Not ProcedureBrowser_ItemMarker(ProcedureBrowserPreviousIndex, ProcedureList()\Type)
          SetGadgetItemColor(#GADGET_ProcedureBrowser, ProcedureBrowserPreviousIndex,
            #PB_Gadget_BackColor, ToolsPanelBackColor, #ProcedureBrowserColumnName)
          SetGadgetItemColor(#GADGET_ProcedureBrowser, ProcedureBrowserPreviousIndex,
            #PB_Gadget_FrontColor, ToolsPanelFrontColor, #ProcedureBrowserColumnName)
        EndIf
      EndIf
      ProcedureBrowserPreviousIndex = -1
  
      PopListPosition(ProcedureList())
    EndIf
  EndIf
  
  ; Highlight the currently selected procedure, marker. macro or issue outside the procedure.
  If Index > -1 And Index < ListSize(ProcedureList())
      ProcedureBrowserPreviousIndex = Index
      ProcedureBrowserPreviousType = Type
      SetGadgetItemColor(#GADGET_ProcedureBrowser, Index,
        #PB_Gadget_BackColor, ProcedureBrowserHighlightBackColor, #ProcedureBrowserColumnName)
      SetGadgetItemColor(#GADGET_ProcedureBrowser, Index,
        #PB_Gadget_FrontColor, ProcedureBrowserHighlightFrontColor, #ProcedureBrowserColumnName)
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_ItemColorSave(Text$, FrontColor.i, BackColor.i)
  ; Saves the entry for coloring in a list. An existing module name and prototype is removed.
  
  Pos = FindString(Text$, "::")
  If Pos
    Text$ = Mid(Text$, Pos + 2)
  EndIf
  
  If Asc(Text$)
    ForEach ProcedureBrowserItemColorList()
      If ProcedureBrowserItemColorList()\Text$ = Text$
        Exists = #True
        Break
      EndIf
    Next
    
    With ProcedureBrowserItemColorList()
      If Not Exists
        AddElement(ProcedureBrowserItemColorList())
        \FrontColor = -1
        \BackColor = -1
      EndIf
    
      If Not Exists
        \Text$ = Text$
      EndIf
      If FrontColor <> -1
        \FrontColor = FrontColor
      EndIf
      If BackColor <> -1
        \BackColor = BackColor
      EndIf
    EndWith
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_ItemColorDelete(Text$)
  ; Removes an entry for coloring from the list.
  
  Pos = FindString(Text$, "::")
  If Pos
    Text$ = Mid(Text$, Pos + 2)
  EndIf
  
  ForEach ProcedureBrowserItemColorList()
    If ProcedureBrowserItemColorList()\Text$ = Text$
      DeleteElement(ProcedureBrowserItemColorList())
      Break
    EndIf
  Next
  
EndProcedure


Procedure ProcedureBrowser_ItemColorUpdate()
  ; Updates the entries in the procedure browser with the current colors.

  PushListPosition(ProcedureList())
  
  SetGadgetItemColor(#GADGET_ProcedureBrowser, #PB_All, #PB_Gadget_BackColor, ToolsPanelBackColor,
    #ProcedureBrowserColumnName)
  SetGadgetItemColor(#GADGET_ProcedureBrowser, #PB_All, #PB_Gadget_FrontColor, ToolsPanelFrontColor,
    #ProcedureBrowserColumnName)
  
  ForEach ProcedureList()
    ProcedureBrowser_ItemMarker(Index, ProcedureList()\Type)
    ProcedureBrowser_ItemColorSet(Index, ProcedureList()\Name$, ProcedureList()\Type)
    Index + 1
  Next

  ProcedureBrowser_ItemHighlight(ProcedureBrowserPreviousIndex, ProcedureBrowserPreviousType)

  PopListPosition(ProcedureList())
  
EndProcedure


Procedure ProcedureBrowser_ItemsCopyClipbord(State.i)
  ; Copies the procedure names to the clipboard.  Options: Ctrl = All, Shift = Arguments.
  
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      LF$ = #CRLF$
    CompilerCase #PB_OS_Linux
      LF$ = #LF$
    CompilerCase #PB_OS_MacOS
      LF$ = #CR$
    CompilerDefault
      CompilerError "Unknown OS."
  CompilerEndSelect
  
  CompilerIf #CompileWindows
    All = GetAsyncKeyState_(#VK_CONTROL) & $8000
    Arguments = GetAsyncKeyState_(#VK_SHIFT) & $8000
  CompilerElseIf #CompileLinuxGtk
    All = Bool(State & #GDK_CONTROL_MASK)
    Arguments = Bool(State & #GDK_SHIFT_MASK)
  CompilerElseIf #CompileMac
    All = ModifierKeyPressed(#PB_Shortcut_Control)
    Arguments = ModifierKeyPressed(#PB_Shortcut_Shift)
  CompilerEndIf
  
  PushListPosition(ProcedureList())
  
  ForEach ProcedureList()
    With ProcedureList()
      
      If All
        Text$ + \Name$
        If Arguments
          Text$ + \Prototype$
        EndIf
        Text$ + LF$
      ElseIf \Type = 0 ; Procedure
        Text$ + \Name$
        If Arguments
          Text$ + \Prototype$
        EndIf
        Text$ + LF$
      EndIf
      
    EndWith
  Next
  
  PopListPosition(ProcedureList())
  
  If Len(Text$)
    SetClipboardText(Text$)
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_Highlight(ListIndex.i, ListType.i, EditorLine.i)
  ; This procedure is called by the timer that was created in the 'ProcedureBrowser_CreateFunction()' procedure.
  ; Here, the corresponding procedure is selected in the procedure browser and colored depending on the position
  ; of the cursor in the editor.
  Static PreviousCurrentLine.i = 1

  If Not ListSize(ProcedureList())
    ProcedureReturn
  EndIf
  
  ; If the button or the status for highlighting the current procedure is activated, the flag is set in the
  ; 'ProcedureBrowser_EventHandler()' procedure. This forces the procedure to be highlighted.
  If ProcedureBrowserHighlightTimerForce
    ProcedureBrowserHighlightTimerForce = #False
    PreviousCurrentLine = 0
  EndIf
  
  ; Continue only if the cursor position in the editor has changed.
  If *ActiveSource\CurrentLine <> PreviousCurrentLine
    If ListIndex = -1
    
      PushListPosition(ProcedureList())
      
      ; Search the procedure list and find the last procedure, marker, macro or issue before or at the cursor position.
      If EditorLine = -1
        CurrentLine = *ActiveSource\CurrentLine
      Else
        CurrentLine = EditorLine
      EndIf
      PreviousCurrentLine = CurrentLine
      
      Index = -1
      AboveLine = -1
      
      InsideProcedure = Bool(ProcedureBrowser_IsLineInside(CurrentLine, 0) > -1) ; procedure
      InsideMacro = Bool(ProcedureBrowser_IsLineInside(CurrentLine, 1) > -1) ; macro
       
      ForEach ProcedureList()
        With ProcedureList()
           
            If \Line = CurrentLine
              Index = Counter
              Type = \Type
              Break
              
            ElseIf InsideProcedure Or InsideMacro
              
              If \Line < CurrentLine And \Line > AboveLine
                AboveLine = \Line
                Index = Counter
                Type = \Type
                
              ElseIf ProcedureBrowserSort = 0 ; unsorted list
                Break
              EndIf
              
            Else  ; Not (InsideProcedure And InsideMacro)
            
              ; Procedure.
              If \Type = 0 And \Line > AboveLine And \Line < CurrentLine And \LineEnd < CurrentLine
                AboveLine = \Line
                Index = Counter
                Type = \Type
             
              ; Macro.
              ElseIf \Type = 1 And \Line > AboveLine And \Line < CurrentLine And \LineEnd < CurrentLine And
                        ProcedureBrowser_IsLineInside(\Line, 0) = -1
                AboveLine = \Line
                Index = Counter
                Type = \Type
            
              ; Marker or issue.
              ElseIf (\Type = 2 Or \Type = 3) And \Line > AboveLine And \Line <= CurrentLine And
                        ProcedureBrowser_IsLineInside(\Line, 0) = -1 And ProcedureBrowser_IsLineInside(\Line, 1) = -1
                AboveLine = \Line
                Index = Counter
                Type = \Type
                
                If \Type = 3
                EndIf
              ElseIf \Line > CurrentLine And ProcedureBrowserSort = 0 ; unsorted list
                Break
              EndIf
            
            EndIf
  
        EndWith
        Counter + 1
      Next
      PopListPosition(ProcedureList())
    Else
      Index = ListIndex
      Type = ListType
      PreviousCurrentLine = EditorLine
    EndIf
        
    If Index > -1  And  ProcedureBrowserCurrentIndex <> Index
      ; Display the previously selected item again with user or standard colors and highlight the currently selected item.
      If ProcedureBrowserHighlightProcedure Or ListIndex > -1
        ProcedureBrowser_ItemHighlight(index, Type)
      
        ; If the button for automatic scrolling is active, bring the current item in the procedure browser into the visible area.
        If ProcedureBrowserScrollProcedure
          SetGadgetState(#GADGET_ProcedureBrowser, Index)
          SetGadgetState(#GADGET_ProcedureBrowser, -1)
        EndIf
    
        ProcedureBrowserCurrentIndex = Index
      EndIf
          
      ; Only activate the buttons for coloring for procedures, macros and markers.
      ProcedureBrowser_DisableColorButtons(Type)
    
    ElseIf Index = -1
      ProcedureBrowser_ItemHighlight(-1, -1)
      ProcedureBrowserCurrentIndex = -1
      ProcedureBrowser_DisableColorButtons(-1)
    EndIf
    
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_HighlightTimer()
  ; This procedure is called by the timer that was created in the 'ProcedureBrowser_CreateFunction()' procedure.
  ; Here, the corresponding procedure is selected in the procedure browser and colored depending on the position
  ; of the cursor in the editor.

  ProcedureBrowser_Highlight(-1, -1, -1)
  
EndProcedure


Procedure ProcedureBrowser_Filter(Text$)
  ; Filters the entries in the procedure list or removes the filter.
  Static PreviousHighlightProcedure.i
  
  ; Deactivate highlighting for active filters.
  If Asc(Text$)
    ProcedureBrowserFilter = #True
    SetGadgetState(#GADGET_ProcedureBrowser_HighlightProcedure, 0)
    DisableGadget(#GADGET_ProcedureBrowser_HighlightProcedure, #True)
    If Asc(ProcedureBrowserFilterText$) = 0
      PreviousHighlightProcedure = ProcedureBrowserHighlightProcedure
    EndIf
    ProcedureBrowserHighlightProcedure = 0
  Else
    ProcedureBrowserFilter = #False
    DisableGadget(#GADGET_ProcedureBrowser_HighlightProcedure, #False)
    SetGadgetState(#GADGET_ProcedureBrowser_HighlightProcedure, PreviousHighlightProcedure)
    ProcedureBrowserHighlightProcedure = PreviousHighlightProcedure
  EndIf
  
  ProcedureBrowserFilterText$ = Text$
  UpdateProcedureList()
  
EndProcedure


CompilerIf #CompileLinuxGtk
  ProcedureC ProcedureBrowser_FilterKeyEvent(*Widget, *Event.GdkEventKey, user_data)
      
    PostEvent(#PB_Event_Gadget, #WINDOW_Main, #GADGET_ProcedureBrowser_FilterInput, #PB_EventType_Change)
  
  EndProcedure
  
  
  Procedure ProcedureBrowser_CopyClipboardButtonEvent(*Widget, *Event.GdkEventButton, user_data)

    ; Control and Shift: *Event\state & #GDK_CONTROL_MASK; #GDK_SHIFT_MASK
    ProcedureBrowser_ItemsCopyClipbord(*Event\state)
    SetActiveGadget(*ActiveSource\EditorGadget)
    
  EndProcedure
CompilerEndIf

;- 

CompilerIf #CompileLinuxGtk
  ProcedureC UpdateProcedureList_GtkScroll(ScrollPosition.i)
    ; As this callback is called async using g_idle_add() we need to ensures the gadget isn't freed yet.
    If IsGadget(#GADGET_ProcedureBrowser)
      SetListViewScroll(#GADGET_ProcedureBrowser, ScrollPosition)
    EndIf
  EndProcedure
CompilerEndIf


Procedure UpdateProcedureList(ScrollPosition.l = -1) ; scroll position -1 means keep current position
  
  ; The Issues tool usually needs an update two when the ProcedureBrowser does,
  ; so just do this always from here for simplicity
  UpdateIssueList()
  
  If *ActiveSource = *ProjectInfo Or *ActiveSource\IsCode = 0
    ClearList(ProcedureList())
    If ProcedureBrowserMode = 1
      ClearGadgetItems(#GADGET_ProcedureBrowser)
    EndIf
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
                ; Depending on the status of the button for displaying the module name, add or omit the module name.
                If ProcedureMulticolor
                  If Not ProcedureBrowserHideModuleName
                    ModulePrefix$ = *Item\Name$ + "::"
                  EndIf
                Else
                  ModulePrefix$ = *Item\Name$ + "::"
                EndIf
                
              Case #ITEM_EndModule, #ITEM_EndDeclareModule
                ModulePrefix$ = ""
                
              Case #ITEM_Procedure
                ; Save the current element from the list; it is still required in case the procedure ends.
                ;AddElement(ProcedureList())
                *ProcedureListProcedure.ProcedureInfo = AddElement(ProcedureList())
                ProcedureList()\Name$ = ModulePrefix$ + *Item\Name$
                ProcedureList()\Line  = i+1
                ProcedureList()\Type  = 0
                Procedurelist()\Prototype$ = *Item\Prototype$
                
                ; Save the line number for the end of the procedure.
                ; It is required to display no markers, macros or issues within a procedure selected in the procedure browser.
              Case #ITEM_ProcedureEnd
                If *ProcedureListProcedure.ProcedureInfo
                  *ProcedureListProcedure\LineEnd = i + 1
                  *ProcedureListProcedure = #Null
                EndIf 
                
              Case #ITEM_Macro
                 ; Save the current element from the list; it is still required in case the macro ends.
                *ProcedureListMacro.ProcedureInfo = AddElement(ProcedureList())
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
                
            ; Save the line number for the end of the macro.
            ; It is required to display no markers or issues within a macro selected in the procedure browser.
            If *ProcedureListMacro.ProcedureInfo
              *ProcedureListMacro\LineEnd = i + 1
              *ProcedureListMacro = #Null
            EndIf
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
            If CompareMemoryString(@ProcedureList()\Name$, @*Previous\Name$, #PB_String_NoCaseAscii) < 0
              Change = 1
            EndIf
            
          ElseIf ProcedureBrowserSort = 3
            If ProcedureList()\Type = *Previous\Type
              If CompareMemoryString(@ProcedureList()\Name$, @*Previous\Name$, #PB_String_NoCaseAscii) < 0
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
    
    ; Filter the procedure list.
    If ProcedureMulticolor And ProcedureBrowserFilter
        ForEach ProcedureList()
          If Not FindString(ProcedureList()\Name$, ProcedureBrowserFilterText$, 1, #PB_String_NoCase)
            DeleteElement(ProcedureList(), 0)
          EndIf
        Next
    EndIf
    
    ; do not show jump when restoring scroll position on updates without source code switch
    StartGadgetFlickerFix(#GADGET_ProcedureBrowser)
    
    ; preserve the selection if possible
    OldIndex = GetGadgetState(#GADGET_ProcedureBrowser)
    NewIndex = -1
    If OldIndex <> -1
      OldText$ = GetGadgetItemText(#GADGET_ProcedureBrowser, OldIndex)
    EndIf
    
    If ScrollPosition = -1
      ScrollPosition = GetListViewScroll(#GADGET_ProcedureBrowser)
    EndIf
    
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
      If CompareMemoryString(@OldText$, @Text$, #PB_String_NoCaseAscii) = 0 And OldIndex <> -1
        NewIndex = CountGadgetItems(#GADGET_ProcedureBrowser)-1
      EndIf
    Next ProcedureList()
    
    CompilerIf #CompileLinuxGtk
      SetGadgetState(#GADGET_ProcedureBrowser, -1)
      
      ; Need to postpone the scroll update untill all events in the gadget were processed
      ; Note that PostEvent() is too early (not all gtk events will be done then)
      g_idle_add_(@UpdateProcedureList_GtkScroll(), ScrollPosition)
    CompilerElse
      ; restore old selection
      If NewIndex <> -1
        SetGadgetState(#GADGET_ProcedureBrowser, NewIndex)
      EndIf
      
      ; TODO-QT
      ; This is also to soon for QT (same as Gtk above) but I found no way to trigger it later.
      ; (PostEvent() is too soon, so is QApplication::postEvent() with a custom event)
      ; A timer works but is a visible delay (even a 0ms timer) so this is no solution.
      SetListViewScroll(#GADGET_ProcedureBrowser, ScrollPosition)
    CompilerEndIf
    
    If ProcedureMulticolor
      ProcedureBrowserCurrentIndex = NewIndex
     ; Color the entrys in the procedure browser.
      ProcedureBrowser_ItemColorUpdate()
      ProcedureBrowserHighlightTimerForce = #True
      ProcedureBrowser_Highlight(-1, -1, -1)
    EndIf
      
    StopGadgetFlickerFix(#GADGET_ProcedureBrowser)
    
  EndIf
  
EndProcedure

Procedure FindProcedureFromSorted(*Parser.ParserData, *Name, Type, ModuleName$)
  ProcedureReturn RadixLookupValue(*Parser\Modules(UCase(ModuleName$))\Indexed[Type], PeekS(*Name))
EndProcedure

Procedure JumpToProcedure() ; return 1 if a jump was done
  Protected *Found.SourceItem
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn 0
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
        If *ActiveSource\CurrentLine <> Line ; do not jump if the procedure header was double-clicked
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


Procedure ProcedureBrowser_CreateFunction(*Entry.ToolsPanelEntry)
  
  If ProcedureMulticolor
    ProcedureBrowserPreviousIndex = -1
    ProcedureBrowserCurrentIndex = -1
    
    ProcedureBrowserHighlightFrontColor = Colors(#COLOR_SelectionFront)\UserValue
    ProcedureBrowserHighlightBackColor = Colors(#COLOR_Selection)\UserValue
    If Colors(#COLOR_Comment)\Enabled
      ProcedureBrowserCommentFrontColor = Colors(#COLOR_Comment)\UserValue
    Else
      ProcedureBrowserCommentFrontColor = ToolsPanelFrontColor
    EndIf
    ProcedureBrowserCommentBackColor = ToolsPanelBackColor
    
    ; Filter.
    StringGadget(#GADGET_ProcedureBrowser_FilterInput, 0, 0, 0, 0, "")
      
    ; Buttons for coloring, automatic selection and scrolling. 
    ButtonImageGadget(#GADGET_ProcedureBrowser_HideModuleNames, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_HideModuleNames), #PB_Button_Toggle)
    ButtonImageGadget(#GADGET_ProcedureBrowser_HighlightProcedure, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_HighlightProcedure), #PB_Button_Toggle)
    ButtonImageGadget(#GADGET_ProcedureBrowser_ScrollProcedure, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_ScrollProcedure), #PB_Button_Toggle)
    ButtonImageGadget(#GADGET_ProcedureBrowser_EnableFolding, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_EnableFolding), #PB_Button_Toggle)
    ButtonImageGadget(#GADGET_ProcedureBrowser_FrontColor, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_FrontColor))
    ButtonImageGadget(#GADGET_ProcedureBrowser_BackColor, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_BackColor))
    ButtonImageGadget(#GADGET_ProcedureBrowser_RestoreColor, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_RestoreColor))
    ButtonImageGadget(#GADGET_ProcedureBrowser_CopyClipboard, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_CopyClipboard))
    ButtonImageGadget(#GADGET_ProcedureBrowser_SwitchButtons, 0, 0, 0, 0, ImageID(#IMAGE_ProcedureBrowser_SwitchButtons))
    
    CompilerIf #CompileLinuxGtk
      GtkSignalConnect(GadgetID(#GADGET_ProcedureBrowser_CopyClipboard), "button-press-event", @ProcedureBrowser_CopyClipboardButtonEvent(), 0)
    CompilerEndIf

    GadgetToolTip(#GADGET_ProcedureBrowser_HideModuleNames, Language("ToolsPanel", "HideModuleNames"))
    GadgetToolTip(#GADGET_ProcedureBrowser_HighlightProcedure, Language("ToolsPanel", "HighlightProcedure"))
    GadgetToolTip(#GADGET_ProcedureBrowser_ScrollProcedure, Language("ToolsPanel", "ScrollProcedure"))
    GadgetToolTip(#GADGET_ProcedureBrowser_EnableFolding, Language("ToolsPanel", "EnableFolding"))
    GadgetToolTip(#GADGET_ProcedureBrowser_FrontColor, Language("ToolsPanel", "FrontColor"))
    GadgetToolTip(#GADGET_ProcedureBrowser_BackColor, Language("ToolsPanel", "BackColor"))
    GadgetToolTip(#GADGET_ProcedureBrowser_RestoreColor, Language("ToolsPanel", "RestoreColor"))
    GadgetToolTip(#GADGET_ProcedureBrowser_CopyClipboard, Language("ToolsPanel", "CopyClipboard"))
    GadgetToolTip(#GADGET_ProcedureBrowser_SwitchButtons, Language("ToolsPanel", "SwitchButtons"))
  
    If EnableAccessibility
      ; Sets a label on the buttons for screen reader users.
      ; This label is only ever seen by screen readers, and never visually shown.
      SetGadgetText(#GADGET_ProcedureBrowser_HideModuleNames, Language("ToolsPanel", "HideModuleNames"))
      SetGadgetText(#GADGET_ProcedureBrowser_HighlightProcedure, Language("ToolsPanel", "HighlightProcedure"))
      SetGadgetText(#GADGET_ProcedureBrowser_ScrollProcedure, Language("ToolsPanel", "ScrollProcedure"))
      SetGadgetText(#GADGET_ProcedureBrowser_EnableFolding, Language("ToolsPanel", "EnableFolding"))
      SetGadgetText(#GADGET_ProcedureBrowser_FrontColor, Language("ToolsPanel", "FrontColor"))
      SetGadgetText(#GADGET_ProcedureBrowser_BackColor, Language("ToolsPanel", "BackColor"))
      SetGadgetText(#GADGET_ProcedureBrowser_RestoreColor, Language("ToolsPanel", "RestoreColor"))
      SetGadgetText(#GADGET_ProcedureBrowser_CopyClipboard, Language("ToolsPanel", "CopyClipboard"))
      SetGadgetText(#GADGET_ProcedureBrowser_SwitchButtons, Language("ToolsPanel", "SwitchButtons"))
     EndIf

    SetGadgetState(#GADGET_ProcedureBrowser_HideModuleNames, ProcedureBrowserHideModuleName)
    SetGadgetState(#GADGET_ProcedureBrowser_HighlightProcedure, ProcedureBrowserHighlightProcedure)
    SetGadgetState(#GADGET_ProcedureBrowser_ScrollProcedure, ProcedureBrowserScrollProcedure)
    SetGadgetState(#GADGET_ProcedureBrowser_EnableFolding, ProcedureBrowserEnableFolding)
    
    DisableGadget(#GADGET_ProcedureBrowser_FrontColor, #True)
    DisableGadget(#GADGET_ProcedureBrowser_BackColor, #True)
    DisableGadget(#GADGET_ProcedureBrowser_RestoreColor, #True)

    ListIconGadget(#GADGET_ProcedureBrowser, 0, 0, 0, 0, "Procedures", 100, #PB_ListIcon_FullRowSelect)
    
    CompilerIf #CompileWindows
      SetWindowLongPtr_(GadgetID(#GADGET_ProcedureBrowser), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#GADGET_ProcedureBrowser), #GWL_STYLE) | #LVS_NOCOLUMNHEADER)
    CompilerElseIf #CompileLinuxGtk
      gtk_tree_view_set_headers_visible_(GadgetID(#GADGET_ProcedureBrowser), #False)
    CompilerElseIf #CompileMacCocoa
      CocoaMessage(0, GadgetID(#GADGET_ProcedureBrowser), "setHeaderView:", #False)
    CompilerEndIf
    
  Else
    ListViewGadget(#GADGET_ProcedureBrowser, 0, 0, 0, 0)
  EndIf

  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_ProcedureBrowser)
  EndIf
  
  ProcedureBrowserMode = 1 ; indicate that the procedurebrowser is present
  
  If *ActiveSource
    UpdateProcedureList()
  EndIf
  
  If ProcedureMulticolor
    ; Add a timer so that the procedure browser can be updated with the current cursor position in the editor.
    AddWindowTimer(#WINDOW_Main, #TIMER_ProcedureBrowser, ProcedureBrowserHighlightTimer)
    BindEvent(#PB_Event_Timer, @ProcedureBrowser_HighlightTimer(), #WINDOW_Main, #TIMER_ProcedureBrowser)
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_DestroyFunction(*Entry.ToolsPanelEntry)
  
  ProcedureBrowserMode = 0 ; indicate that the procedurebrowser is not enabled
  
  ; It is not checked whether the timer is active at all. The ProcedureMulticolor variable is no longer valid for a query.
  ; Remove the timer.
  RemoveWindowTimer(#WINDOW_Main, #TIMER_ProcedureBrowser)
  UnbindEvent(#PB_Event_Timer, @ProcedureBrowser_HighlightTimer(), #WINDOW_Main, #TIMER_ProcedureBrowser)
  
  ; Two different gadgets, ListView and ListIconView, are created with the same number, but not at the same time.
  ; Maybe this is a problem, so release the gadget here.
  If IsGadget(#GADGET_ProcedureBrowser)
    FreeGadget(#GADGET_ProcedureBrowser)
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  If ProcedureMulticolor
    GetRequiredSize(#GADGET_ProcedureBrowser_SwitchButtons, @Width.l, @Height.l)
    
    CompilerIf #CompileWindows
      Space = 3
    CompilerElse
      Space = 6 ; looks better on Linux/OSX with some more space
    CompilerEndIf

    If *Entry\IsSeparateWindow
      ; Small hack: If there is enough space, place the buttons next to the 'StayOnTop' checkbox
      If #DEFAULT_CanWindowStayOnTop
        GetRequiredSize(*Entry\ToolStayOnTop, @StayOnTopWidth.l, @StayOnTopHeight.l)
        If StayOnTopWidth < PanelWidth-10-5*Width-4*Space
          PanelHeight = WindowHeight(*Entry\ToolWindowID)
          ResizeGadget(*Entry\ToolStayOnTop, #PB_Ignore, PanelHeight-5-Height+(Height-StayOnTopHeight)/2, StayOnTopWidth, #PB_Ignore)
        EndIf
      EndIf
      
      ResizeGadget(#GADGET_ProcedureBrowser, 5, 10+Height, PanelWidth-10, PanelHeight-Height-25-Height)
    Else
      ResizeGadget(#GADGET_ProcedureBrowser, 0, 10+Height, PanelWidth, PanelHeight-Height-20-Height)
    EndIf

    ResizeGadget(#GADGET_ProcedureBrowser_FilterInput, 5, 5, PanelWidth-10, Height)
    
    ResizeGadget(#GADGET_ProcedureBrowser_HideModuleNames, PanelWidth-5-5*Width-4*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_HighlightProcedure, PanelWidth-5-4*Width-3*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_ScrollProcedure, PanelWidth-5-3*Width-2*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_EnableFolding, PanelWidth-5-2*Width-Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_FrontColor, PanelWidth-5-5*Width-4*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_BackColor, PanelWidth-5-4*Width-3*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_RestoreColor, PanelWidth-5-3*Width-2*Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_CopyClipboard, PanelWidth-5-2*Width-Space, PanelHeight-Height-5, Width, Height)
    ResizeGadget(#GADGET_ProcedureBrowser_SwitchButtons, PanelWidth-5-Width, PanelHeight-Height-5, Width, Height)
    
    HideGadget(#GADGET_ProcedureBrowser_HideModuleNames, ProcedureBrowserSwitchButtons)
    HideGadget(#GADGET_ProcedureBrowser_HighlightProcedure, ProcedureBrowserSwitchButtons)
    HideGadget(#GADGET_ProcedureBrowser_ScrollProcedure, ProcedureBrowserSwitchButtons)
    HideGadget(#GADGET_ProcedureBrowser_EnableFolding, ProcedureBrowserSwitchButtons)
    HideGadget(#GADGET_ProcedureBrowser_FrontColor, Bool(Not ProcedureBrowserSwitchButtons))
    HideGadget(#GADGET_ProcedureBrowser_BackColor, Bool(Not ProcedureBrowserSwitchButtons))
    HideGadget(#GADGET_ProcedureBrowser_RestoreColor, Bool(Not ProcedureBrowserSwitchButtons))
    HideGadget(#GADGET_ProcedureBrowser_CopyClipboard, Bool(Not ProcedureBrowserSwitchButtons))
   
    CompilerSelect #PB_Compiler_OS
      CompilerCase #PB_OS_Windows
        ScrollBar = GetSystemMetrics_(#SM_CXVSCROLL) + 5
      CompilerCase #PB_OS_Linux
        ScrollBar = 25
      CompilerCase #PB_OS_MacOS
        ScrollBar = 25
      CompilerDefault
        CompilerError "Unknown OS."
    CompilerEndSelect

    SetGadgetItemAttribute(#GADGET_ProcedureBrowser, #PB_Ignore, #PB_ListIcon_ColumnWidth,
      GadgetWidth(#GADGET_ProcedureBrowser) - ScrollBar, #ProcedureBrowserColumnName)

  Else
    If *Entry\IsSeparateWindow
      ResizeGadget(#GADGET_ProcedureBrowser, 5, 5, PanelWidth-10, PanelHeight-10)
    Else
      ResizeGadget(#GADGET_ProcedureBrowser, 0, 0, PanelWidth, PanelHeight)
    EndIf
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
    
    ; Ignore the events for left/right and double clicks, it should be enough for change.
    If ProcedureMulticolor
      EventGadgetType = EventType()
      If EventValid And Not (EventGadgetType = #PB_EventType_Change)
        EventValid = #False
        SetGadgetState(#GADGET_ProcedureBrowser, -1)
      EndIf
    EndIf
    
    If EventValid
      index = GetGadgetState(#GADGET_ProcedureBrowser)
      If index <> -1
        SelectElement(ProcedureList(), index)
        ChangeActiveLine(ProcedureList()\Line, 0)
        
        ; Unfold the procedure block if it was folded
        If ProcedureMulticolor
          If ProcedureBrowserEnableFolding
            SendEditorMessage(#SCI_ENSUREVISIBLE, ProcedureList()\Line)
          EndIf
        Else
          SendEditorMessage(#SCI_ENSUREVISIBLE, ProcedureList()\Line)
        EndIf
        
        CompilerIf #CompileMac Or #CompileLinuxGtk
          ; remove selection so the we won't get more jumps to the procedure start! (OSX/Linux specific problem)
          ; Don't do it on QT as it causes another event causing the cursor to jump back to the first procedure
          SetGadgetState(#GADGET_ProcedureBrowser, -1)
        CompilerEndIf
        
        If ProcedureMulticolor
          ; Save the current index for coloring.
          ; Display the previously selected item again with user or standard colors and highlight the currently selected item.
          ProcedureBrowserHighlightTimerForce = #True
          ProcedureBrowser_Highlight(index, ProcedureList()\Type, ProcedureList()\Line)
          ProcedureBrowserCurrentIndex = index ; The index does not have to match the highlighted entry.
        EndIf
        
      EndIf
    EndIf

    If ProcedureMulticolor
      ; Process the events for the buttons for coloring, automatic selection and scrolling.
      Select EventGadgetID
          
        Case #GADGET_ProcedureBrowser_FilterInput
          If EventGadgetType = #PB_EventType_Change
            ProcedureBrowser_Filter(GetGadgetText(#GADGET_ProcedureBrowser_FilterInput))
          EndIf

        Case #GADGET_ProcedureBrowser_HideModuleNames
          ProcedureBrowserHideModuleName = GetGadgetState(EventGadgetID)
          UpdateProcedureList()
          ; Display a previously selected procedure selected again.
          If ProcedureBrowserPreviousIndex > -1
            SetGadgetItemColor(#GADGET_ProcedureBrowser, ProcedureBrowserPreviousIndex,
              #PB_Gadget_BackColor, ProcedureBrowserHighlightBackColor, #ProcedureBrowserColumnName)
            SetGadgetItemColor(#GADGET_ProcedureBrowser, ProcedureBrowserPreviousIndex,
              #PB_Gadget_FrontColor, ProcedureBrowserHighlightFrontColor, #ProcedureBrowserColumnName)
          EndIf
          ProcedureBrowserHighlightTimerForce = #True
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        Case #GADGET_ProcedureBrowser_HighlightProcedure
          ProcedureBrowserHighlightProcedure = GetGadgetState(EventGadgetID)
          If ProcedureBrowserHighlightProcedure
            ProcedureBrowserHighlightTimerForce = #True
          Else
            If ProcedureBrowserPreviousIndex > -1
              SelectElement(ProcedureList(), ProcedureBrowserPreviousIndex)
            Else
              ProcedureBrowser_ItemHighlight(-1, -1)
            EndIf
          EndIf
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        Case #GADGET_ProcedureBrowser_ScrollProcedure
          ProcedureBrowserScrollProcedure = GetGadgetState(EventGadgetID)
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        Case #GADGET_ProcedureBrowser_EnableFolding
          ProcedureBrowserEnableFolding = GetGadgetState(EventGadgetID)
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        Case #GADGET_ProcedureBrowser_FrontColor
          If ProcedureBrowserCurrentIndex > -1
            Color = ColorRequester(ProcedureBrowser_ItemColorGet(ProcedureBrowserCurrentIndex, #True))
            If Color <> -1
              SelectElement(ProcedureList(), ProcedureBrowserCurrentIndex)
              ProcedureBrowser_ItemColorSave(ProcedureList()\Name$, Color, -1)
              ProcedureBrowser_ItemColorUpdate()
            EndIf
          EndIf
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        Case #GADGET_ProcedureBrowser_BackColor
          If ProcedureBrowserCurrentIndex > -1
            Color = ColorRequester(ProcedureBrowser_ItemColorGet(ProcedureBrowserCurrentIndex, #False))
            If Color <> -1
              SelectElement(ProcedureList(), ProcedureBrowserCurrentIndex)
              ProcedureBrowser_ItemColorSave(ProcedureList()\Name$, -1, Color)
              ProcedureBrowser_ItemColorUpdate()
            EndIf
          EndIf
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        Case #GADGET_ProcedureBrowser_RestoreColor
          If ProcedureBrowserCurrentIndex > -1
            SelectElement(ProcedureList(), ProcedureBrowserCurrentIndex)
            ProcedureBrowser_ItemColorDelete(ProcedureList()\Name$)
            ProcedureBrowser_ItemColorUpdate()
          EndIf
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
          
        CompilerIf Not #CompileLinuxGtk ; Event is processed in ProcedureBrowser_CopyClipboardButtonEvent().
        Case #GADGET_ProcedureBrowser_CopyClipboard
          ProcedureBrowser_ItemsCopyClipbord(0)
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
        CompilerEndIf
          
        Case #GADGET_ProcedureBrowser_SwitchButtons
          ProcedureBrowserSwitchButtons = Bool(Not ProcedureBrowserSwitchButtons)
          HideGadget(#GADGET_ProcedureBrowser_HideModuleNames, ProcedureBrowserSwitchButtons)
          HideGadget(#GADGET_ProcedureBrowser_HighlightProcedure, ProcedureBrowserSwitchButtons)
          HideGadget(#GADGET_ProcedureBrowser_ScrollProcedure, ProcedureBrowserSwitchButtons)
          HideGadget(#GADGET_ProcedureBrowser_EnableFolding, ProcedureBrowserSwitchButtons)
          HideGadget(#GADGET_ProcedureBrowser_FrontColor, Bool(Not ProcedureBrowserSwitchButtons))
          HideGadget(#GADGET_ProcedureBrowser_BackColor, Bool(Not ProcedureBrowserSwitchButtons))
          HideGadget(#GADGET_ProcedureBrowser_RestoreColor, Bool(Not ProcedureBrowserSwitchButtons))
          HideGadget(#GADGET_ProcedureBrowser_CopyClipboard, Bool(Not ProcedureBrowserSwitchButtons))
          If Not *Entry\IsSeparateWindow
            SetActiveGadget(*ActiveSource\EditorGadget)
          EndIf
       
      EndSelect
    EndIf
    
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_PreferenceLoad(*Entry.ToolsPanelEntry)
  
  PreferenceGroup("ProcedureBrowser")
  ProcedureBrowserSort = ReadPreferenceLong  ("Sort", 0) ; 0=by line, nogroup, 1=by line, group, 2=byname, nogroup  3 = byname, group
  DisplayProtoType     = ReadPreferenceLong  ("Prototype", 0)
  ProcedureMulticolor  = ReadPreferenceLong  ("Multicolor", 1)
  
  ProcedureBrowserHideModuleName = ReadPreferenceLong("HideModuleName", 0)
  ProcedureBrowserHighlightProcedure = ReadPreferenceLong("HighlightProcedure", 1)
  ProcedureBrowserHighlightTimer = ReadPreferenceLong("HighlightTimer", 1000)
  ProcedureBrowserScrollProcedure = ReadPreferenceLong("ScrollProcedure", 1)
  ProcedureBrowserEnableFolding = ReadPreferenceLong("EnableFolding", 0)
  ProcedureBrowserSwitchButtons = ReadPreferenceLong("SwitchButtons", 0)
  
  PreferenceGroup("ProcedureBrowser_ItemColor")
  ClearList(ProcedureBrowserItemColorList())
  If ExaminePreferenceKeys()
    While NextPreferenceKey()
      With ProcedureBrowserItemColorList()
        Pos1 = FindString(PreferenceKeyValue(), ",")
        If Pos1
          Pos2 = FindString(PreferenceKeyValue(), ",", Pos1+1)
          If Pos2
            Text$ = Mid(PreferenceKeyValue(), Pos2+1)
            If Asc(Text$)
              AddElement(ProcedureBrowserItemColorList())
              \FrontColor = Val(Mid(PreferenceKeyValue(), 1, Pos1))
              \BackColor = Val(Mid(PreferenceKeyValue(), Pos1+1, Pos2-Pos1-1))
              \Text$ = Text$
            EndIf
          EndIf
        EndIf
      EndWith
    Wend
  EndIf
  
EndProcedure


Procedure ProcedureBrowser_PreferenceSave(*Entry.ToolsPanelEntry)
  
  PreferenceComment("")
  PreferenceGroup("ProcedureBrowser")
  WritePreferenceLong("Sort", ProcedureBrowserSort)
  WritePreferenceLong("Prototype", DisplayProtoType)
  WritePreferenceLong("Multicolor", ProcedureMulticolor)
  
  WritePreferenceLong("HideModuleName", ProcedureBrowserHideModuleName)
  WritePreferenceLong("HighlightProcedure", ProcedureBrowserHighlightProcedure)
  WritePreferenceLong("HighlightTimer", ProcedureBrowserHighlightTimer)
  WritePreferenceLong("ScrollProcedure", ProcedureBrowserScrollProcedure)
  WritePreferenceLong("EnableFolding", ProcedureBrowserEnableFolding)
  WritePreferenceLong("SwitchButtons", ProcedureBrowserSwitchButtons)
  
  PreferenceComment("")
  PreferenceGroup("ProcedureBrowser_ItemColor")
  With ProcedureBrowserItemColorList()
    Counter = 1
    ForEach ProcedureBrowserItemColorList()
      WritePreferenceString(Str(Counter),  "" + \FrontColor + "," + \BackColor + "," + \Text$)
      Counter + 1
    Next
  EndWith
  
EndProcedure


Procedure ProcedureBrowser_PreferenceStart(*Entry.ToolsPanelEntry)
  
  Backup_ProcedureBrowserSort = ProcedureBrowserSort
  Backup_DisplayProtoType = DisplayProtoType
  Backup_ProcedureMulticolor = ProcedureMulticolor
  
EndProcedure


Procedure ProcedureBrowser_PreferenceApply(*Entry.ToolsPanelEntry)
  
  ProcedureBrowserSort = Backup_ProcedureBrowserSort
  DisplayProtoType = Backup_DisplayProtoType
  ProcedureMulticolor = Backup_ProcedureMulticolor
  
EndProcedure


Procedure ProcedureBrowser_PreferenceCreate(*Entry.ToolsPanelEntry)
  
  Top = 10
  CheckBoxGadget(#GADGET_Preferences_ProcedureBrowserSort, 10, 10, 300, 25, Language("Preferences","ProcedureSort"))
  CheckBoxGadget(#GADGET_Preferences_ProcedureBrowserGroup, 10, 40, 300, 25, Language("Preferences","ProcedureGroup"))
  CheckBoxGadget(#GADGET_Preferences_ProcedureProtoType, 10, 70, 300, 25, Language("Preferences", "ProcedurePrototype"))
  CheckBoxGadget(#GADGET_Preferences_ProcedureMulticolor, 10, 100, 300, 25, Language("Preferences", "ProcedureMulticolor"))
  
  GetRequiredSize(#GADGET_Preferences_ProcedureBrowserSort, @Width, @Height)
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ProcedureBrowserGroup))
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ProcedureProtoType))
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ProcedureMulticolor))
  
  ResizeGadget(#GADGET_Preferences_ProcedureBrowserSort,  10, 10, Width, Height)
  ResizeGadget(#GADGET_Preferences_ProcedureBrowserGroup, 10, 15+Height, Width, Height)
  ResizeGadget(#GADGET_Preferences_ProcedureProtoType,    10, 20+Height*2, Width, Height)
  ResizeGadget(#GADGET_Preferences_ProcedureMulticolor, 10, 25+Height*3, Width, Height)
  
  If Backup_ProcedureBrowserSort >= 2
    SetGadgetState(#GADGET_Preferences_ProcedureBrowserSort, 1)
  EndIf
  SetGadgetState(#GADGET_Preferences_ProcedureBrowserGroup, Backup_ProcedureBrowserSort % 2)
  
  SetGadgetState(#GADGET_Preferences_ProcedureProtoType, Backup_DisplayProtoType)
  SetGadgetState(#GADGET_Preferences_ProcedureMulticolor, Backup_ProcedureMulticolor)
  
EndProcedure


Procedure ProcedureBrowser_PreferenceDestroy(*Entry.ToolsPanelEntry)
  
  Backup_ProcedureBrowserSort  = 2*GetGadgetState(#GADGET_Preferences_ProcedureBrowserSort)
  Backup_ProcedureBrowserSort  + GetGadgetState(#GADGET_PReferences_ProcedureBrowserGroup)
  Backup_DisplayProtoType = GetGadgetState(#GADGET_Preferences_ProcedureProtoType)
  Backup_ProcedureMulticolor = GetGadgetState(#GADGET_Preferences_ProcedureMulticolor)
  
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
    ElseIf GetGadgetState(#GADGET_Preferences_ProcedureMulticolor) <> ProcedureMulticolor
      ProcedureReturn 1
    EndIf
    
  Else
    If ProcedureBrowserSort <> Backup_ProcedureBrowserSort Or DisplayProtoType <> Backup_DisplayProtoType
      ProcedureReturn 1
    ElseIf ProcedureMulticolor <> Backup_ProcedureMulticolor
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
AvailablePanelTools()\PreferencesHeight    = 120
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "ProcedureBrowser"
AvailablePanelTools()\PanelTitle$          = "ProcedureBrowserShort"
AvailablePanelTools()\ToolName$            = "ProcedureBrowserLong"
AvailablePanelTools()\PanelTabOrder        = 1

