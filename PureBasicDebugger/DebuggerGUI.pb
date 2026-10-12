; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; update the enabled / disabled states for
; all windows of this debugger according to the ProgramState value
;
Procedure Debugger_UpdateWindowStates(*Debugger.DebuggerData)
  
  For i = 0 To #DEBUGGER_WINDOW_LAST-1
    If *Debugger\Windows[i]
      
      Select i
          
          ; debug output window doesn't need updating when program states change.
          
        Case #DEBUGGER_WINDOW_Asm
          UpdateAsmWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_Memory
          UpdateMemoryViewerWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_Variable
          UpdateVariableWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_History
          UpdateHistoryWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_WatchList
          UpdateWatchListWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_Library
          UpdateLibraryViewerState(*Debugger)
          
        Case #DEBUGGER_WINDOW_Profiler
          UpdateProfilerWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_DataBreakpoints
          UpdateDataBreakpointWindowState(*Debugger)
          
        Case #DEBUGGER_WINDOW_Purifier
          UpdatePurifierWindowState(*Debugger)
          
      EndSelect
      
    EndIf
  Next i
  
EndProcedure

; update the language for all open debugger windows
;
Procedure Debugger_UpdateWindowPreferences()
  
  ForEach RunningDebuggers()
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Debug]
      UpdateDebugWindow(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Asm]
      UpdateAsmWindow(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Memory]
      UpdateMemoryViewerWindow(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Variable]
      UpdateVariableWindow(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_History]
      UpdateHistoryWindow(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Library]
      UpdateLibraryViewer(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Profiler]
      UpdateProfilerWindow(@RunningDebuggers())
    EndIf
    
    If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Purifier]
      UpdatePurifierWindow(@RunningDebuggers())
    EndIf
    
    CompilerIf Not #SpiderBasic
      UpdateWatchListWindow(@RunningDebuggers()) ; this is always open
      UpdateDataBreakpointWindow(@RunningDebuggers()) ; also always open
    CompilerEndIf
    
    ; update the stay on top setting
    ;
    CompilerIf #DEFAULT_CanWindowStayOnTop
      For i = 0 To #DEBUGGER_WINDOW_LAST-1
        If RunningDebuggers()\Windows[i] <> 0
          SetWindowStayOnTop(RunningDebuggers()\Windows[i], DebuggerOnTop)
        EndIf
      Next i
    CompilerEndIf
    
  Next RunningDebuggers()
  
EndProcedure

; memorize the position and size of a debugger window while it is in the normal state (not maximized or minimized)
; the windows only memorize these when closed in the normal state, so without this a window moved to another
; screen and then closed while maximized would open maximized on the old screen
;
Procedure Debugger_MemorizeWindowRect(WindowIndex, Window)
  If DebuggerMemorizeWindows And IsWindowMaximized(Window) = 0 And IsWindowMinimized(Window) = 0
    Select WindowIndex
      Case #DEBUGGER_WINDOW_Debug: *X.INTEGER = @DebugWindowX : *Y.INTEGER = @DebugWindowY : *Width.INTEGER = @DebugWindowWidth : *Height.INTEGER = @DebugWindowHeight
      Case #DEBUGGER_WINDOW_Asm: *X = @AsmWindowX : *Y = @AsmWindowY : *Width = @AsmWindowWidth : *Height = @AsmWindowHeight
      Case #DEBUGGER_WINDOW_Memory: *X = @MemoryViewerX : *Y = @MemoryViewerY : *Width = @MemoryViewerWidth : *Height = @MemoryViewerHeight
      Case #DEBUGGER_WINDOW_Variable: *X = @VariableWindowX : *Y = @VariableWindowY : *Width = @VariableWindowWidth : *Height = @VariableWindowHeight
      Case #DEBUGGER_WINDOW_History: *X = @HistoryWindowX : *Y = @HistoryWindowY : *Width = @HistoryWindowWidth : *Height = @HistoryWindowHeight
      Case #DEBUGGER_WINDOW_WatchList: *X = @WatchListWindowX : *Y = @WatchListWindowY : *Width = @WatchListWindowWidth : *Height = @WatchListWindowHeight
      Case #DEBUGGER_WINDOW_Library: *X = @LibraryViewerX : *Y = @LibraryViewerY : *Width = @LibraryViewerWidth : *Height = @LibraryViewerHeight
      Case #DEBUGGER_WINDOW_Profiler: *X = @ProfilerX : *Y = @ProfilerY : *Width = @ProfilerWidth : *Height = @ProfilerHeight
      Case #DEBUGGER_WINDOW_DataBreakPoints: *X = @DataBreakpointWindowX : *Y = @DataBreakpointWindowY : *Width = @DataBreakpointWindowWidth : *Height = @DataBreakpointWindowHeight
      Default
        ProcedureReturn
    EndSelect
    
    *X\i      = WindowX(Window)
    *Y\i      = WindowY(Window)
    *Width\i  = WindowWidth(Window)
    *Height\i = WindowHeight(Window)
  EndIf
