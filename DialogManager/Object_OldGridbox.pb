; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BoxBase.pb"

;
; gridbox - align elements in a table
;
; Accepted keys in the XML:
;
; columns = number of columns (default = 2)
;
; colspacing = space to add between columns/rows (default = 5)
; rowspacing
;
; colexpand = yes           - items get bigger to fill all space
; rowexpand   no            - do not expand to fill all space
;             equal         - force equal sized items
;             item:<number> - expand only one item if space is available
;
;             for colexpand, default=yes, for rowexpand, default=no
;
; Any child within a gridbox can have these keys:
;
; colspan = number of columns to span (default = 1)
; rowspan = number of rows to span
;
;
#MAX_COLUMNS = 20
#MAX_ROWS    = 50

Structure DlgGridBox Extends DlgBoxBase
  Columns.l
  
  colSpacing.l
  rowSpacing.l
  colExpand.l
  rowExpand.l
  colExpandItem.l
  rowExpandItem.l
  
  RequestedWidth.l
  RequestedHeight.l
  colSize.l[#MAX_COLUMNS]
  rowSize.l[#MAX_ROWS]
EndStructure


Procedure DlgGridBox_New(*StaticData.DialogObjectData)
  *THIS.DlgGridBox = AllocateMemory(SizeOf(DlgGridBox))
  
  If *THIS
    *THIS\VTable     = ?DlgGridBox_VTable
    *THIS\StaticData = *StaticData
    
    Value$ = DialogObjectKey(*StaticData, "COLUMNS")
    If Value$
      *THIS\Columns = Val(Value$)
    Else
      *THIS\Columns = 2 ; default value
    EndIf
    
    Value$ = DialogObjectKey(*StaticData, "COLSPACING")
    If Value$
      *THIS\colSpacing = Val(Value$)
    Else
      *THIS\colSpacing = 5
    EndIf
    
    Value$ = DialogObjectKey(*StaticData, "ROWSPACING")
    If Value$
      *THIS\rowSpacing = Val(Value$)
    Else
      *THIS\rowSpacing = 5
    EndIf
    
    Value$ = UCase(DialogObjectKey(*StaticData, "COLEXPAND"))
    If Value$ = "NO"
      *THIS\colExpand = #Dlg_Expand_No
    ElseIf Value$ = "EQUAL"
      *THIS\colExpand = #Dlg_Expand_Equal
    ElseIf Left(Value$, 5) = "ITEM:"
      *THIS\colExpand = #Dlg_Expand_Item
      *THIS\colExpandItem = Val(Right(Value$, Len(Value$)-5)) - 1 ; we coung from 1
    Else
      *THIS\colExpand = #Dlg_Expand_Yes
    EndIf
    
    Value$ = UCase(DialogObjectKey(*StaticData, "ROWEXPAND"))
    If Value$ = "YES"
      *THIS\rowExpand = #Dlg_Expand_Yes
    ElseIf Value$ = "EQUAL"
      *THIS\rowExpand = #Dlg_Expand_Equal
    ElseIf Left(Value$, 5) = "ITEM:"
      *THIS\rowExpand = #Dlg_Expand_Item
      *THIS\rowExpandItem = Val(Right(Value$, Len(Value$)-5)) - 1 ; we coung from 1
    Else
      *THIS\rowExpand = #Dlg_Expand_No
    EndIf
    
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgGridBox_SizeRequest(*THIS.DlgGridBox, *Width.LONG, *Height.LONG)
  *Width\l  = 0
  *Height\l = 0
  
  If *THIS\NbChildren > 0
    
    RowCount = *THIS\NbChildren / *THIS\Columns
    If RowCount * *THIS\Columns < *THIS\NbChildren
      RowCount + 1 ; there are objects that do not fully fill the last row
    EndIf
    
    For i = 0 To *THIS\NbChildren-1
      Width = 0
      Height = 0
      *THIS\Children[i]\SizeRequest(@Width, @Height)
      
      col  = i % *THIS\Columns
      row  = i / *THIS\Columns
      *THIS\colSize[col] = Max(*THIS\colSize[col], Width)
      *THIS\rowSize[row] = Max(*THIS\rowSize[row], Height)
    Next i
    
    *Width\l  = (*THIS\Columns - 1) * *THIS\colSpacing
    *Height\l = (RowCount - 1) * *THIS\rowSpacing
    
    For i = 0 To *THIS\Columns-1
      *Width\l + *THIS\colSize[i]
    Next i
    
    For i = 0 To RowCount-1
      *Height\l + *THIS\rowSize[i]
    Next i
    
    *THIS\RequestedWidth  = *Width\l
    *THIS\RequestedHeight = *Height\l
    
  EndIf
  
  *Width\l  = Max(*Width\l,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgGridBox_SizeApply(*THIS.DlgGridBox, x, y, Width, Height)
  
  If *THIS\NbChildren > 0
    
    RowCount = *THIS\NbChildren / *THIS\Columns
    If RowCount * *THIS\Columns < *THIS\NbChildren
      RowCount + 1 ; there are objects that do not fully fill the last row
    EndIf
    
    Dim RowSize.l(RowCount)
    Dim ColSize.l(*THIS\Columns)
    
    ;
    ; Calculate widths
    ;
    
    ; equal sizing requested
    If *THIS\colExpand = #Dlg_Expand_Equal
      Size = (Width - (*THIS\Columns-1) * *THIS\colSpacing) / *THIS\Columns
      For i = 0 To *THIS\Columns-1
        ColSize(i) = Size
      Next i
      
      ; not enough space anyway
    ElseIf Width < *THIS\RequestedWidth
      If *THIS\RequestedWidth = 0
        *THIS\RequestedWidth = 1 ; prevent division by 0 error
      EndIf
      For i = 0 To *THIS\Columns-1
        ColSize(i) = (*THIS\colSize[i] * Width) / *THIS\RequestedWidth
      Next i
      
      ; normal expanding
    ElseIf *THIS\colExpand = #Dlg_Expand_Yes
      Extra = (Width - *THIS\RequestedWidth) / *THIS\Columns
      For i = 0 To *THIS\Columns-1
        ColSize(i) = *THIS\colSize[i] + Extra
      Next i
      
      ; expand one item only, or no expanding
    Else
      If *THIS\colExpand = #Dlg_Expand_Item
        Extra = Width - *THIS\RequestedWidth
      Else ; no groing at all
        Extra = 0
      EndIf
      
      For i = 0 To *THIS\Columns-1
        If *THIS\colExpandItem = i
          ColSize(i) = *THIS\colSize[i] + Extra
        Else
          ColSize(i) = *THIS\colSize[i]
        EndIf
      Next i
      
    EndIf
    
    
    ;
    ; Calculate height
    ;
    
    ; equal sizing requested
    If *THIS\rowExpand = #Dlg_Expand_Equal
      Size = (Height - (RowCount-1) * *THIS\rowSpacing) / RowCount
      For i = 0 To RowCount-1
        RowSize(i) = Size
      Next i
      
      ; not enough space anyway
    ElseIf Height < *THIS\RequestedHeight
      If *THIS\RequestedHeight = 0
        *THIS\RequestedHeight = 1 ; prevent division by 0 error
      EndIf
      For i = 0 To RowCount-1
        RowSize(i) = (*THIS\rowSize[i] * Height) / *THIS\RequestedHeight
      Next i
      
      ; normal expanding
    ElseIf *THIS\rowExpand = #Dlg_Expand_Yes
      Extra = (Height - *THIS\RequestedHeight) / RowCount
      For i = 0 To RowCount-1
        RowSize(i) = *THIS\rowSize[i] + Extra
      Next i
      
      ; expand one item only, or no expanding
    Else
      If *THIS\rowExpand = #Dlg_Expand_Item
        Extra = Height - *THIS\RequestedHeight
      Else ; no groing at all
        Extra = 0
      EndIf
      
      For i = 0 To RowCount-1
        If *THIS\rowExpandItem = i
          RowSize(i) = *THIS\rowSize[i] + Extra
        Else
          RowSize(i) = *THIS\rowSize[i]
        EndIf
      Next i
      
    EndIf
    
    
    ; Actual Child resizing...
    ;
    For i = 0 To *THIS\NbChildren-1
      col  = i % *THIS\Columns
      row  = i / *THIS\Columns
      posx = x + col * *THIS\colSpacing
      posy = y + row * *THIS\rowSpacing
      For j = 0 To col-1: posx + ColSize(j): Next j
      For j = 0 To row-1: posy + RowSize(j): Next j
      
      *THIS\Children[i]\SizeApply(posx, posy, ColSize(col), RowSize(row))
    Next i
    
  EndIf
  
  
EndProcedure



DataSection
  
  DlgGridBox_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgGridBox_SizeRequest()
  Data.i @DlgGridBox_SizeApply()
  Data.i @DlgBoxBase_AddChild()
  Data.i @DlgBoxBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgBoxBase_Update()
  Data.i @DlgBoxBase_Destroy()
  
EndDataSection