; 
; PureBasic 5.70 LTS beta 3 (Windows - x64) generated code
; 
; (c) 2018 Fantaisie Software
; 
; The header must remain intact for Re-Assembly
; 
; String
; Requester
; Process
; Cipher
; Memory
; LinkedList
; FileSystem
; Date
; File
; Object
; SimpleList
; Console
; :System
; expat.lib
; kernel32.lib
; :Import
; 
format MS64 COFF
; 
; 
extrn PB_NewList
extrn PB_AddElement
extrn PB_AllocateMemory
extrn PB_ClearList
extrn PB_CloseConsole
extrn PB_CloseFile
extrn PB_CreateFile
extrn PB_DeleteElement
extrn PB_DeleteFile
extrn PB_FreeFiles
extrn PB_FreeFileSystem
extrn PB_FreeList
extrn PB_FreeMemory
extrn PB_FreeMemorys
extrn PB_FreeObjects
extrn PB_InitFile
extrn PB_InitList
extrn PB_InitMemory
extrn PB_InitProcess
extrn PB_InitRequester
extrn PB_IsFile
extrn PB_ListSize
extrn PB_Lof
extrn PB_MessageRequester
extrn PB_NextElement
extrn PB_OpenConsole
extrn PB_PeekS
extrn PB_PeekS2
extrn PB_PrintN
extrn PB_ProgramParameter
extrn PB_ReadData
extrn PB_ReadFile
extrn PB_ReplaceString
extrn PB_ResetList
extrn PB_Space
extrn PB_Str
extrn PB_StringField
extrn PB_UCase
extrn PB_WriteString
extrn PB_WriteStringN
extrn ExitProcess
extrn GetModuleHandleW
extrn HeapCreate
extrn HeapDestroy
extrn memset
extrn pb_XML_ErrorString
extrn pb_XML_GetCurrentLineNumber
extrn pb_XML_GetErrorCode
extrn pb_XML_Parse
extrn pb_XML_ParserCreate
extrn pb_XML_ParserFree
extrn pb_XML_SetEndElementHandler
extrn pb_XML_SetStartElementHandler
extrn SYS_CopyString
extrn SYS_StringEqual
extrn SYS_AllocateString4
extrn SYS_FastAllocateString4
extrn SYS_FastAllocateStringFree4
extrn SYS_FreeString
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
section '.code' code readable executable align 4096
; 
; 
PureBasicStart:
; 
  SUB    rsp,40
  MOV    r8,I_BSSEnd-I_BSSStart
  XOR    rdx,rdx
  MOV    rcx,I_BSSStart
  CALL   memset
  XOR    rcx,rcx
  CALL   GetModuleHandleW
  MOV    [PB_Instance],rax
  XOR    r8,r8
  MOV    rdx,4096
  XOR    rcx,rcx
  CALL   HeapCreate
  MOV    [PB_MemoryBase],rax
  CALL   SYS_InitString
  CALL   PB_InitFile
  CALL   PB_InitList
  CALL   PB_InitMemory
  CALL   PB_InitProcess
  CALL   PB_InitRequester
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
; #EXIT_FAILURE = 1
; #EXIT_SUCCESS = 0
; 
; 
; Input$  = ProgramParameter()
  MOV    rax,[PB_StringBasePosition]
  PUSH   rax
  SUB    rsp,8
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL   PB_ProgramParameter
  ADD    rsp,40
  LEA    rcx,[v_Input$]
  POP    rdx
  CALL   SYS_AllocateString4
; Output$ = ProgramParameter()
  MOV    rax,[PB_StringBasePosition]
  PUSH   rax
  SUB    rsp,8
  PUSH   rax
  POP    rcx
  SUB    rsp,32
  CALL   PB_ProgramParameter
  ADD    rsp,40
  LEA    rcx,[v_Output$]
  POP    rdx
  CALL   SYS_AllocateString4
; 
; 
; 
; 
; 
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
  MOV    rcx,qword [t_Shortcuts]
  CALL   PB_FreeList
  MOV    r9,7
  MOV    r8,s_shortcut
  LEA    rdx,[t_Shortcuts]
  MOV    rcx,16
  CALL   PB_NewList
; Global Indent = 4, PreviousIndent = 2, parser
  MOV    qword [v_Indent],4
  MOV    qword [v_PreviousIndent],2
; 
; CompilerIf #PB_Compiler_OS = #PB_OS_Windows
; #NewLineSequence = Chr(34)+"+Chr(13)+Chr(10)+"+Chr(34)
; CompilerElse
; 
; 
; 
; 
; 
; 
; 
; If ReadFile(0, Input$) = 0 Or CreateFile(1, Output$) = 0
  MOV    rdx,qword [v_Input$]
  MOV    rcx,qword 0
  CALL   PB_ReadFile
  MOV    r15,rax
  AND    r15,r15
  JE     Ok2
  MOV    rdx,qword [v_Output$]
  MOV    rcx,qword 1
  CALL   PB_CreateFile
  MOV    r15,rax
  AND    r15,r15
  JE     Ok2
  JMP    No2
Ok2:
  MOV    rax,1
  JMP    End2
No2:
  XOR    rax,rax
End2:
  AND    rax,rax
  JE    _EndIf62
; Error("File I/O Error")
  MOV    rax,_S112
  MOV    rcx,rax
  CALL  _Procedure2
; EndIf
_EndIf62:
; 
; parser = pb_XML_ParserCreate_(0)
  MOV    rcx,qword 0
  CALL   pb_XML_ParserCreate
  MOV    qword [v_parser],rax
; length = Lof(0)
  MOV    rcx,qword 0
  CALL   PB_Lof
  MOV    qword [v_length],rax
; buffer = AllocateMemory(length)
  MOV    rcx,qword [v_length]
  CALL   PB_AllocateMemory
  MOV    qword [v_buffer],rax
; 
; If parser = 0 Or buffer = 0
  MOV    r15,qword [v_parser]
  AND    r15,r15
  JE     Ok3
  MOV    r15,qword [v_buffer]
  AND    r15,r15
  JE     Ok3
  JMP    No3
Ok3:
  MOV    rax,1
  JMP    End3
No3:
  XOR    rax,rax
End3:
  AND    rax,rax
  JE    _EndIf64
; Error("Memory Error")
  MOV    rax,_S113
  MOV    rcx,rax
  CALL  _Procedure2
