
; IVPBaseNotify interface definition
;
Interface IVPBaseNotify Extends IUnknown
  RenegotiateVPParameters()
EndInterface

; IVPNotify interface definition
;
Interface IVPNotify Extends IVPBaseNotify
  SetDeinterlaceMode(a.l)
  GetDeinterlaceMode(a.l)
EndInterface

; IVPNotify2 interface definition
;
Interface IVPNotify2 Extends IVPNotify
  SetVPSyncMaster(a.l)
  GetVPSyncMaster(a.l)
EndInterface

; IVPVBINotify interface definition
;
Interface IVPVBINotify Extends IVPBaseNotify
  SetDeinterlaceMode(a.l)
  GetDeinterlaceMode(a.l)
  SetVPSyncMaster(a.l)
  GetVPSyncMaster(a.l)
EndInterface
