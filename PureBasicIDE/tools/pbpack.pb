;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------


;
; simple pack utility to use the PB packer functions from the commandline.
;
; usage:
;   pbpack [-q] [-l<n>] outfile.pak file1 file2 file3 ...
;
; NOTE: Commadline order is important! (-q always before -l if both exist)
;
; NOTE: We do not use the CreatePack() command, as we cannot use OpenPack() later anyway
; as the .pak are included into the exe.
; Also we need to be able to include files that fail to be packed!
;
; Pack File Format:
;
; LONG CompressedSize
; LONG UncompressedSize (if this is -1, then the file is not compressed!)
; [COMPRESSED / UNCOMPRESSED data]
;
#PackLevel = 9

UseBriefLZPacker()

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
    
    Goto ErrorHandler_End
    
    ErrorHandler:
    
    Message$ = "Error: " + ErrorMessage() + #CRLF$
    Message$ + "File : " + ErrorFile() + #CRLF$
    Message$ + "Line : " + Str(ErrorLine())
    
    MessageRequester("Error", Message$, 0)
    End
    
    ErrorHandler_End:
    
    OnErrorGoto(?ErrorHandler)
    
  CompilerEndIf
CompilerEndIf

Global FileSize, DisplayedChars

Procedure Callback(SourcePosition, TargetPosition)
  
  status = (SourcePosition*76)/FileSize
  
  Print(RSet("", status-DisplayedChars, "#"))
  
  DisplayedChars = status
  
  ProcedureReturn 1
EndProcedure

OutFile$ = ProgramParameter()

If UCase(OutFile$) = "-Q"  ; quiet flag
  verbose = 0
  OutFile$ = ProgramParameter()
Else
  verbose = 1
EndIf

If UCase(Left(OutFile$, 2)) = "-L" ; pack level specified
  
  PackLevel = Val(Right(OutFile$, Len(OutFile$)-2))
  If PackLevel < 0 Or PackLevel > 9
    PackLevel = #PackLevel
  EndIf
  
  OutFile$ = ProgramParameter()
  
Else
  
  PackLevel = #PackLevel
  
EndIf

OpenConsole() ; open console in any case for error output!

If verbose
  ; PackerCallback(@Callback())
EndIf


InFile$ = ProgramParameter()

If OutFile$ = "" Or InFile$ = ""
  PrintN("  Usage:")
  PrintN("  pbpack [-l<n>] outfile.pak file1 file2 file3 ...")
  PrintN("")
  End 1
EndIf

If CreateFile(0, OutFile$) = 0
  PrintN("  Error: Cannot create output pak file!")
  PrintN("")
  End 1
EndIf

NbFiles = 0

While InFile$ <> ""
  
  FileSize = FileSize(InFile$)
  If verbose
    PrintN("Compressing file: "+GetFilePart(InFile$)+" ("+Str(FileSize)+" Bytes)")
  EndIf
  
  If ReadFile(1, InFile$) = 0
    PrintN("  Error: Compression of the file failed!")
    PrintN("")
    CloseFile(0)
    DeleteFile(OutFile$)
    End 1
  ElseIf Lof(1) = 0
    PrintN("  Error: Compression of the file failed! (File is Empty)")
    PrintN("")
    CloseFile(0)
    CloseFile(1)
    DeleteFile(OutFile$)
    End 1
  Else
    
    NbFiles + 1
    If verbose
      Print("  ")
    EndIf
    
    DisplayedChars = 0
    
    *InBuffer = AllocateMemory(FileSize)
    *OutBuffer = AllocateMemory(FileSize + 8)
    
    If *InBuffer = 0 Or *OutBuffer = 0
      PrintN("  Error: Compression of the file failed! (Memory Error)")
      PrintN("")
      CloseFile(1)
      CloseFile(0)
      DeleteFile(OutFile$)
      End 1
    EndIf
    
    ReadData(1, *InBuffer, FileSize)
    CloseFile(1)
    
    PackedSize = CompressMemory(*InBuffer, FileSize, *OutBuffer, FileSize+8, #PB_PackerPlugin_BriefLZ)
    If PackedSize = 0
      WriteLong(0, FileSize) ; packing failed, add the file unpacked
      WriteLong(0, -1)
      WriteData(0, *InBuffer, FileSize)
    Else
      WriteLong(0, PackedSize)
      WriteLong(0, FileSize)
      WriteData(0, *OutBuffer, PackedSize)
    EndIf
    
    If verbose
      PrintN(RSet("", 76-DisplayedChars, "#")) ; fill the line to 100% :)
    EndIf
    
    FreeMemory(*InBuffer)
    FreeMemory(*Outbuffer)
    
  EndIf
  InFile$ = ProgramParameter()
Wend

CloseFile(0)

If verbose
  PrintN(Str(NbFiles)+" files packed.")
  PrintN("")
EndIf

End 0


