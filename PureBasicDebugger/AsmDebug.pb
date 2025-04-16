; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


#RegisterHasString = 1<<15

; This is only needed on Window creation and Language update, so separate
; it from the normal resize code
;
Procedure ResizeRegisterDisplay(*Debugger.DebuggerData)
  
  If *Debugger\RegisterCount > 0 ; we need to have the register layout here!
    
    ; All buttons have the same text. Also buttons are always higher than string/text gadgets
    ; so the height can be used for all
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Set0], @ButtonWidth, @ButtonHeight)
    ButtonWidth = Max(ButtonWidth, 50)
    
    RegistersWithText = 0
    RegisterTextHeight = GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Text0])
    
    ; get widths for text column
    For i = 0 To *Debugger\RegisterCount-1
      TextWidth = Max(TextWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Text0+i]))
      
      If *Debugger\RegisterIndex[i] & #RegisterHasString
        RegistersWithText + 1
      EndIf
    Next i
    
    TextWidth = Max(TextWidth, 70)
    
    If *Debugger\Is64bit
      BoxWidth = 140
    Else
      BoxWidth = 220
    EndIf
    
    ; resize
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], #PB_ScrollArea_InnerWidth, TextWidth + ButtonWidth + 30 + BoxWidth)
    SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], #PB_ScrollArea_InnerHeight, *Debugger\RegisterCount * (ButtonHeight+10) + 10 + (RegisterTextHeight + 5) * RegistersWithText)
    
    Y = 10
    
    For i = 0 To *Debugger\RegisterCount-1
      CompilerIf #CompileWindows
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Text0+i], 10, Y+2, TextWidth, ButtonHeight)
      CompilerElse
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Text0+i], 10, Y, TextWidth, ButtonHeight)
      CompilerEndIf
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i], 10+TextWidth, Y, BoxWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Set0+i], 20+TextWidth+BoxWidth, Y, ButtonWidth, ButtonHeight)
      
      If *Debugger\RegisterIndex[i] & #RegisterHasString
        ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_TextValue0+i], 10+TextWidth, Y+ButtonHeight+5, 10+BoxWidth+ButtonWidth, RegisterTextHeight)
        Y + ButtonHeight+15+RegisterTextHeight
      Else
        Y + ButtonHeight+10
      EndIf
    Next i
    
  EndIf
  
EndProcedure


