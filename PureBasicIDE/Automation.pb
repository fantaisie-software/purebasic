;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

;
; This file exposes IDE functionality to external programs.
; The functionality will be accessible through a dll compiled from AutomationLibrary.pb
; The actual communication protocol is private
;
; This way to make the IDE extensible has some advantages:
; - no plugin code is running in the IDE process (so no plugin can easily crash the IDE)
; - we control what can be controlled from a plugin, so we can be sure the stuff
;   does not leave the IDE in an invalid state
; - the dll and private communication makes using this simple, and we can change things as we want
;

; This file implements the IDE side of the communication


; The Unix domain socket stuff is implemented in C for simplicity
;
CompilerIf #CompileWindows = 0
  #SOCKET_ERROR = -1
  #INVALID_SOCKET = -1
  
  ImportC #BUILD_DIRECTORY + "AutomationDomainSocket.o"
    DomainSocket_Create(path.p-ascii)
    DomainSocket_Accept(socket.l)
    DomainSocket_Connect(path.p-ascii)
    DomainSocket_Close(socket.l)
    DomainSocket_Send(socket.l, *call)
    DomainSocket_Receive(socket.l)
  EndImport
  
  Global AutomationSocket = #SOCKET_ERROR
  Global AutomationSocketFile$
  Global NewList AutomationClient()
CompilerEndIf

Structure AutomationEvent
  List Client.i()
EndStructure

Global NewMap AutomationEvent.AutomationEvent()

