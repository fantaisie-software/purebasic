; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
; Functions for scanning the sourcecode and maintaining a list of source
; tokens for autocomplete, variableviewer, procedurebrowser etc
;

Global Dim FoldStartVT.l(#MaxSizeHT)
Global Dim FoldEndVT.l(#MaxSizeHT)
Global Dim FoldStartVT2.l(#MaxSizeHT)  ; indicates the last entry starting with the given char
Global Dim FoldEndVT2.l(#MaxSizeHT)

; Marks the basic keywords that have a fold status (to avoid double scanning)
; 1=fold start
; 2=fold end
Global Dim FoldKeywords.l(#NbBasicKeywords)

Global Dim ForwardMatches.l(#NbBasicKeywords, 0)
Global Dim BackwardMatches.l(#NbBasicKeywords, 0)
Global KeywordMatchesBuild = 0

Global NewList KeywordStack.l()

; --------------------------------------------------------------------

; some global parser state to keep while scanning (for simplicity)
Global Parser_Encoding
Global Parser_CurrentLine
Global *Parser_LineStart
Global *Parser_Array.ParsedLines
Global Parser_IgnoreCommentItems

; current line and line start must be remembered
Structure ParserStack
  CurrentLine.l
  *LineStart
EndStructure

Global NewList ParserStack.ParserStack()

Procedure Parser_PushState()
  AddElement(ParserStack())
  ParserStack()\CurrentLine = Parser_CurrentLine
  ParserStack()\LineStart   = *Parser_LineStart
  Parser_IgnoreCommentItems = #True ; true while the stack is pushed (lookahead mode)
EndProcedure

Procedure Parser_PopState()
  Parser_CurrentLine = ParserStack()\CurrentLine
  *Parser_LineStart  = ParserStack()\LineStart
  DeleteElement(ParserStack())
  If ListSize(ParserStack()) = 0
    Parser_IgnoreCommentItems = #False ; record fold marks and comment markers again
  EndIf
EndProcedure

; --------------------------------------------------------------------


; These are macros even though they are long, because of speed for large sources
; Used for scanning the parsed data
;
Macro Parser_FirstItem(_Parser, _Item, _Line)
  _Line = 0
  _Item = _Parser\SourceItemArray\Line[0]\First
  While _Item = 0 And _Line < _Parser\SourceItemCount-1
    _Line + 1
    _Item = _Parser\SourceItemArray\Line[_Line]\First
  Wend
EndMacro

Macro Parser_PreviousItem(_Parser, _Item, _Line)
  If _Item\Previous
    _Item = _Item\Previous
  Else
    _Item = 0
    While _Item = 0 And _Line > 0
      _Line - 1
      _Item = _Parser\SourceItemArray\Line[_Line]\Last
    Wend
  EndIf
EndMacro

Macro Parser_NextItem(_Parser, _Item, _Line)
  If _Item\Next
    _Item = _Item\Next
  Else
    _Item = 0
    While _Item = 0 And _Line < _Parser\SourceItemCount-1
      _Line + 1
      _Item = _Parser\SourceItemArray\Line[_Line]\First
    Wend
  EndIf
EndMacro

; --------------------------------------------------------------------

Procedure BuildFoldingVT()
  
  ; This needs to be done only once (it MUST be done only once)
  If KeywordMatchesBuild = 0
    KeywordMatchesBuild = 1
    
    ; calculate the matches for every keyword, and the max match
    MaxForward = 0
    MaxBackward = 0
    
    Restore KeywordMatches
    Repeat
      Read.l Keyword
      Read.l Match
      
      If Keyword <> 0
        ForwardMatches(Keyword, 0) + 1
        BackwardMatches(Match, 0) + 1
        
        If ForwardMatches(Keyword, 0) > MaxForward
          MaxForward = ForwardMatches(Keyword, 0)
        EndIf
        If BackwardMatches(Match, 0) > MaxBackward
          MaxBackward = BackwardMatches(Match, 0)
        EndIf
      EndIf
    Until Keyword = 0
    
    ; redim arrays (and reset all counts to 0)
    Dim ForwardMatches(#NbBasicKeywords, MaxForward)
    Dim BackwardMatches(#NbBasicKeywords, MaxBackward)
    
    ; now fill arrays
    Restore KeywordMatches
    Repeat
      Read.l Keyword
      Read.l Match
      
      If Keyword <> 0
        ForwardMatches(Keyword, 0) + 1
        ForwardMatches(Keyword, ForwardMatches(Keyword, 0)) = Match
        
        BackwardMatches(Match, 0) + 1
        BackwardMatches(Match, BackwardMatches(Match, 0)) = Keyword
      EndIf
    Until Keyword = 0
  EndIf
  
  
  IsMacroFolding = 0
  
  For i = 0 To 255
    FoldStartVT(i) = 0
    FoldEndVT(i) = 0
  Next i
  
  For i = 1 To #NbBasicKeywords
    FoldKeywords(i) = 0
  Next i
  
  SortArray(FoldStart$(), 2, 1, NbFoldStartWords)
  
  k = 0
  For i = 1 To NbFoldStartWords
    If k <> Asc(LCase(Left(FoldStart$(i), 1)))
      FoldStartVT2(k) = i-1
      FoldStartVT2(Asc(UCase(Chr(k)))) = i-1
      k = Asc(LCase(Left(FoldStart$(i), 1)))
      FoldStartVT(k) = i
      FoldStartVT(Asc(UCase(Chr(k)))) = i
    EndIf
    
    index = IsBasicKeyword(FoldStart$(i))
    If index
      FoldKeywords(index) = 1
    EndIf
  Next i
  FoldStartVT2(k) = NbFoldStartWords
  FoldStartVT2(Asc(UCase(Chr(k)))) = NbFoldStartWords
  
  SortArray(FoldEnd$(), 2, 1, NbFoldEndWords)
  
  k = 0
  For i = 1 To NbFoldEndWords
    If UCase(FoldEnd$(i)) = "ENDMACRO"
      IsMacroFolding = 1 ; special case!
    EndIf
    
    If k <> Asc(LCase(Left(FoldEnd$(i), 1)))
      FoldEndVT2(k) = i-1
      FoldEndVT2(Asc(UCase(Chr(k)))) = i-1
      k = Asc(LCase(Left(FoldEnd$(i), 1)))
      FoldEndVT(k) = i
      FoldEndVT(Asc(UCase(Chr(k)))) = i
    EndIf
    
    index = IsBasicKeyword(FoldEnd$(i))
    If index
      FoldKeywords(index) = 2
    EndIf
  Next i
  FoldEndVT2(k) = NbFoldEndWords
  FoldEndVT2(Asc(UCase(Chr(k)))) = NbFoldEndWords
  
EndProcedure



; frees a linkedlist of *SourceItem structures
Procedure FreeSourceItems(*Item.SourceItem)
  While *Item
    
    ; DEBUGGING ONLY -- very slow!
    ; ------------------------------------------
    ;     found = 0
    ;     ForEach SourceItemHeap()
    ;       If @SourceItemHeap() = *Item
    ;         found = 1
    ;         Break
    ;       EndIf
    ;     Next
    ;     If found = 0
    ;       Debug "Trying to free a SourceItem that does not exist!!"
    ;       CallDebugger
    ;     EndIf
    ; ------------------------------------------
    
    ChangeCurrentElement(SourceItemHeap(), *Item)
    *Item = *Item\Next
    DeleteElement(SourceItemHeap()) ; frees all contained strings...
  Wend
EndProcedure

; frees an entire source items array, including contained lists
Procedure FreeSourceItemArray(*Parser.ParserData)
  ; protect against 0-var for the first call
  If *Parser\SourceItemArray
    For i = 0 To *Parser\SourceItemCount-1
      FreeSourceItems(*Parser\SourceItemArray\Line[i]\First)
    Next i
    FreeMemory(*Parser\SourceItemArray)
    *Parser\SourceItemArray = 0
  EndIf
  
  ForEach *Parser\Modules()
    For i = 0 To #ITEM_LastSorted
      RadixFree(*Parser\Modules()\Indexed[i])
    Next i
  Next *Parser\Modules()
  ClearMap(*Parser\Modules())
  
  ; Sorted data no longer valid
  *Parser\SortedValid = #False
EndProcedure


; creates and links a new sourceitem structure at the end of the current line
; returns the allocated structure space
Procedure AddSourceItem(Type, Line, Position, Length)
  *Item.SourceItem = 0
  
  If AddElement(SourceItemHeap())
    *Item = @SourceItemHeap()
    *Item\Type     = Type
    *Item\Position = Position
    *Item\Length   = Length
    
    If *Parser_Array\Line[Line]\Last = 0
      *Parser_Array\Line[Line]\First = *Item
      *Parser_Array\Line[Line]\Last  = *Item
    Else
      *Item\Previous = *Parser_Array\Line[Line]\Last
      *Parser_Array\Line[Line]\Last\Next = *Item
      *Parser_Array\Line[Line]\Last = *Item
    EndIf
  EndIf
  
  ProcedureReturn *Item
EndProcedure

; compare the 2 sourceitem lists and returns true if they have equal content
; also handles null pointers correctly
Procedure CompareSourceItems(*Item1.SourceItem, *Item2.SourceItem)
  
  ; Compare as long as both items are nonzero
  ;
  While *Item1 And *Item2
    If *Item1\Type <> *Item2\Type Or *Item1\Position <> *Item2\Position Or *Item1\NumericData <> *Item2\NumericData Or *Item1\Name$ <> *Item2\Name$ Or *Item1\StringData$ <> *Item2\StringData$ Or *Item1\ModulePrefix$ <> *Item2\ModulePrefix$
      ProcedureReturn #False
    EndIf
    
    *Item1 = *Item1\Next
    *Item2 = *Item2\Next
  Wend
  
  ; One of the two is 0 here. If the other is not 0 as well,
  ; the lists are different
  ;
  If *Item1 = *Item2
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; returns true if *Pointer is the end of a line with continuation
; *Pointer must either be at a newline or at a ';' comment start
; *Buffer is the start of the buffer (or line)
;
; NOTE: also used outside of Parser, so don't use global parser state!
Procedure IsLineContinuation(*Buffer, *Pointer.PTR)
  
  ; Tokens that cause line continuation:
  ; ',' '|' '+' And Or Xor
  
  ; move away from the newline or comment mark
  *LineEnd = *Pointer
  *Pointer - 1
  
  ; skip whitespace
  While *Pointer > *Buffer And (*Pointer\a = ' ' Or *Pointer\a = 9)
    *Pointer - 1
  Wend
  
  ; if a valid word character, skip to start of word
  If ValidCharacters(*Pointer\a)
    While *Pointer > *Buffer And ValidCharacters(*Pointer\a)
      *Pointer - 1
    Wend
    ; move back to first word char
    If ValidCharacters(*Pointer\a) = 0
      *Pointer + 1
    EndIf
  EndIf
  
  ; check the found token
  If *Pointer >= *Buffer
    
    If *Pointer\a = ',' Or *Pointer\a = '|' Or *Pointer\a = '+'
      ProcedureReturn #True
      
    ElseIf *LineEnd-*Pointer >= 2 And ValidCharacters(*Pointer\a[2]) = 0
      ProcedureReturn Bool(CompareMemoryString(*Pointer, ToAscii("Or"), #PB_String_NoCaseAscii, 2, #PB_Ascii) = #PB_String_Equal)
      
    ElseIf *LineEnd-*Pointer >= 3 And ValidCharacters(*Pointer\a[3]) = 0
      ProcedureReturn Bool(CompareMemoryString(*Pointer, ToAscii("And"), #PB_String_NoCaseAscii, 3, #PB_Ascii) = #PB_String_Equal Or
                           CompareMemoryString(*Pointer, ToAscii("Xor"), #PB_String_NoCaseAscii, 3, #PB_Ascii) = #PB_String_Equal)
      
    EndIf
  EndIf
  
  ProcedureReturn #False ; no line continuation
EndProcedure

; returns true if *LineStart is the start of a line with continuation at the end
; *BufferEnd is the end of the allocated buffer
;
; NOTE: also used outside of Parser, so don't use global parser state!
Procedure IsContinuedLineStart(Line$)
  
  *LineStart.Character = @Line$
  *BufferEnd = *LineStart + Len(Line$) * #CharSize
  
  *Pointer.Character = *LineStart
  FoundChar = #False
  
  ; skip the line to a comment star or line end
  While *Pointer < *BufferEnd
    
    ; detect inline ASM/JS lines
    If FoundChar = #False
      If *Pointer\c = '!'
        ; its inline code
        ProcedureReturn #False
      ElseIf *Pointer\c <> ' ' And *Pointer\c <> 9
        ; non-whitespace means it cannot be inline code
        FoundChar = #True
      EndIf
    EndIf
    
    If *Pointer\c = '"' ; string
      *Pointer + #CharSize
      While *Pointer < *BufferEnd And *Pointer\c <> '"'
        If *Pointer\c = 13 Or *Pointer\c = 10
          ProcedureReturn #False ; something is weird
        EndIf
        *Pointer + #CharSize
      Wend
      *Pointer + #CharSize ; skip second "
      
    ElseIf *Pointer\c = 39 ; "'" char const
      *Pointer + #CharSize
      While *Pointer < *BufferEnd And *Pointer\c <> 39
        If *Pointer\c = 13 Or *Pointer\c = 10
          ProcedureReturn #False ; something is weird
        EndIf
        *Pointer + #CharSize
      Wend
      *Pointer + #CharSize ; skip second "
      
    ElseIf *Pointer\c = '~' And PeekC(*Pointer + #CharSize) = '"' ; escaped string
      *Pointer + (2 * #CharSize)
      While *Pointer < *BufferEnd And *Pointer\c <> '"'
        If *Pointer\c = 13 Or *Pointer\c = 10
          ProcedureReturn #False ; something is weird
        ElseIf *Pointer\c = '\'
          *Pointer + #CharSize   ; escape sequence
          If *Pointer < *BufferEnd And *Pointer\c <> 13 And *Pointer\c <> 10
            *Pointer + #CharSize
          EndIf
        Else
          *Pointer + #CharSize
        EndIf
      Wend
      *Pointer + #CharSize ; skip second "
      
    ElseIf *Pointer\c = 10 Or *Pointer\c = 13 Or *Pointer\c = ';' Or *Pointer\c = 0 ; line end or comment or buffer end
      Break
      
    Else
      *Pointer + #CharSize
      
    EndIf
  Wend
  
  CompilerIf #PB_Compiler_Unicode
    
    ; IsLineContinuation() needs ascii input
    ;
    *String = Ascii(PeekS(*LineStart, (*Pointer - *LineStart) / #CharSize))
    Result = IsLineContinuation(*String, *String + (*Pointer - *LineStart) / #CharSize)
    FreeMemory(*String)
    ProcedureReturn Result
    
  CompilerElse
    
    ; test for line continuation
    ProcedureReturn IsLineContinuation(*LineStart, *Pointer)
  CompilerEndIf
EndProcedure

; Some helpers for scanning a buffer
; Note: *pCursor is a pointer to the *Cursor from ScanBuffer
;
Macro Parser_SkipSpace(_Cursor)
  While _Cursor\b = ' ' Or _Cursor\b = 9
    _Cursor + 1
  Wend
EndMacro

Macro Parser_SkipString(_Cursor)
  _Cursor + 1
  While _Cursor\b And _Cursor\b <> '"' And _Cursor\b <> 13 And _Cursor\b <> 10
    _Cursor + 1
  Wend
  If _Cursor\b = '"'
    _Cursor + 1
  EndIf
EndMacro

Macro Parser_SkipEscapeString(_Cursor)
  _Cursor + 2 ; skip ~"
  While _Cursor\b And _Cursor\b <> '"' And _Cursor\b <> 13 And _Cursor\b <> 10
    If _Cursor\b = '\'
      _Cursor + 1
      If _Cursor\b And _Cursor\b <> 13 And _Cursor\b <> 10
        _Cursor + 1
      EndIf
    Else
      _Cursor + 1
    EndIf
  Wend
  If _Cursor\b = '"'
    _Cursor + 1
  EndIf
EndMacro

Macro Parser_SkipCharConst(_Cursor)
  _Cursor + 1
  While _Cursor\b And _Cursor\b <> 39 And _Cursor\b <> 13 And _Cursor\b <> 10
    _Cursor + 1
  Wend
  If _Cursor\b = 39
    _Cursor + 1
  EndIf
EndMacro

; Skip newline and update CurrentLine count/line start pointer
Macro Parser_Newline(_Cursor)
  If _Cursor\b = 13 And _Cursor\b[1] = 10
    _Cursor + 2
  Else
    _Cursor + 1
  EndIf
  Parser_CurrentLine + 1
  *Parser_LineStart = _Cursor
EndMacro

; process comment (and newline)
; use NoItems to suppress fold marks and comment markers
Procedure Parser_Comment(*pCursor.PTR)
  Static NewList FoundIssues.FoundIssue() ; static to avoid constant alloc/free
  
  *Cursor.PTR = *pCursor\p ; We could use *pCursor\p\b, but this way should be faster
  
  ; Check folding keywords. A Fold can start with a ;
  ;
  If EnableFolding And Parser_IgnoreCommentItems = #False
    If FoldStartVT(*Cursor\a)
      For i = FoldStartVT(*Cursor\a) To FoldStartVT2(*Cursor\a)
        length = Len(FoldStart$(i))
        If CompareMemoryString(*Cursor, ToAscii(FoldStart$(i)), 1, length, #PB_Ascii) = 0 And ValidCharacters(PeekA(*Cursor + length)) = 0
          AddSourceItem(#ITEM_FoldStart, Parser_CurrentLine, -1, -1)
          Break
        EndIf
      Next i
    EndIf
    
    If FoldEndVT(*Cursor\a)
      For i = FoldEndVT(*Cursor\a) To FoldEndVT2(*Cursor\a)
        length = Len(FoldEnd$(i))
        If CompareMemoryString(*Cursor, ToAscii(FoldEnd$(i)), 1, length, #PB_Ascii) = 0 And ValidCharacters(PeekA(*Cursor + length)) = 0
          AddSourceItem(#ITEM_FoldEnd, Parser_CurrentLine, -1, -1)
          Break
        EndIf
      Next i
    EndIf
  EndIf
  
  *Cursor + 1 ; skip comment start
  
  If *Cursor\b = '-' And Parser_IgnoreCommentItems = #False ; marker detected
    *Cursor + 1
    *Start = *Cursor
    While *Cursor\b And *Cursor\b <> 10 And *Cursor\b <> 13
      *Cursor + 1
    Wend
    
    *Item.SourceItem = AddSourceItem(#ITEM_CommentMark, Parser_CurrentLine, -1, -1)
    
    If *Start < *Cursor
      If Parser_Encoding = 1 ; utf8
        *Item\Name$ = Trim(PeekS(*Start, *Cursor - *Start, #PB_UTF8|#PB_ByteLength))
      Else
        *Item\Name$ = Trim(PeekS(*Start, *Cursor - *Start, #PB_Ascii))
      EndIf
    Else
      *Item\Name$ = ""
    EndIf
    
    
  Else
    ; skip to line end
    *Start = *Cursor
    While *Cursor\b And *Cursor\b <> 10 And *Cursor\b <> 13
      *Cursor + 1
    Wend
    
    ; check issues
    If *Start < *Cursor And Parser_IgnoreCommentItems = #False
      If Parser_Encoding = 1 ; utf8
        Comment$ = PeekS(*Start, *Cursor - *Start, #PB_UTF8|#PB_ByteLength)
      Else
        Comment$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii)
      EndIf
      
      If Trim(Comment$) <> ""
        ScanCommentIssues(Comment$, FoundIssues(), #False) ; source parser mode
        ForEach FoundIssues()
          *Item.SourceItem = AddSourceItem(#ITEM_Issue, Parser_CurrentLine, -1, -1)
          *Item\Name$ = FoundIssues()\Text$
          *Item\Issue = FoundIssues()\Issue
        Next FoundIssues()
      EndIf
    EndIf
    
  EndIf
  
  ; process/skip newline
  Parser_Newline(*Cursor)
  
  *pCursor\p = *Cursor
EndProcedure

; Generic routine to skip a braced expression
; Returns true if successful, false if brace mismatch
;
Procedure Parser_SkipBraces(*pCursor.PTR, StartBrace, EndBrace)
  *Cursor.PTR = *pCursor\p
  Result = #True
  
  If *Cursor\b = StartBrace
    *Cursor + 1
    depth   = 1  ; number of ')'s needed to close prototype
    
    Repeat
      Select *Cursor\b
          
        Case 0 ; end of data
          Result = #False
          Break
          
        Case 13, 10 ; newline
          If IsLineContinuation(*Parser_LineStart, *Cursor)
            Parser_Newline(*Cursor)
          Else
            Result = #False
            Break
          EndIf
          
        Case StartBrace
          depth + 1
          
        Case EndBrace
          depth - 1
          If depth = 0
            Break
          EndIf
          
        Case ';'
          If IsLineContinuation(*Parser_LineStart, *Cursor)
            Parser_Comment(@*Cursor)
          Else
            ; incorrect code, as ) is missing
            Result = #False
            Break
          EndIf
          
        Case '"' ; strings are possible as default values
          *Cursor + 1
          While *Cursor\b And *Cursor\b <> '"' And *Cursor\b <> 13 And *Cursor\b <> 10
            *Cursor + 1
          Wend
          If *Cursor\b <> '"'
            Result = #False
            Break
          EndIf
          
        Case '~'
          If PeekB(*Cursor + 1) = '"' ; escaped string
            *Cursor + 2
            While *Cursor\b And *Cursor\b <> '"' And *Cursor\b <> 13 And *Cursor\b <> 10
              If *Cursor\b = '\'
                *Cursor + 1
                If *Cursor\b And *Cursor\b <> 13 And *Cursor\b <> 10
                  *Cursor + 1
                EndIf
              Else
                *Cursor + 1
              EndIf
            Wend
            If *Cursor\b <> '"'
              Result = #False
              Break
            EndIf
          EndIf
          
        Case 39 ; '
          *Cursor + 1
          While *Cursor\b And *Cursor\b <> 39 And *Cursor\b <> 13 And *Cursor\b <> 10
            *Cursor + 1
          Wend
          If *Cursor\b <> 39
            Result = #False
            Break
          EndIf
          
      EndSelect
      
      *Cursor + 1
    ForEver
    
    If *Cursor\b = EndBrace
      *Cursor + 1
    EndIf
  EndIf
  
  *pCursor\p = *Cursor
  ProcedureReturn Result
EndProcedure

Procedure Parser_SkipType(*pCursor.PTR)
  *Cursor.PTR = *pCursor\p ; We could use *pCursor\p\b, but this way should be faster
  
  Parser_SkipSpace(*Cursor)
  
  If *Cursor\a = '.'
    *Cursor + 1
    Parser_SkipSpace(*Cursor)
    
    While ValidCharacters(*Cursor\a) ; skip type
      *Cursor + 1
    Wend
    
    Parser_SkipSpace(*Cursor)
    
    ; type with module prefix
    ; this is rare but possible for example with macros
    If *Cursor\a = ':' And *Cursor\a[1] = ':'
      *Cursor + 2
      Parser_SkipSpace(*Cursor)
      
      While ValidCharacters(*Cursor\a) ; skip actual type
        *Cursor + 1
      Wend
      
      Parser_SkipSpace(*Cursor)
    EndIf
  EndIf
  
  ; check this even without a ".", as it could be "Var${10}"
  ; note that the constant expression may be multiline, so use the generic routine
  If *Cursor\a = '{'
    Parser_SkipBraces(@*Cursor, '{', '}')
  EndIf
  
  *pCursor\p = *Cursor
EndProcedure

; cleaned up a (possibly multiline) prototype or {} fixed string expression
Procedure.s Parser_Cleanup(Input$)
  
  ; step one:
  ; - replace entire comments (from line continuation) by chr(1)
  ; - replace newline and tab and space (outside of string) with chr(1)
  ; - replace , (outside of string) With Chr(2)
  ; Note: after Array, List, Map one space must be preserved
  *Cursor.PTR = @Input$
  PreserveSpace = #False
  Repeat
    Select *Cursor\c
        
      Case 0
        Break
        
      Case '"'
        *Cursor + #CharSize
        While *Cursor\c And *Cursor\c <> '"' And *Cursor\c <> 13 And *Cursor\c <> 10
          *Cursor + #CharSize
        Wend
        If *Cursor\c = '"'
          *Cursor + #CharSize
        EndIf
        
      Case '~'
        If PeekC(*Cursor + #CharSize) = '"'
          *Cursor + (2 * #CharSize)
          While *Cursor\c And *Cursor\c <> '"' And *Cursor\c <> 13 And *Cursor\c <> 10
            If *Cursor\c = '\'
              *Cursor + #CharSize
              If *Cursor\c And *Cursor\c <> 13 And *Cursor\c <> 10
                *Cursor + 1
              EndIf
            Else
              *Cursor + #CharSize
            EndIf
          Wend
          If *Cursor\c = '"'
            *Cursor + #CharSize
          EndIf
        Else
          *Cursor + #CharSize
        EndIf
        
      Case 39
        *Cursor + #CharSize
        While *Cursor\c And *Cursor\c <> 39 And *Cursor\c <> 13 And *Cursor\c <> 10
          *Cursor + #CharSize
        Wend
        If *Cursor\c = 39
          *Cursor + #CharSize
        EndIf
        
      Case ';'
        If PreserveSpace
          *Cursor\c = ' '
          *Cursor + #CharSize
          PreserveSpace = #False
        EndIf
        While *Cursor\c And *Cursor\c <> 13 And *Cursor\c <> 10
          *Cursor\c = 1
          *Cursor + #CharSize
        Wend
        If *Cursor\c = 13 And *Cursor\c[1] = 10
          *Cursor\c = 1: *Cursor + #CharSize
          *Cursor\c = 1: *Cursor + #CharSize
        ElseIf *Cursor\c = 10
          *Cursor\c = 1: *Cursor + #CharSize
        EndIf
        
      Case 13, 10, 9, ' '
        If PreserveSpace
          *Cursor\c = ' '
          PreserveSpace = #False
        Else
          *Cursor\c = 1
        EndIf
        *Cursor + #CharSize
        
      Case ','
        *Cursor\c = 2
        *Cursor + #CharSize
        
      Default
        ; handle Array, List, Map
        If ValidCharacters(*Cursor\c & $FF)  ; must mask for unicode chars!
          
          If CompareMemoryString(*Cursor, @"Array", #PB_String_NoCaseAscii, 5) = #PB_String_Equal And ValidCharacters(*Cursor\c[5] & $FF) = 0
            CopyMemory(@"Array", *Cursor, 5*#CharSize) ; correct the case
            *Cursor + 5*#CharSize
            PreserveSpace = #True
          ElseIf CompareMemoryString(*Cursor, @"List", #PB_String_NoCaseAscii, 4) = #PB_String_Equal And ValidCharacters(*Cursor\c[4] & $FF) = 0
            CopyMemory(@"List", *Cursor, 4*#CharSize) ; correct the case
            *Cursor + 4*#CharSize
            PreserveSpace = #True
          ElseIf CompareMemoryString(*Cursor, @"Map", #PB_String_NoCaseAscii, 3) = #PB_String_Equal And ValidCharacters(*Cursor\c[3] & $FF) = 0
            CopyMemory(@"Map", *Cursor, 3*#CharSize) ; correct the case
            *Cursor + 3*#CharSize
            PreserveSpace = #True
          Else
            ; skip entire word so we do not detect FooList as a list keyword
            While ValidCharacters(*Cursor\c & $FF)
              *Cursor + #CharSize
            Wend
          EndIf
          
        Else
          *Cursor + #CharSize
        EndIf
        
    EndSelect
  ForEver
  
  ; step two:
  ; - remove all stuff marked chr(1)
  ; - replace the comma (marked chr(2)) with ", " for readability
  Result$ = ReplaceString(RemoveString(Input$, Chr(1)), Chr(2), ", ")
  
  ; done
  ProcedureReturn Result$
EndProcedure

; Name$ is needed to check for a $
;
Procedure.s Parser_GetType(*pCursor.PTR, Name$)
  *Cursor.PTR = *pCursor\p ; We could use *pCursor\p\b, but this way should be faster
  
  Parser_SkipSpace(*Cursor)
  
  If Right(Name$, 1) = "$"
    If *Cursor\b = '{'
      *Start = *Cursor
      If Parser_SkipBraces(@*Cursor, '{', '}')
        Type$ = "s" + Parser_Cleanup(PeekS(*Start, *Cursor - *Start, #PB_Ascii)) ; store all types as lowercase
      EndIf
    Else
      Type$ = "s"
    EndIf
    
  ElseIf *Cursor\b = '.'
    *Cursor + 1
    
    Parser_SkipSpace(*Cursor)
    
    *Start = *Cursor
    While ValidCharacters(*Cursor\a)
      *Cursor + 1
    Wend
    
    If *Start < *Cursor
      Type$ = LCase(PeekS(*Start, *Cursor - *Start, #PB_Ascii)) ; store in lowercase
    EndIf
    
    Parser_SkipSpace(*Cursor)
    
    If *Cursor\b = '{'
      ; check for fixed string type
      *Start = *Cursor
      If Parser_SkipBraces(@*Cursor, '{', '}')
        Type$ + Parser_Cleanup(PeekS(*Start, *Cursor - *Start, #PB_Ascii))
      EndIf
      
    ElseIf *Cursor\b = ':' And *Cursor\b[1] = ':'
      ; structure name with a module prefix
      *Cursor + 2
      Parser_SkipSpace(*Cursor)
      
      *Start = *Cursor
      While ValidCharacters(*Cursor\a)
        *Cursor + 1
      Wend
      
      If *Start < *Cursor
        Type$ + "::" + LCase(PeekS(*Start, *Cursor - *Start, #PB_Ascii))
      EndIf
    EndIf
    
    
  EndIf
  
  *pCursor\p = *Cursor
  ProcedureReturn Type$
EndProcedure

; get current word (if any), including possible * and $ chars
;
Procedure.s Parser_GetWord(*pCursor.PTR)
  *Cursor.PTR = *pCursor\p ; We could use *pCursor\p\b, but this way should be faster
  
  If ValidCharacters(*Cursor\a) Or (*Cursor\a = '*' And ValidCharacters(*Cursor\a[1]))
    *Start = *Cursor
    *Cursor + 1
    
    While ValidCharacters(*Cursor\a)
      *Cursor + 1
    Wend
    
    If *Cursor\a = '$'
      *Cursor + 1
    EndIf
    
    Word$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii)
  EndIf
  
  *pCursor\p = *Cursor
  ProcedureReturn Word$
EndProcedure

; get a possible module prefix if a "::" operator is used
; if no such prefix is found, the cursor is not moved
Procedure.s Parser_ModulePrefix(*pCursor.PTR)
  *Cursor.PTR = *pCursor\p
  
  If ValidCharacters(*Cursor\a)
    Word$ = Parser_GetWord(@*Cursor)
    Parser_SkipSpace(*Cursor)
    
    If *Cursor\a = ':' And *Cursor\a[1] = ':'
      *Cursor + 2
      Parser_SkipSpace(*Cursor)
      
      ; update cursor and return module prefix
      *pCursor\p = *Cursor
      ProcedureReturn Word$
    EndIf
  EndIf
  
  ; do not update *pCursor if no module operator was found
  ProcedureReturn ""
EndProcedure

Procedure Parser_SkipPrototype(*pCursor.PTR)
  ProcedureReturn Parser_SkipBraces(*pCursor, '(', ')')
EndProcedure

Procedure.s Parser_GetPrototype(*pCursor.PTR)
  Parser_SkipSpace(*pCursor\p)
  
  If *pCursor\p\b = '('
    *Start  = *pCursor\p
    Ok = Parser_SkipPrototype(*pCursor)
    
    If Ok And *pCursor\p > *Start And PeekB(*pCursor\p - 1) = ')' ; check if there was no error in the prototype
      If Parser_Encoding = 1
        Result$ = Parser_Cleanup(PeekS(*Start, *pCursor\p - *Start, #PB_UTF8|#PB_ByteLength))
      Else
        Result$ = Parser_Cleanup(PeekS(*Start, *pCursor\p - *Start, #PB_Ascii))
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn Result$
EndProcedure

; Analyze/add an unknown word (could be a variable)
;
Procedure Parser_GetUnknownWord(*pCursor.PTR, InImport, ModulePrefix$)
  *Cursor.PTR = *pCursor\p
  Define *Item.SourceItem
  
  ; We have any word here that is not a keyword. Check if it is followed by a (, [ or ::
  ; and else register it as a possible variable.
  ; Stuff like structure items will be filtered on reading (as it requires walking the items to check for structure/endstructure
  ;
  *Start.BYTE = *Cursor
  Word$  = Parser_GetWord(@*Cursor)
  length = Len(Word$)
  
  
  ; filter numbers. Note: the .xx part of a number is handled in the '.' handler
  If IsDecNumber(*Start, length) = 0 And (*Start\b <> '*' Or IsDecNumber(*Start+1, length-1) = 0)
    Parser_SkipSpace(*Cursor)
    
    ; Check if this is actually a label (first text on the line, and followed by a ":")
    IsLabel = 0
    If *Cursor\b = ':'
      IsLabel = 1
      *BackCursor.BYTE = *Start-1
      While *BackCursor >= *Parser_LineStart
        If *BackCursor\b <> ' ' And *BackCursor\b <> 9
          IsLabel = 0
          Break
        EndIf
        *BackCursor - 1
      Wend
    EndIf
    
    If IsLabel
      *Item = AddSourceItem(#ITEM_Label, Parser_CurrentLine, *Start-*Parser_LineStart, length)
      *Item\Name$ = Word$
      *Item\IsDefinition = #True
      *Item\ModulePrefix$ = ModulePrefix$
      
    Else
      Type$ = Parser_GetType(@*Cursor, Word$)
      
      Parser_SkipSpace(*Cursor)
      
      ; something( is a function, array, list, macro.
      ; something[ can only be a structure item array
      ; Note: to filer structure fields, see the handler for the '\' char
      ;
      If *Cursor\b = '('
        ;
        ; NOTE: We must skip SizeOf/OffsetOf/Defined, as the can contain something like
        ;   StructureName\StructureField, which would be considered a variable!
        ;
        WordU$ = UCase(Word$)
        If WordU$ = "SIZEOF" Or WordU$ = "OFFSETOF" Or WordU$ = "DEFINED" Or WordU$ = "TYPEOF"
          *Cursor + 1
          While *Cursor\b And *Cursor\b <> ')' And *Cursor\b <> 13 And *Cursor\b <> 10 And *Cursor\b <> ';'
            *Cursor + 1
          Wend
          If *Cursor\b = ')'
            *Cursor + 1
          EndIf
          
        ElseIf IsBasicFunction(WordU$) = -1 And IsAPIFunction(*Start, length) = -1
          *Item = AddSourceItem(#ITEM_UnknownBraced, Parser_CurrentLine, *Start-*Parser_LineStart, length)
          *Item\ModulePrefix$ = ModulePrefix$
          *Item\Name$ = Word$
          *Item\Type$ = Type$
          *Item\Scope = #SCOPE_UNKNOWN
          
          ; Get the length of the full call/array args etc.
          ; This is actually used to properly detect Imports
          ;
          *Cursor2.BYTE = *Cursor ; do not skip the prototype with the normal cursor!
          Parser_PushState()
          
          If InImport
            ; for items in imports, keep the prototype in the "guess" field
            *Item\Type$ = Type$ + Chr(10) + Parser_GetPrototype(@*Cursor2)
          Else
            Parser_SkipPrototype(@*Cursor2)
          EndIf
          If *Cursor2 > *Cursor And PeekB(*Cursor2 - 1) = ')'
            *Item\FullLength = *Cursor2 - *Start
          EndIf
          
          Parser_PopState()
          
          
        EndIf
        
      ElseIf *Cursor\b <> '['
        *Item = AddSourceItem(#ITEM_Variable, Parser_CurrentLine, *Start-*Parser_LineStart, length)
        *Item\Name$ = Word$
        *Item\Type$ = Type$
        *Item\Scope = #SCOPE_UNKNOWN
        *Item\ModulePrefix$ = ModulePrefix$
        
      EndIf
    EndIf
  EndIf
  
  *pCursor\p = *Cursor
EndProcedure

; returns number of source items added (also adds ITEM_Keyword for the NewList etc)
; mode:
;  0 - Define, Global, Protected, Static
;  1 - Procedure arguments (handle 'Array' 'List', stop at a ')')
;  2 - Shared (handle Arrays/Lists without NewList etc)
;
Procedure Parser_GetVariables(*pCursor.PTR, DefaultType$, Scope, Mode)
  *Cursor.PTR = *pCursor\p
  Count = 0
  Define *Item.SourceItem
  
  ; One loop scans one variable def, up to the next ,
  ; Note that the content can span multiple lines
  ;
  While *Cursor\b And *Cursor\b <> ':'
    Parser_SkipSpace(*Cursor)
    
    ; check for line continuation after the last ,
    If *Cursor\b = ';'
      If IsLineContinuation(*Parser_LineStart, *Cursor)
        Parser_Comment(@*Cursor)
      Else
        Break
      EndIf
      
    ElseIf *Cursor\b = 13 Or *Cursor\b = 10
      If IsLineContinuation(*Parser_LineStart, *Cursor)
        Parser_Newline(*Cursor)
      Else
        Break
      EndIf
      
    EndIf
    
    If Mode = 1 And *Cursor\b = ')'
      ; we reached the end of the prototype (nesting is handled at the end of the loop)
      Break
    EndIf
    
    ; check for module prefix
    ModulePrefix$ = Parser_ModulePrefix(@*Cursor)
    
    ; must be one of: variable name, NewList, Dim, Array, List
    *Start = *Cursor
    ItemLine = Parser_CurrentLine
    ItemPosition = *Start - *Parser_LineStart
    Word$  = Parser_GetWord(@*Cursor)
    If Word$
      Keyword = IsBasicKeyword(Word$)
      
      If Keyword
        *Item = AddSourceItem(#ITEM_Keyword, Parser_CurrentLine, *Start-*Parser_LineStart, Len(Word$))
        *Item\Keyword = Keyword
      EndIf
      
      ; Note: The syntax "Global NewList struct\item()" is not allowed and makes no sense,
      ;   so if we find a NewList, Dim, NewMap here, it is really an array/list/map token we found
      ;
      If Keyword = #KEYWORD_NewList Or Keyword = #KEYWORD_Dim Or Keyword = #KEYWORD_NewMap Or (Mode = 1 And (Keyword = #KEYWORD_Array Or Keyword = #KEYWORD_List Or Keyword = #KEYWORD_Map))
        Parser_SkipSpace(*Cursor)
        *Start = *Cursor
        Word$ = Parser_GetWord(@*Cursor)
        
        If Word$
          Type$ = Parser_GetType(@*Cursor, Word$)
          If Type$ = ""
            Type$ = DefaultType$
          EndIf
          
          If Keyword = #KEYWORD_NewList Or Keyword = #KEYWORD_List
            *Item = AddSourceItem(#ITEM_LinkedList, ItemLine, ItemPosition, Len(Word$))
          ElseIf Keyword = #KEYWORD_Dim Or Keyword = #KEYWORD_Array
            *Item = AddSourceItem(#ITEM_Array, ItemLine, ItemPosition, Len(Word$))
          Else
            *Item = AddSourceItem(#ITEM_Map, ItemLine, ItemPosition, Len(Word$))
          EndIf
          *Item\Name$ = Word$
          *Item\Type$ = Type$
          *Item\Scope = Scope
          *Item\ModulePrefix$ = ModulePrefix$
          Count + 1
        EndIf
        
      Else ; normal variable
        Type$ = Parser_GetType(@*Cursor, Word$)
        If Type$ = ""
          Type$ = DefaultType$
        EndIf
        
        Type = #ITEM_Variable
        If Mode = 2 ; check for Array/list/map sharing
          Parser_SkipSpace(*Cursor)
          If *Cursor\b = '('
            *Cursor + 1
            Parser_SkipSpace(*Cursor)
            If *Cursor\b = ')'
              *Cursor + 1
              Type = #ITEM_UnknownBraced ; here we have an array or list which is shared
            EndIf
          EndIf
        EndIf
        
        *Item = AddSourceItem(Type, ItemLine, ItemPosition, Len(Word$))
        *Item\Name$ = Word$
        *Item\Type$ = Type$
        *Item\Scope = Scope
        *Item\ModulePrefix$ = ModulePrefix$
        Count + 1
      EndIf
      
    EndIf
    
    ; From here on, skip everything up to the next ',', keeping ( ) and strings for initializers in mind
    ;
    nesting = 0
    Repeat
      Parser_SkipSpace(*Cursor)
      
      ; could be another module prefixed item here like in "Global x = prefix::something"
      ModulePrefix$ = Parser_ModulePrefix(@*Cursor)
      
      Select *Cursor\b
          
        Case 0, ':' ; abort cases for everything
          Break 2
          
        Case ';' ; comments
          If IsLineContinuation(*Parser_LineStart, *Cursor)
            Parser_Comment(@*Cursor)
          Else
            Break 2
          EndIf
          
        Case 13, 10 ; newline
          If IsLineContinuation(*Parser_LineStart, *Cursor)
            Parser_Newline(*Cursor)
          Else
            Break 2
          EndIf
          
        Case '(', '{', '['
          nesting + 1
          
        Case ')', '}', ']'
          If nesting = 0 And Mode = 1
            ; If we have a ), its the closing of the prototype
            ; If we have a ] or }, its a mismatched paren, so just skip it
            ;  (do Not Break the, search without moving on as that ends in an endless loop)
            If *Cursor\b = ')'
              Break 2
            EndIf
          ElseIf nesting > 0
            nesting - 1
          EndIf
          
        Case '"', 39 ; string and char const
          Stop = *Cursor\b
          *Cursor + 1
          While *Cursor\b And *Cursor\b <> Stop And *Cursor\b <> 13 And *Cursor\b <> 10
            *Cursor + 1
          Wend
          If *Cursor\b <> Stop ; unterminated literal
            Break 2
          EndIf
          
        Case '~' ; escaped string?
          If PeekB(*Cursor + 1) = '"'
            *Cursor + 2
            While *Cursor\b And *Cursor\b <> Stop And *Cursor\b <> 13 And *Cursor\b <> 10
              If *Cursor\b = '\'
                *Cursor + 1
                If *Cursor\b And *Cursor\b <> 10 And *Cursor\b <> 13
                  *Cursor + 1
                EndIf
              Else
                *Cursor + 1
              EndIf
            Wend
            If *Cursor\b <> '"' ; unterminated literal
              Break 2
            EndIf
          EndIf
          
        Case ','
          If nesting = 0
            *Cursor + 1 ; move away from it
            Break
          EndIf
          
        Case '\'
          ; Structure subfields, ignore them for variable scanning
          ; (See ScanBuffer() handler for \ for more details)
          *Cursor + 1
          Parser_SkipSpace(*Cursor)
          While ValidCharacters(*Cursor\a) ; can be no leading * here
            *Cursor + 1
          Wend
          If *Cursor\b = '$'
            *Cursor + 1
          EndIf
          Parser_SkipType(@*Cursor)
          Continue ; do not execute the "*Cursor + 1" below
          
        Case  '.'
          ; Either we have part2 of a dec number here, or a type that belongs to nothing
          *Cursor + 1
          Parser_SkipSpace(*Cursor)
          While ValidCharacters(*Cursor\a) ; can be no leading * here
            *Cursor + 1
          Wend
          If *Cursor\b = '$'
            *Cursor + 1
          EndIf
          Continue ; do not execute the "*Cursor + 1" below
          
        Case '@'
          *Cursor + 1
          Parser_SkipSpace(*Cursor)
          If ValidCharacters(*Cursor\a) Or (*Cursor\a = '*' And ValidCharacters(*Cursor\a[1]))
            Parser_GetUnknownWord(@*Cursor, 0, ModulePrefix$) ; cannot be in an import here anyway
          EndIf
          Continue ; do not execute the "*Cursor + 1" below
          
        Case '?'
          *Cursor + 1
          Parser_SkipSpace(*Cursor)
          
          *Start = *Cursor
          While ValidCharacters(*Cursor\a)
            *Cursor + 1
          Wend
          
          If *Cursor > *Start
            *Item = AddSourceItem(#ITEM_Label, Parser_CurrentLine, *Start-*Parser_LineStart, *Cursor-*Start)
            *Item\Name$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii)
            *Item\IsDefinition = #False
            *Item\ModulePrefix$ = ModulePrefix$
          EndIf
          Continue ; do not execute the "*Cursor + 1" below
          
        Case '#'
          *Start = *Cursor
          *Cursor + 1
          
          While ValidCharacters(*Cursor\a)
            *Cursor + 1
          Wend
          If *Cursor\b = '$'
            *Cursor + 1
          EndIf
          
          If *Cursor > *Start + 1
            *Item = AddSourceItem(#ITEM_Constant, Parser_CurrentLine, *Start-*Parser_LineStart, *Cursor-*Start)
            *Item\Name$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii) ; no UTF8 needed, as code can be only ascii
            *Item\ModulePrefix$ = ModulePrefix$
            *Item\IsAssignment = #False ; can only be the use of a constant
          EndIf
          Continue ; do not execute the "*Cursor + 1" below
          
        Case '$' ; hex numbers
          *Cursor + 1
          While ValidCharacters(*Cursor\a)
            *Cursor + 1
          Wend
          Continue
          
        Case '%' ; bin numbers
          *Cursor + 1
          While *Cursor\b = '1' Or *Cursor\b = '0'
            *Cursor + 1
          Wend
          Continue
          
        Default
          If ValidCharacters(*Cursor\a) Or (*Cursor\a = '*' And ValidCharacters(*Cursor\a[1]))
            Parser_GetUnknownWord(@*Cursor, 0, ModulePrefix$)
            Continue ; do not execute the "*Cursor + 1" below
          EndIf
          
      EndSelect
      *Cursor + 1
    ForEver
    
  Wend
  
  *pCursor\p = *Cursor
  ProcedureReturn Count
EndProcedure

; NOTE: *Buffer MUST be one char longer than Length and contain a NULL
;   at the end for some of the checks to work correctly!
;   Most CompareMemoryString() simply assume that the buffer is large enough still,
;   so the NULL stops the comparison correctly if not.
;
;   Returns #True if the SourceItemArray was modified (and DetectChanges is true)
;   Note: Each line's items are always deleted and re-created, but if the content
;         is still the same, this is not seen as a change.
;
;   LineOffset must be the first line in the buffer
;   LastLine must be the highest line number included in the buffer
;
Procedure ScanBuffer(*Parser.ParserData, *Buffer, Length, LineOffset, LastLine, DetectChanges)
  *Cursor.PTR = *Buffer
  *BufferEnd  = *Buffer + Length
  
  *Parser_LineStart  = *Buffer
  *Parser_Array      = *Parser\SourceItemArray
  Parser_CurrentLine = LineOffset
  Parser_Encoding    = *Parser\Encoding
  Parser_IgnoreCommentItems = #False
  ClearList(ParserStack())
  
  Define *Item.SourceItem, *ForwardCursor.PTR
  
  ; Any parsing makes the sorted data invalid (as old items get freed)
  *Parser\SortedValid = #False
  
  
  ; This check only works properly for Full-Source scans, but it is only really
  ; needed for Project parsed files (non-loaded) anyway, and they are always
  ; full scans
  InImport = 0
  
  ; Note: we must ensure that the line we scan is actually still in our array.
  ;   This problem can happen when the last line is deleted and the events
  ;   fire from the Scintilla Callback. (especially with ScanLine)
  If LastLine >= *Parser\SourceItemCount Or LineOffset < 0 Or LastLine < LineOffset
    ProcedureReturn #False
  EndIf
  
  If DetectChanges
    ; Keep the old line contents around until the end to detect changes
    *OldArray.ParsedLines = AllocateMemory((LastLine-LineOffset+1) * SizeOf(ParsedLine))
    CopyMemory(@*Parser_Array\Line[LineOffset], *OldArray, (LastLine-LineOffset+1) * SizeOf(ParsedLine))
  Else
    ; free old contents now
    For Line = LineOffset To LastLine
      FreeSourceItems(*Parser_Array\Line[Line]\First)
    Next Line
  EndIf
  
  ; zero out the part of the array we will modify
  ZeroMemory(@*Parser_Array\Line[LineOffset], (LastLine-LineOffset+1) * SizeOf(ParsedLine))
  
  While *Cursor < *BufferEnd
    ; Note: At the beginning of the loop, we are always outside of a word, so if we
    ;   find a valid word char, it is the actual start of the word
    
    ; skip any whitespace
    Parser_SkipSpace(*Cursor)
    
    ; Check for presence of a module prefix
    ModulePrefix$ = Parser_ModulePrefix(@*Cursor)
    
    ; Check for a keyword
    ;
    Keyword = 0
    k = BasicKeywordsHT(*Cursor\a)
    If k
      While k <= #NbBasicKeywords
        length  = Len(BasicKeywords(k))
        compare = CompareMemoryString(ToAscii(BasicKeywords(k)), *Cursor, 1, length, #PB_Ascii)  ; Case insensitive compare
        
        If compare = 0 And (ValidCharacters(PeekA(*Cursor + length)) = 0 Or PeekB(*Cursor + length) = '$') ; if the compare=0, then we have at least length chars left
          
          ; found a keyword here
          Keyword = k
          
          If PeekB(*Cursor + length) = '$'
            length + 1
          EndIf
          
          *Item = AddSourceItem(#ITEM_Keyword, Parser_CurrentLine, *Cursor-*Parser_LineStart, length)
          *Item\Keyword = k ; store keyword index
          
          ; For keywords that are also fold points, we have an array for a fast check
          If EnableFolding
            If FoldKeywords(Keyword) = 1
              AddSourceItem(#ITEM_FoldStart, Parser_CurrentLine, -1, -1)
            ElseIf FoldKeywords(Keyword) = 2
              AddSourceItem(#ITEM_FoldEnd, Parser_CurrentLine, -1, -1)
            EndIf
          EndIf
          
          ; skip the word
          *Cursor + length
          
          Break
          
        ElseIf compare > 0
          Break
          
        Else
          k + 1
          
        EndIf
      Wend
    EndIf
    
    ; Check folding keywords that are not PB keywords (could be macros or procedures)
    ; Don't check for ; comments, because that is done again in Parser_Comment()
    ;
    If EnableFolding And Keyword = 0 And *Cursor\b <> ';'
      If FoldStartVT(*Cursor\a)
        For i = FoldStartVT(*Cursor\a) To FoldStartVT2(*Cursor\a)
          length = Len(FoldStart$(i))
          If CompareMemoryString(*Cursor, ToAscii(FoldStart$(i)), 1, length, #PB_Ascii) = 0 And ValidCharacters(PeekA(*Cursor + length)) = 0
            AddSourceItem(#ITEM_FoldStart, Parser_CurrentLine, -1, -1)
            Break
          EndIf
        Next i
      EndIf
      
      If FoldEndVT(*Cursor\a)
        For i = FoldEndVT(*Cursor\a) To FoldEndVT2(*Cursor\a)
          length = Len(FoldEnd$(i))
          If CompareMemoryString(*Cursor, ToAscii(FoldEnd$(i)), 1, length, #PB_Ascii) = 0 And ValidCharacters(PeekA(*Cursor + length)) = 0
            AddSourceItem(#ITEM_FoldEnd, Parser_CurrentLine, -1, -1)
            Break
          EndIf
        Next i
      EndIf
    EndIf
    
    If Keyword ; we have a keyword here
      
      ; The keywords are already skipped, so no need to do that here
      ;
      Select Keyword ;- Scan Keywords
        
        ; https://www.purebasic.fr/english/viewtopic.php?t=80617
        Case #KEYWORD_CompilerIf, #KEYWORD_CompilerElseIf
            ; skip the CompilerIf to avoid adding constants referenced by it to autocomplete in modules
            While *Cursor\b And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b <> ';' And *Cursor\b <> ':'
            *Cursor + 1
            Wend
          
        Case #KEYWORD_Module, #KEYWORD_DeclareModule, #KEYWORD_UseModule, #KEYWORD_UnuseModule
          ; get the module name
          Parser_SkipSpace(*Cursor)
          *Start = *Cursor
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            Select Keyword
              Case #KEYWORD_Module       : Kind = #ITEM_Module
              Case #KEYWORD_DeclareModule: Kind = #ITEM_DeclareModule
              Case #KEYWORD_UseModule    : Kind = #ITEM_UseModule
              Case #KEYWORD_UnuseModule  : Kind = #ITEM_UnuseModule
            EndSelect
            *Item = AddSourceItem(Kind, Parser_CurrentLine, *Start-*Parser_LineStart, Len(Name$))
            *Item\Name$ = Name$
          EndIf
          
        Case #KEYWORD_EndModule
          AddSourceItem(#ITEM_EndModule, Parser_CurrentLine, -1, -1)
          
        Case #KEYWORD_EndDeclareModule
          AddSourceItem(#ITEM_EndDeclareModule, Parser_CurrentLine, -1, -1)
          
        Case #KEYWORD_Structure, #KEYWORD_Interface
          Parser_SkipSpace(*Cursor)
          *Start = *Cursor
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            If Keyword = #KEYWORD_Structure
              *Item = AddSourceItem(#ITEM_Structure, Parser_CurrentLine, *Start-*Parser_LineStart, Len(Name$))
            Else
              *Item = AddSourceItem(#ITEM_Interface, Parser_CurrentLine, *Start-*Parser_LineStart, Len(Name$))
            EndIf
            *Item\Name$ = Name$
            
            ; Default if no Extends found
            *Item\Content$ = ""
            *Item\FullLength = *Item\Length
            
            ; Look forward for an extends
            ; Use separate cursor for this, so the Extends keyword is correctly handled/detected later
            ;
            *ForwardCursor = *Cursor
            Parser_SkipSpace(*ForwardCursor)
            If UCase(Parser_GetWord(@*ForwardCursor)) = "EXTENDS"
              Parser_SkipSpace(*ForwardCursor)
              Prefix$ = Parser_ModulePrefix(@*ForwardCursor)
              If Prefix$
                Prefix$ + "::"
              EndIf
              *Item\Content$ = Prefix$ + Parser_GetWord(@*ForwardCursor)
              *Item\FullLength = *ForwardCursor-*Start
            EndIf
            
            ; Note: there is no look forward for an 'Align' in structures, because the align may be an
            ;   expression which can span multiple lines. So the *Item\FullLength never includes any
            ;   Align part. This part is handled separately when parsing structure (see StructureFunctions.pb)
          EndIf
          
        Case #KEYWORD_EndMacro
          AddSourceItem(#ITEM_MacroEnd, Parser_CurrentLine, -1, -1)
          
        Case #KEYWORD_EndProcedure
          AddSourceItem(#ITEM_ProcedureEnd, Parser_CurrentLine, -1, -1)
          
        CompilerIf #SpiderBasic ; For now, PB doesn't have EnableC, and EnableASM doesn't need this as it doesn't conflict with PB synatx
          Case #KEYWORD_EnableASM, #KEYWORD_HeaderSection
            AddSourceItem(#ITEM_InlineASM, Parser_CurrentLine, -1, -1)
            
          Case #KEYWORD_DisableASM, #KEYWORD_EndHeaderSection
            AddSourceItem(#ITEM_InlineASMEnd, Parser_CurrentLine, -1, -1)
        CompilerElse
          Case #KEYWORD_HeaderSection
            AddSourceItem(#ITEM_InlineASM, Parser_CurrentLine, -1, -1)
            
          Case #KEYWORD_EndHeaderSection
            AddSourceItem(#ITEM_InlineASMEnd, Parser_CurrentLine, -1, -1)
        CompilerEndIf
        
        Case #KEYWORD_Declare, #KEYWORD_DeclareC, #KEYWORD_DeclareCDLL, #KEYWORD_DeclareDLL, #KEYWORD_Prototype, #KEYWORD_PrototypeC
          Parser_SkipType(@*Cursor)
          Parser_SkipSpace(*Cursor)
          *Start = *Cursor
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            If Keyword = #KEYWORD_Prototype Or Keyword = #KEYWORD_PrototypeC
              *Item = AddSourceItem(#ITEM_Prototype, Parser_CurrentLine, *Start - *Parser_LineStart, Len(Name$))
            Else
              *Item = AddSourceItem(#ITEM_Declare, Parser_CurrentLine, *Start - *Parser_LineStart, Len(Name$))
            EndIf
            *Item\Name$ = Name$
            *Item\Prototype$ = Parser_GetPrototype(@*Cursor)
          EndIf
          
        Case #KEYWORD_Macro
          Parser_SkipSpace(*Cursor)
          *Start = *Cursor
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            *Item = AddSourceItem(#ITEM_Macro, Parser_CurrentLine, *Start-*Parser_LineStart, Len(Name$))
            *Item\Name$ = Name$
            *Item\Prototype$ = Parser_GetPrototype(@*Cursor)
          EndIf
          
        Case #KEYWORD_Procedure, #KEYWORD_ProcedureC, #KEYWORD_ProcedureCDLL, #KEYWORD_ProcedureDLL
          Parser_SkipType(@*Cursor)
          Parser_SkipSpace(*Cursor)
          *Start = *Cursor
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            *Item = AddSourceItem(#ITEM_Procedure, Parser_CurrentLine, *Start-*Parser_LineStart, Len(Name$))
            *Item\Name$ = Name$
            
            ; get the variable definitions, as they become local variables!
            ; use different pointer, as it will be changed
            Parser_PushState()
            *Cursor2.PTR = *Cursor
            Parser_SkipSpace(*Cursor2)
            If *Cursor2\b = '('
              *Cursor2 + 1
              Parser_GetVariables(@*Cursor2, "", #SCOPE_LOCAL, 1)
            EndIf
            Parser_PopState()
            
            ; get prototype the normal way
            *Item\Prototype$ = Parser_GetPrototype(@*Cursor)
          EndIf
          
        Case #KEYWORD_Define, #KEYWORD_Global, #KEYWORD_Protected, #KEYWORD_Static, #KEYWORD_Shared, #KEYWORD_Threaded
          ; All these definitions can have a "Define.xxx" style type now.
          ;
          If PeekB(*Cursor-1) = '$'
            Type$ = Parser_GetType(@*Cursor, "$") ; call the function still for fixed string stuff
          Else
            Type$ = Parser_GetType(@*Cursor, "")
          EndIf
          
          ; Get the variables. Take the scope type into account
          ;
          Select Keyword
            Case #KEYWORD_Define
              ItemLine = Parser_CurrentLine
              If Parser_GetVariables(@*Cursor, Type$, #SCOPE_UNKNOWN, 0) = 0
                ; no variables, so it sets the default type, we have an item for this
                *Item = AddSourceItem(#ITEM_Define, ItemLine, -1, -1)
                *Item\Type$ = Type$
              EndIf
              
            Case #KEYWORD_Global
              Parser_GetVariables(@*Cursor, Type$, #SCOPE_GLOBAL, 0)
              
            Case #KEYWORD_Protected
              Parser_GetVariables(@*Cursor, Type$, #SCOPE_LOCAL, 0)
              
            Case #KEYWORD_Static
              Parser_GetVariables(@*Cursor, Type$, #SCOPE_STATIC, 0)
              
            Case #KEYWORD_Shared
              Parser_GetVariables(@*Cursor, Type$, #SCOPE_SHARED, 2)
              
            Case #KEYWORD_Threaded
              Parser_GetVariables(@*Cursor, Type$, #SCOPE_THREADED, 0)
              
          EndSelect
          
        Case #KEYWORD_Dim, #KEYWORD_ReDim, #KEYWORD_NewList, #KEYWORD_NewMap
          Parser_SkipSpace(*Cursor)
          ModulePrefix$ = Parser_ModulePrefix(@*Cursor)
          *Start = *Cursor
          ItemLine = Parser_CurrentLine
          ItemPosition = *Start - *Parser_LineStart
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            ;
            ; Note: We can now have syntax like this:
            ;   Dim structvar\Array(10)    - structvar is a structure, not an array token
            ;   Dim structlist()\Array(10) - structlist() should be treated as unknownbraced, not array
            ;
            ; It is important to properly identify the token in this case for proper autocomplete
            ;
            Parser_PushState()
            *Cursor2.PTR = *Cursor
            Identified = #True
            Parser_SkipType(@*Cursor2)
            Parser_SkipSpace(*Cursor2)
            If *Cursor2\b = '['  ; structure subfield, must be skipped
              Identified = Parser_SkipBraces(@*Cursor2, '[', ']')
              Parser_SkipSpace(*Cursor2)
            EndIf
            If *Cursor2\b = '(' And Identified
              IsBraced = 1
              Identified = Parser_SkipBraces(@*Cursor2, '(', ')')
              Parser_SkipSpace(*Cursor2)
            Else
              IsBraced = 0
            EndIf
            
            If Identified And *Cursor2\b = '\' And IsBraced = 0
              ; Its a structure variable
              ;
              *Item = AddSourceItem(#ITEM_Variable, ItemLine, ItemPosition, Len(Name$))
              *Item\Name$ = Name$
              *Item\Type$ = Parser_GetType(@*Cursor, "") ; cannot be $, its a structure!
              *Item\Scope = #SCOPE_UNKNOWN
              *Item\ModulePrefix$ = ModulePrefix$
              
            ElseIf Identified And *Cursor2\b = '\'
              ; It is an unknown braced token, as the Dim/NewList/NewMap actually applies to
              ; the item inside the Structure, Not the outer token
              ;
              *Item = AddSourceItem(#ITEM_UnknownBraced, ItemLine, ItemPosition, Len(Name$))
              *Item\Name$ = Name$
              *Item\Type$ = Parser_GetType(@*Cursor, "") ; cannot be $, its a structure!
              *Item\Scope = #SCOPE_UNKNOWN
              *Item\ModulePrefix$ = ModulePrefix$
              If *Cursor2 > *Cursor And PeekB(*Cursor2 - 1) = ')' ; get full length
                *Item\FullLength = *Cursor2 - *Start
              EndIf
              
            Else
              ; Its a real array, list, map
              ; Also use this as fallback if the identifying failed
              ;
              If Keyword = #KEYWORD_Dim Or Keyword = #KEYWORD_ReDim
                *Item = AddSourceItem(#ITEM_Array, ItemLine, ItemPosition, Len(Name$))
              ElseIf Keyword = #KEYWORD_NewMap
                *Item = AddSourceItem(#ITEM_Map, ItemLine, ItemPosition, Len(Name$))
              Else
                *Item = AddSourceItem(#ITEM_LinkedList, ItemLine, ItemPosition, Len(Name$))
              EndIf
              *Item\Name$ = Name$
              *Item\Scope = #SCOPE_UNKNOWN
              *Item\ModulePrefix$ = ModulePrefix$
              
              If Right(Name$, 1) = "$"
                *Item\Type$ = Parser_GetType(@*Cursor, "$")
              Else
                *Item\Type$ = Parser_GetType(@*Cursor, "")
              EndIf
            EndIf
            
            Parser_PopState()
          EndIf
          
        Case #KEYWORD_Array, #KEYWORD_List, #KEYWORD_Map
          ; If we find this here (outside of a procedure prototype), its inside a structure def
          ; So it does not count as an array, map or list token. Just skip it all
          Parser_SkipSpace(*Cursor)
          Name$ = Parser_GetWord(@*Cursor)
          If Name$
            Parser_SkipType(@*Cursor)
            Parser_SkipPrototype(@*Cursor) ; skip any (...) as well
          EndIf
          
        Case #KEYWORD_Import, #KEYWORD_ImportC
          InImport = 1
          
        Case #KEYWORD_EndImport
          InImport = 0
          
        Case #KEYWORD_Enumeration, #KEYWORD_EnumerationBinary
          ; Skip a possible named enumeration name so it does not appear as a variable
          ;
          ; We could collect these in their own category and have special autocomplete for enums, but this seems a bit overkill
          ; since you only type enum names when declaring other enums, never when using enum values.
          Parser_SkipSpace(*Cursor)
          If ValidCharacters(*Cursor\a)
            Parser_GetWord(@*Cursor)
            Parser_SkipSpace(*Cursor)
            If *Cursor\a = ':' And *Cursor\a[1] = ':' ; possible enum name with module prefix
              *Cursor + 2
              Parser_SkipSpace(*Cursor)
              Parser_GetWord(@*Cursor)
            EndIf
          EndIf
          
          ; Skip a possible start value like #PB_Event_FirstCustomValue
          ; Could also be a more complex expression (even with line continuation) but that seems rather unlikely
          Parser_SkipSpace(*Cursor)
          If *Cursor\a = '#' Or ValidCharacters(*Cursor\a)
            *Cursor + 1
            Parser_GetWord(@*Cursor)
            Parser_SkipSpace(*Cursor)
            If *Cursor\a = ':' And *Cursor\a[1] = ':' ; possible enum name with module prefix
              *Cursor + 2
              Parser_SkipSpace(*Cursor)
              If *Cursor\a = '#' Or ValidCharacters(*Cursor\a)
                *Cursor + 1
                Parser_GetWord(@*Cursor)
              EndIf
            EndIf
          EndIf
          
      EndSelect
      
      ;- Scan Other
    ElseIf ValidCharacters(*Cursor\a) Or (*Cursor\a = '*' And ValidCharacters(*Cursor\a[1]))
      Parser_GetUnknownWord(@*Cursor, InImport, ModulePrefix$)
      
    ElseIf *Cursor\b = '$' ; hex numbers
      *Cursor + 1
      While ValidCharacters(*Cursor\a)
        *Cursor + 1
      Wend
      
    ElseIf *Cursor\b = '%' ; bin numbers
      *Cursor + 1
      While *Cursor\b = '1' Or *Cursor\b = '0'
        *Cursor + 1
      Wend
      
    ElseIf *Cursor\b = '@'
      *Cursor + 1
      Parser_SkipSpace(*Cursor)
      If ValidCharacters(*Cursor\a) Or (*Cursor\a = '*' And ValidCharacters(*Cursor\a[1]))
        Parser_GetUnknownWord(@*Cursor, 0, ModulePrefix$)
      EndIf
      
    ElseIf *Cursor\b = '?'
      *Cursor + 1
      Parser_SkipSpace(*Cursor)
      
      *Start = *Cursor
      While ValidCharacters(*Cursor\a)
        *Cursor + 1
      Wend
      
      If *Cursor > *Start
        *Item = AddSourceItem(#ITEM_Label, Parser_CurrentLine, *Start-*Parser_LineStart, *Cursor-*Start)
        *Item\Name$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii)
        *Item\IsDefinition = #False
        *Item\ModulePrefix$ = ModulePrefix$
      EndIf
      
    ElseIf *Cursor\b = '\'
      ; If this is encountered outside of a string, it can mean only one thing:
      ; a.structure\subfield\...
      ; So we simply ignore whatever word+type comes after this.
      ; This also catches stuff inside "Width/EndWidth", as it must begin with a \ too
      ;
      *Cursor + 1
      Parser_SkipSpace(*Cursor)
      While ValidCharacters(*Cursor\a) ; can be no leading * here
        *Cursor + 1
      Wend
      If *Cursor\b = '$'
        *Cursor + 1
      EndIf
      Parser_SkipType(@*Cursor)
      ;
      ; Following could be "[index]", also "(...)" for dynamic array, map etc, but we scan that again normally to detect any variables inside
      
    ElseIf *Cursor\b = '.'
      ; Either we have part2 of a dec number here, or a type that belongs to nothing
      ; so skip it
      *Cursor + 1
      Parser_SkipSpace(*Cursor)
      While ValidCharacters(*Cursor\a) ; can be no leading * here
        *Cursor + 1
      Wend
      If *Cursor\b = '$'
        *Cursor + 1
      EndIf
      
    ElseIf *Cursor\b = '#' ; A constant
      *Start = *Cursor
      *Cursor + 1
      
      While *Cursor < *BufferEnd And ValidCharacters(*Cursor\a)
        *Cursor + 1
      Wend
      If *Cursor < *BufferEnd And *Cursor\b = '$'
        *Cursor + 1
      EndIf
      
      If *Cursor > *Start + 1
        *Item = AddSourceItem(#ITEM_Constant, Parser_CurrentLine, *Start-*Parser_LineStart, *Cursor-*Start)
        *Item\Name$ = PeekS(*Start, *Cursor - *Start, #PB_Ascii) ; no UTF8 needed, as code can be only ascii
        *Item\ModulePrefix$ = ModulePrefix$
        
        Parser_SkipSpace(*Cursor)
        *Item\IsAssignment = Bool(*Cursor\b = '=')
      EndIf
      
    ElseIf *Cursor\b = 13 Or *Cursor\b = 10 ; NewLine
      Parser_Newline(*Cursor)
      
    ElseIf *Cursor\b = '"'  ; skip strings
      Parser_SkipString(*Cursor)
      
    ElseIf *Cursor\b = '~' And PeekB(*Cursor + 1) = '"'
      Parser_SkipEscapeString(*Cursor)
      
    ElseIf *Cursor\b = 39  ; skip character constants
      Parser_SkipCharConst(*Cursor)
      
    ElseIf *Cursor\b = '!' ; direct asm lines
      *BackCursor.BYTE = *Cursor - 1
      IsDirectAsm = 1
      While *BackCursor > *Parser_LineStart
        If *BackCursor\b <> ' ' And *BackCursor\b <> 9
          IsDirectAsm = 0 ; when there is a non-whitespace on this line, it is no direct asm
          Break
        EndIf
        *BackCursor - 1
      Wend
      
      If IsDirectAsm ; skip to lineend, or comment start (so a comment foldmark can still be detected)
        While *Cursor\b And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b <> ';'
          *Cursor + 1
        Wend
      Else
        *Cursor + 1 ; skip the ! only
      EndIf
      
    ElseIf *Cursor\b = ';' ; comments
      Parser_Comment(@*Cursor)
      
    Else
      *Cursor + 1 ; continue at next char
    EndIf
  Wend
  
  ; Check for changes and free old source entries (if requested)
  ; if not requested, old source entries were freed at the top
  ListModified = #False
  
  If DetectChanges
    For Line = LineOffset To LastLine
      *OldFirst.SourceItem = *OldArray\Line[Line-LineOffset]\First
      If CompareSourceItems(*Parser_Array\Line[Line]\First, *OldFirst) = #False
        ListModified = #True
      EndIf
      FreeSourceItems(*OldFirst)
    Next Line
    FreeMemory(*OldArray)
  EndIf
  
  ProcedureReturn ListModified
EndProcedure


Procedure FullSourceScan(*Source.SourceFile)
  If *Source\IsCode = 0
    ProcedureReturn #False
  EndIf
  
  ; free any old data
  FreeSourceItemArray(@*Source\Parser)
  
  ; this is always at least 1 as even an empty gadget has one line...
  *Source\Parser\SourceItemCount = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINECOUNT)
  *Source\Parser\SourceItemSize  = *Source\Parser\SourceItemCount+20 ; allocate for a few extra lines
  *Source\Parser\SourceItemArray = AllocateMemory(*Source\Parser\SourceItemSize * SizeOf(ParsedLine))
  
  If *Source\Parser\SourceItemArray
    Length  = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLENGTH)
    *Buffer = AllocateMemory(Length + 1) ; we need to have a NULL at the end!
    If *Buffer
      ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXT, Length+1, *Buffer) ; #SCI_GETTEXT returns length-1 bytes... very inconsistent of scintilla
      
      ; call the common scan function
      ScanBuffer(@*Source\Parser, *Buffer, Length, 0, *Source\Parser\SourceItemCount-1, #False)
      
      FreeMemory(*Buffer)
    EndIf
  EndIf
  
  ProcedureReturn #True ; this is always seen as a source modification (as we delete all old list)
EndProcedure

Procedure PartialSourceScan(*Source.SourceFile, StartLine, EndLine)
  Result = #False
  
  If *Source\Parser\SourceItemArray And *Source\IsCode
    
    ; include line continuations on the start/end line in the scan
    While StartLine > 0 And HasLineContinuation(StartLine-1, *Source)
      StartLine - 1
    Wend
    
    LineCount = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINECOUNT, 0, 0)
    While EndLine < LineCount-1 And HasLineContinuation(EndLine, *Source)
      EndLine + 1
    Wend
    
    Range.TextRange\chrg\cpMin = ScintillaSendMessage(*Source\EditorGadget, #SCI_POSITIONFROMLINE, StartLine)
    Range\chrg\cpMax           = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETLINEENDPOSITION, EndLine)
    Length = Range\chrg\cpMax - Range\chrg\cpMin
    
    If Length >= 0  ; must also act on a 0 length to scan lines that have become empty by editing!
      Range\lpstrText = AllocateMemory(Length + 1) ; for 0-byte added by Scintilla (also needed by ScanBuffer!)
      If Range\lpstrText
        Length = ScintillaSendMessage(*Source\EditorGadget, #SCI_GETTEXTRANGE, 0, @Range)
        
        ;Debug "[SCAN " + Str(StartLine) + "-" + Str(EndLine) + "] " + PeekS(Range\lpstrText, Length)
        
        ; call the common scan function
        Result = ScanBuffer(@*Source\Parser, Range\lpstrText, Length, StartLine, EndLine, #True)
        
        FreeMemory(Range\lpstrText)
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn Result
EndProcedure

; Scan single line (and surrounding line continuations)
Procedure ScanLine(*Source.SourceFile, Line)
  If *Source\IsCode
    ProcedureReturn PartialSourceScan(*Source, Line, Line)
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Procedure SourceLineCorrection(*Source.SourceFile, Line, LinesAdded)
  If *Source\Parser\SourceItemArray And *Source\IsCode
    *Array.ParsedLines = *Source\Parser\SourceItemArray
    Count              = *Source\Parser\SourceItemCount
    
    ; Any parsing makes the sorted data invalid (as old items get freed)
    *Source\Parser\SortedValid = #False
    
    If LinesAdded > 0
      LastLine = Line+LinesAdded
      
      ; need to realloc the buffer. Allocate some extra so there is no realloc for every newline
      If Count+LinesAdded > *Source\Parser\SourceItemSize
        *Array = ReAllocateMemory(*Array, (Count+LinesAdded+20) * SizeOf(ParsedLine))
        If *Array
          *Source\Parser\SourceItemSize = Count+LinesAdded+20
        EndIf
      EndIf
      
      If *Array
        MoveMemory(*Array + Line*SizeOf(ParsedLine), *Array + LastLine*SizeOf(ParsedLine), (Count-Line)*SizeOf(ParsedLine))
        
        ; need to zero out the new entries, else we get a double free later!
        For i = Line To LastLine-1
          *Array\Line[i]\First = 0
          *Array\Line[i]\Last  = 0
        Next i
        
        *Source\Parser\SourceItemArray = *Array
        *Source\Parser\SourceItemCount + LinesAdded
      EndIf
    Else
      LastLine = Line-LinesAdded ; LinesAdded is negative here, so this is right!
      
      ; free all entries of the gone lines
      For i = Line To LastLine-1
        FreeSourceItems(*Array\Line[i]\First)
        *Array\Line[i]\First = 0 ; just to be sure!
        *Array\Line[i]\Last  = 0
      Next i
      
      ; no realloc needed here
      MoveMemory(*Array + LastLine*SizeOf(ParsedLine), *Array + Line*SizeOf(ParsedLine), (Count-LastLine)*SizeOf(ParsedLine))
      
      *Source\Parser\SourceItemCount + LinesAdded
    EndIf
  EndIf
EndProcedure


Procedure Parser_AddSorted(*Tree.RadixTree, *Item.SourceItem, Line)
  
  ; This is actually only valid inside a sorted item
  *Item\SortedLine = Line
  
  RadixInsert(*Tree, *Item\Name$, *Item)
  
EndProcedure


; Update the Sorted source data for fast access
; This is done for all non-active sources
;
Procedure SortParserData(*Parser.ParserData, *Source.SourceFile=0)
  
  ; no need to do this if no scanning took place
  If *Parser\SortedValid Or (*Source And *Source\IsCode = 0)
    ProcedureReturn
  EndIf
  
  ; safety check
  If *Parser\SourceItemArray = 0
    *Parser\SortedValid = 0
    ProcedureReturn
  EndIf
  
  ; clear any old data
  ForEach *Parser\Modules()
    For i = 0 To #ITEM_LastSorted
      RadixFree(*Parser\Modules()\Indexed[i])
    Next i
  Next *Parser\Modules()
  ClearMap(*Parser\Modules())
  *CurrentModule.SortedModule = AddMapElement(*Parser\Modules(), "")
  *CurrentModule\Name$ = ""
  *Parser\MainModule = *CurrentModule
  
  *CurrentIssue.SourceItem = 0
  *Parser\SortedIssues = 0
  
  ; Now walk the code, and add items (taking scope etc into account)
  ;
  InProcedure  = 0
  InImport     = 0
  InModuleImpl = 0
  InEnumeration= 0
  Parser_FirstItem(*Parser, *Item.SourceItem, Line)
  
  ; We use some parser functions below without a proper parser state. Indicate that they should collect no items
  Parser_IgnoreCommentItems = #True
  
  While *Item
    If *Item\ModulePrefix$ = "" ; ignore prefixed items as they are accesses to other modules
      Select *Item\Type
          
        Case #ITEM_Module
          ; entered a module implementation block
          *CurrentModule = AddMapElement(*Parser\Modules(), "IMPL::" + UCase(*Item\Name$))
          *CurrentModule\Name$ = *Item\Name$
          
        Case #ITEM_DeclareModule
          ; these are collected as sorted ones for autocomplete
          ; they are also always stored in the "" module space
          Parser_AddSorted(@*Parser\MainModule\Sorted\Modules, *Item, Line)
          
          ; entered a new module declaration
          *CurrentModule = AddMapElement(*Parser\Modules(), UCase(*Item\Name$))
          *CurrentModule\Name$ = *Item\Name$
          
        Case #ITEM_EndDeclareModule, #ITEM_EndModule
          ; end of a module declaration. back to the main one
          *CurrentModule = *Parser\MainModule
          
          ; always global items
        Case #ITEM_Declare, #ITEM_Prototype, #ITEM_Label
          Parser_AddSorted(@*CurrentModule\Indexed[*Item\Type], *Item, Line)
          
        Case #ITEM_Constant
          ; only add actual assigned constants (not just uses of them) to the global list
          ; this is especially useful for modules, so constants used from other modules do not
          ; get mixed in
          If InEnumeration Or *Item\IsAssignment
            Parser_AddSorted(@*CurrentModule\Sorted\Constants, *Item, Line)
          EndIf
          
        Case #ITEM_Structure, #ITEM_Interface
          Parser_AddSorted(@*CurrentModule\Indexed[*Item\Type], *Item, Line)
          If *Item\Type = #ITEM_Structure
            EndKeyword = #KEYWORD_EndStructure
          Else
            EndKeyword = #KEYWORD_EndInterface
          EndIf
          
          ; ignore anything inside structures/interfaces (except issues!)
          While *Item\Type <> #ITEM_Keyword Or *Item\Keyword <> EndKeyword
            Parser_NextItem(*Parser, *Item, Line)
            If *Item = 0
              Break 2 ; break outer loop, as Parser_NextItem() has no 0 check!
            ElseIf *Item\Type = #ITEM_Issue
              If *Parser\SortedIssues = 0
                *Parser\SortedIssues = *Item
              Else
                *CurrentIssue\NextSorted = *Item
              EndIf
              *Item\NextSorted = 0
              *Item\SortedLine = Line
              *CurrentIssue    = *Item
            EndIf
          Wend
          
        Case #ITEM_Procedure
          Parser_AddSorted(@*CurrentModule\Sorted\Procedures, *Item, Line)
          InProcedure = 1
          
        Case #ITEM_ProcedureEnd
          InProcedure = 0
          
        Case #ITEM_Macro
          Parser_AddSorted(@*CurrentModule\Sorted\Macros, *Item, Line)
          
          ; skip to macro end as we ignore everything inside (except issues!)
          While *Item\Type <> #ITEM_MacroEnd
            Parser_NextItem(*Parser, *Item, Line)
            If *Item = 0
              Break 2 ; break outer loop
            ElseIf *Item\Type = #ITEM_Issue
              If *Parser\SortedIssues = 0
                *Parser\SortedIssues = *Item
              Else
                *CurrentIssue\NextSorted = *Item
              EndIf
              *Item\NextSorted = 0
              *Item\SortedLine = Line
              *CurrentIssue    = *Item
            EndIf
          Wend
          
          ; Imported functions are marked as #ITEM_UnknownBraced
        Case #ITEM_UnknownBraced
          If InImport
            
            ; if we have a source with it, get the prototype from there
            ; if there is no source, then its a Project file, and the parsed data already
            ; holds the correct prototype
            If *Source And *Item\FullLength > *Item\Length
              ; FullLength includes name and type, so cut that (for only the prototype)
              Line$ = GetContinuationLine(Line, @StartOffset, *Source)
              ProtoStart = StartOffset + BytesToChars(Line$, StartOffset, *Parser\Encoding, *Item\Position+*Item\Length)
              ProtoLength = BytesToChars(Line$, ProtoStart, *Parser\Encoding, *Item\FullLength-*Item\Length)
              Text$ = Mid(Line$, ProtoStart+1, ProtoLength)
              *Cursor.BYTE = ToAscii(Text$)
              *Parser_LineStart = *Cursor
              Parser_SkipType(@*Cursor)
              Parser_SkipSpace(*Cursor)
              Proto$ = Parser_Cleanup(PeekS(*Cursor, -1, #PB_Ascii))
              
              *Item\Type$ = StringField(*Item\Type$, 1, Chr(10)) + Chr(10) + Proto$
            EndIf
            
            Parser_AddSorted(@*CurrentModule\Sorted\Imports, *Item, Line)
            DefinitionEnd = *Item\Position + *Item\FullLength
            
            ; Skip all items on this line that are inside the prototype of this
            ; Import, so we skip any variables inside that prototype properly
            While *Item\Next And *Item\Next\Position < DefinitionEnd
              *Item = *Item\Next
            Wend
          EndIf
          
        Case #ITEM_Variable, #ITEM_Array, #ITEM_LinkedList, #ITEM_Map
          If *Item\Scope = #SCOPE_GLOBAL Or *Item\Scope = #SCOPE_THREADED Or *Item\Scope = #SCOPE_SHARED Or InProcedure = 0 Or InImport
            Parser_AddSorted(@*CurrentModule\Indexed[*Item\Type], *Item, Line)
          EndIf
          
        Case #ITEM_Keyword
          Select *Item\Keyword
              
            Case #KEYWORD_Import, #KEYWORD_ImportC
              InImport = 1
              
            Case #KEYWORD_EndImport
              InImport = 0
              
            Case #KEYWORD_Enumeration, #KEYWORD_EnumerationBinary
              InEnumeration = 1
              
            Case #KEYWORD_EndEnumeration
              InEnumeration = 0
              
          EndSelect
          
        Case #ITEM_Issue
          ; just collect them in a list for fast access by the issue tool
          If *Parser\SortedIssues = 0
            *Parser\SortedIssues = *Item
          Else
            *CurrentIssue\NextSorted = *Item
          EndIf
          *Item\NextSorted = 0
          *Item\SortedLine = Line
          *CurrentIssue    = *Item
          
      EndSelect
    EndIf
    
    Parser_NextItem(*Parser, *Item, Line)
  Wend
  
  ; now the data is valid
  *Parser\SortedValid = #True
EndProcedure


; Scan a file from the project for tokens
;
Procedure ScanFile(FileName$, *Parser.ParserData)
  Protected NewList *LineStarts()
  Protected NewList Items.s()
  Protected NewList *StartItems()
  
  ; Clean up old data (has a 0-check)
  FreeSourceItemArray(*Parser)
  
  ; Load and scan the file
  ;
  If ReadFile(#FILE_ScanSource, FileName$)
    Format = ReadStringFormat(#FILE_ScanSource)
    If Format = #PB_Ascii
      *Parser\Encoding = 0
    Else
      *Parser\Encoding = 1
    EndIf
    
    Size = Lof(#FILE_ScanSource)-Loc(#FILE_ScanSource)
    
    If Size > 0
      *Buffer = AllocateMemory(Size+1) ; leave space for a NULL! (required by ScanBuffer)
      If *Buffer
        ReadData(#FILE_ScanSource, *Buffer, Size)
        
        ; Do a line count and get line starts
        ;
        LineCount = 1 ; even an empty file has 1 line
        *Cursor.PTR = *Buffer
        
        AddElement(*LineStarts())
        *LineStarts() = *Cursor
        
        While *Cursor\b  ; there is a NULL anyway
          If *Cursor\b = 13 And *Cursor\b[1] = 10
            LineCount + 1
            *Cursor + 2
            AddElement(*LineStarts())
            *LineStarts() = *Cursor
            
          ElseIf *Cursor\b = 13 Or *Cursor\b = 10
            LineCount + 1
            *Cursor + 1
            AddElement(*LineStarts())
            *LineStarts() = *Cursor
            
          Else
            *Cursor + 1
          EndIf
        Wend
        
        *Parser\SourceItemCount = LineCount
        *Parser\SourceItemSize  = LineCount ; no extra as the file is not editable
        *Parser\SourceItemArray = AllocateMemory(*Parser\SourceItemSize * SizeOf(ParsedLine))
        
        If *Parser\SourceItemArray
          ; call the common scan function
          ScanBuffer(*Parser, *Buffer, Size, 0, LineCount-1, #False)
          SortParserData(*Parser, 0) ; generate the sorted parser data for quick access
          
          ; for structured autocomplete, parse all contained structures
          ; and store their content in the *Item\Content$ field for later use
          ;
          For t = 0 To 1
            If t = 0
              Type = #ITEM_Structure
              EndKeyword = #KEYWORD_EndStructure
            Else
              Type = #ITEM_Interface
              EndKeyword = #KEYWORD_EndInterface
            EndIf
            
            ForEach *Parser\Modules()
              RadixEnumerateAll(*Parser\Modules()\Indexed[Type], *StartItems())
              
              ForEach *StartItems()
                *StartItem.SourceItem = *StartItems()
                
                SelectElement(*LineStarts(), *StartItem\SortedLine)
                *StartCursor = *LineStarts() + *StartItem\Position + *StartItem\FullLength ; FullLength includes "Extends xxx"
                *EndCursor   = 0
                
                ; Cut any previously scanned content
                ; Note: the first field is reserved for "Extends" structure name
                ;
                *StartItem\Content$ = StringField(*StartItem\Content$, 1, Chr(10))
                
                ; locate the structure/interface end
                *EndItem.SourceItem = *StartItem
                Line = *StartItem\SortedLine
                While *EndItem
                  If *EndItem\Type = #ITEM_Keyword And *EndItem\Keyword = EndKeyword
                    SelectElement(*LineStarts(), Line)
                    *EndCursor = *LineStarts() + *EndItem\Position
                    Break
                  EndIf
                  Parser_NextItem(*Parser, *EndItem, Line)
                Wend
                
                If *EndCursor
                  ClearList(Items())
                  If Type = #ITEM_Structure
                    ParseStructure(*StartCursor, *EndCursor-*StartCursor, Items())
                  Else
                    ParseInterface(*StartCursor, *EndCursor-*StartCursor, Items())
                  EndIf
                  
                  ; Add our new parsed content to the start item
                  ;
                  ForEach Items()
                    *StartItem\Content$ + Chr(10) + Items()
                  Next Items()
                EndIf
              Next *StartItems()
            Next *Parser\Modules()
          Next t
        EndIf
        
        FreeMemory(*Buffer)
      EndIf
    EndIf
    
    CloseFile(#FILE_ScanSource)
  EndIf
  
EndProcedure

; Convert a char offset (0-based) to a byte offset in the specified encoding
Procedure CharsToBytes(Line$, Start, Encoding, Chars)
  If Encoding = 0
    ProcedureReturn StringByteLength(Mid(Line$, Start+1, Chars), #PB_Ascii)
  Else
    ProcedureReturn StringByteLength(Mid(Line$, Start+1, Chars), #PB_UTF8)
  EndIf
EndProcedure

; Convert a byte offset (0-based) to a char offset in the specified encoding
Procedure BytesToChars(Line$, Start, Encoding, Bytes)
  
  If Encoding = 0
    ProcedureReturn Bytes ; there is a 1-1 mapping for ascii sources
  Else
    Chars = 0
    While Bytes > 0
      c = Asc(Mid(Line$, Start+Chars+1, 1))
      If c = 0
        Break
      ElseIf c < $80
        Bytes - 1
      ElseIf c < $800
        Bytes - 2
      Else
        Bytes - 3
      EndIf
      Chars + 1
    Wend
    
    ProcedureReturn Chars
  EndIf
  
EndProcedure


; Return the SourceItem pointer for the item at the given location (if any)
Procedure LocateSourceItem(*Parser.ParserData, Line, Position)
  If *Parser\SourceItemArray And *Parser\SourceItemCount > Line And Line >= 0
    *Item.SourceItem = *Parser\SourceItemArray\Line[Line]\First
    
    While *Item
      If *Item\Position >= 0 And *Item\Position <= Position And *Item\Position + *Item\Length >= Position
        ProcedureReturn *Item
      Else
        *Item = *Item\Next
      EndIf
    Wend
  EndIf
  
  ProcedureReturn 0
EndProcedure

; Return the closest SourceItem to the given position if  (searching backward)
;
Procedure ClosestSourceItem(*Parser.ParserData, *Line.INTEGER, Position)
  If *Parser\SourceItemArray And *Parser\SourceItemCount > *Line\i And *Line\i >= 0
    *Item.SourceItem = *Parser\SourceItemArray\Line[*Line\i]\Last
    
    ; Look on the current line for items below our position
    ;
    While *Item
      If *Item\Position >= 0 And *Item\Position <= Position
        ProcedureReturn *Item
      Else
        *Item = *Item\Previous
      EndIf
    Wend
    
    ; If nothing found, return the last item on any previous line
    While *Line\i > 0
      *Line\i - 1
      If *Parser\SourceItemArray\Line[*Line\i]\Last
        ProcedureReturn *Parser\SourceItemArray\Line[*Line\i]\Last
      EndIf
    Wend
  EndIf
  
  ProcedureReturn 0 ; absolutely no sourceitems before the current location
EndProcedure


; Tries to locate the procedure start from the given Line/Item
; Return true if the item is inside a procedure, false else
Procedure FindProcedureStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER)
  *Item.SourceItem = *pItem\i
  Line = *Line\i
  
  While *Item
    Select *Item\Type
        
      Case #ITEM_Procedure ; found procedure start
        *pItem\i = *Item
        *Line\i  = Line
        ProcedureReturn #True
        
      Case #ITEM_MacroEnd ; yes, we can have a macro inside a procedure. (this is for the weird users :p)
        While *Item And *Item\Type <> #ITEM_Macro
          Parser_PreviousItem(*Parser, *Item, Line)
        Wend
        
        ; The Parser_PreviousItem() below has no 0 check, so break here!
        If *Item = 0
          Break
        EndIf
        
      Case #ITEM_Macro, #ITEM_ProcedureEnd ; inside a macro, or outside of a procedure. abort
        Break
        
    EndSelect
    Parser_PreviousItem(*Parser, *Item, Line)
  Wend
  
  *pItem\i = 0
  ProcedureReturn #False
EndProcedure

; Returns true if the given *SourceItem is in a procedure
Procedure ItemInsideProcedure(*Parser.ParserData, Line, *Item.SourceItem)
  ProcedureReturn FindProcedureStart(*Parser, @Line, @*Item)
EndProcedure


; These functions locate a matching keyword item in the parser data forward Or backward from the given line+item.
;
; Matching keywords are anything in the same group that can follow/precede the input item.
; (for example Else->EndIf, or ElseIf->Else, or Import->EndImport
;
; The following results are possible: (*pLine\i is set according to *pItem\i)
;
; Result=#True, *pItem\i <> 0
;  -> A matching item was found
; Result=#True, *pItem\i = 0
;  -> No matching item was needed (for example with a keyword like "Declare")
; Result=#False, *pItem\i <> 0
;  -> There is a mismatch, the mismatching item is returned
; Result=#False, *pItem\i = 0
;  -> There is no matching (for example For without Next)
;

Procedure MatchKeywordBackward(*Parser.ParserData, *pLine.INTEGER, *pItem.INTEGER)
  *Item.SourceItem = *pItem\i
  Line             = *pLine\i
  Keyword          = *Item\Keyword
  
  If *Item = 0 Or *Item\Type <> #ITEM_Keyword  ; VAlidate that the start is even a keyword
    *pItem\i = 0
    ProcedureReturn #True
  EndIf
  
  If BackwardMatches(Keyword, 0) = 0 ; no matches possible
    *pItem\i = 0
    ProcedureReturn #True
  EndIf
  
  ClearList(KeywordStack())
  
  Repeat
    Parser_PreviousItem(*Parser, *Item, Line)
    If *Item = 0
      *pItem\i = 0
      ProcedureReturn #False
    EndIf
    
    ; Check for keyword items
    ;
    If *Item\Type = #ITEM_Keyword
      
      ; Special check: Inside Compiler statements we ignore the keywords, as the compiler
      ; statements do not need to respect the nesting of normal commands
      ;
      ; Note: The #KEYWORD_ constants are sorted by alphabetic keyword name, so this check works
      ;
      If Keyword < #KEYWORD_CompilerCase Or Keyword > #KEYWORD_CompilerSelect Or (*Item\Keyword >= #KEYWORD_CompilerCase And *Item\Keyword <= #KEYWORD_CompilerSelect)
        
        
        ; Is this a backward match of our stack top ?
        IsMatch = 0
        For i = 1 To BackwardMatches(Keyword, 0)
          If *Item\Keyword = BackwardMatches(Keyword, i)
            IsMatch = 1
            Break
          EndIf
        Next i
        
        If IsMatch
          If ListSize(KeywordStack()) = 0
            ; empty stack, so we matched the original item
            ; (it does not matter if we have further possible matches here)
            *pItem\i = *Item
            *pLine\i = Line
            ProcedureReturn #True
            
          ElseIf BackwardMatches(*Item\Keyword, 0) > 0
            ; this keyword has further matches, so make it our current search keyword
            Keyword = *Item\Keyword
            
          Else
            ; we matched this stack level, so pop it
            Keyword = KeywordStack()
            DeleteElement(KeywordStack())
            
          EndIf
          
        ElseIf ForwardMatches(*Item\Keyword, 0) > 0
          ; if this keyword has forward matches, then we have a mismatch! (as it is a EndXXX for example)
          
          *pItem\i = *Item
          *pLine\i = Line
          ProcedureReturn #False
          
        ElseIf BackwardMatches(*Item\Keyword, 0) > 0
          ; this item has backward matches, so put it on the stack
          AddElement(KeywordStack())
          KeywordStack() = Keyword
          Keyword = *Item\Keyword
          
        EndIf ; if the found keyword has no matches at all, then we just ignore it
      EndIf
    EndIf
  ForEver
  
EndProcedure

Procedure MatchKeywordForward(*Parser.ParserData, *pLine.INTEGER, *pItem.INTEGER)
  *Item.SourceItem = *pItem\i
  Line             = *pLine\i
  Keyword          = *Item\Keyword
  
  If *Item = 0 Or *Item\Type <> #ITEM_Keyword  ; VAlidate that the start is even a keyword
    *pItem\i = 0
    ProcedureReturn #True
  EndIf
  
  If ForwardMatches(Keyword, 0) = 0 ; no forward matches possible
    *pItem\i = 0
    ProcedureReturn #True
  EndIf
  
  ClearList(KeywordStack())
  
  Repeat
    Parser_NextItem(*Parser, *Item, Line)
    If *Item = 0
      *pItem\i = 0
      ProcedureReturn #False
    EndIf
    
    ; Check for keyword items
    ;
    If *Item\Type = #ITEM_Keyword
      
      ; Special check: Inside Compiler statements we ignore the keywords, as the compiler
      ; statements do not need to respect the nesting of normal commands
      ;
      ; Note: The #KEYWORD_ constants are sorted by alphabetic keyword name, so this check works
      ;
      If Keyword < #KEYWORD_CompilerCase Or Keyword > #KEYWORD_CompilerSelect Or (*Item\Keyword >= #KEYWORD_CompilerCase And *Item\Keyword <= #KEYWORD_CompilerSelect)
        
        ; Is this a forward match of our stack top ?
        IsMatch = 0
        For i = 1 To ForwardMatches(Keyword, 0)
          If *Item\Keyword = ForwardMatches(Keyword, i)
            IsMatch = 1
            Break
          EndIf
        Next i
        
        If IsMatch
          If ListSize(KeywordStack()) = 0
            ; empty stack, so we matched the original item
            ; (it does not matter if we have further possible matches here)
            *pItem\i = *Item
            *pLine\i = Line
            ProcedureReturn #True
            
          ElseIf ForwardMatches(*Item\Keyword, 0) > 0
            ; this keyword has further matches, so make it our current search keyword
            Keyword = *Item\Keyword
            
          Else
            ; we matched this stack level, so pop it
            Keyword = KeywordStack()
            DeleteElement(KeywordStack())
            
          EndIf
          
        ElseIf BackwardMatches(*Item\Keyword, 0) > 0
          ; if this keyword has backward matches, then we have a mismatch! (as it is a EndXXX for example)
          
          *pItem\i = *Item
          *pLine\i = Line
          ProcedureReturn #False
          
        ElseIf ForwardMatches(*Item\Keyword, 0) > 0
          ; this item has forward matches, so put it on the stack
          AddElement(KeywordStack())
          KeywordStack() = Keyword
          Keyword = *Item\Keyword
          
        EndIf ; if the found keyword has no matches at all, then we just ignore it
      EndIf
    EndIf
  ForEver
  
EndProcedure

; Find the start item of the most inner loop we are in
; Returns true if item found
;
Procedure FindLoopStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER)
  *Item.SourceItem = *pItem\i
  Line             = *Line\i
  
  ; Move away from the end item if we are on it
  ;
  If *Item And *Item\Type = #ITEM_Keyword And (*Item\Keyword = #KEYWORD_Next Or *Item\Keyword = #KEYWORD_ForEver Or *Item\Keyword = #KEYWORD_Until Or*Item\Keyword = #KEYWORD_Wend)
    Parser_PreviousItem(*Parser, *Item, Line)
  EndIf
  
  Level = 1
  
  While *Item
    Select *Item\Type
        
      Case #ITEM_MacroEnd ; skip macro
        While *Item And *Item\Type <> #ITEM_Macro
          Parser_PreviousItem(*Parser, *Item, Line)
        Wend
        
        ; The Parser_PreviousItem() below has no 0 check, so break here!
        If *Item = 0
          Break
        EndIf
        
      Case #ITEM_Procedure, #ITEM_Macro, #ITEM_ProcedureEnd, #ITEM_Module, #ITEM_EndModule, #ITEM_DeclareModule, #ITEM_EndDeclareModule
        ; inside a macro, or found a procedure or module bound, so abort
        Break
        
      Case #ITEM_Keyword
        Select *Item\Keyword
            
          Case #KEYWORD_For, #KEYWORD_ForEach, #KEYWORD_Repeat, #KEYWORD_While
            Level - 1
            If Level = 0 ; This must have been our start keyword
              *pItem\i = *Item
              *Line\i  = Line
              ProcedureReturn #True
            EndIf
            
          Case #KEYWORD_Next, #KEYWORD_ForEver, #KEYWORD_Until, #KEYWORD_Wend
            Level + 1
            
        EndSelect
        
    EndSelect
    Parser_PreviousItem(*Parser, *Item, Line)
  Wend
  
  
  *pItem\i = 0
  ProcedureReturn #False
EndProcedure

; Find Break, Continue or ProcedureReturn keywords in a loop or Procedure
; *Item should reference a loop or procedure start/end keyword
; Returns number of items found
;
Procedure FindBreakKeywords(*Parser.ParserData, *Item.SourceItem, Line, List Items.SourceItemPair())
  ClearList(Items())
  
  If *Item = 0 Or *Item\Type <> #ITEM_Keyword  ; VAlidate that the start is even a keyword
    ProcedureReturn 0
  EndIf
  
  ; Find the start keyword and determine if we are looking for loops or procedures
  ;
  Select *Item\Keyword
      
    Case #KEYWORD_Procedure, #KEYWORD_ProcedureC, #KEYWORD_ProcedureCDLL, #KEYWORD_ProcedureDLL
      ProcedureMode = #True
      
    Case #KEYWORD_EndProcedure
      If FindProcedureStart(*Parser, @Line, @*Item) = #False
        ProcedureReturn 0
      EndIf
      ProcedureMode = #True
      
    Case #KEYWORD_For, #KEYWORD_ForEach, #KEYWORD_Repeat, #KEYWORD_While
      ProcedureMode = #False
      
    Case #KEYWORD_Next, #KEYWORD_ForEver, #KEYWORD_Until, #KEYWORD_Wend
      If FindLoopStart(*Parser, @Line, @*Item) = #False
        ProcedureReturn 0
      EndIf
      ProcedureMode = #False
      
    Default
      ProcedureReturn 0 ; no procedure or loop start/end keyword
      
  EndSelect
  
  ; For loop detection
  Level = 0
  
  ; Now scan forward and look for matching items
  ;
  While *Item
    Select *Item\Type
        
      Case #ITEM_Macro ; yes, we can have a macro inside a procedure. (this is for the weird users :p)
        While *Item And *Item\Type <> #ITEM_MacroEnd
          Parser_NextItem(*Parser, *Item, Line)
        Wend
        
        ; The Parser_NextItem() below has no 0 check, so break here!
        If *Item = 0
          Break
        EndIf
        
        ; we have reached the end of the procedure (or we were inside a macro)
        ; this also terminates our loop search as we can have no loops past the procedure end
      Case #ITEM_MacroEnd, #ITEM_ProcedureEnd
        Break
        
      Case #ITEM_Keyword
        Select *Item\Keyword
            
          Case #KEYWORD_For, #KEYWORD_ForEach, #KEYWORD_Repeat, #KEYWORD_While
            ; This is also executed on our start element, so we start at Level=1 (in loop mode)
            Level + 1
            
          Case #KEYWORD_Next, #KEYWORD_ForEver, #KEYWORD_Until, #KEYWORD_Wend
            Level - 1
            If Level = 0 And ProcedureMode = #False
              Break ; When we reach 0, it terminated our own loop
            EndIf
            
          Case #KEYWORD_Break, #KEYWORD_Continue
            If Level = 1 And ProcedureMode = #False
              AddElement(Items())
              Items()\Item = *Item
              Items()\Line = Line
            EndIf
            
          Case #KEYWORD_ProcedureReturn
            If ProcedureMode
              AddElement(Items())
              Items()\Item = *Item
              Items()\Line = Line
            EndIf
            
        EndSelect
        
    EndSelect
    Parser_NextItem(*Parser, *Item, Line)
  Wend
  
  ProcedureReturn ListSize(Items())
EndProcedure



; Tries to locate the start of a DeclareModule or Module block (if any)
; The search only extends to the beginning of the file
; The OpenModules() list may contain duplicates if multiple commands are found for the same module
;
; If inside a Module/DeclareModule
; - fills the OpenModules() list
; - sets *pItem and *Line to the module start item+
; - returns #true
;
; If not inside a Module/DeclareModule
; - fills the OpenModules() list with open modules since the start of the file
; - returns #false
;
; If inside a macro
; - clears the OpenModules() list
; - returns #false
;
Procedure FindModuleStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER, List OpenModules.s())
  *Item.SourceItem = *pItem\i
  Line = *Line\i
  
  Protected NewList ClosedModules.s()
  ClearList(OpenModules())
  
  While *Item
    Select *Item\Type
        
      Case #ITEM_Macro  ; the start point was inside a macro. abort
        ClearList(OpenModules())
        Break
        
      Case #ITEM_DeclareModule, #ITEM_Module
        ; found the module decl/impl start
        *pItem\i = *Item
        *Line\i = Line
        ProcedureReturn #True
        
      Case #ITEM_EndDeclareModule, #ITEM_EndModule, #ITEM_MacroEnd
        ; skip these blocks in the search
        Select *Item\Type
          Case #ITEM_EndDeclareModule: StartItem = #ITEM_DeclareModule
          Case #ITEM_EndModule       : StartItem = #ITEM_Module
          Case #ITEM_MacroEnd        : StartItem = #ITEM_Macro
        EndSelect
        
        While *Item And *Item\Type <> StartItem
          Parser_PreviousItem(*Parser, *Item, Line)
        Wend
        
        ; The Parser_PreviousItem() below has no 0 check, so break here!
        If *Item = 0
          Break
        EndIf
        
      Case #ITEM_UseModule
        Closed = #False
        ForEach ClosedModules()
          If CompareMemoryString(@*Item\Name$, PeekI(@ClosedModules()), #PB_String_NoCaseAscii) = #PB_String_Equal
            Closed = #True
            Break
          EndIf
        Next ClosedModules()
        
        If Not Closed
          AddElement(OpenModules())
          OpenModules() = *Item\Name$
        EndIf
        
      Case #ITEM_UnuseModule
        AddElement(ClosedModules())
        ClosedModules() = *Item\Name$
        
    EndSelect
    Parser_PreviousItem(*Parser, *Item, Line)
  Wend
  
  *pItem\i = 0
  ProcedureReturn #False
EndProcedure

; Find the start of the code block containing or starting with the given item
;
; A block start is any keyword that can have a forward match with
; MatchKeywordForward. This means that also a 'ElseIf' or 'Else' is considered
; a block start (the start of the ElseIf block then).
;
; If IncludeSelf is true, the result may be the initial item iself if it fits the criteria
;
; Returns true if such an item is found, false if not inside any block
;
Procedure FindBlockStart(*Parser.ParserData, *Line.INTEGER, *pItem.INTEGER, IncludeSelf)
  *Item.SourceItem = *pItem\i
  Line = *Line\i
  
  If *Item And IncludeSelf = 0
    ; move to previous
    Parser_PreviousItem(*Parser, *Item, Line)
  EndIf
  
  ; must do a nesting search
  Depth = 1
  
  While *Item
    If *Item\Type = #ITEM_Keyword
      If ForwardMatches(*Item\Keyword, 0) = 0 And BackwardMatches(*Item\Keyword, 0) > 0
        ; This is an end of block keyword. Must increase the nesting
        Depth + 1
        
      ElseIf ForwardMatches(*Item\Keyword, 0) > 0 And BackwardMatches(*Item\Keyword, 0) > 0
        ; A middle word like 'ElseIf'. Break only if the current depth is one
        ; Otherwise skip it
        If Depth = 1
          *pItem\i = *Item
          *Line\i = Line
          ProcedureReturn #True
        EndIf
        
      ElseIf ForwardMatches(*Item\Keyword, 0) > 0 And BackwardMatches(*Item\Keyword, 0) = 0
        ; This is a start of block keyword
        Depth - 1
        If Depth = 0
          *pItem\i = *Item
          *Line\i = Line
          ProcedureReturn #True
        EndIf
        
      EndIf
    EndIf
    Parser_PreviousItem(*Parser, *Item, Line)
  Wend
  
  *pItem\i = 0
  ProcedureReturn #False
EndProcedure

Procedure.s ResolveStructureTypeFromSorted(*Parser.ParserData, Type$, List ModuleNames.s())
  
  ; does nothing if already sorted
  SortParserData(*Parser, *Source)
  
  ; look at each module name separately
  ForEach ModuleNames()
    
    *Module.SortedModule = FindMapElement(*Parser\Modules(), UCase(ModuleNames()))
    If *Module
      
      ; Check Structures or Interfaces and Prototypes
      ;
      If RadixLookupValue(*Module\Sorted\Structures, Type$) Or RadixLookupValue(*Module\Sorted\Interfaces, Type$) Or RadixLookupValue(*Module\Sorted\Prototypes, Type$)
        If ModuleNames() = ""
          ProcedureReturn Type$
        ElseIf UCase(Left(ModuleNames(), 6)) = "IMPL::"
          ProcedureReturn LCase(Mid(ModuleNames(), 7)) + "::" + Type$
        Else
          ProcedureReturn LCase(ModuleNames()) + "::" + Type$
        EndIf
      EndIf
      
    EndIf
    
  Next ModuleNames()
  
  ProcedureReturn ""
EndProcedure

; Resolve the complete type for Type$ starting at the given source item
; Works for: Structure, Interface, Prototype
; Note that the type declaration (structure, interface, prototype) can be in another module from the item!
;
Procedure.s ResolveStructureType(*Parser.ParserData, *Item.SourceItem, Line, Type$)
  
  ; If type already has a module prefix or is totally unknown there is nothing todo
  ;
  If Type$ = "" Or  FindString(Type$, "::")
    ProcedureReturn Type$
  EndIf
  
  ; Check for basic types
  If (Len(Type$) = 1 And FindString("bawuclqifd", Type$, 1, #PB_String_NoCase)) Or LCase(Left(Type$, 2)) = "s{"
    ProcedureReturn Type$
  EndIf
  
  ; Find out which modules the item is inside
  ;
  Protected NewList ModuleNames.s()
  If FindModuleStart(*Parser, @Line, @*Item, ModuleNames())
    AddElement(ModuleNames())
    ModuleNames() = *Item\Name$
    
    If *Item\Type = #ITEM_Module
      ; add implementation to search scope
      AddElement(ModuleNames())
      ModuleNames() = "IMPL::" + *Item\Name$
    EndIf
  Else
    ; global scope
    AddElement(ModuleNames())
    ModuleNames() = ""
  EndIf
  
  ; First look at the current parser
  ;
  Full$ = ResolveStructureTypeFromSorted(*Parser, Type$, ModuleNames())
  If Full$
    ProcedureReturn Full$
  EndIf
  
  ; Check project files
  ;
  If AutoCompleteProject And *ActiveSource\ProjectFile
    ; This could be called inside a function that has such a ForEach too!
    Current = ListIndex(ProjectFiles())
    Found = 0
    ForEach ProjectFiles()
      If ProjectFiles()\Source = 0 And @ProjectFiles()\Parser <> *Parser
        Full$ = ResolveStructureTypeFromSorted(@ProjectFiles()\Parser, Type$, ModuleNames())
      ElseIf ProjectFiles()\Source And @ProjectFiles()\Source\Parser <> *Parser
        Full$ = ResolveStructureTypeFromSorted(@ProjectFiles()\Source\Parser, Type$, ModuleNames())
      EndIf
      
      If Full$
        SelectElement(ProjectFiles(), Current)
        ProcedureReturn Full$
      EndIf
    Next ProjectFiles()
    SelectElement(ProjectFiles(), Current)
  EndIf
  
  ; Check other open files
  ;
  If AutoCompleteAllFiles
    Current = ListIndex(FileList())
    Found = 0
    ForEach FileList()
      If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And (AutoCompleteProject = 0 Or FileList()\ProjectFile = 0)
        If @FileList()\Parser <> *Parser
          Full$ = ResolveStructureTypeFromSorted(@FileList()\Parser, Type$, ModuleNames())
          If Full$
            SelectElement(FileList(), Current) ; important!
            ProcedureReturn Full$
          EndIf
        EndIf
      EndIf
    Next FileList()
    SelectElement(FileList(), Current) ; important!
  EndIf
  
  ; return the original type in case it is a predefined resident type
  ProcedureReturn Type$
  
EndProcedure

; Try to resolve the item type by a parser's sorted data
; Look only at the specified module names
; returns prototype for procedure/declare/import and the type for other items (including module prefix)
;
Procedure.s ResolveItemTypeFromSorted(*Parser.ParserData, *InputItem.SourceItem, List ModuleNames.s(), *OutType.INTEGER, *Source.SourceFile = 0)
  
  ; does nothing if already sorted
  SortParserData(*Parser, *Source)
  
  ; look at each module name separately
  ForEach ModuleNames()
    
    *Module.SortedModule = FindMapElement(*Parser\Modules(), UCase(ModuleNames()))
    If *Module
      
      ; Check the macros first for all item types
      ;
      *Item.SourceItem = RadixLookupValue(*Module\Sorted\Macros, *InputItem\Name$)
      If *Item
        ; Check if the macro is a function macro or not
        If (*InputItem\Type = #ITEM_Variable And *Item\Prototype$ <> "") Or (*InputItem\Type <> #ITEM_Variable And *Item\Prototype$ = "")
          Break
        Else
          *OutType\i = #ITEM_Macro
          ProcedureReturn *Item\Prototype$
        EndIf
      EndIf
      
      If *InputItem\Type = #ITEM_UnknownBraced
        
        ; Check all the types that can be UnknownBraced items
        ;
        *Item.SourceItem = RadixLookupValue(*Module\Sorted\Procedures, *InputItem\Name$)
        If *Item
          *OutType\i = *Item\Type
          ProcedureReturn *Item\Prototype$
        EndIf
        
        *Item.SourceItem = RadixLookupValue(*Module\Sorted\Declares, *InputItem\Name$)
        If *Item
          *OutType\i = *Item\Type
          ProcedureReturn *Item\Prototype$
        EndIf
        
        *Item.SourceItem = RadixLookupValue(*Module\Sorted\Arrays, *InputItem\Name$)
        If *Item
          *OutType\i = *Item\Type
          Type$ = StringField(*Item\Type$, 1, Chr(10))
          ProcedureReturn ResolveStructureType(*Parser, *Item, *Item\SortedLine, Type$)
        EndIf
        
        *Item.SourceItem = RadixLookupValue(*Module\Sorted\LinkedLists, *InputItem\Name$)
        If *Item
          *OutType\i = *Item\Type
          Type$ = StringField(*Item\Type$, 1, Chr(10))
          ProcedureReturn ResolveStructureType(*Parser, *Item, *Item\SortedLine, Type$)
        EndIf
        
        *Item.SourceItem = RadixLookupValue(*Module\Sorted\Maps, *InputItem\Name$)
        If *Item
          *OutType\i = *Item\Type
          Type$ = StringField(*Item\Type$, 1, Chr(10))
          ProcedureReturn ResolveStructureType(*Parser, *Item, *Item\SortedLine, Type$)
        EndIf
        
        ; Variables can be #ITEM_UnknownBraced as well, if they are prototypes
        ; If the given variable is no Prototype then there is no match, as a
        ; List can not match a variable etc
        ;
        *Item.SourceItem = RadixLookupValue(*Module\Sorted\Variables, *InputItem\Name$)
        If *Item
          Type$ = StringField(*Item\Type$, 1, Chr(10))
          Type$ = ResolveStructureType(*Parser, *Item, *Item\SortedLine, Type$)
          
          If Type$ And FindPrototype(Type$)
            *OutType\i = *Item\Type
            ProcedureReturn Type$
          EndIf
        EndIf
        
      ElseIf *InputItem\Type <= #ITEM_LastSorted
        *Item.SourceItem = RadixLookupValue(*Module\Indexed[*InputItem\Type], *InputItem\Name$)
        If *Item
          *OutType\i = *InputItem\Type
          Type$ = StringField(*Item\Type$, 1, Chr(10))
          Type$ = ResolveStructureType(*Parser, *Item, *Item\SortedLine, Type$)
          ProcedureReturn Type$
        EndIf
        
      EndIf
      
      
    EndIf
    
  Next ModuleNames()
  
  ProcedureReturn ""
EndProcedure


; Try to resolve the item type in the activesource or all open sources
; Pass in one of: Variable, Array, List, Map, UnknownBraced
Procedure.s ResolveItemType(*InputItem.SourceItem, InputLine, *OutType.INTEGER)
  Protected NewList OpenModules.s()
  
  *Parser.ParserData = @*ActiveSource\Parser
  *Item.SourceItem = *InputItem
  Line  = InputLine
  
  *OutType\i = *InputItem\Type
  Scope = *InputItem\Scope
  
  *ModuleStart.SourceItem = *InputItem
  ModuleStartLine = Line
  
  ; Check the *InputItem itself to know if it provides enough info
  ;
  If *InputItem\Type <> #ITEM_UnknownBraced
    Type$ = StringField(*InputItem\Type$, 1, Chr(10))
    If Type$ <> ""
      ProcedureReturn ResolveStructureType(@*ActiveSource\Parser, *InputItem, InputLine, Type$)
    EndIf
  EndIf
  
  ; Find module start and open modules
  ;
  InsideModule = FindModuleStart(*Parser, @ModuleStartLine, @*ModuleStart, OpenModules())
  If InsideModule
    ModulePrefix$ = *ModuleStart\Name$ + "::"
  Else
    ModulePrefix$ = ""
  EndIf
  
  ; Check local scope, if we are inside a procedure
  ; If declared local, assume it is part of the current module too
  ;
  If FindProcedureStart(*Parser, @Line, @*Item)
    
    While *Item
      If *Item\ModulePrefix$ = "" ; only look at items not from other modules here
        Select *Item\Type
            
          Case #ITEM_ProcedureEnd
            Break
            
          Case #ITEM_Macro
            While *Item And *Item\Type <> #ITEM_MacroEnd
              Parser_NextItem(*Parser, *Item, Line)
            Wend
            
            If *Item = 0 ; Important check, as Parser_NextItem() does not check it below
              Break
            EndIf
            
          Case #ITEM_Keyword
            SkipTo = 0
            Select *Item\Keyword
              Case #KEYWORD_Structure: SkipTo = #KEYWORD_EndStructure
              Case #KEYWORD_Interface: SkipTo = #KEYWORD_EndInterface
              Case #KEYWORD_Import   : SkipTo = #KEYWORD_EndImport
              Case #KEYWORD_ImportC  : SkipTo = #KEYWORD_EndImport
            EndSelect
            If SkipTo
              While *Item And (*Item\Type <> #ITEM_Keyword Or *Item\Keyword <> SkipTo)
                Parser_NextItem(*Parser, *Item, Line)
              Wend
              
              If *Item = 0 ; Important check, as Parser_NextItem() does not check it below
                Break
              EndIf
            EndIf
            
          Case #ITEM_Variable
            If *OutType\i = #ITEM_Variable And CompareMemoryString(@*Item\Name$, @*InputItem\Name$, #PB_String_NoCaseAscii) = #PB_String_Equal
              Type$ = StringField(*Item\Type$, 1, Chr(10))
              If Type$ <> ""
                ProcedureReturn ResolveStructureType(@*ActiveSource\Parser, *Item, Line, Type$)
              ElseIf Scope = #SCOPE_Unknown
                Scope = *Item\Scope
              EndIf
              
              ; If we have a variable with a prototype, the input may be an UnknownBraced as we call the prototype,
              ; so check for this case
              ;
            ElseIf *OutType\i = #ITEM_UnknownBraced And CompareMemoryString(@*Item\Name$, @*InputItem\Name$, #PB_String_NoCaseAscii) = #PB_String_Equal
              Type$ = StringField(*Item\Type$, 1, Chr(10))
              Type$ = ResolveStructureType(@*ActiveSource\Parser, *Item, Line, Type$)
              If Type$ And FindPrototype(Type$)
                *OutType\i = #ITEM_Variable
                ProcedureReturn Type$
              EndIf
              
            EndIf
            
          Case #ITEM_Array, #ITEM_LinkedList, #ITEM_Map
            If (*OutType\i = *Item\Type Or *OutType\i = #ITEM_UnknownBraced) And CompareMemoryString(@*Item\Name$, @*InputItem\Name$, #PB_String_NoCaseAscii) = #PB_String_Equal
              *OutType\i = *Item\Type ; update in case it was UnknownBraced
              Type$ = StringField(*Item\Type$, 1, Chr(10))
              If Type$ <> ""
                ProcedureReturn ResolveStructureType(@*ActiveSource\Parser, *Item, Line, Type$)
              ElseIf Scope = #SCOPE_Unknown
                Scope = *Item\Scope
              EndIf
            EndIf
            
        EndSelect
      EndIf
      
      Parser_NextItem(*Parser, *Item, Line)
    Wend
    
    ; if its local or static and nothing was found then there is probably no type
    If Scope = #SCOPE_LOCAL Or Scope = #SCOPE_STATIC
      ProcedureReturn ""
    EndIf
  EndIf
  
  ; Determine the module names to look at
  If *InputItem\ModulePrefix$ <> ""
    AddElement(OpenModules())
    OpenModules() = *InputItem\ModulePrefix$
  ElseIf InsideModule
    AddElement(OpenModules())
    OpenModules() = *ModuleStart\Name$
    
    ; also look at the module impl if we are inside it
    If *ModuleStart\Type = #ITEM_Module
      AddElement(OpenModules())
      OpenModules() = "IMPL::" + *ModuleStart\Name$
    EndIf
  Else
    ; look at the main module too
    AddElement(OpenModules())
    OpenModules() = ""
  EndIf
  
  ; Check activesource globals scope
  ;
  Type$ = ResolveItemTypeFromSorted(*Parser, *InputItem, OpenModules(), *OutType, *ActiveSource)
  If Type$
    ProcedureReturn Type$
  EndIf
  
  ; Check project files
  ;
  If AutoCompleteProject And *ActiveSource\ProjectFile
    ; This could be called inside a function that has such a ForEach too!
    Current = ListIndex(ProjectFiles())
    Found = 0
    ForEach ProjectFiles()
      If ProjectFiles()\Source = 0
        Type$ = ResolveItemTypeFromSorted(@ProjectFiles()\Parser, *InputItem, OpenModules(), *OutType)
      ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *Source
        Type$ = ResolveItemTypeFromSorted(@ProjectFiles()\Source\Parser, *InputItem, OpenModules(), *OutType, ProjectFiles()\Source)
      EndIf
      
      If Type$
        SelectElement(ProjectFiles(), Current)
        ProcedureReturn Type$
      EndIf
    Next ProjectFiles()
    SelectElement(ProjectFiles(), Current)
  EndIf
  
  ; Check other open files
  ;
  If AutoCompleteAllFiles
    Current = ListIndex(FileList())
    Found = 0
    ForEach FileList()
      If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And (AutoCompleteProject = 0 Or FileList()\ProjectFile = 0)
        Type$ = ResolveItemTypeFromSorted(@FileList()\Parser, *InputItem, OpenModules(), *OutType, @FileList())
        If Type$
          SelectElement(FileList(), Current) ; important!
          ProcedureReturn Type$
        EndIf
      EndIf
    Next FileList()
    SelectElement(FileList(), Current) ; important!
  EndIf
  
  ProcedureReturn ""
EndProcedure


; If the given position (must be a whitespace position or \) is inside a structure/interface,
; this procedure locates the structure base item (also inside With/EndWith) and returns the item/line
; This works only on the active source (has to fetch data from the editor area)
;
; Input:
;   Line$    - line content
;   Position - 0 based location of the '\'
;   *pLine\i - line number
;
; Output:
;   returns #true if base item found
;   *pItem\i - SourceItem pointer for base item
;   *pLine\i - line of base item
;   StructureStack() - filled with structure subitems leading up to the last \
Procedure LocateStructureBaseItem(Line$, Position, *pItem.INTEGER, *pLine.INTEGER, List StructureStack.s())
  IsStructure          = #False
  *BaseItem.SourceItem = 0
  BaseItemLine         = *pLine\i
  ClearList(StructureStack())
  
  ; Strings with escape sequences cannot be searched backwards, so do a first run to block all strings
  ; escape sequences and char consts. This way they can be ignored below
  *Forward.PTR = @Buffer
  While *Forward\c
    If *Forward\c = '"' Or *Forward\c = 39
      ; String or CharConst
      Stop = *Forward\c
      *Forward\c = ' ': *Forward + #CharSize
      While *Forward\c And *Forward\c <> Stop
        *Forward\c = ' ': *Forward + #CharSize
      Wend
      If *Forward\c = Stop
        *Forward\c = ' ': *Forward + #CharSize
      EndIf
      
    ElseIf *Forward\c = '~' And *Forward\c[1] = '"'
      ; Escaped string
      *Forward\c = ' ': *Forward + #CharSize
      *Forward\c = ' ': *Forward + #CharSize
      While *Forward\c And *Forward\c <> '"'
        If *Forward\c = '\' And *Forward\c[1] <> 0
          *Forward\c = ' ': *Forward + #CharSize
          *Forward\c = ' ': *Forward + #CharSize
        Else
          *Forward\c = ' ': *Forward + #CharSize
        EndIf
      Wend
      If *Forward\c = '"'
        *Forward\c = ' ': *Forward + #CharSize
      EndIf
      
    Else
      *Forward + #CharSize
    EndIf
  Wend
  
  ; Skip any whitespace
  *Buffer = @Line$
  *Cursor.Character = *Buffer + Position * SizeOf(Character)
  While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
    *Cursor - SizeOf(Character)
  Wend
  
  ; check if we have a structure here
  ; If yes, search for the SourceItem that is the structure base
  If *Cursor >= *Buffer And *Cursor\c = '\'
    
    While *Cursor >= *Buffer And *Cursor\c = '\'
      *SlashPosition = *Cursor
      
      *Cursor - SizeOf(Character)
      While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9) ; whitespace
        *Cursor - SizeOf(Character)
      Wend
      
      ; check for array in structure, or list, map in structure or base item
      ;
      If *Cursor >= *Buffer And (*Cursor\c = ']' Or *Cursor\c = ')')
        ; skip any number of [], ()
        If *Cursor\c = ']'
          CharOpen = '['
          CharClose = ']'
        Else
          CharOpen = '('
          CharClose = ')'
        EndIf
        
        Depth = 1
        *Cursor - SizeOf(Character)
        While *Cursor >= *Buffer And Depth > 0
          If *Cursor\c = CharClose
            Depth + 1
          ElseIf *Cursor\c = CharOpen
            Depth - 1
          EndIf
          *Cursor - SizeOf(Character)
        Wend
        
      EndIf
      
      ; skip whitespace
      While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9) ; whitespace
        *Cursor - SizeOf(Character)
      Wend
      
      
      ; Must have the structure item here now, or structure base
      If *Cursor >= *Buffer And (*Cursor\c = '$' Or ValidCharacters(*Cursor\c))
        *EndPosition = *Cursor
        *Cursor - SizeOf(Character)
        While *Cursor >= *Buffer And (*Cursor\c = '*' Or ValidCharacters(*Cursor\c))
          *Cursor - SizeOf(Character)
        Wend
        *StartPosition = *Cursor + SizeOf(Character)
        
        ; skip whitespace
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9) ; whitespace
          *Cursor - SizeOf(Character)
        Wend
        
        ; check for a module operator (in item type)
        If *Cursor >= *Buffer + 2 And *Cursor\c = ':' And PeekC(*Cursor - SizeOf(Character)) = ':'
          *Cursor - 2 * SizeOf(Character)
          
          ; skip whitespace
          While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9) ; whitespace
            *Cursor - SizeOf(Character)
          Wend
          
          ; skip the module prefix
          If *Cursor >= *Buffer And ValidCharacters(*Cursor\c)
            *Cursor - SizeOf(Character)
            While *Cursor >= *Buffer And ValidCharacters(*Cursor\c)
              *Cursor - SizeOf(Character)
            Wend
            
            ; skip whitespace
            While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
              *Cursor - SizeOf(Character)
            Wend
          EndIf
        EndIf
        
        ; the base item can also have a type
        If *Cursor >= *Buffer And *Cursor\c = '.'
          *Cursor - SizeOf(Character)
          
          ; skip whitespace
          While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9) ; whitespace
            *Cursor - SizeOf(Character)
          Wend
          
          If ValidCharacters(*Cursor\c)
            *EndPosition = *Cursor
            *Cursor - SizeOf(Character)
            While *Cursor >= *Buffer And (*Cursor\c = '*' Or ValidCharacters(*Cursor\c))
              *Cursor - SizeOf(Character)
            Wend
            *StartPosition = *Cursor + SizeOf(Character)
          Else
            ; something is invalid here
            Break
          EndIf
        EndIf
        
        ; skip whitespace
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9) ; whitespace
          *Cursor - SizeOf(Character)
        Wend
        
        ; Now look if we have another '\' coming
        If *Cursor >= *Buffer And *Cursor\c = '\'
          ; its a sub-structure, so add it (InsertElement, as we search backwards!)
          InsertElement(StructureStack())
          StructureStack() = PeekS(*StartPosition, ((*EndPosition-*StartPosition)/SizeOf(Character))+1)
          ; loop again on the '\' character
          
        Else
          ; It must be the base item, so try to identify it (the loop then terminates)
          *BaseItem = LocateSourceItem(@*ActiveSource\Parser, BaseItemLine, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, (*StartPosition-*Buffer)/SizeOf(Character)))
          If *BaseItem
            If *BaseItem\Type = #ITEM_Variable Or *BaseItem\Type = #ITEM_Array Or *BaseItem\Type = #ITEM_LinkedList Or *BaseItem\Type = #ITEM_Map Or *BaseItem\Type = #ITEM_UnknownBraced
              ; valid base item found (something that can have a structure)
              IsStructure = #True
            Else
              ; go t some item that cannot be the structure. try searching for a With then
              *BaseItem = 0
            EndIf
          EndIf
          
          Break ; nothing more to do
        EndIf
        
        ; No valid char found, something is invalid here
      Else
        Break
      EndIf
    Wend
    
    If *BaseItem = 0
      ;
      ; So we have some \, but no valid base item. Check if there is a "With" somewhere
      ;
      *Item.SourceItem = ClosestSourceItem(@*ActiveSource\Parser, @BaseItemLine, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, (*SlashPosition-*Buffer)/SizeOf(Character)))
      While *Item
        Select *Item\Type
            
          Case #ITEM_Keyword
            If *Item\Keyword = #KEYWORD_With
              
              ; The item directly following the With keyword must be our base item
              ; Note that a #ITEM_FoldStart or #ITEM_FoldEnd could be between the Width and the real source item
              If *Item\Next And (*Item\Next\Type = #ITEM_FoldStart Or *Item\Next\Type = #ITEM_FoldEnd)
                *Item = *Item\Next
              EndIf
              If *Item\Next And (*Item\Next\Type = #ITEM_Variable Or *Item\Next\Type = #ITEM_Array Or *Item\Next\Type = #ITEM_LinkedList Or *Item\Next\Type = #ITEM_Map Or *Item\Next\Type = #ITEM_UnknownBraced)
                *BaseItem = *Item\Next
                IsStructure = #True
                
                ; ok, so we have our base. now we must check if it is something like "Width x\y\z"
                Line$ = GetLine(BaseItemLine, *ActiveSource)
                If *BaseItem\Position >= 0 And *BaseItem\Position+*BaseItem\FullLength < Len(Line$)
                  *Cursor = @Line$ + BytesToChars(Line$, 0, *ActiveSource\Parser\Encoding, *BaseItem\Position + *BaseItem\Length) * #CharSize
                  
                  ; Reset the list and then do AddElement() as we are now scanning forward
                  ResetList(StructureStack())
                  
                  ; we start off right after the base item, so skip until after \ first
                  While *Cursor\c
                    While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend
                    
                    
                    If *Cursor\c = '.' ; type (can happen on the base item)
                      *Cursor + SizeOf(Character)
                      While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend ; whitespace
                      While ValidCharacters(*Cursor\c)                                          ; type name (no *, $, p-ascii etc allowed anyway)
                        *Cursor + SizeOf(Character)
                      Wend
                      While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend ; whitespace
                      
                      ; check for possible module prefix
                      If *Cursor\c = ':' And PeekC(*Cursor + SizeOf(Character)) = ':'
                        *Curspr + 2*SizeOf(Character)
                        While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend ; whitespace
                        While ValidCharacters(*Cursor\c)                                          ; type name (no *, $, p-ascii etc allowed anyway)
                          *Cursor + SizeOf(Character)
                        Wend
                        While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend ; whitespace
                      EndIf
                    EndIf
                    
                    If *Cursor\c = '(' Or *Cursor\c = '[' ; array/map/list (on the base item or inside structure)
                                                          ; skip any number of [], ()
                      If *Cursor\c = '['
                        CharOpen = '['
                        CharClose = ']'
                      Else
                        CharOpen = '('
                        CharClose = ')'
                      EndIf
                      
                      Depth = 1
                      *Cursor + SizeOf(Character)
                      While *Cursor\c And Depth > 0
                        If *Cursor\c = CharOpen
                          Depth + 1
                        ElseIf *Cursor\c = CharClose
                          Depth - 1
                        ElseIf *Cursor\c = '"'
                          *Cursor + SizeOf(Character)
                          While *Cursor\c And *Cursor\c <> '"'
                            *Cursor + SizeOf(Character)
                          Wend
                        ElseIf *Cursor\c = '~' And PeekC(*Cursor + #CharSize) = '"'
                          *Cursor + (2 * #CharSize)
                          While *Cursor\c And *Cursor\c <> '"'
                            If *Cursor\c = '\' And PeekC(*Cursor + #CharSize) <> 0
                              *Cursor + (2 * #CharSize)
                            Else
                              *Cursor + SizeOf(Character)
                            EndIf
                          Wend
                        ElseIf *Cursor\c = 39 ; '
                          *Cursor + SizeOf(Character)
                          While *Cursor\c And *Cursor\c <> 39
                            *Cursor + SizeOf(Character)
                          Wend
                        EndIf
                        *Cursor + SizeOf(Character)
                      Wend
                      
                      ; whitespace
                      While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend ; whitespace
                    EndIf
                    
                    If *Cursor\c = '\'
                      *Cursor + SizeOf(Character)
                      While *Cursor\c = ' ' Or *Cursor\c = 9: *Cursor + SizeOf(Character): Wend
                      
                      *Start = *Cursor
                      While ValidCharacters(*Cursor\c) ; skip item name (can have no $, *, etc here anyway)
                        *Cursor + SizeOf(Character)
                      Wend
                      
                      If *Cursor > *Start
                        AddElement(StructureStack())
                        StructureStack() = PeekS(*Start, (*Cursor-*Start)/SizeOf(Character))
                      Else
                        ; something is invalid here
                        Break
                      EndIf
                    Else
                      ; something is invalid here
                      Break
                    EndIf
                  Wend
                EndIf
                
              EndIf
              
              ; found the Width, so break the search (with or without base item)
              Break
              
            ElseIf *Item\Keyword = #KEYWORD_EndWith
              Break ; not inside a With
            EndIf
            
          Case #ITEM_MacroEnd ; Skip Macros as usual
            While *Item And *Item\Type <> #ITEM_Macro
              Parser_PreviousItem(*ActiveSource\Parser, *Item, BaseItemLine)
            Wend
            
            ; The Parser_PreviousItem() below has no 0 check, so break here!
            If *Item = 0
              Break
            EndIf
            
          Case #ITEM_Macro ; inside a macro, we do not search further
            Break
            
        EndSelect
        Parser_PreviousItem(*ActiveSource\Parser, *Item, BaseItemLine)
      Wend
    EndIf
    
  EndIf
  
  *pItem\i = *BaseItem
  *pLine\i = BaseItemLine
  ProcedureReturn IsStructure
EndProcedure



DataSection
  
  ; List of keyword pairs that match, terminated by a 0 pair
  ;
  ; - The second column defines the keywords that MUST follow the first one
  ;   on the same nesting level. If there are multiple options, then there
  ;   are multiple pairs.
  ;   (Example: Case must be followed by either Case, Default Or EndSelect)
  ;
  ; Note: Compiler Keywords are treated specially, as they can be used
  ;   outside of the normal nesting rules.
  ;
  KeywordMatches:
  Data.l #KEYWORD_Case,            #KEYWORD_Case
  Data.l #KEYWORD_Case,            #KEYWORD_Default
  Data.l #KEYWORD_Case,            #KEYWORD_EndSelect
  Data.l #KEYWORD_CompilerCase,    #KEYWORD_CompilerCase
  Data.l #KEYWORD_CompilerCase,    #KEYWORD_CompilerDefault
  Data.l #KEYWORD_CompilerCase,    #KEYWORD_CompilerEndSelect
  Data.l #KEYWORD_CompilerDefault, #KEYWORD_CompilerEndSelect
  Data.l #KEYWORD_CompilerElse,    #KEYWORD_CompilerEndIf
  Data.l #KEYWORD_CompilerElseIf,  #KEYWORD_CompilerElse
  Data.l #KEYWORD_CompilerElseIf,  #KEYWORD_CompilerElseIf
  Data.l #KEYWORD_CompilerElseIf,  #KEYWORD_CompilerEndIf
  Data.l #KEYWORD_CompilerIf,      #KEYWORD_CompilerElse
  Data.l #KEYWORD_CompilerIf,      #KEYWORD_CompilerElseIf
  Data.l #KEYWORD_CompilerIf,      #KEYWORD_CompilerEndIf
  Data.l #KEYWORD_CompilerSelect,  #KEYWORD_CompilerCase
  Data.l #KEYWORD_CompilerSelect,  #KEYWORD_CompilerEndSelect
  Data.l #KEYWORD_Data,            #KEYWORD_Data
  Data.l #KEYWORD_Data,            #KEYWORD_EndDataSection
  Data.l #KEYWORD_DataSection,     #KEYWORD_Data
  Data.l #KEYWORD_DataSection,     #KEYWORD_EndDataSection
  Data.l #KEYWORD_DeclareModule,   #KEYWORD_EndDeclareModule
  Data.l #KEYWORD_Default,         #KEYWORD_EndSelect
  Data.l #KEYWORD_Else,            #KEYWORD_EndIf
  Data.l #KEYWORD_ElseIf,          #KEYWORD_ElseIf
  Data.l #KEYWORD_ElseIf,          #KEYWORD_Else
  Data.l #KEYWORD_ElseIf,          #KEYWORD_EndIf
  Data.l #KEYWORD_Enumeration,     #KEYWORD_EndEnumeration
  Data.l #KEYWORD_EnumerationBinary, #KEYWORD_EndEnumeration
  Data.l #KEYWORD_For,             #KEYWORD_Next
  Data.l #KEYWORD_ForEach,         #KEYWORD_Next
  Data.l #KEYWORD_If,              #KEYWORD_ElseIf
  Data.l #KEYWORD_If,              #KEYWORD_Else
  Data.l #KEYWORD_If,              #KEYWORD_EndIf
  Data.l #KEYWORD_Import,          #KEYWORD_EndImport
  Data.l #KEYWORD_ImportC,         #KEYWORD_EndImport
  Data.l #KEYWORD_Interface,       #KEYWORD_EndInterface
  Data.l #KEYWORD_Macro,           #KEYWORD_EndMacro
  Data.l #KEYWORD_Module,          #KEYWORD_EndModule
  Data.l #KEYWORD_Procedure,       #KEYWORD_EndProcedure
  Data.l #KEYWORD_ProcedureC,      #KEYWORD_EndProcedure
  Data.l #KEYWORD_ProcedureCDLL,   #KEYWORD_EndProcedure
  Data.l #KEYWORD_ProcedureDLL,    #KEYWORD_EndProcedure
  Data.l #KEYWORD_Repeat,          #KEYWORD_Until
  Data.l #KEYWORD_Repeat,          #KEYWORD_Forever
  Data.l #KEYWORD_Select,          #KEYWORD_Case
  Data.l #KEYWORD_Select,          #KEYWORD_EndSelect
  Data.l #KEYWORD_Structure,       #KEYWORD_EndStructure
  Data.l #KEYWORD_HeaderSection,   #KEYWORD_EndHeaderSection
  CompilerIf Not #SpiderBasic
    Data.l #KEYWORD_StructureUnion,  #KEYWORD_EndStructureUnion
  CompilerEndIf
  Data.l #KEYWORD_While,           #KEYWORD_Wend
  Data.l #KEYWORD_With,            #KEYWORD_EndWith
  Data.l 0, 0
  
EndDataSection