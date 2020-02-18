﻿;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------
UseJPEGImageDecoder()
UsePNGImageDecoder()

Global appname.s = #ProductName$
Global P_WinHeight, P_Status, P_Menu, P_Font.s, P_FontSize, P_FontSizeL
Global P_FontGadget.s, P_FontGadgetSize, P_FontMenu.s, P_FontMenuSize, P_FontColumn.s, P_FontColumnSize, P_FontGrid.s
Global P_SplitterWidth, ScrollAreaW, Panel_Height, P_ScrollWidth
#Page_Padding = 10

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_MacOS
    P_FontGrid = "Lucida Grande"
    #P_FontGridSize = 13
    #P_FontCode = "Monaco"
    #P_FontCodeSize = 14
  CompilerCase #PB_OS_Windows
    If OSVersion() <= #PB_OS_Windows_XP
      P_FontGrid = "Tahoma"
    Else
      P_FontGrid = "Segoe UI"
    EndIf
    
    #P_FontGridSize = 10
    #P_FontCode = "Courier New"
    #P_FontCodeSize = 11
  CompilerCase #PB_OS_Linux
    P_FontGrid = "Lucida Grande"
    #P_FontGridSize = 11
    #P_FontCode = "Monaco"
    #P_FontCodeSize = 11
CompilerEndSelect

Structure FormGadgetItems
  name.s
  level.b
  icon.q
EndStructure
Structure FormGadgetColumns
  name.s
  width.w
EndStructure
Structure FormMenuAdd
  previous_el.i : level.b
  x1.i : y1.i : x2.i : y2.i
EndStructure
Structure FormUndoWin
  x.i
  y.i
  width.i
  height.i
  variable.s
  caption.s
  captionvariable.b
  flags.i
  pbany.b
  color.i
  generateeventloop.b
  disabled.b
  hidden.b
  
  event_file.s
  event_proc.s
EndStructure
Structure FormImg
  id.s
  img.s
  inline.b
  pbany.b
EndStructure
Structure FormGadget
  itemnumber.i
  
  x1.i
  x2.i
  y1.i
  y2.i
  
  lock_left.b
  lock_right.b
  lock_top.b
  lock_bottom.b
  
  oldx.i
  oldy.i
  
  resizing.b
  selected.b
  
  ; undo
  gadgetid.i
  gadgetpos.i
  
  caption.s
  captionvariable.b
  tooltip.s
  tooltipvariable.b
  variable.s
  image.q
  imageid.s ; for parsing when loading
  
  g_data.i
  flags.i
  type.i
  min.i
  max.i
  
  frontcolor.i
  backcolor.i
  gadgetfont.s
  gadgetfontsize.i
  gadgetfontflags.i
  
  parent.q
  parent_item.i
  current_item.i
  
  ; splitter
  gadget1.i
  gadget2.i
  splitter.i
  
  pbany.b
  disabled.b
  hidden.b
  state.i
  
  ; events
  event_proc.s
  
  ; custom gadgets
  cust_init.s
  cust_create.s
  cust_free.s
  
  ; For scrollarea only
  scrollx.i : scrolly.i
  
  List Items.FormGadgetItems()
  List Columns.FormGadgetColumns()
EndStructure
Structure FormMenu
  level.b
  separator.b
  id.s
  item.s
  shortcut.s
  icon.q
  event.s
  
  x1.i
  x2.i
  y1.i
  y2.i
EndStructure
Structure FormToolbar
  id.s
  img.q
  tooltip.s
  separator.i
  toggle.b
  event.s
  
  x1.i
  x2.i
  y.i
EndStructure
Structure FormStatusbar
  width.i
  text.s
  img.q
  flags.i
  progressbar.i
  
  x1.i
  x2.i
  y.i
EndStructure
Structure FormUndoAction
  type.b
  List ActionTool1.FormToolbar()
  List ActionTool2.FormToolbar()
  List ActionStatus1.FormStatusbar()
  List ActionStatus2.FormStatusbar()
  List ActionMenu1.FormMenu()
  List ActionMenu2.FormMenu()
  List ActionGadget.FormGadget()
  List ActionWindow.FormUndoWin()
