; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
;
; SpiderBasic resident
;
;
;

; General
;
;
IncludeFile "../Common.pb"


#PB_ProcessPureBasicEvents = -$1F1F1F1F

; Global flags (multi functions)
;
#PB_LocalFile       = 1 << 16
#PB_GoogleDriveFile = 1 << 17
#PB_LocalStorage    = 1 << 18

#PB_Status_Loaded = 0
#PB_Status_Progress = 1
#PB_Status_Error = 2
#PB_Status_Saved = 3

#PB_File_Streaming = 1 << 0

; #PB_Compiler_App constants
;
#PB_App_Web = 0
#PB_App_Android = 1
#PB_App_IOS = 2

; In app purchase
;
#PB_Product_Consumable    = 0
#PB_Product_NonConsumable = 1

#PB_Product_Approved  = 0
#PB_Product_Cancelled = 1
#PB_Product_Refunded  = 2
#PB_Product_Owned     = 3

; System library
;
#PB_Device_Model    = 0
#PB_Device_Platform = 1
#PB_Device_UUID     = 2
#PB_Device_Version  = 3
#PB_Device_Manufacturer = 4
#PB_Device_Serial   = 5

#PB_Battery_Unknown = -1
#PB_Battery_Plugged = -2

; Clipboard
;
#PB_Clipboard_Image = 8 ; CF_DIB


; Font
;
#PB_Font_Bold        = 1 << 1
#PB_Font_Italic      = 1 << 2
#PB_Font_Underline   = 1 << 3
#PB_Font_StrikeOut   = 1 << 4
#PB_Font_HighQuality = 1 << 5

; Image
;
#PB_Image_Smooth = 0
#PB_Image_Raw    = 1

; LoadImage()
#PB_Image_PNGBase64  = 1 << 0
#PB_Image_JPEGBase64 = 1 << 1

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

#PB_MessageRequester_Yes    = 6
#PB_MessageRequester_No     = 7

#PB_Requester_MultiSelection = 1
#PB_Requester_GoogleDrive = 1 << 1

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
#PB_Event_None             = 0
#PB_Event_Gadget           = 1
#PB_Event_Menu             = 2
; #PB_Event_SysTray          = 3
#PB_Event_CloseWindow      = 4
; #PB_Event_Repaint          = 5
#PB_Event_MoveWindow       = 6
#PB_Event_SizeWindow       = 7
#PB_Event_ActivateWindow   = 8
; #PB_Event_MinimizeWindow   = 9
; #PB_Event_MaximizeWindow   = 10
; #PB_Event_RestoreWindow    = 11
#PB_Event_Timer            = 12
#PB_Event_RightClick       = 13
#PB_Event_LeftClick        = 14
#PB_Event_LeftDoubleClick  = 15
#PB_Event_DeactivateWindow = 16
#PB_Event_RenderFrame      = 17
#PB_Event_Loading          = 18
#PB_Event_LoadingError     = 19
#PB_Event_RequesterOK      = 20
#PB_Event_SizeDesktop      = 21
#PB_Event_WebSocket        = 22
#PB_Event_Mobile           = 23
#PB_Event_Notification     = 24
#PB_Event_ThemeChanged     = 25

; Loading type
;
#PB_Loading_Image = 1
#PB_Loading_Sound = 2
#PB_Loading_Sprite = 3
#PB_Loading_File = 4
#PB_Loading_Xml = 5
#PB_Loading_JSON = 6

;
; Network related one
;
#PB_Event_ClientConnected    = 1
#PB_Event_DataReceived       = 2
#PB_Event_FileReceived       = 3
#PB_Event_ClientDisconnected = 4


; EventType
;
#PB_EventType_LeftClick         = 0
#PB_EventType_RightClick        = 1
#PB_EventType_LeftDoubleClick   = 2
#PB_EventType_RightDoubleClick  = 3
#PB_EventType_Up                = 4
#PB_EventType_Down              = 5
#PB_EventType_Focus             = 7
#PB_EventType_LostFocus         = 8
#PB_EventType_Change            = 9
#PB_EventType_Connected         = 10
#PB_EventType_Closed            = 11
#PB_EventType_Data              = 12
#PB_EventType_String            = 13
#PB_EventType_Error             = 14
#PB_EventType_Resize            = 15
#PB_EventType_PageLoaded        = 16
#PB_EventType_NotificationClicked   = 17
#PB_EventType_NotificationTriggered = 18

