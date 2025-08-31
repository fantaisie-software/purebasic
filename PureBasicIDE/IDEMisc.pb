; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; ide specific misc stuff (not shared with the Debugger)
;



Procedure.s CheckPureBasicKeyWords(CurrentWord$)
  
  If Right(CurrentWord$, 1) = "$"
    CurrentWord$ = Left(CurrentWord$, Len(CurrentWord$)-1)
  EndIf
  
  Select UCase(CurrentWord$)
    Case "FOR", "TO", "STEP", "NEXT"
      Topic$ = "Reference/for_next"
      
    Case "FOREACH"
      Topic$ = "Reference/foreach_next"
      
    Case "GOSUB", "RETURN", "FAKERETURN"
      Topic$ = "Reference/gosub_return"
      
    Case "IF", "ELSEIF", "ELSE", "ENDIF"
      Topic$ = "Reference/if_endif"
      
    Case "REPEAT", "UNTIL", "FOREVER"
      Topic$ = "Reference/repeat_until"
      
    Case "SELECT", "CASE", "DEFAULT", "ENDSELECT"
      Topic$ = "Reference/select_endselect"
      
    Case "WHILE", "WEND"
      Topic$ = "Reference/while_wend"
      
    Case "GOTO", "END", "SWAP"
      Topic$ = "Reference/others"
      
    Case "DEFINE"
      Topic$ = "Reference/define"
      
    Case "DIM", "REDIM", "ARRAY"
      Topic$ = "Reference/dim"
      
    Case "MACRO", "ENDMACRO", "UNDEFINEMACRO", "MACROEXPANDEDCOUNT"
      Topic$ = "Reference/macros"
      
    Case "IMPORT", "IMPORTC", "ENDIMPORT"
      Topic$ = "Reference/import_endimport"
      
    Case "WITH", "ENDWITH"
      Topic$ = "Reference/with_endwith"
      
    Case "PROTOTYPE", "PROTOTYPEC"
      Topic$ = "Reference/prototypes"
      
    Case "NEWLIST", "LIST"
      Topic$ = "Reference/newlist"
      
    Case "NEWMAP", "MAP"
      Topic$ = "Reference/newmap"
      
    Case "STRUCTURE", "STRUCTUREUNION", "ENDSTRUCTUREUNION", "ENDSTRUCTURE"
      Topic$ = "Reference/structures"
      
    Case "INTERFACE", "ENDINTERFACE", "EXTENDS"
      Topic$ = "Reference/interfaces"
      
    Case "ENUMERATION", "ENUMERATIONBINARY", "ENDENUMERATION"
      Topic$ = "Reference/enumerations"
      
    Case "MODULE", "ENDMODULE", "DECLAREMODULE", "ENDDECLAREMODULE", "USEMODULE", "UNUSEMODULE"
      Topic$ = "Reference/module"
      
    Case "BREAK", "CONTINUE"
      Topic$ = "Reference/break_continue"
      
    Case "RUNTIME"
      Topic$ = "Reference/runtime"
      
    Case "GLOBAL"
      Topic$ = "Reference/global"
      
    Case "PROCEDURE", "ENDPROCEDURE", "PROCEDURERETURN", "DECLARE"
      Topic$ = "Reference/procedures"
      
    Case "PROCEDUREDLL", "PROCEDURECDLL", "DECLAREDLL", "DECLARECDLL"
      Topic$ = "Reference/dll"
      
    Case "SHARED"
      Topic$ = "Reference/shared"
      
    Case "STATIC"
      Topic$ = "Reference/static"
      
    Case "THREADED"
      Topic$ = "Reference/threaded"
      
    Case "PROTECTED"
      Topic$ = "Reference/protected"
      
    Case "DATASECTION", "ENDDATASECTION", "DATA", "RESTORE", "READ"
      Topic$ = "Reference/data"
      
    Case "CALLDEBUGGER", "DEBUG", "DEBUGLEVEL", "DISABLEDEBUGGER", "ENABLEDEBUGGER"
      Topic$ = "Reference/debugger"
      
    Case "INCLUDEFILE", "XINCLUDEFILE", "INCLUDEBINARY", "INCLUDEPATH"
      Topic$ = "Reference/includes"
      
    Case "COMPILERIF", "COMPILERELSE", "COMPILERENDIF", "COMPILERSELECT", "COMPILERCASE", "COMPILERDEFAULT", "COMPILERENDSELECT", "COMPILERERROR", "COMPILERWARNING", "ENABLEEXPLICIT", "DISABLEEXPLICIT", "DISABLEPURELIBRARY"
      Topic$ = "Reference/compilerdirectives"
      
    CompilerIf #SpiderBasic
      Case "ENABLEJS", "DISABLEJS"
        Topic$ = "Reference/compilerdirectives"
    CompilerElse
      Case "ENABLEASM", "DISABLEASM"
        Topic$ = "Reference/compilerdirectives"
    CompilerEndIf
      
    Case "ENDHEADERSECTION", "HEADERSECTION"
      Topic$ = "Reference/headersection_endheadersection"
      
    Case "SIZEOF", "OFFSETOF", "TYPEOF", "SUBSYSTEM", "DEFINED", "CLEARSTRUCTURE", "COPYSTRUCTURE", "RESETSTRUCTURE", "INITIALIZESTRUCTURE", "BOOL"
      Topic$ = "Reference/compilerfunctions"
      
  EndSelect
  
  ProcedureReturn Topic$
