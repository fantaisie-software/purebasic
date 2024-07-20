; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Global NextDataBreakPointID = 1
Global RemoveDataBreakpoints = #False ; is #True when there are breakpoints to remove

Procedure FindDataBreakpoint(*Debugger.DebuggerData, ID)
  ; Check the debugger data linked list
  *Point.DataBreakPoint = *Debugger\FirstDataBreakPoint
  
  While *Point
    If *Point\ID = ID
      ProcedureReturn *Point
    Else
      *Point = *Point\Next
    EndIf
  Wend
  
  ProcedureReturn 0
EndProcedure

; removes only from the external debugger data, not from the exe!
Procedure DeleteDataBreakPoint(*Debugger.DebuggerData, *Point.DataBreakPoint)
  If *Point\Next
    *Point\Next\Previous = *Point\Previous
  EndIf
  If *Point\Previous
    *Point\Previous\Next = *Point\Next
  EndIf
  If *Point = *Debugger\FirstDataBreakPoint
    *Debugger\FirstDataBreakPoint = *Point\Next
  EndIf
  
  CompilerIf #CompilePPC
    Debug "FIXME: ClearStructure() broken on PPC"
  CompilerElse
    ClearStructure(*Point, DataBreakPoint)
  CompilerEndIf
  
  FreeMemory(*Point)
EndProcedure

Procedure BreakPoint_AddItem(*Debugger.DebuggerData)
  
  Condition$ = GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition])
  If Condition$ <> ""
    *Point.DataBreakPoint = AllocateMemory(SizeOf(DataBreakPoint))
    *Buffer               = AllocateMemory(StringByteLength(Condition$)+SizeOf(Character) + SizeOf(Long))
    If *Point And *Buffer
      ; (-2 = all)
      ; (-1 = main)
      ProcedureIndex = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure])-2
      
      If ProcedureIndex = -2
        *Point\ProcedureName$ = ""
      Else
        *Point\ProcedureName$ = GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], ProcedureIndex+2)
      EndIf
      
      *Point\Condition$     = Condition$
      *Point\ID             = NextDataBreakPointID
      NextDataBreakPointID + 1
      
      ; add to list
      *Point\Previous = 0
      *Point\Next     = *Debugger\FirstDataBreakPoint
      If *Debugger\FirstDataBreakPoint
        *Debugger\FirstDataBreakPoint\Previous = *Point
      EndIf
      *Debugger\FirstDataBreakPoint = *Point
      
      Command.CommandInfo\Command = #COMMAND_BreakPoint
      Command\Value1   = 4 ; add data breakpoint
      Command\Value2   = ProcedureIndex
      Command\DataSize = StringByteLength(Condition$)+SizeOf(Character)+SizeOf(Long)
      PokeL(*Buffer, *Point\ID)
      PokeS(*Buffer+SizeOf(Long), Condition$)
      SendDebuggerCommandWithData(*Debugger, @Command, *Buffer)
      FreeMemory(*Buffer)
      ; We add the Condition to the list when we get the reply with ok or failure
      
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition], "")
    EndIf
  EndIf
  
EndProcedure

