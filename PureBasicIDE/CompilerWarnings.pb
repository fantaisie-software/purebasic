; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure WarningWindowEvents(EventID)
  Protected Close = 0
  
  If EventID = #PB_Event_Menu And EventMenu() = #MENU_Warnings_Close
    Close = 1
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case #GADGET_Warnings_List
        If EventType() = #PB_EventType_LeftDoubleClick
          Index = GetGadgetState(#GADGET_Warnings_List)
          If Index <> -1 And SelectElement(Warnings(), Index)
            
            If Warnings()\File$ = "" ; it is an unsaved file!
              If *WarningWindowSource And Warnings()\Line <> -1
                ChangeCurrentElement(FileList(), *WarningWindowSource)
                ChangeActiveSourcecode()
                
                ChangeActiveLine(Warnings()\Line, -5)
                SetSelection(Warnings()\Line, 1, Warnings()\Line, -1)
              EndIf
            Else
              ; will simply switch, if the file is open
              If LoadSourceFile(Warnings()\File$) And Warnings()\Line <> -1
                ChangeActiveLine(Warnings()\Line, -5)
                SetSelection(Warnings()\Line, 1, Warnings()\Line, -1)
              EndIf
            EndIf
            
          EndIf
        EndIf
        
      Case #GADGET_Warnings_Close
        Close = 1
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    GetRequiredSize(#GADGET_Warnings_Close, @ButtonWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, 80)
    ResizeGadget(#GADGET_Warnings_List, 5, 5, WindowWidth(#WINDOW_Warnings)-10, WindowHeight(#WINDOW_Warnings)-25-ButtonHeight)
    ResizeGadget(#GADGET_Warnings_Close, (WindowWidth(#WINDOW_Warnings)-ButtonWidth)/2, WindowHeight(#WINDOW_Warnings)-10-ButtonHeight, ButtonWidth, ButtonHeight)
    
  ElseIf EventID = #PB_Event_CloseWindow
    Close = 1
    
  EndIf
  
  If Close
    *WarningWindowSource = 0
    
    WarningWindowPosition\x      = WindowX(#WINDOW_Warnings)
    WarningWindowPosition\y      = WindowY(#WINDOW_Warnings)
    WarningWindowPosition\Width  = WindowWidth(#WINDOW_Warnings)
    WarningWindowPosition\Height = WindowHeight(#WINDOW_Warnings)
    
    CloseWindow(#WINDOW_Warnings)
    ActivateMainWindow()
  EndIf
EndProcedure

Procedure UpdateWarningWindow()
  SetWindowTitle(#WINDOW_Warnings, Language("Misc","WarningsTitle"))
  SetGadgetItemText(#GADGET_Warnings_List, -1, Language("Compiler", "Warning"), 0)
  SetGadgetItemText(#GADGET_Warnings_List, -1, Language("Misc","Line"), 1)
  SetGadgetItemText(#GADGET_Warnings_List, -1, Language("Misc","File"), 2)
  SetGadgetText(#GADGET_Warnings_Close, Language("Misc", "Close"))
  
  WarningWindowEvents(#PB_Event_SizeWindow)
EndProcedure

Procedure DisplayCompilerWarnings()
  If IsWindow(#WINDOW_Warnings)
    WarningWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  ; This is to know which file the warnings belong to if the file is not saved yet
  ; (in this case there is no filename to go by)
  ; This is also used by RemoveSource() to know when to automatically close this window.
  ;
  *WarningWindowSource = *ActiveSource
  
  Flags = #PB_Window_SystemMenu | #PB_Window_SizeGadget
  
  If WarningWindowPosition\x = -1 Or WarningWindowPosition\y = -1
    Flags | #PB_Window_WindowCentered
  EndIf
  
  ColumnWidth = WarningWindowPosition\Width-30-180
  If ColumnWidth < 180
    ColumnWidth = 180
  EndIf
  
  If OpenWindow(#WINDOW_Warnings, WarningWindowPosition\x, WarningWindowPosition\y, WarningWindowPosition\Width, WarningWindowPosition\Height, Language("Misc","WarningsTitle"), Flags, WindowID(#WINDOW_Main))
    ListIconGadget(#GADGET_Warnings_List, 0, 0, ColumnWidth, 0, Language("Compiler", "Warning"), ColumnWidth, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
    AddGadgetColumn(#GADGET_Warnings_List, 1, Language("Misc","Line"), 40)
    AddGadgetColumn(#GADGET_Warnings_List, 2, Language("Misc","File"), 140)
    
    ButtonGadget(#GADGET_Warnings_Close, 0, 0, 0, 0, Language("Misc", "Close"), #PB_Button_Default)
    
    AddKeyboardShortcut(#WINDOW_Warnings, #PB_Shortcut_Return, #MENU_Warnings_Close)
    AddKeyboardShortcut(#WINDOW_Warnings, #PB_Shortcut_Escape, #MENU_Warnings_Close)
    
    ForEach Warnings()
      Text$ = Warnings()\Message$+Chr(10)
      If Warnings()\Line <> -1
        Text$ + Str(Warnings()\Line)
      EndIf
      Text$ + Chr(10) + Warnings()\RelativeFile$
      
      AddGadgetItem(#GADGET_Warnings_List, -1, Text$)
    Next Warnings()
    
    EnsureWindowOnDesktop(#WINDOW_Warnings)
    HideWindow(#WINDOW_Warnings, 0)
    WarningWindowEvents(#PB_Event_SizeWindow)
    
    SetActiveWindow(#WINDOW_Warnings)
    SetActiveGadget(#GADGET_Warnings_Close)
  EndIf
  
EndProcedure



Procedure HideCompilerWarnings()
  If IsWindow(#WINDOW_Warnings)
    WarningWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  ClearList(Warnings())
EndProcedure
