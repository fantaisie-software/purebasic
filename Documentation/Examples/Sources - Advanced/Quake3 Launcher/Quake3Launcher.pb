;
; ------------------------------------------------------------
;
;   PureBasic - Quake 3 Selector 
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; NOTE: This file doesn't compile with the demo version !

WindowWidth  = 400
WindowHeight = 350

ButtonHeight.w = 25

Structure Quake3Mods
  Alias.s
  NomReel.s
  Version.s
EndStructure


NewList Mods.Quake3Mods()

If ReadFile(0, "Quake3Launcher.prefs")

  While Eof(0) = 0

    AddElement(Mods())
    Mods()\Alias   = ReadString(0)
    Mods()\NomReel = ReadString(0)
    Mods()\Version = ReadString(0)

  Wend
  
  CloseFile(0)
Else
  MessageRequester("Quake 3 Launcher", "Can't find the 'Quake3Launcher.prefs' file")
  End
EndIf


If OpenWindow(0, 100, 100, WindowWidth, WindowHeight, "Quake 3 Launcher - by AlphaSND & JunIor")

  Top = 10

  ListViewGadget(5, 10, Top, WindowWidth-20, WindowHeight-ButtonHeight-25) : Top+GadgetHeight(5)+6

  ResetList(Mods())
  While NextElement(Mods())
    AddGadgetItem(5, -1, Mods()\Alias)
  Wend

  OffsetX = WindowWidth/3-14
  ButtonGadget(3, 30+OffsetX*2, Top, OffsetX  , ButtonHeight, "Quit")
  ButtonGadget(4, 83+OffsetX  , Top, OffsetX/2, ButtonHeight, "About")
  ButtonGadget(2, 17+OffsetX  , Top, OffsetX/2, ButtonHeight, "Info")
  ButtonGadget(1, 10          , Top, OffsetX  , ButtonHeight, "Launch !")

  SetActiveGadget(5)
  SetGadgetState(5, 0)
  
  FirstElement(Mods())

  Repeat
    EventID = WaitWindowEvent()
    
    Select EventID

      Case #PB_Event_Gadget

          Select EventGadget()

            Case 1
              Gosub LaunchQuake3

            Case 2
              Gosub DisplayInfo

            Case 3
              Quit = 1

            Case 4
              MessageRequester("About", "Quake 3 Arena Launcher"+Chr(10)+Chr(10)+"Switch between 1.17 & 1.27 version automagically"+Chr(10)+Chr(10)+"Coded in 1 hour in PureBasic"+Chr(10)+"Check it at http://www.purebasic.com"+Chr(10))

            Case 5
              ActualPosition = GetGadgetState(5)
              ResetList(Mods())
              For k=0 To ActualPosition 
                NextElement(Mods())
              Next

              If EventType() = 2
                Gosub LaunchQuake3
              EndIf

          EndSelect

      Case #PB_Event_CloseWindow
        Quit = 1

    EndSelect

  Until Quit = 1

EndIf

End


LaunchQuake3:

  If Mods()\Version = "1.27"
    RenameFile("BaseQ3\pak4.pk3.old", "BaseQ3\pak4.pk3")
    RenameFile("BaseQ3\pak5.pk3.old", "BaseQ3\pak5.pk3")

    Command$ = "Quake3.exe"
  Else
    RenameFile("BaseQ3\pak4.pk3", "BaseQ3\pak4.pk3.old")
    RenameFile("BaseQ3\pak5.pk3", "BaseQ3\pak5.pk3.old")

    Command$ = "Quake3.1.17.exe"
  EndIf

  CopyFile(Mods()\NomReel+"\q3config.cfg", "quake3launcher.cfg")

  RunProgram(Command$, "+set fs_game "+Mods()\NomReel, "")
Return


DisplayInfo:
  If ReadFile(0, Mods()\NomReel+"\"+Mods()\NomReel+".info")

    Information$ = ""
    While Eof(0) = 0
      Information$ = Information$+ReadString(0)+Chr(13)
    Wend

    CloseFile(0)
  Else
    Information$ = "No information available."
  EndIf

  MessageRequester("Information - "+Mods()\Alias, Information$, 0)
Return