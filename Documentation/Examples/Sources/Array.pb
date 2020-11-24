;
; ------------------------------------------------------------
;
;   PureBasic - Array example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Structure BasicStructure
  Field1.b
  Field2.w
  Field3.l
EndStructure


Structure ComplexStructure
  Field.b
  Basic.BasicStructure ; Creation of the BasicStructure object inside this structure
EndStructure


Dim BasicArray.l(100)  ; Reserve 101 elements from 0 to 100 of 'long' type

Dim StructuredArray.BasicStructure(10) ; 11 elements from 0 to 10 of 10 BasicStructure objects

Dim StructuredMultiArray.ComplexStructure(10, 20, 10) ; 11*21*11 = 2541 elements of ComplexStructures objects

; Filling arrays & Structure access
;
For k=0 To 100        ; Fill the basic array with values from 0 to 100.
  BasicArray(k) = k
Next

For k=0 To 10        ; Fill the structured array..
  StructuredArray(k)\Field1 = k
  StructuredArray(k)\Field2 = k+1
  StructuredArray(k)\Field3 = k+2
Next

For x=0 To 10        ; Fill the multi structured array..
  For y=0 To 20
    For z=0 To 10
      StructuredMultiArray(x, y, z)\Field = x
      StructuredMultiArray(x, y, z)\Basic\Field2 = y+1
      StructuredMultiArray(x, y, z)\Basic\Field3 = z+2
    Next
  Next
Next

; Copy the array into a new array
;
Dim BasicArrayCopy(1)
CopyArray(BasicArray(), BasicArrayCopy())

Debug "Copied array size: " + ArraySize(BasicArrayCopy()) ; Display the size of the copy, should be 100 as the original


End
