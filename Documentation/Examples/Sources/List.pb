;
; ------------------------------------------------------------
;
;   PureBasic - Linked list example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

Structure BasicStructure
    Field1.i
    Field2.w
    Field3.l
EndStructure

Structure ComplexStructure
    Field1.i
   *Basic.BasicStructure              ; Pointer to a BasicStructure object
    Basic2.BasicStructure             ; Creation of the BasicStructure object inside this structure
   *Next.ComplexStructure             ; Pointer to another ComplexStructure object
EndStructure

NewList TestList.BasicStructure()
NewList TestComplexList.ComplexStructure()

;
;-------- BasicStructure Add Elements --------
;

AddElement(TestList())
TestList()\Field2 = 1

AddElement(TestList())
TestList()\Field2 = 2

AddElement(TestList())
TestList()\Field2 = 3

AddElement(TestList())
TestList()\Field2 = 4

Debug "============================================="
Debug " Simple Structure"
Debug "................."
Debug ""

Debug "Number of elements in the list: " + ListSize(TestList())

; First way to list all the elements
;
ResetList(TestList())               ; Reset the list index before the first element.

While NextElement(TestList())       ; Process all the elements...
  Debug "ResetList() - 'Field2' value: " + TestList()\Field2
Wend

; Second way, with the help of ForEach
;
ForEach TestList()       ; Process all the elements...
  Debug "ForEach() - 'Field2' value: " + TestList()\Field2
Next


SelectElement(TestList(), 2)  ; Go directly to the 3rd element
Debug "3rd Element - 'Field2' value: " + TestList()\Field2

Debug ""

; 
;
;-------- ComplexStructure Add Elements --------
;
AddElement(TestComplexList())
TestComplexList()\Field1 = 11

AddElement(TestList())
TestComplexList()\Basic = AllocateStructure(BasicStructure)
TestComplexList()\Basic\Field1 = 111 ; It's a pointer but we don't use the * (it's a PureBasic oddity)
TestComplexList()\Basic\Field2 = 222
TestComplexList()\Basic\Field3 = 333

AddElement(TestList())
TestComplexList()\Basic2\Field1 = 1111
TestComplexList()\Basic2\Field2 = 2222
TestComplexList()\Basic2\Field3 = 3333

AddElement(TestList())
TestComplexList()\Next = AllocateStructure(ComplexStructure)
TestComplexList()\Next\Field1 = 7
TestComplexList()\Next\Basic = AllocateStructure(BasicStructure)
TestComplexList()\Next\Basic\Field1 = 77
TestComplexList()\Next\Basic\Field2 = 88
TestComplexList()\Next\Basic\Field3 = 99
TestComplexList()\Next\Basic2\Field1 = 777
TestComplexList()\Next\Basic2\Field2 = 888
TestComplexList()\Next\Basic2\Field3 = 999
TestComplexList()\Next\Next = AllocateStructure(ComplexStructure)
TestComplexList()\Next\Next\Field1 = 9999

; Debug several fields
Debug "============================================="
Debug " Complex Structure"
Debug ".................."
Debug "TestComplexList()\Field1 = " + TestComplexList()\Field1 ;= 11
Debug "TestComplexList()\Basic\Field2 = " + TestComplexList()\Basic\Field2 + " (Beware, it's a pointer but we don't use the '*'";= 222
Debug "TestComplexList()\Basic2\Field3 = " + TestComplexList()\Basic2\Field3;= 3333
Debug "TestComplexList()\Next\Field1 = " + TestComplexList()\Next\Field1 + " (idem)"     ;= 7
Debug "TestComplexList()\Next\Basic\Field1 = " + TestComplexList()\Next\Basic\Field1 + " (idem)" ;= 77
Debug "TestComplexList()\Next\Basic2\Field1 = " + TestComplexList()\Next\Basic2\Field1 + " (idem)";= 777
Debug "TestComplexList()\Next\Next\Field1 = " + TestComplexList()\Next\Next\Field1 + " (idem)"  ;= 9999


End
