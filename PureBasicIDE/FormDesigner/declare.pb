; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
UseJPEGImageDecoder()
UsePNGImageDecoder()

Global P_WinHeight, P_Status, P_Menu, P_Toolbar, P_Font.s, P_FontSize, P_FontSizeL
Global P_FontGadget.s, P_FontGadgetSize, P_FontMenu.s, P_FontMenuSize, P_FontColumn.s, P_FontColumnSize, P_FontGrid.s
Global P_SplitterWidth, ScrollAreaW, Panel_Height, P_ScrollWidth

Global multiselectStart, multiselectParent, multiselectFirstScan

Global grid_color_bg.l, grid_color_fg.l, grid_color_text.l, grid_color_light.l, grid_color_mid.l, grid_color_dark.l

#Page_Padding = 10

CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_MacOS
    
    Declare GetCocoaColor(NSColorName.s)
    
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
    P_FontGrid = "DejaVu Sans"
    #P_FontGridSize = 10
    #P_FontCode = "Monaco"
    #P_FontCodeSize = 11
CompilerEndSelect

;- Structures
;{
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

  List FormCustomFlags.s()

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
;}

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

; Version Warnings Preference Items
EnumerationBinary 
  #FDI_Warn_NotRecognized
  #FDI_Warn_DowngradeAlways
  #FDI_Warn_UpgradeBreaking
  #FDI_Warn_UpgradeAlways 
EndEnumeration
#FDI_Warn_Default = #FDI_Warn_NotRecognized | #FDI_Warn_DowngradeAlways | #FDI_Warn_UpgradeBreaking

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
  #Form_Type_WebView
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
  List customFlags.Flags()
  List Events.EventType()
EndStructure

Global NewList FontFlags.Flags()

EnumerationBinary
  #FDI_Font_Bold
  #FDI_Font_Italic
  #FDI_Font_Underline
  #FDI_Font_StrikeOut
EndEnumeration

AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_Bold" : FontFlags()\value = #PB_Font_Bold
FontFlags()\ivalue = #FDI_Font_Bold
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_Italic" : FontFlags()\value = #PB_Font_Italic
FontFlags()\ivalue = #FDI_Font_Italic
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_Underline" : FontFlags()\value = #PB_Font_Underline
FontFlags()\ivalue = #FDI_Font_Underline
AddElement(FontFlags()) : FontFlags()\name = "#PB_Font_StrikeOut" : FontFlags()\value = #PB_Font_StrikeOut
FontFlags()\ivalue = #FDI_Font_StrikeOut

Global NewList Gadgets.Gadgets()

;- Window
EnumerationBinary
  #FDI_Window_SystemMenu
  #FDI_Window_MinimizeGadget
  #FDI_Window_MaximizeGadget
  #FDI_Window_SizeGadget
  #FDI_Window_Invisible
  #FDI_Window_TitleBar
  #FDI_Window_Tool
  #FDI_Window_BorderLess
  #FDI_Window_ScreenCentered
  #FDI_Window_WindowCentered
  #FDI_Window_Maximize
  #FDI_Window_Minimize
  #FDI_Window_NoGadgets
  #FDI_Window_NoActivate
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Window
Gadgets()\icon = #IMAGE_FormIcons_Calendar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_SystemMenu"
Gadgets()\Flags()\value = #PB_Window_SystemMenu : Gadgets()\Flags()\ivalue = #FDI_Window_SystemMenu
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_MinimizeGadget"
Gadgets()\Flags()\value = #PB_Window_MinimizeGadget : Gadgets()\Flags()\ivalue = #FDI_Window_MinimizeGadget
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_MaximizeGadget"
Gadgets()\Flags()\value = #PB_Window_MaximizeGadget : Gadgets()\Flags()\ivalue = #FDI_Window_MaximizeGadget
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_SizeGadget"
Gadgets()\Flags()\value = #PB_Window_SizeGadget : Gadgets()\Flags()\ivalue = #FDI_Window_SizeGadget
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Invisible"
Gadgets()\Flags()\value = #PB_Window_Invisible : Gadgets()\Flags()\ivalue = #FDI_Window_Invisible
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_TitleBar"
Gadgets()\Flags()\value = #PB_Window_TitleBar : Gadgets()\Flags()\ivalue = #FDI_Window_TitleBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Tool"
Gadgets()\Flags()\value = #PB_Window_Tool : Gadgets()\Flags()\ivalue = #FDI_Window_Tool
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_BorderLess"
Gadgets()\Flags()\value = #PB_Window_BorderLess : Gadgets()\Flags()\ivalue = #FDI_Window_BorderLess
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_ScreenCentered"
Gadgets()\Flags()\value = #PB_Window_ScreenCentered : Gadgets()\Flags()\ivalue = #FDI_Window_ScreenCentered
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_WindowCentered"
Gadgets()\Flags()\value = #PB_Window_WindowCentered : Gadgets()\Flags()\ivalue = #FDI_Window_WindowCentered
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Maximize"
Gadgets()\Flags()\value = #PB_Window_Maximize : Gadgets()\Flags()\ivalue = #FDI_Window_Maximize
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_Minimize"
Gadgets()\Flags()\value = #PB_Window_Minimize : Gadgets()\Flags()\ivalue = #FDI_Window_Minimize
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_NoGadgets"
Gadgets()\Flags()\value = #PB_Window_NoGadgets : Gadgets()\Flags()\ivalue = #FDI_Window_NoGadgets
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Window_NoActivate"
Gadgets()\Flags()\value = #PB_Window_NoActivate : Gadgets()\Flags()\ivalue = #FDI_Window_NoActivate
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Menu"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Gadget"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_SysTray"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Timer"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_CloseWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_Repaint"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_SizeWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_MoveWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_MinimizeWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_MaximizeWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_RestoreWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_ActivateWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_DeactivateWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_WindowDrop"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_GadgetDrop"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_Event_LeftDoubleClick"

