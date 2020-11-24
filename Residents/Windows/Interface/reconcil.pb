
; INotifyReplica interface definition
;
Interface INotifyReplica
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  YouAreAReplica(a.l, b.l)
EndInterface

; IReconcileInitiator interface definition
;
Interface IReconcileInitiator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAbortCallback(a.l)
  SetProgressFeedback(a.l, b.l)
EndInterface

; IReconcilableObject interface definition
;
Interface IReconcilableObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Reconcile(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  GetProgressFeedbackMaxEstimate(a.l)
EndInterface

; IBriefcaseInitiator interface definition
;
Interface IBriefcaseInitiator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsMonikerInBriefcase(a.l)
EndInterface
