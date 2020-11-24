
; IWbemTransport interface definition
;
Interface IWbemTransport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize()
EndInterface

; IWbemLevel1Login interface definition
;
Interface IWbemLevel1Login
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EstablishPosition(a.p-unicode, b.l, c.l)
  RequestChallenge(a.p-unicode, b.p-unicode, c.l)
  WBEMLogin(a.p-unicode, b.l, c.l, d.l, e.l)
  NTLMLogin(a.p-unicode, b.p-unicode, c.l, d.l, e.l)
EndInterface

; IWbemConnectorLogin interface definition
;
Interface IWbemConnectorLogin
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectorLogin(a.p-unicode, b.p-unicode, c.l, d.l, e.l, f.l)
EndInterface

; IWbemAddressResolution interface definition
;
Interface IWbemAddressResolution
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Resolve(a.p-unicode, b.p-unicode, c.l, d.l)
EndInterface

; IWbemClientTransport interface definition
;
Interface IWbemClientTransport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ConnectServer(a.p-bstr, b.l, c.l, d.p-bstr, e.p-bstr, f.p-bstr, g.p-bstr, h.l, i.p-bstr, j.l, k.l)
EndInterface

; IWbemClientConnectionTransport interface definition
;
Interface IWbemClientConnectionTransport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Open(a.p-bstr, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l, l.l)
  OpenAsync(a.p-bstr, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l, j.l, k.l)
  Cancel(a.l, b.l)
EndInterface

; IWbemConstructClassObject interface definition
;
Interface IWbemConstructClassObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetInheritanceChain(a.l, b.l)
  SetPropertyOrigin(a.l, b.l)
  SetMethodOrigin(a.l, b.l)
  SetServerNamespace(a.l, b.l)
EndInterface
