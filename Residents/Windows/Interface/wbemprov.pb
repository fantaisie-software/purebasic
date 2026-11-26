
; IWbemPropertyProvider interface definition
;
Interface IWbemPropertyProvider Extends IUnknown
  GetProperty(a.l, b.l, c.l, d.l, e.l, f.l)
  PutProperty(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IWbemUnboundObjectSink interface definition
;
Interface IWbemUnboundObjectSink Extends IUnknown
  IndicateToConsumer(a.l, b.l, c.l)
EndInterface

; IWbemEventProvider interface definition
;
Interface IWbemEventProvider Extends IUnknown
  ProvideEvents(a.l, b.l)
EndInterface

; IWbemEventProviderQuerySink interface definition
;
Interface IWbemEventProviderQuerySink Extends IUnknown
  NewQuery(a.l, b.l, c.l)
  CancelQuery(a.l)
EndInterface

; IWbemEventProviderSecurity interface definition
;
Interface IWbemEventProviderSecurity Extends IUnknown
  AccessCheck(a.l, b.l, c.l, d.l)
EndInterface

; IWbemEventConsumerProvider interface definition
;
Interface IWbemEventConsumerProvider Extends IUnknown
  FindConsumer(a.l, b.l)
EndInterface

; IWbemProviderInitSink interface definition
;
Interface IWbemProviderInitSink Extends IUnknown
  SetStatus(a.l, b.l)
EndInterface

; IWbemProviderInit interface definition
;
Interface IWbemProviderInit Extends IUnknown
  Initialize(a.p-unicode, b.l, c.p-unicode, d.p-unicode, e.l, f.l, g.l)
EndInterface

; IWbemHiPerfProvider interface definition
;
Interface IWbemHiPerfProvider Extends IUnknown
  QueryInstances(a.l, b.l, c.l, d.l, e.l)
  CreateRefresher(a.l, b.l, c.l)
  CreateRefreshableObject(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  StopRefreshing(a.l, b.l, c.l)
  CreateRefreshableEnum(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetObjects(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IWbemDecoupledRegistrar interface definition
;
Interface IWbemDecoupledRegistrar Extends IUnknown
  Register(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  UnRegister()
EndInterface

; IWbemProviderIdentity interface definition
;
Interface IWbemProviderIdentity Extends IUnknown
  SetRegistrationObject(a.l, b.l)
EndInterface

; IWbemDecoupledBasicEventProvider interface definition
;
Interface IWbemDecoupledBasicEventProvider Extends IWbemDecoupledRegistrar
  GetSink(a.l, b.l, c.l)
  GetService(a.l, b.l, c.l)
EndInterface

; IWbemEventSink interface definition
;
Interface IWbemEventSink Extends IWbemObjectSink
  SetSinkSecurity(a.l, b.l)
  IsActive()
  GetRestrictedSink(a.l, b.l, c.l, d.l)
  SetBatchingParameters(a.l, b.l, c.l)
EndInterface
