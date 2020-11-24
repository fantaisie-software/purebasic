Structure SDL_AudioSpec
  freq.l
  format.w
  channels.b
  silence.b
  samples.w
  padding.w
  size.l
 *callback
 *userdata
EndStructure

#AUDIO_U8 = $0008
#AUDIO_S8 = $8008
#AUDIO_U16LSB = $0010
#AUDIO_S16LSB = $8010
#AUDIO_U16MSB = $1010
#AUDIO_S16MSB = $9010
#AUDIO_U16 = #AUDIO_U16LSB
#AUDIO_S16 = #AUDIO_S16LSB
;#AUDIO_U16SYS = #AUDIO_U16LSB ; LITTLE ENDIAN
;#AUDIO_S16SYS = #AUDIO_S16LSB
#AUDIO_U16SYS = #AUDIO_U16MSB
#AUDIO_S16SYS = #AUDIO_S16MSB

Structure SDL_AudioCVT
  needed.l
  src_format.w
  dst_format.w
  rate_incr.double
 *buf
  len.l
  len_cvt.l
  len_mult.l
  PB_Align(0, 4)
  len_ratio.double
 *filters[10]
  filter_index.l
  PB_Align(0, 4, 1)
EndStructure

Enumeration   ; SDL_audiostatus
  #SDL_AUDIO_STOPPED = 0
  #SDL_AUDIO_PLAYING
  #SDL_AUDIO_PAUSED
EndEnumeration

#SDL_MIX_MAXVOLUME = 128
; ExecutableFormat=
; EOF