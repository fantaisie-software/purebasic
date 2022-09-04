; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Implementation of the Myers Diff algorithm with the linear space refinement specified in
; "An O(ND) Difference Algorithm and Its Variations" -- Algorithmica 1, 2 (1986), 251-266.
; See here: http://www.xmailserver.org/diff2.pdf
;
; A useful tutorial with code examples:
;   https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/
;   https://blog.jcoglan.com/2017/02/15/the-myers-diff-algorithm-part-2/
;   https://blog.jcoglan.com/2017/02/17/the-myers-diff-algorithm-part-3/
;   https://blog.jcoglan.com/2017/03/22/myers-diff-in-linear-space-theory/
;   https://blog.jcoglan.com/2017/04/25/myers-diff-in-linear-space-implementation/
;
; A very useful tutorial and graphical tool to visualize the algorithm:
;   http://simplygenius.net/Article/DiffTutorial1
;   http://simplygenius.net/Article/DiffTutorial2
;


; Compute checksum of a line depending on the given Flags
;
Procedure Diff_ComputeChecksum(*Start, Length, Flags)

  If Length = 0
    ProcedureReturn 0
    
  ElseIf Flags = 0
    ProcedureReturn CRC32Fingerprint(*Start, Length)
    
  Else
    ; need to get a string to apply further options first
    ;
    Protected Line$ = PeekS(*Start, Length, #PB_Ascii) ; ok for ascii and utf8, as we just need a checksum and no content

    If Flags & #DIFF_IgnoreCase
      Line$ = LCase(Line$)
    EndIf
    
    If Flags & #DIFF_IgnoreSpaceAll
      Line$ = Trim(ReplaceString(Line$, Chr(9), " ")) ; convert tab, remove space on sides
      
      ; collapse any multiple space to single ones, so we have only significant spaces left
      While FindString(Line$, "  ", 1)
        Line$ = ReplaceString(Line$, "  ", " ")
      Wend
      
    Else
      If Flags & #DIFF_IgnoreSpaceLeft
        While Left(Line$, 1) = " " Or Left(Line$, 1) = Chr(9) ; simple trim is not enough here
          Line$ = Right(Line$, Len(Line$)-1)
        Wend
      EndIf
      
      If Flags & #DIFF_IgnoreSpaceRight
        While Right(Line$, 1) = " " Or Right(Line$, 1) = Chr(9)
          Line$ = Left(Line$, Len(Line$)-1)
        Wend
      EndIf
    EndIf
    
    If Len(Line$) = 0
      ProcedureReturn 0
    Else
      ; No need to convert back to Ascii. Just compute the hash of the unicode line
      ProcedureReturn CRC32Fingerprint(@Line$, StringByteLength(Line$))
    EndIf
  EndIf
  
EndProcedure

; Scan a file and fill the lines array
;
Procedure Diff_PreProcess(*Pointer.Byte, Size, Array Lines.DiffLine(1), Flags)
  Protected *BufferEnd = *Pointer + Size
  
  Protected Lines = 0
  Protected Space = ArraySize(Lines()) ; don't do +1 to have the extra space for the last line
  
  Protected *LineStart = *Pointer
  While *Pointer < *BufferEnd
    
    ; detect next newline
    If *Pointer\b = 13
      *Pointer + 1
      If *Pointer < *BufferEnd And *Pointer\b = 10
        *Pointer + 1
      EndIf
    ElseIf *Pointer\b = 10
      *Pointer + 1
    Else
      ; no newline
      *Pointer + 1
      Continue
    EndIf
    
    ; newline found
    If Space = 0
      ReDim Lines(Lines * 2)
      Space = Lines
    EndIf
    
    Lines(Lines)\Checksum = Diff_ComputeChecksum(*LineStart, *Pointer-*LineStart, Flags)
    Lines(Lines)\Start = *LineStart
    Lines(Lines)\Length = *Pointer - *LineStart
    Lines + 1
    Space - 1
    *LineStart = *Pointer
  Wend
  
  ; add the last line
  If *Pointer > *LineStart
    Lines(Lines)\Checksum = Diff_ComputeChecksum(*LineStart, *Pointer-*LineStart, Flags)
    Lines(Lines)\Start = *LineStart
    Lines(Lines)\Length = *Pointer - *LineStart
    Lines + 1
  EndIf
  
  ProcedureReturn Lines
EndProcedure

; Add a (possible empty) edit to the edit script
; Multiple edits with the same Op are combined into one
;
Procedure Diff_AddEdit(*Ctx.DiffContext, Op, Array Lines.DiffLine(1), StartLine, Lines)
  Protected Line

  If Lines > 0
    If LastElement(*Ctx\Edits()) = 0 Or *Ctx\Edits()\Op <> Op
      ; start a new edit
      AddElement(*Ctx\Edits())
      *Ctx\Edits()\Op = Op
      *Ctx\Edits()\StartLine = StartLine
      *Ctx\Edits()\Start = Lines(StartLine)\Start
    EndIf
    
    ; append lines to existing edit
    *Ctx\Edits()\Lines + Lines
    For Line = StartLine To StartLine + Lines - 1
      *Ctx\Edits()\Length + Lines(Line)\Length
    Next Line
  EndIf

EndProcedure

; Find middle snake
; Returns edit distance D
;
Procedure Diff_FindMiddleSnake(*Ctx.DiffContext, AOffset, N, BOffset, M, *x.Integer, *y.Integer, *u.Integer, *v.Integer)
  Protected DELTA = N - M
  Protected OFFSET = (N + M) * 2
  Protected odd, mid, D, k, c, x, y
  
  odd = Bool(DELTA % 2 <> 0)
  If odd
    mid = (N + M) / 2 + 1
  Else
    mid = (N + M) / 2
  EndIf
  
  *Ctx\FV(1+OFFSET) = 0
  *Ctx\RV(DELTA-1+OFFSET) = N
  
  For D = 0 To mid
  
    ; forward search
    For k = -D To D Step 2
      If k = -D Or (k <> D And *Ctx\FV(k-1+OFFSET) < *Ctx\FV(k+1+OFFSET))
        x = *Ctx\FV(k+1+OFFSET)
      Else
        x = *Ctx\FV(k-1+OFFSET) + 1
      EndIf
      y = x - k
      *x\i = x
      *y\i = y
      While x < N And y < M And *Ctx\A(AOffset + x)\Checksum = *Ctx\B(BOffset + y)\Checksum
        x + 1
        y + 1
      Wend
      *Ctx\FV(k+OFFSET) = x
      If odd And k >= (DELTA - (D - 1)) And k <= (DELTA + (D - 1))
        If x >= *Ctx\RV(k+OFFSET)
          *u\i = x
          *v\i = y
          ProcedureReturn 2 * D - 1
        EndIf
      EndIf
    Next k
    
    ; reverse search
    For k = -D To D Step 2
      c = k + DELTA
      If k = D Or (k <> -D And *Ctx\RV(c-1+OFFSET) < *Ctx\RV(c+1+OFFSET))
        x = *Ctx\RV(c-1+OFFSET)
      Else
        x = *Ctx\RV(c+1+OFFSET) - 1
      EndIf
      y = x - c
      *u\i = x
      *v\i = y
      While x > 0 And y > 0 And *Ctx\A(AOffset + x-1)\Checksum = *Ctx\B(BOffset + y-1)\Checksum
        x - 1
        y - 1
      Wend
      *Ctx\RV(c+OFFSET) = x
      If odd = 0 And c >= -D And c <= D
        If x <= *Ctx\FV(c+OFFSET)
          *x\i = x
          *y\i = y
          ProcedureReturn 2 * D
        EndIf
      EndIf
    Next k
    
  Next D
EndProcedure

; Recursively compute Diff
;
Procedure Diff_Recursive(*Ctx.DiffContext, AOffset, N, BOffset, M)
  Protected D, x, y, u, v

  If N > 0 And M = 0
    ; second sequence is empty: so only deletions
    Diff_AddEdit(*Ctx, #DIFF_DELETE, *Ctx\A(), AOffset, N)
  
  ElseIf N = 0 And M > 0
    ; first sequence is empty: so only additions
    Diff_AddEdit(*Ctx, #DIFF_INSERT, *Ctx\B(), BOffset, M)
  
  ElseIf N > 0 And M > 0
    D = Diff_FindMiddleSnake(*Ctx, AOffset, N, BOffset, M, @x, @y, @u, @v)
    ;Debug "D = " + D + "   x=" + x + " y=" + y + "  ->  u=" + u + " v=" + v

    If D = 0
      ; both sequences are equal
      Diff_AddEdit(*Ctx, #DIFF_MATCH, *Ctx\A(), AOffset, N)
    
    ElseIf D = 1
      ; exactly one edit and 0 or more matches
      If M > N
        If x = u
          ; \
          ;  \
          ;   |
          Diff_AddEdit(*Ctx, #DIFF_MATCH, *Ctx\A(), AOffset, N)
          Diff_AddEdit(*Ctx, #DIFF_INSERT, *Ctx\B(), BOffset + M-1, 1)
        Else
          ; |
          ;  \
          ;   \
          Diff_AddEdit(*Ctx, #DIFF_INSERT, *Ctx\B(), BOffset, 1)
          Diff_AddEdit(*Ctx, #DIFF_MATCH, *Ctx\A(), AOffset, N)
        EndIf
      Else
        If x = u
          ; \
          ;  \
          ;   -
          Diff_AddEdit(*Ctx, #DIFF_MATCH, *Ctx\A(), AOffset, M)
          Diff_AddEdit(*Ctx, #DIFF_DELETE, *Ctx\A(), AOffset + N-1, 1)
        Else
          ; -
          ;  \
          ;   \
          Diff_AddEdit(*Ctx, #DIFF_DELETE, *Ctx\A(), AOffset, 1)
          Diff_AddEdit(*Ctx, #DIFF_MATCH, *Ctx\A(), AOffset + 1, M)
        EndIf
      EndIf
    
    Else
      ; general case: recurse around the middle snake
      Diff_Recursive(*Ctx, AOffset, x, BOffset, y)
      Diff_AddEdit(*Ctx, #DIFF_MATCH, *Ctx\A(), AOffset + x, u-x)
      Diff_Recursive(*Ctx, AOffset + u, N-u, BOffset + v, M-v)
      
    EndIf
        
  EndIf
EndProcedure

; Main Diff function
;
Procedure Diff(*Ctx.DiffContext, *BufferA, SizeA, *BufferB, SizeB, Flags = 0)
  Protected N, M, MAX, Offset
  
  N = Diff_PreProcess(*BufferA, SizeA, *Ctx\A(), Flags)
  M = Diff_PreProcess(*BufferB, SizeB, *Ctx\B(), Flags)

  *Ctx\LineCountA = N
  *Ctx\LineCountB = M

  Dim *Ctx\FV((N + M)*4+1)
  Dim *Ctx\RV((N + M)*4+1)
  
  ClearList(*Ctx\Edits())
  
  ; Note:
  ; The handling of the D=1 Case in FindMiddleSnake() assumes that we always start
  ; with an inset Or delete. So strip off common lines at the start to ensure this
  Offset = 0
  While Offset < N And Offset < M And *Ctx\A(Offset)\Checksum = *Ctx\B(Offset)\Checksum
    Offset + 1
  Wend
  
  Diff_AddEdit(*Ctx, #DIFF_Match, *Ctx\A(), 0, Offset)
  Diff_Recursive(*Ctx, Offset, N-Offset, Offset, M-Offset)
  
  FreeArray(*Ctx\FV())
  FreeArray(*Ctx\RV())
EndProcedure

; Some debugging utilities
;
CompilerIf #PB_Compiler_Debugger

  Procedure DebugEdit(Prefix$, List Edits.DiffEdit(), Array Lines.DiffLine(1))
    Protected Line, Length, Line$
    
    For Line = Edits()\StartLine To Edits()\StartLine + Edits()\Lines - 1
      Line$ = PeekS(Lines(Line)\Start, Lines(Line)\Length, #PB_Ascii)
      Line$ = RTrim(RTrim(Line$, Chr(10)), Chr(13)) ; trim newline
      Debug Prefix$ + " " + Line$
    Next Line
  EndProcedure

  Procedure DebugDiff(*Ctx.DiffContext)
    ForEach *Ctx\Edits()
      Select *Ctx\Edits()\Op
        Case #DIFF_Match
          DebugEdit(" ", *Ctx\Edits(), *Ctx\A())
        Case #DIFF_Delete
          DebugEdit("-", *Ctx\Edits(), *Ctx\A())
        Case #DIFF_Insert
          DebugEdit("+", *Ctx\Edits(), *Ctx\B())
      EndSelect
    Next *Ctx\Edits()
  EndProcedure
  
  Procedure DebugFile(FileA$, FileB$)
    Protected *BufferA, SizeA, *BufferB, SizeB, Context.DiffContext
    
    If ReadFile(0, FileA$)
      SizeA = Lof(0)
      *BufferA = AllocateMemory(SizeA)
      ReadData(0, *BufferA, SizeA)
      CloseFile(0)
    Else
      Debug "Cannot load: " + FileA$
      End
    EndIf
    
    If ReadFile(0, FileB$)
      SizeB = Lof(0)
      *BufferB = AllocateMemory(SizeB)
      ReadData(0, *BufferB, SizeB)
      CloseFile(0)
    Else
      Debug "Cannot load: " + FileB$
      End
    EndIf
    
    Diff(@Context, *BufferA, SizeA, *BufferB, SizeB)
    DebugDiff(@Context)

    FreeMemory(*BufferA)
    FreeMemory(*BufferB)
  EndProcedure
  
  ;DebugFile("C:\PureBasic\Test\diff\Preferences\0081.pb", "C:\PureBasic\Test\diff\Preferences\0082.pb")
  
CompilerEndIf