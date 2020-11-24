
; IRichEditOle interface definition
;
Interface IRichEditOle
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetClientSite(a.l)
  GetObjectCount()
  GetLinkCount()
  GetObject(a.l, b.l, c.l)
  InsertObject(a.l)
  ConvertObject(a.l, b.l, c.s)
  ActivateAs(a.l, b.l)
  SetHostNames(a.s, b.s)
  SetLinkAvailable(a.l, b.l)
  SetDvaspect(a.l, b.l)
  HandsOffStorage(a.l)
  SaveCompleted(a.l, b.l)
  InPlaceDeactivate()
  ContextSensitiveHelp(a.l)
  GetClipboardData(a.l, b.l, c.l)
  ImportDataObject(a.l, b.l, c.l)
EndInterface

; IRichEditOleCallback interface definition
;
Interface IRichEditOleCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetNewStorage(a.l)
  GetInPlaceContext(a.l, b.l, c.l)
  ShowContainerUI(a.l)
  QueryInsertObject(a.l, b.l, c.l)
  DeleteObject(a.l)
  QueryAcceptData(a.l, b.l, c.l, d.l, e.l)
  ContextSensitiveHelp(a.l)
  GetClipboardData(a.l, b.l, c.l)
  GetDragDropEffect(a.l, b.l, c.l)
  GetContextMenu(a.l, b.l, c.l, d.l)
EndInterface
