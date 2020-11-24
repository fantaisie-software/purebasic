
; ID3DXMatrixStack interface definition
;
Interface ID3DXMatrixStack
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Pop()
  Push()
  LoadIdentity()
  LoadMatrix(a.l)
  MultMatrix(a.l)
  MultMatrixLocal(a.l)
  RotateAxis(a.l, b.f)
  RotateAxisLocal(a.l, b.f)
  RotateYawPitchRoll(a.f, b.f, c.f)
  RotateYawPitchRollLocal(a.f, b.f, c.f)
  Scale(a.f, b.f, c.f)
  ScaleLocal(a.f, b.f, c.f)
  Translate(a.f, b.f, c.f)
  TranslateLocal(a.f, b.f, c.f)
  GetTop()
EndInterface
