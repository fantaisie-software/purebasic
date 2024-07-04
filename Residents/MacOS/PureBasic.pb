﻿; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
;
; PureBasic OSX resident file
;

; General
;
IncludeFile "../Common.pb"

#LF$   = Chr(10)
#CR$   = Chr(13)
#CRLF$ = Chr(13) + Chr(10)
#LFCR$ = Chr(10) + Chr(13)
#TAB$  = Chr(9)
#ESC$  = Chr(27)


; Image lib
#PB_Image_Smooth = 0 ; ignored in the command, just for compatibility
#PB_Image_Raw = 1

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

#PB_DirectoryEntry_File      = 1
#PB_DirectoryEntry_Directory = 2

#PB_FileSystem_NoExtension = 1

; Font
;
#PB_Font_Bold        = 1
#PB_Font_Italic      = 2
#PB_Font_Underline   = 4
#PB_Font_StrikeOut   = 0 ; TODO
#PB_Font_HighQuality = 0 ; TODO

; OnError platform specific error codes
; See <sys/signal.h> (some are different than on Linux)
;
#PB_OnError_InvalidMemory          = 10 ; SIGBUS - OSX reports SIGBUS almost always instead of SIGSEGV
#PB_OnError_Floatingpoint          =  8 ; SIGFPE
#PB_OnError_Breakpoint             =  5 ; SIGTRAP
#PB_OnError_IllegalInstruction     =  4 ; SIGILL
#PB_OnError_PriviledgedInstruction = 12 ; SIGSYS
#PB_OnError_DivideByZero           = -1 ; Windows only, linux reports SIGFPE instead here


; Sort
;
#PB_Sort_Byte = 1
#PB_Sort_Word = 3
#PB_Sort_Long = 5
#PB_Sort_String = 8
#PB_Sort_Float = 9
#PB_Sort_Character = 11
#PB_Sort_Double = 12
#PB_Sort_Quad = 13

; Toolbar
;
#PB_ToolBar_Normal = 0
#PB_ToolBar_Toggle = 1

; Requester
;
#PB_MessageRequester_Ok          = 0
#PB_MessageRequester_YesNo       = 1 << 0
#PB_MessageRequester_YesNoCancel = 1 << 1
#PB_MessageRequester_Info        = 1 << 2
#PB_MessageRequester_Error       = 1 << 3
#PB_MessageRequester_Warning     = 1 << 4

; MessageRequester return value
#PB_MessageRequester_Yes    = 6
#PB_MessageRequester_No     = 7
#PB_MessageRequester_Cancel = 2

#PB_Requester_MultiSelection = 1

#PB_InputRequester_Password = 1

#PB_FontRequester_Effects = 1

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


; Menu
;
#PB_Menu_Preferences = -2
#PB_Menu_About = -3
#PB_Menu_Quit = -4


; StatusBar
;
#PB_StatusBar_Raised     = 1
#PB_StatusBar_BorderLess = 2
#PB_StatusBar_Center     = 4
#PB_StatusBar_Right      = 8

; For OpenSerialPort() 'Parity' parameter
;
#PB_SerialPort_NoParity    = 0
#PB_SerialPort_OddParity   = 1
#PB_SerialPort_EvenParity  = 2
#PB_SerialPort_MarkParity  = 3
#PB_SerialPort_SpaceParity = 4

; Gadget
;

; Colors
#PB_Gadget_FrontColor = 1
#PB_Gadget_BackColor  = 2
#PB_Gadget_LineColor  = 3
#PB_Gadget_TitleFrontColor = 4
#PB_Gadget_TitleBackColor  = 5
#PB_Gadget_GrayTextColor   = 6

#PB_Calendar_Minimum = 1
#PB_Calendar_Maximum = 2


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

#PB_Container_BorderLess = 0
#PB_Container_Flat       = 1
#PB_Container_Raised     = 2
#PB_Container_Single     = 4
#PB_Container_Double     = 8

#PB_Date_Calendar = 0  ; default
#PB_Date_UpDown   = $1 ;DTS_UPDOWN
#PB_Date_Minimum  = 1  ; for Get/SetGadgetAttribute
#PB_Date_Maximum  = 2
#PB_Date_CheckBox = $2 ;DTS_SHOWNONE

