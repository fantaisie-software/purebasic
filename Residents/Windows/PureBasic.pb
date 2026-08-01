; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; General
;
;
IncludeFile "..\Common.pb"


#PB_ProcessPureBasicEvents = -$1F1F1F1F

; SetWindowCallback()
;
#PB_Window_ProcessChildEvents = 0
#PB_Window_NoChildEvents      = 1

; Clipboard
;
#PB_Clipboard_Image = 8 ; CF_DIB


; Font
;
#PB_Font_Bold        = $100
#PB_Font_Italic      = $200
#PB_Font_Underline   = 1 << 2
#PB_Font_StrikeOut   = 1 << 3
#PB_Font_HighQuality = 1 << 4

; Image
;
#PB_Image_Smooth = 0
#PB_Image_Raw    = 1


; OnError platform specific error codes
; See <WinBase.h> and <WinNT.h>
;
#PB_OnError_InvalidMemory          = $C0000005 ; EXCEPTION_ACCESS_VIOLATION
#PB_OnError_Floatingpoint          = $C0000090 ; EXCEPTION_FLT_INVALID_OPERATION
#PB_OnError_Breakpoint             = $80000003 ; EXCEPTION_BREAKPOINT
#PB_OnError_IllegalInstruction     = $C000001D ; EXCEPTION_ILLEGAL_INSTRUCTION
#PB_OnError_PriviledgedInstruction = $C0000096 ; EXCEPTION_PRIV_INSTRUCTION
#PB_OnError_DivideByZero           = $C0000094 ; EXCEPTION_INT_DIVIDE_BY_ZERO

; ToolBar
;
#PB_ToolBar_Normal = 0
#PB_ToolBar_Toggle = 1

; StatusBar
;
#PB_StatusBar_Raised     = 1
#PB_StatusBar_BorderLess = 2
#PB_StatusBar_Center     = 4
#PB_StatusBar_Right      = 8

; Non-common MessageRequester flags
;
#PB_MessageRequester_Ok          = 0
#PB_MessageRequester_YesNo       = 4
#PB_MessageRequester_YesNoCancel = 3
#PB_MessageRequester_Info    = $40
#PB_MessageRequester_Error   = $10
#PB_MessageRequester_Warning = $30

#PB_FontRequester_Effects = 256 ; #CF_EFFECTS

; RunProgram
;

#PB_Program_Wait    = 1 << 0
#PB_Program_Hide    = 1 << 1
#PB_Program_Open    = 1 << 2
#PB_Program_Read    = 1 << 3
#PB_Program_Write   = 1 << 4
#PB_Program_Error   = 1 << 5
#PB_Program_Connect = 1 << 6
#PB_Program_Ascii   = 1 << 7
#PB_Program_UTF8    = 1 << 8
#PB_Program_Unicode = 1 << 9


#PB_Program_Eof = 1 ; for WriteProgramData()

; Event constants
;
#PB_Event_Gadget           = 13100
#PB_Event_Menu             = 13101
#PB_Event_SysTray          = 13102
#PB_Event_ActivateWindow   = 13104 ; 13103 is reserved for our private gadget message id
#PB_Event_MinimizeWindow   = 13107
#PB_Event_MaximizeWindow   = 13108
#PB_Event_RestoreWindow    = 13109
#PB_Event_Timer            = 13110
#PB_Event_RightClick       = 13111
#PB_Event_LeftClick        = 13112
#PB_Event_LeftDoubleClick  = 13113
#PB_Event_DeactivateWindow = 13114
#PB_Event_Repaint          = 13115
#PB_Event_CloseWindow      = 13116
#PB_Event_MoveWindow       = 13117
#PB_Event_SizeWindow       = 13118
#PB_Event_None             = 0

;
; Network related one
;
#PB_Event_ClientConnected    = 1
#PB_Event_DataReceived       = 2
#PB_Event_FileReceived       = 3
#PB_Event_ClientDisconnected = 4


; Specific EventType
;
#PB_EventType_Focus             = 14000 ; PB reserved value
#PB_EventType_LostFocus         = 14001 ; PB reserved value
#PB_EventType_Change            = 768

