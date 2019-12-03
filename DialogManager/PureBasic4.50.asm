; 
; PureBasic 4.50 Alpha 1 (Windows - x86) generated code
; 
; (c) 2010 Fantaisie Software
; 
; The header must remain intact for Re-Assembly
; 
; String
; Requester
; Process
; Cipher
; Misc
; Memory
; LinkedList
; FileSystem
; Date
; File
; Object
; SimpleList
; Console
; :System
; EXPAT
; KERNEL32
; :Import
; 
format MS COFF
; 
extrn _ExitProcess@4
extrn _GetModuleHandleA@4
extrn _HeapCreate@12
extrn _HeapDestroy@4
extrn _XML_ErrorString
extrn _XML_GetCurrentLineNumber
extrn _XML_GetErrorCode
extrn _XML_Parse
extrn _XML_ParserCreate
extrn _XML_ParserFree
extrn _XML_SetEndElementHandler
extrn _XML_SetStartElementHandler
; 
extrn _PB_NewList@16
extrn _PB_AddElement@4
extrn _PB_AllocateMemory@4
extrn _PB_ClearList@4
extrn _PB_CloseConsole@0
extrn _PB_CloseFile@4
extrn _PB_CreateFile@8
extrn _PB_Delay@4
extrn _PB_DeleteElement@4
extrn _PB_DeleteFile@4
extrn _PB_FreeFiles@0
extrn _PB_FreeList@4
extrn _PB_FreeMemory@4
extrn _PB_FreeMemorys@0
extrn _PB_InitFile@0
extrn _PB_InitList@0
extrn _PB_InitMemory@0
extrn _PB_InitProcess@0
extrn _PB_InitRequester@0
extrn _PB_IsFile@4
extrn _PB_ListSize@4
extrn _PB_Lof@4
extrn _PB_MessageRequester@8
extrn _PB_NextElement@4
extrn _PB_OpenConsole@0
extrn _PB_PeekS@8
extrn _PB_PeekS3@16
extrn _PB_PrintN
extrn _PB_ProgramParameter@4
extrn _PB_ReadData@12
extrn _PB_ReadFile@8
extrn _PB_ReplaceString@16
extrn _PB_ResetList@4
extrn _PB_Space@8
extrn _PB_Str@12
extrn _PB_StringField@16
extrn _PB_UCase@8
extrn _PB_WriteString@8
extrn _PB_WriteStringN@8
extrn _memset
extrn _SYS_CopyString@0
extrn _SYS_StringEqual
extrn _SYS_AllocateString4@8
extrn SYS_FastAllocateString
extrn SYS_FastAllocateStringFree
extrn _SYS_FreeString@4
extrn _PB_StringBase
extrn PB_StringBase
extrn _SYS_InitString@0
; 
extrn _PB_StringBasePosition
public _PB_Instance
public _PB_ExecutableType
public _PB_MemoryBase
public PB_Instance
public PB_MemoryBase
public _PB_EndFunctions

macro pb_public symbol
{
  public  _#symbol
  public symbol
_#symbol:
symbol:
}

macro    pb_align value { rb (value-1) - ($-_PB_DataSection + value-1) mod value }
macro pb_bssalign value { rb (value-1) - ($-_PB_BSSSection  + value-1) mod value }
public PureBasicStart
; 
section '.code' code readable executable align 8
; 
; 
PureBasicStart:
; 
  PUSH   dword I_BSSEnd-I_BSSStart
  PUSH   dword 0
  PUSH   dword I_BSSStart
  CALL  _memset
  ADD    esp,12
  PUSH   dword 0
  CALL  _GetModuleHandleA@4
  MOV    [_PB_Instance],eax
  PUSH   dword 0
  PUSH   dword 4096
  PUSH   dword 0
  CALL  _HeapCreate@12
  MOV    [PB_MemoryBase],eax
  CALL  _SYS_InitString@0
  CALL  _PB_InitFile@0
  CALL  _PB_InitList@0
  CALL  _PB_InitMemory@0
  CALL  _PB_InitProcess@0
  CALL  _PB_InitRequester@0
; 
; === Copyright Notice ===
;
;
;                   PureBasic source code file
;
;
; This file is part of the PureBasic Software package. It may not
; be distributed or published in source code or binary form without 
; the expressed permission by Fantaisie Software. 
;
; By contributing modifications or additions to this file, you grant 
; Fantaisie Software the rights to use, modify and distribute your
; work in the PureBasic package.
;
;
; Copyright (C) 2000-2010 Fantaisie Software - all rights reserved
;
;
; 
;
; Compiles a Dialog in xml format to a PB source datasection.
;
; The reason is that in the xml definition, we can use constants from the source,
; So the xml must be transformed into a PB file so it is compiled with the source, and
; the constants are known.
;
; CommandLine: xml_file pb_file
; 
; Datasection structure:
;
; LONG: ObjectType
; LONG: ObjectID
; LONG: GadgetFlags
; LONG: minwidth  (or 0 if none)
; LONG: minheight (or 0 if none)
; LONG: 1 when either "lang" or "text" are set. 0 otherwise
; LONG: Number of extra option pairs
; String: ObjectName, LiteralText, LanguageGroup, LanguageKey
; String: OptionKey, OptionValue (pairs as much as the above number, can be none at all)
;
;   Any subitems, if object is a container
;
; LONG: -1 ; close item list (present for every element, also non-containers!)
;
; After the window objects -1 end, there are all shortcuts placed which were added for this
; window.they have this structure:
;
; LONG: ObjectType = #DIALOG_Shortcut
; LONG: Key
; LONG: ID
;
; At the end, another -1 to close the shortcut list
;
; Specal tags:
;
;  <dialoggroup>    - to group multiple dialogs in one file.. no special meaning otherwise
;  <compiler if=""> - compilerif block. pass a constant expr for the if
;  <compilerelse /> - compilerelse
;  <shortcut key="#KeyConstant" id="#IDConstant">
;
; 
; #EXIT_FAILURE = 1
; #EXIT_SUCCESS = 0
; 
; 
; Input$  = ProgramParameter()
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  CALL  _PB_ProgramParameter@4
  PUSH   dword v_Input$
  CALL  _SYS_AllocateString4@8
; Output$ = ProgramParameter()
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  CALL  _PB_ProgramParameter@4
  PUSH   dword v_Output$
  CALL  _SYS_AllocateString4@8
