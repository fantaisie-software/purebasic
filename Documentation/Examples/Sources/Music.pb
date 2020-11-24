;
; ------------------------------------------------------------
;
;   PureBasic - Music example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


If InitSound() = 0
  MessageRequester("Error", "Sound system not available.") : End
EndIf

FileName$ = OpenFileRequester("","","Music Modules (*.mod, *.xm, *.it)|*.mod;*.xm;*.it", 0)
If FileName$
  If LoadMusic(0, FileName$)
    PlayMusic(0)
    MessageRequester("PureBasic - Module player", "Playing the music module...")
    
    ; Now, perform a nice fading...
    ;
    For k=100 To 0 Step -1
      Delay(20)
      MusicVolume(0, k)
    Next
    
  Else
    MessageRequester("Error", "Can't load the music module or bad module format.")
  EndIf
EndIf
