;
; ------------------------------------------------------------
;
;   PureBasic - Movie example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitMovie() = 0
  MessageRequester("Error", "Can't initialize movie playback !", 0)
  End
EndIf

MovieName$ = OpenFileRequester("Choose the movie to play", "", "Movie files|*.avi;*.mpg|All Files|*.*", 0)
If MovieName$
  If LoadMovie(0, MovieName$)
  
    OpenWindow(0, 100, 150, MovieWidth(0), MovieHeight(0), "PureBasic - Movie")
    PlayMovie(0, WindowID(0))
      
    Repeat
    Until WaitWindowEvent() = #PB_Event_CloseWindow
  Else
    MessageRequester("Error", "Can't load the movie...", 0)
  EndIf
EndIf