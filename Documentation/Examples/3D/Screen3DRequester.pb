;
; ------------------------------------------------------------
;
;   PureBasic - Common 3D functions
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#WINDOW_Screen3DRequester = 0

#GADGET_FullScreen        = 1
#GADGET_Windowed          = 2
#GADGET_ScreenModesLabel  = 3
#GADGET_WindowedModes     = 4
#GADGET_Launch            = 5
#GADGET_Cancel            = 6
#GADGET_Logo              = 7
#GADGET_Frame             = 8
#GADGET_ScreenModes       = 9
#GADGET_Antialiasing      = 10
#GADGET_AntialiasingModes = 11


Global Screen3DRequester_FullScreen, Screen3DRequester_ShowStats

UsePNGImageDecoder()

Procedure Screen3DRequester()

  OpenPreferences(GetHomeDirectory()+"PureBasicDemos3D.prefs")
    FullScreen          = ReadPreferenceLong  ("FullScreen"        , 0)
    FullScreenMode$     = ReadPreferenceString("FullScreenMode"    , "800x600")
    WindowedScreenMode$ = ReadPreferenceString("WindowedScreenMode", "800x600")
    AAMode              = ReadPreferenceLong  ("Antialiasing"      , 0)
    
  If ExamineDesktops()
    ScreenX = DesktopWidth(0)
    ScreenY = DesktopHeight(0)
    ScreenD = DesktopDepth(0)
    ScreenF = DesktopFrequency(0)
  EndIf
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    GadgetHeight = 30
  CompilerElse
    GadgetHeight = 20
  CompilerEndIf
   
  If OpenWindow(#WINDOW_Screen3DRequester, 0, 0, 396, GadgetHeight*4 + 155, "PureBasic - 3D Demos", #PB_Window_ScreenCentered | #PB_Window_SystemMenu | #PB_Window_Invisible)
   
    Top = 6
   
    ImageGadget  (#GADGET_Logo, 6, Top, 0, 0, LoadImage(0,#PB_Compiler_Home+"examples/3d/Data/PureBasic3DLogo.png"), #PB_Image_Border) : Top+76
   
    FrameGadget(#GADGET_Frame, 6, Top, 384, GadgetHeight*3 +45, "", 0) : Top+20
   
    OptionGadget(#GADGET_FullScreen, 40, Top, 130, GadgetHeight, "Fullscreen")        : Top+GadgetHeight+5
    OptionGadget(#GADGET_Windowed  , 40, Top, 130, GadgetHeight, "Windowed")          : Top+GadgetHeight+5
    TextGadget(#GADGET_Antialiasing, 40, Top+5, 130, GadgetHeight, "Antialiasing mode") : Top - ((GadgetHeight+5) * 2)
   
    ComboBoxGadget (#GADGET_ScreenModes  , 190, Top, 150, GadgetHeight+1)     : Top+GadgetHeight+5
    ComboBoxGadget (#GADGET_WindowedModes, 190, Top, 150, GadgetHeight+1)     : Top+GadgetHeight+5
    ComboBoxGadget (#GADGET_AntialiasingModes, 190, Top, 150, GadgetHeight+1) : Top+GadgetHeight+25
  
    ButtonGadget (#GADGET_Launch,   6, Top, 180, GadgetHeight+5, "Launch", #PB_Button_Default)
    ButtonGadget (#GADGET_Cancel, 200, Top, 190, GadgetHeight+5, "Cancel")
      
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"None")
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"FSAA x2")
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"FSAA x4")
    AddGadgetItem(#GADGET_AntialiasingModes,-1,"FSAA x6")
  
    SetGadgetState(#GADGET_AntialiasingModes,AAMode)
    
    If ExamineScreenModes()
      
      Position = 0
      While NextScreenMode()
        
        Position + 1
        Width       = ScreenModeWidth()
        Height      = ScreenModeHeight()
        Depth       = ScreenModeDepth()
        RefreshRate = ScreenModeRefreshRate()
        
        If Depth > 8
          AddGadgetItem(#GADGET_ScreenModes, -1, Str(Width)+"x"+Str(Height)+"x"+Str(Depth)+"@"+Str(RefreshRate))
          If ScreenX = Width And ScreenY = Height And ScreenD = Depth And ScreenF = RefreshRate
            SetGadgetState(#GADGET_ScreenModes, Position)
            FullScreenMode$ = Str(Width)+"x"+Str(Height)+"x"+Str(Depth)+"@"+Str(RefreshRate)
          EndIf  
        EndIf
       
      Wend        
      
    EndIf
    
    ExamineDesktops()
    NbScreenModes = 7
    
    Restore WindowedScreenDimensions

    Repeat      
      Read.l CurrentWidth
      Read.l CurrentHeight
      
      If CurrentWidth < DesktopWidth(0) And CurrentHeight < DesktopHeight(0)
        AddGadgetItem(#GADGET_WindowedModes, -1, Str(CurrentWidth)+ "x"+Str(CurrentHeight))
        NbScreenModes - 1
      Else
        NbScreenModes = 0
      EndIf
      
    Until NbScreenModes = 0
    
    If FullScreen
      SetGadgetState(#GADGET_FullScreen, 1)
    Else
      SetGadgetState(#GADGET_Windowed  , 1)
    EndIf

    SetGadgetText (#GADGET_ScreenModes  , FullScreenMode$)
    SetGadgetText (#GADGET_WindowedModes, WindowedScreenMode$)
    
    DisableGadget (#GADGET_ScreenModes  , 1-FullScreen)
    DisableGadget (#GADGET_WindowedModes, FullScreen)
    
    HideWindow(#WINDOW_Screen3DRequester, 0)
    
    Repeat
      
      Event = WaitWindowEvent()
      
      Select Event
        
      Case #PB_Event_Gadget
        
        Select EventGadget()
          
        Case #GADGET_Launch
          Quit = 2
          
        Case #GADGET_Cancel
          Quit = 1
          
        Case #GADGET_FullScreen
          DisableGadget(#GADGET_ScreenModes  , 0)
          DisableGadget(#GADGET_WindowedModes, 1)
        
        Case #GADGET_Windowed
          DisableGadget(#GADGET_ScreenModes  , 1)
          DisableGadget(#GADGET_WindowedModes, 0)
                 
        EndSelect
        
      Case #PB_Event_CloseWindow
        Quit = 1
        
      EndSelect
      
    Until Quit > 0
    
    FullScreen          = GetGadgetState(#GADGET_FullScreen)
    FullScreenMode$     = GetGadgetText (#GADGET_ScreenModes)
    WindowedScreenMode$ = GetGadgetText (#GADGET_WindowedModes)
    AAMode              = GetGadgetState(#GADGET_AntialiasingModes)
    
    CloseWindow(#WINDOW_Screen3DRequester)
      
  EndIf
  
  If Quit = 2 ; Launch button has been pressed
  
    CreatePreferences(GetHomeDirectory()+"PureBasicDemos3D.prefs")
      WritePreferenceLong  ("FullScreen"        , FullScreen)          
      WritePreferenceString("FullScreenMode"    , FullScreenMode$)     
      WritePreferenceString("WindowedScreenMode", WindowedScreenMode$) 
      WritePreferenceLong  ("Antialiasing"      , AAMode)  
      
    If FullScreen
      ScreenMode$ = FullScreenMode$
    Else
      ScreenMode$ = WindowedScreenMode$
    EndIf
    
    RefreshRate = Val(StringField(ScreenMode$, 2, "@"))
    
    ScreenMode$ = StringField(ScreenMode$, 1, "@") ; Remove the refresh rate info, so we can parse it easily
    
    ScreenWidth  = Val(StringField(ScreenMode$, 1, "x"))
    ScreenHeight = Val(StringField(ScreenMode$, 2, "x"))
    ScreenDepth  = Val(StringField(ScreenMode$, 3, "x"))
    
    Screen3DRequester_FullScreen = FullScreen ; Global variable, for the Screen3DEvents
    
    Select AAMode
      Case 0:
        AntialiasingMode(#PB_AntialiasingMode_None)
      Case 1:
        AntialiasingMode(#PB_AntialiasingMode_x2)
      Case 2:
        AntialiasingMode(#PB_AntialiasingMode_x4)
      Case 3:
        AntialiasingMode(#PB_AntialiasingMode_x6)
    EndSelect
    
    If FullScreen
      Result = OpenScreen(ScreenWidth, ScreenHeight, ScreenDepth, "3D Demos", #PB_Screen_WaitSynchronization, RefreshRate)
    Else
      If OpenWindow(0, 0, 0, ScreenWidth, ScreenHeight+MenuHeight(), "PureBasic - 3D Demos", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
      
        CreateMenu(0, WindowID(#WINDOW_Screen3DRequester))
          MenuTitle("Project")
          MenuItem(0, "Quit")
    
          MenuTitle("About")
          MenuItem(1, "About...")
              
        Result = OpenWindowedScreen(WindowID(#WINDOW_Screen3DRequester), 0, 0, ScreenWidth, ScreenHeight, 0, 0, 0)
      EndIf
    EndIf
    

    
    
  EndIf
     
  ProcedureReturn Result
EndProcedure


Procedure Screen3DEvents()

  If Screen3DRequester_FullScreen = 0 ; Handle all the events relatives to the window..
  
    Repeat
      Event = WindowEvent()
      
      Select Event
      
        Case #PB_Event_Menu
          Select EventMenu()
          
            Case 0
              Quit = 1
          
            Case 2
              MessageRequester("Info", "Windowed 3D in PureBasic !", 0)
              
          EndSelect
             
        Case #PB_Event_CloseWindow
          Quit = 1
        
      EndSelect
      
      If Quit = 1 : End : EndIf  ; Quit the app immediately
    Until Event = 0
    
  EndIf
  
  If ExamineKeyboard()
    If KeyboardReleased(#PB_Key_F1)
      Screen3DRequester_ShowStats = 1-Screen3DRequester_ShowStats ; Switch the ShowStats on/off
    EndIf
  EndIf
          
EndProcedure


Procedure Screen3DStats()
  If Screen3DRequester_ShowStats
    ; Nothing printed for now
  EndIf
EndProcedure

        


DataSection
  WindowedScreenDimensions:
    Data.l  320, 240
    Data.l  512, 384      
    Data.l  640, 480
    Data.l  800, 600     
    Data.l 1024, 768
    Data.l 1280, 1024
    Data.l 1600, 1200
EndDataSection