
; IDummy interface definition
;
Interface IDummy Extends IUnknown
EndInterface

; ITLocalParticipant interface definition
;
Interface ITLocalParticipant Extends IDispatch
  get_LocalParticipantTypedInfo(a.l, b.l)
  put_LocalParticipantTypedInfo(a.l, b.p-bstr)
EndInterface

; IEnumParticipant interface definition
;
Interface IEnumParticipant Extends IUnknown
  Next(a.l, b.l, c.l)
  Reset()
  Skip(a.l)
  Clone(a.l)
EndInterface

; ITParticipantControl interface definition
;
Interface ITParticipantControl Extends IDispatch
  EnumerateParticipants(a.l)
  get_Participants(a.l)
EndInterface

; ITParticipantSubStreamControl interface definition
;
Interface ITParticipantSubStreamControl Extends IDispatch
  get_SubStreamFromParticipant(a.l, b.l)
  get_ParticipantFromSubStream(a.l, b.l)
  SwitchTerminalToSubStream(a.l, b.l)
EndInterface

; ITParticipantEvent interface definition
;
Interface ITParticipantEvent Extends IDispatch
  get_Event(a.l)
  get_Participant(a.l)
  get_SubStream(a.l)
EndInterface

; IMulticastControl interface definition
;
Interface IMulticastControl Extends IDispatch
  get_LoopbackMode(a.l)
  put_LoopbackMode(a.l)
EndInterface
