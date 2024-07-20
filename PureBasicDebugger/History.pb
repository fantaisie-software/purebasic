; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure HistoryWindowEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_Gadget
    EventGadgetID = EventGadget()
    
    If EventGadgetID = *Debugger\Gadgets[#DEBUGGER_GADGET_History_Update]
      Command.CommandInfo\Command = #COMMAND_GetHistory
      SendDebuggerCommand(*Debugger, @Command)
      
    ElseIf EventGadgetID = *Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset]
      For i = 0 To *Debugger\NbProcedures - 1
        If GetGadgetItemState(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats], i) & #PB_ListIcon_Selected
          Command.CommandInfo\Command = #COMMAND_ResetProcedureStats
          Command\Value1 = i
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
      Next i
      
      Command.CommandInfo\Command = #COMMAND_GetProcedureStats
      SendDebuggerCommand(*Debugger, @Command)
      
      
    ElseIf EventGadgetID = *Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll]
      Command.CommandInfo\Command = #COMMAND_ResetProcedureStats
      Command\Value1 = -1
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetProcedureStats
      SendDebuggerCommand(*Debugger, @Command)
      
    ElseIf EventGadgetID = *Debugger\Gadgets[#DEBUGGER_GADGET_History_UpdateStats]
      Command.CommandInfo\Command = #COMMAND_GetProcedureStats
      SendDebuggerCommand(*Debugger, @Command)
      
    ElseIf *Debugger\History
      *history.Debugger_History = *Debugger\History
      For i = 0 To *Debugger\HistorySize-1
        If EventGadgetID = *history\item[i]\Show
          HistoryWindowEvents(*Debugger, #PB_Event_SizeWindow) ; resize the gadgets accordingly
          Break
          
        ElseIf EventGadgetID = *history\item[i]\Variables
          VariableGadget_Event(*history\item[i]\Variables)
          
        EndIf
      Next i
    EndIf
    
  ElseIf EventID = #PB_Event_SizeWindow
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel], 10, 10, WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_History])-20, WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_History])-20)
    Width  = GetPanelWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel])
    Height = GetPanelHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], @ButtonWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, 120)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea], 10, 10, Width-20, Height-30-ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], Width-10-ButtonWidth, Height-10-ButtonHeight, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Updating], 10, 10, Width-20, Height-30-ButtonHeight)
    
    Top = 10
    InnerWidth = Width - 70
    ContainerWidth  = Width - 55
    ContainerHeight = ButtonHeight * 3 + 25
    
    If *Debugger\History
      *history.Debugger_History = *Debugger\History
      If *Debugger\HistorySize > 0
        ButtonWidth = Max(110, GetRequiredWidth(*history\item[0]\Show))
      EndIf
      
      For i = 0 To *Debugger\HistorySize-1
        ResizeGadget(*history\item[i]\Line, 5, 5, InnerWidth-15-ButtonWidth, ButtonHeight)
        ResizeGadget(*history\item[i]\File, 5, 5+ButtonHeight, InnerWidth, ButtonHeight)
        ResizeGadget(*history\item[i]\Show, 5+InnerWidth-ButtonWidth, 5, ButtonWidth, ButtonHeight)
        ResizeGadget(*history\item[i]\Call, 5, 15+ButtonHeight*2, InnerWidth, ButtonHeight)
        ResizeGadget(*history\item[i]\Variables, 5, 5+ContainerHeight, InnerWidth, 195)
        
        If GetGadgetState(*history\item[i]\Show) = 0
          ResizeGadget(*history\item[i]\Container, 5, Top, ContainerWidth, ContainerHeight)
          Top + ContainerHeight + 10
        Else
          ResizeGadget(*history\item[i]\Container, 5, Top, ContainerWidth, ContainerHeight+210)
          Top + ContainerHeight + 220
        EndIf
      Next i
    EndIf
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentText], 5, 5, InnerWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentFile], 5, 10+ButtonHeight, InnerWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentLine], 5, 15+ButtonHeight*2, InnerWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentContainer], 5, Top, ContainerWidth, ContainerHeight)
    Top + ContainerHeight + 10
    
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea], #PB_ScrollArea_InnerWidth, Width - 50)
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea], #PB_ScrollArea_InnerHeight, Top + 10)
    
    ResetAllWidth = Max(120, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll]))
    ResetWidth    = Max(120, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset]))
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats], 10, 10, Width-20, Height-30-ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll], 10, Height-10-ButtonHeight, ResetAllWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset], 20+ResetAllWidth, Height-10-ButtonHeight, ResetWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_UpdateStats], Width-10-ButtonWidth, Height-10-ButtonHeight, ButtonWidth, ButtonHeight)
    
    
  ElseIf EventID = #PB_Event_CloseWindow
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_History]) = 0
      HistoryMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_History])
      If HistoryMaximize = 0
        HistoryWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_History])
        HistoryWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_History])
        HistoryWindowWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_History])
        HistoryWindowHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_History])
      EndIf
    EndIf
    
    If *Debugger\History
      *history.Debugger_History = *Debugger\History
      For i = 0 To *Debugger\HistorySize - 1
        VariableGadget_Free(*history\item[i]\Variables)
      Next i
      FreeMemory(*Debugger\History)
      *Debugger\History = 0
      *Debugger\HistorySize = 0
    EndIf
    
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_History])
    *Debugger\Windows[#DEBUGGER_WINDOW_History] = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateHistoryWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll], 1)
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll], 0)
    
    If *Debugger\ProgramState <> 0 And *Debugger\ProgramState <> -2
      Command.CommandInfo\Command = #COMMAND_GetHistory
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetProcedureStats
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
  EndIf
  
