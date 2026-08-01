; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software and Gaetan DUPONT-PANON. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------
Procedure AddFormInfo(FileName$ = "")
  
  LastElement(FileList())
  *OldSource = *ActiveSource
  
  If *FormInfo = 0
    InitVars()
    FD_Init()
    *FormInfo = AddElement(FileList())
    
    OpenGadgetList(#GADGET_SourceContainer)
    
    ; Create the Form gadgets
    ;
    ContainerGadget(#GADGET_Form, 0, 0, 0, 0)
    CompilerIf #CompileWindows
      SetWindowLongPtr_(GadgetID(#GADGET_Form), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#GADGET_Form), #GWL_STYLE) | #WS_CLIPCHILDREN)
    CompilerEndIf
    
    CanvasGadget(#GADGET_Form_Canvas, 0, 0, 50 - 20, 50 - 20, #PB_Canvas_Keyboard)
    EnableGadgetDrop(#GADGET_Form_Canvas, #PB_Drop_Private, #PB_Drag_Copy, 50)
    
    ScrollBarGadget(#GADGET_Form_ScrollH, 0, 0, 50, 20, 0, 600, 600)
    BindGadgetEvent(#GADGET_Form_ScrollH, @Form_Scrollbars())
    ScrollBarGadget(#GADGET_Form_ScrollV, 0, 0, 20, 50, 0, 400, 400, #PB_ScrollBar_Vertical)
    BindGadgetEvent(#GADGET_Form_ScrollV, @Form_Scrollbars())
    
    CloseGadgetList()
    HideGadget(#GADGET_Form, #True)
    
    ; This creates a full Scintilla with the big callback, but it is never shown,
    ; and so it doesn't matter. This way, the code that expects a Scintilla to be
    ; present will work without crashing
    ;
    CreateEditorGadget()
    
    CloseGadgetList()
    
  Else
    *FormInfo = AddElement(FileList())
    
    OpenGadgetList(#GADGET_SourceContainer)
    CreateEditorGadget()
    CloseGadgetList()
  EndIf
  
  HideEditorGadget(*FormInfo\EditorGadget, #True) ; this is never visible
  
  If FileName$ = ""
    Title$ =  Language("FileStuff","NewForm")
  Else
    Title$ = GetFilePart(FileName$)
  EndIf
  
  FileList()\ID = GetUniqueID()
  FileList()\IsForm = FD_NewWindow()
  FileList()\IsCode = #True ; TODO: check if this is correct
  FileList()\FileName$        = FileName$
  FileList()\Debugger         = OptionDebugger  ; set the default values
  FileList()\EnablePurifier   = OptionPurifier
  FileList()\Optimizer        = OptionOptimizer
  FileList()\EnableASM        = OptionInlineASM
  FileList()\EnableXP         = OptionXPSkin
  FileList()\EnableAdmin      = OptionVistaAdmin
  FileList()\EnableUser       = OptionVistaUser
  FileList()\DllProtection    = OptionDllProtection
  FileList()\SharedUCRT       = OptionSharedUCRT
  FileList()\EnableThread     = OptionThread
  FileList()\EnableOnError    = OptionOnError
  FileList()\ExecutableFormat = OptionExeFormat
  FileList()\CPU              = OptionCPU
  FileList()\NewLineType      = OptionNewLineType
  FileList()\SubSystem$       = OptionSubSystem$
  FileList()\ErrorLog         = OptionErrorLog
  FileList()\Parser\Encoding  = OptionEncoding
  FileList()\UseCreateExe     = OptionUseCreateExe
  FileList()\UseBuildCount    = OptionUseBuildCount
  FileList()\UseCompileCount  = OptionUseCompileCount
  FileList()\TemporaryExePlace= OptionTemporaryExe
  FileList()\CustomCompiler   = OptionCustomCompiler
  FileList()\CompilerVersion$ = OptionCompilerVersion$
  FileList()\CurrentDirectory$= ""
  FileList()\ToggleFolds      = 1
  FileList()\CustomCompiler   = 0
  FileList()\PurifierGranularity$ = ""
  FileList()\ExistsOnDisk     = #False
  
  If OptionEncoding = 0
    ScintillaSendMessage(FileList()\EditorGadget, #SCI_SETCODEPAGE, 0, 0)
  Else
    ScintillaSendMessage(FileList()\EditorGadget, #SCI_SETCODEPAGE, #SC_CP_UTF8, 0)
  EndIf
  
  If EnableColoring
    SetBackgroundColor(FileList()\EditorGadget)
  EndIf
  
  Index = AddTabBarGadgetItem(#GADGET_FilesPanel, #PB_Default, Title$)
  SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
  SetTabBarGadgetItemColor(#GADGET_FilesPanel, Index, #PB_Gadget_BackColor, #COLOR_FormFile)
  ChangeActiveSourceCode(*OldSource)
  
  ResizeMainWindow()
  
  ActivateTool("Form")
EndProcedure

Procedure ResizeFormInfo(Width, Height)
  FD_UpdateScrollbars(1)
  
  swidth = Width - Grid_Scrollbar_Width
  sheight = Height - Grid_Scrollbar_Width
  
  If swidth < 1
    swidth = 1
  EndIf
  
  If sheight < 1 ; ResizeImage can't handle 0 or negative size
    sheight = 1
  EndIf
  
  ; Only resize it for bigger size, to have a fast splitter resize (resizing image and canvas is somewhat slow on big screen)
  ;
  ResizeGadget(#GADGET_Form_Canvas, 0, 0, swidth, sheight)
  ResizeImage(#Drawing_Img, DesktopScaledX(swidth), DesktopScaledY(sheight))
  redraw = 1
EndProcedure


Procedure NewForm()
  AddFormInfo()
EndProcedure

Procedure OpenForm(FileName$)
  AddFormInfo(FileName$)
  
  FD_Open(FileName$)
EndProcedure

Procedure FD_PrepareTestCode(compile = 1)
  
  ; if the current view is the code view, switch to design view and update changes
  If compile And FormWindows()\current_view = 1
    FD_SetDesignView()
  EndIf
  
  If propgrid ; exit edit mode in case the user is in edit mode in the form panel grid.
    grid_StopEditing(propgrid)
  EndIf
  
  
  code$ = FD_SelectCode(1, compile)
  SendEditorMessage(#SCI_CLEARALL, 0, 0) ; should completely erase the old document and create a new one
  InsertCodeString(code$)
  SendEditorMessage(#SCI_EMPTYUNDOBUFFER, 0, 0) ; so this loading cannot be undone
  
  SetSourceModified(#True) ; Set the code source as modified
  
  If Not compile
    FullSourceScan(*ActiveSource)
    UpdateFolding(*ActiveSource, 0, -1)
    UpdateProcedureList()
    UpdateVariableViewer()
  EndIf
  
EndProcedure


;- FormPanel plugin functions

Procedure FormPanel_CreateFunction(*Entry.ToolsPanelEntry)
  
  PanelGadget(#Form_Prop, 0, 0, 50, 50)
  AddGadgetItem(#Form_Prop, 0, Language("Form", "Toolbox"))
  
  gadgetlist = TreeGadget(#PB_Any, 0, 0, GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemWidth), GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemHeight), #PB_Tree_NoLines | #PB_Tree_AlwaysShowSelection)
  
  i = 0
  AddGadgetItem(gadgetlist, i, Language("Form", "AllForms"), 0, 0) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  AddGadgetItem(gadgetlist, i, Language("Form", "Cursor"), ImageID(#IMAGE_FormIcons_Cursor), 1) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  
  ForEach Gadgets()
    If Gadgets()\type <> #Form_Type_Window
      AddGadgetItem(gadgetlist, i, Gadgets()\name, ImageID(Gadgets()\icon), 1)
      SetGadgetItemData(gadgetlist, i, Gadgets()\type)
      i + 1
    EndIf
  Next
  
  node1 = i
  AddGadgetItem(gadgetlist, i, Language("Form", "CommonControls"), 0, 0) : i + 1
  SetGadgetItemData(gadgetlist,i - 1,-1)
  AddGadgetItem(gadgetlist, i, Language("Form", "Cursor"), ImageID(#IMAGE_FormIcons_Cursor), 1) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  
  ForEach Gadgets()
    If Gadgets()\node = 1
      AddGadgetItem(gadgetlist, i, Gadgets()\name, ImageID(Gadgets()\icon), 1)
      SetGadgetItemData(gadgetlist, i, Gadgets()\type)
      If Gadgets()\type = #Form_Type_Button
        nodesel = i
      EndIf
      i + 1
    EndIf
  Next
  
  node2 = i
  AddGadgetItem(gadgetlist, i, Language("Form", "Containers"), 0, 0) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  AddGadgetItem(gadgetlist, i, Language("Form", "Cursor"), ImageID(#IMAGE_FormIcons_Cursor), 1) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  
  ForEach Gadgets()
    If Gadgets()\node = 2
      AddGadgetItem(gadgetlist, i, Gadgets()\name, ImageID(Gadgets()\icon), 1)
      SetGadgetItemData(gadgetlist, i, Gadgets()\type)
      i + 1
    EndIf
  Next
  
  node3 = i
  AddGadgetItem(gadgetlist, i, Language("Form", "MenusToolbars"), 0, 0) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  AddGadgetItem(gadgetlist, i, Language("Form", "Cursor"), ImageID(#IMAGE_FormIcons_Cursor), 1) : i + 1
  SetGadgetItemData(gadgetlist, i - 1, -1)
  
  ForEach Gadgets()
    If Gadgets()\node = 3
      AddGadgetItem(gadgetlist, i, Gadgets()\name, ImageID(Gadgets()\icon), 1)
      SetGadgetItemData(gadgetlist, i, Gadgets()\type)
      i + 1
    EndIf
  Next
  
  SetGadgetItemState(gadgetlist, 0, #PB_Tree_Collapsed)
  SetGadgetItemState(gadgetlist, node1, #PB_Tree_Expanded)
  SetGadgetItemState(gadgetlist, node2, #PB_Tree_Expanded)
  SetGadgetItemState(gadgetlist, node3, #PB_Tree_Expanded)
  SetGadgetState(gadgetlist, nodesel)
  
  form_gadget_type = #Form_Type_Button
  
  AddGadgetItem(#Form_Prop, 1, Language("Form", "Objects"))
  TreeGadget(#Form_PropObjList, 0, 0, GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemWidth), GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemHeight), #PB_Tree_AlwaysShowSelection)
  EnableGadgetDrop(#Form_PropObjList, #PB_Drop_Private, #PB_Drag_Move, #Form_PropObjList)
  
  CloseGadgetList() ; Close the panel
  
  ContainerGadget(#Form_GridContainer,0,0,100,100)
  
  If *Entry\IsSeparateWindow
    CurrentParentWindow = *Entry\ToolWindowID
    AddKeyboardShortcut(CurrentParentWindow, #PB_Shortcut_Command | #PB_Shortcut_C, #Menu_Copy)
    AddKeyboardShortcut(CurrentParentWindow, #PB_Shortcut_Command | #PB_Shortcut_X, #Menu_Cut)
    AddKeyboardShortcut(CurrentParentWindow, #PB_Shortcut_Command | #PB_Shortcut_V, #Menu_Paste)
  Else
    CurrentParentWindow = #WINDOW_Main
  EndIf
  
  propgrid = GridGadget(0, 0, GadgetWidth(#Form_GridContainer), GadgetHeight(#Form_GridContainer), CurrentParentWindow, 3, 0, 20, 100, P_FontGrid, #P_FontGridSize, 0, #Form_GridContainer)
  grid_SetGadgetAttribute(propgrid, #Grid_Scrolling_Horizontal_Disabled, 1)
  grid_SetGadgetAttribute(propgrid, #Grid_Caption_Row, 1)
  grid_SetGadgetAttribute(propgrid, #Grid_Caption_Col, 1)
  grid_SetGadgetAttribute(propgrid, #Grid_Disable_Delete, 1)
  
  propgrid_combo = grid_CreateComboBox(propgrid)
  propgrid_proccombo = grid_CreateComboBox(propgrid)
  
  grid_SetColumnWidth(propgrid, 0, 20)
  grid_SetColumnWidth(propgrid, 1)
  grid_SetColumnWidth(propgrid, 2, grid_GadgetWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1))
  
  CloseGadgetList() ; Close the container
  
  SplitterGadget(#Form_SplitterInt, 0, 0, 100, 200, #Form_Prop, #Form_GridContainer, #PB_Splitter_FirstFixed)
  SetGadgetAttribute(#Form_SplitterInt, #PB_Splitter_FirstMinimumSize, 100)
  SetGadgetAttribute(#Form_SplitterInt, #PB_Splitter_SecondMinimumSize, 100)
  
  If form_splitter_pos <= 0
    form_splitter_pos = 230
  EndIf
  
  SetGadgetState(#Form_SplitterInt, form_splitter_pos)
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#Form_PropObjList)
    ToolsPanel_ApplyColors(gadgetlist)
    ToolsPanel_ApplyColors(propgrid)
  EndIf
  
  If currentwindow
    FD_SelectWindow(currentwindow)
    FD_UpdateObjList()
  EndIf
  
EndProcedure

Procedure FormPanel_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  If *Entry\IsSeparateWindow
    ResizeGadget(#Form_SplitterInt, 5, 5, PanelWidth-10, PanelHeight-10)
  Else
    ResizeGadget(#Form_SplitterInt, 0, 0, PanelWidth, PanelHeight)
  EndIf
  SetGadgetState(#Form_SplitterInt, form_splitter_pos)
  
  ResizeGadget(gadgetlist, 0, 0, GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemWidth), GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemHeight))
  ResizeGadget(#Form_PropObjList, 0, 0, GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemWidth), GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemHeight))
  grid_ResizeGadget(propgrid, 0, 0, GadgetWidth(#Form_GridContainer), GadgetHeight(#Form_GridContainer))
  
  grid_SetColumnWidth(propgrid, 0, 20)
  
  grid_SetColumnWidth(propgrid,1)
  width = grid_GadgetInnerWidth(propgrid) - grid_GetColumnWidth(propgrid, 0) - grid_GetColumnWidth(propgrid, 1)
  If width < 40
    width = 40
  EndIf
  grid_SetColumnWidth(propgrid, 2, width)
  
EndProcedure

Procedure FormPanel_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  If EventGadgetID = #Form_SplitterInt
    grid_ResizeGadget(propgrid, 0, 0, GadgetWidth(#Form_GridContainer), GadgetHeight(#Form_GridContainer))
    ResizeGadget(#Form_PropObjList, 0, 0, GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemWidth), GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemHeight))
    ResizeGadget(gadgetlist, 0, 0, GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemWidth), GetGadgetAttribute(#Form_Prop, #PB_Panel_ItemHeight))
    
    form_splitter_pos = GetGadgetState(#Form_SplitterInt)
  EndIf
  
  If *ActiveSource And *ActiveSource\IsForm
    Select EventGadgetID
      Case gadgetlist
        state = GetGadgetState(gadgetlist)
        
        If state > -1
          form_gadget_type = GetGadgetItemData(gadgetlist, state)
        EndIf
        
        If form_gadget_type = #Form_Type_Splitter
          InitSplitterWin()
        EndIf
        
        Select EventType()
          Case #PB_EventType_DragStart
            If EventGadget() = gadgetlist And *ActiveSource\IsForm
              state = GetGadgetState(gadgetlist)
              tmp_drag_type = GetGadgetItemData(gadgetlist, state)
              drag_type = 0
              
              If tmp_drag_type > 0
                Select tmp_drag_type
                  Case #Form_Type_Toolbar, #Form_Type_StatusBar, #Form_Type_Menu, #Form_Type_Splitter
                    
                  Default
                    drag_type = tmp_drag_type
                    DragPrivate(50)
                    
                EndSelect
                
              EndIf
              
            EndIf
            
          Case #PB_EventType_LeftDoubleClick
            Select form_gadget_type
              Case #Form_Type_Splitter
                
              Case #Form_Type_Toolbar
                FormWindows()\toolbar_visible = 1
                redraw = 1
                
              Case #Form_Type_Menu
                FormWindows()\menu_visible = 1
                redraw = 1
                
              Case #Form_Type_StatusBar
                FormWindows()\status_visible = 1
                redraw = 1
                
              Default
                If form_gadget_type > 0
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
                    Case #Form_Type_OpenGL
                      var = "OpenGL_"+Str(FormWindows()\c_opengl)
                      FormWindows()\c_opengl + 1
                    Case #Form_Type_Scintilla
                      var = "Scintilla_"+Str(FormWindows()\c_scintilla)
                      FormWindows()\c_scintilla + 1
                    Case #Form_Type_Splitter
                      var = "Splitter_"+Str(FormWindows()\c_splitter)
                      FormWindows()\c_splitter + 1
                    Case #Form_Type_Frame3D
                      var = "Frame3D_"+Str(FormWindows()\c_frame3D)
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
                  
                  d_x1 = 10
                  d_x2 = 100 + d_x1
                  d_y1 = 10
                  d_y2 = 25 + d_y1
                  
                  ForEach FormWindows()\FormGadgets()
                    FormWindows()\FormGadgets()\selected = 0
                  Next
                  
                  AddElement(FormWindows()\FormGadgets())
                  FormWindows()\FormGadgets()\x1 = d_x1
                  FormWindows()\FormGadgets()\y1 = d_y1
                  FormWindows()\FormGadgets()\x2 = d_x2
                  FormWindows()\FormGadgets()\y2 = d_y2
                  FormWindows()\FormGadgets()\selected = 1
                  FormWindows()\FormGadgets()\type = form_gadget_type
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
                EndIf
                
            EndSelect
            
        EndSelect
        
        
      Case #Form_PropObjList
        Select EventType()
          Case #PB_EventType_DragStart
            propobjlist_src = GetGadgetState(#Form_PropObjList)
            DragPrivate(#Form_PropObjList, #PB_Drag_Move)
            
          Case #PB_EventType_Change
            ForEach FormWindows()\FormGadgets()
              FormWindows()\FormGadgets()\selected = 0
            Next
            
            el = GetGadgetItemData(#Form_PropObjList, GetGadgetState(#Form_PropObjList))
            
            If el
              ChangeCurrentElement(ObjList(), el)
              
              If ObjList()\gadget
                ChangeCurrentElement(FormWindows()\FormGadgets(), ObjList()\gadget)
                
                If ObjList()\gadget_item > -1
                  FormWindows()\FormGadgets()\current_item = ObjList()\gadget_item
                EndIf
                
                FormWindows()\FormGadgets()\selected = 1
                FD_SelectGadget(FormWindows()\FormGadgets())
                
              Else
                ChangeCurrentElement(ObjList(),el)
                FD_SelectWindow(ObjList()\window)
              EndIf
              
              SetActiveGadget(#GADGET_Form_Canvas)
              redraw = 1
            EndIf
        EndSelect
        
    EndSelect
    
  EndIf
  
EndProcedure

Procedure FormPanel_DestroyFunction(*Entry.ToolsPanelEntry)
  
  grid_FreeGadget(propgrid) ; Important to free the grid or some event could still get to it (timer and such) !
  propgrid = 0
  
EndProcedure

Procedure FormPanel_PreferenceLoad(*Entry.ToolsPanelEntry)
  
  PreferenceGroup("FormPanel")
  form_splitter_pos = ReadPreferenceLong("SplitterPos", 230)
  
  If IsGadget(#Form_SplitterInt)
    SetGadgetState(#Form_SplitterInt, form_splitter_pos)
  EndIf
  
EndProcedure

Procedure FormPanel_PreferenceSave(*Entry.ToolsPanelEntry)
  
  PreferenceComment("")
  PreferenceGroup("FormPanel")
  WritePreferenceLong("SplitterPos", form_splitter_pos)
EndProcedure

;- Initialisation code
; This will make this Tool available to the editor

CompilerIf Not #SpiderBasic
  FormPanel_VT.ToolsPanelFunctions
  
  FormPanel_VT\CreateFunction      = @FormPanel_CreateFunction()
  FormPanel_VT\DestroyFunction     = @FormPanel_DestroyFunction()
  FormPanel_VT\ResizeHandler       = @FormPanel_ResizeHandler()
  FormPanel_VT\EventHandler        = @FormPanel_EventHandler()
  FormPanel_VT\PreferenceLoad      = @FormPanel_PreferenceLoad()
  FormPanel_VT\PreferenceSave      = @FormPanel_PreferenceSave()
  
  
  AddElement(AvailablePanelTools())
  
  AvailablePanelTools()\FunctionsVT          = @FormPanel_VT
  AvailablePanelTools()\NeedPreferences      = 1
  AvailablePanelTools()\NeedConfiguration    = 0
  AvailablePanelTools()\NeedDestroyFunction  = 1
  AvailablePanelTools()\ToolID$              = "Form"
  AvailablePanelTools()\PanelTitle$          = "FormShort"
  AvailablePanelTools()\ToolName$            = "FormLong"
  AvailablePanelTools()\PanelTabOrder        = 4
CompilerEndIf
