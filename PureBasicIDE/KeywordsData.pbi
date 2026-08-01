; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; This file contains the definitions of all the PureBasic/SpiderBasic keywords.
; They were originally part of the "HighlightingEngine.pb" source, and were
; moved to an independent file to allow third party tools to access the keywords
; lists. The Assembly keywords are imported from "AssemblyOperandsX86.pb".

DataSection

  ;- Keywords - BASIC

  ; Note: First is the Keyword in real Case, then the corresponding end-keyword
  ;       (for autocomplete), then whether the tag should include a trailing
  ;       space in autocomplete (if enabled).
  ;       Keywords must be sorted here!

  ; Note: Keep these definitions in sync with the corresponding constants
  ;       defined in "HighlightingEngine.pb".

  BasicKeywords:
  Data$ "Align", "", " "
  Data$ "And", "", " "
  Data$ "Array", "", " "
  Data$ "As", "", " "

  Data$ "Break", "", ""

  Data$ "CallDebugger"     , "", ""
  Data$ "Case"             , "", " "
  Data$ "CompilerCase"     , "", " "
  Data$ "CompilerDefault"  , "", ""
  Data$ "CompilerElse"     , "", ""
  Data$ "CompilerElseIf"   , "", " "
  Data$ "CompilerEndIf"    , "", ""
  Data$ "CompilerEndSelect", "", ""
  Data$ "CompilerError"    , "", " "
  Data$ "CompilerIf"       , "CompilerEndIf"    , " "
  Data$ "CompilerSelect"   , "CompilerEndSelect", " "
  Data$ "CompilerWarning"  , "", " "
  Data$ "Continue"         , "", ""

  Data$ "Data"           , "", " "
  Data$ "DataSection"    , "EndDataSection", ""
  Data$ "Debug"          , "", " "
  Data$ "DebugLevel"     , "", " "
  Data$ "Declare"        , "", ""
  CompilerIf Not #SpiderBasic
    Data$ "DeclareC"       , "", ""
    Data$ "DeclareCDLL"    , "", ""
    Data$ "DeclareDLL"     , "", ""
  CompilerEndIf
  Data$ "DeclareModule"  , "EndDeclareModule", " "
  Data$ "Default"        , "", ""
  Data$ "Define"         , "", " "
  Data$ "Dim"            , "", " "
  CompilerIf Not #SpiderBasic
    Data$ "DisableASM"     , "", ""
  CompilerEndIf
  Data$ "DisableDebugger", "", ""
  Data$ "DisableExplicit", "", ""
  CompilerIf #SpiderBasic
    Data$ "DisableJS"     , "", ""
  CompilerEndIf
  Data$ "DisablePureLibrary", "", ""

  Data$ "Else"              , "", ""
  Data$ "ElseIf"            , "", " "
  CompilerIf Not #SpiderBasic
    Data$ "EnableASM"         , "", ""
  CompilerEndIf
  Data$ "EnableDebugger"    , "", ""
  Data$ "EnableExplicit"    , "", ""
  CompilerIf #SpiderBasic
      Data$ "EnableJS"        , "", ""
  CompilerEndIf
  Data$ "End"               , "", ""
  Data$ "EndDataSection"    , "", ""
  Data$ "EndDeclareModule"  , "", ""
  Data$ "EndEnumeration"    , "", ""
  Data$ "EndHeaderSection"        , "", ""
  Data$ "EndIf"             , "", ""
  Data$ "EndImport"         , "", ""
  Data$ "EndInterface"      , "", ""
  Data$ "EndMacro"          , "", ""
  Data$ "EndModule"         , "", ""
  Data$ "EndProcedure"      , "", ""
  Data$ "EndSelect"         , "", ""
  Data$ "EndStructure"      , "", ""
  CompilerIf Not #SpiderBasic
    Data$ "EndStructureUnion" , "", ""
  CompilerEndIf
  Data$ "EndWith"           , "", ""
  Data$ "Enumeration"       , "EndEnumeration", " "
  Data$ "EnumerationBinary" , "EndEnumeration", " "
  Data$ "Extends"           , "", " "

  CompilerIf Not #SpiderBasic
    Data$ "FakeReturn"   , "", ""
  CompilerEndIf
  Data$ "For"          , "Next", " "
  Data$ "ForEach"      , "Next", " "
  Data$ "ForEver"      , "", ""

  Data$ "Global", "", " "
  CompilerIf Not #SpiderBasic
    Data$ "Gosub" , "", " "
    Data$ "Goto"  , "", " "
  CompilerEndIf
  
  Data$ "HeaderSection"        , "EndHeaderSection", ""

  Data$ "If"            , "EndIf", " "
  Data$ "Import"        , "EndImport", " "
  CompilerIf Not #SpiderBasic
    Data$ "ImportC"       , "EndImport", " "
  CompilerEndIf
  CompilerIf Not #SpiderBasic
    Data$ "IncludeBinary" , "", " "
  CompilerEndIf
  Data$ "IncludeFile"   , "", " "
  Data$ "IncludePath"   , "", " "
  Data$ "Interface"     , "EndInterface", " "

  Data$ "List", "", " "

  Data$ "Macro", "EndMacro", " "
  Data$ "MacroExpandedCount", "", ""
  Data$ "Map", "", " "
  Data$ "Module"  , "EndModule", " "

  Data$ "NewList", "", " "
  Data$ "NewMap",  "", " "
  Data$ "Next"   , "", ""
  Data$ "Not"    , "", " "

  Data$ "Or", "", " "

  ;Data$ "Parallel"       , "", " "
  Data$ "Procedure"      , "EndProcedure", " "
  CompilerIf Not #SpiderBasic
    Data$ "ProcedureC"     , "EndProcedure", " "
    Data$ "ProcedureCDLL"  , "EndProcedure", " "
    Data$ "ProcedureDLL"   , "EndProcedure", " "
  CompilerEndIf
  Data$ "ProcedureReturn", "", " "
  Data$ "Protected"      , "", " "
  Data$ "Prototype"      , "", " "
  CompilerIf Not #SpiderBasic
    Data$ "PrototypeC"     , "", " "
  CompilerEndIf

  Data$ "Read"   , "", " "
  Data$ "ReDim"  , "", " "
  Data$ "Repeat" , "Until ", ""
  Data$ "Restore", "", " "
  CompilerIf Not #SpiderBasic
    Data$ "Return" , "", ""
  CompilerEndIf
  Data$ "Runtime" , "", ""

  Data$ "Select"        , "EndSelect", " "
  Data$ "Shared"        , "", " "
  Data$ "Static"        , "", " "
  Data$ "Step"          , "", " "
  Data$ "Structure"     , "EndStructure", " "
  CompilerIf Not #SpiderBasic
    Data$ "StructureUnion", "EndStructureUnion", ""
  CompilerEndIf
  Data$ "Swap"          , "", " "

  CompilerIf Not #SpiderBasic
    Data$ "Threaded", "", " "
  CompilerEndIf
  Data$ "To", "", " "

  Data$ "UndefineMacro", "", " "
  Data$ "Until", "", " "
  Data$ "UnuseModule", "", " "
  Data$ "UseModule", "", " "

  Data$ "Wend" , "", ""
  Data$ "While", "Wend", " "
  Data$ "With" , "EndWith", " "

  Data$ "XIncludeFile", "", " "
  Data$ "XOr"         , "", " "


  ;- Keywords - ASM
  ASMKeywords:
  ; Note: The IncludeFile directive requires the absolute path as it's used by
  ;       the DocMaker and SyntaxHighlighting DLL.
  IncludeFile #PB_Compiler_FilePath+"AssemblyOperandsX86.pb"

EndDataSection
