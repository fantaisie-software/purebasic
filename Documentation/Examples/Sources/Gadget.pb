﻿;
; ------------------------------------------------------------
;
;   PureBasic - Gadget example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#WindowWidth  = 390
#WindowHeight = 350

If OpenWindow(0, 100, 200, #WindowWidth, #WindowHeight, "PureBasic - Gadget Demonstration", #PB_Window_MinimizeGadget)
    
  Top = 10
  GadgetHeight = 24

  FrameGadget(#PB_Any, 10, Top, 370, 290, "Player...") : Top+20

  StringGadget(0,  20, Top, 200, GadgetHeight, "")
  ButtonGadget(1, 223, Top,  72, GadgetHeight, "Play")
  ButtonGadget(2, 295, Top,  72, GadgetHeight, "Stop")  : Top+35
  DisableGadget(2,1)
  
  GadgetToolTip(1,"Play the current song")
  
  PanelGadget(3, 20, Top, #WindowWidth-50, #WindowHeight-Top-60)
    AddGadgetItem(3, 0, "MP3 PlayList")
      ListViewGadget(4, 6, 10, 230, 148)

      For k=0 To 30
        AddGadgetItem(4, -1, "Music Song n° "+Str(k))
      Next

      ButtonGadget(5,  250, 10, 80, GadgetHeight, "Add")
      ButtonGadget(6,  250, 38, 80, GadgetHeight, "Remove")
      ButtonGadget(7,  250, 66, 80, GadgetHeight, "Select")
      GadgetToolTip(7, "Select the current song")
      
      TrackBarGadget(17, 10, 168, 310, 25, 0, 100)

    AddGadgetItem(3, 1, "Options")
      Top = 10
      CheckBoxGadget(10, 10, Top, 250, GadgetHeight, "Enable low-pass filter") : Top+30
      CheckBoxGadget(11, 10, Top, 250, GadgetHeight, "Enable visual plug-in")  : Top+30
      ComboBoxGadget(12, 10, Top, 250, 21) : Top+30
        AddGadgetItem(12, -1, "FireWorks")
        AddGadgetItem(12, -1, "OpenGL spectrum")
        AddGadgetItem(12, -1, "Bump bass")
      SetGadgetState(12,0)
      DisableGadget(12,1)
      
      OptionGadget(13, 10, Top, 80, GadgetHeight, "640*480") : Top+20
      OptionGadget(14, 10, Top, 80, GadgetHeight, "800*600") : Top+20
      OptionGadget(15, 10, Top, 80, GadgetHeight, "1024*768")
      SetGadgetState(13, 1)
      
      ButtonGadget(16, 150, Top, 80, GadgetHeight, "Info")
  CloseGadgetList()

  TextGadget  (9, 10, #WindowHeight-30, 250, 24, "PureBasic - Gadget demonstration")
  ButtonGadget(8, #WindowWidth-100, #WindowHeight-36, 80, 24, "Quit")

  SetGadgetState(3, 0)

  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Gadget

      Select EventGadget()
        Case 1 ; Play
          DisableGadget(2,0)  ; Enable the 'Stop' gadget
          DisableGadget(1,1)  ; Disable the 'Play' Gadget
      
        Case 2 ; Stop
          DisableGadget(1,0)  ; Enable the 'Play' gadget
          DisableGadget(2,1)  ; Disable the 'Stop' Gadget
        
        Case 4
          If EventType() = 2
            SetGadgetText(0, GetGadgetText(4)) ; Get the current item from the ListView..
          EndIf

        Case 5 ; Add
          AddGadgetItem(4, -1, "New Item Added...")

        Case 6 ; Remove
          RemoveGadgetItem(4, GetGadgetState(4)) ; Remove the current element of the ListView

        Case 7 ; Select
          SetGadgetText(0, GetGadgetText(4)) ; Get the current item from the ListView..
  
        Case 8 ; Quit...
          Event = #PB_Event_CloseWindow

        Case 11 ; Enable PlugIn..
          DisableGadget(12, 1-GetGadgetState(11))
          
        Case 16 ;
          If GetGadgetState(13) : Result$ = GetGadgetText(13) : EndIf
          If GetGadgetState(14) : Result$ = GetGadgetText(14) : EndIf
          If GetGadgetState(15) : Result$ = GetGadgetText(15) : EndIf
         
          MessageRequester("Info", "Selected screen mode: "+Result$, 0)
        
        Case 17
          SetGadgetText(0, Str(GetGadgetState(17)))
          
      EndSelect

    EndIf

  Until Event = #PB_Event_CloseWindow

EndIf

End