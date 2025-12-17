; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Global IsIDEConfigPresent ; ugly way to do this, but works. to test if the source was ever loaded by the IDE
Global MarkerLines$

; Only for ChangeActiveSourceCode() to hide the previously visible gadget,
; even when *ActiveSource does not actually represent the currently visible one.
; (which is done while opening a new source file)
;
Global VisibleScintillaGadget

; only needed during file loading:
; as there is a UpdateCursorPosition() somewhere in the process, we cannot use
; the SourceFile fields dring this time
Global Loading_FirstVisibleLine, Loading_CurrentLine, Loading_CurrentColumn
Global Loading_FoldingState$

Procedure UpdateCursorPosition()
  GetCursorPosition() ; sets the SourceFile fields also used by other functions
  
  StartPosition = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
  EndPosition   = SendEditorMessage(#SCI_GETSELECTIONEND, 0, 0)
  
  If StartPosition = EndPosition
    Text$ = Language("Misc","Line")+": "+Str(*ActiveSource\CurrentLine)+"   "+Language("Misc","Column")+": "+Str(*ActiveSource\CurrentColumnDisplay)
    
  Else
    Text$ = Language("Misc","Line")+": "+Str(*ActiveSource\CurrentLine)+"   "+Language("Misc","Column")+": "+Str(*ActiveSource\CurrentColumnDisplay) + " - ["+Str(CountCharacters(*ActiveSource\EditorGadget, StartPosition, EndPosition))+"]" ; Use a short 'selection'  marker, or the text line+column+selection will be too big for the statusbar field (need #SCI_COUNTCHARACTERS to handle UTF8 properly)
    
  EndIf
  
  StatusBarText(#STATUSBAR, 0, Text$, #PB_StatusBar_Center)
EndProcedure

Procedure RefreshSourceTitle(*Source.SourceFile)
  
  PushListPosition(FileList())
  ChangeCurrentElement(FileList(), *Source)
  Index = ListIndex(FileList())
  PopListPosition(FileList())
  
  SetTabBarGadgetItemText(#GADGET_FilesPanel, Index, GetSourceTitle(*Source))
  
  If *Source = *ProjectInfo
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, #COLOR_ProjectInfo)
  ElseIf *Source\IsForm And *Source\ProjectFile
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, #COLOR_FormProjectFile)
  ElseIf *Source\IsForm
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, #COLOR_FormFile)
  ElseIf *Source\ProjectFile
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
    SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, #COLOR_ProjectFile)
  Else
    ; MacOS Colors
    CompilerIf #CompileMac
      
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, TabBarGadgetInclude\TextColor)
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, TabBarGadgetInclude\FaceColor)

    CompilerElseIf #CompileLinuxGtk

      SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, TabBarGadgetInclude\TextColor)
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, TabBarGadgetInclude\FaceColor)
      
    CompilerElse
      
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, #PB_Default)
    
    CompilerEndIf
    
  EndIf
EndProcedure

; get the title string for the current element in FileList()
Procedure.s GetSourceTitle(*Source.SourceFile)
  
  If *Source = *ProjectInfo
    ;Title$ = "> " + Language("Project","TabTitle")
    Title$ = Language("Project","TabTitle")
    
  Else
    
    Modified = GetSourceModified(*Source)
    
    If *Source\FileName$ = "" And *Source\IsForm
      Title$ = Language("FileStuff","NewForm")
    ElseIf *Source\FileName$ = ""
      Title$ = Language("FileStuff","NewSource")
    Else
      Title$ = GetFilePart(*Source\FileName$)
    EndIf
    
    If Modified
      Title$ + "*"
    EndIf
    
    ;     If *Source\ProjectFile
    ;       Title$ = "> " + Title$
    ;     EndIf
    
  EndIf
  
  ProcedureReturn Title$
  
EndProcedure

Procedure UpdateSourceStatus(Modified)
  
  If Modified = -1
    Modified = GetSourceModified()
    
  ElseIf Modified <> GetSourceModified()
    SetSourceModified(Modified)
    
  EndIf
  
  ; only do an actual refresh if needed.
  ; this procedure is called many times during folding as it seems,
  ; so limit the number of updates if nothing changed
  If Modified <> *ActiveSource\DisplayModified
    *ActiveSource\DisplayModified = Modified
    
    RefreshSourceTitle(*ActiveSource)
    UpdateMenuStates()
  EndIf
  
EndProcedure

