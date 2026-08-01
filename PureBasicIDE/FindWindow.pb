; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure OpenFindWindow(Replace = #False)
  Protected FindFromSelection
  
  If IsWindow(#WINDOW_Find) = 0
    
    If *ActiveSource <> *ProjectInfo
      
      FindWindowDialog = OpenDialog(?Dialog_Find, WindowID(#WINDOW_Main), @FindWindowPosition)
      If FindWindowDialog
        EnsureWindowOnDesktop(#WINDOW_Find)
        
        For i = 1 To FindHistorySize
          If FindSearchHistory(i) <> ""
            AddGadgetItem(#GADGET_Find_FindWord, -1, FindSearchHistory(i))
          EndIf
          
          If FindReplaceHistory(i) <> ""
            AddGadgetItem(#GADGET_Find_ReplaceWord, -1, FindReplaceHistory(i))
          EndIf
        Next i
        
        SetGadgetState(#GADGET_Find_Case,         FindCaseSensitive)
        SetGadgetState(#GADGET_Find_WholeWord,    FindWholeWord)
        SetGadgetState(#GADGET_Find_NoComments,   FindNoComments)
        SetGadgetState(#GADGET_Find_NoStrings,    FindNoStrings)
        SetGadgetState(#GADGET_Find_SelectionOnly,FindSelectionOnly)
        SetGadgetState(#GADGET_Find_AutoWrap,     FindAutoWrap)
        
        If Replace
          SetGadgetState(#GADGET_Find_DoReplace,  1)
          DisableGadget(#GADGET_Find_ReplaceWord, 0)
          DisableGadget(#GADGET_Find_Replace, 0)
          DisableGadget( #GADGET_Find_ReplaceAll, 0)
        Else
          SetGadgetState(#GADGET_Find_DoReplace,  0) ; doreplace should always be disabled when opening this window.
          DisableGadget(#GADGET_Find_ReplaceWord, 1)
          DisableGadget(#GADGET_Find_Replace, 1)
          DisableGadget( #GADGET_Find_ReplaceAll, 1)
        EndIf
        
        SetGadgetState(#GADGET_Find_FindWord, 0) ; select the last entry
        
        GetSelection(@LineStart, @RowStart, @LineEnd, @RowEnd)
        
        If LineStart = LineEnd
          If RowStart = RowEnd
            SetGadgetState(#GADGET_Find_SelectionOnly, 0)
            DisableGadget(#GADGET_Find_SelectionOnly, 1)
            
          Else
            ; display the default selection in the box
            Line$ = Mid(GetLine(LineStart-1), RowStart, RowEnd-RowStart)
            SetGadgetText(#GADGET_Find_FindWord, Line$)
            FindFromSelection = #True
          EndIf
        EndIf
      EndIf
      
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_Find)
  EndIf
  
  ; If replacement is requested from a selection, use that selection as the search word and select the last entry replacement word
  If GetGadgetState(#GADGET_Find_DoReplace)  And FindFromSelection
    SetGadgetState(#GADGET_Find_ReplaceWord, 0) ; select the last entry
    SelectComboBoxText(#GADGET_Find_ReplaceWord)
    SetActiveGadget(#GADGET_Find_ReplaceWord)
  Else
    SelectComboBoxText(#GADGET_Find_FindWord)
    SetActiveGadget(#GADGET_Find_FindWord)
  EndIf
  
EndProcedure

Procedure UpdateFindWindow()
  
  FindWindowDialog\LanguageUpdate()
  
  While FindHistorySize < CountGadgetItems(#GADGET_Find_FindWord)
    RemoveGadgetItem(#GADGET_Find_FindWord, CountGadgetItems(#GADGET_Find_FindWord)-1)
  Wend
  
  While FindHistorySize < CountGadgetItems(#GADGET_Find_ReplaceWord)
    RemoveGadgetItem(#GADGET_Find_ReplaceWord, CountGadgetItems(#GADGET_Find_ReplaceWord)-1)
  Wend
  
  FindWindowDialog\GuiUpdate()
  
EndProcedure



Procedure FindWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
    Case #PB_Event_CloseWindow
      Quit = 1
      
    Case #PB_Event_Gadget
      Select GadgetID
          
        Case #GADGET_Find_DoReplace
          If GetGadgetState(#GADGET_Find_DoReplace)
            DisableGadget(#GADGET_Find_ReplaceWord, 0)
            DisableGadget(#GADGET_Find_Replace, 0)
            DisableGadget( #GADGET_Find_ReplaceAll, 0)
          Else
            DisableGadget(#GADGET_Find_ReplaceWord, 1)
            DisableGadget(#GADGET_Find_Replace, 1)
            DisableGadget( #GADGET_Find_ReplaceAll, 1)
          EndIf
          
        Case #GADGET_Find_FindNext,
             #GADGET_Find_FindPrevious
          If *ActiveSource <> *ProjectInfo
            FindCaseSensitive = GetGadgetState(#GADGET_Find_Case)
            FindWholeWord     = GetGadgetState(#GADGET_Find_WholeWord)
            FindNoComments    = GetGadgetState(#GADGET_Find_NoComments)
            FindNoStrings     = GetGadgetState(#GADGET_Find_NoStrings)
            FindSelectionOnly = GetGadgetState(#GADGET_Find_SelectionOnly)
            FindAutoWrap      = GetGadgetState(#GADGET_Find_AutoWrap)
            FindDoReplace     = GetGadgetState(#GADGET_Find_DoReplace)
            FindSearchString$ = GetGadgetText(#Gadget_Find_FindWord)
            FindReplaceString$= SearchString$
            UpdateFindComboBox(#Gadget_Find_FindWord)
            UpdateFindComboBox(#GADGET_Find_ReplaceWord)
            
            If GadgetID = #GADGET_Find_FindPrevious
              Reverse = #True
            EndIf
            
            If FindText(1, Reverse) And FindDoReplace = 0
              Quit = 1
            Else
              SetWindowForeground(#WINDOW_Find)
            EndIf
          EndIf
          
        Case #GADGET_Find_Replace
          If *ActiveSource <> *ProjectInfo
            *Debugger.DebuggerData = IsDebuggedFile(*ActiveSource)
            If *Debugger And *Debugger\CanDestroy = 0 And #SpiderBasic = 0 ; no error if the code finished executing. In SpiderBasic the file is never locked.
              MessageRequester(#ProductName$, Language("Debugger","EditError"), #FLAG_INFO)
            Else
              FindCaseSensitive = GetGadgetState(#GADGET_Find_Case)
              FindWholeWord     = GetGadgetState(#GADGET_Find_WholeWord)
              FindNoComments    = GetGadgetState(#GADGET_Find_NoComments)
              FindNoStrings     = GetGadgetState(#GADGET_Find_NoStrings)
              FindSelectionOnly = GetGadgetState(#GADGET_Find_SelectionOnly)
              FindAutoWrap      = GetGadgetState(#GADGET_Find_AutoWrap)
              FindDoReplace     = GetGadgetState(#GADGET_Find_DoReplace)
              FindSearchString$ = GetGadgetText(#Gadget_Find_FindWord)
              FindReplaceString$= GetGadgetText(#GADGET_Find_ReplaceWord)
              UpdateFindComboBox(#Gadget_Find_FindWord)
              UpdateFindComboBox(#GADGET_Find_ReplaceWord)
              FindText(2)
            EndIf
            SetWindowForeground(#WINDOW_Find)
          EndIf
          
        Case #GADGET_Find_ReplaceAll
          If *ActiveSource <> *ProjectInfo
            *Debugger.DebuggerData = IsDebuggedFile(*ActiveSource)
            If *Debugger And *Debugger\CanDestroy = 0 And #SpiderBasic = 0 ; no error if the code finished executing. In SpiderBasic the file is never locked.
              MessageRequester(#ProductName$, Language("Debugger","EditError"), #FLAG_INFO)
            Else
              FindCaseSensitive = GetGadgetState(#GADGET_Find_Case)
              FindWholeWord     = GetGadgetState(#GADGET_Find_WholeWord)
              FindNoComments    = GetGadgetState(#GADGET_Find_NoComments)
              FindNoStrings     = GetGadgetState(#GADGET_Find_NoStrings)
              FindSelectionOnly = GetGadgetState(#GADGET_Find_SelectionOnly)
              FindAutoWrap      = GetGadgetState(#GADGET_Find_AutoWrap)
              FindDoReplace     = GetGadgetState(#GADGET_Find_DoReplace)
              FindSearchString$ = GetGadgetText(#Gadget_Find_FindWord)
              FindReplaceString$= GetGadgetText(#GADGET_Find_ReplaceWord)
              UpdateFindComboBox(#Gadget_Find_FindWord)
              UpdateFindComboBox(#GADGET_Find_ReplaceWord)
              SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
              FindText(3)
              SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
            EndIf
            SetWindowForeground(#WINDOW_Find)
          EndIf
          
        Case #GADGET_Find_Close
          Quit = 1
          
      EndSelect
      
  EndSelect
  
  If Quit
    ; get checkbox choices
    FindCaseSensitive = GetGadgetState(#GADGET_Find_Case)
    FindWholeWord     = GetGadgetState(#GADGET_Find_WholeWord)
    FindNoComments    = GetGadgetState(#GADGET_Find_NoComments)
    FindNoStrings     = GetGadgetState(#GADGET_Find_NoStrings)
    FindSelectionOnly = GetGadgetState(#GADGET_Find_SelectionOnly)
    FindAutoWrap      = GetGadgetState(#GADGET_Find_AutoWrap)
    FindDoReplace     = GetGadgetState(#GADGET_Find_DoReplace)
    
    ; save search strings
    For i = 1 To FindHistorySize
      If CountGadgetItems(#GADGET_Find_FindWord) >= i
        FindSearchHistory(i) = GetGadgetItemText(#GADGET_Find_FindWord, i-1, 0)
      Else
        FindSearchHistory(i) = ""
      EndIf
      
      If CountGadgetItems(#GADGET_Find_ReplaceWord) >= i
        FindReplaceHistory(i) = GetGadgetItemText(#GADGET_Find_ReplaceWord, i-1, 0)
      Else
        FindReplaceHistory(i) = ""
      EndIf
    Next i
    
    If MemorizeWindow
      FindWindowDialog\Close(@FindWindowPosition.DialogPosition)
    Else
      FindWindowDialog\Close()
    EndIf
  EndIf
  
EndProcedure