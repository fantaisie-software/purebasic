﻿;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------
;
; Constants and structures which are the same for all OS
;

; Deprecated constants:
;
#PB_LinkedList = 14
#PB_Engine3D_Current = 0
#PB_Engine3D_Maximum = 1
#PB_Engine3D_Minimum = 2
#PB_Engine3D_Average = 3
#PB_Engine3D_Reset   = 4

; Global constants

#True  = 1
#False = 0
#Null  = 0

#PI = 3.141592653589793238
#E = 2.7182818284590452353

; Color constants
;
#Black = $000000
#Blue = $FF0000
#Green = $00FF00
#Cyan = $FFFF00
#Red = $0000FF
#Magenta = $0FF00FF
#Yellow = $00FFFF
#White = $FFFFFF
#Gray = $808080

; Internal compiler constant #PB_Compiler_Processor
;
#PB_Processor_mc68000    = 1
#PB_Processor_x86        = 2
#PB_Processor_PowerPC    = 3
#PB_Processor_x64        = 4
#PB_Processor_JavaScript = 5
#PB_Processor_Arm64      = 6
#PB_Processor_Arm32      = 7

#PB_Backend_Asm = 0
#PB_Backend_C = 1

#PB_Structure_AlignC = -1

#PB_Compiler_Executable = 0
#PB_Compiler_DLL        = 1
#PB_Compiler_Console    = 2

; Internal type used by some PB functions (Sort) and also by Defined(), TypeOf()
;
#PB_Byte       = 1
#PB_Word       = 3
#PB_Long       = 5
#PB_String     = 8
#PB_Structure  = 7
#PB_Float      = 9
#PB_Character  = 11
#PB_Double     = 12
#PB_Quad       = 13
#PB_List       = 14
#PB_Array      = 15
#PB_Integer    = 21
#PB_Map        = 22
#PB_Ascii      = 24
#PB_Unicode    = 25

#PB_Constant    = 50 ; Used by Defined()
#PB_Variable    = 51
#PB_Interface   = 52
#PB_Procedure   = 53
#PB_Function    = 54
#PB_OSFunction  = 55
#PB_Label       = 56
#PB_Prototype   = 57
#PB_Module      = 58
#PB_Enumeration = 59


; Used a lot in the 3D engine, so don't prefix them with lib name
;
#PB_Absolute = 0
#PB_Relative = 1

#PB_Local  = 1 << 1
#PB_Parent = 1 << 2
#PB_World  = 1 << 3
#PB_Engine3D_Raw      = 1 << 5
#PB_Engine3D_Adjusted = 1 << 6

#PB_Vector_X = 0
#PB_Vector_Y = 1
#PB_Vector_Z = 2
#PB_Vector_NegativeX = 3
#PB_Vector_NegativeY = 4
#PB_Vector_NegativeZ = 5

; Internal compiler constant #PB_Compiler_OS
;
#PB_OS_Windows        =  1
#PB_OS_Linux          =  2
#PB_OS_AmigaOS        =  3
#PB_OS_MacOS          =  4
#PB_OS_Web            =  5

; OSVersion() Constants
;
#PB_OS_Windows_NT3_51         =  5
#PB_OS_Windows_95             = 10
#PB_OS_Windows_NT_4           = 20
#PB_OS_Windows_98             = 30
#PB_OS_Windows_ME             = 40
#PB_OS_Windows_2000           = 50
#PB_OS_Windows_XP             = 60
#PB_OS_Windows_Server_2003    = 65
#PB_OS_Windows_Vista          = 70
#PB_OS_Windows_Server_2008    = 75
#PB_OS_Windows_7              = 80
#PB_OS_Windows_Server_2008_R2 = 85
#PB_OS_Windows_8              = 90
#PB_OS_Windows_Server_2012    = 95
#PB_OS_Windows_8_1            = 100
#PB_OS_Windows_Server_2012_R2 = 105
#PB_OS_Windows_10             = 110
#PB_OS_Windows_11             = 120
#PB_OS_Windows_Future         = 200

#PB_OS_Linux_2_2 = 1000
#PB_OS_Linux_2_4 = 1100
#PB_OS_Linux_2_6 = 1200
#PB_OS_Linux_Future = 2000

#PB_OS_MacOSX_10_0   = 10000
#PB_OS_MacOSX_10_1   = 10010
#PB_OS_MacOSX_10_2   = 10020
#PB_OS_MacOSX_10_3   = 10030
#PB_OS_MacOSX_10_4   = 10040
#PB_OS_MacOSX_10_5   = 10050
#PB_OS_MacOSX_10_6   = 10060
#PB_OS_MacOSX_10_7   = 10070
#PB_OS_MacOSX_10_8   = 10080
#PB_OS_MacOSX_10_9   = 10090
#PB_OS_MacOSX_10_10  = 10100
#PB_OS_MacOSX_10_11  = 10110
#PB_OS_MacOSX_10_12  = 10120
#PB_OS_MacOSX_10_13  = 10130
#PB_OS_MacOSX_10_14  = 10140
#PB_OS_MacOSX_10_15  = 10150
#PB_OS_MacOSX_11     = 11000
#PB_OS_MacOSX_12     = 12000
#PB_OS_MacOSX_Future = 99999

#PB_Default = -1  ; Common default value, used by SetGadgetFont(), TransparentSpriteColor, etc..
#PB_All     = -1
#PB_Any     = -1
#PB_Ignore  = -$FFFF

#PB_UTF8  = 2
#PB_UTF16 = #PB_Unicode

; unsupported string formats
#PB_UTF16BE = 4
#PB_UTF32   = 5
#PB_UTF32BE = 6

#PB_ByteLength = 1 << 6

;- Structures
Structure Byte
  b.b
EndStructure

Structure Ascii
  a.a
EndStructure

Structure Unicode
  u.u
EndStructure

Structure Word
  w.w
EndStructure

Structure Long
  l.l
EndStructure

Structure Float
  f.f
EndStructure

Structure Quad
  q.q
EndStructure

Structure Double
  d.d
EndStructure

Structure String
  s.s
EndStructure

Structure Integer
  i.i
EndStructure

; 2D Drawing
;
#PB_2DDrawing_Default      =  0
#PB_2DDrawing_Transparent  =  1
#PB_2DDrawing_XOr          =  2
#PB_2DDrawing_Outlined     =  4
#PB_2DDrawing_AlphaChannel =  8
#PB_2DDrawing_AlphaBlend   = 16
#PB_2DDrawing_AlphaClip    = 32
#PB_2DDrawing_Gradient     = 64
#PB_2DDrawing_CustomFilter = 128
#PB_2DDrawing_AllChannels  = 256

#PB_PixelFormat_8Bits      = 1 << 0
#PB_PixelFormat_15Bits     = 1 << 1
#PB_PixelFormat_16Bits     = 1 << 2
#PB_PixelFormat_24Bits_RGB = 1 << 3
#PB_PixelFormat_24Bits_BGR = 1 << 4
#PB_PixelFormat_32Bits_RGB = 1 << 5
#PB_PixelFormat_32Bits_BGR = 1 << 6

#PB_PixelFormat_ReversedY  = 1 << 15

; CGI
;
#PB_CGI_Text = 0
#PB_CGI_File = 1

#PB_CGI_LastHeader = 1 << 16

