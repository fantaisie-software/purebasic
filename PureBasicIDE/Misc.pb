; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



; Ensure that at least a little bit of the Window is on a screen, so the
; user can find the window. Allow parts of the window to be outside, so
; it can easily be moved out of the way without being annoying
;

#DesktopMargin = 50 ; margin in which window will be moved if mostly outside

Procedure EnsureWindowOnDesktop(Window)
  If GetWindowState(Window) <> #PB_Window_Normal
    ProcedureReturn
  EndIf
  
  Debug "EnsureWindowOnDesktop()"
  Debug "before: "+Str(WindowX(Window))+", "+Str(WindowY(Window))+", "+Str(WindowWidth(Window))+", "+Str(WindowHeight(Window))
  
  ; get Window position
  l = WindowX(Window)
  t = WindowY(Window)
  r = l + WindowWidth(Window)
  b = t + #DesktopMargin ; we want the titlebar to stay on the desktop, so act as if the window is really small
  
  ; monitor with which the window has at least some pixels in common
  monitor = -1
  mode    = 0
  
  Count = ExamineDesktops()
  
  For i = 0 To Count-1
    dl = DesktopX(i)
    dt = DesktopY(i)
    dr = dl + DesktopWidth(i)
    db = dt + DesktopHeight(i)
    
    ; is the window on this desktop (with a margin so it is reachable ?)
    ;
    If r > dl+#DesktopMargin And l < dr-#DesktopMargin And b > dt+#DesktopMargin And t < db-#DesktopMargin
      Debug "--> on desktop: " + Str(i)
      ProcedureReturn
      
      ; else check if any of the window corners is on this desktop
      ;
    ElseIf l < dr And l > dl
      If t < db And t > dt ; top/left corner on screen
        monitor = i
        mode    = 1
      ElseIf b > dt And b < db ; bottom/left corner on screen
        monitor = i
        mode    = 2
      EndIf
      
    ElseIf r > dl And r < dr
      If t < db And t > dt ; top/right corner on screen
        monitor = i
        mode    = 3
      ElseIf b > dt And b < db ; bottom/left corner on screen
        monitor = i
        mode    = 4
      EndIf
      
    EndIf
    
  Next i
  
  ; If we get here, the Window is on no monitor, so move it to the closest one
  ;
  If monitor = -1 ; no coordinates matched, move to main screen
    Debug "--> totally off!"
    ResizeWindow(Window, 100, 100, #PB_Ignore, #PB_Ignore)
    
  Else
    dl = DesktopX(monitor)
    dt = DesktopY(monitor)
    dr = dl + DesktopWidth(monitor)
    db = dt + DesktopHeight(monitor)
    
    If mode = 1 ; top/left corner
      If t > db-#DesktopMargin: t = db-#DesktopMargin: EndIf
      If l > dr-#DesktopMargin: l = dr-#DesktopMargin: EndIf
      
    ElseIf mode = 2 ; bottom/left corner
      If b < dt+#DesktopMargin: b = dt+#DesktopMargin: EndIf
      If l > dr-#DesktopMargin: l = dr-#DesktopMargin: EndIf
      t = b - #DesktopMargin
      
    ElseIf mode = 3 ; top/right corner
      If t > db-#DesktopMargin: t = db-#DesktopMargin: EndIf
      If r < dl+#DesktopMargin: r = dl+#DesktopMargin: EndIf
      l = r - WindowWidth(Window)
      
    Else ; bottom/right corner
      If b < dt+#DesktopMargin: b = dt+#DesktopMargin: EndIf
      If r < dl+#DesktopMargin: r = dl+#DesktopMargin: EndIf
      t = b - #DesktopMargin
      l = r - WindowWidth(Window)
      
    EndIf
    
    ResizeWindow(Window, l, t, #PB_Ignore, #PB_Ignore)
  EndIf
  
  Debug "after : "+Str(WindowX(Window))+", "+Str(WindowY(Window))+", "+Str(WindowWidth(Window))+", "+Str(WindowHeight(Window))
  
EndProcedure

; Generate a unique id by an ever increasing counter (should wrap to 0 if it flows over)
; These IDs are used to identify CompileTargets and Debuggers safely (without invalid pointer problems when they are removed etc)
;
Procedure GetUniqueID()
  Static UniqueID
  
  UniqueID + 1
  
  ; Consider 0 an "invalid ID"
  If UniqueID = 0
    UniqueID + 1
  EndIf
  
  ProcedureReturn UniqueID
EndProcedure


Procedure GetFocusGadgetID(Window)
  
  Gadget = GetActiveGadget()
  If Gadget = -1
    ProcedureReturn 0
  Else
    ProcedureReturn GadgetID(Gadget)
  EndIf
  
EndProcedure


; returns the ImageID if image is valid
Procedure OptionalImageID(Image)
  If IsImage(Image)
    ProcedureReturn ImageID(Image)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure FindMemoryString(*Buffer, Length, String$, Mode)
  StrLength = Len(String$)
  *BufferEnd = *Buffer + Length - StrLength
  While *Buffer <= *BufferEnd
    If CompareMemoryString(*Buffer, @String$, Mode, StrLength) = 0
      ProcedureReturn *Buffer
    Else
      *Buffer + 1
    EndIf
  Wend
  ProcedureReturn 0
EndProcedure

; NOTE: length is in characters!
Procedure FindMemoryCharacter(*Buffer.Character, Length, Character.c)
  *BufferEnd = *Buffer + Length*SizeOf(Character)
  While *Buffer < *BufferEnd
    If *Buffer\c = Character
      ProcedureReturn *Buffer
    EndIf
    *Buffer + SizeOf(Character)
  Wend
  ProcedureReturn 0
EndProcedure


; Parses a line into whitespace (space, tab) separated tokens
; multiple whitespaces are ignored (so there are no empty tokens like with StringField)
; a #NewLine is considered the line end
; returns the number of found tokens
;
Global Dim *ParseString_Tokens(300) ; max number of tokens
                                    ;
Procedure ParseString(String$)
  Shared ParseString_NbTokens
  Static *Buffer
  Protected *Pointer.Character
  
  ParseString_NbTokens = 0
  
  If Len(String$) > 0
    If *Buffer
      FreeMemory(*Buffer)
    EndIf
    
    *Buffer = AllocateMemory((Len(String$)+1)*#CharSize)
    If *Buffer
      PokeS(*Buffer, String$)
      *Pointer = *Buffer
      
      While *Pointer\c
        
        ; skip any whitespaces
        While *Pointer\c And (*Pointer\c = ' ' Or *Pointer\c = 9): *Pointer + #CharSize: Wend
        
        ; test line end
        If *Pointer\c = 10 Or *Pointer\c = 13 Or *Pointer\c = 0
          *Pointer\c = 0
          Break
        Else  ; ok, here we have a token
          *ParseString_Tokens(ParseString_NbTokens) = *Pointer
          ParseString_NbTokens + 1
        EndIf
        
        ; skip the token
        While *Pointer\c And *Pointer\c <> ' ' And *Pointer\c <> 9: *Pointer + #CharSize: Wend
        
        ; terminate the token
        If *Pointer\c ; if we reached the end, stay there so the loop quits
          *Pointer\c = 0
          *Pointer + #CharSize
        EndIf
        
      Wend
      
    EndIf
  EndIf
  
  ProcedureReturn ParseString_NbTokens
EndProcedure

; returns the given token from a previously parsed string
; index is one based!
;
Procedure.s GetStringToken(Index)
  Shared ParseString_NbTokens
  
  If Index > ParseString_NbTokens Or Index < 1
    ProcedureReturn ""
  Else
    ProcedureReturn PeekS(*ParseString_Tokens(Index-1))
  EndIf
  
EndProcedure

Procedure.s StrByteSize(Size.q)
  
  If Size < 1024
    ProcedureReturn Str(Size) + " Byte"
    
  ElseIf Size < 1024 * 1024
    ProcedureReturn StrF(Size / 1024, 2) + " Kb"
    
  ElseIf Size < 1024 * 1024 * 1024
    ProcedureReturn StrF(Size / (1024 * 1024), 2) + " Mb"
    
  Else
    ProcedureReturn StrF(Size / (1024 * 1024 * 1024), 2) + " Gb"
    
  EndIf
  
EndProcedure

; check if a string is a valid number (integer) and return it in *Output if so
; supports hex and bin
;
Procedure IsNumeric(Text$, *Output.INTEGER)
  ; determine allowed input
  ;
  If Left(Text$, 1) = "$"
    Chars.s = "1234567890ABCDEFabcdef"
    Text$ = Right(Text$, Len(Text$)-1) ; remove this for the tests (so we can properly detect "$$" etc)
    Start$ = "$"
  ElseIf Left(Text$, 1) = "%"
    Chars.s = "10"
    Text$ = Right(Text$, Len(Text$)-1)
    Start$ = "%"
  Else
    Chars.s = "1234567890"
    Start$ = ""
  EndIf
  
  ; cut whitespace
  Text$ = RemoveString(RemoveString(Text$, " "), Chr(9))
  
  If Text$ = ""
    ProcedureReturn #False ; not accepted here
  EndIf
  
  ; check for invalid chars
  ;
  Length = Len(Text$)
  For i = 1 To Length
    If FindString(Chars, Mid(Text$, i, 1), 1) = 0
      ProcedureReturn #False
    EndIf
  Next i
  
  ; return number
  ;
  *Output\i = Val(Start$ + Text$)
  ProcedureReturn #True
EndProcedure

Procedure.s RGBString(Color)
  ProcedureReturn "RGB("+Str(Red(Color))+", "+Str(Green(Color))+", "+Str(Blue(Color))+")"
EndProcedure

Procedure ColorFromRGBString(String$)
  String$ = UCase(RemoveString(RemoveString(String$, " "), Chr(9)))
  String$ = RemoveString(RemoveString(String$, "RGB("), ")")
  ProcedureReturn RGB(Val(StringField(String$, 1, ",")), Val(StringField(String$, 2, ",")), Val(StringField(String$, 3, ",")))
EndProcedure


Procedure.s ModulePrefix(Name$, ModuleName$)
  If ModuleName$ <> ""
    ProcedureReturn ModuleName$ + "::" + Name$
  Else
    ProcedureReturn Name$
  EndIf
EndProcedure

; Convert string to Ascii/UTF8 depending on CodePage
; CodePage is the scintilla value #SC_CP_UTF8 or 0
;
Procedure StringToCodePage(CodePage, String$)
  If CodePage = #SC_CP_UTF8
    Format = #PB_UTF8
  Else
    Format = #PB_Ascii
  EndIf
  
  *Buffer = AllocateMemory(StringByteLength(String$, Format) + 1)
  If *Buffer
    PokeS(*Buffer, String$, -1, Format)
  EndIf
  
  ProcedureReturn *Buffer
EndProcedure

; Get the length of the string in the given code page
; CodePage is the scintilla value #SC_CP_UTF8 or 0
Procedure CodePageLength(CodePage, String$)
  If CodePage = #SC_CP_UTF8
    Format = #PB_UTF8
  Else
    Format = #PB_Ascii
  EndIf
  
  ProcedureReturn StringByteLength(String$, Format)
EndProcedure

