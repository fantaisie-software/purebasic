
; IWbemPropertyProvider interface definition
;
Interface IWbemPropertyProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetProperty(a.l, b.l, c.l, d.l, e.l, f.l)
  PutProperty(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IWbemUnboundObjectSink interface definition
;
Interface IWbemUnboundObjectSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IndicateToConsumer(a.l, b.l, c.l)
EndInterface

; IWbemEventProvider interface definition
;
Interface IWbemEventProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ProvideEvents(a.l, b.l)
EndInterface

; IWbemEventProviderQuerySink interface definition
;
Interface IWbemEventProviderQuerySink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  NewQuery(a.l, b.l, c.l)
  CancelQuery(a.l)
EndInterface

; IWbemEventProviderSecurity interface definition
;
Interface IWbemEventProviderSecurity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AccessCheck(a.l, b.l, c.l, d.l)
EndInterface

; IWbemEventConsumerProvider interface definition
;
Interface IWbemEventConsumerProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FindConsumer(a.l, b.l)
EndInterface

; IWbemProviderInitSink interface definition
;
Interface IWbemProviderInitSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetStatus(a.l, b.l)
EndInterface

; IWbemProviderInit interface definition
;
Interface IWbemProviderInit
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.p-unicode, b.l, c.p-unicode, d.p-unicode, e.l, f.l, g.l)
EndInterface

; IWbemHiPerfProvider interface definition
;
Interface IWbemHiPerfProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryInstances(a.l, b.l, c.l, d.l, e.l)
  CreateRefresher(a.l, b.l, c.l)
  CreateRefreshableObject(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  StopRefreshing(a.l, b.l, c.l)
  CreateRefreshableEnum(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetObjects(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IWbemDecoupledRegistrar interface definition
;
Interface IWbemDecoupledRegistrar
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Register(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  UnRegister()
EndInterface

; IWbemProviderIdentity interface definition
;
Interface IWbemProviderIdentity
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRegistrationObject(a.l, b.l)
EndInterface

; IWbemDecoupledBasicEventProvider interface definition
;
Interface IWbemDecoupledBasicEventProvider
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Register(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  UnRegister()
  GetSink(a.l, b.l, c.l)
  GetService(a.l, b.l, c.l)
EndInterface

; IWbemEventSink interface definition
;
Interface IWbemEventSink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Indicate(a.l, b.l)
  SetStatus(a.l, b.l, c.p-bstr, d.l)
  SetSinkSecurity(a.l, b.l)
  IsActive()
  GetRestrictedSink(a.l, b.l, c.l, d.l)
  SetBatchingParameters(a.l, b.l, c.l)
EndInterface
