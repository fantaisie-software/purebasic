; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

XIncludeFile "Common.pb"
XIncludeFile "Object_Window.pb"
XIncludeFile "Object_Gadget.pb"
XIncludeFile "Object_Box.pb"
XIncludeFile "Object_Multibox.pb"
XIncludeFile "Object_Singlebox.pb"
XIncludeFile "Object_Gridbox.pb"
XIncludeFile "Object_Container.pb"
XIncludeFile "Object_Panel.pb"
XIncludeFile "Object_ScrollArea.pb"
XIncludeFile "Object_Frame.pb"
XIncludeFile "Object_Splitter.pb"

CompilerIf #CompileMacCocoa
  ImportC ""
    PB_Gadget_CenterWindow(WindowID.i)
  EndImport
CompilerEndIf


Procedure CreateNextDialogObject()
  Shared *CreateDialogData.DialogObjectData, DialogParentWindowID
  
  ; create the current object
  ;
  Define Object.DialogObject
  
  Select *CreateDialogData\Type
    Case #DIALOG_Window
      Object = DlgWindow_New(*CreateDialogData, DialogParentWindowID)
      *Window.DlgWindow   = Object
      
      ; these are all similar, so they share the object functions
    Case #DIALOG_Button:   Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_Checkbox: Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_Option:   Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_Image:    Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ListView: Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ListIcon: Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_Tree:     Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ComboBox: Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_Text:     Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_String:   Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_Editor:   Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ScrollBar:Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ProgressBar:Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ShortcutGadget:Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_ButtonImage:Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_TrackBar: Object = DlgGadget_New(*CreateDialogData)
    Case #DIALOG_HyperLink: Object = DlgGadget_New(*CreateDialogData)
      
      CompilerIf Defined(DIALOG_USE_EXPLORER, #PB_Constant)
      Case #DIALOG_ExplorerList:Object = DlgGadget_New(*CreateDialogData)
      Case #DIALOG_ExplorerTree:Object = DlgGadget_New(*CreateDialogData)
      Case #DIALOG_ExplorerCombo:Object = DlgGadget_New(*CreateDialogData)
      CompilerEndIf
      
      CompilerIf Defined(DIALOG_USE_SCINTILLA, #PB_Constant)
      Case #DIALOG_Scintilla:Object = DlgGadget_New(*CreateDialogData)
      CompilerEndIf
      
    Case #DIALOG_Container:Object = DlgContainer_New(*CreateDialogData)
    Case #DIALOG_Panel:    Object = DlgPanel_New(*CreateDialogData)
    Case #DIALOG_Tab:      Object = DlgTab_New(*CreateDialogData)
    Case #DIALOG_Scroll:   Object = DlgScroll_New(*CreateDialogData)
    Case #DIALOG_Frame:    Object = DlgFrame_New(*CreateDialogData)
    Case #DIALOG_Splitter: Object = DlgSplitter_New(*CreateDialogData)
      
    Case #DIALOG_VBox:     Object = DlgBox_New(*CreateDialogData)
    Case #DIALOG_HBox:     Object = DlgBox_New(*CreateDialogData)
    Case #DIALOG_Multibox: Object = DlgMultibox_New(*CreateDialogData)
    Case #DIALOG_Singlebox:Object = DlgSinglebox_New(*CreateDialogData)
    Case #DIALOG_Gridbox:  Object = DlgGridbox_New(*CreateDialogData)
    Case #DIALOG_Empty:    Object = DlgEmpty_New(*CreateDialogData)
      
    Default
      CompilerIf #PB_Compiler_Debugger
        MessageRequester("Dialog Manager", "Unknown Object Type!")
      CompilerEndIf
      
      ProcedureReturn 0
  EndSelect
  
  ; Skip the data of this object
  ;
  StringCount = 4 + *CreateDialogData\KeyCount * 2
  *CreateDialogData + SizeOf(DialogObjectData)
  For i = 1 To StringCount
    *CreateDialogData + (MemoryStringLength(*CreateDialogData) + 1) * SizeOf(Character)
  Next i
  
  ; create any child objects
  ;
  While *CreateDialogData\Type <> -1 ; this is -1 to finish the object
    If *CreateDialogData\Type = #DIALOG_Item Or *CreateDialogData\Type = #DIALOG_Column ; special case for gadget items
      DlgGadget_AddItem(Object, *CreateDialogData)
      
      ; Skip the data of this object
      StringCount = 4 + *CreateDialogData\KeyCount * 2
      *CreateDialogData + SizeOf(DialogObjectData)
      For i = 1 To StringCount
        *CreateDialogData + (MemoryStringLength(*CreateDialogData) + 1) * SizeOf(Character)
      Next i
      *CreateDialogData + SizeOf(LONG) ; skip -1 to finish item object
    Else
      Object\AddChild(CreateNextDialogObject())
    EndIf
  Wend
  
  ; finish creation
  ;
  *CreateDialogData + 4 ; skip the -1 data
  Object\Finish()
  
  
  ; apply the invisible/disabled states if set
  ;
  *Object.DlgBase = Object
  
  If *Object\Gadget ; only for real gadgets
    If UCase(DialogObjectKey(*Object\StaticData, "DISABLED")) = "YES"
      DisableGadget(*Object\Gadget, 1)
    EndIf
    
    If UCase(DialogObjectKey(*Object\StaticData, "INVISIBLE")) = "YES"
      HideGadget(*Object\Gadget, 1)
    EndIf
  EndIf
  
  ; apply the "folded" state, which works on all objects
  ;
  If UCase(DialogObjectKey(*Object\StaticData, "FOLDED")) = "YES"
    *Object\Folded = 1
    Object\FoldApply(1)
  EndIf
  
  ProcedureReturn Object
EndProcedure


Procedure OpenDialog(*DataOffset.DialogObjectData, ParentID = 0, *Sizing.DialogPosition = 0)
  Shared *CreateDialogData.DialogObjectData, DialogParentWindowID
  
  If *DataOffset\Type = #DIALOG_Window ; the toplevel object must be a window
    
    *CreateDialogData = *DataOffset
    DialogParentWindowID = ParentID
    Window.DialogObject = CreateNextDialogObject()
    *Window.DlgWindow   = Window
    
    ; add any keyboard shortcuts from the datasection
    ;
    *Shortcut.DialogShortcutData = *CreateDialogData
    While *Shortcut\Type = #DIALOG_Shortcut
      AddKeyboardShortcut(*Window\Window, *Shortcut\Key, *Shortcut\MenuItem)
      *Shortcut + SizeOf(DialogShortcutData) ; skip shortcut data
    Wend
    
    ; The SizeRequest is always needed to calculate minimum sizes internally,
    ; even If we do not use the values.
    ;
    Window\SizeRequest(@Width.l, @Height.l)
    
    If *Sizing And *Window\StaticData\Flags & #PB_Window_SizeGadget And *Sizing\Width <> -1 And *Sizing\Height <> -1
      If UCase(DialogObjectKey(*Window\StaticData, "FORCESIZE")) = "YES"
        ; do not go below the request size if forcesize=yes
        Width  = Max(Width, *Sizing\Width)
        Height = Max(Height, *Sizing\Height)
      Else
        Width  = *Sizing\Width
        Height = *Sizing\Height
      EndIf
    EndIf
    
    If *Sizing And *Sizing\x <> -1 And *Sizing\y <> -1
      x = *Sizing\x
      y = *Sizing\y
    Else ; center the dialog (done later for gtk2 and OSX as it must be after the resize)
      x = #PB_Ignore
      y = #PB_Ignore
      
      CompilerIf #CompileWindows
        AdjustWindowRectEx_(@Border.Rect, #WS_TILEDWINDOW, #False, #WS_EX_WINDOWEDGE)
        x = (DesktopUnscaledX(GetSystemMetrics_(#SM_CXSCREEN)-(Border\bottom-Border\top)) - Width) / 2
        y = (DesktopUnscaledY(GetSystemMetrics_(#SM_CYSCREEN)-(Border\right-Border\left)) - Height) / 2
      CompilerEndIf
    EndIf
    
    ; resize window (even when it gets maximized now) so the restored size is correct
    ;
    ResizeWindow(*Window\Window, x, y, Width, Height)
    
    CompilerIf #CompileLinuxGtk2
      If x = #PB_Ignore And y = #PB_Ignore
        gtk_window_set_position_(WindowID(*Window\Window), #GTK_WIN_POS_CENTER_ALWAYS)
      EndIf
    CompilerEndIf
    
    CompilerIf #CompileMacCocoa
      If x = #PB_Ignore And y = #PB_Ignore
        PB_Gadget_CenterWindow(WindowID(*Window\Window))
      EndIf
    CompilerEndIf
    
    If *Sizing And *Sizing\IsMaximized And *Window\StaticData\Flags & #PB_Window_MaximizeGadget
      SetWindowState(*Window\Window, #PB_Window_Maximize)
      Window\SizeApply(0, 0, WindowWidth(*Window\Window), WindowHeight(*Window\Window))
    Else
      Window\SizeApply(0, 0, Width, Height)
    EndIf
    
    If UCase(DialogObjectKey(*Window\StaticData, "DISABLED")) = "YES"
      DisableWindow(*Window\Window, 1)
    EndIf
    
    If UCase(DialogObjectKey(*Window\StaticData, "INVISIBLE")) <> "YES"
      HideWindow(*Window\Window, 0)
      
      ; we try again the resize as it sometimes does not work when the window is hidden it seems
      ;
      CompilerIf #CompileLinuxGtk2
        If x = #PB_Ignore And y = #PB_Ignore
          gtk_window_set_position_(WindowID(*Window\Window), #GTK_WIN_POS_CENTER)
        EndIf
      CompilerEndIf
      
    EndIf
    
    CompilerIf #PB_Compiler_Debugger
    Else
      MessageRequester("Dialog Manager", "Incorrect dialog data!")
    CompilerEndIf
  EndIf
  
  ProcedureReturn Window
EndProcedure



; =====================================================================================
; =====================================================================================
; =====================================================================================

CompilerIf 0
  XIncludeFile "test.pb"
  
  ;
  ; If CreateImage(1, 45, 20)
  ;   If StartDrawing(ImageOutput(1))
  ;     Box(0, 0, 45, 20, $000000)
  ;     Box(1, 1, 43, 18, $C0C0C0)
  ;     StopDrawing()
  ;   EndIf
  ; EndIf
  
  Window.DialogWindow = OpenDialog(?TestDialogddddddd, 0, 0)
  
  Debug WindowWidth(Window\Window())
  SetWindowColor(Window\Window(), $00FFFF)
  
  ;ResizeWindow(0, 100, 100, #PB_Ignore, #PB_Ignore)
  ;Window\SizeUpdate()
  
  ;Tree = Window\Gadget("tree")
  ;For i = 0 To 16
  ;  AddGadgetItem(Tree, -1, "Prefspage " + Str(i), 0, 0)
  ;Next i
  ;TreeCurrent = 0
  
  Repeat
    Event = WaitWindowEvent()
    
    ;   If Event = #PB_Event_Gadget
    ;   CompilerIf 0
    ;      If EventGadget() = Tree And EventType() = #PB_EventType_Change
    ;        New = GetGadgetState(Tree)
    ;        If New <> -1 And New <> TreeCurrent
    ;          HideGadget(Window\Gadget("container"+Str(New)), 0)
    ;          HideGadget(Window\Gadget("container"+Str(TreeCurrent)), 1)
    ;          TreeCurrent = New
    ;        EndIf
    ;
    ;      EndIf
    ;      CompilerEndIf
    ;
    ;    ElseIf Event = #PB_Event_SizeWindow
    ;      Window\SizeUpdate()
    ;    EndIf
  Until Event = #PB_Event_CloseWindow
  
  Window\Close(0)
  
  End
CompilerEndIf