; Called as soon as the Register layout is known
;
Procedure CreateRegisterGadgets(*Debugger.DebuggerData)
  
  OpenGadgetList(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea])
  
  For i = 0 To *Debugger\RegisterCount-1
    *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Text0+i]  = TextGadget(#PB_Any, 0, 0, 0, 0, *Debugger\RegisterName$[i]+" : ", #PB_Text_Right)
    *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i] = StringGadget(#PB_Any, 0, 0, 0, 0, "")
    *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Set0+i]   = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Set"))
    
    If *Debugger\RegisterIndex[i] & #RegisterHasString
      *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_TextValue0+i] = TextGadget(#PB_Any, 0, 0, 0, 0, "")
    EndIf
  Next i
  
  CloseGadgetList()
  
  ResizeRegisterDisplay(*Debugger)
  
EndProcedure



Procedure AsmWindowEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_Gadget
    EventGadgetID = EventGadget()
    If EventGadgetID = *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack]
      
      Command.CommandInfo\Command = #COMMAND_GetStack
      Command\Value1 = StackIsHex
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
      
    Else
      For i = 0 To *Debugger\RegisterCount-1
        If EventGadgetID = *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Set0+i]
          
          Command.CommandInfo\Command = #COMMAND_SetRegister
          Command\Value1 = *Debugger\RegisterIndex[i] & ~#RegisterHasString
          
          ; Note: The RegisterIsHex is now determined by the $ in the gadget,
          ;   as Val now supports $ as prefix
          If *Debugger\Is64bit
            Value_q.q = Val(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i]))
            Command\DataSize = 8
            SendDebuggerCommandWithData(*Debugger, @Command, @Value_q)
          Else
            Value_l.l = Val(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i]))
            Command\DataSize = 4
            SendDebuggerCommandWithData(*Debugger, @Command, @Value_l)
          EndIf
          
          ; request data updates to see if it worked and update flags strings etc
          ;
          Command.CommandInfo\Command = #COMMAND_GetRegister
          Command\DataSize = 0
          SendDebuggerCommand(*Debugger, @Command)
          
          Break
        EndIf
      Next i
    EndIf
    
  ElseIf EventID = #PB_Event_SizeWindow
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel], 10, 10, WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])-20, WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])-20)
    
    CompilerIf #CompileLinuxGtk
      ; the resize fails on Linux else
      ; (failure to calculate the PanelGadget size?)
      FlushEvents()
    CompilerEndIf
    
    Width  = GetPanelWidth (*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel])
    Height = GetPanelHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel])
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], 0, 0, Width, Height)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Message], 10, 10, Width-20, Height-20)
    
    If AutoStackUpdate
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack], 10, 10, Width-20, Height-20)
    Else
      GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], @ButtonWidth, @ButtonHeight)
      ButtonWidth = Max(120, ButtonWidth)
      
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack], 10, 10, Width-20, Height-30-ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], Width-10-ButtonWidth, Height-10-ButtonHeight, ButtonWidth, ButtonHeight)
    EndIf
    
  ElseIf EventID = #PB_Event_CloseWindow
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_Asm]) = 0
      AsmWindowMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
      If AsmWindowMaximize = 0
        AsmWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
        AsmWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
        AsmWindowWidth  = WindowWidth(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
        AsmWindowHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
      EndIf
    EndIf
    
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
    *Debugger\Windows[#DEBUGGER_WINDOW_Asm] = 0
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateAsmWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = 3 Or *Debugger\ProgramState = 7 Or *Debugger\ProgramState = 8 Or *Debugger\ProgramState = 9
    ;
    ; the data can be accessed
    ;
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Message], 1)
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], 0)
    
    ; send this command first, if not done yet
    If *Debugger\RegisterCount = 0
      Command.CommandInfo\Command = #COMMAND_GetRegisterLayout ; request the layout first
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
    
    ; request data updates
    ;
    Command.CommandInfo\Command = #COMMAND_GetRegister
    Command\DataSize = 0
    SendDebuggerCommand(*Debugger, @Command)
    
    If AutoStackUpdate
      Command.CommandInfo\Command = #COMMAND_GetStack
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
    
  Else
    ;
    ; the data is not available
    ;
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Message], 0)
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], 1)
    
  EndIf
  
EndProcedure

Procedure OpenAsmWindow(*Debugger.DebuggerData)
  
  CompilerIf #CompilePPC
    ProcedureReturn
  CompilerEndIf
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Asm]
    SetWindowforeGround(*Debugger\Windows[#DEBUGGER_WINDOW_Asm])
    
  Else
    
    Window = OpenWindow(#PB_Any, AsmWindowX, AsmWindowY, AsmWindowWidth, AsmWindowHeight, Language("Debugger","AsmWindowTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_Asm] = Window
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel] = PanelGadget(#PB_Any, 0, 0, 0, 0)
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel], -1, Language("Debugger","Registers"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Message] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","NoData"), #PB_Text_Center)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea] = ScrollAreaGadget(#PB_Any, 0, 0, 0, 0, 100, 100, 5)
      ; The gadgets are only added after #COMMAND_RegisterLayout is received
      CloseGadgetList()
      
      ; register layout already known
      If *Debugger\RegisterCount
        CreateRegisterGadgets(*Debugger)
      EndIf
      
      AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel], -1, Language("Debugger","Stack"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack] = EditorGadget(#PB_Any, 0, 0, 0, 0)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      
      Debugger_AddShortcuts(Window)
      
      If EditorFontID
        SetGadgetFont(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack], EditorFontID)
      EndIf
      
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack], #PB_Editor_ReadOnly, 1)
      
      CloseGadgetList()
      
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], 1)
      If AutoStackUpdate
        HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], 1)
      EndIf
      
      CompilerIf #DEFAULT_CanWindowStayOnTop
        SetWindowStayOnTop(Window, DebuggerOnTop)
      CompilerEndIf
      
      EnsureWindowOnDesktop(Window)
      If AsmWindowMaximize
        ShowWindowMaximized(Window)
      Else
        HideWindow(Window, 0)
      EndIf
      
      AsmWindowEvents(*Debugger, #PB_Event_SizeWindow)
      
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
    EndIf
    
  EndIf
  
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Asm]
    
    ; send the proper commands to get the data
    ;
    If *Debugger\ProgramState <> 0 Or *Debugger\ProgramState <> -1
      ; stopped but loaded, lets give it a try
      
      ; send this command first, if not done yet
      If *Debugger\RegisterCount = 0
        Command.CommandInfo\Command = #COMMAND_GetRegisterLayout ; request the layout first
        Command\DataSize = 0
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      Command.CommandInfo\Command = #COMMAND_GetRegister
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
      
      Command.CommandInfo\Command = #COMMAND_GetStack
      Command\Value1 = StackIsHex
      Command\DataSize = 0
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
    
  EndIf
  
