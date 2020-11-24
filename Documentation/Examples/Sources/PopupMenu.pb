;
; ------------------------------------------------------------
;
;   PureBasic - Menu example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;
; Create the popup menu. The indent is important here for a good lisibility
;

If CreatePopupMenu(0)
  MenuItem(1, "Cut")
  MenuItem(2, "Copy")
  MenuItem(3, "Paste")
  MenuBar()
  OpenSubMenu("Options")
    MenuItem(4, "Window...")
    MenuItem(5, "Gadget...")
  CloseSubMenu()
  MenuBar()
  MenuItem( 6, "Quit")
EndIf

;
; We just have to open a window and see when an event happen on the menu
;
If OpenWindow(0, 100, 100, 300, 260, "PureBasic - PopupMenu Example")

  ListIconGadget(0, 10, 10, 280, 240, "Tools", 200)
    AddGadgetItem(0, -1, "Hammer")
    AddGadgetItem(0, -1, "Screwdriver")

  Repeat

    Select WaitWindowEvent()
        
      Case #PB_Event_Gadget
        If EventGadget() = 0 And EventType() = #PB_EventType_RightClick
          DisplayPopupMenu(0, WindowID(0))
        EndIf
          
      Case #PB_Event_Menu
      
        Select EventMenu()  ; To see which menu has been selected

          Case 1 ; Cut
            MessageRequester("PureBasic", "Cut", 0)

          Case 2 ; Copy
            MessageRequester("PureBasic", "Copy", 0)

          Case 3 ; Paste
            MessageRequester("PureBasic", "Paste", 0)

          Case 6 ; Quit
            Quit = 1

        EndSelect
        
      Case #PB_Event_CloseWindow
        Quit = 1

    EndSelect

  Until Quit = 1

EndIf

End