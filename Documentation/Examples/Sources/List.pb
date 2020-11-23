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
    Field1.b
    Field2.w
    Field3.l
EndStructure

Structure ComplexStructure
    Field1.b
   *Basic.BasicStructure              ; Pointer to a BasicStructure object
    Basic2.BasicStructure             ; Creation of the BasicStructure object inside this structure
   *Next.ComplexStructure             ; Pointer to another ComplexStructure object
EndStructure

NewList TestList.BasicStructure()

;
;-------- Add Elements and TestLists --------
;

AddElement(TestList())
TestList()\Field2 = 1

AddElement(TestList())
TestList()\Field2 = 2

AddElement(TestList())
TestList()\Field2 = 3

AddElement(TestList())
TestList()\Field2 = 4

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

End
