; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


CompilerIf #SpiderBasic
  ; There is many info displayed in SpiderBasic
  #CompilerWindow_ListHeight = 250
CompilerElseIf #CompileLinux
  ; On Linux (gtk2) the font is usually much bigger, so make this larger there
  #CompilerWindow_ListHeight = 250
CompilerElse
  #CompilerWindow_ListHeight = 100
CompilerEndIf

Global Options_IsProjectMode
Global Options_CurrentBasePath$
Global *Options_CurrentTarget.CompileTarget

Procedure GetActiveCompileTarget()
  If *ActiveSource
    If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile  ; active source is part of a project
      ProcedureReturn *DefaultTarget
    ElseIf *ActiveSource\IsCode
      ProcedureReturn *ActiveSource ; the SourceFile structure extends the CompileTarget one
    Else
      ProcedureReturn 0 ; active source is a non-pb file
    EndIf
  ElseIf IsProject
    ProcedureReturn *DefaultTarget
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

; Find a CompileTarget structure from its unique ID
;
Procedure FindTargetFromID(ID)
  *Target.CompileTarget = 0
  
  If ID ; 0 is considered invalid, so do no search
        ; Note: This function can be called inside another that loops on FileList(),
        ;   so do not use *ActiveSource to restore the position!
    Current = ListIndex(FileList())
    ForEach FileList()
      If @FileList() <> *ProjectInfo And FileList()\ID = ID
        *Target = @FileList()
        Break
      EndIf
    Next FileList()
    SelectElement(FileList(), Current)
    
    If *Target = 0
      Current = ListIndex(ProjectTargets())
      ForEach ProjectTargets()
        If ProjectTargets()\ID = ID
          *Target = @ProjectTargets()
          Break
        EndIf
      Next ProjectTargets()
      SelectElement(ProjectTargets(), Current)
    EndIf
  EndIf
  
  ProcedureReturn *Target
EndProcedure

Procedure SetCompileTargetDefaults(*Target.CompileTarget)
  *Target\Debugger         = OptionDebugger
  *Target\Optimizer        = OptionOptimizer
  *Target\EnableASM        = OptionInlineASM
  *Target\EnableThread     = OptionThread
  *Target\EnableXP         = OptionXPSkin
  *Target\EnableAdmin      = OptionVistaAdmin
  *Target\EnableUser       = OptionVistaUser
  *Target\EnableWayland    = OptionEnableWayland
  *Target\DPIAware         = OptionDPIAware
  *Target\DllProtection    = OptionDllProtection
  *Target\SharedUCRT       = OptionSharedUCRT
  *Target\EnableOnError    = OptionOnError
  *Target\ExecutableFormat = OptionExeFormat
  *Target\CPU              = OptionCPU
  *Target\SubSystem$       = OptionSubSystem$
  *Target\UseCompileCount  = OptionUseCompileCount
  *Target\UseBuildCount    = OptionUseBuildCount
  *Target\UseCreateExe     = OptionUseCreateExe
  *Target\TemporaryExePlace= OptionTemporaryExe
  *Target\CustomCompiler   = OptionCustomCompiler
  *Target\CompilerVersion$ = OptionCompilerVersion$
  *Target\CurrentDirectory$= ""
  *Target\EnablePurifier   = OptionPurifier
  *Target\PurifierGranularity$ = ""
EndProcedure