EndProcedure

Procedure UpdateAsmWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Asm], Language("Debugger","AsmWindowTitle") + " - " + GetFilePart(*Debugger\FileName$))
  
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel], 0, Language("Debugger","Registers"), 0)
  SetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Panel], 1, Language("Debugger","Stack"), 0)
  
  For i = 0 To *Debugger\RegisterCount-1
    SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Text0+i], Language("Debugger","Set"))
  Next i
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], Language("Debugger","Update"))
  
  If AutoStackUpdate
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], 1)
  Else
    HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_UpdateStack], 0)
  EndIf
  
  ResizeRegisterDisplay(*Debugger) ; resize the register display if needed
  AsmWindowEvents(*Debugger, #PB_Event_SizeWindow)
  
EndProcedure

Procedure AsmDebug_DebuggerEvent(*Debugger.DebuggerData)
  
  If *Debugger\Command\Command = #COMMAND_ControlAssemblyViewer
    OpenAsmWindow(*Debugger)
    ProcedureReturn     ; do not run the rest of this code
  EndIf
  
  ; ignore these messages when the window is closed
  ;
  If *Debugger\Windows[#DEBUGGER_WINDOW_Asm] = 0
    ProcedureReturn
  EndIf
  
  If *Debugger\Command\Command = #COMMAND_RegisterLayout
    *Debugger\RegisterCount = *Debugger\Command\Value1
    *Pointer = *Debugger\CommandData
    
    For i = 0 To *Debugger\RegisterCount-1
      *Debugger\RegisterIndex[i] = PeekW(*Pointer) & $FFFF ; cast to long to not get "signed word" issues
      *Pointer + 2
    Next i
    
    For i = 0 To *Debugger\RegisterCount-1
      *Debugger\RegisterName$[i] = PeekAscii(*Pointer)
      *Pointer + MemoryStringLength(*Pointer, #PB_Ascii) + 1
    Next i
    
    CreateRegisterGadgets(*Debugger)
    
  ElseIf *Debugger\Command\Command = #COMMAND_Register
    If *Debugger\Command\DataSize = 0 Or *Debugger\CommandData = 0  ; data not available
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Message], 0)
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], 1)
    Else
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Message], 1)
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_ScrollArea], 0)
      
      If *Debugger\Is64bit
        *Pointer = *Debugger\CommandData + *Debugger\RegisterCount * 8
      Else
        *Pointer = *Debugger\CommandData + *Debugger\RegisterCount * 4
      EndIf
      
      For i = 0 To *Debugger\RegisterCount-1
        index = *Debugger\RegisterIndex[i] & ~#RegisterHasString
        Debug "index: " + Str(index)
        
        
        If RegisterIsHex And *Debugger\Is64bit
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i], "$"+RSet(Hex(PeekQ(*Debugger\CommandData+index*8), #PB_Quad), 16, "0"))
        ElseIf *Debugger\Is64bit
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i], Str(PeekQ(*Debugger\CommandData+index*8)))
        ElseIf RegisterIsHex
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i], "$"+RSet(Hex(PeekL(*Debugger\CommandData+index*4), #PB_Long), 8, "0"))
        Else
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Value0+i], Str(PeekL(*Debugger\CommandData+index*4)))
        EndIf
        
        If *Debugger\RegisterIndex[i] & #RegisterHasString
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_TextValue0+i], "("+PeekAscii(*Pointer)+")")
          *Pointer + MemoryStringLength(*Pointer, #PB_Ascii) + 1
        EndIf
      Next i
    EndIf
    
  ElseIf *Debugger\Command\Command = #COMMAND_Stack
    If *Debugger\Command\DataSize = 0  ; data not available
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack], Language("Debugger","NoData"))
    Else
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Asm_Stack], PeekAscii(*Debugger\CommandData))
    EndIf
    
  EndIf
  
EndProcedure
