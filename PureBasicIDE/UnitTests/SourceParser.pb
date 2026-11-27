; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the source scanner (SourceParser.pb): the items it finds are used by the procedure browser,
; AutoComplete, folding, the structure viewer...

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

; Scan Code$ like a file of a project, return the found items as "Line:#ITEM_Type:Name" separated by spaces
Procedure.s ScanItems(Code$, *Parser.ParserData)
  Protected Line, Result$, *Item.SourceItem
  
  ScanFile(WriteTestSource(Code$), *Parser)
  
  For Line = 0 To *Parser\SourceItemCount-1
    *Item = *Parser\SourceItemArray\Line[Line]\First
    While *Item
      Select *Item\Type
        Case #ITEM_Procedure, #ITEM_Macro, #ITEM_Structure, #ITEM_Interface, #ITEM_Constant, #ITEM_Prototype, #ITEM_Label, #ITEM_DeclareModule, #ITEM_Module
          Result$ + Str(Line) + ":" + Str(*Item\Type) + ":" + *Item\Name$ + " "
      EndSelect
      *Item = *Item\Next
    Wend
  Next Line
  
  ProcedureReturn RTrim(Result$)
EndProcedure

Macro Item(Line, Type, Name)
  Str(Line) + ":" + Str(Type) + ":" + Name
EndMacro

