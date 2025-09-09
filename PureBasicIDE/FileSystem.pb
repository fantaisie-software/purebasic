; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; --------------------------------------------------------------
;
; Functions for easier working with filenames on all platforms.
;
; Note: This file is standalone and does not need anything from
;  the IDE sources, so it can be used in any other project as well.
;
; This file is unicode ready.
;
; Used by: IDE, Debugger, PureUnit
;
; --------------------------------------------------------------

; redefine these from the IDE source if not present
;
CompilerIf Defined(Separator, #PB_Constant) = 0
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    #Separator = "\"
  CompilerElse
    #Separator = "/"
  CompilerEndIf
CompilerEndIf


; Creates a unique representation of a filename, by doing this:
;  - replaces any "../directory" parts to get a direct path
;  - removes multiple redundant "//" in the path
;  - cutting any "./" in the path
;  - on Windows, replaces all "/" by "\" as both are allowed.
;
; The resulting path can be compared for equalness by only taking
; care or the case sensitivity of the filesystem.
;
; Returns "" if the path contains more "../" than directories!
;
Procedure.s UniqueFilename(FileName$)
  
  ; Got a 0-pointer here on Linux once.
  If FileName$ = ""
    ProcedureReturn ""
  EndIf
  
  ; On Windows, we need to replace all "/" with "\" to have a unique path,
  ; as both can be mixed as separator characters!
  ;
  ; We also do the conversion in the other direction so we can easily share
  ; Project files and compiler settings between Windows and Linux.
  ;
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    FileName$ = ReplaceString(FileName$, "/", "\")
  CompilerElse
    FileName$ = ReplaceString(FileName$, "\", "/")
  CompilerEndIf
  
  *Cursor.Character = @FileName$
  While *Cursor\c
    
    If *Cursor\c = Asc(#Separator)
      If PeekS(*Cursor, 4) = #Separator + ".." + #Separator
        ; remove the previous directory name
        *BackCursor.Character = *Cursor - SizeOf(Character)
        While *BackCursor >= @FileName$
          If *BackCursor\c = Asc(#Separator)
            Break
          EndIf
          *BackCursor - SizeOf(Character)
        Wend
        
        If *BackCursor < @FileName$
          ; oops, more ".." in the string than directories!
          ProcedureReturn ""
        EndIf
        
        ; poking in the string is ok, since it can only get shorter by this
        PokeS(*BackCursor, PeekS(*Cursor + 3*SizeOf(Character)))
        
        ; Make sure the cursor stays inside the string.
        ; Otherwise, if removing a large dir towards the string end, *Cursor might
        ; end up outside of the valid string and create an endless loop
        *Cursor = *BackCursor
        
      ElseIf PeekS(*Cursor, 3) = #Separator + "." + #Separator
        ; simply remove this reference to the own directory
        PokeS(*Cursor, PeekS(*Cursor + 2*SizeOf(Character)))
        
      ElseIf PeekS(*Cursor, 2) = #Separator + #Separator
        ; Redundant "\\" or "//". Remove one of them
        
        ; Special case: On Windows a path starting with \\ is a UNC network oath
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          If *Cursor = @FileName$
            *Cursor + (SizeOf(Character) * 2)
            Continue
          EndIf
        CompilerEndIf
        
        PokeS(*Cursor, PeekS(*Cursor + SizeOf(Character)))
        ; Do not skip the remaining "/" yet to reprocess it in the next loop so do not increase *Cursor here
        
      Else
        *Cursor + SizeOf(Character)
      EndIf
      
    Else
      *Cursor + SizeOf(Character)
    EndIf
  Wend
  
  ProcedureReturn Filename$
EndProcedure

; Returns true if the two (full) filenames are representing
; the same file. This function calls UniqueFilename().
;
Procedure IsEqualFile(File1$, File2$)
  
  File1$ = UniqueFilename(File1$)
  File2$ = UniqueFilename(File2$)
  
  ; The UniqueFilename() returns "" if the filename has too many "../"
  ;
  If File1$ <> "" And File2$ <> ""
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      If File1$ = File2$
        ProcedureReturn #True
      EndIf
      
    CompilerElse
      If UCase(File1$) = UCase(File2$)
        ProcedureReturn #True
      EndIf
      
    CompilerEndIf
    
  EndIf
  
  ProcedureReturn #False
EndProcedure


; Creates a relative path representation of the (full) FileName$
; relative to the (full) BasePath$. Note that the full FileName$ is returned
; if no relative path can be created (different drives), or if there
; would be too many "../../" involved.
;
Procedure.s CreateRelativePath(BasePath$, FileName$)
  
  If FileName$ = "" ; otherwise this gives an ugly "../../"
    ProcedureReturn ""
  EndIf
  
  ; make sure both have no "../" or "/", "\" mixups
  FileName$ = UniqueFilename(FileName$)
  BasePath$ = UniqueFilename(BasePath$)
  
  ; check if both are really full paths:
  ;
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If Mid(BasePath$, 2, 1) = ":" And Mid(FileName$, 2, 1) = ":"
      ; Both have drive letters.. check the drive match
      If UCase(Left(BasePath$, 1)) <> UCase(Left(FileName$, 1))
        ProcedureReturn FileName$
      EndIf
      
    ElseIf Left(BasePath$, 2) = "\\" And Left(FileName$, 2) = "\\"
      ; Both are network paths, check if the computer name matches
      If UCase(StringField(BasePath$, 3, "\")) <> UCase(StringField(FileName$, 3, "\"))
        ProcedureReturn FileName$
      EndIf
      
    Else
      ; Either a mix of Network/non-network paths, or not full paths at all
      ProcedureReturn FileName$
      
    EndIf
    
  CompilerElse
    If Left(BasePath$, 1) <> "/" Or Left(FileName$, 1) <> "/"
      ProcedureReturn FileName$
    EndIf
    
  CompilerEndIf
  
  If Right(BasePath$, 1) <> #Separator
    BasePath$ + #Separator
  EndIf
  
  FullFileName$ = FileName$ ; make backup for later
  
  ; process the part that is identical
  ;
  For x = Len(BasePath$) To 1 Step -1
    If Mid(BasePath$, x, 1) = #Separator
      Protected CaseMode
      CompilerIf #PB_Compiler_OS = #PB_OS_Linux
        CaseMode = #PB_String_CaseSensitive
      CompilerElse
        CaseMode = #PB_String_NoCase
      CompilerEndIf
      
      If CompareMemoryString(@BasePath$, @FileName$, CaseMode, x) = 0
        BasePath$ = Right(BasePath$, Len(BasePath$)-x)
        FileName$ = Right(FileName$, Len(FileName$)-x)
        Break
      EndIf
    EndIf
  Next x
  
  ; now add ".." for each directory left in the BasePath$
  ;
  count = CountString(BasePath$, #Separator)
  If count <= 3 ; do not go too many levels back.. it looks ugly
    For i = 1 To count
      FileName$ = ".." + #Separator + FileName$
    Next i
  Else
    FileName$ = FullFileName$ ; use the full name here
  EndIf
  
  ProcedureReturn FileName$
EndProcedure

; Tries to resolve a (relative or full) FileName$ relative to the
; (full) BasePath$. The returned filename is made unique with
; UniqueFilename()
;
Procedure.s ResolveRelativePath(BasePath$, FileName$)
  
  ; do the cutting of "../" even if basepath is actually empty
  If BasePath$ <> ""
    BasePath$ = UniqueFilename(BasePath$)
    
    If Right(BasePath$, 1) <> #Separator
      BasePath$ + #Separator
    EndIf
    
    If FindString(FileName$, #Separator, 1) = 0
      FileName$ = BasePath$ + FileName$
      
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ElseIf Left(FileName$, 2) = "\\"  ; Network file path, Windows only (like: \\192.168.0.1\Test.pb)
                                        ; FileName$ remains untouched here (it contains a drive letter)
      CompilerEndIf
      
    ElseIf Left(FileName$, 1) = #Separator
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        FileName$ = Left(BasePath$, 2) + FileName$
      CompilerEndIf
      ; On linux/mac. FileName is a full path, so no change
      
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ElseIf Mid(FileName$, 2, 1) = ":"
        ; FileName$ remains untouched here (it contains a drive letter)
      CompilerEndIf
      
    Else
      FileName$ = BasePath$ + FileName$
      
    EndIf
    
  EndIf
  
  ; the UniqueFilename() cuts all the "../" in the combined path
  ; Do this even if FileName$ was a full path to get a unique name as
  ; the debugger reports full filenames containing "../" for example.
  ;
  ProcedureReturn UniqueFilename(FileName$)
EndProcedure

Procedure CreateDirectoryRecursive(Directory$)
  If Directory$ <> ""
    Select FileSize(Directory$)
      Case -2 ; already exists - OK!
        ProcedureReturn #True
        
      Case -1 ; does not exist - create it
        Parent$ = UniqueFilename(Directory$ + #Separator + ".." + #Separator)
        If Parent$ <> ""
          CreateDirectoryRecursive(Parent$)
        EndIf
        CreateDirectory(Directory$)
        If FileSize(Directory$) = -2
          ProcedureReturn #True
        EndIf
        
      Default ; it's a file!
        ProcedureReturn #False
    EndSelect
  EndIf
  ProcedureReturn #False
EndProcedure

