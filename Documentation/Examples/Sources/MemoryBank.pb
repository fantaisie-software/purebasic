;
; ------------------------------------------------------------
;
;   PureBasic - Memory example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

*Buffer = AllocateMemory(1000)

*Pointer = *Buffer
CopyMemoryString("Hello ", @*Pointer)
CopyMemoryString("World")

*LargerBuffer = ReAllocateMemory(*Buffer, 2000) ; need more memory
If *LargerBuffer
  ; work with *LargerBuffer now with size 2000
  ;
  Debug "The old content is still here:"
  Debug PeekS(*LargerBuffer)
  FreeMemory(*LargerBuffer)
Else
  ; resizing failed, keep working with *Buffer (size 1000)
  ;
  FreeMemory(*Buffer)
EndIf