; Common Flags for all Explorer[...]Gadgets:
#PB_Explorer_NoMyDocuments       = 1 << 0

; Flags for ExplorerTreeGadget and ExplorerViewGadget:
#PB_Explorer_NoFiles             = 1 << 1
#PB_Explorer_NoDriveRequester    = 1 << 2
#PB_Explorer_AutoSort            = 1 << 3
#PB_Explorer_BorderLess          = 1 << 4
#PB_Explorer_AlwaysShowSelection = 1 << 5

; ExplorerList only Flags:
#PB_Explorer_NoParentFolder      = 1 << 6
#PB_Explorer_NoFolders           = 1 << 7
#PB_Explorer_NoDirectoryChange   = 1 << 8
#PB_Explorer_NoSort              = 1 << 9
#PB_Explorer_MultiSelect         = 1 << 10
#PB_Explorer_GridLines           = 1 << 11
#PB_Explorer_HeaderDragDrop      = 1 << 12
#PB_Explorer_FullRowSelect       = 1 << 13

; ExplorerTree only Flags:
#PB_Explorer_NoLines             = 1 << 14
#PB_Explorer_NoButtons           = 1 << 15

; ExplorerCombo only Flags:
#PB_Explorer_DrivesOnly          = 1 << 16
#PB_Explorer_Editable            = 1 << 17

; Common Flags for all Explorer[...]Gadgets:
#PB_Explorer_HiddenFiles         = 1 << 18

; Return values for Explorer:
#PB_Explorer_File             = 1
#PB_Explorer_Directory        = 2
#PB_Explorer_Selected         = 4

; Explorerlist standart columns:
#PB_Explorer_Name                = "PB_Explorer_Column_Name"
#PB_Explorer_Size                = "PB_Explorer_Column_Size"
#PB_Explorer_Type                = "PB_Explorer_Column_Type"
#PB_Explorer_Attributes          = "PB_Explorer_Column_Attributes"
#PB_Explorer_Created             = "PB_Explorer_Column_Created"
#PB_Explorer_Modified            = "PB_Explorer_Column_Modified"
#PB_Explorer_Accessed            = "PB_Explorer_Column_Accessed"

#PB_Explorer_ColumnWidth = 1 << 19


#PB_Editor_ReadOnly   = 1
#PB_Editor_WordWrap   = 2

#PB_Frame_Double   = 1
#PB_Frame_Single   = 2
#PB_Frame_Flat     = 3

#PB_Image_Border = 1 << 0
#PB_Image_Raised = 1 << 1


#PB_ListIcon_AlwaysShowSelection = 0 ; NOT SUPPORTED
#PB_ListIcon_FullRowSelect = 0       ; NOT SUPPORTED
#PB_ListIcon_MultiSelect = 1
#PB_ListIcon_CheckBoxes = 2
#PB_ListIcon_ThreeState = 8
#PB_ListIcon_GridLines = 16
#PB_ListIcon_HeaderDragDrop = 32

#PB_ListView_MultiSelect = 1
#PB_ListView_ClickSelect = 2 ; NOT SUPPORTED

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

#PB_Panel_ItemWidth  = 1
#PB_Panel_ItemHeight = 2
#PB_Panel_TabHeight  = 3

#PB_ProgressBar_Smooth = $0
#PB_ProgressBar_Vertical = $1

; Attributes
;
#PB_ProgressBar_Minimum = 1
#PB_ProgressBar_Maximum = 2

; Flags
;
#PB_ScrollArea_Flat = 1
#PB_ScrollArea_Raised = 2
#PB_ScrollArea_Single = 4
#PB_ScrollArea_BorderLess = 8
#PB_ScrollArea_Center = 16

; Attributes
;
#PB_ScrollArea_InnerWidth  = 1
#PB_ScrollArea_InnerHeight = 2
#PB_ScrollArea_X = 3
#PB_ScrollArea_Y = 4
#PB_ScrollArea_ScrollStep = 5

#PB_ScrollBar_Vertical = 1