;- B
EnumerationBinary
  #FDI_Button_Right
  #FDI_Button_Left
  #FDI_Button_Default
  #FDI_Button_MultiLine
  #FDI_Button_Toggle
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Button
Gadgets()\name = "Button"
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Button
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Right"
Gadgets()\Flags()\value = #PB_Button_Right : Gadgets()\Flags()\ivalue = #FDI_Button_Right
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Left"
Gadgets()\Flags()\value = #PB_Button_Left : Gadgets()\Flags()\ivalue = #FDI_Button_Left
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Default"
Gadgets()\Flags()\value = #PB_Button_Default : Gadgets()\Flags()\ivalue = #FDI_Button_Default
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_MultiLine"
Gadgets()\Flags()\value = #PB_Button_MultiLine : Gadgets()\Flags()\ivalue = #FDI_Button_MultiLine
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Toggle"
Gadgets()\Flags()\value = #PB_Button_Toggle : Gadgets()\Flags()\ivalue = #FDI_Button_Toggle

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ButtonImg
Gadgets()\node = 1
Gadgets()\name = "ButtonImage"
Gadgets()\icon = #IMAGE_FormIcons_ButtonImage
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Button_Toggle"
Gadgets()\Flags()\value = #PB_Button_Toggle : Gadgets()\Flags()\ivalue = #FDI_Button_Toggle

;- C
EnumerationBinary
  #FDI_Calendar_Borderless
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Calendar
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Calendar
Gadgets()\name = "Calendar"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Calendar_Borderless"
Gadgets()\Flags()\value = #PB_Calendar_Borderless : Gadgets()\Flags()\ivalue = #FDI_Calendar_Borderless

EnumerationBinary
  #FDI_Canvas_Border
  #FDI_Canvas_ClipMouse
  #FDI_Canvas_Keyboard
  #FDI_Canvas_DrawFocus
EndEnumeration
; TODO #PB_Canvas_Container is missing.

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Canvas
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Canvas
Gadgets()\name = "Canvas"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_Border"
Gadgets()\Flags()\value = #PB_Canvas_Border : Gadgets()\Flags()\ivalue = #FDI_Canvas_Border
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_ClipMouse"
Gadgets()\Flags()\value = #PB_Canvas_ClipMouse : Gadgets()\Flags()\ivalue = #FDI_Canvas_ClipMouse
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_Keyboard"
Gadgets()\Flags()\value = #PB_Canvas_Keyboard : Gadgets()\Flags()\ivalue = #FDI_Canvas_Keyboard
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Canvas_DrawFocus"
Gadgets()\Flags()\value = #PB_Canvas_DrawFocus : Gadgets()\Flags()\ivalue = #FDI_Canvas_DrawFocus
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
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick" 
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MiddleButtonDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MiddleButtonUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_KeyDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_KeyUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Input"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Resize"

EnumerationBinary
  #FDI_CheckBox_Right
  #FDI_CheckBox_Center
  #FDI_CheckBox_ThreeState
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Checkbox
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_CheckBox
Gadgets()\name = "CheckBox"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_CheckBox_Right"
Gadgets()\Flags()\value = #PB_CheckBox_Right : Gadgets()\Flags()\ivalue = #FDI_CheckBox_Right
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_CheckBox_Center"
Gadgets()\Flags()\value = #PB_CheckBox_Center : Gadgets()\Flags()\ivalue = #FDI_CheckBox_Center
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_CheckBox_ThreeState"
Gadgets()\Flags()\value = #PB_CheckBox_ThreeState : Gadgets()\Flags()\ivalue = #FDI_CheckBox_ThreeState

