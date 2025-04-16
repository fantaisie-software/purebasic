; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Functions for Plugins
;
Prototype PLUGIN_InitLibraryPlugin(*buffer) ; for DLL only: - Called when DLL is loaded. Must Fill buffer With LibraryID$ (max size:1000) And Return 0 Or 1
Prototype PLUGIN_EndViewer()                ; Called before unloading the dll (optional)
Prototype PLUGIN_DisplayObject(WindowID, *ObjectData, Size)  ; must create display gadgets on WindowID, and return *Object pointer to identify this later
Prototype PLUGIN_RemoveObject(*Object)                       ; must free gadgets and clear up anything belonging to *Object
Prototype PLUGIN_GetObjectWidth(*Object)                     ; must return required with to display *Object
Prototype PLUGIN_GetObjectHeight(*Object)                    ; must return required height to display *Object
Prototype PLUGIN_SetObjectSize(*Object, Width, Height)       ; can be used as alternative to GetObjectWidth/Height for a dynamic resize
Prototype PLUGIN_ProcessEvents(*Object, EventGadgetID, EventType)   ; must handle events for *Object. NOTE: EventGadgetID might not belong to this object.. ignore it in that case!

Structure LibraryViewerPLUGIN
  
  ; Plugin Data
  ;
  LibraryID$        ; LibraryID for this Plugin
  DllNumber.l       ; #Library ID of the loaded DLL (0 for internal plugins)
  
  ; Function Pointers:
  ;
  EndViewer.PLUGIN_EndViewer
  DisplayObject.PLUGIN_DisplayObject
  RemoveObject.PLUGIN_RemoveObject
  GetObjectWidth.PLUGIN_GetObjectWidth
  GetObjectHeight.PLUGIN_GetObjectHeight
  SetObjectSize.PLUGIN_SetObjectSize
  ProcessEvents.PLUGIN_ProcessEvents
  
EndStructure

Global NewList LibraryPlugins.LibraryViewerPLUGIN()

