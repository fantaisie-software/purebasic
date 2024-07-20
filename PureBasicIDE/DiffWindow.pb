; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Diff tools for the PB IDE
;

;- Globals


; Define this to true if the ScintillaGadget supports the following defined messages
; to have a margin with text in it (needs a more recent scintilla version)
; If supported, we can show line numbers (with gaps) in the diff output which is very nice
;
#SCINTILLA_TEXT_MARGIN = #True

; Represents one line in a file to diff
; Used for the markers in the scintilla gadget
;
Enumeration
  #DIFF_Empty ; for empty lines when changes are made in other file
  #DIFF_Equal
  #DIFF_Added
  #DIFF_Removed
  #DIFF_Changed
  
  #DIFF_StateCount
EndEnumeration

#DIFF_ChangeMarker = #DIFF_StateCount * 2

; future modes may be added here if we have a backup system etc
;
Enumeration
  #DIFF_FileToFile
  #DIFF_SourceToFile
EndEnumeration

; Represents a block of styled characters for the final diff document
Structure DiffStyleBlock
  *Start
  Length.l
  Lines.l
  Style.l
EndStructure

; represents a file entry in directory diff
Structure DiffFile
  Name$   ; may differ if FS is case insensitive, but we use only one name for display anyway
  Style.l
  DateA.l ; last modified
  DateB.l
EndStructure

; information about the two files to diff
;
Global DiffA_Size, DiffB_Size
Global DiffA_Lines, DiffB_Lines                     ; # of lines
Global DiffA_Utf8, DiffB_Utf8                       ; is utf8 bom present
Global *DiffA_Buffer, *DiffB_Buffer                 ; memory buffer containing original files (stays allocated until diff is closed)
Global *DiffA_Start, *DiffB_Start                   ; buffer offset after BOM (if any)
Global NewList StyleA.DiffStyleBlock()              ; resulting diff blocks (stays allocated until diff is closed)
Global NewList StyleB.DiffStyleBlock()
Global DiffA_Title$, DiffB_Title$
Global DiffA_File$, DiffB_File$
Global *DiffSource.SourceFile, DiffMode

; for directory diff
;
Global DiffDirectoryMode ; 0=files only, 1=directory+files, 2=directory only
Global DiffA_Base$, DiffB_Base$, DiffPattern$
Global NewList DiffFiles.DiffFile()

; For the scroll sync
Global DiffScrollX, DiffScrollY, DiffZoom

; For styling
Global DiffStyleGadget, DiffStyleBase, DiffSwapped
Global DiffOpenPattern ; not stored in prefs

Declare UpdateDiffGadget(IsLeft, List Style.DiffStyleBlock(), SetText)
Declare UpdateDiffFileList()


;- Diff window

