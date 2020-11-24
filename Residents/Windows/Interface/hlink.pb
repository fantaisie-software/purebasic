
; IHlink interface definition
;
Interface IHlink
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetHlinkSite(a.l, b.l)
  GetHlinkSite(a.l, b.l)
  SetMonikerReference(a.l, b.l, c.l)
  GetMonikerReference(a.l, b.l, c.l)
  SetStringReference(a.l, b.l, c.l)
  GetStringReference(a.l, b.l, c.l)
  SetFriendlyName(a.l)
  GetFriendlyName(a.l, b.l)
  SetTargetFrameName(a.l)
  GetTargetFrameName(a.l)
  GetMiscStatus(a.l)
  Navigate(a.l, b.l, c.l, d.l)
  SetAdditionalParams(a.l)
  GetAdditionalParams(a.l)
EndInterface

; IHlinkSite interface definition
;
Interface IHlinkSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryService(a.l, b.l, c.l, d.l)
  GetMoniker(a.l, b.l, c.l, d.l)
  ReadyToNavigate(a.l, b.l)
  OnNavigationComplete(a.l, b.l, c.l, d.l)
EndInterface

; IHlinkTarget interface definition
;
Interface IHlinkTarget
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetBrowseContext(a.l)
  GetBrowseContext(a.l)
  Navigate(a.l, b.l)
  GetMoniker(a.l, b.l, c.l)
  GetFriendlyName(a.l, b.l)
EndInterface

; IHlinkFrame interface definition
;
Interface IHlinkFrame
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetBrowseContext(a.l)
  GetBrowseContext(a.l)
  Navigate(a.l, b.l, c.l, d.l)
  OnNavigate(a.l, b.l, c.l, d.l, e.l)
  UpdateHlink(a.l, b.l, c.l, d.l)
EndInterface

; IEnumHLITEM interface definition
;
Interface IEnumHLITEM
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IHlinkBrowseContext interface definition
;
Interface IHlinkBrowseContext
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Register(a.l, b.l, c.l, d.l)
  GetObject(a.l, b.l, c.l)
  Revoke(a.l)
  SetBrowseWindowInfo(a.l)
  GetBrowseWindowInfo(a.l)
  SetInitialHlink(a.l, b.l, c.l)
  OnNavigateHlink(a.l, b.l, c.l, d.l, e.l)
  UpdateHlink(a.l, b.l, c.l, d.l)
  EnumNavigationStack(a.l, b.l, c.l)
  QueryHlink(a.l, b.l)
  GetHlink(a.l, b.l)
  SetCurrentHlink(a.l)
  Clone(a.l, b.l, c.l)
  Close(a.l)
EndInterface

; IExtensionServices interface definition
;
Interface IExtensionServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetAdditionalHeaders(a.l)
  SetAuthenticateData(a.l, b.l, c.l)
EndInterface