; 
; OpenConsole()
  CALL  _PB_OpenConsole@0
; 
; Input$  = "test.xml"
; Output$ = "test.pb"
; Input$  = "c:/purebasic/svn/v4.50/Fr34k/PureBasicIDE/dialogs/Find.xml"
  MOV    edx,_S1
  LEA    ecx,[v_Input$]
  CALL   SYS_FastAllocateStringFree
; Output$ = "c:/purebasic/svn/v4.50/Fr34k/PureBasicIDE/dialogs/Dialog_Find.pb"
  MOV    edx,_S2
  LEA    ecx,[v_Output$]
  CALL   SYS_FastAllocateStringFree
; 
; Structure ArgPair
; Name$
; Value$
; EndStructure
; 
; Structure Shortcut
; Key$
; ID$
; EndStructure
; 
; Global NewList Shortcuts.Shortcut()
  PUSH   dword [t_Shortcuts]
  CALL  _PB_FreeList@4
  PUSH   dword 7
  PUSH   dword s_shortcut
  LEA    eax,[t_Shortcuts+4]
  PUSH   eax
  PUSH   dword 8
  CALL  _PB_NewList@16
  MOV    dword [t_Shortcuts],eax
; Global Indent = 4, PreviousIndent = 2, parser
  MOV    dword [v_Indent],4
  MOV    dword [v_PreviousIndent],2
