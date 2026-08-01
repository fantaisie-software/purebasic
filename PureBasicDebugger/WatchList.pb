; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



Procedure WatchList_AddItem(*Debugger.DebuggerData)
  
  Variable$ = GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable])
  If Variable$ <> ""
    Command.CommandInfo\Command = #COMMAND_WatchlistAdd
    Command\Value1 = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure])-1
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
    
    SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable], "")
  EndIf
  
EndProcedure


Procedure WatchListWindowEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_Menu   ; for the Enter shortcut
    If EventMenu() = #DEBUGGER_MENU_Return
      If GetActiveGadget() = *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable]
        WatchList_AddItem(*Debugger)
      EndIf
    EndIf
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List]
        VariableGadget_Event(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add]
        WatchList_AddItem(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove]
        index = VariableGadget_GetState(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
        If index <> -1
          Command.CommandInfo\Command = #COMMAND_WatchlistRemove
          Command\Value1 = index
          SendDebuggerCommand(*Debugger, @Command)
          
          Command.CommandInfo\Command = #COMMAND_GetWatchlist
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear]
        Command.CommandInfo\Command = #COMMAND_WatchlistRemove
        Command\Value1 = -1
        SendDebuggerCommand(*Debugger, @Command)
        
        Command.CommandInfo\Command = #COMMAND_GetWatchlist
        SendDebuggerCommand(*Debugger, @Command)
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
    Height = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add], @ButtonWidth, @ButtonHeight)
    ButtonWidth  = Max(ButtonWidth, 120)
    ButtonWidth  = Max(ButtonWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove]))
    ButtonWidth  = Max(ButtonWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear]))
    ComboHeight  = GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure])
    StringHeight = GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable])
    TextWidth    = Max(80, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text1]))
    TextWidth    = Max(TextWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text2]))
    TopOffset    = Frame3DTopOffset(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Frame]) + 5
    
    BoxHeight    = Max(ButtonHeight*3+20, TopOffset+ComboHeight+StringHeight+20)
    ButtonHeight = (BoxHeight-20) / 3
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List], 10, 10, Width-20, Height-30-BoxHeight)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Frame], 10, Height-10-BoxHeight, Width-30-ButtonWidth, BoxHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text1], 25, Height-10-BoxHeight+TopOffset, TextWidth, ComboHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text2], 25, Height-BoxHeight+TopOffset+ComboHeight, TextWidth, StringHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], 30+TextWidth, Height-10-BoxHeight+TopOffset, Width-65-ButtonWidth-TextWidth, ComboHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable],  30+TextWidth, Height-BoxHeight+TopOffset+ComboHeight, Width-65-ButtonWidth-TextWidth, StringHeight)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add],    Width-10-ButtonWidth, Height-30-ButtonHeight*3, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove], Width-10-ButtonWidth, Height-20-ButtonHeight*2, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear],  Width-10-ButtonWidth, Height-10-ButtonHeight*1, ButtonWidth, ButtonHeight)
    
  ElseIf EventID = #PB_Event_CloseWindow
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList]) = 0
      WatchListWindowMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
      If WatchListWindowMaximize = 0
        WatchListWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
        WatchListWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
        WatchListWindowWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
        WatchListWindowHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
      EndIf
    EndIf
    
    ; do not close window, only hide it
    ;
    HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList], 1)
    *Debugger\IsWatchListVisible = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateWatchListWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable], 1)
    
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable], 0)
    
  EndIf
  
EndProcedure