; Log errors with plugin dlls to help people with debugging
;
Procedure LibraryViewer_Init_Log(FileName$, Message$)
  Static LastFileName$
  
  If LastFileName$ = ""
    Log = CreateFile(#PB_Any, PureBasicPath$+#DEFAILT_LibraryViewerPlugin+"LibraryViewer.log")
    If Log
      WriteStringN(Log, "PureBasicDebugger - LibraryViewerPlugin - Log")
      WriteStringN(Log, FormatDate("Date: %mm/%dd/%yyyy - %hh:%ii:%ss", Date()))
    EndIf
  Else
    Log = OpenFile(#PB_Any, PureBasicPath$+#DEFAILT_LibraryViewerPlugin+"LibraryViewer.log")
    If Log
      FileSeek(Log, Lof(Log))
    EndIf
  EndIf
  
  If Log
    If FileName$ <> LastFileName$
      WriteStringN(Log, "")
      WriteStringN(Log, "====== FILE : "+FileName$+" =======")
      LastFileName$ = FileName$
    EndIf
    WriteStringN(Log, Message$)
    
    CloseFile(Log)
  EndIf
  
EndProcedure

; Load all the plugin dlls in the debugger directory
;
Procedure LibraryViewer_Init()
  Static IsInitialized
  
  If IsInitialized = 0
    
    If ExamineDirectory(0, PureBasicPath$+#DEFAILT_LibraryViewerPlugin, "*."+#DEFAULT_DLLExtension)
      ; delete old log file)
      DeleteFile(PureBasicPath$+#DEFAILT_LibraryViewerPlugin+"LibraryViewer.log")
      
      While NextDirectoryEntry(0)
        entry = DirectoryEntryType(0)
        If entry = 1
          
          File$   = PureBasicPath$+#DEFAILT_LibraryViewerPlugin+DirectoryEntryName(0)
          Library = OpenLibrary(#PB_Any, File$)
          Success = 0
          
          If Library
            
            InitFunction.PLUGIN_InitLibraryPlugin = GetFunction(Library, "InitLibraryPlugin")
            If InitFunction
              LibraryID$ = Space(1000)
              If InitFunction(@LibraryID$)
                LibraryID$ = PeekAscii(@LibraryID$) ; we expect an ascii string here
                If Trim(LibraryID$) <> ""
                  
                  ; Ok, seems to be a valid plugin dll...
                  ;
                  Success = 1 ; do not unload this dll again!
                  
                  AddElement(LibraryPlugins())
                  LibraryPlugins()\LibraryID$      = LibraryID$
                  LibraryPlugins()\DllNumber       = Library
                  LibraryPlugins()\EndViewer       = GetFunction(Library, "EndViewer")
                  LibraryPlugins()\DisplayObject   = GetFunction(Library, "DisplayObject")
                  LibraryPlugins()\RemoveObject    = GetFunction(Library, "RemoveObject")
                  LibraryPlugins()\GetObjectWidth  = GetFunction(Library, "GetObjectWidth")
                  LibraryPlugins()\GetObjectHeight = GetFunction(Library, "GetObjectHeight")
                  LibraryPlugins()\SetObjectSize   = GetFunction(Library, "SetObjectSize")
                  LibraryPlugins()\ProcessEvents   = GetFunction(Library, "ProcessEvents")
                  
                  ; Check if the required functions are present
                  ;
                  If LibraryPlugins()\DisplayObject = 0
                    LibraryViewer_Init_Log(File$, "Function: DisplayObject(WindowID, *data, size)")
                    LibraryViewer_Init_Log(File$, "  Required Function missing! Cannot use this plugin")
                    Success = 0
                  EndIf
                  
                  If LibraryPlugins()\RemoveObject = 0
                    LibraryViewer_Init_Log(File$, "Function: RemoveObject(*Object)")
                    LibraryViewer_Init_Log(File$, "  Required Function missing! Cannot use this plugin")
                    Success = 0
                  EndIf
                  
                  If LibraryPlugins()\SetObjectSize = 0
                    ; here we only put a warning as we have a working solution
                    If LibraryPlugins()\GetObjectWidth = 0
                      LibraryViewer_Init_Log(File$, "Function: GetObjectWidth(*Object)")
                      LibraryViewer_Init_Log(File$, "  Required Function missing! Cannot use this plugin")
                      LibraryViewer_Init_Log(File$, "  Optionally, SetObjectSize() could be implemented instead.")
                      Success = 0
                    EndIf
                    
                    If LibraryPlugins()\GetObjectHeight = 0
                      LibraryViewer_Init_Log(File$, "Function: GetObjectHeight(*Object)")
                      LibraryViewer_Init_Log(File$, "  Required Function missing! Cannot use this plugin")
                      LibraryViewer_Init_Log(File$, "  Optionally, SetObjectSize() could be implemented instead.")
                      Success = 0
                    EndIf
                  Else
                    If LibraryPlugins()\GetObjectWidth = 0
                      LibraryViewer_Init_Log(File$, "Function: GetObjectWidth(*Object)")
                      LibraryViewer_Init_Log(File$, "  SetObjectSize() is already implemented. This function is ignored.")
                    EndIf
                    
                    If LibraryPlugins()\GetObjectHeight = 0
                      LibraryViewer_Init_Log(File$, "Function: GetObjectHeight(*Object)")
                      LibraryViewer_Init_Log(File$, "  SetObjectSize() is already implemented. This function is ignored.")
                    EndIf
                  EndIf
                  
                  ; EndViewer and ProcessEvents are optional functions
                  
                  If Success = 0  ; remove the plugin data if a function is missing
                    If LibraryPlugins()\EndViewer
                      LibraryPlugins()\EndViewer()
                    EndIf
                    DeleteElement(LibraryPlugins())
                  EndIf
                  
                Else
                  LibraryViewer_Init_Log(File$, "Function: InitLibraryPlugin(*IdBuffer)")
                  LibraryViewer_Init_Log(File$, "  *IdBuffer is empty. A Library ID String must be put there.")
                EndIf
              Else
                LibraryViewer_Init_Log(File$, "Function: InitLibraryPlugin(*IdBuffer)")
                LibraryViewer_Init_Log(File$, "  Returnvalue was 0! Plugin not correctly initialized.")
              EndIf
            Else
              LibraryViewer_Init_Log(File$, "Function: InitLibraryPlugin(*IdBuffer)")
              LibraryViewer_Init_Log(File$, "  Init function missing! Not a valid LibraryViewer Plugin DLL.")
            EndIf
            
            If Success = 0  ; unload the dll if it is no valid plugin dll
              CloseLibrary(Library)
            EndIf
          Else
            LibraryViewer_Init_Log(File$, "Cannot load the DLL!")
          EndIf
          
        EndIf
      Wend
      
      FinishDirectory(0)
    EndIf
    
    IsInitialized = 1
  EndIf
  
EndProcedure

Procedure LibraryViewer_End()
  
  ForEach LibraryPlugins()
    
    ; call the Viewers end function
    ;
    If LibraryPlugins()\EndViewer
      LibraryPlugins()\EndViewer()
    EndIf
    
    ; unload the viewer dll
    ;
    If LibraryPlugins()\DllNumber <> 0
      CloseLibrary(LibraryPlugins()\DllNumber)
    EndIf
    
  Next LibraryPlugins()
  
  ClearList(LibraryPlugins())
  
EndProcedure

; Get a pointer to a plugin structure matching the currently displayed lib (if any)
Procedure LibraryViewer_GetCurrentPlugin(*Debugger.DebuggerData)
  *Plugin = 0
  
  If *Debugger\CurrentLibrary <> -1
    *libinfo.Debugger_LibraryData = *Debugger\LibraryList + *Debugger\CurrentLibrary * SizeOf(Debugger_LibraryData)
    
    If *libinfo\FunctionMask & #LIBRARYINFO_Data ; Does the library even support this ?
      
      ForEach LibraryPlugins()
        If LibraryPlugins()\LibraryID$ = *libinfo\LibraryID$
          *Plugin = @LibraryPlugins()
          Break
        EndIf
      Next LibraryPlugins()
      
    EndIf
    
  EndIf
  
  ProcedureReturn *Plugin
EndProcedure

; Free any displayed object data. (Works also if nothing is to be freed)
Procedure LibraryViewer_FreeObject(*Debugger.DebuggerData)
  
  If *Debugger\CurrentObjectData
    
    *Plugin.LibraryViewerPLUGIN = LibraryViewer_GetCurrentPlugin(*Debugger)
    If *Plugin
      *Plugin\RemoveObject(*Debugger\CurrentObjectData)
    EndIf
    
    FreeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container])
    *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container] = 0
    *Debugger\CurrentObjectData = 0
  EndIf
  
EndProcedure


Procedure LibraryViewer_ClearDisplay(*Debugger.DebuggerData)
  
  ; Empty all the gadgets...
  ;
  ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList])
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], "")
  
  For i = *Debugger\NbLibColumns-1 To 0 Step -1
    RemoveGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], i)
  Next i
  *Debugger\NbLibColumns = 0
  
  If *Debugger\ObjectList
    FreeMemory(*Debugger\ObjectList)
    *Debugger\ObjectList = 0
  EndIf
  *Debugger\CurrentObject = -1
  *Debugger\CurrentObjectID = -1
  
  LibraryViewer_FreeObject(*Debugger)
