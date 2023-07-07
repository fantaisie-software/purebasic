; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
;
; Default communication way for Linux/OSX
;
; - both pipes (anonymous) and FIFO files are available
; - one global thread only, like on windows
; - pipes in non-blocking mode on the receive end to only receive when data available
; - all mutex protected to be save
;

CompilerIf #CompileWindows = 0
  
  ; For the pipe_() command, it expects a 2 element array
  ;
  Structure PipeStructure
    piperead.l
    pipewrite.l
  EndStructure
  
  #SIGKILL = 9
  #SIGUSR1 = 10
  #SIGTERM = 15 ; used for the KillProgram option
  
  ; stream buffer modes, for setvbuf_()
  ;
  #_IOFBF = 0  ;/* Fully buffered.  */
  #_IOLBF = 1  ;/* Line buffered.  */
  #_IONBF = 2  ;/* No buffering.  */
  
  ; fcntl_() command values
  ;
  #F_DUPFD = 0	;/* Duplicate file descriptor.  */
  #F_GETFD = 1  ;/* Get file descriptor flags.  */
  #F_SETFD = 2  ;/* Set file descriptor flags.  */
  #F_GETFL = 3  ;/* Get file status flags.  */
  #F_SETFL = 4  ;/* Set file status flags.  */
  
  ; errno is a macro on Linux and OSX
  ; We only need the EAGAIN error code here
  ;
  CompilerIf #CompileLinux
    ImportC ""
      __errno_location()
    EndImport
    
    Macro errno()
      PeekL(__errno_location())
    EndMacro
    
    #EAGAIN = 11
    
    ; #F_GETFL / #F_SETFL flag value for nonblocking mode
    #O_NONBLOCK	= 2048
    
  CompilerElseIf #CompileMac
    ImportC ""
      __error()
    EndImport
    
    Macro errno()
      PeekL(__error())
    EndMacro
    
    #EAGAIN = 35
    
    ; #F_GETFL / #F_SETFL flag value for nonblocking mode
    #O_NONBLOCK	= 4
    
    CompilerIf #CompileArm64
      
      ; Non-blocking read doesn't work on OS X arm64 for an unknown reason. We use another way to check if it's possible to read from the pipe
      ;
      Import ""
        poll(a.i, b.i, c.i)
      EndImport
    
      Structure pollfd
        fd.l
        events.w
        revents.w
      EndStructure
    
      #POLLIN = 1
    
      Procedure IsPipeData(fd.l)
        Protected fds.pollfd
        
        fds\fd = fd
        fds\events = #POLLIN
        
        If poll(fds, 1, 0) = 1 And (fds\revents & #POLLIN)
          ProcedureReturn #True
        EndIf 
        
        ProcedureReturn #False
      EndProcedure
    CompilerEndIf
    
  CompilerElse
    CompilerError "Plateform not supported"
  CompilerEndIf
  
  ; required file permission bits for fifos
  ;
  #S_IRUSR = 4<<6 ; 0400 (user permissions)
  #S_IWUSR = 2<<6 ; 0200
  #S_IXUSR = 1<<6 ; 0100
  
  #S_IRGRP = (#S_IRUSR >> 3); (group permissions)
  #S_IWGRP = (#S_IWUSR >> 3)
  #S_IXGRP = (#S_IXUSR >> 3)
  
  #S_IROTH = (#S_IRGRP >> 3); (other permissions)
  #S_IWOTH = (#S_IWGRP >> 3)
  #S_IXOTH = (#S_IXGRP >> 3)
  
  
  
  Structure UnixPipe_Communication
    *Vtbl.CommunicationVtbl
    
    UseFIFO.l   ; fifo or pipe_() mode
    Connected.l ; should we try to read or not ?
    
    ; FIFO filenames
    InFifoName$
    OutFifoName$
    
    ; Pipe file descriptors (non-fifo mode)
    InPipe.PipeStructure
    OutPipe.PipeStructure
    
    ; Open pipe handles (type: FILE *)
    InPipeHandle.i
    OutPipeHandle.i
    
    IsFatalError.l
    CommandReceived.l   ; was there any command received yet?
    CommandTimeout.l    ; time of exe creation for timeout test
    EndReceived.l       ; was #COMMAND_End received yet ?
    EndTimeout.l        ; time of exe quit, timeout to be able to receive COMMAND_End before firing an error
    
    ; The command stack is protected by a mutex separate from the overall
    ; "receive" mutex, so commands can be read from the stack while the thread
    ; is actually receiving data.
    StackMutex.i
    
    ; waiting commands
    StackCount.l
    Stack.CommandStackStruct[#MAX_COMMANDSTACK]
  EndStructure
  
  ; All WinPipe Objects are handled in a LinkedList,
  ; protected by a mutex for ALL access to make it save with the thread
  ;
  Global NewList UnixPipe_Data.UnixPipe_Communication()
  Global UnixPipe_Mutex.i = CreateMutex()
  Global UnixPipe_Thread  = 0
  
  CompilerIf #NOTHREAD = 0
    ; only needed in thread mode (as the threadsafe switch is off in the IDE/debugger
    DisableDebugger
  CompilerEndIf
  
  Procedure UnixPipe_FatalError(*This.UnixPipe_Communication, *Command.CommandInfo, FatalError)
    *This\IsFatalError = #True
    
    CompilerIf #PRINT_DEBUGGER_COMMANDS
      PrintN("THREAD::FATAL_ERROR->"+Str(FatalError))
    CompilerEndIf
    
    CompilerIf #NOTHREAD = 0
      LockMutex(*This\StackMutex)
      
      ; clear stack, so the fatal error is the only one
      For i = 0 To *This\StackCount-1
        If *This\Stack[i]\CommandData
          FreeMemory(*This\Stack[i]\CommandData)
        EndIf
      Next i
      
      *This\Stack[0]\Command\Command   = #COMMAND_FatalError
      *This\Stack[0]\Command\Value1    = FatalError
      *This\Stack[0]\Command\Value2    = 0
      *This\Stack[0]\Command\TimeStamp = Date()
      *This\Stack[0]\CommandData       = 0
      *This\StackCount = 1
      
      UnlockMutex(*This\StackMutex)
      
    CompilerElse
      *Command\Command   = #COMMAND_FatalError
      *Command\Value1    = FatalError
      *Command\Value2    = 0
      *Command\TimeStamp = Date()
      
    CompilerEndIf
    
  EndProcedure
  
  
  Procedure UnixPipe_ReadCommand(*This.UnixPipe_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
    
    ;
    ; NOTE: Since we do non-blocking reads, we could actually receive only half of a
    ;   command structure at a time. If this happens, we simply wait for the rest
    ;   to be received right here. Since commands are sent in one write op on the
    ;   other side, it means if we receive some part, the rest will come through right
    ;   away as well.
    ;
    ; Use 1 as size_t in all reads, as fread_() discards the data if not all of size_t
    ; is read at once! (i tested it also for non-blocking mode)
    ;
    *pCommandData\i = 0
    
    CompilerIf #CompileMac And #CompileArm64
      If IsPipeData(fileno_(*This\InPipeHandle)) = #False
        ProcedureReturn #False
      EndIf
    CompilerEndIf
    
    ; Try to read (maybe a part) of the CommandInfo structure
    ;
    Result = fread_(*Command, 1, SizeOf(CommandInfo), *This\InPipeHandle)
    
    If Result < SizeOf(CommandInfo) And errno() <> #EAGAIN
      ; pipe error
      UnixPipe_FatalError(*This, *Command, #ERROR_Pipe)
      ProcedureReturn #True
      
    ElseIf Result = 0
      ; EAGAIN - nothing to receive, no error
      ProcedureReturn #False
      
    EndIf
    
    ; Ok, we received at least a part of the struct. Get the rest.
    ;
    Received = Result
    While Received < SizeOf(CommandInfo)
      Result = fread_(*Command+Received, 1, SizeOf(CommandInfo)-Received, *This\InPipeHandle)
      
      If Result < SizeOf(CommandInfo)-Received And errno() <> #EAGAIN
        UnixPipe_FatalError(*This, *Command, #ERROR_Pipe)
        ProcedureReturn #True
      EndIf
      
      Received + Result
      
      If Received < SizeOf(CommandInfo)
        Delay(1) ; wait for more data
      EndIf
    Wend
    
    ; If there is data, we also wait here until all is received.
    ; This may block a bit, but data is sent right after the command, so it should not be long.
    ;
    If *Command\DataSize > 0
      *pCommandData\i = AllocateMemory(*Command\DataSize)
      
      If *pCommandData\i = 0
        UnixPipe_FatalError(*This, *Command, #ERROR_Memory)
        ProcedureReturn #True
      EndIf
      
      Received = 0
      Repeat
        Result = fread_(*pCommandData\i+Received, 1, *Command\DataSize-Received, *This\InPipeHandle)
        
        If Result < *Command\DataSize-Received And errno() <> #EAGAIN
          FreeMemory(*pCommandData\i)
          UnixPipe_FatalError(*This, *Command, #ERROR_Pipe)
          ProcedureReturn #True
        EndIf
        
        Received + Result
        
        If Received < *Command\DataSize
          Delay(1) ; wait for more data
        EndIf
      Until Received = *Command\DataSize
    EndIf
    
    CompilerIf #PRINT_DEBUGGER_COMMANDS
      PrintN("THREAD::RECEIVE->"+Str(*Command\Command))
    CompilerEndIf
    
    *This\CommandReceived = 1
    
    If *Command\Command = #COMMAND_End
      *This\EndReceived = 1
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  CompilerIf #NOTHREAD = 0
    
    ; ProcedureDLL for OSX !! (weird errors else!)
    ;
    ProcedureDLL UnixPipe_ReceiveThread(Dummy)
      
      ; This is a single thread for all debuggers, so it never quits which
      ; makes it a lot easier/saver as we never need to worry if the thread still runs or not
      ;
      ; We receive into a local buffer, so the stack can still be read by the main thread
      ; in the meantime (without needing the "global mutex" locked)
      ;
      Protected Command.CommandInfo
      Protected *CommandData
      
      Repeat
        LockMutex(UnixPipe_Mutex)  ; full protection needed!
        
        TotalCount = 0
        ForEach UnixPipe_Data()
          
          ; receive as long as there is data, and as long as there is space
          ;
          While UnixPipe_Data()\Connected And UnixPipe_Data()\EndReceived = 0 And UnixPipe_Data()\IsFatalError = 0
            
            ; Do not receive anything if the stack is full
            If UnixPipe_Data()\StackCount >= #MAX_COMMANDSTACK
              ; This check can be done without a mutex lock, as only this thread
              ; can increase the stack, and a decrease during the check has no concequence
              Break
            EndIf
            
            If UnixPipe_ReadCommand(@UnixPipe_Data(), @Command, @*CommandData)
              If UnixPipe_Data()\IsFatalError = 0
                
                ; now lock the stack mutex and add data to the stack
                ; we know there is a free spot, as we checked above
                ; (And the main thread only decreases the stack)
                LockMutex(UnixPipe_Data()\StackMutex)
                
                ; add to stack
                CopyMemory(@Command, @UnixPipe_Data()\Stack[UnixPipe_Data()\StackCount]\Command, SizeOf(CommandInfo))
                UnixPipe_Data()\Stack[UnixPipe_Data()\StackCount]\CommandData = *CommandData
                UnixPipe_Data()\StackCount + 1
                
                UnlockMutex(UnixPipe_Data()\StackMutex)
                
              EndIf
              
              TotalCount + 1
              
              ; break (and unlock mutex) after a lot of commands are read so the main thread can read it
              If TotalCount > 50
                Break 2
              EndIf
            Else
              Break ; nothing to read, so on to the next debugger
            EndIf
          Wend
          
        Next UnixPipe_Data()
        
        UnlockMutex(UnixPipe_Mutex)
        
        Delay(10) ; time for the main thread to access the data
      ForEver
      
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #NOTHREAD = 0
    EnableDebugger
  CompilerEndIf
  
  
  Procedure.s UnixPipe_GetInfo(*This.UnixPipe_Communication)
    If *This\UseFIFO
      ProcedureReturn "FifoFiles;"+*This\InFifoName$+";"+*This\OutFifoName$
    Else
      ProcedureReturn "Pipes;"+Str(*This\InPipe\pipewrite)+";"+Str(*This\OutPipe\piperead)
    EndIf
  EndProcedure
  
  
  Procedure UnixPipe_Connect(*This.UnixPipe_Communication)
    
    If *This\UseFIFO
      ;
      ; ToAscii() uses a static buffer, so it cannot be used for both string args!
      ; Note: The order is important, first In, then Out
      ;
      PokeS(@ascii_wb.l, "wb", -1, #PB_Ascii) ; use a long for this short string
      PokeS(@ascii_rb.l, "rb", -1, #PB_Ascii) ; use a long for this short string
      *This\InPipeHandle = fopen_(*This\InFifoName$, @ascii_rb)
      *This\OutPipeHandle = fopen_(*This\OutFifoName$, @ascii_wb)
      
    Else
      
      ; Note: The order is important, first In, then Out
      *This\InPipeHandle  = fdopen_(*This\InPipe\piperead, ToAscii("rb"))
      *This\OutPipeHandle = fdopen_(*This\OutPipe\pipewrite, ToAscii("wb"))
      
    EndIf
    
    If *This\InPipeHandle And *This\OutPipeHandle
      ; Set the read pipe to non-blocking mode
      ; Without this, nothing will work, as the thread will block with
      ; the mutex locked and we have a deadlock.
      ;
      FD = fileno_(*This\InPipeHandle)
      
      Flags = fcntl_(FD, #F_GETFL, 0) ; read old flags (if possible)
      If Flags = -1                   ; failed
        Flags = 0
      EndIf
      
      If fcntl_(FD, #F_SETFL, Flags | #O_NONBLOCK) <> 0
        ; error, we cannot work with this pipe then
        fclose_(*This\InPipeHandle)
        fclose_(*This\OutPipeHandle)
        ProcedureReturn #False
      EndIf
      
      ; Set both pipes to non-buffered mode
      ;
      setvbuf_(*This\InPipeHandle, 0, #_IONBF, 0)
      setvbuf_(*This\OutPipeHandle, 0, #_IONBF, 0)
      
      
      ; Start the command received timeout now
      ;
      *This\CommandReceived = 0
      *This\CommandTimeout  = ElapsedMilliseconds()
      
      CompilerIf #PRINT_DEBUGGER_COMMANDS
        PrintN("COMMUNICATION::CONNECT OK")
      CompilerEndIf
      
      *This\Connected = 1 ; the thread can start reading
      ProcedureReturn #True
    EndIf
    
    CompilerIf #PRINT_DEBUGGER_COMMANDS
      PrintN("COMMUNICATION::CONNECT FAIL")
    CompilerEndIf
    
    ProcedureReturn #False
  EndProcedure
  
  
  Procedure UnixPipe_Disconnect(*This.UnixPipe_Communication)
    
    CompilerIf #PRINT_DEBUGGER_COMMANDS
      PrintN("COMMUNICATION::DISCONNECT")
    CompilerEndIf
    
    LockMutex(UnixPipe_Mutex)
    ; Note: The order is important, first In, then Out
    If *This\InPipeHandle
      fclose_(*This\InPipeHandle)
    EndIf
    
    If *This\OutPipeHandle
      fclose_(*This\OutPipeHandle)
    EndIf
    
    ; Tell the thread to no longer try any reads
    *This\Connected = 0
    UnlockMutex(UnixPipe_Mutex)
  EndProcedure
  
  
  
  Procedure UnixPipe_Send(*This.UnixPipe_Communication, *Command.CommandInfo, *CommandData)
    result = fwrite_(*Command, SizeOf(CommandInfo), 1, *This\OutPipeHandle)
    
    If *CommandData And *Command\DataSize > 0 And result = 1
      fwrite_(*CommandData, *Command\DataSize, 1, *This\OutPipeHandle)
    EndIf
    
    fflush_(*This\OutPipeHandle)
  EndProcedure
  
  
  Procedure UnixPipe_Receive(*This.UnixPipe_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
    Result = 0
    
    CompilerIf #NOTHREAD = 0
      
      LockMutex(*This\StackMutex)
      
      If *This\StackCount > 0
        CopyMemory(@*This\Stack[0]\command, *Command, SizeOf(CommandInfo))
        *pCommandData\i = *This\Stack[0]\commanddata
        
        ; remove this command from the stack
        *This\StackCount - 1
        If *This\StackCount > 0
          MoveMemory(@*This\Stack[1], @*This\Stack[0], SizeOf(CommandStackStruct) * *This\StackCount)
        EndIf
        
        Result = 1
      EndIf
      
      UnlockMutex(*This\StackMutex)
      
      
    CompilerElse
      
      If *This\Connected And *This\EndReceived = 0 And *This\IsFatalError = 0
        Result = UnixPipe_ReadCommand(*This, *Command, *pCommandData)
      EndIf
      
    CompilerEndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure UnixPipe_CheckErrors(*This.UnixPipe_Communication, *Command.CommandInfo, ProcessObject)
    
    If *This\EndReceived
      ; COMMAND_End was received. Fire no errors anymore
      ProcedureReturn #False
      
      ; If FIFO communication is used, it means the exe is not an immediate child
      ; of the IDE. In this case, WaitProgram() may be incorrect as well, so disable
      ; the program end check and timeout
      ;
    ElseIf *This\UseFIFO = 0 And *This\EndTimeout <> 0 And (ElapsedMilliseconds() - *This\EndTimeout) > DebuggerTimeout/5
      CompilerIf #PRINT_DEBUGGER_COMMANDS
        PrintN("COMMUNICATION::EXE QUIT")
      CompilerEndIf
      *Command\Command   = #COMMAND_FatalError
      *Command\Value1    = #ERROR_ExeQuit
      *Command\Value2    = 0
      *Command\TimeStamp = Date()
      *This\IsFatalError = #True
      ProcedureReturn #True
      
    ElseIf *This\UseFIFO = 0 And *This\EndTimeout = 0 And WaitProgram(ProcessObject, 0) ; if true, exe has quit
      
      ; Check if there is still a command in the buffer!
      ; Do not fire the error if there is still data
      ;
      LockMutex(*This\StackMutex)
      If *This\StackCount = 0
        *This\EndTimeout = ElapsedMilliseconds() ; register the time the exe quit
      EndIf
      UnlockMutex(*This\StackMutex)
      ProcedureReturn #False ; no error yet, allow some time to receive COMMAND_End first
      
    ElseIf *This\CommandReceived = 0 And ElapsedMilliseconds() - *This\CommandTimeout > DebuggerTimeout
      CompilerIf #PRINT_DEBUGGER_COMMANDS
        PrintN("COMMUNICATION::TIMEOUT")
      CompilerEndIf
      *Command\Command   = #COMMAND_FatalError
      *Command\Value1    = #ERROR_Timeout
      *Command\Value2    = 0
      *Command\TimeStamp = Date()
      *This\IsFatalError = #True
      ProcedureReturn #True
      
    Else
      ProcedureReturn #False
      
    EndIf
    
  EndProcedure
  
  
  
  Procedure UnixPipe_Close(*This.UnixPipe_Communication)
    
    CompilerIf #PRINT_DEBUGGER_COMMANDS
      PrintN("COMMUNICATION::CLOSE")
    CompilerEndIf
    
    LockMutex(UnixPipe_Mutex)
    ; The streams are already closed in Disconnect(), so delete the FIFOs now
    If *This\UseFIFO
      DeleteFile(*This\InFifoName$)
      DeleteFile(*This\OutFifoName$)
    Else
      ; Close the pipe ends that were never used in this process
      close_(*This\InPipe\pipewrite)
      close_(*This\OutPipe\piperead)
    EndIf
    
    ; clear stack, if any data left
    For i = 0 To *This\StackCount-1
      If *This\Stack[i]\CommandData
        FreeMemory(*This\Stack[i]\CommandData)
      EndIf
    Next i
    
    ; when we hold the global mutex, this is save
    FreeMutex(*This\StackMutex)
    
    ChangeCurrentElement(UnixPipe_Data(), *This)
    DeleteElement(UnixPipe_Data())
    UnlockMutex(UnixPipe_Mutex)
  EndProcedure
  
  
  Procedure CreatePipeCommunication()
    *Result = 0
    
    ; there is only 1 thread for everything
    CompilerIf #NOTHREAD = 0
      If UnixPipe_Thread = 0
        UnixPipe_Thread = CreateThread(@UnixPipe_ReceiveThread(), 0)
      EndIf
      
      If UnixPipe_Thread
      CompilerEndIf
      
      LockMutex(UnixPipe_Mutex)
      
      AddElement(UnixPipe_Data())
      UnixPipe_Data()\Vtbl       = ?UnixPipe_Vtbl
      UnixPipe_Data()\UseFIFO    = #False
      UnixPipe_Data()\StackMutex = CreateMutex()
      
      If pipe_(@UnixPipe_Data()\InPipe) = 0 And pipe_(@UnixPipe_Data()\OutPipe) = 0
        ; all done
        *Result = @UnixPipe_Data()
      Else
        ; error
        DeleteElement(UnixPipe_Data())
      EndIf
      
      UnlockMutex(UnixPipe_Mutex)
      
      CompilerIf #NOTHREAD = 0
      EndIf
    CompilerEndIf
    
    ProcedureReturn *Result
  EndProcedure
  
  
  Procedure CreateFifoCommunication()
    *Result = 0
    
    ; there is only 1 thread for everything
    CompilerIf #NOTHREAD = 0
      If UnixPipe_Thread = 0
        UnixPipe_Thread = CreateThread(@UnixPipe_ReceiveThread(), 0)
      EndIf
      
      If UnixPipe_Thread
      CompilerEndIf
      
      ; create the fifo's
      ;
      For i = 0 To 50
        FifoIn$ = "/tmp/.pb-FIFO-"+Str(Random($7FFFFFFF))
        If mkfifo_(ToAscii(FifoIn$), #S_IRUSR|#S_IWUSR|#S_IRGRP|#S_IWGRP) = 0
          Break
        Else
          FifoIn$ = ""
        EndIf
      Next i
      
      If FifoIn$ = ""
        ProcedureReturn 0
      EndIf
      
      For i = 0 To 50
        FifoOut$ = "/tmp/.pb-FIFO-"+Str(Random($7FFFFFFF))
        If mkfifo_(ToAscii(FifoOut$), #S_IRUSR|#S_IWUSR|#S_IRGRP|#S_IWGRP) = 0
          Break
        Else
          FifoOut$ = ""
        EndIf
      Next i
      
      If FifoOut$ = ""
        ProcedureReturn 0
      EndIf
      
      LockMutex(UnixPipe_Mutex)
      
      AddElement(UnixPipe_Data())
      UnixPipe_Data()\Vtbl         = ?UnixPipe_Vtbl
      UnixPipe_Data()\UseFIFO      = #True
      UnixPipe_Data()\StackMutex   = CreateMutex()
      UnixPipe_Data()\InFifoName$  = FifoIn$
      UnixPipe_Data()\OutFifoName$ = FifoOut$
      *Result = @UnixPipe_Data()
      
      UnlockMutex(UnixPipe_Mutex)
      
      CompilerIf #NOTHREAD = 0
      EndIf
    CompilerEndIf
    
    ProcedureReturn *Result
  EndProcedure
  
  
  
  DataSection
    
    UnixPipe_Vtbl:
    Data.i @UnixPipe_GetInfo()
    Data.i @UnixPipe_Connect()
    Data.i @UnixPipe_Disconnect()
    Data.i @UnixPipe_Send()
    Data.i @UnixPipe_Receive()
    Data.i @UnixPipe_CheckErrors()
    Data.i @UnixPipe_Close()
    
  EndDataSection
  
CompilerEndIf
