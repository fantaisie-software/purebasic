;
; ------------------------------------------------------------
;
;       Atomic FTP Server in PureBasic
;
;          (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; This program isn't finished, the harder is done but I don't
; have the time to implement the whole RFC 959 commands :-).
; 
;
; 20/05/2002
;   Added a textgadget..
;   Updated for PureBasic 3.20 (Cleaned the code...)
;
; 19/03/2001
;   Listing is now working.
;
; 18/03/2001
;   Based on the Atomic Web Server code..
;   First version.
;

#Version = "0.2"

If InitNetwork() = 0
  MessageRequester("Error", "Can't initialize the network !", 0) : End
EndIf

ClientIP.s
Port = 21
BaseDirectory$    = "ftp/"
CurrentDirectory$ = BaseDirectory$
AtomicTitle$      = "Atomic FTP Server v"+#Version

EOL$ = Chr(13)+Chr(10)

*Buffer = AllocateMemory(10000)

If CreateNetworkServer(0, Port)

  OpenWindow(0, 300, 300, 230, 30, "Atomic FTP Server (Port "+Str(Port)+")")

  TextGadget(1, 10, 8, 200, 20, "Atomic FTP Server Ready.")
  
  Repeat
    
    WEvent = WindowEvent()
    SEvent = NetworkServerEvent()
  
    If WEvent = #PB_Event_CloseWindow
      Quit = 1
    EndIf

    If SEvent
      ClientID = EventClient()
  
      Select SEvent
      
        Case 1  ; New client connected
          SetGadgetText(1, "New client connected !")
          SendNetworkString(ClientID, "220 - Atomic FTP Server v0.1 ready"+EOL$)

        Case 4  ; New client has closed the connection
  
        Default
          RequestLength = ReceiveNetworkData(ClientID, *Buffer, 2000)
          If RequestLength > 3
            PokeL(*Buffer+RequestLength-2, 0)
          EndIf
          Gosub ProcessRequest
          
      EndSelect
    Else
      Delay(20)
    EndIf
    
  Until Quit = 1 
  
  CloseNetworkServer(0)
Else
  MessageRequester("Error", "Can't create the server (port in use ?).", 0)
EndIf

End 


ProcessRequest:

  Command$ = PeekS(*Buffer)
  
  Position = FindString(Command$, " ", 1)
  If Position
    Argument$ = Mid(Command$, Position+1, Len(Command$)-Position)
    Command$ = UCase(RTrim(Left(Command$, Position-1)))
  EndIf

  SetGadgetText(1, "Last command: "+Command$)

  Select Command$

    Case "HELP"
      Gosub Command_HELP

    Case "LIST"
      Gosub Command_LIST

    Case "PASS"
      Gosub Command_PASS

    Case "PORT"
      Gosub Command_PORT

    Case "PWD"
      Gosub Command_PWD

    Case "SYST"
      Gosub Command_SYST

    Case "USER"
      Gosub Command_USER

    Default
      Gosub Command_UNKNOWN

  EndSelect

Return


Command_HELP:
  SendNetworkString(ClientID, "214 - You wanna some help ? :-D"+EOL$)
Return


Command_LIST:
  SendNetworkString(ClientID, "150 - Opening connection"+EOL$)
  
  FTPConnection = OpenNetworkConnection(ClientIP, ClientPort)
  If FTPConnection
    
    a$ = ""
    If ExamineDirectory(0, CurrentDirectory$, "*.*")
    
      NumberFiles = -1
      While NextDirectoryEntry(0)
        
        If DirectoryEntryType(0) = 2
          a$ = a$+"drwxr-xr-x 6 1024 512 Jan 23 10:18 "+DirectoryEntryName(0)+EOL$
        ElseIf Type = 1
          a$ = a$+"rwxr-xr-x 6 512 "+Str(DirectoryEntrySize(0))+" Jan 23 10:18 "+DirectoryEntryName(0)+EOL$
        EndIf
        
        NumberFiles+1
      Wend
    EndIf
    
    SendNetworkString(FTPConnection, "total "+Str(NumberFiles)+EOL$+a$)
    CloseNetworkConnection(FTPConnection)
  EndIf
  
  SendNetworkString(ClientID, "226 - Listing finished"+EOL$)
Return


Command_PASS:
  SendNetworkString(ClientID, "230 - Welcome, enjoy this FTP site"+EOL$)
Return


Command_PORT:

  ; Build a real IP
  ;
  ClientIP = ""
  
  Position = FindString(Argument$, ",", 1)
  ClientIP = ClientIP+Mid(Argument$, 1, Position-1)+"."

  NewPosition = FindString(Argument$, ",", Position+1)
  ClientIP = ClientIP+Mid(Argument$, Position+1, NewPosition-Position-1)+"."

  Position = FindString(Argument$, ",", NewPosition+1)
  ClientIP = ClientIP+Mid(Argument$, NewPosition+1, Position-NewPosition-1)+"."

  NewPosition = FindString(Argument$, ",", Position+1)
  ClientIP = ClientIP+Mid(Argument$, Position+1, NewPosition-Position-1)

  ClientIP = Trim(ClientIP)

  ; Get the port..
  ;
  Position = FindString(Argument$, ",", NewPosition+1)
  
  ClientPort = Val(Mid(Argument$, NewPosition+1, Position-NewPosition-1)) << 8+Val(Right(Argument$, Len(Argument$)-Position))

  SendNetworkString(ClientID, "200 - Ok"+EOL$)
Return


Command_PWD:
  SendNetworkString(ClientID, "257 /"+EOL$)
Return


Command_UNKNOWN:
  SendNetworkString(ClientID, "500 - Unknow command"+EOL$)
Return


Command_USER:
  If Argument$ = "anonymous"
    a$ = "331 - User anonymous accepted. Please enter your e-mail"+EOL$
  Else
    a$ = "331 - Hello "+Argument$+". Please enter your password"+EOL$
  EndIf

  SendNetworkString(ClientID, a$)
Return


Command_SYST:
  SendNetworkString(ClientID, "215 - Atomic FTP Server v"+#Version+EOL$)
Return


 