EndProcedure

Procedure LibraryViewer_DisplayLibrary(*Debugger.DebuggerData, index)
  
  If *Debugger\LibraryList And index < *Debugger\NbLibraries
    
    *libinfo.Debugger_LibraryData = *Debugger\LibraryList + index * SizeOf(Debugger_LibraryData)
    
    Count = 0
    Title$ = StringField(*libinfo\TitleString$, 1, Chr(9))
    While Title$ <> ""
      Size = Val(StringField(*libinfo\TitleString$, Count*2+2, Chr(9)))
      AddGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], Count, Title$, Size)
      Count + 1
      Title$ = StringField(*libinfo\TitleString$, Count*2+1, Chr(9))
    Wend
    *Debugger\NbLibColumns = Count
    
    ; Send the command without data, so the "current displayed id" defaults to -1
    ; (as we are not updating an already displayed list)
    ;
    Command.CommandInfo\Command = #COMMAND_GetLibraryInfo
    Command\Value1 = index
    SendDebuggerCommand(*Debugger, @Command)
    
    *Debugger\CurrentLibrary = index
    *Debugger\CurrentObject = -1
    *Debugger\CurrentObjectID = -1
    
  EndIf
  
EndProcedure

Procedure LibraryViewer_DisplayObject(*Debugger.DebuggerData, index)
  If index <> -1 And *Debugger\ObjectList <> 0
    *idlist.Local_Array = *Debugger\ObjectList
    *libinfo.Debugger_LibraryData = *Debugger\LibraryList + *Debugger\CurrentLibrary * SizeOf(Debugger_LibraryData)
    
    *Debugger\CurrentObject = index
    If *Debugger\Is64bit
      *Debugger\CurrentObjectID = *idlist\q[index]
    Else
      *Debugger\CurrentObjectID = *idlist\l[index]
    EndIf
    
    SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], "")
    LibraryViewer_FreeObject(*Debugger)
    
    If *libinfo\FunctionMask & #LIBRARYINFO_Text
      Command.CommandInfo\Command = #COMMAND_GetObjectText
      Command\Value1 = *Debugger\CurrentLibrary
      
      If *Debugger\Is64bit
        Command\DataSize = 8
        SendDebuggerCommandWithData(*Debugger, @Command, @*idlist\q[index])
      Else
        Command\DataSize = 4
        SendDebuggerCommandWithData(*Debugger, @Command, @*idlist\l[index])
      EndIf
    EndIf
    
    If *libinfo\FunctionMask & #LIBRARYINFO_Data
      Command.CommandInfo\Command = #COMMAND_GetObjectData
      Command\Value1 = *Debugger\CurrentLibrary
      
      If *Debugger\Is64bit
        Command\DataSize = 8
        SendDebuggerCommandWithData(*Debugger, @Command, @*idlist\q[index])
      Else
        Command\DataSize = 4
        SendDebuggerCommandWithData(*Debugger, @Command, @*idlist\l[index])
      EndIf
    EndIf
    
  EndIf
