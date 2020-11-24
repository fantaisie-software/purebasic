
Enumeration
  #SDL_NOEVENT = 0			; Unused (do not remove)
  #SDL_ACTIVEEVENT      ; Application loses/gains visibility
  #SDL_KEYDOWN          ; Keys pressed
  #SDL_KEYUP            ; Keys released
  #SDL_MOUSEMOTION      ; Mouse moved
  #SDL_MOUSEBUTTONDOWN  ; Mouse button pressed
  #SDL_MOUSEBUTTONUP    ; Mouse button released
  #SDL_JOYAXISMOTION    ; Joystick axis motion
  #SDL_JOYBALLMOTION    ; Joystick trackball motion
  #SDL_JOYHATMOTION     ; Joystick hat position change
  #SDL_JOYBUTTONDOWN    ; Joystick button pressed
  #SDL_JOYBUTTONUP      ; Joystick button released
  #SDL_QUIT             ; User-requested quit
  #SDL_SYSWMEVENT       ; System specific event
  #SDL_EVENT_RESERVEDA  ; Reserved for future use..
  #SDL_EVENT_RESERVEDB  ; Reserved for future use..
  #SDL_VIDEORESIZE      ; User resized video mode
  #SDL_VIDEOEXPOSE      ; Screen needs to be redrawn
  #SDL_EVENT_RESERVED2  ; Reserved for future use..
  #SDL_EVENT_RESERVED3  ; Reserved for future use..
  #SDL_EVENT_RESERVED4  ; Reserved for future use..
  #SDL_EVENT_RESERVED5  ; Reserved for future use..
  #SDL_EVENT_RESERVED6  ; Reserved for future use..
  #SDL_EVENT_RESERVED7  ; Reserved for future use..
  
  ; Events SDL_USEREVENT through SDL_MAXEVENTS-1 are for your use
  #SDL_USEREVENT = 24
  
  ; This last event is only for bounding internal arrays
  ; It is the number of bits in the event mask datatype -- Uint32
  #SDL_NUMEVENTS = 32
EndEnumeration

; Predefined event masks
; #define 1 << #X)	(1<<(X))

Enumeration
  #SDL_ACTIVEEVENTMASK	    = 1 << #SDL_ACTIVEEVENT
  #SDL_KEYDOWNMASK		      = 1 << #SDL_KEYDOWN
  #SDL_KEYUPMASK		        = 1 << #SDL_KEYUP
  #SDL_MOUSEMOTIONMASK	    = 1 << #SDL_MOUSEMOTION
  #SDL_MOUSEBUTTONDOWNMASK	= 1 << #SDL_MOUSEBUTTONDOWN
  #SDL_MOUSEBUTTONUPMASK	  = 1 << #SDL_MOUSEBUTTONUP
  #SDL_MOUSEEVENTMASK	      = (1 << #SDL_MOUSEMOTION)| (1 << #SDL_MOUSEBUTTONDOWN) | (1 << #SDL_MOUSEBUTTONUP)
  #SDL_JOYAXISMOTIONMASK	  = 1 << #SDL_JOYAXISMOTION
  #SDL_JOYBALLMOTIONMASK	  = 1 << #SDL_JOYBALLMOTION
  #SDL_JOYHATMOTIONMASK	    = 1 << #SDL_JOYHATMOTION
  #SDL_JOYBUTTONDOWNMASK  	= 1 << #SDL_JOYBUTTONDOWN
  #SDL_JOYBUTTONUPMASK	    = 1 << #SDL_JOYBUTTONUP
  #SDL_JOYEVENTMASK	        = (1 << #SDL_JOYAXISMOTION) | (1 << #SDL_JOYBALLMOTION) | (1 << #SDL_JOYHATMOTION) | (1 << #SDL_JOYBUTTONDOWN) | (1 << #SDL_JOYBUTTONUP)
  #SDL_VIDEORESIZEMASK	    = 1 << #SDL_VIDEORESIZE
  #SDL_VIDEOEXPOSEMASK	    = 1 << #SDL_VIDEOEXPOSE
  #SDL_QUITMASK		          = 1 << #SDL_QUIT
  #SDL_SYSWMEVENTMASK	      = 1 << #SDL_SYSWMEVENT
EndEnumeration

#SDL_ALLEVENTS = $FFFFFFFF
Structure SDL_ActiveEvent
  type.b
  gain.b
  state.b
EndStructure

Structure SDL_KeyboardEvent
  type.b
  which.b
  state.b
  pad.b  ; WARNING ! Need to be 2 bytes boundary aligned
  keysym.SDL_keysym
EndStructure

Structure SDL_MouseMotionEvent
  type.b
  which.b
  state.b
  pad.b  ; WARNING ! Need to be 2 bytes boundary aligned
  x.w
  y.w
  xrel.w
  yrel.w
EndStructure

Structure SDL_MouseButtonEvent
  type.b
  which.b
  button.b
  state.b
  x.w
  y.w
EndStructure

Structure SDL_JoyAxisEvent
  type.b
  which.b
  axis.b
  pad.b  ; WARNING ! Need to be 2 bytes boundary aligned
  value.w
EndStructure

Structure SDL_JoyBallEvent
  type.b
  which.b
  ball.b
  pad.b  ; WARNING ! Need to be 2 bytes boundary aligned
  xrel.w
  yrel.w
EndStructure

Structure SDL_JoyHatEvent
  type.b
  which.b
  hat.b
  value.b
EndStructure

Structure SDL_JoyButtonEvent
  type.b
  which.b
  button.b
  state.b
EndStructure

Structure SDL_ResizeEvent
  type.b
  PB_Align(3, 3)
  w.l
  h.l
EndStructure

Structure SDL_ExposeEvent
  type.b
EndStructure

Structure SDL_QuitEvent
  type.b
EndStructure

Structure SDL_UserEvent
  type.b
  PB_Align(3, 3)
  code.l
  *data1
  *data2
EndStructure

Structure SDL_SysWMEvent
  type.b
  PB_Align(3, 7)
  *msg.SDL_SysWMmsg
EndStructure

Structure SDL_Event
  StructureUnion
    type.b
    active.SDL_ActiveEvent
    key.SDL_KeyboardEvent
    motion.SDL_MouseMotionEvent
    button.SDL_MouseButtonEvent
    jaxis.SDL_JoyAxisEvent
    jball.SDL_JoyBallEvent
    jhat.SDL_JoyHatEvent
    jbutton.SDL_JoyButtonEvent
    resize.SDL_ResizeEvent
    expose.SDL_ExposeEvent
    quit.SDL_QuitEvent
    user.SDL_UserEvent
    syswm.SDL_SysWMEvent
  EndStructureUnion
EndStructure

Enumeration   ; SDL_eventaction
  #SDL_ADDEVENT
  #SDL_PEEKEVENT
  #SDL_GETEVENT
EndEnumeration

#SDL_IGNORE = 0
#SDL_DISABLE = 0
#SDL_ENABLE = 1
; ExecutableFormat=
; EOF