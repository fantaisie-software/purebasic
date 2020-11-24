
; IMpeg2Data interface definition
;
Interface IMpeg2Data
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSection(a.l, b.l, c.l, d.l, e.l)
  GetTable(a.l, b.l, c.l, d.l, e.l)
  GetStreamOfSections(a.l, b.l, c.l, d.l, e.l)
EndInterface

; ISectionList interface definition
;
Interface ISectionList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  InitializeWithRawSections(a.l)
  CancelPendingRequest()
  GetNumberOfSections(a.l)
  GetSectionData(a.l, b.l, c.l)
  GetProgramIdentifier(a.l)
  GetTableIdentifier(a.l)
EndInterface

; IMpeg2Stream interface definition
;
Interface IMpeg2Stream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SupplyDataBuffer(a.l)
EndInterface
