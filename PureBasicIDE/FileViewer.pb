; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Structure FileViewer
  FileName$; to compare to newly opened files..
  
  Gadget.i ; scrollarea or editor.. this value is only needed for resizing
  Image.i  ; loaded image if any
EndStructure

Global NewList FileViewer.FileViewer()

UseJPEGImageDecoder()
UsePNGImageDecoder()
UseTGAImageDecoder()

Global FileViewerOpen

Procedure FileViewer_UpdateButtonStates()
  
  count = ListSize(FileViewer())
  If count = 0
    DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Close, 1)
    DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, 1)
    DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, 1)
    
  Else
    DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Close, 0)
    index = ListIndex(FileViewer())
    
    If count = 1
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, 1)
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, 1)
      
    ElseIf index = 0
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, 1)
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, 0)
      
    ElseIf index = count-1
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, 0)
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, 1)
      
    Else
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, 0)
      DisableToolBarButton(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, 0)
      
    EndIf
  EndIf
  
EndProcedure

Procedure ResizeFileViewer()
  
  ResizeGadget(#GADGET_FileViewer_Panel, 0, ToolbarTopOffset, WindowWidth(#WINDOW_FileViewer), WindowHeight(#WINDOW_FileViewer)-ToolbarHeight-StatusBarHeight)
  
  PanelWidth = GetPanelWidth(#GADGET_FileViewer_Panel)
  PanelHeight = GetPanelHeight(#GADGET_FileViewer_Panel)
  
  ForEach FileViewer()
    
    If FileViewer()\Gadget
      ResizeGadget(FileViewer()\Gadget, 0, 0, PanelWidth, PanelHeight)
    EndIf
    
  Next FileViewer()
EndProcedure

Procedure OpenFileViewerWindow()
  
  If IsWindow(#WINDOW_FileViewer) = 0
    
    ; TODO: Something is wrong here with the PB_OpenWindow3_DEBUG call because it
    ;   complains about the ParentID not being valid when it clearly is.
    ;   This happened only with AllocationPreference set to high addresses first (Windows x64)
    ;
    DisableDebugger
    If OpenWindow(#WINDOW_FileViewer, FileViewerX, FileViewerY, FileViewerWidth, FileViewerHeight, Language("FileViewer","Title"), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_Invisible, WindowID(#WINDOW_Main))
      EnableDebugger
      
      CompilerIf #CompileMac
        If OSVersion() >= #PB_OS_MacOSX_10_14
          ; Fix Toolbar style from titlebar to expanded (Top Left)
          #NSWindowToolbarStyleExpanded = 1
          CocoaMessage(0, WindowID(#WINDOW_FileViewer), "setToolbarStyle:", #NSWindowToolbarStyleExpanded)
        EndIf
      CompilerEndIf
      
      SmartWindowRefresh(#WINDOW_FileViewer, 1)
      
      CompilerIf #CompileMac
        flags = #PB_ToolBar_Large
      CompilerElse
        flags = 0
      CompilerEndIf
      
      If CreateToolBar(#TOOLBAR_FileViewer, WindowID(#WINDOW_FileViewer), flags)
        ToolBarImageButton(#MENU_FileViewer_Open, ImageID(#IMAGE_FileViewer_Open))
        ToolBarImageButton(#MENU_FileViewer_Close, ImageID(#IMAGE_FileViewer_Close))
        ToolBarSeparator()
        ToolBarImageButton(#MENU_FileViewer_Previous, ImageID(#IMAGE_FileViewer_Left))
        ToolBarImageButton(#MENU_FileViewer_Next, ImageID(#IMAGE_FileViewer_Right))
        
        ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Open, Language("FileViewer","Open"))
        ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Close, Language("FileViewer","Close"))
        ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, Language("FileViewer","Previous"))
        ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, Language("FileViewer","Next"))
      EndIf
      
      If CreateStatusBar(#STATUSBAR_FileViewer, WindowID(#WINDOW_FileViewer))
        AddStatusBarField(#PB_Ignore)
      EndIf
      
      PanelGadget(#GADGET_FileViewer_Panel, 0, ToolbarTopOffset, FileViewerWidth, FileViewerHeight-ToolbarHeight-StatusBarHeight)
      CloseGadgetList()
      
      EnableGadgetDrop(#GADGET_FileViewer_Panel, #PB_Drop_Files, #PB_Drag_Copy)
      EnableWindowDrop(#WINDOW_FileViewer, #PB_Drop_Files, #PB_Drag_Copy)
      
      
      EnsureWindowOnDesktop(#WINDOW_FileViewer)
      If FileViewerMaximize
        ShowWindowMaximized(#WINDOW_FileViewer)
      Else
        HideWindow(#WINDOW_FileViewer, 0)
      EndIf
      
      ResizeFileViewer()
      FileViewer_UpdateButtonStates()
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_FileViewer)
  EndIf
  
EndProcedure

Procedure IsBinaryFile(*Buffer, Length)
  ; Check if the Data is text only or binary (search for bytes <= 30, except cr,lf,tab)
  ; Note: we use a binary count as old PB file used a zero char to separate the bottom options from the real code
  ; Also JaPBe uses some similar trick.
  ;
  BinaryCount = 0
  IsBinary = 0
  *Pointer.Ascii = *Buffer
  While *Pointer < *Buffer+Length
    If *Pointer\a < 32 And *Pointer\a <> 10 And *Pointer\a <> 13 And *Pointer\a <> 9
      BinaryCount + 1
      If BinaryCount > 10
        IsBinary = 1
        Break
      EndIf
    EndIf
    *Pointer + 1
  Wend
  
  ProcedureReturn IsBinary
EndProcedure

Procedure FileViewer_OpenFile(Filename$)
  
  AddTools_RunFileViewer = 1 ; to tell if some tool has been executed
  AddTools_File$ = FileName$
  Ext$ = LCase(GetExtensionPart(FileName$))
  
  AddTools_Execute(#TRIGGER_FileViewer_Special, 0) ; special file tools have highest priority
  
  If AddTools_RunFileViewer
    AddTools_Execute(#TRIGGER_FileViewer_All, 0)
  EndIf
  
  If AddTools_RunFileViewer
    If Ext$ <> "bmp" And Ext$ <> "png" And Ext$ <> "jpg" And Ext$ <> "jpeg" And Ext$ <> "tga" And Ext$ <> "ico" And Ext$ <> "txt"
      AddTools_Execute(#TRIGGER_FileViewer_Unknown, 0)
    EndIf
  EndIf
  
  If AddTools_RunFileViewer = 0  ; stop if a tool has been run
    ProcedureReturn
  EndIf
  
  SizeMB.f = FileSize(FileName$)/(1024*1024)
  If SizeMB > 10 ; = 10 mb is the max size handled by file viewer, or it will take forever to display in our EditorGadget() based hex viewer
    MessageRequester(#ProductName$, Language("FileViewer","SizeError"), #FLAG_Error|#PB_MessageRequester_Ok)
    ProcedureReturn
  ElseIf SizeMB > 4 ; = 4 mb check for large files which might take long to load
    If MessageRequester(#ProductName$, Language("FileViewer","SizeWarning")+" ("+StrF(SizeMB, 1)+" MB)"+#NewLine+Language("FileViewer","SizeQuestion"), #FLAG_Warning|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
      ProcedureReturn
    EndIf
  EndIf
  
  ; check if window is open
  ;
  If IsWindow(#WINDOW_FileViewer) = 0
    OpenFileViewerWindow()
  Else
    SetWindowForeground(#WINDOW_FileViewer)
  EndIf
  
  ; check if this file was already loaded
  ;
  Found = 0
  ForEach FileViewer()
    If LCase(FileViewer()\FileName$) = LCase(FileName$)
      Found = 1
      Break
    EndIf
  Next FileViewer()
  
  If Found = 1
    SetGadgetState(#GADGET_FileViewer_Panel, ListIndex(FileViewer()))
    StatusBarText(#STATUSBAR_FileViewer, 0, FileName$)
    
  Else
    
    ; find out if it is an image file..
    If Ext$ = "bmp" Or Ext$ = "png" Or Ext$ = "jpg" Or Ext$ = "jpeg" Or Ext$ = "tga" Or Ext$ = "ico"
      
      Image = LoadImage(#PB_Any, FileName$)
      If Image
        LastElement(FileViewer())
        AddElement(FileViewer())
        FileViewer()\FileName$ = FileName$
        
        FileViewer()\Image = Image
        
        OpenGadgetList(#GADGET_FileViewer_Panel)
        AddGadgetItem(#GADGET_FileViewer_Panel, -1, GetFilePart(FileName$))
        FileViewer()\Gadget = ScrollAreaGadget(#PB_Any, 0, 0, GetPanelWidth(#GADGET_FileViewer_Panel), GetPanelHeight(#GADGET_FileViewer_Panel), ImageWidth(Image), ImageHeight(Image), 10, #PB_ScrollArea_Center)
        ImageGadget = ImageGadget(#PB_Any, 0, 0, ImageWidth(Image), ImageHeight(Image), ImageID(Image))
        
        EnableGadgetDrop(ImageGadget, #PB_Drop_Files, #PB_Drag_Copy)
        CloseGadgetList()
        CloseGadgetList()
      Else
        MessageRequester(#ProductName$, Language("FileStuff","MiscLoadError"), #FLAG_Error)
      EndIf
      
      CompilerIf #CompileWindows ; the gtk2 is not working well enough on all machines
        
      ElseIf Ext$ = "html" Or Ext$ = "htm"
        
        LastElement(FileViewer())
        AddElement(FileViewer())
        FileViewer()\FileName$ = FileName$
        
        OpenGadgetList(#GADGET_FileViewer_Panel)
        AddGadgetItem(#GADGET_FileViewer_Panel, -1, GetFilePart(FileName$))
        FileViewer()\Gadget = WebGadget(#PB_Any, 0, 0, GetPanelWidth(#GADGET_FileViewer_Panel), GetPanelHeight(#GADGET_FileViewer_Panel), "file://" + FileName$)
        CloseGadgetList()
        
      CompilerEndIf
      
    Else
      
      If ReadFile(#FILE_FileViewer, FileName$)
        
        Length = Lof(#FILE_FileViewer)
        
        If Length > 0
          *Buffer = AllocateMemory(Length)
        EndIf
        
        If *Buffer Or Length = 0
          
          ; add the editorgadget and prepare it
          ;
          LastElement(FileViewer())
          AddElement(FileViewer())
          FileViewer()\FileName$ = FileName$
          
          OpenGadgetList(#GADGET_FileViewer_Panel)
          AddGadgetItem(#GADGET_FileViewer_Panel, -1, GetFilePart(FileName$))
          FileViewer()\Gadget = ScintillaGadget(#PB_Any, 0, 0, GetPanelWidth(#GADGET_FileViewer_Panel), GetPanelHeight(#GADGET_FileViewer_Panel), #Null)
          CloseGadgetList()
          
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_USEPOPUP, 1, 0) ; use the scintilla popup
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_SETMARGINWIDTHN, 0, 0)
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_SETMARGINWIDTHN, 1, 0)
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_STYLESETFONT,  #STYLE_DEFAULT, ToAscii(EditorFontName$))
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT,  EditorFontSize)
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_STYLECLEARALL, 0, 0)
          ScintillaSendMessage(FileViewer()\Gadget, #SCI_SETCODEPAGE, 0, 0)
          
          EnableGadgetDrop(FileViewer()\Gadget, #PB_Drop_Files, #PB_Drag_Copy)
          
          If Length > 0
            
            ; ok, now read the file
            ;
            ReadData(#FILE_FileViewer, *Buffer, Length)
            
            If IsBinaryFile(*Buffer, Length) = #False
              ChangeNewLineType(@*Buffer, @Length, #DEFAULT_NewLineType)
              
              Text$ = PeekS(*Buffer, Length, #PB_Ascii)
              ScintillaSendMessage(FileViewer()\Gadget, #SCI_SETTEXT, 0, ToAscii(Text$))
            Else
              *Buffer2 = AllocateMemory(((Length + 16) * 78) / 8) ; Add 16 as the last 16 char block line can be only one character length
              *Pointer2 = *Buffer2
              CopyMemoryString(@"", @*Pointer2)
              
              ; display a nice hex view
              ;
              *Pointer.Ascii = *Buffer
              Repeat
                HexData$ = RSet(Hex(*Pointer-*Buffer), 8, "0") + "  "
                String$  = " "
                For i = 0 To $F
                  
                  If *Pointer > *Buffer+Length
                    HexData$ = LSet(HexData$, 58, " ")
                    Break
                  EndIf
                  
                  HexData$ + RSet(Hex(*Pointer\a, #PB_Byte), 2, "0") + " "
                  
                  If *Pointer\a < 32
                    String$ + "."
                  Else
                    String$ + Chr(*Pointer\a)
                  EndIf
                  
                  *Pointer + 1
                Next i
                
                CopyMemoryString(HexData$)
                CopyMemoryString(String$)
                CopyMemoryString(#NewLine)
              Until *Pointer > *Buffer+Length
              
              Text$ = PeekS(*Buffer2, (*Pointer2-*Buffer2) / #CharSize)
              ScintillaSendMessage(FileViewer()\Gadget, #SCI_SETTEXT, 0, ToAscii(Text$))
              
              FreeMemory(*Buffer2)
              
            EndIf
            
            FreeMemory(*Buffer)
            
          EndIf
          
          SetGadgetAttribute(FileViewer()\Gadget, #PB_Editor_ReadOnly, 1)
        Else
          MessageRequester(#ProductName$, Language("FileStuff","MiscLoadError"), #FLAG_Error)
        EndIf
        
        CloseFile(#FILE_FileViewer)
      Else
        MessageRequester(#ProductName$, Language("FileStuff","MiscLoadError"), #FLAG_Error)
      EndIf
    EndIf
    
    
    SetGadgetState(#GADGET_FileViewer_Panel, CountGadgetItems(#GADGET_FileViewer_Panel)-1)
    If LastElement(FileViewer())
      StatusBarText(#STATUSBAR_FileViewer, 0, FileViewer()\FileName$)
    EndIf
  EndIf
  
  ResizeFileViewer()
  FileViewer_UpdateButtonStates()
EndProcedure

Procedure FileViewerWindowEvents(EventID)
  
  If EventID = #PB_Event_GadgetDrop Or EventID = #PB_Event_WindowDrop
    Files$ = EventDropFiles()
    Count  = CountString(Files$, Chr(10))+1
    
    For i = 1 To Count
      File$ = StringField(Files$, i, Chr(10))
      If File$ <> "" And FileSize(File$) <> -2 ; no directories!
        FileViewer_OpenFile(File$)
      EndIf
    Next i
    
    
  ElseIf EventID = #PB_Event_Menu
    Select EventMenu()
      Case #MENU_FileViewer_Open
        
        Pattern$ = Language("FileViewer","Pattern")
        CompilerIf #CompileWindows = 0
          ; have to remove the .ico pattern...
          Pattern$ = RemoveString(Pattern$, ", *.ico")
          Pattern$ = RemoveString(Pattern$, ",*.ico")
          Pattern$ = RemoveString(Pattern$, ";*.ico")
        CompilerEndIf
        
        FileName$ = OpenFileRequester(Language("FileStuff","OpenFileTitle"), FileViewerPath$, AddTools_PatternStrings$ + Pattern$, FileViewerPattern, #PB_Requester_MultiSelection)
        If FileName$
          FileViewerPattern = SelectedFilePattern()
          FileViewerPath$   = GetPathPart(FileName$)
          
          While FileName$
            FileViewer_OpenFile(FileName$)
            FileName$ = NextSelectedFileName()
          Wend
          
        EndIf
        
      Case #MENU_FileViewer_Close
        If CountGadgetItems(#GADGET_FileViewer_Panel) > 0
          SelectElement(FileViewer(), GetGadgetState(#GADGET_FileViewer_Panel))
          
          If FileViewer()\Image
            FreeImage(FileViewer()\Image)
          EndIf
          
          If ListIndex(FileViewer()) = 0
            DeleteElement(FileViewer())
            FirstElement(FileViewer())
          Else
            DeleteElement(FileViewer())
          EndIf
          
          RemoveGadgetItem(#GADGET_FileViewer_Panel, GetGadgetState(#GADGET_FileViewer_Panel))
          
          If ListSize(FileViewer()) > 0
            StatusBarText(#STATUSBAR_FileViewer, 0, FileViewer()\FileName$)
          Else
            StatusBarText(#STATUSBAR_FileViewer, 0, "")
          EndIf
        EndIf
        FileViewer_UpdateButtonStates()
        
      Case #MENU_FileViewer_Previous
        If ListSize(FileViewer()) > 0
          index = GetGadgetState(#GADGET_FileViewer_Panel)
          If index = 0
            SetGadgetState(#GADGET_FileViewer_Panel, CountGadgetItems(#GADGET_FileViewer_Panel)-1)
            LastElement(FileViewer())
          Else
            SetGadgetState(#GADGET_FileViewer_Panel, index-1)
            SelectElement(FileViewer(), index-1)
          EndIf
          StatusBarText(#STATUSBAR_FileViewer, 0, FileViewer()\FileName$)
        EndIf
        FileViewer_UpdateButtonStates()
        
      Case #MENU_FileViewer_Next
        If ListSize(FileViewer()) > 0
          index = GetGadgetState(#GADGET_FileViewer_Panel)
          If index = CountGadgetItems(#GADGET_FileViewer_Panel)-1
            SetGadgetState(#GADGET_FileViewer_Panel, 0)
            FirstElement(FileViewer())
          Else
            SetGadgetState(#GADGET_FileViewer_Panel, index+1)
            SelectElement(FileViewer(), index+1)
          EndIf
          StatusBarText(#STATUSBAR_FileViewer, 0, FileViewer()\FileName$)
        EndIf
        FileViewer_UpdateButtonStates()
        
    EndSelect
    
  ElseIf EventID = #PB_Event_Gadget
    If EventGadget() = #GADGET_FileViewer_Panel
      If SelectElement(FileViewer(), GetGadgetState(#GADGET_FileViewer_Panel))
        StatusBarText(#STATUSBAR_FileViewer, 0, FileViewer()\FileName$)
      EndIf
      FileViewer_UpdateButtonStates()
    EndIf
    
  ElseIf EventID = #PB_Event_SizeWindow
    ResizeFileViewer()
    
  ElseIf EventID = #PB_Event_CloseWindow
    
    If MemorizeWindow And IsWindowMinimized(#WINDOW_FileViewer) = 0
      FileViewerMaximize = IsWindowMaximized(#WINDOW_FileViewer)
      If FileViewerMaximize = 0
        FileViewerX      = WindowX(#WINDOW_FileViewer)
        FileViewerY      = WindowY(#WINDOW_FileViewer)
        FileViewerWidth  = WindowWidth(#WINDOW_FileViewer)
        FileViewerHeight = WindowHeight(#WINDOW_FileViewer)
      EndIf
    EndIf
    
    ForEach FileViewer()
      
      If FileViewer()\Image
        FreeImage(FileViewer()\Image)
      EndIf
      
    Next FileViewer()
    
    ClearList(FileViewer())
    CloseWindow(#WINDOW_FileViewer)
    
  EndIf
  
EndProcedure

Procedure UpdateFileViewerWindow()
  
  SetWindowTitle(#WINDOW_FileViewer, Language("FileViewer","Title"))
  
  ; re-create the toolbar to apply theme changes
  FreeToolBar(#TOOLBAR_FileViewer)
  
  If CreateToolBar(#TOOLBAR_FileViewer, WindowID(#WINDOW_FileViewer))
    ToolBarImageButton(#MENU_FileViewer_Open, ImageID(#IMAGE_FileViewer_Open))
    ToolBarImageButton(#MENU_FileViewer_Close, ImageID(#IMAGE_FileViewer_Close))
    ToolBarSeparator()
    ToolBarImageButton(#MENU_FileViewer_Previous, ImageID(#IMAGE_FileViewer_Left))
    ToolBarImageButton(#MENU_FileViewer_Next, ImageID(#IMAGE_FileViewer_Right))
    
    ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Open, Language("FileViewer","Open"))
    ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Close, Language("FileViewer","Close"))
    ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Previous, Language("FileViewer","Previous"))
    ToolBarToolTip(#TOOLBAR_FileViewer, #MENU_FileViewer_Next, Language("FileViewer","Next"))
  EndIf
  
  FileViewer_UpdateButtonStates()
  
EndProcedure