; EndIf
_EndIf64:
; 
; ReadData(0, buffer, length)
  MOV    r8,qword [v_length]
  MOV    rdx,qword [v_buffer]
  MOV    rcx,qword 0
  CALL   PB_ReadData
; CloseFile(0)
  MOV    rcx,qword 0
  CALL   PB_CloseFile
; 
; pb_XML_SetStartElementHandler_(parser, @StartElementHandler())
  LEA    rax,[_Procedure4]
  MOV    rdx,rax
  MOV    rcx,qword [v_parser]
  CALL   pb_XML_SetStartElementHandler
; pb_XML_SetEndElementHandler_(parser, @EndElementHandler())
  LEA    rax,[_Procedure6]
  MOV    rdx,rax
  MOV    rcx,qword [v_parser]
  CALL   pb_XML_SetEndElementHandler
; 
; 
; WriteStringN(1, "")
  MOV    rax,_S3
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, ";")
  MOV    rax,_S114
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "; PureBasic IDE - Dialog Manager file")
  MOV    rax,_S115
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, ";")
  MOV    rax,_S114
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "; Autogenerated from "+Chr(34)+Input$+Chr(34))
  MOV    rax,[PB_StringBasePosition]
  PUSH   rax
  SUB    rsp,8
  PUSH   rax
  MOV    rcx,_S116
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [v_Input$]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S108
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; WriteStringN(1, "; Do not edit!")
  MOV    rax,_S117
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, ";")
  MOV    rax,_S114
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "")
  MOV    rax,_S3
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "DataSection")
  MOV    rax,_S118
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "")
  MOV    rax,_S3
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; 
; If pb_XML_Parse_(parser, buffer, length, #True) = #XML_STATUS_ERROR 
  MOV    r9,qword 1
  MOV    r8,qword [v_length]
  MOV    rdx,qword [v_buffer]
  MOV    rcx,qword [v_parser]
  CALL   pb_XML_Parse
  MOV    r15,rax
  AND    r15,r15
  JNE   _EndIf66
; Error("Parser Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + PeekS(pb_XML_ErrorString_(pb_XML_GetErrorCode_(parser)))) 
  MOV    rax,[PB_StringBasePosition]
  PUSH   rax
  SUB    rsp,8
  PUSH   rax
  MOV    rcx,_S119
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rdx,[PB_StringBasePosition]
  PUSH   rdx
  PUSH   rdx
  SUB    rsp,8
  MOV    rcx,qword [v_parser]
  SUB    rsp,32
  CALL   pb_XML_GetCurrentLineNumber
  ADD    rsp,40
  MOV    rcx,rax
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S120
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rdx,[PB_StringBasePosition]
  PUSH   rdx
  PUSH   rdx
  SUB    rsp,8
  MOV    rcx,qword [v_parser]
  SUB    rsp,32
  CALL   pb_XML_GetErrorCode
  ADD    rsp,32
  MOV    rcx,rax
  SUB    rsp,32
  CALL   pb_XML_ErrorString
  ADD    rsp,40
  MOV    rcx,rax
  POP    rdx
  SUB    rsp,32
  CALL   PB_PeekS
  ADD    rsp,32
  POP    rax
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; EndIf
_EndIf66:
; 
; WriteStringN(1, "")
  MOV    rax,_S3
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "EndDataSection")
  MOV    rax,_S121
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; WriteStringN(1, "")
  MOV    rax,_S3
  MOV    rdx,rax
  MOV    rcx,qword 1
  CALL   PB_WriteStringN
; 
; CloseFile(1)
  MOV    rcx,qword 1
  CALL   PB_CloseFile
; FreeMemory(buffer)
  MOV    rcx,qword [v_buffer]
  CALL   PB_FreeMemory
; pb_XML_ParserFree_(parser)
  MOV    rcx,qword [v_parser]
  CALL   pb_XML_ParserFree
; 
; End #EXIT_SUCCESS
  XOR    rax,rax
  MOV    [PB_ExitCode],rax
  JMP   _PB_EOP
; 
; 
_PB_EOP:
  CALL   PB_EndFunctions
  CALL   SYS_FreeStrings
  MOV    rcx,[PB_MemoryBase]
  CALL   HeapDestroy
  MOV    rcx,[PB_ExitCode]
  CALL   ExitProcess
PB_EndFunctions:
  SUB    rsp,40
  CALL   PB_FreeFileSystem
  CALL   PB_FreeFiles
  CALL   PB_FreeObjects
  CALL   PB_FreeMemorys
  ADD    rsp,40
  RET
; 
; ProcedureC EndElementHandler(user_data, *name)
_Procedure6:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  PUSH   rbp
  PUSH   r15
  PS6=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
; 
; Name$ = UCase(PeekS(*name, -1))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword -1
  PUSH   qword [rsp+PS6+56]
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL   PB_PeekS2
  ADD    rsp,32
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+48]
  POP    rdx
  CALL   SYS_AllocateString4
; 
; If Name$ = "DIALOGGROUP" Or Name$ = "COMPILERELSE" Or Name$ = "SHORTCUT"
  PUSH   qword [rsp+40]
  MOV    rcx,_S2
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JNE    Ok1
  PUSH   qword [rsp+40]
  MOV    rcx,_S9
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JNE    Ok1
  PUSH   qword [rsp+40]
  MOV    rcx,_S11
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JNE    Ok1
  JMP    No1
Ok1:
  MOV    rax,1
  JMP    End1
No1:
  XOR    rax,rax
End1:
  AND    rax,rax
  JE    _EndIf54
; ProcedureReturn
  JMP   _EndProcedure7
; EndIf
_EndIf54:
; 
; 
; 
; Indent - 2
  MOV    r15,qword [v_Indent]
  ADD    r15,-2
  MOV    qword [v_Indent],r15
; PreviousIndent = Indent
  PUSH   qword [v_Indent]
  POP    rax
  MOV    qword [v_PreviousIndent],rax
; 
; If Name$ = "COMPILER"
  PUSH   qword [rsp+40]
  MOV    rcx,_S4
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf56
; WriteStringN(1, Space(Indent) + "CompilerEndIf")
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S109
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; Else
  JMP   _EndIf55
_EndIf56:
; WriteStringN(1, Space(Indent) + "Data.l -1")  
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S110
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; EndIf
_EndIf55:
; 
; WriteStringN(1, "")
  MOV    rax,_S3
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteStringN
; 
; If Name$ = "WINDOW" 
  PUSH   qword [rsp+40]
  MOV    rcx,_S14
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf59
; ForEach Shortcuts()
  MOV    rcx,qword [t_Shortcuts]
  CALL   PB_ResetList
_ForEach60:
  MOV    rcx,qword [t_Shortcuts]
  CALL   PB_NextElement
  OR     rax,rax
  JZ    _Next60
; WriteStringN(1, Space(Indent) + "Data.l #DIALOG_Shortcut, " + Shortcuts()\Key$ + ", " + Shortcuts()\ID$) 
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S111
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [t_Shortcuts+8]
  MOV    rcx,qword [rbp+16]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; Next Shortcuts()
  JMP   _ForEach60
_Next60:
; 
; ClearList(Shortcuts()) 
  PUSH   qword [t_Shortcuts]
  POP    rcx
  CALL   PB_ClearList
; WriteStringN(1, Space(Indent) + "Data.l -1") 
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S110
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; WriteStringN(1, "")
  MOV    rax,_S3
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteStringN
; EndIf
_EndIf59:
; 
; EndProcedure
_EndProcedureZero7:
  XOR    rax,rax
_EndProcedure7:
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
; Procedure IsKey(List Args.ArgPair(), Key$)
_Procedure0:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  PUSH   rbp
  PS0=80
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rax,qword [rsp+PS0+0]
  MOV    qword [rsp+40],rax
  MOV    rdx,[rsp+PS0+8]
  LEA    rcx,[rsp+48]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; 
; ForEach Args()
  MOV    rcx,qword [rsp+40]
  CALL   PB_ResetList
_ForEach1:
  MOV    rcx,qword [rsp+40]
  CALL   PB_NextElement
  OR     rax,rax
  JZ    _Next1
; If Args()\Name$ = Key$
  MOV    rax,[rsp+40]
  MOV    rbp,qword [rax+16]
  PUSH   qword [rbp+16]
  MOV    rcx,qword [rsp+56]
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf3
; ProcedureReturn #True 
  MOV    rax,1
  JMP   _EndProcedure1
; EndIf
_EndIf3:
; Next Args()
  JMP   _ForEach1
_Next1:
; 
; ProcedureReturn #False
  XOR    rax,rax
  JMP   _EndProcedure1
; EndProcedure
_EndProcedureZero1:
  XOR    rax,rax
_EndProcedure1:
  PUSH   rax
  MOV    rcx,qword [rsp+56]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  POP    rax
  ADD    rsp,64
  POP    rbp
  RET
; ProcedureC StartElementHandler(user_data, *name, *args.INTEGER)
_Procedure4:
  MOV    qword [rsp+8],rcx
  MOV    qword [rsp+16],rdx
  MOV    qword [rsp+24],r8
  PUSH   rbp
  PUSH   r15
  PS4=144
  MOV    rax,10
.ClearLoop:
  SUB    rsp,8
  MOV    qword [rsp],0
  DEC    rax
  JNZ   .ClearLoop
  SUB    rsp,40
; NewList Args.ArgPair()
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_FreeList
  MOV    r9,7
  MOV    r8,s_argpair
  LEA    rdx,[rsp+40]
  MOV    rcx,16
  CALL   PB_NewList
; 
; Name$ = UCase(PeekS(*name, -1))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword -1
  PUSH   qword [rsp+PS4+56]
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL   PB_PeekS2
  ADD    rsp,32
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+64]
  POP    rdx
  CALL   SYS_AllocateString4
; 
; 
; 
; 
; 
; If Name$ = "DIALOGGROUP"
  PUSH   qword [rsp+56]
  MOV    rcx,_S2
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf7
; ProcedureReturn
  JMP   _EndProcedure5
; EndIf 
_EndIf7:
; 
; 
; 
; While *args\i
_While8:
  MOV    rbp,qword [rsp+PS4+16]
  CMP    qword [rbp],0
  JE    _Wend8
; AddElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_AddElement
; Args()\Name$ = UCase(PeekS(*args\i, -1))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword -1
  MOV    rbp,qword [rsp+PS4+64]
  PUSH   qword [rbp]
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL   PB_PeekS2
  ADD    rsp,32
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  MOV    rbp,qword [rsp+48+8]
  LEA    rcx,[rbp+16]
  POP    rdx
  CALL   SYS_AllocateString4
; *args + SizeOf(INTEGER)
  MOV    r15,qword [rsp+PS4+16]
  ADD    r15,8
  MOV    qword [rsp+PS4+16],r15
; Args()\Value$ = PeekS(*args\i, -1)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword -1
  MOV    rbp,qword [rsp+PS4+48]
  PUSH   qword [rbp]
  POP    rcx
  POP    rdx
  POP    r8
  SUB    rsp,32
  CALL   PB_PeekS2
  ADD    rsp,40
  MOV    rbp,qword [rsp+48+8]
  LEA    rcx,[rbp+24]
  POP    rdx
  CALL   SYS_AllocateString4
; *args + SizeOf(INTEGER)
  MOV    r15,qword [rsp+PS4+16]
  ADD    r15,8
  MOV    qword [rsp+PS4+16],r15
; Wend
  JMP   _While8
_Wend8:
; 
; If PreviousIndent <> Indent
  MOV    r15,qword [v_PreviousIndent]
  CMP    r15,qword [v_Indent]
  JE    _EndIf10
; PreviousIndent = Indent
  PUSH   qword [v_Indent]
  POP    rax
  MOV    qword [v_PreviousIndent],rax
; WriteStringN(1, "")
  MOV    rax,_S3
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteStringN
; EndIf
_EndIf10:
; 
; If Name$ = "COMPILER" 
  PUSH   qword [rsp+56]
  MOV    rcx,_S4
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf12
; If IsKey(Args(), "IF")
  MOV    rax,_S5
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf14
; WriteStringN(1, Space(Indent) + "CompilerIf " + Args()\Value$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S6
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; Else
  JMP   _EndIf13
_EndIf14:
; Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "Invalid compilerif statement!") 
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S7
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [v_parser]
  POP    rcx
  SUB    rsp,32
  CALL   pb_XML_GetCurrentLineNumber
  ADD    rsp,40
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S8
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; EndIf
_EndIf13:
; 
; PreviousIndent = Indent
  PUSH   qword [v_Indent]
  POP    rax
  MOV    qword [v_PreviousIndent],rax
; Indent + 2
  MOV    r15,qword [v_Indent]
  ADD    r15,2
  MOV    qword [v_Indent],r15
; ProcedureReturn 
  JMP   _EndProcedure5
; 
; ElseIf Name$ = "COMPILERELSE"
  JMP   _EndIf11
_EndIf12:
  PUSH   qword [rsp+56]
  MOV    rcx,_S9
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf16
; WriteStringN(1, "")
  MOV    rax,_S3
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteStringN
; WriteStringN(1, Space(Indent-2) + "CompilerElse")
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    r15,qword [v_Indent]
  ADD    r15,-2
  MOV    rax,r15
  PUSH   rax
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S10
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; WriteStringN(1, "")
  MOV    rax,_S3
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteStringN
; ProcedureReturn 
  JMP   _EndProcedure5
; 
; ElseIf Name$ = "SHORTCUT"
  JMP   _EndIf11
_EndIf16:
  PUSH   qword [rsp+56]
  MOV    rcx,_S11
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf17
; AddElement(Shortcuts())
  PUSH   qword [t_Shortcuts]
  POP    rcx
  CALL   PB_AddElement
; If IsKey(Args(), "KEY")
  MOV    rax,_S12
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf19
; Shortcuts()\Key$ = Args()\Value$
  MOV    rbp,qword [rsp+40+8]
  MOV    rcx,qword [rbp+24]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [t_Shortcuts+8]
  LEA    rcx,[rbp+16]
  POP    rdx
  CALL   SYS_AllocateString4
; EndIf
_EndIf19:
; If IsKey(Args(), "ID")
  MOV    rax,_S13
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf21
; Shortcuts()\ID$ = Args()\Value$
  MOV    rbp,qword [rsp+40+8]
  MOV    rcx,qword [rbp+24]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [t_Shortcuts+8]
  LEA    rcx,[rbp+24]
  POP    rdx
  CALL   SYS_AllocateString4
; EndIf
_EndIf21:
; ProcedureReturn 
  JMP   _EndProcedure5
; EndIf
_EndIf11:
_EndIf17:
; 
; Select Name$
  PUSH   qword [rsp+56]
; 
; Case "WINDOW" 
  MOV    rdx,_S14
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case1
; Type$ = "#DIALOG_Window"   
  MOV    rdx,_S15
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; 
; If Indent <> 4 
  MOV    r15,qword [v_Indent]
  CMP    r15,4
  JE    _EndIf23
; Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "WINDOW object must be at the main level!") 
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S7
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [v_parser]
  POP    rcx
  SUB    rsp,32
  CALL   pb_XML_GetCurrentLineNumber
  ADD    rsp,40
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S16
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  POP    qword [PB_StringBasePosition]
; EndIf
_EndIf23:
; 
; If IsKey(Args(), "LABEL")
  SUB    rsp,8
  MOV    rax,_S17
  PUSH   rax
  PUSH   qword [rsp+64]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL  _Procedure0
  ADD    rsp,40
  AND    rax,rax
  JE    _EndIf25
; WriteStringN(1, "  " + Args()\Value$ + ":")
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S18
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S19
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,32
  POP    qword [PB_StringBasePosition]
; DeleteElement(Args())
  SUB    rsp,8
  PUSH   qword [rsp+56]
  POP    rcx
  SUB    rsp,32
  CALL   PB_DeleteElement
  ADD    rsp,40
; Else
  JMP   _EndIf24
_EndIf25:
; Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "WINDOW object must have a LABEL attribute!") 
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S7
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [v_parser]
  POP    rcx
  SUB    rsp,32
  CALL   pb_XML_GetCurrentLineNumber
  ADD    rsp,40
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S20
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  POP    qword [PB_StringBasePosition]
; EndIf     
_EndIf24:
; 
; 
; Case "EMPTY":        Type$ = "#DIALOG_Empty"  
  JMP   _EndSelect1
_Case1:
  MOV    rdx,_S21
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case2
  MOV    rdx,_S22
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "VBOX":         Type$ = "#DIALOG_VBox"
  JMP   _EndSelect1
_Case2:
  MOV    rdx,_S23
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case3
  MOV    rdx,_S24
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "HBOX":         Type$ = "#DIALOG_HBox"
  JMP   _EndSelect1
_Case3:
  MOV    rdx,_S25
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case4
  MOV    rdx,_S26
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "MULTIBOX":     Type$ = "#DIALOG_Multibox"
  JMP   _EndSelect1
_Case4:
  MOV    rdx,_S27
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case5
  MOV    rdx,_S28
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "SINGLEBOX":    Type$ = "#DIALOG_Singlebox"
  JMP   _EndSelect1
_Case5:
  MOV    rdx,_S29
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case6
  MOV    rdx,_S30
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "GRIDBOX":      Type$ = "#DIALOG_Gridbox"    
  JMP   _EndSelect1
_Case6:
  MOV    rdx,_S31
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case7
  MOV    rdx,_S32
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; 
; Case "BUTTON":       Type$ = "#DIALOG_Button"
  JMP   _EndSelect1
_Case7:
  MOV    rdx,_S33
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case8
  MOV    rdx,_S34
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "CHECKBOX":     Type$ = "#DIALOG_Checkbox"
  JMP   _EndSelect1
_Case8:
  MOV    rdx,_S35
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case9
  MOV    rdx,_S36
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "IMAGE":        Type$ = "#DIALOG_Image"
  JMP   _EndSelect1
_Case9:
  MOV    rdx,_S37
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case10
  MOV    rdx,_S38
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "OPTION":       Type$ = "#DIALOG_Option"
  JMP   _EndSelect1
_Case10:
  MOV    rdx,_S39
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case11
  MOV    rdx,_S40
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "LISTVIEW":     Type$ = "#DIALOG_ListView"
  JMP   _EndSelect1
_Case11:
  MOV    rdx,_S41
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case12
  MOV    rdx,_S42
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "LISTICON":     Type$ = "#DIALOG_ListIcon"
  JMP   _EndSelect1
_Case12:
  MOV    rdx,_S43
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case13
  MOV    rdx,_S44
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "TREE":         Type$ = "#DIALOG_Tree"
  JMP   _EndSelect1
_Case13:
  MOV    rdx,_S45
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case14
  MOV    rdx,_S46
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "CONTAINER":    Type$ = "#DIALOG_Container"
  JMP   _EndSelect1
_Case14:
  MOV    rdx,_S47
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case15
  MOV    rdx,_S48
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "COMBOBOX":     Type$ = "#DIALOG_ComboBox"
  JMP   _EndSelect1
_Case15:
  MOV    rdx,_S49
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case16
  MOV    rdx,_S50
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "TEXT":         Type$ = "#DIALOG_Text"
  JMP   _EndSelect1
_Case16:
  MOV    rdx,_S51
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case17
  MOV    rdx,_S52
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "STRING":       Type$ = "#DIALOG_String"
  JMP   _EndSelect1
_Case17:
  MOV    rdx,_S53
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case18
  MOV    rdx,_S54
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "PANEL":        Type$ = "#DIALOG_Panel"
  JMP   _EndSelect1
_Case18:
  MOV    rdx,_S55
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case19
  MOV    rdx,_S56
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "TAB":          Type$ = "#DIALOG_Tab"
  JMP   _EndSelect1
_Case19:
  MOV    rdx,_S57
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case20
  MOV    rdx,_S58
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "SCROLL":       Type$ = "#DIALOG_Scroll"
  JMP   _EndSelect1
_Case20:
  MOV    rdx,_S59
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case21
  MOV    rdx,_S60
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "FRAME":        Type$ = "#DIALOG_Frame"
  JMP   _EndSelect1
_Case21:
  MOV    rdx,_S61
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case22
  MOV    rdx,_S62
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "ITEM":         Type$ = "#DIALOG_Item"
  JMP   _EndSelect1
_Case22:
  MOV    rdx,_S63
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case23
  MOV    rdx,_S64
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "COLUMN":       Type$ = "#DIALOG_Column"
  JMP   _EndSelect1
_Case23:
  MOV    rdx,_S65
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case24
  MOV    rdx,_S66
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "EDITOR":       Type$ = "#DIALOG_Editor"
  JMP   _EndSelect1
_Case24:
  MOV    rdx,_S67
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case25
  MOV    rdx,_S68
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "SCINTILLA":    Type$ = "#DIALOG_Scintilla"
  JMP   _EndSelect1
_Case25:
  MOV    rdx,_S69
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case26
  MOV    rdx,_S70
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "SCROLLBAR":    Type$ = "#DIALOG_ScrollBar"
  JMP   _EndSelect1
_Case26:
  MOV    rdx,_S71
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case27
  MOV    rdx,_S72
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "PROGRESSBAR":  Type$ = "#DIALOG_ProgressBar"
  JMP   _EndSelect1
_Case27:
  MOV    rdx,_S73
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case28
  MOV    rdx,_S74
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "EXPLORERLIST": Type$ = "#DIALOG_ExplorerList"
  JMP   _EndSelect1
_Case28:
  MOV    rdx,_S75
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case29
  MOV    rdx,_S76
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "EXPLORERTREE": Type$ = "#DIALOG_ExplorerTree"
  JMP   _EndSelect1
_Case29:
  MOV    rdx,_S77
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case30
  MOV    rdx,_S78
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "EXPLORERCOMBO":Type$ = "#DIALOG_ExplorerCombo"
  JMP   _EndSelect1
_Case30:
  MOV    rdx,_S79
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case31
  MOV    rdx,_S80
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "SPLITTER":     Type$ = "#DIALOG_Splitter"
  JMP   _EndSelect1
_Case31:
  MOV    rdx,_S81
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case32
  MOV    rdx,_S82
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "SHORTCUTGADGET":Type$ = "#DIALOG_ShortcutGadget"
  JMP   _EndSelect1
_Case32:
  MOV    rdx,_S83
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case33
  MOV    rdx,_S84
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "BUTTONIMAGE":  Type$ = "#DIALOG_ButtonImage"
  JMP   _EndSelect1
_Case33:
  MOV    rdx,_S85
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case34
  MOV    rdx,_S86
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "TRACKBAR":     Type$ = "#DIALOG_TrackBar"
  JMP   _EndSelect1
_Case34:
  MOV    rdx,_S87
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case35
  MOV    rdx,_S88
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; Case "HYPERLINK":    Type$ = "#DIALOG_HyperLink"
  JMP   _EndSelect1
_Case35:
  MOV    rdx,_S89
  MOV    rcx,[rsp]
  SUB    rsp,40
  CALL   SYS_StringEqual
  ADD    rsp,40
  OR     rax,rax
  JE    _Case36
  MOV    rdx,_S90
  LEA    rcx,[rsp+72]
  SUB    rsp,40
  CALL   SYS_FastAllocateStringFree4
  ADD    rsp,40
; 
; Default
  JMP   _EndSelect1
_Case36:
; Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "Unknown Tag: " + PeekS(*name)) 
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S7
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [v_parser]
  POP    rcx
  SUB    rsp,32
  CALL   pb_XML_GetCurrentLineNumber
  ADD    rsp,40
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S91
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+PS4+48]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_PeekS
  ADD    rsp,32
  POP    rax
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+0],rdx
  POP    rcx
  SUB    rsp,32
  CALL  _Procedure2
  ADD    rsp,32
  POP    qword [PB_StringBasePosition]
; 
; EndSelect
_Case37:
_EndSelect1:
  POP    rax
