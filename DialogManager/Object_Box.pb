; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BoxBase.pb"

;
; vbox, hbox
;
; Accepted keys in the XML:
;
; spacing   = space to add between the packed children (default=5)
;
; expand    = yes           - items get bigger to fill all space (default)
;             no            - do not expand to fill all space
;             equal         - force equal sized items
;             item:<number> - expand only one item if space is available
;
; align     = top/left      - only applied when expand="no", top/left is the default
;             center
;             bottom/right
;
;

Structure DlgBox Extends DlgBoxBase
  Spacing.l
  Expand.l
  ExpandItem.l
  Align.l
  
  RequestedSize.l
  FoldedCount.l
  ChildSizes.l[#MAX_CHILDLIST]
EndStructure


Procedure DlgBox_New(*StaticData.DialogObjectData)
  *THIS.DlgBox = AllocateMemory(SizeOf(DlgBox))
  
  If *THIS
    *THIS\VTable     = ?DlgBox_VTable
    *THIS\StaticData = *StaticData
    
    Value$ = DialogObjectKey(*StaticData, "SPACING")
    If Value$
      *THIS\Spacing = Val(Value$)
    Else
      *THIS\Spacing = 5
    EndIf
    
    Value$ = UCase(DialogObjectKey(*StaticData, "EXPAND"))
    If Value$ = "NO"
      *THIS\Expand = #Dlg_Expand_No
    ElseIf Value$ = "EQUAL"
      *THIS\Expand = #Dlg_Expand_Equal
    ElseIf Left(Value$, 5) = "ITEM:"
      *THIS\Expand = #Dlg_Expand_Item
      *THIS\ExpandItem = Val(Right(Value$, Len(Value$)-5)) - 1 ; we coung from 1
    Else
      *THIS\Expand = #Dlg_Expand_Yes
    EndIf
    
    Value$ = UCase(DialogObjectKey(*StaticData, "ALIGN"))
    If Value$ = "CENTER"
      *THIS\Align = #Dlg_Align_Center
    ElseIf Value$ = "BOTTOM" Or Value$ = "RIGHT"
      *THIS\Align = #Dlg_Align_Bottom
    Else
      *THIS\Align = #Dlg_Align_Top
    EndIf
    
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgBox_SizeRequest(*THIS.DlgBox, *Width.LONG, *Height.LONG)
  *Width\l  = 0
  *Height\l = 0
  
  *THIS\FoldedCount = 0
  
  If *THIS\NbChildren > 0
    
    For i = 0 To *THIS\NbChildren-1
      Height = 0
      Width  = 0
      *THIS\Children[i]\SizeRequest(@Width, @Height)
      
      If *THIS\StaticData\Type = #DIALOG_HBox
        *Width\l  + Width
        *Height\l = Max(*Height\l, Height)
        *THIS\ChildSizes[i] = Width
      Else
        *Width\l  = Max(*Width\l, Width)
        *Height\l + Height
        *THIS\ChildSizes[i] = Height
      EndIf
      
      If *THIS\ChildDatas[i]\Folded
        *THIS\FoldedCount + 1
      EndIf
    Next i
    
    If *THIS\NbChildren - *THIS\FoldedCount > 0
      SpaceCount = *THIS\NbChildren - *THIS\FoldedCount - 1
    Else
      SpaceCount = 0
    EndIf
    
    If *THIS\StaticData\Type = #DIALOG_HBox
      *Width\l + *THIS\Spacing * SpaceCount
      *THIS\RequestedSize = *Width\l
    Else
      *Height\l + *THIS\Spacing * SpaceCount
      *THIS\RequestedSize = *Height\l
    EndIf
    
  EndIf
  
  *Width\l  = Max(*Width\l,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgBox_SizeApply(*THIS.DlgBox, x, y, Width, Height)
  
  If *THIS\NbChildren - *THIS\FoldedCount > 0
    VisibleChildren = *THIS\NbChildren - *THIS\FoldedCount
    
    If *THIS\StaticData\Type = #DIALOG_HBox
      Available = Width
    Else
      Available = Height
    EndIf
    
    ; equal sizes are requested
    ;
    If *THIS\Expand = #Dlg_Expand_Equal
      Size = (Available - *THIS\Spacing * (VisibleChildren - 1)) / VisibleChildren
      
      For i = 0 To *THIS\NbChildren-1
        If *THIS\ChildDatas[i]\Folded = 0
          If *THIS\StaticData\Type = #DIALOG_HBox
            *THIS\Children[i]\SizeApply(x, y, Size, Height)
            x + Size + *THIS\Spacing
          Else
            *THIS\Children[i]\SizeApply(x, y, Width, Size)
            y + Size + *THIS\Spacing
          EndIf
        EndIf
      Next i
      
      ; there is not enough space available... all items loose size in percent of what was requested
      ;
    ElseIf Available < *THIS\RequestedSize And Available > 0
      For i = 0 To *THIS\NbChildren-1
        If *THIS\ChildDatas[i]\Folded = 0
          Size = (*THIS\ChildSizes[i] * Available) / *THIS\RequestedSize
          
          If *THIS\StaticData\Type = #DIALOG_HBox
            *THIS\Children[i]\SizeApply(x, y, Size, Height)
            x + Size + *THIS\Spacing
          Else
            *THIS\Children[i]\SizeApply(x, y, Width, Size)
            y + Size + *THIS\Spacing
          EndIf
        EndIf
      Next i
      
      ; normal expanding mode: each item gets the same extra space
      ;
    ElseIf *THIS\Expand = #Dlg_Expand_Yes
      Extra = (Available - *THIS\RequestedSize) / VisibleChildren
      
      For i = 0 To *THIS\NbChildren-1
        If *THIS\ChildDatas[i]\Folded = 0
          If *THIS\StaticData\Type = #DIALOG_HBox
            *THIS\Children[i]\SizeApply(x, y, *THIS\ChildSizes[i] + Extra, Height)
            x + *THIS\ChildSizes[i] + Extra + *THIS\Spacing
          Else
            *THIS\Children[i]\SizeApply(x, y, Width, *THIS\ChildSizes[i] + Extra)
            y + *THIS\ChildSizes[i] + Extra + *THIS\Spacing
          EndIf
        EndIf
      Next i
      
      ; One column or none should grow
      ;
    Else
      If *THIS\Expand = #Dlg_Expand_Item
        Extra = Available - *THIS\RequestedSize
      Else ; no groing at all
        If *THIS\Align = #Dlg_Align_Top
          Extra = 0
        ElseIf *THIS\Align = #Dlg_Align_Center
          Extra = (Available - *THIS\RequestedSize) / 2
        Else
          Extra = Available - *THIS\RequestedSize
        EndIf
        
        If *THIS\StaticData\Type = #DIALOG_HBox ; apply the alignment offset
          x + Extra
        Else
          y + Extra
        EndIf
        
        Extra = 0 ; expand no item at all
      EndIf
      
      For i = 0 To *THIS\NbChildren-1
        If *THIS\ChildDatas[i]\Folded = 0
          If *THIS\ExpandItem = i
            Size = *THIS\ChildSizes[i] + Extra
          Else
            Size = *THIS\ChildSizes[i]
          EndIf
          
          If *THIS\StaticData\Type = #DIALOG_HBox
            *THIS\Children[i]\SizeApply(x, y, Size, Height)
            x + Size + *THIS\Spacing
          Else
            *THIS\Children[i]\SizeApply(x, y, Width, Size)
            y + Size + *THIS\Spacing
          EndIf
        EndIf
      Next i
      
    EndIf
  EndIf
  
EndProcedure



DataSection
  
  DlgBox_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgBox_SizeRequest()
  Data.i @DlgBox_SizeApply()
  Data.i @DlgBoxBase_AddChild()
  Data.i @DlgBoxBase_FoldApply()
  Data.i @DlgBoxBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgBoxBase_Update()
  Data.i @DlgBoxBase_Destroy()
  
EndDataSection