EnumerationBinary
  #FDI_ComboBox_Editable
  #FDI_ComboBox_LowerCase
  #FDI_ComboBox_UpperCase
  #FDI_ComboBox_Image
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Combo
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ComboBox
Gadgets()\name = "ComboBox"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_Editable"
Gadgets()\Flags()\value = #PB_ComboBox_Editable : Gadgets()\Flags()\ivalue = #FDI_ComboBox_Editable
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_LowerCase"
Gadgets()\Flags()\value = #PB_ComboBox_LowerCase : Gadgets()\Flags()\ivalue = #FDI_ComboBox_LowerCase
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_UpperCase"
Gadgets()\Flags()\value = #PB_ComboBox_UpperCase : Gadgets()\Flags()\ivalue = #FDI_ComboBox_UpperCase
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ComboBox_Image"
Gadgets()\Flags()\value = #PB_ComboBox_Image : Gadgets()\Flags()\ivalue = #FDI_ComboBox_Image
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"

EnumerationBinary
  #FDI_Container_BorderLess
  #FDI_Container_Flat
  #FDI_Container_Raised
  #FDI_Container_Single
  #FDI_Container_Double
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Container
Gadgets()\node = 2
Gadgets()\icon = #IMAGE_FormIcons_Container
Gadgets()\name = "Container"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_BorderLess"
Gadgets()\Flags()\value = #PB_Container_BorderLess : Gadgets()\Flags()\ivalue = #FDI_Container_BorderLess
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Flat"
Gadgets()\Flags()\value = #PB_Container_Flat : Gadgets()\Flags()\ivalue = #FDI_Container_Flat
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Raised"
Gadgets()\Flags()\value = #PB_Container_Raised : Gadgets()\Flags()\ivalue = #FDI_Container_Raised
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Single"
Gadgets()\Flags()\value = #PB_Container_Single : Gadgets()\Flags()\ivalue = #FDI_Container_Single
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Container_Double"
Gadgets()\Flags()\value = #PB_Container_Double : Gadgets()\Flags()\ivalue = #FDI_Container_Double
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Resize"

; AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Custom
; Gadgets()\node = 2
; Gadgets()\icon = #IMAGE_FormIcons_Canvas
; Gadgets()\name = "Custom"

;- D
EnumerationBinary
  #FDI_Date_UpDown
  #FDI_Date_CheckBox
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Date
Gadgets()\node = 1
Gadgets()\name = "Date"
Gadgets()\icon = #IMAGE_FormIcons_Date
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Date_UpDown"
Gadgets()\Flags()\value = #PB_Date_UpDown : Gadgets()\Flags()\ivalue = #FDI_Date_UpDown
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Date_CheckBox"
Gadgets()\Flags()\value = #PB_Date_CheckBox : Gadgets()\Flags()\ivalue = #FDI_Date_CheckBox
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"

;- E
EnumerationBinary
  #FDI_Editor_ReadOnly
  #FDI_Editor_WordWrap
  #FDI_Editor_TabNavigation
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Editor
Gadgets()\node = 1
Gadgets()\name = "Editor"
Gadgets()\icon = #IMAGE_FormIcons_Editor
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Editor_ReadOnly"
Gadgets()\Flags()\value = #PB_Editor_ReadOnly : Gadgets()\Flags()\ivalue = #FDI_Editor_ReadOnly
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Editor_WordWrap"
Gadgets()\Flags()\value = #PB_Editor_WordWrap : Gadgets()\Flags()\ivalue = #FDI_Editor_WordWrap
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Editor_TabNavigation"
Gadgets()\Flags()\value = #PB_Editor_TabNavigation : Gadgets()\Flags()\ivalue = #FDI_Editor_TabNavigation
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"