EndProcedure

; checks if an event is coming from a debugger window and dispatches it
; to the right procedure
; returns 1 if it was a debugger event and 0 if not
;
Procedure Debugger_ProcessEvents(EventWindowID, EventID)
  Processed = 0
  
  ; save and restore this, as this procedure might be called from
  ; a "ForEach RunningDebuggers()" itself!
  ;
  Index = ListIndex(RunningDebuggers())
  
  ForEach RunningDebuggers()
    
    For i = 0 To #DEBUGGER_WINDOW_LAST-1
      If RunningDebuggers()\Windows[i] = EventWindowID
        Processed = 1
        
        If EventID = #PB_Event_ActivateWindow ; process this for all windows
                                              ; Debug "activated!"
          If DebuggerBringToTop And DebuggerOnTop = 0
            
            ; bring all windows of this debugger to the top
            
            If DebuggerMainWindow ; start with the main window (if there is one)
              SetWindowForeground_NoActivate(DebuggerMainWindow)
            EndIf
            
            For x = 0 To #DEBUGGER_WINDOW_LAST-1
              If x <> i And RunningDebuggers()\Windows[x] <> 0
                ; handle the special cases (existing, but hidden windows
                If (x <> #DEBUGGER_WINDOW_Debug Or RunningDebuggers()\IsDebugOutputVisible) And (x <> #DEBUGGER_WINDOW_Watchlist Or RunningDebuggers()\IsWatchlistVisible)
                  SetWindowForeground_NoActivate(RunningDebuggers()\Windows[x])
                EndIf
              EndIf
            Next x
            
            ; make sure this one stays on the front
            SetWindowForeground_NoActivate(RunningDebuggers()\Windows[i])
            
          EndIf
        EndIf
        
        If EventID = #PB_Event_MoveWindow Or EventID = #PB_Event_SizeWindow
          Debugger_MemorizeWindowRect(i, EventWindowID)
        EndIf
        
        ; dispatch the event to the right procedure
        ;
        Select i
            
          Case #DEBUGGER_WINDOW_Debug
            DebugWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_Asm
            AsmWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_Memory
            MemoryViewerWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_Variable
            VariableWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_History
            HistoryWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_WatchList
            WatchListWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_Library
            LibraryViewerEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_Profiler
            ProfilerWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_DataBreakpoints
            DataBreakpointWindowEvents(@RunningDebuggers(), EventID)
            
          Case #DEBUGGER_WINDOW_Purifier
            PurifierWindowEvents(@RunningDebuggers(), EventID)
            
          Default ; unknown !?
            Processed = 0
            
        EndSelect
        
        Break 2
      EndIf
    Next i
    
  Next RunningDebuggers()
  
  If Index = -1
    ResetList(RunningDebuggers())
  Else
    SelectElement(RunningDebuggers(), Index)
  EndIf
  
  ProcedureReturn Processed
EndProcedure