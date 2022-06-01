;
; ------------------------------------------------------------
;
;   PureBasic - ImagePlugin example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Enable all the decoders than PureBasic actually supports
;
UseJPEGImageDecoder()
UseTGAImageDecoder()
UsePNGImageDecoder()
UseTIFFImageDecoder()
UseGIFImageDecoder()

; Enable all the encoders than PureBasic actually supports
;
UseJPEGImageEncoder()
UsePNGImageEncoder()


If OpenWindow(0, 0, 0, 250, 130, "PureBasic - Image Converter", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)

  CreateToolBar(0, WindowID(0))
    ToolBarImageButton(0, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Open.png"))
    ToolBarImageButton(1, LoadImage(0, #PB_Compiler_Home + "examples/sources/Data/ToolBar/Save.png"))
    DisableToolBarButton(0, 1, 1)    ; disable the save button
    
  ImageGadget(0, 0, 28, WindowWidth(0), WindowHeight(0), 0, #PB_Image_Border)
  
  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Menu  ; ToolBar are acting as menu
    
      Select EventMenu()
      
        Case 0  ; Open
        
          Filename$ = OpenFileRequester("Choose a picture", "", "All Images Formats|*.bmp;*.jpg;*.png;*.tif;*.tga;*.gif", 0)
          If Filename$
            
            If UCase(GetExtensionPart(Filename$)) = "GIF"
              MessageRequester("About GIF files", "Please, take a look at the example 'ImagePlugin_GIF.pb' to see  animated GIF")
            EndIf
            
            If LoadImage(0, Filename$)
              SetGadgetState(0, ImageID(0))  ; change the picture in the gadget
              DisableToolBarButton(0, 1, 0)    ; enable the save button
              ResizeWindow(0, #PB_Ignore, #PB_Ignore, DesktopUnscaledX(ImageWidth(0)+4), DesktopUnscaledY(ImageHeight(0)+34))
            EndIf
          
          EndIf
        
        Case 1  ; Save
          
          Filename$ = SaveFileRequester("Save a picture", Left(Filename$, Len(Filename$)-Len(GetExtensionPart(Filename$))-1), "BMP Format|*.bmp|JPEG Format|*.jpg|PNG Format|*.png", 0)
          If Filename$
          
            Select SelectedFilePattern()
            
              Case 0  ; BMP
                ImageFormat = #PB_ImagePlugin_BMP
                Extension$  = "bmp"

              Case 1  ; JPEG
                ImageFormat = #PB_ImagePlugin_JPEG
                Extension$  = "jpg"
                
              Case 2  ; PNG
                ImageFormat = #PB_ImagePlugin_PNG
                Extension$  = "png"

            EndSelect
            
            If LCase(GetExtensionPart(Filename$)) <> Extension$
              Filename$ + "." + Extension$
            EndIf
            
            If SaveImage(0, Filename$, ImageFormat)
              MessageRequester("Information", "Image saved successfully", 0)
            EndIf
          
          EndIf
      
      EndSelect
    
    EndIf
    
  Until Event = #PB_Event_CloseWindow  ; If the user has pressed on the close button
  
EndIf

End   ; All is automatically freed by PureBasic