; Attributes
;
#PB_ScrollBar_Minimum    = 1
#PB_ScrollBar_Maximum    = 2
#PB_ScrollBar_PageLength = 3

#PB_Splitter_Vertical  = 1
#PB_Splitter_Separator = 2
#PB_Splitter_FirstFixed = 4
#PB_Splitter_SecondFixed = 8

#PB_Splitter_FirstMinimumSize = 1
#PB_Splitter_SecondMinimumSize = 2
#PB_Splitter_FirstGadget = 3
#PB_Splitter_SecondGadget = 4

#PB_Editor_ReadOnly = 1
#PB_Editor_WordWrap = 2

#PB_String_BorderLess = $20
#PB_String_LowerCase = $8
#PB_String_Numeric = $10
#PB_String_Password = $1
#PB_String_ReadOnly = $2
#PB_String_UpperCase = $4

#PB_Text_Border = $4
#PB_Text_Center = $2
#PB_Text_Right = $1

#PB_TrackBar_Ticks = 1
#PB_TrackBar_Vertical = 2

#PB_TrackBar_Minimum = 1
#PB_TrackBar_Maximum = 2

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

#PB_Web_Back = $1
#PB_Web_Forward = $2
#PB_Web_Refresh = $4
#PB_Web_Stop = $3
#PB_Web_Mozilla = 0 ; Not supported on OS X, just ignore the constant

#PB_HyperLink_Underline = 1

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
#PB_Window_Normal					= 0        ; for Get/SetWindowState
#PB_Window_NoGadgets      = 1 << 12
#PB_Window_NoActivate     = 1 << 13

; For WindowX/Y/Width/Height()
;
#PB_Window_FrameCoordinate = 0
#PB_Window_InnerCoordinate = 1

; Flags
;
#PB_Spin_ReadOnly =  4
#PB_Spin_Numeric = 8

; Attributes
;
#PB_Spin_Minimum = 1
#PB_Spin_Maximum = 2

; Events
;
#PB_Event_None           = 0
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
#PB_Event_RightClick     = 16
#PB_Event_LeftClick      = 17
#PB_Event_LeftDoubleClick= 18

; Event type
;
#PB_EventType_Change = $300
#PB_EventType_Focus = $100
#PB_EventType_LostFocus = $200
#PB_EventType_DragStart = $800

; Drag & Drop
;
#PB_Drag_None = 0
#PB_Drag_Copy = 1
#PB_Drag_Move = 1 << 4
#PB_Drag_Link = 1 << 1

#PB_Drop_Text    = 1413830740
#PB_Drop_Image   = 1346978644
#PB_Drop_Files   = 1751544608
#PB_Drop_Private = 1885499492

#PB_Drag_Enter   = 1
#PB_Drag_Update  = 2
#PB_Drag_Leave   = 3
#PB_Drag_Finish  = 4


; Keyboard
;
#PB_Key_All = -1