; Show/hide the progress gadgets and take other appropriate actions
;
Procedure ShowDiffProgress(ShowProgress)
  If ShowProgress
    State = 0
  Else
    State = 1
  EndIf
  
  HideGadget(#GADGET_Diff_Busy, State)
  
  If DiffDirectoryMode = 0
    HideGadget(#GADGET_Diff_Splitter, 1-State)
    
  Else
    HideGadget(#GADGET_Diff_FileTitle, 1-State)
    If DiffDirectoryMode = 1
      HideGadget(#GADGET_Diff_Splitter2, 1-State)
    Else
      HideGadget(#GADGET_Diff_Files, 1-State)
    EndIf
  EndIf
EndProcedure


Procedure ResizeDiffSplitterContent()  ; triggered on a splitter move
  text = Max(GetRequiredHeight(#GADGET_Diff_Title1), 18)
  
  w = GadgetWidth(#GADGET_Diff_Container1)
  h = GadgetHeight(#GADGET_Diff_Container1)
  ResizeGadget(#GADGET_Diff_Title1, 0, 0, w, text)
  ResizeGadget(#GADGET_Diff_File1, 0, text+2, w, h-text-2)
  
  w = GadgetWidth(#GADGET_Diff_Container2)
  h = GadgetHeight(#GADGET_Diff_Container2)
  ResizeGadget(#GADGET_Diff_Title2, 0, 0, w, text)
  ResizeGadget(#GADGET_Diff_File2, 0, text+2, w, h-text-2)
EndProcedure

Procedure UpdateDiffToolbar()
  ; open tool, swap, refresh, up/down is always on
  
  If DiffDirectoryMode < 2 ; files visible
    FileState = 0
  Else
    FileState = 1
  EndIf
  
  DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_Open1, FileState)
  DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_Open2, FileState)
  DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_Colors, FileState)
  DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_Vertical, FileState)
  
  If DiffDirectoryMode > 0 ; directory visible
    If DiffDirectoryMode = 2
      DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_HideFiles, 1)
    Else
      DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_HideFiles, 0)
    EndIf
  Else
    DisableToolBarButton(#TOOLBAR_Diff, #MENU_Diff_HideFiles, 1)
  EndIf
EndProcedure

Procedure SwitchDirectoryMode(TargetMode)
  
  ; adjust the splitters as needed
  ;
  If DiffDirectoryMode <> TargetMode
    
    ; required for the creation of the temp gadgets (when switching splitter content)
    UseGadgetList(WindowID(#WINDOW_Diff))
    
    Select DiffDirectoryMode
        
      Case 0 ; files only
             ; need to create the required gadgets now
             ;
        CompilerIf #CompileWindows
          TextGadget(#GADGET_Diff_FileTitle, 0, 0, 0, 0, "")
        CompilerElse
          TextGadget(#GADGET_Diff_FileTitle, 0, 0, 0, 0, "", #PB_Text_Border)
        CompilerEndIf
        ListIconGadget(#GADGET_Diff_Files, 0, 0, 250, 0, Language("Diff","Filename"), 250, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
        AddGadgetColumn(#GADGET_Diff_Files, 1, Language("Diff","State"), 100)
        AddGadgetColumn(#GADGET_Diff_Files, 2, Language("Diff","Date1"), 130)
        AddGadgetColumn(#GADGET_Diff_Files, 3, Language("Diff","Date2"), 130)
        
        If TargetMode = 1
          SplitterGadget(#GADGET_Diff_Splitter2, 0, 0, 0, 0, #GADGET_Diff_Files, #GADGET_Diff_Splitter)
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_FirstMinimumSize, 80)
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_SecondMinimumSize, 80)
        Else
          HideGadget(#GADGET_Diff_Splitter, 1)
        EndIf
        
        
      Case 1 ; files and directory
             ; need to put dummy gadgets in the splitter so it can then be freed without freeing the old content
             ;
        If TargetMode = 0
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_SecondGadget, TextGadget(#PB_Any,0,0,0,0,""))
          FreeGadget(#GADGET_Diff_Splitter2) ; frees the splitter and the listicon
          FreeGadget(#GADGET_Diff_FileTitle)
        Else
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_FirstGadget, TextGadget(#PB_Any,0,0,0,0,""))
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_SecondGadget, TextGadget(#PB_Any,0,0,0,0,""))
          FreeGadget(#GADGET_Diff_Splitter2) ; frees only the splitter
          HideGadget(#GADGET_Diff_Splitter, 1)  ; this one is just hidden, never freed
        EndIf
        
        
      Case 2 ; directory only
        HideGadget(#GADGET_Diff_Splitter, 0)
        
        If TargetMode = 0
          FreeGadget(#GADGET_Diff_FileTitle)
          FreeGadget(#GADGET_Diff_Files)
        Else
          UseGadgetList(WindowID(#WINDOW_Diff))
          SplitterGadget(#GADGET_Diff_Splitter2, 0, 0, 0, 0, #GADGET_Diff_Files, #GADGET_Diff_Splitter)
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_FirstMinimumSize, 80)
          SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_SecondMinimumSize, 80)
        EndIf
        
    EndSelect
    
    
  EndIf
  
  DiffDirectoryMode = TargetMode
  
  ; Update toolbar accordingly
  UpdateDiffToolbar()
  
  ; resize
  DiffWindowEvents(#PB_Event_SizeWindow)
  ResizeDiffSplitterContent()
EndProcedure

Procedure ShowNextDifference(Gadget, Forward, IsFirst)
  
  If Gadget = #GADGET_Diff_Files Or DiffDirectoryMode = 2 ; use it if only directories are visible too
                                                          ; directory mode
    index = GetGadgetState(#GADGET_Diff_Files)
    If index = -1 Or IsFirst
      index = 0
    ElseIf Forward
      index + 1
    Else
      index - 1
    EndIf
    
    If SelectElement(DiffFiles(), index)
      Repeat
        If DiffFiles()\Style <> #DIFF_Equal
          SetGadgetState(#GADGET_Diff_Files, ListIndex(DiffFiles())) ; mark this
          Break
        ElseIf Forward
          Result = NextElement(DiffFiles())
        Else
          Result = PreviousElement(DiffFiles())
        EndIf
      Until Result = 0
    EndIf
    SetActiveGadget(#GADGET_Diff_Files)
    
  Else
    ; always fallback to File1 if none of the files is selected
    If Gadget <> #GADGET_Diff_File2
      Gadget = #GADGET_Diff_File1
      Other  = #GADGET_Diff_File2
    Else
      Other  = #GADGET_Diff_File1
    EndIf
    
    If IsFirst
      line = ScintillaSendMessage(Gadget, #SCI_MARKERNEXT, 0, 1 << #DIFF_ChangeMarker)
    Else
      line = ScintillaSendMessage(Gadget, #SCI_LINEFROMPOSITION, ScintillaSendMessage(Gadget, #SCI_GETCURRENTPOS))
      If Forward
        line = ScintillaSendMessage(Gadget, #SCI_MARKERNEXT, line+1, 1 << #DIFF_ChangeMarker)
      Else
        line = ScintillaSendMessage(Gadget, #SCI_MARKERPREVIOUS, line-1, 1 << #DIFF_ChangeMarker)
      EndIf
    EndIf
    
    If line <> -1
      ScintillaSendMessage(Gadget, #SCI_LINESCROLL, -99999, -99999)
      ScintillaSendMessage(Gadget, #SCI_LINESCROLL, 0, line-3)
      ScintillaSendMessage(Gadget, #SCI_GOTOLINE, line, 0)
      
      ; scroll the other to the same place
      ScintillaSendMessage(Other, #SCI_LINESCROLL, -99999, -99999)
      ScintillaSendMessage(Other, #SCI_LINESCROLL, 0, line-3)
      ScintillaSendMessage(Other, #SCI_GOTOLINE, line, 0)
    EndIf
    
    SetActiveGadget(Gadget)
    
  EndIf
  
EndProcedure

Procedure DiffWindowEvents(EventID)
  
  If EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case #GADGET_Diff_Splitter, #GADGET_Diff_Splitter
        ResizeDiffSplitterContent()
        
      Case #GADGET_Diff_Files
        If DiffDirectoryMode > 0 And EventType() = #PB_EventType_LeftDoubleClick
          index = GetGadgetState(#GADGET_Diff_Files)
          If index <> -1 And SelectElement(DiffFiles(), index)
            If DiffFiles()\Style = #DIFF_Changed Or DiffFiles()\Style = #DIFF_Equal ; cannot compare against added/removed files
              DiffFileToFile(DiffA_Base$+DiffFiles()\Name$, DiffB_Base$+DiffFiles()\Name$, #False, 1)
            EndIf
          EndIf
        Else
          UpdateDiffToolbar() ; update on selection changes
        EndIf
        
    EndSelect
    
  ElseIf EventID = #PB_Event_Menu
    EventMenu = EventMenu()
    Select EventMenu
        
      Case #MENU_Diff_Open1, #MENU_Diff_Open2
        If EventMenu = #MENU_Diff_Open1
          If DiffSwapped = 0
            First = #True
          Else
            First = #False
          EndIf
        Else
          If DiffSwapped = 0
            First = #False
          Else
            First = #True
          EndIf
        EndIf
        
        Select DiffMode
          Case #DIFF_FileToFile
            If First
              LoadSourceFile(DiffA_File$)
            Else
              LoadSourceFile(DiffB_File$)
            EndIf
            
          Case #DIFF_SourceToFile ; A is a *Source, B is a file
            If First
              ChangeCurrentElement(FileList(), *DiffSource)
              ChangeActiveSourceCode()
            Else
              LoadSourceFile(DiffB_File$)
            EndIf
            
        EndSelect
        
      Case #MENU_Diff_Refresh
        If DiffDirectoryMode > 0
          DiffDirectories(DiffA_Base$, DiffB_Base$, DiffPattern$, DiffSwapped, DiffDirectoryMode)
        EndIf
        
        If DiffDirectoryMode < 2
          Select DiffMode
            Case #DIFF_FileToFile
              DiffFileToFile(DiffA_File$, DiffB_File$, DiffSwapped, DiffDirectoryMode)
              
            Case #DIFF_SourceToFile
              DiffSourceToFile(*DiffSource, DiffB_File$, DiffSwapped)
              
          EndSelect
        EndIf
        
        
      Case #MENU_Diff_Colors
        If DiffDirectoryMode < 2
          If DiffShowColors
            DiffShowColors = 0
          Else
            DiffShowColors = 1
          EndIf
          SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Colors, DiffShowColors)
          ; update the gadget colors
          UpdateDiffGadget(#True, StyleA(), #False)
          UpdateDiffGadget(#False, StyleB(), #False)
        EndIf
        
        
      Case #MENU_Diff_Swap
        If DiffSwapped = 0
          DiffSwapped = 1
        Else
          DiffSwapped = 0
        EndIf
        SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Swap, DiffSwapped)
        
        If DiffDirectoryMode > 0
          ; just update the view
          UpdateDiffFileList()
        EndIf
        
        If DiffDirectoryMode < 2
          ; swapping the files produces the identical diff output, just
          ; with inserts and deletes reversed, so no need to recalculate it all
          ;
          If DiffSwapped = 0
            SetGadgetText(#GADGET_Diff_Title1, DiffA_Title$) ; set original titles
            SetGadgetText(#GADGET_Diff_Title2, DiffB_Title$)
          Else
            SetGadgetText(#GADGET_Diff_Title1, DiffB_Title$) ; swap the titles
            SetGadgetText(#GADGET_Diff_Title2, DiffA_Title$)
          EndIf
          ; now update the coloring+text, this takes care of the rest
          UpdateDiffGadget(#True, StyleA(), #True)
          UpdateDiffGadget(#False, StyleB(), #True)
          
          ; mark the first difference again
          ShowNextDifference(#GADGET_Diff_File1, #True, #True)
        EndIf
        
      Case #MENU_Diff_Vertical
        If DiffDirectoryMode < 2
          If DiffVertical
            DiffVertical = 0
          Else
            DiffVertical = 1
          EndIf
          
          Width  = WindowWidth(#WINDOW_Diff)
          Height = WindowHeight(#WINDOW_Diff)
          
          ; required for the creation of the temp gadgets (when switching splitter content)
          UseGadgetList(WindowID(#WINDOW_Diff))
          
          If DiffDirectoryMode = 1
            ; must get the splitter out of the outer splitter first. use a dummy for the replacement
            dummy = TextGadget(#PB_Any, 0, 0, 0, 0, "")
            SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_SecondGadget, dummy)
          EndIf
          
          ; remove the old splitter from the window, replace the content first with dummy gadgets
          SetGadgetAttribute(#GADGET_Diff_Splitter, #PB_Splitter_FirstGadget, TextGadget(#PB_Any, 0, 0, 0, 0, ""))
          SetGadgetAttribute(#GADGET_Diff_Splitter, #PB_Splitter_SecondGadget, TextGadget(#PB_Any, 0, 0, 0, 0, ""))
          FreeGadget(#GADGET_Diff_Splitter)
          UseGadgetList(WindowID(#WINDOW_Diff))
          
          If DiffVertical
            SplitterGadget(#GADGET_Diff_Splitter, 5, 5+ToolbarTopOffset, Width-10, Height-10-ToolbarHeight, #GADGET_Diff_Container1, #GADGET_Diff_Container2)
          Else
            SplitterGadget(#GADGET_Diff_Splitter, 5, 5+ToolbarTopOffset, Width-10, Height-10-ToolbarHeight, #GADGET_Diff_Container1, #GADGET_Diff_Container2, #PB_Splitter_Vertical)
          EndIf
          
          If DiffDirectoryMode = 1
            ; put it back into the other splitter (and delete the dummy)
            SetGadgetAttribute(#GADGET_Diff_Splitter2, #PB_Splitter_SecondGadget, #GADGET_Diff_Splitter)
            FreeGadget(dummy)
          EndIf
          
          SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Vertical, DiffVertical)
          ResizeDiffSplitterContent()
        EndIf
        
      Case #MENU_Diff_ShowTool
        OpenDiffDialogWindow()
        
      Case #MENU_Diff_ShowFiles
        ; this is a shortcut, so check that it only works in the files list
        If DiffDirectoryMode > 0 And GetActiveGadget() = #GADGET_Diff_Files
          ; same action as for the listicon event
          index = GetGadgetState(#GADGET_Diff_Files)
          If index <> -1 And SelectElement(DiffFiles(), index)
            If DiffFiles()\Style = #DIFF_Changed Or DiffFiles()\Style = #DIFF_Equal ; cannot compare against added/removed files
              DiffFileToFile(DiffA_Base$+DiffFiles()\Name$, DiffB_Base$+DiffFiles()\Name$, #False, 1)
            EndIf
          EndIf
        EndIf
        
      Case #MENU_Diff_HideFiles
        If DiffDirectoryMode = 1
          SwitchDirectoryMode(2)
          UpdateDiffToolbar()
        EndIf
        
      Case #MENU_Diff_Up
        ShowNextDifference(GetActiveGadget(), #False, #False)
        
      Case #MENU_Diff_Down
        ShowNextDifference(GetActiveGadget(), #True, #False)
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width  = WindowWidth(#WINDOW_Diff)
    Height = WindowHeight(#WINDOW_Diff)
    If DiffDirectoryMode = 0
      ; only the file splitter
      ResizeGadget(#GADGET_Diff_Splitter, 5, 5+ToolbarTopOffset, Width-10, Height-10-ToolbarHeight)
    Else
      h = Max(GetRequiredHeight(#GADGET_Diff_FileTitle), 30)
      ResizeGadget(#GADGET_Diff_FileTitle, 5,5+ToolbarTopOffset, Width-10, h)
      If DiffDirectoryMode = 1
        ; the directory splitter is the main
        ResizeGadget(#GADGET_Diff_Splitter2, 5, 7+ToolbarTopOffset+h, Width-10, Height-12-ToolbarHeight-h)
      Else
        ; only the directory view
        ResizeGadget(#GADGET_Diff_Files, 5, 7+ToolbarTopOffset+h, Width-10, Height-12-ToolbarHeight-h)
      EndIf
    EndIf
    
    GetRequiredSize(#GADGET_Diff_Busy, @BusyW, @BusyH)
    ResizeGadget(#GADGET_Diff_Busy, (Width-BusyW)/2, ToolbarTopOffset + (Height-ToolBarHeight-BusyH) / 2, BusyW, BusyH)
    
  ElseIf EventID = #PB_Event_CloseWindow
    If MemorizeWindow And IsWindowMinimized(#WINDOW_Diff) = 0
      DiffWindowPosition\IsMaximized = IsWindowMaximized(#WINDOW_Diff)
      If DiffWindowPosition\IsMaximized = 0
        DiffWindowPosition\x = WindowX(#WINDOW_Diff)
        DiffWindowPosition\y = WindowY(#WINDOW_Diff)
        DiffWindowPosition\Width  = WindowWidth (#WINDOW_Diff)
        DiffWindowPosition\Height = WindowHeight(#WINDOW_Diff)
      EndIf
    EndIf
    CloseWindow(#WINDOW_Diff)
    
    
    ; free the no longer needed data
    ;
    If *DiffA_Buffer
      FreeMemory(*DiffA_Buffer)
    EndIf
    
    If *DiffB_Buffer
      FreeMemory(*DiffB_Buffer)
    EndIf
    *DiffA_Buffer = 0
    *DiffB_Buffer = 0
    ClearList(StyleA())
    ClearList(StyleB())
    
  EndIf
  
EndProcedure


ProcedureDLL DiffScintillaCallback(Gadget, *scinotify.SCNotification)
  
  Select *scinotify\nmhdr\code
      
      ; There is no separate (cross-platform) notification on scrolling events,
      ; so use the paint message and check the scrolling position to update the
      ; second gadget
      ;
    Case #SCN_PAINTED
      If Gadget = #GADGET_Diff_File1
        OtherGadget = #GADGET_Diff_File2
      Else
        OtherGadget = #GADGET_Diff_File1
      EndIf
      
      Zoom = ScintillaSendMessage(Gadget, #SCI_GETZOOM)
      If Zoom <> DiffZoom
        DiffZoom = Zoom
        ScintillaSendMessage(OtherGadget, #SCI_SETZOOM, DiffZoom)
      EndIf
      
      X = ScintillaSendMessage(Gadget, #SCI_GETXOFFSET)
      If X <> DiffScrollX
        DiffScrollX = X
        ScintillaSendMessage(OtherGadget, #SCI_SETXOFFSET, DiffScrollX)
      EndIf
      
      ; Note: this counts visible lines, not document lines
      ;   this needs to be adjusted if some kind of folding is allowed
      Y = ScintillaSendMessage(Gadget, #SCI_GETFIRSTVISIBLELINE)
      If Y <> DiffScrollY
        DiffScrollY = Y
        ; #SCI_SETFIRSTVISIBLELINE is not supported in our scintilla version, so emulate it
        ScintillaSendMessage(OtherGadget, #SCI_LINESCROLL, 0, DiffScrollY - ScintillaSendMessage(OtherGadget, #SCI_GETFIRSTVISIBLELINE))
      EndIf
      
  EndSelect
  
EndProcedure


Procedure OpenDiffWindow()
  ;
  ; This is not a DialogManager created Window, because of the toolbar etc
  ;
  
  If IsWindow(#WINDOW_Diff) = 0
    
    Flags = #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_Invisible
    If DiffWindowPosition\x = -1 And DiffWindowPosition\y = -1
      Flags | #PB_Window_ScreenCentered
    EndIf
    
    If OpenWindow(#WINDOW_Diff, DiffWindowPosition\x, DiffWindowPosition\y, DiffWindowPosition\Width, DiffWindowPosition\Height, Language("Diff", "Title"), Flags, WindowID(#WINDOW_Main))
      WindowBounds(#WINDOW_Diff, 200, 200, #PB_Ignore, #PB_Ignore)
      
      CompilerIf #CompileMac
        If OSVersion() >= #PB_OS_MacOSX_10_14
          ; Fix Toolbar style from titlebar to expanded (Top Left)
          #NSWindowToolbarStyleExpanded = 1
          CocoaMessage(0, WindowID(#WINDOW_Diff), "setToolbarStyle:", #NSWindowToolbarStyleExpanded)
        EndIf
      CompilerEndIf
      
      CompilerIf #CompileMac
        flags = #PB_ToolBar_Large
      CompilerElse
        flags = 0
      CompilerEndIf
      
      If CreateToolBar(#TOOLBAR_Diff, WindowID(#WINDOW_Diff), Flags)
        ToolBarImageButton(#MENU_Diff_ShowTool, ImageID(#IMAGE_Diff_ShowTool))
        ToolBarImageButton(#MENU_Diff_Open1, ImageID(#IMAGE_Diff_Open1))
        ToolBarImageButton(#MENU_Diff_Open2, ImageID(#IMAGE_Diff_Open2))
        ToolBarSeparator()
        ToolBarImageButton(#MENU_Diff_Colors,   ImageID(#IMAGE_Diff_Colors), #PB_ToolBar_Toggle)
        ToolBarImageButton(#MENU_Diff_Vertical, ImageID(#IMAGE_Diff_Vertical), #PB_ToolBar_Toggle)
        ToolBarImageButton(#MENU_Diff_HideFiles, ImageID(#IMAGE_Diff_HideFiles))
        ToolBarSeparator()
        ToolBarImageButton(#MENU_Diff_Swap,     ImageID(#IMAGE_Diff_Swap))
        ToolBarImageButton(#MENU_Diff_Refresh,  ImageID(#IMAGE_Diff_Refresh))
        ToolBarSeparator()
        ToolBarImageButton(#MENU_Diff_Up, ImageID(#IMAGE_Diff_Up))
        ToolBarImageButton(#MENU_Diff_Down, ImageID(#IMAGE_Diff_Down))
        
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Open1,   Language("Diff","Open1"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Open2,   Language("Diff","Open2"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Refresh, Language("Diff","Refresh"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Swap,    Language("Diff","Swap"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Colors,  Language("Diff","Colors"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Vertical, Language("Diff","Vertical"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_ShowTool, Language("Diff","ShowTool"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_HideFiles, Language("Diff","HideFiles"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Up, Language("Diff","Up"))
        ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Down, Language("Diff","Down"))
        
        SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Colors, DiffShowColors)
        SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Vertical, DiffVertical)
      EndIf
      
      ; this one has no icon, only a shortcut (enter)
      AddKeyboardShortcut(#WINDOW_Diff, #PB_Shortcut_Return, #MENU_Diff_ShowFiles)
      
      TextGadget(#GADGET_Diff_Busy, 0, 0, 0, 0, Language("Diff","Busy"))
      HideGadget(#GADGET_Diff_Busy, 1)
      
      ; the default state is the File only mode, where there is no gadget for filename and files
      DiffDirectoryMode = 0
      UpdateDiffToolbar()
      
      ; Note: The TextGadget with border looks quite ugly in this context on modern Windows version as it has
      ;   the old style "client edge" border. It looks better without any borders at all here
      ;
      ContainerGadget(#GADGET_Diff_Container1, 0, 0, 0, 0, #PB_Container_BorderLess)
      CompilerIf #CompileWindows
        TextGadget(#GADGET_Diff_Title1, 0, 0, 0, 0, "")
      CompilerElse
        TextGadget(#GADGET_Diff_Title1, 0, 0, 0, 0, "", #PB_Text_Border)
      CompilerEndIf
      ScintillaGadget(#GADGET_Diff_File1, 0, 0, 0, 0, @DiffScintillaCallback())
      CloseGadgetList()
      
      ContainerGadget(#GADGET_Diff_Container2, 0, 0, 0, 0, #PB_Container_BorderLess)
      CompilerIf #CompileWindows
        TextGadget(#GADGET_Diff_Title2, 0, 0, 0, 0, "")
      CompilerElse
        TextGadget(#GADGET_Diff_Title2, 0, 0, 0, 0, "", #PB_Text_Border)
      CompilerEndIf
      ScintillaGadget(#GADGET_Diff_File2, 0, 0, 0, 0, @DiffScintillaCallback())
      CloseGadgetList()
      
      ; this variable is reversed from the splitter flag: vertical splitter = horizontal tiling
      If DiffVertical
        SplitterGadget(#GADGET_Diff_Splitter, 5, 5+ToolbarTopOffset, DiffWindowPosition\Width-10, DiffWindowPosition\Height-10-ToolbarHeight, #GADGET_Diff_Container1, #GADGET_Diff_Container2)
      Else
        SplitterGadget(#GADGET_Diff_Splitter, 5, 5+ToolbarTopOffset, DiffWindowPosition\Width-10, DiffWindowPosition\Height-10-ToolbarHeight, #GADGET_Diff_Container1, #GADGET_Diff_Container2, #PB_Splitter_Vertical)
      EndIf
      SetGadgetAttribute(#GADGET_Diff_Splitter, #PB_Splitter_FirstMinimumSize, 80)
      SetGadgetAttribute(#GADGET_Diff_Splitter, #PB_Splitter_SecondMinimumSize, 80)
      
      DiffScrollX = 0
      DiffScrollY = 0
      DiffZoom = ScintillaSendMessage(#GADGET_Diff_File1, #SCI_GETZOOM)
      
      For Gadget = #GADGET_Diff_File1 To #GADGET_Diff_File2
        ScintillaSendMessage(Gadget, #SCI_CLEARCMDKEY, #SCK_TAB) ; to enable the window shortcuts
        ScintillaSendMessage(Gadget, #SCI_CLEARCMDKEY, #SCK_RETURN)
        ApplyWordChars(Gadget)
        ScintillaSendMessage(Gadget, #SCI_SETCARETLINEVISIBLE, 0, 0)
        
        ; margin for line numbers, this is hidden in UpdateDiffGadget() if it is disabled
        ; we cannot use the normal line numbers as we have gaps where stuff is inserted in another file
        CompilerIf #SCINTILLA_TEXT_MARGIN
          ScintillaSendMessage(Gadget, #SCI_SETMARGINTYPEN, 1, #SC_MARGIN_RTEXT)
          ScintillaSendMessage(Gadget, #SCI_SETMARGINMASKN, 1, 0)
          ScintillaSendMessage(Gadget, #SCI_SETMARGINSENSITIVEN, 1, 0)
        CompilerEndIf
        
        ; margin for the markers
        ScintillaSendMessage(Gadget, #SCI_SETMARGINTYPEN, 2, #SC_MARGIN_SYMBOL)
        ScintillaSendMessage(Gadget, #SCI_SETMARGINMASKN, 2, ~#SC_MASK_FOLDERS)
        ScintillaSendMessage(Gadget, #SCI_SETMARGINSENSITIVEN, 2, 0)
        
        For i = 0 To #DIFF_StateCount-1
          ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, i, #SC_MARK_BACKGROUND)
        Next i
        
        ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #DIFF_StateCount+#DIFF_Empty, #SC_MARK_EMPTY)
        ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #DIFF_StateCount+#DIFF_Equal, #SC_MARK_EMPTY)
        ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #DIFF_StateCount+#DIFF_Added, #SC_MARK_PLUS)
        ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #DIFF_StateCount+#DIFF_Removed, #SC_MARK_MINUS)
        ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #DIFF_StateCount+#DIFF_Changed, #SC_MARK_SHORTARROW)
        
        ; for knowing where the next change starts
        ScintillaSendMessage(Gadget, #SCI_MARKERDEFINE, #DIFF_ChangeMarker, #SC_MARK_EMPTY)
      Next Gadget
      
      EnsureWindowOnDesktop(#WINDOW_Diff)
      If DiffWindowPosition\IsMaximized
        ShowWindowMaximized(#WINDOW_Diff)
      Else
        HideWindow(#WINDOW_Diff, 0)
      EndIf
      DiffWindowEvents(#PB_Event_SizeWindow)
      ResizeDiffSplitterContent()
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_Diff)
    
  EndIf
  
EndProcedure

Procedure DiffHighlightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
  ScintillaSendMessage(DiffStyleGadget, #SCI_SETSTYLING, Length, *Color)
EndProcedure

; Update the coloring in the gadget and optionally set the text
;
Procedure UpdateDiffGadget(IsLeft, List Style.DiffStyleBlock(), SetText)
  
  If IsLeft
    If DiffSwapped = 0
      Gadget = #GADGET_Diff_File1
    Else
      Gadget = #GADGET_Diff_File2
    EndIf
  Else
    If DiffSwapped = 0
      Gadget = #GADGET_Diff_File2
    Else
      Gadget = #GADGET_Diff_File1
    EndIf
  EndIf
  
  ; Gtk2 'Pango' need an "!" before the font name (else it will use GDK font)
  ;
  ScintillaSendMessage(Gadget, #SCI_STYLERESETDEFAULT, 0, 0)
  CompilerIf #CompileLinuxGtk
    FontName$ = "!"+EditorFontName$
    ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, #STYLE_DEFAULT, ToAscii(FontName$))
  CompilerElse
    ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, #STYLE_DEFAULT, ToAscii(EditorFontName$))
  CompilerEndIf
  
  ScintillaSendMessage(Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT,  EditorFontSize)
  
  If EditorFontStyle & #PB_Font_Bold
    ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD, #STYLE_DEFAULT, 1)
  Else
    ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD, #STYLE_DEFAULT, 0)
  EndIf
  If EditorFontStyle & #PB_Font_Italic
    ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, #STYLE_DEFAULT, 1)
  Else
    ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, #STYLE_DEFAULT, 0)
  EndIf
  
  ScintillaSendMessage(Gadget, #SCI_STYLESETEOLFILLED, #STYLE_DEFAULT, #True)
  
  ; background markers
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_Empty,   $C0C0C0)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_Equal,   $FFFFFF)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_Added,   $90EE90)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_Removed, $507FFF)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_Changed, $80FFFF)
  
  ; symbol markers
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_StateCount+#DIFF_Empty,   $C0C0C0)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_StateCount+#DIFF_Equal,   $FFFFFF)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_StateCount+#DIFF_Added,   $90EE90)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_StateCount+#DIFF_Removed, $507FFF)
  ScintillaSendMessage(Gadget, #SCI_MARKERSETBACK, #DIFF_StateCount+#DIFF_Changed, $80FFFF)
  
  If DiffShowColors
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, Colors(#COLOR_GlobalBackground)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLECLEARALL, 0, 0) ; to make the background & font change effective!
    
    If EnableKeywordBolding
      ; Gtk2 'Pango' need an "!" before the font name (else it will use GDK font)
      ;
      CompilerIf #CompileLinuxGtk
        FontName$ = "!"+EditorBoldFontName$
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT,  2, ToAscii(FontName$))
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, 14, ToAscii(FontName$))
      CompilerElse
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT,  2, ToAscii(EditorBoldFontName$))
        ScintillaSendMessage(Gadget, #SCI_STYLESETFONT, 14, ToAscii(EditorBoldFontName$))
      CompilerEndIf
      
      ScintillaSendMessage(Gadget, #SCI_STYLESETSIZE, #STYLE_DEFAULT, EditorFontSize)
      ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD,  2, 1)             ; Bold (no effect on linux, but maybe on windows later)
      ScintillaSendMessage(Gadget, #SCI_STYLESETBOLD,  14, 1)
      If EditorFontStyle & #PB_Font_Italic
        ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, 2, 1)
        ScintillaSendMessage(Gadget, #SCI_STYLESETITALIC, 14, 1)
      EndIf
    EndIf
    
    For i = 0 To #DIFF_StateCount-1
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #DIFF_StateCount+i, Colors(#COLOR_NormalText)\DisplayValue)
    Next i
    
    ; applies to all margins
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_LINENUMBER, Colors(#COLOR_LineNumber)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_LINENUMBER, Colors(#COLOR_LineNumberBack)\DisplayValue)
    
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  1, Colors(#COLOR_NormalText)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  2, Colors(#COLOR_BasicKeyword)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  3, Colors(#COLOR_Comment)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  4, Colors(#COLOR_Constant)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  5, Colors(#COLOR_String)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  6, Colors(#COLOR_PureKeyword)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  7, Colors(#COLOR_ASMKeyword)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  8, Colors(#COLOR_Operator)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE,  9, Colors(#COLOR_Structure)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 10, Colors(#COLOR_Number)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 11, Colors(#COLOR_Pointer)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 12, Colors(#COLOR_Separator)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 13, Colors(#COLOR_Label)\DisplayValue)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, 14, Colors(#COLOR_CustomKeyword)\DisplayValue)
    
    CompilerIf #CompileWindows
      If Colors(#COLOR_Selection)\DisplayValue = -1 Or EnableAccessibility; special accessibility scheme
        ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, GetSysColor_(#COLOR_HIGHLIGHT))
      Else
        ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, Colors(#COLOR_Selection)\DisplayValue)
      EndIf
      
      If Colors(#COLOR_SelectionFront)\DisplayValue = -1 Or EnableAccessibility
        ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
      Else
        ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, Colors(#COLOR_SelectionFront)\DisplayValue)
      EndIf
    CompilerElse
      ScintillaSendMessage(Gadget, #SCI_SETSELBACK,    1, Colors(#COLOR_Selection)\DisplayValue)
      ScintillaSendMessage(Gadget, #SCI_SETSELFORE,    1, Colors(#COLOR_SelectionFront)\DisplayValue)
    CompilerEndIf
    
    ScintillaSendMessage(Gadget, #SCI_SETCARETFORE,     Colors(#COLOR_Cursor)\DisplayValue, 0)
    
  Else
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_DEFAULT, $FFFFFF)
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_DEFAULT, $000000)
    ScintillaSendMessage(Gadget, #SCI_STYLECLEARALL, 0, 0) ; to make the background & font change effective!
    
    For i = 0 To #DIFF_StateCount-1
      ScintillaSendMessage(Gadget, #SCI_MARKERSETFORE, #DIFF_StateCount+i, $000000)
    Next i
    
    ScintillaSendMessage(Gadget, #SCI_STYLESETFORE, #STYLE_LINENUMBER, $000000)
    ScintillaSendMessage(Gadget, #SCI_STYLESETBACK, #STYLE_LINENUMBER, $FFFFFF)
    
    CompilerIf #CompileWindows
      ScintillaSendMessage(Gadget, #SCI_SETSELBACK, 1, GetSysColor_(#COLOR_HIGHLIGHT))
      ScintillaSendMessage(Gadget, #SCI_SETSELFORE, 1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
    CompilerElse
      ScintillaSendMessage(Gadget, #SCI_SETSELBACK, 1, $C0C0C0)
      ScintillaSendMessage(Gadget, #SCI_SETSELFORE, 1, $000000)
    CompilerEndIf
    
    ScintillaSendMessage(Gadget, #SCI_SETCARETFORE,  $000000)
  EndIf
  
  ScintillaSendMessage(Gadget, #SCI_SETTABWIDTH, TabLength)
  ScintillaSendMessage(Gadget, #SCI_SETUSETABS, RealTab)
  
  ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 2, ScintillaSendMessage(Gadget, #SCI_TEXTHEIGHT, 1, 0))
  
  CompilerIf #SCINTILLA_TEXT_MARGIN
    Lines = Max(Max(DiffA_Lines, DiffB_Lines), 10) ; use the same margin width on both files
    Lines$ = "_" + RSet("9", Len(Str(Lines)), "9")
    ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 1, ScintillaSendMessage(Gadget, #SCI_TEXTWIDTH, #STYLE_LINENUMBER, ToAscii(Lines$)))
  CompilerElse
    ; hide this margin
    ScintillaSendMessage(Gadget, #SCI_SETMARGINWIDTHN, 1, 0)
  CompilerEndIf
  
  ; We need to build the full buffer for the coloring update and to set the text
  ;
  Length = 1 ; for null byte
  ForEach Style()
    Length + Style()\Length
  Next Style()
  
  If SetText
    ScintillaSendMessage(Gadget, #SCI_SETREADONLY, 0) ; so it can be modified now
  EndIf
  
  *Buffer = AllocateMemory(Length)
  If *Buffer
    
    *Pointer = *Buffer
    ForEach Style()
      If Style()\Start = #Null ; indicates that we need to add empty lines
        For i = 1 To Style()\Length / #NewLineLength
          PokeAscii(*Pointer, #NewLine)
          *Pointer + #NewLineLength
        Next i
      Else
        CopyMemory(Style()\Start, *Pointer, Style()\Length)
        *Pointer + Style()\Length
      EndIf
    Next Style()
    
    If SetText
      ; adjust the utf8 mode as well (in case a swap took place)
      ;
      If IsLeft
        Utf8 = DiffA_Utf8
      Else
        Utf8 = DiffB_Utf8
      EndIf
      
      If Utf8
        ScintillaSendMessage(Gadget, #SCI_SETCODEPAGE, #SC_CP_UTF8)
      Else
        ScintillaSendMessage(Gadget, #SCI_SETCODEPAGE, 0)
      EndIf
      
      ; set the new text
      ScintillaSendMessage(Gadget, #SCI_SETTEXT, 0, *Buffer)
      
      ; the line numbers also only need updating when the text changed
      CompilerIf #SCINTILLA_TEXT_MARGIN
        ScintillaSendMessage(Gadget, #SCI_MARGINTEXTCLEARALL)
      CompilerEndIf
      
      ; apply the markers for the diff background (only needed on text changes)
      ; also apply the line number text (if supported)
      ;
      ScintillaSendMessage(Gadget, #SCI_MARKERDELETEALL, -1)
      Line = 0
      DisplayLine = 1
      PreviousStyle = #DIFF_Equal
      ForEach Style()
        ; mark the beginning of each change block
        ; note: a block with #DIFF_Empty is not a new change when it immediately follows a block of #DIFF_Changed
        ;       because then it is just an extension of that block to match the length in the other file
        ;
        If Style()\Style <> #DIFF_Equal And (Not (Style()\Style = #DIFF_Empty And PreviousStyle = #DIFF_Changed))
          ScintillaSendMessage(Gadget, #SCI_MARKERADD, Line, #DIFF_ChangeMarker)
        EndIf
        
        If DiffSwapped And Style()\Style = #DIFF_Added
          Style = #DIFF_Removed
        ElseIf DiffSwapped And Style()\Style = #DIFF_Removed
          Style = #DIFF_Added
        Else
          Style = Style()\Style
        EndIf
        
        For i = 1 To Style()\Lines
          If Style <> #DIFF_Equal ; keep normal background for equal parts
                                  ; the swapped display is exactly the same as the normal one, only
                                  ; insers and deletes are reversed, so we can do a swap without changing the underlying data
            ScintillaSendMessage(Gadget, #SCI_MARKERADD, Line, Style) ; background
            ScintillaSendMessage(Gadget, #SCI_MARKERADD, Line, #DIFF_StateCount+Style) ; symbol
          EndIf
          
          CompilerIf #SCINTILLA_TEXT_MARGIN
            If Style <> #DIFF_Empty
              Text$ = Str(DisplayLine)
              ScintillaSendMessage(Gadget, #SCI_MARGINSETTEXT, Line, ToAscii(Text$))
              ScintillaSendMessage(Gadget, #SCI_MARGINSETSTYLE, Line, #STYLE_LINENUMBER)
              DisplayLine + 1
            EndIf
          CompilerEndIf
          
          Line + 1
        Next i
        
        PreviousStyle = Style()\Style
      Next Style()
    EndIf
    
    ; apply the styling
    ;
    DiffStyleGadget = Gadget
    ScintillaSendMessage(Gadget, #SCI_STARTSTYLING, 0, $1F)
    If DiffShowColors
      HighlightingEngine(*Buffer, Length-1, 0, @DiffHighlightCallback(), 0)
    Else
      ; no highlighting engine used here. just set the text color for everything
      ScintillaSendMessage(Gadget, #SCI_SETSTYLING, Length-1, 1)
    EndIf
    
    
    FreeMemory(*Buffer)
  EndIf
  
  
  If SetText
    ScintillaSendMessage(Gadget, #SCI_SETREADONLY, 1)
  EndIf
EndProcedure

Procedure UpdateDiffWindow()
  
  SetWindowTitle(#WINDOW_Diff, Language("Diff", "Title"))
  SetGadgetText(#GADGET_Diff_Busy, Language("Diff", "Busy"))
  
  ; Update the coloring in the gadgets
  If DiffDirectoryMode < 2
    UpdateDiffGadget(#True, StyleA(), #False)
    UpdateDiffGadget(#False, StyleB(), #False)
  EndIf
  
  ; re-create the toolbar to apply theme changes
  FreeToolBar(#TOOLBAR_Diff)
  
  CompilerIf #CompileMac
    flags = #PB_ToolBar_Large
  CompilerElse
    flags = 0
  CompilerEndIf
  
  If CreateToolBar(#TOOLBAR_Diff, WindowID(#WINDOW_Diff), flags)
    ToolBarImageButton(#MENU_Diff_ShowTool, ImageID(#IMAGE_Diff_ShowTool))
    ToolBarImageButton(#MENU_Diff_Open1, ImageID(#IMAGE_Diff_Open1))
    ToolBarImageButton(#MENU_Diff_Open2, ImageID(#IMAGE_Diff_Open2))
    ToolBarSeparator()
    ToolBarImageButton(#MENU_Diff_Colors,   ImageID(#IMAGE_Diff_Colors), #PB_ToolBar_Toggle)
    ToolBarImageButton(#MENU_Diff_Vertical, ImageID(#IMAGE_Diff_Vertical), #PB_ToolBar_Toggle)
    ToolBarImageButton(#MENU_Diff_HideFiles, ImageID(#IMAGE_Diff_HideFiles))
    ToolBarSeparator()
    ToolBarImageButton(#MENU_Diff_Swap,     ImageID(#IMAGE_Diff_Swap))
    ToolBarImageButton(#MENU_Diff_Refresh,  ImageID(#IMAGE_Diff_Refresh))
    ToolBarSeparator()
    ToolBarImageButton(#MENU_Diff_Up, ImageID(#IMAGE_Diff_Up))
    ToolBarImageButton(#MENU_Diff_Down, ImageID(#IMAGE_Diff_Down))
    
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Open1,   Language("Diff","Open1"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Open2,   Language("Diff","Open2"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Refresh, Language("Diff","Refresh"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Swap,    Language("Diff","Swap"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Colors,  Language("Diff","Colors"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Vertical, Language("Diff","Vertical"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_ShowTool, Language("Diff","ShowTool"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_HideFiles, Language("Diff","HideFiles"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Up, Language("Diff","Up"))
    ToolBarToolTip(#TOOLBAR_Diff, #MENU_Diff_Down, Language("Diff","Down"))
    
    SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Colors, DiffShowColors)
    SetToolBarButtonState(#TOOLBAR_Diff, #MENU_Diff_Vertical, DiffVertical)
  EndIf
  
  ; re-populate the file diff list to update language and theme
  If DiffDirectoryMode > 0
    UpdateDiffFileList()
  EndIf
  
  ; update the toolbar disabled states
  UpdateDiffToolbar()
EndProcedure


Procedure AddStyleBlock(List Style.DiffStyleBlock(), *Start, Length, Lines, Style)
  AddElement(Style())
  Style()\Start  = *Start
  Style()\Length = Length
  Style()\Style  = Style
  Style()\Lines  = Lines
EndProcedure

Procedure AddEmptyStyleBlock(List Style.DiffStyleBlock(), Lines)
  AddElement(Style())
  Style()\Start  = #Null ; indicates that this is an empty block
  Style()\Length = Lines * #NewLineLength
  Style()\Style  = #DIFF_Empty
  Style()\Lines  = Lines
EndProcedure


Procedure PerformDiff()
  ClearList(StyleA())
  ClearList(StyleB())
  
  ; Show the busy line
  ;
  ShowDiffProgress(#True)
  FlushEvents()
  
  DiffFlags = 0
  If DiffIgnoreCase
    DiffFlags | #DIFF_IgnoreCase
  EndIf
  If DiffIgnoreSpaceAll
    DiffFlags | #DIFF_IgnoreSpaceAll
  EndIf
  If DiffIgnoreSpaceLeft
    DiffFlags | #DIFF_IgnoreSpaceLeft
  EndIf
  If DiffIgnoreSpaceRight
    DiffFlags | #DIFF_IgnoreSpaceRight
  EndIf
  
  Ctx.DiffContext
  Diff(@Ctx, *DiffA_Start, DiffA_Size, *DiffB_Start, DiffB_Size, DiffFlags)
  DiffA_Lines = Ctx\LineCountA
  DiffB_Lines = Ctx\LineCountB
  
  ; Handle the special cases where one or both files are empty/not loadable
  ;
  If DiffA_Lines = 0 And DiffB_Lines = 0
    AddEmptyStyleBlock(StyleA(), 1)
    AddEmptyStyleBlock(StyleB(), 1)
    
  Else
  
    ResetList(Ctx\Edits())
  
    While NextElement(Ctx\Edits())
    
      If Ctx\Edits()\Op = #DIFF_Match
        AddStyleBlock(StyleA(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Equal)
        AddStyleBlock(StyleB(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Equal)
        
      Else
    
        ; Combine Insert+Delete or Delete+Insert into a single "Change" block
        Op = Ctx\Edits()\Op
        NextOp = -1
        PushListPosition(Ctx\Edits())
          If NextElement(Ctx\Edits())
            NextOp = Ctx\Edits()\Op
          EndIf
        PopListPosition(Ctx\Edits())
        
        If Op = #DIFF_Delete And NextOp = #DIFF_Insert
          LinesA = Ctx\Edits()\Lines
          AddStyleBlock(StyleA(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Changed)
          NextElement(Ctx\Edits())
          LinesB = Ctx\Edits()\Lines
          AddStyleBlock(StyleB(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Changed)
          If LinesA < LinesB
            AddEmptyStyleBlock(StyleA(), LinesB-LinesA)
          ElseIf LinesB < LinesA
            AddEmptyStyleBlock(StyleB(), LinesA-LinesB)
          EndIf
        
        ElseIf Op = #DIFF_Insert And NextOp = #DIFF_Delete
          LinesB = Ctx\Edits()\Lines
          AddStyleBlock(StyleB(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Changed)
          NextElement(Ctx\Edits())
          LinesA = Ctx\Edits()\Lines
          AddStyleBlock(StyleA(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Changed)
          If LinesA < LinesB
            AddEmptyStyleBlock(StyleA(), LinesB-LinesA)
          ElseIf LinesB < LinesA
            AddEmptyStyleBlock(StyleB(), LinesA-LinesB)
          EndIf
        
        ElseIf Op = #DIFF_Delete
          AddStyleBlock(StyleA(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Removed)
          AddEmptyStyleBlock(StyleB(), Ctx\Edits()\Lines)
          
        Else ; must be an insert
          AddEmptyStyleBlock(StyleA(), Ctx\Edits()\Lines)
          AddStyleBlock(StyleB(), Ctx\Edits()\Start, Ctx\Edits()\Length, Ctx\Edits()\Lines, #DIFF_Added)
          
        EndIf
        
      EndIf
    Wend
    
  EndIf
  
  If DiffSwapped
    SetGadgetText(#GADGET_Diff_Title1, DiffB_Title$)
    SetGadgetText(#GADGET_Diff_Title2, DiffA_Title$)
  Else
    SetGadgetText(#GADGET_Diff_Title1, DiffA_Title$)
    SetGadgetText(#GADGET_Diff_Title2, DiffB_Title$)
  EndIf
  
  UpdateDiffGadget(#True, StyleA(), #True) ; set the text as well
  UpdateDiffGadget(#False, StyleB(), #True)
  
  ShowDiffProgress(#False)
  UpdateDiffToolbar()
  
  ; mark first difference
  ShowNextDifference(#GADGET_Diff_File1, #True, #True)
  
EndProcedure


; Set the left or right diff buffer.
;  *Buffer must be AllocateMemory() buffer and will belong to the Diff window then
;  *Buffer can be 0 if Length is 0
;
Procedure SetDiffBuffer(IsLeft, *Buffer, Length, Title$, IsUTF8)
  
  ; null buffer and length are accepted here
  If *Buffer = 0
    Length = 0
  EndIf
  
  ; check for an utf8 bom. UTF8-mode is determined in two ways:
  ;  - with the IsUTF8 parameter (for ScintillaGadget source)
  ;  - with a BOM in the data (for file source)
  ;
  *OriginalBuffer = Buffer
  If Length >= 3 And PeekA(*Buffer) = $EF And PeekA(*Buffer+1) = $BB And PeekA(*Buffer+2) = $BF
    IsUTF8 = 1
    *Buffer + 3
    Length - 3
  EndIf
  
  ; do the actual scan for the correct side
  If IsLeft
    If *DiffA_Buffer
      FreeMemory(*DiffA_Buffer)  ; free previous buffer (if any)
    EndIf
    DiffA_Utf8    = IsUTF8
    DiffA_Size    = Length
    *DiffA_Buffer = *OriginalBuffer
    *DiffA_Start  = *Buffer
    DiffA_Title$  = Title$
  Else
    If *DiffB_Buffer
      FreeMemory(*DiffB_Buffer)
    EndIf
    DiffB_Utf8    = IsUTF8
    DiffB_Size    = Length
    *DiffB_Buffer = *OriginalBuffer
    *DiffB_Start  = *Buffer
    DiffB_Title$  = Title$
  EndIf
  
  ProcedureReturn #True
EndProcedure


Procedure DiffFileToFile(File1$, File2$, SwapOutput = #False, DirectoryMode = 0)
  Abort = #False
  
  If DirectoryMode > 1 ; only 0 and 1 show files
    DirectoryMode = 0
  EndIf
  
  ; Sanity check for file size
  ;
  SizeMB.f = FileSize(File1$)/(1024*1024)
  If SizeMB > 3 ; since this is about text files, warn from 2mb on
    If MessageRequester(#ProductName$,Language("FileViewer","SizeWarning")+" ("+StrF(SizeMB, 1)+" Mb)"+#NewLine+Language("FileViewer","SizeQuestion")+#NewLine+#NewLine+File1$, #FLAG_Warning|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
      ProcedureReturn #False
    EndIf
  EndIf
  
  ; ask for the second file only if we did not ask for the first one.
  ; we assume that if the user loads one big file, that the other is big as well (as it is compared to the big one)
  ; no need to be bothered with 2 questions
  If SizeMB < 3
    SizeMB.f = FileSize(File2$)/(1024*1024)
    If SizeMB > 3
      If MessageRequester(#ProductName$,Language("FileViewer","SizeWarning")+" ("+StrF(SizeMB, 1)+" Mb)"+#NewLine+Language("FileViewer","SizeQuestion")+#NewLine+#NewLine+File2$, #FLAG_Warning|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
        ProcedureReturn #False
      EndIf
    EndIf
  EndIf
  
  If ReadFile(#FILE_Diff, File1$)
    Length1 = Lof(#FILE_Diff)
    If Length1 = 0
      *Buffer1 = #Null
    Else
      *Buffer1 = AllocateMemory(Length1)
      If *Buffer1
        Length1 = ReadData(#FILE_Diff, *Buffer1, Length1)
      EndIf
    EndIf
    CloseFile(#FILE_Diff)
  Else
    MessageRequester(#ProductName$, LanguagePattern("Diff","FileError", "%file%", File1$))
    Abort = #True
  EndIf
  
  If *Buffer1 And IsBinaryFile(*Buffer1, Length1)
    MessageRequester(#ProductName$, LanguagePattern("Diff","FileBinary", "%file%", File1$))
    Abort = #True
  EndIf
  
  If Abort = #False ; only read the second file if the first is ok
    If ReadFile(#FILE_Diff, File2$)
      Length2 = Lof(#FILE_Diff)
      If Length2 = 0
        *Buffer2 = #Null
      Else
        *Buffer2 = AllocateMemory(Length2)
        If *Buffer2
          Length2 = ReadData(#FILE_Diff, *Buffer2, Length2)
        EndIf
      EndIf
      CloseFile(#FILE_Diff)
    Else
      MessageRequester(#ProductName$, LanguagePattern("Diff","FileError", "%file%", File2$))
      Abort = #True
    EndIf
  EndIf
  
  ; avoid multiple messages on multiple errors
  If Abort = #False And *Buffer2 And IsBinaryFile(*Buffer2, Length2)
    MessageRequester(#ProductName$, LanguagePattern("Diff","FileBinary", "%file%", File2$))
    Abort = #True
  EndIf
  
  If Abort
    If *Buffer1: FreeMemory(*Buffer1): EndIf
    If *Buffer2: FreeMemory(*Buffer2): EndIf
    ProcedureReturn #False
    
  Else
    ; reset the options
    DiffSwapped = SwapOutput
    DiffMode = #DIFF_FileToFile
    DiffA_File$ = File1$
    DiffB_File$ = File2$
    
    ; The buffer belongs to the diff window after these calls
    ;
    SetDiffBuffer(#True, *Buffer1, Length1, File1$, #False)
    SetDiffBuffer(#False, *Buffer2, Length2, File2$, #False)
    OpenDiffWindow()
    SwitchDirectoryMode(DirectoryMode)
    PerformDiff()
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure DiffSourceToFile(*Source.SourceFile, Filename$, SwapOutput = #False)
  
  ; Sanity check for file size
  ;
  SizeMB.f = FileSize(Filename$)/(1024*1024)
  If SizeMB > 2 ; since this is about text files, warn from 2mb on
    If MessageRequester(#ProductName$,Language("FileViewer","SizeWarning")+" ("+StrF(SizeMB, 1)+" Mb)"+#NewLine+Language("FileViewer","SizeQuestion")+#NewLine+#NewLine+Filename$, #FLAG_Warning|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
      ProcedureReturn
    EndIf
  EndIf
  
  ; try the file first to check for errors
  ;
  If ReadFile(#FILE_Diff, Filename$)
    Length2 = Lof(#FILE_Diff)
    If Length2 = 0
      *Buffer2 = #Null
    Else
      *Buffer2 = AllocateMemory(Length2)
      If *Buffer2
        Length2 = ReadData(#FILE_Diff, *Buffer2, Length2)
      EndIf
    EndIf
    CloseFile(#FILE_Diff)
  Else
    MessageRequester(#ProductName$, LanguagePattern("Diff","FileError", "%file%", Filename$))
    ProcedureReturn
  EndIf
  
  If *Buffer2 And IsBinaryFile(*Buffer2, Length2)
    MessageRequester(#ProductName$, LanguagePattern("Diff","FileBinary", "%file%", Filename$))
    FreeMemory(*Buffer2)
    ProcedureReturn
  EndIf
  
  ; Errors in loading the file from the scintilla are ignored.
  ; If there is an error here, we have a serious memory problem anyway.
  ;
  IsUTF8 = #False
  
  If *Source And *Source\IsProject = 0 And *Source\EditorGadget
    If *Source\Parser\Encoding <> 0
      IsUTF8 = #True
    EndIf
    Length1 = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLENGTH)
    *Buffer1 = AllocateMemory(Length1+1) ; null space needed by scintilla
    If *Buffer1
      ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXT, Length1, *Buffer1)
    EndIf
    
    If *Source\FileName$ = ""
      Title$ = Language("FileStuff","NewSource")
    Else
      Title$ = *Source\FileName$
    EndIf
    Title$ + "  (" + Language("Diff","CurrentEdit") + ")"
  Else
    Length1 = 0
    *Buffer1 = #Null
    Title$ = ""
  EndIf
  
  DiffSwapped = SwapOutput
  DiffMode = #DIFF_SourceToFile
  *DiffSource = *Source
  DiffB_File$ = Filename$
  
  SetDiffBuffer(#True, *Buffer1, Length1, Title$, IsUTF8) ; pass the scintilla utf8 mode
  SetDiffBuffer(#False, *Buffer2, Length2, Filename$, #False)
  OpenDiffWindow()
  SwitchDirectoryMode(0) ; files only mode
  PerformDiff()
EndProcedure


Procedure CheckDiffFileClose(*Source.SourceFile)
  ; When the source that was part of the diff is closed, close the diff window
  ; too because we loose the source for our data then
  ;
  If DiffMode = #DIFF_SourceToFile And *Source = *DiffSource
    DiffWindowEvents(#PB_Event_CloseWindow)
  EndIf
EndProcedure

Procedure ExamineDiffDirectory(Base$, Subdirectory$, List Output.s())
  
  ; first, scan subdirectories if needed
  ;
  If DiffRecurse
    ID = ExamineDirectory(#PB_Any, Base$+Subdirectory$, "*")
    If ID
      While NextDirectoryEntry(ID)
        If DirectoryEntryType(ID) = #PB_DirectoryEntry_Directory
          Name$ = DirectoryEntryName(ID)
          If Name$ <> "." And Name$ <> ".."
            ExamineDiffDirectory(Base$, Subdirectory$+Name$+#Separator, Output())
          EndIf
        EndIf
      Wend
      FinishDirectory(ID)
    EndIf
  EndIf
  
  ; now scan files. PatternList$ may be a list of patterns separated by ","
  ; this produces double entries, which we will later remove
  ;
  Index = 1
  Repeat
    Pattern$ = Trim(StringField(DiffPattern$, Index, ","))
    If Pattern$
      ID = ExamineDirectory(#PB_Any, Base$+Subdirectory$, Pattern$)
      If ID
        While NextDirectoryEntry(ID)
          If DirectoryEntryType(ID) = #PB_DirectoryEntry_File
            AddElement(Output())
            Output() = Subdirectory$+DirectoryEntryName(ID) ; do not include base in this list
          EndIf
        Wend
        FinishDirectory(ID)
      EndIf
    EndIf
    
    Index + 1
  Until Pattern$ = "" Or Pattern$ = "*" Or Pattern$ = "*.*" ; we also abort on these patterns, as then all files are scanned
  
EndProcedure

Procedure UpdateDiffFileList()
  ClearGadgetItems(#GADGET_Diff_Files)
  
  ForEach DiffFiles()
    Style = DiffFiles()\Style   ; swap styles if files get swapped
    If DiffSwapped
      If Style = #DIFF_Added
        Style = #DIFF_Removed
      ElseIf Style = #DIFF_Removed
        Style = #DIFF_Added
      EndIf
      
      DateA = DiffFiles()\DateB
      DateB = DiffFiles()\DateA
    Else
      DateA = DiffFiles()\DateA
      DateB = DiffFiles()\DateB
    EndIf
    
    Select Style
      Case #DIFF_Equal
        State$ = Language("Diff","FileEqual")
        Image  = #IMAGE_Diff_Equal
        Color  = -1
        
      Case #DIFF_Added
        State$ = Language("Diff","FileAdd")
        Image  = #IMAGE_Diff_Add
        Color  = $90EE90
        
      Case #DIFF_Removed
        State$ = Language("Diff","FileDelete")
        Image  = #IMAGE_Diff_Delete
        Color  = $507FFF
        
      Case #DIFF_Changed
        State$ = Language("Diff","FileModify")
        Image  = #IMAGE_Diff_Modify
        Color  = $80FFFF
        
    EndSelect
    
    If IsImage(Image) ; can be missing in the theme (its not in the classic theme for example)
      ImageID = ImageID(Image)
    Else
      ImageID = 0
    EndIf
    
    Line$ = DiffFiles()\Name$ + Chr(10) + State$
    
    If DateA
      Line$ + Chr(10) + FormatDate(Language("Diff","DateFormat"), DateA)
    Else
      Line$ + Chr(10)
    EndIf
    
    If DateB
      Line$ + Chr(10) + FormatDate(Language("Diff","DateFormat"), DateB)
    Else
      Line$ + Chr(10)
    EndIf
    
    AddGadgetItem(#GADGET_Diff_Files, ListIndex(DiffFiles()), Line$, ImageID)
    
    If Color <> -1
      SetGadgetItemColor(#GADGET_Diff_Files, ListIndex(DiffFiles()), #PB_Gadget_BackColor, Color, -1)
      CompilerIf #CompileMac
        ; Fix text color for darkmode
        SetGadgetItemColor(#GADGET_Diff_Files, ListIndex(DiffFiles()), #PB_Gadget_FrontColor, 0, -1)
      CompilerEndIf
    EndIf
    
  Next DiffFiles()
  
  If DiffSwapped
    Text$ = Language("Diff","Directory1")+": "+DiffB_Base$+#NewLine+Language("Diff","Directory2")+": "+DiffA_Base$
  Else
    Text$ = Language("Diff","Directory1")+": "+DiffA_Base$+#NewLine+Language("Diff","Directory2")+": "+DiffB_Base$
  EndIf
  SetGadgetText(#GADGET_Diff_FileTitle, Text$)
  
  ; update toolbar state, as we killed the selection
  UpdateDiffToolbar()
  DiffWindowEvents(#PB_Event_SizeWindow)
  
  ; mark the first difference
  ShowNextDifference(#GADGET_Diff_Files, #True, #True)
EndProcedure

Procedure DiffDirectories(Directory1$, Directory2$, Pattern$, SwapOutput = #False, DirectoryMode = 2)
  NewList FilesA.s()
  NewList FilesB.s()
  
  If DirectoryMode < 1 ; only 1 and 2 show the directories
    DirectoryMode = 1
  EndIf
  
  DiffSwapped = SwapOutput
  DiffA_Base$ = Directory1$
  DiffB_Base$ = Directory2$
  DiffPattern$ = Pattern$
  
  If Trim(DiffPattern$) = ""
    DiffPattern$ = "*"
  EndIf
  
  ; first, examine the two directories to get a list of files
  ExamineDiffDirectory(DiffA_Base$, "", FilesA())
  ExamineDiffDirectory(DiffB_Base$, "", FilesB())
  
  ; eliminate duplicates in each list
  SortList(FilesA(), #PB_Sort_Ascending)
  Last$ = ""
  ForEach FilesA()
    If Last$ = FilesA() ; can use simple compare, as the case should match for the same files because we just got it above
      DeleteElement(FilesA())
    Else
      Last$ = FilesA()
    EndIf
  Next FilesA()
  
  SortList(FilesB(), #PB_Sort_Ascending)
  Last$ = ""
  ForEach FilesB()
    If Last$ = FilesB()
      DeleteElement(FilesB())
    Else
      Last$ = FilesB()
    EndIf
  Next FilesB()
  
  ; open output window
  OpenDiffWindow()
  SwitchDirectoryMode(DirectoryMode)
  ShowDiffProgress(#True)
  FlushEvents()
  
  ClearList(DiffFiles())
  
  ; look at files in A and compare to list B
  ForEach FilesA()
    AddElement(DiffFiles())
    DiffFiles()\Name$ = FilesA()
    DiffFiles()\DateA = GetFileDate(DiffA_Base$+FilesA(), #PB_Date_Modified)
    
    found = 0
    ForEach FilesB()
      If IsEqualFile(FilesA(), FilesB()) ; here we need a full check, as case may differ
        found = 1
        Break
      EndIf
    Next FilesB()
    
    If found = 0
      ; file is only in A
      DiffFiles()\DateB  = 0
      DiffFiles()\Style  = #DIFF_Removed
      
    Else
      ; file found in both, need to compare
      DiffFiles()\DateB  = GetFileDate(DiffB_Base$+FilesB(), #PB_Date_Modified)
      
      ; check the size first before doing the fingerprinting
      If FileSize(DiffA_Base$+FilesA()) <> FileSize(DiffB_Base$+FilesB())
        DiffFiles()\Style = #DIFF_Changed
      ElseIf FileFingerprint(DiffA_Base$+FilesA(), #PB_Cipher_MD5) <> FileFingerprint(DiffB_Base$+FilesB(), #PB_Cipher_MD5)
        DiffFiles()\Style = #DIFF_Changed
      Else
        DiffFiles()\Style = #DIFF_Equal
      EndIf
      
      DeleteElement(FilesB()) ; remove all files that exist in both
    EndIf
  Next FilesA()
  
  ; now everything left in FilesB() is not in FilesA()
  ForEach FilesB()
    AddElement(DiffFiles())
    DiffFiles()\Name$ = FilesB()
    DiffFiles()\DateA = 0
    DiffFiles()\DateB = GetFileDate(DiffB_Base$+FilesB(), #PB_Date_Modified)
    DiffFiles()\Style = #DIFF_Added
  Next FilesB()
  
  ; sort the output by directory name (with subdirectories)
  ; this is not the most efficient sort, but it does the job
  ;
  If FirstElement(DiffFiles())
    Repeat
      *Current.DiffFile  = @DiffFiles()
      *Smallest.DiffFile = @DiffFiles()
      While NextElement(DiffFiles())
        If CompareDirectories(DiffFiles()\Name$, *Smallest\Name$) = #PB_String_Lower
          *Smallest = @DiffFiles()
        EndIf
      Wend
      
      If *Current <> *Smallest
        SwapElements(DiffFiles(), *Current, *Smallest)
        ChangeCurrentElement(DiffFiles(), *Smallest)
      Else
        ChangeCurrentElement(DiffFiles(), *Current)
      EndIf
    Until NextElement(DiffFiles()) = 0 ; end of the list
  EndIf
  
  ; fill the output gadget
  UpdateDiffFileList()
  
  ; done
  ShowDiffProgress(#False)
  
  SetActiveGadget(#GADGET_Diff_Files)
  
  ProcedureReturn #True
EndProcedure


;- Diff dialog

Procedure DiffDialogWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
      
    Case #PB_Event_CloseWindow
      Quit = 1
      
    Case #PB_Event_GadgetDrop
      If GadgetID = #GADGET_DiffDialog_File1 Or GadgetID = #GADGET_DiffDialog_File2
        SetGadgetText(#GADGET_Grep_Directory, StringField(EventDropFiles(), 1, Chr(10)))
        
      ElseIf GadgetID = #GADGET_DiffDialog_Directory1 Or GadgetID = #GADGET_DiffDialog_Directory2
        Path$ = StringField(EventDropFiles(), 1, Chr(10))
        If FileSize(Path$) <> -2 ; probably a file then
          Path$ = GetPathPart(Path$)
        EndIf
        SetGadgetText(#GADGET_Grep_Directory, Path$)
        
      EndIf
      
    Case #PB_Event_Gadget
      Select GadgetID
          
        Case #GADGET_DiffDialog_ChooseFile1, #GADGET_DiffDialog_ChooseFile2
          If GadgetID = #GADGET_DiffDialog_ChooseFile1
            Gadget = #GADGET_DiffDialog_File1
          Else
            Gadget = #GADGET_DiffDialog_File2
          EndIf
          
          Filename$ = OpenFileRequester(Language("FileStuff","OpenFileTitle"), GetGadgetText(Gadget), Language("FileStuff","Pattern"), DiffOpenPattern)
          If Filename$
            DiffOpenPattern = SelectedFilePattern()
            SetGadgetText(Gadget, Filename$)
          EndIf
          
        Case #GADGET_DiffDialog_ChooseDirectory1, #GADGET_DiffDialog_ChooseDirectory2
          If GadgetID = #GADGET_DiffDialog_ChooseDirectory1
            Gadget = #GADGET_DiffDialog_Directory1
          Else
            Gadget = #GADGET_DiffDialog_Directory2
          EndIf
          
          Directory$ = PathRequester("", GetGadgetText(Gadget))
          If Directory$
            SetGadgetText(Gadget, Directory$)
          EndIf
          
          
        Case #GADGET_DiffDialog_CurrentDirectory1, #GADGET_DiffDialog_CurrentDirectory2
          If GadgetID = #GADGET_DiffDialog_CurrentDirectory1
            Gadget = #GADGET_DiffDialog_Directory1
          Else
            Gadget = #GADGET_DiffDialog_Directory2
          EndIf
          
          If *ActiveSource = *ProjectInfo
            Directory$ = GetPathPart(ProjectFile$)
          ElseIf *ActiveSource And *ActiveSource\FileName$ <> ""
            Directory$ = GetPathPart(*ActiveSource\FileName$)
          Else
            Directory$ = GetCurrentDirectory()
          EndIf
          SetGadgetText(Gadget, Directory$)
          
          
        Case #GADGET_DiffDialog_IgnoreSpaceAll
          If GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceAll)
            DisableGadget(#GADGET_DiffDialog_IgnoreSpaceLeft, 1)
            DisableGadget(#GADGET_DiffDialog_IgnoreSpaceRight, 1)
          Else
            DisableGadget(#GADGET_DiffDialog_IgnoreSpaceLeft, 0)
            DisableGadget(#GADGET_DiffDialog_IgnoreSpaceRight, 0)
          EndIf
          
          
        Case #GADGET_DiffDialog_CompareFiles, #GADGET_DiffDialog_CompareDirectories
          ; update the comboboxes
          For j = #GADGET_DiffDialog_File1 To #GADGET_DiffDialog_Pattern
            UpdateFindComboBox(j)
          Next j
          
          ; get the checkboxes
          DiffRecurse          = GetGadgetState(#GADGET_DiffDialog_Recurse)
          DiffIgnoreCase       = GetGadgetState(#GADGET_DiffDialog_IgnoreCase)
          DiffIgnoreSpaceAll   = GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceAll)
          DiffIgnoreSpaceLeft  = GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceLeft)
          DiffIgnoreSpaceRight = GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceRight)
          
          If GadgetID = #GADGET_DiffDialog_CompareFiles
            ; compare files
            File1$ = GetGadgetText(#GADGET_DiffDialog_File1)
            File2$ = GetGadgetText(#GADGET_DiffDialog_File2)
            If File1$ = "" Or File2$ = ""
              MessageRequester(#ProductName$, Language("Diff", "EmptyField"))
            ElseIf DiffFileToFile(File1$, File2$)
              Quit = 1
            EndIf
            
          Else
            ; compare directories
            Directory1$ = GetGadgetText(#GADGET_DiffDialog_Directory1)
            Directory2$ = GetGadgetText(#GADGET_DiffDialog_Directory2)
            
            If Directory1$ = "" Or Directory2$ = ""
              MessageRequester(#ProductName$, Language("Diff", "EmptyField"))
              
            Else
              If Right(Directory1$, 1) <> #Separator
                Directory1$ + #Separator
              EndIf
              If Right(Directory2$, 1) <> #Separator
                Directory2$ + #Separator
              EndIf
              
              If DiffDirectories(Directory1$, Directory2$, GetGadgetText(#GADGET_DiffDialog_Pattern))
                Quit = 1
              EndIf
            EndIf
          EndIf
          
        Case #GADGET_DiffDialog_Cancel
          Quit = 1
          
      EndSelect
      
  EndSelect
  
  If Quit And IsWindow(#WINDOW_DiffDialog) ; could be closed while processing the directory diff
                                           ; abort any ongoing search
                                           ;GrepAbort = 1
    
    ; get the checkboxes
    DiffRecurse          = GetGadgetState(#GADGET_DiffDialog_Recurse)
    DiffIgnoreCase       = GetGadgetState(#GADGET_DiffDialog_IgnoreCase)
    DiffIgnoreSpaceAll   = GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceAll)
    DiffIgnoreSpaceLeft  = GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceLeft)
    DiffIgnoreSpaceRight = GetGadgetState(#GADGET_DiffDialog_IgnoreSpaceRight)
    
    ; save history
    For j = 0 To 4
      Gadget = #GADGET_DiffDialog_File1 + j
      Count  = CountGadgetItems(Gadget)
      
      For i = 1 To FindHistorySize
        If Count >= i
          DiffDialogHistory(j, i) = GetGadgetItemText(Gadget, i-1, 0)
        Else
          DiffDialogHistory(j, i) = ""
        EndIf
      Next i
    Next j
    
    If MemorizeWindow
      DiffDialogWindowDialog\Close(@DiffDialogWindowPosition)
    Else
      DiffDialogWindowDialog\Close()
    EndIf
  EndIf
  
EndProcedure

Procedure OpenDiffDialogWindow()
  
  If IsWindow(#WINDOW_DiffDialog) = 0
    
    DiffDialogWindowDialog = OpenDialog(?Dialog_DiffDialog, WindowID(#WINDOW_Main), @DiffDialogWindowPosition)
    If DiffDialogWindowDialog
      EnsureWindowOnDesktop(#WINDOW_DiffDialog)
      
      AddKeyboardShortcut(#WINDOW_DiffDialog, #PB_Shortcut_Escape, #GADGET_DiffDialog_Cancel)
      
      EnableGadgetDrop(#GADGET_DiffDialog_File1, #PB_Drop_Files, #PB_Drag_Copy)
      EnableGadgetDrop(#GADGET_DiffDialog_File2, #PB_Drop_Files, #PB_Drag_Copy)
      EnableGadgetDrop(#GADGET_DiffDialog_Directory1, #PB_Drop_Files, #PB_Drag_Copy)
      EnableGadgetDrop(#GADGET_DiffDialog_Directory2, #PB_Drop_Files, #PB_Drag_Copy)
      
      For j = 0 To 4
        For i = 1 To FindHistorySize
          If DiffDialogHistory(j, i) <> ""
            AddGadgetItem(#GADGET_DiffDialog_File1+j, -1, DiffDialogHistory(j, i))
          EndIf
        Next i
      Next j
      
      If CountGadgetItems(#GADGET_DiffDialog_Pattern) = 0
        AddGadgetItem(#GADGET_DiffDialog_Pattern, -1, "*" + #SourceFileExtension)  ; Default to *.pb files, else it will find nothing
      EndIf
      
      For j = #GADGET_DiffDialog_File1 To #GADGET_DiffDialog_Pattern
        SetGadgetState(j, 0)
      Next j
      
      SetGadgetState(#GADGET_DiffDialog_Recurse, DiffRecurse)
      SetGadgetState(#GADGET_DiffDialog_IgnoreCase, DiffIgnoreCase)
      SetGadgetState(#GADGET_DiffDialog_IgnoreSpaceAll, DiffIgnoreSpaceAll)
      SetGadgetState(#GADGET_DiffDialog_IgnoreSpaceLeft, DiffIgnoreSpaceLeft)
      SetGadgetState(#GADGET_DiffDialog_IgnoreSpaceRight, DiffIgnoreSpaceRight)
      
      If DiffIgnoreSpaceAll
        DisableGadget(#GADGET_DiffDialog_IgnoreSpaceLeft, 1)
        DisableGadget(#GADGET_DiffDialog_IgnoreSpaceRight, 1)
      EndIf
      
      HideWindow(#WINDOW_DiffDialog, 0)
      
      ; fix required for the centereing of non-resizable windows in the dialog manager
      ; (works only if window is visible)
      CompilerIf #CompileLinuxGtk
        If DiffDialogWindowPosition\x = -1 And DiffDialogWindowPosition\y = -1
          While WindowEvent(): Wend
          gtk_window_set_position_(WindowID(#WINDOW_DiffDialog), #GTK_WIN_POS_CENTER)
        EndIf
      CompilerEndIf
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_DiffDialog)
  EndIf
  
  SelectComboBoxText(#GADGET_DiffDialog_File1)
  SetActiveGadget(#GADGET_DiffDialog_File1)
  
EndProcedure

Procedure UpdateDiffDialogWindow()
  
  DiffDialogWindowDialog\LanguageUpdate()
  
  For j = 0 To 4
    Gadget = #GADGET_DiffDialog_File1 + j
    While FindHistorySize < CountGadgetItems(Gadget)
      RemoveGadgetItem(Gadget, CountGadgetItems(Gadget)-1)
    Wend
  Next j
  
  DiffDialogWindowDialog\GuiUpdate()
  
EndProcedure
