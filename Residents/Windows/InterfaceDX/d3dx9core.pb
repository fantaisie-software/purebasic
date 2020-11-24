
; ID3DXBuffer interface definition
;
Interface ID3DXBuffer
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetBufferPointer()
  GetBufferSize()
EndInterface

; ID3DXSprite interface definition
;
Interface ID3DXSprite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetTransform(a.l)
  SetTransform(a.l)
  SetWorldViewRH(a.l, b.l)
  SetWorldViewLH(a.l, b.l)
  Begin(a.l)
  Draw(a.l, b.l, c.l, d.l, e.l)
  Flush()
  End()
  OnLostDevice()
  OnResetDevice()
EndInterface

; ID3DXFont interface definition
;
Interface ID3DXFont
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetDescA(a.l)
  GetDescW(a.l)
  GetTextMetricsA(a.l)
  GetTextMetricsW(a.l)
  GetDC()
  GetGlyphData(a.l, b.l, c.l, d.l)
  PreloadCharacters(a.l, b.l)
  PreloadGlyphs(a.l, b.l)
  PreloadTextA(a.s, b.l)
  PreloadTextW(a.l, b.l)
  DrawTextA(a.l, b.s, c.l, d.l, e.l, f.l)
  DrawTextW(a.l, b.l, c.l, d.l, e.l, f.l)
  OnLostDevice()
  OnResetDevice()
EndInterface

; ID3DXRenderToSurface interface definition
;
Interface ID3DXRenderToSurface
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetDesc(a.l)
  BeginScene(a.l, b.l)
  EndScene(a.l)
  OnLostDevice()
  OnResetDevice()
EndInterface

; ID3DXRenderToEnvMap interface definition
;
Interface ID3DXRenderToEnvMap
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  GetDesc(a.l)
  BeginCube(a.l)
  BeginSphere(a.l)
  BeginHemisphere(a.l, b.l)
  BeginParabolic(a.l, b.l)
  Face(a.l, b.l)
  End(a.l)
  OnLostDevice()
  OnResetDevice()
EndInterface

; ID3DXLine interface definition
;
Interface ID3DXLine
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetDevice(a.l)
  Begin()
  Draw(a.l, b.l, c.l)
  DrawTransform(a.l, b.l, c.l, d.l)
  SetPattern(a.l)
  GetPattern()
  SetPatternScale(a.f)
  GetPatternScale()
  SetWidth(a.f)
  GetWidth()
  SetAntialias(a.l)
  GetAntialias()
  SetGLLines(a.l)
  GetGLLines()
  End()
  OnLostDevice()
  OnResetDevice()
EndInterface
