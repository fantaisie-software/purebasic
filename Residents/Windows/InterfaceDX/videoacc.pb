
; IAMVideoAcceleratorNotify interface definition
;
Interface IAMVideoAcceleratorNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetUncompSurfacesInfo(a.l, b.l)
  SetUncompSurfacesInfo(a.l)
  GetCreateVideoAcceleratorData(a.l, b.l, c.l)
EndInterface

; IAMVideoAccelerator interface definition
;
Interface IAMVideoAccelerator
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetVideoAcceleratorGUIDs(a.l, b.l)
  GetUncompFormatsSupported(a.l, b.l, c.l)
  GetInternalMemInfo(a.l, b.l, c.l)
  GetCompBufferInfo(a.l, b.l, c.l, d.l)
  GetInternalCompBufferInfo(a.l, b.l)
  BeginFrame(a.l)
  EndFrame(a.l)
  GetBuffer(a.l, b.l, c.l, d.l, e.l)
  ReleaseBuffer(a.l, b.l)
  Execute(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  QueryRenderStatus(a.l, b.l, c.l)
  DisplayFrame(a.l, b.l)
EndInterface