; Note: Do not call FlushEvents() in here as this procedure is called during file loading and processing
;       events could change the active source again and really mess things up!
;
Procedure ChangeActiveSourcecode(*OldSource.SourceFile = 0)
  
  If *OldSource = 0
    *OldSource = *ActiveSource
  EndIf
  
  ; Make sure the sorted data for the old source is up to date to ensure
  ; a quick access. Does nothing if the data is up to date
  If *OldSource And *OldSource <> *ProjectInfo And *OldSource\IsForm = 0
    SortParserData(*OldSource\Parser, *OldSource)
  EndIf
  
  ; preserve procedure browser scroll position
  If ProcedureBrowserMode = 1 And *OldSource And *OldSource <> *ProjectInfo
    *OldSource\ProcedureBrowserScroll = GetListViewScroll(#GADGET_ProcedureBrowser)
  EndIf
  
  AutoComplete_Close()
  
  If *ActiveSource And IsWindow(#WINDOW_Option)  ; make sure the options are closed
    If (*ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile = 0) Or (@FileList() <> *ProjectInfo And FileList()\ProjectFile = 0)
      ; close only if either the old or the new code do not belong to the project
      OptionWindowEvents(#PB_Event_CloseWindow)
    EndIf
  EndIf
  
  CompilerIf #SpiderBasic
    If *ActiveSource And IsWindow(#WINDOW_CreateApp)  ; make sure the CreateApp window is closed
      If (*ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile = 0) Or (@FileList() <> *ProjectInfo And FileList()\ProjectFile = 0)
        ; close only if either the old or the new code do not belong to the project
        CreateAppWindowEvents(#PB_Event_CloseWindow)
      EndIf
    EndIf
  CompilerEndIf
  
  *ActiveSource = @FileList()
  
  SetTabBarGadgetState(#GADGET_FilesPanel, ListIndex(FileList()))
  
  HideLineNumbers(*ActiveSource, 1-EnableLineNumbers)
  
  UpdateMainWindowTitle()
  
  ClearList(BlockSelectionStack())
  BlockSelectionUpdated = #False
  
  ErrorLog_Refresh()   ; always update, even if hidden
  ErrorLog_SyncState(#False) ; update the display state
  
  ResizeMainWindow()  ; make sure the EditorGadget is correctly sized
  
  If *ActiveSource = *ProjectInfo
    EnsureListIconSelection(#GADGET_ProjectInfo_Files)
    HideGadget(#GADGET_ProjectInfo, 0)
    SetActiveGadget(#GADGET_ProjectInfo_Files)
    
  Else
    If *ProjectInfo
      HideGadget(#GADGET_ProjectInfo, 1)
    EndIf
    
    SetActiveGadget(*ActiveSource\EditorGadget)
    HideEditorGadget(*ActiveSource\EditorGadget, 0) ; Show only when the resize is done
    
    CompilerIf #CompileWindows
      ;
      ; Some weird touchpad driver has a problem with invisible windows being on top
      ; in the z-order, so make sure the newly visible gadget is the topmost one
      ; This is not a PB bug, its just a compatibility hack for that driver
      ;
      SetWindowPos_(GadgetID(*ActiveSource\EditorGadget), #HWND_TOP, 0, 0, 0, 0, #SWP_NOMOVE|#SWP_NOOWNERZORDER|#SWP_NOSIZE)
    CompilerEndIf
  EndIf
  
  If *ActiveSource = *ProjectInfo
    If VisibleScintillaGadget
      HideEditorGadget(VisibleScintillaGadget, 1)
    EndIf
    VisibleScintillaGadget = 0
  Else
    ; We hide the previous editor gadget only when the new one is displayed, to remove flickering
    ; NOTE: While a new source is created, the actually displayed gadget is not
    ;   from *ActiveSource (to avoid some flicker), so use a special variable for this check.
    ;
    If VisibleScintillaGadget And VisibleScintillaGadget <> *ActiveSource\EditorGadget
      HideEditorGadget(VisibleScintillaGadget, 1)
    EndIf
    VisibleScintillaGadget = *ActiveSource\EditorGadget
  EndIf
  
  ; show up the canvas for form drawing it the source is actually a form otherwise hide it
  If *ActiveSource\IsForm
    currentwindow = *ActiveSource\IsForm
    
    FD_SelectWindow(currentwindow)
    FD_UpdateObjList()
    redraw = 1
    
    If FormWindows()\current_view = 0
      HideGadget(#GADGET_Form, 0)
      HideEditorGadget(*ActiveSource\EditorGadget, 1)
      
      RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return)
      RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab)
      RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab)
    Else
      HideGadget(#GADGET_Form, 1)
      HideEditorGadget(*ActiveSource\EditorGadget, 0)
      SetActiveGadget(*ActiveSource\EditorGadget)
      
      FD_SelectNone()
      
      CompilerIf #CompileWindows | #CompileMac | #CompileLinuxQt
        AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return, #MENU_Scintilla_Enter)
        AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab, #MENU_Scintilla_Tab)
        AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab, #MENU_Scintilla_ShiftTab)
      CompilerEndIf
    EndIf
    
  Else
    currentwindow = 0 ; no more active form
    
    CompilerIf #CompileWindows | #CompileMac | #CompileLinuxQt
      AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return, #MENU_Scintilla_Enter)
      AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab, #MENU_Scintilla_Tab)
      AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab, #MENU_Scintilla_ShiftTab)
    CompilerEndIf
    
    FD_SelectNone()
    
    If IsGadget(#Form_PropObjList)
      ClearGadgetItems(#Form_PropObjList)
    EndIf
    
    If IsGadget(#GADGET_Form)
      HideGadget(#GADGET_Form, 1)
    EndIf
  EndIf
  
  UpdateCursorPosition()
  
  ; enabled the folding update again, as strangely the fold mark in first line disappears otherwise !?
  If *ActiveSource <> *ProjectInfo And Not *ActiveSource\IsForm
    FullSourceScan(*ActiveSource)
    UpdateFolding(*ActiveSource, 0, -1)
  EndIf
  
  UpdateProcedureList(*ActiveSource\ProcedureBrowserScroll) ; apply previous scroll position (if any)
  UpdateVariableViewer()
  
  UpdateMenuStates()
  SetDebuggerMenuStates()
  
  ; update quickhelp
  If *ActiveSource = *ProjectInfo
    ChangeStatus("", 0)
    
  ElseIf SendEditorMessage(#SCI_GETREADONLY, 0, 0) = 0 ; do not update quickhelp when in debugger mode
    ChangeStatus("", 0)
    UpdateCursorPosition()
    selStart = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
    selEnd = SendEditorMessage(#SCI_GETSELECTIONEND  , 0, 0)
    If selStart = selEnd
      QuickHelpFromLine(*ActiveSource\CurrentLine-1, *ActiveSource\CurrentColumnChars-1)
    EndIf
  EndIf
  
  UpdateSelectionRepeat()
  
EndProcedure

Procedure NewSource(FileName$, ExecuteTool)
  *OldSource = *ActiveSource
  
  LastElement(FileList())
  AddElement(FileList())
  
  ; Generate a unique ID for the target in this structure
  ;
  FileList()\ID = GetUniqueID()
  
  If FileName$ = ""
    Title$ =  Language("FileStuff","NewSource")
  Else
    Title$ = GetFilePart(FileName$)
  EndIf
  
  OpenGadgetList(#GADGET_SourceContainer)
  CreateEditorGadget()
  CloseGadgetList()
  
  If FileName$ = ""
    FileList()\IsCode = #True ; assume it is a code file until it is saved
  Else
    FileList()\IsCode = IsCodeFile(FileName$)
  EndIf
  
  FileList()\FileName$        = FileName$
  FileList()\Debugger         = OptionDebugger  ; set the default values
  FileList()\EnablePurifier   = OptionPurifier
  FileList()\Optimizer        = OptionOptimizer
  FileList()\EnableASM        = OptionInlineASM
  FileList()\EnableXP         = OptionXPSkin
  FileList()\EnableWayland    = OptionWayland
  FileList()\EnableAdmin      = OptionVistaAdmin
  FileList()\EnableUser       = OptionVistaUser
  FileList()\DPIAware         = OptionDPIAware
  FileList()\DllProtection    = OptionDllProtection
  FileList()\SharedUCRT       = OptionSharedUCRT
  FileList()\EnableThread     = OptionThread
  FileList()\EnableOnError    = OptionOnError
  FileList()\ExecutableFormat = OptionExeFormat
  FileList()\CPU              = OptionCPU
  FileList()\NewLineType      = OptionNewLineType
  FileList()\SubSystem$       = OptionSubSystem$
  FileList()\ErrorLog         = OptionErrorLog
  FileList()\Parser\Encoding  = OptionEncoding
  FileList()\UseCreateExe     = OptionUseCreateExe
  FileList()\UseBuildCount    = OptionUseBuildCount
  FileList()\UseCompileCount  = OptionUseCompileCount
  FileList()\TemporaryExePlace= OptionTemporaryExe
  FileList()\CustomCompiler   = OptionCustomCompiler
  FileList()\CompilerVersion$ = OptionCompilerVersion$
  FileList()\CurrentDirectory$= ""
  FileList()\ToggleFolds      = 1
  FileList()\PurifierGranularity$ = ""
  FileList()\ExistsOnDisk     = #False
  
  If OptionEncoding = 0
    ScintillaSendMessage(FileList()\EditorGadget, #SCI_SETCODEPAGE, 0, 0)
  Else
    ScintillaSendMessage(FileList()\EditorGadget, #SCI_SETCODEPAGE, #SC_CP_UTF8, 0)
  EndIf
  
  AddTabBarGadgetItem(#GADGET_FilesPanel, #PB_Default, Title$)
  ChangeActiveSourcecode(*OldSource)
  
  ; Link to project (if any)
  ; Do it as soon as possible, so the panel tab gets the right color very quickly.
  LinkSourceToProject(*ActiveSource)
  
  If EnableColoring
    SetBackgroundColor()
  EndIf
  
  SetTabBarGadgetState(#GADGET_FilesPanel, CountTabBarGadgetItems(#GADGET_FilesPanel)-1)
  UpdateSourceStatus(0)
  ResizeMainWindow()
  
  ; if configured and needed, execute tool for new sources
  If ExecuteTool
    AddTools_Execute(#TRIGGER_NewSource, *ActiveSource)
    
    ; reset the modified flag so this code can be closed without saving if nothing is changed
    UpdateSourceStatus(#False)
    
    ; place cursor at end of file (usually such tools add headers to a file)
    Pos = SendEditorMessage(#SCI_GETLENGTH, 0, 0)
    SendEditorMessage(#SCI_SETSEL, Pos, Pos)
    UpdateCursorPosition()
  EndIf
  
EndProcedure


Procedure DetectNewLineType(*Buffer, BufferSize)
  
  *Pointer.HighlightPTR = *Buffer
  *BufferEnd = *Buffer + BufferSize
  DetectedType = -1
  
  While *Pointer < *BufferEnd
    
    If *Pointer\b = 13 And *Pointer\a[1] = 10
      ; windows newline
      If DetectedType <> 0 And DetectedType <> -1 ; oops, a mixed up file, use os standard
        ProcedureReturn #DEFAULT_NewLineType
      EndIf
      DetectedType = 0
      *Pointer + 1
      
    ElseIf *Pointer\b = 10 And *Pointer\a[1] = 13
      ; unknown type, use os standard
      ProcedureReturn #DEFAULT_NewLineType
      
    ElseIf *Pointer\b = 10
      ; linux newline
      If DetectedType <> 1 And DetectedType <> -1 ; oops, a mixed up file, use os standard
        ProcedureReturn #DEFAULT_NewLineType
      EndIf
      DetectedType = 1
      
    ElseIf *Pointer\b = 13
      ; mac newline
      If DetectedType <> 2 And DetectedType <> -1 ; oops, a mixed up file, use os standard
        ProcedureReturn #DEFAULT_NewLineType
      EndIf
      DetectedType = 2
      
    EndIf
    
    *Pointer + 1
  Wend
  
  If DetectedType = -1
    DetectedType = #DEFAULT_NewLineType
  EndIf
  
  ProcedureReturn DetectedType
EndProcedure


Procedure ChangeNewLineType(*ptrBuffer.INTEGER, *ptrBufferSize.INTEGER, NewLineType)
  
  *NewBuffer = AllocateMemory(*ptrBufferSize\i + 1000000)
  *BufferEnd = *ptrBuffer\i + *ptrBufferSize\i
  *ReadCursor.HighlightPTR = *ptrBuffer\i
  *WriteCursor.HighlightPTR = *NewBuffer
  
  CopyMemoryString("", @*WriteCursor)
  
  If *NewBuffer
    
    While *ReadCursor < *BufferEnd
      If (*ReadCursor\b = 13 And *ReadCursor\a[1] = 10) Or (*ReadCursor\b = 10 And *ReadCursor\a[1] = 13)
        If NewLineType = 0 ; to crlf
          *WriteCursor\b = 13
          *WriteCursor\a[1] = 10
          *ReadCursor + 1
          *WriteCursor + 1
          
        ElseIf NewLineType = 1 ; to lf
          *WriteCursor\b = 10
          *ReadCursor + 1
          
        Else  ; to cr
          *WriteCursor\b = 13
          *ReadCursor + 1
          
        EndIf
        
      ElseIf *ReadCursor\b = 13 Or *ReadCursor\b = 10
        If NewLineType = 0 ; crlf
          *WriteCursor\b = 13
          *WriteCursor\a[1] = 10
          *WriteCursor + 1
          
        ElseIf NewLineType = 1 ; to lf
          *WriteCursor\b = 10
          
        Else ; to cr
          *WriteCursor\b = 13
          
        EndIf
        
      Else
        *WriteCursor\b = *ReadCursor\b
        
      EndIf
      
      *ReadCursor + 1
      *WriteCursor + 1
    Wend
    
    FreeMemory(*ptrBuffer\i) ; free the old buffer
    *ptrBuffer\i     = *NewBuffer
    *ptrBufferSize\i = *WriteCursor - *NewBuffer
    
  EndIf
  
EndProcedure


; Note: We do not use the SYS_AsciiToUTF8 etc anymore because:
;  The "�" and "`" Characters ($91, $92) are not displayed by Scintilla.
;  Scintilla instead uses U+2018 and U+2019 characters when they get pasted.
;  So to avoid any confustion from a disappearing character we handle this conversion
;  as well when doing the Source encoding change.
;
;  Let's hope there are no more such special characters.
;
; Some notes:
;  - unrepresentable chars become '?'
;

Procedure AsciiToUTF8(*out.ASCII, *outlen.LONG, *in.ASCII, *inlen.LONG)
  
  *in_end    = *in + *inlen\l   ; copy to local vars for access speed
  *out_start = *out
  
  While *in < *in_end      ; ascii range
    If *in\a < $80
      *out\a = *in\a
      *out + 1
      
    ElseIf *in\a = $91     ; `-char. Turn this into U+2018
      *out\a = $E2
      *out + 1
      *out\a = $80
      *out + 1
      *out\a = $98
      *out + 1
      
    ElseIf *in\a = $92     ; ï¿½-char. Turn this into U+2019
      *out\a = $E2
      *out + 1
      *out\a = $80
      *out + 1
      *out\a = $99
      *out + 1
      
    Else                   ; turn it into a 2byte sequence
      *out\a = ((*in\a >> 6) & %00011111) | %11000000
      *out + 1
      *out\a = (*in\a & %00111111) | %10000000
      *out + 1
      
    EndIf
    
    *in + 1
  Wend
  
  *outlen\l = *out - *out_start
EndProcedure

Procedure UTF8ToAscii(*out.ASCII, *outlen.LONG, *in.ASCII, *inlen.LONG)
  *in_end    = *in + *inlen\l   ; copy to local vars for access speed
  *out_start = *out
  
  While *in < *in_end
    c = *in\a
    
    If c & %10000000 = 0 ; 1-byte char
      *out\a = c
      *out + 1
      *in + 1
      
    ElseIf c & %11100000 = %11000000 And *in+1 < *in_end ; 2-byte char
      *in + 1
      If *in\a & %11000000 = %10000000 ; check if the next is a followup byte
        c = ((c & %00011111) << 6) | (*in\a & %00111111)
        If c < 256
          *out\a = c
        Else
          *out\a = '?' ; unicode char outside of ascii range
        EndIf
        *out + 1
        *in + 1
      Else
        *out\a = '?' ; invalid utf8
        *out + 1
      EndIf
      
    ElseIf c & %11110000 = %11100000 And *in+2 < *in_end ; 3-byte char, not representable in ascii
      
      If c = $E2 And PeekC(*in+1) = $80 And PeekC(*in+2) = $98
        *out\a = $91
        *out + 1
        *in + 3
        
      ElseIf c = $E2 And PeekC(*in+1) = $80 And PeekC(*in+2) = $99
        *out\a = $92
        *out + 1
        *in + 3
        
      Else
        *out\a = '?'
        *out + 1
        
        ; skip the next two bytes only if they are correct followup bytes
        If PeekC(*in+1) & %11000000 = %10000000 And PeekC(*in+2) & %11000000 = %10000000
          *in + 3
        ElseIf PeekC(*in+1) & %11000000 = %10000000
          *in + 2 ; incomplete sequence
        Else
          *in + 1 ; only start byte of sequence
        EndIf
      EndIf
      
    ElseIf c & %11111000 = %11110000 And *in+3 < *in_end ; 4-byte char, not representable in ascii
      *out\a = '?'
      *out + 1
      
      ; skip the next three bytes only if they are correct followup bytes
      If PeekC(*in+1) & %11000000 = %10000000 And PeekC(*in+2) & %11000000 = %10000000 And PeekC(*in+3) & %11000000 = %10000000
        *in + 4
      ElseIf PeekC(*in+1) & %11000000 = %10000000 And PeekC(*in+2) & %11000000 = %10000000
        *in + 3 ; incomplete sequence
      ElseIf PeekC(*in+1) & %11000000 = %10000000
        *in + 2 ; incomplete sequence
      Else
        *in + 1 ; only start byte of sequence
      EndIf
      
    Else
      *in + 1 ; invalid UTF-8, just skip it
      
    EndIf
  Wend
  
  *outlen\l = *out - *out_start
EndProcedure

Procedure ChangeTextEncoding(*Source.SourceFile, NewEncoding)
  
  If NewEncoding <> *Source\Parser\Encoding
    
    ; Its .l as the SYS function takes an int *
    OldLength.l = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLENGTH, 0, 0)
    *OldBuffer  = AllocateMemory(OldLength+1)
    
    If *OldBuffer
      ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXT, OldLength+1, *OldBuffer) ; #SCI_GETTEXT returns length-1 bytes... very inconsistent of scintilla
      
      If NewEncoding = 1
        NewLength.l = OldLength*4  ; Utf8 can only be 4x as big as Ascii
      Else
        NewLength.l = OldLength  ; Buffer can only get smaller for Utf8-Ascii
      EndIf
      
      *NewBuffer = AllocateMemory(NewLength+1)
      
      If *NewBuffer
        If NewEncoding = 1
          AsciiToUTF8(*NewBuffer, @NewLength, *OldBuffer, @OldLength)
        Else
          UTF8ToAscii(*NewBuffer, @NewLength, *OldBuffer, @OldLength)
        EndIf
        
        ScintillaSendMessage(*Source\EditorGadget, #SCI_CLEARALL, 0, 0) ; should completely erase the old document and create a new one
        
        If NewEncoding = 0
          ScintillaSendMessage(*Source\EditorGadget, #SCI_SETCODEPAGE, 0, 0)
        Else
          ScintillaSendMessage(*Source\EditorGadget, #SCI_SETCODEPAGE, #SC_CP_UTF8, 0)
        EndIf
        
        
        ScintillaSendMessage(*Source\EditorGadget, #SCI_SETTEXT, 0, *NewBuffer)
        
        *Source\Parser\Encoding = NewEncoding ; finally update the flag in the structure
        
        FreeMemory(*NewBuffer)
      EndIf
      
      FreeMemory(*OldBuffer)
    EndIf
    
  EndIf
  
EndProcedure

; Use macro to ease the typing
;
Macro AddStringConfigLine(Key, Value)
  If Value And IsCodeFile ; Don't save empty value, as it's the default
    NbLines + 1
    ConfigLines$(NbLines) = Key + " = " + Value
  EndIf
EndMacro

Macro AddFlagConfigLine(Key, Value)
  If Value And IsCodeFile ; Don't save empty value, as it's the default
    NbLines + 1
    ConfigLines$(NbLines) = Key
  EndIf
EndMacro


; Also used to append Project settings to a temp file, so it must handle a CompileTarget input
;
Procedure SaveProjectSettings(*Target.CompileTarget, IsCodeFile, IsTempFile, ReportErrors)
  
  If SaveProjectSettings = #SAVESETTINGS_DoNotSave And IsTempFile = 0 ; don't save anything
    ProcedureReturn
  EndIf
  
  If SaveProjectSettings = #SAVESETTINGS_EndOfFile And IsCodeFile = 0
    ; Do not save settings at the end of non-code files
    ; We do however save settings when they are not appended to the file to memorize cursor position etc
    ProcedureReturn
  EndIf
  
  ; If its not a target, we have more info from the extended sourcefile structure
  If *Target\IsProject = 0
    *Source.SourceFile = *Target
  Else
    *Source = 0
  EndIf
  
  ; generate the config lines
  ;
  If CommandlineBuild = 0 And *Target = *ActiveSource
    UpdateCursorPosition()
  EndIf
  
  ; Note: All entries with a fixed number of lines come first
  ;       (no array bounds check needed then)
  ;
  
  NbLines = 1
  ConfigLines$(NbLines) = "IDE Options = "+DefaultCompiler\VersionString$
  
  If IsCodeFile
    If *Target\ExecutableFormat = 1
      NbLines + 1
      ConfigLines$(NbLines) = "ExecutableFormat = Console"
    ElseIf *Target\ExecutableFormat = 2
      NbLines + 1
      
      ; Note: when writing, we make a difference, on reading we allow both for compatibility
      ;
      CompilerIf #CompileWindows
        ConfigLines$(NbLines) = "ExecutableFormat = Shared dll"
      CompilerElseIf #CompileMac
        ConfigLines$(NbLines) = "ExecutableFormat = Shared .dylib"
      CompilerElse ; Linux
        ConfigLines$(NbLines) = "ExecutableFormat = Shared .so"
      CompilerEndIf
    EndIf ; no need to write it when it's 0.. it will default to that anyway
  EndIf
  
  If (MemorizeCursor Or IsTempFile) And *Source
    If *Source\CurrentLine > 1
      NbLines + 1
      ConfigLines$(NbLines) = "CursorPosition = "+Str(*Source\CurrentLine-1)
    EndIf
    
    If IsTempFile ; this is saved for tempfiles only
      NbLines + 1
      ConfigLines$(NbLines) = "CursorColumn = "+Str(*Source\CurrentColumnBytes)
    EndIf
    
    If *Source = *ActiveSource
      FirstLine = GetFirstVisibleLine()
    EndIf
    
    If FirstLine > 0
      NbLines + 1
      ConfigLines$(NbLines) = "FirstLine = "+Str(FirstLine)
    EndIf
  EndIf
  
  If *Source And *Source = *ActiveSource And EnableFolding And IsCodeFile
    FoldingInfo$ = CreateFoldingInformation()
    If FoldingInfo$ <> ""
      NbLines + 1
      ConfigLines$(NbLines) = "Folding = "+FoldingInfo$
    EndIf
  EndIf
  
  If CommandlineBuild = 0 And *Source = *ActiveSource And (MemorizeMarkers Or IsTempFile)
    Markers$ = GetMarkerString()
    If Markers$ <> ""
      NbLines + 1
      ConfigLines$(NbLines) = "Markers = "+Markers$
    EndIf
  EndIf
  
  CompilerIf #SpiderBasic
    
    AddStringConfigLine("WindowTheme", *Target\WindowTheme$)
    AddStringConfigLine("GadgetTheme", *Target\GadgetTheme$)
    AddStringConfigLine("WebServerAddress", *Target\WebServerAddress$)
    
    ; WebApp
    ;
    AddStringConfigLine("WebAppName"        , *Target\WebAppName$)
    AddStringConfigLine("WebAppIcon"        , *Target\WebAppIcon$)
    AddStringConfigLine("HtmlFilename"      , *Target\HtmlFilename$)
    AddStringConfigLine("JavaScriptFilename", *Target\JavaScriptFilename$)
    AddStringConfigLine("JavaScriptPath"    , *Target\JavaScriptPath$)
    AddStringConfigLine("ExportCommandLine" , *Target\ExportCommandLine$)
    AddStringConfigLine("ExportArguments"   , *Target\ExportArguments$)
    AddStringConfigLine("ResourceDirectory" , *Target\ResourceDirectory$)
    AddFlagConfigLine("EnableResourceDirectory", *Target\EnableResourceDirectory)
    AddFlagConfigLine("CopyJavaScriptLibrary", *Target\CopyJavaScriptLibrary)
    AddFlagConfigLine("WebAppEnableDebugger" , *Target\WebAppEnableDebugger)
    
    ; iOSApp
    ;
    AddStringConfigLine("iOSAppName"        , *Target\iOSAppName$)
    AddStringConfigLine("iOSAppIcon"        , *Target\iOSAppIcon$)
    AddStringConfigLine("iOSAppVersion"     , *Target\iOSAppVersion$)
    AddStringConfigLine("iOSAppPackageID"   , *Target\iOSAppPackageID$)
    AddStringConfigLine("iOSAppStartupImage", *Target\iOSAppStartupImage$)
    AddStringConfigLine("iOSAppOutput"      , *Target\iOSAppOutput$)
    AddStringConfigLine("iOSAppResourceDirectory" , *Target\iOSAppResourceDirectory$)
    AddFlagConfigLine("iOSAppEnableResourceDirectory", *Target\iOSAppEnableResourceDirectory)
    AddStringConfigLine("iOSAppOrientation", Str(*Target\iOSAppOrientation))
    AddFlagConfigLine("iOSAppFullScreen" , *Target\iOSAppFullScreen)
    AddFlagConfigLine("iOSAppAutoUpload" , *Target\iOSAppAutoUpload)
    AddFlagConfigLine("iOSAppEnableDebugger" , *Target\iOSAppEnableDebugger)
    AddFlagConfigLine("iOSAppKeepAppDirectory" , *Target\iOSAppKeepAppDirectory)
    
    ; AndroidApp
    ;
    AddStringConfigLine("AndroidAppName"        , *Target\AndroidAppName$)
    AddStringConfigLine("AndroidAppIcon"        , *Target\AndroidAppIcon$)
    AddStringConfigLine("AndroidAppVersion"     , *Target\AndroidAppVersion$)
    AddStringConfigLine("AndroidAppCode"        , Str(*Target\AndroidAppCode))
    AddStringConfigLine("AndroidAppPackageID"   , *Target\AndroidAppPackageID$)
    AddStringConfigLine("AndroidAppIAPKey"      , *Target\AndroidAppIAPKey$)
    AddStringConfigLine("AndroidAppStartupImage", *Target\AndroidAppStartupImage$)
    AddStringConfigLine("AndroidAppStartupColor", *Target\AndroidAppStartupColor$)
    AddStringConfigLine("AndroidAppOutput"      , *Target\AndroidAppOutput$)
    AddStringConfigLine("AndroidAppResourceDirectory" , *Target\AndroidAppResourceDirectory$)
    AddFlagConfigLine("AndroidAppEnableResourceDirectory", *Target\AndroidAppEnableResourceDirectory)
    AddStringConfigLine("AndroidAppOrientation" , Str(*Target\AndroidAppOrientation))
    AddFlagConfigLine("AndroidAppFullScreen"    , *Target\AndroidAppFullScreen)
    AddFlagConfigLine("AndroidAppAutoUpload"    , *Target\AndroidAppAutoUpload)
    AddFlagConfigLine("AndroidAppEnableDebugger", *Target\AndroidAppEnableDebugger)
    AddFlagConfigLine("AndroidAppKeepAppDirectory", *Target\AndroidAppKeepAppDirectory)
    AddFlagConfigLine("AndroidAppInsecureFileMode", *Target\AndroidAppInsecureFileMode)
    
  CompilerEndIf
  
  AddFlagConfigLine("Optimizer", *Target\Optimizer)
  
  If *Target\EnableASM And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableAsm"
  EndIf
  If *Target\EnableThread And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableThread"
  EndIf
  If *Target\EnableXP And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableXP"
  EndIf
  If *Target\EnableWayland And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableWayland"
  EndIf
  If *Target\EnableAdmin And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableAdmin"
  EndIf
  If *Target\EnableUser And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableUser"
  EndIf
  If *Target\DPIAware And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "DPIAware"
  EndIf
  If *Target\DllProtection And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "DllProtection"
  EndIf
  If *Target\SharedUCRT And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "SharedUCRT"
  EndIf
  If *Target\EnableOnError And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableOnError"
  EndIf
  If *Target\UseIcon And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "UseIcon = " + *Target\IconName$
  EndIf
  If *Target\UseMainFile And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "UseMainFile = " + *Target\MainFile$
  EndIf
  If *Target\ExecutableName$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "Executable = " + CreateRelativePath(GetPathPart(*Target\FileName$), *Target\ExecutableName$)
  EndIf
  If *Target\CPU And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "CPU = " + Str(*Target\CPU)
  EndIf
  If *Target\SubSystem$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "SubSystem = " + *Target\Subsystem$
  EndIf
  If *Target\LinkerOptions$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "LinkerOptions = " + *Target\LinkerOptions$
  EndIf
  
  If *Target\Debugger = 0 And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "DisableDebugger"
  EndIf
  If *Source And *Source\ErrorLog = 0 And IsCodeFile ; this is only for source files
    NbLines + 1
    ConfigLines$(NbLines) = "HideErrorLog"
  EndIf
  If *Target\CommandLine$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "CommandLine = " + *Target\CommandLine$
  EndIf
  If *Target\CurrentDirectory$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "CurrentDirectory = " + *Target\CurrentDirectory$
  EndIf
  If *Target\TemporaryExePlace And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "CompileSourceDirectory"
  EndIf
  If *Target\EnabledTools$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnabledTools = " + *Target\EnabledTools$
  EndIf
  
  If *Target\CustomCompiler And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "Compiler = "+*Target\CompilerVersion$
  EndIf
  
  If *Target\CustomDebugger And IsCodeFile; do not save any of this if disabled
                                          ;     CompilerIf #CompileMac ; not supported on OSX yet OSX-debug
                                          ;       If *Source\DebuggerType = 1 Or *Source\DebuggerType = 2
                                          ;         Type = *Source\DebuggerType + 1
                                          ;       Else
                                          ;         Type = 0
                                          ;       EndIf
                                          ;     CompilerElse
    Type = *Target\DebuggerType
    ;     CompilerEndIf
    
    If Type = 1
      NbLines + 1
      ConfigLines$(NbLines) = "Debugger = IDE"
    ElseIf Type = 2
      NbLines + 1
      ConfigLines$(NbLines) = "Debugger = Standalone"
    ElseIf Type = 3
      NbLines + 1
      ConfigLines$(NbLines) = "Debugger = Console"
    EndIf
  EndIf
  
  If *Target\CustomWarning And IsCodeFile
    If *Target\WarningMode = 0
      NbLines + 1
      ConfigLines$(NbLines) = "Warnings = Ignore"
    ElseIf *Target\WarningMode = 1
      NbLines + 1
      ConfigLines$(NbLines) = "Warnings = Display"
    ElseIf *Target\WarningMode = 2
      NbLines + 1
      ConfigLines$(NbLines) = "Warnings = Error"
    EndIf
  EndIf
  
  ; Save the granularity options even if the purifier is disabled
  ;
  If *Target\EnablePurifier And *Target\PurifierGranularity$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnablePurifier = " + *Target\PurifierGranularity$
  ElseIf *Target\EnablePurifier And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnablePurifier"
  ElseIf *Target\PurifierGranularity$ And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "DisablePurifier = " + *Target\PurifierGranularity$
  EndIf
  
  If *Target\UseCompileCount And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableCompileCount = " + Str(*Target\CompileCount)
  ElseIf *Target\CompileCount > 0 And IsCodeFile ; only save when <> 0 in disabled mode
    NbLines + 1
    ConfigLines$(NbLines) = "DisableCompileCount = " + Str(*Target\CompileCount)
  EndIf
  If *Target\UseBuildCount And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableBuildCount = " + Str(*Target\BuildCount)
  ElseIf *Target\BuildCount > 0 And IsCodeFile ; only save when <> 0 in disabled mode
    NbLines + 1
    ConfigLines$(NbLines) = "DisableBuildCount = " + Str(*Target\BuildCount)
  EndIf
  If *Target\UseCreateExe And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "EnableExeConstant"
  EndIf
  
  If *Target\NbConstants > 0 And IsCodeFile
    For i = 0 To *Target\NbConstants-1
      NbLines + 1
      
      If *Target\ConstantEnabled[i]
        ConfigLines$(NbLines) = "Constant = " + *Target\Constant$[i]
      Else
        ConfigLines$(NbLines) = "ConstantOff = " + *Target\Constant$[i]
      EndIf
    Next i
  EndIf
  
  If *Target\VersionInfo And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "IncludeVersionInfo"
  EndIf
  
  ; add the version info, even in the disabled state
  For i = 0 To 23
    If *Target\VersionField$[i] <> "" And IsCodeFile
      NbLines + 1
      ConfigLines$(NbLines) = "VersionField"+Str(i)+" = " + *Target\VersionField$[i]
    EndIf
  Next i
  
  ; Note: All entries with a variable number of lines follow here, we must
  ;       ensure that the array is not too small for these (sanity check, as its user input)
  
  If *Target\Watchlist$ <> "" And NbLines < #MAX_ConfigLines And IsCodeFile
    NbLines + 1
    ConfigLines$(NbLines) = "Watchlist = "
    
    index = 1
    While StringField(*Target\Watchlist$, index, ";") <> ""
      If Len(ConfigLines$(NbLines)) > 80 And NbLines < #MAX_ConfigLines ; break the line at 80 chars (or a little over that at least)
        ConfigLines$(NbLines) = Left(ConfigLines$(NbLines), Len(ConfigLines$(NbLines))-1) ; cut the last ";"
        NbLines + 1
        ConfigLines$(NbLines) = "Watchlist = "
      EndIf
      
      ConfigLines$(NbLines) + StringField(*Target\Watchlist$, index, ";") + ";"
      index + 1
    Wend
    
    ConfigLines$(NbLines) = Left(ConfigLines$(NbLines), Len(ConfigLines$(NbLines))-1) ; cut the last ";"
  EndIf
  
  If *Target\NbResourceFiles > 0 And IsCodeFile
    For i = 0 To *Target\NbResourceFiles-1
      If NbLines < #MAX_ConfigLines
        NbLines + 1
        ConfigLines$(NbLines) = "AddResource = "+*Target\ResourceFiles$[i]
      EndIf
    Next i
  EndIf
  
  If IsTempFile = 0 And *Source
    ForEach *Source\UnknownIDEOptionsList$()
      If NbLines < #MAX_ConfigLines
        NbLines + 1
        Configlines$(NbLines) = *Source\UnknownIDEOptionsList$()
      EndIf
    Next
  EndIf
  
  
  ; save the config lines now
  ;
  If SaveProjectSettings = #SAVESETTINGS_EndOfFile Or IsTempFile ; in source file
    
    If *Source
      If *Source\NewLineType = 0
        NewLine$ = Chr(13) + Chr(10)
      ElseIf *Source\NewLineType = 1
        NewLine$ = Chr(10)
      Else
        NewLine$ = Chr(13)
      EndIf
    Else
      NewLine$ = #NewLine
    EndIf
    
    For i = 1 To NbLines
      If *Source And *Source\Parser\Encoding = 0 ; ASCII
        WriteString(#FILE_SaveSource, NewLine$ + "; " + ConfigLines$(i), #PB_Ascii)
      Else
        WriteString(#FILE_SaveSource, NewLine$ + "; " + ConfigLines$(i), #PB_UTF8)
      EndIf
    Next i
    
  ElseIf *Source And SaveProjectSettings = #SAVESETTINGS_PerFileCfg ; save in "filename.pb.cfg"
    If CreateFile(#FILE_SaveConfig, *Source\FileName$+".cfg")
      For i = 1 To NbLines
        WriteStringN(#FILE_SaveConfig, ConfigLines$(i))
      Next i
      CloseFile(#FILE_SaveConfig)
    ElseIf ReportErrors
      MessageRequester(#ProductName$, Language("FileStuff","SaveConfigError")+":"+#NewLine+*Source\FileName$+".cfg", #FLAG_Error)
    EndIf
    
  ElseIf *Source And  SaveProjectSettings = #SAVESETTINGS_PerFolderCfg ; save in "project.cfg"
    If CreateFile(#FILE_SaveConfig, GetPathPart(*Source\FileName$)+"project.cfg.new")
      If ReadFile(#FILE_ReadConfig, GetPathPart(*Source\FileName$)+"project.cfg")
        While Eof(#FILE_ReadConfig) = 0
          Line$ = ReadString(#FILE_ReadConfig)
          
          If UCase(Trim(Line$)) = "["+UCase(GetFilePart(*Source\FileName$))+"]"  ; cut out the old file config
            While Eof(#FILE_ReadConfig) = 0
              Line$ = ReadString(#FILE_ReadConfig)
              If Left(LTrim(Line$), 1) = "["
                WriteStringN(#FILE_SaveConfig, "")
                WriteStringN(#FILE_SaveConfig, Line$)
                Break
              EndIf
            Wend
          ElseIf Line$ <> ""
            WriteStringN(#FILE_SaveConfig, Line$)
          EndIf
        Wend
        CloseFile(#FILE_ReadConfig)
      EndIf
      
      WriteStringN(#FILE_SaveConfig, "[" + GetFilePart(*Source\FileName$) + "]")
      For i = 1 To NbLines-1
        Debug ConfigLines$(i)
        WriteStringN(#FILE_SaveConfig, "  "+ConfigLines$(i))
      Next i
      WriteString(#FILE_SaveConfig, "  "+ConfigLines$(NbLines))  ; no newline at the end of the file
      
      CloseFile(#FILE_SaveConfig)
      
      DeleteFile(GetPathPart(*Source\FileName$)+"project.cfg")
      If FileSize(GetPathPart(*Source\FileName$)+"project.cfg") >= 0
        If ReportErrors
          MessageRequester(#ProductName$, Language("FileStuff","SaveConfigError")+":"+#NewLine+GetPathPart(*Source\FileName$)+"project.cfg", #FLAG_Error)
        EndIf
      ElseIf RenameFile(GetPathPart(*Source\FileName$)+"project.cfg.new", GetPathPart(*Source\FileName$)+"project.cfg") = 0
        If ReportErrors
          MessageRequester(#ProductName$, Language("FileStuff","SaveConfigError")+":"+#NewLine+GetPathPart(*Source\FileName$)+"project.cfg", #FLAG_Error)
        EndIf
      EndIf
    ElseIf ReportErrors
      MessageRequester(#ProductName$, Language("FileStuff","SaveConfigError")+":"+#NewLine+GetPathPart(*Source\FileName$)+"project.cfg.new", #FLAG_Error)
    EndIf
    
  EndIf
  
EndProcedure

; Handles source files with *old* settings format
;
Procedure AnalyzeSettings_Old(*Source.SourceFile, *Buffer, Length)
  ExecutableFormat$   = "WINDOWS"
  
  *Cursor.Ascii = *Buffer+Length
  Found        = 0
  
  If Length > 0
    While *Cursor >= *Buffer
      
      *LastPointer = *Cursor
      
      While *Cursor >= *Buffer And *Cursor\a <> 10
        *Cursor-1
      Wend
      
      If *Cursor >= *Buffer
        Line$ = PeekS(*Cursor+1, *LastPointer - *Cursor, #PB_Ascii)
        
        If Line$ = "; EOF" : Found = 1
        ElseIf Line$ =          "; EnableAsm"         : Found = 1 : *Source\EnableASM = 1
        ElseIf Line$ =          "; EnableXP"          : Found = 1 : *Source\EnableXP  = 1
        ElseIf Line$ =          "; EnableWayland"     : Found = 1 : *Source\EnableWayland = 1
        ElseIf Line$ =          "; EnableOnError"     : Found = 1 : *Source\EnableOnError = 1
        ElseIf Line$ =          "; DisableDebugger"   : Found = 1 : *Source\Debugger  = 0
        ElseIf Left(Line$,13) = "; Executable="       : Found = 1 : *Source\ExecutableName$   = Right(Line$, Len(Line$)-13)
        ElseIf Left(Line$,19) = "; ExecutableFormat=" : Found = 1 : ExecutableFormat$         = Right(Line$, Len(Line$)-19)
        ElseIf Left(Line$,14) = "; CommandLine="      : Found = 1 : *Source\CommandLine$      = Right(Line$, Len(Line$)-14)
        ElseIf Left(Line$,10) = "; UseIcon="          : Found = 1 : *Source\UseIcon = 1     : *Source\IconName$ = Right(Line$, Len(Line$)-10)
        ElseIf Left(Line$,14) = "; UseMainFile="      : Found = 1 : *Source\UseMainFile = 1 : *Source\MainFile$ = Right(Line$, Len(Line$)-14)
        ElseIf Left(Line$,6)  = "; CPU="              : Found = 1 : *Source\CPU               = Val(Right(Line$, Len(Line$)-6 ))
        ElseIf Left(line$,17) = "; CursorPosition="   : Found = 1 : Loading_CurrentLine       = Val(Right(line$, Len(line$)-17)) + 1
        ElseIf Left(line$,12) = "; FirstLine="        : Found = 1 : Loading_FirstVisibleLine  = Val(Right(line$, Len(line$)-12))
        ElseIf Left(line$,12) = "; SubSystem="        : Found = 1 : *Source\SubSystem$        = Right(Line$, Len(Line$)-12)
        ElseIf Left(line$,10) = "; Folding="          : Found = 1 : Loading_FoldingState$             = Right(Line$, Len(Line$)-10)
        Else: Break
        EndIf
        
        *Cursor - 1
        If *Cursor >= *Buffer And *Cursor\a = 13
          *Cursor - 1
        EndIf
      EndIf
    Wend
  EndIf
  
  Select ExecutableFormat$
    Case "Windows"   : *Source\ExecutableFormat = 0
    Case "Linux"     : *Source\ExecutableFormat = 0
    Case "MacOS"     : *Source\ExecutableFormat = 0
    Case "Console"   : *Source\ExecutableFormat = 1
    Case "Shared Dll": *Source\ExecutableFormat = 2
  EndSelect
  
  If Found
    IsIDEConfigPresent = 1 ; we found settings (but from the old IDE), so use the standards for the options that are new
    *Source\SubSystem$       = OptionSubSystem$
    *Source\ErrorLog         = OptionErrorLog
    
    PokeB(*LastPointer+1, 0) ; 0-terminate the buffer
    ProcedureReturn *LastPointer - *Buffer + 1; cut the settings, return new length
    
  Else
    ProcedureReturn Length ; return full buffer length, nothing should be cut
  EndIf
EndProcedure

Procedure AnalyzeSettings_Common(*Source.SourceFile, NbLines)  ; analyze the ConfigLines$ array
  ExecutableFormat$   = ""
  MarkerLines$ = ""
  
  *Source\NbResourceFiles = 0
  
  ; These configs are enabled by default, so if not present, should be 0
  *Source\EnableXP      = 0
  *Source\DPIAware      = 0
  *Source\DllProtection = 0
  *Source\SharedUCRT    = 0
  *Source\EnableWayland = 0
  
  ClearList(*Source\UnknownIDEOptionsList$())
  
  *Source\VersionInfo = 0
  For i = 0 To 15
    *Source\VersionField$[i] = ""
  Next i
  
  *Source\Watchlist$ = ""
  
  *Source\NbConstants = 0
  For i = 0 To #MAX_Constants-1
    *Source\Constant$[i] = ""
    *Source\ConstantEnabled[i] = 0
  Next i
  
  For i = 1 To NbLines
    index = FindString(ConfigLines$(i), "=", 1)
    If index = 0
      Name$  = ConfigLines$(i)
      Value$ = ""
    Else
      Name$  = Left(ConfigLines$(i), index-1)
      Value$ = Right(ConfigLines$(i), Len(ConfigLines$(i))-index)
    EndIf
    Name$ = Trim(RemoveString(UCase(Name$), Chr(9)))
    Value$ = Trim(RemoveString(Value$, Chr(9)))
    
    Select Name$
      Case "IDE OPTIONS"
        ; ok, by this string we know that the options come from the IDE
        IsIDEConfigPresent = 1
        
        CompilerIf #SpiderBasic
        Case "WEBSERVERADDRESS"     : *Source\WebServerAddress$ = Value$
        Case "WINDOWTHEME"          : *Source\WindowTheme$ = Value$
        Case "GADGETTHEME"          : *Source\GadgetTheme$ = Value$
          
        Case "OPTIMIZEJS"           : *Source\Optimizer = 1 ; Backward compatibility with older sources (now named "Optimizer")
        Case "WEBAPPNAME"           : *Source\WebAppName$ = Value$
        Case "WEBAPPICON"           : *Source\WebAppIcon$ = Value$
        Case "HTMLFILENAME"         : *Source\HtmlFilename$ = Value$
        Case "JAVASCRIPTFILENAME"   : *Source\JavaScriptFilename$ = Value$
        Case "JAVASCRIPTPATH"       : *Source\JavaScriptPath$ = Value$
        Case "COPYJAVASCRIPTLIBRARY": *Source\CopyJavaScriptLibrary = 1
        Case "EXPORTCOMMANDLINE"    : *Source\ExportCommandLine$ = Value$
        Case "EXPORTARGUMENTS"      : *Source\ExportArguments$ = Value$
        Case "RESOURCEDIRECTORY"    : *Source\ResourceDirectory$ = Value$
        Case "ENABLERESOURCEDIRECTORY": *Source\EnableResourceDirectory = 1
        Case "WEBAPPENABLEDEBUGGER" : *Source\WebAppEnableDebugger = 1
          
        Case "IOSAPPNAME"         : *Source\iOSAppName$ = Value$
        Case "IOSAPPICON"         : *Source\iOSAppIcon$ = Value$
        Case "IOSAPPVERSION"      : *Source\iOSAppVersion$ = Value$
        Case "IOSAPPPACKAGEID"    : *Source\iOSAppPackageID$ = Value$
        Case "IOSAPPSTARTUPIMAGE" : *Source\iOSAppStartupImage$ = Value$
        Case "IOSAPPOUTPUT"       : *Source\iOSAppOutput$ = Value$
        Case "IOSAPPORIENTATION"  : *Source\iOSAppOrientation = Val(Value$)
        Case "IOSAPPFULLSCREEN"   : *Source\iOSAppFullScreen = 1
        Case "IOSAPPAUTOUPLOAD"   : *Source\iOSAppAutoUpload = 1
        Case "IOSAPPRESOURCEDIRECTORY"      : *Source\iOSAppResourceDirectory$ = Value$
        Case "IOSAPPENABLERESOURCEDIRECTORY": *Source\iOSAppEnableResourceDirectory = 1
        Case "IOSAPPENABLEDEBUGGER" : *Source\iOSAppEnableDebugger = 1
        Case "IOSAPPKEEPAPPDIRECTORY" : *Source\iOSAppKeepAppDirectory = 1
          
        Case "ANDROIDAPPNAME"         : *Source\AndroidAppName$ = Value$
        Case "ANDROIDAPPICON"         : *Source\AndroidAppIcon$ = Value$
        Case "ANDROIDAPPVERSION"      : *Source\AndroidAppVersion$ = Value$
        Case "ANDROIDAPPCODE"         : *Source\AndroidAppCode = Val(Value$)
        Case "ANDROIDAPPPACKAGEID"    : *Source\AndroidAppPackageID$ = Value$
        Case "ANDROIDAPPIAPKEY"       : *Source\AndroidAppIAPKey$ = Value$
        Case "ANDROIDAPPSTARTUPIMAGE" : *Source\AndroidAppStartupImage$ = Value$
        Case "ANDROIDAPPSTARTUPCOLOR" : *Source\AndroidAppStartupColor$ = Value$
        Case "ANDROIDAPPOUTPUT"       : *Source\AndroidAppOutput$ = Value$
        Case "ANDROIDAPPORIENTATION"  : *Source\AndroidAppOrientation = Val(Value$)
        Case "ANDROIDAPPFULLSCREEN"   : *Source\AndroidAppFullScreen = 1
        Case "ANDROIDAPPAUTOUPLOAD"   : *Source\AndroidAppAutoUpload = 1
        Case "ANDROIDAPPRESOURCEDIRECTORY"      : *Source\AndroidAppResourceDirectory$ = Value$
        Case "ANDROIDAPPENABLERESOURCEDIRECTORY": *Source\AndroidAppEnableResourceDirectory = 1
        Case "ANDROIDAPPENABLEDEBUGGER" : *Source\AndroidAppEnableDebugger = 1
        Case "ANDROIDAPPKEEPAPPDIRECTORY" : *Source\AndroidAppKeepAppDirectory = 1
        Case "ANDROIDAPPINSECUREFILEMODE" : *Source\AndroidAppInsecureFileMode = 1
          
      CompilerEndIf
        
      Case "OPTIMIZER":        *Source\Optimizer = 1
      Case "ENABLEASM":        *Source\EnableASM = 1
      Case "ENABLEXP":         *Source\EnableXP = 1
      Case "ENABLEWAYLAND":    *Source\EnableWayland = 1
      Case "ENABLEADMIN":      *Source\EnableAdmin = 1
      Case "ENABLEUSER":       *Source\EnableUser = 1
      Case "DPIAWARE":         *Source\DPIAware = 1
      Case "DLLPROTECTION":    *Source\DllProtection = 1
      Case "SHAREDUCRT":       *Source\SharedUCRT = 1
      Case "ENABLETHREAD":     *Source\EnableThread = 1
      Case "ENABLEONERROR":    *Source\EnableOnError = 1
      Case "DISABLEDEBUGGER":  *Source\Debugger = 0
      Case "HIDEERRORLOG":     *Source\ErrorLog = 0
      Case "EXECUTABLE":       *Source\ExecutableName$ = ResolveRelativePath(GetPathPart(*Source\FileName$), Value$)
      Case "EXECUTABLEFORMAT": ExecutableFormat$ = Value$
      Case "COMMANDLINE":      *Source\CommandLine$ = Value$
      Case "USEICON":          *Source\UseIcon = 1: *Source\IconName$ = Value$
      Case "USEMAINFILE":      *Source\UseMainFile = 1: *Source\MainFile$ = Value$
      Case "CPU":              *Source\CPU = Val(Value$)
      Case "CURSORPOSITION":   Loading_CurrentLine = Val(Value$)
      Case "CURSORCOLUMN":     Loading_CurrentColumn = Val(Value$) ; this is for tempfiles only
      Case "FIRSTLINE":        Loading_FirstVisibleLine = Val(Value$)
      Case "SUBSYSTEM":        *Source\SubSystem$ = Value$
      Case "FOLDING":          Loading_FoldingState$ = Value$
      Case "INCLUDEVERSIONINFO": *Source\VersionInfo = 1
      Case "MARKERS":          MarkerLines$ = RemoveString(Value$, " ") ; also remove spaces inbetreen (not like trim)
      Case "LINKEROPTIONS":    *Source\LinkerOptions$ = Value$
      Case "CURRENTDIRECTORY": *Source\CurrentDirectory$ = Value$
      Case "COMPILESOURCEDIRECTORY": *Source\TemporaryExePlace = 1
      Case "ENABLEDTOOLS":     *Source\EnabledTools$ = UCase(RemoveString(Value$, " ")) ; enforce our format for better searches later
      Case "ENABLEEXECONSTANT":*Source\UseCreateExe = 1
        
      Case "COMPILER"
        *Source\CustomCompiler   = #True
        *Source\CompilerVersion$ = Value$
        
      Case "ENABLECOMPILECOUNT"
        *Source\UseCompileCount = 1
        *Source\CompileCount = Val(Value$)
        
      Case "DISABLECOMPILECOUNT"
        *Source\UseCompileCount = 0
        *Source\CompileCount = Val(Value$)
        
      Case "ENABLEBUILDCOUNT"
        *Source\UseBuildCount = 1
        *Source\BuildCount = Val(Value$)
        
      Case "DISABLEBUILDCOUNT"
        *Source\UseBuildCount = 0
        *Source\BuildCount = Val(Value$)
        
      Case "DEBUGGER"
        *Source\CustomDebugger = 1
        Select UCase(Value$)
          Case "IDE"       : *Source\DebuggerType = 1
          Case "STANDALONE": *Source\DebuggerType = 2
          Case "CONSOLE"   : *Source\DebuggerType = 3
          Default          : *Source\DebuggerType = 1
        EndSelect
        
        ;           CompilerIf #CompileMac ; OSX-debug
        ;             If *Source\DebuggerType > 1
        ;               *Source\DebuggerType - 1
        ;             EndIf
        ;           CompilerEndIf
        
      Case "WARNINGS"
        *Source\CustomWarning = 1
        Select UCase(Value$)
          Case "IGNORE" : *Source\WarningMode = 0
          Case "DISPLAY": *Source\WarningMode = 1
          Case "ERROR"  : *Source\WarningMode = 2
          Default       : *Source\WarningMode = 1
        EndSelect
        
      Case "ENABLEPURIFIER"
        *Source\EnablePurifier = 1
        *Source\PurifierGranularity$ = Value$
        
      Case "DISABLEPURIFIER"
        *Source\EnablePurifier = 0
        *Source\PurifierGranularity$ = Value$
        
      Case "CONSTANT"
        *Source\Constant$[*Source\NbConstants] = Value$
        *Source\ConstantEnabled[*Source\NbConstants] = #True
        *Source\NbConstants + 1
        
      Case "CONSTANTOFF"
        *Source\Constant$[*Source\NbConstants] = Value$
        *Source\ConstantEnabled[*Source\NbConstants] = #False
        *Source\NbConstants + 1
        
      Case "ADDRESOURCE"
        If *Source\NbResourceFiles < #MAX_ResourceFiles
          *Source\ResourceFiles$[*Source\NbResourceFiles] = Value$
          *Source\NbResourceFiles + 1
        EndIf
        
      Case "WATCHLIST": ; this can appear multiple time (to not have too long source lines)
        If *Source\Watchlist$ <> ""
          *Source\Watchlist$ + ";" ; add a separator between the lines
        EndIf
        *Source\Watchlist$ + RemoveString(Value$, " ") ; remove any spaces
        
      Case "" ; Ignore empty lines
        
      Case "FOLDLINES"
        ; from jaPBe.. must be deleted, because jaPBe will get in trouble
        ; if the source is modified without properly updating these!
        
      Default
        If Left(Name$, 12) = "VERSIONFIELD"
          fieldnr = Val(Right(Name$, Len(Name$)-12))
          If fieldnr >= 0 And fieldnr <= 23
            *Source\VersionField$[fieldnr] = Value$
          EndIf
        Else
          ; unknown setting.. save this
          AddElement(*Source\UnknownIDEOptionsList$())
          *Source\UnknownIDEOptionsList$() = Trim(ConfigLines$(i))
        EndIf
        
    EndSelect
  Next i
  
  ; The options are read from bottom to top, so reverse this list so it
  ; looks right in the IDE again
  ;
  If *Source\NbConstants > 0
    For i = 0 To Int(*Source\NbConstants/2)-1
      Swap *Source\Constant$[i], *Source\Constant$[*Source\NbConstants-i-1]
      Swap *Source\ConstantEnabled[i], *Source\ConstantEnabled[*Source\NbConstants-i-1]
    Next i
  EndIf
  
  Select UCase(ExecutableFormat$)
    Case "CONSOLE"
      *Source\ExecutableFormat = 1
      
    Case "SHARED DLL", "SHARED .SO", "SHARED .DYLIB"
      *Source\ExecutableFormat = 2
      
    Default
      *Source\ExecutableFormat = 0 ; Default to executable
  EndSelect
  
EndProcedure

Procedure AnalyzeSettings_SourceFile(*Source.SourceFile, *Buffer, Length)
  
  *Cursor.Ascii = *Buffer+Length
  NbLines = 0
  
  OptionsFound = 0
  
  If Length > 0
    While *Cursor >= *Buffer
      
      *LastPointer = *Cursor
      
      While *Cursor >= *Buffer And (*Cursor\a <> 10 And *Cursor\a <> 13)
        *Cursor-1
      Wend
      
      If *Cursor >= *Buffer
        If *Source\Parser\Encoding = 1 ; UTF8
          Line$ = LTrim(PeekS(*Cursor+1, *LastPointer-*Cursor, #PB_UTF8 | #PB_ByteLength))
        Else ; Ascii
          Line$ = LTrim(PeekS(*Cursor+1, *LastPointer-*Cursor, #PB_Ascii))
        EndIf
        
        If Line$ = "" ; ignore empty lines
        ElseIf Left(Line$, 13) = "; IDE Options"  ; marks the beginning of the block
          *Cursor - 1
          If *Cursor >= *Buffer And (*Cursor\a = 13 Or *Cursor\a = 10)
            *Cursor - 1
          EndIf
          *LastPointer = *Cursor
          
          ; add this line too (important so the NbLines count is not zero even though something was found)
          NbLines + 1
          ConfigLines$(NbLines) = Right(Line$, Len(Line$)-1)
          
          OptionsFound = 1 ; only cut the options of this is found!
          
          Break
        ElseIf Left(Line$, 1) = ";" And NbLines < #MAX_ConfigLines
          NbLines + 1
          ConfigLines$(NbLines) = Right(Line$, Len(Line$)-1)
        Else
          Break
        EndIf
        
        *Cursor - 1
        If *Cursor >= *Buffer And (*Cursor\a = 13 Or *Cursor\a = 10)
          *Cursor - 1
        EndIf
      EndIf
    Wend
  EndIf
  
  If NbLines > 0 And OptionsFound
    AnalyzeSettings_Common(*Source, NbLines)
    PokeA(*LastPointer+1, 0) ; 0-terminate the buffer
    ProcedureReturn *LastPointer - *Buffer + 1; cut the settings, return new length
  Else
    ProcedureReturn Length
  EndIf
EndProcedure

Procedure AnalyzeSettings_ConfigFile(*Source.SourceFile)
  
  If ReadFile(#FILE_ReadConfig, *Source\FileName$ + ".cfg")
    NbLines = 0
    While Eof(#FILE_ReadConfig) = 0 And NbLines < #MAX_ConfigLines
      NbLines + 1
      ConfigLines$(NbLines) = ReadString(#FILE_ReadConfig)
    Wend
    CloseFile(#FILE_ReadConfig)
    
    If NbLines = 0
      ProcedureReturn 0
    Else
      AnalyzeSettings_Common(*Source, NbLines)
      ProcedureReturn 1
    EndIf
  Else
    ProcedureReturn 0
  EndIf
  
EndProcedure

Procedure AnalyzeSettings_ProjectFile(*Source.SourceFile)
  
  If ReadFile(#FILE_ReadConfig, GetPathPart(*Source\FileName$) + "project.cfg")
    NbLines = 0
    While Eof(#FILE_ReadConfig) = 0
      Line$ = ReadString(#FILE_ReadConfig)
      
      If UCase(Trim(Line$)) = "[" + UCase(GetFilePart(*Source\FileName$)) + "]"  ; found the config
        While Eof(#FILE_ReadConfig) = 0
          Line$ = ReadString(#FILE_ReadConfig)
          
          If Left(LTrim(Line$), 1) = "["
            Break
          EndIf
          
          If NbLines < #MAX_ConfigLines
            NbLines + 1
            Configlines$(NbLines) = Line$
          Else
            Break
          EndIf
        Wend
        
        Break
      EndIf
    Wend
    CloseFile(#FILE_ReadConfig)
    
    If NbLines = 0
      ProcedureReturn 0
    Else
      AnalyzeSettings_Common(*Source, NbLines)
      ProcedureReturn 1
    EndIf
  Else
    ProcedureReturn 0
  EndIf
  
EndProcedure

Procedure AnalyzeProjectSettings(*Source.SourceFile, *Buffer, Length, IsTempFile)
  
  
  If SaveProjectSettings = #SAVESETTINGS_DoNotSave And IsTempFile = 0 ; don't save anything
    ProcedureReturn Length
  EndIf
  
  If IsTempFile = 0
    *Source\Debugger      = 1          ; default if the option isn't found
    *Source\ErrorLog      = 1
    *Source\EnableASM     = 0
    *Source\EnableThread  = 0
    *Source\EnableXP      = 1
    *Source\EnableWayland = 0
    *Source\EnableAdmin   = 0
    *Source\EnableUser    = 0
    *Source\DPIAware      = 1
    *Source\DllProtection = 0
    *Source\SharedUCRT    = 0
    *Source\EnableOnError = 0
    *Source\VersionInfo   = 0
    *Source\ErrorLog      = 1
    *Source\NbConstants   = 0
    *Source\LastCompiledLines = 0
    *Source\CustomDebugger= 0
    *Source\DebuggerType  = 1
    *Source\CustomWarning = 0
    *Source\WarningMode   = 1
    *Source\CustomCompiler= 0
    *Source\EnablePurifier = 0
    *Source\PurifierGranularity$ = ""
  EndIf
  
  Loading_FirstVisibleLine = 0
  Loading_CurrentLine      = 0
  Loading_CurrentColumn    = 0
  Loading_FoldingState$    = ""
  
  IsIDEConfigPresent = 0
  ReturnValue = Length
  
  ; old type source file
  ;
  If Length > 20 And FindMemoryString(*Buffer+Length-20, 20, "; EOF", 1)
    ReturnValue = AnalyzeSettings_Old(*Source, *Buffer, Length)
  Else
    
    If IsTempFile ; for temp file, it is only inside the current source.
      ReturnValue = AnalyzeSettings_SourceFile(*Source, *Buffer, Length)
      
    ElseIf SaveProjectSettings = #SAVESETTINGS_EndOfFile
      Result = AnalyzeSettings_SourceFile(*Source, *Buffer, Length)
      If Result < Length ; settings were found
        ReturnValue = Result
      ElseIf AnalyzeSettings_ConfigFile(*Source)  ; found in filename.pb.cfg
        ReturnValue = Length
      Else
        AnalyzeSettings_ProjectFile(*Source)  ; check common config file
        ReturnValue = Length
      EndIf
      
    ElseIf SaveProjectSettings = #SAVESETTINGS_PerFileCfg
      If AnalyzeSettings_ConfigFile(*Source)
        ReturnValue = Length
      ElseIf AnalyzeSettings_ProjectFile(*Source)
        ReturnValue = Length
       Else
        ReturnValue = AnalyzeSettings_SourceFile(*Source, *Buffer, Length)
      EndIf
      
    ElseIf SaveProjectSettings = #SAVESETTINGS_PerFolderCfg
      If AnalyzeSettings_ProjectFile(*Source)
        ReturnValue = Length
      ElseIf AnalyzeSettings_ConfigFile(*Source)
        ReturnValue = Length
      Else
        ReturnValue = AnalyzeSettings_SourceFile(*Source, *Buffer, Length)
      EndIf
      
    EndIf
    
  EndIf
  
  ; if no config options are found, then use the defaults
  If IsIDEConfigPresent = 0
    SetCompileTargetDefaults(*Source) ; set the default values
    *Source\ErrorLog = OptionErrorLog
  EndIf
  
  ProcedureReturn ReturnValue
  
EndProcedure


Procedure FindSourceFile(FileName$)
  
  ForEach FileList()
    If @FileList() <> *ProjectInfo And IsEqualFile(FileName$, FileList()\FileName$)
      ProcedureReturn @FileList()
    EndIf
  Next FileList()
  
EndProcedure

Procedure LoadSourceFile(FileName$, Activate = 1, AddToRecentFiles = 1)
  success = 0
  
  ; Check if this is a project file
  ;
  If IsProjectFile(FileName$)
    LoadProject(FileName$)
    ProcedureReturn 0
  EndIf
  
  ; check if the source is already opened...
  ;
  If FindSourceFile(FileName$)
    If Activate
      ChangeActiveSourcecode()
      ChangeStatus("", 0)
    EndIf
    ProcedureReturn 1
  EndIf
  
  ; Check if this is a form (file extension only for now)
  ; NOTE: it needs to be after the already opened check !
  If LCase(GetExtensionPart(FileName$)) = "pbf"
    
    If FD_VersionCheck(FileName$) = #PB_MessageRequester_No
      ProcedureReturn 0
    EndIf

    OpenForm(FileName$)
    RecentFiles_AddFile(FileName$, #False)
    AddTools_Execute(#TRIGGER_SourceLoad, *ActiveSource)
    LinkSourceToProject(*ActiveSource) ; Link To project (If any)
    ProcedureReturn 1
    
  EndIf
  
  ; reset the current source
  If *ActiveSource
    ChangeCurrentElement(FileList(), *ActiveSource)
  EndIf
  
  ChangeStatus(Language("FileStuff","StatusLoading"), -1)
  
  If ReadFile(#FILE_LoadSource, FileName$)
    ; try to detect the encoding first
    Format = ReadStringFormat(#FILE_LoadSource)
    FileLength = Lof(#FILE_LoadSource)-Loc(#FILE_LoadSource) ; subtract the BOM size!
    
    If *ActiveSource And *ActiveSource\FileName$ = "" And GetSourceModified() = 0 And (ListSize(FileList()) = 1 Or (IsProject And ListSize(FileList()) = 2))
      *EmptySource = *ActiveSource
    EndIf
    
    If FileLength > 0
      *Buffer = AllocateMemory(FileLength+1)
    Else
      NewSource(FileName$, #False) ; absolutely empty file
    EndIf
    
    If *Buffer
      ReadData(#FILE_LoadSource, *Buffer, FileLength)
      
      ; Don't check PB sources, as it can contains weird characters well handled by Scintilla: https://www.purebasic.fr/english/viewtopic.php?f=4&t=61467
      ;
      If IsPureBasicFile(FileName$) = #False
        IsBinary = IsBinaryFile(*Buffer, FileLength)
      
        ;first check for OpenFile-Triggers
        If IsCodeFile(FileName$) = 0 ;exclude all code files, even those the user added
          AddTools_RunFileViewer = 1 ; to check if some tool has been executed
          AddTools_File$ = FileName$
          Ext$ = LCase(GetExtensionPart(FileName$))
          CloseFile(#FILE_LoadSource) ;better close the file here, or the tools might have problems to access it
          AddTools_Execute(#TRIGGER_OpenFile_Special, 0) ; special open file tools have highest priority
          If AddTools_RunFileViewer
            Select IsBinary
              Case 0
                AddTools_Execute(#TRIGGER_OpenFile_nonPB_Text, 0)
              Case 1
                AddTools_Execute(#TRIGGER_OpenFile_nonPB_Binary, 0)
            EndSelect
          EndIf
          If AddTools_RunFileViewer = 0
            FreeMemory(*Buffer)
            ChangeStatus("", 0)
            ProcedureReturn 1
          EndIf
        EndIf
        ;now check for common FileViewer tools
        ;common FileViewer tools, will only trigger for binary files and non-PB files with an unknown BOM
        If IsBinary Or (Format <> #PB_Ascii And Format <> #PB_UTF8)
          FreeMemory(*Buffer)
          If IsFile(#FILE_LoadSource)
            CloseFile(#FILE_LoadSource)
          EndIf
          ChangeStatus("", 0)
          FileViewer_OpenFile(Filename$)
          ProcedureReturn 1
        EndIf
      EndIf
      
      
      NewSource(FileName$, #False)
      
      If Format = #PB_Ascii
        *ActiveSource\Parser\Encoding = 0
        SendEditorMessage(#SCI_SETCODEPAGE, 0, 0)
      Else
        *ActiveSource\Parser\Encoding = 1
        SendEditorMessage(#SCI_SETCODEPAGE, #SC_CP_UTF8, 0)
      EndIf
      
      ; always call ChangeNewLineType(), even if the detected one is the os one,
      ; because if the type can't be detected, the os standard is returned!
      ;
      *ActiveSource\NewLineType = DetectNewLineType(*Buffer, FileLength)
      ChangeNewLineType(@*Buffer, @FileLength, #DEFAULT_NewLineType)
      
      FileLength = AnalyzeProjectSettings(*ActiveSource, *Buffer, FileLength, 0); get the settings and cut them off
      
      StreamTextIn(*Buffer, FileLength)
      FreeMemory(*Buffer)
    EndIf
    
    If *Buffer Or FileLength = 0
      ; update the file monitor info
      ; Note that there could be a slight race condition here if the file is modified between loading
      ; and getting this info, but since this is a GUI feature, such things should not be critical
      *ActiveSource\ExistsOnDisk  = #True
      *ActiveSource\LastWriteDate = GetFileDate(*ActiveSource\Filename$, #PB_Date_Modified)
      *ActiveSource\DiskFileSize  = FileSize(*ActiveSource\Filename$)
      DisableDebugger
        *ActiveSource\DiskChecksum  = FileFingerprint(*ActiveSource\Filename$, #PB_Cipher_MD5)
      EnableDebugger
      
      If AddToRecentFiles
        RecentFiles_AddFile(FileName$, #False)
      EndIf
      AddTools_Execute(#TRIGGER_SourceLoad, *ActiveSource)
      FullSourceScan(*ActiveSource)
      UpdateFolding(*ActiveSource, 0, -1)
      UpdateSelectionRepeat()
      
      ; check if the first source was an empty new file and remove that..
      ;
      If *EmptySource
        RemoveSource(*EmptySource)
      EndIf
      
      If EnableFolding
        ApplyFoldingInformation(Loading_FoldingState$)
      EndIf
      
      If MemorizeCursor
        If Loading_FirstVisibleLine > Loading_CurrentLine
          Loading_CurrentLine = Loading_FirstVisibleLine
        EndIf
        
        If Loading_CurrentLine > 0 ; change the line, if it was written in the settings part of the file
          ChangeActiveLine(Loading_CurrentLine+1, Loading_FirstVisibleLine-Loading_CurrentLine-1) ;in the file, line is 0 based! (to support old behaviour)
        EndIf
        
      Else
        ChangeActiveLine(1, 0)
        UpdateCursorPosition()
        
      EndIf
      
      If MemorizeMarkers And MarkerLines$ <> ""
        ApplyMarkerString(MarkerLines$)
      EndIf
      
      ChangeStatus(Language("FileStuff","StatusLoaded"), 1000)
      UpdateSourceStatus(0)
      success = 1
      
      *Debugger.DebuggerData = IsDebuggedFile(*ActiveSource) ; check if this is loaded for the debugger
      If *Debugger And *Debugger\ProgramState <> -1          ; must be a loaded exe!
        SetReadOnly(*ActiveSource\EditorGadget, 1)
        
        ; copy the error log from the file that created the debugger
        ; for project related files, the log is always shared
        ;
        If *ActiveSource\ProjectFile = 0
          
          *Source.SourceFile = FindTargetFromID(*Debugger\SourceID)
          If *Source = 0
            *Source = FindTargetFromID(*Debugger\TriggerTargetID)
          EndIf
          
          If *Source And *Source\IsProject = 0 ; make sure its not a project target (in this case it is not a SourceFile struct at all!)
            *ActiveSource\LogSize = *Source\LogSize
            For i = 0 To *Source\LogSize-1
              *ActiveSource\LogLines$[i] = *Source\LogLines$[i]
            Next i
          EndIf
          
        EndIf
        
      EndIf
      
      ; call this again to update the ErrorLog, ProcedureBrowser etc (and project stuff)
      ChangeActiveSourcecode()
      HistoryEvent(*ActiveSource, #HISTORY_Open)
      
    Else
      MessageRequester(#ProductName$, Language("FileStuff","LoadError")+#NewLine+FileName$, #FLAG_Error)
      ChangeStatus(Language("FileStuff","LoadError"), 3000)
    EndIf
    If IsFile(#FILE_LoadSource)
      CloseFile(#FILE_LoadSource)
    EndIf
  Else
    MessageRequester(#ProductName$, Language("FileStuff","LoadError")+#NewLine+FileName$, #FLAG_Error)
    ChangeStatus(Language("FileStuff","LoadError"), 3000)
  EndIf
  
  ; If the first file can't be opened for any reasons, this pointer will be null
  ;
  If *ActiveSource
    SetActiveGadget(*ActiveSource\EditorGadget)
  EndIf
  
  ProcedureReturn success
EndProcedure


Procedure SaveSourceFile(FileName$)
  
  If *ActiveSource = *ProjectInfo
    ProcedureReturn 0
  EndIf
  
  If *ActiveSource\ProjectFile = 0 And IsWindow(#WINDOW_Option)  ; make sure the options are closed (for non-project files)
    OptionWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If *ActiveSource\IsForm
    FD_SelectWindow(*ActiveSource\IsForm)
    
    If FormWindows()\current_view = 0 ; Design view, we need to use the special form save routine. In code view, we just save the code as any other source
      FD_Save(FileName$)
      AddTools_Execute(#TRIGGER_SourceSave, *ActiveSource)
      ProcedureReturn 1
    EndIf
  EndIf
  
  ChangeStatus(Language("FileStuff","StatusSaving"), -1)
  
  If CreateFile(#FILE_SaveSource, FileName$)
    If *ActiveSource\Parser\Encoding = 0
      WriteStringFormat(#FILE_SaveSource, #PB_Ascii)
    Else
      WriteStringFormat(#FILE_SaveSource, #PB_UTF8)
    EndIf
    
    FileLength = GetSourceLength()
    
    If FileLength > 0
      *Buffer = AllocateMemory(FileLength+1)
    EndIf
    
    If *Buffer
      StreamTextOut(*Buffer, FileLength)
      
      ; set the newline back to what it was before in the file
      ChangeNewLineType(@*Buffer, @FileLength, *ActiveSource\NewLineType)
      
      WriteData(#FILE_SaveSource, *Buffer, FileLength)
      FreeMemory(*Buffer)
    EndIf
    
    If *Buffer Or FileLength = 0
      *ActiveSource\FileName$ = FileName$ ; SaveProjectSettings() needs an updated FileName$ (https://www.purebasic.fr/english/viewtopic.php?f=4&t=59566)
      *ActiveSource\IsCode = IsCodeFile(FileName$)
      
      SaveProjectSettings(*ActiveSource, *ActiveSource\IsCode, 0, 1)
      CloseFile(#FILE_SaveSource)
      
      ; update the file monitor info
      *ActiveSource\ExistsOnDisk  = #True
      *ActiveSource\LastWriteDate = GetFileDate(Filename$, #PB_Date_Modified)
      *ActiveSource\DiskFileSize  = FileSize(Filename$)
      *ActiveSource\DiskChecksum  = FileFingerprint(Filename$, #PB_Cipher_MD5)
      
      ChangeStatus(Language("FileStuff","StatusSaved"), 1000)
      Result = 1
      
      UpdateSourceStatus(0)
      
      RecentFiles_AddFile(FileName$, #False)
      
      AddTools_Execute(#TRIGGER_SourceSave, *ActiveSource)
      
    Else
      CloseFile(#FILE_SaveSource)
      DeleteFile(FileName$)
      MessageRequester(#ProductName$, Language("FileStuff","SaveError")+#NewLine+FileName$, #FLAG_Error)
      ChangeStatus(Language("FileStuff","SaveError"), 3000)
      Result = 0
    EndIf
  Else
    MessageRequester(#ProductName$, Language("FileStuff","SaveError")+#NewLine+FileName$, #FLAG_Error)
    ChangeStatus(Language("FileStuff","SaveError"), 3000)
    Result = 0
  EndIf
  
  SetActiveGadget(*ActiveSource\EditorGadget)
  UpdateMenuStates() ; to notice the change from new file to unsaved file (#MENU_DiffCurrent)
  
  ProcedureReturn Result
  
EndProcedure


Procedure LoadTempFile(FileName$)  ; load the specified file over the current opened source
  
  If *ActiveSource = *ProjectInfo
    ProcedureReturn 0
  EndIf
  
  Success = 0
  
  If ReadFile(#FILE_LoadSource, FileName$)
    Format = ReadStringFormat(#FILE_LoadSource)
    FileLength = Lof(#FILE_LoadSource)-Loc(#FILE_LoadSource) ; subtract the BOM size!
    
    If FileLength > 0
    *Buffer = AllocateMemory(FileLength+1)
  EndIf
    
    If Format = #PB_Ascii
      *ActiveSource\Parser\Encoding = 0
      SendEditorMessage(#SCI_SETCODEPAGE, 0, 0)
    Else
      *ActiveSource\Parser\Encoding = 1
      SendEditorMessage(#SCI_SETCODEPAGE, #SC_CP_UTF8, 0)
    EndIf
    
    If FileLength > 0
      *Buffer = AllocateMemory(FileLength+1)
    Else ; For empty text, we need to clear the scintilla component (https://www.purebasic.fr/english/viewtopic.php?p=615379#p615379)
      StreamTextIn(ToUTF8(""), 0)
    EndIf
    
    If *Buffer
      ReadData(#FILE_LoadSource, *Buffer, FileLength)
      
      ; always call ChangeNewLineType(), even if the detected one is the os one,
      ; because if the type can't be detected, the os standard is returned!
      ;
      ChangeNewLineType(@*Buffer, @FileLength, #DEFAULT_NewLineType)
      
      FileLength = AnalyzeProjectSettings(*ActiveSource, *Buffer, FileLength, 1); get the settings and cut them off
      
      StreamTextIn(*Buffer, FileLength)
      FreeMemory(*Buffer)
    EndIf
    
    If *Buffer Or FileLength = 0
      Success = 1
      ;      HighlightArea(0, -1)
      FullSourceScan(*ActiveSource)
      UpdateFolding(*ActiveSource, 0, -1)
      UpdateSelectionRepeat()
      
      If EnableFolding
        ApplyFoldingInformation(Loading_FoldingState$)
      EndIf
      
      If Loading_FirstVisibleLine > Loading_CurrentLine
        Loading_CurrentLine = Loading_FirstVisibleLine
      EndIf
      
      If Loading_CurrentLine > 0 ; change the line, if it was written in the settings part of the file
        ChangeActiveLine(Loading_CurrentLine+1, Loading_FirstVisibleLine-Loading_CurrentLine-1) ;in the file, line is 0 based! (to support old behaviour)
      EndIf
      
      ; this is only for tempfiles
      If Loading_CurrentColumn > 1
        SendEditorMessage(#SCI_GOTOPOS, SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)+Loading_CurrentColumn-1, 0)
        UpdateCursorPosition()
      EndIf
      
      
      *Debugger.DebuggerData = IsDebuggedFile(*ActiveSource) ; check if this is loaded for the debugger
      If *Debugger And *Debugger\ProgramState <> -1          ; must be a loaded exe!
        SetReadOnly(*ActiveSource\EditorGadget, 1)
        
        ; copy the error log from the file that created the debugger
        ; for project related files, the log is always shared
        ;
        If *ActiveSource\ProjectFile = 0
          
          *Source.SourceFile = FindTargetFromID(*Debugger\SourceID)
          If *Source = 0
            *Source = FindTargetFromID(*Debugger\TriggerTargetID)
          EndIf
          
          If *Source And *Source\IsProject = 0 ; make sure its not a project target (in this case it is not a SourceFile struct at all!)
            *ActiveSource\LogSize = *Source\LogSize
            For i = 0 To *Source\LogSize-1
              *ActiveSource\LogLines$[i] = *Source\LogLines$[i]
            Next i
          EndIf
          
        EndIf
        
      EndIf
      
      
      If MarkerLines$ <> ""
        ApplyMarkerString(MarkerLines$)
      EndIf
      
      ; call this again to update the ErrorLog
      ChangeActiveSourcecode()
      
    EndIf
    
    CloseFile(#FILE_LoadSource)
  EndIf
  
  SetActiveGadget(*ActiveSource\EditorGadget)
  
  ;   CompilerIf #CompileWindows
  ;     InvalidateRect_(WindowID(#WINDOW_Main), 0, 0)
  ;   CompilerEndIf
  
  ProcedureReturn Success
EndProcedure

Procedure SaveTempFile(FileName$)
  
  If *ActiveSource = *ProjectInfo
    ProcedureReturn 0
  EndIf
  
  If CreateFile(#FILE_SaveSource, FileName$)
    If *ActiveSource\Parser\Encoding = 0
      WriteStringFormat(#FILE_SaveSource, #PB_Ascii)
    Else
      WriteStringFormat(#FILE_SaveSource, #PB_UTF8)
    EndIf
    
    FileLength = GetSourceLength()
    
    If FileLength > 0
      *Buffer = AllocateMemory(FileLength+1)
    EndIf
    
    If *Buffer
      StreamTextOut(*Buffer, FileLength)
      
      ; temp files are always in the OS newline format
      ChangeNewLineType(@*Buffer, @FileLength, #DEFAULT_NewLineType)
      
      WriteData(#FILE_SaveSource, *Buffer, FileLength)
      FreeMemory(*Buffer)
    EndIf
    
    If *Buffer Or FileLength = 0
      
      SaveProjectSettings(*ActiveSource, *ActiveSource\IsCode, 1, 0)
      CloseFile(#FILE_SaveSource)
      
      Result = 1
      
    Else
      CloseFile(#FILE_SaveSource)
      DeleteFile(FileName$)
      Result = 0
    EndIf
  Else
    Result = 0
  EndIf
  
  SetActiveGadget(*ActiveSource\EditorGadget)
  
  ProcedureReturn Result
  
EndProcedure


Procedure LoadSource()
  
  If *ActiveSource = *ProjectInfo And IsProject
    Path$ = GetPathPart(ProjectFile$)
  ElseIf *ActiveSource\FileName$
    Path$ = GetPathPart(*ActiveSource\FileName$)
  Else
    Path$ = SourcePath$
  EndIf
  
  FileName$ = OpenFileRequester(Language("FileStuff","OpenFileTitle"), Path$, Language("FileStuff","Pattern"), SelectedFilePattern, #PB_Requester_MultiSelection)
  If FileName$ <> ""
    
    While WindowEvent() : Wend
    
    SelectedFilePattern = SelectedFilePattern()
    
    While FileName$ <> ""
      LoadSourceFile(FileName$)
      
      ; Flush events. So when many sources are opened at once, the User can see a bit the
      ; progress, instead of just an unresponsive window for quite a while.
      ; There is almost no flicker anymore, so it actually looks quite good.
      ;
      ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
      FlushEvents()
      
      FileName$ = NextSelectedFileName()
    Wend
    
  EndIf
  
EndProcedure


Procedure OpenIncludeOnDoubleClick()
  UpdateCursorPosition()
  CurrentWord$ = LCase(GetCurrentWord())
  Line$ = GetCurrentLine()
  
  NameStart = *ActiveSource\CurrentColumnChars
  While ValidCharacters(Asc(Mid(Line$, NameStart, 1))) = 1  ; skip the rest of 'IncludeFile'
    NameStart + 1
  Wend
  
  While Mid(Line$, NameStart, 1) = " " ; skip spaces
    NameStart + 1
  Wend
  
  If Mid(Line$, NameStart, 1) = Chr(34) ; only if it is a literal string.. constants don't work
    NameStart + 1
    NameEnd = NameStart
    
    While Mid(Line$, NameEnd, 1) <> Chr(34) And NameEnd < Len(Line$)
      NameEnd + 1
    Wend
    
    FileName$ = Mid(Line$, NameStart, NameEnd - NameStart)
    FileName$ = ResolveRelativePath(GetPathPart(*ActiveSource\FileName$), FileName$)
    
    If FileSize(FileName$) > -1  ; check if the result is valid..
      
      If CurrentWord$ = "includebinary"
        FileViewer_OpenFile(FileName$)
      Else
        LoadSourceFile(FileName$)
      EndIf
      
    EndIf
    
  EndIf
  
EndProcedure


Procedure SaveSourceAs()
  Static NewSourcePath$
  
  If *ActiveSource = *ProjectInfo
    ProcedureReturn 0
  EndIf
  
  If *ActiveSource\FileName$
    
    ; Uses the full filename as input like other software
    ;
    NewSourcePath$ = *ActiveSource\FileName$
    
  ElseIf NewSourcePath$ = ""
    
    ; if the file was already saved, use its path as a base.
    ;
    NewSourcePath$ = GetPathPart(SourcePath$)
    
  Else
    NewSourcePath$ = GetPathPart(NewSourcePath$) ; New file to save, don't specify a filename
  EndIf
  
  FileName$ = SaveFileRequester(Language("FileStuff","SaveFileTitle"), NewSourcePath$, Language("FileStuff","Pattern"), SelectedFilePattern)
  If FileName$ <> ""
    SelectedFilePattern = SelectedFilePattern()
    NewSourcePath$ = GetPathPart(FileName$)
    
    If GetExtensionPart(GetFilePart(FileName$)) = ""
      If SelectedFilePattern <= 1  ; (=all pb files or pb sources only)
        If *ActiveSource\IsForm
          FileName$ + #FormFileExtension
        Else
          FileName$ + #SourceFileExtension
        EndIf
        ForceFileCheck = 1
      ElseIf SelectedFilePattern = 2 ; (=pbi only)
        FileName$ + #IncludeFileExtension
        ForceFileCheck = 1
      ElseIf SelectedFilePattern = 4 ; (=pbf only)
        FileName$ + #FormFileExtension
        ForceFileCheck = 1
      EndIf
    EndIf
    
    ; Check if file already open in IDE
    *SourceBeingClosed = 0
    ForEach FileList()
      If @FileList() <> *ActiveSource
        If IsEqualFile(FileList()\FileName$, FileName$)
          PromptedUser = 1
          If MessageRequester(#ProductName$, Language("FileStuff","FileIsOpen")+#NewLine+Language("FileStuff","CloseOverWrite"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_Yes
            *SourceBeingClosed = @FileList()
            Break
          Else
            ProcedureReturn SaveSourceAs()  ; try again
          EndIf
        EndIf
      EndIf
    Next
    If *SourceBeingClosed <> 0
      RemoveSource(*SourceBeingClosed)
    EndIf
    
    ; On Cocoa the file exists dialog is already in the SavePanel, so only popup if we added an extension
    ;
    If (ForceFileCheck Or #CompileMacCocoa = 0) And *SourceBeingClosed = 0
      If FileSize(FileName$) > -1 And IsEqualFile(FileName$, *ActiveSource\FileName$) = 0 ; file exist check
        If MessageRequester(#ProductName$, Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_No
          ProcedureReturn SaveSourceAs()  ; try again
        EndIf
      EndIf
    EndIf
    
    Result = SaveSourceFile(FileName$)
    
    If Result
      UnlinkSourceFromProject(*ActiveSource, #True)
      *ActiveSource\FileName$ = FileName$
      LinkSourceToProject(*ActiveSource)
      
      UpdateMainWindowTitle() ; we now have a new filename
      RefreshSourceTitle(*ActiveSource)
      HistoryEvent(*ActiveSource, #HISTORY_SaveAs)
      UpdateIsCodeStatus() ; re-scan/re-highlight in case the IsCode value has changed
    EndIf
    
    ProcedureReturn Result
  Else
    ProcedureReturn -1 ; indicate user abort (needed when called by CheckSourceSaved())
  EndIf
  
EndProcedure

Procedure SaveSource()
  
  If *ActiveSource\FileName$ = ""
    ProcedureReturn SaveSourceAs()
  Else
    Result = SaveSourceFile(*ActiveSource\FileName$)
    If Result
      HistoryEvent(*ActiveSource, #HISTORY_Save)
    EndIf
    ProcedureReturn Result
  EndIf
  
EndProcedure


Procedure RemoveSource(*Source.SourceFile = 0)
  
  FlushEvents()
  
  If *Source = 0
    *Source = *ActiveSource
  EndIf
  
  If *Source = *ProjectInfo
    ProcedureReturn
  EndIf
  
  If *Source = *ActiveSource
    DeleteCurrent = #True
  Else
    DeleteCurrent = #False
  EndIf
  
  HistoryEvent(*Source, #HISTORY_Close)
  
  AddTools_Execute(#TRIGGER_SourceClose, *Source)
  
  ; Make sure the diff window is closed if this source is part of the diff
  ; (because then we loose the source for refreshes, which will crash then)
  If IsWindow(#WINDOW_Diff)
    CheckDiffFileClose(*Source)
  EndIf
  
  If DeleteCurrent And *Source\ProjectFile = 0 And IsWindow(#WINDOW_Option)  ; make sure the options are closed (for non-project files)
    OptionWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  ; disconnect source from the project (if any)
  UnlinkSourceFromProject(*Source, #True)
  
  ; is this the mainfile for a debugger?
  *Debugger = FindDebuggerFromID(*Source\DebuggerID)
  If *Debugger
    Debugger_Kill(*Debugger)
  EndIf
  
  If *Source = *WarningWindowSource   ; Is this the source that caused the Warning window to open ?
    WarningWindowEvents(#PB_Event_CloseWindow) ; will set *WarningWindowSource to 0
  EndIf
  
  Gadget = *Source\EditorGadget
  
  FreeSourceItemArray(@*Source\Parser)
  
  If FileSize(*Source\RunExecutable$) >= 0
    CompilerIf #CompileMac
      DeleteDirectory(*Source\RunExecutable$, "*", #PB_FileSystem_Recursive) ; a .app is a directory!
    CompilerElse
      DeleteFile(*Source\RunExecutable$)
    CompilerEndIf
  EndIf
  
  
  ; Delete form specific data
  If *Source And *Source\IsForm
    If propgrid
      grid_StopEditing(propgrid)
    EndIf
    
    ; Closing a form source and switching to another opened form crashed the IDE with the following lines uncommented
    ChangeCurrentElement(FormWindows(),*Source\IsForm)
    DeleteElement(FormWindows(), #True) ; If the first element is deleted then the second one is selected to still have a current element.
    
    propgrid_gadget = 0
    propgrid_win = 0
    propgrid_menu = 0
    propgrid_toolbar = 0
    propgrid_statusbar = 0
  EndIf
  
  
  If DeleteCurrent
    Index = ListIndex(FileList())
    If Index = 0
      DeleteElement(FileList())
      FirstElement(FileList())
    Else
      DeleteElement(FileList())
    EndIf
    *ActiveSource = 0
  Else
    PushListPosition(FileList())
    ChangeCurrentElement(FileList(), *Source)
    Index = ListIndex(FileList())
    DeleteElement(FileList())
    PopListPosition(FileList())
  EndIf
  
  RemoveTabBarGadgetItem(#GADGET_FilesPanel, Index)
  
  If ListSize(FileList()) = 0 Or (ListSize(FileList()) = 1 And *ProjectInfo)
    NewSource("", #True)
    HistoryEvent(*ActiveSource, #HISTORY_Create)
  EndIf
  
  ChangeActiveSourcecode()
  
  ; make sure the options are closed (for non-project files)
  ; If this is true, we switched from a project file to non-project file while the options
  ; are open. so close them now
  ;
  If *ActiveSource\ProjectFile = 0 And IsWindow(#WINDOW_Option)
    OptionWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  ; Activate the next EditorGadget
  ;
  If *ActiveSource
    SetActiveGadget(*ActiveSource\EditorGadget)
  EndIf
  
  ; Flush events. So when many sources are closed at once, (close all, IDE close) the User can see a bit the
  ; progress, instead of just an unresponsive window for quite a while.
  ; There is almost no flicker anymore, so it actually looks quite good.
  FlushEvents()
  
  ; Remove old EditorGadget
  ; Fix a stack corruption on OSX, needs to be after FlushEvent().
  ; All events must be processed before the EditorGadget is removed.
  FreeEditorGadget(Gadget)
  
EndProcedure

Procedure CheckSourceSaved(*Source.SourceFile = 0)
  
  If *Source = 0
    *Source = *ActiveSource
  EndIf
  
  If *Source = *ProjectInfo
    ProcedureReturn 1
  EndIf
  
  ; Decide if a save prompt is needed
  PromptUser = #False
  If GetSourceModified(*Source)
    If *Source\FileName$ <> ""
      PromptUser = #True
    Else
      ; Only prompt user to save a 'New' source if it's non-empty
      If ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLENGTH) > 0
        PromptUser = #True
      EndIf
    EndIf
  EndIf
  
  If PromptUser
    
    ; need to make it current for display of the question
    If *Source <> *ActiveSource
      ChangeCurrentElement(FileList(), *Source)
      ChangeActiveSourcecode(*ActiveSource)
      FlushEvents()
    EndIf
    
    If *ActiveSource\FileName$ = ""
      Text$ = Language("FileStuff","ModifiedNew")
    Else
      Text$ = LanguagePattern("FileStuff","Modified", "%filename%", GetFilePart(*ActiveSource\FileName$))
    EndIf
    
    Result = MessageRequester(#ProductName$, Text$, #PB_MessageRequester_YesNoCancel|#FLAG_Question)
    
    If Result = #PB_MessageRequester_Yes
      Status = SaveSource()
      If Status = 0 And *ActiveSource\FileName$ <> "" And (SaveProjectSettings = #SAVESETTINGS_PerFileCfg Or SaveProjectSettings = #SAVESETTINGS_PerFolderCfg)
        ; if the compiler options are not stored at the end of the sourcefile,
        ; we save them even if the source is not saved.
        ; Do not report an error though (for example if the source was loaded from CD)
        SaveProjectSettings(*ActiveSource, *ActiveSource\IsCode, 0, 0)
      EndIf
      ProcedureReturn Status
      
    ElseIf Result = #PB_MessageRequester_No
      If *ActiveSource\FileName$ <> "" And (SaveProjectSettings = #SAVESETTINGS_PerFileCfg Or SaveProjectSettings = #SAVESETTINGS_PerFolderCfg)
        ; if the compiler options are not stored at the end of the sourcefile,
        ; we save them even if the source is not saved.
        ; Do not report an error though (for example if the source was loaded from CD)
        SaveProjectSettings(*ActiveSource, *ActiveSource\IsCode, 0, 0)
      EndIf
      ProcedureReturn 1
      
    ElseIf Result = #PB_MessageRequester_Cancel
      ProcedureReturn -1
      
    EndIf
    
  Else
    
    ; Why should we save the setting even if a source a not modified ?
    ;
    If *Source\FileName$ <> "" And (SaveProjectSettings = #SAVESETTINGS_PerFileCfg Or SaveProjectSettings = #SAVESETTINGS_PerFolderCfg)
      ; if the compiler options are not stored at the end of the sourcefile,
      ; we save them even if the source is not saved.
      ; Do not report an error though (for example if the source was loaded from CD)
      SaveProjectSettings(*Source, *Source\IsCode,  0, 0)
    EndIf
    
    ProcedureReturn 1
  EndIf
  
EndProcedure

Procedure SaveAll()  ; saves all sources, but does not close them!
  
  *CurrentSource   = *ActiveSource ; to restore at the end
  *DisplayedSource = *ActiveSource ; for switching to "Save as..." source
  
  ForEach FileList()
    If @FileList() <> *ProjectInfo
      *ActiveSource = @FileList()
      If GetSourceModified()
        
        If *ActiveSource\FileName$ = ""
          
          ; display the source we are about to save
          *ActiveSource = *DisplayedSource ; needed for the correct source switch
          ChangeActiveSourcecode()         ; *Activesource is correct again now
          *DisplayedSource = *ActiveSource
          
          FlushEvents() ; update the display
          SaveSourceAs(); save the source
        Else
          SaveSourceFile(*ActiveSource\FileName$)
          HistoryEvent(*ActiveSource, #HISTORY_Save)
        EndIf
        
      EndIf
    EndIf
  Next FileList()
  
  ; go back to the viewed sourcecode
  *ActiveSource = *DisplayedSource
  ChangeCurrentElement(FileList(), *CurrentSource)
  ChangeActiveSourceCode()
  
EndProcedure



; this function is called when exiting the editor
; Note: now does not remove the source!
Procedure CheckAllSourcesSaved()
  
  ; to avoid flicker, we only switch sources for real if there
  ; is some user interaction needed (ie a "do you want to save" dialog)
  ;
  *Displayed = *ActiveSource
  NbFiles    = ListSize(FileList())
  
  If *ProjectInfo
    NbFiles - 1
  EndIf
  
  ClearList(OpenFiles())
  LastElement(FileList())
  
  For i = 1 To NbFiles
    If @FileList() = *ProjectInfo
      PreviousElement(FileList())
      
    Else
      *ActiveSource = @FileList()
      
      If GetSourceModified()
        *ActiveSource = *Displayed
        ChangeActiveSourcecode()
        *Displayed = *ActiveSource
      EndIf
      
      ; call this even if GetSourceModified() is false, so
      ; we update the settings file
      ;
      Result = CheckSourceSaved()
      
      If Result = 1
        If *ActiveSource\FileName$ <> "" And AutoReload And *ActiveSource\ProjectFile = 0 ; only save the filenames if autoreload is on (and not part of a project as a project will reopen itself its previously opened files)
          AddElement(OpenFiles())
          OpenFiles() = *ActiveSource\FileName$
        EndIf
        
        PreviousElement(FileList())
      Else
        
        *ActiveSource = *Displayed ; reset the active source
        ChangeActiveSourcecode()
        ProcedureReturn 0
      EndIf
    EndIf
    
  Next i
  
  *ActiveSource = *Displayed ; reset the active source
  ChangeActiveSourcecode()
  
  ProcedureReturn 1
EndProcedure


Procedure AutoSave()  ; called before compiling / creating executable to do the autosaveProcedure AutoSave()  ; called before compiling / creating executable to do the autosave
  
  If AutoSaveAll ; save all sources
    
    *RealActiveSource = *ActiveSource ; have to change the *ActiveSource for the GetSourceModified()
    
    ForEach FileList()
      If @FileList() <> *ProjectInfo
        *ActiveSource = @FileList()
        If *ActiveSource\FileName$ <> "" And GetSourceModified() ; don't save <new> files
          SaveSourceFile(*ActiveSource\FileName$)
          HistoryEvent(*ActiveSource, #HISTORY_Save)
        EndIf
      EndIf
    Next FileList()
    
    *ActiveSource = *RealActiveSource
    ChangeCurrentElement(FileList(), *ActiveSource)
    
  Else ; save the current source only
    
    If *ActiveSource <> *ProjectInfo
      If *ActiveSource\FileName$ <> "" And GetSourceModified() ; don't save <new> files
        SaveSourceFile(*ActiveSource\FileName$)
        HistoryEvent(*ActiveSource, #HISTORY_Save)
      EndIf
    EndIf
    
  EndIf
  
EndProcedure

Procedure ShowInFolder()
  If *ActiveSource
    If *ActiveSource = *ProjectInfo
      FileToShow$ = ProjectFile$
    Else
      FileToShow$ = *ActiveSource\FileName$
    EndIf
    If FileToShow$
      ShowExplorerFile(FileToShow$)
    EndIf
  EndIf
EndProcedure

Procedure ReloadSource()
  If *ActiveSource And *ActiveSource <> *ProjectInfo And *ActiveSource\Filename$
    If GetSourceModified() = #False Or MessageRequester(#ProductName$, Language("FileStuff","ReloadModified"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_Yes
      ; make sure the compiler options are closed if its not a project (as they get reloaded from file too)
      ;
      If IsWindow(#WINDOW_Option)  ; make sure the options are closed
        If (*ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile = 0)
          OptionWindowEvents(#PB_Event_CloseWindow)
        EndIf
      EndIf
      
      ; Simply reload the file over the current source
      ;
      If LoadTempFile(*ActiveSource\FileName$)
        ; we reverted to the disk state, so its no longer modified
        UpdateSourceStatus(#False)
        HistoryEvent(*ActiveSource, #HISTORY_Reload)
      EndIf
    EndIf
  EndIf
EndProcedure


; called also after prefs update
;
Procedure SetupFileMonitor()
  Static TimerRunning = 0
  
  If TimerRunning = 0 And MonitorFileChanges
    ; need to setup the timer
    ;
    ; Note: we check once every 5 seconds which should be enough
    ;       we also check when the main window gets the focus, so when the user switches to
    ;       another program to make a change on disk, it is noticed immediately on return
    ;
    ;       the timer events are only used to trigger an update when the IDE has the focus, so the
    ;       requester does not pop up out of nowhere (it will be noticed on the next focus change then)
    ;       See UserInterface.pb for the timer event handling
    ;
    AddWindowTimer(#WINDOW_Main, #TIMER_FileMonitor, 5000)
    TimerRunning = 1
    
  ElseIf TimerRunning And MonitorFileChanges = 0
    ; need to stop the timer
    RemoveWindowTimer(#WINDOW_Main, #TIMER_FileMonitor)
    TimerRunning = 0
    
  EndIf
  
EndProcedure

Global FileMonitorWindowOpen

Procedure FileMonitorWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  If EventID = #PB_Event_Gadget
    Select GadgetID
        
      Case #GADGET_FileMonitor_Reload
        ; make sure the compiler options are closed if its not a project (as they get reloaded from file too)
        ;
        If IsWindow(#WINDOW_Option)  ; make sure the options are closed
          If (*ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile = 0)
            OptionWindowEvents(#PB_Event_CloseWindow)
          EndIf
        EndIf
        
        ; Simply reload the file over the current source
        ;
        If LoadTempFile(*ActiveSource\FileName$)
          ; we reverted to the disk state, so its no longer modified
          UpdateSourceStatus(#False)
          HistoryEvent(*ActiveSource, #HISTORY_Reload)
        EndIf
        
        ; Update the on-disk info, as LoadTempFile() does not do it
        ;
        *ActiveSource\LastWriteDate = GetFileDate(*ActiveSource\Filename$, #PB_Date_Modified)
        *ActiveSource\DiskFileSize  = FileSize(*ActiveSource\Filename$)
        *ActiveSource\DiskChecksum  = FileFingerprint(*ActiveSource\Filename$, #PB_Cipher_MD5)
        
        Quit = #True
        
      Case #GADGET_FileMonitor_Cancel
        ; mark the file as modified, as it is now different from disk
        UpdateSourceStatus(#True)
        
        ; update the on-disk info
        *ActiveSource\LastWriteDate = GetFileDate(*ActiveSource\Filename$, #PB_Date_Modified)
        *ActiveSource\DiskFileSize  = FileSize(*ActiveSource\Filename$)
        *ActiveSource\DiskChecksum  = FileFingerprint(*ActiveSource\Filename$, #PB_Cipher_MD5)
        
        Quit = #True
        
      Case #GADGET_FileMonitor_ViewDiff
        ; diff the current source to disk. do not swap, so it is Source -> Disk
        ; do not close the requester just yet
        DiffSourceToFile(*ActiveSource, *ActiveSource\Filename$, #False)
        
    EndSelect
    
  ElseIf EventID = #PB_Event_CloseWindow
    ; this window has no close button, but this gets called
    ; when the window should be closed because of a prefs update or IDE shutdown
    Quit = #True
    
  EndIf
  
  If Quit
    DisableWindow(#WINDOW_Main, 0) ; this must be first, so the main window can get the focus!
    CloseWindow(#WINDOW_FileMonitor)
    FileMonitorWindowOpen = 0
    
    FileMonitorEvent() ; check again, in case there was more than one file changed
  EndIf
EndProcedure


Procedure FileMonitorEvent()
  If MonitorFileChanges And FileMonitorWindowOpen = 0 ; do not check when the requester is open!
    
    ForEach FileList()
      If @FileList() <> *ProjectInfo And FileList()\ExistsOnDisk And FileList()\FileName$ And FileList()\IsForm = #False ; only check saved files (ignore form files as they don't use the same save routines)
        Size = FileSize(FileList()\FileName$)                                                                            ; check size first to know if it still exists
        If Size < 0
          ; file deleted on disk
          FileList()\ExistsOnDisk = #False ; fire no more monitor events from now on (until it is saved again)
          
          *Current = @FileList()
          ChangeActiveSourceCode()  ; show the file to the user
          FlushEvents()
          
          If MessageRequester(#ProductName$, LanguagePattern("FileStuff","DeletedOnDisk", "%filename%", GetFilePart(FileList()\FileName$)), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
            SaveSourceFile(*ActiveSource\Filename$)
            HistoryEvent(*ActiveSource, #HISTORY_Save)
          Else
            UpdateSourceStatus(1) ; mark file as modified, so the user is promted to save it when he closes it
          EndIf
          
          ; continue on with the next check
          ChangeCurrentElement(FileList(), *Current)
          
        ElseIf Size <> FileList()\DiskFileSize Or (FileList()\LastWriteDate <> GetFileDate(FileList()\FileName$, #PB_Date_Modified) And FileList()\DiskChecksum <> FileFingerprint(FileList()\FileName$, #PB_Cipher_MD5))
          ; file modified on disk
          
          ; Set this here before making the changes, otherwise FlushEvents() below causes a recursion and we miss updates to multiple files
          FileMonitorWindowOpen = 1
          
          ; update disk information
          FileList()\LastWriteDate = GetFileDate(FileList()\Filename$, #PB_Date_Modified)
          FileList()\DiskFileSize  = FileSize(FileList()\Filename$)
          FileList()\DiskChecksum  = FileFingerprint(FileList()\Filename$, #PB_Cipher_MD5)
          
          ChangeActiveSourceCode()  ; show the file to the user
          FlushEvents()
          
          If GetSourceModified() ; different message if the file is modified
            Message$ = LanguagePattern("FileStuff","ModifiedOnDisk2", "%filename%", GetFilePart(FileList()\Filename$))
          Else
            Message$ = LanguagePattern("FileStuff","ModifiedOnDisk1", "%filename%", GetFilePart(FileList()\Filename$))
          EndIf
          
          FileMonitorWindowDialog = OpenDialog(?Dialog_FileMonitor, WindowID(#WINDOW_Main))
          If FileMonitorWindowDialog
            SetGadgetText(#GADGET_FileMonitor_Text, Message$)
            FileMonitorWindowDialog\GuiUpdate()
            
            StickyWindow(#WINDOW_FileMonitor, 1)
            DisableWindow(#WINDOW_Main, 1)
            
            SetActiveWindow(#WINDOW_FileMonitor)
            SetActiveGadget(#GADGET_FileMonitor_Reload)
            
            ProcedureReturn ; do not continue checking until the requester window is closed by the user
          Else
            FileMonitorWindowOpen = 0 ; should not happen
          EndIf
          
        EndIf
      EndIf
    Next FileList()
    
    ChangeCurrentElement(FileList(), *ActiveSource)
  EndIf
EndProcedure
