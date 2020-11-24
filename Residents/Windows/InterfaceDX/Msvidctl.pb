
; IMSVidCtl interface definition
;
Interface IMSVidCtl
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_AutoSize(a.l)
  put_AutoSize(a.l)
  get_BackColor(a.l)
  put_BackColor(a.l)
  get_Enabled(a.l)
  put_Enabled(a.l)
  get_TabStop(a.l)
  put_TabStop(a.l)
  get_Window(a.l)
  Refresh()
  get_DisplaySize(a.l)
  put_DisplaySize(a.l)
  get_MaintainAspectRatio(a.l)
  put_MaintainAspectRatio(a.l)
  get_ColorKey(a.l)
  put_ColorKey(a.l)
  get_InputsAvailable(a.p-bstr, b.l)
  get_OutputsAvailable(a.p-bstr, b.l)
  get__InputsAvailable(a.l, b.l)
  get__OutputsAvailable(a.l, b.l)
  get_VideoRenderersAvailable(a.l)
  get_AudioRenderersAvailable(a.l)
  get_FeaturesAvailable(a.l)
  get_InputActive(a.l)
  put_InputActive(a.l)
  get_OutputsActive(a.l)
  put_OutputsActive(a.l)
  get_VideoRendererActive(a.l)
  put_VideoRendererActive(a.l)
  get_AudioRendererActive(a.l)
  put_AudioRendererActive(a.l)
  get_FeaturesActive(a.l)
  put_FeaturesActive(a.l)
  get_State(a.l)
  View(a.l)
  Build()
  Pause()
  Run()
  Stop()
  Decompose()
  DisableVideo()
  DisableAudio()
  ViewNext(a.l)
  put_ServiceProvider(a.l)
EndInterface

; IMSEventBinder interface definition
;
Interface IMSEventBinder
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Bind(a.l, b.p-bstr, c.p-bstr, d.l)
  Unbind(a.l)
EndInterface

; _IMSVidCtlEvents interface definition
;
Interface _IMSVidCtlEvents
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface