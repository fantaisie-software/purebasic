;
; ------------------------------------------------------------
;
;   PureBasic - Sound example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitSound() = 0
  MessageRequester("Error", "Sound system is not available",  0)
  End
EndIf

SoundFileName$ = OpenFileRequester("Choose a .wav file", "", "Wave files|*.wav",0)
If SoundFileName$
  If LoadSound(0, SoundFileName$)
    PlaySound(0, #PB_Sound_Loop)
    MessageRequester("Sound", "Playing the sound (loop)..."+#LF$+"Click to quit..", 0)
  Else
    MessageRequester("Error", "Can't load the sound.", 0)
  EndIf
EndIf
End