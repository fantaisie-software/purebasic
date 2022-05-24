;
; ------------------------------------------------------------
;
;   PureBasic - Audio CD example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;-
;- ------- Initialization -------
;- .: Constants & Variables :.
Enumeration FormWindow
  #Window0
EndEnumeration

Enumeration FormGadget
  #ButtonPlay
  #ButtonPause
  #ButtonStop
  #TextAudioCDDrive
  #ComboBoxDeviceCD
  #ListViewTracks
  #TextStatus
  #ButtonEject
  #ButtonPreviousTrack
  #ButtonNextTrack
  #TextTime
  #TextCDLength
  #TextNbTracks
EndEnumeration


NbCDDrives = InitAudioCD()  ; How many CD Drives ?

If NbCDDrives = 0           ; If no CD Drive found then ends everything
  MessageRequester("Error", "No CD Audio drives found...", 0)
  End
EndIf

;- .: Procedures :.
Procedure.s GetHourFormat(LengthInSeconds) ; Format seconds into minutes and seconds
  Minutes = LengthInSeconds/60
  Seconds = LengthInSeconds-Minutes*60
  If Seconds < 10
    ProcedureReturn Str(Minutes)+"m:0"+Str(Seconds)+"s"
  Else
    ProcedureReturn Str(Minutes)+"m:"+Str(Seconds)+"s"
  EndIf
EndProcedure

