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
  newgadget = clipboard()
  clipboard()\backcolor = FormWindows()\FormGadgets()\backcolor
  clipboard()\caption = FormWindows()\FormGadgets()\caption
  clipboard()\current_item =FormWindows()\FormGadgets()\current_item
  clipboard()\flags = FormWindows()\FormGadgets()\flags
  clipboard()\frontcolor =FormWindows()\FormGadgets()\frontcolor
  clipboard()\g_data = FormWindows()\FormGadgets()\g_data
  clipboard()\gadgetfont = FormWindows()\FormGadgets()\gadgetfont
  clipboard()\gadgetfontflags = FormWindows()\FormGadgets()\gadgetfontflags
  clipboard()\gadgetfontsize = FormWindows()\FormGadgets()\gadgetfontsize
  clipboard()\image = FormWindows()\FormGadgets()\image
  clipboard()\max = FormWindows()\FormGadgets()\max
  clipboard()\min = FormWindows()\FormGadgets()\min
  clipboard()\pbany = FormWindows()\FormGadgets()\pbany
  clipboard()\type = FormWindows()\FormGadgets()\type
  clipboard()\variable = FormWindows()\FormGadgets()\variable + "_Copy"
  clipboard()\x1 = FormWindows()\FormGadgets()\x1
  clipboard()\x2 = FormWindows()\FormGadgets()\x2
  clipboard()\y1 = FormWindows()\FormGadgets()\y1
  clipboard()\y2 = FormWindows()\FormGadgets()\y2
  clipboard()\cust_init = FormWindows()\FormGadgets()\cust_init
  clipboard()\cust_create = FormWindows()\FormGadgets()\cust_create
  clipboard()\cust_free = FormWindows()\FormGadgets()\cust_free
  clipboard()\state = FormWindows()\FormGadgets()\state
  clipboard()\parent = parent
  clipboard()\parent_item = FormWindows()\FormGadgets()\parent_item
  clipboard()\lock_left = FormWindows()\FormGadgets()\lock_left
  clipboard()\lock_right = FormWindows()\FormGadgets()\lock_right
  clipboard()\lock_top = FormWindows()\FormGadgets()\lock_top
  clipboard()\lock_bottom = FormWindows()\FormGadgets()\lock_bottom
  
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
      
      FormWindows()\FormGadgets()\backcolor = clipboard()\backcolor
      FormWindows()\FormGadgets()\caption = clipboard()\caption
      FormWindows()\FormGadgets()\current_item =clipboard()\current_item
      FormWindows()\FormGadgets()\flags = clipboard()\flags
      FormWindows()\FormGadgets()\frontcolor =clipboard()\frontcolor
      FormWindows()\FormGadgets()\g_data = clipboard()\g_data
      FormWindows()\FormGadgets()\gadgetfont = clipboard()\gadgetfont
      FormWindows()\FormGadgets()\gadgetfontflags = clipboard()\gadgetfontflags
      FormWindows()\FormGadgets()\gadgetfontsize = clipboard()\gadgetfontsize
      FormWindows()\FormGadgets()\image = clipboard()\image
      FormWindows()\FormGadgets()\max = clipboard()\max
      FormWindows()\FormGadgets()\min = clipboard()\min
      FormWindows()\FormGadgets()\pbany = clipboard()\pbany
      FormWindows()\FormGadgets()\type = clipboard()\type
      FormWindows()\FormGadgets()\state = clipboard()\state
      FormWindows()\FormGadgets()\variable = clipboard()\variable + Str(countpaste)
      FormWindows()\FormGadgets()\x1 = clipboard()\x1
      FormWindows()\FormGadgets()\x2 = clipboard()\x2
      FormWindows()\FormGadgets()\y1 = clipboard()\y1
      FormWindows()\FormGadgets()\y2 = clipboard()\y2
      FormWindows()\FormGadgets()\cust_init = clipboard()\cust_init
      FormWindows()\FormGadgets()\cust_create = clipboard()\cust_create
      FormWindows()\FormGadgets()\cust_free = clipboard()\cust_free
      
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
      FormWindows()\FormGadgets()\lock_left = clipboard()\lock_left
      FormWindows()\FormGadgets()\lock_right = clipboard()\lock_right
      FormWindows()\FormGadgets()\lock_top = clipboard()\lock_top
      FormWindows()\FormGadgets()\lock_bottom = clipboard()\lock_bottom
      FormWindows()\FormGadgets()\itemnumber = itemnumbers
      itemnumbers + 1
      
      CopyList(clipboard()\Items(),FormWindows()\FormGadgets()\Items())
      CopyList(clipboard()\Columns(),FormWindows()\FormGadgets()\Columns())
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
      clipboard()\backcolor = FormWindows()\FormGadgets()\backcolor
      clipboard()\caption = FormWindows()\FormGadgets()\caption
      clipboard()\current_item =FormWindows()\FormGadgets()\current_item
      clipboard()\flags = FormWindows()\FormGadgets()\flags
      clipboard()\frontcolor =FormWindows()\FormGadgets()\frontcolor
      clipboard()\g_data = FormWindows()\FormGadgets()\g_data
      clipboard()\gadgetfont = FormWindows()\FormGadgets()\gadgetfont
      clipboard()\gadgetfontflags = FormWindows()\FormGadgets()\gadgetfontflags
      clipboard()\gadgetfontsize = FormWindows()\FormGadgets()\gadgetfontsize
      clipboard()\image = FormWindows()\FormGadgets()\image
      clipboard()\max = FormWindows()\FormGadgets()\max
      clipboard()\min = FormWindows()\FormGadgets()\min
      clipboard()\pbany = FormWindows()\FormGadgets()\pbany
      clipboard()\type = FormWindows()\FormGadgets()\type
      clipboard()\variable = FormWindows()\FormGadgets()\variable
      clipboard()\x1 = FormWindows()\FormGadgets()\x1
      clipboard()\x2 = FormWindows()\FormGadgets()\x2
      clipboard()\y1 = FormWindows()\FormGadgets()\y1
      clipboard()\y2 = FormWindows()\FormGadgets()\y2
      clipboard()\cust_init = FormWindows()\FormGadgets()\cust_init
      clipboard()\cust_create = FormWindows()\FormGadgets()\cust_create
      clipboard()\cust_free = FormWindows()\FormGadgets()\cust_free
      clipboard()\state = FormWindows()\FormGadgets()\state
      clipboard()\parent = FormWindows()\FormGadgets()\parent
      clipboard()\parent_item = FormWindows()\FormGadgets()\parent_item
      clipboard()\lock_left = FormWindows()\FormGadgets()\lock_left
      clipboard()\lock_right = FormWindows()\FormGadgets()\lock_right
      clipboard()\lock_top = FormWindows()\FormGadgets()\lock_top
      clipboard()\lock_bottom = FormWindows()\FormGadgets()\lock_bottom
      
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
      FormWindows()\FormGadgets()\backcolor = clipboard()\backcolor
      FormWindows()\FormGadgets()\caption = clipboard()\caption
      FormWindows()\FormGadgets()\current_item =clipboard()\current_item
      FormWindows()\FormGadgets()\flags = clipboard()\flags
      FormWindows()\FormGadgets()\frontcolor =clipboard()\frontcolor
      FormWindows()\FormGadgets()\g_data = clipboard()\g_data
      FormWindows()\FormGadgets()\gadgetfont = clipboard()\gadgetfont
      FormWindows()\FormGadgets()\gadgetfontflags = clipboard()\gadgetfontflags
      FormWindows()\FormGadgets()\gadgetfontsize = clipboard()\gadgetfontsize
      FormWindows()\FormGadgets()\image = clipboard()\image
      FormWindows()\FormGadgets()\max = clipboard()\max
      FormWindows()\FormGadgets()\min = clipboard()\min
      FormWindows()\FormGadgets()\pbany = clipboard()\pbany
      FormWindows()\FormGadgets()\type = clipboard()\type
      FormWindows()\FormGadgets()\state = clipboard()\state
      FormWindows()\FormGadgets()\variable = clipboard()\variable + Str(countpaste)
      FormWindows()\FormGadgets()\x1 = clipboard()\x1
      FormWindows()\FormGadgets()\x2 = clipboard()\x2
      FormWindows()\FormGadgets()\y1 = clipboard()\y2
      FormWindows()\FormGadgets()\y2 = clipboard()\y2 + (clipboard()\y2 - clipboard()\y1)
      FormWindows()\FormGadgets()\cust_init = clipboard()\cust_init
      FormWindows()\FormGadgets()\cust_create = clipboard()\cust_create
      FormWindows()\FormGadgets()\cust_free = clipboard()\cust_free
      FormWindows()\FormGadgets()\parent = clipboard()\parent
      FormWindows()\FormGadgets()\parent_item = clipboard()\parent_item
      FormWindows()\FormGadgets()\selected = 1
      FormWindows()\FormGadgets()\lock_left = clipboard()\lock_left
      FormWindows()\FormGadgets()\lock_right = clipboard()\lock_right
      FormWindows()\FormGadgets()\lock_top = clipboard()\lock_top
      FormWindows()\FormGadgets()\lock_bottom = clipboard()\lock_bottom
      CopyList(clipboard()\Items(),FormWindows()\FormGadgets()\Items())
      CopyList(clipboard()\Columns(),FormWindows()\FormGadgets()\Columns())
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