; Test if an event client is connection
;
Procedure IsAutomationEventClient(Event$)
  If FindMapElement(AutomationEvent(), Event$) And ListSize(AutomationEvent()\Client()) > 0
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; Fill *Call with an error response
;
Procedure AutomationError(*Call.RPC_Call, Message$)
  RPC_InitResponse(*Call, 1, #True)
  RPC_SetString(*Call, 0, Message$)
EndProcedure

; Fill *Call with an empty response message (no error)
;
Procedure AutomationVoid(*Call.RPC_Call)
  RPC_InitResponse(*Call, 0, #False)
EndProcedure

; Received an (already decoded) RPC_Call and must fill it with response data
;
Procedure AutomationRequest(*Call.RPC_Call, ClientID)
  
  CompilerIf #DEBUG
    RPC_DebugCall(*Call, "Automation Request")
  CompilerEndIf
  
  Select *Call\Function$ ; name is case sensitive
      
      ; On Linux/OSX, the client just connects to all available IDE instances
      ; and uses the following command to identify the correct one
      ;
      CompilerIf #CompileWindows = 0
        
      Case "Identify"
        RPC_InitResponse(*Call, 4, #False)
        RPC_SetLong(*Call, 0, AsciiConst('A', 'U', 'T', '1')) ; identify "protocol" version
        RPC_SetString(*Call, 1, ProgramFilename())
        RPC_SetLong(*Call, 2, getpid_())
        RPC_SetQuad(*Call, 3, WindowID(#WINDOW_Main)) ; for x64 compatibility
        
      CompilerEndIf
      
    Case "RegisterEvent"
      Event$ = RPC_GetString(*Call, 0)
      AddElement(AutomationEvent(Event$)\Client())
      AutomationEvent(Event$)\Client() = ClientID
      AutomationVoid(*Call)
      
    Case "UnregisterEvent"
      Event$ = RPC_GetString(*Call, 0)
      If FindMapElement(AutomationEvent(), Event$)
        ForEach AutomationEvent()\Client()
          If AutomationEvent()\Client() = ClientID
            DeleteElement(AutomationEvent()\Client())
            Break
          EndIf
        Next AutomationEvent()\Client()
      EndIf
      AutomationVoid(*Call)
      ;
    Case "MenuCommand"
      Command$ = UCase(RPC_GetString(*Call, 0))
      MenuItem = -1
      Restore ShortcutItems ;
      For i = 0 To #MENU_LastShortcutItem
        Read.s MenuTitle$
        Read.s MenuItem$
        Read.l DefaultShortcut
        If Command$ = UCase(MenuItem$)
          MenuItem = i
          Break
        EndIf
      Next i
      
      CompilerIf #CompileMac
        ; handle the 3 special cases
        If MenuItem = #MENU_AboutNotUsed
          MenuItem = #MENU_About
        ElseIf MenuItem = #MENU_PreferenceNotUsed
          MenuItem = #MENU_Preference
        ElseIf MenuItem = #MENU_ExitNotUsed
          MenuItem = #MENU_Exit
        EndIf
      CompilerEndIf
      
      If MenuItem = -1
        AutomationError(*Call, "Menu Command not found")
      Else
        MainMenuEvent(MenuItem)
        AutomationVoid(*Call)
      EndIf
      
      
      
      
      
      ; this is for simple debugging only
      ;     Case "SayHello"
      ;       Name$ = RPC_GetString(*Call, 0)
      ;       RPC_InitResponse(*Call, 1)
      ;       RPC_SetString(*Call, 0, "Hello '"+Name$+"' !")
      
    Default
      AutomationError(*Call, "Invalid request.")
      
  EndSelect
  
  CompilerIf #DEBUG
    RPC_DebugCall(*Call, "Automation Response")
  CompilerEndIf
  
EndProcedure

; Currently nothing to do here on Windows
Procedure InitAutomation()
  ;   CompilerIf #CompileWindows = 0
  ;     ; Unix domain sockets operate on a pseudofile, and since we can have multiple
  ;     ; IDE instances running, try multiple times with different names
  ;     ;
  ;     For i = 0 To 20
  ;       AutomationSocketFile$ = "/tmp/.pb-automation-" + Str(Random(10000))
  ;       AutomationSocket = DomainSocket_Create(AutomationSocketFile$)
  ;       If AutomationSocket <> #SOCKET_ERROR
  ;         ; success
  ;         Break
  ;       EndIf
  ;     Next i
  ;
  ;   CompilerEndIf
EndProcedure

Procedure ShutdownAutomation()
  ;   CompilerIf #CompileWindows = 0
  ;     If AutomationSocket <> #SOCKET_ERROR
  ;       ForEach AutomationClient()
  ;         DomainSocket_Close(AutomationClient())
  ;       Next AutomationClient()
  ;       ClearList(AutomationClient())
  ;
  ;       DomainSocket_Close(AutomationSocket)
  ;       DeleteFile(AutomationSocketFile$)
  ;       AutomationSocket = #SOCKET_ERROR
  ;     EndIf
  ;   CompilerEndIf
EndProcedure



CompilerIf #CompileWindows = 0
  
  ; Communication via unix domain sockets
  ;
  Procedure ProcessAutomationRequest()
    Protected Call.RPC_Call
    Protected Processed = 0
    
    ; not used yet
    ProcedureReturn 0
    
    If AutomationSocket <> #SOCKET_ERROR
      
      ; Check for new connections
      ;
      Repeat
        socket = DomainSocket_Accept(AutomationSocket)
        If socket <> #SOCKET_ERROR
          AddElement(AutomationClient())
          AutomationClient() = socket
          Debug "[Automation] Client connected: " + Str(socket)
        EndIf
      Until socket = #SOCKET_ERROR
      
      ; Check for data on existing connections
      ForEach AutomationClient()
        Repeat
          *Buffer = DomainSocket_Receive(AutomationClient())
          If *Buffer = -1
            ; special value indicating that the connection was closed
            Debug "[Automation] Client disconnect: " + Str(AutomationClient())
            DomainSocket_Close(AutomationClient())
            DeleteElement(AutomationClient())
            Break
            
          ElseIf *Buffer
            ; a command was received
            Processed + 1
            
            Size = PeekL(*Buffer)
            If RPC_Decode(@Call, *Buffer, Size, #False) ; do not copy, Call takes ownership of the buffer
                                                        ; process the decoded request
              AutomationRequest(@Call, AutomationClient())
              
              ; encode the response
              If RPC_Encode(@Call)
                ; send result
                DomainSocket_Send(AutomationClient(), Call\Encoded)
              EndIf
              
              RPC_ClearCall(@Call)
            Else
              ; need to free the buffer
              FreeMemory(*Buffer)
            EndIf
            
          EndIf
        Until *Buffer = 0 Or Processed > 50
        
        If Processed > 50 ; do not handle too many requests at once
          Break
        EndIf
      Next AutomationClient()
      
    EndIf
    
  EndProcedure
  
CompilerElse
  
  Global *CurrentAutomationCall.RPC_Call
  Global AutomationCallComplete
  
  
  ; The communication is done via WM_COPYDATA messages on Windows, which
  ; is quite simple on the IDE side
  ;
  Procedure ProcessAutomationRequest(WindowID, *copy.COPYDATASTRUCT)
    ;     Protected Call.RPC_Call
    ;     Protected *WaitingCall.RPC_Call
    ;
    ;     If *copy\dwData = 'AUT1' And RPC_Decode(@Call, *copy\lpData, *copy\cbData)
    ;
    ;       If Call\IsResponse
    ;         ; response to an event
    ;         ;
    ;         CopyStructure(*CurrentAutomationCall, @Call, RPC_Call)
    ;         AutomationCallComplete = #True
    ;
    ;       Else
    ;         ; request from client
    ;         *WaitingCall = *CurrentAutomationCall ; store this locally, to allow nested events/calls
    ;
    ;         ; process the decoded request
    ;         AutomationRequest(@Call, WindowID)
    ;
    ;         ; encode the response
    ;         If RPC_Encode(@Call)
    ;           ; send result
    ;           response.COPYDATASTRUCT\dwData = 'AUT1'
    ;           response\cbData = Call\EncodedSize
    ;           response\lpData = Call\Encoded
    ;
    ;           ; Use a timeout to he protected from hung client programs
    ;           ;
    ;           If SendMessageTimeout_(WindowID, #WM_COPYDATA, WindowID(#WINDOW_Main), @response, #SMTO_ABORTIFHUNG|#SMTO_NORMAL, 5000, @MessageResult) = 0
    ;             MessageRequester(#ProductName$,Language("Misc","AutomationTimeout"), #FLAG_Error)
    ;           EndIf
    ;         EndIf
    ;         RPC_ClearCall(@Call)
    ;
    ;         *CurrentAutomationCall = *WaitingCall
    ;         AutomationCallComplete = #False
    ;
    ;       EndIf
    ;
    ;     EndIf
  EndProcedure
  
  
  Procedure SendAutomationEvent(*Call.RPC_Call, ChainClients = #False)
    Success = 0
    
    If FindMapElement(AutomationEvent(), *Call\Function$)
      CompilerIf #DEBUG
        RPC_DebugCall(*Call, "Automation Event")
      CompilerEndIf
      
      ForEach AutomationEvent()\Client()
        
        
        If RPC_Encode(*Call)
          request.COPYDATASTRUCT\dwData = AsciiConst('A', 'U', 'T', '1')
          request\cbData = *Call\EncodedSize
          request\lpData = *Call\Encoded
          
          *CurrentAutomationCall = *Call
          AutomationCallComplete = #False
          
          If SendMessageTimeout_(AutomationEvent()\Client(), #WM_COPYDATA, WindowID(#WINDOW_Main), @request, #SMTO_ABORTIFHUNG|#SMTO_NORMAL, 5000, @MessageResult) = 0
            MessageRequester(#ProductName$,Language("Misc","AutomationTimeout"), #FLAG_Error)
            Success = #False
            Break
            
          ElseIf  *Call\ErrorFlag <> 0
            Success = #False
            Break
            
          Else
            Success = #True
            
            ; If ChainClients is set, the response from the first client is sent to further clients
            ; (so Call & Response must have the same signature
            If ChainClients = #False
              Break
            EndIf
            
          EndIf
        EndIf
        
      Next AutomationEvent()\Client()
      
      CompilerIf #DEBUG
        RPC_DebugCall(*Call, "Automation Event (Response)")
      CompilerEndIf
    EndIf
    
    ProcedureReturn Success
  EndProcedure
  
CompilerEndIf


;- Automation events
;

Procedure AutomationEvent_AutoComplete(List Elements.s())
  ;   Protected Call.RPC_Call
  ;   If IsAutomationEventClient("AutoComplete")
  ;     RPC_InitCall(@Call, "AutoComplete", ListSize(Elements()))
  ;     ForEach Elements()
  ;       RPC_SetString(@Call, ListIndex(Elements()), Elements())
  ;     Next Elements()
  ;
  ;     If SendAutomationEvent(@Call, #True)
  ;       ClearList(Elements())
  ;       For i = 0 To Call\NbParameters-1
  ;         AddElement(Elements())
  ;         Elements() = RPC_GetString(@Call, i)
  ;       Next i
  ;     EndIf
  ;     RPC_ClearCall(@Call)
  ;   EndIf
EndProcedure

