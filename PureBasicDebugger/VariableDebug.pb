; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Declare VariableWindowSort(*Debugger.DebuggerData, Gadget)

Structure Variable_SortData
  Type.l
  Direction.l
  *Values.Local_Array
EndStructure

; Platformspecific sort stuff
;
CompilerIf #CompileWindows
  ; See VariableGadget.pb for the ListIconData structure
  ;
  Procedure Variable_SortProc(*data1.ListIconData, *data2.ListIconData, *Values.Variable_SortData)
    If *data1 = 0 Or *data2 = 0 ; may not happen
      ProcedureReturn 0
      
    ElseIf *Values\Type = 0 ; string type
      ProcedureReturn CompareMemoryString(*Values\Values\p[*data1\UserData], *Values\Values\p[*data2\UserData], #PB_String_NoCase) * *Values\Direction
      
    Else ; integer type
      If *Values\Values\q[*data1\UserData] = *Values\Values\q[*data2\UserData]
        ProcedureReturn 0
      ElseIf *Values\Values\q[*data1\UserData] < *Values\Values\q[*data2\UserData]
        ProcedureReturn (-1) * *Values\Direction
      Else
        ProcedureReturn *Values\Direction
      EndIf
      
    EndIf
  EndProcedure
  
  ; used SetWindowCallback() here, not subclassing
  Procedure Variable_WindowCallback(Window, Message, wParam, lParam)
    Result = #PB_ProcessPureBasicEvents
    
    If Message = #WM_NOTIFY
      *nmv.NM_LISTVIEW = lParam
      If *nmv\hdr\code = #LVN_COLUMNCLICK
        Column = *nmv\iSubItem
        
        ForEach RunningDebuggers()
          If RunningDebuggers()\Windows[#DEBUGGER_WINDOW_Variable] <> 0
            *Debugger.DebuggerData = @RunningDebuggers()
            
            Select *nmv\hdr\hwndFrom
                
              Case GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo])
                If *Debugger\ArraySortColumn = Column
                  *Debugger\ArraySortDirection * -1
                Else
                  *Debugger\ArraySortColumn = Column
                  *Debugger\ArraySortDirection = 1
                EndIf
                VariableWindowSort(*Debugger, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo])
                Break
                
              Case GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo])
                If *Debugger\LocalArraySortColumn = Column
                  *Debugger\LocalArraySortDirection * -1
                Else
                  *Debugger\LocalArraySortColumn = Column
                  *Debugger\LocalArraySortDirection = 1
                EndIf
                VariableWindowSort(*Debugger, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo])
                Break
                
              Case GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo])
                If *Debugger\ListSortColumn = Column
                  *Debugger\ListSortDirection * -1
                Else
                  *Debugger\ListSortColumn = Column
                  *Debugger\ListSortDirection = 1
                EndIf
                VariableWindowSort(*Debugger, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo])
                Break
                
              Case GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo])
                If *Debugger\LocalListSortColumn = Column
                  *Debugger\LocalListSortDirection * -1
                Else
                  *Debugger\LocalListSortColumn = Column
                  *Debugger\LocalListSortDirection = 1
                EndIf
                VariableWindowSort(*Debugger, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo])
                Break
                
              Case GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo])
                If *Debugger\MapSortColumn = Column
                  *Debugger\MapSortDirection * -1
                Else
                  *Debugger\MapSortColumn = Column
                  *Debugger\MapSortDirection = 1
                EndIf
                VariableWindowSort(*Debugger, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo])
                Break
                
              Case GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo])
                If *Debugger\LocalMapSortColumn = Column
                  *Debugger\LocalMapSortDirection * -1
                Else
                  *Debugger\LocalMapSortColumn = Column
                  *Debugger\LocalMapSortDirection = 1
                EndIf
                VariableWindowSort(*Debugger, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo])
                Break
                
            EndSelect
          EndIf
        Next RunningDebuggers()
      EndIf
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
CompilerEndIf

; Sort one of the 4 Array/List info gadgets
;
Procedure VariableWindowSort(*Debugger.DebuggerData, Gadget)
  Select Gadget
    Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo]
      Column    = *Debugger\ArraySortColumn
      Direction = *Debugger\ArraySortDirection
      Type      = 0 ; string
      
    Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo]
      Column    = *Debugger\LocalArraySortColumn
      Direction = *Debugger\LocalArraySortDirection
      Type      = 0 ; string
      
    Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo]
      Column    = *Debugger\ListSortColumn
      Direction = *Debugger\ListSortDirection
      If Column > 1
        Type    = 1 ; integer
      Else
        Type    = 0 ; string
      EndIf
      
    Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo]
      Column    = *Debugger\LocalListSortColumn
      Direction = *Debugger\LocalListSortDirection
      If Column > 1
        Type    = 1 ; integer
      Else
        Type    = 0 ; string
      EndIf
      
    Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo]
      Column    = *Debugger\MapSortColumn
      Direction = *Debugger\MapSortDirection
      If Column > 1
        Type    = 1 ; integer
      Else
        Type    = 0 ; string
      EndIf
      
    Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo]
      Column    = *Debugger\LocalMapSortColumn
      Direction = *Debugger\LocalMapSortDirection
      If Column > 1
        Type    = 1 ; integer
      Else
        Type    = 0 ; string
      EndIf
      
    Default
      ProcedureReturn
      
  EndSelect
  
  Count = CountGadgetItems(Gadget)
  
  If Column = -1 Or Count = 0
    CompilerIf #CompileWindows
      SetSortArrow(Gadget, Column, Direction)
    CompilerEndIf
    
    ProcedureReturn
  EndIf
  
  SortData.Variable_SortData
  SortData\Type = Type
  SortData\Direction = Direction
  
  If Type = 0 ; string
    Protected Dim StringSort$(Count)
    
    For i = 0 To Count-1
      index = GetGadgetItemData(Gadget, i)
      StringSort$(index) = GetGadgetItemText(Gadget, i, Column) ; use the set index
      If Left(StringSort$(index), 1) = "*"
        ; ignore the * in front, just like the VariableGadget sort
        StringSort$(index) = Right(StringSort$(index), Len(StringSort$(index))-1)
      EndIf
    Next i
    
    SortData\Values = @StringSort$()
    
  Else ; integer
    Protected Dim IntegerSort.q(Count)
    
    For i = 0 To Count-1
      String$ = GetGadgetItemText(Gadget, i, Column)
      If String$ = "-"
        IntegerSort(GetGadgetItemData(Gadget, i)) = -1
      Else
        IntegerSort(GetGadgetItemData(Gadget, i)) = Val(String$)
      EndIf
    Next i
    
    SortData\Values = @IntegerSort()
    
  EndIf
  
  CompilerIf #CompileWindows
    SendMessage_(GadgetID(Gadget), #LVM_SORTITEMS, @SortData, @Variable_SortProc())
    SetSortArrow(Gadget, Column, Direction)
  CompilerEndIf
  
EndProcedure

Procedure.s VariableListElement(*Debugger.DebuggerData, Gadget, index)
  Shared *VariableGadget_Used.VariableGadget ; to access the variable gadget data structure
  
  If Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global] Or Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local] Or Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer]
    ; These are VariableGadget gadgets, so structures are possible
    ;
    index = VariableGadget_GadgetIndexToReal(Gadget, index)
    VariableGadget_Use(Gadget)
    *items.VariableGadget_ItemList = *VariableGadget_Used\Items
    
    If *items\item[index]\Sublevel > 0 ; its a structure element
      Subitem$ = "\" + StringField(Trim(*items\item[index]\Name$), 1, ".") ; cut structure name
      
      If *items\item[index]\Kind <> 0
        ; Only the selected item can be a dynamic element, as we do not
        ; recurse into them on structure display, none of its parents can be one
        Subitem$ + "()" ; for resolving in the debugger
      EndIf
      
      x = index
      While *items\item[x]\Sublevel > 0 And x >= 0
        ; skip to the parent element
        Sublevel = *items\item[x]\Sublevel
        While *items\item[x]\Sublevel >= SubLevel And x >= 0: x - 1: Wend
        If x <> -1
          If *items\item[x]\Sublevel = 0
            ; its the parent
            BaseItem$ = Trim(*items\item[x]\Name$)
          Else
            Subitem$ = "\" + StringField(Trim(*items\item[x]\Name$), 1, ".") + Subitem$
          EndIf
        EndIf
      Wend
    Else
      BaseItem$ = Trim(*items\item[index]\Name$)
      SubItem$ = ""
    EndIf
    
    If FindString(BaseItem$, "(", 1) = 0
      ; cut any structure name if the base is not a list etc
      BaseItem$ = StringField(BaseItem$, 1, ".")
    EndIf
    
    Debug "Resolved element name: " + BaseItem$ + SubItem$
    ProcedureReturn BaseItem$ + SubItem$
    
  Else
    ; These are just the Array, Map, List info gadgets, Only single names are possible
    ;
    Name$ = GetGadgetItemText(Gadget, index, 1)
    Name$ = Left(Name$, FindString(Name$, "(", 0)-1)
    If FindString(Name$, ".", 1) ; remove structure name too
      Name$ = Left(Name$, FindString(Name$, ".", 0)-1)
    EndIf
    Name$ + "()" ; needs to end in () for the expression resolving
    
    ProcedureReturn Name$
  EndIf
  
