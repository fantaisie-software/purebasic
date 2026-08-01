; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; shortcuts that are added to every debugger window
;
Enumeration #DEBUGGER_MENU_LAST ; add after the debuggers own shortcuts
  #MENU_Debugger_Stop
  #MENU_Debugger_Run
  #MENU_Debugger_Step
  #MENU_Debugger_StepX
  #MENU_Debugger_StepOut
  #MENU_Debugger_StepOver
  #MENU_Debugger_Kill
  #MENU_Debugger_DebugOutput
  #MENU_Debugger_Watchlist
  #MENU_Debugger_VariableList
  #MENU_Debugger_History
  #MENU_Debugger_Memory
  #MENU_Debugger_LibraryViewer
  #MENU_Debugger_DebugAsm
  #MENU_Debugger_DataBreakpoints
  ;#MENU_Debugger_CPUMonitor
EndEnumeration

Procedure FindDebuggerFromID(ID)
  If ID ; 0 is the "invalid ID"
    ForEach RunningDebuggers()
      If ID = RunningDebuggers()\ID
        ProcedureReturn @RunningDebuggers()
      EndIf
    Next RunningDebuggers()
  EndIf
  
  ProcedureReturn 0
EndProcedure

; find out if the given file is active (included) in a debug session
; For Project files which are not included in the debugged source, this returns nothing
;
Procedure IsDebuggedFile(*Source.SourceFile)
  
  ; no source passed (not loaded yet maybe?)
  ;
  If *Source = 0
    ProcedureReturn 0
  EndIf
  
  ; Get the debugger ID (if any)
  ;
  If *Source\DebuggerID
    *Debugger = FindDebuggerFromID(*Source\DebuggerID)
    
    If *Debugger
      ProcedureReturn *Debugger
    EndIf
  EndIf
  
  ; The source is not directly linked to a debugger, so check all debugger file lists
  ;
  ForEach RunningDebuggers()
    
    If IsEqualFile(*Source\FileName$, RunningDebuggers()\FileName$)
      ProcedureReturn @RunningDebuggers() ; return the debugger structure
    EndIf
    
    If RunningDebuggers()\IncludedFiles ; is filename buffer initialized
      *Cursor = RunningDebuggers()\IncludedFiles
      *Cursor + MemoryAsciiLength(*Cursor) + 1 ; skip the source path string
      *Cursor + MemoryAsciiLength(*Cursor) + 1 ; skip the main source name (checked above)
      For i = 1 To RunningDebuggers()\NbIncludedFiles  ; check all included files
                                                       ; the included filenames may include "../" so use ResolveRelativePath() on them, which resolves that to get a unique filename
        FileName$ = UniqueFilename(PeekUTF8(*Cursor))
        If IsEqualFile(*Source\FileName$, FileName$)
          ProcedureReturn @RunningDebuggers() ; return the debugger structure
        EndIf
        *Cursor + MemoryAsciiLength(*Cursor) + 1
      Next i
    EndIf
    
  Next RunningDebuggers()
  
  ; No debugger found
  ;
  ProcedureReturn 0
  
EndProcedure

; Returns the debugger that is associated with this sourcefile
; For Projects, this returns the "Project Debugger" for all project files
;
Procedure GetDebuggerForFile(*Source.SourceFile)
  
  ; This function is called during IDE startup when no files are loaded, so handle this case
  If *Source = 0
    ProcedureReturn 0
  EndIf
  
  If (*Source = *ProjectInfo Or *Source\ProjectFile) And ProjectDebuggerID
    *Debugger = FindDebuggerFromID(ProjectDebuggerID)
    
    If *Debugger
      ProcedureReturn *Debugger
    EndIf
  EndIf
  
  ; The file is not in a project with debugger, so do a normal search
  ProcedureReturn IsDebuggedFile(*Source)
EndProcedure



Procedure GetDebuggerFileNumber(*Debugger.DebuggerData, *Source.SourceFile)
  
  If *Source\FileName$ = "" ; can only be the main source
    If IsDebuggedFile(*Source) = *Debugger
      ProcedureReturn 0
    EndIf
    
  Else
    If IsEqualFile(*Source\FileName$, *Debugger\FileName$)
      ProcedureReturn 0
    EndIf
    
    If *Debugger\IncludedFiles ; is filename buffer initialized
      *Cursor = *Debugger\IncludedFiles
      *Cursor + MemoryAsciiLength(*Cursor) + 1 ; skip the source path string
      *Cursor + MemoryAsciiLength(*Cursor) + 1 ; skip the main source name (checked above)
      For i = 1 To *Debugger\NbIncludedFiles   ; check all included files
        If IsEqualFile(*Source\FileName$, PeekUTF8(*Cursor))
          ProcedureReturn i ; return the file number
        EndIf
        *Cursor + MemoryAsciiLength(*Cursor) + 1
      Next i
    EndIf
    
  EndIf
  
  ProcedureReturn -1 ; file not in this debugger!
EndProcedure