CompilerIf Subsystem("carbon")

  ; On MacOS X Carbon, map on KeyCode, and use GetTranslatedKey() to get the mapped key.
  ;
  #PB_Key_Command = 254
  #PB_Key_Escape = 53
  #PB_Key_1 = 18
  #PB_Key_2 = 19
  #PB_Key_3 = 20
  #PB_Key_4 = 21
  #PB_Key_5 = 23
  #PB_Key_6 = 22
  #PB_Key_7 = 26
  #PB_Key_8 = 28
  #PB_Key_9 = 25
  #PB_Key_0 = 29
  #PB_Key_Minus           = 27
  #PB_Key_Equals          = 24
  #PB_Key_Back            = 51
  #PB_Key_Tab             = 48
  #PB_Key_Q               = 12
  #PB_Key_W               = 13
  #PB_Key_E               = 14
  #PB_Key_R               = 15
  #PB_Key_T               = 17
  #PB_Key_Y               = 16
  #PB_Key_U               = 32
  #PB_Key_I               = 34
  #PB_Key_O               = 31
  #PB_Key_P               = 35
  #PB_Key_LeftBracket     = -2
  #PB_Key_RightBracket    = -2
  #PB_Key_Return          = 36
  #PB_Key_LeftControl     = 251
  #PB_Key_A               = 0
  #PB_Key_S               = 1
  #PB_Key_D               = 2
  #PB_Key_F               = 3
  #PB_Key_G               = 5
  #PB_Key_H               = 4
  #PB_Key_J               = 38
  #PB_Key_K               = 40
  #PB_Key_L               = 37
  #PB_Key_SemiColon       = -2
  #PB_Key_Apostrophe      = -2
  #PB_Key_Grave           = -2
  #PB_Key_LeftShift       = 253
  #PB_Key_BackSlash       = -2
  #PB_Key_Z               = 6
  #PB_Key_X               = 7
  #PB_Key_C               = 8
  #PB_Key_V               = 9
  #PB_Key_B               = 11
  #PB_Key_N               = 45
  #PB_Key_M               = 46
  #PB_Key_Comma           = 43
  #PB_Key_Period          = 47
  #PB_Key_Slash           = 44
  #PB_Key_RightShift      = 253
  #PB_Key_Multiply        = 67 ; Keypad
  #PB_Key_LeftAlt         = 252
  #PB_Key_Space           = 49
  #PB_Key_Capital         = -2
  #PB_Key_F1 = 122
  #PB_Key_F2 = 120
  #PB_Key_F3 = 99
  #PB_Key_F4 = 118
  #PB_Key_F5 = 96
  #PB_Key_F6 = 97
  #PB_Key_F7 = 98
  #PB_Key_F8 = 100
  #PB_Key_F9 = -2
  #PB_Key_F10 = -2
  #PB_Key_NumLock  = -2
  #PB_Key_Scroll   = -2
  #PB_Key_Pad0     = 82
  #PB_Key_Pad1     = 83
  #PB_Key_Pad2     = 84
  #PB_Key_Pad3     = 85
  #PB_Key_Pad4     = 86
  #PB_Key_Pad5     = 87
  #PB_Key_Pad6     = 88
  #PB_Key_Pad7     = 89
  #PB_Key_Pad8     = 91
  #PB_Key_Pad9     = 92
  #PB_Key_Subtract = 78
  #PB_Key_Add      = 69 ; Keypad
  #PB_Key_Decimal  = -2
  #PB_Key_PadComma = 65
  #PB_Key_PadEnter = 76
  #PB_Key_F11 = -2
  #PB_Key_F12 = -2
  #PB_Key_RightControl    = 251
  #PB_Key_Divide          = 75 ; Keypad
  #PB_Key_RightAlt        = 252
  #PB_Key_Pause           = -2
  #PB_Key_Home            = 115
  #PB_Key_Up              = 126
  #PB_Key_PageUp          = 116
  #PB_Key_Left            = 123
  #PB_Key_Right           = 124
  #PB_Key_End             = 119
  #PB_Key_Down            = 125
  #PB_Key_PageDown        = 121
  #PB_Key_Insert          = 114
  #PB_Key_Delete          = 117

