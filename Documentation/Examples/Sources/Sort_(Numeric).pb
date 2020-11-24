;
; ------------------------------------------------------------
;
;   PureBasic - Sort (Numerical) example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

; Change the number of elements here, to see the speed of the sort routine :)
;
#NbElements = 20

Dim Array.b(#NbElements)

For k=0 To #NbElements
  Array(k) = Random(10000)
Next

; Fill the array with lot of random number
;

For k=0 To #NbElements
  Debug Array(k)
Next

; Sort the whole array !
;
SortArray(Array(), #PB_Sort_Ascending)

Debug "----------------"

For k=0 To #NbElements
  Debug Array(k)
Next

MessageRequester("Sort Example", "Sort finished.")

