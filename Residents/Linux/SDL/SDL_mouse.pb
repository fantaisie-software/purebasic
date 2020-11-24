Structure SDL_Cursor
  area.SDL_Rect
  hot_x.w
  hot_y.w
  PB_Align(0, 4)
 *data
 *mask
 *save[2]
 *wm_cursor.WMcursor
EndStructure

#SDL_BUTTON_LEFT = 1
#SDL_BUTTON_MIDDLE = 2
#SDL_BUTTON_RIGHT = 3
#SDL_BUTTON_WHEELUP = 4
#SDL_BUTTON_WHEELDOWN = 5

; #define SDL_BUTTON(X)  (SDL_PRESSED<<(X-1))

; SDL_PRESSED isn't defined in the includes ? Found 1 on google, so we believe it

#SDL_PRESSED  = 1
#SDL_RELEASED = 0

#SDL_BUTTON_LMASK = #SDL_PRESSED << (#SDL_BUTTON_LEFT-1)
#SDL_BUTTON_MMASK = #SDL_PRESSED << (#SDL_BUTTON_MIDDLE-1)
#SDL_BUTTON_RMASK = #SDL_PRESSED << (#SDL_BUTTON_RIGHT-1)

; ExecutableFormat=
; EOF