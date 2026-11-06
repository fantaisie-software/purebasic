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
    #DEBUG_MemoryStats
  EndEnumeration
  
  
  Global Debugging_Combo, Debugging_Editor, Debugging_Display
  
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
            
            
          Case #DEBUG_MemoryStats ; memory stats
            CompilerIf #CompileWindows And  #PB_Compiler_Backend <> #PB_Backend_C
              Protected MemoryBase, MemoryHeap
              
              ; The needed !extrn are in WindowsDebugging.pb already.
              CompilerIf #CompileX86
                !mov eax, dword [_PB_MemoryBase]
                !mov [p.v_MemoryBase], eax
                !mov eax, dword [_PB_Memory_Heap]
                !mov [p.v_MemoryHeap], eax
              CompilerElse
                !mov rax, qword [_PB_MemoryBase]
                !mov [p.v_MemoryBase], rax
                !mov rax, qword [PB_Memory_Heap]
                !mov [p.v_MemoryHeap], rax
              CompilerEndIf
              
              Content$ = "Process Heap:"+#NewLine+"------------------------------"+#NewLine
              Content$ + HeapStats(GetProcessHeap_())+#NewLine+#NewLine
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