; Window flags
;

#PB_Window_ScreenCentered = $1 ; pb specific values
#PB_Window_WindowCentered = $2
#PB_Window_Tool           = $4
#PB_Window_TitleBar       = $C00000 ; WS_BORDER | WS_DLGFRAME
#PB_Window_SystemMenu     = $80000 | #PB_Window_TitleBar ; WS_SYSMENU
#PB_Window_SizeGadget     = $40000 | #PB_Window_TitleBar ; WS_SIZEBOX
#PB_Window_MinimizeGadget = $20000 | #PB_Window_TitleBar | #PB_Window_SystemMenu ; WS_MINIMIZEBOX
#PB_Window_MaximizeGadget = $10000 | #PB_Window_TitleBar | #PB_Window_SystemMenu ; WS_MAXIMIZEBOX
#PB_Window_Invisible      = $10000000 ; WS_VISIBLE
#PB_Window_BorderLess     = $80000000 ; WS_POPUP
#PB_Window_NoGadgets      = $8
#PB_Window_NoActivate     = $2000000

; For WindowX/Y/Width/Height()
;
#PB_Window_FrameCoordinate = 0
#PB_Window_InnerCoordinate = 1

; Window states
;
#PB_Window_Normal   = 0
#PB_Window_Maximize = $1000000 ; #WS_MAXIMIZE
#PB_Window_Minimize = $20000000 ; #WS_MINIMIZE

; FileSystem
;
#PB_FileSystem_Archive    = 32   ; #FILE_ATTRIBUTE_ARCHIVE
#PB_FileSystem_Compressed = 2048 ; #FILE_ATTRIBUTE_COMPRESSED
#PB_FileSystem_Hidden     = 2    ; #FILE_ATTRIBUTE_HIDDEN
#PB_FileSystem_Normal     = 128  ; #FILE_ATTRIBUTE_NORMAL
#PB_FileSystem_ReadOnly   = 1    ; #FILE_ATTRIBUTE_READONLY
#PB_FileSystem_System     = 4    ; #FILE_ATTRIBUTE_SYSTEM

#PB_FileSystem_Recursive  = 1
#PB_FileSystem_Force      = 2

#PB_DirectoryEntry_File      = 1
#PB_DirectoryEntry_Directory = 2

#PB_FileSystem_NoExtension = 1

; Used by Get/SetFileDate() and DirectoryEntryDate()
;
#PB_Date_Created  = 0
#PB_Date_Accessed = 1
#PB_Date_Modified = 2

#PB_Button_Right     = 512
#PB_Button_Left      = 256
#PB_Button_Default   = 1
#PB_Button_MultiLine = $2000
#PB_Button_Toggle    = 3 | 4096

; for buttonimage
#PB_Button_Image = 1
#PB_Button_PressedImage = 2

#PB_Calendar_Borderless = $800000 ; WS_BORDER

#PB_Calendar_Minimum    = 1 ; Attributes
#PB_Calendar_Maximum    = 2
#PB_Calendar_Bold       = 1
#PB_Calendar_Normal     = 0

#PB_CheckBox_Right      = 512
#PB_CheckBox_Center     = $300
#PB_CheckBox_ThreeState = 5    ; #BS_3STATE

#PB_ComboBox_Editable  = 2 | 64  ; #CBS_DROPDOWN | #CBS_AUTOHSCROLL
#PB_ComboBox_LowerCase = $4000   ; #CBS_LOWERCASE
#PB_ComboBox_UpperCase = $2000   ; #CBS_UPPERCASE
#PB_ComboBox_Image     = $10000000 ; #WS_VISIBLE (reused for this flag)

#PB_Date_Calendar = 0  ; default
#PB_Date_UpDown   = $1 ;DTS_UPDOWN
#PB_Date_CheckBox = $2 ;DTS_SHOWNONE

#PB_Date_Minimum  = 1  ; for Get/SetGadgetAttribute
#PB_Date_Maximum  = 2