CompilerElse

  ; Use regular ASCII code
  #PB_Key_Back            = 127
  #PB_Key_Tab             = $09
  #PB_Key_Return          = $0D
  #PB_Key_Escape          = $1B
  #PB_Key_Left            = $1C
  #PB_Key_Right           = $1D
  #PB_Key_Up              = $1E
  #PB_Key_Down            = $1F
  #PB_Key_Space           = $20
  #PB_Key_Comma           = $2C
  #PB_Key_Period          = $2E
  #PB_Key_Slash           = $2F
  #PB_Key_0               = $30
  #PB_Key_1               = $31
  #PB_Key_2               = $32
  #PB_Key_3               = $33
  #PB_Key_4               = $34
  #PB_Key_5               = $35
  #PB_Key_6               = $36
  #PB_Key_7               = $37
  #PB_Key_8               = $38
  #PB_Key_9               = $39
  #PB_Key_LeftBracket     = $5B
  #PB_Key_RightBracket    = $5D
  #PB_Key_Minus           = $2D
  #PB_Key_Equals          = $3D
  #PB_Key_SemiColon       = $3B
  #PB_Key_BackSlash       = $5C
  #PB_Key_A               = $61
  #PB_Key_B               = $62
  #PB_Key_C               = $63
  #PB_Key_D               = $64
  #PB_Key_E               = $65
  #PB_Key_F               = $66
  #PB_Key_G               = $67
  #PB_Key_H               = $68
  #PB_Key_I               = $69
  #PB_Key_J               = $6A
  #PB_Key_K               = $6B
  #PB_Key_L               = $6C
  #PB_Key_M               = $6D
  #PB_Key_N               = $6E
  #PB_Key_O               = $6F
  #PB_Key_P               = $70
  #PB_Key_Q               = $71
  #PB_Key_R               = $72
  #PB_Key_S               = $73
  #PB_Key_T               = $74
  #PB_Key_U               = $75
  #PB_Key_V               = $76
  #PB_Key_W               = $77
  #PB_Key_X               = $78
  #PB_Key_Y               = $79
  #PB_Key_Z               = $7A

  #PB_Key_Pad0 = '0'
  #PB_Key_Pad1 = '1'
  #PB_Key_Pad2 = '2'
  #PB_Key_Pad3 = '3'
  #PB_Key_Pad4 = '4'
  #PB_Key_Pad5 = '5'
  #PB_Key_Pad6 = '6'
  #PB_Key_Pad7 = '7'
  #PB_Key_Pad8 = '8'
  #PB_Key_Pad9 = '9'

  #PB_Key_F1  = 128
  #PB_Key_F2  = 129
  #PB_Key_F3  = 130
  #PB_Key_F4  = 131
  #PB_Key_F5  = 132
  #PB_Key_F6  = 133
  #PB_Key_F7  = 134
  #PB_Key_F8  = 135
  #PB_Key_F9  = 136
  #PB_Key_F10 = 137
  #PB_Key_F11 = 138
  #PB_Key_F12 = 139

  #PB_Key_Command         = 140
  #PB_Key_LeftControl     = 141
  #PB_Key_RightControl    = 142
  #PB_Key_RightAlt        = 143
  #PB_Key_LeftAlt         = 144
  #PB_Key_LeftShift       = 145
  #PB_Key_RightShift      = 146

  #PB_Key_Scroll          = 150 ; ScrollLock
  #PB_Key_Pause           = 151
  #PB_Key_Home            = 152
  #PB_Key_PageUp          = 153
  #PB_Key_End             = 154
  #PB_Key_PageDown        = 155
  #PB_Key_Insert          = 156
  #PB_Key_Delete          = 157

  #PB_Key_Multiply        = '*' ; Keypad
  #PB_Key_Subtract        = '-' ; Keypad
  #PB_Key_Add             = '+' ; Keypad
  #PB_Key_PadComma        = ',' ; Keypad
  #PB_Key_Divide          = '/' ; Keypad
  #PB_Key_PadEnter        = 13
  #PB_Key_Grave           = '`'

  #PB_Key_NumLock         = 0 ; NOT DONE
  #PB_Key_Decimal         = 0 ; NOT DONE
  #PB_Key_Apostrophe      = 0 ; NOT DONE
  #PB_Key_Capital         = 0 ; NOT DONE

CompilerEndIf



#PB_Shortcut_All     = -1

#PB_Shortcut_Shift   = $10000
#PB_Shortcut_Control = $20000
#PB_Shortcut_Alt     = $40000
#PB_Shortcut_Command = $80000

