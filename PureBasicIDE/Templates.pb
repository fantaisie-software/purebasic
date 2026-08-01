; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



;TODO: mac: edit menu in treegadget and edit window!

Structure Template
  Name$
  IsDirectory.l
  Sublevel.l
  IsExpanded.l ; for directories
  
  Comment$
  Code$
EndStructure

Global NewList Template.Template()

Global Template_Selection
Global Template_FirstVisible
Global Template_Splitter
Global Template_AskDelete, Backup_Template_AskDelete
Global Template_DragItem

Global TemplateWindowDialog.DialogWindow, TemplateWindowPosition.DialogPosition

Global *Templates.ToolsPanelEntry ; for global access to the data...

Procedure.s Template_Escape(String$)
  ProcedureReturn ReplaceString(ReplaceString(String$, "\", "\\"), #NewLine, "\n")
EndProcedure

Procedure.s Template_Unescape(String$, NewlineSequence$ = #NewLine)
  ;
  ; A simple ReplaceString() does not work, as "\n" is escaped to "\\n", so
  ; no matter how the replaces are done, a newline gets inserted.
  ;
  Index = 1
  Length = Len(String$)
  
  While Index < Length ; last character needs no checking, as escape sequences are 2 chars
    If Mid(String$, Index, 2) = "\\"
      String$ = Left(String$, index-1) + Right(String$, Length-index) ; cut one of the \
      Length  - 1
    ElseIf Mid(String$, Index, 2) = "\n"
      String$ = Left(String$, index-1) + NewlineSequence$ + Right(String$, Length-index-1) ; cut all the \n
      Length  - 2 + Len(NewlineSequence$)
    EndIf
    
    Index + 1
  Wend
  
  ProcedureReturn String$
EndProcedure


CompilerIf #CompileWindows
  
  Procedure TreeGadgetItemNumber(GadgetID, ItemHandle)
    
    Count = CountGadgetItems(GadgetID)
    For k = 0 To Count-1
      If GadgetItemID(GadgetID, k) = ItemHandle
        ProcedureReturn k
      EndIf
    Next
    
    ProcedureReturn -1
  EndProcedure
  
CompilerEndIf


Procedure Template_Save()
  
  If CreateFile(#FILE_Template, TemplatesFile$)
    WriteStringN(#FILE_Template, "TEMPLATES:1.0")
    WriteStringN(#FILE_Template, "")
    
    sublevel = 0
    ForEach Template()
      
      While Template()\Sublevel < sublevel
        sublevel - 1
        WriteStringN(#FILE_Template, Space(sublevel*2)+"CloseDirectory")
      Wend
      
      If Template()\IsDirectory
        WriteStringN(#FILE_Template, Space(sublevel*2)+"Directory: "+Template()\Name$)
        If Template()\IsExpanded
          WriteStringN(#FILE_Template, Space(sublevel*2)+"Expanded")
        EndIf
        sublevel + 1
      Else
        WriteStringN(#FILE_Template, Space(sublevel*2)+"Template: "+Template()\Name$)
        If Template()\Comment$ <> ""
          WriteStringN(#FILE_Template, Space(sublevel*2+2)+"Comment: "+Template()\Comment$)
        EndIf
        WriteStringN(#FILE_Template, Space(sublevel*2+2)+"Code: "+Template()\Code$)
      EndIf
      
    Next Template()
    
    While sublevel > 0
      sublevel - 1
      WriteStringN(#FILE_Template, Space(sublevel*2)+"CloseDirectory")
    Wend
    
    CloseFile(#FILE_Template)
  EndIf
  
EndProcedure


Procedure Template_UpdateGadgetStates()
  
  If IsWindow(#WINDOW_Template)
    ; disable template window
    For i = #GADGET_Template_Add To #GADGET_Template_Tree
      DisableGadget(i, 1)
    Next i
    
  Else
    
    index = GetGadgetState(#GADGET_Template_Tree)
    If index = -1
      
      DisableGadget(#GADGET_Template_Edit, 1)
      DisableGadget(#GADGET_Template_Remove, 1)
      DisableGadget(#GADGET_Template_RemoveDir, 1)
      DisableGadget(#GADGET_Template_Up, 1)
      DisableGadget(#GADGET_Template_Down, 1)
      
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Use, 1)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Edit, 1)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Remove, 1)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_RemoveDir, 1)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Rename, 1)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Up, 1)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Down, 1)
      
      SetGadgetText(#GADGET_Template_Comment, "")
      
    Else
      
      SelectElement(Template(), index)
      
      If Template()\IsDirectory
        DisableGadget(#GADGET_Template_Edit, 1)
        DisableGadget(#GADGET_Template_Remove, 1)
        DisableGadget(#GADGET_Template_RemoveDir, 0)
        
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Use, 1)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Edit, 1)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Remove, 1)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_RemoveDir, 0)
        
        SetGadgetText(#GADGET_Template_Comment, "")
        
      Else
        DisableGadget(#GADGET_Template_Edit, 0)
        DisableGadget(#GADGET_Template_Remove, 0)
        DisableGadget(#GADGET_Template_RemoveDir, 1)
        
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Use, 0)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Edit, 0)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Remove, 0)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_RemoveDir, 1)
        
        SetGadgetText(#GADGET_Template_Comment, Template_Unescape(Template()\Comment$))
        
      EndIf
      
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Rename, 0)
      
      Sublevel = Template()\Sublevel
      If PreviousElement(Template()) = 0 Or Template()\Sublevel < Sublevel
        DisableGadget(#GADGET_Template_Up, 1)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Up, 1)
      Else
        DisableGadget(#GADGET_Template_Up, 0)
        DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Up, 0)
      EndIf
      
      SelectElement(Template(), index)
      disable = 1
      While NextElement(Template())
        If Template()\Sublevel = Sublevel
          disable = 0
          Break
        ElseIf Template()\Sublevel < Sublevel
          Break
        EndIf
      Wend
      DisableGadget(#GADGET_Template_Down, disable)
      DisableMenuItem(#POPUPMENU_Template, #MENU_Template_Down, disable)
      
    EndIf
    
  EndIf
  
EndProcedure

Procedure TemplateWindowEvents(EventID)
  
  If EventID = #PB_Event_CloseWindow
    If MemorizeWindow
      TemplateWindowDialog\Close(@TemplateWindowPosition)
    Else
      TemplateWindowDialog\Close()
    EndIf
    
    If *Templates ; if its a separate window, it may be closed!
      For i = #GADGET_Template_Add To #GADGET_Template_Tree
        DisableGadget(i, 0) ; re-enable all gadgets
      Next i
      Template_UpdateGadgetStates()           ; update the disabled state
      
      ; put focus back on templates window if it is separate
      If *Templates\IsSeparateWindow
        SetActiveWindow(*Templates\ToolWindowID)
      EndIf
      
      SetActiveGadget(#GADGET_Template_Tree)
    EndIf
    
    
  ElseIf EventID = #PB_Event_Gadget
    If EventGadget() = #GADGET_Template_Save
      
      Length = ScintillaSendMessage(#GADGET_Template_Editor, #SCI_GETTEXTLENGTH, 0, 0)
      Text$ = Space(Length)
      ScintillaSendMessage(#GADGET_Template_Editor, #SCI_GETTEXT, Length+1, @Text$)
      Template()\Code$ = Template_Escape(PeekS(@Text$, -1, #PB_UTF8))
      
      Length = ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_GETTEXTLENGTH, 0, 0)
      Text$ = Space(Length)
      ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_GETTEXT, Length+1, @Text$)
      Template()\Comment$ = Template_Escape(PeekS(@Text$, -1, #PB_UTF8))
      
      SetGadgetText(#GADGET_Template_Comment, GetGadgetText(#GADGET_Template_SetComment))
      TemplateWindowEvents(#PB_Event_CloseWindow) ; close the window
      
      ; Write the templates immediately to disk, so if the IDE crash or force closed, it won't be lost
      Template_Save()
      
    ElseIf EventGadget() = #GADGET_Template_Cancel
      TemplateWindowEvents(#PB_Event_CloseWindow)
      
    EndIf
    
  ElseIf EventID = #PB_Event_SizeWindow
    TemplateWindowDialog\SizeUpdate()
    
  EndIf
  
EndProcedure

Procedure OpenTemplateWindow()
  
  TemplateWindowDialog = OpenDialog(?Dialog_Templates, WindowID(#WINDOW_Main), @TemplateWindowPosition)
  If TemplateWindowDialog
    EnsureWindowOnDesktop(#WINDOW_Template)
    
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_USEPOPUP, 1, 0) ; use the scintilla popup
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_SETMARGINWIDTHN, 0, 0)
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_SETMARGINWIDTHN, 1, 0)
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_STYLESETFONT,  #STYLE_DEFAULT, ToAscii(EditorFontName$))
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_STYLESETSIZE, #STYLE_DEFAULT,  EditorFontSize)
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_STYLECLEARALL, 0, 0)
    
    Text$ = Template_Unescape(Template()\Code$)
    ScintillaSendMessage(#GADGET_Template_Editor, #SCI_SETTEXT, 0, ToUTF8(Text$))
    
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_USEPOPUP, 1, 0) ; use the scintilla popup
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_SETMARGINWIDTHN, 0, 0)
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_SETMARGINWIDTHN, 1, 0)
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_SETWRAPMODE, 1, 0) ; wrap at word boundaries
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_STYLESETFONT,  #STYLE_DEFAULT, ToAscii(EditorFontName$))
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_STYLESETSIZE, #STYLE_DEFAULT,  EditorFontSize)
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_STYLECLEARALL, 0, 0)
    
    Text$ = Template_Unescape(Template()\Comment$)
    ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_SETTEXT, 0, ToUTF8(Text$))
    
    CompilerIf #CompileWindows
      ; Use system defaults for selected text for screenreader access
      ;
      ScintillaSendMessage(#GADGET_Template_Editor, #SCI_SETSELBACK, 1, GetSysColor_(#COLOR_HIGHLIGHT))
      ScintillaSendMessage(#GADGET_Template_Editor, #SCI_SETSELFORE, 1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
      ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_SETSELBACK, 1, GetSysColor_(#COLOR_HIGHLIGHT))
      ScintillaSendMessage(#GADGET_Template_SetComment, #SCI_SETSELFORE, 1, GetSysColor_(#COLOR_HIGHLIGHTTEXT))
    CompilerEndIf
    
    ; disable template window
    For i = #GADGET_Template_Add To #GADGET_Template_Tree
      DisableGadget(i, 1)
    Next i
    
    HideWindow(#WINDOW_Template, 0)
  EndIf
  
EndProcedure

Procedure UpdateTemplateWindow()
  ; since the toolpanel is recreated on a prefs update, we should make sure
  ; this window gets closed, not updated.. to prevent any invalid input to happen
  ;
  TemplateWindowEvents(#PB_Event_CloseWindow)
EndProcedure


Procedure Template_SaveState()
  
  currentindex = ListIndex(Template())
  
  Template_Selection = GetGadgetState(#GADGET_Template_Tree)
  
  ForEach Template()
    If Template()\IsDirectory
      Template()\IsExpanded = GetGadgetItemState(#GADGET_Template_Tree, ListIndex(Template())) & #PB_Tree_Expanded
    EndIf
  Next Template()
  
  CompilerIf #CompileWindows
    Template_FirstVisible = TreeGadgetItemNumber(#GADGET_Template_Tree,  SendMessage_(GadgetID(#GADGET_Template_Tree), #TVM_GETNEXTITEM, #TVGN_FIRSTVISIBLE, 0))
  CompilerEndIf
  
  If currentindex = -1
    ResetList(Template())
  Else
    SelectElement(Template(), currentindex)
  EndIf
  
EndProcedure

Procedure Template_FillTree()
  
  StartGadgetFlickerFix(#GADGET_Template_Tree)
  
  ClearGadgetItems(#GADGET_Template_Tree)
  
  sublevel = 0
  ForEach Template()
    
    ; close necessary nodes..
    While Template()\sublevel < sublevel
      sublevel - 1
    Wend
    
    If Template()\IsDirectory
      AddGadgetItem(#GADGET_Template_Tree, -1, Template()\Name$, ImageID(#IMAGE_Template_Dir), sublevel)
      sublevel + 1
    Else
      AddGadgetItem(#GADGET_Template_Tree, -1, Template()\Name$, ImageID(#IMAGE_Template_Template), sublevel)
    EndIf
    
  Next Template()
  
  ;
  ; Apply the recently saved items state
  ;
  
  SetGadgetState(#GADGET_Template_Tree, Template_Selection)
  
  ForEach Template()
    If Template()\IsDirectory And Template()\IsExpanded
      SetGadgetItemState(#GADGET_Template_Tree, ListIndex(Template()), #PB_Tree_Expanded)
    EndIf
  Next Template()
  
  CompilerIf #CompileWindows
    
    SendMessage_(GadgetID(#GADGET_Template_Tree), #TVM_ENSUREVISIBLE, 0, GadgetItemID(#GADGET_Template_Tree, Template_FirstVisible))
    
  CompilerEndIf
  
  Template_UpdateGadgetStates()
  
  StopGadgetFlickerFix(#GADGET_Template_Tree)
  
EndProcedure



Procedure Template_Insert()
  
  If *ActiveSource <> *ProjectInfo
    index = GetGadgetState(#GADGET_Template_Tree)
    If index <> -1
      SelectElement(Template(), index)
      If Template()\IsDirectory = 0
        
        ; build the string to put before each line (except the first)
        ;
        Prefix$ = ""
        GetCursorPosition() ; update cursor position values
        Line$ = Left(GetLine(*ActiveSource\CurrentLine-1), *ActiveSource\CurrentColumnChars-1)
        
        While Asc(Line$) = ' ' Or Asc(Line$) = 9 ; process all the space/tab combinations
          Prefix$ + Left(Line$, 1)
          Line$ = Right(Line$, Len(Line$)-1)
        Wend
        Prefix$ + Space(Len(Line$)) ; replace remaining characters by spaces
        
        Template$ = Template_Unescape(Template()\Code$)
        Code$ = ReplaceString(Template$, #NewLine, #NewLine+Prefix$)
        InsertCodeString(Code$, #True)
        SetActiveGadget(*ActiveSource\EditorGadget)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure Template_MoveElement(*Element.Template, *Target.Template, Type)
  
  Template_SaveState()
  
  ; save the position of the item after the *Element!
  ;
  ChangeCurrentElement(Template(), *Element)
  If NextElement(Template())
    *GetPoint.Template = @Template()
  Else
    *GetPoint = 0
  EndIf
  
  
  ; first we just move the element itself
  ;
  ChangeCurrentElement(Template(), *Target)
  
  If Type = 1 ; move up
    InsertElement(Template())
  ElseIf Type = 2 ; move down
    If *Target\IsDirectory = 0 ; we must skip the directory of the target first
      AddElement(Template())
    Else
      Repeat
        If NextElement(Template()) = 0
          AddElement(Template())
          Break
        EndIf
        If Template()\Sublevel <= *Target\Sublevel
          InsertElement(Template())
          Break
        EndIf
      ForEver
    EndIf
  ElseIf Type = 3 ; drag & drop
    If *Target\IsDirectory = 0
      InsertElement(Template())
    Else
      AddElement(Template())
    EndIf
  EndIf
  
  *New.Template = @Template()
  SwapElements(Template(), *Element, *New)
  ChangeCurrentElement(Template(), *New) ; remove the dummy element again
  DeleteElement(Template())
  
  Sublevel = *Element\Sublevel
  
  If Type = 3 And *Target\IsDirectory
    *Element\Sublevel = *Target\Sublevel + 1
  Else
    *Element\Sublevel = *Target\Sublevel
  EndIf
  
  If *Element\IsDirectory = 1 ; we must move the rest of the directory
    *AddPoint.Template = *Element ; we add all the children after the element
    
    While *GetPoint And *GetPoint\Sublevel > Sublevel
      ChangeCurrentElement(Template(), *GetPoint)  ; save the next item position first!
      If NextElement(Template())
        *NewGetPoint.Template = @Template()
      Else
        *NewGetPouint = 0
      EndIf
      
      ChangeCurrentElement(Template(), *AddPoint)
      AddElement(Template())
      *New.Template = @Template()
      
      SwapElements(Template(), *New, *GetPoint)
      ChangeCurrentElement(Template(), *New)
      DeleteElement(Template())
      
      If Type = 3 And *Target\IsDirectory
        *GetPoint\Sublevel - (Sublevel - *Target\Sublevel) + 1
      Else
        *GetPoint\Sublevel - (Sublevel - *Target\Sublevel)
      EndIf
      
      *AddPoint = *GetPoint
      *GetPoint = *NewGetPoint ; move to the next item
    Wend
  EndIf
  
  ChangeCurrentElement(Template(), *Element)
  Template_Selection = ListIndex(Template()) ; mark the moved element as selected one
  
  Template_FillTree()
  
EndProcedure

; Called on a #PB_Event_GadgetDrop on the Tree. As this is a separate event
; from #PB_Event_Gadget, the EventHandler() will not get it itself.
Procedure Template_DropEvent()
  
  Target = GetGadgetState(#GADGET_Template_Tree)
  If Target = -1
    Target = CountGadgetItems(#GADGET_Template_Tree)-1
  EndIf
  
  ; verify and do the move
  ;
  If Template_DragItem <> Target
    SelectElement(Template(), Template_DragItem)
    *Element.Template = @Template()
    SelectElement(Template(), Target)
    *Target.Template = @Template()
    
    
    If Target < Template_DragItem ; moving up is always valid
      Template_MoveElement(*Element, *Target, 3)
      
    ElseIf *Element\IsDirectory ; cannot move a directory into itself.. check that
      While PreviousElement(Template()) And @Template() <> *Element  ; move from target to source
        If Template()\Sublevel <= *Element\Sublevel                  ; target is not inside the source
          Template_MoveElement(*Element, *Target, 3)
          Break
        EndIf
      Wend
      
    Else ; a template can be moved everywhere
      Template_MoveElement(*Element, *Target, 3)
      
    EndIf
  EndIf
  
EndProcedure

Procedure Template_CreateFunction(*Entry.ToolsPanelEntry)
  Shared Templae_FirstResize
  
  ButtonImageGadget(#GADGET_Template_Add,       0, 0, 0, 0, ImageID(#IMAGE_Template_Add))
  ButtonImageGadget(#GADGET_Template_Edit,      0, 0, 0, 0, ImageID(#IMAGE_Template_Edit))
  ButtonImageGadget(#GADGET_Template_Remove,    0, 0, 0, 0, ImageID(#IMAGE_Template_Remove))
  ButtonImageGadget(#GADGET_Template_AddDir,    0, 0, 0, 0, ImageID(#IMAGE_Template_AddDir))
  ButtonImageGadget(#GADGET_Template_RemoveDir, 0, 0, 0, 0, ImageID(#IMAGE_Template_RemoveDir))
  ButtonImageGadget(#GADGET_Template_Up,        0, 0, 0, 0, ImageID(#IMAGE_Template_Up))
  ButtonImageGadget(#GADGET_Template_Down,      0, 0, 0, 0, ImageID(#IMAGE_Template_Down))
  
  GadgetToolTip(#GADGET_Template_Add,       Language("Templates","New"))
  GadgetToolTip(#GADGET_Template_Edit,      Language("Templates","Edit"))
  GadgetToolTip(#GADGET_Template_Remove,    Language("Templates","Delete"))
  GadgetToolTip(#GADGET_Template_AddDir,    Language("Templates","NewDir"))
  GadgetToolTip(#GADGET_Template_RemoveDir, Language("Templates","DeleteDir"))
  GadgetToolTip(#GADGET_Template_Up,        Language("Templates","Up"))
  GadgetToolTip(#GADGET_Template_Down,      Language("Templates","Down"))
  
  TreeGadget(#GADGET_Template_Tree, 0, 0, 0, 0, #PB_Tree_AlwaysShowSelection)
  TextGadget(#GADGET_Template_Comment, 0, 0, 0, 0, "", #PB_Text_Border)
  ;SplitterGadget(#GADGET_Template_Splitter, 0, 0, 0, 0, #GADGET_Template_Tree, #GADGET_Template_Comment, #PB_Splitter_SecondFixed)
  Templae_FirstResize = 1 ; to set the splitter pos after! the resize
  
  If EnableMenuIcons
    *Popup = CreatePopupImageMenu(#POPUPMENU_Template)
  Else
    *Popup = CreatePopupMenu(#POPUPMENU_Template)
  EndIf
  
  If *Popup
    MenuItem(#MENU_Template_Use, Language("Templates","MenuUse"))
    MenuBar()
    MenuItem(#MENU_Template_New, Language("Templates","MenuNew"), ImageID(#IMAGE_Template_Add))
    MenuItem(#MENU_Template_Edit, Language("Templates","MenuEdit"), ImageID(#IMAGE_Template_Edit))
    MenuItem(#MENU_Template_Remove, Language("Templates","MenuDelete"), ImageID(#IMAGE_Template_Remove))
    MenuBar()
    MenuItem(#MENU_Template_NewDir, Language("Templates","MenuNewDir"), ImageID(#IMAGE_Template_AddDir))
    MenuItem(#MENU_Template_RemoveDir, Language("Templates","MenuDeleteDir"), ImageID(#IMAGE_Template_RemoveDir))
    MenuBar()
    MenuItem(#MENU_Template_Rename, Language("Templates","MenuRename"))
    MenuBar()
    MenuItem(#MENU_Template_Up, Language("Templates","MenuUp"), ImageID(#IMAGE_Template_Up))
    MenuItem(#MENU_Template_Down, Language("Templates","MenuDown"), ImageID(#IMAGE_Template_Down))
  EndIf
  
  Template_FillTree()
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_Template_Tree)
  EndIf
  
  EnableGadgetDrop(#GADGET_Template_Tree, #PB_Drop_Private, #PB_Drag_Move, #DRAG_Templates)
  
  CompilerIf #CompileLinuxGtk
    ; the gtk label is by default not wrapping lines
    gtk_label_set_line_wrap_(GadgetID(#GADGET_Template_Comment), #True)
  CompilerEndIf
  
  *Templates = *Entry
  
EndProcedure


Procedure Template_DestroyFunction(*Entry.ToolsPanelEntry)
  
  Template_SaveState()
  
  *Templates = 0
  
EndProcedure


Procedure Template_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  Shared Templae_FirstResize
  
  ;TODO: templates - splitterproblem (should be fixed and enabled again)
  ;   ResizeGadget(#GADGET_Template_Splitter, 0, 32, PanelWidth, PanelHeight-32)
  ;   If Templae_FirstResize
  ;     SetGadgetState(#GADGET_Template_Splitter, PanelHeight-32-Template_Splitter)
  ;     Templae_FirstResize = 0
  ;   Else
  ;     Template_Splitter = PanelHeight-32-GetGadgetState(#GADGET_Template_Splitter)
  ;   EndIf
  
  
  ; All the buttons should have the same size, so only call it once
  ;
  GetRequiredSize(#GADGET_Template_Add, @Width.l, @Height.l)
  
  CompilerIf #CompileWindows
    Space = 5
  CompilerElse
    Space = 8 ; looks better on Linux/OSX with some more space
  CompilerEndIf
  
  x = 5
  ResizeGadget(#GADGET_Template_Add,       x, 5, Width, Height): x + Width + Space
  ResizeGadget(#GADGET_Template_Edit,      x, 5, Width, Height): x + Width + Space
  ResizeGadget(#GADGET_Template_Remove,    x, 5, Width, Height): x + Width + Space
  ResizeGadget(#GADGET_Template_AddDir,    x, 5, Width, Height): x + Width + Space
  ResizeGadget(#GADGET_Template_RemoveDir, x, 5, Width, Height): x + Width + Space
  ResizeGadget(#GADGET_Template_Up,        x, 5, Width, Height): x + Width + Space
  ResizeGadget(#GADGET_Template_Down,      x, 5, Width, Height)
  
  If *Entry\IsSeparateWindow
    ResizeGadget(#GADGET_Template_Tree, 5, 10+Height, PanelWidth-10, PanelHeight-Height-80)
    ResizeGadget(#GADGET_Template_Comment, 5, PanelHeight-65, PanelWidth-10, 60)
  Else
    ResizeGadget(#GADGET_Template_Tree, 0, 10+Height, PanelWidth, PanelHeight-Height-80)
    ResizeGadget(#GADGET_Template_Comment, 0, PanelHeight-65, PanelWidth, 65)
  EndIf
  
  CompilerIf #CompileLinuxGtk
    ; required for the TextGadget() to correctly wrap the lines
    ; sets the gtklabel's size request to the size of the gtkeventbox
    ; (see gtk_label_set_line_wrap_() documentation for an explanation)
    gtk_widget_set_size_request_(GadgetID(#GADGET_Template_Comment), GadgetWidth(#GADGET_Template_Comment)-4, -1)
  CompilerEndIf
  
EndProcedure

Procedure Template_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  Static DragItem
  
  Select EventGadgetID
      
    Case #GADGET_Template_Add
      Name$ = InputRequester(Language("Templates","Title"), Language("Templates","EnterName")+":", "")
      If Name$ <> ""
        Template_SaveState()
        
        index = GetGadgetState(#GADGET_Template_Tree)
        If index = -1
          LastElement(Template())
          AddElement(Template())
          Sublevel = 0
        Else
          SelectElement(Template(), index)
          Sublevel = Template()\Sublevel
          If Template()\IsDirectory
            IsExpanded = Template()\IsExpanded
            IsEmpty    = 1
            Repeat
              If NextElement(Template()) = 0
                AddElement(Template())
                Break
              EndIf
              If Template()\Sublevel <= Sublevel
                InsertElement(Template())
                Break
              EndIf
              IsEmpty = 0 ; at least one item was found
            ForEver
            
            If IsExpanded Or IsEmpty ; only add as child to opened dirs, or if it was new
              Sublevel + 1
            EndIf
          Else
            AddElement(Template())
          EndIf
        EndIf
        Template()\Name$ = Name$
        Template()\IsDirectory = 0
        Template()\Sublevel = Sublevel
        index = ListIndex(Template())
        Template_FillTree()
        
        SetGadgetState(#GADGET_Template_Tree, index)
        SelectElement(Template(), index)
        OpenTemplateWindow() ; start editing this template
      EndIf
      
    Case #GADGET_Template_Edit
      index = GetGadgetState(#GADGET_Template_Tree)
      If index <> -1
        SelectElement(Template(), index)
        If Template()\IsDirectory = 0
          OpenTemplateWindow() ; start editing this item
        EndIf
      EndIf
      
    Case #GADGET_Template_Remove
      index = GetGadgetState(#GADGET_Template_Tree)
      If index <> -1
        SelectElement(Template(), index)
        If Template()\IsDirectory = 0
          
          If Template_AskDelete
            If MessageRequester(#ProductName$, Language("Templates", "DeleteQuestion"), #FLAG_QUESTION|#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
              Template_SaveState()
              DeleteElement(Template())
              Template_FillTree()
            EndIf
          Else
            Template_SaveState()
            DeleteElement(Template())
            Template_FillTree()
          EndIf
          
        EndIf
      EndIf
      
    Case #GADGET_Template_AddDir
      Name$ = InputRequester(Language("Templates","Title"), Language("Templates","EnterDirName")+":", "")
      If Name$ <> ""
        Template_SaveState()
        
        index = GetGadgetState(#GADGET_Template_Tree)
        If index = -1
          LastElement(Template())
          AddElement(Template())
          Sublevel = 0
        Else
          SelectElement(Template(), index)
          Sublevel = Template()\Sublevel
          If Template()\IsDirectory
            IsExpanded = Template()\IsExpanded
            IsEmpty    = 1
            
            Repeat
              If NextElement(Template()) = 0
                AddElement(Template())
                Break
              EndIf
              If Template()\Sublevel <= Sublevel
                InsertElement(Template())
                Break
              EndIf
              IsEmpty = 0 ; at least one item was found
            ForEver
            
            If IsExpanded Or IsEmpty ; only add as child to opened dirs, or if it was new
              Sublevel + 1
            EndIf
          Else
            AddElement(Template())
          EndIf
        EndIf
        
        index = ListIndex(Template())
        
        Template()\Name$ = Name$
        Template()\IsDirectory = 1
        Template()\Sublevel = Sublevel
        Template_FillTree()
        
        SetGadgetState(#GADGET_Template_Tree, index)
      EndIf
      
    Case #GADGET_Template_RemoveDir
      index = GetGadgetState(#GADGET_Template_Tree)
      If index <> -1
        SelectElement(Template(), index)
        If Template()\IsDirectory
          Sublevel = Template()\Sublevel
          If NextElement(Template())
            If Template()\Sublevel > Sublevel ; this is a subitem of the dir
              delete = 0
            Else
              delete = 1 ; directory is empty
            EndIf
            PreviousElement(Template()) ; go back to the current!
          Else
            delete = 1 ; it is the last one in the gadget, so it is empty.
          EndIf
          
          If delete = 0
            If MessageRequester(#ProductName$, Language("Templates","DeleteNonEmpty"), #FLAG_QUESTION|#PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
              delete = 1
            EndIf
          EndIf
          
          If delete
            Template_SaveState()
            Repeat
              DeleteElement(Template())
            Until NextElement(Template()) = 0 Or Template()\Sublevel <= Sublevel
            Template_FillTree()
          EndIf
        EndIf
      EndIf
      
    Case #GADGET_Template_Rename ; not real gadgets, but used for wrappers of the menu
      index = GetGadgetState(#GADGET_Template_Tree)
      If index <> -1
        
        ;         CompilerIf #CompileWindows
        ;           SendMessage_(GadgetID(#GADGET_Template_Tree), #TVM_EDITLABEL, 0, GadgetItemID(#GADGET_Template_Tree, index))
        ;
        ;         CompilerElse
        
        SelectElement(Template(), index)
        If Template()\IsDirectory
          Title$ = Language("Templates","EnterDirName")
        Else
          Title$ = Language("Templates","EnterName")
        EndIf
        Name$ = InputRequester(Language("Templates","Title"), Title$, Template()\Name$)
        If Name$ <> ""
          Template()\Name$ = Name$
          SetGadgetItemText(#GADGET_Template_Tree, index, Name$, 0)
        EndIf
        ;
        ;         CompilerEndIf
        ;
      EndIf
      
      
    Case #GADGET_Template_Use
      Template_Insert()
      
    Case #GADGET_Template_Tree
      If EventType() = #PB_EventType_DragStart
        Template_DragItem = GetGadgetState(#GADGET_Template_Tree)
        If Template_DragItem <> -1
          DragPrivate(#DRAG_Templates, #PB_Drag_Move)
        EndIf
        
      ElseIf EventType() = #PB_EventType_LeftDoubleClick
        Template_Insert()
        
      ElseIf EventType() = #PB_EventType_RightClick
        Template_UpdateGadgetStates()
        If *Entry\IsSeparateWindow
          DisplayPopupMenu(#POPUPMENU_Template, WindowID(*Entry\ToolWindowID))
        Else
          DisplayPopupMenu(#POPUPMENU_Template, WindowID(#WINDOW_Main))
        EndIf
        
      Else
        Template_UpdateGadgetStates()
        
      EndIf
      
    Case #GADGET_Template_Up
      index = GetGadgetState(#GADGET_Template_Tree)
      If index > 0
        SelectElement(Template(), index)
        *Current.Template = @Template()
        
        While PreviousElement(Template())
          If Template()\Sublevel = *Current\Sublevel
            Template_MoveElement(*Current, @Template(), 1)
            Break
          ElseIf Template()\Sublevel < *Current\Sublevel
            Break
          EndIf
        Wend
      EndIf
      
    Case #GADGET_Template_Down
      index = GetGadgetState(#GADGET_Template_Tree)
      If index <> -1
        SelectElement(Template(), index)
        *Current.Template = @Template()
        
        While NextElement(Template())
          If Template()\Sublevel = *Current\Sublevel
            Template_MoveElement(*Current, @Template(), 2)
            Break
          ElseIf Template()\Sublevel < *Current\Sublevel
            Break
          EndIf
        Wend
      EndIf
      
  EndSelect
  
EndProcedure


Procedure Template_PreferenceLoad(*Entry.ToolsPanelEntry)
  
  PreferenceGroup("Templates")
  TemplateWindowPosition\x      = ReadPreferenceLong("WindowX", 100)
  TemplateWindowPosition\y      = ReadPreferenceLong("WindowY", 200)
  TemplateWindowPosition\Width  = ReadPreferenceLong("WindowWidth", 500)
  TemplateWindowPosition\Height = ReadPreferenceLong("WindowHeight", 400)
  Template_Splitter     = ReadPreferenceLong("Splitter", 80)
  Template_Selection    = ReadPreferenceLong("Selection", -1)
  Template_FirstVisible = ReadPreferenceLong("FirstVisible", 0)
  Template_AskDelete    = ReadPreferenceLong("AskDelete", 1)
  
  ; now also read the templates file
  ;
  If ReadFile(#FILE_Template, TemplatesFile$)
    
    If ReadString(#FILE_Template) = "TEMPLATES:1.0"
      
      ClearList(Template())
      AddElement(Template()) ; dummy element at start to avoid crash when file content is inconsistent (removed later)
      sublevel = 0
      
      While Eof(#FILE_Template) = 0
        Line$ = ReadString(#FILE_Template)
        separator = FindString(Line$, ":", 1)
        If separator = 0
          Command$ = UCase(Trim(Line$))
          Value$ = ""
        Else
          Command$ = UCase(Trim(Left(Line$, separator-1)))
          Value$ = Trim(Right(Line$, Len(Line$)-separator))
        EndIf
        
        Select Command$
            
          Case "DIRECTORY"
            AddElement(Template())
            Template()\sublevel = sublevel
            Template()\Name$ = Value$
            Template()\IsDirectory = 1
            sublevel + 1
            
          Case "TEMPLATE"
            AddElement(Template())
            Template()\sublevel = sublevel
            Template()\Name$ = Value$
            
          Case "EXPANDED"
            Template()\IsExpanded = 1
            
          Case "COMMENT"
            Template()\Comment$ = Value$
            
          Case "CODE"
            Template()\Code$ = Value$
            
          Case "CLOSEDIRECTORY"
            sublevel - 1
            If sublevel < 0
              sublevel = 0
            EndIf
            
        EndSelect
        
      Wend
      
      FirstElement(Template())
      DeleteElement(Template()) ; remove the dummy element
      
    EndIf
    
    CloseFile(#FILE_Template)
  EndIf
  
EndProcedure


Procedure Template_PreferenceSave(*Entry.ToolsPanelEntry)
  
  PreferenceComment("")
  PreferenceGroup("Templates")
  WritePreferenceLong("WindowX", TemplateWindowPosition\x)
  WritePreferenceLong("WindowY", TemplateWindowPosition\y)
  WritePreferenceLong("WindowWidth", TemplateWindowPosition\Width)
  WritePreferenceLong("WindowHeight", TemplateWindowPosition\Height)
  WritePreferenceLong("Splitter", Template_Splitter)
  WritePreferenceLong("Selection", Template_Selection)
  WritePreferenceLong("FirstVisible", Template_FirstVisible)
  WritePreferenceLong("AskDelete", Template_AskDelete)
  
  
  ; now also save the templates file as it can have folding states modification
  ;
  Template_Save()
  
EndProcedure


Procedure Template_PreferenceStart(*Entry.ToolsPanelEntry)
  
  Backup_Template_AskDelete = Template_AskDelete
  
EndProcedure


Procedure Template_PreferenceApply(*Entry.ToolsPanelEntry)
  
  Template_AskDelete = Backup_Template_AskDelete
  
EndProcedure


Procedure Template_PreferenceCreate(*Entry.ToolsPanelEntry)
  
  CheckBoxGadget(#GADGET_Preferences_TemplatesAskDelete, 10, 10, 300, 25, Language("Templates","DeletePreference"))
  SetGadgetState(#GADGET_Preferences_TemplatesAskDelete, Backup_Template_AskDelete)
  
  GetRequiredSize(#GADGET_Preferences_TemplatesAskDelete, @Width, @Height)
  ResizeGadget(#GADGET_Preferences_TemplatesAskDelete, 10, 10, Width, Height)
  
EndProcedure


Procedure Template_PreferenceDestroy(*Entry.ToolsPanelEntry)
  
  Backup_Template_AskDelete = GetGadgetState(#GADGET_Preferences_TemplatesAskDelete)
  
EndProcedure


Procedure Template_PreferenceEvents(*Entry.ToolsPanelEntry, EventGadgetID)
  ;
  ; nothing here
  ;
EndProcedure

Procedure Template_PreferenceChanged(*Entry.ToolsPanelEntry, IsConfigOpen)
  
  If IsConfigOpen
    If Template_AskDelete <> GetGadgetState(#GADGET_Preferences_TemplatesAskDelete)
      ProcedureReturn 1
    EndIf
    
  Else
    If Template_AskDelete <> Backup_Template_AskDelete
      ProcedureReturn 1
    EndIf
    
  EndIf
  
  ProcedureReturn 0
EndProcedure



;- Initialisation code
; This will make this Tool available to the editor
;
Template_VT.ToolsPanelFunctions

Template_VT\CreateFunction      = @Template_CreateFunction()
Template_VT\DestroyFunction     = @Template_DestroyFunction()
Template_VT\ResizeHandler       = @Template_ResizeHandler()
Template_VT\EventHandler        = @Template_EventHandler()
Template_VT\PreferenceLoad      = @Template_PreferenceLoad()
Template_VT\PreferenceSave      = @Template_PreferenceSave()
Template_VT\PreferenceStart     = @Template_PreferenceStart()
Template_VT\PreferenceApply     = @Template_PreferenceApply()
Template_VT\PreferenceCreate    = @Template_PreferenceCreate()
Template_VT\PreferenceDestroy   = @Template_PreferenceDestroy()
Template_VT\PreferenceEvents    = @Template_PreferenceEvents()
Template_VT\PreferenceChanged   = @Template_PreferenceChanged()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @Template_VT
AvailablePanelTools()\NeedPreferences      = 1
AvailablePanelTools()\NeedConfiguration    = 1
AvailablePanelTools()\NeedDestroyFunction  = 1 ; to save the file!
AvailablePanelTools()\PreferencesWidth     = 320
AvailablePanelTools()\PreferencesHeight    = 80
AvailablePanelTools()\ToolID$              = "Templates"
AvailablePanelTools()\PanelTitle$          = "TemplatesShort"
AvailablePanelTools()\ToolName$            = "TemplatesLong"
AvailablePanelTools()\ToolMinWindowWidth   = 220
AvailablePanelTools()\ToolMinWindowHeight  = 200

TemplatePlugin = @AvailablePanelTools()


