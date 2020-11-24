
; IDXBaseObject interface definition
;
Interface IDXBaseObject
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetGenerationId(a.l)
  IncrementGenerationId(a.l)
  GetObjectSize(a.l)
EndInterface

; IDXTransformFactory interface definition
;
Interface IDXTransformFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryService(a.l, b.l, c.l)
  SetService(a.l, b.l, c.l)
  CreateTransform(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  InitializeTransform(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface

; IDXTransform interface definition
;
Interface IDXTransform
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetGenerationId(a.l)
  IncrementGenerationId(a.l)
  GetObjectSize(a.l)
  Setup(a.l, b.l, c.l, d.l, e.l)
  Execute(a.l, b.l, c.l)
  MapBoundsIn2Out(a.l, b.l, c.l, d.l)
  MapBoundsOut2In(a.l, b.l, c.l, d.l)
  SetMiscFlags(a.l)
  GetMiscFlags(a.l)
  GetInOutInfo(a.l, b.l, c.l, d.l, e.l, f.l)
  SetQuality(a.f)
  GetQuality(a.l)
EndInterface

; IDXSurfacePick interface definition
;
Interface IDXSurfacePick
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  PointPick(a.l, b.l, c.l)
EndInterface

; IDXTBindHost interface definition
;
Interface IDXTBindHost
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetBindHost(a.l)
EndInterface

; IDXTaskManager interface definition
;
Interface IDXTaskManager
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryNumProcessors(a.l)
  SetThreadPoolSize(a.l)
  GetThreadPoolSize(a.l)
  SetConcurrencyLimit(a.l)
  GetConcurrencyLimit(a.l)
  ScheduleTasks(a.l, b.l, c.l, d.l, e.l)
  TerminateTasks(a.l, b.l, c.l)
  TerminateRequest(a.l, b.l)
EndInterface

; IDXSurfaceFactory interface definition
;
Interface IDXSurfaceFactory
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateSurface(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CreateFromDDSurface(a.l, b.l, c.l, d.l, e.l, f.l)
  LoadImage(a.l, b.l, c.l, d.l, e.l, f.l)
  LoadImageFromStream(a.l, b.l, c.l, d.l, e.l, f.l)
  CopySurfaceToNewFormat(a.l, b.l, c.l, d.l, e.l)
  CreateD3DRMTexture(a.l, b.l, c.l, d.l, e.l)
  BitBlt(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IDXSurfaceModifier interface definition
;
Interface IDXSurfaceModifier
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetFillColor(a.l)
  GetFillColor(a.l)
  SetBounds(a.l)
  SetBackground(a.l)
  GetBackground(a.l)
  SetCompositeOperation(a.l)
  GetCompositeOperation(a.l)
  SetForeground(a.l, b.l, c.l)
  GetForeground(a.l, b.l, c.l)
  SetOpacity(a.f)
  GetOpacity(a.l)
  SetLookup(a.l)
  GetLookup(a.l)
EndInterface

; IDXSurface interface definition
;
Interface IDXSurface
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetGenerationId(a.l)
  IncrementGenerationId(a.l)
  GetObjectSize(a.l)
  GetPixelFormat(a.l, b.l)
  GetBounds(a.l)
  GetStatusFlags(a.l)
  SetStatusFlags(a.l)
  LockSurface(a.l, b.l, c.l, d.l, e.l, f.l)
  GetDirectDrawSurface(a.l, b.l)
  GetColorKey(a.l)
  SetColorKey(a.l)
  LockSurfaceDC(a.l, b.l, c.l, d.l)
  SetAppData(a.l)
  GetAppData(a.l)
EndInterface

; IDXSurfaceInit interface definition
;
Interface IDXSurfaceInit
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitSurface(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IDXARGBSurfaceInit interface definition
;
Interface IDXARGBSurfaceInit
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitSurface(a.l, b.l, c.l, d.l, e.l)
  InitFromDDSurface(a.l, b.l, c.l)
  InitFromRawSurface(a.l)
EndInterface

; IDXARGBReadPtr interface definition
;
Interface IDXARGBReadPtr
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSurface(a.l, b.l)
  GetNativeType(a.l)
  Move(a.l)
  MoveToRow(a.l)
  MoveToXY(a.l, b.l)
  MoveAndGetRunInfo(a.l, b.l)
  Unpack(a.l, b.l, c.l)
  UnpackPremult(a.l, b.l, c.l)
  UnpackRect(a.l)
EndInterface

; IDXARGBReadWritePtr interface definition
;
Interface IDXARGBReadWritePtr
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSurface(a.l, b.l)
  GetNativeType(a.l)
  Move(a.l)
  MoveToRow(a.l)
  MoveToXY(a.l, b.l)
  MoveAndGetRunInfo(a.l, b.l)
  Unpack(a.l, b.l, c.l)
  UnpackPremult(a.l, b.l, c.l)
  UnpackRect(a.l)
  PackAndMove(a.l, b.l)
  PackPremultAndMove(a.l, b.l)
  PackRect(a.l)
  CopyAndMoveBoth(a.l, b.l, c.l, d.l)
  CopyRect(a.l, b.l, c.l, d.l, e.l)
  FillAndMove(a.l, b.l, c.l, d.l)
  FillRect(a.l, b.l, c.l)
  OverSample(a.l)
  OverArrayAndMove(a.l, b.l, c.l)
EndInterface

; IDXDCLock interface definition
;
Interface IDXDCLock
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDC()
EndInterface

; IDXTScaleOutput interface definition
;
Interface IDXTScaleOutput
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetOutputSize(a.l, b.l)
EndInterface

; IDXGradient interface definition
;
Interface IDXGradient
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetOutputSize(a.l, b.l)
  SetGradient(a.l, b.l, c.l)
  GetOutputSize(a.l)
EndInterface

; IDXTScale interface definition
;
Interface IDXTScale
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetScales(a.f)
  GetScales(a.f)
  ScaleFitToSize(a.l, b.l, c.l)
EndInterface

; IDXEffect interface definition
;
Interface IDXEffect
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Capabilities(a.l)
  get_Progress(a.l)
  put_Progress(a.f)
  get_StepResolution(a.l)
  get_Duration(a.l)
  put_Duration(a.f)
EndInterface

; IDXLookupTable interface definition
;
Interface IDXLookupTable
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetGenerationId(a.l)
  IncrementGenerationId(a.l)
  GetObjectSize(a.l)
  GetTables(a.l, b.l, c.l, d.l)
  IsChannelIdentity(a.l)
  GetIndexValues(a.l, b.l)
  ApplyTables(a.l, b.l)
EndInterface

; IDXRawSurface interface definition
;
Interface IDXRawSurface
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetSurfaceInfo(a.l)
EndInterface

; IHTMLDXTransform interface definition
;
Interface IHTMLDXTransform
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetHostUrl(a.p-bstr)
EndInterface

; ICSSFilterDispatch interface definition
;
Interface ICSSFilterDispatch
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_Percent(a.l)
  put_Percent(a.f)
  get_Duration(a.l)
  put_Duration(a.f)
  get_Enabled(a.l)
  put_Enabled(a.l)
  get_Status(a.l)
  Apply()
  Play(a.p-variant)
  Stop()
EndInterface
