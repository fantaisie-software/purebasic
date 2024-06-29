; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



#Profiler_Colors = 18 ; number of predefined colors

#ContainerBorder = 4 ; number of pixels to calc inner size of a container with double border

CompilerIf #CompileLinux
  #Profiler_ScrollbarWidth = 18
CompilerElse
  #Profiler_ScrollbarWidth = 15
CompilerEndIf

; OSX only supports up to 9 procedure args, so we put some of the static data
; into a structure and pass by reference
Structure ProfilerDrawing
  x.l           ; the offset/size of the display area inside the drawing area
  y.l
  w.l
  h.l
  linestart.l   ; offset/size inside the profiler data to draw
  lines.l
  countstart.l
  counts.l
EndStructure

Global Profiler_Arrow, Profiler_Select, Profiler_Cross, Profiler_Zoomin, Profiler_Zoomout, Profiler_Zoomall
Global Profiler_CurrentLine ; holds the line under cursor when the popup menu is displayed (0-based)

; calculate all the image positions in the ProfilerDrawing structure
; as this calculation is needed often.
;
Procedure Profiler_CalculateViewport(*Debugger.DebuggerData, *Area.ProfilerDrawing)
  w = DesktopScaledX(GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
  h = DesktopScaledY(GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
  
  *Area\x = 16+*Debugger\ProfilerNumberLength*7
  *Area\y = 11
  *Area\w = w-27-*Debugger\ProfilerNumberLength*7
  *Area\h = h-38
  
  ; prevent too small sizing and division by zero if w/h = 0
  If *Area\w < 20: *Area\w = 20: EndIf
  If *Area\h < 20: *Area\h = 20: EndIf
EndProcedure

Procedure Profiler_ClipToViewport(*x.INTEGER, *y.INTEGER, *Area.ProfilerDrawing)
  If *x\i < *Area\x
    *x\i = *Area\x
  ElseIf *x\i >= *Area\x + *Area\w
    *x\i = *Area\x + *Area\w - 1
  EndIf
  
  If *y\i < *Area\y
    *y\i = *Area\y
  ElseIf *y\i >= *Area\y + *Area\h
    *y\i = *Area\y + *Area\h - 1
  EndIf
EndProcedure


; returns an equal or higher step value that fvalue
; that is a nice round number for the coordinate labeling
Procedure Profiler_StepValue(fvalue.f)
  mult    = 1
  
  While fvalue > 100
    mult * 100
    fvalue / 100
  Wend
  
  If fvalue <= 1:      lvalue = 1   * mult
  ElseIf fvalue <= 2:  lvalue = 2   * mult
  ElseIf fvalue <= 5:  lvalue = 5   * mult
  ElseIf fvalue <= 10: lvalue = 10  * mult
  ElseIf fvalue <= 20: lvalue = 20  * mult
  ElseIf fvalue <= 25: lvalue = 25  * mult
  ElseIf fvalue <= 50: lvalue = 50  * mult
  Else:                lvalue = 100 * mult
  EndIf
  
  ProcedureReturn lvalue
EndProcedure

; Since the size of the default drawing font differs quite a lot
; between the OS, we use are own routine to draw numbers in a fixed
; 7*9 pixel font
;
Procedure Profiler_DrawNumber(x, y, Number, Color, isBold = 0, length = -1)
  If length = -1
    length = Len(Str(Number))
  EndIf
  
  For length = length-1 To 0 Step -1
    *Pointer.BYTE = ?Profiler_Numbers + (Number % 10)*9
    
    ;DisableDebugger ; no debugger warning for plot outside of area
    For dy = 0 To 8
      For dx = 0 To 6
        If *Pointer\b & (1 << (6-dx))
          px = x + length*7 + dx
          py = y+dy
          
          ; In 4.40+, this must be clipped as images are direct memory routines now
          ; Clip 1px more in the x direction for the bold pixel
          ;
          If px >= 0 And py >= 0 And px < OutputWidth()-1 And py < OutputHeight()
            Plot(px, py, color)
            
            If isBold
              Plot(px+1, py, color) ; simply place a dot one pixel to the right
            EndIf
          EndIf
        EndIf
      Next dx
      
      *Pointer + 1
    Next dy
    ;EnableDebugger
    
    Number / 10
    
    If Number = 0
      Break
    EndIf
  Next length
EndProcedure


Procedure Profiler_DrawFile(*Debugger.DebuggerData, *Area.ProfilerDrawing, index, color)
  
  *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
  maxlines = *files\file[index]\Size
  
  *lines.Local_Array = *Debugger\ProfilerData + *files\file[index]\Offset * SizeOf(LONG)
  line               = *Area\lineStart
  
  If *Area\h >= *Area\lines ; lines must be drawn thicker than one pixel
    
    height = Round(*Debugger\ProfilerRatioY, 1)
    While line < *Area\lineStart + *Area\lines - 1 And line < maxlines
      length = (*lines\l[line] - *Area\countStart) * *Debugger\ProfilerRatioX
      
      If length > 0 ; if length < 0, the count is outside the viewport
        If length > *Area\w: length = *Area\w: EndIf
        
        Box(*Area\x, *Area\y + (line-*Area\lineStart)* *Debugger\ProfilerRatioY, length, height, color)
        If *Debugger\ProfilerRatioY >= 3
          ; separate 2 line entries if there is enough space for this (looks better)
          Line(*Area\x, *Area\y + (line-*Area\lineStart)* *Debugger\ProfilerRatioY, *Area\w, 1, $FFFFFF)
        EndIf
      EndIf
      
      line + 1
    Wend
    
    ; draw the last line (may need clipping)
    If line < *Area\lineStart + *Area\lines And line < maxlines
      length = (*lines\l[line] - *Area\countStart) * *Debugger\ProfilerRatioX
      
      If length > 0 ; if length < 0, the count is outside the viewport
        If length > *Area\w: length = *Area\w: EndIf
        
        If (line-*Area\lineStart)* *Debugger\ProfilerRatioY + height > *Area\h
          height = *Area\h - (line-*Area\lineStart)* *Debugger\ProfilerRatioY
        EndIf
        
        Box(*Area\x, *Area\y + (line-*Area\lineStart)* *Debugger\ProfilerRatioY, length, height, color)
        If *Debugger\ProfilerRatioY >= 3
          ; separate 2 line entries if there is enough space for this (looks better)
          Line(*Area\x, *Area\y + (line-*Area\lineStart)* *Debugger\ProfilerRatioY, *Area\w, 1, $FFFFFF)
        EndIf
      EndIf
    EndIf
    
  Else ; multiple lines are combined on one pixel
    thick.d  = 0
    lineDraw = 0
    max      = 0
    
    While line < *Area\lineStart + *Area\lines And line < maxlines
      thick + *Debugger\ProfilerRatioY
      max = Max(max, *lines\l[line])
      
      If thick >= 1
        length = (max - *Area\countStart) * *Debugger\ProfilerRatioX
        
        If length > 0 ; if length < 0, the count is outside the viewport
          If length > *Area\w: length = *Area\w: EndIf
          Line(*Area\x, *Area\y + lineDraw, length, 1, color)
        EndIf
        
        max   = 0
        thick    - 1
        lineDraw + 1
      EndIf
      
      line + 1
    Wend
    
    If thick > 0
      ; draw last line
      length = (max - *Area\countStart) * *Debugger\ProfilerRatioX
      
      If length > 0 ; if length < 0, the count is outside the viewport
        If length > *Area\w: length = *Area\w: EndIf
        Line(*Area\x, *Area\y + lineDraw, length, 1, color)
      EndIf
    EndIf
    
  EndIf
  
  ; DEBUGGING
  ;   h = TextHeight("Gg")
  ;   DrawText(*Area\x, *Area\y,     "Range: "+Str(*Area\x)+", "+Str(*Area\y)+", "+Str(*Area\w)+", "+Str(*Area\h), 0, $FFFFFF)
  ;   DrawText(*Area\x, *Area\y+h,   "Lines: "+Str(*Area\lineStart)+", "+Str(*Area\lines), 0, $FFFFFF)
  ;   DrawText(*Area\x, *Area\y+h*2, "Counts: "+Str(*Area\countStart)+", "+Str(*Area\counts), 0, $FFFFFF)
  ;   DrawText(*Area\x, *Area\y+h*3, "RatioX: "+StrF(*Debugger\ProfilerRatioX), 0, $FFFFFF)
  ;   DrawText(*Area\x, *Area\y+h*4, "RatioY: "+StrF(*Debugger\ProfilerRatioY), 0, $FFFFFF)
  
EndProcedure


Procedure Profiler_DrawAll(*Debugger.DebuggerData)
  
  w = DesktopScaledX(GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
  h = DesktopScaledY(GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
  
  If StartDrawing(CanvasOutput(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
    Box(0, 0, w, h, $FFFFFF)
    
    If *Debugger\ProfilerFiles And *Debugger\ProfilerData
      *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
      
      Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(Area\x-1, Area\y-1, Area\w+2, Area\h+2, $000000)
      
      Area\lineStart  = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY])
      Area\countStart = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX])
      Area\lines      = Area\h / *Debugger\ProfilerRatioY
      Area\counts     = Area\w / *Debugger\ProfilerRatioX
      
      DrawingMode(#PB_2DDrawing_Default)
      
      ; draw the data
      ;
      If *Debugger\NbIncludedFiles = 0
        Profiler_DrawFile(*Debugger, @Area, 0, $FF0000)
        
      Else
        Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files]
        
        ; go backwards, so the top file entry draws on top as well
        For i = *Debugger\NbIncludedFiles To 0 Step -1
          If GetGadgetItemState(Gadget, i) & (#PB_ListIcon_Checked|#PB_ListIcon_Selected)
            index = GetGadgetItemData(Gadget, i) ; get the real index
            Profiler_DrawFile(*Debugger, @Area, index, *files\file[index]\Color)
          EndIf
        Next i
        
      EndIf
      
      ; draw line numbers
      ;
      maxline   = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_Maximum)
      stepvalue = Profiler_StepValue(20 / *Debugger\ProfilerRatioY) ; min 20 pixels between two entries
      first     = Int(Round((Area\lineStart+1) / stepvalue, 1) * stepvalue)
      offset    = Area\y + Int((first-Area\lineStart-1)  * *Debugger\ProfilerRatioY + *Debugger\ProfilerRatioY/2)
      i         = 0
      x         = Area\x-4
      y         = 0
      
      While y <= Area\y+Area\h And (first + i*stepvalue -1) <= maxline
        y = offset + i * stepvalue * *Debugger\ProfilerRatioY
        If y >= Area\y And y <= Area\y+Area\h
          Line(x, y, 3, 1, $000000)
          Profiler_DrawNumber(10, y - 4, (first + i*stepvalue), $000000, 0, *Debugger\ProfilerNumberLength)
        EndIf
        i + 1
      Wend
      
      ; draw count numbers
      ;
      maxcount  = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_Maximum)
      stepvalue = Profiler_StepValue((Len(Str(maxcount))*7+10) / *Debugger\ProfilerRatioX) ; min difference between 2 labels
      
      If Area\countStart = 0
        first = 0
      Else
        first = Int(Round(Area\countStart / stepvalue, 1) * stepvalue)
      EndIf
      
      offset = Area\x + Int((first-Area\countStart)  * *Debugger\ProfilerRatioX)
      i      = 0
      x      = 0
      y      = Area\y+Area\h+1
      
      While x <= Area\x+Area\w And (first + i*stepvalue) <= maxcount
        x = offset + i * stepvalue * *Debugger\ProfilerRatioX
        If x >= Area\x And x <= Area\x+Area\w
          count = first + i*stepvalue
          Line(x, y, 1, 3, $000000)
          Profiler_DrawNumber(x - (Len(Str(count))*7 - 1)/2, y + 7, count, $000000)
        EndIf
        i + 1
      Wend
      
    Else
      DrawText(10, 10, Language("Debugger","ProfilerNoData"), $000000, $FFFFFF)
    EndIf
    
    StopDrawing()
  EndIf

EndProcedure


; Procedure Profiler_DrawPreview(*Debugger.DebuggerData)
;
;   fullw = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Preview])
;   fullh = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Preview])
;
;   ; We re-create the image if the size changed (quicker than a resize, which does the same but additional blitting)
;   ;
;   If *Debugger\ProfilerPreview
;     If fullw <> ImageWidth(*Debugger\ProfilerPreview) Or fullh <> ImageHeight(*Debugger\ProfilerPreview)
;       FreeImage(*Debugger\ProfilerPreview)
;       *Debugger\ProfilerPreview = 0
;     EndIf
;   EndIf
;
;   If *Debugger\ProfilerPreview = 0 And fullw > 0 And fullh > 0
;     *Debugger\ProfilerPreview = CreateImage(#PB_Any, fullw, fullh)
;   EndIf
;
;   If *Debugger\ProfilerPreview
;     If StartDrawing(ImageOutput(*Debugger\ProfilerPreview))
;       Box(0, 0, fullw, fullh, $FFFFFF)
;
;       w = fullw - 4
;       h = fullh - 4
;
;       If *Debugger\ProfilerFiles And *Debugger\ProfilerData And w > 0 And h > 0
;         *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
;         *lines.Local_Array = *Debugger\ProfilerData
;
;         maxlines = *files\file[*Debugger\NbIncludedFiles]\Offset + *files\file[*Debugger\NbIncludedFiles]\Size
;         maxcount = 1
;         For i = 0 To maxlines-1
;           maxcount = Max(maxcount, *lines\l[i])
;         Next i
;
;         RatioX.d = (w / maxcount) * 0.997
;         RatioY.d = (h / maxlines) * 0.997
;
;         If RatioY >= 1 ; lines must be drawn thicker than one pixel
;
;           height = Round(RatioY, 1)
;           For file = 0 To *Debugger\NbIncludedFiles
;             color = *files\file[file]\Color
;
;             For line = 0 To *files\file[file]\Size
;               real   = *files\file[file]\Offset + line
;               length = *lines\l[real] * RatioX
;
;               If length > 0
;                 Box(2, 2 + real * RatioY, length, height, color)
;                 If RatioY >= 3
;                   ; separate 2 line entries if there is enough space for this (looks better)
;                   Line(2, 2 + real * RatioY, w, 1, $FFFFFF)
;                 EndIf
;               EndIf
;
;             Next line
;
;           Next file
;
;
;         Else ; multiple lines are combined on one pixel
;           thick.d  = 0
;           lineDraw = 0
;           max      = 0
;
;           file      = 0
;           remaining = *files\file[0]\Size
;           color     = *files\file[0]\Color
;
;           While line < maxlines
;             thick + RatioY
;             max = Max(max, *lines\l[line])
;
;             If thick >= 1
;               length = max * RatioX
;
;               If length > 0
;                 Line(2, 2 + lineDraw, length, 1, color)
;               EndIf
;
;               max   = 0
;               thick    - 1
;               lineDraw + 1
;             EndIf
;
;             line + 1
;             remaining - 1
;
;             If remaining = 0 And line < maxlines
;               file + 1
;               remaining = *files\file[file]\Size
;               color     = *files\file[file]\Color
;             EndIf
;           Wend
;
;           If thick > 0
;             ; draw last line
;             length = max * RatioX
;
;             If length > 0
;               Line(2, 2 + lineDraw, length, 1, color)
;             EndIf
;           EndIf
;
;         EndIf
;
;       EndIf
;
;       ; draw the border now to avoid the need for any clipping above
;       DrawingMode(#PB_2DDrawing_Outlined)
;       Box(0, 0, fullw, fullh, $000000)
;       Box(1, 1, fullw-2, fullh-2, $FFFFFF)
;
;       StopDrawing()
;     EndIf
;
;     SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Preview], ImageID(*Debugger\ProfilerPreview))
;   Else
;     SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Preview], 0)
;   EndIf
;
; EndProcedure