; 
; CompilerIf #PB_Compiler_OS = #PB_OS_Windows
; #NewLineSequence = Chr(34)+"+Chr(13)+Chr(10)+"+Chr(34)
; CompilerElse
; 
; return true if the key is present, and makes this key the current element, Key must be uppercase
; Procedure IsKey(List Args.ArgPair(), Key$)
macro MP0{
_Procedure0:
  PS0=12
  XOR    eax,eax
  PUSH   eax
  PUSH   eax                                                                                                                                                                                                                  
  MOV    eax,dword [esp+PS0+0]
  MOV    dword [esp+0],eax
  MOV    edx,dword [esp+PS0+4]
  LEA    ecx,[esp+4]
  CALL   SYS_FastAllocateString
; 
; ForEach Args()
  PUSH   dword [esp+0]
  CALL  _PB_ResetList@4
_ForEach1:
  PUSH   dword [esp+0]
  CALL  _PB_NextElement@4
  OR     eax,eax
  JZ    _Next1
; If Args()\Name$ = Key$
  MOV    eax,[esp+0]
  MOV    ebp,dword [eax+8]
  PUSH   dword [ebp+8]
  MOV    edx,dword [esp+8]
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf3
; ProcedureReturn #True ; found
  MOV    eax,1
  JMP   _EndProcedure1
; EndIf
_EndIf3:
; Next Args()
  JMP   _ForEach1
_Next1:
; 
; ProcedureReturn #False
  XOR    eax,eax
  JMP   _EndProcedure1
; EndProcedure
  XOR    eax,eax
_EndProcedure1:
  PUSH   dword [esp+4]
  CALL  _SYS_FreeString@4
  ADD    esp,8
  RET    8
}
; 
; Procedure Error(Message$)
macro MP2{
_Procedure2:
  PUSH   ebx
  PS2=12
  XOR    eax,eax
  PUSH   eax                                                                                                                                                                                                                  
  MOV    edx,dword [esp+PS2+0]
  LEA    ecx,[esp+0]
  CALL   SYS_FastAllocateString
; Shared Output$
; OpenConsole()
  CALL  _PB_OpenConsole@0
; PrintN(Message$) 
  PUSH   dword [esp]
  CALL   dword [_PB_PrintN]
; CloseConsole()
  CALL  _PB_CloseConsole@0
; CompilerIf #PB_Compiler_OS = #PB_OS_Windows
; MessageRequester("DialogCompiler", Message$)
  PUSH   dword [esp]
  PUSH   dword _S3
  CALL  _PB_MessageRequester@8
; CompilerEndIf
; If IsFile(1)
  PUSH   dword 1
  CALL  _PB_IsFile@4
  AND    eax,eax
  JE    _EndIf5
; CloseFile(1)
  PUSH   dword 1
  CALL  _PB_CloseFile@4
; EndIf
_EndIf5:
; DeleteFile(Output$)
  PUSH   dword [v_Output$]
  CALL  _PB_DeleteFile@4
; 
; Delay(1000)
  PUSH   dword 1000
  CALL  _PB_Delay@4
; 
; End #EXIT_FAILURE
  PUSH   dword 1
  JMP   _PB_EOP
; EndProcedure
  XOR    eax,eax
_EndProcedure3:
  PUSH   dword [esp]
  CALL  _SYS_FreeString@4
  ADD    esp,4
  POP    ebx
  RET    4
}
; 
; ProcedureC StartElementHandler(user_data, *name, *args.INTEGER)
macro MP4{
_Procedure4:
  PUSH   ebp
  PUSH   ebx
  PS4=48
  MOV    edx,9
.ClearLoop:
  SUB    esp,4
  MOV    dword [esp],0
  DEC    edx
  JNZ   .ClearLoop                                                                                                                                                 
; NewList Args.ArgPair()
  PUSH   dword [esp+0]
  CALL  _PB_FreeList@4
  PUSH   dword 7
  PUSH   dword s_argpair
  LEA    eax,[esp+8+4]
  PUSH   eax
  PUSH   dword 8
  CALL  _PB_NewList@16
  MOV    dword [esp+0],eax
; 
; PrintN("1")
  PUSH   dword _S4
  CALL   dword [_PB_PrintN]
; 
; Name$ = UCase(PeekS(*name, -1, #PB_UTF8))
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword 2
  PUSH   dword -1
  PUSH   dword [esp+PS4+28]
  CALL  _PB_PeekS3@16
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _PB_UCase@8
  LEA    eax,[esp+12]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; 
; The whole file may be surrounded by a <dialiggroup> tag, to include more
; than one dialog in a standard conform xml file (as one single "document" object is needed)
; We just ignore this tag
;
; If Name$ = "DIALOGGROUP"
  PUSH   dword [esp+8]
  MOV    edx,_S5
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf7
; ProcedureReturn
  JMP   _EndProcedure5
; EndIf 
_EndIf7:
; 
; get the stuff in a PB format
;
; While *args\i
_While8:
  MOV    ebp,dword [esp+PS4+8]
  CMP    dword [ebp],0
  JE    _Wend8
; AddElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_AddElement@4
; Args()\Name$ = UCase(PeekS(*args\i, -1, #PB_UTF8))
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword 2
  PUSH   dword -1
  MOV    ebp,dword [esp+PS4+32]
  PUSH   dword [ebp]
  CALL  _PB_PeekS3@16
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _PB_UCase@8
  MOV    ebp,dword [esp+4+4]
  LEA    eax,[ebp+8]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; *args + SizeOf(INTEGER)
  ADD    dword [esp+PS4+8],4
; Args()\Value$ = PeekS(*args\i, -1, #PB_UTF8)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword 2
  PUSH   dword -1
  MOV    ebp,dword [esp+PS4+24]
  PUSH   dword [ebp]
  CALL  _PB_PeekS3@16
  MOV    ebp,dword [esp+4+4]
  LEA    eax,[ebp+12]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; *args + SizeOf(INTEGER)
  ADD    dword [esp+PS4+8],4
; Wend
  JMP   _While8
_Wend8:
; 
; If PreviousIndent <> Indent
  MOV    ebx,dword [v_PreviousIndent]
  CMP    ebx,dword [v_Indent]
  JE    _EndIf10
; PreviousIndent = Indent
  MOV    eax,dword [v_Indent]
  MOV    dword [v_PreviousIndent],eax
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; EndIf
_EndIf10:
; 
;PrintN("*--------")
; 
; 
; If Name$ = "COMPILER" ; compilerif statement...
  PUSH   dword [esp+8]
  MOV    edx,_S7
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf12
; If IsKey(Args(), "IF")
  PUSH   dword _S8
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf14
; WriteStringN(1, Space(Indent) + "CompilerIf " + Args()\Value$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S9
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; Else
  JMP   _EndIf13
_EndIf14:
; Error("Syntax Error (Line " + Str(XML_GetCurrentLineNumber_(parser)) + "): " + "Invalid compilerif statement!") 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S10
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_GetCurrentLineNumber
  ADD    esp,4
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  MOV    edx,_S11
  CALL  _SYS_CopyString@0
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _Procedure2
  POP    dword [_PB_StringBasePosition]
; EndIf
_EndIf13:
; 
; PreviousIndent = Indent
  MOV    eax,dword [v_Indent]
  MOV    dword [v_PreviousIndent],eax
; Indent + 2
  ADD    dword [v_Indent],2
; ProcedureReturn 
  JMP   _EndProcedure5
; 
; ElseIf Name$ = "COMPILERELSE"
  JMP   _EndIf11
_EndIf12:
  PUSH   dword [esp+8]
  MOV    edx,_S12
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf16
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, Space(Indent-2) + "CompilerElse")
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  MOV    ebx,dword [v_Indent]
  ADD    ebx,-2
  PUSH   ebx
  CALL  _PB_Space@8
  MOV    edx,_S13
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; ProcedureReturn 
  JMP   _EndProcedure5
; 
; ElseIf Name$ = "SHORTCUT"
  JMP   _EndIf11
_EndIf16:
  PUSH   dword [esp+8]
  MOV    edx,_S14
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf17
; AddElement(Shortcuts())
  PUSH   dword [t_Shortcuts]
  CALL  _PB_AddElement@4
; If IsKey(Args(), "KEY")
  PUSH   dword _S15
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf19
; Shortcuts()\Key$ = Args()\Value$
  MOV    ebp,dword [esp+0+4]
  MOV    edx,dword [ebp+12]
  PUSH   dword [_PB_StringBasePosition]
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [t_Shortcuts+4]
  LEA    eax,[ebp+8]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; EndIf
_EndIf19:
; If IsKey(Args(), "ID")
  PUSH   dword _S16
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf21
; Shortcuts()\ID$ = Args()\Value$
  MOV    ebp,dword [esp+0+4]
  MOV    edx,dword [ebp+12]
  PUSH   dword [_PB_StringBasePosition]
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [t_Shortcuts+4]
  LEA    eax,[ebp+12]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; EndIf
_EndIf21:
; ProcedureReturn ; abort here!
  JMP   _EndProcedure5
; EndIf
_EndIf11:
_EndIf17:
; 
; PrintN("--------")
  PUSH   dword _S17
  CALL   dword [_PB_PrintN]
; 
; Select Name$
  PUSH   dword [esp+8]
; 
; Case "WINDOW" ; special case, it must have a "label" attribute    
  MOV    edx,_S18
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case1
; Type$ = "#DIALOG_Window"   
  MOV    edx,_S19
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; 
; If Indent <> 4 ; if it is not that, there is something wrong
  MOV    ebx,dword [v_Indent]
  CMP    ebx,4
  JE    _EndIf23
; Error("Syntax Error (Line " + Str(XML_GetCurrentLineNumber_(parser)) + "): " + "WINDOW object must be at the main level!") 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S10
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_GetCurrentLineNumber
  ADD    esp,4
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  MOV    edx,_S20
  CALL  _SYS_CopyString@0
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _Procedure2
  POP    dword [_PB_StringBasePosition]
; EndIf
_EndIf23:
; 
; If IsKey(Args(), "LABEL")
  PUSH   dword _S21
  PUSH   dword [esp+8]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf25
; WriteStringN(1, "  " + Args()\Value$ + ":")
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S22
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+12+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  MOV    edx,_S23
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   dword [esp+4]
  CALL  _PB_DeleteElement@4
; Else
  JMP   _EndIf24
_EndIf25:
; Error("Syntax Error (Line " + Str(XML_GetCurrentLineNumber_(parser)) + "): " + "WINDOW object must have a LABEL attribute!") 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S10
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_GetCurrentLineNumber
  ADD    esp,4
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  MOV    edx,_S24
  CALL  _SYS_CopyString@0
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _Procedure2
  POP    dword [_PB_StringBasePosition]
; EndIf     
_EndIf24:
; 
; 
; Case "EMPTY":        Type$ = "#DIALOG_Empty"  
  JMP   _EndSelect1
_Case1:
  MOV    edx,_S25
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case2
  MOV    edx,_S26
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "VBOX":         Type$ = "#DIALOG_VBox"
  JMP   _EndSelect1
_Case2:
  MOV    edx,_S27
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case3
  MOV    edx,_S28
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "HBOX":         Type$ = "#DIALOG_HBox"
  JMP   _EndSelect1
_Case3:
  MOV    edx,_S29
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case4
  MOV    edx,_S30
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "MULTIBOX":     Type$ = "#DIALOG_Multibox"
  JMP   _EndSelect1
_Case4:
  MOV    edx,_S31
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case5
  MOV    edx,_S32
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "SINGLEBOX":    Type$ = "#DIALOG_Singlebox"
  JMP   _EndSelect1
_Case5:
  MOV    edx,_S33
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case6
  MOV    edx,_S34
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "GRIDBOX":      Type$ = "#DIALOG_Gridbox"    
  JMP   _EndSelect1
_Case6:
  MOV    edx,_S35
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case7
  MOV    edx,_S36
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; 
; Case "BUTTON":       Type$ = "#DIALOG_Button"
  JMP   _EndSelect1
_Case7:
  MOV    edx,_S37
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case8
  MOV    edx,_S38
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "CHECKBOX":     Type$ = "#DIALOG_Checkbox"
  JMP   _EndSelect1
_Case8:
  MOV    edx,_S39
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case9
  MOV    edx,_S40
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "IMAGE":        Type$ = "#DIALOG_Image"
  JMP   _EndSelect1
_Case9:
  MOV    edx,_S41
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case10
  MOV    edx,_S42
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "OPTION":       Type$ = "#DIALOG_Option"
  JMP   _EndSelect1
_Case10:
  MOV    edx,_S43
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case11
  MOV    edx,_S44
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "LISTVIEW":     Type$ = "#DIALOG_ListView"
  JMP   _EndSelect1
_Case11:
  MOV    edx,_S45
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case12
  MOV    edx,_S46
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "LISTICON":     Type$ = "#DIALOG_ListIcon"
  JMP   _EndSelect1
_Case12:
  MOV    edx,_S47
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case13
  MOV    edx,_S48
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "TREE":         Type$ = "#DIALOG_Tree"
  JMP   _EndSelect1
_Case13:
  MOV    edx,_S49
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case14
  MOV    edx,_S50
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "CONTAINER":    Type$ = "#DIALOG_Container"
  JMP   _EndSelect1
_Case14:
  MOV    edx,_S51
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case15
  MOV    edx,_S52
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "COMBOBOX":     Type$ = "#DIALOG_ComboBox"
  JMP   _EndSelect1
_Case15:
  MOV    edx,_S53
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case16
  MOV    edx,_S54
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "TEXT":         Type$ = "#DIALOG_Text"
  JMP   _EndSelect1
_Case16:
  MOV    edx,_S55
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case17
  MOV    edx,_S56
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "STRING":       Type$ = "#DIALOG_String"
  JMP   _EndSelect1
_Case17:
  MOV    edx,_S57
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case18
  MOV    edx,_S58
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "PANEL":        Type$ = "#DIALOG_Panel"
  JMP   _EndSelect1
_Case18:
  MOV    edx,_S59
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case19
  MOV    edx,_S60
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "TAB":          Type$ = "#DIALOG_Tab"
  JMP   _EndSelect1
_Case19:
  MOV    edx,_S61
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case20
  MOV    edx,_S62
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "SCROLL":       Type$ = "#DIALOG_Scroll"
  JMP   _EndSelect1
_Case20:
  MOV    edx,_S63
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case21
  MOV    edx,_S64
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "FRAME":        Type$ = "#DIALOG_Frame"
  JMP   _EndSelect1
_Case21:
  MOV    edx,_S65
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case22
  MOV    edx,_S66
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "ITEM":         Type$ = "#DIALOG_Item"
  JMP   _EndSelect1
_Case22:
  MOV    edx,_S67
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case23
  MOV    edx,_S68
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "COLUMN":       Type$ = "#DIALOG_Column"
  JMP   _EndSelect1
_Case23:
  MOV    edx,_S69
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case24
  MOV    edx,_S70
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "EDITOR":       Type$ = "#DIALOG_Editor"
  JMP   _EndSelect1
_Case24:
  MOV    edx,_S71
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case25
  MOV    edx,_S72
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "SCINTILLA":    Type$ = "#DIALOG_Scintilla"
  JMP   _EndSelect1
_Case25:
  MOV    edx,_S73
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case26
  MOV    edx,_S74
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "SCROLLBAR":    Type$ = "#DIALOG_ScrollBar"
  JMP   _EndSelect1
_Case26:
  MOV    edx,_S75
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case27
  MOV    edx,_S76
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "PROGRESSBAR":  Type$ = "#DIALOG_ProgressBar"
  JMP   _EndSelect1
_Case27:
  MOV    edx,_S77
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case28
  MOV    edx,_S78
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "EXPLORERLIST": Type$ = "#DIALOG_ExplorerList"
  JMP   _EndSelect1
_Case28:
  MOV    edx,_S79
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case29
  MOV    edx,_S80
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "EXPLORERTREE": Type$ = "#DIALOG_ExplorerTree"
  JMP   _EndSelect1
_Case29:
  MOV    edx,_S81
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case30
  MOV    edx,_S82
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "EXPLORERCOMBO":Type$ = "#DIALOG_ExplorerCombo"
  JMP   _EndSelect1
_Case30:
  MOV    edx,_S83
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case31
  MOV    edx,_S84
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "SPLITTER":     Type$ = "#DIALOG_Splitter"
  JMP   _EndSelect1
_Case31:
  MOV    edx,_S85
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case32
  MOV    edx,_S86
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "SHORTCUTGADGET":Type$ = "#DIALOG_ShortcutGadget"
  JMP   _EndSelect1
_Case32:
  MOV    edx,_S87
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case33
  MOV    edx,_S88
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; Case "BUTTONIMAGE":  Type$ = "#DIALOG_ButtonImage"
  JMP   _EndSelect1
_Case33:
  MOV    edx,_S89
  MOV    ecx,[esp]
  CALL  _SYS_StringEqual
  JE    _Case34
  MOV    edx,_S90
  LEA    ecx,[esp+16]
  CALL   SYS_FastAllocateStringFree
; 
; Default
  JMP   _EndSelect1
_Case34:
; Error("Syntax Error (Line " + Str(XML_GetCurrentLineNumber_(parser)) + "): " + "Unknown Tag: " + PeekS(*name)) 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S10
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_GetCurrentLineNumber
  ADD    esp,4
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  MOV    edx,_S91
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [esp+PS4+24]
  CALL  _PB_PeekS@8
  POP    eax
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _Procedure2
  POP    dword [_PB_StringBasePosition]
; 
; EndSelect
_Case35:
_EndSelect1:
  POP    eax
; 
; WriteStringN(1, Space(Indent) + "Data.l " + Type$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S92
  CALL  _SYS_CopyString@0
  MOV    edx,dword [esp+20]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; 
; If IsKey(Args(), "ID")
  PUSH   dword _S16
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf28
; WriteString(1, Space(Indent) + "Data.l " + Args()\Value$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S92
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteString@8
  POP    dword [_PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; Else
  JMP   _EndIf27
_EndIf28:
; WriteString(1, Space(Indent) + "Data.l #PB_Any")
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S93
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteString@8
  POP    dword [_PB_StringBasePosition]
; EndIf
_EndIf27:
; 
; If IsKey(Args(), "FLAGS")
  PUSH   dword _S94
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf31
; WriteString(1, ", " + Args()\Value$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteString@8
  POP    dword [_PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; ElseIf Name$ = "ITEM" And IsKey(Args(), "SUBLEVEL") ; for treegadget items (see preferences)
  JMP   _EndIf30
_EndIf31:
  PUSH   dword [esp+8]
  MOV    edx,_S67
  POP    ecx
  CALL  _SYS_StringEqual
  JE     No0
  PUSH   dword _S96
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE     No0
Ok0:
  MOV    eax,1
  JMP    End0
No0:
  XOR    eax,eax
End0:
  AND    eax,eax
  JE    _EndIf32
; WriteString(1, ", " + Args()\Value$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteString@8
  POP    dword [_PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; Else
  JMP   _EndIf30
_EndIf32:
; WriteString(1, ", 0")
  PUSH   dword _S97
  PUSH   dword 1
  CALL  _PB_WriteString@8
; EndIf
_EndIf30:
; 
; If IsKey(Args(), "WIDTH")
  PUSH   dword _S98
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf35
; If UCase(Args()\Value$) = "IGNORE"
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    ebp,dword [esp+8+4]
  PUSH   dword [ebp+12]
  CALL  _PB_UCase@8
  INC    dword [_PB_StringBasePosition]
  MOV    edx,_S99
  POP    ecx
  MOV    dword [_PB_StringBasePosition],ecx
  ADD    ecx,[PB_StringBase]
  CALL  _SYS_StringEqual
  JE    _EndIf37
; WriteString(1, ", -1") ; special value to indicate that this size should not be calculated
  PUSH   dword _S100
  PUSH   dword 1
  CALL  _PB_WriteString@8
; Else
  JMP   _EndIf36
_EndIf37:
; WriteString(1, ", " + Args()\Value$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteString@8
  POP    dword [_PB_StringBasePosition]
; EndIf
_EndIf36:
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; Else
  JMP   _EndIf34
_EndIf35:
; WriteString(1, ", 0")
  PUSH   dword _S97
  PUSH   dword 1
  CALL  _PB_WriteString@8
; EndIf
_EndIf34:
; 
; If IsKey(Args(), "HEIGHT")
  PUSH   dword _S101
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf41
; If UCase(Args()\Value$) = "IGNORE"
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    ebp,dword [esp+8+4]
  PUSH   dword [ebp+12]
  CALL  _PB_UCase@8
  INC    dword [_PB_StringBasePosition]
  MOV    edx,_S99
  POP    ecx
  MOV    dword [_PB_StringBasePosition],ecx
  ADD    ecx,[PB_StringBase]
  CALL  _SYS_StringEqual
  JE    _EndIf43
; WriteString(1, ", -1")
  PUSH   dword _S100
  PUSH   dword 1
  CALL  _PB_WriteString@8
; Else
  JMP   _EndIf42
_EndIf43:
; WriteString(1, ", " + Args()\Value$)
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteString@8
  POP    dword [_PB_StringBasePosition]
; EndIf  
_EndIf42:
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; Else
  JMP   _EndIf40
_EndIf41:
; WriteString(1, ", 0")
  PUSH   dword _S97
  PUSH   dword 1
  CALL  _PB_WriteString@8
; EndIf
_EndIf40:
; 
; If IsKey(Args(), "TEXT")
  PUSH   dword _S55
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf47
; LiteralText$ = Args()\Value$
  MOV    ebp,dword [esp+0+4]
  MOV    edx,dword [ebp+12]
  PUSH   dword [_PB_StringBasePosition]
  CALL  _SYS_CopyString@0
  LEA    eax,[esp+20]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; EndIf
_EndIf47:
; 
; HasText = 0
  MOV    dword [esp+20],0
; If IsKey(Args(), "LANG")
  PUSH   dword _S102
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf49
; LanguageGroup$ = StringField(Args()\Value$, 1, ":")
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword _S23
  PUSH   dword 1
  MOV    ebp,dword [esp+16+4]
  PUSH   dword [ebp+12]
  CALL  _PB_StringField@16
  LEA    eax,[esp+28]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; LanguageKey$   = StringField(Args()\Value$, 2, ":")
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword _S23
  PUSH   dword 2
  MOV    ebp,dword [esp+16+4]
  PUSH   dword [ebp+12]
  CALL  _PB_StringField@16
  LEA    eax,[esp+32]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; HasText = 1
  MOV    dword [esp+20],1
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; EndIf
_EndIf49:
; 
; If IsKey(Args(), "NAME")
  PUSH   dword _S103
  PUSH   dword [esp+4]
  CALL  _Procedure0
  AND    eax,eax
  JE    _EndIf51
; ObjectName$ = UCase(Args()\Value$) ; we store the name in ucase
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    ebp,dword [esp+8+4]
  PUSH   dword [ebp+12]
  CALL  _PB_UCase@8
  LEA    eax,[esp+36]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; HasText = 1
  MOV    dword [esp+20],1
; DeleteElement(Args())
  PUSH   dword [esp+0]
  CALL  _PB_DeleteElement@4
; EndIf
_EndIf51:
; 
; WriteStringN(1, ", " + Str(HasText) + ", " + Str(ListSize(Args())))       
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    eax,dword [esp+36]
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [esp+16]
  CALL  _PB_ListSize@4
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; WriteStringN(1, Space(Indent) + "Data.s " + Chr(34)+ObjectName$+Chr(34) + ", " + Chr(34)+ReplaceString(LiteralText$, "%newline%", #NewLineSequence)+Chr(34)+", "+Chr(34)+LanguageGroup$+Chr(34)+", "+Chr(34)+LanguageKey$+Chr(34))
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S104
  CALL  _SYS_CopyString@0
  MOV    edx,dword [esp+40]
  CALL  _SYS_CopyString@0
  MOV    edx,_S105
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword _S106
  PUSH   dword _S107
  PUSH   dword [esp+40]
  CALL  _PB_ReplaceString@16
  POP    eax
  MOV    edx,_S105
  CALL  _SYS_CopyString@0
  MOV    edx,dword [esp+32]
  CALL  _SYS_CopyString@0
  MOV    edx,_S105
  CALL  _SYS_CopyString@0
  MOV    edx,dword [esp+36]
  CALL  _SYS_CopyString@0
  MOV    edx,_S108
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; 
; ForEach Args()
  PUSH   dword [esp+0]
  CALL  _PB_ResetList@4
_ForEach52:
  PUSH   dword [esp+0]
  CALL  _PB_NextElement@4
  OR     eax,eax
  JZ    _Next52
; WriteStringN(1, Space(Indent) + "Data.s " + Chr(34)+Args()\Name$+Chr(34)+", "+Chr(34)+Args()\Value$+Chr(34))
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S104
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+8]
  CALL  _SYS_CopyString@0
  MOV    edx,_S105
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [esp+8+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  MOV    edx,_S108
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; Next Args()
  JMP   _ForEach52
_Next52:
; 
; PreviousIndent = Indent
  MOV    eax,dword [v_Indent]
  MOV    dword [v_PreviousIndent],eax
; Indent + 2
  ADD    dword [v_Indent],2
; 
; PrintN("2")
  PUSH   dword _S109
  CALL   dword [_PB_PrintN]
; 
; EndProcedure
  XOR    eax,eax
_EndProcedure5:
  PUSH   dword [esp+8]
  CALL  _SYS_FreeString@4
  PUSH   dword [esp+12]
  CALL  _SYS_FreeString@4
  PUSH   dword [esp+16]
  CALL  _SYS_FreeString@4
  PUSH   dword [esp+24]
  CALL  _SYS_FreeString@4
  PUSH   dword [esp+28]
  CALL  _SYS_FreeString@4
  PUSH   dword [esp+32]
  CALL  _SYS_FreeString@4
  PUSH   eax
  PUSH   dword [esp+4]
  CALL  _PB_FreeList@4
  POP    eax
  ADD    esp,36
  POP    ebx
  POP    ebp
  RET
}
; 
; ProcedureC EndElementHandler(user_data, *name)
macro MP6{
_Procedure6:
  PUSH   ebx
  PS6=12
  XOR    eax,eax
  PUSH   eax                                                                                                                                                                                                                  
; 
; Name$ = UCase(PeekS(*name, -1, #PB_UTF8))
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword 2
  PUSH   dword -1
  PUSH   dword [esp+PS6+28]
  CALL  _PB_PeekS3@16
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _PB_UCase@8
  LEA    eax,[esp+4]
  PUSH   eax
  CALL  _SYS_AllocateString4@8
; 
; If Name$ = "DIALOGGROUP" Or Name$ = "COMPILERELSE" Or Name$ = "SHORTCUT"
  PUSH   dword [esp]
  MOV    edx,_S5
  POP    ecx
  CALL  _SYS_StringEqual
  JNE    Ok1
  PUSH   dword [esp]
  MOV    edx,_S12
  POP    ecx
  CALL  _SYS_StringEqual
  JNE    Ok1
  PUSH   dword [esp]
  MOV    edx,_S14
  POP    ecx
  CALL  _SYS_StringEqual
  JNE    Ok1
  JMP    No1
Ok1:
  MOV    eax,1
  JMP    End1
No1:
  XOR    eax,eax
End1:
  AND    eax,eax
  JE    _EndIf54
; ProcedureReturn
  JMP   _EndProcedure7
; EndIf
_EndIf54:
; 
; just finish whatever object is present
;
; Indent - 2
  MOV    ebx,dword [v_Indent]
  ADD    ebx,-2
  MOV    dword [v_Indent],ebx
; PreviousIndent = Indent
  MOV    eax,dword [v_Indent]
  MOV    dword [v_PreviousIndent],eax
; 
; If Name$ = "COMPILER"
  PUSH   dword [esp]
  MOV    edx,_S7
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf56
; WriteStringN(1, Space(Indent) + "CompilerEndIf")
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S110
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; Else
  JMP   _EndIf55
_EndIf56:
; WriteStringN(1, Space(Indent) + "Data.l -1")  
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S111
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; EndIf
_EndIf55:
; 
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; 
; If Name$ = "WINDOW" ; when the window object is done, add all the shortcuts after    
  PUSH   dword [esp]
  MOV    edx,_S18
  POP    ecx
  CALL  _SYS_StringEqual
  JE    _EndIf59
; ForEach Shortcuts()
  PUSH   dword [t_Shortcuts]
  CALL  _PB_ResetList@4
_ForEach60:
  PUSH   dword [t_Shortcuts]
  CALL  _PB_NextElement@4
  OR     eax,eax
  JZ    _Next60
; WriteStringN(1, Space(Indent) + "Data.l #DIALOG_Shortcut, " + Shortcuts()\Key$ + ", " + Shortcuts()\ID$) 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S112
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [t_Shortcuts+4]
  MOV    edx,dword [ebp+8]
  CALL  _SYS_CopyString@0
  MOV    edx,_S95
  CALL  _SYS_CopyString@0
  MOV    ebp,dword [t_Shortcuts+4]
  MOV    edx,dword [ebp+12]
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; Next Shortcuts()
  JMP   _ForEach60
_Next60:
; 
; ClearList(Shortcuts()) ; clear the list for the next window object
  PUSH   dword [t_Shortcuts]
  CALL  _PB_ClearList@4
; WriteStringN(1, Space(Indent) + "Data.l -1") 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [_PB_StringBasePosition]
  PUSH   dword [v_Indent]
  CALL  _PB_Space@8
  MOV    edx,_S111
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; EndIf
_EndIf59:
; 
; EndProcedure
  XOR    eax,eax
_EndProcedure7:
  PUSH   dword [esp]
  CALL  _SYS_FreeString@4
  ADD    esp,4
  POP    ebx
  RET
}
; 
; 
; If ReadFile(0, Input$) = 0 Or CreateFile(1, Output$) = 0
  PUSH   dword [v_Input$]
  PUSH   dword 0
  CALL  _PB_ReadFile@8
  MOV    ebx,eax
  AND    ebx,ebx
  JE     Ok2
  PUSH   dword [v_Output$]
  PUSH   dword 1
  CALL  _PB_CreateFile@8
  MOV    ebx,eax
  AND    ebx,ebx
  JE     Ok2
  JMP    No2
Ok2:
  MOV    eax,1
  JMP    End2
No2:
  XOR    eax,eax
End2:
  AND    eax,eax
  JE    _EndIf62
; Error("File I/O Error")
  PUSH   dword _S113
  CALL  _Procedure2
; EndIf
_EndIf62:
; 
; parser = XML_ParserCreate_(0)
  PUSH   dword 0
  CALL  _XML_ParserCreate
  ADD    esp,4
  MOV    dword [v_parser],eax
; length = Lof(0)
  PUSH   dword 0
  CALL  _PB_Lof@4
  MOV    dword [v_length],eax
; buffer = AllocateMemory(length+1)
  MOV    ebx,dword [v_length]
  INC    ebx
  PUSH   ebx
  CALL  _PB_AllocateMemory@4
  MOV    dword [v_buffer],eax
; 
; If parser = 0 Or buffer = 0
  MOV    ebx,dword [v_parser]
  AND    ebx,ebx
  JE     Ok3
  MOV    ebx,dword [v_buffer]
  AND    ebx,ebx
  JE     Ok3
  JMP    No3
Ok3:
  MOV    eax,1
  JMP    End3
No3:
  XOR    eax,eax
End3:
  AND    eax,eax
  JE    _EndIf64
; Error("Memory Error")
  PUSH   dword _S114
  CALL  _Procedure2
; EndIf
_EndIf64:
; 
; ReadData(0, buffer, length)
  PUSH   dword [v_length]
  PUSH   dword [v_buffer]
  PUSH   dword 0
  CALL  _PB_ReadData@12
; CloseFile(0)
  PUSH   dword 0
  CALL  _PB_CloseFile@4
; 
; XML_SetStartElementHandler_(parser, @StartElementHandler())
  LEA    eax,[_Procedure4]
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_SetStartElementHandler
  ADD    esp,8
; XML_SetEndElementHandler_(parser, @EndElementHandler())
  LEA    eax,[_Procedure6]
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_SetEndElementHandler
  ADD    esp,8
; 
; 
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, ";")
  PUSH   dword _S115
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "; PureBasic IDE - Dialog Manager file")
  PUSH   dword _S116
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, ";")
  PUSH   dword _S115
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "; Autogenerated from "+Chr(34)+Input$+Chr(34))
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S117
  CALL  _SYS_CopyString@0
  MOV    edx,dword [v_Input$]
  CALL  _SYS_CopyString@0
  MOV    edx,_S108
  CALL  _SYS_CopyString@0
  INC    dword [_PB_StringBasePosition]
  PUSH   dword 1
  MOV    edx,[PB_StringBase]
  ADD    [esp+4],edx
  CALL  _PB_WriteStringN@8
  POP    dword [_PB_StringBasePosition]
; WriteStringN(1, "; Do not edit!")
  PUSH   dword _S118
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, ";")
  PUSH   dword _S115
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "DataSection")
  PUSH   dword _S119
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; 
; If XML_Parse_(parser, buffer, length, #True) = #XML_STATUS_ERROR ; only output a message in case of error
  PUSH   dword 1
  PUSH   dword [v_length]
  PUSH   dword [v_buffer]
  PUSH   dword [v_parser]
  CALL  _XML_Parse
  ADD    esp,16
  MOV    ebx,eax
  AND    ebx,ebx
  JNE   _EndIf66
; Error("Parser Error (Line " + Str(XML_GetCurrentLineNumber_(parser)) + "): " + PeekS(XML_ErrorString_(XML_GetErrorCode_(parser)))) 
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  MOV    edx,_S120
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_GetCurrentLineNumber
  ADD    esp,4
  CDQ
  PUSH   edx
  PUSH   eax
  CALL  _PB_Str@12
  POP    eax
  MOV    edx,_S121
  CALL  _SYS_CopyString@0
  MOV    eax,[_PB_StringBasePosition]
  PUSH   eax
  PUSH   eax
  PUSH   dword [v_parser]
  CALL  _XML_GetErrorCode
  ADD    esp,4
  PUSH   eax
  CALL  _XML_ErrorString
  ADD    esp,4
  PUSH   eax
  CALL  _PB_PeekS@8
  POP    eax
  MOV    edx,[PB_StringBase]
  ADD    [esp+0],edx
  CALL  _Procedure2
  POP    dword [_PB_StringBasePosition]
; EndIf
_EndIf66:
; 
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "EndDataSection")
  PUSH   dword _S122
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; WriteStringN(1, "")
  PUSH   dword _S6
  PUSH   dword 1
  CALL  _PB_WriteStringN@8
; 
; CloseFile(1)
  PUSH   dword 1
  CALL  _PB_CloseFile@4
; FreeMemory(buffer)
  PUSH   dword [v_buffer]
  CALL  _PB_FreeMemory@4
; XML_ParserFree_(parser)
  PUSH   dword [v_parser]
  CALL  _XML_ParserFree
  ADD    esp,4
; 
; Delay(1000)
  PUSH   dword 1000
  CALL  _PB_Delay@4
; 
; End #EXIT_SUCCESS
  PUSH   dword 0
  JMP   _PB_EOP
; 
; 
_PB_EOP_NoValue:
  PUSH   dword 0
_PB_EOP:
  CALL  _PB_EndFunctions
  PUSH   dword [PB_MemoryBase]
  CALL  _HeapDestroy@4
  CALL  _ExitProcess@4
_PB_EndFunctions:
  CALL  _PB_FreeMemorys@0
  CALL  _PB_FreeFiles@0
  RET
; 
MP6
MP2
MP0
MP4
; 
section '.data' data readable writeable
; 
_PB_DataSection:
pb_public PB_DEBUGGER_LineNumber
  dd     -1
pb_public PB_DEBUGGER_IncludedFiles
  dd     0
pb_public PB_DEBUGGER_FileName
  db     0
_PB_ExecutableType: dd 1
public _SYS_StaticStringStart
_SYS_StaticStringStart:
_S22: db "  ",0
_S6: db 0
_S114: db "Memory Error",0
_S121: db "): ",0
_S67: db "ITEM",0
_S5: db "DIALOGGROUP",0
_S120: db "Parser Error (Line ",0
_S11: db "): Invalid compilerif statement!",0
_S108: db 34,0
_S28: db "#DIALOG_VBox",0
_S25: db "EMPTY",0
_S57: db "STRING",0
_S4: db "1",0
_S109: db "2",0
_S87: db "SHORTCUTGADGET",0
_S50: db "#DIALOG_Tree",0
_S47: db "LISTICON",0
_S100: db ", -1",0
_S26: db "#DIALOG_Empty",0
_S118: db "; Do not edit!",0
_S23: db ":",0
_S115: db ";",0
_S16: db "ID",0
_S97: db ", 0",0
_S8: db "IF",0
_S15: db "KEY",0
_S101: db "HEIGHT",0
_S37: db "BUTTON",0
_S41: db "IMAGE",0
_S122: db "EndDataSection",0
_S96: db "SUBLEVEL",0
_S42: db "#DIALOG_Image",0
_S55: db "TEXT",0
_S40: db "#DIALOG_Checkbox",0
_S86: db "#DIALOG_Splitter",0
_S45: db "LISTVIEW",0
_S33: db "SINGLEBOX",0
_S89: db "BUTTONIMAGE",0
_S65: db "FRAME",0
_S34: db "#DIALOG_Singlebox",0
_S90: db "#DIALOG_ButtonImage",0
_S107: db "%newline%",0
_S69: db "COLUMN",0
_S1: db "c:/purebasic/svn/v4.50/Fr34k/PureBasicIDE/dialogs/Find.xml",0
_S13: db "CompilerElse",0
_S12: db "COMPILERELSE",0
_S66: db "#DIALOG_Frame",0
_S81: db "EXPLORERTREE",0
_S79: db "EXPLORERLIST",0
_S64: db "#DIALOG_Scroll",0
_S51: db "CONTAINER",0
_S14: db "SHORTCUT",0
_S94: db "FLAGS",0
_S52: db "#DIALOG_Container",0
_S104: db "Data.s ",34,0
_S61: db "TAB",0
_S62: db "#DIALOG_Tab",0
_S29: db "HBOX",0
_S32: db "#DIALOG_Multibox",0
_S113: db "File I/O Error",0
_S71: db "EDITOR",0
_S19: db "#DIALOG_Window",0
_S116: db "; PureBasic IDE - Dialog Manager file",0
_S95: db ", ",0
_S43: db "OPTION",0
_S53: db "COMBOBOX",0
_S17: db "--------",0
_S77: db "PROGRESSBAR",0
_S68: db "#DIALOG_Item",0
_S83: db "EXPLORERCOMBO",0
_S117: db "; Autogenerated from ",34,0
_S78: db "#DIALOG_ProgressBar",0
_S84: db "#DIALOG_ExplorerCombo",0
_S106: db 34,"+Chr(13)+Chr(10)+",34,0
_S7: db "COMPILER",0
_S58: db "#DIALOG_String",0
_S35: db "GRIDBOX",0
_S98: db "WIDTH",0
_S88: db "#DIALOG_ShortcutGadget",0
_S103: db "NAME",0
_S48: db "#DIALOG_ListIcon",0
_S36: db "#DIALOG_Gridbox",0
_S27: db "VBOX",0
_S111: db "Data.l -1",0
_S49: db "TREE",0
_S9: db "CompilerIf ",0
_S38: db "#DIALOG_Button",0
_S56: db "#DIALOG_Text",0
_S2: db "c:/purebasic/svn/v4.50/Fr34k/PureBasicIDE/dialogs/Dialog_Find.pb",0
_S21: db "LABEL",0
_S73: db "SCINTILLA",0
_S46: db "#DIALOG_ListView",0
_S119: db "DataSection",0
_S74: db "#DIALOG_Scintilla",0
_S39: db "CHECKBOX",0
_S59: db "PANEL",0
_S112: db "Data.l #DIALOG_Shortcut, ",0
_S85: db "SPLITTER",0
_S70: db "#DIALOG_Column",0
_S105: db 34,", ",34,0
_S20: db "): WINDOW object must be at the main level!",0
_S60: db "#DIALOG_Panel",0
_S82: db "#DIALOG_ExplorerTree",0
_S80: db "#DIALOG_ExplorerList",0
_S3: db "DialogCompiler",0
_S63: db "SCROLL",0
_S99: db "IGNORE",0
_S30: db "#DIALOG_HBox",0
_S110: db "CompilerEndIf",0
_S10: db "Syntax Error (Line ",0
_S72: db "#DIALOG_Editor",0
_S75: db "SCROLLBAR",0
_S24: db "): WINDOW object must have a LABEL attribute!",0
_S76: db "#DIALOG_ScrollBar",0
_S31: db "MULTIBOX",0
_S91: db "): Unknown Tag: ",0
_S44: db "#DIALOG_Option",0
_S93: db "Data.l #PB_Any",0
_S102: db "LANG",0
_S18: db "WINDOW",0
_S54: db "#DIALOG_ComboBox",0
_S92: db "Data.l ",0
pb_public PB_NullString
  db     0
public _SYS_StaticStringEnd
_SYS_StaticStringEnd:
align 4
align 4
s_s:
  dd     0
  dd     -1
s_argpair:
  dd     0
  dd     4
  dd     -1
s_shortcut:
  dd     0
  dd     4
  dd     -1
align 4
; 
section '.bss' readable writeable
_PB_BSSSection:
align 4
; 
I_BSSStart:
_PB_MemoryBase:
PB_MemoryBase: rd 1
_PB_Instance:
PB_Instance: rd 1
; 
align 4
PB_DataPointer rd 1
v_Input$ rd 1
v_Output$ rd 1
v_Indent rd 1
v_PreviousIndent rd 1
v_parser rd 1
v_length rd 1
v_buffer rd 1
align 4
align 4
align 4
align 4
t_Shortcuts rd 2
I_BSSEnd:
section '.data' data readable writeable
SYS_EndDataSection:
