;
; ------------------------------------------------------------
;
;   PureBasic - File example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

MessageRequester("PureBasic", "Welcome !"+Chr(13)+"PureBasic will write a file named: PureBasicTestFile.pb", 0)

If CreateFile(0, "PureBasicTestFile.txt")
  WriteStringN(0, "         This is a PureBasic file test")
  WriteString(0, "Now it's on ")
  WriteString(0, "the same line.")

  CloseFile(0)
Else
  MessageRequester("PureBasic", "Error: can't write the file", 0)
  End
EndIf

If ReadFile(0, "PureBasicTestFile.txt")

  First$ =  Trim(ReadString(0))
  MessageRequester("PureBasic", "Line read: "+First$, 0)
  
  CloseFile(0)
Else
  MessageRequester("PureBasic", "Error: Can't read the file", 0)
EndIf

End
