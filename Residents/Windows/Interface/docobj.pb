
; IOleDocument interface definition
;
Interface IOleDocument
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateView(a.l, b.l, c.l, d.l)
  GetDocMiscStatus(a.l)
  EnumViews(a.l, b.l)
EndInterface

; IOleDocumentSite interface definition
;
Interface IOleDocumentSite
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ActivateMe(a.l)
EndInterface

; IOleDocumentView interface definition
;
Interface IOleDocumentView
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetInPlaceSite(a.l)
  GetInPlaceSite(a.l)
  GetDocument(a.l)
  SetRect(a.l)
  GetRect(a.l)
  SetRectComplex(a.l, b.l, c.l, d.l)
  Show(a.l)
  UIActivate(a.l)
  Open()
  CloseView(a.l)
  SaveViewState(a.l)
  ApplyViewState(a.l)
  Clone(a.l, b.l)
EndInterface

; IEnumOleDocumentViews interface definition
;
Interface IEnumOleDocumentViews
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IContinueCallback interface definition
;
Interface IContinueCallback
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  FContinue()
  FContinuePrinting(a.l, b.l, c.l)
EndInterface

; IPrint interface definition
;
Interface IPrint
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetInitialPageNum(a.l)
  GetPageInfo(a.l, b.l)
  Print(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; IOleCommandTarget interface definition
;
Interface IOleCommandTarget
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  QueryStatus(a.l, b.l, c.l, d.l)
  Exec(a.l, b.l, c.l, d.l, e.l)
EndInterface