; Explorerlist standart columns:
#PB_Explorer_Name                = "PB_Explorer_Column_Name"
#PB_Explorer_Size                = "PB_Explorer_Column_Size"
#PB_Explorer_Type                = "PB_Explorer_Column_Type"
#PB_Explorer_Attributes          = "PB_Explorer_Column_Attributes"
#PB_Explorer_Created             = "PB_Explorer_Column_Created"
#PB_Explorer_Modified            = "PB_Explorer_Column_Modified"
#PB_Explorer_Accessed            = "PB_Explorer_Column_Accessed"

#PB_ListView_MultiSelect = $800 ; #LBS_EXTENDEDSEL
#PB_ListView_ClickSelect = $8   ; #LBS_MULTIPLESEL

; ListIcon flags
#PB_ListIcon_CheckBoxes          = $1        ; #LVS_REPORT
#PB_ListIcon_MultiSelect         = $4        ; #LVS_SINGLESEL 
#PB_ListIcon_GridLines           = $10000    ; #WS_TABSTOP    
#PB_ListIcon_FullRowSelect       = $40000000 ; #WS_CHILD      
#PB_ListIcon_HeaderDragDrop      = $10000000 ; #WS_VISIBLE    
#PB_ListIcon_AlwaysShowSelection = $8        ; #LVS_SHOWSELALWAYS
#PB_ListIcon_ThreeState          = $40       ; #LVS_SHAREIMAGELISTS
#PB_ListIcon_NoHeaders           = $4000     ; #LVS_NOCOLUMNHEADER

#PB_MDI_BorderLess              = $00000001 ; Flags
#PB_MDI_AutoSize                = $00000002
#PB_MDI_NoScrollBars            = $00000004

#PB_MDI_Cascade                 = -1 ; Item States
#PB_MDI_TileVertically          = -2
#PB_MDI_TileHorizontally        = -3
#PB_MDI_Next                    = -4
#PB_MDI_Previous                = -5
#PB_MDI_Arrange                 = -6

#PB_MDI_Image     = 3 ; Attributes
#PB_MDI_TileImage = 4

#PB_Spin_ReadOnly = 1 ; Flags
#PB_Spin_Numeric  = 2

#PB_Spin_Minimum = 1 ; Attributes
#PB_Spin_Maximum = 2

; String Flags
#PB_String_Password    = $20       ; ES_PASSWORD
#PB_String_ReadOnly    = $800      ; ES_READONLY 
#PB_String_LowerCase   = $10       ; ES_LOWERCASE
#PB_String_UpperCase   = $8        ; ES_UPPERCASE
#PB_String_Numeric     = $2000     ; ES_NUMBER
#PB_String_BorderLess  = $20000    ; WS_GROUP  
#PB_String_PlaceHolder = $10000000 ; WS_VISIBLE

#PB_Tree_AlwaysShowSelection = 32
#PB_Tree_NoLines     = 2
#PB_Tree_NoButtons   = 1
#PB_Tree_CheckBoxes  = $100
#PB_Tree_ThreeState  = $10000 ; WS_TABSTOP reused

#PB_Tree_SubLevel = 1 ; Attribute

#PB_Tree_Selected = 1
#PB_Tree_Expanded = 2
#PB_Tree_Checked = 4
#PB_Tree_Collapsed = 8
#PB_Tree_Inbetween = 16

#PB_Image_Raised = 1
#PB_Image_Border = $200

#PB_ProgressBar_Smooth   = 1
#PB_ProgressBar_Vertical = 4

#PB_ProgressBar_Minimum  = 1  ; Attributes
#PB_ProgressBar_Maximum  = 2

#PB_Text_Center = 1
#PB_Text_Right  = 2
#PB_Text_Border = $20000

; DragDrop lib
;
#PB_EventType_DragStart = 14002
#PB_Event_WindowDrop = 13105
#PB_Event_GadgetDrop = 13106

#PB_Drop_Text    = 1; #CF_TEXT
#PB_Drop_Image   = 8; #CF_DIB
#PB_Drop_Files   = 15; #CF_HDROP
#PB_Drop_Private = 512; #CF_PRIVATEFIRST

