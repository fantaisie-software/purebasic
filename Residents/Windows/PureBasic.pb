﻿;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

; General
;
;
IncludeFile "..\Common.pb"


#PB_ProcessPureBasicEvents = -$1F1F1F1F

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



; ToolBar icon definitions
;

#PB_ToolBarIcon_Cut    = 0
#PB_ToolBarIcon_Copy   = 1
#PB_ToolBarIcon_Paste  = 2
#PB_ToolBarIcon_Undo   = 3
#PB_ToolBarIcon_Redo   = 4
#PB_ToolBarIcon_Delete = 5
#PB_ToolBarIcon_New    = 6
#PB_ToolBarIcon_Open   = 7
#PB_ToolBarIcon_Save   = 8
#PB_ToolBarIcon_PrintPreview = 9
#PB_ToolBarIcon_Properties   = 10
#PB_ToolBarIcon_Help    = 11
#PB_ToolBarIcon_Find    = 12
#PB_ToolBarIcon_Replace = 13
#PB_ToolBarIcon_Print   = 14

#PB_ToolBar_Normal = 0
#PB_ToolBar_Toggle = 1

; StatusBar
;

#PB_StatusBar_Raised     = 1
#PB_StatusBar_BorderLess = 2
#PB_StatusBar_Center     = 4
#PB_StatusBar_Right      = 8

; MessageRequester flags
;
#PB_MessageRequester_Ok          = 0
#PB_MessageRequester_YesNo       = 4
#PB_MessageRequester_YesNoCancel = 3
#PB_MessageRequester_Info    = $40
#PB_MessageRequester_Error   = $10
#PB_MessageRequester_Warning = $30

; MessageRequester return value
#PB_MessageRequester_Yes    = 6
#PB_MessageRequester_No     = 7
#PB_MessageRequester_Cancel = 2


#PB_Requester_MultiSelection = 1

#PB_InputRequester_Password = 1

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


; EventType
;
#PB_EventType_Focus             = 14000 ; PB reserved value
#PB_EventType_LostFocus         = 14001 ; PB reserved value
#PB_EventType_Change            = 768
#PB_EventType_LeftClick         = 0
#PB_EventType_RightClick        = 1
#PB_EventType_LeftDoubleClick   = 2
#PB_EventType_RightDoubleClick  = 3
#PB_EventType_Up                = 4
#PB_EventType_Down              = 5
#PB_EventType_Resize            = 6

#PB_EventType_SizeItem   = $FFFE  ; for MDIGadget
#PB_EventType_CloseItem  = $FFFF  ; for MDIGadget

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


; Colors
#PB_Gadget_FrontColor = 1
#PB_Gadget_BackColor  = 2
#PB_Gadget_LineColor  = 3
#PB_Gadget_TitleFrontColor = 4
#PB_Gadget_TitleBackColor  = 5
#PB_Gadget_GrayTextColor   = 6

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

#PB_Container_BorderLess = 0
#PB_Container_Flat       = 1
#PB_Container_Raised     = 2
#PB_Container_Single     = 4
#PB_Container_Double     = 8

#PB_Date_Calendar = 0  ; default
#PB_Date_UpDown   = $1 ;DTS_UPDOWN
#PB_Date_CheckBox = $2 ;DTS_SHOWNONE

#PB_Date_Minimum  = 1  ; for Get/SetGadgetAttribute
#PB_Date_Maximum  = 2

; Common Flags for all Explorer[...]Gadgets:
#PB_Explorer_NoMyDocuments       = $00000200
#PB_Explorer_HiddenFiles         = $00000400

; Flags for ExplorerTreeGadget and ExplorerViewGadget:
#PB_Explorer_NoFiles             = $00000001
#PB_Explorer_NoDriveRequester    = $00000010
#PB_Explorer_AutoSort            = $00000040
#PB_Explorer_BorderLess          = $00100000
#PB_Explorer_AlwaysShowSelection = $01000000

