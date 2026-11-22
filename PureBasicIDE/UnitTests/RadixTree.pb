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
