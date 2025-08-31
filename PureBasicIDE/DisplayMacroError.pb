; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


CompilerIf #SpiderBasic
  #NbIntendKeywords = 49
CompilerElse
  #NbIntendKeywords = 47
CompilerEndIf

Structure IntendKeywords
  Keyword$
  NeutralizeKeyword$
  Intend.l
  NextIntend.l
  LineBefore.l
  LineAfter.l
EndStructure

Global Dim IntendKeywords.IntendKeywords(#NbIntendKeywords)

Restore IntendKeywords
For i = 1 To #NbIntendKeywords
  Read.s IntendKeywords(i)\Keyword$
  Read.s IntendKeywords(i)\NeutralizeKeyword$
  Read.l IntendKeywords(i)\Intend
  Read.l IntendKeywords(i)\NextIntend
  Read.l IntendKeywords(i)\LineBefore
  Read.l IntendKeywords(i)\LineAfter
Next i

Procedure MacroErrorWindowEvents(EventID)
  Protected Close = 0
  
  If EventID = #PB_Event_SizeWindow
    GetRequiredSize(#GADGET_MacroError_Close, @ButtonWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, 80)
    ResizeGadget(#GADGET_MacroError_Scintilla, 5, 5, WindowWidth(#WINDOW_MacroError)-10, WindowHeight(#WINDOW_MacroError)-25-ButtonHeight)
    ResizeGadget(#GADGET_MacroError_Close, (WindowWidth(#WINDOW_MacroError)-ButtonWidth)/2, WindowHeight(#WINDOW_MacroError)-10-ButtonHeight, ButtonWidth, ButtonHeight)
    
  ElseIf EventID = #PB_Event_Gadget And EventGadget() = #GADGET_MacroError_Close
    Close = 1
    
  ElseIf EventID = #PB_Event_Menu And EventMenu() = #MENU_MacroError_Close
    Close = 1
    
  ElseIf EventID = #PB_Event_CloseWindow
    Close = 1
    
  EndIf
  
  If Close
    If MemorizeWindow
      MacroErrorWindowWidth  = WindowWidth(#WINDOW_MacroError)
      MacroErrorWindowHeight = WindowHeight(#WINDOW_MacroError)
    EndIf
    
    CloseWindow(#WINDOW_MacroError)
  EndIf
  
EndProcedure


Procedure DisplayMacroError(MacroErrorLine, List MacroLines.s())
  
  If IsWindow(#WINDOW_MacroError)
    CloseWindow(#WINDOW_MacroError)
  EndIf
  
  If OpenWindow(#WINDOW_MacroError, 0, 0, MacroErrorWindowWidth, MacroErrorWindowHeight, Language("Misc", "MacroErrorTitle"), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible, WindowID(#WINDOW_Main))
    CreateCodeViewer(#GADGET_MacroError_Scintilla, 0, 0, 0, 0, #False)
    ButtonGadget(#GADGET_MacroError_Close, 0, 0, 0, 0, Language("Misc", "Close"), #PB_Button_Default)
    
    AddKeyboardShortcut(#WINDOW_MacroError, #PB_Shortcut_Return, #MENU_MacroError_Close)
    AddKeyboardShortcut(#WINDOW_MacroError, #PB_Shortcut_Escape, #MENU_MacroError_Close)
    
    ; read the lines into an array
    ;
    Count = ListSize(MacroLines())
    Protected Dim Lines.s(Count)
    index = 0
    ForEach MacroLines()
      Lines(index) = MacroLines()
      index + 1
    Next MacroLines()
    
    ; format the lines
    Protected NewList Stack()
    Protected Dim AddLines(Count) ; nonzero for each line where an empty line is before
    Intend = 0
    
    For index = 0 To Count-1
      If Trim(Lines(index)) <> ""
        ClearList(Stack())
        
        *Cursor.Character = @Lines(index)
        While *Cursor\c
          If *Cursor\c = '"' Or *Cursor\c = 39 ; '-char. no need to check comments as the macro parser cuts them
            EndChar.c = *Cursor\c
            Repeat
              *Cursor + #CharSize
            Until *Cursor\c = 0 Or *Cursor\c = EndChar
            If *Cursor\c
              *Cursor + #CharSize
            EndIf
            
          ElseIf *Cursor\c = '~' And PeekC(*Cursor + 1) = '"'
            *Cursor + #CharSize
            While *Cursor\c And *Cursor\c <> '"'
              If *Cursor\c = '\'
                *Cursor + #CharSize
                If *Cursor\c
                  *Cursor + #CharSize
                EndIf
              Else
                *Cursor + #CharSize
              EndIf
            Wend
            If *Cursor\c
              *Cursor + #CharSize
            EndIf
            
          ElseIf *Cursor\c = ':' ; the macro parser cuts all space after a :, so we add one for readability
            *Cursor - @Lines(index) ; the string address changes here!
            Lines(index) = Left(Lines(index), *Cursor / #CharSize + 1)+" "+Right(Lines(index), Len(Lines(index)) - *Cursor / #CharSize - 1)
            *Cursor + @Lines(index) + 2 * #CharSize
            
          ElseIf ValidCharacters(*Cursor\c)
            *Start = *Cursor
            While ValidCharacters(*Cursor\c)
              *Cursor + #CharSize
            Wend
            
            ; Get the word for easier comparison
            Word$ = PeekS(*Start, (*Cursor - *Start) / #CharSize)
            
            For i = 1 To #NbIntendKeywords
              If IntendKeywords(i)\Keyword$ = Word$ ; Note: CompareStringMemory() won't work here, as "For" and "ForEach" will be found as the same name (and indented 2 times)
                found = 0                           ; look for another keyword that neutralizes this one
                field = 1
                Repeat
                  keyword$ = StringField(IntendKeywords(i)\NeutralizeKeyword$, field, ",")
                  If keyword$ <> ""
                    ForEach Stack()
                      If IntendKeywords(Stack())\Keyword$ = keyword$
                        found = 1
                        DeleteElement(Stack())
                        Break 2
                      EndIf
                    Next Stack()
                  EndIf
                  field + 1
                Until keyword$ = ""
                
                If found = 0 ; not neutralized, so add to the stack
                  AddElement(Stack())
                  Stack() = i ; keyword index
                EndIf
                
                Break
              EndIf
            Next i
            
          Else
            *Cursor + #CharSize
          EndIf
          
        Wend
        
        ; calculate intend for this line
        ForEach Stack()
          Intend + IntendKeywords(Stack())\Intend
        Next Stack()
        
        If Intend > 0
          If RealTab
            Lines(index) = RSet(Chr(9), Intend, Chr(9)) + Lines(index)
          Else
            Lines(index) = Space(Intend * TabLength) + Lines(index)
          EndIf
        Else
          Intend = 0
        EndIf
        
        ; calculate intend for next line
        ForEach Stack()
          Intend + IntendKeywords(Stack())\NextIntend
        Next Stack()
        
        ; add new lines if needed (only if there is a single keyword on the line
        If ListSize(Stack()) = 1
          AddLines(index) + IntendKeywords(Stack())\LineBefore
          AddLines(index+1) + IntendKeywords(Stack())\LineAfter
        EndIf
      EndIf
    Next index
    
    ; write lines back to buffer
    For i = 0 To Count-1
      Buffer$ + Lines(i) + #NewLine
      
      If AddLines(i+1) > 0
        Buffer$ + #NewLine
      EndIf
    Next i
    
    *Buffer = Ascii(Buffer$) ; Needs to be freed with FreeMemory() !
    If *Buffer
      SetCodeViewer(#GADGET_MacroError_Scintilla, *Buffer, *ActiveSource\Parser\Encoding)
      FreeMemory(*Buffer)
    EndIf
    
    MacroErrorWindowEvents(#PB_Event_SizeWindow)
    HideWindow(#WINDOW_MacroError, 0)
    
    ; mark the error line. (must calculate added lines first)
    Increase = 0
    For i = 1 To MacroErrorLine - 1
      If AddLines(i) > 0
        Increase + 1
      EndIf
    Next i
    MacroErrorLine + Increase - 1
    
    ScintillaSendMessage(#GADGET_MacroError_Scintilla, #SCI_LINESCROLL, 0, MacroErrorLine-4)
    ScintillaSendMessage(#GADGET_MacroError_Scintilla, #SCI_ENSUREVISIBLE, MacroErrorLine, 0)
    ScintillaSendMessage(#GADGET_MacroError_Scintilla, #SCI_SETSEL, ScintillaSendMessage(#GADGET_MacroError_Scintilla, #SCI_POSITIONFROMLINE, MacroErrorLine), ScintillaSendMessage(#GADGET_MacroError_Scintilla, #SCI_GETLINEENDPOSITION, MacroErrorLine))
    
    SetActiveWindow(#WINDOW_MacroError)
    SetActiveGadget(#GADGET_MacroError_Close)
  EndIf
  
  
EndProcedure


Procedure UpdateMacroErrorWindow()
  
  SetWindowTitle(#WINDOW_MacroError, Language("Misc", "MacroErrortitle"))
  SetGadgetText(#GADGET_MacroError_Close, Language("Misc", "Close"))
  UpdateCodeViewer(#GADGET_MacroError_Scintilla) ; update the coloring
  
EndProcedure


DataSection
  
  ; Keywords that should produce a change in intendation.
  ; Order does not matter.
  ;
  ; First the Keyword, then the keyword, that 'neutralized' it (for multiple, separate with ",")
  ; then the intend change For the line With the keyword,
  ; then the change for the line after the keyword
  ; then whether the command should be preceded by an empty line
  ; then whether the command should be followed by an empty line
  ;
  IntendKeywords:
  Data$ "If", "EnfIf"                   : Data.l  0, 1, 0, 0
  Data$ "Else", ""                      : Data.l -1, 1, 0, 0
  Data$ "ElseIf", ""                    : Data.l -1, 1, 0, 0
  Data$ "EndIf", "If"                   : Data.l -1, 0, 0, 0
  Data$ "Select", "EndSelect"           : Data.l  0, 2, 0, 0
  Data$ "Case", ""                      : Data.l -1, 1, 0, 0
  Data$ "Default", ""                   : Data.l -1, 1, 0, 0
  Data$ "EndSelect", "Select"           : Data.l -2, 0, 0, 0
  Data$ "CompilerIf", "CompilerEndIF"   : Data.l  0, 1, 0, 0
  Data$ "CompilerElse", ""              : Data.l -1, 1, 0, 0
  Data$ "CompilerElseIf", ""            : Data.l -1, 1, 0, 0
  Data$ "CompilerEndIf", "CompilerIf"   : Data.l -1, 0, 0, 0
  Data$ "CompilerSelect", "CompilerEndSelect": Data.l  0, 2, 0, 0
  Data$ "CompilerCase", ""              : Data.l -1, 1, 0, 0
  Data$ "CompilerDefault", ""           : Data.l -1, 1, 0, 0
  Data$ "CompilerEndSelect", "CompilerSelect": Data.l -2, 0, 0, 0
  Data$ "Macro", "EndMacro"             : Data.l  0, 1, 1, 0
  Data$ "EndMacro", "Macro"             : Data.l -1, 0, 0, 1
  Data$ "With", "EndWith"               : Data.l  0, 1, 0, 0
  Data$ "EndWith", "With"               : Data.l -1, 0, 0, 0
  Data$ "Import", "EndImport"           : Data.l  0, 1, 1, 0
  Data$ "ImportC", "EndImport"          : Data.l  0, 1, 1, 0
  Data$ "EndImport", "Import,ImportC"   : Data.l -1, 0, 0, 1
  Data$ "Interface", "EndInterface"     : Data.l  0, 1, 1, 0
  Data$ "EndInterface", "Interface"     : Data.l -1, 0, 0, 1
  Data$ "Structure", "EndStructure"     : Data.l  0, 1, 1, 0
  Data$ "EndStructure", "Structure"     : Data.l -1, 0, 0, 1
  Data$ "Enumeration", "EndEnumeration" : Data.l  0, 1, 1, 0
  Data$ "EnumerationBinary", "EndEnumeration" : Data.l  0, 1, 1, 0
  Data$ "EndEnumeration", "Enumeration" : Data.l -1, 0, 0, 1
  Data$ "StructureUnion", "EndStructureUnion": Data.l  0, 1, 0, 0
  Data$ "EndStructureUnion", "StructureUnion": Data.l -1, 0 , 0, 0
  Data$ "DataSection", "EndDataSection" : Data.l  0, 1, 1, 0
  Data$ "EndDataSection", "DataSection" : Data.l -1, 0, 0, 1
  Data$ "For", "Next"                   : Data.l  0, 1, 0, 0
  Data$ "ForEach", "Next"               : Data.l  0, 1, 0, 0
  Data$ "Next", "For,ForEach"           : Data.l -1, 0, 0, 0
  Data$ "Repeat", "Until,ForEver"       : Data.l  0, 1, 0, 0
  Data$ "Until", "Repeat"               : Data.l -1, 0, 0, 0
  Data$ "ForEver", "Repeat"             : Data.l -1, 0, 0, 0
  Data$ "While", "Wend"                 : Data.l  0, 1, 0, 0
  Data$ "Wend", "While"                 : Data.l -1, 0, 0, 0
  Data$ "Procedure", "EndProcedure"     : Data.l  0, 1, 1, 0
  Data$ "ProcedureC", "EndProcedure"    : Data.l  0, 1, 1, 0
  Data$ "ProcedureCDLL", "EndProcedure" : Data.l  0, 1, 1, 0
  Data$ "ProcedureDLL", "EndProcedure"  : Data.l  0, 1, 1, 0
  Data$ "EndProcedure", "Procedure,ProcedureC,ProcedureDLL,ProcedureCDLL": Data.l -1, 0, 0, 1
  Data$ "HeaderSection", "EndHeaderSection" : Data.l  0, 1, 1, 0
  Data$ "EndHeaderSection", "HeaderSection" : Data.l -1, 0, 0, 1
  
EndDataSection

