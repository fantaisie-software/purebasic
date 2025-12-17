; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; this file should contain all OS X specific extension
; functions that are "self contained" ie, do not need anything of the
; IDE, so they can be reused by the debugger and such
;

CompilerIf #CompileMacCocoa
  
  ImportC ""
    PB_Gadget_CenterEditorGadget(GadgetID.i)
    PB_Gadget_ShowToolBar(ToolBarID.i, State.l)
    PB_Gadget_SelectAllComboBoxText(*ComboBox)
    PB_Gadget_SetOpenFinderFiles(*Callback)
    PB_Gadget_AddFullScreenButton(*WindowID)
    PB_Gadget_AbsoluteGadgetY(*Gadget)
    ;  PB_Gadget_GetProperty(Gadget, Property)
    ;  PB_SelectElement(*List, Index) ; we need to use this on the ListIcon gadgets internal linkedlist, so we can't use the regular ListIndex()
  EndImport
  
  ; For the tab panel
  ;
  #kThemeBrushAlertBackgroundActive = 3
  #noErr = 0
  
  ; the HIThemeBrushCreateCGColor() is 10.4+ only, but the x86 version is at least 10.4 anyway
  ImportC ""
    HIThemeBrushCreateCGColor(Brush, *Color)
    CGColorGetComponents(Color)
    CGColorGetNumberOfComponents(Color)
    CGColorRelease(Color)
  EndImport
  
  CompilerIf Defined(PB_Gadget, #PB_Structure) = 0
    Structure PB_Gadget
      *Gadget
      *Container
      ; Definition is incomplete, but more is not needed
    EndStructure
  CompilerEndIf
  
  Procedure ShowWindowMaximized(Window)
    SetWindowState(Window, #PB_Window_Maximize)
    HideWindow(Window, 0)
  EndProcedure
  
  
  Procedure IsWindowMaximized(Window)
    If GetWindowState(Window) & #PB_Window_Maximize
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure IsWindowMinimized(Window)
    
    If GetWindowState(Window) & #PB_Window_Minimize
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
    
  EndProcedure
  
  Procedure SetWindowForeground(Window)
    
    SetActiveWindow(Window)  ; This is correct as SetActiveWindow() call SelectWindow_()
    
  EndProcedure
  
  ; set window to the foreground without giving it the focus (and without a focus event!)
  ;
  Procedure SetWindowForeground_NoActivate(Window)
    
    Debug "TODO SetWindowForeground_NoActivate()"
    ;BringToFront_(WindowID(Window))
    
  EndProcedure
  
  
  Procedure SetWindowStayOnTop(Window, StayOnTop)
    StickyWindow(Window, StayOnTop)
  EndProcedure
  
  
  Procedure GetPanelWidth(Gadget)
    ProcedureReturn GetGadgetAttribute(Gadget, #PB_Panel_ItemWidth)
  EndProcedure
  
  Procedure GetPanelHeight(Gadget)
    ProcedureReturn GetGadgetAttribute(Gadget, #PB_Panel_ItemHeight)
  EndProcedure
  
  
  
  Procedure SelectComboBoxText(Gadget)
    PB_Gadget_SelectAllComboBoxText(GadgetID(Gadget))
  EndProcedure
  
  
  Procedure RedrawGadget(Gadget)
    ; Not needed on Cocoa
  EndProcedure
  
  
  Procedure GetButtonBackgroundColor()
    ProcedureReturn $FFFFFF ; TODO
  EndProcedure
  
  Procedure StartFlickerFix(Window)
  EndProcedure
  
  Procedure StopFlickerFix(Window, DoRedraw)
  EndProcedure
  
  Procedure StartGadgetFlickerFix(Gadget)
  EndProcedure
  
  Procedure StopGadgetFlickerFix(Gadget)
  EndProcedure
  
  Procedure ZeroMemory(*Buffer, Size)
    memset_(*Buffer, 0, Size)
  EndProcedure
  
  Structure PB_ListIconElement
    *Text
    Image.i
    State.l
    UserData.i
  EndStructure
  
  Structure PB_TreeElement
    *Text
    Level.l
    Image.i
    Expanded.l
    Checked.l
    UserData.i
  EndStructure
  
  
  #ListProperty = AsciiConst('L', 'I', 'S', 'T')
  #PureImageColumnID = AsciiConst('P', 'U', 'R', 'I')
  
  #kDataBrowserNoItem = 0
  #kDataBrowserItemNoProperty = 0
  
  
  Procedure.s GetExplorerName()
    ProcedureReturn "Finder"
  EndProcedure
  
  Procedure ShowExplorerDirectory(Directory$)
    RunProgram("open", Chr(34)+Directory$+Chr(34), "")
  EndProcedure
  
  Procedure ShowExplorerFile(File$)
    RunProgram("open", "-R " + #DQUOTE$ + File$ + #DQUOTE$, "")
  EndProcedure
  
  ; Carbon event modifiers
  ;
  #activeFlagBit = 0
  #btnStateBit = 7
  #cmdKeyBit = 8
  #shiftKeyBit = 9
  #alphaLockBit = 10
  #optionKeyBit = 11
  #controlKeyBit = 12
  #rightShiftKeyBit = 13
  #rightOptionKeyBit = 14
  #rightControlKeyBit = 15
  
  #activeFlag = 1 << #activeFlagBit
  #btnState = 1 << #btnStateBit
  #cmdKey = 1 << #cmdKeyBit
  #shiftKey = 1 << #shiftKeyBit
  #alphaLock = 1 << #alphaLockBit
  #optionKey = 1 << #optionKeyBit
  #controlKey = 1 << #controlKeyBit
  #rightShiftKey = 1 << #rightShiftKeyBit
  #rightOptionKey = 1 << #rightOptionKeyBit
  #rightControlKey = 1 << #rightControlKeyBit
  
  Procedure ModifierKeyPressed(Key)
    
    Select Key
      Case #PB_Shortcut_Command: mod = #cmdKey
      Case #PB_Shortcut_Control: mod = #controlKey
      Case #PB_Shortcut_Shift:   mod = #shiftKey
      Case #PB_Shortcut_Alt:     mod = #optionKey
    EndSelect
    
    If GetCurrentEventKeyModifiers_() & mod
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure OpenWebBrowser(Url$)
    RunProgram("open", Url$, "")
  EndProcedure
  
  Procedure GetCocoaColor(NSColorName.s)
    Protected.CGFloat r, g, b, a
    Protected NSColor, NSColorSpace
    
    ; There is no controlAccentColor on macOS < 10.14
    If NSColorName = "controlAccentColor" And OSVersion() < #PB_OS_MacOSX_10_14
      ProcedureReturn $D5ABAD
    EndIf
    
    ; There are no system colors on macOS < 10.10
    If Left(NSColorName, 6) = "system" And OSVersion() < #PB_OS_MacOSX_10_10
      NSColorName = LCase(Mid(NSColorName, 7, 1)) + Mid(NSColorName, 8)
    EndIf
    
    NSColorSpace = CocoaMessage(0, 0, "NSColorSpace deviceRGBColorSpace")
    NSColor = CocoaMessage(0, CocoaMessage(0, 0, "NSColor " + NSColorName), "colorUsingColorSpace:", NSColorSpace)
    If NSColor
      CocoaMessage(@r, NSColor, "redComponent")
      CocoaMessage(@g, NSColor, "greenComponent")
      CocoaMessage(@b, NSColor, "blueComponent")
      CocoaMessage(@a, NSColor, "alphaComponent")
      ProcedureReturn RGBA(r * 255.0, g * 255.0, b * 255.0, a * 255.0)
    EndIf
  EndProcedure
  
  ; Ignore the apparence support if we are compiling the standalone debugger
  CompilerIf Defined(PUREBASIC_IDE, #PB_Constant)
    
    ; Appearance support
    
    Procedure UpdateAppearance()
      Protected NSApp, NSAppearance, NSAppearanceAqua, NSEffectiveAppearance, NSAppearanceSave
      Protected Update, OldFaceColor, Item, ItemCount
      
      NSApp = CocoaMessage(0, 0, "NSApplication sharedApplication")
      NSAppearance = CocoaMessage(0, NSApp, "appearance")
      
      If Not DisplayDarkMode And NSAppearance = 0
        NSAppearanceAqua = CocoaMessage(0, 0, "NSAppearance appearanceNamed:$", @"NSAppearanceNameAqua")
        CocoaMessage(0, NSApp, "setAppearance:", NSAppearanceAqua)
        Update = #True
      ElseIf DisplayDarkMode And NSAppearance <> 0
        NSAppearanceAqua = #nil
        CocoaMessage(0, NSApp, "setAppearance:", #nil)
        Update = #True
      EndIf
      
      If Update
        With TabBarGadgetInclude
          OldFaceColor = \FaceColor & $FFFFFF
          ; Save current appearance
          NSAppearanceSave = CocoaMessage(0, 0, "NSAppearance currentAppearance")
          NSEffectiveAppearance = CocoaMessage(0, NSApp, "effectiveAppearance")
          CocoaMessage(0, 0, "NSAppearance setCurrentAppearance:", NSEffectiveAppearance)
          \BorderColor = GetCocoaColor("systemGrayColor")
          \TabBarColor = GetCocoaColor("windowBackgroundColor")
          \TextColor   = GetCocoaColor("windowFrameTextColor")
          \FaceColor   = GetCocoaColor("windowBackgroundColor")
          ; Restore current appearance
          CocoaMessage(0, 0, "NSAppearance setCurrentAppearance:", NSAppearanceSave)
          ; Update tabbar item with default colors
          ItemCount = CountTabBarGadgetItems(#GADGET_FilesPanel) - 1
          For Item = 0 To ItemCount
            If GetTabBarGadgetItemColor(#GADGET_FilesPanel, Item, #PB_Gadget_BackColor) = OldFaceColor
              SetTabBarGadgetItemColor(#GADGET_FilesPanel, Item, #PB_Gadget_FrontColor, \TextColor)
              SetTabBarGadgetItemColor(#GADGET_FilesPanel, Item, #PB_Gadget_BackColor, \FaceColor)
            EndIf
          Next
        EndWith
        If DisplayDarkMode
          ; Update FormDesigner GridGadget
          grid_color_bg = GetCocoaColor("underPageBackgroundColor")
          grid_color_text = GetCocoaColor("textColor")
          grid_color_light = GetCocoaColor("windowBackgroundColor")
          grid_color_mid = #Gray
        EndIf
      EndIf
      
    EndProcedure
    
    EnumerationBinary
      #NSKeyValueObservingOptionNew
      #NSKeyValueObservingOptionOld
    EndEnumeration
    
    ProcedureC KVO_Appearance(obj, sel, keyPath, object, change, context)
      Select PeekS(CocoaMessage(0, keyPath, "UTF8String"), -1, #PB_UTF8)
        Case "effectiveAppearance"
          If DisplayDarkMode
            With TabBarGadgetInclude
              OldFaceColor = \FaceColor & $FFFFFF
              ; Save current appearance
              NSAppearanceSave = CocoaMessage(0, 0, "NSAppearance currentAppearance")
              NSEffectiveAppearance = CocoaMessage(0, NSApp, "effectiveAppearance")
              CocoaMessage(0, 0, "NSAppearance setCurrentAppearance:", NSEffectiveAppearance)
              \BorderColor = GetCocoaColor("systemGrayColor")
              \TabBarColor = GetCocoaColor("windowBackgroundColor")
              \TextColor   = GetCocoaColor("windowFrameTextColor")
              \FaceColor   = GetCocoaColor("windowBackgroundColor")
              ; Restore current appearance
              CocoaMessage(0, 0, "NSAppearance setCurrentAppearance:", NSAppearanceSave)
              ; Update tabbar item with default colors
              ItemCount = CountTabBarGadgetItems(#GADGET_FilesPanel) - 1
              For Item = 0 To ItemCount
                If GetTabBarGadgetItemColor(#GADGET_FilesPanel, Item, #PB_Gadget_BackColor) = OldFaceColor
                  SetTabBarGadgetItemColor(#GADGET_FilesPanel, Item, #PB_Gadget_FrontColor, \TextColor)
                  SetTabBarGadgetItemColor(#GADGET_FilesPanel, Item, #PB_Gadget_BackColor, \FaceColor)
                EndIf
              Next
            EndWith
            ; Update FormDesigner GridGadget
            grid_color_bg = GetCocoaColor("underPageBackgroundColor")
            grid_color_text = GetCocoaColor("textColor")
            grid_color_light = GetCocoaColor("windowBackgroundColor")
            grid_color_mid = #Gray
          EndIf
          
      EndSelect
    EndProcedure

    Procedure InitAppearanceObserver()
      Protected NSApp, KVO_Class, KVO_Object
   
      ; Create Key-Value Observer class (PB_KVO_Appearance)
      KVO_Class = objc_allocateClassPair_(objc_getClass_("NSObject"), "PB_KVO_Appearance", 0)
      class_addMethod_(KVO_Class, sel_registerName_("observeValueForKeyPath:ofObject:change:context:"), @KVO_Appearance(), "v@:@@@^v")
      objc_registerClassPair_(KVO_Class)

      ; Create PB_KVO class instance (KVO)
      KVO_Object = CocoaMessage(0, 0, "PB_KVO_Appearance new")

      ; Add observer
      NSApp = CocoaMessage(0, 0, "NSApplication sharedApplication")
      CocoaMessage(0, NSApp, "addObserver:", KVO_Object, "forKeyPath:$", @"effectiveAppearance", "options:", #NSKeyValueObservingOptionNew, "context:", #nil)

    EndProcedure
  CompilerEndIf
  
  Procedure GetListViewScroll(Gadget)
    Protected *GadgetStruct.PB_Gadget, *ClipView, Bounds.CGRect
    
    *GadgetStruct = IsGadget(Gadget)
    *ClipView = CocoaMessage(0, *GadgetStruct\Container, "contentView")
    CocoaMessage(@Bounds, *ClipView, "bounds")
    
    ProcedureReturn Bounds\origin\y
  EndProcedure
  
  Procedure SetListViewScroll(Gadget, Position)
    Protected *GadgetStruct.PB_Gadget, *DocumentView, TargetPoint.CGPoint
    TargetPoint\y = Position
    
    *GadgetStruct = IsGadget(Gadget)
    *DocumentView = CocoaMessage(0, *GadgetStruct\Container, "documentView")
    CocoaMessage(0, *DocumentView, "scrollPoint:@", @TargetPoint)
  EndProcedure
    
CompilerEndIf
