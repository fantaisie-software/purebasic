
; IDummy interface definition
;
Interface IDummy
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
EndInterface

; ITLocalParticipant interface definition
;
Interface ITLocalParticipant
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_LocalParticipantTypedInfo(a.l, b.l)
  put_LocalParticipantTypedInfo(a.l, b.p-bstr)
EndInterface

; IEnumParticipant interface definition
;
Interface IEnumParticipant
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITParticipantControl interface definition
;
Interface ITParticipantControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  EnumerateParticipants(a.l)
  get_Participants(a.l)
EndInterface

; ITParticipantSubStreamControl interface definition
;
Interface ITParticipantSubStreamControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_SubStreamFromParticipant(a.l, b.l)
  get_ParticipantFromSubStream(a.l, b.l)
  SwitchTerminalToSubStream(a.l, b.l)
EndInterface

; ITParticipantEvent interface definition
;
Interface ITParticipantEvent
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Event(a.l)
  get_Participant(a.l)
  get_SubStream(a.l)
EndInterface

; IMulticastControl interface definition
;
Interface IMulticastControl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_LoopbackMode(a.l)
  put_LoopbackMode(a.l)
EndInterface
