/* Unicode and threads functions aliases, to share the file
 * between all OS
 *
 * Note: only the functions which are always unicode are found here
 */

/* AudioCD */
#define PB_AudioCDName  M_UnicodeFunction(PB_AudioCDName)

/* Clipboard */
#define PB_GetClipboardText  M_UnicodeFunction(PB_GetClipboardText)
#define PB_SetClipboardText  M_UnicodeFunction(PB_SetClipboardText)

/* Console */
#define PB_Inkey        M_UnicodeFunction(PB_Inkey)
#define PB_Input        M_UnicodeFunction(PB_Input)
#define PB_Print        M_UnicodeFunction(PB_Print)
#define PB_PrintN       M_UnicodeFunction(PB_PrintN)
#define PB_ConsoleError M_UnicodeFunction(PB_ConsoleError)
#define PB_ConsoleTitle M_UnicodeFunction(PB_ConsoleTitle)
#define PB_OpenConsole  M_UnicodeFunction(PB_OpenConsole)
#define PB_OpenConsole2 M_UnicodeFunction(PB_OpenConsole2)



/* Desktop */
#define PB_DesktopName M_UnicodeFunction(PB_DesktopName)

/* Drag & Drop */
#define PB_DragText   M_UnicodeFunction(PB_DragText)
#define PB_DragImage  M_UnicodeFunction(PB_DragImage)
#define PB_DragFiles  M_UnicodeFunction(PB_DragFiles)
#define PB_DragText2  M_UnicodeFunction(PB_DragText2)
#define PB_DragImage2 M_UnicodeFunction(PB_DragImage2)
#define PB_DragFiles2 M_UnicodeFunction(PB_DragFiles2)

#define PB_EnableGadgetDrop  M_UnicodeFunction(PB_EnableGadgetDrop)
#define PB_EnableGadgetDrop2 M_UnicodeFunction(PB_EnableGadgetDrop2)
#define PB_EnableWindowDrop  M_UnicodeFunction(PB_EnableWindowDrop)
#define PB_EnableWindowDrop2 M_UnicodeFunction(PB_EnableWindowDrop2)

#define PB_EventDropType   M_UnicodeFunction(PB_EventDropType)
#define PB_EventDropText   M_UnicodeFunction(PB_EventDropText)
#define PB_EventDropImage  M_UnicodeFunction(PB_EventDropImage)
#define PB_EventDropImage2 M_UnicodeFunction(PB_EventDropImage2)
#define PB_EventDropFiles  M_UnicodeFunction(PB_EventDropFiles)

/* Font */
#define PB_RegisterFont M_UnicodeFunction(PB_RegisterFont)
#define PB_LoadFont     M_UnicodeFunction(PB_LoadFont)
#define PB_LoadFont2    M_UnicodeFunction(PB_LoadFont2)

/* File */
#define PB_CopyDirectory      M_UnicodeFunction(PB_CopyDirectory)
#define PB_CopyDirectory2     M_UnicodeFunction(PB_CopyDirectory2)
#define PB_CopyFile           M_UnicodeFunction(PB_CopyFile)
#define PB_DeleteDirectory    M_UnicodeFunction(PB_DeleteDirectory)
#define PB_DeleteDirectory2   M_UnicodeFunction(PB_DeleteDirectory2)
#define PB_DeleteFile         M_UnicodeFunction(PB_DeleteFile)
#define PB_DeleteFile2        M_UnicodeFunction(PB_DeleteFile2)
#define PB_CreateDirectory    M_UnicodeFunction(PB_CreateDirectory)
#define PB_FileSize           M_UnicodeFunction(PB_FileSize)
#define PB_CheckFilename      M_UnicodeFunction(PB_CheckFilename)
#define PB_RenameFile         M_UnicodeFunction(PB_RenameFile)
#define PB_ExamineDirectory   M_UnicodeFunction(PB_ExamineDirectory)
#define PB_NextDirectoryEntry M_UnicodeFunction(PB_NextDirectoryEntry)
#define PB_DirectoryEntryType M_UnicodeFunction(PB_DirectoryEntryType)
#define PB_DirectoryEntryName M_UnicodeFunction(PB_DirectoryEntryName)
#define PB_DirectoryEntrySize M_UnicodeFunction(PB_DirectoryEntrySize)
#define PB_DirectoryEntryAttributes M_UnicodeFunction(PB_DirectoryEntryAttributes)
#define PB_GetHomeDirectory   M_UnicodeFunction(PB_GetHomeDirectory)
#define PB_GetCurrentDirectory M_UnicodeFunction(PB_GetCurrentDirectory)
#define PB_SetCurrentDirectory M_UnicodeFunction(PB_SetCurrentDirectory)
#define PB_GetTemporaryDirectory M_UnicodeFunction(PB_GetTemporaryDirectory)
#define PB_GetFileAttributes  M_UnicodeFunction(PB_GetFileAttributes)
#define PB_SetFileAttributes  M_UnicodeFunction(PB_SetFileAttributes)
#define PB_GetFileDate        M_UnicodeFunction(PB_GetFileDate)
#define PB_SetFileDate        M_UnicodeFunction(PB_SetFileDate)

