; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_Windows
    #Slash = '\'
    #BadSlash = '/'
  CompilerDefault
    #Slash = '/'
    #BadSlash = '\'
CompilerEndSelect

Procedure.i EqualPathLen (s1$, s2$)
  ; -- return length of identical part of the paths in s1$ and s2$
  Protected maxEqual, temp, equal, ret
  Protected *p1.Character, *p2.Character
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    s1$ = UCase(s1$)
    s2$ = UCase(s2$)
  CompilerEndIf
  
  maxEqual = Len(s1$)
  temp = Len(s2$)
  If maxEqual > temp
    maxEqual = temp
  EndIf
  
  *p1 = @s1$
  *p2 = @s2$
  equal = 0
  ret = 0
  While equal < maxEqual And *p1\c = *p2\c
    equal + 1
    If *p1\c = #Slash
      ret = equal
    EndIf
    *p1 + SizeOf(character)
    *p2 + SizeOf(character)
  Wend
  
  ProcedureReturn ret
EndProcedure
Procedure.s RelativePath (baseDir$, absPath$)
  ; -- convert an absolute path to a relative one
  ; in : baseDir$: full name of a directory, with trailing (back)slash
  ;      absPath$: full name of a path to a directory or file
  ; out: absPath$ converted, so that it is relative to baseDir$
  Protected equal, s, i, parent$, ret$=""
  
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If UCase(Left(baseDir$, 1)) <> UCase(Left(absPath$, 1))
      ProcedureReturn absPath$  ; can't build a relative path
    EndIf
  CompilerEndIf
  
  ReplaceString(baseDir$, Chr(#BadSlash), Chr(#Slash), #PB_String_InPlace)
  ReplaceString(absPath$, Chr(#BadSlash), Chr(#Slash), #PB_String_InPlace)
  equal = EqualPathLen(baseDir$, absPath$)
  
  s = CountString(Mid(baseDir$, equal+1), Chr(#Slash))
  parent$ = ".." + Chr(#Slash)
  For i = 1 To s
    ret$ + parent$
  Next
  
  ProcedureReturn ret$ + Mid(absPath$, equal+1)
EndProcedure
Procedure OpenDoc(doc.s)
  CompilerIf #PB_Compiler_OS=#PB_OS_MacOS
    RunProgram("open",doc,"",#PB_Program_Open)
  CompilerElse
    RunProgram(doc)
  CompilerEndIf
EndProcedure

; Drawing functions for special cells in grid gadget
Procedure DrawFileRequester(x,y,width,height,col,row)
  height - 1
  width - 2
  
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(#Form_Font))
  address = grid_GetCellData(propgrid,col,row)
  text.s = ""
  
  If address
    text.s = PeekS(grid_GetCellData(propgrid,col,row))
    DrawText(x,y,text, ToolsPanelFrontColor)
  EndIf
  
  x1 = x + TextWidth(text) + 3
  y1 = y
  width = width + x - x1
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, y1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 18,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  x = x1 + (width - TextWidth("...")) / 2
  y = y1 -2
  DrawingFont(FontID(#Form_Font))
  DrawText(x,y,"...",RGB(0,0,0))
EndProcedure
Procedure DrawFontPicker(x,y,width,height,col,row)
  height - 1
  width - 2
  
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(#Form_Font))
  address = grid_GetCellData(propgrid,col,row)
  text.s = ""
  
  If address
    text.s = PeekS(grid_GetCellData(propgrid,col,row))
    DrawText(x,y,text, ToolsPanelFrontColor)
  EndIf
  
  x1 = x + TextWidth(text) + 3
  y1 = y
  width = width + x - x1
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, y1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, height,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  x = x1 + (width - TextWidth("...")) / 2
  y = y1 -2
  DrawingFont(FontID(#Form_Font))
  DrawText(x,y,"...",RGB(0,0,0))
EndProcedure
Procedure DrawColorPicker(x,y,width,height,col,row)
  height - 1
  width - 2
  
  color = grid_GetCellData(propgrid,col,row)
  
  If color > -1
    DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
    Box(x,y,32,height,color)
  Else
    DrawingMode(#PB_2DDrawing_Outlined)
  EndIf
  DrawingMode(#PB_2DDrawing_Outlined)
  Box(x,y,32,height,RGB(0,0,0))
  
  x1 = x + 34
  y1 = y
  width = width - 34
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, y1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, height,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  x = x1 + (width - TextWidth("...")) / 2
  y = y1 -2
  DrawingFont(FontID(#Form_Font))
  DrawText(x,y,"...",RGB(0,0,0))
EndProcedure
Procedure DrawButton(x1,y1,width,height,col,row)
  height - 1
  width - 2
  
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, x1+9)
  Box(x1+1,y1+1,width-2, 8)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+9,width-2, 7,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 18,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(#Form_Font))
  caption.s = Language("Form", "Select")
  x = x1 + (width- TextWidth(caption)) / 2
  y = y1 + (18 - TextHeight(caption)) / 2
  DrawText(x,y,caption,RGB(0,0,0))
EndProcedure
Procedure DrawButtonB(x1,y1,width,height,col,row)
  height - 1
  width - 2
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, x1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 22,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(#Form_Font))
  caption.s = Language("Form", "Select")
  x = x1 + (width- TextWidth(caption)) / 2
  y = y1 + (22 - TextHeight(caption)) / 2
  DrawText(x,y,caption,RGB(0,0,0))
EndProcedure
Procedure DrawButtonC(x1,y1,width,height,col,row)
  height - 1
  width - 2
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, x1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 22,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(#Form_Font))
  caption.s = Language("Form", "SetRelativePath")
  x = x1 + (width- TextWidth(caption)) / 2
  y = y1 + (22 - TextHeight(caption)) / 2
  DrawText(x,y,caption,RGB(0,0,0))
EndProcedure
Procedure DrawUp(x1,y1,width,height,col,row)
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, y1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 22,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  x = x1 + (width - ImageWidth(#Img_Up)) / 2
  y = y1 + (22 - ImageHeight(#Img_Up)) / 2
  DrawAlphaImage(ImageID(#Img_Up),x,y)
EndProcedure
Procedure DrawDown(x1,y1,width,height,col,row)
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, y1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 22,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  x = x1 + (width - ImageWidth(#Img_Down)) / 2
  y = y1 + (22 - ImageHeight(#Img_Down)) / 2
  DrawAlphaImage(ImageID(#Img_Down),x,y)
EndProcedure
Procedure DrawDelete(x1,y1,width,height,col,row)
  DrawingMode(#PB_2DDrawing_Gradient)
  BackColor(RGB(255,255,255))
  FrontColor(RGB(244,244,244))
  LinearGradient(x1+1,y1+1,x1+1, y1+9)
  Box(x1+1,y1+1,width-2, 10)
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1+1,y1+11,width-2, 9,RGB(236,236,236))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1,y1,width, 22,3,3,RGB(144,144,144))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  x = x1 + (width - ImageWidth(#Img_Delete)) / 2
  y = y1 + (22 - ImageHeight(#Img_Delete)) / 2
  DrawAlphaImage(ImageID(#Img_Delete),x,y)
EndProcedure

; Images manager
Procedure ImageManager(img.s)
  
  If Not FindMapElement(Images(),img)
    Images(img) = LoadImage(#PB_Any,img)
  EndIf
  
  ProcedureReturn Images(img)
EndProcedure
Procedure AddImage(img.s)
  ForEach FormWindows()\FormImg()
    If img = FormWindows()\FormImg()\img
      ProcedureReturn @FormWindows()\FormImg()
      Break
    EndIf
  Next
  
  AddElement(FormWindows()\FormImg())
  FormWindows()\FormImg()\img = img
  FormWindows()\FormImg()\inline = inlineimg
  FormWindows()\FormImg()\pbany = FormVariable
  ProcedureReturn @FormWindows()\FormImg()
EndProcedure
Procedure CleanImageList()
  PushListPosition(FormWindows())
  ForEach FormWindows()
    ForEach FormWindows()\FormImg()
      found = 0
      
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\image = @FormWindows()\FormImg()
          found = 1
          Break
        EndIf
      Next
      
      ForEach FormWindows()\FormMenus()
        If FormWindows()\FormMenus()\icon = @FormWindows()\FormImg()
          found = 1
          Break
        EndIf
      Next
      
      ForEach FormWindows()\FormStatusbars()
        If FormWindows()\FormStatusbars()\img = @FormWindows()\FormImg()
          found = 1
          Break
        EndIf
      Next
      
      ForEach FormWindows()\FormToolbars()
        If FormWindows()\FormToolbars()\img = @FormWindows()\FormImg()
          found = 1
          Break
        EndIf
      Next
      
      If Not found ; image is used nowhere, delete it!
        DeleteElement(FormWindows()\FormImg())
      EndIf
    Next
  Next
  
  PopListPosition(FormWindows())
EndProcedure

Procedure FormChanges(change.b)
  If ListSize(FormWindows())
    FormWindows()\changes_monitor = change
    UpdateSourceStatus(change)
    
    If change = 0
      FormWindows()\changes_code = 0
    EndIf
  EndIf
EndProcedure
