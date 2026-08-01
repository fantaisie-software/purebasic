; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


CompilerIf #PRINT_DEBUGGER_COMMANDS
  OpenConsole()
CompilerEndIf


Declare Debugger_ForceDestroy(*Debugger.DebuggerData)

Procedure Debugger_Quit()
  
  While FirstElement(RunningDebuggers())
    Debugger_ForceDestroy(@RunningDebuggers())
  Wend
  
EndProcedure


Procedure IsDebuggerValid(*Debugger)
  Found = 0
  Index = ListIndex(RunningDebuggers())
  
  ForEach RunningDebuggers()
    If @RunningDebuggers() = *Debugger
      Found = 1
      Break
    EndIf
  Next RunningDebuggers()
  
  If Index = -1
    ResetList(RunningDebuggers())
  Else
    SelectElement(RunningDebuggers(), Index)
  EndIf
  
  ProcedureReturn Found
EndProcedure


; The debugger structure is destroyed when the exe is unloaded, AND all the
; debugger windows have been closed by the user
; this procedure checks these conditions and destroys the debugger structure
; if needed
;
Procedure Debugger_CheckDestroy(*Debugger.DebuggerData)
  
  ; is the debugger structure even valid any more?
  ;
  If IsDebuggerValid(*Debugger) = 0
    ProcedureReturn
  EndIf
  
  ; check if exe is running
  ;
  If *Debugger\CanDestroy = 0
    ProcedureReturn
  EndIf
  
  ; check for open windows
  ;
  For i = 0 To #DEBUGGER_WINDOW_LAST-1
    If i = #DEBUGGER_WINDOW_Debug  ; this is a special case (can be open, but hidden)
      If *Debugger\Windows[i] And *Debugger\IsDebugOutputVisible
        ProcedureReturn
      EndIf
      
    ElseIf i = #DEBUGGER_WINDOW_WatchList ; this too is a special case (is always open)
      If *Debugger\IsWatchListVisible
        ProcedureReturn
      EndIf
      
    ElseIf i = #DEBUGGER_WINDOW_DataBreakpoints
      If *Debugger\DataBreakpointsVisible
        ProcedureReturn
      EndIf
      
    ElseIf *Debugger\Windows[i]
      ProcedureReturn
    EndIf
  Next i
  
  
  ; this is a special case!
  ;
  If IsWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
  EndIf
  
  If IsWindow(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
    VariableGadget_Free(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
  EndIf
  
  If IsWindow(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints])
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints])
  EndIf
  
  ; free any memory blocks referenced from this structure
  ;
  If *Debugger\IncludedFiles
    FreeMemory(*Debugger\IncludedFiles)
  EndIf
  
  If *Debugger\Procedures
    FreeMemory(*Debugger\Procedures)
  EndIf
  
  If *Debugger\MemoryDump
    FreeMemory(*Debugger\MemoryDump)
  EndIf
  
  ; the data array is freed automatically when the window closes
  ;
  If *Debugger\ProfilerFiles
    *Files.Debugger_ProfilerList = *Debugger\ProfilerFiles
    
    ; release the color images
    ;
    For i = 0 To *Debugger\NbIncludedFiles
      If *Files\file[i]\ColorImage
        FreeImage(*Files\file[i]\ColorImage)
      EndIf
    Next i
    
    FreeMemory(*Debugger\ProfilerFiles)
  EndIf
  
  
  If *Debugger\History
    *history.Debugger_History = *Debugger\History
    For i = 0 To *Debugger\HistorySize - 1
      VariableGadget_Free(*history\item[i]\Variables)
    Next i
    FreeMemory(*Debugger\History)
  EndIf
  
  If *Debugger\LibraryList
    *libraries.Debugger_LibraryList = *Debugger\LibraryList
    For i = 0 To *Debugger\NbLibraries - 1
      FreePBString(@*libraries\library[i]\LibraryID$)
      FreePBString(@*libraries\library[i]\Name$)
      FreePBString(@*libraries\library[i]\TitleString$)
    Next i
    FreeMemory(*Debugger\LibraryList)
  EndIf
  
  If *Debugger\ObjectList
    FreeMemory(*Debugger\ObjectList)
  EndIf
  
  ; Terminate the communication, if not already done
  ;
  If *Debugger\Communication
    *Debugger\Communication\Disconnect()
  EndIf
  
  ; Close the Process Object
  If *Debugger\ProcessObject
    
    ; There can be zombies process in Linux when the debugger exits: https://www.purebasic.fr/english/viewtopic.php?t=84602
    ;
    CompilerIf #CompileLinux
      If WaitProgram(*Debugger\ProcessObject, 0) = #False ; still running
        KillProgram(*Debugger\ProcessObject)
      EndIf
    CompilerEndIf
    
    CloseProgram(*Debugger\ProcessObject)
    *Debugger\ProcessObject = 0
  EndIf
  
  ; Now cleanup the communication, if not done yet
  ;
  If *Debugger\Communication
    *Debugger\Communication\Close()
    *Debugger\Communication = 0
  EndIf
  
  CompilerIf #CompileWindows
    If *Debugger\TerminationMutex
      CloseHandle_(*Debugger\TerminationMutex)
      *Debugger\TerminationMutex = 0
    EndIf
  CompilerEndIf
  
  ; remove the structure
  ;
  ChangeCurrentElement(RunningDebuggers(), *Debugger)
  DeleteElement(RunningDebuggers())
  