#PB_Drag_None    = 0; #DROPEFFECT_NONE
#PB_Drag_Copy    = 1; #DROPEFFECT_COPY
#PB_Drag_Move    = 2; #DROPEFFECT_MOVE
#PB_Drag_Link    = 4; #DROPEFFECT_LINK

#PB_Drag_Enter   = 1
#PB_Drag_Update  = 2
#PB_Drag_Leave   = 3
#PB_Drag_Finish  = 4


; For OpenSerialPort() 'Parity' parameter
;
#PB_SerialPort_NoParity    = 0 ; #NOPARITY
#PB_SerialPort_OddParity   = 1 ; #ODDPARITY
#PB_SerialPort_EvenParity  = 2 ; #EVENPARITY
#PB_SerialPort_MarkParity  = 3 ; #MARKPARITY
#PB_SerialPort_SpaceParity = 4 ; #SPACEPARITY

; Keyboard key
;

#PB_Key_All             = -1

#PB_Key_Escape          = $01
#PB_Key_1               = $02
#PB_Key_2               = $03
#PB_Key_3               = $04
#PB_Key_4               = $05
#PB_Key_5               = $06
#PB_Key_6               = $07
#PB_Key_7               = $08
#PB_Key_8               = $09
#PB_Key_9               = $0A
#PB_Key_0               = $0B
#PB_Key_Minus           = $0C
#PB_Key_Equals          = $0D
#PB_Key_Back            = $0E
#PB_Key_Tab             = $0F
#PB_Key_Q               = $10
#PB_Key_W               = $11
#PB_Key_E               = $12
#PB_Key_R               = $13
#PB_Key_T               = $14
#PB_Key_Y               = $15
#PB_Key_U               = $16
#PB_Key_I               = $17
#PB_Key_O               = $18
#PB_Key_P               = $19
#PB_Key_LeftBracket     = $1A
#PB_Key_RightBracket    = $1B
#PB_Key_Return          = $1C
#PB_Key_LeftControl     = $1D
#PB_Key_A               = $1E
#PB_Key_S               = $1F
#PB_Key_D               = $20
#PB_Key_F               = $21
#PB_Key_G               = $22
#PB_Key_H               = $23
#PB_Key_J               = $24
#PB_Key_K               = $25
#PB_Key_L               = $26
#PB_Key_SemiColon       = $27
#PB_Key_Apostrophe      = $28
#PB_Key_Grave           = $29
#PB_Key_LeftShift       = $2A
#PB_Key_BackSlash       = $2B
#PB_Key_Z               = $2C
#PB_Key_X               = $2D
#PB_Key_C               = $2E
#PB_Key_V               = $2F
#PB_Key_B               = $30
#PB_Key_N               = $31
#PB_Key_M               = $32
#PB_Key_Comma           = $33
#PB_Key_Period          = $34
#PB_Key_Slash           = $35
#PB_Key_RightShift      = $36
#PB_Key_Multiply        = $37
#PB_Key_LeftAlt         = $38
#PB_Key_Space           = $39
#PB_Key_Capital         = $3A
#PB_Key_F1              = $3B
#PB_Key_F2              = $3C
#PB_Key_F3              = $3D
#PB_Key_F4              = $3E
#PB_Key_F5              = $3F
#PB_Key_F6              = $40
#PB_Key_F7              = $41
#PB_Key_F8              = $42
#PB_Key_F9              = $43
#PB_Key_F10             = $44
#PB_Key_NumLock         = $45
#PB_Key_Scroll          = $46
#PB_Key_Pad7            = $47
#PB_Key_Pad8            = $48
#PB_Key_Pad9            = $49
#PB_Key_Subtract        = $4A
#PB_Key_Pad4            = $4B
#PB_Key_Pad5            = $4C
#PB_Key_Pad6            = $4D
#PB_Key_Add             = $4E
#PB_Key_Pad1            = $4F
#PB_Key_Pad2            = $50
#PB_Key_Pad3            = $51
#PB_Key_Pad0            = $52
#PB_Key_Decimal         = $53
#PB_Key_F11             = $57
#PB_Key_F12             = $58
#PB_Key_PadEnter        = $9C
#PB_Key_RightControl    = $9D
#PB_Key_PadComma        = $B3
#PB_Key_Divide          = $B5
#PB_Key_RightAlt        = $B8
#PB_Key_Pause           = $C5
#PB_Key_Home            = $C7
#PB_Key_Up              = $C8
#PB_Key_PageUp          = $C9
#PB_Key_Left            = $CB
#PB_Key_Right           = $CD
#PB_Key_End             = $CF
#PB_Key_Down            = $D0
#PB_Key_PageDown        = $D1
#PB_Key_Insert          = $D2
#PB_Key_Delete          = $D3


