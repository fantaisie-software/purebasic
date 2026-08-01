; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

UseSQLiteDatabase()


; whether or not to compress new history entries
; can be disabled for better debugging. should be enabled in releases
#ENABLE_HISTORY_COMPRESSION = #True
#HISTORY_COMPRESSION_LEVEL = 1 ; best speed

; enable to process events asynchronously (better for performance)
; disable this only for testing
#HISTORY_WRITE_ASYNC = #True

; enable to purge sessions which don't contain any edit events
#HISTORY_PURGE_EMPTY_SESSIONS = #True

; keep previous versions of displayed sources cached
; to speed up loading (as reconstructing multiple diffs takes time)
; especially when browsing within the history of one file, this helps a lot
#HISTORY_EVENT_SOURCE_CACHE = 100

; maximum number of diffs to create before writing again the full source in the event log.
; this must be smaller than the cache size, otherwise loading a single source with too many
; diff events will require more steps than fit in the cache and lead to bad performance
#HISTORY_EVENT_MAX_DIFFS = 75

;- Import extra sqlite stuff
;
ImportC ""
  sqlite3_last_insert_rowid.q(*sqlite3)
  
  sqlite3_bind_blob.l(*sqlite3_stmt, index.l, *buffer, size.l, *destructor)
  sqlite3_bind_int.l(*sqlite3_stmt, index.l, value.l)
  sqlite3_bind_null.l(*sqlite3_stmt, index.l)
  CompilerIf #PB_Compiler_Unicode
    sqlite3_bind_text16.l(*sqlite3_stmt, index.l, text, size.l, *destructor)
    sqlite3_prepare16_v2.l(*sqlite3, zSql, nByte.l, *ppStmt, *pzTail)
  CompilerElse
    sqlite3_bind_text.l(*sqlite3_stmt, index.l, text, size.l, *destructor)
    sqlite3_prepare_v2.l(*sqlite3, zSql, nByte.l, *ppStmt, *pzTail)
  CompilerEndIf
  
  sqlite3_step.l(*sqlite3_stmt)
  sqlite3_finalize.l(*sqlite3_stmt)
  
  sqlite3_threadsafe.l()
EndImport

#SQLITE_STATIC = 0
#SQLITE_TRANSIENT = -1

#SQLITE_OK = 0
#SQLITE_ROW = 100
#SQLITE_DONE = 101


;- Data types in history
;
Enumeration 1
  #DATA_Empty ; data is null. the file is empty
  #DATA_Same  ; data is null. the file is the same as on the previous event
  #DATA_Diff  ; data is a diff since the previous event
  #DATA_Full  ; data is the full file content (this is the case for new files in a session that are not empty)
  #DATA_DiffZ ; data is a diff (zlib compressed)
  #DATA_FullZ ; data is full file (zlib compressed)
EndEnumeration

; asynchronous handling of events for speed
Structure HistoryEvent
  *QueueNext.HistoryEvent ; next event in queue
  *ProcessedNext.HistoryEvent ; next in list of processed events
  SourceID.i                  ; id of the originating source
  HistoryName.s               ; filename or unique name for new files
  Encoding.l
  Event.l
  Time.l
  *Content      ; 0 if size=0
  Size.l
  Checksum.l
  FreshFile.l   ; has the file been saved?
  DiffCount.l   ; number of diffs written since the last full source (updated when the event is written)
  EventID.l     ; this is known after the event is written and used by the followup event
EndStructure

Structure EventSource
  EventID.l
  Encoding.l
  *Buffer   ; never #null (0-size event sources are not cached)
  Size.l
EndStructure

Global NewList EventSourceCache.EventSource()

Global OSSessionID$, SessionID
Global CurrentHistoryFile$, CurrentHistorySource
Global CompilerVersionWritten = #False
Global StartOfDay
Global CurrentUser$ = UserName()
Global NewMap HistoryFirstLines.i() ; map of first displayed lines for each file

Global NewList *HistoryEvents.HistoryEvent()
Global *HistoryMutex = CreateMutex()
Global *HistorySemaphore = CreateSemaphore()

; Note: cannot use a LinkedList as it is not threadsafe
Global *HistoryQueueHead.HistoryEvent = 0
Global *HistoryQueueTail.HistoryEvent = 0

; List of already processed events (one per file) managed by the thread only
Global *HistoryFirstProcessed.HistoryEvent = 0

Declare History_EventThread(*Dummy)

Procedure.s SqlEscape(String$)
  ProcedureReturn ReplaceString(String$, "'", "''")
EndProcedure

CompilerIf #PB_Compiler_Debugger
  
  Procedure DatabaseUpdate_DEBUG(db, sql$)
    Debug "[DB UPDATE] " + sql$
    r = DatabaseUpdate(db, sql$)
    If r = 0
      Debug "[DB FAILURE] " + DatabaseError()
      CallDebugger
    EndIf
    ProcedureReturn r
  EndProcedure
  
  Macro DatabaseUpdate(db, sql)
    DatabaseUpdate_DEBUG(db, sql)
  EndMacro
  
  Procedure DatabaseQuery_DEBUG(db, sql$)
    Debug "[DB QUERY] " + sql$
    r = DatabaseQuery(db, sql$)
    If r = 0
      Debug "[DB FAILURE] " + DatabaseError()
      CallDebugger
    EndIf
    ProcedureReturn r
  EndProcedure
  
  Macro DatabaseQuery(db, sql)
    DatabaseQuery_DEBUG(db, sql)
  EndMacro
  
CompilerEndIf


