; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BinBase.pb"

;
; container - ContainerGadget()
;
; Accepted keys in the XML:
;
;   All accepted by DlgBinBase
;

Structure DlgContainer Extends DlgBinBase
  BorderWidth.l
  BorderHeight.l
  BorderInClient.l ; whether the border is part of the client area
EndStructure


Procedure DlgContainer_New(*StaticData.DialogObjectData)
  *THIS.DlgContainer = AllocateMemory(SizeOf(DlgContainer))
  
  If *THIS
    *THIS\VTable     = ?DlgContainer_VTable
    *THIS\StaticData = *StaticData
    *THIS\HasTitle   = #False ; for DlgBinBase_Update()
    
    *THIS\Gadget = ContainerGadget(*StaticData\Gadget, 0, 0, 0, 0, *StaticData\Flags)
    
    If *StaticData\Gadget <> -1
      *THIS\Gadget = *StaticData\Gadget
    EndIf
    
    DlgBinBase_GetOptions(*THIS) ; read all the margin etc options
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgContainer_SizeRequest(*THIS.DlgContainer, *Width.LONG, *Height.LONG)
  *THIS\RequestedWidth  = 0
  *THIS\RequestedHeight = 0
  
  If *THIS\Child
    *THIS\Child\SizeRequest(@*THIS\RequestedWidth, @*THIS\RequestedHeight)
  EndIf
  
  CompilerIf #CompileWindows
    If *THIS\StaticData\Flags & #PB_Container_Flat
      *THIS\BorderWidth  = 2
      *THIS\BorderHeight = 2
    ElseIf *THIS\StaticData\Flags <> 0
      *THIS\BorderWidth  = GetSystemMetrics_(#SM_CXBORDER) * 2
      *THIS\BorderHeight = GetSystemMetrics_(#SM_CXBORDER) * 2
    Else
      *THIS\BorderWidth  = 0
      *THIS\BorderHeight = 0
    EndIf
    *THIS\BorderInClient = #True
  CompilerEndIf
  
  CompilerIf #CompileLinux
    ; TODO: Need a good way to calculate border sizes
    ;
    If *THIS\StaticData\Flags = #PB_Container_BorderLess
      *THIS\BorderWidth  = 0 ; no more border around a borderless container
      *THIS\BorderHeight = 0
    Else
      *THIS\BorderWidth  = 8 ; all border types have the same width here
      *THIS\BorderHeight = 8
    EndIf
    *THIS\BorderInClient = #True ; to be tested
  CompilerEndIf
  
  CompilerIf #CompileMacCocoa
    If *THIS\StaticData\Flags = #PB_Container_BorderLess
      *THIS\BorderWidth  = 0
      *THIS\BorderHeight = 0
    Else
      *THIS\BorderWidth  = 16 ; 8px border on all types except borderless
      *THIS\BorderHeight = 16
    EndIf
    *THIS\BorderInClient = #False
  CompilerEndIf
  
  *Width\l  = Max(*THIS\RequestedWidth +*THIS\lMargin+*THIS\lMargin+*THIS\BorderWidth,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*THIS\RequestedHeight+*THIS\tMargin+*THIS\bMargin+*THIS\BorderHeight, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgContainer_SizeApply(*THIS.DlgContainer, x, y, Width, Height)
  ResizeGadget(*THIS\Gadget, x, y, Width, Height)
  
  If *THIS\Child
    If *THIS\BorderInClient
      x = *THIS\BorderWidth / 2 ; need to add an offset from the border
      y = *THIS\BorderHeight / 2
    Else
      x = 0
      y = 0
    EndIf
    
    Width  - *THIS\BorderWidth
    Height - *THIS\BorderHeight
    DlgBinBase_CalculateChildSize(*THIS, @x, @y, @Width, @Height)
    
    *THIS\Child\SizeApply(x, y, Width, Height)
  EndIf
  
EndProcedure



DataSection
  
  DlgContainer_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgContainer_SizeRequest()
  Data.i @DlgContainer_SizeApply()
  Data.i @DlgBinBase_AddChild()
  Data.i @DlgBinBase_FoldApply()
  Data.i @DlgBinBase_Find()
  Data.i @DlgBinBase_Finish()
  Data.i @DlgBinBase_Update()
  Data.i @DlgBinBase_Destroy()
  
EndDataSection