;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


; Returns the size of the value of type at *pointer in
; the data that comes from the debugger.
;
; Note: structures return 0, as they are not presented as a single value,
;   but only as its structure fields
;
; Handles array, list, map etc
;
Procedure GetValueSize(type, *Pointer, Is64bit)
  If IS_POINTER(type) Or IS_INTEGER(type)
    If Is64bit
      ProcedureReturn 8
    Else
      ProcedureReturn 4
    EndIf
  Else
    Select type & #TYPEMASK
      Case #TYPE_BYTE, #TYPE_ASCII:   ProcedureReturn 1
      Case #TYPE_WORD, #TYPE_UNICODE: ProcedureReturn 2
      Case #TYPE_LONG:      ProcedureReturn 4
      Case #TYPE_STRUCTURE: ProcedureReturn 0 ; has no value
      Case #TYPE_FLOAT:     ProcedureReturn 4
      Case #TYPE_CHARACTER: ProcedureReturn 4 ; its translated into a long actually
      Case #TYPE_DOUBLE:    ProcedureReturn 8
      Case #TYPE_QUAD:      ProcedureReturn 8
        
        ; strings are stored in the format of the external debugger
      Case #TYPE_FIXEDSTRING,  #TYPE_STRING
        ProcedureReturn MemoryStringLengthBytes(*Pointer) + #CharSize
        
      Case #TYPE_ARRAY
        ; string with dimensions (ascii)
        ProcedureReturn MemoryAsciiLength(*Pointer) + 1
        
      Case #TYPE_LINKEDLIST
        ; size, current element (both integer)
        If Is64bit
          ProcedureReturn 8*2
        Else
          ProcedureReturn 4*2
        EndIf
        
      Case #TYPE_MAP
        ; size (integer), iscurrent (byte), current element (external)
        If Is64bit
          Size = 8
        Else
          Size = 4
        EndIf
        If PeekB(*Pointer + Size)  ; IsCurrent
          ProcedureReturn Size + 1 + MemoryStringLengthBytes(*Pointer + Size + 1) + #CharSize
        Else
          ProcedureReturn Size + 1
        EndIf
        
    EndSelect
  EndIf
EndProcedure


; Specify the type to detect "ByRef" parameters (for Array,List,Map)
Procedure.s ScopeName(scope, type = 0)
  Select scope
    Case #SCOPE_MAIN
      ProcedureReturn "Main"
      
    Case #SCOPE_GLOBAL
      ProcedureReturn "Global"
      
    Case #SCOPE_THREADED
      ProcedureReturn "Threaded"
      
    Case #SCOPE_LOCAL
      If IS_PARAMETER(type)
        ProcedureReturn "ByRef"
      Else
        ProcedureReturn "Local"
      EndIf
      
    Case #SCOPE_STATIC
      ProcedureReturn "Static"
      
    Case #SCOPE_SHARED
      ProcedureReturn "Shared"
      
    Case #SCOPE_PARAMETER
      ProcedureReturn "ByRef"  ; for the WatchList only!
      
    Default
      ProcedureReturn ""
  EndSelect
EndProcedure

; prefix a module name if it is not empty
Procedure.s ModuleName(Name$, ModuleName$)
  If ModuleName$ = ""
    ProcedureReturn Name$
  Else
    ProcedureReturn ModuleName$ + "::" + Name$
  EndIf
EndProcedure