Procedure.s History_VersionString(CompilerVersion$)
  Title$ = CompilerVersion$
  Title$ = RemoveString(Title$, "Windows - ") ; remove the OS part as it is redundant information
  Title$ = RemoveString(Title$, "Linux - ")
  Title$ = RemoveString(Title$, "MacOS X - ")
  Title$ = RemoveString(Title$, #ProductName$ + " ") ; also remove the prefix
  ProcedureReturn Title$
EndProcedure

Procedure.s History_GetOption(Key$)
  Value$ = ""
  If DatabaseQuery(#DB_History, "SELECT value FROM options WHERE key = '" + SqlEscape(Key$) + "'")
    If NextDatabaseRow(#DB_History)
      Value$ = GetDatabaseString(#DB_History, 0)
    EndIf
    FinishDatabaseQuery(#DB_History)
  EndIf
  ProcedureReturn Value$
EndProcedure

Procedure History_SetOption(Key$, Value$)
  ; the ON CONFLICT clause of the table causes any old value for the same key to be deleted
  ; automatically
  DatabaseUpdate(#DB_History, "INSERT INTO options (key, value) VALUES ('" + SqlEscape(Key$) + "', '" + SqlEscape(Value$) + "')")
EndProcedure

Procedure StartHistorySession()
  
  ; no setup if history is disabled
  If EnableHistory = #False
    ProcedureReturn
  EndIf
  
  ; check threadsafety of sqlite (should be always on)
  If sqlite3_threadsafe() = 0
    MessageRequester(#ProductName$, "Critical: sqlite is not compiled threadsafe")
    End
  EndIf
  
  ; make sure the db file exists
  If OpenFile(#FILE_Database, HistoryDatabaseFile$)
    CloseFile(#FILE_Database)
  EndIf
  
  ; open database
  HistoryActive = OpenDatabase(#DB_History, HistoryDatabaseFile$, "", "", #PB_Database_SQLite)
  
  If HistoryActive
    
    ; Options table: stores unique key value pairs
    ; This table is used for DB version checks, so do not modify it in the future!
    DatabaseUpdate(#DB_History, "CREATE TABLE IF NOT EXISTS options(key TEXT UNIQUE ON CONFLICT REPLACE, value NOT NULL)")
    
    ; The minor version is increased when compatible changes are done.
    ; I.e. a "1.1" IDE can still access a "1.5" database
    ; The major version is increased when incompatible changes are made to
    ; prevent corruption of a newer db or confusing old IDE versions
    ;
    ; Right now the version is "1.1" and this IDE will access any DB of version "1.X"
    ;
    Major$ = History_GetOption("version.major")
    Minor$ = History_GetOption("version.minor")
    
    ; Check for compatible major version
    If Major$ <> "" And Major$ <> "1"
      MessageRequester(#ProductName$, LanguagePattern("History", "VersionError", "%filename%", HistoryDatabaseFile$))
      CloseDatabase(#DB_History)
      HistoryActive = 0
      ProcedureReturn
    EndIf
    
    ; write version options if not present
    If Major$ = ""
      History_SetOption("version.major", "1")
    EndIf
    If Minor$ = ""
      History_SetOption("version.minor", "1")
    EndIf
    
    ; Session table:
    ;   session_id : primary key of table
    ;   os_id      : ID created by Session_Start() to detect dead instances. set to null for properly ended sessions
    ;   version    : Compiler version (default compiler of the IDE)
    ;   user       : OS user name
    ;   start_time : session start time
    ;   end_time   : session end time (0 for still running)
    ;   warned     : 1 if a warning was displayed for a detected dead session
    ;
    DatabaseUpdate(#DB_History, "CREATE TABLE IF NOT EXISTS session(session_id INTEGER PRIMARY KEY, os_id STRING, version TEXT NOT NULL, user TEXT NOT NULL, start_time INTEGER NOT NULL, end_time INTEGER NOT NULL, warned INTEGER NOT NULL)")
    
    ; Event table:
    ;   event_id       : primary key
    ;   session_id     : session id
    ;   filename       : file name (for new files: "::unsaved::" + unique id + creation time stamp)
    ;   event          : one of the #HISTORY_XXX values
    ;   time           : event time stamp
    ;   type           : one of the #DATA_XXX values
    ;   previous_event : id of previous event for the file (if any)
    ;   encoding       : encoding of source file
    ;   data           : file data or null, depending on type
    ;
    DatabaseUpdate(#DB_History, "CREATE TABLE IF NOT EXISTS event(event_id INTEGER PRIMARY KEY, session_id INTEGER NOT NULL, filename TEXT NOT NULL, event INTEGER NOT NULL, time INTEGER NOT NULL, type INTEGER NOT NULL, previous_event INTEGER, encoding INTEGER NOT NULL, data BLOB)")
    
    ; create indices for fast searching
    DatabaseUpdate(#DB_History, "CREATE INDEX IF NOT EXISTS idx_session1 ON session (start_time)")
    DatabaseUpdate(#DB_History, "CREATE INDEX IF NOT EXISTS idx_session2 ON session (end_time)")
    DatabaseUpdate(#DB_History, "CREATE INDEX IF NOT EXISTS idx_event1 ON event (session_id, filename)")
    
    ; get version string
    ; note: this is probably empty still if the compiler is too slow to load so it will be updated later
    Title$ = History_VersionString(DefaultCompiler\VersionString$)
    
    ; Setup detection of crashed sessions
    ; The OSSessionID is only unique for currently running sessions
    ; It is used to detect which unended session is still running and which is crashed
    OSSessionID$ = Session_Start()
    
    DatabaseUpdate(#DB_History, "INSERT INTO session(os_id, version, user, start_time, end_time, warned) values ('" + OSSessionID$ + "', '" + SqlEscape(Title$) + "', '" + SqlEscape(UserName()) + "', " + Str(Date()) + ", 0, 0)")
    SessionID = sqlite3_last_insert_rowid(DatabaseID(#DB_History))
    
    AddWindowTimer(#WINDOW_Main, #TIMER_History, HistoryTimer * 60000) ; value is in minutes
    
    ; create thread for asynchronous event writing
    ; must disable the debugger here, because the thread proc is in DisableDebugger too,
    ; so the debugger will complain that it does not know the procedure
    CompilerIf #HISTORY_WRITE_ASYNC
      DisableDebugger
      If CreateThread(@History_EventThread(), 0) = 0
        MessageRequester(#ProductName$, "Critical error: Cannot create thread for session history recording")
        CloseDatabase(#DB_History)
        HistoryActive = 0
      EndIf
      EnableDebugger
    CompilerEndIf
    
  Else
    MessageRequester(#ProductName$, LanguagePattern("History", "FileError", "%filename%", HistoryDatabaseFile$))
  EndIf
  
EndProcedure

Procedure HistoryCompilerLoaded()
  If HistoryActive And CompilerVersionWritten = #False
    Title$ = History_VersionString(DefaultCompiler\VersionString$)
    DatabaseUpdate(#DB_History, "UPDATE session SET version = '" + SqlEscape(Title$) + "' WHERE session_id = " + Str(SessionID))
    CompilerVersionWritten = #True
  EndIf
EndProcedure

Procedure DetectCrashedHistorySession()
  If HistoryActive
    
    NewList CrashedSID.i()
    
    ; get all sessions that are marked as not closed and not warned
    ; display most recent if multiple crashes (could happen if multiple instances are running and the pc crashes)
    sql$ = "SELECT session_id, os_id FROM session "
    sql$ + "WHERE end_time = 0 AND warned = 0 "
    sql$ + "ORDER BY start_time DESC"
    
    If DatabaseQuery(#DB_History, sql$)
      ; check any hits against the running sessions
      While NextDatabaseRow(#DB_History)
        sid   = GetDatabaseLong(#DB_History, 0)
        OSID$ = GetDatabaseString(#DB_History, 1)
        
        If sid <> SessionID And Session_IsRunning(OSID$) = #False
          AddElement(CrashedSID())
          CrashedSID() = sid
        EndIf
      Wend
      
      FinishDatabaseQuery(#DB_History)
    EndIf
    
    If ListSize(CrashedSID()) > 0
      
      ; set the warned flag for all these sessions
      DatabaseUpdate(#DB_History, "BEGIN TRANSACTION")
      ForEach CrashedSID()
        DatabaseUpdate(#DB_History, "UPDATE session SET warned = 1 WHERE session_id = " + Str(CrashedSID()))
      Next CrashedSID()
      DatabaseUpdate(#DB_History, "COMMIT TRANSACTION")
      
      ; ask if the session history should be shown
      If MessageRequester(#ProductName$, Language("History", "CrashedInfo"), #FLAG_Question|#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
        FirstElement(CrashedSID())
        OpenEditHistoryWindow(CrashedSID())
      EndIf
      
    EndIf
    
    
  EndIf
EndProcedure

Procedure History_FlushEvents()
  CompilerIf #HISTORY_WRITE_ASYNC
    WaitStart.q = ElapsedMilliseconds()
    Hidden = #True
    
    ; wait until the queue is clear
    ; no need for any locking as it is just a simple check
    While *HistoryQueueHead
      WaitWindowEvent(50)
      
      If Hidden And (ElapsedMilliseconds() - WaitStart > 1000) ; Display the window after 1 sec of waiting
        ; setup a window to display if the wait is too long (hidden)
        Window.DialogWindow = OpenDialog(?Dialog_HistoryShutdown) ; Warning, on MacOS, creating the window sometimes crash when the IDE exits, so open it open when necessary to minimize the issue
        HideWindow(#WINDOW_EditHistoryShutdown, #False)
        SetGadgetState(#GADGET_HistoryShutdown_Progress, #PB_ProgressBar_Unknown)
        Hidden = #False
        
        CompilerIf #CompileLinuxGtk
          gtk_window_set_position_(WindowID(#WINDOW_EditHistoryShutdown), #GTK_WIN_POS_CENTER_ALWAYS)
        CompilerEndIf
        
        CompilerIf #CompileMacCocoa
          PB_Gadget_CenterWindow(WindowID(#WINDOW_EditHistoryShutdown))
        CompilerEndIf
      EndIf
      
    Wend
    
    If Window
      SetGadgetState(#GADGET_HistoryShutdown_Progress, 0)
      Window\Close(0)
    EndIf
    
  CompilerEndIf
EndProcedure


Procedure HistoryShutdownEvents()
  
  If HistoryActive
    
    ; write a close event for any still open files
    ; the ide only saves, but does not close each file on shutdown!
    ForEach FileList()
      HistoryEvent(@FileList(), #HISTORY_Close)
    Next FileList()
    
  EndIf
  
EndProcedure


Procedure EndHistorySession()
  
  If HistoryActive
    
    ; wait until all these events are written
    ; the WriteShutdownEvents() procedure can write quite a lot of events, so this could take some time
    History_FlushEvents()
    
    ; write that the session correctly ended
    DatabaseUpdate(#DB_History, "UPDATE session SET os_id = null, end_time = " + Str(Date()) + " WHERE session_id = " + Str(SessionID))
    
    ; end detection of bad sessions
    Session_End(OSSessionID$)
    
    ; Now purge old sessions if needed
    ;
    PurgeList$ = ""
    
    If HistoryPurgeMode = 1
      
      ; purge by session count
      ; exclude running and crashed (not warned) sessions
      sql$ = "SELECT session_id FROM session "
      sql$ + "WHERE end_time <> 0 OR warned = 1 "
      sql$ + "ORDER BY start_time DESC"
      
      If DatabaseQuery(#DB_History, sql$)
        ; skip the number of sessions to keep
        Count = 0
        While Count < MaxSessionCount And NextDatabaseRow(#DB_History)
          Count + 1
        Wend
        
        ; record sessions for deleting
        While NextDatabaseRow(#DB_History)
          PurgeList$ + ", " + Str(GetDatabaseLong(#DB_History, 0))
        Wend
        
        FinishDatabaseQuery(#DB_History)
      EndIf
      
    ElseIf HistoryPurgeMode = 2
      
      ; purge by start date
      CurrentDate = Date()
      StartOfDay = Date(Year(CurrentDate), Month(CurrentDate), Day(CurrentDate), 0, 0, 0)
      CutOff = AddDate(StartOfDay, #PB_Date_Day, -MaxSessionDays)
      
      ; cut off by end_time
      ; for crashed sessions, use start time, but exclude not yet warned ones
      sql$ = "SELECT session_id FROM session "
      sql$ + "WHERE (end_time < " + Str(CutOff) + " AND end_time <> 0) "
      sql$ + "OR (end_time = 0 AND start_time < " + Str(CutOff) + " AND warned = 1)"
      
      If DatabaseQuery(#DB_History, sql$)
        ; record sessions for deleting
        While NextDatabaseRow(#DB_History)
          PurgeList$ + ", " + Str(GetDatabaseLong(#DB_History, 0))
        Wend
        
        FinishDatabaseQuery(#DB_History)
      EndIf
      
    EndIf
    
    CompilerIf #HISTORY_PURGE_EMPTY_SESSIONS
      NewList FoundSessionID$()
      If DatabaseQuery(#DB_History, "SELECT session_id FROM session")
        While NextDatabaseRow(#DB_History)
          AddElement(FoundSessionID$())
          FoundSessionID$() = GetDatabaseString(#DB_History, 0)
        Wend
        FinishDatabaseQuery(#DB_History)
        
        ForEach FoundSessionID$()
          If DatabaseQuery(#DB_History, "SELECT COUNT(*) FROM event WHERE session_id='" + FoundSessionID$() + "'")
            If NextDatabaseRow(#DB_History)
              If GetDatabaseLong(#DB_History, 0) = 0
                PurgeList$ + ", " + FoundSessionID$()
              EndIf
            EndIf
            FinishDatabaseQuery(#DB_History)
          EndIf
        Next
      EndIf
      FreeList(FoundSessionID$())
    CompilerEndIf
    
    If PurgeList$ <> ""
      ; strip beginning ", "
      PurgeList$ = Mid(PurgeList$, 3)
      ; purge them all at once
      DatabaseUpdate(#DB_History, "BEGIN TRANSACTION")
      DatabaseUpdate(#DB_History, "DELETE FROM event WHERE session_id IN (" + PurgeList$ + ")")
      DatabaseUpdate(#DB_History, "DELETE FROM session WHERE session_id IN (" + PurgeList$ + ")")
      DatabaseUpdate(#DB_History, "COMMIT TRANSACTION")
    EndIf
    
    ; close db
    CloseDatabase(#DB_History)
    
  EndIf
EndProcedure

; Make a unique ID string for file identification
;
Procedure.s History_MakeUniqueId()
  Length = 16
  Dim Buffer.a(Length-1)
  
  If OpenCryptRandom()
    CryptRandomData(@Buffer(0), Length)
    CloseCryptRandom()
  Else
    RandomData(@Buffer(0), Length)
  EndIf
  
  Result$ = ""
  For i = 0 To Length-1
    Result$ + RSet(Hex(Buffer(i)), 2, "0")
  Next i
  
  ProcedureReturn Result$
EndProcedure

CompilerIf #HISTORY_WRITE_ASYNC
  DisableDebugger
CompilerEndIf

Procedure History_FreeEvent(*Event.HistoryEvent)
  If *Event\Content
    FreeMemory(*Event\Content)
  EndIf
  ClearStructure(*Event, HistoryEvent)
  FreeMemory(*Event)
EndProcedure

Procedure History_AsyncUpdateName(PreviousName$, Name$)
  
  CompilerIf #HISTORY_WRITE_ASYNC = #False
    Debug "Async: updating event names: " + PreviousName$ + " to " + Name$
  CompilerEndIf
  
  ; Use bind variables as we cannot modify strings in this thread
  Protected Success = #False
  CompilerIf #PB_Compiler_Unicode
    If sqlite3_prepare16_v2(DatabaseID(#DB_History), @"UPDATE event SET filename = ? WHERE filename = ? AND session_id = ?", -1, @*Statement, #Null) = #SQLITE_OK
      Success = #True
      sqlite3_bind_text16(*Statement, 1, @Name$, -1, #SQLITE_STATIC)
      sqlite3_bind_text16(*Statement, 2, @PreviousName$, -1, #SQLITE_STATIC)
    EndIf
  CompilerElse
    If sqlite3_prepare_v2(DatabaseID(#DB_History), @"UPDATE event SET filename = ? WHERE filename = ? AND session_id = ?", -1, @*Statement, #Null) = #SQLITE_OK
      Success = #True
      sqlite3_bind_text(*Statement, 1, @Name$, -1, #SQLITE_STATIC)
      sqlite3_bind_text(*Statement, 2, @PreviousName$, -1, #SQLITE_STATIC)
    EndIf
  CompilerEndIf
  
  If Success
    sqlite3_bind_int(*Statement, 3, SessionID)
    
    While sqlite3_step(*Statement) = #SQLITE_ROW: Wend
    sqlite3_finalize(*Statement)
  EndIf
  
  
EndProcedure

Procedure History_AsyncDeleteEvent(EventID)
  
  CompilerIf #HISTORY_WRITE_ASYNC = #False
    Debug "Async: deleting event with id: " + Str(EventID)
  CompilerEndIf
  
  Protected Success = #False
  CompilerIf #PB_Compiler_Unicode
    If sqlite3_prepare16_v2(DatabaseID(#DB_History), @"DELETE FROM event WHERE event_id = ?", -1, @*Statement, #Null) = #SQLITE_OK
      Success = #True
    EndIf
  CompilerElse
    If sqlite3_prepare_v2(DatabaseID(#DB_History), @"DELETE FROM event WHERE event_id = ?", -1, @*Statement, #Null) = #SQLITE_OK
      Success = #True
    EndIf
  CompilerEndIf
  
  If Success
    sqlite3_bind_int(*Statement, 1, EventID)
    
    While sqlite3_step(*Statement) = #SQLITE_ROW: Wend
    sqlite3_finalize(*Statement)
  EndIf
  
EndProcedure

; Generates an edit script:
; Beginning: <long> full size of target
;
; C<long> : copy from source
; D<long> : skip from source
; A<long><content> : add content from diff
;
; returns size of diff'ed content
; returns 0 if diff is larger than real file
Procedure History_MakeDiff(*Output, *OutSize.INTEGER, *Event.HistoryEvent, *Previous.HistoryEvent)

  ; The diff algorithm needs thread safety because of the LinkedList commands
  CompilerIf #HISTORY_WRITE_ASYNC And #PB_Compiler_Thread = 0
    CompilerError "History_MakeDiff() must be compiled with threadsafe switch"
  CompilerEndIf

  Protected Ctx.DiffContext
  Diff(@Ctx, *Previous\Content, *Previous\Size, *Event\Content, *Event\Size)
  
  ; write the output
  *OutputEnd = *Output + *OutSize\i
  *Pointer.PTR = *Output
  *Pointer\l = *Event\Size ; store original size
  *Pointer + 4             ; skip original size storage
  
  ForEach Ctx\Edits()
    If *Pointer + 5 > *OutputEnd
      ProcedureReturn #False
    EndIf
    
    Select Ctx\Edits()\Op
      Case #DIFF_MATCH
        *Pointer\b = 'C': *Pointer + 1
        *Pointer\l = Ctx\Edits()\Length: *Pointer + 4
        
      Case #DIFF_DELETE
        *Pointer\b = 'D': *Pointer + 1
        *Pointer\l = Ctx\Edits()\Length: *Pointer + 4
        
      Case #DIFF_INSERT
        *Pointer\b = 'A': *Pointer + 1
        *Pointer\l = Ctx\Edits()\Length: *Pointer + 4
        
        If *Pointer + Ctx\Edits()\Length > *OutputEnd
          ProcedureReturn #False
        EndIf
        
        CopyMemory(Ctx\Edits()\Start, *Pointer, Ctx\Edits()\Length)
        *Pointer + Ctx\Edits()\Length
        
    EndSelect
  Next Ctx\Edits()
  
  *OutSize\i = *Pointer - *Output
  ProcedureReturn #True
EndProcedure


Procedure History_ApplyDiff(*Output, *PreviousBuffer, *Diff.PTR, DiffSize)
  
  *DiffEnd = *Diff + DiffSize
  
  *Diff + 4 ; skip expanded size
  
  While *Diff < *DiffEnd
    Select *Diff\b
        
      Case 'C'
        *Diff + 1
        Size = *Diff\l: *Diff + 4
        CopyMemory(*PreviousBuffer, *Output, Size)
        *PreviousBuffer + Size
        *Output + Size
        
      Case 'D'
        *Diff + 1
        Size = *Diff\l: *Diff + 4
        ; just skip on the input
        *PreviousBuffer + Size
        
      Case 'A'
        *Diff + 1
        Size = *Diff\l: *Diff + 4
        CopyMemory(*Diff, *Output, Size)
        *Diff + Size
        *Output + Size
        
      Default
        ; something is wrong here
        ProcedureReturn #False
        
    EndSelect
  Wend
  
  ProcedureReturn #True
EndProcedure

Procedure History_WriteEvent(*Event.HistoryEvent)
  
  ; calculate checksum if needed
  If *Event\Checksum = 0 And *Event\Content And *Event\Size
    *Event\Checksum = CRC32Fingerprint(*Event\Content, *Event\Size)
  EndIf
  
  ; find any previous event for the same source and remove it from the list
  ; this list is accessed only by this thread
  *Update.HistoryEvent = 0 ; the one to update on a delete
  *Previous.HistoryEvent = *HistoryFirstProcessed
  While *Previous And *Previous\SourceID <> *Event\SourceID
    *Update = *Previous
    *Previous = *Previous\ProcessedNext
  Wend
  
  ; previous event found
  If *Previous
    
    ; If the Event is #HISTORY_Edit, decide if there were changes
    ; Drop the event if there were no changes since last time
    If *Event\Event = #HISTORY_Edit And *Previous\Size = *Event\Size And *Previous\Checksum = *Event\Checksum
      History_FreeEvent(*Event)
      ProcedureReturn
    EndIf
    
    ; unlink the previous event from list
    If *Update
      *Update\ProcessedNext = *Previous\ProcessedNext
    Else
      *HistoryFirstProcessed = *Previous\ProcessedNext
    EndIf
    
    ; if the event is close, and the only previous event is open or create,
    ; drop both from the db to avoid lots of empty open/close event combinations
    If *Event\Event = #HISTORY_Close And (*Previous\Event = #HISTORY_Create Or *Previous\Event = #HISTORY_Open)
      History_AsyncDeleteEvent(*Previous\EventID)
      History_FreeEvent(*Previous)
      History_FreeEvent(*Event)
      ProcedureReturn
    EndIf
    
    ; if a fresh file is saved, rename all old events to the new filename
    If *Event\Event = #HISTORY_SaveAs And *Previous\FreshFile
      History_AsyncUpdateName(*Previous\HistoryName, *Event\HistoryName)
    EndIf
    
  EndIf
  
  ; prepare/compress the contents for storage
  StorageSize = 0
  *StorageBuffer = #Null
  
  If *Event\Content = #Null
    Type = #DATA_Empty
    PreviousEventID = 0
    *Event\DiffCount = 0
    
  ElseIf *Previous = #Null Or *Previous\Content = #Null Or *Previous\DiffCount >= #HISTORY_EVENT_MAX_DIFFS
    ; write full data if no previous data exists, or the max diff count is reached
    Type = #DATA_Full
    PreviousEventID = 0
    StorageSize = *Event\Size
    *StorageBuffer = *Event\Content
    
    ; attempt to compress
    CompilerIf #ENABLE_HISTORY_COMPRESSION
      CompressedSize = compressBound(*Event\Size) + 4
      *CompressedBuffer = AllocateMemory(CompressedSize)
      If *CompressedBuffer
        CompressedSize - 4
        If compress2(*CompressedBuffer + 4, @CompressedSize, *Event\Content , *Event\Size, #HISTORY_COMPRESSION_LEVEL) = #Z_OK
          Type = #DATA_FullZ
          PokeL(*CompressedBuffer, *Event\Size) ; store original size in first 4 bytes
          StorageSize = CompressedSize + 4
          *StorageBuffer = *CompressedBuffer
        Else
          FreeMemory(*CompressedBuffer)
        EndIf
      EndIf
    CompilerEndIf
    *Event\DiffCount = 0
    
  ElseIf *Event\Size = *Previous\Size And *Event\Checksum = *Previous\Checksum
    Type = #DATA_Same
    PreviousEventID = *Previous\EventID
    *Event\DiffCount = *Previous\DiffCount + 1
    
  Else
    ; fallback to full if something fails below
    Type = #DATA_Full
    PreviousEventID = 0
    StorageSize = *Event\Size
    *StorageBuffer = *Event\Content
    *Event\DiffCount = *Previous\DiffCount + 1
    
    ; try to diff
    *DiffBuffer = AllocateMemory(StorageSize + 4) ; 4 bytes for the unpacked size
    If *DiffBuffer
      DiffSize = StorageSize + 4
      If History_MakeDiff(*DiffBuffer, @DiffSize, *Event, *Previous)
        Type = #DATA_Diff
        *StorageBuffer = *DiffBuffer
        StorageSize = DiffSize
        PreviousEventID = *Previous\EventID
      Else
        FreeMemory(*DiffBuffer) ; diff is larger than original!
        *DiffBuffer = 0
      EndIf
    EndIf
    
    ; attempt to compress
    CompilerIf #ENABLE_HISTORY_COMPRESSION
      CompressedSize = compressBound(StorageSize) + 4
      *CompressedBuffer = AllocateMemory(CompressedSize)
      If *CompressedBuffer
        CompressedSize - 4
        If compress2(*CompressedBuffer + 4, @CompressedSize, *StorageBuffer, StorageSize, #HISTORY_COMPRESSION_LEVEL) = #Z_OK
          If Type = #DATA_Diff
            Type = #DATA_DiffZ
            FreeMemory(*DiffBuffer) ; diff buffer is no longer needed. storagebuffer is overwritten below
          Else
            Type = #DATA_FullZ
          EndIf
          PokeL(*CompressedBuffer, StorageSize) ; store original size in first 4 bytes
          StorageSize = CompressedSize + 4
          *StorageBuffer = *CompressedBuffer
        Else
          FreeMemory(*CompressedBuffer)
        EndIf
      EndIf
    CompilerEndIf
    
  EndIf
  
  ; Update the DB
  ; We cannot use the Database functions for thread safety
  ; Use the sqlite functions directly
  ; In PB, sqlite is compiled threadsafe, so this is ok
  CompilerIf #HISTORY_WRITE_ASYNC = #False
    Debug "Async: writing history event: " + Str(*Event\Event)
  CompilerEndIf
  
  ; Use bind variables as we cannot modify strings in this thread
  Protected Success = #False
  CompilerIf #PB_Compiler_Unicode
    If sqlite3_prepare16_v2(DatabaseID(#DB_History), @"INSERT INTO event(session_id, filename, event, time, type, previous_event, encoding, data) VALUES (?,?,?,?,?,?,?,?)", -1, @*Statement, #Null) = #SQLITE_OK
      Success = #True
      sqlite3_bind_int (*Statement, 1, SessionID)
      sqlite3_bind_text16(*Statement, 2, @*Event\HistoryName, -1, #SQLITE_STATIC)
    EndIf
  CompilerElse
    If sqlite3_prepare_v2(DatabaseID(#DB_History), @"INSERT INTO event(session_id, filename, event, time, type, previous_event, encoding, data) VALUES (?,?,?,?,?,?,?,?)", -1, @*Statement, #Null) = #SQLITE_OK
      Success = #True
      sqlite3_bind_int (*Statement, 1, SessionID)
      sqlite3_bind_text(*Statement, 2, @*Event\HistoryName, -1, #SQLITE_STATIC)
    EndIf
  CompilerEndIf
  
  If Success
    sqlite3_bind_int (*Statement, 3, *Event\Event)
    sqlite3_bind_int (*Statement, 4, *Event\Time)
    sqlite3_bind_int (*Statement, 5, Type)
    sqlite3_bind_int (*Statement, 6, PreviousEventID)
    sqlite3_bind_int (*Statement, 7, *Event\Encoding)
    
    If *StorageBuffer
      sqlite3_bind_blob(*Statement, 8, *StorageBuffer, StorageSize, #SQLITE_STATIC)
    Else
      sqlite3_bind_null(*Statement, 8)
    EndIf
    
    While sqlite3_step(*Statement) = #SQLITE_ROW: Wend
    sqlite3_finalize(*Statement)
    
    ; retrieve the event id
    *Event\EventID = sqlite3_last_insert_rowid(DatabaseID(#DB_History))
  EndIf
  
  ; free compressed buffer
  If *StorageBuffer And *StorageBuffer <> *Event\Content
    FreeMemory(*StorageBuffer)
  EndIf
  
  ; free the previous event info
  If *Previous
    History_FreeEvent(*Previous)
  EndIf
  
  ; if this is a close, free the current event
  ; otherwise store it for reference on the next one
  If *Event\Event = #HISTORY_Close
    History_FreeEvent(*Event)
    
  Else
    *Event\ProcessedNext = *HistoryFirstProcessed
    *HistoryFirstProcessed = *Event
    
  EndIf
  
EndProcedure


Procedure History_EventThread(*Dummy)
  
  Repeat
    
    ; wait and get the next event to process
    WaitSemaphore(*HistorySemaphore)
    LockMutex(*HistoryMutex)
    *Event.HistoryEvent = *HistoryQueueHead
    *HistoryQueueHead = *Event\QueueNext
    If *HistoryQueueHead = 0
      *HistoryQueueTail = 0
    EndIf
    UnlockMutex(*HistoryMutex)
    
    ; write the event
    History_WriteEvent(*Event)
    
  ForEver
  
EndProcedure

CompilerIf #HISTORY_WRITE_ASYNC
  EnableDebugger
CompilerEndIf


Procedure HistoryEvent(*Source.SourceFile, Event)
  If HistoryActive And *Source <> *ProjectInfo And *Source\IsForm = #False
    Debug "[HISTORY] Event: " + Str(Event)
    
    ; Behavior for SaveAs
    ; - for fresh files, the writing procedure will rename all previous events to the new name
    ;   so all events have the identity of the saved name, even the older ones
    ; - for old files. write a 'close' event for the old file name. then the normal
    ;   SaveAs for the new filename to separate the two now existing streams of events
    If Event = #HISTORY_SaveAs And *Source\FreshFile = #False
      HistoryEvent(*Source, #HISTORY_Close)
    EndIf
    
    Size = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLENGTH, 0, 0)
    If Size > HistoryMaxFileSize
      
      ; Size checking works like this:
      ; If the file is too large on open, it is excluded entirely (ExcludeFromHistory = true)
      ; If the file was small but grows to large, write no events but the
      ; close event, so the event log is consistent
      ;
      If Event = #HISTORY_Open
        *Source\ExcludeFromHistory = #True
        ProcedureReturn
      ElseIf *Source\ExcludeFromHistory = #False And Event <> #HISTORY_CLOSE
        ProcedureReturn
      EndIf
    EndIf
    
    ; change HistoryName if needed
    ;
    If Event = #HISTORY_Create
      ; make a unique name for this unsaved file. append the creation date so it can later be used for display
      *Source\HistoryName = "::unsaved::" + History_MakeUniqueID() + Str(Date())
      *Source\FreshFile = #True
      
    ElseIf Event = #HISTORY_Open Or Event = #HISTORY_Save Or Event = #HISTORY_SaveAs
      *Source\HistoryName = *Source\FileName$
      *Source\FreshFile = #False
      
    EndIf
    
    ; get the content
    If Size = 0
      *Buffer = #Null
    Else
      *Buffer = AllocateMemory(Size+1)
      ScintillaSendMessage(*Source\EditorGadget,#SCI_GETTEXT, Size+1, *Buffer)
    EndIf
    
    ; enqueue a task to write this event in the thread
    ; this gives significant speedup when loading many files at once (like on startup)
    *Event.HistoryEvent = AllocateMemory(SizeOf(HistoryEvent))
    *Event\SourceID     = *Source\ID
    *Event\HistoryName  = *Source\HistoryName
    *Event\Encoding     = *Source\Parser\Encoding
    *Event\Event        = Event
    *Event\Time         = Date()
    *Event\Content      = *Buffer
    *Event\Size         = Size
    *Event\Checksum     = 0 ; not yet calculated
    *Event\FreshFile    = *Source\FreshFile
    *Event\EventID      = -1 ; set by the thread when writing the event
    
    CompilerIf #HISTORY_WRITE_ASYNC
      LockMutex(*HistoryMutex)
      If *HistoryQueueTail = 0
        ; queue is empty
        *HistoryQueueHead = *Event
        *HistoryQueueTail = *Event
      Else
        *HistoryQueueTail\QueueNext = *Event
        *HistoryQueueTail = *Event
      EndIf
      UnlockMutex(*HistoryMutex)
      SignalSemaphore(*HistorySemaphore)
      
    CompilerElse
      History_WriteEvent(*Event)
      
    CompilerEndIf
    
  EndIf
EndProcedure

Procedure HistoryTimer()
  If HistoryActive
    
    ForEach FileList()
      If @FileList() <> *ProjectInfo And FileList()\IsForm = 0 And FileList()\ExcludeFromHistory = 0
        ; the event writing figures out if there are changes
        ; and will discard this event if there are none
        HistoryEvent(@FileList(), #HISTORY_Edit)
      EndIf
    Next FileList()
    
  EndIf
EndProcedure

; Get a the time from a date value only
;
Procedure.s TimeToString(time)
  ProcedureReturn FormatDate(Language("History","TimeFormat"), time)
EndProcedure

; Get a time or date from a date value depending if it is today or earlier
;
Procedure.s DateTimeToString(time)
  
  If time >= StartOfDay
    ; today: just the time
    ProcedureReturn TimeToString(time)
    
  ElseIf ((StartOfDay - time) / (24*60*60)) < 4
    ; the past few days, use a weekday for readability
    WeekDay$ = Language("Misc", "Weekday" + Str(DayOfWeek(time)))
    ProcedureReturn WeekDay$ + " " + TimeToString(time)
    
  Else
    ; use a day and month
    ProcedureReturn FormatDate(Language("History","DateTimeFormat"), time)
    
  EndIf
  
EndProcedure

; special return value for empty sources
Global EmptyEventSource.EventSource

; Returns an EventSource structure
Procedure History_LoadEventSource(EventID)
  
  ; check cache first
  ForEach EventSourceCache()
    If EventSourceCache()\EventID = EventID
      Debug "[HISTORY CACHE] HIT: " + Str(EventID)
      
      ; move to the front of the list (indicates most recently used)
      MoveElement(EventSourceCache(), #PB_List_First)
      
      ProcedureReturn @EventSourceCache()
    EndIf
  Next EventSourceCache()
  
  ; check the db
  *Buffer = 0
  Size = 0
  
  If DatabaseQuery(#DB_History, "SELECT type, previous_event, encoding, data FROM event WHERE event_id = " + Str(EventID))
    If NextDatabaseRow(#DB_History)
      Type        = GetDatabaseLong(#DB_History, 0)
      PreviousID  = GetDatabaseLong(#DB_History, 1)
      Encoding    = GetDatabaseLong(#DB_History, 2)
      
      Select Type
          
        Case #DATA_Empty
          FinishDatabaseQuery(#DB_History)
          ProcedureReturn @EmptyEventSource
          
        Case #DATA_Same
          FinishDatabaseQuery(#DB_History)
          ProcedureReturn History_LoadEventSource(PreviousID)
          
        Case #DATA_Diff
          DiffSize = DatabaseColumnSize(#DB_History, 3)
          *Diff = AllocateMemory(DiffSize)
          GetDatabaseBlob(#DB_History, 3, *Diff, DiffSize)
          FinishDatabaseQuery(#DB_History)
          
          Size = PeekL(*Diff) ; stores final size
          *Buffer = AllocateMemory(Size + 1) ; need to add a NULL (for scintilla SETTEXT)
          *Previous.EventSource = History_LoadEventSource(PreviousID)
          History_ApplyDiff(*Buffer, *Previous\Buffer, *Diff, DiffSize)
          FreeMemory(*Diff)
          
        Case #DATA_DiffZ
          CompressedSize = DatabaseColumnSize(#DB_History, 3)
          *Compressed = AllocateMemory(CompressedSize)
          GetDatabaseBlob(#DB_History, 3, *Compressed, CompressedSize)
          DiffSize = PeekL(*Compressed)
          *Diff = AllocateMemory(DiffSize)
          uncompress(*Diff, @DiffSize, *Compressed + 4, CompressedSize - 4)
          FreeMemory(*Compressed)
          FinishDatabaseQuery(#DB_History)
          
          Size = PeekL(*Diff) ; stores final size
          *Buffer = AllocateMemory(Size + 1) ; need to add a NULL (for scintilla SETTEXT)
          *Previous.EventSource = History_LoadEventSource(PreviousID)
          History_ApplyDiff(*Buffer, *Previous\Buffer, *Diff, DiffSize)
          FreeMemory(*Diff)
          
        Case #DATA_Full
          Size = DatabaseColumnSize(#DB_History, 3)
          *Buffer = AllocateMemory(Size + 1) ; need to add a NULL (for scintilla SETTEXT)
          GetDatabaseBlob(#DB_History, 3, *Buffer, Size)
          FinishDatabaseQuery(#DB_History)
          
        Case #DATA_FullZ
          CompressedSize = DatabaseColumnSize(#DB_History, 3)
          *Compressed = AllocateMemory(CompressedSize)
          GetDatabaseBlob(#DB_History, 3, *Compressed, CompressedSize)
          Size = PeekL(*Compressed)
          *Buffer = AllocateMemory(Size + 1) ; need to add a NULL (for scintilla SETTEXT)
          uncompress(*Buffer, @Size, *Compressed + 4, CompressedSize - 4)
          FreeMemory(*Compressed)
          FinishDatabaseQuery(#DB_History)
          
        Default
          MessageRequester(#ProductName$, "Unknown data type in session history database." + #NewLine + "This database seems to be from a newer " + #ProductName$ + " version")
          ProcedureReturn @EmptyEventSource
          
      EndSelect
    Else
      FinishDatabaseQuery(#DB_History)
    EndIf
  EndIf
  
  If *Buffer
    
    ; delete an entry from cache if too big
    If ListSize(EventSourceCache()) >= #HISTORY_EVENT_SOURCE_CACHE
      ; least recently used
      LastElement(EventSourceCache())
      Debug "[HISTORY CACHE] EVICT: " + Str(EventSourceCache()\EventID)
      FreeMemory(EventSourceCache()\Buffer)
      DeleteElement(EventSourceCache())
    EndIf
    
    ; insert into cache (as first position)
    Debug "[HISTORY CACHE] MISS: " + Str(EventID)
    FirstElement(EventSourceCache())
    InsertElement(EventSourceCache())
    EventSourceCache()\EventID = EventID
    EventSourceCache()\Encoding = Encoding
    EventSourceCache()\Size = Size
    EventSourceCache()\Buffer = *Buffer
    ProcedureReturn @EventSourceCache()
    
  Else
    ProcedureReturn @EmptyEventSource
  EndIf
EndProcedure

Procedure History_ShowEventSource(EventID)
  
  If CurrentHistorySource = EventID
    ; no need to reload
    ProcedureReturn
  EndIf
  CurrentHistorySource = EventID
  
  ; back up first visible line of previous source
  FirstLine = ScintillaSendMessage(#GADGET_History_Source, #SCI_GETFIRSTVISIBLELINE, 0, 0)
  HistoryFirstLines(CurrentHistoryFile$) = FirstLine
  
  *File.EventSource = History_LoadEventSource(EventID)
  If *File\Buffer
    SetCodeViewer(#GADGET_History_Source, *File\Buffer, *File\Encoding)
    ; no FreeMemory(), as the loaded buffer lives on in the cache!
  Else
    ; source was empty, or an error occurred
    SetCodeViewer(#GADGET_History_Source, @"", 0)
  EndIf
  
  ; get the file name of this source
  ; and set the first visible line again
  If DatabaseQuery(#DB_History, "SELECT filename FROM event WHERE event_id = " + Str(EventID))
    If NextDatabaseRow(#DB_History)
      CurrentHistoryFile$ = GetDatabaseString(#DB_History, 0)
      FirstLine = HistoryFirstLines(CurrentHistoryFile$)
      ScintillaSendMessage(#GADGET_History_Source, #SCI_LINESCROLL, 0, FirstLine)
    EndIf
    FinishDatabaseQuery(#DB_History)
  EndIf
  
EndProcedure

Procedure.s History_FileDisplayName(FileName$)
  
  If Left(FileName$, 11) = "::unsaved::"
    Time = Val(Right(FileName$, Len(FileName$)-43))
    ProcedureReturn Language("History","UnsavedSource") + " (" + DateTimeToString(Time) + ")"
  Else
    ProcedureReturn GetFilePart(FileName$)
  EndIf
  
EndProcedure

Procedure.s History_SessionDisplayName(sid, OsID$, Version$, User$, StartTime, EndTime)
  
  CurrentVersion$ = History_VersionString(DefaultCompiler\VersionString$)
  
  If sid = SessionID
    Session$ = Language("History", "CurrentSession")
  Else
    If EndTime = 0
      If Session_IsRunning(OsID$)
        ; session still running
        Session$ = DateTimeToString(StartTime) + " (" + Language("History", "SessionRunning") + ")"
      Else
        ; crashed
        Session$ = DateTimeToString(StartTime) + " (" + Language("History", "SessionCrashed") + ")"
      EndIf
    Else
      ; finished session
      Duration = (EndTime - StartTime)  / 60
      If Duration = 0
        ; very short session :)
        Session$ = DateTimeToString(StartTime)
      ElseIf Duration < 60
        ; less than one hour
        Session$ = DateTimeToString(StartTime) + " (" + Str(Duration) + " " + Language("History", "DurationMinutes") + ")"
      Else
        ; more than one hour
        Session$ = DateTimeToString(StartTime) + " (" + Str(Duration / 60) + ":" + RSet(Str(Duration % 60), 2, "0") + " " + Language("History", "DurationHours") + ")"
      EndIf
    EndIf
    
    ; only add further info if it differs from the current one
    ;
    If User$ <> CurrentUser$
      Session$ + " - " + User$
    EndIf
    If Version$ <> CurrentVersion$
      Session$ + " - " + Version$
    EndIf
  EndIf
  
  ProcedureReturn Session$
EndProcedure

Procedure History_FillFileList()
  
  ClearGadgetItems(#GADGET_History_FileList)
  
  Index = GetGadgetState(#GADGET_History_FileCombo)
  If Index = -1
    ProcedureReturn
  EndIf
  
  EventID = GetGadgetItemData(#GADGET_History_FileCombo, Index)
  File$ = ""
  If DatabaseQuery(#DB_History, "SELECT filename FROM event WHERE event_id = " + Str(EventID))
    If NextDatabaseRow(#DB_History)
      File$ = GetDatabaseString(#DB_History, 0)
    EndIf
    FinishDatabaseQuery(#DB_History)
  EndIf
  
  If File$ = ""
    ; no file info found ?
    ProcedureReturn
  EndIf
  
  If DatabaseQuery(#DB_History, "SELECT event_id, time, event FROM event WHERE filename = '" + SqlEscape(File$) + "' ORDER BY time ASC")
    
    index = 0
    While NextDatabaseRow(#DB_History)
      EventID      = GetDatabaseLong(#DB_History, 0)
      Time         = GetDatabaseLong(#DB_History, 1)
      Action       = GetDatabaseLong(#DB_History, 2)
      
      ImageID = OptionalImageID(#IMAGE_History_First + Action)
      ; always use DateTime here because this list includes all sessions
      AddGadgetItem(#GADGET_History_FileList, index, DateTimeToString(Time), ImageID)
      SetGadgetItemData(#GADGET_History_FileList, index, EventID)
      index + 1
    Wend
    
    FinishDatabaseQuery(#DB_History)
    
  EndIf
  
  ; scroll all the way down to see the most recent event
  SetGadgetState(#GADGET_History_FileList, CountGadgetItems(#GADGET_History_FileList)-1)
  
EndProcedure

Procedure History_FillFileCombo()
  
  ClearGadgetItems(#GADGET_History_FileCombo)
  
  sql$ = "SELECT MIN(e.event_id), e.filename FROM event e "
  sql$ + "GROUP BY e.filename "
  sql$ + "ORDER BY e.filename ASC"
  
  If DatabaseQuery(#DB_History, sql$)
    
    index = 0
    While NextDatabaseRow(#DB_History)
      EventID   = GetDatabaseLong(#DB_History, 0)
      File$     = GetDatabaseString(#DB_History, 1)
      FileName$ = History_FileDisplayName(File$)
      
      AddGadgetItem(#GADGET_History_FileCombo, index, FileName$, OptionalImageID(#IMAGE_History_File), 0)
      SetGadgetItemData(#GADGET_History_FileCombo, index, EventID)
      index + 1
    Wend
    
    FinishDatabaseQuery(#DB_History)
  EndIf
  
  ; display the first file
  If CountGadgetItems(#GADGET_History_FileCombo) > 0
    SetGadgetState(#GADGET_History_FileCombo, 0)
    History_FillFileList()
  EndIf
  
EndProcedure


Procedure History_FillSessionTree()
  
  ClearGadgetItems(#GADGET_History_SessionTree)
  
  Index = GetGadgetState(#GADGET_History_SessionCombo)
  If Index = -1
    ProcedureReturn
  EndIf
  
  sid = GetGadgetItemData(#GADGET_History_SessionCombo, Index)
  
  ; decide whether to display time and date or only time
  ; if people use a laptop and don't shut down the IDE, a session can last many days
  ; use dateTime if the first and last event are on different days
  UseDates = #False
  If DatabaseQuery(#DB_History, "SELECT MIN(time), MAX(time) FROM event WHERE session_id = " + Str(sid))
    If NextDatabaseRow(#DB_History)
      MinTime = GetDatabaseLong(#DB_History, 0)
      MaxTime = GetDatabaseLong(#DB_History, 1)
      If Day(MinTime) <> Day(MaxTime) Or Month(MinTime) <> Month(MaxTime) Or Year(MinTime) <> Year(MaxTime)
        UseDates = #True
      EndIf
    EndIf
    FinishDatabaseQuery(#DB_History)
  EndIf
  
  If DatabaseQuery(#DB_History, "SELECT event_id, filename, time, event FROM event WHERE session_id = " + Str(sid) + " ORDER BY filename ASC, time ASC")
    
    LastFile$ = ""
    index = 0
    While NextDatabaseRow(#DB_History)
      EventID      = GetDatabaseLong(#DB_History, 0)
      File$        = GetDatabaseString(#DB_History, 1)
      Time         = GetDatabaseLong(#DB_History, 2)
      Action       = GetDatabaseLong(#DB_History, 3)
      
      If File$ <> LastFile$
        FileName$ = History_FileDisplayName(File$)
        
        AddGadgetItem(#GADGET_History_SessionTree, index, FileName$, OptionalImageID(#IMAGE_History_File), 0)
        SetGadgetItemData(#GADGET_History_SessionTree, index, -1)
        index + 1
        
        LastFile$ = File$
      EndIf
      
      ImageID = OptionalImageID(#IMAGE_History_First + Action)
      
      If UseDates
        TimeStr$ = DateTimeToString(Time)
      Else
        TimeStr$ = TimeToString(Time)
      EndIf
      
      AddGadgetItem(#GADGET_History_SessionTree, index, TimeStr$, ImageID, 1)
      SetGadgetItemData(#GADGET_History_SessionTree, index, EventID)
      index + 1
    Wend
    
    FinishDatabaseQuery(#DB_History)
    
    For i = 0 To index-1
      If GetGadgetItemAttribute(#GADGET_History_SessionTree, i,  #PB_Tree_SubLevel) = 0
        SetGadgetItemState(#GADGET_History_SessionTree, i, #PB_Tree_Expanded)
      EndIf
    Next i
    
  EndIf
  
EndProcedure

Procedure History_FillSessionCombo(DisplaySID)
  
  ; display current session if no other one is indicated
  If DisplaySID = -1
    DisplaySID = SessionID
  EndIf
  SelectedSessionIndex = 0
  
  If DatabaseQuery(#DB_History, "SELECT session_id, os_id, version, user, start_time, end_time FROM session ORDER BY start_time DESC")
    index = 0
    While NextDatabaseRow(#DB_History)
      sid       = GetDatabaseLong(#DB_History, 0)
      osid$     = GetDatabaseString(#DB_History, 1)
      Version$  = GetDatabaseString(#DB_History, 2)
      User$     = GetDatabaseString(#DB_History, 3)
      StartTime = GetDatabaseLong(#DB_History, 4)
      EndTime   = GetDatabaseLong(#DB_History, 5)
      
      Session$ = History_SessionDisplayName(sid, osid$, Version$, User$, StartTime, EndTime)
      
      If sid = DisplaySID
        SelectedSessionIndex = index
      EndIf
      
      AddGadgetItem(#GADGET_History_SessionCombo, index, Session$)
      SetGadgetItemData(#GADGET_History_SessionCombo, index, sid)
      index + 1
    Wend
    
    FinishDatabaseQuery(#DB_History)
  EndIf
  
  ; display the current session
  If CountGadgetItems(#GADGET_History_SessionCombo) > 0
    SetGadgetState(#GADGET_History_SessionCombo, SelectedSessionIndex)
    History_FillSessionTree()
  EndIf
  
EndProcedure





Procedure OpenEditHistoryWindow(DisplaySID = -1)
  
  If HistoryActive = 0
    ProcedureReturn
  EndIf
  
  ; Calculate start of the current day for the TimeToString() procedure
  CurrentDate = Date()
  StartOfDay = Date(Year(CurrentDate), Month(CurrentDate), Day(CurrentDate), 0, 0, 0)
  
  ClearMap(HistoryFirstLines())
  
  If IsWindow(#WINDOW_EditHistory) = 0
    
    EditHistoryDialog = OpenDialog(?Dialog_History, WindowID(#WINDOW_Main), @EditHistoryPosition)
    If EditHistoryDialog
      
      ; https://www.purebasic.fr/english/viewtopic.php?t=76506  
      If EditHistoryPosition\IsMaximized      
        EditHistoryDialog\SizeUpdate()
      EndIf  
      
      EnsureWindowOnDesktop(#WINDOW_EditHistory)
      
      InitCodeViewer(#GADGET_History_Source, EnableLineNumbers)
      HideWindow(#WINDOW_EditHistory, 0)
      
      SetGadgetState(#GADGET_History_Splitter, EditHistorySplitter)
      
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_EditHistory)
  EndIf
  
  ; make sure all events are written to the db
  History_FlushEvents()
  
  ; refresh display
  History_FillSessionCombo(DisplaySID)
  History_FillFileCombo()
  
  CurrentHistoryFile$ = ""
  CurrentHistorySource = -1
  
  EditHistoryDialog\SizeUpdate()
  
EndProcedure

Procedure UpdateEditHistoryWindow()
  
  EditHistoryDialog\LanguageUpdate()
  EditHistoryDialog\GuiUpdate()
  UpdateCodeViewer(#GADGET_History_Source)
  
EndProcedure

Procedure EditHistoryWindowEvent(EventID)
  
  Select EventID
      
    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case #GADGET_History_Splitter
          CompilerIf #CompileWindows
            ; just update the column width. the rest is automatic
            SendMessage_(GadgetID(#GADGET_History_FileList), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
          CompilerElse
            ; the size of the user interface must be adjusted accordingly,
            ; only if the position of the splitter is changed.
            If GetGadgetState(#GADGET_History_Splitter) <> GetGadgetData(#GADGET_History_Splitter)
              SetGadgetData(#GADGET_History_Splitter, GetGadgetState(#GADGET_History_Splitter))
              EditHistoryDialog\SizeUpdate()
            EndIf
          CompilerEndIf
          
        Case #GADGET_History_SessionCombo
          History_FillSessionTree()
          
        Case #GADGET_History_SessionTree
          Index = GetGadgetState(#GADGET_History_SessionTree)
          If Index <> -1
            EventID = GetGadgetItemData(#GADGET_History_SessionTree, Index)
            If EventID <> -1
              History_ShowEventSource(EventID)
            EndIf
          EndIf
          
        Case #GADGET_History_FileCombo
          History_FillFileList()
          
        Case #GADGET_History_FileList
          Index = GetGadgetState(#GADGET_History_FileList)
          If Index <> -1
            EventID = GetGadgetItemData(#GADGET_History_FileList, Index)
            If EventID <> -1
              History_ShowEventSource(EventID)
            EndIf
          EndIf
          
          
      EndSelect
      
    Case #PB_Event_SizeWindow
      ; force size splitter gadget
      SetGadgetData(#GADGET_History_Splitter, -1)
      
    Case #PB_Event_CloseWindow
      If MemorizeWindow
        EditHistorySplitter = GetGadgetState(#GADGET_History_Splitter)
        EditHistoryDialog\Close(@EditHistoryPosition)
      Else
        EditHistoryDialog\Close()
      EndIf
      
      EditHistoryDialog = 0 ; Important on OS X to put back the pointer to null after closing, as it can be called in the resize callback (https://www.purebasic.fr/english/viewtopic.php?f=24&t=59703&start=60)
      
      ; clear the display cache
      ForEach EventSourceCache()
        FreeMemory(EventSourceCache()\Buffer)
      Next EventSourceCache()
      ClearList(EventSourceCache())
      
  EndSelect
  
EndProcedure