EnumerationBinary
  #FDI_Explorer_AlwaysShowSelection
  #FDI_Explorer_AutoSort
  #FDI_Explorer_BorderLess
  #FDI_Explorer_DrivesOnly
  #FDI_Explorer_Editable
  #FDI_Explorer_FullRowSelect
  #FDI_Explorer_GridLines
  #FDI_Explorer_HeaderDragDrop
  #FDI_Explorer_MultiSelect
  #FDI_Explorer_NoButtons
  #FDI_Explorer_NoDirectoryChange
  #FDI_Explorer_NoDriveRequester
  #FDI_Explorer_NoFiles
  #FDI_Explorer_NoFolders
  #FDI_Explorer_NoLines
  #FDI_Explorer_NoMyDocuments
  #FDI_Explorer_NoParentFolder
  #FDI_Explorer_NoSort
  #FDI_Explorer_HiddenFiles
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ExplorerCombo
Gadgets()\node = 1
Gadgets()\name = "Explorer Combo"
Gadgets()\icon = #IMAGE_FormIcons_ExplorerCombo
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_DrivesOnly"
Gadgets()\Flags()\value = #PB_Explorer_DrivesOnly : Gadgets()\Flags()\ivalue = #FDI_Explorer_DrivesOnly
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_Editable"
Gadgets()\Flags()\value = #PB_Explorer_Editable : Gadgets()\Flags()\ivalue = #FDI_Explorer_Editable
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoMyDocuments"
Gadgets()\Flags()\value = #PB_Explorer_NoMyDocuments : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoMyDocuments

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ExplorerList
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ExplorerList
Gadgets()\name = "Explorer List"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoMyDocuments"
Gadgets()\Flags()\value = #PB_Explorer_NoMyDocuments : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoMyDocuments
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_BorderLess"
Gadgets()\Flags()\value = #PB_Explorer_BorderLess : Gadgets()\Flags()\ivalue = #FDI_Explorer_BorderLess
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AlwaysShowSelection"
Gadgets()\Flags()\value = #PB_Explorer_AlwaysShowSelection : Gadgets()\Flags()\ivalue = #FDI_Explorer_AlwaysShowSelection
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_MultiSelect"
Gadgets()\Flags()\value = #PB_Explorer_MultiSelect : Gadgets()\Flags()\ivalue = #FDI_Explorer_MultiSelect
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_GridLines"
Gadgets()\Flags()\value = #PB_Explorer_GridLines : Gadgets()\Flags()\ivalue = #FDI_Explorer_GridLines
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_HeaderDragDrop"
Gadgets()\Flags()\value = #PB_Explorer_HeaderDragDrop : Gadgets()\Flags()\ivalue = #FDI_Explorer_HeaderDragDrop
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_FullRowSelect"
Gadgets()\Flags()\value = #PB_Explorer_FullRowSelect : Gadgets()\Flags()\ivalue = #FDI_Explorer_FullRowSelect
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoFiles"
Gadgets()\Flags()\value = #PB_Explorer_NoFiles : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoFiles
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoFolders"
Gadgets()\Flags()\value = #PB_Explorer_NoFolders : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoFolders
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoParentFolder"
Gadgets()\Flags()\value = #PB_Explorer_NoParentFolder : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoParentFolder
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoDirectoryChange"
Gadgets()\Flags()\value = #PB_Explorer_NoDirectoryChange : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoDirectoryChange
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoDriveRequester"
Gadgets()\Flags()\value = #PB_Explorer_NoDriveRequester : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoDriveRequester
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoSort"
Gadgets()\Flags()\value = #PB_Explorer_NoSort : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoSort
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AutoSort"
Gadgets()\Flags()\value = #PB_Explorer_AutoSort : Gadgets()\Flags()\ivalue = #FDI_Explorer_AutoSort
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AutoSort"
Gadgets()\Flags()\value = #PB_Explorer_HiddenFiles : Gadgets()\Flags()\ivalue = #FDI_Explorer_HiddenFiles
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick "
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Refresh"

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ExplorerTree
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ExplorerTree
Gadgets()\name = "Explorer Tree"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_BorderLess"
Gadgets()\Flags()\value = #PB_Explorer_BorderLess : Gadgets()\Flags()\ivalue = #FDI_Explorer_BorderLess
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AlwaysShowSelection"
Gadgets()\Flags()\value = #PB_Explorer_AlwaysShowSelection : Gadgets()\Flags()\ivalue = #FDI_Explorer_AlwaysShowSelection
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoLines"
Gadgets()\Flags()\value = #PB_Explorer_NoLines : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoLines
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoButtons"
Gadgets()\Flags()\value = #PB_Explorer_NoButtons : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoButtons
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoFiles"
Gadgets()\Flags()\value = #PB_Explorer_NoFiles : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoFiles
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoDriveRequester"
Gadgets()\Flags()\value = #PB_Explorer_NoDriveRequester : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoDriveRequester
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_NoMyDocuments"
Gadgets()\Flags()\value = #PB_Explorer_NoMyDocuments : Gadgets()\Flags()\ivalue = #FDI_Explorer_NoMyDocuments
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Explorer_AutoSort"
Gadgets()\Flags()\value = #PB_Explorer_AutoSort : Gadgets()\Flags()\ivalue = #FDI_Explorer_AutoSort
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"

;- F
EnumerationBinary
  #FDI_Frame_Single
  #FDI_Frame_Double
  #FDI_Frame_Flat
  #FDI_Frame_Container
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Frame3D
Gadgets()\node = 2
Gadgets()\icon = #IMAGE_FormIcons_Frame3D
Gadgets()\name = "Frame"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Single"
Gadgets()\Flags()\value = #PB_Frame_Single : Gadgets()\Flags()\ivalue = #FDI_Frame_Single
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Double"
Gadgets()\Flags()\value = #PB_Frame_Double : Gadgets()\Flags()\ivalue = #FDI_Frame_Double
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Flat"
Gadgets()\Flags()\value = #PB_Frame_Flat : Gadgets()\Flags()\ivalue = #FDI_Frame_Flat
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Frame_Container"
Gadgets()\Flags()\value = #PB_Frame_Container : Gadgets()\Flags()\ivalue = #FDI_Frame_Container

;- H
EnumerationBinary
  #FDI_HyperLink_Underline
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_HyperLink
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_HyperLink
Gadgets()\name = "Hyperlink"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_HyperLink_Underline"
Gadgets()\Flags()\value = #PB_HyperLink_Underline : Gadgets()\Flags()\ivalue = #FDI_HyperLink_Underline