; Adjust the PageLength of the scrollbars to the current
; ratio and size
;
Procedure Profiler_UpdatePageLength(*Debugger.DebuggerData)
  
  Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
  
  MaxCount = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_Maximum)
  MaxLine  = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_Maximum)
  
  SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_PageLength, Area\w / *Debugger\ProfilerRatioX)
  SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_PageLength, Area\h / *Debugger\ProfilerRatioY)
  
  CountPage = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_PageLength)
  LinePage  = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_PageLength)
  
  If CountPage > MaxCount
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_PageLength, MaxCount)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 1)
  ElseIf CountPage = MaxCount
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 1)
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 0)
  EndIf
  
  If LinePage > MaxLine
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_PageLength, MaxLine)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], 1)
  ElseIf LinePage = MaxLine
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], 1)
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], 0)
  EndIf
  
EndProcedure



; xor function, so 2x the same args erases it
;
Procedure Profiler_DrawSelect(*Debugger.DebuggerData, x1, y1, x2, y2)
  
  Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
  Profiler_ClipToViewport(@x1, @y1, @Area)
  Profiler_ClipToViewport(@x2, @y2, @Area)
  
  If x1 > x2
    Swap x1, x2
  EndIf
  
  If y1 > y2
    Swap y1, y2
  EndIf
  
  If StartDrawing(CanvasOutput(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
    DrawingMode(#PB_2DDrawing_XOr | #PB_2DDrawing_Outlined)
    Box(x1, y1, x2-x1+1, y2-y1+1, $FFFFFF)
    
    If y1 <> y2
      For x = x1 To x2 Step 5
        Plot(x, y1, $FFFFFF)
        Plot(x, y2, $FFFFFF)
      Next x
    EndIf
    
    If x1 <> x2
      For y = y1 To y2 Step 5
        Plot(x1, y, $FFFFFF)
        Plot(x2, y, $FFFFFF)
      Next y
    EndIf
    
    StopDrawing()
  EndIf
  
EndProcedure

; xor drawing
;
Procedure Profiler_DrawCross(*Debugger.DebuggerData, x, y)
  
  Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
  
  ; we only draw when we are inside the viewport
  ;
  If x >= Area\x And x < Area\x+Area\w And y >= Area\y And y < Area\y+Area\h
    
    If StartDrawing(CanvasOutput(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]))
      DrawingMode(#PB_2DDrawing_XOr | #PB_2DDrawing_Transparent)
      
      ; draw the lines
      ;
      If y > Area\y + 6
        Line(x, Area\y, 1, y - Area\y - 6, $FFFFFF)
        For i = Area\y To y - 6 Step 5
          Plot(x, i, $FFFFFF)
        Next i
      EndIf
      If y < Area\y+Area\h - 6
        Line(x, y+6, 1, Area\h - (y - Area\y) - 6, $FFFFFF)
        For i = y+6 To Area\y+Area\h Step 5
          Plot(x, i, $FFFFFF)
        Next i
      EndIf
      
      If x > Area\x + 6
        Line(Area\x, y, x - Area\x - 6, 1, $FFFFFF)
        For i = Area\x To x - 6 Step 5
          Plot(i, y, $FFFFFF)
        Next i
      EndIf
      If x < Area\x+Area\w - 6
        Line(x+6, y, Area\w - (x - Area\x) - 6, 1, $FFFFFF)
        For i = x+6 To Area\x+Area\w Step 5
          Plot(i, y, $FFFFFF)
        Next i
      EndIf
      
      ; draw the numbers
      ; (add 1 even for the count, as we display what is under, not next to the cursor!)
      ;
      count = 1+GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX]) + Int(Round((x - Area\x) / *Debugger\ProfilerRatioX, 0))
      line  = 1+GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY]) + Int(Round((y - Area\y) / *Debugger\ProfilerRatioY, 0))
      
      Profiler_DrawNumber(Area\x+Area\w-2-Len(Str(line))*7, y-12, line, $FFFFFF)
      Profiler_DrawNumber(x-2-Len(Str(count))*7, Area\y+3, count, $FFFFFF)
      
      StopDrawing()
    EndIf
    
  EndIf
  