Procedure OpenWatchlistWindow(*Debugger.DebuggerData)
  
  If *Debugger\IsWatchListVisible = 0
    
    EnsureWindowOnDesktop(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
    HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList], 0) ; show the window first.. otherwise sometimes the move/resize does not seem to work !?
    
    ;Debug "watchlist size: "+Str(WatchListWindowX)+"x"+Str(WatchListWindowY)
    
    If WatchListWindowWidth = 0 Or WatchListWindowHeight = 0
      WatchListWindowX           = 50
      WatchListWindowY           = 50
      WatchListWindowWidth       = 700
      WatchListWindowHeight      = 300
    EndIf
    
    ResizeWindow(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList], WatchListWindowX, WatchListWindowY, WatchListWindowWidth, WatchListWindowHeight)
    WatchListWindowEvents(*Debugger, #PB_Event_SizeWindow)
    
    ; something for better optics (must be after the first resize)
    CompilerIf #CompileWindows
      SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List]), #LVM_SETCOLUMNWIDTH, 3, #LVSCW_AUTOSIZE_USEHEADER)
    CompilerEndIf
    
    ; the filename is set after creation, so update it here...
    SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList], Language("Debugger","WatchListTitle") + " - " + DebuggerTitle(*Debugger\FileName$))
    
    *Debugger\IsWatchListVisible = 1
  EndIf
  
  SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList])
  WatchListWindowEvents(*Debugger, #PB_Event_SizeWindow)
  
EndProcedure

; this actually creates the window, but keeps it hidden
;
Procedure CreateWatchlistWindow(*Debugger.DebuggerData)
  
  Flags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget
  If WatchListWindowMaximize
    Flags | #PB_Window_Maximize
  EndIf
  
  Window = OpenWindow(#PB_Any, 0, 0, 0, 0, Language("Debugger","WatchListTitle") + " - " + GetFilePart(*Debugger\FileName$), Flags)
  If Window
    
    *Debugger\Windows[#DEBUGGER_WINDOW_WatchList] = Window
    
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List] = VariableGadget_Create(#PB_Any, 0, 0, 0, 0, Language("Debugger","Scope")+Chr(10)+Language("Debugger","Procedure"), #False, #False)
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Frame] = FrameGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","AddVariable")+":")
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text1] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Procedure")+":", #PB_Text_Right)
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text2] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Variable")+":", #PB_Text_Right)
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure] = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Variable] = StringGadget(#PB_Any, 0, 0, 0, 0, "")
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Add"))
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Remove"))
    *Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Clear"))
    
    *Debugger\IsWatchListVisible = 0
    
    CompilerIf #DEFAULT_CanWindowStayOnTop
      SetWindowStayOnTop(Window, DebuggerOnTop)
    CompilerEndIf
    
    AddKeyboardShortcut(Window, #PB_Shortcut_Return, #DEBUGGER_MENU_Return)
    Debugger_AddShortcuts(Window)
  EndIf
  
EndProcedure

Procedure UpdateWatchListWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_WatchList], Language("Debugger","WatchListTitle") + " - " + GetFilePart(*Debugger\FileName$))
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Frame], Language("Debugger", "AddVariable")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text1], Language("Debugger", "Procedure")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Text2], Language("Debugger", "Variable")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Add], Language("Debugger", "Add"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Remove], Language("Debugger", "Remove"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Clear], Language("Debugger", "Clear"))
  
  WatchListWindowEvents(*Debugger, #PB_Event_SizeWindow) ; update button sizes
  
EndProcedure

; ---------------------------------------------------------

Procedure WatchList_DebuggerEvent(*Debugger.DebuggerData)
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_ControlWatchlist
      OpenWatchlistWindow(*Debugger)
      
    Case #COMMAND_Procedures
      ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure])
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], -1, Language("Debugger","NoProcedure"))
      *Pointer = *Debugger\Procedures
      For i = 1 To *Debugger\NbProcedures
        Name$ = PeekAscii(*Pointer)+"()"
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        ModName$ = PeekAscii(*Pointer)
        *Pointer + MemoryAsciiLength(*Pointer) + 1
        AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], -1, ModuleName(Name$, ModName$))
      Next i
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], 0)
      
    Case #COMMAND_WatchlistError
      MessageRequester("PureBasic Debugger", Language("Debugger","VariableError")+#NewLine+PeekS(*Debugger\CommandData, *Debugger\Command\DataSize, #PB_UTF8), #FLAG_Warning)
      
    Case #COMMAND_Watchlist
      VariableGadget_Lock(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
      VariableGadget_Allocate(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List], *Debugger\Command\Value1)
      VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
      
      *Pointer = *Debugger\CommandData
      For i = 1 To *Debugger\Command\Value1
        type = PeekB(*Pointer)
        *Pointer + 1
        scope = PeekB(*Pointer)
        *Pointer + 1
        isvalid = PeekB(*Pointer)
        *Pointer + 1
        ProcedureIndex = PeekL(*Pointer)
        *Pointer + 4
        name$ = PeekS(*Pointer, -1, #PB_UTF8)
        *Pointer + MemoryUTF8LengthBytes(*Pointer) + 1
        
        Extra$ = ScopeName(scope)
        If ProcedureIndex = -1
          Extra$ + Chr(10)
        Else
          Extra$ + Chr(10) + GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_Procedure], ProcedureIndex+1, 0)
        EndIf
        
        If isvalid = 0
          VariableGadget_Add(type, 0, 0, Extra$, name$, "", 0, *Debugger\Is64bit)
          VariableGadget_SetString(i-1, "---", #False)
          
        Else
          VariableGadget_Add(type, 0, 0, Extra$, name$, "", *Pointer, *Debugger\Is64bit)
          *Pointer + GetValueSize(type, *Pointer, *Debugger\Is64bit)
          
        EndIf
        
      Next i
      
      VariableGadget_SyncAll() ; sync all SetString() calls with the display
      VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
      VariableGadget_Unlock(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
      
    Case #COMMAND_WatchlistEvent
      VariableGadget_Use(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
      If *Debugger\Command\Value1 = -1
        VariableGadget_SetString(*Debugger\Command\Value2, "---", #True) ; sync directly with the display
      ElseIf *Debugger\CommandData = 0
        VariableGadget_Set(*Debugger\Command\Value1, @*Debugger\Command\Value2, *Debugger\Is64bit, #True)
      Else
        VariableGadget_Set(*Debugger\Command\Value1, *Debugger\CommandData, *Debugger\Is64bit, #True)
      EndIf
      VariableGadget_Sort(*Debugger\Gadgets[#DEBUGGER_GADGET_WatchList_List])
      
      
  EndSelect
  
EndProcedure