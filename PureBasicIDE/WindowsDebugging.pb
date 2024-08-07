; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

CompilerIf #CompileWindows
  
  CompilerIf #DEBUG
    
     CompilerIf #PB_Compiler_Backend = #PB_Backend_C
      ; Do Nothing as we can't easily access externals vars for now (should be added in a future PB version)
      ;
    CompilerElse
      ; It's used in debugging.pb as well, so declare them in the global scope
      CompilerIf #CompileX86
        !extrn _PB_StringHeap
        !extrn _PB_Memory_Heap
      CompilerElse
        !extrn PB_StringHeap
        !extrn PB_Memory_Heap
      CompilerEndIf
    CompilerEndIf
    
    ; For easier bug hunting (use with GetLastError_() for example
    ;
    Procedure WindowsError(Code.l)
      Buffer$ = Space(1000)
      FormatMessage_(#FORMAT_MESSAGE_IGNORE_INSERTS|#FORMAT_MESSAGE_FROM_SYSTEM, 0, Code, 0, @Buffer$, 1000, 0)
      MessageRequester("Error", "Code: " + Str(Code) + #NewLine + "Message: " + Buffer$)
    EndProcedure
    
    ; Declare a macro which can helps a lot to localize weird bugs
    ;
    Procedure _TestHeaps(File$, Line)
      Protected StringHeap, MemoryBase, MemoryHeap
      
      CompilerIf #PB_Compiler_Backend = #PB_Backend_C
        ; Do Nothing as we can't easily access externals vars for now (should be added in a future PB version)
        ;
      CompilerElse
        
        CompilerIf #CompileX86
          !mov eax, dword [_PB_StringHeap]
          !mov [p.v_StringHeap], eax
          !mov eax, dword [_PB_MemoryBase]
          !mov [p.v_MemoryBase], eax
          !mov eax, dword [_PB_Memory_Heap]
          !mov [p.v_MemoryHeap], eax
        CompilerElse
          !mov rax, qword [PB_StringHeap]
          !mov [p.v_StringHeap], rax
          !mov rax, qword [_PB_MemoryBase]
          !mov [p.v_MemoryBase], rax
          !mov rax, qword [PB_Memory_Heap]
          !mov [p.v_MemoryHeap], rax
        CompilerEndIf
      
        If HeapValidate_(StringHeap, 0, 0) = 0
          MessageRequester("StringHeap corrupted !", File$+" : "+Str(Line))
        EndIf
        
        If HeapValidate_(MemoryBase, 0, 0) = 0
          MessageRequester("MemoryBase heap corrupted !", File$+" : "+Str(Line))
        EndIf
        
        If HeapValidate_(MemoryHeap, 0, 0) = 0
          MessageRequester("AllocateMemory heap corrupted !", File$+" : "+Str(Line))
        EndIf
      CompilerEndIf
    EndProcedure
        
    Macro TestHeaps
      _TestHeaps(#PB_Compiler_File, #PB_Compiler_Line)
    EndMacro
    
  CompilerEndIf
  
CompilerEndIf