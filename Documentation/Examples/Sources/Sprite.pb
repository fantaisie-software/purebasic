;
; ------------------------------------------------------------
;
;   PureBasic - Sprite example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitSprite() = 0 Or InitKeyboard() = 0
  MessageRequester("Error", "Sprite system can't be initialized", 0)
  End
EndIf

If OpenScreen(800, 600, 32, "Sprite")

  ; Load our 16 bit sprite (which is a 24 bit picture in fact, as BMP doesn't support 16 bit format)
  ;
  LoadSprite(0, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp")
  CopySprite(0, 1, 0)
  
  Repeat
    
    ; Inverse the buffers (the back become the front (visible)... And we can do the rendering on the back)
    
    FlipBuffers()
    
    ClearScreen(RGB(0,0,0))
    
    ; Draw our sprite

    ClipSprite(0, 0, 0, x, x/8)
     
    DisplaySprite(0, x, 100)
    DisplaySprite(1, x, x)
    DisplaySprite(0, 600-x, x)
    
    x+1
    
    ExamineKeyboard()
  Until KeyboardPushed(#PB_Key_Escape)
  
Else
  MessageRequester("Error", "Can't open a 800*600 - 32 bit screen !", 0)
EndIf
