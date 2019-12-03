; 
; PureBasic 5.70 LTS beta 3 (Windows - x64) generated code
; 
; (c) 2018 Fantaisie Software
; 
; The header must remain intact for Re-Assembly
; 
; :DLL
; String
; Memory
; Map
; Object
; SimpleList
; Array
; :System
; kernel32.lib
; :Import
; 
format MS64 COFF
; 
; 
extrn PB_NewMap
extrn PB_AllocateMemory
extrn PB_AllocateMemory2
extrn PB_Asc
extrn PB_CompareMemoryString2
extrn PB_CompareMemoryString4
extrn PB_CopyMemory
extrn PB_FindString2
extrn PB_FreeMap
extrn PB_FreeMemory
extrn PB_FreeMemorys
extrn PB_FreeObjects
extrn PB_InitArray
extrn PB_InitMap
extrn PB_InitMemory
extrn PB_LCase
extrn PB_Left
extrn PB_Len
extrn PB_MemoryStringLength2
extrn PB_Mid2
extrn PB_PeekB
extrn PB_PeekS3
extrn PB_PokeS3
extrn PB_ReAllocateMemory2
extrn PB_Right
extrn PB_StringByteLength2
extrn PB_UCase
extrn GetModuleHandleW
extrn HeapCreate
extrn HeapDestroy
extrn memset
extrn SYS_CopyString
extrn SYS_StringEqual
extrn SYS_StringSuperior
extrn SYS_AllocateString4
extrn SYS_FastAllocateString4
extrn SYS_FastAllocateStringFree4
extrn SYS_FreeString
extrn SYS_AllocateArray
extrn SYS_AllocateMultiArray
extrn PB_CreateMapElement
extrn PB_GetMapElement
extrn PB_StringBase
extrn SYS_InitString
extrn SYS_FreeStrings
; 
extrn PB_StringBasePosition
public _PB_Instance
public PB_ExecutableType
public PB_OpenGLSubsystem
public _PB_MemoryBase
public PB_Instance
public PB_MemoryBase
public PB_EndFunctions
public _DLLEntryPoint@12
public _Procedure42
public _Procedure40

macro pb_public symbol
{
  public  _#symbol
  public symbol
_#symbol:
symbol:
}

macro    pb_align value { rb (value-1) - ($-_PB_DataSection + value-1) mod value }
macro pb_bssalign value { rb (value-1) - ($-_PB_BSSSection  + value-1) mod value }

define ll_initsyntaxcheckarrays_basickeywords l_basickeywords
define ll_initsyntaxcheckarrays_asmkeywords l_asmkeywords
; 
section '.code' code readable executable align 4096
; 
; 
_DLLEntryPoint@12:
  SUB    rsp,40
  CMP    rdx,1
  JNE   .SkipProcessAttach
  MOV    [_PB_Instance],rcx
  CALL   PB_DllInit
  MOV    rcx,[_PB_Instance]
  CALL  _Procedure40
  JMP   .End
.SkipProcessAttach:
  CMP    rdx,2
  JNE   .SkipThreadAttach
  JMP   .End
.SkipThreadAttach:
  CMP    rdx,0
  JNE   .SkipProcessDetach
  CALL  _PB_EOP
  JMP   .End
.SkipProcessDetach:
  CMP    rdx,3
  JNE   .SkipThreadDetach
.SkipThreadDetach:
.End:
  MOV    rax,1
  ADD    rsp,40
  RET
