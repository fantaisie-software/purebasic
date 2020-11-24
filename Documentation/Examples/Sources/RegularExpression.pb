;
; ------------------------------------------------------------
;
;   PureBasic - RegularExpression example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Will match every word of 3 letters, lowercase with a 'b' as middle letter
;
If CreateRegularExpression(0, "[a-z]b[a-z]")

  Dim Result$(0)
  
  NbResults = ExtractRegularExpression(0, " abc it won't match abz", result$())
  
  Debug "Nb matchs found: " + NbResults
  
  For i = 0 To NbResults - 1
    Debug Result$(i)
  Next

Else
  MessageRequester("Error", RegularExpressionError())
EndIf
