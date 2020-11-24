

Enumeration   ; SDL_SYSWM_TYPE
  #SDL_SYSWM_X11
EndEnumeration


Structure SDL_SysWMmsg
  version.SDL_version
  pad.b
  subsystem.l ; SDL_SYSWM_TYPE ENUM
  xevent.b[96] ; Opaque structure as it's a big XEvent one
EndStructure


Structure SDL_SysWMinfo_info_x11
  *display
  window.l
  *lock_func
  *unlock_func
  fswindow.l
  wmwindow.l
EndStructure

Structure SDL_SysWMinfo_info
  x11.SDL_SysWMinfo_info_x11
EndStructure

Structure SDL_SysWMinfo
  version.SDL_version
  pad.b
  subsystem.l ; SDL_SYSWM_TYPE ENUM
  info.SDL_SysWMinfo_info
EndStructure