EndProcedure

Procedure LibraryViewerEvents(*Debugger.DebuggerData, EventID)
  
  If EventID = #PB_Event_Gadget
    Select EventGadget()
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList]
        index = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList])
        If index <> *Debugger\CurrentLibrary
          LibraryViewer_ClearDisplay(*Debugger)
          
          If index <> -1
            LibraryViewer_DisplayLibrary(*Debugger, index)
          EndIf
          
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update]
        If *Debugger\CurrentLibrary <> -1
          Command.CommandInfo\Command = #COMMAND_GetLibraryInfo
          Command\Value1 = *Debugger\CurrentLibrary
          SendDebuggerCommand(*Debugger, @Command)
        EndIf
        
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList]
        index = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList])
        If index <> *Debugger\CurrentObject
          LibraryViewer_DisplayObject(*Debugger, index)
        EndIf
        
      Case *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1], *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2]
        If *Debugger\CurrentObjectData
          *Plugin.LibraryViewerPLUGIN = LibraryViewer_GetCurrentPlugin(*Debugger)
          If *Plugin And *Plugin\SetObjectSize ; optional function!
            Width  = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2])  - 4
            Height = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2]) - 4
            ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container], 0, 0, Width, Height)
            *Plugin\SetObjectSize(*Debugger\CurrentObjectData, Width, Height)
          EndIf
        EndIf
        
      Default
        If *Debugger\CurrentObjectData
          *Plugin.LibraryViewerPLUGIN = LibraryViewer_GetCurrentPlugin(*Debugger)
          If *Plugin And *Plugin\ProcessEvents ; optional function!
            *Plugin\ProcessEvents(*Debugger\CurrentObjectData, EventGadget(), EventType())
          EndIf
        EndIf
        
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    Width  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Library])
    Height = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
    
    GetRequiredSize(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update], @ButtonWidth, @ButtonHeight)
    ButtonWidth  = Max(ButtonWidth, 100)
    ButtonHeight = Max(ButtonHeight, GetRequiredHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList]))
    TextWidth    = Max(GetRequiredWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Text1]), 120)
    
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Text1], 10, 10, TextWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 20+TextWidth, 10, Width-40-TextWidth-ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update], Width-10-ButtonWidth, 10, ButtonWidth, ButtonHeight)
    ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1], 10, 15+ButtonHeight, Width-20, Height-25-ButtonHeight)
    
  ElseIf EventID = #PB_Event_CloseWindow
    
    If DebuggerMemorizeWindows And IsWindowMinimized(*Debugger\Windows[#DEBUGGER_WINDOW_Library]) = 0
      LibraryViewerMaximize = IsWindowMaximized(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
      If LibraryViewerMaximize = 0
        LibraryViewerX = WindowX(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
        LibraryViewerY = WindowY(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
        LibraryViewerWidth  = WindowWidth (*Debugger\Windows[#DEBUGGER_WINDOW_Library])
        LibraryViewerHeight = WindowHeight(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
        LibraryViewerSplitter1 = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1])
        LibraryViewerSplitter2 = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2])
      EndIf
    EndIf
    
    LibraryViewer_FreeObject(*Debugger)
    
    CloseWindow(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
    *Debugger\Windows[#DEBUGGER_WINDOW_Library] = 0
    
    If *Debugger\ObjectList ; the current displayed object list is freed
      FreeMemory(*Debugger\ObjectList)
      *Debugger\ObjectList = 0
    EndIf
    
    Debugger_CheckDestroy(*Debugger)
    
  EndIf
  
EndProcedure

Procedure UpdateLibraryViewerState(*Debugger.DebuggerData)
  
  ; Execution stopped... update the list...
  ;
  If *Debugger\ProgramState = 3 Or *Debugger\ProgramState = 7 Or *Debugger\ProgramState = 8 Or *Debugger\ProgramState = 9
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update], 1)
    
    ; Update the List:
    If *Debugger\CurrentLibrary <> -1
      Command.CommandInfo\Command = #COMMAND_GetLibraryInfo
      Command\Value1 = *Debugger\CurrentLibrary
      SendDebuggerCommand(*Debugger, @Command)
    EndIf
    
    ; Exe not loaded .. no access
    ;
  ElseIf *Debugger\ProgramState = -1
    ;LibraryViewer_ClearDisplay(*Debugger)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], 1)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update], 1)
    
    ; Other states.. access with 'update' button
    ;
  Else
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], 0)
    DisableGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update], 0)
    
  EndIf
  
  