; Window flags
;

#PB_Window_ScreenCentered = 1 << 0
#PB_Window_WindowCentered = 1 << 1
#PB_Window_Tool           = 1 << 2
#PB_Window_TitleBar       = 1 << 3
#PB_Window_SystemMenu     = 1 << 4
#PB_Window_SizeGadget     = 1 << 5
; #PB_Window_MinimizeGadget = 1 << 6 ; Not supported in SpiderBasic for now
; #PB_Window_MaximizeGadget = 1 << 7 ;
#PB_Window_Invisible      = 1 << 8
#PB_Window_BorderLess     = 1 << 9
#PB_Window_NoGadgets      = 1 << 10
#PB_Window_NoActivate     = 1 << 11
#PB_Window_Background     = 1 << 12
#PB_Window_AllowSelection = 1 << 13
#PB_Window_NoMove         = 1 << 14

; For WindowX/Y/Width/Height()
;
#PB_Window_FrameCoordinate = 0
#PB_Window_InnerCoordinate = 1

; Window states
;
#PB_Window_Normal   = 0
; #PB_Window_Maximize = $1000000 ; #WS_MAXIMIZE
; #PB_Window_Minimize = $20000000 ; #WS_MINIMIZE

; FileSystem
;
#PB_FileSystem_Archive    = 32
#PB_FileSystem_Compressed = 2048
#PB_FileSystem_Hidden     = 2
#PB_FileSystem_Normal     = 128
#PB_FileSystem_ReadOnly   = 1
#PB_FileSystem_System     = 4

#PB_FileSystem_Recursive  = 1
#PB_FileSystem_Force      = 2

#PB_DirectoryEntry_File      = 1
#PB_DirectoryEntry_Directory = 2

#PB_FileSystem_NoExtension = 1

; Notification
;
#PB_Notification_Secret   = (1 << 1)
#PB_Notification_Progress = (1 << 2)

#PB_Notification_Now       = 0
#PB_Notification_InSecond  = 1
#PB_Notification_InMinute  = 2
#PB_Notification_InHour    = 3
#PB_Notification_InDay     = 4
#PB_Notification_InWeek    = 5
#PB_Notification_InMonth   = 6
#PB_Notification_InQuarter = 7
#PB_Notification_InYear    = 8
#PB_Notification_EveryDate = 9
#PB_Notification_EveryMinute = 10
#PB_Notification_EveryHour   = 11
#PB_Notification_EveryDay    = 12
#PB_Notification_EveryWeek   = 13
#PB_Notification_EveryMonth  = 14
#PB_Notification_EveryYear   = 15
#PB_Notification_At          = 16

; LoadScript()
;
#PB_Script_JavaScript = 0
#PB_Script_CSS = 1

; SplashScreenControl()
;
#PB_SplashScreen_Close = 0
#PB_SplashScreen_NoAutoClose = 1
#PB_SplashScreen_AutoClose = 2

; Used by Get/SetFileDate() and DirectoryEntryDate()
;
#PB_Date_Created  = 0
#PB_Date_Accessed = 1
#PB_Date_Modified = 2

#PB_Button_Right     = 1 << 0
#PB_Button_Left      = 1 << 1
#PB_Button_Default   = 1 << 2
#PB_Button_MultiLine = 1 << 3
#PB_Button_Toggle    = 1 << 4

; for buttonimage
#PB_Button_Image = 1
#PB_Button_PressedImage = 2

#PB_Calendar_Borderless = 1

#PB_Calendar_Minimum    = 1
#PB_Calendar_Maximum    = 2
#PB_Calendar_Bold       = 1
#PB_Calendar_Normal     = 0

#PB_CheckBox_Right      = 1 << 0
#PB_CheckBox_Center     = 1 << 1

#PB_ComboBox_Editable  = 1 << 0
#PB_ComboBox_LowerCase = 1 << 1
#PB_ComboBox_UpperCase = 1 << 2
#PB_ComboBox_Image     = 1 << 3

#PB_Date_Calendar = 0
#PB_Date_UpDown   = 1
#PB_Date_CheckBox = 2

#PB_Date_Minimum  = 1
#PB_Date_Maximum  = 2

; Editor

#PB_ListView_MultiSelect = 1 << 0
#PB_ListView_ClickSelect = 1 << 1

#PB_Spin_ReadOnly = 1 ; Flags
#PB_Spin_Numeric  = 2

#PB_Spin_Minimum = 1 ; Attributes
#PB_Spin_Maximum = 2


#PB_Tree_AlwaysShowSelection = 1 << 0
#PB_Tree_NoLines             = 1 << 1
#PB_Tree_NoButtons           = 1 << 2

#PB_Tree_SubLevel = 1 ; Attribute

#PB_Tree_Selected = 1
#PB_Tree_Expanded = 2
#PB_Tree_Checked = 4
#PB_Tree_Collapsed = 8

#PB_Image_Raised = 1 << 0
#PB_Image_Border = 1 << 1



#PB_ProgressBar_Smooth   = 1

; Not supported in DOJO
; #PB_ProgressBar_Vertical = 4

#PB_ProgressBar_Minimum  = 1  ; Attributes
#PB_ProgressBar_Maximum  = 2

#PB_Text_Center = 1 << 0
#PB_Text_Right  = 1 << 1
#PB_Text_Border = 1 << 2
#PB_Text_VerticalCenter = 1 << 3

; DragDrop lib
;
;#PB_EventType_DragStart = 14002
;#PB_Event_WindowDrop = 13105
;#PB_Event_GadgetDrop = 13106

;#PB_Drop_Text    = 1; #CF_TEXT
;#PB_Drop_Image   = 8; #CF_DIB
;#PB_Drop_Files   = 15; #CF_HDROP
;#PB_Drop_Private = 512; #CF_PRIVATEFIRST

;#PB_Drag_None    = 0; #DROPEFFECT_NONE
;#PB_Drag_Copy    = 1; #DROPEFFECT_COPY
;#PB_Drag_Move    = 2; #DROPEFFECT_MOVE
;#PB_Drag_Link    = 4; #DROPEFFECT_LINK

;#PB_Drag_Enter   = 1
;#PB_Drag_Update  = 2
;#PB_Drag_Leave   = 3
;#PB_Drag_Finish  = 4

#PB_Mouse_Locked = 0;
#PB_Mouse_Unlocked = 1;


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

#PB_Key_Back            =  8
#PB_Key_Tab             =  9
#PB_Key_Return          = 13
#PB_Key_Capital         = 20
#PB_Key_Escape          = 27
#PB_Key_Space           = 32

#PB_Key_0               = 48
#PB_Key_1               = 49
#PB_Key_2               = 50
#PB_Key_3               = 51
#PB_Key_4               = 52
#PB_Key_5               = 53
#PB_Key_6               = 54
#PB_Key_7               = 55
#PB_Key_8               = 56
#PB_Key_9               = 57

#PB_Key_A               = 65
#PB_Key_B               = 66
#PB_Key_C               = 67
#PB_Key_D               = 68
#PB_Key_E               = 69
#PB_Key_F               = 70
#PB_Key_G               = 71
#PB_Key_H               = 72
#PB_Key_I               = 73
#PB_Key_J               = 74
#PB_Key_K               = 75
#PB_Key_L               = 76
#PB_Key_M               = 77
#PB_Key_N               = 78
#PB_Key_O               = 79
#PB_Key_P               = 80
#PB_Key_Q               = 81
#PB_Key_R               = 82
#PB_Key_S               = 83
#PB_Key_T               = 84
#PB_Key_U               = 85
#PB_Key_V               = 86
#PB_Key_W               = 87
#PB_Key_X               = 88
#PB_Key_Y               = 89
#PB_Key_Z               = 90

