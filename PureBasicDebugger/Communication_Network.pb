;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

;
;
; Network communication plugin
;

UseMD5Fingerprint()

;- ----> Import from NetworkSupport.c
;
CompilerIf #CompileWindows
  Import "wsock32.lib"
  EndImport
  
  #NetworkSupport_Library = "NetworkSupport.obj"
CompilerElse
  
  #SOCKET_ERROR = -1
  #INVALID_SOCKET = -1
  
  #NetworkSupport_Library = "NetworkSupport.o"
CompilerEndIf

ImportC #BUILD_DIRECTORY + #NetworkSupport_Library
  
  ; // Wrappers For the simple stuff For consistency
  ; //
  Network_Initialize()
  Network_CreateSocket()
  Network_CloseSocket(Socket)
  
  ; // Only initiates the connect.
  ; // Use Network_ConnectSocketCheck() To wait For a connection/failure.
  ; // Returns 0 on failure
  ; //
  Network_ConnectSocketStart(Socket, Hostname.p-ascii, Port)
  
  ; // Check the status of a connect()
  ; //
  ; // Returns:
  ; //   0 = still pending
  ; //   1 = connected
  ; //   2 = connection failed
  ; //
  Network_ConnectSocketCheck(Socket)
  
  ; // Put the socket in listen mode (1 connection max)
  ; // If Interface is empty, bind to all interfaces
  ; //
  Network_Listen(Socket, InterfaceName.p-ascii, Port)
  
  ; // Check If an incoming connection is made on a listening socket, does Not block
  ; // returns new Socket Or SOCKET_ERROR (= no incoming connection)
  ; //
  Network_CheckAccept(Socket)
  
  ; // Check if data is ready For reading
  ; //
  ; // Returns:
  ; //   0 = no Data
  ; //   1 = Data available
  ; //   2 = disconnect
  Network_CheckData(Socket)
  
  ; // Ensure the Data is Read fully
  ; // Returns true If ok, false If network disconnect
  ; //
  Network_ReceiveData(Socket, *Buffer, Size)
  
  ; // Blocking send of Data
  ; // Returns true If ok, false If network disconnect
  ; //
  Network_SendData(Socket, *Buffer, Size)
  
  ; // Blocking send of string Data (ascii)
  ; // Returns true If ok, false If network disconnect
  ; //
  Network_SendString(Socket, String.p-ascii)
  
EndImport

ImportC ""
  
  ; Import of the AES functions (included in Cypher lib, linked because we use MD5 too)
  ; (so we do not have to use the PB object system for thread safety)
  ;
  rijndael_set_key.l(*context, *key, bits)
  
  rijndael_ecb_decrypt.l(*context, *input, *output, length)
  rijndael_ecb_encrypt.l(*context, *input, *output, length)
  rijndael_cbc_decrypt.l(*context, *input, *output, length, *iv)
  rijndael_cbc_encrypt.l(*context, *input, *output, length, *iv)
  
  ; imported so we can get the binary data instead of the string (for key creation)
  MD5Init(*Context)
  MD5Update(*Context, *Buffer, Size)
  MD5Final(*Output, *Context)
  
EndImport

#SizeOf_rijndael_ctx = 488 ; size in bytes of a context structure (in C)
#SizeOf_MD5_ctx      = 88

DataSection
  
  CiperInitializer:
  Data.b $D7, $2F, $E7, $B8, $AA, $9F, $E9, $01, $A5, $A5, $09, $58, $C9, $85, $A9, $CC
  
EndDataSection

; in bytes, must be multiple of 16, not too large (can be different from debugger lib)
#EncryptionHandshakeSize = 32

