; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the helpers of the edit history (EditHistory.pb)

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

ProcedureUnit EditHistory_SqlEscape()
  AssertString(SqlEscape("it's"), "it''s")
  AssertString(SqlEscape("''"), "''''")
  AssertString(SqlEscape("plain"), "plain")
EndProcedureUnit

ProcedureUnit EditHistory_VersionString()
  ; The compiler version strings look like "PureBasic 6.50 beta 7 (Linux - x64)": the OS is redundant here
  AssertString(History_VersionString(#ProductName$ + " 6.50 beta 7 (Linux - x64)"), "6.50 beta 7 (x64)")
  AssertString(History_VersionString(#ProductName$ + " 6.50 (Windows - x86)"), "6.50 (x86)")
  AssertString(History_VersionString(#ProductName$ + " 6.50 (MacOS X - arm64)"), "6.50 (arm64)")
EndProcedureUnit

ProcedureUnit EditHistory_MakeUniqueId()
  Protected Id$ = History_MakeUniqueId()
  Assert(Len(Id$) = 32, Id$)
  Assert(Id$ <> History_MakeUniqueId())
  Protected i
  For i = 1 To 32 ; hex digits
    Assert(FindString("0123456789ABCDEF", Mid(Id$, i, 1)), Id$)
  Next i
EndProcedureUnit

; The history stores a version of a file as a diff to the previous one: Apply(MakeDiff()) must give it back
Procedure DiffRoundTrip(Previous$, Current$)
  Protected Previous.HistoryEvent, Event.HistoryEvent, Size = 4096, Result
  Protected *Diff = AllocateMemory(Size), *Output = AllocateMemory(4096)
  
  Previous\Content = UTF8(Previous$) : Previous\Size = MemorySize(Previous\Content) - 1
  Event\Content    = UTF8(Current$)  : Event\Size    = MemorySize(Event\Content) - 1
  
  If History_MakeDiff(*Diff, @Size, @Event, @Previous)
    Assert(PeekL(*Diff) = Event\Size, "the diff starts with the size of the new version")
    If History_ApplyDiff(*Output, Previous\Content, *Diff, Size)
      Result = Bool(PeekS(*Output, Event\Size, #PB_UTF8 | #PB_ByteLength) = Current$)
    EndIf
  EndIf
  
  FreeMemory(Previous\Content) : FreeMemory(Event\Content) : FreeMemory(*Diff) : FreeMemory(*Output)
  ProcedureReturn Result
EndProcedure

ProcedureUnit EditHistory_DiffRoundTrip()
  Assert(DiffRoundTrip("a" + #LF$ + "b" + #LF$ + "c" + #LF$, "a" + #LF$ + "b" + #LF$ + "c" + #LF$), "unchanged")
  Assert(DiffRoundTrip("a" + #LF$ + "c" + #LF$, "a" + #LF$ + "b" + #LF$ + "c" + #LF$), "insert")
  Assert(DiffRoundTrip("a" + #LF$ + "b" + #LF$ + "c" + #LF$, "a" + #LF$ + "c" + #LF$), "delete")
  Assert(DiffRoundTrip("a" + #CRLF$ + "b" + #CRLF$, "x" + #CRLF$ + "b" + #CRLF$ + "été"), "change, CRLF, no last newline, UTF-8")
  Assert(DiffRoundTrip("", "new" + #LF$), "from an empty file")
  Assert(DiffRoundTrip("old" + #LF$, ""), "to an empty file")
EndProcedureUnit

ProcedureUnit EditHistory_DiffTooLarge()
  Protected Previous.HistoryEvent, Event.HistoryEvent, Size = 16
  Protected *Diff = AllocateMemory(Size)
  
  Previous\Content = UTF8("a") : Previous\Size = 1
  Event\Content    = UTF8("a completely different and longer text") : Event\Size = MemorySize(Event\Content) - 1
  Assert(History_MakeDiff(*Diff, @Size, @Event, @Previous) = #False, "the diff does not fit: the full source is stored")
  
  FreeMemory(Previous\Content) : FreeMemory(Event\Content) : FreeMemory(*Diff)
EndProcedureUnit

ProcedureUnit EditHistory_ApplyInvalidDiff()
  Protected *Diff = AllocateMemory(5), *Output = AllocateMemory(16)
  PokeB(*Diff + 4, 'X')
  Assert(History_ApplyDiff(*Output, *Output, *Diff, 5) = #False, "unknown command")
  FreeMemory(*Diff) : FreeMemory(*Output)
EndProcedureUnit
