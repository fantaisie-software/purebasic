; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BinBase.pb"

;
; singlebox
;   A box with just one child. Used only to apply extra margin/alignment properties to a child.
;   Its called a box (as all virtual containers are called that), but it extends DlgBinBase,
;   because these are the properties we want.
;
; Accepted keys in the XML:
;
; all DlgBinBase options
;
;


Structure DlgSinglebox Extends DlgBinBase
EndStructure


Procedure DlgSinglebox_New(*StaticData.DialogObjectData)
  *THIS.DlgSinglebox = AllocateMemory(SizeOf(DlgSinglebox))
  
  If *THIS
    *THIS\VTable     = ?DlgSinglebox_VTable
    *THIS\StaticData = *StaticData
    *THIS\HasTitle   = 0
    
    DlgBinBase_GetOptions(*THIS, 0)
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgSinglebox_SizeRequest(*THIS.DlgSinglebox, *Width.LONG, *Height.LONG)
  *THIS\RequestedWidth  = 0
  *THIS\RequestedHeight = 0
  
  If *THIS\Child
    *THIS\Child\SizeRequest(@*THIS\RequestedWidth, @*THIS\RequestedHeight)
  EndIf
  
  *Width\l  = Max(*THIS\RequestedWidth +*THIS\lMargin+*THIS\lMargin, *THIS\StaticData\MinWidth)
  *Height\l = Max(*THIS\RequestedHeight+*THIS\tMargin+*THIS\bMargin, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgSinglebox_SizeApply(*THIS.DlgSinglebox, x, y, Width, Height)
  If *THIS\Child
    DlgBinBase_CalculateChildSize(*THIS, @x, @y, @Width, @Height)
    *THIS\Child\SizeApply(x, y, Width, Height)
  EndIf
EndProcedure



DataSection
  
  DlgSinglebox_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgSinglebox_SizeRequest()
  Data.i @DlgSinglebox_SizeApply()
  Data.i @DlgBinBase_AddChild()
  Data.i @DlgBinBase_FoldApply()
  Data.i @DlgBinBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgBinBase_Update()
  Data.i @DlgBinBase_Destroy()
  
EndDataSection