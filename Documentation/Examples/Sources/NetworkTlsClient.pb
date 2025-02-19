;
; ------------------------------------------------------------
;
;   PureBasic - TLS Client
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Note: NetworkTlsServer.pb must be launched before trying this code
;

UseNetworkTLS()

Connection = OpenNetworkConnection("127.0.0.1", 20252, #PB_Network_TCP | #PB_Network_IPv4 | #PB_Network_TLSv1_3)
If Connection
  *Buffer = AllocateMemory($FFFF, #PB_Memory_NoClear)
  If *Buffer
    Debug "Sending string"
    SendNetworkString(Connection, "GET / HTTP/1.1" + #CRLF$ + "Host: www.purebasic.fr" + #CRLF$ + #CRLF$)
    Debug "String Sent"
    Timeout = 100
    Repeat
      Select NetworkServerEvent()
          
      EndSelect
      
      Select NetworkClientEvent(Connection)
        Case #PB_NetworkEvent_Data
          Repeat
            Length = ReceiveNetworkData(Connection, *Buffer, MemorySize(*Buffer))
            If Length > 0
              Receive$ + PeekS(*Buffer, Length, #PB_UTF8 | #PB_ByteLength)
            EndIf
          Until Length = 0 Or (Length > 0 And Length <> MemorySize(*Buffer))
          Break
          
        Case #PB_NetworkEvent_Disconnect
          Debug "Disconnect"
          Break
          
        Case #PB_NetworkEvent_None
          Delay(10)
          Timeout - 1
          
      EndSelect
    Until Timeout = 0
    
    If Receive$ <> ""
      Debug Receive$
    EndIf
    
    FreeMemory(*Buffer)
  EndIf
  
  CloseNetworkConnection(Connection)
Else
  Debug "can't create the client"
EndIf
