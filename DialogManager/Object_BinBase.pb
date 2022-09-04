; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_Base.pb"

;
; Shared functions for objects with one child. This is no object on its own
;
; Used by: window, container
;
;
; Accepted keys in the XML:
;
; margin = margin around the content (default = 10)
;          can be a single number (= all margin), or a combination of
;          top:<num>,left:<num>,right:<num>,bottom:<num>,vertical:<num>,horizontal:<num>
;          example: "vertical:5,left:10,right:0"
;
; expand = yes        - expand child to fill all space (default)
;          no         - no expanding
;          vertical   - expand vertically only
;          horizontal - expand horizontally only
;
; expandwidth  = max size to expand the children to. If the requested size is larger than
; expandheight   this setting then the request size is used (ie the content does not get smaller)
;                default=0
;
; align  = combination of top,left,bottom,right and center. (only effective when expand <> yes)
;          example: "top,center" or "top,left" (default)
;
;

Structure DlgBinBase Extends DlgBase
  HasTitle.l
  
  StructureUnion
    Child.DialogObject
    *ChildData.DlgBase ; note: only the dlgbase data (mainly the static data) are always present!
  EndStructureUnion
  
  tMargin.l ; user settings
  bMargin.l
  lMargin.l
  rMargin.l
  
  vExpand.l
  hExpand.l
  vExpandMax.l ; <= 0 means no max
  hExpandMax.l
  vAlign.l
  hAlign.l
  
  RequestedWidth.l ; size as requested by the child, without parent margins/borders
  RequestedHeight.l
EndStructure


; Get the number of a value like "TOP:<num>,..."
;
Procedure.l GetSubStringValue(String$, Name$)
  Position = FindString(String$, Name$, 1)
  
  If Position = 0
    ProcedureReturn 0
    
  Else
    *Pointer.Character = @String$ + (Position + Len(Name$) - 1) * SizeOf(Character)
    Value$ = ""
    
    While *Pointer\c >= '0' And *Pointer\c <= '9'
      Value$ + Chr(*Pointer\c)
      *Pointer + 1
    Wend
    
    ProcedureReturn Val(Value$)
  EndIf
  
EndProcedure


; Read the common options (margin, expand, align)
;
Procedure DlgBinBase_GetOptions(*THIS.DlgBinBase, DefaultMargin=10)
  
  *THIS\tMargin = DefaultMargin ; defaults
  *THIS\bMargin = DefaultMargin
  *THIS\rMargin = DefaultMargin
  *THIS\lMargin = DefaultMargin
  
  Value$ = UCase(DialogObjectKey(*THIS\StaticData, "MARGIN"))
  If Value$ <> "" And FindString(Value$, ":", 1) = 0
    *THIS\tMargin = Val(Value$)
    *THIS\bMargin = *THIS\tMargin
    *THIS\rMargin = *THIS\tMargin
    *THIS\lMargin = *THIS\tMargin
  ElseIf Value$ <> ""
    
    *THIS\tMargin = GetSubStringValue(Value$, "TOP:")
    *THIS\bMargin = GetSubStringValue(Value$, "BOTTOM:")
    *THIS\lMargin = GetSubStringValue(Value$, "LEFT:")
    *THIS\rMargin = GetSubStringValue(Value$, "RIGHT:")
    
    If FindString(Value$, "VERTICAL:", 1)
      *THIS\tMargin = GetSubStringValue(Value$, "VERTICAL:")
      *THIS\bMargin = *THIS\tMargin
    EndIf
    If FindString(Value$, "HORIZONTAL:", 1)
      *THIS\lMargin = GetSubStringValue(Value$, "HORIZONTAL:")
      *THIS\rMargin = *THIS\lMargin
    EndIf
    
  EndIf
  
  Value$ = UCase(DialogObjectKey(*THIS\StaticData, "EXPAND"))
  If Value$ = "VERTICAL"
    *THIS\vExpand = #True
  ElseIf Value$ = "HORIZONTAL"
    *THIS\hExpand = #True
  ElseIf Value$ <> "NO"
    *THIS\vExpand = #True
    *THIS\hExpand = #True
  EndIf
  
  Value$ = DialogObjectKey(*THIS\StaticData, "EXPANDWIDTH")
  If Value$ <> ""
    *THIS\hExpandMax = Val(Value$)
  EndIf
  
  Value$ = DialogObjectKey(*THIS\StaticData, "EXPANDHEIGHT")
  If Value$ <> ""
    *THIS\vExpandMax = Val(Value$)
  EndIf
  
  Value$ = UCase(DialogObjectKey(*THIS\StaticData, "ALIGN"))
  If FindString(Value$, "TOP", 1)
    *THIS\vAlign = #Dlg_Align_Top
  EndIf
  If FindString(Value$, "BOTTOM", 1)
    *THIS\vAlign = #Dlg_Align_Bottom
  EndIf
  If FindString(Value$, "LEFT", 1)
    *THIS\hAlign = #Dlg_Align_Top
  EndIf
  If FindString(Value$, "RIGHT", 1)
    *THIS\hAlign = #Dlg_Align_Bottom
  EndIf
  
  If FindString(Value$, "CENTER", 1)
    If *THIS\vAlign = 0  ; set any non-set property to center
      *THIS\vAlign = #Dlg_Align_Center
    EndIf
    If *THIS\hAlign = 0
      *THIS\hAlign = #Dlg_Align_Center
    EndIf
  Else ; set any nonset property to top
    If *THIS\vAlign = 0  ; set any non-set property to center
      *THIS\vAlign = #Dlg_Align_Top
    EndIf
    If *THIS\hAlign = 0
      *THIS\hAlign = #Dlg_Align_Top
    EndIf
  EndIf
  
  
