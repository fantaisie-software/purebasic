Structure SDL_keysym
  scancode.b
  pad.b
  pad2.w
  sym.l ; SDLKey ENUM
  mod.l ; SDLMod ENUM
  unicode.w
  pad3.b[2]  ; PureBasic: structures size needs32 bytes boundary
EndStructure

#SDL_ALL_HOTKEYS = $FFFFFFFF
#SDL_DEFAULT_REPEAT_DELAY = 500
#SDL_DEFAULT_REPEAT_INTERVAL = 30
; ExecutableFormat=
; EOF
