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
  ResizeGadget(5, #PB_Ignore, #PB_Ignore, WindowWidth(0)-10, WindowHeight(0)-45) ; Our 'master' splitter gadget
EndProcedure


If OpenWindow(0, 100, 120, #WindowWidth, #WindowHeight, "PureBasic - Gadget Demonstration", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)

  HyperLinkGadget(7, 10, 5, 180, 30, "This is a green hyperlink", RGB(0,255,0))
  HyperLinkGadget(8, 200, 5, 120, 30, "Click me !", RGB(255,0,0))
  
  SetGadgetFont(8, LoadFont(0, "courier", 10, #PB_Font_Underline | #PB_Font_Bold))
  
  TextGadget( 9, 350, 5, 50, 30, "Pos:")
  TextGadget(10, 400, 5, 50, 30, "-")
  TextGadget(11, 450, 5, 50, 30, "-")
  TextGadget(12, 500, 5, 50, 30, "-")
  
  ListIconGadget(0, 115, 10, 100, 190, "Test", 100)
  For k=0 To 10
    AddGadgetItem(0, -1, "Element "+Str(k))
  Next
  
  ExplorerListGadget(1, 115, 10, 100, 190, GetHomeDirectory(), #PB_Explorer_AlwaysShowSelection|#PB_Explorer_FullRowSelect|#PB_Explorer_MultiSelect)

  TreeGadget(3, 115, 10, 100, 190)
  
  For k=0 To 10
    AddGadgetItem(3, -1, "Hello "+Str(k))
  Next

  PanelGadget(6, 0, 0, 400, 400)
    For k=1 To 5
      AddGadgetItem(6, -1, "Line "+Str(k))
      ButtonGadget(12+k, 10, 10, 100, 20, "Test"+Str(k))
    Next
  CloseGadgetList()

  SplitterGadget(2, 0, 0, #WindowWidth/2, #WindowHeight/2, 1, 0)
  SplitterGadget(4, 0, 0, #WindowWidth, #WindowHeight, 3, 2, #PB_Splitter_Vertical | #PB_Splitter_Separator)
  SplitterGadget(5, 5, 40, #WindowWidth-10, #WindowHeight-45, 4, 6, #PB_Splitter_Vertical)
  
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
          SetGadgetText(12,Str(GetGadgetState(5)))
          
          Case 2
          SetGadgetText(10,Str(GetGadgetState(2)))
          
        Case 4
          SetGadgetText(11,Str(GetGadgetState(4)))
          
        Case 5
          SetGadgetText(12,Str(GetGadgetState(5)))
          
      EndSelect
    EndIf
  
  Until Event = #PB_Event_CloseWindow
EndIf

End
