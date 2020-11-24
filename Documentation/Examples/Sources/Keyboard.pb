;
; ------------------------------------------------------------
;
;   PureBasic - Keyboard example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If InitKeyboard() = 0 Or InitSprite() = 0
  MessageRequester("Error", "Can't initialize the sprite system.", 0)
  End
EndIf

MessageRequester("Information", "This will test the fast keyboard access..."+#LF$+"Press 'ESC' to quit!", 0)


If OpenScreen(800, 600, 32, "Keyboard")

  x = 100
  y = 100
  
  LoadSprite(0, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp")

  Repeat
  
    FlipBuffers()
    
    ClearScreen(RGB(0,0,0))
  
    ExamineKeyboard()
    
    If KeyboardPushed(#PB_Key_Left)
      x-1
    EndIf
  
    If KeyboardPushed(#PB_Key_Right)
      x+1
    EndIf
  
    If KeyboardPushed(#PB_Key_Up)
      y-1
    EndIf
  
    If KeyboardPushed(#PB_Key_Down)
      y+1
    EndIf
    
    For OffsetY=0 To 600 Step 70
      For OffsetX=0 To 800 Step 200
        DisplaySprite(0, OffsetX+x, y+OffsetY)
      Next
      
      For OffsetX=0 To 800 Step 200
        DisplaySprite(0, OffsetX+x+90, y+OffsetY+35)
      Next
    Next
    
  Until KeyboardPushed(#PB_Key_Escape)

Else
  MessageRequester("Error", "Impossible to open a 800*600 32 bit screen",0)
EndIf

End