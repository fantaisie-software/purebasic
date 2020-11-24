
Structure SDL_RWops_stdio
  autoclose.l
 *fp
EndStructure


Structure SDL_RWops_mem
 *base
 *here
 *stop
EndStructure


Structure SDL_RWops_unknown
 *data1
EndStructure

Structure SDL_RWops
 *seek
 *read
 *write
 *close
  type.l
  PB_Align(0, 4)
  StructureUnion
    stdio.SDL_RWops_stdio
    mem.SDL_RWops_mem
    unknown.SDL_RWops_unknown
  EndStructureUnion
EndStructure
