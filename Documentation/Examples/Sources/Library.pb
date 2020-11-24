;
; ------------------------------------------------------------
;
;   PureBasic - Library
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

CompilerSelect #PB_Compiler_OS
 
  CompilerCase #PB_OS_Windows

      If OpenLibrary(0, "USER32.DLL")
        
        *MessageBox = GetFunction(0, "MessageBoxW")
        If *MessageBox
          CallFunctionFast(*MessageBox, 0, @"Body", @"Title", 0)
        EndIf
       
        CloseLibrary(0)
      EndIf


  CompilerCase #PB_OS_Linux

      If OpenLibrary(0, "libc.so")
     
        *MAlloc = GetFunction(0, "malloc")
        If *MAlloc
          *Buffer = CallCFunctionFast(*MAlloc, 128)
          If *Buffer
            Debug "Buffer allocated"

            CallCFunction(0, "free", *Buffer)

          EndIf
        EndIf
     
        CloseLibrary(0)
      EndIf

  CompilerCase #PB_OS_MacOS

      If OpenLibrary(0, "libc.dylib")
     
        *MAlloc = GetFunction(0, "malloc")
        If *MAlloc
          *Buffer = CallCFunctionFast(*MAlloc, 128)
          If *Buffer
            Debug "Buffer allocated"

            CallCFunction(0, "free", *Buffer)

          EndIf
        EndIf
     
        CloseLibrary(0)
      EndIf

CompilerEndSelect