Procedure RefreshCD() ; If a (new) CD is inside
  ClearGadgetItems(#ListViewTracks)
  
  NbAudioTracks = AudioCDTracks()
  For k=1 To NbAudioTracks
    If k<10
      AddGadgetItem(#ListViewTracks, -1, "Track 0"+Str(k)+" :"+GetHourFormat(AudioCDTrackLength(k)))
    Else
      AddGadgetItem(#ListViewTracks, -1, "Track "+Str(k)+" :"+GetHourFormat(AudioCDTrackLength(k)))
    EndIf
  Next
  
  DisableGadget(#ButtonPause, 1)
  DisableGadget(#ButtonStop, 1)
  SetGadgetState(#ListViewTracks, 0)
  SetGadgetText(#TextCDLength, "Total: " + GetHourFormat(AudioCDLength()))
  SetGadgetText(#TextNbTracks, "Total Tracks: "+Str(AudioCDTracks()))
EndProcedure

;-
;- ---------- Main Code ---------
;- Open a window
If OpenWindow(#Window0, 0, 0, 400, 470, "PureBasic - AudioCD Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  
  ButtonGadget(#ButtonPlay, 30, 20, 100, 25, "Play")
  ButtonGadget(#ButtonPause, 150, 20, 100, 25, "Pause")
  ButtonGadget(#ButtonStop, 270, 20, 100, 25, "Stop")
  TextGadget(#TextAudioCDDrive, 180, 60, 80, 25, "Device:", #PB_Text_Right)
  ComboBoxGadget(#ComboBoxDeviceCD, 270, 60, 100, 25)
  ButtonGadget(#ButtonEject, 30, 60, 100, 25, "Eject CD", #PB_Button_Toggle)
  ButtonGadget(#ButtonPreviousTrack, 30, 100, 170, 25, "Previous Track")
  ButtonGadget(#ButtonNextTrack, 210, 100, 160, 25, "Next Track")
  ListViewGadget(#ListViewTracks, 30, 130, 340, 270)
  TextGadget(#TextStatus, 30, 410, 240, 25, "Status: Stopped")
  TextGadget(#TextTime, 280, 410, 90, 25, "00:00", #PB_Text_Right)
  TextGadget(#TextCDLength, 30, 440, 190, 25, "Total: ")
  TextGadget(#TextNbTracks, 240, 440, 130, 25, "", #PB_Text_Right)
  
  
  For k=0 To NbCDDrives -1  ; Fullfill the ComboBox with CD devices' name
    UseAudioCD(k)
    AddGadgetItem(#ComboBoxDeviceCD, -1, Left(AudioCDName(),2))
  Next
  SetGadgetState(#ComboBoxDeviceCD, 0)
  UseAudioCD(0)
  
  
  RefreshCD() ; Fullfill the ListView with CD's tracks
  
  AddWindowTimer(#Window0, 0, 100) 
  
  ;- Loop:
  Repeat
    Select WaitWindowEvent() 
        
      Case #PB_Event_Gadget
        
        ;- ->Management of the gadgets
        Select EventGadget()
            
          Case #ButtonPlay              ; Play
            If Pause=#True
              ResumeAudioCD()
              Pause=#False
            Else
              CurrentTrack = GetGadgetState(#ListViewTracks)+1
              PlayAudioCD(CurrentTrack, AudioCDTracks())
            EndIf
            
          Case #ButtonPause             ; Pause
            Pause=#True
            PauseAudioCD()
            
          Case #ButtonStop              ; Stop
            Pause=#False
            StopAudioCD()
            
          Case #ButtonEject             ; Eject/Close
            ClearGadgetItems(#ListViewTracks)
            If GetGadgetState(#ButtonEject) = 1
              SetGadgetText(#ButtonEject, "Close")
              EjectAudioCD(1)
            Else
              SetGadgetText(#ButtonEject, "Eject CD")
              EjectAudioCD(0)
              RefreshCD()
            EndIf
            
          Case #ComboBoxDeviceCD        ; Choose your CD Device
            UseAudioCD(GetGadgetState(#ComboBoxDeviceCD))
            RefreshCD()
            
          Case #ButtonPreviousTrack     ; Play Previous Track
            CurrentTrack = CurrentTrack - 1
            If CurrentTrack < 1
              CurrentTrack=AudioCDTracks()
            EndIf
            SetGadgetState(#ListViewTracks, CurrentTrack-1)
            PlayAudioCD(CurrentTrack, AudioCDTracks())
            
          Case #ButtonNextTrack         ; Play Next Track
            CurrentTrack = CurrentTrack + 1
            If CurrentTrack > AudioCDTracks()
              CurrentTrack=1
            EndIf
            SetGadgetState(#ListViewTracks, CurrentTrack-1)
            PlayAudioCD(CurrentTrack, AudioCDTracks())
            
          Case #ListViewTracks           ; Click on Track = Play the Track
            If Pause=#True
              Pause=#False
            EndIf
            CurrentTrack = GetGadgetState(#ListViewTracks)+1
            PlayAudioCD(CurrentTrack, AudioCDTracks())
            
        EndSelect
      
      Case #PB_Event_Timer
        ;- ->Display informations
        CurrentTrack = AudioCDStatus()
        
        If CurrentTrack > 0 ; A track is playing...
          If AudioCDTrackSeconds() = 0  ; Update the ListView if a new track is played
            SetGadgetState(#ListViewTracks, CurrentTrack-1)
          EndIf
          SetGadgetText(#TextStatus, "Playing Track " + Str(CurrentTrack) + " (Length: " + GetHourFormat(AudioCDTrackLength(CurrentTrack)) + ")")
          SetGadgetText(#TextTime, "Time: " + GetHourFormat(AudioCDTrackSeconds()))
          DisableGadget(#ButtonPlay, 1)
          DisableGadget(#ButtonPause, 0)
          DisableGadget(#ButtonStop, 0)
          DisableGadget(#ListViewTracks, 0)
          
        ElseIf CurrentTrack = 0         ; The CD Drive is paused or stopped ?
          If Pause=#True                ; Pause
            SetGadgetText(#TextStatus, "Status: Pause.")
            DisableGadget(#ButtonPlay, 0)
            DisableGadget(#ButtonPause, 1)
            DisableGadget(#ButtonStop, 0)
            DisableGadget(#ListViewTracks, 0)
          Else                          ; Stopped
            SetGadgetText(#TextStatus, "Status: Stopped with a CD inside.")
            SetGadgetText(#TextTime, "")
            DisableGadget(#ButtonPlay, 0)
            DisableGadget(#ButtonPause, 1)
            DisableGadget(#ButtonStop, 1)
            DisableGadget(#ListViewTracks, 0)
            If GetGadgetState(#ButtonEject) = 1
              SetGadgetText(#ButtonEject, "Close")
              SetGadgetText(#ButtonEject, "Eject CD")
              SetGadgetState(#ButtonEject, 0)
              RefreshCD()
            EndIf
          EndIf
          
        ElseIf CurrentTrack = -1        ; CD Drive not ready
          DisableGadget(#ListViewTracks, 1)
          SetGadgetText(#TextStatus, "Status: No CD or Open.")
          SetGadgetText(#TextCDLength, "Total: ")
          SetGadgetText(#TextTime, "")
          SetGadgetText(#TextNbTracks, "Total Tracks: ")
          DisableGadget(#ButtonPlay, 1)
          DisableGadget(#ButtonPause, 1)
          DisableGadget(#ButtonStop, 1)
          DisableGadget(#ListViewTracks, 1)
          
        Else
          DisableGadget(#ListViewTracks, 0)
          
        EndIf
      
      Case #PB_Event_CloseWindow ; Close the Window
        Quit = 1
    EndSelect
  Until Quit = 1
  
EndIf
;- End Loop:
;-
;- ------------- End ------------
;- Free CD Drives
For k=0 To NbCDDrives-1 ; Stop all the CD drives, if some are playing together
  UseAudioCD(k)
  StopAudioCD()
Next

End