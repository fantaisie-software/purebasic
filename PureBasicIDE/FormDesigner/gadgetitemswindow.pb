; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
Global items_gadget, items_grid
Procedure FD_UpdateItems()
  grid_DeleteAllRows(items_grid)
  PushListPosition(FormWindows()\FormGadgets())
  ChangeCurrentElement(FormWindows()\FormGadgets(),items_gadget)
  
  pos = 0
  ForEach FormWindows()\FormGadgets()\Items()
    grid_InsertRow(items_grid,pos)
    grid_SetCellString(items_grid,0,pos,FormWindows()\FormGadgets()\Items()\name)
    grid_SetRowCaption(items_grid,pos," ")
    grid_SetCellString(items_grid,1,pos,Str(FormWindows()\FormGadgets()\Items()\level))
    grid_SetCellType(items_grid,2,pos,#Grid_Cell_Custom)
    grid_SetCellState(items_grid,2,pos,@DrawUp())
    grid_SetCellType(items_grid,3,pos,#Grid_Cell_Custom)
    grid_SetCellState(items_grid,3,pos,@DrawDown())
    grid_SetCellType(items_grid,4,pos,#Grid_Cell_Custom)
    grid_SetCellState(items_grid,4,pos,@DrawDelete())
    pos + 1
  Next
  grid_InsertRow(items_grid,pos)
  grid_SetRowCaption(items_grid,pos,"*")
  
  PopListPosition(FormWindows()\FormGadgets())
EndProcedure
Procedure FD_InitItems()
  DisableWindow(#WINDOW_Main, #True) ; Important to disable the main window or it can lead to some issues: https://www.purebasic.fr/english/viewtopic.php?p=471724#p471724
  
  Define Title$, ID$
  
  If FormWindows()\FormGadgets()\pbany
    ID$ = FormWindows()\FormGadgets()\variable
  Else
    ID$ = "#" + FormWindows()\FormGadgets()\variable
  EndIf
  Title$ = ReplaceString(Language("Form","EditItemsTitle"), "%id%", ID$)
  
  OpenWindow(#Form_Items, 0, 0, 600, 400, Title$, #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_WindowCentered | #PB_Window_SizeGadget, WindowID(#WINDOW_Main))
  AddKeyboardShortcut(#Form_Items, #PB_Shortcut_Command | #PB_Shortcut_C, #Menu_Copy)
  AddKeyboardShortcut(#Form_Items, #PB_Shortcut_Command | #PB_Shortcut_X, #Menu_Cut)
  AddKeyboardShortcut(#Form_Items, #PB_Shortcut_Command | #PB_Shortcut_V, #Menu_Paste)
  items_grid = GridGadget(0,0,WindowWidth(#Form_Items),WindowHeight(#Form_Items),#Form_Items,5,0,22,100,P_FontGrid,#P_FontGridSize,0)
  grid_SetGadgetAttribute(items_grid,#Grid_Scrolling_Horizontal_Disabled,1)
  grid_SetGadgetAttribute(items_grid,#Grid_Disable_Delete,1)
  
  grid_SetColumnCaption(items_grid,0,Language("Form", "Item"))
  grid_SetColumnWidth(items_grid,0,300)
  If FormWindows()\FormGadgets()\type = #Form_Type_TreeGadget
    grid_SetColumnCaption(items_grid,1,Language("Form", "Level"))
  Else
    grid_SetColumnCaption(items_grid,1,Language("Form", "N/A"))
  EndIf
  grid_SetColumnWidth(items_grid,1,50)
  grid_SetColumnCaption(items_grid,2," ")
  grid_SetColumnWidth(items_grid,2,22)
  grid_SetColumnCaption(items_grid,3," ")
  grid_SetColumnWidth(items_grid,3,22)
  grid_SetColumnCaption(items_grid,4," ")
  grid_SetColumnWidth(items_grid,4,22)
  
  FD_UpdateItems()
EndProcedure

Procedure FD_CloseItems()
  grid_FreeGadget(items_grid)
  items_grid = 0
  
  CloseWindow(#Form_Items)
  FD_UpdateObjList()
  
  DisableWindow(#WINDOW_Main, #False)
EndProcedure

Procedure FD_ResizeItems()
  grid_ResizeGadget(items_grid,0,0,WindowWidth(#Form_Items),WindowHeight(#Form_Items))
EndProcedure

Global column_gadget, column_grid
Procedure FD_UpdateColumns()
  grid_DeleteAllRows(column_grid)
  PushListPosition(FormWindows()\FormGadgets())
  ChangeCurrentElement(FormWindows()\FormGadgets(),column_gadget)
  
  pos = 0
  ForEach FormWindows()\FormGadgets()\Columns()
    grid_InsertRow(column_grid,pos)
    grid_SetCellString(column_grid,0,pos,FormWindows()\FormGadgets()\Columns()\name)
    grid_SetCellString(column_grid,1,pos,Str(FormWindows()\FormGadgets()\Columns()\width))
    grid_SetRowCaption(column_grid,pos," ")
    grid_SetCellType(column_grid,2,pos,#Grid_Cell_Custom)
    grid_SetCellState(column_grid,2,pos,@DrawUp())
    grid_SetCellType(column_grid,3,pos,#Grid_Cell_Custom)
    grid_SetCellState(column_grid,3,pos,@DrawDown())
    grid_SetCellType(column_grid,4,pos,#Grid_Cell_Custom)
    grid_SetCellState(column_grid,4,pos,@DrawDelete())
    pos + 1
  Next
  grid_InsertRow(column_grid,pos)
  grid_SetRowCaption(column_grid,pos,"*")
  
  PopListPosition(FormWindows()\FormGadgets())
EndProcedure
Procedure FD_InitColumns()
  
  Define Title$, ID$
  
  If FormWindows()\FormGadgets()\pbany
    ID$ = FormWindows()\FormGadgets()\variable
  Else
    ID$ = "#" + FormWindows()\FormGadgets()\variable
  EndIf
  Title$ = ReplaceString(Language("Form","EditColumnsTitle"), "%id%", ID$)
  
  OpenWindow(#Form_Columns, 0, 0, 600, 400, Title$,#PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_WindowCentered | #PB_Window_SizeGadget,WindowID(#WINDOW_Main))
  AddKeyboardShortcut(#Form_Columns, #PB_Shortcut_Command | #PB_Shortcut_C, #Menu_Copy)
  AddKeyboardShortcut(#Form_Columns, #PB_Shortcut_Command | #PB_Shortcut_X, #Menu_Cut)
  AddKeyboardShortcut(#Form_Columns, #PB_Shortcut_Command | #PB_Shortcut_V, #Menu_Paste)
  column_grid = GridGadget(0,0,WindowWidth(#Form_Columns),WindowHeight(#Form_Columns),#Form_Columns,5,0,22,100,P_FontGrid,#P_FontGridSize,0)
  grid_SetGadgetAttribute(column_grid,#Grid_Scrolling_Horizontal_Disabled,1)
  grid_SetGadgetAttribute(column_grid,#Grid_Disable_Delete,1)
  
  grid_SetColumnCaption(column_grid,0,Language("Form", "Item"))
  grid_SetColumnWidth(column_grid,0,400)
  grid_SetColumnCaption(column_grid,1,Language("Form", "Width"))
  grid_SetColumnWidth(column_grid,1,100)
  grid_SetColumnCaption(column_grid,2," ")
  grid_SetColumnWidth(column_grid,2,22)
  grid_SetColumnCaption(column_grid,3," ")
  grid_SetColumnWidth(column_grid,3,22)
  grid_SetColumnCaption(column_grid,4," ")
  grid_SetColumnWidth(column_grid,4,22)
  
  FD_UpdateColumns()
EndProcedure
Procedure FD_CloseColumns()
  grid_FreeGadget(column_grid)
  column_grid = 0
  
  CloseWindow(#Form_Columns)
  FD_UpdateObjList()
EndProcedure
Procedure FD_ResizeColumns()
  grid_ResizeGadget(column_grid,0,0,WindowWidth(#Form_Columns),WindowHeight(#Form_Columns))
EndProcedure

Procedure FormColumnsWindowEvents(EventID)
  Select EventID
    Case #PB_Event_SizeWindow
      FD_ResizeColumns()
      
    Case #PB_Event_CloseWindow
      FD_CloseColumns()
      redraw = 1
      
  EndSelect
EndProcedure


Procedure FormItemsWindowEvents(EventID)
  Select EventID
    Case #PB_Event_SizeWindow
      FD_ResizeItems()
      
    Case #PB_Event_CloseWindow
      FD_CloseItems()
      redraw = 1
      
  EndSelect
EndProcedure
