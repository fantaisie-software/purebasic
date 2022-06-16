;
; ------------------------------------------------------------
;
;       Atomic FTP Server in PureBasic
;
;          (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; NOTE: This is a demo program, not suitable for production !
; Only very basic commands are implemented
;

#Version = "0.3"

ClientIP.s
Port = 21
BaseDirectory$    = "FTP/"
CurrentDirectory$ = BaseDirectory$

EOL$ = Chr(13)+Chr(10)

*Buffer = AllocateMemory(10000)

If CreateNetworkServer(0, Port, #PB_Network_IPv4 | #PB_Network_TCP, "127.0.0.1")

  OpenWindow(0, 100, 200, 320, 40, "Atomic FTP Server v"+#Version+" (127.0.0.1:"+Port+")")
  TextGadget(0, 10, 10, 300, 30, "Atomic FTP Server Ready.")
  
  Repeat
    
    ; Use a non-blocking event poll, to be able to check for the network server events
    ;
    Repeat
      Event = WindowEvent()

      Select Event 
        Case #PB_Event_CloseWindow 
          Quit = 1 
          
       EndSelect
    Until Event = 0
    
    ServerEvent = NetworkServerEvent()
    If ServerEvent
      ClientID = EventClient()
  
      Select ServerEvent
      
        Case #PB_NetworkEvent_Connect  ; New client connected
          SetGadgetText(0, "New client "+ClientID+"connected !")
          SendNetworkString(ClientID, "220 - Atomic FTP Server v"+#Version+" ready"+EOL$)

        Case #PB_NetworkEvent_Disconnect  ; Client has closed the connection
          SetGadgetText(0, "Client "+ClientID+" disconnected.")
          
        Case #PB_NetworkEvent_Data
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

  Command$ = PeekS(*Buffer, -1, #PB_UTF8)
  
  Position = FindString(Command$, " ", 1)
  If Position
    Argument$ = Mid(Command$, Position+1, Len(Command$)-Position)
    Command$ = UCase(RTrim(Left(Command$, Position-1)))
  EndIf
  
  Debug "Command: "+Command$
  SetGadgetText(0, "Last command: "+Command$)

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
      
    Case "TYPE"
      Gosub Command_TYPE

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
    
      NumberFiles = 0
      While NextDirectoryEntry(0)
        
        Select DirectoryEntryType(0) 
          Case #PB_DirectoryEntry_Directory
            a$ = a$+"drwxr-xr-x 6 1024 512 Jan 23 10:18 "+DirectoryEntryName(0)+EOL$
            NumberFiles+1
         
          Case #PB_DirectoryEntry_File
            a$ = a$+"-rwxr-xr-x 6 512 "+Str(DirectoryEntrySize(0))+" Jan 23 10:18 "+DirectoryEntryName(0)+EOL$
            NumberFiles+1
            
        EndSelect
      Wend
    EndIf
    
    SendNetworkString(FTPConnection, "total "+Str(NumberFiles)+EOL$+a$)
    CloseNetworkConnection(FTPConnection)
  Else
    Debug "Can't open the file listing connection"
  EndIf
  
  SendNetworkString(ClientID, "226 - Listing finished"+EOL$)
Return


Command_PASS:
  SendNetworkString(ClientID, "230 - Welcome, enjoy this FTP site"+EOL$)
Return
  
Command_TYPE:
  SendNetworkString(ClientID, "200 - Ok"+EOL$)
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

  ; Get the port
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


 