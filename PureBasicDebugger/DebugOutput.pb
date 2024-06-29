; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure.s DebugOutput_Selection(*Debugger.DebuggerData)
  Gadget  = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List]
  Buffer$ = ""
  
  max     = CountGadgetItems(Gadget)-1
  State   = GetGadgetState(Gadget)
  multiselect = 0
  
  If State <> -1
    For i = State+1 To max
      If GetGadgetItemState(Gadget, i)
        multiselect = 1
        Break
      EndIf
    Next i
  EndIf
  
  If multiselect
    For i = State To max
      If GetGadgetItemState(Gadget, i)
        Buffer$ + GetGadgetItemText(Gadget, i) + #NewLine
      EndIf
    Next i
    
  Else
    For i = 0 To max
      Buffer$ + GetGadgetItemText(Gadget, i) + #NewLine
    Next i
    
  EndIf
  
  ProcedureReturn Buffer$
EndProcedure

Procedure DebugOutput_EvaluateExpression(*Debugger.DebuggerData)
  
  If *Debugger\ProgramState = -1
    
    StatusBarText(*Debugger\OutputStatusbar, 0, Language("Debugger", "ExeEnded"))
    
  Else
    
    StatusBarText(*Debugger\OutputStatusbar, 0, "...")
    
    Expr$ = Trim(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]))
    Test$ = UCase(Left(Expr$, 4))
    
    If (Test$ = "SET " Or Test$ = "SET" + Chr(9)) And FindString(Expr$, "=", 1) <> 0
      
      ; its the new "set" command
      ;
      Expr$  = Trim(Right(Expr$, Len(Expr$)-4))
      length = (Len(Expr$)+1) * SizeOf(Character)
      
      ; ugly hack to separate the two request strings, but works.
      PokeC(@Expr$ + (FindString(Expr$, "=", 1)-1) * SizeOf(Character), 0)
      
      Command.CommandInfo\Command = #COMMAND_SetVariable
      Command\Value1 = AsciiConst('D','E','B','G') ; to identify the sender
      Command\Value2 = 0                           ; reserved for now
      Command\DataSize = length
      SendDebuggerCommandWithData(*Debugger, @Command, @Expr$)
      
    Else
      
      ; normal expression evaluation
      ;
      Command.CommandInfo\Command = #COMMAND_EvaluateExpression
      Command\Value1 = AsciiConst('D','E','B','G') ; to identify the sender
      Command\Value2 = -1                          ; use current line as context
      Command\DataSize = (Len(Expr$)+1) * SizeOf(Character)
      SendDebuggerCommandWithData(*Debugger, @Command, @Expr$)
      
    EndIf
    
    ; the gadget content is changed when the response is received
    ; (to act different on errors)
    
  EndIf
  
EndProcedure

