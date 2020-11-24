
; IDirectPlay8Address interface definition
;
Interface IDirectPlay8Address
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  BuildFromURLW(a.l)
  BuildFromURLA(a.s)
  Duplicate(a.l)
  SetEqual(a.l)
  IsEqual(a.l)
  Clear()
  GetURLW(a.l, b.l)
  GetURLA(a.s, b.l)
  GetSP(a.l)
  GetUserData(a.l, b.l)
  SetSP(a.l)
  SetUserData(a.l, b.l)
  GetNumComponents(a.l)
  GetComponentByName(a.l, b.l, c.l, d.l)
  GetComponentByIndex(a.l, b.l, c.l, d.l, e.l, f.l)
  AddComponent(a.l, b.l, c.l, d.l)
  GetDevice(a.l)
  SetDevice(a.l)
  BuildFromDPADDRESS(a.l, b.l)
EndInterface

; IDirectPlay8AddressIP interface definition
;
Interface IDirectPlay8AddressIP
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  BuildFromSockAddr(a.l)
  BuildAddress(a.l, b.l)
  BuildLocalAddress(a.l, b.l)
  GetSockAddress(a.l, b.l)
  GetLocalAddress(a.l, b.l)
  GetAddress(a.l, b.l, c.l)
EndInterface