; 
; WriteStringN(1, Space(Indent) + "Data.l " + Type$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S92
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [rsp+88]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; 
; If IsKey(Args(), "ID")
  MOV    rax,_S13
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf28
; WriteString(1, Space(Indent) + "Data.l " + Args()\Value$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S92
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteString
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; Else
  JMP   _EndIf27
_EndIf28:
; WriteString(1, Space(Indent) + "Data.l #PB_Any")
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S93
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteString
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; EndIf
_EndIf27:
; 
; If IsKey(Args(), "FLAGS")
  MOV    rax,_S94
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf31
; WriteString(1, ", " + Args()\Value$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteString
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; ElseIf Name$ = "ITEM" And IsKey(Args(), "SUBLEVEL") 
  JMP   _EndIf30
_EndIf31:
  PUSH   qword [rsp+56]
  MOV    rcx,_S63
  POP    rdx
  CALL   SYS_StringEqual
  OR     rax,rax
  JE     No0
  MOV    rax,_S96
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE     No0
Ok0:
  MOV    rax,1
  JMP    End0
No0:
  XOR    rax,rax
End0:
  AND    rax,rax
  JE    _EndIf32
; WriteString(1, ", " + Args()\Value$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteString
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; Else
  JMP   _EndIf30
_EndIf32:
; WriteString(1, ", 0")
  MOV    rax,_S97
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteString
; EndIf
_EndIf30:
; 
; If IsKey(Args(), "WIDTH")
  MOV    rax,_S98
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf35
; If UCase(Args()\Value$) = "IGNORE"
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rbp,qword [rsp+64+8]
  PUSH   qword [rbp+24]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  MOV    rcx,_S99
  POP    rdx
  MOV    qword [PB_StringBasePosition],rdx
  ADD    rdx,[PB_StringBase]
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf37
; WriteString(1, ", -1") 
  MOV    rax,_S100
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteString
; Else
  JMP   _EndIf36
_EndIf37:
; WriteString(1, ", " + Args()\Value$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteString
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; EndIf
_EndIf36:
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; Else
  JMP   _EndIf34
_EndIf35:
; WriteString(1, ", 0")
  MOV    rax,_S97
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteString
; EndIf
_EndIf34:
; 
; If IsKey(Args(), "HEIGHT")
  MOV    rax,_S101
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf41
; If UCase(Args()\Value$) = "IGNORE"
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rbp,qword [rsp+64+8]
  PUSH   qword [rbp+24]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  MOV    rcx,_S99
  POP    rdx
  MOV    qword [PB_StringBasePosition],rdx
  ADD    rdx,[PB_StringBase]
  CALL   SYS_StringEqual
  OR     rax,rax
  JE    _EndIf43
; WriteString(1, ", -1")
  MOV    rax,_S100
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteString
; Else
  JMP   _EndIf42
_EndIf43:
; WriteString(1, ", " + Args()\Value$)
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteString
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; EndIf  
_EndIf42:
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; Else
  JMP   _EndIf40
_EndIf41:
; WriteString(1, ", 0")
  MOV    rax,_S97
  PUSH   rax
  PUSH   qword 1
  POP    rcx
  POP    rdx
  CALL   PB_WriteString
; EndIf
_EndIf40:
; 
; If IsKey(Args(), "TEXT")
  MOV    rax,_S51
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf47
; LiteralText$ = Args()\Value$
  MOV    rbp,qword [rsp+40+8]
  MOV    rcx,qword [rbp+24]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  LEA    rcx,[rsp+80]
  POP    rdx
  CALL   SYS_AllocateString4
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; EndIf
_EndIf47:
; 
; HasText = 0
  MOV    qword [rsp+80],0
; If IsKey(Args(), "LANG")
  MOV    rax,_S102
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf49
; LanguageGroup$ = StringField(Args()\Value$, 1, ":")
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rax,_S19
  PUSH   rax
  PUSH   qword 1
  MOV    rbp,qword [rsp+80+8]
  PUSH   qword [rbp+24]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_StringField
  ADD    rsp,40
  LEA    rcx,[rsp+96]
  POP    rdx
  CALL   SYS_AllocateString4
; LanguageKey$   = StringField(Args()\Value$, 2, ":")
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rax,_S19
  PUSH   rax
  PUSH   qword 2
  PUSH   qword [rbp+24]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_StringField
  ADD    rsp,40
  LEA    rcx,[rsp+104]
  POP    rdx
  CALL   SYS_AllocateString4
; HasText = 1
  MOV    qword [rsp+80],1
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; EndIf
_EndIf49:
; 
; If IsKey(Args(), "NAME")
  MOV    rax,_S103
  PUSH   rax
  PUSH   qword [rsp+48]
  POP    rcx
  POP    rdx
  CALL  _Procedure0
  AND    rax,rax
  JE    _EndIf51
; ObjectName$ = UCase(Args()\Value$) 
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rbp,qword [rsp+64+8]
  PUSH   qword [rbp+24]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_UCase
  ADD    rsp,40
  LEA    rcx,[rsp+112]
  POP    rdx
  CALL   SYS_AllocateString4
; HasText = 1
  MOV    qword [rsp+80],1
; DeleteElement(Args())
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   PB_DeleteElement
; EndIf
_EndIf51:
; 
; WriteStringN(1, ", " + Str(HasText) + ", " + Str(ListSize(Args())))       
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [rsp+120]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S95
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [rsp+88]
  POP    rcx
  SUB    rsp,32
  CALL   PB_ListSize
  ADD    rsp,40
  MOV    rax,rax
  PUSH   rax
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Str
  ADD    rsp,32
  POP    rax
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; WriteStringN(1, Space(Indent) + "Data.s " + Chr(34)+ObjectName$+Chr(34) + ", " + Chr(34)+ReplaceString(LiteralText$, "%newline%", #NewLineSequence)+Chr(34)+", "+Chr(34)+LanguageGroup$+Chr(34)+", "+Chr(34)+LanguageKey$+Chr(34))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S104
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [rsp+128]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S105
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [PB_StringBasePosition]
  MOV    rax,_S107
  PUSH   rax
  MOV    rax,_S106
  PUSH   rax
  PUSH   qword [rsp+128]
  POP    rcx
  POP    rdx
  POP    r8
  POP    r9
  SUB    rsp,32
  CALL   PB_ReplaceString
  ADD    rsp,32
  POP    rax
  MOV    rcx,_S105
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [rsp+112]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S105
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [rsp+120]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S108
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; 
; ForEach Args()
  MOV    rcx,qword [rsp+40]
  CALL   PB_ResetList
_ForEach52:
  MOV    rcx,qword [rsp+40]
  CALL   PB_NextElement
  OR     rax,rax
  JZ    _Next52
; WriteStringN(1, Space(Indent) + "Data.s " + Chr(34)+Args()\Name$+Chr(34)+", "+Chr(34)+Args()\Value$+Chr(34))
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  SUB    rsp,8
  PUSH   qword [PB_StringBasePosition]
  PUSH   qword [v_Indent]
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_Space
  ADD    rsp,40
  MOV    rcx,_S104
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rbp,qword [rsp+64+8]
  MOV    rcx,qword [rbp+16]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S105
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,qword [rbp+24]
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  MOV    rcx,_S108
  SUB    rsp,40
  CALL   SYS_CopyString
  ADD    rsp,40
  ADD    qword [PB_StringBasePosition],2
  PUSH   qword 1
  MOV    rdx,[PB_StringBase]
  ADD    [rsp+8],rdx
  POP    rcx
  POP    rdx
  SUB    rsp,32
  CALL   PB_WriteStringN
  ADD    rsp,40
  POP    qword [PB_StringBasePosition]
; Next Args()
  JMP   _ForEach52
_Next52:
; 
; PreviousIndent = Indent
  PUSH   qword [v_Indent]
  POP    rax
  MOV    qword [v_PreviousIndent],rax
; Indent + 2
  MOV    r15,qword [v_Indent]
  ADD    r15,2
  MOV    qword [v_Indent],r15
; 
; EndProcedure
_EndProcedureZero5:
  XOR    rax,rax
_EndProcedure5:
  PUSH   rax
  MOV    rcx,qword [rsp+96]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  MOV    rcx,qword [rsp+112]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  MOV    rcx,qword [rsp+72]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  MOV    rcx,qword [rsp+104]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  MOV    rcx,qword [rsp+64]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  MOV    rcx,qword [rsp+80]
  SUB    rsp,40
  CALL   SYS_FreeString
  ADD    rsp,40
  PUSH   qword [rsp+48]
  POP    rcx
  SUB    rsp,40
  CALL   PB_FreeList
  ADD    rsp,40
  POP    rax
  ADD    rsp,120
  POP    r15
  POP    rbp
  RET
; Procedure Error(Message$)
_Procedure2:
  MOV    qword [rsp+8],rcx
  PS2=64
  XOR    rax,rax
  PUSH   rax
  PUSH   rax
  SUB    rsp,40
  MOV    rdx,[rsp+PS2+0]
  LEA    rcx,[rsp+40]
  SUB    rsp,16
  CALL   SYS_FastAllocateString4
  ADD    rsp,16
; Shared Output$
; OpenConsole()
  CALL   PB_OpenConsole
; PrintN(Message$) 
  PUSH   qword [rsp+40]
  POP    rcx
  CALL   qword [PB_PrintN]
; CloseConsole()
  CALL   PB_CloseConsole
; CompilerIf #PB_Compiler_OS = #PB_OS_Windows
; MessageRequester("DialogCompiler", Message$)
  PUSH   qword [rsp+40]
  MOV    rax,_S1
  PUSH   rax
  POP    rcx
  POP    rdx
  CALL   PB_MessageRequester
; CompilerEndIf
; If IsFile(1)
  PUSH   qword 1
  POP    rcx
  CALL   PB_IsFile
  AND    rax,rax
  JE    _EndIf5
; CloseFile(1)
  PUSH   qword 1
  POP    rcx
  CALL   PB_CloseFile
; EndIf
_EndIf5:
; DeleteFile(Output$)
  PUSH   qword [v_Output$]
  POP    rcx
  CALL   PB_DeleteFile
; End #EXIT_FAILURE
  MOV    rax,1
  MOV    [PB_ExitCode],rax
  JMP   _PB_EOP
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
  ADD    rsp,56
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
_S18: dw 32,32,0
_S3: dw 0
_S113: dw 77,101,109,111,114,121,32,69,114,114,111,114,0
_S2: dw 68,73,65,76,79,71,71,82,79,85,80,0
_S108: dw 34,0
_S24: dw 35,68,73,65,76,79,71,95,86,66,111,120,0
_S53: dw 83,84,82,73,78,71,0
_S83: dw 83,72,79,82,84,67,85,84,71,65,68,71,69,84,0
_S46: dw 35,68,73,65,76,79,71,95,84,114,101,101,0
_S43: dw 76,73,83,84,73,67,79,78,0
_S100: dw 44,32,45,49,0
_S117: dw 59,32,68,111,32,110,111,116,32,101,100,105,116,33,0
_S19: dw 58,0
_S114: dw 59,0
_S12: dw 75,69,89,0
_S121: dw 69,110,100,68,97,116,97,83,101,99,116,105,111,110,0
_S89: dw 72,89,80,69,82,76,73,78,75,0
_S90: dw 35,68,73,65,76,79,71,95,72,121,112,101,114,76,105,110,107,0
_S36: dw 35,68,73,65,76,79,71,95,67,104,101,99,107,98,111,120,0
_S41: dw 76,73,83,84,86,73,69,87,0
_S29: dw 83,73,78,71,76,69,66,79,88,0
_S30: dw 35,68,73,65,76,79,71,95,83,105,110,103,108,101,98,111,120,0
_S86: dw 35,68,73,65,76,79,71,95,66,117,116,116,111,110,73,109,97,103,101,0
_S106: dw 37,110,101,119,108,105,110,101,37,0
_S10: dw 67,111,109,112,105,108,101,114,69,108,115,101,0
_S9: dw 67,79,77,80,73,76,69,82,69,76,83,69,0
_S77: dw 69,88,80,76,79,82,69,82,84,82,69,69,0
_S60: dw 35,68,73,65,76,79,71,95,83,99,114,111,108,108,0
_S47: dw 67,79,78,84,65,73,78,69,82,0
_S11: dw 83,72,79,82,84,67,85,84,0
_S94: dw 70,76,65,71,83,0
_S48: dw 35,68,73,65,76,79,71,95,67,111,110,116,97,105,110,101,114,0
_S58: dw 35,68,73,65,76,79,71,95,84,97,98,0
_S25: dw 72,66,79,88,0
_S28: dw 35,68,73,65,76,79,71,95,77,117,108,116,105,98,111,120,0
_S39: dw 79,80,84,73,79,78,0
_S73: dw 80,82,79,71,82,69,83,83,66,65,82,0
_S79: dw 69,88,80,76,79,82,69,82,67,79,77,66,79,0
_S80: dw 35,68,73,65,76,79,71,95,69,120,112,108,111,114,101,114,67,111,109,98,111,0
_S4: dw 67,79,77,80,73,76,69,82,0
_S31: dw 71,82,73,68,66,79,88,0
_S103: dw 78,65,77,69,0
_S44: dw 35,68,73,65,76,79,71,95,76,105,115,116,73,99,111,110,0
_S34: dw 35,68,73,65,76,79,71,95,66,117,116,116,111,110,0
_S17: dw 76,65,66,69,76,0
_S42: dw 35,68,73,65,76,79,71,95,76,105,115,116,86,105,101,119,0
_S81: dw 83,80,76,73,84,84,69,82,0
_S66: dw 35,68,73,65,76,79,71,95,67,111,108,117,109,110,0
_S78: dw 35,68,73,65,76,79,71,95,69,120,112,108,111,114,101,114,84,114,101,101,0
_S59: dw 83,67,82,79,76,76,0
_S26: dw 35,68,73,65,76,79,71,95,72,66,111,120,0
_S68: dw 35,68,73,65,76,79,71,95,69,100,105,116,111,114,0
_S87: dw 84,82,65,67,75,66,65,82,0
_S93: dw 68,97,116,97,46,108,32,35,80,66,95,65,110,121,0
_S120: dw 41,58,32,0
_S63: dw 73,84,69,77,0
_S119: dw 80,97,114,115,101,114,32,69,114,114,111,114,32,40,76,105,110,101,32,0
_S8: dw 41,58,32,73,110,118,97,108,105,100,32,99,111,109,112,105,108,101,114,105,102,32,115,116,97,116,101,109,101,110,116,33,0
_S21: dw 69,77,80,84,89,0
_S22: dw 35,68,73,65,76,79,71,95,69,109,112,116,121,0
_S13: dw 73,68,0
_S97: dw 44,32,48,0
_S5: dw 73,70,0
_S101: dw 72,69,73,71,72,84,0
_S33: dw 66,85,84,84,79,78,0
_S37: dw 73,77,65,71,69,0
_S96: dw 83,85,66,76,69,86,69,76,0
_S38: dw 35,68,73,65,76,79,71,95,73,109,97,103,101,0
_S51: dw 84,69,88,84,0
_S82: dw 35,68,73,65,76,79,71,95,83,112,108,105,116,116,101,114,0
_S85: dw 66,85,84,84,79,78,73,77,65,71,69,0
_S61: dw 70,82,65,77,69,0
_S65: dw 67,79,76,85,77,78,0
_S62: dw 35,68,73,65,76,79,71,95,70,114,97,109,101,0
_S75: dw 69,88,80,76,79,82,69,82,76,73,83,84,0
_S104: dw 68,97,116,97,46,115,32,34,0
_S57: dw 84,65,66,0
_S88: dw 35,68,73,65,76,79,71,95,84,114,97,99,107,66,97,114,0
_S112: dw 70,105,108,101,32,73,47,79,32,69,114,114,111,114,0
_S67: dw 69,68,73,84,79,82,0
_S15: dw 35,68,73,65,76,79,71,95,87,105,110,100,111,119,0
_S115: dw 59,32,80,117,114,101,66,97,115,105,99,32,73,68,69,32,45,32,68,105,97,108,111,103,32,77,97,110,97,103,101,114,32,102,105,108,101,0
_S95: dw 44,32,0
_S49: dw 67,79,77,66,79,66,79,88,0
_S64: dw 35,68,73,65,76,79,71,95,73,116,101,109,0
_S116: dw 59,32,65,117,116,111,103,101,110,101,114,97,116,101,100,32,102,114,111,109,32,34,0
_S74: dw 35,68,73,65,76,79,71,95,80,114,111,103,114,101,115,115,66,97,114,0
_S107: dw 34,43,67,104,114,40,49,51,41,43,67,104,114,40,49,48,41,43,34,0
_S54: dw 35,68,73,65,76,79,71,95,83,116,114,105,110,103,0
_S98: dw 87,73,68,84,72,0
_S84: dw 35,68,73,65,76,79,71,95,83,104,111,114,116,99,117,116,71,97,100,103,101,116,0
_S32: dw 35,68,73,65,76,79,71,95,71,114,105,100,98,111,120,0
_S23: dw 86,66,79,88,0
_S110: dw 68,97,116,97,46,108,32,45,49,0
_S45: dw 84,82,69,69,0
_S6: dw 67,111,109,112,105,108,101,114,73,102,32,0
_S52: dw 35,68,73,65,76,79,71,95,84,101,120,116,0
_S69: dw 83,67,73,78,84,73,76,76,65,0
_S118: dw 68,97,116,97,83,101,99,116,105,111,110,0
_S70: dw 35,68,73,65,76,79,71,95,83,99,105,110,116,105,108,108,97,0
_S35: dw 67,72,69,67,75,66,79,88,0
_S55: dw 80,65,78,69,76,0
_S111: dw 68,97,116,97,46,108,32,35,68,73,65,76,79,71,95,83,104,111,114,116,99,117,116,44,32,0
_S105: dw 34,44,32,34,0
_S16: dw 41,58,32,87,73,78,68,79,87,32,111,98,106,101,99,116,32,109,117,115,116,32,98,101,32,97,116,32,116,104,101,32,109,97,105,110,32,108,101,118,101,108,33,0
_S56: dw 35,68,73,65,76,79,71,95,80,97,110,101,108,0
_S76: dw 35,68,73,65,76,79,71,95,69,120,112,108,111,114,101,114,76,105,115,116,0
_S1: dw 68,105,97,108,111,103,67,111,109,112,105,108,101,114,0
_S99: dw 73,71,78,79,82,69,0
_S109: dw 67,111,109,112,105,108,101,114,69,110,100,73,102,0
_S7: dw 83,121,110,116,97,120,32,69,114,114,111,114,32,40,76,105,110,101,32,0
_S71: dw 83,67,82,79,76,76,66,65,82,0
_S20: dw 41,58,32,87,73,78,68,79,87,32,111,98,106,101,99,116,32,109,117,115,116,32,104,97,118,101,32,97,32,76,65,66,69,76,32,97,116,116,114,105,98,117,116,101,33,0
_S72: dw 35,68,73,65,76,79,71,95,83,99,114,111,108,108,66,97,114,0
_S27: dw 77,85,76,84,73,66,79,88,0
_S91: dw 41,58,32,85,110,107,110,111,119,110,32,84,97,103,58,32,0
_S40: dw 35,68,73,65,76,79,71,95,79,112,116,105,111,110,0
_S102: dw 76,65,78,71,0
_S14: dw 87,73,78,68,79,87,0
_S50: dw 35,68,73,65,76,79,71,95,67,111,109,98,111,66,111,120,0
_S92: dw 68,97,116,97,46,108,32,0
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
s_argpair:
  dq     0
  dq     8
  dq     -1
s_shortcut:
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
v_parser rq 1
v_buffer rq 1
v_Output$ rq 1
PB_DataPointer rq 1
v_Indent rq 1
v_length rq 1
v_PreviousIndent rq 1
v_Input$ rq 1
pb_bssalign 8
pb_bssalign 8
pb_bssalign 8
pb_bssalign 8
t_Shortcuts rq 2
I_BSSEnd:
section '.data' data readable writeable
SYS_EndDataSection:
