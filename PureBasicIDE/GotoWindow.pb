; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure OpenGotoWindow()
  
  If *ActiveSource <> *ProjectInfo
    GotoWindowDialog = OpenDialog(?Dialog_Goto, WindowID(#WINDOW_Main))
    EnsureWindowOnDesktop(#WINDOW_Goto)
    SetActiveGadget(#GADGET_Goto_Line)
  EndIf
  
EndProcedure


Procedure GotoWindowEvents(EventID)
  
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
          
        Case #GADGET_Goto_Ok
          Quit = 1 : ChangeLine = 1
          
        Case #GADGET_Goto_Cancel
          Quit = 1
          
      EndSelect
      
  EndSelect
  
  If ChangeLine
    If *ActiveSource <> *ProjectInfo
      ChangeActiveLine(Val(GetGadgetText(#GADGET_Goto_Line)), -5)
    EndIf
  EndIf
  
  If Quit
    GotoWindowDialog\Close()
  EndIf
  
EndProcedure

