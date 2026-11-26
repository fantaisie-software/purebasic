
; IVMRImagePresenter9 interface definition
;
Interface IVMRImagePresenter9 Extends IUnknown
  StartPresenting(a.l)
  StopPresenting(a.l)
  PresentImage(a.l, b.l)
EndInterface

; IVMRSurfaceAllocator9 interface definition
;
Interface IVMRSurfaceAllocator9 Extends IUnknown
  InitializeDevice(a.l, b.l, c.l)
  TerminateDevice(a.l)
  GetSurface(a.l, b.l, c.l, d.l)
  AdviseNotify(a.l)
EndInterface

; IVMRSurfaceAllocatorEx9 interface definition
;
Interface IVMRSurfaceAllocatorEx9 Extends IVMRSurfaceAllocator9
  GetSurfaceEx(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IVMRSurfaceAllocatorNotify9 interface definition
;
Interface IVMRSurfaceAllocatorNotify9 Extends IUnknown
  AdviseSurfaceAllocator(a.l, b.l)
  SetD3DDevice(a.l, b.l)
  ChangeD3DDevice(a.l, b.l)
  AllocateSurfaceHelper(a.l, b.l, c.l)
  NotifyEvent(a.l, b.l, c.l)
EndInterface

; IVMRWindowlessControl9 interface definition
;
Interface IVMRWindowlessControl9 Extends IUnknown
  GetNativeVideoSize(a.l, b.l, c.l, d.l)
  GetMinIdealVideoSize(a.l, b.l)
  GetMaxIdealVideoSize(a.l, b.l)
  SetVideoPosition(a.l, b.l)
  GetVideoPosition(a.l, b.l)
  GetAspectRatioMode(a.l)
  SetAspectRatioMode(a.l)
  SetVideoClippingWindow(a.l)
  RepaintVideo(a.l, b.l)
  DisplayModeChanged()
  GetCurrentImage(a.l)
  SetBorderColor(a.l)
  GetBorderColor(a.l)
EndInterface

; IVMRMixerControl9 interface definition
;
Interface IVMRMixerControl9 Extends IUnknown
  SetAlpha(a.l, b.f)
  GetAlpha(a.l, b.l)
  SetZOrder(a.l, b.l)
  GetZOrder(a.l, b.l)
  SetOutputRect(a.l, b.l)
  GetOutputRect(a.l, b.l)
  SetBackgroundClr(a.l)
  GetBackgroundClr(a.l)
  SetMixingPrefs(a.l)
  GetMixingPrefs(a.l)
  SetProcAmpControl(a.l, b.l)
  GetProcAmpControl(a.l, b.l)
  GetProcAmpControlRange(a.l, b.l)
EndInterface

; IVMRMixerBitmap9 interface definition
;
Interface IVMRMixerBitmap9 Extends IUnknown
  SetAlphaBitmap(a.l)
  UpdateAlphaBitmapParameters(a.l)
  GetAlphaBitmapParameters(a.l)
EndInterface

; IVMRSurface9 interface definition
;
Interface IVMRSurface9 Extends IUnknown
  IsSurfaceLocked()
  LockSurface(a.l)
  UnlockSurface()
  GetSurface(a.l)
EndInterface

; IVMRImagePresenterConfig9 interface definition
;
Interface IVMRImagePresenterConfig9 Extends IUnknown
  SetRenderingPrefs(a.l)
  GetRenderingPrefs(a.l)
EndInterface

; IVMRVideoStreamControl9 interface definition
;
Interface IVMRVideoStreamControl9 Extends IUnknown
  SetStreamActiveState(a.l)
  GetStreamActiveState(a.l)
EndInterface

; IVMRFilterConfig9 interface definition
;
Interface IVMRFilterConfig9 Extends IUnknown
  SetImageCompositor(a.l)
  SetNumberOfStreams(a.l)
  GetNumberOfStreams(a.l)
  SetRenderingPrefs(a.l)
  GetRenderingPrefs(a.l)
  SetRenderingMode(a.l)
  GetRenderingMode(a.l)
EndInterface

; IVMRAspectRatioControl9 interface definition
;
Interface IVMRAspectRatioControl9 Extends IUnknown
  GetAspectRatioMode(a.l)
  SetAspectRatioMode(a.l)
EndInterface

; IVMRMonitorConfig9 interface definition
;
Interface IVMRMonitorConfig9 Extends IUnknown
  SetMonitor(a.l)
  GetMonitor(a.l)
  SetDefaultMonitor(a.l)
  GetDefaultMonitor(a.l)
  GetAvailableMonitors(a.l, b.l, c.l)
EndInterface

; IVMRDeinterlaceControl9 interface definition
;
Interface IVMRDeinterlaceControl9 Extends IUnknown
  GetNumberOfDeinterlaceModes(a.l, b.l, c.l)
  GetDeinterlaceModeCaps(a.l, b.l, c.l)
  GetDeinterlaceMode(a.l, b.l)
  SetDeinterlaceMode(a.l, b.l)
  GetDeinterlacePrefs(a.l)
  SetDeinterlacePrefs(a.l)
  GetActualDeinterlaceMode(a.l, b.l)
EndInterface

; IVMRImageCompositor9 interface definition
;
Interface IVMRImageCompositor9 Extends IUnknown
  InitCompositionDevice(a.l)
  TermCompositionDevice(a.l)
  SetStreamMediaType(a.l, b.l, c.l)
  CompositeImage(a.l, b.l, c.l, d.q, e.q, f.l, g.l, h.l)
EndInterface