EndProcedure

CompilerIf #CompileWindows
  
  ; To handle scrolling events in realtime one Windows. Not needed on Linux
  ;
  Procedure Profiler_ScrollbarCallback(Window, Message, wParam, lParam)
    Result = 0
    
    *Debugger.DebuggerData = GetWindowLongPtr_(Window, #GWL_USERDATA)
    If *Debugger
      ;
      ; call the original callback first, so the gadget state is properly updated.
      ;
      Result = CallWindowProc_(*Debugger\ProfilerScrollCallback, Window, Message, wParam, lParam)
      
      ; now check our event
      ;
      If Message = #WM_HSCROLL Or Message = #WM_VSCROLL
        Profiler_DrawAll(*Debugger)
      EndIf
    Else
      Result = DefWindowProc_(Window, Message, wParam, lParam)
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
CompilerEndIf


Global Profiler_CaptureMode, Profiler_DownX, Profiler_DownY, Profiler_OldX, Profiler_OldY

Procedure Profiler_LButtonDown(*Debugger.DebuggerData, x, y)
  ; if we were in mode 3, we simply switch to the new mode now, else start capturing
  If Profiler_CaptureMode = 3
    Profiler_DrawCross(*Debugger, Profiler_OldX, Profiler_OldY)
  EndIf
  
  Profiler_DownX = x
  Profiler_DownY = y
  Profiler_OldX  = Profiler_DownX
  Profiler_OldY  = Profiler_DownY
  
  If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select]) = 0
    Profiler_CaptureMode = 1
  Else
    Profiler_CaptureMode = 2
    Profiler_DrawSelect(*Debugger, Profiler_DownX, Profiler_DownY, Profiler_OldX, Profiler_OldY)
  EndIf
