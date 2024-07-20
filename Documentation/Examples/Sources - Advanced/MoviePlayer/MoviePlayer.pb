;
; Movie player in PureBasic
;
; Note: This source code is for demonstration only and is not
; finished or optimized at all. It has been coded in less than hour.
;

#WindowWidth = 300
#WindowHeight = 68

If InitMovie() = 0
  MessageRequester("Error", "Can't initialize movie playback !", 0)
  End
EndIf

If OpenWindow(0, 100, 100, #WindowWidth, #WindowHeight, "PureBasic Movie Player v1.1", #PB_Window_Invisible | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget)

  If CreateMenu(0, WindowID(0))
    MenuTitle("File")
      MenuItem(0, "Load Movie")
      MenuBar()
      MenuItem(1, "Quit")
      
    MenuTitle("Control")
      MenuItem(2, "Play")
      MenuItem(3, "Stop")
      MenuItem(4, "Pause")

      MenuBar()
      
      OpenSubMenu("Size")
        MenuItem(13, "50 %")
        MenuItem(14, "100 %")
        MenuItem(15, "200 %")
      CloseSubMenu()
      
      MenuBar()
      
      OpenSubMenu("Volume")
        MenuItem(6, "100 %")
        MenuItem(7, "50 %")
        MenuItem(8, "Mute")
      CloseSubMenu()
      
      OpenSubMenu("Balance")
        MenuItem( 9, "Middle")
        MenuItem(10, "Left")
        MenuItem(11, "Right")
      CloseSubMenu()
      
    MenuTitle("About")
      MenuItem(12, "About")
  EndIf

  If CreateToolBar(0, WindowID(0))
    ToolBarImageButton(0, LoadImage(0, "Icons\Load.ico"))
    ToolBarSeparator()
    ToolBarImageButton(3, LoadImage(0, "Icons\Stop.ico"))
    ToolBarImageButton(2, LoadImage(0, "Icons\Play.ico"))
    ToolBarImageButton(4, LoadImage(0, "Icons\Pause.ico"))
    ToolBarSeparator()
    ToolBarImageButton(12, LoadImage(0, "Icons\About.ico"))
  EndIf
  
  If CreateStatusBar(0, WindowID(0))
    AddStatusBarField(6000) ; Excessive value of 6000 pixels, to have a field which take all the window width !
    StatusBarText(0, 0, "Welcome !", 0)
  EndIf
  
  HideWindow(0, 0)  ; Show the window once all toolbar/menus has been created...
  
  Volume = 100
      
  Repeat
  
    Select WindowEvent()
            
      Case #PB_Event_Menu
      
        Select EventMenu()
        
          Case 0 ; Load
            MovieName$ = OpenFileRequester("Choose the movie to play", "", "Movie/Audio files|*.avi;*.mpg;*.asf;*.mp3;*.wav|All Files|*.*", 0)
            If MovieName$
              If LoadMovie(0, MovieName$)
                MovieLoaded = 1
                MovieState  = 0
                
                If MovieHeight(0) > 0  ; Not an audio only file..
                  ResizeWindow(0, #PB_Ignore, #PB_Ignore, MovieWidth(0), MovieHeight(0)+70)
                Else
                  ResizeWindow(0, #PB_Ignore, #PB_Ignore, #WindowWidth, #WindowHeight)
                EndIf
                
                StatusBarText(0, 0, "Movie '"+MovieName$+"' loaded", 0)
              Else
                StatusBarText(0, 0, "Can't load the movie '"+MovieName$+"'", 0)
              EndIf
            EndIf
            
          Case 1 ; Quit
            End
            
          ; ---------------- Movie controls -------------------
            
          Case 2 ; Play
            
            If MovieLoaded
              If MovieState = 2
                ResumeMovie(0)
              Else
                PlayMovie(0, WindowID(0))
              EndIf
              
              StatusBarText(0, 0, "Playing...", 0)
              MovieState = 1  ; Playing
            EndIf
            
          Case 3 ; Stop
            If MovieLoaded And MovieState = 1
              StopMovie(0)
              MovieState = 3 ; Stopped
              StatusBarText(0, 0, "Movie stopped.", 0)
           EndIf
            
          Case 4 ; Pause
            If MovieLoaded And MovieState = 1
              PauseMovie(0)
              MovieState = 2  ; Paused
              StatusBarText(0, 0, "Movie paused.", 0)
           EndIf
            
          ; ---------------- Volume -------------------
            
          Case 6 ; Volume 100%
            Volume = 100
            
          Case 7 ; Volume 50%
            Volume = 50
            
          Case 8 ; Volume 100%
            Volume = 0
            
          ; ---------------- Balance -------------------
                        
          Case 9  ; Balance middle
            Balance = 0
            
          Case 10 ; Balance left
            Balance = -100
            
          Case 11 ; Balance right
            Balance = 100
            
          ; ---------------- Size -------------------

          Case 13  ; Size 50%
            If MovieLoaded
              MovieWidth  = MovieWidth(0)/2
              MovieHeight = MovieHeight(0)/2
            EndIf
            
          Case 14 ; Size 100%
            If MovieLoaded
              MovieWidth  = MovieWidth(0)
              MovieHeight = MovieHeight(0)
            EndIf
                    
          Case 15 ; Size 200%
            If MovieLoaded
              MovieWidth  = MovieWidth(0)*2
              MovieHeight = MovieHeight(0)*2
            EndIf
            
          ; ---------------- Misc -------------------
            
          Case 12 ; About
            MessageRequester("Info", "PureBasic Movie Player"+Chr(10)+Chr(10)+"https://www.purebasic.com")
        
        EndSelect
        
        If MovieLoaded
          If CurrentWidth <> MovieWidth Or CurrentHeight <> MovieHeight
            ResizeWindow(0, #PB_Ignore, #PB_Ignore, MovieWidth+20, MovieHeight+100)  ; Movie will be resized in the #PB_WindowSizeEvent
            
            CurrentWidth  = MovieWidth
            CurrentHeight = MovieHeight
          EndIf
        
          If CurrentVolume <> Volume Or CurrentBalance <> Balance  ; We need to update the audio stuff
            MovieAudio(0, Volume, Balance)
            
            CurrentVolume  = Volume
            CurrentBalance = Balance
          EndIf
        EndIf
        
      Case #PB_Event_CloseWindow
        End
        
      Case #PB_Event_SizeWindow
        If IsMovie(0)
          ResizeMovie(0, 0, 27, WindowWidth(0), WindowHeight(0)-70)
        EndIf
        
      Case 0
        Delay(20)
        
        If MovieLoaded And MovieStatus(0) <> PreviousMovieStatus  ; To prevent flickering on the StatusBar
        
          Select MovieStatus(0)
            Case -1
              StatusBarText(0, 0, "Movie Paused.", 0)

            Case 0
              StatusBarText(0, 0, "Movie Stopped.", 0)

            Default
              StatusBarText(0, 0, "Playing :"+Str(MovieStatus(0)), 0)
              
          EndSelect
          
          PreviousMovieStatus = MovieStatus(0)
        EndIf
          
    EndSelect
    
  ForEver
EndIf

End