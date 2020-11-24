;
; ------------------------------------------------------------
;
;   PureBasic - Json
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

#JSON_Create = 0
#JSON_Parse = 1


; Build JSON data from scratch
;
If CreateJSON(#JSON_Create)
  Person = SetJSONObject(JSONValue(#JSON_Create))
  SetJSONString(AddJSONMember(Person, "FirstName"), "John")
  SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
  SetJSONInteger(AddJSONMember(Person, "Age"), 42)
  
  Values = SetJSONArray(AddJSONMember(Person, "Values"))
  For i = 1 To 5
    SetJSONInteger(AddJSONElement(Values), Random(256))
  Next i
  
  Debug "---------- Compact format ----------"
  Debug ""
  Debug ComposeJSON(#JSON_Create)
  Debug ""
  Debug "---------- Pretty-Printed format ----------"
  Debug ""
  Debug ComposeJSON(#JSON_Create, #PB_JSON_PrettyPrint)
  Debug ""
EndIf


; Read JSON data from a string
;
Input$ = "[1, 3, 5, 7, null, 23, 25, 27]"
If ParseJSON(#JSON_Parse, Input$)
  NewList Numbers()
  ExtractJSONList(JSONValue(#JSON_Parse), Numbers())
  
  Debug "---------- Extracting values ----------"
  Debug ""
  ForEach Numbers()
    Debug Numbers()
  Next
EndIf


