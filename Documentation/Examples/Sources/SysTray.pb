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


; Invisible window to just have the systray
OpenWindow(0, 0, 0, 10, 10, "", #PB_Window_Invisible)

UsePNGImageDecoder()
AddSysTrayIcon(0, WindowID(0), LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/world.png"))

; Create a pop-up menu to be displayed by the systray
CreatePopupMenu(0)
  MenuItem(0, "About PureBasic...")
  MenuBar()
  MenuItem(1, "Exit")

; Associate the menu to the systray
SysTrayIconMenu(0, MenuID(0))

Repeat
  Select WaitWindowEvent()
    Case #PB_Event_Menu
      Select EventMenu()
        Case 0 ; About
          MessageRequester("About", "Systray example !")

        Case 1 ; Exit 
          RemoveSysTrayIcon(0)
          End
      EndSelect
  EndSelect
ForEver