#PB_CGI_HeaderContentLength = "Content-length"
#PB_CGI_HeaderContentType = "Content-type"
#PB_CGI_HeaderExpires = "Expires"
#PB_CGI_HeaderLocation = "Location"
#PB_CGI_HeaderPragma = "Pragma"
#PB_CGI_HeaderStatus = "Status"
#PB_CGI_HeaderRefresh = "Refresh"
#PB_CGI_HeaderSetCookie = "Set-Cookie"
#PB_CGI_HeaderContentDisposition = "Content-Disposition"

#PB_CGI_AuthType = "AUTH_TYPE"
#PB_CGI_ContentLength = "CONTENT_LENGTH"
#PB_CGI_ContentType = "CONTENT_TYPE"
#PB_CGI_DocumentRoot = "DOCUMENT_ROOT"
#PB_CGI_GatewayInterface = "GATEWAY_INTERFACE"
#PB_CGI_PathInfo = "PATH_INFO"
#PB_CGI_PathTranslated = "PATH_TRANSLATED"
#PB_CGI_QueryString = "QUERY_STRING"
#PB_CGI_RemoteAddr = "REMOTE_ADDR"
#PB_CGI_RemoteHost = "REMOTE_HOST"
#PB_CGI_RemoteIdent = "REMOTE_IDENT"
#PB_CGI_RemotePort = "REMOTE_PORT"
#PB_CGI_RemoteUser = "REMOTE_USER"
#PB_CGI_RequestURI = "REQUEST_URI"
#PB_CGI_RequestMethod = "REQUEST_METHOD"
#PB_CGI_ScriptName = "SCRIPT_NAME"
#PB_CGI_ScriptFilename = "SCRIPT_FILENAME"
#PB_CGI_ServerAdmin = "SERVER_ADMIN"
#PB_CGI_ServerName = "SERVER_NAME"
#PB_CGI_ServerPort = "SERVER_PORT"
#PB_CGI_ServerProtocol = "SERVER_PROTOCOL"
#PB_CGI_ServerSignature = "SERVER_SIGNATURE"
#PB_CGI_ServerSoftware = "SERVER_SOFTWARE"
#PB_CGI_HttpAccept = "HTTP_ACCEPT"
#PB_CGI_HttpAcceptEncoding = "HTTP_ACCEPT_ENCODING"
#PB_CGI_HttpAcceptLanguage = "HTTP_ACCEPT_LANGUAGE"
#PB_CGI_HttpCookie = "HTTP_COOKIE"
#PB_CGI_HttpForwarded = "HTTP_FORWARDED"
#PB_CGI_HttpHost = "HTTP_HOST"
#PB_CGI_HttpPragma = "HTTP_PRAGMA"
#PB_CGI_HttpReferer = "HTTP_REFERER"
#PB_CGI_HttpUserAgent = "HTTP_USER_AGENT"

; Cipher
;
#PB_Cipher_MD5   = 1
#PB_Cipher_CRC32 = 2
#PB_Cipher_SHA1  = 3
#PB_Cipher_SHA2  = 4
#PB_Cipher_SHA3  = 5

#PB_Cipher_Decode    = 1 << 0
#PB_Cipher_Encode    = 1 << 1
#PB_Cipher_CBC       = 1 << 2 ; Used by AES
#PB_Cipher_ECB       = 1 << 3 ; Used by AES
#PB_Cipher_URL       = 1 << 4 ; Used by Base64Encoder
#PB_Cipher_NoPadding = 1 << 5 ; Used by Base64Encoder

; Date
;
#PB_Date_Year   = 0
#PB_Date_Month  = 1
#PB_Date_Week   = 2
#PB_Date_Day    = 3
#PB_Date_Hour   = 4
#PB_Date_Minute = 5
#PB_Date_Second = 6

; Database
;
#PB_Database_ODBC = 1
#PB_Database_SQLite = 2
#PB_Database_PostgreSQL = 3
#PB_Database_MySQL = 4

#PB_Database_StaticCursor  = 0
#PB_Database_DynamicCursor = 1

; DatabaseColumnType()
;
#PB_Database_Long   = 1
#PB_Database_String = 2
#PB_Database_Float  = 3
#PB_Database_Double = 4
#PB_Database_Quad   = 5
#PB_Database_Blob   = 6

; Event
;
#PB_Event_FirstCustomValue     = 1 << 16
#PB_EventType_FirstCustomValue = 1 << 18

; File library
;
#PB_File_NoShare     = 0
#PB_File_IgnoreEOL   = 1 << 16
#PB_File_SharedRead  = 1 << 17
#PB_File_SharedWrite = 1 << 18
#PB_File_NoBuffering = 1 << 19
#PB_File_Append      = 1 << 20

CompilerIf #PB_Compiler_OS <> #PB_OS_Web

  ; FileSystem library
  ;
  #PB_Directory_Desktop     = 0
  #PB_Directory_Programs    = 1
  #PB_Directory_Downloads   = 2
  #PB_Directory_Documents   = 3
  #PB_Directory_ProgramData = 4
  #PB_Directory_AllUserData = 5
  #PB_Directory_Videos      = 6
  #PB_Directory_Musics      = 7
  #PB_Directory_Pictures    = 8
  #PB_Directory_Public      = 9

CompilerEndIf

; Image
;
#PB_ImagePlugin_JPEG     = $4745504A
#PB_ImagePlugin_PNG      = $474E50
#PB_ImagePlugin_BMP      = $504D42

CompilerIf #PB_Compiler_OS <> #PB_OS_Web

  #PB_Image_FloydSteinberg =  1 << 8 ; SaveImage()
  
  #PB_ImagePlugin_JPEG2000 = $4B32504A
  #PB_ImagePlugin_TGA      = $414754
  #PB_ImagePlugin_TIFF     = $46464954
  #PB_ImagePlugin_ICON     = $4E4F4349
  #PB_ImagePlugin_GIF      = $474946

CompilerEndIf

; deprecated, just map it to 24bit image depth always
; use 24bit for better Windows GDI compatibility
#PB_Image_DisplayFormat = 24
#PB_Image_Transparent   = -1 ; CreateImage()
#PB_Image_OriginalDepth = -2  ; ImageDepth()
#PB_Image_InternalDepth = -3  ; ImageDepth()

; JSON
;
#PB_JSON_Null     = 0
#PB_JSON_String   = 1
#PB_JSON_Number   = 2
#PB_JSON_Boolean  = 3
#PB_JSON_Array    = 4
#PB_JSON_Object   = 5

#PB_JSON_PrettyPrint = (1 << 0)

CompilerIf #PB_Compiler_OS <> #PB_OS_Web
  #PB_JSON_NoCase      = (1 << 1)
  #PB_JSON_NoClear     = (1 << 2)
CompilerEndIf


; Keyboard
;
#PB_Keyboard_Qwerty          = 0
#PB_Keyboard_International   = (1)
#PB_Keyboard_AllowSystemKeys = (1 << 1)


; MouseButton()
;
#PB_MouseButton_Left    = 1
#PB_MouseButton_Right   = 2
#PB_MouseButton_Middle  = 3