;- I
EnumerationBinary
  #FDI_Image_Border
  #FDI_Image_Raised
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Img
Gadgets()\node = 1
Gadgets()\name = "Image"
Gadgets()\icon = #IMAGE_FormIcons_Image
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Image_Border"
Gadgets()\Flags()\value = #PB_Image_Border : Gadgets()\Flags()\ivalue = #FDI_Image_Border
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Image_Border"
Gadgets()\Flags()\value = #PB_Image_Raised : Gadgets()\Flags()\ivalue = #FDI_Image_Raised
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_IP
Gadgets()\node = 1
Gadgets()\name = "IP"
Gadgets()\icon = #IMAGE_FormIcons_IPAddress

;- L
EnumerationBinary
  #FDI_ListIcon_CheckBoxes
  #FDI_ListIcon_ThreeState
  #FDI_ListIcon_MultiSelect
  #FDI_ListIcon_GridLines
  #FDI_ListIcon_FullRowSelect
  #FDI_ListIcon_HeaderDragDrop
  #FDI_ListIcon_AlwaysShowSelection
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ListIcon
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ListIcon
Gadgets()\name = "ListIcon"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_CheckBoxes"
Gadgets()\Flags()\value = #PB_ListIcon_CheckBoxes : Gadgets()\Flags()\ivalue = #FDI_ListIcon_CheckBoxes
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_ThreeState"
Gadgets()\Flags()\value = #PB_ListIcon_ThreeState : Gadgets()\Flags()\ivalue = #FDI_ListIcon_ThreeState
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_MultiSelect"
Gadgets()\Flags()\value = #PB_ListIcon_MultiSelect : Gadgets()\Flags()\ivalue = #FDI_ListIcon_MultiSelect
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_GridLines"
Gadgets()\Flags()\value = #PB_ListIcon_GridLines : Gadgets()\Flags()\ivalue = #FDI_ListIcon_GridLines
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_FullRowSelect"
Gadgets()\Flags()\value = #PB_ListIcon_FullRowSelect : Gadgets()\Flags()\ivalue = #FDI_ListIcon_FullRowSelect
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_HeaderDragDrop"
Gadgets()\Flags()\value = #PB_ListIcon_HeaderDragDrop : Gadgets()\Flags()\ivalue = #FDI_ListIcon_HeaderDragDrop
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListIcon_AlwaysShowSelection"
Gadgets()\Flags()\value = #PB_ListIcon_AlwaysShowSelection : Gadgets()\Flags()\ivalue = #FDI_ListIcon_AlwaysShowSelection
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
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_ColumnClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"

EnumerationBinary
  #FDI_ListView_MultiSelect
  #FDI_ListView_ClickSelect
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ListView
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_ListView
Gadgets()\name = "ListView"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListView_MultiSelect"
Gadgets()\Flags()\value = #PB_ListView_MultiSelect : Gadgets()\Flags()\ivalue = #FDI_ListView_MultiSelect
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ListView_ClickSelect" :
Gadgets()\Flags()\value = #PB_ListView_ClickSelect : Gadgets()\Flags()\ivalue = #FDI_ListView_ClickSelect
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"

;- O
EnumerationBinary
  #FDI_OpenGL_Keyboard
  #FDI_OpenGL_NoFlipSynchronization
  #FDI_OpenGL_FlipSynchronization
  #FDI_OpenGL_NoDepthBuffer
  #FDI_OpenGL_16BitDepthBuffer
  #FDI_OpenGL_24BitDepthBuffer
  #FDI_OpenGL_NoStencilBuffer
  #FDI_OpenGL_8BitStencilBuffer
  #FDI_OpenGL_NoAccumulationBuffer
  #FDI_OpenGL_32BitAccumulationBuffer
  #FDI_OpenGL_64BitAccumulationBuffer
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_OpenGL
Gadgets()\node = 1
Gadgets()\icon = #IMAGE_FormIcons_Container
Gadgets()\name = "OpenGL"
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_Keyboard"
Gadgets()\Flags()\value = #PB_OpenGL_Keyboard : Gadgets()\Flags()\ivalue = #FDI_OpenGL_Keyboard
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_NoFlipSynchronization"
Gadgets()\Flags()\value = #PB_OpenGL_NoFlipSynchronization : Gadgets()\Flags()\ivalue = #FDI_OpenGL_NoFlipSynchronization
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_FlipSynchronization"
Gadgets()\Flags()\value = #PB_OpenGL_FlipSynchronization : Gadgets()\Flags()\ivalue = #FDI_OpenGL_FlipSynchronization
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_NoDepthBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_NoDepthBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_NoDepthBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_16BitDepthBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_16BitDepthBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_16BitDepthBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_24BitDepthBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_24BitDepthBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_24BitDepthBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_NoStencilBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_NoStencilBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_NoStencilBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_8BitStencilBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_8BitStencilBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_8BitStencilBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_NoAccumulationBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_NoAccumulationBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_NoAccumulationBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_32BitAccumulationBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_32BitAccumulationBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_32BitAccumulationBuffer
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_OpenGL_64BitAccumulationBuffer"
Gadgets()\Flags()\value = #PB_OpenGL_64BitAccumulationBuffer : Gadgets()\Flags()\ivalue = #FDI_OpenGL_64BitAccumulationBuffer
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
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick" 
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MiddleButtonDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_MiddleButtonUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_KeyDown"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_KeyUp"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Input"

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Option
Gadgets()\node = 1
Gadgets()\name = "Option"
Gadgets()\icon = #IMAGE_FormIcons_Option