#PB_Key_Minus           = '-'
#PB_Key_Equals          = '='
#PB_Key_LeftBracket     = '('
#PB_Key_RightBracket    = ')'
#PB_Key_SemiColon       = ';'
#PB_Key_Apostrophe      = 34
#PB_Key_Grave           = '`'
#PB_Key_BackSlash       = '\'
#PB_Key_Comma           = ','
#PB_Key_Period          = '.'
#PB_Key_Slash           = '/'

#PB_Key_RightControl    = 17
#PB_Key_LeftControl     = 17 ; Same as RightControl
#PB_Key_RightAlt        = 18
#PB_Key_LeftAlt         = 18 ; Same as LeftAlt
#PB_Key_LeftShift       = 16
#PB_Key_RightShift      = 16 ; Same as LeftShift

#PB_Key_F1              = 112
#PB_Key_F2              = 113
#PB_Key_F3              = 114
#PB_Key_F4              = 115
#PB_Key_F5              = 116
#PB_Key_F6              = 117
#PB_Key_F7              = 118
#PB_Key_F8              = 119
#PB_Key_F9              = 120
#PB_Key_F10             = 121
#PB_Key_F11             = 122
#PB_Key_F12             = 123

#PB_Key_NumLock         = 144
#PB_Key_Scroll          = 145

#PB_Key_Pad0            = 96
#PB_Key_Pad1            = 97
#PB_Key_Pad2            = 98
#PB_Key_Pad3            = 99
#PB_Key_Pad4            = 100
#PB_Key_Pad5            = 101
#PB_Key_Pad6            = 102
#PB_Key_Pad7            = 103
#PB_Key_Pad8            = 104
#PB_Key_Pad9            = 105
#PB_Key_PadEnter        = 13 ; Same as 'Enter'

#PB_Key_Subtract        = 109
#PB_Key_Add             = 107
#PB_Key_Decimal         = 110
#PB_Key_PadComma        = 110
#PB_Key_Divide          = 111
#PB_Key_Multiply        = 106

#PB_Key_Pause           = 19
#PB_Key_Home            = 36
#PB_Key_End             = 35
#PB_Key_PageUp          = 33
#PB_Key_PageDown        = 34

#PB_Key_Left            = 37
#PB_Key_Up              = 38
#PB_Key_Right           = 39
#PB_Key_Down            = 40

#PB_Key_Insert          = 45
#PB_Key_Delete          = 46


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
#PB_Shortcut_Capital = 0
#PB_Shortcut_Escape  = 27
#PB_Shortcut_Space   = 32
#PB_Shortcut_PageUp  = 33
#PB_Shortcut_PageDown= 34
#PB_Shortcut_End     = 4
#PB_Shortcut_Home    = 1
#PB_Shortcut_Left    = 37
#PB_Shortcut_Up      = 38
#PB_Shortcut_Right   = 39
#PB_Shortcut_Down    = 40
#PB_Shortcut_Select  = 0
#PB_Shortcut_Insert  = 5
#PB_Shortcut_Delete  = 127
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
#PB_Shortcut_Pad0 = 48
#PB_Shortcut_Pad1 = 49
#PB_Shortcut_Pad2 = 50
#PB_Shortcut_Pad3 = 51
#PB_Shortcut_Pad4 = 52
#PB_Shortcut_Pad5 = 53
#PB_Shortcut_Pad6 = 54
#PB_Shortcut_Pad7 = 55
#PB_Shortcut_Pad8 = 56
#PB_Shortcut_Pad9 = 57
#PB_Shortcut_Multiply  = 42
#PB_Shortcut_Add       = 43
#PB_Shortcut_Separator = 0
#PB_Shortcut_Subtract  = 45
#PB_Shortcut_Decimal   = 44
#PB_Shortcut_Divide    = 47
#PB_Shortcut_F1  = 201
#PB_Shortcut_F2  = 202
#PB_Shortcut_F3  = 203
#PB_Shortcut_F4  = 204
#PB_Shortcut_F5  = 205
#PB_Shortcut_F6  = 206
#PB_Shortcut_F7  = 207
#PB_Shortcut_F8  = 208
#PB_Shortcut_F9  = 209
#PB_Shortcut_F10 = 210
#PB_Shortcut_F11 = 211
#PB_Shortcut_F12 = 212

