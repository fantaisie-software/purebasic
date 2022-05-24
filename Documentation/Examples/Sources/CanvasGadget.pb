;
; ------------------------------------------------------------
;
;   PureBasic - CanvasGadget example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Enumeration
  #IMAGE_Content  ; stores the previous CanvasGadget content while the mouse is down
  #IMAGE_Color
  #IMAGE_LoadSave
EndEnumeration

Enumeration
  #GADGET_Canvas
  #GADGET_Color
  #GADGET_Brush
  #GADGET_Line
  #GADGET_Box
  #GADGET_Circle
  #GADGET_Fill
  #GADGET_Clear
  #GADGET_Load
  #GADGET_Save
EndEnumeration

Global CurrentColor, CurrentMode, StartX, StartY

; Draw the mouse action result depending on the currently selected mode and event type
;
Procedure DrawAction(x, y, EventType)

  If StartDrawing(CanvasOutput(#GADGET_Canvas))
    Select CurrentMode
    
      Case #GADGET_Brush
        If EventType = #PB_EventType_LeftButtonDown Or EventType = #PB_EventType_MouseMove
          Circle(x, y, 5, CurrentColor)
        EndIf
        
      Case #GADGET_Line
        DrawImage(ImageID(#IMAGE_Content), 0, 0)
        LineXY(StartX, StartY, x, y, CurrentColor)
      
      Case #GADGET_Box
        DrawImage(ImageID(#IMAGE_Content), 0, 0)
        Box(StartX, StartY, x-StartX, y-StartY, CurrentColor)
        
      Case #GADGET_Circle
        DrawImage(ImageID(#IMAGE_Content), 0, 0)
        
        If x > StartX
          rx = x - StartX
        Else
          rx = StartX - x
        EndIf
        
        If y > StartY
          ry = y - StartY
        Else
          ry = StartY - y
        EndIf
        
        If GetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_Modifiers) & #PB_Canvas_Control
          ry = rx
        EndIf
        
        Ellipse(StartX, StartY, rx, ry, CurrentColor)
      
      Case #GADGET_Fill
        If EventType = #PB_EventType_LeftButtonDown
          FillArea(x, y, -1, CurrentColor)
        EndIf
  
    EndSelect
    
    StopDrawing()
  EndIf

EndProcedure

UseJPEGImageDecoder()
UseJPEGImageEncoder()

CurrentColor = $000000
CurrentMode  = #GADGET_Brush
CreateImage(#IMAGE_Color, DesktopScaledX(35), DesktopScaledY(35), 24)
CreateImage(#IMAGE_Content, DesktopScaledX(380), DesktopScaledY(380), 24)

If OpenWindow(0, 0, 0, 460, 400, "CanvasGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
  CanvasGadget(#GADGET_Canvas, 10, 10, 380, 380, #PB_Canvas_ClipMouse)

  ButtonImageGadget(#GADGET_Color, 400, 10, 50, 50, ImageID(#IMAGE_Color))
  
  ButtonGadget(#GADGET_Brush,  400, 100, 50, 25, "Brush",  #PB_Button_Toggle)
  ButtonGadget(#GADGET_Line,   400, 130, 50, 25, "Line",   #PB_Button_Toggle)
  ButtonGadget(#GADGET_Box,    400, 160, 50, 25, "Box",    #PB_Button_Toggle)
  ButtonGadget(#GADGET_Circle, 400, 190, 50, 25, "Circle", #PB_Button_Toggle)
  ButtonGadget(#GADGET_Fill,   400, 220, 50, 25, "Fill",   #PB_Button_Toggle)
    
  ButtonGadget(#GADGET_Clear,  400, 280, 50, 25, "Clear")
  
  ButtonGadget(#GADGET_Load,   400, 335, 50, 25, "Load")
  ButtonGadget(#GADGET_Save,   400, 365, 50, 25, "Save")
  
  SetGadgetState(#GADGET_Brush, 1)
  SetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_Cursor, #PB_Cursor_Cross)

  Repeat
    Event = WaitWindowEvent()
    
    If Event = #PB_Event_Gadget
    
      Select EventGadget()
      
        Case #GADGET_Canvas
          X = GetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_MouseX)
          Y = GetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_MouseY)
          Type = EventType()
        
          Select EventType()
          
            Case #PB_EventType_LeftButtonDown
              ;
              ; This stores the current content of the CanvasGadget in #IMAGE_Content,
              ; so it can be re-drawn while the mouse moves
              ;
              If StartDrawing(ImageOutput(#IMAGE_Content))
                DrawImage(GetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_Image), 0, 0)
                StopDrawing()
              EndIf
              
              StartX = X
              StartY = Y
              DrawAction(X, Y, EventType())

            
            Case #PB_EventType_LeftButtonUp
              DrawAction(X, Y, EventType())
            
            Case #PB_EventType_MouseMove
              If GetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton
                DrawAction(X, Y, EventType())
              EndIf
                      
          EndSelect
        
        Case #GADGET_Color
          CurrentColor = ColorRequester(CurrentColor)
          If StartDrawing(ImageOutput(#IMAGE_Color))
            Box(0, 0, 35, 35, CurrentColor)
            StopDrawing()
            SetGadgetAttribute(#GADGET_Color, #PB_Button_Image, ImageID(#IMAGE_Color))
          EndIf
          
        Case #GADGET_Brush, #GADGET_Line, #GADGET_Box, #GADGET_Circle, #GADGET_Fill
          EventGadget = EventGadget()
          For Gadget = #GADGET_Brush To #GADGET_Fill
            If Gadget = EventGadget
              SetGadgetState(Gadget, 1)
            Else
              SetGadgetState(Gadget, 0) ; unset the state of all other gadgets
            EndIf
          Next Gadget
          CurrentMode = EventGadget
      
        Case #GADGET_Clear
          If StartDrawing(CanvasOutput(#GADGET_Canvas))
            Box(0, 0, 380, 380, $FFFFFF)
            StopDrawing()
          EndIf
      
        Case #GADGET_Load
          File$ = OpenFileRequester("Load Image...", "", "JPEG Images|*.jpeg|All Files|*.*", 0)
          If File$
            If LoadImage(#IMAGE_LoadSave, File$)
              If StartDrawing(CanvasOutput(#GADGET_Canvas))
                Box(0, 0, 380, 380, $FFFFFF)
                DrawImage(ImageID(#IMAGE_LoadSave), 0, 0)
                StopDrawing()
              EndIf
              FreeImage(#IMAGE_LoadSave)
            Else
              MessageRequester("CanvasGadget", "Cannot load image: " + File$)
            EndIf
          EndIf
              
        Case #GADGET_Save
          File$ = SaveFileRequester("Save Image...", File$, "JPEG Images|*.jpeg|All Files|*.*", 0)
          If File$ And (FileSize(File$) = -1 Or MessageRequester("CanvasGadget", "Overwrite this file? " + File$, #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes)
            If CreateImage(#IMAGE_LoadSave, 380, 380, 24) And StartDrawing(ImageOutput(#IMAGE_LoadSave))
              DrawImage(GetGadgetAttribute(#GADGET_Canvas, #PB_Canvas_Image), 0, 0)
              StopDrawing()
              
              If SaveImage(#IMAGE_LoadSave, File$, #PB_ImagePlugin_JPEG) = 0
                MessageRequester("CanvasGadget", "Cannot save image: " + File$)
              EndIf
              
              FreeImage(#IMAGE_LoadSave)
            EndIf
          EndIf
                
      EndSelect
    
    EndIf
    
  Until Event = #PB_Event_CloseWindow

EndIf


