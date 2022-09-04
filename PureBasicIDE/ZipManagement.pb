; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
;
; Some very very basic routines for reading a Zip in PB.
;
; The functions use zlib for decoding and work entirely in memory.
; They should support most simple zip files.
;

;- ZIP format structures
;  (as far as this code supports them)
;
#SIGNATURE_LocalFileHeader = $04034b50
#SIGNATURE_CentralFileHeader = $02014b50
#SIGNATURE_EndOfDirectory = $06054b50

#SupportedVersion = 20 ; no zi64 or encryption supported

#BITFLAG_DataDescriptor = 1<<3
#SIZEOF_DataDescriptor = 12  ; in non-zip64 files

; all other compression methods not supported here
#COMPRESSION_Store = 0
#COMPRESSION_Deflate = 8

; The Zip format is all in little-endian, so for PowerPC, we need a conversion
;
CompilerIf #PB_Compiler_Processor = #PB_Processor_PowerPC
  Macro LONG_LE(Value)
    ((((Value) >> 24) & $000000FF) | (((Value) >> 8) & $0000FF00) | (((Value) << 8) & $00FF0000) | (((Value) << 24) & $FF000000))
  EndMacro
  
  Macro WORD_LE(Value)
    ((((Value) >> 8) & $00FF) | (((Value) << 8) & $FF00))
  EndMacro
CompilerElse
  Macro LONG_LE(Value)
    Value
  EndMacro
  
  Macro WORD_LE(Value)
    Value
  EndMacro
CompilerEndIf

Structure LocalFileHeader
  Signature.l       ; $04034b50
  VersionNeeded.w
  BitFlag.w
  Compression.w
  LastModifiedTime.w
  LastModifiedData.w
  Crc32.l
  CompressedSize.l
  UncompressedSize.l
  FileNameLength.w
  ExtraFieldLength.w
  ; FileName - variable length
  ; ExtraField - variable length
EndStructure


Structure CentralFileHeader
  Signature.l ; $02014b50
  VersionMadeBy.w
  VersionNeeded.w
  BitFlag.w
  Compression.w
  LastModifiedTime.w
  LastModifiedData.w
  Crc32.l
  CompressedSize.l
  UncompressedSize.l
  FileNameLength.w
  ExtraFieldLength.w
  FileCommentLength.w
  DiskNumberStart.w
  InternalAttributes.w
  ExternalAttributes.l
  LocalHeaderOffset.l
  ; FileName - variable length
  ; ExtraField - variable length
  ; FileComment - variable length
EndStructure

Structure EndOfDirectory
  Signature.l ; $06054b50
  DiskNumber.w
  DiskWithDirectoryStart.w
  TotalFilesOnThisDisk.w
  TotalFiles.w
  DirectorySize.l
  DirectoryStart.l
  CommentLength.w
  ; Comment - variable length
EndStructure


;- Zip reading code (from memory)

; allow standalone use of this file
; Note: Everything in this structure is in normal processor byte order
CompilerIf Defined(ZipEntry, #PB_Structure) = 0
  Structure ZipEntry
    Name$
    *Content.i
    Crc32.l
    Compression.l
    Compressed.l
    Uncompressed.l
  EndStructure
CompilerEndIf

; Scans zip data from memory and fills file list with all readable (nonempty) entries
;
Procedure ScanZip(*Buffer, Size, List Files.ZipEntry())
  ClearList(Files())
  
  If LONG_LE(PeekL(*Buffer)) = #SIGNATURE_LocalFileHeader ; must be at the beginning
                                                          ; find end of central directory
    *DirectoryEnd.EndOfDirectory = *Buffer + Size - SizeOf(EndOfDirectory)
    While *DirectoryEnd > *Buffer And LONG_LE(*DirectoryEnd\Signature) <> #SIGNATURE_EndOfDirectory
      *DirectoryEnd - 1
    Wend
    
    If *DirectoryEnd > *Buffer
      If WORD_LE(*DirectoryEnd\TotalFiles) > 0 And WORD_LE(*DirectoryEnd\DiskNumber) = WORD_LE(*DirectoryEnd\DiskWithDirectoryStart)
        If LONG_LE(*DirectoryEnd\DirectoryStart) > 0 And LONG_LE(*DirectoryEnd\DirectoryStart) < Size And LONG_LE(*DirectoryEnd\DirectorySize) > 0 And LONG_LE(*DirectoryEnd\DirectorySize) < Size
          
          *Entry.CentralFileHeader = *Buffer + LONG_LE(*DirectoryEnd\DirectoryStart)
          While *Entry < *DirectoryEnd And LONG_LE(*Entry\Signature) = #SIGNATURE_CentralFileHeader
            
            If WORD_LE(*Entry\VersionNeeded) <= #SupportedVersion And (WORD_LE(*Entry\Compression) = #COMPRESSION_Store Or WORD_LE(*Entry\Compression) = #COMPRESSION_Deflate)
              If LONG_LE(*Entry\CompressedSize) > 0 And LONG_LE(*Entry\CompressedSize) < Size And LONG_LE(*Entry\UncompressedSize) > 0 And LONG_LE(*Entry\UncompressedSize) < 1024*1024*3 ; only interested in small files with this code
                If WORD_LE(*Entry\FileNameLength) > 0
                  If LONG_LE(*Entry\LocalHeaderOffset) >= 0 And LONG_LE(*Entry\LocalHeaderOffset) < Size - LONG_LE(*Entry\CompressedSize) - SizeOf(LocalFileHeader)
                    
                    *Header.LocalFileHeader = *Buffer + LONG_LE(*Entry\LocalHeaderOffset)
                    *Content = *Header + SizeOf(LocalFileHeader) + WORD_LE(*Header\FileNameLength) + WORD_LE(*Header\ExtraFieldLength)
                    If *Content > *Buffer And *Content < *Buffer + Size - LONG_LE(*Entry\CompressedSize)
                      AddElement(Files())
                      Files()\Name$        = PeekS(*Entry + SizeOf(CentralFileHeader), WORD_LE(*Entry\FileNameLength), #PB_Ascii)
                      Files()\Content      = *Content
                      Files()\Crc32        = LONG_LE(*Entry\Crc32)
                      Files()\Compression  = WORD_LE(*Entry\Compression)
                      Files()\Compressed   = LONG_LE(*Entry\CompressedSize)
                      Files()\Uncompressed = LONG_LE(*Entry\UncompressedSize)
                    EndIf
                    
                  EndIf
                EndIf
              EndIf
            EndIf
            
            *Entry + SizeOf(CentralFileHeader) + WORD_LE(*Entry\FileNameLength) + WORD_LE(*Entry\ExtraFieldLength) + WORD_LE(*Entry\FileCommentLength)
          Wend
          
        EndIf
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn ListSize(Files())
EndProcedure


; Returns a buffer of uncompressed size.
; Must be freed by the caller
;
Procedure ExtractZip(*Entry.ZipEntry)
  *Buffer = AllocateMemory(*Entry\Uncompressed)
  Success = 0
  
  If *Buffer
    If *Entry\Compression = #COMPRESSION_Store
      CopyMemory(*Entry\Content, *Buffer, *Entry\Uncompressed)
      Success = 1
      
    Else
      stream.z_stream
      stream\next_in   = *Entry\Content
      stream\avail_in  = *Entry\Compressed
      stream\next_out  = *Buffer
      stream\avail_out = *Entry\Uncompressed
      ; other fields remain 0
      
      ; Call with negative bits (maximum) to specify the raw inflate mode
      ; (else zlib fails because there is no zlib header)
      If inflateInit2(@stream, -15) = #Z_OK
        If inflate(@stream, #Z_FINISH) = #Z_STREAM_END
          Success = 1
        EndIf
        inflateEnd(@stream)
      EndIf
    EndIf
    
    If Success = 0 Or CRC32Fingerprint(*Buffer, *Entry\Uncompressed) <> *Entry\Crc32
      FreeMemory(*Buffer)
      *Buffer = 0
    EndIf
  EndIf
  
  ProcedureReturn *Buffer
EndProcedure