EndProcedure

; Note: x/y must be initialized to any needed border offset
;       width/height must be initialized to the available client size in the parent
;
Procedure DlgBinBase_CalculateChildSize(*THIS.DlgBinBase, *x.LONG, *y.LONG, *Width.LONG, *Height.LONG)
  
  *x\l + *THIS\lMargin
  *y\l + *THIS\tMargin
  *Width\l  - *THIS\lMargin - *THIS\rMargin
  *Height\l - *THIS\tMargin - *THIS\bMargin
  
  FullWidth  = *Width\l
  FullHeight = *Height\l
  
  If FullWidth > *THIS\RequestedWidth
    If *THIS\hExpand = #False
      *Width\l = *THIS\RequestedWidth
    ElseIf *THIS\hExpandMax > 0 And *THIS\hExpandMax < FullWidth
      *Width\l = Max(*THIS\RequestedWidth, *THIS\hExpandMax)
    EndIf
    
    If *THIS\hAlign = #Dlg_Align_Center
      *x\l + (FullWidth - *Width\l) / 2
    ElseIf *THIS\hAlign = #Dlg_Align_Bottom
      *x\l + FullWidth - *Width\l
    EndIf
  EndIf
  
  If FullHeight > *THIS\RequestedHeight
    If *THIS\vExpand = #False
      *Height\l = *THIS\RequestedHeight
    ElseIf *THIS\vExpandMax > 0 And *THIS\vExpandMax < FullHeight
      *Height\l = Max(*THIS\RequestedHeight, *THIS\vExpandMax)
    EndIf
    
    If *THIS\vAlign = #Dlg_Align_Center
      *y\l + (FullHeight - *Height\l) / 2
    ElseIf *THIS\vAlign = #Dlg_Align_Bottom
      *y\l + FullHeight - *Height\l
    EndIf
  EndIf
  
EndProcedure

Procedure DlgBinBase_AddChild(*THIS.DlgBinBase, Child.DialogObject)
  CompilerIf #PB_Compiler_Debugger
    If *THIS\Child
      MessageRequester("Dialog Manager", "Object can only hold one child !")
    EndIf
  CompilerEndIf
  
  *THIS\Child = Child
  *THIS\ChildData\Parent = *THIS
EndProcedure

Procedure DlgBinBase_FoldApply(*THIS.DlgBinBase, State)
  ; hiding is always done, showing only if there is no "fold" tag set on this object too
  If State Or *THIS\Folded = 0
    If *THIS\Gadget
      HideGadget(*THIS\Gadget, State)
    EndIf
    
    If *THIS\Child
      *THIS\Child\FoldApply(State)
    EndIf
  EndIf
EndProcedure


Procedure DlgBinBase_Finish(*THIS.DlgBinBase)
  CloseGadgetList()
EndProcedure



Procedure DlgBinBase_Find(*THIS.DlgBinBase, Name$)
  If DialogObjectName(*THIS\StaticData) = Name$
    ProcedureReturn *THIS ; now returns object pointer
  EndIf
  
  If *THIS\Child
    ProcedureReturn *THIS\Child\Find(Name$)
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure DlgBinBase_Update(*THIS.DlgBinBase)
  If *THIS\HasTitle And *THIS\StaticData\HasText
    SetGadgetText(*THIS\Gadget, DialogObjectText(*THIS\StaticData))
  EndIf
  
  If *THIS\Child
    *THIS\Child\Update()
  EndIf
EndProcedure



Procedure DlgBinBase_Destroy(*THIS.DlgBinBase)
  If *THIS\Child
    *THIS\Child\Destroy()
  EndIf
  
  FreeMemory(*THIS)
EndProcedure
