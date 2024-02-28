;-----------------------------------------------------
;    Grid Gadget for Purebasic
;    This source is proprietary - please do not redistribute
;    The license below doesn't apply to this file for gdpcomputing's individual license holders.
;    (c) gdpcomputing / Gaetan Dupont-Panon
;    Version 0.5
;-----------------------------------------------------
; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
#Grid_Padding = 9
#Grid_TextEdit_Font_Strikethrough = 8
EnableExplicit

Enumeration
  #Grid_Align_Left = 0
  #Grid_Align_Center = 1
  #Grid_Align_Right = 2
  #Grid_Align_Top = 2
  #Grid_Align_Middle = 1
  #Grid_Align_Bottom = 0
EndEnumeration

Enumeration
  #Grid_Event_Cursor = 5
  #Grid_Event_Cell
  #Grid_Event_Selection
  #Grid_Event_Scroll
  #Grid_Event_Column_ButtonClick
  
  #Grid_Event_Cell_ContentChange
  #Grid_Event_Cell_CellsDeleted
  #Grid_Event_Cell_LeftButtonDown
  #Grid_Event_Cell_LeftDblClick
  #Grid_Event_Cell_LeftButtonUp
  #Grid_Event_Cell_RightButtonDown
  #Grid_Event_Cell_RightButtonUp
  
  #Grid_Event_KeyDown
  
  ; Cell types
  #Grid_Cell_TextWrap = 0
  #Grid_Cell_Checkbox = 1
  #Grid_Cell_Combobox = 2
  #Grid_Cell_Combobox_Editable = 3
  #Grid_Cell_Custom = 4
  #Grid_Cell_Text = 5
  #Grid_Cell_SpinGadget = 6
  
  
  #Grid_Scrolling_Column = 1
  #Grid_Scrolling_Row
  #Grid_Scrolling_Enabled
  #Grid_Scrolling_Vertical_Disabled
  #Grid_Scrolling_Horizontal_Disabled
  
  #Grid_Lines_Horizontal_Disabled
  #Grid_Lines_Vertical_Disabled
  
  #Grid_Color_HeaderBackground
  #Grid_Color_HeaderBackgroundSelected
  #Grid_Color_HeaderText
  #Grid_Color_HeaderTextSelected
  #Grid_Color_SelectAllButton
  #Grid_Color_LineLight
  #Grid_Color_LineDark
  #Grid_Color_Background
  #Grid_Color_CellFirstSelected
  #Grid_Color_CellSelected
  
  #Grid_Attribute_SelectedColumn
  #Grid_Attribute_SelectedRow
  
  #Grid_Caption_Row
  #Grid_Caption_Col
  
  #Grid_VisibleColumns
  #Grid_VisibleRows
  
  #Grid_Disable_Delete
EndEnumeration


CompilerSelect #PB_Compiler_OS
  CompilerCase #PB_OS_MacOS
    Global Grid_Scrollbar_Width = 16
  CompilerCase #PB_OS_Linux
    Global Grid_Scrollbar_Width = 18
  CompilerCase #PB_OS_Windows
    Global Grid_Scrollbar_Width = 18
CompilerEndSelect

;- Helping functions
Global grids_gs_windowmousedx.i, grids_gs_windowmousedy.i
Procedure.i grid_NewWindowMouseX(windownr.i)
  Protected wmx.i, dmx.i
  
  wmx = WindowMouseX(windownr)
  dmx = DesktopMouseX()
  If wmx >= 0
    grids_gs_windowmousedx = dmx-wmx
  EndIf
  ProcedureReturn DesktopMouseX()-grids_gs_windowmousedx
EndProcedure
Procedure.i grid_NewWindowMouseY(windownr.i)
  Protected wmy.i, dmy.i
  
  wmy = WindowMouseY(windownr)
  dmy = DesktopMouseY()
  If wmy >= 0
    grids_gs_windowmousedy = dmy-wmy
  EndIf
  ProcedureReturn DesktopMouseY()-grids_gs_windowmousedy
EndProcedure

Procedure grid_Max(val1,val2)
  If val1 > val2
    ProcedureReturn val1
  Else
    ProcedureReturn val2
  EndIf
EndProcedure
Procedure grid_Min(val1,val2)
  If val1 > val2
    ProcedureReturn val2
  Else
    ProcedureReturn val1
  EndIf
