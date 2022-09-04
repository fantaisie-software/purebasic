; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_Base.pb"

;
; Shared functions for objects with multiple children. This is no object on its own
;
; Used by: vbox, hbox, multibox, gridbox
;


Structure DlgBoxBase Extends DlgBase
  NbChildren.l
  
  StructureUnion
    Children.DialogObject[#MAX_CHILDLIST]
    *ChildDatas.DlgBase[#MAX_CHILDLIST]
  EndStructureUnion
EndStructure


Procedure DlgBoxBase_AddChild(*THIS.DlgBoxBase, Child.DialogObject)
  CompilerIf #PB_Compiler_Debugger
    If *THIS\NbChildren >= #MAX_CHILDLIST
      MessageRequester("Dialog Manager", "Too many immediate child items (" + Str(#MAX_CHILDLIST) + ") !")
    EndIf
  CompilerEndIf
  
  *THIS\Children[*THIS\NbChildren] = Child
  *THIS\ChildDatas[*THIS\NbChildren]\Parent = *THIS
  *THIS\NbChildren + 1
EndProcedure


Procedure DlgBoxBase_FoldApply(*THIS.DlgBoxBase, State)
  ; hiding is always done, showing only if there is no "fold" tag set on this object too
  If State Or *THIS\Folded = 0
    If *THIS\Gadget
      HideGadget(*THIS\Gadget, State)
    EndIf
    
    For i = 0 To *THIS\NbChildren-1
      *THIS\Children[i]\FoldApply(State)
    Next i
  EndIf
EndProcedure



Procedure DlgBoxBase_Find(*THIS.DlgBoxBase, Name$)
  If DialogObjectName(*THIS\StaticData) = Name$
    ProcedureReturn *THIS ; now returns the object pointer!
  EndIf
  
  For i = 0 To *THIS\NbChildren-1
    Result = *THIS\Children[i]\Find(Name$)
    If Result <> 0
      ProcedureReturn Result
    EndIf
  Next i
EndProcedure


Procedure DlgBoxBase_Update(*THIS.DlgBoxBase)
  If *THIS\Gadget And *THIS\StaticData\HasText
    SetGadgetText(*THIS\Gadget, DialogObjectText(*THIS\StaticData))
  EndIf
  
  For i = 0 To *THIS\NbChildren-1
    *THIS\Children[i]\Update()
  Next i
EndProcedure



Procedure DlgBoxBase_Destroy(*THIS.DlgBoxBase)
  For i = 0 To *THIS\NbChildren-1
    *THIS\Children[i]\Destroy()
  Next i
  
  FreeMemory(*THIS)
EndProcedure



