;
; ------------------------------------------------------------
;
;       Atomic Web Server in PureBasic
;
;          (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitNetwork() = 0
  MessageRequester("Error", "Can't initialize the network !", 0)
  End
EndIf

Port = 80
BaseDirectory$ = "www/"
DefaultPage$   = "Index.html"
AtomicTitle$   = "Atomic Web Server v1.0"

Global EOL$

EOL$ = Chr(13)+Chr(10)

*Buffer = AllocateMemory(10000)

If CreateNetworkServer(0, Port)

  OpenWindow(0, 100, 200, 230, 0, "Atomic Web Server (Port "+Str(Port)+")")
  
  Repeat
    
    Repeat
      WEvent = WindowEvent()

      If WEvent = #PB_Event_CloseWindow : Quit = 1 : EndIf
    Until WEvent = 0
    
    SEvent = NetworkServerEvent()
  
    If SEvent
      ClientID = EventClient()
  
      Select SEvent
      
        Case 1  ; When a new client has been connected...
          
        Case 4  ; When a client has closed the connection...
  
        Default
          RequestLength = ReceiveNetworkData(ClientID, *Buffer, 2000)
          Gosub ProcessRequest
          
      EndSelect

    Else
      Delay(20)  ; Don't stole the whole CPU !
    EndIf
    
  Until Quit = 1 
    
  CloseNetworkServer(0)
Else
  MessageRequester(AtomicTitle$, "Error: can't create the server (port in use ?).", 0)
EndIf
  
End 



Procedure.l BuildRequestHeader(*Buffer, DataLength, ContentType$)

  Length = PokeS(*Buffer, "HTTP/1.1 200 OK"+EOL$, -1, #PB_UTF8)                     : *Buffer+Length
  Length = PokeS(*Buffer, "Date: Wed, 11 Fec 2017 11:15:43 GMT"+EOL$, -1, #PB_UTF8) : *Buffer+Length
  Length = PokeS(*Buffer, "Server: Atomic Web Server 0.2b"+EOL$, -1, #PB_UTF8)      : *Buffer+Length
  Length = PokeS(*Buffer, "Content-Length: "+Str(DataLength)+EOL$, -1, #PB_UTF8)    : *Buffer+Length
  Length = PokeS(*Buffer, "Content-Type: "+ContentType$+EOL$, -1, #PB_UTF8)         : *Buffer+Length
  Length = PokeS(*Buffer, #CRLF$, -1, #PB_UTF8)                                     : *Buffer+Length

  ; Length = PokeS(*Buffer, "Last-modified: Thu, 27 Jun 1996 16:40:50 GMT"+Chr(13)+Chr(10), -1, #PB_UTF8) : *Buffer+Length
  ; Length = PokeS(*Buffer, "Accept-Ranges: bytes"+EOL$, -1, #PB_UTF8) : *Buffer+Length
  ; Length = PokeS(*Buffer, "Connection: close"+EOL$, -1, #PB_UTF8) : *Buffer+Length

  ProcedureReturn *Buffer
EndProcedure


ProcessRequest:

  a$ = PeekS(*Buffer, -1, #PB_UTF8)
  
  If Left(a$, 3) = "GET"

    MaxPosition = FindString(a$, Chr(13), 5)
    Position = FindString(a$, " ", 5)
    If Position < MaxPosition
      RequestedFile$ = Mid(a$, 6, Position-5)      ; Automatically remove the leading '/'
      RequestedFile$ = RTrim(RequestedFile$)
    Else
      RequestedFile$ = Mid(a$, 6, MaxPosition-5)   ; When a command like 'GET /' is sent..
    EndIf

      ; The following routine transforme all '/' in '\' (Windows format)
      ;
      Structure tmp
        a.b
      EndStructure

      If RequestedFile$ = ""
        RequestedFile$ = DefaultPage$
      Else
        *t.tmp = @RequestedFile$
        While *t\a <> 0
          If *t\a = '/' : *t\a = '\' : EndIf
          *t+1
        Wend
      EndIf

      ; Test if the file exists, and if not display the error message
      ;   

      If ReadFile(0, BaseDirectory$+RequestedFile$, #PB_UTF8)
      
        FileLength = Lof(0)

        Select Right(RequestedFile$,4)
          Case ".gif"
            ContentType$ = "image/gif"

          Case ".jpg"
            ContentType$ = "image/jpeg"

          Case ".txt"
            ContentType$ = "text/plain"

          Case ".zip"
            ContentType$ = "application/zip"

          Default
            ContentType$ = "text/html"

        EndSelect
        
        *FileBuffer   = AllocateMemory(FileLength+200)
        *BufferOffset = BuildRequestHeader(*FileBuffer, FileLength, ContentType$)

        ReadData(0, *BufferOffset, FileLength)

        CloseFile(0)
 
        SendNetworkData(ClientID, *FileBuffer, *BufferOffset-*FileBuffer+FileLength)
        
        FreeMemory(*FileBuffer)
      Else
        If ReadFile(0, BaseDirectory$+"AtomicWebServer_Error.html")
          FileLength = Lof(0)
          ContentType$ = "text/html"

          *FileBuffer   = AllocateMemory(FileLength+200)
          *BufferOffset = BuildRequestHeader(*FileBuffer, FileLength, ContentType$)

          ReadData(0, *BufferOffset, FileLength)
          CloseFile(0)
   
          SendNetworkData(ClientID, *FileBuffer, *BufferOffset-*FileBuffer+FileLength)
          FreeMemory(*FileBuffer)
        EndIf
      EndIf
  EndIf

Return
