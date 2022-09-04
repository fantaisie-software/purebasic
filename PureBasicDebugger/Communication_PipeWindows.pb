; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
;
; Default communication way for Windows
;
; - named pipes (as we cannot inherit handles with RunProgram())
; - one global thread only
; - receiving only if data available on the pipe
; - all mutex protected to be save
;

CompilerIf #CompileWindows
  
  
  Structure WinPipe_Communication
    *Vtbl.CommunicationVtbl
    
    ; named pipes are used, so we can use RunProgram() to manage the exe
    ;
    ; Note: a named pipe supports duplex mode (read/write on one handle),
    ;   but we use two separate pipes to allow read/write in different threads
    ;   without a mutex protection.
    ;
    InPipeName$
    OutPipeName$
    
    ; open pipe handles
    InPipeHandle.i
    OutPipeHandle.i
    
    
    ; Win9x does not support CreateNamedPipe(), so use anonymous pipes there
    ;
    IsNamedPipe.l
    DebuggerInPipeHandle.i  ; handles to the debugger end of the anonymous
    DebuggerOutPipeHandle.i
    
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
  Global NewList WinPipe_Data.WinPipe_Communication()
  Global WinPipe_Mutex.i = CreateMutex()
  Global WinPipe_Thread  = 0
  
  CompilerIf #NOTHREAD = 0
    ; debugger must be disabled in thread mode
    ; keep it on in nothread mode for better debugging!
    DisableDebugger
  CompilerEndIf
  
  Procedure WinPipe_FatalError(*This.WinPipe_Communication, *Command.CommandInfo, FatalError)
    *This\IsFatalError = #True
    
    CompilerIf #NOTHREAD = 0
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
      
    CompilerElse
      *Command\Command   = #COMMAND_FatalError
      *Command\Value1    = FatalError
      *Command\Value2    = 0
      *Command\TimeStamp = Date()
      
    CompilerEndIf
    
  EndProcedure
  
  
  Procedure WinPipe_ReadCommand(*This.WinPipe_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
    
    *pCommandData\i = 0
    BytesAvailable  = 0
    PeekNamedPipe_(*This\InPipeHandle, #Null, 0, #Null, @BytesAvailable, #Null)
    
    ; at least a full command struct must be available
    If BytesAvailable >= SizeOf(CommandInfo)
      
      ; read the structure
      Received = 0
      Repeat
        Result = ReadFile_(*This\InPipeHandle, *Command+Received, SizeOf(CommandInfo)-Received, @BytesRead, #Null)
        Received + BytesRead
      Until Result = 0 Or Received = SizeOf(CommandInfo)
      
      If Received = SizeOf(CommandInfo)
        
        If *Command\DataSize > 0
          
          *CommandData = AllocateMemory(*Command\DataSize)
          If *CommandData
            ;
            ; This read may block, as we do not test if all is available, but this is ok.
            ; We cannot wait for all to be available, as it may be more than the pipe buffer can store!
            ;
            Received = 0
            Repeat
              Result = ReadFile_(*This\InPipeHandle, *CommandData+Received, *Command\DataSize-Received, @BytesRead, #Null)
              Received + BytesRead
            Until Result = 0 Or Received = *Command\DataSize
            
            If Received = *Command\DataSize
              *pCommandData\i = *CommandData
            Else
              FreeMemory(*CommandData)
              WinPipe_FatalError(*This, *Command, #ERROR_Pipe)
            EndIf
            
          Else
            WinPipe_FatalError(*This, *Command, #ERROR_Memory)
          EndIf
          
          ;
          ; Nothing else to do when no data for this command
          ;
        EndIf
        
      Else
        WinPipe_FatalError(*This, *Command, #ERROR_Pipe)
      EndIf
      
      CompilerIf #PRINT_DEBUGGER_COMMANDS
        PrintN("THREAD::RECEIVE->"+Str(*Command\Command))
      CompilerEndIf
      
      *This\CommandReceived = 1
      
      If *Command\Command = #COMMAND_End
        *This\EndReceived = 1
      EndIf
      
      ; There is a command now in any case (its an error command if something goes wrong)
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  CompilerIf #NOTHREAD = 0
    
    Procedure WinPipe_ReceiveThread(Dummy)
      
      ; This is a single thread for all debuggers, so it never quits which
      ; makes it a lot easier/saver as we never need to worry if the thread still runs or not
      ;
      Protected Command.CommandInfo
      Protected *CommandData
      
      Repeat
        LockMutex(WinPipe_Mutex)  ; full protection needed!
        
        TotalCount = 0
        ForEach WinPipe_Data()
          
          ; receive as long as there is data, and as long as there is space
          ;
          While WinPipe_Data()\EndReceived = 0 And WinPipe_Data()\IsFatalError = 0
            
            ; Do not receive anything if the stack is full
            If WinPipe_Data()\StackCount >= #MAX_COMMANDSTACK
              ; This check can be done without a mutex lock, as only this thread
              ; can increase the stack, and a decrease during the check has no concequence
              Break
            EndIf
            
            
            If WinPipe_ReadCommand(@WinPipe_Data(), @Command, @*CommandData)
              If WinPipe_Data()\IsFatalError = 0
                
                ; now lock the stack mutex and add data to the stack
                ; we know there is a free spot, as we checked above
                ; (And the main thread only decreases the stack)
                LockMutex(WinPipe_Data()\StackMutex)
                
                ; add to stack
                CopyMemory(@Command, @WinPipe_Data()\Stack[WinPipe_Data()\StackCount]\Command, SizeOf(CommandInfo))
                WinPipe_Data()\Stack[WinPipe_Data()\StackCount]\CommandData = *CommandData
                WinPipe_Data()\StackCount + 1
                
                UnlockMutex(WinPipe_Data()\StackMutex)
                
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
          
        Next WinPipe_Data()
        
        UnlockMutex(WinPipe_Mutex)
        
        Delay(10) ; time for the main thread to access the data
      ForEver
      
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #NOTHREAD = 0
    EnableDebugger
  CompilerEndIf
  
  
  Procedure.s WinPipe_GetInfo(*This.WinPipe_Communication)
    If *This\IsNamedPipe
      ProcedureReturn "NamedPipes;" + *This\InPipeName$ + ";" + *This\OutPipeName$
    Else
      ProcedureReturn "Pipes;" + Str(GetCurrentProcessId_()) + ";" + Str(*This\DebuggerOutPipeHandle) + ";" + Str(*This\DebuggerInPipeHandle)
    EndIf
  EndProcedure
  
  
  Procedure WinPipe_Connect(*This.WinPipe_Communication)
    ; all work done in the Create function (for this side at least)
    ProcedureReturn #True
  EndProcedure
  
  Procedure WinPipe_Disconnect(*This.WinPipe_Communication)
    ; all done in Close()
  EndProcedure
  
  
  Procedure WinPipe_Send(*This.WinPipe_Communication, *Command.CommandInfo, *CommandData)
    ; no mutex needed, as we send through a separate pipe handle
    ; No error checking: Its a blocking pipe, so it should go through in all normal circumstances
    WriteFile_(*This\OutPipeHandle, *Command, SizeOf(CommandInfo), @byteswritten, 0)
    
    If *CommandData And *Command\DataSize > 0
      WriteFile_(*This\OutPipeHandle, *CommandData, *Command\DataSize, @byteswritten, 0)
    EndIf
  EndProcedure
  
  
  Procedure WinPipe_Receive(*This.WinPipe_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
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
      
      If *This\EndReceived = 0 And *This\IsFatalError = 0
        Result = WinPipe_ReadCommand(*This, *Command, *pCommandData)
      EndIf
      
    CompilerEndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure WinPipe_CheckErrors(*This.WinPipe_Communication, *Command.CommandInfo, ProcessObject)
    
    If *This\EndReceived
      ; COMMAND_End was received. Fire no errors anymore
      ProcedureReturn #False
      
    ElseIf *This\EndTimeout <> 0 And (ElapsedMilliseconds() - *This\EndTimeout) > DebuggerTimeout/5
      *Command\Command   = #COMMAND_FatalError
      *Command\Value1    = #ERROR_ExeQuit
      *Command\Value2    = 0
      *Command\TimeStamp = Date()
      *This\IsFatalError = #True
      ProcedureReturn #True
      
    ElseIf *This\EndTimeout = 0 And WaitProgram(ProcessObject, 0) ; if true, exe has quit
      
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
  
  
  
  Procedure WinPipe_Close(*This.WinPipe_Communication)
    LockMutex(WinPipe_Mutex)
    If *This\InPipeHandle
      CloseHandle_(*This\InPipeHandle)
    EndIf
    
    If *This\OutPipeHandle
      CloseHandle_(*This\OutPipeHandle)
    EndIf
    
    If *This\IsNamedPipe = 0
      ;
      ; Close the other side of the anonymous pipes.
      ; (The debugger actually duplicates these, so we can close
      ;  them here without interfering with what the debugger does)
      ;
      If *This\DebuggerInPipeHandle
        CloseHandle_(*This\DebuggerInPipeHandle)
      EndIf
      If *This\DebuggerOutPipeHandle
        CloseHandle_(*This\DebuggerOutPipeHandle)
      EndIf
    EndIf
    
    ; clear stack, if any data left
    For i = 0 To *This\StackCount-1
      If *This\Stack[i]\CommandData
        FreeMemory(*This\Stack[i]\CommandData)
      EndIf
    Next i
    
    ; this is ok if the global mutex is locked
    FreeMutex(*This\StackMutex)
    
    ChangeCurrentElement(WinPipe_Data(), *This)
    DeleteElement(WinPipe_Data())
    UnlockMutex(WinPipe_Mutex)
  EndProcedure
  
  
  
  Procedure CreatePipeCommunication()
    *Result = 0
    
    ; there is only 1 thread for everything
    CompilerIf #NOTHREAD = 0
      If WinPipe_Thread = 0
        WinPipe_Thread = CreateThread(@WinPipe_ReceiveThread(), 0)
      EndIf
      
      If WinPipe_Thread
      CompilerEndIf
      
      ; Cache the Win9x check to not execute it on every run
      ;
      CompilerIf #CompileX86
        Static IsWin9x = -1
        If IsWin9x = -1
          If OSVersion() = #PB_OS_Windows_95 Or OSVersion() = #PB_OS_Windows_98 Or OSVersion() = #PB_OS_Windows_ME
            IsWin9x = 1
          Else
            IsWin9x = 0
          EndIf
        EndIf
      CompilerElse
        IsWin9x = 0
      CompilerEndIf
      
      ; Win9x does not support CreateNamedPipe() so we use anonymous pipes there
      ; Since RunProgram() does not inherit any handles, the child must use
      ; DuplicateHandle() to get the pipe handles to its process space
      ;
      ; Keep the Names pipes on the newer OS though, as i do not know if the
      ; required PROCESS_DUP_HANDLE is granted to the child process on Vista and such
      ;
      If IsWin9x
        
        If CreatePipe_(@Pipe1Read, @Pipe1Write, #Null, 2048) And CreatePipe_(@Pipe2Read, @Pipe2Write, #Null, 2048)
          
          LockMutex(WinPipe_Mutex)
          
          AddElement(WinPipe_Data())
          WinPipe_Data()\Vtbl            = ?WinPipe_Vtbl
          WinPipe_Data()\InPipeHandle    = Pipe1Read
          WinPipe_Data()\OutPipeHandle   = Pipe2Write
          WinPipe_Data()\DebuggerInPipeHandle  = Pipe2Read
          WinPipe_Data()\DebuggerOutPipeHandle = Pipe1Write
          WinPipe_Data()\IsNamedPipe     = #False
          WinPipe_Data()\StackMutex      = CreateMutex()
          WinPipe_Data()\CommandReceived = 0
          WinPipe_Data()\CommandTimeout  = ElapsedMilliseconds()
          WinPipe_Data()\StackCount      = 0
          *Result = @WinPipe_Data()
          
          UnlockMutex(WinPipe_Mutex)
          
        EndIf
        
      Else
        
        Rand         = Random($7FFFFFFF)
        InPipeName$  = "\\.\pipe\PureBasic_DebuggerPipeA_" + Hex(Rand)
        OutPipeName$ = "\\.\pipe\PureBasic_DebuggerPipeB_" + Hex(Rand)
        
        InPipeHandle = CreateNamedPipe_(@InPipeName$, #PIPE_ACCESS_INBOUND, 0, 1, 0, 2048, 1000, #Null)
        If InPipeHandle <> #INVALID_HANDLE_VALUE
          
          OutPipeHandle = CreateNamedPipe_(@OutPipeName$, #PIPE_ACCESS_OUTBOUND, 0, 1, 2048, 0, 1000, #Null)
          If OutPipeHandle <> #INVALID_HANDLE_VALUE
            
            LockMutex(WinPipe_Mutex)
            
            AddElement(WinPipe_Data())
            WinPipe_Data()\Vtbl            = ?WinPipe_Vtbl
            WinPipe_Data()\InPipeName$     = InPipeName$
            WinPipe_Data()\OutPipeName$    = OutPipeName$
            WinPipe_Data()\InPipeHandle    = InPipeHandle
            WinPipe_Data()\OutPipeHandle   = OutPipeHandle
            WinPipe_Data()\IsNamedPipe     = #True
            WinPipe_Data()\StackMutex      = CreateMutex()
            WinPipe_Data()\CommandReceived = 0
            WinPipe_Data()\CommandTimeout  = ElapsedMilliseconds()
            WinPipe_Data()\StackCount      = 0
            *Result = @WinPipe_Data()
            
            UnlockMutex(WinPipe_Mutex)
            
          Else
            CloseHandle_(InPipeHandle) ; cleanup first open handle
          EndIf
        EndIf
        
      EndIf
      
      CompilerIf #NOTHREAD = 0
      EndIf
    CompilerEndIf
    
    ProcedureReturn *Result
  EndProcedure
  
  
  
  DataSection
    
    WinPipe_Vtbl:
    Data.i @WinPipe_GetInfo()
    Data.i @WinPipe_Connect()
    Data.i @WinPipe_Disconnect()
    Data.i @WinPipe_Send()
    Data.i @WinPipe_Receive()
    Data.i @WinPipe_CheckErrors()
    Data.i @WinPipe_Close()
    
  EndDataSection
  
CompilerEndIf

