;
; ------------------------------------------------------------
;
;   PureBasic - DPI Aware Load Image example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; This example shows how to load an image taking into account DPI
;

 Procedure LoadImageDPI(Image, File.s)
  Protected Result
 
  Result = LoadImage(Image, File)
  If Result
    If Image = #PB_Any
      ResizeImage(Result, DesktopScaledX(ImageWidth(Result)), DesktopScaledY(ImageHeight(Result)))
    Else
      ResizeImage(Image, DesktopScaledX(ImageWidth(Image)), DesktopScaledY(ImageHeight(Image)))
    EndIf
  EndIf
  ProcedureReturn Result
 EndProcedure

If OpenWindow(0, 0, 0, 200, 100, "ButtonImage", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  If LoadImageDPI(0, #PB_Compiler_Home + "/Examples/Sources/Data/PureBasic.bmp")
    ButtonImageGadget(0, 10, 10, 180, 50, ImageID(0))
  EndIf
  Repeat
  Until WaitWindowEvent() = #PB_Event_CloseWindow
EndIf