/* FileSystem */
#define PB_GetExtensionPart M_UnicodeFunction(PB_GetExtensionPart)
#define PB_GetFilePart			M_UnicodeFunction(PB_GetFilePart)
#define PB_GetFilePart2			M_UnicodeFunction(PB_GetFilePart2)
#define PB_GetPathPart			M_UnicodeFunction(PB_GetPathPart)

/* Gadget */
#ifndef WINDOWS
  // On Windows, these are not unicode
  #define PB_AddGadgetItem        M_UnicodeFunction(PB_AddGadgetItem)
  #define PB_AddGadgetItem2       M_UnicodeFunction(PB_AddGadgetItem2)
  #define PB_AddGadgetItem3       M_UnicodeFunction(PB_AddGadgetItem3)

  #define PB_SetGadgetItemText    M_UnicodeFunction(PB_SetGadgetItemText)
  #define PB_SetGadgetItemText2   M_UnicodeFunction(PB_SetGadgetItemText2)

  #define PB_AddGadgetColumn      M_UnicodeFunction(PB_AddGadgetColumn)
#endif

#define PB_GetGadgetItemText    M_UnicodeFunction(PB_GetGadgetItemText)
#define PB_GetGadgetItemText2   M_UnicodeFunction(PB_GetGadgetItemText2)
#define PB_GetGadgetText        M_UnicodeFunction(PB_GetGadgetText)
#define PB_SetGadgetText        M_UnicodeFunction(PB_SetGadgetText)
#define PB_GadgetToolTip        M_UnicodeFunction(PB_GadgetToolTip)
#define PB_ButtonGadget         M_UnicodeFunction(PB_ButtonGadget)
#define PB_ButtonGadget2        M_UnicodeFunction(PB_ButtonGadget2)
#define PB_StringGadget         M_UnicodeFunction(PB_StringGadget)
#define PB_StringGadget2        M_UnicodeFunction(PB_StringGadget2)
#define PB_TextGadget           M_UnicodeFunction(PB_TextGadget)
#define PB_TextGadget2          M_UnicodeFunction(PB_TextGadget2)
#define PB_CheckBoxGadget       M_UnicodeFunction(PB_CheckBoxGadget)
#define PB_CheckBoxGadget2      M_UnicodeFunction(PB_CheckBoxGadget2)
#define PB_OptionGadget         M_UnicodeFunction(PB_OptionGadget)
#define PB_ListViewGadget       M_UnicodeFunction(PB_ListViewGadget)
#define PB_ListViewGadget2      M_UnicodeFunction(PB_ListViewGadget2)
#define PB_FrameGadget          M_UnicodeFunction(PB_FrameGadget)
#define PB_FrameGadget2         M_UnicodeFunction(PB_FrameGadget2)
#define PB_ComboBoxGadget       M_UnicodeFunction(PB_ComboBoxGadget)
#define PB_ComboBoxGadget2      M_UnicodeFunction(PB_ComboBoxGadget2)
#define PB_HyperLinkGadget      M_UnicodeFunction(PB_HyperLinkGadget)
#define PB_HyperLinkGadget2     M_UnicodeFunction(PB_HyperLinkGadget2)
#define PB_ImageGadget          M_UnicodeFunction(PB_ImageGadget)
#define PB_ImageGadget2         M_UnicodeFunction(PB_ImageGadget2)
#define PB_ListIconGadget       M_UnicodeFunction(PB_ListIconGadget)
#define PB_ListIconGadget2      M_UnicodeFunction(PB_ListIconGadget2)
#define PB_ContainerGadget      M_UnicodeFunction(PB_ContainerGadget)
#define PB_ContainerGadget2     M_UnicodeFunction(PB_ContainerGadget2)
#define PB_IPAddressGadget      M_UnicodeFunction(PB_IPAddressGadget)
#define PB_ProgressBarGadget    M_UnicodeFunction(PB_ProgressBarGadget)
#define PB_ProgressBarGadget2   M_UnicodeFunction(PB_ProgressBarGadget2)
#define PB_ScrollBarGadget      M_UnicodeFunction(PB_ScrollBarGadget)
#define PB_ScrollBarGadget2     M_UnicodeFunction(PB_ScrollBarGadget2)
#define PB_ScrollAreaGadget     M_UnicodeFunction(PB_ScrollAreaGadget)
#define PB_ScrollAreaGadget2    M_UnicodeFunction(PB_ScrollAreaGadget2)
#define PB_ScrollAreaGadget3    M_UnicodeFunction(PB_ScrollAreaGadget3)
#define PB_TrackBarGadget       M_UnicodeFunction(PB_TrackBarGadget)
#define PB_TrackBarGadget2      M_UnicodeFunction(PB_TrackBarGadget2)
#define PB_WebGadget            M_UnicodeFunction(PB_WebGadget)
#define PB_WebGadget2           M_UnicodeFunction(PB_WebGadget2)
#define PB_ButtonImageGadget    M_UnicodeFunction(PB_ButtonImageGadget)
#define PB_ButtonImageGadget2   M_UnicodeFunction(PB_ButtonImageGadget2)
#define PB_DateGadget           M_UnicodeFunction(PB_DateGadget)
#define PB_DateGadget2          M_UnicodeFunction(PB_DateGadget2)
#define PB_DateGadget3          M_UnicodeFunction(PB_DateGadget3)
#define PB_DateGadget4          M_UnicodeFunction(PB_DateGadget4)
#define PB_CalendarGadget       M_UnicodeFunction(PB_CalendarGadget)
#define PB_CalendarGadget2      M_UnicodeFunction(PB_CalendarGadget2)
#define PB_CalendarGadget3      M_UnicodeFunction(PB_CalendarGadget3)
#define PB_EditorGadget         M_UnicodeFunction(PB_EditorGadget)
#define PB_EditorGadget2        M_UnicodeFunction(PB_EditorGadget2)
#define PB_ExplorerListGadget   M_UnicodeFunction(PB_ExplorerListGadget)
#define PB_ExplorerListGadget2  M_UnicodeFunction(PB_ExplorerListGadget2)
#define PB_ExplorerTreeGadget   M_UnicodeFunction(PB_ExplorerTreeGadget)
#define PB_ExplorerTreeGadget2  M_UnicodeFunction(PB_ExplorerTreeGadget2)
#define PB_ExplorerComboGadget  M_UnicodeFunction(PB_ExplorerComboGadget)
#define PB_ExplorerComboGadget2 M_UnicodeFunction(PB_ExplorerComboGadget2)
#define PB_SpinGadget           M_UnicodeFunction(PB_SpinGadget)
#define PB_SpinGadget2          M_UnicodeFunction(PB_SpinGadget2)
#define PB_TreeGadget           M_UnicodeFunction(PB_TreeGadget)
#define PB_TreeGadget2          M_UnicodeFunction(PB_TreeGadget2)
#define PB_GadgetItemID         M_UnicodeFunction(PB_GadgetItemID)
#define PB_PanelGadget          M_UnicodeFunction(PB_PanelGadget)
#define PB_SplitterGadget       M_UnicodeFunction(PB_SplitterGadget)
#define PB_SplitterGadget2      M_UnicodeFunction(PB_SplitterGadget2)
#define PB_MDIGadget            M_UnicodeFunction(PB_MDIGadget)
#define PB_MDIGadget2           M_UnicodeFunction(PB_MDIGadget2)
#define PB_ScintillaGadget      M_UnicodeFunction(PB_ScintillaGadget)
#define PB_CanvasGadget         M_UnicodeFunction(PB_CanvasGadget)
#define PB_CanvasGadget2        M_UnicodeFunction(PB_CanvasGadget2)
#define PB_CanvasOutput         M_UnicodeFunction(PB_CanvasOutput)
#define PB_CanvasVectorOutput   M_UnicodeFunction(PB_CanvasVectorOutput)
#define PB_CanvasVectorOutput2  M_UnicodeFunction(PB_CanvasVectorOutput2)
#define PB_OpenGLGadget         M_UnicodeFunction(PB_OpenGLGadget)
#define PB_OpenGLGadget2        M_UnicodeFunction(PB_OpenGLGadget2)