Procedure DebugWindowEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_ActivateWindow
    CompilerIf #CompileWindows
      ; to 'fix' a weird bug: https://www.purebasic.fr/english/viewtopic.php?f=4&t=66634
      ; NOTE: doesn't work as it breaks the IDE: https://www.purebasic.fr/english/viewtopic.php?f=4&t=69031
      ; SetActiveGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])
    CompilerEndIf
    
  ElseIf EventID = #PB_Event_Menu   ; for the Enter shortcut
    If EventMenu() = #DEBUGGER_MENU_Return
      If GetActiveGadget() = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]
        DebugOutput_EvaluateExpression(*Debugger)
      EndIf
    EndIf
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Display]
        DebugOutput_EvaluateExpression(*Debugger)
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List]
        If EventType() = #PB_EventType_DragStart
          DragText(DebugOutput_Selection(*Debugger), #PB_Drag_Copy)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy] ; Note: it's now a 'copy-all' button
        SetClipboardText(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])) ; Get the whole text at once
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear]
        ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save] ; we always save the whole list, not just the selection
        FileName$ = DebuggerOutputFile$
        Repeat
          FileName$ = SaveFileRequester(Language("Debugger","SaveFileTitle"), FileName$, Language("Debugger","SaveFilePattern"), 0)
          If FileName$ = ""
            Break
          EndIf
          
          ; auto-add extension
          If GetExtensionPart(FileName$) = "" And SelectedFilePattern() = 0
            FileName$ + ".txt"
          EndIf
          
          If FileSize(FileName$) <> -1
            result = MessageRequester("PureBasic Debugger",Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #FLAG_Warning|#PB_MessageRequester_YesNoCancel)
            If result = #PB_MessageRequester_Cancel
              Break ; abort
            ElseIf result = #PB_MessageRequester_No
              Continue ; ask again
            EndIf
          EndIf
          
          File = CreateFile(#PB_Any, FileName$)
          If File
            max = CountGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])-1
            For i = 0 To max
              WriteStringN(File, GetGadgetItemText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List], i, 0))
            Next i
            CloseFile(File)
            DebuggerOutputFile$ = FileName$ ; store for next time
          Else
            MessageRequester("PureBasic Debugger",ReplaceString(Language("Debugger","SaveError"), "%filename%", FileName$, 1), #FLAG_Error)
          EndIf
          
          Break ; if we got here, then do not try again
        ForEver
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width =  WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
    Height = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy], @CopyWidth, @ButtonHeight)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save], @SaveWidth, @ButtonHeight)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear], @ClearWidth, @ButtonHeight)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Display], @DisplayWidth, @ButtonHeight)
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_Gadget_Debug_Text], @TextWidth, @TextHeight)
    EntryHeight = GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry])
    StatusHeight = StatusBarHeight(*Debugger\OutputStatusbar)
    
    CopyWidth  = Max(120, CopyWidth)
    SaveWidth  = Max(120, SaveWidth)
    ClearWidth = Max(120, ClearWidth)
    DisplayWidth = Max(60, DisplayWidth)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List], 10, 20+ButtonHeight, Width-20, Height-35-ButtonHeight-EntryHeight-StatusHeight)
    
    Y = Height-10-EntryHeight-StatusHeight
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry], 15+TextWidth, Y, Width-DisplayWidth-TextWidth-30, EntryHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Display], Width-10-DisplayWidth, Y, DisplayWidth, EntryHeight)
    CompilerIf #CompileWindows
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Text], 10, Y+2, TextWidth, TextHeight)
    CompilerElse
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Text], 10, Y, TextWidth, TextHeight)
    CompilerEndIf
    
    Y = 10
    If Width < CopyWidth+SaveWidth+ClearWidth+40
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy], 10, Y, (Width-40)/3, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save], 20+(Width-40)/3, Y, (Width-40)/3, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear], 30+((Width-40)*2)/3, Y, (Width-40)/3, ButtonHeight)
    Else
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy], Width-30-ClearWidth-SaveWidth-CopyWidth, Y, CopyWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save], Width-20-ClearWidth-SaveWidth, Y, SaveWidth, ButtonHeight)
      ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear],Width-10-ClearWidth, Y, ClearWidth, ButtonHeight)
      ;       ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy], 10, Y, CopyWidth, ButtonHeight)
      ;       ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save], 20+CopyWidth, Y, SaveWidth, ButtonHeight)
      ;       ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear],30+CopyWidth+SaveWidth, Y, ClearWidth, ButtonHeight)
    EndIf
    
  ElseIf EventID = #PB_Event_CloseWindow
    
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_Debug]) = 0
      DebugWindowMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
      If DebugWindowMaximize = 0
        DebugWindowX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
        DebugWindowY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
        DebugWindowWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
        DebugWindowHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
      EndIf
    EndIf
    
    *Debugger\IsDebugOutputVisible = 0  ; special case: only hide the window so it can still receive debug data
    HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Debug], 1)
    Debugger_CheckDestroy(*Debugger) ; see if all debugger stuff is closed
  EndIf
  
EndProcedure