EndProcedure
Procedure.s grid_NumberToLetter(number.l)
  Protected i_firstletter, i_secondletter, firstletter.s, secondletter.s, thirdletter.s
  
  If number <= 25
    ProcedureReturn Chr(65 + number)
  ElseIf number <= 701
    i_firstletter = Round(number / 26,#PB_Round_Down)
    firstletter.s = Chr(65 + i_firstletter - 1)
    secondletter.s = Chr(64 + (number - i_firstletter*26) + 1)
    ProcedureReturn (firstletter + secondletter)
  ElseIf number <= 18277
    i_firstletter = Round((number - 26) / 676,#PB_Round_Down)
    i_secondletter = Round((number - 26- 676 * i_firstletter) / 26,#PB_Round_Down)
    firstletter.s = Chr(65 + i_firstletter - 1)
    secondletter.s = Chr(64 + i_secondletter + 1)
    thirdletter.s = Chr(64 + number - 26 - (676 * i_firstletter) - 26 * i_secondletter + 1)
    ProcedureReturn (firstletter + secondletter + thirdletter)
  EndIf
  
EndProcedure


Structure grid_FontList
  fontname.s
  fontsize.w
  fontflags.l
  hfont.i
EndStructure
Structure GridCellStyle
  style_end.l
  fontname.s
  fontsize.w
  fontflags.l
  color.l
EndStructure
Structure GridRowsCols
  wh.w
  wtext.w
  caption.s
  g_data.i
  visible.b
  type.w
  
  *buttonid ; column button imageID
EndStructure
Structure GridCells
  type.w
  state.i ; checkboxes: (0, 1) ; comboboxes: id of the combo list
  
  content.s
  c_data.i
  locked.b
  halign.b
  valign.b
  ident.w
  backColor.l
  backColorSet.b
  List style.GridCellStyle()
EndStructure
Structure GridSelection
  sel_row.l
  sel_row_end.l
  sel_col.l
  sel_col_end.l
EndStructure
Structure GridComboValues
  value.s
  c_data.i
EndStructure
Structure GridComboList
  List values.GridComboValues()
EndStructure
Structure GridColRow
  col.i
  row.i
EndStructure

Structure GridEvents
  event.i
  event_row.i
  event_column.i
  event_cell.i
  List event_cells.GridColRow()
EndStructure

Structure Grid_Struct
  ; Colors
  color_header.i
  color_header_text.i
  color_header_text_sel.i
  color_header_sel.i
  color_selectall.i
  color_linedark.i
  color_linelight.i
  color_background.i
  color_cellfirstsel.i
  color_cellsel.i
  
  ; Gadgets handles
  *canvas
  *hscroll
  *vscroll
  *font
  *hwnd
  hidden.b
  gadgetlist.i
  parent_item.i
  
  ; Cell types
  *checkboximgyes
  *checkboximgno
  List combolists.GridComboList()
  *ac_window
  *ac_list
  ac_scroll.i
  ac_active.b
  ac_col.i
  ac_row.i
  ac_font.i
  ac_fontsize.i
  ac_itemheight.i
  ac_scrollv.i
  ac_scrollh.i
  ac_currentcombo.i
  
  redraw.b
  redraw_ignore_grid.b
  
  ; Event
  lbuttondown.b
  cell_selected.s
  cell_selected_move.s
  oldmousex.w
  oldmousey.w
  scrolltimer.b
  
  ; Get Selection: position
  selectionrange.i
  
  ; When edit mode is on and user keys "tab" then "enter", go to the cell below the last edited cell.
  keep_pos_col.i
  keep_pos_row.i
  
  ; Edit cursor
  timer_edit.b  ; on / off
  timer_edit2.b ; visible / invisible
  
  ; Image handles
  *edit_dc
  *select_dc
  *tempimg
  
  ; Default style
  dfont.s
  dfontsize.w
  dfontcolor.l
  
  ; Temp style
  tstyle.b
  tfont.s
  tfontsize.w
  tfontcolor.l
  tfontflags.l
  
  ; Current cursor
  cursor.w
  
  ; Col/Row resize
  resizing.b
  resize_col.l
  resize_row.l
  resize_posx.w
  resize_posy.w
  default_row_height.i
  default_col_width.i
  
  ; Position / size
  x.w
  y.w
  width.w
  height.w
  innerwidth.w
  innerheight.w
  
  ; Headers sizes
  header_row_width.w
  header_row_hidden.b
  header_col_height.w
  header_col_hidden.b
  
  ; Edit
  edit_col.l
  edit_row.l
  edit_sel_start.l
  edit_sel_end.l
  edit_selecting.b
  edit_pos.l
  edit_old_content.s
  List edit_old_style.GridCellStyle()
  edit_x.l
  edit_y.l
  edit_x2.l
  edit_y2.l
  edit_combo_pos.i
  disable_delete.b
  
  ; Scroll position
  scrollbar_excel.b
  
  xscroll_disabled.b
  yscroll_disabled.b
  scroll_enabled.b
  xscroll.l
  xscroll_end.l
  yscroll.l
  yscroll_end.l
  
  ; Delayed Scroll
  scroll_time_x.w
  scroll_time_y.w
  
  ; Selection
  List sel.GridSelection()
  
  ; Event queue
  List events.GridEvents()
  ; Current event
  c_event.i : c_event_row.i : c_event_column.i : c_event_cell.i :List c_event_cells.GridColRow() :  c_event_index_cells.i
  
  numcols.l
  numrows.l
  maxnumcols.l
  maxnumrows.l
  
  ; attr
  hline.b
  vline.b
  
  ; Hash maps holding cells, cols and rows content (linked to their indexes, not the columns/rows number).
  Map cells.GridCells()
  Map cols.GridRowsCols()
  Map rows.GridRowsCols()
  
  ; Arrays holding indexes for columns and rows (allows to delete, insert or swap easily columns/rows).
  Array col.l(20000)
  Array row.l(2000000)
  col_index.l
  row_index.l
EndStructure


Global NewList grid_grids.Grid_Struct(), grid_maxrows = 2000000, grid_maxcols = 20000
Global grids_dblclick, grid_deltagadgetposx, grid_deltagadgetposy
Global NewMap grids_fonts.grid_FontList() ; FontNameSize & NULL B I

Declare grid_DoRedraw(*grid.Grid_Struct,redraw_grid.b = #True)
Declare grid_DoKeyDownEvent(*grid.Grid_Struct, wparam, modifier)
Declare grid_DoEditFieldEvent(*grid.Grid_Struct, key)
Declare grid_GetCellTextWidth(*grid.Grid_Struct, col_index, row_index)
Declare grid_ResizeGadget(*grid.Grid_Struct, x, y, width, height)
Declare grid_GetGadgetAttribute(*grid.Grid_Struct, attribute)
Declare grid_ScrollEvent()
Declare grid_CanvasEvent()
Declare grid_ACListEvent()
Declare grid_TimerEvent()
Declare grid_WindowEvent()


CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
  #Grid_Command = #PB_Canvas_Command
CompilerElse
  #Grid_Command = #PB_Canvas_Control
CompilerEndIf

Procedure grid_BuildScrollbarSize(*grid.Grid_Struct)
  Protected drawing_y, drawing_x, current_row, current_column, oldglist
  
  If Not *grid\header_row_hidden
    drawing_x = *grid\header_row_width + 1
  Else
    drawing_x = 0
  EndIf
  
  current_column = 0
  
  While drawing_x < *grid\innerwidth
    If current_column < *grid\maxnumcols
      
      If FindMapElement(*grid\cols(), Str(*grid\col(current_column)))
        drawing_x + *grid\cols()\wh + 1
      Else
        drawing_x + *grid\default_col_width + 1
      EndIf
      current_column + 1
    Else
      current_column + 1
      Break
    EndIf
  Wend
  
  If current_column > *grid\maxnumcols ; all cols are displayed meaning no H scrollbar is required
    *grid\xscroll = 0
    *grid\redraw = #True
    *grid\innerheight = *grid\height
    
    If *grid\hscroll
      FreeGadget(*grid\hscroll)
      *grid\hscroll = 0
      grid_ResizeGadget(*grid, *grid\x,*grid\y,*grid\width,*grid\height)
    EndIf
  Else
    If Not *grid\xscroll_disabled
      If Not *grid\hscroll
        *grid\redraw = #True
        *grid\innerheight = *grid\height - Grid_Scrollbar_Width
        
        ResizeGadget(*grid\canvas, *grid\x,*grid\y,*grid\innerwidth,*grid\innerheight)
        
        If *grid\gadgetlist > -1
          oldglist = UseGadgetList(WindowID(*grid\hwnd))
          UseGadgetList(oldglist)
          
          OpenGadgetList(*grid\gadgetlist, *grid\parent_item)
        Else
          oldglist = UseGadgetList(WindowID(*grid\hwnd))
        EndIf
        
        *grid\hscroll = ScrollBarGadget(#PB_Any,*grid\x,*grid\y+*grid\height-Grid_Scrollbar_Width,*grid\width-Grid_Scrollbar_Width,Grid_Scrollbar_Width,0,1,1)
        BindGadgetEvent(*grid\hscroll, @grid_ScrollEvent())
        
        If *grid\gadgetlist > -1
          CloseGadgetList()
          UseGadgetList(oldglist);
        Else
          UseGadgetList(oldglist)
        EndIf
      EndIf
      
      SetGadgetAttribute(*grid\hscroll,#PB_ScrollBar_Maximum,*grid\maxnumcols + 10 - 1);current_column + 10 + 1)
      SetGadgetAttribute(*grid\hscroll,#PB_ScrollBar_PageLength, 10)
    EndIf
  EndIf
  
  ; Vertical scrollbar
  drawing_y = 0
  
  If drawing_y < *grid\header_col_height+1 And Not *grid\header_col_hidden
    drawing_y = *grid\header_col_height+1
  EndIf
  
  current_row = 0
  
  While  drawing_y < *grid\innerheight
    If current_row < *grid\maxnumrows
      If FindMapElement(*grid\rows(), Str(*grid\row(current_row)))
        If *grid\rows()\visible ; don't draw
          current_row + 1
          Continue
        EndIf
        
        drawing_y + *grid\rows()\wh + 1
      Else
        drawing_y + *grid\default_row_height + 1
      EndIf
      current_row + 1
    Else
      current_row + 1
      Break
    EndIf
  Wend
  
  If current_row > *grid\maxnumrows  ; all rows are displayed meaning no V scrollbar is required
    *grid\yscroll = 0
    *grid\redraw = #True
    *grid\innerwidth = *grid\width
    
    If *grid\vscroll
      FreeGadget(*grid\vscroll)
      *grid\vscroll = 0
      grid_ResizeGadget(*grid, *grid\x,*grid\y,*grid\width,*grid\height)
    EndIf
    
  Else ; build scrollbar size
    If Not *grid\yscroll_disabled
      If Not *grid\vscroll
        *grid\redraw = #True
        *grid\innerwidth = *grid\width - Grid_Scrollbar_Width
        
        ResizeGadget(*grid\canvas, *grid\x,*grid\y,*grid\innerwidth,*grid\innerheight)
        
        If *grid\gadgetlist > -1
          oldglist = UseGadgetList(WindowID(*grid\hwnd))
          UseGadgetList(oldglist)
          OpenGadgetList(*grid\gadgetlist, *grid\parent_item)
        Else
          oldglist = UseGadgetList(WindowID(*grid\hwnd))
        EndIf
        
        *grid\vscroll = ScrollBarGadget(#PB_Any,*grid\x+*grid\width-Grid_Scrollbar_Width,*grid\y,Grid_Scrollbar_Width,*grid\innerheight,0,1,1,#PB_ScrollBar_Vertical)
        BindGadgetEvent(*grid\vscroll, @grid_ScrollEvent())
        
        If *grid\gadgetlist > -1
          CloseGadgetList()
          UseGadgetList(oldglist)
        Else
          UseGadgetList(oldglist)
        EndIf
      EndIf
      
      SetGadgetAttribute(*grid\vscroll,#PB_ScrollBar_Maximum, *grid\maxnumrows + 10 - 1) ; - current_row + 10 + 1)
      SetGadgetAttribute(*grid\vscroll,#PB_ScrollBar_PageLength, 10)
    EndIf
  EndIf
EndProcedure

Procedure grid_DrawCheckbox(*grid.Grid_Struct)
  *grid\checkboximgno = CreateImage(#PB_Any,16,16)
  *grid\checkboximgyes = CreateImage(#PB_Any,16,16)
  
  StartDrawing(ImageOutput(*grid\checkboximgno))
  Box(0,0,16,16,RGB(128,128,128))
  Box(1,1,14,14,RGB(255,255,255))
  StopDrawing()
  
  StartDrawing(ImageOutput(*grid\checkboximgyes))
  Box(0,0,16,16,RGB(128,128,128))
  Box(1,1,14,14,RGB(255,255,255))
  
  ; check drawing right part
  LineXY(6,10,12,4,RGB(128,128,128))
  LineXY(7,10,12,5,RGB(128,128,128))
  LineXY(7,11,12,6,RGB(128,128,128))
  
  ; check drawing left part
  LineXY(4,8,4,6,RGB(128,128,128))
  LineXY(5,9,5,7,RGB(128,128,128))
  LineXY(6,9,6,8,RGB(128,128,128))
  StopDrawing()
EndProcedure

Procedure GridGadget(x, y, width, height, hwnd, maxcols = 20000, maxrows = 1000000, def_row_height = 21, def_col_width = 100, dfont.s = "Arial", dfontsize.w = 11, dfontcolor.l = 0, parent = -1, parent_item = 0)
  Protected i, style.i, oldgadgetlist, *grid.Grid_Struct
  
  *grid = AddElement(grid_grids())
  
  *grid\gadgetlist = parent
  *grid\parent_item = parent_item
  
  *grid\keep_pos_col = - 1
  *grid\keep_pos_row = -1
  
  *grid\canvas = CanvasGadget(#PB_Any,x,y,width-Grid_Scrollbar_Width,height-Grid_Scrollbar_Width, #PB_Canvas_Keyboard)
  
  *grid\hwnd = hwnd
  *grid\tempimg = CreateImage(#PB_Any,1,1)
  *grid\redraw = #True
  
  AddWindowTimer(*grid\hwnd, 145876, 500)
  AddWindowTimer(*grid\hwnd, 145875, 50)
  
  grid_DrawCheckbox(*grid)
  
  ; sets colors:
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    *grid\color_header = RGB(218,231,245)
    *grid\color_header_text = RGB(39, 37, 57)
    *grid\color_header_text_sel = RGB(250,230,110)
    *grid\color_header_sel = RGB(30,50,90)
    *grid\color_selectall = RGB(170,185,210)
    *grid\color_linedark = RGB(160,175,200)
    *grid\color_linelight = RGB(220,220,220)
    *grid\color_background = RGB(255,255,255) ;RGB(150,185,225)
    *grid\color_cellfirstsel = RGBA(215,235,255,200)
    *grid\color_cellsel = RGBA(180,220,255,200)
  CompilerElse
    *grid\color_header = RGB(233,233,233)
    *grid\color_header_text = RGB(98,98,98)
    *grid\color_header_text_sel = RGB(255,255,255)
    *grid\color_header_sel = RGB(185,185,185)
    *grid\color_selectall = RGB(255,255,255)
    *grid\color_linedark = RGB(150,150,150)
    *grid\color_linelight = RGB(206,206,206)
    *grid\color_background = RGB(255,255,255) ;RGB(190,190,200)
    *grid\color_cellfirstsel = RGBA(215,235,255,200)
    *grid\color_cellsel = RGBA(180,220,255,200)
  CompilerEndIf
  
  *grid\default_col_width = DesktopScaledX(def_col_width)
  *grid\default_row_height = DesktopScaledY(def_row_height)
  
  *grid\hscroll = ScrollBarGadget(#PB_Any,x,y+height-Grid_Scrollbar_Width,width-Grid_Scrollbar_Width,Grid_Scrollbar_Width,0,1,1)
  *grid\vscroll = ScrollBarGadget(#PB_Any,x+width-Grid_Scrollbar_Width,y,Grid_Scrollbar_Width,height-Grid_Scrollbar_Width,0,1,1,#PB_ScrollBar_Vertical)
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    *grid\font = LoadFont(#PB_Any,"Lucida Grande",12,#PB_Font_Bold)
  CompilerElse
    *grid\font = LoadFont(#PB_Any,"Segoe UI",9)
  CompilerEndIf
  
  If Not FindMapElement(grids_fonts(),dfont+Str(dfontsize))
    AddMapElement(grids_fonts(),dfont+Str(dfontsize))
    grids_fonts()\fontname = dfont
    grids_fonts()\fontsize = dfontsize
    grids_fonts()\hfont = LoadFont(#PB_Any,grids_fonts()\fontname,grids_fonts()\fontsize)
  EndIf
  
  *grid\dfont = dfont
  *grid\dfontcolor = dfontcolor
  *grid\dfontsize = dfontsize
  
  *grid\x = x
  *grid\y = y
  *grid\width = width
  *grid\height = height
  *grid\innerwidth = width-Grid_Scrollbar_Width
  *grid\innerheight = height-Grid_Scrollbar_Width
  
  *grid\header_col_height = DesktopScaledY(21)
  *grid\header_row_width = 0 ; calculated during drawing
  
  ; Set the selection to the top left cell.
  AddElement(*grid\sel())
  *grid\sel()\sel_col = 0
  *grid\sel()\sel_col_end = 0
  *grid\sel()\sel_row = 0
  *grid\sel()\sel_row_end = 0
  
  *grid\resize_col = - 1
  *grid\resize_row = - 1
  
  *grid\edit_col = - 1
  *grid\edit_row = - 1
  
  DisableDebugger
  For i = 0 To maxcols
    *grid\col(i) = i
  Next
  
  For i = 0 To maxrows
    *grid\row(i) = i
  Next
  *grid\col_index = grid_maxcols
  *grid\row_index = grid_maxrows
  EnableDebugger
  
  *grid\maxnumcols = maxcols
  *grid\maxnumrows = maxrows
  *grid\scroll_enabled = #True
  
  SetActiveGadget(*grid\canvas)
  RemoveKeyboardShortcut(*grid\hwnd, #PB_Shortcut_Tab)
  RemoveKeyboardShortcut(*grid\hwnd, #PB_Shortcut_Tab|#PB_Shortcut_Shift)
  
  grid_BuildScrollbarSize(*grid)
  
  ; Setup for combo boxes
  *grid\ac_window = OpenWindow(#PB_Any,0,0,200,200,"",#PB_Window_BorderLess | #PB_Window_Invisible | #PB_Window_NoGadgets,WindowID(*grid\hwnd))
  oldgadgetlist = UseGadgetList(WindowID(*grid\ac_window))
  *grid\ac_list = CanvasGadget(#PB_Any,0,0,200,200,#PB_Canvas_Keyboard)
  
  *grid\ac_row = -1
  *grid\ac_col = -1
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    *grid\ac_fontsize = 13
    *grid\ac_font = LoadFont(#PB_Any,"Lucida Grande",*grid\ac_fontsize)
    *grid\ac_itemheight = 17
  CompilerElse
    *grid\ac_fontsize = 10
    *grid\ac_font = LoadFont(#PB_Any,"Arial",*grid\ac_fontsize)
    *grid\ac_itemheight = 17
  CompilerEndIf
  
  ; Event handling
  If *grid\vscroll
    BindGadgetEvent(*grid\vscroll, @grid_ScrollEvent())
  EndIf
  If *grid\hscroll
    BindGadgetEvent(*grid\hscroll, @grid_ScrollEvent())
  EndIf
  
  BindGadgetEvent(*grid\canvas, @grid_CanvasEvent())
  BindGadgetEvent(*grid\ac_list, @grid_ACListEvent())
  
  ; Unbind first (in case there are more than one grid in the same window)
  UnbindEvent(#PB_Event_Timer, @grid_TimerEvent(), *grid\hwnd)
  UnbindEvent(#PB_Event_MoveWindow, @grid_WindowEvent(), *grid\hwnd)
  BindEvent(#PB_Event_Timer, @grid_TimerEvent(), *grid\hwnd)
  BindEvent(#PB_Event_MoveWindow, @grid_WindowEvent(), *grid\hwnd)
  
  HideWindow(*grid\ac_window,1)
  StickyWindow(*grid\ac_window,1)
  SetActiveWindow(*grid\hwnd)
  UseGadgetList(oldgadgetlist)
  
  ProcedureReturn *grid
EndProcedure

Procedure grid_FreeGadget(*grid.Grid_Struct)
  
  ; Unbind all events to avoid issues
  ;
  If *grid\vscroll
    UnbindGadgetEvent(*grid\vscroll, @grid_ScrollEvent())
  EndIf
  If *grid\hscroll
    UnbindGadgetEvent(*grid\hscroll, @grid_ScrollEvent())
  EndIf
  
  UnbindGadgetEvent(*grid\canvas, @grid_CanvasEvent())
  UnbindGadgetEvent(*grid\ac_list, @grid_ACListEvent())
  UnbindEvent(#PB_Event_Timer, @grid_TimerEvent(), *grid\hwnd)
  UnbindEvent(#PB_Event_MoveWindow, @grid_WindowEvent(), *grid\hwnd)
  
  FreeFont(*grid\ac_font)
  FreeFont(*grid\font)
  
  FreeGadget(*grid\ac_list)
  
  CloseWindow(*grid\ac_window)
  
  If *grid\hscroll
    FreeGadget(*grid\hscroll)
  EndIf
  
  If *grid\vscroll
    FreeGadget(*grid\vscroll)
  EndIf
  
  FreeGadget(*grid\canvas)
  FreeImage(*grid\tempimg)
  FreeImage(*grid\checkboximgno)
  FreeImage(*grid\checkboximgyes)
  
  ChangeCurrentElement(grid_grids(),*grid)
  DeleteElement(grid_grids())
EndProcedure


Procedure grid_SetGadgetAttribute(*grid.Grid_Struct, attribute, value)
  Protected xscroll.b, diff, maxscroll, more, yscroll.b, max, oldglist
  
  Select attribute
    Case #Grid_Attribute_SelectedColumn
      LastElement(*grid\sel())
      *grid\sel()\sel_col = value
      *grid\sel()\sel_col_end = value
      *grid\redraw = #True
      
    Case #Grid_Attribute_SelectedRow
      LastElement(*grid\sel())
      *grid\sel()\sel_row = value
      *grid\sel()\sel_row_end = value
      *grid\redraw = #True
      
    Case #Grid_Disable_Delete
      *grid\disable_delete = value
      
    Case #Grid_Lines_Horizontal_Disabled
      *grid\hline = value
      *grid\redraw = #True
      
    Case #Grid_Lines_Vertical_Disabled
      *grid\vline = value
      *grid\redraw = #True
      
    Case #Grid_Caption_Col
      *grid\header_col_hidden = value
      If value = 0
        *grid\header_col_height = 21
      Else
        *grid\header_col_height = 0
      EndIf
      grid_ResizeGadget(*grid, *grid\x, *grid\y, *grid\width, *grid\height)
      *grid\redraw = #True
      
    Case #Grid_Caption_Row
      *grid\header_row_hidden = value
      grid_ResizeGadget(*grid, *grid\x, *grid\y, *grid\width, *grid\height)
      *grid\redraw = #True
      
    Case #Grid_Scrolling_Vertical_Disabled
      If value = #True And *grid\yscroll_disabled = #False
        *grid\yscroll_disabled = #True
        *grid\yscroll = 0
        *grid\redraw = #True
        *grid\innerwidth = *grid\width
        
        If *grid\vscroll
          FreeGadget(*grid\vscroll)
          *grid\vscroll = 0
        EndIf
        
        grid_ResizeGadget(*grid, *grid\x,*grid\y,*grid\width,*grid\height)
      EndIf
      
      If value = #False And *grid\yscroll_disabled = #True
        *grid\yscroll_disabled = #False
        *grid\redraw = #True
        *grid\innerwidth = *grid\width - Grid_Scrollbar_Width
        
        ResizeGadget(*grid\canvas, *grid\x,*grid\y,*grid\innerwidth,*grid\innerheight)
        
        oldglist = UseGadgetList(*grid\gadgetlist)
        OpenGadgetList(*grid\gadgetlist, *grid\parent_item)
        *grid\vscroll = ScrollBarGadget(#PB_Any,*grid\x+*grid\width-Grid_Scrollbar_Width,*grid\y,Grid_Scrollbar_Width,*grid\height-Grid_Scrollbar_Width,0,1,1,#PB_ScrollBar_Vertical)
        BindGadgetEvent(*grid\vscroll, @grid_ScrollEvent())
        CloseGadgetList()
        UseGadgetList(oldglist)
      EndIf
      
    Case #Grid_Scrolling_Horizontal_Disabled
      If value = #True And *grid\xscroll_disabled = 0
        *grid\xscroll_disabled = 1
        *grid\xscroll = 0
        *grid\redraw = #True
        *grid\innerheight = *grid\height
        
        If *grid\hscroll
          FreeGadget(*grid\hscroll)
          *grid\hscroll = 0
        EndIf
        
        grid_ResizeGadget(*grid, *grid\x,*grid\y,*grid\width,*grid\height)
      EndIf
      
      If value = #False And *grid\xscroll_disabled = #True
        *grid\xscroll_disabled = 0
        *grid\redraw = #True
        *grid\innerheight = *grid\height - Grid_Scrollbar_Width
        ResizeGadget(*grid\canvas, *grid\x,*grid\y,*grid\innerwidth,*grid\innerheight)
        
        oldglist = UseGadgetList(*grid\gadgetlist)
        OpenGadgetList(*grid\gadgetlist, *grid\parent_item)
        *grid\hscroll = ScrollBarGadget(#PB_Any,*grid\x,*grid\y+*grid\height-Grid_Scrollbar_Width,*grid\width-Grid_Scrollbar_Width,Grid_Scrollbar_Width,0,1,1)
        BindGadgetEvent(*grid\hscroll, @grid_ScrollEvent())
        CloseGadgetList()
        UseGadgetList(oldglist)
      EndIf
      
    Case #Grid_Scrolling_Column
      If Not *grid\scroll_enabled Or *grid\xscroll_disabled Or Not *grid\hscroll
        ProcedureReturn
      EndIf
      
      max = GetGadgetAttribute(*grid\hscroll,#PB_ScrollBar_Maximum) - GetGadgetAttribute(*grid\hscroll,#PB_ScrollBar_PageLength)
      If value > max
        value = max
      EndIf
      
      If value < 0
        value = 0
      EndIf
      
      If *grid\xscroll <> value
        *grid\xscroll = value
        SetGadgetState(*grid\hscroll,*grid\xscroll)
        
        *grid\redraw = #True
      EndIf
      
    Case #Grid_Scrolling_Row
      If Not *grid\scroll_enabled Or *grid\yscroll_disabled Or Not *grid\vscroll
        ProcedureReturn
      EndIf
      
      max = GetGadgetAttribute(*grid\vscroll,#PB_ScrollBar_Maximum) - GetGadgetAttribute(*grid\vscroll,#PB_ScrollBar_PageLength)
      If value > max
        value = max
      EndIf
      
      If value < 0
        value = 0
      EndIf
      
      If *grid\yscroll <> value
        *grid\yscroll = value
        SetGadgetState(*grid\vscroll,*grid\yscroll)
        
        *grid\redraw = #True
      EndIf
  EndSelect
  
EndProcedure
Procedure.i grid_GetGadgetAttribute(*grid.Grid_Struct, attribute)
  Protected value.i, drawing_x, drawing_y, current_row, current_column, indexed_current_column, indexed_current_row
  
  Select attribute
    Case #Grid_Disable_Delete
      value = *grid\disable_delete
      
    Case #Grid_Scrolling_Row
      value = *grid\yscroll
      
    Case #Grid_Scrolling_Column
      value = *grid\xscroll
      
    Case #Grid_VisibleColumns
      If Not *grid\header_row_hidden
        drawing_x = *grid\header_row_width + 1
      Else
        drawing_x = 0
      EndIf
      
      current_column = *grid\xscroll
      
      While drawing_x < *grid\innerwidth
        If current_column < *grid\maxnumcols
          indexed_current_column = *grid\col(current_column)
          
          If FindMapElement(*grid\cols(), Str(indexed_current_column))
            drawing_x + *grid\cols()\wh + 1
          Else
            drawing_x + *grid\default_col_width + 1
          EndIf
          current_column + 1
        Else
          current_column + 1
          Break
        EndIf
      Wend
      value = current_column - *grid\xscroll
      
      If value > *grid\maxnumcols
        value = *grid\maxnumcols
      EndIf
      
    Case #Grid_VisibleRows
      drawing_y = 22
      
      current_row = *grid\yscroll
      
      While  drawing_y < *grid\innerheight
        If current_row < *grid\maxnumrows
          indexed_current_row = *grid\row(current_row)
          
          If FindMapElement(*grid\rows(), Str(indexed_current_row))
            drawing_y + *grid\rows()\wh + 1
          Else
            drawing_y + *grid\default_row_height + 1
          EndIf
          current_row + 1
        Else
          current_row + 1
          Break
        EndIf
      Wend
      value = current_row - *grid\yscroll
      
      If value > *grid\maxnumrows
        value = *grid\maxnumrows
      EndIf
  EndSelect
  
  ProcedureReturn value
EndProcedure

Procedure grid_SetActiveGadget(*grid.Grid_Struct)
  SetActiveGadget(*grid\canvas)
EndProcedure

Procedure grid_IsActiveGadget(*grid.Grid_Struct)
  If GetActiveGadget() = *grid\canvas
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure grid_ResizeGadget(*grid.Grid_Struct, x, y, width, height)
  Protected maxscroll, more
  
  If x <> #PB_Ignore
    *grid\x = x
  EndIf
  
  If y <> #PB_Ignore
    *grid\y = y
  EndIf
  
  If width <> #PB_Ignore
    *grid\width = width
    
    If *grid\yscroll_disabled Or *grid\vscroll = 0
      *grid\innerwidth = width
    Else
      *grid\innerwidth = width - Grid_Scrollbar_Width
    EndIf
    
  EndIf
  
  If height <> #PB_Ignore
    *grid\height = height
    
    If *grid\xscroll_disabled Or *grid\hscroll = 0
      *grid\innerheight = height
    Else
      *grid\innerheight = height - Grid_Scrollbar_Width
    EndIf
  EndIf
  
  ResizeGadget(*grid\canvas, *grid\x,*grid\y,*grid\innerwidth,*grid\innerheight)
  
  If Not *grid\xscroll_disabled And *grid\hscroll
    ResizeGadget(*grid\hscroll,x,*grid\y + *grid\innerheight,*grid\innerwidth,Grid_Scrollbar_Width)
  EndIf
  
  If Not *grid\yscroll_disabled And *grid\vscroll
    ResizeGadget(*grid\vscroll,*grid\x + *grid\innerwidth,y,Grid_Scrollbar_Width,*grid\innerheight)
  EndIf
  
  ; build scrollbar size
  grid_BuildScrollbarSize(*grid)
  
  *grid\redraw = #True
EndProcedure

Procedure grid_GadgetX(*grid.Grid_Struct)
  ProcedureReturn *grid\x
EndProcedure

Procedure grid_GadgetY(*grid.Grid_Struct)
  ProcedureReturn *grid\y
EndProcedure

Procedure grid_GadgetWidth(*grid.Grid_Struct)
  ProcedureReturn *grid\width
EndProcedure

Procedure grid_GadgetHeight(*grid.Grid_Struct)
  ProcedureReturn *grid\height
EndProcedure

Procedure grid_GadgetInnerWidth(*grid.Grid_Struct)
  ProcedureReturn DesktopScaledX(*grid\innerwidth)
EndProcedure

Procedure grid_GadgetInnerHeight(*grid.Grid_Struct)
  ProcedureReturn DesktopScaledY(*grid\innerheight)
EndProcedure

Procedure grid_SetGadgetColor(*grid.Grid_Struct,ColorType,Color)
  Select ColorType
    Case #Grid_Color_CellFirstSelected
      *grid\color_cellfirstsel = Color
    Case #Grid_Color_CellSelected
      *grid\color_cellsel = Color
    Case #Grid_Color_HeaderBackground
      *grid\color_header = Color
    Case #Grid_Color_HeaderBackgroundSelected
      *grid\color_header_sel = Color
    Case #Grid_Color_HeaderText
      *grid\color_header_text = Color
    Case #Grid_Color_HeaderTextSelected
      *grid\color_header_text_sel = Color
    Case #Grid_Color_SelectAllButton
      *grid\color_selectall = Color
    Case #Grid_Color_LineLight
      *grid\color_linelight = Color
    Case #Grid_Color_LineDark
      *grid\color_linedark = Color
    Case #Grid_Color_Background
      *grid\color_background = Color
  EndSelect
  
  *grid\redraw = #True
EndProcedure
Procedure grid_SetMaxGridRowsColumns(cols,rows)
  grid_maxcols = cols
  grid_maxrows = rows
EndProcedure

Procedure grid_HideGadget(*grid.Grid_Struct, value.b)
  *grid\hidden = value
  
  HideGadget(*grid\canvas,value)
EndProcedure

Procedure grid_Redraw(*grid.Grid_Struct)
  *grid\redraw = #True
EndProcedure


Procedure.i grid_GetNumberOfColumns(*grid.Grid_Struct)
  ProcedureReturn *grid\maxnumcols
EndProcedure

Procedure.i grid_GetNumberOfRows(*grid.Grid_Struct)
  ProcedureReturn *grid\maxnumrows
EndProcedure

Procedure grid_SetDefaultStyle(*grid.Grid_Struct, font.s, size.w, color.l)
  *grid\dfont = font
  *grid\dfontcolor = color
  *grid\dfontsize = size
  
  If Not FindMapElement(grids_fonts(), font+Str(size))
    AddMapElement(grids_fonts(),font+Str(size))
    grids_fonts()\fontname = font
    grids_fonts()\fontsize = size
    grids_fonts()\hfont = LoadFont(#PB_Any,grids_fonts()\fontname,grids_fonts()\fontsize)
  EndIf
EndProcedure

Procedure grid_SetColumnButton(*grid.Grid_Struct, index, *imageID)
  Protected col.s
  
  col.s = Str(*grid\col(index))
  If Not FindMapElement(*grid\cols(),col)
    AddMapElement(*grid\cols(),col)
  EndIf
  
  *grid\cols()\buttonid = *imageID
  *grid\redraw = 1
  
  If *grid\cols()\wh = 0
    *grid\cols()\wh = *grid\default_col_width
  EndIf
EndProcedure
Procedure grid_SetColumnCaption(*grid.Grid_Struct, index, caption.s)
  Protected col.s
  
  col.s = Str(*grid\col(index))
  If Not FindMapElement(*grid\cols(),col)
    AddMapElement(*grid\cols(),col)
  EndIf
  
  *grid\cols()\caption = caption
  
  StartDrawing(ImageOutput(*grid\tempimg))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(*grid\font))
  
  *grid\cols()\wtext = TextWidth(caption)
  StopDrawing()
  
  If *grid\cols()\wh = 0
    *grid\cols()\wh = *grid\default_col_width
  EndIf
  
  *grid\redraw = #True
EndProcedure
Procedure grid_SetColumnData(*grid.Grid_Struct, index, g_data.i)
  Protected col.s
  
  col.s = Str(*grid\col(index))
  If Not FindMapElement(*grid\cols(),col)
    AddMapElement(*grid\cols(),col)
  EndIf
  
  *grid\cols()\g_data = g_data
  
  If *grid\cols()\wh = 0
    *grid\cols()\wh = *grid\default_col_width
  EndIf
  
EndProcedure

Procedure grid_GetColumnData(*grid.Grid_Struct, index)
  Protected caption.s, g_data
  
  If FindMapElement(*grid\cols(), Str(*grid\col(index)))
    g_data = *grid\cols()\g_data
  Else
    g_data = 0
  EndIf
  
  ProcedureReturn g_data
EndProcedure
Procedure.s grid_GetColumnCaption(*grid.Grid_Struct, index)
  Protected caption.s
  
  If FindMapElement(*grid\cols(), Str(*grid\col(index)))
    caption.s = *grid\cols()\caption
  Else
    caption.s = grid_NumberToLetter(index)
  EndIf
  
  ProcedureReturn caption
EndProcedure

Procedure grid_SetColumnWidth(*grid.Grid_Struct, index, width = -1, padding = 0)
  Protected col.s, i, cell_width, caption.s
  
  col.s = Str(*grid\col(index))
  If Not FindMapElement(*grid\cols(),col)
    AddMapElement(*grid\cols(),col)
  EndIf
  
  If width = -1
    StartDrawing(ImageOutput(*grid\tempimg))
    DrawingFont(FontID(*grid\font))
    
    If *grid\cols()\caption <> ""
      caption.s = *grid\cols()\caption
    Else
      caption.s = grid_NumberToLetter(index)
    EndIf
    width = TextWidth(caption)
    
    If *grid\cols()\buttonid
      width + 17*2
    EndIf
    
    For i = 0 To *grid\maxnumrows - 1
      cell_width = grid_GetCellTextWidth(*grid.Grid_Struct, index, i)
      
      If FindMapElement(*grid\cells(),Str(*grid\col(index))+"x"+Str(*grid\row(i)))
        If *grid\cells()\type = #Grid_Cell_Combobox Or *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget
          cell_width + 22
        EndIf
      EndIf
      
      If cell_width > width
        width  = cell_width
      EndIf
    Next
    
    If width >= *grid\innerwidth - 2
      width = *grid\innerwidth - 2
    EndIf
    
    width + padding
    
    StopDrawing()
  EndIf
  
  *grid\cols()\wh = width
  *grid\redraw = #True
EndProcedure

Procedure grid_GetColumnWidth(*grid.Grid_Struct, index)
  Protected col.s, width
  
  col.s = Str(*grid\col(index))
  
  If FindMapElement(*grid\cols(), col)
    width = *grid\cols()\wh
  Else
    width = *grid\default_col_width
  EndIf
  
  ProcedureReturn width
EndProcedure
Procedure grid_SetRowCaption(*grid.Grid_Struct, index, caption.s)
  Protected row.s
  
  row.s = Str(*grid\row(index))
  If Not FindMapElement(*grid\rows(),row)
    AddMapElement(*grid\rows(),row)
  EndIf
  
  *grid\rows()\caption = caption
  
  StartDrawing(ImageOutput(*grid\tempimg))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  DrawingFont(FontID(*grid\font))
  
  *grid\rows()\wtext = TextWidth(caption)
  StopDrawing()
  
  If *grid\rows()\wh = 0
    *grid\rows()\wh = *grid\default_row_height
  EndIf
  
  *grid\redraw = #True
EndProcedure
Procedure grid_SetRowData(*grid.Grid_Struct, index, g_data)
  Protected row.s
  
  row.s = Str(*grid\row(index))
  If Not FindMapElement(*grid\rows(),row)
    AddMapElement(*grid\rows(),row)
  EndIf
  
  *grid\rows()\g_data = g_data
  
  If *grid\rows()\wh = 0
    *grid\rows()\wh = *grid\default_row_height
  EndIf
  
EndProcedure
Procedure grid_GetRowData(*grid.Grid_Struct, index)
  Protected caption.s, g_data
  
  If FindMapElement(*grid\rows(), Str(*grid\row(index)))
    g_data = *grid\rows()\g_data
  Else
    g_data = 0
  EndIf
  
  ProcedureReturn g_data
EndProcedure
Procedure.s grid_GetRowCaption(*grid.Grid_Struct, index)
  Protected caption.s
  
  If FindMapElement(*grid\rows(), Str(*grid\row(index)))
    caption.s = *grid\rows()\caption
  Else
    caption.s = Str(index+1)
  EndIf
  
  ProcedureReturn caption
EndProcedure
Procedure grid_SetRowHeight(*grid.Grid_Struct, index, height)
  Protected row.s
  
  row.s = Str(*grid\row(index))
  If Not FindMapElement(*grid\rows(),row)
    AddMapElement(*grid\rows(),row)
  EndIf
  
  *grid\rows()\wh = height
  
  *grid\redraw = #True
EndProcedure
Procedure grid_GetRowHeight(*grid.Grid_Struct, index)
  Protected row.s, height
  
  row.s = Str(*grid\row(index))
  If FindMapElement(*grid\rows(), row)
    height = *grid\rows()\wh
  Else
    height = *grid\default_row_height
  EndIf
  
  ProcedureReturn height
EndProcedure

Procedure grid_HideRow(*grid.Grid_Struct, index, hide.b)
  Protected row.s
  
  row.s = Str(*grid\row(index))
  If Not FindMapElement(*grid\rows(),row)
    AddMapElement(*grid\rows(),row)
  EndIf
  
  *grid\rows()\visible = hide
  
  If *grid\rows()\wh = 0
    *grid\rows()\wh = *grid\default_row_height
  EndIf
  
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
  
EndProcedure



Procedure grid_SetCellData(*grid.Grid_Struct, col_index, row_index, value)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
    
    ClearList(*grid\cells()\style())
    AddElement(*grid\cells()\style())
    *grid\cells()\style()\color = *grid\dfontcolor
    *grid\cells()\style()\fontname = *grid\dfont
    *grid\cells()\style()\fontsize = *grid\dfontsize
    *grid\cells()\style()\style_end = 0
  EndIf
  
  *grid\cells()\c_data = value
  
  If col_index >= *grid\numcols
    *grid\numcols = col_index + 1
  EndIf
  
  If row_index >= *grid\numrows
    *grid\numrows = row_index + 1
  EndIf
EndProcedure

Procedure grid_GetCellData(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, c_data.i
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If FindMapElement(*grid\cells(),cell)
    c_data =  *grid\cells()\c_data
  EndIf
  
  ProcedureReturn c_data
EndProcedure

Procedure grid_SetCellString(*grid.Grid_Struct, col_index, row_index, value.s)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  ClearList(*grid\cells()\style())
  AddElement(*grid\cells()\style())
  *grid\cells()\style()\color = *grid\dfontcolor
  *grid\cells()\style()\fontname = *grid\dfont
  *grid\cells()\style()\fontsize = *grid\dfontsize
  *grid\cells()\style()\style_end = Len(value)
  
  *grid\cells()\content = value
  
  If col_index >= *grid\numcols
    *grid\numcols = col_index + 1
  EndIf
  
  If row_index >= *grid\numrows
    *grid\numrows = row_index + 1
  EndIf
  
  *grid\redraw = #True
EndProcedure

Procedure.s grid_GetCellString(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, content.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If FindMapElement(*grid\cells(),cell)
    content.s = *grid\cells()\content
  EndIf
  
  ProcedureReturn content
EndProcedure

Procedure grid_SetCellBackColor(*grid.Grid_Struct, col_index, row_index, backcolor)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
  EndIf
  
  *grid\cells()\backColor = backcolor
  *grid\cells()\backColorSet = #True
EndProcedure

Procedure.l grid_GetCellBackColor(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, color
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If FindMapElement(*grid\cells(),cell)
    color = *grid\cells()\backColor
  Else
    color = *grid\color_background
  EndIf
  
  ProcedureReturn color
EndProcedure

Procedure grid_SetCellAlign(*grid.Grid_Struct, col_index, row_index, align.b)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  *grid\cells()\halign = align
EndProcedure

Procedure grid_SetCellVerticalAlign(*grid.Grid_Struct, col_index, row_index, align.b)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  *grid\cells()\valign = align
EndProcedure

Procedure grid_CellIdentRight(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  *grid\cells()\ident + 10
EndProcedure

Procedure grid_CellIdentLeft(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  *grid\cells()\ident - 10
  
  If *grid\cells()\ident < 0
    *grid\cells()\ident = 0
  EndIf
EndProcedure

Procedure grid_SetCellType(*grid.Grid_Struct, col_index, row_index, type)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  ClearList(*grid\cells()\style())
  AddElement(*grid\cells()\style())
  *grid\cells()\style()\color = *grid\dfontcolor
  *grid\cells()\style()\fontname = *grid\dfont
  *grid\cells()\style()\fontsize = *grid\dfontsize
  *grid\cells()\style()\style_end = 0
  
  *grid\cells()\type = type
  *grid\cells()\state = 0
  *grid\cells()\content = ""
  
  If col_index >= *grid\numcols
    *grid\numcols = col_index + 1
  EndIf
  
  If row_index >= *grid\numrows
    *grid\numrows = row_index + 1
  EndIf
  
  *grid\redraw = #True
EndProcedure

Procedure grid_SetCellState(*grid.Grid_Struct, col_index, row_index, state.i)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  *grid\cells()\state = state
  *grid\redraw = #True
  
EndProcedure

Procedure grid_GetCellType(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, value.i
  
  If col_index > -1 And row_index > -1
    cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
    
    If FindMapElement(*grid\cells(),cell)
      value = *grid\cells()\type
    EndIf
  EndIf
  
  ProcedureReturn value
EndProcedure
Procedure grid_GetCellState(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, value.i
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If FindMapElement(*grid\cells(),cell)
    value = *grid\cells()\state
  EndIf
  
  ProcedureReturn value
EndProcedure

Procedure grid_SetColumnType(*grid.Grid_Struct, index, type)
  Protected col.s, i, cell_width
  
  col.s = Str(*grid\col(index))
  If Not FindMapElement(*grid\cols(),col)
    AddMapElement(*grid\cols(),col)
  EndIf
  
  *grid\cols()\type = type
  
  For i = 0 To *grid\maxnumrows
    grid_SetCellType(*grid,index,i,type)
  Next
  
  If *grid\cols()\wh = 0
    *grid\cols()\wh = *grid\default_col_width
  EndIf
EndProcedure

Procedure grid_GetColumnType(*grid.Grid_Struct, index)
  Protected caption.s, g_data
  
  If FindMapElement(*grid\cols(), Str(*grid\col(index)))
    g_data = *grid\cols()\type
  Else
    g_data = 0
  EndIf
  
  ProcedureReturn g_data
EndProcedure


Procedure grid_CreateComboBox(*grid.Grid_Struct)
  Protected value.i
  
  AddElement(*grid\combolists())
  value = *grid\combolists()
  
  ProcedureReturn value
EndProcedure

Procedure grid_AddComboBoxItem(*grid.Grid_Struct, *combo, index, value.s)
  Protected max
  
  ChangeCurrentElement( *grid\combolists(), *combo)
  
  max = ListSize(*grid\combolists()\values()) - 1
  
  If index >= 0 And index < max
    SelectElement(*grid\combolists()\values(),index)
    InsertElement(*grid\combolists()\values())
  ElseIf index = -1 Or index >= max
    LastElement(*grid\combolists()\values())
    AddElement(*grid\combolists()\values())
  EndIf
  
  *grid\combolists()\values()\value = value
EndProcedure

Procedure grid_RemoveComboBoxItem(*grid.Grid_Struct, *combo, index)
  ChangeCurrentElement( *grid\combolists(), *combo)
  
  SelectElement(*grid\combolists()\values(),index)
  DeleteElement(  *grid\combolists()\values())
EndProcedure

Procedure grid_ClearComboBoxItems(*grid.Grid_Struct, *combo)
  ChangeCurrentElement( *grid\combolists(), *combo)
  
  ClearList(*grid\combolists()\values())
EndProcedure

Procedure grid_SetComboBoxItemData(*grid.Grid_Struct, *combo, index, value)
  ChangeCurrentElement(*grid\combolists(), *combo)
  
  SelectElement(*grid\combolists()\values(),index)
  
  *grid\combolists()\values()\c_data = value
EndProcedure

Procedure grid_SetCellLockState(*grid.Grid_Struct, col_index, row_index, locked.b)
  Protected cell.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If Not FindMapElement(*grid\cells(),cell)
    AddMapElement(*grid\cells(),cell)
    *grid\cells()\backColor = *grid\color_background
  EndIf
  
  *grid\cells()\locked = locked
EndProcedure

Procedure.b grid_GetCellLockState(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, locked.b
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  locked.b = #False
  
  If FindMapElement(*grid\cells(),cell)
    locked = *grid\cells()\locked
  EndIf
  
  ProcedureReturn locked
EndProcedure
Procedure.s grid_GetCellCursorSelection(*grid.Grid_Struct)
  Protected text.s, sel_start, sel_end
  
  text.s = ""
  
  If *grid\edit_row > -1 And *grid\edit_col > -1
    If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
      sel_start = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
      sel_end = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
      
      text = Mid(*grid\cells()\content,sel_start + 1, sel_end - sel_start)
    EndIf
  EndIf
  
  ProcedureReturn text
EndProcedure

Procedure grid_CopyCellCursorSelection(*grid.Grid_Struct)
  Protected text.s, sel_start, sel_end
  
  text.s = ""
  
  If *grid\edit_row > -1 And *grid\edit_col > -1
    If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
      sel_start = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
      sel_end = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
      
      text = Mid(*grid\cells()\content,sel_start + 1, sel_end - sel_start)
      SetClipboardText(text)
    EndIf
  EndIf
EndProcedure

Procedure grid_CutCellCursorSelection(*grid.Grid_Struct)
  Protected text.s, sel_start, sel_end, content.s, min, max, cell.s, oldend
  
  text.s = ""
  
  If *grid\edit_row > -1 And *grid\edit_col > -1
    If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
      sel_start = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
      sel_end = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
      
      text = Mid(*grid\cells()\content,sel_start + 1, sel_end - sel_start)
      
      content.s = *grid\cells()\content
      content = Left(content, grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)) + Right(content, Len(content) - grid_Max(*grid\edit_sel_start, *grid\edit_sel_end))
      
      min = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
      max = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
      
      *grid\cells()\content = content
      
      ForEach *grid\cells()\style()
        If *grid\cells()\style()\style_end >= min And *grid\cells()\style()\style_end <= max
          *grid\cells()\style()\style_end = min
        ElseIf *grid\cells()\style()\style_end >= max
          *grid\cells()\style()\style_end = *grid\cells()\style()\style_end - (max - min)
        EndIf
      Next
      
      oldend = -1
      ForEach *grid\cells()\style()
        If *grid\cells()\style()\style_end = oldend
          oldend = *grid\cells()\style()\style_end
          DeleteElement(*grid\cells()\style())
        Else
          oldend = *grid\cells()\style()\style_end
        EndIf
      Next
      
      *grid\edit_pos = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
      *grid\edit_sel_end = 0
      *grid\edit_sel_start = 0
      *grid\edit_selecting = #False
      *grid\redraw = #True
      SetClipboardText(text)
    EndIf
  EndIf
EndProcedure

Procedure grid_PasteCellCursorSelection(*grid.Grid_Struct)
  Protected cell.s, text.s, content.s, min, max, oldend
  
  If *grid\edit_row > -1 And *grid\edit_col > -1
    cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
    text.s = GetClipboardText()
    
    If FindMapElement(*grid\cells(), cell)
      ; Delete selection
      If *grid\edit_selecting
        content.s = *grid\cells()\content
        content.s = Left(content, grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)) + Right(content, Len(content) - grid_Max(*grid\edit_sel_start, *grid\edit_sel_end))
        
        min = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
        max = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
        
        *grid\cells()\content = content
        
        ForEach *grid\cells()\style()
          If *grid\cells()\style()\style_end >= min And *grid\cells()\style()\style_end <= max
            *grid\cells()\style()\style_end = min
          ElseIf *grid\cells()\style()\style_end >= max
            *grid\cells()\style()\style_end = *grid\cells()\style()\style_end - (max - min)
          EndIf
        Next
        
        oldend = -1
        ForEach *grid\cells()\style()
          If *grid\cells()\style()\style_end = oldend
            oldend = *grid\cells()\style()\style_end
            DeleteElement(*grid\cells()\style())
          Else
            oldend = *grid\cells()\style()\style_end
          EndIf
        Next
        
        *grid\edit_pos = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
        *grid\edit_sel_end = 0
        *grid\edit_sel_start = 0
        *grid\edit_selecting = #False
      EndIf
      
      ; Paste
      *grid\cells()\content = Left(*grid\cells()\content,*grid\edit_pos) + text + Right(*grid\cells()\content,Len(*grid\cells()\content)-*grid\edit_pos)
      
      ForEach *grid\cells()\style()
        If *grid\cells()\style()\style_end >= *grid\edit_pos
          *grid\cells()\style()\style_end + Len(text)
        EndIf
      Next
      
      *grid\edit_pos + Len(text)
      
      *grid\redraw = #True
    Else
      AddMapElement(*grid\cells(),cell)
      *grid\cells()\content = text
      *grid\edit_pos + Len(text)
      *grid\cells()\backColor = *grid\color_background
      *grid\redraw = #True
      
      ClearList(*grid\cells()\style())
      AddElement(*grid\cells()\style())
      *grid\cells()\style()\color = *grid\dfontcolor
      *grid\cells()\style()\fontname = *grid\dfont
      *grid\cells()\style()\fontsize = *grid\dfontsize
      *grid\cells()\style()\style_end = *grid\edit_pos
    EndIf
    
  EndIf
EndProcedure

Procedure grid_CopySelection(*grid.Grid_Struct)
  Protected clipboard.s, row_start, row_end, col_end, col_start, cell.s, i, j
  
  LastElement(*grid\sel())
  
  clipboard.s
  
  row_start = grid_Min(*grid\sel()\sel_row,*grid\sel()\sel_row_end)
  row_end = grid_Max(*grid\sel()\sel_row,*grid\sel()\sel_row_end)
  
  col_start = grid_Min(*grid\sel()\sel_col,*grid\sel()\sel_col_end)
  col_end = grid_Max(*grid\sel()\sel_col,*grid\sel()\sel_col_end)
  
  For i = row_start To row_end
    For j = col_start To col_end
      cell.s = Str(*grid\col(j))+"x"+Str(*grid\row(i))
      
      If FindMapElement(*grid\cells(),cell)
        clipboard + *grid\cells()\content
      EndIf
      
      If j <> col_end
        clipboard + Chr(9)
      EndIf
    Next
    
    If i <> row_end
      clipboard + Chr(13) + Chr(10)
    EndIf
  Next
  
  SetClipboardText(clipboard)
  
EndProcedure

Procedure grid_PasteToSelection(*grid.Grid_Struct)
  Protected clipboard.s, ty, tpos, clip_line.s, tx
  
  clipboard.s = GetClipboardText()
  
  LastElement(*grid\sel())
  
  ty = 0
  While Len(clipboard) > 0
    tpos = FindString(clipboard, Chr(13)+Chr(10), 1)
    If tpos > 0
      clip_line.s = Left(clipboard,tpos-1)
      clipboard = Right(clipboard,Len(clipboard)-tpos-1)
    Else
      clip_line.s = clipboard
      clipboard = ""
    EndIf
    
    tx = 0
    While Len(clip_line) > 0
      tpos = FindString(clip_line,Chr(9),1)
      If tpos > 0
        grid_SetCellString( *grid, *grid\sel()\sel_col + tx,*grid\sel()\sel_row + ty,Left(clip_line,tpos-1))
        clip_line = Right(clip_line,Len(clip_line)-tpos)
        tx + 1
      Else
        grid_SetCellString( *grid, *grid\sel()\sel_col + tx,*grid\sel()\sel_row + ty,clip_line)
        clip_line = ""
      EndIf
    Wend
    ty + 1
  Wend
EndProcedure

Procedure.s grid_GetCursorStyleFontName(*grid.Grid_Struct, cursor = -1, col_index = -1, row_index = -1)
  Protected cell.s, pos, fontname.s
  
  If col_index = -1 And row_index = -1
    cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
  Else
    cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(col_index))
  EndIf
  
  If cursor = -1
    cursor = *grid\edit_pos
  EndIf
  
  If FindMapElement(*grid\cells(), cell)
    pos = 0
    ForEach *grid\cells()\style()
      If (cursor > pos And cursor <= *grid\cells()\style()\style_end) Or cursor = 0
        fontname = *grid\cells()\style()\fontname
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn fontname
EndProcedure

Procedure grid_GetCursorStyleFontSize(*grid.Grid_Struct, cursor = -1, col_index = -1, row_index = -1)
  Protected cell.s, pos, fontsize
  
  If col_index = -1 And row_index = -1
    cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
  Else
    cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(col_index))
  EndIf
  
  If cursor = -1
    cursor = *grid\edit_pos
  EndIf
  
  If FindMapElement(*grid\cells(), cell)
    pos = 0
    ForEach *grid\cells()\style()
      If (cursor > pos And cursor <= *grid\cells()\style()\style_end) Or cursor = 0
        fontsize = *grid\cells()\style()\fontsize
      EndIf
    Next
  EndIf
  
  ProcedureReturn fontsize
EndProcedure

Procedure grid_GetCursorStyleColor(*grid.Grid_Struct, cursor = -1, col_index = -1, row_index = -1)
  Protected cell.s, pos, color.i
  
  If col_index = -1 And row_index = -1
    cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
  Else
    cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(col_index))
  EndIf
  
  If cursor = -1
    cursor = *grid\edit_pos
  EndIf
  
  If FindMapElement(*grid\cells(), cell)
    pos = 0
    ForEach *grid\cells()\style()
      If (cursor > pos And cursor <= *grid\cells()\style()\style_end) Or cursor = 0
        color = *grid\cells()\style()\color
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn color
EndProcedure

Procedure grid_GetCursorStyleFontFlags(*grid.Grid_Struct, cursor = -1, col_index = -1, row_index = -1)
  Protected cell.s, pos, flags
  
  If col_index = -1 And row_index = -1
    cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
  Else
    cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(col_index))
  EndIf
  
  If cursor = -1
    cursor = *grid\edit_pos
  EndIf
  
  If FindMapElement(*grid\cells(), cell)
    pos = 0
    ForEach *grid\cells()\style()
      If (cursor > pos And cursor <= *grid\cells()\style()\style_end) Or cursor = 0
        flags = *grid\cells()\style()\fontflags
        Break
      EndIf
    Next
  EndIf
  
  ProcedureReturn flags
EndProcedure

Procedure grid_SetSelectionStyle(*grid.Grid_Struct,col_index ,row_index ,fontname.s = "", fontsize = -1, bold.b = -1, italic.b = -1, underline.b = -1, strikethrough = -1, color = -1,s_start = -1,s_end = -1)
  Protected cell.s, selecting, realselend, realselstart, selstart, selend, add_start.b, add_end.b, old_color, old_end, old_flags, old_fontname.s, old_fontsize, fontkey.s
  
  If col_index = -1
    col_index = *grid\edit_col
  EndIf
  If row_index = -1
    row_index = *grid\edit_row
  EndIf
  
  If col_index = -1 Or row_index = -1
    ProcedureReturn
  EndIf
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  If FindMapElement(*grid\cells(),cell)
    If s_start > -1 And s_end > -1
      selecting = #True
      
      realselstart = grid_Min(s_start,s_end)
      realselend = grid_Max(s_start,s_end)
    EndIf
    
    
    If *grid\edit_selecting Or selecting
      If Not selecting
        realselstart = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
        realselend = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
      EndIf
      
      selstart = realselstart
      selend = realselend
      
      add_start.b = #True
      add_end.b = #True
      ForEach *grid\cells()\style()
        If selstart = *grid\cells()\style()\style_end
          add_start = #False
        EndIf
        If selend = *grid\cells()\style()\style_end
          add_end = #False
        EndIf
      Next
      
      If selstart = 0
        add_start = #False
      EndIf
      
      If selend = Len(*grid\cells()\content)
        add_end = #False
      EndIf
      
      If add_start
        ForEach *grid\cells()\style()
          If selstart < *grid\cells()\style()\style_end
            old_end = *grid\cells()\style()\style_end
            old_flags = *grid\cells()\style()\fontflags
            old_color = *grid\cells()\style()\color
            old_fontname.s = *grid\cells()\style()\fontname
            old_fontsize = *grid\cells()\style()\fontsize
            
            AddElement(*grid\cells()\style())
            *grid\cells()\style()\color = old_color
            *grid\cells()\style()\fontname = old_fontname
            *grid\cells()\style()\fontsize = old_fontsize
            *grid\cells()\style()\style_end = selstart
            *grid\cells()\style()\fontflags = old_flags
            
            Break
          EndIf
        Next
      EndIf
      If add_end
        ForEach *grid\cells()\style()
          If selend < *grid\cells()\style()\style_end
            old_end = *grid\cells()\style()\style_end
            old_flags = *grid\cells()\style()\fontflags
            old_color = *grid\cells()\style()\color
            old_fontname.s = *grid\cells()\style()\fontname
            old_fontsize = *grid\cells()\style()\fontsize
            
            AddElement(*grid\cells()\style())
            
            *grid\cells()\style()\color = old_color
            *grid\cells()\style()\fontname = old_fontname
            *grid\cells()\style()\fontsize = old_fontsize
            *grid\cells()\style()\style_end = selend
            *grid\cells()\style()\fontflags = old_flags
            Break
          EndIf
        Next
      EndIf
      
      ForEach *grid\cells()\style()
        If *grid\cells()\style()\style_end > selstart And *grid\cells()\style()\style_end <= selend
          If color <> -1
            *grid\cells()\style()\color = color
          EndIf
          If fontname <> ""
            *grid\cells()\style()\fontname = fontname
          EndIf
          If fontsize <> - 1
            *grid\cells()\style()\fontsize = fontsize
          EndIf
          
          If bold = 1 And Not *grid\cells()\style()\fontflags & #PB_Font_Bold
            *grid\cells()\style()\fontflags | #PB_Font_Bold
          ElseIf bold = 0 And *grid\cells()\style()\fontflags & #PB_Font_Bold
            *grid\cells()\style()\fontflags - #PB_Font_Bold
          EndIf
          
          If italic = 1 And Not *grid\cells()\style()\fontflags & #PB_Font_Italic
            *grid\cells()\style()\fontflags | #PB_Font_Italic
          ElseIf italic = 0 And *grid\cells()\style()\fontflags & #PB_Font_Italic
            *grid\cells()\style()\fontflags - #PB_Font_Italic
          EndIf
          
          If underline = 1 And Not *grid\cells()\style()\fontflags & #PB_Font_Underline
            *grid\cells()\style()\fontflags | #PB_Font_Underline
          ElseIf underline = 0 And *grid\cells()\style()\fontflags & #PB_Font_Underline
            *grid\cells()\style()\fontflags - #PB_Font_Underline
          EndIf
          
          If strikethrough = 1 And Not *grid\cells()\style()\fontflags & #Grid_TextEdit_Font_Strikethrough
            *grid\cells()\style()\fontflags | #Grid_TextEdit_Font_Strikethrough
          ElseIf strikethrough = 0 And *grid\cells()\style()\fontflags & #Grid_TextEdit_Font_Strikethrough
            *grid\cells()\style()\fontflags - #Grid_TextEdit_Font_Strikethrough
          EndIf
          
          fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
          
          If *grid\cells()\style()\fontflags & #PB_Font_Bold
            fontkey + "B"
          EndIf
          If *grid\cells()\style()\fontflags & #PB_Font_Italic
            fontkey + "I"
          EndIf
          
          If Not FindMapElement(grids_fonts(),fontkey)
            AddMapElement(grids_fonts(),fontkey)
            grids_fonts()\fontname = *grid\cells()\style()\fontname
            grids_fonts()\fontsize = *grid\cells()\style()\fontsize
            
            If *grid\cells()\style()\fontflags & #PB_Font_Bold
              grids_fonts()\fontflags | #PB_Font_Bold
            EndIf
            If *grid\cells()\style()\fontflags & #PB_Font_Italic
              grids_fonts()\fontflags | #PB_Font_Italic
            EndIf
            
            grids_fonts()\hfont = LoadFont(#PB_Any,grids_fonts()\fontname,grids_fonts()\fontsize, grids_fonts()\fontflags)
          EndIf
          
        EndIf
      Next
      
      SortStructuredList(*grid\cells()\style(),#PB_Sort_Ascending,OffsetOf(GridCellStyle\style_end),#PB_Long)
      
      
    Else
      ; we add a temp style, which will be deleted on an cursor position change
      If *grid\tstyle = #False
        ; let's retrieve the previous style
        
        *grid\tfont = grid_GetCursorStyleFontName(*grid, -1, col_index, row_index)
        *grid\tfontsize = grid_GetCursorStyleFontSize(*grid, col_index, row_index)
        *grid\tfontflags = grid_GetCursorStyleFontFlags(*grid, col_index, row_index)
        *grid\tfontcolor = grid_GetCursorStyleColor(*grid, col_index, row_index)
      EndIf
      
      *grid\tstyle = #True
      
      If color <> -1
        *grid\tfontcolor = color
      EndIf
      
      If fontname <> ""
        *grid\tfont = fontname
      EndIf
      
      If fontsize <> - 1
        *grid\tfontsize = fontsize
      EndIf
      
      If bold = 1 And Not *grid\tfontflags & #PB_Font_Bold
        *grid\tfontflags | #PB_Font_Bold
      ElseIf bold = 0 And *grid\tfontflags & #PB_Font_Bold
        *grid\tfontflags - #PB_Font_Bold
      EndIf
      
      If italic = 1 And Not *grid\tfontflags & #PB_Font_Italic
        *grid\tfontflags | #PB_Font_Italic
      ElseIf italic = 0 And *grid\tfontflags & #PB_Font_Italic
        *grid\tfontflags - #PB_Font_Italic
      EndIf
      
      If underline = 1 And Not *grid\tfontflags & #PB_Font_Underline
        *grid\tfontflags | #PB_Font_Underline
      ElseIf underline = 0 And *grid\tfontflags & #PB_Font_Underline
        *grid\tfontflags - #PB_Font_Underline
      EndIf
      
      If strikethrough = 1 And Not *grid\tfontflags & #Grid_TextEdit_Font_Strikethrough
        *grid\tfontflags | #Grid_TextEdit_Font_Strikethrough
      ElseIf strikethrough = 0 And *grid\tfontflags & #Grid_TextEdit_Font_Strikethrough
        *grid\tfontflags - #Grid_TextEdit_Font_Strikethrough
      EndIf
    EndIf
  EndIf
  
  *grid\redraw = #True
EndProcedure

Procedure grid_InsertRow(*grid.Grid_Struct,index)
  Protected endloop, i, col.s
  
  If index = -1
    index = *grid\maxnumrows
  EndIf
  
  DisableDebugger
  *grid\maxnumrows + 1
  *grid\row_index + 1
  
  endloop = index + 1
  For i = *grid\maxnumrows To endloop Step - 1
    *grid\row(i) = *grid\row(i - 1)
  Next
  
  *grid\row(index) = *grid\row_index
  EnableDebugger
  
  
  For i = 0 To *grid\maxnumcols
    col.s = Str(*grid\col(i))
    If FindMapElement(*grid\cols(),col)
      If *grid\cols()\type > 0
        grid_SetCellType(*grid,i,index,*grid\cols()\type)
      EndIf
      
    EndIf
    
  Next
  
  
  *grid\ numrows + 1
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
EndProcedure

Procedure grid_InsertColumn(*grid.Grid_Struct,index, caption.s = "", width = -1)
  Protected endloop, i
  
  If index = -1
    index = *grid\maxnumcols
  EndIf
  
  DisableDebugger
  *grid\maxnumcols + 1
  *grid\col_index + 1
  
  endloop = index + 1
  For i = *grid\maxnumcols To endloop Step - 1
    *grid\col(i) = *grid\col(i - 1)
  Next
  
  *grid\col(index) = *grid\col_index
  EnableDebugger
  
  If caption <> ""
    grid_SetColumnCaption(*grid,index,caption)
  EndIf
  
  If width > -1
    grid_SetColumnWidth(*grid,index, width)
  EndIf
  
  *grid\numcols + 1
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
EndProcedure

Procedure grid_DeleteColumn(*grid.Grid_Struct,index)
  Protected maxcolminus.b, i, cell.s, col.s, endloop
  
  ; delete the cells in this column
  maxcolminus.b = #False
  For i = 0 To *grid\maxnumrows
    cell.s = Str(*grid\col(index))+"x"+Str(*grid\row(i))
    If FindMapElement(*grid\cells(),cell)
      If *grid\cells()\content <> ""
        maxcolminus = #True
      EndIf
      
      DeleteMapElement(*grid\cells())
    EndIf
  Next
  
  ; delete the column attributes
  col.s = Str(*grid\col(index))
  If FindMapElement(*grid\cols(),col)
    DeleteMapElement(*grid\cols())
  EndIf
  
  ; remove the index from the index list
  endloop = *grid\maxnumcols - 1
  For i = index To endloop
    *grid\col(i) = *grid\col(i + 1)
  Next
  
  If maxcolminus
    *grid\ numcols - 1
  EndIf
  
  *grid\maxnumcols - 1
  
  If *grid\xscroll > *grid\maxnumcols
    *grid\xscroll = *grid\maxnumcols
  EndIf
  
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
EndProcedure

Procedure grid_DeleteRow(*grid.Grid_Struct,index)
  Protected maxcolminus.b, cell.s, i, col.s, endloop
  
  ; delete the cells in this column
  maxcolminus.b = #False
  For i = 0 To *grid\maxnumcols
    cell.s = Str(*grid\col(i))+"x"+Str(*grid\row(index))
    If FindMapElement(*grid\cells(),cell)
      If *grid\cells()\content <> ""
        maxcolminus = #True
      EndIf
      
      DeleteMapElement(*grid\cells())
    EndIf
  Next
  
  ; delete the row attributes
  col.s = Str(*grid\row(index))
  If FindMapElement(*grid\rows(),col)
    DeleteMapElement(*grid\rows())
  EndIf
  
  ; remove the index from the index list
  endloop = *grid\maxnumrows - 1
  For i = index To endloop
    *grid\row(i) = *grid\row(i + 1)
  Next
  
  If maxcolminus
    *grid\ numrows - 1
  EndIf
  
  *grid\maxnumrows - 1
  
  If *grid\yscroll > *grid\maxnumrows
    *grid\yscroll = *grid\maxnumrows
  EndIf
  
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
EndProcedure

Procedure grid_DeleteAllColumns(*grid.Grid_Struct)
  Protected maxcolminus.b, i, cell.s, col.s, endloop
  
  ; delete all cells
  ClearMap(*grid\cells())
  
  ; delete all column attributes
  ClearMap(*grid\cols())
  
  ; remove indexes from index list
  endloop = *grid\maxnumcols - 1
  For i = 0 To endloop
    *grid\col(i) = i
  Next
  
  *grid\numcols = 0
  *grid\maxnumcols = 0
  *grid\xscroll = 0
  
  ; Reset selection
  ClearList(*grid\sel())
  AddElement(*grid\sel())
  
  *grid\sel()\sel_col = 0
  *grid\sel()\sel_col_end = 0
  *grid\sel()\sel_row = 0
  *grid\sel()\sel_row_end = 0
  
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
EndProcedure

Procedure grid_DeleteAllRows(*grid.Grid_Struct)
  Protected maxcolminus.b, cell.s, i, col.s, endloop
  
  ; delete all cells
  ClearMap(*grid\cells())
  
  ; delete all column attributes
  ClearMap(*grid\rows())
  
  ; remove the index from the index list
  endloop = *grid\maxnumrows - 1
  For i = 0 To endloop
    *grid\row(i) = i
  Next
  
  *grid\numrows = 0
  *grid\maxnumrows = 0
  *grid\yscroll = 0
  
  ; Reset selection
  ClearList(*grid\sel())
  AddElement(*grid\sel())
  
  *grid\sel()\sel_col = 0
  *grid\sel()\sel_col_end = 0
  *grid\sel()\sel_row = 0
  *grid\sel()\sel_row_end = 0
  
  *grid\redraw = #True
  grid_BuildScrollbarSize(*grid)
EndProcedure

Procedure.s grid_GetCurrentCellCombo(*grid.Grid_Struct,x,y)
  Protected drawing_x, drawing_x2, drawing_y, drawing_y2, current_row, current_row_map.s, current_column, current_column_map.s, indexed_current_column, indexed_current_row
  drawing_x = 0
  drawing_y = 0
  
  If x < *grid\header_row_width And y < (*grid\header_col_height+1) And Not *grid\header_col_hidden
    ProcedureReturn "-1x-1"
  EndIf
  
  current_row = *grid\yscroll
  drawing_y = 0
  While drawing_y < *grid\innerheight
    If current_row < *grid\maxnumrows
      
      indexed_current_row = *grid\row(current_row)
      
      ; Draw the rows captions
      current_row_map.s = Str(indexed_current_row)
      If drawing_y < *grid\header_col_height+1 And Not *grid\header_col_hidden
        drawing_y2 = *grid\header_col_height+1
      Else
        If FindMapElement(*grid\rows(), current_row_map)
          If *grid\rows()\visible ; don't draw
            current_row + 1
            Continue
          EndIf
          drawing_y2 = drawing_y + *grid\rows()\wh + 1
        Else
          drawing_y2 = drawing_y + *grid\default_row_height + 1
        EndIf
      EndIf
      
      ; Draw the cells
      drawing_x = 0
      current_column = *grid\xscroll
      
      If x <= (*grid\header_row_width + 1) And y >= drawing_y And y <= drawing_y2
        ProcedureReturn "-1x-1"
      EndIf
      
      drawing_x = *grid\header_row_width + 1
      While drawing_x < *grid\innerwidth
        If current_column < *grid\maxnumcols
          
          indexed_current_column = *grid\col(current_column)
          current_column_map.s = Str(indexed_current_column)+"x"+Str(indexed_current_row)
          
          If FindMapElement(*grid\cols(), Str(indexed_current_column))
            drawing_x2 = drawing_x + *grid\cols()\wh + 1
          Else
            drawing_x2 = drawing_x + *grid\default_col_width + 1
          EndIf
          
          If y <= (*grid\header_col_height + 1) And Not *grid\header_col_hidden
            If x >= drawing_x And x =< drawing_x2
              ProcedureReturn "-1x-1"
            EndIf
          Else
            If x >= (drawing_x2 - 23) And x =< drawing_x2 And y >= drawing_y And y <= drawing_y2
              ProcedureReturn Str(current_column)+ "x"+Str(current_row)+ "x" + Str(drawing_x) + "x" + Str(drawing_y2) + "x" + Str(drawing_x2) + "x" + Str(drawing_y)
            EndIf
          EndIf
          
          
          current_column + 1
          drawing_x = drawing_x2
        Else
          Break
        EndIf
        
      Wend
      
      If drawing_y <> 0 Or *grid\header_col_hidden > 0
        current_row + 1
      EndIf
      
      drawing_y = drawing_y2
    Else
      Break
    EndIf
    
  Wend
  
  ProcedureReturn "-2x-2"
EndProcedure

Procedure.s grid_GetCurrentCell(*grid.Grid_Struct,x,y)
  Protected drawing_x, drawing_x2, drawing_y, drawing_y2, current_row, current_row_map.s, current_column, current_column_map.s, indexed_current_column, indexed_current_row
  drawing_x = 0
  drawing_y = 0
  
  If x < *grid\header_row_width And y < (*grid\header_col_height+1) And Not *grid\header_col_hidden
    ProcedureReturn "-1x-1"+ "x"+Str(drawing_x)+ "x"+Str(drawing_y)
  EndIf
  
  current_row = *grid\yscroll
  drawing_y = 0
  While drawing_y < *grid\innerheight
    If current_row < *grid\maxnumrows
      
      indexed_current_row = *grid\row(current_row)
      
      ; Draw the rows captions
      current_row_map.s = Str(indexed_current_row)
      If drawing_y < *grid\header_col_height+1 And Not *grid\header_col_hidden
        drawing_y2 = *grid\header_col_height+1
      Else
        If FindMapElement(*grid\rows(), current_row_map)
          If *grid\rows()\visible ; don't draw
            current_row + 1
            Continue
          EndIf
          
          drawing_y2 = drawing_y + *grid\rows()\wh + 1
        Else
          drawing_y2 = drawing_y + *grid\default_row_height + 1
        EndIf
      EndIf
      
      ; Draw the cells
      drawing_x = 0
      current_column = *grid\xscroll
      
      If x <= (*grid\header_row_width + 1) And y >= drawing_y And y <= drawing_y2
        ProcedureReturn "-1x"+Str(current_row)+ "x"+Str(drawing_x)+ "x"+Str(drawing_y)
      EndIf
      
      drawing_x = *grid\header_row_width + 1
      While drawing_x < *grid\innerwidth
        If current_column < *grid\maxnumcols
          
          indexed_current_column = *grid\col(current_column)
          current_column_map.s = Str(indexed_current_column)+"x"+Str(indexed_current_row)
          
          If FindMapElement(*grid\cols(), Str(indexed_current_column))
            drawing_x2 = drawing_x + *grid\cols()\wh + 1
          Else
            drawing_x2 = drawing_x + *grid\default_col_width + 1
          EndIf
          
          If y <= (*grid\header_col_height + 1) And Not *grid\header_col_hidden
            If x >= drawing_x And x =< drawing_x2
              ProcedureReturn Str(current_column)+ "x-1"+ "x"+Str(drawing_x)+ "x"+Str(drawing_y)
            EndIf
          Else
            If x >= drawing_x And x =< drawing_x2 And y >= drawing_y And y <= drawing_y2
              ProcedureReturn Str(current_column)+ "x"+Str(current_row)+ "x"+Str(drawing_x)+ "x"+Str(drawing_y)
            EndIf
          EndIf
          
          current_column + 1
          drawing_x = drawing_x2
        Else
          Break
        EndIf
        
      Wend
      
      If drawing_y <> 0 Or *grid\header_col_hidden > 0
        current_row + 1
      EndIf
      
      drawing_y = drawing_y2
    Else
      Break
    EndIf
    
  Wend
  
  ProcedureReturn "-2x-2"+ "x"+Str(drawing_x)+ "x"+Str(drawing_y)
EndProcedure

Procedure.b grid_IsCellSelected(*grid.Grid_Struct, current_column, current_row)
  Protected selected.b
  
  selected.b = #False
  
  ForEach *grid\sel()
    If (*grid\sel()\sel_col = -1 And *grid\sel()\sel_row = -1)
      ; all cells selected
      selected = #True
      Break
    EndIf
    
    If (current_row >= grid_Min(*grid\sel()\sel_row,*grid\sel()\sel_row_end) And current_row <= grid_Max(*grid\sel()\sel_row,*grid\sel()\sel_row_end) And *grid\sel()\sel_col = -1)
      ; the whole row is selected
      selected = #True
      Break
    EndIf
    
    If (current_column >= grid_Min(*grid\sel()\sel_col,*grid\sel()\sel_col_end) And current_column <= grid_Max(*grid\sel()\sel_col,*grid\sel()\sel_col_end) And *grid\sel()\sel_row = -1)
      ; the whole column is selected
      selected = #True
      Break
    EndIf
    
    If current_column >= grid_Min(*grid\sel()\sel_col,*grid\sel()\sel_col_end) And current_column <= grid_Max(*grid\sel()\sel_col,*grid\sel()\sel_col_end) And current_row >= grid_Min(*grid\sel()\sel_row,*grid\sel()\sel_row_end) And current_row <= grid_Max(*grid\sel()\sel_row,*grid\sel()\sel_row_end)
      ; this cell is part of the selection
      selected = #True
      Break
    EndIf
  Next
  
  ProcedureReturn selected
EndProcedure

Procedure.b grid_IsColumnInSelection(*grid.Grid_Struct, current_column)
  Protected selected.b
  
  selected.b = #False
  
  ForEach *grid\sel()
    If (*grid\sel()\sel_col = -1 And *grid\sel()\sel_row = -1)
      ; all cells selected
      selected = #True
      Break
    EndIf
    
    If *grid\sel()\sel_col = -1
      selected = #True
      Break
    EndIf
    
    If (current_column >= grid_Min(*grid\sel()\sel_col,*grid\sel()\sel_col_end) And current_column <= grid_Max(*grid\sel()\sel_col,*grid\sel()\sel_col_end))
      selected = #True
      Break
    EndIf
  Next
  
  ProcedureReturn selected
EndProcedure

Procedure.b grid_IsRowInSelection(*grid.Grid_Struct, current_row)
  Protected selected.b
  
  selected.b = #False
  
  ForEach *grid\sel()
    If (*grid\sel()\sel_col = -1 And *grid\sel()\sel_row = -1)
      ; all cells selected
      selected = #True
      Break
    EndIf
    
    If *grid\sel()\sel_row = -1
      selected = #True
      Break
    EndIf
    
    If current_row >= grid_Min(*grid\sel()\sel_row,*grid\sel()\sel_row_end) And current_row <= grid_Max(*grid\sel()\sel_row,*grid\sel()\sel_row_end)
      selected = #True
      Break
    EndIf
  Next
  
  ProcedureReturn selected
EndProcedure

Procedure.b grid_IsCellEditing(*grid.Grid_Struct, current_column, current_row)
  If *grid\edit_col = current_column And *grid\edit_row = current_row
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure grid_GetLastCellSelected(*grid.Grid_Struct, *row, *column)
  Protected selected.b
  
  selected.b = #False
  
  LastElement(*grid\sel())
  If (*grid\sel()\sel_col = -1 And *grid\sel()\sel_row = -1)
    PokeL(*row,0)
    PokeL(*column,0)
    
  ElseIf (*grid\sel()\sel_col = -1)
    ; the whole row is selected
    PokeL(*row,*grid\sel()\sel_row)
    PokeL(*column,0)
    
  ElseIf (*grid\sel()\sel_row = -1)
    ; the whole column is selected
    PokeL(*row,0)
    PokeL(*column,*grid\sel()\sel_col)
    
  Else
    
    PokeL(*row,*grid\sel()\sel_row)
    PokeL(*column,*grid\sel()\sel_col)
    
  EndIf
EndProcedure

Procedure grid_GetEditPosFromMouse(*grid.Grid_Struct, current_column, current_row, mouse_x, mouse_y)
  Protected xmouse, xpos1, xpos2, cell.s, textwidth, leftpadding, textx, textstart, fontkey.s, textend, i, pos
  
  xmouse = mouse_x - *grid\edit_x + 3
  
  xpos1 = 0
  xpos2 = 0
  StartDrawing(ImageOutput(*grid\tempimg))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  
  cell.s = Str(*grid\col(current_column))+"x"+Str(*grid\row(current_row))
  
  If FindMapElement(*grid\cells(),cell)
    If *grid\cells()\halign = #Grid_Align_Center
      textwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
      leftpadding = (*grid\edit_x2 - *grid\edit_x - textwidth) / 2 ; (cell width - text width) / 2
      
    ElseIf *grid\cells()\halign = #Grid_Align_Right
      textwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
      leftpadding = *grid\edit_x2 - *grid\edit_x - textwidth - *grid\cells()\ident ; (cell width - text width)
      
    Else
      leftpadding = *grid\cells()\ident
    EndIf
    
    textx = leftpadding
    textstart = 1
    
    
    If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap; if the cell is a combo box, wrap text and start at the position
      textstart = 1 + *grid\edit_combo_pos
    EndIf
    
    
    ForEach *grid\cells()\style()
      fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
      
      If *grid\cells()\style()\fontflags & #PB_Font_Bold
        fontkey + "B"
      EndIf
      If *grid\cells()\style()\fontflags & #PB_Font_Italic
        fontkey + "I"
      EndIf
      
      If FindMapElement(grids_fonts(),fontkey)
        DrawingFont(FontID(grids_fonts()\hfont))
      EndIf
      
      textend = *grid\cells()\style()\style_end
      
      
      For i = textstart To textend
        xpos1 = xpos2
        xpos2 = textx + TextWidth(Mid(*grid\cells()\content,textstart, i - textstart + 1))
        If xmouse >= xpos1 And xmouse < xpos2
          pos = i-1
          Break
        EndIf
      Next
      textx = xpos2
      
      textstart = *grid\cells()\style()\style_end + 1
      DrawingFont(FontID(*grid\font))
    Next
  EndIf
  
  If xmouse >= textx
    pos = Len(*grid\cells()\content)
  EndIf
  
  DrawingFont(FontID(*grid\font))
  StopDrawing()
  
  ProcedureReturn pos
EndProcedure
Procedure grid_GetCellTextWidth(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, width, textstart, fontkey.s
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  DrawingFont(FontID(*grid\font))
  
  If FindMapElement(*grid\cells(),cell)
    width = 0
    textstart = 1
    ForEach *grid\cells()\style()
      fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
      
      If *grid\cells()\style()\fontflags & #PB_Font_Bold
        fontkey + "B"
      EndIf
      If *grid\cells()\style()\fontflags & #PB_Font_Italic
        fontkey + "I"
      EndIf
      
      If FindMapElement(grids_fonts(),fontkey)
        DrawingFont(FontID(grids_fonts()\hfont))
      EndIf
      
      width + TextWidth(Mid(*grid\cells()\content,textstart, *grid\cells()\style()\style_end - textstart + 1))
      textstart = *grid\cells()\style()\style_end + 1
      DrawingFont(FontID(*grid\font))
    Next
  EndIf
  
  DrawingFont(FontID(*grid\font))
  
  ProcedureReturn width
EndProcedure

Procedure grid_GetCellTextHeight2(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, height, textstart, fontkey.s, text.s, newheight
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  DrawingFont(FontID(*grid\font))
  
  If FindMapElement(*grid\cells(),cell)
    height = 0
    textstart = 1
    ForEach *grid\cells()\style()
      fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
      
      If *grid\cells()\style()\fontflags & #PB_Font_Bold
        fontkey + "B"
      EndIf
      If *grid\cells()\style()\fontflags & #PB_Font_Italic
        fontkey + "I"
      EndIf
      
      If FindMapElement(grids_fonts(),fontkey)
        DrawingFont(FontID(grids_fonts()\hfont))
      EndIf
      
      text.s = Mid(*grid\cells()\content,textstart, *grid\cells()\style()\style_end - textstart + 1)
      newheight = *grid\cells()\style()\fontsize
      If newheight > height And Len(text) > 0
        height = newheight
      EndIf
      
      textstart = *grid\cells()\style()\style_end + 1
      DrawingFont(FontID(*grid\font))
    Next
  EndIf
  
  height = Int(height/0.82)
  ProcedureReturn height
EndProcedure

Procedure grid_GetCellTextHeight(*grid.Grid_Struct, col_index, row_index)
  Protected cell.s, height, textstart, fontkey.s, text.s, newheight
  
  cell.s = Str(*grid\col(col_index))+"x"+Str(*grid\row(row_index))
  
  DrawingFont(FontID(*grid\font))
  
  If FindMapElement(*grid\cells(),cell)
    height = 0
    textstart = 1
    ForEach *grid\cells()\style()
      fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
      
      If *grid\cells()\style()\fontflags & #PB_Font_Bold
        fontkey + "B"
      EndIf
      If *grid\cells()\style()\fontflags & #PB_Font_Italic
        fontkey + "I"
      EndIf
      
      
      If FindMapElement(grids_fonts(),fontkey)
        DrawingFont(FontID(grids_fonts()\hfont))
      EndIf
      
      text.s = Mid(*grid\cells()\content,textstart, *grid\cells()\style()\style_end - textstart + 1)
      newheight = TextHeight(text)
      If newheight > height And Len(text) > 0
        height = newheight
      EndIf
      
      textstart = *grid\cells()\style()\style_end + 1
      DrawingFont(FontID(*grid\font))
    Next
  EndIf
  
  ProcedureReturn height
EndProcedure

Procedure grid_GetWidthFromPos(*grid.Grid_Struct, current_column, current_row, pos)
  Protected xpos1, xpos2, cell.s, textx, textstart, textend, fontkey.s, i
  
  If pos = 0
    ProcedureReturn 0
  EndIf
  
  xpos1 = 0
  xpos2 = 0
  
  cell.s = Str(*grid\col(current_column))+"x"+Str(*grid\row(current_row))
  
  If FindMapElement(*grid\cells(),cell)
    textx = 0
    textstart = 1
    ForEach *grid\cells()\style()
      fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
      
      If *grid\cells()\style()\fontflags & #PB_Font_Bold
        fontkey + "B"
      EndIf
      If *grid\cells()\style()\fontflags & #PB_Font_Italic
        fontkey + "I"
      EndIf
      
      If FindMapElement(grids_fonts(),fontkey)
        DrawingFont(FontID(grids_fonts()\hfont))
      EndIf
      
      textend = *grid\cells()\style()\style_end
      
      
      For i = textstart To textend
        xpos1 = xpos2
        xpos2 = textx + TextWidth(Mid(*grid\cells()\content,textstart, i - textstart + 1))
        If i = pos
          DrawingFont(FontID(*grid\font))
          ProcedureReturn xpos2
        EndIf
      Next
      textx = xpos2
      
      textstart = *grid\cells()\style()\style_end + 1
      DrawingFont(FontID(*grid\font))
    Next
  EndIf
  
  DrawingFont(FontID(*grid\font))
  
  ProcedureReturn -1
EndProcedure

Procedure grid_BeginEditing(*grid.Grid_Struct, col, row)
  Protected ok, content.s, mousex, mousey
  
  mousex = grid_NewWindowMouseX(*grid\hwnd) - *grid\x - grid_deltagadgetposx
  mousey = grid_NewWindowMouseY(*grid\hwnd) - *grid\y - grid_deltagadgetposy
  
  If *grid\edit_col = -1 And *grid\edit_row = -1
    If col >= 0 And row >= 0 And Not grid_GetCellLockState(*grid,col,row)
      ok = #True
      If FindMapElement(*grid\cells(),Str(*grid\col(col))+"x"+Str(*grid\row(row)))
        Select *grid\cells()\type
          Case #Grid_Cell_Checkbox, #Grid_Cell_Combobox, #Grid_Cell_Custom, #Grid_Cell_SpinGadget
            ok = #False
        EndSelect
      EndIf
      
      If ok
        *grid\edit_col = col
        *grid\edit_row = row
        
        If *grid\numcols < *grid\edit_col
          *grid\numcols = *grid\edit_col
        EndIf
        If *grid\numrows < *grid\edit_row
          *grid\numrows = *grid\edit_row
        EndIf
        
        ; scroll if the cell is not entirely visible
        If *grid\edit_col > *grid\xscroll_end And *grid\edit_col < (*grid\maxnumcols - 1)
          grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Column,*grid\xscroll + 1)
          grid_DoRedraw(*grid)
        EndIf
        If *grid\edit_row >= *grid\yscroll_end And *grid\edit_row < (*grid\maxnumrows - 1)
          grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Row,*grid\yscroll + 1)
          grid_DoRedraw(*grid)
        EndIf
        
        content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
        
        If FindMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
          CopyList(*grid\cells()\style(),*grid\edit_old_style())
        EndIf
        
        If content = ""
          If Not FindMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
            AddMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
            *grid\cells()\backColor = *grid\color_background
          EndIf
          
          If ListSize(*grid\cells()\style()) <> 1
            ClearList(*grid\cells()\style())
            AddElement(*grid\cells()\style())
            *grid\cells()\style()\color = *grid\dfontcolor
            *grid\cells()\style()\fontname = *grid\dfont
            *grid\cells()\style()\fontsize = *grid\dfontsize
            *grid\cells()\style()\style_end = 0
          Else
            LastElement(*grid\cells()\style())
            *grid\cells()\style()\style_end = 0
          EndIf
          
        EndIf
        grid_DoRedraw( *grid )
        
        *grid\edit_pos = grid_GetEditPosFromMouse( *grid,  *grid\edit_col, *grid\edit_row, mousex, mousey)
        *grid\edit_sel_end = 0
        *grid\edit_sel_start = 0
        *grid\edit_combo_pos = 0
        
        *grid\edit_old_content = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cursor
        *grid\tstyle = #False
        
        *grid\redraw = #True
        *grid\redraw_ignore_grid = #True
      EndIf
    EndIf
  EndIf
EndProcedure

Procedure grid_StopEditing(*grid.Grid_Struct)
  Protected mousex, mousey
  
  mousex = grid_NewWindowMouseX(*grid\hwnd) - *grid\x - grid_deltagadgetposx
  mousey = grid_NewWindowMouseY(*grid\hwnd) - *grid\y - grid_deltagadgetposy
  
  If *grid\edit_col > -1 And *grid\edit_row > -1 And mousex > *grid\edit_x And mousex < *grid\edit_x2 And mousey > *grid\edit_y And mousey < *grid\edit_y2
  Else
    If *grid\edit_col > -1 And *grid\edit_row > -1
      If *grid\edit_old_content <> grid_GetCellString(*grid,*grid\edit_col,*grid\edit_row)
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cell
        *grid\events()\event_column = *grid\sel()\sel_col
        *grid\events()\event_row = *grid\sel()\sel_row
        *grid\events()\event_cell = #Grid_Event_Cell_ContentChange
      EndIf
    EndIf
    
    *grid\edit_col = -1
    *grid\edit_row = -1
    *grid\edit_combo_pos = 0
    
    *grid\edit_selecting = #False
    *grid\redraw = #True
    *grid\tstyle = #False
  EndIf
EndProcedure

Procedure grid_DoEditFieldEvent(*grid.Grid_Struct, key)
  Protected edit_col, edit_row, cell.s, content.s, min, max, bold, italic, underline, strikethrough, width, width_editpos, width_pos
  
  If *grid\maxnumrows And *grid\maxnumcols
    ; switch to edit mode, and type the first character
    If *grid\edit_col = -1 And *grid\edit_row = -1
      LastElement(*grid\sel())
      
      If *grid\sel()\sel_col = -1
        edit_col = 0
      Else
        edit_col = *grid\sel()\sel_col
      EndIf
      If *grid\sel()\sel_row = -1
        edit_row = 0
      Else
        edit_row = *grid\sel()\sel_row
      EndIf
      
      *grid\edit_combo_pos = 0
      
      If FindMapElement(*grid\cells(), Str(*grid\col(edit_col))+"x"+Str(*grid\row(edit_row)))
        If *grid\cells()\type = #Grid_Cell_Checkbox Or *grid\cells()\type = #Grid_Cell_Combobox Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_Custom
          ProcedureReturn
        EndIf
      EndIf
      
      If Not grid_GetCellLockState( *grid,  edit_col, edit_row)
        *grid\edit_col = edit_col
        *grid\edit_row = edit_row
        
        If *grid\numcols < *grid\edit_col
          *grid\numcols = *grid\edit_col
        EndIf
        If *grid\numrows < *grid\edit_row
          *grid\numrows = *grid\edit_row
        EndIf
        
        *grid\edit_pos = 0
        *grid\edit_sel_end = 0
        *grid\edit_sel_start = 0
        *grid\edit_old_content = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
        
        cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
        If FindMapElement(*grid\cells(), cell)
          *grid\cells()\content = ""
          CopyList(*grid\cells()\style(),*grid\edit_old_style())
          ; as through this mode we clear the previous content, let's clear the previous styles as well
          If ListSize(*grid\cells()\style()) <> 1
            ClearList(*grid\cells()\style())
            AddElement(*grid\cells()\style())
            *grid\cells()\style()\color = *grid\dfontcolor
            *grid\cells()\style()\fontname = *grid\dfont
            *grid\cells()\style()\fontsize = *grid\dfontsize
            *grid\cells()\style()\style_end = 0
          Else
            LastElement(*grid\cells()\style())
            *grid\cells()\style()\style_end = 0
          EndIf
        EndIf
        
        ; scroll if the cell is not entirely visible
        If *grid\edit_col > *grid\xscroll_end And *grid\edit_col < *grid\maxnumcols
          grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Column,*grid\xscroll + 1)
          grid_DoRedraw(*grid)
        EndIf
        If *grid\edit_row >= *grid\yscroll_end And *grid\edit_row < *grid\maxnumrows
          grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Row,*grid\yscroll + 1)
          grid_DoRedraw(*grid)
        EndIf
      EndIf
    EndIf
    
    ; if there was a selection, erase the selection...
    If *grid\edit_selecting = #True
      cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
      content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
      content = Left(content, grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)) + Right(content, Len(content) - grid_Max(*grid\edit_sel_start, *grid\edit_sel_end))
      
      If FindMapElement(*grid\cells(),cell)
        *grid\cells()\content = content
        min = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
        max = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
        ForEach *grid\cells()\style()
          If *grid\cells()\style()\style_end >= min And *grid\cells()\style()\style_end <= max
            *grid\cells()\style()\style_end = min
          ElseIf *grid\cells()\style()\style_end >= max
            *grid\cells()\style()\style_end = *grid\cells()\style()\style_end - (max - min)
          EndIf
        Next
      EndIf
      
      *grid\edit_pos = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
      *grid\edit_sel_end = 0
      *grid\edit_sel_start = 0
      *grid\edit_selecting = #False
    EndIf
    
    ; Add the input
    If *grid\edit_col > -1 And *grid\edit_row > -1
      cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
      
      If Not FindMapElement(*grid\cells(),cell)
        AddMapElement(*grid\cells(),cell)
        *grid\cells()\backColor = *grid\color_background
        
        ClearList(*grid\cells()\style())
        AddElement(*grid\cells()\style())
        *grid\cells()\style()\color = *grid\dfontcolor
        *grid\cells()\style()\fontname = *grid\dfont
        *grid\cells()\style()\fontsize = *grid\dfontsize
        *grid\cells()\style()\style_end = 0
      EndIf
      
      If FindMapElement(*grid\cells(),cell)
        LastElement(*grid\cells()\style())
        Repeat
          If *grid\cells()\style()\style_end >= *grid\edit_pos
            *grid\cells()\style()\style_end + 1
            
            If *grid\edit_pos = (*grid\cells()\style()\style_end - 1)
              Break
            EndIf
          EndIf
          
        Until PreviousElement(*grid\cells()\style()) = 0
      EndIf
      
      *grid\cells()\content = Left(*grid\cells()\content,*grid\edit_pos) + Chr(key) + Right(*grid\cells()\content,Len(*grid\cells()\content)-*grid\edit_pos)
      *grid\edit_pos + 1
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Cursor
      
      If *grid\tstyle
        If *grid\tfontflags & #PB_Font_Bold
          bold = 1
        EndIf
        
        If *grid\tfontflags & #PB_Font_Italic
          italic = 1
        EndIf
        
        If *grid\tfontflags & #PB_Font_Underline
          underline = 1
        EndIf
        
        If *grid\tfontflags & #Grid_TextEdit_Font_Strikethrough
          strikethrough = 1
        EndIf
        grid_SetSelectionStyle( *grid, -1,-1,*grid\tfont,*grid\tfontsize,bold,italic, underline,strikethrough,*grid\tfontcolor,*grid\edit_pos-1,*grid\edit_pos)
      EndIf
      
      ; Combo box scrolling handling
      If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
        If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
          StartDrawing(ImageOutput(*grid\tempimg))
          width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
          
          If width >= (*grid\edit_x2 - *grid\edit_x) And *grid\edit_x2 > 0
            ; get cursor position taking into account the combo scroll position
            width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
            width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
            If width_pos >= (*grid\edit_x2 - *grid\edit_x)
              StopDrawing()
              *grid\edit_combo_pos = 0
              ; move combo scroll pos
              *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos - (*grid\edit_x2 - *grid\edit_x),*grid\edit_y + 1) + 1
            EndIf
          EndIf
          StopDrawing()
        EndIf
      EndIf
      
      *grid\tstyle = #False
      
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
    EndIf
  EndIf
EndProcedure

Procedure grid_DoHoverEvent(*grid.Grid_Struct,x, y)
  Protected cursor.b, current_row, current_column, drawing_x, drawing_x2, drawing_y, drawing_y2, indexed_current_column, indexed_current_row
  
  cursor.b = #False
  
  ; if the mouse position is on the cells, or on the "select all" header button
  If (x > *grid\header_row_width And y > *grid\header_col_height) Or (x < *grid\header_row_width And y < *grid\header_col_height)
    
  Else
    
    current_row = *grid\yscroll
    drawing_y = 0
    While drawing_y < *grid\innerheight
      indexed_current_row = *grid\row(current_row)
      
      If drawing_y < *grid\header_col_height + 1
        drawing_y2 = *grid\header_col_height + 1
      Else
        If FindMapElement(*grid\rows(), Str(indexed_current_row))
          drawing_y2 = drawing_y + *grid\rows()\wh + 1
        Else
          drawing_y2 = drawing_y + *grid\default_row_height + 1
        EndIf
      EndIf
      
      drawing_x = 0
      current_column = *grid\xscroll
      
      If x <= (*grid\header_row_width + 1) And y >= (drawing_y2 - 3) And y <= (drawing_y2 + 3) And drawing_y > 0
        *grid\resize_row = current_row
        *grid\resize_posx = drawing_y
        *grid\resize_posy = drawing_y2
        
        If *grid\cursor <> #PB_Cursor_UpDown
          SetGadgetAttribute(*grid\canvas,#PB_Canvas_Cursor,#PB_Cursor_UpDown)
          *grid\cursor = #PB_Cursor_UpDown
          cursor = #True
        EndIf
        ProcedureReturn
      EndIf
      
      If drawing_y <> 0
        current_row + 1
      EndIf
      
      drawing_y = drawing_y2
      
      If current_row >= *grid\maxnumrows
        Break
      EndIf
      
    Wend
    
    drawing_x = *grid\header_row_width + 1
    While drawing_x < *grid\innerwidth
      indexed_current_column = *grid\col(current_column)
      
      If FindMapElement(*grid\cols(), Str(indexed_current_column))
        drawing_x2 = drawing_x + *grid\cols()\wh + 1
      Else
        drawing_x2 = drawing_x + *grid\default_col_width + 1
      EndIf
      
      If y <= *grid\header_col_height
        If x >= (drawing_x2 - 5) And x <= (drawing_x2 + 5)
          *grid\resize_col = current_column
          *grid\resize_posx = drawing_x
          *grid\resize_posy = drawing_x2
          
          If *grid\cursor <> #PB_Cursor_LeftRight
            SetGadgetAttribute(*grid\canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftRight)
            *grid\cursor = #PB_Cursor_LeftRight
            cursor = #True
          EndIf
          
          ProcedureReturn
        EndIf
      EndIf
      
      current_column + 1
      
      If current_column >= *grid\maxnumcols
        Break
      EndIf
      
      drawing_x = drawing_x2
    Wend
    
    
  EndIf
  
  If cursor = #False
    *grid\cursor = #PB_Cursor_Default
    *grid\resize_col = - 1
    *grid\resize_row = - 1
    
    SetGadgetAttribute(*grid\canvas,#PB_Canvas_Cursor,#PB_Cursor_Default)
  EndIf
EndProcedure

Procedure grid_DrawCombo(drawing_x, drawing_x2, drawing_y,drawing_y2, *grid)
  Protected x1, x2, y1, y2
  
  x1 = drawing_x2 - 22 - 1
  x2 = drawing_x2 - 2
  y1 = drawing_y
  y2 = drawing_y2 - 1
  
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Box(x1 + 1, y1 + 1, x2 - x1 - 2, (y2 - y1) -2,RGB(235,235,235))
  DrawingMode(#PB_2DDrawing_Outlined)
  RoundBox(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2,3,3,RGB(250,250,250))
  RoundBox(x1, y1, x2 - x1, y2 - y1,3,3,RGB(111,111,111))
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  Line(drawing_x2 - 1 - 21 + 5,drawing_y + (drawing_y2 - drawing_y - 5) / 2, 9, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 6,drawing_y + (drawing_y2 - drawing_y - 5) / 2 + 1, 7, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 7,drawing_y + (drawing_y2 - drawing_y - 5) / 2 + 2, 5, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 8,drawing_y + (drawing_y2 - drawing_y - 5) / 2 + 3, 3, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 9,drawing_y + (drawing_y2 - drawing_y - 5) / 2 + 4, 1, 1,RGB(40,40,40))
EndProcedure

Procedure grid_DrawSpin(drawing_x, drawing_x2, drawing_y,drawing_y2, *grid)
  Protected x1, x2, y1, y2, boxheight
  
  x1 = drawing_x2 - 22 - 1
  x2 = drawing_x2 - 2
  y1 = drawing_y
  y2 = drawing_y2 - 1
  
  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
  boxheight = (drawing_y2 - drawing_y) / 2
  ; up
  Line(drawing_x2 - 1 - 21 + 9,drawing_y + (boxheight - 5) / 2 , 1, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 8,drawing_y + (boxheight - 5) / 2 + 1, 3, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 7,drawing_y + (boxheight - 5) / 2 + 2, 5, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 6,drawing_y + (boxheight - 5) / 2 + 3, 7, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 5,drawing_y + (boxheight - 5) / 2 + 4, 9, 1,RGB(40,40,40))
  
  ; down
  Line(drawing_x2 - 1 - 21 + 5,drawing_y + boxheight + (boxheight - 5) / 2, 9, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 6,drawing_y + boxheight + (boxheight - 5) / 2 + 1, 7, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 7,drawing_y + boxheight + (boxheight - 5) / 2 + 2, 5, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 8,drawing_y + boxheight + (boxheight - 5) / 2 + 3, 3, 1,RGB(40,40,40))
  Line(drawing_x2 - 1 - 21 + 9,drawing_y + boxheight + (boxheight - 5) / 2 + 4, 1, 1,RGB(40,40,40))
EndProcedure


Procedure grid_DoRedraw(*grid.Grid_Struct,redraw_grid.b = #True)
  Protected drawing_x, drawing_x2, drawing_y, drawing_y2, current_column, current_row, indexed_current_column, indexed_current_row, width, rowCaptionWidth, firstcell_coll, firstcell_row, column_selected.b
  Protected caption.s, cell.s, height, height2, edit_col, textwidth, leftpadding, toppadding, tempcontent.s, tempwidth, content.s, fontkey.s, textx, textstart, text.s, newtextx
  Protected row_selected.b, wtext, xcursor, sel_end, sel_start, selend, selstart, abc, cellcolor, selected_cell
  
  drawing_x = 0
  drawing_y = 0
  rowCaptionWidth = 0
  
  If Not *grid\hidden
    
    StartDrawing(CanvasOutput(*grid\canvas))
    DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
    DrawingFont(FontID(*grid\font))
    
    Define w = OutputWidth()
    Define h = OutputHeight()
    
    If redraw_grid
      Box(0,0,w,h,RGB(255,255,255))
    EndIf
    
    ; Calculate Row Caption Width
    current_row = *grid\yscroll
    
    While  drawing_y < h
      If current_row < *grid\maxnumrows
        indexed_current_row = *grid\row(current_row)
        
        If FindMapElement(*grid\rows(), Str(indexed_current_row))
          width = *grid\rows()\wtext + #Grid_Padding * 2
          
          If width > rowCaptionWidth
            rowCaptionWidth = width
          EndIf
          
          drawing_y + *grid\rows()\wh + 1
        Else
          width = TextWidth(Str(current_row)) + #Grid_Padding * 2
          
          If width > rowCaptionWidth
            rowCaptionWidth = width
          EndIf
          
          drawing_y + *grid\default_row_height + 1
        EndIf
        current_row + 1
      Else
        current_row + 1
        Break
      EndIf
    Wend
    
    If rowCaptionWidth = 0 And *grid\maxnumcols > 0
      rowCaptionWidth = 15
    EndIf
    
    *grid\yscroll_end = current_row - 2
    
    If *grid\header_row_hidden = 1
      *grid\header_row_width = 0
    Else
      *grid\header_row_width = rowCaptionWidth
    EndIf
    
    ; Draw the "select all cells" button
    If redraw_grid And Not *grid\header_row_hidden And rowCaptionWidth > 0 And Not *grid\header_col_hidden
      FrontColor(*grid\color_header)
      Box(0,0,rowCaptionWidth,*grid\header_col_height)
      
      LineXY(rowCaptionWidth - 11 - 4, *grid\header_col_height - 3, rowCaptionWidth - 4, *grid\header_col_height - 3 - 11, *grid\color_selectall)
      LineXY(rowCaptionWidth - 4, *grid\header_col_height - 3 - 11, rowCaptionWidth - 4, *grid\header_col_height - 3, *grid\color_selectall)
      LineXY(rowCaptionWidth - 15, *grid\header_col_height - 3, rowCaptionWidth - 4, *grid\header_col_height - 3, *grid\color_selectall)
      FillArea(rowCaptionWidth - 5, *grid\header_col_height - 4, *grid\color_selectall, *grid\color_selectall)
    EndIf
    
    current_column = *grid\xscroll
    
    If Not *grid\header_row_hidden
      drawing_x = *grid\header_row_width + 1
    Else
      drawing_x = 0
    EndIf
    
    grid_GetLastCellSelected(*grid.Grid_Struct, @firstcell_row, @firstcell_coll)
    
    While drawing_x < w
      If current_column < *grid\maxnumcols
        
        ;{- draw column caption and vertical lines
        DrawingFont(FontID(*grid\font))
        
        indexed_current_column = *grid\col(current_column)
        column_selected.b = grid_IsColumnInSelection( *grid,  current_column)
        
        If redraw_grid
          If Not *grid\header_col_hidden
            If FindMapElement(*grid\cols(), Str(indexed_current_column))
              If column_selected
                FrontColor(*grid\color_header_sel)
              Else
                FrontColor(*grid\color_header)
              EndIf
              
              Box(drawing_x,0,*grid\cols()\wh, *grid\header_col_height)
              
              If *grid\cols()\caption <> ""
                caption.s = *grid\cols()\caption
              Else
                caption.s = grid_NumberToLetter(current_column)
              EndIf
              
              If column_selected
                FrontColor(*grid\color_header_text_sel)
              Else
                FrontColor(*grid\color_header_text)
              EndIf
              
              DrawText(drawing_x + (*grid\cols()\wh - *grid\cols()\wtext) / 2 ,4,caption)
              
              If *grid\cols()\buttonid
                DrawAlphaImage(*grid\cols()\buttonid,drawing_x + *grid\cols()\wh - 17,(*grid\header_col_height - 16)/2)
              EndIf
              
              LineXY(drawing_x + *grid\cols()\wh,0,drawing_x + *grid\cols()\wh, *grid\header_col_height,*grid\color_linedark)
            Else
              If column_selected
                FrontColor(*grid\color_header_sel)
              Else
                FrontColor(*grid\color_header)
              EndIf
              
              Box(drawing_x,0,*grid\default_col_width, *grid\header_col_height)
              
              If column_selected
                FrontColor(*grid\color_header_text_sel)
              Else
                FrontColor(*grid\color_header_text)
              EndIf
              
              DrawText(drawing_x + *grid\default_col_width / 2 ,4, grid_NumberToLetter(current_column))
              
              LineXY(drawing_x + *grid\default_col_width,0,drawing_x + *grid\default_col_width, *grid\header_col_height, *grid\color_linedark)
            EndIf
          EndIf
        EndIf
        
        If FindMapElement(*grid\cols(), Str(indexed_current_column))
          drawing_x2 = drawing_x + *grid\cols()\wh + 1
        Else
          drawing_x2 = drawing_x + *grid\default_col_width + 1
        EndIf
        
        If redraw_grid
          If Not *grid\vline
            If *grid\header_col_hidden
              LineXY(drawing_x2 - 1, 0, drawing_x2 - 1, h,*grid\color_linelight)
            Else
              LineXY(drawing_x2 - 1, *grid\header_col_height, drawing_x2 - 1,h,*grid\color_linelight)
            EndIf
          EndIf
        EndIf
        
        If *grid\header_col_hidden
          drawing_y = 0
        Else
          drawing_y = *grid\header_col_height + 1
        EndIf
        ;}
        
        current_row = *grid\yscroll
        
        While drawing_y < h
          If current_row < *grid\maxnumrows
            ; Draw the cells
            indexed_current_row = *grid\row(current_row)
            
            If FindMapElement(*grid\rows(), Str(indexed_current_row))
              If *grid\rows()\visible ; don't draw
                current_row + 1
                drawing_y2 = drawing_y
                Continue
              EndIf
              
              
              drawing_y2 = drawing_y + *grid\rows()\wh + 1
            Else
              drawing_y2 = drawing_y + *grid\default_row_height + 1
            EndIf
            
            ; draw back color
            cell.s = Str(indexed_current_column)+"x"+Str(indexed_current_row)
            
            If redraw_grid
              
              If FindMapElement(*grid\cells(),cell)
                Box(drawing_x, drawing_y, drawing_x2 - drawing_x - 1, drawing_y2 - drawing_y,grid_GetCellBackColor( *grid, current_column, current_row))
              Else
                Box(drawing_x, drawing_y, drawing_x2 - drawing_x - 1, drawing_y2 - drawing_y, *grid\color_background)
              EndIf
              
              
              If grid_IsCellSelected( *grid,  current_column, current_row)
                ; get width
                If FindMapElement(*grid\cols(), Str(indexed_current_column))
                  width = *grid\cols()\wh
                Else
                  width = *grid\default_col_width
                EndIf
                
                ;get height
                If FindMapElement(*grid\rows(), Str(indexed_current_row))
                  height = *grid\rows()\wh
                Else
                  height = *grid\default_row_height
                EndIf
                
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                
                If current_row = firstcell_row And current_column = firstcell_coll
                  Box(drawing_x,drawing_y,width + *grid\vline,height + *grid\hline,RGBA(215,235,255,200))
                Else
                  Box(drawing_x,drawing_y,width + *grid\vline,height + *grid\hline,RGBA(180,220,255,200))
                EndIf
                
                DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
              EndIf
            EndIf
            
            ; if this cell is in edit mode, calculate the cells width (> to the text width)
            If grid_IsCellEditing( *grid,  current_column, current_row) ;{-
              *grid\edit_x = drawing_x
              *grid\edit_x2 = drawing_x2
              *grid\edit_y2 = drawing_y2
              *grid\edit_y = drawing_y
              textwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
              edit_col = current_column
              
              
              If FindMapElement(*grid\cells(), cell)
                Select *grid\cells()\type
                  Case #Grid_Cell_Combobox_Editable, #Grid_Cell_SpinGadget ; Make the edit field 22px smaller to leave space for the combo box button
                    *grid\edit_x2 - 22
                  Case #Grid_Cell_Text ; Extend the edit field width according to the cell content if the cell is in text mode.
                    If *grid\cells()\halign = #Grid_Align_Right
                      While textwidth > (*grid\edit_x2 - *grid\edit_x)
                        edit_col - 1
                        
                        If edit_col < 0
                          *grid\edit_x = *grid\header_row_width
                          Break
                        EndIf
                        
                        *grid\edit_x - grid_GetColumnWidth( *grid, edit_col)
                      Wend
                    Else
                      While textwidth > (*grid\edit_x2 - *grid\edit_x)
                        edit_col + 1
                        *grid\edit_x2 + grid_GetColumnWidth( *grid, edit_col) + 1
                      Wend
                    EndIf
                EndSelect
              EndIf
              ;}
            Else ;{- Not in edit mode, draw the cell according to its cell type.
              If redraw_grid
                If FindMapElement(*grid\cells(), Str(indexed_current_column)+"x"+Str(indexed_current_row))
                  Select *grid\cells()\type
                    Case #Grid_Cell_Custom ;{- Draw custom cell
                      If *grid\cells()\state
                        CallFunctionFast(*grid\cells()\state,drawing_x, drawing_y, drawing_x2 - drawing_x, drawing_y2 - drawing_y, current_column, current_row)
                      EndIf
                      ;}
                      
                    Case #Grid_Cell_Checkbox ;{- Draw check box
                      If *grid\cells()\state = 0
                        DrawImage(ImageID(*grid\checkboximgno), drawing_x + (drawing_x2 - drawing_x - 16) / 2, drawing_y + (drawing_y2 - drawing_y - 16) / 2)
                      Else
                        DrawImage(ImageID(*grid\checkboximgyes), drawing_x + (drawing_x2 - drawing_x - 16) / 2, drawing_y + (drawing_y2 - drawing_y - 16) / 2)
                      EndIf
                      ;}
                      
                    Case #Grid_Cell_Combobox, #Grid_Cell_SpinGadget, #Grid_Cell_Combobox_Editable ;{- Draw combo box and text
                      height2 = grid_GetCellTextHeight2( *grid,  current_column, current_row)
                      height = grid_GetCellTextHeight( *grid,  current_column, current_row)
                      textwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
                      
                      If *grid\cells()\type = #Grid_Cell_Combobox Or *grid\cells()\type = #Grid_Cell_Combobox_Editable
                        grid_DrawCombo(drawing_x, drawing_x2, drawing_y, drawing_y2, *grid)
                      ElseIf *grid\cells()\type = #Grid_Cell_SpinGadget
                        grid_DrawSpin(drawing_x, drawing_x2, drawing_y, drawing_y2, *grid)
                      EndIf
                      
                      width = drawing_x2 - drawing_x - 22 ; removes 22 as this is the size of the dropdown button
                      
                      ;{- Compute padding
                      If *grid\cells()\halign = #Grid_Align_Center
                        leftpadding = (drawing_x2 - drawing_x - textwidth) / 2 ; (cell width - text width) / 2
                        
                      ElseIf *grid\cells()\halign = #Grid_Align_Right
                        leftpadding = drawing_x2 - drawing_x - textwidth - *grid\cells()\ident; (cell width - text width)
                        
                      Else
                        leftpadding = *grid\cells()\ident
                      EndIf
                      
                      
                      If *grid\cells()\valign = #Grid_Align_Top
                        toppadding = 0
                      ElseIf *grid\cells()\valign = #Grid_Align_Middle
                        toppadding = (drawing_y2 - drawing_y - height) / 2
                      Else
                        toppadding = drawing_y2 - drawing_y - height
                      EndIf
                      
                      If toppadding < 0
                        toppadding = 0
                      EndIf
                      
                      If leftpadding < 0
                        leftpadding = 0
                      EndIf
                      ;}
                      ;{- Wrap text to fit in cell
                      If textwidth > width
                        ; wrap text
                        content.s = *grid\cells()\content
                        tempwidth = textwidth
                        tempcontent.s = content
                        
                        While tempwidth > width
                          *grid\cells()\content = Left(tempcontent,Len(tempcontent)-1)
                          tempcontent = *grid\cells()\content
                          tempwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
                        Wend
                        
                        *grid\cells()\content = content
                        content = tempcontent
                      Else
                        content.s = *grid\cells()\content
                      EndIf
                      ;}
                      
                      textx = drawing_x + leftpadding
                      textstart = 1
                      ForEach *grid\cells()\style()
                        fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
                        
                        If *grid\cells()\style()\fontflags & #PB_Font_Bold
                          fontkey + "B"
                        EndIf
                        If *grid\cells()\style()\fontflags & #PB_Font_Italic
                          fontkey + "I"
                        EndIf
                        
                        If FindMapElement(grids_fonts(),fontkey)
                          DrawingFont(FontID(grids_fonts()\hfont))
                        EndIf
                        
                        text.s = Mid(content,textstart, *grid\cells()\style()\style_end - textstart + 1)
                        newtextx = DrawText(textx,drawing_y + height2 - *grid\cells()\style()\fontsize/0.82 + toppadding, text,*grid\cells()\style()\color)
                        
                        ; draw the underline
                        If *grid\cells()\style()\fontflags & #PB_Font_Underline
                          Line(textx,drawing_y + toppadding + height - 2, newtextx - textx, 1, *grid\cells()\style()\color)
                        EndIf
                        
                        ; draw the strike through
                        If *grid\cells()\style()\fontflags & #Grid_TextEdit_Font_Strikethrough
                          Line(textx,drawing_y + toppadding + height / 2, newtextx - textx, 1, *grid\cells()\style()\color)
                        EndIf
                        
                        textx = newtextx
                        
                        textstart = *grid\cells()\style()\style_end + 1
                      Next
                      ;}
                      
                    Case #Grid_Cell_Text, #Grid_Cell_TextWrap ;{- Draw normal text cell
                      height2 = grid_GetCellTextHeight2( *grid,  current_column, current_row)
                      height = grid_GetCellTextHeight( *grid,  current_column, current_row)
                      textwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
                      width = drawing_x2 - drawing_x
                      
                      If grid_IsCellSelected( *grid,  current_column, current_row)
                        selected_cell = RGBA(215,235,255,200)
                      Else
                        selected_cell = 0
                      EndIf
                      
                      ;{- Compute padding
                      If *grid\cells()\halign = #Grid_Align_Center
                        leftpadding = (drawing_x2 - drawing_x - textwidth) / 2 ; (cell width - text width) / 2
                        
                      ElseIf *grid\cells()\halign = #Grid_Align_Right
                        leftpadding = drawing_x2 - drawing_x - textwidth - *grid\cells()\ident; (cell width - text width)
                        
                      Else
                        leftpadding = *grid\cells()\ident
                      EndIf
                      
                      
                      If *grid\cells()\valign = #Grid_Align_Top
                        toppadding = 0
                      ElseIf *grid\cells()\valign = #Grid_Align_Middle
                        toppadding = (drawing_y2 - drawing_y - height) / 2
                      Else
                        toppadding = drawing_y2 - drawing_y - height
                      EndIf
                      
                      If toppadding < 0
                        toppadding = 0
                      EndIf
                      
                      If leftpadding < 0
                        leftpadding = 0
                      EndIf
                      ;}
                      ;{- Wrap text to fit in cell
                      If textwidth > width
                        ; wrap text
                        content.s = *grid\cells()\content
                        tempwidth = textwidth
                        tempcontent.s = content
                        
                        While tempwidth > width
                          *grid\cells()\content = Left(tempcontent,Len(tempcontent)-1)
                          tempcontent = *grid\cells()\content
                          tempwidth = grid_GetCellTextWidth( *grid,  current_column, current_row)
                        Wend
                        
                        *grid\cells()\content = content
                        content = tempcontent
                      Else
                        content.s = *grid\cells()\content
                      EndIf
                      ;}
                      
                      textx = drawing_x + leftpadding
                      textstart = 1
                      ForEach *grid\cells()\style()
                        fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
                        
                        If *grid\cells()\style()\fontflags & #PB_Font_Bold
                          fontkey + "B"
                        EndIf
                        If *grid\cells()\style()\fontflags & #PB_Font_Italic
                          fontkey + "I"
                        EndIf
                        
                        If FindMapElement(grids_fonts(),fontkey)
                          DrawingFont(FontID(grids_fonts()\hfont))
                        EndIf
                        
                        If selected_cell <> 0
                          cellcolor = RGBA(215,235,255,200) ! $FFFFFFFF
                          
                        Else
                          cellcolor = *grid\cells()\style()\color
                        EndIf
                        
                        
                        text.s = Mid(content,textstart, *grid\cells()\style()\style_end - textstart + 1)
                        newtextx = DrawText(textx,drawing_y + height2 - *grid\cells()\style()\fontsize/0.82 + toppadding, text, cellcolor)
                        
                        ; draw the underline
                        If *grid\cells()\style()\fontflags & #PB_Font_Underline
                          Line(textx,drawing_y + toppadding + height - 2, newtextx - textx, 1, *grid\cells()\style()\color)
                        EndIf
                        
                        ; draw the strike through
                        If *grid\cells()\style()\fontflags & #Grid_TextEdit_Font_Strikethrough
                          Line(textx,drawing_y + toppadding + height / 2, newtextx - textx, 1, *grid\cells()\style()\color)
                        EndIf
                        
                        textx = newtextx
                        
                        textstart = *grid\cells()\style()\style_end + 1
                      Next
                      ;}
                  EndSelect
                EndIf
              EndIf ;}
            EndIf
            
            current_row + 1
          Else
            Break
          EndIf
          
          drawing_y = drawing_y2
        Wend
        
        drawing_x = drawing_x2
        current_column + 1
      Else
        current_column + 1
        Break
      EndIf
      
    Wend
    *grid\xscroll_end = current_column - 1
    
    If redraw_grid
      If *grid\maxnumcols > 0 And Not *grid\header_col_hidden
        LineXY(0,21,w,21,*grid\color_linedark)
      EndIf
      
      If *grid\header_col_hidden
        drawing_y = 0
      Else
        drawing_y = *grid\header_col_height + 1
      EndIf
      current_row = *grid\yscroll
      
      ;{- Draw the rows captions + horizontal lines
      While drawing_y < h
        If current_row < *grid\maxnumrows
          
          drawing_x = rowCaptionWidth + 1
          current_column = *grid\xscroll
          indexed_current_row = *grid\row(current_row)
          
          If FindMapElement(*grid\rows(), Str(indexed_current_row))
            drawing_y2 = drawing_y + *grid\rows()\wh + 1
          Else
            drawing_y2 = drawing_y + *grid\default_row_height + 1
          EndIf
          
          row_selected.b = grid_IsRowInSelection( *grid, current_row)
          DrawingFont(FontID(*grid\font))
          
          If FindMapElement(*grid\rows(), Str(indexed_current_row))
            If *grid\rows()\visible ; don't draw
              current_row + 1
              drawing_y2 = drawing_y
              Continue
            EndIf
            
            If Not *grid\header_row_hidden
              If row_selected
                FrontColor(*grid\color_header_sel)
              Else
                FrontColor(*grid\color_header)
              EndIf
              
              Box(0,drawing_y,rowCaptionWidth,*grid\rows()\wh)
              
              If row_selected
                FrontColor(*grid\color_header_text_sel)
              Else
                FrontColor(*grid\color_header_text)
              EndIf
              
              If *grid\rows()\caption <> ""
                caption.s = *grid\rows()\caption
                wtext = *grid\rows()\wtext
              Else
                caption.s = Str(current_row + 1)
                wtext = TextWidth(caption)
              EndIf
              
              DrawText((rowCaptionWidth - wtext) / 2,drawing_y + (*grid\rows()\wh - 12) / 2, caption)
              
              LineXY(0,drawing_y + *grid\rows()\wh,rowCaptionWidth,drawing_y + *grid\rows()\wh,*grid\color_linedark)
            EndIf
            drawing_y + *grid\rows()\wh + 1
          Else
            If Not *grid\header_row_hidden
              If row_selected
                FrontColor(*grid\color_header_sel)
              Else
                FrontColor(*grid\color_header)
              EndIf
              
              Box(0,drawing_y,rowCaptionWidth,*grid\default_row_height)
              
              caption.s = Str(current_row + 1)
              
              If row_selected
                FrontColor(*grid\color_header_text_sel)
              Else
                FrontColor(*grid\color_header_text)
              EndIf
              
              DrawText((rowCaptionWidth - TextWidth(caption)) / 2,drawing_y + (*grid\default_row_height - 12) / 2, caption)
              
              LineXY(0,drawing_y + *grid\default_row_height,rowCaptionWidth,drawing_y + *grid\default_row_height,*grid\color_linedark)
            EndIf
            drawing_y + *grid\default_row_height + 1
          EndIf
          
          If Not *grid\hline
            LineXY(*grid\header_row_width,drawing_y - 1,w,drawing_y - 1,*grid\color_linelight)
          EndIf
          current_row + 1
        Else
          Break
        EndIf
        
      Wend ;}
      
      If Not *grid\header_row_hidden And *grid\maxnumcols > 0
        LineXY(rowCaptionWidth,0,rowCaptionWidth,h,*grid\color_linedark)
      EndIf
      
      ; Draw background if we've reached the end of the grid size.
      If drawing_x2 < w
        If drawing_x2 = 0 And Not *grid\header_row_hidden
          drawing_x2 = drawing_x
        EndIf
        
        Box(drawing_x2,0, w - drawing_x2, h, *grid\color_background)
      EndIf
      
      If drawing_y2 < h
        If drawing_y2 = 0
          drawing_y2 = drawing_y
        EndIf
        
        Box(0, drawing_y2, w, h - drawing_y2, *grid\color_background)
      EndIf
    EndIf
    
    ; Draw combo box button if needed
    If (*grid\edit_col > -1 Or *grid\edit_row > -1) And *grid\edit_col >= *grid\xscroll And *grid\edit_col <= *grid\xscroll_end And *grid\edit_row >= *grid\yscroll And *grid\edit_row <= *grid\yscroll_end
      If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
        If *grid\cells()\type = #Grid_Cell_Combobox_Editable
          grid_DrawCombo(*grid\edit_x, *grid\edit_x2 + 22, *grid\edit_y, *grid\edit_y2, *grid)
        EndIf
        If *grid\cells()\type = #Grid_Cell_SpinGadget
          grid_DrawSpin(*grid\edit_x, *grid\edit_x2 + 22, *grid\edit_y, *grid\edit_y2, *grid)
        EndIf
        
      EndIf
    EndIf
    
    StopDrawing()
    
    ;{- Edit Field
    If (*grid\edit_col > -1 Or *grid\edit_row > -1) And *grid\edit_col >= *grid\xscroll And *grid\edit_col <= *grid\xscroll_end And *grid\edit_row >= *grid\yscroll And *grid\edit_row <= *grid\yscroll_end
      
      If *grid\edit_dc = 0
        *grid\edit_dc = CreateImage(#PB_Any,*grid\edit_x2 - *grid\edit_x - 1, *grid\edit_y2 - *grid\edit_y - 1)
      Else
        If ImageWidth(*grid\edit_dc) <> (*grid\edit_x2 - *grid\edit_x - 1)  Or ImageHeight(*grid\edit_dc) <> (*grid\edit_y2 - *grid\edit_y  - 1)
          ResizeImage(*grid\edit_dc,*grid\edit_x2 - *grid\edit_x - 1, *grid\edit_y2 - *grid\edit_y - 1)
          grid_DoRedraw(*grid,1)
          ProcedureReturn
        EndIf
      EndIf
      StartDrawing(ImageOutput(*grid\edit_dc))
      DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
      
      Box(0,0, *grid\edit_x2 - *grid\edit_x - 1, *grid\edit_y2 - *grid\edit_y - 1,grid_GetCellBackColor( *grid, *grid\edit_col, *grid\edit_row))
      
      indexed_current_row = *grid\row(*grid\edit_row)
      indexed_current_column = *grid\col(*grid\edit_col)
      
      If FindMapElement(*grid\cells(), Str(indexed_current_column)+"x"+Str(indexed_current_row))
        If *grid\cells()\halign = #Grid_Align_Center
          textwidth = grid_GetCellTextWidth( *grid,  *grid\edit_col, *grid\edit_row)
          leftpadding = (*grid\edit_x2 - *grid\edit_x - textwidth) / 2 ; (cell width - text width) / 2
          
        ElseIf *grid\cells()\halign = #Grid_Align_Right
          textwidth = grid_GetCellTextWidth( *grid,  *grid\edit_col, *grid\edit_row)
          leftpadding = *grid\edit_x2 - *grid\edit_x - textwidth - *grid\cells()\ident ; (cell width - text width)
          
        Else
          leftpadding = *grid\cells()\ident
        EndIf
        
        xcursor = leftpadding + grid_GetWidthFromPos( *grid, *grid\edit_col,*grid\edit_row,*grid\edit_pos)
        
        ; If cell is a combo box, remove the scroll width to the x cursor pos.
        If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
          xcursor - grid_GetWidthFromPos( *grid, *grid\edit_col,*grid\edit_row,*grid\edit_combo_pos)
        EndIf
        
        height2 = grid_GetCellTextHeight2( *grid,  *grid\edit_col,*grid\edit_row)
        height = grid_GetCellTextHeight( *grid,  *grid\edit_col,*grid\edit_row)
        
        If height = 0
          height = 16 ;Int(12.0 / 0.75)
        EndIf
        
        If *grid\cells()\valign = #Grid_Align_Top
          toppadding = 0
        ElseIf *grid\cells()\valign = #Grid_Align_Middle
          toppadding = (*grid\edit_y2 - *grid\edit_y - height) / 2
        Else
          toppadding = *grid\edit_y2 - *grid\edit_y - height
        EndIf
        
        
        ; draw selection background
        If *grid\edit_selecting
          sel_start = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
          sel_end = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
          
          selstart = leftpadding + grid_GetWidthFromPos( *grid, *grid\edit_col,*grid\edit_row,sel_start)
          selend = leftpadding + grid_GetWidthFromPos( *grid, *grid\edit_col,*grid\edit_row,sel_end)
          
          ; If cell is a combo box, remove the scroll width to the selection box.
          If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_TextWrap Or *grid\cells()\type = #Grid_Cell_SpinGadget
            selstart - grid_GetWidthFromPos( *grid, *grid\edit_col,*grid\edit_row,*grid\edit_combo_pos)
            selend - grid_GetWidthFromPos( *grid, *grid\edit_col,*grid\edit_row,*grid\edit_combo_pos)
          EndIf
          
          DrawingMode(#PB_2DDrawing_AlphaBlend)
          
          ; Need to use the inverted color using formula below, but then change text color!
          Box(selstart, toppadding,selend - selstart,height, *grid\cells()\backColor ! $FFFFFFFF) ;RGBA(180,215,255,255))
          DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
          
          sel_start + 1
          sel_end + 1
        EndIf
        
        ; Draw content
        textx = leftpadding
        textstart = 1
        
        If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap ; if the cell is a combo box, wrap text and start at the position
          textstart = 1 + *grid\edit_combo_pos
        EndIf
        
        
        ForEach *grid\cells()\style()
          fontkey.s = *grid\cells()\style()\fontname+Str(*grid\cells()\style()\fontsize)
          
          If *grid\cells()\style()\fontflags & #PB_Font_Bold
            fontkey + "B"
          EndIf
          If *grid\cells()\style()\fontflags & #PB_Font_Italic
            fontkey + "I"
          EndIf
          
          If FindMapElement(grids_fonts(),fontkey)
            DrawingFont(FontID(grids_fonts()\hfont))
          EndIf
          
          If *grid\edit_selecting And sel_start <= (*grid\cells()\style()\style_end + 1)
            ; whole style is selected
            If sel_start < textstart And sel_end > (*grid\cells()\style()\style_end + 1)
              text.s = Mid(*grid\cells()\content,textstart, *grid\cells()\style()\style_end - textstart + 1)
              newtextx = DrawText(textx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\backColor)
              
            EndIf
            
            ;selection starts and ends in the style
            If sel_start > textstart And sel_end <= (*grid\cells()\style()\style_end + 1)
              ; non selected text
              text.s = Mid(*grid\cells()\content,textstart, sel_start - textstart)
              newtextx = DrawText(textx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\style()\color)
              
              ; selected text
              text.s = Mid(*grid\cells()\content,sel_start, sel_end - sel_start)
              newtextx = DrawText(newtextx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\backColor)
              
              ; non selected text
              text.s = Mid(*grid\cells()\content,sel_end, *grid\cells()\style()\style_end  - sel_end + 1)
              newtextx = DrawText(newtextx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\style()\color)
              
            EndIf
            
            ; selection starts in the style and ends after
            If sel_start >= textstart And sel_end > (*grid\cells()\style()\style_end + 1)
              ; non selected text
              text.s = Mid(*grid\cells()\content,textstart, sel_start - textstart)
              newtextx = DrawText(textx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\style()\color)
              
              ; selected text
              text.s = Mid(*grid\cells()\content,sel_start, *grid\cells()\style()\style_end - sel_start + 1)
              newtextx = DrawText(newtextx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\backColor)
              
            EndIf
            
            ; selection starts before the style and ends in the style
            If sel_start <= textstart And sel_end <= (*grid\cells()\style()\style_end + 1)
              ; selected text
              text.s = Mid(*grid\cells()\content,textstart, sel_end - textstart)
              newtextx = DrawText(textx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\backColor)
              
              ; non selected text
              text.s = Mid(*grid\cells()\content,sel_end, *grid\cells()\style()\style_end - sel_end + 1)
              newtextx = DrawText(newtextx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\style()\color)
            EndIf
            
          Else
            text.s = Mid(*grid\cells()\content,textstart, *grid\cells()\style()\style_end - textstart + 1)
            newtextx = DrawText(textx, toppadding + height2 - *grid\cells()\style()\fontsize / 0.82, text,*grid\cells()\style()\color)
          EndIf
          
          ; draw the underline
          If *grid\cells()\style()\fontflags & #PB_Font_Underline
            Line(textx,toppadding + height - 2, newtextx - textx, 1, *grid\cells()\style()\color)
          EndIf
          
          ; draw the strike through
          If *grid\cells()\style()\fontflags & #Grid_TextEdit_Font_Strikethrough
            Line(textx,toppadding + height / 2, newtextx - textx, 1, *grid\cells()\style()\color)
          EndIf
          
          textx = newtextx
          textstart = *grid\cells()\style()\style_end + 1
          DrawingFont(FontID(*grid\font))
        Next
        
        ; Draw Cursor
        If *grid\timer_edit2
          Line(xcursor, toppadding,1,height,*grid\cells()\backColor ! $FFFFFFFF)
        EndIf
      Else
        xcursor = 0
        height = Int(12.0 / 0.75) ;TODO: put the max font size of the line instead of 12
        
        ; Draw Cursor
        If *grid\timer_edit2
          Line(xcursor, 0,1,height,RGB(0,0,0))
        EndIf
      EndIf
      StopDrawing()
      
    EndIf ;}
    
    StartDrawing(CanvasOutput(*grid\canvas))
    If (*grid\edit_col > -1 Or *grid\edit_row > -1) And *grid\edit_col >= *grid\xscroll And *grid\edit_col <= *grid\xscroll_end And *grid\edit_row >= *grid\yscroll And *grid\edit_row <= *grid\yscroll_end
      DrawImage(ImageID(*grid\edit_dc),*grid\edit_x,*grid\edit_y)
    EndIf
    StopDrawing()
    
  EndIf
EndProcedure


Procedure grid_CloseCombo(*grid.Grid_Struct,keep_info = 0)
  If *grid\ac_scrollv
    FreeGadget(*grid\ac_scrollv)
    *grid\ac_scrollv = 0
  EndIf
  
  HideWindow(*grid\ac_window,1)
  *grid\ac_active = 0
  
  If keep_info = 0
    *grid\ac_col = -1
    *grid\ac_row = -1
  EndIf
  
  SetActiveWindow(*grid\hwnd)
EndProcedure

Procedure grid_RedrawComboList(*grid.Grid_Struct)
  Protected y, num, scrollv, oldgadgetlist, max, mx, my, padding
  padding = 1
  
  If *grid\ac_currentcombo
    ChangeCurrentElement(*grid\combolists(),*grid\ac_currentcombo)
    num = ListSize(*grid\combolists()\values())
    
    mx = WindowMouseX(*grid\ac_window)
    my = WindowMouseY(*grid\ac_window)
    
    If ListSize(*grid\combolists()\values()) * *grid\ac_itemheight > GadgetHeight(*grid\ac_list) ; add scrollbars
      If *grid\ac_scrollv = 0
        max = Round((num * *grid\ac_itemheight - GadgetHeight(*grid\ac_list)) / *grid\ac_itemheight,1) + 1
        
        oldgadgetlist = UseGadgetList(WindowID(*grid\ac_window))
        ResizeGadget(*grid\ac_list,#PB_Ignore,#PB_Ignore,WindowWidth(*grid\ac_window) - Grid_Scrollbar_Width,#PB_Ignore)
        *grid\ac_scrollv = ScrollBarGadget(#PB_Any,GadgetWidth(*grid\ac_list),0,Grid_Scrollbar_Width,GadgetHeight(*grid\ac_list),0,max,Int(GadgetHeight(*grid\ac_list) / (num * *grid\ac_itemheight)),#PB_ScrollBar_Vertical)
        BindGadgetEvent(*grid\ac_scrollv, @grid_ACListEvent())
        UseGadgetList(oldgadgetlist)
      EndIf
      
      scrollv = GetGadgetState(*grid\ac_scrollv)
    Else ; remove scrollbars (if they exist)
      If *grid\ac_scrollv
        FreeGadget(*grid\ac_scrollv)
        *grid\ac_scrollv = 0
      EndIf
    EndIf
    
    StartDrawing(CanvasOutput(*grid\ac_list))
    DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
    DrawingFont(FontID(*grid\ac_font))
    
    Box(0,0,OutputWidth(),OutputHeight(),RGB(255,255,255))
    
    If ListSize(*grid\combolists()\values()) > 0
      SelectElement(*grid\combolists()\values(),scrollv)
      
      Repeat
        If my >= y And my < (y + *grid\ac_itemheight) And my > -1
          Box(padding,y,OutputWidth()-padding*2,  *grid\ac_itemheight,RGB(192, 218, 255))
        EndIf
        
        
        DrawText(1+padding,y + *grid\ac_fontsize/0.82 - *grid\ac_fontsize,*grid\combolists()\values()\value,RGB(0,0,0))
        
        y + *grid\ac_itemheight
      Until NextElement(*grid\combolists()\values()) = 0
    EndIf
    
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0,0,OutputWidth(),OutputHeight(),RGB(100,100,100))
    DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_NativeText)
    
    StopDrawing()
  EndIf
EndProcedure


Procedure grid_DoKeyDownEvent(*grid.Grid_Struct, key, modifier)
  Protected col, row, row_end, row_start, col_end, col_start, i, j, cell.s, content.s, min, max, oldend, numpos, width, width_pos, width_editpos
  
  If *grid\edit_col = -1 And *grid\edit_row = -1 ; not in edit mode
    If key = #PB_Shortcut_Right Or key = #PB_Shortcut_Left Or key = #PB_Shortcut_Up Or key = #PB_Shortcut_Down Or key = #PB_Shortcut_Return Or key = #PB_Shortcut_Tab ;{-
      LastElement(*grid\sel())
      
      If modifier = #PB_Canvas_Shift
        col = *grid\sel()\sel_col_end
        row = *grid\sel()\sel_row_end
      Else
        col = *grid\sel()\sel_col
        row = *grid\sel()\sel_row
        ClearList(*grid\sel())
        AddElement(*grid\sel())
      EndIf
      
      If col < 0
        col = 0
      EndIf
      
      If row < 0
        row = 0
      EndIf
      
      If key = #PB_Shortcut_Right
        *grid\keep_pos_col = -1
        *grid\keep_pos_row = -1
        If col+1 < *grid\maxnumcols
          col + 1
        EndIf
      ElseIf key = #PB_Shortcut_Left
        *grid\keep_pos_col = -1
        *grid\keep_pos_row = -1
        col - 1
      ElseIf key = #PB_Shortcut_Up
        *grid\keep_pos_col = -1
        *grid\keep_pos_row = -1
        row - 1
      ElseIf key = #PB_Shortcut_Down
        *grid\keep_pos_col = -1
        *grid\keep_pos_row = -1
        If row+1 < *grid\maxnumrows
          row + 1
        EndIf
        
      ElseIf key = #PB_Shortcut_Return
        If *grid\keep_pos_col > -1 And *grid\keep_pos_row > -1
          ; if user has pressed tab after edit mode, return to the cell below the first edited cell.
          col = *grid\keep_pos_col
          row = *grid\keep_pos_row
          
          *grid\keep_pos_col = -1
          *grid\keep_pos_row = -1
        EndIf
        
        If row+1 < *grid\maxnumrows
          row + 1
        EndIf
      ElseIf key = #PB_Shortcut_Tab And modifier = #PB_Canvas_Shift
        If *grid\keep_pos_col = - 1 And *grid\keep_pos_row = -1
          *grid\keep_pos_col = col
          *grid\keep_pos_row = row
        EndIf
        col - 1
      ElseIf key = #PB_Shortcut_Tab
        If *grid\keep_pos_col = - 1 And *grid\keep_pos_row = -1
          *grid\keep_pos_col = col
          *grid\keep_pos_row = row
        EndIf
        col + 1
      EndIf
      
      If col < 0
        col = 0
      EndIf
      
      If row < 0
        row = 0
      EndIf
      
      If row >= *grid\maxnumrows - 1 ; last row
        row = *grid\maxnumrows - 1
        
        If col  >= *grid\maxnumcols
          col = *grid\maxnumcols - 1
        EndIf
      Else
        If col >= *grid\maxnumcols
          col = 0
          row + 1
        EndIf
      EndIf
      
      If key = #PB_Shortcut_Tab
        ClearList(*grid\sel())
        AddElement(*grid\sel())
        *grid\sel()\sel_col = col
        *grid\sel()\sel_col_end = col
        *grid\sel()\sel_row = row
        *grid\sel()\sel_row_end = row
      Else
        If modifier = #PB_Canvas_Shift
          *grid\sel()\sel_col_end = col
          *grid\sel()\sel_row_end = row
        Else
          *grid\sel()\sel_col = col
          *grid\sel()\sel_col_end = col
          *grid\sel()\sel_row = row
          *grid\sel()\sel_row_end = row
        EndIf
      EndIf
      
      If *grid\sel()\sel_row_end < *grid\yscroll ; go up
        grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Row,*grid\sel()\sel_row_end)
      ElseIf *grid\sel()\sel_row_end > *grid\yscroll_end ; go down
        grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Row,*grid\yscroll + *grid\sel()\sel_row_end - *grid\yscroll_end)
      EndIf
      
      If *grid\sel()\sel_col_end < *grid\xscroll
        grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Column,*grid\sel()\sel_col_end)
      ElseIf *grid\sel()\sel_col_end > *grid\xscroll_end
        grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Column,*grid\xscroll + *grid\sel()\sel_col_end - *grid\xscroll_end)
      EndIf
      
      If key = #PB_Shortcut_Tab
        SetActiveGadget(*grid\canvas)
      EndIf
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Selection
      
      
      ; check if row not hidden
      Repeat
        If FindMapElement(*grid\rows(),Str(*grid\row(*grid\sel()\sel_row)))
          If *grid\rows()\visible ; row is hidden
            If key = #PB_Shortcut_Up
              *grid\sel()\sel_row - 1
            Else
              *grid\sel()\sel_row + 1
            EndIf
          Else
            Break
          EndIf
        Else
          Break
        EndIf
        
        If *grid\sel()\sel_row >= *grid\maxnumrows
          Break
        EndIf
        If *grid\sel()\sel_row <= 0
          Break
        EndIf
      ForEver
      
      If *grid\sel()\sel_row_end < *grid\sel()\sel_row
        *grid\sel()\sel_row_end = *grid\sel()\sel_row
      EndIf
      ;       If *grid\sel()\sel_row > *grid\sel()\sel_row_end
      ;         *grid\sel()\sel_row = *grid\sel()\sel_row_end
      ;       EndIf
      ; end check if row not hidden
      
      *grid\redraw = #True
      ;}
    ElseIf key = #PB_Shortcut_Delete Or key = #PB_Shortcut_Back ;{-
      If *grid\disable_delete = 0
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cell
        *grid\events()\event_cell = #Grid_Event_Cell_CellsDeleted
        
        ForEach *grid\sel()
          If *grid\sel()\sel_row = -1
            row_start = 0
            row_end = *grid\numrows
          Else
            row_start = grid_Min(*grid\sel()\sel_row,*grid\sel()\sel_row_end)
            row_end = grid_Max(*grid\sel()\sel_row,*grid\sel()\sel_row_end)
          EndIf
          
          If *grid\sel()\sel_col = -1
            col_start = 0
            col_end = *grid\numcols
          Else
            col_start = grid_Min(*grid\sel()\sel_col,*grid\sel()\sel_col_end)
            col_end = grid_Max(*grid\sel()\sel_col,*grid\sel()\sel_col_end)
          EndIf
          
          For i = row_start To row_end
            For j = col_start To col_end
              cell.s = Str(*grid\col(j))+"x"+Str(*grid\row(i))
              
              If FindMapElement(*grid\cells(),cell)
                If Not *grid\cells()\locked And *grid\cells()\type <> #Grid_Cell_Checkbox And *grid\cells()\type <> #Grid_Cell_Custom
                  ClearList(*grid\cells()\style())
                  *grid\cells()\content = ""
                  *grid\redraw = #True
                  
                  AddElement(*grid\events()\event_cells())
                  *grid\events()\event_cells()\col = j
                  *grid\events()\event_cells()\row = i
                EndIf
              EndIf
            Next
          Next
        Next
      EndIf
      ;}
    EndIf
  Else ; edit mode is on
       ; if quit edit mode
    If key = #PB_Shortcut_Tab And modifier = #PB_Canvas_Shift ;{-
      ClearList(*grid\sel())
      AddElement(*grid\sel())
      
      If *grid\keep_pos_col = - 1 And *grid\keep_pos_row = -1
        *grid\keep_pos_col = *grid\edit_col
        *grid\keep_pos_row = *grid\edit_row
      EndIf
      
      If *grid\edit_col > -1 And *grid\edit_row > -1
        If *grid\edit_old_content <> grid_GetCellString(*grid,*grid\edit_col,*grid\edit_row)
          AddElement(*grid\events())
          *grid\events()\event = #Grid_Event_Cell
          *grid\events()\event_column = *grid\edit_col
          *grid\events()\event_row = *grid\edit_row
          *grid\events()\event_cell = #Grid_Event_Cell_ContentChange
        EndIf
      EndIf
      
      ; Set the selected cell at the next row
      If *grid\edit_col > 0
        *grid\sel()\sel_col = *grid\edit_col - 1
        *grid\sel()\sel_col_end = *grid\edit_col - 1
      Else
        *grid\sel()\sel_col = 0
        *grid\sel()\sel_col_end = 0
      EndIf
      
      *grid\sel()\sel_row = *grid\edit_row
      *grid\sel()\sel_row_end = *grid\edit_row
      
      *grid\edit_col = -1
      *grid\edit_row = -1
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Selection
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
      *grid\tstyle = #False
      
      SetActiveGadget(*grid\canvas)
      ;}
    ElseIf key = #PB_Shortcut_Tab ;{-
      ClearList(*grid\sel())
      AddElement(*grid\sel())
      
      If *grid\keep_pos_col = - 1 And *grid\keep_pos_row = -1
        *grid\keep_pos_col = *grid\edit_col
        *grid\keep_pos_row = *grid\edit_row
      EndIf
      
      If *grid\edit_col > -1 And *grid\edit_row > -1
        If *grid\edit_old_content <> grid_GetCellString(*grid,*grid\edit_col,*grid\edit_row)
          AddElement(*grid\events())
          *grid\events()\event = #Grid_Event_Cell
          *grid\events()\event_column = *grid\edit_col
          *grid\events()\event_row = *grid\edit_row
          *grid\events()\event_cell = #Grid_Event_Cell_ContentChange
        EndIf
      EndIf
      
      ; Set the selected cell at the next row
      If *grid\edit_col+1 < *grid\maxnumcols
        *grid\sel()\sel_col = *grid\edit_col + 1
        *grid\sel()\sel_col_end = *grid\edit_col + 1
      Else
        *grid\sel()\sel_col = *grid\edit_col
        *grid\sel()\sel_col_end = *grid\edit_col
      EndIf
      
      *grid\sel()\sel_row = *grid\edit_row
      *grid\sel()\sel_row_end = *grid\edit_row
      
      *grid\edit_col = -1
      *grid\edit_row = -1
      *grid\edit_combo_pos = 0
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Selection
      
      *grid\redraw = #True
      *grid\tstyle = #False
      
      SetActiveGadget(*grid\canvas)
      ;}
    ElseIf key = #PB_Shortcut_Return ;{-
      ClearList(*grid\sel())
      AddElement(*grid\sel())
      
      If *grid\edit_col > -1 And *grid\edit_row > -1
        If *grid\edit_old_content <> grid_GetCellString(*grid,*grid\edit_col,*grid\edit_row)
          AddElement(*grid\events())
          *grid\events()\event = #Grid_Event_Cell
          *grid\events()\event_column = *grid\edit_col
          *grid\events()\event_row = *grid\edit_row
          *grid\events()\event_cell = #Grid_Event_Cell_ContentChange
        EndIf
      EndIf
      
      If *grid\keep_pos_col > -1 And *grid\keep_pos_row > -1
        ; if user has pressed tab after edit mode, return to the cell below the first edited cell.
        *grid\sel()\sel_col = *grid\keep_pos_col
        *grid\sel()\sel_col_end = *grid\keep_pos_col
        
        If *grid\keep_pos_row + 1 < *grid\maxnumrows
          *grid\sel()\sel_row = *grid\keep_pos_row + 1
          *grid\sel()\sel_row_end = *grid\keep_pos_row + 1
        Else
          *grid\sel()\sel_row = *grid\keep_pos_row
          *grid\sel()\sel_row_end = *grid\keep_pos_row
        EndIf
        
        *grid\keep_pos_col = -1
        *grid\keep_pos_row = -1
      Else
        ; Set the selected cell at the next row
        *grid\sel()\sel_col = *grid\edit_col
        *grid\sel()\sel_col_end = *grid\edit_col
        
        
        If *grid\edit_row + 1 < *grid\maxnumrows
          *grid\sel()\sel_row = *grid\edit_row + 1
          *grid\sel()\sel_row_end = *grid\edit_row + 1
        Else
          *grid\sel()\sel_row = *grid\edit_row
          *grid\sel()\sel_row_end = *grid\edit_row
        EndIf
      EndIf
      
      ; check if row not hidden
      Repeat
        If FindMapElement(*grid\rows(),Str(*grid\row(*grid\sel()\sel_row)))
          If *grid\rows()\visible ; row is hidden
            *grid\sel()\sel_row + 1
          Else
            Break
          EndIf
        Else
          Break
        EndIf
        
        If *grid\sel()\sel_row >= *grid\maxnumrows
          Break
        EndIf
      ForEver
      
      If *grid\sel()\sel_row_end < *grid\sel()\sel_row
        *grid\sel()\sel_row_end = *grid\sel()\sel_row
      EndIf
      ; end check if row not hidden
      
      *grid\edit_col = -1
      *grid\edit_row = -1
      *grid\edit_combo_pos = 0
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Selection
      
      *grid\redraw = #True
      *grid\tstyle = #False
      ;}
    ElseIf key = #PB_Shortcut_Escape ;{-
      grid_SetCellString( *grid, *grid\edit_col,*grid\edit_row,*grid\edit_old_content)
      If FindMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
        CopyList(*grid\edit_old_style(),*grid\cells()\style())
      EndIf
      
      *grid\edit_col = -1
      *grid\edit_row = -1
      *grid\edit_combo_pos = 0
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Selection
      
      *grid\redraw = #True
      *grid\tstyle = #False
      ;}
    ElseIf key = #PB_Shortcut_End And modifier = #PB_Canvas_Shift ;{-
      *grid\keep_pos_col = - 1
      *grid\keep_pos_row = -1
      content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
      
      If Not *grid\edit_selecting
        *grid\edit_selecting = #True
        *grid\edit_sel_start = *grid\edit_pos
        *grid\edit_sel_end = *grid\edit_pos
      EndIf
      
      If *grid\edit_sel_end = *grid\edit_pos
        If *grid\edit_sel_end < Len(content)
          *grid\edit_sel_end = Len(content)
          *grid\edit_pos = *grid\edit_sel_end
        EndIf
      Else
        If *grid\edit_sel_start < Len(content)
          *grid\edit_sel_start = Len(content)
          *grid\edit_pos = *grid\edit_sel_start
        EndIf
      EndIf
      
      ; Combo box scrolling handling
      If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
        If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
          StartDrawing(ImageOutput(*grid\tempimg))
          width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
          
          If width >= (*grid\edit_x2 - *grid\edit_x)
            ; get cursor position taking into account the combo scroll position
            width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
            width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
            If width_pos >= (*grid\edit_x2 - *grid\edit_x)
              StopDrawing()
              *grid\edit_combo_pos = 0
              ; move combo scroll pos
              *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos - (*grid\edit_x2 - *grid\edit_x),*grid\edit_y + 1) + 1
            EndIf
          EndIf
          StopDrawing()
        EndIf
      EndIf
      
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Cursor
      *grid\tstyle = #False
      ;}
    ElseIf key = #PB_Shortcut_Home And modifier = #PB_Canvas_Shift ;{-
      *grid\keep_pos_col = - 1
      *grid\keep_pos_row = -1
      If Not *grid\edit_selecting
        *grid\edit_selecting = #True
        *grid\edit_sel_start = *grid\edit_pos
        *grid\edit_sel_end = *grid\edit_pos
      EndIf
      
      If *grid\edit_sel_start = *grid\edit_pos
        If *grid\edit_sel_start > 0
          *grid\edit_sel_start = 0
          *grid\edit_pos = *grid\edit_sel_start
        EndIf
      Else
        If *grid\edit_sel_end > 0
          *grid\edit_sel_end = 0
          *grid\edit_pos = *grid\edit_sel_end
        EndIf
      EndIf
      *grid\edit_combo_pos = 0
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Cursor
      *grid\tstyle = #False
      ;}
    ElseIf key = #PB_Shortcut_Home ;{-
      *grid\edit_sel_start = 0
      *grid\edit_selecting = 0
      *grid\edit_pos = 0
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
      
      ;}
    ElseIf key = #PB_Shortcut_End ;{-
      content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
      *grid\edit_sel_start = 0
      *grid\edit_selecting = 0
      *grid\edit_pos = Len(content)
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
      
      ;}
    Else
      *grid\keep_pos_col = -1
      *grid\keep_pos_row = -1
      If key = #PB_Shortcut_Left ;{-
        If modifier = #PB_Canvas_Shift Or (modifier & #PB_Canvas_Shift And modifier & #Grid_Command)
          
          If Not *grid\edit_selecting
            *grid\edit_selecting = #True
            *grid\edit_sel_start = *grid\edit_pos
            *grid\edit_sel_end = *grid\edit_pos
          EndIf
          
          If *grid\edit_sel_start = *grid\edit_pos
            If *grid\edit_sel_start > 0
              
              If modifier & #Grid_Command
                *grid\edit_sel_start = 0
              Else
                *grid\edit_sel_start - 1
              EndIf
              
              *grid\edit_pos = *grid\edit_sel_start
            EndIf
          Else
            If *grid\edit_sel_end > 0
              
              If modifier & #Grid_Command
                *grid\edit_sel_end = 0
              Else
                *grid\edit_sel_end - 1
              EndIf
              
              *grid\edit_pos = *grid\edit_sel_end
            EndIf
          EndIf
          *grid\redraw = #True
          *grid\redraw_ignore_grid = #True
          
        Else
          If *grid\edit_pos > 0
            *grid\edit_pos - 1
          EndIf
          *grid\edit_sel_start = 0
          *grid\edit_sel_end = 0
          *grid\edit_selecting = #False
          *grid\redraw = #True
          *grid\redraw_ignore_grid = #True
        EndIf
        
        ; Combo box scrolling handling
        If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
          If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
            StartDrawing(ImageOutput(*grid\tempimg))
            width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
            
            If width >= (*grid\edit_x2 - *grid\edit_x)
              ; get cursor position taking into account the combo scroll position
              width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
              width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
              
              If width_pos <= 0
                StopDrawing()
                *grid\edit_combo_pos = 0
                ; move combo scroll pos
                *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos,*grid\edit_y + 1) - 1
                
                If *grid\edit_combo_pos < 0
                  *grid\edit_combo_pos = 0
                EndIf
                
              EndIf
            EndIf
            StopDrawing()
          EndIf
        EndIf
        
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cursor
        *grid\tstyle = #False
        ;}
      ElseIf key = #PB_Shortcut_Right ;{-
        If modifier = #PB_Canvas_Shift Or (modifier & #PB_Canvas_Shift And modifier & #Grid_Command)
          content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
          
          If Not *grid\edit_selecting
            *grid\edit_selecting = #True
            *grid\edit_sel_start = *grid\edit_pos
            *grid\edit_sel_end = *grid\edit_pos
          EndIf
          
          If *grid\edit_sel_end = *grid\edit_pos
            If *grid\edit_sel_end < Len(content)
              
              If modifier & #Grid_Command
                *grid\edit_sel_end = Len(content)
              Else
                *grid\edit_sel_end + 1
              EndIf
              
              *grid\edit_pos = *grid\edit_sel_end
            EndIf
          Else
            If *grid\edit_sel_start < Len(content)
              
              If modifier & #Grid_Command
                *grid\edit_sel_start = Len(content)
              Else
                *grid\edit_sel_start + 1
              EndIf
              
              *grid\edit_pos = *grid\edit_sel_start
            EndIf
          EndIf
          *grid\redraw = #True
          *grid\redraw_ignore_grid = #True
          
        Else
          If *grid\edit_pos < Len(grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row))
            *grid\edit_pos + 1
          EndIf
          
          *grid\edit_sel_start = 0
          *grid\edit_sel_end = 0
          *grid\edit_selecting = #False
          *grid\redraw = #True
          *grid\redraw_ignore_grid = #True
        EndIf
        
        ; Combo box scrolling handling
        If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
          If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
            StartDrawing(ImageOutput(*grid\tempimg))
            width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
            
            If width >= (*grid\edit_x2 - *grid\edit_x)
              ; get cursor position taking into account the combo scroll position
              width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
              width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
              If width_pos >= (*grid\edit_x2 - *grid\edit_x)
                StopDrawing()
                *grid\edit_combo_pos = 0
                ; move combo scroll pos
                *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos - (*grid\edit_x2 - *grid\edit_x),*grid\edit_y + 1) + 1
              EndIf
            EndIf
            StopDrawing()
          EndIf
        EndIf
        
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cursor
        *grid\tstyle = #False
        ;}
      ElseIf key = #PB_Shortcut_Up ;{-
        *grid\edit_pos = 0
        *grid\edit_combo_pos = 0
        
        *grid\redraw = #True
        *grid\redraw_ignore_grid = #True
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cursor
        *grid\tstyle = #False
        ;}
      ElseIf key = #PB_Shortcut_Down ;{-
        *grid\edit_pos = Len(grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row))
        
        ; Combo box scrolling handling
        If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
          If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
            StartDrawing(ImageOutput(*grid\tempimg))
            width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
            
            If width >= (*grid\edit_x2 - *grid\edit_x)
              ; get cursor position taking into account the combo scroll position
              width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
              width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
              If width_pos >= (*grid\edit_x2 - *grid\edit_x)
                StopDrawing()
                *grid\edit_combo_pos = 0
                ; move combo scroll pos
                *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos - (*grid\edit_x2 - *grid\edit_x),*grid\edit_y + 1) + 1
              EndIf
            EndIf
            StopDrawing()
          EndIf
        EndIf
        
        *grid\redraw = #True
        *grid\redraw_ignore_grid = #True
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cursor
        *grid\tstyle = #False
        ;}
      ElseIf key = #PB_Shortcut_Back Or key = #PB_Shortcut_Delete ;{-
        content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
        
        If (*grid\edit_sel_end > 0 Or *grid\edit_sel_start > 0) And *grid\edit_sel_start <> *grid\edit_sel_end
          content = Left(content, grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)) + Right(content, Len(content) - grid_Max(*grid\edit_sel_start, *grid\edit_sel_end))
          
          min = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
          max = grid_Max(*grid\edit_sel_start, *grid\edit_sel_end)
          
          cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
          If FindMapElement(*grid\cells(),cell)
            *grid\cells()\content = content
            
            ForEach *grid\cells()\style()
              If *grid\cells()\style()\style_end >= min And *grid\cells()\style()\style_end <= max
                *grid\cells()\style()\style_end = min
              ElseIf *grid\cells()\style()\style_end >= max
                *grid\cells()\style()\style_end = *grid\cells()\style()\style_end - (max - min)
              EndIf
            Next
            
            oldend = -1
            ForEach *grid\cells()\style()
              If *grid\cells()\style()\style_end = oldend
                oldend = *grid\cells()\style()\style_end
                DeleteElement(*grid\cells()\style())
              Else
                oldend = *grid\cells()\style()\style_end
              EndIf
            Next
          EndIf
          
          *grid\edit_pos = grid_Min(*grid\edit_sel_start, *grid\edit_sel_end)
          *grid\edit_sel_end = 0
          *grid\edit_sel_start = 0
          *grid\edit_selecting = #False
        ElseIf key = #PB_Shortcut_Back And *grid\edit_pos > 0
          content = Left(content, *grid\edit_pos - 1) + Right(content, Len(content) - *grid\edit_pos)
          
          cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
          If FindMapElement(*grid\cells(),cell)
            *grid\cells()\content = content
            numpos = 0
            
            ForEach *grid\cells()\style()
              If *grid\edit_pos = *grid\cells()\style()\style_end
                numpos + 1
                
                If numpos > 1
                  DeleteElement(*grid\cells()\style())
                EndIf
              EndIf
              
              If *grid\cells()\style()\style_end >= *grid\edit_pos
                *grid\cells()\style()\style_end - 1
              EndIf
            Next
          EndIf
          
          *grid\edit_pos - 1
          
          ; Combo box scrolling handling
          If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
            If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
              StartDrawing(ImageOutput(*grid\tempimg))
              width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
              
              If width >= (*grid\edit_x2 - *grid\edit_x)
                ; get cursor position taking into account the combo scroll position
                width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
                width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
                
                If width_pos <= 0
                  StopDrawing()
                  *grid\edit_combo_pos = 0
                  ; move combo scroll pos
                  *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos,*grid\edit_y + 1) - 1
                  If *grid\edit_combo_pos < 0
                    *grid\edit_combo_pos = 0
                  EndIf
                  
                EndIf
              Else
                *grid\edit_combo_pos = 0
              EndIf
              StopDrawing()
            EndIf
          EndIf
          
        ElseIf key = #PB_Shortcut_Delete And *grid\edit_pos < Len(content)
          content = Left(content, *grid\edit_pos) + Right(content, Len(content) - *grid\edit_pos - 1)
          
          cell.s = Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row))
          If FindMapElement(*grid\cells(),cell)
            *grid\cells()\content = content
            
            ForEach *grid\cells()\style()
              If *grid\cells()\style()\style_end > *grid\edit_pos
                *grid\cells()\style()\style_end - 1
              EndIf
            Next
          EndIf
        EndIf
        
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cursor
        *grid\redraw = #True
        *grid\redraw_ignore_grid = #True
        *grid\tstyle = #False
        ;}
      EndIf
    EndIf
  EndIf
  
  SetActiveGadget(*grid\canvas)
EndProcedure

Procedure grid_DoLeftButtonDownEvent(*grid.Grid_Struct, mousex, mousey, rightbutton.b = 0)
  Protected  content.s, col, row, pos, left.s, right.s, rpos, rpospadding, lpos, to_i, i, grids_dblclick2.q, ok, grid.s, cellcombo.s, combo_y, combo_x
  
  *grid\keep_pos_col = -1
  *grid\keep_pos_row = -1
  
  If Not rightbutton
    *grid\lbuttondown = 1
    grids_dblclick2.q = ElapsedMilliseconds()
  EndIf
  
  
  If *grid\edit_col > -1 And *grid\edit_row > -1 And mousex > *grid\edit_x And mousex < *grid\edit_x2 And mousey > *grid\edit_y And mousey < *grid\edit_y2
    ; mouse inside the editing area
    content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
    
    *grid\edit_pos = grid_GetEditPosFromMouse( *grid,  *grid\edit_col, *grid\edit_row, mousex, mousey)
    *grid\edit_sel_start = *grid\edit_pos
    *grid\edit_sel_end = *grid\edit_pos
    *grid\edit_selecting = #True
    *grid\redraw = #True
    *grid\redraw_ignore_grid = #True
    *grid\tstyle = #False
    
    AddElement(*grid\events())
    *grid\events()\event = #Grid_Event_Cursor
  Else
    If *grid\edit_col > -1 And *grid\edit_row > -1
      If *grid\edit_old_content <> grid_GetCellString(*grid,*grid\edit_col,*grid\edit_row)
        AddElement(*grid\events())
        *grid\events()\event = #Grid_Event_Cell
        *grid\events()\event_column = *grid\sel()\sel_col
        *grid\events()\event_row = *grid\sel()\sel_row
        *grid\events()\event_cell = #Grid_Event_Cell_ContentChange
      EndIf
    EndIf
    
    *grid\edit_col = -1
    *grid\edit_row = -1
    *grid\edit_combo_pos = 0
    
    *grid\edit_selecting = #False
    *grid\redraw = #True
    *grid\tstyle = #False
    
    AddElement(*grid\events())
    *grid\events()\event = #Grid_Event_Selection
  EndIf
  
  
  If *grid\resize_col <> -1 Or *grid\resize_row <> -1
    *grid\resizing = #True
    
  ElseIf (*grid\edit_col = -1 And *grid\edit_row = -1)
    *grid\cell_selected.s = grid_GetCurrentCell(*grid,mousex,mousey)
    col = Val(StringField(*grid\cell_selected, 1, "x"))
    row = Val(StringField(*grid\cell_selected, 2, "x"))
    
    If GetGadgetAttribute(*grid\canvas,#PB_Canvas_Modifiers) = #Grid_Command
      LastElement(*grid\sel())
      AddElement(*grid\sel())
    ElseIf GetGadgetAttribute(*grid\canvas,#PB_Canvas_Modifiers) = #PB_Canvas_Shift
      LastElement(*grid\sel())
    ElseIf  col = -2 And row = -2
      LastElement(*grid\sel())
    Else
      ClearList(*grid\sel())
      AddElement(*grid\sel())
    EndIf
    
    
    If col > -2 And row > -2
      If GetGadgetAttribute(*grid\canvas,#PB_Canvas_Modifiers) = #PB_Canvas_Shift
        *grid\sel()\sel_col_end = col
        *grid\sel()\sel_row_end = row
      Else
        *grid\sel()\sel_col = col
        *grid\sel()\sel_col_end = col
        *grid\sel()\sel_row = row
        *grid\sel()\sel_row_end = row
      EndIf
      
      *grid\redraw = #True
    EndIf
    
    
    cellcombo.s = grid_GetCurrentCellCombo(*grid,GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseX),GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseY))
    col = Val(StringField(cellcombo, 1, "x"))
    row = Val(StringField(cellcombo, 2, "x"))
    If col > -1 And row > -1
      If FindMapElement(*grid\cells(),Str(*grid\col(col))+"x"+Str(*grid\row(row)))
        If *grid\cells()\type = #Grid_Cell_SpinGadget
          combo_y = Val(StringField(cellcombo, 6, "x"))
          combo_x = Val(StringField(cellcombo, 4, "x"))
          If mousey < (combo_y + (combo_x - combo_y) / 2)
            grid_SetCellString(*grid, col, row, Str(Val(grid_GetCellString(*grid, col, row)) + 1))
          Else
            grid_SetCellString(*grid, col, row, Str(Val(grid_GetCellString(*grid, col, row)) - 1))
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndIf
  
  If grids_dblclick2 - grids_dblclick < DoubleClickTime() And mousex = *grid\oldmousex And mousey = *grid\oldmousey
    grid.s = grid_GetCurrentCell( *grid,  mousex, mousey)
    col = Val(StringField(grid,1,"x"))
    row = Val(StringField(grid,2,"x"))
    AddElement(*grid\events())
    *grid\events()\event = #Grid_Event_Cell
    *grid\events()\event_column = col
    *grid\events()\event_row = row
    *grid\events()\event_cell = #Grid_Event_Cell_LeftDblClick
    
    If grid_GetCellType(*grid,col,row) = #Grid_Cell_Custom
      *grid\lbuttondown = 0
      *grid\cell_selected = ""
      *grid\cell_selected_move = ""
    EndIf
    
    If *grid\edit_col > -1 And *grid\edit_row > -1 ; is editing?
                                                   ; select the word under the mouse
      content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
      pos = grid_GetEditPosFromMouse( *grid,  *grid\edit_col, *grid\edit_row, mousex, mousey)
      
      left.s = Left(content, pos)
      
      rpospadding = Len(left)
      right.s = Right(content, Len(content) - pos)
      
      to_i = CountString(left," ")
      For i = 1 To to_i
        lpos = FindString(left," ",lpos+1)
      Next
      
      rpos = FindString(right," ") - 1
      If rpos < 0
        rpos = Len(content)
      Else
        rpos + rpospadding
      EndIf
      
      *grid\edit_sel_start = lpos
      *grid\edit_sel_end = rpos
      *grid\edit_pos = rpos
      *grid\edit_selecting = #True
      
      AddElement(*grid\events())
      *grid\events()\event = #Grid_Event_Cursor
      
      *grid\tstyle = #False
      
      *grid\redraw = #True
      *grid\redraw_ignore_grid = #True
      
    Else ; if editing is off, and mouse over the grid
      If mousey > *grid\header_col_height And mousex > *grid\header_row_width
        If grid_GetCurrentCell(*grid,mousex,mousey) <> "-2x-2"
          LastElement(*grid\sel())
          
          If *grid\sel()\sel_col > -1 And *grid\sel()\sel_row > -1
            ; ensure the cell isn't locked.
            If Not grid_GetCellLockState(*grid,  *grid\sel()\sel_col, *grid\sel()\sel_row)
              ; don't launch the edit mode if cell is not a standard cell
              ok = #True
              If FindMapElement(*grid\cells(),Str(*grid\col(*grid\sel()\sel_col))+"x"+Str(*grid\row(*grid\sel()\sel_row)))
                Select *grid\cells()\type
                  Case #Grid_Cell_Checkbox, #Grid_Cell_Combobox, #Grid_Cell_Custom
                    ok = #False
                  Case #Grid_Cell_SpinGadget ; don't get into edit mode if dbl click on spin button
                    cellcombo.s = grid_GetCurrentCellCombo(*grid,GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseX),GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseY))
                    If Val(StringField(cellcombo, 1, "x")) > -1 And Val(StringField(cellcombo, 2, "x")) > -1
                      If mousex > Val(StringField(cellcombo, 5, "x")) - 22
                        ok = #False
                      EndIf
                    EndIf
                    
                EndSelect
              EndIf
              
              If ok
                *grid\edit_col = *grid\sel()\sel_col
                *grid\edit_row = *grid\sel()\sel_row
                
                If *grid\numcols < *grid\edit_col
                  *grid\numcols = *grid\edit_col
                EndIf
                If *grid\numrows < *grid\edit_row
                  *grid\numrows = *grid\edit_row
                EndIf
                
                ; scroll if the cell is not entirely visible
                If *grid\edit_col > *grid\xscroll_end And *grid\edit_col < (*grid\maxnumcols - 1)
                  grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Column,*grid\xscroll + 1)
                  grid_DoRedraw(*grid)
                EndIf
                If *grid\edit_row >= *grid\yscroll_end And *grid\edit_row < (*grid\maxnumrows - 1)
                  grid_SetGadgetAttribute( *grid, #Grid_Scrolling_Row,*grid\yscroll + 1)
                  grid_DoRedraw(*grid)
                EndIf
                
                content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
                
                If FindMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
                  CopyList(*grid\cells()\style(),*grid\edit_old_style())
                EndIf
                
                If content = ""
                  If Not FindMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
                    AddMapElement(*grid\cells(),Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
                    *grid\cells()\backColor = *grid\color_background
                  EndIf
                  
                  If ListSize(*grid\cells()\style()) <> 1
                    ClearList(*grid\cells()\style())
                    AddElement(*grid\cells()\style())
                    *grid\cells()\style()\color = *grid\dfontcolor
                    *grid\cells()\style()\fontname = *grid\dfont
                    *grid\cells()\style()\fontsize = *grid\dfontsize
                    *grid\cells()\style()\style_end = 0
                  Else
                    LastElement(*grid\cells()\style())
                    *grid\cells()\style()\style_end = 0
                  EndIf
                  
                EndIf
                grid_DoRedraw( *grid )
                
                *grid\edit_pos = grid_GetEditPosFromMouse( *grid,  *grid\edit_col, *grid\edit_row, mousex, mousey)
                *grid\edit_sel_end = 0
                *grid\edit_sel_start = 0
                *grid\edit_combo_pos = 0
                
                *grid\edit_old_content = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
                AddElement(*grid\events())
                *grid\events()\event = #Grid_Event_Cursor
                *grid\tstyle = #False
                
                *grid\redraw = #True
                *grid\redraw_ignore_grid = #True
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
    If Not rightbutton
      grids_dblclick = 0
    EndIf
  Else
    If Not rightbutton
      grids_dblclick = grids_dblclick2
    EndIf
  EndIf
  
  
  LastElement(*grid\sel())
  *grid\oldmousex = mousex
  *grid\oldmousey = mousey
EndProcedure

Procedure grid_DoMouseMoveEvent(*grid.Grid_Struct, mousex, mousey)
  Protected cell.s, content.s, newpos, sel_col_end, sel_row_end, new_pos, cursor, width, width_pos, width_editpos
  
  If *grid\cell_selected <> "" ; Cell selection
    cell.s = grid_GetCurrentCell(*grid,mousex,mousey)
    
    If *grid\cell_selected_move = ""
      *grid\cell_selected_move = cell
    EndIf
    
    If ((cell <> *grid\cell_selected And cell <> *grid\cell_selected_move) Or (cell = *grid\cell_selected And *grid\cell_selected <> *grid\cell_selected_move)) And cell <> ""
      ; go to the last selected block
      LastElement(*grid\sel())
      *grid\cell_selected_move = cell
      
      If *grid\sel()\sel_col_end > -1
        sel_col_end = Val(StringField(*grid\cell_selected_move, 1, "x"))
        If sel_col_end > -1
          *grid\sel()\sel_col_end = sel_col_end
        EndIf
      EndIf
      
      If *grid\sel()\sel_row_end > -1
        sel_row_end = Val(StringField(*grid\cell_selected_move, 2, "x"))
        If sel_row_end > -1
          *grid\sel()\sel_row_end = sel_row_end
        EndIf
      EndIf
      
      *grid\redraw = #True
    EndIf
  ElseIf *grid\resizing ; Column or Row resizing
    If *grid\resize_col <> -1
      *grid\resize_posy = mousex
      
      If *grid\resize_posy >= *grid\innerwidth - 2
        *grid\resize_posy = *grid\innerwidth - 2
      ElseIf *grid\resize_posy <= *grid\resize_posx
        *grid\resize_posy = *grid\resize_posx + 1
      EndIf
      
      grid_SetColumnWidth( *grid,  *grid\resize_col, *grid\resize_posy - *grid\resize_posx)
    ElseIf *grid\resize_row <> -1
      *grid\resize_posy = mousey
      
      If *grid\resize_posy >= *grid\innerheight - 2
        *grid\resize_posy = *grid\innerheight - 2
      ElseIf *grid\resize_posy <= *grid\resize_posx
        *grid\resize_posy = *grid\resize_posx + 1
      EndIf
      grid_SetRowHeight( *grid,  *grid\resize_row, *grid\resize_posy - *grid\resize_posx)
    EndIf
    
    grid_BuildScrollbarSize(*grid)
    *grid\redraw = #True
  Else
    ; Selection in edit box
    If *grid\edit_col > -1 And *grid\edit_row > -1 And *grid\edit_selecting = #True And *grid\lbuttondown
      content.s = grid_GetCellString( *grid, *grid\edit_col,*grid\edit_row)
      new_pos = grid_GetEditPosFromMouse( *grid,  *grid\edit_col, *grid\edit_row, mousex, mousey)
      
      If new_pos <> *grid\edit_pos
        *grid\edit_pos = new_pos
        *grid\edit_sel_end = *grid\edit_pos
        
        ; Combo box scrolling handling
        If FindMapElement(*grid\cells(), Str(*grid\col(*grid\edit_col))+"x"+Str(*grid\row(*grid\edit_row)))
          If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_SpinGadget Or *grid\cells()\type = #Grid_Cell_TextWrap
            StartDrawing(ImageOutput(*grid\tempimg))
            width = grid_GetCellTextWidth(*grid, *grid\edit_col, *grid\edit_row)
            
            If width >= (*grid\edit_x2 - *grid\edit_x)
              ; get cursor position taking into account the combo scroll position
              width_editpos = grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_pos)
              width_pos = width_editpos - grid_GetWidthFromPos(*grid, *grid\edit_col, *grid\edit_row,*grid\edit_combo_pos)
              If width_pos >= (*grid\edit_x2 - *grid\edit_x - 2)
                StopDrawing()
                *grid\edit_combo_pos = 0
                ; move combo scroll pos
                *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos - (*grid\edit_x2 - *grid\edit_x),*grid\edit_y + 1) + 1
              EndIf
              If width_pos <= 2
                StopDrawing()
                *grid\edit_combo_pos = 0
                ; move combo scroll pos
                *grid\edit_combo_pos = grid_GetEditPosFromMouse(*grid,*grid\edit_col, *grid\edit_row,*grid\edit_x + width_editpos,*grid\edit_y + 1) - 1
                
                If *grid\edit_combo_pos < 0
                  *grid\edit_combo_pos = 0
                EndIf
                
              EndIf
            EndIf
            StopDrawing()
          EndIf
        EndIf
        
        *grid\redraw = #True
        *grid\redraw_ignore_grid = #True
      EndIf
      ; No mouse button down: change mouse cursor if required
    ElseIf *grid\edit_col > -1 And *grid\edit_row > -1
      If mousex > *grid\edit_x And mousex < *grid\edit_x2 And mousey > *grid\edit_y And mousey < *grid\edit_y2
        If *grid\cursor <> #PB_Cursor_IBeam
          SetGadgetAttribute(*grid\canvas,#PB_Canvas_Cursor,#PB_Cursor_IBeam)
          *grid\cursor = #PB_Cursor_IBeam
          cursor = #True
        EndIf
      Else
        *grid\cursor = #PB_Cursor_Default
        SetGadgetAttribute(*grid\canvas,#PB_Canvas_Cursor,#PB_Cursor_Default)
      EndIf
    Else
      grid_DoHoverEvent( *grid,  mousex, mousey)
    EndIf
  EndIf
EndProcedure

Procedure grid_DoLeftButtonUpEvent(*grid.Grid_Struct, mousex, mousey)
  Protected cell.s, cellcombo.s, sel_col_end, sel_row_end, col, row, combo_x, combo_y, combo_w, icombo, colx
  
  *grid\lbuttondown = 0
  
  If *grid\edit_selecting And *grid\edit_sel_end = *grid\edit_sel_start
    *grid\edit_selecting = #False
    *grid\redraw = #True
    *grid\redraw_ignore_grid = #True
  EndIf
  
  If *grid\resizing
    *grid\resizing = #False
  EndIf
  
  cell.s = grid_GetCurrentCell(*grid,GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseX),GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseY))
  
  If *grid\cell_selected_move = ""
    *grid\cell_selected_move = cell
  EndIf
  
  ; Grid button
  If mousey < *grid\header_col_height
    col = Val(StringField(cell, 1, "x"))
    row = Val(StringField(cell, 2, "x"))
    
    If col > -1 And FindMapElement(*grid\cols(),Str(*grid\col(col)))
      If *grid\cols()\buttonid
        colx = Val(StringField(cell, 3, "x"))
        
        If mousex > colx + (*grid\cols()\wh - 17)
          AddElement(*grid\events())
          *grid\events()\event = #Grid_Event_Column_ButtonClick
          *grid\events()\event_column = col
          *grid\events()\event_row = row
        EndIf
      EndIf
    EndIf
  EndIf
  
  
  ; If cell is a combo box, check if user clicks on the combo button
  cellcombo.s = grid_GetCurrentCellCombo(*grid,GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseX),GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseY))
  col = Val(StringField(cellcombo, 1, "x"))
  row = Val(StringField(cellcombo, 2, "x"))
  If col > -1 And row > -1
    If FindMapElement(*grid\cells(),Str(*grid\col(col))+"x"+Str(*grid\row(row)))
      If *grid\cells()\type = #Grid_Cell_Combobox_Editable Or *grid\cells()\type = #Grid_Cell_Combobox
        combo_x = Val(StringField(cellcombo, 3, "x")) + *grid\x + grids_gs_windowmousedx + grid_deltagadgetposx
        combo_y = Val(StringField(cellcombo, 4, "x")) + *grid\y + grids_gs_windowmousedy + grid_deltagadgetposy
        combo_w = Val(StringField(cellcombo, 5, "x")) - Val(StringField(cellcombo, 3, "x"))
        
        ResizeWindow(*grid\ac_window, combo_x,combo_y,combo_w,200)
        ResizeGadget(*grid\ac_list, 0,0,combo_w,200)
        
        ; do not display combobox as the click happened on a combobox already opened.
        If *grid\ac_row = row And *grid\ac_col = col And *grid\ac_row <> -1 And *grid\ac_col <> -1
          *grid\ac_row = -1
          *grid\ac_col = -1
        Else
          If *grid\ac_active = 0
            HideWindow(*grid\ac_window,0)
          EndIf
          
          StickyWindow(*grid\ac_window,1)
          SetActiveWindow(*grid\ac_window)
          
          *grid\ac_active = 1
          *grid\ac_row = row
          *grid\ac_col = col
          ; internal combo box list is stored in the state param of the cell
          If *grid\cells()\state <> 0
            ChangeCurrentElement(*grid\combolists(),*grid\cells()\state)
            icombo = 0
            *grid\ac_currentcombo = *grid\cells()\state
          EndIf
          
          grid_RedrawComboList(*grid)
        EndIf
      EndIf
    EndIf
  EndIf
  
  If ((cell <> *grid\cell_selected And cell <> *grid\cell_selected_move) Or (cell = *grid\cell_selected And *grid\cell_selected <> *grid\cell_selected_move)) And cell <> ""
    ; go to the last selected block
    LastElement(*grid\sel())
    
    If *grid\sel()\sel_col_end <> -1
      sel_col_end = Val(StringField(cell, 1, "x"))
      
      If sel_col_end > -1
        *grid\sel()\sel_col_end = sel_col_end
      EndIf
    EndIf
    
    If *grid\sel()\sel_row_end <> -1
      sel_row_end = Val(StringField(cell, 2, "x"))
      
      If sel_row_end > -1
        *grid\sel()\sel_row_end = sel_row_end
      EndIf
      
    EndIf
    
    *grid\redraw = #True
  EndIf
  *grid\cell_selected = ""
  *grid\cell_selected_move = ""
  
EndProcedure

Procedure grid_DoCheckboxEvent(*grid.Grid_Struct, mousex, mousey)
  Protected cell.s, col, row
  
  If mousey > *grid\header_col_height And mousex > *grid\header_row_width
    cell.s = grid_GetCurrentCell(*grid,GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseX),GetGadgetAttribute(*grid\canvas,#PB_Canvas_MouseY))
    If cell <> "-2x-2"
      col = Val(StringField(cell, 1, "x"))
      row = Val(StringField(cell, 2, "x"))
      
      If col > -1 And row > -1
        If Not grid_GetCellLockState(*grid,  col, row)
          If FindMapElement(*grid\cells(),Str(*grid\col(col))+"x"+Str(*grid\row(row)))
            If *grid\cells()\type = #Grid_Cell_Checkbox
              
              If *grid\cells()\state = 0
                *grid\cells()\state = 1
              Else
                *grid\cells()\state = 0
              EndIf
              
              *grid\redraw = #True
              
              AddElement(*grid\events())
              *grid\events()\event = #Grid_Event_Cell
              *grid\events()\event_column = *grid\sel()\sel_col
              *grid\events()\event_row = *grid\sel()\sel_row
              *grid\events()\event_cell = #Grid_Event_Cell_ContentChange
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure grid_FirstSelectionRange(*grid.Grid_Struct)
  *grid\selectionrange = -1
EndProcedure

Procedure grid_NextSelectionRange(*grid.Grid_Struct)
  Protected result
  
  If *grid\selectionrange = -1
    result = FirstElement(*grid\sel())
  Else
    result = NextElement(*grid\sel())
  EndIf
  If result
    *grid\selectionrange = *grid\sel()
  Else
    *grid\selectionrange = -1
  EndIf
  
  ProcedureReturn result
EndProcedure
Procedure.s grid_GetSelectionRange(*grid.Grid_Struct)
  ChangeCurrentElement( *grid\sel(), *grid\selectionrange)
  
  ProcedureReturn Str(*grid\sel()\sel_col)+","+Str(*grid\sel()\sel_col_end)+"x"+Str(*grid\sel()\sel_row)+","+Str(*grid\sel()\sel_row_end)
EndProcedure

Procedure grid_SetCellSelection(*grid.Grid_Struct, col, col_end, row, row_end)
  ClearList(*grid\sel())
  
  AddElement(*grid\sel())
  *grid\sel()\sel_col = col
  *grid\sel()\sel_col_end = col_end
  *grid\sel()\sel_row = row
  *grid\sel()\sel_row_end = row_end
  *grid\redraw = #True
  
EndProcedure
Procedure grid_AddCellSelection(*grid.Grid_Struct, col, col_end, row, row_end)
  AddElement(*grid\sel())
  *grid\sel()\sel_col = col
  *grid\sel()\sel_col_end = col_end
  *grid\sel()\sel_row = row
  *grid\sel()\sel_row_end = row_end
  *grid\redraw = #True
  
EndProcedure

Procedure grid_EventEditingRow(*grid.Grid_Struct)
  ProcedureReturn *grid\edit_row
EndProcedure

Procedure grid_EventEditingColumn(*grid.Grid_Struct)
  ProcedureReturn *grid\edit_col
EndProcedure

Procedure grid_EventEditing(*grid.Grid_Struct)
  If *grid And *grid\edit_col > -1 And *grid\edit_row > -1
    ProcedureReturn #True
  EndIf
  
  ProcedureReturn #False
EndProcedure

Procedure grid_EventColumn(*grid.Grid_Struct)
  Protected col.i
  If *grid\c_event_cell = #Grid_Event_Cell_CellsDeleted
    If *grid\c_event_index_cells > -1
      SelectElement(*grid\c_event_cells(),*grid\c_event_index_cells)
      col = *grid\c_event_cells()\col
      ProcedureReturn  col
    Else
      ProcedureReturn -2
    EndIf
  Else
    col = *grid\c_event_column
    ProcedureReturn col
  EndIf
EndProcedure

Procedure grid_EventRow(*grid.Grid_Struct)
  Protected row.i
  
  If *grid\c_event_cell = #Grid_Event_Cell_CellsDeleted
    If *grid\c_event_index_cells > -1
      SelectElement(*grid\c_event_cells(),*grid\c_event_index_cells)
      row = *grid\c_event_cells()\row
      ProcedureReturn row
    Else
      ProcedureReturn -2
    EndIf
  Else
    row = *grid\c_event_row
    ProcedureReturn row
  EndIf
EndProcedure

Procedure grid_EventType(*grid.Grid_Struct)
  ProcedureReturn *grid\c_event_cell
EndProcedure

Procedure grid_EventNextCell(*grid.Grid_Struct)
  If *grid\c_event_index_cells < (ListSize(*grid\c_event_cells()) - 1)
    *grid\c_event_index_cells + 1
    ProcedureReturn 1
  Else
    *grid\c_event_index_cells = -1
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure grid_EventFirstCell(*grid.Grid_Struct)
  *grid\c_event_index_cells = -1
EndProcedure

; BindEvent procedures
Procedure grid_ACListEvent()
  Protected gadget
  Protected pos
  
  gadget = EventGadget()
  
  ForEach grid_grids()
    If gadget = grid_grids()\ac_scrollv
      grid_RedrawComboList(grid_grids())
    EndIf
    
    If gadget = grid_grids()\ac_list
      Select EventType()
        Case #PB_EventType_LeftClick
          pos = Int(WindowMouseY(grid_grids()\ac_window) / grid_grids()\ac_itemheight)
          
          If grid_grids()\ac_scrollv
            pos + GetGadgetState(grid_grids()\ac_scrollv)
          EndIf
          
          If pos < ListSize(grid_grids()\combolists()\values())
            SelectElement(grid_grids()\combolists()\values(), pos)
            
            If Not grid_GetCellLockState(grid_grids(),  grid_grids()\ac_col,grid_grids()\ac_row)
              grid_SetCellString(grid_grids(),grid_grids()\ac_col,grid_grids()\ac_row,grid_grids()\combolists()\values()\value)
              grid_SetCellData(grid_grids(),grid_grids()\ac_col,grid_grids()\ac_row,grid_grids()\combolists()\values()\c_data)
              
              AddElement(grid_grids()\events())
              grid_grids()\events()\event = #Grid_Event_Cell
              grid_grids()\events()\event_column = grid_grids()\ac_col
              grid_grids()\events()\event_row = grid_grids()\ac_row
              grid_grids()\events()\event_cell = #Grid_Event_Cell_ContentChange
            EndIf
          EndIf
          
          grid_CloseCombo(grid_grids())
          
        Case #PB_EventType_KeyDown
          Select GetGadgetAttribute(grid_grids()\ac_list,#PB_Canvas_Key)
            Case #PB_Shortcut_Tab
              
            Case #PB_Shortcut_Escape
              grid_CloseCombo(grid_grids())
            Case #PB_Shortcut_Up
              
            Case #PB_Shortcut_Down
              
          EndSelect
          
        Case #PB_EventType_MouseWheel
          If grid_grids()\ac_scrollv
            SetGadgetState(grid_grids()\ac_scrollv,GetGadgetState(grid_grids()\ac_scrollv) - GetGadgetAttribute(grid_grids()\ac_list,#PB_Canvas_WheelDelta))
            grid_RedrawComboList(grid_grids())
          EndIf
        Case #PB_EventType_MouseMove
          grid_RedrawComboList(grid_grids())
        Case #PB_EventType_MouseLeave
          grid_RedrawComboList(grid_grids())
      EndSelect
      
    EndIf
  Next
  
EndProcedure

Procedure grid_CanvasEvent()
  Protected gadget
  Protected char, key, modifier, firstcell_row, firstcell_col, mousex, mousey, grid.s, col, row, scroll
  
  gadget = EventGadget()
  
  ForEach grid_grids()
    If gadget = grid_grids()\canvas
      mousex = grid_NewWindowMouseX(grid_grids()\hwnd) - grid_grids()\x - grid_deltagadgetposx
      mousey = grid_NewWindowMouseY(grid_grids()\hwnd) - grid_grids()\y - grid_deltagadgetposy
      
      ; alter the mouse position in case the parent of the grid gadget is not the window, so that the mouse position is relative to the gadget
      If GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_MouseX) > -1 And WindowMouseX(grid_grids()\hwnd) > -1
        grid_deltagadgetposx = WindowMouseX(grid_grids()\hwnd) - GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_MouseX) - grid_grids()\x
      EndIf
      
      If GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_MouseY) > -1 And WindowMouseY(grid_grids()\hwnd) > -1
        grid_deltagadgetposy = WindowMouseY(grid_grids()\hwnd) - GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_MouseY) - grid_grids()\y
      EndIf
      
      Select EventType()
        Case #PB_EventType_Input
          grid_CloseCombo(grid_grids())
          char = GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_Input)
          
          If char > 31
            grid_DoEditFieldEvent( grid_grids(), char)
          EndIf
          
        Case #PB_EventType_KeyDown
          grid_CloseCombo(grid_grids())
          key = GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_Key)
          modifier = GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_Modifiers)
          
          grid_DoKeyDownEvent( grid_grids(),  key, modifier)
          
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_KeyDown
          grid_GetLastCellSelected(grid_grids(), @firstcell_row, @firstcell_col)
          grid_grids()\events()\event_column = firstcell_col
          grid_grids()\events()\event_row = firstcell_row
          grid_grids()\events()\event_cell = key
          
        Case #PB_EventType_LeftButtonDown
          grid_CloseCombo(grid_grids(), 1)
          grid_DoLeftButtonDownEvent( grid_grids(),  mousex, mousey)
          
          grid.s = grid_GetCurrentCell( grid_grids(),  mousex, mousey)
          col = Val(StringField(grid,1,"x"))
          row = Val(StringField(grid,2,"x"))
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_Cell
          grid_grids()\events()\event_column = col
          grid_grids()\events()\event_row = row
          grid_grids()\events()\event_cell = #Grid_Event_Cell_LeftButtonDown
          
        Case #PB_EventType_LeftClick
          grid_DoCheckboxEvent( grid_grids(),  mousex, mousey)
          
        Case #PB_EventType_MouseMove
          grid_DoMouseMoveEvent( grid_grids(),  mousex, mousey)
          
        Case #PB_EventType_LeftButtonUp
          ;grid_CloseCombo(*grid,0)
          grid_DoLeftButtonUpEvent( grid_grids(),  mousex, mousey)
          
          ; Send an event notification
          grid.s = grid_GetCurrentCell( grid_grids(),  mousex, mousey)
          col = Val(StringField(grid,1,"x"))
          row = Val(StringField(grid,2,"x"))
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_Cell
          grid_grids()\events()\event_column = col
          grid_grids()\events()\event_row = row
          grid_grids()\events()\event_cell = #Grid_Event_Cell_LeftButtonUp
          
        Case #PB_EventType_RightButtonDown
          grid_CloseCombo(grid_grids())
          grid.s = grid_GetCurrentCell(grid_grids(), mousex, mousey)
          col = Val(StringField(grid,1,"x"))
          row = Val(StringField(grid,2,"x"))
          
          If grid_IsCellSelected(grid_grids(), col, row) = 0
            ClearList(grid_grids()\sel())
            AddElement(grid_grids()\sel())
            
            If col > -2 And row > -2
              grid_grids()\sel()\sel_col = col
              grid_grids()\sel()\sel_col_end = col
              grid_grids()\sel()\sel_row = row
              grid_grids()\sel()\sel_row_end = row
              grid_grids()\redraw = #True
            EndIf
          EndIf
          
          ; Send an event notification
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_Cell
          grid_grids()\events()\event_column = col
          grid_grids()\events()\event_row = row
          grid_grids()\events()\event_cell = #Grid_Event_Cell_RightButtonDown
          
        Case #PB_EventType_RightButtonUp
          grid_CloseCombo(grid_grids())
          ; Send an event notification
          grid.s = grid_GetCurrentCell( grid_grids(), mousex, mousey)
          col = Val(StringField(grid,1,"x"))
          row = Val(StringField(grid,2,"x"))
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_Cell
          grid_grids()\events()\event_column = col
          grid_grids()\events()\event_row = row
          grid_grids()\events()\event_cell = #Grid_Event_Cell_RightButtonUp
          
        Case #PB_EventType_MouseWheel
          grid_CloseCombo(grid_grids())
          If grid_grids()\resizing = #False
            scroll = grid_grids()\yscroll + (-3 * GetGadgetAttribute(grid_grids()\canvas,#PB_Canvas_WheelDelta))
            
            If scroll < 0
              scroll = 0
            EndIf
            
            If scroll > grid_grids()\maxnumrows-1
              scroll = grid_grids()\maxnumrows-1
            EndIf
            
            grid_SetGadgetAttribute( grid_grids(), #Grid_Scrolling_Row,scroll)
            AddElement(grid_grids()\events())
            grid_grids()\events()\event = #Grid_Event_Scroll
          EndIf
      EndSelect
    EndIf
    
    If grid_grids()\redraw
      If grid_grids()\redraw_ignore_grid
        grid_DoRedraw( grid_grids(), #False)
      Else
        grid_DoRedraw( grid_grids() )
      EndIf
      
      grid_grids()\redraw_ignore_grid = #False
      grid_grids()\redraw = #False
    EndIf
  Next
  
EndProcedure

Procedure grid_ScrollEvent()
  Protected gadget
  
  gadget = EventGadget()
  
  ForEach grid_grids()
    Select gadget
      Case grid_grids()\hscroll
        grid_CloseCombo(grid_grids())
        If Not grid_grids()\xscroll_disabled
          grid_SetGadgetAttribute(grid_grids(),#Grid_Scrolling_Column,GetGadgetState(grid_grids()\hscroll))
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_Scroll
        EndIf
        
      Case grid_grids()\vscroll
        grid_CloseCombo(grid_grids())
        If Not grid_grids()\yscroll_disabled
          grid_SetGadgetAttribute(grid_grids(),#Grid_Scrolling_Row,GetGadgetState(grid_grids()\vscroll))
          AddElement(grid_grids()\events())
          grid_grids()\events()\event = #Grid_Event_Scroll
        EndIf
    EndSelect
    
    If grid_grids()\redraw
      If grid_grids()\redraw_ignore_grid
        grid_DoRedraw( grid_grids(), #False)
      Else
        grid_DoRedraw( grid_grids() )
      EndIf
      
      grid_grids()\redraw_ignore_grid = #False
      grid_grids()\redraw = #False
    EndIf
  Next
  
EndProcedure

Procedure grid_TimerEvent()
  Protected scrollx, scrolly, mousex, mousey
  
  ForEach grid_grids()
    Select EventTimer()
      Case 145875
        mousex = grid_NewWindowMouseX(grid_grids()\hwnd) - grid_grids()\x - grid_deltagadgetposx
        mousey = grid_NewWindowMouseY(grid_grids()\hwnd) - grid_grids()\y - grid_deltagadgetposy
        
        If grid_grids()\edit_col > -1 And grid_grids()\edit_row > -1
          If (EventGadget() <> grid_grids()\canvas Or (EventGadget() = grid_grids()\canvas And EventType() <> #PB_EventType_KeyDown And EventType() <> #PB_EventType_LeftButtonDown And EventType() <> #PB_EventType_RightButtonDown And Not grid_grids()\lbuttondown))
            If grid_grids()\timer_edit = 0
              grid_grids()\timer_edit = 1
              grid_grids()\timer_edit2 = 1
            EndIf
          Else
            grid_grids()\timer_edit = 0
            grid_grids()\timer_edit2 = 1
          EndIf
        Else
          grid_grids()\timer_edit = 0
          grid_grids()\timer_edit2 = 1
        EndIf
        
        If grid_grids()\resizing = #False And grid_grids()\edit_selecting = #False
          If (mousey >= (grid_grids()\innerheight) Or mousey <= (grid_grids()\header_col_height) Or mousex >= (grid_grids()\innerwidth)  Or mousex <= (grid_grids()\header_row_width)) And grid_grids()\lbuttondown
            If grid_grids()\scrolltimer = 0
              grid_grids()\scrolltimer = 1
            EndIf
            
            LastElement(grid_grids()\sel())
            If (mousey - grid_grids()\innerheight) >= 0 And grid_grids()\sel()\sel_row <> -1
              If grid_grids()\yscroll + 1 < grid_grids()\maxnumrows
                grid_grids()\scroll_time_y = 1
              Else
                grid_grids()\scroll_time_y = 0
              EndIf
            ElseIf mousey <= (grid_grids()\header_col_height) And grid_grids()\sel()\sel_row <> -1
              grid_grids()\scroll_time_y = -1
            Else
              grid_grids()\scroll_time_y = 0
            EndIf
            
            If (mousex - grid_grids()\innerwidth) >= 0 And grid_grids()\sel()\sel_col <> -1
              If grid_grids()\xscroll + 1 < grid_grids()\maxnumcols
                grid_grids()\scroll_time_x = 1
              Else
                grid_grids()\scroll_time_x = 0
              EndIf
            ElseIf mousex <= (grid_grids()\header_row_width) And grid_grids()\sel()\sel_col <> -1
              grid_grids()\scroll_time_x = -1
            Else
              grid_grids()\scroll_time_x = 0
            EndIf
          Else
            grid_grids()\scrolltimer = 0
          EndIf
        EndIf
        
        CompilerIf #PB_Compiler_OS <> #PB_OS_Linux
          If grid_grids()\ac_active = 1 And GetActiveWindow() <> grid_grids()\ac_window
            grid_CloseCombo(grid_grids(),1)
          EndIf
        CompilerEndIf
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          If grid_grids()\ac_active And GetActiveWindow_() <> WindowID(grid_grids()\ac_window)
            grid_CloseCombo(grid_grids(),1)
          EndIf
        CompilerEndIf
        
        
        If grid_grids()\resizing = #False And grid_grids()\edit_selecting = #False
          If grid_grids()\scrolltimer
            If ListSize(grid_grids()\sel())
              LastElement(grid_grids()\sel())
              
              grid_grids()\sel()\sel_row_end + grid_grids()\scroll_time_y
              grid_grids()\sel()\sel_col_end + grid_grids()\scroll_time_x
              
              If grid_grids()\sel()\sel_row_end < 0
                grid_grids()\sel()\sel_row_end = 0
              EndIf
              If grid_grids()\sel()\sel_col_end < 0
                grid_grids()\sel()\sel_col_end = 0
              EndIf
            EndIf
            
            If grid_grids()\scroll_time_y <> 0
              scrolly = grid_grids()\yscroll + grid_grids()\scroll_time_y
            Else
              scrolly = -1
            EndIf
            
            If grid_grids()\scroll_time_x <> 0
              scrollx = grid_grids()\xscroll + grid_grids()\scroll_time_x
            Else
              scrollx = -1
            EndIf
            
            If scrollx > -1
              grid_SetGadgetAttribute( grid_grids(), #Grid_Scrolling_Column,scrollx)
            EndIf
            
            If scrolly > -1
              grid_SetGadgetAttribute( grid_grids(), #Grid_Scrolling_Row,scrolly)
            EndIf
            
            AddElement(grid_grids()\events())
            grid_grids()\events()\event = #Grid_Event_Scroll
          EndIf
        EndIf
        
      Case 145876
        If grid_grids()\timer_edit
          If grid_grids()\timer_edit2
            grid_grids()\timer_edit2 = 0
          Else
            grid_grids()\timer_edit2 = 1
          EndIf
          
          grid_grids()\redraw = #True
          grid_grids()\redraw_ignore_grid = #True
        EndIf
    EndSelect
    
    If grid_grids()\redraw
      If grid_grids()\redraw_ignore_grid
        grid_DoRedraw(grid_grids(), #False)
      Else
        grid_DoRedraw(grid_grids())
      EndIf
      
      grid_grids()\redraw_ignore_grid = #False
      grid_grids()\redraw = #False
    EndIf
  Next
EndProcedure

Procedure grid_WindowEvent()
  ForEach grid_grids()
    If grid_grids()\ac_active
      grid_CloseCombo(grid_grids())
    EndIf
  Next
EndProcedure

Procedure grid_Event(*grid.Grid_Struct)
  Protected event
  
  If FirstElement(*grid\events())
    event = *grid\events()\event
    *grid\c_event_cell = *grid\events()\event_cell
    *grid\c_event_column = *grid\events()\event_column
    *grid\c_event_row = *grid\events()\event_row
    CopyList(*grid\events()\event_cells(),*grid\c_event_cells())
    *grid\c_event_index_cells = -1
    DeleteElement(*grid\events())
  EndIf
  
  ProcedureReturn event
EndProcedure

DisableExplicit
