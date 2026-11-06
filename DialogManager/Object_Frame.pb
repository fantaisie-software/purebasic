; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BinBase.pb"

;
; frame - Frame3dGadget()
;
; Accepted keys in the XML:
;
;   All accepted by DlgBinBase
;
; Note: The 'flags' Key is ignored here, as only the standard frame is supported (to calculate sized)
;       To get a single/double/flat frame, use a Container.
;

Structure DlgFrame Extends DlgBinBase
  BorderTop.l
  BorderBottom.l
  BorderLeft.l
  BorderRight.l
EndStructure


Procedure DlgFrame_New(*StaticData.DialogObjectData)
  *THIS.DlgFrame = AllocateMemory(SizeOf(DlgFrame))
  
  If *THIS
    *THIS\VTable     = ?DlgFrame_VTable
    *THIS\StaticData = *StaticData
    *THIS\HasTitle   = #True ; for DlgBinBase_Update()
    
    *THIS\Gadget = FrameGadget(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData))
    
    If *StaticData\Gadget <> -1
      *THIS\Gadget = *StaticData\Gadget
    EndIf
    
    DlgBinBase_GetOptions(*THIS, 5) ; read all the margin etc options
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgFrame_SizeRequest(*THIS.DlgFrame, *Width.LONG, *Height.LONG)
  *THIS\RequestedWidth  = 0
  *THIS\RequestedHeight = 0
  
  If *THIS\Child
    *THIS\Child\SizeRequest(@*THIS\RequestedWidth, @*THIS\RequestedHeight)
  EndIf
  
  CompilerIf #CompileMacCocoa
    
    *This\BorderTop    = Frame3DTopOffset(*This\Gadget)
    *THIS\BorderBottom = 8
    *THIS\BorderLeft   = 8
    *THIS\BorderRight  = 8
    
  CompilerElse
    
    *This\BorderTop    = Frame3DTopOffset(*This\Gadget)
    *THIS\BorderBottom = 4
    *THIS\BorderLeft   = 4
    *THIS\BorderRight  = 4
    
  CompilerEndIf
  
  *Width\l  = Max(*THIS\RequestedWidth +*THIS\lMargin+*THIS\lMargin+*THIS\BorderLeft+*THIS\BorderRight,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*THIS\RequestedHeight+*THIS\tMargin+*THIS\bMargin+*THIS\BorderTop+*THIS\BorderBottom, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgFrame_SizeApply(*THIS.DlgFrame, x, y, Width, Height)
  ResizeGadget(*THIS\Gadget, x, y, Width, Height)
  
  If *THIS\Child
    x + *THIS\BorderLeft
    y + *THIS\BorderTop
    Width  - (*THIS\BorderLeft + *THIS\BorderRight)
    Height - (*THIS\BorderTop + *THIS\BorderBottom)
    DlgBinBase_CalculateChildSize(*THIS, @x, @y, @Width, @Height)
    
    *THIS\Child\SizeApply(x, y, Width, Height)
  EndIf
  
EndProcedure



DataSection
  
  DlgFrame_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgFrame_SizeRequest()
  Data.i @DlgFrame_SizeApply()
  Data.i @DlgBinBase_AddChild()
  Data.i @DlgBinBase_FoldApply()
  Data.i @DlgBinBase_Find()
  Data.i @DlgBase_Finish() ; no Gadgetlist to close.
  Data.i @DlgBinBase_Update()
  Data.i @DlgBinBase_Destroy()
  
EndDataSection