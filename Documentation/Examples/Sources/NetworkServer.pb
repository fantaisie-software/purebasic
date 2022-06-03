;
; ------------------------------------------------------------
;
;   PureBasic - Network (Server) example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Note: run the NetworkClient.pb file to send some data to this server
;

Port = 6832
*Buffer = AllocateMemory(1000)

If CreateNetworkServer(0, Port, #PB_Network_IPv4 | #PB_Network_TCP, "127.0.0.1")

  MessageRequester("PureBasic - Server", "Server created (Port "+Port+").", 0)
  
  Repeat
      
    ServerEvent = NetworkServerEvent()
  
    If ServerEvent
    
      ClientID = EventClient()
  
      Select ServerEvent
      
        Case #PB_NetworkEvent_Connect
          MessageRequester("PureBasic - Server", "A new client has connected !", 0)
  
        Case #PB_NetworkEvent_Data
          MessageRequester("PureBasic - Server", "Client "+ClientID+" has send a packet !", 0)
          ReceiveNetworkData(ClientID, *Buffer, 1000)
          MessageRequester("Info", "String: "+PeekS(*Buffer, -1, #PB_UTF8), 0)
  
        Case #PB_NetworkEvent_Disconnect
          MessageRequester("PureBasic - Server", "Client "+ClientID+" has closed the connection...", 0)
          Quit = 1
    
      EndSelect
    EndIf
    
  Until Quit = 1
  
  MessageRequester("PureBasic - Server", "Click to quit the server.", 0)
  
  CloseNetworkServer(0)
Else
  MessageRequester("Error", "Can't create the server (port in use ?).", 0)
EndIf

  
End

