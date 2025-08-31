; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
;
; PureBasic Linux resident file
;

; General
;
;
IncludeFile "../Common.pb"


; Clipboard
;
#PB_Clipboard_Image = 0 ; TODO

; Used by Get/SetFileDate() and DirectoryEntryDate()
;
#PB_Date_Created  = 0
#PB_Date_Accessed = 1
#PB_Date_Modified = 2

; FileSystem
;
#PB_FileSystem_Link     = $1000

#PB_FileSystem_ReadUser   = $100  ; 0400
#PB_FileSystem_WriteUser  =  $80  ; 0200
#PB_FileSystem_ExecUser   =  $40  ; 0100
#PB_FileSystem_ReadGroup  =  $20  ;  040
#PB_FileSystem_WriteGroup =  $10  ;  020
#PB_FileSystem_ExecGroup  =   $8  ;  010
#PB_FileSystem_ReadAll    =   $4
#PB_FileSystem_WriteAll   =   $2
#PB_FileSystem_ExecAll    =   $1

#PB_FileSystem_Recursive  = 1
#PB_FileSystem_Force      = 2

#PB_FileSystem_NoExtension = 1

#PB_DirectoryEntry_File      = 1
#PB_DirectoryEntry_Directory = 2

#PB_Date_Created  = 0
#PB_Date_Accessed = 1
#PB_Date_Modified = 2

; Font
;
#PB_Font_Bold        = 1 << 0
#PB_Font_Italic      = 1 << 1
#PB_Font_Underline   = 0 ; TODO
#PB_Font_StrikeOut   = 0 ; TODO
#PB_Font_HighQuality = 0 ; TODO

; Image
;
#PB_Image_Smooth = 0
#PB_Image_Raw    = 1


; OnError platform specific error codes
; See <bits/signum.h>
;
#PB_OnError_InvalidMemory          = 11 ; SIGSEGV
#PB_OnError_Floatingpoint          =  8 ; SIGFPE
#PB_OnError_Breakpoint             =  5 ; SIGTRAP
#PB_OnError_IllegalInstruction     =  4 ; SIGILL
#PB_OnError_PriviledgedInstruction = 31 ; SIGSYS
#PB_OnError_DivideByZero           = -1 ; Windows only, linux reports SIGFPE instead here

; RunProgram
;
#PB_Program_Wait     = 1
#PB_Program_Hide     = 2
#PB_Program_Open     = 4
#PB_Program_Read     = 8
#PB_Program_Write    = 16
#PB_Program_Error    = 32
#PB_Program_Connect  = 64
#PB_Program_Eof      = 1  ; for WriteProgramData()
#PB_Program_Ascii    = 128
#PB_Program_UTF8     = 256
#PB_Program_Unicode  = 512


; StatusBar
;
#PB_StatusBar_Raised     = 1
#PB_StatusBar_BorderLess = 2
#PB_StatusBar_Center     = 4
#PB_StatusBar_Right      = 8

#PB_Button_Default = $8
#PB_Button_Left = $2
#PB_Button_MultiLine = $10
#PB_Button_Right = $1
#PB_Button_Toggle = $4

; for buttonimage
#PB_Button_Image = 1
#PB_Button_PressedImage = 2

#PB_Calendar_Borderless = 1

#PB_CheckBox_Center = $2
#PB_CheckBox_Right = $1
#PB_CheckBox_ThreeState = $4

#PB_ComboBox_Editable  = $1
#PB_ComboBox_LowerCase = $2
#PB_ComboBox_UpperCase = $4
#PB_ComboBox_Image     = $8

#PB_Calendar_Minimum = 1
#PB_Calendar_Maximum = 2

#PB_Date_Calendar = 0  ; default
#PB_Date_UpDown   = $1 ;DTS_UPDOWN
#PB_Date_Minimum  = 1  ; for Get/SetGadgetAttribute
#PB_Date_Maximum  = 2
#PB_Date_CheckBox = $2 ;DTS_SHOWNONE

; Explorerlist standart columns:
#PB_Explorer_Name                = "PB_Explorer_Column_Name"
#PB_Explorer_Size                = "PB_Explorer_Column_Size"
#PB_Explorer_Type                = "PB_Explorer_Column_Type"
#PB_Explorer_Attributes          = "PB_Explorer_Column_Attributes"
#PB_Explorer_Created             = "PB_Explorer_Column_Created"
#PB_Explorer_Modified            = "PB_Explorer_Column_Modified"
#PB_Explorer_Accessed            = "PB_Explorer_Column_Accessed"

