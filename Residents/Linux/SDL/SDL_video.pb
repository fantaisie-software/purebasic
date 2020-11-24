#SDL_ALPHA_OPAQUE = 255
#SDL_ALPHA_TRANSPARENT = 0
Structure SDL_Rect
  x.w
  y.w
  w.w
  h.w
EndStructure

Structure SDL_Color
  r.b
  g.b
  b.b
  unused.b
EndStructure

Structure SDL_Palette
  ncolors.l
  PB_Align(0, 4)
 *colors.SDL_Color
EndStructure

Structure SDL_PixelFormat
 *palette.SDL_Palette
  BitsPerPixel.b
  BytesPerPixel.b
  Rloss.b
  Gloss.b
  Bloss.b
  Aloss.b
  Rshift.b
  Gshift.b
  Bshift.b
  Ashift.b
  PB_Align(2, 2)
  Rmask.l
  Gmask.l
  Bmask.l
  Amask.l
  colorkey.l
  alpha.b
  PB_Align(3, 7, 1)
EndStructure

Structure SDL_Surface
  flags.l
  PB_Align(0, 4)
 *format.SDL_PixelFormat
  w.l
  h.l
  pitch.w
  PB_Align(2, 6, 1)
 *pixels
  offset.l
  PB_Align(0, 4, 2)
 *hwdata.private_hwdata
  clip_rect.SDL_Rect
  unused1.l
  locked.l
 *map.SDL_BlitMap
  format_version.l
  refcount.l
EndStructure

#SDL_SWSURFACE = $00000000
#SDL_HWSURFACE = $00000001
#SDL_ASYNCBLIT = $00000004
#SDL_ANYFORMAT = $10000000
#SDL_HWPALETTE = $20000000
#SDL_DOUBLEBUF = $40000000
#SDL_FULLSCREEN = $80000000
#SDL_OPENGL = $00000002
#SDL_OPENGLBLIT = $0000000A
#SDL_RESIZABLE = $00000010
#SDL_NOFRAME = $00000020
#SDL_HWACCEL = $00000100
#SDL_SRCCOLORKEY = $00001000
#SDL_RLEACCELOK = $00002000
#SDL_RLEACCEL = $00004000
#SDL_SRCALPHA = $00010000
#SDL_PREALLOC = $01000000

Structure SDL_VideoInfo
  packed_flags.l
  ; hw_available:1
  ; wm_available:1
  ; UnusedBits1:6
  ; UnusedBits2:1
  ; blit_hw:1
  ; blit_hw_CC:1
  ; blit_hw_A:1
  ; blit_sw:1
  ; blit_sw_CC:1
  ; blit_sw_A:1
  ; blit_fill:1
  ; UnusedBits3:16
  video_mem.l
 *vfmt.SDL_PixelFormat
  current_w.l
  current_h.l
EndStructure

#SDL_YV12_OVERLAY = $32315659
#SDL_IYUV_OVERLAY = $56555949
#SDL_YUY2_OVERLAY = $32595559
#SDL_UYVY_OVERLAY = $59565955
#SDL_YVYU_OVERLAY = $55595659
Structure SDL_Overlay
  format.l
  w.l
  h.l
  planes.l
 *pitches
 *pixels
 *hwfuncs.private_yuvhwfuncs
 *hwdata.private_yuvhwdata
  packed_flags.l
  ; hw_overlay:1
  ; UnusedBits:31
  PB_Align(0, 4)
EndStructure

Enumeration   ; SDL_GLattr
  #SDL_GL_RED_SIZE
  #SDL_GL_GREEN_SIZE
  #SDL_GL_BLUE_SIZE
  #SDL_GL_ALPHA_SIZE
  #SDL_GL_BUFFER_SIZE
  #SDL_GL_DOUBLEBUFFER
  #SDL_GL_DEPTH_SIZE
  #SDL_GL_STENCIL_SIZE
  #SDL_GL_ACCUM_RED_SIZE
  #SDL_GL_ACCUM_GREEN_SIZE
  #SDL_GL_ACCUM_BLUE_SIZE
  #SDL_GL_ACCUM_ALPHA_SIZE
  #SDL_GL_STEREO
  #SDL_GL_MULTISAMPLEBUFFERS
  #SDL_GL_MULTISAMPLESAMPLES
EndEnumeration

#SDL_LOGPAL = $01
#SDL_PHYSPAL = $02
Enumeration   ; SDL_GrabMode
  #SDL_GRAB_QUERY = -1
  #SDL_GRAB_OFF = 0
  #SDL_GRAB_ON = 1
  #SDL_GRAB_FULLSCREEN
EndEnumeration

; ExecutableFormat=
; EOF