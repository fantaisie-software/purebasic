; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Tests of the structure / interface helpers (StructureFunctions.pb), used by AutoComplete and the
; structure viewer

PureUnitOptions(MainCode, ThreadOnly)
XIncludeFile "TestEnvironment.pbi"

; Parse the content of a Structure/Interface (between the first line and the End line), return the fields with "|"
Procedure.s ParseFields(Code$, IsInterface = #False)
  Protected NewList Fields.s(), Result$
  Protected *Buffer = UTF8(Code$)
  
  If IsInterface
    ParseInterface(*Buffer, MemorySize(*Buffer) - 1, Fields())
  Else
    ParseStructure(*Buffer, MemorySize(*Buffer) - 1, Fields())
  EndIf
  FreeMemory(*Buffer)
  
  ForEach Fields()
    Result$ + Fields() + "|"
  Next
  ProcedureReturn RTrim(Result$, "|")
EndProcedure

ProcedureUnit Structure_ParseFields()
  Protected Result$ = ParseFields(~"\n  x.l\n  *Next.Item  ; comment\n  Name$\n  Text.s{10}\n  Values.w[4] : y.d\n")
  AssertString(Result$, "x.l|*Next.Item|Name$|Text.s{10}|Values.w[4]|y.d", Result$)
EndProcedureUnit

ProcedureUnit Structure_ParseDynamicFields()
  Protected Result$ = ParseFields(~"\n  Array a.l(0)\n  List Items.Item()\n  Map Names.s()\n  ListSize.i\n")
  AssertString(Result$, "Array a.l(0)|List Items.Item()|Map Names.s()|ListSize.i", Result$)
EndProcedureUnit

ProcedureUnit Structure_ParseAlign()
  Protected Result$ = ParseFields(~" Align #PB_Structure_AlignC\n  a.b\n  b.q\n")
  AssertString(Result$, "a.b|b.q", "the Align part is skipped: " + Result$)
EndProcedureUnit

; An unfinished escaped string ending with a \ in the Align expression (while typing): the \ must not
; skip the newline, which ends the expression
ProcedureUnit Structure_ParseAlignUnfinishedString()
  Protected Result$ = ParseFields(" Align ~" + #DQUOTE$ + "a\" + #LF$ + "  x.l" + #LF$ + "  y.l" + #LF$)
  AssertString(Result$, "x.l|y.l", Result$)
EndProcedureUnit

ProcedureUnit Structure_ParseSkipsDirectives()
  Protected Result$ = ParseFields(~"\n  CompilerIf #PB_Compiler_64Bit\n    a.q\n  CompilerElse\n    a.l\n  CompilerEndIf\n  StructureUnion\n    b.l\n  EndStructureUnion\n")
  AssertString(Result$, "a.q|a.l|b.l", "the fields of both branches and of the union: " + Result$)
EndProcedureUnit

ProcedureUnit Structure_ParseModuleType()
  Protected Result$ = ParseFields(~"\n  p.Module::Point\n")
  AssertString(Result$, "p.Module::Point", Result$)
EndProcedureUnit

ProcedureUnit Interface_ParseMethods()
  Protected Result$ = ParseFields(~"\n  QueryInterface(*riid, *ppvObject)\n  GetName.s() ; comment\n  SetValue(Value.d, \n           Flags = 0)\n  Release()\n", #True)
  AssertString(Result$, "QueryInterface(*riid, *ppvObject)|GetName.s()|SetValue(Value.d, Flags=0)|Release()", "a continued line is joined: " + Result$)
EndProcedureUnit

ProcedureUnit Structure_FieldParts()
  AssertString(StructureFieldKind("Array a.l(0)"), "Array")
  AssertString(StructureFieldKind(#TAB$ + "list Items.Item()"), "List", "case insensitive, tabs")
  AssertString(StructureFieldKind("Map Names.s()"), "Map")
  AssertString(StructureFieldKind("ArraySize.l"), "", "a field starting like a keyword")
  AssertString(StructureFieldKind("x.l"), "")
  
  AssertString(StructureFieldName("Array a.l(0)"), "a")
  AssertString(StructureFieldName("*Next.Item"), "Next", "no * when the field is used")
  AssertString(StructureFieldName("Values.w[4]"), "Values")
  AssertString(StructureFieldName("Text.s{10}"), "Text")
  AssertString(StructureFieldName("Name$"), "Name$")
  
  AssertString(StructureFieldType("*Next.Item"), "Item")
  AssertString(StructureFieldType("List Items . Item()"), "Item")
  AssertString(StructureFieldType("Values.w[4]"), "w")
  AssertString(StructureFieldType("x"), "", "no type")
  
  AssertString(InterfaceFieldName("GetName.s(Index)"), "GetName")
  AssertString(InterfaceFieldName(" Release ()"), "Release")
EndProcedureUnit