; 
PB_DllInit:
  SUB    rsp,40
  XOR    r8,r8
  MOV    rdx,4096
  XOR    rcx,rcx
  CALL   HeapCreate
  MOV    [PB_MemoryBase],rax
  MOV    rax,PB_DataSectionStart
  MOV    qword [PB_DataPointer],rax
  CALL   SYS_InitString
  CALL   PB_InitArray
  CALL   PB_InitMap
  CALL   PB_InitMemory
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; XIncludeFile "../HilightningEngine.pb"
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; CompilerIf Not Defined(SpiderBasic, #PB_Constant)
; #SpiderBasic = 0
; CompilerEndIf
; 
; 
; 
; CompilerIf Not Defined(MaxSizeHT, #PB_Constant)
; CompilerIf #PB_Compiler_Unicode
; #MaxSizeHT = 65535
; CompilerElse
; CompilerEndIf
; 
; 
; CompilerIf Not Defined(StringToAscii, #PB_Procedure)
; CompilerEndIf
; 
; 
; 
; 
; 
; 
; Global Dim ValidCharacters.b(#MaxSizeHT)  
  SUB    rsp,24
  MOV    rdx,65536
  LEA    rax,[a_ValidCharacters]
  PUSH   rax
  XOR    r9,r9
  MOV    r8,1
  MOV    rcx,1
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_ValidCharacters],rax
; 
; 
; 
; 
; 
; CompilerIf Defined(PUREBASIC_DEBUGGER, #PB_Constant) = 0 
; Structure SourceFileParser
; Encoding.l
; EndStructure
; 
; Structure SourceFile
; EnableASM.l
; DebuggerData.i
; Parser.SourceFileParser
; EndStructure
; 
; #FILE_LoadFunctions = 0
; #FILE_LoadAPI = 1
; 
; #DEFAULT_FunctionFile       = ""
; #DEFAULT_ApiFile            = ""
; 
; CompilerIf #PB_Compiler_Unicode = 0
; 
; 
; 
; Macro PeekAscii(Memory)
; 
; Macro PeekAsciiLength(Memory, Length)
; 
; Macro MemoryAsciiLength(Memory)
; 
; CompilerEndIf  
; 
; CompilerEndIf
; 
; 
; 
; 
; Global *ASMKeywordColor, *BackgroundColor, *BasicKeywordColor, *CommentColor, *ConstantColor, *LabelColor
; Global *NormalTextColor, *NumberColor, *OperatorColor, *PointerColor, *PureKeywordColor, *SeparatorColor, *CustomKeywordColor
; Global *StringColor, *StructureColor, *LineNumberColor, *LineNumberBackColor, *MarkerColor, *CurrentLineColor, *CursorColor, *SelectionColor
; Global *ModuleColor, *BadEscapeColor
; 
; Global *ActiveSource.SourceFile
; Global EnableColoring
; Global EnableCaseCorrection 
; Global EnableKeywordBolding
; Global SourceStringFormat
; 
; Global NbASMKeywords.l 
; 
; CompilerIf #SpiderBasic
; #NbBasicKeywords = 111
; CompilerEndIf
; 
; #BasicTypeChars = "ABCUWLSFDQI" 
; 
; Global Dim BasicKeywordsHT.l(#MaxSizeHT)
  SUB    rsp,24
  MOV    rdx,65536
  LEA    rax,[a_BasicKeywordsHT]
  PUSH   rax
  XOR    r9,r9
  MOV    r8,5
  MOV    rcx,4
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_BasicKeywordsHT],rax
; Global Dim BasicKeywords.s(#NbBasicKeywords)
  SUB    rsp,24
  MOV    rdx,112
  LEA    rax,[a_BasicKeywords]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_BasicKeywords],rax
; Global Dim BasicKeywordsReal.s(#NbBasicKeywords)
  SUB    rsp,24
  MOV    rdx,112
  LEA    rax,[a_BasicKeywordsReal]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_BasicKeywordsReal],rax
; Global Dim BasicKeywordsEndKeywords.s(#NbBasicKeywords)
  SUB    rsp,24
  MOV    rdx,112
  LEA    rax,[a_BasicKeywordsEndKeywords]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_BasicKeywordsEndKeywords],rax
; Global Dim BasicKeywordsSpaces.s(#NbBasicKeywords)
  SUB    rsp,24
  MOV    rdx,112
  LEA    rax,[a_BasicKeywordsSpaces]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_BasicKeywordsSpaces],rax
; 
; Global Dim CustomKeywords.s(0) 
  SUB    rsp,24
  MOV    rdx,1
  LEA    rax,[a_CustomKeywords]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_CustomKeywords],rax
; Global Dim CustomKeywordsHT.l(#MaxSizeHT)
  SUB    rsp,24
  MOV    rdx,65536
  LEA    rax,[a_CustomKeywordsHT]
  PUSH   rax
  XOR    r9,r9
  MOV    r8,5
  MOV    rcx,4
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_CustomKeywordsHT],rax
; Global NbCustomKeywords
; 
; 
; Global Dim ConstantList.S(0)   
  SUB    rsp,24
  MOV    rdx,1
  LEA    rax,[a_ConstantList]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_ConstantList],rax
; Global Dim ConstantHT.L(27, 1)
  MOV    qword [a_ConstantHT+8],28
  MOV    qword [a_ConstantHT+16],2
  SUB    rsp,24
  LEA    rax,[a_ConstantHT]
  PUSH   rax
  XOR    r9,r9
  MOV    r8,5
  MOV    rdx,4
  MOV    rcx,2
  SUB    rsp,32
  CALL   SYS_AllocateMultiArray
  ADD    rsp,64
  MOV    qword [a_ConstantHT],rax
; Global ConstantListSize
; 
; 
; Global Dim ASMKeywordsHT.l(#MaxSizeHT)
  SUB    rsp,24
  MOV    rdx,65536
  LEA    rax,[a_ASMKeywordsHT]
  PUSH   rax
  XOR    r9,r9
  MOV    r8,5
  MOV    rcx,4
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_ASMKeywordsHT],rax
; 
; Global Dim APIFunctionsHT.l(#MaxSizeHT)
  SUB    rsp,24
  MOV    rdx,65536
  LEA    rax,[a_APIFunctionsHT]
  PUSH   rax
  XOR    r9,r9
  MOV    r8,5
  MOV    rcx,4
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_APIFunctionsHT],rax
; Global NewMap BasicFunctionMap.l(4096)
  MOV    rcx,qword 4096
  SUB    rsp,8
  PUSH   rcx
  LEA    r9,[m_BasicFunctionMap]
  XOR    r8,r8
  MOV    rdx,5
  MOV    rcx,4
  SUB    rsp,32
  CALL   PB_NewMap
  ADD    rsp,40
  ADD    rsp,8
; 
; Global BasicKeyword$, ASMKeyword$, KnownConstant$, CustomKeyword$
; Global NbBasicFunctions, NbApiFunctions
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; Enumeration 1
; #KEYWORD_Align
; #KEYWORD_And
; #KEYWORD_Array
; #KEYWORD_As
; 
; #KEYWORD_Break
; 
; #KEYWORD_CallDebugger
; #KEYWORD_Case
; #KEYWORD_CompilerCase
; #KEYWORD_CompilerDefault
; #KEYWORD_CompilerElse
; #KEYWORD_CompilerElseIf
; #KEYWORD_CompilerEndIf
; #KEYWORD_CompilerEndSelect
; #KEYWORD_CompilerError
; #KEYWORD_CompilerIf
; #KEYWORD_CompilerSelect
; #KEYWORD_CompilerWarning
; #KEYWORD_Continue
; 
; #KEYWORD_Data
; #KEYWORD_DataSection
; #KEYWORD_Debug
; #KEYWORD_DebugLevel
; #KEYWORD_Declare
; CompilerIf Not #SpiderBasic
; #KEYWORD_DeclareC
; #KEYWORD_DeclareCDLL
; #KEYWORD_DeclareDLL
; CompilerEndIf
; #KEYWORD_DeclareModule
; #KEYWORD_Default
; #KEYWORD_Define
; #KEYWORD_Dim
; CompilerIf Not #SpiderBasic
; #KEYWORD_DisableASM
; CompilerEndIf
; #KEYWORD_DisableDebugger
; #KEYWORD_DisableExplicit
; CompilerIf #SpiderBasic
; 
; #KEYWORD_Else
; #KEYWORD_ElseIf
; CompilerIf Not #SpiderBasic
; #KEYWORD_EnableASM
; CompilerEndIf
; #KEYWORD_EnableDebugger
; #KEYWORD_EnableExplicit
; CompilerIf #SpiderBasic
; #KEYWORD_End
; #KEYWORD_EndDataSection
; #KEYWORD_EndDeclareModule
; #KEYWORD_EndEnumeration
; #KEYWORD_EndIf
; #KEYWORD_EndImport
; #KEYWORD_EndInterface
; #KEYWORD_EndMacro
; #KEYWORD_EndModule
; #KEYWORD_EndProcedure
; #KEYWORD_EndSelect
; #KEYWORD_EndStructure
; CompilerIf Not #SpiderBasic
; #KEYWORD_EndStructureUnion
; CompilerEndIf
; #KEYWORD_EndWith
; #KEYWORD_Enumeration
; #KEYWORD_EnumerationBinary
; #KEYWORD_Extends
; 
; CompilerIf Not #SpiderBasic
; #KEYWORD_FakeReturn
; CompilerEndIf
; #KEYWORD_For
; #KEYWORD_ForEach
; #KEYWORD_ForEver
; 
; #KEYWORD_Global
; CompilerIf Not #SpiderBasic
; #KEYWORD_Gosub
; #KEYWORD_Goto
; CompilerEndIf
; 
; #KEYWORD_If
; #KEYWORD_Import
; CompilerIf Not #SpiderBasic
; #KEYWORD_ImportC
; #KEYWORD_IncludeBinary
; CompilerEndIf
; #KEYWORD_IncludeFile
; #KEYWORD_IncludePath
; #KEYWORD_Interface
; 
; #KEYWORD_List
; 
; #KEYWORD_Macro
; #KEYWORD_MacroExpandedCount
; #KEYWORD_Map
; #KEYWORD_Module
; 
; #KEYWORD_NewList
; #KEYWORD_NewMap
; #KEYWORD_Next
; #KEYWORD_Not
; 
; #KEYWORD_Or
; 
; 
; #KEYWORD_Procedure
; CompilerIf Not #SpiderBasic
; #KEYWORD_ProcedureC
; #KEYWORD_ProcedureCDLL
; #KEYWORD_ProcedureDLL
; CompilerEndIf
; #KEYWORD_ProcedureReturn
; #KEYWORD_Protected
; #KEYWORD_Prototype
; CompilerIf Not #SpiderBasic
; #KEYWORD_PrototypeC
; CompilerEndIf
; 
; #KEYWORD_Read
; #KEYWORD_ReDim
; #KEYWORD_Repeat
; #KEYWORD_Restore
; CompilerIf Not #SpiderBasic
; #KEYWORD_Return
; CompilerEndIf
; #KEYWORD_Runtime
; 
; #KEYWORD_Select
; #KEYWORD_Shared
; #KEYWORD_Static
; #KEYWORD_Step
; #KEYWORD_Structure
; CompilerIf Not #SpiderBasic
; #KEYWORD_StructureUnion
; CompilerEndIf
; #KEYWORD_Swap
; 
; CompilerIf Not #SpiderBasic
; #KEYWORD_Threaded
; CompilerEndIf
; #KEYWORD_To
; 
; #KEYWORD_UndefineMacro
; #KEYWORD_Until
; #KEYWORD_UnuseModule
; #KEYWORD_UseModule
; 
; #KEYWORD_Wend
; #KEYWORD_While
; #KEYWORD_With
; 
; #KEYWORD_XIncludeFile
; #KEYWORD_XOr
; EndEnumeration
; 
; 
; 
; 
; CompilerIf #SpiderBasic
; 
; 
; CompilerIf #PB_Compiler_EnumerationValue <> #NbBasicKeywords+1
; 
; 
; 
; Prototype HilightCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
; 
; 
; Structure FunctionEntry
; Name$        
; Proto$       
; *Ascii       
; AsciiBuffer.a[256] 
; EndStructure
; 
; Structure HilightPTR
; StructureUnion
; a.a[0]
; b.b[0] 
; c.c[0] 
; w.w[0] 
; u.u[0]
; l.l[0]
; f.f[0]
; q.q[0]
; d.d[0]
; i.i[0]
; EndStructureUnion
; EndStructure
; 
; 
; 
; CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; CompilerIf Defined(PUREBASIC_DEBUGGER, #PB_Constant) 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; Global *KeywordStructure = StringToAscii("Structure") 
  LEA    rax,[_S2]
  MOV    rcx,rax
  CALL  _Procedure0
  MOV    qword [p_KeywordStructure],rax
; Global *KeywordInterface = StringToAscii("Interface")
  LEA    rax,[_S3]
  MOV    rcx,rax
  CALL  _Procedure0
  MOV    qword [p_KeywordInterface],rax
; Global *KeywordExtends   = StringToAscii("Extends")
  LEA    rax,[_S4]
  MOV    rcx,rax
  CALL  _Procedure0
  MOV    qword [p_KeywordExtends],rax
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; #EndSeparator  = -1
; #SkipSeparator = -2
; #ModuleSeparator = -2
; 
; 
; DataSection
; 
; 
; 
; 
; 
; 
; 
; 
; 
; 
; BasicKeywords:
; Data$ "Align", "", " "
; Data$ "And", "", " "
; Data$ "Array", "", " "
; Data$ "As", "", " "    
; 
; Data$ "Break", "", ""
; 
; Data$ "CallDebugger"     , "", ""
; Data$ "Case"             , "", " "
; Data$ "CompilerCase"     , "", " "
; Data$ "CompilerDefault"  , "", ""
; Data$ "CompilerElse"     , "", ""
; Data$ "CompilerElseIf"   , "", " "
; Data$ "CompilerEndIf"    , "", ""
; Data$ "CompilerEndSelect", "", ""
; Data$ "CompilerError"    , "", " "
; Data$ "CompilerIf"       , "CompilerEndIf"    , " "
; Data$ "CompilerSelect"   , "CompilerEndSelect", " "
; Data$ "CompilerWarning"  , "", " "
; Data$ "Continue"         , "", ""
; 
; Data$ "Data"           , "", " "
; Data$ "DataSection"    , "EndDataSection", ""
; Data$ "Debug"          , "", " "
; Data$ "DebugLevel"     , "", " "
; Data$ "Declare"        , "", ""
; CompilerIf Not #SpiderBasic
; Data$ "DeclareC"       , "", ""
; Data$ "DeclareCDLL"    , "", ""
; Data$ "DeclareDLL"     , "", ""
; CompilerEndIf
; Data$ "DeclareModule"  , "EndDeclareModule", " "
; Data$ "Default"        , "", ""
; Data$ "Define"         , "", " "
; Data$ "Dim"            , "", " "
; CompilerIf Not #SpiderBasic
; Data$ "DisableASM"     , "", ""
; CompilerEndIf
; Data$ "DisableDebugger", "", ""
; Data$ "DisableExplicit", "", ""
; CompilerIf #SpiderBasic
; 
; Data$ "Else"              , "", ""
; Data$ "ElseIf"            , "", " "
; CompilerIf Not #SpiderBasic
; Data$ "EnableASM"         , "", ""
; CompilerEndIf
; Data$ "EnableDebugger"    , "", ""
; Data$ "EnableExplicit"    , "", ""
; CompilerIf #SpiderBasic
; Data$ "End"               , "", ""
; Data$ "EndDataSection"    , "", ""
; Data$ "EndDeclareModule"  , "", ""
; Data$ "EndEnumeration"    , "", ""
; Data$ "EndIf"             , "", ""
; Data$ "EndImport"         , "", ""
; Data$ "EndInterface"      , "", ""
; Data$ "EndMacro"          , "", ""
; Data$ "EndModule"         , "", ""
; Data$ "EndProcedure"      , "", ""
; Data$ "EndSelect"         , "", ""
; Data$ "EndStructure"      , "", ""
; CompilerIf Not #SpiderBasic
; Data$ "EndStructureUnion" , "", ""
; CompilerEndIf
; Data$ "EndWith"           , "", ""
; Data$ "Enumeration"       , "EndEnumeration", " "
; Data$ "EnumerationBinary" , "EndEnumeration", " "
; Data$ "Extends"           , "", " "
; 
; CompilerIf Not #SpiderBasic
; Data$ "FakeReturn"   , "", ""
; CompilerEndIf
; Data$ "For"          , "Next", " "
; Data$ "ForEach"      , "Next", " "
; Data$ "ForEver"      , "", ""
; 
; Data$ "Global", "", " "
; CompilerIf Not #SpiderBasic
; Data$ "Gosub" , "", " "
; Data$ "Goto"  , "", " "
; CompilerEndIf
; 
; Data$ "If"            , "EndIf", " "
; Data$ "Import"        , "EndImport", " "
; CompilerIf Not #SpiderBasic
; Data$ "ImportC"       , "EndImport", " "
; CompilerEndIf
; CompilerIf Not #SpiderBasic
; Data$ "IncludeBinary" , "", " "
; CompilerEndIf
; Data$ "IncludeFile"   , "", " "
; Data$ "IncludePath"   , "", " "
; Data$ "Interface"     , "EndInterface", " "
; 
; Data$ "List", "", " "
; 
; Data$ "Macro", "EndMacro", " "
; Data$ "MacroExpandedCount", "", ""
; Data$ "Map", "", " "
; Data$ "Module"  , "EndModule", " "
; 
; Data$ "NewList", "", " "
; Data$ "NewMap",  "", " "
; Data$ "Next"   , "", ""
; Data$ "Not"    , "", " "
; 
; Data$ "Or", "", " "
; 
; 
; Data$ "Procedure"      , "EndProcedure", " "
; CompilerIf Not #SpiderBasic
; Data$ "ProcedureC"     , "EndProcedure", " "
; Data$ "ProcedureCDLL"  , "EndProcedure", " "
; Data$ "ProcedureDLL"   , "EndProcedure", " "
; CompilerEndIf
; Data$ "ProcedureReturn", "", " "
; Data$ "Protected"      , "", " "
; Data$ "Prototype"      , "", " "
; CompilerIf Not #SpiderBasic
; Data$ "PrototypeC"     , "", " "
; CompilerEndIf
; 
; Data$ "Read"   , "", " "
; Data$ "ReDim"  , "", " "
; Data$ "Repeat" , "Until ", ""
; Data$ "Restore", "", " "
; CompilerIf Not #SpiderBasic
; Data$ "Return" , "", ""
; CompilerEndIf
; Data$ "Runtime" , "", ""
; 
; Data$ "Select"        , "EndSelect", " "
; Data$ "Shared"        , "", " "
; Data$ "Static"        , "", " "
; Data$ "Step"          , "", " "
; Data$ "Structure"     , "EndStructure", " "
; CompilerIf Not #SpiderBasic
; Data$ "StructureUnion", "EndStructureUnion", ""
; CompilerEndIf
; Data$ "Swap"          , "", " "
; 
; CompilerIf Not #SpiderBasic
; Data$ "Threaded", "", " "
; CompilerEndIf
; Data$ "To", "", " "
; 
; Data$ "UndefineMacro", "", " "
; Data$ "Until", "", " "
; Data$ "UnuseModule", "", " "
; Data$ "UseModule", "", " "
; 
; Data$ "Wend" , "", ""
; Data$ "While", "Wend", " "
; Data$ "With" , "EndWith", " "
; 
; Data$ "XIncludeFile", "", " "
; Data$ "XOr"         , "", " "
; 
; 
; 
; ASMKeywords:
; IncludeFile #PB_Compiler_FilePath+"AssemblyOperandsX86.pb" 
; 
; 
; 
; Data.l 393
; Data$ "AAA"
; Data$ "AAD"
; Data$ "AAM"
; Data$ "AAS"
; Data$ "ADC"
; Data$ "ADD"
; Data$ "AND"
; Data$ "ARPL"
; Data$ "BOUND"
; Data$ "BSF"
; Data$ "BSR"
; Data$ "BSWAP"
; Data$ "BT"
; Data$ "BTC"
; Data$ "BTR"
; Data$ "BTS"
; Data$ "CALL"
; Data$ "CBW"
; Data$ "CDQ"
; Data$ "CLC"
; Data$ "CLD"
; Data$ "CLI"
; Data$ "CLTS"
; Data$ "CMC"
; Data$ "CMOVA"
; Data$ "CMOVAE"
; Data$ "CMOVB"
; Data$ "CMOVBE"
; Data$ "CMOVC"
; Data$ "CMOVE"
; Data$ "CMOVG"
; Data$ "CMOVGE"
; Data$ "CMOVL"
; Data$ "CMOVLE"
; Data$ "CMOVNA"
; Data$ "CMOVNAE"
; Data$ "CMOVNB"
; Data$ "CMOVNBE"
; Data$ "CMOVNC"
; Data$ "CMOVNE"
; Data$ "CMOVNG"
; Data$ "CMOVNGE"
; Data$ "CMOVNL"
; Data$ "CMOVNLE"
; Data$ "CMOVNO"
; Data$ "CMOVNP"
; Data$ "CMOVNS"
; Data$ "CMOVNZ"
; Data$ "CMOVO"
; Data$ "CMOVP"
; Data$ "CMOVPE"
; Data$ "CMOVPO"
; Data$ "CMOVS"
; Data$ "CMOVZ"
; Data$ "CMP"
; Data$ "CMPS"
; Data$ "CMPSB"
; Data$ "CMPSD"
; Data$ "CMPSW"
; Data$ "CMPXCHG"
; Data$ "CMPXCHG8B"
; Data$ "CWD"
; Data$ "CWDE"
; Data$ "DAA"
; Data$ "DAS"
; Data$ "DB"
; Data$ "DD"
; Data$ "DEC"
; Data$ "DIV"
; Data$ "DW"
; Data$ "EMMS"
; Data$ "ENTER"
; Data$ "ESC"
; Data$ "F2XM1"
; Data$ "FABS"
; Data$ "FADD"
; Data$ "FADDP"
; Data$ "FBLD"
; Data$ "FBSTP"
; Data$ "FCHS"
; Data$ "FCLEX"
; Data$ "FCMOVB"
; Data$ "FCMOVBE"
; Data$ "FCMOVE"
; Data$ "FCMOVNB"
; Data$ "FCMOVNBE"
; Data$ "FCMOVNE"
; Data$ "FCMOVNU"
; Data$ "FCMOVU"
; Data$ "FCOM"
; Data$ "FCOMI"
; Data$ "FCOMIP"
; Data$ "FCOMP"
; Data$ "FCOMPP"
; Data$ "FCOS"
; Data$ "FDECSTP"
; Data$ "FDIV"
; Data$ "FDIVP"
; Data$ "FDIVR"
; Data$ "FDIVRP"
; Data$ "FFREE"
; Data$ "FIADD"
; Data$ "FICOM"
; Data$ "FICOMP"
; Data$ "FIDIV"
; Data$ "FIDIVR"
; Data$ "FILD"
; Data$ "FIMUL"
; Data$ "FINCSTP"
; Data$ "FINIT"
; Data$ "FIST"
; Data$ "FISTP"
; Data$ "FISUB"
; Data$ "FISUBR"
; Data$ "FLD"
; Data$ "FLD1"
; Data$ "FLDCW"
; Data$ "FLDENV"
; Data$ "FLDL2E"
; Data$ "FLDL2T"
; Data$ "FLDLG2"
; Data$ "FLDLN2"
; Data$ "FLDPI"
; Data$ "FLDZ"
; Data$ "FMUL"
; Data$ "FMULP"
; Data$ "FNCLEX"
; Data$ "FNINIT"
; Data$ "FNOP"
; Data$ "FNSAVE"
; Data$ "FNSTCW"
; Data$ "FNSTENV"
; Data$ "FNSTSW"
; Data$ "FPATAN"
; Data$ "FPREM"
; Data$ "FPREM1"
; Data$ "FPTAN"
; Data$ "FRNDINT"
; Data$ "FRSTOR"
; Data$ "FSAVE"
; Data$ "FSCALE"
; Data$ "FSETPM"
; Data$ "FSIN"
; Data$ "FSINCOS"
; Data$ "FSQRT"
; Data$ "FST"
; Data$ "FSTCW"
; Data$ "FSTENV"
; Data$ "FSTP"
; Data$ "FSTSW"
; Data$ "FSUB"
; Data$ "FSUBP"
; Data$ "FSUBR"
; Data$ "FSUBRP"
; Data$ "FTST"
; Data$ "FUCOM"
; Data$ "FUCOMI"
; Data$ "FUCOMIP"
; Data$ "FUCOMP"
; Data$ "FUCOMPP"
; Data$ "FWAIT"
; Data$ "FXAM"
; Data$ "FXCH"
; Data$ "FXTRACT"
; Data$ "FYL2X"
; Data$ "FYL2XP1"
; Data$ "HLT"
; Data$ "IDIV"
; Data$ "IMUL"
; Data$ "IN"
; Data$ "INC"
; Data$ "INS"
; Data$ "INSB"
; Data$ "INSD"
; Data$ "INSW"
; Data$ "INT"
; Data$ "INTO"
; Data$ "INVD"
; Data$ "INVLPG"
; Data$ "IRET"
; Data$ "IRETD"
; Data$ "JA"
; Data$ "JAE"
; Data$ "JB"
; Data$ "JBE"
; Data$ "JC"
; Data$ "JCXZ"
; Data$ "JE"
; Data$ "JECXZ"
; Data$ "JG"
; Data$ "JGE"
; Data$ "JL"
; Data$ "JLE"
; Data$ "JMP"
; Data$ "JNA"
; Data$ "JNAE"
; Data$ "JNB"
; Data$ "JNBE"
; Data$ "JNC"
; Data$ "JNE"
; Data$ "JNG"
; Data$ "JNGE"
; Data$ "JNL"
; Data$ "JNLE"
; Data$ "JNO"
; Data$ "JNP"
; Data$ "JNS"
; Data$ "JNZ"
; Data$ "JO"
; Data$ "JP"
; Data$ "JPE"
; Data$ "JPO"
; Data$ "JS"
; Data$ "JZ"
; Data$ "LAHF"
; Data$ "LAR"
; Data$ "LDS"
; Data$ "LEA"
; Data$ "LEAVE"
; Data$ "LES"
; Data$ "LFS"
; Data$ "LGDT"
; Data$ "LGS"
; Data$ "LIDT"
; Data$ "LLDT"
; Data$ "LMSW"
; Data$ "LOCK"
; Data$ "LODS"
; Data$ "LODSB"
; Data$ "LODSD"
; Data$ "LODSW"
; Data$ "LOOP"
; Data$ "LOOPE"
; Data$ "LOOPNE"
; Data$ "LOOPNZ"
; Data$ "LOOPZ"
; Data$ "LSL"
; Data$ "LSS"
; Data$ "LTR"
; Data$ "MOV"
; Data$ "MOVD"
; Data$ "MOVQ"
; Data$ "MOVS"
; Data$ "MOVSB"
; Data$ "MOVSD"
; Data$ "MOVSW"
; Data$ "MOVSX"
; Data$ "MOVZX"
; Data$ "MUL"
; Data$ "NEG"
; Data$ "NOP"
; Data$ "NOT"
; Data$ "OR"
; Data$ "OUT"
; Data$ "OUTS"
; Data$ "OUTSB"
; Data$ "OUTSD"
; Data$ "OUTSW"
; Data$ "PACKSSDW"
; Data$ "PACKSSWB"
; Data$ "PACKUSWB"
; Data$ "PADDB"
; Data$ "PADDD"
; Data$ "PADDSB"
; Data$ "PADDSW"
; Data$ "PADDUSB"
; Data$ "PADDUSW"
; Data$ "PADDW"
; Data$ "PAND"
; Data$ "PANDN"
; Data$ "PCMPEQB"
; Data$ "PCMPEQD"
; Data$ "PCMPEQW"
; Data$ "PCMPGTB"
; Data$ "PCMPGTD"
; Data$ "PCMPGTW"
; Data$ "PMADDWD"
; Data$ "PMULHW"
; Data$ "POP"
; Data$ "POPA"
; Data$ "POPAD"
; Data$ "POPF"
; Data$ "POPFD"
; Data$ "POR"
; Data$ "PSLLD"
; Data$ "PSLLQ"
; Data$ "PSLLW"
; Data$ "PSRAD"
; Data$ "PSRAW"
; Data$ "PSRLD"
; Data$ "PSRLQ"
; Data$ "PSRLW"
; Data$ "PSUBB"
; Data$ "PSUBD"
; Data$ "PSUBSB"
; Data$ "PSUBSW"
; Data$ "PSUBUSB"
; Data$ "PSUBUSW"
; Data$ "PSUBW"
; Data$ "PUNPCKHBW"
; Data$ "PUNPCKHDQ"
; Data$ "PUNPCKHWD"
; Data$ "PUNPCKLBW"
; Data$ "PUNPCKLDQ"
; Data$ "PUNPCKLWD"
; Data$ "PUSH"
; Data$ "PUSHA"
; Data$ "PUSHAD"
; Data$ "PUSHF"
; Data$ "PUSHFD"
; Data$ "PXOR"
; Data$ "RCL"
; Data$ "RCR"
; Data$ "RDMSR"
; Data$ "RDPMC"
; Data$ "RDTSC"
; Data$ "REP"
; Data$ "REPE"
; Data$ "REPNE"
; Data$ "REPNZ"
; Data$ "REPZ"
; Data$ "RET"
; Data$ "RETF"
; Data$ "ROL"
; Data$ "ROR"
; Data$ "RSM"
; Data$ "SAHF"
; Data$ "SAL"
; Data$ "SAR"
; Data$ "SBB"
; Data$ "SCAS"
; Data$ "SCASB"
; Data$ "SCASD"
; Data$ "SCASW"
; Data$ "SETA"
; Data$ "SETAE"
; Data$ "SETB"
; Data$ "SETBE"
; Data$ "SETC"
; Data$ "SETE"
; Data$ "SETG"
; Data$ "SETGE"
; Data$ "SETL"
; Data$ "SETLE"
; Data$ "SETNA"
; Data$ "SETNAE"
; Data$ "SETNB"
; Data$ "SETNBE"
; Data$ "SETNC"
; Data$ "SETNE"
; Data$ "SETNG"
; Data$ "SETNGE"
; Data$ "SETNL"
; Data$ "SETNLE"
; Data$ "SETNO"
; Data$ "SETNP"
; Data$ "SETNS"
; Data$ "SETNZ"
; Data$ "SETO"
; Data$ "SETP"
; Data$ "SETPE"
; Data$ "SETPO"
; Data$ "SETS"
; Data$ "SETZ"
; Data$ "SGDT"
; Data$ "SHL"
; Data$ "SHLD"
; Data$ "SHR"
; Data$ "SHRD"
; Data$ "SIDT"
; Data$ "SLDT"
; Data$ "SMSW"
; Data$ "STC"
; Data$ "STD"
; Data$ "STI"
; Data$ "STOS"
; Data$ "STOSB"
; Data$ "STOSD"
; Data$ "STOSW"
; Data$ "STR"
; Data$ "SUB"
; Data$ "TEST"
; Data$ "UD2"
; Data$ "VERR"
; Data$ "VERW"
; Data$ "WAIT"
; Data$ "WBINVD"
; Data$ "WRMSR"
; Data$ "XADD"
; Data$ "XCHG"
; Data$ "XLAT"
; Data$ "XLATB"
; Data$ "XOR"
; 
; 
; EndDataSection
; 
; Prototype UserCallback(*Position, Length, Color)
; Global    UserCallback.UserCallback
; Global    DummySource.SourceFile
; 
; Enumeration
; #SYNTAX_Text
; #SYNTAX_Keyword  
; #SYNTAX_Comment
; #SYNTAX_Constant
; #SYNTAX_String
; #SYNTAX_Function
; #SYNTAX_Asm
; #SYNTAX_Operator
; #SYNTAX_Structure
; #SYNTAX_Number
; #SYNTAX_Pointer
; #SYNTAX_Separator
; #SYNTAX_Label  
; #SYNTAX_Module
; EndEnumeration
; 
; 
; 
; 
  ADD    rsp,40
  RET
_PB_EOP:
  SUB    rsp,40
  CALL   PB_EndFunctions
  CALL   SYS_FreeStrings
  MOV    rcx,[PB_MemoryBase]
  CALL   HeapDestroy
  ADD    rsp,40
  RET
PB_EndFunctions:
  SUB    rsp,40
  CALL   PB_FreeObjects
  CALL   PB_FreeMemorys
  ADD    rsp,40
  RET
; 
; ProcedureDLL SyntaxHighlight(*Buffer, Length, Callback.UserCallback, EnableASM)
_Procedure42:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  MOV    qword [rsp+32],r9
  PUSH   r15
  PS42=64
  XOR    rax,rax
  PUSH   rax
  SUB    rsp,40
; If *Buffer And Length > 0 And Callback
  CMP    qword [rsp+PS42+0],0
  JE     No120
  MOV    r15,qword [rsp+PS42+8]
  AND    r15,r15
  JLE    No120
  CMP    qword [rsp+PS42+16],0
  JE     No120
Ok120:
  MOV    rax,1
  JMP    End120
No120:
  XOR    rax,rax
End120:
  AND    rax,rax
  JE    _EndIf305
; UserCallback = Callback
  PUSH   qword [rsp+PS42+16]
  POP    rax
  MOV    qword [v_UserCallback],rax
; 
; 
; 
; 
; HilightningEngine(*Buffer, Length, -1, @DllCallback(), EnableASM)
  SUB    rsp,8
  PUSH   qword [rsp+PS42+32]
  LEA    rax,[_Procedure38]
  MOV    rax,rax
  PUSH   rax
  PUSH   qword -1
  PUSH   qword [rsp+PS42+40]
  PUSH   qword [rsp+PS42+40]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL  _Procedure34
  ADD    rsp,48
; 
; EndIf
_EndIf305:
; EndProcedure
_EndProcedureZero43:
  XOR    rax,rax
_EndProcedure43:
  ADD    rsp,48
  POP    r15
  RET
; Procedure IsCommandStart(*LineStart, *Cursor.BYTE)
_Procedure32:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  PUSH   rbp
  PUSH   r15
  PS32=64
  SUB    rsp,40
; *Cursor - 1 
  MOV    r15,qword [rsp+PS32+8]
  DEC    r15
  MOV    qword [rsp+PS32+8],r15
; 
; While *Cursor > *LineStart
_While121:
  MOV    r15,qword [rsp+PS32+8]
  CMP    r15,qword [rsp+PS32+0]
  JLE   _Wend121
; If *Cursor\b = ':'
  MOV    rbp,qword [rsp+PS32+8]
  MOVSX  r15,byte [rbp]
  CMP    r15,58
  JNE   _EndIf123
; ProcedureReturn 1
  MOV    rax,1
  JMP   _EndProcedure33
; ElseIf *Cursor\b <> ' ' And *Cursor\b <> 9
  JMP   _EndIf122
_EndIf123:
  MOV    rbp,qword [rsp+PS32+8]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     No23
  MOV    rbp,qword [rsp+PS32+8]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     No23
Ok23:
  MOV    rax,1
  JMP    End23
No23:
  XOR    rax,rax
End23:
  AND    rax,rax
  JE    _EndIf124
; ProcedureReturn 0
  XOR    rax,rax
  JMP   _EndProcedure33
; EndIf
_EndIf122:
_EndIf124:
; *Cursor - 1
  MOV    r15,qword [rsp+PS32+8]
  DEC    r15
  MOV    qword [rsp+PS32+8],r15
; Wend
  JMP   _While121
_Wend121:
; 
; ProcedureReturn 1  
  MOV    rax,1
  JMP   _EndProcedure33
; EndProcedure
_EndProcedureZero33:
  XOR    rax,rax
_EndProcedure33:
  ADD    rsp,40
  POP    r15
  POP    rbp
  RET
; Procedure IsBasicKeyword(Word$, *LineStart = 0, *WordStart = 0)
_Procedure26:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  PUSH   rbp
  PUSH   r15
  PS26=112
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS26+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; 
; If Right(Word$, 1) = "$"
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 1
  PUSH   qword [rsp+72]
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL   PB_Right
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  LEA    rcx,[_S5]
  POP    rdx
  MOV    qword [PB_StringBasePosition],rdx
  ADD    rdx,[PB_StringBase]
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf98
; Word$ = Left(Word$, Len(Word$)-1)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [rsp+72]
  POP    rcx
  SUB    rsp,32
  CALL   PB_Len
  ADD    rsp,40
  MOV    r15,rax
  DEC    r15
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+72]
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL   PB_Left
  ADD    rsp,40
  LEA    rcx,[rsp+48]
  POP    rdx
  CALL   SYS_AllocateString4
; AddDollar = 1
  MOV    qword [rsp+48],1
; EndIf
_EndIf98:
; 
; Word$ = LCase(Word$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+64]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_LCase
  ADD    rsp,40
  LEA    rcx,[rsp+48]
  POP    rdx
  CALL   SYS_AllocateString4
; k = BasicKeywordsHT(Asc(Word$))  
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_Asc
  MOV    r15,rax
  MOV    rbp,qword [a_BasicKeywordsHT]
  SAL    r15,2
  MOVSXD rax,dword [rbp+r15]
  PUSH   rax
  POP    rax
  MOV    qword [rsp+56],rax
; If k
  CMP    qword [rsp+56],0
  JE    _EndIf100
; While Quit = 0 And k <= #NbBasicKeywords
_While101:
  MOV    r15,qword [rsp+64]
  AND    r15,r15
  JNE    No16
  MOV    r15,qword [rsp+56]
  CMP    r15,111
  JG     No16
Ok16:
  MOV    rax,1
  JMP    End16
No16:
  XOR    rax,rax
End16:
  AND    rax,rax
  JE    _Wend101
; 
; If BasicKeywords(k) <= Word$
  MOV    r15,qword [rsp+56]
  MOV    rbp,qword [a_BasicKeywords]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  MOV    rcx,qword [rsp+48]
  POP    rdx
  CALL   SYS_StringSuperior
  OR     rax,rax
  JNE   _EndIf103
; If BasicKeywords(k) = Word$
  MOV    r15,qword [rsp+56]
  MOV    rbp,qword [a_BasicKeywords]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  MOV    rcx,qword [rsp+48]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf105
; BasicKeyword$ = BasicKeywordsReal(k)
  MOV    r15,qword [rsp+56]
  MOV    rbp,qword [a_BasicKeywordsReal]
  SAL    r15,3
  MOV    rcx,qword [rbp+r15]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[v_BasicKeyword$]
  POP    rdx
  CALL   SYS_AllocateString4
; Result = k
  PUSH   qword [rsp+56]
  POP    rax
  MOV    qword [rsp+72],rax
; Quit = 1
  MOV    qword [rsp+64],1
; EndIf
_EndIf105:
; Else
  JMP   _EndIf102
_EndIf103:
; Quit = 1
  MOV    qword [rsp+64],1
; EndIf
_EndIf102:
; 
; k+1
  MOV    r15,qword [rsp+56]
  INC    r15
  MOV    qword [rsp+56],r15
; Wend
  JMP   _While101
_Wend101:
; EndIf
_EndIf100:
; 
; If AddDollar
  CMP    qword [rsp+48],0
  JE    _EndIf108
; BasicKeyword$ + "$"
  MOV    rcx,qword [v_BasicKeyword$]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[_S5]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[v_BasicKeyword$]
  POP    rdx
  CALL   SYS_AllocateString4
; EndIf
_EndIf108:
; 
; If (Result = #KEYWORD_Align Or Result = #KEYWORD_Extends) And *LineStart And *WordStart
  MOV    r15,qword [rsp+72]
  CMP    r15,1
  JE     Ok17
  MOV    r15,qword [rsp+72]
  CMP    r15,55
  JE     Ok17
  JMP    No17
Ok17:
  MOV    rax,1
  JMP    End17
No17:
  XOR    rax,rax
End17:
  AND    rax,rax
  JE     No18
  CMP    qword [rsp+PS26+8],0
  JE     No18
  CMP    qword [rsp+PS26+16],0
  JE     No18
Ok18:
  MOV    rax,1
  JMP    End18
No18:
  XOR    rax,rax
End18:
  AND    rax,rax
  JE    _EndIf110
; 
; If IsAfterStructure(Result, *LineStart, *WordStart) = #False
  PUSH   qword [rsp+PS26+16]
  PUSH   qword [rsp+PS26+16]
  PUSH   qword [rsp+88]
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure24
  MOV    r15,rax
  AND    r15,r15
  JNE   _EndIf112
; ProcedureReturn 0
  XOR    rax,rax
  JMP   _EndProcedure27
; EndIf
_EndIf112:
; EndIf
_EndIf110:
; 
; ProcedureReturn Result
  MOV    rax,qword [rsp+72]
  JMP   _EndProcedure27
; EndProcedure
_EndProcedureZero27:
  XOR    rax,rax
_EndProcedure27:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,88
  POP    r15
  POP    rbp
  RET
; Procedure HilightningEngine(*InBuffer, InBufferLength, CursorPosition, Callback.HilightCallback, IsSourceCode)
_Procedure34:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  MOV    qword [rsp+32],r9
  PUSH   rbp
  PUSH   r15
  PUSH   r14
  PS34=304
  MOV    rax,29
.ClearLoop:
  SUB    rsp,8
  MOV    qword [rsp],0
  DEC    rax
  JNZ   .ClearLoop
  SUB    rsp,40
; 
; *Cursor.HilightPTR = *InBuffer
  PUSH   qword [rsp+PS34+0]
  POP    rax
  MOV    qword [rsp+40],rax
; *InBufferEnd = *InBuffer + InBufferLength
  MOV    r15,qword [rsp+PS34+0]
  ADD    r15,qword [rsp+PS34+8]
  MOV    qword [rsp+48],r15
; *LineStart   = *InBuffer 
  PUSH   qword [rsp+PS34+0]
  POP    rax
  MOV    qword [rsp+56],rax
; 
; If IsSourceCode And *ActiveSource And *ActiveSource\EnableASM
  CMP    qword [rsp+PS34+32],0
  JE     No24
  CMP    qword [p_ActiveSource],0
  JE     No24
  MOV    rbp,qword [p_ActiveSource]
  CMP    dword [rbp],0
  JE     No24
Ok24:
  MOV    rax,1
  JMP    End24
No24:
  XOR    rax,rax
End24:
  AND    rax,rax
  JE    _EndIf126
; ASMEnabled = 1
  MOV    qword [rsp+64],1
; Else
  JMP   _EndIf125
_EndIf126:
; ASMEnabled = 0
  MOV    qword [rsp+64],0
; EndIf
_EndIf125:
; 
; If IsSourceCode And *ActiveSource And *ActiveSource\Parser\Encoding = 1
  CMP    qword [rsp+PS34+32],0
  JE     No25
  CMP    qword [p_ActiveSource],0
  JE     No25
  MOV    rbp,qword [p_ActiveSource]
  MOVSXD r15,dword [rbp+12]
  CMP    r15,1
  JNE    No25
Ok25:
  MOV    rax,1
  JMP    End25
No25:
  XOR    rax,rax
End25:
  AND    rax,rax
  JE    _EndIf129
; SourceStringFormat = #PB_UTF8
  MOV    qword [v_SourceStringFormat],2
; Else
  JMP   _EndIf128
_EndIf129:
; SourceStringFormat = #PB_Ascii
  MOV    qword [v_SourceStringFormat],24
; EndIf    
_EndIf128:
; 
; SeperatorChar = 0
  MOV    qword [rsp+72],0
; OldSeparatorChar = 0   
  MOV    qword [rsp+80],0
; OlderSeparatorChar = 0 
  MOV    qword [rsp+88],0
; 
; While *Cursor < *InBufferEnd
_While131:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE   _Wend131
; 
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; 
; 
; While *Cursor < *InBufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
_While132:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No26
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     Ok27
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok27
  JMP    No27
Ok27:
  MOV    rax,1
  JMP    End27
No27:
  XOR    rax,rax
End27:
  AND    rax,rax
  JE     No26
Ok26:
  MOV    rax,1
  JMP    End26
No26:
  XOR    rax,rax
End26:
  AND    rax,rax
  JE    _Wend132
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While132
_Wend132:
; 
; 
; 
; *WordStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+104],rax
; 
; While *Cursor < *InBufferEnd And ValidCharacters(*Cursor\a)
_While133:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No28
  MOV    rbp,qword [rsp+40]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No28
Ok28:
  MOV    rax,1
  JMP    End28
No28:
  XOR    rax,rax
End28:
  AND    rax,rax
  JE    _Wend133
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While133
_Wend133:
; 
; *WordEnd.BYTE = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+112],rax
; 
; 
; 
; AfterSpaces = 0
  MOV    qword [rsp+120],0
; While *Cursor < *InBufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
_While134:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No29
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     Ok30
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok30
  JMP    No30
Ok30:
  MOV    rax,1
  JMP    End30
No30:
  XOR    rax,rax
End30:
  AND    rax,rax
  JE     No29
Ok29:
  MOV    rax,1
  JMP    End29
No29:
  XOR    rax,rax
End29:
  AND    rax,rax
  JE    _Wend134
; AfterSpaces+1
  MOV    r15,qword [rsp+120]
  INC    r15
  MOV    qword [rsp+120],r15
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend   
  JMP   _While134
_Wend134:
; 
; 
; 
; 
; If AfterSpaces = 0 And *Cursor < *InBufferEnd And *Cursor\b = '$' And *WordStart < *WordEnd 
  MOV    r15,qword [rsp+120]
  AND    r15,r15
  JNE    No31
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No31
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,36
  JNE    No31
  MOV    r15,qword [rsp+104]
  CMP    r15,qword [rsp+112]
  JGE    No31
Ok31:
  MOV    rax,1
  JMP    End31
No31:
  XOR    rax,rax
End31:
  AND    rax,rax
  JE    _EndIf136
; *WordEnd + 1
  MOV    r15,qword [rsp+112]
  INC    r15
  MOV    qword [rsp+112],r15
; *Cursor  + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; 
; While *Cursor < *InBufferEnd And (*Cursor\b = ' ' Or *Cursor\b = 9)
_While137:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No32
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     Ok33
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok33
  JMP    No33
Ok33:
  MOV    rax,1
  JMP    End33
No33:
  XOR    rax,rax
End33:
  AND    rax,rax
  JE     No32
Ok32:
  MOV    rax,1
  JMP    End32
No32:
  XOR    rax,rax
End32:
  AND    rax,rax
  JE    _Wend137
; AfterSpaces+1
  MOV    r15,qword [rsp+120]
  INC    r15
  MOV    qword [rsp+120],r15
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend   
  JMP   _While137
_Wend137:
; EndIf
_EndIf136:
; 
; WordLength = *WordEnd - *WordStart 
  MOV    r15,qword [rsp+112]
  SUB    r15,qword [rsp+104]
  MOV    qword [rsp+128],r15
; WordStart$ = PeekAsciiLength(*WordStart, WordLength)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 24
  PUSH   qword [rsp+160]
  PUSH   qword [rsp+144]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_PeekS3
  ADD    rsp,40
  LEA    rcx,[rsp+144]
  POP    rdx
  CALL   SYS_AllocateString4
; 
; SeparatorUsed = 0
  MOV    qword [rsp+144],0
; IgnoreSeparator = 0
  MOV    qword [rsp+152],0
; 
; 
; 
; If *Cursor > *InBufferEnd 
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JLE   _EndIf139
; SeparatorChar = #EndSeparator 
  MOV    qword [rsp+160],-1
; 
; Else
  JMP   _EndIf138
_EndIf139:
; 
; NewLine = 0
  MOV    qword [rsp+168],0
; If ValidCharacters(*Cursor\a)
  MOV    rbp,qword [rsp+40]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE    _EndIf142
; SeparatorChar = 0
  MOV    qword [rsp+160],0
; 
; ElseIf *Cursor\b = 13 Or *Cursor\b = 10         
  JMP   _EndIf141
_EndIf142:
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     Ok34
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     Ok34
  JMP    No34
Ok34:
  MOV    rax,1
  JMP    End34
No34:
  XOR    rax,rax
End34:
  AND    rax,rax
  JE    _EndIf143
; NewLine = 1
  MOV    qword [rsp+168],1
; 
; If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 13 Or *Cursor\a[1] = 10)  
  MOV    r15,qword [rsp+40]
  INC    r15
  CMP    r15,qword [rsp+48]
  JGE    No35
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,13
  CMP    r15,rax
  JE     Ok36
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,10
  CMP    r15,rax
  JE     Ok36
  JMP    No36
