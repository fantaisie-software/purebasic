; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



Global Image_Minimize, Image_Maximize

Procedure Standalone_AddLog(Message$, TimeStamp)
  If LogTimeStamp
    Message$ = FormatDate("[%hh:%ii:%ss] ", TimeStamp) + Message$
  EndIf
  AddGadgetItem(#GADGET_Log, -1, Message$)
  SetGadgetState(#GADGET_Log, CountGadgetItems(#GADGET_Log)-1)
EndProcedure



Procedure Standalone_ResizeGUI()
  Width = WindowWidth(#WINDOW_Main)
  Height = WindowHeight(#WINDOW_Main) - StatusbarHeight
  
  CompilerIf #CompilePPC
    NbGadgets = 8
  CompilerElse
    NbGadgets = 9
  CompilerEndIf
  
  Dim ButtonWidth.l(NbGadgets) ; also needed for mini mode
  
  If IsMiniDebugger
    
    GetRequiredSize(#GADGET_Run, @ButtonWidth(1), @ButtonHeight)
    ButtonWidth(2) = GetRequiredWidth(#GADGET_Stop)
    ButtonWidth(3) = GetRequiredWidth(#GADGET_Step)
    ButtonWidth(4) = GetRequiredWidth(#GADGET_StepOver)
    ButtonWidth(5) = GetRequiredWidth(#GADGET_StepOut)
    ButtonWidth(6) = 70
    ButtonWidth(7) = GetRequiredWidth(#GADGET_Quit)
    
    Total = 80
    For i = 1 To 7
      Total + ButtonWidth(i)
    Next i
    Extra = (Width-Total) / NbGadgets
    
    Top = 10
    Left = 10
    ResizeGadget(#GADGET_Run,      Left, Top, ButtonWidth(1)+Extra, ButtonHeight): Left + ButtonWidth(1)+Extra + 10
    ResizeGadget(#GADGET_Stop,      Left, Top, ButtonWidth(2)+Extra, ButtonHeight): Left + ButtonWidth(2)+Extra + 10
    ResizeGadget(#GADGET_Step,      Left, Top, ButtonWidth(3)+Extra, ButtonHeight): Left + ButtonWidth(3)+Extra + 10
    ResizeGadget(#GADGET_StepOver,  Left, Top, ButtonWidth(4)+Extra, ButtonHeight): Left + ButtonWidth(4)+Extra + 10
    ResizeGadget(#GADGET_StepOut,   Left, Top, ButtonWidth(5)+Extra, ButtonHeight): Left + ButtonWidth(5)+Extra + 10
    ResizeGadget(#GADGET_StepCount, Left, Top, ((ButtonWidth(6)+Extra)*2)/3, ButtonHeight)
    ResizeGadget(#GADGET_Quit,      Width-10-ButtonWidth(7)-Extra, Top, ButtonWidth(7)+Extra, ButtonHeight)
    
    Top + ButtonHeight + 10
    SizeGadget = #GADGET_Maximize
  Else
    
    Top = 10
    GetRequiredSize(#GADGET_Run, @ColWidth1, @ButtonHeight)
    ColumnWidth1 = Max(ColumnWidth1, 70)
    ColumnWidth1 = Max(ColumnWidth1, GetRequiredWidth(#GADGET_Step))
    ColumnWidth1 = Max(ColumnWidth1, GetRequiredWidth(#GADGET_StepOver))
    ColumnWidth2 = Max(70, GetRequiredWidth(#GADGET_Stop))
    ColumnWidth2 = Max(ColumnWidth2, GetRequiredWidth(#GADGET_StepOut))
    
    ResizeGadget(#GADGET_Run,  10, Top, ColumnWidth1, ButtonHeight)
    ResizeGadget(#GADGET_Stop, 20+ColumnWidth1, Top, ColumnWidth2, ButtonHeight): Top + ButtonHeight + 10
    ResizeGadget(#GADGET_Step,  10, Top, ColumnWidth1, ButtonHeight)
    ResizeGadget(#GADGET_StepCount, 20+ColumnWidth1, Top, ColumnWidth2, ButtonHeight): Top + ButtonHeight + 10
    ResizeGadget(#GADGET_StepOver,  10, Top, ColumnWidth1, ButtonHeight)
    ResizeGadget(#GADGET_StepOut, 20+ColumnWidth1, Top, ColumnWidth2, ButtonHeight): Top + ButtonHeight + 10
    ResizeGadget(#GADGET_Quit, 10, Top, 10+ColumnWidth1+ColumnWidth2, ButtonHeight): Top + ButtonHeight
    ResizeGadget(#GADGET_Log, 30+ColumnWidth1+ColumnWidth2, 10, Width-40-ColumnWidth1-ColumnWidth2, Top-10)
    
    Top + 10
    SizeGadget = #GADGET_Minimize
  EndIf
  
  ButtonHeight2    = Max(ButtonHeight, GetRequiredHeight(#GADGET_SelectSource))
  BreakSetWidth    = Max(120, GetRequiredWidth(#GADGET_BreakSet))
  BreakRemoveWidth = Max(120, GetRequiredWidth(#GADGET_BreakClear))
  BreakClearWidth  = Max(120, GetRequiredWidth(#GADGET_DataBreak))
  
  ResizeGadget(#GADGET_SelectSource, 10, Top, Width-85-BreakClearWidth-BreakRemoveWidth-BreakSetWidth, ButtonHeight2)
  ResizeGadget(#GADGET_BreakSet    , Width-65-BreakClearWidth-BreakRemoveWidth-BreakSetWidth, Top, BreakSetWidth, ButtonHeight2)
  ResizeGadget(#GADGET_BreakClear , Width-55-BreakClearWidth-BreakRemoveWidth, Top, BreakRemoveWidth, ButtonHeight2)
  ResizeGadget(#GADGET_DataBreak  , Width-45-BreakClearWidth, Top, BreakClearWidth, ButtonHeight2)
  ResizeGadget(SizeGadget          , Width-35 , Top, 25, ButtonHeight2)
  Top + ButtonHeight2 + 10
  
  EditHeight = Height-Top-ButtonHeight-20
  If EditHeight < 0
    EditHeight = 0
    EditTop    = Height + 10 ; hide the gadget entirely when it is size=0 as on linux it remains visible which is ugly
  Else
    EditTop    = Top
  EndIf
  
  If SourceFiles(CurrentSource)\IsLoaded
    ResizeGadget(SourceFiles(CurrentSource)\Gadget, 10, EditTop, Width-20, EditHeight)
  Else
    ResizeGadget(#GADGET_Waiting, 10, EditTop, Width-20, EditHeight)
  EndIf
  
  Top = Height - 10 - ButtonHeight
  ButtonWidth(1) = GetRequiredWidth(#GADGET_Debug)
  ButtonWidth(2) = GetRequiredWidth(#GADGET_Variables)
  ButtonWidth(3) = GetRequiredWidth(#GADGET_Watchlist)
  ButtonWidth(4) = GetRequiredWidth(#GADGET_Profiler)
  ButtonWidth(5) = GetRequiredWidth(#GADGET_History)
  ButtonWidth(6) = GetRequiredWidth(#GADGET_Memory)
  ButtonWidth(7) = GetRequiredWidth(#GADGET_Library)
  CompilerIf #CompilePPC = 0
    ButtonWidth(8) = GetRequiredWidth(#GADGET_Assembly)
    ButtonWidth(9) = GetRequiredWidth(#GADGET_Purifier)
  CompilerElse
    ButtonWidth(8) = GetRequiredWidth(#GADGET_Purifier)
  CompilerEndIf
  
  Total = 10+5*(NbGadgets-1)
  For i = 1 To NbGadgets
    Total + ButtonWidth(i)
  Next i
  Extra = (Width-Total) / NbGadgets
  
  Left = 10
  ResizeGadget(#GADGET_Debug,     Left, Top, ButtonWidth(1)+Extra, ButtonHeight): Left + ButtonWidth(1)+Extra + 5
  ResizeGadget(#GADGET_Variables, Left, Top, ButtonWidth(2)+Extra, ButtonHeight): Left + ButtonWidth(2)+Extra + 5
  ResizeGadget(#GADGET_Watchlist, Left, Top, ButtonWidth(3)+Extra, ButtonHeight): Left + ButtonWidth(3)+Extra + 5
  ResizeGadget(#GADGET_Profiler,  Left, Top, ButtonWidth(4)+Extra, ButtonHeight): Left + ButtonWidth(4)+Extra + 5
  ResizeGadget(#GADGET_History,   Left, Top, ButtonWidth(5)+Extra, ButtonHeight): Left + ButtonWidth(5)+Extra + 5
  ResizeGadget(#GADGET_Memory,    Left, Top, ButtonWidth(6)+Extra, ButtonHeight): Left + ButtonWidth(6)+Extra + 5
  ResizeGadget(#GADGET_Library,   Left, Top, ButtonWidth(7)+Extra, ButtonHeight): Left + ButtonWidth(7)+Extra + 5
  CompilerIf #CompilePPC = 0
    ResizeGadget(#GADGET_Assembly, Left, Top, ButtonWidth(8)+Extra, ButtonHeight): Left + ButtonWidth(8)+Extra + 5
    ResizeGadget(#GADGET_Purifier, Left, Top, ButtonWidth(9)+Extra, ButtonHeight)
  CompilerElse
    ResizeGadget(#GADGET_Purifier, Left, Top, ButtonWidth(8)+Extra, ButtonHeight)
  CompilerEndIf
  
EndProcedure


Procedure Standalone_CreateGUI()
  
  Image_Minimize = CatchImageDPI(#PB_Any, ?MinimizeImageData)
  Image_Maximize = CatchImageDPI(#PB_Any, ?MaximizeImageData)
  
  If OpenWindow(#WINDOW_Main, DebuggerMainWindowX, DebuggerMainWindowY, DebuggerMainWindowWidth, DebuggerMainWindowHeight, "PureBasic Debugger", #PB_Window_Invisible|#PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget)
    
    *Statusbar = CreateStatusBar(#STATUSBAR, WindowID(#WINDOW_Main))
    If *Statusbar
      AddStatusBarField(#PB_Ignore)
      StatusbarHeight = StatusBarHeight(#STATUSBAR)
    EndIf
    
    ButtonGadget(#GADGET_Run,  0, 0, 0, 0, Language("StandaloneDebugger","Run"))
    ButtonGadget(#GADGET_Stop, 0, 0, 0, 0, Language("StandaloneDebugger","Stop"))
    ButtonGadget(#GADGET_Step, 0, 0, 0, 0, Language("StandaloneDebugger","Step"))
    StringGadget(#GADGET_StepCount, 0, 0, 0, 0, "1", #PB_String_Numeric)
    ButtonGadget(#GADGET_StepOver, 0, 0, 0, 0, Language("StandaloneDebugger","StepOver"))
    ButtonGadget(#GADGET_StepOut, 0, 0, 0, 0, Language("StandaloneDebugger","StepOut"))
    ButtonGadget(#GADGET_Quit, 0, 0, 0, 0, Language("StandaloneDebugger","Quit"))
    
    ListViewGadget(#GADGET_Log, 0, 0, 0, 0)
    
    ComboBoxGadget(#GADGET_SelectSource, 0, 0, 0, 300)
    ButtonGadget(#GADGET_BreakSet, 0, 0, 0, 0, Language("StandaloneDebugger","BreakSetRemove"))
    ButtonGadget(#GADGET_BreakClear, 0, 0, 0, 0, Language("StandaloneDebugger","BreakClear"))
    ButtonGadget(#GADGET_DataBreak, 0, 0, 0, 0, Language("StandaloneDebugger","DataBreak"), #PB_Button_Toggle)
    
    ButtonGadget(#GADGET_Debug, 0, 0, 0, 0, Language("StandaloneDebugger", "DebugOutput"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Watchlist, 0, 0, 0, 0, RemoveString(Language("MenuItem", "WatchList"),"&"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Variables, 0, 0, 0, 0, Language("StandaloneDebugger", "VariableList"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Profiler, 0, 0, 0, 0, Language("StandaloneDebugger", "Profiler"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_History, 0, 0, 0, 0, RemoveString(Language("MenuItem", "History"),"&"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Memory, 0, 0, 0, 0, Language("StandaloneDebugger", "Memory"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Library, 0, 0, 0, 0, Language("StandaloneDebugger", "Library"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Assembly, 0, 0, 0, 0, RemoveString(Language("MenuItem", "DebugAsm"),"&"), #PB_Button_Toggle)
    ButtonGadget(#GADGET_Purifier, 0, 0, 0, 0, Language("StandaloneDebugger", "Purifier"), #PB_Button_Toggle)
    
    CompilerIf #CompilePPC
      HideGadget(#GADGET_Assembly, 1)
    CompilerEndIf
    
    ButtonImageGadget(#GADGET_Minimize, 0, 0, 0, 0, ImageID(Image_Minimize))
    ButtonImageGadget(#GADGET_Maximize, 0, 0, 0, 0, ImageID(Image_Maximize))
    If IsMiniDebugger
      HideGadget(#GADGET_Minimize, 1)
      HideGadget(#GADGET_Log, 1)
    Else
      HideGadget(#GADGET_Maximize, 1)
    EndIf
    
    TextGadget(#GADGET_Waiting, 0, 0, 0, 0, Language("Debugger","Waiting"), #PB_Text_Center|#PB_Text_Border)
    
    AddKeyboardShortcut(#WINDOW_Main, Shortcut_Run, #MENU_Run)
    AddKeyboardShortcut(#WINDOW_Main, Shortcut_Stop, #MENU_Stop)
    AddKeyboardShortcut(#WINDOW_Main, Shortcut_Step, #MENU_Step)
    AddKeyboardShortcut(#WINDOW_Main, Shortcut_StepOver, #MENU_StepOver)
    AddKeyboardShortcut(#WINDOW_Main, Shortcut_StepOut, #MENU_StepOut)
    
    Standalone_ResizeGUI()
    
    CompilerIf #DEFAULT_CanWindowStayOnTop
      SetWindowStayOnTop(#WINDOW_Main, DebuggerOnTop)
    CompilerEndIf
    
    success = 1
  EndIf
  
  DebuggerMainWindow = #WINDOW_Main ; this makes sure that the "bring to top" option works on this too
  
  ProcedureReturn success
EndProcedure

Procedure UpdateGadgetStates()
  
  If *DebuggerData\ProgramState = -1  ; stuff that works only while the exe is loaded
    DisableGadget(#GADGET_BreakSet, 1)
    DisableGadget(#GADGET_BreakClear, 1)
    DisableGadget(#GADGET_DataBreak, 1)
  Else
    DisableGadget(#GADGET_BreakSet, 0)
    DisableGadget(#GADGET_BreakClear, 0)
    DisableGadget(#GADGET_DataBreak, 0)
  EndIf
  
  If *DebuggerData\ProgramState = -1 ; not loaded
    DisableGadget(#GADGET_Run, 1)
    DisableGadget(#GADGET_Stop, 1)
    DisableGadget(#GADGET_Step, 1)
    DisableGadget(#GADGET_StepCount, 1)
    DisableGadget(#GADGET_StepOver, 1)
    DisableGadget(#GADGET_StepOut, 1)
    
  ElseIf *DebuggerData\ProgramState = 0 ; running
    DisableGadget(#GADGET_Run, 1)
    DisableGadget(#GADGET_Stop, 0)
    DisableGadget(#GADGET_Step, 1)
    DisableGadget(#GADGET_StepCount, 1)
    DisableGadget(#GADGET_StepOver, 1)
    DisableGadget(#GADGET_StepOut, 1)
    
  ElseIf *DebuggerData\ProgramState = 6 ; fatal error (no continuing possible)
    DisableGadget(#GADGET_Run, 1)
    DisableGadget(#GADGET_Stop, 1)
    DisableGadget(#GADGET_Step, 1)
    DisableGadget(#GADGET_StepCount, 1)
    DisableGadget(#GADGET_StepOver, 1)
    DisableGadget(#GADGET_StepOut, 1)
    
  Else ; not running for some other reason
    DisableGadget(#GADGET_Run, 0)
    DisableGadget(#GADGET_Stop, 1)
    DisableGadget(#GADGET_Step, 0)
    DisableGadget(#GADGET_StepCount, 0)
    DisableGadget(#GADGET_StepOver, 0)
    DisableGadget(#GADGET_StepOut, 0)
    
  EndIf
  
EndProcedure


DataSection
 
  MinimizeImageData:
    IncludeBinary "../PureBasicIDE/data/DefaultTheme/TemplateUp.png"
  MaximizeImageData:
    IncludeBinary "../PureBasicIDE/data/DefaultTheme/TemplateDown.png"

EndDataSection