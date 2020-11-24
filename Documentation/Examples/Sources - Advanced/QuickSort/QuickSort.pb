;
; ------------------------------------------------------------
;
;   PureBasic - QuickSort example
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Global Dim a(10000)

Procedure QuickSort(g, d)
  
  If g < d
    v = a(d)
    i = g - 1
    j = d
    
    Repeat
      Repeat
        i + 1
      Until a(i) >= v
      
      ok = 0
      Repeat
        If j > 0
          j - 1
        Else
          ok = 1
        EndIf
        
        If a(j) <= v
          ok = 1
        EndIf
      Until ok <> 0
      
      Swap a(i), a(j)
    Until j <= i
    
    t = a(j)
    a(j) = a(i)
    a(i) = a(d)
    a(d) = t
    
    QuickSort(g, i - 1)
    QuickSort(i + 1, d)
  EndIf
  
EndProcedure

a(10) = 1
a(20) = 256
a(100) = -200
a(1000) = -230

a(40) = -50

QuickSort(0,10000)

For k=0 To 5
  MessageRequester("First elements", Str(a(k)), 0)
Next

For k=9999 To 10000
  MessageRequester("Last elements", Str(a(k)), 0)
Next
