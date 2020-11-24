
; IDirect3D interface definition
;
Interface IDirect3D
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  EnumDevices(a.l, b.l)
  CreateLight(a.l, b.l)
  CreateMaterial(a.l, b.l)
  CreateViewport(a.l, b.l)
  FindDevice(a.l, b.l)
EndInterface

; IDirect3D2 interface definition
;
Interface IDirect3D2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumDevices(a.l, b.l)
  CreateLight(a.l, b.l)
  CreateMaterial(a.l, b.l)
  CreateViewport(a.l, b.l)
  FindDevice(a.l, b.l)
  CreateDevice(a.l, b.l, c.l)
EndInterface

; IDirect3D3 interface definition
;
Interface IDirect3D3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumDevices(a.l, b.l)
  CreateLight(a.l, b.l)
  CreateMaterial(a.l, b.l)
  CreateViewport(a.l, b.l)
  FindDevice(a.l, b.l)
  CreateDevice(a.l, b.l, c.l, d.l)
  CreateVertexBuffer(a.l, b.l, c.l, d.l)
  EnumZBufferFormats(a.l, b.l, c.l)
  EvictManagedTextures()
EndInterface

; IDirect3D7 interface definition
;
Interface IDirect3D7
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  EnumDevices(a.l, b.l)
  CreateDevice(a.l, b.l, c.l)
  CreateVertexBuffer(a.l, b.l, c.l)
  EnumZBufferFormats(a.l, b.l, c.l)
  EvictManagedTextures()
EndInterface

; IDirect3DDevice interface definition
;
Interface IDirect3DDevice
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l)
  GetCaps(a.l, b.l)
  SwapTextureHandles(a.l, b.l)
  CreateExecuteBuffer(a.l, b.l, c.l)
  GetStats(a.l)
  Execute(a.l, b.l, c.l)
  AddViewport(a.l)
  DeleteViewport(a.l)
  NextViewport(a.l, b.l, c.l)
  Pick(a.l, b.l, c.l, d.l)
  GetPickRecords(a.l, b.l)
  EnumTextureFormats(a.l, b.l)
  CreateMatrix(a.l)
  SetMatrix(a.l, b.l)
  GetMatrix(a.l, b.l)
  DeleteMatrix(a.l)
  BeginScene()
  EndScene()
  GetDirect3D(a.l)
EndInterface

; IDirect3DDevice2 interface definition
;
Interface IDirect3DDevice2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l, b.l)
  SwapTextureHandles(a.l, b.l)
  GetStats(a.l)
  AddViewport(a.l)
  DeleteViewport(a.l)
  NextViewport(a.l, b.l, c.l)
  EnumTextureFormats(a.l, b.l)
  BeginScene()
  EndScene()
  GetDirect3D(a.l)
  SetCurrentViewport(a.l)
  GetCurrentViewport(a.l)
  SetRenderTarget(a.l, b.l)
  GetRenderTarget(a.l)
  Begin(a.l, b.l, c.l)
  BeginIndexed(a.l, b.l, c.l, d.l, e.l)
  Vertex(a.l)
  Index(a.l)
  End(a.l)
  GetRenderState(a.l, b.l)
  SetRenderState(a.l, b.l)
  GetLightState(a.l, b.l)
  SetLightState(a.l, b.l)
  SetTransform(a.l, b.l)
  GetTransform(a.l, b.l)
  MultiplyTransform(a.l, b.l)
  DrawPrimitive(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitive(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SetClipStatus(a.l)
  GetClipStatus(a.l)
EndInterface

; IDirect3DDevice3 interface definition
;
Interface IDirect3DDevice3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l, b.l)
  GetStats(a.l)
  AddViewport(a.l)
  DeleteViewport(a.l)
  NextViewport(a.l, b.l, c.l)
  EnumTextureFormats(a.l, b.l)
  BeginScene()
  EndScene()
  GetDirect3D(a.l)
  SetCurrentViewport(a.l)
  GetCurrentViewport(a.l)
  SetRenderTarget(a.l, b.l)
  GetRenderTarget(a.l)
  Begin(a.l, b.l, c.l)
  BeginIndexed(a.l, b.l, c.l, d.l, e.l)
  Vertex(a.l)
  Index(a.l)
  End(a.l)
  GetRenderState(a.l, b.l)
  SetRenderState(a.l, b.l)
  GetLightState(a.l, b.l)
  SetLightState(a.l, b.l)
  SetTransform(a.l, b.l)
  GetTransform(a.l, b.l)
  MultiplyTransform(a.l, b.l)
  DrawPrimitive(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitive(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SetClipStatus(a.l)
  GetClipStatus(a.l)
  DrawPrimitiveStrided(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitiveStrided(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  DrawPrimitiveVB(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitiveVB(a.l, b.l, c.l, d.l, e.l)
  ComputeSphereVisibility(a.l, b.f, c.l, d.l, e.l)
  GetTexture(a.l, b.l)
  SetTexture(a.l, b.l)
  GetTextureStageState(a.l, b.l, c.l)
  SetTextureStageState(a.l, b.l, c.l)
  ValidateDevice(a.l)
EndInterface

; IDirect3DDevice7 interface definition
;
Interface IDirect3DDevice7
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetCaps(a.l)
  EnumTextureFormats(a.l, b.l)
  BeginScene()
  EndScene()
  GetDirect3D(a.l)
  SetRenderTarget(a.l, b.l)
  GetRenderTarget(a.l)
  Clear(a.l, b.l, c.l, d.l, e.f, f.l)
  SetTransform(a.l, b.l)
  GetTransform(a.l, b.l)
  SetViewport(a.l)
  MultiplyTransform(a.l, b.l)
  GetViewport(a.l)
  SetMaterial(a.l)
  GetMaterial(a.l)
  SetLight(a.l, b.l)
  GetLight(a.l, b.l)
  SetRenderState(a.l, b.l)
  GetRenderState(a.l, b.l)
  BeginStateBlock()
  EndStateBlock(a.l)
  PreLoad(a.l)
  DrawPrimitive(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitive(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  SetClipStatus(a.l)
  GetClipStatus(a.l)
  DrawPrimitiveStrided(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitiveStrided(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  DrawPrimitiveVB(a.l, b.l, c.l, d.l, e.l)
  DrawIndexedPrimitiveVB(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  ComputeSphereVisibility(a.l, b.f, c.l, d.l, e.l)
  GetTexture(a.l, b.l)
  SetTexture(a.l, b.l)
  GetTextureStageState(a.l, b.l, c.l)
  SetTextureStageState(a.l, b.l, c.l)
  ValidateDevice(a.l)
  ApplyStateBlock(a.l)
  CaptureStateBlock(a.l)
  DeleteStateBlock(a.l)
  CreateStateBlock(a.l, b.l)
  Load(a.l, b.l, c.l, d.l, e.l)
  LightEnable(a.l, b.l)
  GetLightEnable(a.l, b.l)
  SetClipPlane(a.l, b.l)
  GetClipPlane(a.l, b.l)
  GetInfo(a.l, b.l, c.l)
EndInterface

; IDirect3DExecuteBuffer interface definition
;
Interface IDirect3DExecuteBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l)
  Lock(a.l)
  Unlock()
  SetExecuteData(a.l)
  GetExecuteData(a.l)
  Validate(a.l, b.l, c.l, d.l)
  Optimize(a.l)
EndInterface

; IDirect3DLight interface definition
;
Interface IDirect3DLight
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  SetLight(a.l)
  GetLight(a.l)
EndInterface

; IDirect3DMaterial interface definition
;
Interface IDirect3DMaterial
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  SetMaterial(a.l)
  GetMaterial(a.l)
  GetHandle(a.l, b.l)
  Reserve()
  Unreserve()
EndInterface

; IDirect3DMaterial2 interface definition
;
Interface IDirect3DMaterial2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetMaterial(a.l)
  GetMaterial(a.l)
  GetHandle(a.l, b.l)
EndInterface

; IDirect3DMaterial3 interface definition
;
Interface IDirect3DMaterial3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetMaterial(a.l)
  GetMaterial(a.l)
  GetHandle(a.l, b.l)
EndInterface

; IDirect3DTexture interface definition
;
Interface IDirect3DTexture
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l)
  GetHandle(a.l, b.l)
  PaletteChanged(a.l, b.l)
  Load(a.l)
  Unload()
EndInterface

; IDirect3DTexture2 interface definition
;
Interface IDirect3DTexture2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetHandle(a.l, b.l)
  PaletteChanged(a.l, b.l)
  Load(a.l)
EndInterface

; IDirect3DViewport interface definition
;
Interface IDirect3DViewport
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  GetViewport(a.l)
  SetViewport(a.l)
  TransformVertices(a.l, b.l, c.l, d.l)
  LightElements(a.l, b.l)
  SetBackground(a.l)
  GetBackground(a.l, b.l)
  SetBackgroundDepth(a.l)
  GetBackgroundDepth(a.l, b.l)
  Clear(a.l, b.l, c.l)
  AddLight(a.l)
  DeleteLight(a.l)
  NextLight(a.l, b.l, c.l)
EndInterface

; IDirect3DViewport2 interface definition
;
Interface IDirect3DViewport2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  GetViewport(a.l)
  SetViewport(a.l)
  TransformVertices(a.l, b.l, c.l, d.l)
  LightElements(a.l, b.l)
  SetBackground(a.l)
  GetBackground(a.l, b.l)
  SetBackgroundDepth(a.l)
  GetBackgroundDepth(a.l, b.l)
  Clear(a.l, b.l, c.l)
  AddLight(a.l)
  DeleteLight(a.l)
  NextLight(a.l, b.l, c.l)
  GetViewport2(a.l)
  SetViewport2(a.l)
EndInterface

; IDirect3DViewport3 interface definition
;
Interface IDirect3DViewport3
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l)
  GetViewport(a.l)
  SetViewport(a.l)
  TransformVertices(a.l, b.l, c.l, d.l)
  LightElements(a.l, b.l)
  SetBackground(a.l)
  GetBackground(a.l, b.l)
  SetBackgroundDepth(a.l)
  GetBackgroundDepth(a.l, b.l)
  Clear(a.l, b.l, c.l)
  AddLight(a.l)
  DeleteLight(a.l)
  NextLight(a.l, b.l, c.l)
  GetViewport2(a.l)
  SetViewport2(a.l)
  SetBackgroundDepth2(a.l)
  GetBackgroundDepth2(a.l, b.l)
  Clear2(a.l, b.l, c.l, d.l, e.f, f.l)
EndInterface

; IDirect3DVertexBuffer interface definition
;
Interface IDirect3DVertexBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Lock(a.l, b.l, c.l)
  Unlock()
  ProcessVertices(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetVertexBufferDesc(a.l)
  Optimize(a.l, b.l)
EndInterface

; IDirect3DVertexBuffer7 interface definition
;
Interface IDirect3DVertexBuffer7
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Lock(a.l, b.l, c.l)
  Unlock()
  ProcessVertices(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  GetVertexBufferDesc(a.l)
  Optimize(a.l, b.l)
  ProcessVerticesStrided(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
EndInterface
