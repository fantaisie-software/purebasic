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
