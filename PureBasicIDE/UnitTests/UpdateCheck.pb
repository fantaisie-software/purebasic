; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the update check (UpdateCheck.pb): reading the versions.xml file of the website

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

Procedure.s ReleasesText(List Releases.Release())
  Protected Result$
  ForEach Releases()
    Result$ + Releases()\Name$ + ":" + Str(Releases()\Number) + ":" + Str(Releases()\Category) + ":" + Str(Releases()\Beta) + ":" + Str(Releases()\LTS) + "|"
  Next
  ProcedureReturn RTrim(Result$, "|")
EndProcedure

ProcedureUnit UpdateCheck_ReadVersionFile()
  Protected NewList Releases.Release()
  Protected File$ = WriteTestSource(~"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
                                    ~"<versions xmlns=\"" + #UpdateCheckNamespace$ + ~"\">\n" +
                                    ~"  <version category=\"bugfix\" number=\"6.21\" name=\"6.21\" />\n" +
                                    ~"  <version category=\"beta\" number=\"6.30\" beta=\"3\" name=\"6.30b3\" />\n" +
                                    ~"  <version category=\"final\" number=\" 6.30 \" lts=\"1\" name=\"6.30\" />\n" +
                                    ~"  <version category=\"future\" number=\"9.00\" name=\"unknown category\" />\n" +
                                    ~"  <other number=\"9.00\" />\n" +
                                    ~"</versions>", "versions.xml")
  
  Assert(ReadVersionFile(File$, Releases()))
  AssertString(ReleasesText(Releases()), "6.30:630:" + Str(#CATEGORY_Final) + ":0:1|6.30b3:630:" + Str(#CATEGORY_Beta) + ":3:0|6.21:621:" + Str(#CATEGORY_Bugfix) + ":0:0", "sorted, the newest first: " + ReleasesText(Releases()))
EndProcedureUnit

ProcedureUnit UpdateCheck_InvalidFiles()
  Protected NewList Releases.Release()
  
  AddElement(Releases())
  Assert(ReadVersionFile(UnitTestDirectory$ + "missing.xml", Releases()) = #False)
  Assert(ListSize(Releases()) = 0, "the list is cleared")
  
  Assert(ReadVersionFile(WriteTestSource("<versions><version", "broken.xml"), Releases()) = #False, "invalid XML")
  Assert(ReadVersionFile(WriteTestSource(~"<versions xmlns=\"http://example.com/\"><version category=\"final\" number=\"6.30\" /></versions>", "other.xml"), Releases()) = #False, "another namespace")
  Assert(ListSize(Releases()) = 0)
EndProcedureUnit
