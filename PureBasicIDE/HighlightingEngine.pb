; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


CompilerIf Not Defined(SpiderBasic, #PB_Constant)
  #SpiderBasic = 0
CompilerEndIf

; Redefine this constant here as it is included by the docmaker as well
;
CompilerIf Not Defined(MaxSizeHT, #PB_Constant)
  CompilerIf #PB_Compiler_Unicode
    #MaxSizeHT = 65535
  CompilerElse
    #MaxSizeHT = 255
  CompilerEndIf
CompilerEndIf


; the following are repeated declarations, for the case
; that the engine is used standalone
;
Global Dim ValidCharacters.b(#MaxSizeHT)  ; used by Syntax Highlighting and Structure Viewer

; stuff to use if not included from IDE/debugger
; (the ide includes the debugger sources too, that's why
; #PUREBASIC_DEBUGGER is declared there too).
;
CompilerIf Defined(PUREBASIC_DEBUGGER, #PB_Constant) = 0
  Structure SourceFileParser
    Encoding.l
  EndStructure

  Structure SourceFile
    EnableASM.l
    DebuggerData.i
    Parser.SourceFileParser
  EndStructure

  #FILE_LoadFunctions = 0
  #FILE_LoadAPI = 1

  #DEFAULT_FunctionFile       = ""
  #DEFAULT_ApiFile            = ""

  CompilerIf #PB_Compiler_Unicode = 0

    ; We could use PeekS(Memory, -1, #PB_Ascii) for both code, but it will have a performance hit
    ;
    Macro PeekAscii(Memory)
      PeekS(Memory)
    EndMacro

    Macro PeekAsciiLength(Memory, Length)
      PeekS(Memory, Length)
    EndMacro

    Macro MemoryAsciiLength(Memory)
      MemoryStringLength(Memory)
    EndMacro

    Macro ToAscii(String)
      @String
    EndMacro

  CompilerElse

    ; not really a macro, but this is a macro in non-unicode mode, that's why it is here
    Procedure ToAscii(String$)
      Static *Buffer, BufferLength

      If BufferLength > 1000000 ; Very big string (> 1MB), free it to clean some mem
        FreeMemory(*Buffer)
        BufferLength = 0
      EndIf

      Length = Len(String$) + 1

      ; Use a cache system to avoid alloc/free at every call, as it can be called a lot
      If BufferLength
        If BufferLength < Length
          *Buffer = ReAllocateMemory(*Buffer, Length, #PB_Memory_NoClear)
        EndIf
      Else
        *Buffer = AllocateMemory(Length, #PB_Memory_NoClear)
      EndIf

      BufferLength = Length

      PokeS(*Buffer, String$, -1, #PB_Ascii)
      ProcedureReturn *Buffer
    EndProcedure

    Macro PeekAscii(Memory)
      PeekS(Memory, -1, #PB_Ascii)
    EndMacro

    Macro PeekAsciiLength(Memory, Length)
      PeekS(Memory, Length, #PB_Ascii)
    EndMacro

    Macro MemoryAsciiLength(Memory)
      MemoryStringLength(Memory, #PB_Ascii)
    EndMacro

  CompilerEndIf

CompilerEndIf


; OS specific highlighting color representation:
;
Global *ASMKeywordColor, *BackgroundColor, *BasicKeywordColor, *CommentColor, *ConstantColor, *LabelColor
Global *NormalTextColor, *NumberColor, *OperatorColor, *PointerColor, *PureKeywordColor, *SeparatorColor, *CustomKeywordColor
Global *StringColor, *StructureColor, *LineNumberColor, *LineNumberBackColor, *MarkerColor, *CurrentLineColor, *CursorColor, *SelectionColor
Global *ModuleColor, *BadEscapeColor

Global *ActiveSource.SourceFile
Global EnableColoring
Global EnableCaseCorrection
Global EnableKeywordBolding
Global SourceStringFormat

Global NbASMKeywords.l ; Need to be a 'long' as the 'Data' is declared as long (32/64 bits)

CompilerIf #SpiderBasic
  #NbBasicKeywords = 98
CompilerElse
  #NbBasicKeywords = 114
CompilerEndIf

#BasicTypeChars = "ABCUWLSFDQI" ; characters that are basic types (uppercase)

Global Dim BasicKeywordsHT.l(#MaxSizeHT)
Global Dim BasicKeywords.s(#NbBasicKeywords)
Global Dim BasicKeywordsReal.s(#NbBasicKeywords)
Global Dim BasicKeywordsEndKeywords.s(#NbBasicKeywords)
Global Dim BasicKeywordsSpaces.s(#NbBasicKeywords)

Global Dim CustomKeywords.s(0) ; setup by the IDE, works if empty as well (index 0 is ignored!!)
Global Dim CustomKeywordsHT.l(#MaxSizeHT)
Global NbCustomKeywords


Global Dim ASMKeywordsHT.l(#MaxSizeHT)

Global Dim APIFunctionsHT.l(#MaxSizeHT)
Global NewMap BasicFunctionMap.l(4096)

Global BasicKeyword$, ASMKeyword$, KnownConstant$, CustomKeyword$
Global NbBasicFunctions, NbApiFunctions

CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
  
  Global BasicKeywordsTree.RadixTree   ; Stores index in array (not "index+1" since index 0 is invalid anyway)
  Global ASMKeywordsTree.RadixTree     ; Stores index in array (not "index+1"!)
  Global BasicFunctionsTree.RadixTree  ; Stores index+1
  Global APIFunctionsTree.RadixTree    ; Stores index+1
  
  ; Redeclared from StructureViewer.pb
  Global Dim ConstantList.s(0)
  Global ConstantTree.RadixTree
  
CompilerElse
  ; Replace functions that only have meaning in the IDE
  Macro RadixInsert(a, b, c)
  EndMacro
  
  Macro RadixFree(x)
  EndMacro
CompilerEndIf


;- Keyword constants
;
; NOTE: These constants must be in sync with the below data section, as they
;   represent the numerical index of the keyword in the keywords array.
;   This is 1 based as the keyword array is 1 based too
;
; Used by: The Source Parser/resolving of related keywords features, as
;   it is faster to refer to keywords by index than by name
;
Enumeration 1
  #KEYWORD_Align
  #KEYWORD_And
  #KEYWORD_Array
  #KEYWORD_As

  #KEYWORD_Break

  #KEYWORD_CallDebugger
  #KEYWORD_Case
  #KEYWORD_CompilerCase
  #KEYWORD_CompilerDefault
  #KEYWORD_CompilerElse
  #KEYWORD_CompilerElseIf
  #KEYWORD_CompilerEndIf
  #KEYWORD_CompilerEndSelect
  #KEYWORD_CompilerError
  #KEYWORD_CompilerIf
  #KEYWORD_CompilerSelect
  #KEYWORD_CompilerWarning
  #KEYWORD_Continue

  #KEYWORD_Data
  #KEYWORD_DataSection
  #KEYWORD_Debug
  #KEYWORD_DebugLevel
  #KEYWORD_Declare
  CompilerIf Not #SpiderBasic
    #KEYWORD_DeclareC
    #KEYWORD_DeclareCDLL
    #KEYWORD_DeclareDLL
  CompilerEndIf
  #KEYWORD_DeclareModule
  #KEYWORD_Default
  #KEYWORD_Define
  #KEYWORD_Dim
  CompilerIf Not #SpiderBasic
    #KEYWORD_DisableASM
  CompilerEndIf
  #KEYWORD_DisableDebugger
  #KEYWORD_DisableExplicit
  CompilerIf #SpiderBasic ; It's EnableJS in SpiderBasic, so it needs to be put there as it's alpha-sorted !
    #KEYWORD_DisableASM
  CompilerEndIf
  #KEYWORD_DisablePureLibrary
  #KEYWORD_Else
  #KEYWORD_ElseIf
  CompilerIf Not #SpiderBasic
    #KEYWORD_EnableASM
  CompilerEndIf
  #KEYWORD_EnableDebugger
  #KEYWORD_EnableExplicit
  CompilerIf #SpiderBasic ; It's EnableJS in SpiderBasic, so it needs to be put there as it's alpha-sorted !
    #KEYWORD_EnableASM
  CompilerEndIf
  #KEYWORD_End
  #KEYWORD_EndDataSection
  #KEYWORD_EndDeclareModule
  #KEYWORD_EndEnumeration
  #KEYWORD_EndHeaderSection
  #KEYWORD_EndIf
  #KEYWORD_EndImport
  #KEYWORD_EndInterface
  #KEYWORD_EndMacro
  #KEYWORD_EndModule
  #KEYWORD_EndProcedure
  #KEYWORD_EndSelect
  #KEYWORD_EndStructure
  CompilerIf Not #SpiderBasic
    #KEYWORD_EndStructureUnion
  CompilerEndIf
  #KEYWORD_EndWith
  #KEYWORD_Enumeration
  #KEYWORD_EnumerationBinary
  #KEYWORD_Extends

  CompilerIf Not #SpiderBasic
    #KEYWORD_FakeReturn
  CompilerEndIf
  #KEYWORD_For
  #KEYWORD_ForEach
  #KEYWORD_ForEver

  #KEYWORD_Global
  CompilerIf Not #SpiderBasic
    #KEYWORD_Gosub
    #KEYWORD_Goto
  CompilerEndIf
  
  #KEYWORD_HeaderSection

  #KEYWORD_If
  #KEYWORD_Import
  CompilerIf Not #SpiderBasic
    #KEYWORD_ImportC
    #KEYWORD_IncludeBinary
  CompilerEndIf
  #KEYWORD_IncludeFile
  #KEYWORD_IncludePath
  #KEYWORD_Interface

  #KEYWORD_List

  #KEYWORD_Macro
  #KEYWORD_MacroExpandedCount
  #KEYWORD_Map
  #KEYWORD_Module

  #KEYWORD_NewList
  #KEYWORD_NewMap
  #KEYWORD_Next
  #KEYWORD_Not

  #KEYWORD_Or

  ;#KEYWORD_Parallel
  #KEYWORD_Procedure
  CompilerIf Not #SpiderBasic
    #KEYWORD_ProcedureC
    #KEYWORD_ProcedureCDLL
    #KEYWORD_ProcedureDLL
  CompilerEndIf
  #KEYWORD_ProcedureReturn
  #KEYWORD_Protected
  #KEYWORD_Prototype
  CompilerIf Not #SpiderBasic
    #KEYWORD_PrototypeC
  CompilerEndIf

  #KEYWORD_Read
  #KEYWORD_ReDim
  #KEYWORD_Repeat
  #KEYWORD_Restore
  CompilerIf Not #SpiderBasic
    #KEYWORD_Return
  CompilerEndIf
  #KEYWORD_Runtime

  #KEYWORD_Select
  #KEYWORD_Shared
  #KEYWORD_Static
  #KEYWORD_Step
  #KEYWORD_Structure
  CompilerIf Not #SpiderBasic
    #KEYWORD_StructureUnion
  CompilerEndIf
  #KEYWORD_Swap

  CompilerIf Not #SpiderBasic
    #KEYWORD_Threaded
  CompilerEndIf
  #KEYWORD_To

  #KEYWORD_UndefineMacro
  #KEYWORD_Until
  #KEYWORD_UnuseModule
  #KEYWORD_UseModule

  #KEYWORD_Wend
  #KEYWORD_While
  #KEYWORD_With

  #KEYWORD_XIncludeFile
  #KEYWORD_XOr
EndEnumeration


; To reduce CompilerIf across the source, do some aliases
;
CompilerIf #SpiderBasic
  #KEYWORD_DeclareC = #KEYWORD_Declare
  #KEYWORD_DeclareCDLL = #KEYWORD_Declare
  #KEYWORD_DeclareDLL = #KEYWORD_Declare
  #KEYWORD_ImportC = #KEYWORD_Import
  #KEYWORD_ProcedureC = #KEYWORD_Procedure
  #KEYWORD_ProcedureCDLL = #KEYWORD_Procedure
  #KEYWORD_ProcedureDLL = #KEYWORD_Procedure
  #KEYWORD_PrototypeC = #KEYWORD_Prototype
  #KEYWORD_Threaded = #KEYWORD_Global
  #KEYWORD_IncludeBinary = #KEYWORD_IncludeFile
CompilerEndIf


CompilerIf #PB_Compiler_EnumerationValue <> #NbBasicKeywords+1
  CompilerError "Keyword Constants not in sync with Keyword count!"
CompilerEndIf

; Use a prototype to have the fastest access possible to the callback
;
Prototype HighlightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)

; For API/BasicFunction array
Structure FunctionEntry
  Name$        ; name (in correct case)
  Proto$       ; quickhelp string (if any)
  *Ascii       ; pointer to name in ascii
  AsciiBuffer.a[256] ; name in ascii for highlighting engine (which is ascii only)
EndStructure

Structure HighlightPTR
  StructureUnion
    a.a[0]
    b.b[0] ; even when declaring with an array like this, we still
    c.c[0] ; can use the single \b, which is perfect for a universal
    w.w[0] ; pointer variable
    u.u[0]
    l.l[0]
    f.f[0]
    q.q[0]
    d.d[0]
    i.i[0]
  EndStructureUnion
EndStructure

;- Issue scan support for the IDE
;
CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)

  ; Skip 'Count' characters (not bytes) in Ascii/UTF8 from *Pointer
  ;
  Procedure SkipCharacters(*Pointer.Ascii, Count, StringFormat)
    If StringFormat = #PB_Ascii

      ; simple
      ProcedureReturn *Pointer + Count

    Else

      ; must look for utf8 sequences
      For i = 1 To Count

        If *Pointer\a = 0
          ProcedureReturn *Pointer

        ElseIf *Pointer\a & %10000000 = %00000000 ; 1 byte
          *Pointer + 1

        ElseIf *Pointer\a & %11100000 = %11000000 ; 2 byte
          *Pointer + 1
          If *Pointer\a & %11000000 = %10000000: *Pointer + 1: EndIf ; follow byte

        ElseIf *Pointer\a & %11110000 = %11100000 ; 3 byte
          *Pointer + 1
          If *Pointer\a & %11000000 = %10000000: *Pointer + 1: EndIf ; follow byte
          If *Pointer\a & %11000000 = %10000000: *Pointer + 1: EndIf ; follow byte

        ElseIf *Pointer\a & %11111000 = %11110000 ; 4 byte
          *Pointer + 1
          If *Pointer\a & %11000000 = %10000000: *Pointer + 1: EndIf ; follow byte
          If *Pointer\a & %11000000 = %10000000: *Pointer + 1: EndIf ; follow byte
          If *Pointer\a & %11000000 = %10000000: *Pointer + 1: EndIf ; follow byte

        Else ; invalid
          *Pointer + 1

        EndIf
      Next i

      ProcedureReturn *Pointer
    EndIf
  EndProcedure

  Procedure HighlightCommentIssues(*StringStart, *LineEnd, *StringEnd, StringFormat, Callback.HighlightCallback)
    Static NewList Found.FoundIssue() ; static to avoid constant alloc/free

    ; scan for issues
    ; remove the ';' from the scanned string
    If StringFormat = #PB_UTF8
      Comment$ = PeekS(*StringStart+1, *LineEnd-*StringStart, StringFormat | #PB_ByteLength) ; #PB_ByteLength is only valid for UTF8
    Else
      Comment$ = PeekS(*StringStart+1, *LineEnd-*StringStart, StringFormat)
    EndIf
    
    ScanCommentIssues(Comment$, Found(), #True) ; highlight mode

    ; add them one by one (and manage space in between)
    *Cursor = *StringStart

    ; Note the \Position values are 1-based, but we did not include the ';' in the
    ; scanned string. So by starting at 0 here, the ; will be handled correctly when the
    ; first issue is passed to the callback
    Position = 0

    ForEach Found()
      If Found()\Position > Position
        ; something between the issues
        *Start  = *Cursor
        *Cursor = SkipCharacters(*Cursor, Found()\Position - Position, StringFormat)
        Callback(*Start, *Cursor-*Start, *CommentColor, 0, 0)
      EndIf

      ; output the issue
      ; Note that only issues with Style<>-1 are returned in highlight mode
      *Start = *Cursor
      *Cursor = SkipCharacters(*Cursor, Found()\Length, StringFormat)
      Callback(*Start, *Cursor-*Start, Found()\Style, 0, 0)

      Position = Found()\Position + Found()\Length
    Next Found()

    ; output final comment part
    If *Cursor < *StringEnd
      Callback(*Cursor, *StringEnd-*Cursor, *CommentColor, 0, 0)
    EndIf
  EndProcedure

CompilerEndIf


; If *Source and *Target have same content: returns #False
; Otherwise, copy the memory and return #True
Procedure CopyMemoryCheck(*Source.HighlightPTR, *Target.HighlightPTR, Length)

  ; for a fast equal check, do it in integer blocks
  While Length >= SizeOf(Integer)
    If *Source\i <> *Target\i
      CopyMemory(*Source, *Target, Length)
      ProcedureReturn #True
    Else
      *Source + SizeOf(Integer)
      *Target + SizeOf(Integer)
      Length - SizeOf(Integer)
    EndIf
  Wend

  ; check the last bytes
  While Length > 0
    If *Source\b <> *Target\b
      CopyMemory(*Source, *Target, Length)
      ProcedureReturn #True
    Else
      *Source + 1
      *Target + 1
      Length - 1
    EndIf
  Wend

  ; no check found a difference
  ProcedureReturn #False
EndProcedure

Procedure ByteUcase(Byte.a) ; get the upper case value of a char in ascii mode
  If Byte >= 'a' And Byte <= 'z'
    ProcedureReturn Byte - 'a' + 'A'
  Else
    ProcedureReturn Byte
  EndIf
EndProcedure


Procedure InitSyntaxCheckArrays()

  ; Build the ValidCharacter table to have have a faster routine to detect
  ; if the char is a considered as a string or not. Nice improvement :)
  ;
  For k='0' To '9'            ; Tell that the ASCII from 0 to 9 are valid
    ValidCharacters(k) = 1
  Next

  For k='A' To 'Z'            ; Tell that the ASCII from A to Z are valid
    ValidCharacters(k) = 1
  Next

  For k='a' To 'z'            ; Tell that the ASCII from a to z are valid
    ValidCharacters(k) = 1
  Next

  ValidCharacters('_') = 1


  ; Now, init the internal PureBasic keywords
  ; can be done here, as it does not need the compiler
  ;
  RadixFree(BasicKeywordsTree)
  CurrentChar = 0
  Restore BasicKeywords
  For k=1 To #NbBasicKeywords
    Read.s BasicKeywordsReal(k)
    BasicKeywords(k) = LCase(BasicKeywordsReal(k))
    Read.s BasicKeywordsEndKeywords(k)
    Read.s BasicKeywordsSpaces(k)
    RadixInsert(BasicKeywordsTree, BasicKeywordsReal(k), k)

    Char = Asc(BasicKeywords(k))
    If Char <> CurrentChar
      BasicKeywordsHT(Char) = k
      CurrentChar = Char
    EndIf
  Next

  ; This is for the SourceParser which does not convert to lowercase when
  ; checking the array (as the highlighter does)
  ;
  For Char = 'A' To 'Z'
    BasicKeywordsHT(Char) = BasicKeywordsHT(Char+('a'-'A'))
  Next Char

  ; And next, init the ASM keywords
  ;
  CurrentChar = 0
  RadixFree(ASMKeywordsTree)
  Restore ASMKeywords

  Read.l NbASMKeywords

  Global Dim ASMKeywords.s(NbASMKeywords)

  For k=1 To NbASMKeywords
    Read.s ASMKeywords(k)
    RadixInsert(ASMKeywordsTree, ASMKeywords(k), k)

    Char = Asc(ASMKeywords(k))
    If Char <> CurrentChar
      ASMKeywordsHT(Char) = k
      CurrentChar = Char
    EndIf
  Next

  ; ASM keywords are all uppercase, so set the lowercase index here
  For Char = 'A' To 'Z'
    ASMKeywordsHT(Char+('a'-'A')) = ASMKeywordsHT(Char)
  Next Char

EndProcedure


Procedure InitSyntaxHighlighting()
  Static APIFunctionsRead

  NbBasicFunctions = 0
  Global Dim BasicFunctions.FunctionEntry(0)

  ; Only load these files when we are inside the IDE or debugger
  ;
  CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)

    If CompilerReady ; only if the compiler is loaded!
      CompilerWrite("FUNCTIONLIST")
      Response$ = CompilerRead()

      NbBasicFunctions = Val(Response$)
      If NbBasicFunctions < 10000 And NbBasicFunctions > 0  ; Sanity check... If over, it's a bit strange...
        Dim BasicFunctions.FunctionEntry(NbBasicFunctions)
        RadixFree(BasicFunctionsTree)

        CurrentFunction = 0
        Repeat
          Response$ = CompilerRead_NoDebug()

          If Response$ = "OUTPUT"+Chr(9)+"COMPLETE"
            Break

          ElseIf CurrentFunction < NbBasicFunctions
            space = FindString(Response$, " ", 1)

            If space > 0
              BasicFunctions(CurrentFunction)\Name$  = Left(Response$, space-1)
              BasicFunctions(CurrentFunction)\Proto$ = Right(Response$, Len(Response$)-space)
            Else
              BasicFunctions(CurrentFunction)\Name$  = Response$
              BasicFunctions(CurrentFunction)\Proto$ = ""
            EndIf

            CurrentFunction + 1
          EndIf
        ForEver

        ; Note: The compiler does not always sort this in the same order than the
        ; PB compare functions so our hashing stops working
        ; So we add a sort step here to be sure
        SortStructuredArray(BasicFunctions(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(FunctionEntry\Name$), #PB_String, 0, NbBasicFunctions-1)
                
        ; Do the conversion to ascii now, as our pointer field is wrong else!
        For i = 0 To NbBasicFunctions-1
          PokeS(@BasicFunctions(i)\AsciiBuffer[0], BasicFunctions(i)\Name$, 255, #PB_Ascii)
          BasicFunctions(i)\Ascii = @BasicFunctions(i)\AsciiBuffer[0]
          RadixInsert(BasicFunctionsTree, BasicFunctions(i)\Name$, i+1)
        Next i

      EndIf

    EndIf

  CompilerEndIf


  ; PureBasic function Hash Table
  ;
  ClearMap(BasicFunctionMap())
  For k=1 To NbBasicFunctions
    BasicFunctionMap(UCase(BasicFunctions(k-1)\Name$)) = k
  Next

  ; Read the API Functions file
  ;

  If APIFunctionsRead = 0  ; only needed once, not on compiler restart
    APIFunctionsRead = 1

    NbAPIFunctions = 0
    Global Dim APIFunctions.FunctionEntry(0)
    RadixFree(APIFunctionsTree)

    ; Only load these files when we are inside the IDE or debugger
    ;
    CompilerIf Defined(PUREBASIC_DEBUGGER, #PB_Constant)

      If ReadFile(#FILE_LoadAPI, PureBasicPath$ + #DEFAULT_ApiFile)

        NbAPIFunctions = Val(ReadString(#FILE_LoadAPI, #PB_Ascii))

        *Cursor.Byte = AllocateMemory(Lof(#FILE_LoadAPI)+2) ; this one never changes, because the API list isn't compiler generated
        *APIFunctionsBuffer = *Cursor
        If *Cursor
          ReadData(#FILE_LoadAPI, *Cursor, Lof(#FILE_LoadAPI))

          Dim APIFunctions.FunctionEntry(NbAPIFunctions)
          CurrentFunction = 0

          Repeat

            *NameStart = *Cursor     ; FunctionName

            While *Cursor\b <> ' ' And *Cursor\b <> 13 And *Cursor\b <> 10
              *Cursor+1
            Wend

            If *Cursor\b = 13 Or *Cursor\b = 10  ; End of line
              *Cursor\b = 0
              *Cursor+1

              APIFunctions(CurrentFunction)\Name$ = PeekS(*NameStart, -1, #PB_Ascii)
              APIFunctions(CurrentFunction)\Proto$ = ""
            Else
              *Cursor\b = 0
              *Cursor+1

              APIFunctions(CurrentFunction)\Name$ = PeekS(*NameStart, -1, #PB_Ascii)

              *NameStart = *Cursor ; QuickHelo

              While *Cursor\b <> 13  And *Cursor\b <> 10 And *Cursor\b ; Skip the end of line
                *Cursor+1
              Wend

              *Cursor\b = 0
              *Cursor+1

              APIFunctions(CurrentFunction)\Proto$ = PeekS(*NameStart, -1, #PB_Ascii)
            EndIf

            If (*Cursor\b = 10)
              *Cursor+1
            EndIf

            CurrentFunction+1
          Until *Cursor\b = 0 Or CurrentFunction > NbAPIFunctions

          ; make sure the sorting is ok here too
          SortStructuredArray(APIFunctions(), #PB_Sort_Ascending|#PB_Sort_NoCase, OffsetOf(FunctionEntry\Name$), #PB_String, 0, NbAPIFunctions-1)

          ; Do the conversion to ascii now, as our pointer field is wrong else!
          For i = 0 To NbAPIFunctions-1
            PokeS(@APIFunctions(i)\AsciiBuffer[0], APIFunctions(i)\Name$, 255, #PB_Ascii)
            APIFunctions(i)\Ascii = @APIFunctions(i)\AsciiBuffer[0]
            RadixInsert(APIFunctionsTree, APIFunctions(i)\Name$, i+1)
          Next i

          FreeMemory(*APIFunctionsBuffer)
        EndIf

        CloseFile(#FILE_LoadAPI)
      EndIf

    CompilerEndIf

    ; API function Hash Table
    ;
    CurrentChar = 0
    For k=1 To NbAPIFunctions
      If APIFunctions(k-1)\Name$
        Char = ByteUcase(PeekB(APIFunctions(k-1)\Ascii))
        If Char <> CurrentChar
          APIFunctionsHT(Char) = k
          CurrentChar = Char
        EndIf
      EndIf
    Next

  EndIf

  ; Indicate that highlighting is ready now:
  ;
  IsHighlightingReady = 1

EndProcedure

CompilerIf Defined(PUREBASIC_DEBUGGER, #PB_Constant) ; only in IDE and debugger

  Procedure BuildCustomKeywordTable()
    Protected NewList TempList.s() ; to collect all words first (from file and list)

    ; needed for the ValidCharacters!
    InitSyntaxCheckArrays()

    ; make a copy of the IDE list
    ;
    ForEach CustomKeywordList()
      Word$ = Trim(RemoveString(CustomKeywordList(), Chr(9)))

      *Cursor.Character = @Word$
      While *Cursor\c
        If ValidCharacters(*Cursor\c) = 0 And *Cursor\c <> '_' And *Cursor\c <> '*' And *Cursor\c <> '$'
          Word$ = ""
          Break
        EndIf
        *Cursor + SizeOf(Character)
      Wend

      If Word$ <> ""
        AddElement(TempList())
        TempList() = Word$
      EndIf
    Next CustomKeywordList()

    ; add the file list if any
    ;
    If CustomKeywordFile$ <> "" And FileSize(CustomKeywordFile$) < 50000 ; just a sanity check to not load an avi :D
      If ReadFile(#FILE_LoadFunctions, CustomKeywordFile$)
        While Not Eof(#FILE_LoadFunctions)
          Word$ = Trim(RemoveString(ReadString(#FILE_LoadFunctions), Chr(9)))

          *Cursor.Character = @Word$
          While *Cursor\c
            If ValidCharacters(*Cursor\c) = 0 And *Cursor\c <> '_' And *Cursor\c <> '*' And *Cursor\c <> '$'
              Word$ = ""
              Break
            EndIf
            *Cursor + SizeOf(Character)
          Wend

          If Word$ <> ""
            AddElement(TempList())
            TempList() = Word$
          EndIf
        Wend
        CloseFile(#FILE_LoadFunctions)
      EndIf
    EndIf

    ; sort the list and fill the highlighter arrays
    SortList(TempList(), #PB_Sort_Ascending|#PB_Sort_NoCase)

    NbCustomKeywords = ListSize(TempList())
    Global Dim CustomKeywords.s(NbCustomKeywords)

    For i = 0 To 255
      CustomKeywordsHT(i) = 0 ; clear the HT
    Next i

    CurrentChar = 0
    ForEach TempList()
      index = ListIndex(TempList())+1 ; index 0 is ignored
      CustomKeywords(index) = TempList()

      Char = Asc(UCase(Left(TempList(), 1)))
      If Char <> CurrentChar
        CustomKeywordsHT(Char) = index
        CurrentChar = Char
      EndIf
    Next TempList()

  EndProcedure

CompilerEndIf


; do no longer work on strings but only on buffers, to avoid unneeded ascii-unicode conversions
;
Procedure IsAPIFunction(*Word, length)
  Result = -1

  If length > 2 And PeekB(*Word+length-1) = '_'
    length - 1

    k = APIFunctionsHT(ByteUcase(PeekB(*Word)))  ; We use an HashTable to get access to the index very quickly
    If k
      k-1
      While Quit = 0 And k < NbAPIFunctions
        If APIFunctions(k)\Name$ = ""
          Quit = 1
        Else
          Compare = CompareMemoryString(APIFunctions(k)\Ascii, *Word, 1, length, #PB_Ascii)  ; Case insensitive compare

          If Compare <= 0
            If Compare = 0 And length = MemoryAsciiLength(APIFunctions(k)\Ascii) ; important to check the length!
              Result = k
              Quit   = 1
            EndIf
          Else
            Quit = 1
          EndIf
        EndIf

        k+1
      Wend
    EndIf

  EndIf

  ProcedureReturn Result
EndProcedure


Procedure IsBasicFunction(Word$) ; Word$ must be in UPPER case
  ProcedureReturn BasicFunctionMap(Word$) - 1 ; Will return -1 if not found or the zerobased index of the function in the array
EndProcedure


Procedure IsASMKeyword(Word$)

  Word$ = UCase(Word$)
  k = ASMKeywordsHT(Asc(Word$))  ; We use an HashTable to get access to the index very quickly
  If k
    While Quit = 0 And k <= NbASMKeywords

      If ASMKeywords(k) <= Word$
        If ASMKeywords(k) = Word$
          ASMKeyword$ = ASMKeywords(k)
          Result = k
          Quit = 1
        EndIf
      Else
        Quit = 1
      EndIf

      k+1
    Wend
  EndIf

  ProcedureReturn Result
EndProcedure

Procedure IsCustomKeyword(Word$)

  k = CustomKeywordsHT(Asc(UCase(Word$)))  ; We use an HashTable to get access to the index very quickly
  If k
    While Quit = 0 And k <= NbCustomKeywords

      Compare = CompareMemoryString(@CustomKeywords(k), @Word$, #PB_String_NoCaseAscii)  ; Case insensitive compare

      If Compare <= 0
        If Compare = 0
          CustomKeyword$ = CustomKeywords(k)
          Result = k
          Quit = 1
        EndIf
      Else
        Quit = 1
      EndIf

      k+1
    Wend
  EndIf

  ProcedureReturn Result
EndProcedure


Procedure IsKnownConstant(Word$)
  
  CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
    
    Match = RadixLookupValue(ConstantTree, Word$)
    If Match
      KnownConstant$ = ConstantList(Match-1) ; The tree stores index+1
      ProcedureReturn 1
    EndIf
    
  CompilerEndIf
    
  ProcedureReturn 0
EndProcedure

; for detection. use global so it does not need to be done all the time
Global *KeywordStructure = Ascii("Structure") ; Don't use ToAscii as it use a single buffer
Global *KeywordInterface = Ascii("Interface")
Global *KeywordExtends   = Ascii("Extends")

; returns true if the current position is after
; a structure or interface keyword
;
Procedure IsAfterStructure(Keyword, *LineStart, *Cursor.HighlightPTR)

  ; move away from word start char
  *Cursor - 1

  ; skip whitespace
  While *Cursor > *LineStart And (*Cursor\b = ' ' Or *Cursor\b = 9)
    *Cursor - 1
  Wend

  ; skip structure name
  While *Cursor > *LineStart And ValidCharacters(*Cursor\a)
    *Cursor - 1
  Wend

  ; skip whitespace
  While *Cursor > *LineStart And (*Cursor\b = ' ' Or *Cursor\b = 9)
    *Cursor - 1
  Wend

  ; skip keyword
  *WordEnd = *Cursor + 1
  While *Cursor > *LineStart And ValidCharacters(*Cursor\a)
    *Cursor - 1
  Wend

  ; move to start of keyword
  ; if the 'structure' is not the linestart, we just moved off the word
  If ValidCharacters(*Cursor\a) = 0
    *Cursor + 1
  EndIf

  Length = *WordEnd - *Cursor
  If Length = 9 And CompareMemoryString(*Cursor, *KeywordStructure, #PB_String_NoCaseAscii, 9, #PB_Ascii) = #PB_String_Equal
    ; extends/align on structure
    ProcedureReturn #True
  ElseIf Keyword = #KEYWORD_Extends And Length = 9 And CompareMemoryString(*Cursor, *KeywordInterface, #PB_String_NoCaseAscii, 9, #PB_Ascii) = #PB_String_Equal
    ; extends on interface (no align allowed)
    ProcedureReturn #True
  ElseIf Keyword = #KEYWORD_Align And Length = 7 And CompareMemoryString(*Cursor, *KeywordExtends, #PB_String_NoCaseAscii, 7, #PB_Ascii) = #PB_String_Equal
    ; align after extends (Structure X Extends Y Align Z is allowed)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; Supply *LineStart and *WordStart to check 'Align' and 'Extends' after structures
;
Procedure IsBasicKeyword(Word$, *LineStart = 0, *WordStart = 0)

  If Right(Word$, 1) = "$"
    Word$ = Left(Word$, Len(Word$)-1)
    AddDollar = 1
  EndIf

  Word$ = LCase(Word$)
  k = BasicKeywordsHT(Asc(Word$))  ; We use an HashTable to get access to the index very quickly
  If k
    While Quit = 0 And k <= #NbBasicKeywords

      If BasicKeywords(k) <= Word$
        If BasicKeywords(k) = Word$
          BasicKeyword$ = BasicKeywordsReal(k)
          Result = k
          Quit = 1
        EndIf
      Else
        Quit = 1
      EndIf

      k+1
    Wend
  EndIf

  If AddDollar
    BasicKeyword$ + "$"
  EndIf

  If (Result = #KEYWORD_Align Or Result = #KEYWORD_Extends) And *LineStart And *WordStart
    ; report Align and Extends only as keywords if they follow a structure or interface
    If IsAfterStructure(Result, *LineStart, *WordStart) = #False
      ProcedureReturn 0
    EndIf
  EndIf

  ProcedureReturn Result
EndProcedure


Procedure IsDecNumber(*string.BYTE, length)
  If length < 0 Or ByteUcase(*string\b) = 'E' ; prevent variablenames like e1, e, e1225 from highlighting as numbers
    ProcedureReturn 0
  EndIf

  *bufferend = *string + length
  While *string < *bufferend
    If (*string\b < 48 Or *string\b > 57) And *string\b <> 'e' And *string\b <> 'E' And *string\b <> '-' And *string\b <> '+' ; include the 123e-10 stuff too
      ProcedureReturn 0
    EndIf
    *string + 1
  Wend
  ProcedureReturn 1
EndProcedure

; Checks if the cursor is the first non-whitespace char on a line
;
Procedure IsLineStart(*LineStart, *Cursor.BYTE)
  *Cursor - 1 ; the currently examined cursor position must not be checked

  While *Cursor > *LineStart
    If *Cursor\b <> ' ' And *Cursor\b <> 9
      ProcedureReturn 0
    EndIf
    *Cursor - 1
  Wend

  ProcedureReturn 1
EndProcedure

; Checks if the cursor is the first non-whitespace char on a line or since a ':'
;
Procedure IsCommandStart(*LineStart, *Cursor.BYTE)
  *Cursor - 1 ; the currently examined cursor position must not be checked

  While *Cursor > *LineStart
    If *Cursor\b = ':'
      ProcedureReturn 1
    ElseIf *Cursor\b <> ' ' And *Cursor\b <> 9
      ProcedureReturn 0
    EndIf
    *Cursor - 1
  Wend

  ProcedureReturn 1
EndProcedure


; callback function
;
;Declare HighlightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)

#EndSeparator  = -1
#SkipSeparator = -2
#ModuleSeparator = -2

Procedure HighlightingEngine(*InBuffer, InBufferLength, CursorPosition, Callback.HighlightCallback, IsSourceCode, DisableFormatting = 0)

  *Cursor.HighlightPTR = *InBuffer
  *InBufferEnd = *InBuffer + InBufferLength
  *LineStart   = *InBuffer ; Scintilla never requests the highlight of less than complete lines, so this is ok

  If IsSourceCode And *ActiveSource And *ActiveSource\EnableASM
    ASMEnabled = 1
  Else
    ASMEnabled = 0
  EndIf

  If IsSourceCode And *ActiveSource And *ActiveSource\Parser\Encoding = 1
    SourceStringFormat = #PB_UTF8
  Else
    SourceStringFormat = #PB_Ascii
  EndIf

  SeparatorChar = 0
  OldSeparatorChar = 0   ; the previous separator char
  OlderSeparatorChar = 0 ; the separator char before the previous one

  While *Cursor < *InBufferEnd

    *StringStart = *Cursor

    ; first, skip all tabs and spaces
    While *Cursor < *InBufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
      *Cursor + 1
    Wend

    ; Now, isolate the word..

    *WordStart = *Cursor

    While *Cursor < *InBufferEnd And ValidCharacters(*Cursor\a)
      *Cursor + 1
    Wend

    *WordEnd.BYTE = *Cursor

    ; Skip all the spaces after the word..

    AfterSpaces = 0
    While *Cursor < *InBufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
      AfterSpaces+1
      *Cursor + 1
    Wend

    ; a direct '$' is seen as part of the word now, makes things simpler
    ; and fixes "Dim Array$(x)"
    ;
    If AfterSpaces = 0 And *Cursor < *InBufferEnd And *Cursor\b = '$' And *WordStart < *WordEnd ; a single $ usually starts a hex number, so exclude it!
      *WordEnd + 1
      *Cursor  + 1

      While *Cursor < *InBufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
        AfterSpaces+1
        *Cursor + 1
      Wend
    EndIf

    WordLength = *WordEnd - *WordStart
    WordStart$ = PeekAsciiLength(*WordStart, WordLength)

    SeparatorUsed = 0
    IgnoreSeparator = 0

    ; Here we got our separator: (, ', ;....). If it's a valid character, then the separator was spaces..

    If *Cursor > *InBufferEnd
      SeparatorChar = #EndSeparator ; indicate end of the loop!

    Else

      NewLine = 0
      If ValidCharacters(*Cursor\a)
        SeparatorChar = 0

      ElseIf *Cursor\b = 13 Or *Cursor\b = 10
        NewLine = 1

        If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 13 Or *Cursor\a[1] = 10)  ; output the newline directly with the word
          *Cursor + 2
        Else
          *Cursor + 1
        EndIf

        SeparatorChar = #SkipSeparator

      ElseIf *Cursor\b = 0
        SeparatorChar = #EndSeparator ; indicate end of the loop!

      Else
        SeparatorChar = *Cursor\a
      EndIf
    EndIf

    ; Custom keywords get priority even over PB ones so you can re-color some of them if you want
    If IsCustomKeyword(WordStart$) And OldSeparatorChar <> '\'

      ; -------------------- Custom Keyword -------------------------
      If DisableFormatting = #False And EnableCaseCorrection And (CursorPosition = 0 Or CursorPosition < *WordStart-*InBuffer Or CursorPosition > *WordEnd-*InBuffer)
        TextChanged = CopyMemoryCheck(ToAscii(CustomKeyword$), *WordStart, Len(CustomKeyword$)) ; no PokeS() as it will write a 0!
      Else
        TextChanged = 0
      EndIf

      If DisableFormatting = #False And EnableKeywordBolding ; special fix for the alignment issues. for bolded keywords, we output all whitespace as "normal text"
        Callback(*StringStart, *WordStart- *StringStart, *NormalTextColor, 0, 0)
        Callback(*WordStart  , *WordEnd  - *WordStart  , *CustomKeywordColor, 1, TextChanged)
        Callback(*WordEnd    , *Cursor   - *WordEnd    , *NormalTextColor, 0, 0)
      Else
        Callback(*StringStart, *Cursor - *StringStart, *CustomKeywordColor, 0, TextChanged)
      EndIf

      CompilerIf Defined(IDE_SYNTAXCHECK, #PB_Constant)
        CompilerError "Note: when adding this, add code for all possible syntax tokens here"
      CompilerEndIf


      ; do not highlight as keyword if the last separator was \ (then its a structure member)
      ; also not when its the first thing in a command, and a Asm keyword (and asm turned on)
      ; as And, Or, Xor and such only happen as keywords after something else, this will work
      ;
    ElseIf IsBasicKeyword(WordStart$, *LineStart, *WordStart) And OldSeparatorChar <> '\' And (ASMEnabled = 0 Or IsASMKeyword(WordStart$) = 0 Or IsCommandStart(*LineStart, *WordStart) = 0)

      ; -------------------- Basic Keywords -------------------------

      ; do not correct the word the user is currently typing, because it will change the case of any word that starts with a PB keyword, which is not good
      If DisableFormatting = #False And EnableCaseCorrection And (CursorPosition = 0 Or CursorPosition < *WordStart-*InBuffer Or CursorPosition > *WordEnd-*InBuffer)
        TextChanged = CopyMemoryCheck(ToAscii(BasicKeyword$), *WordStart, Len(BasicKeyword$)) ; no PokeS() as it will write a 0!
      Else
        TextChanged = 0
      EndIf

      If DisableFormatting = #False And EnableKeywordBolding ; special fix for the alignment issues. for bolded keywords, we output all whitespace as "normal text"
        Callback(*StringStart, *WordStart- *StringStart, *NormalTextColor, 0, 0)
        Callback(*WordStart  , *WordEnd  - *WordStart  , *BasicKeywordColor, 1, TextChanged)
        Callback(*WordEnd    , *Cursor   - *WordEnd    , *NormalTextColor, 0, 0)
      Else
        Callback(*StringStart, *Cursor - *StringStart, *BasicKeywordColor, 0, TextChanged)
      EndIf
      
      ; When loading a file, the whole buffer is scanned at once, so detect the EnableJS/DisableJS live, to modify the formatting flag
      Select LCase(BasicKeyword$)
        Case BasicKeywords(#KEYWORD_EnableASM), BasicKeywords(#KEYWORD_HeaderSection)
          DisableFormatting = #True
          
        Case BasicKeywords(#KEYWORD_DisableASM), BasicKeywords(#KEYWORD_EndHeaderSection)
          DisableFormatting = #False
      EndSelect

    ElseIf SeparatorChar = ':' And *Cursor\a[1] = ':'

      ; --------------------- Module Prefix ------------------------

      Callback(*StringStart, *Cursor-*StringStart, *ModuleColor, 0, 0)
      Callback(*Cursor, 2, *OperatorColor, 0, 0)

      ; do not further process this
      SeparatorChar = #ModuleSeparator
      SeparatorUsed = 1
      *Cursor + 2 ; skip both ::


    ElseIf SeparatorChar = ':' And IsLineStart(*LineStart, *WordStart) And WordLength > 0

      ; --------------------- Labels -------------------------------

      Callback(*StringStart, *Cursor-*StringStart+1, *LabelColor, 0, 0) ; include the : !
      SeparatorUsed = 1



    ElseIf SeparatorChar = '(' And WordLength > 0

      ; --------------------- Procedures / Functions --------------------
      TextChanged = 0

      FunctionPosition = IsAPIFunction(*WordStart, WordLength)
      If FunctionPosition > -1

        If DisableFormatting = #False And EnableCaseCorrection
          TextChanged = CopyMemoryCheck(APIFunctions(FunctionPosition)\Ascii, *WordStart, WordLength-1)
        EndIf

      Else
        FunctionPosition = IsBasicFunction(UCase(WordStart$))
        If FunctionPosition > -1

          If DisableFormatting = #False And EnableCaseCorrection And OldSeparatorChar <> '.' ; do not correct structure names
            TextChanged = CopyMemoryCheck(BasicFunctions(FunctionPosition)\Ascii, *WordStart, WordLength)
          EndIf

        EndIf

      EndIf

      If OldSeparatorChar = '.'
        WordStart$ = UCase(WordStart$)
        If Len(WordStart$) = 1 And FindString(#BasicTypeChars, WordStart$, 1) ; check for the basic types
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, TextChanged)
        Else
          Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, TextChanged)
        EndIf
      ElseIf OldSeparatorChar = #ModuleSeparator And OlderSeparatorChar = '.'
        ; List foo.module::bar()
        Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, TextChanged)
      Else
        Callback(*StringStart, *Cursor-*StringStart, *PureKeywordColor, 0, TextChanged)
      EndIf

    ElseIf IsDecNumber(*WordStart, WordLength) Or (OldSeparatorChar = '.' And ByteUcase(PeekB(*WordStart)) = 'E' And IsDecNumber(*WordStart+1, WordLength-1)) ; allow 1.e10 by skipping the 'E' in the test

      ; ---------------------- Decimal Numbers -----------------------

      If SeparatorChar = '.'
        Callback(*StringStart, *Cursor-*StringStart+1, *NumberColor, 0, 0) ; include the .
        SeparatorUsed = 1
      Else
        Callback(*StringStart, *Cursor-*StringStart, *NumberColor, 0, 0)
      EndIf

    ElseIf ASMEnabled And IsASMKeyword(WordStart$)

      ; -------------------- ASM Keywords ---------------------------

      ; do not correct the word the user is currently typing, because it will change the case of any word that starts with a PB keyword, which is not good
      If DisableFormatting = #False And EnableCaseCorrection And (CursorPosition = 0 Or CursorPosition < *WordStart-*InBuffer Or CursorPosition > *WordEnd-*InBuffer)
        TextChanged = CopyMemoryCheck(ToAscii(ASMKeyword$), *WordStart, WordLength) ; no PokeS() as it will write a 0!
        Callback(*StringStart, *Cursor-*StringStart, *ASMKeywordColor, 0, TextChanged)
      Else
        Callback(*StringStart, *Cursor-*StringStart, *ASMKeywordColor, 0, 0)
      EndIf

    ElseIf OldSeparatorChar = '\' Or SeparatorChar = '\'

      ; ---------------------- Structures --------------------------
      Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, 0)


    ElseIf SeparatorChar = '.' Or OldSeparatorChar = '.' Or (OldSeparatorChar = #ModuleSeparator And OlderSeparatorChar = '.')

      ; ---------------------- Structures Or PB Types -----------------

      If OldSeparatorChar = '.'
        WordStart$ = UCase(WordStart$)
        If Len(WordStart$) = 1 And FindString(#BasicTypeChars, WordStart$, 1) ; check for the basic types
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
        Else
          Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, 0)
        EndIf

      Else
        *ForwardCursor.HighlightPTR = *Cursor+1
        While *ForwardCursor.HighlightPTR < *InBufferEnd And ValidCharacters(*ForwardCursor\a)
          *ForwardCursor + 1
        Wend
        NextWord$ = UCase(PeekAsciiLength(*Cursor+1, *ForwardCursor-*Cursor-1))

        ; check further in case of a module prefix here
        While *ForwardCursor < *InBufferEnd And *ForwardCursor\b = ' ' Or *ForwardCursor\b = 9: *ForwardCursor + 1: Wend
        If *ForwardCursor < *InBufferEnd-2 And *ForwardCursor\b = ':' And PeekB(*ForwardCursor + 1) = ':'
          IsModulePrefix = 1
          *ForwardCursor + 2
          While *ForwardCursor < *InBufferEnd And *ForwardCursor\b = ' ' Or *ForwardCursor\b = 9: *ForwardCursor + 1: Wend
          While *ForwardCursor.HighlightPTR < *InBufferEnd And ValidCharacters(*ForwardCursor\a)
            *ForwardCursor + 1
          Wend
          While *ForwardCursor < *InBufferEnd And *ForwardCursor\b = ' ' Or *ForwardCursor\b = 9: *ForwardCursor + 1: Wend
        Else
          IsModulePrefix = 0
        EndIf

        If *ForwardCursor\b = '('  ; Dim whatever.xy() or NewList...
          Callback(*StringStart, *Cursor-*StringStart, *PureKeywordColor, 0, 0)

        ElseIf IsModulePrefix = 0 And Len(NextWord$) = 1 And FindString(#BasicTypeChars, NextWord$, 1) ; check for the basic types
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)

          ; special cases for p-ascii, p-unicode, p-bstr
          ;
        ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-8 And CompareMemoryString(*Cursor, ToAscii(".p-ascii"), #PB_String_NoCaseAscii, 8, #PB_Ascii) = 0
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
          Callback(*Cursor, 1, *SeparatorColor, 0, 0)
          Callback(*Cursor+1, 7, *NormalTextColor, 0, 0)
          *Cursor + 8
          SeparatorChar = #SkipSeparator

        ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-10 And CompareMemoryString(*Cursor, ToAscii(".p-unicode"), #PB_String_NoCaseAscii, 10, #PB_Ascii) = 0
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
          Callback(*Cursor, 1, *SeparatorColor, 0, 0)
          Callback(*Cursor+1, 9, *NormalTextColor, 0, 0)
          *Cursor + 10
          SeparatorChar = #SkipSeparator

        ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-7 And CompareMemoryString(*Cursor, ToAscii(".p-bstr"), #PB_String_NoCaseAscii, 7, #PB_Ascii) = 0
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
          Callback(*Cursor, 1, *SeparatorColor, 0, 0)
          Callback(*Cursor+1, 6, *NormalTextColor, 0, 0)
          *Cursor + 7
          SeparatorChar = #SkipSeparator

        ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-10 And CompareMemoryString(*Cursor, ToAscii(".p-variant"), #PB_String_NoCaseAscii, 10, #PB_Ascii) = 0
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
          Callback(*Cursor, 1, *SeparatorColor, 0, 0)
          Callback(*Cursor+1, 9, *NormalTextColor, 0, 0)
          *Cursor + 10
          SeparatorChar = #SkipSeparator

        ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-7 And CompareMemoryString(*Cursor, ToAscii(".p-utf8"), #PB_String_NoCaseAscii, 7, #PB_Ascii) = 0
          Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
          Callback(*Cursor, 1, *SeparatorColor, 0, 0)
          Callback(*Cursor+1, 6, *NormalTextColor, 0, 0)
          *Cursor + 7
          SeparatorChar = #SkipSeparator


        Else
          Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, 0)

        EndIf
      EndIf


    ElseIf *Cursor-*StringStart > 0

      ; ---------------------- Normal Text -------------------------
      Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)

    EndIf

    ; Everything that has a Word before a separator has been processed and outputted now.
    ; Only separators remain

    If SeparatorUsed = 0 And SeparatorChar <> #SkipSeparator

      If SeparatorChar = '!' And IsLineStart(*LineStart, *Cursor)

        ; --------------------- ASM or C Line with "!" ---------------------

        *StringStart = *Cursor ; highlight to lineend (do not stop on comment as ASM and C are different here)
        While *Cursor < *InBufferEnd And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b
          *Cursor + 1
        Wend

        If *Cursor\b <> ';'
          NewLine = 1

          If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
            *Cursor + 1
          EndIf

          If *Cursor < *InBufferEnd ; include the newline
            *Cursor + 1
          EndIf
        EndIf

        Callback(*StringStart, *Cursor-*StringStart, *ASMKeywordColor, 0, 0)
        SeparatorChar = #SkipSeparator



      ElseIf SeparatorChar = '"'

        ; --------------------- Strings ----------------------------

        *StringStart = *Cursor ; the position of the Separator
        *Cursor + 1
        While *Cursor < *InBufferEnd And (*Cursor\b <> '"' And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b)
          *Cursor + 1
        Wend

        If *Cursor\b = 10 Or *Cursor\b = 13
          NewLine = 1

          If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
            *Cursor + 1
          EndIf
        EndIf

        If *Cursor < *InBufferEnd ; include the newline or second "
          *Cursor + 1
        EndIf

        Callback(*StringStart, *Cursor-*StringStart, *StringColor, 0, 0) ; include the second " !
        SeparatorChar = #SkipSeparator

      ElseIf SeparatorChar = '~' And *Cursor\a[1] = '"'

        ; --------------------- Strings with escape sequences ----------------------------

        *StringStart = *Cursor ; the position of the ~
        *Cursor + 2

        While *Cursor < *InBufferEnd
          Select *Cursor\b

            Case 0         ; end of input
              Break

            Case 13, 10    ; newline
              NewLine = 1
              If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
                *Cursor + 1
              EndIf
              Break

            Case '"'       ; end of string
              *Cursor + 1
              Break

            Case '\'       ; escape sequence
              If *Cursor+1 < *InBufferEnd
                Select *Cursor\a[1]

                  Case 'a', 'b', 'f', 'n', 'r', 't', 'v', '"', '\'
                    ; correct sequence
                    *Cursor + 2

                  Default
                    ; incorrect sequence. mark it with the "bad brace" color
                    If *Cursor > *StringStart
                      Callback(*StringStart, *Cursor-*StringStart, *StringColor, 0, 0)
                    EndIf
                    Callback(*StringStart, 2, *BadEscapeColor, 0, 0)
                    *Cursor + 2
                    *StringStart = *Cursor

                EndSelect
              Else
                *Cursor + 1
                Break
              EndIf

            Default        ; other char
              *Cursor + 1

          EndSelect
        Wend

        If *Cursor > *StringStart
          Callback(*StringStart, *Cursor-*StringStart, *StringColor, 0, 0)
        EndIf
        SeparatorChar = #SkipSeparator

      ElseIf SeparatorChar = ';'



        ; ------------------- Comments -------------------------

        *StringStart = *Cursor
        WhiteOnly = #True
        While *Cursor < *InBufferEnd And (*Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b)
          If *Cursor\b <> ' ' And *Cursor\b <> 9
            WhiteOnly = #False
          EndIf
          *Cursor + 1
        Wend
        NewLine = 1
        *LineEnd = *Cursor

        If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
          *Cursor + 1
        EndIf

        If *Cursor < *InBufferEnd ; include the newline
          *Cursor + 1
        EndIf

        SeparatorChar = #SkipSeparator

        CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)

          If WhiteOnly Or PeekA(*StringStart + 1) = '-'
            ; no issue scanning in empty comments or marker lines
            Callback(*StringStart, *Cursor-*StringStart, *CommentColor, 0, 0)
          Else
            ; scan/highlight issues
            HighlightCommentIssues(*StringStart, *LineEnd, *Cursor, SourceStringFormat, Callback)
          EndIf

        CompilerElse

          ; no issues support
          Callback(*StringStart, *Cursor-*StringStart, *CommentColor, 0, 0)

        CompilerEndIf

      ElseIf SeparatorChar = '#'

        ; ---------------------- Constants --------------------

        *StringStart = *Cursor
        *Cursor + 1
        While *Cursor < *InBufferEnd And ValidCharacters(*Cursor\a)
          *Cursor + 1
        Wend

        If *Cursor < *InBufferEnd And *Cursor\b = '$' ; string constant
          *Cursor + 1
        EndIf

        ; also do not correct case here if the cursor is over the word
        If DisableFormatting = #False And EnableCaseCorrection And ConstantListSize > 0 And *Cursor > *StringStart + 1 And IsKnownConstant(PeekAsciiLength(*StringStart, *Cursor-*StringStart)) And (CursorPosition = 0 Or CursorPosition < *StringStart-*InBuffer Or CursorPosition > *Cursor-*InBuffer)
          TextChanged = CopyMemoryCheck(ToAscii(KnownConstant$), *StringStart, Len(KnownConstant$))
          Callback(*StringStart, *Cursor-*StringStart, *ConstantColor, 0, TextChanged) ; don't include the current char!
        Else
          Callback(*StringStart, *Cursor-*StringStart, *ConstantColor, 0, 0) ; don't include the current char!
        EndIf

        SeparatorChar = #SkipSeparator ; don't move the cursor at the loop end

      ElseIf SeparatorChar = 39 ; '

        ; --------------------- Numeric Constants -----------------------

        *StringStart = *Cursor ; the position of the Separator
        *Cursor + 1
        While *Cursor < *InBufferEnd And (*Cursor\b <> 39 And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b)
          *Cursor + 1
        Wend

        If *Cursor < *InBufferEnd And (*Cursor\b = 10 Or *Cursor\b = 13)
          NewLine = 1

          If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
            *Cursor + 1
          EndIf
        EndIf

        Callback(*StringStart, *Cursor-*StringStart+1, *ConstantColor, 0, 0) ; include the second ' !
        *Cursor + 1
        SeparatorChar = #SkipSeparator



      ElseIf SeparatorChar = '$'

        ; -------------------------- HEX Values ----------------------------

        *StringStart = *Cursor
        *Cursor + 1
        While *Cursor < *InBufferEnd And ((*Cursor\b >= '0' And *Cursor\b <= '9') Or (*Cursor\b >= 'A' And *Cursor\b <= 'F') Or (*Cursor\b >= 'a' And *Cursor\b <= 'f'))
          *Cursor + 1
        Wend

        Callback(*StringStart, *Cursor-*StringStart, *NumberColor, 0, 0) ; don't include the current char
        SeparatorChar = #SkipSeparator


      ElseIf SeparatorChar = '%'

        ; ---------------------------- % - binary or mod ------------------------

        *StringStart = *Cursor
        *Cursor + 1

        While *Cursor < *InBufferEnd And (*Cursor\b = '1' Or *Cursor\b = '0')
          *Cursor + 1
        Wend

        If *Cursor = *StringStart + 1   ; no numbers found, so not binary
          Callback(*StringStart, 1, *OperatorColor, 0, 0)

        Else  ; binary
          Callback(*StringStart, *Cursor-*StringStart, *NumberColor, 0, 0)

        EndIf
        SeparatorChar = #SkipSeparator


      ElseIf SeparatorChar = '@' Or SeparatorChar = '?'

        ; ------------------------------ Pointer @ or ? --------------------

        IsNumber = 0
        *StringStart = *Cursor
        *Cursor + 1

        While *Cursor < *InBufferEnd And (ValidCharacters(*Cursor\a) Or *Cursor\b = '$')
          *Cursor + 1
        Wend

        Callback(*StringStart, *Cursor-*StringStart, *PointerColor, 0, 0) ; don't include the current char!
        SeparatorChar = #SkipSeparator                                    ; don't move the cursor at the loop end



      ElseIf SeparatorChar = '*'

        ; ---------------------- * - Pointer or Operator -----------------------------

        If ValidCharacters(*Cursor\a[1]) = 0 ; surely an operator
          Callback(*Cursor, 1, *OperatorColor, 0, 0)

        Else ; since 5*a is not a pointer, we need to further check..

          *BackCursor.HighlightPTR = *Cursor-1
          IsPointer = 1
          While *BackCursor >= *InBuffer And *BackCursor\b <> 10 And *BackCursor\b <> 13
            If *BackCursor\b = '(' Or *BackCursor\b = ':' Or *BackCursor\b = '[' Or *BackCursor\b = ',' Or *BackCursor\b = '*' Or *BackCursor\b = '=' Or *BackCursor\b = '+' Or *BackCursor\b = '-' Or *BackCursor\b = '/' Or *BackCursor\b = '@' Or *BackCursor\b = '&' Or *BackCursor\b = '|' Or *BackCursor\b = '!' Or *BackCursor\b = '~' Or *BackCursor\b = '<' Or *BackCursor\b = '>' Or *BackCursor\b = '\' Or *BackCursor\b = '%'
              ; must be a pointer
              Break
            ElseIf ValidCharacters(*BackCursor\a) Or *BackCursor\b = ')' Or *BackCursor\b = ']' Or *BackCursor\b = '.'
              ; can't be a pointer
              IsPointer = 0
              Break
            EndIf
            *BackCursor - 1
          Wend

          If ValidCharacters(*BackCursor\a)  ; in this case, check if this was a PB Keyword
            *CheckEnd = *BackCursor
            While *BackCursor >= *InBuffer And ValidCharacters(*BackCursor\a)
              *BackCursor - 1
            Wend
            IsPointer = IsBasicKeyword(PeekAsciiLength(*BackCursor+1, *CheckEnd-*BackCursor))

            If IsPointer = 0 And *BackCursor >= *InBuffer And *BackCursor\b = '.' ; go further back, as it could be "Define.l *ptr"
              *BackCursor - 1
              *CheckEnd = *BackCursor
              While *BackCursor >= *InBuffer And ValidCharacters(*BackCursor\a)
                *BackCursor - 1
              Wend
              IsPointer = IsBasicKeyword(PeekAsciiLength(*BackCursor+1, *CheckEnd-*BackCursor))
            EndIf
          EndIf

          If IsPointer = 0
            Callback(*Cursor, 1, *OperatorColor, 0, 0)

          Else
            *StringStart = *Cursor
            *Cursor + 1
            While *Cursor < *InBufferEnd And (ValidCharacters(*Cursor\a) Or *Cursor\b = '$')
              *Cursor + 1
            Wend

            Callback(*StringStart, *Cursor-*StringStart, *PointerColor, 0, 0)
            SeparatorChar = #SkipSeparator ; don't move the cursor at the loop end

          EndIf

        EndIf




      ElseIf SeparatorChar = '=' Or SeparatorChar = '+' Or SeparatorChar = '-' Or SeparatorChar = '/' Or SeparatorChar = '&' Or SeparatorChar = '|' Or SeparatorChar = '!' Or SeparatorChar = '~' Or SeparatorChar = '<' Or SeparatorChar = '>'

        ; ------------------------- Operators --------------------------------
        ; = + - / & | ! ~ < >

        Callback(*Cursor, 1, *OperatorColor, 0, 0)



      ElseIf SeparatorChar = '(' Or SeparatorChar = ')' Or SeparatorChar = '[' Or SeparatorChar = ']' Or SeparatorChar = '.' Or SeparatorChar = ',' Or SeparatorChar = ':' Or SeparatorChar = '\'

        ; ------------------------- Separators -------------------------------
        ; ( ) [ ] . , : \

        Callback(*Cursor, 1, *SeparatorColor, 0, 0)


      ElseIf SeparatorChar > 0

        ; ----------------------- Normal Text Separator --------------

        Callback(*Cursor, 1, *NormalTextColor, 0, 0)
      EndIf
    EndIf

    If SeparatorChar > 0  ; #SkipSeparator is -2
      *Cursor + 1         ; move away from the separator char
    EndIf

    OlderSeparatorChar = OldSeparatorChar
    OldSeparatorChar = SeparatorChar

    If NewLine
      *LineStart = *Cursor
      OldSeparatorChar = 0
      OlderSeparatorChar = 0
    EndIf

    If SeparatorChar = #EndSeparator ; null byte encountered, quit the loop!
      Break
    EndIf
  Wend


EndProcedure

;- Keywords - BASIC and ASM
; Note: The IncludeFile directive requires the absolute path as it's used by
;       the DocMaker and SyntaxHighlighting DLL.
IncludeFile #PB_Compiler_FilePath+"KeywordsData.pbi"