; Gadget
;
Enumeration  ; gadget types
  #PB_GadgetType_Unknown = 0
  
  #PB_GadgetType_Button
  #PB_GadgetType_String
  #PB_GadgetType_Text
  #PB_GadgetType_CheckBox
  #PB_GadgetType_Option
  #PB_GadgetType_ListView
  #PB_GadgetType_Frame
  #PB_GadgetType_ComboBox
  #PB_GadgetType_Image
  #PB_GadgetType_HyperLink
  #PB_GadgetType_Container
  #PB_GadgetType_ListIcon
  #PB_GadgetType_IPAddress
  #PB_GadgetType_ProgressBar
  #PB_GadgetType_ScrollBar
  #PB_GadgetType_ScrollArea
  #PB_GadgetType_TrackBar
  #PB_GadgetType_Web
  #PB_GadgetType_ButtonImage
  #PB_GadgetType_Calendar
  #PB_GadgetType_Date
  #PB_GadgetType_Editor
  #PB_GadgetType_ExplorerList
  #PB_GadgetType_ExplorerTree
  #PB_GadgetType_ExplorerCombo
  #PB_GadgetType_Spin
  #PB_GadgetType_Tree
  #PB_GadgetType_Panel
  #PB_GadgetType_Splitter
  #PB_GadgetType_MDI
  #PB_GadgetType_Scintilla
  #PB_GadgetType_Shortcut
  #PB_GadgetType_Canvas
  #PB_GadgetType_OpenGL
EndEnumeration

; for SetGadgetState
#PB_ProgressBar_Unknown = -1

#PB_Gadget_ContainerCoordinate = 0
#PB_Gadget_ScreenCoordinate = 1 << 0
#PB_Gadget_WindowCoordinate = 1 << 1

#PB_Gadget_ActualSize   = 0
#PB_Gadget_RequiredSize = 1

#PB_Checkbox_Checked   = 1
#PB_Checkbox_Unchecked = 0
#PB_Checkbox_Inbetween = -1

#PB_ListIcon_DisplayMode  = 2
#PB_ListIcon_ColumnCount = 3

#PB_ListIcon_LargeIcon = 0
#PB_ListIcon_SmallIcon = 1
#PB_ListIcon_List      = 2
#PB_ListIcon_Report    = 3

; keep in sync with the listicon ones
#PB_Explorer_DisplayMode  = 2

#PB_Explorer_LargeIcon = 0
#PB_Explorer_SmallIcon = 1
#PB_Explorer_List      = 2
#PB_Explorer_Report    = 3

; String attributes
;
#PB_String_MaximumLength = 1

; WebGadget constants are common on all OS
#PB_Web_Back = $1
#PB_Web_Forward = $2
#PB_Web_Refresh = $4
#PB_Web_Stop = $3

; for Get/SetGadgetItemText()
;
#PB_Web_HtmlCode      = 1  ; read/write
#PB_Web_PageTitle     = 2  ; readonly
#PB_Web_StatusMessage = 3  ; readonly
#PB_Web_SelectedText  = 4  ; readonly

; for Get/SetGadgetAttribute()
;
#PB_Web_BlockPopups        = 1 ; block popup windows
#PB_Web_BlockPopupMenu     = 2 ; block IE menu (the above event is fired to allow a custom menu)
#PB_Web_NavigationCallback = 3 ; set a callback to trace (and prevent) navigation (See example)
#PB_Web_Progress           = 4 ; at a DownloadProgress event, get the downloaded data (readonly) may be 0 if unknown
#PB_Web_ProgressMax        = 5 ; at a DownloadProgress event, get the total size (readonly) may be 0 if unknown
#PB_Web_Busy               = 6 ; check if the Gadget is busy loading/rendering (readonly)
#PB_Web_ScrollX            = 7 ; get/set the X scroll position
#PB_Web_ScrollY            = 8 ; get/set the Y scroll position


; CanvasGadget/OpenGLGadget
;
#PB_EventType_MouseEnter          = $10000 + 1
#PB_EventType_MouseLeave          = $10000 + 2
#PB_EventType_MouseMove           = $10000 + 3
#PB_EventType_LeftButtonDown      = $10000 + 4
#PB_EventType_LeftButtonUp        = $10000 + 5
#PB_EventType_RightButtonDown     = $10000 + 6
#PB_EventType_RightButtonUp       = $10000 + 7
#PB_EventType_MiddleButtonDown    = $10000 + 8
#PB_EventType_MiddleButtonUp      = $10000 + 9
#PB_EventType_MouseWheel          = $10000 + 10
#PB_EventType_KeyDown             = $10000 + 11
#PB_EventType_KeyUp               = $10000 + 12
#PB_EventType_Input               = $10000 + 13

; WebGadget
;
#PB_EventType_TitleChange      = $10050 + 1
#PB_EventType_StatusChange     = $10050 + 2
#PB_EventType_PopupWindow      = $10050 + 3
#PB_EventType_DownloadStart    = $10050 + 4
#PB_EventType_DownloadProgress = $10050 + 5
#PB_EventType_DownloadEnd      = $10050 + 6
#PB_EventType_PopupMenu        = $10050 + 7


; Flags for CanvasGadget
;
#PB_Canvas_Border     = 1 << 0
CompilerIf #PB_Compiler_OS <> #PB_OS_Web
  #PB_Canvas_ClipMouse  = 1 << 1 ; Not supported in JS
CompilerEndIf
#PB_Canvas_Keyboard   = 1 << 2
#PB_Canvas_DrawFocus  = (1 << 3) | #PB_Canvas_Keyboard ; implies the keyboard flag
CompilerIf #PB_Compiler_OS = #PB_OS_Web
  #PB_Canvas_Transparent = 1 << 4
CompilerEndIf
#PB_Canvas_Container = 1 << 5


; Get/SetGadgetAttribute for CanvasGadget
;
#PB_Canvas_Image        = 1
#PB_Canvas_MouseX       = 2
#PB_Canvas_MouseY       = 3
#PB_Canvas_Buttons      = 4
#PB_Canvas_Key          = 5
#PB_Canvas_Modifiers    = 6
#PB_Canvas_Cursor       = 7
#PB_Canvas_WheelDelta   = 8
#PB_Canvas_Input        = 9
CompilerIf #PB_Compiler_OS <> #PB_OS_Web
  #PB_Canvas_Clip         = 10
  #PB_Canvas_CustomCursor = 11
CompilerEndIf

; For PB_Canvas_Modifiers
;
#PB_Canvas_Shift        = (1 << 0)
#PB_Canvas_Alt          = (1 << 1)
#PB_Canvas_Control      = (1 << 2)
CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  #PB_Canvas_Command    = (1 << 3)
CompilerElse
  #PB_Canvas_Command    = #PB_Canvas_Control ; use the same behavior as on AddKeyboardShortcut
CompilerEndIf

; For PB_Canvas_Buttons
;
#PB_Canvas_LeftButton   = (1 << 0)
#PB_Canvas_RightButton  = (1 << 1)
#PB_Canvas_MiddleButton = (1 << 2)


