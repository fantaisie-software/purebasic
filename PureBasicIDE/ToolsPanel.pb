; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


Procedure ActivateTool(Name$)
  Opened = 0
  
  If ToolsPanelMode
    ; try the tools in the panel first
    ;
    ForEach UsedPanelTools()
      *PanelToolData.ToolsPanelEntry = UsedPanelTools()
      If *PanelToolData\ToolID$ = Name$
        SetGadgetState(#GADGET_ToolsPanel, ListIndex(UsedPanelTools()))
        CurrentTool = UsedPanelTools()
        CurrentTool\ResizeHandler(GetPanelWidth(#GADGET_ToolsPanel), GetPanelHeight(#GADGET_ToolsPanel))
        Opened = 1
        Break
      EndIf
    Next UsedPanelTools()
    
    If Opened And ToolsPanelAutoHide And ToolsPanelVisible = 0
      If ToolsPanelHideDelay < 2500
        ToolsPanelHideTime.q = ElapsedMilliseconds() + 2500 ; stay open for at least 2.5 seconds!
      Else
        ToolsPanelHideTime.q = ElapsedMilliseconds() + ToolsPanelHideDelay
      EndIf
      ToolsPanel_Show()
    EndIf
  EndIf
  
  If Opened = 0
    
    ; now try the rest and open in external window
    ;
    ForEach AvailablePanelTools()
      If AvailablePanelTools()\ToolID$ = Name$
        If AvailablePanelTools()\IsSeparateWindow
          SetWindowForeground(AvailablePanelTools()\ToolWindowID)
          SetActiveWindow(AvailablePanelTools()\ToolWindowID)
        Else
          
          Flags = #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget
          If AvailablePanelTools()\ToolWindowX = 0
            Flags | #PB_Window_ScreenCentered
          EndIf
          
          If AvailablePanelTools()\ExternalPlugin
            Title$ = AvailablePanelTools()\PanelTitle$
          Else
            Title$ = Language("ToolsPanel", AvailablePanelTools()\PanelTitle$)
          EndIf
          
          WindowWidth = AvailablePanelTools()\ToolWindowWidth
          If WindowWidth < AvailablePanelTools()\ToolMinWindowWidth
            WindowWidth = AvailablePanelTools()\ToolMinWindowWidth
          EndIf
          
          WindowHeight = AvailablePanelTools()\ToolWindowHeight
          If WindowHeight < AvailablePanelTools()\ToolMinWindowHeight
            WindowHeight = AvailablePanelTools()\ToolMinWindowHeight
          EndIf
          
          Window = OpenWindow(#PB_Any, AvailablePanelTools()\ToolWindowX, AvailablePanelTools()\ToolWindowY, WindowWidth, WindowHeight, Title$, Flags)
          If Window
            EnsureWindowOnDesktop(Window)
            WindowBounds(Window, AvailablePanelTools()\ToolMinWindowWidth, AvailablePanelTools()\ToolMinWindowHeight, #PB_Ignore, #PB_Ignore)
            
            AvailablePanelTools()\IsSeparateWindow = 1
            AvailablePanelTools()\ToolWindowID = Window
            Tool.ToolsPanelInterface = @AvailablePanelTools()
            Tool\CreateFunction()
            
            If #DEFAULT_CanWindowStayOnTop
              ;               CompilerIf #CompileWindows
              ;                 AvailablePanelTools()\ToolStayOnTop = CheckBoxGadget(#PB_Any, 5, WindowHeight(Window)-23, WindowWidth(Window)-10, 23, Language("Misc","StayOnTop"))
              ;               CompilerElse
              ;                 AvailablePanelTools()\ToolStayOnTop = CheckBoxGadget(#PB_Any, 5, WindowHeight(Window)-25, WindowWidth(Window)-10, 25, Language("Misc","StayOnTop"))
              ;               CompilerEndIf
              AvailablePanelTools()\ToolStayOnTop = CheckBoxGadget(#PB_Any, 5, WindowHeight(Window)-25, WindowWidth(Window)-10, 25, Language("Misc","StayOnTop"))
              Height = GetRequiredHeight(AvailablePanelTools()\ToolStayOnTop)
              ResizeGadget(AvailablePanelTools()\ToolStayOnTop, 5, WindowHeight(Window)-Height-5, WindowWidth(Window)-10, Height)
              SetGadgetState(AvailablePanelTools()\ToolStayOnTop, AvailablePanelTools()\IsToolStayOnTop)
              SetWindowStayOnTop(Window, AvailablePanelTools()\IsToolStayOnTop)
              Tool\ResizeHandler(WindowWidth(Window), WindowHeight(Window)-Height-5)
            Else
              Tool\ResizeHandler(WindowWidth(Window), WindowHeight(Window))
            EndIf
          EndIf
        EndIf
        
        Break
      EndIf
    Next AvailablePanelTools()
    
  EndIf
  
EndProcedure

; Creates the "hidden panel" image. This procedure is used on OSX, and as fallback for the other os
;
Procedure ToolsPanel_CreateFake_Default()
  
  CatchImage(#IMAGE_ToolsPanelRight, ?Image_ToolsPanelRight)
  CatchImage(#IMAGE_ToolsPanelLeft, ?Image_ToolsPanelLeft)
  
  If ToolsPanelSide = 0
    ImageGadget(#GADGET_ToolsPanelFake, 0, 0, 0, 0, ImageID(#IMAGE_ToolsPanelRight))
  Else
    ImageGadget(#GADGET_ToolsPanelFake, 0, 0, 0, 0, ImageID(#IMAGE_ToolsPanelLeft))
  EndIf
  ToolsPanelHiddenWidth = 16
  
EndProcedure


; Special Windows procedure for the vertical.
; Does not work on XP, so windows still needs the default fallback
;
CompilerIf #CompileWindows
  Procedure ToolsPanel_CreateFake_Windows()
    
    #TCS_VERTICAL = $80
    #TCS_RIGHT = $2
    
    ; on windows we have a special replacement for the hidden panel (= vertical tab)
    ; which does not work on XP.
    ; Intrestingly, this works ok on vista (though the gadget is displayed without skins there)
    If OSVersion() <> #PB_OS_Windows_XP
      
      ; this frees the old fake panel created below as well, as it is its child.
      ;
      ContainerGadget(#GADGET_ToolsPanelFake, 0, 0, 0, 0)
      CloseGadgetList()
      
      If ToolsPanelSide = 0
        style = #TCS_RIGHT
      Else
        style = 0
      EndIf
      
      
      FakeToolsPanelID = CreateWindowEx_(0, "SysTabControl32", "", #WS_VISIBLE|#WS_OVERLAPPED|#WS_CHILD|#WS_CLIPSIBLINGS|#TCS_MULTILINE|#TCS_VERTICAL|style, 0, 0, 0, 0, GadgetID(#GADGET_ToolsPanelFake), 0, GetModuleHandle_(#Null$) , 0)
      If FakeToolsPanelID
        
        ; we use MS Sans serif for the vertical panel, as any other try to modify the
        ; system default font looks ugly.
        ; all this will not be done on XP anyway (were there is another default font)
        ;
        FontID = FontID(LoadFont(#PB_Any, "MS Sans Serif", 10, #PB_Font_HighQuality))
        SendMessage_(FakeToolsPanelID, #WM_SETFONT, FontID, 0)
        
        ForEach UsedPanelTools()
          *ToolData.ToolsPanelEntry = UsedPanelTools()
          If *ToolData\ExternalPlugin
            Text$ = *ToolData\PanelTitle$
          Else
            Text$ = Language("ToolsPanel", *ToolData\PanelTitle$)
          EndIf
          
          panelitem.TC_ITEM\mask = #TCIF_TEXT
          panelitem\pszText = @Text$
          SendMessage_(FakeToolsPanelID, #TCM_INSERTITEM, ListIndex(UsedPanelTools()), @panelitem)
          
        Next UsedPanelTools()
        
      EndIf
      
      ToolsPanelHiddenWidth = 25 ; width of the vertical panel
    Else
      ; use the fallback procedure on XP
      ToolsPanel_CreateFake_Default()
      
    EndIf
    
  EndProcedure
CompilerEndIf

; Special linux procedure for the vertical panel
;
CompilerIf #CompileLinuxGtk
  
  ImportC ""
    gtk_label_set_angle_(*Label.GtkWidget, angle.d) As "gtk_label_set_angle" ; Gtk 2.6+
  EndImport
  
  Procedure ToolsPanel_CreateFake_Linux(IsUpdate)
    PanelGadget(#GADGET_ToolsPanelFake, 0, 0, 0, 0)
    
    ; If the gadget is visible (toolspanel update), then we get the same warning as mentioned below
    ; So just hide it (this is done after creation anyway, so it does not hurt)
    If IsUpdate
      HideGadget(#GADGET_ToolsPanelFake, 1)
    EndIf
    
    ForEach UsedPanelTools()
      *ToolData.ToolsPanelEntry = UsedPanelTools()
      If *ToolData\ExternalPlugin
        AddGadgetItem(#GADGET_ToolsPanelFake, -1, *ToolData\PanelTitle$)
      Else
        AddGadgetItem(#GADGET_ToolsPanelFake, -1, Language("ToolsPanel", *ToolData\PanelTitle$))
      EndIf
      
      ; set the needed orientation for the tab label
      ; Note that the actual label is now inside a container (because of image support)
      ;
      *LabelContainer.GtkWidget = gtk_notebook_get_tab_label_(GadgetID(#GADGET_ToolsPanelFake), gtk_notebook_get_nth_page_(GadgetID(#GADGET_ToolsPanelFake), ListIndex(UsedPanelTools())))
      *Children = gtk_container_get_children_(*LabelContainer)
      *Label.GtkWidget = g_list_nth_data_(*Children, 1) ; label is the second child (image slot is always present)
      g_list_free_(*Children)                           ; free this list
      
      If ToolsPanelSide = 0
        gtk_label_set_angle_(*Label, 270)
      Else
        gtk_label_set_angle_(*Label, 90)
      EndIf
    Next UsedPanelTools()
    
    CloseGadgetList()
    
    ; make it vertical
    ;
    If ToolsPanelSide = 0
      gtk_notebook_set_tab_pos_(GadgetID(#GADGET_ToolsPanelFake), #GTK_POS_RIGHT)
    Else
      gtk_notebook_set_tab_pos_(GadgetID(#GADGET_ToolsPanelFake), #GTK_POS_LEFT)
    EndIf
    
    ; Note: ToolsPanelHiddenWidth cannot be set here, as the window is not shown
    ;  yet, and there is no way to calculate the tab height. This variable is set
    ;  in the main source when the PanelTabHeight is calculated as well.
    ;
    ; Note: We have to set this to a high enough value for the startup, else we get
    ;  a gtk warning by some theme engine (CRITICAL **: clearlooks_style_draw_box_gap: assertion `width >= -1' failed)
    ;  The real value is set later in PureBasic.pb
    ;
    If IsUpdate = #False
      ToolsPanelHiddenWidth = 50
    EndIf
        
  EndProcedure
CompilerEndIf


Procedure ToolsPanel_Create(IsUpdate)
  
  UseGadgetList(WindowID(#WINDOW_Main))
  
  ; create the gadget that represents the "hidden" panel
  ;
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows: ToolsPanel_CreateFake_Windows()
    CompilerCase #PB_OS_Linux
      CompilerIf #CompileLinuxGtk
        ToolsPanel_CreateFake_Linux(IsUpdate)
      CompilerElse
        ToolsPanel_CreateFake_Default()
      CompilerEndIf
    CompilerCase #PB_OS_MacOS:   ToolsPanel_CreateFake_Default() ; use same as windows fallback
  CompilerEndSelect
  
  HideGadget(#GADGET_ToolsPanelFake, 1)
  
  If ToolsPanelMode
    
    If IsGadget(#GADGET_ToolsPanel) ; we do not destroy the gadget anymore
      OpenGadgetList(#GADGET_ToolsPanel)
    Else
      PanelGadget(#GADGET_ToolsPanel, 0, 0, 0, 0)
    EndIf
    
    ForEach UsedPanelTools()
      *ToolData.ToolsPanelEntry = UsedPanelTools()
      
      If *ToolData\ExternalPlugin
        AddGadgetItem(#GADGET_ToolsPanel, -1, *ToolData\PanelTitle$)
      Else
        AddGadgetItem(#GADGET_ToolsPanel, -1, Language("ToolsPanel", *ToolData\PanelTitle$))
      EndIf
      PanelTool.ToolsPanelInterface = UsedPanelTools()
      PanelTool\CreateFunction()
    Next UsedPanelTools()
    
    FirstElement(UsedPanelTools())  ; set the current tool.. very important!
    CurrentTool = UsedPanelTools()
    
    CloseGadgetList()
    
    CompilerIf #CompileWindows
      SetWindowLongPtr_(GadgetID(#GADGET_ToolsPanel), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#GADGET_ToolsPanel), #GWL_STYLE) | #TCS_MULTILINE)
    CompilerEndIf
    
  Else
    If IsGadget(#GADGET_ToolsPanel) = 0
      PanelGadget(#GADGET_ToolsPanel, 0, 0, 0, 0) ; still create the gadget if we do not need a panel
      CloseGadgetList()
    EndIf
    HideGadget(#GADGET_ToolsPanel, 1)
    
  EndIf
  
EndProcedure

Procedure ToolsPanel_Update()
  
  ; because you can also change the order of items in the ToolsPanel completely,
  ; we destroy the whole ToolsPanel and recreate it.
  ;
  ForEach UsedPanelTools()
    *ToolData.ToolsPanelEntry = UsedPanelTools()
    If *ToolData\NeedDestroyFunction
      PanelTool.ToolsPanelInterface = UsedPanelTools()
      PanelTool\DestroyFunction()
    EndIf
  Next UsedPanelTools()
  
  ClearList(UsedPanelTools())
  
  If IsGadget(#GADGET_ToolsPanel)
    ClearGadgetItems(#GADGET_ToolsPanel) ; no more freegadget
  EndIf
  
  If ListSize(NewUsedPanelTools()) > 0
    ToolsPanelMode = 1
  Else
    ToolsPanelMode = 0
  EndIf
  
  ; Close any tools in external tool windows to avoid any conflicts
  ;
  ForEach AvailablePanelTools()
    If AvailablePanelTools()\IsSeparateWindow
      If AvailablePanelTools()\NeedDestroyFunction
        Tool.ToolsPanelInterface = @AvailablePanelTools()
        Tool\DestroyFunction()
      EndIf
      
      If MemorizeWindow
        Window = AvailablePanelTools()\ToolWindowID
        AvailablePanelTools()\ToolWindowX      = WindowX(Window)
        AvailablePanelTools()\ToolWindowY      = WindowY(Window)
        AvailablePanelTools()\ToolWindowWidth  = WindowWidth(Window)
        AvailablePanelTools()\ToolWindowHeight = WindowHeight(Window)
      EndIf
      CloseWindow(AvailablePanelTools()\ToolWindowID)
      AvailablePanelTools()\ToolWindowID = -1
      AvailablePanelTools()\IsSeparateWindow = 0
    EndIf
  Next AvailablePanelTools()
  
  ; copy the NewUsedPanelTools() to the UsedPanelTools()
  ;
  ForEach NewUsedPanelTools()
    AddElement(UsedPanelTools())
    UsedPanelTools() = NewUsedPanelTools()
  Next NewUsedPanelTools()
  
  ; now re-create the whole thing
  ;
  ToolsPanel_Create(#True)
  
  ; Swap the gadgets in the splitter if the Toolspanelside changed.
  ; we need to check which is the toolspanel, as ToolsPanelSide is already updated,
  ; we cannot use that one to know where the panel is now :)
  ;
  If GadgetType(GetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget)) = #PB_GadgetType_Panel
    OldSide = 1
  Else
    OldSide = 0
  EndIf
  
  If OldSide <> ToolsPanelSide
    ; create a dummy gadget for the swap
    DummyGadget = ContainerGadget(#PB_Any, 0, 0, 0, 0)
    CloseGadgetList()
    
    FirstGadget  = GetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget)
    SecondGadget = GetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondGadget)
    
    SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget, DummyGadget)
    SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondGadget, FirstGadget)
    SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget, SecondGadget)
    
    ; reverse the sizes as well
    SetGadgetState(#GADGET_ToolsSplitter, GadgetWidth(#GADGET_ToolsSplitter)-GetGadgetState(#GADGET_ToolsSplitter))
    
    FreeGadget(DummyGadget)
  EndIf
  
  If ToolsPanelVisible = 0
    HideGadget(#GADGET_ToolsPanelFake, 0)
  EndIf
  
  If ToolsPanelAutoHide Or  ToolsPanelMode = 0 ; hide the panel if we do not need it
    ToolsPanel_Hide()
  ElseIf ToolsPanelMode
    ToolsPanel_Show()
  EndIf
  
  ; Resize the currently displayed tool
  ;
  If ToolsPanelVisible And CurrentTool
    CurrentTool\ResizeHandler(GetPanelWidth(#GADGET_ToolsPanel), GetPanelHeight(#GADGET_ToolsPanel))
  EndIf
EndProcedure

; checks the autohide state of the ToolsPanel.
; If ToolsPanelAutoHide is set, the OS specific Event code must ensure that
; this is called either on any mouse movement or in a timer interval
; to ensure correct updates of this
;
Procedure ToolsPanel_CheckAutoHide()
  If ToolsPanelAutoHide And ToolsPanelMode
    MouseX = WindowMouseX(#WINDOW_Main)
    
    If MouseX <> -1 And WindowMouseY(#WINDOW_Main) <> -1 ; do nothing if mouse is outside of the window
      
      ; Convert cursor X position from physical to logical pixels to ensure that scale is
      ; consistent with editor and tool-panel widths.
      ; This must be done only after it's determined to be in-frame; unscaling prior will
      ; result in failure at high scale factors (where -1 becomes 0).
      ;
      CompilerIf #CompileWindows
        MouseX = DesktopUnscaledX(MouseX)
      CompilerEndIf

      If ToolsPanelSide = 0 ; right side
        Offset = EditorWindowWidth - MouseX
        ToolsPanelWidth = GadgetWidth(#GADGET_ToolsSplitter) - GetGadgetState(#GADGET_ToolsSplitter)
      Else
        Offset = MouseX
        ToolsPanelWidth = GetGadgetState(#GADGET_ToolsSplitter)
      EndIf
      
      ;Debug "Width: " + Str(ToolsPanelWidth) + ", X: "+Str(Offset)
      
      If ToolsPanelVisible And Offset > ToolsPanelWidth + 40
        If ToolsPanelHideTime = 0 ; first time the panel was left
          ToolsPanelHideTime.q = ElapsedMilliseconds() + ToolsPanelHideDelay
        ElseIf ToolsPanelHideTime < ElapsedMilliseconds() ; the hide timeout has passed
          ToolsPanel_Hide()
          ToolsPanelHideTime = 0
        EndIf
        
      ElseIf ToolsPanelVisible = 0 And Offset < ToolsPanelHiddenWidth
        ToolsPanel_Show()
        ToolsPanelHideTime = 0
        
      EndIf
      
    EndIf
    
  EndIf
EndProcedure

Procedure ToolsPanel_Hide()
  
  CompilerIf #CompileWindows
    If FakeToolsPanelID
      SendMessage_(FakeToolsPanelID, #TCM_SETCURSEL, GetGadgetState(#GADGET_ToolsPanel), 0)
    EndIf
  CompilerEndIf
  
  CompilerIf #CompileLinuxGtk
    If GadgetType(#GADGET_ToolsPanelFake) = #PB_GadgetType_Panel ; check if we used the vertical panel
      SetGadgetState(#GADGET_ToolsPanelFake, GetGadgetState(#GADGET_ToolsPanel))
    EndIf
  CompilerEndIf
  
  If ToolsPanelVisible ; no check for ToolsPanelMode here, as we call this to hide the panel when ToolsPanelMode = 0
    If ErrorLogVisible
      State = GetGadgetState(#GADGET_LogSplitter) ; somehow the reparenting makes the slider jump in the second splitter on linux, so only reset it after ResizeWindow()
    EndIf
    
    CompilerIf #CompileWindows
      ; Temporarily disable painting to avoid flickering while reparenting.
      SendMessage_(WindowID(#WINDOW_Main), #WM_SETREDRAW, #False, 0)
    CompilerEndIf
    
    If ToolsPanelSide = 0
      ToolsPanelWidth_Hidden = GadgetWidth(#GADGET_ToolsSplitter) - GetGadgetState(#GADGET_ToolsSplitter)
      SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget, #GADGET_ToolsDummy)
    Else
      ToolsPanelWidth_Hidden = GetGadgetState(#GADGET_ToolsSplitter)
      SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondGadget, #GADGET_ToolsDummy)
    EndIf
    
    ToolsPanelVisible = 0
    HideGadget(#GADGET_ToolsPanelFake, 0)
    ResizeMainWindow()
    CompilerIf #CompileWindows
      ; Restore painting to have updated visuals reflected.
      SendMessage_(WindowID(#WINDOW_Main), #WM_SETREDRAW, #True, 0)
    CompilerEndIf
    HideGadget(#GADGET_ToolsSplitter, 1)
    
    If ErrorLogVisible
      SetGadgetState(#GADGET_LogSplitter, State)
    EndIf
  EndIf
  
EndProcedure

Procedure ToolsPanel_Show()
  If ToolsPanelVisible = 0 And ToolsPanelMode
    If ErrorLogVisible
      State = GetGadgetState(#GADGET_LogSplitter) ; somehow the reparenting makes the slider jump in the second splitter on linux, so only reset it after ResizeWindow()
      OldGadget = #GADGET_LogSplitter
    Else
      OldGadget = #GADGET_SourceContainer
    EndIf
    
    HideGadget(#GADGET_ToolsSplitter, 0)
    
    If ToolsPanelSide = 0
      SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_FirstGadget, OldGadget)
    Else
      SetGadgetAttribute(#GADGET_ToolsSplitter, #PB_Splitter_SecondGadget, OldGadget)
    EndIf
    
    ToolsPanelVisible = 1
    HideGadget(#GADGET_ToolsPanelFake, 1)
    ResizeMainWindow()
    
    ; apply the old state again.
    If ToolsPanelSide = 0
      SetGadgetState(#GADGET_ToolsSplitter, GadgetWidth(#GADGET_ToolsSplitter)-ToolsPanelWidth_Hidden)
    Else
      SetGadgetState(#GADGET_ToolsSplitter, ToolsPanelWidth_Hidden)
    EndIf
    
    If ErrorLogVisible
      SetGadgetState(#GADGET_LogSplitter, State)
    EndIf
  EndIf
  
EndProcedure

DataSection
  
  Image_ToolsPanelRight:
    IncludeBinary "data/ToolsPanelRight.png"
  
  Image_ToolsPanelLeft:
    IncludeBinary "data/ToolsPanelLeft.png"
  
EndDataSection