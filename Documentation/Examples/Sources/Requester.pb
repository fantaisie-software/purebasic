;
; ------------------------------------------------------------
;
;   PureBasic - Requester example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If OpenWindow(0, 100, 200, 300, 300, "PureBasic - Requesters example")

  If CreateMenu(0, WindowID(0))
    MenuTitle("Test")
      MenuItem(0, "Open")
      MenuItem(1, "Save")
      MenuItem(6, "Path")
      MenuBar()
      MenuItem(2, "Choose a color")
      MenuItem(3, "Choose a font")
      MenuBar()
      MenuItem(4, "Simple message")
      MenuBar()
      MenuItem(5, "Quit")
  EndIf
  
  Repeat
    Event = WaitWindowEvent()

    Select Event
    
      Case #PB_Event_Menu  ; A Menu item has been selected
      
        Select EventMenu()
        
          Case 0  ; OpenFileRequester
            File$ = OpenFileRequester("PureBasic - Open", "Pure.txt", "Text (*.txt)|*.txt;*.bat|(PureBasic (*.pb)|*.pb", 0)
            If File$+File$
              MessageRequester("Information", "Selected File: "+File$, 0);
            EndIf
          
          Case 1  ; SaveFileRequester
            File$ = SaveFileRequester("PureBasic - Save", "Basic.pb", "Text (*.txt)|*.txt|(PureBasic (*.pb)|*.pb", 1)
            If File$
              MessageRequester("Information", "Selected File: "+File$, 0);
            EndIf
          
          Case 2  ; ColorRequester
            Colour = ColorRequester()
            If Colour > -1
              MessageRequester("Info", "Colour choosen: Red: "+Str(Red(Colour))+", Green: "+Str(Green(Colour))+", Blue: "+Str(Blue(Colour)), 0);
            EndIf
          
          Case 3  ; FontRequester
            If FontRequester("Courier", -13, 0)
              MessageRequester("Info", "Selected font: "+SelectedFontName()+Chr(10)+"Font size: "+Str(SelectedFontSize()), 0)
            EndIf
          
          Case 4  ; MessageRequester
            MessageRequester("Information", "Simple Message"+Chr(13)+"Line 2"+Chr(13)+"Line 3", 0)
          
          Case 5  ; Quit
            Quit = 1
            
          Case 6
            Path$ = PathRequester("Choose a path...","C:\")
            If Path$
              MessageRequester("Information", "Selected Path: "+Path$, 0)
            EndIf
            
        EndSelect
      
      
      Case #PB_Event_CloseWindow  ; If the user has pressed on the close button
        Quit = 1
        
    EndSelect

  Until Quit = 1
  
EndIf

End   ; All the opened windows are closed automatically by PureBasic
    