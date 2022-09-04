; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Now for all OS
;
Structure PB_LibraryViewer_Image
  Format.l         ; #PB_PixelFormat values (32bit or 24bit only)
  BytesPerPixel.l  ; 3 or 4
  Pitch.l
  Width.l
  Height.l         ; Following is the image data in topdown format
EndStructure


Procedure Plugin_Image_DisplayObject(WindowID, *Buffer, Size)
  *Header.PB_LibraryViewer_Image = *Buffer
  Success = 0
  
  If *Buffer And Size > 0
    *Object = CreateImage(#PB_Any, *Header\Width, *Header\Height, *Header\BytesPerPixel * 8)
    If *Object And StartDrawing(ImageOutput(*Object))
      *OutputBuffer = DrawingBuffer()
      OutputFormat  = DrawingBufferPixelFormat()
      OutputPitch   = DrawingBufferPitch()
      
      If *OutputBuffer
        
        ; little trick: make Pitch negative and start at the last row if Y is reversed
        If OutputFormat & #PB_PixelFormat_ReversedY
          *OutputBuffer + (*Header\Height-1) * OutputPitch
          OutputPitch  = -OutputPitch
          OutputFormat = OutputFormat & (~#PB_PixelFormat_ReversedY)
        EndIf
        
        *InputBuffer = *Buffer + SizeOf(PB_LibraryViewer_Image)
        
        ; If the formats match we just make a fast line copy
        ; Otherwise the Input and Output have the same BPP as we created them
        ; that way so we only need To Map BGR->RGB And RGB->BGR which is rather simple
        ;
        For y = 0 To *Header\Height-1
          *Input.Local_Array  = *InputBuffer + (y * *Header\Pitch)
          *Output.Local_Array = *OutputBuffer + (y * OutputPitch)
          
          If OutputFormat = *Header\Format
            CopyMemory(*Input, *Output, *Header\Width * *Header\BytesPerPixel)
            
          ElseIf *Header\BytesPerPixel = 3 ; no alpha
            
            CompilerIf #CompileMac
              ; OSX is a special case here as it does not have 24bit images, so we need
              ; to convert 24bit to 32bit here for crossplatform compatibility
              ;
              If (*Header\Format = #PB_PixelFormat_24Bits_RGB And OutputFormat = #PB_PixelFormat_32Bits_BGR) Or (*Header\Format = #PB_PixelFormat_24Bits_BGR And OutputFormat = #PB_PixelFormat_32Bits_RGB)
                For x = 1 To *Header\Width
                  *Output\b[0] = *Input\b[2]  ; BGR->RGB + expand to 32bit
                  *Output\b[1] = *Input\b[1]
                  *Output\b[2] = *Input\b[0]
                  *Output\b[3] = $FF
                  
                  *Input + 3
                  *Output + 4
                Next x
              Else
                For x = 1 To *Header\Width
                  *Output\b[0] = *Input\b[0]  ; expand to 32bit only
                  *Output\b[1] = *Input\b[1]
                  *Output\b[2] = *Input\b[2]
                  *Output\b[3] = $FF
                  
                  *Input + 3
                  *Output + 4
                Next x
              EndIf
              
            CompilerElse
              For x = 1 To *Header\Width
                *Output\b[0] = *Input\b[2]
                *Output\b[1] = *Input\b[1]
                *Output\b[2] = *Input\b[0]
                
                *Input + 3
                *Output + 3
              Next x
              
            CompilerEndIf
            
          Else
            For x = 1 To *Header\Width
              *Output\b[0] = *Input\b[2]
              *Output\b[1] = *Input\b[1]
              *Output\b[2] = *Input\b[0]
              *Output\b[3] = *Input\b[3] ; alpha is always at the end
              
              *Input + 4
              *Output + 4
            Next x
            
          EndIf
        Next y
        
        Success = 1
      EndIf
      StopDrawing()
    EndIf
  EndIf
  
  If Success
    ; Create the gadget for the image. No UseGadgetList needed, as this is an internal plugin
    ImageGadget(#PB_Any, 0, 0, *Header\Width, *Header\Height, ImageID(*Object))
    
    ; The only thing needed to be freed later is the Image, so pass this back
    ProcedureReturn *Object
  Else
    ProcedureReturn 0
  EndIf
EndProcedure


Procedure Plugin_Image_RemoveObject(*Object)
  FreeImage(*Object)
EndProcedure

Procedure Plugin_Image_GetObjectWidth(*Object)
  ProcedureReturn ImageWidth(*Object)
EndProcedure

Procedure Plugin_Image_GetObjectHeight(*Object)
  ProcedureReturn ImageHeight(*Object)
EndProcedure


; Register with LibraryViewer
;
AddElement(LibraryPlugins())
LibraryPlugins()\LibraryID$      = "PB_LIBRARY_Image"
LibraryPlugins()\DisplayObject   = @Plugin_Image_DisplayObject()
LibraryPlugins()\RemoveObject    = @Plugin_Image_RemoveObject()
LibraryPlugins()\GetObjectWidth  = @Plugin_Image_GetObjectWidth()
LibraryPlugins()\GetObjectHeight = @Plugin_Image_GetObjectHeight()

; Register for Sprite/Sprite3D lib as well... uses the same format
;
AddElement(LibraryPlugins())
LibraryPlugins()\LibraryID$      = "PB_LIBRARY_Sprite"
LibraryPlugins()\DisplayObject   = @Plugin_Image_DisplayObject()
LibraryPlugins()\RemoveObject    = @Plugin_Image_RemoveObject()
LibraryPlugins()\GetObjectWidth  = @Plugin_Image_GetObjectWidth()
LibraryPlugins()\GetObjectHeight = @Plugin_Image_GetObjectHeight()

AddElement(LibraryPlugins())
LibraryPlugins()\LibraryID$      = "PB_LIBRARY_Sprite3D"
LibraryPlugins()\DisplayObject   = @Plugin_Image_DisplayObject()
LibraryPlugins()\RemoveObject    = @Plugin_Image_RemoveObject()
LibraryPlugins()\GetObjectWidth  = @Plugin_Image_GetObjectWidth()
LibraryPlugins()\GetObjectHeight = @Plugin_Image_GetObjectHeight()

