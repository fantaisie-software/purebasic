; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Very simple replacement for the "zip" utility to create the theme files on Windows
; without the need to install a tool for it.
; Only used in the Windows specifif "MakeWindows.cmd" scripts. The makefile always uses
; the "zip" utility.
;
; Just creates a Zip file from all files in a source directory.
;
; Commandline:
;    <zipfile> <source directory>
;

OpenConsole()
UseZipPacker()

ZipFile$ = ProgramParameter()
If ZipFile$ = ""
  PrintN("Missing mandatory zip file parameter")
  End 1
EndIf

Source$ = ProgramParameter()
If Source$ = ""
  PrintN("Missing mandatory source directory parameter")
  End 1
EndIf

If CreatePack(0, ZipFile$, #PB_PackerPlugin_Zip)
  
  If ExamineDirectory(0, Source$, "*.*")
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        
        Name$ = DirectoryEntryName(0)
        File$ = Source$ + "\" + Name$
        If Not AddPackFile(0, File$, Name$)
          PrintN("Failed to add file to Zip: " + File$)
          End 1
        EndIf
        
      EndIf
    Wend
    FinishDirectory(0)
  Else
    PrintN("Failed to read directory: " + Source$)
  EndIf
  
  ClosePack(0)
  
Else
  PrintN("Failed to create Zip file: " + ZipFile$)
  End 1
  
EndIf

End 0