/* Image */
#define PB_LoadImage    M_UnicodeFunction(PB_LoadImage)
#define PB_LoadImage2   M_UnicodeFunction(PB_LoadImage2)
#define PB_SaveImage    M_UnicodeFunction(PB_SaveImage)
#define PB_SaveImage2   M_UnicodeFunction(PB_SaveImage2)
#define PB_SaveImage3   M_UnicodeFunction(PB_SaveImage3)
#define PB_SaveImage4   M_UnicodeFunction(PB_SaveImage4)
#define PB_ImageOutput  M_UnicodeFunction(PB_ImageOutput)

/* Joystick */
#define PB_JoystickName      M_UnicodeFunction(PB_JoystickName)


/* Keyboard */
#define PB_KeyboardInkey M_UnicodeFunction(PB_KeyboardInkey)

/* Library */
#define PB_OpenLibrary         M_UnicodeFunction(PB_OpenLibrary)
#define PB_GetFunction         M_UnicodeFunction(PB_GetFunction)
#define PB_LibraryFunctionName M_UnicodeFunction(PB_LibraryFunctionName)

/* Menu */
#define PB_MenuTitle        M_UnicodeFunction(PB_MenuTitle)
#define PB_MenuItem         M_UnicodeFunction(PB_MenuItem)
#define PB_MenuItem2        M_UnicodeFunction(PB_MenuItem2)
#define PB_OpenSubMenu      M_UnicodeFunction(PB_OpenSubMenu)
#define PB_OpenSubMenu2     M_UnicodeFunction(PB_OpenSubMenu2)
#define PB_GetMenuItemText  M_UnicodeFunction(PB_GetMenuItemText)
#define PB_SetMenuItemText  M_UnicodeFunction(PB_SetMenuItemText)
#define PB_GetMenuTitleText M_UnicodeFunction(PB_GetMenuTitleText)
#define PB_SetMenuTitleText M_UnicodeFunction(PB_SetMenuTitleText)

