; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;- ----- Common stuff -----

Declare RGBToHSV(Color, *h.FLOAT, *s.FLOAT, *v.FLOAT)
Declare RGBToHSL(Color, *h.FLOAT, *s.FLOAT, *l.FLOAT)
Declare HueToRGB(h.f)
Declare HSVToRGB(h.f, s.f, v.f)
Declare HSLToRGB(h.f, s.f, l.f)

Prototype ColorPicker_Mode_Setup(*Entry, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
Prototype ColorPicker_Mode_Event(*Entry, Gadget, Type)

Structure ColorPickerData Extends ToolsPanelEntry
  Mode$       ; current mode
  RGBColor.l  ; current RGB color (no alpha component)
  
  ; for alpha mode
  UseAlpha.l
  VerticalAlpha.l ; if true, draw alpha above solid in the color field
  a.f
  
  IgnoreInputField.l ; see ColorPicker_UpdateColorField
  
  ; callback for current mode
  SetupFunction.ColorPicker_Mode_Setup
  EventFunction.ColorPicker_Mode_Event
  
  ; for RGB mode
  r.f
  g.f
  b.f
  
  ; for HSL/HSV mode
  h.f
  s.f
  l.f
  v.f
  
  ; for color wheel
  TriangleRadius.l
  TriangleSide.f
  TriangleHeight.f
  
  ; for Palette/Name
  First.l
  Rows.l
  Cols.l
  RowHeight.l
  BoxWidth.l
  Palette$
  CompilerIf #CompileWindows
    ScrollCallback.i
  CompilerEndIf
  
EndStructure

Structure ColorEntry
  Name$
  Color.l
EndStructure

Structure Palette
  ID$
  Name$
  Count.l
  Array Entry.ColorEntry(0)
EndStructure

Structure ColorHistory
  Color.l
  Alpha.l ; -1 if not used
EndStructure

#ColorPicker_History = 24

Global Dim ColorPicker_History.ColorHistory(#ColorPicker_History-1)

Global *ColorPicker.ColorPickerData ; needed for filter access
Global NewList PaletteList.Palette()
Global *Palette.Palette
Global FilteredPalette.Palette ; this is always a filtered copy of the current palette

Declare ColorPicker_ResizeHandler(*Entry.ColorPickerData, PanelWidth, PanelHeight)
Declare ColorPicker_UpdateColor(*Entry.ColorPickerData, Color)
Declare ColorPicker_TriggerResize(*Entry.ColorPickerData)

CompilerIf #CompileWindows
  Global ScrollBarOldCallback ; for scrollbar updates  
CompilerEndIf



Procedure ColorPicker_LoadPalettes(*Entry.ColorPickerData)
  
  Select UCase(CurrentLanguage$)
    Case "DEUTSCH":  Lang$ = "de"
    Case "FRANCAIS": Lang$ = "fr"
    Default:         Lang$ = "en"
  EndSelect
  
  If ListSize(PaletteList()) = 0
    
    If LoadXML(#XML_ColorTable, PureBasicPath$ + #DEFAULT_CatalogPath + "ColorTable.xml") And XMLStatus(#XML_ColorTable) = #PB_XML_Success
      *Main = MainXMLNode(#XML_ColorTable)
      If *Main And GetXMLNodeName(*Main) = "table"
        
        *Palette = ChildXMLNode(*Main)
        While *Palette
          If XMLNodeType(*Palette) = #PB_XML_Normal And GetXMLNodeName(*Palette) = "palette"
            
            AddElement(PaletteList())
            PaletteList()\Count = 0
            PaletteList()\ID$   = GetXMLAttribute(*Palette, "id")
            PaletteList()\Name$ = GetXMLAttribute(*Palette, Lang$)
            If PaletteList()\Name$ = ""
              PaletteList()\Name$ = GetXMLAttribute(*Palette, "en") ; always the fallback
            EndIf
            
            ; do a count
            *Color = ChildXMLNode(*Palette)
            While *Color
              If XMLNodeType(*Color) = #PB_XML_Normal And GetXMLNodeName(*Color) = "color"
                PaletteList()\Count + 1
              EndIf
              *Color = NextXMLNode(*Color)
            Wend
            If PaletteList()\Count > 0
              Dim PaletteList()\Entry(PaletteList()\Count-1)
            EndIf
            
            ; read entries
            i = 0
            *Color = ChildXMLNode(*Palette)
            While *Color
              If XMLNodeType(*Color) = #PB_XML_Normal And GetXMLNodeName(*Color) = "color"
                PaletteList()\Entry(i)\Name$ = GetXMLAttribute(*Color, Lang$)
                If PaletteList()\Entry(i)\Name$ = ""
                  PaletteList()\Entry(i)\Name$ = GetXMLAttribute(*Color, "en") ; fallback
                EndIf
                PaletteList()\Entry(i)\Color = RGB(Val(Trim(GetXMLAttribute(*Color, "r"))), Val(Trim(GetXMLAttribute(*Color, "g"))), Val(Trim(GetXMLAttribute(*Color, "b"))))
                i + 1
              EndIf
              *Color = NextXMLNode(*Color)
            Wend
          EndIf
          *Palette = NextXMLNode(*Palette)
        Wend
        
      EndIf
    EndIf
    
    
    ; if still zero, add an empty palette to the list so we do not have to handle
    ; that condition later
    ;
    If ListSize(PaletteList()) = 0
      AddElement(PaletteList())
      PaletteList()\Name$ = ""
      PaletteList()\Count = 0
    EndIf
    
    FirstElement(PaletteList())
    *Palette = @PaletteList()
    
    
    ; fill the combobox
    ;
    ClearGadgetItems(#GADGET_Color_Scheme)
    index = 0
    ForEach PaletteList()
      AddGadgetItem(#GADGET_Color_Scheme, -1, PaletteList()\Name$)
      If PaletteList()\ID$ = *Entry\Palette$
        index = ListIndex(PaletteList())
        *Palette = @PaletteList()
      EndIf
    Next PaletteList()
    SetGadgetState(#GADGET_Color_Scheme, index)
  EndIf
  
EndProcedure


; create the chessfield effect below transparent areas
;
Procedure ColorPicker_TransparentFilter(x, y, SourceColor, TargetColor)
  If (x % 14 < 7 And y % 14 < 7) Or (x % 14 >= 7 And y % 14 >= 7)
    ProcedureReturn AlphaBlend(SourceColor, $FFC0C0C0)
  Else
    ProcedureReturn AlphaBlend(SourceColor, $FFFFFFFF)
  EndIf
EndProcedure


; Draw a simple cross marker for 2d areas
;
Procedure ColorPicker_DrawCross(x, y)
  Box(x-8, y-1, 7, 3, $000000)
  Box(x+2, y-1, 7, 3, $000000)
  Box(x-1, y-8, 3, 7, $000000)
  Box(x-1, y+2, 3, 7, $000000)
  
  Line(x-5, y, 3, 1, $FFFFFF)
  Line(x+3, y, 3, 1, $FFFFFF)
  Line(x, y-5, 1, 3, $FFFFFF)
  Line(x, y+3, 1, 3, $FFFFFF)
EndProcedure

; Draw a double arrow marker for slides
;
Procedure ColorPicker_DrawArrow(x, y1, y2)
  Line(x-4, y1,   9, 1, $FFFFFF)
  Line(x-3, y1+1, 7, 1, $FFFFFF)
  Line(x-2, y1+2, 5, 1, $FFFFFF)
  Line(x-1, y1+3, 3, 1, $FFFFFF)
  Line(x,   y1+4, 1, 1, $FFFFFF) ; use Line here too, so it is bounds checked (unlike Plot)
  Line(x-3, y1,   7, 1, $000000)
  Line(x-2, y1+1, 5, 1, $000000)
  Line(x-1, y1+2, 3, 1, $000000)
  Line(x,   y1+3, 1, 1, $000000)
  
  Line(x-4, y2,   9, 1, $FFFFFF)
  Line(x-3, y2-1, 7, 1, $FFFFFF)
  Line(x-2, y2-2, 5, 1, $FFFFFF)
  Line(x-1, y2-3, 3, 1, $FFFFFF)
  Line(x,   y2-4, 1, 1, $FFFFFF)
  Line(x-3, y2,   7, 1, $000000)
  Line(x-2, y2-1, 5, 1, $000000)
  Line(x-1, y2-2, 3, 1, $000000)
  Line(x,   y2-3, 1, 1, $000000)
EndProcedure

; get a RGBA color from an RGB and A value
;
Procedure ColorPicker_AddAlpha(Color, Alpha)
  ProcedureReturn (Color & $FFFFFF) | (Alpha << 24)
EndProcedure


;- ----- RGB picker -----

Procedure ColorPicker_RGB_Update(*Entry.ColorPickerData)
  r = Int(*Entry\r * 255.0)
  g = Int(*Entry\g * 255.0)
  b = Int(*Entry\b * 255.0)
  
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    w = OutputWidth()
    h = OutputHeight()
    Box(0, 0, w, h, $000000)
    For x = 0 To w-3
      Line(x+1, 1, 1, h-2, RGB(Int((x * 255.0) / (w-3)), g, b))
    Next x
    ColorPicker_DrawArrow(1+*Entry\r * (w-3), 1, DesktopScaledY(28))
    StopDrawing()
  EndIf
  
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas2))
    w = OutputWidth()
    h = OutputHeight()
    Box(0, 0, w, h, $000000)
    For x = 0 To w-3
      Line(x+1, 1, 1, h-2, RGB(r, Int((x * 255.0) / (w-3)), b))
    Next x
    ColorPicker_DrawArrow(1+*Entry\g * (w-3), 1, DesktopScaledY(28))
    StopDrawing()
  EndIf
  
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas3))
    w = OutputWidth()
    h = OutputHeight()
    Box(0, 0, w, h, $000000)
    For x = 0 To w-3
      Line(x+1, 1, 1, h-2, RGB(r, g, Int((x * 255.0) / (w-3))))
    Next x
    ColorPicker_DrawArrow(1+*Entry\b * (w-3), 1, DesktopScaledY(28))
    StopDrawing()
  EndIf
  
  ColorPicker_UpdateColor(*Entry, RGB(r, g, b))
EndProcedure


Procedure ColorPicker_RGB_Setup(*Entry.ColorPickerData, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
  HideGadget(#GADGET_Color_Canvas1, 0)
  HideGadget(#GADGET_Color_Canvas2, 0)
  HideGadget(#GADGET_Color_Canvas3, 0)
  HideGadget(#GADGET_Color_Scheme, 1)
  HideGadget(#GADGET_Color_Scroll, 1)
  HideGadget(#GADGET_Color_Filter, 1)
  HideGadget(#GADGET_Color_Label1, 0)
  HideGadget(#GADGET_Color_Label2, 0)
  HideGadget(#GADGET_Color_Label3, 0)
  
  SetGadgetText(#GADGET_Color_Label1, "R: ")
  SetGadgetText(#GADGET_Color_Label2, "G: ")
  SetGadgetText(#GADGET_Color_Label3, "B: ")
  GetRequiredSize(#GADGET_Color_Label1, @LabelWidth, @LabelHeight)
  Offset = (30-LabelHeight) / 2
  
  ResizeGadget(#GADGET_Color_Label1, CanvasX, CanvasY+Offset+5,  LabelWidth, LabelHeight)
  ResizeGadget(#GADGET_Color_Label2, CanvasX, CanvasY+Offset+45, LabelWidth, LabelHeight)
  ResizeGadget(#GADGET_Color_Label3, CanvasX, CanvasY+Offset+85, LabelWidth, LabelHeight)
  
  ResizeGadget(#GADGET_Color_Canvas1, CanvasX+LabelWidth, CanvasY+5,  CanvasWidth-LabelWidth, 30)
  ResizeGadget(#GADGET_Color_Canvas2, CanvasX+LabelWidth, CanvasY+45, CanvasWidth-LabelWidth, 30)
  ResizeGadget(#GADGET_Color_Canvas3, CanvasX+LabelWidth, CanvasY+85, CanvasWidth-LabelWidth, 30)
  
  ; Get the current color
  ;
  *Entry\r = Red(*Entry\RGBColor)   / 255.0
  *Entry\g = Green(*Entry\RGBColor) / 255.0
  *Entry\b = Blue(*Entry\RGBColor)  / 255.0
  
  ColorPicker_RGB_Update(*Entry)
  
  ProcedureReturn 115 ; actual height used
EndProcedure


Procedure ColorPicker_RGB_Event(*Entry.ColorPickerData, Gadget, Type)
  If Gadget = #GADGET_Color_Canvas1 Or Gadget = #GADGET_Color_Canvas2 Or Gadget = #GADGET_Color_Canvas3
    If Type = #PB_EventType_LeftButtonDown Or (Type = #PB_EventType_MouseMove And GetGadgetAttribute(Gadget, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
      
      value.f = (GetGadgetAttribute(Gadget, #PB_Canvas_MouseX) - 1) / (DesktopScaledX(GadgetWidth(Gadget)) - 3)
      If value < 0: value = 0: EndIf
      If value > 1: value = 1: EndIf
      
      Select Gadget
        Case #GADGET_Color_Canvas1: *Entry\r = value
        Case #GADGET_Color_Canvas2: *Entry\g = value
        Case #GADGET_Color_Canvas3: *Entry\b = value
      EndSelect
      
      *Entry\RGBColor = RGB(*Entry\r * 255, *Entry\g * 255, *Entry\b * 255)
      ColorPicker_RGB_Update(*Entry)
    EndIf
  EndIf
EndProcedure

;- ----- HSV picker -----

Procedure ColorPicker_HSV_Update(*Entry.ColorPickerData, DrawAll)
  
  ; draw the s/v field on a backing image and only
  ; change it if the hue changed as it is quite slow to draw
  ;
  If DrawAll
    If StartDrawing(ImageOutput(#IMAGE_Color_Content2))
      w = OutputWidth()
      h = OutputHeight()
      Box(0, 0, w, h, $000000)
      
      For x = 0 To w-3
        For y = 0 To h-3
          Plot(1+x, 1+y, HSVToRGB(*Entry\h, x / (w-3), 1.0-(y / (h-3))))
        Next y
      Next x
      
      StopDrawing()
    EndIf
  EndIf
  
  ;  redraw the canvases with new markers
  ;
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    DrawImage(ImageID(#IMAGE_Color_Content1), 0, 0)
    ColorPicker_DrawArrow(1 + Int((*Entry\h * (OutputWidth() - 3)) / 360.0), 1, DesktopScaledY(28))
    StopDrawing()
  EndIf
  
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas2))
    DrawImage(ImageID(#IMAGE_Color_Content2), 0, 0)
    ColorPicker_DrawCross(1 + Int(*Entry\s * (OutputWidth()-3)), 1 + Int((1.0 - *Entry\v) * (OutputHeight()-3)))
    StopDrawing()
  EndIf
  
  ColorPicker_UpdateColor(*Entry, HSVToRGB(*Entry\h, *Entry\s, *Entry\v))
EndProcedure


Procedure ColorPicker_HSV_Setup(*Entry.ColorPickerData, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
  
  ; Limit the height to a 4/3 ratio to avoid an overly long picker area
  If CanvasHeight*3 > CanvasWidth*4
    CanvasHeight = (CanvasWidth * 4) / 3
  EndIf
  
  
  ; Create hue image and draw it
  ImageWidth = DesktopScaledX(CanvasWidth)
  ImageHeight = DesktopScaledY(CanvasHeight)
  
  CreateImage(#IMAGE_Color_Content1, ImageWidth, ImageHeight, 24)
  If StartDrawing(ImageOutput(#IMAGE_Color_Content1))
    Box(0, 0, ImageWidth, ImageHeight, $000000)
    For x = 0 To ImageWidth-3
      Line(x+1, 1, 1, ImageHeight-3, HueToRGB((x * 360.0) / (ImageWidth-3)))
    Next x
    StopDrawing()
  EndIf
  
  ; Create image for s/v field
  CreateImage(#IMAGE_Color_Content2, ImageWidth, ImageHeight-35, 24)
  
  RGBToHSV(*Entry\RGBColor, @*Entry\h, @*Entry\s, @*Entry\v)
  
  HideGadget(#GADGET_Color_Canvas1, 0)
  HideGadget(#GADGET_Color_Canvas2, 0)
  HideGadget(#GADGET_Color_Canvas3, 1)
  HideGadget(#GADGET_Color_Scheme, 1)
  HideGadget(#GADGET_Color_Scroll, 1)
  HideGadget(#GADGET_Color_Filter, 1)
  HideGadget(#GADGET_Color_Label1, 1)
  HideGadget(#GADGET_Color_Label2, 1)
  HideGadget(#GADGET_Color_Label3, 1)
  
  ResizeGadget(#GADGET_Color_Canvas1, CanvasX, CanvasY, CanvasWidth, 30)
  ResizeGadget(#GADGET_Color_Canvas2, CanvasX, CanvasY+35, CanvasWidth, CanvasHeight-35)
  
  ColorPicker_HSV_Update(*Entry, #True)
  
  ProcedureReturn CanvasHeight ; actual height used
EndProcedure


Procedure ColorPicker_HSV_Event(*Entry.ColorPickerData, Gadget, Type)
  If Gadget = #GADGET_Color_Canvas1
    If Type = #PB_EventType_LeftButtonDown Or (Type = #PB_EventType_MouseMove And GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
      *Entry\h = ((GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseX) - 1) * 360.0) / (DesktopScaledX(GadgetWidth(#GADGET_Color_Canvas1)) - 3)
      If *Entry\h < 0: *Entry\h = 0: EndIf
      If *Entry\h >= 360: value = 360: EndIf
      ColorPicker_HSV_Update(*Entry, #True) ; redraw main area
    EndIf
  ElseIf Gadget = #GADGET_Color_Canvas2
    If Type = #PB_EventType_LeftButtonDown Or (Type = #PB_EventType_MouseMove And GetGadgetAttribute(#GADGET_Color_Canvas2, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
      *Entry\s = (GetGadgetAttribute(#GADGET_Color_Canvas2, #PB_Canvas_MouseX)-1) / (DesktopScaledX(GadgetWidth(#GADGET_Color_Canvas2))-3)
      *Entry\v = 1.0 - (GetGadgetAttribute(#GADGET_Color_Canvas2, #PB_Canvas_MouseY)-1) / (DesktopScaledX(GadgetHeight(#GADGET_Color_Canvas2))-3)
      If *Entry\s < 0: *Entry\s = 0: EndIf
      If *Entry\s > 1: *Entry\s = 1: EndIf
      If *Entry\v < 0: *Entry\v = 0: EndIf
      If *Entry\v > 1: *Entry\v = 1: EndIf
      ColorPicker_HSV_Update(*Entry, #False)     ; no redraw of the s/v area
    EndIf
  EndIf
EndProcedure

;- ----- HSL picker -----

Procedure ColorPicker_HSL_Update(*Entry.ColorPickerData)
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    DrawImage(ImageID(#IMAGE_Color_Content1), 0, 0)
    ColorPicker_DrawCross(1 + Int((*Entry\h * (OutputWidth()-3)) / 360.0), 1 + Int((1.0-*Entry\s) * (OutputHeight()-3)))
    StopDrawing()
  EndIf
  
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas2))
    w = OutputWidth()
    h = OutputHeight()
    Box(0, 0, w, h, $000000)
    For x = 0 To w-3
      Line(1+x, 1+y, 1, h-2, HSLToRGB(*Entry\h, *Entry\s, (x / (w-3))))
    Next x
    ColorPicker_DrawArrow(1 + Int(*Entry\l * (w - 3)), 1, h-2)
    StopDrawing()
  EndIf
  
  ColorPicker_UpdateColor(*Entry, HSLToRGB(*Entry\h, *Entry\s, *Entry\l))
EndProcedure

Procedure ColorPicker_HSL_Setup(*Entry.ColorPickerData, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
  
  ; Limit the height to a 4/3 ratio to avoid an overly long picker area
  If CanvasHeight*3 > CanvasWidth*4
    CanvasHeight = (CanvasWidth * 4) / 3
  EndIf
  
  ; Create h/v image and draw it
  ImageWidth = DesktopScaledX(CanvasWidth)
  ImageHeight = DesktopScaledY(CanvasHeight)
  
  CreateImage(#IMAGE_Color_Content1, ImageWidth, ImageHeight -35, 24)
  If StartDrawing(ImageOutput(#IMAGE_Color_Content1))
    Box(0, 0, w, ImageHeight-35, $000000)
    For x = 0 To ImageWidth-3
      For y = 0 To ImageHeight-38
        Plot(1+x, 1+y, HSLToRGB((x * 360.0) / (ImageWidth-3), 1.0-(y / (ImageHeight-37)), 0.5)) ; divide by h-42, as a value of 0 in s is not allowed
      Next y
    Next x
    StopDrawing()
  EndIf
  
  RGBToHSL(*Entry\RGBColor, @*Entry\h, @*Entry\s, @*Entry\l)
  
  HideGadget(#GADGET_Color_Canvas1, 0)
  HideGadget(#GADGET_Color_Canvas2, 0)
  HideGadget(#GADGET_Color_Canvas3, 1)
  HideGadget(#GADGET_Color_Scheme, 1)
  HideGadget(#GADGET_Color_Scroll, 1)
  HideGadget(#GADGET_Color_Filter, 1)
  HideGadget(#GADGET_Color_Label1, 1)
  HideGadget(#GADGET_Color_Label2, 1)
  HideGadget(#GADGET_Color_Label3, 1)
  
  ResizeGadget(#GADGET_Color_Canvas1, CanvasX, CanvasY, CanvasWidth, CanvasHeight-35)
  ResizeGadget(#GADGET_Color_Canvas2, CanvasX, CanvasY+CanvasHeight-30, CanvasWidth, 30)
  
  ColorPicker_HSL_Update(*Entry)
  
  ProcedureReturn CanvasHeight ; actual height used
EndProcedure

Procedure ColorPicker_HSL_Event(*Entry.ColorPickerData, Gadget, Type)
  If Gadget = #GADGET_Color_Canvas1
    If Type = #PB_EventType_LeftButtonDown Or (Type = #PB_EventType_MouseMove And GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
      *Entry\h = ((GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseX)-1) * 360.0) / (DesktopScaledX(GadgetWidth(#GADGET_Color_Canvas1))-3)
      *Entry\s = 1.0 - (GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseY)-1) / (DesktopScaledY(GadgetHeight(#GADGET_Color_Canvas1))-2)
      If *Entry\h < 0: *Entry\h = 0: EndIf
      If *Entry\h >= 360.0: *Entry\h = 360: EndIf
      If *Entry\s <= 0: *Entry\s = 0.001: EndIf
      If *Entry\s > 1: *Entry\s = 1: EndIf
      ColorPicker_HSL_Update(*Entry)
    EndIf
  ElseIf Gadget = #GADGET_Color_Canvas2
    If Type = #PB_EventType_LeftButtonDown Or (Type = #PB_EventType_MouseMove And GetGadgetAttribute(#GADGET_Color_Canvas2, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
      *Entry\l = (GetGadgetAttribute(#GADGET_Color_Canvas2, #PB_Canvas_MouseX)-1) / (DesktopScaledX(GadgetWidth(#GADGET_Color_Canvas2))-3)
      If *Entry\l < 0: *Entry\l = 0: EndIf
      If *Entry\l > 1: *Entry\l = 1: EndIf
      ColorPicker_HSL_Update(*Entry)
    EndIf
  EndIf
EndProcedure

;- ----- Wheel picker (HSV) -----

; rotate in degrees
Procedure Rotate(Angle.f, *x.FLOAT, *y.FLOAT)
  cos.f = Cos(Radian(Angle))
  sin.f = Sin(Radian(Angle))
  x.f = *x\f * cos - *y\f * sin
  y.f = *x\f * sin + *y\f * cos
  *x\f = x
  *y\f = y
EndProcedure

Procedure ColorPicker_WheelFilter(x, y, SourceColor, TargetColor)
  Center  = OutputWidth() / 2
  Angle.f = Mod(Degree(ATan2(x-Center, y-Center)) + 360, 360)
  ProcedureReturn HueToRGB(Angle)
EndProcedure

Procedure ColorPicker_WheelCenterFilter(x, y, SourceColor, TargetColor)
  Center = OutputWidth() / 2
  
  ; first rotate the x/y around the center by the negative (hue+30) degrees
  ; so the triangle is upright, with the v direction parallel to the y axis and
  ; the s direction parallel to x
  ;
  r_x.f = x - Center
  r_y.f = y - Center
  Rotate(-(*ColorPicker\h + 30.0), @r_x, @r_y)
  
  ; v is now just the reversed y coordinate scaled by the triangle height
  ;
  v.f = 1.0 - (r_y + (*ColorPicker\TriangleHeight / 3.0)) / *ColorPicker\TriangleHeight
  
  ; s is the x coordinate scaled by the triangle side
  ; the triangle side has to be scaled by v first, as we want a triangle shape, not a square shape
  ;
  s.f = (r_x + ((*ColorPicker\TriangleSide * v) /  2.0)) / (*ColorPicker\TriangleSide * v)
  
  ; now we have the color
  ;
  ProcedureReturn HSVToRGB(*ColorPicker\h, s, v)
EndProcedure


Procedure ColorPicker_Wheel_Update(*Entry.ColorPickerData, DrawAll)
  
  ; draw the triangle on the backing image and only update it when
  ; needed, as it is quite slow
  If DrawAll
    If StartDrawing(ImageOutput(#IMAGE_Color_Content1))
      w = OutputWidth()
      h = OutputHeight()
      Center = w / 2
      Radius = w / 2 - 10
      
      CompilerIf #CompileLinuxGtk
        *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
        linbackcolor= RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
      CompilerEndIf
      
      ; clear the center
      DrawingMode(#PB_2DDrawing_Default)
      CompilerIf #CompileLinux
        Circle(Center, Center, *Entry\TriangleRadius, linbackcolor)
      CompilerElse
        Circle(Center, Center, *Entry\TriangleRadius, $FFFFFF)
      CompilerEndIf
      DrawingMode(#PB_2DDrawing_Outlined)
      Circle(Center, Center, *Entry\TriangleRadius, $000000)
      
      ; draw the triangle
      x1 = Center + Cos(Radian(*Entry\h)) * (*Entry\TriangleRadius-2) ; inner radius at hue
      y1 = Center + Sin(Radian(*Entry\h)) * (*Entry\TriangleRadius-2)
      x2 = Center + Cos(Radian(*Entry\h + 120.0)) * (*Entry\TriangleRadius-2) ; inner radius at full v
      y2 = Center + Sin(Radian(*Entry\h + 120.0)) * (*Entry\TriangleRadius-2)
      x3 = Center + Cos(Radian(*Entry\h + 240.0)) * (*Entry\TriangleRadius-2) ; inner radius at full s
      y3 = Center + Sin(Radian(*Entry\h + 240.0)) * (*Entry\TriangleRadius-2)
      
      DrawingMode(#PB_2DDrawing_Default)
      LineXY(x1, y1, x2, y2, $000000)
      LineXY(x1, y1, x3, y3, $000000)
      LineXY(x2, y2, x3, y3, $000000)
      
      ; fill the triangle
      DrawingMode(#PB_2DDrawing_CustomFilter)
      CustomFilterCallback(@ColorPicker_WheelCenterFilter())
      FillArea(Center, Center, $000000)
      
      StopDrawing()
    EndIf
  EndIf
  
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    DrawImage(ImageID(#IMAGE_Color_Content1), 0, 0)
    
    w = OutputWidth()
    h = OutputHeight()
    Center = w / 2
    Radius = w / 2 - 10
    
    x0 = Center + Cos(Radian(*Entry\h)) * (Radius-1)  ; outer radius at hue
    y0 = Center + Sin(Radian(*Entry\h)) * (Radius-1)
    x1 = Center + Cos(Radian(*Entry\h)) * (*Entry\TriangleRadius+1) ; inner radius at hue
    y1 = Center + Sin(Radian(*Entry\h)) * (*Entry\TriangleRadius+1)
    LineXY(x0, y0, x1, y1, $FFFFFF)
    
    ; draw the cross marker
    ; do the action from the WheelCenterFilter() in reverse order
    ;
    DrawingMode(#PB_2DDrawing_Default)
    r_x.f = - ((*Entry\TriangleSide * *Entry\v) / 2) + (*Entry\s * (*Entry\TriangleSide * *Entry\v))
    r_y.f = - (*Entry\TriangleHeight / 3) + ((1.0 - *Entry\v) * *Entry\TriangleHeight)
    Rotate(*Entry\h + 30.0, @r_x, @r_y)
    ColorPicker_DrawCross(Center + r_x, Center + r_y)
    StopDrawing()
  EndIf
  
  ColorPicker_UpdateColor(*Entry, HSVToRGB(*Entry\h, *Entry\s, *Entry\v))
  
  ProcedureReturn CanvasWidth ; actual height used
EndProcedure


Procedure ColorPicker_Wheel_Setup(*Entry.ColorPickerData, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
  
  ; use the smaller one as the size
  If CanvasWidth < CanvasHeight
    Size = CanvasWidth
  Else
    Size = CanvasHeight
    CanvasX + (CanvasWidth-Size) / 2
  EndIf
  
  ; create the image with the static content
  ;
  CreateImage(#IMAGE_Color_Content1, DesktopScaledX(Size), DesktopScaledY(Size), 24)
  If StartDrawing(ImageOutput(#IMAGE_Color_Content1))
    w = OutputWidth()
    h = OutputHeight()
    CompilerIf #CompileLinuxGtk
      *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
      linbackcolor= RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
      Box(0, 0, w, h, linbackcolor)
    CompilerElse
      Box(0, 0, w, h, $FFFFFF)  
    CompilerEndIf
    Center = w / 2
    Radius = w / 2 - 10
    
    If Radius > 150
      *Entry\TriangleRadius = Radius - 30
    Else
      *Entry\TriangleRadius  = Radius * 0.85
    EndIf
    
    ; Precalculate some values
    ; The triangle in the middle is an equilateral triangle, so these are simple to calculate
    ; from the radius of the surrounding circle
    ;
    *Entry\TriangleSide   = (3.0 * *Entry\TriangleRadius) / Sqr(3.0)
    *Entry\TriangleHeight = (3.0 * *Entry\TriangleRadius) / 2.0
    
    DrawingMode(#PB_2DDrawing_CustomFilter)
    CustomFilterCallback(@ColorPicker_WheelFilter())
    Circle(Center, Center, Radius)
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Circle(Center, Center, Radius, $000000)
    
    StopDrawing()
  EndIf
  
  RGBToHSV(*Entry\RGBColor, @*Entry\h, @*Entry\s, @*Entry\v)
  
  HideGadget(#GADGET_Color_Canvas1, 0)
  HideGadget(#GADGET_Color_Canvas2, 1)
  HideGadget(#GADGET_Color_Canvas3, 1)
  HideGadget(#GADGET_Color_Scheme, 1)
  HideGadget(#GADGET_Color_Scroll, 1)
  HideGadget(#GADGET_Color_Filter, 1)
  HideGadget(#GADGET_Color_Label1, 1)
  HideGadget(#GADGET_Color_Label2, 1)
  HideGadget(#GADGET_Color_Label3, 1)
  
  ResizeGadget(#GADGET_Color_Canvas1, CanvasX, CanvasY, Size, Size)
  
  ColorPicker_Wheel_Update(*Entry, #True)
  
  ProcedureReturn Size
EndProcedure

Procedure ColorPicker_Wheel_Event(*Entry.ColorPickerData, Gadget, Type)
  Static State
  
  If Gadget = #GADGET_Color_Canvas1
    ; get info
    w = DesktopScaledX(GadgetWidth(#GADGET_Color_Canvas1))
    h = DesktopScaledY(GadgetHeight(#GADGET_Color_Canvas1))
    x = GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseX)
    y = GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseY)
    
    Center = w / 2
    Radius = (w / 2) - 10
    
    
    ; handle event
    Select Type
        
      Case #PB_EventType_LeftButtonDown
        Distance.f = Sqr((x-Center)*(x-Center) + (y-Center)*(y-Center))
        
        If Distance <= *Entry\TriangleRadius
          State = 2 ; Mouse down in V/S area
        ElseIf Distance <= Radius
          State = 1 ; Mouse down in H area
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        State = 0
        
    EndSelect
    
    ; update values
    Select State
        
      Case 1
        *Entry\h = Mod(Degree(ATan2(x-Center, y-Center)) + 360, 360)
        ColorPicker_Wheel_Update(*Entry, #True)
        
      Case 2
        ; same action as the WheelCenterFilter()
        r_x.f = x - Center
        r_y.f = y - Center
        Rotate(-(*Entry\h + 30.0), @r_x, @r_y)
        
        ; calculate v first, as we need it for s
        *Entry\v = 1.0 - ((r_y + (*Entry\TriangleHeight / 3.0)) / *ColorPicker\TriangleHeight)
        If *Entry\v < 0: *Entry\v = 0: EndIf
        If *Entry\v > 1: *Entry\v = 1: EndIf
        *Entry\s = (r_x + ((*Entry\TriangleSide * *Entry\v) /  2.0)) / (*Entry\TriangleSide * *Entry\v)
        If *Entry\s < 0: *Entry\s = 0: EndIf
        If *Entry\s > 1: *Entry\s = 1: EndIf
        ColorPicker_Wheel_Update(*Entry, #False)
        
    EndSelect
    
  EndIf
EndProcedure

;- ----- Palette picker -----

Procedure ColorPicker_Palette_Update(*Entry.ColorPickerData)
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    w = OutputWidth()
    h = OutputHeight()
    
    ; if a palette has less items than can be displayed, it is important to remove old content
    CompilerIf #CompileLinuxGtk
      *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
      linbackcolor= RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
      Box(0, 0, w, h, linbackcolor)
    CompilerElse
      Box(0, 0, w, h, $FFFFFF)
    CompilerEndIf    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0, 0, w, h, $000000)
    
    DrawingMode(#PB_2DDrawing_Default)
    Color = *Entry\First
    For row = 0 To *Entry\Rows-1
      For col = 0 To *Entry\Cols-1
        If Color >= *Palette\Count
          Break 2
        EndIf
        
        x = col * DesktopScaledX(16)
        y = row * DesktopScaledY(16)
        Box(x, y, DesktopScaledX(17), DesktopScaledY(17), $000000)
        Box(x+1, y+1, DesktopScaledX(15), DesktopScaledY(15), *Palette\Entry(Color)\Color)
        Color + 1
      Next col
    Next row
    
    StopDrawing()
  EndIf
  
  ; No ColorPicker_UpdateColor() here, as the color only changes on a click
EndProcedure


Procedure ColorPicker_Palette_Setup(*Entry.ColorPickerData, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
  ; load the palettes
  ColorPicker_LoadPalettes(*Entry)
  
  ; There is no backing image for this picker, as
  ; everything can be drawn directly on the canvas
  
  ComboHeight = GetRequiredHeight(#GADGET_Color_Scheme)
  
  *Entry\First = 0
  *Entry\Cols  = (CanvasWidth - 20) / 16
  *Entry\Rows  = (CanvasHeight - ComboHeight - 5) / 16
  
  width   = *Entry\Cols * 16 + 1
  height  = *Entry\Rows * 16 + 1
  xoffset = CanvasX + ((CanvasWidth - 20) % 16) / 2
  yoffset = CanvasY + 5 + ComboHeight + ((CanvasHeight - ComboHeight - 5) % 16) / 2
  
  SetGadgetAttribute(#GADGET_Color_Scroll, #PB_ScrollBar_Maximum, Int(Round(*Palette\Count / *Entry\Cols, #PB_Round_Up)))
  SetGadgetAttribute(#GADGET_Color_Scroll, #PB_ScrollBar_PageLength, *Entry\Rows)
  SetGadgetState(#GADGET_Color_Scroll, 0)
  
  If *Entry\Cols * *Entry\Rows >= *Palette\Count
    DisableGadget(#GADGET_Color_Scroll, 1)
  Else
    DisableGadget(#GADGET_Color_Scroll, 0)
  EndIf
  
  HideGadget(#GADGET_Color_Canvas1, 0)
  HideGadget(#GADGET_Color_Canvas2, 1)
  HideGadget(#GADGET_Color_Canvas3, 1)
  HideGadget(#GADGET_Color_Scheme, 0)
  HideGadget(#GADGET_Color_Scroll, 0)
  HideGadget(#GADGET_Color_Filter, 1)
  HideGadget(#GADGET_Color_Label1, 1)
  HideGadget(#GADGET_Color_Label2, 1)
  HideGadget(#GADGET_Color_Label3, 1)
  
  ResizeGadget(#GADGET_Color_Canvas1, xoffset, yoffset, width, height)
  ResizeGadget(#GADGET_Color_Scheme, CanvasX, CanvasY, CanvasWidth, ComboHeight)
  ResizeGadget(#GADGET_Color_Scroll, xoffset+width, yoffset, 20, height)
  
  ColorPicker_Palette_Update(*Entry)
  ColorPicker_UpdateColor(*Entry, *Entry\RGBColor)
  
  ProcedureReturn CanvasHeight ; actual height used
EndProcedure

Procedure ColorPicker_Palette_Event(*Entry.ColorPickerData, Gadget, Type)
  Select Gadget
      
    Case #GADGET_Color_Scheme
      index = GetGadgetState(#GADGET_Color_Scheme)
      If index <> -1
        SelectElement(PaletteList(), index)
        If *Palette <> @PaletteList() ; only if the entry changed
          *Palette = @PaletteList()
          
          ; trigger a resize which sets up the display of this new palette
          ColorPicker_TriggerResize(*Entry)
        EndIf
      EndIf
      
    Case #GADGET_Color_Scroll
      *Entry\First = GetGadgetState(#GADGET_Color_Scroll) * *Entry\Cols
      ColorPicker_Palette_Update(*Entry)
      
    Case #GADGET_Color_Canvas1
      If Type = #PB_EventType_LeftButtonDown
        col = Round(GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseX) / DesktopScaledX(16), #PB_Round_Down)
        row = Round(GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseY) / DesktopScaledY(16), #PB_Round_Down)
        Color = *Entry\First + row * *Entry\Cols + col
        
        If Color >= 0 And Color < *Palette\Count
          ; valid color entry
          *Entry\RGBColor = *Palette\Entry(Color)\Color
          ColorPicker_Palette_Update(*Entry)
          ColorPicker_UpdateColor(*Entry, *Entry\RGBColor)
        EndIf
      EndIf
      
      
  EndSelect
EndProcedure

;- ----- Name picker -----

Procedure ColorPicker_Name_UpdateFilter(*Entry.ColorPickerData)
  ; make a copy of the real palette and sort it by name
  FilteredPalette\Count = *Palette\Count
  CopyArray(*Palette\Entry(), FilteredPalette\Entry())
  SortStructuredArray(FilteredPalette\Entry(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(ColorEntry\Name$), #PB_String)
  
  ; apply the filter
  Filter$ = LCase(Trim(ReplaceString(RemoveString(GetGadgetText(#GADGET_Color_Filter), Chr(9)), ",", " ")))
  If Filter$
    ReadEntry = 0
    WriteEntry = 0
    Words = CountString(Filter$, " ") + 1
    
    For ReadEntry = 0 To FilteredPalette\Count-1
      Name$ = LCase(FilteredPalette\Entry(ReadEntry)\Name$)
      match = 1
      For i = 1 To Words
        Word$ = StringField(Filter$, i, " ")
        If FindString(Name$, Word$, 1) = 0
          match = 0
          Break
        EndIf
      Next i
      
      If match
        If ReadEntry <> WriteEntry
          FilteredPalette\Entry(WriteEntry)\Name$ = FilteredPalette\Entry(ReadEntry)\Name$
          FilteredPalette\Entry(WriteEntry)\Color = FilteredPalette\Entry(ReadEntry)\Color
        EndIf
        WriteEntry + 1
      EndIf
    Next ReadEntry
    
    FilteredPalette\Count = WriteEntry
  EndIf
  
  ; update the scrollbar
  SetGadgetAttribute(#GADGET_Color_Scroll, #PB_ScrollBar_Maximum, FilteredPalette\Count)
  SetGadgetAttribute(#GADGET_Color_Scroll, #PB_ScrollBar_PageLength, *Entry\Rows)
  
  *Entry\First = 0
  SetGadgetState(#GADGET_Color_Scroll, 0)
  
  If *Entry\Rows >= FilteredPalette\Count
    DisableGadget(#GADGET_Color_Scroll, 1)
  Else
    DisableGadget(#GADGET_Color_Scroll, 0)
  EndIf
EndProcedure

Procedure ColorPicker_Name_Update(*Entry.ColorPickerData)
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    
    DrawingFont(GetGadgetFont(#PB_Default))
    
    w = OutputWidth()
    h = OutputHeight()
    CompilerIf #CompileLinuxGtk
      *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
      linbackcolor= RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
      linbackcolordark= RGB(*Style\dark[#GTK_STATE_NORMAL]\red >> 8, *Style\dark[#GTK_STATE_NORMAL]\green >> 8, *Style\dark[#GTK_STATE_NORMAL]\blue >> 8)
      linfgcolor= RGB(*Style\fg[#GTK_STATE_NORMAL]\red >> 8, *Style\fg[#GTK_STATE_NORMAL]\green >> 8, *Style\fg[#GTK_STATE_NORMAL]\blue >> 8)
      Box(0, 0, w, h, linbackcolor)
    CompilerElse
      Box(0, 0, w, h, $FFFFFF)
    CompilerEndIf

    DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
    For row = 0 To *Entry\Rows ; draw also the last half row in the remaining space
      If *Entry\First + row >= FilteredPalette\Count
        Break
      EndIf
      
      y = 1 + row * *Entry\RowHeight
      If row % 2
        CompilerIf #CompileLinux
          Box(1, y, w-2, *Entry\RowHeight, linbackcolordark)
        CompilerElse
          Box(1, y, w-2, *Entry\RowHeight, $E0E0E0)
        CompilerEndIf
      Else
        CompilerIf #CompileLinux
          Box(1, y, w-2, *Entry\RowHeight, linbackcolor)
        CompilerElse
          Box(1, y, w-2, *Entry\RowHeight, $FFFFFF)
        CompilerEndIf
      EndIf
      
      Box(w-3-*Entry\BoxWidth, y+2, *Entry\BoxWidth, *Entry\RowHeight-4, FilteredPalette\Entry(*Entry\First + row)\Color)
        CompilerIf #CompileLinux
          DrawText(5, y+4, FilteredPalette\Entry(*Entry\First + row)\Name$, linfgcolor)
        CompilerElse
          DrawText(5, y+4, FilteredPalette\Entry(*Entry\First + row)\Name$, $000000)
        CompilerEndIf
    Next row
    
    If FilteredPalette\Count = 0
      DrawText(5, 5, Language("ToolsPanel", "NoMatch"), $808080)
    EndIf
    
    ; do this last, to draw over the last maybe half row in the gadget
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0, 0, w, h, $000000)
    
    StopDrawing()
  EndIf
  
  ; No ColorPicker_UpdateColor() here, as the color only changes on a click
EndProcedure


Procedure ColorPicker_Name_Setup(*Entry.ColorPickerData, CanvasX, CanvasY, CanvasWidth, CanvasHeight)
  ; load the palettes
  ColorPicker_LoadPalettes(*Entry)
  
  ; make sure the palette is sorted in alphabetic order
  
  
  ; There is no backing image for this picker, as
  ; everything can be drawn directly on the canvas
  
  SetGadgetText(#GADGET_Color_Label1, Language("ToolsPanel", "Color_Filter")+": ")
  GetRequiredSize(#GADGET_Color_Label1, @LabelWidth, @LabelHeight)
  
  ComboHeight = GetRequiredHeight(#GADGET_Color_Scheme)
  FilterHeight = Max(LabelHeight, GetRequiredHeight(#GADGET_Color_Filter))
  
  max = 0
  If StartDrawing(CanvasOutput(#GADGET_Color_Canvas1))
    DrawingFont(GetGadgetFont(#PB_Default))
    *Entry\RowHeight = TextHeight("Hg") + 8
    For i = 0 To *Palette\Count-1
      max = Max(max, TextWidth(*Palette\Entry(i)\Name$))
    Next i
    StopDrawing()
  EndIf
  
  *Entry\BoxWidth = (CanvasWidth-30) - max
  If *Entry\BoxWidth < ((CanvasWidth-30) / 5)
    *Entry\BoxWidth = (CanvasWidth-30) / 5
  ElseIf *Entry\BoxWidth > (CanvasWidth-30) / 2
    *Entry\BoxWidth = (CanvasWidth-30) / 2
  EndIf
  
  If *Entry\BoxWidth < 60
    *Entry\BoxWidth = 60
  EndIf
  
  Height = CanvasHeight - ComboHeight - 10 - FilterHeight
  *Entry\Rows  = DesktopScaledY(Height-2) / *Entry\RowHeight
  
  SetGadgetText(#GADGET_Color_Filter, "")
  ColorPicker_Name_UpdateFilter(*Entry)
  
  HideGadget(#GADGET_Color_Canvas1, 0)
  HideGadget(#GADGET_Color_Canvas2, 1)
  HideGadget(#GADGET_Color_Canvas3, 1)
  HideGadget(#GADGET_Color_Scheme, 0)
  HideGadget(#GADGET_Color_Scroll, 0)
  HideGadget(#GADGET_Color_Filter, 0)
  HideGadget(#GADGET_Color_Label1, 0)
  HideGadget(#GADGET_Color_Label2, 1)
  HideGadget(#GADGET_Color_Label3, 1)
  
  ResizeGadget(#GADGET_Color_Canvas1, CanvasX, CanvasY+ComboHeight+5, CanvasWidth-20, Height)
  ResizeGadget(#GADGET_Color_Scheme, CanvasX, CanvasY, CanvasWidth, ComboHeight)
  ResizeGadget(#GADGET_Color_Scroll, CanvasX+CanvasWidth-20, CanvasY+ComboHeight+5, 20, Height)
  ResizeGadget(#GADGET_Color_Label1, CanvasX, CanvasY+CanvasHeight-FilterHeight+(FilterHeight-LabelHeight)/2, LabelWidth, LabelHeight)
  ResizeGadget(#GADGET_Color_Filter, CanvasX+LabelWidth, CanvasY+CanvasHeight-FilterHeight, CanvasWidth-LabelWidth, FilterHeight)
  
  ColorPicker_Name_Update(*Entry)
  ColorPicker_UpdateColor(*Entry, *Entry\RGBColor)
  
  ProcedureReturn CanvasHeight ; actual height used
EndProcedure

Procedure ColorPicker_Name_Event(*Entry.ColorPickerData, Gadget, Type)
  Select Gadget
      
    Case #GADGET_Color_Scheme
      index = GetGadgetState(#GADGET_Color_Scheme)
      If index <> -1
        SelectElement(PaletteList(), index)
        If *Palette <> @PaletteList() ; only if the entry changed
          *Palette = @PaletteList()
          
          ; trigger a resize which sets up the display of this new palette
          ColorPicker_TriggerResize(*Entry)
        EndIf
      EndIf
      
    Case #GADGET_Color_Scroll
      *Entry\First = GetGadgetState(#GADGET_Color_Scroll)
      ColorPicker_Name_Update(*Entry)
      
    Case #GADGET_Color_Filter
      If Type = #PB_EventType_Change
        ColorPicker_Name_UpdateFilter(*Entry)
        ColorPicker_Name_Update(*Entry)
      EndIf
      
    Case #GADGET_Color_Canvas1
      If Type = #PB_EventType_MouseWheel
        *Entry\First - GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_WheelDelta)
        If *Entry\First < 0
          *Entry\First = 0
        EndIf
        If *Entry\First > *Palette\Count - GetGadgetAttribute(#GADGET_Color_Scroll, #PB_ScrollBar_PageLength)
          *Entry\First = *Palette\Count - GetGadgetAttribute(#GADGET_Color_Scroll, #PB_ScrollBar_PageLength)
        EndIf  
        SetGadgetState(#GADGET_Color_Scroll, *Entry\First)
        ColorPicker_Name_Update(*Entry)
      EndIf

      If Type = #PB_EventType_LeftButtonDown
        row = (GetGadgetAttribute(#GADGET_Color_Canvas1, #PB_Canvas_MouseY) - 1) / *Entry\RowHeight
        Color = *Entry\First + row
        
        If Color >= 0 And Color < FilteredPalette\Count
          ; valid color entry
          *Entry\RGBColor = FilteredPalette\Entry(Color)\Color
          ColorPicker_Name_Update(*Entry)
          ColorPicker_UpdateColor(*Entry, *Entry\RGBColor) ; not done in Name_Update()
        EndIf
      EndIf
      
  EndSelect
EndProcedure


;- ----- Common functions -----

Procedure ColorPicker_UpdateColorField(*Entry.ColorPickerData, Field, Text$)
  ;
  ; Note: When input from an active input field triggered this update,
  ; do not update its content, or it will move the cursor which is very annoying
  ; This is what the IgnoreInputField variable is good for
  ;
  ; Also do not update the text if it does not change, as that seems to trigger
  ; unneeded update events on Windows (that screw up things like the scrollbar handling)
  ;
  If *Entry\IgnoreInputField <> Field And Text$ <> GetGadgetText(Field)
    SetGadgetText(Field, Text$)
  EndIf
EndProcedure

Procedure ColorPicker_UpdateColor(*Entry.ColorPickerData, Color)
  
  ; redraw the alpha slider with the new color
  ;
  If *Entry\UseAlpha
    If StartDrawing(CanvasOutput(#GADGET_Color_CanvasAlpha))
      w = OutputWidth()
      h = OutputHeight()
      Box(0, 0, w, h, $000000)
      
      DrawingMode(#PB_2DDrawing_CustomFilter)
      CustomFilterCallback(@ColorPicker_TransparentFilter())
      For x = 0 To w-3
        Line(x+1, 1, 1, h-2, ColorPicker_AddAlpha(Color, Int((x * 255.0) / (w-3))))
      Next x
      
      DrawingMode(#PB_2DDrawing_Default)
      ColorPicker_DrawArrow(1+*Entry\a * (w-3), 1, DesktopScaledY(28))
      StopDrawing()
    EndIf
  EndIf
  
  ; Redraw the color area
  ;
  If StartDrawing(CanvasOutput(#GADGET_Color_Current))
    w = OutputWidth()
    h = OutputHeight()
    Box(1, 1, w-2, h-2, Color)
    
    If *Entry\UseAlpha
      DrawingMode(#PB_2DDrawing_CustomFilter)
      CustomFilterCallback(@ColorPicker_TransparentFilter())
      
      If *Entry\VerticalAlpha
        Box(1, 1, w-2, (h-2)/2, ColorPicker_AddAlpha(Color, Int(*Entry\a * 255.0)))
      Else
        Box(1, 1, (w-2)/2, h-2, ColorPicker_AddAlpha(Color, Int(*Entry\a * 255.0)))
      EndIf
    EndIf
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0, 0, w, h, $000000)
    StopDrawing()
  EndIf
  
  ; Update text fields
  ;
  ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input0, Str(Red(Color)))
  ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input1, Str(Green(Color)))
  ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input2, Str(Blue(Color)))
  
  If *Entry\UseAlpha
    ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input3,  Str(Int(*Entry\a * 255.0)))
    ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Hex, "$" + RSet(Hex(ColorPicker_AddAlpha(Color, Int(*Entry\a * 255.0)), #PB_Long), 8, "0"))
  Else
    ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Hex, "$" + RSet(Hex(Color, #PB_Long), 6, "0"))
  EndIf
  
  If *Entry\Mode$ = "HSL" ; can use the values directly
    c_h.f = *Entry\h
    c_s.f = *Entry\s
    c_l.f = *Entry\l
  Else ; need to calculate these
    RGBToHSL(Color, @c_h.f, @c_s.f, @c_l.f)
  EndIf
  
  ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input4, StrF(c_h, 0)) ; degree
  ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input5, StrF(c_s*100.0, 0)) ; percent
  ColorPicker_UpdateColorField(*Entry, #GADGET_Color_Input6, StrF(c_l*100.0, 0)) ; percent
  
  *Entry\RGBColor = Color
EndProcedure


Procedure ColorPicker_UpdateHistory(*Entry.ColorPickerData)
  If StartDrawing(CanvasOutput(#GADGET_Color_History))
    w = OutputWidth()
    h = OutputHeight()
    CompilerIf #CompileLinuxGtk
      *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
      linbackcolor= RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
      Box(0, 0, w, h, linbackcolor)
    CompilerElse
      Box(0, 0, w, h, $FFFFFF)
    CompilerEndIf    
    cols = (w-DesktopScaledX(5)) / DesktopScaledX(23)
    If cols < 1: cols = 1: EndIf
    
    For i = 0 To #ColorPicker_History-1
      x = DesktopScaledX(4) + (i % cols) * DesktopScaledX(23)
      y = DesktopScaledX(4) + (i / cols) * DesktopScaledX(23)
      
      If ColorPicker_History(i)\Alpha < 0
        DrawingMode(#PB_2DDrawing_Default)
        Box(x, y, DesktopScaledX(20), DesktopScaledX(20), ColorPicker_History(i)\Color)
      Else
        DrawingMode(#PB_2DDrawing_CustomFilter)
        CustomFilterCallback(@ColorPicker_TransparentFilter())
        Box(x, y, DesktopScaledX(20), DesktopScaledX(20), ColorPicker_AddAlpha(ColorPicker_History(i)\Color, ColorPicker_History(i)\Alpha))
      EndIf
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(x, y, DesktopScaledX(20), DesktopScaledX(20), $000000)
    Next i
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0, 0, w, h, $000000)
    
    StopDrawing()
  EndIf
EndProcedure


Procedure ColorPicker_SetModeFunctions(*Entry.ColorPickerData, Mode$)
  
  Select *Entry\Mode$
      
    Case "HSV"
      *Entry\SetupFunction = @ColorPicker_HSV_Setup()
      *Entry\EventFunction = @ColorPicker_HSV_Event()
      
    Case "HSL"
      *Entry\SetupFunction = @ColorPicker_HSL_Setup()
      *Entry\EventFunction = @ColorPicker_HSL_Event()
      
    Case "WHEEL"
      *Entry\SetupFunction = @ColorPicker_Wheel_Setup()
      *Entry\EventFunction = @ColorPicker_Wheel_Event()
      
    Case "PALETTE"
      *Entry\SetupFunction = @ColorPicker_Palette_Setup()
      *Entry\EventFunction = @ColorPicker_Palette_Event()
      
    Case "NAME"
      *Entry\SetupFunction = @ColorPicker_Name_Setup()
      *Entry\EventFunction = @ColorPicker_Name_Event()
      
    Default ; RGB is the fallback
      *Entry\SetupFunction = @ColorPicker_RGB_Setup()
      *Entry\EventFunction = @ColorPicker_RGB_Event()
      
  EndSelect
  
EndProcedure

Procedure ColorPicker_TriggerResize(*Entry.ColorPickerData)
  If *Entry\IsSeparateWindow
    If #DEFAULT_CanWindowStayOnTop
      ColorPicker_ResizeHandler(*Entry, WindowWidth(*Entry\ToolWindowID), WindowHeight(*Entry\ToolWindowID)-GetRequiredHeight(*Entry\ToolStayOnTop)-5)
    Else
      ColorPicker_ResizeHandler(*Entry, WindowWidth(*Entry\ToolWindowID), WindowHeight(*Entry\ToolWindowID))
    EndIf
  Else
    ColorPicker_ResizeHandler(*Entry, GetGadgetAttribute(#GADGET_ToolsPanel, #PB_Panel_ItemWidth), GetGadgetAttribute(#GADGET_ToolsPanel, #PB_Panel_ItemHeight))
  EndIf
EndProcedure

; To handle scrolling events in realtime on Windows/macOS. Not needed on Linux
;
Procedure ColorPicker_ScrollbarCallback()
  *ColorPicker\EventFunction(*ColorPicker, #GADGET_Color_Scroll, 0)
EndProcedure

;- ----- ToolsPanel interface -----

Procedure ColorPicker_CreateFunction(*Entry.ColorPickerData)
  *ColorPicker = *Entry
  
  ButtonGadget(#GADGET_Color_RGB,     0, 0, 0, 0, Language("ToolsPanel","Mode_RGB"),     #PB_Button_Toggle)
  ButtonGadget(#GADGET_Color_HSV,     0, 0, 0, 0, Language("ToolsPanel","Mode_HSV"),     #PB_Button_Toggle)
  ButtonGadget(#GADGET_Color_HSL,     0, 0, 0, 0, Language("ToolsPanel","Mode_HSL"),     #PB_Button_Toggle)
  ButtonGadget(#GADGET_Color_Wheel,   0, 0, 0, 0, Language("ToolsPanel","Mode_Wheel"),   #PB_Button_Toggle)
  ButtonGadget(#GADGET_Color_Palette, 0, 0, 0, 0, Language("ToolsPanel","Mode_Palette"), #PB_Button_Toggle)
  ButtonGadget(#GADGET_Color_Name,    0, 0, 0, 0, Language("ToolsPanel","Mode_Name"),    #PB_Button_Toggle)
  
  CanvasGadget(#GADGET_Color_Canvas1, 0, 0, 0, 0, #PB_Canvas_ClipMouse)
  CanvasGadget(#GADGET_Color_Canvas2, 0, 0, 0, 0, #PB_Canvas_ClipMouse)
  CanvasGadget(#GADGET_Color_Canvas3, 0, 0, 0, 0, #PB_Canvas_ClipMouse)
  
  TextGadget(#GADGET_Color_Label1, 0, 0, 0, 0, "")
  TextGadget(#GADGET_Color_Label2, 0, 0, 0, 0, "")
  TextGadget(#GADGET_Color_Label3, 0, 0, 0, 0, "")
  ComboBoxGadget(#GADGET_Color_Scheme, 0, 0, 0, 0)
  ScrollBarGadget(#GADGET_Color_Scroll, 0, 0, 0, 0, 0, 100, 10, #PB_ScrollBar_Vertical)
  StringGadget(#GADGET_Color_Filter, 0, 0, 0, 0, "")
  
  ; Use bind event for scrollbar gadget to be sure it update in realtime
  BindGadgetEvent(#GADGET_Color_Scroll, @ColorPicker_ScrollbarCallback())
  
  CheckBoxGadget(#GADGET_Color_UseAlpha, 0, 0, 0, 0, Language("ToolsPanel", "UseAlpha"))
  CanvasGadget(#GADGET_Color_CanvasAlpha, 0, 0, 0, 0, #PB_Canvas_ClipMouse)
  SetGadgetState(#GADGET_Color_UseAlpha, *Entry\UseAlpha)
  
  CanvasGadget(#GADGET_Color_Current, 0, 0, 0, 0)
  TextGadget(#GADGET_Color_Text0, 0, 0, 0, 0, "R: ")
  TextGadget(#GADGET_Color_Text1, 0, 0, 0, 0, "G: ")
  TextGadget(#GADGET_Color_Text2, 0, 0, 0, 0, "B: ")
  TextGadget(#GADGET_Color_Text3, 0, 0, 0, 0, "A: ")
  TextGadget(#GADGET_Color_Text4, 0, 0, 0, 0, "H: ")
  TextGadget(#GADGET_Color_Text5, 0, 0, 0, 0, "S: ")
  TextGadget(#GADGET_Color_Text6, 0, 0, 0, 0, "L: ")
  
  For Gadget = #GADGET_Color_Input0 To #GADGET_Color_Input6
    StringGadget(Gadget, 0, 0, 0, 0, "", #PB_String_Numeric)
  Next Gadget
  StringGadget(#GADGET_Color_Hex, 0, 0, 0, 0, "") ; for hex input
  
  ButtonGadget(#GADGET_Color_Insert, 0, 0, 0, 0,    Language("ToolsPanel", "Color_Insert"))
  ButtonGadget(#GADGET_Color_InsertRGB, 0, 0, 0, 0, Language("ToolsPanel", "Color_RGB"))
  ButtonGadget(#GADGET_Color_Save, 0, 0, 0, 0,      Language("ToolsPanel", "Color_Save"))
  
  CanvasGadget(#GADGET_Color_History, 0, 0, 0, 0, #PB_Canvas_ClipMouse)
  
  If *Entry\UseAlpha = 0
    HideGadget(#GADGET_Color_CanvasAlpha, 1)
    HideGadget(#GADGET_Color_Text3, 1)
    HideGadget(#GADGET_Color_Input3, 1) ; A field
  EndIf
  
  ColorPicker_SetModeFunctions(*Entry, *Entry\Mode$)
  
  Select *Entry\Mode$
    Case "HSV"    : SetGadgetState(#GADGET_Color_HSV, 1)
    Case "HSL"    : SetGadgetState(#GADGET_Color_HSL, 1)
    Case "WHEEL"  : SetGadgetState(#GADGET_Color_Wheel, 1)
    Case "PALETTE": SetGadgetState(#GADGET_Color_Palette, 1)
    Case "NAME"   : SetGadgetState(#GADGET_Color_Name, 1)
    Default       : SetGadgetState(#GADGET_Color_RGB, 1) ; fallback
  EndSelect
  
EndProcedure


Procedure ColorPicker_DestroyFunction(*Entry.ColorPickerData)
  *ColorPicker = 0
  
  If IsImage(#IMAGE_Color_Content1) ; not all picker modes need these
    FreeImage(#IMAGE_Color_Content1)
  EndIf
  If IsImage(#IMAGE_Color_Content2)
    FreeImage(#IMAGE_Color_Content2)
  EndIf
  
  If *Palette
    *Entry\Palette$ = *Palette\ID$
  EndIf
  
  ; this will trigger a reload when the color picker is created again
  ; to update language etc
  ClearList(PaletteList())
  *Palette = 0
EndProcedure


Procedure ColorPicker_ResizeHandler(*Entry.ColorPickerData, PanelWidth, PanelHeight)
  Protected Dim ButtonWidth(#GADGET_Color_Name - #GADGET_Color_RGB)
  
  y = 5
  
  Total = 0
  For Gadget = #GADGET_Color_RGB To #GADGET_Color_Name
    GetRequiredSize(Gadget, @ButtonWidth(Gadget-#GADGET_Color_RGB), @ButtonHeight)
    Total + ButtonWidth(Gadget-#GADGET_Color_RGB)
  Next Gadget
  Total + 10 + (#GADGET_Color_Name-#GADGET_Color_RGB) * 2
  
  If Total <= PanelWidth ; one row
    Extra = (PanelWidth - Total) / (#GADGET_Color_Name-#GADGET_Color_RGB+1)
    If Extra > 100
      Extra = 100
    EndIf
    
    x = 5
    For Gadget = #GADGET_Color_RGB To #GADGET_Color_Name
      ResizeGadget(Gadget, x, y, ButtonWidth(Gadget-#GADGET_Color_RGB)+Extra, ButtonHeight)
      x + ButtonWidth(Gadget-#GADGET_Color_RGB) + Extra + 2
    Next Gadget
    y + ButtonHeight + 5
    
  Else ; two rows
    Total = 0
    For i = 0 To 2
      ButtonWidth(i) = Max(ButtonWidth(i), ButtonWidth(i+3))
      Total + ButtonWidth(i)
    Next i
    Total + 14
    
    If Total <= PanelWidth
      Extra = (PanelWidth - Total) / 3
    Else
      Extra = 0
    EndIf
    
    x = 5
    For i = 0 To 2
      ResizeGadget(#GADGET_Color_RGB+i, x, y, ButtonWidth(i)+Extra, ButtonHeight)
      ResizeGadget(#GADGET_Color_RGB+i+3, x, y+ButtonHeight+2, ButtonWidth(i)+Extra, ButtonHeight)
      x + ButtonWidth(i)+Extra+2
    Next i
    y + 2 * ButtonHeight + 7
  EndIf
  
  ; Calculate height of everything below the picker area
  ;
  UseAlphaHeight = GetRequiredHeight(#GADGET_Color_UseAlpha)
  GetRequiredSize(#GADGET_Color_Text0, @TextWidth, @TextHeight)
  InputHeight = Max(TextHeight, GetRequiredHeight(#GADGET_Color_Input0))
  ColorWidth = PanelWidth - 30 - 2 * (TextWidth + 40)
  
  ButtonWidth(0) = GetRequiredWidth(#GADGET_Color_Insert)
  ButtonWidth(1) = GetRequiredWidth(#GADGET_Color_InsertRGB)
  ButtonWidth(2) = GetRequiredWidth(#GADGET_Color_Save)
  Total          = ButtonWidth(0)+ButtonWidth(1)+ButtonWidth(2) + 14
  ButtonHeight   = GetRequiredHeight(#GADGET_Color_Insert)
  
  cols = (PanelWidth - 15) / 23   ; history display
  If cols < 1: cols = 1: EndIf
  rows = Int(Round(#ColorPicker_History / cols, #PB_Round_Up))
  
  RestHeight = 0
  RestHeight + UseAlphaHeight + 15
  If *Entry\UseAlpha
    RestHeight + 35 ; alpha slider
  EndIf
  If ColorWidth < 60 ; color will be above values entries
    RestHeight + 65
  EndIf
  RestHeight + (InputHeight+5) * 3 ; R, G, B entries
  If *Entry\UseAlpha
    RestHeight + InputHeight + 5 ; A entry
  EndIf
  RestHeight + InputHeight + 15 ; hex entry and space
  If Total <= PanelWidth        ; buttons in single row
    RestHeight + ButtonHeight + 15
  Else
    RestHeight + 2*ButtonHeight + 17
  EndIf
  RestHeight + rows*23 + 5 ; history
  
  ; resize the canvas (and init it)
  ;
  CanvasWidth = PanelWidth - 10
  CanvasHeight = PanelHeight - y - (RestHeight+10)
  
  ; prevent negative or 0 values here
  If CanvasWidth  < 10: CanvasWidth  = 10: EndIf
  If CanvasHeight < 10: CanvasHeight = 10: EndIf
  CanvasHeight = *Entry\SetupFunction(*Entry, 5, y, CanvasWidth, CanvasHeight)  ; a picker can use less height
  
  y + CanvasHeight + 5
  
  ResizeGadget(#GADGET_Color_UseAlpha, 5, y, PanelWidth-10, UseAlphaHeight)
  y + UseAlphaHeight + 5
  
  If *Entry\UseAlpha
    ; the redraw of this canvas is handled in ColorPicker_UpdateColor()
    ResizeGadget(#GADGET_Color_CanvasAlpha, 5, y, PanelWidth-10, 30)
    y + 35
  EndIf
  
  y + 10
  
  If ColorWidth >= 60 ; enough space for column mode
    *Entry\VerticalAlpha = 1
    If *Entry\UseAlpha
      ResizeGadget(#GADGET_Color_Current, PanelWidth-5-ColorWidth, y, ColorWidth, InputHeight*5 + 20)
    Else
      ResizeGadget(#GADGET_Color_Current, PanelWidth-5-ColorWidth, y, ColorWidth, InputHeight*4 + 15)
    EndIf
  Else ; color above input
    *Entry\VerticalAlpha = 0
    ResizeGadget(#GADGET_Color_Current, 5, y, PanelWidth-10, 60)
    y + 65
  EndIf
  
  For i = 0 To 2
    ResizeGadget(#GADGET_Color_Text0+i,  5, y+(InputHeight-TextHeight)/2, TextWidth, TextHeight)
    ResizeGadget(#GADGET_Color_Input0+i, 5+TextWidth, y, 40, InputHeight)
    ResizeGadget(#GADGET_Color_Text4+i,  55+TextWidth, y+(InputHeight-TextHeight)/2, TextWidth, TextHeight)
    ResizeGadget(#GADGET_Color_Input4+i, 55+TextWidth*2, y, 40, InputHeight)
    y + InputHeight + 5
  Next i
  
  If *Entry\UseAlpha
    ResizeGadget(#GADGET_Color_Text3,  5, y+(InputHeight-TextHeight)/2, TextWidth, TextHeight)
    ResizeGadget(#GADGET_Color_Input3, 5+TextWidth, y, 40, InputHeight)
    y + InputHeight + 5
  EndIf
  
  ResizeGadget(#GADGET_Color_Hex, 5+TextWidth, y, 90+TextWidth, InputHeight)
  y + InputHeight + 15
  
  ; buttons
  If Total <= PanelWidth
    ; single row
    Extra = (PanelWidth-Total) / 3
    If Extra > 150
      Extra = 150
    EndIf
    
    ResizeGadget(#GADGET_Color_Insert, 5, y, ButtonWidth(0)+Extra, ButtonHeight)
    ResizeGadget(#GADGET_Color_InsertRGB, 7+ButtonWidth(0)+Extra, y, ButtonWidth(1)+Extra, ButtonHeight)
    ResizeGadget(#GADGET_Color_Save, 9+ButtonWidth(0)+ButtonWidth(1)+2*Extra, y, ButtonWidth(2)+Extra, ButtonHeight)
    y + ButtonHeight + 15
  Else
    ; double row
    ButtonWidth(0) = Max(ButtonWidth(0), ButtonWidth(2))
    Total = ButtonWidth(0) + ButtonWidth(1) + 20
    If Total <= PanelWidth
      Extra = (PanelWidth-Total) / 2
    Else
      Extra = 0
    EndIf
    
    ResizeGadget(#GADGET_Color_Insert, 5, y, ButtonWidth(0)+Extra, ButtonHeight)
    ResizeGadget(#GADGET_Color_InsertRGB, 7+ButtonWidth(0)+Extra, y, ButtonWidth(1)+Extra, ButtonHeight)
    y + ButtonHeight + 2
    ResizeGadget(#GADGET_Color_Save, 5, y, ButtonWidth(0)+Extra, ButtonHeight)
    y + ButtonHeight + 15
  EndIf
  
  ; history
  width = cols * 23 + 5
  ResizeGadget(#GADGET_Color_History, (PanelWidth-width)/2, y, width, rows*23 + 5)
  
  ; to update the resized color, history and alpha aras
  ColorPicker_UpdateColor(*Entry, *Entry\RGBColor)
  ColorPicker_UpdateHistory(*Entry)
  
  
  CompilerIf #CompileWindows
    ; for some odd reasons, these do not redraw properly in some instances
    For Gadget = #GADGET_Color_Input0 To #GADGET_Color_Input6
      RedrawWindow_(GadgetID(Gadget), #Null, #Null, #RDW_INVALIDATE)
    Next Gadget
    RedrawWindow_(GadgetID(#GADGET_Color_Hex), #Null, #Null, #RDW_INVALIDATE)
  CompilerEndIf
  
EndProcedure


Procedure ColorPicker_EventHandler(*Entry.ColorPickerData, EventGadgetID)
  
  Select EventGadgetID
      
    Case #GADGET_Color_RGB, #GADGET_Color_HSV, #GADGET_Color_HSL, #GADGET_Color_Wheel, #GADGET_Color_Palette, #GADGET_Color_Name
      For Gadget = #GADGET_Color_RGB To #GADGET_Color_Name
        If Gadget = EventGadgetID
          SetGadgetState(Gadget, 1)
        Else
          SetGadgetState(Gadget, 0)
        EndIf
      Next Gadget
      
      Select EventGadgetID
        Case #GADGET_Color_RGB: Mode$ = "RGB"
        Case #GADGET_Color_HSV: Mode$ = "HSV"
        Case #GADGET_Color_HSL: Mode$ = "HSL"
        Case #GADGET_Color_Wheel: Mode$ = "WHEEL"
        Case #GADGET_Color_Palette: Mode$ = "PALETTE"
        Case #GADGET_Color_Name: Mode$ = "NAME"
      EndSelect
      
      If *Entry\Mode$ <> Mode$
        *Entry\Mode$ = Mode$
        ColorPicker_SetModeFunctions(*Entry, Mode$)
        
        ; trigger a resize, which also sets up the new picker type
        ColorPicker_TriggerResize(*Entry)
      EndIf
      
    Case #GADGET_Color_Canvas1, #GADGET_Color_Canvas2, #GADGET_Color_Canvas3, #GADGET_Color_Scheme, #GADGET_Color_Scroll, #GADGET_Color_Filter
      *Entry\EventFunction(*Entry, EventGadgetID, EventType())
      
    Case #GADGET_Color_UseAlpha
      *Entry\UseAlpha = GetGadgetState(#GADGET_Color_UseAlpha)
      If *Entry\UseAlpha
        HideGadget(#GADGET_Color_CanvasAlpha, 0)
        HideGadget(#GADGET_Color_Text3, 0)
        HideGadget(#GADGET_Color_Input3, 0) ; A field
      Else
        HideGadget(#GADGET_Color_CanvasAlpha, 1)
        HideGadget(#GADGET_Color_Text3, 1)
        HideGadget(#GADGET_Color_Input3, 1)
      EndIf
      ColorPicker_TriggerResize(*Entry) ; will resize the shown gadget and redraw everything
      
    Case #GADGET_Color_CanvasAlpha
      If EventType() = #PB_EventType_LeftButtonDown Or (EventType() = #PB_EventType_MouseMove And GetGadgetAttribute(#GADGET_Color_CanvasAlpha, #PB_Canvas_Buttons) & #PB_Canvas_LeftButton)
        *Entry\a = (GetGadgetAttribute(#GADGET_Color_CanvasAlpha, #PB_Canvas_MouseX) - 1) / (DesktopScaledX(GadgetWidth(#GADGET_Color_CanvasAlpha)) - 3)
        If *Entry\a < 0: *Entry\a = 0: EndIf
        If *Entry\a > 1: *Entry\a = 1: EndIf
        ColorPicker_UpdateColor(*Entry, *Entry\RGBColor)
      EndIf
      
    Case #GADGET_Color_Insert
      If *ActiveSource <> *ProjectInfo
        If *Entry\UseAlpha
          InsertCodeString("$"+RSet(Hex(ColorPicker_AddAlpha(*Entry\RGBColor, Int(*Entry\a * 255.0)), #PB_Long), 8, "0"))
        Else
          InsertCodeString("$"+RSet(Hex(*Entry\RGBColor, #PB_Long), 6, "0"))
        EndIf
      EndIf
      
    Case #GADGET_Color_InsertRGB
      If *ActiveSource <> *ProjectInfo
        If *Entry\UseAlpha
          InsertCodeString("RGBA("+Str(Red(*Entry\RGBColor))+", "+Str(Green(*Entry\RGBColor))+", "+Str(Blue(*Entry\RGBColor))+", "+Str(Int(*Entry\a * 255.0))+")")
        Else
          InsertCodeString("RGB("+Str(Red(*Entry\RGBColor))+", "+Str(Green(*Entry\RGBColor))+", "+Str(Blue(*Entry\RGBColor))+")")
        EndIf
      EndIf
      
    Case #GADGET_Color_Save
      ; move all entries one slot and add the current color
      MoveMemory(@ColorPicker_History(0), @ColorPicker_History(1), SizeOf(ColorEntry)*(#ColorPicker_History-1))
      ColorPicker_History(0)\Color = *Entry\RGBColor
      If *Entry\UseAlpha
        ColorPicker_History(0)\Alpha = Int(*Entry\a * 255.0)
      Else
        ColorPicker_History(0)\Alpha = -1
      EndIf
      ColorPicker_UpdateHistory(*Entry)
      
    Case #GADGET_Color_History
      If EventType() = #PB_EventType_LeftButtonDown
        x = DesktopUnscaledX(GetGadgetAttribute(#GADGET_Color_History, #PB_Canvas_MouseX))
        y = DesktopUnscaledY(GetGadgetAttribute(#GADGET_Color_History, #PB_Canvas_MouseY))
        If x >= 4 And y >= 4
          col = (x-4) / 23
          row = (y-4) / 23
          If x <= (col*23)+24 And y <= (col*23)+24 ; check that we are really within a box and not in the in between space
            cols = (GadgetWidth(#GADGET_Color_History)-5) / 23
            If cols < 1: cols = 1: EndIf
            entry = row*cols + col
            
            If entry >= 0 And entry < #ColorPicker_History
              If ColorPicker_History(entry)\Alpha < 0
                If *Entry\UseAlpha
                  *Entry\UseAlpha = 0
                  SetGadgetState(#GADGET_Color_UseAlpha, 0)
                  HideGadget(#GADGET_Color_CanvasAlpha, 1)
                  HideGadget(#GADGET_Color_Text3, 1)
                  HideGadget(#GADGET_Color_Input3, 1)
                EndIf
              Else
                If *Entry\UseAlpha = 0
                  *Entry\UseAlpha = 1
                  SetGadgetState(#GADGET_Color_UseAlpha, 1)
                  HideGadget(#GADGET_Color_CanvasAlpha, 0)
                  HideGadget(#GADGET_Color_Text3, 0)
                  HideGadget(#GADGET_Color_Input3, 0)
                EndIf
                *Entry\a = ColorPicker_History(entry)\Alpha / 255.0
              EndIf
              
              ; re-initialize the picker with the new color
              *Entry\RGBColor = ColorPicker_History(entry)\Color
              ColorPicker_TriggerResize(*Entry)
            EndIf
          EndIf
        EndIf
      EndIf
      
      
    Case #GADGET_Color_Input0 To #GADGET_Color_Input2
      If EventType() = #PB_EventType_Change
        If IsNumeric(GetGadgetText(EventGadgetID), @Component)
          If Component < 0:   Component = 0:   EndIf
          If Component > 255: Component = 255: EndIf
          Select EventGadgetID
            Case #GADGET_Color_Input0: *Entry\RGBColor = RGB(Component, Green(*Entry\RGBColor), Blue(*Entry\RGBColor))
            Case #GADGET_Color_Input1: *Entry\RGBColor = RGB(Red(*Entry\RGBColor), Component, Blue(*Entry\RGBColor))
            Case #GADGET_Color_Input2: *Entry\RGBColor = RGB(Red(*Entry\RGBColor), Green(*Entry\RGBColor), Component)
          EndSelect
          
          *Entry\IgnoreInputField = EventGadgetID
          ColorPicker_TriggerResize(*Entry)
          *Entry\IgnoreInputField = 0
        EndIf
      EndIf
      
    Case #GADGET_Color_Input3
      If EventType() = #PB_EventType_Change
        If IsNumeric(GetGadgetText(#GADGET_Color_Input3), @Component)
          *Entry\a = Component / 255.0
          If *Entry\a < 0: *Entry\a = 0: EndIf
          If *Entry\a > 1: *Entry\a = 1: EndIf
          *Entry\IgnoreInputField = EventGadgetID
          ColorPicker_UpdateColor(*Entry, *Entry\RGBColor) ; refresh only alpha display
          *Entry\IgnoreInputField = 0
        EndIf
      EndIf
      
    Case #GADGET_Color_Input4 To #GADGET_Color_Input6
      If EventType() = #PB_EventType_Change
        If IsNumeric(GetGadgetText(EventGadgetID), @Component)
          If Component < 0: Component = 0: EndIf
          RGBToHSL(*Entry\RGBColor, @h.f, @s.f, @l.f)
          Select EventGadgetID
            Case #GADGET_Color_Input4
              If Component >= 360: Component = 359: EndIf
              *Entry\RGBColor = HSLToRGB(Component, s, l)
            Case #GADGET_Color_Input5
              If Component > 100: Component = 100: EndIf
              *Entry\RGBColor = HSLToRGB(h, (Component / 100.0), l)
            Case #GADGET_Color_Input6
              If Component >= 100
                *Entry\RGBColor = HSLToRGB(h, s, 0.999)
              Else
                *Entry\RGBColor = HSLToRGB(h, s, (Component / 100.0))
              EndIf
          EndSelect
          *Entry\IgnoreInputField = EventGadgetID
          ColorPicker_TriggerResize(*Entry)
          *Entry\IgnoreInputField = 0
        EndIf
      EndIf
      
    Case #GADGET_Color_Hex
      If EventType() = #PB_EventType_Change
        Text$ = RemoveString(RemoveString(GetGadgetText(#GADGET_Color_Hex), " "), Chr(9))
        If Left(Text$, 1) <> "$"
          Text$ = "$" + Text$
        EndIf
        If IsNumeric(Text$, @Color)
          If *Entry\UseAlpha
            *Entry\a = Alpha(Color) / 255.0
          EndIf
          *Entry\RGBColor = Color
          
          *Entry\IgnoreInputField = EventGadgetID
          ColorPicker_TriggerResize(*Entry)
          *Entry\IgnoreInputField = 0
        EndIf
      EndIf
      
      
  EndSelect
  
EndProcedure


Procedure ColorPicker_PreferenceLoad(*Entry.ColorPickerData)
  
  PreferenceGroup("ColorPicker")
  *Entry\Mode$    = ReadPreferenceString("Mode", "RGB")
  *Entry\RGBColor = ReadPreferenceLong("Color", $BFBF3F) & $FFFFFF ; default to a color in the middle of the spectrum (and mask out any alpha)
  *Entry\UseAlpha = ReadPreferenceLong("UseAlpha", 0)
  *Entry\a        = ReadPreferenceLong("Alpha", $FF) / 255.0
  *Entry\Palette$ = ReadPreferenceString("Palette", "2") ; the CSS3 palette is the default (as it has many entries)
  
  
  ; read stored colors
  ;
  HistorySize = ReadPreferenceLong("HistorySize", -1)
  If HistorySize > 0
    ; backward compatibility mode
    If HistorySize > #ColorPicker_History
      HistorySize = #ColorPicker_History
    EndIf
    
    ; init the history to the default values
    For i = 0 To #ColorPicker_History-1
      ColorPicker_History(i)\Color = $FFFFFF
      ColorPicker_History(i)\Alpha = -1
    Next i
    
    ; color 0 used to be the current color (now stored separately)
    For i = 1 To HistorySize
      ColorPicker_History(i-1)\Color = ReadPreferenceLong("RealColor_"+Str(i), $D0D0D0)
    Next i
  Else
    ; new mode
    For i = 0 To #ColorPicker_History-1
      ColorPicker_History(i)\Color = ReadPreferenceLong("Color_"+Str(i), $D0D0D0)
      ColorPicker_History(i)\Alpha = ReadPreferenceLong("Alpha_"+Str(i), -1)
    Next i
    
  EndIf
  
EndProcedure


Procedure ColorPicker_PreferenceSave(*Entry.ColorPickerData)
  
  PreferenceComment("")
  PreferenceGroup("ColorPicker")
  WritePreferenceString("Mode", *Entry\Mode$)
  WritePreferenceLong("Color", *Entry\RGBColor)
  WritePreferenceLong("UseAlpha", *Entry\UseAlpha)
  WritePreferenceLong("Alpha", Int(*Entry\a * 255.0))
  
  If *Palette
    WritePreferenceString("Palette", *Palette\ID$) ; write the ID of the current palette
  Else
    WritePreferenceString("Palette", *Entry\Palette$) ; never loaded, use the ID from the prefs
  EndIf
  
  For i = 0 To #ColorPicker_History-1
    WritePreferenceLong("Color_"+Str(i), ColorPicker_History(i)\Color)
    WritePreferenceLong("Alpha_"+Str(i), ColorPicker_History(i)\Alpha)
  Next i
  
EndProcedure



;- Initialisation code
; This will make this Tool available to the editor
;
ColorPicker_VT.ToolsPanelFunctions

ColorPicker_VT\CreateFunction      = @ColorPicker_CreateFunction()
ColorPicker_VT\DestroyFunction     = @ColorPicker_DestroyFunction()
ColorPicker_VT\ResizeHandler       = @ColorPicker_ResizeHandler()
ColorPicker_VT\EventHandler        = @ColorPicker_EventHandler()
ColorPicker_VT\PreferenceLoad      = @ColorPicker_PreferenceLoad()
ColorPicker_VT\PreferenceSave      = @ColorPicker_PreferenceSave()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @ColorPicker_VT
AvailablePanelTools()\NeedPreferences      = 1
AvailablePanelTools()\NeedConfiguration    = 0
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "ColorPicker"
AvailablePanelTools()\PanelTitle$          = "ColorPicker"
AvailablePanelTools()\ToolName$            = "ColorPicker"
AvailablePanelTools()\ToolMinWindowWidth   = 200
AvailablePanelTools()\ToolMinWindowHeight  = 480

;- Colorspace conversion functions

Procedure.f ColorMin(r.f, g.f, b.f)
  If r < g
    If r < b
      ProcedureReturn r
    Else
      ProcedureReturn b
    EndIf
  Else
    If g < b
      ProcedureReturn g
    Else
      ProcedureReturn b
    EndIf
  EndIf
EndProcedure

Procedure.f ColorMax(r.f, g.f, b.f)
  If r > g
    If r > b
      ProcedureReturn r
    Else
      ProcedureReturn b
    EndIf
  Else
    If g > b
      ProcedureReturn g
    Else
      ProcedureReturn b
    EndIf
  EndIf
EndProcedure

Procedure RGBToHSV(Color, *h.FLOAT, *s.FLOAT, *v.FLOAT)
  Protected.f r, g, b, max, min, delta
  
  r = Red(Color)   / 255.0
  g = Green(Color) / 255.0
  b = Blue(Color)  / 255.0
  
  max = ColorMax(r,g,b)
  min = ColorMin(r,g,b)
  
  *v\f = max
  If max <> 0.0
    delta = max - min
    *s\f = delta/max
    
    If delta <> 0.0
      If r = max
        *h\f = (g-b)/delta
      ElseIf g = max
        *h\f = 2.0 + (b-r)/delta
      ElseIf b = max
        *h\f = 4.0 + (r-g)/delta
      EndIf
      
      *h\f * 60.0
      
      If *h\f<0.0
        *h\f + 360.0
      EndIf
    Else
      *h\f = 0
    EndIf
    
  Else
    *s\f = 0
    *h\f = 0
  EndIf
EndProcedure

Procedure RGBToHSL(Color, *h.FLOAT, *s.FLOAT, *l.FLOAT)
  Protected.f r, g, b, max, min, delta
  
  r = Red(Color)   / 255.0
  g = Green(Color) / 255.0
  b = Blue(Color)  / 255.0
  
  max   = ColorMax(r,g,b)
  min   = ColorMin(r,g,b)
  delta = max - min
  
  If delta <> 0.0
    *l\f = (max + min) / 2.0
    
    If *l\f <= 0.5
      *s\f = delta/(max+min)
    Else
      *s\f = delta/(2-max-min)
    EndIf
    
    If r = max
      *h\f = (g-b)/delta
    ElseIf g = max
      *h\f = 2.0 + (b-r)/delta
    ElseIf b = max
      *h\f = 4.0 + (r-g)/delta
    EndIf
    
    *h\f * 60.0
    
    If *h\f<0.0
      *h\f + 360.0
    EndIf
  Else ; grey
    *s\f = 0
    *h\f = 0
    *l\f = r
  EndIf
  
EndProcedure

; input: 0-360, output: RGB of HSL with hue and full saturation and half luminance
; Much faster than HSLToRGB
;
Procedure HueToRGB(h.f)
  Protected.f r, g, b
  
  ; make sure it is always less than 360, else we get black
  h = Mod(h, 360.0)
  
  If h < 60
    r = 1
    g = h / 60
    b = 0
  ElseIf h < 120
    r = 1 - (h - 60) / 60
    g = 1
    b = 0
  ElseIf h < 180
    r = 0
    g = 1
    b = (h - 120) / 60
  ElseIf h < 240
    r = 0
    g = 1 - (h - 180) / 60
    b = 1
  ElseIf h < 300
    r = (h - 240) / 60
    g = 0
    b = 1
  Else
    r = 1
    g = 0
    b = 1 - (h - 300) / 60
  EndIf
  
  ProcedureReturn RGB(Int(r * 255), Int(g * 255), Int(b * 255))
EndProcedure

Procedure HSVToRGB(h.f, s.f, v.f)
  Protected.f i, f, p, q, t
  Protected.f r, g, b
  
  ; make sure it is always less than 360, else we get black
  h = Mod(h, 360.0)
  
  If s = 0
    r = v
    g = v
    b = v
  Else
    h / 60.0
    i = Round(h, 0)
    f = h-i
    p = v*(1.0-s)
    q = v*(1.0-s*f)
    t = v*(1.0-s*(1.0-f))
    
    Select i
      Case 0 : r = v : g = t : b = p
      Case 1 : r = q : g = v : b = p
      Case 2 : r = p : g = v : b = t
      Case 3 : r = p : g = q : b = v
      Case 4 : r = t : g = p : b = v
      Case 5 : r = v : g = p : b = q
    EndSelect
    
  EndIf
  
  ProcedureReturn RGB(Int(r * 255), Int(g * 255), Int(b * 255))
EndProcedure


Procedure.f HSLToRGBComponent(q1.f, q2.f, h.f)
  If h >= 360.0
    h - 360.0
  ElseIf h < 0.0
    h + 360.0
  EndIf
  
  If h < 60.0
    ProcedureReturn q1+(q2-q1)*h/60.0
  ElseIf h < 180.0
    ProcedureReturn q2
  ElseIf h < 240.0
    ProcedureReturn q1+(q2-q1)*(240.0-h)/60.0
  Else
    ProcedureReturn q1
  EndIf
EndProcedure


Procedure HSLToRGB(h.f, s.f, l.f)
  Protected.f p1, p2
  Protected.f r, g, b
  
  ; make sure it is always less than 360, else we get black
  h = Mod(h, 360.0)
  
  If l <= 0.5
    p2 = l * (1.0 + s)
  Else
    p2 = l + s - l * s
  EndIf
  
  p1 = 2.0 * l - p2
  r = HSLToRGBComponent(p1, p2, h+120)
  g = HSLToRGBComponent(p1, p2, h)
  b = HSLToRGBComponent(p1, p2, h-120)
  
  ProcedureReturn RGB(Int(r*255), Int(g*255), Int(b*255))
EndProcedure
