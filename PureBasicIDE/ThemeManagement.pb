; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "ToolbarManagement.pb"

;- Structures and Globals

Structure PrefsThemeList
  Filename$      ; theme filename (no path), "" for builtin theme
  Preview.i      ; preview image (#PB_Any)
  ImageGadget.i  ; gadgets (#PB_Any)
  OptionGadget.i
  TextGadget.i
EndStructure


Structure ThemeEntry
  IconName$
  *ZipEntry.ZipEntry
EndStructure

Global NewList PrefsThemeList.PrefsThemeList()

Global *ThemeFile, ThemeFileSize, ThemeInfo1$, ThemeInfo2$, ThemeInfo3$
Global NewList ThemeZipEntries.ZipEntry()
Global NewList ThemeEntries.ThemeEntry()

;- Functions for internal use
;
Procedure CenterImage(Image, NewImage, Width, Height, Depth = 32, BackColor = #PB_Image_Transparent)
  Protected r1, x, y, dx, dy, image2
    
  r1 = CreateImage(NewImage, Width, Height, Depth, BackColor)
  If r1
    If NewImage = #PB_Any
      NewImage = r1
    EndIf
    dx = ImageWidth(Image)
    dy = ImageHeight(Image)
    x = (Width - dx) / 2
    y = (Height - dy) / 2
    If StartDrawing(ImageOutput(NewImage))
      DrawAlphaImage(ImageID(Image), x, y)
      StopDrawing()
    EndIf
  EndIf
  ProcedureReturn r1
EndProcedure

Procedure Theme_Open(Filename$) ; pass "" to open internal theme
  ClearList(ThemeEntries())
  *ThemeFile      = 0
  *LocalThemeFile = 0
  
  If Filename$ = ""
    *LocalThemeFile = ?DefaultTheme
    ThemeFileSize   = ?EndDefaultTheme - ?DefaultTheme
  Else
    If ReadFile(#FILE_Theme, Filename$)
      ThemeFileSize = Lof(#FILE_Theme)
      If ThemeFileSize < 1024*1024*30  ; sanity check
        *LocalThemeFile = AllocateMemory(ThemeFileSize)
        If *LocalThemeFile
          If ReadData(#FILE_Theme, *LocalThemeFile, ThemeFileSize) <> ThemeFileSize
            FreeMemory(*ThemeFile)
            *LocalThemeFile = 0
          EndIf
        EndIf
      EndIf
      CloseFile(#FILE_Theme)
    EndIf
  EndIf
  
  If *LocalThemeFile
    If ScanZip(*LocalThemeFile, ThemeFileSize, ThemeZipEntries()) > 0
      
      ; Locate the Theme.prefs file
      ForEach ThemeZipEntries()
        If LCase(GetFilePart(ThemeZipEntries()\Name$)) = "theme.prefs" ; all case insensitive here
          
          ; Read the Theme.prefs file
          *Buffer = ExtractZip(@ThemeZipEntries())
          If *Buffer
            *BufferEnd  = *Buffer + ThemeZipEntries()\Uncompressed
            *Cursor.PTR = *Buffer
            Group$      = ""
            
            If ThemeZipEntries()\Uncompressed > 3 And *Cursor\b[0] = $EF And *Cursor\b[1] = $BB And *Cursor\b[2] = $BF
              Mode = #PB_UTF8
              *Cursor + 3
            Else
              Mode = #PB_Ascii
            EndIf
            
            While *Cursor < *BufferEnd
              *Start = *Cursor
              While *Cursor < *BufferEnd And *Cursor\b <> 13 And *Cursor\b <> 10
                *Cursor + 1
              Wend
              Line$ = PeekS(*Start, *Cursor-*Start, Mode)
              
              ; Advance cursor beyond newline
              If *Cursor+1 < *BufferEnd And *Cursor\b = 13 And *Cursor\b[1] = 10
                *Cursor + 2
              Else
                *Cursor + 1
              EndIf
              
              Line$  = Trim(RemoveString(Line$, Chr(9)))
              
              If Left(Line$, 1) = "[" And Right(Line$, 1) = "]"
                Group$ = LCase(Trim(Mid(Line$, 2, Len(Line$)-2)))
                
              ElseIf Left(Line$, 1) <> ";"
                Index = FindString(Line$, "=", 1)
                If Index > 0
                  Key$   = Trim(Left(Line$, Index-1))
                  Value$ = Trim(Right(Line$, Len(Line$)-Index))
                  
                  If Group$ = "theme"
                    Select LCase(Key$)
                      Case "info1": ThemeInfo1$ = Value$
                      Case "info2": ThemeInfo2$ = Value$
                      Case "info3": ThemeInfo3$ = Value$
                    EndSelect
                    
                  ElseIf Group$ <> ""
                    If Value$ <> ""
                      Value$ = LCase(Value$)
                      ForEach ThemeZipEntries()
                        If Value$ = LCase(ThemeZipEntries()\Name$)
                          AddElement(ThemeEntries())
                          ThemeEntries()\IconName$ = Group$+":"+LCase(Key$)
                          ThemeEntries()\ZipEntry  = @ThemeZipEntries()
                          Break
                        EndIf
                      Next ThemeZipEntries()
                    EndIf
                    
                  EndIf
                EndIf
              EndIf
            Wend
            
            FreeMemory(*Buffer)
          EndIf
          
          Break
        EndIf
      Next ThemeZipEntries()
      
    EndIf
    
    If ListSize(ThemeEntries()) = 0
      If Filename$ <> ""
        FreeMemory(*LocalThemeFile) ; dynamically allocated
      EndIf
      *LocalThemeFile = 0
    Else
      If Filename$ <> ""
        *ThemeFile = *LocalThemeFile ; dynamically allocated (freed later)
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn ListSize(ThemeEntries())
EndProcedure

Procedure Theme_Close()
  ClearList(ThemeEntries())
  ClearList(ThemeZipEntries())
  If *ThemeFile
    FreeMemory(*ThemeFile) ; is 0 when internal theme is used
  EndIf
EndProcedure

; Only frees the old image if the new one cannot be extracted/found
Procedure Theme_LoadImage(Image, ImageName$)
  Result = 0
  ImageName$ = LCase(ImageName$)
  IsAnyImage = #False
  
  ForEach ThemeEntries()
    If ImageName$ = ThemeEntries()\IconName$
      
      *Buffer = ExtractZip(ThemeEntries()\ZipEntry)
      If *Buffer
        Result = CatchImage(Image, *Buffer, ThemeEntries()\ZipEntry\Uncompressed)
        
        ; Resize all the them image according to current DPI.
        ;
        If Image = #PB_Any
          Image = Result
          IsAnyImage = #True
        EndIf
        CompilerIf #CompileMac
          If IsAnyImage
            Result = CenterImage(Image, #PB_Any, 24, 24)
            FreeImage(Image)
          Else
            tmpImage = CenterImage(Image, #PB_Any, 24, 24)
            CopyImage(tmpImage, Image)
            FreeImage(tmpImage)
          EndIf
        CompilerElse
          ResizeImage(Image, DesktopScaledX(ImageWidth(Image)), DesktopScaledY(ImageHeight(Image)))
        CompilerEndIf
        FreeMemory(*Buffer)
      EndIf
      
      Break
    EndIf
  Next ThemeEntries()
  
  ProcedureReturn Result
EndProcedure

Procedure Theme_AddToPrefslist(Filename$)
  If Theme_Open(Filename$)
    AddElement(PrefsThemeList())
    PrefsThemeList()\Filename$ = GetFilePart(Filename$)
    
    PreviewWidth  = DesktopScaledX(#MAX_ThemePreview*19+3)
    PreviewHeight = DesktopScaledY(22)
    PrefsThemeList()\Preview   = CreateImage(#PB_Any, PreviewWidth, PreviewHeight)
    
    ; Load the icons for preview
    ; This must be done outside the StartDrawing() as it seems to mess up the StartDrawing() on OSX else
    ;
    index = 1
    count = 0
    While count < #MAX_ThemePreview And index <= #NB_ToolbarMenuItems
      If Theme_LoadImage(#IMAGE_FirstThemePreview+count, ToolbarMenuName$(index))
        count + 1
      EndIf
      index + 1
    Wend
    
    If PrefsThemeList()\Preview And StartDrawing(ImageOutput(PrefsThemeList()\Preview))
      Box(0, 0, PreviewWidth  , PreviewHeight  , $000000)
      Box(DesktopScaledX(1), DesktopScaledY(1), PreviewWidth-2, PreviewHeight-2, $FFFFFF)
      
      For i = 0 To count-1
        DrawAlphaImage(ImageID(#IMAGE_FirstThemePreview+i), DesktopScaledX(i*19+3), DesktopScaledY(3))
      Next i
      
      StopDrawing()
    EndIf
    
    ; free the individual preview images
    For i = 0 To count-1
      FreeImage(#IMAGE_FirstThemePreview+i)
    Next i
    
    PrefsThemeList()\ImageGadget = ImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(PrefsThemeList()\Preview))
    
    Text$ = ThemeInfo1$
    If ThemeInfo2$ <> "" Or ThemeInfo3$ <> ""
      Text$ + #NewLine + ThemeInfo2$
    EndIf
    If ThemeInfo3$ <> ""
      Text$ + #NewLine + ThemeInfo3$
    EndIf
    PrefsThemeList()\TextGadget = TextGadget(#PB_Any, 0, 0, 0, 0, Text$)
    
    Theme_Close()
  EndIf
EndProcedure

;- Functions for external use
;
Procedure CreatePrefsThemeList()
  
  OpenGadgetList(#GADGET_Preferences_Themes)
  
  ; Add the default theme
  Theme_AddToPrefsList("")
  
  ; Search for themes
  If ExamineDirectory(0, PureBasicPath$+#DEFAULT_ThemePath, "*")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        Theme_AddToPrefsList(PureBasicPath$+#DEFAULT_ThemePath+DirectoryEntryName(0))
      EndIf
    Wend
    FinishDirectory(0)
  EndIf
  
  ; Create all OptionGadgets here, to have them all in one group
  ForEach PrefsThemeList()
    PrefsThemeList()\OptionGadget = OptionGadget(#PB_Any, 0, 0, 0, 0, "")
  Next PrefsThemeList()
  
  CloseGadgetList()
  
  If FirstElement(PrefsThemeList()) ; this is only 0 if even the internal images fail loading
    
    GetRequiredSize(PrefsThemeList()\OptionGadget, @OptionWidth.l, @OptionHeight.l)
    OptionSize = Max(OptionWidth, Max(OptionHeight, 22))
    
    Width  = #MAX_ThemePreview*19+3
    Top    = 15
    
    ForEach PrefsThemeList()
      GetRequiredSize(PrefsThemeList()\TextGadget, @TextWidth.l, @TextHeight.l)
      
      ResizeGadget(PrefsThemeList()\OptionGadget, 10, Top, OptionSize, OptionSize)
      ResizeGadget(PrefsThemeList()\ImageGadget, 10+OptionSize, Top, #MAX_ThemePreview*19+3, 22)
      ResizeGadget(PrefsThemeList()\TextGadget, 10+OptionSize, Top+27, TextWidth, TextHeight)
      
      ; The first check is needed if both are "" (default theme)
      If CurrentTheme$ = PrefsThemeList()\Filename$ Or IsEqualFile(CurrentTheme$, PrefsThemeList()\Filename$)
        SetGadgetState(PrefsThemeList()\OptionGadget, 1)
      EndIf
      
      Width = Max(Width, TextWidth)
      Top + 42 + TextHeight
    Next PrefsThemeList()
    
    SetGadgetAttribute(#GADGET_Preferences_Themes, #PB_ScrollArea_InnerWidth, Width+20+OptionSize)
    SetGadgetAttribute(#GADGET_Preferences_Themes, #PB_ScrollArea_InnerHeight, Top)
    
  EndIf
  
EndProcedure

Procedure FreePrefsThemeList()
  ForEach PrefsThemeList()
    FreeGadget(PrefsThemeList()\ImageGadget)
    FreeImage(PrefsThemeList()\Preview)
  Next PrefsThemeList()
  
  ClearList(PrefsThemeList())
EndProcedure

Procedure PrefsThemeChanged()
  
  ForEach PrefsThemeList()
    If GetGadgetState(PrefsThemeList()\OptionGadget)
      ; The first check is needed if both are "" (default theme)
      If CurrentTheme$ <> PrefsThemeList()\Filename$ And IsEqualFile(CurrentTheme$, PrefsThemeList()\Filename$) = 0
        ProcedureReturn 1
      EndIf
    EndIf
  Next PrefsThemeList()
  
  ProcedureReturn 0
EndProcedure

Procedure ApplyPrefsTheme()
  
  ForEach PrefsThemeList()
    If GetGadgetState(PrefsThemeList()\OptionGadget)
      ; Only reload theme if needed
      ; The first check is needed if both are "" (default theme)
      If CurrentTheme$ <> PrefsThemeList()\Filename$ And IsEqualFile(CurrentTheme$, PrefsThemeList()\Filename$) = 0
        
        ; Set theme and reload
        CurrentTheme$ = PrefsThemeList()\Filename$
        LoadTheme()
        ProcedureReturn
        
      EndIf
    EndIf
  Next PrefsThemeList()
  
EndProcedure

Procedure LoadTheme()
  
  If CurrentTheme$ <> "" ; means default theme
    
    ; For the templates and fileviewer image, we add a fallback (default icons), to never have an empty button
    ; (For the menu, we allow missing items to choose which menu items to put an icon to)
    ;
    If Theme_Open("")
      Theme_LoadImage(#IMAGE_FilePanel_New,      "Misc:FilePanelNew")
      ; Misc:FilePanelProject is optional
      
      Theme_LoadImage(#IMAGE_Template_Add,       "Template:Add")
      Theme_LoadImage(#IMAGE_Template_AddDir,    "Template:AddDirectory")
      Theme_LoadImage(#IMAGE_Template_Dir,       "Template:Directory")
      Theme_LoadImage(#IMAGE_Template_Down,      "Template:Down")
      Theme_LoadImage(#IMAGE_Template_Edit,      "Template:Edit")
      Theme_LoadImage(#IMAGE_Template_Remove,    "Template:Remove")
      Theme_LoadImage(#IMAGE_Template_RemoveDir, "Template:RemoveDirectory")
      Theme_LoadImage(#IMAGE_Template_Template,  "Template:Template")
      Theme_LoadImage(#IMAGE_Template_Up,        "Template:Up")
      
      Theme_LoadImage(#IMAGE_FileViewer_Open,    "FileViewer:Open")
      Theme_LoadImage(#IMAGE_FileViewer_Close,   "FileViewer:Close")
      Theme_LoadImage(#IMAGE_FileViewer_Left,    "FileViewer:Left")
      Theme_LoadImage(#IMAGE_FileViewer_Right,   "FileViewer:Right")
      
      Theme_LoadImage(#IMAGE_WebView_OpenBrowser, "WebView:OpenBrowser")
      
      Theme_LoadImage(#IMAGE_Help_Back,           "Help:Back")
      Theme_LoadImage(#IMAGE_Help_Forward,        "Help:Forward")
      Theme_LoadImage(#IMAGE_Help_Home,           "Help:Home")
      Theme_LoadImage(#IMAGE_Help_Previous,       "Help:Previous")
      Theme_LoadImage(#IMAGE_Help_Next,           "Help:Next")
      Theme_LoadImage(#IMAGE_Help_OpenHelp,       "Help:OpenHelp")
      
      Theme_LoadImage(#IMAGE_Option_AddTarget,    "Compiler:AddTarget")
      Theme_LoadImage(#IMAGE_Option_EditTarget,   "Compiler:EditTarget")
      Theme_LoadImage(#IMAGE_Option_CopyTarget,   "Compiler:CopyTarget")
      Theme_LoadImage(#IMAGE_Option_RemoveTarget, "Compiler:RemoveTarget")
      Theme_LoadImage(#IMAGE_Option_TargetUp,     "Compiler:TargetUp")
      Theme_LoadImage(#IMAGE_Option_TargetDown,   "Compiler:TargetDown")
      Theme_LoadImage(#IMAGE_Option_DefaultTarget,"Compiler:DefaultTarget")
      Theme_LoadImage(#IMAGE_Option_NormalTarget, "Compiler:NormalTarget")
      Theme_LoadImage(#IMAGE_Option_DisabledTarget,"Compiler:DisabledTarget")
      Theme_LoadImage(#IMAGE_Build_TargetOK,      "Compiler:TargetOK")
      Theme_LoadImage(#IMAGE_Build_TargetError,   "Compiler:TargetError")
      Theme_LoadImage(#IMAGE_Build_TargetWarning, "Compiler:TargetWarning")
      Theme_LoadImage(#IMAGE_Build_TargetNotDone, "Compiler:TargetNotDone")
      
      Theme_LoadImage(#IMAGE_Explorer_AddFavorite,    "Explorer:AddFavorite")
      Theme_LoadImage(#IMAGE_Explorer_RemoveFavorite, "Explorer:RemoveFavorite")
      
      Theme_LoadImage(#IMAGE_Diff_Open1,      "Diff:Open1")
      Theme_LoadImage(#IMAGE_Diff_Open2,      "Diff:Open2")
      Theme_LoadImage(#IMAGE_Diff_Refresh,    "Diff:Refresh")
      Theme_LoadImage(#IMAGE_Diff_Colors,     "Diff:Colors")
      Theme_LoadImage(#IMAGE_Diff_Swap,       "Diff:Swap")
      Theme_LoadImage(#IMAGE_Diff_Vertical,   "Diff:Vertical")
      Theme_LoadImage(#IMAGE_Diff_HideFiles,  "Diff:HideFiles")
      Theme_LoadImage(#IMAGE_Diff_Up,         "Diff:Up")
      Theme_LoadImage(#IMAGE_Diff_Down,       "Diff:Down")
      Theme_LoadImage(#IMAGE_Diff_ShowTool,   "Diff:DiffTool")
      
      Theme_LoadImage(#IMAGE_IssueSingleFile, "Issues:SingleFile")
      Theme_LoadImage(#IMAGE_IssueMultiFile,  "Issues:MultiFile")
      Theme_LoadImage(#IMAGE_IssueExport,     "Issues:Export")
      
      Theme_LoadImage(#IMAGE_FormIcons_Button,           "FormIcons:Button")
      Theme_LoadImage(#IMAGE_FormIcons_ButtonImage,      "FormIcons:ButtonImage")
      Theme_LoadImage(#IMAGE_FormIcons_Calendar,         "FormIcons:Calendar")
      Theme_LoadImage(#IMAGE_FormIcons_Canvas,           "FormIcons:Canvas")
      Theme_LoadImage(#IMAGE_FormIcons_CheckBox,         "FormIcons:CheckBox")
      Theme_LoadImage(#IMAGE_FormIcons_ComboBox,         "FormIcons:ComboBox")
      Theme_LoadImage(#IMAGE_FormIcons_Container,        "FormIcons:Container")
      Theme_LoadImage(#IMAGE_FormIcons_Date,             "FormIcons:Date")
      Theme_LoadImage(#IMAGE_FormIcons_Editor,           "FormIcons:Editor")
      Theme_LoadImage(#IMAGE_FormIcons_ExplorerCombo,    "FormIcons:ExplorerCombo")
      Theme_LoadImage(#IMAGE_FormIcons_ExplorerList,     "FormIcons:ExplorerList")
      Theme_LoadImage(#IMAGE_FormIcons_ExplorerTree,     "FormIcons:ExplorerTree")
      Theme_LoadImage(#IMAGE_FormIcons_Frame3D,          "FormIcons:Frame3D")
      Theme_LoadImage(#IMAGE_FormIcons_HyperLink,        "FormIcons:HyperLink")
      Theme_LoadImage(#IMAGE_FormIcons_Image,            "FormIcons:Image")
      Theme_LoadImage(#IMAGE_FormIcons_IPAddress,        "FormIcons:IPAddress")
      Theme_LoadImage(#IMAGE_FormIcons_ListIcon,         "FormIcons:ListIcon")
      Theme_LoadImage(#IMAGE_FormIcons_ListView,         "FormIcons:ListView")
      Theme_LoadImage(#IMAGE_FormIcons_Menu,             "FormIcons:Menu")
      Theme_LoadImage(#IMAGE_FormIcons_Option,           "FormIcons:Option")
      Theme_LoadImage(#IMAGE_FormIcons_Panel,            "FormIcons:Panel")
      Theme_LoadImage(#IMAGE_FormIcons_ProgressBar,      "FormIcons:ProgressBar")
      Theme_LoadImage(#IMAGE_FormIcons_ScrollArea,       "FormIcons:ScrollArea")
      Theme_LoadImage(#IMAGE_FormIcons_ScrollBar,        "FormIcons:ScrollBar")
      Theme_LoadImage(#IMAGE_FormIcons_Spin,             "FormIcons:Spin")
      Theme_LoadImage(#IMAGE_FormIcons_Splitter,         "FormIcons:Splitter")
      Theme_LoadImage(#IMAGE_FormIcons_Status,           "FormIcons:Status")
      Theme_LoadImage(#IMAGE_FormIcons_String,           "FormIcons:String")
      Theme_LoadImage(#IMAGE_FormIcons_Text,             "FormIcons:Text")
      Theme_LoadImage(#IMAGE_FormIcons_ToolBar,          "FormIcons:ToolBar")
      Theme_LoadImage(#IMAGE_FormIcons_TrackBar,         "FormIcons:TrackBar")
      Theme_LoadImage(#IMAGE_FormIcons_Tree,             "FormIcons:Tree")
      Theme_LoadImage(#IMAGE_FormIcons_Web,              "FormIcons:Web")
      Theme_LoadImage(#IMAGE_FormIcons_Cursor,           "FormIcons:Cursor")
      
      ; No fallback for the other entries in "Diff", as they can be empty
      
      ; No fallback for ProjectPanel icons, as they are not critical
      
      ; No fallback for history icons (optional)
      
      Theme_Close()
    EndIf
    
    If Theme_Open(PureBasicPath$ + #DEFAULT_ThemePath + CurrentTheme$) = 0
      CurrentTheme$ = "" ; theme not loadable, revert to default
    EndIf
  EndIf
  
  If CurrentTheme$ = ""
    Theme_Open("")
  EndIf
  
  ; Load Menu icons
  ;
  For i = 1 To #NB_ToolbarMenuItems
    If ToolbarMenuIcon(i)
      FreeImage(ToolbarMenuIcon(i))  ; free any old icon here (#PB_Any value)
      ToolbarMenuIcon(i) = 0
    EndIf
    
    ToolbarMenuIcon(i) = Theme_LoadImage(#PB_Any, ToolbarMenuName$(i))
  Next i
  
  Theme_LoadImage(#IMAGE_FilePanel_New,      "Misc:FilePanelNew")
  
  If IsImage(#IMAGE_FilePanel_Project)
    FreeImage(#IMAGE_FilePanel_Project)
  EndIf
  Theme_LoadImage(#IMAGE_FilePanel_Project,  "Misc:FilePanelProject")
  
  ; Load Template icons
  ;
  Theme_LoadImage(#IMAGE_Template_Add,       "Template:Add")
  Theme_LoadImage(#IMAGE_Template_AddDir,    "Template:AddDirectory")
  Theme_LoadImage(#IMAGE_Template_Dir,       "Template:Directory")
  Theme_LoadImage(#IMAGE_Template_Down,      "Template:Down")
  Theme_LoadImage(#IMAGE_Template_Edit,      "Template:Edit")
  Theme_LoadImage(#IMAGE_Template_Remove,    "Template:Remove")
  Theme_LoadImage(#IMAGE_Template_RemoveDir, "Template:RemoveDirectory")
  Theme_LoadImage(#IMAGE_Template_Template,  "Template:Template")
  Theme_LoadImage(#IMAGE_Template_Up,        "Template:Up")
  
  Theme_LoadImage(#IMAGE_FileViewer_Open,    "FileViewer:Open")
  Theme_LoadImage(#IMAGE_FileViewer_Close,   "FileViewer:Close")
  Theme_LoadImage(#IMAGE_FileViewer_Left,    "FileViewer:Left")
  Theme_LoadImage(#IMAGE_FileViewer_Right,   "FileViewer:Right")
  
  Theme_LoadImage(#IMAGE_WebView_OpenBrowser, "WebView:OpenBrowser")
  
  Theme_LoadImage(#IMAGE_Help_Back,           "Help:Back")
  Theme_LoadImage(#IMAGE_Help_Forward,        "Help:Forward")
  Theme_LoadImage(#IMAGE_Help_Home,           "Help:Home")
  Theme_LoadImage(#IMAGE_Help_Previous,       "Help:Previous")
  Theme_LoadImage(#IMAGE_Help_Next,           "Help:Next")
  Theme_LoadImage(#IMAGE_Help_OpenHelp,       "Help:OpenHelp")
  
  Theme_LoadImage(#IMAGE_Option_AddTarget,    "Compiler:AddTarget")
  Theme_LoadImage(#IMAGE_Option_EditTarget,   "Compiler:EditTarget")
  Theme_LoadImage(#IMAGE_Option_CopyTarget,   "Compiler:CopyTarget")
  Theme_LoadImage(#IMAGE_Option_RemoveTarget, "Compiler:RemoveTarget")
  Theme_LoadImage(#IMAGE_Option_TargetUp,     "Compiler:TargetUp")
  Theme_LoadImage(#IMAGE_Option_TargetDown,   "Compiler:TargetDown")
  Theme_LoadImage(#IMAGE_Option_DefaultTarget,"Compiler:DefaultTarget")
  Theme_LoadImage(#IMAGE_Option_NormalTarget, "Compiler:NormalTarget")
  Theme_LoadImage(#IMAGE_Option_DisabledTarget,"Compiler:DisabledTarget")
  Theme_LoadImage(#IMAGE_Build_TargetOK,      "Compiler:TargetOK")
  Theme_LoadImage(#IMAGE_Build_TargetError,   "Compiler:TargetError")
  Theme_LoadImage(#IMAGE_Build_TargetWarning, "Compiler:TargetWarning")
  Theme_LoadImage(#IMAGE_Build_TargetNotDone, "Compiler:TargetNotDone")
  
  Theme_LoadImage(#IMAGE_Explorer_AddFavorite,    "Explorer:AddFavorite")
  Theme_LoadImage(#IMAGE_Explorer_RemoveFavorite, "Explorer:RemoveFavorite")
  Theme_LoadImage(#IMAGE_Explorer_Directory,      "Explorer:Directory")
  Theme_LoadImage(#IMAGE_Explorer_File,           "Explorer:File")
  Theme_LoadImage(#IMAGE_Explorer_FilePB,         "Explorer:FilePB")
  
  ; Clear the 'Multicolored Procedure List' Icons in case they are missing in this theme
  ;
  For i = #IMAGE_ProcedureBrowser_BackColor To #IMAGE_ProcedureBrowser_SwitchButtons
    If IsImage(i)
      FreeImage(i)
    EndIf
  Next i

  ; The icons must be present in the ZIP archive: \PureBasic\Themes\*Theme*.zip
  Theme_LoadImage(#IMAGE_ProcedureBrowser_BackColor,          "ProcedureBrowser:BackColor")     
  Theme_LoadImage(#IMAGE_ProcedureBrowser_CopyClipboard,      "ProcedureBrowser:CopyClipboard")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_EnableFolding,      "ProcedureBrowser:EnableFolding")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_FilterClear,        "ProcedureBrowser:FilterClear")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_FrontColor,         "ProcedureBrowser:FrontColor")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_HideModuleNames,    "ProcedureBrowser:HideModuleNames")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_HighlightProcedure, "ProcedureBrowser:HighlightProcedure")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_RestoreColor,       "ProcedureBrowser:RestoreColor")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_ScrollProcedure,    "ProcedureBrowser:ScrollProcedure")
  Theme_LoadImage(#IMAGE_ProcedureBrowser_SwitchButtons,      "ProcedureBrowser:SwitchButtons")

  ; Clear the optional diff Icons in case they are missing in this theme
  ;
  For i = #IMAGE_Diff_Equal To #IMAGE_Diff_Modify
    If IsImage(i)
      FreeImage(i)
    EndIf
  Next i
  
  Theme_LoadImage(#IMAGE_Diff_Open1,      "Diff:Open1")
  Theme_LoadImage(#IMAGE_Diff_Open2,      "Diff:Open2")
  Theme_LoadImage(#IMAGE_Diff_Refresh,    "Diff:Refresh")
  Theme_LoadImage(#IMAGE_Diff_Colors,     "Diff:Colors")
  Theme_LoadImage(#IMAGE_Diff_Swap,       "Diff:Swap")
  Theme_LoadImage(#IMAGE_Diff_Vertical,   "Diff:Vertical")
  Theme_LoadImage(#IMAGE_Diff_HideFiles,  "Diff:HideFiles")
  Theme_LoadImage(#IMAGE_Diff_Up,         "Diff:Up")
  Theme_LoadImage(#IMAGE_Diff_Down,       "Diff:Down")
  Theme_LoadImage(#IMAGE_Diff_ShowTool,   "Diff:DiffTool")
  Theme_LoadImage(#IMAGE_Diff_Equal,      "Diff:FileEqual")
  Theme_LoadImage(#IMAGE_Diff_Add,        "Diff:FileAdd")
  Theme_LoadImage(#IMAGE_Diff_Delete,     "Diff:FileDelete")
  Theme_LoadImage(#IMAGE_Diff_Modify,     "Diff:FileModify")
  
  ; Clear ProjectPanel Icons in case they are missing in this theme
  ;
  For i = #IMAGE_ProjectPanel_InternalFiles To #IMAGE_ProjectPanel_RescanFile
    If IsImage(i)
      FreeImage(i)
    EndIf
  Next i
  
  Theme_LoadImage(#IMAGE_ProjectPanel_InternalFiles, "ProjectPanel:InternalFiles")
  Theme_LoadImage(#IMAGE_ProjectPanel_ExternalFiles, "ProjectPanel:ExternalFiles")
  Theme_LoadImage(#IMAGE_ProjectPanel_Directory,     "ProjectPanel:Directory")
  Theme_LoadImage(#IMAGE_ProjectPanel_File,          "ProjectPanel:File")
  Theme_LoadImage(#IMAGE_ProjectPanel_FileScanned,   "ProjectPanel:FileScanned")
  Theme_LoadImage(#IMAGE_ProjectPanel_Open,          "ProjectPanel:Open")
  Theme_LoadImage(#IMAGE_ProjectPanel_AddFile,       "ProjectPanel:AddFile")
  Theme_LoadImage(#IMAGE_ProjectPanel_RemoveFile,    "ProjectPanel:RemoveFile")
  Theme_LoadImage(#IMAGE_ProjectPanel_RescanFile,    "ProjectPanel:RescanFile")
  
  
  ; Clear previous history icon in case it is empty in this theme
  If IsImage(#IMAGE_History_Session)
    FreeImage(#IMAGE_History_Session)
  EndIf
  Theme_LoadImage(#IMAGE_History_Session, "History:Session")
  
  If IsImage(#IMAGE_History_File)
    FreeImage(#IMAGE_History_File)
  EndIf
  Theme_LoadImage(#IMAGE_History_File, "History:File")
  
  For i = #IMAGE_History_First To #IMAGE_History_Last
    If IsImage(i)
      FreeImage(i)
    EndIf
  Next i
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_Create, "History:EventCreate")
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_Open,   "History:EventOpen")
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_Close,  "History:EventClose")
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_Save,   "History:EventSave")
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_SaveAs, "History:EventSaveAs")
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_Reload, "History:EventReload")
  Theme_LoadImage(#IMAGE_History_First + #HISTORY_Edit,   "History:EventEdit")
  
  Theme_LoadImage(#IMAGE_IssueSingleFile, "Issues:SingleFile")
  Theme_LoadImage(#IMAGE_IssueMultiFile,  "Issues:MultiFile")
  Theme_LoadImage(#IMAGE_IssueExport,     "Issues:Export")
  
  If IsImage(#IMAGE_AllIssues)
    FreeImage(#IMAGE_AllIssues) ; free old image as this is optional
  EndIf
  Theme_LoadImage(#IMAGE_AllIssues,     "Issues:AllIssues")
  
  For i = 0 To 4
    If IsImage(#IMAGE_Priority0 + i)
      FreeImage(#IMAGE_Priority0 + i) ; free old image as this is optional
    EndIf
    Theme_LoadImage(#IMAGE_Priority0 + i, "Issues:Priority" + i)
  Next i
  
  Theme_LoadImage(#IMAGE_FormIcons_Button,    "ProjectPanel:RescanFile")
  
  Theme_LoadImage(#IMAGE_FormIcons_Button,           "FormIcons:Button")
  Theme_LoadImage(#IMAGE_FormIcons_ButtonImage,      "FormIcons:ButtonImage")
  Theme_LoadImage(#IMAGE_FormIcons_Calendar,         "FormIcons:Calendar")
  Theme_LoadImage(#IMAGE_FormIcons_Canvas,           "FormIcons:Canvas")
  Theme_LoadImage(#IMAGE_FormIcons_CheckBox,         "FormIcons:CheckBox")
  Theme_LoadImage(#IMAGE_FormIcons_ComboBox,         "FormIcons:ComboBox")
  Theme_LoadImage(#IMAGE_FormIcons_Container,        "FormIcons:Container")
  Theme_LoadImage(#IMAGE_FormIcons_Date,             "FormIcons:Date")
  Theme_LoadImage(#IMAGE_FormIcons_Editor,           "FormIcons:Editor")
  Theme_LoadImage(#IMAGE_FormIcons_ExplorerCombo,    "FormIcons:ExplorerCombo")
  Theme_LoadImage(#IMAGE_FormIcons_ExplorerList,     "FormIcons:ExplorerList")
  Theme_LoadImage(#IMAGE_FormIcons_ExplorerTree,     "FormIcons:ExplorerTree")
  Theme_LoadImage(#IMAGE_FormIcons_Frame3D,          "FormIcons:Frame3D")
  Theme_LoadImage(#IMAGE_FormIcons_HyperLink,        "FormIcons:HyperLink")
  Theme_LoadImage(#IMAGE_FormIcons_Image,            "FormIcons:Image")
  Theme_LoadImage(#IMAGE_FormIcons_IPAddress,        "FormIcons:IPAddress")
  Theme_LoadImage(#IMAGE_FormIcons_ListIcon,         "FormIcons:ListIcon")
  Theme_LoadImage(#IMAGE_FormIcons_ListView,         "FormIcons:ListView")
  Theme_LoadImage(#IMAGE_FormIcons_Menu,             "FormIcons:Menu")
  Theme_LoadImage(#IMAGE_FormIcons_Option,           "FormIcons:Option")
  Theme_LoadImage(#IMAGE_FormIcons_Panel,            "FormIcons:Panel")
  Theme_LoadImage(#IMAGE_FormIcons_ProgressBar,      "FormIcons:ProgressBar")
  Theme_LoadImage(#IMAGE_FormIcons_ScrollArea,       "FormIcons:ScrollArea")
  Theme_LoadImage(#IMAGE_FormIcons_ScrollBar,        "FormIcons:ScrollBar")
  Theme_LoadImage(#IMAGE_FormIcons_Spin,             "FormIcons:Spin")
  Theme_LoadImage(#IMAGE_FormIcons_Splitter,         "FormIcons:Splitter")
  Theme_LoadImage(#IMAGE_FormIcons_Status,           "FormIcons:Status")
  Theme_LoadImage(#IMAGE_FormIcons_String,           "FormIcons:String")
  Theme_LoadImage(#IMAGE_FormIcons_Text,             "FormIcons:Text")
  Theme_LoadImage(#IMAGE_FormIcons_ToolBar,          "FormIcons:ToolBar")
  Theme_LoadImage(#IMAGE_FormIcons_TrackBar,         "FormIcons:TrackBar")
  Theme_LoadImage(#IMAGE_FormIcons_Tree,             "FormIcons:Tree")
  Theme_LoadImage(#IMAGE_FormIcons_Web,              "FormIcons:Web")
  Theme_LoadImage(#IMAGE_FormIcons_Cursor,           "FormIcons:Cursor")
  Theme_Close()
  
EndProcedure


DataSection
  
  DefaultTheme:
  IncludeBinary "Build/DefaultTheme.zip"
  EndDefaultTheme:
  
EndDataSection