;- P
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Panel
Gadgets()\node = 2
Gadgets()\name = "Panel"
Gadgets()\icon = #IMAGE_FormIcons_Panel
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Resize"

EnumerationBinary
  #FDI_ProgressBar_Smooth
  #FDI_ProgressBar_Vertical
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ProgressBar
Gadgets()\node = 1
Gadgets()\name = "ProgressBar"
Gadgets()\icon = #IMAGE_FormIcons_ProgressBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ProgressBar_Smooth"
Gadgets()\Flags()\value = #PB_ProgressBar_Smooth : Gadgets()\Flags()\ivalue = #FDI_ProgressBar_Smooth
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ProgressBar_Vertical"
Gadgets()\Flags()\value = #PB_ProgressBar_Vertical : Gadgets()\Flags()\ivalue = #FDI_ProgressBar_Vertical

;- S
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Scintilla
Gadgets()\node = 1
Gadgets()\name = "Scintilla"
Gadgets()\icon = #IMAGE_FormIcons_Editor
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick" 

EnumerationBinary
  #FDI_ScrollArea_Flat
  #FDI_ScrollArea_Raised
  #FDI_ScrollArea_Single
  #FDI_ScrollArea_BorderLess
  #FDI_ScrollArea_Center
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_ScrollArea
Gadgets()\node = 2
Gadgets()\name = "ScrollArea"
Gadgets()\icon = #IMAGE_FormIcons_ScrollArea
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Flat"
Gadgets()\Flags()\value = #PB_ScrollArea_Flat : Gadgets()\Flags()\ivalue = #FDI_ScrollArea_Flat
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Raised"
Gadgets()\Flags()\value = #PB_ScrollArea_Raised : Gadgets()\Flags()\ivalue = #FDI_ScrollArea_Raised
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Single"
Gadgets()\Flags()\value = #PB_ScrollArea_Single : Gadgets()\Flags()\ivalue = #FDI_ScrollArea_Single
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_BorderLess"
Gadgets()\Flags()\value = #PB_ScrollArea_BorderLess : Gadgets()\Flags()\ivalue = #FDI_ScrollArea_BorderLess
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollArea_Center"
Gadgets()\Flags()\value = #PB_ScrollArea_Center : Gadgets()\Flags()\ivalue = #FDI_ScrollArea_Center
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Resize"

EnumerationBinary
  #FDI_ScrollBar_Vertical
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Scrollbar
Gadgets()\node = 1
Gadgets()\name = "ScrollBar"
Gadgets()\icon = #IMAGE_FormIcons_ScrollBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_ScrollBar_Vertical"
Gadgets()\Flags()\value = #PB_ScrollBar_Vertical : Gadgets()\Flags()\ivalue = #FDI_ScrollBar_Vertical

EnumerationBinary
  #FDI_Spin_ReadOnly
  #FDI_Spin_Numeric
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Spin
Gadgets()\node = 1
Gadgets()\name = "Spin"
Gadgets()\icon = #IMAGE_FormIcons_Spin
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Spin_ReadOnly"
Gadgets()\Flags()\value = #PB_Spin_ReadOnly : Gadgets()\Flags()\ivalue = #FDI_Spin_ReadOnly
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Spin_Numeric"
Gadgets()\Flags()\value = #PB_Spin_Numeric : Gadgets()\Flags()\ivalue = #FDI_Spin_Numeric
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Up"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Down"
  
EnumerationBinary
  #FDI_Splitter_Vertical
  #FDI_Splitter_Separator
  #FDI_Splitter_FirstFixed
  #FDI_Splitter_SecondFixed
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Splitter
Gadgets()\node = 2
Gadgets()\name = "Splitter"
Gadgets()\icon = #IMAGE_FormIcons_Splitter
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_Vertical"
Gadgets()\Flags()\value = #PB_Splitter_Vertical : Gadgets()\Flags()\ivalue = #FDI_Splitter_Vertical
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_Separator"
Gadgets()\Flags()\value = #PB_Splitter_Separator : Gadgets()\Flags()\ivalue = #FDI_Splitter_Separator
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_FirstFixed"
Gadgets()\Flags()\value = #PB_Splitter_FirstFixed : Gadgets()\Flags()\ivalue = #FDI_Splitter_FirstFixed
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Splitter_SecondFixed"
Gadgets()\Flags()\value = #PB_Splitter_SecondFixed : Gadgets()\Flags()\ivalue = #FDI_Splitter_SecondFixed

