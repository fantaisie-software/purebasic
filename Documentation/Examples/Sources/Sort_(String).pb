;
; ------------------------------------------------------------
;
;   PureBasic - Sort (String) example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Don't change the number of elements without add them in the data below !
;
#NbElements = 8

Dim Array.s(#NbElements)

For k=0 To #NbElements
  Read.s Array(k)
Next

For k=0 To #NbElements
  Debug Array(k)
Next

SortArray(Array(), #PB_Sort_Ascending | #PB_Sort_NoCase)

Debug "---------------------"

For k=0 To #NbElements
  Debug Array(k)
Next

MessageRequester("Information", "Sort finished !", 0)

End


DataSection
  Data.s "Hello", "This", "is", "a", "Nice", "test", "Isn't", "it ?", "Haha !"
EndDataSection
