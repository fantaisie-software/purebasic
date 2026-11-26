
; IXDSToRat interface definition
;
Interface IXDSToRat Extends IDispatch
  Init()
  ParseXDSBytePair(a.l, b.l, c.l, d.l, e.l)
EndInterface

; IEvalRat interface definition
;
Interface IEvalRat Extends IDispatch
  get_BlockedRatingAttributes(a.l, b.l, c.l)
  put_BlockedRatingAttributes(a.l, b.l, c.l)
  get_BlockUnRated(a.l)
  put_BlockUnRated(a.l)
  MostRestrictiveRating(a.l, b.l, c.l, d.l, e.l, f.l, g.l, h.l, i.l)
  TestRating(a.l, b.l, c.l)
EndInterface