;- ----> Data structure
Structure Network_Communication
  *Vtbl.CommunicationVtbl
  
  Host$
  Password$
  Port.l
  
  Connected.l         ; should we try to read or not ?
  IsFatalError.l
  CommandReceived.l   ; was there any command received yet?
  CommandTimeout.q    ; time of exe creation for timeout test
  EndReceived.l       ; was #COMMAND_End received yet ?
  EndTimeout.q        ; time of exe quit, timeout to be able to receive COMMAND_End before firing an error
  
  Socket.i
  
  ; The command stack is protected by a mutex separate from the overall
  ; "receive" mutex, so commands can be read from the stack while the thread
  ; is actually receiving data.
  StackMutex.i
  
  ; Stores Gadget/Window data during connection
  Window.i
  LogGadget.i
  PasswordGadget.i
  AbortGadget.i
  OkGadget.i
  
  ; set on user action
  PasswordSet.l
  AbortPressed.l
  InvisibleTimeout.q
  
  ; encryption support
  EncryptionHash$
  EncryptStream.l
  EncryptionDataSent.l
  CryptContext.b[#SizeOf_rijndael_ctx]
  HashContext.b[#SizeOf_MD5_ctx]
  InitializerEncrypt.b[16]
  InitializerDecrypt.b[16]
  
  ; waiting commands
  StackCount.l
  Stack.CommandStackStruct[#MAX_COMMANDSTACK]
EndStructure


;- ----> Globals
; All WinPipe Objects are handled in a LinkedList,
; protected by a mutex for ALL access to make it save with the thread
;
Global NewList Network_Data.Network_Communication()
Global Network_Mutex.i = CreateMutex()
Global Network_Thread  = 0
Global Network_Initialized = 0

;- ----> Encryption support

Procedure Network_SetupEncryption(*This.Network_Communication, Password$)
  *Key = AllocateMemory(16)
  If *Key
    
    Debug "[Network] Setup password: "+Chr(34)+Password$+Chr(34)
    
    ; This has to match what the debugger lib does
    ; Use the imported functions, so we get directly a binary representation
    MD5Init(@*This\HashContext)
    MD5Update(@*This\HashContext, ?CiperInitializer, 16)
    MD5Update(@*This\HashContext, ToAscii(Password$), StringByteLength(Password$, #PB_Ascii))
    MD5Final(*Key, @*This\HashContext)
    
    CompilerIf #PB_Compiler_Debugger
      Hex$ = ""
      For i = 0 To 15
        Hex$ + RSet(Hex(PeekA(*Key+i)), 2, "0")
      Next i
      Debug "[Network] Encryption Key: " + LCase(Hex$)
    CompilerEndIf
    
    rijndael_set_key(@*This\CryptContext, *Key, 128)
    
    ; this will be needed for CBC on the actual data stream
    CopyMemory(?CiperInitializer, @*This\InitializerEncrypt, 16)
    CopyMemory(?CiperInitializer, @*This\InitializerDecrypt, 16)
    
    FreeMemory(*Key)
  EndIf
EndProcedure

; must be freed by caller
Procedure Network_CreateHandshakeBlock(*This.Network_Communication)
  *Block      = AllocateMemory(#EncryptionHandshakeSize * 2)
  *BlockPlain = *Block + #EncryptionHandshakeSize ; use the same buffer
  
  If *Block
    ; create random plaintext
    ; this can differ from what the debugger lib does
    ; does not need to be a strong random, as even a known-plaintext-attack on AES has not been done yet
    For i = 0 To (#EncryptionHandshakeSize/4)-1
      PokeL(*BlockPlain + i*4, Random($FFFFFFFF))
    Next i
    
    CompilerIf #PB_Compiler_Debugger
      Debug "[Network] Calling Network_CreateHandshakeBlock()"
      Debug "[Network] Encryption handshake block PLAIN (" + Str(#EncryptionHandshakeSize)+") bytes"
      B$ = ""
      For i = 0 To #EncryptionHandshakeSize-1
        B$ + LCase(RSet(Hex(PeekA(*BlockPlain+i)), 2, "0")) + " "
      Next i
      Debug B$
    CompilerEndIf
    
    ; get MD5 of it
    *This\EncryptionHash$ = Fingerprint(*BlockPlain, #EncryptionHandshakeSize, #PB_Cipher_MD5)
    
    ; encrypt
    rijndael_ecb_encrypt(@*This\CryptContext, *BlockPlain, *Block, #EncryptionHandshakeSize)
    
    CompilerIf #PB_Compiler_Debugger
      Debug "[Network] Encryption Hash: " + *This\EncryptionHash$
      Debug "[Network] Encryption handshake block CIPHER (" + Str(#EncryptionHandshakeSize)+") bytes"
      B$ = ""
      For i = 0 To #EncryptionHandshakeSize-1
        B$ + LCase(RSet(Hex(PeekA(*Block+i)), 2, "0")) + " "
      Next i
      Debug B$
    CompilerEndIf
  EndIf
  
  ProcedureReturn *Block
EndProcedure


Procedure.s Network_DecryptHandshakeBlock(*This.Network_Communication, *Block, Size)
  Result$ = "-invalid-"
  
  If *Block And Size > 0
    *Decrypted = AllocateMemory(Size)
    If *Decrypted
      
      CompilerIf #PB_Compiler_Debugger
        Debug "[Network] Calling Network_DecryptHandshakeBlock()"
        Debug "[Network] Encryption handshake block CIPHER (" + Str(Size)+") bytes"
        B$ = ""
        For i = 0 To Size-1
          B$ + LCase(RSet(Hex(PeekA(*Block+i)), 2, "0")) + " "
        Next i
        Debug B$
      CompilerEndIf
      
      rijndael_ecb_decrypt(@*This\CryptContext, *Block, *Decrypted, Size)
      
      ; The debugger lib uses a compatible method
      Result$ = Fingerprint(*Decrypted, Size, #PB_Cipher_MD5)
      
      CompilerIf #PB_Compiler_Debugger
        Debug "[Network] Encryption Hash: " + Result$
        Debug "[Network] Encryption handshake block PLAIN (" + Str(Size)+") bytes"
        B$ = ""
        For i = 0 To Size-1
          B$ + LCase(RSet(Hex(PeekA(*Decrypted+i)), 2, "0")) + " "
        Next i
        Debug B$
      CompilerEndIf
      
      FreeMemory(*Decrypted)
    EndIf
  EndIf
  
  ProcedureReturn Result$
EndProcedure


;- ----> Functions for the text-based negotiation

; Read a string until newline (CRLF or LF)
; returns "-error-" if network connection failed
;
Procedure.s Network_ReadString(Socket)
  Result$ = ""
  
  *Buffer = AllocateMemory(1024)
  Size    = 1024
  If *Buffer
    *Pointer.BYTE = *Buffer
    
    Repeat
      If (*Pointer - *Buffer) > Size-10
        ; reallocate buffer
        Size + 1024
        *Pointer - *Buffer ; get index
        
        *NewBuffer = ReAllocateMemory(*Buffer, Size)
        If *NewBuffer
          *Buffer = *NewBuffer
          *Pointer + *Buffer ; get pointer
        Else
          Result$ = PeekS(*Buffer, *Pointer, #PB_Ascii) ; pointer has the length
          Break
        EndIf
      EndIf
      
      If Network_ReceiveData(Socket, *Pointer, 1)
        If *Pointer\b = 10 ; newline
          *Pointer\b = 0
          
          ; check and remove a CR before the LF
          If *Pointer > *Buffer And PeekB(*Pointer-1) = 13
            PokeB(*Pointer-1, 0)
          EndIf
          
          Result$ = PeekS(*Buffer, -1, #PB_Ascii)
          Break
        Else
          *Pointer + 1
        EndIf
      Else
        Result$ = "-error-"
        Break
      EndIf
    ForEver
    
    FreeMemory(*Buffer)
  EndIf
  
  Debug "Network_ReadString(): " + Result$
  ProcedureReturn Result$
EndProcedure

; Read one Value from the values list (Key<LF>Value pairs)
;
Procedure.s Network_GetValue(Key$, List Values$())
  Key$ = UCase(Key$)
  
  ForEach Values$()
    If StringField(Values$(), 1, Chr(10)) = Key$
      ProcedureReturn StringField(Values$(), 2, Chr(10))
    EndIf
  Next Values$()
  
  ProcedureReturn ""
EndProcedure

; Read a header (until empty line) including data and values (Key<LF>Value)
; Returnvalue is the header first line (cleaned up)
;
Procedure.s Network_ReadHeader(Socket, List Values$(), *pCommandData.INTEGER)
  ClearList(Values$())
  *pCommandData\i = 0
  
  Header$ =  Network_ReadString(Socket)
  If Header$ <> "" And Header$ <> "-error-"
    ; remove extra whitespace by tokenizing
    ;
    String$ = Trim(RemoveString(Header$, Chr(9)))
    Header$ = ""
    
    While String$
      Option$ = StringField(String$, 1, " ")
      Header$ + Option$ + " "
      String$ = LTrim(Right(String$, Len(String$)-Len(Option$)))
    Wend
    
    Header$ = RTrim(Header$)
    
    ; read additional values
    ;
    Repeat
      Pair$ = Network_ReadString(Socket)
      If Pair$ = "-error-"
        ClearList(Values$())
        ProcedureReturn "-error-"
      ElseIf Pair$ <> ""
        Pair$ = RemoveString(Pair$, Chr(9))
        Separator = FindString(Pair$, ":", 1)
        If Separator <> 0
          AddElement(Values$())
          Values$() = UCase(Trim(Left(Pair$, Separator-1)))+Chr(10)+Trim(Right(Pair$, Len(Pair$)-Separator))
        EndIf
      EndIf
    Until Pair$ = ""
    
    LengthValue$ = Network_GetValue("Length", Values$())
    If LengthValue$
      Length = Val(LengthValue$)
      If Length > 0
        *pCommandData\i = AllocateMemory(Length)
        If *pCommandData\i
          If Network_ReceiveData(Socket, *pCommandData\i, Length) = 0
            Header$ = "-error-"
            ClearList(Values$())
            FreeMemory(*pCommandData\i)
            *pCommandData\i = 0
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn Header$
EndProcedure

; the message is in english, not translated
Procedure Network_SendError(Socket, Key$, Message$)
  Response$ = "ERROR " + Str(#PB_Compiler_Version) + " " + Key$ + #LF$
  Response$ + "  Message: " + Message$ + #LF$
  Response$ + #LF$
  
  Network_SendString(Socket, Response$)
EndProcedure

;- ----> Functions for the status Window

Procedure Network_ShowPasswordEntry(*This.Network_Communication, State)
  GetRequiredSize(*This\AbortGadget, @AbortWidth.l, @AbortHeight.l)
  GetRequiredSize(*This\OkGadget, @OkWidth.l, @OkHeight.l)
  OkHeight   = Max(OkHeight, GetRequiredHeight(*This\PasswordGadget))
  OkWidth    = Max(OkWidth, 50)
  AbortWidth = Max(AbortWidth, 100)
  
  If State
    HideGadget(*This\PasswordGadget, 0)
    HideGadget(*This\OkGadget, 0)
    ResizeGadget(*This\LogGadget, 10, 10, 330, 215-AbortHeight-OkHeight)
    ResizeGadget(*This\PasswordGadget, 10, 230-AbortHeight-OkHeight, 325-OkWidth, OkHeight)
    ResizeGadget(*This\OkGadget, 340-OkWidth, 230-AbortHeight-OkHeight, OkWidth, OkHeight)
    
    ; reset the password
    *This\PasswordSet = 0
    HideWindow(*This\Window, 0) ; make sure it is visible
    SetGadgetText(*This\PasswordGadget, "")
    SetActiveWindow(*This\Window)
    SetActiveGadget(*This\PasswordGadget)
  Else
    HideGadget(*This\PasswordGadget, 1)
    HideGadget(*This\OkGadget, 1)
    ResizeGadget(*This\LogGadget, 10, 10, 330, 220-AbortHeight)
  EndIf
  
  ResizeGadget(*This\AbortGadget, (350-AbortWidth)/2, 240-AbortHeight, AbortWidth, AbortHeight)
EndProcedure

Procedure Network_OpenWindow(*This.Network_Communication, Title$)
  CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
    DisableWindow(#WINDOW_Main, 1)
    Parent = WindowID(#WINDOW_Main)
  CompilerElse
    DisableWindow(#WINDOW_Main, 1)
    Parent = WindowID(#WINDOW_Main)
  CompilerEndIf
  
  *This\Window = OpenWindow(#PB_Any, 0, 0, 350, 250, Title$, #PB_Window_TitleBar|#PB_Window_WindowCentered|#PB_Window_Invisible, Parent)
  If *This\Window
    *This\LogGadget      = ListViewGadget(#PB_Any, 0, 0, 0, 0)
    *This\PasswordGadget = StringGadget(#PB_Any, 0, 0, 0, 0, "", #PB_String_Password)
    *This\AbortGadget    = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Misc", "Cancel"))
    *This\OkGadget       = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Misc", "Ok"))
    
    AddKeyboardShortcut(*This\Window, #PB_Shortcut_Return, 1)
    
    ; Initially the window stays hidden, until the timeout expires
    ; (so it does Not popup shortly when connecting to localhost for example)
    ;
    *This\InvisibleTimeout = ElapsedMilliseconds() + 500
    
    Network_ShowPasswordEntry(*This, #False) ; resize the content
    *This\AbortPressed = #False
  EndIf
EndProcedure

Procedure Network_CloseWindow(*This.Network_Communication)
  CloseWindow(*This\Window)
  
  CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
    DisableWindow(#WINDOW_Main, 0)
  CompilerElse
    DisableWindow(#WINDOW_Main, 0)
  CompilerEndIf
EndProcedure

Procedure Network_FlushWindowEvents(*This.Network_Communication)
  EventCount = 0
  
  If *This\InvisibleTimeout <> -1 And *This\InvisibleTimeout < ElapsedMilliseconds()
    ; show the window now
    HideWindow(*This\Window, 0) ; it took a while, make the window visible
    SetActiveWindow(*This\Window)
    *This\InvisibleTimeout = -1 ; do not do it again
  EndIf
  
  Repeat
    EventID = WindowEvent()
    
    If EventID = 0
      ProcedureReturn EventCount
      
    Else
      EventCount + 1
      
      If EventWindow() = *This\Window
        If EventID = #PB_Event_Gadget And EventGadget() = *This\AbortGadget
          *This\AbortPressed = #True
          ProcedureReturn EventCount
          
        ElseIf EventID = #PB_Event_Gadget And EventGadget() = *This\OkGadget
          *This\PasswordSet = #True
          ProcedureReturn EventCount
          
        ElseIf EventID = #PB_Event_Menu And EventMenu() = 1
          If GetActiveGadget() = *This\PasswordGadget
            *This\PasswordSet = #True
            ProcedureReturn EventCount
          EndIf
          
        EndIf
        
      Else
        ; For the standalone debugger we just drop the event as the main
        ; window is disabled anyway
        CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
          DispatchEvent(EventID)
        CompilerEndIf
        
      EndIf
    EndIf
  ForEver
EndProcedure

Procedure Network_AddLog(*This.Network_Communication, Message$)
  AddGadgetItem(*This\LogGadget, -1, Message$)
  SetGadgetState(*This\LogGadget, CountGadgetItems(*This\LogGadget)-1)
  Network_FlushWindowEvents(*This)
EndProcedure

;- ----> Connect functions


Procedure Network_ConnectServer(*This.Network_Communication)
  Success = #False
  Protected NewList Values$()
  AcceptSocket = #SOCKET_ERROR
  
  If *This\Password$
    Network_SetupEncryption(*This, *This\Password$)
  EndIf
  
  If *This\Host$ <> ""
    Title$ = ReplaceString(ReplaceString(Language("NetworkDebugger", "ServerTitleNamed"), "%port%", Str(*This\Port)), "%host%", *This\Host$)
  Else
    Title$ = ReplaceString(Language("NetworkDebugger", "ServerTitle"), "%port%", Str(*This\Port))
  EndIf
  
  Network_OpenWindow(*This, Title$)
  HideWindow(*This\Window, 0) ; show it immediately here, as it won't be an instant connect
  
  If Network_Listen(*This\Socket, *This\Host$, *This\Port)
    
    While *This\AbortPressed = #False And Success = 0
      ; wait for connection
      Network_AddLog(*This, Language("NetworkDebugger", "Listen"))
      
      While *This\AbortPressed = #False And AcceptSocket = #SOCKET_ERROR
        AcceptSocket = Network_CheckAccept(*This\Socket)
        If AcceptSocket = #SOCKET_ERROR ; no connection yet
          If Network_FlushWindowEvents(*This) = 0
            Delay(50)
          EndIf
        EndIf
      Wend
      
      If *This\AbortPressed
        Break
      EndIf
      
      ; handle requests from client
      Network_FlushWindowEvents(*This)
      
      *This\EncryptionDataSent = 0
      
      While *This\AbortPressed = #False And Success = 0
        Select Network_CheckData(AcceptSocket)
            
          Case 0 ; nothing to read
            If Network_FlushWindowEvents(*This) = 0
              Delay(50)
            EndIf
            
          Case 1
            Header$   = Network_ReadHeader(AcceptSocket, Values$(), @*CommandData)
            VersionNb = Val(StringField(Header$, 2, " "))
            
            If Header$ = "-error-" Or Header$ = ""
              Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
              Break
              
            ElseIf VersionNb <> #PB_Compiler_Version
              Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_WrongVersion"))
              Network_AddLog(*This, Language("NetworkDebugger", "ExeVersion")+": "+StrF(VersionNb / 100.0, 2))
              Network_AddLog(*This, Language("NetworkDebugger", "DebuggerVersion")+": "+StrF(#PB_Compiler_Version / 100.0, 2))
              Network_AddLog(*This, Language("NetworkDebugger", "ConnectionDenied"))
              Network_SendError(AcceptSocket, "WrongVersion", "The PureBasic Version does not match.")
              Break
              
            Else
              Select UCase(StringField(Header$, 1, " "))
                  
                Case "CONNECT"
                  Select UCase(StringField(Header$, 3, " ")); check the target
                      
                    Case "EXECUTABLE"
                      Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_NoExecutable"))
                      Network_AddLog(*This, Language("NetworkDebugger", "ConnectionDenied"))
                      Network_SendError(AcceptSocket, "NoExecutable", "The server is not a debug-able executable.")
                      Break
                      
                    Case "DEBUGGER"
                      PasswordOK = 0
                      
                      If *This\Password$ And *This\EncryptionDataSent > 0
                        If *This\EncryptionHash$ = Network_GetValue("EncryptionHash", Values$())
                          PasswordOK = 1
                        EndIf
                      EndIf
                      
                      If *This\Password$ And PasswordOK = 0
                        ; create a new handshake block and send response
                        *Block = Network_CreateHandshakeBlock(*This)
                        If *Block
                          Response$ = "ENCRYPTION " + Str(#PB_Compiler_Version) + " AES" + #LF$
                          Response$ + "  Length: "+Str(#EncryptionHandshakeSize) + #LF$
                          Response$ + #LF$
                          
                          If Network_SendString(AcceptSocket, Response$) = 0 Or Network_SendData(AcceptSocket, *Block, #EncryptionHandshakeSize) = 0
                            Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
                            FreeMemory(*Block)
                            Break
                          EndIf
                          *This\EncryptionDataSent + 1
                          ; no break in this case
                          
                          FreeMemory(*Block)
                        Else
                          Network_AddLog(*This, Language("Misc", "Error")+": " + Language("NetworkDebugger", "Error_FatalError"))
                          Network_AddLog(*This, Language("NetworkDebugger", "ConnectionDenied"))
                          Network_SendError(AcceptSocket, "FatalError", "Fatal error.")
                          Break
                        EndIf
                        
                        
                      Else ; no password, or match
                        
                        ; Send the ACCEPT response with our settings
                        If *This\Password$
                          *This\EncryptStream = 1
                        EndIf
                        
                        Response$ = "ACCEPT " + Str(#PB_Compiler_Version) + " DEBUGGER" + #LF$
                        Response$ + "  CallOnStart: "+Str(CallDebuggerOnStart) + #LF$
                        Response$ + "  CallOnEnd: "+Str(CallDebuggerOnEnd) + #LF$
                        Response$ + "  Unicode: "+Str(#PB_Compiler_Unicode) + #LF$
                        Response$ + "  BigEndian: "+Str(#DEBUGGER_BigEndian) + #LF$
                        Response$ + "  Encryption: "+Str(*This\EncryptStream) + #LF$
                        Response$ + #LF$
                        
                        If Network_SendString(AcceptSocket, Response$)
                          Success = #True
                          Network_AddLog(*This, Language("NetworkDebugger", "ConnectionSuccess"))
                        Else
                          Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
                        EndIf
                        Break
                      EndIf
                      
                    Default
                      Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_NoService"))
                      Network_AddLog(*This, Language("NetworkDebugger", "ConnectionDenied"))
                      Network_SendError(AcceptSocket, "NoService", "The server cannot provide the requested service.")
                      Break
                      
                  EndSelect
                  
                Default
                  Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_InvalidRequest"))
                  Network_AddLog(*This, Language("NetworkDebugger", "ConnectionDenied"))
                  Network_SendError(AcceptSocket, "InvalidRequest", "Invalid request.")
                  Break
                  
              EndSelect
              
            EndIf
            
            If *CommandData
              FreeMemory(*CommandData)
              *CommandData = 0
            EndIf
            
          Case 2
            Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
            Break
            
        EndSelect
      Wend
      
      If Success = 0
        ; if we get here with no success then we have to close the socket
        Network_CloseSocket(AcceptSocket)
        AcceptSocket = #SOCKET_ERROR
      EndIf
      
    Wend
    
  Else
    Network_AddLog(*This, Language("NetworkDebugger", "ServerFailed") + " " + Str(*This\Port))
    
    ; This is the only place where we have a hard error as server.
    ; All others just go to the log and the user has to press abort to cancel the wait
    ;
    SetActiveWindow(*This\Window)
    MessageRequester("PureBasic Debugger", Language("NetworkDebugger", "ServerFailed") + " " + Str(*This\Port), #FLAG_Error)
  EndIf
  
  
  If Success
    
    ; Close the listen socket and keep the accept one
    Network_CloseSocket(*This\Socket)
    *This\Socket = AcceptSocket
    
    ; Start the command received timeout now
    ;
    *This\CommandReceived = 0
    *This\CommandTimeout  = ElapsedMilliseconds()
    
    *This\Connected = 1 ; the thread can start reading
    
  EndIf
  
  Network_CloseWindow(*This)
  
  ProcedureReturn Success
EndProcedure



Procedure Network_ConnectClient(*This.Network_Communication)
  Success = #False
  Connected = #False
  Protected NewList Values$()
  Message$ = ""
  
  Title$ = Language("NetworkDebugger", "ConnectTitle") + " " + *This\Host$ + " (" + Language("NetworkDebugger", "Port") + " " + Str(*This\Port) + ") ..."
  Network_OpenWindow(*This, Title$)
  Network_AddLog(*This, Language("NetworkDebugger", "Connect"))
  
  If Network_ConnectSocketStart(*This\Socket, *This\Host$, *This\Port)
    Network_FlushWindowEvents(*This)
    
    While *This\AbortPressed = #False And Connected = #False
      Select Network_ConnectSocketCheck(*This\Socket)
          
        Case 0 ; pending
          If Network_FlushWindowEvents(*This) = 0
            Delay(50)
          EndIf
          
        Case 1 ; connected
          Connected = #True
          
        Case 2 ; failed
          Network_AddLog(*This, Language("NetworkDebugger", "ConnectionFailed"))
          Break
          
      EndSelect
    Wend
  Else
    Network_AddLog(*This, Language("NetworkDebugger", "ConnectionFailed"))
  EndIf
  
  If Connected
    Network_AddLog(*This, Language("NetworkDebugger", "QueryStatus"))
    
    Request$ = "CONNECT " + Str(#PB_Compiler_Version) + " EXECUTABLE" + #LF$
    Request$ + "  CallOnStart: "+Str(CallDebuggerOnStart) + #LF$
    Request$ + "  CallOnEnd: "+Str(CallDebuggerOnEnd) + #LF$
    Request$ + "  Unicode: "+Str(#PB_Compiler_Unicode) + #LF$
    Request$ + "  BigEndian: "+Str(#DEBUGGER_BigEndian) + #LF$
    Request$ + #LF$
    
    If Network_SendString(*This\Socket, Request$)
      Network_FlushWindowEvents(*This)
      
      While *This\AbortPressed = #False
        Select Network_CheckData(*This\Socket)
            
          Case 0 ; nothing to read
            If Network_FlushWindowEvents(*This) = 0
              Delay(50)
            EndIf
            
          Case 1
            Header$   = Network_ReadHeader(*This\Socket, Values$(), @*CommandData)
            VersionNb = Val(StringField(Header$, 2, " "))
            
            If Header$ = "-error-"
              Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
              Message$ = Language("NetworkDebugger", "ConnectionLost")
              Break
              
            ElseIf VersionNb <> #PB_Compiler_Version
              Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_WrongVersion"))
              Network_AddLog(*This, Language("NetworkDebugger", "ExeVersion")+": "+StrF(VersionNb / 100.0, 2))
              Network_AddLog(*This, Language("NetworkDebugger", "DebuggerVersion")+": "+StrF(#PB_Compiler_Version / 100.0, 2))
              Message$ = Language("NetworkDebugger", "Error_WrongVersion") + #NewLine + Language("NetworkDebugger", "ExeVersion")+": "+StrF(VersionNb / 100.0, 2) + #NewLine +Language("NetworkDebugger", "DebuggerVersion")+": "+StrF(#PB_Compiler_Version / 100.0, 2)
              Break
              
            Else
              Select UCase(StringField(Header$, 1, " "))
                  
                Case "ACCEPT"
                  Network_AddLog(*This, Language("NetworkDebugger","ConnectionSuccess"))
                  
                  ; check if the server has encryption enabled
                  ; (we will only receive this after a succeeded encryption handshake)
                  Value$ = Network_GetValue("Encryption", Values$())
                  If Value$ And Val(Value$) <> 0
                    *This\EncryptStream = #True
                  EndIf
                  
                  Success = #True
                  Break
                  
                Case "ENCRYPTION"
                  
                  If *This\Password$ And *This\EncryptionDataSent = 0
                    ; password not yet send
                    Password$ = *This\Password$
                  Else
                    If *This\EncryptionDataSent = 0
                      Network_AddLog(*This, Language("NetworkDebugger","NeedPassword"))
                    Else
                      Network_AddLog(*This, Language("NetworkDebugger","WrongPassword"))
                    EndIf
                    
                    ; get the password
                    Network_ShowPasswordEntry(*This, #True)
                    While *This\PasswordSet = #False And *This\AbortPressed = #False
                      If Network_FlushWindowEvents(*This) = 0
                        Delay(50)
                      EndIf
                    Wend
                    Password$ = GetGadgetText(*This\PasswordGadget)
                    Network_ShowPasswordEntry(*This, #False)
                    
                    If *This\AbortPressed
                      Break
                    EndIf
                  EndIf
                  
                  ; setup the context with the password
                  Network_SetupEncryption(*This, Password$)
                  
                  ; decrypt the buffer with this password and send a new request
                  Hash$ = Network_DecryptHandshakeBlock(*This, *CommandData, Val(Network_GetValue("Length", Values$())))
                  
                  Request$ = "CONNECT " + Str(#PB_Compiler_Version) + " EXECUTABLE" + #LF$
                  Request$ + "  CallOnStart: "+Str(CallDebuggerOnStart) + #LF$
                  Request$ + "  CallOnEnd: "+Str(CallDebuggerOnEnd) + #LF$
                  Request$ + "  Unicode: "+Str(#PB_Compiler_Unicode) + #LF$
                  Request$ + "  BigEndian: "+Str(#DEBUGGER_BigEndian) + #LF$
                  Request$ + "  EncryptionHash: "+ Hash$ + #LF$
                  Request$ + #LF$
                  
                  If Network_SendString(*This\Socket, Request$) = 0
                    Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
                    Message$ = Language("NetworkDebugger", "ConnectionLost")
                    Break
                  EndIf
                  
                  *This\EncryptionDataSent + 1
                  
                Case "ERROR"
                  Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_"+StringField(Header$, 3, " ")))
                  Network_AddLog(*This, Language("NetworkDebugger", "ConnectionFailed"))
                  Message$ = Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_"+StringField(Header$, 3, " "))
                  Break
                  
                Default
                  Network_AddLog(*This, Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_InvalidResponse"))
                  Network_AddLog(*This, Language("NetworkDebugger", "ConnectionFailed"))
                  Message$ = Language("Misc", "Error")+": "+Language("NetworkDebugger", "Error_InvalidResponse")
                  Break
                  
              EndSelect
              
            EndIf
            
            If *CommandData
              FreeMemory(*CommandData)
              *CommandData = 0
            EndIf
            
          Case 2
            Network_AddLog(*This, Language("NetworkDebugger", "ConnectionLost"))
            Message$ = Language("NetworkDebugger", "ConnectionLost")
            Break
            
        EndSelect
      Wend
      
    EndIf
  EndIf
  
  If Success
    
    ; Start the command received timeout now
    ;
    *This\CommandReceived = 0
    *This\CommandTimeout  = ElapsedMilliseconds()
    
    *This\Connected = 1 ; the thread can start reading
    
  ElseIf *This\AbortPressed = #False  ; no error when abort was pressed
    
    HideWindow(*This\Window, 0) ; make sure the window is visible
    SetActiveWindow(*This\Window)
    
    MessageStart$ = Language("NetworkDebugger","ConnectFailed") + ":" + #NewLine + *This\Host$ + " (" + Language("NetworkDebugger","Port") + " " + Str(*This\Port) + ")"
    If Message$ <> ""
      MessageStart$ + #NewLine + #NewLine + Message$
    EndIf
    
    MessageRequester("PureBasic Debugger", MessageStart$, #FLAG_Error)
    
  EndIf
  
  Network_CloseWindow(*This)
  
  ProcedureReturn Success
EndProcedure



;- ----> Communication Interface

DisableDebugger

Procedure Network_FatalError(*This.Network_Communication, *Command.CommandInfo, FatalError)
  *This\IsFatalError = #True
  
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

Procedure Network_ReadCommandCrypt(*This.Network_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
  Protected CommandCrypt.CommandInfo
  
  If Network_ReceiveData(*This\Socket, @CommandCrypt, SizeOf(CommandInfo)) = 0
    ProcedureReturn #False
  EndIf
  
  rijndael_cbc_decrypt(@*This\CryptContext, @CommandCrypt, *Command, SizeOf(CommandInfo), @*This\InitializerDecrypt)
  ;rijndael_ecb_decrypt(@*This\CryptContext, @CommandCrypt, *Command, SizeOf(CommandInfo))
  ;CopyMemory(@CommandCrypt, *Command, SizeOf(CommandInfo))
  
  If *Command\DataSize > 0
    
    ; Padding for blocks < 16 bytes
    If *Command\DataSize < 16
      Size = 16
    Else
      Size = *Command\DataSize
    EndIf
    
    *pCommandData\i   = AllocateMemory(Size)
    *CommandDataCrypt = AllocateMemory(Size)
    If *pCommandData\i = 0 Or *CommandDataCrypt = 0
      ProcedureReturn #False
    EndIf
    
    If Network_ReceiveData(*This\Socket, *CommandDataCrypt, Size) = 0
      FreeMemory(*pCommandData\i)
      FreeMemory(*CommandDataCrypt)
      *pCommandData\i = 0
      ProcedureReturn #False
    EndIf
    
    rijndael_cbc_decrypt(@*This\CryptContext, *CommandDataCrypt, *pCommandData\i, Size, @*This\InitializerDecrypt)
    ;rijndael_ecb_decrypt(@*This\CryptContext, *CommandDataCrypt, *pCommandData\i, Size)
    ;CopyMemory(*CommandDataCrypt, *pCommandData\i, Size)
    
    FreeMemory(*CommandDataCrypt)
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure Network_ReadCommand(*This.Network_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
  *pCommandData\i = 0
  
  If *This\EncryptStream
    ProcedureReturn Network_ReadCommandCrypt(*This, *Command, *pCommandData)
    
  Else
    
    If Network_ReceiveData(*This\Socket, *Command, SizeOf(CommandInfo)) = 0
      ProcedureReturn #False
    EndIf
    
    If *Command\DataSize > 0
      *pCommandData\i = AllocateMemory(*Command\DataSize)
      If *pCommandData\i = 0
        ProcedureReturn #False
        
      ElseIf Network_ReceiveData(*This\Socket, *pCommandData\i, *Command\DataSize) = 0
        ProcedureReturn #False
        
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn #True
EndProcedure

CompilerIf #NOTHREAD = 0
  
  ; ProcedureDLL for OSX !! (weird errors else!)
  ;
  ProcedureDLL Network_ReceiveThread(Dummy)
    
    Protected Command.CommandInfo
    Protected *CommandData
    
    Repeat
      LockMutex(Network_Mutex)  ; full protection needed!
      
      TotalCount = 0
      ForEach Network_Data()
        
        ; receive as long as there is data, and as long as there is space
        ;
        While Network_Data()\Connected And Network_Data()\EndReceived = 0 And Network_Data()\IsFatalError = 0
          
          ; Do not receive anything if the stack is full
          If Network_Data()\StackCount >= #MAX_COMMANDSTACK
            ; This check can be done without a mutex lock, as only this thread
            ; can increase the stack, and a decrease during the check has no concequence
            Break
          EndIf
          
          Select Network_CheckData(Network_Data()\Socket)
              
            Case 0 ; no data
              Break
              
            Case 1 ; data
              If Network_ReadCommand(@Network_Data(), @Command, @*CommandData)
                ; now lock the stack mutex and add data to the stack
                ; we know there is a free spot, as we checked above
                ; (And the main thread only decreases the stack)
                LockMutex(Network_Data()\StackMutex)
                
                ; add to stack
                CopyMemory(@Command, @Network_Data()\Stack[Network_Data()\StackCount]\Command, SizeOf(CommandInfo))
                Network_Data()\Stack[Network_Data()\StackCount]\CommandData = *CommandData
                Network_Data()\StackCount + 1
                
                Network_Data()\CommandReceived = 1
                
                If Command\Command = #COMMAND_End
                  Network_Data()\EndReceived = 1
                EndIf
                
                UnlockMutex(Network_Data()\StackMutex)
                
                TotalCount + 1
                
                ; break (and unlock mutex) after a lot of commands are read so the main thread can read it
                If TotalCount > 50
                  Break 2
                EndIf
              Else
                If Network_Data()\EndReceived = 0
                  Network_FatalError(@Network_Data(), @Command, #ERROR_NetworkFail)
                EndIf
                Break
              EndIf
              
            Case 2 ; disconnect
              If Network_Data()\EndReceived = 0  ; its no error if we terminated normally
                Network_FatalError(@Network_Data(), @Command, #ERROR_NetworkFail)
              EndIf
              Break
              
          EndSelect
          
        Wend
        
      Next Network_Data()
      
      UnlockMutex(Network_Mutex)
      
      Delay(10) ; time for the main thread to access the data
    ForEver
    
  EndProcedure
  
CompilerEndIf

EnableDebugger


Procedure.s Network_GetInfo(*This.Network_Communication)
  ProcedureReturn "" ; nothing to pass back here
EndProcedure


Procedure Network_Disconnect(*This.Network_Communication)
  LockMutex(Network_Mutex)
  ; Tell the thread to no longer try any reads (the socket is closed in Close())
  *This\Connected = 0
  UnlockMutex(Network_Mutex)
EndProcedure

Procedure Network_SendCrypt(*This.Network_Communication, *Command.CommandInfo, *CommandData)
  Protected CommandCrypt.CommandInfo
  Size = *Command\DataSize
  
  ; Encrypt/send the command (always > 16 byte)
  rijndael_cbc_encrypt(@*This\CryptContext, *Command, @CommandCrypt, SizeOf(CommandInfo), @*This\InitializerEncrypt)
  ;rijndael_ecb_encrypt(@*This\CryptContext, *Command, @CommandCrypt, SizeOf(CommandInfo))
  ;CopyMemory(*Command, @CommandCrypt, SizeOf(CommandInfo))
  
  Network_SendData(*This\Socket, @CommandCrypt, SizeOf(CommandInfo))
  
  If Size > 0 And *CommandData
    
    If Size < 16
      ; AES cannot handle buffers < 16byte, must be padded
      ;
      *Buffer = AllocateMemory(16)
      If *Buffer = 0
        ProcedureReturn
      EndIf
      
      CopyMemory(*CommandData, *Buffer, Size)
      SizeReal = 16
    Else
      *Buffer = *CommandData
      SizeReal = Size
    EndIf
    
    *CommandDataCrypt = AllocateMemory(Size)
    If *CommandDataCrypt
      rijndael_cbc_encrypt(@*This\CryptContext, *Buffer, *CommandDataCrypt, SizeReal, @*This\InitializerEncrypt)
      ;rijndael_ecb_encrypt(@*This\CryptContext, *Buffer, *CommandDataCrypt, SizeReal)
      ;CopyMemory(*Buffer, *CommandDataCrypt, SizeReal)
      
      Network_SendData(*This\Socket, *CommandDataCrypt, SizeReal)
      FreeMemory(*CommandDataCrypt)
    EndIf
    
    If Size < 16
      FreeMemory(*Buffer)
    EndIf
  EndIf
  
EndProcedure



Procedure Network_Send(*This.Network_Communication, *Command.CommandInfo, *CommandData)
  
  ; Note: We no longer do any disconnect detection when sending, because if the
  ;   exe closes normally while we send something, we do not want a "fatal error"
  ;   but rather the normal end message which we get when we get to read the COMMAND_End
  ;   from the exe later
  ;
  If *This\Connected And *This\EndReceived = 0
    
    If *This\EncryptStream
      Network_SendCrypt(*This, *Command, *CommandData)
    Else
      
      Network_SendData(*This\Socket, *Command, SizeOf(CommandInfo))
      
      If *Command\DataSize > 0 And *CommandData
        Network_SendData(*This\Socket, *CommandData, *Command\DataSize)
      EndIf
      
    EndIf
    
  EndIf
  
EndProcedure


Procedure Network_Receive(*This.Network_Communication, *Command.CommandInfo, *pCommandData.INTEGER)
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
      Select Network_CheckData(*This\Socket)
        Case 1
          If Not Network_ReadCommand(*This, *Command, *pCommandData)
            If *This\EndReceived = 0
              Network_FatalError(*This, *Command, #ERROR_NetworkFail)
              Result = 1
            EndIf
          Else
            *This\CommandReceived = 1
            
            If *Command\Command = #COMMAND_End
              *This\EndReceived = 1
            EndIf
            Result = 1
          EndIf
          
          
        Case 2
          If *This\EndReceived = 0
            Network_FatalError(*This, *Command, #ERROR_NetworkFail)
            Result = 1
          EndIf
          
      EndSelect
    EndIf
    
  CompilerEndIf
  
  ProcedureReturn Result
EndProcedure


Procedure Network_CheckErrors(*This.Network_Communication, *Command.CommandInfo, ProcessObject)
  
  If *This\EndReceived
    ; COMMAND_End was received. Fire no errors anymore
    ProcedureReturn #False
    
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



Procedure Network_Close(*This.Network_Communication)
  LockMutex(Network_Mutex)
  Network_CloseSocket(*This\Socket)
  
  ; clear stack, if any data left
  For i = 0 To *This\StackCount-1
    If *This\Stack[i]\CommandData
      FreeMemory(*This\Stack[i]\CommandData)
    EndIf
  Next i
  
  ; when we hold the global mutex, this is save
  FreeMutex(Network_Data()\StackMutex)
  
  ChangeCurrentElement(Network_Data(), *This)
  DeleteElement(Network_Data())
  UnlockMutex(Network_Mutex)
EndProcedure

;- ----> Initialisation

; Mode: 1=client, 2=server (ignores Host$)
;
Procedure CreateNetworkCommunication(Mode, Host$, Port, Password$)
  *Result = 0
  
  ; Initialize just once for all network stuff
  ;
  If Network_Initialized = 0
    Network_Initialized = Network_Initialize()
  EndIf
  
  If Network_Initialized
    
    ; there is only 1 thread for everything
    CompilerIf #NOTHREAD = 0
      If Network_Thread = 0
        Network_Thread = CreateThread(@Network_ReceiveThread(), 0)
      EndIf
      
      If Network_Thread
      CompilerEndIf
      
      LockMutex(Network_Mutex)
      
      AddElement(Network_Data())
      If Mode = 1
        Network_Data()\Vtbl = ?NetworkClient_Vtbl ; client mode
      Else
        Network_Data()\Vtbl = ?NetworkServer_Vtbl ; server mode
      EndIf
      Network_Data()\Host$      = Host$
      Network_Data()\Port       = Port
      Network_Data()\Password$  = Password$
      Network_Data()\StackMutex = CreateMutex()
      Network_Data()\Socket     = Network_CreateSocket()
      
      If Network_Data()\Socket <> #INVALID_SOCKET
        *Result = @Network_Data()
      Else
        DeleteElement(Network_Data())
      EndIf
      
      UnlockMutex(Network_Mutex)
      
      CompilerIf #NOTHREAD = 0
      EndIf
    CompilerEndIf
    
  EndIf
  
  If *Result = 0
    ; we have to notify the user here
    MessageRequester("PureBasic Debugger", Language("NetworkDebugger","Unavailable"), #FLAG_Error)
  EndIf
  
  ProcedureReturn *Result
EndProcedure



DataSection
  
  NetworkClient_Vtbl:
  Data.i @Network_GetInfo()
  Data.i @Network_ConnectClient()
  Data.i @Network_Disconnect()
  Data.i @Network_Send()
  Data.i @Network_Receive()
  Data.i @Network_CheckErrors()
  Data.i @Network_Close()
  
  NetworkServer_Vtbl:
  Data.i @Network_GetInfo()
  Data.i @Network_ConnectServer()
  Data.i @Network_Disconnect()
  Data.i @Network_Send()
  Data.i @Network_Receive()
  Data.i @Network_CheckErrors()
  Data.i @Network_Close()
  
  
EndDataSection