Ok36:
  MOV    rax,1
  JMP    End36
No36:
  XOR    rax,rax
End36:
  AND    rax,rax
  JE     No35
Ok35:
  MOV    rax,1
  JMP    End35
No35:
  XOR    rax,rax
End35:
  AND    rax,rax
  JE    _EndIf145
; *Cursor + 2
  MOV    r15,qword [rsp+40]
  ADD    r15,2
  MOV    qword [rsp+40],r15
; Else
  JMP   _EndIf144
_EndIf145:
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf144:
; 
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; ElseIf *Cursor\b = 0
  JMP   _EndIf141
_EndIf143:
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  AND    r15,r15
  JNE   _EndIf147
; SeparatorChar = #EndSeparator 
  MOV    qword [rsp+160],-1
; 
; Else
  JMP   _EndIf141
_EndIf147:
; SeparatorChar = *Cursor\a
  MOV    rbp,qword [rsp+40]
  MOVZX  rax,byte [rbp]
  PUSH   rax
  POP    rax
  MOV    qword [rsp+160],rax
; EndIf
_EndIf141:
; EndIf
_EndIf138:
; 
; 
; If IsCustomKeyword(WordStart$) And OldSeparatorChar <> '\'
  PUSH   qword [rsp+136]
  POP    rcx
  CALL  _Procedure20
  AND    rax,rax
  JE     No37
  MOV    r15,qword [rsp+80]
  CMP    r15,92
  JE     No37
Ok37:
  MOV    rax,1
  JMP    End37
No37:
  XOR    rax,rax
End37:
  AND    rax,rax
  JE    _EndIf150
; 
; 
; If EnableCaseCorrection And (CursorPosition = 0 Or CursorPosition < *WordStart-*InBuffer Or CursorPosition > *WordEnd-*InBuffer)
  CMP    qword [v_EnableCaseCorrection],0
  JE     No38
  MOV    r15,qword [rsp+PS34+16]
  AND    r15,r15
  JE     Ok39
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+104]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JL     Ok39
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+112]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JG     Ok39
  JMP    No39
Ok39:
  MOV    rax,1
  JMP    End39
No39:
  XOR    rax,rax
End39:
  AND    rax,rax
  JE     No38
Ok38:
  MOV    rax,1
  JMP    End38
No38:
  XOR    rax,rax
End38:
  AND    rax,rax
  JE    _EndIf152
; TextChanged = CopyMemoryCheck(ToAscii(CustomKeyword$), *WordStart, Len(CustomKeyword$)) 
  PUSH   qword [v_CustomKeyword$]
  POP    rcx
  CALL   PB_Len
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+112]
  PUSH   qword [v_CustomKeyword$]
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure6
  MOV    qword [rsp+176],rax
; Else
  JMP   _EndIf151
_EndIf152:
; TextChanged = 0
  MOV    qword [rsp+176],0
; EndIf
_EndIf151:
; 
; If EnableKeywordBolding 
  CMP    qword [v_EnableKeywordBolding],0
  JE    _EndIf155
; Callback(*StringStart, *WordStart- *StringStart, *NormalTextColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+136]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*WordStart  , *WordEnd  - *WordStart  , *CustomKeywordColor, 1, TextChanged)        
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 1
  PUSH   qword [p_CustomKeywordColor]
  MOV    r15,qword [rsp+144]
  SUB    r15,qword [rsp+136]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+144]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*WordEnd    , *Cursor   - *WordEnd    , *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+144]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+152]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else
  JMP   _EndIf154
_EndIf155:
; Callback(*StringStart, *Cursor - *StringStart, *CustomKeywordColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_CustomKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf      
_EndIf154:
; 
; CompilerIf Defined(IDE_SYNTAXCHECK, #PB_Constant)
; 
; 
; 
; 
; 
; 
; ElseIf IsBasicKeyword(WordStart$, *LineStart, *WordStart) And OldSeparatorChar <> '\' And (ASMEnabled = 0 Or IsASMKeyword(WordStart$) = 0 Or IsCommandStart(*LineStart, *WordStart) = 0)
  JMP   _EndIf149
_EndIf150:
  PUSH   qword [rsp+104]
  PUSH   qword [rsp+64]
  PUSH   qword [rsp+152]
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure26
  AND    rax,rax
  JE     No40
  MOV    r15,qword [rsp+80]
  CMP    r15,92
  JE     No40
  MOV    r15,qword [rsp+64]
  AND    r15,r15
  JE     Ok41
  PUSH   qword [rsp+136]
  POP    rcx
  CALL  _Procedure18
  MOV    r15,rax
  AND    r15,r15
  JE     Ok41
  PUSH   qword [rsp+104]
  PUSH   qword [rsp+64]
  POP    rcx
  POP    rdx
  CALL  _Procedure32
  MOV    r15,rax
  AND    r15,r15
  JE     Ok41
  JMP    No41
Ok41:
  MOV    rax,1
  JMP    End41
No41:
  XOR    rax,rax
End41:
  AND    rax,rax
  JE     No40
Ok40:
  MOV    rax,1
  JMP    End40
No40:
  XOR    rax,rax
End40:
  AND    rax,rax
  JE    _EndIf157
; 
; 
; 
; 
; If EnableCaseCorrection And (CursorPosition = 0 Or CursorPosition < *WordStart-*InBuffer Or CursorPosition > *WordEnd-*InBuffer)
  CMP    qword [v_EnableCaseCorrection],0
  JE     No42
  MOV    r15,qword [rsp+PS34+16]
  AND    r15,r15
  JE     Ok43
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+104]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JL     Ok43
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+112]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JG     Ok43
  JMP    No43
Ok43:
  MOV    rax,1
  JMP    End43
No43:
  XOR    rax,rax
End43:
  AND    rax,rax
  JE     No42
Ok42:
  MOV    rax,1
  JMP    End42
No42:
  XOR    rax,rax
End42:
  AND    rax,rax
  JE    _EndIf159
; TextChanged = CopyMemoryCheck(ToAscii(BasicKeyword$), *WordStart, Len(BasicKeyword$)) 
  PUSH   qword [v_BasicKeyword$]
  POP    rcx
  CALL   PB_Len
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+112]
  PUSH   qword [v_BasicKeyword$]
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure6
  MOV    qword [rsp+176],rax
; Else
  JMP   _EndIf158
_EndIf159:
; TextChanged = 0
  MOV    qword [rsp+176],0
; EndIf
_EndIf158:
; 
; If EnableKeywordBolding 
  CMP    qword [v_EnableKeywordBolding],0
  JE    _EndIf162
; Callback(*StringStart, *WordStart- *StringStart, *NormalTextColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+136]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*WordStart  , *WordEnd  - *WordStart  , *BasicKeywordColor, 1, TextChanged)         
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 1
  PUSH   qword [p_BasicKeywordColor]
  MOV    r15,qword [rsp+144]
  SUB    r15,qword [rsp+136]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+144]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*WordEnd    , *Cursor   - *WordEnd    , *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+144]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+152]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else
  JMP   _EndIf161
_EndIf162:
; Callback(*StringStart, *Cursor - *StringStart, *BasicKeywordColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_BasicKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf
_EndIf161:
; 
; ElseIf SeparatorChar = ':' And *Cursor\a[1] = ':'
  JMP   _EndIf149
_EndIf157:
  MOV    r15,qword [rsp+160]
  CMP    r15,58
  JNE    No44
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,58
  CMP    r15,rax
  JNE    No44
Ok44:
  MOV    rax,1
  JMP    End44
No44:
  XOR    rax,rax
End44:
  AND    rax,rax
  JE    _EndIf164
; 
; 
; 
; Callback(*StringStart, *Cursor-*StringStart, *ModuleColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_ModuleColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor, 2, *OperatorColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_OperatorColor]
  PUSH   qword 2
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; 
; SeparatorChar = #ModuleSeparator
  MOV    qword [rsp+160],-2
; SeparatorUsed = 1
  MOV    qword [rsp+144],1
; *Cursor + 2 
  MOV    r15,qword [rsp+40]
  ADD    r15,2
  MOV    qword [rsp+40],r15
; 
; 
; ElseIf SeparatorChar = ':' And IsLineStart(*LineStart, *WordStart) And WordLength > 0
  JMP   _EndIf149
_EndIf164:
  MOV    r15,qword [rsp+160]
  CMP    r15,58
  JNE    No45
  PUSH   qword [rsp+104]
  PUSH   qword [rsp+64]
  POP    rcx
  POP    rdx
  CALL  _Procedure30
  AND    rax,rax
  JE     No45
  MOV    r15,qword [rsp+128]
  AND    r15,r15
  JLE    No45
Ok45:
  MOV    rax,1
  JMP    End45
No45:
  XOR    rax,rax
End45:
  AND    rax,rax
  JE    _EndIf165
; 
; 
; 
; Callback(*StringStart, *Cursor-*StringStart+1, *LabelColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_LabelColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorUsed = 1
  MOV    qword [rsp+144],1
; 
; 
; 
; ElseIf SeparatorChar = '(' And WordLength > 0
  JMP   _EndIf149
_EndIf165:
  MOV    r15,qword [rsp+160]
  CMP    r15,40
  JNE    No46
  MOV    r15,qword [rsp+128]
  AND    r15,r15
  JLE    No46
Ok46:
  MOV    rax,1
  JMP    End46
No46:
  XOR    rax,rax
End46:
  AND    rax,rax
  JE    _EndIf166
; 
; 
; TextChanged = 0
  MOV    qword [rsp+176],0
; 
; FunctionPosition = IsAPIFunction(*WordStart, WordLength)
  PUSH   qword [rsp+128]
  PUSH   qword [rsp+112]
  POP    rcx
  POP    rdx
  CALL  _Procedure14
  MOV    qword [rsp+184],rax
; If FunctionPosition > -1
  MOV    r15,qword [rsp+184]
  CMP    r15,-1
  JLE   _EndIf168
; 
; If EnableCaseCorrection 
  CMP    qword [v_EnableCaseCorrection],0
  JE    _EndIf170
; TextChanged = CopyMemoryCheck(APIFunctions(FunctionPosition)\Ascii, *WordStart, WordLength-1)
  MOV    r15,qword [rsp+128]
  DEC    r15
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+112]
  MOV    r15,qword [rsp+200]
  MOV    rbp,qword [a_APIFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  PUSH   qword [rbp+16]
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure6
  MOV    qword [rsp+176],rax
; EndIf
_EndIf170:
; 
; Else
  JMP   _EndIf167
_EndIf168:
; FunctionPosition = IsBasicFunction(UCase(WordStart$))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+176]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure16
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
  MOV    qword [rsp+184],rax
; If FunctionPosition > -1
  MOV    r15,qword [rsp+184]
  CMP    r15,-1
  JLE   _EndIf173
; 
; If EnableCaseCorrection And OldSeparatorChar <> '.' 
  CMP    qword [v_EnableCaseCorrection],0
  JE     No47
  MOV    r15,qword [rsp+80]
  CMP    r15,46
  JE     No47
Ok47:
  MOV    rax,1
  JMP    End47
No47:
  XOR    rax,rax
End47:
  AND    rax,rax
  JE    _EndIf175
; TextChanged = CopyMemoryCheck(BasicFunctions(FunctionPosition)\Ascii, *WordStart, WordLength)
  PUSH   qword [rsp+128]
  PUSH   qword [rsp+112]
  MOV    r15,qword [rsp+200]
  MOV    rbp,qword [a_BasicFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  PUSH   qword [rbp+16]
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure6
  MOV    qword [rsp+176],rax
; EndIf
_EndIf175:
; 
; EndIf         
_EndIf173:
; 
; EndIf
_EndIf167:
; 
; If OldSeparatorChar = '.'
  MOV    r15,qword [rsp+80]
  CMP    r15,46
  JNE   _EndIf177
; WordStart$ = UCase(WordStart$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+160]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+144]
  POP    rdx
  CALL   SYS_AllocateString4
; If Len(WordStart$) = 1 And FindString(#BasicTypeChars, WordStart$, 1) 
  PUSH   qword [rsp+136]
  POP    rcx
  CALL   PB_Len
  MOV    r15,rax
  CMP    r15,1
  JNE    No48
  PUSH   qword 1
  PUSH   qword [rsp+144]
  LEA    rax,[_S6]
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_FindString2
  AND    rax,rax
  JE     No48
Ok48:
  MOV    rax,1
  JMP    End48
No48:
  XOR    rax,rax
End48:
  AND    rax,rax
  JE    _EndIf179
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else
  JMP   _EndIf178
_EndIf179:
; Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_StructureColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf     
_EndIf178:
; ElseIf OldSeparatorChar = #ModuleSeparator And OlderSeparatorChar = '.'
  JMP   _EndIf176
_EndIf177:
  MOV    r15,qword [rsp+80]
  CMP    r15,-2
  JNE    No49
  MOV    r15,qword [rsp+88]
  CMP    r15,46
  JNE    No49
Ok49:
  MOV    rax,1
  JMP    End49
No49:
  XOR    rax,rax
End49:
  AND    rax,rax
  JE    _EndIf181
; 
; Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_StructureColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else               
  JMP   _EndIf176
_EndIf181:
; Callback(*StringStart, *Cursor-*StringStart, *PureKeywordColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_PureKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf     
_EndIf176:
; 
; ElseIf IsDecNumber(*WordStart, WordLength) Or (OldSeparatorChar = '.' And ByteUcase(PeekB(*WordStart)) = 'E' And IsDecNumber(*WordStart+1, WordLength-1)) 
  JMP   _EndIf149
_EndIf166:
  PUSH   qword [rsp+128]
  PUSH   qword [rsp+112]
  POP    rcx
  POP    rdx
  CALL  _Procedure28
  AND    rax,rax
  JNE    Ok50
  MOV    r15,qword [rsp+80]
  CMP    r15,46
  JNE    No51
  PUSH   qword [rsp+104]
  POP    rcx
  CALL   PB_PeekB
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  CALL  _Procedure8
  MOV    r15,rax
  CMP    r15,69
  JNE    No51
  MOV    r15,qword [rsp+128]
  DEC    r15
  MOV    rax,r15
  PUSH   rax
  MOV    r15,qword [rsp+112]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  CALL  _Procedure28
  AND    rax,rax
  JE     No51
Ok51:
  MOV    rax,1
  JMP    End51
No51:
  XOR    rax,rax
End51:
  AND    rax,rax
  JNE    Ok50
  JMP    No50
Ok50:
  MOV    rax,1
  JMP    End50
No50:
  XOR    rax,rax
End50:
  AND    rax,rax
  JE    _EndIf183
; 
; 
; 
; If SeparatorChar = '.'
  MOV    r15,qword [rsp+160]
  CMP    r15,46
  JNE   _EndIf185
; Callback(*StringStart, *Cursor-*StringStart+1, *NumberColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NumberColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorUsed = 1
  MOV    qword [rsp+144],1
; Else
  JMP   _EndIf184
_EndIf185:
; Callback(*StringStart, *Cursor-*StringStart, *NumberColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NumberColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf
_EndIf184:
; 
; ElseIf ASMEnabled And IsASMKeyword(WordStart$)
  JMP   _EndIf149
_EndIf183:
  CMP    qword [rsp+64],0
  JE     No52
  PUSH   qword [rsp+136]
  POP    rcx
  CALL  _Procedure18
  AND    rax,rax
  JE     No52
Ok52:
  MOV    rax,1
  JMP    End52
No52:
  XOR    rax,rax
End52:
  AND    rax,rax
  JE    _EndIf187
; 
; 
; 
; 
; If EnableCaseCorrection And (CursorPosition = 0 Or CursorPosition < *WordStart-*InBuffer Or CursorPosition > *WordEnd-*InBuffer)
  CMP    qword [v_EnableCaseCorrection],0
  JE     No53
  MOV    r15,qword [rsp+PS34+16]
  AND    r15,r15
  JE     Ok54
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+104]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JL     Ok54
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+112]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JG     Ok54
  JMP    No54
Ok54:
  MOV    rax,1
  JMP    End54
No54:
  XOR    rax,rax
End54:
  AND    rax,rax
  JE     No53
Ok53:
  MOV    rax,1
  JMP    End53
No53:
  XOR    rax,rax
End53:
  AND    rax,rax
  JE    _EndIf189
; TextChanged = CopyMemoryCheck(ToAscii(ASMKeyword$), *WordStart, WordLength) 
  PUSH   qword [rsp+128]
  PUSH   qword [rsp+112]
  PUSH   qword [v_ASMKeyword$]
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure6
  MOV    qword [rsp+176],rax
; Callback(*StringStart, *Cursor-*StringStart, *ASMKeywordColor, 0, TextChanged)
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_ASMKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else
  JMP   _EndIf188
_EndIf189:
; Callback(*StringStart, *Cursor-*StringStart, *ASMKeywordColor, 0, 0)       
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_ASMKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf   
_EndIf188:
; 
; ElseIf OldSeparatorChar = '\' Or SeparatorChar = '\' 
  JMP   _EndIf149
_EndIf187:
  MOV    r15,qword [rsp+80]
  CMP    r15,92
  JE     Ok55
  MOV    r15,qword [rsp+160]
  CMP    r15,92
  JE     Ok55
  JMP    No55
Ok55:
  MOV    rax,1
  JMP    End55
No55:
  XOR    rax,rax
End55:
  AND    rax,rax
  JE    _EndIf191
; 
; 
; Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_StructureColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; 
; ElseIf SeparatorChar = '.' Or OldSeparatorChar = '.' Or (OldSeparatorChar = #ModuleSeparator And OlderSeparatorChar = '.')
  JMP   _EndIf149
_EndIf191:
  MOV    r15,qword [rsp+160]
  CMP    r15,46
  JE     Ok56
  MOV    r15,qword [rsp+80]
  CMP    r15,46
  JE     Ok56
  MOV    r15,qword [rsp+80]
  CMP    r15,-2
  JNE    No57
  MOV    r15,qword [rsp+88]
  CMP    r15,46
  JNE    No57
Ok57:
  MOV    rax,1
  JMP    End57
No57:
  XOR    rax,rax
End57:
  AND    rax,rax
  JNE    Ok56
  JMP    No56
Ok56:
  MOV    rax,1
  JMP    End56
No56:
  XOR    rax,rax
End56:
  AND    rax,rax
  JE    _EndIf192
; 
; 
; 
; If OldSeparatorChar = '.'
  MOV    r15,qword [rsp+80]
  CMP    r15,46
  JNE   _EndIf194
; WordStart$ = UCase(WordStart$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+160]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+144]
  POP    rdx
  CALL   SYS_AllocateString4
; If Len(WordStart$) = 1 And FindString(#BasicTypeChars, WordStart$, 1) 
  PUSH   qword [rsp+136]
  POP    rcx
  CALL   PB_Len
  MOV    r15,rax
  CMP    r15,1
  JNE    No58
  PUSH   qword 1
  PUSH   qword [rsp+144]
  LEA    rax,[_S6]
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_FindString2
  AND    rax,rax
  JE     No58
Ok58:
  MOV    rax,1
  JMP    End58
No58:
  XOR    rax,rax
End58:
  AND    rax,rax
  JE    _EndIf196
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else        
  JMP   _EndIf195
_EndIf196:
; Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_StructureColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf
_EndIf195:
; 
; Else
  JMP   _EndIf193
_EndIf194:
; *ForwardCursor.HilightPTR = *Cursor+1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+192],r15
; While *ForwardCursor.HilightPTR < *InBufferEnd And ValidCharacters(*ForwardCursor\a)
_While199:
  MOV    r15,qword [rsp+192]
  CMP    r15,qword [rsp+48]
  JGE    No59
  MOV    rbp,qword [rsp+192]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No59
Ok59:
  MOV    rax,1
  JMP    End59
No59:
  XOR    rax,rax
End59:
  AND    rax,rax
  JE    _Wend199
; *ForwardCursor + 1
  MOV    r15,qword [rsp+192]
  INC    r15
  MOV    qword [rsp+192],r15
; Wend
  JMP   _While199
_Wend199:
; NextWord$ = UCase(PeekAsciiLength(*Cursor+1, *ForwardCursor-*Cursor-1))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 24
  MOV    r15,qword [rsp+240]
  SUB    r15,qword [rsp+88]
  DEC    r15
  MOV    rax,r15
  PUSH   rax
  MOV    r15,qword [rsp+96]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_PeekS3
  ADD    rsp,32
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+208]
  POP    rdx
  CALL   SYS_AllocateString4
; 
; 
; While *ForwardCursor < *InBufferEnd And *ForwardCursor\b = ' ' Or *ForwardCursor\b = 9: *ForwardCursor + 1: Wend
_While200:
  MOV    r15,qword [rsp+192]
  CMP    r15,qword [rsp+48]
  JGE    No60
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JNE    No60
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok60
  JMP    No60
Ok60:
  MOV    rax,1
  JMP    End60
No60:
  XOR    rax,rax
End60:
  AND    rax,rax
  JE    _Wend200
  MOV    r15,qword [rsp+192]
  INC    r15
  MOV    qword [rsp+192],r15
  JMP   _While200
_Wend200:
; If *ForwardCursor < *InBufferEnd-2 And *ForwardCursor\b = ':' And PeekB(*ForwardCursor + 1) = ':'
  MOV    r15,qword [rsp+192]
  MOV    r14,qword [rsp+48]
  ADD    r14,-2
  CMP    r15,r14
  JGE    No61
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,58
  JNE    No61
  MOV    r15,qword [rsp+192]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  CALL   PB_PeekB
  MOV    r15,rax
  CMP    r15,58
  JNE    No61
Ok61:
  MOV    rax,1
  JMP    End61
No61:
  XOR    rax,rax
End61:
  AND    rax,rax
  JE    _EndIf202
; IsModulePrefix = 1
  MOV    qword [rsp+208],1
; *ForwardCursor + 2
  MOV    r15,qword [rsp+192]
  ADD    r15,2
  MOV    qword [rsp+192],r15
; While *ForwardCursor < *InBufferEnd And *ForwardCursor\b = ' ' Or *ForwardCursor\b = 9: *ForwardCursor + 1: Wend
_While203:
  MOV    r15,qword [rsp+192]
  CMP    r15,qword [rsp+48]
  JGE    No62
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JNE    No62
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok62
  JMP    No62
Ok62:
  MOV    rax,1
  JMP    End62
No62:
  XOR    rax,rax
End62:
  AND    rax,rax
  JE    _Wend203
  MOV    r15,qword [rsp+192]
  INC    r15
  MOV    qword [rsp+192],r15
  JMP   _While203
_Wend203:
; While *ForwardCursor.HilightPTR < *InBufferEnd And ValidCharacters(*ForwardCursor\a)
_While204:
  MOV    r15,qword [rsp+192]
  CMP    r15,qword [rsp+48]
  JGE    No63
  MOV    rbp,qword [rsp+192]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No63
Ok63:
  MOV    rax,1
  JMP    End63
No63:
  XOR    rax,rax
End63:
  AND    rax,rax
  JE    _Wend204
; *ForwardCursor + 1
  MOV    r15,qword [rsp+192]
  INC    r15
  MOV    qword [rsp+192],r15
; Wend
  JMP   _While204
_Wend204:
; While *ForwardCursor < *InBufferEnd And *ForwardCursor\b = ' ' Or *ForwardCursor\b = 9: *ForwardCursor + 1: Wend
_While205:
  MOV    r15,qword [rsp+192]
  CMP    r15,qword [rsp+48]
  JGE    No64
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JNE    No64
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok64
  JMP    No64
Ok64:
  MOV    rax,1
  JMP    End64
No64:
  XOR    rax,rax
End64:
  AND    rax,rax
  JE    _Wend205
  MOV    r15,qword [rsp+192]
  INC    r15
  MOV    qword [rsp+192],r15
  JMP   _While205
_Wend205:
; Else
  JMP   _EndIf201
_EndIf202:
; IsModulePrefix = 0
  MOV    qword [rsp+208],0
; EndIf
_EndIf201:
; 
; If *ForwardCursor\b = '('  
  MOV    rbp,qword [rsp+192]
  MOVSX  r15,byte [rbp]
  CMP    r15,40
  JNE   _EndIf208
; Callback(*StringStart, *Cursor-*StringStart, *PureKeywordColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_PureKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; ElseIf IsModulePrefix = 0 And Len(NextWord$) = 1 And FindString(#BasicTypeChars, NextWord$, 1) 
  JMP   _EndIf207
_EndIf208:
  MOV    r15,qword [rsp+208]
  AND    r15,r15
  JNE    No65
  PUSH   qword [rsp+200]
  POP    rcx
  CALL   PB_Len
  MOV    r15,rax
  CMP    r15,1
  JNE    No65
  PUSH   qword 1
  PUSH   qword [rsp+208]
  LEA    rax,[_S6]
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_FindString2
  AND    rax,rax
  JE     No65
Ok65:
  MOV    rax,1
  JMP    End65
No65:
  XOR    rax,rax
End65:
  AND    rax,rax
  JE    _EndIf209
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; 
; 
; ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-8 And CompareMemoryString(*Cursor, ToAscii(".p-ascii"), #PB_String_NoCase, 8, #PB_Ascii) = 0
  JMP   _EndIf207
_EndIf209:
  PUSH   qword [rsp+200]
  LEA    rcx,[_S7]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE     No66
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+48]
  ADD    r14,-8
  CMP    r15,r14
  JGE    No66
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 8
  PUSH   qword 1
  LEA    rax,[_S8]
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No66
Ok66:
  MOV    rax,1
  JMP    End66
No66:
  XOR    rax,rax
End66:
  AND    rax,rax
  JE    _EndIf210
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)                   
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor, 1, *SeparatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_SeparatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor+1, 7, *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  PUSH   qword 7
  MOV    r15,qword [rsp+80]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; *Cursor + 8
  MOV    r15,qword [rsp+40]
  ADD    r15,8
  MOV    qword [rsp+40],r15
; SeparatorChar = #SkipSeparator          
  MOV    qword [rsp+160],-2
; 
; ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-10 And CompareMemoryString(*Cursor, ToAscii(".p-unicode"), #PB_String_NoCase, 10, #PB_Ascii) = 0
  JMP   _EndIf207
_EndIf210:
  PUSH   qword [rsp+200]
  LEA    rcx,[_S7]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE     No67
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+48]
  ADD    r14,-10
  CMP    r15,r14
  JGE    No67
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 10
  PUSH   qword 1
  LEA    rax,[_S9]
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No67
Ok67:
  MOV    rax,1
  JMP    End67
No67:
  XOR    rax,rax
End67:
  AND    rax,rax
  JE    _EndIf211
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)                   
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor, 1, *SeparatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_SeparatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor+1, 9, *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  PUSH   qword 9
  MOV    r15,qword [rsp+80]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; *Cursor + 10
  MOV    r15,qword [rsp+40]
  ADD    r15,10
  MOV    qword [rsp+40],r15
; SeparatorChar = #SkipSeparator        
  MOV    qword [rsp+160],-2
; 
; ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-7 And CompareMemoryString(*Cursor, ToAscii(".p-bstr"), #PB_String_NoCase, 7, #PB_Ascii) = 0
  JMP   _EndIf207
_EndIf211:
  PUSH   qword [rsp+200]
  LEA    rcx,[_S7]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE     No68
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+48]
  ADD    r14,-7
  CMP    r15,r14
  JGE    No68
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 7
  PUSH   qword 1
  LEA    rax,[_S10]
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No68
Ok68:
  MOV    rax,1
  JMP    End68
No68:
  XOR    rax,rax
End68:
  AND    rax,rax
  JE    _EndIf212
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)                   
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor, 1, *SeparatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_SeparatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor+1, 6, *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  PUSH   qword 6
  MOV    r15,qword [rsp+80]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; *Cursor + 7
  MOV    r15,qword [rsp+40]
  ADD    r15,7
  MOV    qword [rsp+40],r15
; SeparatorChar = #SkipSeparator        
  MOV    qword [rsp+160],-2
; 
; ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-10 And CompareMemoryString(*Cursor, ToAscii(".p-variant"), #PB_String_NoCase, 10, #PB_Ascii) = 0
  JMP   _EndIf207
_EndIf212:
  PUSH   qword [rsp+200]
  LEA    rcx,[_S7]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE     No69
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+48]
  ADD    r14,-10
  CMP    r15,r14
  JGE    No69
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 10
  PUSH   qword 1
  LEA    rax,[_S11]
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No69
Ok69:
  MOV    rax,1
  JMP    End69
No69:
  XOR    rax,rax
End69:
  AND    rax,rax
  JE    _EndIf213
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)                   
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor, 1, *SeparatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_SeparatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor+1, 9, *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  PUSH   qword 9
  MOV    r15,qword [rsp+80]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; *Cursor + 10
  MOV    r15,qword [rsp+40]
  ADD    r15,10
  MOV    qword [rsp+40],r15