; Flags for OpenGLGadget
;
#PB_OpenGL_Keyboard              = (1 << 2)
#PB_OpenGL_NoFlipSynchronization = (1 << 3)
#PB_OpenGL_FlipSynchronization   = (1 << 4)
#PB_OpenGL_NoDepthBuffer         = (1 << 5)
#PB_OpenGL_16BitDepthBuffer     = (1 << 6)
#PB_OpenGL_24BitDepthBuffer     = (1 << 7)
#PB_OpenGL_NoStencilBuffer       = (1 << 8)
#PB_OpenGL_8BitStencilBuffer    = (1 << 9)
#PB_OpenGL_NoAccumulationBuffer  = (1 << 10)
#PB_OpenGL_32BitAccumulationBuffer = (1 << 11)
#PB_OpenGL_64BitAccumulationBuffer = (1 << 12)


; Get/SetGadgetAttribute for OpenGL Gadget
; Note that common values are shared with CanvasGadget so we can reuse some code
;
#PB_OpenGL_MouseX       = #PB_Canvas_MouseX
#PB_OpenGL_MouseY       = #PB_Canvas_MouseY
#PB_OpenGL_Buttons      = #PB_Canvas_Buttons
#PB_OpenGL_Key          = #PB_Canvas_Key
#PB_OpenGL_Modifiers    = #PB_Canvas_Modifiers
#PB_OpenGL_Cursor       = #PB_Canvas_Cursor
#PB_OpenGL_WheelDelta   = #PB_Canvas_WheelDelta
#PB_OpenGL_Input        = #PB_Canvas_Input
CompilerIf #PB_Compiler_OS <> #PB_OS_Web
  #PB_OpenGL_CustomCursor = #PB_Canvas_CustomCursor
CompilerEndIf
#PB_OpenGL_FlipBuffers  = 12
#PB_OpenGL_SetContext   = 13

; For PB_OpenGL_Modifiers. Same as CanvasGadget for Code reuse
;
#PB_OpenGL_Shift   = #PB_Canvas_Shift
#PB_OpenGL_Alt     = #PB_Canvas_Alt
#PB_OpenGL_Control = #PB_Canvas_Control
#PB_OpenGL_Command = #PB_Canvas_Command

; For PB_OpenGL_Buttons. Same as CanvasGadget for Code reuse
;
#PB_OpenGL_LeftButton   = #PB_Canvas_LeftButton
#PB_OpenGL_RightButton  = #PB_Canvas_RightButton
#PB_OpenGL_MiddleButton = #PB_Canvas_MiddleButton

; Constants for #PB_Canvas_Cursor, maybe also
; used for other cursor stuff in the future
; (so named PB_Cursor_XXX And Not PB_Canvas_XXX)
Enumeration
  #PB_Cursor_Default
  #PB_Cursor_Cross
  #PB_Cursor_IBeam
  #PB_Cursor_Hand
  #PB_Cursor_Busy
  #PB_Cursor_Denied
  #PB_Cursor_Arrows
  #PB_Cursor_LeftRight
  #PB_Cursor_UpDown
  #PB_Cursor_LeftUpRightDown
  #PB_Cursor_LeftDownRightUp
  #PB_Cursor_Invisible
EndEnumeration


; LinkedList library (MoveElement)
;
#PB_List_First  = 1
#PB_List_Last   = 2
#PB_List_Before = 3
#PB_List_After  = 4

; Ftp library
;
#PB_FTP_ReadUser     = $400
#PB_FTP_WriteUser    = $200
#PB_FTP_ExecuteUser  = $100
#PB_FTP_ReadGroup    = $40
#PB_FTP_WriteGroup   = $20
#PB_FTP_ExecuteGroup = $10
#PB_FTP_ReadAll      = $4
#PB_FTP_WriteAll     = $2
#PB_FTP_ExecuteAll   = $1

#PB_FTP_Started  = -1
#PB_FTP_Error    = -2
#PB_FTP_Finished = -3

#PB_FTP_File      = 1
#PB_FTP_Directory = 2

; HTTP library
;
#PB_HTTP_Success     = -2
#PB_HTTP_Failed      = -3
#PB_HTTP_Aborted     = -4

#PB_HTTP_Asynchronous = (1 << 0)
#PB_HTTP_NoRedirect   = (1 << 1)
#PB_HTTP_NoSSLCheck   = (1 << 2)
#PB_HTTP_HeadersOnly  = (1 << 3)
#PB_HTTP_WeakSSL      = (1 << 4)
#PB_HTTP_Debug        = (1 << 5)

#PB_HTTP_Get = 0
#PB_HTTP_Post = 1
#PB_HTTP_Put = 2
#PB_HTTP_Patch = 3
#PB_HTTP_Delete = 4

#PB_HTTP_StatusCode = 0
#PB_HTTP_Response = 1
#PB_HTTP_ErrorMessage = 2
#PB_HTTP_Headers = 3

#PB_URL_Protocol   = "/PC/"
#PB_URL_Site       = "/WS/"
#PB_URL_Port       = "/PO/"
#PB_URL_Parameters = "/PM/"
#PB_URL_Path       = "/PT/"
#PB_URL_User       = "/US/"
#PB_URL_Password   = "/PS/"
#PB_URL_Anchor     = "/AN/"

; Mail library
;
#PB_Mail_From    = 0
#PB_Mail_Subject = 1
#PB_Mail_XMailer = 2
#PB_Mail_Date    = 3
#PB_Mail_Custom  = 4

#PB_Mail_To  = 1 << 0
#PB_Mail_Cc  = 1 << 1
#PB_Mail_Bcc = 1 << 2

#PB_Mail_Connected = -1
#PB_Mail_Error     = -2
#PB_Mail_Finished  = -3

#PB_Mail_Asynchronous = 1 << 0
#PB_Mail_UseSSL       = 1 << 1

; Map Library
;
#PB_Map_NoElementCheck = 0
#PB_Map_ElementCheck   = 1

; Memory library
;
#PB_Memory_NoClear = 1

; Menu library
;
#PB_Menu_ModernLook = 1

; Network
;
#PB_Network_TCP = 1; #SOCK_STREAM
#PB_Network_UDP = 2; #SOCK_DGRAM
#PB_Network_IPv4 = 0
#PB_Network_IPv6 = 1 << 28

#PB_NetworkEvent_None       = 0
#PB_NetworkEvent_Connect    = 1
#PB_NetworkEvent_Data       = 2
#PB_NetworkEvent_Disconnect = 4

; RegularExpression
;
#PB_RegularExpression_DotAll     = $00000004 ; #PCRE_DOTALL
#PB_RegularExpression_Extended   = $00000008 ; #PCRE_EXTENDED
#PB_RegularExpression_MultiLine  = $00000002 ; #PCRE_MULTILINE
#PB_RegularExpression_AnyNewLine = $00500000 ; #PCRE_NEWLINE_ANYCRLF
#PB_RegularExpression_NoCase     = $00000001 ; #PCRE_CASELESS


; OnError
;
; Note: The error code constants are in the OS specific files
;
CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
  Enumeration 0
    #PB_OnError_EAX
    #PB_OnError_EBX
    #PB_OnError_ECX
    #PB_OnError_EDX
    #PB_OnError_EBP
    #PB_OnError_ESI
    #PB_OnError_EDI
    #PB_OnError_ESP
    #PB_OnError_Flags
  EndEnumeration
CompilerEndIf

CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
  Enumeration 0
    #PB_OnError_RAX
    #PB_OnError_RCX
    #PB_OnError_RDX
    #PB_OnError_RBX
    #PB_OnError_RSP
    #PB_OnError_RBP
    #PB_OnError_RSI
    #PB_OnError_RDI
    #PB_OnError_R8
    #PB_OnError_R9
    #PB_OnError_R10
    #PB_OnError_R11
    #PB_OnError_R12
    #PB_OnError_R13
    #PB_OnError_R14
    #PB_OnError_R15
    #PB_OnError_Flags
  EndEnumeration
CompilerEndIf

CompilerIf #PB_Compiler_Processor = #PB_Processor_PowerPC
  Enumeration 0
    #PB_OnError_r0
    #PB_OnError_r1
    #PB_OnError_r2
    #PB_OnError_r3
    #PB_OnError_r4
    #PB_OnError_r5
    #PB_OnError_r6
    #PB_OnError_r7
    #PB_OnError_R8
    #PB_OnError_R9
    #PB_OnError_R10
    #PB_OnError_R11
    #PB_OnError_R12
    #PB_OnError_R13
    #PB_OnError_R14
    #PB_OnError_R15
    #PB_OnError_r16
    #PB_OnError_r17
    #PB_OnError_r18
    #PB_OnError_r19
    #PB_OnError_r20
    #PB_OnError_r21
    #PB_OnError_r22
    #PB_OnError_r23
    #PB_OnError_r24
    #PB_OnError_r25
    #PB_OnError_r26
    #PB_OnError_r27
    #PB_OnError_r28
    #PB_OnError_r29
    #PB_OnError_r30
    #PB_OnError_r31
    #PB_OnError_cr
    #PB_OnError_xer
    #PB_OnError_lr
    #PB_OnError_ctx
  EndEnumeration
CompilerEndIf

; Packer library
;
#PB_PackerPlugin_Zip      = 1
#PB_PackerPlugin_Lzma     = 2
#PB_PackerPlugin_Tar      = 3
#PB_PackerPlugin_BriefLZ  = 4
#PB_PackerPlugin_JCALG1   = 5

#PB_Packer_Gzip    = (1 << 16)
#PB_Packer_Bzip2   = (1 << 17)

#PB_Packer_UncompressedSize = 0
#PB_Packer_CompressedSize   = 1

#PB_Packer_File      = 0
#PB_Packer_Directory = 1

; Preference library
;
#PB_Preference_NoSpace        = 1 << 0
#PB_Preference_GroupSeparator = 1 << 1

; Screen library
;
#PB_Screen_NoSynchronization    = 0
#PB_Screen_WaitSynchronization  = 1
#PB_Screen_SmartSynchronization = 2

; Sprite library
;
#PB_Sprite_PixelCollision = 4
#PB_Sprite_AlphaBlending  = 8

#PB_Sprite_NoFiltering       = 0
#PB_Sprite_BilinearFiltering = 1

#PB_Sprite_BlendZero              = 0
#PB_Sprite_BlendOne               = 1
#PB_Sprite_BlendSourceColor       = 2
#PB_Sprite_BlendInvertSourceColor = 3
#PB_Sprite_BlendDestinationColor  = 4
#PB_Sprite_BlendInvertDestinationColor = 5
#PB_Sprite_BlendSourceAlpha       = 6
#PB_Sprite_BlendInvertSourceAlpha = 7
#PB_Sprite_BlendDestinationAlpha  = 8
#PB_Sprite_BlendInvertDestinationAlpha = 9

; System library
;
#PB_System_CPUs        = 0
#PB_System_ProcessCPUs = 1

#PB_System_TotalPhysical = 0
#PB_System_FreePhysical  = 1
#PB_System_TotalVirtual  = 2
#PB_System_FreeVirtual   = 3
#PB_System_TotalSwap     = 4
#PB_System_FreeSwap      = 5
#PB_System_PageSize      = 6
 

; Sound library
;
#PB_Sound_Loop = 1
#PB_Sound_MultiChannel = 2

#PB_Sound_Streaming = 1

#PB_Sound_Stopped = 0
#PB_Sound_Playing = 1
#PB_Sound_Paused  = 2
#PB_Sound_Unknown = 3

#PB_Sound_Millisecond = 1
#PB_Sound_Frame       = 0

; ToolBar library
;
#PB_ToolBar_Small      = 1 << 0
#PB_ToolBar_Large      = 1 << 1
#PB_ToolBar_Text       = 1 << 2
#PB_ToolBar_InlineText = 1 << 3

; Math library
;
#PB_Round_Down    = 0
#PB_Round_Up      = 1
#PB_Round_Nearest = 2

; Map library
;
#PB_Map_ElementCheck = 1
#PB_Map_NoElementCheck = 0

; SerialPortError() results
;
#PB_SerialPort_RxOver       = (1 << 0)
#PB_SerialPort_OverRun      = (1 << 1)
#PB_SerialPort_RxParity     = (1 << 2)
#PB_SerialPort_Frame        = (1 << 3)
#PB_SerialPort_Break        = (1 << 4)
#PB_SerialPort_TxFull       = (1 << 5)
#PB_SerialPort_IOE          = (1 << 6)
#PB_SerialPort_WaitingCTS   = (1 << 7)
#PB_SerialPort_WaitingDSR   = (1 << 8)
#PB_SerialPort_WaitingRLSD  = (1 << 9)
#PB_SerialPort_XoffReceived = (1 << 10)
#PB_SerialPort_XoffSent     = (1 << 11)
#PB_SerialPort_EOFSent      = (1 << 12)

; For the SetSerialPortStatus() only
;
#PB_SerialPort_DTR = 1
#PB_SerialPort_RTS = 2
#PB_SerialPort_TXD = 3

; For the GetSerialPortStatus() only
;
#PB_SerialPort_RI  = 4
#PB_SerialPort_DCD = 5
#PB_SerialPort_DSR = 6
#PB_SerialPort_CTS = 7

; For Get/SetSerialPortStatus()
#PB_SerialPort_XonCharacter  = 8
#PB_SerialPort_XoffCharacter = 9

; Handshake mode
;
#PB_SerialPort_NoHandshake = 0
#PB_SerialPort_RtsHandshake = 1
#PB_SerialPort_RtsCtsHandshake = 2
#PB_SerialPort_XonXoffHandshake = 3

; Sort library
;
#PB_Sort_Ascending  = 0
#PB_Sort_Descending = 1
#PB_Sort_NoCase     = 2

; String library
;
#PB_String_CaseSensitive = 0
#PB_String_NoCase  = 1

CompilerIf #PB_Compiler_OS <> #PB_OS_Web
  #PB_String_InPlace = 2
CompilerEndIf

#PB_String_Equal   = 0
#PB_String_Lower   = -1
#PB_String_Greater = 1

#PB_String_NoZero = 1 << 8

#PB_String_EscapeInternal = 0
#PB_String_EscapeXML      = 1

; System library
;
#PB_System_TotalPhysical = 0
#PB_System_FreePhysical  = 1
#PB_System_TotalVirtual  = 2
#PB_System_FreeVirtual   = 3
#PB_System_TotalSwap     = 4
#PB_System_FreeSwap      = 5
#PB_System_PageSize      = 6

; XML library
;
;// nodetypes
#PB_XML_Root     = 0
#PB_XML_Normal   = 1
#PB_XML_Comment  = 2
#PB_XML_CData    = 3
#PB_XML_DTD      = 4
#PB_XML_Instruction = 5

#PB_XML_StandaloneYes = 1
#PB_XML_StandaloneNo  = 0
CompilerIf #PB_Compiler_OS <> #PB_OS_Web
  #PB_XML_StandaloneUnset = -1
CompilerEndIf

;// For CatchXML
#PB_XML_StreamStart = 1
#PB_XML_StreamNext  = 2
#PB_XML_StreamEnd   = 3

;// For FormatXML
#PB_XML_WindowsNewline  = (1 << 0)
#PB_XML_LinuxNewline    = (1 << 1)
#PB_XML_MacNewline      = (1 << 2)

#PB_XML_CutNewline      = (1 << 3)
#PB_XML_ReduceNewline   = (1 << 4)

#PB_XML_CutSpace        = (1 << 5)
#PB_XML_ReduceSpace     = (1 << 6)
 
#PB_XML_ReFormat        = (1 << 7)
#PB_XML_ReIndent        = (1 << 8)

;// flags For Save/ExportXML And ExportXMLSize
#PB_XML_StringFormat    = (1 << 0)
#PB_XML_NoDeclaration   = (1 << 1)

;// flags For ExtractXMLArray/List/Map/Structure
#PB_XML_NoCase          = (1 << 9)


CompilerIf #PB_Compiler_OS = #PB_OS_Web

  Enumeration
    #PB_XML_Success
    #PB_XML_Error
  EndEnumeration
  
CompilerElse

  ; Return values for XMLStatus()
  ; The values correspond to the #XML_ERROR_... enum in expat.pb
  ;
  Enumeration
    #PB_XML_Success
    #PB_XML_NoMemory
    #PB_XML_Syntax
    #PB_XML_NoElements
    #PB_XML_InvalidToken
    #PB_XML_UnclosedToken
    #PB_XML_PartialCharacter
    #PB_XML_TagMismatch
    #PB_XML_DublicateAttribute
    #PB_XML_JunkAfterDocElement
    #PB_XML_ParamEntityRef
    #PB_XML_UndefinedEntity
    #PB_XML_RecursiveEntityRef
    #PB_XML_AsyncEntity
    #PB_XML_BadCharacterRef
    #PB_XML_BinaryEntityRef
    #PB_XML_AttributeExternalEntityRef
    #PB_XML_MisplacedXML
    #PB_XML_UnknownEncoding
    #PB_XML_IncorrectEncoding
    #PB_XML_UnclosedCDataSection
    #PB_XML_ExternalEntityHandling
    #PB_XML_NotStandalone
    #PB_XML_UnexpectedState
    #PB_XML_EntityDeclaredInPE
    #PB_XML_FeatureRequiresDTD
    #PB_XML_CantChangeFeatures
    #PB_XML_UnboundPrefix
    #PB_XML_UndeclaringPrefix
    #PB_XML_IncompletePE
    #PB_XML_XMLDeclaration
    #PB_XML_TextDeclaration
    #PB_XML_PublicID
    #PB_XML_Suspended
    #PB_XML_NotSuspended
    #PB_XML_Aborted
    #PB_XML_Finished
    #PB_XML_SuspendedPE
    #PB_XML_ReservedPrefixXML
    #PB_XML_ReservedPrefixXMLNS
    #PB_XML_ReservedNamespaceURI
  EndEnumeration
  
CompilerEndIf

; VectorDrawing lib
;
#PB_Path_Default          = 0
#PB_Path_Relative         = (1 << 0)
#PB_Path_Connected        = (1 << 1)
#PB_Path_CounterClockwise = (1 << 2)
#PB_Path_Preserve         = (1 << 3)
#PB_Path_RoundEnd         = (1 << 4)
#PB_Path_SquareEnd        = (1 << 5)
#PB_Path_RoundCorner      = (1 << 6)
#PB_Path_DiagonalCorner   = (1 << 7)
#PB_Path_Winding          = (1 << 8)

#PB_Coordinate_Device     = 0
#PB_Coordinate_Output     = 1
#PB_Coordinate_User       = 2
#PB_Coordinate_Source     = 3

#PB_Unit_Pixel            = 1
#PB_Unit_Point            = 2
#PB_Unit_Inch             = 3
#PB_Unit_Millimeter       = 4

#PB_VectorText_Default    = 0
#PB_VectorText_Visible    = (1 << 1)
#PB_VectorText_Offset     = (1 << 2)
#PB_VectorText_Baseline   = (1 << 3)

#PB_VectorImage_Default   = 0
#PB_VectorImage_Repeat    = (1 << 1)

#PB_VectorParagraph_Left   = 0
#PB_VectorParagraph_Right  = (1 << 1)
#PB_VectorParagraph_Center = (1 << 2)
#PB_VectorParagraph_Block  = (1 << 3)

; Disable all constants not supported by SpiderBasic
;
CompilerIf #PB_Compiler_OS <> #PB_OS_Web

; Printer lib
;
; Get/Set/EnablePrinterOption
#PB_Printer_Color        = (1 << 1)
#PB_Printer_Collate      = (1 << 2)
#PB_Printer_Reverse      = (1 << 3)
#PB_Printer_Landscape    = (1 << 4)
#PB_Printer_Quality      = (1 << 5)
#PB_Printer_Copies       = (1 << 6)
#PB_Printer_Range        = (1 << 7)
#PB_Printer_PageSet      = (1 << 8)
#PB_Printer_CurrentPage  = (1 << 9)
#PB_Printer_Selection    = (1 << 10)
#PB_Printer_Scale        = (1 << 11)

; #PB_Printer_Quality
#PB_PrinterQuality_Draft  = 1
#PB_PrinterQuality_Low    = 2
#PB_PrinterQuality_Normal = 3
#PB_PrinterQuality_High   = 4

; #PB_Printer_Range
#PB_PrinterRange_All       = 1
#PB_PrinterRange_Current   = 2
#PB_PrinterRange_Selection = 3
#PB_PrinterRange_Custom    = 4

; #PB_Printer_PageSet
#PB_PrinterPageSet_All     = 1
#PB_PrinterPageSet_Even    = 2
#PB_PrinterPageSet_Odd     = 3

;--------------------------------- 3D Engine Constants ----------------------------------------------

; Engine3D
;
#PB_3DArchive_FileSystem = 0
#PB_3DArchive_Zip        = 1

#PB_Node = 1
#PB_Entity = 2
#PB_Camera = 3
#PB_BillboardGroup = 4
#PB_Sound3D = 5
#PB_ParticleEmitter = 6

; Billboard
;
#PB_Billboard_Point = 0
#PB_Billboard_Oriented = 1
#PB_Billboard_SelfOriented = 2
#PB_Billboard_Perpendicular = 3
#PB_Billboard_SelfPerpendicular = 4

; Camera
;
#PB_Camera_Plot       = 2
#PB_Camera_Wireframe  = 1
#PB_Camera_Textured   = 0

#PB_Camera_Perspective  = 0
#PB_Camera_Orthographic = 1

; Effect
;
#PB_LensFlare_HaloColor   = 0
#PB_LensFlare_CircleColor = 1
#PB_LensFlare_BurstColor  = 2


