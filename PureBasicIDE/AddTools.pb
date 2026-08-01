; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Global IsNewTool

Procedure AddTools_AddMenuEntries()
  
  ; do y count of the menu items to add:
  count = 0
  ForEach ToolsList()
    If ToolsList()\DeactivateTool = 0
      If (ToolsList()\Shortcut <> 0 And ToolsList()\Shortcut <> -1) Or ToolsList()\HideFromMenu = 0
        count + 1
      EndIf
    EndIf
  Next ToolsList()
  
  If count > 0
    MenuBar()
    
    ForEach ToolsList()
      
      If ToolsList()\DeactivateTool = 0
        If ToolsList()\Shortcut <> 0 And ToolsList()\Shortcut <> -1
          AddKeyboardShortcut(#WINDOW_Main, ToolsList()\Shortcut, #MENU_AddTools_Start+ListIndex(ToolsList()))
          If ToolsList()\HideFromMenu = 0
            MenuItem(#MENU_AddTools_Start+ListIndex(ToolsList()), ToolsList()\MenuItemName$+Chr(9)+GetShortcutText(ToolsList()\Shortcut))
          EndIf
        Else
          If ToolsList()\HideFromMenu = 0
            MenuItem(#MENU_AddTools_Start+ListIndex(ToolsList()), ToolsList()\MenuItemName$)
          EndIf
        EndIf
      EndIf
      
    Next ToolsList()
    
  EndIf
  
EndProcedure


; set up environment variables for the tools
Procedure AddTools_SetEnvVar(List EnvVars.s(), Name$, Value$)
  AddElement(EnvVars()) ; store the names for later deletion
  EnvVars() = "PB_TOOL_" + Name$
  SetEnvironmentVariable("PB_TOOL_"+Name$, Value$)
EndProcedure

Procedure AddTools_ExecuteCurrent(Trigger, *Target.CompileTarget)
  
  ; If it is not a project target, the *Target is extended by the SourceFile struct
  If CommandlineBuild = 0 And *Target And *Target\IsProject = 0 And *Target <> *ProjectInfo
    *Source.SourceFile = *Target
  Else
    *Source = 0
  EndIf
  
  If Trim(ToolsList()\CommandLine$) <> ""
    
    ; for source specific tools we must check if the given source allows this tool
    ;
    If ToolsList()\SourceSpecific
      ; check if the tool is enabled
      ; the list is in uppercase, no spaces (spaces inside names replaced by '_')
      ; separated by comma
      ;
      If *Target = 0
        ; no target given (editor start etc)
        ProcedureReturn
        
      ElseIf FindString(","+*Target\EnabledTools$+",", ","+ReplaceString(UCase(Trim(ToolsList()\MenuItemName$)), " ", "_")+",", 1) = 0
        ; tool not enabled
        ProcedureReturn
      EndIf
    EndIf
    
    ToolArguments$ = ToolsList()\Arguments$
    If ToolArguments$ = ""
      If Trigger = #TRIGGER_FileViewer_All Or Trigger = #TRIGGER_FileViewer_Unknown Or Trigger = #TRIGGER_FileViewer_Special
        ToolArguments$ = Chr(34)+AddTools_File$+Chr(34)
      ElseIf Trigger = #TRIGGER_OpenFile_nonPB_Binary Or Trigger = #TRIGGER_OpenFile_nonPB_Text Or Trigger = #TRIGGER_OpenFile_Special
        ToolArguments$ = Chr(34)+AddTools_File$+Chr(34)
      EndIf
      
    Else
      
      Test$      = UCase(ToolsList()\Arguments$)
      File$      = ""
      
      If FindString(Test$, "%FILE", 1)
        If Trigger = #TRIGGER_FileViewer_All Or Trigger = #TRIGGER_FileViewer_Unknown Or Trigger = #TRIGGER_FileViewer_Special
          ToolArguments$ = ReplaceString(ToolArguments$, "%FILE", AddTools_File$, 1)
        ElseIf Trigger = #TRIGGER_OpenFile_nonPB_Binary Or Trigger = #TRIGGER_OpenFile_nonPB_Text Or Trigger = #TRIGGER_OpenFile_Special
          ToolArguments$ = ReplaceString(ToolArguments$, "%FILE", AddTools_File$, 1)
          
        ElseIf *Target = 0 Or *Target = *ProjectInfo Or *Target\FileName$ = ""
          ToolArguments$ = ReplaceString(ToolArguments$, "%FILE", "", 1)
          
          ; do not extra save the source in these cases!
        ElseIf Trigger = #TRIGGER_SourceSave Or Trigger = #TRIGGER_SourceLoad Or Trigger = #TRIGGER_SourceClose ; no current source, or not saved. for SaveSource, we cannot save again as it will be an endless loop!
          ToolArguments$ = ReplaceString(ToolArguments$, "%FILE", *Target\FileName$, 1)
          
        ElseIf CommandlineBuild = 0 And *Target = *ActiveSource
          File$ = *Target\FileName$
          
          *CurrentElement = ToolsList()
          SaveSourceFile(File$) ; This can trigger other tool so we need to preserve our element
          HistoryEvent(*ActiveSource, #HISTORY_Save)
          ChangeCurrentElement(ToolsList(), *CurrentElement)
          
          ToolArguments$ = ReplaceString(ToolArguments$, "%FILE", File$, 1)
          
        Else ; not the active source (maybe compile target, so do not save to temp file)
          ToolArguments$ = ReplaceString(ToolArguments$, "%FILE", *Target\FileName$, 1)
          
        EndIf
      EndIf
      
      If FindString(Test$, "%TEMPFILE", 1)
        If Trigger = #TRIGGER_FileViewer_All Or Trigger = #TRIGGER_FileViewer_Unknown Or Trigger = #TRIGGER_FileViewer_Special
          ToolArguments$ = ReplaceString(ToolArguments$, "%TEMPFILE", "", 1)
        ElseIf Trigger = #TRIGGER_OpenFile_nonPB_Binary Or Trigger = #TRIGGER_OpenFile_nonPB_Text Or Trigger = #TRIGGER_OpenFile_Special
          ToolArguments$ = ReplaceString(ToolArguments$, "%TEMPFILE", "", 1)
          
        ElseIf *Source = 0 Or *Source <> *ActiveSource ; no current source (ide start/end)
          ToolArguments$ = ReplaceString(ToolArguments$, "%TEMPFILE", "", 1)
          
        Else
          File$ = TempPath$ + "TempFile" + #SourceFileExtension ; fallback
          For i = 0 To 10000
            If FileSize(TempPath$ + #ProductName$+"_TempFile"+Str(i) + #SourceFileExtension) = -1
              File$ = TempPath$ + #ProductName$+"_TempFile"+Str(i) + #SourceFileExtension
              Break
            EndIf
          Next i
          
          If SaveTempFile(File$)
            RegisterDeleteFile(File$) ; register for deletion at IDE end
            ToolArguments$ = ReplaceString(ToolArguments$, "%TEMPFILE", File$, 1)
          Else
            ToolArguments$ = ReplaceString(ToolArguments$, "%TEMPFILE", "", 1)
          EndIf
        EndIf
      EndIf
      
      If FindString(Test$, "%COMPILEFILE", 1)
        If Trigger = #TRIGGER_BeforeCompile Or Trigger = #TRIGGER_AfterCompile Or Trigger = #TRIGGER_BeforeCreateExe Or Trigger = #TRIGGER_AfterCreateExe
          ToolArguments$ = ReplaceString(ToolArguments$, "%COMPILEFILE", AddTools_CompiledFile$, 1)
        Else
          ToolArguments$ = ReplaceString(ToolArguments$, "%COMPILEFILE", "", 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%EXECUTABLE", 1)
        If Trigger = #TRIGGER_AfterCompile Or Trigger = #TRIGGER_AfterCreateExe Or Trigger = #TRIGGER_ProgramRun
          ToolArguments$ = ReplaceString(ToolArguments$, "%EXECUTABLE", AddTools_ExecutableName$, 1)
        ElseIf *Target = 0
          ToolArguments$ = ReplaceString(ToolArguments$, "%EXECUTABLE", "", 1)
        Else ; return the last created executable name for all other triggers
          ToolArguments$ = ReplaceString(ToolArguments$, "%EXECUTABLE", *Target\ExecutableName$, 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%PATH", 1)
        If Trigger = #TRIGGER_FileViewer_All Or Trigger = #TRIGGER_FileViewer_Unknown Or Trigger = #TRIGGER_FileViewer_Special
          ToolArguments$ = ReplaceString(ToolArguments$, "%PATH", GetPathPart(AddTools_File$), 1)
        ElseIf Trigger = #TRIGGER_OpenFile_nonPB_Binary Or Trigger = #TRIGGER_OpenFile_nonPB_Text Or Trigger = #TRIGGER_OpenFile_Special
          ToolArguments$ = ReplaceString(ToolArguments$, "%PATH", GetPathPart(AddTools_File$), 1)
          
        ElseIf *Target = 0 Or *Target\FileName$ = ""
          ToolArguments$ = ReplaceString(ToolArguments$, "%PATH", "", 1)
        Else
          ToolArguments$ = ReplaceString(ToolArguments$, "%PATH", GetPathPart(*Target\FileName$), 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%CURSOR", 1)
        If *Source = 0
          ToolArguments$ = ReplaceString(ToolArguments$, "%CURSOR", "", 1)
        Else
          UpdateCursorPosition()
          ToolArguments$ = ReplaceString(ToolArguments$, "%CURSOR", Str(*Source\CurrentLine)+"x"+Str(*Source\CurrentColumnChars), 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%SELECTION", 1)
        If *Source = 0
          ToolArguments$ = ReplaceString(ToolArguments$, "%SELECTION", "", 1)
        Else
          GetSelection(@LineStart, @RowStart, @LineEnd, @RowEnd)
          ToolArguments$ = ReplaceString(ToolArguments$, "%SELECTION", Str(LineStart)+"x"+Str(RowStart)+"x"+Str(LineEnd)+"x"+Str(RowEnd), 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%WORD", 1)
        If *Source = 0
          ToolArguments$ = ReplaceString(ToolArguments$, "%WORD", "", 1)
        Else
          ToolArguments$ = ReplaceString(ToolArguments$, "%WORD", GetCurrentWord(), 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%PROJECT", 1)
        If IsProject
          ToolArguments$ = ReplaceString(ToolArguments$, "%PROJECT", GetPathPart(ProjectFile$), 1)
        Else
          ToolArguments$ = ReplaceString(ToolArguments$, "%PROJECT", "", 1)
        EndIf
      EndIf
      
      If FindString(Test$, "%HOME", 1)
        ToolArguments$ = ReplaceString(ToolArguments$, "%HOME", PureBasicPath$, 1)
      EndIf
      
    EndIf
    
    ; Display the run tool in the BuildLog (the function has a check to know if the buildlog is present)
    ;
    If Trigger = #TRIGGER_BeforeCreateExe Or Trigger = #TRIGGER_AfterCreateExe
      If CommandlineBuild = 0
        BuildLogEntry(Language("Compiler","BuildRunTool")+": "+ToolsList()\CommandLine$ + " " + ToolArguments$)
      ElseIf QuietBuild = 0
        PrintN(Language("Compiler","BuildRunTool")+": "+ToolsList()\CommandLine$ + " " + ToolArguments$)
      EndIf
    EndIf
    
    ; set up some information for the tool in Env variables
    ;
    Protected NewList EnvVars.s()
    
    AddTools_SetEnvVar(EnvVars(), "IDE", ProgramFilename())
    
    Protected *TargetCompiler.Compiler
    If *Target And *Target\CustomCompiler
      *TargetCompiler = FindCompiler(*Target\CompilerVersion$)
      If *TargetCompiler = 0
        *TargetCompiler = @DefaultCompiler
      EndIf
    Else
      *TargetCompiler = @DefaultCompiler
    EndIf
    AddTools_SetEnvVar(EnvVars(), "Compiler", *TargetCompiler\Executable$)
    
    AddTools_SetEnvVar(EnvVars(), "Preferences", PreferencesFile$)
    AddTools_SetEnvVar(EnvVars(), "MainWindow", Str(WindowID(#WINDOW_Main)))
    
    If IsProject
      AddTools_SetEnvVar(EnvVars(), "Project", ProjectFile$)
    EndIf
    
    If *Target And *Target <> *ProjectInfo
      AddTools_SetEnvVar(EnvVars(), "InlineASM", Str(*Target\EnableASM))
      AddTools_SetEnvVar(EnvVars(), "Unicode", "1") ; for compatibility with old tools
      AddTools_SetEnvVar(EnvVars(), "Thread", Str(*Target\EnableThread))
      CompilerIf #CompileWindows
        AddTools_SetEnvVar(EnvVars(), "XPSkin", Str(*Target\EnableXP))
        AddTools_SetEnvVar(EnvVars(), "OnError", Str(*Target\EnableOnError))
      CompilerElseIf #CompileLinux
        AddTools_SetEnvVar(EnvVars(), "Wayland", Str(*Target\EnableWayland))
      CompilerEndIf
      AddTools_SetEnvVar(EnvVars(), "Debugger", Str(*Target\Debugger))
      AddTools_SetEnvVar(EnvVars(), "SubSystem", *Target\SubSystem$)
      
      If Trigger = #TRIGGER_AfterCompile Or Trigger = #TRIGGER_ProgramRun
        AddTools_SetEnvVar(EnvVars(), "Executable", AddTools_ExecutableName$)
      Else ; return the last created executable name for all other triggers
        AddTools_SetEnvVar(EnvVars(), "Executable", *Target\ExecutableName$)
      EndIf
      
    EndIf
    
    If *Source
      AddTools_SetEnvVar(EnvVars(), "Scintilla", Str(GadgetID(*Source\EditorGadget)))
      
      UpdateCursorPosition()
      GetSelection(@LineStart, @RowStart, @LineEnd, @RowEnd)
      
      AddTools_SetEnvVar(EnvVars(), "Cursor", Str(*Source\CurrentLine)+"x"+Str(*Source\CurrentColumnChars))
      AddTools_SetEnvVar(EnvVars(), "Selection", Str(LineStart)+"x"+Str(RowStart)+"x"+Str(LineEnd)+"x"+Str(RowEnd))
      AddTools_SetEnvVar(EnvVars(), "Word", GetCurrentWord())
    EndIf
    
    AddTools_SetEnvVar(EnvVars(), "Language", CurrentLanguage$)
    
    FileList$ = ""
    current = ListIndex(FileList()) ; does not need to be *ActiveSource!
    ForEach FileList()
      If @FileList() <> *ProjectInfo
        If FileList()\FileName$ <> ""
          FileList$ + FileList()\FileName$ + Chr(10)
        EndIf
      EndIf
    Next FileList()
    SelectElement(FileList(), current)
    
    If Right(FileList$, 1) = Chr(10)
      FileList$ = Left(FileList$, Len(FileList$)-1)
    EndIf
    AddTools_SetEnvVar(EnvVars(), "FileList", FileList$)
    
    
    
    If Trim(ToolsList()\WorkingDir$) = "" ; no working dir set, lets use the current source path
      If *Target = 0
        ToolWorkingDir$ = ""
      Else
        ToolWorkingDir$ = GetPathPart(*Target\FileName$)
      EndIf
    Else
      ToolWorkingDir$ = ToolsList()\WorkingDir$
    EndIf
    
    If ToolsList()\Flags & 2 ; run hidden
      Flags = #PB_Program_Hide
    Else
      Flags = 0
    EndIf
    
    CommandLine$ = ToolsList()\CommandLine$

    ; We can't launch a .app directory directly on OS X, we need to launch the executable in
    ; /Contents/MacOS/ProgramName https://www.purebasic.fr/english/viewtopic.php?f=24&t=59274
    ;
    CompilerIf #CompileMac
      If GetExtensionPart(CommandLine$) = "app"
        Filename$ = GetFilePart(CommandLine$)
        CommandLine$ = CommandLine$ + "/Contents/MacOS/" + Left(Filename$, Len(Filename$)-4)
      EndIf
    CompilerEndIf
      
    If ToolsList()\Flags & 1  ; wait until tool quits
      Flags | #PB_Program_Open; no wait flag, as we do this with ProgramRunning()
      
      If CommandlineBuild = 0
        If ToolsList()\HideEditor
          IsMaximized = IsWindowMaximized(#WINDOW_Main)
          HideWindow(#WINDOW_Main, 1)
        Else
          DisableWindow(#WINDOW_Main, 1)
        EndIf
      EndIf
      
      Program = RunProgram(CommandLine$, ToolArguments$, ToolWorkingDir$, Flags)
      
      If Program
        If CommandlineBuild = 0
          While WaitProgram(Program, 10) = 0
            FlushEvents()
          Wend
        Else
          WaitProgram(Program)
        EndIf
        
        CloseProgram(Program)
      EndIf
      
      If CommandlineBuild = 0
        If ToolsList()\HideEditor
          If IsMaximized
            ShowWindowMaximized(#WINDOW_Main)
          Else
            HideWindow(#WINDOW_Main, 0)
          EndIf
        Else
          DisableWindow(#WINDOW_Main, 0)
        EndIf
      EndIf
      
      If File$ <> ""
        If CommandlineBuild = 0 And ToolsList()\ReloadSource <> 0
          If ToolsList()\ReloadSource = 1
            NewSource("", #False)
          EndIf
          
          LoadTempFile(File$)
          UpdateSourceStatus(1)
          HistoryEvent(*ActiveSource, #HISTORY_Create)
          
          ; update file monitor stats, so there won't be a " do you want to load changes from disk" message
          If *ActiveSource And IsEqualFile(File$, *ActiveSource\FileName$)
            *ActiveSource\ExistsOnDisk  = #True
            *ActiveSource\LastWriteDate = GetFileDate(File$, #PB_Date_Modified)
            *ActiveSource\DiskFileSize  = FileSize(File$)
            *ActiveSource\DiskChecksum  = FileFingerprint(File$, #PB_Cipher_MD5)
          EndIf
          
        EndIf
        
        If IsTempFile = 1
          DeleteFile(File$)
        EndIf
      EndIf
      
    Else
      
      RunProgram(CommandLine$, ToolArguments$, ToolWorkingDir$, Flags)
      
    EndIf
    
    ; clear all the set up environment variables
    ForEach EnvVars()
      RemoveEnvironmentVariable(EnvVars())
    Next EnvVars()
    
    If CommandlineBuild = 0
      CompilerIf #CompileWindows
        ; Note: The DisableWindow() command sents the IDE to the background, because the
        ; foreground app (the tool) ends while the IDE is still disabled, so it does not
        ; get the focus anymore. There is no other way around than to grab the focus
        ; back afterwards.
        ;
        SetWindowForeground_Real(#WINDOW_Main)
      CompilerEndIf
      
      SetWindowForeground(#WINDOW_Main)
      If *Source
        SetActiveGadget(*Source\EditorGadget)
      EndIf
    EndIf
    
  EndIf
  
EndProcedure


Procedure AddTools_Execute(Trigger, *Target.CompileTarget)
  
  If Trigger = #TRIGGER_Menu
    
    ; select the menuitem and execute it
    ;
    MenuID = *Target
    If MenuID >= #MENU_AddTools_Start And MenuID - #MENU_AddTools_Start < ListSize(ToolsList())
      SelectElement(ToolsList(), MenuID - #MENU_AddTools_Start)
      If ToolsList()\DeactivateTool = 0
        AddTools_ExecuteCurrent(#TRIGGER_Menu, *ActiveSource)
      EndIf
    EndIf
    
  ElseIf Trigger = #TRIGGER_FileViewer_Special Or Trigger = #TRIGGER_OpenFile_Special
    
    ; check if there is a tool that supports the filetype
    ;
    ext$ = LCase(GetExtensionPart(AddTools_File$))
    
    ForEach ToolsList()
      If ToolsList()\Trigger = Trigger And ToolsList()\DeactivateTool = 0
        
        i = 1
        While StringField(ToolsList()\ConfigLine$, i, ",") <> ""
          If Trim(LCase(StringField(ToolsList()\ConfigLine$, i, ","))) = ext$
            AddTools_ExecuteCurrent(Trigger, *Target)
            AddTools_RunFileViewer = 0 ; indicate that a tool has been executed
            Break                      ; only run one tool per file!
          EndIf
          i + 1
        Wend
        
      EndIf
    Next ToolsList()
    
  Else
    
    ; find all tools that have the current Trigger set and execute them
    ;
    ForEach ToolsList()
      If ToolsList()\Trigger = Trigger And ToolsList()\DeactivateTool = 0
        AddTools_ExecuteCurrent(Trigger, *Target)
        
        If Trigger = #TRIGGER_FileViewer_All Or Trigger = #TRIGGER_FileViewer_Unknown Or Trigger = #TRIGGER_OpenFile_nonPB_Binary Or Trigger = #TRIGGER_OpenFile_nonPB_Text
          AddTools_RunFileViewer = 0 ; indicate that a tool has been executed
          Break                      ; do not run more than one tool!
        EndIf
      EndIf
    Next ToolsList()
    
  EndIf
  
EndProcedure



Procedure AddTools_Init()
  
  AddTools_PatternStrings$ = ""
  
  OpenPreferences(AddToolsFile$)
  
  ClearList(ToolsList())
  
  PreferenceGroup("ToolsInfo")
  Count = ReadPreferenceLong("ToolCount", 0)
  
  For i = 0 To Count-1
    AddElement(ToolsList())
    PreferenceGroup("Tool_"+Str(i))
    
    ToolsList()\CommandLine$  = ReadPreferenceString("Command",      "")
    ToolsList()\Arguments$    = ReadPreferenceString("Arguments",    "")
    ToolsList()\WorkingDir$   = ReadPreferenceString("WorkingDir",   "")
    ToolsList()\MenuItemName$ = ReadPreferenceString("MenuItemName", "")
    ToolsList()\Shortcut      = ReadPreferenceLong  ("Shortcut",      0)
    ToolsList()\ConfigLine$   = ReadPreferenceString("ConfigLine",   "")
    ToolsList()\Trigger       = ReadPreferenceLong  ("Trigger",       0)
    ToolsList()\Flags         = ReadPreferenceLong  ("Flags",         0)
    ToolsList()\ReloadSource  = ReadPreferenceLong  ("ReloadSource",  0)
    ToolsList()\HideEditor    = ReadPreferenceLong  ("HideEditor",    0)
    ToolsList()\HideFromMenu  = ReadPreferenceLong  ("HideFromMenu",  0)
    ToolsList()\SourceSpecific= ReadPreferenceLong  ("SourceSpecific",0)
    ToolsList()\DeactivateTool= ReadPreferenceLong  ("Deactivate",    0)
    
    If ToolsList()\Trigger = #TRIGGER_FileViewer_Special Or ToolsList()\Trigger = #TRIGGER_OpenFile_Special
      Pattern$ = RemoveString(ToolsList()\ConfigLine$, " ")
      If Right(Pattern$, 1) = ","
        Pattern$ = Left(Pattern$, Len(Pattern$)-1)
      EndIf
      AddTools_PatternStrings$ +ToolsList()\MenuItemName$ + " (*."+ReplaceString(Pattern$, ",", ",*.") + ")|*."+ReplaceString(Pattern$, ",", ";*.") + "|"
    EndIf
  Next i
  
  ClosePreferences()
  
EndProcedure


Procedure AddTools_UpdateListItem(index)
  
  SelectElement(ToolsList_Edit(), index)
  SetGadgetItemText(#GADGET_AddTools_List, index, ToolsList_Edit()\MenuItemName$, 0)
  
  If ToolsList_Edit()\Trigger = 0 And ToolsList_Edit()\Shortcut <> 0 And ToolsList_Edit()\Shortcut <> -1
    SetGadgetItemText(#GADGET_AddTools_List, index, GetShortcutText(ToolsList_Edit()\Shortcut), 1)
  Else
    SetGadgetItemText(#GADGET_AddTools_List, index, Language("AddTools","Trigger"+Str(ToolsList_Edit()\Trigger)), 1)
  EndIf
  
  SetGadgetItemText(#GADGET_AddTools_List, index, ToolsList_Edit()\CommandLine$, 2)
  
EndProcedure


Procedure AddTools_SwitchElements(FirstElement, SecondElement)
  
  SelectElement(ToolsList_Edit(), FirstElement)
  *FirstElement.ToolsData = @ToolsList_Edit()
  FirstState = GetGadgetItemState(#GADGET_AddTools_List, FirstElement)
  
  SelectElement(ToolsList_Edit(), SecondElement)
  SecondState = GetGadgetItemState(#GADGET_AddTools_List, SecondElement)
  
  SwapElements(ToolsList_Edit(), *FirstElement, @ToolsList_Edit())
  
  AddTools_UpdateListItem(FirstElement)
  AddTools_UpdateListItem(SecondElement)
  
  ; update the ckeck marks
  SetGadgetItemState(#GADGET_AddTools_List, FirstElement, SecondState)
  SetGadgetItemState(#GADGET_AddTools_List, SecondElement, FirstState)
  
  
EndProcedure

Procedure AddTools_DisableAndStateGadget(GadgetID, DisableState)
  If DisableState = 1
    SetGadgetState(GadgetID, 0) ; only change the state when disabling the gadgets. otherwise some can never be unchecked!
  EndIf
  DisableGadget (GadgetID, DisableState)
EndProcedure


Procedure AddTools_UpdateDisabledState()
  
  Trigger    = GetGadgetState(#GADGET_EditTools_Trigger)
  Arguments$ = GetGadgetText(#GADGET_EditTools_Arguments)
  
  If Trigger <> #TRIGGER_Menu
    ;     DisableShortcutControl = 1
    ;     DisableShortcutAlt = 1
    ;     DisableShortcutShift = 1
    ;     DisableShortcutCommand = 1
    ;     DisableShortcutKey = 1
    DisableShortcut = 1
  EndIf
  
  If Trigger = #TRIGGER_BeforeCompile Or Trigger = #TRIGGER_AfterCompile Or Trigger = #TRIGGER_ProgramRun Or Trigger = #TRIGGER_BeforeCreateExe Or Trigger = #TRIGGER_AfterCreateExe Or Trigger = #TRIGGER_SourceLoad Or Trigger = #TRIGGER_SourceSave Or Trigger = #TRIGGER_SourceClose
    DisableSourceSpecific = 0
  Else
    DisableSourceSpecific = 1
  EndIf
  
  If GetGadgetState(#GADGET_EditTools_WaitForQuit) = 0
    DisableHideEditor = 1
    DisableReload     = 1
  Else
    If Trigger = #TRIGGER_EditorStart Or Trigger = #TRIGGER_EditorEnd Or Trigger = #TRIGGER_BeforeCompile Or Trigger = #TRIGGER_AfterCompile
      DisableReload = 1
      
    ElseIf FindString(Arguments$, "%TEMPFILE", 1) = 0 And FindString(Arguments$, "%FILE", 1) = 0
      DisableReload = 1
      
    EndIf
    
  EndIf
  
  If Trigger = #TRIGGER_FileViewer_All Or Trigger = #TRIGGER_FileViewer_Unknown Or Trigger = #TRIGGER_OpenFile_nonPB_Binary Or Trigger = #TRIGGER_OpenFile_nonPB_Text
    DisableConfigLine = 1
    DisableReload = 1
    
  ElseIf Trigger = #TRIGGER_FileViewer_Special Or Trigger = #TRIGGER_OpenFile_Special
    DisableReload = 1
  Else
    DisableConfigLine = 1
  EndIf
  
  If DisableReload Or GetGadgetState(#GADGET_EditTools_Reload) = 0
    DisableReloadNew = 1
    DisableReloadOld = 1
  EndIf
  
  CompilerIf #CompileMac = 0
    DisableShortcutCommand = 1
  CompilerEndIf
  
  ; Update all disable states at once
  ;
  ;   AddTools_DisableAndStateGadget(#GADGET_EditTools_ShortcutControl, DisableShortcutControl)
  ;   AddTools_DisableAndStateGadget(#GADGET_EditTools_ShortcutAlt,     DisableShortcutAlt)
  ;   AddTools_DisableAndStateGadget(#GADGET_EditTools_ShortcutShift,   DisableShortcutShift)
  ;   AddTools_DisableAndStateGadget(#GADGET_EditTools_ShortcutCommand, DisableShortcutCommand)
  ;   AddTools_DisableAndStateGadget(#GADGET_EditTools_ShortcutKey,     DisableShortcutKey)
  AddTools_DisableAndStateGadget(#GADGET_EditTools_Shortcut,   DisableShortcut)
  AddTools_DisableAndStateGadget(#GADGET_EditTools_HideEditor, DisableHideEditor)
  AddTools_DisableAndStateGadget(#GADGET_EditTools_Reload, DisableReload)
  AddTools_DisableAndStateGadget(#GADGET_EditTools_SourceSpecific, DisableSourceSpecific)
  
  DisableGadget(#GADGET_EditTools_ReloadNew , DisableReloadNew)
  DisableGadget(#GADGET_EditTools_ReloadOld , DisableReloadOld)
  DisableGadget(#GADGET_EditTools_ConfigLine, DisableConfigLine)
  
EndProcedure


Procedure AddTools_OpenEditWindow()
  
  ; this window can't be already open, because the open buttons are disabled when it is, so no check here
  ;
  EditToolsWindowDialog = OpenDialog(?Dialog_EditTools, WindowID(#WINDOW_AddTools), @EditToolsWindowPosition)
  If EditToolsWindowDialog
    EnsureWindowOnDesktop(#WINDOW_EditTools)
    
    EnableGadgetDrop(#GADGET_EditTools_CommandLine, #PB_Drop_Files, #PB_Drag_Copy)
    EnableGadgetDrop(#GADGET_EditTools_WorkingDir,  #PB_Drop_Files, #PB_Drag_Copy)
    
    ; Shortcut names
    ;     For i = 0 To #NbShortcutKeys-1
    ;       AddGadgetItem(#GADGET_EditTools_ShortcutKey, -1, ShortcutNames(i))
    ;     Next i
    
    ; disable the addtools window
    For i = #GADGET_AddTools_List To #GADGET_AddTools_OK
      DisableGadget(i, 1)
    Next i
    
    ; load the settings to edit, if this isn't a new one
    If IsNewTool
      SetGadgetState(#GADGET_EditTools_ReloadNew, 1) ; default
      SetGadgetState(#GADGET_EditTools_Trigger, 0)
      
      ;       SetGadgetState(#GADGET_EditTools_ShortcutControl, 0)
      ;       SetGadgetState(#GADGET_EditTools_ShortcutAlt,     0)
      ;       SetGadgetState(#GADGET_EditTools_ShortcutShift,   0)
      ;       SetGadgetState(#GADGET_EditTools_ShortcutCommand, 0)
      ;       SetGadgetState(#GADGET_EditTools_ShortcutKey, 0)
      SetGadgetState(#GADGET_EditTools_Shortcut, 0)
      
    Else ; load settings
      SetGadgetText(#GADGET_EditTools_CommandLine, ToolsList_Edit()\CommandLine$)
      SetGadgetText(#GADGET_EditTools_Arguments,   ToolsList_Edit()\Arguments$)
      SetGadgetText(#GADGET_EditTools_WorkingDir,  ToolsList_Edit()\WorkingDir$)
      SetGadgetText(#GADGET_EditTools_MenuEntry,   ToolsList_Edit()\MenuItemName$)
      SetGadgetText(#GADGET_EditTools_ConfigLine,  ToolsList_Edit()\ConfigLine$)
      
      ;       If ToolsList_Edit()\Shortcut & #PB_Shortcut_Control ; win 98 problem!
      ;         SetGadgetState(#GADGET_EditTools_ShortcutControl, 1)
      ;       Else
      ;         SetGadgetState(#GADGET_EditTools_ShortcutControl, 0)
      ;       EndIf
      ;
      ;       If ToolsList_Edit()\Shortcut & #PB_Shortcut_Alt
      ;         SetGadgetState(#GADGET_EditTools_ShortcutAlt,     1)
      ;       Else
      ;         SetGadgetState(#GADGET_EditTools_ShortcutAlt,     0)
      ;       EndIf
      ;
      ;       If ToolsList_Edit()\Shortcut & #PB_Shortcut_Shift
      ;         SetGadgetState(#GADGET_EditTools_ShortcutShift,   1)
      ;       Else
      ;         SetGadgetState(#GADGET_EditTools_ShortcutShift,   0)
      ;       EndIf
      ;
      ;       CompilerIf #CompileMac
      ;         SetGadgetState(#GADGET_EditTools_ShortcutCommand, ToolsList_Edit()\Shortcut & #PB_Shortcut_Command)
      ;       CompilerEndIf
      ;       SetGadgetState(#GADGET_EditTools_ShortcutKey, GetBaseKeyIndex(ToolsList_Edit()\Shortcut))
      SetGadgetState(#GADGET_EditTools_Shortcut, ToolsList_Edit()\Shortcut)
      
      SetGadgetState(#GADGET_EditTools_Trigger,    ToolsList_Edit()\Trigger)
      SetGadgetState(#GADGET_EditTools_HideEditor, ToolsList_Edit()\HideEditor)
      SetGadgetState(#GADGET_EditTools_WaitForQuit,ToolsList_Edit()\Flags & 1)
      SetGadgetState(#GADGET_EditTools_RunHidden,  ToolsList_Edit()\Flags & 2)
      SetGadgetState(#GADGET_EditTools_HideFromMenu,ToolsList_Edit()\HideFromMenu)
      SetGadgetState(#GADGET_EditTools_SourceSpecific,ToolsList_Edit()\SourceSpecific)
      
      If ToolsList_Edit()\ReloadSource <> 0
        SetGadgetState(#GADGET_EditTools_Reload, 1)
        
        If ToolsList_Edit()\ReloadSource = 1
          SetGadgetState(#GADGET_EditTools_ReloadNew, 1)
        Else
          SetGadgetState(#GADGET_EditTools_ReloadOld, 1)
        EndIf
      Else
        SetGadgetState(#GADGET_EditTools_ReloadNew, 1)
      EndIf
    EndIf
    
    AddTools_UpdateDisabledState() ; make sure the right choices are enabled
    
    SetActiveGadget(#GADGET_EditTools_CommandLine)
  EndIf
  
EndProcedure


Procedure UpdateEditToolsWindow()
  
  EditToolsWindowDialog\LanguageUpdate()
  
  ;   For i = 0 To #NbShortcutKeys-1
  ;     SetGadgetItemText(#GADGET_EditTools_ShortcutKey, i, ShortcutNames(i), 0)
  ;   Next i
  
  EditToolsWindowDialog\GuiUpdate()
  
EndProcedure


Procedure AddTools_EditWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    If GetActiveGadget() = #GADGET_EditTools_Shortcut
      ; Window shortcuts supersede the ShortcutGadget(), so in order to select "Return" as a shortcut
      ; Do not act on the menu event when the ShortcutGadget is active
      ;
      If EventMenu() = #GADGET_EditTools_Ok
        SetGadgetState(#GADGET_EditTools_Shortcut, #PB_Shortcut_Return)
      Else
        SetGadgetState(#GADGET_EditTools_Shortcut, #PB_Shortcut_Escape)
      EndIf
      EventID = 0
    Else
      EventID  = #PB_Event_Gadget   ; to normal gadget events...
      EventGadgetID = EventMenu()
    EndIf
  Else
    EventGadgetID = EventGadget()
  EndIf
  
  If EventID = #PB_Event_GadgetDrop
    Select EventGadgetID
        
      Case #GADGET_EditTools_CommandLine
        File$ = StringField(EventDropFiles(), 1, Chr(10))
        SetGadgetText(#GADGET_EditTools_CommandLine, File$)
        
      Case #GADGET_EditTools_WorkingDir
        Path$ = StringField(EventDropFiles(), 1, Chr(10))
        If FileSize(Path$) <> -2 ; probably a file then
          Path$ = GetPathPart(Path$)
        EndIf
        SetGadgetText(#GADGET_EditTools_WorkingDir, Path$)
        
    EndSelect
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadgetID
        
      Case #GADGET_EditTools_ChooseCommandLine
        CompilerIf #CompileWindows
          Pattern$ = Language("Compiler","ExePattern")
        CompilerElse
          Pattern$ = ""
        CompilerEndIf
        File$ = OpenFileRequester(Language("AddTools","ChooseExe"), GetGadgetText(#GADGET_EditTools_CommandLine), Pattern$, 0)
        If File$ <> ""
          SetGadgetText(#GADGET_EditTools_CommandLine, File$)
        EndIf
        
      Case #GADGET_EditTools_ArgumentsInfo
        Info$ = ""
        For i = 1 To 10
          Info$ + Language("AddTools","Argument"+Str(i)) + #NewLine
        Next i
        MessageRequester(Language("AddTools","Info"), Info$, #FLAG_Info)
        
        
      Case #GADGET_EditTools_ChooseWorkingDir
        Directory$ = PathRequester(Language("AddTools","ChooseDir"), GetGadgetText(#GADGET_EditTools_WorkingDir))
        If Directory$ <> ""
          SetGadgetText(#GADGET_EditTools_WorkingDir, Directory$)
        EndIf
        
      Case #GADGET_EditTools_Ok
        
        ; first check if all the contents are ok
        ;
        If Trim(GetGadgetText(#GADGET_EditTools_CommandLine)) = ""
          MessageRequester(#ProductName$, Language("AddTools","NoCommandLine"), #FLAG_Info)
          
        ElseIf Trim(GetGadgetText(#GADGET_EditTools_MenuEntry)) = ""
          MessageRequester(#ProductName$, Language("AddTools","NoName"), #FLAG_Info)
          
        Else
          index = ListIndex(ToolsList_Edit())
          
          Name$ = LCase(Trim(GetGadgetText(#GADGET_EditTools_MenuEntry)))
          
          ;           If GetGadgetState(#GADGET_EditTools_ShortcutKey) = -1
          ;             Shortcut = -1
          ;           Else
          ;             Shortcut = ShortcutValues(GetGadgetState(#GADGET_EditTools_ShortcutKey))
          ;           EndIf
          ;           If GetGadgetState(#GADGET_EditTools_ShortcutControl)
          ;             Shortcut | #PB_Shortcut_Control
          ;           EndIf
          ;           If GetGadgetState(#GADGET_EditTools_ShortcutAlt)
          ;             Shortcut | #PB_Shortcut_Alt
          ;           EndIf
          ;           If GetGadgetState(#GADGET_EditTools_ShortcutShift)
          ;             Shortcut | #PB_Shortcut_Shift
          ;           EndIf
          ;           If GetGadgetState(#GADGET_EditTools_ShortcutCommand)
          ;             Shortcut | #PB_Shortcut_Command
          ;           EndIf
          Shortcut = GetGadgetState(#GADGET_EditTools_Shortcut)
          
          If IsNewTool
            *CurrentTool = 0
          Else
            *CurrentTool = @ToolsList_Edit()
          EndIf
          
          If IsShortcutUsed(Shortcut, -1, *CurrentTool)
            MessageRequester(#ProductName$, Language("Shortcuts","AllreadyUsed")+#NewLine+Chr(34)+GetShortcutOwner(Shortcut)+Chr(34), #FLAG_Info) ; DO NOT FIX TYPO: AllreadyUsed
            error = 1
          Else
            error = 0
          EndIf
          
          ForEach ToolsList_Edit()
            If IsNewTool = 0 And ListIndex(ToolsList_Edit()) = index
              ; no checks in this case
            ElseIf Name$ = LCase(Trim(ToolsList_Edit()\MenuItemName$))
              MessageRequester(#ProductName$, Language("AddTools","NameExists"), #FLAG_Info)
              error = 1
              Break
              
            EndIf
          Next ToolsList_Edit()
          
          If index <> -1
            SelectElement(ToolsList_Edit(), index)
          EndIf
          
          ; now save the settings to the list
          ;
          If error = 0
            
            If IsNewTool  ; add the entry if it wasn't there
              If index = -1
                LastElement(ToolsList_Edit())
                index = ListSize(ToolsList_Edit())
              Else
                index + 1
              EndIf
              AddElement(ToolsList_Edit())
              AddGadgetItem(#GADGET_AddTools_List, index, "") ; also add a gadget item
              SetGadgetItemState(#GADGET_AddTools_List, index, #PB_ListIcon_Checked)
              SetGadgetState(#GADGET_AddTools_List, index)
            EndIf
            
            ToolsList_Edit()\CommandLine$   = GetGadgetText(#GADGET_EditTools_CommandLine)
            ToolsList_Edit()\Arguments$     = GetGadgetText(#GADGET_EditTools_Arguments)
            ToolsList_Edit()\WorkingDir$    = GetGadgetText(#GADGET_EditTools_WorkingDir)
            ToolsList_Edit()\MenuItemName$  = GetGadgetText(#GADGET_EditTools_MenuEntry)
            ToolsList_Edit()\Shortcut       = Shortcut
            ToolsList_Edit()\ConfigLine$    = GetGadgetText(#GADGET_EditTools_Configline)
            ToolsList_Edit()\Trigger        = GetGadgetState(#GADGET_EditTools_Trigger)
            ToolsList_Edit()\Flags          = GetGadgetState(#GADGET_EditTools_WaitForQuit) | GetGadgetState(#GADGET_EditTools_RunHidden) << 1
            
            If GetGadgetState(#GADGET_EditTools_Reload) = 0
              ToolsList_Edit()\ReloadSource = 0
            ElseIf GetGadgetState(#GADGET_EditTools_ReloadNew) <> 0
              ToolsList_Edit()\ReloadSource = 1
            Else
              ToolsList_Edit()\ReloadSource = 2
            EndIf
            
            ToolsList_Edit()\HideEditor     = GetGadgetState(#GADGET_EditTools_HideEditor)
            ToolsList_Edit()\HideFromMenu   = GetGadgetState(#GADGET_EditTools_HideFromMenu)
            ToolsList_Edit()\SourceSpecific = GetGadgetState(#GADGET_EditTools_SourceSpecific)
            
            AddTools_UpdateListItem(index)
            
            Quit = 1
          EndIf
        EndIf
        
        
      Case #GADGET_EditTools_Cancel
        Quit = 1
        
      Default ; one of the options has changed
        If IsWindow(#WINDOW_EditTools)
          AddTools_UpdateDisabledState()
        EndIf
        
    EndSelect
    
    
  ElseIf EventID = #PB_Event_CloseWindow
    Quit = 1
    
  EndIf
  
  If Quit
    If MemorizeWindow
      EditToolsWindowDialog\Close(@EditToolsWindowPosition)
    Else
      EditToolsWindowDialog\Close()
    EndIf
    
    ; enable the addtools window
    For i = #GADGET_AddTools_List To #GADGET_AddTools_OK
      DisableGadget(i, 0)
    Next i
    
    SetActiveWindow(#WINDOW_AddTools)
  EndIf
  
EndProcedure


Procedure AddTools_OpenWindow()
  
  If IsWindow(#WINDOW_AddTools) = 0
    
    AddToolsWindowDialog = OpenDialog(?Dialog_AddTools, WindowID(#WINDOW_Main), @AddToolsWindowPosition)
    If AddToolsWindowDialog
      EnsureWindowOnDesktop(#WINDOW_AddTools)
      
      EnableGadgetDrop(#GADGET_AddTools_List, #PB_Drop_Private, #PB_Drag_Move, #DRAG_AddTools)
      
      ; adjust column width
      ColumnWidth = (GadgetWidth(#GADGET_AddTools_List) - 20) / 6
      SetGadgetItemAttribute(#GADGET_AddTools_List, 0, #PB_ListIcon_ColumnWidth, ColumnWidth*2, 0)
      SetGadgetItemAttribute(#GADGET_AddTools_List, 0, #PB_ListIcon_ColumnWidth, ColumnWidth, 1)
      SetGadgetItemAttribute(#GADGET_AddTools_List, 0, #PB_ListIcon_ColumnWidth, ColumnWidth*3, 2)
      
      ; duplicate the tools list to work on it, and fill the gadget
      ;
      ClearList(ToolsList_Edit())
      ForEach ToolsList()
        AddElement(ToolsList_Edit())
        ToolsList_Edit()\CommandLine$   = ToolsList()\CommandLine$
        ToolsList_Edit()\Arguments$     = ToolsList()\Arguments$
        ToolsList_Edit()\WorkingDir$    = ToolsList()\WorkingDir$
        ToolsList_Edit()\MenuItemName$  = ToolsList()\MenuItemName$
        ToolsList_Edit()\Shortcut       = ToolsList()\Shortcut
        ToolsList_Edit()\Configline$    = ToolsList()\ConfigLine$
        ToolsList_Edit()\Trigger        = ToolsList()\Trigger
        ToolsList_Edit()\Flags          = ToolsList()\Flags
        ToolsList_Edit()\ReloadSource   = ToolsList()\ReloadSource
        ToolsList_Edit()\HideEditor     = ToolsList()\HideEditor
        ToolsList_Edit()\HideFromMenu   = ToolsList()\HideFromMenu
        ToolsList_Edit()\SourceSpecific = ToolsList()\SourceSpecific
        ToolsList_Edit()\DeactivateTool = ToolsList()\DeactivateTool
        
        
        item = ListIndex(ToolsList_Edit())
        AddGadgetItem(#GADGET_AddTools_List, item, ToolsList_Edit()\MenuItemName$)
        If ToolsList_Edit()\Trigger = 0 And ToolsList_Edit()\Shortcut <> 0 And ToolsList_Edit()\Shortcut <> -1
          SetGadgetItemText(#GADGET_AddTools_List, item, GetShortcutText(ToolsList_Edit()\Shortcut), 1)
        Else
          SetGadgetItemText(#GADGET_AddTools_List, item, Language("AddTools","Trigger"+Str(ToolsList_Edit()\Trigger)), 1)
        EndIf
        SetGadgetItemText(#GADGET_AddTools_List, item, ToolsList_Edit()\CommandLine$, 2)
        
        If ToolsList_Edit()\DeactivateTool = 0
          SetGadgetItemState(#GADGET_AddTools_List, item, #PB_ListIcon_Checked)
        EndIf
      Next ToolsList()
      
    EndIf
    
  Else
    SetWindowforeground(#WINDOW_AddTools)
  EndIf
  
  SetActiveGadget(#GADGET_AddTools_List)
  
EndProcedure



Procedure AddTools_WindowEvents(EventID)
  Static DragItem ; selected item during a d+d
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    EventGadgetID = EventMenu()
  Else
    EventGadgetID = EventGadget()
  EndIf
  
  
  If EventID = #PB_Event_GadgetDrop
    If EventGadgetID = #GADGET_AddTools_List
      Target = GetGadgetState(#GADGET_AddTools_List)
      If Target = -1
        Target = CountGadgetItems(#GADGET_AddTools_List)-1
      EndIf
      
      If Target > DragItem
        For i = DragItem To Target-1
          AddTools_SwitchElements(i, i+1)
        Next i
        
      ElseIf Target < DragItem ; if Target=DragItem we do nothing
        For i = DragItem To Target+1 Step -1
          AddTools_SwitchElements(i, i-1)
        Next i
        
      EndIf
      SetGadgetState(#GADGET_AddTools_List, Target)
      
    EndIf
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadgetID
        
      Case #GADGET_AddTools_List
        If EventType() = #PB_EventType_DragStart
          DragItem = GetGadgetState(#GADGET_AddTools_List)
          If DragItem <> -1
            DragPrivate(#DRAG_AddTools, #PB_Drag_Move)
          EndIf
          
        ElseIf EventType() = #PB_EventType_LeftDoubleClick ; allows to edit a tool
          index = GetGadgetState(#GADGET_AddTools_List)
          If index <> -1
            IsNewTool = 0
            SelectElement(ToolsList_Edit(), index)
            AddTools_OpenEditWindow()
          EndIf
        EndIf
        
      Case #GADGET_AddTools_New
        If ListSize(ToolsList_Edit()) < #MAX_AddTools
          IsNewTool = 1
          AddTools_OpenEditWindow()
        EndIf
        
      Case #GADGET_AddTools_Edit
        index = GetGadgetState(#GADGET_AddTools_List)
        If index <> -1
          IsNewTool = 0
          SelectElement(ToolsList_Edit(), index)
          AddTools_OpenEditWindow()
        EndIf
        
      Case #GADGET_AddTools_Delete
        index = GetGadgetState(#GADGET_AddTools_List)
        
        If index <> -1
          RemoveGadgetItem(#GADGET_AddTools_List, index)
          SelectElement(ToolsList_Edit(), index)
          DeleteElement(ToolsList_Edit())
        EndIf
        
      Case #GADGET_AddTools_Up
        index = GetGadgetState(#GADGET_AddTools_List)
        If index > 0
          AddTools_SwitchElements(index, index-1)
          SetGadgetState(#GADGET_AddTools_List, index-1)
        EndIf
        
      Case #GADGET_AddTools_Down
        index = GetGadgetState(#GADGET_AddTools_List)
        If index <> -1 And index < CountGadgetItems(#GADGET_AddTools_List)-1
          AddTools_SwitchElements(index, index+1)
          SetGadgetState(#GADGET_AddTools_List, index+1)
        EndIf
        
      Case #GADGET_AddTools_Ok
        If IsWindow(#WINDOW_EditTools) = 0 ; even when the ok butten is disabled, the shortcut works, so check this!
          
          ; copy the list over the old one, and save the prefs
          ;
          If CreatePreferences(AddToolsFile$)
            PreferenceComment(" PureBasic IDE ToolsMenu Configuration")
            PreferenceComment("")
            PreferenceGroup("ToolsInfo")
            WritePreferenceLong("ToolCount", ListSize(ToolsList_Edit()))
            SavePrefs = 1
          Else
            SavePrefs = 0
            MessageRequester(#ProductName$, LanguagePattern("Misc","PreferenceError", "%filename%", AddToolsFile$), #FLAG_Error)
          EndIf
          
          AddTools_PatternStrings$ = ""
          
          ClearList(ToolsList())
          ForEach ToolsList_Edit()
            AddElement(ToolsList())
            ToolsList()\CommandLine$   = ToolsList_Edit()\CommandLine$
            ToolsList()\Arguments$     = ToolsList_Edit()\Arguments$
            ToolsList()\WorkingDir$    = ToolsList_Edit()\WorkingDir$
            ToolsList()\MenuItemName$  = ToolsList_Edit()\MenuItemName$
            ToolsList()\Shortcut       = ToolsList_Edit()\Shortcut
            ToolsList()\Configline$    = ToolsList_Edit()\ConfigLine$
            ToolsList()\Trigger        = ToolsList_Edit()\Trigger
            ToolsList()\ReloadSource   = ToolsList_Edit()\ReloadSource
            ToolsList()\HideEditor     = ToolsList_Edit()\HideEditor
            ToolsList()\HideFromMenu   = ToolsList_Edit()\HideFromMenu
            ToolsList()\SourceSpecific = ToolsList_Edit()\SourceSpecific
            ToolsList()\Flags          = ToolsList_Edit()\Flags
            
            If GetGadgetItemState(#GADGET_AddTools_List, ListIndex(ToolsList_Edit())) & #PB_ListIcon_Checked
              ToolsList()\DeactivateTool = 0
            Else
              ToolsList()\DeactivateTool = 1
            EndIf
            
            If ToolsList()\Trigger = #TRIGGER_FileViewer_Special
              Pattern$ = RemoveString(ToolsList()\ConfigLine$, " ")
              If Right(Pattern$, 1) = ","
                Pattern$ = Left(Pattern$, Len(Pattern$)-1)
              EndIf
              AddTools_PatternStrings$ +ToolsList()\MenuItemName$ + " (*."+ReplaceString(Pattern$, ",", ",*.") + ")|*."+ReplaceString(Pattern$, ",", ";*.") + "|"
            EndIf
            
            If SavePrefs
              PreferenceComment("")
              PreferenceComment("")
              PreferenceGroup("Tool_"+Str(ListIndex(ToolsList())))
              
              WritePreferenceString("Command"     , ToolsList()\CommandLine$ )
              WritePreferenceString("Arguments"   , ToolsList()\Arguments$   )
              WritePreferenceString("WorkingDir"  , ToolsList()\WorkingDir$  )
              WritePreferenceString("MenuItemName", ToolsList()\MenuItemName$)
              WritePreferenceLong  ("Shortcut"    , ToolsList()\Shortcut     )
              WritePreferenceString("ConfigLine"  , ToolsList()\ConfigLine$  )
              WritePreferenceLong  ("Trigger"     , ToolsList()\Trigger      )
              WritePreferenceLong  ("Flags"       , ToolsList()\Flags        )
              WritePreferenceLong  ("ReloadSource", ToolsList()\ReloadSource )
              WritePreferenceLong  ("HideEditor"  , ToolsList()\HideEditor   )
              WritePreferenceLong  ("HideFromMenu", ToolsList()\HideFromMenu )
              WritePreferenceLong  ("SourceSpecific", ToolsList()\SourceSpecific)
              WritePreferenceLong  ("Deactivate"  , ToolsList()\DeactivateTool)
            EndIf
            
          Next ToolsList_Edit()
          
          ClearList(ToolsList_Edit())
          
          If SavePrefs
            ClosePreferences()
          EndIf
          
          RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_All)
          
          CompilerIf #CompileWindows | #CompileMac | #CompileLinuxQt; re-add the shortcuts for tab/enter
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Return, #MENU_Scintilla_Enter)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Tab, #MENU_Scintilla_Tab)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Shift | #PB_Shortcut_Tab, #MENU_Scintilla_ShiftTab)
          CompilerEndIf
          
          StartFlickerFix(#WINDOW_Main)
          CreateIDEMenu() ; update the menu
          StopFlickerFix(#WINDOW_Main, 1)
          
          CreateKeyboardShortcuts(#WINDOW_Main)
          UpdateExplorerPatterns()
          Quit = 1
        EndIf
        
      Case #GADGET_AddTools_Cancel ; cancel can also be pressed when the edit window is open.
        If IsWindow(#WINDOW_EditTools)
          AddTools_EditWindowEvents(#PB_Event_CloseWindow)
        EndIf
        Quit = 1
        
    EndSelect
    
  ElseIf EventID = #PB_Event_SizeWindow
    AddToolsWindowDialog\SizeUpdate()
    
  ElseIf EventID = #PB_Event_CloseWindow
    If IsWindow(#WINDOW_EditTools)
      AddTools_EditWindowEvents(#PB_Event_CloseWindow)
    EndIf
    Quit = 1
    
  EndIf
  
  If Quit
    If MemorizeWindow
      AddToolsWindowDialog\Close(@AddToolsWindowPosition)
    Else
      AddToolsWindowDialog\Close()
    EndIf
    
    AddToolsWindowDialog = 0
  EndIf
  
EndProcedure