EndProcedure

Procedure OpenHistoryWindow(*Debugger.DebuggerData)
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_History]
    SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_History])
    
  Else
    Window = OpenWindow(#PB_Any, HistoryWindowX, HistoryWindowY, HistoryWindowWidth, HistoryWindowHeight, Language("Debugger","HistoryWindowTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_History] = Window
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel] = PanelGadget(#PB_Any, 0, 0, 0, 0)
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel], -1, Language("Debugger","History"))
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea] = ScrollAreaGadget(#PB_Any, 0, 0, 0, 0, 1000, 1000, 10, #PB_ScrollArea_Single)
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentContainer] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Single)
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentText] = TextGadget(#PB_Any, 5, 5, 0, 25, Language("Debugger","CurrentPosition"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentLine] = TextGadget(#PB_Any, 5, 35, 0, 25, "")
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentFile] = TextGadget(#PB_Any, 5, 65, 0, 25, "")
      CloseGadgetList()
      CloseGadgetList()
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_Update] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_Updating] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Updating"), #PB_Text_Center)
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Updating], 1)
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel], -1, Language("Debugger","Statistics"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Name"), 300, #PB_ListIcon_MultiSelect|#PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats], 1, Language("Debugger","CallCount"), 100)
      
      
      If *Debugger\Procedures
        *Pointer = *Debugger\Procedures
        For i = 1 To *Debugger\NbPRocedures
          Name$ = PeekAscii(*Pointer) + "()"
          *Pointer + MemoryAsciiLength(*Pointer) + 1
          ModName$ = PeekAscii(*Pointer)
          *Pointer + MemoryAsciiLength(*Pointer) + 1
          AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats], -1, ModuleName(Name$, ModName$))
        Next i
        
        Command.CommandInfo\Command = #COMMAND_GetProcedureStats
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Reset"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","ResetAll"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_History_UpdateStats] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      
      CloseGadgetList()
      
      EnsureWindowOnDesktop(Window)
      If HistoryMaximize
        ShowWindowMaximized(Window)
      Else
        HideWindow(Window, 0)
      EndIf
      HistoryWindowEvents(*Debugger, #PB_Event_SizeWindow)
      
      CompilerIf #DEFAULT_CanWindowStayOnTop
        SetWindowStayOnTop(Window, DebuggerOnTop)
      CompilerEndIf
      
      Debugger_AddShortcuts(Window)
      
      Command.CommandInfo\Command = #COMMAND_GetHistory
      SendDebuggerCommand(*Debugger, @Command)
      
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
    EndIf
  EndIf
  
EndProcedure

Procedure UpdateHistoryWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_History], Language("Debugger","HistoryWindowTitle") + " - " + GetFilePart(*Debugger\FileName$))
  
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel], 0, Language("Debugger","History"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Panel], 1, Language("Debugger","Statistics"), 0)
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], Language("Debugger","Update"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Updating], Language("Debugger","Updating"))
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Reset], Language("Debugger","Reset"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ResetAll], Language("Debugger","ResetAll"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_UpdateStats], Language("Debugger","Update"))
  
  HistoryWindowEvents(*Debugger, #PB_Window_SizeGadget) ; update button sizes
  
EndProcedure

Procedure History_DebuggerEvent(*Debugger.DebuggerData)
  
  If *Debugger\Command\Command = #COMMAND_ControlCallstack
    OpenHistoryWindow(*Debugger)
    ProcedureReturn     ; do not run the rest of this code
  EndIf
  
  ; ignore these messages when the window is closed
  ;
  If *Debugger\Windows[#DEBUGGER_WINDOW_History] = 0
    ProcedureReturn
  EndIf
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_History
      
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Updating], 0)
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea], 1)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], 1)
      
      ; delete the old gadgets & data
      ;
      If *Debugger\History
        *history.Debugger_History = *Debugger\History
        For i = 0 To *Debugger\HistorySize - 1
          VariableGadget_Free(*history\item[i]\Variables)
          FreeGadget(*history\item[i]\Container)
        Next i
        FreeMemory(*Debugger\History)
        *Debugger\History = 0
        *Debugger\HistorySize = 0
      EndIf
      
      If *Debugger\Command\Value1 > 0
        *Debugger\HistorySize = *Debugger\Command\Value1
        *Debugger\History = AllocateMemory(*Debugger\HistorySize * SizeOf(Debugger_HistoryData))
        If *Debugger\History
          *history.Debugger_History = *Debugger\History
          *pointer = *Debugger\CommandData
          
          OpenGadgetList(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea])
          
          For i = 0 To *Debugger\HistorySize-1
            Line = PeekL(*Pointer): *Pointer + 4
            Call$ = PeekS(*Pointer): *Pointer + MemoryStringLengthBytes(*Pointer) + #CharSize ; not ascii!
            
            *history\item[i]\Container   = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Single)
            *history\item[i]\Line      = TextGadget(#PB_Any, 5, 5, 0, 25, Language("Debugger","Line")+": "+Str(DebuggerLineGetLine(Line)+1))
            *history\item[i]\File      = TextGadget(#PB_Any, 5, 35, 0, 25, Language("Debugger","File")+": "+GetDebuggerRelativeFile(*Debugger, Line))
            *history\item[i]\Show      = ButtonGadget(#PB_Any, 0, 5, 110, 25, Language("Debugger","ShowVariables"), #PB_Button_Toggle)
            *history\item[i]\Call      = StringGadget(#PB_Any, 5, 65, 0, 25, Call$, #PB_String_ReadOnly)
            *history\item[i]\Variables = VariableGadget_Create(#PB_Any, 5, 100, 0, 195, Language("Debugger","Scope"), #True, #False)
            CloseGadgetList()
            
            Command.CommandInfo\Command = #COMMAND_GetHistoryLocals
            Command\Value1 = i
            SendDebuggerCommand(*Debugger, @Command)
          Next i
          
          CloseGadgetList()
          
        EndIf
      EndIf
      
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentLine], Language("Debugger","Line")+": "+Str(DebuggerLineGetLine(*Debugger\Command\Value2) + 1))
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_CurrentFile], Language("Debugger","File")+": "+GetDebuggerRelativeFile(*Debugger, *Debugger\Command\Value2))
      
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Updating], 1)
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_ScrollArea], 0)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Update], 0)
      
      HistoryWindowEvents(*Debugger, #PB_Event_SizeWindow)
      
      
    Case  #COMMAND_HistoryLocals
      
      If *Debugger\History
        *history.Debugger_History = *Debugger\History
        If *Debugger\Command\Value1 < *Debugger\HistorySize
          
          VariableGadget_Lock(*history\item[*Debugger\Command\Value1]\Variables)
          VariableGadget_Allocate(*history\item[*Debugger\Command\Value1]\Variables, *Debugger\Command\Value2)
          VariableGadget_Use(*history\item[*Debugger\Command\Value1]\Variables)
          
          *Pointer = *Debugger\CommandData
          For i = 1 To *Debugger\Command\Value2
            type = PeekB(*Pointer) & ~(1<<6) ; remove the direct param flag right at the start
            *Pointer + 1
            dynamictype = PeekB(*Pointer)
            *Pointer + 1
            scope = PeekB(*Pointer)
            *Pointer + 1
            sublevel = PeekL(*Pointer)
            *Pointer + 4
            name$ = PeekAscii(*Pointer)
            *Pointer + MemoryAsciiLength(*Pointer) + 1
            
            Select scope
              Case #SCOPE_GLOBAL: ScopeName$ = ""
              Case #SCOPE_LOCAL:  ScopeName$ = "Local"
              Case #SCOPE_STATIC: ScopeName$ = "Static"
              Case #SCOPE_SHARED: ScopeName$ = "Shared"
            EndSelect
            
            VariableGadget_Add(type, dynamictype, sublevel, ScopeName$, name$, "", *Pointer, *Debugger\Is64bit)
            *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
          Next i
          
          VariableGadget_Unlock(*history\item[*Debugger\Command\Value1]\Variables)
          VariableGadget_Sort(*history\item[*Debugger\Command\Value1]\Variables)
          
        EndIf
      EndIf
      
    Case #COMMAND_Procedures
      If *Debugger\Procedures
        ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats])
        *Pointer = *Debugger\Procedures
        For i = 1 To *Debugger\NbPRocedures
          Name$ = PeekAscii(*Pointer) + "()"
          *Pointer + MemoryAsciiLength(*Pointer) + 1
          ModName$ = PeekAscii(*Pointer)
          *Pointer + MemoryAsciiLength(*Pointer) + 1
          AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats], -1, ModuleName(Name$, ModName$))
        Next i
        
        Command.CommandInfo\Command = #COMMAND_GetPRocedureStats
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
    Case #COMMAND_ProcedureStats
      *stats.ProcedureStats_List = *Debugger\CommandData
      For i = 0 To *Debugger\Command\Value1 - 1
        SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_History_Stats], i, Str(*stats\callcount[i]), 1)
      Next i
      
  EndSelect
  
EndProcedure
