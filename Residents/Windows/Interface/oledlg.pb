
; IOleUILinkContainerW interface definition
;
Interface IOleUILinkContainerW Extends IUnknown
  GetNextLink(a.l)
  SetLinkUpdateOptions(a.l, b.l)
  GetLinkUpdateOptions(a.l, b.l)
  SetLinkSource(a.l, b.l, c.l, d.l, e.l)
  GetLinkSource(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  OpenLinkSource(a.l)
  UpdateLink(a.l, b.l, c.l)
  CancelLink(a.l)
EndInterface

; IOleUILinkContainerA interface definition
;
Interface IOleUILinkContainerA Extends IUnknown
  GetNextLink(a.l)
  SetLinkUpdateOptions(a.l, b.l)
  GetLinkUpdateOptions(a.l, b.l)
  SetLinkSource(a.l, b.l, c.l, d.l, e.l)
  GetLinkSource(a.l, b.l, c.l, d.l, e.l, f.l, g.l)
  OpenLinkSource(a.l)
  UpdateLink(a.l, b.l, c.l)
  CancelLink(a.l)
EndInterface

; IOleUIObjInfoW interface definition
;
Interface IOleUIObjInfoW Extends IUnknown
  GetObjectInfo(a.l, b.l, c.l, d.l, e.l, f.l)
  GetConvertInfo(a.l, b.l, c.l, d.l, e.l, f.l)
  ConvertObject(a.l, b.l)
  GetViewInfo(a.l, b.l, c.l, d.l)
  SetViewInfo(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IOleUIObjInfoA interface definition
;
Interface IOleUIObjInfoA Extends IUnknown
  GetObjectInfo(a.l, b.l, c.l, d.l, e.l, f.l)
  GetConvertInfo(a.l, b.l, c.l, d.l, e.l, f.l)
  ConvertObject(a.l, b.l)
  GetViewInfo(a.l, b.l, c.l, d.l)
  SetViewInfo(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IOleUILinkInfoW interface definition
;
Interface IOleUILinkInfoW Extends IOleUILinkContainerW
  GetLastUpdate(a.l, b.l)
EndInterface

; IOleUILinkInfoA interface definition
;
Interface IOleUILinkInfoA Extends IOleUILinkContainerA
  GetLastUpdate(a.l, b.l)
EndInterface
