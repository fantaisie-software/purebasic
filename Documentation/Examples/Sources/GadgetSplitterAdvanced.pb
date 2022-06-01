;
; ------------------------------------------------------------
;
;   PureBasic - Gadget example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#WindowWidth  = 640
#WindowHeight = 480

Procedure OnSizeWindow()
  ResizeGadget(5, #PB_Ignore, #PB_Ignore, WindowWidth(0), WindowHeight(0)-25) ; Our 'master' splitter gadget
EndProcedure


If OpenWindow(0, 0, 0, #WindowWidth, #WindowHeight, "PureBasic - Gadget Demonstration", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)

  TextGadget(7, 10, 5, 700, 15, "PureBasic splitter demonstation with Editor, ScrollArea, ExplorerTree and Web gadgets. Feel the power...")

  WebGadget(0, 10, 10, 300, 20, "http://www.google.com")
  
  EditorGadget(1, 115, 10, 100, 190)
  For k=1 To 10
    AddGadgetItem(1, k-1, "Line "+Str(k))
  Next

  ExplorerTreeGadget(3, 115, 10, 100, 190, GetHomeDirectory(), #PB_Explorer_AlwaysShowSelection|#PB_Explorer_FullRowSelect|#PB_Explorer_MultiSelect)

  ScrollAreaGadget(6, 0, 0, 400, 400, 1000, 1000, 1)
    ButtonGadget(20, 20, 20, 200, 200, "Scroll Area !")
  CloseGadgetList()
  
  SplitterGadget(2, 0, 0, #WindowWidth/2, #WindowHeight/2, 1, 0)
  SplitterGadget(4, 0, 0, #WindowWidth, #WindowHeight, 3, 2, #PB_Splitter_Vertical)
  SplitterGadget(5, 0, 25, #WindowWidth, #WindowHeight-25, 4, 6, #PB_Splitter_Vertical)
  
  SetGadgetState(5, 500)
  
  ; Use BindEvent() to have a realtime window sizing
  BindEvent(#PB_Event_SizeWindow, @OnSizeWindow())

  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Gadget
      
      Select EventGadget()

        Case 8
          SetGadgetState(5, 333)
          SetGadgetState(2, 333)
          SetGadgetState(11, 5)
          
        Case 20
          Debug "OK"
          
      EndSelect
      
    EndIf

  
  Until Event = #PB_Event_CloseWindow

EndIf

End