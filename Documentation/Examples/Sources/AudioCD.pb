;
; ------------------------------------------------------------
;
;   PureBasic - Audio CD example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

NbCDDrives = InitAudioCD()

If NbCDDrives = 0
  MessageRequester("Error", "No CD Audio drives found...", 0)
  End
EndIf

Procedure.s GetHourFormat(LengthInSeconds)
  Minutes = LengthInSeconds/60
  Seconds = LengthInSeconds-Minutes*60
  If Seconds < 10 : Null$ = "0" : Else : Null$ = "" : EndIf

  ProcedureReturn Str(Minutes)+":"+Null$+Str(Seconds)
EndProcedure

; Initialize constants for easier code reading
;
Enumeration
  #GADGET_Play
  #GADGET_Stop
  #GADGET_Eject
  #GADGET_Close
  #GADGET_Select
  #GADGET_Status
  #GADGET_Time
  #GADGET_AudioCDDrive
  #GADGET_SelectDrive 
EndEnumeration
  
Procedure RefreshCD()
  ClearGadgetItems(#GADGET_Select)

  NbAudioTracks = AudioCDTracks()
  For k=1 To NbAudioTracks
    AddGadgetItem(#GADGET_Select, -1, "Track "+Str(k))
  Next
  SetGadgetState(#GADGET_Select, 0)
EndProcedure


If OpenWindow(0, 100, 200, 265, 125, "PureBasic - AudioCD Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)

  ButtonGadget  (#GADGET_Play   ,  10, 10, 60 , 24, "Play")
  ButtonGadget  (#GADGET_Stop   ,  70, 10, 60 , 24, "Stop")
  ButtonGadget  (#GADGET_Eject  , 130, 10, 60 , 24, "Eject")
  ButtonGadget  (#GADGET_Close  , 190, 10, 60 , 24, "Close")
  ComboBoxGadget(#GADGET_Select ,  10, 43, 240, 24)
  TextGadget(#GADGET_Status, 10, 70, 180, 24, "Status: stopped")
  TextGadget(#GADGET_Time, 200, 70, 240, 24, "")

  TextGadget(#GADGET_AudioCDDrive, 10, 99, 180, 24, "Select the CD-Audio drive :")
  ComboBoxGadget(#GADGET_SelectDrive, 210, 95, 40, 24)

  For k=1 To NbCDDrives
    UseAudioCD(k-1)
    AddGadgetItem(#GADGET_SelectDrive, -1, Left(AudioCDName(),2))
  Next
  SetGadgetState(#GADGET_SelectDrive, 0)
  UseAudioCD(0)

  If NbCDDrives = 1
    DisableGadget(#GADGET_SelectDrive, 1)
  EndIf
  
  AddWindowTimer(0, 1, 500) ; Check every 200 ms
  
  RefreshCD()

  Repeat
    Event = WaitWindowEvent()

    Select Event 
      Case #PB_Event_Gadget
        Select EventGadget()
  
          Case #GADGET_Play
            CurrentTrack = GetGadgetState(4)+1
            PlayAudioCD(CurrentTrack, CurrentTrack)
            
          Case #GADGET_Stop
            StopAudioCD()
  
          Case #GADGET_Eject
            EjectAudioCD(1)
  
          Case #GADGET_Close
            EjectAudioCD(0)
  
          Case #GADGET_SelectDrive
            UseAudioCD(GetGadgetState(#GADGET_SelectDrive))
            RefreshCD()
  
        EndSelect
        
      Case #PB_Event_Timer
        CurrentTrack = AudioCDStatus()
        If CurrentTrack > 0
          SetGadgetText(#GADGET_Status, "Playing Track "+Str(CurrentTrack)+" (Length: "+GetHourFormat(AudioCDTrackLength(CurrentTrack))+")")
          SetGadgetText(#GADGET_Time, "Time: "+GetHourFormat(AudioCDTrackSeconds()))
          DisableGadget(#GADGET_Play, 1)
          DisableGadget(#GADGET_Stop, 0)
          DisableGadget(#GADGET_Select, 0)
        Else
          If CurrentTrack = -1
            NeedRefresh = 1
            SetGadgetText(#GADGET_Status, "Status: No disk detected")
            DisableGadget(#GADGET_Select, 1)
          Else
            SetGadgetText(#GADGET_Status, "Status: Stopped")
            DisableGadget(#GADGET_Select, 0)
            
            If NeedRefresh
              RefreshCD()
              NeedRefresh = 0
            EndIf
          EndIf
          
          SetGadgetText(#GADGET_Time, "")
          DisableGadget(#GADGET_Play, 0)
          DisableGadget(#GADGET_Stop, 1)
        EndIf
    EndSelect

  Until Event = #PB_Event_CloseWindow

EndIf

For k=0 To NbCDDrives-1    ; Stop all the CD drives, if some are playing together
  UseAudioCD(k)
  StopAudioCD()
Next

End
