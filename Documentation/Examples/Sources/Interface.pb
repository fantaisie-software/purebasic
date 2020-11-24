;
; ------------------------------------------------------------
;
;   PureBasic - Interface
;
;    (c) Fantaisie Software
;
; ------------------------------------------------------------
;


;- =================================
;- Example 1
;- =================================
Debug "***************************"
Debug "*        Example 1        *"
Debug "***************************"

Structure Foo
  *vt                         ;pointer to virtual table as first entry
  intFoo.i
EndStructure

;public menthods
Procedure Foo_SetFoo(*this.foo,value.i)  ;first parameter is the *this pointer
  *this\intFoo = value
EndProcedure

Procedure Foo_GetFoo(*this.foo)
  ProcedureReturn *this\intFoo
EndProcedure

;destructor
Procedure Foo_Free(*this.foo)
  FreeMemory(*this)
EndProcedure

Interface IFoo    ;create interface hides the *this pointer
  Get()
  Set(value.i)
  Free()
EndInterface

DataSection
  vtFoo:    ;create virtual table
  Data.i @Foo_GetFoo()
  Data.i @Foo_SetFoo()
  Data.i @Foo_Free()
EndDataSection

;contructor
Procedure New_Foo()
  Protected *this.foo
  *this = AllocateMemory(SizeOf(foo))
  If *this
    *this\vt = ?vtFoo
    ProcedureReturn *this
  EndIf
EndProcedure

;user declares inteface

Global *myfoo.ifoo = New_Foo()

If *myfoo
  *myfoo\Set(123)
  Debug *myfoo\Get()
  *myfoo\Free()
EndIf
Debug ""



;- =================================
;- Example 2
;- =================================
Debug "***************************"
Debug "*        Example 2        *"
Debug "***************************"

Interface NewRectangle
  Perimeter.i()
  Surface.i()
  Length.i(Valeur)
  Width.i(Valeur)
  Destroy.i()
EndInterface

Structure Rectangle
  *DSVT ;Data Section Virtual Table
  
  Length.i
  Width.i
EndStructure

Procedure.i RectangleInit(Length=0, Width=0)
  Protected *Object.Rectangle
  
  *Object = AllocateMemory(SizeOf(Rectangle))
  
  If *Object
    *Object\DSVT = ?Class
    
    *Object\Length = Length
    *Object\Width = Width
  EndIf
  
  ProcedureReturn *object
EndProcedure


Procedure Perimeter(*this.Rectangle)
  ProcedureReturn (*this\Length + *this\Width) * 2
EndProcedure

Procedure Surface(*this.Rectangle)
  ProcedureReturn *this\Length * *this\Width
EndProcedure

Procedure Length(*this.Rectangle, Valeur)
  *this\Length = Valeur
EndProcedure

Procedure Width(*this.Rectangle, Valeur)
  *this\Width = Valeur
EndProcedure

Procedure Destroy(*this.Rectangle)
  FreeMemory(*this)
EndProcedure

DataSection
  Class:
  Data.i @Perimeter()
  Data.i @Surface()
  Data.i @Length()
  Data.i @Width()
  Data.i @Destroy()
EndDataSection

; How to use it
MyField.NewRectangle = RectangleInit(20,10)

Debug "Perimeter is  " + MyField\Perimeter()
Debug "Surface is  "  + MyField\Surface()

Debug ""

;Let's modify some values
MyField\Length(40)
MyField\Width(20)
Debug "Perimeter is  " + MyField\Perimeter()
Debug "Surface is  "  + MyField\Surface()

MyField\Destroy()
Debug ""