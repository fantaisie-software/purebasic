
; IAMPlayListItem interface definition
;
Interface IAMPlayListItem
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFlags(a.l)
  GetSourceCount(a.l)
  GetSourceURL(a.l, b.l)
  GetSourceStart(a.l, b.l)
  GetSourceDuration(a.l, b.l)
  GetSourceStartMarker(a.l, b.l)
  GetSourceEndMarker(a.l, b.l)
  GetSourceStartMarkerName(a.l, b.l)
  GetSourceEndMarkerName(a.l, b.l)
  GetLinkURL(a.l)
  GetScanDuration(a.l, b.l)
EndInterface

; IAMPlayList interface definition
;
Interface IAMPlayList
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetFlags(a.l)
  GetItemCount(a.l)
  GetItem(a.l, b.l)
  GetNamedEvent(a.l, b.l, c.l, d.l)
  GetRepeatInfo(a.l, b.l, c.l)
EndInterface

; ISpecifyParticularPages interface definition
;
Interface ISpecifyParticularPages
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetPages(a.l, b.l)
EndInterface

; IAMRebuild interface definition
;
Interface IAMRebuild
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  RebuildNow()
EndInterface