EndProcedure

Procedure Debugger_ForceDestroy(*Debugger.DebuggerData)
  
  ; is the debugger structure even valid any more?
  ;
  If IsDebuggerValid(*Debugger) = 0
    ProcedureReturn
  EndIf
  
  ; flag structure for destruction
  ;
  *Debugger\CanDestroy = 1
  
  ; Terminate communication
  ;
  If *Debugger\Communication
    If *Debugger\IsNetwork
      ; Send the KILL command so the target exe can quit itself (if the connection still works though)
      ;
      Command.CommandInfo\Command = #COMMAND_Kill
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
    
    *Debugger\Communication\Disconnect()
  EndIf
  
  ; Kill exe, if it still runs
  ;
  If *Debugger\ProcessObject
    If WaitProgram(*Debugger\ProcessObject, 0) = #False ; still running
      
      ; Try to quit the Exe without a forced kill
      ;
      CompilerIf #CompileWindows
        If *Debugger\TerminationMutex
          ; releasing this mutex should cause the process to quit itself (cleaner then TerminatProcess)
          ReleaseMutex_(*Debugger\TerminationMutex)
        EndIf
        
      CompilerElse
        ; "ask" the program to quit (with calling the EndFunctions)
        kill_(ProgramID(*Debugger\ProcessObject), #SIGTERM) ; ProgramID() returns the pid on unix
        
      CompilerEndIf
      
      ; Wait a bit and kill if it did not work
      ;
      If WaitProgram(*Debugger\ProcessObject, 1500) = #False
        KillProgram(*Debugger\ProcessObject)
      EndIf
    EndIf
    
    CloseProgram(*Debugger\ProcessObject)
    *Debugger\ProcessObject = 0
  EndIf
  
  ; Now cleanup the communication, if not done yet
  ;
  If *Debugger\Communication
    *Debugger\Communication\Close()
    *Debugger\Communication = 0
  EndIf
  
  CompilerIf #CompileWindows
    If *Debugger\TerminationMutex
      CloseHandle_(*Debugger\TerminationMutex)
      *Debugger\TerminationMutex = 0
    EndIf
  CompilerEndIf
  
  
  ; close all associated windows
  ; will also call the Debugger_CheckDestroy() function after the windows are removed
  ;
  For i = 0 To #DEBUGGER_WINDOW_LAST-1
    If *Debugger\Windows[i]
      ; send it a window close event:
      ;
      Debugger_ProcessEvents(*Debugger\Windows[i], #PB_Event_CloseWindow)
      
      ; each closing of a debugger window can destroy the structure already,
      ; as they all call Debugger_CheckDestroy(), so we must check for that!
      ;
      If IsDebuggerValid(*Debugger) = 0
        ProcedureReturn
      EndIf
      
      ; if it is still there then forcibly remove it
      ;
      If IsWindow(*Debugger\Windows[i])
        CloseWindow(*Debugger\Windows[i])
        *Debugger\Windows[i] = 0
      EndIf
    EndIf
  Next i
  
  
  ; make sure the thing is really removed from the Debuggers list!
  ; even if some other procedure didn't clean up right!
  ;
  If IsDebuggerValid(*Debugger)
    ; Call the CheckDestroy() once again to give it a last chance to correctly free the data
    Debugger_CheckDestroy(*Debugger)
    
    If IsDebuggerValid(*Debugger) ; if it is still there, it is really messed up
      ChangeCurrentElement(RunningDebuggers(), *Debugger)
      DeleteElement(RunningDebuggers())
    EndIf
  EndIf
  
EndProcedure

;
; Debugging only. To log all communication to a file
;
CompilerIf #LOG_DEBUGGER_COMMANDS
  
  Procedure LogDebuggerCommand(Direction, *Command.CommandInfo, *CommandData)
    
    If Direction
      If *Command
        Restore DebuggerCommands_Outgoing
        For i = 0 To *Command\Command
          Read.s ConstantName$
        Next i
      EndIf
      
      Direction$ = "Debugger -> Executable"
    Else
      If *Command
        If *Command\Command = #COMMAND_FatalError
          ConstantName$ = "#COMMAND_FatalError"
        Else
          Restore DebuggerCommands_Incoming
          For i = 0 To *Command\Command
            Read.s ConstantName$
          Next i
        EndIf
      EndIf
      
      Direction$ = "Executable -> Debugger"
    EndIf
    
    Log = OpenFile(#PB_Any, #LOG_DEBUGGER_FILE)
    If Log
      FileSeek(Log, Lof(Log))
      
      WriteStringN(Log, "")
      WriteStringN(Log, "--------------------------------------------------------------------------------")
      
      If *Command
        WriteStringN(Log, FormatDate("[%hh:%ii:%ss] ", *Command\Timestamp) + Direction$)
        WriteStringN(Log, "  Command : " + Str(*Command\Command) + "   ("+ConstantName$+")")
        WriteStringN(Log, "  Value1  : " + Str(*Command\Value1) + "   ($" + Hex(*Command\Value1, #PB_Long)+")")
        WriteStringN(Log, "  Value2  : " + Str(*Command\Value2) + "   ($" + Hex(*Command\Value2, #PB_Long)+")")
        WriteStringN(Log, "  DataSize: " + Str(*Command\DataSize) + " Bytes")
      Else
        WriteStringN(Log, FormatDate("[%hh:%ii:%ss] ", Date()) + Direction$)
        WriteStringN(Log, "  --- ERROR: Invalid command (*Command = 0) ---")
      EndIf
      
      WriteStringN(Log, "--------------------------------------------------------------------------------")
      
      If *Command And *Command\DataSize > 0
        If *CommandData = 0
          WriteStringN(Log, "  --- ERROR: Expected CommandData not available! ---")
        Else
          *Base = *CommandData
          
          While *Base < *CommandData + *Command\DataSize
            Offset$ = "  $" + RSet(Hex(*Base - *CommandData), 8, "0")
            Hex$    = "  "
            String$ = " " ; one space is added by the last hex column
            
            For i = 0 To 15
              If *Base + i < *CommandData + *Command\DataSize
                Value = PeekB(*Base + i) & $FF
                Hex$ + RSet(Hex(Value), 2, "0") + " "
                
                If Value < 32
                  String$ + "."
                Else
                  String$ + Chr(Value)
                EndIf
              Else
                Hex$ + "   "
              EndIf
            Next i
            
            *Base + 16
            WriteStringN(Log, Offset$+Hex$+String$)
          Wend
          
        EndIf
        WriteStringN(Log, "--------------------------------------------------------------------------------")
      EndIf
      
      WriteStringN(Log, "")
      
      CloseFile(Log)
    EndIf
    
  EndProcedure
  
  Procedure LogProgramCreation(Executable$, Parameters$, Directory$)
    Info$ = "PureBasic " + StrD(#PB_Compiler_Version/100, 2)
    
    CompilerIf #CompileWindows
      Info$ + " - Windows"
    CompilerElse
      CompilerIf #CompileLinux
        Info$ + "- Linux"
      CompilerElse
        Info$ + "- Mac OSX"
      CompilerEndIf
    CompilerEndIf
    
    CompilerIf #CompileX86
      Info$ + "- x86"
    CompilerElse
      CompilerIf #CompileX64
        Info$ + "- x64"
      CompilerElse
        Info$ + "- ppc"
      CompilerEndIf
    CompilerEndIf
    
    CompilerIf #PB_Compiler_Unicode
      Info$ + "  (Unicode mode)"
    CompilerElse
      Info$ + "  (Ascii mode)"
    CompilerEndIf
    
    Log = CreateFile(#PB_Any, #LOG_DEBUGGER_fILE)
    If Log
      WriteStringN(Log, "--------------------------------------------------------------------------------")
      WriteStringN(Log, "  Debugger communication log")
      WriteStringN(Log, "--------------------------------------------------------------------------------")
      WriteStringN(Log, "")
      WriteStringN(Log, "  Debugger exe : " + ProgramFilename())
      WriteStringN(Log, "  Build date   : "+FormatDate("%mm/%dd/%yyyy - %hh:%ii", #PB_Compiler_Date))
      WriteStringN(Log, "  Build with   : "+Info$)
      WriteStringN(Log, "")
      WriteStringN(Log, "  Executable   : "+Executable$)
      WriteStringN(Log, "  Parameters   : "+Parameters$)
      WriteStringN(Log, "  Directory    : "+Directory$)
      WriteStringN(Log, "  Session start: "+FormatDate("%hh:%ii:%ss", Date()))
      WriteStringN(Log, "")
      WriteStringN(Log, "--------------------------------------------------------------------------------")
      WriteStringN(Log, "")
      
      CloseFile(Log)
    EndIf
  EndProcedure
  
CompilerEndIf


; sends a command to the debugger
;

Procedure SendDebuggerCommandWithData(*Debugger.DebuggerData, *Command.CommandInfo, *CommandData)
  CompilerIf #PRINT_DEBUGGER_COMMANDS
    Restore DebuggerCommands_Outgoing
    For i = 0 To *Command\Command
      Read.s ConstantName$
    Next i
    PrintN("IDE::SEND->"+ConstantName$+" ("+Str(*Command\Command)+")")
  CompilerEndIf
  
  *Command\TimeStamp = Date()
  
  CompilerIf #LOG_DEBUGGER_COMMANDS
    LogDebuggerCommand(1, *Command, *CommandData)
  CompilerEndIf
  
  If *Debugger\Communication And *Debugger\ProgramState <> -1 ; can only send to loaded executables!
    *Debugger\Communication\Send(*Command, *CommandData)
    
    CompilerIf #CompileLinuxGtk2 ; TODO-GTK3 TODO-QT
      ; Send an X event to the child (actually to all x windows), which should make its WaitWindowEvent() return.
      Event.GdkEventClient
      Event\type         = #GDK_CLIENT_EVENT
      Event\send_event   = 1
      Event\message_type = gdk_atom_intern_("PureBasic_Break", 0)
      Event\data_format  = 32
      gdk_event_send_clientmessage_toall_(@Event)
    CompilerEndIf
  EndIf
EndProcedure

Procedure SendDebuggerCommand(*Debugger.DebuggerData, *Command.CommandInfo)
  *Command\DataSize = 0
  SendDebuggerCommandWithData(*Debugger, *Command, 0)
EndProcedure



; Function shared with the standalone debugger loop
;
Procedure Debugger_End(*Debugger.DebuggerData)
  
  UpdateDebugOutputWindow(*Debugger)
  
  *Debugger\CanDestroy = 1
  Debugger_CheckDestroy(*Debugger) ; make an attempt to remove the structure (if all windows are closed)
  
EndProcedure



; this procedure checks the command stack for
; all debuggers and processes any waiting ones.
; it returns nonzero when at least one command was processed
; NOTE: this must be called on a constant basis from the main
; loop!
;
Procedure Debugger_ProcessIncomingCommands()
  result = 0
  
  ;   CompilerIf #CompileWindows
  ;     ProcessDebugEvents()  ; Win32 debug API events
  ;   CompilerEndIf
  
  ForEach RunningDebuggers()
    *Debugger.DebuggerData = @RunningDebuggers()
    
    Repeat
      
      If *Debugger\Communication = 0
        Break
        
      ElseIf *Debugger\Communication\Receive(@*Debugger\Command, @*Debugger\CommandData) = #False
        If *Debugger\Communication\CheckErrors(@*Debugger\Command, *Debugger\ProcessObject) = #False
          Break
        EndIf
        *Debugger\CommandData = 0
      EndIf
      
      result + 1  ; a command is being processed
      
      ; debugging...
      CompilerIf #PRINT_DEBUGGER_COMMANDS
        If *Debugger\Command\Command = #COMMAND_FatalError
          PrintN("IDE::PROCESSING->FatalError (Value1 = "+Str(*Debugger\Command\Value1)+")")
        Else
          Restore DebuggerCommands_Incoming
          For i = 0 To *Debugger\Command\Command
            Read.s ConstantName$
          Next i
          PrintN("IDE::PROCESSING->"+ConstantName$+" ("+Str(*Debugger\Command\Command)+")")
        EndIf
      CompilerEndIf
      
      CompilerIf #LOG_DEBUGGER_COMMANDS
        LogDebuggerCommand(0, *Debugger\Command, *Debugger\CommandData)
      CompilerEndIf
      
      ;      If *Debugger\Windows[#DEBUGGER_WINDOW_Debug] = 0
      ;        OpenDebugWindow(*Debugger, #False)
      ;      EndIf
      ;      Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List]
      ;      AddGadgetItem(Gadget, -1, "IDE::RECEIVE->"+Str(*Debugger\Command\Command))
      ;      SetGadgetState(Gadget, CountGadgetItems(Gadget)-1)
      
      ; we are outside the locked area and outside the thread,
      ; so we can do pretty much what we want here (except accessing the command stack)
      ;
      Select *Debugger\Command\Command  ; handle stuff that is the same for ide and debugger
          
        Case #COMMAND_FatalError  ; indicates fatal communication error of debugger
          Select *Debugger\Command\Value1
            Case #ERROR_Memory
              Message$ = Language("Debugger", "MemoryError")
            Case #ERROR_Pipe
              Message$ = Language("Debugger", "PipeError")
            Case #ERROR_ExeQuit
              Message$ = Language("Debugger", "ExeQuitError")
            Case #ERROR_Timeout
              If DebuggerTimeout % 1000 = 0
                Timeout$ = Str(DebuggerTimeout/1000)
              Else
                Timeout$ = StrF(DebuggerTimeout/1000.0, 1)
              EndIf
              Message$ = ReplaceString(Language("Debugger", "TimeoutError"), "%timeout%", Timeout$)
            Case #ERROR_NetworkFail
              Message$ = Language("Debugger", "NetworkError")
          EndSelect
          
          CompilerIf #CompileWindows
            ; Very weird Vista related problem:
            ;
            ; If a program is missing a dll, and you get the "missing dll" message at
            ; startup, Vista will put up another "the program has a problem" dialog
            ; once you click ok. Somehow this window messes with the z-order or something.
            ; After you click "close" on this dialog, the following requester will
            ; open behind (!) the IDE, and be unaccessible (=lockup).
            ;
            ; The only way to solve this is to force our window to the foreground before.
            ; (Leave this in for all Windows versions, because in case of a Memory/Pipe error,
            ; we never know who had the focus so maybe this could happened there too)
            ;
            CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
              SetWindowForeground_Real(#WINDOW_Main)
            CompilerElse
              SetWindowForeground_Real(#WINDOW_Main)
            CompilerEndIf
          CompilerEndIf
          
          MessageRequester("PureBasic Debugger", Message$, #FLAG_Error)
          
          ; pass this on to the calllback
          RealProgramState = *Debugger\ProgramState ; save for later restoring (so ForceDestroy() correctly ends the program)
          *Debugger\ProgramState = -1               ; tell that the exe is not loaded not loaded
          *Debugger\LastProgramState = -1           ; last state no longer matters
          Debugger_UpdateWindowStates(*Debugger)
          DebuggerCallback(*Debugger)
          
          *Debugger\ProgramState = RealProgramState
          Debugger_ForceDestroy(*Debugger) ; force the removal of this debugger!
          Break 2                          ; important, because the *Debugger is now invalid!
          
          
        Case #COMMAND_Init
          If *Debugger\Command\Value2 = #DEBUGGER_Version
            *Debugger\NbIncludedFiles = *Debugger\Command\Value1  ; save the included files
            *Debugger\IncludedFiles = *Debugger\CommandData
            *Debugger\CommandData = 0 ; do not free this buffer
            *Debugger\LastProgramState = *Debugger\ProgramState
            *Debugger\ProgramState = 0 ; running
            Debugger_UpdateWindowStates(*Debugger)
            
            If IsWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]) ; if the variable viewer is open before the program loaded
              Command.CommandInfo\Command = #COMMAND_GetGlobalNames
              SendDebuggerCommand(*Debugger, @Command)
            EndIf
            
            ; request module and procedure names from the executable
            ;
            Command.CommandInfo\Command = #COMMAND_GetModules
            SendDebuggerCommand(*Debugger, @Command)
            Command.CommandInfo\Command = #COMMAND_GetProcedures
            SendDebuggerCommand(*Debugger, @Command)
            
            ; AutoRun Profiler if requested
            ;
            If ProfilerRunAtStart
              Command.CommandInfo\Command = #COMMAND_StartProfiler
              SendDebuggerCommand(*Debugger, @Command)
              
              ; request the profiler offsets right away, so they are available
              ; even if the user only opens the profiler after the program quit.
              Command.CommandInfo\Command = #COMMAND_GetProfilerOffsets
              SendDebuggerCommand(*Debugger, @Command)
              
              *Debugger\ProfilerRunning = 1
            EndIf
            
            ; open the windows which are set to auto-open
            ;
            If AutoOpenDebugOutput
              OpenDebugWindow(*Debugger, #True)
            EndIf
            
            If AutoOpenAsmWindow
              OpenAsmWindow(*Debugger)
            EndIf
            
            If AutoOpenMemoryViewer
              OpenMemoryViewerWindow(*Debugger)
            EndIf
            
            If AutoOpenVariableViewer
              OpenVariableWindow(*Debugger)
            EndIf
            
            If AutoOpenHistory
              OpenHistoryWindow(*Debugger)
            EndIf
            
            If AutoOpenWatchlist
              OpenWatchListWindow(*Debugger)
            EndIf
            
            If AutoOpenLibraryViewer
              OpenLibraryViewerWindow(*Debugger)
            EndIf
            
            If AutoOpenProfiler
              OpenProfilerWindow(*Debugger)
            EndIf
            
            If AutoOpenDataBreakpoints
              OpenDataBreakpointWindow(*Debugger)
            EndIf
            
            If AutoOpenPurifier
              OpenPurifierWindow(*Debugger)
            EndIf
            
          Else
            ; version conflict!!
            MessageRequester("PureBasic Debugger", Language("Debugger","VersionError"), #FLAG_Error)
            
            ; pass this on to the calllback
            *Debugger\Command\Command = #COMMAND_FatalError
            *Debugger\Command\Value1  = #ERROR_Version
            
            RealProgramState = *Debugger\ProgramState ; save for later restoring (so ForceDestroy() correctly ends the program)
            *Debugger\ProgramState = -1               ; tell that the exe is not loaded not loaded
            *Debugger\LastProgramState = -1           ; last state no longer matters
            Debugger_UpdateWindowStates(*Debugger)
            DebuggerCallback(*Debugger)
            
            *Debugger\ProgramState = RealProgramState
            Debugger_ForceDestroy(*Debugger) ; force the removal of this debugger!
            Break 2                          ; important, because the *Debugger is now invalid!
          EndIf
          
        Case #COMMAND_ExeMode
          If *Debugger\Command\Value1 & (1 << 0)
            *Debugger\IsUnicode = 1
          EndIf
          If *Debugger\Command\Value1 & (1 << 1)
            *Debugger\IsThread = 1
          EndIf
          If *Debugger\Command\Value1 & (1 << 2)
            *Debugger\Is64Bit = 1
          EndIf
          If *Debugger\Command\Value1 & (1 << 3)
            *Debugger\IsPurifier = 1
          EndIf
          
          ; initialize the directories for these outputs to the source directory
          ; do this here and not in #COMMAND_Init so the standalone debugger had a chance to init the file name
          DebuggerOutputFile$ = GetPathPart(*Debugger\FileName$)
          MemoryViewerFile$ = GetPathPart(*Debugger\FileName$)
          
        Case #COMMAND_End
          *Debugger\ProgramState = -1 ; not loaded
          *Debugger\LastProgramState = -1 ; last state no longer matters
          *Debugger\ProgramEnded = 1      ; for ignoring any following pipe errors (happens on linux in console mode)
          Debugger_UpdateWindowStates(*Debugger)
          
        Case #COMMAND_Error
          *Debugger\LastProgramState = *Debugger\ProgramState
          *Debugger\ProgramState = *Debugger\Command\Value2
          Debugger_UpdateWindowStates(*Debugger)
          
          ; No generic action to take here, as the program state is not modified
          ; (only display needs to be done by the callback)
          ; Case #COMMAND_Warning
          
        Case #COMMAND_Stopped
          *Debugger\LastProgramState = *Debugger\ProgramState
          *Debugger\ProgramState = *Debugger\Command\Value2
          Debugger_UpdateWindowStates(*Debugger)
          
        Case #COMMAND_Continued
          *Debugger\LastProgramState = *Debugger\ProgramState
          *Debugger\ProgramState = 0 ; running
          Debugger_UpdateWindowStates(*Debugger)
          
        Case #COMMAND_Debug, #COMMAND_DebugDouble, #COMMAND_DebugQuad, #COMMAND_Expression, #COMMAND_SetVariableResult, #COMMAND_ControlDebugOutput
          DebugOutput_DebuggerEvent(*Debugger)
          
        Case #COMMAND_RegisterLayout, #COMMAND_Register, #COMMAND_Stack, #COMMAND_ControlAssemblyViewer
          AsmDebug_DebuggerEvent(*Debugger)
          
        Case #COMMAND_Memory, #COMMAND_ControlMemoryViewer
          MemoryViewer_DebuggerEvent(*Debugger)
          
        Case #COMMAND_GlobalNames, #COMMAND_Globals, #COMMAND_Locals, #COMMAND_ArrayInfo, #COMMAND_ArrayData, #COMMAND_ListData, #COMMAND_ListInfo, #COMMAND_MapData, #COMMAND_MapInfo, #COMMAND_ControlVariableViewer
          VariableDebug_DebuggerEvent(*Debugger)
          
        Case #COMMAND_History, #COMMAND_HistoryLocals, #COMMAND_ControlCallstack
          History_DebuggerEvent(*Debugger)
          
        Case #COMMAND_Procedures
          *Debugger\NbProcedures = *Debugger\Command\Value1
          *Debugger\Procedures = *Debugger\CommandData
          *Debugger\CommandData = 0
          
          ; in case the history window was open before exe started, add the list now
          History_DebuggerEvent(*Debugger)
          
          ; the watchlist requires this event too! (to fill the procedure list)
          WatchList_DebuggerEvent(*Debugger)
          DataBreakpoint_DebuggerEvent(*Debugger)
          
        Case #COMMAND_ProcedureStats
          History_DebuggerEvent(*Debugger)
          
        Case #COMMAND_Watchlist, #COMMAND_WatchlistEvent, #COMMAND_WatchlistError, #COMMAND_ControlWatchlist
          WatchList_DebuggerEvent(*Debugger)
          
        Case #COMMAND_DataBreakPoint
          DataBreakpoint_DebuggerEvent(*Debugger)
          
        Case #COMMAND_Libraries, #COMMAND_LibraryInfo, #COMMAND_ObjectID, #COMMAND_ObjectText, #COMMAND_ObjectData, #COMMAND_ControlLibraryViewer
          LibraryViewer_DebuggerEvent(*Debugger)
          
        Case #COMMAND_ProfilerOffsets, #COMMAND_ProfilerData, #COMMAND_ControlProfiler
          Profiler_DebuggerEvent(*Debugger)
          
        Case #COMMAND_ControlPurifier
          Purifier_DebuggerEvent(*Debugger)
          
        Case #COMMAND_Modules
          *Debugger\NbModules = *Debugger\Command\Value1
          If *Debugger\CommandData And *Debugger\NbModules > 0
            ReDim *Debugger\ModuleNames(*Debugger\NbModules-1)
            
            *Pointer = *Debugger\CommandData
            For i = 0 To *Debugger\NbModules - 1
              *Debugger\ModuleNames(i) = PeekS(*Pointer, -1, #PB_Ascii)
              *Pointer + MemoryStringLength(*Pointer, #PB_Ascii) + 1
            Next i
          EndIf
          
      EndSelect
      
      DebuggerCallback(*Debugger) ; call the declared callback
      
      
      If IsDebuggerValid(*Debugger)= 0 ; make sure the debugger is still valid (might have been closed by the callback
        Break 2
      EndIf
      
      ; exe is unloaded, take necessary steps
      ;
      If *Debugger\Command\Command = #COMMAND_End
        Debugger_End(*Debugger) ; Function shared with the Standalone debugger callback
        Break 2                 ; important, because the *Debugger is now invalid!
      EndIf
      
      ; free any associated command data
      ;
      If *Debugger\CommandData
        FreeMemory(*Debugger\CommandData)
        *Debugger\CommandData = 0
      EndIf
      
    Until result > 100 ; only process 100 commands at a time to allow GUI updates to take place!
    
    If IsDebuggerValid(*Debugger)
      UpdateDebugOutputWindow(*Debugger) ; Will check if the debugger output needs to be updated (some debug message in queue)
    EndIf
    
  Next RunningDebuggers()
  
  ProcedureReturn result
EndProcedure

; executes the given program and returns a debugger structure for it
;
Procedure Debugger_ExecuteProgram(FileName$, CommandLine$, Directory$)
  
  Debug "Debugger_ExecuteProgram():"
  Debug FileName$
  Debug CommandLine$
  Debug Directory$
  Debug DebuggerIseFIFO
  
  ; add a new debugger structure
  ;
  LastElement(RunningDebuggers())
  If AddElement(RunningDebuggers()) = 0
    Debug " -- Debugger_ExecuteProgram() failed: AddElement()"
    ProcedureReturn 0
  EndIf
  
  ; generate a unique ID to represent this structure
  ;
  RunningDebuggers()\ID = GetUniqueID()
  
  ; this is to fix an issue in the CPU monitor of the ide
  ; RunningDebuggers()\CPUTime = -1
  
  ; create the communication object and
  ; setup the environment variables or file to pass on to the new process
  ;
  ;   CompilerIf #CompileMac ; OSX-debug
  ;     DebuggerUseFIFO = 1 ; always used
  ;   CompilerEndIf
  
  CompilerIf #CompileWindows = 0
    If DebuggerUseFIFO
      
      RunningDebuggers()\Communication = CreateFifoCommunication()
      If RunningDebuggers()\Communication = 0
        DeleteElement(RunningDebuggers())
        Debug " -- Debugger_ExecuteProgram() failed: CreateFifoCommunication()"
        ProcedureReturn 0
      EndIf
      
      File = CreateFile(#PB_Any, "/tmp/.pbdebugger.out")
      If File
        WriteStringN(File, "PB_DEBUGGER_Communication") ; identifyer string
        WriteStringN(File, Str(Date()))                 ; use a timestamp to ignore an old .purebasic.out from a crash (else the console debugger never starts!)
        WriteStringN(File, RunningDebuggers()\Communication\GetInfo())
        WriteStringN(File, Str(#PB_Compiler_Unicode)+";"+Str(CallDebuggerOnStart)+";"+Str(CallDebuggerOnEnd)+";"+Str(#DEBUGGER_BigEndian)) ; options (UnicodeMode;CallOnStart;CallOnEnd;IsBigEndian)
        CloseFile(File)
      Else
        RunningDebuggers()\Communication\Close()
        DeleteElement(RunningDebuggers())
        Debug " -- Debugger_ExecuteProgram() failed: CreateFile(/tmp/.pbdebugger.out)"
        ProcedureReturn 0
      EndIf
      
    Else
    CompilerEndIf
    
    RunningDebuggers()\Communication = CreatePipeCommunication()
    If RunningDebuggers()\Communication = 0
      DeleteElement(RunningDebuggers())
      Debug " -- Debugger_ExecuteProgram() failed: CreatePipeCommunication()"
      ProcedureReturn 0
    EndIf
    
    SetEnvironmentVariable("PB_DEBUGGER_Communication", RunningDebuggers()\Communication\GetInfo())
    SetEnvironmentVariable("PB_DEBUGGER_Options", Str(#PB_Compiler_Unicode)+";"+Str(CallDebuggerOnStart)+";"+Str(CallDebuggerOnEnd)+";"+Str(#DEBUGGER_BigEndian))
    
    CompilerIf #CompileWindows = 0
    EndIf
  CompilerEndIf
  
  RunningDebuggers()\IsNetwork = #False
  
  ; for windows we need an alternative solution for TerminateProcess_()
  ; we do it through a mutex.
  ; It is initially locked, and if unlocked, the debugged program will terminate itself.
  ;
  CompilerIf #CompileWindows
    ; Note: We now use RunProgram() on Windows, so no handle inheriting.
    ;   Use a named mutex then.
    MutexName$ = "PureBasic_DebuggerMutex_" + Hex(Random($7FFFFFFF))
    
    RunningDebuggers()\TerminationMutex = CreateMutex_(#Null, 1, MutexName$)
    If RunningDebuggers()\TerminationMutex = 0 Or GetLastError_() = #ERROR_ALREADY_EXISTS
      RunningDebuggers()\Communication\Close()
      DeleteElement(RunningDebuggers())
      Debug " -- Debugger_ExecuteProgram() failed: CreateMutex_() (Windows termination mutex)"
      ProcedureReturn 0
    EndIf
    
    SetEnvironmentVariable("PB_DEBUGGER_KillMutex", MutexName$)
  CompilerEndIf
  
  ; try to create the new process
  ;
  RunningDebuggers()\ProcessObject = RunProgram(FileName$, CommandLine$, Directory$, #PB_Program_Open)
  If RunningDebuggers()\ProcessObject = 0
    RunningDebuggers()\Communication\Close()
    
    CompilerIf #CompileWindows
      CloseHandle_(RunningDebuggers()\TerminationMutex)
    CompilerEndIf
    
    DeleteElement(RunningDebuggers())
    Debug " -- Debugger_ExecuteProgram() failed: RunProgram()"
    ProcedureReturn 0
  EndIf
  
  ; remove the environment variables again
  ;
  CompilerIf #CompileWindows = 0
    If DebuggerUseFIFO = 0
    CompilerEndIf
    
    RemoveEnvironmentVariable("PB_DEBUGGER_Communication")
    RemoveEnvironmentVariable("PB_DEBUGGER_Options")
    
    CompilerIf #CompileWindows = 0
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileWindows
    RemoveEnvironmentVariable("PB_DEBUGGER_KillMutex")
  CompilerEndIf
  
  ; Try to connect the communication
  ;
  If RunningDebuggers()\Communication\Connect() = 0
    RunningDebuggers()\Communication\Close()  ; cleanup
    
    ; Try to quit the Exe without a forced kill
    CompilerIf #CompileWindows
      ReleaseMutex_(RunningDebuggers()\TerminationMutex)
    CompilerElse
      kill_(ProgramID(RunningDebuggers()\ProcessObject), #SIGTERM) ; ProgramID() returns the pid on unix
    CompilerEndIf
    
    ; Wait a bit and kill if it did not work
    If WaitProgram(RunningDebuggers()\ProcessObject, 1500) = #False
      KillProgram(RunningDebuggers()\ProcessObject)
    EndIf
    
    CompilerIf #CompileWindows
      CloseHandle_(RunningDebuggers()\TerminationMutex)
    CompilerEndIf
    
    DeleteElement(RunningDebuggers())
    Debug " -- Debugger_ExecuteProgram() failed: Communication\Connect()"
    ProcedureReturn 0
  EndIf
  
  RunningDebuggers()\ProgramState = -1 ; indicate that exe is not loaded yet. (or has not called PB_DEBUGGER_Start())
  RunningDebuggers()\LastProgramState = -1
  
  
  ; the watchlist window is always open, but invisible, same for the debug one
  ;
  CreateWatchlistWindow(@RunningDebuggers())
  CreateDebugWindow(@RunningDebuggers())
  CreateDataBreakpointWindow(@RunningDebuggers())
  
  ; Default purifier options if not set otherwise later
  RunningDebuggers()\PurifierGlobal = 1
  RunningDebuggers()\PurifierLocal  = 1
  RunningDebuggers()\PurifierString = 64
  RunningDebuggers()\PurifierDynamic = 1
  
  ;
  ; Debugging
  ;
  CompilerIf #LOG_DEBUGGER_COMMANDS
    LogProgramCreation(Executable$, CommandLine$, Directory$)
  CompilerEndIf
  
  
  ; all done, process & debugger successfully created
  ; return the debugger structure
  ProcedureReturn @RunningDebuggers()
EndProcedure
