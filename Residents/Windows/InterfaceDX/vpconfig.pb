
; IVPBaseConfig interface definition
;
Interface IVPBaseConfig Extends IUnknown
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
Interface IVPConfig Extends IVPBaseConfig
  IsVPDecimationAllowed(a.l)
  SetScalingFactors(a.l)
EndInterface

; IVPVBIConfig interface definition
;
Interface IVPVBIConfig Extends IVPBaseConfig
  IsVPDecimationAllowed(a.l)
  SetScalingFactors(a.l)
EndInterface
; ExecutableFormat=
; EOF