EndProcedure

Procedure Profiler_LButtonUp(*Debugger.DebuggerData)
  If Profiler_CaptureMode = 1 Or Profiler_CaptureMode = 2
    
    If Profiler_CaptureMode = 2
      Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
      Profiler_ClipToViewport(@Profiler_DownX, @Profiler_DownY, @Area)
      Profiler_ClipToViewport(@Profiler_OldX,  @Profiler_OldY,  @Area)
      
      If Profiler_DownX > Profiler_OldX
        Swap Profiler_DownX, Profiler_OldX
      EndIf
      
      If Profiler_DownY > Profiler_OldY
        Swap Profiler_DownY, Profiler_OldY
      EndIf
      
      ; needed for later moving
      ;
      countStart = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX]) + (Profiler_DownX - Area\x) / *Debugger\ProfilerRatioX
      lineStart  = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY]) + (Profiler_DownY - Area\y) / *Debugger\ProfilerRatioY
      
      ; zoom (must be before the move for the pagelength to be correct)
      ;
      If Profiler_OldX > Profiler_DownX+1 And Profiler_OldY > Profiler_DownY+1
        *Debugger\ProfilerRatioX / ((Profiler_OldX-Profiler_DownX) / Area\w)
        *Debugger\ProfilerRatioY / ((Profiler_OldY-Profiler_DownY) / Area\h)
        If *Debugger\ProfilerRatioX > 30.0: *Debugger\ProfilerRatioX = 30.0: EndIf
        If *Debugger\ProfilerRatioY > 30.0: *Debugger\ProfilerRatioY = 30.0: EndIf
      EndIf
      
      Profiler_UpdatePageLength(*Debugger)
      
      ; move the origin
      ;
      maxStart = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_Maximum) - GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_PageLength)
      If maxStart > 0
        If countStart < 0
          countStart = 0
        ElseIf countStart > maxStart
          countStart = maxStart
        EndIf
        
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], countStart)
      EndIf
      
      maxStart = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_Maximum) - GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_PageLength)
      If maxStart > 0
        If lineStart < 0
          lineStart = 0
        ElseIf lineStart > maxStart
          lineStart = maxStart
        EndIf
        
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], lineStart)
      EndIf
      
      Profiler_DrawAll(*Debugger)
    EndIf
    
    Profiler_CaptureMode = 0
  EndIf
EndProcedure

Procedure Profiler_MouseMove(*Debugger.DebuggerData, x, y)
  
  If Profiler_CaptureMode = 0 And GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Cross])
    ; start cross display
    Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
    If x >= Area\x And x <= Area\x + Area\w And y >= Area\y And y <= Area\y+Area\h
      Profiler_CaptureMode = 3
      Profiler_DrawCross(*Debugger, x, y)
    EndIf
    
  ElseIf Profiler_CaptureMode = 3 ; continue cross display
    Profiler_DrawCross(*Debugger, Profiler_OldX, Profiler_OldY) ; erase old one
    Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
    
    If x >= Area\x And x <= Area\x + Area\w And y >= Area\y And y <= Area\y+Area\h
      Profiler_DrawCross(*Debugger, x, y)
    Else
      ; stop the capture
      Profiler_CaptureMode = 0
    EndIf
    
  ElseIf Profiler_CaptureMode = 1 ; drag
    countStart = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX]) - (x - Profiler_OldX) / *Debugger\ProfilerRatioX
    maxStart   = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_Maximum) - GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_PageLength)
    
    If maxStart > 0
      If countStart < 0
        countStart = 0
      ElseIf countStart > maxStart
        countStart = maxStart
      EndIf
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], countStart)
    EndIf
    
    lineStart  = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY]) - (y - Profiler_OldY) / *Debugger\ProfilerRatioY
    maxStart   = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_Maximum) - GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_PageLength)
    
    If maxStart > 0
      If lineStart < 0
        lineStart = 0
      ElseIf lineStart > maxStart
        lineStart = maxStart
      EndIf
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], lineStart)
    EndIf
    
    Profiler_DrawAll(*Debugger)
    
  ElseIf Profiler_CaptureMode = 2 ; select
    If Profiler_OldX <> x Or Profiler_OldY <> y
      Profiler_DrawSelect(*Debugger, Profiler_DownX, Profiler_DownY, Profiler_OldX, Profiler_OldY) ; erase with xor
      Profiler_DrawSelect(*Debugger, Profiler_DownX, Profiler_DownY, x, y)
    EndIf
    
  EndIf
  
  Profiler_OldX = x
  Profiler_OldY = y
EndProcedure

Procedure Profiler_RButtonDown(*Debugger.DebuggerData, x, y)
  If Profiler_CaptureMode > 0
    
    If Profiler_CaptureMode = 2
      Profiler_DrawSelect(*Debugger, Profiler_DownX, Profiler_DownY, Profiler_OldX, Profiler_OldY) ; erase with xor
    ElseIf Profiler_CaptureMode = 3
      Profiler_DrawCross(*Debugger, Profiler_OldX, Profiler_OldY) ; erase old one
    EndIf
    
    Profiler_CaptureMode = 0
  EndIf
  
  Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
  
  If X >= Area\x And X < Area\X+Area\w And Y >= Area\y And Y < Area\y+Area\h
    Profiler_CurrentLine = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY]) + Int(Round((y - Area\y) / *Debugger\ProfilerRatioY, 0)) ; 0-based
    
    If CreatePopupMenu(#POPUPMENU_Profiler)
      MenuItem(#DEBUGGER_MENU_Zoomin,   Language("Debugger","Zoomin"))
      MenuItem(#DEBUGGER_MENU_Zoomout,  Language("Debugger","Zoomout"))
      MenuBar()
      
      If *Debugger\NbIncludedFiles = 0
        MenuItem(#DEBUGGER_MENU_File0, Language("Debugger","ViewLine"))
      Else
        OpenSubMenu(Language("Debugger","ViewLine")+" ...")
        
        ; add all files we are viewing
        For file = 0 To *Debugger\NbIncludedFiles
          If GetGadgetItemState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], file) & (#PB_ListIcon_Checked|#PB_ListIcon_Selected)
            index = GetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], file) ; get the real index
            MenuItem(#DEBUGGER_MENU_File0+index, GetDebuggerRelativeFile(*Debugger, index << #DEBUGGER_DebuggerLineFileOffset))
          EndIf
        Next file
        
        CloseSubMenu()
      EndIf
      
      DisplayPopupMenu(#POPUPMENU_Profiler, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler]))
    EndIf
  EndIf
EndProcedure

; Update bounds for the displayed files and adjust scrollbars as needed
;
Procedure Profiler_UpdateBounds(*Debugger.DebuggerData)
  
  If *Debugger\ProfilerFiles And *Debugger\ProfilerData
    *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
    
    If *Debugger\NbIncludedFiles = 0 ; single file mode
      
      MaxLine  = *files\file[0]\Size
      MaxCount = 1
      
      *lines.Local_Array = *Debugger\ProfilerData
      For i = 0 To MaxLine-1
        MaxCount = Max(*lines\l[i], MaxCount)
      Next i
      
    Else ; multifile mode
      
      MaxLine  = 1
      MaxCount = 1
      Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files]
      
      For file = 0 To *Debugger\NbIncludedFiles
        If GetGadgetItemState(Gadget, file) & (#PB_ListIcon_Checked|#PB_ListIcon_Selected)
          index = GetGadgetItemData(Gadget, file) ; get the real index
          linecount = *files\file[index ]\Size
          *lines.Local_Array = *Debugger\ProfilerData + *files\file[index ]\Offset * SizeOf(LONG)
          
          For line = 0 To linecount-1
            MaxCount = Max(MaxCount, *lines\l[line])
          Next line
          MaxLine = Max(MaxLine, linecount)
        EndIf
      Next file
      
    EndIf
    
    Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
    
    *Debugger\ProfilerRatioX = (Area\w / MaxCount) * 0.995
    *Debugger\ProfilerRatioY = (Area\h / MaxLine) * 0.995
    
    ;     If MaxLine < 500
    ;       *Debugger\ProfilerRatioY = (Area\h / MaxLine) * 0.995
    ;     ElseIf MaxLine < 1000
    ;       *Debugger\ProfilerRatioY = (Area\h / MaxLine) * 2
    ;     ElseIf MaxLine < 3000
    ;       *Debugger\ProfilerRatioY = (Area\h / MaxLine) * 4
    ;     Else
    ;       *Debugger\ProfilerRatioY = (Area\h / MaxLine) * 10
    ;     EndIf
    
    If *Debugger\ProfilerRatioX > 30.0: *Debugger\ProfilerRatioX = 30.0: EndIf
    If *Debugger\ProfilerRatioY > 30.0: *Debugger\ProfilerRatioY = 30.0: EndIf
    
    SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 0)
    SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], 0)
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_Maximum, MaxCount)
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_Maximum, MaxLine)
    Profiler_UpdatePageLength(*Debugger)
    
  EndIf
  