EnumerationBinary
  #FDI_String_Numeric
  #FDI_String_Password
  #FDI_String_ReadOnly
  #FDI_String_LowerCase
  #FDI_String_UpperCase
  #FDI_String_BorderLess
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_StringGadget
Gadgets()\node = 1
Gadgets()\name = "String"
Gadgets()\icon = #IMAGE_FormIcons_String
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_Numeric"
Gadgets()\Flags()\value = #PB_String_Numeric : Gadgets()\Flags()\ivalue = #FDI_String_Numeric
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_Password"
Gadgets()\Flags()\value = #PB_String_Password : Gadgets()\Flags()\ivalue = #FDI_String_Password
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_ReadOnly"
Gadgets()\Flags()\value = #PB_String_ReadOnly : Gadgets()\Flags()\ivalue = #FDI_String_ReadOnly
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_LowerCase"
Gadgets()\Flags()\value = #PB_String_LowerCase : Gadgets()\Flags()\ivalue = #FDI_String_LowerCase
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_UpperCase"
Gadgets()\Flags()\value = #PB_String_UpperCase : Gadgets()\Flags()\ivalue = #FDI_String_UpperCase
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_String_BorderLess"
Gadgets()\Flags()\value = #PB_String_BorderLess : Gadgets()\Flags()\ivalue = #FDI_String_BorderLess
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Focus"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LostFocus"

;- T
EnumerationBinary
  #FDI_Text_Center
  #FDI_Text_Right
  #FDI_Text_Border
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Text
Gadgets()\node = 1
Gadgets()\name = "Text"
Gadgets()\icon = #IMAGE_FormIcons_Text
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Text_Center"
Gadgets()\Flags()\value = #PB_Text_Center : Gadgets()\Flags()\ivalue = #FDI_Text_Center
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Text_Right"
Gadgets()\Flags()\value = #PB_Text_Right : Gadgets()\Flags()\ivalue = #FDI_Text_Right
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Text_Border"
Gadgets()\Flags()\value = #PB_Text_Border : Gadgets()\Flags()\ivalue = #FDI_Text_Border

EnumerationBinary
  #FDI_TrackBar_Ticks
  #FDI_TrackBar_Vertical
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Trackbar
Gadgets()\node = 1
Gadgets()\name = "TrackBar"
Gadgets()\icon = #IMAGE_FormIcons_TrackBar
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_TrackBar_Ticks"
Gadgets()\Flags()\value = #PB_TrackBar_Ticks : Gadgets()\Flags()\ivalue = #FDI_TrackBar_Ticks
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_TrackBar_Vertical"
Gadgets()\Flags()\value = #PB_TrackBar_Vertical : Gadgets()\Flags()\ivalue = #FDI_TrackBar_Vertical

EnumerationBinary
  #FDI_Tree_AlwaysShowSelection
  #FDI_Tree_NoLines
  #FDI_Tree_NoButtons
  #FDI_Tree_CheckBoxes
  #FDI_Tree_ThreeState
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_TreeGadget
Gadgets()\node = 1
Gadgets()\name = "Tree"
Gadgets()\icon = #IMAGE_FormIcons_Tree
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_AlwaysShowSelection"
Gadgets()\Flags()\value = #PB_Tree_AlwaysShowSelection : Gadgets()\Flags()\ivalue = #FDI_Tree_AlwaysShowSelection
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_NoLines"
Gadgets()\Flags()\value = #PB_Tree_NoLines : Gadgets()\Flags()\ivalue = #FDI_Tree_NoLines
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_NoButtons"
Gadgets()\Flags()\value = #PB_Tree_NoButtons : Gadgets()\Flags()\ivalue = #FDI_Tree_NoButtons
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_CheckBoxes"
Gadgets()\Flags()\value = #PB_Tree_CheckBoxes : Gadgets()\Flags()\ivalue = #FDI_Tree_CheckBoxes
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Tree_ThreeState"
Gadgets()\Flags()\value = #PB_Tree_ThreeState : Gadgets()\Flags()\ivalue = #FDI_Tree_ThreeState
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_LeftDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_RightDoubleClick"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_Change"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DragStart"

;- W
EnumerationBinary
  #FDI_Web_Edge
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Web
Gadgets()\node = 1
Gadgets()\name = "Web"
Gadgets()\icon = #IMAGE_FormIcons_Web
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_Web_Edge"
Gadgets()\Flags()\value = #PB_Web_Edge : Gadgets()\Flags()\ivalue = #FDI_Web_Edge
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_TitleChange"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_StatusChange"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DownloadStart"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DownloadProgress"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_DownloadEnd"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_PopupWindow"
AddElement(Gadgets()\Events()) : Gadgets()\Events()\name = "#PB_EventType_PopupMenu"

EnumerationBinary
  #FDI_WebView_Debug
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_WebView
Gadgets()\node = 1
Gadgets()\name = "WebView"
Gadgets()\icon = #IMAGE_FormIcons_Web
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_WebView_Debug"
Gadgets()\Flags()\value = #PB_WebView_Debug : Gadgets()\Flags()\ivalue = #FDI_WebView_Debug

