;
; Program to demonstrate the capatibilities of the PureBasic compiler.
;

; First step standard variables
;
Byte.b  = 2        ; Byte (8 bit) variable
Word.w  = 3000     ; Word (16 bit) variable
Long.l  = 400000   ; Long (32 bit) variable
Float.f = 125.545  ; Float (32 bit) variable

Binary = %1011 ; 11 in binary format
Hexa   = $FF   ; 255 in hexadecimal format

; Variable interactions:
;
Result.l = Byte+Word+Long*Byte

; Structures
;
Structure BasicStructure
  Field1.b
  Field2.w
  Field3.l
EndStructure

; Linked lists
;
NewList TestList.BasicStructure()

AddElement(TestList())
TestList()\Field2 = 1

AddElement(TestList())
TestList()\Field3 = 2

ForEach TestList() ; Display all the elements...
  Debug TestList()\Field2
  Debug TestList()\Field3
Next


End