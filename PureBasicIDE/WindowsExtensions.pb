; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;windows only
CompilerIf #CompileWindows
  
  
  Procedure ShowWindowMaximized(Window)
    
    ShowWindow_(WindowID(Window), #SW_MAXIMIZE)
    
  EndProcedure
  
  Procedure IsWindowMaximized(Window)
    
    ProcedureReturn IsZoomed_(WindowID(Window))
    
  EndProcedure
  
  Procedure IsWindowMinimized(Window)
    
    ProcedureReturn IsIconic_(WindowID(Window))
    
  EndProcedure
  
  Procedure SetWindowForeground(Window)
    
    If GetWindowLongPtr_(WindowID(Window), #GWL_STYLE) & #WS_MINIMIZE
      ShowWindow_(WindowID(Window), #SW_RESTORE)
    EndIf
    
    BringWindowToTop_(WindowID(Window))
    SetForegroundWindow_(WindowID(Window))
    
    SetActiveWindow(Window)
    
  EndProcedure
  
  Procedure SetWindowForeground_NoActivate(Window)
    
    SetWindowPos_(WindowID(Window), #HWND_TOP, 0,0,0,0, #SWP_NOACTIVATE|#SWP_NOMOVE|#SWP_NOOWNERZORDER|#SWP_NOSIZE)
    
  EndProcedure
  
  ; windows only, force window to the foreground
  ;
  ; NOTE: This function is dangerous and can cause the IDE to hang.
  ;   Use this only when there is no other option.
  ;   (currently used only by AddTools.pb and by the Commiunication.pb in the Debugger)
  ;
  Procedure SetWindowForeground_Real(Window)
    
    hWnd = WindowID(Window)
    
    If GetWindowLongPtr_(hWnd, #GWL_STYLE) & #WS_MINIMIZE
      ShowWindow_(hWnd, #SW_RESTORE)
    EndIf
    
    ; Check To see If we are the foreground thread
    
    foregroundThreadID = GetWindowThreadProcessId_(GetForegroundWindow_(), 0)
    ourThreadID = GetCurrentThreadId_()
    ; If not, attach our thread's 'input' to the foreground thread's
    
    If (foregroundThreadID <> ourThreadID)
      AttachThreadInput_(foregroundThreadID, ourThreadID, #True);
    EndIf
    
    ; Bring our window To the foreground
    SetForegroundWindow_(hWnd)
    
    ; If we attached our thread, detach it now
    If (foregroundThreadID <> ourThreadID)
      AttachThreadInput_(foregroundThreadID, ourThreadID, #False)
    EndIf
    
    ; Needed to redraw the frame, as the window is activated but the frame stay in inactive color (at least on XP)
    RedrawWindow_(hWnd, #Null, #Null, #RDW_FRAME | #RDW_INVALIDATE)
    
  EndProcedure
  
  Procedure SetWindowStayOnTop(Window, StayOnTop)
    
    If StayOnTop
      SetWindowPos_(WindowID(Window), #HWND_TOPMOST , 0, 0, 0, 0, #SWP_NOSIZE |#SWP_NOMOVE)
    Else
      SetWindowPos_(WindowID(Window), #HWND_NOTOPMOST , 0, 0, 0, 0, #SWP_NOSIZE |#SWP_NOMOVE)
    EndIf
    
  EndProcedure
  
  
  Procedure GetPanelWidth(Gadget)
    ;   tc.TC_ITEM\mask = #TCIF_PARAM
    ;   If SendMessage_(GadgetID(Gadget), #TCM_GETITEM, GetGadgetState(Gadget), @tc)
    ;     GetClientRect_(tc\lParam, rect.RECT)
    ;     ProcedureReturn rect\right
    ;   EndIf
    ProcedureReturn GetGadgetAttribute(Gadget, #PB_Panel_ItemWidth)
  EndProcedure
  
  Procedure GetPanelHeight(Gadget)
    ;   tc.TC_ITEM\mask = #TCIF_PARAM
    ;   If SendMessage_(GadgetID(Gadget), #TCM_GETITEM, GetGadgetState(Gadget), @tc)
    ;     GetClientRect_(tc\lParam, rect.RECT)
    ;     ProcedureReturn rect\bottom
    ;   EndIf
    ProcedureReturn GetGadgetAttribute(Gadget, #PB_Panel_ItemHeight)
  EndProcedure
  
  
  Procedure SelectComboBoxText(Gadget)
    
    SendMessage_(GadgetID(Gadget), #EM_SETSEL, 0, -1)
    SetFocus_(GadgetID(Gadget))
    
  EndProcedure
  
  Procedure RedrawGadget(Gadget)
    RedrawWindow_(GadgetID(Gadget), 0, 0, #RDW_INVALIDATE)
  EndProcedure
  
  
  Procedure GetButtonBackgroundColor()
    ProcedureReturn GetSysColor_(#COLOR_BTNFACE)
  EndProcedure
  
  Procedure StartFlickerFix(Window)
    ; LockWindowUpdate() seems to be better for us than #WM_SETREDRAW: it does weird things on Windows 8 (try with 100 recent file list, the main IDE flicker when loading a new file)
    LockWindowUpdate_(WindowID(Window))
  EndProcedure
  
  Procedure StopFlickerFix(Window, DoRedraw)
    LockWindowUpdate_(#Null)
  EndProcedure
  
  Procedure StartGadgetFlickerFix(Gadget)
    SendMessage_(GadgetID(Gadget), #WM_SETREDRAW, #False, 0)
  EndProcedure
  
  Procedure StopGadgetFlickerFix(Gadget)
    SendMessage_(GadgetID(Gadget), #WM_SETREDRAW, #True, 0)
    InvalidateRect_(GadgetID(Gadget), #Null, #True)
  EndProcedure
  
  
  Structure AdditionalStreamInfo_2 ; _2 to not collide with the richedit one! (in case richedit is used)
    Action.i                       ; 0=streamin 1=streamout
    Buffer.i
    Length.i
  EndStructure
  
  Procedure RichEdit_StreamCallback_2(*StreamInfo.AdditionalStreamInfo_2, *Buffer, BufferLength.l, *Result.LONG)
    Result = 0
    
    If *StreamInfo\Action = 0  ; stream in
      
      If BufferLength < *StreamInfo\Length
        CopyMemory(*StreamInfo\Buffer, *Buffer, BufferLength)
        
        *StreamInfo\Buffer + BufferLength
        *StreamInfo\Length - BufferLength
        *Result\l = BufferLength
        
      Else
        CopyMemory(*StreamInfo\Buffer, *Buffer, *StreamInfo\Length)
        
        *Result\l = *StreamInfo\Length
        *StreamInfo\Length = 0
        
      EndIf
      
    Else  ; stream out
      
      If BufferLength < *StreamInfo\Length
        CopyMemory(*Buffer, *StreamInfo\Buffer, BufferLength)
        
        *StreamInfo\Buffer + BufferLength
        *StreamInfo\Length - BufferLength
        *Result\l = BufferLength
        
      Else
        CopyMemory(*Buffer, *StreamInfo\Buffer, *StreamInfo\Length)
        
        *Result\l = *StreamInfo\Length
        *StreamInfo\Length = 0
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  #HDF_BITMAP_ON_RIGHT = $1000
  #HDI_IMAGE           = $0020
  
  #HDF_SORTUP   = $0400 ; WinXP+ with skins only, but that's enough
  #HDF_SORTDOWN = $0200
  
  Procedure SetSortArrow_NoTheme(Gadget, Column, Direction)
    Static UpImage, DownImage
    
    If UpImage = 0
      UpImage   = CreateImage(#PB_Any, 10, 10)
      DownImage = CreateImage(#PB_Any, 10, 10)
      
      If StartDrawing(ImageOutput(DownImage))
        Box(0, 0, 10, 10, GetSysColor_(#COLOR_BTNFACE))
        Restore SortArrowImage
        For y = 0 To 9
          For x = 0 To 9
            Read.b Pixel
            If Pixel
              Plot(x, y, $000000)
            EndIf
          Next x
        Next y
        StopDrawing()
      EndIf
      
      If StartDrawing(ImageOutput(UpImage))
        Box(0, 0, 10, 10, GetSysColor_(#COLOR_BTNFACE))
        Restore SortArrowImage
        For y = 9 To 0 Step -1
          For x = 0 To 9
            Read.b Pixel
            If Pixel
              Plot(x, y, $000000)
            EndIf
          Next x
        Next y
        StopDrawing()
      EndIf
      
    EndIf
    
    Protected item.HD_ITEM, Header, Columns, Text$, i
    
    Header = SendMessage_(GadgetID(Gadget), #LVM_GETHEADER, 0, 0)
    If Header
      Columns = SendMessage_(Header, #HDM_GETITEMCOUNT, 0, 0)
      
      For i = 0 To Columns-1
        Text$ = GetGadgetItemText(Gadget, -1, i)
        
        If Column = i
          item\mask       = #HDI_BITMAP | #HDI_FORMAT | #HDI_TEXT
          item\fmt        = #HDF_BITMAP | #HDF_BITMAP_ON_RIGHT | #HDF_STRING
          item\pszText    = @Text$
          item\cchTextMax = Len(Text$)
          
          If Direction = 1
            item\hbm = ImageID(UpImage)
          Else
            item\hbm = ImageID(DownImage)
          EndIf
        Else
          item\mask       = #HDI_FORMAT | #HDI_TEXT
          item\fmt        = #HDF_STRING
          item\pszText    = @Text$
          item\cchTextMax = Len(Text$)
          item\hbm        = 0
        EndIf
        
        SendMessage_(Header, #HDM_SETITEM, i, @item)
      Next i
    EndIf
  EndProcedure
  
  DataSection
    
    SortArrowImage:
    Data.b 0,0,0,0,0,0,0,0,0,0
    Data.b 0,0,0,0,0,0,0,0,0,0
    Data.b 0,0,0,0,0,0,0,0,0,0
    Data.b 1,1,1,1,1,1,1,1,1,1
    Data.b 0,1,1,1,1,1,1,1,1,0
    Data.b 0,0,1,1,1,1,1,1,0,0
    Data.b 0,0,0,1,1,1,1,0,0,0
    Data.b 0,0,0,0,1,1,0,0,0,0
    Data.b 0,0,0,0,0,0,0,0,0,0
    Data.b 0,0,0,0,0,0,0,0,0,0
    
  EndDataSection
  
  Procedure SetSortArrow_Theme(Gadget, Column, Direction)
    Header = SendMessage_(GadgetID(Gadget), #LVM_GETHEADER, 0, 0)
    
    If Header
      Columns = SendMessage_(Header, #HDM_GETITEMCOUNT, 0, 0)
      item.HD_ITEM\mask = #HDI_FORMAT
      
      For i = 0 To Columns-1
        If Column = i
          If Direction = 1
            item\fmt = #HDF_LEFT|#HDF_STRING|#HDF_SORTUP
          Else
            item\fmt = #HDF_LEFT|#HDF_STRING|#HDF_SORTDOWN
          EndIf
        Else
          item\fmt = #HDF_LEFT|#HDF_STRING
        EndIf
        
        SendMessage_(Header, #HDM_SETITEM, i, @item)
      Next i
    EndIf
  EndProcedure
  
  CompilerIf #PB_Compiler_Backend = #PB_Backend_C
    Import ""
      PB_Gadget_IsThemed.l
    EndImport
  CompilerEndIf
    
  
  ; Windows only
  ;
  ; Column: -1 to reset
  ; Direction: 1=ascending, -1=descending
  ;
  Procedure SetSortArrow(Gadget, Column, Direction)
    Protected IsThemed
    
    ; PB_Gadget_GetCommonControlsVersion() is called by ListIconGadget, so this is ok
    ;
    CompilerIf #PB_Compiler_Backend = #PB_Backend_C
      IsThemed = PB_Gadget_IsThemed
    CompilerElseIf #PB_Compiler_Processor = #PB_Processor_x86
      !extrn _PB_Gadget_IsThemed
      !mov eax, [_PB_Gadget_IsThemed]
      !mov [p.v_IsThemed], eax
    CompilerElse
      !extrn PB_Gadget_IsThemed
      !mov rax, qword 0
      !mov eax, dword [PB_Gadget_IsThemed]
      !mov [p.v_IsThemed], rax
    CompilerEndIf
    
    If IsThemed
      SetSortArrow_Theme(Gadget, Column, Direction)
    Else
      SetSortArrow_NoTheme(Gadget, Column, Direction)
    EndIf
  EndProcedure
  
  Procedure ZeroMemory(*Buffer, Size)
    RtlZeroMemory_(*Buffer, Size)
  EndProcedure
  
  Procedure.s GetExplorerName()
    ProcedureReturn "Explorer"
  EndProcedure
  
  Procedure ShowExplorerDirectory(Directory$)
    ShellExecute_(#Null, @"explore", @Directory$, #Null, #Null, #SW_SHOWNORMAL)
  EndProcedure
  
  Procedure ShowExplorerFile(File$)
    RunProgram("explorer.exe", "/SELECT," + #DQUOTE$ + File$ + #DQUOTE$, "")
  EndProcedure
  
  Procedure ModifierKeyPressed(Key)
    Select Key
      Case #PB_Shortcut_Shift:   vKey = #VK_SHIFT
      Case #PB_Shortcut_Control: vKey = #VK_CONTROL
      Case #PB_Shortcut_Alt:     vKey = #VK_MENU
    EndSelect
    
    If GetAsyncKeyState_(vKey) & $8000
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure OpenWebBrowser(Url$)
    ShellExecute_(#Null, @"open", @Url$, @"", @"", #SW_SHOWNORMAL)
  EndProcedure
  
  Procedure GetListViewScroll(Gadget)
    ProcedureReturn SendMessage_(GadgetID(Gadget), #LB_GETTOPINDEX, 0, 0)
  EndProcedure
  
  Procedure SetListViewScroll(Gadget, Position)
    SendMessage_(GadgetID(Gadget), #LB_SETTOPINDEX, Position, 0)
  EndProcedure
  
CompilerEndIf