; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the radix tree (RadixTree.pb), which only needs the declarations of Common.pb.
; No PureUnitOptions(MainCode) here: these files have no main code to run, and it keeps the test fast.

IncludePath "../"
XIncludeFile "CompilerFlags.pb"
XIncludeFile "Common.pb"
XIncludeFile "Macro.pb"
XIncludeFile "RadixTree.pb"

ProcedureUnit Radix_InsertLookup()
  Protected Tree.RadixTree
  
  RadixInsert(@Tree, "OpenWindow", 1)
  RadixInsert(@Tree, "OpenFile", 2)
  RadixInsert(@Tree, "Open", 3)
  
  Assert(RadixLookupValue(@Tree, "OpenWindow") = 1)
  Assert(RadixLookupValue(@Tree, "openfile") = 2, "lookup is case-insensitive")
  Assert(RadixLookupValue(@Tree, "Open") = 3, "a prefix of other entries can be a value too")
  Assert(RadixLookupValue(@Tree, "Ope") = 0, "a prefix is not a value")
  Assert(RadixLookupValue(@Tree, "OpenWindows") = 0)
  
  RadixFree(@Tree)
EndProcedureUnit

ProcedureUnit Radix_Enumerate()
  Protected Tree.RadixTree, Result$
  Protected NewList *Values()
  
  RadixInsert(@Tree, "OpenWindow", 1)
  RadixInsert(@Tree, "OpenFile", 2)
  RadixInsert(@Tree, "CloseWindow", 3)
  
  RadixEnumeratePrefix(@Tree, "open", *Values())
  Assert(ListSize(*Values()) = 2)
  
  RadixEnumerateAll(@Tree, *Values())
  ForEach *Values() : Result$ + Str(*Values()) : Next
  AssertString(Result$, "321", "sorted alphabetically: " + Result$)
  
  RadixFree(@Tree)
EndProcedureUnit

ProcedureUnit Radix_EmptyTree()
  Protected Tree.RadixTree, First, Last
  Protected NewList *Values()
  
  Assert(RadixLookupValue(@Tree, "x") = 0)
  Assert(RadixFindRange(@Tree, "x", @First, @Last) = #False)
  RadixEnumerateAll(@Tree, *Values())
  Assert(ListSize(*Values()) = 0)
  RadixFree(@Tree)
EndProcedureUnit

ProcedureUnit Radix_SplitNodes()
  Protected Tree.RadixTree
  
  ; each insert splits the node of the previous one at another place
  RadixInsert(@Tree, "ABCDEF", 1)
  RadixInsert(@Tree, "ABCxyz", 2)
  RadixInsert(@Tree, "AB", 3)
  RadixInsert(@Tree, "ABCD", 4)
  RadixInsert(@Tree, "A", 5)
  RadixInsert(@Tree, "B", 6)
  
  Assert(RadixLookupValue(@Tree, "abcdef") = 1)
  Assert(RadixLookupValue(@Tree, "ABCXYZ") = 2)
  Assert(RadixLookupValue(@Tree, "AB") = 3)
  Assert(RadixLookupValue(@Tree, "ABCD") = 4)
  Assert(RadixLookupValue(@Tree, "A") = 5)
  Assert(RadixLookupValue(@Tree, "B") = 6)
  Assert(RadixLookupValue(@Tree, "ABC") = 0, "only a node, no value")
  Assert(RadixLookupValue(@Tree, "ABCDE") = 0)
  Assert(RadixLookupValue(@Tree, "") = 0)
  
  RadixFree(@Tree)
EndProcedureUnit

; AutoComplete stores the index of each word in a list sorted with #PB_Sort_NoCase, and gets the matches
; of what is typed with RadixFindRange(): compare it with a search in the sorted list. The "_" in the words
; checks that the tree uses the same order as the case insensitive sort ("_" before the letters, as it
; compares in lowercase: https://www.purebasic.fr/english/viewtopic.php?p=615646)
ProcedureUnit Radix_FindRangeMatchesSortedList()
  Protected Tree.RadixTree, i, j, Prefix$, First, Last, ExpectedFirst, ExpectedLast, Found
  Protected NewMap Unique.i()
  
  RandomSeed(547)
  For i = 1 To 2000
    Prefix$ = ""
    For j = 1 To 1 + Random(7)
      Prefix$ + Mid("ABCDE_1", 1 + Random(6), 1)
    Next j
    Unique(Prefix$) = 1
  Next i
  
  Protected Dim Words.s(MapSize(Unique()) - 1)
  i = 0
  ForEach Unique()
    Words(i) = MapKey(Unique())
    i + 1
  Next
  SortArray(Words(), #PB_Sort_Ascending | #PB_Sort_NoCase)
  
  ; values are index + 1, as 0 is no value
  For i = 0 To ArraySize(Words())
    RadixInsert(@Tree, Words(i), i + 1)
  Next i
  For i = 0 To ArraySize(Words())
    Assert(RadixLookupValue(@Tree, LCase(Words(i))) = i + 1, Words(i))
  Next i
  
  For i = 1 To 500
    Prefix$ = ""
    For j = 1 To 1 + Random(3) ; AutoComplete starts with one typed char
      Prefix$ + Mid("ABCDE_1", 1 + Random(6), 1)
    Next j
    
    ExpectedFirst = 0
    ExpectedLast  = 0
    For j = 0 To ArraySize(Words())
      If LCase(Left(Words(j), Len(Prefix$))) = LCase(Prefix$)
        If ExpectedFirst = 0 : ExpectedFirst = j + 1 : EndIf
        ExpectedLast = j + 1
      EndIf
    Next j
    
    Found = RadixFindRange(@Tree, Prefix$, @First, @Last)
    Assert(Found = Bool(ExpectedFirst <> 0), "'" + Prefix$ + "' found")
    If Found
      Assert(First = ExpectedFirst And Last = ExpectedLast, "'" + Prefix$ + "': " + Str(First) + "-" + Str(Last) + " instead of " + Str(ExpectedFirst) + "-" + Str(ExpectedLast))
    EndIf
  Next i
  
  RadixFree(@Tree)
EndProcedureUnit