/* Music */
#define PB_LoadMusic M_UnicodeFunction(PB_LoadMusic)

/* Movie */
#define PB_LoadMovie 	M_UnicodeFunction(PB_LoadMovie)

/* Palette */
#define PB_LoadPalette M_UnicodeFunction(PB_LoadPalette)

/* Printer */
#define PB_PrintRequester       M_UnicodeFunction(PB_PrintRequester)
#define PB_StartPrinting        M_UnicodeFunction(PB_StartPrinting)
#define PB_PrinterOutput        M_UnicodeFunction(PB_PrinterOutput)

/* Requester */
#define PB_ColorRequester       M_UnicodeFunction(PB_ColorRequester)
#define PB_ColorRequester2      M_UnicodeFunction(PB_ColorRequester2)
#define PB_FontRequester        M_UnicodeFunction(PB_FontRequester)
#define PB_FontRequester2       M_UnicodeFunction(PB_FontRequester2)
#define PB_FontRequester3       M_UnicodeFunction(PB_FontRequester3)
#define PB_SelectedFontName     M_UnicodeFunction(PB_SelectedFontName)
#define PB_SelectedFontSize     M_UnicodeFunction(PB_SelectedFontSize)
#define PB_SelectedFontEffect   M_UnicodeFunction(PB_SelectedFontEffect)
#define PB_SelectedFontColor    M_UnicodeFunction(PB_SelectedFontColor)
#define PB_SelectedFontStyle    M_UnicodeFunction(PB_SelectedFontStyle)
#define PB_InputRequester       M_UnicodeFunction(PB_InputRequester)
#define PB_InputRequester2      M_UnicodeFunction(PB_InputRequester2)
#define PB_MessageRequester     M_UnicodeFunction(PB_MessageRequester)
#define PB_MessageRequester2    M_UnicodeFunction(PB_MessageRequester2)
#define PB_NextSelectedFileName M_UnicodeFunction(PB_NextSelectedFileName)
#define PB_SelectedFilePattern  M_UnicodeFunction(PB_SelectedFilePattern)
#define PB_OpenFileRequester    M_UnicodeFunction(PB_OpenFileRequester)
#define PB_OpenFileRequester2   M_UnicodeFunction(PB_OpenFileRequester2)
#define PB_PathRequester        M_UnicodeFunction(PB_PathRequester)
#define PB_SaveFileRequester    M_UnicodeFunction(PB_SaveFileRequester)
#define PB_SelectedFileName     M_UnicodeFunction(PB_SelectedFileName)

/* Sound */
#define PB_LoadSound  M_UnicodeFunction(PB_LoadSound)
#define PB_LoadSound2 M_UnicodeFunction(PB_LoadSound2)

/* StatusBar */
#define PB_StatusBarText   M_UnicodeFunction(PB_StatusBarText)
#define PB_StatusBarText2  M_UnicodeFunction(PB_StatusBarText2)