Procedure DataBreakpointWindowEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_Menu   ; for the Enter shortcut
    If EventMenu() = #DEBUGGER_MENU_Return
      If GetActiveGadget() = *Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition]
        BreakPoint_AddItem(*Debugger)
      EndIf
    EndIf
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Add]
        BreakPoint_AddItem(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Remove]
        index = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List])
        If index <> -1
          Command.CommandInfo\Command = #COMMAND_BreakPoint
          Command\Value1 = 5 ; remove data breakpoint
          Command\Value2 = GetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index) ; this is the ID
          SendDebuggerCommand(*Debugger, @Command)
          RemoveGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Clear]
        Command.CommandInfo\Command = #COMMAND_BreakPoint
        Command\Value1 = 6 ; clear data breakpoints
        SendDebuggerCommand(*Debugger, @Command)
        ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List])
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
    Height = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Add], @ButtonWidth, @ButtonHeight)
    ButtonWidth  = Max(ButtonWidth, 120)
    ButtonWidth  = Max(ButtonWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Remove]))
    ButtonWidth  = Max(ButtonWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Clear]))
    ComboHeight  = GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure])
    StringHeight = GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition])
    TextWidth    = Max(80, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Text1]))
    TextWidth    = Max(TextWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Text2]))
    TopOffset    = Frame3DTopOffset(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Frame]) + 5
    
    BoxHeight    = Max(ButtonHeight*3+20, TopOffset+ComboHeight+StringHeight+20)
    ButtonHeight = (BoxHeight-20) / 3
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], 10, 10, Width-20, Height-30-BoxHeight)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Frame], 10, Height-10-BoxHeight, Width-30-ButtonWidth, BoxHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Text1], 25, Height-10-BoxHeight+TopOffset, TextWidth, ComboHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Text2], 25, Height-BoxHeight+TopOffset+ComboHeight, TextWidth, StringHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], 30+TextWidth, Height-10-BoxHeight+TopOffset, Width-65-ButtonWidth-TextWidth, ComboHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition],  30+TextWidth, Height-BoxHeight+TopOffset+ComboHeight, Width-65-ButtonWidth-TextWidth, StringHeight)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Add],    Width-10-ButtonWidth, Height-30-ButtonHeight*3, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Remove], Width-10-ButtonWidth, Height-20-ButtonHeight*2, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Clear],  Width-10-ButtonWidth, Height-10-ButtonHeight*1, ButtonWidth, ButtonHeight)
    
  ElseIf EventID = #PB_Event_CloseWindow
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints]) = 0
      DataBreakpointWindowMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
      If DataBreakpointWindowMaximize = 0
        DataBreakpointWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
        DataBreakpointWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
        DataBreakpointWindowWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
        DataBreakpointWindowHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints])
      EndIf
    EndIf
    
    ; do not close window, only hide it
    ;
    HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints], 1)
    *Debugger\DataBreakpointsVisible = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateDataBreakpointWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Add], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Remove], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Clear], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition], 1)
    
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Add], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Remove], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Clear], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Condition], 0)
    
    ; With the next update after the stop by the breakpoint, remove it
    ;
    If *Debugger\ProgramState <> 9 And RemoveDataBreakpoints
      ; step backwards so indexes don't change by removals
      For i = CountGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List])-1 To 0 Step -1
        *Point.DataBreakPoint = GetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], i)
        If *Point And *Point\ConditionTrue
          RemoveGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], i)
          DeleteDataBreakPoint(*Debugger, *Point)
        EndIf
      Next i
      
      RemoveDataBreakpoints = #False
    EndIf
    
  EndIf
  
EndProcedure