EndProcedure

Procedure Profiler_UpdateStats(*Debugger.DebuggerData)
  
  If *Debugger\NbIncludedFiles > 0 And *Debugger\ProfilerFiles And *Debugger\ProfilerData
    *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
    Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files]
    
    totalcount = 0 ; grrr, quad bugs. lets stay with long
    For file = 0 To *Debugger\NbIncludedFiles
      index = GetGadgetItemData(Gadget, file) ; get the real index
      
      linecount = *files\file[index ]\Size
      count   = 0
      *lines.Local_Array = *Debugger\ProfilerData + *files\file[index]\Offset * SizeOf(LONG)
      
      For line = 0 To linecount-1
        count + *lines\l[line]
      Next line
      
      totalcount + count
      
      SetGadgetItemText(Gadget, file, Str(count), 1)
      SetGadgetItemText(Gadget, file, StrD(count / linecount, 1), 2)
    Next file
  EndIf
  
EndProcedure

Procedure UpdateProfilerWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update], 1)
    
  Else
    
    If *Debugger\ProfilerRunning
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], 0)
    Else
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], 0)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], 1)
    EndIf
    
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset], 0)
    
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -2
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update], 1)
      
      ; send the update command
      ;
      Command.CommandInfo\Command = #COMMAND_GetProfilerData ; do an update as well...
      SendDebuggerCommand(*Debugger, @Command)
    Else
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update], 0)
    EndIf
    
  EndIf
  
EndProcedure

