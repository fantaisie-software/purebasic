
; IHostDialogHelper interface definition
;
Interface IHostDialogHelper
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ShowHTMLDialog(a.l, b.l, c.l, d.l, e.l, f.l)
EndInterface

; IDocHostUIHandler interface definition
;
Interface IDocHostUIHandler
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ShowContextMenu(a.l, b.l, c.l, d.l)
  GetHostInfo(a.l)
  ShowUI(a.l, b.l, c.l, d.l, e.l)
  HideUI()
  UpdateUI()
  EnableModeless(a.l)
  OnDocWindowActivate(a.l)
  OnFrameWindowActivate(a.l)
  ResizeBorder(a.l, b.l, c.l)
  TranslateAccelerator(a.l, b.l, c.l)
  GetOptionKeyPath(a.l, b.l)
  GetDropTarget(a.l, b.l)
  GetExternal(a.l)
  TranslateUrl(a.l, b.l, c.l)
  FilterDataObject(a.l, b.l)
EndInterface

; IDocHostUIHandler2 interface definition
;
Interface IDocHostUIHandler2
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ShowContextMenu(a.l, b.l, c.l, d.l)
  GetHostInfo(a.l)
  ShowUI(a.l, b.l, c.l, d.l, e.l)
  HideUI()
  UpdateUI()
  EnableModeless(a.l)
  OnDocWindowActivate(a.l)
  OnFrameWindowActivate(a.l)
  ResizeBorder(a.l, b.l, c.l)
  TranslateAccelerator(a.l, b.l, c.l)
  GetOptionKeyPath(a.l, b.l)
  GetDropTarget(a.l, b.l)
  GetExternal(a.l)
  TranslateUrl(a.l, b.l, c.l)
  FilterDataObject(a.l, b.l)
  GetOverrideKeyPath(a.l, b.l)
EndInterface

; ICustomDoc interface definition
;
Interface ICustomDoc
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  SetUIHandler(a.l)
EndInterface

; IDocHostShowUI interface definition
;
Interface IDocHostShowUI
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  ShowMessage(a.l, b.p-unicode, c.p-unicode, d.l, e.p-unicode, f.l, g.l)
  ShowHelp(a.l, b.p-unicode, c.l, d.l, e.l, f.l)
EndInterface

; IClassFactoryEx interface definition
;
Interface IClassFactoryEx
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  CreateInstance(a.l, b.l, c.l)
  LockServer(a.l)
  CreateInstanceWithContext(a.l, b.l, c.l, d.l)
EndInterface

; IHTMLOMWindowServices interface definition
;
Interface IHTMLOMWindowServices
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  moveTo(a.l, b.l)
  moveBy(a.l, b.l)
  resizeTo(a.l, b.l)
  resizeBy(a.l, b.l)
EndInterface
