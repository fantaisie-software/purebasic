
; IDsAdminCreateObj interface definition
;
Interface IDsAdminCreateObj
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l)
  CreateModal(a.l, b.l)
EndInterface

; IDsAdminNewObj interface definition
;
Interface IDsAdminNewObj
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetButtons(a.l, b.l)
  GetPageCounts(a.l, b.l)
EndInterface

; IDsAdminNewObjPrimarySite interface definition
;
Interface IDsAdminNewObjPrimarySite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateNew(a.l)
  Commit()
EndInterface

; IDsAdminNewObjExt interface definition
;
Interface IDsAdminNewObjExt
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l, c.l, d.l, e.l)
  AddPages(a.l, b.l)
  SetObject(a.l)
  WriteData(a.l, b.l)
  OnError(a.l, b.l, c.l)
  GetSummaryInfo()
EndInterface

; IDsAdminNotifyHandler interface definition
;
Interface IDsAdminNotifyHandler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Initialize(a.l, b.l)
  Begin(a.l, b.l, c.l, d.l, e.l)
  Notify(a.l, b.l)
  End()
EndInterface