EndProcedure

Procedure OpenLibraryViewerWindow(*Debugger.DebuggerData)
  
  ;ProcedureReturn ; disabled for this Alpha version
  
  ; Load the LibraryViewer plugin dlls
  ;
  LibraryViewer_Init()
  
  If *Debugger\Windows[#DEBUGGER_WINDOW_Library]
    SetWindowForeground(*Debugger\Windows[#DEBUGGER_WINDOW_Library])
    
  Else
    Window = OpenWindow(#PB_Any, LibraryViewerX, LibraryViewerY, LibraryViewerWidth, LibraryViewerHeight, Language("Debugger","LibraryViewerTitle") + " - " + DebuggerTitle(*Debugger\FileName$), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_MaximizeGadget)
    If Window
      *Debugger\Windows[#DEBUGGER_WINDOW_Library] = Window
      
      ; used to replace the ScrollArea when we are in dynamic resize mode.
      ;
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2] = ContainerGadget(#PB_Any, 0, 0, 0, 0, #PB_Container_Double)
      CloseGadgetList()
      HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2], 1)
      
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Text1]       = TextGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","SelectLibrary")+":", #PB_Text_Right)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList] = ComboBoxGadget(#PB_Any, 0, 0, 0, 0)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update]      = ButtonGadget(#PB_Any, 0, 0, 0, 0, Language("Debugger","Update"))
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList]  = ListIconGadget(#PB_Any, 0, 0, 0, 0, "", 20, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText]  = EditorGadget(#PB_Any, 0, 0, 0, 0)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData]  = ScrollAreaGadget(#PB_Any, 0, 0, 0, 0, 200, 200, 10); TODO: fix the center flag on linux and re-add this, #PB_ScrollArea_Center)
      CloseGadgetList()
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2]   = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData], #PB_Splitter_Vertical|#PB_Splitter_FirstFixed)
      *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1]   = SplitterGadget(#PB_Any, 0, 0, 0, 0, *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_FirstFixed)
      
      CompilerIf #CompileWindows
        Static MonoFont
      
        If MonoFont = 0
          MonoFont = LoadFont(#PB_Any, "Courier New", 10)
        EndIf
      
        If MonoFont
          ; it looks just much better this way
          SetGadgetFont(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], FontID(MonoFont))
        EndIf
      CompilerEndIf
      
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], #PB_Editor_ReadOnly, 1)
      RemoveGadgetColumn(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], 0)
      
      Debugger_AddShortcuts(Window)
      
      EnsureWindowOnDesktop(Window)
      If LibraryViewerMaximize
        ShowWindowMaximized(Window)
      Else
        HideWindow(Window, 0)
      EndIf
      
      LibraryViewerEvents(*Debugger, #PB_Event_SizeWindow)
      
      If LibraryViewerSplitter1 < 20
        LibraryViewerSplitter1 = 80
      EndIf
      If LibraryViewerSplitter2 < 20
        LibraryViewerSplitter2 = 80
      EndIf
      
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1], LibraryViewerSplitter1)
      SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], LibraryViewerSplitter2)
      
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1], #PB_Splitter_FirstMinimumSize, 20)
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_FirstMinimumSize, 20)
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter1], #PB_Splitter_SecondMinimumSize, 20)
      SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_SecondMinimumSize, 20)
      
      *Debugger\CurrentLibrary = -1
      *Debugger\CurrentObject = -1
      *Debugger\CurrentObjectID = -1
      
      UpdateLibraryViewerState(*Debugger)
      Debugger_ProcessEvents(Window, #PB_Event_ActivateWindow) ; makes all debugger windows go to the top
      
      If *Debugger\LibraryList ; The library list was already retrieved
        *libraries.Debugger_LibraryList = *Debugger\LibraryList
        For i = 0 To *Debugger\NbLibraries-1
          AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], -1, *libraries\library[i]\Name$)
        Next i
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 0)
        LibraryViewer_DisplayLibrary(*Debugger, 0) ; show the first lib
      Else
        AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], -1, Language("Debugger","NoLibraryInfo"))
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 0)
        
        Command.CommandInfo\Command = #COMMAND_GetLibraries
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      UpdateLibraryViewerState(*Debugger)
      
      CompilerIf #DEFAULT_CanWindowStayOnTop
        SetWindowStayOnTop(Window, DebuggerOnTop)
      CompilerEndIf
      
    EndIf
  EndIf
  
