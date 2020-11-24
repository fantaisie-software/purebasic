
; IXDSToRat interface definition
;
Interface IXDSToRat
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  Init()
  ParseXDSBytePair(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IEvalRat interface definition
;
Interface IEvalRat
  QueryInterface(a.l, b.l)
  AddRef()
  Release()
  GetTypeInfoCount(a.l)
  GetTypeInfo(a.l, b.l, c.l)
  GetIDsOfNames(a.l, b.l, c.l, d.l, e.l)
  Invoke(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l)
  get_BlockedRatingAttributes(a.l, b.l, c.l)
  put_BlockedRatingAttributes(a.l, b.l, c.l)
  get_BlockUnRated(a.l)
  put_BlockUnRated(a.l)
  MostRestrictiveRating(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  TestRating(a.l, b.l, c.l)
EndInterface
