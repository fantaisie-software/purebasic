;
; ------------------------------------------------------------
;
;   PureBasic - MiniBrowser
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Procedure ResizeWebWindow()
  ResizeGadget(10, #PB_Ignore, #PB_Ignore, WindowWidth(0), WindowHeight(0)-52)
  ResizeGadget(4, #PB_Ignore, #PB_Ignore, WindowWidth(0)-185, #PB_Ignore)
  ResizeGadget(5, WindowWidth(0)-25, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  ResizeGadget(6, #PB_Ignore, #PB_Ignore, WindowWidth(0), #PB_Ignore)
EndProcedure


If OpenWindow(0, 100, 200, 500, 300, "PureBasic MiniBrowser v1.0", #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget)

  CreateStatusBar(0, WindowID(0))
    AddStatusBarField(#PB_Ignore)
    StatusBarText(0, 0, "Welcome to the world's smallest Browser !", 0)
      
  ButtonGadget(1,   0, 3, 50, 25, "Back")
  ButtonGadget(2,  50, 3, 50, 25, "Next")
  ButtonGadget(3, 100, 3, 50, 25, "Stop")

  StringGadget(4, 155, 5, 0, 20, "http://www.google.com")
  
  ButtonGadget(5, 0, 3, 25, 25, "Go")
  
  FrameGadget(6, 0, 30, 0, 2, "", 2) ; Nice little separator

  If WebGadget(10, 0, 31, 0, 0, "http://www.google.com") = 0
    
    CompilerIf #PB_Compiler_OS <> #PB_OS_Windows
      ; Linux and OX uses Webkit
      MessageRequester("Error", "Webkit library not found", 0)
    CompilerEndIf
    
    End ; Quit
  EndIf
  
  AddKeyboardShortcut(0, #PB_Shortcut_Return, 0)
  
  ; Use bindevent() to have a realtime window resize
  ;
  BindEvent(#PB_Event_SizeWindow, @ResizeWebWindow())
  ResizeWebWindow() ; Adjust the gadget to the current window size
    
  Repeat
    Event = WaitWindowEvent()
    
    Select Event
      Case #PB_Event_Gadget
      
        Select EventGadget()
          Case 1
            SetGadgetState(10, #PB_Web_Back)
          
          Case 2
            SetGadgetState(10, #PB_Web_Forward)
          
          Case 3
            SetGadgetState(10, #PB_Web_Stop)
          
          Case 5
            SetGadgetText(10, GetGadgetText(4))
            
        EndSelect
      
      Case #PB_Event_Menu ; We only have one shortcut
        SetGadgetText(10, GetGadgetText(4))
     
    EndSelect
      
  Until Event = #PB_Event_CloseWindow
   
EndIf
