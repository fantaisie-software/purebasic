
; IDsAdminCreateObj interface definition
;
Interface IDsAdminCreateObj Extends IUnknown
  Initialize(a.l, b.l, c.l)
  CreateModal(a.l, b.l)
EndInterface

; IDsAdminNewObj interface definition
;
Interface IDsAdminNewObj Extends IUnknown
  SetButtons(a.l, b.l)
  GetPageCounts(a.l, b.l)
EndInterface

; IDsAdminNewObjPrimarySite interface definition
;
Interface IDsAdminNewObjPrimarySite Extends IUnknown
  CreateNew(a.l)
  Commit()
EndInterface

; IDsAdminNewObjExt interface definition
;
Interface IDsAdminNewObjExt Extends IUnknown
  Initialize(a.l, b.l, c.l, d.l, e.l)
  AddPages(a.l, b.l)
  SetObject(a.l)
  WriteData(a.l, b.l)
  OnError(a.l, b.l, c.l)
  GetSummaryInfo()
EndInterface

; IDsAdminNotifyHandler interface definition
;
Interface IDsAdminNotifyHandler Extends IUnknown
  Initialize(a.l, b.l)
  Begin(a.l, b.l, c.l, d.l, e.l)
  Notify(a.l, b.l)
  End()
EndInterface
