;
; ------------------------------------------------------------
;
;   PureBasic - Gadget example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#WindowWidth  = 450
#WindowHeight = 305

; Load our images..
;
LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/Drive.bmp")
LoadImage(1, #PB_Compiler_Home + "examples/sources/Data/File.bmp")
LoadImage(2, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp")

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  ; Only Windows supports .ico file format
  LoadImage(3, #PB_Compiler_Home + "examples/sources/Data/CdPlayer.ico")
CompilerElse
  LoadImage(3, #PB_Compiler_Home + "examples/sources/Data/Drive.bmp")
CompilerEndIf

CreatePopupMenu(0)
  MenuItem(0, "Popup !")

If OpenWindow(0, 100, 200, #WindowWidth, #WindowHeight, "PureBasic - Advanced Gadget Demonstration", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget)

  ListIconGadget(5, 170, 50, 265, 200, "Column 1", 131)
  AddGadgetColumn(5, 1, "Column 2", 300)
  AddGadgetColumn(5, 2, "Column 3", 80)
  
  TextGadget(4, 10, 16, 180, 24, "Please wait while initializing...")
  
  ProgressBarGadget(3, 10, 260, #WindowWidth-25, 20, 0, 100)
  
  ; Update the ProgressBar, just for fun !
  ;
  For k=0 To 100
    SetGadgetState(3, k)
    Delay(10)
  Next
  
  ImageGadget      (0, 200, 5, 0, 0, ImageID(2))
  ButtonImageGadget(1, 384, 5, 50, 36, ImageID(3))
  
  TreeGadget    (2,  10, 50, 150, 200)
    
  SetGadgetText(4, "Initialize Ok... Welcome !")
  
  ; Fill Up the Tree gadget with lot of entries (including the image)
  ;
  
  For k=0 To 10
    AddGadgetItem(2, -1, "General "+Str(k), ImageID(1))
    AddGadgetItem(2, -1, "ScreenMode", ImageID(1))
      AddGadgetItem(2, -1, "640*480", ImageID(1), 1)
      AddGadgetItem(2, -1, "800*600", ImageID(3), 1)
      AddGadgetItem(2, -1, "1024*768", ImageID(1), 1)
      AddGadgetItem(2, -1, "1600*1200", ImageID(1), 1)
    AddGadgetItem(2, -1, "Joystick", ImageID(1))
  Next
    
  ; Fill Up the ListIcon gadget. Notice than the column are separated by Chr(10) (NewLine) character
  ;
  For k=0 To 100
    AddGadgetItem(5, -1, "Element "+Str(k)+Chr(10)+"C 2"+Chr(10)+"Comment 3", ImageID(3))
  Next
  
  SetGadgetState(5, 8)
  
  Repeat
    Event = WaitWindowEvent()

    If Event = #PB_Event_Gadget
      
      Select EventGadget()
        Case 1
          MessageRequester("Information", "You did it !", 0)
      
        Case 2
          SetGadgetText(4, "Tree Gadget. Item selected: "+Str(GetGadgetState(2)))
          
          If EventType() = 2
            MessageRequester("Information", "Doubleclick: item"+Str(GetGadgetState(2))+", Text: "+GetGadgetText(2), 0)
          ElseIf EventType() = 1
            DisplayPopupMenu(0, WindowID(0))
          EndIf
          
        Case 5
          SetGadgetText(4, "ListIcon Gadget. Item selected: "+Str(GetGadgetState(5)))
          
          If EventType() = 2
            MessageRequester("Information", "Doubleclick: item"+Str(GetGadgetState(5))+", Text: "+GetGadgetText(5), 0)
          ElseIf EventType() = 1
            DisplayPopupMenu(0, WindowID(0))
          EndIf
          
     EndSelect

    EndIf
    
  Until Event = #PB_Event_CloseWindow
EndIf

End