#PB_Image_Border = 1 << 0
#PB_Image_Raised = 1 << 1

#PB_ListView_MultiSelect = 1
#PB_ListView_ClickSelect = 2

#PB_MDI_BorderLess              = $00000001
#PB_MDI_AutoSize                = $00000002
#PB_MDI_NoScrollBars            = $00000004
#PB_MDI_Cascade                 = -1
#PB_MDI_TileVertically          = -2
#PB_MDI_TileHorizontally        = -3
#PB_MDI_Next                    = -4
#PB_MDI_Previous                = -5
#PB_MDI_Arrange                 = -6
#PB_MDI_Normal                  = $00000001
#PB_MDI_Maximize                = $00000002
#PB_MDI_Minimize                = $00000004
#PB_MDI_Hide                    = $00000008
#PB_MDI_Show                    = $00000010
#PB_MDI_ItemWidth               = 1
#PB_MDI_ItemHeight              = 2
#PB_MDI_SizedItem               = 1

; Flags
;
#PB_ProgressBar_Smooth = $0
#PB_ProgressBar_Vertical = $1

; Attributes
;
#PB_ProgressBar_Minimum = 1
#PB_ProgressBar_Maximum = 2

; Flags
;
#PB_Spin_ReadOnly =  4
#PB_Spin_Numeric = 8

; Attributes
;
#PB_Spin_Minimum = 1
#PB_Spin_Maximum = 2

#PB_Text_Border = $4
#PB_Text_Center = $2
#PB_Text_Right = $1

#PB_Tree_AlwaysShowSelection = $0
#PB_Tree_CheckBoxes = $4
#PB_Tree_NoButtons = $2
#PB_Tree_NoLines = $1
#PB_Tree_ThreeState = $8

#PB_Tree_SubLevel = 1

#PB_Tree_Selected = 1
#PB_Tree_Expanded = 2
#PB_Tree_Checked = 4
#PB_Tree_Collapsed = 8
#PB_Tree_Inbetween = 16

; Window
;
#PB_Window_Invisible      = 1 << 0
#PB_Window_SizeGadget     = 1 << 1
#PB_Window_SystemMenu     = 1 << 2
#PB_Window_TitleBar       = 1 << 3
#PB_Window_MaximizeGadget = 1 << 4
#PB_Window_MinimizeGadget = 1 << 5
#PB_Window_ScreenCentered = 1 << 6
#PB_Window_BorderLess     = 1 << 7
#PB_Window_WindowCentered = 1 << 8
#PB_Window_Maximize       = 1 << 9
#PB_Window_Minimize       = 1 << 10
#PB_Window_Tool           = 1 << 11
#PB_Window_Normal         = 0
#PB_Window_NoGadgets      = 1 << 12
#PB_Window_NoActivate     = 1 << 13

; For WindowX/Y/Width/Height()
;
#PB_Window_FrameCoordinate = 0
#PB_Window_InnerCoordinate = 1


; Events
;
#PB_Event_Menu           = 1
#PB_Event_CloseWindow    = 2
#PB_Event_Gadget         = 3
#PB_Event_MoveWindow     = 5
#PB_Event_Repaint        = 4
#PB_Event_SizeWindow     = 6
#PB_Event_ActivateWindow = 7
#PB_Event_DeactivateWindow = 8
#PB_Event_SysTray        = 9
#PB_Event_WindowDrop     = 10
#PB_Event_GadgetDrop     = 11
#PB_Event_MinimizeWindow = 12
#PB_Event_MaximizeWindow = 13
#PB_Event_RestoreWindow  = 14
#PB_Event_Timer          = 15
#PB_Event_RightClick       = 16
#PB_Event_LeftClick        = 17
#PB_Event_LeftDoubleClick  = 18
#PB_Event_None             = 0

; Event type
;
#PB_EventType_Change = $300
#PB_EventType_Focus = $100
#PB_EventType_LostFocus = $200
#PB_EventType_DragStart = $800