Procedure UpdateErrorLogMenuState()
  If *ActiveSource And AlwaysHideLog = 0
    DisableMenuItem(#MENU, #MENU_ShowLog, 0) ; the log is always viewable, as it displays compiler errors too
    
    If *ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile
      State = ProjectShowLog
      Size  = ListSize(ProjectLog())
    Else
      State = *ActiveSource\ErrorLog
      Size  = *ActiveSource\LogSize
    EndIf
    
    If State And Size > 0
      DisableMenuAndToolbarItem(#MENU_ClearLog, 0)
      DisableMenuAndToolbarItem(#MENU_CopyLog, 0)
    Else
      DisableMenuAndToolbarItem(#MENU_ClearLog, 1)
      DisableMenuAndToolbarItem(#MENU_CopyLog, 1)
    EndIf
  Else
    DisableMenuItem(#MENU, #MENU_ShowLog, 1)
    DisableMenuAndToolbarItem(#MENU_ClearLog, 1)
    DisableMenuAndToolbarItem(#MENU_CopyLog, 1)
  EndIf
EndProcedure



Procedure SetDebuggerMenuStates()
  
  IsEnabled = 0
  *Target.CompileTarget = GetActiveCompileTarget()
  If *Target
    IsEnabled = *Target\Debugger
  EndIf
  
  If *ActiveSource And (*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile Or *ActiveSource\IsCode)
    NonPBFile = 0
  Else
    NonPBFile = 1
  EndIf
  
  If IsToolBar(#TOOLBAR)
    SetToolBarButtonState(#TOOLBAR, #MENU_Debugger, IsEnabled)
  EndIf
  
  SetMenuItemState(#MENU, #MENU_Debugger, IsEnabled)
  
  *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  
  If *Debugger Or IsEnabled
    If *Debugger And *Debugger\ProgramState <> -1
      Select *Debugger\ProgramState
          
        Case -2 ; means running in step mode
          DisableMenuAndToolbarItem(#MENU_Stop, 0)
          DisableMenuAndToolbarItem(#MENU_Run, 1)
          DisableMenuAndToolbarItem(#MENU_Step, 1)
          DisableMenuAndToolbarItem(#MENU_StepX, 1)
          DisableMenuAndToolbarItem(#MENU_StepOver, 1)
          DisableMenuAndToolbarItem(#MENU_StepOut, 1)
          
        Case 0 ; running
          DisableMenuAndToolbarItem(#MENU_Stop, 0)
          DisableMenuAndToolbarItem(#MENU_Run, 1)
          DisableMenuAndToolbarItem(#MENU_Step, 1)
          DisableMenuAndToolbarItem(#MENU_StepX, 1)
          DisableMenuAndToolbarItem(#MENU_StepOver, 1)
          DisableMenuAndToolbarItem(#MENU_StepOut, 1)
          
        Case 6 ; fatal error (cannot continue)
          DisableMenuAndToolbarItem(#MENU_Stop, 1)
          DisableMenuAndToolbarItem(#MENU_Run, 1)
          DisableMenuAndToolbarItem(#MENU_Step, 1)
          DisableMenuAndToolbarItem(#MENU_StepX, 1)
          DisableMenuAndToolbarItem(#MENU_StepOver, 1)
          DisableMenuAndToolbarItem(#MENU_StepOut, 1)
          
        Case 5 ; program ended
          DisableMenuAndToolbarItem(#MENU_Stop, 1)
          DisableMenuAndToolbarItem(#MENU_Run, 1)
          DisableMenuAndToolbarItem(#MENU_Step, 1)
          DisableMenuAndToolbarItem(#MENU_StepX, 1)
          DisableMenuAndToolbarItem(#MENU_StepOver, 1)
          DisableMenuAndToolbarItem(#MENU_StepOut, 1)
          
        Default ; stopped for some other reason (can continue)
          DisableMenuAndToolbarItem(#MENU_Stop, 1)
          DisableMenuAndToolbarItem(#MENU_Run, 0)
          DisableMenuAndToolbarItem(#MENU_Step, 0)
          DisableMenuAndToolbarItem(#MENU_StepX, 0)
          DisableMenuAndToolbarItem(#MENU_StepOver, 0)
          DisableMenuAndToolbarItem(#MENU_StepOut, 0)
          
      EndSelect
      
      CompilerIf #SpiderBasic
        ; We don't know when a program exits in JS as there is no blocking event loop, so let all the menu/toolbar item always active
      CompilerElse       
        DisableMenuAndToolbarItem(#MENU_Debugger, 1) ; cannot enable/disable the debugger wile it is running
      CompilerEndIf
      
      ; not available if not compiled in purifier mode
      If *Debugger\IsPurifier
        DisableMenuAndToolbarItem(#MENU_Purifier, 0)
      Else
        DisableMenuAndToolbarItem(#MENU_Purifier, 1)
      EndIf
      
      DisableMenuAndToolbarItem(#MENU_Kill, 0)
      DisableMenuAndToolbarItem(#MENU_DebugOutput, 0)
      DisableMenuAndToolbarItem(#MENU_Watchlist, 0)
      DisableMenuAndToolbarItem(#MENU_VariableList, 0)
      DisableMenuAndToolbarItem(#MENU_Profiler, 0)
      DisableMenuAndToolbarItem(#MENU_Memory, 0)
      DisableMenuAndToolbarItem(#MENU_DebugAsm, 0)
      DisableMenuAndToolbarItem(#MENU_History, 0)
      DisableMenuAndToolbarItem(#MENU_LibraryViewer, 0)
      DisableMenuAndToolbarItem(#MENU_DataBreakPoints, 0)
      ;     ElseIf *Debugger
      ;       DisableMenuAndToolbarItem(#MENU_Debugger, 0)
      ;
      ;       DisableMenuAndToolbarItem(#MENU_Stop, 1)
      ;       DisableMenuAndToolbarItem(#MENU_Run, 1)
      ;       DisableMenuAndToolbarItem(#MENU_Step, 1)
      ;       DisableMenuAndToolbarItem(#MENU_StepX, 1)
      ;       DisableMenuAndToolbarItem(#MENU_Kill, 0) ; enable only the kill, to be enable to do a "cleanup" when the exe does not even start.
      ;       DisableMenuAndToolbarItem(#MENU_DebugOutput, 1)
      ;       DisableMenuAndToolbarItem(#MENU_Watchlist, 1)
      ;       DisableMenuAndToolbarItem(#MENU_VariableList, 1)
      ;       DisableMenuAndToolbarItem(#MENU_Memory, 1)
      ;       DisableMenuAndToolbarItem(#MENU_DebugAsm, 1)
      ;       DisableMenuAndToolbarItem(#MENU_History, 1)
    Else
      DisableMenuAndToolbarItem(#MENU_Debugger, 0)
      
      DisableMenuAndToolbarItem(#MENU_Stop, 1)
      DisableMenuAndToolbarItem(#MENU_Run, 1)
      DisableMenuAndToolbarItem(#MENU_Step, 1)
      DisableMenuAndToolbarItem(#MENU_StepX, 1)
      DisableMenuAndToolbarItem(#MENU_StepOver, 1)
      DisableMenuAndToolbarItem(#MENU_StepOut, 1)
      
      CompilerIf #SpiderBasic
        ; We don't know when a program exits in JS as there is no blocking event loop, so let all the menu/toolbar item always active
      CompilerElse       
        DisableMenuAndToolbarItem(#MENU_Kill, 1)
      CompilerEndIf
      
      DisableMenuAndToolbarItem(#MENU_DebugOutput, 1)
      DisableMenuAndToolbarItem(#MENU_Watchlist, 1)
      DisableMenuAndToolbarItem(#MENU_VariableList, 1)
      DisableMenuAndToolbarItem(#MENU_Memory, 1)
      DisableMenuAndToolbarItem(#MENU_DebugAsm, 1)
      DisableMenuAndToolbarItem(#MENU_History, 1)
      DisableMenuAndToolbarItem(#MENU_LibraryViewer, 1)
      DisableMenuAndToolbarItem(#MENU_Profiler, 1)
      DisableMenuAndToolbarItem(#MENU_DataBreakPoints, 1)
      DisableMenuAndToolbarItem(#MENU_Purifier, 1)
    EndIf
    
  ElseIf IsEnabled And NonPBFile = 0
    DisableMenuAndToolbarItem(#MENU_Debugger, 0)
    
    DisableMenuAndToolbarItem(#MENU_Stop, 1)
    DisableMenuAndToolbarItem(#MENU_Run, 1)
    DisableMenuAndToolbarItem(#MENU_Step, 1)
    DisableMenuAndToolbarItem(#MENU_StepX, 1)
    DisableMenuAndToolbarItem(#MENU_StepOver, 1)
    DisableMenuAndToolbarItem(#MENU_StepOut, 1)
    
    CompilerIf #SpiderBasic
      ; We don't know when a program exits in JS as there is no blocking event loop, so let all the menu/toolbar item always active
    CompilerElse   
      DisableMenuAndToolbarItem(#MENU_Kill, 1)
    CompilerEndIf
    
    DisableMenuAndToolbarItem(#MENU_DebugOutput, 1)
    DisableMenuAndToolbarItem(#MENU_Watchlist, 1)
    DisableMenuAndToolbarItem(#MENU_VariableList, 1)
    DisableMenuAndToolbarItem(#MENU_DebugAsm, 1)
    DisableMenuAndToolbarItem(#MENU_History, 1)
    DisableMenuAndToolbarItem(#MENU_Memory, 1)
    DisableMenuAndToolbarItem(#MENU_LibraryViewer, 1)
    DisableMenuAndToolbarItem(#MENU_Profiler, 1)
    DisableMenuAndToolbarItem(#MENU_DataBreakPoints, 1)
    DisableMenuAndToolbarItem(#MENU_Purifier, 1)
    
    
    ; ;     If *StartSource And *StartSource\RunDebuggerMode = 3 ; console debugger
    ; ;       DisableMenuAndToolbarItem(#MENU_BreakPoint, 1)
    ; ;       DisableMenuAndToolbarItem(#MENU_BreakClear, 1)
    ; ;     Else
    ;       DisableMenuAndToolbarItem(#MENU_BreakPoint, 0)
    ;       DisableMenuAndToolbarItem(#MENU_BreakClear, 0)
    ; ;     EndIf
    
  Else
    DisableMenuAndToolbarItem(#MENU_Debugger, NonPBFile)
    
    DisableMenuAndToolbarItem(#MENU_Stop, 1)
    DisableMenuAndToolbarItem(#MENU_Run, 1)
    DisableMenuAndToolbarItem(#MENU_Step, 1)
    DisableMenuAndToolbarItem(#MENU_StepX, 1)
    DisableMenuAndToolbarItem(#MENU_StepOver, 1)
    DisableMenuAndToolbarItem(#MENU_StepOut, 1)
    
    CompilerIf #SpiderBasic
      ; We don't know when a program exits in JS as there is no blocking event loop, so let all the menu/toolbar item always active
    CompilerElse 
      DisableMenuAndToolbarItem(#MENU_Kill, 1)
    CompilerEndIf
    
    DisableMenuAndToolbarItem(#MENU_BreakPoint, NonPBFile)
    DisableMenuAndToolbarItem(#MENU_BreakClear, NonPBFile)
    DisableMenuAndToolbarItem(#MENU_DataBreakPoints, 1)
    DisableMenuAndToolbarItem(#MENU_ShowLog, 1)
    ;     DisableMenuAndToolbarItem(#MENU_ClearLog, 1)
    ;     DisableMenuAndToolbarItem(#MENU_CopyLog, 1)
    DisableMenuAndToolbarItem(#MENU_DebugOutput, 1)
    DisableMenuAndToolbarItem(#MENU_Watchlist, 1)
    DisableMenuAndToolbarItem(#MENU_VariableList, 1)
    DisableMenuAndToolbarItem(#MENU_DebugAsm, 1)
    DisableMenuAndToolbarItem(#MENU_History, 1)
    DisableMenuAndToolbarItem(#MENU_Memory, 1)
    DisableMenuAndToolbarItem(#MENU_LibraryViewer, 1)
    DisableMenuAndToolbarItem(#MENU_Profiler, 1)
    DisableMenuAndToolbarItem(#MENU_Purifier, 1)
  EndIf
  
  If *ActiveSource And *ActiveSource <> *ProjectInfo
    DisableMenuAndToolbarItem(#MENU_BreakPoint, 0)
    DisableMenuAndToolbarItem(#MENU_BreakClear, 0)
    DisableMenuAndToolbarItem(#MENU_ClearErrorMarks, 0)
  Else
    DisableMenuAndToolbarItem(#MENU_BreakPoint, 1)
    DisableMenuAndToolbarItem(#MENU_BreakClear, 1)
    DisableMenuAndToolbarItem(#MENU_ClearErrorMarks, 1)
  EndIf
  
  CompilerIf #CompilePPC
    DisableMenuAndToolbarItem(#MENU_DebugAsm, 1) ; TODO: ASM registers support not supported on OS X
  CompilerEndIf
  
  UpdateErrorLogMenuState()
EndProcedure

Procedure Debugger_AddLog_BySource(*Source.SourceFile, Message$, TimeStamp)
  If LogTimeStamp
    Message$ = "[" + FormatDate(Language("Debugger","TimeStamp"), TimeStamp) + "] " + Message$
  EndIf
  
  If *Source = *ProjectInfo Or *Source\ProjectFile ; project mode
    
    ; limit the project log size too (like normal files), so the list stays readable
    ;
    If ListSize(ProjectLog()) = #MAX_ErrorLog*10
      FirstElement(ProjectLog())
      DeleteElement(ProjectLog())
    EndIf
    
    LastElement(ProjectLog())
    AddElement(ProjectLog())
    ProjectLog() = Message$
    
  Else
    ; add the messages to the source structure
    ;
    If *Source\LogSize = #MAX_ErrorLog  ; log buffer is full (remove first line)
      For i = 0 To #MAX_ErrorLog-2
        *Source\LogLines$[i] = *Source\LogLines$[i+1]
      Next i
      *Source\LogSize - 1
    EndIf
    
    *Source\LogLines$[*Source\LogSize] = Message$
    *Source\LogSize + 1
  EndIf
  
  ; the *Source is not necessarily the active source, so do not just add the
  ; message to the log, but update the full list now
  ;
  ErrorLog_Refresh()
  
  UpdateErrorLogMenuState()
  
EndProcedure

Procedure Debugger_AddLog(*Debugger.DebuggerData, Message$, TimeStamp)
  If LogTimeStamp And TimeStamp <> 0
    Message$ = "[" + FormatDate(Language("Debugger","TimeStamp"), TimeStamp) + "] " + Message$
  EndIf
  
  ; add message to the gadget
  ;
  If ((*ActiveSource = *ProjectInfo Or *ActiveSource\ProjectFile) And *Debugger\ID = ProjectDebuggerID) Or (*Debugger = IsDebuggedFile(*ActiveSource))
    AddGadgetItem(#GADGET_ErrorLog, -1, Message$)
    SetGadgetState(#GADGET_ErrorLog, CountGadgetItems(#GADGET_ErrorLog)-1)
  EndIf
  
  If *Debugger\ID = ProjectDebuggerID
    
    ; limit the project log size too (like normal files), so the list stays readable
    ;
    If ListSize(ProjectLog()) = #MAX_ErrorLog*10
      FirstElement(ProjectLog())
      DeleteElement(ProjectLog())
    EndIf
    
    LastElement(ProjectLog())
    AddElement(ProjectLog())
    ProjectLog() = Message$
    
  Else
    
    ; add the messages to all source files associated with this debugger
    ;
    ForEach FileList()
      If @FileList() <> *ProjectInfo And *Debugger = IsDebuggedFile(@FileList())
        
        If FileList()\LogSize = #MAX_ErrorLog  ; log buffer is full (remove first line)
          For i = 0 To #MAX_ErrorLog-2
            FileList()\LogLines$[i] = FileList()\LogLines$[i+1]
          Next i
          FileList()\LogSize - 1
        EndIf
        
        FileList()\LogLines$[FileList()\LogSize] = Message$
        FileList()\LogSize + 1
      EndIf
    Next FileList()
    ChangeCurrentElement(FileList(), *ActiveSource)
    
  EndIf
  
  ; update menu state
  UpdateErrorLogMenuState()
  
EndProcedure

; called before the exe is terminated in any way to save the watchlist
; in the source file
;
Procedure Debugger_SaveWatchlist(*Debugger.DebuggerData)
  
  ; Find the target that triggered the compile
  ;
  *Target.CompileTarget = FindTargetFromID(*Debugger\TriggerTargetID)
  
  If *Target
    
    ; Save the purifier options
    If *Debugger\IsPurifier
      *Target\PurifierGranularity$ = GetPurifierOptions(*Debugger)
    EndIf
    
    ; save the debug window history (if any)
    ;
    If *Debugger\Windows[#DEBUGGER_WINDOW_Debug]
      Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]
      *Target\ExpressionHistorySize = CountGadgetItems(Gadget)
      
      If *Target\ExpressionHistorySize > #MAX_EpressionHistory
        *Target\ExpressionHistorySize = #MAX_EpressionHistory
      EndIf
      
      For i = 0 To *Target\ExpressionHistorySize - 1
        *Target\ExpressionHistory$[i] = GetGadgetItemText(Gadget, i)
      Next i
    EndIf
    
    ; There is no reading from the program below
    ; this kills the watchlist save feature!
    ;If *Debugger\ProgramState = -1 ; after a fatal error, this can happen.
    ;  ProcedureReturn ; cannot read from unloaded/unconnected exe
    ;EndIf
    
    *Target\Watchlist$ = ""
    
    ;
    ; NOTE: we access the ListIconGadget of the VariableGadget directly here
    ; This only works as long as there are no structures in it!
    ; (which are currently not supported in the watchlist anyway)
    ; so if there are ever structures supported here, this MUST be changed!
    ;
    
    Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List]
    size = CountGadgetItems(Gadget)
    If size > 0
      For i = 1 To size
        ProcName$ = GetGadgetItemText(Gadget, i-1, 1)
        If ProcName$ <> ""
          *Target\Watchlist$ + ProcName$ + ">"
        EndIf
        *Target\Watchlist$ + GetGadgetItemText(Gadget, i-1, 2) + ";"
      Next i
      
      ; cut the last ","
      *Target\Watchlist$ = Left(*Target\Watchlist$, Len(*Target\Watchlist$)-1)
    EndIf
    
    ; remove all spaces to save space
    ; (to array indexes, there are automatically spaces added)
    *Target\Watchlist$ = RemoveString(*Target\Watchlist$, " ")
    
    
  EndIf
  
EndProcedure

Procedure Debugger_Started(*Debugger.DebuggerData)
  
  ; Output warnings for the various internal debugging features
  ;
  CompilerIf #NOTHREAD
    Debugger_AddLog(*Debugger, "WARNING! #NOTHREAD communication is used. This is for IDE debugging only! (see DebuggerCommon.pb)", 0)
  CompilerEndIf
  
  CompilerIf #PRINT_DEBUGGER_COMMANDS
    Debugger_AddLog(*Debugger, "WARNING! #PRINT_DEBUGGER_COMMANDS is set. This is for IDE debugging only! (see DebuggerCommon.pb)", 0)
  CompilerEndIf
  
  CompilerIf #LOG_DEBUGGER_COMMANDS
    Debugger_AddLog(*Debugger, "WARNING! #LOG_DEBUGGER_COMMANDS is set. The output file is: "+#LOG_DEBUGGER_FILE, 0)
  CompilerEndIf
  
  ; transmit the set breakpoints to the exe
  ;
  ForEach FileList()
    If @FileList() <> *ProjectInfo And IsDebuggedFile(@FileList()) = *Debugger  ; get all open files included in this debugger
      
      ClearErrorLines(@FileList()) ; clear the errors in all lines
      SetReadOnly(FileList()\EditorGadget, 1) ; make all included sources readonly
      
      ; enumerate all lines and transmit breakpoint messages for each breakpoint
      File = GetDebuggerFileNumber(*Debugger, @FileList())
      Line = -1
      Repeat
        Line = GetBreakPoint(@FileList(), Line+1)
        If Line <> -1
          
          Command.CommandInfo\Command = #COMMAND_BreakPoint
          Command\Value1 = 1 ; set breakpoint
          Command\Value2 = MakeDebuggerLine(File, Line)
          Command\DataSize = 0
          SendDebuggerCommand(*Debugger, @Command)
          
        EndIf
      Until Line = -1
      
    EndIf
  Next FileList()
  ChangeCurrentElement(FileList(), *ActiveSource)
  
  ; transmit watchlist to exe
  ;
  *Target.CompileTarget = FindTargetFromID(*Debugger\TriggerTargetID)
  If *Target
    
    ; load DebutOutput expression history
    ;
    Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]
    For i = 0 To *Target\ExpressionHistorySize - 1
      AddGadgetItem(Gadget, -1, *Target\ExpressionHistory$[i])
    Next i
    
    
    If *Target\Watchlist$ <> ""
      index = 1
      Entry$ = StringField(*Target\Watchlist$, index, ";")
      While Entry$ <> ""
        If FindString(Entry$, ">", 1) = 0
          ProcIndex = -1
          Variable$ = Entry$
        Else
          ProcName$ = UCase(RemoveString(StringField(Entry$, 1, ">"), "()"))
          Variable$ = StringField(Entry$, 2, ">")
          
          ProcIndex = -1  ; get the index of this procedure in the list
          If *Debugger\Procedures
            *pointer = *Debugger\Procedures
            For i = 0 To *Debugger\NbProcedures-1
              Proc$ = UCase(PeekAscii(*pointer))
              *pointer + MemoryAsciiLength(*pointer) + 1
              ModName$ = UCase(PeekAscii(*pointer))
              *pointer + MemoryAsciiLength(*pointer) + 1
              
              If ModuleName(Proc$, ModName$) = ProcName$
                ProcIndex = i
                Break
              EndIf
            Next i
          EndIf
        EndIf
        
        ; Convert to UTF8 to correctly preserve Map keys (which may contain unicode chars)
        UTF8Length = StringByteLength(Variable$) + 1
        VariableUTF8$ = Space(UTF8Length)
        PokeS(@VariableUTF8$, Variable$, -1, #PB_UTF8)
        
        Command.CommandInfo\Command = #COMMAND_WatchlistAdd
        Command\Value1 = ProcIndex
        Command\Value2 = 0 ; report no errors!
        Command\DataSize = UTF8Length
        SendDebuggerCommandWithData(*Debugger, @Command, @VariableUTF8$)
        
        index + 1
        Entry$ = StringField(*Target\Watchlist$, index, ";")
      Wend
      
      ; update complete list:
      ;
      Command.CommandInfo\Command = #COMMAND_GetWatchlist
      SendDebuggerCommand(*Debugger, @Command)
      
    EndIf
    
    ; Apply any saved purifier options (ignored if purifier is off)
    If *Target\PurifierGranularity$ <> ""
      ApplyDefaultPurifierOptions(*Debugger, *Target\PurifierGranularity$)
    EndIf
  EndIf
  
  ; Do this to update the Filename for all "automatic open" windows (else it remains empty!)
  Debugger_UpdateWindowPreferences()
  
  ; tell the executable to start executing
  ;
  Command.CommandInfo\Command = #COMMAND_Run
  Command\Value1 = 0; do not respond with COMMAND_Continued
  SendDebuggerCommand(*Debugger, @Command)
  
  SetDebuggerMenuStates()
  
EndProcedure

Procedure Debugger_Ended(*Debugger.DebuggerData)
  
  Debugger_SaveWatchlist(*Debugger)
  
  ; remove any old current line mark
  ; enable all included sources for editing again
  ;
  ; Note: Check if a source isn't in another debug session as well!
  ForEach FileList()
    If @FileList() <> *ProjectInfo
      ThisDebugger  = #False
      OtherDebugger = #False
      
      ; Check the direct link to a debugger
      ;
      If FileList()\DebuggerID
        *FileDebugger.DebuggerData = FindDebuggerFromID(FileList()\DebuggerID)
        If *FileDebugger = *Debugger
          ThisDebugger = #True
        ElseIf *FileDebugger And *FileDebugger\CanDestroy = 0
          OtherDebugger = #True
        EndIf
      EndIf
      
      ; Check the indirect link as included file
      ;
      If OtherDebugger = #False
        ForEach RunningDebuggers()
          If RunningDebuggers()\CanDestroy = 0
            
            ; debugger main file
            If IsEqualFile(FileList()\FileName$, RunningDebuggers()\FileName$)
              If @RunningDebuggers() = *Debugger
                ThisDebugger = #True
              Else
                OtherDebugger = #True
                Break  ; no need to look further in this case
              EndIf
            EndIf
            
            ; included files
            If RunningDebuggers()\IncludedFiles ; is filename buffer initialized
              *Cursor = RunningDebuggers()\IncludedFiles
              *Cursor + MemoryAsciiLength(*Cursor) + 1 ; skip the source path string
              *Cursor + MemoryAsciiLength(*Cursor) + 1 ; skip the main source name (checked above)
              For i = 1 To RunningDebuggers()\NbIncludedFiles  ; check all included files
                                                               ; the included filenames may include "../" so use ResolveRelativePath() on them, which resolves that to get a unique filename
                FileName$ = UniqueFilename(PeekUTF8(*Cursor))
                If IsEqualFile(FileList()\FileName$, FileName$)
                  If @RunningDebuggers() = *Debugger
                    ThisDebugger = #True
                  Else
                    OtherDebugger = #True
                    Break  ; no need to look further in this case
                  EndIf
                EndIf
                *Cursor + MemoryAsciiLength(*Cursor) + 1
              Next i
            EndIf
          EndIf
        Next RunningDebuggers()
      EndIf
      
      ; Only clean up when no longer in any debugger's files
      ;
      If ThisDebugger And OtherDebugger = #False
        If DebuggerKeepErrorMarks = 0
          ClearErrorLines(@FileList())
        EndIf
        
        ClearCurrentLine(@FileList())
        SetReadOnly(FileList()\EditorGadget, 0)
      EndIf
    EndIf
  Next FileList()
  ChangeCurrentElement(FileList(), *ActiveSource)
  
  SetDebuggerMenuStates()
  ActivateMainWindow() ; re-enable the focus on editor gadget (https://www.purebasic.fr/english/viewtopic.php?f=4&t=46375&p=352864#p352864)
EndProcedure

; returns true/false
Procedure Debugger_SwitchToFile(*Debugger.DebuggerData, Line)
  FileName$ = GetDebuggerFile(*Debugger, Line)
  
  CompilerIf #SpiderBasic
    If LCase(GetFilePart(FileName$)) = "pb_editoroutput.pb" ; File not yet saved (https://forums.spiderbasic.com/viewtopic.php?t=2549)
      FileName$ = ""
    EndIf
  CompilerEndIf
  
  If FileName$ = "" ; main source, and not saved yet
    CompilerIf #SpiderBasic
      ; SpiderBasic can only have one active debugger, so it's always the active source if the file wasn't saved
      result = 1
    CompilerElse
      *Source.SourceFile = FindTargetFromID(*Debugger\SourceID)
      If *Source And *Source\IsProject = 0 ; sanity check
        If *Source <> *ActiveSource        ; check to reduce flickering (especially for step)
          ChangeCurrentElement(FileList(), *Source)
          ChangeActiveSourceCode()
        EndIf
        result = 1
      Else
        result = 0
      EndIf
    CompilerEndIf
  ElseIf IsEqualFile(FileName$, *ActiveSource\FileName$)
    result = 1
  Else
    result = LoadSourceFile(FileName$)
  EndIf
  
  ProcedureReturn result
EndProcedure

Procedure DebuggerCallback(*Debugger.DebuggerData)
  
  CompilerIf #PB_Compiler_Debugger
    InDebuggerCallback = #True
  CompilerEndIf
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_FatalError  ; fatal communication error
      Select *Debugger\Command\Value1
        Case #ERROR_Memory
          Text$ = Language("Debugger", "MemoryError")
        Case #ERROR_Pipe
          Text$ = Language("Debugger", "PipeError")
        Case #ERROR_ExeQuit
          Text$ = Language("Debugger", "ExeQuitError")
        Case #ERROR_Timeout
          Text$ = LanguagePattern("Debugger", "TimeoutError", "%timeout%", StrF(DebuggerTimeout / 1000.0, 0))
        Case #ERROR_Version
          Text$ = Language("Debugger", "VersionError")
        Case #ERROR_NetworkFail
          Text$ = Language("Debugger", "NetworkError")
      EndSelect
      
      Text$ = StringField(Text$, 1, Left(#NewLine, 1)) ; first line only
      
      Debugger_AddLog(*Debugger, Text$, *Debugger\Command\TimeStamp)
      Debugger_Ended(*Debugger) ; re-enable editing the sources
      ChangeStatus(Text$, 3000)
      
      ;Case #COMMAND_Init
      ; NOTE: we do nothing on the init command.. we first wait for the requested
      ; COMMAND_GetProcedures to return, so we can init the watchlist and stuff
      
    Case #COMMAND_Procedures
      ; set the warning mode
      Command.CommandInfo\Command = #COMMAND_WarningMode
      *Target.CompileTarget = FindTargetFromID(*Debugger\TriggerTargetID)
      If *Target And *Target\CustomWarning
        Command\Value1 = *Target\WarningMode
      Else
        Command\Value1 = WarningMode ; global setting
      EndIf
      SendDebuggerCommand(*Debugger, @Command)
      
      ; here the program really starts
      Debugger_AddLog(*Debugger, Language("Debugger","ExeStarted"), *Debugger\Command\TimeStamp)
      Debugger_Started(*Debugger)
      ChangeStatus(Language("Debugger","ExeStarted"), -1)
      
    Case #COMMAND_End
      Debugger_AddLog(*Debugger, Language("Debugger","ExeEnded"), *Debugger\Command\TimeStamp)
      Debugger_Ended(*Debugger)
      ChangeStatus(Language("Debugger","ExeEnded"), 3000)
      
    Case #COMMAND_ExeMode
      Text$ = Language("Debugger","ExecutableType") + ": "
      
      Select (*Debugger\Command\Value2 >> 16) & $FFFF
        Case 1: Text$ + "Windows"
        Case 2: Text$ + "Linux"
        Case 3: Text$ + "MacOSX"
      EndSelect
      
      Select *Debugger\Command\Value2 & $FFFF
        Case 1: Text$ + " - x86"
        Case 2: Text$ + " - x64"
        Case 3: Text$ + " - ppc"
        Case 4: Text$ + " - arm64"
      EndSelect
      
      If *Debugger\Is64bit
        Text$ + "  (64bit"
      Else
        Text$ + "  (32bit"
      EndIf
      If *Debugger\IsUnicode: Text$ + ", Unicode": EndIf
      If *Debugger\IsThread : Text$ + ", Thread" : EndIf
      If *Debugger\IsPurifier: Text$ + ", Purifier": EndIf
      Text$ + ")"
      
      Debugger_AddLog(*Debugger, Text$, *Debugger\Command\TimeStamp)
      
      
    Case #COMMAND_Error
      FileName$ = GetDebuggerFile(*Debugger, *Debugger\Command\Value1)
      LineNumber = DebuggerLineGetLine(*Debugger\Command\Value1) + 1
      
      If Debugger_SwitchToFile(*Debugger, *Debugger\Command\Value1)
        ; the compiled file has the IDE settings appended to it, so the reported error line
        ; might be bigger than what the user sees. correct this here
        If LineNumber > GetLinesCount(*ActiveSource)
          LineNumber = GetLinesCount(*ActiveSource)
        EndIf
        
        ; remove any old current line mark
        ForEach FileList()
          If @FileList() <> *ProjectInfo And IsDebuggedFile(@FileList()) = *Debugger  ; get all open files belonging to this debugger
            ClearCurrentLine(@FileList())
          EndIf
        Next FileList()
        ChangeCurrentElement(FileList(), *ActiveSource)
        
        MarkErrorLine(LineNumber)
        CompilerIf #SpiderBasic
          ; As we don't have a read only scintilla, the red line is overriden by the active line background and we don't see it. So just select the line below and so we can see it.
          ChangeActiveLine(LineNumber+1, -5)
        CompilerElse
          MarkCurrentLine(LineNumber)
        CompilerEndIf
      EndIf
      
      If FileName$ <> ""
        Debugger_AddLog(*Debugger, Language("Debugger", "LogError") + " " + GetFilePart(FileName$) + " ("+Language("Misc","Line")+": " + Str(LineNumber)+")", *Debugger\Command\TimeStamp)
      Else
        Debugger_AddLog(*Debugger, Language("Debugger", "LogError") +" "+Language("Misc","Line")+": " + Str(LineNumber), *Debugger\Command\TimeStamp)
      EndIf
      Debugger_AddLog(*Debugger, Language("Debugger", "LogError") +" " + PeekUTF8(*Debugger\CommandData), *Debugger\Command\TimeStamp)
      
      ChangeStatus(Language("Misc","Line")+": " + Str(LineNumber) +" - " +  PeekUTF8(*Debugger\CommandData), -1)
      
      If DebuggerKillOnError
        Debugger_Ended(*Debugger)
        
        CompilerIf Not #SpiderBasic
          Debugger_ForceDestroy(*Debugger)
        CompilerEndIf
      EndIf
      
      SetDebuggerMenuStates()
      SetWindowForeGround(#WINDOW_Main)
      
    Case #COMMAND_Warning
      FileName$ = GetDebuggerFile(*Debugger, *Debugger\Command\Value1)
      LineNumber = DebuggerLineGetLine(*Debugger\Command\Value1) + 1
      
      If Debugger_SwitchToFile(*Debugger, *Debugger\Command\Value1)
        ; the compiled file has the IDE settings appended to it, so the reported error line
        ; might be bigger than what the user sees. correct this here
        If LineNumber > GetLinesCount(*ActiveSource)
          LineNumber = GetLinesCount(*ActiveSource)
        EndIf
        
        ; just mark as warning, no stop or currentline change
        MarkWarningLine(LineNumber)
      EndIf
      
      If FileName$ <> ""
        Debugger_AddLog(*Debugger, Language("Debugger", "LogWarning") + " " + GetFilePart(FileName$) + " ("+Language("Misc","Line")+": " + Str(LineNumber)+")", *Debugger\Command\TimeStamp)
      Else
        Debugger_AddLog(*Debugger, Language("Debugger", "LogWarning") +" "+Language("Misc","Line")+": " + Str(LineNumber), *Debugger\Command\TimeStamp)
      EndIf
      Debugger_AddLog(*Debugger, Language("Debugger", "LogWarning") +" " + PeekUTF8(*Debugger\CommandData), *Debugger\Command\TimeStamp)
      
      ChangeStatus(Language("Misc","Line")+": " + Str(LineNumber) +" - " +  PeekUTF8(*Debugger\CommandData), -1)
      
      
    Case #COMMAND_Stopped
      Text$ = Language("Debugger","Stopped")
      
      Select *Debugger\Command\Value2
        Case 3: Text$ + " (CallDebugger)": SetWindowForeGround(#WINDOW_Main)
        Case 5: Text$ + " ("+Language("Debugger","BeforeEnd")+")": SetWindowForeGround(#WINDOW_Main)
        Case 7: Text$ + " ("+Language("Debugger","BreakPoint")+")": SetWindowForeGround(#WINDOW_Main)
        Case 8: Text$ + " ("+Language("Debugger","UserRequest")+")"
          
        Case 9
          ; The DataBreakpoint functions have processed the eariler #COMMAND_DataBreakPoint,
          ; so the matching Condition is marked in the breakpoint list
          Text$ + " (" + Language("Debugger","DataBreakpoint")
          *Point.DataBreakPoint = *Debugger\FirstDataBreakPoint
          While *Point
            If *Point\ConditionTrue
              Text$ + ": " + *Point\Condition$
              Break
            Else
              *Point = *Point\Next
            EndIf
          Wend
          Text$ + ")"
          
          SetWindowForeGround(#WINDOW_Main)
          If *Debugger\DataBreakpointsVisible
            SetWindowForeGround(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints])
          EndIf
          
      EndSelect
      
      If *Debugger\LastProgramState <> -2  ; don't log a stop after a Step command
        Debugger_AddLog(*Debugger, Text$, *Debugger\Command\TimeStamp)
      EndIf
      ChangeStatus(Text$, -1)
      
      ;       Debug "---------- Stopped ----------------------"
      ;       Debug "Line: "+Str(*Debugger\Command\Value1)
      ;       Debug "FilePart: "+Str(DebuggerLineGetFile(*Debugger\Command\Value1))
      ;       Debug GetDebuggerFile(*Debugger, *Debugger\Command\Value1)
      
      If *Debugger\Command\Value1 <> -1 ; check to ensure correct currentline value
        
        FileName$ = GetDebuggerFile(*Debugger, *Debugger\Command\Value1)
        LineNumber = DebuggerLineGetLine(*Debugger\Command\Value1) + 1
        
        If Debugger_SwitchToFile(*Debugger, *Debugger\Command\Value1)
          ; the compiled file has the IDE settings appended to it, so the reported error line
          ; might be bigger than what the user sees. correct this here
          If LineNumber > GetLinesCount(*ActiveSource)
            LineNumber = GetLinesCount(*ActiveSource)
          EndIf
          
          ; remove any old current line mark
          ForEach FileList()
            If @FileList() <> *ProjectInfo And IsDebuggedFile(@FileList()) = *Debugger  ; get all open files belonging to this debugger
              ClearCurrentLine(@FileList())
            EndIf
          Next FileList()
          ChangeCurrentElement(FileList(), *ActiveSource)
          
          MarkCurrentLine(LineNumber)
        EndIf
        
      EndIf
      
      SetDebuggerMenuStates()
      
    Case #COMMAND_Continued
      Debugger_AddLog(*Debugger, Language("Debugger","Continued"), *Debugger\Command\TimeStamp)
      ChangeStatus(Language("Debugger","Continued"), -1)
      SetDebuggerMenuStates()
      
      ; remove any old current line mark
      ForEach FileList()
        If @FileList() <> *ProjectInfo And IsDebuggedFile(@FileList()) = *Debugger  ; get all open files belonging to this debugger
          ClearCurrentLine(@FileList())
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource)
      
    Case #COMMAND_Debug
      If DebugOutputToErrorLog ; if set, this procedure is responsible for the debug output
        Message$ = "[Debug] "
        If *Debugger\Command\Value1 = 5 ; long
          If DebugIsHex
            Message$ + Hex(*Debugger\Command\Value2, #PB_Long)
          Else
            Message$ + Str(*Debugger\Command\Value2)
          EndIf
        ElseIf *Debugger\Command\Value1 = 8 ; string
          String$ = PeekS(*Debugger\CommandData, *Debugger\Command\DataSize)
          If Left(String$, 19) = "[OutputDebugString]"
            Message$ = String$ ; do not add the [Debug] from above
          Else
            Message$ + String$
          EndIf
        ElseIf *Debugger\Command\Value1 = 9 ; float
          Message$ + StrF_Debug(PeekF(@*Debugger\Command\Value2))
        EndIf
        
        ; Truncate the Message to avoid display problems on Windows, and because debugging
        ; such large things is no longer reasonably viewable anyway
        ;
        If Len(Message$) > 4096
          Message$ = Left(Message$, 4096) + " [...]"
        EndIf
        
        Debugger_AddLog(*Debugger, Message$, *Debugger\Command\TimeStamp)
      EndIf
      
    Case #COMMAND_DebugDouble
      If DebugOutputToErrorLog ; if set, this procedure is responsible for the debug output
        Debugger_AddLog(*Debugger, "[Debug] " + StrD_Debug(PeekD(@*Debugger\Command\Value1)), *Debugger\Command\TimeStamp)
      EndIf
      
    Case #COMMAND_DebugQuad
      If DebugOutputToErrorLog ; if set, this procedure is responsible for the debug output
        Message$ = "[Debug] "
        If DebugIsHex
          Message$ + Hex(PeekQ(@*Debugger\Command\Value1), #PB_Quad)
        Else
          Message$ + Str(PeekQ(@*Debugger\Command\Value1))
        EndIf
        
        Debugger_AddLog(*Debugger, Message$, *Debugger\Command\TimeStamp)
      EndIf
      
    Case #COMMAND_Expression
      
      ; expression evaluation for tooltips
      ; check if this message is for us (the debug output uses this message too)
      ;
      If *Debugger\Command\Value1 = AsciiConst('S','C','I','N') And *Debugger\CommandData And IsMouseDwelling = 1
        
        Select *Debugger\Command\Value2 ; result code
            
          Case 0 ; error
            Message$ = "Debugger: " + PeekUTF8(*Debugger\CommandData)
            Debug Message$
            
            ; Variable not found is common (place the cursor on a keyword etc),
            ; so display nothing if this happens.
            If IsVariableExpression = 0 Or (Left(Message$, 29) <> "Debugger: Variable not found:" And Left(Message$, 43) <> "Debugger: Array() / LinkedList() not found:" And Message$ <> "Debugger: Garbage at the end of the input.")
              SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
              SendEditorMessage(#SCI_CALLTIPSETHLT, 0, 9)
            EndIf
            
            
          Case 1 ; empty, do nothing
            
          Case 2 ; quad
            Name$    = PeekS(*Debugger\CommandData+8, (*Debugger\Command\DataSize-8) / #CharSize)
            Message$ = Name$ + " = " + Str(PeekQ(*Debugger\CommandData))
            SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            SendEditorMessage(#SCI_CALLTIPSETHLT, 0, Len(Name$))
            
          Case 3 ; double
            Name$    = PeekS(*Debugger\CommandData+8, (*Debugger\Command\DataSize-8) / #CharSize)
            Message$ = Name$ + " = " + StrD_Debug(PeekD(*Debugger\CommandData))
            SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            SendEditorMessage(#SCI_CALLTIPSETHLT, 0, Len(Name$))
            
          Case 4 ; string
            Message$ = PeekS(*Debugger\CommandData, (*Debugger\Command\DataSize) / #CharSize)
            Name$    = PeekS(*Debugger\CommandData + (Len(Message$) + 1) * #CharSize, *Debugger\Command\DataSize / #CharSize - Len(Message$) - 1)
            Message$ = Name$ + " = " + Chr(34) + Message$ + Chr(34)
            
            If Len(Message$) > 100
              Message$ = Left(Message$, 96) + "..."
            EndIf
            
            ; result buffer must be freed
            CodePage = SendEditorMessage(#SCI_GETCODEPAGE)
            *Buffer = StringToCodePage(CodePage, Message$)
            If *Buffer
              SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, *Buffer)
              SendEditorMessage(#SCI_CALLTIPSETHLT, 0, CodePageLength(CodePage, Name$))
              FreeMemory(*Buffer)
            EndIf
            
          Case 5 ; structure
            *Pointer = *Debugger\CommandData
            Message$ = ""
            
            Type$ = PeekS(*Pointer, -1, #PB_Ascii): *Pointer + Len(Type$) + 1
            Count = PeekL(*Pointer): *Pointer + 4
            
            ; Calculate the maximum number of lines to display the tooltip up or down.
            ;
            ; Currently, with MaxLine = 25 hardcoded, no possibility to display more lines for large structures if there is enough space.
            ; If there isn't enough space at the bottom or top, the tolltip isn't displayed at all. 
            ; Large structure tooltip is often not displayed when the cursor is on a middle line, no problem when the cursor is at the top or bottom.
            ;
            ; With the calculation below, the number of lines to be displayed is adjusted (with a 1 line margin to be on the safe side) to the available space, 
            ; And so make sure the tooltip is always displayed with the maximum number of structure fields displayed.
            ;
            ; Windows 10, 11 has thin invisible borders on left, right and bottom. It is used to grip the mouse for resizing. Use SPI_GETWORKAREA instead of OpenWindow
            CompilerIf #PB_Compiler_OS = #PB_OS_Windows
              SystemParametersInfo_(#SPI_GETWORKAREA, 0, @wr.RECT, 0)
              WorkAreaWidth  = wr\right - wr\left
              WorkAreaHeight = wr\bottom - wr\top
            CompilerElse
              DummyWindow = OpenWindow(#PB_Any,0,0,0,0,"",#PB_Window_Invisible | #PB_Window_Maximize | #PB_Window_MaximizeGadget | #PB_Window_NoActivate)
              WorkAreaWidth  = DesktopScaledX(WindowWidth(DummyWindow, #PB_Window_FrameCoordinate))
              WorkAreaHeight = DesktopScaledY(WindowHeight(DummyWindow, #PB_Window_FrameCoordinate))
              CloseWindow(DummyWindow)
            CompilerEndIf
            
            ; ToolTip width enlarged according to the available space between the mouse position and the right desktop border, rather than 100 hard-coded chars
            ; To be aligned with the mouse position. For a full ToolTip, adjusted to the desktop width, use: MaxLenLine = WorkAreaWidth  / SendEditorMessage(#SCI_TEXTWIDTH, #STYLE_DEFAULT, ToAscii("A"))
            MaxLenLine = (WorkAreaWidth - DesktopMouseX()) / SendEditorMessage(#SCI_TEXTWIDTH, #STYLE_DEFAULT, ToAscii("A")) +1   ; +1 for Chr(10), #LF$

            ; Number of lines from top: Remove a line for "Structure: " + Name$ and a second line to ensure that the tooltip is displayed with its borders. 
            MaxLineTop = SendEditorMessage(#SCI_LINEFROMPOSITION, MouseDwellPosition, 0) - SendEditorMessage(#SCI_GETFIRSTVISIBLELINE, 0, 0) - 2
            Debug "ToolTip: Max Line From Top = " + Str(MaxLineTop) + " = " + Str(SendEditorMessage(#SCI_LINEFROMPOSITION, MouseDwellPosition, 0)) + " - " + Str(SendEditorMessage(#SCI_GETFIRSTVISIBLELINE, 0, 0)) + " - 2"

            ; Number of lines to bottom : (from mouse position + height of 1 line) to bottom and remove a line for "Structure: " + Name$
            TextHeight = SendEditorMessage(#SCI_TEXTHEIGHT, 1, 0)
            MaxLineBottom = Round((WorkAreaHeight -  DesktopMouseY() - TextHeight) / TextHeight, #PB_Round_Down) - 1
            Debug "ToolTip: Max Line To Bottom = " + Str(MaxLineBottom) + " = Round((" + Str(WorkAreaHeight) + " - " + Str(DesktopMouseY()) + " - " + Str(TextHeight) + ") / " + Str(TextHeight) + ", #PB_Round_Down) - 1"
            
            MaxLine = Max(MaxLineTop, MaxLineBottom)
            If Count > MaxLine
              MaxLine - 1
            EndIf
            
            For i = 1 To Count
              type        = PeekB(*Pointer): *Pointer + 1
              dynamictype = PeekB(*Pointer): *Pointer + 1
              sublevel    = PeekL(*Pointer): *Pointer + 4
              Name$       = PeekS(*Pointer, -1, #PB_Ascii): *Pointer + Len(Name$) + 1
              Line$       = Chr(10) + Space(sublevel*2 + 1) + "\" + Name$
              
              If IS_ARRAY(type)
                Line$ + "(" + PeekAscii(*Pointer) + ")" ; dimensions
                
              ElseIf IS_LINKEDLIST(type)
                Line$ + "()" ; ignore the current and size for now (looks better)
                
              ElseIf IS_MAP(type)
                Line$ + "()"
                
              ElseIf IS_POINTER(type) ; pointer
                If *Debugger\Is64bit
                  Line$ + " = " + Str(PeekQ(*Pointer))
                Else
                  Line$ + " = " + Str(PeekL(*Pointer))
                EndIf
              Else ; no pointer
                Select type
                  Case #TYPE_BYTE:      Line$ + " = " + Str(PeekB(*Pointer))
                  Case #TYPE_ASCII:     Line$ + " = " + StrU(PeekB(*Pointer), #PB_Byte)
                  Case #TYPE_WORD:      Line$ + " = " + Str(PeekW(*Pointer))
                  Case #TYPE_UNICODE:   Line$ + " = " + StrU(PeekW(*Pointer), #PB_Word)
                  Case #TYPE_LONG:      Line$ + " = " + Str(PeekL(*Pointer))
                  Case #TYPE_STRUCTURE: ; structure, do not add a =
                  Case #TYPE_FLOAT:     Line$ + " = " + StrF_Debug(PeekF(*Pointer))
                  Case #TYPE_DOUBLE:    Line$ + " = " + StrD_Debug(PeekD(*Pointer))
                  Case #TYPE_QUAD:      Line$ + " = " + Str(PeekQ(*Pointer))
                  Case #TYPE_CHARACTER: Line$ + " = " + Str(PeekL(*Pointer)) ; already transformed to int here
                    
                  Case #TYPE_INTEGER
                    If *Debugger\Is64bit
                      Line$ + " = " + Str(PeekQ(*Pointer))
                    Else
                      Line$ + " = " + Str(PeekL(*Pointer))
                    EndIf
                    
                  Case #TYPE_STRING, #TYPE_FIXEDSTRING
                    String$ = PeekS(*Pointer)
                    Line$ + " = " + Chr(34) + String$ + Chr(34)
                EndSelect
              EndIf
              
              *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
              
              ; do not display too large structures !
              If i <= MaxLine
                If Len(Line$) > MaxLenLine
                  Line$ = Left(Line$, MaxLenLine-4) + " ..."
                EndIf
                
                Message$ + Line$
              EndIf
            Next i
            
            If Count > MaxLine
              Message$ + Chr(10) + "..."
            EndIf
            
            Name$ = PeekS(*Pointer) ; request string
            
            Message$ = "Structure: " + Name$ + Message$
            
            ; result buffer must be freed
            CodePage = SendEditorMessage(#SCI_GETCODEPAGE)
            *Buffer = StringToCodePage(CodePage, Message$)
            If *Buffer
              SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, *Buffer)
              SendEditorMessage(#SCI_CALLTIPSETHLT, 0, CodePageLength(CodePage, Name$) + 11)
              FreeMemory(*Buffer)
            EndIf
            
          Case 6 ; long (ppc only)
            Name$    = PeekS(*Debugger\CommandData+4, (*Debugger\Command\DataSize-4) / #CharSize)
            Message$ = Name$ + " = " + Str(PeekL(*Debugger\CommandData))
            SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            SendEditorMessage(#SCI_CALLTIPSETHLT, 0, Len(Name$))
            
          Case 7 ; float (ppc only)
            Name$    = PeekS(*Debugger\CommandData+4, (*Debugger\Command\DataSize-4) / #CharSize)
            Message$ = Name$ + " = " + StrF_Debug(PeekF(*Debugger\CommandData))
            SendEditorMessage(#SCI_CALLTIPSHOW, MouseDwellPosition, ToUTF8(Message$))
            SendEditorMessage(#SCI_CALLTIPSETHLT, 0, Len(Name$))
            
        EndSelect
        
      EndIf
      
  EndSelect
  
  CompilerIf #PB_Compiler_Debugger
    InDebuggerCallback = #False
  CompilerEndIf
  
EndProcedure

Procedure Debugger_ShowLine(*Debugger.DebuggerData, Line)
  
  FileName$ = GetDebuggerFile(*Debugger, Line)
  LineNumber = DebuggerLineGetLine(Line) + 1
  
  If Debugger_SwitchToFile(*Debugger, Line)
    ; make sure the linenumber is not too high (could happen in the profiler)
    If LineNumber > GetLinesCount(*ActiveSource)
      LineNumber = GetLinesCount(*ActiveSource)
    EndIf
    ChangeActiveLine(LineNumber, -5)
    
    ActivateMainWindow()
  EndIf
  
EndProcedure


Procedure ProcessDebuggerEvent()
  
  StandaloneDebuggers_CheckExits()
  
  If Debugger_ProcessIncomingCommands() = 0
  EndIf
  
EndProcedure


; Debugger Menu Actions
; They must check first if the operation is even allowed, as the shortcuts even work
; when the menu is disabled!
;
Procedure Debugger_Run(*Debugger.DebuggerData = 0)
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  If *Debugger
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -1 And *Debugger\ProgramState <> 6 And *Debugger\ProgramState <> 5
      
      Command.CommandInfo\Command = #COMMAND_Run
      Command\Value1 = 1 ; respond with COMMAND_Continued
      SendDebuggerCommand(*Debugger, @Command)
      ; program state is updated once the debugger responds with #COMMAND_Continued
      
    EndIf
  EndIf
EndProcedure

Procedure Debugger_Stop(*Debugger.DebuggerData = 0)
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  If *Debugger
    If *Debugger\ProgramState = 0
      
      Command.CommandInfo\Command = #COMMAND_Stop
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
      ; program state is updated once the debugger responds with #COMMAND_Stopped
      
    EndIf
  EndIf
EndProcedure

Procedure Debugger_Step(*Debugger.DebuggerData = 0)
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  If *Debugger
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -1 And *Debugger\ProgramState <> 6 And *Debugger\ProgramState <> 5
      
      Command.CommandInfo\Command = #COMMAND_Step
      Command\DataSize = 0
      Command\Value1 = 1  ; 1 step
      SendDebuggerCommand(*Debugger, @Command)
      
      *Debugger\ProgramState = -2 ; indicate step mode
      SetDebuggerMenuStates()
      ChangeStatus(Language("Debugger","OneStep"), -1)
      
    EndIf
  EndIf
EndProcedure

Procedure Debugger_StepX(*Debugger.DebuggerData = 0)
  Static LastStepValue
  
  If LastStepValue <= 1
    LastStepValue = 1
  EndIf
  
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  
  If *Debugger
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -1 And *Debugger\ProgramState <> 6 And *Debugger\ProgramState <> 5
      
      StepString$ = InputRequester(#ProductName$ + " Debugger", Language("Debugger","ChooseStep"), Str(LastStepValue))
      If StepString$ <> ""
        
        LastStepValue = Val(StepString$)
        If LastStepValue <= 1
          LastStepValue = 1
        EndIf
        
        Command.CommandInfo\Command = #COMMAND_Step
        Command\DataSize = 0
        Command\Value1 = LastStepValue
        SendDebuggerCommand(*Debugger, @Command)
        
        *Debugger\ProgramState = -2 ; indicate step mode
        SetDebuggerMenuStates()
        ChangeStatus(LanguagePattern("Debugger","StepX", "%x%", Str(LastStepValue)), -1)
      EndIf
      
    EndIf
  EndIf
EndProcedure

Procedure Debugger_StepOver(*Debugger.DebuggerData = 0)
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  If *Debugger
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -1 And *Debugger\ProgramState <> 6 And *Debugger\ProgramState <> 5
      
      Command.CommandInfo\Command = #COMMAND_Step
      Command\DataSize = 0
      Command\Value1 = -1  ; means "step over"
      SendDebuggerCommand(*Debugger, @Command)
      
      *Debugger\ProgramState = -2 ; indicate step mode
      SetDebuggerMenuStates()
      ChangeStatus(Language("Debugger","StepOver"), -1)
      
    EndIf
  EndIf
EndProcedure

Procedure Debugger_StepOut(*Debugger.DebuggerData = 0)
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  If *Debugger
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -1 And *Debugger\ProgramState <> 6 And *Debugger\ProgramState <> 5
      
      Command.CommandInfo\Command = #COMMAND_Step
      Command\DataSize = 0
      Command\Value1 = -2  ; means "step out"
      SendDebuggerCommand(*Debugger, @Command)
      
      *Debugger\ProgramState = -2 ; indicate step mode
      SetDebuggerMenuStates()
      ChangeStatus(Language("Debugger","StepOut"), -1)
      
    EndIf
  EndIf
EndProcedure

; kill kills the executable and removes all open windows
; (thus effectively "cleaning" up all that belongs to it)
; the debugger structure is then removed too.
;
Procedure Debugger_Kill(*Debugger.DebuggerData = 0)
  If *Debugger = 0 ; get the activesource debugger if none is supplied
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
  EndIf
  If *Debugger
    
    Debugger_SaveWatchlist(*Debugger)
    
    ; remove any old current line mark
    ; enable all included sources for editing again
    ; must be before the destruction of the debugger structure!
    ForEach FileList()
      If @FileList() <> *ProjectInfo And IsDebuggedFile(@FileList()) = *Debugger  ; get all open files belonging to this debugger
        If DebuggerKeepErrorMarks = 0
          ClearErrorLines(@FileList())
        EndIf
        
        ClearCurrentLine(@FileList())
        SetReadOnly(FileList()\EditorGadget, 0)
      EndIf
    Next FileList()
    ChangeCurrentElement(FileList(), *ActiveSource)
    
    Debugger_AddLog(*Debugger, Language("Debugger","ExeKilled"), Date())
    ChangeStatus(Language("Debugger","ExeKilled"), 3000)
    
    Debugger_ForceDestroy(*Debugger) ; force removing of the debugger/exe
    
    SetDebuggerMenuStates()
  EndIf
  
EndProcedure


; this two always work, however they only transmit
; the changes when there is a running debugger
;
Procedure Debugger_BreakPoint(Line)
  
  If *ActiveSource <> *ProjectInfo
    If GetBreakPoint(*ActiveSource, Line) = Line ; there is a breakpoint on this line
      ClearBreakPoint(Line)
      Action = 2 ; remove breakpoint
    Else
      MarkBreakPoint(Line)
      Action = 1 ; add breakpoint
    EndIf
    
    *Debugger.DebuggerData = IsDebuggedFile(*ActiveSource)
    If *Debugger
      Command.CommandInfo\Command = #COMMAND_BreakPoint
      Command\Value1 = Action
      Command\Value2 = MakeDebuggerLine(GetDebuggerFileNumber(*Debugger, *ActiveSource), Line)
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
  EndIf
  
EndProcedure


Procedure Debugger_ClearBreakPoints()
  
  If *ActiveSource <> *ProjectInfo
    ClearAllBreakPoints(*ActiveSource)
    
    *Debugger.DebuggerData = IsDebuggedFile(*ActiveSource)
    If *Debugger
      Command.CommandInfo\Command = #COMMAND_BreakPoint
      Command\Value1 = 3 ; clear all
      Command\Value2 = GetDebuggerFileNumber(*Debugger, *ActiveSource)
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
  EndIf
  
EndProcedure

Procedure Debugger_EvaluateAtCursor(position)
  
  If *ActiveSource <> *ProjectInfo
    *Debugger.DebuggerData = GetDebuggerForFile(*ActiveSource)
    If *Debugger
      Expr$ = ""
      
      ; if the mouse is over a selection, evaluate the
      ; entire selection
      ;
      selStart = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
      selEnd = SendEditorMessage(#SCI_GETSELECTIONEND  , 0, 0)
      If selStart > selEnd
        Swap selStart, selEnd
      EndIf
      
      If selStart <= position And selStart <> selEnd And position <= selEnd
        ; multiline is now allowed, as there could be a line continuation
        Expr$ = Space(selEnd - selStart)
        range.TextRange\chrg\cpMin  = selStart
        range\chrg\cpMax            = selEnd
        range\lpstrText             = @Expr$
        SendEditorMessage(#SCI_GETTEXTRANGE, 0, @range)
        
        If *ActiveSource\Parser\Encoding = 1
          Expr$ = PeekS(@Expr$, -1, #PB_UTF8)
        Else
          Expr$ = PeekS(@Expr$, -1, #PB_Ascii)
        EndIf
        
        Expr$ = Trim(Expr$)
        IsVariableExpression = 0
      EndIf
      
      ; try the current word now if the selection is not ok
      ;
      If Expr$ = ""
        Line      = SendEditorMessage(#SCI_LINEFROMPOSITION, position, 0)
        linestart = SendEditorMessage(#SCI_POSITIONFROMLINE, line, 0)
        column    = CountCharacters(*ActiveSource\EditorGadget, linestart, position)
        Line$     = GetLine(line)
        
        If Line$ <> ""
          GetWordBoundary(@Line$, Len(Line$), column, @selStart, @selEnd, 1) ; include * or #
          If Mid(Line$, selEnd+2, 2) = "()"
            selEnd + 2
          EndIf
          If Mid(Line$, selStart, 1) = "$" Or Mid(Line$, selStart, 1) = "%"
            selStart-1
          EndIf
          
          Expr$ = Mid(Line$, selStart+1, selEnd - selStart + 1)
          IsVariableExpression = 1
        EndIf
      EndIf
      
      ; Evaluate if there is a debugger...
      ;
      If Expr$ <> ""
        Debug Expr$
        Command.CommandInfo\Command = #COMMAND_EvaluateExpressionWithStruct  ; structures allowed
        Command\Value1 = AsciiConst('S','C','I','N')                         ; to identify the sender
        Command\Value2 = MakeDebuggerLine(GetDebuggerFileNumber(*Debugger, *ActiveSource), SendEditorMessage(#SCI_LINEFROMPOSITION, position, 0))
        Command\DataSize = (Len(Expr$)+1) * SizeOf(Character)
        SendDebuggerCommandWithData(*Debugger, @Command, @Expr$)
        Debug Expr$
      EndIf
      
    EndIf
  EndIf
  
EndProcedure

; process the debugger shortcuts that are added by the ide to all debugger
; windows

; updates the shortcuts to all the windows of this debugger
; called when any new window is opened, or after prefs change
;
Procedure Debugger_AddShortcuts(Window)
  
  If KeyboardShortcuts(#MENU_Stop)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_Stop), #MENU_Debugger_Stop)
  EndIf
  If KeyboardShortcuts(#MENU_Run)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_Run), #MENU_Debugger_Run)
  EndIf
  If KeyboardShortcuts(#MENU_Step)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_Step), #MENU_Debugger_Step)
  EndIf
  If KeyboardShortcuts(#MENU_StepX)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_StepX), #MENU_Debugger_StepX)
  EndIf
  If KeyboardShortcuts(#MENU_StepOut)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_StepOut), #MENU_Debugger_StepOut)
  EndIf
  If KeyboardShortcuts(#MENU_StepOver)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_StepOver), #MENU_Debugger_StepOver)
  EndIf
  If KeyboardShortcuts(#MENU_Kill)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_Kill), #MENU_Debugger_Kill)
  EndIf
  If KeyboardShortcuts(#MENU_DebugOutput)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_DebugOutput), #MENU_Debugger_DebugOutput)
  EndIf
  If KeyboardShortcuts(#MENU_Watchlist)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_Watchlist), #MENU_Debugger_Watchlist)
  EndIf
  If KeyboardShortcuts(#MENU_VariableList)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_VariableList), #MENU_Debugger_VariableList)
  EndIf
  If KeyboardShortcuts(#MENU_History)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_History), #MENU_Debugger_History)
  EndIf
  If KeyboardShortcuts(#MENU_Memory)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_Memory), #MENU_Debugger_Memory)
  EndIf
  If KeyboardShortcuts(#MENU_LibraryViewer)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_LibraryViewer), #MENU_Debugger_LibraryViewer)
  EndIf
  If KeyboardShortcuts(#MENU_DebugAsm)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_DebugAsm), #MENU_Debugger_DebugAsm)
  EndIf
  If KeyboardShortcuts(#MENU_DataBreakPoints)
    AddKeyboardShortcut(Window, KeyboardShortcuts(#MENU_DataBreakPoints), #MENU_Debugger_DataBreakPoints)
  EndIf
  
EndProcedure

; these 2 are for the preference updates
; (they remove all shortcuts before the list update, and add them again after)
;
Procedure Debugger_RemoveExtraShortcuts()
  
  ForEach RunningDebuggers()
    For i = 0 To #DEBUGGER_WINDOW_LAST-1
      If IsWindow(RunningDebuggers()\Windows[i])
        
        If KeyboardShortcuts(#MENU_Stop)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_Stop))
        EndIf
        If KeyboardShortcuts(#MENU_Run)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_Run))
        EndIf
        If KeyboardShortcuts(#MENU_Step)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_Step))
        EndIf
        If KeyboardShortcuts(#MENU_StepX)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_StepX))
        EndIf
        If KeyboardShortcuts(#MENU_StepOut)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_StepOut))
        EndIf
        If KeyboardShortcuts(#MENU_StepOver)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_StepOver))
        EndIf
        If KeyboardShortcuts(#MENU_Kill)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_Kill))
        EndIf
        If KeyboardShortcuts(#MENU_DebugOutput)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_DebugOutput))
        EndIf
        If KeyboardShortcuts(#MENU_Watchlist)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_Watchlist))
        EndIf
        If KeyboardShortcuts(#MENU_VariableList)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_VariableList))
        EndIf
        If KeyboardShortcuts(#MENU_History)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_History))
        EndIf
        If KeyboardShortcuts(#MENU_Memory)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_Memory))
        EndIf
        If KeyboardShortcuts(#MENU_LibraryViewer)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_LibraryViewer))
        EndIf
        If KeyboardShortcuts(#MENU_DebugAsm)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_DebugAsm))
        EndIf
        If KeyboardShortcuts(#MENU_DataBreakPoints)
          RemoveKeyboardShortcut(RunningDebuggers()\Windows[i], KeyboardShortcuts(#MENU_DataBreakPoints))
        EndIf
        
        
      EndIf
    Next i
  Next RunningDebuggers()
  
EndProcedure

Procedure Debugger_AddExtraShortcuts()
  
  ForEach RunningDebuggers()
    For i = 0 To #DEBUGGER_WINDOW_LAST-1
      If IsWindow(RunningDebuggers()\Windows[i])
        Debugger_AddShortcuts(RunningDebuggers()\Windows[i])
      EndIf
    Next i
  Next RunningDebuggers()
  
EndProcedure


Procedure Debugger_ProcessShortcuts(EventWindowID, EventID)
  result = 0
  
  If EventID = #PB_Event_Menu
    
    ; On the debugger windows, we add the IDE shortcuts for all stuff that do not concern the IDE
    ; (eg breakpoint stuff is not added). We also add shortcuts to open other debug windows,
    ; which could be useful
    ;
    ForEach RunningDebuggers()
      For i = 0 To #DEBUGGER_WINDOW_LAST-1
        
        If EventWindowID = RunningDebuggers()\Windows[i]
          result = 1
          
          Select EventMenu()
              
            Case #MENU_Debugger_Stop
              Debugger_Stop(@RunningDebuggers())
              
            Case #MENU_Debugger_Run
              Debugger_Run(@RunningDebuggers())
              
            Case #MENU_Debugger_Step
              Debugger_Step(@RunningDebuggers())
              
            Case #MENU_Debugger_StepX
              Debugger_StepX(@RunningDebuggers())
              
            Case #MENU_Debugger_StepOut
              Debugger_StepOut(@RunningDebuggers())
              
            Case #MENU_Debugger_StepOver
              Debugger_StepOver(@RunningDebuggers())
              
            Case #MENU_Debugger_Kill
              Debugger_Kill(@RunningDebuggers())
              
            Case #MENU_Debugger_DebugOutput
              OpenDebugWindow(@RunningDebuggers(), #True)
              
            Case #MENU_Debugger_Watchlist
              OpenWatchListWindow(@RunningDebuggers())
              
            Case #MENU_Debugger_VariableList
              OpenVariableWindow(@RunningDebuggers())
              
            Case #MENU_Debugger_History
              OpenHistoryWindow(@RunningDebuggers())
              
            Case #MENU_Debugger_Memory
              OpenMemoryViewerWindow(@RunningDebuggers())
              
            Case #MENU_Debugger_LibraryViewer
              OpenLibraryViewerWindow(@RunningDebuggers())
              
            Case #MENU_Debugger_DebugAsm
              OpenAsmWindow(@RunningDebuggers())
              
            Case #MENU_Debugger_DataBreakPoints
              OpenDataBreakpointWindow(@RunningDebuggers())
              
              
            Default: result = 0
          EndSelect
          
          Break 2 ; no need to check any other debuggers (this could even be problematic after a kill())
        EndIf
        
      Next i
    Next RunningDebuggers()
    
  EndIf
  
  ProcedureReturn result
EndProcedure