/* Screen */
#define PB_OpenWindowedScreen  M_UnicodeFunction(PB_OpenWindowedScreen)
#define PB_OpenWindowedScreen2 M_UnicodeFunction(PB_OpenWindowedScreen2)
#define PB_OpenWindowedScreen3 M_UnicodeFunction(PB_OpenWindowedScreen3)
#define PB_OpenScreen          M_UnicodeFunction(PB_OpenScreen)
#define PB_OpenScreen2         M_UnicodeFunction(PB_OpenScreen2)
#define PB_OpenScreen3         M_UnicodeFunction(PB_OpenScreen3)
#define PB_ScreenOutput        M_UnicodeFunction(PB_ScreenOutput)

/* Sprite */
#define PB_LoadSprite         M_UnicodeFunction(PB_LoadSprite)
#define PB_LoadSprite2        M_UnicodeFunction(PB_LoadSprite2)
#define PB_SaveSprite         M_UnicodeFunction(PB_SaveSprite)
#define PB_SaveSprite2        M_UnicodeFunction(PB_SaveSprite2)
#define PB_SaveSprite3        M_UnicodeFunction(PB_SaveSprite3)
#define PB_SpriteOutput       M_UnicodeFunction(PB_SpriteOutput)

/* ToolBar */
#define PB_ToolBarToolTip M_UnicodeFunction(PB_ToolBarToolTip)

/* Window */
#define PB_OpenWindow                    M_UnicodeFunction(PB_OpenWindow)
#define PB_OpenWindow2                   M_UnicodeFunction(PB_OpenWindow2)
#define PB_OpenWindow3                   M_UnicodeFunction(PB_OpenWindow3)
#define PB_GetWindowTitle                M_UnicodeFunction(PB_GetWindowTitle)
#define PB_SetWindowTitle                M_UnicodeFunction(PB_SetWindowTitle)
#define PB_WindowOutput                  M_UnicodeFunction(PB_WindowOutput)

/* Process */
#define PB_ExamineEnvironmentVariables M_UnicodeFunction(PB_ExamineEnvironmentVariables)
#define PB_NextEnvironmentVariable     M_UnicodeFunction(PB_NextEnvironmentVariable)
#define PB_EnvironmentVariableName     M_UnicodeFunction(PB_EnvironmentVariableName)
#define PB_EnvironmentVariableValue    M_UnicodeFunction(PB_EnvironmentVariableValue)
#define PB_GetEnvironmentVariable      M_UnicodeFunction(PB_GetEnvironmentVariable)
#define PB_SetEnvironmentVariable      M_UnicodeFunction(PB_SetEnvironmentVariable)
#define PB_ProgramFilename             M_UnicodeFunction(PB_ProgramFilename)
#define PB_ProgramParameter            M_UnicodeFunction(PB_ProgramParameter)
#define PB_ProgramParameter2           M_UnicodeFunction(PB_ProgramParameter2)
#define PB_CountProgramParameters      M_UnicodeFunction(PB_CountProgramParameters)
#define PB_RunProgram                  M_UnicodeFunction(PB_RunProgram)
#define PB_RunProgram2                 M_UnicodeFunction(PB_RunProgram2)
#define PB_RunProgram3                 M_UnicodeFunction(PB_RunProgram3)
#define PB_RunProgram4                 M_UnicodeFunction(PB_RunProgram4)
#define PB_ReadProgramError            M_UnicodeFunction(PB_ReadProgramError)
#define PB_ReadProgramError2           M_UnicodeFunction(PB_ReadProgramError2)
#define PB_ReadProgramString           M_UnicodeFunction(PB_ReadProgramString)
#define PB_ReadProgramString2          M_UnicodeFunction(PB_ReadProgramString2)
#define PB_RemoveEnvironmentVariable   M_UnicodeFunction(PB_RemoveEnvironmentVariable)
#define PB_WriteProgramString          M_UnicodeFunction(PB_WriteProgramString)
#define PB_WriteProgramString2         M_UnicodeFunction(PB_WriteProgramString2)
#define PB_WriteProgramStringN         M_UnicodeFunction(PB_WriteProgramStringN)
#define PB_WriteProgramStringN2        M_UnicodeFunction(PB_WriteProgramStringN2)
#define PB_OpenSharedMutex             M_UnicodeFunction(PB_OpenSharedMutex)
#define PB_AllocateSharedMemory        M_UnicodeFunction(PB_AllocateSharedMemory)
#define PB_Process_MakeKey             M_UnicodeFunction(PB_Process_MakeKey)

/* SerialPort */
#define PB_OpenSerialPort M_UnicodeFunction(PB_OpenSerialPort)
#define PB_WriteSerialPortString M_UnicodeFunction(PB_WriteSerialPortString)
#define PB_WriteSerialPortString2 M_UnicodeFunction(PB_WriteSerialPortString2)