; SeparatorChar = #SkipSeparator      
  MOV    qword [rsp+160],-2
; 
; ElseIf NextWord$ = "P" And *Cursor < *InBufferEnd-7 And CompareMemoryString(*Cursor, ToAscii(".p-utf8"), #PB_String_NoCase, 7, #PB_Ascii) = 0
  JMP   _EndIf207
_EndIf213:
  PUSH   qword [rsp+200]
  LEA    rcx,[_S7]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE     No70
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+48]
  ADD    r14,-7
  CMP    r15,r14
  JGE    No70
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 7
  PUSH   qword 1
  LEA    rax,[_S12]
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No70
Ok70:
  MOV    rax,1
  JMP    End70
No70:
  XOR    rax,rax
End70:
  AND    rax,rax
  JE    _EndIf214
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0)                   
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor, 1, *SeparatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_SeparatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Callback(*Cursor+1, 6, *NormalTextColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  PUSH   qword 6
  MOV    r15,qword [rsp+80]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; *Cursor + 7
  MOV    r15,qword [rsp+40]
  ADD    r15,7
  MOV    qword [rsp+40],r15
; SeparatorChar = #SkipSeparator                 
  MOV    qword [rsp+160],-2
; 
; 
; Else
  JMP   _EndIf207
_EndIf214:
; Callback(*StringStart, *Cursor-*StringStart, *StructureColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_StructureColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; EndIf
_EndIf207:
; EndIf
_EndIf193:
; 
; 
; ElseIf *Cursor-*StringStart > 0 
  JMP   _EndIf149
_EndIf192:
  MOV    r15,qword [rsp+40]
  SUB    r15,qword [rsp+96]
  AND    r15,r15
  JLE   _EndIf216
; 
; 
; Callback(*StringStart, *Cursor-*StringStart, *NormalTextColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; EndIf
_EndIf149:
_EndIf216:
; 
; 
; 
; 
; If SeparatorUsed = 0 And SeparatorChar <> #SkipSeparator
  MOV    r15,qword [rsp+144]
  AND    r15,r15
  JNE    No71
  MOV    r15,qword [rsp+160]
  CMP    r15,-2
  JE     No71
Ok71:
  MOV    rax,1
  JMP    End71
No71:
  XOR    rax,rax
End71:
  AND    rax,rax
  JE    _EndIf218
; 
; If SeparatorChar = '!' And IsLineStart(*LineStart, *Cursor)
  MOV    r15,qword [rsp+160]
  CMP    r15,33
  JNE    No72
  PUSH   qword [rsp+40]
  PUSH   qword [rsp+64]
  POP    rcx
  POP    rdx
  CALL  _Procedure30
  AND    rax,rax
  JE     No72
Ok72:
  MOV    rax,1
  JMP    End72
No72:
  XOR    rax,rax
End72:
  AND    rax,rax
  JE    _EndIf220
; 
; 
; 
; *StringStart = *Cursor 
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; While *Cursor < *InBufferEnd And *Cursor\b <> ';' And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b
_While221:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No73
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,59
  JE     No73
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     No73
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     No73
  MOV    rbp,qword [rsp+40]
  CMP    byte [rbp],0
  JE     No73
Ok73:
  MOV    rax,1
  JMP    End73
No73:
  XOR    rax,rax
End73:
  AND    rax,rax
  JE    _Wend221
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While221
_Wend221:
; 
; If *Cursor\b <> ';' 
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,59
  JE    _EndIf223
; NewLine = 1
  MOV    qword [rsp+168],1
; 
; If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
  MOV    r15,qword [rsp+40]
  INC    r15
  CMP    r15,qword [rsp+48]
  JGE    No74
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,10
  CMP    r15,rax
  JE     Ok75
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,13
  CMP    r15,rax
  JE     Ok75
  JMP    No75
Ok75:
  MOV    rax,1
  JMP    End75
No75:
  XOR    rax,rax
End75:
  AND    rax,rax
  JE     No74
Ok74:
  MOV    rax,1
  JMP    End74
No74:
  XOR    rax,rax
End74:
  AND    rax,rax
  JE    _EndIf225
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf225:
; 
; If *Cursor < *InBufferEnd 
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE   _EndIf227
; *Cursor + 1 
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf   
_EndIf227:
; EndIf     
_EndIf223:
; 
; Callback(*StringStart, *Cursor-*StringStart, *ASMKeywordColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_ASMKeywordColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; 
; 
; ElseIf SeparatorChar = '"'
  JMP   _EndIf219
_EndIf220:
  MOV    r15,qword [rsp+160]
  CMP    r15,34
  JNE   _EndIf228
; 
; 
; 
; *StringStart = *Cursor 
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; While *Cursor < *InBufferEnd And (*Cursor\b <> '"' And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b)
_While229:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No76
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,34
  JE     No77
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     No77
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     No77
  MOV    rbp,qword [rsp+40]
  CMP    byte [rbp],0
  JE     No77
Ok77:
  MOV    rax,1
  JMP    End77
No77:
  XOR    rax,rax
End77:
  AND    rax,rax
  JE     No76
Ok76:
  MOV    rax,1
  JMP    End76
No76:
  XOR    rax,rax
End76:
  AND    rax,rax
  JE    _Wend229
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While229
_Wend229:
; 
; If *Cursor\b = 10 Or *Cursor\b = 13
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     Ok78
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     Ok78
  JMP    No78
Ok78:
  MOV    rax,1
  JMP    End78
No78:
  XOR    rax,rax
End78:
  AND    rax,rax
  JE    _EndIf231
; NewLine = 1
  MOV    qword [rsp+168],1
; 
; If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
  MOV    r15,qword [rsp+40]
  INC    r15
  CMP    r15,qword [rsp+48]
  JGE    No79
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,10
  CMP    r15,rax
  JE     Ok80
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,13
  CMP    r15,rax
  JE     Ok80
  JMP    No80
Ok80:
  MOV    rax,1
  JMP    End80
No80:
  XOR    rax,rax
End80:
  AND    rax,rax
  JE     No79
Ok79:
  MOV    rax,1
  JMP    End79
No79:
  XOR    rax,rax
End79:
  AND    rax,rax
  JE    _EndIf233
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf    
_EndIf233:
; EndIf
_EndIf231:
; 
; If *Cursor < *InBufferEnd 
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE   _EndIf235
; *Cursor + 1      
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf        
_EndIf235:
; 
; Callback(*StringStart, *Cursor-*StringStart, *StringColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_StringColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; ElseIf SeparatorChar = '~' And *Cursor\a[1] = '"'
  JMP   _EndIf219
_EndIf228:
  MOV    r15,qword [rsp+160]
  CMP    r15,126
  JNE    No81
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,34
  CMP    r15,rax
  JNE    No81
Ok81:
  MOV    rax,1
  JMP    End81
No81:
  XOR    rax,rax
End81:
  AND    rax,rax
  JE    _EndIf236
; 
; 
; 
; *StringStart = *Cursor 
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 2
  MOV    r15,qword [rsp+40]
  ADD    r15,2
  MOV    qword [rsp+40],r15
; 
; While *Cursor < *InBufferEnd         
_While237:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE   _Wend237
; Select *Cursor\b
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  MOV    rax,r15
  PUSH   rax
; 
; Case 0         
  XOR    r15,r15
  CMP    r15,[rsp]
  JNE   _Case1
; Break
  ADD    rsp,8
  JMP   _Wend237
; 
; Case 13, 10    
  JMP   _EndSelect1
_Case1:
  MOV    r15,13
  CMP    r15,[rsp]
  JE    _Case2
  MOV    r15,10
  CMP    r15,[rsp]
  JNE   _Case3
_Case2:
; NewLine = 1              
  MOV    qword [rsp+176],1
; If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
  MOV    r15,qword [rsp+48]
  INC    r15
  CMP    r15,qword [rsp+56]
  JGE    No82
  MOV    rbp,qword [rsp+48]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,10
  CMP    r15,rax
  JE     Ok83
  MOV    rbp,qword [rsp+48]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,13
  CMP    r15,rax
  JE     Ok83
  JMP    No83
Ok83:
  MOV    rax,1
  JMP    End83
No83:
  XOR    rax,rax
End83:
  AND    rax,rax
  JE     No82
Ok82:
  MOV    rax,1
  JMP    End82
No82:
  XOR    rax,rax
End82:
  AND    rax,rax
  JE    _EndIf239
; *Cursor + 1
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; EndIf    
_EndIf239:
; Break      
  ADD    rsp,8
  JMP   _Wend237
; 
; Case '"'       
  JMP   _EndSelect1
_Case3:
  MOV    r15,34
  CMP    r15,[rsp]
  JNE   _Case4
; *Cursor + 1
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; Break
  ADD    rsp,8
  JMP   _Wend237
; 
; Case '\'       
  JMP   _EndSelect1
_Case4:
  MOV    r15,92
  CMP    r15,[rsp]
  JNE   _Case5
; If *Cursor+1 < *InBufferEnd
  MOV    r15,qword [rsp+48]
  INC    r15
  CMP    r15,qword [rsp+56]
  JGE   _EndIf241
; Select *Cursor\a[1]
  MOV    rbp,qword [rsp+48]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,r15
  PUSH   rax
; 
; Case 'a', 'b', 'f', 'n', 'r', 't', 'v', '"', '\'
  MOV    r15,97
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,98
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,102
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,110
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,114
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,116
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,118
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,34
  CMP    r15,[rsp]
  JE    _Case6
  MOV    r15,92
  CMP    r15,[rsp]
  JNE   _Case7
_Case6:
; 
; *Cursor + 2
  MOV    r15,qword [rsp+56]
  ADD    r15,2
  MOV    qword [rsp+56],r15
; 
; Default
  JMP   _EndSelect2
_Case7:
; 
; If *Cursor > *StringStart
  MOV    r15,qword [rsp+56]
  CMP    r15,qword [rsp+112]
  JLE   _EndIf243
; Callback(*StringStart, *Cursor-*StringStart, *StringColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_StringColor]
  MOV    r15,qword [rsp+88]
  SUB    r15,qword [rsp+144]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+152]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+88]
  ADD    rsp,48
; EndIf                    
_EndIf243:
; Callback(*StringStart, 2, *BadEscapeColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_BadEscapeColor]
  PUSH   qword 2
  PUSH   qword [rsp+152]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+88]
  ADD    rsp,48
; *Cursor + 2
  MOV    r15,qword [rsp+56]
  ADD    r15,2
  MOV    qword [rsp+56],r15
; *StringStart = *Cursor
  PUSH   qword [rsp+56]
  POP    rax
  MOV    qword [rsp+112],rax
; 
; EndSelect
_Case8:
_EndSelect2:
  POP    rax
; Else
  JMP   _EndIf240
_EndIf241:
; *Cursor + 1
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; Break
  ADD    rsp,8
  JMP   _Wend237
; EndIf
_EndIf240:
; 
; Default        
  JMP   _EndSelect1
_Case5:
; *Cursor + 1         
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; 
; EndSelect        
_Case9:
_EndSelect1:
  POP    rax
; Wend
  JMP   _While237
_Wend237:
; 
; If *Cursor > *StringStart
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+96]
  JLE   _EndIf246
; Callback(*StringStart, *Cursor-*StringStart, *StringColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_StringColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf 
_EndIf246:
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; ElseIf SeparatorChar = ';'
  JMP   _EndIf219
_EndIf236:
  MOV    r15,qword [rsp+160]
  CMP    r15,59
  JNE   _EndIf247
; 
; 
; 
; 
; 
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; WhiteOnly = #True
  MOV    qword [rsp+216],1
; While *Cursor < *InBufferEnd And (*Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b)
_While248:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No84
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     No85
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     No85
  MOV    rbp,qword [rsp+40]
  CMP    byte [rbp],0
  JE     No85
Ok85:
  MOV    rax,1
  JMP    End85
No85:
  XOR    rax,rax
End85:
  AND    rax,rax
  JE     No84
Ok84:
  MOV    rax,1
  JMP    End84
No84:
  XOR    rax,rax
End84:
  AND    rax,rax
  JE    _Wend248
; If *Cursor\b <> ' ' And *Cursor\b <> 9
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     No86
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     No86
Ok86:
  MOV    rax,1
  JMP    End86
No86:
  XOR    rax,rax
End86:
  AND    rax,rax
  JE    _EndIf250
; WhiteOnly = #False
  MOV    qword [rsp+216],0
; EndIf
_EndIf250:
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While248
_Wend248:
; NewLine = 1
  MOV    qword [rsp+168],1
; *LineEnd = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+224],rax
; 
; If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
  MOV    r15,qword [rsp+40]
  INC    r15
  CMP    r15,qword [rsp+48]
  JGE    No87
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,10
  CMP    r15,rax
  JE     Ok88
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,13
  CMP    r15,rax
  JE     Ok88
  JMP    No88
Ok88:
  MOV    rax,1
  JMP    End88
No88:
  XOR    rax,rax
End88:
  AND    rax,rax
  JE     No87
Ok87:
  MOV    rax,1
  JMP    End87
No87:
  XOR    rax,rax
End87:
  AND    rax,rax
  JE    _EndIf252
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf252:
; 
; If *Cursor < *InBufferEnd 
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE   _EndIf254
; *Cursor + 1        
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf254:
; 
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
; 
; 
; Callback(*StringStart, *Cursor-*StringStart, *CommentColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_CommentColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; CompilerEndIf
; 
; ElseIf SeparatorChar = '#'
  JMP   _EndIf219
_EndIf247:
  MOV    r15,qword [rsp+160]
  CMP    r15,35
  JNE   _EndIf255
; 
; 
; 
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; While *Cursor < *InBufferEnd And ValidCharacters(*Cursor\a)
_While256:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No89
  MOV    rbp,qword [rsp+40]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No89
Ok89:
  MOV    rax,1
  JMP    End89
No89:
  XOR    rax,rax
End89:
  AND    rax,rax
  JE    _Wend256
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While256
_Wend256:
; 
; If *Cursor < *InBufferEnd And *Cursor\b = '$' 
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No90
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,36
  JNE    No90
Ok90:
  MOV    rax,1
  JMP    End90
No90:
  XOR    rax,rax
End90:
  AND    rax,rax
  JE    _EndIf258
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf258:
; 
; 
; If EnableCaseCorrection And ConstantListSize > 0 And *Cursor > *StringStart + 1 And IsKnownConstant(PeekAsciiLength(*StringStart, *Cursor-*StringStart)) And (CursorPosition = 0 Or CursorPosition < *StringStart-*InBuffer Or CursorPosition > *Cursor-*InBuffer)
  CMP    qword [v_EnableCaseCorrection],0
  JE     No91
  MOV    r15,qword [v_ConstantListSize]
  AND    r15,r15
  JLE    No91
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+96]
  INC    r14
  CMP    r15,r14
  JLE    No91
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 24
  MOV    r15,qword [rsp+88]
  SUB    r15,qword [rsp+144]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+152]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_PeekS3
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure22
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
  AND    rax,rax
  JE     No91
  MOV    r15,qword [rsp+PS34+16]
  AND    r15,r15
  JE     Ok92
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+96]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JL     Ok92
  MOV    r15,qword [rsp+PS34+16]
  MOV    r14,qword [rsp+40]
  SUB    r14,qword [rsp+PS34+0]
  CMP    r15,r14
  JG     Ok92
  JMP    No92
Ok92:
  MOV    rax,1
  JMP    End92
No92:
  XOR    rax,rax
End92:
  AND    rax,rax
  JE     No91
Ok91:
  MOV    rax,1
  JMP    End91
No91:
  XOR    rax,rax
End91:
  AND    rax,rax
  JE    _EndIf260
; TextChanged = CopyMemoryCheck(ToAscii(KnownConstant$), *StringStart, Len(KnownConstant$)) 
  PUSH   qword [v_KnownConstant$]
  POP    rcx
  CALL   PB_Len
  MOV    rax,rax
  PUSH   rax
  PUSH   qword [rsp+104]
  PUSH   qword [v_KnownConstant$]
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL  _Procedure6
  MOV    qword [rsp+176],rax