; Engine3D
;
#PB_Engine3D_CurrentFPS          = 0
#PB_Engine3D_MaximumFPS          = 1
#PB_Engine3D_MinimumFPS          = 2
#PB_Engine3D_AverageFPS          = 3
#PB_Engine3D_ResetFPS            = 4
#PB_Engine3D_NbRenderedTriangles = 5
#PB_Engine3D_NbRenderedBatches   = 6

#PB_Engine3D_NoLog       = 0
#PB_Engine3D_DebugLog    = 1 << 0
#PB_Engine3D_DebugOutput = 1 << 1
#PB_Engine3D_EnableCG    = 1 << 2

; Rotations type
#PB_Orientation_PitchYawRoll = 1 << 7
#PB_Orientation_Quaternion   = 1 << 8
#PB_Orientation_Direction    = 1 << 9


#PB_Shadow_None            = 0
#PB_Shadow_Modulative      = 1
#PB_Shadow_Additive        = 2
#PB_Shadow_TextureAdditive = 3
#PB_Shadow_TextureModulative = 5



; Entity
;
#PB_Entity_CastShadow      = 1 << 2
#PB_Entity_DisplaySkeleton = 1 << 3

#PB_Entity_None           = 0
#PB_Entity_StaticBody     = 1
#PB_Entity_BoxBody        = 2
#PB_Entity_SphereBody     = 3
#PB_Entity_CylinderBody   = 4
#PB_Entity_ConvexHullBody = 5
#PB_Entity_CapsuleBody    = 7
#PB_Entity_CompoundBody   = 8
#PB_Entity_PlaneBody      = 9
#PB_Entity_ConeBody       = 10

#PB_Entity_Friction = 2
#PB_Entity_Restitution = 3
#PB_Entity_LinearVelocityX = 4
#PB_Entity_LinearVelocityY = 5
#PB_Entity_LinearVelocityZ = 6
#PB_Entity_MassCenterX = 7
#PB_Entity_MassCenterY = 8
#PB_Entity_MassCenterZ = 9
#PB_Entity_MaxVelocity = 10
#PB_Entity_LinearVelocity = 11
#PB_Entity_NbSubEntities = 12
#PB_Entity_LinearSleeping = 13
#PB_Entity_AngularSleeping = 14
#PB_Entity_DeactivationTime = 15
#PB_Entity_IsActive = 16
#PB_Entity_AngularVelocityX = 17
#PB_Entity_AngularVelocityY = 18
#PB_Entity_AngularVelocityZ = 19
#PB_Entity_AngularVelocity = 20
#PB_Entity_HasContactResponse = 21
#PB_Entity_ScaleX = 22
#PB_Entity_ScaleY = 23
#PB_Entity_ScaleZ = 24
#PB_Entity_MinVelocity = 25
#PB_Entity_ForceVelocity = 26
#PB_Entity_LinearDamping = 27
#PB_Entity_AngularDamping = 28
#PB_Entity_DisableContactResponse = 30

#PB_Entity_MinBoundingBoxX  = 1 << 0
#PB_Entity_MaxBoundingBoxX  = 1 << 1
#PB_Entity_MinBoundingBoxY  = 1 << 2
#PB_Entity_MaxBoundingBoxY  = 1 << 3
#PB_Entity_MinBoundingBoxZ  = 1 << 4
#PB_Entity_MaxBoundingBoxZ  = 1 << 5
#PB_Entity_WorldBoundingBox = 1 << 6
#PB_Entity_LocalBoundingBox = 1 << 7


; EntityAnimation
;
#PB_EntityAnimation_Once     = 1 << 0
#PB_EntityAnimation_Manual   = 1 << 1
#PB_EntityAnimation_Continue = 1 << 2

#PB_EntityAnimation_Unknown = 0
#PB_EntityAnimation_Started = 1
#PB_EntityAnimation_Stopped = 2

#PB_EntityAnimation_Average    = 0
#PB_EntityAnimation_Cumulative = 1

; GUI
;
#PB_Window3D_Invisible =  1 << 0
#PB_Window3D_SizeGadget = 1 << 1
#PB_Window3D_Borderless = 1 << 2

#PB_Event3D_Gadget = 1
#PB_Event3D_CloseWindow = 2
#PB_Event3D_SizeWindow = 3
#PB_Event3D_MoveWindow = 4
#PB_Event3D_ActivateWindow = 5

#PB_EventType3D_Focus = 1
#PB_EventType3D_LostFocus = 2
#PB_EventType3D_Change = 3

; Gadgets3D
;
Enumeration
  #PB_GadgetType3D_Unknown

  #PB_GadgetType3D_Button
  #PB_GadgetType3D_String
  #PB_GadgetType3D_Text
  #PB_GadgetType3D_CheckBox
  #PB_GadgetType3D_Option
  #PB_GadgetType3D_ListView
  #PB_GadgetType3D_Frame
  #PB_GadgetType3D_ComboBox
  #PB_GadgetType3D_Image
  #PB_GadgetType3D_Container
  #PB_GadgetType3D_ProgressBar
  #PB_GadgetType3D_ScrollBar
  #PB_GadgetType3D_ScrollArea
  #PB_GadgetType3D_Editor
  #PB_GadgetType3D_Spin
  #PB_GadgetType3D_Panel
EndEnumeration

#PB_ComboBox3D_Editable = 1

#PB_Editor3D_ReadOnly = 1

#PB_Image3D_Border = 1

#PB_ListView3D_Multiselect = 1

#PB_Panel3D_ItemWidth  = 1
#PB_Panel3D_ItemHeight = 1 << 1
#PB_Panel3D_TabHeight  = 1 << 2

#PB_ProgressBar3D_Minimum = 0
#PB_ProgressBar3D_Maximum = 1

#PB_ScrollArea3D_InnerWidth  = 1
#PB_ScrollArea3D_InnerHeight = 2
#PB_ScrollArea3D_X = 3
#PB_ScrollArea3D_Y = 4

#PB_ScrollBar3D_Vertical = 1

#PB_ScrollBar3D_Minimum    = 1
#PB_ScrollBar3D_Maximum    = 1 << 1
#PB_ScrollBar3D_PageLength = 1 << 2

#PB_Spin3D_Minimum = 1
#PB_Spin3D_Maximum = 2

#PB_String3D_ReadOnly = 1
#PB_String3D_Password = 1 << 1
#PB_String3D_Numeric  = 1 << 2

; Joint

; Attributes
#PB_PointJoint_Tau = 1
#PB_PointJoint_Damping = 2
#PB_SliderJoint_LowerLimit = 3
#PB_SliderJoint_UpperLimit = 4
#PB_ConeTwistJoint_SwingSpan = 5 ; First swing span of the joint
#PB_ConeTwistJoint_SwingSpan2 = 6 ; Second swing span of the joint
#PB_ConeTwistJoint_TwistSpan = 7 ; Twist span of the joint
#PB_HingeJoint_LowerLimit = 8
#PB_HingeJoint_UpperLimit = 9
#PB_Joint_EnableSpring = 10
#PB_Joint_Stiffness = 11
#PB_Joint_Damping = 12
#PB_Joint_Position = 13
#PB_Joint_NoLimit = 14
#PB_Joint_LowerLimit = 15
#PB_Joint_UpperLimit = 16


; Light

#PB_Light_Point = 1
#PB_Light_Directional = 2
#PB_Light_Spot = 3

