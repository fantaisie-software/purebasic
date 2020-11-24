;
; ------------------------------------------------------------
;
;   PureBasic - ToolBar example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

UsePNGImageDecoder()

If OpenWindow(0, 100, 200, 195, 260, "ToolBar example", #PB_Window_SystemMenu | #PB_Window_SizeGadget)

  If CreateToolBar(0, WindowID(0))
    ToolBarImageButton(0, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/New.png"))
    ToolBarImageButton(1, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Open.png"))
    ToolBarImageButton(2, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Save.png"))
    
    ToolBarSeparator()

    ToolBarImageButton(3, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Cut.png"))
    ToolBarToolTip(0, 3, "Cut")
    
    ToolBarImageButton(4, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Copy.png"))
    ToolBarToolTip(0, 4, "Copy")
    
    ToolBarImageButton(5, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Paste.png"))
    ToolBarToolTip(0, 5, "Paste")
    
    ToolBarSeparator()

    ToolBarImageButton(6, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Find.png"))
    ToolBarToolTip(0, 6, "Find a document")
  EndIf


  If CreateMenu(0, WindowID(0))
    MenuTitle("Project")
      MenuItem(0, "New")
      MenuItem(1, "Open")
      MenuItem(2, "Save")
  EndIf
  
  DisableToolBarButton(0, 2, 1) ; Disable the button '2'
  
  ;
  ; The event loop. A ToolBar event is like a Menu event (as tools are shortcut for menu the most
  ; of the time). This is handy, as if the ToolBar buttons and the MenuItem have the same ID, then
  ; the same operation can be done on both action without any adds..
  ;
  
  Repeat
    Event = WaitWindowEvent()

    Select Event
    
      Case #PB_Event_Menu
        MessageRequester("Information", "ToolBar or Menu ID: "+Str(EventMenu()), 0)
      
      Case #PB_Event_CloseWindow  ; If the user has pressed on the close button
        Quit = 1
        
    EndSelect

  Until Quit = 1
  
EndIf

End   ; All resources are automatically freed
   