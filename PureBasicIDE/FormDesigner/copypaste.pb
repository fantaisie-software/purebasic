; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Procedure FD_CopyGadget(gadget,parent)
  ChangeCurrentElement(FormWindows()\FormGadgets(),gadget)
  gadgetnum = FormWindows()\FormGadgets()\itemnumber
  AddElement(duplicates())
  duplicates() = FormWindows()\FormGadgets()
  
  AddElement(clipboard())
  oldgadget = FormWindows()\FormGadgets()
  newgadget = clipboard()
  CopyStructure(oldgadget, newgadget, FormGadget)
  clipboard()\variable = FormWindows()\FormGadgets()\variable + "_Copy"
  clipboard()\parent = parent
  
  CopyList(FormWindows()\FormGadgets()\Items(),clipboard()\Items())
  CopyList(FormWindows()\FormGadgets()\Columns(),clipboard()\Columns())
  
  PushListPosition(FormWindows()\FormGadgets())
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\parent = gadgetnum
      ok = 1
      ForEach duplicates()
        If FormWindows()\FormGadgets() = duplicates()
          ok = 0
        EndIf
      Next
      
      If ok
        FD_CopyGadget(FormWindows()\FormGadgets(),newgadget)
      EndIf
      
    EndIf
  Next
  PopListPosition(FormWindows()\FormGadgets())
EndProcedure

Global countpaste
Procedure FD_Copy()
  countpaste = 0
  ClearList(clipboard())
  ClearList(duplicates())
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected And Not FormWindows()\FormGadgets()\splitter And FormWindows()\FormGadgets()\type <> #Form_Type_Splitter
      ok = 1
      ForEach duplicates()
        If FormWindows()\FormGadgets() = duplicates()
          ok = 0
        EndIf
      Next
      
      If ok
        FD_CopyGadget(FormWindows()\FormGadgets(),FormWindows()\FormGadgets()\parent)
      EndIf
    EndIf
  Next
EndProcedure
Procedure FD_Cut()
  FD_Copy()
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      FD_DeleteGadgetA(FormWindows()\FormGadgets())
    EndIf
  Next
  FD_DeleteGadgetB()
  FD_SelectWindow(FormWindows())
  redraw = 1
EndProcedure
Procedure FD_Paste()
  countpaste + 1
  
  If ListSize(clipboard()) > 0
    ClearList(twins())
    ForEach FormWindows()\FormGadgets()
      FormWindows()\FormGadgets()\selected = 0
    Next
    
    LastElement(FormWindows()\FormGadgets())
    pos = ListIndex(FormWindows()\FormGadgets())
    ForEach clipboard()
      AddElement(FormWindows()\FormGadgets())
      AddElement(twins())
      twins()\a = FormWindows()\FormGadgets()\itemnumber
      twins()\b = clipboard()
      
      oldgadget = clipboard()
      newgadget = FormWindows()\FormGadgets()
      CopyStructure(oldgadget, newgadget, FormGadget)
      CopyList(clipboard()\Items(),FormWindows()\FormGadgets()\Items())
      CopyList(clipboard()\Columns(),FormWindows()\FormGadgets()\Columns())
      FormWindows()\FormGadgets()\variable = clipboard()\variable + Str(countpaste)
      
      PushListPosition(FormWindows()\FormGadgets())
      
      parentfound = 0
      
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\itemnumber = clipboard()\parent
          parentfound = 1
        EndIf
      Next
      
      PopListPosition(FormWindows()\FormGadgets())
      
      If parentfound = 1
        FormWindows()\FormGadgets()\parent = clipboard()\parent
        FormWindows()\FormGadgets()\parent_item = clipboard()\parent_item
      EndIf
      
      
      FormWindows()\FormGadgets()\selected = 1
      FormWindows()\FormGadgets()\itemnumber = itemnumbers
      itemnumbers + 1
      
    Next
    FD_SelectGadget(FormWindows()\FormGadgets())
    
    addaction = 1
    ForEach FormWindows()\FormGadgets()
      ForEach twins()
        If FormWindows()\FormGadgets()\parent = twins()\b
          FormWindows()\FormGadgets()\parent = twins()\a
        EndIf
        
        If twins()\a = FormWindows()\FormGadgets()\itemnumber
          FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),#Undo_Create)
          addaction = 0
        EndIf
      Next
    Next
    
    FD_UpdateObjList()
    redraw = 1
    FormChanges(1)
  EndIf
EndProcedure


