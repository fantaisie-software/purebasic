;
; ------------------------------------------------------------
;
;   PureBasic - Map example file
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

NewMap TestMap.BasicStructure()

;
;-------- Add Elements and TestMaps --------
;
TestMap("item1")\Field2 = 1
TestMap("item2")\Field2 = 2
TestMap("item3")\Field2 = 3
TestMap("item4")\Field2 = 4


Debug "Number of elements in the Map: " + MapSize(TestMap())

; First way to Map all the elements
;
ResetMap(TestMap())               ; Reset the Map index before the first element.
While NextMapElement(TestMap())  ; Process all the elements...
  Debug "ResetMap() - 'Field2' value: " + TestMap()\Field2
Wend

; Second way, with the help of ForEach
;
ForEach TestMap()       ; Process all the elements...
  Debug "ForEach() - 'Field2' value: " + TestMap()\Field2
Next


; Go directly to the 3rd element
FindMapElement(TestMap(), "item3")

Debug "3rd Element - 'Field2' value: " + TestMap()\Field2

End