; Callback(*StringStart, *Cursor-*StringStart, *ConstantColor, 0, TextChanged) 
  SUB    rsp,8
  PUSH   qword [rsp+184]
  PUSH   qword 0
  PUSH   qword [p_ConstantColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; Else
  JMP   _EndIf259
_EndIf260:
; Callback(*StringStart, *Cursor-*StringStart, *ConstantColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_ConstantColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf
_EndIf259:
; 
; SeparatorChar = #SkipSeparator 
  MOV    qword [rsp+160],-2
; 
; ElseIf SeparatorChar = 39 
  JMP   _EndIf219
_EndIf255:
  MOV    r15,qword [rsp+160]
  CMP    r15,39
  JNE   _EndIf262
; 
; 
; 
; *StringStart = *Cursor 
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; While *Cursor < *InBufferEnd And (*Cursor\b <> 39 And *Cursor\b <> 10 And *Cursor\b <> 13 And *Cursor\b)
_While263:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No93
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,39
  JE     No94
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     No94
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     No94
  MOV    rbp,qword [rsp+40]
  CMP    byte [rbp],0
  JE     No94
Ok94:
  MOV    rax,1
  JMP    End94
No94:
  XOR    rax,rax
End94:
  AND    rax,rax
  JE     No93
Ok93:
  MOV    rax,1
  JMP    End93
No93:
  XOR    rax,rax
End93:
  AND    rax,rax
  JE    _Wend263
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While263
_Wend263:
; 
; If *Cursor < *InBufferEnd And (*Cursor\b = 10 Or *Cursor\b = 13)
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No95
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     Ok96
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     Ok96
  JMP    No96
Ok96:
  MOV    rax,1
  JMP    End96
No96:
  XOR    rax,rax
End96:
  AND    rax,rax
  JE     No95
Ok95:
  MOV    rax,1
  JMP    End95
No95:
  XOR    rax,rax
End95:
  AND    rax,rax
  JE    _EndIf265
; NewLine = 1
  MOV    qword [rsp+168],1
; 
; If *Cursor+1 < *InBufferEnd And (*Cursor\a[1] = 10 Or *Cursor\a[1] = 13)
  MOV    r15,qword [rsp+40]
  INC    r15
  CMP    r15,qword [rsp+48]
  JGE    No97
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,10
  CMP    r15,rax
  JE     Ok98
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rax,13
  CMP    r15,rax
  JE     Ok98
  JMP    No98
Ok98:
  MOV    rax,1
  JMP    End98
No98:
  XOR    rax,rax
End98:
  AND    rax,rax
  JE     No97
Ok97:
  MOV    rax,1
  JMP    End97
No97:
  XOR    rax,rax
End97:
  AND    rax,rax
  JE    _EndIf267
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf267:
; EndIf
_EndIf265:
; 
; Callback(*StringStart, *Cursor-*StringStart+1, *ConstantColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_ConstantColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; 
; 
; ElseIf SeparatorChar = '$'
  JMP   _EndIf219
_EndIf262:
  MOV    r15,qword [rsp+160]
  CMP    r15,36
  JNE   _EndIf268
; 
; 
; 
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; While *Cursor < *InBufferEnd And ((*Cursor\b >= '0' And *Cursor\b <= '9') Or (*Cursor\b >= 'A' And *Cursor\b <= 'F') Or (*Cursor\b >= 'a' And *Cursor\b <= 'f'))
_While269:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No99
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,48
  JL     No100
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,57
  JG     No100
Ok100:
  MOV    rax,1
  JMP    End100
No100:
  XOR    rax,rax
End100:
  AND    rax,rax
  JNE    Ok101
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,65
  JL     No102
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,70
  JG     No102
Ok102:
  MOV    rax,1
  JMP    End102
No102:
  XOR    rax,rax
End102:
  AND    rax,rax
  JNE    Ok103
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,97
  JL     No104
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,102
  JG     No104
Ok104:
  MOV    rax,1
  JMP    End104
No104:
  XOR    rax,rax
End104:
  AND    rax,rax
  JNE    Ok103
  JMP    No103
Ok103:
  MOV    rax,1
  JMP    End103
No103:
  XOR    rax,rax
End103:
  AND    rax,rax
  JNE    Ok101
  JMP    No101
Ok101:
  MOV    rax,1
  JMP    End101
No101:
  XOR    rax,rax
End101:
  AND    rax,rax
  JE     No99
Ok99:
  MOV    rax,1
  JMP    End99
No99:
  XOR    rax,rax
End99:
  AND    rax,rax
  JE    _Wend269
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While269
_Wend269:
; 
; Callback(*StringStart, *Cursor-*StringStart, *NumberColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NumberColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; 
; ElseIf SeparatorChar = '%'
  JMP   _EndIf219
_EndIf268:
  MOV    r15,qword [rsp+160]
  CMP    r15,37
  JNE   _EndIf270
; 
; 
; 
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; 
; While *Cursor < *InBufferEnd And (*Cursor\b = '1' Or *Cursor\b = '0')
_While271:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No105
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,49
  JE     Ok106
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,48
  JE     Ok106
  JMP    No106
Ok106:
  MOV    rax,1
  JMP    End106
No106:
  XOR    rax,rax
End106:
  AND    rax,rax
  JE     No105
Ok105:
  MOV    rax,1
  JMP    End105
No105:
  XOR    rax,rax
End105:
  AND    rax,rax
  JE    _Wend271
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While271
_Wend271:
; 
; If *Cursor = *StringStart + 1   
  MOV    r15,qword [rsp+40]
  MOV    r14,qword [rsp+96]
  INC    r14
  CMP    r15,r14
  JNE   _EndIf273
; Callback(*StringStart, 1, *OperatorColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_OperatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; Else  
  JMP   _EndIf272
_EndIf273:
; Callback(*StringStart, *Cursor-*StringStart, *NumberColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NumberColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; EndIf  
_EndIf272:
; SeparatorChar = #SkipSeparator
  MOV    qword [rsp+160],-2
; 
; 
; ElseIf SeparatorChar = '@' Or SeparatorChar = '?'
  JMP   _EndIf219
_EndIf270:
  MOV    r15,qword [rsp+160]
  CMP    r15,64
  JE     Ok107
  MOV    r15,qword [rsp+160]
  CMP    r15,63
  JE     Ok107
  JMP    No107
Ok107:
  MOV    rax,1
  JMP    End107
No107:
  XOR    rax,rax
End107:
  AND    rax,rax
  JE    _EndIf275
; 
; 
; 
; IsNumber = 0
  MOV    qword [rsp+232],0
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; 
; While *Cursor < *InBufferEnd And (ValidCharacters(*Cursor\a) Or *Cursor\b = '$')
_While276:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No108
  MOV    rbp,qword [rsp+40]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JNE    Ok109
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,36
  JE     Ok109
  JMP    No109
Ok109:
  MOV    rax,1
  JMP    End109
No109:
  XOR    rax,rax
End109:
  AND    rax,rax
  JE     No108
Ok108:
  MOV    rax,1
  JMP    End108
No108:
  XOR    rax,rax
End108:
  AND    rax,rax
  JE    _Wend276
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While276
_Wend276:
; 
; Callback(*StringStart, *Cursor-*StringStart, *PointerColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_PointerColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorChar = #SkipSeparator 
  MOV    qword [rsp+160],-2
; 
; 
; 
; ElseIf SeparatorChar = '*'
  JMP   _EndIf219
_EndIf275:
  MOV    r15,qword [rsp+160]
  CMP    r15,42
  JNE   _EndIf277
; 
; 
; 
; If ValidCharacters(*Cursor\a[1]) = 0 
  MOV    rbp,qword [rsp+40]
  PUSH   rbp
  POP    rbp
  MOVZX  r15,byte [rbp+1]
  MOV    rbp,qword [a_ValidCharacters]
  MOVSX  r15,byte [rbp+r15]
  AND    r15,r15
  JNE   _EndIf279
; Callback(*Cursor, 1, *OperatorColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_OperatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; Else 
  JMP   _EndIf278
_EndIf279:
; 
; *BackCursor.HilightPTR = *Cursor-1
  MOV    r15,qword [rsp+40]
  DEC    r15
  MOV    qword [rsp+240],r15
; IsPointer = 1
  MOV    qword [rsp+248],1
; While *BackCursor >= *InBuffer And *BackCursor\b <> 10 And *BackCursor\b <> 13
_While281:
  MOV    r15,qword [rsp+240]
  CMP    r15,qword [rsp+PS34+0]
  JL     No110
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,10
  JE     No110
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,13
  JE     No110
Ok110:
  MOV    rax,1
  JMP    End110
No110:
  XOR    rax,rax
End110:
  AND    rax,rax
  JE    _Wend281
; If *BackCursor\b = '(' Or *BackCursor\b = ':' Or *BackCursor\b = '[' Or *BackCursor\b = ',' Or *BackCursor\b = '*' Or *BackCursor\b = '=' Or *BackCursor\b = '+' Or *BackCursor\b = '-' Or *BackCursor\b = '/' Or *BackCursor\b = '@' Or *BackCursor\b = '&' Or *BackCursor\b = '|' Or *BackCursor\b = '!' Or *BackCursor\b = '~' Or *BackCursor\b = '<' Or *BackCursor\b = '>' Or *BackCursor\b = '\' Or *BackCursor\b = '%'
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,40
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,58
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,91
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,44
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,42
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,61
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,43
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,45
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,47
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,64
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,38
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,124
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,33
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,126
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,60
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,62
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,92
  JE     Ok111
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,37
  JE     Ok111
  JMP    No111
Ok111:
  MOV    rax,1
  JMP    End111
No111:
  XOR    rax,rax
End111:
  AND    rax,rax
  JE    _EndIf283
; 
; Break     
  JMP   _Wend281
; ElseIf ValidCharacters(*BackCursor\a) Or *BackCursor\b = ')' Or *BackCursor\b = ']' Or *BackCursor\b = '.'
  JMP   _EndIf282
_EndIf283:
  MOV    rbp,qword [rsp+240]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JNE    Ok112
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,41
  JE     Ok112
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,93
  JE     Ok112
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,46
  JE     Ok112
  JMP    No112
Ok112:
  MOV    rax,1
  JMP    End112
No112:
  XOR    rax,rax
End112:
  AND    rax,rax
  JE    _EndIf284
; 
; IsPointer = 0
  MOV    qword [rsp+248],0
; Break
  JMP   _Wend281
; EndIf
_EndIf282:
_EndIf284:
; *BackCursor - 1
  MOV    r15,qword [rsp+240]
  DEC    r15
  MOV    qword [rsp+240],r15
; Wend
  JMP   _While281
_Wend281:
; 
; If ValidCharacters(*BackCursor\a)  
  MOV    rbp,qword [rsp+240]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE    _EndIf286
; *CheckEnd = *BackCursor
  PUSH   qword [rsp+240]
  POP    rax
  MOV    qword [rsp+256],rax
; While *BackCursor >= *InBuffer And ValidCharacters(*BackCursor\a) 
_While287:
  MOV    r15,qword [rsp+240]
  CMP    r15,qword [rsp+PS34+0]
  JL     No113
  MOV    rbp,qword [rsp+240]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No113
Ok113:
  MOV    rax,1
  JMP    End113
No113:
  XOR    rax,rax
End113:
  AND    rax,rax
  JE    _Wend287
; *BackCursor - 1
  MOV    r15,qword [rsp+240]
  DEC    r15
  MOV    qword [rsp+240],r15
; Wend            
  JMP   _While287
_Wend287:
; IsPointer = IsBasicKeyword(PeekAsciiLength(*BackCursor+1, *CheckEnd-*BackCursor))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 24
  MOV    r15,qword [rsp+320]
  SUB    r15,qword [rsp+304]
  MOV    rax,r15
  PUSH   rax
  MOV    r15,qword [rsp+312]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_PeekS3
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL  _Procedure26
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
  MOV    qword [rsp+248],rax
; 
; If IsPointer = 0 And *BackCursor >= *InBuffer And *BackCursor\b = '.' 
  MOV    r15,qword [rsp+248]
  AND    r15,r15
  JNE    No114
  MOV    r15,qword [rsp+240]
  CMP    r15,qword [rsp+PS34+0]
  JL     No114
  MOV    rbp,qword [rsp+240]
  MOVSX  r15,byte [rbp]
  CMP    r15,46
  JNE    No114
Ok114:
  MOV    rax,1
  JMP    End114
No114:
  XOR    rax,rax
End114:
  AND    rax,rax
  JE    _EndIf289
; *BackCursor - 1
  MOV    r15,qword [rsp+240]
  DEC    r15
  MOV    qword [rsp+240],r15
; *CheckEnd = *BackCursor
  PUSH   qword [rsp+240]
  POP    rax
  MOV    qword [rsp+256],rax
; While *BackCursor >= *InBuffer And ValidCharacters(*BackCursor\a) 
_While290:
  MOV    r15,qword [rsp+240]
  CMP    r15,qword [rsp+PS34+0]
  JL     No115
  MOV    rbp,qword [rsp+240]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No115
Ok115:
  MOV    rax,1
  JMP    End115
No115:
  XOR    rax,rax
End115:
  AND    rax,rax
  JE    _Wend290
; *BackCursor - 1
  MOV    r15,qword [rsp+240]
  DEC    r15
  MOV    qword [rsp+240],r15
; Wend               
  JMP   _While290
_Wend290:
; IsPointer = IsBasicKeyword(PeekAsciiLength(*BackCursor+1, *CheckEnd-*BackCursor))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 24
  MOV    r15,qword [rsp+320]
  SUB    r15,qword [rsp+304]
  MOV    rax,r15
  PUSH   rax
  MOV    r15,qword [rsp+312]
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_PeekS3
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL  _Procedure26
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
  MOV    qword [rsp+248],rax
; EndIf
_EndIf289:
; EndIf
_EndIf286:
; 
; If IsPointer = 0
  MOV    r15,qword [rsp+248]
  AND    r15,r15
  JNE   _EndIf292
; Callback(*Cursor, 1, *OperatorColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_OperatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; Else
  JMP   _EndIf291
_EndIf292:
; *StringStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+96],rax
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; While *Cursor < *InBufferEnd And (ValidCharacters(*Cursor\a) Or *Cursor\b = '$')
_While294:
  MOV    r15,qword [rsp+40]
  CMP    r15,qword [rsp+48]
  JGE    No116
  MOV    rbp,qword [rsp+40]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JNE    Ok117
  MOV    rbp,qword [rsp+40]
  MOVSX  r15,byte [rbp]
  CMP    r15,36
  JE     Ok117
  JMP    No117
Ok117:
  MOV    rax,1
  JMP    End117
No117:
  XOR    rax,rax
End117:
  AND    rax,rax
  JE     No116
Ok116:
  MOV    rax,1
  JMP    End116
No116:
  XOR    rax,rax
End116:
  AND    rax,rax
  JE    _Wend294
; *Cursor + 1
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; Wend
  JMP   _While294
_Wend294:
; 
; Callback(*StringStart, *Cursor-*StringStart, *PointerColor, 0, 0)
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_PointerColor]
  MOV    r15,qword [rsp+72]
  SUB    r15,qword [rsp+128]
  MOV    rax,r15
  PUSH   rax
  PUSH   qword [rsp+136]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; SeparatorChar = #SkipSeparator 
  MOV    qword [rsp+160],-2
; 
; EndIf
_EndIf291:
; 
; EndIf
_EndIf278:
; 
; 
; 
; 
; ElseIf SeparatorChar = '=' Or SeparatorChar = '+' Or SeparatorChar = '-' Or SeparatorChar = '/' Or SeparatorChar = '&' Or SeparatorChar = '|' Or SeparatorChar = '!' Or SeparatorChar = '~' Or SeparatorChar = '<' Or SeparatorChar = '>'
  JMP   _EndIf219
_EndIf277:
  MOV    r15,qword [rsp+160]
  CMP    r15,61
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,43
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,45
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,47
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,38
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,124
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,33
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,126
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,60
  JE     Ok118
  MOV    r15,qword [rsp+160]
  CMP    r15,62
  JE     Ok118
  JMP    No118
Ok118:
  MOV    rax,1
  JMP    End118
No118:
  XOR    rax,rax
End118:
  AND    rax,rax
  JE    _EndIf295
; 
; 
; 
; 
; Callback(*Cursor, 1, *OperatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_OperatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; 
; 
; ElseIf SeparatorChar = '(' Or SeparatorChar = ')' Or SeparatorChar = '[' Or SeparatorChar = ']' Or SeparatorChar = '.' Or SeparatorChar = ',' Or SeparatorChar = ':' Or SeparatorChar = '\'
  JMP   _EndIf219
_EndIf295:
  MOV    r15,qword [rsp+160]
  CMP    r15,40
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,41
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,91
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,93
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,46
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,44
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,58
  JE     Ok119
  MOV    r15,qword [rsp+160]
  CMP    r15,92
  JE     Ok119
  JMP    No119
Ok119:
  MOV    rax,1
  JMP    End119
No119:
  XOR    rax,rax
End119:
  AND    rax,rax
  JE    _EndIf296
; 
; 
; 
; 
; Callback(*Cursor, 1, *SeparatorColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_SeparatorColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; 
; 
; ElseIf SeparatorChar > 0
  JMP   _EndIf219
_EndIf296:
  MOV    r15,qword [rsp+160]
  AND    r15,r15
  JLE   _EndIf297
; 
; 
; 
; Callback(*Cursor, 1, *NormalTextColor, 0, 0) 
  SUB    rsp,8
  PUSH   qword 0
  PUSH   qword 0
  PUSH   qword [p_NormalTextColor]
  PUSH   qword 1
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   qword [rsp+PS34+72]
  ADD    rsp,48
; EndIf
_EndIf219:
_EndIf297:
; EndIf
_EndIf218:
; 
; If SeparatorChar > 0  
  MOV    r15,qword [rsp+160]
  AND    r15,r15
  JLE   _EndIf299
; *Cursor + 1 
  MOV    r15,qword [rsp+40]
  INC    r15
  MOV    qword [rsp+40],r15
; EndIf
_EndIf299:
; 
; OlderSeparatorChar = OldSeparatorChar
  PUSH   qword [rsp+80]
  POP    rax
  MOV    qword [rsp+88],rax
; OldSeparatorChar = SeparatorChar
  PUSH   qword [rsp+160]
  POP    rax
  MOV    qword [rsp+80],rax
; 
; If NewLine
  CMP    qword [rsp+168],0
  JE    _EndIf301
; *LineStart = *Cursor
  PUSH   qword [rsp+40]
  POP    rax
  MOV    qword [rsp+56],rax
; OldSeparatorChar = 0
  MOV    qword [rsp+80],0
; OlderSeparatorChar = 0
  MOV    qword [rsp+88],0
; EndIf
_EndIf301:
; 
; If SeparatorChar = #EndSeparator 
  MOV    r15,qword [rsp+160]
  CMP    r15,-1
  JNE   _EndIf303
; Break
  JMP   _Wend131
; EndIf
_EndIf303:
; Wend
  JMP   _While131
_Wend131:
; 
; 
; EndProcedure
_EndProcedureZero35:
  XOR    rax,rax
_EndProcedure35:
  PUSH   rax
  MOV    rcx,qword [rsp+144]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  MOV    rcx,qword [rsp+208]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,272
  POP    r14
  POP    r15
  POP    rbp
  RET
; Procedure IsCustomKeyword(Word$)
_Procedure20:
  MOV    qword [rsp+8],rcx
  PUSH   rbp
  PUSH   r15
  PS20=112
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS20+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; 
; k = CustomKeywordsHT(Asc(UCase(Word$)))  
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+80]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL   PB_Asc
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
  MOV    r15,rax
  MOV    rbp,qword [a_CustomKeywordsHT]
  SAL    r15,2
  MOVSXD rax,dword [rbp+r15]
  PUSH   rax
  POP    rax
  MOV    qword [rsp+48],rax
; If k
  CMP    qword [rsp+48],0
  JE    _EndIf71
; While Quit = 0 And k <= NbCustomKeywords
_While72:
  MOV    r15,qword [rsp+56]
  AND    r15,r15
  JNE    No5
  MOV    r15,qword [rsp+48]
  CMP    r15,qword [v_NbCustomKeywords]
  JG     No5
Ok5:
  MOV    rax,1
  JMP    End5
No5:
  XOR    rax,rax
End5:
  AND    rax,rax
  JE    _Wend72
; 
; Compare = CompareMemoryString(@CustomKeywords(k), @Word$, #PB_String_NoCase)  
  PUSH   qword 1
  MOV    rax,qword [rsp+48]
  MOV    rax,rax
  PUSH   rax
  MOV    r15,qword [rsp+64]
  MOV    rbp,qword [a_CustomKeywords]
  SAL    r15,3
  MOV    rax,qword [rbp+r15]
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_CompareMemoryString2
  MOV    qword [rsp+64],rax
; 
; If Compare <= 0
  MOV    r15,qword [rsp+64]
  AND    r15,r15
  JG    _EndIf74
; If Compare = 0
  MOV    r15,qword [rsp+64]
  AND    r15,r15
  JNE   _EndIf76
; CustomKeyword$ = CustomKeywords(k)
  MOV    r15,qword [rsp+48]
  MOV    rbp,qword [a_CustomKeywords]
  SAL    r15,3
  MOV    rcx,qword [rbp+r15]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[v_CustomKeyword$]
  POP    rdx
  CALL   SYS_AllocateString4
; Result = k
  PUSH   qword [rsp+48]
  POP    rax
  MOV    qword [rsp+72],rax
; Quit = 1
  MOV    qword [rsp+56],1
; EndIf
_EndIf76:
; Else
  JMP   _EndIf73
_EndIf74:
; Quit = 1
  MOV    qword [rsp+56],1
; EndIf
_EndIf73:
; 
; k+1
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; Wend
  JMP   _While72
_Wend72:
; EndIf
_EndIf71:
; 
; ProcedureReturn Result
  MOV    rax,qword [rsp+72]
  JMP   _EndProcedure21
; EndProcedure
_EndProcedureZero21:
  XOR    rax,rax
_EndProcedure21:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,88
  POP    r15
  POP    rbp
  RET
; Procedure StringToAscii(String$)
_Procedure0:
  MOV    qword [rsp+8],rcx
  PUSH   r15
  PS0=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS0+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; 
; *Buffer = AllocateMemory(StringByteLength(String$, #PB_Ascii) + 1)
  PUSH   qword 24
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL   PB_StringByteLength2
  MOV    r15,rax
  INC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  CALL   PB_AllocateMemory
  MOV    qword [rsp+48],rax
; If *Buffer
  CMP    qword [rsp+48],0
  JE    _EndIf2
; PokeS(*Buffer, String$, -1, #PB_Ascii)
  PUSH   qword 24
  PUSH   qword -1
  PUSH   qword [rsp+56]
  PUSH   qword [rsp+72]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  CALL   PB_PokeS3
; EndIf
_EndIf2:
; 
; ProcedureReturn *Buffer
  MOV    rax,qword [rsp+48]
  JMP   _EndProcedure1
; EndProcedure
_EndProcedureZero1:
  XOR    rax,rax
_EndProcedure1:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,64
  POP    r15
  RET
; ProcedureDLL AttachProcess(Instance)
_Procedure40:
  MOV    qword [rsp+8],rcx
  PUSH   rbp
  PS40=64
  XOR    rax,rax
  PUSH   rax
  SUB    rsp,40
; 
; 
; 
; *NormalTextColor    = #SYNTAX_Text
  MOV    qword [p_NormalTextColor],0
; *BasicKeywordColor  = #SYNTAX_Keyword
  MOV    qword [p_BasicKeywordColor],1
; *CommentColor       = #SYNTAX_Comment
  MOV    qword [p_CommentColor],2
; *ConstantColor      = #SYNTAX_Constant
  MOV    qword [p_ConstantColor],3
; *StringColor        = #SYNTAX_String
  MOV    qword [p_StringColor],4
; *PureKeywordColor   = #SYNTAX_Function
  MOV    qword [p_PureKeywordColor],5
; *ASMKeywordColor    = #SYNTAX_Asm
  MOV    qword [p_ASMKeywordColor],6
; *OperatorColor      = #SYNTAX_Operator
  MOV    qword [p_OperatorColor],7
; *StructureColor     = #SYNTAX_Structure
  MOV    qword [p_StructureColor],8
; *NumberColor        = #SYNTAX_Number
  MOV    qword [p_NumberColor],9
; *PointerColor       = #SYNTAX_Pointer
  MOV    qword [p_PointerColor],10
; *SeparatorColor     = #SYNTAX_Separator
  MOV    qword [p_SeparatorColor],11
; *LabelColor         = #SYNTAX_Label  
  MOV    qword [p_LabelColor],12
; *ModuleColor        = #SYNTAX_Module
  MOV    qword [p_ModuleColor],13
; *BadEscapeColor     = #SYNTAX_String
  MOV    qword [p_BadEscapeColor],4
; 
; 
; 
; EnableColoring = 1      
  MOV    qword [v_EnableColoring],1
; EnableCaseCorrection = 0
  MOV    qword [v_EnableCaseCorrection],0
; EnableKeywordBolding = 0
  MOV    qword [v_EnableKeywordBolding],0
; LoadHilightningFiles = 0 
  MOV    qword [rsp+40],0
; 
; 
; 
; DummySource\EnableASM = 1
  LEA    rbp,[v_DummySource]
  MOV    dword [rbp],1
; *ActiveSource = @DummySource
  LEA    rax,[v_DummySource]
  MOV    rax,rax
  PUSH   rax
  POP    rax
  MOV    qword [p_ActiveSource],rax
; 
; 
; 
; InitSyntaxCheckArrays()
  CALL  _Procedure10
; InitSyntaxHilightning()  
  CALL  _Procedure12
; 
; EndProcedure
_EndProcedureZero41:
  XOR    rax,rax
_EndProcedure41:
  ADD    rsp,48
  POP    rbp
  RET
; Procedure IsAPIFunction(*Word, length)
_Procedure14:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  PUSH   rbp
  PUSH   r15
  PUSH   r14
  PS14=112
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
; Result = -1
  MOV    qword [rsp+40],-1
; 
; If length > 2 And PeekB(*Word+length-1) = '_'
  MOV    r15,qword [rsp+PS14+8]
  CMP    r15,2
  JLE    No1
  MOV    r15,qword [rsp+PS14+0]
  ADD    r15,qword [rsp+PS14+8]
  DEC    r15
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  CALL   PB_PeekB
  MOV    r15,rax
  CMP    r15,95
  JNE    No1
Ok1:
  MOV    rax,1
  JMP    End1
No1:
  XOR    rax,rax
End1:
  AND    rax,rax
  JE    _EndIf50
; length - 1
  MOV    r15,qword [rsp+PS14+8]
  DEC    r15
  MOV    qword [rsp+PS14+8],r15
; 
; k = APIFunctionsHT(ByteUcase(PeekB(*Word)))  
  PUSH   qword [rsp+PS14+0]
  POP    rcx
  CALL   PB_PeekB
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  CALL  _Procedure8
  MOV    r15,rax
  MOV    rbp,qword [a_APIFunctionsHT]
  SAL    r15,2
  MOVSXD rax,dword [rbp+r15]
  PUSH   rax
  POP    rax
  MOV    qword [rsp+48],rax
; If k
  CMP    qword [rsp+48],0
  JE    _EndIf52
; k-1
  MOV    r15,qword [rsp+48]
  DEC    r15
  MOV    qword [rsp+48],r15
; While Quit = 0 And k < NbAPIFunctions
_While53:
  MOV    r15,qword [rsp+56]
  AND    r15,r15
  JNE    No2
  MOV    r15,qword [rsp+48]
  CMP    r15,qword [v_NbApiFunctions]
  JGE    No2
Ok2:
  MOV    rax,1
  JMP    End2
No2:
  XOR    rax,rax
End2:
  AND    rax,rax
  JE    _Wend53
; If APIFunctions(k)\Name$ = ""
  MOV    r15,qword [rsp+48]
  MOV    rbp,qword [a_APIFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  PUSH   qword [rbp]
  LEA    rcx,[_S1]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf55
; Quit = 1
  MOV    qword [rsp+56],1
; Else
  JMP   _EndIf54
_EndIf55:
; Compare = CompareMemoryString(APIFunctions(k)\Ascii, *Word, 1, length, #PB_Ascii)  
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword [rsp+PS14+24]
  PUSH   qword 1
  PUSH   qword [rsp+PS14+32]
  MOV    r15,qword [rsp+88]
  MOV    rbp,qword [a_APIFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  PUSH   qword [rbp+16]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    qword [rsp+64],rax
; 
; If Compare <= 0
  MOV    r15,qword [rsp+64]
  AND    r15,r15
  JG    _EndIf58
; If Compare = 0 And length = MemoryAsciiLength(APIFunctions(k)\Ascii) 
  MOV    r15,qword [rsp+64]
  AND    r15,r15
  JNE    No3
  MOV    r15,qword [rsp+PS14+8]
  PUSH   qword 24
  MOV    r14,qword [rsp+56]
  MOV    rbp,qword [a_APIFunctions]
  IMUL   r14,280
  ADD    rbp,r14
  PUSH   qword [rbp+16]
  POP    rcx
  POP    rdx
  CALL   PB_MemoryStringLength2
  CMP    r15,rax
  JNE    No3
Ok3:
  MOV    rax,1
  JMP    End3
No3:
  XOR    rax,rax
End3:
  AND    rax,rax
  JE    _EndIf60
; Result = k
  PUSH   qword [rsp+48]
  POP    rax
  MOV    qword [rsp+40],rax
; Quit   = 1
  MOV    qword [rsp+56],1
; EndIf
_EndIf60:
; Else
  JMP   _EndIf57
_EndIf58:
; Quit = 1
  MOV    qword [rsp+56],1
; EndIf
_EndIf57:
; EndIf
_EndIf54:
; 
; k+1
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; Wend
  JMP   _While53
_Wend53:
; EndIf
_EndIf52:
; 
; EndIf
_EndIf50:
; 
; ProcedureReturn Result
  MOV    rax,qword [rsp+40]
  JMP   _EndProcedure15
; EndProcedure
_EndProcedureZero15:
  XOR    rax,rax
_EndProcedure15:
  ADD    rsp,80
  POP    r14
  POP    r15
  POP    rbp
  RET
; Procedure IsKnownConstant(Word$)
_Procedure22:
  MOV    qword [rsp+8],rcx
  PUSH   rbp
  PUSH   r15
  PS22=96
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS22+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; ascii = Asc(UCase(Mid(Word$, 2, 1))) 
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword 1
  PUSH   qword 2
  PUSH   qword [rsp+112]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_Mid2
  ADD    rsp,32
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL   PB_Asc
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
  MOV    qword [rsp+48],rax
; If ascii = '_'
  MOV    r15,qword [rsp+48]
  CMP    r15,95
  JNE   _EndIf79
; char = 27
  MOV    qword [rsp+56],27
; ElseIf ascii >= 'A' And ascii <= 'Z' 
  JMP   _EndIf78
_EndIf79:
  MOV    r15,qword [rsp+48]
  CMP    r15,65
  JL     No6
  MOV    r15,qword [rsp+48]
  CMP    r15,90
  JG     No6
Ok6:
  MOV    rax,1
  JMP    End6
No6:
  XOR    rax,rax
End6:
  AND    rax,rax
  JE    _EndIf80
; char = ascii - 'A' + 1
  MOV    r15,qword [rsp+48]
  ADD    r15,-64
  MOV    qword [rsp+56],r15
; Else
  JMP   _EndIf78
_EndIf80:
; ProcedureReturn 0
  XOR    rax,rax
  JMP   _EndProcedure23
; EndIf
_EndIf78:
; 
; For i = ConstantHT(char, 0) To ConstantHT(char, 1)     
  MOV    rdx,qword [a_ConstantHT+8]
  IMUL   rdx,qword [rsp+56]
  MOV    rbp,rdx
  PUSH   rbp
  XOR    rax,rax
  POP    rbp
  ADD    rbp,rax
  SAL    rbp,2
  ADD    rbp,qword [a_ConstantHT]
  MOVSXD rax,dword [rbp]
  PUSH   rax
  POP    rax
  MOV    qword [rsp+64],rax
  JMP   _ForSkipDebug82
_For82:
_ForSkipDebug82:
  MOV    rdx,qword [a_ConstantHT+8]
  IMUL   rdx,qword [rsp+56]
  MOV    rbp,rdx
  PUSH   rbp
  MOV    rax,1
  POP    rbp
  ADD    rbp,rax
  SAL    rbp,2
  ADD    rbp,qword [a_ConstantHT]
  MOVSXD rax,dword [rbp]
  CMP    rax,qword [rsp+64]
  JL    _Next83
; If CompareMemoryString(@Word$, @ConstantList(i), #PB_String_NoCase) = 0
  PUSH   qword 1
  MOV    r15,qword [rsp+72]
  MOV    rbp,qword [a_ConstantList]
  SAL    r15,3
  MOV    rax,qword [rbp+r15]
  MOV    rax,rax
  PUSH   rax
  MOV    rax,qword [rsp+56]
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_CompareMemoryString2
  MOV    r15,rax
  AND    r15,r15
  JNE   _EndIf85
; KnownConstant$ = ConstantList(i)
  MOV    r15,qword [rsp+64]
  MOV    rbp,qword [a_ConstantList]
  SAL    r15,3
  MOV    rcx,qword [rbp+r15]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[v_KnownConstant$]
  POP    rdx
  CALL   SYS_AllocateString4
; ProcedureReturn 1
  MOV    rax,1
  JMP   _EndProcedure23
; EndIf
_EndIf85:
; Next i
_NextContinue83:
  INC    qword [rsp+64]
  JNO   _For82
_Next83:
; 
; EndProcedure
_EndProcedureZero23:
  XOR    rax,rax
_EndProcedure23:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,72
  POP    r15
  POP    rbp
  RET
; Procedure IsAfterStructure(Keyword, *LineStart, *Cursor.HilightPTR)
_Procedure24:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  PUSH   rbp
  PUSH   r15
  PS24=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
; 
; 
; *Cursor - 1 
  MOV    r15,qword [rsp+PS24+16]
  DEC    r15
  MOV    qword [rsp+PS24+16],r15
; 
; 
; While *Cursor > *LineStart And (*Cursor\b = ' ' Or *Cursor\b = 9)
_While86:
  MOV    r15,qword [rsp+PS24+16]
  CMP    r15,qword [rsp+PS24+8]
  JLE    No7
  MOV    rbp,qword [rsp+PS24+16]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     Ok8
  MOV    rbp,qword [rsp+PS24+16]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok8
  JMP    No8
Ok8:
  MOV    rax,1
  JMP    End8
No8:
  XOR    rax,rax
End8:
  AND    rax,rax
  JE     No7
Ok7:
  MOV    rax,1
  JMP    End7
No7:
  XOR    rax,rax
End7:
  AND    rax,rax
  JE    _Wend86
; *Cursor - 1
  MOV    r15,qword [rsp+PS24+16]
  DEC    r15
  MOV    qword [rsp+PS24+16],r15
; Wend
  JMP   _While86
_Wend86:
; 
; 
; While *Cursor > *LineStart And ValidCharacters(*Cursor\a)
_While87:
  MOV    r15,qword [rsp+PS24+16]
  CMP    r15,qword [rsp+PS24+8]
  JLE    No9
  MOV    rbp,qword [rsp+PS24+16]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No9
Ok9:
  MOV    rax,1
  JMP    End9
No9:
  XOR    rax,rax
End9:
  AND    rax,rax
  JE    _Wend87
; *Cursor - 1
  MOV    r15,qword [rsp+PS24+16]
  DEC    r15
  MOV    qword [rsp+PS24+16],r15
; Wend
  JMP   _While87
_Wend87:
; 
; 
; While *Cursor > *LineStart And (*Cursor\b = ' ' Or *Cursor\b = 9)
_While88:
  MOV    r15,qword [rsp+PS24+16]
  CMP    r15,qword [rsp+PS24+8]
  JLE    No10
  MOV    rbp,qword [rsp+PS24+16]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     Ok11
  MOV    rbp,qword [rsp+PS24+16]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     Ok11
  JMP    No11
Ok11:
  MOV    rax,1
  JMP    End11
No11:
  XOR    rax,rax
End11:
  AND    rax,rax
  JE     No10
Ok10:
  MOV    rax,1
  JMP    End10
No10:
  XOR    rax,rax
End10:
  AND    rax,rax
  JE    _Wend88
; *Cursor - 1
  MOV    r15,qword [rsp+PS24+16]
  DEC    r15
  MOV    qword [rsp+PS24+16],r15
; Wend
  JMP   _While88
_Wend88:
; 
; 
; *WordEnd = *Cursor + 1
  MOV    r15,qword [rsp+PS24+16]
  INC    r15
  MOV    qword [rsp+40],r15
; While *Cursor > *LineStart And ValidCharacters(*Cursor\a)
_While89:
  MOV    r15,qword [rsp+PS24+16]
  CMP    r15,qword [rsp+PS24+8]
  JLE    No12
  MOV    rbp,qword [rsp+PS24+16]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  CMP    byte [rbp+r15],0
  JE     No12
Ok12:
  MOV    rax,1
  JMP    End12
No12:
  XOR    rax,rax
End12:
  AND    rax,rax
  JE    _Wend89
; *Cursor - 1
  MOV    r15,qword [rsp+PS24+16]
  DEC    r15
  MOV    qword [rsp+PS24+16],r15
; Wend
  JMP   _While89
_Wend89:
; 
; 
; 
; If ValidCharacters(*Cursor\a) = 0
  MOV    rbp,qword [rsp+PS24+16]
  MOVZX  r15,byte [rbp]
  MOV    rbp,qword [a_ValidCharacters]
  MOVSX  r15,byte [rbp+r15]
  AND    r15,r15
  JNE   _EndIf91
; *Cursor + 1
  MOV    r15,qword [rsp+PS24+16]
  INC    r15
  MOV    qword [rsp+PS24+16],r15
; EndIf
_EndIf91:
; 
; Length = *WordEnd - *Cursor
  MOV    r15,qword [rsp+40]
  SUB    r15,qword [rsp+PS24+16]
  MOV    qword [rsp+48],r15
; If Length = 9 And CompareMemoryString(*Cursor, *KeywordStructure, #PB_String_NoCase, 9, #PB_Ascii) = #PB_String_Equal
  MOV    r15,qword [rsp+48]
  CMP    r15,9
  JNE    No13
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 9
  PUSH   qword 1
  PUSH   qword [p_KeywordStructure]
  PUSH   qword [rsp+PS24+56]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No13
Ok13:
  MOV    rax,1
  JMP    End13
No13:
  XOR    rax,rax
End13:
  AND    rax,rax
  JE    _EndIf93
; 
; ProcedureReturn #True
  MOV    rax,1
  JMP   _EndProcedure25
; ElseIf Keyword = #KEYWORD_Extends And Length = 9 And CompareMemoryString(*Cursor, *KeywordInterface, #PB_String_NoCase, 9, #PB_Ascii) = #PB_String_Equal
  JMP   _EndIf92
_EndIf93:
  MOV    r15,qword [rsp+PS24+0]
  CMP    r15,55
  JNE    No14
  MOV    r15,qword [rsp+48]
  CMP    r15,9
  JNE    No14
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 9
  PUSH   qword 1
  PUSH   qword [p_KeywordInterface]
  PUSH   qword [rsp+PS24+56]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No14
Ok14:
  MOV    rax,1
  JMP    End14
No14:
  XOR    rax,rax
End14:
  AND    rax,rax
  JE    _EndIf94
; 
; ProcedureReturn #True
  MOV    rax,1
  JMP   _EndProcedure25
; ElseIf Keyword = #KEYWORD_Align And Length = 7 And CompareMemoryString(*Cursor, *KeywordExtends, #PB_String_NoCase, 7, #PB_Ascii) = #PB_String_Equal
  JMP   _EndIf92
_EndIf94:
  MOV    r15,qword [rsp+PS24+0]
  CMP    r15,1
  JNE    No15
  MOV    r15,qword [rsp+48]
  CMP    r15,7
  JNE    No15
  SUB    rsp,8
  PUSH   qword 24
  PUSH   qword 7
  PUSH   qword 1
  PUSH   qword [p_KeywordExtends]
  PUSH   qword [rsp+PS24+56]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_CompareMemoryString4
  ADD    rsp,48
  MOV    r15,rax
  AND    r15,r15
  JNE    No15
Ok15:
  MOV    rax,1
  JMP    End15
No15:
  XOR    rax,rax
End15:
  AND    rax,rax
  JE    _EndIf95
; 
; ProcedureReturn #True
  MOV    rax,1
  JMP   _EndProcedure25
; Else
  JMP   _EndIf92
_EndIf95:
; ProcedureReturn #False
  XOR    rax,rax
  JMP   _EndProcedure25
; EndIf
_EndIf92:
; EndProcedure
_EndProcedureZero25:
  XOR    rax,rax
_EndProcedure25:
  ADD    rsp,56
  POP    r15
  POP    rbp
  RET
; Procedure IsLineStart(*LineStart, *Cursor.BYTE)
_Procedure30:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  PUSH   rbp
  PUSH   r15
  PS30=64
  SUB    rsp,40
; *Cursor - 1 
  MOV    r15,qword [rsp+PS30+8]
  DEC    r15
  MOV    qword [rsp+PS30+8],r15
; 
; While *Cursor > *LineStart
_While118:
  MOV    r15,qword [rsp+PS30+8]
  CMP    r15,qword [rsp+PS30+0]
  JLE   _Wend118
; If *Cursor\b <> ' ' And *Cursor\b <> 9
  MOV    rbp,qword [rsp+PS30+8]
  MOVSX  r15,byte [rbp]
  CMP    r15,32
  JE     No22
  MOV    rbp,qword [rsp+PS30+8]
  MOVSX  r15,byte [rbp]
  CMP    r15,9
  JE     No22
Ok22:
  MOV    rax,1
  JMP    End22
No22:
  XOR    rax,rax
End22:
  AND    rax,rax
  JE    _EndIf120
; ProcedureReturn 0
  XOR    rax,rax
  JMP   _EndProcedure31
; EndIf
_EndIf120:
; *Cursor - 1
  MOV    r15,qword [rsp+PS30+8]
  DEC    r15
  MOV    qword [rsp+PS30+8],r15
; Wend
  JMP   _While118
_Wend118:
; 
; ProcedureReturn 1
  MOV    rax,1
  JMP   _EndProcedure31
; EndProcedure
_EndProcedureZero31:
  XOR    rax,rax
_EndProcedure31:
  ADD    rsp,40
  POP    r15
  POP    rbp
  RET
; Procedure IsBasicFunction(Word$) 
_Procedure16:
  MOV    qword [rsp+8],rcx
  PUSH   rbp
  PUSH   r15
  PS16=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS16+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; ProcedureReturn BasicFunctionMap(Word$) - 1 
  PUSH   qword [rsp+40]
  POP    rdx
  MOV    rcx,qword [m_BasicFunctionMap]
  CALL   PB_GetMapElement
  MOV    rbp,rax
  MOVSXD r15,dword [rbp]
  DEC    r15
  MOV    rax,r15
  JMP   _EndProcedure17
; EndProcedure
_EndProcedureZero17:
  XOR    rax,rax
_EndProcedure17:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,56
  POP    r15
  POP    rbp
  RET
; Procedure ByteUcase(Byte.a) 
_Procedure8:
  MOV    qword [rsp+8],rcx
  PUSH   r15
  PS8=64
  XOR    rax,rax
  PUSH   rax
  SUB    rsp,40
; If Byte >= 'a' And Byte <= 'z'
  MOVZX  r15,byte [rsp+PS8+0]
  MOV    rax,97
  CMP    r15,rax
  JL     No0
  MOVZX  r15,byte [rsp+PS8+0]
  MOV    rax,122
  CMP    r15,rax
  JG     No0
Ok0:
  MOV    rax,1
  JMP    End0
No0:
  XOR    rax,rax
End0:
  AND    rax,rax
  JE    _EndIf19
; ProcedureReturn Byte - 'a' + 'A'
  MOVZX  r15,byte [rsp+PS8+0]
  ADD    r15,-32
  MOV    rax,r15
  JMP   _EndProcedure9
; Else
  JMP   _EndIf18
_EndIf19:
; ProcedureReturn Byte
  MOVZX  rax,byte [rsp+PS8+0]
  JMP   _EndProcedure9
; EndIf
_EndIf18:
; EndProcedure
_EndProcedureZero9:
  XOR    rax,rax
_EndProcedure9:
  ADD    rsp,48
  POP    r15
  RET
; Procedure DllCallback(*StringStart.BYTE, Length, *Color, IsBold, TextChanged)
_Procedure38:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  MOV    qword [rsp+32],r9
  PS38=48
  SUB    rsp,40
; UserCallback(*StringStart, Length, *Color)
  PUSH   qword [rsp+PS38+16]
  PUSH   qword [rsp+PS38+16]
  PUSH   qword [rsp+PS38+16]
  POP    rcx
  POP    rdx
  POP    r8
  CALL   qword [v_UserCallback]
; EndProcedure
_EndProcedureZero39:
  XOR    rax,rax
_EndProcedure39:
  ADD    rsp,40
  RET
; Procedure InitSyntaxCheckArrays()
_Procedure10:
  PUSH   rbp
  PUSH   r15
  PUSH   r14
  PS10=96
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
; 
; 
; 
; 
; For k='0' To '9'            
  MOV    qword [rsp+40],48
  JMP   _ForSkipDebug21
_For21:
_ForSkipDebug21:
  MOV    rax,57
  CMP    rax,qword [rsp+40]
  JL    _Next22
; ValidCharacters(k) = 1
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_ValidCharacters]
  MOV    byte [rbp+r15],1
; Next
_NextContinue22:
  INC    qword [rsp+40]
  JNO   _For21
_Next22:
; 
; For k='A' To 'Z'            
  MOV    qword [rsp+40],65
  JMP   _ForSkipDebug23
_For23:
_ForSkipDebug23:
  MOV    rax,90
  CMP    rax,qword [rsp+40]
  JL    _Next24
; ValidCharacters(k) = 1
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_ValidCharacters]
  MOV    byte [rbp+r15],1
; Next
_NextContinue24:
  INC    qword [rsp+40]
  JNO   _For23
_Next24:
; 
; For k='a' To 'z'            
  MOV    qword [rsp+40],97
  JMP   _ForSkipDebug25
_For25:
_ForSkipDebug25:
  MOV    rax,122
  CMP    rax,qword [rsp+40]
  JL    _Next26
; ValidCharacters(k) = 1
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_ValidCharacters]
  MOV    byte [rbp+r15],1
; Next
_NextContinue26:
  INC    qword [rsp+40]
  JNO   _For25
_Next26:
; 
; ValidCharacters('_') = 1
  MOV    rbp,qword [a_ValidCharacters]
  MOV    byte [rbp+95],1
; 
; 
; 
; 
; 
; CurrentChar = 0
  MOV    qword [rsp+48],0
; Restore BasicKeywords
  LEA    rax,[ll_initsyntaxcheckarrays_basickeywords]
  MOV    qword [PB_DataPointer],rax
; For k=1 To #NbBasicKeywords
  MOV    qword [rsp+40],1
  JMP   _ForSkipDebug27
_For27:
_ForSkipDebug27:
  MOV    rax,111
  CMP    rax,qword [rsp+40]
  JL    _Next28
; Read.s BasicKeywordsReal(k)
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_BasicKeywordsReal]
  SAL    r15,3
  LEA    rcx,[rbp+r15]
  MOV    rdx,qword [PB_DataPointer]
  CALL   SYS_FastAllocateStringFree4
  ADD    qword [PB_DataPointer],rax
; BasicKeywords(k) = LCase(BasicKeywordsReal(k))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    r15,qword [rsp+64]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_LCase
  ADD    rsp,40
  MOV    r15,qword [rsp+48]
  MOV    rbp,qword [a_BasicKeywords]
  SAL    r15,3
  LEA    rcx,[rbp+r15]
  POP    rdx
  CALL   SYS_AllocateString4
; Read.s BasicKeywordsEndKeywords(k)
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_BasicKeywordsEndKeywords]
  SAL    r15,3
  LEA    rcx,[rbp+r15]
  MOV    rdx,qword [PB_DataPointer]
  CALL   SYS_FastAllocateStringFree4
  ADD    qword [PB_DataPointer],rax
; Read.s BasicKeywordsSpaces(k)
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_BasicKeywordsSpaces]
  SAL    r15,3
  LEA    rcx,[rbp+r15]
  MOV    rdx,qword [PB_DataPointer]
  CALL   SYS_FastAllocateStringFree4
  ADD    qword [PB_DataPointer],rax
; 
; Char = Asc(BasicKeywords(k))
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_BasicKeywords]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  POP    rcx
  CALL   PB_Asc
  MOV    qword [rsp+56],rax
; If Char <> CurrentChar
  MOV    r15,qword [rsp+56]
  CMP    r15,qword [rsp+48]
  JE    _EndIf30
; BasicKeywordsHT(Char) = k
  PUSH   qword [rsp+40]
  MOV    r15,qword [rsp+64]
  MOV    rbp,qword [a_BasicKeywordsHT]
  SAL    r15,2
  POP    rax
  MOV    dword [rbp+r15],eax
; CurrentChar = Char
  PUSH   qword [rsp+56]
  POP    rax
  MOV    qword [rsp+48],rax
; EndIf
_EndIf30:
; Next
_NextContinue28:
  INC    qword [rsp+40]
  JNO   _For27
_Next28:
; 
; 
; 
; 
; For Char = 'A' To 'Z'
  MOV    qword [rsp+56],65
  JMP   _ForSkipDebug31
_For31:
_ForSkipDebug31:
  MOV    rax,90
  CMP    rax,qword [rsp+56]
  JL    _Next32
; BasicKeywordsHT(Char) = BasicKeywordsHT(Char+('a'-'A'))
  MOV    r15,qword [rsp+56]
  ADD    r15,32
  MOV    rbp,qword [a_BasicKeywordsHT]
  SAL    r15,2
  MOVSXD rax,dword [rbp+r15]
  PUSH   rax
  MOV    r15,qword [rsp+64]
  SAL    r15,2
  POP    rax
  MOV    dword [rbp+r15],eax
; Next Char
_NextContinue32:
  INC    qword [rsp+56]
  JNO   _For31
_Next32:
; 
; 
; 
; CurrentChar = 0
  MOV    qword [rsp+48],0
; Restore ASMKeywords
  LEA    rax,[ll_initsyntaxcheckarrays_asmkeywords]
  MOV    qword [PB_DataPointer],rax
; 
; Read.l NbASMKeywords
  MOV    rax,qword [PB_DataPointer]
  MOVSXD rax,dword [rax]
  MOV    dword [v_NbASMKeywords],eax
  ADD    qword [PB_DataPointer],4
; 
; Global Dim ASMKeywords.s(NbASMKeywords)
  MOVSXD rax,dword [v_NbASMKeywords]
  INC    rax
  SUB    rsp,24
  MOV    rdx,rax
  LEA    rax,[a_ASMKeywords]
  PUSH   rax
  LEA    r9,[s_s]
  MOV    r8,8
  MOV    rcx,8
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_ASMKeywords],rax
; 
; For k=1 To NbASMKeywords
  MOV    qword [rsp+40],1
  JMP   _ForSkipDebug33
_For33:
_ForSkipDebug33:
  MOVSXD rax,dword [v_NbASMKeywords]
  CMP    rax,qword [rsp+40]
  JL    _Next34
; Read.s ASMKeywords(k)
  MOV    r15,qword [rsp+40]
  MOV    rbp,qword [a_ASMKeywords]
  SAL    r15,3
  LEA    rcx,[rbp+r15]
  MOV    rdx,qword [PB_DataPointer]
  CALL   SYS_FastAllocateStringFree4
  ADD    qword [PB_DataPointer],rax
; 
; Char = Asc(ASMKeywords(k))
  MOV    r15,qword [rsp+40]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  POP    rcx
  CALL   PB_Asc
  MOV    qword [rsp+56],rax
; If Char <> CurrentChar
  MOV    r15,qword [rsp+56]
  CMP    r15,qword [rsp+48]
  JE    _EndIf36
; ASMKeywordsHT(Char) = k
  PUSH   qword [rsp+40]
  MOV    r15,qword [rsp+64]
  MOV    rbp,qword [a_ASMKeywordsHT]
  SAL    r15,2
  POP    rax
  MOV    dword [rbp+r15],eax
; CurrentChar = Char
  PUSH   qword [rsp+56]
  POP    rax
  MOV    qword [rsp+48],rax
; EndIf
_EndIf36:
; Next  
_NextContinue34:
  INC    qword [rsp+40]
  JNO   _For33
_Next34:
; 
; 
; For Char = 'A' To 'Z'
  MOV    qword [rsp+56],65
  JMP   _ForSkipDebug37
_For37:
_ForSkipDebug37:
  MOV    rax,90
  CMP    rax,qword [rsp+56]
  JL    _Next38
; ASMKeywordsHT(Char+('a'-'A')) = ASMKeywordsHT(Char)
  MOV    r15,qword [rsp+56]
  MOV    rbp,qword [a_ASMKeywordsHT]
  SAL    r15,2
  MOVSXD rax,dword [rbp+r15]
  PUSH   rax
  MOV    r15,qword [rsp+64]
  ADD    r15,32
  SAL    r15,2
  POP    rax
  MOV    dword [rbp+r15],eax
; Next Char
_NextContinue38:
  INC    qword [rsp+56]
  JNO   _For37
_Next38:
; 
; EndProcedure
_EndProcedureZero11:
  XOR    rax,rax
_EndProcedure11:
  ADD    rsp,64
  POP    r14
  POP    r15
  POP    rbp
  RET
; Procedure ToAscii(String$)
_Procedure2:
  MOV    qword [rsp+8],rcx
  PUSH   r15
  PS2=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS2+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; Static *Buffer, BufferLength
; 
; If BufferLength > 1000000 
  MOV    r15,qword [so_ToAscii.v_BufferLength]
  CMP    r15,1000000
  JLE   _EndIf4
; FreeMemory(*Buffer)
  PUSH   qword [so_ToAscii.p_Buffer]
  POP    rcx
  CALL   PB_FreeMemory
; BufferLength = 0
  MOV    qword [so_ToAscii.v_BufferLength],0
; EndIf
_EndIf4:
; 
; Length = Len(String$) + 1
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_Len
  MOV    r15,rax
  INC    r15
  MOV    qword [rsp+48],r15
; 
; 
; If BufferLength
  CMP    qword [so_ToAscii.v_BufferLength],0
  JE    _EndIf6
; If BufferLength < Length
  MOV    r15,qword [so_ToAscii.v_BufferLength]
  CMP    r15,qword [rsp+48]
  JGE   _EndIf8
; *Buffer = ReAllocateMemory(*Buffer, Length, #PB_Memory_NoClear)
  PUSH   qword 1
  PUSH   qword [rsp+56]
  PUSH   qword [so_ToAscii.p_Buffer]
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_ReAllocateMemory2
  MOV    qword [so_ToAscii.p_Buffer],rax
; EndIf
_EndIf8:
; Else
  JMP   _EndIf5
_EndIf6:
; *Buffer = AllocateMemory(Length, #PB_Memory_NoClear)
  PUSH   qword 1
  PUSH   qword [rsp+56]
  POP    rcx
  POP    rdx
  CALL   PB_AllocateMemory2
  MOV    qword [so_ToAscii.p_Buffer],rax
; EndIf
_EndIf5:
; 
; BufferLength = Length
  PUSH   qword [rsp+48]
  POP    rax
  MOV    qword [so_ToAscii.v_BufferLength],rax
; 
; PokeS(*Buffer, String$, -1, #PB_Ascii)
  PUSH   qword 24
  PUSH   qword -1
  PUSH   qword [rsp+56]
  PUSH   qword [so_ToAscii.p_Buffer]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  CALL   PB_PokeS3
; ProcedureReturn *Buffer
  MOV    rax,qword [so_ToAscii.p_Buffer]
  JMP   _EndProcedure3
; EndProcedure
_EndProcedureZero3:
  XOR    rax,rax
_EndProcedure3:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,64
  POP    r15
  RET
; Procedure IsASMKeyword(Word$)
_Procedure18:
  MOV    qword [rsp+8],rcx
  PUSH   rbp
  PUSH   r15
  PS18=96
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS18+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; 
; Word$ = UCase(Word$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+64]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+48]
  POP    rdx
  CALL   SYS_AllocateString4
; k = ASMKeywordsHT(Asc(Word$))  
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_Asc
  MOV    r15,rax
  MOV    rbp,qword [a_ASMKeywordsHT]
  SAL    r15,2
  MOVSXD rax,dword [rbp+r15]
  PUSH   rax
  POP    rax
  MOV    qword [rsp+48],rax
; If k
  CMP    qword [rsp+48],0
  JE    _EndIf63
; While Quit = 0 And k <= NbASMKeywords
_While64:
  MOV    r15,qword [rsp+56]
  AND    r15,r15
  JNE    No4
  MOV    r15,qword [rsp+48]
  MOVSXD rax,dword [v_NbASMKeywords]
  CMP    r15,rax
  JG     No4
Ok4:
  MOV    rax,1
  JMP    End4
No4:
  XOR    rax,rax
End4:
  AND    rax,rax
  JE    _Wend64
; 
; If ASMKeywords(k) <= Word$
  MOV    r15,qword [rsp+48]
  MOV    rbp,qword [a_ASMKeywords]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  MOV    rcx,qword [rsp+48]
  POP    rdx
  CALL   SYS_StringSuperior
  OR     rax,rax
  JNE   _EndIf66
; If ASMKeywords(k) = Word$
  MOV    r15,qword [rsp+48]
  MOV    rbp,qword [a_ASMKeywords]
  SAL    r15,3
  PUSH   qword [rbp+r15]
  MOV    rcx,qword [rsp+48]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf68
; ASMKeyword$ = ASMKeywords(k)
  MOV    r15,qword [rsp+48]
  MOV    rbp,qword [a_ASMKeywords]
  SAL    r15,3
  MOV    rcx,qword [rbp+r15]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[v_ASMKeyword$]
  POP    rdx
  CALL   SYS_AllocateString4
; Result = k
  PUSH   qword [rsp+48]
  POP    rax
  MOV    qword [rsp+64],rax
; Quit = 1
  MOV    qword [rsp+56],1
; EndIf
_EndIf68:
; Else
  JMP   _EndIf65
_EndIf66:
; Quit = 1
  MOV    qword [rsp+56],1
; EndIf
_EndIf65:
; 
; k+1
  MOV    r15,qword [rsp+48]
  INC    r15
  MOV    qword [rsp+48],r15
; Wend
  JMP   _While64
_Wend64:
; EndIf
_EndIf63:
; 
; ProcedureReturn Result
  MOV    rax,qword [rsp+64]
  JMP   _EndProcedure19
; EndProcedure
_EndProcedureZero19:
  XOR    rax,rax
_EndProcedure19:
  PUSH   rax
  MOV    rcx,qword [rsp+48]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,72
  POP    r15
  POP    rbp
  RET
; Procedure IsDecNumber(*string.BYTE, length)
_Procedure28:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  PUSH   rbp
  PUSH   r15
  PS28=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
; If length < 0 Or ByteUcase(*string\b) = 'E' 
  MOV    r15,qword [rsp+PS28+8]
  AND    r15,r15
  JL     Ok19
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  rax,byte [rbp]
  PUSH   rax
  POP    rcx
  CALL  _Procedure8
  MOV    r15,rax
  CMP    r15,69
  JE     Ok19
  JMP    No19
Ok19:
  MOV    rax,1
  JMP    End19
No19:
  XOR    rax,rax
End19:
  AND    rax,rax
  JE    _EndIf114
; ProcedureReturn 0
  XOR    rax,rax
  JMP   _EndProcedure29
; EndIf
_EndIf114:
; 
; *bufferend = *string + length
  MOV    r15,qword [rsp+PS28+0]
  ADD    r15,qword [rsp+PS28+8]
  MOV    qword [rsp+40],r15
; While *string < *bufferend
_While115:
  MOV    r15,qword [rsp+PS28+0]
  CMP    r15,qword [rsp+40]
  JGE   _Wend115
; If (*string\b < 48 Or *string\b > 57) And *string\b <> 'e' And *string\b <> 'E' And *string\b <> '-' And *string\b <> '+' 
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  r15,byte [rbp]
  CMP    r15,48
  JL     Ok20
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  r15,byte [rbp]
  CMP    r15,57
  JG     Ok20
  JMP    No20
Ok20:
  MOV    rax,1
  JMP    End20
No20:
  XOR    rax,rax
End20:
  AND    rax,rax
  JE     No21
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  r15,byte [rbp]
  CMP    r15,101
  JE     No21
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  r15,byte [rbp]
  CMP    r15,69
  JE     No21
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  r15,byte [rbp]
  CMP    r15,45
  JE     No21
  MOV    rbp,qword [rsp+PS28+0]
  MOVSX  r15,byte [rbp]
  CMP    r15,43
  JE     No21
Ok21:
  MOV    rax,1
  JMP    End21
No21:
  XOR    rax,rax
End21:
  AND    rax,rax
  JE    _EndIf117
; ProcedureReturn 0
  XOR    rax,rax
  JMP   _EndProcedure29
; EndIf
_EndIf117:
; *string + 1
  MOV    r15,qword [rsp+PS28+0]
  INC    r15
  MOV    qword [rsp+PS28+0],r15
; Wend
  JMP   _While115
_Wend115:
; ProcedureReturn 1
  MOV    rax,1
  JMP   _EndProcedure29
; EndProcedure
_EndProcedureZero29:
  XOR    rax,rax
_EndProcedure29:
  ADD    rsp,56
  POP    r15
  POP    rbp
  RET
; Procedure CopyMemoryCheck(*Source.HilightPTR, *Target.HilightPTR, Length)
_Procedure6:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  PUSH   rbp
  PUSH   r15
  PS6=64
  SUB    rsp,40
; 
; 
; While Length >= SizeOf(Integer) 
_While10:
  MOV    r15,qword [rsp+PS6+16]
  CMP    r15,8
  JL    _Wend10
; If *Source\i <> *Target\i
  MOV    rbp,qword [rsp+PS6+0]
  MOV    r15,qword [rbp]
  MOV    rbp,qword [rsp+PS6+8]
  CMP    r15,qword [rbp]
  JE    _EndIf12
; CopyMemory(*Source, *Target, Length)
  PUSH   qword [rsp+PS6+16]
  PUSH   qword [rsp+PS6+16]
  PUSH   qword [rsp+PS6+16]
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_CopyMemory
; ProcedureReturn #True
  MOV    rax,1
  JMP   _EndProcedure7
; Else
  JMP   _EndIf11
_EndIf12:
; *Source + SizeOf(Integer)    
  MOV    r15,qword [rsp+PS6+0]
  ADD    r15,8
  MOV    qword [rsp+PS6+0],r15
; *Target + SizeOf(Integer)
  MOV    r15,qword [rsp+PS6+8]
  ADD    r15,8
  MOV    qword [rsp+PS6+8],r15
; Length - SizeOf(Integer)
  MOV    r15,qword [rsp+PS6+16]
  ADD    r15,-8
  MOV    qword [rsp+PS6+16],r15
; EndIf
_EndIf11:
; Wend
  JMP   _While10
_Wend10:
; 
; 
; While Length > 0
_While14:
  MOV    r15,qword [rsp+PS6+16]
  AND    r15,r15
  JLE   _Wend14
; If *Source\b <> *Target\b
  MOV    rbp,qword [rsp+PS6+0]
  MOVSX  r15,byte [rbp]
  MOV    rbp,qword [rsp+PS6+8]
  CMP    r15b,byte [rbp]
  JE    _EndIf16
; CopyMemory(*Source, *Target, Length)
  PUSH   qword [rsp+PS6+16]
  PUSH   qword [rsp+PS6+16]
  PUSH   qword [rsp+PS6+16]
  POP    rcx
  POP    rdx
  POP    r8
  CALL   PB_CopyMemory
; ProcedureReturn #True
  MOV    rax,1
  JMP   _EndProcedure7
; Else
  JMP   _EndIf15
_EndIf16:
; *Source + 1   
  MOV    r15,qword [rsp+PS6+0]
  INC    r15
  MOV    qword [rsp+PS6+0],r15
; *Target + 1
  MOV    r15,qword [rsp+PS6+8]
  INC    r15
  MOV    qword [rsp+PS6+8],r15
; Length - 1
  MOV    r15,qword [rsp+PS6+16]
  DEC    r15
  MOV    qword [rsp+PS6+16],r15
; EndIf
_EndIf15:
; Wend
  JMP   _While14
_Wend14:
; 
; 
; ProcedureReturn #False
  XOR    rax,rax
  JMP   _EndProcedure7
; EndProcedure
_EndProcedureZero7:
  XOR    rax,rax
_EndProcedure7:
  ADD    rsp,40
  POP    r15
  POP    rbp
  RET
; Procedure InitSyntaxHilightning()  
_Procedure12:
  PUSH   rbp
  PUSH   r15
  PS12=96
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
; Static APIFunctionsRead
; 
; NbBasicFunctions = 0
  MOV    qword [v_NbBasicFunctions],0
; Global Dim BasicFunctions.FunctionEntry(0)
  SUB    rsp,24
  MOV    rdx,1
  LEA    rax,[a_BasicFunctions]
  PUSH   rax
  LEA    r9,[s_functionentry]
  MOV    r8,7
  MOV    rcx,280
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_BasicFunctions],rax
; 
; 
; 
; CompilerIf Defined(PUREBASIC_IDE, #PB_Constant) 
; 
; 
; 
; 
; For k=1 To NbBasicFunctions
  MOV    qword [rsp+40],1
  JMP   _ForSkipDebug39
_For39:
_ForSkipDebug39:
  MOV    rax,qword [v_NbBasicFunctions]
  CMP    rax,qword [rsp+40]
  JL    _Next40
; BasicFunctionMap(UCase(BasicFunctions(k-1)\Name$)) = k
  PUSH   qword [rsp+40]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  MOV    r15,qword [rsp+64]
  DEC    r15
  MOV    rbp,qword [a_BasicFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  PUSH   qword [rbp]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,32
  MOV    rcx,[rsp]
  MOV    qword [PB_StringBasePosition],rcx
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rdx
  MOV    rcx,qword [m_BasicFunctionMap]
  SUB    rsp,40
  CALL   PB_CreateMapElement
  MOV    rbp,rax
  ADD    rsp,40
  POP    rax
  MOV    dword [rbp],eax
; Next
_NextContinue40:
  INC    qword [rsp+40]
  JNO   _For39
_Next40:
; 
; 
; 
; 
; If APIFunctionsRead = 0  
  MOV    r15,qword [so_InitSyntaxHilightning.v_APIFunctionsRead]
  AND    r15,r15
  JNE   _EndIf42
; APIFunctionsRead = 1
  MOV    qword [so_InitSyntaxHilightning.v_APIFunctionsRead],1
; 
; NbAPIFunctions = 0
  MOV    qword [v_NbApiFunctions],0
; Global Dim APIFunctions.FunctionEntry(0)
  SUB    rsp,24
  MOV    rdx,1
  LEA    rax,[a_APIFunctions]
  PUSH   rax
  LEA    r9,[s_functionentry]
  MOV    r8,7
  MOV    rcx,280
  SUB    rsp,32
  CALL   SYS_AllocateArray
  ADD    rsp,64
  MOV    qword [a_APIFunctions],rax
; 
; 
; 
; CompilerIf Defined(PUREBASIC_DEBUGGER, #PB_Constant)         
; 
; 
; 
; CurrentChar = 0
  MOV    qword [rsp+48],0
; For k=1 To NbAPIFunctions
  MOV    qword [rsp+40],1
  JMP   _ForSkipDebug43
_For43:
_ForSkipDebug43:
  MOV    rax,qword [v_NbApiFunctions]
  CMP    rax,qword [rsp+40]
  JL    _Next44
; If APIFunctions(k-1)\Name$
  MOV    r15,qword [rsp+40]
  DEC    r15
  MOV    rbp,qword [a_APIFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  MOV    rcx,qword [rbp]
  XOR    rdx,rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JNE   _EndIf46
; Char = ByteUcase(PeekB(APIFunctions(k-1)\Ascii))
  MOV    r15,qword [rsp+40]
  DEC    r15
  MOV    rbp,qword [a_APIFunctions]
  IMUL   r15,280
  ADD    rbp,r15
  PUSH   qword [rbp+16]
  POP    rcx
  CALL   PB_PeekB
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  CALL  _Procedure8
  MOV    qword [rsp+56],rax
; If Char <> CurrentChar
  MOV    r15,qword [rsp+56]
  CMP    r15,qword [rsp+48]
  JE    _EndIf48
; APIFunctionsHT(Char) = k
  PUSH   qword [rsp+40]
  MOV    r15,qword [rsp+64]
  MOV    rbp,qword [a_APIFunctionsHT]
  SAL    r15,2
  POP    rax
  MOV    dword [rbp+r15],eax
; CurrentChar = Char
  PUSH   qword [rsp+56]
  POP    rax
  MOV    qword [rsp+48],rax
; EndIf
_EndIf48:
; EndIf
_EndIf46:
; Next
_NextContinue44:
  INC    qword [rsp+40]
  JNO   _For43
_Next44:
; 
; EndIf
_EndIf42:
; 
; 
; 
; IsHilightningReady = 1
  MOV    qword [rsp+64],1
; 
; EndProcedure
_EndProcedureZero13:
  XOR    rax,rax
_EndProcedure13:
  ADD    rsp,72
  POP    r15
  POP    rbp
  RET
; 
section '.data' data readable writeable
; 
_PB_DataSection:
PB_OpenGLSubsystem: db 0
pb_public PB_DEBUGGER_LineNumber
  dd     -1
pb_public PB_DEBUGGER_IncludedFiles
  dd     0
pb_public PB_DEBUGGER_FileName
  db     0
pb_public PB_Compiler_Unicode
  dd     1
pb_public PB_Compiler_Thread
  dd     0
pb_public PB_Compiler_Purifier
  dd     0
pb_public PB_Compiler_Debugger
  dd     0
pb_public PB_Compiler_DPIAware
  dd     0
PB_ExecutableType: dd 0
pb_align 8
public _SYS_StaticStringStart
_SYS_StaticStringStart:
_S1: dw 0
_S5: dw 36,0
_S7: dw 80,0
_S4: dw 69,120,116,101,110,100,115,0
_S12: dw 46,112,45,117,116,102,56,0
_S6: dw 65,66,67,85,87,76,83,70,68,81,73,0
_S3: dw 73,110,116,101,114,102,97,99,101,0
_S2: dw 83,116,114,117,99,116,117,114,101,0
_S11: dw 46,112,45,118,97,114,105,97,110,116,0
_S10: dw 46,112,45,98,115,116,114,0
_S8: dw 46,112,45,97,115,99,105,105,0
_S9: dw 46,112,45,117,110,105,99,111,100,101,0
pb_public PB_NullString
  dw     0
public _SYS_StaticStringEnd
_SYS_StaticStringEnd:
pb_align 8
pb_align 8
pb_align 8
s_s:
  dq     0
  dq     -1
s_functionentry:
  dq     0
  dq     8
  dq     -1
pb_align 8
; 
section '.bss' readable writeable
_PB_BSSSection:
pb_bssalign 8
; 
I_BSSStart:
_PB_MemoryBase:
PB_MemoryBase: rq 1
_PB_Instance:
PB_Instance: rq 1
PB_ExitCode: rq 1
; 
pb_bssalign 8
v_ConstantListSize rq 1
p_PureKeywordColor rq 1
p_BadEscapeColor rq 1
p_ActiveSource rq 1
p_LabelColor rq 1
v_KnownConstant$ rq 1
p_NumberColor rq 1
v_UserCallback rq 1
p_KeywordExtends rq 1
p_CursorColor rq 1
p_StringColor rq 1
PB_DataPointer rq 1
v_ASMKeyword$ rq 1
p_ConstantColor rq 1
p_CurrentLineColor rq 1
v_NbBasicFunctions rq 1
p_LineNumberBackColor rq 1
p_PointerColor rq 1
v_CustomKeyword$ rq 1
p_BackgroundColor rq 1
p_ModuleColor rq 1
v_EnableCaseCorrection rq 1
p_SelectionColor rq 1
p_ASMKeywordColor rq 1
v_EnableColoring rq 1
p_LineNumberColor rq 1
p_CustomKeywordColor rq 1
p_NormalTextColor rq 1
v_SourceStringFormat rq 1
v_NbApiFunctions rq 1
p_KeywordInterface rq 1
v_BasicKeyword$ rq 1
p_SeparatorColor rq 1
v_NbCustomKeywords rq 1
p_StructureColor rq 1
p_OperatorColor rq 1
p_KeywordStructure rq 1
v_EnableKeywordBolding rq 1
p_CommentColor rq 1
p_MarkerColor rq 1
p_BasicKeywordColor rq 1
v_NbASMKeywords rd 1
pb_bssalign 8
v_DummySource rb 16
pb_bssalign 8
so_ToAscii.p_Buffer rq 1
so_ToAscii.v_BufferLength rq 1
so_InitSyntaxHilightning.v_APIFunctionsRead rq 1
pb_bssalign 8
pb_bssalign 8
a_ValidCharacters:
  rq     1
  rq     1
a_BasicKeywordsHT:
  rq     1
  rq     1
a_BasicKeywords:
  rq     1
  rq     1
a_BasicKeywordsReal:
  rq     1
  rq     1
a_BasicKeywordsEndKeywords:
  rq     1
  rq     1
a_BasicKeywordsSpaces:
  rq     1
  rq     1
a_CustomKeywords:
  rq     1
  rq     1
a_CustomKeywordsHT:
  rq     1
  rq     1
a_ConstantList:
  rq     1
  rq     1
a_ConstantHT:
  rq     1
  rq     1
  rq     1
a_ASMKeywordsHT:
  rq     1
  rq     1
a_APIFunctionsHT:
  rq     1
  rq     1
a_ASMKeywords:
  rq     1
  rq     1
a_BasicFunctions:
  rq     1
  rq     1
a_APIFunctions:
  rq     1
  rq     1
m_BasicFunctionMap rq 1
I_BSSEnd:
section '.data' data readable writeable
l_basickeywords:
PB_DataSectionStart:
  dw     65,108,105,103,110,0,0,32,0
  dw     65,110,100,0,0,32,0
  dw     65,114,114,97,121,0,0,32,0
  dw     65,115,0,0,32,0
  dw     66,114,101,97,107,0,0,0
  dw     67,97,108,108,68,101,98,117,103,103,101,114,0,0,0
  dw     67,97,115,101,0,0,32,0
  dw     67,111,109,112,105,108,101,114,67,97,115,101,0,0,32,0
  dw     67,111,109,112,105,108,101,114,68,101,102,97,117,108,116,0,0,0
  dw     67,111,109,112,105,108,101,114,69,108,115,101,0,0,0
  dw     67,111,109,112,105,108,101,114,69,108,115,101,73,102,0,0,32,0
  dw     67,111,109,112,105,108,101,114,69,110,100,73,102,0,0,0
  dw     67,111,109,112,105,108,101,114,69,110,100,83,101,108,101,99,116,0,0,0
  dw     67,111,109,112,105,108,101,114,69,114,114,111,114,0,0,32,0
  dw     67,111,109,112,105,108,101,114,73,102,0,67,111,109,112,105,108,101,114,69,110,100,73,102,0,32,0
  dw     67,111,109,112,105,108,101,114,83,101,108,101,99,116,0,67,111,109,112,105,108,101,114,69,110,100,83,101,108,101,99,116,0,32,0
  dw     67,111,109,112,105,108,101,114,87,97,114,110,105,110,103,0,0,32,0
  dw     67,111,110,116,105,110,117,101,0,0,0
  dw     68,97,116,97,0,0,32,0
  dw     68,97,116,97,83,101,99,116,105,111,110,0,69,110,100,68,97,116,97,83,101,99,116,105,111,110,0,0
  dw     68,101,98,117,103,0,0,32,0
  dw     68,101,98,117,103,76,101,118,101,108,0,0,32,0
  dw     68,101,99,108,97,114,101,0,0,0
  dw     68,101,99,108,97,114,101,67,0,0,0
  dw     68,101,99,108,97,114,101,67,68,76,76,0,0,0
  dw     68,101,99,108,97,114,101,68,76,76,0,0,0
  dw     68,101,99,108,97,114,101,77,111,100,117,108,101,0,69,110,100,68,101,99,108,97,114,101,77,111,100,117,108,101,0,32,0
  dw     68,101,102,97,117,108,116,0,0,0
  dw     68,101,102,105,110,101,0,0,32,0
  dw     68,105,109,0,0,32,0
  dw     68,105,115,97,98,108,101,65,83,77,0,0,0
  dw     68,105,115,97,98,108,101,68,101,98,117,103,103,101,114,0,0,0
  dw     68,105,115,97,98,108,101,69,120,112,108,105,99,105,116,0,0,0
  dw     69,108,115,101,0,0,0
  dw     69,108,115,101,73,102,0,0,32,0
  dw     69,110,97,98,108,101,65,83,77,0,0,0
  dw     69,110,97,98,108,101,68,101,98,117,103,103,101,114,0,0,0
  dw     69,110,97,98,108,101,69,120,112,108,105,99,105,116,0,0,0
  dw     69,110,100,0,0,0
  dw     69,110,100,68,97,116,97,83,101,99,116,105,111,110,0,0,0
  dw     69,110,100,68,101,99,108,97,114,101,77,111,100,117,108,101,0,0,0
  dw     69,110,100,69,110,117,109,101,114,97,116,105,111,110,0,0,0
  dw     69,110,100,73,102,0,0,0
  dw     69,110,100,73,109,112,111,114,116,0,0,0
  dw     69,110,100,73,110,116,101,114,102,97,99,101,0,0,0
  dw     69,110,100,77,97,99,114,111,0,0,0
  dw     69,110,100,77,111,100,117,108,101,0,0,0
  dw     69,110,100,80,114,111,99,101,100,117,114,101,0,0,0
  dw     69,110,100,83,101,108,101,99,116,0,0,0
  dw     69,110,100,83,116,114,117,99,116,117,114,101,0,0,0
  dw     69,110,100,83,116,114,117,99,116,117,114,101,85,110,105,111,110,0,0,0
  dw     69,110,100,87,105,116,104,0,0,0
  dw     69,110,117,109,101,114,97,116,105,111,110,0,69,110,100,69,110,117,109,101,114,97,116,105,111,110,0,32,0
  dw     69,110,117,109,101,114,97,116,105,111,110,66,105,110,97,114,121,0,69,110,100,69,110,117,109,101,114,97,116,105,111,110,0,32,0
  dw     69,120,116,101,110,100,115,0,0,32,0
  dw     70,97,107,101,82,101,116,117,114,110,0,0,0
  dw     70,111,114,0,78,101,120,116,0,32,0
  dw     70,111,114,69,97,99,104,0,78,101,120,116,0,32,0
  dw     70,111,114,69,118,101,114,0,0,0
  dw     71,108,111,98,97,108,0,0,32,0
  dw     71,111,115,117,98,0,0,32,0
  dw     71,111,116,111,0,0,32,0
  dw     73,102,0,69,110,100,73,102,0,32,0
  dw     73,109,112,111,114,116,0,69,110,100,73,109,112,111,114,116,0,32,0
  dw     73,109,112,111,114,116,67,0,69,110,100,73,109,112,111,114,116,0,32,0
  dw     73,110,99,108,117,100,101,66,105,110,97,114,121,0,0,32,0
  dw     73,110,99,108,117,100,101,70,105,108,101,0,0,32,0
  dw     73,110,99,108,117,100,101,80,97,116,104,0,0,32,0
  dw     73,110,116,101,114,102,97,99,101,0,69,110,100,73,110,116,101,114,102,97,99,101,0,32,0
  dw     76,105,115,116,0,0,32,0
  dw     77,97,99,114,111,0,69,110,100,77,97,99,114,111,0,32,0
  dw     77,97,99,114,111,69,120,112,97,110,100,101,100,67,111,117,110,116,0,0,0
  dw     77,97,112,0,0,32,0
  dw     77,111,100,117,108,101,0,69,110,100,77,111,100,117,108,101,0,32,0
  dw     78,101,119,76,105,115,116,0,0,32,0
  dw     78,101,119,77,97,112,0,0,32,0
  dw     78,101,120,116,0,0,0
  dw     78,111,116,0,0,32,0
  dw     79,114,0,0,32,0
  dw     80,114,111,99,101,100,117,114,101,0,69,110,100,80,114,111,99,101,100,117,114,101,0,32,0
  dw     80,114,111,99,101,100,117,114,101,67,0,69,110,100,80,114,111,99,101,100,117,114,101,0,32,0
  dw     80,114,111,99,101,100,117,114,101,67,68,76,76,0,69,110,100,80,114,111,99,101,100,117,114,101,0,32,0
  dw     80,114,111,99,101,100,117,114,101,68,76,76,0,69,110,100,80,114,111,99,101,100,117,114,101,0,32,0
  dw     80,114,111,99,101,100,117,114,101,82,101,116,117,114,110,0,0,32,0
  dw     80,114,111,116,101,99,116,101,100,0,0,32,0
  dw     80,114,111,116,111,116,121,112,101,0,0,32,0
  dw     80,114,111,116,111,116,121,112,101,67,0,0,32,0
  dw     82,101,97,100,0,0,32,0
  dw     82,101,68,105,109,0,0,32,0
  dw     82,101,112,101,97,116,0,85,110,116,105,108,32,0,0
  dw     82,101,115,116,111,114,101,0,0,32,0
  dw     82,101,116,117,114,110,0,0,0
  dw     82,117,110,116,105,109,101,0,0,0
  dw     83,101,108,101,99,116,0,69,110,100,83,101,108,101,99,116,0,32,0
  dw     83,104,97,114,101,100,0,0,32,0
  dw     83,116,97,116,105,99,0,0,32,0
  dw     83,116,101,112,0,0,32,0
  dw     83,116,114,117,99,116,117,114,101,0,69,110,100,83,116,114,117,99,116,117,114,101,0,32,0
  dw     83,116,114,117,99,116,117,114,101,85,110,105,111,110,0,69,110,100,83,116,114,117,99,116,117,114,101,85,110,105,111,110,0,0
  dw     83,119,97,112,0,0,32,0
  dw     84,104,114,101,97,100,101,100,0,0,32,0
  dw     84,111,0,0,32,0
  dw     85,110,100,101,102,105,110,101,77,97,99,114,111,0,0,32,0
  dw     85,110,116,105,108,0,0,32,0
  dw     85,110,117,115,101,77,111,100,117,108,101,0,0,32,0
  dw     85,115,101,77,111,100,117,108,101,0,0,32,0
  dw     87,101,110,100,0,0,0
  dw     87,104,105,108,101,0,87,101,110,100,0,32,0
  dw     87,105,116,104,0,69,110,100,87,105,116,104,0,32,0
  dw     88,73,110,99,108,117,100,101,70,105,108,101,0,0,32,0
  dw     88,79,114,0,0,32,0
l_asmkeywords:
  dd     393
  dw     65,65,65,0
  dw     65,65,68,0
  dw     65,65,77,0
  dw     65,65,83,0
  dw     65,68,67,0
  dw     65,68,68,0
  dw     65,78,68,0
  dw     65,82,80,76,0
  dw     66,79,85,78,68,0
  dw     66,83,70,0
  dw     66,83,82,0
  dw     66,83,87,65,80,0
  dw     66,84,0
  dw     66,84,67,0
  dw     66,84,82,0
  dw     66,84,83,0
  dw     67,65,76,76,0
  dw     67,66,87,0
  dw     67,68,81,0
  dw     67,76,67,0
  dw     67,76,68,0
  dw     67,76,73,0
  dw     67,76,84,83,0
  dw     67,77,67,0
  dw     67,77,79,86,65,0
  dw     67,77,79,86,65,69,0
  dw     67,77,79,86,66,0
  dw     67,77,79,86,66,69,0
  dw     67,77,79,86,67,0
  dw     67,77,79,86,69,0
  dw     67,77,79,86,71,0
  dw     67,77,79,86,71,69,0
  dw     67,77,79,86,76,0
  dw     67,77,79,86,76,69,0
  dw     67,77,79,86,78,65,0
  dw     67,77,79,86,78,65,69,0
  dw     67,77,79,86,78,66,0
  dw     67,77,79,86,78,66,69,0
  dw     67,77,79,86,78,67,0
  dw     67,77,79,86,78,69,0
  dw     67,77,79,86,78,71,0
  dw     67,77,79,86,78,71,69,0
  dw     67,77,79,86,78,76,0
  dw     67,77,79,86,78,76,69,0
  dw     67,77,79,86,78,79,0
  dw     67,77,79,86,78,80,0
  dw     67,77,79,86,78,83,0
  dw     67,77,79,86,78,90,0
  dw     67,77,79,86,79,0
  dw     67,77,79,86,80,0
  dw     67,77,79,86,80,69,0
  dw     67,77,79,86,80,79,0
  dw     67,77,79,86,83,0
  dw     67,77,79,86,90,0
  dw     67,77,80,0
  dw     67,77,80,83,0
  dw     67,77,80,83,66,0
  dw     67,77,80,83,68,0
  dw     67,77,80,83,87,0
  dw     67,77,80,88,67,72,71,0
  dw     67,77,80,88,67,72,71,56,66,0
  dw     67,87,68,0
  dw     67,87,68,69,0
  dw     68,65,65,0
  dw     68,65,83,0
  dw     68,66,0
  dw     68,68,0
  dw     68,69,67,0
  dw     68,73,86,0
  dw     68,87,0
  dw     69,77,77,83,0
  dw     69,78,84,69,82,0
  dw     69,83,67,0
  dw     70,50,88,77,49,0
  dw     70,65,66,83,0
  dw     70,65,68,68,0
  dw     70,65,68,68,80,0
  dw     70,66,76,68,0
  dw     70,66,83,84,80,0
  dw     70,67,72,83,0
  dw     70,67,76,69,88,0
  dw     70,67,77,79,86,66,0
  dw     70,67,77,79,86,66,69,0
  dw     70,67,77,79,86,69,0
  dw     70,67,77,79,86,78,66,0
  dw     70,67,77,79,86,78,66,69,0
  dw     70,67,77,79,86,78,69,0
  dw     70,67,77,79,86,78,85,0
  dw     70,67,77,79,86,85,0
  dw     70,67,79,77,0
  dw     70,67,79,77,73,0
  dw     70,67,79,77,73,80,0
  dw     70,67,79,77,80,0
  dw     70,67,79,77,80,80,0
  dw     70,67,79,83,0
  dw     70,68,69,67,83,84,80,0
  dw     70,68,73,86,0
  dw     70,68,73,86,80,0
  dw     70,68,73,86,82,0
  dw     70,68,73,86,82,80,0
  dw     70,70,82,69,69,0
  dw     70,73,65,68,68,0
  dw     70,73,67,79,77,0
  dw     70,73,67,79,77,80,0
  dw     70,73,68,73,86,0
  dw     70,73,68,73,86,82,0
  dw     70,73,76,68,0
  dw     70,73,77,85,76,0
  dw     70,73,78,67,83,84,80,0
  dw     70,73,78,73,84,0
  dw     70,73,83,84,0
  dw     70,73,83,84,80,0
  dw     70,73,83,85,66,0
  dw     70,73,83,85,66,82,0
  dw     70,76,68,0
  dw     70,76,68,49,0
  dw     70,76,68,67,87,0
  dw     70,76,68,69,78,86,0
  dw     70,76,68,76,50,69,0
  dw     70,76,68,76,50,84,0
  dw     70,76,68,76,71,50,0
  dw     70,76,68,76,78,50,0
  dw     70,76,68,80,73,0
  dw     70,76,68,90,0
  dw     70,77,85,76,0
  dw     70,77,85,76,80,0
  dw     70,78,67,76,69,88,0
  dw     70,78,73,78,73,84,0
  dw     70,78,79,80,0
  dw     70,78,83,65,86,69,0
  dw     70,78,83,84,67,87,0
  dw     70,78,83,84,69,78,86,0
  dw     70,78,83,84,83,87,0
  dw     70,80,65,84,65,78,0
  dw     70,80,82,69,77,0
  dw     70,80,82,69,77,49,0
  dw     70,80,84,65,78,0
  dw     70,82,78,68,73,78,84,0
  dw     70,82,83,84,79,82,0
  dw     70,83,65,86,69,0
  dw     70,83,67,65,76,69,0
  dw     70,83,69,84,80,77,0
  dw     70,83,73,78,0
  dw     70,83,73,78,67,79,83,0
  dw     70,83,81,82,84,0
  dw     70,83,84,0
  dw     70,83,84,67,87,0
  dw     70,83,84,69,78,86,0
  dw     70,83,84,80,0
  dw     70,83,84,83,87,0
  dw     70,83,85,66,0
  dw     70,83,85,66,80,0
  dw     70,83,85,66,82,0
  dw     70,83,85,66,82,80,0
  dw     70,84,83,84,0
  dw     70,85,67,79,77,0
  dw     70,85,67,79,77,73,0
  dw     70,85,67,79,77,73,80,0
  dw     70,85,67,79,77,80,0
  dw     70,85,67,79,77,80,80,0
  dw     70,87,65,73,84,0
  dw     70,88,65,77,0
  dw     70,88,67,72,0
  dw     70,88,84,82,65,67,84,0
  dw     70,89,76,50,88,0
  dw     70,89,76,50,88,80,49,0
  dw     72,76,84,0
  dw     73,68,73,86,0
  dw     73,77,85,76,0
  dw     73,78,0
  dw     73,78,67,0
  dw     73,78,83,0
  dw     73,78,83,66,0
  dw     73,78,83,68,0
  dw     73,78,83,87,0
  dw     73,78,84,0
  dw     73,78,84,79,0
  dw     73,78,86,68,0
  dw     73,78,86,76,80,71,0
  dw     73,82,69,84,0
  dw     73,82,69,84,68,0
  dw     74,65,0
  dw     74,65,69,0
  dw     74,66,0
  dw     74,66,69,0
  dw     74,67,0
  dw     74,67,88,90,0
  dw     74,69,0
  dw     74,69,67,88,90,0
  dw     74,71,0
  dw     74,71,69,0
  dw     74,76,0
  dw     74,76,69,0
  dw     74,77,80,0
  dw     74,78,65,0
  dw     74,78,65,69,0
  dw     74,78,66,0
  dw     74,78,66,69,0
  dw     74,78,67,0
  dw     74,78,69,0
  dw     74,78,71,0
  dw     74,78,71,69,0
  dw     74,78,76,0
  dw     74,78,76,69,0
  dw     74,78,79,0
  dw     74,78,80,0
  dw     74,78,83,0
  dw     74,78,90,0
  dw     74,79,0
  dw     74,80,0
  dw     74,80,69,0
  dw     74,80,79,0
  dw     74,83,0
  dw     74,90,0
  dw     76,65,72,70,0
  dw     76,65,82,0
  dw     76,68,83,0
  dw     76,69,65,0
  dw     76,69,65,86,69,0
  dw     76,69,83,0
  dw     76,70,83,0
  dw     76,71,68,84,0
  dw     76,71,83,0
  dw     76,73,68,84,0
  dw     76,76,68,84,0
  dw     76,77,83,87,0
  dw     76,79,67,75,0
  dw     76,79,68,83,0
  dw     76,79,68,83,66,0
  dw     76,79,68,83,68,0
  dw     76,79,68,83,87,0
  dw     76,79,79,80,0
  dw     76,79,79,80,69,0
  dw     76,79,79,80,78,69,0
  dw     76,79,79,80,78,90,0
  dw     76,79,79,80,90,0
  dw     76,83,76,0
  dw     76,83,83,0
  dw     76,84,82,0
  dw     77,79,86,0
  dw     77,79,86,68,0
  dw     77,79,86,81,0
  dw     77,79,86,83,0
  dw     77,79,86,83,66,0
  dw     77,79,86,83,68,0
  dw     77,79,86,83,87,0
  dw     77,79,86,83,88,0
  dw     77,79,86,90,88,0
  dw     77,85,76,0
  dw     78,69,71,0
  dw     78,79,80,0
  dw     78,79,84,0
  dw     79,82,0
  dw     79,85,84,0
  dw     79,85,84,83,0
  dw     79,85,84,83,66,0
  dw     79,85,84,83,68,0
  dw     79,85,84,83,87,0
  dw     80,65,67,75,83,83,68,87,0
  dw     80,65,67,75,83,83,87,66,0
  dw     80,65,67,75,85,83,87,66,0
  dw     80,65,68,68,66,0
  dw     80,65,68,68,68,0
  dw     80,65,68,68,83,66,0
  dw     80,65,68,68,83,87,0
  dw     80,65,68,68,85,83,66,0
  dw     80,65,68,68,85,83,87,0
  dw     80,65,68,68,87,0
  dw     80,65,78,68,0
  dw     80,65,78,68,78,0
  dw     80,67,77,80,69,81,66,0
  dw     80,67,77,80,69,81,68,0
  dw     80,67,77,80,69,81,87,0
  dw     80,67,77,80,71,84,66,0
  dw     80,67,77,80,71,84,68,0
  dw     80,67,77,80,71,84,87,0
  dw     80,77,65,68,68,87,68,0
  dw     80,77,85,76,72,87,0
  dw     80,79,80,0
  dw     80,79,80,65,0
  dw     80,79,80,65,68,0
  dw     80,79,80,70,0
  dw     80,79,80,70,68,0
  dw     80,79,82,0
  dw     80,83,76,76,68,0
  dw     80,83,76,76,81,0
  dw     80,83,76,76,87,0
  dw     80,83,82,65,68,0
  dw     80,83,82,65,87,0
  dw     80,83,82,76,68,0
  dw     80,83,82,76,81,0
  dw     80,83,82,76,87,0
  dw     80,83,85,66,66,0
  dw     80,83,85,66,68,0
  dw     80,83,85,66,83,66,0
  dw     80,83,85,66,83,87,0
  dw     80,83,85,66,85,83,66,0
  dw     80,83,85,66,85,83,87,0
  dw     80,83,85,66,87,0
  dw     80,85,78,80,67,75,72,66,87,0
  dw     80,85,78,80,67,75,72,68,81,0
  dw     80,85,78,80,67,75,72,87,68,0
  dw     80,85,78,80,67,75,76,66,87,0
  dw     80,85,78,80,67,75,76,68,81,0
  dw     80,85,78,80,67,75,76,87,68,0
  dw     80,85,83,72,0
  dw     80,85,83,72,65,0
  dw     80,85,83,72,65,68,0
  dw     80,85,83,72,70,0
  dw     80,85,83,72,70,68,0
  dw     80,88,79,82,0
  dw     82,67,76,0
  dw     82,67,82,0
  dw     82,68,77,83,82,0
  dw     82,68,80,77,67,0
  dw     82,68,84,83,67,0
  dw     82,69,80,0
  dw     82,69,80,69,0
  dw     82,69,80,78,69,0
  dw     82,69,80,78,90,0
  dw     82,69,80,90,0
  dw     82,69,84,0
  dw     82,69,84,70,0
  dw     82,79,76,0
  dw     82,79,82,0
  dw     82,83,77,0
  dw     83,65,72,70,0
  dw     83,65,76,0
  dw     83,65,82,0
  dw     83,66,66,0
  dw     83,67,65,83,0
  dw     83,67,65,83,66,0
  dw     83,67,65,83,68,0
  dw     83,67,65,83,87,0
  dw     83,69,84,65,0
  dw     83,69,84,65,69,0
  dw     83,69,84,66,0
  dw     83,69,84,66,69,0
  dw     83,69,84,67,0
  dw     83,69,84,69,0
  dw     83,69,84,71,0
  dw     83,69,84,71,69,0
  dw     83,69,84,76,0
  dw     83,69,84,76,69,0
  dw     83,69,84,78,65,0
  dw     83,69,84,78,65,69,0
  dw     83,69,84,78,66,0
  dw     83,69,84,78,66,69,0
  dw     83,69,84,78,67,0
  dw     83,69,84,78,69,0
  dw     83,69,84,78,71,0
  dw     83,69,84,78,71,69,0
  dw     83,69,84,78,76,0
  dw     83,69,84,78,76,69,0
  dw     83,69,84,78,79,0
  dw     83,69,84,78,80,0
  dw     83,69,84,78,83,0
  dw     83,69,84,78,90,0
  dw     83,69,84,79,0
  dw     83,69,84,80,0
  dw     83,69,84,80,69,0
  dw     83,69,84,80,79,0
  dw     83,69,84,83,0
  dw     83,69,84,90,0
  dw     83,71,68,84,0
  dw     83,72,76,0
  dw     83,72,76,68,0
  dw     83,72,82,0
  dw     83,72,82,68,0
  dw     83,73,68,84,0
  dw     83,76,68,84,0
  dw     83,77,83,87,0
  dw     83,84,67,0
  dw     83,84,68,0
  dw     83,84,73,0
  dw     83,84,79,83,0
  dw     83,84,79,83,66,0
  dw     83,84,79,83,68,0
  dw     83,84,79,83,87,0
  dw     83,84,82,0
  dw     83,85,66,0
  dw     84,69,83,84,0
  dw     85,68,50,0
  dw     86,69,82,82,0
  dw     86,69,82,87,0
  dw     87,65,73,84,0
  dw     87,66,73,78,86,68,0
  dw     87,82,77,83,82,0
  dw     88,65,68,68,0
  dw     88,67,72,71,0
  dw     88,76,65,84,0
  dw     88,76,65,84,66,0
  dw     88,79,82,0
SYS_EndDataSection:
