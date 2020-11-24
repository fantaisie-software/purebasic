
; IDirect3D9 interface definition
;
Interface IDirect3D9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RegisterSoftwareDevice(a.l)
  GetAdapterCount()
  GetAdapterIdentifier(a.l, b.l, c.l)
  GetAdapterModeCount(a.l, b.l)
  EnumAdapterModes(a.l, b.l, c.l, d.l)
  GetAdapterDisplayMode(a.l, b.l)
  CheckDeviceType(a.l, b.l, c.l, d.l, e.l)
  CheckDeviceFormat(a.l, b.l, c.l, d.l, e.l, f.l)
  CheckDeviceMultiSampleType(a.l, b.l, c.l, d.l, e.l, f.l)
  CheckDepthStencilMatch(a.l, b.l, c.l, d.l, e.l)
  CheckDeviceFormatConversion(a.l, b.l, c.l, d.l)
  GetDeviceCaps(a.l, b.l, c.l)
  GetAdapterMonitor(a.l)
  CreateDevice(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IDirect3DDevice9 interface definition
;
Interface IDirect3DDevice9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  TestCooperativeLevel()
  GetAvailableTextureMem()
  EvictManagedResources()
  GetDirect3D(a.l)
  GetDeviceCaps(a.l)
  GetDisplayMode(a.l, b.l)
  GetCreationParameters(a.l)
  SetCursorProperties(a.l, b.l, c.l)
  SetCursorPosition(a.l, b.l, c.l)
  ShowCursor(a.l)
  CreateAdditionalSwapChain(a.l, b.l)
  GetSwapChain(a.l, b.l)
  GetNumberOfSwapChains()
  Reset(a.l)
  Present(a.l, b.l, c.l, d.l)
  GetBackBuffer(a.l, b.l, c.l, d.l)
  GetRasterStatus(a.l, b.l)
  SetDialogBoxMode(a.l)
  SetGammaRamp(a.l, b.l, c.l)
  GetGammaRamp(a.l, b.l)
  CreateTexture(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CreateVolumeTexture(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  CreateCubeTexture(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  CreateVertexBuffer(a.l, b.l, c.l, d.l, e.l, f.l)
  CreateIndexBuffer(a.l, b.l, c.l, d.l, e.l, f.l)
  CreateRenderTarget(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  CreateDepthStencilSurface(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  UpdateSurface(a.l, b.l, c.l, d.l)
  UpdateTexture(a.l, b.l)
  GetRenderTargetData(a.l, b.l)
  GetFrontBufferData(a.l, b.l)
  StretchRect(a.l, b.l, c.l, d.l, e.l)
  ColorFill(a.l, b.l, c.l)
  CreateOffscreenPlainSurface(a.l, b.l, c.l, d.l, e.l, f.l)
  SetRenderTarget(a.l, b.l)
  GetRenderTarget(a.l, b.l)
  SetDepthStencilSurface(a.l)
  GetDepthStencilSurface(a.l)
  BeginScene()
  EndScene()
  Clear(a.l, b.l, c.l, d.l, e.f, f.l)
  SetTransform(a.l, b.l)
  GetTransform(a.l, b.l)
  MultiplyTransform(a.l, b.l)
  SetViewport(a.l)
  GetViewport(a.l)
  SetMaterial(a.l)
  GetMaterial(a.l)
  SetLight(a.l, b.l)
  GetLight(a.l, b.l)
  LightEnable(a.l, b.l)
  GetLightEnable(a.l, b.l)
  SetClipPlane(a.l, b.l)
  GetClipPlane(a.l, b.l)
  SetRenderState(a.l, b.l)
  GetRenderState(a.l, b.l)
  CreateStateBlock(a.l, b.l)
  BeginStateBlock()
  EndStateBlock(a.l)
  SetClipStatus(a.l)
  GetClipStatus(a.l)
  GetTexture(a.l, b.l)
  SetTexture(a.l, b.l)
  GetTextureStageState(a.l, b.l, c.l)
  SetTextureStageState(a.l, b.l, c.l)
  GetSamplerState(a.l, b.l, c.l)
  SetSamplerState(a.l, b.l, c.l)
  ValidateDevice(a.l)
  SetPaletteEntries(a.l, b.l)
  GetPaletteEntries(a.l, b.l)
  SetCurrentTexturePalette(a.l)
  GetCurrentTexturePalette(a.l)
  SetScissorRect(a.l)
  GetScissorRect(a.l)
  SetSoftwareVertexProcessing(a.l)
  GetSoftwareVertexProcessing()
  SetNPatchMode(a.f)
  GetNPatchMode()
  DrawPrimitive(a.l, b.l, c.l)
  DrawIndexedPrimitive(a.l, b.l, c.l, d.l, e.l, f.l)
  DrawPrimitiveUP(a.l, b.l, c.l, d.l)
  DrawIndexedPrimitiveUP(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  ProcessVertices(a.l, b.l, c.l, d.l, e.l, f.l)
  CreateVertexDeclaration(a.l, b.l)
  SetVertexDeclaration(a.l)
  GetVertexDeclaration(a.l)
  SetFVF(a.l)
  GetFVF(a.l)
  CreateVertexShader(a.l, b.l)
  SetVertexShader(a.l)
  GetVertexShader(a.l)
  SetVertexShaderConstantF(a.l, b.l, c.l)
  GetVertexShaderConstantF(a.l, b.l, c.l)
  SetVertexShaderConstantI(a.l, b.l, c.l)
  GetVertexShaderConstantI(a.l, b.l, c.l)
  SetVertexShaderConstantB(a.l, b.l, c.l)
  GetVertexShaderConstantB(a.l, b.l, c.l)
  SetStreamSource(a.l, b.l, c.l, d.l)
  GetStreamSource(a.l, b.l, c.l, d.l)
  SetStreamSourceFreq(a.l, b.l)
  GetStreamSourceFreq(a.l, b.l)
  SetIndices(a.l)
  GetIndices(a.l)
  CreatePixelShader(a.l, b.l)
  SetPixelShader(a.l)
  GetPixelShader(a.l)
  SetPixelShaderConstantF(a.l, b.l, c.l)
  GetPixelShaderConstantF(a.l, b.l, c.l)
  SetPixelShaderConstantI(a.l, b.l, c.l)
  GetPixelShaderConstantI(a.l, b.l, c.l)
  SetPixelShaderConstantB(a.l, b.l, c.l)
  GetPixelShaderConstantB(a.l, b.l, c.l)
  DrawRectPatch(a.l, b.l, c.l)
  DrawTriPatch(a.l, b.l, c.l)
  DeletePatch(a.l)
  CreateQuery(a.l, b.l)
EndInterface

; IDirect3DStateBlock9 interface definition
;
Interface IDirect3DStateBlock9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  Capture()
  Apply()
EndInterface

; IDirect3DSwapChain9 interface definition
;
Interface IDirect3DSwapChain9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Present(a.l, b.l, c.l, d.l, e.l)
  GetFrontBufferData(a.l)
  GetBackBuffer(a.l, b.l, c.l)
  GetRasterStatus(a.l)
  GetDisplayMode(a.l)
  GetDevice(a.l)
  GetPresentParameters(a.l)
EndInterface

; IDirect3DResource9 interface definition
;
Interface IDirect3DResource9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
EndInterface

; IDirect3DVertexDeclaration9 interface definition
;
Interface IDirect3DVertexDeclaration9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetDeclaration(a.l, b.l)
EndInterface

; IDirect3DVertexShader9 interface definition
;
Interface IDirect3DVertexShader9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetFunction(a.l, b.l)
EndInterface

; IDirect3DPixelShader9 interface definition
;
Interface IDirect3DPixelShader9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetFunction(a.l, b.l)
EndInterface

; IDirect3DBaseTexture9 interface definition
;
Interface IDirect3DBaseTexture9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  SetLOD(a.l)
  GetLOD()
  GetLevelCount()
  SetAutoGenFilterType(a.l)
  GetAutoGenFilterType()
  GenerateMipSubLevels()
EndInterface

; IDirect3DTexture9 interface definition
;
Interface IDirect3DTexture9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  SetLOD(a.l)
  GetLOD()
  GetLevelCount()
  SetAutoGenFilterType(a.l)
  GetAutoGenFilterType()
  GenerateMipSubLevels()
  GetLevelDesc(a.l, b.l)
  GetSurfaceLevel(a.l, b.l)
  LockRect(a.l, b.l, c.l, d.l)
  UnlockRect(a.l)
  AddDirtyRect(a.l)
EndInterface

; IDirect3DVolumeTexture9 interface definition
;
Interface IDirect3DVolumeTexture9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  SetLOD(a.l)
  GetLOD()
  GetLevelCount()
  SetAutoGenFilterType(a.l)
  GetAutoGenFilterType()
  GenerateMipSubLevels()
  GetLevelDesc(a.l, b.l)
  GetVolumeLevel(a.l, b.l)
  LockBox(a.l, b.l, c.l, d.l)
  UnlockBox(a.l)
  AddDirtyBox(a.l)
EndInterface

; IDirect3DCubeTexture9 interface definition
;
Interface IDirect3DCubeTexture9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  SetLOD(a.l)
  GetLOD()
  GetLevelCount()
  SetAutoGenFilterType(a.l)
  GetAutoGenFilterType()
  GenerateMipSubLevels()
  GetLevelDesc(a.l, b.l)
  GetCubeMapSurface(a.l, b.l, c.l)
  LockRect(a.l, b.l, c.l, d.l, e.l)
  UnlockRect(a.l, b.l)
  AddDirtyRect(a.l, b.l)
EndInterface

; IDirect3DVertexBuffer9 interface definition
;
Interface IDirect3DVertexBuffer9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  Lock(a.l, b.l, c.l, d.l)
  Unlock()
  GetDesc(a.l)
EndInterface

; IDirect3DIndexBuffer9 interface definition
;
Interface IDirect3DIndexBuffer9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  Lock(a.l, b.l, c.l, d.l)
  Unlock()
  GetDesc(a.l)
EndInterface

; IDirect3DSurface9 interface definition
;
Interface IDirect3DSurface9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  SetPriority(a.l)
  GetPriority()
  PreLoad()
  GetType()
  GetContainer(a.l, b.l)
  GetDesc(a.l)
  LockRect(a.l, b.l, c.l)
  UnlockRect()
  GetDC(a.l)
  ReleaseDC(a.l)
EndInterface

; IDirect3DVolume9 interface definition
;
Interface IDirect3DVolume9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  SetPrivateData(a.l, b.l, c.l, d.l)
  GetPrivateData(a.l, b.l, c.l)
  FreePrivateData(a.l)
  GetContainer(a.l, b.l)
  GetDesc(a.l)
  LockBox(a.l, b.l, c.l)
  UnlockBox()
EndInterface

; IDirect3DQuery9 interface definition
;
Interface IDirect3DQuery9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetType()
  GetDataSize()
  Issue(a.l)
  GetData(a.l, b.l, c.l)
EndInterface