; ExplorerList only Flags:
#PB_Explorer_NoParentFolder      = $00000002
#PB_Explorer_NoFolders           = $00000004
#PB_Explorer_NoDirectoryChange   = $00000008
#PB_Explorer_NoSort              = $00000020
#PB_Explorer_MultiSelect         = $00200000
#PB_Explorer_GridLines           = $00400000
#PB_Explorer_HeaderDragDrop      = $00800000
#PB_Explorer_FullRowSelect       = $02000000

; ExplorerTree only Flags:
#PB_Explorer_NoLines             = $04000000
#PB_Explorer_NoButtons           = $08000000

; ExplorerCombo only Flags:
#PB_Explorer_DrivesOnly          = $00000080
#PB_Explorer_Editable            = $00000100

; Return values for Explorer:
#PB_Explorer_None                = $0
#PB_Explorer_File                = $1
#PB_Explorer_Directory           = $2
#PB_Explorer_Selected            = $4

; Explorerlist standart columns:
#PB_Explorer_Name                = "PB_Explorer_Column_Name"
#PB_Explorer_Size                = "PB_Explorer_Column_Size"
#PB_Explorer_Type                = "PB_Explorer_Column_Type"
#PB_Explorer_Attributes          = "PB_Explorer_Column_Attributes"
#PB_Explorer_Created             = "PB_Explorer_Column_Created"
#PB_Explorer_Modified            = "PB_Explorer_Column_Modified"
#PB_Explorer_Accessed            = "PB_Explorer_Column_Accessed"

#PB_Explorer_ColumnWidth = 1

; Editor
#PB_Editor_ReadOnly = $800      ; ES_READONLY
#PB_Editor_WordWrap = $10000000 ; WS_VISIBLE

#PB_Frame_Double   = 1
#PB_Frame_Single   = 2
#PB_Frame_Flat     = 3

#PB_ListIcon_Selected  = 1
#PB_ListIcon_Checked   = 2
#PB_ListIcon_Inbetween = 4

#PB_ListIcon_ColumnWidth = 1

#PB_ListView_MultiSelect = $800 ; #LBS_EXTENDEDSEL
#PB_ListView_ClickSelect = $8   ; #LBS_MULTIPLESEL

#PB_ListIcon_CheckBoxes     = 1
#PB_ListIcon_MultiSelect    = 4
#PB_ListIcon_GridLines      = $10000
#PB_ListIcon_FullRowSelect  = $40000000
#PB_ListIcon_HeaderDragDrop = $10000000
#PB_ListIcon_AlwaysShowSelection = 8
#PB_ListIcon_ThreeState     = 64 ; LVS_SHAREIMAGELISTS (re-used for this setting)


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

#PB_ScrollBar_Minimum = 1 ; Attributes
#PB_ScrollBar_Maximum = 2
#PB_ScrollBar_PageLength = 3

; Flags
;
#PB_Splitter_Vertical    = 1
#PB_Splitter_Separator   = 2
#PB_Splitter_FirstFixed  = 4
#PB_Splitter_SecondFixed = 8

; Attributes
;
#PB_Splitter_FirstMinimumSize  = 1
#PB_Splitter_SecondMinimumSize = 2
#PB_Splitter_FirstGadget       = 3
#PB_Splitter_SecondGadget      = 4


; String flags
;
#PB_String_Password  = 32         ; ES_PASSWORD
#PB_String_ReadOnly  = $800
#PB_String_Numeric   = $2000
#PB_String_LowerCase = 16
#PB_String_UpperCase = 8
#PB_String_BorderLess = $20000 ; reuse WS_GROUP
#PB_String_AutoComplete = $10000000 ; reuse WS_VISIBLE
#PB_String_AutoInsert = $40000000   ; reuse WS_CHILD

#PB_Spin_ReadOnly = 1 ; Flags
#PB_Spin_Numeric  = 2

#PB_Spin_Minimum = 1 ; Attributes
#PB_Spin_Maximum = 2


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

#PB_Panel_ItemWidth  = 1 ; Attributes
#PB_Panel_ItemHeight = 2
#PB_Panel_TabHeight  = 3

#PB_TrackBar_Ticks    = 1
#PB_TrackBar_Vertical = 2

#PB_TrackBar_Minimum = 1 ; Attributes
#PB_TrackBar_Maximum = 2

#PB_HyperLink_Underline  = 1

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
; ;- special ASCII chars (moved to WindowsUnicode.res to have the string ones in unicode!)
; #SOH$   = Chr(001)  :  #SOH =   1 ;    (Start of Header)
; #STX$   = Chr(002)  :  #STX =   2 ;    (Start of Text)
; #ETX$   = Chr(003)  :  #ETX =   3 ;    (End of Text)
; #EOT$   = Chr(004)  :  #EOT =   4 ;    (End of Transmission)
; #ENQ$   = Chr(005)  :  #ENQ =   5 ;    (Enquiry)
; #ACK$   = Chr(006)  :  #ACK =   6 ;    (Acknowledgment)
; #BEL$   = Chr(007)  :  #BEL =   7 ;    (Bell)
; #BS$    = Chr(008)  :  #BS  =   8 ;    (Backspace)
; #HT$    = Chr(009)  :  #HT  =   9 ;    (Horizontal Tab)
; #TAB$   = Chr(009)  :  #TAB =   9 ;    (TAB)
; #LF$    = Chr(010)  :  #LF  =  10 ;    (Line Feed)
; #VT$    = Chr(011)  :  #VT  =  11 ;    (Vertical Tab)
; #FF$    = Chr(012)  :  #FF  =  12 ;    (Form Feed)
; #CR$    = Chr(013)  :  #CR  =  13 ;    (Carriage Return)
; #SO$    = Chr(014)  :  #SO  =  14 ;    (Shift Out)
; #SI$    = Chr(015)  :  #SI  =  15 ;    (Shift In)
; #DLE$   = Chr(016)  :  #DLE =  16 ;    (Data Link Escape)
; #DC1$   = Chr(017)  :  #DC1 =  17 ;    (Device Control 1) (XON)
; #DC2$   = Chr(018)  :  #DC2 =  18 ;    (Device Control 2)
; #DC3$   = Chr(019)  :  #DC3 =  19 ;    (Device Control 3) (XOFF)
; #DC4$   = Chr(020)  :  #DC4 =  20 ;    (Device Control 4)
; #NAK$   = Chr(021)  :  #NAK =  21 ;    (Negative Acknowledgement)
; #SYN$   = Chr(022)  :  #SYN =  22 ;    (Synchronous Idle)
; #ETB$   = Chr(023)  :  #ETB =  23 ;    (End of Trans. Block)
; #CAN$   = Chr(024)  :  #CAN =  24 ;    (Cancel)
; #EM$    = Chr(025)  :  #EM  =  25 ;    (End of Medium)
; #SUB$   = Chr(026)  :  #SUB =  26 ;    (Substitute)
; #ESC$   = Chr(027)  :  #ESC =  27 ;    (Escape)
; #FS$    = Chr(028)  :  #FS  =  28 ;    (File Separator)
; #GS$    = Chr(029)  :  #GS  =  29 ;    (Group Separator)
; #RS$    = Chr(030)  :  #RS  =  30 ;    (Request to Send)(Record Separator)
; #US$    = Chr(031)  :  #US  =  31 ;    (Unit Separator)
; #DEL$   = Chr(127)  :  #DEL = 127 ;    (delete)
; #CRLF$  = Chr(13) + Chr(10)
; #LFCR$  = Chr(10) + Chr(13)
; #DOUBLEQUOTE$ = Chr(34)
; #DQUOTE$      = Chr(34)


;Structure Character ; This one is located in the WindowsUnicode.res
;  c.c
;EndStructure
