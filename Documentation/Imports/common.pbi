
Macro DQuoteM
  "
EndMacro

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86

  ; Api() define a regular import on the OS
  ;
  CompilerSelect #PB_Compiler_OS

    CompilerCase #PB_OS_Windows

      Macro Api(Name, Args, CallSize)
        Name#_#Args As DQuoteM#_#Name@CallSize#DQuoteM
      EndMacro

      Macro ApiC(Name, Args)
        Name#_#Args As DQuoteM#_#Name#DQuoteM
      EndMacro

      ; AnsiWide() macro define a wide function (FunctionNameW) in unicode mode and
      ; and Ansi function (FunctionNameA) in ASCII mode
      ;
      CompilerIf #PB_Compiler_Unicode
      
        Macro AnsiWide(Name, Args, CallSize)
          Name#_#Args As DQuoteM#_#Name#W@CallSize#DQuoteM
        EndMacro

        ; Wierd version which doesn't include "A" at the end in ANSI mode
        ;
        Macro AnsiWideWierd(Name, Args, CallSize)
          Name#_#Args As DQuoteM#_#Name#W@CallSize#DQuoteM
        EndMacro
        
      CompilerElse
        
        Macro AnsiWide(Name, Args, CallSize)
          Name#_#Args As DQuoteM#_#Name#A@CallSize#DQuoteM
        EndMacro
        
        ; Wierd version which doesn't include "A" at the end in ANSI mode
        ;
        Macro AnsiWideWierd(Name, Args, CallSize)
          Name#_#Args As DQuoteM#_#Name#@CallSize#DQuoteM
        EndMacro

      CompilerEndIf
      
      ; Wide() macro always define a wide function (FunctionNameW). Some function in Windows doesn't have an Ansi version
      ;
      Macro Wide(Name, Args, CallSize)
        Name#_#Args As DQuoteM#_#Name#W@CallSize#DQuoteM
      EndMacro

  CompilerCase #PB_OS_MacOS

    Macro Api(Name, Args, CallSize)
      Name#_#Args As DQuoteM#_#Name#DQuoteM
    EndMacro

    Macro ApiC(Name, Args)
      Name#_#Args As DQuoteM#_#Name#DQuoteM
    EndMacro

  CompilerCase #PB_OS_Linux

    Macro Api(Name, Args, CallSize)
      Name#_#Args As DQuoteM#Name#DQuoteM
    EndMacro

    Macro ApiC(Name, Args)
      Name#_#Args As DQuoteM#Name#DQuoteM
    EndMacro

  CompilerEndSelect

CompilerElse ; x64, arm32, arm64

  ; AnsiWide() macro define a wide function (FunctionNameW) in unicode mode and
  ; and Ansi function (FunctionNameA) in ASCII mode
  ;
  CompilerIf #PB_Compiler_Unicode
  
    Macro AnsiWide(Name, Args, CallSize)
      Name#_#Args As DQuoteM#Name#W#DQuoteM
    EndMacro
    
    ; Wierd version which doesn't include "A" at the end in ANSI mode
    ;
    Macro AnsiWideWierd(Name, Args, CallSize)
      Name#_#Args As DQuoteM#Name#W#DQuoteM
    EndMacro
    
  CompilerElse
    
    Macro AnsiWide(Name, Args, CallSize)
      Name#_#Args As DQuoteM#Name#A#DQuoteM
    EndMacro

    ; Wierd version which doesn't include "A" at the end in ANSI mode
    ;
    Macro AnsiWideWierd(Name, Args, CallSize)
      Name#_#Args As DQuoteM#Name#DQuoteM
    EndMacro
    
  CompilerEndIf
  
  ; Wide() macro always define a wide function (FunctionNameW). Some function in Windows doesn't have an Ansi version
  ;
  Macro Wide(Name, Args, CallSize)
    Name#_#Args As DQuoteM#Name#W#DQuoteM
  EndMacro
  
  ; Api() define a regular import on the OS (same as ApiC() on Linux and OS X)
  ;
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Macro Api(Name, Args, CallSize)
      Name#_#Args As DQuoteM#_#Name#DQuoteM
    EndMacro
  CompilerElse
    Macro Api(Name, Args, CallSize)
      Name#_#Args As DQuoteM#Name#DQuoteM
    EndMacro
  CompilerEndIf

  ; ApiC() macro
  ;
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    Macro ApiC(Name, Args)
      Name#_#Args As DQuoteM#_#Name#DQuoteM
    EndMacro
  CompilerElse
    Macro ApiC(Name, Args)
      Name#_#Args As DQuoteM#Name#DQuoteM
    EndMacro
  CompilerEndIf
    
CompilerEndIf