EndStructure
Structure FormWindow
  x.i
  y.i
  width.i
  height.i
  variable.s
  caption.s
  captionvariable.b
  flags.i
  pbany.b
  color.i
  generateeventloop.b
  disabled.b
  hidden.b
  parent.s
  
  lastgadgetselected.i
  
  event_file.s
  event_proc.s
  
  List FormImg.FormImg()
  List FormGadgets.FormGadget()
  List FormMenus.FormMenu()
  List FormMenuButtons.FormMenuAdd()
  menu_buttonx.i
  menu_buttony.i
  menu_visible.b
  List FormToolbars.FormToolbar()
  toolbar_buttonx.i
  toolbar_buttony.i
  toolbar_visible.b
  List FormStatusbars.FormStatusbar()
  status_buttonx.i
  status_buttony.i
  status_visible.b
  
  List UndoActions.FormUndoAction()
  undo_pos.i
  
  paddingx.i
  paddingy.i
  
  changes_monitor.b
  changes_code.b
  current_file.s
  current_view.b
  
  c_canvas.i
  c_button.i
  c_buttonimg.i
  c_calendar.i
  c_checkbox.i
  c_combo.i
  c_container.i
  c_date.i
  c_editor.i
  c_explorercombo.i
  c_explorerlist.i
  c_explorertree.i
  c_frame3D.i
  c_hyperlink.i
  c_image.i
  c_ip.i
  c_listicon.i
  c_listview.i
  c_opengl.i
  c_option.i
  c_panel.i
  c_progressbar.i
  c_scintilla.i
  c_scrollarea.i
  c_scrollbar.i
  c_spin.i
  c_splitter.i
  c_string.i
  c_text.i
  c_trackbar.i
  c_tree.i
  c_web.i
EndStructure

Structure Obj
  level.i
  
  window.i
  gadget.i ; NULL if the item is a window
  gadget_number.i
  gadget_item.i ; PanelGadget only
  name.s
EndStructure

#Endline = Chr(10)

; Help structures used when generating and parsing source code
Structure two
  a.i : b.i
EndStructure
Structure twostring
  a.s
  b.s
EndStructure
Structure twomixed
  a.i
  b.s
EndStructure
Structure threestring
  a.s
  b.s
  c.s
EndStructure
Structure fontlist
  id.s
  name.s
  size.i
  flags.i
EndStructure


Global NewList clipboard.FormGadget(), NewList duplicates.i(), NewList twins.two()
Global NewList FormWindows.FormWindow(), NewList OpenTempImg.FormImg(), NewMap Images.i(), NewList togglebuttons.i(), currentwindow.i, switch, NewList ObjList.Obj()

; Prefs:
Global form_splitter_pos, inlineimg
Global maxundolevel = 99

; Window count
Global c_window
Global formwinx, formwiny, formwinw, formwinh, formwinstate
; Drawing variables
Global drawing.b, moving, moving_x, moving_y, moving_firstx, moving_firsty, resizing, resizing_win, scrolling, delta.f, scrollingx, scrollingy, form_gadget_type = 50, parent
Global toolselected.b, tooldragpos, statusselected.b, statusdragpos, menuselected, menudragposx, menudragposy
Global moveresizeundo, moveundo, resizeundo
Global itemnumbers = 1
Global d_x, d_y, d_width, d_height, d_x1, d_y1, d_x2, d_y2, d_gadget1, d_gadget2
; Various padding variables, used for the drawing area
Global topwinpadding, topmenupadding, toptoolpadding, bottompaddingsb, leftpadding
Global gadgetlist, propgrid, propgrid_win, propgrid_gadget, propgrid_toolbar, propgrid_statusbar, propgrid_menu, propgrid_combo, propgrid_proccombo, code_gadget, menu_el, menu_color_row
Global redraw.b, currentview = 0, propobjlist_src, drag_type

Declare FD_NewWindow(x=0,y=0,width=600,height=400,file.s = "")
Declare FD_UpdateSplitter()
Declare InitSplitterWin()
Declare FD_Save(file.s)
Declare FD_SelectWindow(window)
Declare FD_SelectGadget(gadget)
Declare FD_UpdateObjList()
Declare FD_FindParent(item_number)
Declare FD_InitBasicPropGridRows(gadget = 0)
Declare FD_ProcessEventGrid(col, row)
Declare FD_UpdateCode()
Declare FD_CutEvent()
Declare FD_CopyEvent()
Declare FD_PasteEvent()
Declare FD_DuplicateGadget()
Declare FD_Open(file.s,update = 0)
Declare FD_PrepareTestCode(compile = 1)


; Gadget Types
Enumeration
  #Form_Type_Window = 49
  #Form_Type_Button
  #Form_Type_ButtonImg
  #Form_Type_StringGadget
  #Form_Type_Checkbox
  #Form_Type_Text
  #Form_Type_OpenGL
  #Form_Type_Option
  #Form_Type_TreeGadget
  #Form_Type_ListView
  #Form_Type_ListIcon
  #Form_Type_Combo
  #Form_Type_Spin
  #Form_Type_Trackbar
  #Form_Type_ProgressBar
  #Form_Type_Img
  #Form_Type_IP
  #Form_Type_Scrollbar
  #Form_Type_HyperLink
  #Form_Type_Editor
  #Form_Type_ExplorerTree
  #Form_Type_ExplorerList
  #Form_Type_ExplorerCombo
  #Form_Type_Date
  #Form_Type_Calendar
  #Form_Type_Scintilla
  #Form_Type_Frame3D
  #Form_Type_ScrollArea
  #Form_Type_Web
  #Form_Type_Container
  #Form_Type_Panel
  #Form_Type_Canvas
  #Form_Type_Custom
  #Form_Type_Splitter
  #Form_Type_Toolbar
  #Form_Type_StatusBar
  #Form_Type_Menu
