; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


#MAX_PurifierState = 14

Procedure GranularityFromState(State)
  If State = #MAX_PurifierState
    ProcedureReturn 0 ; disable
  Else
    ProcedureReturn 1 << State ; nb of lines
  EndIf
EndProcedure

Procedure StateFromGranularity(Granularity)
  If Granularity <= 0 ; negative is not allowed, and 0 means disabled
    ProcedureReturn #MAX_PurifierState
  Else
    For State = 0 To #MAX_PurifierState-1
      If Granularity >= (1 << State) And Granularity < (1 << (State+1))
        ProcedureReturn State
      EndIf
    Next State
    
    ProcedureReturn #MAX_PurifierState-1
  EndIf
EndProcedure

Procedure UpdatePurifierLines(*Debugger.DebuggerData)
  Modified = 0
  
  State = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal])
  Select State
    Case 0
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesGlobal], Language("Debugger","CheckAlways"))
    Case #MAX_PurifierState
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesGlobal], Language("Debugger","CheckNever"))
    Default
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesGlobal], ReplaceString(Language("Debugger","CheckLines"), "%lines%", Str(1<<State)))
  EndSelect
  
  If GranularityFromState(State) <> *Debugger\PurifierGlobal
    Modified = 1
  EndIf
  
  State = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal])
  Select State
    Case 0
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesLocal], Language("Debugger","CheckAlways"))
    Case #MAX_PurifierState
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesLocal], Language("Debugger","CheckNever"))
    Default
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesLocal], ReplaceString(Language("Debugger","CheckLines"), "%lines%", Str(1<<State)))
  EndSelect
  
  If GranularityFromState(State) <> *Debugger\PurifierLocal
    Modified = 1
  EndIf
  
  State = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString])
  Select State
    Case 0
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesString], Language("Debugger","CheckAlways"))
    Case #MAX_PurifierState
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesString], Language("Debugger","CheckNever"))
    Default
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesString], ReplaceString(Language("Debugger","CheckLines"), "%lines%", Str(1<<State)))
  EndSelect
  
  If GranularityFromState(State) <> *Debugger\PurifierString
    Modified = 1
  EndIf
  
  State = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic])
  Select State
    Case 0
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesDynamic], Language("Debugger","CheckAlways"))
    Case #MAX_PurifierState
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesDynamic], Language("Debugger","CheckNever"))
    Default
      SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesDynamic], ReplaceString(Language("Debugger","CheckLines"), "%lines%", Str(1<<State)))
  EndSelect
  
  If GranularityFromState(State) <> *Debugger\PurifierDynamic
    Modified = 1
  EndIf
  
  If Modified
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply], 0)
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply], 1)
  EndIf
EndProcedure

; Apply a previously saved default options string
;
Procedure ApplyDefaultPurifierOptions(*Debugger.DebuggerData, OptionString$)
  If OptionString$
    OptionString$ = RemoveString(RemoveString(OptionString$, " "), Chr(9))
    
    If CountString(OptionString$, ",") >= 3
      ; previous options are present
      ; use the StateFromGranularity to sanitize the input
      *Debugger\PurifierGlobal  = GranularityFromState(StateFromGranularity(Val(StringField(OptionString$, 1, ","))))
      *Debugger\PurifierLocal   = GranularityFromState(StateFromGranularity(Val(StringField(OptionString$, 2, ","))))
      *Debugger\PurifierString  = GranularityFromState(StateFromGranularity(Val(StringField(OptionString$, 3, ","))))
      *Debugger\PurifierDynamic = GranularityFromState(StateFromGranularity(Val(StringField(OptionString$, 4, ","))))
    EndIf
    
    ; update window (if it is open)
    If *Debugger\Windows[#DEBUGGER_WINDOW_Purifier]
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal],  StateFromGranularity(*Debugger\PurifierGlobal))
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal],   StateFromGranularity(*Debugger\PurifierLocal))
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString],  StateFromGranularity(*Debugger\PurifierString))
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic], StateFromGranularity(*Debugger\PurifierDynamic))
      UpdatePurifierLines(*Debugger)
    EndIf
    
    ; send options to debugger
    If *Debugger\IsPurifier
      Protected Dim State.l(3)
      State(0) = *Debugger\PurifierGlobal
      State(1) = *Debugger\PurifierLocal
      State(2) = *Debugger\PurifierString
      State(3) = *Debugger\PurifierDynamic
      
      Command.CommandInfo\Command = #COMMAND_SetPurifier
      Command\DataSize = 4 * SizeOf(LONG)
      SendDebuggerCommandWithData(*Debugger, @Command, @State(0))
    EndIf
  EndIf
