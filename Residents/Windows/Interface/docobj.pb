
; IOleDocument interface definition
;
Interface IOleDocument Extends IUnknown
  CreateView(a.l, b.l, c.l, d.l)
  GetDocMiscStatus(a.l)
  EnumViews(a.l, b.l)
EndInterface

; IOleDocumentSite interface definition
;
Interface IOleDocumentSite Extends IUnknown
  ActivateMe(a.l)
EndInterface

; IOleDocumentView interface definition
;
Interface IOleDocumentView Extends IUnknown
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
Interface IEnumOleDocumentViews Extends IUnknown
  Next(a.l, b.l, c.l)
  Skip(a.l)
  Reset()
  Clone(a.l)
EndInterface

; IContinueCallback interface definition
;
Interface IContinueCallback Extends IUnknown
  FContinue()
  FContinuePrinting(a.l, b.l, c.l)
EndInterface

; IPrint interface definition
;
Interface IPrint Extends IUnknown
  SetInitialPageNum(a.l)
  GetPageInfo(a.l, b.l)
  Print(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
EndInterface

; IOleCommandTarget interface definition
;
Interface IOleCommandTarget Extends IUnknown
  QueryStatus(a.l, b.l, c.l, d.l)
  Exec(a.l, b.l, c.l, d.l, e.l)
EndInterface