; Shader
;
#PB_Shader_Blur     = 0
#PB_Shader_Noise    = 1
#PB_Shader_Pixelate = 2
#PB_Shader_Bevel    = 4
#PB_Shader_BulgePinch = 5
#PB_Shader_Reflection = 7
#PB_Shader_Adjustment = 8

#PB_PixelateShader_SizeX = 1
#PB_PixelateShader_SizeY = 2

#PB_NoiseShader_Seed = 3
#PB_NoiseShader_Intensity = 4

#PB_BlurShader_Intensity = 5
#PB_BlurShader_Quality = 6

#PB_BulgePinchShader_Strength = 7
#PB_BulgePinchShader_CenterX = 8
#PB_BulgePinchShader_CenterY = 9
#PB_BulgePinchShader_Radius = 10

#PB_BevelShader_Thickness = 12
#PB_BevelShader_Rotation = 13
#PB_BevelShader_LightColor = 14
#PB_BevelShader_ShadowColor = 15

#PB_ReflectionShader_AlphaStart = 16
#PB_ReflectionShader_AlphaEnd = 17
#PB_ReflectionShader_Boundary = 18
#PB_ReflectionShader_AmplitudeStart = 19
#PB_ReflectionShader_AmplitudeEnd = 20
#PB_ReflectionShader_WaveLengthStart = 21
#PB_ReflectionShader_WaveLengthEnd = 22
#PB_ReflectionShader_Mirror = 23
#PB_ReflectionShader_Time = 32

#PB_AdjustmentShader_Alpha = 24
#PB_AdjustmentShader_Gamma = 25
#PB_AdjustmentShader_Saturation = 26
#PB_AdjustmentShader_Contrast = 27
#PB_AdjustmentShader_Brightness = 28
#PB_AdjustmentShader_Red = 29
#PB_AdjustmentShader_Green = 30
#PB_AdjustmentShader_Blue = 31

; Mobile
;
#PB_Mobile_Container = 1 << 0
#PB_Mobile_Left      = 1 << 1
#PB_Mobile_Right     = 1 << 2
#PB_Mobile_Center    = 1 << 3
#PB_Mobile_Search    = 1 << 4
#PB_Mobile_Password  = 1 << 5
#PB_Mobile_Numeric   = 1 << 6
#PB_Mobile_Tappable  = 1 << 7
#PB_Mobile_Chevron     = 1 << 8
#PB_Mobile_NoDivider   = 1 << 9
#PB_Mobile_LongDivider = 1 << 10
#PB_Mobile_Header      = 1 << 11
#PB_Mobile_Expandable  = 1 << 12
#PB_Mobile_Swipeable   = 1 << 13
#PB_Mobile_Icon        = 1 << 14
#PB_Mobile_Circular    = 1 << 15
#PB_Mobile_Indeterminate = 1 << 16
#PB_Mobile_BackButton = 1 << 17

#PB_Mobile_InSet   = 1

#PB_Mobile_Page    = 0
#PB_Mobile_Section = 1
#PB_Mobile_Row = 2
#PB_Mobile_Template = 3
#PB_Mobile_Dialog = 4
#PB_Mobile_PopOver = 5

#PB_Mobile_Push = 1
#PB_Mobile_Pop = 0

#PB_Mobile_Auto = 0
#PB_Mobile_Android = 1
#PB_Mobile_iOS = 2

#PB_Mobile_TabLabel = "label"
#PB_Mobile_TabIcon  = "icon"
#PB_Mobile_TabActiveIcon = "active-icon"
#PB_Mobile_TabBadge = "badge"

#PB_Mobile_LightTheme = 1
#PB_Mobile_DarkTheme = 2
