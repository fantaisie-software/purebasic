;
; ------------------------------------------------------------
;
;   PureBasic - Printer example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

If PrintRequester()

  If StartPrinting("PureBasic Test")
  
    LoadFont(0, "Arial", 30)
    LoadFont(1, "Arial", 100)
  
    If StartDrawing(PrinterOutput())
      
      BackColor(RGB(255, 255, 255)) ; Uses white as back color, usuful when printing on a white sheet
      FrontColor(RGB(0, 0, 0)) ; Use black for standard text color
      
      DrawingFont(FontID(0))
      DrawText(100, 100, "PureBasic Printer Test")
      
      DrawingFont(FontID(1))
      DrawText(100, 400, "PureBasic Printer Test 2")
    
      If LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/PureBasic.bmp")
        DrawImage(ImageID(0), 200, 600)
      Else
        MessageRequester("Error","Can't load the image")
      EndIf
      
      Box(200, 1000, 100, 100, RGB(255, 0, 0)) ; Draw a red box
        
      StopDrawing()
    EndIf
    
    StopPrinting()
  EndIf
EndIf