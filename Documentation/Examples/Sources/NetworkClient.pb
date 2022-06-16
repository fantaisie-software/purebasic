;
; ------------------------------------------------------------
;
;   PureBasic - Network (Client) example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; Note: run the NetworkServer.pb file first to launch the server
;

Port = 6832

ConnectionID = OpenNetworkConnection("127.0.0.1", Port)
If ConnectionID
  MessageRequester("PureBasic - Client", "Client connected to server...", 0)
  
  SendNetworkString(ConnectionID, "An hello from a client !!! :-)", #PB_UTF8)
    
  MessageRequester("PureBasic - Client", "A string has been sent to the server, please check it before quit...", 0)
  
  CloseNetworkConnection(ConnectionID)
Else
  MessageRequester("PureBasic - Client", "Can't find the server (Is it launched ?).", 0)
EndIf
  
End