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
;   The Children will always get the size they ask for, except if scrolling is set to one
;   direction only and the gadget cannot grow.
;
; innerheight = inner minimal height (-1 = do not change)
; innerwidth  = inner minimal width  (-1 = do not change)
; step        = scrollstep value (default = 10)
;
; scrolling   = horizontal/vertical/both (default)
;               force only one direction to be scrollable. the gadget will try to grow big
;               enough to show all content in the other direction
;

Enumeration
  #DlgScroll_Both
  #DlgScroll_Vertical
  #DlgScroll_Horizontal
EndEnumeration

Structure DlgScroll Extends DlgBinBase
  InnerWidth.l
  InnerHeight.l
  Scrolling.l
EndStructure


Procedure DlgScroll_New(*StaticData.DialogObjectData)
  *THIS.DlgScroll = AllocateMemory(SizeOf(DlgScroll))
  
  If *THIS
    *THIS\VTable      = ?DlgScroll_VTable
    *THIS\StaticData  = *StaticData
    *THIS\HasTitle    = #False ; for DlgBinBase_Update()
    *THIS\InnerWidth  = Val(DialogObjectKey(*StaticData, "INNERWIDTH"))
    *THIS\InnerHeight = Val(DialogObjectKey(*StaticData, "INNERHEIGHT"))
    
    Value$ = DialogObjectKey(*StaticData, "STEP")
    If Value$
      ScrollStep = Val(Value$)
    Else
      ScrollStep = 10
    EndIf
    
    Value$ = UCase(DialogObjectKey(*StaticData, "SCROLLING"))
    If Value$ = "VERTICAL"
      *THIS\Scrolling = #DlgScroll_Vertical
    ElseIf Value$ = "HORIZONTAL"
      *THIS\Scrolling = #DlgScroll_Horizontal
    Else
      *THIS\Scrolling = #DlgScroll_Both
    EndIf
    
    DisableDebugger
    *THIS\Gadget = ScrollAreaGadget(*StaticData\Gadget, 0, 0, 0, 0, *THIS\InnerWidth, *THIS\InnerHeight, ScrollStep, *StaticData\Flags)
    EnableDebugger
    
    If *StaticData\Gadget <> -1
      *THIS\Gadget = *StaticData\Gadget
    EndIf
    
    DlgBinBase_GetOptions(*THIS) ; read all the margin etc options
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgScroll_SizeRequest(*THIS.DlgScroll, *Width.LONG, *Height.LONG)
  *THIS\RequestedWidth  = 0
  *THIS\RequestedHeight = 0
  
  If *THIS\Child
    *THIS\Child\SizeRequest(@*THIS\RequestedWidth, @*THIS\RequestedHeight)
  EndIf
  
  ; TODO: maybe measure the real sizes of the scrollbars
  If *THIS\Scrolling = #DlgScroll_Vertical
    *Width\l  = Max(*THIS\RequestedWidth + 22+*THIS\lMargin+*THIS\rMargin, *THIS\StaticData\MinWidth)
    *Height\l = *THIS\StaticData\MinHeight
  ElseIf *THIS\Scrolling = #DlgScroll_Horizontal
    *Width\l  = *THIS\StaticData\MinWidth
    *Height\l = Max(*THIS\RequestedHeight + 22+*THIS\tMargin+*THIS\bMargin, *THIS\StaticData\MinHeight)
  Else
    *Width\l  = *THIS\StaticData\MinWidth
    *Height\l = *THIS\StaticData\MinHeight
  EndIf
EndProcedure



Procedure DlgScroll_SizeApply(*THIS.DlgScroll, x, y, Width, Height)
  ResizeGadget(*THIS\Gadget, x, y, Width, Height)
  
  AreaWidth  = Max(*THIS\RequestedWidth +*THIS\lMargin+*THIS\rMargin, *THIS\InnerWidth)
  AreaHeight = Max(*THIS\RequestedHeight+*THIS\tMargin+*THIS\bMargin, *THIS\InnerHeight)
  
  If *THIS\Scrolling = #DlgScroll_Vertical
    AreaWidth = Width - 22
  ElseIf *THIS\Scrolling = #DlgScroll_Horizontal
    AreaHeight = Height - 22
  EndIf
  
  If *THIS\InnerWidth <> -1
    SetGadgetAttribute(*THIS\Gadget, #PB_ScrollArea_InnerWidth,  AreaWidth)
  EndIf
  
  If *THIS\InnerHeight <> -1
    SetGadgetAttribute(*THIS\Gadget, #PB_ScrollArea_InnerHeight, AreaHeight)
  EndIf
  
  If *THIS\Child
    x = 0
    y = 0
    Width  = AreaWidth
    Height = AreaHeight
    DlgBinBase_CalculateChildSize(*THIS, @x, @y, @Width, @Height)
    *THIS\Child\SizeApply(x, y, Width, Height)
  EndIf
  
EndProcedure



DataSection
  
  DlgScroll_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgScroll_SizeRequest()
  Data.i @DlgScroll_SizeApply()
  Data.i @DlgBinBase_AddChild()
  Data.i @DlgBinBase_FoldApply()
  Data.i @DlgBinBase_Find()
  Data.i @DlgBinBase_Finish()
  Data.i @DlgBinBase_Update()
  Data.i @DlgBinBase_Destroy()
  
EndDataSection