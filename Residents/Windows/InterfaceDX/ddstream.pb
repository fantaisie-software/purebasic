
; IDirectDrawMediaStream interface definition
;
Interface IDirectDrawMediaStream Extends IMediaStream
  GetFormat(a.l, b.l, c.l, d.l)
  SetFormat(a.l, b.l)
  GetDirectDraw(a.l)
  SetDirectDraw(a.l)
  CreateSample(a.l, b.l, c.l, d.l)
  GetTimePerFrame(a.l)
EndInterface

; IDirectDrawStreamSample interface definition
;
Interface IDirectDrawStreamSample Extends IStreamSample
  GetSurface(a.l, b.l)
  SetRect(a.l)
EndInterface