EndProcedure

Procedure VariableWindowEvents(*Debugger.DebuggerData, EventID)
  Static PopupVariableGadget
  Shared *VariableGadget_Used.VariableGadget ; to access the variable gadget data structure
  
  If EventID = #PB_Event_Menu
    Select EventMenu()
        
      Case #DEBUGGER_MENU_WatchlistAdd
        If IsGadget(PopupVariableGadget)
          index = GetGadgetState(PopupVariableGadget)
          If index <> -1
            Variable$ = VariableListElement(*Debugger, PopupVariableGadget, index)
            
            If Variable$ <> ""
              Command.CommandInfo\Command = #COMMAND_WatchlistAdd
              
              ; local variables? (include the procedure index)
              ;
              If PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local]
                VariableGadget_Use(PopupVariableGadget)
                Command\Value1 = *VariableGadget_Used\CustomData
              Else
                Command\Value1 = -1
              EndIf
              
              Command\Value2 = 1 ; report error messages
              Command\DataSize = StringByteLength(Variable$, #PB_UTF8)+1
              
              *Buffer = AllocateMemory(Command\DataSize)
              If *Buffer
                PokeS(*Buffer, Variable$, -1, #PB_UTF8)
                SendDebuggerCommandWithData(*Debugger, @Command, *Buffer)
                FreeMemory(*Buffer)
              EndIf
              
              Command.CommandInfo\Command = #COMMAND_GetWatchlist
              SendDebuggerCommand(*Debugger, @Command)
            EndIf
          EndIf
        EndIf
        
      Case #DEBUGGER_MENU_CopyVariable
        If IsGadget(PopupVariableGadget)
          index = GetGadgetState(PopupVariableGadget)
          If index <> -1
            Variable$ = VariableListElement(*Debugger, PopupVariableGadget, index)
            
            If Variable$
              VariableGadget_Use(PopupVariableGadget)
              index = VariableGadget_GadgetIndexToReal(PopupVariableGadget, index)
              *items.VariableGadget_ItemList = *VariableGadget_Used\Items
              
              If *items\item[index]\Value$ <> ""
                Variable$ + " = " + *items\item[index]\Value$
              EndIf
              SetClipboardText(Variable$)
            EndIf
          EndIf
        EndIf
        
      Case #DEBUGGER_MENU_ViewAll
        If IsGadget(PopupVariableGadget)
          item = GetGadgetState(PopupVariableGadget)
          If item <> -1
            Command.CommandInfo\Command = #COMMAND_GetArrayListData
            Command\Value1 = 0
            
            If PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global]
              Command\Value2 = 1 ; we explicitly ask to give global names the priority when searching.
            Else
              Command\Value2 = 0
            EndIf
            
            Name$ = VariableListElement(*Debugger, PopupVariableGadget, item)
            Command\DataSize = StringByteLength(Name$)+#CharSize
            SendDebuggerCommandWithData(*Debugger, @Command, @Name$)
            
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], 1)
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems], 0)
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange], 0)
            DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], 1)
          EndIf
        EndIf
        
      Case #DEBUGGER_MENU_ViewNonZero
        If IsGadget(PopupVariableGadget)
          item = GetGadgetState(PopupVariableGadget)
          If item <> -1
            Command.CommandInfo\Command = #COMMAND_GetArrayListData
            Command\Value1 = 1
            
            If PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global]
              Command\Value2 = 1 ; we explicitly ask to give global names the priority when searching.
            Else
              Command\Value2 = 0
            EndIf
            
            Name$ = VariableListElement(*Debugger, PopupVariableGadget, item)
            Command\DataSize = StringByteLength(Name$)+#CharSize
            SendDebuggerCommandWithData(*Debugger, @Command, @Name$)
            
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], 0)
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems], 1)
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange], 0)
            DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], 1)
          EndIf
        EndIf
        
      Case #DEBUGGER_MENU_ViewRange
        If IsGadget(PopupVariableGadget)
          item = GetGadgetState(PopupVariableGadget)
          If item <> -1
            Command.CommandInfo\Command = #COMMAND_GetArrayListData
            Command\Value1 = 2
            
            If PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo] Or PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global]
              Command\Value2 = 1 ; we explicitly ask to give global names the priority when searching.
            Else
              Command\Value2 = 0
            EndIf
            
            Name$ = VariableListElement(*Debugger, PopupVariableGadget, item)
            Range$ = InputRequester(Language("Debugger","ViewArrayList"), Language("Debugger","EnterRange")+":", "")
            
            If Range$ <> ""
              size = StringByteLength(Name$) + StringByteLength(Range$) + 2*#CharSize
              *buffer = AllocateMemory(size)
              If *buffer
                PokeS(*buffer, Name$)
                PokeS(*buffer + StringByteLength(Name$)+#CharSize, Range$)
                
                Command\DataSize = size
                SendDebuggerCommandWithData(*Debugger, @Command, *buffer)
                FreeMemory(*buffer)
              EndIf
              
              SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], 0)
              SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems], 0)
              SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange], 1)
              DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], 0)
              SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], Range$)
            EndIf
          EndIf
        EndIf
        
    EndSelect
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter]
        If GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_FirstGadget) = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer] Or GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_SecondGadget) = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer]
          ContainerWidth = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
          ContainerHeight = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
          If ContainerWidth > 20+300
            ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], (ContainerWidth-300) / 2, (ContainerHeight-20)/2, 300, 20)
          Else
            ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], 10, (ContainerHeight-20)/2, ContainerWidth-20, 20)
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global]
        VariableGadget_Event(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
        If EventType() = #PB_EventType_RightClick
          PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global]
          index = VariableGadget_GadgetIndexToReal(PopupVariableGadget, GetGadgetState(PopupVariableGadget))
          If index <> -1
            VariableGadget_Use(PopupVariableGadget)
            *items.VariableGadget_ItemList = *VariableGadget_Used\Items
            
            If *items\item[index]\Kind = 0 ; no dynamic element
              DisplayPopupMenu(#POPUPMENU_VariableViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            Else  ; dynamic element, use different menu
              DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            EndIf
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local]
        VariableGadget_Event(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
        If EventType() = #PB_EventType_RightClick
          PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local]
          index = VariableGadget_GadgetIndexToReal(PopupVariableGadget, GetGadgetState(PopupVariableGadget))
          If index <> -1
            VariableGadget_Use(PopupVariableGadget)
            *items.VariableGadget_ItemList = *VariableGadget_Used\Items
            
            If *items\item[index]\Kind = 0 ; no dynamic element
              DisplayPopupMenu(#POPUPMENU_VariableViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            Else  ; dynamic element, use different menu
              DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            EndIf
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer]
        VariableGadget_Event(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        If EventType() = #PB_EventType_RightClick
          PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer]
          index = VariableGadget_GadgetIndexToReal(PopupVariableGadget, GetGadgetState(PopupVariableGadget))
          If index <> -1
            VariableGadget_Use(PopupVariableGadget)
            *items.VariableGadget_ItemList = *VariableGadget_Used\Items
            
            If *items\item[index]\Kind <> 0 ; dynamic element
              DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            EndIf
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo]
        If EventType() = #PB_EventType_RightClick
          If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo]) <> -1
            DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo]
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo]
        If EventType() = #PB_EventType_RightClick
          If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo]) <> -1
            DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo]
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo]
        If EventType() = #PB_EventType_RightClick
          If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo]) <> -1
            DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo]
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo]
        If EventType() = #PB_EventType_RightClick
          If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo]) <> -1
            DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo]
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo]
        If EventType() = #PB_EventType_RightClick
          If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo]) <> -1
            DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo]
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo]
        If EventType() = #PB_EventType_RightClick
          If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo]) <> -1
            DisplayPopupMenu(#POPUPMENU_ArrayViewer, WindowID(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]))
            PopupVariableGadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo]
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update]
        If *Debugger\ProgramState <> -1
          ; send the update command
          ;
          Command.CommandInfo\Command = #COMMAND_GetGlobals
          SendDebuggerCommand(*Debugger, @Command)
          
          Command.CommandInfo\Command = #COMMAND_GetLocals
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray]
        If *Debugger\ProgramState <> -1
          Command.CommandInfo\Command = #COMMAND_GetArrayInfo
          Command\Value1 = #True
          SendDebuggerCommand(*Debugger, @Command)
          
          Command.CommandInfo\Command = #COMMAND_GetArrayInfo
          Command\Value1 = #False
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
        
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList]
        If *Debugger\ProgramState <> -1
          Command.CommandInfo\Command = #COMMAND_GetListInfo
          Command\Value1 = #True
          SendDebuggerCommand(*Debugger, @Command)
          
          Command.CommandInfo\Command = #COMMAND_GetListInfo
          Command\Value1 = #False
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap]
        If *Debugger\ProgramState <> -1
          Command.CommandInfo\Command = #COMMAND_GetMapInfo
          Command\Value1 = #True
          SendDebuggerCommand(*Debugger, @Command)
          
          Command.CommandInfo\Command = #COMMAND_GetMapInfo
          Command\Value1 = #False
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems],  *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems], *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange]
        If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange])
          DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], 0)
        Else
          DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], 1)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display]
        Name$ = Trim(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputName]))
        Command.CommandInfo\Command = #COMMAND_GetArrayListData
        Command\Value2 = 0 ; do not explicitly request a global one
        
        ; Until 4.41, Name$ was without a (), but we need it now for the
        ; expression parser resolving (structure array, list, map), so add it
        ; if it does not exist to help the user with the transition
        ;
        If Right(RemoveString(RemoveString(Name$, " "), Chr(9)), 2) <> "()"
          Name$ + "()"
        EndIf
        
        If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems])
          Command\Value1 = 0
          Command\DataSize = StringByteLength(Name$)+#CharSize
          SendDebuggerCommandWithData(*Debugger, @Command, @Name$) ; now in external format
          
        ElseIf GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems])
          Command\Value1 = 1
          Command\DataSize = StringByteLength(Name$)+#CharSize
          SendDebuggerCommandWithData(*Debugger, @Command, @Name$)
          
        Else
          Range$ = Trim(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange]))
          
          ; Range is now also in external format
          size = StringByteLength(Name$) + StringByteLength(Range$) + #CharSize*2
          *buffer = AllocateMemory(size)
          If *buffer
            PokeS(*Buffer, Name$)
            PokeS(*Buffer + StringByteLength(Name$)+#CharSize, Range$)
            Command\Value1 = 2
            Command\DataSize = size
            SendDebuggerCommandWithData(*Debugger, @Command, *Buffer)
            FreeMemory(*Buffer)
          EndIf
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Copy]
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Save]
        
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 10, 10, WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])-20, WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])-20)
    
    CompilerIf #CompileLinuxGtk
      ; the resize fails on Linux else when opening the window
      FlushEvents()
    CompilerEndIf
    
    Width  = GetPanelWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel])
    Height = GetPanelHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel])
    
    ; All buttons have "Update" on them, so we can use the same size
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update], @ButtonWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, 120)
    
    ; Variable view
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], 10, 10, Width-20, Height-30-ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update], Width-10-ButtonWidth, Height-35, ButtonWidth, ButtonHeight)
    
    If GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_FirstGadget) = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer] Or GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_SecondGadget) = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer]
      ContainerWidth = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
      ContainerHeight = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
      If ContainerWidth > 20+300
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], (ContainerWidth-300) / 2, (ContainerHeight-20)/2, 300, 20)
      Else
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], 10, (ContainerHeight-20)/2, ContainerWidth-20, 20)
      EndIf
    EndIf
    
    ; Array view
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArraySplitter], 10, 10, Width-20, Height-30-ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray], Width-10-ButtonWidth, Height-35, ButtonWidth, ButtonHeight)
    
    ; LinkedList view
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListSplitter], 10, 10, Width-20, Height-30-ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList], Width-10-ButtonWidth, Height-35, ButtonWidth, ButtonHeight)
    
    ; Map view
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapSplitter], 10, 10, Width-20, Height-30-ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap], Width-10-ButtonWidth, Height-35, ButtonWidth, ButtonHeight)
    
    ; List/Array viewer
    ButtonWidth = Max(80, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display]))
    TextWidth   = GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Text])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], @OptionWidth, @OptionHeight)
    OptionWidth = Max(200, OptionWidth)
    OptionWidth = Max(OptionWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems]))
    OptionWidth = Max(OptionWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange]))
    BoxWidth    = TextWidth+ButtonWidth+OptionWidth+35
    BoxHeight   = ButtonHeight*2 + OptionHeight*3 + 50
    
    Offset = (Width-BoxWidth)/2
    If Offset < 10
      Offset = Width-BoxWidth
    EndIf
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 10, 10, Width-20, Height-25-BoxHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Container], 10, Height-10-BoxHeight, Width-20, BoxHeight)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 10, 10, Width-20, Height-25-BoxHeight)
    If Width > 40+300
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], (Width-20-300) / 2, (Height-25-BoxHeight-20)/2, 300, 20)
    Else
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], 10, (Height-25-BoxHeight-20)/2, Width-40, 20)
    EndIf
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Text], Offset, 15, TextWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputName], Offset+5+TextWidth, 15, OptionWidth+10, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], Offset+15+TextWidth, 20+ButtonHeight, OptionWidth, OptionHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems], Offset+15+TextWidth, 25+ButtonHeight+OptionHeight, OptionWidth, OptionHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange], Offset+15+TextWidth, 30+ButtonHeight+OptionHeight*2, OptionWidth, OptionHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], Offset+35+TextWidth, 35+ButtonHeight+OptionHeight*3, OptionWidth-20, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display], Offset+35+TextWidth+OptionWidth, 15, ButtonWidth, ButtonHeight)
    ; ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Copy], Offset+35+TextWidth+OptionWidth, 20+ButtonHeight, ButtonWidth, ButtonHeight)
    ; ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Save], Offset+35+TextWidth+OptionWidth, 25+ButtonHeight*2, ButtonWidth, ButtonHeight)
    
  ElseIf EventID = #PB_Event_CloseWindow
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_Variable]) = 0
      VariableViewerMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
      If VariableViewerMaximize = 0
        VariableWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
        VariableWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
        VariableWindowWidth  = WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
        VariableWindowHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
      EndIf
    EndIf
    
    HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Variable], 1)
    VariableGadget_Free(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
    VariableGadget_Free(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
    VariableGadget_Free(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
    
    *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateVariableWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display], 1)
    
    DisableMenuItem(#POPUPMENU_VariableViewer, #DEBUGGER_MENU_WatchlistAdd, 1)
    DisableMenuItem(#POPUPMENU_ArrayViewer, #DEBUGGER_MENU_ViewAll, 1)
    DisableMenuItem(#POPUPMENU_ArrayViewer, #DEBUGGER_MENU_ViewNonZero, 1)
    DisableMenuItem(#POPUPMENU_ArrayViewer, #DEBUGGER_MENU_ViewRange, 1)
    
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display], 0)
    
    DisableMenuItem(#POPUPMENU_VariableViewer, #DEBUGGER_MENU_WatchlistAdd, 0)
    DisableMenuItem(#POPUPMENU_ArrayViewer, #DEBUGGER_MENU_ViewAll, 0)
    DisableMenuItem(#POPUPMENU_ArrayViewer, #DEBUGGER_MENU_ViewNonZero, 0)
    DisableMenuItem(#POPUPMENU_ArrayViewer, #DEBUGGER_MENU_ViewRange, 0)
    
    
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -2
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap], 1)
      
      ; send the update command
      ;
      Command.CommandInfo\Command = #COMMAND_GetGlobals
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetLocals
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetArrayInfo
      Command\Value1 = #True
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetArrayInfo
      Command\Value1 = #False
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetListInfo
      Command\Value1 = #True
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetListInfo
      Command\Value1 = #False
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetMapInfo
      Command\Value1 = #True
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetMapInfo
      Command\Value1 = #False
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
    
  EndIf
  
EndProcedure


Procedure OpenVariableWindow(*Debugger.DebuggerData)
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Variable]
    SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_Variable])
    
  Else
    Window = OpenWindow(#PB_Any, VariableWindowX, VariableWindowY, VariableWindowWidth, VariableWindowHeight, Language("Debugger","VariableWindowTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = Window
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel] = PanelGadget(#PB_Any, 0, 0, 0, 0)
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], -1, Language("Debugger","Variables"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global] = VariableGadget_Create(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), #True, #False)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local]  = VariableGadget_Create(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), #True, #False)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter] = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global], *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Single)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress] = ProgressBarGadget(#PB_Any, 0, 0, 0, 0, 0, 100)
      CloseGadgetList()
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer], 1)
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], -1, Language("Debugger","Arrays"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), 70, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo], 1, Language("Debugger","Name"), 430)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), 70, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo], 1, Language("Debugger","Name"), 430)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArraySplitter] = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo], *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo])
      
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray], 1)
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], -1, Language("Debugger","LinkedLists"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), 70, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo], 1, Language("Debugger","Name"), VariableWindowWidth-300)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo], 2, Language("Debugger","Size"), 70)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo], 3, Language("Debugger","Current"), 70)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), 70, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo], 1, Language("Debugger","Name"), VariableWindowWidth-300)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo], 2, Language("Debugger","Size"), 70)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo], 3, Language("Debugger","Current"), 70)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListSplitter] = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo], *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo])
      
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList], 1)
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], -1, Language("Debugger","Maps"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), 70, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo], 1, Language("Debugger","Name"), VariableWindowWidth-350)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo], 2, Language("Debugger","Size"), 70)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo], 3, Language("Debugger","Current"), 120)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope"), 70, #PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_GridLines)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo], 1, Language("Debugger","Name"), VariableWindowWidth-350)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo], 2, Language("Debugger","Size"), 70)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo], 3, Language("Debugger","Current"), 120)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapSplitter] = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo], *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo])
      
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap], 1)
      
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], -1, Language("Debugger","ViewArrayList"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer] = VariableGadget_Create(#PB_Any, 0, 0, 0, 0, "", #False, #True)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Single)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress] = ProgressBarGadget(#PB_Any, 0, 0, 0, 0, 0, 100)
      CloseGadgetList()
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 1)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Container] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Single)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Text]         = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","ArrayListName")+":", #PB_Text_Right)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputName]    = StringGadget(#PB_Any, 0, 0, 0, 0, "")
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems]     = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","AllItems"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems] = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","NonZeroItems"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange]    = OptionGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","ItemRange")+":")
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange]   = StringGadget(#PB_Any, 0, 0, 0, 0, "")
      *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display]      = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Display"))
      ; TODO: not yet implemented
      ;*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Copy]         = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Copy"))
      ;*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Save]         = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Save"))
      CloseGadgetList()
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputRange], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display], 1)
      
      
      CompilerIf #DEFAULT_CanWindowStayOnTop
        SetWindowStayOnTop(Window, DebuggerOnTop)
      CompilerEndIf
      
      If CreatePopupMenu(#POPUPMENU_VariableViewer)
        MenuItem(#DEBUGGER_MENU_WatchlistAdd, Language("Debugger","WatchlistAdd"))
        MenuBar()
        MenuItem(#DEBUGGER_MENU_CopyVariable, Language("Debugger","Copy"))
      EndIf
      
      If CreatePopupMenu(#POPUPMENU_ArrayViewer)
        MenuItem(#DEBUGGER_MENU_ViewAll,     Language("Debugger", "AllItems"))
        MenuItem(#DEBUGGER_MENU_ViewNonZero, Language("Debugger", "NonZeroItems"))
        MenuItem(#DEBUGGER_MENU_ViewRange,   Language("Debugger", "ItemRange"))
      EndIf
      
      Debugger_AddShortcuts(Window)
      
      ; Set default sorting values (name column, ascending)
      ;
      *Debugger\ArraySortColumn         = 0
      *Debugger\ArraySortDirection      = 1
      *Debugger\LocalArraySortColumn    = 1
      *Debugger\LocalArraySortDirection = 1
      *Debugger\ListSortColumn          = 0
      *Debugger\ListSortDirection       = 1
      *Debugger\LocalListSortColumn     = 1
      *Debugger\LocalListSortDirection  = 1
      
      CompilerIf #CompileWindows
        ; watch column clicks
        SetWindowCallback(@Variable_WindowCallback(), Window) ; local window callback
      CompilerEndIf
      
      ; send the command to get the global variable names (so in the future, only the values are transmitted)
      ;
      If *Debugger\ProgramState <> -1
        Command.CommandInfo\Command = #COMMAND_GetGlobalNames
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      EnsureWindowOnDesktop(Window)
      If VariableViewerMaximize  ; must be before the resize so panel size is calculated correctly!
        ShowWindowMaximized(Window)
      Else
        HideWindow(Window, 0)
      EndIf
      VariableWindowEvents(*Debugger, #PB_Event_SizeWindow)
      
      CompilerIf #CompileLinuxGtk
        FlushEvents() ; Flush the events to finish window creation/resize or SetGadgetState() could fail on linux: https://www.purebasic.fr/english/viewtopic.php?f=23&t=48589
      CompilerEndIf
      
      Height = GetPanelHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel])
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], (Height-55)/2)
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArraySplitter], (Height-55)/2)
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListSplitter], (Height-55)/2)
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapSplitter], (Height-55)/2)
      UpdateVariableWindowState(*Debugger)
      
      
      ; something for better optics (must be after the first resize)
      CompilerIf #CompileWindows
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global]), #LVM_SETCOLUMNWIDTH, 2, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local]), #LVM_SETCOLUMNWIDTH, 2, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer]), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo]), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo]), #LVM_SETCOLUMNWIDTH, 1, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo]), #LVM_SETCOLUMNWIDTH, 3, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo]), #LVM_SETCOLUMNWIDTH, 3, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo]), #LVM_SETCOLUMNWIDTH, 3, #LVSCW_AUTOSIZE_USEHEADER)
        SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo]), #LVM_SETCOLUMNWIDTH, 3, #LVSCW_AUTOSIZE_USEHEADER)
      CompilerEndIf
      
      ; The UpdateVariableWindowState() does not request an update if we are not in singlestep mode,
      ; so we do this manually when the window opened, which makes sense.
      If *Debugger\ProgramState = 0
        ; send the update command
        ;
        Command.CommandInfo\Command = #COMMAND_GetGlobals
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetLocals
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetArrayInfo
        Command\Value1 = #True
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetArrayInfo
        Command\Value1 = #False
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetListInfo
        Command\Value1 = #True
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetListInfo
        Command\Value1 = #False
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetMapInfo
        Command\Value1 = #True
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetMapInfo
        Command\Value1 = #False
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
    EndIf
  EndIf
  
