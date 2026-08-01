; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; to be able to display the QuickHelp to the function where the cursor is currently inside, even when it is not over it
;
Structure QuickHelpStack
  Word$       ; Word for the QuickHelp
  Position.l  ; Position in the input line
  Parameter.l ; holds the parameter of the function we are currently working on.
EndStructure

Global Dim QuickHelpStack.QuickHelpStack(200)
Global NewList QuickHelpStructureStack.s()
Global NewList QuickHelpStructureList.s()

; Regular expressions to match a single number
;
CreateRegularExpression(#REGEX_HexNumber, "^[\+\-]?\$[0-9a-fA-F]+$")
CreateRegularExpression(#REGEX_BinNumber, "^[\+\-]?\%[01]+$")
CreateRegularExpression(#REGEX_DecNumber, "^[\+\-]?[0-9]+$")
CreateRegularExpression(#REGEX_FloatNumber, "^[\+\-]?[0-9]+\.[0-9]*$")
CreateRegularExpression(#REGEX_ScienceNumber, "^[\+\-]?[0-9]+\.?[0-9]*[eE][\+\-]?[0-9]+$")


; Retrieve the boundary of a word (start index and end index from a buffer, given the
; position in the buffer)
;
; NOTE: When modifying this function, be sure to report to standalone debugger
;
Procedure GetWordBoundary(*Buffer, BufferLength, Position, *StartIndex.INTEGER, *EndIndex.INTEGER, Mode)
  *WordStart.Character = *Buffer
  *WordEnd.Character   = *Buffer + BufferLength * #CharSize
  
  If Position >= 0 And Position < BufferLength+#CharSize And (Mode = 1 Or Position < BufferLength)
    *Cursor.Character = *Buffer + Position*#CharSize
    
    If Mode = 1 ; Needed for Auto-complete
      *Cursor-#CharSize
    ElseIf ValidCharacters(*Cursor\c) = 0 ; Needed, so F1 help works nicely
      *Cursor-#CharSize
    EndIf
    
    While *Cursor >= *Buffer
      If ValidCharacters(*Cursor\c) = 0 And (Mode = 0 Or (*Cursor\c <> '#' And *Cursor\c <> '*'))
        *WordStart = *Cursor + #CharSize
        Break
      EndIf
      *Cursor - #CharSize
      Found = 1
    Wend
    
    *Cursor.Character = *Buffer + Position*#CharSize
    While *Cursor\c
      If ValidCharacters(*Cursor\c) = 0 And *Cursor\c <> '$'
        *WordEnd = *Cursor - #CharSize
        Break
      EndIf
      *Cursor + #CharSize
      Found = 1
    Wend
    
    ; Special case: "var1*var2" is detected as one word! (also handle 1*2*3*4*word correctly)
    If Found
      Repeat
        *Cursor = FindMemoryCharacter(*WordStart+#CharSize, (*WordEnd - *WordStart) / #CharSize - 1, '*')
        If *Cursor
          If *Cursor <= *Buffer + Position*#CharSize ; the cursor is on the second word
            *WordStart = *Cursor+#CharSize
          ElseIf *Cursor < *WordEnd ; cursor on the first word
            *WordEnd = *Cursor
          EndIf
        EndIf
      Until *Cursor = 0
      
      ; Another special case: *#CONSTANT (https://www.purebasic.fr/english/viewtopic.php?f=4&t=40104)
      *NextCharacter.Character = *WordStart+#CharSize
      If *WordStart\c = '*' And *NextCharacter\c = '#'
        *WordStart+1
      EndIf
    EndIf
  EndIf
  
  CompilerIf #PB_Compiler_Unicode
    *StartIndex\i = (*WordStart - *Buffer)/#CharSize
    *EndIndex\i   = (*WordEnd   - *Buffer)/#CharSize
  CompilerElse
    *StartIndex\i = *WordStart - *Buffer
    *EndIndex\i   = *WordEnd   - *Buffer
  CompilerEndIf
  
  ProcedureReturn Found
EndProcedure

Procedure.s GetWord(*Buffer, BufferLength, Position)
  
  If GetWordBoundary(*Buffer, BufferLength, Position, @StartIndex, @EndIndex, 0)
    If EndIndex-StartIndex+1 > 0
      ProcedureReturn PeekS(*Buffer + StartIndex * #CharSize, EndIndex-StartIndex+1)
    EndIf
  EndIf
EndProcedure


Procedure.s GetModulePrefix(*Buffer, BufferLength, Position)
  
  If Position > 1 And Position <= BufferLength
    *Cursor.Character = *Buffer + (Position - 1) * #CharSize
    
    ; skip space
    While *Cursor > *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
      *Cursor - #CharSize
    Wend
    
    ; check for module operator
    If *Cursor > *Buffer+#CharSize And *Cursor\c = ':' And PeekC(*Cursor - #CharSize) = ':'
      *Cursor - 2*#CharSize
      
      ; skip space
      While *Cursor > *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
        *Cursor - #CharSize
      Wend
      
      ; skip word
      *LastChar = *Cursor
      While *Cursor > *Buffer And ValidCharacters(*Cursor\c)
        *Cursor - #CharSize
      Wend
      If *Cursor = *Buffer And ValidCharacters(*Cursor\c)
        *FirstChar = *Buffer
      Else
        *FirstChar = *Cursor + #CharSize
      EndIf
      
      If *LastChar >= *FirstChar
        CompilerIf #PB_Compiler_Unicode
          ProcedureReturn PeekS(*FirstChar, (*LastChar - *FirstChar + #CharSize) / #CharSize)
        CompilerElse
          ProcedureReturn PeekS(*FirstChar, *LastChar - *FirstChar + #CharSize)
        CompilerEndIf
      EndIf
      
      
    EndIf
  EndIf
  
  ProcedureReturn ""
EndProcedure



Procedure.s GetCurrentLine()
  
  GetCursorPosition() ; Ensures than the fields are updated
  ProcedureReturn GetLine(*ActiveSource\CurrentLine-1)
  
EndProcedure

Procedure.s GetCurrentWord()
  
  Line$ = GetCurrentLine()
  If Line$
    CurrentWord$ = GetWord(@Line$, Len(Line$), *ActiveSource\CurrentColumnChars-1)
  EndIf
  
  ProcedureReturn CurrentWord$
EndProcedure

; Extract the number at the given position
; Does not guarantee that the output is a correct number.
; The regular expressions at the top can be used to verify this easily
Procedure.s GetNumber(Line$, Position) ; position is 0-based
  If Position >= Len(Line$)            ; 0-based
    ProcedureReturn ""
  EndIf
  
  ; Note: The PB compiler accepts spaces between some number parts, but
  ;   for simplicity we only allow it without spaces (which should be the norm)
  ;   Who writes a number like "1e - 10" ?
  ;
  Line$   = UCase(Line$) ; simplify the checks
  *Buffer = @Line$
  *Pointer.Character = @Line$ + Position
  
  ; Walk back from the current location depending on the current cursor token
  ; to find the start of the number
  ; The further possible tokens depend on what token we start on
  ;
  Select *Pointer\c
      
    Case '%', '$'
      ; Hex and Bin numbers, there can only be a +, - before this
      *Pointer - SizeOf(Character)
      If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
        *Pointer - SizeOf(Character)
      EndIf
      
    Case '.'
      ; Before the dot can only be a decimal number and a sign
      ; The exponent part cannot contain a dot
      *Pointer - SizeOf(Character)
      While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
        *Pointer - SizeOf(Character)
      Wend
      If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
        *Pointer - SizeOf(Character)
      EndIf
      
    Case '+', '-'
      ; A +/- can be in the exponent part, so we can be in the middle of the number or the beginning
      ; No need to check for possible Hex in this case, as there its only in the beginning
      *Pointer - SizeOf(Character)
      If *Pointer >= *Buffer And *Pointer\c = 'E'
        *Pointer - SizeOf(Character)
        While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
          *Pointer - SizeOf(Character)
        Wend
        If *Pointer >= *Buffer And *Pointer\c = '.'
          *Pointer - SizeOf(Character)
          While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
            *Pointer - SizeOf(Character)
          Wend
        EndIf
        If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
          *Pointer - SizeOf(Character)
        EndIf
      EndIf
      
    Case 'E'
      ; before the exponent part can be a full decimal number (with dot and sign)
      ; NOTE: E can also be in a Hex number, so accept both!
      *Pointer - SizeOf(Character)
      While *Pointer >= *Buffer And ((*Pointer\c >= '0' And *Pointer\c <= '9') Or (*Pointer\c >= 'A' And *Pointer\c <= 'F'))
        *Pointer - SizeOf(Character)
      Wend
      If *Pointer >= *Buffer And *Pointer\c = '.'
        ; As we found a dot, it can no longer be a Hex number
        *Pointer - SizeOf(Character)
        While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
          *Pointer - SizeOf(Character)
        Wend
      EndIf
      If *Pointer >= *Buffer And *Pointer\c = '$' ; possible Hex start
        *Pointer - SizeOf(Character)
      EndIf
      If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
        *Pointer - SizeOf(Character)
      EndIf
      
    Case 'A' To 'D', 'F'
      ; Can only be a hex number here
      While *Pointer >= *Buffer And ((*Pointer\c >= '0' And *Pointer\c <= '9') Or (*Pointer\c >= 'A' And *Pointer\c <= 'F'))
        *Pointer - SizeOf(Character)
      Wend
      If *Pointer >= *Buffer And *Pointer\c = '$'
        *Pointer - SizeOf(Character)
      EndIf
      If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
        *Pointer - SizeOf(Character)
      EndIf
      
    Case '0' To '9'
      ; We can be in the part before, after the dot or after the E
      ; Or this could be a hex or bin number.
      ; Note: This first check walks right over the 'E' if we have a float number (with no extra sign), which is no problem
      While *Pointer >= *Buffer And ((*Pointer\c >= '0' And *Pointer\c <= '9') Or (*Pointer\c >= 'A' And *Pointer\c <= 'F'))
        *Pointer - SizeOf(Character)
      Wend
      ; Possible sign for the exponent
      If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
        *Pointer - SizeOf(Character)
      EndIf
      If *Pointer >= *Buffer
        Select *Pointer\c
            
          Case '%', '$'
            ; Now we know its hex/bin
            *Pointer - SizeOf(Character)
            
          Case '.'
            ; Its a normal float, or exponent without a sign
            *Pointer - SizeOf(Character)
            While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
              *Pointer - SizeOf(Character)
            Wend
            
          Case 'E'
            ; Now we know its an exponent number (as it must have been "E+" or "E-")
            *Pointer - SizeOf(Character)
            While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
              *Pointer - SizeOf(Character)
            Wend
            If *Pointer >= *Buffer And *Pointer\c = '.'
              *Pointer - SizeOf(Character)
              While *Pointer >= *Buffer And (*Pointer\c >= '0' And *Pointer\c <= '9')
                *Pointer - SizeOf(Character)
              Wend
            EndIf
            
        EndSelect
        
        If *Pointer >= *Buffer And (*Pointer\c = '+' Or *Pointer\c = '-')
          *Pointer - SizeOf(Character)
        EndIf
      EndIf
      
  EndSelect
  
  ; *Pointer now points 1 char before the number start (or to *Buffer-1)
  ;
  *Start = *Pointer + SizeOf(Character)
  
  ; Now we scan forward from here, which is much simpler
  ;
  *Pointer = *Start
  
  ; First, a possible sign
  If *Pointer\c = '+' Or *Pointer\c = '-'
    *Pointer + SizeOf(Character)
  EndIf
  
  If *Pointer\c = '$' ; Hex number
    *Pointer + SizeOf(Character)
    While (*Pointer\c >= '0' And *Pointer\c <= '9') Or (*Pointer\c >= 'A' And *Pointer\c <= 'F')
      *Pointer + SizeOf(Character)
    Wend
    
  ElseIf *Pointer\c = '%' ; Bin number
    *Pointer + SizeOf(Character)
    While *Pointer\c = '0' Or *Pointer\c = '1'
      *Pointer + SizeOf(Character)
    Wend
    
  Else ; dec number
    While *Pointer\c >= '0' And *Pointer\c <= '9'
      *Pointer + SizeOf(Character)
    Wend
    
    If *Pointer\c = '.'
      *Pointer + SizeOf(Character)
      While *Pointer\c >= '0' And *Pointer\c <= '9'
        *Pointer + SizeOf(Character)
      Wend
    EndIf
    
    If *Pointer\c = 'E'
      *Pointer + SizeOf(Character)
      If *Pointer\c = '+' Or *Pointer\c = '-'
        *Pointer + SizeOf(Character)
      EndIf
      While *Pointer\c >= '0' And *Pointer\c <= '9'
        *Pointer + SizeOf(Character)
      Wend
    EndIf
    
  EndIf
  
  ProcedureReturn PeekS(*Start, (*Pointer - *Start) / SizeOf(Character))
EndProcedure


Procedure InsertComments()
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  GetSelection(@LineStart, 0, @LineEnd, @RowEnd)
  
  If RowEnd <= 1 And LineStart <> LineEnd ; when selecting a full line, it actually selects the newline too, this results in one extra line. Needs at least 2 lines to work: https://www.purebasic.fr/english/viewtopic.php?f=23&t=48512
    LineEnd - 1
  EndIf
  
  SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
  For index = LineStart-1 To LineEnd-1
    SetLine(index, "; " + GetLine(index))
  Next index
  SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
  
  If PartialSourceScan(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateFolding(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateProcedureList()
    UpdateVariableViewer()
  EndIf
  
  SetSelection(LineStart, 1, LineEnd, -1)
  
EndProcedure


Procedure RemoveComments()
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  GetSelection(@LineStart, 0, @LineEnd, @RowEnd)
  
  If RowEnd <= 1 And LineEnd > LineStart ; when selecting a full line, it actually selects the newline too, this results in one extra line
    LineEnd - 1
  EndIf
  
  SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
  For index = LineStart-1 To LineEnd-1
    Line$ = GetLine(index)
    
    If Left(Line$, 2) = "; " ; This is how the IDE adds it, so also remove the space
      SetLine(index, Right(Line$, Len(Line$)-2))
    ElseIf Left(LTrim(RemoveString(Line$, Chr(9))), 1) = ";" ; the first none-whitespace is a ;
      position = FindString(Line$, ";", 1)
      
      If Mid(Line$, position+1, 1) = " "
        SetLine(index, Left(Line$, position-1) + Right(Line$, Len(Line$)-(position+1))) ; remove the space as well
      Else
        SetLine(index, Left(Line$, position-1) + Right(Line$, Len(Line$)-position)) ; remove only the ;
      EndIf
    EndIf
  Next index
  SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
  
  If PartialSourceScan(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateFolding(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateProcedureList()
    UpdateVariableViewer()
  EndIf
  
  SetSelection(LineStart, 1, LineEnd, -1)
EndProcedure

Procedure InsertTab()
  
  GetSelection(@LineStart, 0, @LineEnd, @RowEnd)
  
  
  If RowEnd <= 1 ; when selecting a full line, it actually selects the newline too, this results in one extra line
    LineEnd - 1
  EndIf
  
  If RealTab
    Add$ = Chr(9)
  Else
    Add$ = Space(TabLength)
  EndIf
  
  SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
  For index = LineStart-1 To LineEnd-1
    SetLine(index, Add$ + GetLine(index))
  Next index
  SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
  
  ; This is required to update the keyword underline data
  ;
  If PartialSourceScan(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateFolding(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateProcedureList()
    UpdateVariableViewer()
  EndIf
  
  
  FlushEvents(); some event generated by the SetLine causes the selection to be lost, so flush it here
  
  SetSelection(LineStart, 1, LineEnd, -1)
  
  
EndProcedure

Procedure RemoveTab()
  
  GetSelection(@LineStart, 0, @LineEnd, @RowEnd)
  
  
  If RowEnd <= 1 ; when selecting a full line, it actually selects the newline too, this results in one extra line
    LineEnd - 1
  EndIf
  
  SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
  For index = LineStart-1 To LineEnd-1
    Line$ = GetLine(index)
    
    If Left(Line$, 1) = Chr(9)
      Line$ = Right(Line$, Len(Line$)-1)
      
    Else
      cut = 0
      For i = 1 To TabLength
        If Mid(Line$, i, 1) = " "
          cut + 1
        Else
          Break
        EndIf
      Next i
      Line$ = Right(Line$, Len(Line$)-cut)
    EndIf
    
    SetLine(index, Line$)
  Next index
  SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
  
  ; This is required to update the keyword underline data
  ;
  If PartialSourceScan(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateFolding(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateProcedureList()
    UpdateVariableViewer()
  EndIf
  
  
  FlushEvents() ; some event generated by the SetLine causes the selection to be lost, so flush it here
  
  SetSelection(LineStart, 1, LineEnd, -1)
  
EndProcedure

Procedure AutoIndent()
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  GetSelection(@LineStart, 0, @LineEnd, @RowEnd)
  
  If RowEnd <= 1 ; when selecting a full line, it actually selects the newline too, this results in one extra line
    LineEnd - 1
  EndIf
  
  SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
  UpdateIndent(LineStart-1, LineEnd-1)
  SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
  
  ; This is required to update the keyword underline data
  ;
  If PartialSourceScan(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateFolding(*ActiveSource, LineStart-1, LineEnd-1)
    UpdateProcedureList()
    UpdateVariableViewer()
  EndIf
  
  
  FlushEvents(); some event generated by the SetLine causes the selection to be lost, so flush it here
  
  SetSelection(LineStart, 1, LineEnd, -1)
EndProcedure

Procedure ShiftComments(IsRight)
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn
  EndIf
  
  GetSelection(@LineStart, 0, @LineEnd, @RowEnd)
  
  If RowEnd <= 1 ; when selecting a full line, it actually selects the newline too, this results in one extra line
    LineEnd - 1
  EndIf
  
  If LineStart < LineEnd ; must be more than one line
    
    ; collect all lines and get info about min/max positions positions
    Protected Dim Lines.s(LineEnd - LineStart)
    MinColumn = $7FFFFFFF ; large positive number
    MaxColumn = 0
    MaxCodeColumn = 0
    LineOffset = LineStart - 1
    
    For i = LineStart-1 To LineEnd-1
      Lines(i-LineOffset) = GetLine(i)
      
      Comment = GetCommentPosition(Lines(i-LineOffset))
      If Comment >= 0
        Prefix$   = Left(Lines(i-LineOffset), Comment)
        Column    = CountColumns(Prefix$)
        
        While Right(Prefix$, 1) = " " Or Right(Prefix$, 1) = Chr(9)
          Prefix$ = Left(Prefix$, Len(Prefix$)-1)
        Wend
        CodeColumn = CountColumns(Prefix$)
        
        MinColumn = Min(MinColumn, Column)
        If ((Column-1) - ((Column-1) % TabLength)) > CodeColumn
          MaxColumn = Max(MaxColumn, Column) ; ignore columns that cannot be moved left anymore
        EndIf
        MaxCodeColumn = Max(MaxCodeColumn, CodeColumn)
        
      EndIf
    Next i
    
    If MinColumn < $7FFFFFFF ; check if there even are comments
      SendEditorMessage(#SCI_BEGINUNDOACTION, 0, 0)
      
      If IsRight
        MinColumn = (MinColumn - (MinColumn % TabLength)) + TabLength
        
        For i = LineStart-1 To LineEnd-1
          Comment = GetCommentPosition(Lines(i-LineOffset))
          If Comment >= 0
            Prefix$  = Left(Lines(i-LineOffset), Comment)
            Comment$ = Right(Lines(i-LineOffset), Len(Lines(i-LineOffset))-Comment)
            Column   = CountColumns(Prefix$)
            If Column < MinColumn
              If RealTab
                SetLine(i, Prefix$ + Chr(9) + Comment$)
              Else
                SetLine(i, Prefix$ + Space(MinColumn-Column) + Comment$)
              EndIf
            EndIf
          EndIf
        Next i
        
      Else
        
        MaxColumn - 1
        MaxColumn = (MaxColumn - (MaxColumn % TabLength))
        If MaxColumn < 0
          MaxColumn = 0
        EndIf
        
        For i = LineStart-1 To LineEnd-1
          Comment = GetCommentPosition(Lines(i-LineOffset))
          If Comment >= 0
            Prefix$  = Left(Lines(i-LineOffset), Comment)
            Comment$ = Right(Lines(i-LineOffset), Len(Lines(i-LineOffset))-Comment)
            Column   = CountColumns(Prefix$)
            
            While Column > MaxColumn
              If Right(Prefix$, 1) = " "
                Prefix$ = Left(Prefix$, Len(Prefix$)-1)
                Column - 1
              ElseIf Right(Prefix$, 1) = Chr(9)
                Prefix$ = Left(Prefix$, Len(Prefix$)-1)
                Column = CountColumns(Prefix$) ; need to re-calculate the new position
              Else
                Break
              EndIf
            Wend
            
            SetLine(i, Prefix$ + Comment$)
          EndIf
        Next i
        
      EndIf
      
      SendEditorMessage(#SCI_ENDUNDOACTION, 0, 0)
      
      FlushEvents(); some event generated by the SetLine causes the selection to be lost, so flush it here
      SetSelection(LineStart, 1, LineEnd, -1)
      
    EndIf
  EndIf
  
EndProcedure

; Skip *Item, and then to the end of the line or to the next ':'
; Returns the Position within the line and modifies *Line if needed
; Returns a position in bytes!
;
Procedure BlockSelect_SkipKeyword(*Item.SourceItem, *Line.INTEGER)
  
  Column = *Item\Position + *Item\Length
  
  LineCount = SendEditorMessage(#SCI_GETLINECOUNT, 0, 0)
  Line$ = GetContinuationLine(*Line\i, @Offset)
  *Pointer.PTR = @Line$ + Offset + Column
  
  ; scan forward
  While *Pointer\c
    
    If *Pointer\c = ':' And *Pointer\c[1] = ':'
      *Pointer + 2*#CharSize ; a :: module separator
      Column + 2
      
    ElseIf *Pointer\c = ':'
      Break ; found a command separator
      
    ElseIf *Pointer\c = 13
      *Line\i + 1
      Column = 0
      *Pointer + #CharSize
      If *Pointer\c = 10
        *Pointer + #CharSize
      EndIf
      
    ElseIf *Pointer\c = 10
      *Line\i + 1
      Column = 0
      *Pointer + #CharSize
      
    ElseIf *Pointer\c = '"'
      *Pointer + #CharSize: Column + 1
      While *Pointer\c And *Pointer\c <> '"' And *Pointer\c <> 13 And *Pointer\c <> 10
        *Pointer + #CharSize: Column + 1
      Wend
      If *Pointer\c = '"'
        *Pointer + #CharSize: Column + 1
      EndIf
      
    ElseIf *Pointer\c = '~' And *Pointer\c[1] = '"'
      *Pointer + (2 * #CharSize): Column + 2
      While *Pointer\c And *Pointer\c <> '"' And *Pointer\c <> 13 And *Pointer\c <> 10
        If *Pointer\c = '\' And *Pointer\c[1] <> 13 And *Pointer\c[1] <> 10
          *Pointer + (2 * #CharSize): Column + 2
        Else
          *Pointer + #CharSize: Column + 1
        EndIf
      Wend
      If *Pointer\c = '"'
        *Pointer + #CharSize: Column + 1
      EndIf
      
    ElseIf *Pointer\c = 39 ; '
      *Pointer + #CharSize: Column + 1
      While *Pointer\c And *Pointer\c <> 39 And *Pointer\c <> 13 And *Pointer\c <> 10
        *Pointer + #CharSize: Column + 1
      Wend
      If *Pointer\c = 39
        *Pointer + #CharSize: Column + 1
      EndIf
      
    ElseIf *Pointer\c = ';'
      While *Pointer\c And *Pointer\c <> 13 And *Pointer\c <> 10
        *Pointer + #CharSize: Column + 1
      Wend
      
    Else
      *Pointer + #CharSize: Column + 1
      
    EndIf
    
  Wend
  
  If *Pointer\c = 0 And *Line\i < LineCount - 1
    ; We reached the end of the last continuation line
    ; So include the newline to have an easy way to cut the entire block
    *Line\i + 1
    ProcedureReturn 0
    
  Else
    ; We are somewhere in side the line at a ':'
    ProcedureReturn Column
    
  EndIf
  
EndProcedure

Procedure BlockSelect_AddBlock(*StartItem.SourceItem, StartLine, IncludeStart, *EndItem.SourceItem, EndLine, IncludeEnd)
  
  Line$ = GetLine(StartLine)
  If IncludeStart
    ; If the stuff before the start item is only whitespace then select the entire line
    ; The start is a block keyword, so there can be no line continuation here
    StartColumn = BytesToChars(Line$, 0, Encoding, *StartItem\Position)
    If StartColumn > 0 And RemoveString(RemoveString(Left(Line$, StartColumn), Chr(9)), " ") = ""
      StartColumn = 0
    EndIf
  Else
    ; Skip the keyword
    StartColumn = BytesToChars(Line$, 0, *ActiveSource\Parser\Encoding, BlockSelect_SkipKeyword(*StartItem, @StartLine))
  EndIf
  
  Line$ = GetLine(EndLine)
  If IncludeEnd
    ; Skip the keyword
    EndColumn = BytesToChars(Line$, 0, *ActiveSource\Parser\Encoding, BlockSelect_SkipKeyword(*EndItem, @EndLine))
  Else
    ; If the stuff before the end item is only whitespace then select only the previous line
    ; The start is a block keyword, so there can be no line continuation here
    EndColumn = BytesToChars(Line$, 0, Encoding, *EndItem\Position)
    If EndLine > 0 And RemoveString(RemoveString(Left(Line$, EndColumn), Chr(9)), " ") = ""
      EndLine - 1
      EndColumn = SendEditorMessage(#SCI_LINELENGTH, EndLine, 0)
    EndIf
  EndIf
  
  StartPosition = SendEditorMessage(#SCI_POSITIONFROMLINE, StartLine, 0) + StartColumn
  EndPosition   = SendEditorMessage(#SCI_POSITIONFROMLINE, EndLine, 0) + EndColumn
  
  ; Only add a stack element if it is different from the previous one!
  ;
  If ListSize(BlockSelectionStack()) = 0 Or BlockSelectionStack()\StartPosition <> StartPosition Or BlockSelectionStack()\EndPosition <> EndPosition
    AddElement(BlockSelectionStack())
    BlockSelectionStack()\StartPosition = StartPosition
    BlockSelectionStack()\EndPosition = EndPosition
  EndIf
  
EndProcedure

Procedure BlockSelect_BuildStack()
  
  StartPosition = SendEditorMessage(#SCI_GETSELECTIONSTART, 0, 0)
  EndPosition   = SendEditorMessage(#SCI_GETSELECTIONEND, 0, 0)
  
  ; The lowest element is the current selection
  ClearList(BlockSelectionStack())
  AddElement(BlockSelectionStack())
  BlockSelectionStack()\StartPosition = StartPosition
  BlockSelectionStack()\EndPosition = EndPosition
  
  ; look for blocks
  Line   = SendEditorMessage(#SCI_LINEFROMPOSITION, StartPosition, 0)
  Column = StartPosition - SendEditorMessage(#SCI_POSITIONFROMLINE, Line, 0)
  
  StartLine = Line
  *StartItem.SourceItem = ClosestSourceItem(@*ActiveSource\Parser, @StartLine, Column)
  IncludeSelf = #True
  
  While FindBlockStart(@*ActiveSource\Parser, @StartLine, @*StartItem, IncludeSelf)
    
    ; Look forward to the next match for this item
    NextLine = StartLine
    *NextItem.SourceItem = *StartItem
    If MatchKeywordForward(@*ActiveSource\Parser, @NextLine, @*NextItem) And *NextItem
      
      ; add a stack element for the 'inner' part of this block
      BlockSelect_AddBlock(*StartItem, StartLine, #False, *NextItem, NextLine, #False)
      
      If BackwardMatches(*StartItem\Keyword, 0) > 0
        ; This must be a middle keyword like 'ElseIf'
        ; add a stack element for the block including the 'ElseIf' statement
        BlockSelect_AddBlock(*StartItem, StartLine, #True, *NextItem, NextLine, #False)
        
        ; Move back to the actual start statement (i.e. the 'If')
        While BackwardMatches(*StartItem\Keyword, 0) > 0
          If MatchKeywordBackward(@*ActiveSource\Parser, @StartLine, @*StartItem) = #False Or *StartItem = 0
            ; something is messed up here
            ; Since we have no start item to work with anymore, we completely abort the whole thing
            ProcedureReturn
          EndIf
        Wend
      EndIf
      
      ; match forward to the end of the block
      While ForwardMatches(*NextItem\Keyword, 0) > 0
        If MatchKeywordForward(@*ActiveSource\Parser, @NextLine, @*NextItem) = #False Or *NextItem = 0
          ; something is messed up here. skip this block and continue the outer look
          *NextItem = 0
          Break
        EndIf
      Wend
      
      If *NextItem
        ; add a stack element for the whole IF/ElseIf/EndIf block (outer bounds)
        BlockSelect_AddBlock(*StartItem, StartLine, #True, *NextItem, NextLine, #True)
      EndIf
      
    EndIf
    
    ; For the next lookup, do not include the *StartItem in the search anymore
    IncludeSelf = #False
  Wend
  
EndProcedure

Procedure SelectBlock()
  If *ActiveSource And *ActiveSource <> *ProjectInfo And *ActiveSource\IsCode
    
    ; We build the full stack of all possible block selections from the current location first
    ; and then just move up/down this stack later with SelectBlock()/DeselectBlock()
    ;
    ; This avoids ambiguities which block to select which would happen if we tried to find the
    ; next block each time from the current selection
    ;
    If ListSize(BlockSelectionStack()) = 0
      BlockSelect_BuildStack()
      FirstElement(BlockSelectionStack()) ; go to the element representing the current selection
    EndIf
    
    ; move up the stack if there is another possible block to select
    ;
    If  NextElement(BlockSelectionStack())
      FlushEvents() ; some event causes this to not work! (dirty hack)
      
      BlockSelectionUpdated = #True ; don't clear the stack in the scintilla callback
      
      ; Swap the two positions. This causes the SCI_SETSEL message to put the caret at the block
      ; start and scroll it into view. This is generally more helpful than seeing the block end
      SendEditorMessage(#SCI_SETSEL, BlockSelectionStack()\EndPosition, BlockSelectionStack()\StartPosition)
      UpdateCursorPosition()
      
      ; scroll a bit if the selection start is now in the first line in view
      If SendEditorMessage(#SCI_DOCLINEFROMVISIBLE, SendEditorMessage(#SCI_GETFIRSTVISIBLELINE, 0, 0)) = SendEditorMessage(#SCI_LINEFROMPOSITION, BlockSelectionStack()\StartPosition)
        SendEditorMessage(#SCI_LINESCROLL, 0, -3)
      EndIf
    EndIf
    
  EndIf
EndProcedure

Procedure DeselectBlock()
  If *ActiveSource And *ActiveSource <> *ProjectInfo And *ActiveSource\IsCode
    
    ; Move down the stack (if possible). The lowest element is the original selection
    If PreviousElement(BlockSelectionStack())
      FlushEvents() ; some event causes this to not work! (dirty hack)
      
      BlockSelectionUpdated = #True ; don't clear the stack in the scintilla callback
      If ListIndex(BlockSelectionStack()) = 0
        ; no swapping here. restore the original selection
        SendEditorMessage(#SCI_SETSEL, BlockSelectionStack()\StartPosition, BlockSelectionStack()\EndPosition)
      Else
        ; swap like in the SelectBlock() function
        SendEditorMessage(#SCI_SETSEL, BlockSelectionStack()\EndPosition, BlockSelectionStack()\StartPosition)
      EndIf
      UpdateCursorPosition()
    EndIf
    
  EndIf
EndProcedure

; Check if the given prefix string ends in the middle of a string, character constant or comment
; Returns
;   0 = no string or comment
;   1 = comment
;   2 = string
;   3 = char const
;
Procedure IsCommentOrString(Prefix$)
  
  *Cursor.Character = @Prefix$
  
  Repeat
    Select *Cursor\c
        
      Case 0
        ; not inside anything
        ProcedureReturn 0
        
      Case ';'
        ; comment
        ProcedureReturn 1
        
      Case '"'
        ; regular string
        *Cursor + #CharSize
        While *Cursor\c <> '"'
          If *Cursor\c = 0
            ProcedureReturn 2
          Else
            *Cursor + #CharSize
          EndIf
        Wend
        *Cursor + #CharSize
        
      Case 39
        ; char constant
        *Cursor + #CharSize
        While *Cursor\c <> 39
          If *Cursor\c = 0
            ProcedureReturn 3
          Else
            *Cursor + #CharSize
          EndIf
        Wend
        *Cursor + #CharSize
        
      Case '~'
        *Cursor + #CharSize
        If *Cursor\c = '"'
          ; escaped string
          *Cursor\c + #CharSize
          While *Cursor\c <> '"'
            If *Cursor\c = 0
              ProcedureReturn 2
            ElseIf *Cursor\c = '\'
              *Cursor + #CharSize
              If *Cursor\c = 0
                ProcedureReturn 2 ; check for prefix end right after the \
              EndIf
              *Cursor + #CharSize ; skip second char, even if sequence is invalid (all we care about is \" here)
            Else
              *Cursor + #CharSize
            EndIf
          Wend
          *Cursor\c + #CharSize
        EndIf
        
      Default
        ; any other char
        *Cursor + #CharSize
        
    EndSelect
  ForEver
EndProcedure

Procedure CheckSearchStringComment(line, column, IsAutoComplete) ; line & column are 0 based!
  
  Result = IsCommentOrString(Left(GetLine(line), column))
  
  If IsAutoComplete
    If Result > 1 And AutoCompleteNoStrings
      ProcedureReturn 0
    ElseIf Result = 1 And AutoCompleteNoComments
      ProcedureReturn 0
    Else
      ProcedureReturn 1
    EndIf
    
  Else
    If Result > 1 And FindNoStrings
      ProcedureReturn 0
    ElseIf Result = 1 And FindNoComments
      ProcedureReturn 0
    Else
      ProcedureReturn 1
    EndIf
    
  EndIf
  
EndProcedure


; Checks if given cursor pos is inside a string or comment
;
Procedure CheckStringComment(Cursor)
  
  line      = SendEditorMessage(#SCI_LINEFROMPOSITION, Cursor, 0)
  linestart = SendEditorMessage(#SCI_POSITIONFROMLINE, line, 0)
  position  = CountCharacters(*ActiveSource\EditorGadget, linestart, Cursor)
  
  Result = IsCommentOrString(Left(GetLine(line), position))
  
  If Result > 0
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure FindQuickHelpFromSorted(*Parser.ParserData, Word$, List ModuleNames.s())
  
  ForEach ModuleNames()
    
    *Module.SortedModule = *Parser\Modules(UCase(ModuleNames()))
    If *Module
      
      ; macros go first
      *Item.SourceItem = RadixLookupValue(*Module\Sorted\Macros, Word$)
      If *Item
        ProcedureReturn *Item
      EndIf
      
      *Item.SourceItem = RadixLookupValue(*Module\Sorted\Procedures, Word$)
      If *Item
        ProcedureReturn *Item
      EndIf
      
      *Item.SourceItem = RadixLookupValue(*Module\Sorted\Declares, Word$)
      If *Item
        ProcedureReturn *Item
      EndIf
      
      *Item.SourceItem = RadixLookupValue(*Module\Sorted\Imports, Word$)
      If *Item
        ProcedureReturn *Item
      EndIf
      
    EndIf
    
  Next ModuleNames()
  
  ProcedureReturn 0
EndProcedure

Procedure.s GenerateQuickHelpFromWord(Line$, Word$, line, Column)
  Static LastWord$, LastText$, LastLine, *LastActiveSource ; position is the word start, not cursor
  
  ; We do some caching here, as looking at all open sources
  ; is quite costly especially with many open files, and this function
  ; is called a lot with the same Word$, while the cursor moves around
  ; inside a Procedure etc.
  ;
  ; The caching cannot be done inside QuickHelpFromLine(), because
  ; we always have to analyse the line to know what word we are at.
  ;
  ; QuickHelpFromLine() does determine whether caching can be done though too,
  ; as we can only use the cached value if the line did not get edited,
  ; even if the word is the same (see QuickHelpFromLine())
  ;
  If *LastActiveSource = *ActiveSource And LastLine = line And Word$ = LastWord$
    ProcedureReturn LastText$
  Else
    *LastActiveSource = *ActiveSource
    LastLine          = line
    LastWord$         = Word$
  EndIf
  
  If IsAPIFunction(ToAscii(Word$), Len(Word$)) <> -1
    index = IsAPIFunction(ToAscii(Word$), Len(Word$))
    Text$ = APIFunctions(index)\Name$+"_"
    If APIFunctions(index)\Proto$
      Text$ + APIFunctions(index)\Proto$
    Else
      Text$ + "() - " + Language("Misc","NoQuickHelp")
    EndIf
    
  ElseIf IsBasicFunction(UCase(Word$)) <> -1
    index = IsBasicFunction(UCase(Word$))
    Text$ = BasicFunctions(index)\Name$
    If BasicFunctions(index)\Proto$
      Text$ + BasicFunctions(index)\Proto$
    Else
      Text$ + "()"
    EndIf
    
  ElseIf Left(Word$, 1) <> "#" ; ignore constants here
    
    ; Generate the sorted index for the active source
    ; does nothing if the data is already indexed
    SortParserData(@*ActiveSource\Parser, *ActiveSource)
    
    *Item.SourceItem = 0
    
    ; find out if we are inside a module and find the open modules
    Protected NewList ModuleNames.s()
    ModuleStartLine = line
    *ModuleStart.SourceItem = ClosestSourceItem(@*ActiveSource\Parser, @ModuleStartLine, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, Column))
    If *ModuleStart And *ModuleStart\ModulePrefix$ <> ""
      AddElement(ModuleNames())
      ModuleNames() = *ModuleStart\ModulePrefix$ ; only look at this one module
    ElseIf *ModuleStart And FindModuleStart(@*ActiveSource\Parser, @ModuleStartLine, @*ModuleStart, ModuleNames())
      AddElement(ModuleNames())
      ModuleNames() = *ModuleStart\Name$
      If *ModuleStart\Type = #ITEM_Module
        AddElement(ModuleNames())
        ModuleNames() = "IMPL::" + *ModuleStart\Name$
      EndIf
    Else
      AddElement(ModuleNames())
      ModuleNames() = "" ; main module
    EndIf
    
    ; check add ActiveSource items
    *Item = FindQuickHelpFromSorted(@*ActiveSource\Parser, Word$, ModuleNames())
    
    ; check project sources
    If *Item = 0 And *ActiveSource\ProjectFile
      ForEach ProjectFiles()
        If ProjectFiles()\Source = 0
          *Item = FindQuickHelpFromSorted(@ProjectFiles()\Parser, Word$, ModuleNames())
        ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *ActiveSource
          *Item = FindQuickHelpFromSorted(@ProjectFiles()\Source\Parser, Word$, ModuleNames())
        EndIf
        
        If *Item
          Break
        EndIf
      Next ProjectFiles()
    EndIf
    
    ; check other open sources
    If *Item = 0
      ForEach FileList()
        If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And FileList()\ProjectFile = 0
          *Item = FindQuickHelpFromSorted(@FileList()\Parser, Word$, ModuleNames())
          If *Item
            Break
          EndIf
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource) ; important!
    EndIf
    
    If *Item
      If *Item\Type = #ITEM_Macro
        Text$ = *Item\Name$ + *Item\Prototype$
        
      ElseIf *Item\Type = #ITEM_Import
        Text$ = *Item\Name$ + StringField(*Item\Type$, 2, Chr(10))
        
      ElseIf *Item\Prototype$ = ""
        Text$ = *Item\Name$ + "()"
        
      ElseIf FindString(*Item\Type$, Chr(10), 1)
        ; this is for Imports that are marked #ITEM_UnknownBraced (its like this in loaded sources)
        Text$ = *Item\Name$ + StringField(*Item\Type$, 2, Chr(10))
        
      Else
        Text$ = *Item\Name$ + *Item\Prototype$
        
      EndIf
    EndIf
    
  EndIf
  
  
  LastText$ = Text$
  ProcedureReturn Text$
EndProcedure

; Generate the quick help text for a structured item (prototype or interface)
;
Procedure.s GenerateQuickHelpFromStructure(Word$, *BaseItem.SourceItem, BaseItemLine, List Stack.s())
  Message$ = ""
  
  If *BaseItem\Type = #ITEM_Variable Or *BaseItem\Type = #ITEM_Array Or *BaseItem\Type = #ITEM_LinkedList Or *BaseItem\Type = #ITEM_Map Or *BaseItem\Type = #ITEM_UnknownBraced
    
    ; resolve the type to know the structure
    ;
    Type$ = ResolveItemType(*BaseItem, BaseItemLine, @OutType.i)
    If Type$ And (OutType = #ITEM_Variable Or OutType = #ITEM_Array Or OutType = #ITEM_LinkedList Or OutType = #ITEM_Map)
      
      ; walk the structure stack to resolve subitems (all must be resolvable)
      ;
      ForEach Stack()
        Subitem$ = Stack()
        SubitemFound = 0
        
        ; Can only be a structure here, because Word$ is our final sublevel,
        ; and interfaces/prototypes have no further subitems
        ClearList(QuickHelpStructureList())
        If FindStructure(Type$, QuickHelpStructureList())
          
          ; process the items
          ForEach QuickHelpStructureList()
            Entry$ = StructureFieldName(QuickHelpStructureList())
            If Subitem$ And CompareMemoryString(@Subitem$, @Entry$, #PB_String_NoCaseAscii) = #PB_String_Equal
              ; on to the next stack item
              Type$ = StructureFieldType(QuickHelpStructureList())
              SubitemFound = 1
              Break
            EndIf
          Next QuickHelpStructureList()
        EndIf
        
        ; There was a mismatch in the subitem chain. There is nothing to display then
        If SubitemFound = 0
          ProcedureReturn ""
        EndIf
      Next Stack()
      
      ; Now we have the final type of the nested structure level, look for our word
      ;
      ClearList(QuickHelpStructureList())
      
      If FindStructure(Type$, QuickHelpStructureList())
        ForEach QuickHelpStructureList()
          Entry$     = StructureFieldName(QuickHelpStructureList())
          EntryType$ = StructureFieldType(QuickHelpStructureList())
          If CompareMemoryString(@Word$, @Entry$, #PB_String_NoCaseAscii) = #PB_String_Equal
            ; Its a structure, so the item must have a prototype as type, else it cannot be with arguments
            *ProtoItem.SourceItem = FindPrototype(EntryType$)
            If *ProtoItem And *ProtoItem\Prototype$
              If FindString(EntryType$, "::")
                EntryType$ = StringField(EntryType$, 2, "::") ; remove any module prefix from the type
              EndIf
              Message$ = EntryType$ + *ProtoItem\Prototype$ ; add the prototype name only if something was found!
            EndIf
            Break
          EndIf
        Next QuickHelpStructureList()
        
      ElseIf FindInterface(Type$, QuickHelpStructureList())
        ForEach QuickHelpStructureList()
          Entry$ = InterfaceFieldName(QuickHelpStructureList())
          Proto$ = Trim(Right(QuickHelpStructureList(), Len(QuickHelpStructureList())-(FindString(QuickHelpStructureList(), "(", 1)-1)))
          
          If CompareMemoryString(@Word$, @Entry$, #PB_String_NoCaseAscii) = #PB_String_Equal
            Message$ = Entry$ + Proto$ ; use only Name+Prototype, no return type
            Break
          EndIf
        Next QuickHelpStructureList()
        
      EndIf
      
    EndIf
  EndIf
  
  ProcedureReturn Message$
EndProcedure

Procedure.s GenerateQuickHelpText(Line$, Word$, Line, Column)
  
  ; For the structure and prototype check we must ensure that the line data is up to date
  ;
  If ScanLine(*ActiveSource, line)
    UpdateFolding(*ActiveSource, line-1, line+2)
    *ActiveSource\ParserDataChanged = #True  ; defere any updating to when the current line changes
  EndIf
  
  ; Check if it is a structured item first
  ;
  If Column > 0
    BaseItemLine = line
    If LocateStructureBaseItem(Line$, Column-1, @*BaseItem.SourceItem, @BaseItemLine, QuickHelpStructureStack())
      ProcedureReturn GenerateQuickHelpFromStructure(Word$, *BaseItem, BaseItemLine, QuickHelpStructureStack())
    EndIf
  EndIf
  
  ; Now check if it is a prototype'd variable
  ;
  *Item.SourceItem = LocateSourceItem(@*ActiveSource\Parser, line, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, Column))
  If *Item
    ; Array, List, Map cannot hold Prototypes directly (only in structures)
    Type$ = ResolveItemType(*Item, line, @OutType.i)
    If Type$ And OutType = #ITEM_Variable
      *ProtoItem.SourceItem = FindPrototype(Type$)
      If *ProtoItem And *ProtoItem\Prototype$
        ProcedureReturn *ProtoItem\Name$ + *ProtoItem\Prototype$
      EndIf
    EndIf
  EndIf
  
  ; Use the old routine to check for PB functions and other stuff
  ;
  ProcedureReturn GenerateQuickHelpFromWord(Line$, Word$, line, Column)
EndProcedure

; Find enclosing function (or array) from the given cursor position (0 based)
;
; Returns function name or empty string if not inside any
; *StartPosition\i will be the position of the function name in Line$ (0 based)
; *Parameter\i will be the parameter index in the function (1 based)
;
Procedure.s FindEnclosingFunction(Line$, Cursor, *StartPosition.INTEGER, *Parameter.INTEGER)
  
  ScanLine$ = UCase(Left(Line$, Cursor)) ; cut everything after the current position
  
  Stack = 0
  ClearStructure(@QuickHelpStack(0), QuickHelpStack)
  
  *LineStart    = ToAscii(ScanLine$)
  *Pointer.Ascii = *LineStart
  FoundChar = #False
  
  While *Pointer\a
    
    ; detect inline ASM/JS lines
    If FoundChar = #False
      If *Pointer\a = '!'
        ChangeStatus("", 0)
        ProcedureReturn
      ElseIf *Pointer\a <> ' ' And *Pointer\a <> 9
        ; non-whitespace means it cannot be inline code
        FoundChar = #True
      EndIf
    EndIf
    
    If *Pointer\a = ';'
      If Not IsLineContinuation(*LineStart, *Pointer) ; comment ends all this.
        ChangeStatus("", 0)
        ProcedureReturn
      EndIf
      
      ; comment after continuation, so skip comment
      While *Pointer\a And *Pointer\a <> 13 And *Pointer\a <> 10
        *Pointer + 1
      Wend
      
    ElseIf *Pointer\a = '"' ; ignore strings
      *Pointer + 1
      While *Pointer\a And *Pointer\a <> '"'
        *Pointer + 1
      Wend
      If *Pointer\a
        *Pointer + 1
      EndIf
      
    ElseIf *Pointer\a = '~' And PeekA(*Pointer + 1) = '"' ; ignore escapedstrings
      *Pointer + 2
      While *Pointer\a And *Pointer\a <> '"'
        If *Pointer\a = '\' And PeekA(*Pointer + 1) <> 0
          *Pointer + 2
        Else
          *Pointer + 1
        EndIf
      Wend
      If *Pointer\a
        *Pointer + 1
      EndIf
      
    ElseIf *Pointer\a = 39 ; ignore char const
      *Pointer + 1
      While *Pointer\a And *Pointer\a <> 39
        *Pointer + 1
      Wend
      If *Pointer\a
        *Pointer + 1
      EndIf
      
    ElseIf *Pointer\a = '('
      If Stack < 200
        Stack + 1
        ClearStructure(@QuickHelpStack(Stack), QuickHelpStack)
      EndIf
      *Pointer + 1
      
    ElseIf *Pointer\a = ')'
      If Stack > 0
        Stack - 1
        QuickHelpStack(Stack)\Word$ = ""
      EndIf
      *Pointer + 1
      
    ElseIf *Pointer\a = ','
      QuickHelpStack(Stack)\Word$ = ""
      QuickHelpStack(Stack)\Parameter + 1
      *Pointer + 1
      
    ElseIf ValidCharacters(*Pointer\a)
      *Start = *Pointer
      While ValidCharacters(*Pointer\a)
        *Pointer + 1
      Wend
      QuickHelpStack(Stack)\Word$ = PeekAsciiLength(*Start, *Pointer-*Start)
      QuickHelpStack(Stack)\Position = *Start-*LineStart
      
    ElseIf *Pointer\a <> ' ' And *Pointer\a <> 9
      QuickHelpStack(Stack)\Word$ = ""
      *Pointer + 1
      
    Else
      *Pointer + 1
      
    EndIf
    
  Wend
  
  Stack - 1 ; the last stack position is the inside of the () if any
  
  While Stack > 0 And QuickHelpStack(Stack)\Word$ = ""  ; go back all empty spaces
    Stack - 1                                           ; Example: Function( ( ( ...
  Wend
  
  If Stack >= 0 And QuickHelpStack(Stack)\Word$ <> ""
    *StartPosition\i = QuickHelpStack(Stack)\Position
    *Parameter\i = QuickHelpStack(Stack+1)\Parameter + 1 ; the argument index is +1 in the stack (because they are inside the '(' )
    ProcedureReturn QuickHelpStack(Stack)\Word$
  Else
    *StartPosition\i = 0
    *Parameter\i = 0
    ProcedureReturn ""
  EndIf
EndProcedure


Procedure QuickHelpFromLine(line, cursorposition) ; position is 0 based!
  Shared StatusMessageTimeout.q                   ; shared for the special access in QuickHelpFromLine()
  
  If *ActiveSource\IsCode = 0
    ChangeStatus("", 0)
    ProcedureReturn
  EndIf
  
  Line$ = GetContinuationLine(line, @StartOffset)
  cursorposition + StartOffset
  
  If cursorposition > Len(Line$) ; something is wrong here
    ProcedureReturn
  EndIf
  
  EnclosingFunction$ = FindEnclosingFunction(Line$, cursorposition, @FunctionStart, @Argument)

  If EnclosingFunction$ <> ""
    Message$ = GenerateQuickHelpText(Line$, EnclosingFunction$, line, FunctionStart)
    
    If Message$ = "" Or FindString(Message$, "(", 1) = 0 Or FindString(Message$, ")", 1) = 0
      ChangeStatus(Message$, 0)
      
    Else
      ; now we check for the argument under the cursor to mark it...
      
      ; we need to find the end of the function prototype.
      ; as both inside the prototype (for linkedlists) and in the comment, there can be '( )', a simple findstring does not work.
      ;
      Test$ = Message$ ; make a copy, so we can block out strings for later FindString()
      position = FindString(Test$, "(", 1)
      length = Len(Message$)
      depth = 1
      *Cursor.Character = @Test$ + (position-1) * SizeOf(Character)
      
      While depth > 0 And position <= length And *Cursor\c
        position + 1
        *Cursor + SizeOf(Character)
        
        Select *Cursor\c
            
          Case '"' ; ignore strings
            Repeat
              *Cursor\c = ' ' ; block out string content so "," get ignored in strings below
              position + 1
              *Cursor + SizeOf(Character)
            Until *Cursor\c = '"' Or *Cursor\c = 0 ; string end
            
          Case '~' ; ignore escaped strings
            position + 1
            *Cursor + SizeOf(Character)
            If *Cursor\c = '"'
              *Cursor\c = ' ' ; block out string content so "," get ignored in strings below
              position + 1
              *Cursor + SizeOf(Character)
              
              While *Cursor\c And *Cursor\c <> '"'
                If *Cursor\c = '\' And PeekC(*Cursor + SizeOf(Character)) <> 0
                  *Cursor\c = ' '
                  *Cursor + SizeOf(Character)
                  *Cursor\c = ' '
                  *Cursor + SizeOf(Character)
                  position + 2
                Else
                  *Cursor\c = ' '
                  position + 1
                  *Cursor + SizeOf(Character)
                EndIf
              Wend
              
              If *Cursor\c = '"'
                *Cursor\c = ' '
                position + 1
                *Cursor + SizeOf(Character)
              EndIf
            EndIf
            
          Case 39 ; ignore char constants
            Repeat
              *Cursor\c = ' ' ; block out string content so "," get ignored in strings below
              position + 1
              *Cursor + SizeOf(Character)
            Until *Cursor\c = 39 Or *Cursor\c = 0
            
          Case '('
            depth + 1
            
          Case ')'
            depth - 1
            
        EndSelect
      Wend
      
      Test$ = Left(Test$, position-1) ; ignore the description part (Test$ now has all strings blocked out)
      
      If Right(RTrim(Test$), 1) = "(" ; the function had no parameters '()'
        ChangeStatus(Message$, 0)
        
      Else
        
        position = FindString(Test$, "(", 1)
        While Argument > 1 And position <> 0
          position = FindString(Test$, ",", position+1)
          Argument - 1
        Wend
        
        If position = 0 ; something did not match here!
          ChangeStatus(Message$, 0)
          
        Else
          Endposition = FindString(Test$, ",", position+1)
          If Endposition = 0
            Endposition = Len(Test$)+1
          EndIf
          
          ; only make the word bold, not and "," or "[" for optional parameters
          While Mid(Message$, position+1, 1) = " " Or Mid(Message$, position+1, 1) = "," Or Mid(Message$, position+1, 1) = "[" Or Mid(Message$, position+1, 1) = "]"
            position + 1
          Wend
          While Mid(Message$, endposition-1, 1) = " " Or Mid(Message$, endposition-1, 1) = "," Or Mid(Message$, endposition-1, 1) = "[" Or Mid(Message$, endposition-1, 1) = "]"
            Endposition - 1
          Wend
          
          ; on windows, we make the thing ownerdrawn to draw the current argument in bold
          ;
          CompilerIf #CompileWindows
            Shared StatusBarOwnerDrawText$
            
            If EnableAccessibility
              
              ; Do not ownerdraw to make it better readable by screen readers
              Message$ = Left(Message$, position) + "   => " + Mid(Message$, position+1, Endposition-position-1) + " <=   " + Right(Message$, Len(Message$)-Endposition+1)
              ChangeStatus(Message$, 0)
              
            Else
            
              time.q = ElapsedMilliseconds()
              
              If StatusMessageTimeout < time
                StatusMessageTimeout = 0
                StatusBarOwnerDrawText$ = Message$
                SendMessage_(*MainStatusBar, #SB_SETTEXT, 1|#SBT_NOBORDERS|#SBT_OWNERDRAW, position | Endposition<<16)
              EndIf
            
            EndIf
            
          CompilerElse
            
            CompilerIf #CompileLinuxGtk
              
              ; On Gtk2, we can use Pango markup to put bold text in a GtkLabel.. quite cool :)
              ;
              time.q = ElapsedMilliseconds()
              
              If StatusMessageTimeout < time
                StatusMessageTimeout = 0
                Message$ = Left(Message$, position) + "<b>" + Mid(Message$, position+1, Endposition-position-1) + "</b>" + Right(Message$, Len(Message$)-Endposition+1)
                
                ; find the label to set the text...
                FrameList = gtk_container_get_children_(StatusBarID(#STATUSBAR))
                If FrameList
                  Frame = g_list_nth_data_(FrameList, 1) ; the text field is field 1
                  If Frame
                    LabelList = gtk_container_get_children_(Frame)
                    If LabelList
                      Label = g_list_nth_data_(LabelList, 0)
                      
                      If Label ; found it
                        gtk_label_set_markup_(Label, ToAscii(Message$))
                      EndIf
                      
                      g_list_free_(LabelList)
                    EndIf
                  EndIf
                  g_list_free_(FrameList)
                EndIf
                
              EndIf
              
            CompilerElse
              
              ; on the other systems we mark the current argument with text arrows
              Message$ = Left(Message$, position) + "   => " + Mid(Message$, position+1, Endposition-position-1) + " <=   " + Right(Message$, Len(Message$)-Endposition+1)
              ChangeStatus(Message$, 0)
              
            CompilerEndIf
            
          CompilerEndIf
          
        EndIf
        
      EndIf
      
    EndIf
  Else
    
    Message$ = ""
    
    If GetWordBoundary(@Line$, Len(Line$), cursorposition, @StartIndex, @EndIndex, 0)
      If EndIndex-StartIndex+1 > 0
        Word$ = PeekS(@Line$+StartIndex * #CharSize, EndIndex-StartIndex+1)
        Message$ = GenerateQuickHelpText(Line$, Word$, line, StartIndex)
      EndIf
    EndIf
    
    ChangeStatus(Message$, 0)
    
  EndIf
  
EndProcedure


; This is the same idea as base 64, but not the same, as directly the line states
; are encoded like this
#EncodingChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+-"

Procedure.s CreateFoldingInformation()
  
  If *ActiveSource\IsCode = 0
    ProcedureReturn ""
  EndIf
  
  foldpoints = 0
  count = GetLinesCount(*ActiveSource)
  Output$ = ""
  bit = 0
  value = %111111 ; the default is "expanded", so that when somebody with more foldpoints set does not view this code with all folds closed
  
  For i = 0 To count-1
    If IsFoldPoint(i)
      foldpoints + 1
      
      If GetFoldState(i) = 0
        value & ~(1<<bit) ; clear the expanded state for this bit
      EndIf
      bit + 1
      
      If bit = 6  ; 6bit number = 64 max
        Output$ + Mid(#EncodingChars, value+1, 1)
        value = %111111
        bit = 0
      EndIf
    EndIf
  Next i
  
  Output$ + Mid(#EncodingChars, value+1, 1)
  
  If foldpoints = 0
    ProcedureReturn "" ; else it returns a single "-" (from the default value) which we do not want to save
  Else
    ProcedureReturn Output$
  EndIf
EndProcedure

Procedure DecodeNextLineState(Input$)
  Static Buffer$, value, bit
  
  If Input$ <> ""   ; this sets the internal buffer (start of decoding)
    Buffer$ = Input$
    For i = 1 To 255
      If FindString(#EncodingChars, Chr(i), 1) = 0  ; remove any non encoding chars from the buffer
        Buffer$ = RemoveString(Buffer$, Chr(i))
      EndIf
    Next i
    bit = 6
    
    ProcedureReturn 0
  Else
    
    If bit >= 6
      If Len(Buffer$) = 0
        ProcedureReturn 1 ; expanded is the default state if the user has more foldpoints than were saved in the file
      Else
        value   = FindString(#EncodingChars, Left(Buffer$, 1), 1) - 1
        Buffer$ = Right(Buffer$, Len(Buffer$)-1)
        bit     = 0
      EndIf
    EndIf
    
    If value & (1<<bit)
      result = 1
    Else
      result = 0
    EndIf
    
    bit + 1
    ProcedureReturn result
  EndIf
  
EndProcedure

Procedure ApplyFoldingInformation(Folding$)
  
  If Folding$ <> "" And *ActiveSource\IsCode
    
    count = GetLinesCount(*ActiveSource)
    DecodeNextLineState(Folding$) ; set the decode buffer
    
    openfolds = 0
    closefolds = 0
    
    For i = 0 To count-1
      If IsFoldPoint(i)
        state = DecodeNextLineState("")
        If state
          openfolds + 1
        Else
          closefolds + 1
        EndIf
        SetFoldState(i, state)
      EndIf
    Next i
    
    If openfolds > closefolds
      *ActiveSource\ToggleFolds = 1
    Else
      *ActiveSource\ToggleFolds = 0
    EndIf
    
  EndIf
  
EndProcedure