EndEnumeration

Enumeration #PB_Compiler_EnumerationValue
  #Form_Resize_TopLeft
  #Form_Resize_TopMiddle
  #Form_Resize_TopRight
  #Form_Resize_BottomLeft
  #Form_Resize_BottomMiddle
  #Form_Resize_BottomRight
  #Form_Resize_MiddleLeft
  #Form_Resize_MiddleRight
  
  #Form_Menu0
  #Form_Menu1
  #Form_Menu2
  #Form_Menu3
  #Form_Menu4
  #Form_Menu5
  #Form_Menu6
  #Form_Menu7
  #Form_Menu8
  #Form_Menu9
  #Form_Menu10
  #Form_Menu11
  #Form_Menu12
  #Form_Menu13
  #Form_Menu14
  #Form_Menu15
  #Form_Menu16
  #Form_Menu17
  
  #Form_Items
  #Form_Columns
  #Form_ImgList
  #Form_SplitterWin
  
  #Form_Font
  #Form_FontColumnHeader
  #Form_FontMenu
EndEnumeration

; Undo type flags
Enumeration
  #Undo_Change
  #Undo_Create
  #Undo_Delete
EndEnumeration

;{ Flags
Structure Flags
  name.s
  value.i
  ivalue.i
EndStructure
Structure EventType
  name.s
EndStructure
Structure Gadgets
  name.s
  type.i
  icon.i
  node.b
  List Flags.Flags()
  List Events.EventType()
EndStructure

Global NewList FontFlags.Flags()
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_Bold" : FontFlags()\value = #PB_Font_Bold
FontFlags()\ivalue = 1 << 0
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_Italic" : FontFlags()\value = #PB_Font_Italic
FontFlags()\ivalue = 1 << 1
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_Underline" : FontFlags()\value = #PB_Font_Underline
FontFlags()\ivalue = 1 << 2
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_StrikeOut" : FontFlags()\value = #PB_Font_StrikeOut
FontFlags()\ivalue = 1 << 3

Global NewList Gadgets.Gadgets()
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Window
Gadgets()\icon = #IMAGE_FormIcons_Calendar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_SystemMenu" : Gadgets()\Flags()\value = #PB_Window_SystemMenu
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_MinimizeGadget" : Gadgets()\Flags()\value = #PB_Window_MinimizeGadget
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_MaximizeGadget" : Gadgets()\Flags()\value = #PB_Window_MaximizeGadget
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_SizeGadget" : Gadgets()\Flags()\value = #PB_Window_SizeGadget
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Invisible" : Gadgets()\Flags()\value = #PB_Window_Invisible
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_TitleBar" : Gadgets()\Flags()\value = #PB_Window_TitleBar
Gadgets()\Flags()\ivalue = 1 << 5
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Tool" : Gadgets()\Flags()\value = #PB_Window_Tool
Gadgets()\Flags()\ivalue = 1 << 6
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_BorderLess" : Gadgets()\Flags()\value = #PB_Window_BorderLess
Gadgets()\Flags()\ivalue = 1 << 7
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_ScreenCentered" : Gadgets()\Flags()\value = #PB_Window_ScreenCentered
Gadgets()\Flags()\ivalue = 1 << 8
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_WindowCentered" : Gadgets()\Flags()\value = #PB_Window_WindowCentered
Gadgets()\Flags()\ivalue = 1 << 9
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Maximize" : Gadgets()\Flags()\value = #PB_Window_Maximize
Gadgets()\Flags()\ivalue = 1 << 10
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Minimize" : Gadgets()\Flags()\value = #PB_Window_Minimize
Gadgets()\Flags()\ivalue = 1 << 11
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_NoGadgets" : Gadgets()\Flags()\value = #PB_Window_NoGadgets
Gadgets()\Flags()\ivalue = 1 << 12
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_CloseWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Repaint"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_SizeWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_MoveWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_MinimizeWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_MaximizeWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_RestoreWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_ActivateWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_WindowDrop"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Menu"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Gadget"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_SysTray"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Timer"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_GadgetDrop"

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Button
Gadgets()\name = "Button"
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Button
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Right" : Gadgets()\Flags()\value = #PB_Button_Right
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Left" : Gadgets()\Flags()\value = #PB_Button_Left
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Default" : Gadgets()\Flags()\value = #PB_Button_Default
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_MultiLine" : Gadgets()\Flags()\value = #PB_Button_MultiLine
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Toggle" : Gadgets()\Flags()\value = #PB_Button_Toggle
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ButtonImg
Gadgets()\node = 1
Gadgets()\name = "ButtonImage"
Gadgets()\icon = #IMAGE_FormIcons_ButtonImage
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Toggle" : Gadgets()\Flags()\value = #PB_Button_Toggle
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Calendar
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Calendar
Gadgets()\name = "Calendar"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Calendar_Borderless" : Gadgets()\Flags()\value = #PB_Calendar_Borderless
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Canvas
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Canvas
Gadgets()\name = "Canvas"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_Border" : Gadgets()\Flags()\value = #PB_Canvas_Border
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_ClipMouse" : Gadgets()\Flags()\value = #PB_Canvas_ClipMouse
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_Keyboard" : Gadgets()\Flags()\value = #PB_Canvas_Keyboard
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_DrawFocus" : Gadgets()\Flags()\value = #PB_Canvas_DrawFocus
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MouseEnter"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MouseLeave"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MouseMove"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MouseWheel"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftButtonDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftButtonUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightButtonDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightButtonUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MiddleButtonDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MiddleButtonUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_KeyDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_KeyUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Input"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Checkbox
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_CheckBox
Gadgets()\name = "CheckBox"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_CheckBox_Right" : Gadgets()\Flags()\value = #PB_CheckBox_Right
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_CheckBox_Center" : Gadgets()\Flags()\value = #PB_CheckBox_Center
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_CheckBox_ThreeState" : Gadgets()\Flags()\value = #PB_CheckBox_ThreeState
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Combo
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ComboBox
Gadgets()\name = "ComboBox"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_Editable" : Gadgets()\Flags()\value = #PB_ComboBox_Editable
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_LowerCase" : Gadgets()\Flags()\value = #PB_ComboBox_LowerCase
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_UpperCase" : Gadgets()\Flags()\value = #PB_ComboBox_UpperCase
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_Image" : Gadgets()\Flags()\value = #PB_ComboBox_Image
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Container
Gadgets()\node = 2
Gadgets()\icon = #IMAGE_FormIcons_Container
Gadgets()\name = "Container"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_BorderLess" : Gadgets()\Flags()\value = #PB_Container_BorderLess
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Flat" : Gadgets()\Flags()\value = #PB_Container_Flat
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Raised" : Gadgets()\Flags()\value = #PB_Container_Raised
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Single" : Gadgets()\Flags()\value = #PB_Container_Single
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Double" : Gadgets()\Flags()\value = #PB_Container_Double
Gadgets()\Flags()\ivalue = 1 << 4
; AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Custom
; Gadgets()\node = 2
; Gadgets()\icon = #IMAGE_FormIcons_Canvas
; Gadgets()\name = "Custom"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Date
Gadgets()\node = 1
Gadgets()\name = "Date"
Gadgets()\icon = #IMAGE_FormIcons_Date
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Date_UpDown" : Gadgets()\Flags()\value = #PB_Date_UpDown
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Date_CheckBox" : Gadgets()\Flags()\value = #PB_Date_CheckBox
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Editor
Gadgets()\node = 1
Gadgets()\name = "Editor"
Gadgets()\icon = #IMAGE_FormIcons_Editor
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Editor_ReadOnly" : Gadgets()\Flags()\value = #PB_Editor_ReadOnly
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Editor_WordWrap" : Gadgets()\Flags()\value = #PB_Editor_WordWrap
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ExplorerCombo
Gadgets()\node = 1
Gadgets()\name = "Explorer Combo"
Gadgets()\icon = #IMAGE_FormIcons_ExplorerCombo
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_DrivesOnly" : Gadgets()\Flags()\value = #PB_Explorer_DrivesOnly
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_Editable" : Gadgets()\Flags()\value = #PB_Explorer_Editable
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoMyDocuments" : Gadgets()\Flags()\value = #PB_Explorer_NoMyDocuments
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ExplorerList
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ExplorerList
Gadgets()\name = "Explorer List"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoMyDocuments" : Gadgets()\Flags()\value = #PB_Explorer_NoMyDocuments
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_BorderLess" : Gadgets()\Flags()\value = #PB_Explorer_BorderLess
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AlwaysShowSelection" : Gadgets()\Flags()\value = #PB_Explorer_AlwaysShowSelection
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_MultiSelect" : Gadgets()\Flags()\value = #PB_Explorer_MultiSelect
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_GridLines" : Gadgets()\Flags()\value = #PB_Explorer_GridLines
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_HeaderDragDrop" : Gadgets()\Flags()\value = #PB_Explorer_HeaderDragDrop
Gadgets()\Flags()\ivalue = 1 << 5
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_FullRowSelect" : Gadgets()\Flags()\value = #PB_Explorer_FullRowSelect
Gadgets()\Flags()\ivalue = 1 << 6
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoFiles" : Gadgets()\Flags()\value = #PB_Explorer_NoFiles
Gadgets()\Flags()\ivalue = 1 << 7
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoFolders" : Gadgets()\Flags()\value = #PB_Explorer_NoFolders
Gadgets()\Flags()\ivalue = 1 << 8
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoParentFolder" : Gadgets()\Flags()\value = #PB_Explorer_NoParentFolder
Gadgets()\Flags()\ivalue = 1 << 9
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoDirectoryChange" : Gadgets()\Flags()\value = #PB_Explorer_NoDirectoryChange
Gadgets()\Flags()\ivalue = 1 << 10
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoDriveRequester" : Gadgets()\Flags()\value = #PB_Explorer_NoDriveRequester
Gadgets()\Flags()\ivalue = 1 << 11
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoSort" : Gadgets()\Flags()\value = #PB_Explorer_NoSort
Gadgets()\Flags()\ivalue = 1 << 12
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AutoSort" : Gadgets()\Flags()\value = #PB_Explorer_AutoSort
Gadgets()\Flags()\ivalue = 1 << 13
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ExplorerTree
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ExplorerTree
Gadgets()\name = "Explorer Tree"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_BorderLess" : Gadgets()\Flags()\value = #PB_Explorer_BorderLess
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AlwaysShowSelection" : Gadgets()\Flags()\value = #PB_Explorer_AlwaysShowSelection
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoLines" : Gadgets()\Flags()\value = #PB_Explorer_NoLines
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoButtons" : Gadgets()\Flags()\value = #PB_Explorer_NoButtons
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoFiles" : Gadgets()\Flags()\value = #PB_Explorer_NoFiles
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoDriveRequester" : Gadgets()\Flags()\value = #PB_Explorer_NoDriveRequester
Gadgets()\Flags()\ivalue = 1 << 5
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoMyDocuments" : Gadgets()\Flags()\value = #PB_Explorer_NoMyDocuments
Gadgets()\Flags()\ivalue = 1 << 6
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AutoSort" : Gadgets()\Flags()\value = #PB_Explorer_AutoSort
Gadgets()\Flags()\ivalue = 1 << 7
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Frame3D
Gadgets()\node = 2
Gadgets()\icon = #IMAGE_FormIcons_Frame3D
Gadgets()\name = "Frame"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Single" : Gadgets()\Flags()\value = #PB_Frame_Single
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Double" : Gadgets()\Flags()\value = #PB_Frame_Double
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Flat" : Gadgets()\Flags()\value = #PB_Frame_Flat
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_HyperLink
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_HyperLink
Gadgets()\name = "Hyperlink"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_HyperLink_Underline" : Gadgets()\Flags()\value = #PB_HyperLink_Underline
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Img
Gadgets()\node = 1
Gadgets()\name = "Image"
Gadgets()\icon = #IMAGE_FormIcons_Image
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Image_Border" : Gadgets()\Flags()\value = #PB_Image_Border
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_IP
Gadgets()\node = 1
Gadgets()\name = "IP"
Gadgets()\icon = #IMAGE_FormIcons_IPAddress
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ListIcon
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ListIcon
Gadgets()\name = "ListIcon"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_CheckBoxes" : Gadgets()\Flags()\value = #PB_ListIcon_CheckBoxes
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_ThreeState" : Gadgets()\Flags()\value = #PB_ListIcon_ThreeState
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_MultiSelect" : Gadgets()\Flags()\value = #PB_ListIcon_MultiSelect
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_GridLines" : Gadgets()\Flags()\value = #PB_ListIcon_GridLines
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_FullRowSelect" : Gadgets()\Flags()\value = #PB_ListIcon_FullRowSelect
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_HeaderDragDrop" : Gadgets()\Flags()\value = #PB_ListIcon_HeaderDragDrop
Gadgets()\Flags()\ivalue = 1 << 5
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_AlwaysShowSelection" : Gadgets()\Flags()\value = #PB_ListIcon_AlwaysShowSelection
Gadgets()\Flags()\ivalue = 1 << 6
;AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_LargeIcon" : Gadgets()\Flags()\value = #PB_ListIcon_LargeIcon
;Gadgets()\Flags()\ivalue = 1 << 7
;AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_SmallIcon" : Gadgets()\Flags()\value = #PB_ListIcon_SmallIcon
;Gadgets()\Flags()\ivalue = 1 << 8
;AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_List" : Gadgets()\Flags()\value = #PB_ListIcon_List
;Gadgets()\Flags()\ivalue = 1 << 9
;AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_Report" : Gadgets()\Flags()\value = #PB_ListIcon_Report
;Gadgets()\Flags()\ivalue = 1 << 10

AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ListView
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ListView
Gadgets()\name = "ListView"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListView_MultiSelect" : Gadgets()\Flags()\value = #PB_ListView_MultiSelect
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListView_ClickSelect" : Gadgets()\Flags()\value = #PB_ListView_ClickSelect
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"


AddElement(Gadgets()) : Gadgets()\type = #Form_Type_OpenGL
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Container
Gadgets()\name = "OpenGL"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_Keyboard" : Gadgets()\Flags()\value = #PB_OpenGL_Keyboard
Gadgets()\Flags()\ivalue = 1 << 0


AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Option
Gadgets()\node = 1
Gadgets()\name = "Option"
Gadgets()\icon = #IMAGE_FormIcons_Option
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Panel
Gadgets()\node = 2
Gadgets()\name = "Panel"
Gadgets()\icon = #IMAGE_FormIcons_Panel
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ProgressBar
Gadgets()\node = 1
Gadgets()\name = "ProgressBar"
Gadgets()\icon = #IMAGE_FormIcons_ProgressBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ProgressBar_Smooth" : Gadgets()\Flags()\value = #PB_ProgressBar_Smooth
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ProgressBar_Vertical" : Gadgets()\Flags()\value = #PB_ProgressBar_Vertical
Gadgets()\Flags()\ivalue = 1 << 1


AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Scintilla
Gadgets()\node = 1
Gadgets()\name = "Scintilla"
Gadgets()\icon = #IMAGE_FormIcons_Editor



AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ScrollArea
Gadgets()\node = 2
Gadgets()\name = "ScrollArea"
Gadgets()\icon = #IMAGE_FormIcons_ScrollArea
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Flat" : Gadgets()\Flags()\value = #PB_ScrollArea_Flat
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Raised" : Gadgets()\Flags()\value = #PB_ScrollArea_Raised
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Single" : Gadgets()\Flags()\value = #PB_ScrollArea_Single
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_BorderLess" : Gadgets()\Flags()\value = #PB_ScrollArea_BorderLess
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Center" : Gadgets()\Flags()\value = #PB_ScrollArea_Center
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Scrollbar
Gadgets()\node = 1
Gadgets()\name = "ScrollBar"
Gadgets()\icon = #IMAGE_FormIcons_ScrollBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollBar_Vertical" : Gadgets()\Flags()\value = #PB_ScrollBar_Vertical
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Spin
Gadgets()\node = 1
Gadgets()\name = "Spin"
Gadgets()\icon = #IMAGE_FormIcons_Spin
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Spin_ReadOnly" : Gadgets()\Flags()\value = #PB_Spin_ReadOnly
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Spin_Numeric" : Gadgets()\Flags()\value = #PB_Spin_Numeric
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Splitter
Gadgets()\node = 2
Gadgets()\name = "Splitter"
Gadgets()\icon = #IMAGE_FormIcons_Splitter
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_Vertical" : Gadgets()\Flags()\value = #PB_Splitter_Vertical
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_Separator" : Gadgets()\Flags()\value = #PB_Splitter_Separator
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_FirstFixed" : Gadgets()\Flags()\value = #PB_Splitter_FirstFixed
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_SecondFixed" : Gadgets()\Flags()\value = #PB_Splitter_SecondFixed
Gadgets()\Flags()\ivalue = 1 << 3

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_StringGadget
Gadgets()\node = 1
Gadgets()\name = "String"
Gadgets()\icon = #IMAGE_FormIcons_String
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_Numeric" : Gadgets()\Flags()\value = #PB_String_Numeric
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_Password" : Gadgets()\Flags()\value = #PB_String_Password
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_ReadOnly" : Gadgets()\Flags()\value = #PB_String_ReadOnly
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_LowerCase" : Gadgets()\Flags()\value = #PB_String_LowerCase
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_UpperCase" : Gadgets()\Flags()\value = #PB_String_UpperCase
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_BorderLess" : Gadgets()\Flags()\value = #PB_String_BorderLess
Gadgets()\Flags()\ivalue = 1 << 5
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Text
Gadgets()\node = 1
Gadgets()\name = "Text"
Gadgets()\icon = #IMAGE_FormIcons_Text
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Text_Center" : Gadgets()\Flags()\value = #PB_Text_Center
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Text_Right" : Gadgets()\Flags()\value = #PB_Text_Right
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Text_Border" : Gadgets()\Flags()\value = #PB_Text_Border
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Trackbar
Gadgets()\node = 1
Gadgets()\name = "TrackBar"
Gadgets()\icon = #IMAGE_FormIcons_TrackBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_TrackBar_Ticks" : Gadgets()\Flags()\value = #PB_TrackBar_Ticks
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_TrackBar_Vertical" : Gadgets()\Flags()\value = #PB_TrackBar_Vertical
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_TreeGadget
Gadgets()\node = 1
Gadgets()\name = "Tree"
Gadgets()\icon = #IMAGE_FormIcons_Tree
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_AlwaysShowSelection" : Gadgets()\Flags()\value = #PB_Tree_AlwaysShowSelection
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_NoLines" : Gadgets()\Flags()\value = #PB_Tree_NoLines
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_NoButtons" : Gadgets()\Flags()\value = #PB_Tree_NoButtons
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_CheckBoxes" : Gadgets()\Flags()\value = #PB_Tree_CheckBoxes
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_ThreeState" : Gadgets()\Flags()\value = #PB_Tree_ThreeState
Gadgets()\Flags()\ivalue = 1 << 4
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Web
Gadgets()\node = 1
Gadgets()\name = "WebView"
Gadgets()\icon = #IMAGE_FormIcons_Web
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Toolbar
Gadgets()\node = 3
Gadgets()\name = "ToolBar"
Gadgets()\icon = #IMAGE_FormIcons_ToolBar
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_StatusBar
Gadgets()\node = 3
Gadgets()\name = "StatusBar"
Gadgets()\icon = #IMAGE_FormIcons_Status
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_Raised" : Gadgets()\Flags()\value = #PB_StatusBar_Raised
Gadgets()\Flags()\ivalue = 1 << 0
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_BorderLess" : Gadgets()\Flags()\value = #PB_StatusBar_BorderLess
Gadgets()\Flags()\ivalue = 1 << 1
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_Center" : Gadgets()\Flags()\value = #PB_StatusBar_Center
Gadgets()\Flags()\ivalue = 1 << 2
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_Right" : Gadgets()\Flags()\value = #PB_StatusBar_Right
Gadgets()\Flags()\ivalue = 1 << 3
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Menu
Gadgets()\node = 3
Gadgets()\name = "Menu"
Gadgets()\icon = #IMAGE_FormIcons_Menu


Procedure FlagValue(flag.s)
  ForEach Gadgets()
    ForEach Gadgets()\Flags()
      If Gadgets()\Flags()\name = flag
        ProcedureReturn Gadgets()\Flags()\ivalue
      EndIf
    Next
  Next
  
  ForEach FontFlags()
    If FontFlags()\name = flag
      ProcedureReturn FontFlags()\ivalue
    EndIf
  Next
EndProcedure


;}



