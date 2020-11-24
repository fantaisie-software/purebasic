;
; ------------------------------------------------------------
;
;   PureBasic - Compressor example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

UseBriefLZPacker() ; Small and fast packer

If ReadFile(0, OpenFileRequester("Choose a file to compress", "", "*.*", 0))
  FileLength = Lof(0)
  
  ; Allocate the 2 memory buffers needed for compression..
  ;
  *Source = AllocateMemory(FileLength)
  *Target = AllocateMemory(FileLength)
  If FileLength And *Source And *Target
    ReadData(0, *Source, FileLength) ; Read the whole file in the memory buffer
    
    ; Compress the file, which is in memory
    ;
    CompressedLength = CompressMemory(*Source, FileLength, *Target, FileLength)
    If CompressedLength

      DecompressedLength = UncompressMemory(*Target, CompressedLength, *Source, FileLength)
      If DecompressedLength = FileLength
        MessageRequester("Info", "De/Compression succeded:"+#LF$+#LF$+"Old size: "+Str(FileLength)+#LF$+"New size: "+Str(CompressedLength))
      EndIf
    Else
      MessageRequester("Error", "Can't compress the file")
    EndIf
    
    FreeMemory(*Source)
    FreeMemory(*Target)
    
  EndIf
  
  CloseFile(0)
EndIf

End
