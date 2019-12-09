;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

; this file should contain all linux specific extension
; functions that are "self contained" ie, do not need anything of the
; IDE, so they can be reused by the debugger and such
;

CompilerIf #CompileLinux
  
  Structure _GtkAllocation Extends GtkAllocation: EndStructure
  Structure _GtkWidget Extends GtkWidget: EndStructure
  Structure _GtkWindow Extends GtkWindow: EndStructure
  Structure _GtkCombo Extends GtkCombo: EndStructure
  Structure _GtkBin Extends GtkBin: EndStructure
  Structure _GtkEditable Extends GtkEditable: EndStructure
  Structure _GtkText Extends GtkText: EndStructure
  Structure _GtkStyle Extends GtkStyle: EndStructure
  Structure _GtkAdjustment Extends GtkAdjustment: EndStructure
  
  Structure _GdkEventButton Extends GdkEventButton: EndStructure  ; to solve future gtk2 trouble easily
  Structure _GdkEventClient Extends GdkEventClient: EndStructure
  Structure _GdkEventKey Extends GdkEventKey: EndStructure
  
  CompilerIf #CompileX64
    ;CompilerError "check this struct for x64"
  CompilerEndIf
  
  
  Structure XClientMessageEvent
    type.l        ; int
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      alignment1.l
    CompilerEndIf
    serial.i      ; unsigned long    /* # of last request processed by server */
    send_event.l  ; Bool (=int)    /* true if this came from a SendEvent request */
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      alignment2.l
    CompilerEndIf
    *display      ; pointer  /* Display the event was read from */
    window.i      ; Window (= pointer)
    message_type.i; Atom (= pointer)
    format.l      ; int
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      alignment3.l
    CompilerEndIf
    StructureUnion
      b.b[20]      ; char
      s.w[10]      ; short
      l.i[5]       ; long is 64bit on Linux64!
    EndStructureUnion
  EndStructure
  
  
  Structure _GdkScreen Extends GdkScreen ; PB def seems to be incomplete
                                         ;     *font_options;
                                         ;     resolution.d;      /* pixels/points scale factor for fonts */
  EndStructure
  
  
  Structure GdkScreenX11
    parent_instance._GdkScreen;
    
    *display
    *xdisplay
    *xscreen
    
    ; incomplete def!
  EndStructure
  
  Structure GdkDrawableImplX11
    parent_instance.GdkDrawable
    *wrapper
    *colormap
    
    xid.l
    *screen
    
    picture.l ;Picture
    *cairo_surface
  EndStructure
  
  Structure _GdkWindowObject ; PB def is empty!
    parent_instance.GdkDrawable;
    *impl.GdkDrawable          ; /* window-system-specific delegate object */
    *parent
    user_data.l
    ; incomplete def!
  EndStructure
  
  ;#define GDK_WINDOW_XDISPLAY(win)      (GDK_SCREEN_X11 (GDK_WINDOW_SCREEN (win))->xdisplay)
  ;#define GDK_WINDOW_XID(win)           (GDK_DRAWABLE_IMPL_X11(((GdkWindowObject *)win)->impl)->xid)
  ;#define GDK_WINDOW_SCREEN(win)         (GDK_DRAWABLE_IMPL_X11 (((GdkWindowObject *)win)->impl)->screen)
  ;#define GDK_SCREEN_X11(object)           (G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_SCREEN_X11, GdkScreenX11))
  ;#define GDK_DRAWABLE_IMPL_X11(object)           (G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DRAWABLE_IMPL_X11, GdkDrawableImplX11))
  
  Procedure XDisplayFromWindowID(*Window.GtkWidget)
    *gdkwindowobj._GdkWindowObject = *Window\window
    *impl.GdkDrawableImplX11 = *gdkwindowobj\impl
    *screen.GdkScreenX11 = *impl\screen
    ProcedureReturn *screen\xdisplay
  EndProcedure
  
  
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
  
  
  #Success = 0
  
  ; If WindowID != 0 (a result from WindowID()), the current X display from gtk is used
  ; Else a new X connection is opened just for this command, so this also works if
  ; no GUI commands are used.
  ;
  ; If the program has open windows, it is advised to use one of them here
  ; to avoid the extra X connection.
  ;
  ; If there is no window manager that complies to the WM manager hints is present,
  ; the result is an empty string
  ;
  Procedure.s GetWindowManager(WindowID = 0)
    Result$ = ""
    
    If WindowID
      xdisplay = XDisplayFromWindowID(WindowID)
    Else
      ; uses the default DISPLAY environment variable
      ; can also be a display string, needs to be ascii though!
      ;
      xdisplay = XOpenDisplay(#Null)
    EndIf
    
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
      
      If WindowID = 0
        XCloseDisplay(xdisplay) ; if we opened it, close it again!
      EndIf
    EndIf
    
    ProcedureReturn Result$
  EndProcedure
  
  
  Procedure GTKSignalConnect(*Widget, Signal$, Function, user_data)
    g_signal_connect_data_(*Widget, Signal$, Function, user_data, 0, 0)
  EndProcedure
  
  
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
    
    *Widget._GtkWidget = WindowID(Window)
    gdk_window_raise_(*Widget\Window)
    SetActiveWindow(Window)
    
  EndProcedure
  
  ; set window to the foreground without giving it the focus (and without a focus event!)
  Procedure SetWindowForeground_NoActivate(Window)
    
    *Widget._GtkWidget = WindowID(Window)
    gdk_window_raise_(*Widget\Window)
    
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
  
  
  Procedure GetPanelItemID(Gadget, Item)
    
    ProcedureReturn gtk_notebook_get_nth_page_(GadgetID(Gadget), Item)
    
  EndProcedure
  
  
  Procedure SelectComboBoxText(Gadget)
    *Entry = gtk_bin_get_child_(GadgetID(Gadget))
    
    If *Entry
      gtk_editable_select_region_(*Entry, 0, -1)
      gtk_widget_grab_focus_(*Entry)
    EndIf
  EndProcedure
  
  
  Procedure RedrawGadget(Gadget)
    gtk_widget_queue_draw_(GadgetID(Gadget))
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
  
  ImportC ""
    ; This is a varargs function, so do an import which allows us to set 1 value
    ; Terminator MUST be -1
    gtk_list_store_set_1(*Store, *Item, Column, *Value, Terminator) As "gtk_list_store_set"
    gtk_tree_store_set_1(*Store, *Item, Column, *Value, Terminator) As "gtk_tree_store_set"
  EndImport
  
  CompilerIf Defined(PB_Gadget, #PB_Structure) = 0
    Structure PB_Gadget
      *Gadget.GtkWidget
      *Container.GtkWidget
      *VT
      UserData.i
      GadgetData.i[4]
    EndStructure
  CompilerEndIf
  
  Structure PB_TreeCache
    ItemCount.l
    ArraySize.l
    *Cache
  EndStructure
  
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
        
      ElseIf FindString(WindowManager$, "KWIN", 1)
        ; KDE
        AddElement(Managers()): Managers() = "dolphin"   ; kde4 default
        AddElement(Managers()): Managers() = "konqueror" ; kde3 default
        AddElement(Managers()): Managers() = "krusader"
        AddElement(Managers()): Managers() = "nautilus"
        AddElement(Managers()): Managers() = "gnome-commander"
        AddElement(Managers()): Managers() = "thunar"
        
        ; ElseIf FindString(WindowManager$, "XFWM", 1)
        ; Xfce (use the below fallback for that and others)
        
      Else
        ; fallback
        AddElement(Managers()): Managers() = "thunar"
        AddElement(Managers()): Managers() = "dolphin"
        AddElement(Managers()): Managers() = "konqueror"
        AddElement(Managers()): Managers() = "krusader"
        AddElement(Managers()): Managers() = "nautilus"
        AddElement(Managers()): Managers() = "gnome-commander"
        
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
  
  Procedure ModifierKeyPressed(Key)
    Select Key
      Case #PB_Shortcut_Shift:   mod = #GDK_SHIFT_MASK
      Case #PB_Shortcut_Control: mod = #GDK_CONTROL_MASK
      Case #PB_Shortcut_Alt:     mod = #GDK_MOD1_MASK
    EndSelect
    
    ; We don't need the pointer, so just use the main window as reference
    *Window.GtkWidget = WindowID(#WINDOW_Main)
    gdk_window_get_pointer_(*Window\window, @x, @y, @mask)
    
    If mask & mod
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
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
  
CompilerEndIf