Procedure InitVars()
  Select FormSkin
    Case #PB_OS_MacOS
      P_WinHeight = 22
      P_Status = 24
      P_Menu = 23
      P_Font.s = "Lucida Grande"
      P_FontSize = 9
      P_FontSizeL = 10
      P_FontGadget.s = "Lucida Grande"
      P_FontGadgetSize = 10
      P_FontMenu.s = "Lucida Grande"
      P_FontMenuSize = 11
      P_FontColumn.s = "Lucida Grande"
      P_FontColumnSize = 8
      P_SplitterWidth = 12
      P_ScrollWidth = 18
      
      ScrollAreaW = 14
      Panel_Height = 31
      
    Case #PB_OS_Windows
      If OSVersion() <= #PB_OS_Windows_XP
        P_Font.s = "Tahoma"
        P_FontGadget.s = "Tahoma"
        P_FontMenu.s = "Tahoma"
        P_FontColumn.s = "Tahoma"
        
      Else
        P_Font.s = "Segoe UI"
        P_FontGadget.s = "Segoe UI"
        P_FontMenu.s = "Segoe UI"
        P_FontColumn.s = "Segoe UI"
        
      EndIf
      
      P_WinHeight = 29
      P_Status = 23
      P_Menu = 22
      P_FontSize = 9
      P_FontSizeL = 10
      P_FontGadgetSize = 9
      P_FontMenuSize = 9
      P_FontColumnSize = 9
      P_SplitterWidth = 9
      P_ScrollWidth = 18
      
      ScrollAreaW = 20
      Panel_Height = 22
    Case #PB_OS_Linux
      P_WinHeight = 28
      P_Status = 23
      P_Menu = 22
      P_Font.s = "Lucida Grande"
      P_FontSize = 10
      P_FontSizeL = 11
      P_FontGadget.s = "Lucida Grande"
      P_FontGadgetSize = 11
      P_FontMenu.s = "Lucida Grande"
      P_FontMenuSize = 12
      P_FontColumn.s = "Lucida Grande"
      P_FontColumnSize = 9
      P_SplitterWidth = 9
      P_ScrollWidth = 18
      
      ScrollAreaW = 20
      Panel_Height = 29
  EndSelect
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    P_FontSize + 3
    P_FontSizeL + 3
    P_FontGadgetSize + 3
    P_FontMenuSize + 3
    P_FontColumnSize + 3
  CompilerEndIf
  
  
  If IsFont(#Form_Font) : FreeFont(#Form_Font) : EndIf
  If IsFont(#Form_FontColumnHeader) : FreeFont(#Form_FontColumnHeader) : EndIf
  If IsFont(#Form_FontMenu) : FreeFont(#Form_FontMenu) : EndIf
  
  LoadFont(#Form_Font,P_FontGadget,P_FontGadgetSize)
  LoadFont(#Form_FontColumnHeader,P_FontColumn,P_FontColumnSize)
  LoadFont(#Form_FontMenu,P_FontMenu,P_FontMenuSize)
EndProcedure

DataSection ;{
  submenu: : IncludeBinary "img/vd_submenu.png"
  delete: : IncludeBinary "img/vd_delete.png"
  up: : IncludeBinary "img/vd_up.png"
  down: : IncludeBinary "img/vd_down.png"
  plus: : IncludeBinary "img/vd_plus.png"
  
  ; mac drawing helping images
  macmin: : IncludeBinary "img/macmin.png"
  macmax: : IncludeBinary "img/macmax.png"
  macclose: : IncludeBinary "img/macclose.png"
  macdis: : IncludeBinary "img/macdisabled.png"
  combodblarrows: : IncludeBinary "img/maccombodblarrows.png"
  spin: : IncludeBinary "img/macspin.png"
  date: : IncludeBinary "img/macdate.png"
  maccheckbx: : IncludeBinary "img/maccheckbox.png"
  maccheckbxsel: : IncludeBinary "img/maccheckboxchecked.png"
  macoption: : IncludeBinary "img/macoption.png"
  macoptionsel: : IncludeBinary "img/macoptionselected.png"
  mactrackbar: : IncludeBinary "img/mactrackbar.png"
  mactrackbarv: : IncludeBinary "img/mactrackbarv.png"
  
  ; windows drawing helping images
  winicon: : IncludeBinary "img/windowsicon.png"
  scrollup: : IncludeBinary "img/windowsscrollup.png"
  scrolldown: : IncludeBinary "img/windowsscrolldown.png"
  scrollleft: : IncludeBinary "img/windowsscrollleft.png"
  scrollright: : IncludeBinary "img/windowsscrollright.png"
  arrowdown: : IncludeBinary "img/windowsarrowdown.png"
  
  win8min: : IncludeBinary "img/windows8min.png"
  win8max: : IncludeBinary "img/windows8max.png"
  win8close: : IncludeBinary "img/windows8close.png"
  win8checkbx: : IncludeBinary "img/windows8checkbox.png"
  win8checkbxsel: : IncludeBinary "img/windows8checkboxok.png"
  win8option: : IncludeBinary "img/windows8option.png"
  win8optionsel: : IncludeBinary "img/windows8optionok.png"
  win8spin: : IncludeBinary "img/windows8spin.png"
  win8arrowdown: : IncludeBinary "img/windows8arrowdown.png"
  win8scrollup: : IncludeBinary "img/windows8scrollup.png"
  win8scrolldown: : IncludeBinary "img/windows8scrolldown.png"
  win8scrollleft: : IncludeBinary "img/windows8scrollleft.png"
  win8scrollright: : IncludeBinary "img/windows8scrollright.png"
  
  win7trackbar: : IncludeBinary "img/windowstrack.png"
  win7trackbarv: : IncludeBinary "img/windowstrackv.png"
  win7min: : IncludeBinary "img/windowsmin.png"
  win7max: : IncludeBinary "img/windowsmax.png"
  win7close: : IncludeBinary "img/windowsclose.png"
  win7maxdis: : IncludeBinary "img/windowsmaxdis.png"
  win7mindis: : IncludeBinary "img/windowsmindis.png"
  win7checkbx: : IncludeBinary "img/windowscheckbox.png"
  win7checkbxsel: : IncludeBinary "img/windowscheckboxsel.png"
  win7option: : IncludeBinary "img/windowsoption.png"
  win7optionsel: : IncludeBinary "img/windowsoptionsel.png"
  
  ; linux drawing helping images
  linuxmin: : IncludeBinary "img/linuxmin.png"
  linuxmax: : IncludeBinary "img/linuxmax.png"
  linuxclose: : IncludeBinary "img/linuxclose.png"
  
EndDataSection ;}