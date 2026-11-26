
; INotifyReplica interface definition
;
Interface INotifyReplica Extends IUnknown
  YouAreAReplica(a.l, b.l)
EndInterface

; IReconcileInitiator interface definition
;
Interface IReconcileInitiator Extends IUnknown
  SetAbortCallback(a.l)
  SetProgressFeedback(a.l, b.l)
EndInterface

; IReconcilableObject interface definition
;
Interface IReconcilableObject Extends IUnknown
  Reconcile(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  GetProgressFeedbackMaxEstimate(a.l)
EndInterface

; IBriefcaseInitiator interface definition
;
Interface IBriefcaseInitiator Extends IUnknown
  IsMonikerInBriefcase(a.l)
EndInterface
