;
; ------------------------------------------------------------
;
;   PureBasic - Prototype example file
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;

;
; Use prototype with structure
; =============================
;


Prototype.d Object_add(a.d,b.d)

Structure Object
  ADD.Object_add
EndStructure

Procedure.d Object_add(a.d,b.d)
  ProcedureReturn a + b
EndProcedure

Procedure.i new()
  *o.Object = AllocateStructure(Object)
  *o\ADD = @Object_add()
  ProcedureReturn *o
EndProcedure

*test.Object = new()

Debug " Use prototype with structure"
Debug " ======================="
Debug *test\add(53,47) ; Display 100.0
Debug ""
Debug ""

;
; Use prototype to pass Procedure pointer as parameter
; =====================================================
;

Prototype.s ProtoTest()

Procedure.s Test1()
  ProcedureReturn "Hello from test #1"
EndProcedure

Procedure.s Test2()
  ProcedureReturn "Hello from test #2"
EndProcedure


Procedure Run(MyTest.ProtoTest)
  Debug MyTest()
EndProcedure


Debug " Use prototype to pass Procedure pointer as parameter"
Debug " ==============================================="
Run(@Test1())
Run(@Test2())


;old fashon
Procedure.s test()
  ProcedureReturn "test"
EndProcedure

Procedure runold(ptr) ; Assume ptr is the procedure pointer
  Debug PeekS(CallFunctionFast(ptr))
EndProcedure

runold(@test())