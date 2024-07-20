; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
Global imglist_grid
Procedure UpdateImgList()
  grid_DeleteAllRows(imglist_grid)
  
  pos = 0
  If ListSize(FormWindows()) ; Check is there's at least one form opened
    ForEach FormWindows()\FormImg()
      grid_InsertRow(imglist_grid,pos)
      
      grid_SetCellString(imglist_grid,0,pos,FormWindows()\FormImg()\img)
      grid_SetRowCaption(imglist_grid,pos," ")
      grid_SetCellType(imglist_grid,1,pos,#Grid_Cell_Checkbox)
      grid_SetCellState(imglist_grid,1,pos,FormWindows()\FormImg()\inline)
      grid_SetCellType(imglist_grid,2,pos,#Grid_Cell_Checkbox)
      grid_SetCellState(imglist_grid,2,pos,FormWindows()\FormImg()\pbany)
      grid_SetCellType(imglist_grid,3,pos,#Grid_Cell_Custom)
      grid_SetCellState(imglist_grid,3,pos,@DrawButtonB())
      grid_SetCellType(imglist_grid,4,pos,#Grid_Cell_Custom)
      grid_SetCellState(imglist_grid,4,pos,@DrawButtonC())
      pos + 1
    Next
  EndIf
EndProcedure
Procedure InitImgList()
  OpenWindow(#Form_ImgList, 0, 0, 770, 550, Language("Misc","ImageManagerTitle"),#PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_WindowCentered | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget ,WindowID(#WINDOW_Main))
  AddKeyboardShortcut(#Form_ImgList, #PB_Shortcut_Command | #PB_Shortcut_C, #Menu_Copy)
  AddKeyboardShortcut(#Form_ImgList, #PB_Shortcut_Command | #PB_Shortcut_X, #Menu_Cut)
  AddKeyboardShortcut(#Form_ImgList, #PB_Shortcut_Command | #PB_Shortcut_V, #Menu_Paste)
  imglist_grid = GridGadget(0,0,WindowWidth(#Form_ImgList),WindowHeight(#Form_ImgList),#Form_ImgList,5,0,22,100,P_FontGrid,#P_FontGridSize,0)
  grid_SetGadgetAttribute(imglist_grid,#Grid_Scrolling_Horizontal_Disabled,1)
  grid_SetGadgetAttribute(imglist_grid,#Grid_Disable_Delete,1)
  
  grid_SetColumnCaption(imglist_grid,0,Language("Form", "ImageURL"))
  grid_SetColumnWidth(imglist_grid,0,250)
  grid_SetColumnCaption(imglist_grid,1,"CatchImage?")
  grid_SetColumnWidth(imglist_grid,1,100)
  grid_SetColumnCaption(imglist_grid,2,"PBAny?")
  grid_SetColumnWidth(imglist_grid,2,100)
  grid_SetColumnCaption(imglist_grid,3,Language("Form", "SelectImage"))
  grid_SetColumnWidth(imglist_grid,3,110)
  grid_SetColumnCaption(imglist_grid,4,Language("Form", "RelativePath"))
  grid_SetColumnWidth(imglist_grid,4,150)
  
  UpdateImgList()
EndProcedure
Procedure CloseImgList()
  grid_FreeGadget(imglist_grid)
  imglist_grid = 0
  
  CloseWindow(#Form_ImgList)
EndProcedure
Procedure ResizeImgList()
  grid_ResizeGadget(imglist_grid,0,0,WindowWidth(#Form_ImgList),WindowHeight(#Form_ImgList))
EndProcedure
Procedure FormImgListWindowEvents(EventID)
  Select EventID
    Case #PB_Event_SizeWindow
      ResizeImgList()
      
    Case #PB_Event_CloseWindow
      CloseImgList()
      redraw = 1
      
  EndSelect
  
EndProcedure