;- Other features

; Tool bar.
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Toolbar
Gadgets()\node = 3
Gadgets()\name = "ToolBar"
Gadgets()\icon = #IMAGE_FormIcons_ToolBar

; Status bar.
EnumerationBinary
  #FDI_StatusBar_Raised
  #FDI_StatusBar_BorderLess
  #FDI_StatusBar_Center
  #FDI_StatusBar_Right
EndEnumeration

AddElement(Gadgets()) : Gadgets()\type = #Form_Type_StatusBar
Gadgets()\node = 3
Gadgets()\name = "StatusBar"
Gadgets()\icon = #IMAGE_FormIcons_Status
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_Raised"
Gadgets()\Flags()\value = #PB_StatusBar_Raised : Gadgets()\Flags()\ivalue = #FDI_StatusBar_Raised
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_BorderLess"
Gadgets()\Flags()\value = #PB_StatusBar_BorderLess : Gadgets()\Flags()\ivalue = #FDI_StatusBar_BorderLess
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_Center"
Gadgets()\Flags()\value = #PB_StatusBar_Center : Gadgets()\Flags()\ivalue = #FDI_StatusBar_Center
AddElement(Gadgets()\Flags()) : Gadgets()\Flags()\name = "#PB_StatusBar_Right"
Gadgets()\Flags()\value = #PB_StatusBar_Right : Gadgets()\Flags()\ivalue = #FDI_StatusBar_Right

; Menu bar.
AddElement(Gadgets()) : Gadgets()\type = #Form_Type_Menu
Gadgets()\node = 3
Gadgets()\name = "Menu"
Gadgets()\icon = #IMAGE_FormIcons_Menu

;}

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

Procedure InitVars()
  Select FormSkin
    Case #PB_OS_MacOS
      P_WinHeight = 22
      P_Status = 24
      P_Menu = 23
      P_Toolbar = 36
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
      P_Toolbar = 24
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
      P_Status = 26
      P_Menu = 28
      P_Toolbar = 38
      P_Font.s = "DejaVu Sans"
      P_FontSize = 9
      P_FontSizeL = 11
      P_FontGadget.s = "DejaVu Sans"
      P_FontGadgetSize = 9
      P_FontMenu.s = "DejaVu Sans"
      P_FontMenuSize = 11
      P_FontColumn.s = "DejaVu Sans"
      P_FontColumnSize = 11
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
  
  CompilerIf #CompileMac
    If DisplayDarkMode
      grid_color_bg = GetCocoaColor("underPageBackgroundColor")
      grid_color_text = GetCocoaColor("textColor")
      grid_color_light = GetCocoaColor("windowBackgroundColor")
      grid_color_mid = #Gray
    Else
      grid_color_bg = RGB(238, 238, 238)
      grid_color_text = #Black
      grid_color_light = #Gray; RGB(238, 238, 238)
      grid_color_mid = #Gray
    EndIf
  CompilerElse
    CompilerIf #CompileLinuxGtk
      Global *Style.GtkStyle = gtk_widget_get_style_(WindowID(#WINDOW_Main))
      grid_color_bg = RGB(*Style\bg[#GTK_STATE_NORMAL]\red >> 8, *Style\bg[#GTK_STATE_NORMAL]\green >> 8, *Style\bg[#GTK_STATE_NORMAL]\blue >> 8)
      grid_color_text = RGB(*Style\text[#GTK_STATE_NORMAL]\red >> 8, *Style\text[#GTK_STATE_NORMAL]\green >> 8, *Style\text[#GTK_STATE_NORMAL]\blue >> 8)
      grid_color_light = RGB(*Style\light[#GTK_STATE_NORMAL]\red >> 8, *Style\light[#GTK_STATE_NORMAL]\green >> 8, *Style\light[#GTK_STATE_NORMAL]\blue >> 8)
      grid_color_mid = RGB(*Style\mid[#GTK_STATE_NORMAL]\red >> 8, *Style\mid[#GTK_STATE_NORMAL]\green >> 8, *Style\mid[#GTK_STATE_NORMAL]\blue >> 8)
    CompilerElse
      grid_color_bg = RGB(238, 238, 238)
      grid_color_text = #Black
      grid_color_light = #Gray; RGB(238, 238, 238)
      grid_color_mid = #Gray
    CompilerEndIf
  CompilerEndIf
  
  If IsFont(#Form_Font) : FreeFont(#Form_Font) : EndIf
  If IsFont(#Form_FontColumnHeader) : FreeFont(#Form_FontColumnHeader) : EndIf
  If IsFont(#Form_FontMenu) : FreeFont(#Form_FontMenu) : EndIf

  LoadFont(#Form_Font,P_FontGadget,P_FontGadgetSize)
  LoadFont(#Form_FontColumnHeader,P_FontColumn,P_FontColumnSize)
  LoadFont(#Form_FontMenu,P_FontMenu,P_FontMenuSize)
EndProcedure

;- Include images
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
