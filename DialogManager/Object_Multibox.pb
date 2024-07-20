; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BoxBase.pb"

;
; multibox
;   A box with multiple children in the same position. Used to put multiple containers
;   inside and show only one of them at a time.
;
; Accepted keys in the XML:
;
; only the default options
;
;


Structure DlgMultibox Extends DlgBoxBase
EndStructure


Procedure DlgMultibox_New(*StaticData.DialogObjectData)
  *THIS.DlgMultibox = AllocateMemory(SizeOf(DlgMultibox))
  
  If *THIS
    *THIS\VTable     = ?DlgMultibox_VTable
    *THIS\StaticData = *StaticData
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgMultibox_SizeRequest(*THIS.DlgMultibox, *Width.LONG, *Height.LONG)
  *Width\l  = 0
  *Height\l = 0
  
  For i = 0 To *THIS\NbChildren-1
    Height = 0
    Width  = 0
    
    *THIS\Children[i]\SizeRequest(@Width, @Height)
    
    *Width\l  = Max(*Width\l,  Width)
    *Height\l = Max(*Height\l, Height)
  Next i
  
  
  *Width\l  = Max(*Width\l,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgMultibox_SizeApply(*THIS.DlgMultibox, x, y, Width, Height)
  For i = 0 To *THIS\NbChildren-1
    *THIS\Children[i]\SizeApply(x, y, Width, Height)
  Next i
EndProcedure



DataSection
  
  DlgMultibox_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgMultibox_SizeRequest()
  Data.i @DlgMultibox_SizeApply()
  Data.i @DlgBoxBase_AddChild()
  Data.i @DlgBoxBase_FoldApply()
  Data.i @DlgBoxBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgBoxBase_Update()
  Data.i @DlgBoxBase_Destroy()
  
EndDataSection