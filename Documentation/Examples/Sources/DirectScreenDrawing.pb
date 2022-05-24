;
; ------------------------------------------------------------
;
;   PureBasic - Drawing via Direct Screen Access (DSA)
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
;

; We disable the debugger to run at full speed !
DisableDebugger

#ScreenWidth  = 800  ; Feel free to change this to see the pixel filling speed !
#ScreenHeight = 600

If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Can't initialize the GFX system",0)
EndIf

Structure Pixel
  Pixel.l
EndStructure

Procedure.f GSin(angle.f)
  ProcedureReturn Sin(angle*(2*3.14/360))
EndProcedure

; Pre-calculated values are faster than realtime calculated ones...
; ... so we save them in an array before starting gfx operations
Dim CosTable(#ScreenWidth*2)
Dim ColorTable(255)

For i = 0 To #ScreenWidth*2
  CosTable(i) = GSin(360*i/320)* 32 + 32
Next


If OpenScreen(#ScreenWidth, #ScreenHeight, 32, "PB Plasma")

  Repeat
    Wave+6
    If Wave > 320 : Wave = 0 : EndIf
    
    If StartDrawing(ScreenOutput())
      Buffer      = DrawingBuffer()             ; Get the start address of the screen buffer
      Pitch       = DrawingBufferPitch()        ; Get the length (in byte) took by one horizontal line
      PixelFormat = DrawingBufferPixelFormat()  ; Get the pixel format.
      
      ; We don't care about Y for this effect, so remove it from the fags
      PixelFormat & ~#PB_PixelFormat_ReversedY
      
      If PixelFormat = #PB_PixelFormat_32Bits_RGB Or PixelFormat = #PB_PixelFormat_24Bits_RGB
        For i = 0 To 255
          ColorTable(i) = i << 16 ; Blue is at the 3th pixel
        Next
      ElseIf PixelFormat = #PB_PixelFormat_32Bits_BGR Or PixelFormat = #PB_PixelFormat_24Bits_BGR
        For i = 0 To 255
          ColorTable(i) = i       ; Blue is at the 1th pixel
        Next
      EndIf
      
      If PixelFormat = #PB_PixelFormat_32Bits_RGB Or PixelFormat = #PB_PixelFormat_32Bits_BGR
        Offset = 4
      Else ; 24-bit
        Offset = 3
      EndIf
    
      For y = 0 To #ScreenHeight-1
        pos1 = CosTable(y+wave)
        
        *Line.Pixel = Buffer+Pitch*y
        
        For x = 0 To #ScreenWidth-1
          pos2 = (CosTable(x+Wave) + CosTable(x+y) + pos1)
          
          *Line\Pixel = ColorTable(pos2) ; Write the pixel directly to the memory !
          *Line+Offset
          
          ; You can try with regular plot to see the speed difference
          ; Plot(x, y, ColorTable(pos2))
        Next
      Next
      
      StopDrawing()
    EndIf
    
    ExamineKeyboard()
    
    FlipBuffers()
     
  Until KeyboardPushed(#PB_Key_Escape)

Else
  MessageRequester("Error","Can't open the screen !",0)
EndIf

End