EndProcedure

; Get the current options string to save it for later debugger runs
;
Procedure.s GetPurifierOptions(*Debugger.DebuggerData)
  If *Debugger\PurifierGlobal = 1 And *Debugger\PurifierLocal = 1 And *Debugger\PurifierString = 64 And *Debugger\PurifierDynamic = 1
    ; default values, no need to store that. so return an empty string
    ProcedureReturn ""
  Else
    ProcedureReturn Str(*Debugger\PurifierGlobal) + "," + Str(*Debugger\PurifierLocal) + "," + Str(*Debugger\PurifierString) + "," + Str(*Debugger\PurifierDynamic)
  EndIf
EndProcedure

Procedure ApplyPurifierOptions(*Debugger.DebuggerData)
  *Debugger\PurifierGlobal  = GranularityFromState(GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal]))
  *Debugger\PurifierLocal   = GranularityFromState(GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal]))
  *Debugger\PurifierString  = GranularityFromState(GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString]))
  *Debugger\PurifierDynamic = GranularityFromState(GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic]))
  
  Protected Dim State.l(3)
  State(0) = *Debugger\PurifierGlobal
  State(1) = *Debugger\PurifierLocal
  State(2) = *Debugger\PurifierString
  State(3) = *Debugger\PurifierDynamic
  
  Command.CommandInfo\Command = #COMMAND_SetPurifier
  Command\DataSize = 4 * SizeOf(LONG)
  SendDebuggerCommandWithData(*Debugger, @Command, @State(0))
  
  UpdatePurifierLines(*Debugger) ; update the apply button
EndProcedure

CompilerIf #CompileWindows
  
  Procedure PurifierWindowCallback(Window, Message, wParam, lParam)
    
    If Message = #WM_HSCROLL
      *Debugger.DebuggerData = GetWindowLongPtr_(Window, #GWL_USERDATA)
      If *Debugger
        If lParam = GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal]) Or lParam = GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal]) Or lParam = GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString]) Or lParam = GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic])
          UpdatePurifierLines(*Debugger)
        EndIf
      EndIf
    EndIf
    
    ProcedureReturn #PB_ProcessPureBasicEvents
  EndProcedure
  
CompilerEndIf

Procedure PurifierWindowEvents(*Debugger.DebuggerData, EventID)
  Quit = 0
  
  If EventID = #PB_Event_Menu
    Select EventMenu()
        
      Case #DEBUGGER_MENU_Return
        ApplyPurifierOptions(*Debugger)
        Quit = 1
        
      Case #DEBUGGER_MENU_Escape
        Quit = 1
        
    EndSelect
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal]
        UpdatePurifierLines(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal]
        UpdatePurifierLines(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString]
        UpdatePurifierLines(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic]
        UpdatePurifierLines(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok]
        ApplyPurifierOptions(*Debugger)
        Quit = 1
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Cancel]
        Quit = 1
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply]
        ApplyPurifierOptions(*Debugger)
        
    EndSelect
    
  ElseIf EventID = #PB_Event_CloseWindow
    Quit = 1
    
  EndIf
  
  If Quit
    If DebuggerMemorizeWindows
      PurifierWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Purifier])
      PurifierWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Purifier]) ; not a resizable window
    EndIf
    
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Purifier])
    *Debugger\Windows[#DEBUGGER_WINDOW_Purifier] = 0
    Debugger_CheckDestroy(*Debugger)
  EndIf
  
EndProcedure

Procedure UpdatePurifierWindowState(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply], 1)
    
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok], 0)
    UpdatePurifierLines(*Debugger) ; updates the "Apply" button state
    
  EndIf
  
  
EndProcedure

