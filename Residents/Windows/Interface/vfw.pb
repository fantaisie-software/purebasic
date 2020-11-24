
; IAVIStream interface definition
;
Interface IAVIStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Create(a.l, b.l)
  Info(a.l, b.l)
  FindSample(a.l, b.l)
  ReadFormat(a.l, b.l, c.l)
  SetFormat(a.l, b.l, c.l)
  Read(a.l, b.l, c.l, d.l, e.l, f.l)
  Write(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  Delete(a.l, b.l)
  ReadData(a.l, b.l, c.l)
  WriteData(a.l, b.l, c.l)
  SetInfo(a.l, b.l)
  Reserved1()
  Reserved2()
  Reserved3()
  Reserved4()
  Reserved5()
EndInterface

; IAVIStreaming interface definition
;
Interface IAVIStreaming
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Begin(a.l, b.l, c.l)
  End()
EndInterface

; IAVIEditStream interface definition
;
Interface IAVIEditStream
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Cut(a.l, b.l, c.l)
  Copy(a.l, b.l, c.l)
  Paste(a.l, b.l, c.l, d.l, e.l)
  Clone(a.l)
  SetInfo(a.l, b.l)
EndInterface

; IAVIPersistFile interface definition
;
Interface IAVIPersistFile
  Reserved1()
EndInterface

; IAVIFile interface definition
;
Interface IAVIFile
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Info(a.l, b.l)
  GetStream(a.l, b.l, c.l)
  CreateStream(a.l, b.l)
  WriteData(a.l, b.l, c.l)
  ReadData(a.l, b.l, c.l)
  EndRecord()
  DeleteStream(a.l, b.l)
EndInterface

; IGetFrame interface definition
;
Interface IGetFrame
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFrame(a.l)
  Begin(a.l, b.l, c.l)
  End()
  SetFormat(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface
