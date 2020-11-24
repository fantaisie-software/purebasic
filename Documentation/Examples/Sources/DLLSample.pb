;
; ------------------------------------------------------------
;
;   PureBasic - DLL example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;
; This example is a skeleton to build easely a DLL using PureBasic
; The dll is created in the 'Compilers' directory, under the
; 'purebasic.dll' name. An associated '.lib' is generated to use
; with VisualC++.
;
;
; Rules to follow:
;   - Never write code outside a procedure, except for variables
;   or structure declaration.
;
;   - DirectX Init routines must not be initialized in the the
;   AttachProcess() procedure
;
;   - There is 4 procedures automatically called: AttachProcess(),
;   DetachProcess(), AttachThread() and DetachThread(). If you don't
;   need them, just remove them.
;

#TESTDLL = 0

CompilerIf #TESTDLL = 0

  CompilerIf #PB_Compiler_OS = #PB_OS_Windows

    ; These 4 procedures are Windows specific
    ;

    ; This procedure is called once, when the program loads the library
    ; for the first time. All init stuffs can be done here (but not DirectX init)
    ;
    ProcedureDLL AttachProcess(Instance)
    EndProcedure
  
  
    ; Called when the program release (free) the DLL
    ;
    ProcedureDLL DetachProcess(Instance)
    EndProcedure
  
  
    ; Both are called when a thread in a program call or release (free) the DLL
    ;
    ProcedureDLL AttachThread(Instance)
    EndProcedure
  
    ProcedureDLL DetachThread(Instance)
    EndProcedure

  CompilerEndIf

  ; Real code start here..
  ;
  ProcedureDLL EasyRequester(Message$)

    MessageRequester("EasyRequester !", Message$)

  EndProcedure

CompilerElse

  If OpenLibrary(0, "PureBasic.dll") Or OpenLibrary(0, "PureBasic.so")
    CallFunction(0, "EasyRequester", @"Test")
  EndIf
    
CompilerEndIf
