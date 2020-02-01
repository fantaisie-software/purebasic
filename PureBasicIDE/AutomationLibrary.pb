;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

;
; Implements the client side of the IDE automation
; This is compiled into a dll so tools can use it
;

XIncludeFile "CompilerFlags.pb"
XIncludeFile "Macro.pb"
XIncludeFile "FileSystem.pb"
XIncludeFile "RemoteProcedureCall.pb"

Prototype EventCallback(*Call)

Global LastError$ = "" ; initialize, so the pointer is not NULL
Global EventCallback.EventCallback = 0

CompilerIf #CompileWindows = 0
  ;
  ;- Unix specific communication stuff
  ; The Unix domain socket stuff is implemented in C for simplicity
  ;
  #SOCKET_ERROR = -1
  #INVALID_SOCKET = -1
  
  CompilerIf #PB_Compiler_Debugger
    #DEBUG = 1
    #BUILD_DIRECTORY = "/Users/freak/PureBuild/v4.60_X86/ide/"
  CompilerEndIf
  
  ImportC #BUILD_DIRECTORY + "AutomationDomainSocket.o"
    DomainSocket_Create(path.p-ascii)
    DomainSocket_Accept(socket.l)
    DomainSocket_Connect(path.p-ascii)
    DomainSocket_Close(socket.l)
    DomainSocket_Send(socket.l, *call)
    DomainSocket_Receive(socket.l)
  EndImport
  
  Global AutomationSocket = #SOCKET_ERROR
  
  Procedure SendRequest(*Call.RPC_Call)
    Success = 0
    
    CompilerIf #DEBUG
      RPC_DebugCall(*Call, "Sending request")
    CompilerEndIf
    
    If AutomationSocket <> #SOCKET_ERROR And RPC_Encode(*Call)
      If DomainSocket_Send(AutomationSocket, *Call\Encoded)
        ; wait for response
        Timeout.q = ElapsedMilliseconds()
        Repeat
          *Buffer = DomainSocket_Receive(AutomationSocket)
          If *Buffer = 0
            Delay(10)
          EndIf
        Until *Buffer <> 0 Or ElapsedMilliseconds()-Timeout > 5000
        
        If *Buffer = -1
          ; connection lost
          AutomationSocket = #SOCKET_ERROR
          RPC_InitResponse(*Call, 1, #True)
          RPC_SetString(*Call, 0, "Connection lost")
          
        ElseIf *Buffer
          Size = PeekL(*Buffer)
          If RPC_Decode(*Call, *Buffer, Size, #False) ; do not copy. the buffer now belongs to the call
            Success = 1
          Else
            FreeMemory(*Buffer) ; in case of error
            RPC_InitResponse(*Call, 1, #True)
            RPC_SetString(*Call, 0, "Out of resources")
          EndIf
          
        Else
          RPC_InitResponse(*Call, 1, #True)
          RPC_SetString(*Call, 0, "Communication timeout")
        EndIf
      Else
        RPC_InitResponse(*Call, 1, #True)
        RPC_SetString(*Call, 0, "Connection lost")
      EndIf
    Else
      RPC_InitResponse(*Call, 1, #True)
      RPC_SetString(*Call, 0, "Out of resources")
    EndIf
    
    CompilerIf #DEBUG
      RPC_DebugCall(*Call, "Received response")
    CompilerEndIf
    
    If *Call\ErrorFlag
      LastError$ = RPC_GetString(*Call, 0)
      Success = 0
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
  Procedure WaitEvents(Timeout)
  EndProcedure
  
  Procedure Connect(WindowID, ProcessID, Executable$)
    Protected Call.RPC_Call
    Success = 0
    
    If Executable$
      ; make path absolute
      Executable$ = ResolveRelativePath(GetCurrentDirectory(), Executable$)
    EndIf
    
    ; enumerate all domain sockets from the IDE naming scheme and query them
    ; to see if they match our criteria
    ;
    If ExamineDirectory(0, "/tmp/", ".pb-automation-*")
      While NextDirectoryEntry(0)
        If DirectoryEntryType(0) = #PB_DirectoryEntry_File
          Path$ = "/tmp/" + DirectoryEntryName(0)
          AutomationSocket = DomainSocket_Connect(Path$)
          If AutomationSocket <> #SOCKET_ERROR
            ; send the identify command to this IDE
            RPC_InitCall(@Call.RPC_Call, "Identify", 0)
            If SendRequest(@Call)
              If RPC_GetLong(@Call, 0) = AsciiConst('A','U','T','1') ; check protocol version first
                
                If WindowID
                  If RPC_GetQuad(@Call, 3) = WindowID
                    Success = 1
                  EndIf
                  
                ElseIf ProcessID
                  If RPC_GetLong(@Call, 2) = ProcessID
                    Success = 1
                  EndIf
                  
                ElseIf Executable$
                  If IsEqualFile(Executable$, RPC_GetString(@Call, 1))
                    Success = 1
                  EndIf
                  
                Else
                  ; connect to any, so we accept this connection
                  Success = 1
                  
                EndIf
                
              EndIf
            EndIf
            
            RPC_ClearCall(@Call)
            
            If Success
              Break
            Else
              ; not the right IDE
              DomainSocket_Close(AutomationSocket)
              AutomationSocket = #SOCKET_ERROR
            EndIf
          EndIf
        EndIf
      Wend
      
      FinishDirectory(0)
    EndIf
    
    If Success = 0
      LastError$ = "Connection could not be established."
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
  Procedure Disconnect()
    DomainSocket_Close(AutomationSocket)
    AutomationSocket = #SOCKET_ERROR
  EndProcedure
  
CompilerElse
  ;
  ;- Windows specific communication stuff (using WM_COPYDATA)
  ;
  Global CommunicationWindow
  Global CommunicationMessage
  Global TargetWindow
  Global *CurrentCall.RPC_Call, CallComplete
  
  Procedure CommunicationCallback(Window, Message, wParam, lParam)
    Protected EventCall.RPC_Call
    Protected *StoredCall.RPC_Call
    
    If Window = CommunicationWindow And Message = #WM_COPYDATA And wParam = TargetWindow And *CurrentCall
      *copy.COPYDATASTRUCT = lParam
      
      If *copy And *copy\dwData = AsciiConst('A','U','T','1') And *copy\cbData > 20 And *copy\lpData
        
        ; check the actual size with the encoded data
        If PeekL(*copy\lpData) <= *copy\cbData
          
          ; check if this is an event call or a response
          ;
          If PeekL(*copy\lpData+4) = 0
            ; event call
            
            If EventCallback And RPC_Decode(@EventCall, *copy\lpData, *copy\cbData)
              ; store the *CurrentCall pointer, so we can have nested calls from the event handler
              *StoredCall = *CurrentCall
              
              EventCallback(@EventCall)
              
              ; restore the wait for the response
              *CurrentCall = *StoredCall
              CallComplete = #False
            EndIf
            
          Else
            ; response to call
            ; check for a match in the responseID
            If PeekL(*copy\lpData+8) = *CurrentCall\ResponseID
              
              ; match, try to decode
              If RPC_Decode(*CurrentCall, *copy\lpData, *copy\cbData) = 0
                RPC_InitResponse(*CurrentCall, 1, #True)
                RPC_SetString(*CurrentCall, 0, "Invalid response")
              EndIf
              
              CallComplete = #True
            EndIf
            
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn DefWindowProc_(Window, Message, wParam, lParam)
  EndProcedure
  
  Procedure SendRequest(*Call.RPC_Call)
    Success = 0
    
    CompilerIf #DEBUG
      RPC_DebugCall(*Call, "Sending request")
    CompilerEndIf
    
    If CommunicationWindow And TargetWindow And RPC_Encode(*Call)
      ; prepare for receiving the response, as it can happen even while
      ; we are in the SendMessage_() below (makes sense, as the IDE sends the response right then)
      CallComplete = #False
      *CurrentCall = *Call
      
      ; Send the data
      ;
      request.COPYDATASTRUCT\dwData = AsciiConst('A','U','T','1')
      request\cbData = *Call\EncodedSize
      request\lpData = *Call\Encoded
      SendMessage_(TargetWindow, #WM_COPYDATA, CommunicationWindow, @request)
      
      ; The SendMessage_() does not return until the IDE has processed the call, and any responses
      ; are already sent. So we need no message loop here to wait for a response
      
      If CallComplete
        ; *Call is already decoded in the callback, so all is fine
        Success = 1
      Else
        RPC_InitResponse(*Call, 1, #True)
        RPC_SetString(*Call, 0, "Communication timeout")
      EndIf
    Else
      RPC_InitResponse(*Call, 1, #True)
      RPC_SetString(*Call, 0, "Out of resources")
    EndIf
    
    CompilerIf #DEBUG
      RPC_DebugCall(*Call, "Received response")
    CompilerEndIf
    
    If *Call\ErrorFlag
      LastError$ = RPC_GetString(*Call, 0)
      Success = 0
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
  Procedure WaitEvents(Timeout)
    StartTime.q = ElapsedMilliseconds()
    
    ; This message loop will not interfere with PB WaitWindowEvent(), as events are now also
    ; stored by the PB event lib on Windows (so we do not miss any events here)
    ; also we only get events for our own communication window anyway
    ;
    If CommunicationWindow
      If Timeout <= 0
        If PeekMessage_(@msg.MSG, CommunicationWindow, 0, 0, #PM_REMOVE)
          TranslateMessage_(@msg)
          DispatchMessage_(@msg)
        EndIf
        
      Else
        While ElapsedMilliseconds()-StartTime < Timeout
          If PeekMessage_(@msg.MSG, CommunicationWindow, 0, 0, #PM_REMOVE)
            TranslateMessage_(@msg)
            DispatchMessage_(@msg)
          Else
            Delay(50)
          EndIf
        Wend
        
      EndIf
    EndIf
  EndProcedure
  
  Procedure Connect(WindowID, ProcessID, Executable$)
    Success = 0
    TargetWindow = 0
    
    If CommunicationWindow
      ;
      ; Discover all IDE instances that support Automation
      ;
      If WindowID
        ; post to this window only
        PostMessage_(WindowID, CommunicationMessage, AsciiConst('A','U','T','O'), CommunicationWindow)
      Else
        PostMessage_(#HWND_BROADCAST, CommunicationMessage, AsciiConst('A','U','T','O'), CommunicationWindow)
      EndIf
      
      If Executable$
        ; make path absolute
        Executable$ = ResolveRelativePath(GetCurrentDirectory(), Executable$)
      EndIf
      
      Timeout.q = ElapsedMilliseconds()
      Repeat
        If PeekMessage_(@msg.MSG, CommunicationWindow, 0, 0, #PM_REMOVE)
          TranslateMessage_(@msg)
          DispatchMessage_(@msg)
          
          ; The connection communication is done (at least the response) with PostMessage,
          ; so we do not need code in the callback and can process it here
          ;
          If msg\hwnd = CommunicationWindow And msg\message = CommunicationMessage
            CompilerIf #DEBUG
              Debug "[RunOnceMessage received] Code = '" + PeekS(@msg\wParam, 4, #PB_Ascii) + "', Window = " + Hex(msg\lParam)
            CompilerEndIf
            
            If msg\wParam = AsciiConst('A','U','T','1')
              ; response from an IDE that supports this
              
              If WindowID
                ; if a WindowID was given, we are done at this point
                If WindowID = msg\lParam
                  TargetWindow = msg\lParam
                  Success = 1
                EndIf
                
              ElseIf ProcessID
                ; find out the ProcessID of this window
                If GetWindowThreadProcessId_(msg\lParam, @dwProcessID.l) And dwProcessID = ProcessID
                  TargetWindow = msg\lParam
                  Success = 1
                EndIf
                
              ElseIf Executable$
                ; need to ask the IDE if the executable matches
                ; response is then an 'AOK' message
                copy.COPYDATASTRUCT\cbData = StringByteLength(Executable$, #PB_UTF8) + 1
                copy\lpData = AllocateMemory(copy\cbData)
                If copy\lpData
                  PokeS(copy\lpData, Executable$, -1, #PB_UTF8)
                  copy\dwData = AsciiConst('A','E','X','E')
                  SendMessage_(msg\lParam, #WM_COPYDATA, CommunicationWindow, @copy)
                  FreeMemory(copy\lpData)
                EndIf
                
              Else
                ; ConnectAny, accept the first response
                TargetWindow = msg\lParam
                Success = 1
                
              EndIf
              
            ElseIf msg\wParam = AsciiConst(0, 'A','O','K')
              ; response from an IDE with the correct Executable$
              TargetWindow = msg\lParam
              Success = 1
              
            EndIf
            
          EndIf
          
        Else
          Delay(50)
        EndIf
      Until Success Or ElapsedMilliseconds()-Timeout > 5000
    EndIf
    
    If Success = 0
      LastError$ = "Connection could not be established."
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
  Procedure Disconnect()
    ; nothing to do here currently on Windows
    TargetWindow = 0
  EndProcedure
  
  ProcedureDLL AttachProcess(Instance)
    ;
    ; Create our communication window and class
    ;
    Class.WNDCLASS
    Class\hbrBackground = #COLOR_BTNFACE+1
    Class\hInstance     = Instance
    Class\lpszClassName = @"PB_AutomationClient"
    Class\lpfnWndProc   = @CommunicationCallback()
    RegisterClass_(@Class)
    
    CommunicationMessage = RegisterWindowMessage_(#ProductName$+"_RunOnce") ; use the IDE runonce message for this too
    
    If OSVersion() >= #PB_OS_Windows_2000
      ; create a message only window
      ParentWindow = -3 ; HWND_MESSAGE
    Else
      ParentWindow = #Null
    EndIf
    
    CommunicationWindow = CreateWindowEx_(0, @"PB_AutomationClient", @"", 0, 0, 0, 0, 0, ParentWindow, 0, Instance, #Null)
    
  EndProcedure
  
  ProcedureDLL DetachProcess(Instance)
    ;
    ; Clean up
    ;
    CloseWindow_(CommunicationWindow)
    UnregisterClass_(@"PB_AutomationClient", Instance)
  EndProcedure
  
CompilerEndIf

;- Connecting/Disconnecting
;
ProcedureDLL AUTO_ConnectToWindow(WindowID)
  ProcedureReturn Connect(WindowID, 0, "")
EndProcedure

ProcedureDLL AUTO_ConnectToProcess(ProcessID)
  ProcedureReturn Connect(0, ProcessID, "")
EndProcedure

ProcedureDLL AUTO_ConnectToProgram(Executable$)
  ProcedureReturn Connect(0, 0, Executable$)
EndProcedure

ProcedureDLL AUTO_ConnectToAny()
  ProcedureReturn Connect(0, 0, "")
EndProcedure

ProcedureDLL AUTO_ConnectFromTool()
  MainWindow$ = GetEnvironmentVariable("PB_TOOL_MainWindow")
  If MainWindow$
    ProcedureReturn Connect(Val(MainWindow$), 0, "")
  Else
    LastError$ = "IDE Tool information not found"
    ProcedureReturn 0
  EndIf
EndProcedure

ProcedureDLL AUTO_Disconnect()
  Disconnect()
EndProcedure


;- Error handling
;
ProcedureDLL AUTO_ClearError()
  LastError$ = ""
EndProcedure

ProcedureDLL AUTO_LastErrorPtr()
  ProcedureReturn @LastError$
EndProcedure


;- Event handling
;
ProcedureDLL AUTO_RPC_SetCallback(Callback.EventCallback)
  EventCallback = Callback
EndProcedure

ProcedureDLL AUTO_RPC_ProcessEvents(Timeout)
  WaitEvents(Timeout)
EndProcedure

;- RPC wrapper
;
; We add a wrapper around this, because of the DLL boundary (need to handle strings right),
; and also so the caller process does not know the contents of the *Call structure
; for future compatibility
;
ProcedureDLL AUTO_RPC_NewCall(Function$, NbParameters)
  *Call.RPC_Call = AllocateMemory(SizeOf(RPC_Call))
  If *Call
    InitializeStructure(*Call, RPC_Call)
    RPC_InitCall(*Call, Function$, NbParameters)
  EndIf
  ProcedureReturn *Call
EndProcedure

ProcedureDLL AUTO_RPC_FreeCall(*Call.RPC_Call)
  If *Call
    RPC_ClearCall(*Call)
    FreeMemory(*Call)
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_CallResponse(*Call.RPC_Call, NbParameters)
  If *Call
    RPC_InitResponse(*Call, NbParameters, #False)
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_CallError(*Call.RPC_Call, Message$)
  If *Call
    RPC_InitResponse(*Call, 1, #True)
    RPC_SetString(*Call, 0, Message$)
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_SendCall(*Call.RPC_Call)
  If *Call
    ProcedureReturn SendRequest(*Call)
  Else
    LastError$ = "Invalid call."
    ProcedureReturn 0
  EndIf
EndProcedure

;- RPC Get/Set functions
;
ProcedureDLL AUTO_RPC_SetLong(*Call.RPC_Call, Index, Value.l)
  If *Call
    RPC_SetLong(*Call, Index, Value)
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_SetQuad(*Call.RPC_Call, Index, Value.q)
  If *Call
    RPC_SetQuad(*Call, Index, Value)
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_SetString(*Call.RPC_Call, Index, Value$)
  If *Call
    RPC_SetString(*Call, Index, Value$)
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_SetMemory(*Call.RPC_Call, Index, *Buffer, Size)
  If *Call
    RPC_SetMemory(*Call, Index, *Buffer, Size)
  EndIf
EndProcedure

ProcedureDLL.l AUTO_RPC_GetLong(*Call.RPC_Call, Index)
  If *Call
    ProcedureReturn RPC_GetLong(*Call, Index)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

ProcedureDLL.q AUTO_RPC_GetQuad(*Call.RPC_Call, Index)
  If *Call
    ProcedureReturn RPC_GetQuad(*Call, Index)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_GetStringPtr(*Call.RPC_Call, Index)
  If *Call And Index < *Call\NbParameters And *Call\Parameter(Index)\Type = #PB_String
    ; return only the pointer here, so the caller can PeekS it
    ProcedureReturn @*Call\Parameter(Index)\String$
  Else
    ProcedureReturn @""
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_GetMemorySize(*Call.RPC_Call, Index)
  If *Call
    ProcedureReturn RPC_GetMemorySize(*Call, Index)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_GetMemory(*Call.RPC_Call, Index)
  If *Call
    ProcedureReturn RPC_GetMemory(*Call, Index)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_CountParameters(*Call.RPC_Call)
  If *Call
    ProcedureReturn *Call\NbParameters
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

ProcedureDLL AUTO_RPC_GetFunctionPtr(*Call.RPC_Call)
  If *Call
    ProcedureReturn @*Call\Function$
  Else
    ProcedureReturn @""
  EndIf
EndProcedure

