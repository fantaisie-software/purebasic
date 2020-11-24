#SDL_MAX_TRACKS = 99
#SDL_AUDIO_TRACK = $00
#SDL_DATA_TRACK = $04
Enumeration   ; CDstatus
  #CD_TRAYEMPTY
  #CD_STOPPED
  #CD_PLAYING
  #CD_PAUSED
  #CD_ERROR = -1
EndEnumeration

Structure SDL_CDtrack
  id.b
  type.b
  unused.w
  length.l
  offset.l
EndStructure

Structure SDL_CD
  id.l
  status.l ; CDstatus Enum
  numtracks.l
  cur_track.l
  cur_frame.l
  track.SDL_CDtrack[#SDL_MAX_TRACKS+1]
EndStructure

#CD_FPS = 75
; ExecutableFormat=
; EOF