Procedure OpenDataBreakpointWindow(*Debugger.DebuggerData)
  
  If *Debugger\DataBreakpointsVisible = 0
    
    EnsureWindowOnDesktop(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints])
    HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints], 0) ; show the window first.. otherwise sometimes the move/resize does not seem to work !?
    
    If DataBreakpointWindowWidth = 0 Or DataBreakpointWindowHeight = 0
      DataBreakpointWindowX           = 75
      DataBreakpointWindowY           = 75
      DataBreakpointWindowWidth       = 700
      DataBreakpointWindowHeight      = 300
    EndIf
    
    ResizeWindow(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints], DataBreakpointWindowX, DataBreakpointWindowY, DataBreakpointWindowWidth, DataBreakpointWindowHeight)
    DataBreakpointWindowEvents(*Debugger, #PB_Event_SizeWindow)
    
    ; the filename is set after creation, so update it here...
    SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints], Language("Debugger","DataBreakpoints") + " - " + DebuggerTitle(*Debugger\FileName$))
    
    *Debugger\DataBreakpointsVisible = 1
  EndIf
  
  SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints])
  DataBreakpointWindowEvents(*Debugger, #PB_Event_SizeWindow)
  
EndProcedure

; this actually creates the window, but keeps it hidden
;
Procedure CreateDataBreakpointWindow(*Debugger.DebuggerData)
  
  Flags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget
  If DataBreakpointWindowMaximize
    Flags | #PB_Window_Maximize
  EndIf
  
  Window = OpenWindow(#PB_Any, 0, 0, 0, 0, Language("Debugger","DataBreakpoints") + " - " + GetFilePart(*Debugger\FileName$), Flags)
  If Window
    
    *Debugger\Windows[#DEBUGGER_WINDOW_DataBreakpoints] = Window
    
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_List] = ListIconGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger", "Procedure"), 100, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect)
    AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_List], 1, Language("Debugger", "Condition"), 350)
    AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_List], 2, Language("Debugger", "ConditionStatus"), 250)
    
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Frame] = FrameGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","AddBreakPoint")+":")
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Text1] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Procedure")+":", #PB_Text_Right)
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Text2] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Condition")+":", #PB_Text_Right)
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Procedure] = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Condition] = StringGadget(#PB_Any, 0, 0, 0, 0, "")
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Add] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Add"))
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Remove] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Remove"))
    *Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Clear] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Clear"))
    
    *Debugger\DataBreakpointsVisible = 0
    
    CompilerIf #DEFAULT_CanWindowStayOnTop
      SetWindowStayOnTop(Window, DebuggerOnTop)
    CompilerEndIf
    
    AddKeyboardShortcut(Window, #PB_Shortcut_Return, #DEBUGGER_MENU_Return)
    Debugger_AddShortcuts(Window)
  EndIf
  
EndProcedure

Procedure UpdateDataBreakpointWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_DataBreakPoints], Language("Debugger","DataBreakpoints") + " - " + GetFilePart(*Debugger\FileName$))
  
  
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_List], -1, Language("Debugger", "Procedure"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_List], -1, Language("Debugger", "Condition"), 1)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_List], -1, Language("Debugger", "ConditionStatus"), 2)
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Frame], Language("Debugger", "AddBreakPoint")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Text1], Language("Debugger", "Procedure")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Text2], Language("Debugger", "Condition")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Add], Language("Debugger", "Add"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Remove], Language("Debugger", "Remove"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Breakpoint_Clear], Language("Debugger", "Clear"))
  
  DataBreakpointWindowEvents(*Debugger, #PB_Event_SizeWindow) ; update button sizes
  
EndProcedure

; ---------------------------------------------------------

Procedure DataBreakpoint_DebuggerEvent(*Debugger.DebuggerData)
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_Procedures
      ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure])
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], -1, Language("Debugger","AllProcedures"))
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], -1, Language("Debugger","NoProcedure"))
      *Pointer = *Debugger\Procedures
      For i = 1 To *Debugger\NbProcedures
        Name$ = PeekAscii(*Pointer) + "()"
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        ModName$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], -1, ModuleName(Name$, ModName$))
      Next i
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_Procedure], 0)
      
    Case #COMMAND_DataBreakPoint
      *Point.DataBreakPoint = FindDataBreakpoint(*Debugger, *Debugger\Command\Value2) ; find our structure
      If *Point
        ; find the entry in the gadget (if any)
        index = -1
        last  = CountGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List])-1
        For i = 0 To last
          If *Point = GetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], i)
            index = i
            Break
          EndIf
        Next i
        
        Select *Debugger\Command\Value1 ; status
            
          Case 1 ; added
            index = CountGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List])
            AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, *Point\ProcedureName$+Chr(10)+*Point\Condition$)
            SetGadgetItemData(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, *Point)
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index)
            
          Case 2 ; cannot add
            MessageRequester("PureBasic Debugger", Language("Debugger","BreakPointError")+#NewLine+*Point\Condition$, #FLAG_Warning)
            DeleteDataBreakPoint(*Debugger, *Point) ; delete from list
            
          Case 3 ; eval error
            If index <> -1
              SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, PeekS(*Debugger\CommandData, *Debugger\Command\DataSize, #PB_Ascii), 2)
              SetGadgetItemColor(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, #PB_Gadget_BackColor, $90FFFF, -1)
            EndIf
            
          Case 4 ; false
            If index <> -1
              SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, "#False", 2)
              SetGadgetItemColor(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, #PB_Gadget_BackColor, -1, -1)
            EndIf
            
          Case 5 ; true
                 ; indicate that the breakpoint is true, but do not remove it
                 ; will be removed in UpdateWaichListWindowState() when the program continues
            If index <> -1
              SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, "#True", 2)
              SetGadgetItemColor(*Debugger\Gadgets[#DEBUGGER_GADGET_BreakPoint_List], index, #PB_Gadget_BackColor, $90FF90, -1)
            EndIf
            *Point\ConditionTrue = #True
            RemoveDataBreakpoints = #True
            
        EndSelect
      EndIf
      
  EndSelect
  
EndProcedure