Procedure CompilerReady()
  DisableMenuItem(#MENU, #MENU_StructureViewer, 0)
  DisableMenuItem(#MENU, #MENU_CreateExecutable, 0)
  DisableMenuAndToolbarItem(#MENU_CompileRun, 0)
  DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 0)
  
  CompilerReady = 1
  
  If *CurrentCompiler = @DefaultCompiler
    HistoryCompilerLoaded()
    
    InitSyntaxHighlighting()
    
    ; Set up the os specific color values
    ;
    SetUpHighlightingColors()
    
    ; do this before scanning, as it affects saved data (known constants etc)
    InitStructureViewer()
    
    ; Init the AutoComplete context sensitive constants (must be after InitStructureViewer() as it uses the ConstantList)
    AutoComplete_InitContextConstants()
  EndIf
  
  ; Ok, everything is loaded, now highlight any already open files.
  ;
  If EnableColoring
    If ListSize(FileList()) > 0     ; on Linux, this happens before any source is open
      *CurrentFile = *ActiveSource
      
      ForEach FileList()
        If @FileList() <> *ProjectInfo
          *ActiveSource = @FileList()
          
          FullSourceScan(@FileList())                     ; re-scan autocomplete + procedurebrowser
          SortParserData(@FileList()\Parser, @FileList()) ; update sorted data in case its not the active source
          UpdateFolding(@FileList(), 0, -1)               ; redo all folding
          
          SetBackgroundColor()
          UpdateHighlighting()
        EndIf
      Next FileList()
      
      ChangeCurrentElement(FileList(), *CurrentFile)
      *ActiveSource = *CurrentFile
    EndIf
  EndIf
  
  ; Re-scan all non-loaded project files for changed options
  ;
  If IsProject
    ForEach ProjectFiles()
      If ProjectFiles()\Source = 0 And ProjectFiles()\AutoScan ; not currently loaded, but scanning
        ScanFile(ProjectFiles()\FileName$, @ProjectFiles()\Parser)
      EndIf
    Next ProjectFiles()
  EndIf
  
  If IsWindow(#WINDOW_StructureViewer)
    DisplayStructureRootList()
  EndIf
  
  ; reflect any source scan changes
  UpdateProcedureList()
  UpdateVariableViewer()
  
EndProcedure


Global CompilerWindowSmall, CompilerWindowBig

Procedure AddCompilerWindowItem(Text$)
  AddGadgetItem(#GADGET_Compiler_List, -1, Text$)
  ScrollEditorGadgetToEnd(#GADGET_Compiler_List)
EndProcedure


Procedure DisplayCompilerWindow()
  
  ; hide the warning window (if any), and clear the warning list (important)
  HideCompilerWarnings()
  
  If IsWindow(#WINDOW_MacroError)
    MacroErrorWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If OpenWindow(#WINDOW_Compiler, 0, 0, 400, 50, #ProductName$, #PB_Window_TitleBar | #PB_Window_Invisible, WindowID(#WINDOW_Main))
    
    Container = ContainerGadget(#PB_Any, 5, 5, 190, 40, #PB_Container_Single)
    ; add a dummy text for size calculation
    TextGadget(#GADGET_Compiler_Text, 15, 15, 120, 20, Language("Compiler","Compiling") + "  (999999 "+Language("Compiler","Lines")+")")
    ButtonGadget(#GADGET_Compiler_Details, 240, 15, 50, 20, Language("Compiler", "Details"), #PB_Button_Toggle)
    CloseGadgetList()
    
    EditorGadget(#GADGET_Compiler_List, 5, 55, 190, 100, #PB_Editor_ReadOnly)
    ProgressBarGadget(#GADGET_Compiler_Progress, 5, 160, 190, 20, 0, 1000)
    ButtonGadget(#GADGET_Compiler_Abort, 145, 160, 50, 20, Language("Misc", "Abort"))
    
    ; calculate needed sizes
    GetRequiredSize(#GADGET_Compiler_Text,    @TextWidth,   @TextHeight)
    GetRequiredSize(#GADGET_Compiler_Details, @ButtonWidth, @ButtonHeight)
    GetRequiredSize(#GADGET_Compiler_Abort,   @AbortWidth,  @ButtonHeight)
    
    ; special handling is needed for OSX Cocoa
    CompilerIf #CompileMacCocoa
      ; border is large and not part of the client area
      ContainerBorderWidth = 16
      ContainerBorderHeight = 16
      ContainerOffsetX = 0
      ContainerOffsetY = 0
      MinButtonHeight = 40
    CompilerElse
      ; add some distance to the borders in the client area on other os
      ContainerBorderWidth = 20
      ContainerBorderHeight = 20
      ContainerOffsetX = 10
      ContainerOffsetY = 10
      MinButtonHeight = 20
    CompilerEndIf
    
    ButtonWidth = Max(ButtonWidth, 60)
    AbortWidth  = Max(AbortWidth, 60)
    ButtonHeight= Max(ButtonHeight, MinButtonHeight)
    Width       = Max(20+ContainerBorderWidth+TextWidth+ButtonWidth, WindowWidth(#WINDOW_Compiler))
    Height      = 10+ContainerBorderHeight+Max(TextHeight, ButtonHeight)
    
    ; for later resizing
    CompilerWindowSmall = Height
    CompilerWindowBig   = Height + 15 + ButtonHeight + #CompilerWindow_ListHeight
    
    ResizeGadget(Container, 5, 5, Width-10, Height-10)
    ResizeGadget(#GADGET_Compiler_Text, ContainerOffsetX, ContainerOffsetY+(Height-30-TextHeight)/2, TextWidth, TextHeight)
    ResizeGadget(#GADGET_Compiler_Details, Width-20-ContainerBorderWidth-ButtonWidth+20, ContainerOffsetY, ButtonWidth, Height-30)
    ResizeGadget(#GADGET_Compiler_List, 5, Height+5, Width-10, #CompilerWindow_ListHeight)
    ResizeGadget(#GADGET_Compiler_Progress, 5, Height+10+#CompilerWindow_ListHeight, Width-15-AbortWidth, ButtonHeight)
    ResizeGadget(#GADGET_Compiler_Abort, Width-5-AbortWidth, Height+10+#CompilerWindow_ListHeight, AbortWidth, ButtonHeight)
    
    ; resize the window and re-center it as well
    If ShowCompilerProgress
      NewHeight = CompilerWindowBig
      SetGadgetState(#GADGET_Compiler_Details, 1)
    Else
      NewHeight = CompilerWindowSmall
    EndIf
    
    ResizeWindow(#WINDOW_Compiler, #PB_Ignore, #PB_Ignore, Width, NewHeight)
    
    ; set the real text to the textgadget
    SetGadgetText(#GADGET_Compiler_Text, Language("Compiler","Compiling"))
    AddCompilerWindowItem(Language("Compiler","Compiling"))
    
    HideWindow(#WINDOW_Compiler, #False, #PB_Window_WindowCentered)
    ; StickyWindow(#WINDOW_Compiler, 1) ; Why sticky ? If we put the IDE to background it will stay above our browser for example, which is very annoying
  EndIf
  
  DisableMenuItem(#MENU, #MENU_CreateExecutable, 1)
  DisableMenuAndToolbarItem(#MENU_CompileRun, 1)
  DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 1)
  
  ; important so the active source cannot be closed/switched during compiling
  DisableWindow(#WINDOW_Main, 1)
  
  FlushEvents() ; allow the window to be drawn for linux compiling
  
  CompilerBusy = 1
EndProcedure

Procedure HideCompilerWindow()
  
  ; In build window mode, ignore the hide call on errors
  If UseProjectBuildWindow = 0
    If IsWindow(#WINDOW_Compiler)
      CloseWindow(#WINDOW_Compiler)
      
      DisableMenuItem(#MENU, #MENU_CreateExecutable, 0)
      DisableMenuAndToolbarItem(#MENU_CompileRun, 0)
      DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 0)
    EndIf
    
    ; re-enable the main window
    DisableWindow(#WINDOW_Main, 0)
    FlushEvents()
  EndIf
  
  CompilerBusy = 0
EndProcedure


Procedure StopCompilerWindow()
  
  ; In build window mode, ignore the hide call on errors
  If UseProjectBuildWindow = 0
    If IsWindow(#WINDOW_Compiler)
      CloseWindow(#WINDOW_Compiler)
      
      DisableMenuItem(#MENU, #MENU_CreateExecutable, 0)
      DisableMenuAndToolbarItem(#MENU_CompileRun, 0)
      DisableMenuAndToolbarItem(#MENU_SyntaxCheck, 0)
    EndIf
    
    ; re-enable the main window
    DisableWindow(#WINDOW_Main, 0)
    FlushEvents()
  EndIf
  
  CompilerBusy = 0
EndProcedure


Procedure CompilerWindowEvents(EventID)
  
  If EventID = #PB_Event_Gadget
    
    If EventGadget() = #GADGET_Compiler_Details
      ShowCompilerProgress = GetGadgetState(#GADGET_Compiler_Details)
      
      If ShowCompilerProgress
        ResizeWindow(#WINDOW_Compiler, #PB_Ignore, #PB_Ignore, #PB_Ignore, CompilerWindowBig)
      Else
        ResizeWindow(#WINDOW_Compiler, #PB_Ignore, #PB_Ignore, #PB_Ignore, CompilerWindowSmall)
      EndIf
      
    ElseIf EventGadget() = #GADGET_Compiler_Abort
      ; set the flag, the rest is done from the Compiler_HandleCompilerResponse() (CompilerInterface.pb)
      CompilationAborted = #True
      
      CompilerIf #SpiderBasic
        If CompilerBusy = 0
          HideCompilerWindow()
        EndIf
      CompilerEndIf
    EndIf
  EndIf
  
EndProcedure

;- ------------------------------------------------

Procedure BuildLogEntry(Message$, InfoIndex = -1)
  If UseProjectBuildWindow And BuildWindowDialog
    Index = CountGadgetItems(#GADGET_Build_Log)
    
    AddGadgetItem(#GADGET_Build_Log, Index, Message$)
    SetGadgetItemData(#GADGET_Build_Log, Index, InfoIndex)
    SetGadgetState(#GADGET_Build_Log, Index)
  EndIf
EndProcedure

; Mode = 0: build target to OutputFile$
; Mode = 1: open requester to ask for output file (on SpiderBasic, the same as Mode 0)
; Mode = 2: build target to temporary exe
;
; Returns: success/failure
;
Procedure.s BuildProjectTarget(*Target.CompileTarget, Mode, CreateExe, CheckSyntax)
  Protected OutputFile$
  Protected Success = #False
  
  ; check if there is an input file for this target
  If *Target\MainFile$ = ""
    If CommandlineBuild
      PrintN(LanguagePattern("Compiler", "NoInputFile", "%target%", *Target\Name$))
    ElseIf UseProjectBuildWindow
      BuildLogEntry(LanguagePattern("Compiler", "NoInputFile", "%target%", *Target\Name$))
    Else
      MessageRequester(#ProductName$, LanguagePattern("Compiler", "NoInputFile", "%target%", *Target\Name$), #FLAG_Error)
    EndIf
    ProcedureReturn ""
  EndIf
  *Target\FileName$ = ResolveRelativePath(GetPathPart(ProjectFile$), *Target\MainFile$)
  
  If AutoSave And CommandlineBuild = 0
    AutoSave()
  EndIf
  
  CompilerIf #SpiderBasic
    If Mode = 1 : Mode = 0 : EndIf ; Mode 1 doesn't exists in SpiderBasic
  CompilerEndIf
  
  If Mode = 0 ; use fixed file
    CompilerIf #SpiderBasic
      If *Target\AppFormat =  #AppFormatiOS
        TargetOutputFile$ = *Target\iOSAppOutput$
      ElseIf *Target\AppFormat =  #AppFormatAndroid
        TargetOutputFile$ = *Target\AndroidAppOutput$
      Else
        TargetOutputFile$ = *Target\HtmlFilename$
      EndIf
    CompilerElse
      TargetOutputFile$ = *Target\OutputFile$
    CompilerEndIf
    
    If TargetOutputFile$ = ""
      If CommandlineBuild
        PrintN(LanguagePattern("Compiler", "NoOutputFile", "%target%", *Target\Name$))
      ElseIf UseProjectBuildWindow
        BuildLogEntry(LanguagePattern("Compiler", "NoOutputFile", "%target%", *Target\Name$))
      Else
        MessageRequester(#ProductName$, LanguagePattern("Compiler", "NoOutputFile", "%target%", *Target\Name$), #FLAG_Error)
      EndIf
      ProcedureReturn ""
    Else
      OutputFile$ = ResolveRelativePath(GetPathPart(ProjectFile$), TargetOutputFile$) ; this is relative
    EndIf
    
    ; set this for later use and tools
    *Target\ExecutableName$ = OutputFile$
    
  ElseIf Mode = 1 ; ask for file
    If *Target\OutputFile$
      Path$ = ResolveRelativePath(GetPathPart(ProjectFile$), *Target\OutputFile$) ; this is relative
    ElseIf *Target\ExecutableName$                                                ; last compiled exe
      Path$ = *Target\ExecutableName$                                             ; this is full path
    Else
      Path$ = GetPathPart(ProjectFile$)
    EndIf
    
    If *Target\ExecutableFormat = 2 ; shared dll
      CompilerIf #CompileWindows
        Pattern$     = Language("Compiler","DllPattern")
        Extension$   = ".dll"
      CompilerElseIf #CompileMac
        Pattern$   = "Shared Library (*.dylib)|*.dylib|All Files (*.*)|*.*"
        Extension$ = ".dylib"
      CompilerElse ; Linux
        Pattern$   = "Shared Library (*.so)|*.so|All Files (*.*)|*.*"
        Extension$ = ".so"
      CompilerEndIf
    Else
      CompilerIf #CompileWindows
        Pattern$   = Language("Compiler","ExePattern")
        Extension$ = ".exe"
      CompilerElseIf #CompileMac
        Pattern$   = ""
        If *Target\ExecutableFormat <> 1 ; console
          Extension$ = ".app"
        Else
          Extension$ = ""
        EndIf
      CompilerElse ; Linux
        Pattern$   = ""
        Extension$ = ""
      CompilerEndIf
    EndIf
    
    OutputFile$ = SaveFileRequester(Language("Compiler","CreateExe"), Path$, Pattern$, 0)
    If OutputFile$ = ""
      ProcedureReturn ""
    EndIf
    
    If LCase(Right(OutputFile$, Len(Extension$))) <> Extension$ And SelectedFilePattern() <> 1
      OutputFile$+Extension$
    EndIf
    
    ; set this for later use and tools
    *Target\ExecutableName$ = OutputFile$
    
  Else ; use temp file
    OutputFile$ = Compiler_TemporaryFilename(*Target)
    
  EndIf
  
  CompilerIf #Demo
    If *Target\ExecutableFormat = 2 ; shared dll
      CompilerIf #CompileWindows
        Message$ = "DLL creation is not available in the demo version."
      CompilerElse
        Message$ = "SO Library creation is not available in the demo version."
      CompilerEndIf
      
      If CommandlineBuild
        PrintN(Message$)
      ElseIf UseProjectBuildWindow
        BuildLogEntry(Message$)
      Else
        MessageRequester("Information", Message$, #FLAG_Info)
      EndIf
    Else
    CompilerEndIf
    
    ; for the addtools, we need a temporary file, so they can modify it...
    If CopyFile(*Target\FileName$, TempPath$ + "PB_EditorOutput.pb")
      CompilerIf #CompileWindows
        ; If the source file was readonly, so will be the temp file, so remove that!
        SetFileAttributes(TempPath$ + "PB_EditorOutput.pb", GetFileAttributes(TempPath$ + "PB_EditorOutput.pb") & ~#PB_FileSystem_ReadOnly)
      CompilerEndIf
      
      ; append the procects settings for the tools if needed
      If SaveProjectSettings <> #SAVESETTINGS_EndOfFile And OpenFile(#FILE_SaveSource, TempPath$+"PB_EditorOutput.pb")
        FileSeek(#FILE_SaveSource, Lof(#FILE_SaveSource)) ; to to the end of the file
        SaveProjectSettings(*Target, #True, 1, 0)
        CloseFile(#FILE_SaveSource)
      EndIf
      
      AddTools_CompiledFile$ = TempPath$ + "PB_EditorOutput.pb"; save for AddTools
      If CreateExe
        AddTools_Execute(#TRIGGER_BeforeCreateExe, *Target)
      Else
        AddTools_Execute(#TRIGGER_BeforeCompile, *Target)
      EndIf
      
      If UseProjectBuildWindow = 0 And CommandlineBuild = 0
        DisplayCompilerWindow() ; hiding this window is done by the compiler functions if there is no error
      EndIf
      
      Success = Compiler_BuildTarget(TempPath$ + "PB_EditorOutput.pb", OutputFile$, *Target, CreateExe, CheckSyntax)
      
    Else
      
      ; copy failed, just fallback and use the original file
      ; the most probable cause for this is that the source did not exist. this will raise a compiler error later
      ;
      AddTools_CompiledFile$ = ""; no temporary file available
      If CreateExe
        AddTools_Execute(#TRIGGER_BeforeCreateExe, *Target)
      Else
        AddTools_Execute(#TRIGGER_BeforeCompile, *Target)
      EndIf
      
      If UseProjectBuildWindow = 0 And CommandlineBuild = 0
        DisplayCompilerWindow() ; hiding this window is done by the compiler functions if there is no error
      EndIf
      
      Success = Compiler_BuildTarget(*Target\Filename$, OutputFile$, *Target, CreateExe, CheckSyntax)
      
    EndIf
    
  CompilerIf #Demo : EndIf : CompilerEndIf
  
  If Success
    ProcedureReturn OutputFile$
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure BuildWindowEvents(EventID)
  Quit = 0
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  If EventID = #PB_Event_Gadget
    Select EventGadget()
      Case #GADGET_Build_Targets
        
      Case #GADGET_Build_Log
        If EventType() = #PB_EventType_LeftDoubleClick
          Index = GetGadgetState(#GADGET_Build_Log)
          If Index <> -1
            InfoIndex = GetGadgetItemData(#GADGET_Build_Log, Index)
            If InfoIndex <> -1 And SelectElement(BuildInfo(), InfoIndex)
              
              ; will simply switch if the file is open already
              If LoadSourceFile(BuildInfo()\File$)
                ChangeActiveLine(BuildInfo()\Line, -5)
                SetSelection(BuildInfo()\Line, 1, BuildInfo()\Line, -1)
              EndIf
              
            EndIf
          EndIf
        EndIf
        
      Case #GADGET_Build_Abort
        ; set the flag, the rest is done from the Compiler_HandleCompilerResponse()
        CompilationAborted = #True
        
      Case #GADGET_Build_Copy
        Content$ = ""
        Count = CountGadgetItems(#GADGET_Build_Log)
        For i = 0 To Count-1
          Content$ + GetGadgetItemText(#GADGET_Build_Log, i, 0) + #NewLine
        Next i
        SetClipboardText(Content$)
        
      Case #GADGET_Build_Save
        FileName$ = GetPathPart(ProjectFile$)
        Pattern   = 0
        Repeat
          FileName$ = SaveFileRequester(Language("Debugger","SaveFileTitle"), FileName$, Language("Debugger","SaveFilePattern"), Pattern)
          Pattern   = SelectedFilePattern()
          If FileName$ = ""
            Break
          ElseIf Pattern = 0 And GetExtensionPart(FileName$) = ""
            FileName$ + ".txt"
          EndIf
          
          If FileSize(FileName$) <> -1
            result = MessageRequester(#ProductName$,Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #FLAG_Warning|#PB_MessageRequester_YesNoCancel)
            If result = #PB_MessageRequester_Cancel
              Break ; abort
            ElseIf result = #PB_MessageRequester_No
              Continue ; ask again
            EndIf
          EndIf
          
          File = CreateFile(#PB_Any, FileName$)
          If File
            Count = CountGadgetItems(#GADGET_Build_Log)
            For i = 0 To Count-1
              WriteStringN(File, GetGadgetItemText(#GADGET_Build_Log, i, 0))
            Next i
            CloseFile(File)
          Else
            MessageRequester(#ProductName$,LanguagePattern("Debugger","SaveError", "%filename%", FileName$), #FLAG_Error)
          EndIf
          
          Break ; if we got here, then do not try again
        ForEver
        
      Case #GADGET_Build_Close
        ; CompilerBusy goes to 0 after each target
        ; UseProjectBuildWindow goes to 0 when all are done
        If (Not CompilerBusy) And (Not UseProjectBuildWindow)
          Quit = 1
        EndIf
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    BuildWindowDialog\SizeUpdate()
    
  ElseIf EventID = #PB_Event_CloseWindow
    ; we have no systemmenu, but this can be sent by code to close the window
    Quit = 1
    
  EndIf
  
  If Quit
    AutoCloseBuildWindow = GetGadgetState(#GADGET_Build_CloseWhenDone)
    
    If MemorizeWindow
      BuildWindowDialog\Close(@BuildWindowPosition)
    Else
      BuildWindowDialog\Close()
    EndIf
    BuildWindowDialog = 0
  EndIf
  
EndProcedure

Procedure UpdateBuildWindow()
  ; theme update
  Count = CountGadgetItems(#GADGET_Build_Targets)
  For i = 0 To Count-1
    Select GetGadgetItemData(#GADGET_Build_Targets, i)
      Case 0: SetGadgetItemImage(#GADGET_Build_Targets, i, ImageID(#IMAGE_Build_TargetNotDone))
      Case 1: SetGadgetItemImage(#GADGET_Build_Targets, i, ImageID(#IMAGE_Build_TargetError))
      Case 2: SetGadgetItemImage(#GADGET_Build_Targets, i, ImageID(#IMAGE_Build_TargetWarning))
      Case 3: SetGadgetItemImage(#GADGET_Build_Targets, i, ImageID(#IMAGE_Build_TargetOK))
    EndSelect
  Next i
  
  BuildWindowDialog\LanguageUpdate()
  BuildWindowDialog\GuiUpdate()
EndProcedure

Procedure OpenBuildWindow(List *Targets.CompileTarget())
  ; hide the windows from the normal mode compiling
  ;
  HideCompilerWarnings()
  
  If IsWindow(#WINDOW_MacroError)
    MacroErrorWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_Option)
    OptionWindowEvents(#PB_Event_CloseWindow)
  EndIf
  
  If IsWindow(#WINDOW_Build) = 0
    BuildWindowDialog = OpenDialog(?Dialog_Build, WindowID(#WINDOW_Main), @BuildWindowPosition)
    
    SetGadgetState(#GADGET_Build_CloseWhenDone, AutoCloseBuildWindow)
    
    CompilerIf #CompileWindows
      Static MonoFont
      
      If MonoFont = 0
        MonoFont = LoadFont(#PB_Any, "Courier New", 10)
      EndIf
      
      If MonoFont
        ; it looks just much better this way
        SetGadgetFont(#GADGET_Build_Log, FontID(MonoFont))
      EndIf
    CompilerEndIf
    
  Else
    ClearGadgetItems(#GADGET_Build_Targets)
    ClearGadgetItems(#GADGET_Build_Log)
    HideGadget(#GADGET_Build_DoneContainer, 1)
    HideGadget(#GADGET_Build_WorkContainer, 0)
    SetWindowForeground(#WINDOW_Build)
  EndIf
  
  EnsureWindowOnDesktop(#WINDOW_Build)
  
  
  ForEach *Targets()
    AddGadgetItem(#GADGET_Build_Targets, -1, *Targets()\Name$+Chr(10)+"-", ImageID(#IMAGE_Build_TargetNotDone))
  Next *Targets()
  
  ; During the build process, disable the main window so the user cannot initiate another compile etc
  ;
  DisableWindow(#WINDOW_Main, #True)
  
  ; This causes the compile functions to output to our build window
  ;
  UseProjectBuildWindow = #True
  CompilerBusy = 1
  
  ClearList(BuildInfo())
  OldWarningCount = 0
  SuccessCount = 0
  FailCount = 0
  
  ForEach *Targets()
    BuildLogEntry(RSet("", 80, "-"))
    BuildLogEntry("  " + LanguagePattern("Compiler","BuildStart", "%target%", *Targets()\Name$))
    BuildLogEntry(RSet("", 80, "-"))
    SetGadgetState(#GADGET_Build_Targets, ListIndex(*Targets()))
    
    Result$ = BuildProjectTarget(*Targets(), 0, #True, #False)
    
    ; count the emitted warnings during this compile
    WarningCount = 0
    ForEach BuildInfo()
      If BuildInfo()\IsWarning
        WarningCount + 1
      EndIf
    Next BuildInfo()
    
    If Result$ <> "" And WarningCount = OldWarningCount
      ; Failures are logged as errors and warnings give a "success with warnings" line, so add a line for success here too
      ; do this before executing the tools for a consistent log output
      BuildLogEntry(Language("Compiler","BuildSuccess"))
    EndIf
    
    ; Update the target's build counts and execute any tools
    If Result$ <> ""
      If *Targets()\UseCompileCount      ; this increases both compile+build count
        *Targets()\CompileCount + 1
      EndIf
      
      If *Targets()\UseBuildCount
        *Targets()\BuildCount + 1
      EndIf
      
      AddTools_ExecutableName$ = Result$
      AddTools_Execute(#TRIGGER_AfterCreateExe, *Targets())
    EndIf
    
    Index = ListIndex(*Targets())
    
    If Result$ = ""
      SetGadgetItemText(#GADGET_Build_Targets, Index, Language("Compiler","StatusError"), 1)
      SetGadgetItemImage(#GADGET_Build_Targets, Index, ImageID(#IMAGE_Build_TargetError))
      SetGadgetItemData(#GADGET_Build_Targets, Index, 1) ; for UpdateBuildWindow()
      FailCount + 1
      
    ElseIf WarningCount > OldWarningCount
      SetGadgetItemText(#GADGET_Build_Targets, Index, LanguagePattern("Compiler","StatusWarning", "%count%", Str(WarningCount - OldWarningCount)), 1)
      SetGadgetItemImage(#GADGET_Build_Targets, Index, ImageID(#IMAGE_Build_TargetWarning))
      SetGadgetItemData(#GADGET_Build_Targets, Index, 2)
      SuccessCount + 1 ; this is a success too
      
    Else
      SetGadgetItemText(#GADGET_Build_Targets, Index, Language("Compiler","StatusOk"), 1)
      SetGadgetItemImage(#GADGET_Build_Targets, Index, ImageID(#IMAGE_Build_TargetOK))
      SetGadgetItemData(#GADGET_Build_Targets, Index, 3)
      SuccessCount + 1
      
    EndIf
    
    OldWarningCount = WarningCount
    BuildLogEntry("")
    
    If CompilationAborted
      Break
    EndIf
  Next *Targets()
  
  ; Display some stats
  ;
  BuildLogEntry(RSet("", 80, "-"))
  BuildLogEntry("")
  
  If SuccessCount > 0
    BuildLogEntry("  " + LanguagePattern("Compiler", "BuildStatsNoError", "%count%", Str(SuccessCount)))
  EndIf
  If FailCount > 0
    BuildLogEntry("  " + LanguagePattern("Compiler", "BuildStatsError", "%count%", Str(FailCount)))
  EndIf
  If WarningCount > 0
    BuildLogEntry("  " + LanguagePattern("Compiler", "BuildStatsWarning", "%count%", Str(WarningCount)))
  EndIf
  If CompilationAborted
    BuildLogEntry("  " + Language("Compiler","BuildStatsAborted"))
  EndIf
  
  BuildLogEntry("")
  
  ; Compiling is done, enable the main window again
  ;
  DisableWindow(#WINDOW_Main, #False)
  CompilerBusy = 0
  UseProjectBuildWindow = #False
  
  UpdateProjectInfo() ; reflect build count change in project info
  
  If GetGadgetState(#GADGET_Build_CloseWhenDone) And FailCount = 0
    BuildWindowEvents(#PB_Event_CloseWindow)
    
  Else
    ; Go to "finished mode"
    HideGadget(#GADGET_Build_WorkContainer, 1)
    HideGadget(#GADGET_Build_DoneContainer, 0)
    
    SetGadgetState(#GADGET_Build_Targets, -1)
    SetGadgetState(#GADGET_Build_Log, -1)
  EndIf
  
EndProcedure

;- ------------------------------------------------

Procedure CompileRun(CheckSyntax)
  UseProjectBuildWindow = #False
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  If CompilerReady And CompilerBusy = 0
    
    If AutoClearLog
      ClearGadgetItems(#GADGET_ErrorLog)
      *ActiveSource\LogSize = 0
      SetDebuggerMenuStates()
    EndIf
    
    ClearList(CompileSource\UnknownIDEOptionsList$())
    
    If AutoSave
      AutoSave() ; do the autosave stuff
    EndIf
    
    If *ActiveSource\UseMainFile
      
      ; make sure the compile source is clean and does not have settings from a previous compile
      ClearStructure(@CompileSource, SourceFile)
      InitializeStructure (@CompileSource, SourceFile) ; We use complex type in this structure like 'List' so we need to reinit again
      
      ; create a new SourceFile structure to represent the MainFile settings
      ; the CompileSource structure is global for the Windows compiler to access it too
      ;
      CompileSource\FileName$ = ResolveRelativePath(GetPathPart(*ActiveSource\FileName$), *ActiveSource\MainFile$)
      
      If ReadFile(#FILE_Compile, CompileSource\FileName$)
        If Lof(#FILE_Compile) < 5000
          Length = Lof(#FILE_Compile)
        Else
          Length = 5000
          FileSeek(#FILE_Compile, Lof(#FILE_Compile)-5000)
        EndIf
        
        *Buffer = AllocateMemory(Length+10) ; we only need the project settings.. (+10 to avoid error on empty files for 0-size alloc!)
        If *Buffer
          ReadData(#FILE_Compile, *Buffer, Length)
          CloseFile(#FILE_Compile)
          
          AnalyzeProjectSettings(@CompileSource, *Buffer, Length, 0)
          FreeMemory(*Buffer)
          
          CompileSource\Debugger     = *ActiveSource\Debugger ; these are set by the current file
          CompileSource\CommandLine$ = *ActiveSource\CommandLine$
          CompileSource\FileName$    = ResolveRelativePath(GetPathPart(*ActiveSource\FileName$), *ActiveSource\MainFile$) ; this is important to compile from the right directory
          
          Success = #False
          
          ; for the addtools, we need a temporary file, so they can modify it...
          If CopyFile(CompileSource\FileName$, TempPath$ + "PB_EditorOutput.pb")
            CompilerIf #CompileWindows
              ; If the source file was readonly, so will be the temp file, so remove that!
              SetFileAttributes(TempPath$ + "PB_EditorOutput.pb", GetFileAttributes(TempPath$ + "PB_EditorOutput.pb") & ~#PB_FileSystem_ReadOnly)
            CompilerEndIf
            
            ; append the procects settings for the tools if needed
            If SaveProjectSettings <> #SAVESETTINGS_EndOfFile And OpenFile(#FILE_SaveSource, TempPath$+"PB_EditorOutput.pb")
              FileSeek(#FILE_SaveSource, Lof(#FILE_SaveSource)) ; to to the end of the file
              SaveProjectSettings(@CompileSource, #True, 1, 0)
              CloseFile(#FILE_SaveSource)
            EndIf
            
            ; call the compiler function with this new structure and main source name
            AddTools_CompiledFile$ = TempPath$ + "PB_EditorOutput.pb"; save for AddTools
            AddTools_Execute(#TRIGGER_BeforeCompile, *ActiveSource)
            
            DisplayCompilerWindow() ; hiding this window is done by the compiler functions if there is no error
            
            Success = Compiler_CompileRun(TempPath$ + "PB_EditorOutput.pb", @CompileSource, CheckSyntax)
            
          Else
            
            ; call the compiler function with this new structure and main source name
            AddTools_CompiledFile$ = ""; no temporary file available
            AddTools_Execute(#TRIGGER_BeforeCompile, *ActiveSource)
            
            DisplayCompilerWindow() ; hiding this window is done by the compiler functions if there is no error
            
            Success = Compiler_CompileRun(CompileSource\FileName$, @CompileSource, CheckSyntax)
            
          EndIf
          
          ; update the build counter for this main file.
          ; This can be tricky as the file may not be loaded in the IDE at this time.
          ;
          If Success And CompileSource\UseCompileCount And CheckSyntax = #False
            
            ; first check if this source is loaded in the IDE
            IsLoaded = 0
            *RealActiveSource = *ActiveSource ; *ActiveSource is modified below as well!
            
            ForEach FileList()
              If @FileList() <> *ProjectInfo And IsEqualFile(FileList()\FileName$, CompileSource\FileName$)
                IsLoaded = 1
                FileList()\CompileCount + 1
                
                If AutoSave And AutoSaveAll ; as it is not the active source, only save With "autosave all" on
                  *ActiveSource = @FileList() ; must be done for the SaveSourceFile() !
                  SaveSourceFile(*ActiveSource\FileName$)
                  HistoryEvent(*ActiveSource, #HISTORY_Save)
                Else
                  ; mark as modified (do manually as the function is only for *ActiveSource
                  FileList()\ScintillaModified = 1
                  FileList()\DisplayModified = 1
                  SetTabBarGadgetItemText(#GADGET_FilesPanel, ListIndex(FileList()), GetFilePart(CompileSource\FileName$)+"*")
                EndIf
                
                Break
              EndIf
            Next FileList()
            ChangeCurrentElement(FileList(), *RealActiveSource)
            *ActiveSource = *RealActiveSource
            
            ; ok, we have to update the file on disk
            ; Note: SaveProjectSettings() actually works if we do not append the options to the source,
            ;       but some settings are lost (folding, currentline etc) as the source is not shown,
            ;       so we do not use it as it may be annoying to lose this data often.
            ;
            ; Note: do not report errors, as the media could be readonly and we do not want to annoy the user then on each compile
            ;
            If IsLoaded = 0
              NewCount = CompileSource\CompileCount + 1
              
              Select SaveProjectSettings
                Case #SAVESETTINGS_EndOfFile
                  *Buffer = 0
                  
                  If ReadFile(#FILE_ReadConfig, CompileSource\FileName$)
                    Length = Lof(#FILE_ReadConfig)
                    *Buffer = AllocateMemory(Length+10) ; avoid the 0size-buffer problem
                    If *Buffer
                      ReadData(#FILE_ReadConfig, *Buffer, Length)
                    EndIf
                    CloseFile(#FILE_ReadConfig)
                  EndIf
                  
                  If *Buffer
                    Select DetectNewLineType(*Buffer, Length)
                      Case 0: NewLine$ = Chr(13)+Chr(10)
                      Case 1: NewLine$ = Chr(10)
                      Case 2: NewLine$ = Chr(13)
                    EndSelect
                    
                    *Cursor.BYTE = *Buffer
                    IsCorrectSection = 0
                    Lookup$ = NewLine$ + "; IDE Options"
                    LookupLength = Len(Lookup$)
                    
                    While *Cursor < *Buffer + Length
                      If CompareMemoryString(*Cursor, ToAscii(Lookup$), 0, LookupLength) = 0 ; this is case sensitive!
                        IsCorrectSection = 1
                      ElseIf IsCorrectSection And CompareMemoryString(*Cursor, ToAscii("EnableCompileCount"), 1, 18) = 0
                        *Start = *Cursor
                        While *Cursor < *Buffer + Length And *Cursor\b <> 10 And *Cursor\b <> 13
                          *Cursor + 1
                        Wend
                        
                        ; now we can directly write the new file
                        If CreateFile(#FILE_SaveConfig, CompileSource\FileName$)
                          WriteData(#FILE_SaveConfig, *Buffer, *Start-*Buffer)
                          WriteString(#FILE_SaveConfig, "EnableCompileCount = " + Str(NewCount)); no newline as we write it with the last block!
                          WriteData(#FILE_SaveConfig, *Cursor, Length - (*Cursor-*Buffer))
                          
                          CloseFile(#FILE_SaveConfig)
                        EndIf
                        
                      EndIf
                      *Cursor + 1
                    Wend
                    
                    FreeMemory(*Buffer)
                  EndIf
                  
                  
                Case #SAVESETTINGS_PerFileCfg ; filename.pb.cfg
                  Success = 0
                  If ReadFile(#FILE_ReadConfig, CompileSource\FileName$+".cfg")
                    If CreateFile(#FILE_SaveConfig, CompileSource\FileName$+".cfg.new")
                      While Not Eof(#FILE_ReadConfig)
                        Line$ = ReadString(#FILE_ReadConfig)
                        
                        If FindString(UCase(Line$), "ENABLECOMPILECOUNT", 1) <> 0
                          Line$ = "EnableCompileCount = " + Str(NewCount)
                          Success = 1
                        EndIf
                        
                        If Eof(#FILE_ReadConfig)
                          WriteString(#FILE_SaveConfig, Line$) ; no newline at the end
                        Else
                          WriteStringN(#FILE_SaveConfig, Line$)
                        EndIf
                      Wend
                      CloseFile(#FILE_SaveConfig)
                    EndIf
                    CloseFile(#FILE_ReadConfig)
                  EndIf
                  
                  If Success And DeleteFile(CompileSource\FileName$+".cfg")
                    RenameFile(CompileSource\FileName$+".cfg.new", CompileSource\FileName$+".cfg")
                  Else
                    DeleteFile(CompileSource\FileName$+".cfg.new")
                  EndIf
                  
                Case #SAVESETTINGS_PerFolderCfg ; project.cfg
                  Success = 0
                  IsCorrectSection = 0
                  If ReadFile(#FILE_ReadConfig, GetPathPart(CompileSource\FileName$)+"project.cfg")
                    If CreateFile(#FILE_SaveConfig, GetPathPart(CompileSource\FileName$)+"project.cfg.new")
                      While Not Eof(#FILE_ReadConfig)
                        Line$ = ReadString(#FILE_ReadConfig)
                        
                        If UCase(Trim(Line$)) = "["+UCase(GetFilePart(CompileSource\FileName$))+"]"
                          IsCorrectSection = 1
                        ElseIf Left(Trim(Line$), 1) = "["
                          IsCorrectSection = 0
                        ElseIf IsCorrectSection And FindString(UCase(Line$), "ENABLECOMPILECOUNT", 1) <> 0
                          Line$ = "  EnableCompileCount = " + Str(NewCount)
                          Success = 1
                        EndIf
                        
                        If Eof(#FILE_ReadConfig)
                          WriteString(#FILE_SaveConfig, Line$) ; no newline at the end
                        Else
                          WriteStringN(#FILE_SaveConfig, Line$)
                        EndIf
                      Wend
                      CloseFile(#FILE_SaveConfig)
                    EndIf
                    CloseFile(#FILE_ReadConfig)
                  EndIf
                  
                  If Success And DeleteFile(GetPathPart(CompileSource\FileName$)+"project.cfg")
                    RenameFile(GetPathPart(CompileSource\FileName$)+"project.cfg.new", GetPathPart(CompileSource\FileName$)+"project.cfg")
                  Else
                    DeleteFile(GetPathPart(CompileSource\FileName$)+"project.cfg.new")
                  EndIf
                  
                  ; case #SAVESETTINGS_DoNotSave - no saving
              EndSelect
            EndIf
            
          EndIf
          
        Else
          MessageRequester(#ProductName$, "Critical Error! Out of Memory!", #FLAG_ERROR)
          ActivateMainWindow()
        EndIf
        
        
      Else
        MessageRequester(#ProductName$, Language("Compiler", "ReadMainError")+#NewLine+*ActiveSource\MainFile$, #FLAG_ERROR)
        ActivateMainWindow()
      EndIf
      
      
    Else ; No MainFile option... way simpler :)
      
      ; the source must be saved to the temp path
      ;
      If SaveTempFile(TempPath$ + "PB_EditorOutput.pb")
        
        
        AddTools_CompiledFile$ = TempPath$ + "PB_EditorOutput.pb" ; save for AddTools
        AddTools_Execute(#TRIGGER_BeforeCompile, *ActiveSource)
        
        DisplayCompilerWindow() ; hiding this window is done by the compiler functions if there is no error
        
        ; call the os compiler function, with the current source settings
        If Compiler_CompileRun(TempPath$ + "PB_EditorOutput.pb", *ActiveSource, CheckSyntax)
          
          ; update the compile count
          If *ActiveSource\UseCompileCount And CheckSyntax = #False
            *ActiveSource\CompileCount + 1
            
            If AutoSave And *ActiveSource\FileName$ <> "" ; no autosave if file was never saved yet!
                                                          ; with autosave, save directly so the * does not appear
              SaveSourceFile(*ActiveSource\FileName$)
              HistoryEvent(*ActiveSource, #HISTORY_Save)
            Else
              ; mark the source as changed so this is saved when the source is actually closed!
              UpdateSourceStatus(1)
            EndIf
          EndIf
          
        EndIf
        
      Else
        MessageRequester(#ProductName$, Language("Compiler","SaveTempError")+#NewLine+TempPath$+"PB_EditorOutput.pb", #FLAG_ERROR)
        HideCompilerWindow()
      EndIf
    EndIf
    
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
    ActivateMainWindow()
  EndIf
  
  
EndProcedure


Procedure StartInternalBuild(SourceFile$, File$)
  AddTools_CompiledFile$ = SourceFile$
  AddTools_Execute(#TRIGGER_BeforeCreateExe, *ActiveSource)
  
  DisplayCompilerWindow() ; hiding this window is done by the compiler functions if there is no error
  
  If Compiler_BuildTarget(SourceFile$, File$, *ActiveSource, #True, #False)
    
    ; do the compilation counts (both, as the CompileCount includes the BuildCount)
    If *ActiveSource\UseCompileCount Or *ActiveSource\UseBuildCount
      If *ActiveSource\UseCompileCount
        *ActiveSource\CompileCount + 1
      EndIf
      
      If *ActiveSource\UseBuildCount
        *ActiveSource\BuildCount + 1
      EndIf
      
      If AutoSave
        ; with AutoSave, we directly save again, as else the * reappears which is weird
        SaveSourceFile(*ActiveSource\FileName$)
        HistoryEvent(*ActiveSource, #HISTORY_Save)
      Else
        ; mark the source as changed so this is saved when the source is actually closed!
        UpdateSourceStatus(1)
      EndIf
    EndIf
    
    ProcedureReturn #True ; Success
  EndIf
  
  ProcedureReturn #False
EndProcedure


Procedure CreateExecutable()
  Protected *MainSource.SourceFile
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  UseProjectBuildWindow = #False
  
  If CompilerReady And CompilerBusy = 0
    
    *InitialActiveSource = *ActiveSource
    
    If *ActiveSource\FileName$ = ""
      If SaveSourceAs() = -1
        ProcedureReturn  ; abort the whole thing if the user does not save the sourcecode
      EndIf
      
    ElseIf AutoSave
      AutoSave()
    EndIf
    
    ; Handle the special case when creating an executable from a file which has a main file.
    ; Here, we just load the file in the IDE if not open, or use the opened file infos
    ;
    If *ActiveSource\UseMainFile
      
      MainFileName$ = ResolveRelativePath(GetPathPart(*ActiveSource\FileName$), *ActiveSource\MainFile$)
      If LoadSourceFile(MainFileName$, 0) ; Ensure it's loaded in the IDE, to have all the correct prefs and such
        
        ; Look for our newly opened file
        ;
        *MainSource = FindSourceFile(MainFileName$)
        
      EndIf
      
      If *MainSource = 0
        MessageRequester("Error", "Can't load the main file to create the executable: "+MainFileName$)
        ProcedureReturn
      EndIf
      
      *ActiveSource = *MainSource
      
    EndIf
    
    CompilerIf #SpiderBasic
      
      OpenCreateAppWindow(*ActiveSource, #False)
      
      *ActiveSource = *InitialActiveSource ; Restore the active source
      
    CompilerElse
      
      If *ActiveSource\ExecutableName$
        Path$ = *ActiveSource\ExecutableName$
      Else
        Path$ = GetPathPart(*ActiveSource\FileName$) ; Get the path of the source file (or main file if specified) if no executable has been specified
      EndIf
      
      
      ; the source must be saved to the temp path
      ;
      If SaveTempFile(TempPath$ + "PB_EditorOutput.pb") = 0
        MessageRequester(#ProductName$, Language("Compiler","SaveTempError")+#NewLine+TempPath$+"PB_EditorOutput.pb", #FLAG_ERROR)
        *InitialActiveSource = *ActiveSource
        ProcedureReturn
      EndIf
      
      CompilerIf #Demo
        If *ActiveSource\ExecutableFormat = 2 ; shared dll
          CompilerIf #CompileWindows
            MessageRequester("Information", "DLL creation is not available in the demo version.")
          CompilerElse
            MessageRequester("Information", "SO Library creation is not available in the demo version.")
          CompilerEndIf
        Else
        CompilerEndIf
        
        If *ActiveSource\ExecutableFormat = 2 ; shared dll
          CompilerIf #CompileWindows
            Pattern$     = Language("Compiler","DllPattern")
            Extension$   = ".dll"
          CompilerElseIf #CompileMac
            Pattern$   = "Shared Library (*.dylib)|*.dylib|All Files (*.*)|*.*"
            Extension$ = ".dylib"
          CompilerElse ; Linux
            Pattern$   = "Shared Library (*.so)|*.so|All Files (*.*)|*.*"
            Extension$ = ".so"
          CompilerEndIf
        Else
          CompilerIf #CompileWindows
            Pattern$   = Language("Compiler","ExePattern")
            Extension$ = ".exe"
          CompilerElseIf #CompileMac
            Pattern$   = ""
            If *ActiveSource\ExecutableFormat = 1
              Extension$ = "" ; console, do not append .app automatically here
            Else
              Extension$ = ".app"  ; automatically append ".app" for gui programs
            EndIf
          CompilerElse ; Linux
            Pattern$   = ""
            Extension$ = ""
          CompilerEndIf
        EndIf
        
        File$ = SaveFileRequester(Language("Compiler","CreateExe"), Path$, Pattern$, 0)
        If File$
          If LCase(Right(File$, Len(Extension$))) <> Extension$ And SelectedFilePattern() <> 1
            File$+Extension$
          EndIf
          
          ; If the name of the exe has changed, we need to re-save the file (https://www.purebasic.fr/english/viewtopic.php?f=4&t=59806)
          ;
          If *ActiveSource\ExecutableName$ <> File$
            *ActiveSource\ExecutableName$ = File$
            If AutoSave
              SaveSourceFile(*ActiveSource\FileName$)
            Else
              UpdateSourceStatus(1) ; mark the source as changed so this is saved when the source is actually closed!
            EndIf
          EndIf
          
          If StartInternalBuild(TempPath$ + "PB_EditorOutput.pb", File$)
            *ActiveSource = *InitialActiveSource ; Restore the active source only if the compilation has succeeded
          EndIf
          
        Else
          *ActiveSource = *InitialActiveSource ; Restore the active source as the CreateExecutable has been aborted
          HideCompilerWindow()
        EndIf
        
      CompilerIf #Demo : EndIf : CompilerEndIf
      
    CompilerEndIf
    
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
  EndIf
  
EndProcedure

Procedure Run()
  UseProjectBuildWindow = #False
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  If CompilerReady And CompilerBusy = 0
    If AutoClearLog
      ClearGadgetItems(#GADGET_ErrorLog)
      *ActiveSource\LogSize = 0
      SetDebuggerMenuStates()
    EndIf
    
    AddTools_Execute(#TRIGGER_ProgramRun, *ActiveSource)
    Compiler_Run(*ActiveSource, #False)  ; not the first time this is run
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
  EndIf
  
EndProcedure




Procedure CompileRunProject(CheckSyntax)
  ; Use the normal CompilerWindow for this
  UseProjectBuildWindow = #False
  
  If CompilerReady And CompilerBusy = 0
    If AutoClearLog
      ClearList(ProjectLog())
      ErrorLog_Refresh()
      SetDebuggerMenuStates()
    EndIf
    
    If AutoSave
      AutoSave()
    EndIf
    
    ; Delete the previous output filename (if possible)
    ;
    If *DefaultTarget\RunExecutable$
      CompilerIf #CompileMac
        DeleteDirectory(*DefaultTarget\RunExecutable$, "*", #PB_FileSystem_Recursive) ; a .app is a directory!
      CompilerElse
        DeleteFile(*DefaultTarget\RunExecutable$)
      CompilerEndIf
      *DefaultTarget\RunExecutable$ = ""
    EndIf
    
    ; compile to temporary exe (always with Compile/Run, so multiple instances can run etc)
    ;
    OutputFile$ = BuildProjectTarget(*DefaultTarget, 2, #False, CheckSyntax)
    If OutputFile$ <> ""
      ; Register the output file for deletion in case the user re-compiles while the first instance
      ; of the exe still runs (and cannot be deleted)
      ;
      RegisterDeleteFile(OutputFile$)
      
      If *DefaultTarget\UseCompileCount And CheckSyntax = #False ; only increase the build count here
        *DefaultTarget\CompileCount + 1
        UpdateProjectInfo()                  ; reflect count change in project info
      EndIf
      
      ; set the run information, then simply call the run command from here to reduce code
      *DefaultTarget\RunExecutable$     = OutputFile$
      *DefaultTarget\RunExeFormat       = *DefaultTarget\ExecutableFormat
      *DefaultTarget\RunDebuggerMode    = (*DefaultTarget\Debugger|ForceDebugger)&~ForceNoDebugger
      *DefaultTarget\RunEnableAdmin     = *DefaultTarget\EnableAdmin
      *DefaultTarget\RunSourceFileName$ = *DefaultTarget\FileName$ ; updated before compiling, so this is the full file
      *DefaultTarget\RunMainFileUsed    = 0                        ; no mainfile option here
      *DefaultTarget\RunCompilerPath$   = GetPathPart(*CurrentCompiler\Executable$)
      *DefaultTarget\RunCompilerVersion = *CurrentCompiler\VersionNumber
      
      ; execute any external tools
      AddTools_ExecutableName$ = OutputFile$
      AddTools_Execute(#TRIGGER_AfterCompile, *DefaultTarget)
      
      If CheckSyntax = #False
        AddTools_Execute(#TRIGGER_ProgramRun, *DefaultTarget)
        Compiler_Run(*DefaultTarget, #True) ; run (for the first time)
      EndIf
    EndIf
    
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
    ActivateMainWindow()
  EndIf
  
EndProcedure

Procedure RunProject()
  ; Use the normal CompilerWindow for this
  UseProjectBuildWindow = #False
  
  If CompilerReady And CompilerBusy = 0
    If AutoClearLog
      ClearList(ProjectLog())
      ErrorLog_Refresh()
      SetDebuggerMenuStates()
    EndIf
    
    AddTools_ExecutableName$ = *DefaultTarget\RunExecutable$
    AddTools_Execute(#TRIGGER_ProgramRun, *DefaultTarget)
    
    Compiler_Run(*DefaultTarget, #False) ; run (not for the first time)
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
  EndIf
  
EndProcedure

Procedure CreateExecutableProject()
  ; Use the normal CompilerWindow for this
  UseProjectBuildWindow = #False
  
  If CompilerReady And CompilerBusy = 0
    
    OutputFile$ = BuildProjectTarget(*DefaultTarget, 1, #True, #False) ; ask for output file
    If OutputFile$ <> ""
      If *DefaultTarget\UseCompileCount      ; this increases both compile+build count
        *DefaultTarget\CompileCount + 1
      EndIf
      
      If *DefaultTarget\UseBuildCount
        *DefaultTarget\BuildCount + 1
      EndIf
      
      If *DefaultTarget\UseCompileCount Or *DefaultTarget\UseBuildCount
        UpdateProjectInfo() ; reflect count change in project info
      EndIf
      
      AddTools_ExecutableName$ = OutputFile$
      AddTools_Execute(#TRIGGER_AfterCreateExe, *DefaultTarget)
      
      ProcedureReturn 1
    EndIf
    
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
  EndIf
  
EndProcedure

Procedure BuildTarget(*Target.CompileTarget)
  Protected NewList *Targets.CompileTarget()
  
  ; Just create a list with this one target and let the common function do the heavy work
  ;
  AddElement(*Targets())
  *Targets() = *Target
  
  If CompilerReady And CompilerBusy = 0
    OpenBuildWindow(*Targets())
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
  EndIf
EndProcedure

Procedure BuildAll()
  Protected NewList *Targets.CompileTarget()
  
  If CompilerReady And CompilerBusy = 0
    
    ; Add all targets that are set for "build all" to our list
    ; in the same order as they appear in compiler options (no dependency resolving yet)
    ;
    ForEach ProjectTargets()
      If ProjectTargets()\IsEnabled
        AddElement(*Targets())
        *Targets() = @ProjectTargets()
      EndIf
    Next ProjectTargets()
    
    If ListSize(*Targets()) <> 0
      OpenBuildWindow(*Targets()) ; this function does all the work
    Else
      MessageRequester(#ProductName$, Language("Compiler","NoBuildTargets"))
    EndIf
    
  Else
    MessageRequester(#ProductName$, Language("Compiler","NotReady"))
  EndIf
EndProcedure



CompilerIf #CompileWindows
  
  DataSection
    
    Resource_Strings:
    Data.l 6 ; count
    Data$ "VOS_UNKNOWN"
    Data$ "VOS_DOS"
    Data$ "VOS_DOS_WINDOWS16"
    Data$ "VOS_DOS_WINDOWS32"
    Data$ "VOS_NT_WINDOWS32"
    Data$ "VOS_NT"
    
    Data.l 7 ; count
    Data$ "VFT_UNKNOWN"
    Data$ "VFT_APP"
    Data$ "VFT_DLL"
    Data$ "VFT_DRV"
    Data$ "VFT_FONT"
    Data$ "VFT_VXD"
    Data$ "VFT_STATIC_LIB"
    
    Data.l 168
    Data$ "0000 Language Neutral"
    Data$ "007f Invariant locale"
    Data$ "0400 Process Or User Default Language"
    Data$ "0800 System Default Language"
    Data$ "0436 Afrikaans"
    Data$ "041c Albanian"
    Data$ "0401 Arabic (Saudi Arabia)"
    Data$ "0801 Arabic (Iraq)"
    Data$ "0c01 Arabic (Egypt)"
    Data$ "1001 Arabic (Libya)"
    Data$ "1401 Arabic (Algeria)"
    Data$ "1801 Arabic (Morocco)"
    Data$ "1c01 Arabic (Tunisia)"
    Data$ "2001 Arabic (Oman)"
    Data$ "2401 Arabic (Yemen)"
    Data$ "2801 Arabic (Syria)"
    Data$ "2c01 Arabic (Jordan)"
    Data$ "3001 Arabic (Lebanon)"
    Data$ "3401 Arabic (Kuwait)"
    Data$ "3801 Arabic (U.A.E.)"
    Data$ "3c01 Arabic (Bahrain)"
    Data$ "4001 Arabic (Qatar)"
    Data$ "042b Armenian"
    Data$ "042c Azeri (Latin)"
    Data$ "082c Azeri (Cyrillic)"
    Data$ "042d Basque"
    Data$ "0423 Belarusian"
    Data$ "0445 Bengali (India)"
    Data$ "141a Bosnian (Bosnia And Herzegovina)"
    Data$ "0402 Bulgarian"
    Data$ "0455 Burmese"
    Data$ "0403 Catalan"
    Data$ "0404 Chinese (Taiwan)"
    Data$ "0804 Chinese (PRC)"
    Data$ "0c04 Chinese (Hong Kong SAR, PRC)"
    Data$ "1004 Chinese (Singapore)"
    Data$ "1404 Chinese (Macao SAR)"
    Data$ "041a Croatian"
    Data$ "101a Croatian (Bosnia And Herzegovina)"
    Data$ "0405 Czech"
    Data$ "0406 Danish"
    Data$ "0465 Divehi"
    Data$ "0413 Dutch (Netherlands)"
    Data$ "0813 Dutch (Belgium)"
    Data$ "0409 English (United States)"
    Data$ "0809 English (United Kingdom)"
    Data$ "0c09 English (Australian)"
    Data$ "1009 English (Canadian)"
    Data$ "1409 English (New Zealand)"
    Data$ "1809 English (Ireland)"
    Data$ "1c09 English (South Africa)"
    Data$ "2009 English (Jamaica)"
    Data$ "2409 English (Caribbean)"
    Data$ "2809 English (Belize)"
    Data$ "2c09 English (Trinidad)"
    Data$ "3009 English (Zimbabwe)"
    Data$ "3409 English (Philippines)"
    Data$ "0425 Estonian"
    Data$ "0438 Faeroese"
    Data$ "0429 Farsi"
    Data$ "040b Finnish"
    Data$ "040c French (Standard)"
    Data$ "080c French (Belgian)"
    Data$ "0c0c French (Canadian)"
    Data$ "100c French (Switzerland)"
    Data$ "140c French (Luxembourg)"
    Data$ "180c French (Monaco)"
    Data$ "0456 Galician"
    Data$ "0437 Georgian"
    Data$ "0407 German (Standard)"
    Data$ "0807 German (Switzerland)"
    Data$ "0c07 German (Austria)"
    Data$ "1007 German (Luxembourg)"
    Data$ "1407 German (Liechtenstein)"
    Data$ "0408 Greek"
    Data$ "0447 Gujarati"
    Data$ "040d Hebrew"
    Data$ "0439 Hindi"
    Data$ "040e Hungarian"
    Data$ "040f Icelandic"
    Data$ "0421 Indonesian"
    Data$ "0434 isiXhosa/Xhosa (South Africa)"
    Data$ "0435 isiZulu/Zulu (South Africa)"
    Data$ "0410 Italian (Standard)"
    Data$ "0810 Italian (Switzerland)"
    Data$ "0411 Japanese"
    Data$ "044b Kannada"
    Data$ "0457 Konkani"
    Data$ "0412 Korean"
    Data$ "0812 Korean (Johab)"
    Data$ "0440 Kyrgyz"
    Data$ "0426 Latvian"
    Data$ "0427 Lithuanian"
    Data$ "0827 Lithuanian (Classic)"
    Data$ "042f Macedonian (FYROM)"
    Data$ "043e Malay (Malaysian)"
    Data$ "083e Malay (Brunei Darussalam)"
    Data$ "044c Malayalam (India)"
    Data$ "0481 Maori (New Zealand)"
    Data$ "043a Maltese (Malta)"
    Data$ "044e Marathi"
    Data$ "0450 Mongolian"
    Data$ "0414 Norwegian (Bokmal)"
    Data$ "0814 Norwegian (Nynorsk)"
    Data$ "0415 Polish"
    Data$ "0416 Portuguese (Brazil)"
    Data$ "0816 Portuguese (Portugal)"
    Data$ "0446 Punjabi"
    Data$ "046b Quechua (Bolivia)"
    Data$ "086b Quechua (Ecuador)"
    Data$ "0c6b Quechua (Peru)"
    Data$ "0418 Romanian"
    Data$ "0419 Russian"
    Data$ "044f Sanskrit"
    Data$ "043b Sami, Northern (Norway)"
    Data$ "083b Sami, Northern (Sweden)"
    Data$ "0c3b Sami, Northern (Finland)"
    Data$ "103b Sami, Lule (Norway)"
    Data$ "143b Sami, Lule (Sweden)"
    Data$ "183b Sami, Southern (Norway)"
    Data$ "1c3b Sami, Southern (Sweden)"
    Data$ "203b Sami, Skolt (Finland)"
    Data$ "243b Sami, Inari (Finland)"
    Data$ "0c1a Serbian (Cyrillic)"
    Data$ "1c1a Serbian (Cyrillic, Bosnia, And Herzegovina)"
    Data$ "081a Serbian (Latin)"
    Data$ "181a Serbian (Latin, Bosnia, And Herzegovina)"
    Data$ "046c Sesotho sa Leboa/Northern Sotho (South Africa)"
    Data$ "0432 Setswana/Tswana (South Africa)"
    Data$ "041b Slovak"
    Data$ "0424 Slovenian"
    Data$ "040a Spanish (Spain, Traditional Sort)"
    Data$ "080a Spanish (Mexican)"
    Data$ "0c0a Spanish (Spain, Modern Sort)"
    Data$ "100a Spanish (Guatemala)"
    Data$ "140a Spanish (Costa Rica)"
    Data$ "180a Spanish (Panama)"
    Data$ "1c0a Spanish (Dominican Republic)"
    Data$ "200a Spanish (Venezuela)"
    Data$ "240a Spanish (Colombia)"
    Data$ "280a Spanish (Peru)"
    Data$ "2c0a Spanish (Argentina)"
    Data$ "300a Spanish (Ecuador)"
    Data$ "340a Spanish (Chile)"
    Data$ "380a Spanish (Uruguay)"
    Data$ "3c0a Spanish (Paraguay)"
    Data$ "400a Spanish (Bolivia)"
    Data$ "440a Spanish (El Salvador)"
    Data$ "480a Spanish (Honduras)"
    Data$ "4c0a Spanish (Nicaragua)"
    Data$ "500a Spanish (Puerto Rico)"
    Data$ "0430 Sutu"
    Data$ "0441 Swahili (Kenya)"
    Data$ "041d Swedish"
    Data$ "081d Swedish (Finland)"
    Data$ "045a Syriac"
    Data$ "0449 Tamil"
    Data$ "0444 Tatar (Tatarstan)"
    Data$ "044a Telugu"
    Data$ "041e Thai"
    Data$ "041f Turkish"
    Data$ "0422 Ukrainian"
    Data$ "0420 Urdu (Pakistan)"
    Data$ "0820 Urdu (India)"
    Data$ "0443 Uzbek (Latin)"
    Data$ "0843 Uzbek (Cyrillic)"
    Data$ "042a Vietnamese"
    Data$ "0452 Welsh (United Kingdom)"
    
  EndDataSection
  
CompilerEndIf