;
;
#PB_Shortcut_Back    = 8
#PB_Shortcut_Tab     = 9
#PB_Shortcut_Clear   = 127
#PB_Shortcut_Return  = 13
#PB_Shortcut_Menu    = 0
#PB_Shortcut_Pause   = 0
#PB_Shortcut_Print   = 0
#PB_Shortcut_Capital = 0
#PB_Shortcut_Escape  = 27
#PB_Shortcut_Space   = 32
#PB_Shortcut_PageUp  = 11
#PB_Shortcut_PageDown= 12
#PB_Shortcut_End     = 4
#PB_Shortcut_Home    = 1
#PB_Shortcut_Left    = 28
#PB_Shortcut_Up      = 30
#PB_Shortcut_Right   = 29
#PB_Shortcut_Down    = 31
#PB_Shortcut_Select  = 0
#PB_Shortcut_Execute = 0
#PB_Shortcut_Snapshot= 0
#PB_Shortcut_Insert  = 5
#PB_Shortcut_Delete  = 127
#PB_Shortcut_Help    = 0
#PB_Shortcut_0 = 48
#PB_Shortcut_1 = 49
#PB_Shortcut_2 = 50
#PB_Shortcut_3 = 51
#PB_Shortcut_4 = 52
#PB_Shortcut_5 = 53
#PB_Shortcut_6 = 54
#PB_Shortcut_7 = 55
#PB_Shortcut_8 = 56
#PB_Shortcut_9 = 57
#PB_Shortcut_A = 97
#PB_Shortcut_B = 98
#PB_Shortcut_C = 99
#PB_Shortcut_D = 100
#PB_Shortcut_E = 101
#PB_Shortcut_F = 102
#PB_Shortcut_G = 103
#PB_Shortcut_H = 104
#PB_Shortcut_I = 105
#PB_Shortcut_J = 106
#PB_Shortcut_K = 107
#PB_Shortcut_L = 108
#PB_Shortcut_M = 109
#PB_Shortcut_N = 110
#PB_Shortcut_O = 111
#PB_Shortcut_P = 112
#PB_Shortcut_Q = 113
#PB_Shortcut_R = 114
#PB_Shortcut_S = 115
#PB_Shortcut_T = 116
#PB_Shortcut_U = 117
#PB_Shortcut_V = 118
#PB_Shortcut_W = 119
#PB_Shortcut_X = 120
#PB_Shortcut_Y = 121
#PB_Shortcut_Z = 122
#PB_Shortcut_LeftWindows  = 0
#PB_Shortcut_RightWindows = 0
#PB_Shortcut_Apps = 0
#PB_Shortcut_Pad0 = 130
#PB_Shortcut_Pad1 = 131
#PB_Shortcut_Pad2 = 132
#PB_Shortcut_Pad3 = 133
#PB_Shortcut_Pad4 = 134
#PB_Shortcut_Pad5 = 135
#PB_Shortcut_Pad6 = 136
#PB_Shortcut_Pad7 = 137
#PB_Shortcut_Pad8 = 138
#PB_Shortcut_Pad9 = 139
#PB_Shortcut_Multiply  = 42
#PB_Shortcut_Add       = 43
#PB_Shortcut_Separator = 0
#PB_Shortcut_Subtract  = 45
#PB_Shortcut_Decimal   = 44
#PB_Shortcut_Divide    = 47
#PB_Shortcut_F1  = 122 + $100 ; KeyCode
#PB_Shortcut_F2  = 120 + $100 ; KeyCode
#PB_Shortcut_F3  = 99  + $100 ; KeyCode
#PB_Shortcut_F4  = 118 + $100 ; KeyCode
#PB_Shortcut_F5  = 96  + $100 ; KeyCode
#PB_Shortcut_F6  = 97  + $100 ; KeyCode
#PB_Shortcut_F7  = 98  + $100 ; KeyCode
#PB_Shortcut_F8  = 100 + $100 ; KeyCode
#PB_Shortcut_F9  = 101 + $100 ; KeyCode
#PB_Shortcut_F10 = 109 + $100 ; KeyCode
#PB_Shortcut_F11 = 103 + $100 ; KeyCode
#PB_Shortcut_F12 = 111 + $100 ; KeyCode
#PB_Shortcut_F13 = 0
#PB_Shortcut_F14 = 0
#PB_Shortcut_F15 = 0
#PB_Shortcut_F16 = 0
#PB_Shortcut_F17 = 0
#PB_Shortcut_F18 = 0
#PB_Shortcut_F19 = 0
#PB_Shortcut_F20 = 0
#PB_Shortcut_F21 = 0
#PB_Shortcut_F22 = 0
#PB_Shortcut_F23 = 0
#PB_Shortcut_F24 = 0
#PB_Shortcut_Numlock= 27
#PB_Shortcut_Scroll = 0 ; Not supported on OS X

#PB_Input_Eof = Chr(10)+"EOF"+Chr(10) ; it is a string, so unicode mode affects it
