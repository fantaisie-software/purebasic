
; IDirectPlay8LobbyClient interface definition
;
Interface IDirectPlay8LobbyClient
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l)
  EnumLocalPrograms(a.l, b.l, c.l, d.l, e.l)
  ConnectApplication(a.l, b.l, c.l, d.l, e.l)
  Send(a.l, b.l, c.l, d.l)
  ReleaseApplication(a.l, b.l)
  Close(a.l)
  GetConnectionSettings(a.l, b.l, c.l, d.l)
  SetConnectionSettings(a.l, b.l, c.l)
EndInterface

; IDirectPlay8LobbiedApplication interface definition
;
Interface IDirectPlay8LobbiedApplication
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l, d.l)
  RegisterProgram(a.l, b.l)
  UnRegisterProgram(a.l, b.l)
  Send(a.l, b.l, c.l, d.l)
  SetAppAvailable(a.l, b.l)
  UpdateStatus(a.l, b.l, c.l)
  Close(a.l)
  GetConnectionSettings(a.l, b.l, c.l, d.l)
  SetConnectionSettings(a.l, b.l, c.l)
EndInterface