#PB_Light_DiffuseColor  = 0
#PB_Light_SpecularColor = 1

; Material
;
#PB_Material_Replace    = 0
#PB_Material_Add        = 1
#PB_Material_Modulate   = 2
#PB_Material_AlphaBlend = 3
#PB_Material_Color      = 4

#PB_Material_None        = 0
#PB_Material_Bilinear    = 1
#PB_Material_Trilinear   = 2
#PB_Material_Anisotropic = 3

#PB_Material_Flat      = 1 << 0
#PB_Material_Gouraud   = 1 << 1
#PB_Material_Phong     = 1 << 2
#PB_Material_Wireframe = 1 << 3
#PB_Material_Point	   = 1 << 4
#PB_Material_Solid	   = 1 << 5

#PB_Material_Fixed    = 0
#PB_Material_Animated = 1

#PB_Material_AmbientColors = -1

; Colors
#PB_Material_DiffuseColor  = 0
#PB_Material_SpecularColor = 1
#PB_Material_AmbientColor  = 2
#PB_Material_SelfIlluminationColor = 3

; Atttributes
#PB_Material_Shininess      = 0
#PB_Material_TextureRotate  = 1
#PB_Material_TextureUScale  = 2
#PB_Material_TextureVScale  = 3
#PB_Material_TextureUScroll = 4
#PB_Material_TextureVScroll = 5
#PB_Material_DepthWrite     = 6
#PB_Material_Lighting       = 7
#PB_Material_ShadingMode    = 8
#PB_Material_CullingMode    = 9
#PB_Material_DepthCheck     = 10
#PB_Material_EnvironmentMap = 15
#PB_Material_ProjectiveTexturing = 16
#PB_Material_AlphaReject    = 17
#PB_Material_TAM            = 20

; #PB_Material_EnvironmentMap values
#PB_Material_NoMap         = -1
#PB_Material_PlanarMap     = 0
#PB_Material_CurvedMap     = 1
#PB_Material_ReflectionMap = 2
#PB_Material_NormalMap     = 3

; #PB_Material_TAM values
#PB_Material_WrapTAM   = 0
#PB_Material_MirrorTAM = 1
#PB_Material_ClampTAM  = 2
#PB_Material_BorderTAM = 3
            
#PB_Material_NoCulling         = 1
#PB_Material_ClockWiseCull     = 2
#PB_Material_AntiClockWiseCull = 3

; Mesh
;
Structure PB_MeshVertex
  x.f
  y.f
  z.f
  NormalX.f
  NormalY.f
  NormalZ.f
  TangentX.f
  TangentY.f
  TangentZ.f
  u.f
  v.f
  Color.l
EndStructure

Structure PB_MeshFace
  Index.l
EndStructure


#PB_Mesh_Vertex       = 1 << 0
#PB_Mesh_Color        = 1 << 1
#PB_Mesh_Normal       = 1 << 2
#PB_Mesh_UVCoordinate = 1 << 3
#PB_Mesh_Face         = 1 << 4
#PB_Mesh_Tangent      = 1 << 5

#PB_Mesh_PointList     = 1
#PB_Mesh_LineList      = 2
#PB_Mesh_LineStrip     = 3
#PB_Mesh_TriangleList  = 4
#PB_Mesh_TriangleStrip = 5
#PB_Mesh_TriangleFan   = 6

#PB_Mesh_Static  = 0
#PB_Mesh_Dynamic = 1

; NodeAnimation
;
#PB_NodeAnimation_Linear = 0
#PB_NodeAnimation_Spline = 1

#PB_NodeAnimation_LinearRotation    = 2
#PB_NodeAnimation_SphericalRotation = 3

#PB_NodeAnimation_Once = 1 << 0

#PB_NodeAnimation_Unknown = 0
#PB_NodeAnimation_Started = 1
#PB_NodeAnimation_Stopped = 2


; Particle
;
#PB_Particle_Point = 0
#PB_Particle_Box   = 1

#PB_Particle_Velocity        = 2
#PB_Particle_MinimumVelocity = 3
#PB_Particle_MaximumVelocity = 4


; Sound3D
;
#PB_Sound3D_Loop = 1
#PB_Sound3D_Streaming = 2

; Terrain
;
#PB_Terrain_CastShadows   = 1 << 0
#PB_Terrain_LowLODShadows = 1 << 1

#PB_Terrain_Lightmap      = 1 << 0
#PB_Terrain_NormalMapping = 1 << 1

; Texture
;
#PB_Texture_AutomaticUpdate = 1 << 0
#PB_Texture_ManualUpdate    = 1 << 1
#PB_Texture_CameraViewPort  = 1 << 2
#PB_Texture_VisibilityMask  = 1 << 3

; Text3D
;
#PB_Text3D_Left = 0
#PB_Text3D_HorizontallyCentered = 1 << 0
#PB_Text3D_Top                  = 1 << 1
#PB_Text3D_Bottom               = 1 << 2
#PB_Text3D_VerticallyCentered   = 1 << 3

; Vehicle
;
#PB_Vehicle_Friction = 1
#PB_Vehicle_MaxSuspensionForce = 2
#PB_Vehicle_MaxSuspensionCompression = 3
#PB_Vehicle_MaxSuspensionLength = 8
#PB_Vehicle_WheelDampingCompression = 4
#PB_Vehicle_WheelDampingRelaxation = 5
#PB_Vehicle_SuspensionStiffness = 6
#PB_Vehicle_RollInfluence = 7
#PB_Vehicle_IsInContact = 9
#PB_Vehicle_ContactPointX = 10
#PB_Vehicle_ContactPointY = 11
#PB_Vehicle_ContactPointZ = 12
#PB_Vehicle_ContactPointNormalX = 13
#PB_Vehicle_ContactPointNormalY = 14
#PB_Vehicle_ContactPointNormalZ = 15
#PB_Vehicle_CurrentSpeed = 16
#PB_Vehicle_ForwardVectorX = 17
#PB_Vehicle_ForwardVectorY = 18
#PB_Vehicle_ForwardVectorZ = 19


; World
;
#PB_World_WaterMediumQuality = 0
#PB_World_WaterLowQuality    = 1 << 0
#PB_World_WaterHighQuality   = 1 << 1
#PB_World_WaterCaustics      = 1 << 2
#PB_World_WaterSmooth        = 1 << 3
#PB_World_WaterFoam          = 1 << 4
#PB_World_WaterSun           = 1 << 5
#PB_World_UnderWater         = 1 << 6
#PB_World_WaterGodRays       = 1 << 7

#PB_AntialiasingMode_None = 0
#PB_AntialiasingMode_x2 = 1
#PB_AntialiasingMode_x4 = 2
#PB_AntialiasingMode_x6 = 4

#PB_World_DebugNone   = 0
#PB_World_DebugEntity = 1 << 0
#PB_World_DebugBody   = 1 << 1

#PB_World_TerrainPick = -2
#PB_World_WaterPick   = -3


; for DragDrop lib DragOSFormats()

Structure DragDataFormat
  Format.i    ; The OS specific ID for the format to drag (see below for more information)
 *Buffer      ; The memory buffer containing the data in this format
  Size.i      ; The size of the data in the buffer  EndStructure
EndStructure

CompilerEndIf