Procedure.s GetDebuggerFile(*Debugger.DebuggerData, LineNumber)
  
  FileNumber = (LineNumber >> 24) & $FF
  If FileNumber > *Debugger\NbIncludedFiles
    ProcedureReturn ""
  ElseIf FileNumber = 0
    ProcedureReturn *Debugger\FileName$
  Else
    *Pointer = *Debugger\IncludedFiles
    For i = 0 To FileNumber ; count from 0 to skip the "sourcepath" at the start
      *Pointer + MemoryAsciiLength(*Pointer) + 1
    Next i
    
    FileName$ = PeekAscii(*Pointer)
    
    ; NOTE: the FileName$ can contain "../", so we need to remove this
    ;
    *Cursor.Character = @FileName$
    While *Cursor\c
      
      If *Cursor\c = Asc(#Separator)
        If PeekS(*Cursor, 4) = #Separator + ".." + #Separator
          ; remove the previous directory name
          *BackCursor.Character = *Cursor - #CharSize
          While *BackCursor >= @FileName$
            If *BackCursor\c = Asc(#Separator)
              Break
            EndIf
            *BackCursor - #CharSize
          Wend
          
          If *BackCursor < @FileName$
            ; oops, more ".." in the string than directories!
            ProcedureReturn ""
          EndIf
          
          ; poking in the string is ok, since it can only get shorter by this
          PokeS(*BackCursor, PeekS(*Cursor + 3*#CharSize))
          
          ; Make sure the cursor stays inside the string.
          ; Otherwise, if removing a large dir towards the string end, *Cursor might
          ; end up outside of the valid string and create an endless loop
          *Cursor = *BackCursor
          
        ElseIf PeekS(*Cursor, 3) = #Separator + "." + #Separator
          ; simply remove this reference to the own directory
          PokeS(*Cursor, PeekS(*Cursor + 2*#CharSize))
          
        Else
          *Cursor + #CharSize
        EndIf
        
      Else
        *Cursor + #CharSize
      EndIf
    Wend
    
    ProcedureReturn FileName$
    
  EndIf
  
EndProcedure

Procedure.s GetDebuggerRelativeFile(*Debugger.DebuggerData, LineNumber)
  FileName$ = GetDebuggerFile(*Debugger, LineNumber)
  
  If *Debugger\IncludedFiles
    SourcePath$ = PeekAscii(*Debugger\IncludedFiles) ; first is the source path
    FileName$ = CreateRelativePath(SourcePath$, FileName$)
  EndIf
  
  If FileName$ = ""
    ProcedureReturn Language("FileStuff","NewSource")
  EndIf
  
  ProcedureReturn FileName$
EndProcedure


; get a string representation of the flags register
;
; /* Flags register
;       |11|10|F|E|D|C|B|A|9|8|7|6|5|4|3|2|1|0|
;         |  | | | | | | | | | | | | | | | | '---  CF Carry Flag
;         |  | | | | | | | | | | | | | | | '---  1
;         |  | | | | | | | | | | | | | | '---  PF Parity Flag
;         |  | | | | | | | | | | | | | '---  0
;         |  | | | | | | | | | | | | '---  AF Auxiliary Flag
;         |  | | | | | | | | | | | '---  0
;         |  | | | | | | | | | | '---  ZF Zero Flag
;         |  | | | | | | | | | '---  SF Sign Flag
;         |  | | | | | | | | '---  TF Trap Flag  (Single Step)
;         |  | | | | | | | '---  IF Interrupt Flag
;         |  | | | | | | '---  DF Direction Flag
;         |  | | | | | '---  OF Overflow flag
;         |  | | | | '--- ?
;         |  | | | '---  IOPL I/O Privilege Level  (286+ only)
;         |  | | '---  NT Nested Task Flag  (286+ only)
;         |  | '---  0
;         |  '---  RF Resume Flag (386+ only)
;         '----  VM  Virtual Mode Flag (386+ only)
; */
; Procedure.s GetFlagsRegisterString(Flags.l)
;   Result$ = ""
;
;   If Flags & 1<< 0: Result$ + "CF, ": EndIf
;   If Flags & 1<< 2: Result$ + "PF, ": EndIf
;   If Flags & 1<< 4: Result$ + "AF, ": EndIf
;   If Flags & 1<< 6: Result$ + "ZF, ": EndIf
;   If Flags & 1<< 7: Result$ + "SF, ": EndIf
;   If Flags & 1<< 8: Result$ + "TF, ": EndIf
;   If Flags & 1<< 9: Result$ + "IF, ": EndIf
;   If Flags & 1<<10: Result$ + "DF, ": EndIf
;   If Flags & 1<<11: Result$ + "OF, ": EndIf
;   If Flags & 1<<13: Result$ + "IOPL, ": EndIf
;   If Flags & 1<<14: Result$ + "NT, ": EndIf
;   If Flags & 1<<16: Result$ + "RF, ": EndIf
;   If Flags & 1<<17: Result$ + "VM, ": EndIf
;
;   If Result$ = ""
;     ProcedureReturn ""
;   Else
;     ProcedureReturn Left(Result$, Len(Result$)-2) ;  cut the last ", "
;   EndIf
;
; EndProcedure

; Val for hex values
;
Procedure ValHex(String$)
  String$ = UCase(String$)
  *Cursor.Character = @String$
  Result = 0
  
  While *Cursor\c
    Result << 4
    If *Cursor\c >= '0' And *Cursor\c <= '9'
      Result + *Cursor\c - '0'
    ElseIf *Cursor\c >= 'A' And *Cursor\c <= 'F'
      Result + *Cursor\c - 'A' + 10
    Else
      Break
    EndIf
    *Cursor + #CharSize
  Wend
  
  ProcedureReturn Result
EndProcedure

; replacements for the normal functions in Debug output/variable viewer and such
; for now it just cuts any remaining 0's, but this can easily be extended
; to allow other display of floats too (like 123e-5 or something)
;
Procedure.s StrF_Debug(Value.f)
  String$ = StrF(Value, 14) ; 14 digits should be ok for normal float
  If FindString(String$, ".", 1) = 0
    ProcedureReturn String$
  Else
    length = Len(String$)
    While Mid(String$, length, 1) = "0"
      length - 1
    Wend
    If Mid(String$, length, 1) = "."
      length + 1
    EndIf
    ProcedureReturn Left(String$, length)
  EndIf
EndProcedure

Procedure.s StrD_Debug(Value.d, Digits = 25)
  String$ = StrD(Value, Digits)
  If FindString(String$, ".", 1) = 0
    ProcedureReturn String$
  Else
    length = Len(String$)
    While Mid(String$, length, 1) = "0"
      length - 1
    Wend
    If Mid(String$, length, 1) = "."
      length + 1
    EndIf
    ProcedureReturn Left(String$, length)
  EndIf
EndProcedure

Procedure.s StrD_Science(Value.d)
  abs.d = Abs(Value)
  exp.i = 0
  
  If Value = 0.0
    ProcedureReturn "0"
    
  ElseIf abs >= 1.0 And abs < 10.0
    ProcedureReturn StrD_Debug(Value)
    
  ElseIf abs < 1.0
    While abs < 1.0
      abs * 10.0
      Value * 10.0
      exp + 1
    Wend
    ProcedureReturn StrD_Debug(Value, 10) + "E-" + Str(exp)
    
  Else
    While abs >= 10.0
      abs / 10.0
      Value / 10.0
      exp + 1
    Wend
    ProcedureReturn StrD_Debug(Value, 10) + "E" + Str(exp)
    
  EndIf
  
EndProcedure

Procedure.s DebuggerTitle(FileName$)
  If DisplayFullPath
    ProcedureReturn FileName$
  Else
    ProcedureReturn GetFilePart(FileName$)
  EndIf
EndProcedure