; this window is always open and only shown when needed
;
Procedure CreateDebugWindow(*Debugger.DebuggerData)
  
  Flags = #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_SizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget
  If DebugWindowMaximize
    Flags | #PB_Window_Maximize
  EndIf
  
  Window = OpenWindow(#PB_Any, DebugWindowX, DebugWindowY, DebugWindowWidth, DebugWindowHeight, Language("Debugger","DebugWindowTitle") + " - " + DebuggerTitle(*Debugger\FileName$), Flags)
  If Window
    *Debugger\Windows[#DEBUGGER_WINDOW_Debug] = Window
    
    *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List]    = EditorGadget(#PB_Any, 0, 0, 0, 0, #PB_Editor_ReadOnly)
    *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]   = ComboBoxGadget(#PB_Any, 0, 0, 0, 0, #PB_ComboBox_Editable)
    *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Display] = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Display"))
    *Debugger\Gadgets[#DEBUGGER_Gadget_Debug_Text]    = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Debug")+":")
    
    *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy]    = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Copy"))
    *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save]    = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Save"))
    *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear]   = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Clear"))
    
    *Debugger\OutputStatusbar = CreateStatusBar(#PB_Any, WindowID(Window))
    AddStatusBarField(#PB_Ignore)
    
    CompilerIf #SpiderBasic
      ; We don't support this yet
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry], #True)
      DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Display], #True)
    CompilerEndIf
    
    If DebugOutFontID <> #PB_Default
      SetGadgetFont(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List], DebugOutFontID)
    EndIf
    
    DebugWindowEvents(*Debugger, #PB_Event_SizeWindow)
    
    CompilerIf #DEFAULT_CanWindowStayOnTop
      SetWindowStayOnTop(Window, DebuggerOnTop)
    CompilerEndIf
    
    AddKeyboardShortcut(Window, #PB_Shortcut_Return, #DEBUGGER_MENU_Return)
    Debugger_AddShortcuts(Window)
    
    *Debugger\OutputFirstVisible   = 1; mark as not yet visible
    *Debugger\IsDebugOutputVisible = 0
  EndIf
  
  
EndProcedure

Procedure OpenDebugWindow(*Debugger.DebuggerData, ActivateWindow)
  
  HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Debug], 0, #PB_Window_NoActivate)  ; Don't steal the focus from the main app
  EnsureWindowOnDesktop(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
  
  ; Do not activate the Window when opened automatically, to not steal the focus
  ; away from the debugged program (will cause a DX screen to minimize for example!
  If ActivateWindow
    SetWindowforeGround(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
  Else
    SetWindowforeGround_NoActivate(*Debugger\Windows[#DEBUGGER_WINDOW_Debug])
  EndIf
  
  StatusBarText(*Debugger\OutputStatusbar, 0, "")
  *Debugger\IsDebugOutputVisible = 1
  *Debugger\OutputFirstVisible   = 0 ; the window was once visible
  
  Debugger_ProcessEvents(*Debugger\Windows[#DEBUGGER_WINDOW_Debug], #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
  
EndProcedure


Procedure CloseDebugWindow(*Debugger.DebuggerData)
  
  ; We don't really close it, so we can re-open it later
  HideWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Debug], #True)
EndProcedure


Procedure UpdateDebugWindow(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Debug], Language("Debugger","DebugWindowTitle") + " - " + DebuggerTitle(*Debugger\FileName$))
  
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Copy], Language("Debugger","Copy"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Save], Language("Debugger","Save"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Clear], Language("Debugger","Clear"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Display], Language("Debugger","Display"))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_Gadget_Debug_Text], Language("Debugger","Debug")+":")
  
  
  ; update the font setting
  SetGadgetFont(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List], DebugOutFontID)
  
  DebugWindowEvents(*Debugger, #PB_Event_SizeWindow) ; to update any gadget size requirements
EndProcedure


Procedure UpdateDebugOutputWindow(*Debugger.DebuggerData)
  
  If *Debugger\IsDebugMessage ; We can use DebugMessage$ as we could want to have Debug ""
    
    Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List]
    
    AddGadgetItem(Gadget, -1, *Debugger\DebugMessage$)

    ScrollEditorGadgetToEnd(Gadget)
    
    *Debugger\DebugMessage$ = ""
    *Debugger\IsDebugMessage = #False
  EndIf
  
EndProcedure


; this is called whenever debug output is received
; it will handle opening a window and adding the text
; the command field contains the needed data
;
Procedure DebugOutput_DebuggerEvent(*Debugger.DebuggerData)
  
  ; This command does not mean that the Window should be shown
  ; automatically, so handle it first
  ;
  If *Debugger\Command\Command = #COMMAND_ControlDebugOutput
    Select *Debugger\Command\Value1
        
      Case 1 ; show
        OpenDebugWindow(*Debugger, #True)
        
      Case 2 ; clear
        UpdateDebugOutputWindow(*Debugger) ; Ensure we are flushing the remaining cached text
        ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])
        
      Case 3 ; save
        If *Debugger\CommandData And *Debugger\Command\DataSize > 0
          FileName$ = PeekS(*Debugger\CommandData, *Debugger\Command\DataSize)
          
          UpdateDebugOutputWindow(*Debugger) ; Ensure we are flushing the remaining cached text
          File = CreateFile(#PB_Any, FileName$)
          If File
            WriteString(File, GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])) ; We now use an EditorGadget() so we can get the text in one call
            CloseFile(File)
          Else
            MessageRequester("PureBasic Debugger",ReplaceString(Language("Debugger","SaveError"), "%filename%", FileName$, 1), #FLAG_Error)
          EndIf
        EndIf
        
      Case 4 ; copy to clipboard
        UpdateDebugOutputWindow(*Debugger) ; Ensure we are flushing the remaining cached text
        SetClipboardText(GetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List])) ; We now use an EditorGadget() so we can get the text in one call
        
      Case 5 ; close
        CloseDebugWindow(*Debugger)
        
    EndSelect
    
    ; Do not execute the code below
    ProcedureReturn
  EndIf
  
  ; filter expression messages that are not for this window
  ;
  If (*Debugger\Command\Command = #COMMAND_Expression Or *Debugger\Command\Command = #COMMAND_SetVariableResult) And *Debugger\Command\Value1 <> AsciiConst('D','E','B','G')
    ProcedureReturn
  EndIf
  
  If DebugOutputToErrorLog = 0 Or *Debugger\Command\Command = #COMMAND_Expression Or *Debugger\Command\Command = #COMMAND_SetVariableResult
    
    ; automatically show the window if it was never visible
    ; do not activate though, to not steal the focus
    ;
    If *Debugger\OutputFirstVisible
      OpenDebugWindow(*Debugger, #False)
    EndIf
    
    If DebugTimeStamp
      Message$ = "[" + FormatDate(Language("Debugger","TimeStamp"), *Debugger\Command\TimeStamp) + "] "
    Else
      Message$ = ""
    EndIf
    
    Gadget = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_List]
    
    StatusBarText(*Debugger\OutputStatusbar, 0, "")
    
    If *Debugger\Command\Command = #COMMAND_Debug
      If *Debugger\Command\Value1 = 5 ; long
        If DebugIsHex
          Message$ + Hex(*Debugger\Command\Value2, #PB_Long)
        Else
          Message$ + Str(*Debugger\Command\Value2)
        EndIf
        
      ElseIf *Debugger\Command\Value1 = 8 ; string
        Message$ + PeekS(*Debugger\CommandData, *Debugger\Command\DataSize)
        
      ElseIf *Debugger\Command\Value1 = 9 ; float
        Message$ + StrF_Debug(PeekF(@*Debugger\Command\Value2))
      EndIf
      
    ElseIf *Debugger\Command\Command = #COMMAND_DebugDouble ; double
      Message$ + StrD_Debug(PeekD(@*Debugger\Command\Value1))
      
    ElseIf *Debugger\Command\Command = #COMMAND_DebugQuad ; quad
      If DebugIsHex
        Message$ + Hex(PeekQ(@*Debugger\Command\Value1), #PB_Quad)
      Else
        Message$ + Str(PeekQ(@*Debugger\Command\Value1))
      EndIf
      
      
    ElseIf (*Debugger\Command\Command = #COMMAND_Expression Or *Debugger\Command\Command = #COMMAND_SetVariableResult) And *Debugger\Command\Value1 = AsciiConst('D','E','B','G')
      If *Debugger\CommandData = 0
        ProcedureReturn
      EndIf
      
      Select *Debugger\Command\Value2 ; result code
          
        Case 0 ; error
          StatusBarText(*Debugger\OutputStatusbar, 0, "Error: "+PeekAscii(*Debugger\CommandData))
          
          ; it will select the whole text, so only do it if the focus was lost
          ; (for example when the "display" button was pressed with the mouse.)
          If GetActiveGadget() <> *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]
            SetActiveGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry])
          EndIf
          ProcedureReturn ; add no output here
          
        Case 1 ; empty, we add an empty line still
          Expr$ = PeekS(*Debugger\CommandData)
          
        Case 2 ; quad
          If DebugIsHex
            Message$ + Hex(PeekQ(*Debugger\CommandData), #PB_Quad)
          Else
            Message$ + Str(PeekQ(*Debugger\CommandData))
          EndIf
          Expr$ = PeekS(*Debugger\CommandData + 8)
          
        Case 3 ; double
          Message$ + StrD_Debug(PeekD(*Debugger\CommandData))
          Expr$ = PeekS(*Debugger\CommandData + 8)
          
        Case 4 ; string
          Message$ + PeekS(*Debugger\CommandData)
          Expr$ = PeekS(*Debugger\CommandData + (Len(Message$) + 1)*#CharSize)
          
          If *Debugger\Command\Command = #COMMAND_SetVariableResult
            Message$ = Chr(34)+Message$+Chr(34)
          EndIf
          
        Case 5 ; structure
               ; Not implemented for the moment. Dunno if it is needed.
               ; (We request no structuremap for now, so structures are returned
               ;  as their pointers)
          
        Case 6  ; long (osx only, enable for crossplatform debugging)
          If DebugIsHex
            Message$ + Hex(PeekL(*Debugger\CommandData), #PB_Long)
          Else
            Message$ + Str(PeekL(*Debugger\CommandData))
          EndIf
          Expr$ = PeekS(*Debugger\CommandData + 4)
          
        Case 7 ; float (osx only)
          Message$ + StrF_Debug(PeekF(*Debugger\CommandData))
          Expr$ = PeekS(*Debugger\CommandData + 4)
          
          
      EndSelect
      
      ; only clear gadget on success, so we can still see
      ; the faulty input if there is an error.
      ;
      Entry = *Debugger\Gadgets[#DEBUGGER_GADGET_Debug_Entry]
      Count = CountGadgetItems(Entry)
      
      ; remove double items
      ; backwards to not alter the index by deleting
      For i = Count-1 To 0 Step -1
        If GetGadgetItemText(Entry, i) = Expr$
          RemoveGadgetItem(Entry, i)
          Count - 1
        EndIf
      Next i
      
      ; make sure we are below the max count
      While Count >= #MAX_EpressionHistory
        RemoveGadgetItem(Entry, Count-1)
        Count - 1
      Wend
      
      ; add this expr to the history
      AddGadgetItem(Entry, 0, Expr$)
      SetGadgetText(Entry, "")
      SetActiveGadget(Entry)
      
      ; if it is an expression result, we only set it in the
      ; status bar, not in the gadget
      ;
      If *Debugger\Command\Command = #COMMAND_SetVariableResult
        StatusBarText(*Debugger\OutputStatusbar, 0, "Variable set to: "+Message$)
        ProcedureReturn ; no output in gadget here!
      EndIf
      
    EndIf
    
    ; Truncate the Message to avoid display problems on Windows, and because debugging
    ; such large things is no longer reasonably viewable anyway
    ;
    ; As we use an editor based gadget now, it can be displayed without issue
    ;
    ;If Len(Message$) > 4096
    ;  Message$ = Left(Message$, 4096) + " [...]"
    ;EndIf
    
    If *Debugger\IsDebugMessage
      Message$ = #LF$ + Message$
    EndIf
    
    *Debugger\DebugMessage$ + Message$ ; Will be updated once the whole batch has been processed in  , so we can have batch debug coming and it won't be too slow
    *Debugger\IsDebugMessage = #True
  EndIf
  
EndProcedure