#PB_Shortcut_All     = -1

#PB_Shortcut_Shift   = $10000
#PB_Shortcut_Control = $20000
#PB_Shortcut_Alt     = $40000
#PB_Shortcut_Command = #PB_Shortcut_Control

#PB_Shortcut_Back     = 8
#PB_Shortcut_Tab     = 9
#PB_Shortcut_Clear   = 12
#PB_Shortcut_Return   = 13
#PB_Shortcut_Menu     = 18
#PB_Shortcut_Pause   =19
#PB_Shortcut_Print =42
#PB_Shortcut_Capital= 20
#PB_Shortcut_Escape= 27
#PB_Shortcut_Space= 32
#PB_Shortcut_PageUp= 33
#PB_Shortcut_PageDown= 34
#PB_Shortcut_End= 35
#PB_Shortcut_Home= 36
#PB_Shortcut_Left= 37
#PB_Shortcut_Up =38
#PB_Shortcut_Right= 39
#PB_Shortcut_Down =40
#PB_Shortcut_Select= 41
#PB_Shortcut_Execute= 43
#PB_Shortcut_Snapshot= 44
#PB_Shortcut_Insert= 45
#PB_Shortcut_Delete= 46
#PB_Shortcut_Help= 47
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
#PB_Shortcut_LeftWindows= $5B
#PB_Shortcut_RightWindows= $5C
#PB_Shortcut_Apps= $5D
#PB_Shortcut_Pad0= 96
#PB_Shortcut_Pad1= 97
#PB_Shortcut_Pad2= 98
#PB_Shortcut_Pad3= 99
#PB_Shortcut_Pad4= 100
#PB_Shortcut_Pad5= 101
#PB_Shortcut_Pad6= 102
#PB_Shortcut_Pad7= 103
#PB_Shortcut_Pad8= 104
#PB_Shortcut_Pad9= 105
#PB_Shortcut_Multiply= 106
#PB_Shortcut_Add= 107
#PB_Shortcut_Separator= 108
#PB_Shortcut_Subtract= 109
#PB_Shortcut_Decimal =110
#PB_Shortcut_Divide= 111
#PB_Shortcut_F1= 112
#PB_Shortcut_F2= 113
#PB_Shortcut_F3= 114
#PB_Shortcut_F4= 115
#PB_Shortcut_F5= 116
#PB_Shortcut_F6= 117
#PB_Shortcut_F7= 118
#PB_Shortcut_F8= 119
#PB_Shortcut_F9= 120
#PB_Shortcut_F10= 121
#PB_Shortcut_F11= 122
#PB_Shortcut_F12= 123
#PB_Shortcut_F13= 124
#PB_Shortcut_F14= 125
#PB_Shortcut_F15= 126
#PB_Shortcut_F16= 127
#PB_Shortcut_F17= 128
#PB_Shortcut_F18= 129
#PB_Shortcut_F19= 130
#PB_Shortcut_F20= 131
#PB_Shortcut_F21= 132
#PB_Shortcut_F22= 133
#PB_Shortcut_F23= 134
#PB_Shortcut_F24= 135
#PB_Shortcut_Numlock= 144
#PB_Shortcut_Scroll =145
;

#PB_Input_Eof = Chr(4) ; end of file character for Input()
