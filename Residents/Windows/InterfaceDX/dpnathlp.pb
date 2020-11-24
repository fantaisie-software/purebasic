
; IDirectPlayNATHelp interface definition
;
Interface IDirectPlayNATHelp
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  Close(a.l)
  GetCaps(a.l, b.l)
  RegisterPorts(a.l, b.l, c.l, d.l, e.l, f.l)
  GetRegisteredAddresses(a.l, b.l, c.l, d.l, e.l, f.l)
  DeregisterPorts(a.l, b.l)
  QueryAddress(a.l, b.l, c.l, d.l, e.l)
  SetAlertEvent(a.l, b.l)
  SetAlertIOCompletionPort(a.l, b.l, c.l, d.l)
  ExtendRegisteredPortsLease(a.l, b.l, c.l)
EndInterface