; Drag & Drop
;
CompilerIf Subsystem("qt")
  #PB_Drag_None = 0
  #PB_Drag_Copy = $1  ; matches Qt::DropAction
  #PB_Drag_Move = $2
  #PB_Drag_Link = $4
CompilerElse
  #PB_Drag_None = 0
  #PB_Drag_Copy = 1 << 1
  #PB_Drag_Move = 1 << 2
  #PB_Drag_Link = 1 << 3
CompilerEndIf

#PB_Drop_Text    = (-1)
#PB_Drop_Image   = (-2)
#PB_Drop_Files   = (-3)
#PB_Drop_Private = (-4)

#PB_Drag_Enter   = 1
#PB_Drag_Update  = 2
#PB_Drag_Leave   = 3
#PB_Drag_Finish  = 4

; Toolbar
;
#PB_ToolBarIcon_Copy = $1
#PB_ToolBarIcon_Cut = $0
#PB_ToolBarIcon_Delete = $5
#PB_ToolBarIcon_Find = $C
#PB_ToolBarIcon_Help = $B
#PB_ToolBarIcon_New = $6
#PB_ToolBarIcon_Open = $7
#PB_ToolBarIcon_Paste = $2
#PB_ToolBarIcon_Print = $E
#PB_ToolBarIcon_PrintPreview = $9
#PB_ToolBarIcon_Properties = $A
#PB_ToolBarIcon_Redo = $4
#PB_ToolBarIcon_Replace = $D
#PB_ToolBarIcon_Save = $8
#PB_ToolBarIcon_Undo = $3

#PB_ToolBar_Normal = 0
#PB_ToolBar_Toggle = 1


; For OpenSerialPort() 'Parity' parameter
;
#PB_SerialPort_NoParity    = 0
#PB_SerialPort_OddParity   = 1
#PB_SerialPort_EvenParity  = 2
#PB_SerialPort_MarkParity  = 3
#PB_SerialPort_SpaceParity = 4


; Keyboard
;
#PB_Key_All = -1




#PB_Key_Escape = $1B
#PB_Key_1 = $31
#PB_Key_2 = $32
#PB_Key_3 = $33
#PB_Key_4 = $34
#PB_Key_5 = $35
#PB_Key_6 = $36
#PB_Key_7 = $37
#PB_Key_8 = $38
#PB_Key_9 = $39
#PB_Key_0 = $30
#PB_Key_Minus           = $2D
#PB_Key_Equals          = $3D
#PB_Key_Back            = $08
#PB_Key_Tab             = $09
#PB_Key_Q               = $71
#PB_Key_W               = $77
#PB_Key_E               = $65
#PB_Key_R               = $72
#PB_Key_T               = $74
#PB_Key_Y               = $79
#PB_Key_U               = $75
#PB_Key_I               = $69
#PB_Key_O               = $6F
#PB_Key_P               = $70
#PB_Key_LeftBracket     = $5B
#PB_Key_RightBracket    = $5D
#PB_Key_Return          = $D
#PB_Key_LeftControl     =  306
#PB_Key_A               = $61
#PB_Key_S               = $73
#PB_Key_D               = $64
#PB_Key_F               = $66
#PB_Key_G               = $67
#PB_Key_H               = $68
#PB_Key_J               = $6A
#PB_Key_K               = $6B
#PB_Key_L               = $6C
#PB_Key_SemiColon       = $3B
#PB_Key_Apostrophe      = 0 ; NOT DONE
#PB_Key_Grave           = 0 ; NOT DONE
#PB_Key_LeftShift       = 304
#PB_Key_BackSlash       = $5C
#PB_Key_Z               = $7A
#PB_Key_X               = $78
#PB_Key_C               = $63
#PB_Key_V               = $76
#PB_Key_B               = $62
#PB_Key_N               = $6E
#PB_Key_M               = $6D
#PB_Key_Comma           = $2C
#PB_Key_Period          = $2E
#PB_Key_Slash           = $2F
#PB_Key_RightShift      =  303
#PB_Key_Multiply        = $10C ; Keypad
#PB_Key_LeftAlt         =  308
#PB_Key_Space           = $20
#PB_Key_Capital         = 0 ; NOT DONE
#PB_Key_F1 = $11A
#PB_Key_F2 = $11B
#PB_Key_F3 = $11C
#PB_Key_F4 = $11D
#PB_Key_F5 = $11E
#PB_Key_F6 = $11F
#PB_Key_F7 = $120
#PB_Key_F8 = $121
#PB_Key_F9 = $122
#PB_Key_F10 = $123
#PB_Key_NumLock         =  300
#PB_Key_Scroll          = 302 ; ScrollLock
#PB_Key_Pad7 = $107
#PB_Key_Pad8 = $108
#PB_Key_Pad9 = $109
#PB_Key_Subtract        = $10D ; Keypad
#PB_Key_Pad4 = $104
#PB_Key_Pad5 = $105
#PB_Key_Pad6 = $106
#PB_Key_Add             = $10E ; Keypad
#PB_Key_Pad1 = $101
#PB_Key_Pad2 = $102
#PB_Key_Pad3 = $103
#PB_Key_Pad0 = $100
#PB_Key_Decimal         = 0 ; NOT DONE
#PB_Key_F11 = $124
#PB_Key_F12 = $125
#PB_Key_PadEnter = $10F
#PB_Key_RightControl    =  305
#PB_Key_PadComma        = $10A
#PB_Key_Divide          = $10B
#PB_Key_RightAlt        =  307
#PB_Key_Pause           = $13
#PB_Key_Home            = $116
#PB_Key_Up              = $111
#PB_Key_PageUp          = $118
#PB_Key_Left            = $114
#PB_Key_Right           = $113
#PB_Key_End             = $117
#PB_Key_Down            = $112
#PB_Key_PageDown        = $119
#PB_Key_Insert          = $115
#PB_Key_Delete          = $7F