Procedure ResizePurifierWindow(*Debugger.DebuggerData)
  ; The window is not resizable by the user, but we still need it
  ; For the initial sizing and resize on language change
  ;
  FrameOffset = Frame3DTopOffset(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Frame])
  GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextGlobal], @TextWidth, @TextHeight)
  TextWidth = Max(TextWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextLocal]))
  TextWidth = Max(TextWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextString]))
  TextWidth = Max(TextWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextDynamic]))
  LinesWidth = Max(GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesGlobal]), GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesLocal]))
  LinesWidth = Max(LinesWidth, 80)
  GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok], @ButtonWidth, @ButtonHeight)
  ButtonWidth = Max(ButtonWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Cancel]))
  ButtonWidth = Max(ButtonWidth, GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply]))
  ButtonWidth = Max(ButtonWidth, 90)
  TrackbarHeight = Max(TextHeight, 30)
  
  Width  = 350 + LinesWidth + 40           ; Width of trackbars
  Width  = Max(Width, TextWidth + 40)      ; Width of text
  Width  = Max(Width, ButtonWidth * 3 + 30); Width of buttons
  Height = 65 + FrameOffset + (TextHeight + TrackbarHeight + 15) * 4 + ButtonHeight
  
  ResizeWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Purifier], #PB_Ignore, #PB_Ignore, Width, Height)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Frame], 10, 10, Width-20, Height-40-ButtonHeight)
  
  Top = 25 + FrameOffset
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextGlobal], 20, Top, Width-40, TextHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal], 20, Top+TextHeight+5, Width-45-LinesWidth, TrackbarHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesGlobal], Width-20-LinesWidth, Top+TextHeight+5, LinesWidth, TrackbarHeight)
  Top + TextHeight + TrackbarHeight + 15
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextLocal], 20, Top, Width-40, TextHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal], 20, Top+TextHeight+5, Width-45-LinesWidth, TrackbarHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesLocal], Width-20-LinesWidth, Top+TextHeight+5, LinesWidth, TrackbarHeight)
  Top + TextHeight + TrackbarHeight + 15
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextString], 20, Top, Width-40, TextHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString], 20, Top+TextHeight+5, Width-45-LinesWidth, TrackbarHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesString], Width-20-LinesWidth, Top+TextHeight+5, LinesWidth, TrackbarHeight)
  Top + TextHeight + TrackbarHeight + 15
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextDynamic], 20, Top, Width-40, TextHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic], 20, Top+TextHeight+5, Width-45-LinesWidth, TrackbarHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesDynamic], Width-20-LinesWidth, Top+TextHeight+5, LinesWidth, TrackbarHeight)
  
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok], Width-20-ButtonWidth*3, Height-15-ButtonHeight, ButtonWidth, ButtonHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Cancel], Width-15-ButtonWidth*2, Height-15-ButtonHeight, ButtonWidth, ButtonHeight)
  ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply], Width-10-ButtonWidth, Height-15-ButtonHeight, ButtonWidth, ButtonHeight)
EndProcedure

