
; IDirectPlayLobby interface definition
;
Interface IDirectPlayLobby
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l, c.l)
  CreateAddress(a.l, b.l, c.l, d.l, e.l, f.l)
  EnumAddress(a.l, b.l, c.l, d.l)
  EnumAddressTypes(a.l, b.l, c.l, d.l)
  EnumLocalApplications(a.l, b.l, c.l)
  GetConnectionSettings(a.l, b.l, c.l)
  ReceiveLobbyMessage(a.l, b.l, c.l, d.l, e.l)
  RunApplication(a.l, b.l, c.l, d.l)
  SendLobbyMessage(a.l, b.l, c.l, d.l)
  SetConnectionSettings(a.l, b.l, c.l)
  SetLobbyMessageEvent(a.l, b.l, c.l)
EndInterface

; IDirectPlayLobby2 interface definition
;
Interface IDirectPlayLobby2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l, c.l)
  CreateAddress(a.l, b.l, c.l, d.l, e.l, f.l)
  EnumAddress(a.l, b.l, c.l, d.l)
  EnumAddressTypes(a.l, b.l, c.l, d.l)
  EnumLocalApplications(a.l, b.l, c.l)
  GetConnectionSettings(a.l, b.l, c.l)
  ReceiveLobbyMessage(a.l, b.l, c.l, d.l, e.l)
  RunApplication(a.l, b.l, c.l, d.l)
  SendLobbyMessage(a.l, b.l, c.l, d.l)
  SetConnectionSettings(a.l, b.l, c.l)
  SetLobbyMessageEvent(a.l, b.l, c.l)
  CreateCompoundAddress(a.l, b.l, c.l, d.l)
EndInterface

; IDirectPlayLobby3 interface definition
;
Interface IDirectPlayLobby3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l, c.l)
  CreateAddress(a.l, b.l, c.l, d.l, e.l, f.l)
  EnumAddress(a.l, b.l, c.l, d.l)
  EnumAddressTypes(a.l, b.l, c.l, d.l)
  EnumLocalApplications(a.l, b.l, c.l)
  GetConnectionSettings(a.l, b.l, c.l)
  ReceiveLobbyMessage(a.l, b.l, c.l, d.l, e.l)
  RunApplication(a.l, b.l, c.l, d.l)
  SendLobbyMessage(a.l, b.l, c.l, d.l)
  SetConnectionSettings(a.l, b.l, c.l)
  SetLobbyMessageEvent(a.l, b.l, c.l)
  CreateCompoundAddress(a.l, b.l, c.l, d.l)
  ConnectEx(a.l, b.l, c.l, d.l)
  RegisterApplication(a.l, b.l)
  UnregisterApplication(a.l, b.l)
  WaitForConnectionSettings(a.l)
EndInterface