Procedure ProfilerWindowEvents(*Debugger.DebuggerData, EventID)
  Static DragItem
  
  If EventID = #PB_Event_GadgetDrop ; can only be the files gadget
    If *Debugger\ProfilerFiles
      *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
      
      Target = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files])
      If Target = -1
        Target = CountGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files])
      EndIf
      
      index = GetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], DragItem)
      Text$ = GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], DragItem, 0) + Chr(10) + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], DragItem, 1) + Chr(10) + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], DragItem, 2)
      state = GetGadgetItemState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], DragItem)
      RemoveGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], DragItem)
      
      If DragItem < Target
        Target - 1
      EndIf
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], Target, Text$, ImageID(*files\file[index]\ColorImage))
      SetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], Target, index) ; preserve the index
      If state & #PB_ListIcon_Checked
        SetGadgetItemState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], Target, #PB_ListIcon_Checked)
      EndIf
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], Target)
      
      Profiler_DrawAll(*Debugger)    ; redraw with the new order
                                     ;Profiler_DrawPreview(*Debugger)
    EndIf
    
  ElseIf EventID = #PB_Event_Menu
    Select EventMenu()
        
      Case #DEBUGGER_MENU_Zoomin
        *Debugger\ProfilerRatioX * 1.15
        *Debugger\ProfilerRatioY * 1.15
        If *Debugger\ProfilerRatioX > 30.0: *Debugger\ProfilerRatioX = 30.0: EndIf
        If *Debugger\ProfilerRatioY > 30.0: *Debugger\ProfilerRatioY = 30.0: EndIf
        Profiler_UpdatePageLength(*Debugger)
        Profiler_DrawAll(*Debugger)
        
      Case #DEBUGGER_MENU_Zoomout
        *Debugger\ProfilerRatioX * 0.85
        *Debugger\ProfilerRatioY * 0.85
        If *Debugger\ProfilerRatioX < 1e-5: *Debugger\ProfilerRatioX = 1e-5: EndIf
        If *Debugger\ProfilerRatioY < 1e-2: *Debugger\ProfilerRatioY = 1e-2: EndIf
        Profiler_UpdatePageLength(*Debugger)
        Profiler_DrawAll(*Debugger)
        
      Case #DEBUGGER_MENU_File0 To #DEBUGGER_MENU_File255
        Line = MakeDebuggerLine(EventMenu() - #DEBUGGER_MENU_File0, Profiler_CurrentLine)
        Debugger_ShowLine(*Debugger, Line)
        
    EndSelect
    
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]
        x = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas], #PB_Canvas_MouseX)
        y = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas], #PB_Canvas_MouseY)
        Select EventType()
          Case #PB_EventType_MouseEnter, #PB_EventType_MouseMove
            Profiler_MouseMove(*Debugger, x, y)
          Case #PB_EventType_LeftButtonDown
            Profiler_LButtonDown(*Debugger, x, y)
          Case #PB_EventType_LeftButtonUp
            Profiler_LButtonUp(*Debugger)
          Case #PB_EventType_RightButtonDown
            Profiler_RButtonDown(*Debugger, x, y)
        EndSelect
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start]
        Command.CommandInfo\Command = #COMMAND_StartProfiler
        SendDebuggerCommand(*Debugger, @Command)
        *Debugger\ProfilerRunning = 1
        UpdateProfilerWindowState(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop]
        Command.CommandInfo\Command = #COMMAND_StopProfiler
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetProfilerData ; do an update as well...
        SendDebuggerCommand(*Debugger, @Command)
        
        *Debugger\ProfilerRunning = 0
        UpdateProfilerWindowState(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset]
        Command.CommandInfo\Command = #COMMAND_ResetProfiler
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetProfilerData ; do an update as well...
        SendDebuggerCommand(*Debugger, @Command)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update]
        Command.CommandInfo\Command = #COMMAND_GetProfilerData
        SendDebuggerCommand(*Debugger, @Command)
        
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter]
        Width  = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container])-#ContainerBorder
        Height = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container])-#ContainerBorder
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas], 0, 0, Width-15, Height-15)
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 0, Height-15, Width-15, 15)
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], Width-15, 0, 15, Height-15)
        Profiler_UpdatePageLength(*Debugger) ; adjust the scrollbars
        Profiler_DrawAll(*Debugger)          ; redraw after every resize
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files]
        If EventType() = #PB_EventType_RightClick
          index = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files])
          If index <> -1 And *Debugger\ProfilerFiles
            file = GetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index) ; get real index
            *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
            newColor = ColorRequester(*files\file[file]\Color)
            
            If newColor <> -1
              *files\file[file]\Color = newColor
              
              newImage = CreateImage(#PB_Any, #DEFAULT_ListIconImageSize, #DEFAULT_ListIconImageSize)
              If newImage And StartDrawing(ImageOutput(newImage))
                Box(0, 0, #DEFAULT_ListIconImageSize, #DEFAULT_ListIconImageSize, $FFFFFF)
                Box(#DEFAULT_ListIconImageOffset, #DEFAULT_ListIconImageOffset, 12, 12, $000000)
                Box(#DEFAULT_ListIconImageOffset+1, #DEFAULT_ListIconImageOffset+1, 10, 10, newColor)
                StopDrawing()
                
                If *files\file[file]\ColorImage
                  FreeImage(*files\file[file]\ColorImage)
                EndIf
                *files\file[file]\ColorImage = newImage
                
                Text$ = GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index, 0) + Chr(10) + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index, 1) + Chr(10) + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index, 2)
                state = GetGadgetItemState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index)
                RemoveGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index)
                AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index, Text$, ImageID(newImage))
                SetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index, file) ; preserve the index
                If state & #PB_ListIcon_Checked
                  SetGadgetItemState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index, #PB_ListIcon_Checked)
                EndIf
                
                SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], index)
              EndIf
              
              Profiler_DrawAll(*Debugger)
              ;Profiler_DrawPreview(*Debugger)
            EndIf
          EndIf
          
        ElseIf EventType() = #PB_EventType_DragStart
          DragItem = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files])
          If DragItem <> -1
            DragPrivate(#DRAG_Profiler, #PB_Drag_Move)
          EndIf
          
        Else
          Profiler_UpdateBounds(*Debugger)
          Profiler_DrawAll(*Debugger)
        EndIf
        
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select]
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select], 1)
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Drag], 0)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Drag]
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select], 0)
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Drag], 1)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomin]
        *Debugger\ProfilerRatioX * 1.15
        *Debugger\ProfilerRatioY * 1.15
        If *Debugger\ProfilerRatioX > 30.0: *Debugger\ProfilerRatioX = 30.0: EndIf
        If *Debugger\ProfilerRatioY > 30.0: *Debugger\ProfilerRatioY = 30.0: EndIf
        Profiler_UpdatePageLength(*Debugger)
        Profiler_DrawAll(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomout]
        *Debugger\ProfilerRatioX * 0.85
        *Debugger\ProfilerRatioY * 0.85
        If *Debugger\ProfilerRatioX < 1e-5: *Debugger\ProfilerRatioX = 1e-5: EndIf
        If *Debugger\ProfilerRatioY < 1e-2: *Debugger\ProfilerRatioY = 1e-2: EndIf
        Profiler_UpdatePageLength(*Debugger)
        Profiler_DrawAll(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomall]
        MaxCount = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], #PB_ScrollBar_Maximum)
        MaxLine  = GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], #PB_ScrollBar_Maximum)
        Profiler_CalculateViewport(*Debugger, @Area.ProfilerDrawing)
        
        *Debugger\ProfilerRatioX = (Area\w / MaxCount) * 0.995
        *Debugger\ProfilerRatioY = (Area\h / MaxLine)  * 0.995
        
        If *Debugger\ProfilerRatioX > 30.0: *Debugger\ProfilerRatioX = 30.0: EndIf
        If *Debugger\ProfilerRatioY > 30.0: *Debugger\ProfilerRatioY = 30.0: EndIf
        
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 0)
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], 0)
        Profiler_UpdatePageLength(*Debugger)
        Profiler_DrawAll(*Debugger)
        
        
        CompilerIf #CompileWindows = 0
          
          ; On Windows, the redrawing is triggered in ScrollbarCallback() for realtime
          ; scrolling, so this must be ignored then!
          ;
          ; On Linux, we do not need a spechial solution, so use the normal event system
          ;
        Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX]
          Profiler_DrawAll(*Debugger)
          
        Case *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY]
          Profiler_DrawAll(*Debugger)
          
        CompilerEndIf
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
    Height = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], @NewWidth, @ButtonHeight)
    ButtonWidth = Max(100, NewWidth)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], @NewWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, NewWidth)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset], @NewWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, NewWidth)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update], @NewWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, NewWidth)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start],  10, 10,                ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop],   10, 15+ButtonHeight,   ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset],  10, 20+ButtonHeight*2, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update], 10, 35+ButtonHeight*3, ButtonWidth, ButtonHeight)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Drag],    ButtonWidth-90, 50+ButtonHeight*4, 30, 30)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select],  ButtonWidth-55, 50+ButtonHeight*4, 30, 30)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Cross],   ButtonWidth-20, 50+ButtonHeight*4, 30, 30)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomin],  ButtonWidth-90, 85+ButtonHeight*4, 30, 30)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomout], ButtonWidth-55, 85+ButtonHeight*4, 30, 30)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomall], ButtonWidth-20, 85+ButtonHeight*4, 30, 30)
    
    ;ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Preview], 10, 130+ButtonHeight*4, ButtonWidth, Height-140-ButtonHeight*4)
    
    
    If *Debugger\NbIncludedFiles > 0
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter], 20+ButtonWidth, 10, Width-30-ButtonWidth, Height-20)
      Width  = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container])-#ContainerBorder
      Height = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container])-#ContainerBorder
    Else
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container], 20+ButtonWidth, 10, Width-30-ButtonWidth, Height-20)
      Width  = Width-30-ButtonWidth - #ContainerBorder
      Height = Height-20 - #ContainerBorder
    EndIf
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas], 0, 0, Width-#Profiler_ScrollbarWidth, Height-#Profiler_ScrollbarWidth)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX], 0, Height-#Profiler_ScrollbarWidth, Width-#Profiler_ScrollbarWidth, #Profiler_ScrollbarWidth)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY], Width-#Profiler_ScrollbarWidth, 0, #Profiler_ScrollbarWidth, Height-#Profiler_ScrollbarWidth)
    
    Profiler_UpdatePageLength(*Debugger) ; adjust the scrollbars
    Profiler_DrawAll(*Debugger)          ; redraw after every resize
                                         ;Profiler_DrawPreview(*Debugger)
    
  ElseIf EventID = #PB_Event_CloseWindow
    
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler]) = 0
      ProfilerMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
      If ProfilerMaximize = 0
        ProfilerX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
        ProfilerY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
        ProfilerWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
        ProfilerHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
      EndIf
    EndIf
    
    If *Debugger\NbIncludedFiles > 0
      ProfilerSplitter  = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter])
    EndIf
    
    ; free profiler array
    ; keep the file table in case the window is reopened (is freed in CheckDestroy)
    If *Debugger\ProfilerData
      FreeMemory(*Debugger\ProfilerData)
      *Debugger\ProfilerData = 0
    EndIf
    
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
    
    ;     If *Debugger\ProfilerPreview
    ;       FreeImage(*Debugger\ProfilerPreview)
    ;       *Debugger\ProfilerPreview = 0
    ;     EndIf
    
    *Debugger\Windows[#DEBUGGER_WINDOW_Profiler] = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
EndProcedure

Procedure OpenProfilerWindow(*Debugger.DebuggerData)
  
  If Profiler_Arrow = 0
    Profiler_Arrow   = CatchImageDPI(#PB_Any, ?Profiler_Arrow)
    Profiler_Select  = CatchImageDPI(#PB_Any, ?Profiler_Select)
    Profiler_Cross   = CatchImageDPI(#PB_Any, ?Profiler_Cross)
    Profiler_Zoomin  = CatchImageDPI(#PB_Any, ?Profiler_Zoomin)
    Profiler_Zoomout = CatchImageDPI(#PB_Any, ?Profiler_Zoomout)
    Profiler_Zoomall = CatchImageDPI(#PB_Any, ?Profiler_Zoomall)
  EndIf
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Profiler]
    SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler])
    
  Else
    Window = OpenWindow(#PB_Any, ProfilerX, ProfilerY, ProfilerWidth, ProfilerHeight, Language("Debugger","ProfilerTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_Invisible)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_Profiler] = Window
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start]  = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Misc","Start"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop]   = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Misc","Stop"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset]  = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Reset"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      
      If *Debugger\ProfilerRunning
        DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], 1)
      Else
        DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], 1)
      EndIf
      
      ;*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Preview]   = ImageGadget(#PB_Any, 0, 0, 0, 0, 0)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomin]    = ButtonImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(Profiler_Zoomin))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomout]   = ButtonImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(Profiler_Zoomout))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Zoomall]   = ButtonImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(Profiler_Zoomall))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select]    = ButtonImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(Profiler_Select), #PB_Button_Toggle)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Drag]      = ButtonImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(Profiler_Arrow), #PB_Button_Toggle)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Cross]     = ButtonImageGadget(#PB_Any, 0, 0, 0, 0, ImageID(Profiler_Cross), #PB_Button_Toggle)
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Select], 1)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Double)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Canvas]    = CanvasGadget(#PB_Any, 0, 0, 0, 0, #PB_Canvas_ClipMouse)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollX]   = ScrollBarGadget(#PB_Any, 0, 0, 100, 15, 0, 1, 10000) ; max will automatically be changed when data arrives
      *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_ScrollY]   = ScrollBarGadget(#PB_Any, 0, 0, 15, 100, 0, 1, 1000, #PB_ScrollBar_Vertical)
      CloseGadgetList()
      
      If *Debugger\NbIncludedFiles > 0 ; this is valid here. we only need a filelist if there is more than 1 file!
        *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","File"), 260, #PB_ListIcon_MultiSelect|#PB_ListIcon_CheckBoxes|#PB_ListIcon_AlwaysShowSelection)  ; no fullrowselect so we can select multiple entries without starting a drag
        AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 1, Language("Debugger","CalledLines"), 120)
        AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 2, Language("Debugger","CallsPerLine"), 120)
        
        *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter] = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container], *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], #PB_Splitter_SecondFixed)
        SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter], #PB_Splitter_FirstMinimumSize, 100)
        SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter], #PB_Splitter_SecondMinimumSize, 100)
        
        EnableGadgetDrop(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], #PB_Drop_Private, #PB_Drag_Move, #DRAG_Profiler)
        
        If *Debugger\ProfilerFiles
          *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
          
          For file = 0 To *Debugger\NbIncludedFiles
            ; we store the index in the data field so we can reorder the entries...
            AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], file, GetDebuggerRelativeFile(*Debugger, file << #DEBUGGER_DebuggerLineFileOffset), ImageID(*files\file[file]\ColorImage))
            SetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], file, file)
          Next file
        EndIf
      Else
        *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files]    = 0
        *Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter] = 0
      EndIf
      
      CompilerIf #CompileWindows
        ; callback to catch the scrollbar events in realtime and for mouse events
        ;
        SetWindowLongPtr_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container]), #GWL_USERDATA, *Debugger)
        *Debugger\ProfilerScrollCallback = SetWindowLongPtr_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Container]), #GWL_WNDPROC, @Profiler_ScrollbarCallback())
      CompilerEndIf
      
      Debugger_AddShortcuts(Window)
      
      ProfilerWindowEvents(*Debugger, #PB_Event_SizeWindow)
      
      If *Debugger\NbIncludedFiles > 0
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Splitter], ProfilerSplitter)
        
        w = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files]) - 20 ; subtract the scrollbar width
        If w < 360
          SetGadgetItemAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0, #PB_ListIcon_ColumnWidth, w/3, 0)
          SetGadgetItemAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0, #PB_ListIcon_ColumnWidth, w/3, 1)
          SetGadgetItemAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0, #PB_ListIcon_ColumnWidth, w/3, 2)
        Else
          SetGadgetItemAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0, #PB_ListIcon_ColumnWidth, w-240, 0)
          SetGadgetItemAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0, #PB_ListIcon_ColumnWidth, 120, 1)
          SetGadgetItemAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0, #PB_ListIcon_ColumnWidth, 120, 2)
        EndIf
      EndIf
      
      EnsureWindowOnDesktop(Window)
      If ProfilerMaximize
        ShowWindowMaximized(Window)
      Else
        HideWindow(Window, 0)
      EndIf
      
      UpdateProfilerWindowState(*Debugger)  ; also updates the "profiler running state"
      
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
      
      ; this has to be done only once per program...
      ;
      If *Debugger\ProfilerFiles = 0 And ProfilerRunAtStart = 0 ; with runatstart, this command is already sent!
        Command.CommandInfo\Command = #COMMAND_GetProfilerOffsets
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      If *Debugger\ProgramState = -1
        ; if the profiler was running when the program ended, we have the final data set already
        ;
        Profiler_UpdateBounds(*Debugger)
        Profiler_DrawAll(*Debugger)
        Profiler_UpdateStats(*Debugger)
        UpdateProfilerWindowState(*Debugger)
        
      Else
        ; request an update
        ;
        Command.CommandInfo\Command = #COMMAND_GetProfilerData
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure UpdateProfilerWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Profiler], Language("Debugger","ProfilerTitle") + " - " + DebuggerTitle(*Debugger\FileName$))
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start],  Language("Misc","Start"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop],   Language("Misc","Stop"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Reset],  Language("Debugger","Reset"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Update], Language("Debugger","Update"))
  
  If *Debugger\NbIncludedFiles > 0
    SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], -1, Language("Debugger","File"), 0)
    SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], -1, Language("Debugger","CalledLines"), 1)
    SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], -1, Language("Debugger","CallsPerLine"), 2)
  EndIf
  
  ProfilerWindowEvents(*Debugger, #PB_Event_SizeWindow) ; to update any gadget size requirements
  
EndProcedure


Procedure Profiler_DebuggerEvent(*Debugger.DebuggerData)
  
  If *Debugger\Command\Command = #COMMAND_ControlProfiler
    
    If *Debugger\Command\Value1 = 1 ; show
      OpenProfilerWindow(*Debugger)
    EndIf
    
    ; Update the gadget content (both for show and update commands)
    *Debugger\ProfilerRunning = *Debugger\Command\Value2
    
    If *Debugger\Windows[#DEBUGGER_WINDOW_Profiler]
      If *Debugger\ProfilerRunning
        DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], 0)
        DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], 1)
      Else
        DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Start], 1)
        DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Stop], 0)
      EndIf
    EndIf
    
  ElseIf *Debugger\Command\Command = #COMMAND_ProfilerOffsets And *Debugger\CommandData And *Debugger\ProfilerFiles = 0
    ; this is done only once, so no freeing of old data
    ;
    count = *Debugger\Command\Value1
    
    *Debugger\ProfilerFiles = AllocateMemory(count * SizeOf(Debugger_ProfilerData))
    If *Debugger\ProfilerFiles
      *files.Debugger_ProfilerList = *Debugger\ProfilerFiles
      
      ; calc the max line value of all files
      max = 0
      For i = 0 To count-1
        *files\file[i]\Offset = PeekL(*Debugger\CommandData + i*SizeOf(LONG))
        
        ; calculate the length of this file
        If i < count-1
          *files\file[i]\Size = PeekL(*Debugger\CommandData + (i+1)*SizeOf(LONG)) - *files\file[i]\Offset
        Else
          *files\file[i]\Size = *Debugger\Command\Value2 - *files\file[i]\Offset
        EndIf
        
        ; init the color values and images
        *files\file[i]\Color = PeekL(?Profiler_Colors + (i % #Profiler_Colors) * SizeOf(LONG))
        
        newImage = CreateImage(#PB_Any, #DEFAULT_ListIconImageSize, #DEFAULT_ListIconImageSize)
        If newImage And StartDrawing(ImageOutput(newImage))
          Box(0, 0, #DEFAULT_ListIconImageSize, #DEFAULT_ListIconImageSize, $FFFFFF)
          Box(#DEFAULT_ListIconImageOffset, #DEFAULT_ListIconImageOffset, 12, 12, $000000)
          Box(#DEFAULT_ListIconImageOffset+1, #DEFAULT_ListIconImageOffset+1, 10, 10, *files\file[i]\Color)
          StopDrawing()
        EndIf
        *files\file[i]\ColorImage = newImage
        
        ; add to the list if the window is already open
        If *Debugger\NbIncludedFiles > 0 And *Debugger\Windows[#DEBUGGER_WINDOW_Profiler]
          ; we store the index in the data field so we can reorder the entries...
          AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], i, GetDebuggerRelativeFile(*Debugger, i << #DEBUGGER_DebuggerLineFileOffset), ImageID(*files\file[i]\ColorImage))
          SetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], i, i)
        EndIf
        
        max = Max(max, *files\file[i]\Size)
      Next i
      
      If *Debugger\NbIncludedFiles > 0 And *Debugger\Windows[#DEBUGGER_WINDOW_Profiler]
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Profiler_Files], 0) ; select the first file for display
      EndIf
      
      *Debugger\ProfilerNumberLength = Len(Str(max))
    EndIf
    
  ElseIf *Debugger\Command\Command = #COMMAND_ProfilerData And *Debugger\CommandData And *Debugger\ProfilerFiles ; also keep this if the window is not open (for program end inspection)
    If *Debugger\ProfilerData
      FreeMemory(*Debugger\ProfilerData)
      *Debugger\ProfilerData = 0
    EndIf
    
    If *Debugger\Windows[#DEBUGGER_WINDOW_Profiler] <> 0 ; only draw if there is a window!
      
      ; Only set ProfilerData if we have a window, else when we open a window we get an
      ; error because Profiler_UpdateBounds() was not called yet!
      ;
      ; Simply use the CommandData buffer.
      ; We set that to 0 so it is not freed automatically
      ;
      *Debugger\ProfilerData = *Debugger\CommandData
      *Debugger\CommandData  = 0
      
      Profiler_UpdateBounds(*Debugger)
      Profiler_DrawAll(*Debugger) ; redraw the display
      Profiler_UpdateStats(*Debugger)
      ;Profiler_DrawPreview(*Debugger)
    EndIf
    
  EndIf
  
EndProcedure





DataSection
  
  Profiler_Arrow:   : IncludeBinary "Data/arrow.png"
  Profiler_Select:  : IncludeBinary "Data/select.png"
  Profiler_Cross:   : IncludeBinary "Data/cross.png"
  Profiler_Zoomin:  : IncludeBinary "Data/zoomin.png"
  Profiler_Zoomout: : IncludeBinary "Data/zoomout.png"
  Profiler_Zoomall: : IncludeBinary "Data/zoomall.png"
  
  
  Profiler_Colors:
  Data.l $FF0000
  Data.l $0000FF
  Data.l $008000
  Data.l $0080FF
  Data.l $00FFFF
  Data.l $800080
  Data.l $808000
  Data.l $8000FF
  Data.l $FF8000
  Data.l $004000
  Data.l $808080
  Data.l $400080
  Data.l $800000
  Data.l $FF00FF
  Data.l $FF8080
  Data.l $00FF00
  Data.l $000080
  Data.l $008080
  
  
  Profiler_Numbers:
  Data.b %0111000
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %0111000
  
  Data.b %0001000
  Data.b %0011000
  Data.b %0101000
  Data.b %0001000
  Data.b %0001000
  Data.b %0001000
  Data.b %0001000
  Data.b %0001000
  Data.b %0011100
  
  Data.b %0111000
  Data.b %1000100
  Data.b %0000100
  Data.b %0000100
  Data.b %0001000
  Data.b %0010000
  Data.b %0100000
  Data.b %1000000
  Data.b %1111100
  
  Data.b %0111000
  Data.b %1000100
  Data.b %0000100
  Data.b %0000100
  Data.b %0011000
  Data.b %0000100
  Data.b %0000100
  Data.b %1000100
  Data.b %0111000
  
  Data.b %0000100
  Data.b %0001100
  Data.b %0010100
  Data.b %0100100
  Data.b %1000100
  Data.b %1111100
  Data.b %0000100
  Data.b %0000100
  Data.b %0000100
  
  Data.b %1111100
  Data.b %1000000
  Data.b %1000000
  Data.b %1000000
  Data.b %1111000
  Data.b %0000100
  Data.b %0000100
  Data.b %1000100
  Data.b %0111000
  
  Data.b %0111000
  Data.b %1000100
  Data.b %1000000
  Data.b %1000000
  Data.b %1111000
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %0111000
  
  Data.b %1111100
  Data.b %0000100
  Data.b %0000100
  Data.b %0001000
  Data.b %0001000
  Data.b %0010000
  Data.b %0010000
  Data.b %0100000
  Data.b %0100000
  
  Data.b %0111000
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %0111000
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %0111000
  
  Data.b %0111000
  Data.b %1000100
  Data.b %1000100
  Data.b %1000100
  Data.b %0111100
  Data.b %0000100
  Data.b %0000100
  Data.b %1000100
  Data.b %0111000
  
EndDataSection