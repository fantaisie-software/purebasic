; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
; For easier debugging of IDE internals.
;
; If the #DEBUG constant is set to 1, there is a new menu entry
; "Help->Debugging", which will open this window where some info
; can be viewed about the current source and settings etc.
;
; (more stuff can be added as needed while looking for bugs)
;
;

CompilerIf #DEBUG
  
  Enumeration
    #DEBUG_SourceTokens
    #DEBUG_SortedTokens
    #DEBUG_SortedIssues
    #DEBUG_ProjectTokens
    #DEBUG_CompilerDialog
    #DEBUG_PreferencesDialog
    #DEBUG_FindDialog
    #DEBUG_GrepDialog
    #DEBUG_AddToolsDialog
    #DEBUG_EditToolsDialog
    #DEBUG_MemoryStats
  EndEnumeration
  
  
  Global Debugging_Combo, Debugging_Editor, Debugging_Display
  
  Declare.s DumpDialogHirachy(*Object.DlgBase, Indent)
  
  CompilerIf #CompileWindows
    
    Structure PROCESS_HEAP_ENTRY_Block
      hMem.i
      dwReserved.l[3]
    EndStructure
    
    Structure PROCESS_HEAP_ENTRY_Region
      dwCommittedSize.l
      dwUnCommittedSize.l
      lpFirstBlock.i
      lpLastBlock.i
    EndStructure
    
    Structure PROCESS_HEAP_ENTRY
      lpData.i
      cbData.l
      cbOverhead.b
      iRegionIndex.b
      wFlags.w
      StructureUnion
        Block.PROCESS_HEAP_ENTRY_Block
        Region.PROCESS_HEAP_ENTRY_Region
      EndStructureUnion
    EndStructure
    
    #PROCESS_HEAP_ENTRY_BUSY        = $0004
    #PROCESS_HEAP_ENTRY_DDESHARE    = $0020
    #PROCESS_HEAP_ENTRY_MOVEABLE    = $0010
    #PROCESS_HEAP_REGION            = $0001
    #PROCESS_HEAP_UNCOMMITTED_RANGE = $0002
    
    Procedure.s HeapStats(Heap)
      Protected Entry.PROCESS_HEAP_ENTRY
      Protected Blocks, Size, Overhead
      Protected Uncommitted
      
      HeapLock_(Heap)
      While HeapWalk_(Heap, @Entry)
        If Entry\wFlags & #PROCESS_HEAP_ENTRY_BUSY
          Blocks + 1
          Size + Entry\cbData
          Overhead + Entry\cbOverhead
        ElseIf Entry\wFlags & #PROCESS_HEAP_UNCOMMITTED_RANGE
          Uncommitted + Entry\cbData
        EndIf
      Wend
      HeapUnlock_(Heap)
      
      Result$ = "Allocated Blocks  : " + Str(Blocks) + #NewLine
      If Blocks > 0
        Result$ + "Avg. Block Size   : " + StrByteSize(Size/Blocks) + #NewLine
      EndIf
      Result$ + "Total Memory      : " + StrByteSize(Size) + #NewLine
      Result$ + "Heap Overhead     : " + StrByteSize(Overhead) + #NewLine
      Result$ + "Uncommitted Memory: " + StrByteSize(Uncommitted) + #NewLine
      
      If HeapValidate_(Heap, 0, #Null)
        Result$ + "Heap valiadtion   : Ok" + #NewLine
      Else
        Result$ + "Heap valiadtion   : Failed !!!" + #NewLine
      EndIf
      
      ProcedureReturn Result$
    EndProcedure
    
  CompilerEndIf
  
  Procedure.s DumpDlgBin(*Bin.DlgBinBase, Indent)
    Text$ = Space(Indent) + "Margins = t:"+Str(*Bin\tMargin)+", b:"+Str(*Bin\bMargin)+", l:"+Str(*Bin\lMargin)+", r:"+Str(*Bin\rMargin)+#NewLine
    Text$ + Space(Indent) + "Expand = v:"+Str(*Bin\vExpand)+", h:"+Str(*Bin\hExpand)+"  Align = v:"+Str(*Bin\vAlign)+", h:"+Str(*Bin\hAlign)+#NewLine
    Text$ + Space(Indent) + "Requested Size = "+Str(*Bin\RequestedWidth) + ", "+Str(*Bin\RequestedHeight) + #NewLine
    
    If *Bin\Child
      Text$ + DumpDialogHirachy(*Bin\Child, Indent+2)
    Else
      Text$ + Space(Indent) + "-- no child --"
    EndIf
    
    ProcedureReturn Text$
  EndProcedure
  
  Procedure.s DumpDlgBox(*Box.DlgBoxBase, Indent)
    Text$ = ""
    
    ; those have extra data
    If *Box\StaticData\type = #DIALOG_VBox Or *Box\StaticData\type = #DIALOG_HBox
      *Box2.DlgBox = *Box
      Text$ + Space(Indent) + "Spacing = "+Str(*Box2\Spacing)+", Expand = "+Str(*Box2\Expand)+", Item = "+Str(*Box2\ExpandItem) + ", Align = "+Str(*Box2\Align)+#NewLine
      Text$ + Space(Indent) + "RequestedSize = "+Str(*Box2\RequestedSize) + #NewLine
      
      Text$ + Space(Indent) + "ChildSizes ="
      For i = 0 To *Box\NbChildren-1
        Text$ + " " + Str(*Box2\ChildSizes[i])
      Next i
      Text$ + #NewLine
    EndIf
    
    If *Box\NbChildren = 0
      Text$ + Space(Indent) + "-- no children --"
    Else
      For i = 0 To *Box\NbChildren-1
        Text$ + DumpDialogHirachy(*Box\Children[i], Indent+2)
      Next i
    EndIf
    
    ProcedureReturn Text$
  EndProcedure
  
  Procedure.s DumpDlgGadget(*Gadget.DlgGadget, Name$, Indent)
    Text$ = "----- "+Name$+" -----"+#NewLine
    Text$ + Space(Indent) + "Position = "+Str(GadgetX(*Gadget\Gadget)) + ", "+Str(GadgetY(*Gadget\Gadget)) + ", "+Str(GadgetWidth(*Gadget\Gadget)) + ", "+Str(GadgetHeight(*Gadget\Gadget))+#NewLine
    If *Gadget\HasTitle
      Text$ + Space(Indent) + "Text = "+ReplaceString(GetGadgetText(*Gadget\Gadget), #Newline, "\n") + #NewLine
    EndIf
    
    ProcedureReturn Text$
  EndProcedure
  
  
  Procedure.s DumpDialogHirachy(*Object.DlgBase, Indent)
    Text$ = Space(Indent)
    
    Select *Object\StaticData\type
        
      Case #DIALOG_Window
        *Window.DlgWindow = *Object
        Text$ + "----- Window -----"+#NewLine
        Text$ + Space(Indent) + "Size = "+Str(WindowWidth(*Window\Window)) + ", "+Str(WindowHeight(*Window\Window)) + #NewLine
        Text$ + DumpDlgBin(*Object, Indent)
        
      Case #DIALOG_VBox
        Text$ + "----- VBox -----"+#NewLine
        Text$ + DumpDlgBox(*Object, Indent)
        
      Case #DIALOG_HBox
        Text$ + "----- HBox -----"+#NewLine
        Text$ + DumpDlgBox(*Object, Indent)
        
      Case #DIALOG_Multibox
        Text$ + "----- Multibox -----"+#NewLine
        Text$ + DumpDlgBox(*Object, Indent)
        
      Case #DIALOG_Singlebox
        Text$ + "----- Singlebox -----"+#NewLine
        Text$ + DumpDlgBin(*Object, Indent)
        
      Case #DIALOG_Gridbox
        *Grid.DlgGridBox = *Object
        Text$ + "----- Gridbox -----"+#NewLine
        Text$ + Space(Indent) + "NbColumns = "+Str(*Grid\NbColumns) + ", NbRows = "+Str(*Grid\NbRows) + #NewLine
        Text$ + Space(Indent) + "Spacing = col:"+Str(*Grid\colSpacing)+" row:"+Str(*Grid\rowSpacing)+", Expand = col:"+Str(*Grid\colExpand)+" row:"+Str(*Grid\rowExpand)+", Item = col:"+Str(*Grid\colExpandItem)+" row:"+Str(*Grid\rowExpandItem)+#NewLine
        Text$ + Space(Indent) + "RequestedWidth = "+Str(*Grid\RequestedWidth)+", RequestedHeight = "+Str(*Grid\RequestedHeight)+#NewLine
        
        Text$ + Space(Indent) + "ColSizes ="
        For i = 0 To *Grid\NbColumns-1
          Text$ + " " + Str(*Grid\colSize[i])
        Next i
        Text$ + #NewLine + Space(Indent) + "RowSizes ="
        For i = 0 To *Grid\NbRows-1
          Text$ + " " + Str(*Grid\rowSize[i])
        Next i
        Text$ + #NewLine
        
        For row = 0 To *Grid\NbRows-1
          Text$ + Space(Indent+2) + "===== Gridbox new row =====" + #NewLine
          For col = 0 To *Grid\NbColumns-1
            Child.DialogObject = *GRid\Rows[row]\Cols[col]\Child
            If Child <> #DlgGrid_Empty And Child <> #DlgGrid_Span
              
              Text$ + DumpDialogHirachy(Child, Indent+2)
              
              If *GRid\Rows[row]\Cols[col]\Colspan > 1 Or *GRid\Rows[row]\Cols[col]\Rowspan > 1
                Text$ + Space(Indent+2)+"(Gridbox: Colspan = "+Str(*GRid\Rows[row]\Cols[col]\Colspan)+", Rowspan = "+Str(*GRid\Rows[row]\Cols[col]\Rowspan)+")"+#NewLine
              EndIf
              
            EndIf
          Next col
        Next row
        
        
      Case #DIALOG_Empty
        Text$ + "----- Empty -----"+#NewLine
        
      Case #DIALOG_Button:      Text$ + DumpDlgGadget(*Object, "Button", Indent)
      Case #DIALOG_Checkbox:    Text$ + DumpDlgGadget(*Object, "Checkbox", Indent)
      Case #DIALOG_Image:       Text$ + DumpDlgGadget(*Object, "Image", Indent)
      Case #DIALOG_Option:      Text$ + DumpDlgGadget(*Object, "Option", Indent)
      Case #DIALOG_ListView:    Text$ + DumpDlgGadget(*Object, "ListView", Indent) ; we ignore the <item> and <column> entries in this display
      Case #DIALOG_ListIcon:    Text$ + DumpDlgGadget(*Object, "ListIcon", Indent)
      Case #DIALOG_Tree:        Text$ + DumpDlgGadget(*Object, "Tree", Indent)
      Case #DIALOG_ComboBox:    Text$ + DumpDlgGadget(*Object, "ComboBox", Indent)
      Case #DIALOG_Text:        Text$ + DumpDlgGadget(*Object, "Text", Indent)
      Case #DIALOG_String:      Text$ + DumpDlgGadget(*Object, "String", Indent)
      Case #DIALOG_Editor:      Text$ + DumpDlgGadget(*Object, "Editor", Indent)
      Case #DIALOG_Scintilla:   Text$ + DumpDlgGadget(*Object, "Scintilla", Indent)
      Case #DIALOG_ScrollBar:   Text$ + DumpDlgGadget(*Object, "ScrollBar", Indent)
      Case #DIALOG_ProgressBar: Text$ + DumpDlgGadget(*Object, "ProgressBar", Indent)
        
      Case #DIALOG_Container
        Text$ + "----- Container -----"+#NewLine
        Text$ + DumpDlgBin(*Object, Indent)
        
      Case #DIALOG_Panel
        Text$ + "----- Panel -----"+#NewLine
        Text$ + DumpDlgBox(*Object, Indent)
        
      Case #DIALOG_Tab
        *Tab.DlgTab = *Object
        Text$ + "----- Tab -----"+#NewLine
        Text$ + Space(Indent) + "Title = "+GetGadgetItemText(*Tab\ParentGadget, *Tab\ItemIndex) + #NewLine
        Text$ + DumpDlgBin(*Object, Indent)
        
      Case #DIALOG_Scroll
        *Scroll.DlgScroll = *Object
        Text$ + "----- ScrollArea -----"+#NewLine
        Text$ + Space(Indent) + "InnerWidth = "+Str(*Scroll\InnerWidth) + ", InnerHeight = "+Str(*Scroll\InnerHeight) + ", Scrolling = "+Str(*Scroll\Scrolling)+#NewLine
        Text$ + DumpDlgBin(*Object, Indent)
        
      Case #DIALOG_Frame
        *Frame.DlgFrame = *Object
        Text$ + "----- Frame -----"+#NewLine
        Text$ + Space(Indent) + "Title = "+GetGadgetText(*Frame\Gadget) + #NewLine
        Text$ + Space(Indent) + "Boder = t:"+Str(*Frame\BorderTop)+", b:"+Str(*Frame\BorderBottom)+", l:"+Str(*Frame\BorderLeft)+", r:"+Str(*Frame\BorderRight)+#NewLine
        Text$ + DumpDlgBin(*Object, Indent)
        
        
    EndSelect
    
    ProcedureReturn Text$
  EndProcedure
  
  Procedure DebuggingWindowEvents(EventID)
    Static NewList *Items()
    
    If EventID = #PB_Event_Gadget
      If EventGadget() = Debugging_Display
        
        Content$ = ""
        
        Select GetGadgetState(Debugging_Combo) ; specifies the action
            
          Case #DEBUG_SourceTokens ; sourcetoken list
            
            If *ActiveSource\Parser\SourceItemArray
              If *ActiveSource\Parser\SourceItemCount > 0
                length = Len(Str(*ActiveSource\Parser\SourceItemCount))
                
                For i = 0 To *ActiveSource\Parser\SourceItemCount-1
                  Content$ + RSet(Str(i+1), length, " ")
                  
                  *Item.SourceItem = *ActiveSource\Parser\SourceItemArray\Line[i]\First
                  While *Item
                    Select *Item\Type
                      Case #ITEM_Keyword         : Kind$ = "Keyword("+BasicKeywordsReal(*Item\Keyword)+")"
                      Case #ITEM_Procedure       : Kind$ = "Procedure"
                      Case #ITEM_Macro           : Kind$ = "Macro"
                      Case #ITEM_CommentMark     : Kind$ = "Marker"
                      Case #ITEM_Issue           : Kind$ = "Issue"
                      Case #ITEM_Structure       : Kind$ = "Structure"
                      Case #ITEM_Interface       : Kind$ = "Interface"
                      Case #ITEM_Constant        : Kind$ = "Constant"
                      Case #ITEM_Variable        : Kind$ = "Variable"
                      Case #ITEM_Array           : Kind$ = "Array"
                      Case #ITEM_LinkedList      : Kind$ = "LinkedList"
                      Case #ITEM_Import          : Kind$ = "Import"
                      Case #ITEM_FoldStart       : Kind$ = "FoldStart"
                      Case #ITEM_FoldEnd         : Kind$ = "FoldEnd"
                      Case #ITEM_MacroEnd        : Kind$ = "MacroEnd"
                      Case #ITEM_ProcedureEnd    : Kind$ = "ProcedureEnd"
                      Case #ITEM_InlineASM       : Kind$ = "InlineASM"
                      Case #ITEM_InlineASMEnd    : Kind$ = "InlineASMEnd"
                      Case #ITEM_Declare         : Kind$ = "Declare"
                      Case #ITEM_Define          : Kind$ = "Define"
                      Case #ITEM_Prototype       : Kind$ = "Prototype"
                      Case #ITEM_Label           : Kind$ = "Label"
                      Case #ITEM_Map             : Kind$ = "Map"
                      Case #ITEM_UnknownBraced   : Kind$ = "UnknownBraced"
                      Case #ITEM_DeclareModule   : Kind$ = "DeclareModule"
                      Case #ITEM_EndDeclareModule: Kind$ = "EndDeclareModule"
                      Case #ITEM_Module          : Kind$ = "Module"
                      Case #ITEM_EndModule       : Kind$ = "EndModule"
                      Case #ITEM_UseModule       : Kind$ = "UseModule"
                      Case #ITEM_UnuseModule     : Kind$ = "UnuseModule"
                      Default                    : Kind$ = "Unknown("+Str(*Item\Type)+")"
                    EndSelect
                    If *Item\ModulePrefix$ = ""
                      Prefix$ = ""
                    Else
                      Prefix$ = *Item\ModulePrefix$ + "::"
                    EndIf
                    Content$ + " -> ["+Str(*Item\Position)+"] "+Kind$+"="+Prefix$+*Item\Name$+" "+*Item\StringData$
                    *Item = *Item\Next
                  Wend
                  
                  Content$ + #NewLine
                Next i
                
              Else
                Content$ = "-- Array count is 0 --"
              EndIf
            Else
              Content$ = "-- Array pointer is 0 --"
            EndIf
            
          Case #DEBUG_SortedTokens ; sorted source tokens
            SortParserData(@*ActiveSource\Parser) ; ensure it is up to date
            Content$ = ""
            
            ForEach *ActiveSource\Parser\Modules()
              Content$ + #NewLine + "=================== Module: " + MapKey(*ActiveSource\Parser\Modules()) + " =======================" + #NewLine
              
              For Type = 0 To #ITEM_LastSorted
                Select Type
                  Case #ITEM_Procedure : Title$ = "----- Procedures -----"
                  Case #ITEM_Macro     : Title$ = "----- Macros -----"
                  Case #ITEM_Declare   : Title$ = "----- Declares -----"
                  Case #ITEM_Structure : Title$ = "----- Structures -----"
                  Case #ITEM_Interface : Title$ = "----- Interfaces -----"
                  Case #ITEM_Prototype : Title$ = "----- Prototypes -----"
                  Case #ITEM_Constant  : Title$ = "----- Constants -----"
                  Case #ITEM_Variable  : Title$ = "----- Variables -----"
                  Case #ITEM_Array     : Title$ = "----- Arrays -----"
                  Case #ITEM_LinkedList: Title$ = "----- LinkedLists -----"
                  Case #ITEM_Label     : Title$ = "----- Labels -----"
                  Case #ITEM_Import    : Title$ = "----- Imports -----"
                  Case #ITEM_Map       : Title$ = "----- Maps -----"
                  Default              : Title$ = "----- Unknown type -----"
                EndSelect
                
                RadixEnumerateAll(*ActiveSource\Parser\Modules()\Indexed[Type], *Items())
                If ListSize(*Items()) > 0
                  Content$ + #NewLine + Title$ + #NewLine
                  ForEach *Items()
                    *Item.SourceItem = *Items()
                    Content$ + *Item\Name$ + " " + *Item\StringData$ + #NewLine
                  Next *Items()
                EndIf
              Next Type
            Next *ActiveSource\Parser\Modules()
            
          Case #DEBUG_SortedIssues
            SortParserData(@*ActiveSource\Parser) ; ensure it is up to date
            Content$ = ""
            *Item.SourceItem = *ActiveSource\Parser\SortedIssues
            While *Item
              Content$ + "Line=" + Str(*Item\SortedLine + 1) + ", Issue=" + *Item\Issue + ", Text=" + *Item\Name$ + #NewLine
              *Item = *Item\NextSorted
            Wend
            
          Case #DEBUG_ProjectTokens
            Content$ = ""
            If IsProject
              If ListSize(ProjectFiles()) > 0
                ForEach ProjectFiles()
                  Content$ + "  #####################################################" + #NewLine
                  Content$ + "  " + ProjectFiles()\FileName$
                  
                  If ProjectFiles()\Source
                    Content$ + "  (loaded)" + #NewLine
                    *Parser.ParserData = @ProjectFiles()\Source\Parser
                    SortParserData(*Parser, ProjectFiles()\Source)
                  Else
                    Content$ + #NewLine
                    *Parser.ParserData = @ProjectFiles()\Parser
                    SortParserData(*Parser)
                  EndIf
                  
                  Content$ + "  #####################################################" + #NewLine
                  
                  ForEach *Parser\Modules()
                    Content$ + #NewLine + "=================== Module: " + MapKey(*Parser\Modules()) + " =======================" + #NewLine
                    
                    For Type = 0 To #ITEM_LastSorted
                      Select Type
                        Case #ITEM_Procedure : Title$ = "----- Procedures -----"
                        Case #ITEM_Macro     : Title$ = "----- Macros -----"
                        Case #ITEM_Declare   : Title$ = "----- Declares -----"
                        Case #ITEM_Structure : Title$ = "----- Structures -----"
                        Case #ITEM_Interface : Title$ = "----- Interfaces -----"
                        Case #ITEM_Prototype : Title$ = "----- Prototypes -----"
                        Case #ITEM_Constant  : Title$ = "----- Constants -----"
                        Case #ITEM_Variable  : Title$ = "----- Variables -----"
                        Case #ITEM_Array     : Title$ = "----- Arrays -----"
                        Case #ITEM_LinkedList: Title$ = "----- LinkedLists -----"
                        Case #ITEM_Label     : Title$ = "----- Labels -----"
                        Case #ITEM_Import    : Title$ = "----- Imports -----"
                        Case #ITEM_Map       : Title$ = "----- Maps -----"
                        Default              : Title$ = "----- Unknown type -----"
                      EndSelect
                      
                      RadixEnumerateAll(*Parser\Modules()\Indexed[Type], *Items())
                      If ListSize(*Items()) > 0
                        Content$ + #NewLine + Title$ + #NewLine
                        ForEach *Items()
                          *Item.SourceItem = *Items()
                          Content$ + *Item\Name$ + " " + *Item\StringData$ + #NewLine
                        Next *Items()
                      EndIf
                    Next Type
                  Next *Parser\Modules()
                  
                Next ProjectFiles()
              Else
                Content$ = "-- No project files --"
              EndIf
            Else
              Content$ = "-- No current project --"
            EndIf
            
            
          Case #DEBUG_CompilerDialog ; DialogHirachy - OptionWindow
            If IsWindow(#WINDOW_Option)
              Content$ = DumpDialogHirachy(OptionWindowDialog, 0) ; the main object is directly the DlgWindow object
            Else
              Content$ = "-- Compiler Window not open --"
            EndIf
            
          Case #DEBUG_PreferencesDialog ; DialogHirachy - Preferences
            If IsWindow(#WINDOW_Preferences)
              Content$ = DumpDialogHirachy(PreferenceWindowDialog, 0) ; the main object is directly the DlgWindow object
            Else
              Content$ = "-- Preferences Window not open --"
            EndIf
            
          Case #DEBUG_FindDialog ; DialogHirachy - Find
            If IsWindow(#WINDOW_Find)
              Content$ = DumpDialogHirachy(FindWindowDialog, 0) ; the main object is directly the DlgWindow object
            Else
              Content$ = "-- Find Window not open --"
            EndIf
            
          Case #DEBUG_GrepDialog ; DialogHirachy - Grep
            If IsWindow(#WINDOW_Grep)
              Content$ = DumpDialogHirachy(GrepWindowDialog, 0) ; the main object is directly the DlgWindow object
            Else
              Content$ = "-- Grep Window not open --"
            EndIf
            
          Case #DEBUG_AddToolsDialog ; DialogHirachy - AddTools
            If IsWindow(#WINDOW_AddTools)
              Content$ = DumpDialogHirachy(AddToolsWindowDialog, 0) ; the main object is directly the DlgWindow object
            Else
              Content$ = "-- AddTools Window not open --"
            EndIf
            
          Case #DEBUG_EditToolsDialog ; DialogHirachy - EditTools
            If IsWindow(#WINDOW_EditTools)
              Content$ = DumpDialogHirachy(EditToolsWindowDialog, 0) ; the main object is directly the DlgWindow object
            Else
              Content$ = "-- EditTools Window not open --"
            EndIf
            
          Case #DEBUG_MemoryStats ; memory stats
            CompilerIf #CompileWindows And  #PB_Compiler_Backend <> #PB_Backend_C
              Protected StringHeap, MemoryBase, MemoryHeap
              
              ; The needed !extrn are in WindowsDebugging.pb already.
              CompilerIf #CompileX86
                !mov eax, dword [_PB_StringHeap]
                !mov [p.v_StringHeap], eax
                !mov eax, dword [_PB_MemoryBase]
                !mov [p.v_MemoryBase], eax
                !mov eax, dword [_PB_Memory_Heap]
                !mov [p.v_MemoryHeap], eax
              CompilerElse
                !mov rax, qword [PB_StringHeap]
                !mov [p.v_StringHeap], rax
                !mov rax, qword [_PB_MemoryBase]
                !mov [p.v_MemoryBase], rax
                !mov rax, qword [PB_Memory_Heap]
                !mov [p.v_MemoryHeap], rax
              CompilerEndIf
              
              Content$ = "Process Heap:"+#NewLine+"------------------------------"+#NewLine
              Content$ + HeapStats(GetProcessHeap_())+#NewLine+#NewLine
              Content$ + "String Heap:"+#NewLine+"------------------------------"+#NewLine
              Content$ + HeapStats(StringHeap)+#NewLine+#NewLine
              Content$ + "MemoryBase Heap:"+#NewLine+"------------------------------"+#NewLine
              Content$ + HeapStats(MemoryBase)+#NewLine+#NewLine
              Content$ + "AllocateMemory Heap:"+#NewLine+"------------------------------"+#NewLine
              Content$ + HeapStats(MemoryHeap)+#NewLine+#NewLine
              
              Dim AllHeaps.i(100)
              NumHeaps = GetProcessHeaps_(101, @AllHeaps())
              Unknown  = 1
              
              For i = 0 To NumHeaps-1
                If AllHeaps(i) <> StringHeap And AllHeaps(i) <> MemoryBase And AllHeaps(i) <> MemoryHeap And AllHeaps(i) <> GetProcessHeap_()
                  Content$ + "Unknown Heap #"+Str(Unknown)+#NewLine+"------------------------------"+#NewLine
                  Content$ + HeapStats(AllHeaps(i))+#NewLine+#NewLine
                  Unknown + 1
                EndIf
              Next i
              
              
              
            CompilerElse
              Content$ = "-- Windows ASM only --"
            CompilerEndIf
            
        EndSelect
        
        SetGadgetText(Debugging_Editor, Content$)
        
      EndIf
      
    ElseIf EventID = #PB_Event_SizeWindow
      w = WindowWidth(#WINDOW_Debugging)
      h = WindowHeight(#WINDOW_Debugging)
      c = GetRequiredHeight(Debugging_Combo)
      
      ResizeGadget(Debugging_Combo, 10, 10, w-180, c)
      ResizeGadget(Debugging_Display, w-160, 10, 150, c)
      ResizeGadget(Debugging_Editor, 10, c+20, w-20, h-c-30)
      
    ElseIf EventID = #PB_Event_CloseWindow
      CloseWindow(#WINDOW_Debugging)
      
    EndIf
    
  EndProcedure
  
  Procedure OpenDebuggingWindow()
    
    If IsWindow(#WINDOW_Debugging)
      SetWindowforeground(#WINDOW_Debugging)
      
    ElseIf OpenWindow(#WINDOW_Debugging, 0, 0, 600, 400, #ProductName$ + " - IDE Debugging", #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_Invisible)
      
      Debugging_Combo   = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
      Debugging_Display = ButtonGadget(#PB_Any, 0, 0, 0, 0, "Display")
      Debugging_Editor  = EditorGadget(#PB_Any, 0, 0, 0, 0, #PB_Editor_ReadOnly)
      
      AddGadgetItem(Debugging_Combo, -1, "SourceToken Array")
      AddGadgetItem(Debugging_Combo, -1, "SourceToken Sorted Lists")
      AddGadgetItem(Debugging_Combo, -1, "SourceToken Sorted Issues")
      AddGadgetItem(Debugging_Combo, -1, "ProjectFiles SourceToken Sorted Lists")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Compiler Options")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Preferences")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Find")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Grep")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Config Tools")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Edit Tool")
      AddGadgetItem(Debugging_Combo, -1, "DialogManager - Sort Sources")
      AddGadgetItem(Debugging_Combo, -1, "Memory Stats (Windows Only)")
      
      SetGadgetState(Debugging_Combo, 0)
      
      CompilerIf #CompileWindows
        SetGadgetFont(Debugging_Editor, GetStockObject_(#ANSI_FIXED_FONT))
      CompilerEndIf
      
      DebuggingWindowEvents(#PB_Event_SizeWindow)
      HideWindow(#WINDOW_Debugging, 0)
      
    EndIf
    
  EndProcedure
  
CompilerEndIf