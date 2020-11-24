
; IDelaydC interface definition
;
Interface IDelaydC
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l, c.l, d.l)
  Disconnect()
  QueryStatus(a.l)
  Configure(a.l, b.l)
  Start(a.l)
  Pause()
  Resume()
  Stop(a.l)
  GetControlState(a.l, b.l)
  GetTotalStatistics(a.l, b.l)
  GetConversationStatistics(a.l, b.l, c.l, d.l, e.l)
  InsertSpecialFrame(a.l, b.l, c.l, d.l)
  QueryStations(a.l)
EndInterface

; IRTC interface definition
;
Interface IRTC
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l, c.l, d.l, e.l)
  Disconnect()
  QueryStatus(a.l)
  Configure(a.l, b.l)
  Start()
  Pause()
  Resume()
  Stop()
  GetControlState(a.l, b.l)
  GetTotalStatistics(a.l, b.l)
  GetConversationStatistics(a.l, b.l, c.l, d.l, e.l)
  InsertSpecialFrame(a.l, b.l, c.l, d.l)
  QueryStations(a.l)
EndInterface

; IStats interface definition
;
Interface IStats
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Connect(a.l, b.l, c.l, d.l)
  Disconnect()
  QueryStatus(a.l)
  Configure(a.l, b.l)
  Start()
  Pause()
  Resume()
  Stop()
  GetControlState(a.l, b.l)
  GetTotalStatistics(a.l, b.l)
  GetConversationStatistics(a.l, b.l, c.l, d.l, e.l)
  InsertSpecialFrame(a.l, b.l, c.l, d.l)
  QueryStations(a.l)
EndInterface