EndProcedure


; Register a filename for deletion an IDE shutdown.
; Done for all temp files, so proper cleanup is ensured
; Can be called for the same file multiple times without problem
;
Global NewList TempFiles.s()

Procedure RegisterDeleteFile(FileName$)
  ; prevent double entries
  ForEach TempFiles()
    If IsEqualFile(TempFiles(), FileName$)
      ProcedureReturn
    EndIf
  Next TempFiles()
  
  AddElement(TempFiles())
  TempFiles() = FileName$
EndProcedure

; Delete all registered tempfiles (called at shutdown)
Procedure DeleteRegisteredFiles()
  ForEach TempFiles()
    CompilerIf #CompileMac
      If GetExtensionPart(TempFiles()) = "app"
        DeleteDirectory(TempFiles(), "*", #PB_FileSystem_Recursive) ; a .app is a directory!
      Else
        DeleteFile(TempFiles())
      EndIf
    CompilerElse
      DeleteFile(TempFiles())
    CompilerEndIf
  Next TempFiles()
EndProcedure


; Compare two directories like strings, but give the common sublevels priority
;
Procedure CompareDirectories(Directory1$, Directory2$)
  Item1$ = StringField(Directory1$, 1, #Separator)
  Item2$ = StringField(Directory2$, 1, #Separator)
  
  If Item1$ = "" And Item2$ = ""
    ProcedureReturn #PB_String_Equal
  ElseIf Item1$ = ""
    ProcedureReturn #PB_String_Lower
  ElseIf Item2$ = ""
    ProcedureReturn #PB_String_Greater
  Else
    Result = CompareMemoryString(@Item1$, @Item2$, #PATH_CaseInsensitive)
    If Result <> #PB_String_Equal
      ; if one has further subdirectories and the other does not, put the one with the directory above
      Index1 = FindString(Directory1$, #Separator, 1)
      Index2 = FindString(Directory2$, #Separator, 1)
      If Index1 <> 0 And Index2 = 0
        ProcedureReturn #PB_String_Lower
      ElseIf Index1 = 0 And Index2 <> 0
        ProcedureReturn #PB_String_Greater
      Else
        ProcedureReturn Result
      EndIf
    Else
      Directory1$ = Right(Directory1$, Len(Directory1$)-Len(Item1$)-1)
      Directory2$ = Right(Directory2$, Len(Directory2$)-Len(Item2$)-1)
      ProcedureReturn CompareDirectories(Directory1$, Directory2$)
    EndIf
  EndIf
EndProcedure

