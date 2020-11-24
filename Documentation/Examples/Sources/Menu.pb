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
; We just have to open a window and see when an event happen on the menu
;

If OpenWindow(0, 100, 150, 195, 260, "PureBasic - Menu")

  ;
  ; Create the menu. The indent is very important here for a good lisibility
  ;

  If CreateMenu(0, WindowID(0))
    MenuTitle("File")
      MenuItem( 1, "&Load...")
      MenuItem( 2, "Save")
      MenuItem( 3, "Save As...")
      MenuBar()
      OpenSubMenu("Recents")
        MenuItem( 5, "Pure.png")
        MenuItem( 6, "Basic.jpg")
        OpenSubMenu("Even more !")
          MenuItem( 12, "Yeah")
        CloseSubMenu()
        MenuItem( 13, "Rocks.tga")
      CloseSubMenu()
      MenuBar()
      MenuItem( 7, "&Quit")

    MenuTitle("Edition")
      MenuItem( 8, "Cut")
      MenuItem( 9, "Copy")
      MenuItem(10, "Paste")
      
    MenuTitle("?")
      MenuItem(11, "About")
      MenuItem(14, "Check/Uncheck Me")

  EndIf
  
  DisableMenuItem(0, 3, 1)
  DisableMenuItem(0, 13, 1)
  
  ;
  ; This is the 'event loop'. All the user actions are processed here.
  ; It's very easy to understand: when an action occurs, the Event
  ; isn't 0 and we just have to see what have happened...
  ;
  
  Repeat

    Select WaitWindowEvent()

      Case #PB_Event_Menu

        Select EventMenu()  ; To see which menu has been selected

          Case 11 ; About
            MessageRequester("About", "Cool Menu example", 0)

          Case 14 ; Check/Uncheck Me
          If GetMenuItemState(0,14) = 1   ; Checked
            SetMenuItemState(0,14,0)      ; So uncheck Me
          Else                            ; Else
            SetMenuItemState(0,14,1)      ; Check Me
          EndIf
 
          Default
            MessageRequester("Info", "MenuItem: "+Str(EventMenu()), 0)

        EndSelect

      Case #PB_Event_CloseWindow
        Quit = 1

    EndSelect

  Until Quit = 1

EndIf

End