EndProcedure

Procedure UpdateLibraryViewer(*Debugger.DebuggerData)
  
  SetWindowTitle(*Debugger\Windows[#DEBUGGER_WINDOW_Library], Language("Debugger","LibraryViewerTitle") + " - " + GetFilePart(*Debugger\FileName$))
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Text1], Language("Debugger","SelectLibrary")+":")
  SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Update], Language("Debugger","Update"))
  
  LibraryViewerEvents(*Debugger, #PB_Event_SizeWindow) ; Update gadget sizes
  
EndProcedure

Procedure LibraryViewer_DebuggerEvent(*Debugger.DebuggerData)
  
  Select *Debugger\Command\Command
      
    Case #COMMAND_ControlLibraryViewer
      OpenLibraryViewerWindow(*Debugger)
      
      If *Debugger\Command\Value2 <> -1 ; library to select
        Library = *Debugger\Command\Value2
      Else
        Library = GetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList])
      EndIf
      
      ; select the library to display
      If Library <> *Debugger\CurrentLibrary ; change library
        SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], Library)
        LibraryViewer_ClearDisplay(*Debugger)
        If Library <> -1
          LibraryViewer_DisplayLibrary(*Debugger, Library)
        EndIf
      Else
        Command.CommandInfo\Command = #COMMAND_GetLibraryInfo
        Command\Value1 = *Debugger\CurrentLibrary
        SendDebuggerCommand(*Debugger, @Command)
      EndIf
      
      ; select the object to display
      If *Debugger\Command\Value1 = 2 And *Debugger\CommandData
        If *Debugger\Is64bit
          *Debugger\CurrentObjectID = PeekQ(*Debugger\CommandData)
        Else
          *Debugger\CurrentObjectID = PeekL(*Debugger\CommandData)
        EndIf
      Else
        *Debugger\CurrentObjectID = -1
      EndIf
      
      
    Case #COMMAND_Libraries
      
      ; Free any old library or object list
      ;
      If *Debugger\LibraryList
        *libraries.Debugger_LibraryList = *Debugger\LibraryList
        For i = 0 To *Debugger\NbLibraries - 1
          FreePBString(@*libraries\library[i]\LibraryID$)
          FreePBString(@*libraries\library[i]\Name$)
          FreePBString(@*libraries\library[i]\TitleString$)
        Next i
        FreeMemory(*Debugger\LibraryList)
        *Debugger\LibraryList = 0
      EndIf
      
      ; clear display and library list gadget
      ;
      If *Debugger\Windows[#DEBUGGER_WINDOW_Library]
        LibraryViewer_ClearDisplay(*Debugger)
        ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList])
        *Debugger\CurrentLibrary = -1
      EndIf
      
      ; Read the list of libraries
      ;
      *Debugger\NbLibraries = *Debugger\Command\Value1
      If *Debugger\NbLibraries > 0 And *Debugger\CommandData
        *libraries.Debugger_LibraryList = AllocateMemory(*Debugger\NbLibraries * SizeOf(Debugger_LibraryData))
        If *libraries
          *Pointer = *Debugger\CommandData
          For i = 0 To *Debugger\NbLibraries-1
            *libraries\library[i]\LibraryID$ = PeekAscii(*Pointer)
            *Pointer + MemoryAsciiLength(*Pointer) + 1
            *libraries\library[i]\Name$ = PeekAscii(*Pointer)
            *Pointer + MemoryAsciiLength(*Pointer) + 1
            *libraries\library[i]\TitleString$ = PeekAscii(*Pointer)
            *Pointer + MemoryAsciiLength(*Pointer) + 1
            *libraries\library[i]\FunctionMask = PeekL(*Pointer)
            *Pointer + 4
            
            If *Debugger\Windows[#DEBUGGER_WINDOW_Library]
              AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], -1, *libraries\library[i]\Name$)
            EndIf
          Next i
          
          *Debugger\LibraryList = *libraries
          
          If *Debugger\Windows[#DEBUGGER_WINDOW_Library]
            SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 0)
            LibraryViewer_DisplayLibrary(*Debugger, 0) ; show the first lib
          EndIf
        EndIf
        
        
        If *Debugger\Windows[#DEBUGGER_WINDOW_Library]
          UpdateLibraryViewerState(*Debugger)
        EndIf
        
      Else
        If *Debugger\Windows[#DEBUGGER_WINDOW_Library]
          AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], -1, Language("Debugger","NoLibraryInfo"))
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_LibraryList], 0)
        EndIf
      EndIf
      
    Case #COMMAND_LibraryInfo
      If *Debugger\Windows[#DEBUGGER_WINDOW_Library] And *Debugger\Command\Value1 = *Debugger\CurrentLibrary
        ClearGadgetItems(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList])
        SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], "")
        LibraryViewer_FreeObject(*Debugger)
        
        *Debugger\NbObjects = *Debugger\Command\Value2
        *Pointer = *Debugger\CommandData
        
        lastIDIndex = -1
        
        If *Debugger\NbObjects > 0
          If *Debugger\Is64bit
            *Debugger\ObjectList = AllocateMemory(*Debugger\NbObjects * SizeOf(QUAD))
          Else
            *Debugger\ObjectList = AllocateMemory(*Debugger\NbObjects * SizeOf(LONG))
          EndIf
          
          If *Debugger\ObjectList
            *id.Local_Array = *Debugger\ObjectList
            For i = 0 To *Debugger\NbObjects-1
              If *Debugger\Is64bit
                *id\q[i] = PeekQ(*Pointer)
                *Pointer + 8
                
                ; store the new index of the Object ID that was last displayed
                If *id\q[i] = *Debugger\CurrentObjectID And *Debugger\CurrentObjectID <> -1
                  lastIDIndex = i
                EndIf
              Else
                *id\l[i] = PeekL(*Pointer)
                *Pointer + 4
                
                ; store the new index of the Object ID that was last displayed
                If *id\l[i] = *Debugger\CurrentObjectID And *Debugger\CurrentObjectID <> -1
                  lastIDIndex = i
                EndIf
              EndIf
              
              String$ = PeekAscii(*Pointer)
              *Pointer + MemoryAsciiLength(*Pointer) + 1
              
              AddGadgetItem(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], -1, ReplaceString(String$, Chr(9), Chr(10)))
            Next i
          Else
            ; skip the object data, as there is no available memory
            For i = 0 To *Debugger\NbObjects-1
              If *Debugger\Is64bit
                *Pointer + 8 ; skip ID
              Else
                *Pointer + 4 ; skip ID
              EndIf
              *Pointer + MemoryAsciiLength(*Pointer) + 1 ; skip string
            Next i
            *Debugger\NbObjects = 0
          EndIf
        EndIf
        
        
        ; set the gadget to the last Object if we are updating the list and
        ; update the current object too
        ;
        *Debugger\CurrentObject = lastIDIndex
        If lastIDIndex = -1
          *Debugger\CurrentObjectID = -1
        Else
          SetGadgetState(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList], lastIDIndex)
          CompilerIf #CompileWindows
            SendMessage_(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectList]), #LVM_ENSUREVISIBLE, lastIDIndex, 0)
          CompilerEndIf
          
          LibraryViewer_DisplayObject(*Debugger, lastIDIndex)
        EndIf
      EndIf
      
      ; This is sent before #COMMAND_ObjectTExt/#COMMAND_ObjectData to tell the corresponding ID
      ; (its separate, so we can send the full object data in one command without adding the id to the buffer)
      ;
    Case #COMMAND_ObjectID
      If *Debugger\Is64bit
        *Debugger\CommandObjectID = PeekQ(@*Debugger\Command\Value1)
      Else
        *Debugger\CommandObjectID = PeekL(@*Debugger\Command\Value1)
      EndIf
      
      
    Case #COMMAND_ObjectText
      If *Debugger\Windows[#DEBUGGER_WINDOW_Library] And *Debugger\CommandObjectID = *Debugger\CurrentObjectID
        If *Debugger\Command\DataSize > 1
          StartGadgetFlickerFix(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText])
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], PeekAscii(*Debugger\CommandData))
          ;Editor_StreamIn(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], *Debugger\CommandData, *Debugger\Command\DataSize-1)
          StopGadgetFlickerFix(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText])
        Else
          SetGadgetText(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectText], "")
        EndIf
      EndIf
      
      
    Case #COMMAND_ObjectData
      ;
      ; Do NOT use LibraryViewer_FreeObject() here, as we destroy the old object
      ; after showing the new to reduce flickering
      ;
      If *Debugger\Windows[#DEBUGGER_WINDOW_Library] And *Debugger\CommandObjectID = *Debugger\CurrentObjectID
        
        OldObjectData = *Debugger\CurrentObjectData
        OldContainer  = *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container]
        
        *Debugger\CurrentObjectData = 0
        *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container] = 0
        
        ;      StartGadgetFlickerFix(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData])
        
        If *Debugger\Command\DataSize > 0 And *Debugger\CommandData
          *Plugin.LibraryViewerPLUGIN = LibraryViewer_GetCurrentPlugin(*Debugger)
          If *Plugin
            
            ; open the right parent gadget
            If *Plugin\SetObjectSize
              OpenGadgetList(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2])
            Else
              OpenGadgetList(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData])
            EndIf
            
            *Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container] = ContainerGadget(#PB_Any, 0, 0, 0, 0)
            *Debugger\CurrentObjectData = *Plugin\DisplayObject(GadgetID(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container]), *Debugger\CommandData, *Debugger\Command\DataSize)
            CloseGadgetList()
            CloseGadgetList()
            
            If *Debugger\CurrentObjectData
              
              If *Plugin\SetObjectSize
                ; do the splitter-reparent if needed now.
                ; must be before we measure the width/height!
                ;
                If GadgetType(GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_SecondGadget)) <> #PB_GadgetType_Container
                  HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2], 0)
                  SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_SecondGadget, *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2])
                  HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData], 1)
                EndIf
                
                Width  = GadgetWidth(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2])   - 4
                Height = GadgetHeight(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2]) - 4
                ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container], 0, 0, Width, Height)
                
                ; no longer needed since 4.60
                ;                 CompilerIf #CompileLinux
                ;                   Width - 4; due to the Gtk borders
                ;                   Height - 4
                ;                 CompilerEndIf
                
                *Plugin\SetObjectSize(*Debugger\CurrentObjectData, Width, Height)
              Else
                
                ; do the splitter-reparent if needed now.
                ;
                If GadgetType(GetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_SecondGadget)) <> #PB_GadgetType_ScrollArea
                  HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData], 0)
                  SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Splitter2], #PB_Splitter_SecondGadget, *Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData])
                  HideGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData2], 1)
                EndIf
                
                Width  = *Plugin\GetObjectWidth(*Debugger\CurrentObjectData)
                Height = *Plugin\GetObjectHeight(*Debugger\CurrentObjectData)
                
                ; no longer needed since 4.60
                ;                 CompilerIf #CompileLinux
                ;                   Width + 4; due to the Gtk borders
                ;                   Height + 4
                ;                 CompilerEndIf
                
                ResizeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container], 0, 0, Width, Height)
                SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData], #PB_ScrollArea_InnerWidth, Width)
                SetGadgetAttribute(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData], #PB_ScrollArea_InnerHeight, Height)
              EndIf
              
            Else
              FreeGadget(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_Container])
            EndIf
            
          EndIf
        EndIf
        
        
        If OldObjectData ; now free the old Object
          
          *Plugin.LibraryViewerPLUGIN = LibraryViewer_GetCurrentPlugin(*Debugger)
          If *Plugin
            *Plugin\RemoveObject(OldObjectData)
          EndIf
          
          FreeGadget(OldContainer)
        EndIf
        
      EndIf
      
      ;      StopGadgetFlickerFix(*Debugger\Gadgets[#DEBUGGER_GADGET_Library_ObjectData])
      
  EndSelect
  
  
EndProcedure