EndProcedure


Procedure UpdateVariableWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Variable], Language("Debugger","VariableWindowTitle") + " - " + GetFilePart(*Debugger\FileName$))
  
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 0, Language("Debugger","Variables"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 1, Language("Debugger","Arrays"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 2, Language("Debugger","LinkedLists"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 3, Language("Debugger","Maps"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 4, Language("Debugger","ViewArrayList"), 0)
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Update], Language("Debugger","Update"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateArray], Language("Debugger","Update"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateList], Language("Debugger","Update"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_UpdateMap], Language("Debugger","Update"))
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Text], Language("Debugger","ArrayListName")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_AllItems], Language("Debugger","AllItems"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_NonZeroItems], Language("Debugger","NonZeroItems"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ItemRange], Language("Debugger","ItemRange")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Display], Language("Debugger","Display"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Copy], Language("Debugger","Copy"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Save], Language("Debugger","Save"))
  
  VariableWindowEvents(*Debugger, #PB_Event_SizeWindow) ; update button sizes
  
EndProcedure


Procedure VariableDebug_DebuggerEvent(*Debugger.DebuggerData)
  Shared *VariableGadget_Used.VariableGadget ; to access the variable gadget data structure
  
  If *Debugger\Command\Command = #COMMAND_ControlVariableViewer
    OpenVariableWindow(*Debugger)
    ProcedureReturn     ; do not run the rest of this code
  EndIf
  
  ; ignore these messages when the window is closed
  ;
  If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
    ProcedureReturn
  EndIf
  
  Select *Debugger\Command\Command
      
      ;- #COMMAND_GlobalNames
    Case #COMMAND_GlobalNames
      VariableGadget_Allocate(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global], *Debugger\Command\Value2)
      VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      
      *Pointer = *Debugger\CommandData
      For i = 1 To *Debugger\Command\Value2
        type = PeekB(*Pointer)
        *Pointer + 1
        dynamictype = PeekB(*Pointer)
        *Pointer + 1
        scope = PeekB(*Pointer)
        ScopeName$ = ScopeName(scope)
        *Pointer + 1
        sublevel = PeekL(*Pointer)
        *Pointer + 4
        name$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*pointer) + 1
        mod$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*pointer) + 1
        
        VariableGadget_Add(type, dynamictype, sublevel, ScopeName$, name$, mod$, 0, *Debugger\Is64bit)
      Next i
      
      VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      
      ;- #COMMAND_Globals
    Case #COMMAND_Globals
      VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], 0)
      UpdateStep = *Debugger\Command\Value2 / 100
      NextUpdate = UpdateStep
      Timeout.q  = ElapsedMilliseconds() + 750
      ProgressVisible = 0
      
      *Pointer = *Debugger\CommandData
      For i = 1 To *Debugger\Command\Value2
        type = PeekB(*Pointer)
        *Pointer + 1
        
        VariableGadget_Set(i-1, *Pointer, *Debugger\Is64bit, #False)
        *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
        
        If i > NextUpdate And (ProgressVisible Or Timeout < ElapsedMilliseconds())
          If ProgressVisible = 0 And i < *Debugger\Command\Value2 / 2  ; do not show if almost finished
            SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], #PB_ProgressBar_Maximum, *Debugger\Command\Value2)
            HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global], 1)
            SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_FirstGadget, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
            
            ContainerWidth = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
            ContainerHeight = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
            If ContainerWidth > 20+300
              ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], (ContainerWidth-300) / 2, (ContainerHeight-20)/2, 300, 20)
            Else
              ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], 10, (ContainerHeight-20)/2, ContainerWidth-20, 20)
            EndIf
            HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer], 0)
            
            ProgressVisible = 1
          EndIf
          
          NextUpdate + UpdateStep
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], i)
          
          FlushEvents() ; Note: The FlushEvents() could contain a close event!
          If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
            ProcedureReturn
          EndIf
        EndIf
      Next i
      
      If ProgressVisible
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], *Debugger\Command\Value2)
        
        FlushEvents() ; Note: The FlushEvents() could contain a close event!
        If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
          ProcedureReturn
        EndIf
      EndIf
      
      VariableGadget_SyncAll() ; update the displayed content
      VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      
      If ProgressVisible
        HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer], 1)
        SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_FirstGadget, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
        HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global], 0)
      EndIf
      
      VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Global])
      
      ;- #COMMAND_Locals
    Case #COMMAND_Locals
      VariableGadget_Allocate(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local], *Debugger\Command\Value2)
      VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
      VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
      *VariableGadget_Used\CustomData = *Debugger\Command\Value1
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], 0)
      UpdateStep = *Debugger\Command\Value2 / 100
      NextUpdate = UpdateStep
      Timeout.q  = ElapsedMilliseconds() + 750
      ProgressVisible = 0
      
      *Pointer = *Debugger\CommandData
      For i = 1 To *Debugger\Command\Value2
        type = PeekB(*Pointer) & ~(1<<6) ; remove the direct param flag right at the start
        *Pointer + 1
        dynamictype = PeekB(*Pointer)
        *Pointer + 1
        scope = PeekB(*Pointer)
        ScopeName$ = ScopeName(scope)
        *Pointer + 1
        sublevel = PeekL(*Pointer)
        *Pointer + 4
        name$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        VariableGadget_Add(type, dynamictype, sublevel, ScopeName$, name$, "", *Pointer, *Debugger\Is64bit)
        *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
        
        If i > NextUpdate And (ProgressVisible Or Timeout < ElapsedMilliseconds())
          If ProgressVisible = 0 And i < *Debugger\Command\Value2 / 2  ; do not show if almost finished
            SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], #PB_ProgressBar_Maximum, *Debugger\Command\Value2)
            HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local], 1)
            SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_SecondGadget, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
            
            ContainerWidth = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
            ContainerHeight = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer])
            If ContainerWidth > 20+300
              ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], (ContainerWidth-300) / 2, (ContainerHeight-20)/2, 300, 20)
            Else
              ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], 10, (ContainerHeight-20)/2, ContainerWidth-20, 20)
            EndIf
            HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer], 0)
            
            ProgressVisible = 1
          EndIf
          
          NextUpdate + UpdateStep
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Progress], i)
          
          FlushEvents() ; Note: The FlushEvents() could contain a close event!
          If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
            ProcedureReturn
          EndIf
        EndIf
      Next i
      
      VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
      
      If ProgressVisible
        HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ProgressContainer], 1)
        SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Splitter], #PB_Splitter_SecondGadget, *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
        HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local], 0)
      EndIf
      
      VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Local])
      
      
      ;- #COMMAND_ArrayInfo
    Case #COMMAND_ArrayInfo
      *Pointer = *Debugger\CommandData
      
      If *Debugger\Command\Value1 ; isglobal
        Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ArrayInfo]
        OldState = -1
        
        ; the number of global arrays never changed (only the arrays sizes), so
        ; only overwrite the old content to not loose the scrolling position.
        ;
        If CountGadgetItems(Gadget) = 0
          AddNew = 1
        Else
          AddNew = 0
          Protected Dim InfoStrings$(*Debugger\Command\Value2)
        EndIf
      Else
        Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalArrayInfo]
        OldState = GetGadgetState(Gadget)
        ClearGadgetItems(Gadget)
        AddNew = 1
      EndIf
      
      For i = 0 To *Debugger\Command\Value2-1
        Name$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        ModName$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        Dimensions$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        type = PeekB(*Pointer)
        *Pointer + 1
        
        ; this is also present for global lists
        scope = PeekB(*Pointer)
        ScopeName$ = ScopeName(scope, type)
        *Pointer + 1
        
        If IS_POINTER(type)
          Name$ = "*" + Name$
        EndIf
        
        If *Debugger\Command\Value1 = 0 ; local, always re-adding
          AddGadgetItem(Gadget, i, ScopeName$+Chr(10)+ModuleName(Name$, ModName$)+Dimensions$, ImageID(VariableGadget_Icons(type & #TYPEMASK)))
          SetGadgetItemData(Gadget, i, i) ; associate the item with its index so we have it after sorting
          
        ElseIf AddNew
          AddGadgetItem(Gadget, i, ScopeName$+Chr(10)+ModuleName(Name$, ModName$)+Dimensions$, ImageID(VariableGadget_Icons(type & #TYPEMASK)))
          SetGadgetItemData(Gadget, i, i) ; associate the item with its index so we have it after sorting
          
        Else
          InfoStrings$(i) = ModuleName(Name$, ModName$)+Dimensions$ ; the update is done later
          
        EndIf
      Next i
      
      ; If we just refresh the content, we must do it now, as the indexes could be
      ; changed from sorting (this is for the global gadget only)
      ;
      If AddNew = 0
        For i = 0 To *Debugger\Command\Value2-1
          SetGadgetItemText(Gadget, i, InfoStrings$(GetGadgetItemData(Gadget, i)), 1)
        Next i
      EndIf
      
      If OldState <> -1
        SetGadgetState(Gadget, OldState)
      EndIf
      
      VariableWindowSort(*Debugger, Gadget)
      
      
      ;- #COMMAND_ListInfo
    Case #COMMAND_ListInfo
      *Pointer = *Debugger\CommandData
      
      If *Debugger\Command\Value1 ; isglobal
        Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ListInfo]
        OldState = -1
        
        ; the number of global lists never changed (only the arrays sizes), so
        ; only overwrite the old content to not loose the scrolling position.
        ;
        If CountGadgetItems(Gadget) = 0
          AddNew = 1
        Else
          AddNew = 0
          Dim InfoStrings$(*Debugger\Command\Value2)
        EndIf
      Else
        Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalListInfo]
        OldState = GetGadgetState(Gadget)
        ClearGadgetItems(Gadget)
        AddNew = 1
      EndIf
      
      For i = 0 To *Debugger\Command\Value2-1
        Name$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        ModName$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        type = PeekB(*Pointer)
        *Pointer + 1
        
        ; this is also present for global lists
        scope = PeekB(*Pointer)
        ScopeName$ = ScopeName(scope, type)
        *Pointer + 1
        
        If IS_POINTER(type)
          Name$ = "*" + Name$
        EndIf
        Name$ + "()"
        
        If *Debugger\Is64bit
          If PeekQ(*Pointer) = -1
            Size$ = "-"
          Else
            Size$ = Str(PeekQ(*Pointer))
          EndIf
          *Pointer + 8
          
          If PeekQ(*Pointer) = -1
            Current$ = "-"
          Else
            Current$ = Str(PeekQ(*Pointer))
          EndIf
          *Pointer + 8
        Else
          If PeekL(*Pointer) = -1
            Size$ = "-"
          Else
            Size$ = Str(PeekL(*Pointer))
          EndIf
          *Pointer + 4
          
          If PeekL(*Pointer) = -1
            Current$ = "-"
          Else
            Current$ = Str(PeekL(*Pointer))
          EndIf
          *Pointer + 4
        EndIf
        
        If *Debugger\Command\Value1 = 0 ; local, always adding new items
          AddGadgetItem(Gadget, i, ScopeName$+Chr(10)+ModuleName(Name$, ModName$)+Chr(10)+Size$+Chr(10)+Current$, ImageID(VariableGadget_Icons(type & #TYPEMASK)))
          SetGadgetItemData(Gadget, i, i) ; associate the item with its index so we have it after sorting
          
        ElseIf AddNew
          AddGadgetItem(Gadget, i, ScopeName$+Chr(10)+ModuleName(Name$, ModName$)+Chr(10)+Size$+Chr(10)+Current$, ImageID(VariableGadget_Icons(type & #TYPEMASK)))
          SetGadgetItemData(Gadget, i, i) ; so we know the index after sorting
          
        Else
          ; we just update size and index when updating
          InfoStrings$(i) = Size$ + Chr(10) + Current$
        EndIf
      Next i
      
      ; If we just refresh the content, we must do it now, as the indexes could be
      ; changed from sorting (this is for the global gadget only)
      ;
      If AddNew = 0
        For i = 0 To *Debugger\Command\Value2-1
          index = GetGadgetItemData(Gadget, i)
          SetGadgetItemText(Gadget, i, StringField(InfoStrings$(index), 1, Chr(10)), 2)
          SetGadgetItemText(Gadget, i, StringField(InfoStrings$(index), 2, Chr(10)), 3)
        Next i
      EndIf
      
      If OldState <> -1
        SetGadgetState(Gadget, OldState)
      EndIf
      
      VariableWindowSort(*Debugger, Gadget)
      
      ;- #COMMAND_MapInfo
    Case #COMMAND_MapInfo
      *Pointer = *Debugger\CommandData
      
      If *Debugger\Command\Value1 ; isglobal
        Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_MapInfo]
        OldState = -1
        
        ; the number of global lists never changed (only the sizes), so
        ; only overwrite the old content to not loose the scrolling position.
        ;
        If CountGadgetItems(Gadget) = 0
          AddNew = 1
        Else
          AddNew = 0
          Dim InfoStrings$(*Debugger\Command\Value2)
        EndIf
      Else
        Gadget   = *Debugger\Gadgets[#DEBUGGER_GADGET_Variable_LocalMapInfo]
        OldState = GetGadgetState(Gadget)
        ClearGadgetItems(Gadget)
        AddNew = 1
      EndIf
      
      For i = 0 To *Debugger\Command\Value2-1
        Name$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        ModName$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        
        type = PeekB(*Pointer)
        *Pointer + 1
        
        ; this is also present for global lists
        scope = PeekB(*Pointer)
        ScopeName$ = ScopeName(scope, type)
        *Pointer + 1
        
        If IS_POINTER(type)
          Name$ = "*" + Name$
        EndIf
        Name$ + "()"
        
        If *Debugger\Is64bit
          If PeekQ(*Pointer) = -1
            Size$ = "-"
          Else
            Size$ = Str(PeekQ(*Pointer))
          EndIf
          *Pointer + 8
        Else
          If PeekL(*Pointer) = -1
            Size$ = "-"
          Else
            Size$ = Str(PeekL(*Pointer))
          EndIf
          *Pointer + 4
        EndIf
        
        IsCurrent = PeekB(*Pointer)
        *Pointer + 1
        
        If IsCurrent
          Current$ = Chr(34)+PeekS(*Pointer)+Chr(34) ; in external debugger format
          *Pointer + (MemoryStringLength(*Pointer) + 1) * #CharSize
        Else
          Current$ = "-"
        EndIf
        
        If *Debugger\Command\Value1 = 0 ; local, always adding new items
          AddGadgetItem(Gadget, i, ScopeName$+Chr(10)+ModuleName(Name$, ModName$)+Chr(10)+Size$+Chr(10)+Current$, ImageID(VariableGadget_Icons(type & #TYPEMASK)))
          SetGadgetItemData(Gadget, i, i) ; associate the item with its index so we have it after sorting
          
        ElseIf AddNew
          AddGadgetItem(Gadget, i, ScopeName$+Chr(10)+ModuleName(Name$, ModName$)+Chr(10)+Size$+Chr(10)+Current$, ImageID(VariableGadget_Icons(type & #TYPEMASK)))
          SetGadgetItemData(Gadget, i, i) ; so we know the index after sorting
          
        Else
          ; we just update size and index when updating
          InfoStrings$(i) = Size$ + Chr(10) + Current$
        EndIf
      Next i
      
      ; If we just refresh the content, we must do it now, as the indexes could be
      ; changed from sorting (this is for the global gadget only)
      ;
      If AddNew = 0
        For i = 0 To *Debugger\Command\Value2-1
          index = GetGadgetItemData(Gadget, i)
          SetGadgetItemText(Gadget, i, StringField(InfoStrings$(index), 1, Chr(10)), 2)
          SetGadgetItemText(Gadget, i, StringField(InfoStrings$(index), 2, Chr(10)), 3)
        Next i
      EndIf
      
      If OldState <> -1
        SetGadgetState(Gadget, OldState)
      EndIf
      
      VariableWindowSort(*Debugger, Gadget)
      
      ;- #COMMAND_ListData
    Case #COMMAND_ListData
      If *Debugger\Command\Value1 = 0 ; indicates an error
        MessageRequester(Language("Debugger", "ViewArrayList"), PeekAsciiLength(*Debugger\CommandData, *Debugger\Command\DataSize))
        
      Else ; no error
           ; switch to the correct tab in case the display was started by contextmenu from
           ; another tab
        If GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel]) <> 4
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 4)
          
          FlushEvents() ; Note: The FlushEvents() could contain a close event!
          If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
            ProcedureReturn
          EndIf
        EndIf
        
        VariableGadget_Allocate(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], *Debugger\Command\Value2)
        VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        type = *Debugger\Command\Value1
        *pointer = *Debugger\CommandData
        
        RealName$ = PeekS(*pointer)
        *pointer + MemoryStringLengthBytes(*pointer) + #CharSize
        SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputName], RealName$)
        
        ; Cut the () from the RealName$ so we can add the index later
        For i = Len(RealName$) To 1 Step -1
          If Mid(RealName$, i, 1) = "("
            RealName$ = Trim(Left(RealName$, i-1))
            Break
          EndIf
        Next i
        
        If IS_STRUCTURE(type) And Not IS_POINTER(type)
          *map = *pointer
          While PeekB(*pointer) <> -1
            *pointer + 6; skip sublevel+type+dynamictype
            *pointer + MemoryAsciiLength(*pointer) + 1; skip name
          Wend
          *pointer + 1
        EndIf
        
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], 0)
        UpdateStep = *Debugger\Command\Value2 / 100
        NextUpdate = UpdateStep
        Timeout.q  = ElapsedMilliseconds() + 750
        ProgressVisible = 0
        
        LinesAdded = 0
        While *pointer < *Debugger\CommandData + *Debugger\Command\DataSize
          If *Debugger\Is64bit
            index$= Str(PeekQ(*pointer))
            *pointer + 8
          Else
            index$ = Str(PeekL(*pointer))
            *pointer + 4
          EndIf
          
          If IS_STRUCTURE(type) And Not IS_POINTER(type)
            VariableGadget_Add(7, 0, 0, "", RealName$ + "(:" + index$ + ":)", "", *Pointer, *Debugger\Is64bit)
            LinesAdded + 1
            
            *mappointer = *map
            While PeekB(*mappointer) <> -1
              structtype = PeekB(*mappointer)
              *mappointer + 1
              dynamictype = PeekB(*mappointer)
              *mappointer + 1
              sublevel = PeekL(*mappointer)
              *mappointer + 4
              Name$ = PeekAscii(*mappointer)
              *mappointer + MemoryAsciiLength(*mappointer) + 1; skip name
              
              VariableGadget_Add(structtype, dynamictype, sublevel, "", Name$, "", *Pointer, *Debugger\Is64bit)
              *Pointer + GetValueSize(structtype, *Pointer, *Debugger\Is64bit)
              LinesAdded + 1
            Wend
            
          Else
            VariableGadget_Add(type, 0, 0, "", RealName$ + "(:" + index$ + ":)", "", *Pointer, *Debugger\Is64bit)
            *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
            LinesAdded + 1
          EndIf
          
          If LinesAdded > NextUpdate And (ProgressVisible Or ElapsedMilliseconds() > Timeout)
            If ProgressVisible = 0 And LinesAdded < *Debugger\Command\Value2 / 2
              SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], #PB_ProgressBar_Maximum, *Debugger\Command\Value2)
              HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 0)
              HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 1)
              ProgressVisible = 1
            EndIf
            
            NextUpdate + UpdateStep
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], LinesAdded)
            
            FlushEvents() ; Note: The FlushEvents() could contain a close event!
            If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
              ProcedureReturn
            EndIf
          EndIf
        Wend
        
        If ProgressVisible
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], *Debugger\Command\Value2)
          
          FlushEvents() ; Note: The FlushEvents() could contain a close event!
          If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
            ProcedureReturn
          EndIf
        EndIf
        
        If IS_STRUCTURE(type) And Not IS_POINTER(type)
          VariableGadget_Expand(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        EndIf
        
        VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        
        If ProgressVisible
          HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 0)
          HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 1)
        EndIf
        
        VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        
      EndIf
      
      
      ;- #COMMAND_ArrayData
    Case #COMMAND_ArrayData
      If *Debugger\Command\Value1 = 0 ; indicates an error
        MessageRequester(Language("Debugger", "ViewArrayList"), PeekAsciiLength(*Debugger\CommandData, *Debugger\Command\DataSize))
        
      Else ; no error
           ; switch to the correct tab in case the display was started by contextmenu from
           ; another tab
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 4)
        
        
        VariableGadget_Allocate(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], *Debugger\Command\Value2)
        VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        type = *Debugger\Command\Value1
        *pointer = *Debugger\CommandData
        
        RealName$ = PeekS(*pointer)
        *pointer + MemoryStringLengthBytes(*pointer) + #CharSize
        SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputName], RealName$)
        
        ; Cut the () from the RealName$ so we can add the dimensions later
        For i = Len(RealName$) To 1 Step -1
          If Mid(RealName$, i, 1) = "("
            RealName$ = Trim(Left(RealName$, i-1))
            Break
          EndIf
        Next i
        
        If IS_STRUCTURE(type) And Not IS_POINTER(type)
          *map = *pointer
          While PeekB(*pointer) <> -1
            *pointer + 6; skip sublevel+type+dynamictype
            *pointer + MemoryAsciiLength(*pointer) + 1; skip name
          Wend
          *pointer + 1
        EndIf
        
        FlushEvents() ; Note: The FlushEvents() could contain a close event!
        If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
          ProcedureReturn
        EndIf
        
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], 0)
        UpdateStep = *Debugger\Command\Value2 / 100
        NextUpdate = UpdateStep
        Timeout.q  = ElapsedMilliseconds() + 750
        ProgressVisible = 0
        
        LinesAdded = 0
        While *pointer < *Debugger\CommandData + *Debugger\Command\DataSize
          Indizes$ = PeekAscii(*pointer)
          *pointer + MemoryAsciiLength(*pointer) + 1
          
          If IS_STRUCTURE(type) And Not IS_POINTER(type)
            VariableGadget_Add(7, 0, 0, "", RealName$ + "("+Indizes$+")", "", *Pointer, *Debugger\Is64bit)
            LinesAdded + 1
            
            *mappointer = *map
            While PeekB(*mappointer) <> -1
              structtype = PeekB(*mappointer)
              *mappointer + 1
              dynamictype = PeekB(*mappointer)
              *mappointer + 1
              sublevel = PeekL(*mappointer)
              *mappointer + 4
              Name$ = PeekAscii(*mappointer)
              *mappointer + MemoryAsciiLength(*mappointer) + 1; skip name
              
              VariableGadget_Add(structtype, dynamictype, sublevel, "", Name$, "", *Pointer, *Debugger\Is64bit)
              *Pointer + GetValueSize(structtype, *Pointer, *Debugger\Is64bit)
              LinesAdded + 1
            Wend
            
          Else
            VariableGadget_Add(type, 0, 0, "", RealName$ + "("+Indizes$+")", "", *Pointer, *Debugger\Is64bit)
            *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
            LinesAdded + 1
          EndIf
          
          If LinesAdded > NextUpdate And (ProgressVisible Or ElapsedMilliseconds() > Timeout)
            If ProgressVisible = 0 And LinesAdded < *Debugger\Command\Value2 / 2
              SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], #PB_ProgressBar_Maximum, *Debugger\Command\Value2)
              HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 0)
              HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 1)
              ProgressVisible = 1
            EndIf
            
            NextUpdate + UpdateStep
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], LinesAdded)
            
            FlushEvents() ; Note: The FlushEvents() could contain a close event!
            If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
              ProcedureReturn
            EndIf
          EndIf
        Wend
        
        If ProgressVisible
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], *Debugger\Command\Value2)
          
          FlushEvents() ; Note: The FlushEvents() could contain a close event!
          If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
            ProcedureReturn
          EndIf
        EndIf
        
        If IS_STRUCTURE(type) And Not IS_POINTER(type)
          VariableGadget_Expand(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        EndIf
        
        VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        
        If ProgressVisible
          HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 0)
          HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 1)
        EndIf
        
        VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        
      EndIf
      
      ;- #COMMAND_MapData
    Case #COMMAND_MapData
      If *Debugger\Command\Value1 = 0 ; indicates an error
        MessageRequester(Language("Debugger", "ViewArrayList"), PeekAsciiLength(*Debugger\CommandData, *Debugger\Command\DataSize))
        
      Else ; no error
           ; switch to the correct tab in case the display was started by contextmenu from another tab
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Panel], 4)
        
        VariableGadget_Allocate(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], *Debugger\Command\Value2)
        VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        type = *Debugger\Command\Value1
        *pointer = *Debugger\CommandData
        
        RealName$ = PeekS(*pointer)
        *pointer + MemoryStringLengthBytes(*pointer) + #CharSize
        SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_InputName], RealName$)
        
        ; Cut the () from the RealName$ so we can add the key later
        For i = Len(RealName$) To 1 Step -1
          If Mid(RealName$, i, 1) = "("
            RealName$ = Trim(Left(RealName$, i-1))
            Break
          EndIf
        Next i
        
        If IS_STRUCTURE(type) And Not IS_POINTER(type)
          *map = *pointer
          While PeekB(*pointer) <> -1
            *pointer + 6; skip sublevel+type+dynamictype
            *pointer + MemoryAsciiLength(*pointer) + 1; skip name
          Wend
          *pointer + 1
        EndIf
        
        FlushEvents() ; Note: The FlushEvents() could contain a close event!
        If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
          ProcedureReturn
        EndIf
        
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], 0)
        UpdateStep = *Debugger\Command\Value2 / 100
        NextUpdate = UpdateStep
        Timeout.q  = ElapsedMilliseconds() + 750
        ProgressVisible = 0
        
        LinesAdded = 0
        While *pointer < *Debugger\CommandData + *Debugger\Command\DataSize
          Key$ = Chr(34)+PeekS(*pointer)+Chr(34) ; in external format
          *pointer + (MemoryStringLength(*pointer) + 1) * #CharSize
          
          If IS_STRUCTURE(type) And Not IS_POINTER(type)
            VariableGadget_Add(7, 0, 0, "", RealName$ + "("+Key$+")", "", *Pointer, *Debugger\Is64bit)
            LinesAdded + 1
            
            *mappointer = *map
            While PeekB(*mappointer) <> -1
              structtype = PeekB(*mappointer)
              *mappointer + 1
              dynamictype = PeekB(*mappointer)
              *mappointer + 1
              sublevel = PeekL(*mappointer)
              *mappointer + 4
              Name$ = PeekAscii(*mappointer)
              *mappointer + MemoryAsciiLength(*mappointer) + 1; skip name
              
              VariableGadget_Add(structtype, dynamictype, sublevel, "", Name$, "", *Pointer, *Debugger\Is64bit)
              *Pointer + GetValueSize(structtype, *Pointer, *Debugger\Is64bit)
              LinesAdded + 1
            Wend
            
          Else
            VariableGadget_Add(type, 0, 0, "", RealName$ + "("+Key$+")", "", *Pointer, *Debugger\Is64bit)
            *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
            LinesAdded + 1
          EndIf
          
          If LinesAdded > NextUpdate And (ProgressVisible Or ElapsedMilliseconds() > Timeout)
            If ProgressVisible = 0 And LinesAdded < *Debugger\Command\Value2 / 2
              SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], #PB_ProgressBar_Maximum, *Debugger\Command\Value2)
              HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 0)
              HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 1)
              ProgressVisible = 1
            EndIf
            
            NextUpdate + UpdateStep
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], LinesAdded)
            
            FlushEvents() ; Note: The FlushEvents() could contain a close event!
            If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
              ProcedureReturn
            EndIf
          EndIf
        Wend
        
        If ProgressVisible
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerProgress], *Debugger\Command\Value2)
          
          FlushEvents() ; Note: The FlushEvents() could contain a close event!
          If *Debugger\Windows[#DEBUGGER_WINDOW_Variable] = 0
            ProcedureReturn
          EndIf
        EndIf
        
        If IS_STRUCTURE(type) And Not IS_POINTER(type)
          VariableGadget_Expand(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        EndIf
        
        VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        
        If ProgressVisible
          HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer], 0)
          HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_ViewerContainer], 1)
        EndIf
        
        VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_Variable_Viewer])
        
      EndIf
      
  EndSelect
  
EndProcedure