Procedure FD_CopyEvent()
  temp_clipboard = 0
  If grid_EventEditing(propgrid)
    grid_CopyCellCursorSelection(propgrid)
    grid_SetActiveGadget(propgrid)
    temp_clipboard = 1
  EndIf
  temp_grid = items_grid
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_CopyCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  temp_grid = column_grid
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_CopyCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  temp_grid = prefs_custgadgets
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_CopyCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  If currentview = 1
    ;     FD_CopyCode()
  ElseIf Not temp_clipboard
    FD_Copy()
  EndIf
EndProcedure
Procedure FD_CutEvent()
  temp_clipboard = 0
  If grid_EventEditing(propgrid)
    grid_CutCellCursorSelection(propgrid)
    grid_SetActiveGadget(propgrid)
    temp_clipboard = 1
  EndIf
  temp_grid = items_grid
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_CutCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  temp_grid = column_grid
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_CutCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  temp_grid = prefs_custgadgets
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_CutCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  If currentview = 0 And Not temp_clipboard
    FD_Cut()
  EndIf
EndProcedure
Procedure FD_PasteEvent()
  temp_clipboard = 0
  If grid_EventEditing(propgrid)
    grid_PasteCellCursorSelection(propgrid)
    grid_SetActiveGadget(propgrid)
    temp_clipboard = 1
  EndIf
  temp_grid = items_grid
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_PasteCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  temp_grid = column_grid
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_PasteCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  temp_grid = prefs_custgadgets
  If temp_grid
    If grid_EventEditing(temp_grid)
      grid_PasteCellCursorSelection(temp_grid)
      grid_SetActiveGadget(temp_grid)
      temp_clipboard = 1
    EndIf
  EndIf
  If currentview = 0 And Not temp_clipboard
    FD_Paste()
  EndIf
EndProcedure
Procedure FD_GridClipboardEvent(*grid, MenuID) ; cut/copy/paste shortcut in a separate grid window (items, columns, images)
  If *grid And grid_EventEditing(*grid)
    Select MenuID
      Case #MENU_Cut
        grid_CutCellCursorSelection(*grid)
      Case #MENU_Copy
        grid_CopyCellCursorSelection(*grid)
      Case #MENU_Paste
        grid_PasteCellCursorSelection(*grid)
    EndSelect
    grid_SetActiveGadget(*grid)
  EndIf
EndProcedure
Procedure FD_DuplicateGadget()
  If ListSize(FormWindows())
    
    found = 0
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\selected
        found = 1
        Break
      EndIf
    Next
    
    If found
      countpaste + 1
      
      AddElement(clipboard())
      oldgadget = FormWindows()\FormGadgets()
      newgadget = clipboard()
      CopyStructure(oldgadget, newgadget, FormGadget)
      CopyList(FormWindows()\FormGadgets()\Items(),clipboard()\Items())
      CopyList(FormWindows()\FormGadgets()\Columns(),clipboard()\Columns())
      
      FormWindows()\FormGadgets()\selected = 0
      
      c = CountString(clipboard()\variable, "_")
      If c = 0
        clipboard()\variable = clipboard()\variable + "_"
      EndIf
        
      pos = 0
      For i = 1 To c
        pos = FindString(clipboard()\variable, "_", pos + 1)
      Next
      
      If pos
        clipboard()\variable = Left(clipboard()\variable,pos)
      EndIf
      
      AddElement(FormWindows()\FormGadgets())
      oldgadget = clipboard()
      newgadget = FormWindows()\FormGadgets() 
      CopyStructure(oldgadget, newgadget, FormGadget)
      CopyList(clipboard()\Items(),FormWindows()\FormGadgets()\Items())
      CopyList(clipboard()\Columns(),FormWindows()\FormGadgets()\Columns())
      
      FormWindows()\FormGadgets()\variable = clipboard()\variable + Str(countpaste)
      FormWindows()\FormGadgets()\y1 = clipboard()\y2
      FormWindows()\FormGadgets()\y2 = clipboard()\y2 + (clipboard()\y2 - clipboard()\y1)
      FormWindows()\FormGadgets()\selected = 1
      FormWindows()\FormGadgets()\itemnumber = itemnumbers
      itemnumbers + 1
      FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets(),#Undo_Create)
      DeleteElement(clipboard())
      FD_UpdateObjList()
      FD_SelectGadget(FormWindows()\FormGadgets())
      
      redraw = 1
      
      If propgrid
        grid_SetActiveGadget(propgrid)
        grid_BeginEditing(propgrid, 1, 3)
      EndIf
    EndIf
  EndIf
EndProcedure
