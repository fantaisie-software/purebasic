; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Map of function parameter specific PB constants
; Format is simple comma separated entries:
;
;   <functionname>,<1-based parameter index>,#constant,#constant,...
;
; A wildcard is supported in constant names (meaning all constants starting with given prefix)
; An empty entry terminates the list.
; Sorting is not relevant but still done to easier find entries when editing.

DataSection
  
  BasicFunctionConstants:
  
  ;- A
  Data$ "AddDate,2,#PB_Date_Year,#PB_Date_Month,#PB_Date_Week,#PB_Date_Day,#PB_Date_Hour,#PB_Date_Minute,#PB_Date_Second"
  Data$ "AddKeyboardShortcut,2,#PB_Shortcut_*"
  Data$ "AddListMobileItem,3,#PB_Mobile_Chevron,#PB_Mobile_NoDivider,#PB_Mobile_LongDivider,#PB_Mobile_Expandable,#PB_Mobile_Tappable,#PB_Mobile_Header,#PB_Mobile_Container"
  Data$ "AddMapElement,3,#PB_Map_ElementCheck,#PB_Map_NoElementCheck"
  Data$ "AddPathArc,6,#PB_Path_Default,#PB_Path_Relative"
  Data$ "AddPathBox,5,#PB_Path_Default,#PB_Path_Relative,#PB_Path_Connected"
  Data$ "AddPathCircle,6,#PB_Path_Default,#PB_Path_Relative,#PB_Path_Connected,#PB_Path_CounterClockwise"
  Data$ "AddPathCurve,7,#PB_Path_Default,#PB_Path_Relative"
  Data$ "AddPathEllipse,7,#PB_Path_Default,#PB_Path_Relative,#PB_Path_Connected,#PB_Path_CounterClockwise"
  Data$ "AddPathLine,3,#PB_Path_Default,#PB_Path_Relative"
  Data$ "AddPathSegments,2,#PB_Path_Default,#PB_Path_Relative"
  Data$ "AddScreenShader,1,PB_Shader_Blur,PB_Shader_Noise,#PB_Shader_Pixelate,#PB_Shader_Bevel,#PB_Shader_BulgePinch,#PB_Shader_Adjustment,#PB_Shader_Reflection"
  Data$ "AddSpriteShader,2,PB_Shader_Blur,PB_Shader_Noise,#PB_Shader_Pixelate,#PB_Shader_Bevel,#PB_Shader_BulgePinch,#PB_Shader_Adjustment"
  Data$ "AESDecoder,9,#PB_Cipher_CBC,#PB_Cipher_ECB"
  Data$ "AESEncoder,9,#PB_Cipher_CBC,#PB_Cipher_ECB"
  Data$ "AllocateMemory,2,#PB_Memory_NoClear"
  
  ;- B
  Data$ "Base64Encoder,4,#PB_Cipher_NoPadding,#PB_Cipher_URL"
  Data$ "Base64EncoderBuffer,7,#PB_Cipher_NoPadding,#PB_Cipher_URL"
  Data$ "Bin,2,#PB_Quad,#PB_Byte,#PB_Ascii,#PB_Word,#PB_Unicode,#PB_Long"
  Data$ "BindEvent,1,#PB_Event_*"
  Data$ "BindEvent,3,#PB_All"
  Data$ "BindEvent,4,#PB_All"
  Data$ "BindEvent,5,#PB_All,#PB_EventType_*"
  Data$ "BindGadgetEvent,3,#PB_All,#PB_EventType_*"
  Data$ "ButtonGadget,1,#PB_Any"
  Data$ "ButtonGadget,7,#PB_Button_Right,#PB_Button_Left,#PB_Button_Default,#PB_Button_MultiLine,#PB_Button_Toggle"
  Data$ "ButtonImageGadget,1,#PB_Any"
  Data$ "ButtonImageGadget,7,#PB_Button_Toggle"
  Data$ "ButtonMobile,1,#PB_Any"
  Data$ "ButtonMobile,3,#PB_Mobile_Icon,#PB_Mobile_BackButton,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right"

  
  ;- C
  Data$ "CalendarGadget,1,#PB_Any"
  Data$ "CalendarGadget,7,#PB_Calendar_Borderless"
  Data$ "CancelNotification,1,#PB_All"
  Data$ "CanvasGadget,1,#PB_Any"
  Data$ "CanvasGadget,6,#PB_Canvas_Border,#PB_Canvas_Keyboard,#PB_Canvas_DrawFocus,#PB_Canvas_Transparent,#PB_Canvas_Container"
  Data$ "CanvasVectorOutput,2,#PB_Unit_Pixel,#PB_Unit_Point,#PB_Unit_Inch,#PB_Unit_Millimeter"
  Data$ "ChangeNavigatorMobilePage,2,#PB_Mobile_Push,#PB_Mobile_Pop"
  Data$ "CheckBoxGadget,1,#PB_Any"
  Data$ "CheckBoxGadget,7,#PB_CheckBox_Right,#PB_CheckBox_Center,#PB_CheckBox_ThreeState"
  Data$ "CheckBoxMobile,1,#PB_Any"
  Data$ "CheckBoxMobile,3,#PB_Mobile_Left,#PB_Mobile_Right"
  Data$ "ClipPath,1,#PB_Path_Default,#PB_Path_Preserve"
  Data$ "ClipSprite,2,#PB_Default"
  Data$ "ClipSprite,3,#PB_Default"
  Data$ "ClipSprite,4,#PB_Default"
  Data$ "ClipSprite,5,#PB_Default"
  Data$ "CloseDatabase,1,#PB_All"
  Data$ "CloseFile,1,#PB_All"
  Data$ "CloseWindow,1,#PB_All"
  Data$ "ComboBoxGadget,1,#PB_Any"
  Data$ "ComboBoxGadget,6,#PB_ComboBox_Editable,#PB_ComboBox_LowerCase,#PB_ComboBox_UpperCase,#PB_ComboBox_Image"
  Data$ "ComboBoxGadget3D,1,#PB_Any"
  Data$ "ComboBoxGadget3D,6,#PB_ComboBox3D_Editable"
  Data$ "CompareMemoryString,3,#PB_String_CaseSensitive,#PB_String_NoCase"
  Data$ "CompareMemoryString,5,#PB_UTF8,#PB_Ascii,#PB_Unicode"
  Data$ "ComposeJSON,2,#PB_JSON_PrettyPrint"
  Data$ "ContainerGadget,1,#PB_Any"
  Data$ "ContainerGadget,6,#PB_Container_BorderLess,#PB_Container_Flat,#PB_Container_Raised,#PB_Container_Single,#PB_Container_Double"
  Data$ "ContainerMobile,1,#PB_Any"
  Data$ "ContainerMobile,2,#PB_Mobile_Page,#PB_Mobile_Template,#PB_Mobile_Dialog,#PB_Mobile_PopOver,#PB_Mobile_Row,#PB_Mobile_Section"
  Data$ "ConvertCoordinateX,3,#PB_Coordinate_Device,#PB_Coordinate_Output,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "ConvertCoordinateX,4,#PB_Coordinate_Device,#PB_Coordinate_Output,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "ConvertCoordinateY,3,#PB_Coordinate_Device,#PB_Coordinate_Output,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "ConvertCoordinateY,4,#PB_Coordinate_Device,#PB_Coordinate_Output,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "CopyImage,2,#PB_Any"
  Data$ "CopySprite,2,#PB_Any"
  Data$ "CopySprite,3,#PB_Sprite_PixelCollision,#PB_Sprite_AlphaBlending "
  Data$ "CreateDialog,1,#PB_Any"
  Data$ "CreateFile,1,#PB_Any"
  Data$ "CreateFile,4,#PB_UTF8,#PB_Ascii,#PB_Unicode,#PB_LocalStorage"
  Data$ "CreateImage,1,#PB_Any"
  ;Data$ "CreateImage,5,#PB_Image_Transparent"  ; leave out to keep all color constants as allowed too
  Data$ "CreateImageMenu,1,#PB_Any"
  Data$ "CreateJSON,1,#PB_Any"
  Data$ "CreateMenu,1,#PB_Any"
  Data$ "CreateNotification,1,#PB_Any"
  Data$ "CreateNotification,4,#PB_Notification_Secret,#PB_Notification_Progress"
  Data$ "CreatePopupImageMenu,1,#PB_Any"
  Data$ "CreatePopupMenu,1,#PB_Any"
  Data$ "CreateRegularExpression,1,#PB_Any"
  Data$ "CreateRegularExpression,3,#PB_RegularExpression_DotAll,#PB_RegularExpression_Extended,#PB_RegularExpression_MultiLine,#PB_RegularExpression_AnyNewLine,#PB_RegularExpression_NoCase"
  Data$ "CreateSprite,1,#PB_Any"
  Data$ "CreateSprite,4,#PB_Sprite_PixelCollision,#PB_Sprite_AlphaBlending"
  Data$ "CreateToolBar,1,#PB_Any"
  Data$ "CreateXML,1,#PB_Any"
  Data$ "CreateXML,2,#PB_UTF8,#PB_Ascii,#PB_Unicode"
  Data$ "CreateXMLNode,4,#PB_XML_Normal,#PB_XML_Comment,#PB_XML_CData,#PB_XML_DTD,#PB_XML_Instruction"
  Data$ "CustomDashPath,3,#PB_Path_Default,#PB_Path_Preserve,#PB_Path_RoundEnd,#PB_Path_SquareEnd,#PB_Path_RoundCorner,#PB_Path_DiagonalCorner"
  
  ;- D
  Data$ "DashPath,3,#PB_Path_Default,#PB_Path_Preserve,#PB_Path_RoundEnd,#PB_Path_SquareEnd,#PB_Path_RoundCorner,#PB_Path_DiagonalCorner"
  Data$ "DateGadget,1,#PB_Any"
  Data$ "DateGadget,8,#PB_Date_UpDown,#PB_Date_Checkbox"
  Data$ "Defined,2,#PB_Constant,#PB_Variable,#PB_Array,#PB_List,#PB_Map,#PB_Structure,#PB_Interface,#PB_Procedure,#PB_Function,#PB_OSFunction,#PB_Label,#PB_Prototype,#PB_Module,#PB_Enumeration"
  Data$ "DeviceAlwaysOn,1,#True,#False"
  Data$ "DeviceBrightness,1,#Default"
  Data$ "DeviceInfo,1,#PB_Device_Model,#PB_Device_Platform,#PB_Device_UUID,#PB_Device_Version,#PB_Device_Manufacturer,#PB_Device_Serial"
  Data$ "DisableGadget,2,#True,#False"
  Data$ "DisableMenuItem,3,#True,#False"
  Data$ "DisableToolBarButton,3,#True,#False"
  Data$ "DisableWindow,2,#True,#False"
  Data$ "DotPath,3,#PB_Path_Default,#PB_Path_Preserve,#PB_Path_RoundEnd,#PB_Path_SquareEnd"
  Data$ "DrawingMode,1,#PB_2DDrawing_Default,#PB_2DDrawing_Transparent,#PB_2DDrawing_XOr,#PB_2DDrawing_Outlined,#PB_2DDrawing_AlphaBlend,#PB_2DDrawing_AlphaClip,#PB_2DDrawing_AlphaChannel,#PB_2DDrawing_AllChannels,#PB_2DDrawing_Gradient,#PB_2DDrawing_CustomFilter"
  
  ;- E
  Data$ "EditorGadget,1,#PB_Any"
  Data$ "EditorGadget,6,#PB_Editor_ReadOnly,#PB_Editor_WordWrap"
  Data$ "EncodeImage,2,#PB_ImagePlugin_JPEG,#PB_ImagePlugin_PNG"
  Data$ "ExportJSON,4,#PB_JSON_PrettyPrint"
  
  ;- F
  Data$ "FileSeek,3,#PB_Absolute,#PB_Relative"
  Data$ "FillPath,1,#PB_Path_Default,#PB_Path_Preserve"
  Data$ "FindString,4,#PB_String_CaseSensitive,#PB_String_NoCase"
  Data$ "Fingerprint,4,#PB_Cipher_CRC32,#PB_Cipher_MD5,#PB_Cipher_SHA1,#PB_Cipher_SHA2,#PB_Cipher_SHA3"
  Data$ "FrameGadget,1,#PB_Any"
  Data$ "FrameGadget,7,#PB_Frame_Single,#PB_Frame_Double,#PB_Frame_Flat"
  Data$ "FreeDialog,1,#PB_All"
  Data$ "FreeFont,1,#PB_All"
  Data$ "FreeGadget,1,#PB_All"
  Data$ "FreeImage,1,#PB_All"
  Data$ "FreeJSON,1,#PB_All"
  Data$ "FreeMenu,1,#PB_All"
  Data$ "FreeNotification,1,#PB_All"
  Data$ "FreeRegularExpression,1,#PB_All"
  Data$ "FreeSound,1,#PB_All"
  Data$ "FreeSprite,1,#PB_All"
  Data$ "FreeXML,1,#PB_All"
  
  ;- G
  Data$ "GadgetHeight,2,#PB_Gadget_ActualSize,#PB_Gadget_RequiredSize"
  Data$ "GadgetWidth,2,#PB_Gadget_ActualSize,#PB_Gadget_RequiredSize"
  Data$ "GadgetX,2,#PB_Gadget_ContainerCoordinate,#PB_Gadget_WindowCoordinate,#PB_Gadget_ScreenCoordinate"
  Data$ "GadgetY,2,#PB_Gadget_ContainerCoordinate,#PB_Gadget_WindowCoordinate,#PB_Gadget_ScreenCoordinate"
  ;Data$ "GetGadgetAttribute,2,"     ; leave out because of the many different constants depending on the gadget type
  Data$ "GetGadgetColor,2,#PB_Gadget_FrontColor,#PB_Gadget_BackColor,#PB_Gadget_LineColor,#PB_Gadget_TitleFrontColor,#PB_Gadget_TitleBackColor,#PB_Gadget_GrayTextColor"
  Data$ "GetGadgetItemAttribute,2,#PB_Explorer_ColumnWidth,#PB_ListIcon_ColumnWidth,#PB_Tree_SubLevel"
  Data$ "GetGadgetItemColor,3,#PB_Gadget_FrontColor,#PB_Gadget_BackColor"
  Data$ "GetMobileAttribute,2,#PB_Mobile_TabLabel,#PB_Mobile_TabIcon,#PB_Mobile_TabActiveIcon,#PB_Mobile_TabBadge"
  Data$ "GrabImage,2,#PB_Any"
  
  ;- H
  Data$ "Hex,2,#PB_Quad,#PB_Byte,#PB_Ascii,#PB_Word,#PB_Unicode,#PB_Long"
  Data$ "HideBillboardGroup,2,#True,#False"
  Data$ "HideEffect,2,#True,#False"
  Data$ "HideEntity,2,#True,#False"
  Data$ "HideGadget,2,#True,#False"
  Data$ "HideGadget3D,2,#True,#False"
  Data$ "HideLight,2,#True,#False"
  Data$ "HideMenu,2,#True,#False"
  Data$ "HideParticleEmitter,2,#True,#False"
  Data$ "HideWindow,2,#True,#False"
  Data$ "HideWindow,3,#PB_Window_NoActivate,#PB_Window_ScreenCentered,#PB_Window_WindowCentered"
  Data$ "HTTPInfo,1,#PB_HTTP_StatusCode,#PB_HTTP_StatusText,#PB_HTTP_Headers"
  Data$ "HTTPRequest,1,#PB_HTTP_Get,#PB_HTTP_Post,#PB_HTTP_Put,#PB_HTTP_Patch,#PB_HTTP_Delete"
  Data$ "HyperLinkGadget,1,#PB_Any"
  Data$ "HyperLinkGadget,8,#PB_Hyperlink_Underline"
  
  ;- I
  Data$ "IconMobile,1,#PB_Any"
  Data$ "IconMobile,3,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right"
  Data$ "ImageMobile,1,#PB_Any"
  Data$ "ImageMobile,3,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right"
  Data$ "ImageGadget,1,#PB_Any"
  Data$ "ImageGadget,7,#PB_Image_Border,#PB_Image_Raised"
  Data$ "ImageVectorOutput,2,#PB_Unit_Pixel,#PB_Unit_Point,#PB_Unit_Inch,#PB_Unit_Millimeter"
  Data$ "InputMobile,1,#PB_Any"
  Data$ "InputMobile,4,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right,#PB_Mobile_Search,#PB_Mobile_Password,#PB_Mobile_Numeric"
  Data$ "IsInsidePath,3,#PB_Coordinate_Device,#PB_Coordinate_Output,#PB_Coordinate_User,#PB_Coordinate_Source"
  
  ;- J
  Data$ "JoystickAxisX,3,#PB_Absolute,#PB_Relative"
  Data$ "JoystickAxisY,3,#PB_Absolute,#PB_Relative"
  Data$ "JoystickAxisZ,3,#PB_Absolute,#PB_Relative"
  
  ;- K
  Data$ "KeyboardPushed,1,#PB_Key_*"
  Data$ "KeyboardReleased,1,#PB_Key_*"
  
  ;- L
  Data$ "ListIconGadget,1,#PB_Any"
  Data$ "ListIconGadget,8,#PB_ListIcon_CheckBoxes,#PB_ListIcon_MultiSelect,#PB_ListIcon_GridLines,#PB_ListIcon_FullRowSelect,#PB_ListIcon_AlwaysShowSelection"
  Data$ "ListMobile,1,#PB_Any"
  Data$ "ListMobile,2,#PB_Mobile_InSet"
  Data$ "ListViewGadget,1,#PB_Any"
  Data$ "ListViewGadget,6,#PB_ListView_Multiselect,#PB_ListView_ClickSelect"
  Data$ "ListViewGadget3D,1,#PB_Any"
  Data$ "LoadFont,1,#PB_Any"
  Data$ "LoadFont,4,#PB_Font_Bold,#PB_Font_Italic,#PB_Font_Underline,#PB_Font_StrikeOut,#PB_Font_HighQuality"
  Data$ "LoadImage,1,#PB_Any"
  Data$ "LoadImage,3,#PB_LocalFile,#PB_Image_PNGBase64,#PB_Image_JPEGBase64"
  Data$ "LoadJSON,1,#PB_Any"
  Data$ "LoadJSON,3,#PB_LocalFile"
  Data$ "LoadScript,3,#PB_Script_JavaScript,#PB_Script_CSS"
  Data$ "LoadSound,1,#PB_Any"
  Data$ "LoadSprite,1,#PB_Any"
  Data$ "LoadSprite,3,#PB_Sprite_PixelCollision,#PB_Sprite_AlphaBlending"
  Data$ "LoadXML,1,#PB_Any"
  Data$ "LoadXML,4,#PB_LocalFile"
  
  ;- M
  Data$ "MergeLists,3,#PB_List_Last,#PB_List_First,#PB_List_Before,#PB_List_After"
  Data$ "MessageRequester,2,#PB_MessageRequester_Ok,#PB_MessageRequester_YesNo"
  Data$ "MobileStyle,1,#PB_Mobile_iOS,#PB_Mobile_Android"
  Data$ "MouseButton,1,#PB_MouseButton_Left,#PB_MouseButton_Right,#PB_MouseButton_Middle"
  
  ;- N
  Data$ "NavigatorMobile,1,#PB_Any"
  Data$ "NavigatorMobile,3,#PB_Mobile_Swipeable"
  
  ;- O
  Data$ "OpenDatabase,1,#PB_Any"
  Data$ "OpenFile,1,#PB_Any"
  Data$ "OpenFile,4,PB_LocalFile,#PB_GoogleDriveFile,#PB_File_Streaming,#PB_LocalStorage,#PB_Ascii,#PB_UTF8,#PB_Unicode"
  Data$ "OpenFileRequester,3,#PB_Requester_MultiSelection,#PB_Requester_GoogleDrive"
  Data$ "OpenWindow,1,#PB_Any"
  Data$ "OpenWindow,7,#PB_Window_SystemMenu,#PB_Window_Background,#PB_Window_SizeGadget,#PB_Window_Invisible,#PB_Window_TitleBar,#PB_Window_Tool,#PB_Window_BorderLess,#PB_Window_ScreenCentered,#PB_Window_WindowCentered,#PB_Window_NoGadgets,#PB_Window_NoActivate,#PB_Window_NoMove"
  Data$ "OptionGadget,1,#PB_Any"
  Data$ "OptionMobile,1,#PB_Any"
  Data$ "OptionMobile,3,#PB_Mobile_Left,#PB_Mobile_Right"
  
  ;- P
  Data$ "PanelGadget,1,#PB_Any"
  Data$ "ParseJSON,1,#PB_Any"
  Data$ "ParseXML,1,#PB_Any"
  Data$ "PeekS,4,#PB_Ascii,#PB_UTF8,#PB_Unicode,#PB_ByteLength"
  Data$ "PlaySound,2,#PB_Sound_Loop,#PB_Sound_MultiChannel"
  Data$ "PokeS,5,#PB_Ascii,#PB_UTF8,#PB_Unicode,#PB_String_NoZero"
  Data$ "PostEvent,1,#PB_Event_*"
  Data$ "PostEvent,4,#PB_EventType_*"
  Data$ "ProgressBarGadget,1,#PB_Any"
  Data$ "ProgressBarGadget,8,#PB_ProgressBar_Smooth"
  Data$ "ProgressBarMobile,1,#PB_Any"
  Data$ "ProgressBarMobile,2,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right,#PB_Mobile_Circular,#PB_Mobile_Indeterminate"
  
  ;- R
  Data$ "ReadCharacter,2,#PB_Ascii,#PB_Unicode,#PB_UTF8"
  Data$ "ReadFile,1,#PB_Any"
  Data$ "ReadFile,4,#PB_LocalFile,#PB_GoogleDriveFile,#PB_File_Streaming,#PB_LocalStorage,#PB_Ascii,#PB_UTF8,#PB_Unicode"
  Data$ "ReadString,2,#PB_Ascii,#PB_UTF8,#PB_Unicode,#PB_File_IgnoreEOL"
  Data$ "ReAllocateMemory,3,#PB_Memory_NoClear"
  Data$ "RegisterAppProduct,3,#PB_Product_Consumable,#PB_Product_NonConsumable"
  Data$ "ReleaseMouse,1,#True,#False"
  Data$ "RemoveKeyboardShortcut,2,#PB_Shortcut_*"
  Data$ "RemoveScreenShader,1,PB_Shader_Blur,PB_Shader_Noise,#PB_Shader_Pixelate,#PB_Shader_Bevel,#PB_Shader_BulgePinch,#PB_Shader_Adjustment,#PB_Shader_Reflection"
  Data$ "RemoveSpriteShader,2,PB_Shader_Blur,PB_Shader_Noise,#PB_Shader_Pixelate,#PB_Shader_Bevel,#PB_Shader_BulgePinch,#PB_Shader_Adjustment"
  Data$ "RemoveString,3,#PB_String_CaseSensitive,#PB_String_NoCase"
  Data$ "ReplaceString,4,#PB_String_CaseSensitive,#PB_String_NoCase"
  Data$ "ResetCoordinates,1,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "ResizeImage,4,#PB_Image_Smooth,#PB_Image_Raw"
  Data$ "RotateCoordinates,4,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "RotateSprite,3,#PB_Absolute,#PB_Relative"
  Data$ "Round,2,#PB_Round_Down,#PB_Round_Up,#PB_Round_Nearest"
  
  ;- S
  Data$ "ScaleCoordinates,3,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "ScheduleNotification,2,#PB_Notification_Now,#PB_Notification_At,#PB_Notification_InSecond,#PB_Notification_InMinute,#PB_Notification_InHour,#PB_Notification_InDay,#PB_Notification_InWeek,#PB_Notification_InMonth,#PB_Notification_InQuarter,#PB_Notification_InYear,#PB_Notification_EveryDate,#PB_Notification_EveryMinute,#PB_Notification_EveryHour,#PB_Notification_EveryDay,#PB_Notification_EveryWeek,#PB_Notification_EveryMonth,#PB_Notification_EveryYear"
  Data$ "ScrollAreaGadget,1,#PB_Any"
  Data$ "ScrollAreaGadget,9,#PB_ScrollArea_Flat,#PB_ScrollArea_Raised,#PB_ScrollArea_Single,#PB_ScrollArea_BorderLess,#PB_ScrollArea_Center"
  ;Data$ "SetGadgetAttribute,2,"      ; leave out because of the many different constants depending on the gadget type
  ;Data$ "SetGadgetAttribute3D,2,"    ; leave out because of the many different constants depending on the gadget type
  Data$ "SetGadgetColor,2,#PB_Gadget_FrontColor,#PB_Gadget_BackColor,#PB_Gadget_LineColor,#PB_Gadget_TitleFrontColor,#PB_Gadget_TitleBackColor,#PB_Gadget_GrayTextColor"
  Data$ "SetGadgetFont,1,#PB_Default"
  Data$ "SetGadgetItemAttribute,3,#PB_ListIcon_ColumnWidth"
  Data$ "SetMobileAttribute,2,#PB_Mobile_TabLabel,#PB_Mobile_TabIcon,#PB_Mobile_TabActiveIcon,#PB_Mobile_TabBadge"
  Data$ "SetSoundPosition,3,#PB_Sound_Frame,#PB_Sound_Millisecond"
  Data$ "SetToolBarButtonState,3,#True,#False"
  Data$ "SetXMLEncoding,2,#PB_Ascii,#PB_Unicode,#PB_UTF8"
  Data$ "SetXMLStandalone,2,#PB_XML_StandaloneYes,#PB_XML_StandaloneNo"
  Data$ "SkewCoordinates,3,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "SortArray,2,#PB_Sort_Ascending,#PB_Sort_Descending,#PB_Sort_NoCase"
  Data$ "SortList,2,#PB_Sort_Ascending,#PB_Sort_Descending,#PB_Sort_NoCase"
  Data$ "SoundLength,2,#PB_Sound_Frame,#PB_Sound_Millisecond"
  Data$ "SpinGadget,1,#PB_Any"
  Data$ "SpinGadget,8,#PB_Spin_ReadOnly,#PB_Spin_Numeric"
  Data$ "SplashScreenControl,1,#PB_SplashScreen_AutoClose,#PB_SplashScreen_NoAutoClose,#PB_SplashScreen_Close"
  Data$ "SplitList,3,#True,#False"
  Data$ "SplitterGadget,1,#PB_Any"
  Data$ "SplitterGadget,8,#PB_Splitter_Vertical,#PB_Splitter_Separator,#PB_Splitter_FirstFixed,#PB_Splitter_SecondFixed"
  Data$ "SplitterMobile,1,#PB_Any"
  Data$ "SpriteQuality,1,#PB_Sprite_NoFiltering,#PB_Sprite_BilinearFiltering"
  Data$ "ScreenShaderAttribute,1,#PB_BlurShader_Intensity,#PB_BlurShader_Quality,#PB_NoiseShader_Seed,#PB_NoiseShader_Intensity,#PB_PixelateShader_SizeX,#PB_PixelateShader_SizeY,#PB_BevelShader_Thickness,#PB_BevelShader_Rotation,#PB_BevelShader_LightColor,#PB_BevelShader_ShadowColor,#PB_BulgePinchShader_Strength,#PB_BulgePinchShader_CenterX,#PB_BulgePinchShader_CenterY,#PB_BulgePinchShader_Radius,#PB_AdjustmentShader_Alpha,#PB_AdjustmentShader_Gamma,#PB_AdjustmentShader_Saturation,#PB_AdjustmentShader_Contrast,#PB_AdjustmentShader_Brightness,#PB_AdjustmentShader_Red,#PB_AdjustmentShader_Green,#PB_AdjustmentShader_Blue,#PB_ReflectionShader_AlphaStart,#PB_ReflectionShader_AlphaEnd,#PB_ReflectionShader_Boundary,#PB_ReflectionShader_AmplitudeStart,#PB_ReflectionShader_AmplitudeEnd,#PB_ReflectionShader_WaveLengthStart,#PB_ReflectionShader_WaveLengthEnd,#PB_ReflectionShader_Mirror,#PB_ReflectionShader_Time"
  Data$ "SpriteShaderAttribute,2,#PB_BlurShader_Intensity,#PB_BlurShader_Quality,#PB_NoiseShader_Seed,#PB_NoiseShader_Intensity,#PB_PixelateShader_SizeX,#PB_PixelateShader_SizeY,#PB_BevelShader_Thickness,#PB_BevelShader_Rotation,#PB_BevelShader_LightColor,#PB_BevelShader_ShadowColor,#PB_BulgePinchShader_Strength,#PB_BulgePinchShader_CenterX,#PB_BulgePinchShader_CenterY,#PB_BulgePinchShader_Radius,#PB_AdjustmentShader_Alpha,#PB_AdjustmentShader_Gamma,#PB_AdjustmentShader_Saturation,#PB_AdjustmentShader_Contrast,#PB_AdjustmentShader_Brightness,#PB_AdjustmentShader_Red,#PB_AdjustmentShader_Green,#PB_AdjustmentShader_Blue"
  Data$ "StartAESCipher,5,#PB_Cipher_Decode,#PB_Cipher_Encode,#PB_Cipher_CBC,#PB_Cipher_ECB"
  Data$ "StartFingerprint,2,#PB_Cipher_CRC32,#PB_Cipher_MD5,#PB_Cipher_SHA1,#PB_Cipher_SHA2,#PB_Cipher_SHA3"
  Data$ "StickyWindow,2,#True,#False"
  Data$ "StringFingerprint,2,#PB_Cipher_CRC32,#PB_Cipher_MD5,#PB_Cipher_SHA1,#PB_Cipher_SHA2,#PB_Cipher_SHA3"
  Data$ "StringFingerprint,4,#PB_UTF8,#PB_Ascii,#PB_Unicode"
  Data$ "StringGadget,1,#PB_Any"
  Data$ "StringGadget,7,#PB_String_Numeric,#PB_String_Password,#PB_String_ReadOnly,#PB_String_LowerCase,#PB_String_UpperCase,#PB_String_BorderLess,#PB_String_PlaceHolder"
  Data$ "StrokePath,2,#PB_Path_Default,#PB_Path_Preserve,#PB_Path_RoundEnd,#PB_Path_SquareEnd,#PB_Path_RoundCorner,#PB_Path_DiagonalCorner"
  Data$ "StrU,2,#PB_Quad,#PB_Byte,#PB_Ascii,#PB_Word,#PB_Unicode,#PB_Long"
  Data$ "SwitchMobile,1,#PB_Any"
  Data$ "SwitchMobile,2,#PB_Mobile_Left,#PB_Mobile_Right,#PB_Mobile_Center"
  
  ;- T
  Data$ "TabBarMobile,1,#PB_Any"
  Data$ "TabBarMobile,2,#PB_Mobile_Swipeable"
  Data$ "ToolBarImageButton,3,#PB_ToolBar_Normal,#PB_ToolBar_Toggle"
  Data$ "TextGadget,1,#PB_Any"
  Data$ "TextGadget,7,#PB_Text_Center,#PB_Text_VerticalCenter,#PB_Text_Right,#PB_Text_Border"
  Data$ "TextMobile,1,#PB_Any"
  Data$ "TextMobile,3,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right"
  Data$ "ToolBarMobile,1,#PB_Any"
  Data$ "ToolBarImageButton,3,#PB_ToolBar_Normal,#PB_ToolBar_Toggle"
  Data$ "TrackBarGadget,1,#PB_Any"
  Data$ "TrackBarGadget,8,#PB_TrackBar_Vertical"
  Data$ "TrackBarMobile,1,#PB_Any"
  Data$ "TrackBarMobile,5,#PB_Mobile_Left,#PB_Mobile_Center,#PB_Mobile_Right"
  Data$ "TranslateCoordinates,3,#PB_Coordinate_User,#PB_Coordinate_Source"
  Data$ "TreeGadget,1,#PB_Any"
  Data$ "TreeGadget,6,#PB_Tree_AlwaysShowSelection,#PB_Tree_NoLines,#PB_Tree_NoButtons"
  
  ;- U
  Data$ "UnbindEvent,1,#PB_Event_*"
  Data$ "UnbindEvent,5,#PB_EventType_*"
  Data$ "UnbindGadgetEvent,3,#PB_EventType_*"
  
  ;- V
  Data$ "VectorTextHeight,2,#PB_VectorText_Default,#PB_VectorText_Visible,#PB_VectorText_Offset,#PB_VectorText_Baseline"
  Data$ "VectorTextWidth,2,#PB_VectorText_Default,#PB_VectorText_Visible,#PB_VectorText_Offset"
  
  ;- W
  Data$ "WindowHeight,2,#PB_Window_InnerCoordinate,#PB_Window_FrameCoordinate"
  Data$ "WindowWidth,2,#PB_Window_InnerCoordinate,#PB_Window_FrameCoordinate"
  Data$ "WindowX,2,#PB_Window_FrameCoordinate,#PB_Window_InnerCoordinate"
  Data$ "WindowY,2,#PB_Window_FrameCoordinate,#PB_Window_InnerCoordinate"
  Data$ "WriteCharacter,3,#PB_Ascii,#PB_Unicode,#PB_UTF8"
  Data$ "WriteString,3,#PB_Ascii,#PB_UTF8,#PB_Unicode"
  Data$ "WriteStringFormat,2,#PB_Ascii,#PB_UTF8,#PB_Unicode,#PB_UTF16BE,#PB_UTF32,#PB_UTF32BE"
  Data$ "WriteStringN,3,#PB_Ascii,#PB_UTF8,#PB_Unicode"
  
  ;- X
  ; Nothing yet
  
  ;- Y
  ; Nothing yet
  
  ;- Z
  Data$ "ZoomSprite,2,#PB_Default"
  Data$ "ZoomSprite,3,#PB_Default"
  
  ; Termination of list
  Data$ ""
  
EndDataSection