#PB_Shortcut_All     = -1

CompilerIf Subsystem("qt")

; Qt::Modifier aka Qt::KeyboardModifier defined in QtCore/qnamespace.h
;
#PB_Shortcut_Shift   = $02000000
#PB_Shortcut_Control = $04000000
#PB_Shortcut_Alt     = $08000000
#PB_Shortcut_Command = #PB_Shortcut_Control


; Qt::Key defined in QtCore/qnamespace.h
;
#PB_Shortcut_Back    = $01000003
#PB_Shortcut_Tab     = $01000001
#PB_Shortcut_Clear   = $0100000b
#PB_Shortcut_Return  = $01000004
#PB_Shortcut_Menu    = $01000055
#PB_Shortcut_Pause   = $01000008
#PB_Shortcut_Print   = $01000009
#PB_Shortcut_Capital = $01000024
#PB_Shortcut_Escape  = $01000000
#PB_Shortcut_Space   = $20
#PB_Shortcut_PageUp  = $01000016
#PB_Shortcut_PageDown= $01000017
#PB_Shortcut_End     = $01000011
#PB_Shortcut_Home    = $01000010
#PB_Shortcut_Left    = $01000012
#PB_Shortcut_Up      = $01000013
#PB_Shortcut_Right   = $01000014
#PB_Shortcut_Down    = $01000015
#PB_Shortcut_Select  = $01010000 ; = Key_Select.  Not sure about this
#PB_Shortcut_Execute = $01020003 ; = Key_Execute. Not sure about this
#PB_Shortcut_Snapshot= 0         ; Not defined in Qt and cannot be caught according to a quick internet search
#PB_Shortcut_Insert  = $01000006
#PB_Shortcut_Delete  = $01000007
#PB_Shortcut_Help    = $01000058
#PB_Shortcut_0= 48
#PB_Shortcut_1= 49
#PB_Shortcut_2= 50
#PB_Shortcut_3= 51
#PB_Shortcut_4= 52
#PB_Shortcut_5= 53
#PB_Shortcut_6= 54
#PB_Shortcut_7= 55
#PB_Shortcut_8= 56
#PB_Shortcut_9= 57
#PB_Shortcut_A= 65
#PB_Shortcut_B= 66
#PB_Shortcut_C= 67
#PB_Shortcut_D= 68
#PB_Shortcut_E= 69
#PB_Shortcut_F= 70
#PB_Shortcut_G= 71
#PB_Shortcut_H= 72
#PB_Shortcut_I= 73
#PB_Shortcut_J= 74
#PB_Shortcut_K= 75
#PB_Shortcut_L= 76
#PB_Shortcut_M= 77
#PB_Shortcut_N= 78
#PB_Shortcut_O= 79
#PB_Shortcut_P= 80
#PB_Shortcut_Q= 81
#PB_Shortcut_R= 82
#PB_Shortcut_S= 83
#PB_Shortcut_T= 84
#PB_Shortcut_U= 85
#PB_Shortcut_V= 86
#PB_Shortcut_W= 87
#PB_Shortcut_X= 88
#PB_Shortcut_Y= 89
#PB_Shortcut_Z= 90
#PB_Shortcut_LeftWindows= 0  ; Cannot find anything here
#PB_Shortcut_RightWindows= 0 ; Cannot find anything here
#PB_Shortcut_Apps = 0        ; Cannot find anything here
#PB_Shortcut_Pad0 = 48 | $20000000 ; Qt::KeypadModifier
#PB_Shortcut_Pad1 = 49 | $20000000
#PB_Shortcut_Pad2 = 50 | $20000000
#PB_Shortcut_Pad3 = 51 | $20000000
#PB_Shortcut_Pad4 = 52 | $20000000
#PB_Shortcut_Pad5 = 53 | $20000000
#PB_Shortcut_Pad6 = 54 | $20000000
#PB_Shortcut_Pad7 = 55 | $20000000
#PB_Shortcut_Pad8 = 56 | $20000000
#PB_Shortcut_Pad9 = 57 | $20000000
#PB_Shortcut_Multiply  = $2a ; TODO: do we need Qt::KeypadModifier here too?
#PB_Shortcut_Add       = $2b
#PB_Shortcut_Separator = $2c
#PB_Shortcut_Subtract  = $2d
#PB_Shortcut_Decimal   = $2e
#PB_Shortcut_Divide    = $2f
#PB_Shortcut_F1  = $01000030
#PB_Shortcut_F2  = $01000031
#PB_Shortcut_F3  = $01000032
#PB_Shortcut_F4  = $01000033
#PB_Shortcut_F5  = $01000034
#PB_Shortcut_F6  = $01000035
#PB_Shortcut_F7  = $01000036
#PB_Shortcut_F8  = $01000037
#PB_Shortcut_F9  = $01000038
#PB_Shortcut_F10 = $01000039
#PB_Shortcut_F11 = $0100003a
#PB_Shortcut_F12 = $0100003b
#PB_Shortcut_F13 = $0100003c
#PB_Shortcut_F14 = $0100003d
#PB_Shortcut_F15 = $0100003e
#PB_Shortcut_F16 = $0100003f
#PB_Shortcut_F17 = $01000040
#PB_Shortcut_F18 = $01000041
#PB_Shortcut_F19 = $01000042
#PB_Shortcut_F20 = $01000043
#PB_Shortcut_F21 = $01000044
#PB_Shortcut_F22 = $01000045
#PB_Shortcut_F23 = $01000046
#PB_Shortcut_F24 = $01000047
#PB_Shortcut_Numlock= $01000025
#PB_Shortcut_Scroll = $01000026

