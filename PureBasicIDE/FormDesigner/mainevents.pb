; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Global form_gs_windowmousedx.i, form_gs_windowmousedy.i
Procedure.i FD_NewWindowMouseX(windownr.i)
  Protected wmx.i, dmx.i
  
  wmx = WindowMouseX(windownr)
  dmx = DesktopMouseX()
  If wmx >= 0
    form_gs_windowmousedx = dmx-wmx
  EndIf
  ProcedureReturn DesktopMouseX()-form_gs_windowmousedx
EndProcedure
Procedure.i FD_NewWindowMouseY(windownr.i)
  Protected wmy.i, dmy.i
  
  wmy = WindowMouseY(windownr)
  dmy = DesktopMouseY()
  If wmy >= 0
    form_gs_windowmousedy = dmy-wmy
  EndIf
  ProcedureReturn DesktopMouseY()-form_gs_windowmousedy
EndProcedure

Procedure FD_FindParent(item_number)
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\itemnumber = item_number
      Break
    EndIf
  Next
EndProcedure
Procedure FD_ReadProcedureList()
  grid_ClearComboBoxItems(propgrid, propgrid_proccombo)
  
  NewList FDProcList.ProcedureInfo()
  
  ClearList(FDProcList())
  
  PushListPosition(FileList()) ; Always preserve the current FileList() as it's used to know the active source !
  ForEach FileList()
    If @FileList() <> *ProjectInfo And FileList()\IsForm = 0
      InsideMacro = 0
      
      If FileList()\Parser\SourceItemArray
        For i = 0 To FileList()\Parser\SourceItemCount-1
          *Item.SourceItem = FileList()\Parser\SourceItemArray\Line[i]\First
          While *Item
            If InsideMacro = 0
              If *Item\Type = #ITEM_Procedure
                AddElement(FDProcList())
                FDProcList()\Name$ = *Item\Name$
                FDProcList()\Line  = i+1
                FDProcList()\Type  = 0
                FDProcList()\Prototype$ = *Item\Prototype$
                
              EndIf
            EndIf
            
            If *Item\Type = #ITEM_CommentMark
            ElseIf *Item\Type = #ITEM_Macro
              InsideMacro = 1
            ElseIf *Item\Type = #ITEM_MacroEnd
              InsideMacro = 0
            EndIf
            
            *Item = *Item\Next
          Wend
        Next i
      EndIf
      
      ; first sort the list
      ;
      If ListSize(FDProcList()) > 1
        Repeat
          Done = 1
          FirstElement(FDProcList())
          *Previous.ProcedureInfo = @FDProcList()
          
          While NextElement(FDProcList())
            Change = 0
            
            If ProcedureBrowserSort = 0
              If FDProcList()\Line < *Previous\Line
                Change = 1
              EndIf
              
            ElseIf ProcedureBrowserSort = 1
              If FDProcList()\Type = *Previous\Type
                If FDProcList()\Line < *Previous\Line
                  Change = 1
                EndIf
              ElseIf FDProcList()\Type < *Previous\Type
                Change = 1
              EndIf
              
            ElseIf ProcedureBrowserSort = 2
              If CompareMemoryString(@FDProcList()\Name$, @*Previous\Name$, 1) < 0
                Change = 1
              EndIf
              
            ElseIf ProcedureBrowserSort = 3
              If FDProcList()\Type = *Previous\Type
                If CompareMemoryString(@FDProcList()\Name$, @*Previous\Name$, 1) < 0
                  Change = 1
                EndIf
              ElseIf FDProcList()\Type < *Previous\Type
                Change = 1
              EndIf
              
            EndIf
            
            If Change
              SwapElements(FDProcList(), *Previous, @FDProcList())
              Done = 0
            EndIf
            
            *Previous = @FDProcList()
          Wend
          
        Until Done
      EndIf
      
      SortStructuredList(FDProcList(), #PB_Sort_Ascending | #PB_Sort_NoCase, OffsetOf(ProcedureInfo\Name$), #PB_String)
      ForEach FDProcList()
        If FDProcList()\Type = 0
          Text$ = FDProcList()\Name$
          grid_AddComboBoxItem(propgrid,propgrid_proccombo, -1, Text$)
        EndIf
        
      Next FDProcList()
    EndIf
  Next
  PopListPosition(FileList())
  
  FreeList(FDProcList())
  
EndProcedure
Procedure FD_OpenPBFile(proc.s)
  If FormWindows()\event_file
    If FileSize(FormWindows()\event_file) > -1
      handle = OpenFile(#PB_Any,FormWindows()\event_file)
      
      If handle
        linenb = 0
        linepos = 0
        lineproc = 0
        Repeat
          linepos = Loc(handle)
          line.s = ReadString(handle)
          
          If FindString(line,proc.s + "(") Or FindString(line,proc.s + " ")
            lineproc = linenb
          EndIf
          
          linenb + 1
        Until Eof(handle)
        
        CloseFile(handle)
      EndIf
      
      LoadSourceFile(FormWindows()\event_file)
      ChangeActiveLine(lineproc + 1, 0)
    EndIf
  EndIf
EndProcedure
Procedure FD_CheckVariable(string.s)
  If FindString(string, " ") Or FindString(string, ".") Or FindString(string, "-") Or FindString(string, "/") Or
     FindString(string, "\") Or FindString(string, "|") Or FindString(string, "?") Or FindString(string, "!") Or
     FindString(string, "@") Or FindString(string, "£") Or FindString(string, "$") Or FindString(string, "=")
    
    MessageRequester(#ProductName$, Language("Form","WrongVarName"))
    ProcedureReturn #False
    
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Declare Form_Scrollbars()

Global form_node1, form_node2, form_node3
Procedure PropGridFoldImgProc(x,y,width,height,column,row)
  type = grid_GetCellData(propgrid, 0, row)
  xpos = x + (width - 11) / 2
  ypos = y + (height - 11) / 2
  Box(xpos, ypos, 11, 11, RGB(255, 255, 255))
  DrawingMode(#PB_2DDrawing_Outlined)
  Box(xpos, ypos, 11, 11, RGB(0, 0, 0))
  DrawingMode(#PB_2DDrawing_Transparent)
  If type = 1
    Line(xpos + 5, ypos + 3, 1, 5, RGB(0, 0, 0))
  EndIf
  
  Line(xpos + 3, ypos + 5, 5, 1, RGB(0, 0, 0))
EndProcedure
Procedure PropGridAddNode(grid, row, title.s)
  grid_InsertRow(grid, row)
  grid_SetRowData(grid, row, -100)
  grid_SetCellType(grid, 0, row, #Grid_Cell_Custom)
  grid_SetCellState(grid, 0, row, @PropGridFoldImgProc())
  
  grid_SetCellBackColor(grid, 0, row, grid_color_bg)
  grid_SetCellBackColor(grid, 1, row, grid_color_bg)
  grid_SetCellBackColor(grid, 2, row, grid_color_bg)
  grid_SetCellString(grid, 1, row, title)
  grid_SetSelectionStyle(grid, 1, row, "", -1, 1, -1, -1, -1, grid_color_text, 0, Len(title))
  
  grid_SetCellLockState(grid, 0, row, 1)
  grid_SetCellLockState(grid, 1, row, 1)
  grid_SetCellLockState(grid, 2, row, 1)
  
EndProcedure
Procedure PropGridAddItem(grid, row, title.s, value.s = "")
  grid_InsertRow(grid, row)
  grid_SetCellBackColor(grid, 0, row, grid_color_bg)
  grid_SetCellString(grid, 1, row, title)
  grid_SetCellString(grid, 2, row, value)
  grid_SetCellLockState(grid,0,row,1)
  grid_SetCellLockState(grid,1,row,1)
  
EndProcedure
Procedure PropGridFoldNode(grid, row, fold = -1)
  If grid_GetRowData(grid, row) = -100
    firstblock = grid_GetCellData(grid, 0, row)
    If firstblock = 0
      firstblock = 1
    Else
      firstblock = 0
    EndIf
    
    If fold = 0
      firstblock = 0
    EndIf
    If fold = 1
      firstblock = 1
    EndIf
    
    grid_SetCellData(grid, 0, row, firstblock)
    
    ; hide til next node or end
    forstart = row + 1
    forend = grid_GetNumberOfRows(grid) - 1
    
    For i = forstart To forend
      If grid_GetRowData(grid, i) <> - 100
        grid_HideRow(grid, i, firstblock)
      Else
        Break
      EndIf
    Next
    
    ; resize in case the V scrollbar appears or disappears
    grid_SetColumnWidth(grid, 0, 20)
    grid_SetColumnWidth(grid, 1)
    width = grid_GadgetInnerWidth(grid) - grid_GetColumnWidth(grid, 0) - grid_GetColumnWidth(grid, 1)
    If width < 40
      width = 40
    EndIf
    grid_SetColumnWidth(grid, 2, width)
  EndIf
  
  ; dirty way to remember which node is closed (fine as there's only 3 nodes anyway)
  If row = 0
    form_node1 = firstblock
  ElseIf row < 9
    form_node2 = firstblock
  Else
    form_node3 = firstblock
  EndIf
  
EndProcedure



Procedure FD_UpdateScrollbars(resizewin = 0)
  If ListSize(FormWindows())
    If FormWindows()\flags & FlagValue("#PB_Window_SystemMenu")
      topwinpadding = P_WinHeight
    Else
      topwinpadding = 0
    EndIf
    
    If ListSize(FormWindows()\FormStatusbars()) Or FormWindows()\status_visible
      bottompaddingsb = P_Status
    Else
      bottompaddingsb = 0
    EndIf
    
    If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
      topmenupadding = P_Menu
    Else
      topmenupadding = 0
    EndIf
    
    If ListSize(FormWindows()\FormToolbars()) Or FormWindows()\toolbar_visible
      toptoolpadding = 16
      toptoolpadding + 8 ; top3, bottom5
    Else
      toptoolpadding = 0
    EndIf
    
    Select FormSkin
      Case #PB_OS_MacOS
        h = FormWindows()\width + #Page_Padding*2
        v = FormWindows()\height + topwinpadding + topmenupadding + toptoolpadding + #Page_Padding*2
      Case #PB_OS_Windows
        h = FormWindows()\width + #Page_Padding*2 + 16
        v = FormWindows()\height + topwinpadding + 8 + #Page_Padding*2
      Case #PB_OS_Linux
        h = FormWindows()\width + #Page_Padding*2
        v = FormWindows()\height + topwinpadding + #Page_Padding*2
    EndSelect
  EndIf
  
  scrollh = 0 : scrollv = 0
  If h > DesktopScaledX(GadgetWidth(#GADGET_Form)) - Grid_Scrollbar_Width
    scrollh = 1
  EndIf
  If v > DesktopScaledY(GadgetHeight(#GADGET_Form)) - Grid_Scrollbar_Width
    scrollv = 1
  EndIf
  
  swidth = GadgetWidth(#GADGET_Form)-Grid_Scrollbar_Width
  sheight = GadgetHeight(#GADGET_Form)-Grid_Scrollbar_Width
  
  If scrollh
    If IsGadget(#GADGET_Form_ScrollH)
      If resizewin
        ResizeGadget(#GADGET_Form_ScrollH,0,GadgetHeight(#GADGET_Form)-Grid_Scrollbar_Width,swidth,Grid_Scrollbar_Width)
      EndIf
    Else
      OpenGadgetList(#GADGET_Form)
      ScrollBarGadget(#GADGET_Form_ScrollH,0,GadgetHeight(#GADGET_Form)-Grid_Scrollbar_Width,swidth,Grid_Scrollbar_Width,0,600,GadgetWidth(#GADGET_Form_Canvas))
      BindGadgetEvent(#GADGET_Form_ScrollH, @Form_Scrollbars())
      CloseGadgetList()
    EndIf
    SetGadgetAttribute(#GADGET_Form_ScrollH,#PB_ScrollBar_Maximum,h)
    SetGadgetAttribute(#GADGET_Form_ScrollH,#PB_ScrollBar_PageLength,GadgetWidth(#GADGET_Form_Canvas))
    SetGadgetState(#GADGET_Form_ScrollH,FormWindows()\paddingx)
  Else
    If IsGadget(#GADGET_Form_ScrollH)
      FreeGadget(#GADGET_Form_ScrollH)
    EndIf
  EndIf
  
  If scrollv
    If IsGadget(#GADGET_Form_ScrollV)
      If resizewin
        ResizeGadget(#GADGET_Form_ScrollV,GadgetWidth(#GADGET_Form)-Grid_Scrollbar_Width,0,Grid_Scrollbar_Width,sheight)
      EndIf
    Else
      OpenGadgetList(#GADGET_Form)
      ScrollBarGadget(#GADGET_Form_ScrollV,GadgetWidth(#GADGET_Form)-Grid_Scrollbar_Width,0,Grid_Scrollbar_Width,sheight,0,800,GadgetHeight(#GADGET_Form_Canvas),#PB_ScrollBar_Vertical)
      BindGadgetEvent(#GADGET_Form_ScrollV, @Form_Scrollbars())
      CloseGadgetList()
    EndIf
    SetGadgetAttribute(#GADGET_Form_ScrollV,#PB_ScrollBar_Maximum,v)
    SetGadgetAttribute(#GADGET_Form_ScrollV,#PB_ScrollBar_PageLength,GadgetHeight(#GADGET_Form_Canvas))
    SetGadgetState(#GADGET_Form_ScrollV,FormWindows()\paddingy)
  Else
    If IsGadget(#GADGET_Form_ScrollV)
      FreeGadget(#GADGET_Form_ScrollV)
    EndIf
  EndIf
  
  redraw = 1
EndProcedure
Procedure FD_SelectGadget(gadget)
  
  If propgrid
    If grid_EventEditing(propgrid)
      FD_ProcessEventGrid(grid_EventEditingColumn(propgrid), grid_EventEditingRow(propgrid))
    EndIf
    
    FormWindows()\lastgadgetselected = gadget
    
    propgrid_gadget = gadget
    propgrid_win = 0
    propgrid_menu = 0
    propgrid_toolbar = 0
    propgrid_statusbar = 0
    PushListPosition(FormWindows()\FormGadgets())
    ChangeCurrentElement(FormWindows()\FormGadgets(),gadget)
    grid_StopEditing(propgrid)
    grid_DeleteAllRows(propgrid)
    FD_InitBasicPropGridRows(#True)
    
    Select FormWindows()\FormGadgets()\type
      Case #Form_Type_Date
        grid_SetCellString(propgrid,1,4,Language("Form", "Mask"))
      Default
        grid_SetCellString(propgrid,1,4,Language("Form", "Caption"))
    EndSelect
    
    grid_SetCellState(propgrid,2,1,FormWindows()\FormGadgets()\pbany)
    grid_SetCellString(propgrid,2,2,FormWindows()\FormGadgets()\variable)
    grid_SetCellState(propgrid,2,3,FormWindows()\FormGadgets()\captionvariable)
    
    Select FormWindows()\FormGadgets()\type
      Case #Form_Type_Editor, #Form_Type_Canvas
        grid_SetCellLockState(propgrid, 2, 4, 1)
        
      Case #Form_Type_Scintilla
        grid_SetCellLockState(propgrid, 2, 3, 1) ; Callback is stored in the caption for ScintillaGadget
        grid_SetCellString(propgrid, 1, 4, "Callback")
        grid_SetCellString(propgrid, 2, 4, FormWindows()\FormGadgets()\caption)
        
      Default
        grid_SetCellLockState(propgrid, 2, 3, 0)
        grid_SetCellLockState(propgrid, 2, 4, 0)
        grid_SetCellString(propgrid, 2, 4, FormWindows()\FormGadgets()\caption)
    EndSelect
    
    
    grid_SetCellState(propgrid, 2, 5, FormWindows()\FormGadgets()\tooltipvariable)
    grid_SetCellString(propgrid, 2, 6, FormWindows()\FormGadgets()\tooltip)
    
    grid_SetCellString(propgrid, 2,8,Str(FormWindows()\FormGadgets()\x1))
    grid_SetCellString(propgrid, 2,9,Str(FormWindows()\FormGadgets()\y1))
    grid_SetCellString(propgrid, 2,10,Str(FormWindows()\FormGadgets()\x2-FormWindows()\FormGadgets()\x1))
    grid_SetCellString(propgrid, 2,11,Str(FormWindows()\FormGadgets()\y2-FormWindows()\FormGadgets()\y1))
    grid_SetCellState(propgrid, 2,12,FormWindows()\FormGadgets()\hidden)
    grid_SetCellState(propgrid, 2,13,FormWindows()\FormGadgets()\disabled)
    
    i = 14
    
    PropGridAddItem(propgrid, i, Language("Form", "Parent"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
    grid_SetCellState(propgrid,2,i,@DrawFontPicker())
    
    If FormWindows()\FormGadgets()\parent
      PushListPosition(FormWindows()\FormGadgets())
      FD_FindParent(FormWindows()\FormGadgets()\parent)
      
      display.s = FormWindows()\FormGadgets()\variable
      PopListPosition(FormWindows()\FormGadgets())
    EndIf
    
    oldbuffer = grid_GetCellData(propgrid, 2, i)
    If oldbuffer
      FreeMemory(oldbuffer)
    EndIf
    
    buffer = AllocateMemory((Len(display)+1)* SizeOf(Character))
    PokeS(buffer,display)
    grid_SetCellData(propgrid,2,i,buffer)
    
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "LockLeft"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\FormGadgets()\lock_left)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "LockRight"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\FormGadgets()\lock_right)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "LockTop"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\FormGadgets()\lock_top)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "LockBottom"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\FormGadgets()\lock_bottom)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Font"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
    grid_SetCellState(propgrid,2,i,@DrawFontPicker())
    
    If FormWindows()\FormGadgets()\gadgetfont <> ""
      display.s = FormWindows()\FormGadgets()\gadgetfont + " " + Str(FormWindows()\FormGadgets()\gadgetfontsize) + " "
      
      If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Bold")
        display + "B"
      EndIf
      If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Italic")
        display + "I"
      EndIf
      If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Underline")
        display + "U"
      EndIf
      If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_StrikeOut")
        display + "S"
      EndIf
      
      oldbuffer = grid_GetCellData(propgrid,2,i)
      If oldbuffer
        FreeMemory(oldbuffer)
      EndIf
      
      buffer = AllocateMemory((Len(display)+1)* SizeOf(Character))
      PokeS(buffer,display)
      grid_SetCellData(propgrid,2,i,buffer)
    EndIf
    i + 1
    
    Select FormWindows()\FormGadgets()\type
      Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
        PropGridAddItem(propgrid, i, Language("Form", "FrontColor"))
        grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
        grid_SetCellState(propgrid,2,i,@DrawColorPicker())
        grid_SetCellData(propgrid,2,i,FormWindows()\FormGadgets()\frontcolor)
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "BackColor"))
        grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
        grid_SetCellState(propgrid,2,i,@DrawColorPicker())
        grid_SetCellData(propgrid,2,i,FormWindows()\FormGadgets()\backcolor)
        i + 1
    EndSelect
    
    Select FormWindows()\FormGadgets()\type
      Case #Form_Type_Custom
        PropGridAddItem(propgrid, i, Language("Form", "SelectGadget"))
        grid_SetCellType(propgrid,2,i,#Grid_Cell_ComboBox)
        grid_SetCellState(propgrid,2,i,propgrid_combo)
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "InitCode"))
        grid_SetCellString(propgrid,2,i,FormWindows()\FormGadgets()\cust_init)
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "CreateCode"))
        grid_SetCellString(propgrid,2,i,FormWindows()\FormGadgets()\cust_create)
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "Help"))
        grid_SetCellString(propgrid,2,i,"%id% %x% %y% %w% %h% %txt% %hwnd% ") : grid_SetCellLockState(propgrid,1,i,1)
        i + 1
        
      Case #Form_Type_Spin, #Form_Type_Trackbar, #Form_Type_ProgressBar, #Form_Type_Scrollbar
        PropGridAddItem(propgrid, i, Language("Form", "Min"), Str(FormWindows()\FormGadgets()\min))
        grid_SetCellString(propgrid,2,i,Str(FormWindows()\FormGadgets()\min))
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "Max"), Str(FormWindows()\FormGadgets()\max))
        grid_SetCellString(propgrid,2,i,Str(FormWindows()\FormGadgets()\max))
        i + 1
        
      Case #Form_Type_Splitter
        PropGridAddItem(propgrid, i, Language("Form", "SplitterPosition"), Str(FormWindows()\FormGadgets()\state))
        i + 1
        
      Case #Form_Type_ScrollArea
        PropGridAddItem(propgrid, i, Language("Form", "InnerWidth"), Str(FormWindows()\FormGadgets()\min))
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "InnerHeight"), Str(FormWindows()\FormGadgets()\max))
        i + 1
        
      Case #Form_Type_Img, #Form_Type_ButtonImg
        PropGridAddItem(propgrid, i, Language("Form", "CurrentImage"))
        
        imageurl.s = ""
        If FormWindows()\FormGadgets()\image
          ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormGadgets()\image)
          imageurl.s = FormWindows()\FormImg()\img
        EndIf
        
        grid_SetCellString(propgrid,2,i,imageurl)
        i + 1
        
        PropGridAddItem(propgrid, i, Language("Form", "ChangeImage"))
        grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
        grid_SetCellState(propgrid,2,i,@DrawButton())
        i + 1
        
      Case #Form_Type_Option, #Form_Type_Checkbox
        PropGridAddItem(propgrid, i, Language("Form", "Checked"))
        grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
        grid_SetCellState(propgrid,2,i,FormWindows()\FormGadgets()\state)
        i + 1
    EndSelect
    
    PropGridAddItem(propgrid, i, Language("Form", "SelectProc"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Combobox_Editable)
    grid_SetCellState(propgrid,2,i,propgrid_proccombo)
    grid_SetCellString(propgrid,2,i,FormWindows()\FormGadgets()\event_proc)
    i + 1
    
    FD_ReadProcedureList()
    
    PropGridAddNode(propgrid, i, Language("ToolsPanel", "Constants"))
    i + 1
    
    ForEach Gadgets()
      If Gadgets()\type = FormWindows()\FormGadgets()\type
        ForEach Gadgets()\Flags()
          PropGridAddItem(propgrid, i, Gadgets()\Flags()\name)
          grid_SetCellType(propgrid, 2, i, #Grid_Cell_Checkbox)
          
          If FormWindows()\FormGadgets()\flags & Gadgets()\Flags()\ivalue
            grid_SetCellState(propgrid, 2, i, 1)
          EndIf
          i + 1
        Next
      EndIf
    Next
    
    
    ; Set the folded states
    forend = grid_GetNumberOfRows(propgrid) - 1
    j = 0
    For i = 0 To forend
      If grid_GetRowData(propgrid, i) = - 100
        Select j
          Case 0
            PropGridFoldNode(propgrid, i, form_node1)
          Case 1
            PropGridFoldNode(propgrid, i, form_node2)
          Case 2
            PropGridFoldNode(propgrid, i, form_node3)
        EndSelect
        
        j + 1
      EndIf
    Next
    
    grid_SetColumnWidth(propgrid, 0, 20)
    grid_SetColumnWidth(propgrid, 1)
    width = grid_GadgetInnerWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1)
    If width < 40
      width = 40
    EndIf
    grid_SetColumnWidth(propgrid, 2, width)
    
    PopListPosition(FormWindows()\FormGadgets())
  EndIf
EndProcedure

Procedure FD_SelectWindow(window)
  If propgrid
    If grid_EventEditing(propgrid)
      FD_ProcessEventGrid(grid_EventEditingColumn(propgrid), grid_EventEditingRow(propgrid))
    EndIf
    
    grid_StopEditing(propgrid)
    grid_DeleteAllRows(propgrid)
    FD_InitBasicPropGridRows()
    
    grid_SetCellString(propgrid, 1, 4, "Caption")
    
    propgrid_win = window
    propgrid_gadget = 0
    propgrid_toolbar = 0
    propgrid_menu = 0
    propgrid_statusbar = 0
    
    ChangeCurrentElement(FormWindows(),window)
    grid_SetCellState(propgrid, 2, 1, FormWindows()\pbany)
    grid_SetCellString(propgrid, 2, 2, FormWindows()\variable)
    grid_SetCellState(propgrid, 2, 3, FormWindows()\captionvariable)
    grid_SetCellString(propgrid, 2, 4, FormWindows()\caption)
    
    If FormWindows()\x = -65535
      winx.s = "#PB_Ignore"
    Else
      winx.s = Str(FormWindows()\x)
    EndIf
    
    If FormWindows()\y = -65535
      winy.s = "#PB_Ignore"
    Else
      winy.s = Str(FormWindows()\y)
    EndIf
    
    grid_SetCellString(propgrid, 2, 6, winx)
    grid_SetCellString(propgrid, 2, 7, winy)
    
    grid_SetCellString(propgrid, 2, 8, Str(FormWindows()\width))
    grid_SetCellString(propgrid, 2, 9, Str(FormWindows()\height))
    grid_SetCellState(propgrid, 2, 10, FormWindows()\hidden)
    grid_SetCellState(propgrid, 2, 11, FormWindows()\disabled)
    
    i = 12
    PropGridAddItem(propgrid, i, Language("Form", "Parent"), FormWindows()\parent)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Color"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
    grid_SetCellState(propgrid,2,i,@DrawColorPicker())
    grid_SetCellData(propgrid,2,i,FormWindows()\color)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "GenEventProc"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\generateeventloop)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "SelectProc"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Combobox_Editable)
    grid_SetCellState(propgrid,2,i,propgrid_proccombo)
    grid_SetCellString(propgrid,2,i,FormWindows()\event_proc)
    i + 1
    
    FD_ReadProcedureList()
    
    PropGridAddNode(propgrid, i, Language("ToolsPanel", "Constants"))
    i + 1
    
    ForEach Gadgets()
      If Gadgets()\type = #Form_Type_Window
        ForEach Gadgets()\Flags()
          PropGridAddItem(propgrid, i, Gadgets()\Flags()\name)
          grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
          If FormWindows()\flags & Gadgets()\Flags()\ivalue
            grid_SetCellState(propgrid,2,i,1)
          EndIf
          
          i+1
        Next
        If ListSize(Gadgets()\Flags()) <= 0 : i + 1 : EndIf
        custFlags.s = ""
        ForEach FormWindows()\FormCustomFlags()
          If custFlags = ""
            custFlags = FormWindows()\FormCustomFlags()
          Else
            custFlags + " | " + FormWindows()\FormCustomFlags()
          EndIf  
        Next
        PropGridAddItem(propgrid, i, Language("Form", "customFlags"), custFlags)
        i + 1
      EndIf
    Next
    
    ; Set the folded states
    forend = grid_GetNumberOfRows(propgrid) - 1
    j = 0
    For i = 0 To forend
      If grid_GetRowData(propgrid, i) = - 100
        Select j
          Case 0
            PropGridFoldNode(propgrid, i, form_node1)
          Case 1
            PropGridFoldNode(propgrid, i, form_node2)
          Case 2
            PropGridFoldNode(propgrid, i, form_node3)
        EndSelect
        
        j + 1
      EndIf
    Next
    
    grid_SetColumnWidth(propgrid, 0, 20)
    grid_SetColumnWidth(propgrid,1)
    width = grid_GadgetInnerWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1)
    If width < 40
      width = 40
    EndIf
    grid_SetColumnWidth(propgrid, 2, width)
    
  EndIf
  FD_UpdateScrollbars()
EndProcedure
Procedure FD_SelectToolbar(toolbar)
  If propgrid
    If grid_EventEditing(propgrid)
      FD_ProcessEventGrid(grid_EventEditingColumn(propgrid), grid_EventEditingRow(propgrid))
    EndIf
    
    propgrid_gadget = 0
    propgrid_win = 0
    propgrid_statusbar = 0
    propgrid_menu = 0
    propgrid_toolbar = toolbar
    PushListPosition(FormWindows()\FormToolbars())
    ChangeCurrentElement(FormWindows()\FormToolbars(),toolbar)
    
    grid_StopEditing(propgrid)
    grid_DeleteAllRows(propgrid)
    
    PropGridAddItem(propgrid, i, Language("Form", "Variable"), FormWindows()\FormToolbars()\id)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Caption"), FormWindows()\FormToolbars()\tooltip)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "CurrentImage"))
    
    
    imageurl.s = ""
    If FormWindows()\FormToolbars()\img
      ChangeCurrentElement(FormWindows()\FormImg(), FormWindows()\FormToolbars()\img)
      imageurl.s = FormWindows()\FormImg()\img
    EndIf
    
    grid_SetCellString(propgrid,2,i,imageurl)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "ChangeImage"))
    grid_SetCellType(propgrid, 2,i,#Grid_Cell_Custom)
    grid_SetCellState(propgrid, 2,i,@DrawButton())
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "ToggleButton"))
    grid_SetCellType(propgrid, 2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid, 2,i,FormWindows()\FormToolbars()\toggle)
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "Separator"))
    grid_SetCellType(propgrid, 2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid, 2,i,FormWindows()\FormToolbars()\separator)
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "SelectProc"))
    grid_SetCellType(propgrid, 2,i,#Grid_Cell_Combobox_Editable)
    grid_SetCellState(propgrid, 2,i,propgrid_proccombo)
    grid_SetCellString(propgrid, 2,i,FormWindows()\FormToolbars()\event)
    i+1
    
    FD_ReadProcedureList()
    
    grid_SetColumnWidth(propgrid, 0, 20)
    grid_SetColumnWidth(propgrid, 1)
    width = grid_GadgetInnerWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1)
    If width < 40
      width = 40
    EndIf
    grid_SetColumnWidth(propgrid, 2, width)
    
    PopListPosition(FormWindows()\FormToolbars())
  EndIf
EndProcedure
Procedure FD_SelectStatusBar(statusbar)
  If propgrid
    If grid_EventEditing(propgrid)
      FD_ProcessEventGrid(grid_EventEditingColumn(propgrid), grid_EventEditingRow(propgrid))
    EndIf
    
    propgrid_gadget = 0
    propgrid_win = 0
    propgrid_toolbar = 0
    propgrid_menu = 0
    propgrid_statusbar = statusbar
    PushListPosition(FormWindows()\FormStatusbars())
    ChangeCurrentElement(FormWindows()\FormStatusbars(),statusbar)
    
    grid_StopEditing(propgrid)
    grid_DeleteAllRows(propgrid)
    
    PropGridAddItem(propgrid, i, Language("Form", "Width"))
    
    If FormWindows()\FormStatusbars()\width = -1
      grid_SetCellString(propgrid,2,i,"#PB_Ignore")
    Else
      grid_SetCellString(propgrid,2,i,Str(FormWindows()\FormStatusbars()\width))
    EndIf
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "Text"), FormWindows()\FormStatusbars()\text)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "CurrentImage"))
    
    imageurl.s = ""
    If FormWindows()\FormStatusbars()\img
      ChangeCurrentElement(FormWindows()\FormImg(), FormWindows()\FormStatusbars()\img)
      imageurl.s = FormWindows()\FormImg()\img
    EndIf
    
    grid_SetCellString(propgrid,2,i,imageurl)
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "ChangeImage"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
    grid_SetCellState(propgrid,2,i,@DrawButton())
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "ProgressBar"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\FormStatusbars()\progressbar)
    i+1
    
    ForEach Gadgets()
      If Gadgets()\type = #Form_Type_StatusBar
        ForEach Gadgets()\Flags()
          PropGridAddItem(propgrid, i, Gadgets()\Flags()\name)
          grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
          If FormWindows()\FormStatusbars()\flags & Gadgets()\Flags()\ivalue
            grid_SetCellState(propgrid,2,i,1)
          EndIf
          
          i+1
        Next
      EndIf
    Next
    
    grid_SetColumnWidth(propgrid, 0, 20)
    grid_SetColumnWidth(propgrid,1)
    width = grid_GadgetInnerWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1)
    If width < 40
      width = 40
    EndIf
    grid_SetColumnWidth(propgrid, 2, width)
    
    PopListPosition(FormWindows()\FormStatusbars())
  EndIf
EndProcedure
Procedure FD_SelectMenu(menu)
  If propgrid
    If grid_EventEditing(propgrid)
      FD_ProcessEventGrid(grid_EventEditingColumn(propgrid), grid_EventEditingRow(propgrid))
    EndIf
    
    propgrid_gadget = 0
    propgrid_win = 0
    propgrid_toolbar = 0
    propgrid_statusbar = 0
    propgrid_menu = menu
    PushListPosition(FormWindows()\FormMenus())
    ChangeCurrentElement(FormWindows()\FormMenus(),menu)
    
    grid_StopEditing(propgrid)
    grid_DeleteAllRows(propgrid)
    
    PropGridAddItem(propgrid, i, Language("Form", "Constant"), FormWindows()\FormMenus()\id)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Name"), FormWindows()\FormMenus()\item)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Shortcut"), FormWindows()\FormMenus()\shortcut)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "Separator"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Checkbox)
    grid_SetCellState(propgrid,2,i,FormWindows()\FormMenus()\separator)
    i + 1
    
    PropGridAddItem(propgrid, i, Language("Form", "CurrentImage"))
    
    imageurl.s = ""
    If FormWindows()\FormMenus()\icon
      ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormMenus()\icon)
      imageurl.s = FormWindows()\FormImg()\img
    EndIf
    
    grid_SetCellString(propgrid,2,i,imageurl)
    i + 1
    
    
    PropGridAddItem(propgrid, i, Language("Form", "ChangeImage"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Custom)
    grid_SetCellState(propgrid,2,i,@DrawButton())
    i+1
    
    PropGridAddItem(propgrid, i, Language("Form", "SelectProc"))
    grid_SetCellType(propgrid,2,i,#Grid_Cell_Combobox_Editable)
    grid_SetCellState(propgrid,2,i,propgrid_proccombo)
    grid_SetCellString(propgrid,2,i,FormWindows()\FormMenus()\event)
    i+1
    
    FD_ReadProcedureList()
    
    grid_SetColumnWidth(propgrid, 0, 20)
    grid_SetColumnWidth(propgrid,1)
    width = grid_GadgetInnerWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1)
    If width < 40
      width = 40
    EndIf
    grid_SetColumnWidth(propgrid, 2, width)
    
    PopListPosition(FormWindows()\FormMenus())
  EndIf
EndProcedure
Procedure FD_SelectNone()
  If propgrid
    If grid_EventEditing(propgrid)
      FD_ProcessEventGrid(grid_EventEditingColumn(propgrid), grid_EventEditingRow(propgrid))
    EndIf
    
    propgrid_gadget = 0
    propgrid_win = 0
    propgrid_toolbar = 0
    propgrid_statusbar = 0
    propgrid_menu = 0
    
    grid_StopEditing(propgrid)
    grid_DeleteAllRows(propgrid)
  EndIf
EndProcedure

Structure tempobjlist
  name.s
  state.b
EndStructure
Procedure FD_UpdateObjList()
  ClearList(ObjList())
  
  level = 0
  
  If ListSize(FormWindows())
    
    AddElement(ObjList())
    ObjList()\level = level
    ObjList()\window = FormWindows()
    ObjList()\name = FormWindows()\variable
    ObjList()\gadget_item = -1
    
    ForEach FormWindows()\FormGadgets()
      level = 1
      found = 0
      If FormWindows()\FormGadgets()\parent
        ForEach ObjList()
          If found = 1 And (ObjList()\level < level); Or ListIndex(ObjList()) = ListSize(ObjList())-1)
            PreviousElement(ObjList())
            Break
          EndIf
          
          If ObjList()\gadget_number = FormWindows()\FormGadgets()\parent
            If FormWindows()\FormGadgets()\parent_item > -1
              If ObjList()\gadget_item = FormWindows()\FormGadgets()\parent_item
                level = ObjList()\level + 1
                found = 1
              EndIf
            Else
              found = 1
              level = ObjList()\level + 1
            EndIf
          EndIf
        Next
      Else
        LastElement(ObjList())
      EndIf
      
      AddElement(ObjList())
      ObjList()\level = level
      ObjList()\window = FormWindows()
      ObjList()\gadget = FormWindows()\FormGadgets()
      ObjList()\gadget_number = FormWindows()\FormGadgets()\itemnumber
      ObjList()\gadget_item = -1
      ObjList()\name = FormWindows()\FormGadgets()\variable
      
      ForEach FormWindows()\FormGadgets()\Items()
        AddElement(ObjList())
        ObjList()\level = level + 1
        ObjList()\window = FormWindows()
        ObjList()\gadget = FormWindows()\FormGadgets()
        ObjList()\gadget_number = FormWindows()\FormGadgets()\itemnumber
        ObjList()\gadget_item = ListIndex(FormWindows()\FormGadgets()\Items())
        ObjList()\name = FormWindows()\FormGadgets()\Items()\name
      Next
    Next
    
    If IsGadget(#Form_PropObjList)
      num = CountGadgetItems(#Form_PropObjList) -1
      NewList obj.tempobjlist()
      For i = 0 To num
        AddElement(obj())
        obj()\name = GetGadgetItemText(#Form_PropObjList,i)
        obj()\state = GetGadgetItemState(#Form_PropObjList,i)
      Next
      state.s = GetGadgetItemText(#Form_PropObjList,GetGadgetState(#Form_PropObjList))
      
      ClearGadgetItems(#Form_PropObjList)
      
      pos = 0
      ForEach ObjList()
        If ObjList()\gadget
          PushListPosition(FormWindows()\FormGadgets())
          ChangeCurrentElement(FormWindows()\FormGadgets(), ObjList()\gadget)
          this_type = FormWindows()\FormGadgets()\type
          PopListPosition(FormWindows()\FormGadgets())
        Else
          this_type = #Form_Type_Window
        EndIf
        
        imgid = 0
        ForEach Gadgets()
          If Gadgets()\type = this_type
            imgid = ImageID(Gadgets()\icon)
          EndIf
        Next
        
        AddGadgetItem(#Form_PropObjList,pos,ObjList()\name,imgid,ObjList()\level)
        SetGadgetItemData(#Form_PropObjList,pos,ObjList())
        
        pos + 1
      Next
      
      num = CountGadgetItems(#Form_PropObjList) -1
      For i = 0 To num
        ForEach obj()
          If obj()\name = GetGadgetItemText(#Form_PropObjList,i)
            SetGadgetItemState(#Form_PropObjList,i,obj()\state)
          EndIf
        Next
      Next
      SetGadgetState(#Form_PropObjList,-1)
    EndIf
    
  EndIf
EndProcedure
Global NewList Deletelist.i()
Procedure FD_DeleteGadgetA(gadget)
  ChangeCurrentElement(FormWindows()\FormGadgets(),gadget)
  
  AddElement(Deletelist())
  Deletelist() = FormWindows()\FormGadgets()
  gadgetnum = FormWindows()\FormGadgets()\itemnumber
  PushListPosition(FormWindows()\FormGadgets())
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\parent = gadgetnum
      FD_DeleteGadgetA(FormWindows()\FormGadgets())
    EndIf
  Next
  PopListPosition(FormWindows()\FormGadgets())
EndProcedure
Procedure FD_DeleteGadgetB()
  FormChanges(1)
  addaction = 1
  ForEach Deletelist()
    ChangeCurrentElement(FormWindows()\FormGadgets(),Deletelist())
    If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
      PushListPosition(FormWindows()\FormGadgets())
      s_gadget1 = FormWindows()\FormGadgets()\gadget1
      s_gadget2 = FormWindows()\FormGadgets()\gadget2
      
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\itemnumber = s_gadget1
          FormWindows()\FormGadgets()\splitter = 0
        EndIf
        If FormWindows()\FormGadgets()\itemnumber = s_gadget2
          FormWindows()\FormGadgets()\splitter = 0
        EndIf
      Next
      PopListPosition(FormWindows()\FormGadgets())
    EndIf
    
    If Not FormWindows()\FormGadgets()\splitter
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),#Undo_Delete)
      addaction = 0
      
      DeleteElement(FormWindows()\FormGadgets())
    EndIf
  Next
  ClearList(Deletelist())
  FD_UpdateObjList()
EndProcedure


Procedure FD_DrawResizeButton(x,y)
  DrawingMode(#PB_2DDrawing_Transparent)
  Box(x-4,y-4,8,8,RGB(0,0,0))
  Box(x-3,y-3,6,6,RGB(255,255,255))
EndProcedure

Procedure FD_CheckPoint(x,y,x1,y1,precision = 4)
  If (x >= x1-precision And x <= x1+precision) And (y >=y1-precision And y <= y1+precision)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure FD_AlignPoint(x)
  point = Int(x / FormGridSize) * FormGridSize
  
  ProcedureReturn point
EndProcedure

Global xmin,xmax,ymin,ymax
; Filter that do not draw parts of gadget that are outside of the container's visible area.
Procedure FD_FilterCallback(x, y, SourceColor, TargetColor)
  If x > xmin And x < xmax And y > ymin And y < ymax
    alpha.f = Alpha(SourceColor)/255 ; alpha blending
    SR = SourceColor & $FF
    SG = SourceColor>>8 & $FF
    SB = SourceColor>>16 & $FF
    TR = TargetColor & $FF
    TG = TargetColor>>8 & $FF
    TB = TargetColor>>16 & $FF
    R = SR * alpha + TR * (1 - alpha)
    G = SG * alpha + TG * (1 - alpha)
    B = SB * alpha + TB * (1 - alpha)
    
    ProcedureReturn R | G<<8 | B<<16
  Else
    ProcedureReturn TargetColor
  EndIf
  
  ;   If x > xmin And x < xmax And y > ymin And y < ymax
  ;     alpha.f = Alpha(SourceColor)/255 ; alpha blending
  ;     ProcedureReturn RGB(Red(SourceColor)*alpha+Red(TargetColor)*(1-alpha),Green(SourceColor)*alpha+Green(TargetColor)*(1-alpha),Blue(SourceColor)*alpha+Blue(TargetColor)*(1-alpha))
  ;   Else
  ;     ProcedureReturn TargetColor
  ;   EndIf
EndProcedure

Procedure FD_DrawGadget(x1,y1,x2,y2,type, caption.s = "", flag = 0, g_data = -1, items = 0, *pointer = 0)
  If x2 > x1 And y2 > y1
    If CreateImage(#TDrawing_Img, x2-x1, y2-y1, 32) ; Images can be very big and requiers some memory, so ensures we can create it
      StopDrawing()
      
      fd_fontid = 0
      If *pointer
        PushListPosition(FormWindows()\FormGadgets())
        ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
        
        If FormWindows()\FormGadgets()\captionvariable
          caption = "[" + caption + "]"
        EndIf
        
        If FormWindows()\FormGadgets()\frontcolor <> -1
          gadgfrontcolor = RGBA(Red(FormWindows()\FormGadgets()\frontcolor),Green(FormWindows()\FormGadgets()\frontcolor),Blue(FormWindows()\FormGadgets()\frontcolor),255)
        EndIf
        If FormWindows()\FormGadgets()\backcolor <> -1
          gadgbackcolor = RGBA(Red(FormWindows()\FormGadgets()\backcolor),Green(FormWindows()\FormGadgets()\backcolor),Blue(FormWindows()\FormGadgets()\backcolor),255)
        EndIf
        
        If FormWindows()\FormGadgets()\gadgetfont
          fontkey.s = FormWindows()\FormGadgets()\gadgetfont+Str(FormWindows()\FormGadgets()\gadgetfontsize)
          
          If fontflags & FlagValue("#PB_Font_Bold")
            fontkey + "B"
          EndIf
          If fontflags & FlagValue("#PB_Font_Italic")
            fontkey + "I"
          EndIf
          If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Underline")
            fontkey + "U"
          EndIf
          If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_StrikeOut")
            fontkey + "S"
          EndIf
          
          
          If FindMapElement(grids_fonts(),fontkey)
            fd_fontid = grids_fonts()\hfont
          Else
            AddMapElement(grids_fonts(),fontkey)
            grids_fonts()\fontname = FormWindows()\FormGadgets()\gadgetfont
            grids_fonts()\fontsize = FormWindows()\FormGadgets()\gadgetfontsize
            
            fontflags = 0
            If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Bold")
              If fontflags = 0
                fontflags = #PB_Font_Bold
              Else
                fontflags | #PB_Font_Bold
              EndIf
            EndIf
            If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Italic")
              If fontflags = 0
                fontflags = #PB_Font_Italic
              Else
                fontflags | #PB_Font_Italic
              EndIf
            EndIf
            If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Underline")
              If fontflags = 0
                fontflags = #PB_Font_Underline
              Else
                fontflags | #PB_Font_Underline
              EndIf
            EndIf
            If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_StrikeOut")
              If fontflags = 0
                fontflags = #PB_Font_StrikeOut
              Else
                fontflags | #PB_Font_StrikeOut
              EndIf
            EndIf
            
            grids_fonts()\hfont = LoadFont(#PB_Any,grids_fonts()\fontname,grids_fonts()\fontsize, fontflags)
            fd_fontid = grids_fonts()\hfont
          EndIf
        EndIf
      EndIf
      
      If fd_fontid = 0
        fd_fontid = #Form_Font
      EndIf
      
      StartDrawing(ImageOutput(#TDrawing_Img))
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(0,0,OutputWidth(),OutputHeight(),  RGBA(0,0,0,0))
      
      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
      gadgfrontcolor = -1
      gadgbackcolor = -1
      
      
      ox1 = x1 : ox2 = x2 : oy1 = y1 : oy2 = y2
      x1 = 0: x2=ox2-ox1: y1=0: y2=oy2-oy1
      Select type
        Case #Form_Type_Splitter ;{
          If *pointer
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            pos = FormWindows()\FormGadgets()\state
            PopListPosition(FormWindows()\FormGadgets())
            
            Select FormSkin
              Case #PB_OS_MacOS
                color = RGBA(237, 237, 237,255)
              Case #PB_OS_Windows
                color = RGBA(240, 240, 240,255)
              Case #PB_OS_Linux
                color = RGBA(242, 241, 240,255)
            EndSelect
            
            If flag & FlagValue("#PB_Splitter_Vertical")
              Box(x1 + pos,y1,P_SplitterWidth,y2 - y1,color)
              
              Select FormSkin
                Case #PB_OS_MacOS
                  Circle(x1 + pos + (P_SplitterWidth - 6), y1 + (y2 - y1) / 2,2,RGBA(140,140,140,255))
                Case #PB_OS_Windows
                  If flag & FlagValue("#PB_Splitter_Separator")
                    Line(x1 + pos + 3,y1,1,y2 - y1,RGBA(255,255,255,255))
                    Line(x1 + pos + 3 + 1,y1,1,y2 - y1,RGBA(255,255,255,255))
                    Line(x1 + pos + 3 + 2,y1,1,y2 - y1,RGBA(140,140,140,255))
                    Line(x1 + pos + 3,y2 - 1,3,1,RGBA(140,140,140,255))
                  EndIf
                Case #PB_OS_Linux
              EndSelect
            Else
              Box(x1,y1 + pos,x2 - x1, P_SplitterWidth, color)
              
              Select FormSkin
                Case #PB_OS_MacOS
                  Circle(x1 + (x2 - x1) / 2, y1 + pos + (P_SplitterWidth - 6),2,RGBA(140,140,140,255))
                Case #PB_OS_Windows
                  If flag & FlagValue("#PB_Splitter_Separator")
                    Line(x1, y1 + pos + 3,x2 - x1,1,RGBA(255,255,255,255))
                    Line(x1, y1 + pos + 3 + 1,x2 - x1,1,RGBA(255,255,255,255))
                    Line(x1, y1 + pos + 3 + 2,x2 - x1,1,RGBA(140,140,140,255))
                    Line(x2 - 1, y1 + pos + 3,1,3,RGBA(140,140,140,255))
                  EndIf
                Case #PB_OS_Linux
              EndSelect
            EndIf
          EndIf
          
          ;}
        Case #Form_Type_StringGadget, #Form_Type_IP ;{
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          
          Select FormSkin
            Case #PB_OS_MacOS
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
              LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
              LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
              LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
              LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
            Case #PB_OS_Windows
              Select FormSkinVersion
                Case 7
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                  Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
                  LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
                  LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
                  LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
                  LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
                Case 8
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                  Box(x1,y1,x2 - x1, y2 - y1,RGBA(171,173,179,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  Box(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2, color)
              EndSelect
            Case #PB_OS_Linux
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
              LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
              LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
              LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
              LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
          EndSelect
          
          DrawingFont(FontID(fd_fontid))
          
          If caption = ""
            Select type
              Case #Form_Type_StringGadget
                caption = "StringGadget"
              Case #Form_Type_IP
                caption = "IPGadget"
            EndSelect
          EndIf
          
          
          x = x1 + 3
          y = y1 + (y2 - y1 - TextHeight(caption)) / 2
          
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          DrawText(x,y,caption,color)
          ;}
        Case #Form_Type_Button ;{
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          Select FormSkin
            Case #PB_OS_MacOS
              If y2-y1 = 25 ; rounded button
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
                BackColor(RGBA(255,255,255,255))
                FrontColor(RGBA(244,244,244,255))
                LinearGradient(x1+1,y1+1,x1+1, y1+9)
                Box(x1+1,y1+1,x2 - x1-2, 10)
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1+1,y1+11,x2 - x1-2, 10,RGBA(236,236,236,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1,y1,x2 - x1, 22,3,3,RGBA(144,144,144,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(fd_fontid))
                x = x1 + (x2 - x1 - TextWidth(caption)) / 2
                y = y1 + (y2 - y1 - TextHeight(caption)) / 2
                DrawText(x,y,caption,color)
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1,y1,x2 - x1, y2 - y1, 4, 4, RGBA(220,220,220,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                RoundBox(x1 + 1,y1 + 1,x2 - x1 - 2, y2 - y1 - 2, 4, 4, RGBA(241,241,241,255))
                
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1 + 1,y1 + 1,x2 - x1 - 2, y2 - y1 - 2, 4, 4, RGBA(174,174,174,255))
                Line(x1 + 4, y1 + 2, x2 - x1 - 8, 1,RGBA(255,255,255,255))
                Line(x1 + 3, y1 + 3, x2 - x1 - 6, 1,RGBA(250,250,250,255))
                Line(x1 + 2, y1 + 4, x2 - x1 - 4, 1,RGBA(246,246,246,255))
                
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(fd_fontid))
                x = x1 + (x2 - x1 - TextWidth(caption)) / 2
                y = y1 + (y2 - y1 - TextHeight(caption)) / 2
                DrawText(x,y,caption,color)
              EndIf
              
            Case #PB_OS_Windows
              Select FormSkinVersion
                Case 7
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  height1 = (y2 - y1) * 0.45 -2
                  Box(x1 + 1, y1 + 1, x2 - x1 - 2, height1,RGBA(235,235,235,255))
                  Box(x1 + 1, y1 + 1 + height1, x2 - x1 - 2, (y2 - y1) * 0.55 -2,RGBA(211,211,211,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                  RoundBox(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2,3,3,RGBA(250,250,250,255))
                  RoundBox(x1, y1, x2 - x1, y2 - y1,3,3,RGBA(111,111,111,255))
                  
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  
                  DrawingFont(FontID(fd_fontid))
                  
                  x = x1 + (x2 - x1 - TextWidth(caption)) / 2
                  y = y1 + (y2 - y1 - TextHeight(caption)) / 2
                  DrawText(x,y,caption,color)
                Case 8
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
                  FrontColor(RGBA(240,240,240,255))
                  BackColor(RGBA(229,229,229,255))
                  LinearGradient(x1 + 1, y1 + 1, x1 + 1, y2 - y1 - 2)
                  Box(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2)
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                  Box(x1, y1, x2 - x1, y2 - y1,RGBA(172,172,172,255))
                  
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  
                  DrawingFont(FontID(fd_fontid))
                  
                  x = x1 + (x2 - x1 - TextWidth(caption)) / 2
                  y = y1 + (y2 - y1 - TextHeight(caption)) / 2
                  DrawText(x,y,caption,color)
              EndSelect
            Case #PB_OS_Linux
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              RoundBox(x1,y1,x2 - x1, y2 - y1, 4, 4, RGBA(220,220,220,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              RoundBox(x1 + 1,y1 + 1,x2 - x1 - 2, y2 - y1 - 2, 4, 4, RGBA(241,241,241,255))
              
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              RoundBox(x1 + 1,y1 + 1,x2 - x1 - 2, y2 - y1 - 2, 4, 4, RGBA(174,174,174,255))
              Line(x1 + 4, y1 + 2, x2 - x1 - 8, 1,RGBA(255,255,255,255))
              Line(x1 + 3, y1 + 3, x2 - x1 - 6, 1,RGBA(250,250,250,255))
              Line(x1 + 2, y1 + 4, x2 - x1 - 4, 1,RGBA(246,246,246,255))
              
              x = x1 + (x2 - x1 - TextWidth(caption)) / 2
              y = y1 + (y2 - y1 - TextHeight(caption)) / 2
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              DrawingFont(FontID(fd_fontid))
              DrawText(x,y,caption,color)
          EndSelect
          ;}
        Case #Form_Type_ButtonImg ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(RGBA(250,250,250,255))
          FrontColor(RGBA(239,239,239,255))
          
          LinearGradient(x1+1,y1+1,x1+1, y2-1)
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1-2)
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          ; Draw Image
          If *pointer
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If FormWindows()\FormGadgets()\image
              ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormGadgets()\image)
              g_data = ImageManager(FormWindows()\FormImg()\img)
              If IsImage(g_data)
                DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
                DrawImage(ImageID(g_data),x1 + (x2 - x1 - ImageWidth(g_data))/2,y1 + (y2 - y1 - ImageHeight(g_data))/2)
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              EndIf
            EndIf
            
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          ;}
        Case #Form_Type_Checkbox ;{
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          
          If *pointer
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If FormWindows()\FormGadgets()\state
              Select FormSkin
                Case #PB_OS_MacOS
                  imgid = #Img_MacCheckboxSel
                Case #PB_OS_Windows
                  Select FormSkinVersion
                    Case 7
                      imgid = #Img_Win7CheckboxSel
                    Case 8
                      imgid = #Img_Win8CheckboxSel
                  EndSelect
                Case #PB_OS_Linux
                  imgid = #Img_Win7CheckboxSel
              EndSelect
              DrawAlphaImage(ImageID(imgid), x1, y1 + (y2 - y1 - ImageHeight(imgid)) /2)
            Else
              Select FormSkin
                Case #PB_OS_MacOS
                  imgid = #Img_MacCheckbox
                Case #PB_OS_Windows
                  Select FormSkinVersion
                    Case 7
                      imgid = #Img_Win7Checkbox
                    Case 8
                      imgid = #Img_Win8Checkbox
                  EndSelect
                Case #PB_OS_Linux
                  imgid = #Img_Win7Checkbox
              EndSelect
              DrawAlphaImage(ImageID(imgid), x1, y1 + (y2 - y1 - ImageHeight(imgid)) /2)
            EndIf
            
            PopListPosition(FormWindows()\FormGadgets())
          Else
            Select FormSkin
              Case #PB_OS_MacOS
                imgid = #Img_MacCheckbox
              Case #PB_OS_Windows
                Select FormSkinVersion
                  Case 7
                    imgid = #Img_Win7Checkbox
                  Case 8
                    imgid = #Img_Win8Checkbox
                EndSelect
              Case #PB_OS_Linux
                imgid = #Img_Win7Checkbox
            EndSelect
            DrawAlphaImage(ImageID(imgid), x1, y1 + (y2 - y1 - ImageHeight(imgid)) /2)
          EndIf
          
          DrawingFont(FontID(fd_fontid))
          DrawText(x1 + 14 + 3, y1 + (y2 - y1 - 15) / 2,caption,color)
          ;}
        Case #Form_Type_Text, #Form_Type_HyperLink ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          DrawingFont(FontID(fd_fontid))
          
          If type = #Form_Type_Text ; draw a background if it's a TextGadget
            If gadgbackcolor <> -1
              color = gadgbackcolor
            Else
              Select FormSkin
                Case #PB_OS_MacOS
                  color = RGBA(237, 237, 237,255)
                Case #PB_OS_Windows
                  color = RGBA(240, 240, 240,255)
                Case #PB_OS_Linux
                  color = RGBA(242, 241, 240,255)
              EndSelect
            EndIf
            Box(x1,y1,x2 - x1, y2 - y1,color)
          EndIf
          
          posx = x1+1
          
          If flag & FlagValue("#PB_Text_Right")
            posx = x2 - TextWidth(caption)-1
          ElseIf flag & FlagValue("#PB_Text_Center")
            posx = x1+1 + (x2 - x1 - TextWidth(caption))/2
          EndIf
          
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          If caption = ""
            If type = #Form_Type_Text
              caption = "TextGadget"
            Else
              caption = "HyperLinkGadget"
            EndIf
          EndIf
          
          DrawText(posx,y1,caption,color)
          
          If flag & FlagValue("#PB_Text_Border")
            DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
            Box(x1,y1,x2 - x1, y2 - y1,RGBA(142,142,142,255))
          EndIf
          
          ;}
        Case #Form_Type_Option ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          
          If *pointer
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If FormWindows()\FormGadgets()\state
              Select FormSkin
                Case #PB_OS_MacOS
                  imgid = #Img_MacOptionSel
                Case #PB_OS_Windows
                  Select FormSkinVersion
                    Case 7
                      imgid = #Img_Win7OptionSel
                    Case 8
                      imgid = #Img_Win8OptionSel
                  EndSelect
                Case #PB_OS_Linux
                  imgid = #Img_Win7OptionSel
              EndSelect
              DrawAlphaImage(ImageID(imgid), x1, y1 + (y2 - y1 - ImageHeight(imgid)) /2)
            Else
              Select FormSkin
                Case #PB_OS_MacOS
                  imgid = #Img_MacOption
                Case #PB_OS_Windows
                  Select FormSkinVersion
                    Case 7
                      imgid = #Img_Win7Option
                    Case 8
                      imgid = #Img_Win8Option
                  EndSelect
                Case #PB_OS_Linux
                  imgid = #Img_Win7Option
              EndSelect
              DrawAlphaImage(ImageID(imgid), x1, y1 + (y2 - y1 - ImageHeight(imgid)) /2)
            EndIf
            
            PopListPosition(FormWindows()\FormGadgets())
          Else
            Select FormSkin
              Case #PB_OS_MacOS
                imgid = #Img_MacOption
              Case #PB_OS_Windows
                Select FormSkinVersion
                  Case 7
                    imgid = #Img_Win7Option
                  Case 8
                    imgid = #Img_Win8Option
                EndSelect
              Case #PB_OS_Linux
                imgid = #Img_Win7Option
            EndSelect
            DrawAlphaImage(ImageID(imgid), x1, y1 + (y2 - y1 - ImageHeight(imgid)) /2)
          EndIf
          
          DrawingFont(FontID(fd_fontid))
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          DrawText(x1 + 16 + 3,y1 + (y2-y1 - 17) /2,caption,color)
          ;}
        Case #Form_Type_TreeGadget ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(142,142,142,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,color)
          
          DrawingFont(FontID(fd_fontid))
          
          ; Draw items
          If *pointer And items > 0
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            
            y1+4
            ForEach FormWindows()\FormGadgets()\Items()
              levelpadding.s = Space(FormWindows()\FormGadgets()\Items()\level * 3)
              DrawText(x1 + 30,y1,levelpadding + FormWindows()\FormGadgets()\Items()\name,color)
              y1 + TextHeight(" ") + 6
            Next
            
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          
          If items = 0
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            
            DrawText(x1 + 30,y1 + 4, "TreeGadget", color)
          EndIf
          
          ;}
        Case #Form_Type_ListView ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(142,142,142,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,color)
          
          If *pointer And items > 0
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            DrawingFont(FontID(fd_fontid))
            y1+4
            ForEach FormWindows()\FormGadgets()\Items()
              DrawText(x1 + 6,y1,FormWindows()\FormGadgets()\Items()\name,color)
              y1 + TextHeight(" ") + 4
            Next
            
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          
          If items = 0
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            DrawingFont(FontID(fd_fontid))
            
            DrawText(x1 + 30,y1 + 4, "ListViewGadget", color)
          EndIf
          ;}
        Case #Form_Type_ListIcon ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(142,142,142,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,color)
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
          BackColor(RGBA(255,255,255,255))
          FrontColor(RGBA(244,244,244,255))
          LinearGradient(x1+1,y1+1,x1+1, x1+9)
          Box(x1+1,y1+1,x2 - x1-2, 8)
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          Box(x1+1,y1+9,x2 - x1-2, 6,RGBA(236,236,236,255))
          Line(x1+1,y1+15,x2-x1-2,1,RGBA(244,244,244,255))
          Line(x1+1,y1+16,x2-x1-2,1,RGBA(182,182,182,255))
          
          If *pointer
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            
            DrawingFont(FontID(fd_fontid))
            xcol = x1 + 2
            ForEach FormWindows()\FormGadgets()\Columns()
              DrawText(xcol + 2,y1,FormWindows()\FormGadgets()\Columns()\name,RGBA(0,0,0,255))
              xcol + FormWindows()\FormGadgets()\Columns()\width
              
              Line(xcol,y1 + 1,1,15,RGBA(182,182,182,255))
            Next
            
            y1+20
            ForEach FormWindows()\FormGadgets()\Items()
              If FindString(FormWindows()\FormGadgets()\Items()\name,"|")
                num = CountString(FormWindows()\FormGadgets()\Items()\name,"|") + 1
                
                FirstElement(FormWindows()\FormGadgets()\Columns())
                xcol = x1 + 2
                For i = 1 To num
                  DrawText(xcol,y1,StringField(FormWindows()\FormGadgets()\Items()\name,i,"|"),color)
                  xcol + FormWindows()\FormGadgets()\Columns()\width
                  If Not NextElement(FormWindows()\FormGadgets()\Columns())
                    Break
                  EndIf
                Next
                
              Else
                DrawText(x1 + 6,y1,FormWindows()\FormGadgets()\Items()\name,color)
              EndIf
              
              y1 + TextHeight(" ") + 4
            Next
            
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          ;}
        Case #Form_Type_Combo, #Form_Type_ExplorerCombo ;{
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          Select FormSkin
            Case #PB_OS_MacOS
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
              BackColor(RGBA(255,255,255,255))
              FrontColor(RGBA(244,244,244,255))
              LinearGradient(x1+1,y1+1,x1+1, x1+9)
              Box(x1+1,y1+1,x2 - x1-2, 10)
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              Box(x1+1,y1+11,x2 - x1-2, 9,RGBA(236,236,236,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              RoundBox(x1,y1,x2 - x1, 22,3,3,RGBA(144,144,144,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              DrawAlphaImage(ImageID(#Img_Combo),x2 - 12,y1 + 5)
              DrawingFont(FontID(fd_fontid))
              DrawText(x1 + 6,y1 + (22 - TextHeight(" ")) / 2,"Item 1", color)
              
            Case #PB_OS_Windows
              If flag & FlagValue("#PB_ComboBox_Editable")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1,y1,x2 - x1, y2 - y1,RGBA(255,255,255,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2 - x1, y2 - y1,RGBA(150,150,150,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Select FormSkinVersion
                  Case 7
                    DrawAlphaImage(ImageID(#Img_ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_ArrowDown)) / 2)
                  Case 8
                    DrawAlphaImage(ImageID(#Img_Win8ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_Win8ArrowDown)) / 2)
                EndSelect
                DrawingFont(FontID(fd_fontid))
                DrawText(x1 + 3,y1 + (y2 - y1  - TextHeight(" ")) / 2,"Item 1", color)
              Else
                Select FormSkinVersion
                  Case 7
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1 + 1, y1 + 1, x2 - x1 - 2, (y2 - y1) * 0.45 -2,RGBA(235,235,235,255))
                    Box(x1 + 1, y1 + 1 + (y2 - y1) * 0.45, x2 - x1 - 2, (y2 - y1) * 0.55 -2,RGBA(211,211,211,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    RoundBox(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2,3,3,RGBA(250,250,250,255))
                    RoundBox(x1, y1, x2 - x1, y2 - y1,3,3,RGBA(111,111,111,255))
                    DrawAlphaImage(ImageID(#Img_ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_ArrowDown)) / 2)
                  Case 8
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
                    FrontColor(RGBA(240,240,240,255))
                    BackColor(RGBA(229,229,229,255))
                    LinearGradient(x1 + 1, y1 + 1, x1 + 1, y2 - y1 - 2)
                    Box(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2)
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    Box(x1, y1, x2 - x1, y2 - y1,RGBA(172,172,172,255))
                    DrawAlphaImage(ImageID(#Img_Win8ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_Win8ArrowDown)) / 2)
                EndSelect
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(fd_fontid))
                DrawText(x1 + 4,y1 + (y2 - y1  - TextHeight(" ")) / 2,"Item 1", color)
              EndIf
              
            Case #PB_OS_Linux
              If flag & FlagValue("#PB_ComboBox_Editable")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1,y1,x2 - x1, y2 - y1,RGBA(255,255,255,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2 - x1, y2 - y1,RGBA(150,150,150,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawAlphaImage(ImageID(#Img_ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_ArrowDown)) / 2)
                DrawingFont(FontID(fd_fontid))
                DrawText(x1 + 3,y1 + (y2 - y1  - TextHeight(" ")) / 2,"Item 1", color)
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1 + 1, y1 + 1, x2 - x1 - 2, (y2 - y1) * 0.45 -2,RGBA(235,235,235,255))
                Box(x1 + 1, y1 + 1 + (y2 - y1) * 0.45, x2 - x1 - 2, (y2 - y1) * 0.55 -2,RGBA(211,211,211,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2,3,3,RGBA(250,250,250,255))
                RoundBox(x1, y1, x2 - x1, y2 - y1,3,3,RGBA(111,111,111,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawAlphaImage(ImageID(#Img_ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_ArrowDown)) / 2)
                DrawingFont(FontID(fd_fontid))
                DrawText(x1 + 4,y1 + (y2 - y1  - TextHeight(" ")) / 2,"Item 1", color)
              EndIf
          EndSelect
          ;}
        Case #Form_Type_Spin ;{
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Select FormSkin
            Case #PB_OS_MacOS
              x2 - 20
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
              LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
              LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
              LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
              LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
              DrawImage(ImageID(#Img_Spin),x2 + 7,y1 + (y2-y1-23)/2)
            Case #PB_OS_Windows
              Select FormSkinVersion
                Case 7
                  x2 - 20
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                  Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
                  LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
                  LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
                  LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
                  LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
                  DrawImage(ImageID(#Img_Spin),x2 + 7,y1 + (y2-y1-23)/2)
                Case 8
                  x2 - ImageWidth(#Img_Win8Spin) - 1
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                  Box(x1,y1,x2 - x1, y2 - y1,RGBA(171,173,179,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  Box(x1 + 1, y1 + 1, x2 - x1 - 2, y2 - y1 - 2, color)
                  DrawImage(ImageID(#Img_Win8Spin),x2 + 1,y1 + (y2-y1-ImageHeight(#Img_Win8Spin))/2)
              EndSelect
            Case #PB_OS_Linux
              x2 - 20
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
              LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
              LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
              LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
              LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
              DrawImage(ImageID(#Img_Spin),x2 + 7,y1 + (y2-y1-23)/2)
          EndSelect
          
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          
          DrawingFont(FontID(fd_fontid))
          x = x1 + 3
          y = y1 + (y2 - y1 - TextHeight(caption)) / 2
          DrawText(x,y,caption,color)
          ;}
        Case #Form_Type_Trackbar ;{
          Select FormSkin
            Case #PB_OS_MacOS
              If flag & FlagValue("#PB_TrackBar_Vertical")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1 + 3,y1,5,y2-y1,1,1,RGBA(116,116,116,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Line(x1+4,y1+1,1,y2 - y1 - 2,RGBA(170,170,170,255))
                Line(x1+5,y1+1,1,y2 - y1 - 2,RGBA(193,193,193,255))
                Line(x1+6,y1+1,1,y2 - y1 - 2,RGBA(205,205,205,255))
                DrawAlphaImage(ImageID(#Img_MacTrackbarV),x1,y1)
                If flag & FlagValue("#PB_TrackBar_Ticks")
                  wfinish = y2 - 9
                  wstart = y1 + 9
                  While wstart <= wfinish
                    Line(x1 + 8 + 9, wstart,4,1,RGBA(154,154,154,255))
                    wstart + 8
                  Wend
                Else
                  Box(x1 + 8 + 9,y1 + 9, 4, y2 - y1 - 18,RGBA(114,114,114,255))
                EndIf
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1,y1 + 3,x2 - x1, 5,1,1,RGBA(116,116,116,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Line(x1+1,y1+4,x2 - x1 - 2,1,RGBA(170,170,170,255))
                Line(x1+1,y1+5,x2 - x1 - 2,1,RGBA(193,193,193,255))
                Line(x1+1,y1+6,x2 - x1 - 2,1,RGBA(205,205,205,255))
                DrawAlphaImage(ImageID(#Img_MacTrackbar),x1,y1)
                If flag & FlagValue("#PB_TrackBar_Ticks")
                  wfinish = x2 - 9
                  wstart = x1 + 9
                  While wstart <= wfinish
                    Line(wstart,y1 + 8 + 9,1,4,RGBA(154,154,154,255))
                    wstart + 8
                  Wend
                  
                Else
                  Box(x1 + 9,y1 + 8 + 9, x2 - x1 - 18,4,RGBA(114,114,114,255))
                EndIf
              EndIf
              
            Case #PB_OS_Windows
              If flag & FlagValue("#PB_TrackBar_Vertical")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                RoundBox(x1 + 3,y1,5,y2-y1,1,1,RGBA(231,231,231,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1 + 3,y1,5,y2-y1,1,1,RGBA(176,176,176,255))
                
                DrawAlphaImage(ImageID(#Img_Win7TrackbarV),x1,y1)
                If flag & FlagValue("#PB_TrackBar_Ticks")
                  wfinish = y2 - 9
                  wstart = y1 + 9
                  While wstart <= wfinish
                    Line(x1 + 8 + 9, wstart,4,1,RGBA(154,154,154,255))
                    wstart + 8
                  Wend
                EndIf
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                RoundBox(x1,y1 + 3,x2 - x1, 5,1,1,RGBA(231,231,231,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1,y1 + 3,x2 - x1, 5,1,1,RGBA(176,176,176,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawAlphaImage(ImageID(#Img_Win7Trackbar),x1,y1)
                If flag & FlagValue("#PB_TrackBar_Ticks")
                  wfinish = x2 - 9
                  wstart = x1 + 9
                  While wstart <= wfinish
                    Line(wstart,y1 + 8 + 9,1,4,RGBA(154,154,154,255))
                    wstart + 8
                  Wend
                EndIf
              EndIf
              
            Case #PB_OS_Linux
              If flag & FlagValue("#PB_TrackBar_Vertical")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                RoundBox(x1 + 3,y1,5,y2-y1,1,1,RGBA(231,231,231,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1 + 3,y1,5,y2-y1,1,1,RGBA(176,176,176,255))
                
                DrawAlphaImage(ImageID(#Img_Win7TrackbarV),x1,y1)
                If flag & FlagValue("#PB_TrackBar_Ticks")
                  wfinish = y2 - 9
                  wstart = y1 + 9
                  While wstart <= wfinish
                    Line(x1 + 8 + 9, wstart,4,1,RGBA(154,154,154,255))
                    wstart + 8
                  Wend
                EndIf
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                RoundBox(x1,y1 + 3,x2 - x1, 5,1,1,RGBA(231,231,231,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(x1,y1 + 3,x2 - x1, 5,1,1,RGBA(176,176,176,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawAlphaImage(ImageID(#Img_Win7Trackbar),x1,y1)
                If flag & FlagValue("#PB_TrackBar_Ticks")
                  wfinish = x2 - 9
                  wstart = x1 + 9
                  While wstart <= wfinish
                    Line(wstart,y1 + 8 + 9,1,4,RGBA(154,154,154,255))
                    wstart + 8
                  Wend
                EndIf
              EndIf
          EndSelect
          ;}
        Case #Form_Type_ProgressBar ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
              color = RGBA(230,230,230,255)
            Else
              color = RGBA(220,220,220,255)
            EndIf
          EndIf
          
          If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
            Box(x1,y1,x2 - x1, y2 - y1,color)
          Else
            RoundBox(x1,y1,x2 - x1, y2 - y1,3,3,color)
          EndIf
          
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
              color = RGBA(6,176,37,255)
            Else
              color = RGBA(134,206,244,255)
            EndIf
          EndIf
          
          If flag & FlagValue("#PB_ProgressBar_Vertical")
            Box(x1 + 1, y1 + 1, x2 - x1 - 2, (y2 - y1) / 2 - 2,color)
          Else
            Box(x1 + 1, y1 + 1, (x2 - x1) / 2 - 2, y2 - y1 - 2,color)
          EndIf
          
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
            Box(x1,y1,x2 - x1, y2 - y1,RGBA(188,188,188,255))
          Else
            RoundBox(x1,y1,x2 - x1, y2 - y1,3,3,RGBA(152,152,152,255))
          EndIf
          ;}
        Case #Form_Type_Img ;{
          If *pointer
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If FormWindows()\FormGadgets()\image
              ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormGadgets()\image)
              g_data = ImageManager(FormWindows()\FormImg()\img)
              If IsImage(g_data)
                DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
                DrawImage(ImageID(g_data),x1 + (x2 - x1 - ImageWidth(g_data))/2,y1 + (y2 - y1 - ImageHeight(g_data))/2)
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              EndIf
            Else
              DrawingFont(FontID(fd_fontid))
              DrawText(x1,y1,"ImageGadget",RGBA(0,0,0,255))
            EndIf
            
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          ;}
        Case #Form_Type_Scrollbar ;{
          Select FormSkin
            Case #PB_OS_MacOS
              If flag & FlagValue("#PB_ScrollBar_Vertical")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Line(x1,y1,1,y2-y1,RGBA(228,228,228,255))
                Line(x1+1,y1,1,y2-y1,RGBA(242,242,242,255))
                Line(x1+2,y1,1,y2-y1,RGBA(244,244,244,255))
                Line(x1+3,y1,1,y2-y1,RGBA(245,245,245,255))
                Box(x1+4,y1,10,y2-y1,RGBA(250,250,250,255))
                
                RoundBox(x1 + 4,y1 + 1, 8,(y2 - y1)/3,3,3,RGBA(195,195,195,255))
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Line(x1,y1,x2-x1,1,RGBA(228,228,228,255))
                Line(x1,y1+1,x2-x1,1,RGBA(242,242,242,255))
                Line(x1,y1+2,x2-x1,1,RGBA(244,244,244,255))
                Line(x1,y1+3,x2-x1,1,RGBA(245,245,245,255))
                Box(x1,y1+4,x2-x1,10,RGBA(250,250,250,255))
                
                RoundBox(x1 + 1,y1 + 4, (x2 - x1)/3,8,3,3,RGBA(195,195,195,255))
              EndIf
              
            Case #PB_OS_Windows
              If flag & FlagValue("#PB_ScrollBar_Vertical")
                Select FormSkinVersion
                  Case 7
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1,y1,x2-x1,y2-y1,RGBA(240,240,240,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
                    DrawAlphaImage(ImageID(#Img_ScrollUp),x1 +  (x2 - x1 - 6) / 2, y1 + 6)
                    DrawAlphaImage(ImageID(#Img_ScrollDown),x1 +  (x2 - x1 - 6) / 2, y2 - 10)
                    
                    RoundBox(x1 + 1,y1 + 17 + 1, x2-x1-2,(y2 - y1 - 34)/3,1,1,RGBA(155,155,155,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1 + 2, y1 + 17 + 2, (x2-x1)*3/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(236,236,236,255))
                    Box(x1 + 2 + (x2-x1)*3/8, y1 + 17 + 2, (x2-x1)*5/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(202,202,202,255))
                  Case 8
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1, y1, x2 - x1, y2 - y1, RGBA(240,240,240,255))
                    Line(x1,y1,1,y2 - y1,RGBA(255,255,255,255))
                    DrawAlphaImage(ImageID(#Img_Win8ScrollUp),x1 +  (x2 - x1 - ImageWidth(#Img_Win8ScrollUp)) / 2, y1 + 5)
                    DrawAlphaImage(ImageID(#Img_Win8ScrollDown),x1 +  (x2 - x1 - ImageWidth(#Img_Win8ScrollUp)) / 2, y2 - 5 - ImageHeight(#Img_Win8ScrollDown))
                    
                    Box(x1 + 1, y1 + 17, x2 - x1 - 1,(y2 - y1 - 34)/3,RGBA(205,205,205,255))
                EndSelect
              Else
                Select FormSkinVersion
                  Case 7
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1,y1,x2-x1,y2-y1,RGBA(240,240,240,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
                    DrawAlphaImage(ImageID(#Img_ScrollLeft),x1 + 6, y1 + (y2 - y1 - 6) / 2)
                    DrawAlphaImage(ImageID(#Img_ScrollRight),x2 - 10, y1 + (y2 - y1 - 6) / 2)
                    
                    RoundBox(x1 + 17 + 1,y1 + 1, (x2 - x1 - 34)/3,y2-y1-2,1,1,RGBA(155,155,155,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1 + 17 + 2,y1 + 2, (x2 - x1 - 34)/3 - 2,(y2-y1)*3/8 - 4,RGBA(236,236,236,255))
                    Box(x1 + 17 + 2,y1 + 2 + (y2-y1)*3/8, (x2 - x1 - 34)/3 - 2,(y2-y1)*5/8 - 4,RGBA(202,202,202,255))
                  Case 8
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(x1, y1, x2 - x1, y2 - y1, RGBA(240,240,240,255))
                    Line(x1,y1,x2 - x1,1,RGBA(255,255,255,255))
                    DrawAlphaImage(ImageID(#Img_Win8ScrollLeft),x1 + 5, y1 +  (y2 - y1 - ImageHeight(#Img_Win8ScrollLeft)) / 2)
                    DrawAlphaImage(ImageID(#Img_Win8ScrollRight),x2 - 5 - ImageWidth(#Img_Win8ScrollRight), y1 +  (y2 - y1 - ImageHeight(#Img_Win8ScrollRight)) / 2)
                    
                    Box(x1 + 17, y1 + 1, (x2 - x1 - 34)/3, y2 - y1 - 1,RGBA(205,205,205,255))
                EndSelect
              EndIf
              
            Case #PB_OS_Linux
              If flag & FlagValue("#PB_ScrollBar_Vertical")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1,y1,x2-x1,y2-y1,RGBA(240,240,240,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
                DrawAlphaImage(ImageID(#Img_ScrollUp),x1 +  (x2 - x1 - 6) / 2, y1 + 6)
                DrawAlphaImage(ImageID(#Img_ScrollDown),x1 +  (x2 - x1 - 6) / 2, y2 - 10)
                
                RoundBox(x1 + 1,y1 + 17 + 1, x2-x1-2,(y2 - y1 - 34)/3,1,1,RGBA(155,155,155,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1 + 2, y1 + 17 + 2, (x2-x1)*3/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(236,236,236,255))
                Box(x1 + 2 + (x2-x1)*3/8, y1 + 17 + 2, (x2-x1)*5/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(202,202,202,255))
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1,y1,x2-x1,y2-y1,RGBA(240,240,240,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
                DrawAlphaImage(ImageID(#Img_ScrollLeft),x1 + 6, y1 + (y2 - y1 - 6) / 2)
                DrawAlphaImage(ImageID(#Img_ScrollRight),x2 - 10, y1 + (y2 - y1 - 6) / 2)
                
                RoundBox(x1 + 17 + 1,y1 + 1, (x2 - x1 - 34)/3,y2-y1-2,1,1,RGBA(155,155,155,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(x1 + 17 + 2,y1 + 2, (x2 - x1 - 34)/3 - 2,(y2-y1)*3/8 - 4,RGBA(236,236,236,255))
                Box(x1 + 17 + 2,y1 + 2 + (y2-y1)*3/8, (x2 - x1 - 34)/3 - 2,(y2-y1)*5/8 - 4,RGBA(202,202,202,255))
              EndIf
          EndSelect
          ;}
        Case #Form_Type_Editor, #Form_Type_Scintilla ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(194,194,194,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,color)
          x = x1 + 3
          y = y1 + 3
          
          DrawingFont(FontID(fd_fontid))
          
          If *pointer And items > 0
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
            
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            
            y1+4
            ForEach FormWindows()\FormGadgets()\Items()
              DrawText(x1 + 6,y1,FormWindows()\FormGadgets()\Items()\name,color)
              y1 + TextHeight(" ") + 4
            Next
            
            PopListPosition(FormWindows()\FormGadgets())
          EndIf
          
          If items = 0
            If gadgfrontcolor <> -1
              color = gadgfrontcolor
            Else
              color = RGBA(0,0,0,255)
            EndIf
            
            Select type
              Case #Form_Type_Scintilla
                DrawText(x1 + 30, y1 + 4, "ScintillaGadget", color)
              Case #Form_Type_Editor
                DrawText(x1 + 30, y1 + 4, "EditorGadget", color)
            EndSelect
          EndIf
          ;}
        Case #Form_Type_ExplorerTree ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(142,142,142,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,color)
          DrawingFont(FontID(fd_fontid))
          x = x1 + 3
          y = y1 + 3
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          DrawText(x,y,"Explorer Tree",color)
          ;}
        Case #Form_Type_ExplorerList ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(142,142,142,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,color)
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
          BackColor(RGBA(255,255,255,255))
          FrontColor(RGBA(244,244,244,255))
          LinearGradient(x1+1,y1+1,x1+1, x1+9)
          Box(x1+1,y1+1,x2 - x1-2, 8)
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          Box(x1+1,y1+9,x2 - x1-2, 6,RGBA(236,236,236,255))
          Line(x1+1,y1+15,x2-x1-2,1,RGBA(244,244,244,255))
          Line(x1+1,y1+16,x2-x1-2,1,RGBA(182,182,182,255))
          
          DrawingFont(FontID(#Form_FontColumnHeader))
          DrawText(x1 + 6,y1 +2,"Files/Drawers",RGBA(0,0,0,255))
          
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          DrawingFont(FontID(fd_fontid))
          DrawText(x1 + 6,y1 + 20,"File 1",color)
          DrawText(x1 + 6,y1 + TextHeight(" ") + 24,"File 2",color)
          ;}
        Case #Form_Type_Date ;{
          Select FormSkin
            Case #PB_OS_MacOS
              x2 - 21 - 6
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
              LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
              LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
              LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
              LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              If gadgbackcolor <> -1
                color = gadgbackcolor
              Else
                color = RGBA(255,255,255,255)
              EndIf
              Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
              DrawingFont(FontID(fd_fontid))
              x = x1 + 3
              y = y1 + (y2 - y1 - TextHeight(caption)) / 2
              
              If gadgfrontcolor <> -1
                color = gadgfrontcolor
              Else
                color = RGBA(0,0,0,255)
              EndIf
              
              DrawText(x,y,caption,color)
              DrawImage(ImageID(#Img_Date),x2 + 6,y1 + (y2 - y1 - 22) / 2)
              
            Case #PB_OS_Windows
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              If gadgbackcolor <> -1
                color = gadgbackcolor
              Else
                color = RGBA(255,255,255,255)
              EndIf
              Box(x1,y1,x2 - x1, y2 - y1,color)
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(150,150,150,255))
              DrawAlphaImage(ImageID(#Img_ArrowDown),x2 - 12,y1 + (y2 - y1 - ImageHeight(#Img_ArrowDown)) / 2)
              DrawingFont(FontID(fd_fontid))
              If gadgfrontcolor <> -1
                color = gadgfrontcolor
              Else
                color = RGBA(0,0,0,255)
              EndIf
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              DrawText(x1 + 3,y1 + (y2 - y1  - TextHeight(caption)) / 2,caption,color)
              
            Case #PB_OS_Linux
              x2 - 21 - 6
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2 - x1, y2 - y1,RGBA(165,165,165,255))
              LineXY(x1+1,y1+1,x2-2,y1+1,RGBA(227,227,227,255))
              LineXY(x1+1,y1+2,x2-2,y1+2,RGBA(245,245,245,255))
              LineXY(x1+1,y1+2,x1+1,y2-2,RGBA(245,245,245,255))
              LineXY(x2-2,y1+2,x2-2,y2-2,RGBA(245,245,245,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              If gadgbackcolor <> -1
                color = gadgbackcolor
              Else
                color = RGBA(255,255,255,255)
              EndIf
              Box(x1+2,y1+3,x2 - x1-4, y2 - y1 - 4,color)
              DrawingFont(FontID(fd_fontid))
              x = x1 + 3
              y = y1 + (y2 - y1 - TextHeight(caption)) / 2
              
              If gadgfrontcolor <> -1
                color = gadgfrontcolor
              Else
                color = RGBA(0,0,0,255)
              EndIf
              DrawText(x,y,caption,color)
              DrawImage(ImageID(#Img_Date),x2 + 6,y1 + (y2 - y1 - 22) / 2)
          EndSelect
          
          
          ;}
        Case #Form_Type_Calendar ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(255,255,255,255)
          EndIf
          Box(x1,y1,x2-x1,y2-y1,color)
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2-x1,y2-y1,RGBA(0,0,0,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          DrawingFont(FontID(fd_fontid))
          
          If gadgfrontcolor <> -1
            color = gadgfrontcolor
          Else
            color = RGBA(0,0,0,255)
          EndIf
          DrawText(x1+3,y1+3,"Calendar Gadget",color)
          ;}
        Case #Form_Type_Frame3D ;{
          Select FormSkin
            Case #PB_OS_MacOS
              If flag & FlagValue("#PB_Frame3D_Single")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
              ElseIf flag & FlagValue("#PB_Frame3D_Double")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
                Box(x1+1,y1+1,x2-x1-2,y2-y1-2,RGBA(194,194,194,255))
              ElseIf flag & FlagValue("#PB_Frame3D_Flat")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(0,0,0,255))
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(#Form_FontColumnHeader))
                DrawText(x1+10,y1,caption,RGBA(0,0,0,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                theight = TextHeight(" ")+1
                RoundBox(x1+1,y1 + theight+1,x2-x1-2,y2-y1- theight-2,3,3,RGBA(222,222,222,255))
                RoundBox(x1,y1 + theight,x2-x1,y2-y1- theight,3,3,RGBA(200,200,200,255))
              EndIf
            Case #PB_OS_Windows
              If flag & FlagValue("#PB_Frame3D_Single")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(160,160,160,255))
                Line(x1,y2,x2-x1,1,RGBA(255,255,255,255))
                Line(x2,y1,1,y2 - y1,RGBA(255,255,255,255))
              ElseIf flag & FlagValue("#PB_Frame3D_Double")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(160,160,160,255))
                Line(x1,y2,x2-x1,1,RGBA(255,255,255,255))
                Line(x2,y1,1,y2 - y1,RGBA(255,255,255,255))
                Box(x1 + 1,y1 + 1,x2-x1 - 2,y2-y1 - 2,RGBA(105,105,105,255))
                Line(x1+1,y2 -1,x2-x1-2,1,RGBA(227,227,227,255))
                Line(x2-1,y1 +1,1,y2 - y1-2,RGBA(227,227,227,255))
              ElseIf flag & FlagValue("#PB_Frame3D_Flat")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(100,100,100,255))
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Line(x1, y1 + 9, 1, y2 - y1 - 9, RGBA(221,221,221,255)) ; left
                Line(x2 - 1, y1 + 9, 1, y2 - y1 - 9, RGBA(221,221,221,255)) ; right
                Line(x1, y2 - 1, x2 - x1, 1, RGBA(221,221,221,255))         ; bottom
                                                                            ;top
                If caption <> ""
                  Line(x1, y1 + 9, 8, 1, RGBA(221,221,221,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  DrawingFont(FontID(#Form_FontColumnHeader))
                  twidth = TextWidth(caption) + 2
                  Line(x1 + 10 + twidth, y1 + 9, x2 - x1 - 10 - twidth, 1, RGBA(221,221,221,255))
                Else
                  Line(x1, y1 + 9, x2 - x1, 1, RGBA(221,221,221,255))
                EndIf
                
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(#Form_FontColumnHeader))
                DrawText(x1+10,y1,caption,RGBA(0,0,0,255),RGBA(240,240,240,255))
              EndIf
              
            Case #PB_OS_Linux
              If flag & FlagValue("#PB_Frame3D_Single")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(160,160,160,255))
                Line(x1,y2,x2-x1,1,RGBA(255,255,255,255))
                Line(x2,y1,1,y2 - y1,RGBA(255,255,255,255))
              ElseIf flag & FlagValue("#PB_Frame3D_Double")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(160,160,160,255))
                Line(x1,y2,x2-x1,1,RGBA(255,255,255,255))
                Line(x2,y1,1,y2 - y1,RGBA(255,255,255,255))
                Box(x1 + 1,y1 + 1,x2-x1 - 2,y2-y1 - 2,RGBA(105,105,105,255))
                Line(x1+1,y2 -1,x2-x1-2,1,RGBA(227,227,227,255))
                Line(x2-1,y1 +1,1,y2 - y1-2,RGBA(227,227,227,255))
              ElseIf flag & FlagValue("#PB_Frame3D_Flat")
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Box(x1,y1,x2-x1,y2-y1,RGBA(100,100,100,255))
              Else
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                Line(x1, y1 + 9, 1, y2 - y1 - 9, RGBA(221,221,221,255)) ; left
                Line(x2 - 1, y1 + 9, 1, y2 - y1 - 9, RGBA(221,221,221,255)) ; right
                Line(x1, y2 - 1, x2 - x1, 1, RGBA(221,221,221,255))         ; bottom
                                                                            ;top
                If caption <> ""
                  Line(x1, y1 + 9, 8, 1, RGBA(221,221,221,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  DrawingFont(FontID(#Form_FontColumnHeader))
                  twidth = TextWidth(caption) + 2
                  Line(x1 + 10 + twidth, y1 + 9, x2 - x1 - 10 - twidth, 1, RGBA(221,221,221,255))
                Else
                  Line(x1, y1 + 9, x2 - x1, 1, RGBA(221,221,221,255))
                EndIf
                
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(#Form_FontColumnHeader))
                DrawText(x1+10,y1,caption,RGBA(0,0,0,255),RGBA(240,240,240,255))
              EndIf
          EndSelect
          
          ;}
        Case #Form_Type_ScrollArea ;{
          Select FormSkin
            Case #PB_OS_MacOS
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
              x1+1 : x2-2 : y1+1 : y2-2
              
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              If gadgbackcolor <> -1
                color = gadgbackcolor
              Else
                color = RGBA(237, 237, 237,255)
              EndIf
              Box(x1,y1,x2-x1,y2-y1,color)
              
              oldx1 = x1: oldx2 = x2: oldy1 = y1: oldy2 = y2
              ;vscroll
              x1 = x2-14 : y2 - 14
              Line(x1,y1,1,y2-y1,RGBA(228,228,228,255))
              Line(x1+1,y1,1,y2-y1,RGBA(242,242,242,255))
              Line(x1+2,y1,1,y2-y1,RGBA(244,244,244,255))
              Line(x1+3,y1,1,y2-y1,RGBA(245,245,245,255))
              Box(x1+4,y1,10,y2-y1,RGBA(250,250,250,255))
              
              length = (y2 - y1)/3
              
              If *pointer
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                maxscroll = (FormWindows()\FormGadgets()\max + ScrollAreaW - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
                If maxscroll > 0
                  start.f = FormWindows()\FormGadgets()\scrolly / maxscroll
                  start * (y2-y1 - length)
                  RoundBox(x1 + 4,y1 + start, 8,length,3,3,RGBA(195,195,195,255))
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
              ;hscroll
              x1 = oldx1
              y2 = oldy2
              y1 = y2-14
              x2 - 14
              Line(x1,y1,x2-x1,1,RGBA(228,228,228,255))
              Line(x1,y1+1,x2-x1,1,RGBA(242,242,242,255))
              Line(x1,y1+2,x2-x1,1,RGBA(244,244,244,255))
              Line(x1,y1+3,x2-x1,1,RGBA(245,245,245,255))
              Box(x1,y1+4,x2-x1,10,RGBA(250,250,250,255))
              
              length = (x2 - x1)/3
              
              If *pointer
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                maxscroll = (FormWindows()\FormGadgets()\min + ScrollAreaW - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))
                If maxscroll > 0
                  start.f = FormWindows()\FormGadgets()\scrollx / maxscroll
                  start * (x2-x1- length)
                  RoundBox(x1 + start,y1 + 4, length,8,3,3,RGBA(195,195,195,255))
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
            Case #PB_OS_Windows
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
              x1+1 : x2-2 : y1+1 : y2-2
              
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              If gadgbackcolor <> -1
                color = gadgbackcolor
              Else
                color = RGBA(237, 237, 237,255)
              EndIf
              Box(x1,y1,x2-x1,y2-y1,color)
              
              oldx1 = x1: oldx2 = x2: oldy1 = y1: oldy2 = y2
              ;vscroll
              x1 = x2-20 : y2 - 20
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Select FormSkinVersion
                Case 7
                  Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
                  DrawAlphaImage(ImageID(#Img_ScrollUp),x1 +  (x2 - x1 - 6) / 2, y1 + 6)
                  DrawAlphaImage(ImageID(#Img_ScrollDown),x1 +  (x2 - x1 - 6) / 2, y2 - 10)
                Case 8
                  Box(x1, y1, x2 - x1, y2 - y1, RGBA(240,240,240,255))
                  Line(x1,y1,1,y2 - y1,RGBA(255,255,255,255))
                  DrawAlphaImage(ImageID(#Img_Win8ScrollUp),x1 +  (x2 - x1 - ImageWidth(#Img_Win8ScrollUp)) / 2, y1 + 5)
                  DrawAlphaImage(ImageID(#Img_Win8ScrollDown),x1 +  (x2 - x1 - ImageWidth(#Img_Win8ScrollUp)) / 2, y2 - 5 - ImageHeight(#Img_Win8ScrollDown))
              EndSelect
              length = (y2 - y1 - 34)/3
              
              If *pointer
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                maxscroll = (FormWindows()\FormGadgets()\max + ScrollAreaW - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
                If maxscroll > 0
                  start.f = FormWindows()\FormGadgets()\scrolly / maxscroll
                  start * (y2-y1-34 - length)
                  
                  Select FormSkinVersion
                    Case 7
                      RoundBox(x1 + 1,y1 + 17 + 1 + start, x2-x1-2,(y2 - y1 - 34)/3,1,1,RGBA(155,155,155,255))
                      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                      Box(x1 + 2, y1 + 17 + 2 + start, (x2-x1)*3/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(236,236,236,255))
                      Box(x1 + 2 + (x2-x1)*3/8, y1 + 17 + 2 + start, (x2-x1)*5/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(202,202,202,255))
                    Case 8
                      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                      Box(x1 + 1, y1 + 17 + start, x2 - x1 - 1,(y2 - y1 - 34)/3,RGBA(205,205,205,255))
                  EndSelect
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
              ;hscroll
              x1 = oldx1
              y2 = oldy2
              y1 = y2-20
              x2 - 20
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Select FormSkinVersion
                Case 7
                  Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
                  DrawAlphaImage(ImageID(#Img_ScrollLeft),x1 + 6, y1 + (y2 - y1 - 6) / 2)
                  DrawAlphaImage(ImageID(#Img_ScrollRight),x2 - 10, y1 + (y2 - y1 - 6) / 2)
                Case 8
                  Box(x1, y1, x2 - x1, y2 - y1, RGBA(240,240,240,255))
                  Line(x1,y1,x2 - x1,1,RGBA(255,255,255,255))
                  DrawAlphaImage(ImageID(#Img_Win8ScrollLeft),x1 + 5, y1 +  (y2 - y1 - ImageHeight(#Img_Win8ScrollLeft)) / 2)
                  DrawAlphaImage(ImageID(#Img_Win8ScrollRight),x2 - 5 - ImageWidth(#Img_Win8ScrollRight), y1 +  (y2 - y1 - ImageHeight(#Img_Win8ScrollRight)) / 2)
              EndSelect
              length = (x2 - x1 - 34)/3
              
              If *pointer
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                maxscroll = (FormWindows()\FormGadgets()\min + ScrollAreaW - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))
                If maxscroll > 0
                  start.f = FormWindows()\FormGadgets()\scrollx / maxscroll
                  start * (x2-x1-34 - length)
                  Select FormSkinVersion
                    Case 7
                      RoundBox(x1 + 17 + 1 + start,y1 + 1, (x2 - x1 - 34)/3,y2-y1-2,1,1,RGBA(155,155,155,255))
                      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                      Box(x1 + 17 + 2 + start,y1 + 2, (x2 - x1 - 34)/3 - 2,(y2-y1)*3/8 - 4,RGBA(236,236,236,255))
                      Box(x1 + 17 + 2 + start,y1 + 2 + (y2-y1)*3/8, (x2 - x1 - 34)/3 - 2,(y2-y1)*5/8 - 4,RGBA(202,202,202,255))
                    Case 8
                      DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                      Box(x1 + 17 + start, y1 + 1, (x2 - x1 - 34)/3, y2 - y1 - 1,RGBA(205,205,205,255))
                  EndSelect
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
            Case #PB_OS_Linux
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
              x1+1 : x2-2 : y1+1 : y2-2
              
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              If gadgbackcolor <> -1
                color = gadgbackcolor
              Else
                color = RGBA(237, 237, 237,255)
              EndIf
              Box(x1,y1,x2-x1,y2-y1,color)
              
              oldx1 = x1: oldx2 = x2: oldy1 = y1: oldy2 = y2
              ;vscroll
              x1 = x2-20 : y2 - 20
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
              DrawAlphaImage(ImageID(#Img_ScrollUp),x1 +  (x2 - x1 - 6) / 2, y1 + 6)
              DrawAlphaImage(ImageID(#Img_ScrollDown),x1 +  (x2 - x1 - 6) / 2, y2 - 10)
              
              length = (y2 - y1 - 34)/3
              
              If *pointer
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                maxscroll = (FormWindows()\FormGadgets()\max + ScrollAreaW - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
                If maxscroll > 0
                  start.f = FormWindows()\FormGadgets()\scrolly / maxscroll
                  start * (y2-y1-34 - length)
                  
                  RoundBox(x1 + 1,y1 + 17 + 1 + start, x2-x1-2,(y2 - y1 - 34)/3,1,1,RGBA(155,155,155,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  Box(x1 + 2, y1 + 17 + 2 + start, (x2-x1)*3/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(236,236,236,255))
                  Box(x1 + 2 + (x2-x1)*3/8, y1 + 17 + 2 + start, (x2-x1)*5/8 - 4,(y2 - y1 - 34)/3 - 2,RGBA(202,202,202,255))
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
              ;hscroll
              x1 = oldx1
              y2 = oldy2
              y1 = y2-20
              x2 - 20
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1,x2-x1,y2-y1,RGBA(233,233,233,255))
              DrawAlphaImage(ImageID(#Img_ScrollLeft),x1 + 6, y1 + (y2 - y1 - 6) / 2)
              DrawAlphaImage(ImageID(#Img_ScrollRight),x2 - 10, y1 + (y2 - y1 - 6) / 2)
              
              length = (x2 - x1 - 34)/3
              
              If *pointer
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                maxscroll = (FormWindows()\FormGadgets()\min + ScrollAreaW - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))
                If maxscroll > 0
                  start.f = FormWindows()\FormGadgets()\scrollx / maxscroll
                  start * (x2-x1-34 - length)
                  RoundBox(x1 + 17 + 1 + start,y1 + 1, (x2 - x1 - 34)/3,y2-y1-2,1,1,RGBA(155,155,155,255))
                  DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                  Box(x1 + 17 + 2 + start,y1 + 2, (x2 - x1 - 34)/3 - 2,(y2-y1)*3/8 - 4,RGBA(236,236,236,255))
                  Box(x1 + 17 + 2 + start,y1 + 2 + (y2-y1)*3/8, (x2 - x1 - 34)/3 - 2,(y2-y1)*5/8 - 4,RGBA(202,202,202,255))
                EndIf
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
          EndSelect
          ;}
        Case #Form_Type_Web ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(194,194,194,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,RGBA(255,255,255,255))
          DrawingFont(FontID(fd_fontid))
          x = x1 + 3
          y = y1 + 3
          DrawText(x,y,"Web",RGBA(0,0,0,255))
          
          ;}
        Case #Form_Type_WebView ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2 - x1, y2 - y1,RGBA(194,194,194,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          Box(x1+1,y1+1,x2 - x1-2, y2 - y1 - 2,RGBA(255,255,255,255))
          DrawingFont(FontID(fd_fontid))
          x = x1 + 3
          y = y1 + 3
          DrawText(x,y,"WebView",RGBA(0,0,0,255))
          
          ;}
        Case #Form_Type_Container,#Form_Type_Custom ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          
          If gadgbackcolor <> -1
            color = gadgbackcolor
          Else
            color = RGBA(237, 237, 237,255)
          EndIf
          
          Box(x1,y1,x2-x1,y2-y1,color)
          
          If flag & FlagValue("#PB_Container_Single") Or type = #Form_Type_Custom
            DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
            Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
          ElseIf flag & FlagValue("#PB_Container_Flat")
            DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
            Box(x1,y1,x2-x1,y2-y1,RGBA(0,0,0,255))
          ElseIf flag & FlagValue("#PB_Container_Double")
            DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
            Box(x1,y1,x2-x1,y2-y1,RGBA(130,130,130,255))
            Box(x1+1,y1+1,x2-x1-2,y2-y1-2,RGBA(194,194,194,255))
          ElseIf flag & FlagValue("#PB_Container_Raised")
            DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
            Box(x1,y1,x2-x1,y2-y1,RGBA(194,194,194,255))
            Box(x1+1,y1+1,x2-x1-2,y2-y1-2,RGBA(130,130,130,255))
          EndIf
          
          ;}
        Case #Form_Type_Panel ;{
          Select FormSkin
            Case #PB_OS_MacOS
              theight = 11
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              RoundBox(x1+2,y1 + theight + 2,x2-x1-4,y2-y1- theight-4,3,3,RGBA(231,231,231,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              RoundBox(x1+1,y1 + theight+1,x2-x1-2,y2-y1- theight-2,3,3,RGBA(222,222,222,255))
              RoundBox(x1,y1 + theight,x2-x1,y2-y1- theight,3,3,RGBA(200,200,200,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              
              If *pointer And items > 0
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                
                DrawingFont(FontID(fd_fontid))
                width = 0
                ForEach FormWindows()\FormGadgets()\Items()
                  width + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 24
                Next
                
                nx1 = (x2-x1-width) / 2
                
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Gradient)
                BackColor(RGBA(255,255,255,255))
                FrontColor(RGBA(244,244,244,255))
                LinearGradient(nx1+1,y1+1,nx1+1, nx1+9)
                Box(nx1+1,y1+1,width-2, 10)
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                Box(nx1+1,y1+11,width-2, 9,RGBA(236,236,236,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                RoundBox(nx1,y1,width, 22,3,3,RGBA(144,144,144,255))
                DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                DrawingFont(FontID(fd_fontid))
                
                ForEach FormWindows()\FormGadgets()\Items()
                  nx1 + 12
                  If FormWindows()\FormGadgets()\current_item = ListIndex( FormWindows()\FormGadgets()\Items())
                    RoundBox(nx1 - 12,y1,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 24,22,3,3,RGBA(140,140,140,255))
                    
                    If FormWindows()\FormGadgets()\current_item > 0
                      Box(nx1 - 12,y1,3,22,RGBA(140,140,140,255))
                    EndIf
                    
                    If FormWindows()\FormGadgets()\current_item < ListSize(FormWindows()\FormGadgets()\Items())-1
                      Box(nx1 + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12 - 3,y1,3,22,RGBA(140,140,140,255))
                    EndIf
                    
                    
                    color = RGBA(255,255,255,255)
                  Else
                    If ListIndex(FormWindows()\FormGadgets()\Items()) < ListSize(FormWindows()\FormGadgets()\Items())-1
                      Line(nx1 + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12,y1 + 3,1,22 - 6,RGBA(189,189,189,255))
                    EndIf
                    
                    color = RGBA(0,0,0,255)
                  EndIf
                  
                  nx1 = DrawText(nx1,y1+3,FormWindows()\FormGadgets()\Items()\name,color)
                  nx1 + 12
                Next
                
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
            Case #PB_OS_Windows
              theight = 11
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              Box(x1,y1+20,x2-x1,y2-y1-20,RGBA(137,140,140,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              Box(x1+1,y1+21,x2-x1-2,y2-y1-22,RGBA(255,255,255,255))
              
              If *pointer And items > 0
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                
                DrawingFont(FontID(fd_fontid))
                nx1 = x1
                
                ForEach FormWindows()\FormGadgets()\Items()
                  If FormWindows()\FormGadgets()\current_item = ListIndex( FormWindows()\FormGadgets()\Items())
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    Box(nx1, y1,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12,21,RGBA(137,140,140,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    Box(nx1 + 1, y1 + 1,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 10,20,RGBA(255,255,255,255))
                  Else
                    Box(nx1, y1 + 2,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12,19,RGBA(137,140,140,255))
                    Box(nx1 + 1, y1 + 3,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 10,17,RGBA(240,240,240,255))
                  EndIf
                  
                  nx1 = DrawText(nx1 + 6,y1+3,FormWindows()\FormGadgets()\Items()\name,RGBA(0,0,0,255))
                  nx1 + 6
                Next
                
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
            Case #PB_OS_Linux
              theight = 11
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
              RoundBox(x1,y1+28,x2-x1,y2-y1-28,3,3,RGBA(184,180,176,255))
              DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
              RoundBox(x1+1,y1+29,x2-x1-2,y2-y1-30,3,3,RGBA(247,246,246,255))
              Box(x1+1,y1+29,3,3,RGBA(247,246,246,255))
              Line(x1,y1+28,3,1,RGBA(184,180,176,255))
              
              If *pointer And items > 0
                PushListPosition(FormWindows()\FormGadgets())
                ChangeCurrentElement(FormWindows()\FormGadgets(),*pointer)
                
                DrawingFont(FontID(fd_fontid))
                nx1 = x1
                
                ForEach FormWindows()\FormGadgets()\Items()
                  If FormWindows()\FormGadgets()\current_item = ListIndex( FormWindows()\FormGadgets()\Items())
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    RoundBox(nx1, y1,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 14,31,3,3,RGBA(184,180,176,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    RoundBox(nx1 + 1, y1 + 1,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12,34,3,3,RGBA(247,246,246,255))
                  Else
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
                    RoundBox(nx1, y1 + 2,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 14,29,3,3,RGBA(200,197,194,255))
                    DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
                    RoundBox(nx1 + 1, y1 + 3,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12,32,3,3,RGBA(232,232,232,255))
                    
                    Box(nx1, y1 + 29,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 14,6,RGBA(247,246,246,255))
                    Line(nx1, y1 + 28,TextWidth(FormWindows()\FormGadgets()\Items()\name) + 14,1,RGBA(184,180,176,255))
                  EndIf
                  
                  nx1 = DrawText(nx1 + 6,y1+6,FormWindows()\FormGadgets()\Items()\name,RGBA(0,0,0,255))
                  nx1 + 8
                Next
                
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              Line(x1,y1+28,1,7,RGBA(184,180,176,255))
          EndSelect
          ;}
        Case #Form_Type_Canvas ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          Box(x1,y1,x2-x1,y2-y1,RGBA(237, 237, 237,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2-x1,y2-y1,RGBA(0,0,0,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          DrawingFont(FontID(fd_fontid))
          DrawText(x1+3,y1+3,"Canvas Gadget",RGBA(0,0,0,255))
          ;}
        Case #Form_Type_OpenGL ;{
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          Box(x1,y1,x2-x1,y2-y1,RGBA(237, 237, 237,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Outlined)
          Box(x1,y1,x2-x1,y2-y1,RGBA(0,0,0,255))
          DrawingMode(#PB_2DDrawing_AlphaBlend|#PB_2DDrawing_Transparent)
          DrawingFont(FontID(fd_fontid))
          DrawText(x1+3,y1+3,"OpenGL Gadget",RGBA(0,0,0,255))
          ;}
      EndSelect
      
      If *pointer
        PopListPosition(FormWindows()\FormGadgets())
      EndIf
      
      StopDrawing()
      StartDrawing(ImageOutput(#Drawing_Img))
      DrawingMode(#PB_2DDrawing_Transparent)
      If ox1 < xmin Or ox2 > xmax Or oy1 < ymin Or oy2 > ymax ; fast check to avoid using slow filter
        DrawingMode(#PB_2DDrawing_CustomFilter)
        CustomFilterCallback(@FD_FilterCallback())
      EndIf
      
      DrawAlphaImage(ImageID(#TDrawing_Img),ox1,oy1)
      
      ProcedureReturn #True ; Drawing succeeded
    Else
      MessageRequester(#ProductName$, LanguagePattern("Form","OutOfMemoryError", "%size%", Str(x2-x1) +"x"+ Str(y2-y1)), #PB_MessageRequester_Ok | #FLAG_Error) ; Can't create the backend image, so we are probably out of memory (we don't want the IDE to crash !)
    EndIf
  EndIf
EndProcedure

Procedure FD_GetGadgetXY(gadget,xy)
  oldgadget = gadget
  PushListPosition(FormWindows()\FormGadgets())
  FD_FindParent(gadget)
  width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
  height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
  PopListPosition(FormWindows()\FormGadgets())
  
  While gadget <> 0
    PushListPosition(FormWindows()\FormGadgets())
    FD_FindParent(gadget)
    
    x1 + FormWindows()\FormGadgets()\x1
    y1 + FormWindows()\FormGadgets()\y1
    
    If gadget <> oldgadget And FormWindows()\FormGadgets()\y1 + FormWindows()\FormGadgets()\scrolly >0
      y1 - FormWindows()\FormGadgets()\scrolly
    EndIf
    If gadget <> oldgadget And FormWindows()\FormGadgets()\x1 + FormWindows()\FormGadgets()\scrollx >0
      x1 - FormWindows()\FormGadgets()\scrollx
    EndIf
    
    If FormWindows()\FormGadgets()\type = #Form_Type_Panel And FormWindows()\FormGadgets()\y1 + Panel_Height > 0 And gadget <> oldgadget
      y1 + Panel_Height
    EndIf
    
    gadget = FormWindows()\FormGadgets()\parent
    PopListPosition(FormWindows()\FormGadgets())
  Wend
  
  If xy = 0
    ProcedureReturn x1 + width
  ElseIf xy = 1
    ProcedureReturn y1 + height
  ElseIf xy = 2
    ProcedureReturn x1
  ElseIf xy = 3
    ProcedureReturn y1
  EndIf
EndProcedure

Procedure FD_UpdateSplitter()
  PushListPosition(FormWindows()\FormGadgets())
  countsplitter = 0
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
      countsplitter + 1
    EndIf
  Next
  PopListPosition(FormWindows()\FormGadgets())
  
  For i = 1 To countsplitter
    PushListPosition(FormWindows()\FormGadgets())
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
        
        s_x1 = FormWindows()\FormGadgets()\x1
        s_x2 = FormWindows()\FormGadgets()\x2
        s_y1 = FormWindows()\FormGadgets()\y1
        s_y2 = FormWindows()\FormGadgets()\y2
        
        s_g1 = FormWindows()\FormGadgets()\gadget1
        s_g2 = FormWindows()\FormGadgets()\gadget2
        s_vertical = FormWindows()\FormGadgets()\flags & FlagValue("#PB_Splitter_Vertical")
        s_pos = FormWindows()\FormGadgets()\state
        
        PushListPosition(FormWindows()\FormGadgets())
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\itemnumber = s_g1
            If s_vertical
              FormWindows()\FormGadgets()\x1 = s_x1
              FormWindows()\FormGadgets()\x2 = s_x1 + s_pos
              FormWindows()\FormGadgets()\y1 = s_y1
              FormWindows()\FormGadgets()\y2 = s_y2
            Else
              FormWindows()\FormGadgets()\x1 = s_x1
              FormWindows()\FormGadgets()\x2 = s_x2
              FormWindows()\FormGadgets()\y1 = s_y1
              FormWindows()\FormGadgets()\y2 = s_y1 + s_pos
            EndIf
          EndIf
          If FormWindows()\FormGadgets()\itemnumber = s_g2
            If s_vertical
              FormWindows()\FormGadgets()\x1 = s_x1 + s_pos + P_SplitterWidth
              FormWindows()\FormGadgets()\x2 = s_x2
              FormWindows()\FormGadgets()\y1 = s_y1
              FormWindows()\FormGadgets()\y2 = s_y2
            Else
              FormWindows()\FormGadgets()\x1 = s_x1
              FormWindows()\FormGadgets()\x2 = s_x2
              FormWindows()\FormGadgets()\y1 = s_y1 + s_pos + P_SplitterWidth
              FormWindows()\FormGadgets()\y2 = s_y2
            EndIf
          EndIf
        Next
        redraw = 1
        PopListPosition(FormWindows()\FormGadgets())
      EndIf
    Next
    PopListPosition(FormWindows()\FormGadgets())
  Next
EndProcedure

Procedure FD_LeftDown(x,y)
  ChangeCurrentElement(FormWindows(),currentwindow)
  
  ; Status bar selection
  statusselected = 0
  If ListSize(FormWindows()\FormStatusbars()) Or FormWindows()\status_visible
    ForEach FormWindows()\FormStatusbars()
      If x >= FormWindows()\FormStatusbars()\x1 And x <= FormWindows()\FormStatusbars()\x2 And y >= FormWindows()\FormStatusbars()\y And y <= FormWindows()\FormStatusbars()\y + bottompaddingsb
        FD_SelectStatusBar(FormWindows()\FormStatusbars())
        statusselected = 1
        
        ForEach FormWindows()\FormGadgets()
          FormWindows()\FormGadgets()\selected = 0
        Next
        
        ProcedureReturn
      EndIf
    Next
    
    If x >= FormWindows()\status_buttonx And x <= FormWindows()\status_buttonx + 16 And y >= FormWindows()\status_buttony And y <= FormWindows()\status_buttony + bottompaddingsb
      DisplayPopupMenu(#Form_Menu11,WindowID(#WINDOW_Main))
      ProcedureReturn
    EndIf
  EndIf
  
  ; Menu bar selection
  menuselected = 0
  If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
    ForEach FormWindows()\FormMenus()
      If x >= FormWindows()\FormMenus()\x1 And x <= FormWindows()\FormMenus()\x2 And y >= FormWindows()\FormMenus()\y1 And y <= FormWindows()\FormMenus()\y2
        menuselected = FormWindows()\FormMenus()
        
        ForEach FormWindows()\FormGadgets()
          FormWindows()\FormGadgets()\selected = 0
        Next
        
        ProcedureReturn
      EndIf
    Next
    
    ForEach FormWindows()\FormMenuButtons()
      If x >= FormWindows()\FormMenuButtons()\x1 And x <= FormWindows()\FormMenuButtons()\x2 And y >= FormWindows()\FormMenuButtons()\y1 And y <= FormWindows()\FormMenuButtons()\y2
        FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
        ChangeCurrentElement(FormWindows()\FormMenus(),FormWindows()\FormMenuButtons()\previous_el)
        level = FormWindows()\FormMenuButtons()\level
        AddElement(FormWindows()\FormMenus())
        FormWindows()\FormMenus()\level = level
        FormWindows()\FormMenus()\item = "MenuItem" + Str(ListSize(FormWindows()\FormMenus()))
        FormWindows()\FormMenus()\id = "#MenuItem_" + Str(ListSize(FormWindows()\FormMenus()))
        menuselected = FormWindows()\FormMenus()
        FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
        FormChanges(1)
        ProcedureReturn
      EndIf
    Next
    
    
    If x >= FormWindows()\menu_buttonx And x <= FormWindows()\menu_buttonx + 16 And y >= FormWindows()\menu_buttony And y <= FormWindows()\menu_buttony + 16
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
      LastElement(FormWindows()\FormMenus())
      AddElement(FormWindows()\FormMenus())
      FormWindows()\FormMenus()\level = 0
      FormWindows()\FormMenus()\item = "MenuTitle"
      redraw = 1
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
      FormChanges(1)
      ProcedureReturn
    EndIf
  EndIf
  
  ; Toolbar selection
  toolselected = 0
  If ListSize(FormWindows()\FormToolbars()) Or FormWindows()\toolbar_visible
    ForEach FormWindows()\FormToolbars()
      If x >= FormWindows()\FormToolbars()\x1 And x <= FormWindows()\FormToolbars()\x2 And y >= FormWindows()\FormToolbars()\y And y <= FormWindows()\FormToolbars()\y + 16
        FD_SelectToolbar(FormWindows()\FormToolbars())
        toolselected = 1
        
        ForEach FormWindows()\FormGadgets()
          FormWindows()\FormGadgets()\selected = 0
        Next
        
        ProcedureReturn
      EndIf
    Next
    
    If x >= FormWindows()\toolbar_buttonx And x <= FormWindows()\toolbar_buttonx + 16 And y >= FormWindows()\toolbar_buttony And y <= FormWindows()\toolbar_buttony + 16
      DisplayPopupMenu(#Form_Menu8,WindowID(#WINDOW_Main))
      ProcedureReturn
    EndIf
  EndIf
  
  
  px = FD_AlignPoint(x - leftpadding + FormWindows()\paddingx - #Page_Padding)
  py = FD_AlignPoint(y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding)
  x + FormWindows()\paddingx - #Page_Padding - leftpadding
  y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding
  
  ; Resizing?
  count_select = 0
  ForEach FormWindows()\FormGadgets()
    count_select + FormWindows()\FormGadgets()\selected
  Next
  
  parent = 0
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected And FormWindows()\FormGadgets()\splitter = 0
      this_parent = FormWindows()\FormGadgets()\parent
      
      If this_parent
        a_x1 = 0 : a_x2 = 0 : a_y1 = 0 : a_y2 = 0
      Else
        a_x1 = 0 : a_x2 = 10000 : a_y1 = 0 : a_y2 = 10000
      EndIf
      
      x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
      While this_parent <> 0
        PushListPosition(FormWindows()\FormGadgets())
        FD_FindParent(this_parent)
        this_parent = FormWindows()\FormGadgets()\parent
        
        x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
        x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
        y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
        y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
        
        a_x1 + FormWindows()\FormGadgets()\x1
        a_x2 + FormWindows()\FormGadgets()\x2
        a_y1 + FormWindows()\FormGadgets()\y1
        a_y2 + FormWindows()\FormGadgets()\y2
        
        If FormWindows()\FormGadgets()\type = #Form_Type_Panel
          y1 + Panel_Height
          y2 + Panel_Height
        EndIf
        
        PopListPosition(FormWindows()\FormGadgets())
      Wend
      
      x1 + FormWindows()\FormGadgets()\x1 - scrollx
      x2 + FormWindows()\FormGadgets()\x2 - scrollx
      y1 + FormWindows()\FormGadgets()\y1 - scrolly
      y2 + FormWindows()\FormGadgets()\y2 - scrolly
      
      If x > a_x1 And x <= a_x2 And y >= a_y1 And y <= a_y2
        If FD_CheckPoint(x,y,x1,y1) ; top left
          FormWindows()\FormGadgets()\resizing = #Form_Resize_TopLeft
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,x2,y1) ; top right
          FormWindows()\FormGadgets()\resizing = #Form_Resize_TopRight
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,(x2 + x1) / 2,y1) ; top middle
          FormWindows()\FormGadgets()\resizing = #Form_Resize_TopMiddle
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,x1,y2) ; bottom left
          FormWindows()\FormGadgets()\resizing = #Form_Resize_BottomLeft
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,x2,y2) ; bottom right
          FormWindows()\FormGadgets()\resizing = #Form_Resize_BottomRight
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,(x2 + x1) / 2,y2) ; bottom middle
          FormWindows()\FormGadgets()\resizing = #Form_Resize_BottomMiddle
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,x1,(y2 + y1) / 2) ; middle left
          FormWindows()\FormGadgets()\resizing = #Form_Resize_MiddleLeft
          FormWindows()\FormGadgets()\selected = 1
        ElseIf FD_CheckPoint(x,y,x2,(y2 + y1) / 2) ; middle right
          FormWindows()\FormGadgets()\resizing = #Form_Resize_MiddleRight
          FormWindows()\FormGadgets()\selected = 1
        EndIf
        
        If FormWindows()\FormGadgets()\selected
          FD_SelectGadget(FormWindows()\FormGadgets())
        EndIf
        
        If FormWindows()\FormGadgets()\resizing
          resizing = FormWindows()\FormGadgets()
          Break
        EndIf
      EndIf
    EndIf
    
    If Not (GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Modifiers) & #PB_Canvas_Command)
      If count_select < 2
        FormWindows()\FormGadgets()\selected = 0
      EndIf
    EndIf
  Next
  
  If Not resizing
    If LastElement(FormWindows()\FormGadgets())
      Repeat
        this_parent = FormWindows()\FormGadgets()\parent
        this_parent_item = FormWindows()\FormGadgets()\parent_item
        hidden = 0
        
        If this_parent
          a_x1 = 0 : a_x2 = 0 : a_y1 = 0 : a_y2 = 0
        Else
          a_x1 = 0 : a_x2 = 10000 : a_y1 = 0 : a_y2 = 10000
        EndIf
        
        x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
        While this_parent <> 0
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(this_parent)
          
          If FormWindows()\FormGadgets()\current_item <> this_parent_item And this_parent_item <> -1
            hidden = 1
          EndIf
          
          If FormWindows()\FormGadgets()\hidden
            hidden = 1
          EndIf
          
          this_parent = FormWindows()\FormGadgets()\parent
          this_parent_item = FormWindows()\FormGadgets()\parent_item
          
          x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
          x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
          y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
          y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
          
          a_x1 + FormWindows()\FormGadgets()\x1
          a_x2 + FormWindows()\FormGadgets()\x2
          a_y1 + FormWindows()\FormGadgets()\y1
          a_y2 + FormWindows()\FormGadgets()\y2
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Panel
            y1 + Panel_Height
            y2 + Panel_Height
          EndIf
          PopListPosition(FormWindows()\FormGadgets())
        Wend
        
        x1 + FormWindows()\FormGadgets()\x1 - scrollx
        x2 + FormWindows()\FormGadgets()\x2 - scrollx
        y1 + FormWindows()\FormGadgets()\y1 - scrolly
        y2 + FormWindows()\FormGadgets()\y2 - scrolly
        
        If FormWindows()\FormGadgets()\hidden
          hidden = 1
        EndIf
        
        If (x > x1 And x <= x2 And y >= y1 And y <= y2) And (x > a_x1 And x <= a_x2 And y >= a_y1 And y <= a_y2) And Not hidden
          Select FormWindows()\FormGadgets()\type
            Case #Form_Type_Splitter
              If FormWindows()\FormGadgets()\flags & FlagValue("#PB_Splitter_Vertical")
                check = FD_CheckPoint(x,0,x1 + FormWindows()\FormGadgets()\state + P_SplitterWidth / 2,0,P_SplitterWidth / 2)
              Else
                check = FD_CheckPoint(0,y,0,y1 + FormWindows()\FormGadgets()\state + P_SplitterWidth / 2,P_SplitterWidth / 2)
              EndIf
              
              If FD_CheckPoint(x,0,x1,0,4) Or FD_CheckPoint(x,0,x2,0,4) Or FD_CheckPoint(0,y,0,y1,4) Or FD_CheckPoint(0,y,0,y2,4) Or check
                FormWindows()\FormGadgets()\selected = 1
                FD_SelectGadget(FormWindows()\FormGadgets())
                moving = FormWindows()\FormGadgets()
                moving_x = px
                moving_y = py
                moving_firstx = px
                moving_firsty = py
                FormWindows()\FormGadgets()\oldx = FormWindows()\FormGadgets()\x1
                FormWindows()\FormGadgets()\oldy = FormWindows()\FormGadgets()\y1
                splittersel = 1
              EndIf
            Case #Form_Type_Container, #Form_Type_Panel, #Form_Type_ScrollArea, #Form_Type_Frame3D
              
              ; tab selection for panel gadget
              If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                If y >= y1 And y <= y1 + Panel_Height
                  StartDrawing(ImageOutput(#Drawing_Img))
                  DrawingFont(FontID(#Form_Font))
                  width = 0
                  ForEach FormWindows()\FormGadgets()\Items()
                    width + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 24
                  Next
                  
                  Select FormSkin
                    Case #PB_OS_MacOS
                      nx1 = x1 + (x2-x1-width) / 2
                      ForEach FormWindows()\FormGadgets()\Items()
                        nx2 = nx1 + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 24
                        If x >= nx1 And x <= nx2
                          FormWindows()\FormGadgets()\current_item = ListIndex(FormWindows()\FormGadgets()\Items())
                          Break
                        EndIf
                        
                        nx1 = nx2
                      Next
                    Case #PB_OS_Windows
                      nx1 = x1
                      ForEach FormWindows()\FormGadgets()\Items()
                        nx2 = nx1 + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12
                        If x >= nx1 And x <= nx2
                          FormWindows()\FormGadgets()\current_item = ListIndex(FormWindows()\FormGadgets()\Items())
                          Break
                        EndIf
                        
                        nx1 = nx2
                      Next
                    Case #PB_OS_Linux
                      nx1 = x1
                      ForEach FormWindows()\FormGadgets()\Items()
                        nx2 = nx1 + TextWidth(FormWindows()\FormGadgets()\Items()\name) + 12
                        If x >= nx1 And x <= nx2
                          FormWindows()\FormGadgets()\current_item = ListIndex(FormWindows()\FormGadgets()\Items())
                          Break
                        EndIf
                        
                        nx1 = nx2
                      Next
                  EndSelect
                  
                  StopDrawing()
                EndIf
              EndIf
              
              If FD_CheckPoint(x,0,x1,0,4) Or FD_CheckPoint(x,0,x2,0,4) Or FD_CheckPoint(0,y,0,y1,4) Or FD_CheckPoint(0,y,0,y2,4) Or (FormWindows()\FormGadgets()\type = #Form_Type_Panel And y <= y1 + Panel_Height)
                FormWindows()\FormGadgets()\selected = 1
                FD_SelectGadget(FormWindows()\FormGadgets())
                
                If FormWindows()\FormGadgets()\splitter = 0
                  FormWindows()\FormGadgets()\oldx = FormWindows()\FormGadgets()\x1
                  FormWindows()\FormGadgets()\oldy = FormWindows()\FormGadgets()\y1
                  
                  moving = FormWindows()\FormGadgets()
                  moving_x = px
                  moving_y = py
                  moving_firstx = px
                  moving_firsty = py
                  Break
                Else
                  PushListPosition(FormWindows()\FormGadgets())
                  
                  splitter = FormWindows()\FormGadgets()\splitter
                  ForEach FormWindows()\FormGadgets()
                    If FormWindows()\FormGadgets()\itemnumber = splitter
                      s_gadget1 = FormWindows()\FormGadgets()\gadget1
                      s_gadget2 = FormWindows()\FormGadgets()\gadget2
                      
                      ; Deselect the two inner gadgets
                      ForEach FormWindows()\FormGadgets()
                        If FormWindows()\FormGadgets()\itemnumber = s_gadget1 Or FormWindows()\FormGadgets()\itemnumber = s_gadget2
                          FormWindows()\FormGadgets()\selected = 0
                        EndIf
                      Next
                      
                      Break ; quit the loop
                    EndIf
                  Next
                  
                  PopListPosition(FormWindows()\FormGadgets())
                  
                  FormWindows()\FormGadgets()\selected = 1
                  FD_SelectGadget(FormWindows()\FormGadgets())
                  redraw = 1
                  splittersel = 1
                  Break
                EndIf
                
              ElseIf (y >= y2 - ScrollAreaW) And FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
                scrollingx = FormWindows()\FormGadgets()
                scrolling = x
              ElseIf (x >= x2 - ScrollAreaW) And FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
                scrollingy = FormWindows()\FormGadgets()
                scrolling = y
              Else
                If FormWindows()\FormGadgets()\type <> #Form_Type_Frame3D And FormWindows()\FormGadgets()\type <> #Form_Type_Splitter
                  parent = FormWindows()\FormGadgets()\itemnumber
                  Break
                EndIf
              EndIf
              
              
            Default
              If FormWindows()\FormGadgets()\splitter
                PushListPosition(FormWindows()\FormGadgets())
                splitter = FormWindows()\FormGadgets()\splitter
                ForEach FormWindows()\FormGadgets()
                  If FormWindows()\FormGadgets()\itemnumber = splitter
                    s_gadget1 = FormWindows()\FormGadgets()\gadget1
                    s_gadget2 = FormWindows()\FormGadgets()\gadget2
                  EndIf
                Next
                
                ForEach FormWindows()\FormGadgets()
                  If FormWindows()\FormGadgets()\itemnumber = s_gadget1
                    FormWindows()\FormGadgets()\selected = 0
                  EndIf
                  If FormWindows()\FormGadgets()\itemnumber = s_gadget2
                    FormWindows()\FormGadgets()\selected = 0
                  EndIf
                Next
                
                PopListPosition(FormWindows()\FormGadgets())
              EndIf
              
              FormWindows()\FormGadgets()\selected = 1
              FD_SelectGadget(FormWindows()\FormGadgets())
              If FormWindows()\FormGadgets()\splitter = 0
                moving = FormWindows()\FormGadgets()
                moving_x = px
                moving_y = py
                moving_firstx = px
                moving_firsty = py
                addaction = 1
                ForEach FormWindows()\FormGadgets()
                  If FormWindows()\FormGadgets()\selected
                    addaction = 0
                    FormWindows()\FormGadgets()\oldx = FormWindows()\FormGadgets()\x1
                    FormWindows()\FormGadgets()\oldy = FormWindows()\FormGadgets()\y1
                  EndIf
                Next
                ProcedureReturn
              Else
                redraw = 1
                splittersel = 1
                Break
              EndIf
          EndSelect
        EndIf
      Until PreviousElement(FormWindows()\FormGadgets()) = 0
    EndIf
    
    ; resizing window?
    Select FormSkin
      Case #PB_OS_MacOS
        winx = FormWindows()\width + 2
        winy =  FormWindows()\height + 2
      Case #PB_OS_Windows
        winx = FormWindows()\width + 8 + 2
        winy = FormWindows()\height + 8 + 2
      Case #PB_OS_Linux
        winx = FormWindows()\width + 2
        winy =  FormWindows()\height + 2
    EndSelect
    
    Select FormSkin
      Case #PB_OS_Windows
        y + toptoolpadding + topmenupadding
      Case #PB_OS_Linux
        y + toptoolpadding + topmenupadding
    EndSelect
    
    If FD_CheckPoint(x,y,winx,winy)
      FormAddUndoAction(1,FormWindows())
      
      resizing_win = 1
    EndIf
    
    Select FormSkin
      Case #PB_OS_Windows
        y - toptoolpadding - topmenupadding
      Case #PB_OS_Linux
        y - toptoolpadding - topmenupadding
    EndSelect
    
    If Not moving And Not scrollingx And Not scrollingy And Not resizing_win And Not splittersel
      count_select = 0
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\selected
          count_select + 1
        EndIf
      Next
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\selected And count_select = 1 And (FormWindows()\FormGadgets()\type = #Form_Type_Container Or FormWindows()\FormGadgets()\type = #Form_Type_Panel Or FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea Or FormWindows()\FormGadgets()\type = #Form_Type_Frame3D)
        Else
          FormWindows()\FormGadgets()\selected = 0
        EndIf
      Next
      
      If form_gadget_type > -1
        If form_gadget_type <= 0
          form_gadget_type = #Form_Type_Button
        EndIf
        
        drawing = 1
        d_x = px
        d_y = py
        
        d_x1 = px
        d_y1 = py
        d_x2 = px
        d_y2 = py
      EndIf
      
      If Not drawing And Not count_select
        SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_Cross)
        multiselectStart = #True
        multiselectFirstScan = #True
        multiselectParent = -1
      EndIf
    EndIf
  EndIf
  
  redraw = 1
EndProcedure

Procedure FD_Move(x,y)
  ChangeCurrentElement(FormWindows(),currentwindow)
  px = FD_AlignPoint(x - leftpadding + FormWindows()\paddingx - #Page_Padding)
  py = FD_AlignPoint(y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding)
  
  Select FormSkin
    Case #PB_OS_Windows
      px_win = FD_AlignPoint(px - 8)
      py_win = FD_AlignPoint(y + FormWindows()\paddingy - #Page_Padding - topwinpadding - 8)
    Case #PB_OS_Linux
      px_win = px
      py_win = FD_AlignPoint(y + FormWindows()\paddingy - #Page_Padding - topwinpadding)
    Case #PB_OS_MacOS
      px_win = px
      py_win = py
  EndSelect
  
  If toolselected
    tooldragpos = x
    redraw = 1
  EndIf
  If statusselected
    statusdragpos = x
    redraw = 1
  EndIf
  If menuselected
    menudragposx = x
    menudragposy = y
    redraw = 1
  EndIf
  
  
  x + FormWindows()\paddingx - #Page_Padding - leftpadding
  y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding
  
  If px > FormWindows()\width
    px = FormWindows()\width
  ElseIf px < 0
    px = 0
  EndIf
  
  limit = FormWindows()\height - bottompaddingsb
  
  If FormSkin <> #PB_OS_MacOS
    limit - toptoolpadding - topmenupadding
  EndIf
  
  If py > limit
    py = limit
  ElseIf py < 0
    py = 0
  EndIf
  
  
  If drawing ;{
    d_width = px - d_x
    d_height = py - d_y
    
    If d_width > 0
      d_x1 = d_x
      d_x2 = d_x + d_width
    Else
      d_x1 = d_x + d_width
      d_x2 = d_x
    EndIf
    
    If d_height > 0
      d_y1 = d_y
      d_y2 = d_y + d_height
    Else
      d_y2 = d_y
      d_y1 = d_y + d_height
    EndIf
    
    If d_x1 < 0
      d_x1 = 0
    ElseIf d_x1 > FormWindows()\width
      d_x1 = FormWindows()\width
    EndIf
    If d_x2 < 0
      d_x2 = 0
    ElseIf d_x2 > FormWindows()\width
      d_x2 = FormWindows()\width
    EndIf
    If d_y1 < 0
      d_y1 = 0
    ElseIf d_y1 > FormWindows()\height
      d_y1 = FormWindows()\height
    EndIf
    If d_y2 < 0
      d_y2 = 0
    ElseIf d_y2 > FormWindows()\height
      d_y2 = FormWindows()\height
    EndIf
    
    redraw = 1
  EndIf ;}
  
  If moving ;{
    moving_x = px
    moving_y = py
    slidex = moving_x - moving_firstx
    slidey = moving_y - moving_firsty
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\selected
        newx1 = FormWindows()\FormGadgets()\oldx + slidex
        newx2 = FormWindows()\FormGadgets()\oldx + FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 + slidex
        newy1 = FormWindows()\FormGadgets()\oldy + slidey
        newy2 = FormWindows()\FormGadgets()\oldy + FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 + slidey
        
        this_parent = FormWindows()\FormGadgets()\parent
        x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
        If this_parent
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(this_parent)
          
          If FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
            x2 + FormWindows()\FormGadgets()\min
            y2 + FormWindows()\FormGadgets()\max
          Else
            x2 + FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
            y2 + FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
          EndIf
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Panel
            y2 + Panel_Height
          EndIf
          
          PopListPosition(FormWindows()\FormGadgets())
        EndIf
        
        If y2 = 0
          y2 = FormWindows()\height - bottompaddingsb
          If FormSkin = #PB_OS_MacOS
            y2 - toptoolpadding - topmenupadding
          EndIf
        EndIf
        
        If x2 = 0
          x2 = FormWindows()\width
        EndIf
        
        If newy1 < 0
          newy2 - newy1
          newy1 = 0
        EndIf
        
        If newx1 < 0
          newx2 - newx1
          newx1 = 0
        EndIf
        
        If newy2 > y2
          newy1 - (newy2 - y2)
          newy2 = y2
        EndIf
        
        If newx2 > x2
          newx1 - (newx2 - x2)
          newx2 = x2
        EndIf
        
        If Not moveresizeundo And (FormWindows()\FormGadgets()\x2 <> newx2 Or FormWindows()\FormGadgets()\x1 <> newx1 Or FormWindows()\FormGadgets()\y2 <> newy2 Or FormWindows()\FormGadgets()\y1 <> newy1)
          FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
          moveundo = 1
        EndIf
        
        If (FormWindows()\FormGadgets()\x2 <> newx2 Or FormWindows()\FormGadgets()\x1 <> newx1 Or FormWindows()\FormGadgets()\y2 <> newy2 Or FormWindows()\FormGadgets()\y1 <> newy1)
          redraw = 1
        EndIf
        
        FormWindows()\FormGadgets()\x2 = newx2
        FormWindows()\FormGadgets()\x1 = newx1
        FormWindows()\FormGadgets()\y2 = newy2
        FormWindows()\FormGadgets()\y1 = newy1
      EndIf
    Next
    If moveundo
      moveresizeundo = 1
    EndIf
    
    ChangeCurrentElement(FormWindows()\FormGadgets(),moving)
    ; avoid if possible to redraw the grid
    If redraw And propgrid
      grid_SetCellString(propgrid,2,8,Str(FormWindows()\FormGadgets()\x1))
      grid_SetCellString(propgrid,2,9,Str(FormWindows()\FormGadgets()\y1))
      grid_SetCellString(propgrid,2,10,Str(FormWindows()\FormGadgets()\x2-FormWindows()\FormGadgets()\x1))
      grid_SetCellString(propgrid,2,11,Str(FormWindows()\FormGadgets()\y2-FormWindows()\FormGadgets()\y1))
    EndIf
    
    moving_x = px
    moving_y = py
    FD_UpdateSplitter()
    FormChanges(1)
  EndIf ;}
  
  If scrollingx ;{
    ChangeCurrentElement(FormWindows()\FormGadgets(),scrollingx)
    
    Select FormSkin
      Case #PB_OS_MacOS
        scrollwidth = (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)/3
      Case #PB_OS_Windows
        scrollwidth = (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)/3 + 34
      Case #PB_OS_Linux
        scrollwidth = (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)/3 + 34
    EndSelect
    
    delta + ((x-scrolling) / (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 - P_ScrollWidth)) * (FormWindows()\FormGadgets()\min - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1) + scrollwidth)
    
    FormWindows()\FormGadgets()\scrollx + Int(delta)
    
    If FormWindows()\FormGadgets()\scrollx < 0
      FormWindows()\FormGadgets()\scrollx = 0
      scrolling = x
    ElseIf FormWindows()\FormGadgets()\scrollx > (FormWindows()\FormGadgets()\min + ScrollAreaW - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))
      FormWindows()\FormGadgets()\scrollx = (FormWindows()\FormGadgets()\min + ScrollAreaW - (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1))
      scrolling = x
    Else
      scrolling = x
      delta - Int(delta)
      redraw = 1
    EndIf
  EndIf ;}
  
  If scrollingy ;{
    ChangeCurrentElement(FormWindows()\FormGadgets(),scrollingy)
    
    Select FormSkin
      Case #PB_OS_MacOS
        scrollwidth = (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)/3
      Case #PB_OS_Windows
        scrollwidth = (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)/3 + 34
      Case #PB_OS_Linux
        scrollwidth = (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)/3 + 34
    EndSelect
    
    delta + ((y-scrolling) / (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 - P_ScrollWidth)) * (FormWindows()\FormGadgets()\max - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1) + scrollwidth)
    
    FormWindows()\FormGadgets()\scrolly + Int(delta)
    
    If FormWindows()\FormGadgets()\scrolly < 0
      FormWindows()\FormGadgets()\scrolly = 0
      scrolling = y
    ElseIf FormWindows()\FormGadgets()\scrolly > (FormWindows()\FormGadgets()\max + ScrollAreaW - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
      FormWindows()\FormGadgets()\scrolly = (FormWindows()\FormGadgets()\max + ScrollAreaW - (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1))
      scrolling = y
    Else
      scrolling = y
      delta - Int(delta)
      redraw = 1
    EndIf
  EndIf ;}
  
  If resizing ;{
    ChangeCurrentElement(FormWindows()\FormGadgets(),resizing)
    
    this_parent = FormWindows()\FormGadgets()\parent
    x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
    While this_parent <> 0
      PushListPosition(FormWindows()\FormGadgets())
      FD_FindParent(this_parent)
      this_parent = FormWindows()\FormGadgets()\parent
      
      x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
      x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
      y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
      y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
      
      If FormWindows()\FormGadgets()\type = #Form_Type_Panel
        y1 + Panel_Height
        y2 + Panel_Height
      EndIf
      
      PopListPosition(FormWindows()\FormGadgets())
    Wend
    
    x1 - scrollx
    x2 - scrollx
    y1 - scrolly
    y2 - scrolly
    If Not moveresizeundo
      FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
      resizeundo = 1
      moveresizeundo = 1
    EndIf
    
    resoldx1 = FormWindows()\FormGadgets()\x1
    resoldx2 = FormWindows()\FormGadgets()\x2
    resoldy1 = FormWindows()\FormGadgets()\y1
    resoldy2 = FormWindows()\FormGadgets()\y2
    
    resizetype = FormWindows()\FormGadgets()\resizing
    
    Select FormWindows()\FormGadgets()\resizing
      Case #Form_Resize_TopLeft
        FormWindows()\FormGadgets()\x1 = px - x1
        FormWindows()\FormGadgets()\y1 = py - y1
        
        If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
          FormWindows()\FormGadgets()\x1 = FormWindows()\FormGadgets()\x2 - FormGridSize
        EndIf
        If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
          FormWindows()\FormGadgets()\y1 = FormWindows()\FormGadgets()\y2 - FormGridSize
        EndIf
        
      Case #Form_Resize_TopMiddle
        FormWindows()\FormGadgets()\y1 = py - y1
        
        If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
          FormWindows()\FormGadgets()\y1 = FormWindows()\FormGadgets()\y2 - FormGridSize
        EndIf
        
      Case #Form_Resize_TopRight
        FormWindows()\FormGadgets()\x2 = px - x1
        FormWindows()\FormGadgets()\y1 = py - y1
        
        If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
          FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormGridSize
        EndIf
        If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
          FormWindows()\FormGadgets()\y1 = FormWindows()\FormGadgets()\y2 - FormGridSize
        EndIf
        
      Case #Form_Resize_BottomLeft
        FormWindows()\FormGadgets()\x1 = px - x1
        FormWindows()\FormGadgets()\y2 = py - y1
        
        If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
          FormWindows()\FormGadgets()\x1 = FormWindows()\FormGadgets()\x2 - FormGridSize
        EndIf
        If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
          FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + FormGridSize
        EndIf
        
      Case #Form_Resize_BottomMiddle
        FormWindows()\FormGadgets()\y2 = py - y1
        
        If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
          FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + FormGridSize
        EndIf
        
      Case #Form_Resize_BottomRight
        FormWindows()\FormGadgets()\x2 = px - x1
        FormWindows()\FormGadgets()\y2 = py - y1
        
        If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
          FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormGridSize
        EndIf
        If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
          FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + FormGridSize
        EndIf
        
      Case #Form_Resize_MiddleLeft
        FormWindows()\FormGadgets()\x1 = px - x1
        
        If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
          FormWindows()\FormGadgets()\x1 = FormWindows()\FormGadgets()\x2 - FormGridSize
        EndIf
        
      Case #Form_Resize_MiddleRight
        FormWindows()\FormGadgets()\x2 = px - x1
        
        If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
          FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormGridSize
        EndIf
    EndSelect
    
    resizex1 = FormWindows()\FormGadgets()\x1 - resoldx1
    resizex2 = FormWindows()\FormGadgets()\x2 - resoldx2
    resizey1 = FormWindows()\FormGadgets()\y1 - resoldy1
    resizey2 = FormWindows()\FormGadgets()\y2 - resoldy2
    
    
    ; avoid if possible to redraw the grid or drawing area
    If propgrid And (resoldx1 <> FormWindows()\FormGadgets()\x1 Or resoldx2 <> FormWindows()\FormGadgets()\x2 Or resoldy1 <> FormWindows()\FormGadgets()\y1 Or resoldy2 <> FormWindows()\FormGadgets()\y2)
      grid_SetCellString(propgrid,2,8,Str(FormWindows()\FormGadgets()\x1))
      grid_SetCellString(propgrid,2,9,Str(FormWindows()\FormGadgets()\y1))
      grid_SetCellString(propgrid,2,10,Str(FormWindows()\FormGadgets()\x2-FormWindows()\FormGadgets()\x1))
      grid_SetCellString(propgrid,2,11,Str(FormWindows()\FormGadgets()\y2-FormWindows()\FormGadgets()\y1))
      redraw = 1
    EndIf
    
    FD_UpdateSplitter()
    
    ; if multiple gadgets are selected, resize them as well
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\selected And FormWindows()\FormGadgets() <> resizing
        redraw = 1
        Select resizetype
          Case #Form_Resize_TopLeft
            FormWindows()\FormGadgets()\x1 + resizex1
            FormWindows()\FormGadgets()\y1 + resizey1
            
            If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
              FormWindows()\FormGadgets()\x1 = FormWindows()\FormGadgets()\x2 - FormGridSize
            EndIf
            If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
              FormWindows()\FormGadgets()\y1 = FormWindows()\FormGadgets()\y2 - FormGridSize
            EndIf
            
          Case #Form_Resize_TopMiddle
            FormWindows()\FormGadgets()\y1 + resizey1
            
            If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
              FormWindows()\FormGadgets()\y1 = FormWindows()\FormGadgets()\y2 - FormGridSize
            EndIf
            
          Case #Form_Resize_TopRight
            FormWindows()\FormGadgets()\x2 + resizex2
            FormWindows()\FormGadgets()\y1 + resizey1
            
            If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormGridSize
            EndIf
            If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
              FormWindows()\FormGadgets()\y1 = FormWindows()\FormGadgets()\y2 - FormGridSize
            EndIf
            
          Case #Form_Resize_BottomLeft
            FormWindows()\FormGadgets()\x1 + resizex1
            FormWindows()\FormGadgets()\y2 + resizey2
            
            If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
              FormWindows()\FormGadgets()\x1 = FormWindows()\FormGadgets()\x2 - FormGridSize
            EndIf
            If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + FormGridSize
            EndIf
            
          Case #Form_Resize_BottomMiddle
            FormWindows()\FormGadgets()\y2 + resizey2
            
            If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + FormGridSize
            EndIf
            
          Case #Form_Resize_BottomRight
            FormWindows()\FormGadgets()\x2 + resizex2
            FormWindows()\FormGadgets()\y2 + resizey2
            
            If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormGridSize
            EndIf
            If FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1 <= 0
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + FormGridSize
            EndIf
            
          Case #Form_Resize_MiddleLeft
            FormWindows()\FormGadgets()\x1 + resizex1
            
            If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
              FormWindows()\FormGadgets()\x1 = FormWindows()\FormGadgets()\x2 - FormGridSize
            EndIf
            
          Case #Form_Resize_MiddleRight
            FormWindows()\FormGadgets()\x2 + resizex2
            
            If FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1 <= 0
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + FormGridSize
            EndIf
        EndSelect
      EndIf
    Next
    
    
    FormChanges(1)
  EndIf ;}
  
  If resizing_win ;{
    update_scrollbars = 0
    If FormWindows()\width <> px_win Or FormWindows()\height <> py_win
      update_scrollbars = 1
    EndIf
    
    winoldw = FormWindows()\width
    winoldh = FormWindows()\height
    
    FormWindows()\width = px_win
    FormWindows()\height = py_win
    
    If FormWindows()\height <= 5
      FormWindows()\height = 5
    EndIf
    If FormWindows()\width <= 80
      FormWindows()\width = 80
    EndIf
    
    
    If update_scrollbars
      FD_UpdateScrollbars(1)
      
      swidth = GadgetWidth(#GADGET_Form)-Grid_Scrollbar_Width
      sheight = GadgetHeight(#GADGET_Form)-Grid_Scrollbar_Width
      
      ResizeGadget(#GADGET_Form_Canvas,0,0,swidth,sheight)
    EndIf
    
    If winoldw <> FormWindows()\width Or winoldh <> FormWindows()\height
      redraw = 1
    EndIf
  EndIf ;}
  
  ForEach FormWindows()\FormGadgets()
    this_parent = FormWindows()\FormGadgets()\parent
    this_parent_item = FormWindows()\FormGadgets()\parent_item
    hidden = 0
    
    If this_parent
      a_x1 = 0 : a_x2 = 0 : a_y1 = 0 : a_y2 = 0
    Else
      a_x1 = 0 : a_x2 = 10000 : a_y1 = 0 : a_y2 = 10000
    EndIf
    
    x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
    While this_parent <> 0
      PushListPosition(FormWindows()\FormGadgets())
      FD_FindParent(this_parent)
      
      If FormWindows()\FormGadgets()\current_item <> this_parent_item And this_parent_item <> -1
        hidden = 1
      EndIf
      
      If FormWindows()\FormGadgets()\hidden
        hidden = 1
      EndIf
      
      this_parent = FormWindows()\FormGadgets()\parent
      this_parent_item = FormWindows()\FormGadgets()\parent_item
      
      x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
      x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
      y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
      y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
      
      a_x1 + FormWindows()\FormGadgets()\x1
      a_x2 + FormWindows()\FormGadgets()\x2
      a_y1 + FormWindows()\FormGadgets()\y1
      a_y2 + FormWindows()\FormGadgets()\y2
      
      If FormWindows()\FormGadgets()\type = #Form_Type_Panel
        y1 + Panel_Height
        y2 + Panel_Height
      EndIf
      
      PopListPosition(FormWindows()\FormGadgets())
    Wend
    
    x1 + FormWindows()\FormGadgets()\x1 - scrollx
    x2 + FormWindows()\FormGadgets()\x2 - scrollx
    y1 + FormWindows()\FormGadgets()\y1 - scrolly
    y2 + FormWindows()\FormGadgets()\y2 - scrolly
    
    If FormWindows()\FormGadgets()\hidden
      hidden = 1
    EndIf
    
    If x > a_x1 And x <= a_x2 And y >= a_y1 And y <= a_y2
      
      If FormWindows()\FormGadgets()\selected And Not hidden And Not FormWindows()\FormGadgets()\splitter
        If FD_CheckPoint(x,y,x1,y1) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_TopLeft ; top left
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftUpRightDown)
          ok = 1
        ElseIf FD_CheckPoint(x,y,x2,y1) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_TopRight ; top right
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftDownRightUp)
          ok = 1
        ElseIf FD_CheckPoint(x,y,(x2 + x1) / 2,y1) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_TopMiddle ; top middle
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_UpDown)
          ok = 1
        ElseIf FD_CheckPoint(x,y,x1,y2) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_BottomLeft ; bottom left
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftDownRightUp)
          ok = 1
        ElseIf FD_CheckPoint(x,y,x2,y2) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_BottomRight ; bottom right
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftUpRightDown)
          ok = 1
        ElseIf FD_CheckPoint(x,y,(x2 + x1) / 2,y2) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_BottomMiddle ; bottom middle
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_UpDown)
          ok = 1
        ElseIf FD_CheckPoint(x,y,x1,(y2 + y1) / 2) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_MiddleLeft ; middle left
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftRight)
          ok = 1
        ElseIf FD_CheckPoint(x,y,x2,(y2 + y1) / 2) Or FormWindows()\FormGadgets()\resizing = #Form_Resize_MiddleRight ; middle right
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftRight)
          ok = 1
        EndIf
        
        If ok
          Break
        EndIf
      EndIf
      
      If x > x1 And x <= x2 And y >= y1 And y <= y2 And Not hidden
        If FormWindows()\FormGadgets()\type = #Form_Type_Container Or FormWindows()\FormGadgets()\type = #Form_Type_Panel Or FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea Or FormWindows()\FormGadgets()\type = #Form_Type_Frame3D
          If FD_CheckPoint(x,0,x1,0,4) Or FD_CheckPoint(x,0,x2,0,4) Or FD_CheckPoint(0,y,0,y1,4) Or FD_CheckPoint(0,y,0,y2,4) Or (FormWindows()\FormGadgets()\type = #Form_Type_Panel And y <= y1 + Panel_Height)
            ok = 1
            SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_Hand)
          EndIf
        Else
          ok = 1
          SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_Hand)
          Break
        EndIf
      EndIf
    EndIf
  Next
  
  Select FormSkin
    Case #PB_OS_MacOS
      winx = FormWindows()\width + 2
      winy =  FormWindows()\height + 2
      
    Case #PB_OS_Linux
      winx = FormWindows()\width + 2
      winy =  FormWindows()\height + 2 - toptoolpadding - topmenupadding
      
    Case #PB_OS_Windows
      winx = FormWindows()\width + 8 + 2
      winy = FormWindows()\height + 8 + 2 - toptoolpadding - topmenupadding
  EndSelect
  
  ; mouse hover win resize?
  If FD_CheckPoint(x,y,winx,winy)
    SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_LeftUpRightDown)
    ok = 1
  EndIf
  
  If ok = 0
    SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_Default)
  EndIf
  
EndProcedure

Procedure FD_MoveMultiSelection(x,y)
  Static sx1, sx2, sy1, sy2
  
  px = FD_AlignPoint(x - leftpadding + FormWindows()\paddingx - #Page_Padding)
  py = FD_AlignPoint(y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding)
  x + FormWindows()\paddingx - #Page_Padding - leftpadding
  y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding
  
  If multiselectFirstScan
    multiselectFirstScan = #False
    sx1 = x
    sy1 = y
    sx2 = x
    sy2 = y
  EndIf
  
  If sx1 > x
    sx1 = x
  EndIf
  If sx2 < x
    sx2 = x
  EndIf
  If sy1 > y
    sy1 = y
  EndIf
  If sy2 < y
    sy2 = y
  EndIf
  
  If LastElement(FormWindows()\FormGadgets())
    Repeat
      this_parent = FormWindows()\FormGadgets()\parent
      this_parent_item = FormWindows()\FormGadgets()\parent_item
      hidden = 0
      
      If this_parent
        a_x1 = 0 : a_x2 = 0 : a_y1 = 0 : a_y2 = 0
      Else
        a_x1 = 0 : a_x2 = 10000 : a_y1 = 0 : a_y2 = 10000
      EndIf
      
      x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
      While this_parent <> 0
        PushListPosition(FormWindows()\FormGadgets())
        FD_FindParent(this_parent)
        
        If FormWindows()\FormGadgets()\current_item <> this_parent_item And this_parent_item <> -1
          hidden = 1
        EndIf
        
        If FormWindows()\FormGadgets()\hidden
          hidden = 1
        EndIf
        
        this_parent = FormWindows()\FormGadgets()\parent
        this_parent_item = FormWindows()\FormGadgets()\parent_item
        
        x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
        x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
        y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
        y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
        
        a_x1 + FormWindows()\FormGadgets()\x1
        a_x2 + FormWindows()\FormGadgets()\x2
        a_y1 + FormWindows()\FormGadgets()\y1
        a_y2 + FormWindows()\FormGadgets()\y2
        
        If FormWindows()\FormGadgets()\type = #Form_Type_Panel
          y1 + Panel_Height
          y2 + Panel_Height
        EndIf
        
        PopListPosition(FormWindows()\FormGadgets())
      Wend
      
      x1 + FormWindows()\FormGadgets()\x1 - scrollx
      x2 + FormWindows()\FormGadgets()\x2 - scrollx
      y1 + FormWindows()\FormGadgets()\y1 - scrolly
      y2 + FormWindows()\FormGadgets()\y2 - scrolly
      
      If FormWindows()\FormGadgets()\hidden
        hidden = 1
      EndIf
      
      If Not hidden
        If x > a_x1 And x <= a_x2 And y >= a_y1 And y <= a_y2
          If (x > x1 And x <= x2 And y >= y1 And y <= y2) Or ((x1 > sx1 And x2 <= sx2) And (y1 > sy1 And y2 <= sy2))
            If multiSelectParent < 0
              Select FormWindows()\FormGadgets()\type
                Case #Form_Type_Container, #Form_Type_Panel, #Form_Type_ScrollArea
                  multiSelectParent = FormWindows()\FormGadgets()\itemnumber
                Case #Form_Type_Splitter
                  If FormWindows()\FormGadgets()\flags & FlagValue("#PB_Splitter_Vertical")
                    If x < x1 + FormWindows()\FormGadgets()\state
                      multiSelectParent = FormWindows()\FormGadgets()\gadget1
                    Else
                      multiSelectParent = FormWindows()\FormGadgets()\gadget2
                    EndIf  
                  Else
                    If y < y1 + FormWindows()\FormGadgets()\state
                      multiSelectParent = FormWindows()\FormGadgets()\gadget1
                    Else
                      multiSelectParent = FormWindows()\FormGadgets()\gadget2
                    EndIf  
                  EndIf
                
                Default
                  multiSelectParent = 0
              EndSelect
            EndIf
            If FormWindows()\FormGadgets()\parent = multiSelectParent
              If Not FormWindows()\FormGadgets()\selected
                count_select + 1
                FormWindows()\FormGadgets()\selected = 1
                FormWindows()\FormGadgets()\oldx = FormWindows()\FormGadgets()\x1
                FormWindows()\FormGadgets()\oldy = FormWindows()\FormGadgets()\y1
                redraw = 1
              EndIf
              If (x > x1 And x <= x2 And y >= y1 And y <= y2)
                moving = FormWindows()\FormGadgets()
                moving_x = px
                moving_y = py
                moving_firstx = px
                moving_firsty = py
              EndIf
            EndIf
          
          EndIf
        EndIf
      EndIf
      
    Until PreviousElement(FormWindows()\FormGadgets()) = 0
    
    If multiSelectParent < 0
      multiSelectParent = 0
    EndIf
    
  EndIf
  
EndProcedure

Procedure FD_LeftUp(x,y)
  ChangeCurrentElement(FormWindows(),currentwindow)
  
  px = FD_AlignPoint(x - leftpadding + FormWindows()\paddingx - #Page_Padding)
  py = FD_AlignPoint(y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding)
  x + FormWindows()\paddingx - #Page_Padding - leftpadding
  y + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding
  
  If multiselectStart
    SetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Cursor,#PB_Cursor_Hand)
    multiselectStart = #False
    multiselectFirstScan = #False
  EndIf
  
  If drawing And d_x1 <> d_x2 And d_y1 <> d_y2 ;{
    If form_gadget_type = #Form_Type_Toolbar
      FormWindows()\toolbar_visible = 1
      
    ElseIf form_gadget_type = #Form_Type_StatusBar
      FormWindows()\status_visible = 1
      
    ElseIf form_gadget_type = #Form_Type_Menu
      FormWindows()\menu_visible = 1
      
    Else
      If form_gadget_type <= 0
        form_gadget_type = #Form_Type_Button
      EndIf
      
      var.s = ""
      
      Select form_gadget_type ;{
        Case #Form_Type_Button
          var = "Button_"+Str(FormWindows()\c_button)
          FormWindows()\c_button + 1
        Case #Form_Type_ButtonImg
          var = "ButtonImage_"+Str(FormWindows()\c_buttonimg)
          FormWindows()\c_buttonimg + 1
        Case #Form_Type_StringGadget
          var = "String_"+Str(FormWindows()\c_string)
          FormWindows()\c_string + 1
        Case #Form_Type_Checkbox
          var = "Checkbox_"+Str(FormWindows()\c_checkbox)
          FormWindows()\c_checkbox + 1
        Case #Form_Type_Text
          var = "Text_"+Str(FormWindows()\c_text)
          FormWindows()\c_text + 1
        Case #Form_Type_OpenGL
          var = "OpenGL_"+Str(FormWindows()\c_opengl)
          FormWindows()\c_opengl + 1
        Case #Form_Type_Option
          var = "Option_"+Str(FormWindows()\c_option)
          FormWindows()\c_option + 1
        Case #Form_Type_TreeGadget
          var = "Tree_"+Str(FormWindows()\c_tree)
          FormWindows()\c_tree + 1
        Case #Form_Type_ListView
          var = "ListView_"+Str(FormWindows()\c_listview)
          clistview + 1
        Case #Form_Type_ListIcon
          var = "ListIcon_"+Str(FormWindows()\c_listicon)
          FormWindows()\c_listicon + 1
        Case #Form_Type_Combo
          var = "Combo_"+Str(FormWindows()\c_combo)
          FormWindows()\c_combo + 1
        Case #Form_Type_Spin
          var = "Spin_"+Str(FormWindows()\c_spin)
          FormWindows()\c_spin + 1
        Case #Form_Type_Trackbar
          var = "TrackBar_"+Str(FormWindows()\c_trackbar)
          FormWindows()\c_trackbar + 1
        Case #Form_Type_ProgressBar
          var = "ProgressBar_"+Str(FormWindows()\c_progressbar)
          FormWindows()\c_progressbar + 1
        Case #Form_Type_Img
          var = "Image_"+Str(FormWindows()\c_image)
          FormWindows()\c_image + 1
        Case #Form_Type_IP
          var = "IP_"+Str(FormWindows()\c_ip)
          FormWindows()\c_ip + 1
        Case #Form_Type_Scrollbar
          var = "Scrollbar_"+Str(FormWindows()\c_scrollbar)
          FormWindows()\c_scrollbar + 1
        Case #Form_Type_HyperLink
          var = "Hyperlink_"+Str(FormWindows()\c_hyperlink)
          FormWindows()\c_hyperlink + 1
        Case #Form_Type_Editor
          var = "Editor_"+Str(FormWindows()\c_editor)
          FormWindows()\c_editor + 1
        Case #Form_Type_ExplorerTree
          var = "ExplorerTree_"+Str(FormWindows()\c_explorertree)
          FormWindows()\c_explorertree + 1
        Case #Form_Type_ExplorerList
          var = "ExplorerList_"+Str(FormWindows()\c_explorerlist)
          FormWindows()\c_explorerlist + 1
        Case #Form_Type_ExplorerCombo
          var = "ExplorerCombo_"+Str(FormWindows()\c_explorercombo)
          FormWindows()\c_explorercombo + 1
        Case #Form_Type_Date
          var = "Date_"+Str(FormWindows()\c_date)
          FormWindows()\c_date + 1
        Case #Form_Type_Calendar
          var = "Calendar_"+Str(FormWindows()\c_calendar)
          FormWindows()\c_calendar + 1
        Case #Form_Type_Scintilla
          var = "Scintilla_"+Str(FormWindows()\c_scintilla)
          FormWindows()\c_scintilla + 1
        Case #Form_Type_Splitter
          var = "Splitter_"+Str(FormWindows()\c_splitter)
          FormWindows()\c_splitter + 1
        Case #Form_Type_Frame3D
          var = "Frame_"+Str(FormWindows()\c_frame3D)
          FormWindows()\c_frame3D + 1
        Case #Form_Type_ScrollArea
          var = "ScrollArea_"+Str(FormWindows()\c_scrollarea)
          FormWindows()\c_scrollarea + 1
        Case #Form_Type_Web
          var = "WebView_"+Str(FormWindows()\c_web)
          FormWindows()\c_web + 1
        Case #Form_Type_WebView
          var = "WebView_"+Str(FormWindows()\c_web)
          FormWindows()\c_web + 1
        Case #Form_Type_Container
          var = "Container_"+Str(FormWindows()\c_container)
          FormWindows()\c_container + 1
        Case #Form_Type_Panel
          var = "Panel_"+Str(FormWindows()\c_panel)
          FormWindows()\c_panel + 1
        Case #Form_Type_Canvas
          var = "Canvas_"+Str(FormWindows()\c_canvas)
          FormWindows()\c_canvas + 1
      EndSelect ;}
      
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      
      If parent
        this_parent = parent
        parentx1 = 0 : parenty1 = 0
        While this_parent <> 0
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(this_parent)
          this_parent = FormWindows()\FormGadgets()\parent
          
          parentx1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
          parenty1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Panel
            parenty1 + Panel_Height
          EndIf
          
          PopListPosition(FormWindows()\FormGadgets())
        Wend
        
        FD_FindParent(parent)
        If FormWindows()\FormGadgets()\type = #Form_Type_Panel
          parent_item = FormWindows()\FormGadgets()\current_item
        Else
          parent_item = -1
        EndIf
        
        ; order the gadget at the end of the item list of the parent
        gadget = parent
        While NextElement(FormWindows()\FormGadgets())
          If FormWindows()\FormGadgets()\parent = parent
            If FormWindows()\FormGadgets()\parent_item > parent_item
              Break
            EndIf
            gadget = FormWindows()\FormGadgets()\itemnumber
          Else
            Break
          EndIf
        Wend
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\itemnumber = gadget
            Break
          EndIf
        Next
        
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\x1 = d_x1 - parentx1
        FormWindows()\FormGadgets()\y1 = d_y1 - parenty1
        FormWindows()\FormGadgets()\x2 = d_x2 - parentx1
        FormWindows()\FormGadgets()\y2 = d_y2 - parenty1
        FormWindows()\FormGadgets()\selected = 1
        FormWindows()\FormGadgets()\type = form_gadget_type
        FormWindows()\FormGadgets()\parent = parent
        FormWindows()\FormGadgets()\parent_item = parent_item
      Else
        AddElement(FormWindows()\FormGadgets())
        FormWindows()\FormGadgets()\x1 = d_x1
        FormWindows()\FormGadgets()\y1 = d_y1
        FormWindows()\FormGadgets()\x2 = d_x2
        FormWindows()\FormGadgets()\y2 = d_y2
        FormWindows()\FormGadgets()\selected = 1
        FormWindows()\FormGadgets()\type = form_gadget_type
      EndIf
      
      FormWindows()\FormGadgets()\itemnumber = itemnumbers
      itemnumbers + 1
      
      FormChanges(1)
      
      Select form_gadget_type
        Case #Form_Type_ListIcon
          AddElement(FormWindows()\FormGadgets()\Columns())
          FormWindows()\FormGadgets()\Columns()\name = "Column 1"
          FormWindows()\FormGadgets()\Columns()\width = 100
          
        Case #Form_Type_ScrollArea
          FormWindows()\FormGadgets()\min = d_x2 - d_x1 + 200
          FormWindows()\FormGadgets()\max = d_y2 - d_y1 + 200
          
        Case #Form_Type_Scintilla
          FormWindows()\FormGadgets()\caption = "Callback_"+var+"()"
          
        Case #Form_Type_Panel
          AddElement(FormWindows()\FormGadgets()\Items())
          FormWindows()\FormGadgets()\Items()\name = "Tab 1"
          
        Case #Form_Type_Splitter
          PushListPosition(FormWindows()\FormGadgets())
          ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget1)
          num1 = FormWindows()\FormGadgets()\itemnumber
          ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget2)
          num2 = FormWindows()\FormGadgets()\itemnumber
          PopListPosition(FormWindows()\FormGadgets())
          
          FormWindows()\FormGadgets()\gadget1 = num1
          FormWindows()\FormGadgets()\gadget2 = num2
          
          FormWindows()\FormGadgets()\state = (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1) / 2
          splitter = FormWindows()\FormGadgets()\itemnumber ;@FormWindows()\FormGadgets()
          
          PushListPosition(FormWindows()\FormGadgets())
          ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget1)
          FormWindows()\FormGadgets()\splitter = splitter
          ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget2)
          FormWindows()\FormGadgets()\splitter = splitter
          PopListPosition(FormWindows()\FormGadgets())
          
          ; in case the splitter is created in a container
          *listpos = @FormWindows()\FormGadgets()
          splitterparent = FormWindows()\FormGadgets()\parent
          splitterparentitem = FormWindows()\FormGadgets()\parent_item
          PushListPosition(FormWindows()\FormGadgets())
          
          ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget1)
          FormWindows()\FormGadgets()\parent = splitterparent
          FormWindows()\FormGadgets()\parent_item = splitterparentitem
          MoveElement(FormWindows()\FormGadgets(), #PB_List_Before, *listpos)
          
          ChangeCurrentElement(FormWindows()\FormGadgets(),d_gadget2)
          FormWindows()\FormGadgets()\parent = splitterparent
          FormWindows()\FormGadgets()\parent_item = splitterparentitem
          MoveElement(FormWindows()\FormGadgets(), #PB_List_Before, *listpos)
          
          PopListPosition(FormWindows()\FormGadgets())
          
          form_gadget_type = #Form_Type_Button
          
          num = CountGadgetItems(gadgetlist) - 1
          For i = 0 To num
            If GetGadgetItemData(gadgetlist,i) = #Form_Type_Button
              SetGadgetState(gadgetlist,i)
              Break
            EndIf
          Next
      EndSelect
      
      FormWindows()\FormGadgets()\frontcolor = -1
      FormWindows()\FormGadgets()\backcolor = -1
      FormWindows()\FormGadgets()\variable = var
      FormWindows()\FormGadgets()\pbany = FormVariable
      FormWindows()\FormGadgets()\captionvariable = FormVariableCaption
      FormWindows()\FormGadgets()\tooltipvariable = FormVariableCaption
      
      FormWindows()\FormGadgets()\lock_left = 1
      FormWindows()\FormGadgets()\lock_top = 1
      
      FD_UpdateSplitter()
      
      FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets(),#Undo_Create)
      
      PushListPosition(FormWindows()\FormGadgets())
      FD_UpdateObjList()
      PopListPosition(FormWindows()\FormGadgets())
      
      FD_SelectGadget(FormWindows()\FormGadgets())
    EndIf
    
    parent = 0
    d_x1 = 0 : d_x2 = 0 : d_y1 = 0 : d_y2 = 0
  EndIf ;}
  
  If resizing_win
    FormWindows()\paddingx = 0
    FormWindows()\paddingy = 0
    
    FormAddUndoAction(0,FormWindows())
    FormChanges(1)
    FD_UpdateScrollbars()
  EndIf
  
  If resizing
    ChangeCurrentElement(FormWindows()\FormGadgets(),resizing)
    If resizeundo
      FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
    EndIf
    
    ForEach FormWindows()\FormGadgets()
      FormWindows()\FormGadgets()\resizing = 0
    Next
    
    resizing = 0
  EndIf
  
  If moving
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\selected
        If moveundo
          LastElement(FormWindows()\UndoActions())
          ForEach FormWindows()\UndoActions()\ActionGadget()
            If FormWindows()\UndoActions()\ActionGadget()\itemnumber = FormWindows()\FormGadgets()\itemnumber
              FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
            EndIf
          Next
        EndIf
      EndIf
    Next
  EndIf
  
  
  isselect = 0
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      isselect = 1
      ; Fix move multiple times
      FormWindows()\FormGadgets()\oldx = FormWindows()\FormGadgets()\x1
      FormWindows()\FormGadgets()\oldy = FormWindows()\FormGadgets()\y1
    EndIf
  Next
  
  If Not isselect And Not toolselected And Not statusselected And Not menuselected
    FD_SelectWindow(currentwindow)
  EndIf
  
  ;{ statusbar drag'n drop
  If statusdragpos And propgrid_statusbar
    ;PushListPosition(FormWindows()\FormStatusbars())
    before = 0 : after = 0
    ForEach FormWindows()\FormStatusbars()
      If statusdragpos > FormWindows()\FormStatusbars()\x1 - 5 And statusdragpos < (FormWindows()\FormStatusbars()\x2 - 5)
        before = FormWindows()\FormStatusbars()
        Break
      ElseIf ListIndex(FormWindows()\FormStatusbars()) = ListSize(FormWindows()\FormStatusbars()) -1 And statusdragpos > FormWindows()\FormStatusbars()\x1
        after = FormWindows()\FormStatusbars()
        Break
      EndIf
    Next
    
    ChangeCurrentElement(FormWindows()\FormStatusbars(),propgrid_statusbar)
    
    If before > 0 And propgrid_statusbar <> before
      MoveElement(FormWindows()\FormStatusbars(),#PB_List_Before,before)
    ElseIf after > 0 And propgrid_statusbar <> after
      MoveElement(FormWindows()\FormStatusbars(),#PB_List_After,after)
    EndIf
    ;PopListPosition(FormWindows()\FormStatusbars())
    FD_SelectStatusBar(FormWindows()\FormStatusbars())
    ;FD_SelectWindow(FormWindows())
  EndIf
  ;}
  
  ;{ toolbar drag'n drop
  If tooldragpos And propgrid_toolbar
    Select FormSkin ;{
      Case #PB_OS_MacOS
        toolx = #Page_Padding - FormWindows()\paddingx + 7
      Case #PB_OS_Windows
        toolx = #Page_Padding - FormWindows()\paddingx + 8 + 5
      Case #PB_OS_Linux
        toolx = #Page_Padding - FormWindows()\paddingx + 8 + 5
    EndSelect ;}
    
    before = 0 : after = 0
    ForEach FormWindows()\FormToolbars()
      If tooldragpos > toolx - 5 And tooldragpos < toolx + 5
        before = FormWindows()\FormToolbars()
        Break
      ElseIf ListIndex(FormWindows()\FormToolbars()) = ListSize(FormWindows()\FormToolbars()) -1 And tooldragpos > toolx + 5
        after = FormWindows()\FormToolbars()
        Break
      EndIf
      
      If FormWindows()\FormToolbars()\separator = 1
        Select FormSkin
          Case #PB_OS_Windows, #PB_OS_Linux
            toolx + 10
          Case #PB_OS_MacOS
            toolx + 10
        EndSelect
      Else
        toolx + 16 + 6
      EndIf
    Next
    
    ChangeCurrentElement(FormWindows()\FormToolbars(),propgrid_toolbar)
    
    If before > 0 And propgrid_toolbar <> before
      MoveElement(FormWindows()\FormToolbars(),#PB_List_Before,before)
    ElseIf after > 0 And propgrid_toolbar <> after
      MoveElement(FormWindows()\FormToolbars(),#PB_List_After,after)
    EndIf
  EndIf
  ;}
  
  ;{ menu drag'n drop
  If menudragposx And menudragposy And menuselected
    before = 0
    after = 0
    newlevel = 0
    level = 0
    FirstElement(FormWindows()\FormMenus())
    menuy2 = FormWindows()\FormMenus()\y2
    
    ForEach FormWindows()\FormMenus()
      ; drag before the first menu title
      If ListIndex(FormWindows()\FormMenus()) = 0 And menudragposx <= FormWindows()\FormMenus()\x1 And menudragposy >= FormWindows()\FormMenus()\y1 And menudragposy < FormWindows()\FormMenus()\y2
        before = FormWindows()\FormMenus()
        newlevel = FormWindows()\FormMenus()\level
        Break
      EndIf
      
      ; drag before the first menu item
      If FormWindows()\FormMenus()\level > level And menudragposy >= FormWindows()\FormMenus()\y1 - 1 And menudragposy < FormWindows()\FormMenus()\y1 + 1 And menudragposx > FormWindows()\FormMenus()\x1 And menudragposx <= FormWindows()\FormMenus()\x2
        before = FormWindows()\FormMenus()
        newlevel = FormWindows()\FormMenus()\level
        Break
      EndIf
      
      If menudragposx > FormWindows()\FormMenus()\x1 And menudragposx <= FormWindows()\FormMenus()\x2 And menudragposy > FormWindows()\FormMenus()\y1 + 1 And menudragposy <= FormWindows()\FormMenus()\y2
        after = FormWindows()\FormMenus()
        newlevel = FormWindows()\FormMenus()\level
        Break
      EndIf
      
      If FormWindows()\FormMenus() = propgrid_menu ; move to a new level
        oldLevel = FormWindows()\FormMenus()\level
        PushListPosition(FormWindows()\FormMenus())
        check = 0
        If NextElement(FormWindows()\FormMenus())
          If FormWindows()\FormMenus()\level <= oldLevel
            PreviousElement(FormWindows()\FormMenus())
            check = 1
          EndIf
        EndIf
        
        ; move to an empty opened submenu
        If check And menudragposx > FormWindows()\FormMenus()\x2 And menudragposy > menuy2
          after = FormWindows()\FormMenus()
          newlevel = FormWindows()\FormMenus()\level + 1
          Break
        EndIf
        PopListPosition(FormWindows()\FormMenus())
      EndIf
      
      level = FormWindows()\FormMenus()\level
    Next
    
    ChangeCurrentElement(FormWindows()\FormMenus(),menuselected)
    oldLevel = FormWindows()\FormMenus()\level
    
    If (before > 0 And menuselected <> before) Or (after > 0 And menuselected <> after)
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
    EndIf
    
    nextpos = 0
    If before > 0 And menuselected <> before
      PushListPosition(FormWindows()\FormMenus())
      If NextElement(FormWindows()\FormMenus())
        nextpos = FormWindows()\FormMenus()
      EndIf
      PopListPosition(FormWindows()\FormMenus())
      
      MoveElement(FormWindows()\FormMenus(),#PB_List_Before,before)
      diffLevel = newlevel - FormWindows()\FormMenus()\level
      FormWindows()\FormMenus()\level = newlevel
    ElseIf after > 0 And menuselected <> after
      PushListPosition(FormWindows()\FormMenus())
      If NextElement(FormWindows()\FormMenus())
        nextpos = FormWindows()\FormMenus()
      EndIf
      PopListPosition(FormWindows()\FormMenus())
      
      ; items need to be moved after their last child element
      PushListPosition(FormWindows()\FormMenus())
      ChangeCurrentElement(FormWindows()\FormMenus(),after)
      after_level = FormWindows()\FormMenus()\level
      Repeat
        after = FormWindows()\FormMenus()
        If NextElement(FormWindows()\FormMenus())
          nextEl = 1
        Else
          Break
        EndIf
      Until FormWindows()\FormMenus()\level <= after_level
      
      PopListPosition(FormWindows()\FormMenus())
      
      MoveElement(FormWindows()\FormMenus(),#PB_List_After,after)
      diffLevel = newlevel - FormWindows()\FormMenus()\level
      FormWindows()\FormMenus()\level = newlevel
    EndIf
    
    If nextpos ; move child elements
      movedel = menuselected
      ChangeCurrentElement(FormWindows()\FormMenus(),nextpos)
      
      Repeat
        If FormWindows()\FormMenus()\level > oldLevel
          PushListPosition(FormWindows()\FormMenus())
          nextEl = 0
          If NextElement(FormWindows()\FormMenus())
            nextEl = FormWindows()\FormMenus()
          EndIf
          PopListPosition(FormWindows()\FormMenus())
          MoveElement(FormWindows()\FormMenus(),#PB_List_After,movedel)
          FormWindows()\FormMenus()\level + diffLevel
          movedel = FormWindows()\FormMenus()
          
          If nextEl
            ChangeCurrentElement(FormWindows()\FormMenus(),nextEl)
          EndIf
        EndIf
      Until FormWindows()\FormMenus()\level <= oldLevel Or nextEl = 0
      
    EndIf
    
    
    If (before > 0 And menuselected <> before) Or (after > 0 And menuselected <> after)
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
    EndIf
    
  EndIf
  ;}
  
  If menuselected
    FD_SelectMenu(menuselected)
  EndIf
  
  scrolling = 0 : scrollingx = 0 : scrollingy = 0 : delta = 0
  moveresizeundo = 0 : moveundo = 0 : resizeundo = 0
  drawing = 0
  moving = 0
  resizing_win = 0
  tooldragpos = 0
  toolselected = 0
  statusselected = 0
  statusdragpos = 0
  menuselected = 0
  menudragposx = 0
  menudragposy = 0
  
  redraw = 1
EndProcedure
Procedure FD_Redraw()
  starttime.q = ElapsedMilliseconds()
  If currentwindow And ListSize(FormWindows())
    ChangeCurrentElement(FormWindows(),currentwindow)
    
    If FormSkin = #PB_OS_Windows ; take the window border into account on Windows
      leftpadding = 8
    Else
      leftpadding = 0
    EndIf
    
    If FormWindows()\flags & FlagValue("#PB_Window_SystemMenu") Or FormWindows()\flags & FlagValue("#PB_Window_TitleBar")
      topwinpadding = P_WinHeight
    Else
      If FormSkin = #PB_OS_Windows
        topwinpadding = 8
      Else
        topwinpadding = 0
      EndIf
    EndIf
    
    If ListSize(FormWindows()\FormStatusbars()) Or FormWindows()\status_visible
      bottompaddingsb = P_Status
    Else
      bottompaddingsb = 0
    EndIf
    
    If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
      topmenupadding = P_Menu
    Else
      topmenupadding = 0
    EndIf
    
    If ListSize(FormWindows()\FormToolbars()) Or FormWindows()\toolbar_visible
      toptoolpadding = P_Toolbar
    Else
      toptoolpadding = 0
    EndIf
    
    
    StartDrawing(ImageOutput(#Drawing_Img))
    DrawingMode(#PB_2DDrawing_Transparent)
    Box(0,0,OutputWidth(),OutputHeight(), RGB(150, 150, 150))
    
    ;{ Draw the window
    Select FormSkin
      Case #PB_OS_MacOS
        DrawingMode(#PB_2DDrawing_Transparent)
        color = RGB(237, 237, 237)
        
        If FormWindows()\color > -1
          color = FormWindows()\color
        EndIf
        
        RoundBox(#Page_Padding - FormWindows()\paddingx - 1,#Page_Padding - FormWindows()\paddingy - 1 + topmenupadding,FormWindows()\width + 2,FormWindows()\height + 2 + topwinpadding + toptoolpadding, 4,4, color)
        DrawingMode(#PB_2DDrawing_Outlined)
        RoundBox(#Page_Padding - FormWindows()\paddingx - 1,#Page_Padding - FormWindows()\paddingy - 1 + topmenupadding,FormWindows()\width + 2,FormWindows()\height + 2 + topwinpadding + toptoolpadding, 4,4, RGB(184,184,184))
        
        FD_DrawResizeButton(#Page_Padding - FormWindows()\paddingx + FormWindows()\width + 2,#Page_Padding - FormWindows()\paddingy + FormWindows()\height + topmenupadding + toptoolpadding + topwinpadding + 2)
      Case #PB_OS_Windows
        DrawingMode(#PB_2DDrawing_Transparent)
        color = RGB(240, 240, 240)
        
        If FormWindows()\color > -1
          color = FormWindows()\color
        EndIf
        
        Select FormSkinVersion
          Case 7
            ; window has a 8px border
            DrawingMode(#PB_2DDrawing_Gradient)
            BackColor(RGB(210, 232, 232))
            GradientColor(0.5, RGB(184,220,250))
            FrontColor(RGB(210, 232, 232))
            LinearGradient(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy - 1, #Page_Padding - FormWindows()\paddingx + (FormWindows()\width + 16),#Page_Padding - FormWindows()\paddingy - 1)
            
            RoundBox(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy - 1,FormWindows()\width + 16,FormWindows()\height + topwinpadding + 8, 4,4) ; , RGB(210, 232, 232))
            DrawingMode(#PB_2DDrawing_Outlined)
            RoundBox(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy - 1,FormWindows()\width + 16,FormWindows()\height + topwinpadding + 8, 4,4, RGB(37, 37, 37))
            Box(#Page_Padding - FormWindows()\paddingx + 7, #Page_Padding - FormWindows()\paddingy + topwinpadding - 1, FormWindows()\width + 2, FormWindows()\height + 2, RGB(93, 108, 122))
            DrawingMode(#PB_2DDrawing_Transparent)
            Box(#Page_Padding - FormWindows()\paddingx + 8, #Page_Padding - FormWindows()\paddingy + topwinpadding , FormWindows()\width, FormWindows()\height, color)
            
          Case 8
            Box(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy - 1,FormWindows()\width + 16,FormWindows()\height + topwinpadding + 8, RGB(107,173,246))
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy - 1,FormWindows()\width + 16,FormWindows()\height + topwinpadding + 8, RGB(82,132,188))
            Box(#Page_Padding - FormWindows()\paddingx + 7, #Page_Padding - FormWindows()\paddingy + topwinpadding - 1, FormWindows()\width + 2, FormWindows()\height + 2, RGB(91, 147, 209))
            DrawingMode(#PB_2DDrawing_Transparent)
            Box(#Page_Padding - FormWindows()\paddingx + 8, #Page_Padding - FormWindows()\paddingy + topwinpadding , FormWindows()\width, FormWindows()\height, color)
        EndSelect
        
        FD_DrawResizeButton(#Page_Padding - FormWindows()\paddingx + FormWindows()\width + 16 + 2,#Page_Padding - FormWindows()\paddingy + FormWindows()\height + topwinpadding + 8 + 2)
      Case #PB_OS_Linux
        DrawingMode(#PB_2DDrawing_Transparent)
        color = RGB(242,241,240)
        
        If FormWindows()\color > -1
          color = FormWindows()\color
        EndIf
        
        If topwinpadding
          RoundBox(#Page_Padding - FormWindows()\paddingx - 1,#Page_Padding - 1 - FormWindows()\paddingy,FormWindows()\width + 2,FormWindows()\height + 1 + topwinpadding, 6,6, color)
        EndIf
        Box(#Page_Padding - 1 - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + topwinpadding,FormWindows()\width + 2,FormWindows()\height + 1, color)
        
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(#Page_Padding - 1 - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + topwinpadding,FormWindows()\width + 2,FormWindows()\height + 2,RGB(70,70,70))
        DrawingMode(#PB_2DDrawing_Transparent)
        
        FD_DrawResizeButton(#Page_Padding - FormWindows()\paddingx + FormWindows()\width + 2,#Page_Padding - FormWindows()\paddingy + FormWindows()\height + topwinpadding + 2)
    EndSelect ;}
    
    ;{ Draw the grid (if applicable)
    If FormGrid
      i = 0
      
      Select FormSkin
        Case #PB_OS_MacOS
          gridpadding = #Page_Padding - FormWindows()\paddingy + topwinpadding + topmenupadding + toptoolpadding
          gridyend = FormWindows()\height
        Case #PB_OS_Windows
          gridpadding = #Page_Padding - FormWindows()\paddingy + topwinpadding + topmenupadding + toptoolpadding
          gridyend = FormWindows()\height - (topmenupadding + toptoolpadding)
        Case #PB_OS_Linux
          gridpadding = #Page_Padding - FormWindows()\paddingy + topwinpadding + topmenupadding + toptoolpadding
          gridyend = FormWindows()\height - (topmenupadding + toptoolpadding)
      EndSelect
      
      While i < FormWindows()\width
        j = 0
        While j < gridyend
          Box(#Page_Padding - FormWindows()\paddingx + leftpadding + i,gridpadding + j,1,1,RGB(30,30,30))
          j + FormGridSize
        Wend
        i + FormGridSize
      Wend
    EndIf ;}
    
    ;{ Draw the window's system menu
    If FormWindows()\flags & FlagValue("#PB_Window_SystemMenu") Or FormWindows()\flags & FlagValue("#PB_Window_TitleBar")
      Select FormSkin
        Case #PB_OS_MacOS
          DrawingMode(#PB_2DDrawing_Outlined)
          Line(#Page_Padding - FormWindows()\paddingx - 1,#Page_Padding - 1 + topmenupadding - FormWindows()\paddingy+22,FormWindows()\width + 2,1,RGB(184,184,184))
          
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(RGB(228,228,228))
          
          If toptoolpadding = 0
            FrontColor(RGB(183,183,183))
            LinearGradient(#Page_Padding - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + topmenupadding,#Page_Padding - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + topmenupadding + 21)
          Else
            FrontColor(RGB(175,175,175))
            LinearGradient(#Page_Padding - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + topmenupadding,#Page_Padding - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + topmenupadding + 90)
          EndIf
          
          FillArea(#Page_Padding - FormWindows()\paddingx + 3,#Page_Padding - FormWindows()\paddingy + topmenupadding + 20,RGB(184,184,184))
          DrawingMode(#PB_2DDrawing_Transparent)
          
          If toptoolpadding = 0
            Line(#Page_Padding - FormWindows()\paddingx - 1,#Page_Padding - 1 - FormWindows()\paddingy + topmenupadding+22,FormWindows()\width + 2,1,RGB(105,105,105))
          EndIf
          
          DrawAlphaImage(ImageID(#Img_MacClose),#Page_Padding - FormWindows()\paddingx + 9,#Page_Padding - FormWindows()\paddingy + topmenupadding+5)
          
          If FormWindows()\flags & FlagValue("#PB_Window_MinimizeGadget")
            DrawAlphaImage(ImageID(#Img_MacMin),#Page_Padding - FormWindows()\paddingx + 9 + 12 + 9,#Page_Padding - FormWindows()\paddingy + topmenupadding+5)
          Else
            DrawAlphaImage(ImageID(#Img_MacDis),#Page_Padding - FormWindows()\paddingx + 9 + 12 + 9,#Page_Padding - FormWindows()\paddingy + topmenupadding+5)
          EndIf
          
          If FormWindows()\flags & FlagValue("#PB_Window_MaximizeGadget")
            DrawAlphaImage(ImageID(#Img_MacMax),#Page_Padding - FormWindows()\paddingx + 9 + 12 + 9 + 12 + 9,#Page_Padding - FormWindows()\paddingy + topmenupadding+5)
          Else
            DrawAlphaImage(ImageID(#Img_MacDis),#Page_Padding - FormWindows()\paddingx + 9 + 12 + 9 + 12 + 9,#Page_Padding - FormWindows()\paddingy + topmenupadding+5)
          EndIf
          
          ; Drawing title twice to get the shadow effect
          DrawingFont(FontID(#Form_Font))
          DrawText(#Page_Padding - FormWindows()\paddingx + (FormWindows()\width - TextWidth(FormWindows()\caption))/2,#Page_Padding - FormWindows()\paddingy + topmenupadding+5,FormWindows()\caption,RGB(255,255,255))
          DrawText(#Page_Padding - FormWindows()\paddingx + (FormWindows()\width - TextWidth(FormWindows()\caption))/2,#Page_Padding - FormWindows()\paddingy + topmenupadding+4,FormWindows()\caption,RGB(54,54,54))
        Case #PB_OS_Windows
          Select FormSkinVersion
            Case 7
              DrawAlphaImage(ImageID(#Img_WindowsIcon),#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + 8)
              
              DrawAlphaImage(ImageID(#Img_Win7Close),#Page_Padding - FormWindows()\paddingx + 8 + FormWindows()\width - 47,#Page_Padding - FormWindows()\paddingy - 1)
              
              If FormWindows()\flags & FlagValue("#PB_Window_MinimizeGadget")
                DrawAlphaImage(ImageID(#Img_Win7Min),#Page_Padding - FormWindows()\paddingx + 8 + FormWindows()\width - 47 - 26 - 29,#Page_Padding - FormWindows()\paddingy - 1)
              ElseIf FormWindows()\flags & FlagValue("#PB_Window_MaximizeGadget")
                DrawAlphaImage(ImageID(#Img_Win7MinDis),#Page_Padding - FormWindows()\paddingx + 8 + FormWindows()\width - 47 - 26 - 29,#Page_Padding - FormWindows()\paddingy - 1)
              EndIf
              
              If FormWindows()\flags & FlagValue("#PB_Window_MaximizeGadget")
                DrawAlphaImage(ImageID(#Img_Win7Max),#Page_Padding - FormWindows()\paddingx + 8 + FormWindows()\width - 47 - 26,#Page_Padding - FormWindows()\paddingy - 1)
              ElseIf FormWindows()\flags & FlagValue("#PB_Window_MinimizeGadget")
                DrawAlphaImage(ImageID(#Img_Win7MaxDis),#Page_Padding - FormWindows()\paddingx + 8 + FormWindows()\width - 47 - 26,#Page_Padding - FormWindows()\paddingy - 1)
              EndIf
              
              DrawingFont(FontID(#Form_Font))
              DrawText(#Page_Padding - FormWindows()\paddingx + 8 + 21,#Page_Padding - FormWindows()\paddingy + 8,FormWindows()\caption,RGB(0,0,0))
            Case 8
              DrawAlphaImage(ImageID(#Img_WindowsIcon),#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + 8)
              endpos = #Page_Padding - FormWindows()\paddingx + 8 + ImageWidth(#Img_WindowsIcon)
              
              pos = #Page_Padding - FormWindows()\paddingx + 8 + FormWindows()\width - ImageWidth(#Img_Win8Close)
              DrawAlphaImage(ImageID(#Img_Win8Close),pos,#Page_Padding - FormWindows()\paddingy )
              
              If FormWindows()\flags & FlagValue("#PB_Window_MaximizeGadget")
                pos - ImageWidth(#Img_Win8Max)
                DrawAlphaImage(ImageID(#Img_Win8Max),pos,#Page_Padding - FormWindows()\paddingy )
              EndIf
              
              If FormWindows()\flags & FlagValue("#PB_Window_MinimizeGadget")
                pos - ImageWidth(#Img_Win8Min)
                DrawAlphaImage(ImageID(#Img_Win8Min),pos,#Page_Padding - FormWindows()\paddingy )
              EndIf
              
              DrawingFont(FontID(#Form_Font))
              pos = endpos + (pos - endpos - TextWidth(FormWindows()\caption)) / 2
              DrawText(pos,#Page_Padding - FormWindows()\paddingy + 8,FormWindows()\caption,RGB(0,0,0))
          EndSelect
        Case #PB_OS_Linux
          DrawingMode(#PB_2DDrawing_Transparent)
          color = RGB(70,70,70)
          RoundBox(#Page_Padding - 1 - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy,FormWindows()\width + 2,P_WinHeight, 6,6, color)
          Box(#Page_Padding - 1 - FormWindows()\paddingx,#Page_Padding - 1 - FormWindows()\paddingy + 6,FormWindows()\width + 2,P_WinHeight -6, color)
          
          DrawAlphaImage(ImageID(#Img_LinuxClose),#Page_Padding - FormWindows()\paddingx + 11,#Page_Padding - FormWindows()\paddingy + 4)
          pos = #Page_Padding - FormWindows()\paddingx + 11 + ImageWidth(#Img_LinuxClose)
          If FormWindows()\flags & FlagValue("#PB_Window_MinimizeGadget")
            DrawAlphaImage(ImageID(#Img_LinuxMin),pos,#Page_Padding - FormWindows()\paddingy + 4)
            pos + ImageWidth(#Img_LinuxMin)
          EndIf
          
          If FormWindows()\flags & FlagValue("#PB_Window_MaximizeGadget")
            DrawAlphaImage(ImageID(#Img_LinuxMax),pos,#Page_Padding - FormWindows()\paddingy + 4)
            pos + ImageWidth(#Img_LinuxMax)
          EndIf
          
          DrawingFont(FontID(#Form_Font))
          DrawText(pos + 12,#Page_Padding - FormWindows()\paddingy + 6,FormWindows()\caption,RGB(255,255,255))
      EndSelect
    EndIf ;}
    
    ;{ Draw toolbar
    If toptoolpadding
      Select FormSkin ;{
        Case #PB_OS_MacOS
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(RGB(228,228,228))
          FrontColor(RGB(175,175,175))
          LinearGradient(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topmenupadding,#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topmenupadding + 90)
          Box(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding,FormWindows()\width,toptoolpadding)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          Line(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topmenupadding+ topwinpadding + toptoolpadding,FormWindows()\width,1,RGB(105,105,105))
          
          toolx = #Page_Padding - FormWindows()\paddingx + 7
          tooly = #Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding + 3
        Case #PB_OS_Windows
          DrawingMode(#PB_2DDrawing_Transparent)
          Box(#Page_Padding - FormWindows()\paddingx +8,#Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding,FormWindows()\width,toptoolpadding,RGB(240, 240, 240))
          
          toolx = #Page_Padding - FormWindows()\paddingx + 8 + 5
          tooly = #Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding + 3
        Case #PB_OS_Linux
          DrawingMode(#PB_2DDrawing_Transparent)
          Box(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding,FormWindows()\width,toptoolpadding,RGB(242, 241, 240))
          
          toolx = #Page_Padding - FormWindows()\paddingx + 8 + 5
          tooly = #Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding + 3
      EndSelect ;}
      
      ForEach FormWindows()\FormToolbars()
        If tooldragpos
          diff = 5
          
          If tooldragpos > toolx - diff And tooldragpos < toolx + diff
            Line(toolx - 3, tooly, 1, 16, RGB(0,0,255))
            Line(toolx - 2, tooly, 1, 16, RGB(0,0,255))
          ElseIf ListIndex(FormWindows()\FormToolbars()) = ListSize(FormWindows()\FormToolbars()) -1 And tooldragpos > toolx + diff
            Line(toolx + 16, tooly, 1, 16, RGB(0,0,255))
            Line(toolx + 17, tooly, 1, 16, RGB(0,0,255))
          EndIf
        EndIf
        
        If FormWindows()\FormToolbars()\separator = 1
          If propgrid_toolbar = FormWindows()\FormToolbars()
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(toolx - 1, tooly - 1, 8, 18, RGB(0,0,0))
            DrawingMode(#PB_2DDrawing_Transparent)
          EndIf
          
          Select FormSkin
            Case #PB_OS_Windows, #PB_OS_Linux
              Line(toolx + 2,tooly + 1, 1, 14, RGB(132,132,132))
              FormWindows()\FormToolbars()\x1 = toolx
              FormWindows()\FormToolbars()\x2 = toolx + 10
              FormWindows()\FormToolbars()\y = tooly
              toolx + 10
            Case #PB_OS_MacOS
              FormWindows()\FormToolbars()\x1 = toolx
              FormWindows()\FormToolbars()\x2 = toolx + 10
              FormWindows()\FormToolbars()\y = tooly
              toolx + 10
          EndSelect
        Else
          If FormWindows()\FormToolbars()\img
            ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormToolbars()\img)
            img = ImageManager(FormWindows()\FormImg()\img)
          Else
            img = #IMAGE_FormIcons_Image
          EndIf
          
          If IsImage(img)
            If ImageDepth(img) = 32
              DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
            Else
              DrawingMode(#PB_2DDrawing_Transparent)
            EndIf
            
            DrawImage(ImageID(img),toolx,tooly,16,16)
            DrawingMode(#PB_2DDrawing_Transparent)
          EndIf
          
          If propgrid_toolbar = FormWindows()\FormToolbars()
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(toolx - 1, tooly - 1, 18, 18, RGB(0,0,0))
            DrawingMode(#PB_2DDrawing_Transparent)
          EndIf
          
          FormWindows()\FormToolbars()\x1 = toolx
          FormWindows()\FormToolbars()\x2 = toolx + 16
          FormWindows()\FormToolbars()\y = tooly
          
          toolx + 16 + 6
        EndIf
      Next
      FormWindows()\toolbar_buttonx = toolx
      FormWindows()\toolbar_buttony = tooly
      
      DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
      DrawImage(ImageID(#Img_Plus),toolx,tooly)
      DrawingMode(#PB_2DDrawing_Transparent)
    EndIf ;}
    
    ;{ Draw Status Bar
    If bottompaddingsb
      Select FormSkin ;{
        Case #PB_OS_MacOS
          sbx = #Page_Padding - FormWindows()\paddingx + 7
          sby = #Page_Padding - FormWindows()\paddingy + topmenupadding + topwinpadding + toptoolpadding + FormWindows()\height - bottompaddingsb
          
          DrawingMode(#PB_2DDrawing_Transparent)
          Line(sbx - 7,sby,FormWindows()\width,1,RGB(184,184,184))
          
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(RGB(211,211,211))
          FrontColor(RGB(1171,171,171))
          LinearGradient(sbx,sby,sbx,sby+23)
          
          RoundBox(#Page_Padding,sby,FormWindows()\width,bottompaddingsb,3,3)
          
          DrawingMode(#PB_2DDrawing_Transparent)
          Line(sbx - 7,sby,FormWindows()\width,1,RGB(118,118,118))
          DrawingFont(FontID(#Form_Font))
        Case #PB_OS_Windows
          sbx = #Page_Padding - FormWindows()\paddingx + 8 + 7
          sby = #Page_Padding - FormWindows()\paddingy + topwinpadding + FormWindows()\height - bottompaddingsb
          
          DrawingMode(#PB_2DDrawing_Transparent)
          Line(sbx - 7,sby,FormWindows()\width,1,RGB(145,145,145))
        Case #PB_OS_Linux
          sbx = #Page_Padding - FormWindows()\paddingx + 8 + 7
          sby = #Page_Padding - FormWindows()\paddingy + topwinpadding + FormWindows()\height - bottompaddingsb
          
          DrawingMode(#PB_2DDrawing_Transparent)
          Line(sbx - 8 - 7,sby,FormWindows()\width,1,RGB(145,145,145))
      EndSelect ;}
      
      ; if #pb_ignore is used, calculate the width of those fields
      sbcountignore = 0
      sbcountwidth = 0
      ForEach FormWindows()\FormStatusbars()
        If FormWindows()\FormStatusbars()\width = -1
          sbcountignore + 1
        Else
          sbcountwidth + FormWindows()\FormStatusbars()\width
        EndIf
      Next
      sbremainingwidth = FormWindows()\width - 14 - sbcountwidth
      
      ForEach FormWindows()\FormStatusbars()
        If FormWindows()\FormStatusbars()\width > -1
          sbwidth = FormWindows()\FormStatusbars()\width
        Else
          sbwidth = sbremainingwidth / sbcountignore
        EndIf
        
        If propgrid_statusbar = FormWindows()\FormStatusbars()
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(sbx, sby, sbwidth, bottompaddingsb, RGB(0,0,0))
          DrawingMode(#PB_2DDrawing_Transparent)
        EndIf
        
        If statusdragpos
          If statusdragpos > FormWindows()\FormStatusbars()\x1 - 5 And statusdragpos < (FormWindows()\FormStatusbars()\x2 - 5)
            Line(sbx - 1, sby, 1, 16, RGB(0,0,255))
            Line(sbx, sby, 1, 16, RGB(0,0,255))
          ElseIf ListIndex(FormWindows()\FormStatusbars()) = ListSize(FormWindows()\FormStatusbars()) -1 And statusdragpos > FormWindows()\FormStatusbars()\x1
            Line(sbx + sbwidth, sby, 1, 16, RGB(0,0,255))
            Line(sbx + sbwidth + 1, sby, 1, 16, RGB(0,0,255))
          EndIf
        EndIf
        
        If FormWindows()\FormStatusbars()\text <> ""
          DrawingMode(#PB_2DDrawing_Transparent)
          
          If FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Center")
            DrawText(sbx + (sbwidth - TextWidth(FormWindows()\FormStatusbars()\text))/2,sby+4,FormWindows()\FormStatusbars()\text,RGB(0,0,0))
          ElseIf FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Right")
            DrawText(sbx + sbwidth - TextWidth(FormWindows()\FormStatusbars()\text),sby+4,FormWindows()\FormStatusbars()\text,RGB(0,0,0))
          Else
            DrawText(sbx,sby+4,FormWindows()\FormStatusbars()\text,RGB(0,0,0))
          EndIf
        ElseIf FormWindows()\FormStatusbars()\progressbar
          x1 = sbx
          y1 = sby + 5
          x2 = sbx + sbwidth
          y2 = sby + 23 - 5
          
          DrawingMode(#PB_2DDrawing_Transparent)
          If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
            color = RGB(230,230,230)
          Else
            color = RGB(220,220,220)
          EndIf
          
          If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
            Box(x1,y1,x2 - x1, y2 - y1,color)
          Else
            RoundBox(x1,y1,x2 - x1, y2 - y1,3,3,color)
          EndIf
          
          If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
            color = RGB(6,176,37)
          Else
            color = RGB(134,206,244)
          EndIf
          
          Box(x1 + 1, y1 + 1, (x2 - x1) / 2 - 2, y2 - y1 - 2,color)
          
          DrawingMode(#PB_2DDrawing_Outlined)
          If FormSkin = #PB_OS_Windows And FormSkinVersion = 8
            Box(x1,y1,x2 - x1, y2 - y1,RGB(188,188,188))
          Else
            RoundBox(x1,y1,x2 - x1, y2 - y1,3,3,RGB(152,152,152))
          EndIf
        Else
          If FormWindows()\FormStatusbars()\img
            ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormStatusbars()\img)
            img = ImageManager(FormWindows()\FormImg()\img)
          Else
            img = #IMAGE_FormIcons_Image
          EndIf
          
          If IsImage(img)
            If FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Center")
              toolx = sbx + (sbwidth - ImageWidth(img))/2
              tooly = sby + 4
            ElseIf FormWindows()\FormStatusbars()\flags & FlagValue("#PB_StatusBar_Right")
              toolx = sbx + sbwidth - ImageWidth(img)
              tooly = sby + 4
            Else
              toolx = sbx
              tooly = sby + 4
            EndIf
            
            If ImageDepth(img) = 32
              DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
            Else
              DrawingMode(#PB_2DDrawing_Transparent)
            EndIf
            
            DrawImage(ImageID(img),toolx,tooly)
            DrawingMode(#PB_2DDrawing_Transparent)
          EndIf
        EndIf
        
        FormWindows()\FormStatusbars()\x1 = sbx
        FormWindows()\FormStatusbars()\x2 = sbx + sbwidth
        FormWindows()\FormStatusbars()\y = sby
        sbx + sbwidth
        
        ; draw field separator on windows/linux
        If FormSkin = #PB_OS_Windows
          If ListIndex(FormWindows()\FormStatusbars()) < ListSize(FormWindows()\FormStatusbars())-1
            Line(sbx,sby + 1,1,bottompaddingsb - 1,RGB(215,215,215))
          EndIf
        EndIf
        If FormSkin = #PB_OS_Linux
          If ListIndex(FormWindows()\FormStatusbars()) < ListSize(FormWindows()\FormStatusbars())-1
            Line(sbx,sby + 1,1,bottompaddingsb - 1,RGB(215,215,215))
          EndIf
        EndIf
      Next
      
      DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
      DrawImage(ImageID(#Img_Plus),sbx,sby + 4)
      DrawingMode(#PB_2DDrawing_Transparent)
      FormWindows()\status_buttonx = sbx
      FormWindows()\status_buttony = sby
    EndIf ;}
    
    ;{ Draw final window border on Mac
    If FormSkin = #PB_OS_MacOS
      DrawingMode(#PB_2DDrawing_Outlined)
      RoundBox(#Page_Padding - FormWindows()\paddingx - 1,#Page_Padding - 1 - FormWindows()\paddingy + topmenupadding,FormWindows()\width + 2,FormWindows()\height + 2 + topwinpadding + toptoolpadding, 4,4,RGB(118,118,118))
      DrawingMode(#PB_2DDrawing_Transparent)
    EndIf ;}
    
    ;{ draw all gadgets. messy code to check if the gadget is visible (esp. when parent is a panel or scrollarea)
    ForEach FormWindows()\FormGadgets()
      If Not FormWindows()\FormGadgets()\hidden
        this_parent = FormWindows()\FormGadgets()\parent
        this_parent_item = FormWindows()\FormGadgets()\parent_item
        x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
        xmin = 0 : xmax = FormWindows()\width : ymin = 0 : ymax = FormWindows()\height
        scrollx = 0 : scrolly = 0
        
        oldparent = this_parent
        dontdraw = 0
        While this_parent <> 0
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(this_parent)
          
          x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
          x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
          y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
          y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
          
          If this_parent <> oldparent
            scrollx + FormWindows()\FormGadgets()\scrollx
            scrolly + FormWindows()\FormGadgets()\scrolly
          EndIf
          
          If FormWindows()\FormGadgets()\x1 > 0
            xmin + FormWindows()\FormGadgets()\x1
          EndIf
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Panel And FormWindows()\FormGadgets()\y1 + Panel_Height > 0
            ymin + FormWindows()\FormGadgets()\y1 + Panel_Height
          ElseIf FormWindows()\FormGadgets()\y1 > 0
            ymin + FormWindows()\FormGadgets()\y1
          EndIf
          
          If FormWindows()\FormGadgets()\hidden
            dontdraw = 1
          EndIf
          
          If FormWindows()\FormGadgets()\type = #Form_Type_Panel
            y1 + Panel_Height
            y2 + Panel_Height
            
            If this_parent_item <> FormWindows()\FormGadgets()\current_item ; the item is not currently displayed, don't draw the gadget
              dontdraw = 1
            EndIf
          EndIf
          this_parent = FormWindows()\FormGadgets()\parent
          this_parent_item = FormWindows()\FormGadgets()\parent_item
          PopListPosition(FormWindows()\FormGadgets())
        Wend
        
        If FormWindows()\FormGadgets()\parent
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(FormWindows()\FormGadgets()\parent)
          
          xmax + xmin + FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
          If x1 - xmin < 0
            xmax + x1 -  xmin
          EndIf
          
          ymax + ymin + FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
          If y1 - ymin < 0
            ymax + y1 - ymin
          EndIf
          
          ymin - scrolly
          xmin - scrollx
          
          If FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
            xmax - P_ScrollWidth
            ymax - P_ScrollWidth
          EndIf
          
          PopListPosition(FormWindows()\FormGadgets())
        EndIf
        
        this_parent = FormWindows()\FormGadgets()\parent
        While this_parent <> 0
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(this_parent)
          
          x1gadget = FD_GetGadgetXY(this_parent,2)
          y1gadget = FD_GetGadgetXY(this_parent,3)
          x2gadget = FD_GetGadgetXY(this_parent,0)
          y2gadget = FD_GetGadgetXY(this_parent,1)
          
          If ymin < y1gadget
            ymin = y1gadget
          EndIf
          If xmin < x1gadget
            xmin = x1gadget
          EndIf
          If xmax > x2gadget
            xmax = x2gadget
          EndIf
          If ymax > y2gadget
            ymax = y2gadget
          EndIf
          
          this_parent = FormWindows()\FormGadgets()\parent
          PopListPosition(FormWindows()\FormGadgets())
        Wend
        
        If FormWindows()\FormGadgets()\parent
          PushListPosition(FormWindows()\FormGadgets())
          FD_FindParent(FormWindows()\FormGadgets()\parent)
          
          If FormWindows()\FormGadgets()\type = #Form_Type_ScrollArea
            xmax - P_ScrollWidth
            ymax - P_ScrollWidth
          EndIf
          
          PopListPosition(FormWindows()\FormGadgets())
        EndIf
        
        If Not dontdraw
          x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\paddingx + #Page_Padding + leftpadding
          x2 + FormWindows()\FormGadgets()\x2 - FormWindows()\paddingx + #Page_Padding + leftpadding
          y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding
          y2 + FormWindows()\FormGadgets()\y2 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding
          
          xmin - FormWindows()\paddingx + #Page_Padding + leftpadding
          xmax - FormWindows()\paddingx + #Page_Padding + leftpadding
          ymin - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding
          ymax - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding
          
          If FD_DrawGadget(x1,y1,x2,y2,FormWindows()\FormGadgets()\type,FormWindows()\FormGadgets()\caption, FormWindows()\FormGadgets()\flags, FormWindows()\FormGadgets()\g_data, ListSize( FormWindows()\FormGadgets()\Items()),FormWindows()\FormGadgets())
            
            ; if selected, draw the border/resize
            If FormWindows()\FormGadgets()\selected
              DrawingMode(#PB_2DDrawing_Outlined)
              If FormWindows()\FormGadgets()\splitter
                Box(x1 + 1,y1 + 1,x2 - x1 - 2, y2 - y1 - 2,RGB(108, 121, 230))
              Else
                Box(x1,y1,x2 - x1, y2 - y1,RGB(0,0,0))
              EndIf
              
              If Not FormWindows()\FormGadgets()\splitter
                DrawingMode(#PB_2DDrawing_Transparent)
                FD_DrawResizeButton(x1,y1)
                FD_DrawResizeButton(x2,y1)
                FD_DrawResizeButton(x1,y2)
                FD_DrawResizeButton(x2,y2)
                FD_DrawResizeButton((x1 + x2)/2,y1)
                FD_DrawResizeButton((x1 + x2)/2,y2)
                FD_DrawResizeButton(x1,(y1 + y2)/2)
                FD_DrawResizeButton(x2,(y1 + y2)/2)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Next ;}
    
    ;{ draw the new gadget if applicable
    If drawing And d_x2 > d_x1 And d_y2 > d_y1
      xmin = 0 : xmax = 9999 : ymin = 0 : ymax = 9999
      Select FormSkin
        Case #PB_OS_MacOS
          DrawSuccess = FD_DrawGadget(d_x1 - FormWindows()\paddingx + #Page_Padding,d_y1 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding,d_x2 - FormWindows()\paddingx + #Page_Padding,d_y2 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding,form_gadget_type)
        Case #PB_OS_Windows
          DrawSuccess = FD_DrawGadget(d_x1 + leftpadding - FormWindows()\paddingx + #Page_Padding,d_y1 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding,d_x2 - FormWindows()\paddingx + #Page_Padding + leftpadding,d_y2 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding,form_gadget_type)
        Case #PB_OS_Linux
          DrawSuccess = FD_DrawGadget(d_x1 + leftpadding - FormWindows()\paddingx + #Page_Padding,d_y1 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding,d_x2 - FormWindows()\paddingx + #Page_Padding + leftpadding,d_y2 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding,form_gadget_type)
      EndSelect
      
      If DrawSuccess
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(d_x1 + leftpadding - FormWindows()\paddingx + #Page_Padding, d_y1 - FormWindows()\paddingy + #Page_Padding + topwinpadding + toptoolpadding + topmenupadding, d_x2 - d_x1, d_y2 - d_y1,RGB(0,0,0))
      EndIf
    EndIf ;}
    
    ;{ Draw menu
    Select FormSkin ;{
      Case #PB_OS_MacOS
        DrawingMode(#PB_2DDrawing_Transparent)
        Line(0,0,OutputWidth(),1,RGB(85,85,85))
        If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(RGB(251,251,251))
          FrontColor(RGB(218,218,218))
          LinearGradient(0,1,0,22)
          Box(0,1,OutputWidth(),21)
          DrawingMode(#PB_2DDrawing_Transparent)
          Line(0,22,OutputWidth(),1,RGB(118,118,118))
          menux = 20
          menuy = 4
          menuspace = 20
        EndIf
      Case #PB_OS_Windows
        If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
          DrawingMode(#PB_2DDrawing_Transparent)
          Select FormSkinVersion
            Case 7
              Box(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding,FormWindows()\width,7,RGB(245,245,245))
              Box(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding + 7,FormWindows()\width,11,RGB(218,224,241))
              Line(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding + 19,FormWindows()\width,1,RGB(182,188,204))
              Line(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding + 20,FormWindows()\width,1,RGB(240,240,240))
              Line(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding + 21,FormWindows()\width,1,RGB(160,160,160))
            Case 8
              Box(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding,FormWindows()\width,21,RGB(245,246,247))
              Line(#Page_Padding - FormWindows()\paddingx + 8,#Page_Padding - FormWindows()\paddingy + topwinpadding + 21,FormWindows()\width,1,RGB(232,233,234))
          EndSelect
          
          menux = #Page_Padding - FormWindows()\paddingx + 8 + 7
          menuy = #Page_Padding - FormWindows()\paddingy + topwinpadding + 2
          menuspace = 7
        EndIf
        
      Case #PB_OS_Linux
        If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
          DrawingMode(#PB_2DDrawing_Transparent)
          Box(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topwinpadding,FormWindows()\width,topmenupadding - 1,RGB(245,246,247))
          Line(#Page_Padding - FormWindows()\paddingx,#Page_Padding - FormWindows()\paddingy + topwinpadding + topmenupadding - 1,FormWindows()\width,1,RGB(232,233,234))
          
          menux = #Page_Padding - FormWindows()\paddingx + 8 + 7
          menuy = #Page_Padding - FormWindows()\paddingy + topwinpadding + 2
          menuspace = 7
        EndIf
        
    EndSelect ;}
    
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(#Form_FontMenu))
    
    If propgrid_menu
      NewList items.i()
      
      ChangeCurrentElement(FormWindows()\FormMenus(),propgrid_menu)
      AddElement(items()) : items() = FormWindows()\FormMenus()
      
      level = FormWindows()\FormMenus()\level
      If level
        Repeat
          PreviousElement(FormWindows()\FormMenus())
          If FormWindows()\FormMenus()\level < level
            AddElement(items()) : items() = FormWindows()\FormMenus()
            level = FormWindows()\FormMenus()\level
          EndIf
        Until level = 0
      EndIf
    EndIf
    
    ForEach FormWindows()\FormMenus()
      FormWindows()\FormMenus()\x1 = 0
      FormWindows()\FormMenus()\x2 = 0
      FormWindows()\FormMenus()\y1 = 0
      FormWindows()\FormMenus()\y2 = 0
    Next
    ClearList(FormWindows()\FormMenuButtons())
    
    ForEach FormWindows()\FormMenus()
      If FormWindows()\FormMenus()\level = 0
        FormWindows()\FormMenus()\x1 = menux
        FormWindows()\FormMenus()\y1 = menuy
        menux = DrawText(menux,menuy,FormWindows()\FormMenus()\item,RGB(0,0,0))
        menux + menuspace
        FormWindows()\FormMenus()\y2 = menuy + TextHeight(FormWindows()\FormMenus()\item)
        FormWindows()\FormMenus()\x2 = menux
        
        If propgrid_menu = FormWindows()\FormMenus()
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(FormWindows()\FormMenus()\x1 - 1, FormWindows()\FormMenus()\y1 - 1, FormWindows()\FormMenus()\x2 - FormWindows()\FormMenus()\x1 , FormWindows()\FormMenus()\y2 - FormWindows()\FormMenus()\y1 + 2, RGB(0,0,0))
          DrawingMode(#PB_2DDrawing_Transparent)
        EndIf
      EndIf
    Next
    
    If ListSize(FormWindows()\FormMenus()) Or FormWindows()\menu_visible
      FormWindows()\menu_buttonx = menux
      FormWindows()\menu_buttony = menuy
      DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
      DrawImage(ImageID(#Img_Plus),menux,menuy)
      DrawingMode(#PB_2DDrawing_Transparent)
    EndIf
    
    If propgrid_menu And ListSize(items()) >= 1
      LastElement(items())
      Repeat
        ChangeCurrentElement(FormWindows()\FormMenus(),items())
        level = FormWindows()\FormMenus()\level + 1
        height = 20
        width = 0
        
        Repeat
          finish = NextElement(FormWindows()\FormMenus())
          
          If Not finish
            Break
          EndIf
          
          If FormWindows()\FormMenus()\level = level
            textwidth = TextWidth(FormWindows()\FormMenus()\item)
            
            If FormWindows()\FormMenus()\shortcut
              textwidth + TextWidth(FormWindows()\FormMenus()\shortcut)
            EndIf
            
            textwidth + 16 + 8 ; icon
            
            If textwidth > width
              width = textwidth
            EndIf
            
            If FormWindows()\FormMenus()\separator
              height + 12
            Else
              height + 20
            EndIf
            
          EndIf
          
        Until FormWindows()\FormMenus()\level < level
        
        width + 40
        
        If width < 100
          width = 100
        EndIf
        
        ChangeCurrentElement(FormWindows()\FormMenus(),items())
        If ListIndex(items()) = ListSize(items()) - 1
          submenux = FormWindows()\FormMenus()\x1
          If FormSkin = #PB_OS_MacOS
            submenuy = menuy - 4 + topmenupadding
          Else
            submenuy = menuy - 2 + topmenupadding
          EndIf
        Else
          submenux = nextmenux
          submenuy = nextmenuy
        EndIf
        
        nextmenux = submenux + width
        nextmenuy = submenuy
        
        PushListPosition(items())
        nextel = items()
        If PreviousElement(items())
          nextel = items()
        Else
          nextel = -1
        EndIf
        PopListPosition(items())
        
        ChangeCurrentElement(FormWindows()\FormMenus(),items())
        If FormWindows()\FormMenus()\separator
          Break
        EndIf
        
        DrawingMode(#PB_2DDrawing_Transparent)
        Box(submenux,submenuy,width,height,RGB(255,255,255))
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(submenux,submenuy,width,height,RGB(200,200,200))
        DrawingMode(#PB_2DDrawing_Transparent)
        ChangeCurrentElement(FormWindows()\FormMenus(),items())
        
        level = FormWindows()\FormMenus()\level + 1
        posy = submenuy
        
        count = 0
        Repeat
          previous_el = FormWindows()\FormMenus()
          finish = NextElement(FormWindows()\FormMenus())
          
          If FormWindows()\FormMenus() = nextel
            nextmenuy = posy
            
            If Not finish
              nextmenuy - 20
            EndIf
          EndIf
          
          If finish
            If FormWindows()\FormMenus()\level = level
              If FormWindows()\FormMenus()\separator
                Line(submenux,posy + 6,width ,1,RGB(200,200,200))
                FormWindows()\FormMenus()\x1 = submenux
                FormWindows()\FormMenus()\x2 = submenux + width
                FormWindows()\FormMenus()\y1 = posy
                FormWindows()\FormMenus()\y2 = posy + 12
                posy + 12
              Else
                If FormWindows()\FormMenus()\icon
                  ChangeCurrentElement(FormWindows()\FormImg(),FormWindows()\FormMenus()\icon)
                  img = ImageManager(FormWindows()\FormImg()\img)
                  
                  If IsImage(img)
                    If ImageDepth(img) = 32
                      DrawingMode(#PB_2DDrawing_AlphaBlend | #PB_2DDrawing_Transparent)
                    Else
                      DrawingMode(#PB_2DDrawing_Transparent)
                    EndIf
                    
                    DrawImage(ImageID(img),submenux + 3,posy + 2,16,16)
                    DrawingMode(#PB_2DDrawing_Transparent)
                  EndIf
                EndIf
                
                DrawText(submenux + 24, posy, FormWindows()\FormMenus()\item,RGB(0,0,0))
                
                If FormWindows()\FormMenus()\shortcut
                  DrawText(submenux + width - 10 - TextWidth(FormWindows()\FormMenus()\shortcut),posy, FormWindows()\FormMenus()\shortcut, RGB(0,0,0))
                EndIf
                
                FormWindows()\FormMenus()\x1 = submenux
                FormWindows()\FormMenus()\x2 = submenux + width
                FormWindows()\FormMenus()\y1 = posy
                FormWindows()\FormMenus()\y2 = posy + 20
                
                sub = 0
                PushListPosition(FormWindows()\FormMenus())
                If NextElement(FormWindows()\FormMenus())
                  If FormWindows()\FormMenus()\level > level
                    sub = 1
                  EndIf
                EndIf
                PopListPosition(FormWindows()\FormMenus())
                
                If sub
                  DrawingMode(#PB_2DDrawing_Transparent | #PB_2DDrawing_AlphaBlend)
                  DrawImage(ImageID(#Img_MacSubMenu),submenux + width - 20,posy + 4)
                  DrawingMode(#PB_2DDrawing_Transparent)
                EndIf
                
                posy + 20
              EndIf
              
              If propgrid_menu = FormWindows()\FormMenus()
                DrawingMode(#PB_2DDrawing_Outlined)
                Box(FormWindows()\FormMenus()\x1, FormWindows()\FormMenus()\y1, FormWindows()\FormMenus()\x2 - FormWindows()\FormMenus()\x1 , FormWindows()\FormMenus()\y2 - FormWindows()\FormMenus()\y1, RGB(0,0,0))
                DrawingMode(#PB_2DDrawing_Transparent)
              EndIf
            EndIf
          Else
            Break
          EndIf
          count + 1
        Until FormWindows()\FormMenus()\level < level
        
        AddElement(FormWindows()\FormMenuButtons())
        FormWindows()\FormMenuButtons()\x1 = submenux
        FormWindows()\FormMenuButtons()\x2 = submenux + width
        FormWindows()\FormMenuButtons()\y1 = posy
        FormWindows()\FormMenuButtons()\y2 = posy + 20
        FormWindows()\FormMenuButtons()\level = ListSize(items()) - ListIndex(items())
        
        If FormWindows()\FormMenus()\level > 0 And count = 0
          PreviousElement(FormWindows()\FormMenus())
        EndIf
        
        FormWindows()\FormMenuButtons()\previous_el = previous_el
        DrawText(submenux + 5, posy, "Add Item...",RGB(0,0,0))
      Until PreviousElement(items()) = 0
    EndIf
    
    If ListSize(FormWindows()\FormMenus())
      level = 0
      FirstElement(FormWindows()\FormMenus())
      menuy2 = FormWindows()\FormMenus()\y2
      
      ForEach FormWindows()\FormMenus()
        ; drag before the first menu title
        If ListIndex(FormWindows()\FormMenus()) = 0 And menudragposx <= FormWindows()\FormMenus()\x1 And menudragposy >= FormWindows()\FormMenus()\y1 And menudragposy < FormWindows()\FormMenus()\y2
          Line(FormWindows()\FormMenus()\x1 - 1, FormWindows()\FormMenus()\y1, 1, 16, RGB(0,0,255))
          Line(FormWindows()\FormMenus()\x1, FormWindows()\FormMenus()\y1, 1, 16, RGB(0,0,255))
        EndIf
        
        ; drag before the first menu item
        If FormWindows()\FormMenus()\level > level And menudragposy >= FormWindows()\FormMenus()\y1 - 1 And menudragposy < FormWindows()\FormMenus()\y1 + 1 And menudragposx > FormWindows()\FormMenus()\x1 And menudragposx <= FormWindows()\FormMenus()\x2
          Line(FormWindows()\FormMenus()\x1, FormWindows()\FormMenus()\y1 - 1, FormWindows()\FormMenus()\x2 - FormWindows()\FormMenus()\x1, 1, RGB(0,0,255))
          Line(FormWindows()\FormMenus()\x1, FormWindows()\FormMenus()\y1, FormWindows()\FormMenus()\x2 - FormWindows()\FormMenus()\x1, 1, RGB(0,0,255))
        EndIf
        
        If menudragposx > FormWindows()\FormMenus()\x1 And menudragposx <= FormWindows()\FormMenus()\x2 And menudragposy > FormWindows()\FormMenus()\y1 + 1 And menudragposy <= FormWindows()\FormMenus()\y2
          If FormWindows()\FormMenus()\level = 0
            Line(FormWindows()\FormMenus()\x2, FormWindows()\FormMenus()\y1, 1, 16, RGB(0,0,255))
            Line(FormWindows()\FormMenus()\x2 + 1, FormWindows()\FormMenus()\y1, 1, 16, RGB(0,0,255))
          Else
            Line(FormWindows()\FormMenus()\x1, FormWindows()\FormMenus()\y2, FormWindows()\FormMenus()\x2 - FormWindows()\FormMenus()\x1, 1, RGB(0,0,255))
            Line(FormWindows()\FormMenus()\x1, FormWindows()\FormMenus()\y2 + 1, FormWindows()\FormMenus()\x2 - FormWindows()\FormMenus()\x1, 1, RGB(0,0,255))
          EndIf
        EndIf
        
        If FormWindows()\FormMenus() = propgrid_menu ; move to a new level
          oldLevel = FormWindows()\FormMenus()\level
          PushListPosition(FormWindows()\FormMenus())
          check = 0
          If NextElement(FormWindows()\FormMenus())
            If FormWindows()\FormMenus()\level <= oldLevel
              PreviousElement(FormWindows()\FormMenus())
              check = 1
            EndIf
          EndIf
          
          ; move to an empty opened submenu
          If check And menudragposx > FormWindows()\FormMenus()\x2 And menudragposy > menuy2
            Line(FormWindows()\FormMenus()\x2, FormWindows()\FormMenus()\y1, 100, 1, RGB(0,0,255))
            Line(FormWindows()\FormMenus()\x2, FormWindows()\FormMenus()\y1 + 1, 100, 1, RGB(0,0,255))
          EndIf
          PopListPosition(FormWindows()\FormMenus())
        EndIf
        
        level = FormWindows()\FormMenus()\level
      Next
    EndIf
    
    
    ;}
    
    StopDrawing()
    
    If StartDrawing(CanvasOutput(#GADGET_Form_Canvas))
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawImage(ImageID(#Drawing_Img),0,0)
      StopDrawing()
    EndIf
  EndIf
  duration.q = ElapsedMilliseconds() - starttime
  If duration < 35
    Delay(15)
  EndIf
EndProcedure
Procedure FD_KeyDown(key, modifier)
  ChangeCurrentElement(FormWindows(),currentwindow)
  addaction = 1
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      redraw = 1
      Select key
        Case #PB_Shortcut_Delete, #PB_Shortcut_Back
          FD_DeleteGadgetA(FormWindows()\FormGadgets())
          FD_DeleteGadgetB()
          FD_SelectWindow(FormWindows())
          
        Case #PB_Shortcut_Left
          If modifier & #PB_Canvas_Shift
            If FD_AlignPoint(FormWindows()\FormGadgets()\x2 - FormGridSize) > FormWindows()\FormGadgets()\x1
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + width - FormGridSize
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,0)
            EndIf
          Else
            If FD_AlignPoint(FormWindows()\FormGadgets()\x1 - FormGridSize) >= 0 And FD_AlignPoint(FormWindows()\FormGadgets()\x2 - FormGridSize) <= FormWindows()\width
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
              FormWindows()\FormGadgets()\x1 = FD_AlignPoint(FormWindows()\FormGadgets()\x1 - FormGridSize)
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + width
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,0)
            EndIf
          EndIf
          FD_SelectGadget(FormWindows()\FormGadgets())
        Case #PB_Shortcut_Right
          If modifier & #PB_Canvas_Shift
            If FD_AlignPoint(FormWindows()\FormGadgets()\x2 + FormGridSize) <= FormWindows()\width
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + width + FormGridSize
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
            EndIf
          Else
            
            If FD_AlignPoint(FormWindows()\FormGadgets()\x1 + FormGridSize) >= 0 And FD_AlignPoint(FormWindows()\FormGadgets()\x2 + FormGridSize) <= FormWindows()\width
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
              FormWindows()\FormGadgets()\x1 = FD_AlignPoint(FormWindows()\FormGadgets()\x1 + FormGridSize)
              FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + width
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
            EndIf
          EndIf
          FD_SelectGadget(FormWindows()\FormGadgets())
        Case #PB_Shortcut_Up
          If modifier & #PB_Canvas_Shift
            If FD_AlignPoint(FormWindows()\FormGadgets()\y2 - FormGridSize) > FormWindows()\FormGadgets()\y1
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height - FormGridSize
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
            EndIf
          Else
            If FD_AlignPoint(FormWindows()\FormGadgets()\y1 - FormGridSize) >= 0 And FD_AlignPoint(FormWindows()\FormGadgets()\y2 - FormGridSize) <= FormWindows()\height
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
              FormWindows()\FormGadgets()\y1 = FD_AlignPoint(FormWindows()\FormGadgets()\y1 - FormGridSize)
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
            EndIf
          EndIf
          SetActiveGadget(#GADGET_Form_Canvas)
          FD_SelectGadget(FormWindows()\FormGadgets())
        Case #PB_Shortcut_Down
          If modifier & #PB_Canvas_Shift
            If FD_AlignPoint(FormWindows()\FormGadgets()\y2 + FormGridSize) <= FormWindows()\height
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height + FormGridSize
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
            EndIf
          Else
            If FD_AlignPoint(FormWindows()\FormGadgets()\y1 + FormGridSize) >= 0 And FD_AlignPoint(FormWindows()\FormGadgets()\y2 + FormGridSize) <= FormWindows()\height
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
              addaction = 0
              height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
              FormWindows()\FormGadgets()\y1 = FD_AlignPoint(FormWindows()\FormGadgets()\y1 + FormGridSize)
              FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height
              FD_UpdateSplitter()
              FormChanges(1)
              FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
            EndIf
          EndIf
          SetActiveGadget(#GADGET_Form_Canvas)
          FD_SelectGadget(FormWindows()\FormGadgets())
      EndSelect
    EndIf
  Next
  
EndProcedure
Procedure FD_RightClick(x, y)
  If y >= FormWindows()\toolbar_buttony And y <= FormWindows()\toolbar_buttony + 16
    menu_el = 0
    
    ForEach FormWindows()\FormToolbars()
      If x >= FormWindows()\FormToolbars()\x1 And x <= FormWindows()\FormToolbars()\x2
        menu_el = FormWindows()\FormToolbars()
        Break
      EndIf
    Next
    
    If menu_el
      DisplayPopupMenu(#Form_Menu10,WindowID(#WINDOW_Main))
    Else
      DisplayPopupMenu(#Form_Menu9,WindowID(#WINDOW_Main))
    EndIf
  ElseIf y >= FormWindows()\status_buttony And y <= FormWindows()\status_buttony + bottompaddingsb
    menu_el = 0
    
    ForEach FormWindows()\FormStatusbars()
      If x >= FormWindows()\FormStatusbars()\x1 And x <= FormWindows()\FormStatusbars()\x2
        menu_el = FormWindows()\FormStatusbars()
        Break
      EndIf
    Next
    
    If menu_el
      DisplayPopupMenu(#Form_Menu13,WindowID(#WINDOW_Main))
    Else
      DisplayPopupMenu(#Form_Menu12,WindowID(#WINDOW_Main))
    EndIf
    
  Else ; menu right click
    menu_el = 0
    ForEach FormWindows()\FormMenus()
      If x >= FormWindows()\FormMenus()\x1 And x <= FormWindows()\FormMenus()\x2 And y >= FormWindows()\FormMenus()\y1 And y <= FormWindows()\FormMenus()\y2
        menu_el = FormWindows()\FormMenus()
        Break
      EndIf
    Next
    
    If menu_el
      DisplayPopupMenu(#Form_Menu15,WindowID(#WINDOW_Main))
    Else
      If y >= FormWindows()\menu_buttony And y <= FormWindows()\menu_buttony + topmenupadding
        DisplayPopupMenu(#Form_Menu14,WindowID(#WINDOW_Main))
        menu_el = 1
      EndIf
    EndIf
    
    If Not menu_el ; gadget or other
      PushListPosition(FormWindows()\FormGadgets())
      el = 0
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\selected
          el = FormWindows()\FormGadgets()
          Break
        EndIf
      Next
      
      menu_el = 0
      
      If el
        ForEach ObjList()
          If ObjList()\gadget = el
            menu_el = ObjList()
            Break
          EndIf
        Next
      EndIf
      PopListPosition(FormWindows()\FormGadgets())
      
      If menu_el
        PushListPosition(FormWindows()\FormGadgets())
        ChangeCurrentElement(FormWindows()\FormGadgets(),el)
        Select FormWindows()\FormGadgets()\type
          Case #Form_Type_Panel,#Form_Type_TreeGadget, #Form_Type_ListView, #Form_Type_Combo,#Form_Type_Editor
            DisplayPopupMenu(#Form_Menu17,WindowID(#WINDOW_Main))
          Case #Form_Type_ListIcon
            DisplayPopupMenu(#Form_Menu16,WindowID(#WINDOW_Main))
          Default
            DisplayPopupMenu(#Form_Menu1,WindowID(#WINDOW_Main))
        EndSelect
        PopListPosition(FormWindows()\FormGadgets())
      Else
        DisplayPopupMenu(#Form_Menu6,WindowID(#WINDOW_Main))
      EndIf
    EndIf
  EndIf
  
EndProcedure
Procedure FD_AlignLeft()
  left = 0
  If FormWindows()\lastgadgetselected
    If ChangeCurrentElement(FormWindows()\FormGadgets(), FormWindows()\lastgadgetselected)
      left = FormWindows()\FormGadgets()\x1
    EndIf
    
  EndIf
  
  addaction = 1
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
      addaction = 0
      width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
      FormWindows()\FormGadgets()\x1 = left
      FormWindows()\FormGadgets()\x2 = left + width
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
    EndIf
  Next
  
  redraw = 1
EndProcedure
Procedure FD_AlignTop()
  top = 0
  If FormWindows()\lastgadgetselected
    If ChangeCurrentElement(FormWindows()\FormGadgets(), FormWindows()\lastgadgetselected)
      top = FormWindows()\FormGadgets()\y1
    EndIf
    
  EndIf
  
  addaction = 1
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
      addaction = 0
      height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
      FormWindows()\FormGadgets()\y1 = top
      FormWindows()\FormGadgets()\y2 = top + height
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
    EndIf
  Next
  
  redraw = 1
EndProcedure
Procedure FD_AlignHeight()
  height = 0
  If FormWindows()\lastgadgetselected
    If ChangeCurrentElement(FormWindows()\FormGadgets(), FormWindows()\lastgadgetselected)
      height = FormWindows()\FormGadgets()\y1
    EndIf
    
  EndIf
  
  addaction = 1
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
      addaction = 0
      FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + height
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
    EndIf
  Next
  
  redraw = 1
EndProcedure
Procedure FD_AlignWidth()
  width = 0
  If FormWindows()\lastgadgetselected
    If ChangeCurrentElement(FormWindows()\FormGadgets(), FormWindows()\lastgadgetselected)
      width = FormWindows()\FormGadgets()\y1
    EndIf
    
  EndIf
  
  addaction = 1
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets()\selected
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0,1)
      addaction = 0
      FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + width
      FormAddUndoAction(addaction,FormWindows(),FormWindows()\FormGadgets(),0)
    EndIf
  Next
  
  redraw = 1
EndProcedure

Global form_select_parent_gadget
Procedure FD_UpdateSelectParent()
  parent_sel = GetGadgetState(#GADGET_Form_Parent_Select)
  
  If parent_sel > -1
    parent_sel = GetGadgetItemData(#GADGET_Form_Parent_Select,parent_sel)
    
    PushListPosition(FormWindows()\FormGadgets())
    ForEach FormWindows()\FormGadgets()
      If FormWindows()\FormGadgets()\itemnumber = parent_sel
        Break
      EndIf
    Next
    
    ClearGadgetItems(#GADGET_Form_Parent_SelectItem)
    
    i = 0
    ForEach FormWindows()\FormGadgets()\Items()
      AddGadgetItem(#GADGET_Form_Parent_SelectItem, i, FormWindows()\FormGadgets()\Items()\name)
      i + 1
    Next
    
    If i > 0
      SetGadgetState(#GADGET_Form_Parent_SelectItem, 0)
    EndIf
    
    PopListPosition(FormWindows()\FormGadgets())
  EndIf
  
  
EndProcedure
Procedure FD_InitSelectParent(parent_gadget)
  Protected xml
  Protected Title$
  
  xml = CatchXML(#PB_Any, ?FormParent_Start, ?FormParent_End - ?FormParent_Start)
  If XMLStatus(xml) <> #PB_XML_Success Or Not CreateDialog(#WINDOW_Form_Parent)
    ProcedureReturn
  EndIf
  
  If Not OpenXMLDialog(#WINDOW_Form_Parent, xml, "", #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore, WindowID(#WINDOW_Main))
    FreeDialog(#WINDOW_Form_Parent)
    ProcedureReturn
  EndIf
  
  DisableWindow(#WINDOW_Main,1)
  
  If FormWindows()\FormGadgets()\pbany
    Title$ = ReplaceString(Language("Form","ParentTitle"), "%id%", FormWindows()\FormGadgets()\variable)
  Else
    Title$ = ReplaceString(Language("Form","ParentTitle"), "%id%", "#" + FormWindows()\FormGadgets()\variable)
  EndIf  
  
  SetWindowTitle(#WINDOW_Form_Parent, Title$)
  SetGadgetText(#GADGET_Form_Parent_Select_Text, Language("Form","Parent"))
  SetGadgetText(#GADGET_Form_Parent_SelectItem_Text, Language("Form","ParentItem"))
  SetGadgetText(#GADGET_Form_Parent_OK, Language("Form","OK"))
  SetGadgetText(#GADGET_Form_Parent_Cancel, Language("Form","Cancel"))
  RefreshDialog(#WINDOW_Form_Parent)
  
  i = 0
  selected = 0
  this_gadget = FormWindows()\FormGadgets()
  
  AddGadgetItem(#GADGET_Form_Parent_Select,i,FormWindows()\variable)
  SetGadgetItemData(#GADGET_Form_Parent_Select,i,0)
  i + 1
  
  PushListPosition(FormWindows()\FormGadgets())
  ForEach FormWindows()\FormGadgets()
    If FormWindows()\FormGadgets() <> this_gadget
      Select FormWindows()\FormGadgets()\type
        Case #Form_Type_Container, #Form_Type_Panel, #Form_Type_ScrollArea
          AddGadgetItem(#GADGET_Form_Parent_Select,i,FormWindows()\FormGadgets()\variable)
          SetGadgetItemData(#GADGET_Form_Parent_Select,i,FormWindows()\FormGadgets()\itemnumber)
          
          If FormWindows()\FormGadgets()\itemnumber = parent_gadget
            selected = i
          EndIf
          
          i + 1
        Case #Form_Type_Frame3D
          If FormWindows()\FormGadgets()\flags & #PB_Frame_Container
            AddGadgetItem(#GADGET_Form_Parent_Select,i,FormWindows()\FormGadgets()\variable)
            SetGadgetItemData(#GADGET_Form_Parent_Select,i,FormWindows()\FormGadgets()\itemnumber)
            
            If FormWindows()\FormGadgets()\itemnumber = parent_gadget
              selected = i
            EndIf
            
            i + 1
          EndIf
      EndSelect
    EndIf
  Next
  PopListPosition(FormWindows()\FormGadgets())
  
  If i > 0
    SetGadgetState(#GADGET_Form_Parent_Select, selected)
  EndIf
  
  FD_UpdateSelectParent()
  
  DataSection
    FormParent_Start:
    IncludeBinary "FormParent.xml"
    FormParent_End:
  EndDataSection
EndProcedure
Procedure FD_CloseSelectParent()
  CloseWindow(#WINDOW_Form_Parent)
  FreeDialog(#WINDOW_Form_Parent)
  DisableWindow(#WINDOW_Main,0)
EndProcedure
Procedure FD_EventSelectParent(EventID)
  Select EventID
    Case #PB_Event_CloseWindow
      FD_CloseSelectParent()
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #GADGET_Form_Parent_Select
          FD_UpdateSelectParent()
          
        Case #GADGET_Form_Parent_OK
          parent_sel = GetGadgetState(#GADGET_Form_Parent_Select)
          
          If parent_sel > -1
            parent_sel = GetGadgetItemData(#GADGET_Form_Parent_Select,parent_sel)
            parent_sel_item = GetGadgetState(#GADGET_Form_Parent_SelectItem)
            
            ChangeCurrentElement(FormWindows()\FormGadgets(), form_select_parent_gadget)
            
            FormWindows()\FormGadgets()\parent = parent_sel
            FormWindows()\FormGadgets()\parent_item = parent_sel_item
            
            gadget_width = FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1
            gadget_height = FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1
            
            ; reset position to origin, as we work in relative position
            FormWindows()\FormGadgets()\x1 = 0
            FormWindows()\FormGadgets()\y1 = 0
            FormWindows()\FormGadgets()\x2 = gadget_width
            FormWindows()\FormGadgets()\y2 = gadget_height
            
            FD_FindParent(parent_sel)
            new_pos = FormWindows()\FormGadgets()
            ChangeCurrentElement(FormWindows()\FormGadgets(), form_select_parent_gadget)
            MoveElement(FormWindows()\FormGadgets(), #PB_List_After, new_pos)
            
            
            ; if the gadget is a splitter, we need to change the gadgets' parents as well.
            If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
              s_g1 = FormWindows()\FormGadgets()\gadget1
              s_g2 = FormWindows()\FormGadgets()\gadget2
              
              PushListPosition(FormWindows()\FormGadgets())
              ForEach FormWindows()\FormGadgets()
                If FormWindows()\FormGadgets()\itemnumber = s_g1
                  s_g1_pointer = @FormWindows()\FormGadgets()
                EndIf
                If FormWindows()\FormGadgets()\itemnumber = s_g2
                  s_g2_pointer = @FormWindows()\FormGadgets()
                EndIf
              Next
              PopListPosition(FormWindows()\FormGadgets())
              
              *listpos = @FormWindows()\FormGadgets()
              splitterparent = FormWindows()\FormGadgets()\parent
              splitterparentitem = FormWindows()\FormGadgets()\parent_item
              PushListPosition(FormWindows()\FormGadgets())
              
              ChangeCurrentElement(FormWindows()\FormGadgets(),s_g1_pointer)
              FormWindows()\FormGadgets()\parent = parent_sel
              FormWindows()\FormGadgets()\parent_item = parent_sel_item
              MoveElement(FormWindows()\FormGadgets(), #PB_List_Before, *listpos)
              
              ChangeCurrentElement(FormWindows()\FormGadgets(),s_g2_pointer)
              FormWindows()\FormGadgets()\parent = parent_sel
              FormWindows()\FormGadgets()\parent_item = parent_sel_item
              MoveElement(FormWindows()\FormGadgets(), #PB_List_Before, *listpos)
              
              PopListPosition(FormWindows()\FormGadgets())
              
              FD_UpdateSplitter()
            EndIf
            
            
            redraw = 1
            FD_UpdateObjList()
            FD_SelectGadget(FormWindows()\FormGadgets())
          EndIf
          
          FD_CloseSelectParent()
          
        Case #GADGET_Form_Parent_Cancel
          FD_CloseSelectParent()
          
      EndSelect
  EndSelect
  
EndProcedure



Procedure FD_ProcessEventGridGadget(col,row)
  FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
  Select row
    Case 1 ; PB Any
      FormWindows()\FormGadgets()\pbany = grid_GetCellState(propgrid, 2, row)
      
    Case 2 ; Variable
      If grid_GetCellString(propgrid, 2, row) = ""
        grid_SetCellString(propgrid, 2, row, FormWindows()\FormGadgets()\variable)
      Else
        FormWindows()\FormGadgets()\variable = grid_GetCellString(propgrid, 2, row)
      EndIf
      
      FD_UpdateObjList()
      
    Case 3 ; Caption is a variable
      If FD_CheckVariable(grid_GetCellString(propgrid, 2, 4))
        FormWindows()\FormGadgets()\captionvariable = grid_GetCellState(propgrid, 2, row)
      Else
        grid_SetCellState(propgrid, 2, row, 0)
        redraw = 1
      EndIf
      
    Case 4 ; Caption
      If FormWindows()\FormGadgets()\captionvariable
        If FD_CheckVariable(grid_GetCellString(propgrid, 2, 4))
          FormWindows()\FormGadgets()\caption = grid_GetCellString(propgrid, 2, row)
        Else
          grid_SetCellString(propgrid, 2, row, FormWindows()\FormGadgets()\caption)
        EndIf
      Else
        FormWindows()\FormGadgets()\caption = grid_GetCellString(propgrid, 2, row)
      EndIf
      redraw = 1
      
    Case 5 ; Tooltip is a variable
      If FD_CheckVariable(grid_GetCellString(propgrid, 2, 6))
        FormWindows()\FormGadgets()\tooltipvariable = grid_GetCellState(propgrid, 2, row)
      Else
        grid_SetCellState(propgrid, 2, row, 0)
      EndIf
      
      redraw = 1
      
    Case 6 ; Tooltip
      If FormWindows()\FormGadgets()\captionvariable
        If FD_CheckVariable(grid_GetCellString(propgrid, 2, 6))
          FormWindows()\FormGadgets()\tooltip = grid_GetCellString(propgrid, 2, row)
        Else
          grid_SetCellString(propgrid, 2, row, FormWindows()\FormGadgets()\caption)
        EndIf
      Else
        FormWindows()\FormGadgets()\tooltip = grid_GetCellString(propgrid, 2, row)
      EndIf
      
    Case 8 ; x
      FormWindows()\FormGadgets()\x1 = Val(grid_GetCellString(propgrid, 2, row))
      FormWindows()\FormGadgets()\x2 = Val(grid_GetCellString(propgrid, 2, 10)) + Val(grid_GetCellString(propgrid, 2,row))
      FD_UpdateSplitter()
      
    Case 9 ; y
      FormWindows()\FormGadgets()\y1 = Val(grid_GetCellString(propgrid, 2, row))
      FormWindows()\FormGadgets()\y2 = Val(grid_GetCellString(propgrid, 2, 11)) + Val(grid_GetCellString(propgrid, 2,row))
      FD_UpdateSplitter()
      
    Case 10 ; width
      new_x2 = Val(grid_GetCellString(propgrid, 2,row)) + Val(grid_GetCellString(propgrid, 2, 8))
      
      If new_x2 > FormWindows()\FormGadgets()\x1
        FormWindows()\FormGadgets()\x2 = new_x2
        FD_UpdateSplitter()
      Else
        FD_SelectGadget(FormWindows()\FormGadgets())
      EndIf
      
    Case 11 ; height
      new_y2 = Val(grid_GetCellString(propgrid, 2,row)) + Val(grid_GetCellString(propgrid, 2, 9))
      If new_y2 > FormWindows()\FormGadgets()\y1
        FormWindows()\FormGadgets()\y2 = new_y2
        FD_UpdateSplitter()
      Else
        FD_SelectGadget(FormWindows()\FormGadgets())
      EndIf
      
    Case 12 ; Hidden
      FormWindows()\FormGadgets()\hidden = grid_GetCellState(propgrid, 2,row)
    Case 13 ; Disabled
      FormWindows()\FormGadgets()\disabled = grid_GetCellState(propgrid, 2,row)
    Case 15 ;
      FormWindows()\FormGadgets()\lock_left = grid_GetCellState(propgrid, 2,row)
    Case 16 ;
      FormWindows()\FormGadgets()\lock_right = grid_GetCellState(propgrid, 2,row)
    Case 17 ;
      FormWindows()\FormGadgets()\lock_top = grid_GetCellState(propgrid, 2,row)
    Case 18 ;
      FormWindows()\FormGadgets()\lock_bottom = grid_GetCellState(propgrid, 2,row)
    Default
      i = 20
      
      Select FormWindows()\FormGadgets()\type
        Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
          i + 2
      EndSelect
      Select FormWindows()\FormGadgets()\type
        Case #Form_Type_Custom
          If row = 18 ; selector
            value.s = grid_GetCellString(propgrid, 2, 20)
            ;             ForEach prefs_cust()
            ;               If prefs_cust()\a = value
            ;                 Break
            ;               EndIf
            ;             Next
            ;             grid_SetCellString(propgrid, 2,16,prefs_cust()\b)
            ;             grid_SetCellString(propgrid, 2,17,prefs_cust()\c)
            ;             FormWindows()\FormGadgets()\cust_init = prefs_cust()\b
            ;             FormWindows()\FormGadgets()\cust_create = prefs_cust()\c
          Else
            FormWindows()\FormGadgets()\cust_init = grid_GetCellString(propgrid, 2,21)
            FormWindows()\FormGadgets()\cust_create = grid_GetCellString(propgrid, 2,22)
          EndIf
        Case #Form_Type_Splitter
          If row = 20
            splitter_value = Val(grid_GetCellString(propgrid, 2, row))
            
            ; check if the splitter position is actually inside the splitter gadget to avoid possible crash.
            If FormWindows()\FormGadgets()\flags & FlagValue("#PB_Splitter_Vertical")
              If splitter_value > 0 And splitter_value < (FormWindows()\FormGadgets()\x2 - FormWindows()\FormGadgets()\x1)
                FormWindows()\FormGadgets()\state = splitter_value
              Else
                grid_SetCellString(propgrid, 1, row, Str(FormWindows()\FormGadgets()\state))
              EndIf
            Else
              If splitter_value > 0 And splitter_value < (FormWindows()\FormGadgets()\y2 - FormWindows()\FormGadgets()\y1)
                FormWindows()\FormGadgets()\state = splitter_value
              Else
                grid_SetCellString(propgrid, 1, row, Str(FormWindows()\FormGadgets()\state))
              EndIf
            EndIf
            
            FD_UpdateSplitter()
          EndIf
          i + 1
          
        Case #Form_Type_Spin, #Form_Type_ProgressBar, #Form_Type_ScrollArea
          FormWindows()\FormGadgets()\min = Val(grid_GetCellString(propgrid, 2, 22))
          FormWindows()\FormGadgets()\max = Val(grid_GetCellString(propgrid, 2, 23))
          i + 2
          
        Case #Form_Type_Trackbar, #Form_Type_Scrollbar
          FormWindows()\FormGadgets()\min = Val(grid_GetCellString(propgrid, 2, 20))
          FormWindows()\FormGadgets()\max = Val(grid_GetCellString(propgrid, 2, 21))
          i + 2
          
        Case #Form_Type_Img, #Form_Type_ButtonImg
          i + 2
        Case #Form_Type_Option, #Form_Type_Checkbox
          FormWindows()\FormGadgets()\state = grid_GetCellState(propgrid, 2, 20)
          i + 1
      EndSelect
      
      ; Event cells: pick procedure
      If row = i
        ; as the event can fire if the user input the procname instead of selecting it,
        ; I need to add a check if procedure exists in the file
        ; if it does not => add the procedure
        ;If FormWindows()\event_file = ""
        ;  grid_SetCellString(propgrid, 2,row,"")
        ;  MessageRequester(#ProductName$, Language("Form","SelectEventFileFirst"))
        ;Else
        FormWindows()\FormGadgets()\event_proc = grid_GetCellString(propgrid, 2, i)
        ;EndIf
      EndIf
      i + 1
      
      flag = 0
      i + 1 ; space for constant's node
      ForEach Gadgets()
        If Gadgets()\type = FormWindows()\FormGadgets()\type
          ForEach Gadgets()\Flags()
            state = grid_GetCellState(propgrid, 2, i)
            If state
              If flag = 0
                flag = Gadgets()\Flags()\ivalue
              Else
                flag | Gadgets()\Flags()\ivalue
              EndIf
            EndIf
            i+1
          Next
        EndIf
      Next
      FormWindows()\FormGadgets()\flags = flag
      
      If row >= 16 And FormWindows()\FormGadgets()\type = #Form_Type_Splitter
        FD_UpdateSplitter()
      EndIf
  EndSelect
  FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
  redraw = 1
EndProcedure
Procedure FD_ProcessEventGridWindow(col,row)
  FormAddUndoAction(1,FormWindows())
  Select row
    Case 1 ; PB Any
      FormWindows()\pbany = grid_GetCellState(propgrid, 2,row)
      
    Case 2 ; Variable
      If grid_GetCellString(propgrid, 2, row) = ""
        grid_SetCellString(propgrid, 2, row, FormWindows()\variable)
      Else
        FormWindows()\variable = grid_GetCellString(propgrid, 2, row)
      EndIf
      
      FD_UpdateObjList()
      
    Case 3 ; Caption is a variable
      If FD_CheckVariable(grid_GetCellString(propgrid, 2, 4))
        FormWindows()\captionvariable = grid_GetCellState(propgrid, 2, row)
      Else
        grid_SetCellState(propgrid, 2, row, 0)
      EndIf
      
      redraw = 1
      
    Case 4 ; Caption
      If FormWindows()\captionvariable
        If FD_CheckVariable(grid_GetCellString(propgrid, 2, 4))
          FormWindows()\caption = grid_GetCellString(propgrid, 2, row)
        Else
          grid_SetCellString(propgrid, 2,row,FormWindows()\caption)
        EndIf
      Else
        FormWindows()\caption = grid_GetCellString(propgrid, 2, row)
      EndIf
      redraw = 1
      
    Case 6 ; x
      winx.s = grid_GetCellString(propgrid, 2, row)
      
      If winx = "#PB_Ignore"
        FormWindows()\x = -65535
      Else
        FormWindows()\x = Val(winx)
      EndIf
      
    Case 7 ; y
      winy.s = grid_GetCellString(propgrid, 2, row)
      
      If winy = "#PB_Ignore"
        FormWindows()\y = -65535
      Else
        FormWindows()\y = Val(winy)
      EndIf
      
    Case 8 ; width
      FormWindows()\width = Val(grid_GetCellString(propgrid, 2, row))
      redraw = 1
      FD_UpdateScrollbars()
      
    Case 9 ; height
      FormWindows()\height = Val(grid_GetCellString(propgrid, 2, row))
      redraw = 1
      FD_UpdateScrollbars()
      
    Case 10 ; Hidden
      FormWindows()\hidden = grid_GetCellState(propgrid, 2, row)
      
    Case 11 ; Disabled
      FormWindows()\disabled = grid_GetCellState(propgrid, 2, row)
      
    Case 12 ; Parent window
      FormWindows()\parent = grid_GetCellString(propgrid, 2, row)
      
    Case 14 ; generate event procedure
      FormWindows()\generateeventloop = grid_GetCellState(propgrid, 2, row)
      
    Case 15
      ; Event cells: pick procedure
      ; as the event can fire if the user input the procname instead of selecting it,
      ; I need to add a check if procedure exists in the file
      ; if it does not => add the procedure
      ;If FormWindows()\event_file = ""
      ;  grid_SetCellString(propgrid, 2,row,"")
      ;  MessageRequester(#ProductName$, Language("Form","SelectEventFileFirst"))
      ;Else
      FormWindows()\event_proc = grid_GetCellString(propgrid, 2, row)
      ;EndIf
      
    Default
      i = 17
      flag = 0
      custFlags.s = ""
      
      ForEach Gadgets()
        If Gadgets()\type = #Form_Type_Window
          ForEach Gadgets()\Flags()
            state = grid_GetCellState(propgrid, 2, i)
            If state
              If flag = 0
                flag = Gadgets()\Flags()\ivalue
              Else
                flag | Gadgets()\Flags()\ivalue
              EndIf
            EndIf
            i+1
          Next
          custFlags = Trim(grid_GetCellString(propgrid, 2, i))
          numflags = CountString(custFlags,"|")
          ClearList(FormWindows()\FormCustomFlags())
          If custFlags
            For k = 0 To numflags
              If numflags = 0
                thisflags.s = custFlags
              Else
                thisflags.s = Trim(StringField(custFlags,k+1,"|"))
              EndIf
              AddElement(FormWindows()\FormCustomFlags())
              FormWindows()\FormCustomFlags() = thisflags
            Next k
          EndIf
        EndIf
      Next
      FormWindows()\flags = flag
      redraw = 1
  EndSelect
  FormAddUndoAction(0,FormWindows())
EndProcedure
Procedure FD_ProcessEventGridMenu(col,row)
  FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
  
  Select row
    Case 0 ; constant
      FormWindows()\FormMenus()\id = grid_GetCellString(propgrid, 2,row)
    Case 1 ; name
      FormWindows()\FormMenus()\item = grid_GetCellString(propgrid, 2,row)
    Case 2 ; shortcut
      FormWindows()\FormMenus()\shortcut = grid_GetCellString(propgrid, 2,row)
    Case 3 ; separator
      FormWindows()\FormMenus()\separator = grid_GetCellState(propgrid, 2,row)
    Case 6 ; event procedure
           ; as the event can fire if the user input the procname instead of selecting it,
           ; I need to add a check if procedure exists in the file
           ; if it does not => add the procedure
           ;If FormWindows()\event_file = ""
           ;  grid_SetCellString(propgrid, 2,row,"")
           ;  MessageRequester(#ProductName$, Language("Form","SelectEventFileFirst"))
           ;Else
      FormWindows()\FormMenus()\event = grid_GetCellString(propgrid, 2,6)
      
      ForEach FormWindows()\FormToolbars()
        If FormWindows()\FormToolbars()\id = FormWindows()\FormMenus()\id
          FormWindows()\FormToolbars()\event = FormWindows()\FormMenus()\event
          Break
        EndIf
      Next
      ;EndIf
  EndSelect
  
  FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
  redraw = 1
EndProcedure
Procedure FD_ProcessEventGridToolbar(col,row)
  FormAddUndoAction(1,FormWindows(),-1,0,0,1)
  Select row
    Case 0 ; variable
      FormWindows()\FormToolbars()\id = grid_GetCellString(propgrid, 2, row)
      
    Case 1 ; caption
      FormWindows()\FormToolbars()\tooltip = grid_GetCellString(propgrid, 2, row)
      
    Case 2 ; image input
      image = AddImage(grid_GetCellString(propgrid, 2, row))
      FormWindows()\FormToolbars()\img = image
      CleanImageList()
      
    Case 4 ; toggle
      FormWindows()\FormToolbars()\toggle = grid_GetCellState(propgrid, 2, row)
      
    Case 5 ; separator
      FormWindows()\FormToolbars()\separator = grid_GetCellState(propgrid, 2, row)
      
    Case 6 ; event procedure
           ; as the event can fire if the user input the procname instead of selecting it,
           ; I need to add a check if procedure exists in the file
           ; if it does not => add the procedure
           ;If FormWindows()\event_file = ""
           ;  grid_SetCellString(propgrid, 2,row,"")
           ;  MessageRequester(#ProductName$, Language("Form","SelectEventFileFirst"))
           ;Else
      FormWindows()\FormToolbars()\event = grid_GetCellString(propgrid, 2, 6)
      
      ForEach FormWindows()\FormMenus()
        If FormWindows()\FormMenus()\id = FormWindows()\FormToolbars()\id
          FormWindows()\FormMenus()\event = FormWindows()\FormToolbars()\event
          Break
        EndIf
      Next
      ;EndIf
  EndSelect
  FormAddUndoAction(0,FormWindows(),-1,0,1,1)
  
  redraw = 1
EndProcedure
Procedure FD_ProcessEventGridStatusbar(col,row)
  FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
  
  Select row
    Case 0 ; width
      widthval.s = grid_GetCellString(propgrid, 2, row)
      If widthval = "#PB_Ignore"
        FormWindows()\FormStatusbars()\width = -1
      Else
        FormWindows()\FormStatusbars()\width = Val(widthval)
      EndIf
      
    Case 1 ; caption
      FormWindows()\FormStatusbars()\text = grid_GetCellString(propgrid, 2, row)
      
    Case 2 ; image input
      image = AddImage(grid_GetCellString(propgrid, 2,row))
      FormWindows()\FormStatusbars()\img = image
      CleanImageList()
      
    Case 4 ; progressbar
      FormWindows()\FormStatusbars()\progressbar = grid_GetCellState(propgrid, 2, row)
      
    Default ; flags
      i = 5
      flag = 0
      ForEach Gadgets()
        If Gadgets()\type = #Form_Type_StatusBar
          ForEach Gadgets()\Flags()
            state = grid_GetCellState(propgrid, 2, i)
            If state
              If flag = 0
                flag = Gadgets()\Flags()\ivalue
              Else
                flag | Gadgets()\Flags()\ivalue
              EndIf
            EndIf
            i+1
          Next
        EndIf
      Next
      FormWindows()\FormStatusbars()\flags = flag
  EndSelect
  
  FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
  redraw = 1
EndProcedure

Procedure FD_ProcessEventGrid(col, row)
  If propgrid_win ;{
    PushListPosition(FormWindows())
    ChangeCurrentElement(FormWindows(),propgrid_win)
    FD_ProcessEventGridWindow(col,row)
    PopListPosition(FormWindows())
  EndIf ;}
  If propgrid_toolbar ;{
    PushListPosition(FormWindows()\FormToolbars())
    ChangeCurrentElement(FormWindows()\FormToolbars(),propgrid_toolbar)
    FD_ProcessEventGridToolbar(col,row)
    PopListPosition(FormWindows()\FormToolbars())
  EndIf ;}
  If propgrid_statusbar ;{
    PushListPosition(FormWindows()\FormStatusbars())
    ChangeCurrentElement(FormWindows()\FormStatusbars(),propgrid_statusbar)
    FD_ProcessEventGridStatusbar(col,row)
    PopListPosition(FormWindows()\FormStatusbars())
  EndIf ;}
  If propgrid_menu ;{
    PushListPosition(FormWindows()\FormMenus())
    ChangeCurrentElement(FormWindows()\FormMenus(),propgrid_menu)
    FD_ProcessEventGridMenu(col,row)
    PopListPosition(FormWindows()\FormMenus())
  EndIf ;}
  If propgrid_gadget ;{
    PushListPosition(FormWindows()\FormGadgets())
    ChangeCurrentElement(FormWindows()\FormGadgets(),propgrid_gadget)
    FD_ProcessEventGridGadget(col,row)
    PopListPosition(FormWindows()\FormGadgets())
  EndIf ;}
EndProcedure

Procedure FD_SetDesignView()
  ; load changes made to the code
  FD_UpdateCode()
  FD_UpdateObjList()
  
  HideGadget(#GADGET_Form, 0)
  HideEditorGadget(*ActiveSource\EditorGadget, 1)
  
  ChangeCurrentElement(FormWindows(),currentwindow)
  FD_SelectWindow(currentwindow)
  redraw = 1
  
  FormWindows()\current_view = 0
  
  ForEach FormWindows()\FormGadgets()
    FormWindows()\FormGadgets()\selected = 0
  Next
EndProcedure


Procedure FD_ProcessMenuEvent(menu_event)
  Select menu_event
    Case #MENU_FormSwitch ; switch to code or window
      If *ActiveSource And *ActiveSource\IsForm
        If FormWindows()\current_view = 0 ; switch to code view
          
          HideGadget(#GADGET_Form, 1)
          HideEditorGadget(*ActiveSource\EditorGadget, 0)
          
          FD_PrepareTestCode(0)
          FD_SelectNone()
          
          SetActiveGadget(*ActiveSource\EditorGadget)
          
          FormWindows()\current_view = 1
          
          CompilerIf #CompileWindows | #CompileMac | #CompileLinuxQt
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return, #MENU_Scintilla_Enter)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab, #MENU_Scintilla_Tab)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab, #MENU_Scintilla_ShiftTab)
          CompilerEndIf
          
        Else ; switch to design view
          FD_SetDesignView()
          
          RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return)
          RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab)
          RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab)
          
        EndIf
        
        ResizeMainWindow() ; Resize the scintilla/form gadget if needed
      EndIf
      
    Case #Menu_Menu_DeleteItem
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
      oldlevel = FormWindows()\FormMenus()\level
      ChangeCurrentElement(FormWindows()\FormMenus(),menu_el)
      DeleteElement(FormWindows()\FormMenus())
      
      If NextElement(FormWindows()\FormMenus())
        Repeat
          If FormWindows()\FormMenus()\level > oldlevel
            DeleteElement(FormWindows()\FormMenus())
            
            If Not NextElement(FormWindows()\FormMenus())
              Break
            EndIf
          EndIf
        Until FormWindows()\FormMenus()\level <= oldlevel
      EndIf
      
      FD_SelectWindow(FormWindows())
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
      CleanImageList()
      FormChanges(1)
      redraw = 1
      
    Case #Menu_Menu_Delete
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
      ClearList(FormWindows()\FormMenus())
      FormWindows()\menu_visible = 0
      FD_SelectWindow(FormWindows())
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
      CleanImageList()
      FormChanges(1)
      redraw = 1
      
      
    Case #Menu_StatusImage
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
      LastElement(FormWindows()\FormStatusbars())
      AddElement(FormWindows()\FormStatusbars())
      FormWindows()\FormStatusbars()\width = 50
      FD_SelectStatusBar(FormWindows()\FormStatusbars())
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
      FormChanges(1)
      redraw = 1
      
    Case #Menu_StatusLabel
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
      LastElement(FormWindows()\FormStatusbars())
      AddElement(FormWindows()\FormStatusbars())
      FormWindows()\FormStatusbars()\width = 50
      FormWindows()\FormStatusbars()\text = "Label"
      FD_SelectStatusBar(FormWindows()\FormStatusbars())
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
      FormChanges(1)
      redraw = 1
      
    Case #Menu_StatusProgressBar
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
      LastElement(FormWindows()\FormStatusbars())
      AddElement(FormWindows()\FormStatusbars())
      FormWindows()\FormStatusbars()\width = 50
      FormWindows()\FormStatusbars()\progressbar = 1
      FD_SelectStatusBar(FormWindows()\FormStatusbars())
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
      FormChanges(1)
      redraw = 1
      
    Case #Menu_StatusDeleteItem
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
      ChangeCurrentElement(FormWindows()\FormStatusbars(),menu_el)
      DeleteElement(FormWindows()\FormStatusbars())
      FD_SelectWindow(FormWindows())
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
      CleanImageList()
      FormChanges(1)
      redraw = 1
      
    Case #Menu_StatusDelete
      FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
      ClearList(FormWindows()\FormStatusbars())
      FormWindows()\status_visible = 0
      FD_SelectWindow(FormWindows())
      FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
      CleanImageList()
      FormChanges(1)
      redraw = 1
      
    Case #Menu_ToolbarButton
      FormAddUndoAction(1,FormWindows(),-1,0,0,1)
      LastElement(FormWindows()\FormToolbars())
      AddElement(FormWindows()\FormToolbars())
      FormWindows()\FormToolbars()\id = "#Toolbar_"+Str(ListIndex(FormWindows()\FormToolbars()))
      FD_SelectToolbar(FormWindows()\FormToolbars())
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      FormAddUndoAction(0,FormWindows(),-1,0,1,1)
      FormChanges(1)
      redraw = 1
      
    Case #Menu_ToolbarToggleButton
      FormAddUndoAction(1,FormWindows(),-1,0,0,1)
      LastElement(FormWindows()\FormToolbars())
      AddElement(FormWindows()\FormToolbars())
      FormWindows()\FormToolbars()\id = "#Toolbar_"+Str(ListIndex(FormWindows()\FormToolbars()))
      FormWindows()\FormToolbars()\toggle = 1
      FD_SelectToolbar(FormWindows()\FormToolbars())
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      FormAddUndoAction(0,FormWindows(),-1,0,1,1)
      FormChanges(1)
      redraw = 1
      
    Case #Menu_ToolbarSeparator
      FormAddUndoAction(1,FormWindows(),-1,0,0,1)
      LastElement(FormWindows()\FormToolbars())
      AddElement(FormWindows()\FormToolbars())
      FormWindows()\FormToolbars()\separator = 1
      FD_SelectToolbar(FormWindows()\FormToolbars())
      ForEach FormWindows()\FormGadgets()
        FormWindows()\FormGadgets()\selected = 0
      Next
      FormAddUndoAction(0,FormWindows(),-1,0,1,1)
      FormChanges(1)
      redraw = 1
      
    Case #Menu_ToolbarDeleteItem
      FormAddUndoAction(1,FormWindows(),-1,0,0,1)
      ChangeCurrentElement(FormWindows()\FormToolbars(),menu_el)
      DeleteElement(FormWindows()\FormToolbars())
      FD_SelectWindow(FormWindows())
      FormAddUndoAction(0,FormWindows(),-1,0,1,1)
      CleanImageList()
      FormChanges(1)
      redraw = 1
      
    Case #Menu_ToolbarDelete
      FormAddUndoAction(1,FormWindows(),-1,0,0,1)
      ClearList(FormWindows()\FormToolbars())
      FormWindows()\toolbar_visible = 0
      FD_SelectWindow(FormWindows())
      FormAddUndoAction(0,FormWindows(),-1,0,1,1)
      CleanImageList()
      FormChanges(1)
      redraw = 1
      
    Case #Menu_RemoveEventFile
      If propgrid_win
        PushListPosition(FormWindows())
        ChangeCurrentElement(FormWindows(),propgrid_win)
        FormWindows()\event_file = ""
        display.s = ""
        
        oldbuffer = grid_GetCellData(propgrid, 2, 14)
        If oldbuffer
          FreeMemory(oldbuffer)
        EndIf
        
        buffer = AllocateMemory((Len(display)+1)* SizeOf(Character))
        PokeS(buffer,display)
        grid_SetCellData(propgrid, 2, 14, buffer)
        grid_Redraw(propgrid)
        
        FormAddUndoAction(1,FormWindows())
        
        PopListPosition(FormWindows())
      EndIf
      
    Case #Menu_RemoveFont
      PushListPosition(FormWindows()\FormGadgets())
      ChangeCurrentElement(FormWindows()\FormGadgets(),propgrid_gadget)
      FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
      grid_SetCellData(propgrid, 2, 14, 0)
      grid_Redraw(propgrid)
      FormWindows()\FormGadgets()\gadgetfont = ""
      FormWindows()\FormGadgets()\gadgetfontflags = 0
      FormWindows()\FormGadgets()\gadgetfontsize = 0
      FormChanges(1)
      FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
      PopListPosition(FormWindows()\FormGadgets())
      
    Case #Menu_RemoveColor
      If propgrid_win
        PushListPosition(FormWindows())
        ChangeCurrentElement(FormWindows(),propgrid_win)
        FormWindows()\color = -1
        grid_SetCellData(propgrid, 2, menu_color_row, -1)
        grid_Redraw(propgrid)
        redraw = 1
        FormChanges(1)
        FormAddUndoAction(1,FormWindows())
        
        PopListPosition(FormWindows())
        
      ElseIf propgrid_gadget
        PushListPosition(FormWindows()\FormGadgets())
        ChangeCurrentElement(FormWindows()\FormGadgets(),propgrid_gadget)
        FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
        
        Select FormWindows()\FormGadgets()\type
          Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
            grid_SetCellData(propgrid, 2, menu_color_row, -1)
            If menu_color_row = 20
              FormWindows()\FormGadgets()\frontcolor = -1
            ElseIf menu_color_row = 21
              FormWindows()\FormGadgets()\backcolor = -1
            EndIf
            grid_Redraw(propgrid)
            redraw = 1
            FormChanges(1)
        EndSelect
        
        FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
        PopListPosition(FormWindows()\FormGadgets())
      EndIf
      
    Case #Menu_AlignLeft
      FD_AlignLeft()
    Case #Menu_AlignTop
      FD_AlignTop()
    Case #Menu_AlignWidth
      FD_AlignWidth()
    Case #Menu_AlignHeight
      FD_AlignHeight()
      
    Case #MENU_Form_EditItems
      items_gadget = 0
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\selected
          Select FormWindows()\FormGadgets()\type
            Case #Form_Type_Panel,#Form_Type_TreeGadget, #Form_Type_ListView, #Form_Type_ListIcon, #Form_Type_Combo,#Form_Type_Editor
              items_gadget = FormWindows()\FormGadgets()
          EndSelect
          Break
        EndIf
      Next
      If items_gadget
        FD_InitItems()
      Else
        MessageRequester(#ProductName$, Language("Form", "NoGadgetSelected"))
      EndIf
      
    Case #Menu_Columns
      column_gadget = 0
      ForEach FormWindows()\FormGadgets()
        If FormWindows()\FormGadgets()\selected
          If FormWindows()\FormGadgets()\type = #Form_Type_ListIcon
            column_gadget = FormWindows()\FormGadgets()
          EndIf
          Break
        EndIf
      Next
      If column_gadget
        FD_InitColumns()
      Else
        MessageRequester(#ProductName$, Language("Form", "NoGadgetSelected"))
      EndIf
      
      
    Case #Menu_Duplicate
      If FormWindows()\current_view = 0
        FD_DuplicateGadget()
      EndIf
      
    Case #Menu_DeleteFormObj
      ChangeCurrentElement(ObjList(),menu_el)
      PushListPosition(FormWindows())
      ChangeCurrentElement(FormWindows(),ObjList()\window)
      ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
      
      If ObjList()\gadget_item > -1
        ; delete gadget in the item gadgetlist
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\parent = ObjList()\gadget_number And FormWindows()\FormGadgets()\parent_item = ObjList()\gadget_item
            FD_DeleteGadgetA(FormWindows()\FormGadgets())
          EndIf
        Next
        FD_DeleteGadgetB()
        
        ForEach FormWindows()\FormGadgets()
          If FormWindows()\FormGadgets()\parent = ObjList()\gadget_number And FormWindows()\FormGadgets()\parent_item > ObjList()\gadget_item
            FormWindows()\FormGadgets()\parent_item - 1
          EndIf
        Next
        
        ; delete item
        ChangeCurrentElement(FormWindows(),ObjList()\window)
        ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
        SelectElement(FormWindows()\FormGadgets()\Items(),ObjList()\gadget_item)
        DeleteElement(FormWindows()\FormGadgets()\Items())
      Else
        FD_DeleteGadgetA(FormWindows()\FormGadgets())
        FD_DeleteGadgetB()
      EndIf
      FD_SelectWindow(FormWindows())
      
      PopListPosition(FormWindows())
      FD_UpdateObjList()
      FormChanges(1)
      redraw = 1
      
    Case #Menu_Rename
      If menu_el
        ChangeCurrentElement(ObjList(),menu_el)
        
        input.s = InputRequester("",Language("Form", "NewTabName"),ObjList()\name)
        If input <> ""
          PushListPosition(FormWindows())
          ChangeCurrentElement(FormWindows(),ObjList()\window)
          ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
          
          FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
          SelectElement(FormWindows()\FormGadgets()\Items(),ObjList()\gadget_item)
          FormWindows()\FormGadgets()\Items()\name = input
          FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
          
          PopListPosition(FormWindows())
          FD_UpdateObjList()
          redraw = 1
          FormChanges(1)
        EndIf
        
      EndIf
  EndSelect
EndProcedure

Procedure FD_EventMain(gadget, event_type)
  Select gadget
    Case #GADGET_Form_Canvas ;{
      If currentwindow       ; Ensure there is still a window, or it can crash when closing a form on Linux/x64
        Select event_type
          Case #PB_EventType_MouseWheel
            If IsGadget(#GADGET_Form_ScrollV)
              SetGadgetState(#GADGET_Form_ScrollV,GetGadgetState(#GADGET_Form_ScrollV) - GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_WheelDelta)*10)
              FormWindows()\paddingy = GetGadgetState(#GADGET_Form_ScrollV)
              redraw = 1
            EndIf
          Case #PB_EventType_LeftButtonDown
            x = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseX)
            y = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseY)
            
            ;           If GetGadgetAttribute(#GADGET_Form_Canvas, #PB_Canvas_Modifiers) & #PB_Canvas_Control
            ;             FD_RightClick(x, y)
            ;           Else
            FD_LeftDown(x,y)
            ;           EndIf
            
          Case #PB_EventType_MouseMove
            x = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseX)
            y = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseY)
            If multiselectStart
              FD_MoveMultiSelection(x,y)
            Else
              FD_Move(x, y)
            EndIf
            
          Case #PB_EventType_LeftButtonUp
            x = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseX)
            y = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseY)
            FD_LeftUp(x,y)
            
          Case #PB_EventType_RightClick
            x = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseX)
            y = GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_MouseY)
            FD_RightClick(x, y)
            
          Case #PB_EventType_KeyDown
            FD_KeyDown(GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Key),GetGadgetAttribute(#GADGET_Form_Canvas,#PB_Canvas_Modifiers))
          Case #PB_EventType_KeyUp
        EndSelect
      EndIf
      ;}
  EndSelect
EndProcedure


Procedure Form_Scrollbars()
  Select EventGadget()
    Case #GADGET_Form_ScrollH
      FormWindows()\paddingx = GetGadgetState(#GADGET_Form_ScrollH)
      redraw = 1
    Case #GADGET_Form_ScrollV
      FormWindows()\paddingy = GetGadgetState(#GADGET_Form_ScrollV)
      redraw = 1
  EndSelect
  
  If redraw
    FD_Redraw()
    redraw = 0
  EndIf
  
EndProcedure


Procedure FD_Event(EventID, EventGadgetID, EventType)
  
  ; Do the grid Form panel event here as we need the EventID.
  If propgrid ;{
              ;grid_DoEvent(propgrid,EventID)
    EventGrid = grid_Event(propgrid)
    
    Select EventGrid
      Case #Grid_Event_KeyDown
        If grid_EventType(propgrid) = #PB_Shortcut_Tab
          row = grid_EventRow(propgrid)
          col = grid_EventColumn(propgrid)
          If col = 0
            grid_SetGadgetAttribute(propgrid,#Grid_Attribute_SelectedColumn,1)
          EndIf
        EndIf
      Case #Grid_Event_Cell
        Select grid_EventType(propgrid)
          Case #Grid_Event_Cell_RightButtonUp ;{
            If propgrid_win
              PushListPosition(FormWindows())
              ChangeCurrentElement(FormWindows(),propgrid_win)
              row = grid_EventRow(propgrid)
              
              If row = 13 ; Window color
                menu_color_row = row
                DisplayPopupMenu(#Form_Menu4,WindowID(#WINDOW_Main))
              EndIf
              If row = 15
                DisplayPopupMenu(#Form_Menu7,WindowID(#WINDOW_Main))
              EndIf
              
              PopListPosition(FormWindows())
            ElseIf propgrid_gadget
              PushListPosition(FormWindows()\FormGadgets())
              ChangeCurrentElement(FormWindows()\FormGadgets(),propgrid_gadget)
              row = grid_EventRow(propgrid)
              
              Select row
                Case 19 ; font
                  DisplayPopupMenu(#Form_Menu5,WindowID(#WINDOW_Main))
                Case 20, 21 ; front color, back color
                  Select FormWindows()\FormGadgets()\type
                    Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
                      menu_color_row = row
                      DisplayPopupMenu(#Form_Menu4,WindowID(#WINDOW_Main))
                  EndSelect
              EndSelect
              
              PopListPosition(FormWindows()\FormGadgets())
            EndIf
            ;}
          Case #Grid_Event_Cell_LeftButtonDown
            row = grid_EventRow(propgrid)
            col = grid_EventColumn(propgrid)
            grid_BeginEditing(propgrid, col, row)
            
          Case #Grid_Event_Cell_LeftDblClick ;{
            row = grid_EventRow(propgrid)
            col = grid_EventColumn(propgrid)
            
            If propgrid_gadget
              PushListPosition(FormWindows()\FormGadgets())
              ChangeCurrentElement(FormWindows()\FormGadgets(),propgrid_gadget)
              i = 20
              
              Select FormWindows()\FormGadgets()\type
                Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
                  i + 2
              EndSelect
              Select FormWindows()\FormGadgets()\type
                Case #Form_Type_Custom
                  i + 3
                Case #Form_Type_Spin, #Form_Type_ProgressBar, #Form_Type_ScrollArea
                  i + 2
                Case #Form_Type_Trackbar, #Form_Type_Scrollbar
                  i + 2
                Case #Form_Type_Img, #Form_Type_ButtonImg
                  i + 2
                Case #Form_Type_Option, #Form_Type_Checkbox
                  i + 1
              EndSelect
              
              If row = i
                FD_OpenPBFile(FormWindows()\FormGadgets()\event_proc)
              EndIf
              PopListPosition(FormWindows()\FormGadgets())
            ElseIf propgrid_win
              PushListPosition(FormWindows())
              ChangeCurrentElement(FormWindows(),propgrid_win)
              
              ;               If row = 14
              ;                 FD_OpenPBFile(FormWindows()\event_proc)
              ;               EndIf
              
              PopListPosition(FormWindows())
            EndIf
            ;}
            
            
          Case #Grid_Event_Cell_LeftButtonUp ;{
            row = grid_EventRow(propgrid)
            col = grid_EventColumn(propgrid)
            
            If grid_EventRow(propgrid) >= 0
              PropGridFoldNode(propgrid, row)
            EndIf
            
            If propgrid_gadget ;{
              PushListPosition(FormWindows()\FormGadgets())
              ChangeCurrentElement(FormWindows()\FormGadgets(),propgrid_gadget)
              row = grid_EventRow(propgrid)
              
              Select row
                Case 14 ; parent
                  form_select_parent_gadget = FormWindows()\FormGadgets()
                  FD_InitSelectParent(FormWindows()\FormGadgets()\parent)
                  
                Case 19 ; font
                        ;{ switch internal flags to PB flags
                  fontflags = 0
                  If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Bold")
                    If fontflags = 0
                      fontflags = #PB_Font_Bold
                    Else
                      fontflags | #PB_Font_Bold
                    EndIf
                  EndIf
                  If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Italic")
                    If fontflags = 0
                      fontflags = #PB_Font_Italic
                    Else
                      fontflags | #PB_Font_Italic
                    EndIf
                  EndIf
                  If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Underline")
                    If fontflags = 0
                      fontflags = #PB_Font_Underline
                    Else
                      fontflags | #PB_Font_Underline
                    EndIf
                  EndIf
                  If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_StrikeOut")
                    If fontflags = 0
                      fontflags = #PB_Font_StrikeOut
                    Else
                      fontflags | #PB_Font_StrikeOut
                    EndIf
                  EndIf
                  ;}
                  
                  If FontRequester(FormWindows()\FormGadgets()\gadgetfont,FormWindows()\FormGadgets()\gadgetfontsize, 0,0,fontflags)
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    FormWindows()\FormGadgets()\gadgetfont = SelectedFontName()
                    FormWindows()\FormGadgets()\gadgetfontsize = SelectedFontSize()
                    fontflags = SelectedFontStyle()
                    
                    newfontflags = 0
                    If fontflags & #PB_Font_Bold
                      If newfontflags = 0
                        newfontflags = FlagValue("#PB_Font_Bold")
                      Else
                        newfontflags | FlagValue("#PB_Font_Bold")
                      EndIf
                    EndIf
                    If fontflags & #PB_Font_Italic
                      If newfontflags = 0
                        newfontflags = FlagValue("#PB_Font_Italic")
                      Else
                        newfontflags | FlagValue("#PB_Font_Italic")
                      EndIf
                    EndIf
                    If fontflags & #PB_Font_Underline
                      If newfontflags = 0
                        newfontflags = FlagValue("#PB_Font_Underline")
                      Else
                        newfontflags | FlagValue("#PB_Font_Underline")
                      EndIf
                    EndIf
                    If fontflags & #PB_Font_StrikeOut
                      If newfontflags = 0
                        newfontflags = FlagValue("#PB_Font_StrikeOut")
                      Else
                        newfontflags | FlagValue("#PB_Font_StrikeOut")
                      EndIf
                    EndIf
                    FormWindows()\FormGadgets()\gadgetfontflags = newfontflags
                    
                    display.s = FormWindows()\FormGadgets()\gadgetfont + " " + Str(FormWindows()\FormGadgets()\gadgetfontsize) + " "
                    If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Bold")
                      display + "B"
                    EndIf
                    If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Italic")
                      display + "I"
                    EndIf
                    If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_Underline")
                      display + "U"
                    EndIf
                    If FormWindows()\FormGadgets()\gadgetfontflags & FlagValue("#PB_Font_StrikeOut")
                      display + "S"
                    EndIf
                    
                    oldbuffer = grid_GetCellData(propgrid, 2,row)
                    If oldbuffer
                      FreeMemory(oldbuffer)
                    EndIf
                    
                    buffer = AllocateMemory((Len(display)+1)* SizeOf(Character))
                    PokeS(buffer,display)
                    grid_SetCellData(propgrid, 2, row, buffer)
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    grid_Redraw(propgrid)
                    redraw = 1
                  EndIf
                  
                Case 20 ; front color
                  Select FormWindows()\FormGadgets()\type
                    Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
                      color = ColorRequester()
                      
                      If color > -1
                        FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                        FormWindows()\FormGadgets()\frontcolor = color
                        grid_SetCellData(propgrid, 2, row, color)
                        grid_Redraw(propgrid)
                        redraw = 1
                        FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                        FormChanges(1)
                      EndIf
                  EndSelect
                  
                Case 21 ; back color (or select image)
                  Select FormWindows()\FormGadgets()\type
                    Case #Form_Type_Calendar, #Form_Type_Container, #Form_Type_Editor, #Form_Type_ExplorerList, #Form_Type_ExplorerTree, #Form_Type_HyperLink, #Form_Type_ListIcon, #Form_Type_ListView, #Form_Type_ProgressBar, #Form_Type_ScrollArea, #Form_Type_Spin, #Form_Type_StringGadget, #Form_Type_Text, #Form_Type_TreeGadget
                      color = ColorRequester()
                      
                      If color > -1
                        FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                        FormWindows()\FormGadgets()\backcolor = color
                        grid_SetCellData(propgrid, 2,row,color)
                        grid_Redraw(propgrid)
                        redraw = 1
                        FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                        FormChanges(1)
                      EndIf
                      
                    Case #Form_Type_Img, #Form_Type_ButtonImg
                      file.s = OpenFileRequester(Language("Form", "SelectImage"),"",Language("Form", "MaskAllFiles"),0)
                      
                      If file
                        ImageManager(file)
                        image = AddImage(file)
                        
                        FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                        FormWindows()\FormGadgets()\image = image
                        grid_SetCellString(propgrid, 1, 18, file)
                        
                        If MessageRequester(#ProductName$,Language("Form", "ResizeGadgetImg"),#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                          tempimg = LoadImage(#PB_Any,file)
                          If tempimg
                            FormWindows()\FormGadgets()\x2 = FormWindows()\FormGadgets()\x1 + ImageWidth(tempimg)
                            FormWindows()\FormGadgets()\y2 = FormWindows()\FormGadgets()\y1 + ImageHeight(tempimg)
                            FreeImage(tempimg)
                          EndIf
                        EndIf
                        
                        CleanImageList()
                        FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                        redraw = 1
                        FormChanges(1)
                      EndIf
                  EndSelect
              EndSelect
              
              PopListPosition(FormWindows()\FormGadgets())
              ;}
            ElseIf propgrid_win ;{
              PushListPosition(FormWindows())
              ChangeCurrentElement(FormWindows(),propgrid_win)
              row = grid_EventRow(propgrid)
              
              If row = 13 ; Window color
                color = ColorRequester()
                
                If color > -1
                  FormAddUndoAction(1,FormWindows())
                  FormWindows()\color = color
                  grid_SetCellData(propgrid, 2,row,color)
                  
                  FormAddUndoAction(0,FormWindows())
                  grid_Redraw(propgrid)
                  redraw = 1
                  FormChanges(1)
                EndIf
              EndIf
              
              PopListPosition(FormWindows())
              ;}
            ElseIf propgrid_toolbar ;{
              PushListPosition(FormWindows()\FormToolbars())
              ChangeCurrentElement(FormWindows()\FormToolbars(),propgrid_toolbar)
              row = grid_EventRow(propgrid)
              
              Select row
                Case 3 ; select image
                  file.s = OpenFileRequester(Language("Form", "SelectImage"),"",Language("Form", "MaskAllFiles"),0)
                  If file
                    FormAddUndoAction(1,FormWindows(),-1,0,0,1)
                    img = AddImage(file)
                    FormWindows()\FormToolbars()\img = img
                    CleanImageList()
                    grid_SetCellString(propgrid, 2,row - 1,file)
                    FormAddUndoAction(0,FormWindows(),-1,0,1,1)
                    FormChanges(1)
                    redraw = 1
                  EndIf
              EndSelect
              PopListPosition(FormWindows()\FormToolbars())
              ;}
            ElseIf propgrid_statusbar ;{
              PushListPosition(FormWindows()\FormStatusbars())
              ChangeCurrentElement(FormWindows()\FormStatusbars(),propgrid_statusbar)
              row = grid_EventRow(propgrid)
              
              Select row
                Case 3 ; select image
                  file.s = OpenFileRequester(Language("Form", "SelectImage"),"",Language("Form", "MaskAllFiles"),0)
                  If file
                    FormAddUndoAction(1,FormWindows(),-1,0,0,-1,1)
                    img = AddImage(file)
                    FormWindows()\FormStatusbars()\img = img
                    CleanImageList()
                    grid_SetCellString(propgrid, 2,row - 1,file)
                    FormAddUndoAction(0,FormWindows(),-1,0,1,-1,1)
                    FormChanges(1)
                    redraw = 1
                  EndIf
              EndSelect
              PopListPosition(FormWindows()\FormStatusbars())
              ;}
            ElseIf propgrid_menu ;{
              PushListPosition(FormWindows()\FormMenus())
              ChangeCurrentElement(FormWindows()\FormMenus(),propgrid_menu)
              row = grid_EventRow(propgrid)
              
              Select row
                Case 5 ; select image
                  file.s = OpenFileRequester(Language("Form", "SelectImage"),"",Language("Form", "MaskAllFiles"),0)
                  
                  If file
                    ImageManager(file)
                    image = AddImage(file)
                    
                    FormAddUndoAction(1,FormWindows(),-1,0,0,-1,-1,1)
                    FormWindows()\FormMenus()\icon = image
                    
                    CleanImageList()
                    FormAddUndoAction(0,FormWindows(),-1,0,1,-1,-1,1)
                    redraw = 1
                    FormChanges(1)
                  EndIf
              EndSelect
              ;}
            EndIf
            ;}
            
          Case #Grid_Event_Cell_ContentChange
            FormChanges(1)
            col = grid_EventColumn(propgrid)
            row = grid_EventRow(propgrid)
            FD_ProcessEventGrid(col, row)
            
        EndSelect
    EndSelect
  EndIf ;}
  
  If imglist_grid ;{
                  ;grid_DoEvent(imglist_grid,EventID)
    EventGrid = grid_Event(imglist_grid)
    Select EventGrid
      Case #Grid_Event_Cell
        Select grid_EventType(imglist_grid)
          Case #Grid_Event_Cell_LeftButtonUp
            col = grid_EventColumn(imglist_grid)
            row = grid_EventRow(imglist_grid)
            
            If row >= 0
              Select col
                Case 3 ; select
                  file.s = OpenFileRequester(Language("Form", "SelectImage"),"",Language("Form", "MaskAllFiles"),0)
                  If file
                    SelectElement(FormWindows()\FormImg(),row)
                    grid_SetCellString(imglist_grid,0,row,file)
                    FormWindows()\FormImg()\img = file
                    
                    If *ActiveSource\IsForm And FormWindows()\current_view = 1
                      FormChanges(1)
                      FD_PrepareTestCode(0)
                      FD_SelectNone()
                    EndIf
                    
                  EndIf
                Case 4 ; relative
                  If FormWindows()\current_file
                    SelectElement(FormWindows()\FormImg(),row)
                    path.s = GetPathPart(FormWindows()\current_file)
                    newpath.s = RelativePath(path,FormWindows()\FormImg()\img)
                    FormWindows()\FormImg()\img = newpath
                    grid_SetCellString(imglist_grid,0,row,FormWindows()\FormImg()\img)
                    
                    If *ActiveSource\IsForm And FormWindows()\current_view = 1
                      FormChanges(1)
                      FD_PrepareTestCode(0)
                      FD_SelectNone()
                    EndIf
                    
                  Else
                    MessageRequester(#ProductName$,Language("Form", "SaveRequiredWarning"))
                  EndIf
                  
              EndSelect
            EndIf
            
          Case #Grid_Event_Cell_ContentChange
            col = grid_EventColumn(imglist_grid)
            row = grid_EventRow(imglist_grid)
            
            If row >= 0
              Select col
                Case 0 ; img url
                  SelectElement(FormWindows()\FormImg(),row)
                  FormWindows()\FormImg()\img = grid_GetCellString(imglist_grid,col,row)
                Case 1 ; catchimg
                  SelectElement(FormWindows()\FormImg(),row)
                  FormWindows()\FormImg()\inline = grid_GetCellState(imglist_grid,col,row)
                Case 2 ; pbany
                  SelectElement(FormWindows()\FormImg(),row)
                  FormWindows()\FormImg()\pbany = grid_GetCellState(imglist_grid,col,row)
                  
              EndSelect
              
              If *ActiveSource\IsForm And FormWindows()\current_view = 1
                FormChanges(1)
                FD_PrepareTestCode(0)
                FD_SelectNone()
              EndIf
              
            EndIf
        EndSelect
    EndSelect
  EndIf ;}
  
  If items_grid ;{
                ;grid_DoEvent(items_grid,EventID)
    EventGrid = grid_Event(items_grid)
    Select EventGrid
      Case #Grid_Event_Cell
        Select grid_EventType(items_grid)
          Case #Grid_Event_Cell_LeftButtonUp
            ChangeCurrentElement(FormWindows()\FormGadgets(),items_gadget)
            items_gadget_num = FormWindows()\FormGadgets()\itemnumber
            col = grid_EventColumn(items_grid)
            row = grid_EventRow(items_grid)
            
            If row  < ListSize(FormWindows()\FormGadgets()\Items()) And row >= 0
              Select col
                Case 2 ; move up
                  If row > 0
                    ; delete item
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    SelectElement(FormWindows()\FormGadgets()\Items(),row)
                    item.s = FormWindows()\FormGadgets()\Items()\name
                    DeleteElement(FormWindows()\FormGadgets()\Items())
                    SelectElement(FormWindows()\FormGadgets()\Items(),row-1)
                    InsertElement(FormWindows()\FormGadgets()\Items())
                    FormWindows()\FormGadgets()\Items()\name = item
                    ; update gadget list
                    ForEach FormWindows()\FormGadgets()
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = row
                        FormWindows()\FormGadgets()\parent_item = -2
                      EndIf
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = row - 1
                        FormWindows()\FormGadgets()\parent_item = row
                      EndIf
                    Next
                    ForEach FormWindows()\FormGadgets()
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = -2
                        FormWindows()\FormGadgets()\parent_item = row - 1
                      EndIf
                    Next
                    FD_UpdateItems()
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    FormChanges(1)
                  EndIf
                  
                Case 3 ; move down
                  If row < ListSize(FormWindows()\FormGadgets()\Items())-1
                    ; delete item
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    SelectElement(FormWindows()\FormGadgets()\Items(),row)
                    item.s = FormWindows()\FormGadgets()\Items()\name
                    DeleteElement(FormWindows()\FormGadgets()\Items())
                    SelectElement(FormWindows()\FormGadgets()\Items(),row)
                    AddElement(FormWindows()\FormGadgets()\Items())
                    FormWindows()\FormGadgets()\Items()\name = item
                    ; update gadget list
                    ForEach FormWindows()\FormGadgets()
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = row
                        FormWindows()\FormGadgets()\parent_item = -2
                      EndIf
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = row + 1
                        FormWindows()\FormGadgets()\parent_item = row
                      EndIf
                    Next
                    ForEach FormWindows()\FormGadgets()
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = -2
                        FormWindows()\FormGadgets()\parent_item = row + 1
                      EndIf
                    Next
                    FD_UpdateItems()
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    FormChanges(1)
                  EndIf
                  
                Case 4 ; delete
                  If MessageRequester(#ProductName$,Language("Form", "DeleteItemConfirm"),#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                    ; delete gadget in the item gadgetlist
                    ForEach FormWindows()\FormGadgets()
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item = row
                        FD_DeleteGadgetA(FormWindows()\FormGadgets())
                      EndIf
                    Next
                    FD_DeleteGadgetB()
                    ForEach FormWindows()\FormGadgets()
                      If FormWindows()\FormGadgets()\parent = items_gadget_num And FormWindows()\FormGadgets()\parent_item > row
                        FormWindows()\FormGadgets()\parent_item - 1
                      EndIf
                    Next
                    FD_SelectWindow(FormWindows())
                    
                    ; delete item
                    ChangeCurrentElement(FormWindows()\FormGadgets(),items_gadget)
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    SelectElement(FormWindows()\FormGadgets()\Items(),row)
                    DeleteElement(FormWindows()\FormGadgets()\Items())
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    
                    FD_UpdateItems()
                    FormChanges(1)
                  EndIf
                  
              EndSelect
            EndIf
            
          Case #Grid_Event_Cell_ContentChange
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),items_gadget)
            
            row = grid_EventRow(items_grid)
            
            If row >= 0
              If row < ListSize(FormWindows()\FormGadgets()\Items())
                FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                SelectElement(FormWindows()\FormGadgets()\Items(),row)
                FormWindows()\FormGadgets()\Items()\name = grid_GetCellString(items_grid,0,row)
                FormWindows()\FormGadgets()\Items()\level = Val(grid_GetCellString(items_grid,1,row))
                FormChanges(1)
                FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
              Else ; new item
                FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                LastElement(FormWindows()\FormGadgets()\Items())
                AddElement(FormWindows()\FormGadgets()\Items())
                FormWindows()\FormGadgets()\Items()\name = grid_GetCellString(items_grid,0,row)
                FD_UpdateItems()
                grid_SetGadgetAttribute(items_grid, #Grid_Attribute_SelectedRow, ListSize(FormWindows()\FormGadgets()\Items())) ; change the position of the selected cell
                FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                FormChanges(1)
              EndIf
            EndIf
            
            PopListPosition(FormWindows()\FormGadgets())
        EndSelect
    EndSelect
  EndIf ;}
  
  If column_grid ;{
                 ;grid_DoEvent(column_grid, EventID)
    EventGrid = grid_Event(column_grid)
    Select EventGrid
      Case #Grid_Event_Cell
        Select grid_EventType(column_grid)
          Case #Grid_Event_Cell_LeftButtonUp
            ChangeCurrentElement(FormWindows()\FormGadgets(),column_gadget)
            col = grid_EventColumn(column_grid)
            row = grid_EventRow(column_grid)
            
            If row  < ListSize(FormWindows()\FormGadgets()\Columns()) And row >= 0
              Select col
                Case 2 ; move up
                  If row > 0
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    FD_UpdateColumns()
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    FormChanges(1)
                  EndIf
                  
                Case 3 ; move down
                  If row < ListSize(FormWindows()\FormGadgets()\Items())-1
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    FD_UpdateColumns()
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    FormChanges(1)
                  EndIf
                  
                Case 4 ; delete
                  If MessageRequester(#ProductName$,Language("Form", "DeleteItemConfirm"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                    ; delete item
                    ChangeCurrentElement(FormWindows()\FormGadgets(),column_gadget)
                    FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                    SelectElement(FormWindows()\FormGadgets()\Columns(),row)
                    DeleteElement(FormWindows()\FormGadgets()\Columns())
                    FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                    
                    FD_UpdateColumns()
                    FormChanges(1)
                  EndIf
              EndSelect
            EndIf
            
          Case #Grid_Event_Cell_ContentChange
            PushListPosition(FormWindows()\FormGadgets())
            ChangeCurrentElement(FormWindows()\FormGadgets(),column_gadget)
            
            col = grid_EventColumn(column_grid)
            row = grid_EventRow(column_grid)
            
            If row >= 0
              If row < ListSize(FormWindows()\FormGadgets()\Columns())
                FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                SelectElement(FormWindows()\FormGadgets()\Columns(),row)
                FormWindows()\FormGadgets()\Columns()\name = grid_GetCellString(column_grid,0,row)
                FormWindows()\FormGadgets()\Columns()\width = Val(grid_GetCellString(column_grid,1,row))
                FormChanges(1)
                FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
              Else ; new item
                FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets())
                LastElement(FormWindows()\FormGadgets()\Columns())
                AddElement(FormWindows()\FormGadgets()\Columns())
                FormWindows()\FormGadgets()\Columns()\name = grid_GetCellString(column_grid,0,row)
                FormWindows()\FormGadgets()\Columns()\width = 100
                FD_UpdateColumns()
                FormAddUndoAction(0,FormWindows(),FormWindows()\FormGadgets())
                FormChanges(1)
              EndIf
            EndIf
            
            PopListPosition(FormWindows()\FormGadgets())
        EndSelect
    EndSelect
  EndIf ;}
  
  
  Select EventID
      
    Case #PB_Event_GadgetDrop ;{
      If EventGadget() = #GADGET_Form_Canvas And EventDropType() = #PB_Drop_Private And EventDropPrivate() = 50
        If drag_type > 0
          var.s = ""
          
          Select drag_type ;{
            Case #Form_Type_Button
              var = "Button_"+Str(FormWindows()\c_button)
              FormWindows()\c_button + 1
            Case #Form_Type_ButtonImg
              var = "ButtonImage_"+Str(FormWindows()\c_buttonimg)
              FormWindows()\c_buttonimg + 1
            Case #Form_Type_StringGadget
              var = "String_"+Str(FormWindows()\c_string)
              FormWindows()\c_string + 1
            Case #Form_Type_Checkbox
              var = "Checkbox_"+Str(FormWindows()\c_checkbox)
              FormWindows()\c_checkbox + 1
            Case #Form_Type_Text
              var = "Text_"+Str(FormWindows()\c_text)
              FormWindows()\c_text + 1
            Case #Form_Type_OpenGL
              var = "OpenGL_"+Str(FormWindows()\c_opengl)
              FormWindows()\c_opengl + 1
            Case #Form_Type_Option
              var = "Option_"+Str(FormWindows()\c_option)
              FormWindows()\c_option + 1
            Case #Form_Type_TreeGadget
              var = "Tree_"+Str(FormWindows()\c_tree)
              FormWindows()\c_tree + 1
            Case #Form_Type_ListView
              var = "ListView_"+Str(FormWindows()\c_listview)
              clistview + 1
            Case #Form_Type_ListIcon
              var = "ListIcon_"+Str(FormWindows()\c_listicon)
              FormWindows()\c_listicon + 1
            Case #Form_Type_Combo
              var = "Combo_"+Str(FormWindows()\c_combo)
              FormWindows()\c_combo + 1
            Case #Form_Type_Spin
              var = "Spin_"+Str(FormWindows()\c_spin)
              FormWindows()\c_spin + 1
            Case #Form_Type_Trackbar
              var = "TrackBar_"+Str(FormWindows()\c_trackbar)
              FormWindows()\c_trackbar + 1
            Case #Form_Type_ProgressBar
              var = "ProgressBar_"+Str(FormWindows()\c_progressbar)
              FormWindows()\c_progressbar + 1
            Case #Form_Type_Img
              var = "Image_"+Str(FormWindows()\c_image)
              FormWindows()\c_image + 1
            Case #Form_Type_IP
              var = "IP_"+Str(FormWindows()\c_ip)
              FormWindows()\c_ip + 1
            Case #Form_Type_Scrollbar
              var = "Scrollbar_"+Str(FormWindows()\c_scrollbar)
              FormWindows()\c_scrollbar + 1
            Case #Form_Type_HyperLink
              var = "Hyperlink_"+Str(FormWindows()\c_hyperlink)
              FormWindows()\c_hyperlink + 1
            Case #Form_Type_Editor
              var = "Editor_"+Str(FormWindows()\c_editor)
              FormWindows()\c_editor + 1
            Case #Form_Type_ExplorerTree
              var = "ExplorerTree_"+Str(FormWindows()\c_explorertree)
              FormWindows()\c_explorertree + 1
            Case #Form_Type_ExplorerList
              var = "ExplorerList_"+Str(FormWindows()\c_explorerlist)
              FormWindows()\c_explorerlist + 1
            Case #Form_Type_ExplorerCombo
              var = "ExplorerCombo_"+Str(FormWindows()\c_explorercombo)
              FormWindows()\c_explorercombo + 1
            Case #Form_Type_Date
              var = "Date_"+Str(FormWindows()\c_date)
              FormWindows()\c_date + 1
            Case #Form_Type_Calendar
              var = "Calendar_"+Str(FormWindows()\c_calendar)
              FormWindows()\c_calendar + 1
            Case #Form_Type_Scintilla
              var = "Scintilla_"+Str(FormWindows()\c_scintilla)
              FormWindows()\c_scintilla + 1
            Case #Form_Type_Splitter
              var = "Splitter_"+Str(FormWindows()\c_splitter)
              FormWindows()\c_splitter + 1
            Case #Form_Type_Frame3D
              var = "Frame_"+Str(FormWindows()\c_frame3D)
              FormWindows()\c_frame3D + 1
            Case #Form_Type_ScrollArea
              var = "ScrollArea_"+Str(FormWindows()\c_scrollarea)
              FormWindows()\c_scrollarea + 1
            Case #Form_Type_Web
              var = "WebView_"+Str(FormWindows()\c_web)
              FormWindows()\c_web + 1
            Case #Form_Type_WebView
              var = "WebView_"+Str(FormWindows()\c_web)
              FormWindows()\c_web + 1
            Case #Form_Type_Container
              var = "Container_"+Str(FormWindows()\c_container)
              FormWindows()\c_container + 1
            Case #Form_Type_Panel
              var = "Panel_"+Str(FormWindows()\c_panel)
              FormWindows()\c_panel + 1
            Case #Form_Type_Canvas
              var = "Canvas_"+Str(FormWindows()\c_canvas)
              FormWindows()\c_canvas + 1
          EndSelect ;}
          
          d_x1 = FD_NewWindowMouseX(#WINDOW_Main) - GadgetX(#GADGET_SourceContainer)
          d_y1 = FD_NewWindowMouseY(#WINDOW_Main) - GadgetY(#GADGET_SourceContainer) - MenuHeight() - ToolBarHeight(#TOOLBAR)
          
          d_x1 = FD_AlignPoint(d_x1 + FormWindows()\paddingx - #Page_Padding - leftpadding)
          d_y1 = FD_AlignPoint(d_y1 + FormWindows()\paddingy - #Page_Padding - topwinpadding - toptoolpadding - topmenupadding)
          d_x2 = 100 + d_x1
          d_y2 = 25 + d_y1
          
          parent = 0
          If LastElement(FormWindows()\FormGadgets())
            Repeat
              this_parent = FormWindows()\FormGadgets()\parent
              this_parent_item = FormWindows()\FormGadgets()\parent_item
              hidden = 0
              
              x1 = 0 : x2 = 0 : y1 = 0 : y2 = 0
              While this_parent <> 0
                PushListPosition(FormWindows()\FormGadgets())
                FD_FindParent(this_parent)
                
                If FormWindows()\FormGadgets()\current_item <> this_parent_item And this_parent_item <> -1
                  hidden = 1
                EndIf
                
                If FormWindows()\FormGadgets()\hidden
                  hidden = 1
                EndIf
                
                this_parent = FormWindows()\FormGadgets()\parent
                this_parent_item = FormWindows()\FormGadgets()\parent_item
                
                x1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
                x2 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
                y1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
                y2 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
                
                If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                  y1 + Panel_Height
                  y2 + Panel_Height
                EndIf
                
                PopListPosition(FormWindows()\FormGadgets())
              Wend
              
              x1 + FormWindows()\FormGadgets()\x1 - scrollx
              x2 + FormWindows()\FormGadgets()\x2 - scrollx
              y1 + FormWindows()\FormGadgets()\y1 - scrolly
              y2 + FormWindows()\FormGadgets()\y2 - scrolly
              
              If FormWindows()\FormGadgets()\hidden
                hidden = 1
              EndIf
              
              If d_x1 > x1 And d_x1 <= x2 And d_y1 >= y1 And d_y1 <= y2 And Not hidden
                Select FormWindows()\FormGadgets()\type
                  Case #Form_Type_Container, #Form_Type_Panel, #Form_Type_ScrollArea
                    parent = FormWindows()\FormGadgets()\itemnumber
                    Break
                  Case #Form_Type_Frame3D
                    If FormWindows()\FormGadgets()\flags & #PB_Frame_Container
                      parent = FormWindows()\FormGadgets()\itemnumber
                      Break
                    EndIf
                EndSelect
              EndIf
            Until PreviousElement(FormWindows()\FormGadgets()) = 0
          EndIf
          
          ForEach FormWindows()\FormGadgets()
            FormWindows()\FormGadgets()\selected = 0
          Next
          
          
          If parent
            this_parent = parent
            parentx1 = 0 : parenty1 = 0
            While this_parent <> 0
              PushListPosition(FormWindows()\FormGadgets())
              FD_FindParent(this_parent)
              this_parent = FormWindows()\FormGadgets()\parent
              
              parentx1 + FormWindows()\FormGadgets()\x1 - FormWindows()\FormGadgets()\scrollx
              parenty1 + FormWindows()\FormGadgets()\y1 - FormWindows()\FormGadgets()\scrolly
              
              If FormWindows()\FormGadgets()\type = #Form_Type_Panel
                parenty1 + Panel_Height
              EndIf
              
              PopListPosition(FormWindows()\FormGadgets())
            Wend
            
            FD_FindParent(parent)
            If FormWindows()\FormGadgets()\type = #Form_Type_Panel
              parent_item = FormWindows()\FormGadgets()\current_item
            Else
              parent_item = -1
            EndIf
            
            ; order the gadget at the end of the item list of the parent
            gadget = parent
            While NextElement(FormWindows()\FormGadgets())
              If FormWindows()\FormGadgets()\parent = parent
                If FormWindows()\FormGadgets()\parent_item > parent_item
                  Break
                EndIf
                gadget = FormWindows()\FormGadgets()\itemnumber
              Else
                Break
              EndIf
            Wend
            
            ForEach FormWindows()\FormGadgets()
              If FormWindows()\FormGadgets()\itemnumber = gadget
                Break
              EndIf
            Next
            
            AddElement(FormWindows()\FormGadgets())
            FormWindows()\FormGadgets()\x1 = d_x1 - parentx1
            FormWindows()\FormGadgets()\y1 = d_y1 - parenty1
            FormWindows()\FormGadgets()\x2 = d_x2 - parentx1
            FormWindows()\FormGadgets()\y2 = d_y2 - parenty1
            FormWindows()\FormGadgets()\selected = 1
            FormWindows()\FormGadgets()\type = drag_type
            FormWindows()\FormGadgets()\itemnumber = itemnumbers
            FormWindows()\FormGadgets()\parent = parent
            FormWindows()\FormGadgets()\parent_item = parent_item
          Else
            AddElement(FormWindows()\FormGadgets())
            FormWindows()\FormGadgets()\x1 = d_x1
            FormWindows()\FormGadgets()\y1 = d_y1
            FormWindows()\FormGadgets()\x2 = d_x2
            FormWindows()\FormGadgets()\y2 = d_y2
            FormWindows()\FormGadgets()\selected = 1
            FormWindows()\FormGadgets()\type = drag_type
            FormWindows()\FormGadgets()\itemnumber = itemnumbers
          EndIf
          
          itemnumbers + 1
          FormChanges(1)
          
          Select drag_type
            Case #Form_Type_ListIcon
              AddElement(FormWindows()\FormGadgets()\Columns())
              FormWindows()\FormGadgets()\Columns()\name = "Column 1"
              FormWindows()\FormGadgets()\Columns()\width = 100
            Case #Form_Type_ScrollArea
              FormWindows()\FormGadgets()\min = d_x2 - d_x1 + 200
              FormWindows()\FormGadgets()\max = d_y2 - d_y1 + 200
            Case #Form_Type_Scintilla
              FormWindows()\FormGadgets()\caption = "Callback_"+var+"()"
            Case #Form_Type_Panel
              AddElement(FormWindows()\FormGadgets()\Items())
              FormWindows()\FormGadgets()\Items()\name = "Tab 1"
          EndSelect
          
          FormWindows()\FormGadgets()\frontcolor = -1
          FormWindows()\FormGadgets()\backcolor = -1
          FormWindows()\FormGadgets()\variable = var
          FormWindows()\FormGadgets()\pbany = FormVariable
          FormWindows()\FormGadgets()\captionvariable = FormVariableCaption
          FormWindows()\FormGadgets()\tooltipvariable = FormVariableCaption
          
          FormWindows()\FormGadgets()\lock_left = 1
          FormWindows()\FormGadgets()\lock_top = 1
          
          FD_UpdateSplitter()
          
          FormAddUndoAction(1,FormWindows(),FormWindows()\FormGadgets(),#Undo_Create)
          
          FD_UpdateObjList()
          FD_SelectGadget(FormWindows()\FormGadgets())
          redraw = 1
          drag_type = 0
        EndIf
        
      EndIf
      
      If EventGadget() = #Form_PropObjList And EventDropType() = #PB_Drop_Private And EventDropPrivate() = #Form_PropObjList
        propobjlist_dest = GetGadgetState(#Form_PropObjList)
        
        If propobjlist_src <> propobjlist_dest And propobjlist_src > 0 And propobjlist_dest > -1
          
          PushListPosition(FormWindows()\FormGadgets())
          ChangeCurrentElement(ObjList(),GetGadgetItemData(#Form_PropObjList,propobjlist_src))
          ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
          *el1 = @FormWindows()\FormGadgets()
          parent = FormWindows()\FormGadgets()\parent
          parent_i = FormWindows()\FormGadgets()\parent_item
          level = ObjList()\level
          
          If propobjlist_dest = 0
            ChangeCurrentElement(ObjList(),GetGadgetItemData(#Form_PropObjList,1))
            where = #PB_List_Before
          Else
            ChangeCurrentElement(ObjList(),GetGadgetItemData(#Form_PropObjList,propobjlist_dest))
            where = #PB_List_After
          EndIf
          
          ; check the splitter is not moved before one of its elements
          splitter_dontmove = 0
          If FormWindows()\FormGadgets()\type = #Form_Type_Splitter
            id = FormWindows()\FormGadgets()\itemnumber
            
            PushListPosition(ObjList())
            
            While NextElement(ObjList())
              PushListPosition(FormWindows()\FormGadgets())
              ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
              
              If FormWindows()\FormGadgets()\splitter = id
                PopListPosition(FormWindows()\FormGadgets())
                splitter_dontmove = 1
                Break
              EndIf
              
              
              PopListPosition(FormWindows()\FormGadgets())
            Wend
            
            PopListPosition(ObjList())
          EndIf
          
          If Not splitter_dontmove
            ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
            *el2 = @FormWindows()\FormGadgets()
            
            If parent = FormWindows()\FormGadgets()\parent And parent_i = FormWindows()\FormGadgets()\parent_item
              ChangeCurrentElement(FormWindows()\FormGadgets(),*el1)
              MoveElement(FormWindows()\FormGadgets(),where,*el2)
              
              ; move all children
              ChangeCurrentElement(ObjList(),GetGadgetItemData(#Form_PropObjList,propobjlist_src))
              While NextElement(ObjList())
                If ObjList()\gadget_item = -1 And ObjList()\level > level
                  ChangeCurrentElement(FormWindows()\FormGadgets(),ObjList()\gadget)
                  MoveElement(FormWindows()\FormGadgets(),#PB_List_After,*el1)
                  *el1 = @FormWindows()\FormGadgets()
                Else
                  Break
                EndIf
              Wend
              
              PopListPosition(FormWindows()\FormGadgets())
              FD_UpdateObjList()
              FormChanges(1)
            Else
              MessageRequester(#ProductName$, Language("Form", "MoveGadgetWarning"))
            EndIf
          Else
            MessageRequester(#ProductName$, Language("Form", "MoveGadgetWarning"))
          EndIf
          
        EndIf
      EndIf ;}
    Case #PB_Event_Gadget
      FD_EventMain(EventGadgetID, EventType)
      EventSplitterWin(EventGadgetID, EventType)
      
    Case #PB_Event_Menu
      FD_ProcessMenuEvent(EventMenu())
  EndSelect
  If redraw
    FD_Redraw()
    redraw = 0
  EndIf
EndProcedure
