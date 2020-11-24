;
; ------------------------------------------------------------
;
;   PureBasic - SysTray example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Note: on some Linux distributions (like Ubuntu), the systray icons can be hidden by default. For more information
; see this link: http://ubuntugenius.wordpress.com/2011/06/25/ubuntu-11-04-fix-show-all-iconsindicators-in-unity-panels-notification-area/
;


If OpenWindow(0, 100, 150, 300, 100, "PureBasic - SysTray Example", #PB_Window_SystemMenu)

  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    ; .ico format is available only on Windows
    IconName$ = #PB_Compiler_Home + "examples/sources/Data/CdPlayer.ico"
  CompilerElse
    UsePNGImageDecoder()
    IconName$ = #PB_Compiler_Home + "examples/sources/Data/world.png"
  CompilerEndIf
  
  AddSysTrayIcon(1, WindowID(0), LoadImage(0, IconName$))
  AddSysTrayIcon(2, WindowID(0), LoadImage(1, IconName$))
  SysTrayIconToolTip(1, "Icon 1")
  SysTrayIconToolTip(2, "Icon 2")
  
  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_SysTray
      If EventType() = #PB_EventType_LeftDoubleClick
        MessageRequester("SysTray", "Left DoubleClick on SysTrayIcon "+Str(EventGadget()),0)
        
        ChangeSysTrayIcon (EventGadget(), LoadImage(0, IconName$))
        SysTrayIconToolTip(EventGadget(), "Changed !")
      EndIf
      
    EndIf
  Until Event = #PB_Event_CloseWindow
  
EndIf
