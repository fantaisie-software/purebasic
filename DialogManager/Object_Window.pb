; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


XIncludeFile "Object_BinBase.pb"

;
; window
;
; Accepted keys in the XML:
;
;   All accepted by DlgBinBase
;
;  forcesize = yes/no (default)
;              If the window is resizable, do not allow resizing below the
;              requested minimum size
;
;  closebutton = yes (default)/no
;                The default is to have the #PB_Window_SystemMenu flag on all dialogs
;                use this to remove it


Global NewList DialogWindowList.DialogWindow()

Structure DlgWindow Extends DlgBinBase
  Window.i
EndStructure

CompilerIf #CompileLinuxGtk
  ProcedureC GtkFontUpdate(*object, *paramspect, user_data)
    
    ForEach DialogWindowList()
      DialogWindowList()\GuiUpdate()
    Next DialogWindowList()
    
  EndProcedure
CompilerEndIf

Procedure DlgWindow_New(*StaticData.DialogObjectData, ParentID)
  *THIS.DlgWindow = AllocateMemory(SizeOf(DlgWindow))
  
  CompilerIf #CompileLinuxGtk
    Static FontCallbackSet
    
    If FontCallbackSet = 0
      *GtkDefaults = gtk_settings_get_default_()
      If *GtkDefaults
        g_signal_connect_data_(*GtkDefaults, "notify::gtk-font-name", @GtkFontUpdate(), 0, 0, 0)
        FontCallbackSet = 1
      EndIf
    EndIf
    
  CompilerEndIf
  
  If *THIS
    *THIS\VTable     = ?DlgWindow_VTable
    *THIS\StaticData = *StaticData
    
    If UCase(DialogObjectKey(*THIS\StaticData, "CLOSEBUTTON")) = "NO"
      Flags = #PB_Window_Invisible | *StaticData\Flags
    Else
      ; default
      Flags = #PB_Window_SystemMenu | #PB_Window_Invisible | *StaticData\Flags
    EndIf
    
    *THIS\Window = OpenWindow(*StaticData\Gadget, 0, 0, 0, 0, DialogObjectText(*StaticData), Flags, ParentID)
    
    CompilerIf #CompileMac
      If OSVersion() >= #PB_OS_MacOSX_10_14
        ; Fix Toolbar style from titlebar to expanded (Top Left)
        #NSWindowToolbarStyleExpanded = 1
        If *StaticData\Gadget = #PB_Any
          CocoaMessage(0, WindowID(*THIS\Window), "setToolbarStyle:", #NSWindowToolbarStyleExpanded)
        Else
          CocoaMessage(0, WindowID(*StaticData\Gadget), "setToolbarStyle:", #NSWindowToolbarStyleExpanded)
        EndIf  
      EndIf
    CompilerEndIf
    
    If *StaticData\Gadget <> -1
      *THIS\Window = *StaticData\Gadget
    EndIf
    
    DlgBinBase_GetOptions(*THIS) ; read all the margin etc options
    
    AddElement(DialogWindowList()) ; add the window to the global list for gui updates
    DialogWindowList() = *THIS
  EndIf
  
  ProcedureReturn *THIS
EndProcedure



Procedure DlgWindow_SizeRequest(*THIS.DlgWindow, *Width.LONG, *Height.LONG)
  *THIS\RequestedWidth  = 0
  *THIS\RequestedHeight = 0
  
  If *THIS\Child
    *THIS\Child\SizeRequest(@*THIS\RequestedWidth, @*THIS\RequestedHeight)
  EndIf
  
  *Width\l  = Max(*THIS\RequestedWidth +*THIS\lMargin+*THIS\lMargin, *THIS\StaticData\MinWidth)
  *Height\l = Max(*THIS\RequestedHeight+*THIS\tMargin+*THIS\bMargin, *THIS\StaticData\MinHeight)
  
  
  If UCase(DialogObjectKey(*THIS\StaticData, "FORCESIZE")) = "YES"
    WindowBounds(*THIS\Window, *Width\l, *Height\l, #PB_Ignore, #PB_Ignore)
  EndIf
EndProcedure



Procedure DlgWindow_SizeApply(*THIS.DlgWindow, x, y, Width, Height)
  ; No resizing of the main window is done here, it must be done explicitly,
  ; this is better, as often we just want to resize all gadgets after a resize event
  ; the public functions below do the resizewindow when needed
  
  If *THIS\Child
    x = 0
    y = 0
    DlgBinBase_CalculateChildSize(*THIS, @x, @y, @Width, @Height)
    
    *THIS\Child\SizeApply(x, y, Width, Height)
  EndIf
  
EndProcedure



; -----------------------------------------------------------------------------
; Publicly usable functions in the extended DialogWindow interface
; -----------------------------------------------------------------------------



Procedure DialogWindow_Window(*THIS.DlgWindow)
  ProcedureReturn *THIS\Window
EndProcedure


Procedure DialogWindow_Gadget(*THIS.DlgWindow, Name$)
  Protected THIS.DialogWindow = *THIS
  Protected *Result.DlgBase   = THIS\Find(UCase(Name$)) ; the find methods expect a uppercase name
  
  ; The private "Find" now returns the object pointer, not gadget ID!
  If *Result
    ProcedureReturn *Result\Gadget
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure DialogWindow_Fold(*THIS.DlgWindow, Name$, State)
  Protected THIS.DialogWindow   = *THIS
  Protected *Result.DlgBase     = THIS\Find(UCase(Name$)) ; the find methods expect a uppercase name
  Protected RESULT.DialogObject = *Result
  
  If *Result
    ; Note: the "Folded" flag is only set on the topmost object, so unfold
    ; is done correctly, but all children are hidden by FoldApply()
    ;
    *Result\Folded = State
    
    If State
      RESULT\FoldApply(State)
      
    Else
      ; To unfold (show) the children, we must first ensure that
      ; none of the parents is still folded
      ;
      unfold = 1
      While *Result
        If *Result\Folded
          unfold = 0
          Break
        EndIf
        *Result = *Result\Parent
      Wend
      
      If unfold
        RESULT\FoldApply(State)
      EndIf
    EndIf
    
    ; we need a recalc here!
    THIS\GuiUpdate()
  EndIf
EndProcedure


Procedure DialogWindow_LanguageUpdate(*THIS.DlgWindow)
  Protected THIS.DialogWindow = *THIS
  SetWindowTitle(*THIS\Window, DialogObjectText(*THIS\StaticData))
  THIS\Update()
  ; do not automatically trigger a gui update in case the user wants to change language stuff himself first
EndProcedure


Procedure DialogWindow_GuiUpdate(*THIS.DlgWindow)
  Protected THIS.DialogWindow = *THIS
  
  THIS\SizeRequest(@Width, @Height) ; re-calculate required sizes
  
  If GetWindowState(*THIS\Window) & #PB_Window_Maximize Or *THIS\StaticData\Flags & #PB_Window_SizeGadget
    ; window is maximized or user-sizable, so do not resize the window, except to enforce a minimum size
    If UCase(DialogObjectKey(*THIS\StaticData, "FORCESIZE")) = "YES"
      Width  = Max(Width, WindowWidth(*THIS\Window))
      Height = Max(Height, WindowHeight(*THIS\Window))
      ResizeWindow(*THIS\Window, #PB_Ignore, #PB_Ignore, Width, Height)
    Else
      Width  = WindowWidth(*THIS\Window)
      Height = WindowHeight(*THIS\Window)
    EndIf
  Else
    ; fixed size, nonmaximized dialog.. change the size to the new requested value
    ResizeWindow(*THIS\Window, #PB_Ignore, #PB_Ignore, Width, Height)
  EndIf
  
  THIS\SizeApply(0, 0, Width, Height) ; resize children
EndProcedure


Procedure DialogWindow_SizeUpdate(*THIS.DlgWindow)
  Protected THIS.DialogWindow = *THIS
  ; the required size data should still be ok, so just apply the new size to all gadgets
  THIS\SizeApply(0, 0, WindowWidth(*THIS\Window), WindowHeight(*THIS\Window))
EndProcedure


Procedure DialogWindow_Close(*THIS.DlgWindow, *Sizing.DialogPosition)
  Protected THIS.DialogWindow = *THIS
  
  ; remove window from the global list
  ;
  ForEach DialogWindowList()
    If DialogWindowList() = *THIS
      DeleteElement(DialogWindowList())
      Break
    EndIf
  Next DialogWindowList()
  
  If *Sizing
    If GetWindowState(*THIS\Window) & #PB_Window_Minimize = 0
      *Sizing\IsMaximized = GetWindowState(*THIS\Window) & #PB_Window_Maximize
      If *Sizing\IsMaximized = 0
        *Sizing\x      = WindowX(*THIS\Window)
        *Sizing\y      = WindowY(*THIS\Window)
        *Sizing\Width  = WindowWidth(*THIS\Window)
        *Sizing\Height = WindowHeight(*THIS\Window)
      EndIf
    EndIf
  EndIf
  
  CloseWindow(*THIS\Window)
  THIS\Destroy() ; will release all memory
EndProcedure



DataSection
  
  DlgWindow_VTable:
  Data.i @DlgBase_SizeRequestWrapper()
  Data.i @DlgWindow_SizeRequest()
  Data.i @DlgWindow_SizeApply()
  Data.i @DlgBinBase_AddChild()
  Data.i @DlgBinBase_FoldApply()
  Data.i @DlgBinBase_Find()
  Data.i @DlgBase_Finish()
  Data.i @DlgBinBase_Update()
  Data.i @DlgBinBase_Destroy()
  
  ; extended functions in DialogWindow
  Data.i @DialogWindow_Window()
  Data.i @DialogWindow_Gadget()
  Data.i @DialogWindow_Fold()
  Data.i @DialogWindow_LanguageUpdate()
  Data.i @DialogWindow_GuiUpdate()
  Data.i @DialogWindow_SizeUpdate()
  Data.i @DialogWindow_Close()
  
  
EndDataSection

