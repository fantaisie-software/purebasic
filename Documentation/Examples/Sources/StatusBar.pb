;
; ------------------------------------------------------------
;
;   PureBasic - StatusBar example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


If OpenWindow(0, 100, 150, 300, 100, "PureBasic - StatusBar Example", #PB_Window_SystemMenu | #PB_Window_SizeGadget)

  If CreateStatusBar(0, WindowID(0))
    AddStatusBarField(100)
    AddStatusBarField(50)
    AddStatusBarField(100)
  EndIf

  StatusBarText(0, 0, "Area 1")
  StatusBarText(0, 1, "Area 2", #PB_StatusBar_BorderLess)
  StatusBarText(0, 2, "Area 3", #PB_StatusBar_Right | #PB_StatusBar_Raised)
      
  Repeat

  Until WaitWindowEvent() = #PB_Event_CloseWindow
  
EndIf