Procedure OpenPurifierWindow(*Debugger.DebuggerData)
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Purifier]
    SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_Purifier])
    
  Else
    Window = OpenWindow(#PB_Any, PurifierWindowX, PurifierWindowY, 100, 100, Language("Debugger","PurifierTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_Invisible)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_Purifier] = Window
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Frame] = FrameGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","PurifierIntervall")) ; DO NOT FIX TYPO: PurifierIntervall
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextGlobal] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","GlobalIntervall"))   ; DO NOT FIX TYPO: GlobalIntervall
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextLocal] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","LocalIntervall"))     ; DO NOT FIX TYPO: LocalIntervall
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextString] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","StringIntervall"))   ; DO NOT FIX TYPO: StringIntervall
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextDynamic] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","DynamicIntervall")) ; DO NOT FIX TYPO: DynamicIntervall
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal] = TrackBarGadget(#PB_Any, 0, 0, 0, 0, 0, #MAX_PurifierState, #PB_TrackBar_Ticks)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal] = TrackBarGadget(#PB_Any, 0, 0, 0, 0, 0, #MAX_PurifierState, #PB_TrackBar_Ticks)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString] = TrackBarGadget(#PB_Any, 0, 0, 0, 0, 0, #MAX_PurifierState, #PB_TrackBar_Ticks)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic] = TrackBarGadget(#PB_Any, 0, 0, 0, 0, 0, #MAX_PurifierState, #PB_TrackBar_Ticks)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesGlobal] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger", "CheckLines")) ; long text for measurement
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesLocal] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger", "CheckLines"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesString] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger", "CheckLines"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_LinesDynamic] = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger", "CheckLines"))
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Misc","Ok"), #PB_Button_Default)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Cancel] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Misc","Cancel"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Preferences","Apply"))
      
      CompilerIf #CompileWindows
        ; For realtime updates while the slider moves
        SetWindowLongPtr_(WindowID(Window), #GWL_USERDATA, *Debugger)
        SetWindowCallback(@PurifierWindowCallback(), Window)
      CompilerEndIf
      
      CompilerIf #DEFAULT_CanWindowStayOnTop
        SetWindowStayOnTop(Window, DebuggerOnTop)
      CompilerEndIf
      
      ResizePurifierWindow(*Debugger)
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal], StateFromGranularity(*Debugger\PurifierGlobal))
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal], StateFromGranularity(*Debugger\PurifierLocal))
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString], StateFromGranularity(*Debugger\PurifierString))
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic], StateFromGranularity(*Debugger\PurifierDynamic))
      UpdatePurifierLines(*Debugger)
      
      AddKeyboardShortcut(Window, #PB_Shortcut_Return, #DEBUGGER_MENU_Return)
      AddKeyboardShortcut(Window, #PB_Shortcut_Escape, #DEBUGGER_MENU_Escape)
      
      Debugger_AddShortcuts(Window)
      EnsureWindowOnDesktop(Window)
      
      HideWindow(Window, 0)
      UpdatePurifierWindowState(*Debugger)
      
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
    EndIf
  EndIf
  
EndProcedure


Procedure UpdatePurifierWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Purifier], Language("Debugger","PurifierTitle") + " - " + DebuggerTitle(*Debugger\FileName$))
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Frame], Language("Debugger","PurifierIntervall"))      ; DO NOT FIX TYPO: PurifierIntervall
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextGlobal], Language("Debugger","GlobalIntervall"))   ; DO NOT FIX TYPO: GlobalIntervall
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextLocal], Language("Debugger","LocalIntervall"))     ; DO NOT FIX TYPO: LocalIntervall
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextString], Language("Debugger","StringIntervall"))   ; DO NOT FIX TYPO: StringIntervall
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TextDynamic], Language("Debugger","DynamicIntervall")) ; DO NOT FIX TYPO: DynamicIntervall
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Ok], Language("Misc","Ok"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Cancel], Language("Misc","Cancel"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_Apply], Language("Preferences","Apply"))
  
  UpdatePurifierLines(*Debugger)
  ResizePurifierWindow(*Debugger)
  
EndProcedure

; ---------------------------------------------------------

Procedure Purifier_DebuggerEvent(*Debugger.DebuggerData)
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_ControlPurifier
      If *Debugger\Command\Value1 = 1 And *Debugger\CommandData And *Debugger\Command\Datasize >= 4*SizeOf(Long)
        
        ; sanitize the input through the state function
        *Debugger\PurifierGlobal  = GranularityFromState(StateFromGranularity(PeekL(*Debugger\CommandData)))
        *Debugger\PurifierLocal   = GranularityFromState(StateFromGranularity(PeekL(*Debugger\CommandData + SizeOf(Long))))
        *Debugger\PurifierString  = GranularityFromState(StateFromGranularity(PeekL(*Debugger\CommandData + SizeOf(Long)*2)))
        *Debugger\PurifierDynamic = GranularityFromState(StateFromGranularity(PeekL(*Debugger\CommandData + SizeOf(Long)*3)))
        
        If *Debugger\Windows[#DEBUGGER_WINDOW_Purifier]
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarGlobal],  StateFromGranularity(*Debugger\PurifierGlobal))
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarLocal],   StateFromGranularity(*Debugger\PurifierLocal))
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarString],  StateFromGranularity(*Debugger\PurifierString))
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Purifier_TrackbarDynamic], StateFromGranularity(*Debugger\PurifierDynamic))
          UpdatePurifierLines(*Debugger)
        EndIf
        
        ; Since communication is asynchronous, we could have just sent a #COMMAND_SetPurifier
        ; before receiving this (in which case the purifier state does not fit the gui anymor)
        ; so re-sent it in any case with the current values
        ;
        Protected Dim State.l(3)
        State(0) = *Debugger\PurifierGlobal
        State(1) = *Debugger\PurifierLocal
        State(2) = *Debugger\PurifierString
        State(3) = *Debugger\PurifierDynamic
        
        Command.CommandInfo\Command = #COMMAND_SetPurifier
        Command\DataSize = 4 * SizeOf(LONG)
        SendDebuggerCommandWithData(*Debugger, @Command, @State(0))
      EndIf
      
  EndSelect
  
EndProcedure

