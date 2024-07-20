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
;             for colexpand, Default=yes, For rowexpand, Default=no
;
; Any child within a gridbox can have these keys:
;
; colspan = number of columns to span (default = 1)
; rowspan = number of rows to span
;
;
#MAX_COLUMNS = 15
#MAX_ROWS    = 70

#DlgGrid_Empty = 0 ; used instead of child element pointers for special purposes
#DlgGrid_Span  = 1

Structure DlgGridBoxChild
  Child.DialogObject
  Colspan.l
  Rowspan.l
EndStructure

Structure DlgGridBoxRow
  Cols.DlgGridBoxChild[#MAX_COLUMNS]
EndStructure

Structure DlgGridBox Extends DlgBase
  NbColumns.l
  NbRows.l
  NextChild.l
  
  Rows.DlgGridBoxRow[#MAX_ROWS] ; here the children are stored
  
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
      *THIS\NbColumns = Val(Value$)
    Else
      *THIS\NbColumns = 2 ; default value
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
  MaxWidth = 0
  MaxHeight = 0

  If *THIS\NbRows > 0
    
    For row = 0 To *THIS\NbRows-1
      For col = 0 To *THIS\NbColumns-1
        Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
        
        If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
          Width = 0
          Height = 0
          Child\SizeRequest(@Width, @Height)
          
          ; for now we only count the non-spaning children.
          ; the others are calculated later
          ;
          If *THIS\Rows[row]\Cols[col]\Colspan = 1
            *THIS\colSize[col] = Max(*THIS\colSize[col], Width)
            MaxWidth = Max(*THIS\colSize[col], MaxWidth)
          EndIf
          
          If *THIS\Rows[row]\Cols[col]\Rowspan = 1
            *THIS\rowSize[row] = Max(*THIS\rowSize[row], Height)
            MaxHeight = Max(*THIS\rowSize[row], MaxHeight)
          EndIf
        EndIf
        
      Next col
    Next row

        If *THIS\colExpand = #Dlg_Expand_Equal
          For col = 0 To *THIS\NbColumns-1
             *THIS\colSize[col]=MaxWidth
          Next col
        EndIf
        
        If *THIS\rowExpand = #Dlg_Expand_Equal
                For row = 0 To *THIS\NbRows-1
                        *THIS\rowSize[row]= MaxHeight
                Next row
        EndIf
    
    ; calculate effects by spanning children
    ;
    For row = 0 To *THIS\NbRows-1
      For col = 0 To *THIS\NbColumns-1
        
        If *THIS\Rows[row]\Cols[col]\Colspan > 1 Or *THIS\Rows[row]\Cols[col]\Rowspan > 1
          colspan = *THIS\Rows[row]\Cols[col]\Colspan
          rowspan = *THIS\Rows[row]\Cols[col]\Rowspan
          
          Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
          
          If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
            Width = 0
            Height = 0
            Child\SizeRequest(@Width, @Height)
            
            ; calculate colspan requirements
            ;
            If colspan > 1
              ; calculate size of the spaned columns
              Size = (colspan-1) * *THIS\colSpacing
              For i = 0 To colspan-1
                Size + *THIS\colSize[col+i]
              Next i
              
              ; action is only needed if this is not enough. What to do depends on the expansion mode
              If Size < Width
                
                If *THIS\colExpand = #Dlg_Expand_Equal ; size the columns equally
                  Size = (Width - (colspan-1) * *THIS\colSpacing) / colspan
                  For i = 0 To colspan-1
                    If *THIS\colSize[col+i] < Size ; never decrease a column size, as it could make another spaned object too small again!
                      *THIS\colSize[col+i] = Size
                    EndIf
                  Next i
                  
                ElseIf *THIS\colExpand = #Dlg_Expand_Yes ; normal expanding
                  Size = (Width - Size) / colspan
                  For i = 0 To colspan-1
                    *THIS\colSize[col+i] + Size
                  Next i
                  
                  ; expand one item only (see if it is in our span)
                ElseIf *THIS\colExpand = #Dlg_Expand_Item And (*THIS\colExpandItem >= col And *THIS\colExpandItem < col + colspan)
                  *THIS\colSize[*THIS\colExpandItem] + (Width - Size)
                  
                Else ; no expanding, or above case failed. add the space to the last column
                  *THIS\colSize[col+colspan-1] + (Width - Size)
                  
                EndIf
                
              EndIf
            EndIf
            
            
            ; calculate rowspan requirements
            ;
            If rowspan > 1
              ; calculate size of the spaned columns
              Size = (rowspan-1) * *THIS\rowSpacing
              For i = 0 To rowspan-1
                Size + *THIS\rowSize[row+i]
              Next i
              
              ; action is only needed if this is not enough. What to do depends on the expansion mode
              If Size < Height
                
                If *THIS\rowExpand = #Dlg_Expand_Equal ; size the columns equally
                  Size = (Height - (rowspan-1) * *THIS\rowSpacing) / rowspan
                  For i = 0 To rowspan-1
                    If *THIS\rowSize[row+i] < Size ; never decrease a column size, as it could make another spaned object too small again!
                      *THIS\rowSize[row+i] = Size
                    EndIf
                  Next i
                  
                ElseIf *THIS\rowExpand = #Dlg_Expand_Yes ; normal expanding
                  Size = (Height - Size) / rowspan
                  For i = 0 To rowspan-1
                    *THIS\rowSize[row+i] + Size
                  Next i
                  
                  ; expand one item only (see if it is in our span)
                ElseIf *THIS\rowExpand = #Dlg_Expand_Item And (*THIS\rowExpandItem >= row And *THIS\rowExpandItem < row + rowspan)
                  *THIS\rowSize[*THIS\rowExpandItem] + (Height - Size)
                  
                Else ; no expanding, or above case failed. add the space to the last column
                  *THIS\rowSize[row+rowspan-1] + (Height - Size)
                  
                EndIf
                
              EndIf
            EndIf
            
            
          EndIf
        EndIf
        
      Next col
    Next row
    
    
    *Width\l  = (*THIS\NbColumns - 1) * *THIS\colSpacing
    *Height\l = (*THIS\NbRows - 1) * *THIS\rowSpacing
    
    For i = 0 To *THIS\NbColumns-1
      *Width\l + *THIS\colSize[i]
    Next i
    
    For i = 0 To *THIS\NbRows-1
      *Height\l + *THIS\rowSize[i]
    Next i
    
    *THIS\RequestedWidth  = *Width\l
    *THIS\RequestedHeight = *Height\l
    
  EndIf
  
  *Width\l  = Max(*Width\l,  *THIS\StaticData\MinWidth)
  *Height\l = Max(*Height\l, *THIS\StaticData\MinHeight)
EndProcedure



Procedure DlgGridBox_SizeApply(*THIS.DlgGridBox, x, y, Width, Height)
  
  If *THIS\NbRows > 0
    
    Dim RowSize.l(*THIS\NbRows)
    Dim ColSize.l(*THIS\NbColumns)
    
    ;
    ; Calculate column widths
    ;
    
    ; equal sizing requested
    If *THIS\colExpand = #Dlg_Expand_Equal
      ; when there are too many columns, an integer rounding error is visible (not filling all space)
      ; example: structureviewer
      ; so when there are many columns, calc with float. (only in equal extend mode)
      ;
      If *THIS\NbColumns > 10
        SizeF.f = (Width - (*THIS\NbColumns-1) * *THIS\colSpacing) / *THIS\NbColumns
        For i = 0 To *THIS\NbColumns-1
          ColSize(i) = SizeF * (i + 1) - SizeF * i ; calculate difference between two fields. this way the rounding error gets equally distributed
        Next i
      Else
        Size = (Width - (*THIS\NbColumns-1) * *THIS\colSpacing) / *THIS\NbColumns
        For i = 0 To *THIS\NbColumns-1
          ColSize(i) = Size
        Next i
      EndIf
      
      ; not enough space anyway
    ElseIf Width < *THIS\RequestedWidth And Width > 0
      For i = 0 To *THIS\NbColumns-1
        ColSize(i) = (*THIS\colSize[i] * Width) / *THIS\RequestedWidth
      Next i
      
      ; normal expanding
    ElseIf *THIS\colExpand = #Dlg_Expand_Yes
      Extra = (Width - *THIS\RequestedWidth) / *THIS\NbColumns
      For i = 0 To *THIS\NbColumns-1
        ColSize(i) = *THIS\colSize[i] + Extra
      Next i
      
      ; expand one item only, or no expanding
    Else
      If *THIS\colExpand = #Dlg_Expand_Item
        Extra = Width - *THIS\RequestedWidth
      Else ; no groing at all
        Extra = 0
      EndIf
      
      For i = 0 To *THIS\NbColumns-1
        If *THIS\colExpandItem = i
          ColSize(i) = *THIS\colSize[i] + Extra
        Else
          ColSize(i) = *THIS\colSize[i]
        EndIf
      Next i
      
    EndIf
    
    ;
    ; Calculate row heights
    ;
    
    ; equal sizing requested
    If *THIS\rowExpand = #Dlg_Expand_Equal
      Size = (Height - (*THIS\NbRows-1) * *THIS\rowSpacing) / *THIS\NbRows
      For i = 0 To *THIS\NbRows-1
        RowSize(i) = Size
      Next i
      
      ; not enough space anyway
    ElseIf Height < *THIS\RequestedHeight And Height > 0
      For i = 0 To *THIS\NbRows-1
        RowSize(i) = (*THIS\rowSize[i] * Height) / *THIS\RequestedHeight
      Next i
      
      ; normal expanding
    ElseIf *THIS\rowExpand = #Dlg_Expand_Yes
      Extra = (Height - *THIS\RequestedHeight) / *THIS\NbRows
      For i = 0 To *THIS\NbRows-1
        RowSize(i) = *THIS\rowSize[i] + Extra
      Next i
      
      ; expand one item only, or no expanding
    Else
      If *THIS\rowExpand = #Dlg_Expand_Item
        Extra = Height - *THIS\RequestedHeight
      Else ; no groing at all
        Extra = 0
      EndIf
      
      For i = 0 To *THIS\NbRows-1
        If *THIS\rowExpandItem = i
          RowSize(i) = *THIS\rowSize[i] + Extra
        Else
          RowSize(i) = *THIS\rowSize[i]
        EndIf
      Next i
      
    EndIf
    
    ;
    ; Actual Child resizing...
    ;
    
    For row = 0 To *THIS\NbRows-1
      For col = 0 To *THIS\NbColumns-1
        Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
        If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
          
          posx = x + col * *THIS\colSpacing
          posy = y + row * *THIS\rowSpacing
          For j = 0 To col-1: posx + ColSize(j): Next j
          For j = 0 To row-1: posy + RowSize(j): Next j
          
          colspan = *THIS\Rows[row]\Cols[col]\Colspan
          rowspan = *THIS\Rows[row]\Cols[col]\Rowspan
          Width   = ColSize(col)
          Height  = RowSize(row)
          For j = 1 To colspan-1: Width  + ColSize(col+j) + *THIS\colSpacing: Next j
          For j = 1 To rowspan-1: Height + RowSize(row+j) + *THIS\rowSpacing: Next j
          
          Child\SizeApply(posx, posy, Width, Height)
        EndIf
      Next col
    Next row
    
  EndIf
  
EndProcedure



Procedure DlgGridBox_AddChild(*THIS.DlgGridBox, Child.DialogObject)
  
  ; we must first find a free spot that is not filled with a span dummy
  ;
  row = *THIS\NextChild / *THIS\NbColumns
  col = *THIS\NextChild % *THIS\NbColumns
  
  While *THIS\Rows[row]\Cols[col]\Child <> #DlgGrid_Empty
    *THIS\NextChild + 1
    row = *THIS\NextChild / *THIS\NbColumns
    col = *THIS\NextChild % *THIS\NbColumns
  Wend
  
  ; Add dummy span objects if needed (check the child for that)
  ;
  *ChildData.DlgBase = Child
  colspan = Val(DialogObjectKey(*ChildData\StaticData, "COLSPAN"))
  rowspan = Val(DialogObjectKey(*ChildData\StaticData, "ROWSPAN"))
  If colspan < 1: colspan = 1: EndIf ; each call takes at least one row and column
  If rowspan < 1: rowspan = 1: EndIf
  
  If col + colspan > *THIS\NbColumns ; cannot span more than that
    colspan = *THIS\NbColumns - col
  EndIf
  
  For i = 0 To rowspan-1
    For j = 0 To colspan-1
      *THIS\Rows[row+i]\Cols[col+j]\Child = #DlgGrid_Span ; reserve this cell for the span
    Next j
  Next i
  
  ; set the child. (to the top/left of the spanning area if it is used)
  ;
  *THIS\Rows[row]\Cols[col]\Child   = Child
  *THIS\Rows[row]\Cols[col]\Colspan = colspan
  *THIS\Rows[row]\Cols[col]\Rowspan = rowspan
  *THIS\NextChild + 1
  
  *ChildData\Parent = *THIS
EndProcedure


Procedure DlgGridBox_FoldApply(*THIS.DlgGridBox, State)
  ; hiding is always done, showing only if there is no "fold" tag set on this object too
  If State Or *THIS\Folded = 0
    
    For row = 0 To *THIS\NbRows-1
      For col = 0 To *THIS\NbColumns-1
        Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
        
        If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
          Child\FoldApply(State) ; calling the interface in the structure directly gives an invalid memory access.. bug maybe?
        EndIf
      Next col
    Next row
    
  EndIf
EndProcedure


Procedure DlgGridBox_Finish(*THIS.DlgGridBox)
  
  ; when all children are added, we calculate the number of rows
  ; for easier access later. Note: the last added child can span several rows,
  ; so we cannot simply calculate the value from the NextChild one.
  ;
  For row = 0 To #MAX_ROWS-1
    ; simply check if all columns in this row are empty
    ;
    empty = 1
    
    For col = 0 To *THIS\NbColumns-1
      If *THIS\Rows[row]\Cols[col]\Child <> #DlgGrid_Empty
        empty = 0
        Break
      EndIf
    Next col
    
    If empty
      Break
    EndIf
  Next row
  
  *THIS\NbRows = row
  
EndProcedure



Procedure DlgGridBox_Find(*THIS.DlgGridBox, Name$)
  If DialogObjectName(*THIS\StaticData) = Name$
    ProcedureReturn *THIS ; now returns the object!
  EndIf
  
  For row = 0 To *THIS\NbRows-1
    For col = 0 To *THIS\NbColumns-1
      Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
      
      If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
        result = Child\Find(Name$) ; calling the interface in the structure directly gives an invalid memory access.. bug maybe?
        
        If result
          ProcedureReturn result
        EndIf
      EndIf
      
    Next col
  Next row
  
EndProcedure


Procedure DlgGridBox_Update(*THIS.DlgGridBox)
  For row = 0 To *THIS\NbRows-1
    For col = 0 To *THIS\NbColumns-1
      Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
      If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
        
        Child\Update()
        
      EndIf
    Next col
  Next row
EndProcedure



Procedure DlgGridBox_Destroy(*THIS.DlgGridBox)
  For row = 0 To *THIS\NbRows-1
    For col = 0 To *THIS\NbColumns-1
      Child.DialogObject = *THIS\Rows[row]\Cols[col]\Child
      If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
        
        Child\Destroy()
        
      EndIf
    Next col
  Next row
  
  FreeMemory(*THIS)
EndProcedure




DataSection
  
  DlgGridBox_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgGridBox_SizeRequest()
  Data.i @DlgGridBox_SizeApply()
  Data.i @DlgGridBox_AddChild()
  Data.i @DlgGridBox_FoldApply()
  Data.i @DlgGridBox_Find()
  Data.i @DlgGridBox_Finish()
  Data.i @DlgGridBox_Update()
  Data.i @DlgGridBox_Destroy()
  
EndDataSection
