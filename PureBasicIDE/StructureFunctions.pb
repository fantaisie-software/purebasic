; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
;  Helper functions for managing structures/interfaces in the user's code
;  Used mainly by AutoComplete
;

; Parse a Structure content (without Structure XXX / EndStructure)
; And fill Output() with the separated items
; (Output() is not cleared, for better handling of Extends by chaining ParseStructure calls)
;
; Note:
;   As structure/interface items can be names like keywords or PB functions,
;   the usual parsed SourceItem data is not enough to recover a structure's content,
;   so it must be parsed explicitly from a buffer
;
;   Note: Extends must be handled separately
;
;   *Buffer must point AFTER any 'Extends' parts, but may be before any
;   'Align' part.
;
Procedure ParseStructure(*Buffer, Length, List Output.s())
  *BufferEnd  = *Buffer + Length
  *Cursor.PTR = *Buffer
  
  ; skip whitespace
  While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
    *Cursor + 1
  Wend
  
  ; Properly skip any 'Align' part
  If *BufferEnd-*Cursor >= 6 And CompareMemoryString(*Cursor, ToAscii("Align"), #PB_String_NoCaseAscii, 5, #PB_Ascii) = #PB_String_Equal And ValidCharacters(*Cursor\a[5]) = 0
    *Cursor + 5
    
    ; the align part is an expression which may be multiline
    While *Cursor < *BufferEnd
      
      ; Comment
      If *Cursor\b = ';'
        Continuation = IsLineContinuation(*Buffer, *Cursor)
        While *Cursor < *BufferEnd And *Cursor\b <> 10 And *Cursor\b <> 13
          *Cursor + 1
        Wend
        If *Cursor < *BufferEnd-1 And *Cursor\b = 13 And *Cursor\b[1] = 10
          *Cursor + 2
        Else
          *Cursor + 1
        EndIf
        
        ; If not a line continuation, we have skipped the expression so break
        If Continuation = #False
          Break
        EndIf
        
        ; String
      ElseIf *Cursor\b = '"'
        *Cursor + 1
        While *Cursor < *BufferEnd And *Cursor\b <> '"'
          If *Cursor\b = 13 Or *Cursor\b = 10
            Break 2 ; something is weird
          EndIf
          *Cursor + 1
        Wend
        *Cursor + 1 ; skip second "
        
        ; Escape Strings
      ElseIf *Cursor\b = '~' And *Cursor < (*BufferEnd - 1) And *Cursor\b[1] = '"'
        *Cursor + 2
        While *Cursor < *BufferEnd And *Cursor\b <> '"'
          If *Cursor\b = 13 Or *Cursor\b = 10
            Break 2 ; something is weird
          ElseIf *Cursor\b = '\'
            *Cursor + 1
            If *Cursor < *BufferEnd And *Cursor\b <> 13 Or *Cursor\b <> 10
              *Cursor + 1
            EndIf
          Else
            *Cursor + 1
          EndIf
        Wend
        *Cursor + 1 ; skip second "
        
        ; Character constant
      ElseIf *Cursor\b = 39
        *Cursor + 1
        While *Cursor < *BufferEnd And *Cursor\b <> 39
          If *Cursor\b = 13 Or *Cursor\b = 10
            Break 2 ; something is weird
          EndIf
          *Cursor + 1
        Wend
        *Cursor + 1 ; skip second '
        
        ; ':' is the end of the align expression
      ElseIf *Cursor\b = ':'
        Break
        
        ; newline
      ElseIf *Cursor\b = 13 Or *Cursor\b = 10
        Continuation = IsLineContinuation(*Buffer, *Cursor)
        If *Cursor < *BufferEnd-1 And *Cursor\b = 13 And *Cursor\b[1] = 10
          *Cursor + 2
        Else
          *Cursor + 1
        EndIf
        
        ; break only if not a continuation char
        If Continuation = #False
          Break
        EndIf
        
      Else
        *Cursor + 1
      EndIf
      
    Wend
  EndIf
  
  ; finally start scanning for structure items
  ;
  While *Cursor < *BufferEnd
    Prefix$ = ""
    
    If *Cursor\b = ';' ; comment
      While *Cursor < *BufferEnd And *Cursor\b <> 10 And *Cursor\b <> 13
        *Cursor + 1
      Wend
      
    ElseIf ValidCharacters(*Cursor\a) Or *Cursor\a = '*'
      *Start = *Cursor
      
      ; Check for Array, List, Map def
      ; Note: "List .l" is a valid structure entry, so check for this
      ;
      If *Cursor < *BufferEnd-6 And (PeekB(*Cursor+5) = ' ' Or PeekB(*Cursor+5) = 9) And CompareMemoryString(*Cursor, ToAscii("Array"), #PB_String_NoCaseAscii, 5, #PB_Ascii) = #PB_String_Equal
        *Cursor2.BYTE = *Cursor+5
        While *Cursor2 < *BufferEnd And (*Cursor2\b = ' ' Or *Cursor2\b = 9)
          *Cursor2 + 1
        Wend
        If *Cursor2 < *BufferEnd And *Cursor2\b <> '.'
          ; its a proper array def
          Prefix$ = "Array "
          *Cursor = *Cursor2 ; skip keyword and whitespace
          *Start = *Cursor
        EndIf
        
      ElseIf *Cursor < *BufferEnd-5 And (PeekB(*Cursor+4) = ' ' Or PeekB(*Cursor+4) = 9) And CompareMemoryString(*Cursor, ToAscii("List"), #PB_String_NoCaseAscii, 4, #PB_Ascii) = #PB_String_Equal
        *Cursor2.BYTE = *Cursor+4
        While *Cursor2 < *BufferEnd And (*Cursor2\b = ' ' Or *Cursor2\b = 9)
          *Cursor2 + 1
        Wend
        If *Cursor2 < *BufferEnd And *Cursor2\b <> '.'
          ; its a proper list def
          Prefix$ = "List "
          *Cursor = *Cursor2 ; skip keyword and whitespace
          *Start = *Cursor
        EndIf
        
      ElseIf *Cursor < *BufferEnd-4 And (PeekB(*Cursor+3) = ' ' Or PeekB(*Cursor+3) = 9) And CompareMemoryString(*Cursor, ToAscii("Map"), #PB_String_NoCaseAscii, 3, #PB_Ascii) = #PB_String_Equal
        *Cursor2.BYTE = *Cursor+3
        While *Cursor2 < *BufferEnd And (*Cursor2\b = ' ' Or *Cursor2\b = 9)
          *Cursor2 + 1
        Wend
        If *Cursor2 < *BufferEnd And *Cursor2\b <> '.'
          ; its a proper map def
          Prefix$ = "Map "
          *Cursor = *Cursor2 ; skip keyword and whitespace
          *Start = *Cursor
        EndIf
        
      EndIf
      
      If *Cursor\b = '*' ; yes, there can be whitespace after the *
        *Cursor + 1
        While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
          *Cursor + 1
        Wend
      EndIf
      
      ; get the name
      While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
        *Cursor + 1
      Wend
      
      If *Cursor < *BufferEnd And *Cursor\b = '$'
        *Cursor + 1
      EndIf
      
      While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
        *Cursor + 1
      Wend
      
      ; get the type
      If *Cursor < *BufferEnd And *Cursor\b = '.'
        *Cursor + 1
        While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
          *Cursor + 1
        Wend
        
        While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
          *Cursor + 1
        Wend
        
        While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
          *Cursor + 1
        Wend
        
        ; possible module prefix
        If *Cursor < *BufferEnd - 2 And *Cursor\b = ':' And *Cursor\b[1] = ':'
          *Cursor + 2
          While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
            *Cursor + 1
          Wend
          
          While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
            *Cursor + 1
          Wend
        EndIf
      EndIf
      
      ; get a possible fixed string size
      ; Could be an expression with line continuation, but this is a very unlikely scenario
      If *Cursor < *BufferEnd And *Cursor\b = '{'
        Depth = 1
        *Cursor + 1
        While *Cursor < *BufferEnd And Depth > 0
          Select *Cursor\b
            Case 10, 13, ':', ';': Break ; problem
            Case '{': Depth + 1
            Case '}': Depth - 1
            Case 39 ; ' is possible here (though unlikely)
              *Cursor + 1
              While *Cursor < *BufferEnd And *Cursor <> 39
                *Cursor + 1
              Wend
          EndSelect
          *Cursor + 1
        Wend
        
        While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
          *Cursor + 1
        Wend
      EndIf
      
      ; get a possible array, list, map content
      ; Could be an expression with line continuation, but this is a very unlikely scenario
      If *Cursor < *BufferEnd And (*Cursor\b = '[' Or *Cursor\b = '(')
        If *Cursor\b = '['
          CharOpen = '['
          CharClose = ']'
        Else
          CharOpen = '('
          CharClose = ')'
        EndIf
        
        Depth = 1
        *Cursor + 1
        While *Cursor < *BufferEnd And Depth > 0
          Select *Cursor\b
            Case 10, 13, ':', ';': Break ; problem
            Case CharOpen: Depth + 1
            Case CharClose: Depth - 1
            Case 39 ; ' is possible here (though unlikely)
              *Cursor + 1
              While *Cursor < *BufferEnd And *Cursor <> 39
                *Cursor + 1
              Wend
          EndSelect
          *Cursor + 1
        Wend
      EndIf
      
      ; finally done
      If *Cursor <= *BufferEnd
        Field$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii)
        Field$ = RemoveString(Field$, " ")  ; cut whitespace
        Field$ = RemoveString(Field$, Chr(9))
        
        Select UCase(Field$) ; filter some stuff
            
          Case "STRUCTUREUNION", "ENDSTRUCTUREUNION", "COMPILERIF", "COMPILERELSE", "COMPILERENDIF", "COMPILERSELECT", "COMPILERCASE", "COMPILERDEFAULT", "COMPILERENDSELECT", "", "*"
            ; skip to newline or : to ignore anything after compiler directives
            While *Cursor < *BufferEnd
              Select *Cursor\b
                Case 10, 13 ; we can continue parsing here
                  Break
                Case ':' ; can be module start or : separator
                  If *Cursor < *BufferEnd - 1 And *Cursor\b[1] = ':'
                    *Cursor + 2
                  Else
                    Break
                  EndIf
                Case ';' ; have to skip the line, then continue
                  While *Cursor < *BufferEnd And *Cursor\b <> 13 And *Cursor\b <> 10
                    *Cursor + 1
                  Wend
                  Break
                Case 39 ; '
                  *Cursor + 1
                  While *Cursor < *BufferEnd And *Cursor <> 39
                    *Cursor + 1
                  Wend
                Case '"'
                  *Cursor + 1
                  While *Cursor < *BufferEnd And *Cursor <> '"'
                    *Cursor + 1
                  Wend
                Case '~'
                  If (*Cursor + 1) < *BufferEnd And *Cursor\b[1] = '"'
                    *Cursor + 2
                    While *Cursor < *BufferEnd And *Cursor <> '"'
                      If *Cursor\b = '\'
                        *Cursor + 2
                      Else
                        *Cursor + 1
                      EndIf
                    Wend
                  EndIf
              EndSelect
              *Cursor + 1
            Wend
            
          Default
            ; Seems to be a valid field
            AddElement(Output())
            Output() = Prefix$ + Field$
            
        EndSelect
      EndIf
      
    Else ; anything invalid, just skip it (including newline, separators etc
      *Cursor + 1
      
    EndIf
  Wend
  
EndProcedure

; Same for Interfaces
;
Procedure ParseInterface(*Buffer, Length, List Output.s())
  *BufferEnd  = *Buffer + Length
  *Cursor.PTR = *Buffer
  
  While *Cursor < *BufferEnd
    If *Cursor\b = ';' ; comment
      While *Cursor < *BufferEnd And *Cursor\b <> 10 And *Cursor\b <> 13
        *Cursor + 1
      Wend
      
    ElseIf ValidCharacters(*Cursor\a) ; interfaces cannot have pointer type ?
      *Start = *Cursor
      
      ; get the name
      While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
        *Cursor + 1
      Wend
      
      Name$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii)
      
      If *Cursor < *BufferEnd And *Cursor\b = '$'
        *Cursor + 1
      EndIf
      
      While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
        *Cursor + 1
      Wend
      
      ; get the type
      If *Cursor < *BufferEnd And *Cursor\b = '.'
        *Cursor + 1
        While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
          *Cursor + 1
        Wend
        
        While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
          *Cursor + 1
        Wend
        
        While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
          *Cursor + 1
        Wend
        
        ; possible module prefix
        If *Cursor < *BufferEnd - 2 And *Cursor\b = ':' And *Cursor\b[1] = ':'
          *Cursor + 2
          While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
            *Cursor + 1
          Wend
          
          While *Cursor < *BufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
            *Cursor + 1
          Wend
        EndIf
      EndIf
      
      ; get the prototype
      ; Note: This could be multiline with line continuation (especially with ",")
      If *Cursor < *BufferEnd And *Cursor\b = '('
        Depth = 1
        *Cursor + 1
        
        While *Cursor < *BufferEnd And Depth > 0
          Select *Cursor\b
          
            Case ':'
              If *Cursor < (*BufferEnd - 1) And *Cursor\b[1] = ':'
                ; module prefix (e.g. in the type definition of a method argument)
                *Cursor + 1
              Else
                ; unexpected statement separator. syntax is invalid
                Break
              EndIf
              
            Case 10, 13, ';'
              ; end of line, but could be a line continuation
              If IsLineContinuation(*Buffer, *Cursor)
                ; skip comment (if any)
                While *Cursor < *BufferEnd And *Cursor\b <> 10 And *Cursor\b <> 13
                  *Cursor + 1
                Wend
                
                ; skip extra char in case of Windows newline
                If *Cursor < (*BufferEnd - 1) And *Cursor\b = 13 And *Cursor\b[1] = 10
                  *Cursor + 1
                EndIf
                
              Else
                ; unexpected
                Break
                
              EndIf
              
            Case '('
              Depth + 1
              
            Case ')'
              Depth - 1
              If Depth = 0
                Break
              EndIf
              
            Case '"' ; strings are possible as default values
              *Cursor + 1
              While *Cursor < *BufferEnd And *Cursor\b <> '"'
                *Cursor + 1
              Wend
              
            Case '~'
              If (*Cursor + 1) < *BufferEnd And *Cursor\b[1] = '"'
                *Cursor + 2
                While *Cursor < *BufferEnd And *Cursor <> '"'
                  If *Cursor\b = '\'
                    *Cursor + 2
                  Else
                    *Cursor + 1
                  EndIf
                Wend
              EndIf
              
            Case 39 ; ' is possible here too
              *Cursor + 1
              While *Cursor < *BufferEnd And *Cursor\b <> 39
                *Cursor + 1
              Wend
              
          EndSelect
          
          *Cursor + 1
        Wend
        
        If *Cursor < *BufferEnd And *Cursor\b = ')'
          *Cursor + 1
          
          ; again, filter compiler directives
          Select UCase(Name$)
              
            Case "COMPILERIF", "COMPILERELSE", "COMPILERENDIF", "COMPILERSELECT", "COMPILERCASE", "COMPILERDEFAULT", "COMPILERENDSELECT", ""
              ; ignore until : ; or newline
              While *Cursor < *BufferEnd
                Select *Cursor\b
                  Case 10, 13 ; we can continue parsing here
                    Break
                  Case ':' ; can be module start or : separator
                    If *Cursor < *BufferEnd - 1 And *Cursor\b[1] = ':'
                      *Cursor + 2
                    Else
                      Break
                    EndIf
                  Case ';' ; have to skip the line, then continue
                    While *Cursor < *BufferEnd And *Cursor\b <> 13 And *Cursor\b <> 10
                      *Cursor + 1
                    Wend
                    Break
                  Case 39 ; '
                    *Cursor + 1
                    While *Cursor < *BufferEnd And *Cursor <> 39
                      *Cursor + 1
                    Wend
                  Case '"'
                    *Cursor + 1
                    While *Cursor < *BufferEnd And *Cursor <> '"'
                      *Cursor + 1
                    Wend
                  Case '~'
                    If (*Cursor + 1) < *BufferEnd And *Cursor\b[1] = '"'
                      *Cursor + 2
                      While *Cursor < *BufferEnd And *Cursor <> '"'
                        If *Cursor\b = '\'
                          *Cursor + 2
                        Else
                          *Cursor + 1
                        EndIf
                      Wend
                    EndIf
                    
                EndSelect
                *Cursor + 1
              Wend
              
            Default
              ; done
              AddElement(Output())
              Output() = Trim(Parser_Cleanup(PeekS(*Start, *Cursor - *Start, #PB_Ascii)))
          EndSelect
          
        EndIf
      EndIf
      
    Else ; anything invalid, just skip it (including newline, separators etc
      *Cursor + 1
      
    EndIf
  Wend
  
EndProcedure

; If needed, fully resolve the type of Field$ with module prefix
; if not needed, just return Field$ as is
;
Procedure.s ResolveStructureFieldType(*Parser.ParserData, *Item.SourceItem, Field$)
  Index1 = FindString(Field$, ".")
  If Index1 = 0
    ProcedureReturn Field$
  EndIf
  
  Index2 = FindString(Field$, "(", Index1)
  If Index2 = 0: Index2 = FindString(Field$, "[", Index1): EndIf
  If Index2 = 0: Index2 = FindString(Field$, "{", Index1): EndIf
  If Index2 = 0: Index2 = Len(Field$) + 1: EndIf
  
  ; split up the line
  Prefix$ = Left(Field$, Index1)
  Type$ = Mid(Field$, Index1 + 1, Index2-Index1-1)
  Postfix$ = Mid(Field$, Index2)
  
  ; clean up the type
  Type$ = RemoveString(RemoveString(Type$, " "), Chr(9))
  
  ; resolve the type
  Type$ = ResolveStructureType(*Parser, *Item, *Item\SortedLine, Type$)
  If Type$ = ""
    ProcedureReturn Field$
  EndIf
  
  ; return the final thing
  ProcedureReturn Prefix$ + Type$ + Postfix$
EndProcedure

; Find structure/interface in an open Source
;
Procedure FindStructureInterfaceFromSource(*Source.SourceFile, Name$, ModuleName$, Type, List Output.s(), Recursion)
  Success = #False

  ; lookup in the source
  *Item.SourceItem = RadixLookupValue(*Source\Parser\Modules(UCase(ModuleName$))\Indexed[Type], Name$)
  
  ; check also the module body (if any)
  If *Item = 0 And ModuleName$ <> ""
    *Item.SourceItem = RadixLookupValue(*Source\Parser\Modules("IMPL::" + UCase(ModuleName$))\Indexed[Type], Name$)
  EndIf
  
  If *Item
    ; we need to parse the content from the actual gadget
    StartIndex = ScintillaSendMessage(*Source\EditorGadget, #SCI_POSITIONFROMLINE, *Item\SortedLine) + *Item\Position + *Item\FullLength ; FullLength includes Extends keyword
    EndIndex   = -1
    Success    = #False
    
    ; If this structure/interface extends another, get that first
    ; We do not care about the result here. If the Base is not found, its items
    ; will simply be missing
    ;
    ExtendBase$ = StringField(*Item\Content$, 1, Chr(10)) ; holds the base struct, if any
    ExtendBase$ = ResolveStructureType(@*Source\Parser, *Item, *Item\SortedLine, ExtendBase$)
    If ExtendBase$ <> ""
      FindStructureInterface(ExtendBase$, Type, Output(), Recursion + 1)
    EndIf
    
    If Type = #ITEM_Structure
      EndKeyword = #KEYWORD_EndStructure
    Else
      EndKeyword = #KEYWORD_EndInterface
    EndIf
    
    Line = *Item\SortedLine
    *EndItem.SourceItem = *Item
    While *EndItem
      If *EndItem\Type = #ITEM_Keyword And *EndItem\Keyword = EndKeyword
        EndIndex = ScintillaSendMessage(*Source\EditorGadget, #SCI_POSITIONFROMLINE, Line) + *EndItem\Position
        Break
      EndIf
      Parser_NextItem(*Source\Parser, *EndItem, Line)
    Wend
    
    If EndIndex > StartIndex
      *Buffer = AllocateMemory(EndIndex - StartIndex + 1)
      If *Buffer
        Range.SCTextRange
        Range\chrg\cpMin = StartIndex
        Range\chrg\cpMax = EndIndex
        Range\lpstrText  = *Buffer
        If ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXTRANGE, 0, @Range)
          If Type = #ITEM_Structure
            ; need to resolve the field types of structures (can be from different module)
            Protected NewList TempList.s()
            ParseStructure(*Buffer, EndIndex-StartIndex, TempList())
            ForEach TempList()
              AddElement(Output())
              Output() = ResolveStructureFieldType(@*Source\Parser, *Item, TempList())
            Next TempList()
          Else
            ParseInterface(*Buffer, EndIndex-StartIndex, Output())
          EndIf
          Success = #True
        EndIf
        FreeMemory(*Buffer)
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn Success
EndProcedure

; Find a structure or interface in all open/project sources or residents
; IF the structure/interface is inside a module, the name MUST include the module prefix!
; Returns true/false
;
; Keep a recursion count to detect infinite recursions "Test extends Test".
; We could also build a list of already seen names, but this way is simpler to catch
; this very rare case
;
Procedure FindStructureInterface(Name$, Type, List Output.s(), Recursion)
  ClearList(Output())
  
  ; Limit recursion to prevent stack overflow on "Test extends Test"
  ; More than 50 "Extends" sounds pretty insane anyway
  If Recursion > 50
    ProcedureReturn #False
  EndIf
  
  If Type <> #ITEM_Structure And Type <> #ITEM_Interface Or Name$ = ""
    ProcedureReturn #False
  EndIf
  
  If FindString(Name$, "::")
    ModuleName$ = StringField(Name$, 1, "::")
    Name$ = StringField(Name$, 2, "::")
  Else
    ModuleName$ = ""
  EndIf
  
  ; Check predefined structures (only if there is a loaded compiler)
  ; This is not needed if a module prefix is given
  If CompilerReady And ModuleName$ = ""
    
    If Type = #ITEM_Structure
      If RadixLookupValue(StructureTree, Name$)
        
        ; Request structure content
        ForceDefaultCompiler()
        CompilerWrite("STRUCTURE"+Chr(9)+Trim(Name$))
        Repeat
          Response$ = CompilerRead()
          
          If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
            Break
          Else
            AddElement(Output())
            Output() = Response$
          EndIf
        ForEver
        ProcedureReturn #True
        
      EndIf
      
    Else
      If RadixLookupValue(InterfaceTree, Name$)
        
        ; Request structure content
        ForceDefaultCompiler()
        CompilerWrite("INTERFACE"+Chr(9)+Trim(Name$))
        Repeat
          Response$ = CompilerRead()
          
          If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
            Break
          Else
            AddElement(Output())
            Output() = Response$
          EndIf
        ForEver
        ProcedureReturn #True

        
      EndIf

    EndIf
    
  EndIf
  
  
  
  ; Always check the active source first for priority
  ;
  SortParserData(@*ActiveSource\Parser, *ActiveSource)
  If FindStructureInterfaceFromSource(*ActiveSource, Name$, ModuleName$, Type, Output(), Recursion)
    ProcedureReturn #True
  EndIf
  
  
  ; check all open files that are included in autocomplete listing
  ; All files have sorted data now (as we just sorted the active source above)
  ;
  
  ; Note: this can be called inside another function which loops on FileList() too!
  ; (also for recursive searches!)
  Current = ListIndex(FileList())
  ForEach FileList()
    If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource
      If AutoCompleteAllFiles Or (AutoCompleteProject And *ActiveSource\ProjectFile And FileList()\ProjectFile)
        ; A recursive FindStructureInterface (for Extends support) could change this, so store the filelist element
        If FindStructureInterfaceFromSource(@FileList(), Name$, ModuleName$, Type, Output(), Recursion)
          SelectElement(FileList(), Current) ; important
          ProcedureReturn #True
        EndIf
      EndIf
    EndIf
  Next FileList()
  SelectElement(FileList(), Current)
  
  ; Check all project files that are not open
  ; These should have the Structure content as a Chr(10) separated list in the SourceItem
  ;
  If AutoCompleteProject And *ActiveSource\ProjectFile
    Current = ListIndex(ProjectFiles())
    ForEach ProjectFiles()
      If ProjectFiles()\Source = 0
        ; lookup in the source
        *Item.SourceItem = RadixLookupValue(ProjectFiles()\Parser\Modules(UCase(ModuleName$))\Indexed[Type], Name$)
        
        ; check also the module impl
        If *Item = 0 And ModuleName$ <> ""
          *Item.SourceItem = RadixLookupValue(ProjectFiles()\Parser\Modules("IMPL::" + UCase(ModuleName$))\Indexed[Type], Name$)
        EndIf
        
        If *Item
          ; If this structure/interface extends another, get that first
          ; We do not care about the result here. If the Base is not found, its items
          ; will simply be missing
          ;
          ExtendBase$ = StringField(*Item\Content$, 1, Chr(10)) ; holds the base struct, if any
          ExtendBase$ = ResolveStructureType(@ProjectFiles()\Parser, *Item, *Item\SortedLine, ExtendBase$)
          If ExtendBase$ <> ""
            FindStructureInterface(ExtendBase$, Type, Output(), Recursion + 1)
          EndIf
          
          If Len(*Item\Content$) > Len(ExtendBase$)+1
            Count = CountString(*Item\Content$, Chr(10))
            For i = 2 To Count+1 ; The first slot is the Extends base structure always (even if empty)
              AddElement(Output())
              Entry$ = StringField(*Item\Content$, i, Chr(10))
              If Type = #ITEM_Structure
                Output() = ResolveStructureFieldType(@ProjectFiles()\Parser, *Item, Entry$)
              Else
                Output() = Entry$
              EndIf
            Next i
          EndIf
          
          SelectElement(ProjectFiles(), Current)
          ProcedureReturn #True
        EndIf
      EndIf
    Next ProjectFiles()
    SelectElement(ProjectFiles(), Current)
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure FindStructure(Name$, List Output.s())
  ProcedureReturn FindStructureInterface(Name$, #ITEM_Structure, Output(), 0)
EndProcedure

Procedure FindInterface(Name$, List Output.s())
  ProcedureReturn FindStructureInterface(Name$, #ITEM_Interface, Output(), 0)
EndProcedure

; return "Array", "List", "Map" or "" (in this case)
Procedure.s StructureFieldKind(Entry$)
  Entry$ = Trim(ReplaceString(Entry$, Chr(9), " ")) ; do not remove yet for the List/Array/Map check
  
  ; Test also for the space, as it could be "ArraySomething.l" else
  If CompareMemoryString(@Entry$, @"Array ", #PB_String_NoCaseAscii, 6) = #PB_String_Equal
    ProcedureReturn "Array"
  ElseIf CompareMemoryString(@Entry$, @"List ", #PB_String_NoCaseAscii, 5) = #PB_String_Equal
    ProcedureReturn "List"
  ElseIf CompareMemoryString(@Entry$, @"Map ", #PB_String_NoCaseAscii, 4) = #PB_String_Equal
    ProcedureReturn "Map"
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

Procedure.s StructureFieldName(Entry$)
  Entry$ = Trim(ReplaceString(Entry$, Chr(9), " ")) ; do not remove yet for the List/Array/Map check
  
  If CompareMemoryString(@Entry$, @"Array ", #PB_String_NoCaseAscii, 6) = #PB_String_Equal
    Entry$ = Right(Entry$, Len(Entry$)-6)
  ElseIf CompareMemoryString(@Entry$, @"List ", #PB_String_NoCaseAscii, 5) = #PB_String_Equal
    Entry$ = Right(Entry$, Len(Entry$)-5)
  ElseIf CompareMemoryString(@Entry$, @"Map ", #PB_String_NoCaseAscii, 4) = #PB_String_Equal
    Entry$ = Right(Entry$, Len(Entry$)-4)
  EndIf
  
  Entry$ = RemoveString(Entry$, " ")   ; now cut whitespace
  Entry$ = RemoveString(Entry$, "*")   ; * is not present when accessing pointer structure items!
  Entry$ = StringField(Entry$, 1, "[") ; cut array stuff
  Entry$ = StringField(Entry$, 1, "(") ; cut dynamic array stuff
  Entry$ = StringField(Entry$, 1, "{") ; cut fixed string stuff
  ProcedureReturn StringField(Entry$, 1, ".")
EndProcedure

Procedure.s StructureFieldType(Entry$)
  Entry$ = RemoveString(RemoveString(Entry$, Chr(9)), " ") ; cut whitespace (messes up "List Something.l()", but we only want the type anyway)
  Entry$ = StringField(Entry$, 1, "[")                     ; cut array stuff
  Entry$ = StringField(Entry$, 1, "(")                     ; cut dynamic array stuff
  Entry$ = StringField(Entry$, 1, "{")                     ; cut fixed string stuff
  ProcedureReturn StringField(Entry$, 2, ".")
EndProcedure

Procedure.s InterfaceFieldName(Entry$)
  Entry$ = RemoveString(RemoveString(Entry$, Chr(9)), " ") ; cut whitespace
  Entry$ = StringField(Entry$, 1, "(")                     ; cut prototype
  ProcedureReturn StringField(Entry$, 1, ".")              ; cut any type info
EndProcedure

Procedure FindPrototypeInModule(Name$, ModuleName$)

  ; check all open files that are included in autocomplete listing
  ; All files have sorted data now (as we just sorted the active source above)
  
  ; Note: This function can be called inside another that loops on FileList(),
  ;   so do not use *ActiveSource to restore the position!
  Current = ListIndex(FileList())
  ForEach FileList()
    If @FileList() <> *ProjectInfo
      If AutoCompleteAllFiles Or @FileList() = *ActiveSource Or (AutoCompleteProject And *ActiveSource\ProjectFile And FileList()\ProjectFile)

        *Item.SourceItem = RadixLookupValue(FileList()\Parser\Modules(UCase(ModuleName$))\Sorted\Prototypes, Name$)
        If *Item
          ChangeCurrentElement(FileList(), *ActiveSource) ; important
          ProcedureReturn *Item
        EndIf
        
      EndIf
    EndIf
  Next FileList()
  SelectElement(FileList(), Current)
  
  
  ; Check Project files
  ;
  If AutoCompleteProject And *ActiveSource\ProjectFile
    Current = ListIndex(ProjectFiles())
    ForEach ProjectFiles()
      If ProjectFiles()\Source = 0
        ; walk all Structures in this source
        *Item.SourceItem = RadixLookupValue(ProjectFiles()\Parser\Modules(UCase(ModuleName$))\Sorted\Prototypes, Name$)
        If *Item
          ProcedureReturn *Item
        EndIf
      EndIf
    Next ProjectFiles()
    SelectElement(ProjectFiles(), Current)
  EndIf
  
EndProcedure

; Return the SourceItem that defines the given prototype. Null if not found
; Input must include a module prefix if a module should be searched
Procedure FindPrototype(Name$)
  
  If Name$ = ""
    ProcedureReturn 0
  EndIf
  
  ; Prototypes are always global scope, so we can find them easily in the sorted data
  ;
  SortParserData(@*ActiveSource\Parser, *ActiveSource)
  
  ; split module prefix
  If FindString(Name$, "::")
    ModulePrefix$ = StringField(Name$, 1, "::")
    Name$ = StringField(Name$, 2, "::")
    
    ; search module declaration and implementation (in this order)
    *ProtoItem = FindPrototypeInModule(Name$, ModulePrefix$)
    If *ProtoItem = 0
      *ProtoItem = FindPrototypeInModule(Name$, "IMPL::" + ModulePrefix$)
    EndIf
    ProcedureReturn *ProtoItem
    
  Else
    ProcedureReturn FindPrototypeInModule(Name$, "") ; search global space
  EndIf
  
EndProcedure