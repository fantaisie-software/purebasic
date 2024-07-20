; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; keep track of running standalone debuggers in order to update things like
; watchlist when they update
;

Structure Standalone_Debuggers
  CompileTargetID.i; unique id of the compiletarget used for compilation
  CommFile$        ; the random filename used for communication
  
  CommandLine$     ; settings used for RunProgram
  Parameters$
  Directory$
  
  WaitStatus.l     ; set to one after execution ended
EndStructure

Global NewList Standalone_Debuggers.Standalone_Debuggers()

DisableDebugger
ProcedureDLL StandaloneDebuggers_WaitThread(*Info.Standalone_Debuggers) ; DLL is important in MacOS X
  
  RunProgram(*Info\CommandLine$, *Info\Parameters$, *Info\Directory$, #PB_Program_Wait)
  *Info\WaitStatus = 1
  
EndProcedure

; Special one to execute the debugger in elevated mode on vista when
; an admin mode tool is debugged...
;
CompilerIf #CompileWindows
  Procedure StandaloneDebuggers_WaitThread_VistaAdmin(*Info.Standalone_Debuggers)
    
    info.SHELLEXECUTEINFO
    info\cbSize       = SizeOf(SHELLEXECUTEINFO)
    info\fMask        = #SEE_MASK_NOCLOSEPROCESS
    info\hwnd         = WindowID(#WINDOW_Main)
    info\lpVerb       = @"runas"
    info\lpFile       = @*Info\CommandLine$
    info\lpParameters = @*Info\Parameters$
    info\lpDirectory  = @*Info\Directory$
    info\nShow        = #SW_SHOWNORMAL
    
    
    If ShellExecuteEx_(@info) And info\hProcess
      WaitForSingleObject_(info\hProcess, #INFINITE)
      CloseHandle_(info\hProcess)
    EndIf
    *Info\WaitStatus = 1
    
  EndProcedure
CompilerEndIf

EnableDebugger

; This one manages everything there is to do to run the external debugger
; it passes watchlist/breakpoints, and also handled the results
; parameters are for the gui terminal on linux
;
Procedure ExecuteStandaloneDebugger(*Target.CompileTarget, DebuggerCMD$, Executable$, Directory$, Parameters$ = "")
  
  ; generate the file to communicate with the debugger
  ; use a (almost) unique filename to avoid overwriteing another one by a running debugger
  ;
  CompilerIf #CompileWindows
    CommFile$ = TempPath$ + "PureBasic_Debugger" + Str(Random($FFFF)) + ".txt"
  CompilerElse
    CommFile$ = TempPath$ + ".pb-DEBUGGER-" + Str(Random($FFFF)) + ".txt"
  CompilerEndIf
  
  ; The OSX "open" command cuts the commandline parameters, so we
  ; use a fixed filename for this case. Ugly, but works
  ;
  CompilerIf #CompileMac
    If DebuggerCMD$ = "open"
      CommFile$ = "/tmp/.pbstandalone.out"
      If OSVersion() > #PB_OS_MacOSX_10_5
        Parameters$ + " --args " ; needed to pass arg to the opened app to "open" commandline tool (only available on OS X 10.6+)
      EndIf
    EndIf
  CompilerEndIf
  
  ; Register the command file for auto deletion on IDE end
  ; (Deleting it when the program ends is too soon for Linux, with console mode
  ;  as the terminal starter seems to quit before the exe is loaded!)
  ;
  RegisterDeleteFile(CommFile$)
  
  If CreateFile(#FILE_StandaloneDebugger, CommFile$)
    
    ;
    ; Important: the command file is utf-8!
    ;
    
    ; write the general stuff
    ;
    WriteStringN(#FILE_StandaloneDebugger, "EXEFILE "+Executable$, #PB_UTF8)
    WriteStringN(#FILE_StandaloneDebugger, "COMMANDLINE "+*Target\CommandLine$, #PB_UTF8)
    WriteStringN(#FILE_StandaloneDebugger, "PREFERENCES "+PreferencesFile$, #PB_UTF8)
    
    ; Write warning mode
    ;
    If *Target\CustomWarning
      Mode = *Target\WarningMode
    Else
      Mode = WarningMode ; global setting
    EndIf
    
    Select Mode
      Case 0: WriteStringN(#FILE_StandaloneDebugger, "WARNINGS IGNORE", #PB_UTF8)
      Case 1: WriteStringN(#FILE_StandaloneDebugger, "WARNINGS DISPLAY", #PB_UTF8)
      Case 2: WriteStringN(#FILE_StandaloneDebugger, "WARNINGS ERROR", #PB_UTF8)
    EndSelect
    
    If *Target\EnablePurifier And *Target\PurifierGranularity$
      WriteStringN(#FILE_StandaloneDebugger, "PURIFIER "+*Target\PurifierGranularity$, #PB_UTF8)
    EndIf
    
    ; we no longer get the CompileFile passed here!
    If *Target\UseMainFile
      WriteStringN(#FILE_StandaloneDebugger, "SOURCEFILE "+ResolveRelativePath(GetPathPart(*Target\FileName$), *Target\MainFile$), #PB_UTF8)
      
    Else
      
      If *Target\FileName$ <> ""
        WriteStringN(#FILE_StandaloneDebugger, "SOURCEFILE "+*Target\FileName$, #PB_UTF8)
      Else
        CompilerIf #CompileMac
          WriteStringN(#FILE_StandaloneDebugger, "SOURCEFILE "+"/tmp/PB_EditorOutput.pb", #PB_UTF8)
        CompilerElse
          WriteStringN(#FILE_StandaloneDebugger, "SOURCEFILE "+Language("FileStuff", "NewSource"), #PB_UTF8)
        CompilerEndIf
      EndIf
      
    EndIf
    
    ; write the watchlist
    ;
    index = 1
    While StringField(*Target\Watchlist$, index, ";") <> ""
      WriteStringN(#FILE_StandaloneDebugger, "WATCH "+StringField(*Target\Watchlist$, index, ";"), #PB_UTF8)
      index + 1
    Wend
    
    
    ; just write breakpoints of any open file, those that are not compiled
    ; with this source will be ignored
    ;
    ForEach FileList()
      If @FileList() <> *ProjectInfo
        Line = -1
        Repeat
          Line = GetBreakPoint(@FileList(), Line+1)
          If Line <> -1
            
            If @FileList() = *Target ; this is the main source, include no filename
              WriteStringN(#FILE_StandaloneDebugger, "BREAK "+Str(Line+1), #PB_UTF8)
            Else
              WriteStringN(#FILE_StandaloneDebugger, "BREAK "+Str(Line+1)+","+FileList()\FileName$, #PB_UTF8)
            EndIf
            
          EndIf
        Until Line = -1
      EndIf
    Next FileList()
    ChangeCurrentElement(FileList(), *ActiveSource)
    
    CloseFile(#FILE_StandaloneDebugger)
    
    AddElement(Standalone_Debuggers())
    Standalone_Debuggers()\Directory$ = Directory$
    Standalone_Debuggers()\WaitStatus = 0
    Standalone_Debuggers()\CommandLine$ = DebuggerCMD$
    Standalone_Debuggers()\CommFile$    = CommFile$
    Standalone_Debuggers()\Parameters$  = Parameters$ + " -o "+Chr(34)+CommFile$+Chr(34)
    Standalone_Debuggers()\CompileTargetID= *Target\ID
    
    Debug "Standalone: "
    Debug Standalone_Debuggers()\CommandLine$
    Debug Standalone_Debuggers()\Parameters$
    Debug Standalone_Debuggers()\Directory$
    Debug CommFile$
    
    ; Use a special one for elevated mode of the debugger
    ; when debugging an admin tool on vista
    ;
    CompilerIf #CompileWindows
      If *Target\RunEnableAdmin And OSVersion() >= #PB_OS_Windows_Vista
        CreateThread(@StandaloneDebuggers_WaitThread_VistaAdmin(), @Standalone_Debuggers())
        ProcedureReturn
      EndIf
    CompilerEndIf
    
    CreateThread(@StandaloneDebuggers_WaitThread(), @Standalone_Debuggers())
  Else
    
    ; could not create the file
    ; Note: on linux, with the GUITerminal, this will not work, but this condition should not happen anyway
    RunProgram(DebuggerCMD$, Parameters$ + " " + Executable$ + " " + *Target\CommandLine$, Directory$)
  EndIf
  
  ; make sure the timer for event processing is running
  If IsDebuggerTimer = 0
    Debug "[Activate debugger timer]"
    AddWindowTimer(#WINDOW_Main, #TIMER_DebuggerProcessing, 20) ; check every 20 ms
    IsDebuggerTimer = 1
  EndIf
  
EndProcedure


; checks if a running externaldebugger has quit, and updates
; the watchlist that was passed back by it
;
Procedure StandaloneDebuggers_CheckExits()
  
  ForEach Standalone_Debuggers()
    
    If Standalone_Debuggers()\WaitStatus ; the debugger has quit!
      
      If Standalone_Debuggers()\CommFile$
        
        ; we only need the watchlist and purifier, but first we must check if the
        ; given target structure is still valid
        ;
        ; the breakpoints are ignored for now,as it might be a little confusing
        ; if they are altered after you quit the debugger
        ;
        *Target.CompileTarget = FindTargetFromID(Standalone_Debuggers()\CompileTargetID)
        
        If *Target
          If ReadFile(#FILE_StandaloneDebugger, Standalone_Debuggers()\CommFile$)
            *Target\Watchlist$ = ""
            
            While Eof(#FILE_StandaloneDebugger) = 0
              Line$ = ReadString(#FILE_StandaloneDebugger)
              If Left(Line$, 6) = "WATCH "
                *Target\Watchlist$ + Right(Line$, Len(Line$)-6) + ";"
              ElseIf Left(Line$, 9) = "PURIFIER "
                *Target\PurifierGranularity$ = Right(Line$, Len(Line$)-9)
              EndIf
            Wend
            
            If *Target\Watchlist$ <> ""
              *Target\Watchlist$ = Left(*Target\Watchlist$, Len(*Target\Watchlist$)-1) ; cut the last ";"
            EndIf
            
            CloseFile(#FILE_StandaloneDebugger)
          EndIf
        EndIf
        
        ; Do not delete here. This is too soon on Linux with debugger in a terminal
        ; (these files are deleted on IDE end)
        ; DeleteFile(Standalone_Debuggers()\CommFile$)
      EndIf
      
      DeleteElement(Standalone_Debuggers())
      Break
    EndIf
    
  Next Standalone_Debuggers()
  
EndProcedure

Procedure StandaloneDebuggers_IsRunning()
  If ListSize(Standalone_Debuggers()) > 0
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure