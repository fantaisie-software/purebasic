;
; ------------------------------------------------------------
;
;   PureBasic - Recursive File Search example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Procedure FileSearch(List Files.s(), dir.s, mask.s = "")
  Protected name.s, id
  
  If Right(dir, 1) <> #PS$
    dir + #PS$
  EndIf
  
  id = ExamineDirectory(#PB_Any, dir, "")
  If id
    While NextDirectoryEntry(id)
      name = DirectoryEntryName(id)
      If name = "." Or name = ".."
        Continue
      EndIf
      
      If DirectoryEntryType(id) = #PB_DirectoryEntry_Directory ; if the path is a folder
        FileSearch(Files(), dir + name + #PS$, mask)            ; recursive call to subfolder
      ElseIf (Not Asc(mask) Or GetExtensionPart(name) = mask) And AddElement(Files())
        Files() = dir + DirectoryEntryName(id)
      EndIf
    Wend
    
    FinishDirectory(id)
  EndIf
EndProcedure

Define NewList Files.s()
FileSearch(Files(), GetTemporaryDirectory(), "txt") ; empty string to find all files

ForEach Files()
  Debug Files()
Next