ProcedureUnit Scan_Declarations()
  Protected Parser.ParserData
  Protected Code$ = "Procedure.i Add(a, b)" + #LF$ +
                    "  ProcedureReturn a + b" + #LF$ +
                    "EndProcedure" + #LF$ +
                    "Macro Twice(x) : (x*2) : EndMacro" + #LF$ +
                    "Structure Point3D : x.f : y.f : z.f : EndStructure" + #LF$ +
                    "#Answer = 42" + #LF$ +
                    "Prototype.i ProtoAdd(a, b)" + #LF$ +
                    "Interface IShape : Area.d() : EndInterface" + #LF$ +
                    "MyLabel:"
  Protected Result$ = ScanItems(Code$, @Parser)
  
  Assert(FindString(Result$, Item(0, #ITEM_Procedure, "Add")), Result$)
  Assert(FindString(Result$, Item(3, #ITEM_Macro, "Twice")), Result$)
  Assert(FindString(Result$, Item(4, #ITEM_Structure, "Point3D")), Result$)
  Assert(FindString(Result$, Item(5, #ITEM_Constant, "#Answer")), Result$)
  Assert(FindString(Result$, Item(6, #ITEM_Prototype, "ProtoAdd")), Result$)
  Assert(FindString(Result$, Item(7, #ITEM_Interface, "IShape")), Result$)
  Assert(FindString(Result$, Item(8, #ITEM_Label, "MyLabel")), Result$)
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Scan_Modules()
  Protected Parser.ParserData
  Protected Code$ = "DeclareModule Geo" + #LF$ +
                    "  Declare.d Area(r.d)" + #LF$ +
                    "EndDeclareModule" + #LF$ +
                    "Module Geo" + #LF$ +
                    "  Procedure.d Area(r.d) : ProcedureReturn #PI * r * r : EndProcedure" + #LF$ +
                    "EndModule"
  Protected Result$ = ScanItems(Code$, @Parser)
  
  Assert(FindString(Result$, Item(0, #ITEM_DeclareModule, "Geo")), Result$)
  Assert(FindString(Result$, Item(3, #ITEM_Module, "Geo")), Result$)
  Assert(FindString(Result$, Item(4, #ITEM_Procedure, "Area")), Result$)
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Scan_CommentsAndStringsIgnored()
  Protected Parser.ParserData
  Protected Result$ = ScanItems(~"; Procedure InComment()\nx$ = \"Procedure InString()\"\n", @Parser)
  
  AssertString(Result$, "", Result$)
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Scan_LineContinuation()
  Protected Parser.ParserData
  Protected Code$ = "Procedure Long(a," + #LF$ +
                    "              b)" + #LF$ +
                    "EndProcedure" + #LF$ +
                    "Procedure Next()" + #LF$ +
                    "EndProcedure"
  Protected Result$ = ScanItems(Code$, @Parser)
  
  AssertString(Result$, Item(0, #ITEM_Procedure, "Long") + " " + Item(3, #ITEM_Procedure, "Next"), Result$)
  FreeSourceItemArray(@Parser)
EndProcedureUnit

; https://www.purebasic.fr/english/viewtopic.php?t=90014
; The first char of a continued line must not be skipped (here the closing ')' and an empty line)
ProcedureUnit Scan_LineContinuationFirstChar()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result$
  Protected Code$ = "Procedure Long(a," + #LF$ +
                    ")" + #LF$ +
                    "EndProcedure" + #LF$ +
                    "Procedure Comment(a, ; comment" + #LF$ +
                    ")" + #LF$ +
                    "EndProcedure" + #CRLF$ +
                    "Procedure Next(a," + #CRLF$ +
                    "b)" + #CRLF$ +
                    "EndProcedure" + #CRLF$ +
                    "Procedure Last()" + #LF$ +
                    "EndProcedure"
  ScanFile(WriteTestSource(Code$), @Parser)
  
  For Line = 0 To Parser\SourceItemCount - 1
    *Item = Parser\SourceItemArray\Line[Line]\First
    While *Item
      If *Item\Type = #ITEM_Procedure
        Result$ + Str(Line) + ":" + *Item\Name$ + *Item\Prototype$ + " "
      EndIf
      *Item = *Item\Next
    Wend
  Next Line
  
  AssertString(Trim(Result$), "0:Long(a, ) 3:Comment(a, ) 6:Next(a, b) 9:Last()", Result$)
  FreeSourceItemArray(@Parser)
EndProcedureUnit

; https://www.purebasic.fr/english/viewtopic.php?t=90014
; https://www.purebasic.fr/english/viewtopic.php?t=90014
; The positions and lengths are words: on a very long line they are capped, not wrapped to negative values
ProcedureUnit Scan_VeryLongLine()
  Protected Parser.ParserData, *Item.SourceItem, Found
  ScanFile(WriteTestSource("Foo(" + Space(40000) + "1) : Global Late.l"), @Parser)
  
  *Item = Parser\SourceItemArray\Line[0]\First
  While *Item
    Select *Item\Type
      Case #ITEM_UnknownBraced
        Assert(*Item\FullLength = 32767, "FullLength = " + Str(*Item\FullLength))
        Found + 1
      Case #ITEM_Variable
        Assert(*Item\Position = 32767, "Position = " + Str(*Item\Position))
        Found + 1
    EndSelect
    *Item = *Item\Next
  Wend
  Assert(Found = 2, "items found: " + Str(Found))
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Parser_CleanupEscapedString()
  Protected Result$ = Parser_Cleanup(~"a$ = ~\"x\\ty\",  b")
  AssertString(Result$, ~"a$=~\"x\\ty\", b", Result$)
EndProcedureUnit

;- Navigation in the scanned items (keyword matching, loops, procedures...)

; Lines:       0                   1                 2                     3                                  4
Global NestedCode$ = "Procedure Test(a)" + #LF$ + "  If a = 1" + #LF$ + "    For i = 1 To 10" + #LF$ + "      If i = 5 : Break : EndIf" + #LF$ + "    Next" + #LF$ +
                     "  ElseIf a = 2" + #LF$ + "    Repeat" + #LF$ + "      While #True : Break : Wend" + #LF$ + "    Until #True" + #LF$ +
                     "  Else" + #LF$ + "    ProcedureReturn 0" + #LF$ + "  EndIf" + #LF$ + "EndProcedure" + #LF$ + "If a : EndIf"
;                    5                    6                    7                                       8
;                    9                    10                             11                    12                     13

; The keyword item on Line (the first one, or the one after the Skip first ones)
Procedure KeywordItem(*Parser.ParserData, Line, Keyword, Skip = 0)
  Protected *Item.SourceItem = *Parser\SourceItemArray\Line[Line]\First
  While *Item
    If *Item\Type = #ITEM_Keyword And *Item\Keyword = Keyword
      If Skip = 0
        ProcedureReturn *Item
      EndIf
      Skip - 1
    EndIf
    *Item = *Item\Next
  Wend
  Fail("No keyword " + Str(Keyword) + " on line " + Str(Line))
EndProcedure

; Line and keyword of the item found by Match(), or "none" / "mismatch:..."
Macro FoundKeyword(Function, StartLine, StartKeyword, Skip = 0)
  ; (a macro, as the procedures take pointers to the line and the item)
  Bool(#True) : Line = StartLine : *Item = KeywordItem(@Parser, StartLine, StartKeyword, Skip) : Result = Function(@Parser, @Line, @*Item)
EndMacro

Procedure.s Found(Result, Line, *Item.SourceItem)
  If *Item = 0
    ProcedureReturn "none"
  ElseIf Result = #False
    ProcedureReturn "mismatch:" + Str(Line) + ":" + BasicKeywordsReal(*Item\Keyword)
  Else
    ProcedureReturn Str(Line) + ":" + BasicKeywordsReal(*Item\Keyword)
  EndIf
EndProcedure

ProcedureUnit Navigation_MatchKeywords()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result
  ScanFile(WriteTestSource(NestedCode$), @Parser)
  
  FoundKeyword(MatchKeywordForward, 1, #KEYWORD_If)
  AssertString(Found(Result, Line, *Item), "5:ElseIf", Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordForward, 5, #KEYWORD_ElseIf)
  AssertString(Found(Result, Line, *Item), "9:Else", Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordForward, 9, #KEYWORD_Else)
  AssertString(Found(Result, Line, *Item), "11:EndIf", "the nested If/EndIf are skipped" + ": " + Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordForward, 3, #KEYWORD_If)
  AssertString(Found(Result, Line, *Item), "3:EndIf", "on the same line" + ": " + Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordForward, 6, #KEYWORD_Repeat)
  AssertString(Found(Result, Line, *Item), "8:Until", Found(Result, Line, *Item))
  
  FoundKeyword(MatchKeywordBackward, 11, #KEYWORD_EndIf)
  AssertString(Found(Result, Line, *Item), "9:Else", Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordBackward, 4, #KEYWORD_Next)
  AssertString(Found(Result, Line, *Item), "2:For", Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordBackward, 7, #KEYWORD_Wend)
  AssertString(Found(Result, Line, *Item), "7:While", Found(Result, Line, *Item))
  
  FoundKeyword(MatchKeywordForward, 3, #KEYWORD_Break)
  Assert(Result = #True And *Item = 0, "Break has no matching keyword")
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Navigation_KeywordMismatch()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result
  ScanFile(WriteTestSource("If a" + #LF$ + "  For i = 1 To 2" + #LF$ + "EndIf" + #LF$ + "While b"), @Parser)
  
  FoundKeyword(MatchKeywordForward, 1, #KEYWORD_For)
  AssertString(Found(Result, Line, *Item), "mismatch:2:EndIf", Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordBackward, 2, #KEYWORD_EndIf)
  AssertString(Found(Result, Line, *Item), "mismatch:1:For", Found(Result, Line, *Item))
  FoundKeyword(MatchKeywordForward, 3, #KEYWORD_While)
  Assert(Result = #False And *Item = 0, "no Wend")
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Navigation_FindLoopStart()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result
  ScanFile(WriteTestSource(NestedCode$), @Parser)
  
  FoundKeyword(FindLoopStart, 3, #KEYWORD_Break)
  AssertString(Found(Result, Line, *Item), "2:For", "the If is not a loop" + ": " + Found(Result, Line, *Item))
  FoundKeyword(FindLoopStart, 7, #KEYWORD_Break)
  AssertString(Found(Result, Line, *Item), "7:While", "the inner loop" + ": " + Found(Result, Line, *Item))
  FoundKeyword(FindLoopStart, 8, #KEYWORD_Until)
  AssertString(Found(Result, Line, *Item), "6:Repeat", "from the loop end" + ": " + Found(Result, Line, *Item))
  FoundKeyword(FindLoopStart, 10, #KEYWORD_ProcedureReturn)
  Assert(Result = #False And *Item = 0, "not in a loop (the procedure start ends the search)")
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Navigation_FindBlockStart()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result
  ScanFile(WriteTestSource(NestedCode$), @Parser)
  
  Line = 10 : *Item = KeywordItem(@Parser, 10, #KEYWORD_ProcedureReturn)
  Assert(FindBlockStart(@Parser, @Line, @*Item, #False))
  AssertString(Found(#True, Line, *Item), "9:Else", Found(#True, Line, *Item))
  
  Line = 4 : *Item = KeywordItem(@Parser, 4, #KEYWORD_Next)
  Assert(FindBlockStart(@Parser, @Line, @*Item, #False))
  AssertString(Found(#True, Line, *Item), "2:For", "the If/EndIf inside is skipped" + ": " + Found(#True, Line, *Item))
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Navigation_InsideProcedure()
  Protected Parser.ParserData, Line, *Item.SourceItem
  ScanFile(WriteTestSource(NestedCode$), @Parser)
  
  Line = 7 : *Item = KeywordItem(@Parser, 7, #KEYWORD_Wend)
  Assert(FindProcedureStart(@Parser, @Line, @*Item))
  Assert(Line = 0 And *Item\Type = #ITEM_Procedure And *Item\Name$ = "Test")
  
  Assert(ItemInsideProcedure(@Parser, 10, KeywordItem(@Parser, 10, #KEYWORD_ProcedureReturn)))
  Assert(ItemInsideProcedure(@Parser, 13, KeywordItem(@Parser, 13, #KEYWORD_If)) = #False, "after EndProcedure")
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Navigation_LocateSourceItem()
  Protected Parser.ParserData, *Item.SourceItem
  ScanFile(WriteTestSource(NestedCode$), @Parser)
  
  ; "      If i = 5 : Break : EndIf": Break is at 0-based char 17
  *Item = LocateSourceItem(@Parser, 3, 19)
  Assert(*Item And *Item\Type = #ITEM_Keyword And *Item\Keyword = #KEYWORD_Break)
  Assert(LocateSourceItem(@Parser, 3, 17) = *Item, "at the start")
  Assert(LocateSourceItem(@Parser, 3, 22) = *Item, "just after the end")
  Assert(LocateSourceItem(@Parser, 3, 0) = 0, "nothing in the indentation")
  Assert(LocateSourceItem(@Parser, 99, 0) = 0, "after the last line")
  Assert(LocateSourceItem(@Parser, -1, 0) = 0)
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

;- Line continuation and encodings

ProcedureUnit Parser_IsContinuedLineStart()
  Assert(IsContinuedLineStart("x = Foo(1,"))
  Assert(IsContinuedLineStart("x = a +  ; comment"))
  Assert(IsContinuedLineStart("If a Or"))
  Assert(IsContinuedLineStart("If a AND "))
  Assert(IsContinuedLineStart("x = a | "))
  Assert(IsContinuedLineStart("x = a Xor"))
  Assert(IsContinuedLineStart("x = Foo(1)") = #False)
  Assert(IsContinuedLineStart("x = Color") = #False, "a word ending with 'or'")
  Assert(IsContinuedLineStart("x = Band") = #False, "a word ending with 'and'")
  Assert(IsContinuedLineStart(~"x$ = \"a,\"") = #False, "a , in a string")
  Assert(IsContinuedLineStart("; a,") = #False, "a , in a comment")
  Assert(IsContinuedLineStart("! mov eax,") = #False, "inline assembly")
EndProcedureUnit

ProcedureUnit Parser_CharsBytes()
  Protected Line$ = "x$ = " + #DQUOTE$ + "é€" + #DQUOTE$
  
  Assert(CharsToBytes(Line$, 0, 1, 8) = 11, "UTF-8: é is 2 bytes, € is 3")
  Assert(CharsToBytes(Line$, 6, 1, 1) = 2)
  Assert(CharsToBytes(Line$, 0, 0, 7) = 7, "ASCII")
  
  Assert(BytesToChars(Line$, 0, 1, 11) = 8)
  Assert(BytesToChars(Line$, 6, 1, 5) = 2)
  Assert(BytesToChars(Line$, 0, 0, 7) = 7, "ASCII")
  Assert(BytesToChars(Line$, 0, 1, 100) = Len(Line$), "stops at the line end")
EndProcedureUnit

;- More scanned items

ProcedureUnit Scan_Variables()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result$
  ScanFile(WriteTestSource("Global Counter.l, Name$" + #LF$ + "Global NewList Items.Point()" + #LF$ + "Global Dim Grid.b(10, 10)" + #LF$ + "Global NewMap Names.s()" + #LF$ + "Define *Buffer.Ascii"), @Parser)
  
  For Line = 0 To Parser\SourceItemCount - 1
    *Item = Parser\SourceItemArray\Line[Line]\First
    While *Item
      Select *Item\Type
        Case #ITEM_Variable, #ITEM_Array, #ITEM_LinkedList, #ITEM_Map
          Result$ + Str(Line) + ":" + Str(*Item\Type) + ":" + *Item\Name$ + ":" + StringField(*Item\Type$, 1, #LF$) + " "
      EndSelect
      *Item = *Item\Next
    Wend
  Next Line
  
  Assert(FindString(Result$, "0:" + Str(#ITEM_Variable) + ":Counter:l "), Result$)
  Assert(FindString(Result$, "0:" + Str(#ITEM_Variable) + ":Name$:s "), "the $ suffix is a string: " + Result$)
  Assert(FindString(Result$, "1:" + Str(#ITEM_LinkedList) + ":Items:point "), "the types are stored in lowercase: " + Result$)
  Assert(FindString(Result$, "2:" + Str(#ITEM_Array) + ":Grid:b "), Result$)
  Assert(FindString(Result$, "3:" + Str(#ITEM_Map) + ":Names:s "), Result$)
  Assert(FindString(Result$, "4:" + Str(#ITEM_Variable) + ":*Buffer:ascii "), Result$)
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

; https://www.purebasic.fr/english/viewtopic.php?t=90014
; The variables after an escaped string or a continued line in an initial value
ProcedureUnit Scan_VariablesAfterInitialValues()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result$
  ScanFile(WriteTestSource(~"Global a$ = ~\"x\\n\", b.l\nGlobal c = Max(1,\n), d.w\nGlobal e.b"), @Parser)
  
  For Line = 0 To Parser\SourceItemCount - 1
    *Item = Parser\SourceItemArray\Line[Line]\First
    While *Item
      If *Item\Type = #ITEM_Variable
        Result$ + Str(Line) + ":" + *Item\Name$ + " "
      EndIf
      *Item = *Item\Next
    Wend
  Next Line
  
  AssertString(Trim(Result$), "0:a$ 0:b 1:c 2:d 3:e", Result$)
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit

ProcedureUnit Scan_EnumerationAndMarks()
  Protected Parser.ParserData, Line, *Item.SourceItem, Result$
  ScanFile(WriteTestSource(";- Section" + #LF$ + "Enumeration Windows" + #LF$ + "  #Main" + #LF$ + "  #Tools = 5" + #LF$ + "EndEnumeration" + #LF$ + "; TODO: later"), @Parser)
  
  For Line = 0 To Parser\SourceItemCount - 1
    *Item = Parser\SourceItemArray\Line[Line]\First
    While *Item
      Select *Item\Type
        Case #ITEM_Constant, #ITEM_CommentMark
          Result$ + Str(Line) + ":" + Str(*Item\Type) + ":" + *Item\Name$ + " "
      EndSelect
      *Item = *Item\Next
    Wend
  Next Line
  
  Assert(FindString(Result$, "0:" + Str(#ITEM_CommentMark) + ":"), Result$)
  Assert(FindString(Result$, "2:" + Str(#ITEM_Constant) + ":#Main "), Result$)
  Assert(FindString(Result$, "3:" + Str(#ITEM_Constant) + ":#Tools "), Result$)
  
  FreeSourceItemArray(@Parser)
EndProcedureUnit
