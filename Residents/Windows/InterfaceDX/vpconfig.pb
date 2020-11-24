
; IVPBaseConfig interface definition
;
Interface IVPBaseConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetConnectInfo(a.l, b.l)
  SetConnectInfo(a.l)
  GetVPDataInfo(a.l)
  GetMaxPixelRate(a.l, b.l)
  InformVPInputFormats(a.l, b.l)
  GetVideoFormats(a.l, b.l)
  SetVideoFormat(a.l)
  SetInvertPolarity()
  GetOverlaySurface(a.l)
  SetDirectDrawKernelHandle(a.l)
  SetVideoPortID(a.l)
  SetDDSurfaceKernelHandles(a.l, b.l)
  SetSurfaceParameters(a.l, b.l, c.l)
EndInterface

; IVPConfig interface definition
;
Interface IVPConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetConnectInfo(a.l, b.l)
  SetConnectInfo(a.l)
  GetVPDataInfo(a.l)
  GetMaxPixelRate(a.l, b.l)
  InformVPInputFormats(a.l, b.l)
  GetVideoFormats(a.l, b.l)
  SetVideoFormat(a.l)
  SetInvertPolarity()
  GetOverlaySurface(a.l)
  SetDirectDrawKernelHandle(a.l)
  SetVideoPortID(a.l)
  SetDDSurfaceKernelHandles(a.l, b.l)
  SetSurfaceParameters(a.l, b.l, c.l)
  IsVPDecimationAllowed(a.l)
  SetScalingFactors(a.l)
EndInterface

; IVPVBIConfig interface definition
;
Interface IVPVBIConfig
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetConnectInfo(a.l, b.l)
  SetConnectInfo(a.l)
  GetVPDataInfo(a.l)
  GetMaxPixelRate(a.l, b.l)
  InformVPInputFormats(a.l, b.l)
  GetVideoFormats(a.l, b.l)
  SetVideoFormat(a.l)
  SetInvertPolarity()
  GetOverlaySurface(a.l)
  SetDirectDrawKernelHandle(a.l)
  SetVideoPortID(a.l)
  SetDDSurfaceKernelHandles(a.l, b.l)
  SetSurfaceParameters(a.l, b.l, c.l)
  IsVPDecimationAllowed(a.l)
  SetScalingFactors(a.l)
EndInterface
; ExecutableFormat=
; EOF
