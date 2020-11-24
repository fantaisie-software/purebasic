
; IVMRImagePresenter9 interface definition
;
Interface IVMRImagePresenter9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  StartPresenting(a.l)
  StopPresenting(a.l)
  PresentImage(a.l, b.l)
EndInterface

; IVMRSurfaceAllocator9 interface definition
;
Interface IVMRSurfaceAllocator9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitializeDevice(a.l, b.l, c.l)
  TerminateDevice(a.l)
  GetSurface(a.l, b.l, c.l, d.l)
  AdviseNotify(a.l)
EndInterface

; IVMRSurfaceAllocatorEx9 interface definition
;
Interface IVMRSurfaceAllocatorEx9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitializeDevice(a.l, b.l, c.l)
  TerminateDevice(a.l)
  GetSurface(a.l, b.l, c.l, d.l)
  AdviseNotify(a.l)
  GetSurfaceEx(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IVMRSurfaceAllocatorNotify9 interface definition
;
Interface IVMRSurfaceAllocatorNotify9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  AdviseSurfaceAllocator(a.l, b.l)
  SetD3DDevice(a.l, b.l)
  ChangeD3DDevice(a.l, b.l)
  AllocateSurfaceHelper(a.l, b.l, c.l)
  NotifyEvent(a.l, b.l, c.l)
EndInterface

; IVMRWindowlessControl9 interface definition
;
Interface IVMRWindowlessControl9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IVMRMixerControl9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IVMRMixerBitmap9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAlphaBitmap(a.l)
  UpdateAlphaBitmapParameters(a.l)
  GetAlphaBitmapParameters(a.l)
EndInterface

; IVMRSurface9 interface definition
;
Interface IVMRSurface9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  IsSurfaceLocked()
  LockSurface(a.l)
  UnlockSurface()
  GetSurface(a.l)
EndInterface

; IVMRImagePresenterConfig9 interface definition
;
Interface IVMRImagePresenterConfig9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetRenderingPrefs(a.l)
  GetRenderingPrefs(a.l)
EndInterface

; IVMRVideoStreamControl9 interface definition
;
Interface IVMRVideoStreamControl9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetStreamActiveState(a.l)
  GetStreamActiveState(a.l)
EndInterface

; IVMRFilterConfig9 interface definition
;
Interface IVMRFilterConfig9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IVMRAspectRatioControl9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetAspectRatioMode(a.l)
  SetAspectRatioMode(a.l)
EndInterface

; IVMRMonitorConfig9 interface definition
;
Interface IVMRMonitorConfig9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetMonitor(a.l)
  GetMonitor(a.l)
  SetDefaultMonitor(a.l)
  GetDefaultMonitor(a.l)
  GetAvailableMonitors(a.l, b.l, c.l)
EndInterface

; IVMRDeinterlaceControl9 interface definition
;
Interface IVMRDeinterlaceControl9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
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
Interface IVMRImageCompositor9
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  InitCompositionDevice(a.l)
  TermCompositionDevice(a.l)
  SetStreamMediaType(a.l, b.l, c.l)
  CompositeImage(a.l, b.l, c.l, d.q, e.q, f.l, g.l, h.l)
EndInterface
