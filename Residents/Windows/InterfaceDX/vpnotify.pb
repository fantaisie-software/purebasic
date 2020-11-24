
; IVPBaseNotify interface definition
;
Interface IVPBaseNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RenegotiateVPParameters()
EndInterface

; IVPNotify interface definition
;
Interface IVPNotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RenegotiateVPParameters()
  SetDeinterlaceMode(a.l)
  GetDeinterlaceMode(a.l)
EndInterface

; IVPNotify2 interface definition
;
Interface IVPNotify2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RenegotiateVPParameters()
  SetDeinterlaceMode(a.l)
  GetDeinterlaceMode(a.l)
  SetVPSyncMaster(a.l)
  GetVPSyncMaster(a.l)
EndInterface

; IVPVBINotify interface definition
;
Interface IVPVBINotify
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RenegotiateVPParameters()
  SetDeinterlaceMode(a.l)
  GetDeinterlaceMode(a.l)
  SetVPSyncMaster(a.l)
  GetVPSyncMaster(a.l)
EndInterface
