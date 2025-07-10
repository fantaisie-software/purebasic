; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
Procedure InitSplitterWin()
  
  DisableWindow(#WINDOW_Main,1)
  OpenWindow(#Form_SplitterWin, 0, 0, 412, 142, Language("Form","CreateSplitterTitle"), #PB_Window_SystemMenu | #PB_Window_WindowCentered,WindowID(#WINDOW_Main))
  
  Text_0 = TextGadget(#PB_Any, 20, 20, 110, 22, Language("Form","FirstGadget"), #PB_Text_Right)
  Text_0_1 = TextGadget(#PB_Any, 20, 52, 110, 22, Language("Form","SecondGadget"), #PB_Text_Right)
  ComboBoxGadget(#Form_Splitter_1st, 140, 20, 250, 22)
  ComboBoxGadget(#Form_Splitter_2nd, 140, 52, 250, 22)
  ButtonGadget(#Form_Splitter_OK, 200, 100, 120, 25, Language("Form","StartDrawing"))
  ButtonGadget(#Form_Splitter_Cancel, 90, 100, 100, 25, Language("Form","Cancel"))
  
  i = 0
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\splitter = 0
      If FormWindows()\FormGadgets()\pbany
        ID$ = FormWindows()\FormGadgets()\variable
      Else
        ID$ = "#" + FormWindows()\FormGadgets()\variable
      EndIf
      AddGadgetItem(#Form_Splitter_1st,i, ID$)
      SetGadgetItemData(#Form_Splitter_1st,i,@FormWindows()\FormGadgets())
      AddGadgetItem(#Form_Splitter_2nd,i, ID$)
      SetGadgetItemData(#Form_Splitter_2nd,i,@FormWindows()\FormGadgets())
      i + 1
    EndIf
  Next
  
EndProcedure
Procedure CloseSplitterWin()
  CloseWindow(#Form_SplitterWin)
  DisableWindow(#WINDOW_Main,0)
EndProcedure

Procedure EventSplitterWin(gadget, event_type)
  Select gadget
    Case #Form_Splitter_OK
      If GetGadgetState(#Form_Splitter_1st) > -1
        d_gadget1 = GetGadgetItemData(#Form_Splitter_1st,GetGadgetState(#Form_Splitter_1st))
      Else
        d_gadget1 = 0
      EndIf
      
      If GetGadgetState(#Form_Splitter_2nd) > -1
        d_gadget2 = GetGadgetItemData(#Form_Splitter_2nd,GetGadgetState(#Form_Splitter_2nd))
      Else
        d_gadget2 = 0
      EndIf
      
      If Not d_gadget1 Or Not d_gadget2 Or d_gadget1 = d_gadget2
        MessageRequester(#ProductName$, Language("Form","SelectError"))
      Else
        PushListPosition(FormWindows()\FormGadgets())
        ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget1)
        d_parent1 = FormWindows()\FormGadgets()\parent
        d_parentitem1 = FormWindows()\FormGadgets()\parent_item
        ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget2)
        d_parent2 = FormWindows()\FormGadgets()\parent
        d_parentitem2 = FormWindows()\FormGadgets()\parent_item
        PopListPosition(FormWindows()\FormGadgets())
        If d_parent1 = d_parent2 And d_parentitem1 = d_parentitem2
          CloseSplitterWin()
        Else
          MessageRequester(#ProductName$, Language("Form","GadgetListError"))
        EndIf
      EndIf
    Case #Form_Splitter_Cancel
      CloseSplitterWin()
      form_gadget_type = #Form_Type_Button
      ;       UpdateToggleButton(#Ribbon_Insert_Button)
      
      num = CountGadgetItems(gadgetlist) - 1
      For i = 0 To num
        If GetGadgetItemData(gadgetlist,i) = #Form_Type_Button
          SetGadgetState(gadgetlist,i)
          Break
        EndIf
      Next
      
  EndSelect
EndProcedure
