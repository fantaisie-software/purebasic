; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure FD_InitBasicPropGridRows(gadget = 0)
  
  grid_SetGadgetColor(propgrid, #Grid_Color_LineLight, grid_color_light)
  
  PropGridAddNode(propgrid, i, "Properties")
  i + 1
  
  PropGridAddItem(propgrid, i, "#PB_Any")
  grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
  i+1
  
  PropGridAddItem(propgrid, i, Language("Form", "Variable"))
  i+1
  
  PropGridAddItem(propgrid, i, Language("Form", "CaptionIsVariable"))
  grid_SetCellType(propgrid, 2, i, #Grid_Cell_Checkbox)
  i+1
  
  PropGridAddItem(propgrid, i, Language("Form", "Caption"))
  i+1
  
  If gadget
    PropGridAddItem(propgrid, i, Language("Form", "TooltipIsVariable"))
    grid_SetCellType(propgrid, 2, i, #Grid_Cell_Checkbox)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Tooltip"))
    i + 1
  EndIf
  
  PropGridAddNode(propgrid, i, "Layout")
  i + 1
  
  PropGridAddItem(propgrid, i, "X")
  i + 1
  
  PropGridAddItem(propgrid, i, "Y")
  i + 1
  
  PropGridAddItem(propgrid, i, Language("Form", "Width"))
  i + 1
  
  PropGridAddItem(propgrid, i, Language("Form", "Height"))
  i + 1
  
  PropGridAddItem(propgrid, i, Language("Form", "Hidden"))
  grid_SetCellType(propgrid, 2, i, #Grid_Cell_Checkbox)
  i + 1
  
  PropGridAddItem(propgrid, i, Language("Form", "Disabled"))
  grid_SetCellType(propgrid, 2, i, #Grid_Cell_Checkbox)
  i + 1
  
EndProcedure
Procedure FD_Init()
  
  CatchImage(#Img_Delete,?delete)
  CatchImage(#Img_Up,?up)
  CatchImage(#Img_Down,?down)
  CatchImage(#Img_Combo,?combodblarrows)
  CatchImage(#Img_Spin,?spin)
  CatchImage(#Img_Date,?date)
  
  ; osx
  CatchImage(#Img_MacClose,?macclose)
  CatchImage(#Img_MacDis,?macdis)
  CatchImage(#Img_MacMax,?macmax)
  CatchImage(#Img_MacMin,?macmin)
  CatchImage(#Img_MacCheckbox,?maccheckbx)
  CatchImage(#Img_MacCheckboxSel,?maccheckbxsel)
  CatchImage(#Img_MacOption,?macoption)
  CatchImage(#Img_MacOptionSel,?macoptionsel)
  CatchImage(#Img_MacTrackbar,?mactrackbar)
  CatchImage(#Img_MacTrackbarV,?mactrackbarv)
  CatchImage(#Img_MacSubMenu,?submenu)
  
  ; linux
  CatchImage(#Img_LinuxClose,?linuxclose)
  CatchImage(#Img_LinuxMax,?linuxmax)
  CatchImage(#Img_LinuxMin,?linuxmin)
  
  ; windows 7
  CatchImage(#Img_Win7Close,?win7close)
  CatchImage(#Img_Win7MaxDis,?win7maxdis)
  CatchImage(#Img_Win7MinDis,?win7mindis)
  CatchImage(#Img_Win7Max,?win7max)
  CatchImage(#Img_Win7Min,?win7min)
  CatchImage(#Img_Win7Checkbox,?win7checkbx)
  CatchImage(#Img_Win7CheckboxSel,?win7checkbxsel)
  CatchImage(#Img_Win7Option,?win7option)
  CatchImage(#Img_Win7OptionSel,?win7optionsel)
  CatchImage(#Img_Win7Trackbar,?win7trackbar)
  CatchImage(#Img_Win7TrackbarV,?win7trackbarv)
  
  ; windows 8
  CatchImage(#Img_Win8Close,?win8close)
  CatchImage(#Img_Win8Max,?win8max)
  CatchImage(#Img_Win8Min,?win8min)
  CatchImage(#Img_Win8Checkbox,?win8checkbx)
  CatchImage(#Img_Win8CheckboxSel,?win8checkbxsel)
  CatchImage(#Img_Win8Option,?win8option)
  CatchImage(#Img_Win8OptionSel,?win8optionsel)
  CatchImage(#Img_Win8Spin,?win8spin)
  CatchImage(#Img_Win8ArrowDown,?win8arrowdown)
  CatchImage(#Img_Win8ScrollDown,?win8scrolldown)
  CatchImage(#Img_Win8ScrollUp,?win8scrollup)
  CatchImage(#Img_Win8ScrollLeft,?win8scrollleft)
  CatchImage(#Img_Win8ScrollRight,?win8scrollright)
  
  CatchImage(#Img_WindowsIcon,?winicon)
  CatchImage(#Img_ScrollDown,?scrolldown)
  CatchImage(#Img_ScrollUp,?scrollup)
  CatchImage(#Img_ScrollLeft,?scrollleft)
  CatchImage(#Img_ScrollRight,?scrollright)
  CatchImage(#Img_ArrowDown,?arrowdown)
  
  CatchImage(#Img_Plus,?plus)
  CreateImage(#Drawing_Img,400,400)
  
  ; TODO This menu may be unused, follow up. 
  CreatePopupMenu(#Form_Menu0)
  MenuItem(#Menu_Rename,Language("Form", "Rename"))
  MenuItem(#Menu_DeleteFormObj,Language("Form", "Delete"))
  MenuBar()
  MenuItem(#Menu_Cut,Language("Form", "Cut"))
  MenuItem(#Menu_Copy,Language("Form", "Copy"))
  MenuItem(#Menu_Paste,Language("Form", "Paste"))
  
  CreatePopupMenu(#Form_Menu1)
  MenuItem(#Menu_DeleteFormObj,Language("Form", "Delete"))
  MenuBar()
  MenuItem(#Menu_Cut,Language("Form", "Cut"))
  MenuItem(#Menu_Copy,Language("Form", "Copy"))
  MenuItem(#Menu_Paste,Language("Form", "Paste"))
  MenuItem(#MENU_Duplicate,Language("Form", "Duplicate"))
  MenuBar()
  MenuItem(#Menu_AlignLeft,Language("Form", "AlignLeft"))
  MenuItem(#Menu_AlignTop,Language("Form", "AlignTop"))
  MenuItem(#Menu_AlignWidth,Language("Form", "AlignWidth"))
  MenuItem(#Menu_AlignHeight,Language("Form", "AlignHeight"))
  
  CreatePopupMenu(#Form_Menu16)
  MenuItem(#Menu_DeleteFormObj,Language("Form", "Delete"))
  MenuBar()
  MenuItem(#Menu_Cut,Language("Form", "Cut"))
  MenuItem(#Menu_Copy,Language("Form", "Copy"))
  MenuItem(#Menu_Paste,Language("Form", "Paste"))
  MenuItem(#MENU_Duplicate,Language("Form", "Duplicate"))
  MenuBar()
  MenuItem(#MENU_Form_EditItems,Language("Form", "EditItems"))
  MenuItem(#Menu_Columns,Language("Form", "EditColumns"))
  MenuBar()
  MenuItem(#Menu_AlignLeft,Language("Form", "AlignLeft"))
  MenuItem(#Menu_AlignTop,Language("Form", "AlignTop"))
  MenuItem(#Menu_AlignWidth,Language("Form", "AlignWidth"))
  MenuItem(#Menu_AlignHeight,Language("Form", "AlignHeight"))
  
  CreatePopupMenu(#Form_Menu17)
  MenuItem(#Menu_DeleteFormObj,Language("Form", "Delete"))
  MenuBar()
  MenuItem(#Menu_Cut,Language("Form", "Cut"))
  MenuItem(#Menu_Copy,Language("Form", "Copy"))
  MenuItem(#Menu_Paste,Language("Form", "Paste"))
  MenuItem(#MENU_Duplicate,Language("Form", "Duplicate"))
  MenuBar()
  MenuItem(#MENU_Form_EditItems,Language("Form", "EditItems"))
  MenuBar()
  MenuItem(#Menu_AlignLeft,Language("Form", "AlignLeft"))
  MenuItem(#Menu_AlignTop,Language("Form", "AlignTop"))
  MenuItem(#Menu_AlignWidth,Language("Form", "AlignWidth"))
  MenuItem(#Menu_AlignHeight,Language("Form", "AlignHeight"))
  
  CreatePopupMenu(#Form_Menu3)
  MenuItem(#Menu_Copy,Language("Form", "Copy"))
  MenuBar()
  MenuItem(#Menu_SelectAll,Language("Form", "SelectAll"))
  
  CreatePopupMenu(#Form_Menu4)
  MenuItem(#Menu_RemoveColor,Language("Form", "RemoveColour"))
  CreatePopupMenu(#Form_Menu5)
  MenuItem(#Menu_RemoveFont,Language("Form", "RemoveFont"))
  
  CreatePopupMenu(#Form_Menu6)
  MenuItem(#Menu_Paste,Language("Form", "Paste"))
  
  CreatePopupMenu(#Form_Menu7)
  MenuItem(#Menu_RemoveEventFile,Language("Form", "Remove"))
  
  CreatePopupMenu(#Form_Menu8)
  MenuItem(#Menu_ToolbarButton, Language("Form", "AddButton"))
  MenuItem(#Menu_ToolbarToggleButton, Language("Form", "AddToggle"))
  MenuItem(#Menu_ToolbarSeparator, Language("Form", "AddSeparator"))
  
  CreatePopupMenu(#Form_Menu9)
  MenuItem(#Menu_ToolbarDelete, Language("Form", "DeleteToolbar"))
  
  CreatePopupMenu(#Form_Menu10)
  MenuItem(#Menu_ToolbarDeleteItem, Language("Form", "DeleteToolbarItem"))
  
  CreatePopupMenu(#Form_Menu11)
  MenuItem(#Menu_StatusImage, Language("Form", "AddImage"))
  MenuItem(#Menu_StatusLabel, Language("Form", "AddLabel"))
  MenuItem(#Menu_StatusProgressBar, Language("Form", "AddProgressBar"))
  
  CreatePopupMenu(#Form_Menu12)
  MenuItem(#Menu_StatusDelete, Language("Form", "DeleteStatusBar"))
  
  CreatePopupMenu(#Form_Menu13)
  MenuItem(#Menu_StatusDeleteItem, Language("Form", "DeleteField"))
  
  CreatePopupMenu(#Form_Menu14)
  MenuItem(#Menu_Menu_Delete, Language("Form", "DeleteMenu"))
  
  CreatePopupMenu(#Form_Menu15)
  MenuItem(#Menu_Menu_DeleteItem, Language("Form", "DeleteMenuItem"))
EndProcedure
