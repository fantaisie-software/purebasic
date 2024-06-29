; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; this file should contain all linux specific extension
; functions that are "self contained" ie, do not need anything of the
; IDE, so they can be reused by the debugger and such
;

CompilerIf #CompileLinux

  ; ---------------------------------------------------
  ; Required XLib stuff:
  ; ---------------------------------------------------
  
  ImportC "-lX11" ; link with XLib even if no gui commands are used
    XOpenDisplay(display_name)
    XCloseDisplay(display)
    XInternAtom(display, name.p-ascii, only_if_exists)
    XFree(pdata)
    XDefaultRootWindow(display)
    XGetWindowProperty(display, w, property, long_offset, long_length, delete, req_type, actual_type_return, actual_format_return, nitems_return, bytes_after_return, prop_return)
    XGetWMName(display, w, text_prop_return)
  EndImport
  
  CompilerIf #CompileLinuxGtk
    ImportC ""
      gtk_widget_get_window_(window) As "gtk_widget_get_window" ; Gtk 2.14 or newer
    EndImport
  CompilerEndIf
  
  CompilerIf #CompileLinuxQt
    ImportC "Build/QtHelpers.a"
      Qt_ScrollEditorToBottom(*Widget)
      QT_CenterEditor(*Widget)
      QT_SelectComboBoxText(*Widget)
      QT_GetListViewScroll(*Widget)
      QT_SetListViewScroll(*Widget, Value)
      QT_WindowBackgroundColor(*Window)
      QT_GetViewPort(*Widget)
      QT_SetEventFilter(*Widget, *Handler)
      QT_SendEvent(*Widget, *Event)
      QT_EventType(*Event)
      QT_EventKey(*Event)
      QT_EventButton(*Event)
    EndImport
  CompilerEndIf
  
  
  #Success = 0
  
  ; If there is no window manager that complies to the WM manager hints is present,
  ; the result is an empty string
  ;
  Procedure.s GetWindowManager()
    Result$ = ""
    
    ; uses the default DISPLAY environment variable
    ; can also be a display string, needs to be ascii though!
    ;
    xdisplay = XOpenDisplay(#Null)
    
    If xdisplay
      
      _NET_SUPPORTING_WM_CHECK = XInternAtom(xdisplay, "_NET_SUPPORTING_WM_CHECK", #False)
      _NET_WM_NAME             = XInternAtom(xdisplay, "_NET_WM_NAME", #False)
      WINDOW_PROPERTY          = XInternAtom(xdisplay, "WINDOW", #False)
      UTF8_PROPERTY            = XInternAtom(xdisplay, "UTF8_STRING", #False)
      
      ; read the _NET_SUPPORTING_WM_CHECK from the X root window
      ;
      If XGetWindowProperty(xdisplay, XDefaultRootWindow(xdisplay), _NET_SUPPORTING_WM_CHECK, 0, 32, #False, WINDOW_PROPERTY, @rettype, @retformat, @retitems, @retbytes, @resultdata) = #Success And resultdata
        If rettype = WINDOW_PROPERTY And retformat = 32 And retitems >= 1
          child = PeekL(resultdata)
          
          ; the child must also have a _NET_SUPPORTING_WM_CHECK according to the specification
          ;
          If XGetWindowProperty(xdisplay, child, _NET_SUPPORTING_WM_CHECK, 0, 32, #False, WINDOW_PROPERTY, @rettype, @retformat, @retitems, @retbytes, @resultdata2) = #Success And resultdata2
            If rettype = WINDOW_PROPERTY And retformat = 32 And retitems >= 1 And PeekL(resultdata2) = child
              
              ; read the _NET_WM_NAME which stores the WM name for complying implementations
              ;
              If XGetWindowProperty(xdisplay, child, _NET_WM_NAME, 0, 6400, #False, UTF8_PROPERTY, @rettype, @retformat, @retitems, @retbytes, @resultstring) = #Success And resultstring
                If rettype = UTF8_PROPERTY And retformat = 8 And retitems >= 1
                  Result$ = PeekS(resultstring, -1, #PB_UTF8)
                EndIf
                XFree(resultstring)
              EndIf
              
            EndIf
            XFree(resultdata2)
          EndIf
          
        EndIf
        XFree(resultdata)
      EndIf
      
      XCloseDisplay(xdisplay) ; if we opened it, close it again!
    EndIf
    
    ProcedureReturn Result$
  EndProcedure
  
  CompilerIf #CompileLinuxGtk
    Procedure GTKSignalConnect(*Widget, Signal$, Function, user_data)
      g_signal_connect_data_(*Widget, Signal$, Function, user_data, 0, 0)
    EndProcedure
  CompilerEndIf
  
  
  Procedure ShowWindowMaximized(Window)
    ; PB4 supports all this now (also gtk1)
    ;
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
    CompilerIf #CompileLinuxGtk
      gdk_window_raise_(gtk_widget_get_window_(WindowID(Window)))
    CompilerElse
      QtScript("window(" + Window + ").raise()")
    CompilerEndIf
    SetActiveWindow(Window)
  EndProcedure
  
  ; set window to the foreground without giving it the focus (and without a focus event!)
  Procedure SetWindowForeground_NoActivate(Window)
    CompilerIf #CompileLinuxGtk
      gdk_window_raise_(gtk_widget_get_window_(WindowID(Window)))
    CompilerElse
      QtScript("window(" + Window + ").raise()")
    CompilerEndIf
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
    CompilerIf #CompileLinuxGtk
      *Entry = gtk_bin_get_child_(GadgetID(Gadget))
      
      If *Entry
        gtk_editable_select_region_(*Entry, 0, -1)
        gtk_widget_grab_focus_(*Entry)
      EndIf
    CompilerElse
      QT_SelectComboBoxText(GadgetID(Gadget))
    CompilerEndIf
  EndProcedure
  
  
  Procedure RedrawGadget(Gadget)
    CompilerIf #CompileLinuxGtk
      gtk_widget_queue_draw_(GadgetID(Gadget))
    CompilerElse
      QtScript("gadget(" + Gadget + ").update()")
    CompilerEndIf
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
    ;memset_(*Buffer, 0, Size)  ; somehow this causes an assembler error
    For i = 0 To size-1
      PokeB(*Buffer+i, 0)
    Next i
  EndProcedure
  
  CompilerIf #CompileLinuxGtk
    ImportC ""
      ; This is a varargs function, so do an import which allows us to set 1 value
      ; Terminator MUST be -1
      gtk_list_store_set_1(*Store, *Item, Column, *Value, Terminator) As "gtk_list_store_set"
      gtk_tree_store_set_1(*Store, *Item, Column, *Value, Terminator) As "gtk_tree_store_set"
    EndImport
  CompilerEndIf
  
  Global FileManagerExe$
  Global FileManagerParameters$
  Global FileManagerName$
  Global FileManagerFound
  
  Procedure DetectFileManager()
    Protected NewList Managers.s()
    
    If FileManagerFound = 0
      ;
      ; Try to find a suitable file manager from a list of managers
      ; Check the WindowManager name to try the ones that are usually the default
      ; on a WindowManager first
      ;
      WindowManager$ = UCase(GetWindowManager())
      
      ; Window manager names can contain version info etc
      ;
      If FindString(WindowManager$, "METACITY", 1)
        ; Gnome desktop
        AddElement(Managers()): Managers() = "nautilus"
        AddElement(Managers()): Managers() = "gnome-commander"
        AddElement(Managers()): Managers() = "dolphin"
        AddElement(Managers()): Managers() = "konqueror"
        AddElement(Managers()): Managers() = "krusader"
        AddElement(Managers()): Managers() = "thunar"
        AddElement(Managers()): Managers() = "nemo"
        AddElement(Managers()): Managers() = "pcmanfm"
        
      ElseIf FindString(WindowManager$, "KWIN", 1)
        ; KDE
        AddElement(Managers()): Managers() = "dolphin"   ; kde4 default
        AddElement(Managers()): Managers() = "konqueror" ; kde3 default
        AddElement(Managers()): Managers() = "krusader"
        AddElement(Managers()): Managers() = "nautilus"
        AddElement(Managers()): Managers() = "gnome-commander"
        AddElement(Managers()): Managers() = "thunar"
        AddElement(Managers()): Managers() = "nemo"
        AddElement(Managers()): Managers() = "pcmanfm"
        
        ; ElseIf FindString(WindowManager$, "XFWM", 1)
        ; Xfce (use the below fallback for that and others)
        
      ElseIf FindString(WindowManager$, "MUTTER", 1)
        ; Mutter
        AddElement(Managers()): Managers() = "nemo"
        AddElement(Managers()): Managers() = "pcmanfm"
        AddElement(Managers()): Managers() = "nautilus"
        AddElement(Managers()): Managers() = "gnome-commander"
        AddElement(Managers()): Managers() = "dolphin"
        AddElement(Managers()): Managers() = "konqueror"
        AddElement(Managers()): Managers() = "krusader"
        AddElement(Managers()): Managers() = "thunar"
        
      Else
        ; fallback
        AddElement(Managers()): Managers() = "thunar"
        AddElement(Managers()): Managers() = "dolphin"
        AddElement(Managers()): Managers() = "konqueror"
        AddElement(Managers()): Managers() = "krusader"
        AddElement(Managers()): Managers() = "nautilus"
        AddElement(Managers()): Managers() = "gnome-commander"
        AddElement(Managers()): Managers() = "nemo"
        AddElement(Managers()): Managers() = "pcmanfm"
        
      EndIf
      
      ; Test which file manager exists
      ;
      ForEach Managers()
        CommandLine$ = "which "+Managers()+" > "+TempPath$+"PB_ManagerTest.txt 2>/dev/null"
        If system_(ToAscii(CommandLine$)) = 0
          file = ReadFile(#PB_Any, TempPath$+"PB_ManagerTest.txt")
          If file
            FileManagerExe$  = ReadString(file)
            FileManagerFound = #True
            CloseFile(file)
            
            Select Managers()
                
              Case "nautilus"
                FileManagerName$ = "Nautilus"
                FileManagerParameters$ = ""
                
              Case "gnome-commander"
                FileManagerName$ = "Gnome Commander"
                FileManagerParameters$ = "-l "
                
              Case "konqueror"
                FileManagerName$ = "Konqueror"
                FileManagerParameters$ = ""
                
              Case "dolphin"
                FileManagerName$ = "Dolphin"
                FileManagerParameters$ = ""
                
              Case "krusader"
                FileManagerName$ = "Krusader"
                FileManagerParameters$ = "--left "
                
              Case "thunar"
                FileManagerName$ = "Thunar"
                FileManagerParameters$ = ""
                
              Case "nemo"
                FileManagerName$ = "Nemo"
                FileManagerParameters$ = ""
                
              Case "pcmanfm"
                FileManagerName$ = "PcManFM"
                FileManagerParameters$ = ""
              
            EndSelect
            
            Break
          EndIf
        EndIf
      Next Managers()
      
      DeleteFile(TempPath$+"PB_ManagerTest.txt")
    EndIf
  EndProcedure
  
  
  Procedure.s GetExplorerName()
    DetectFileManager()
    If FileManagerFound
      ProcedureReturn FileManagerName$
    Else
      ProcedureReturn "Filemanager"
    EndIf
  EndProcedure
  
  Procedure ShowExplorerDirectory(Directory$)
    DetectFileManager()
    If FileManagerFound
      RunProgram(FileManagerExe$, FileManagerParameters$+Chr(34)+Directory$+Chr(34), "")
    EndIf
  EndProcedure
  
  Procedure ShowExplorerFile(File$)
    ; For now, just launch the containing folder
    ShowExplorerDirectory(GetPathPart(File$))
  EndProcedure
  
  Procedure ModifierKeyPressed(Key)
    ; Not used on Linux
    ProcedureReturn 0
  EndProcedure
  
  Procedure OpenWebBrowser(Url$)
    
    If RunProgram("xdg-open", Url$, "") = #False
      browser$ = Trim(GetEnvironmentVariable("BROWSER"))
      If browser$ = ""
        If RunProgram("gnome-open", Url$, "") = #False
          If RunProgram("kfmclient","exec " + Url$, "") = #False
            If RunProgram("www-browser", Url$, "") = #False
              MessageRequester(#ProductName$, "Cannot open WebBrowser!")
            EndIf
          EndIf
        EndIf
      Else
        If RunProgram(browser$, Url$, "") = #False
          MessageRequester(#ProductName$, "Cannot open WebBrowser!")
        EndIf
      EndIf
    EndIf
    
  EndProcedure
  
  CompilerIf #CompileLinuxGtk
    ImportC ""
      gtk_adjustment_get_value.d(*Adjustment)
      gtk_adjustment_set_value(*Adjustment, Position.d)
    EndImport
  CompilerEndIf
  
  Procedure GetListViewScroll(Gadget)
    CompilerIf #CompileLinuxGtk
      ProcedureReturn gtk_adjustment_get_value(gtk_tree_view_get_vadjustment_(GadgetID(Gadget)))
    CompilerElse
      ProcedureReturn QT_GetListViewScroll(GadgetID(Gadget))
    CompilerEndIf
  EndProcedure
  
  Procedure SetListViewScroll(Gadget, Position)
    CompilerIf #CompileLinuxGtk
      gtk_adjustment_set_value(gtk_tree_view_get_vadjustment_(GadgetID(Gadget)), Position)
    CompilerElse
      QT_SetListViewScroll(GadgetID(Gadget), Position)
    CompilerEndIf
  EndProcedure
  
CompilerEndIf