CompilerElse

#PB_Shortcut_Shift   = $10000
#PB_Shortcut_Control = $20000
#PB_Shortcut_Alt     = $40000
#PB_Shortcut_Command = #PB_Shortcut_Control

; GDK_xx definition, located in /usr/include/gtk-1.2/gdk/gdkkeysymbs.h
;
#PB_Shortcut_Back    = $FF08
#PB_Shortcut_Tab     = $FF09
#PB_Shortcut_Clear   = $FF0B
#PB_Shortcut_Return  = $FF0D
#PB_Shortcut_Menu    = 0     ; TODO
#PB_Shortcut_Pause   = $FF13
#PB_Shortcut_Print   = $FF61
#PB_Shortcut_Capital = 0     ; TODO
#PB_Shortcut_Escape  = $FF1B
#PB_Shortcut_Space   = $0020
#PB_Shortcut_PageUp  = $FF55
#PB_Shortcut_PageDown= $FF56
#PB_Shortcut_End     = $FF57
#PB_Shortcut_Home    = $FF50
#PB_Shortcut_Left    = $FF51
#PB_Shortcut_Up      = $FF52
#PB_Shortcut_Right   = $FF53
#PB_Shortcut_Down    = $FF54
#PB_Shortcut_Select  = $FF60
#PB_Shortcut_Execute = $FF62
#PB_Shortcut_Snapshot= 0      ; TODO
#PB_Shortcut_Insert  = $FF63
#PB_Shortcut_Delete  = $FFFF
#PB_Shortcut_Help    = $FF6A
#PB_Shortcut_0= 48
#PB_Shortcut_1= 49
#PB_Shortcut_2= 50
#PB_Shortcut_3= 51
#PB_Shortcut_4= 52
#PB_Shortcut_5= 53
#PB_Shortcut_6= 54
#PB_Shortcut_7= 55
#PB_Shortcut_8= 56
#PB_Shortcut_9= 57
#PB_Shortcut_A= 65
#PB_Shortcut_B= 66
#PB_Shortcut_C= 67
#PB_Shortcut_D= 68
#PB_Shortcut_E= 69
#PB_Shortcut_F= 70
#PB_Shortcut_G= 71
#PB_Shortcut_H= 72
#PB_Shortcut_I= 73
#PB_Shortcut_J= 74
#PB_Shortcut_K= 75
#PB_Shortcut_L= 76
#PB_Shortcut_M= 77
#PB_Shortcut_N= 78
#PB_Shortcut_O= 79
#PB_Shortcut_P= 80
#PB_Shortcut_Q= 81
#PB_Shortcut_R= 82
#PB_Shortcut_S= 83
#PB_Shortcut_T= 84
#PB_Shortcut_U= 85
#PB_Shortcut_V= 86
#PB_Shortcut_W= 87
#PB_Shortcut_X= 88
#PB_Shortcut_Y= 89
#PB_Shortcut_Z= 90
#PB_Shortcut_LeftWindows= $5B  ; TODO
#PB_Shortcut_RightWindows= $5C ; TODO
#PB_Shortcut_Apps = $5D        ; TODO
#PB_Shortcut_Pad0 = $FFB0
#PB_Shortcut_Pad1 = $FFB1
#PB_Shortcut_Pad2 = $FFB2
#PB_Shortcut_Pad3 = $FFB3
#PB_Shortcut_Pad4 = $FFB4
#PB_Shortcut_Pad5 = $FFB5
#PB_Shortcut_Pad6 = $FFB6
#PB_Shortcut_Pad7 = $FFB7
#PB_Shortcut_Pad8 = $FFB8
#PB_Shortcut_Pad9 = $FFB9
#PB_Shortcut_Multiply  = $FFAA
#PB_Shortcut_Add       = $FFAB
#PB_Shortcut_Separator = $FFAC
#PB_Shortcut_Subtract  = $FFAD
#PB_Shortcut_Decimal   = $FFAE
#PB_Shortcut_Divide    = $FFAF
#PB_Shortcut_F1  = $FFBE
#PB_Shortcut_F2  = $FFBF
#PB_Shortcut_F3  = $FFC0
#PB_Shortcut_F4  = $FFC1
#PB_Shortcut_F5  = $FFC2
#PB_Shortcut_F6  = $FFC3
#PB_Shortcut_F7  = $FFC4
#PB_Shortcut_F8  = $FFC5
#PB_Shortcut_F9  = $FFC6
#PB_Shortcut_F10 = $FFC7
#PB_Shortcut_F11 = $FFC8
#PB_Shortcut_F12 = $FFC9
#PB_Shortcut_F13 = $FFCA
#PB_Shortcut_F14 = $FFCB
#PB_Shortcut_F15 = $FFCC
#PB_Shortcut_F16 = $FFCD
#PB_Shortcut_F17 = $FFCE
#PB_Shortcut_F18 = $FFCF
#PB_Shortcut_F19 = $FFD0
#PB_Shortcut_F20 = $FFD1
#PB_Shortcut_F21 = $FFD2
#PB_Shortcut_F22 = $FFD3
#PB_Shortcut_F23 = $FFD4
#PB_Shortcut_F24 = $FFD5
#PB_Shortcut_Numlock= $FF7F
#PB_Shortcut_Scroll = $FF14 ; #define GDK_Scroll_Lock 0xFF14

CompilerEndIf

#PB_Input_Eof = Chr(10)+"EOF"+Chr(10) ; it is a string, so unicode mode affects it
