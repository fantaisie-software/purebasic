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
  MessageRequester("Error", "Can't initialize the sound system",  0)
  End
EndIf

UseOGGSoundDecoder()

SoundFileName$ = OpenFileRequester("Choose a sound file", "", "Wave or OGG files|*.wav;*.ogg",0)
If SoundFileName$
  If LoadSound(0, SoundFileName$)
    PlaySound(0,#PB_Sound_Loop)
    MessageRequester("Sound", "Playing the sound (loop)..."+Chr(10)+"Click to quit..", 0)
  Else
    MessageRequester("Error", "Can't load the sound.", 0)
  EndIf
EndIf
End