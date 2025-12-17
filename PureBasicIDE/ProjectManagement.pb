; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------



#Project_Version = 100
#Project_VersionString = "1.0"

#Project_Open_LoadLast    = 0
#Project_Open_LoadAll     = 1
#Project_Open_LoadDefault = 2
#Project_Open_LoadMain    = 3
#Project_Open_LoadNone    = 4

; Some helpers for the XML reading/writing
;
Procedure NewSection(*Main, Name$)
  *Section = CreateXMLNode(*Main, "section", -1)
  SetXMLAttribute(*Section, "name", Name$)
  ProcedureReturn *Section
EndProcedure

Procedure AppendNode(*Parent, Name$, Text$="")
  *Node = CreateXMLNode(*Parent, Name$, -1)
  SetXMLNodeText(*Node, Text$)
  ProcedureReturn *Node
EndProcedure

Procedure GetSection(*Main, Name$)
  *Section = ChildXMLNode(*Main)
  
  While *Section
    If XMLNodeType(*Section) = #PB_XML_Normal And GetXMLNodeName(*Section) = "section" And GetXMLAttribute(*Section, "name") = Name$
      If GetXMLAttribute(*Section, "minversion") = "" Or Int(ValD(GetXMLAttribute(*Section, "minversion")) * 100.0) <= #Project_Version
        ProcedureReturn *Section
      Else
        ProcedureReturn 0
      EndIf
    EndIf
    
    *Section = NextXMLNode(*Section)
  Wend
  
  ProcedureReturn 0
EndProcedure

Procedure.s ReadNode(*Section, Path$)
  *Node = XMLNodeFromPath(*Section, Path$)
  If *Node
    ProcedureReturn GetXMLNodeText(*Node)
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

; for simpler XML reading
;
Procedure.s Xml_SingleLine(Input$)  ; simply cuts all newline and trims spaces
  Input$ = RemoveString(Input$, Chr(13))
  Input$ = RemoveString(Input$, Chr(10))
  ProcedureReturn Trim(Input$)
EndProcedure


Procedure.s Xml_MultiLine(Input$)   ; cuts newline at beginning and end and trims space on every line
  
  ; replace all newline by chr(10)
  Input$ = ReplaceString(Input$, Chr(13)+Chr(10), Chr(10))
  Input$ = ReplaceString(Input$, Chr(13), Chr(10))
  
  ; remove empty lines at beginning and end
  Input$ = Trim(Input$)
  While Left(Input$, 1) = Chr(10)
    Input$ = LTrim(Right(Input$, Len(Input$)-1))
  Wend
  
  While Right(Input$, 1) = Chr(10)
    Input$ = RTrim(Left(Input$, Len(Input$)-1))
  Wend
  
  ; trim spaces in between lines, and put back system newline
  Count   = CountString(Input$, Chr(10))+1
  Output$ = ""
  For i = 1 To Count
    Output$ + #NewLine + Trim(StringField(Input$, i, Chr(10)))
  Next i
  If Output$ <> ""
    Output$ = Right(Output$, Len(Output$)-Len(#NewLine))
  EndIf
  
  ProcedureReturn Output$
EndProcedure

Procedure Xml_Integer(Input$, Fallback = 0) ; reads an integer value (returns fallback for empty string)
  Length = Len(Input$)
  Value$ = ""
  For i = 1 To Length
    If FindString("1234567890+-$%.eE", Mid(Input$, i, 1), 1) <> 0 ; cut all unwanted characters
      Value$ + Mid(Input$, i, 1)
    EndIf
  Next i
  
  If Input$ = ""
    ProcedureReturn Fallback
  Else
    ProcedureReturn Val(Value$)
  EndIf
EndProcedure

Procedure Xml_Boolean(Input$, Fallback = 0) ; returns 0 or 1 always
  If Xml_Integer(Input$, 0)
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure AddProjectDefaultMenuEntries()
  If IsProject
    ForEach ProjectTargets()
      Index = ListIndex(ProjectTargets())
      If Index < #MAX_MenuTargets
        MenuItem(#MENU_DefaultTarget_Start+Index, ProjectTargets()\Name$)
        
        ; mark the default item
        If ProjectTargets()\IsDefault
          SetMenuItemState(#MENU, #MENU_DefaultTarget_Start+Index, #True)
        EndIf
      EndIf
    Next ProjectTargets()
  EndIf
EndProcedure

Procedure AddProjectBuildMenuEntries()
  If IsProject
    ForEach ProjectTargets()
      Index = ListIndex(ProjectTargets())
      If Index < #MAX_MenuTargets
        MenuItem(#MENU_BuildTarget_Start+Index, ProjectTargets()\Name$)
      EndIf
    Next ProjectTargets()
  EndIf
EndProcedure

Procedure IsProjectFile(FileName$)
  Protected Result = #False
  
  ; Note: We can not share the loaded #XML with the LoadProject() (which would save a re-parse)
  ;   because LoadSourceFile() calls IsProjectFile() too, and this would invalidate
  ;   the #XML from the LoadProject(), so just parse it twice (its small anyway)
  ;   This bug took a long time to track down.
  
  ; Sanity size check to not forever try to parse a very large file
  ; Only .pbp/.sbp are recognized as projects to have a faster check
  ;
  If "."+LCase(GetExtensionPart(FileName$)) = #ProjectFileExtension And FileSize(FileName$) < 1024*1024*10
    
    ; Just parse the XML and check whether the main node and namespace are ok.
    ; Project files are rather small, so this is ok
    ;
    If LoadXML(#XML_CheckProject, FileName$)
      If XMLStatus(#XML_CheckProject) = #PB_XML_Success And MainXMLNode(#XML_CheckProject)
        If ResolveXMLNodeName(MainXMLNode(#XML_CheckProject), "/") = #ProjectFileNamespace$ + "/project"
          Result = #True
        EndIf
      EndIf
      
      FreeXML(#XML_CheckProject)
    EndIf
    
  EndIf
  
  ProcedureReturn Result
EndProcedure

Procedure.s ProjectName(FileName$) ; Get the project name from a project file
  Result$ = ""
  
  If LoadXML(#XML_CheckProject, FileName$)
    If XMLStatus(#XML_CheckProject) = #PB_XML_Success And MainXMLNode(#XML_CheckProject)
      If ResolveXMLNodeName(MainXMLNode(#XML_CheckProject), "/") = #ProjectFileNamespace$ + "/project"
        *Config = GetSection(MainXMLNode(#XML_CheckProject), "config")
        If *Config
          *Options = XMLNodeFromPath(*Config, "options")
          If *Options
            Result$ = Xml_SingleLine(GetXMLAttribute(*Options, "name"))
          EndIf
        EndIf
      EndIf
    EndIf
    
    FreeXML(#XML_CheckProject)
  EndIf
  
  ProcedureReturn Result$
EndProcedure

; Provides a guess whether a file may be a sourcecode or not for the purpose of AutoComplete scanning
; Also used to decide whether a file should be highlighted or not
; Accept both PB/SB files here, to make it more comfortable to edit an SB file in the PB IDE for example
;
Procedure IsCodeFile(FileName$)
  Ext$ = UCase(GetExtensionPart(FileName$))
  
  If Ext$ = ""
    ProcedureReturn #False
  EndIf
  
  ; PB and SB extensions always work
  If Ext$ = "PB" Or Ext$ = "PBI" Or Ext$ = "PBF" Or Ext$ = "SB" Or Ext$ = "SBI" Or Ext$ = "SBF"
    ProcedureReturn #True
  EndIf
  
  ; Check custom extensions from the preferences
  Count = CountString(CodeFileExtensions$, ",") + 1
  For i = 1 To Count
    If Ext$ = UCase(Trim(StringField(CodeFileExtensions$, i, ",")))
      ProcedureReturn #True
    EndIf
  Next i
  
  ProcedureReturn #False
EndProcedure

; Decides whether to add a 'PB' icon to a file in the project panel/explorer
; Only allow PB or SB here depending on the mode
;
Procedure IsPureBasicFile(FileName$)
  Ext$ = UCase(GetExtensionPart(FileName$))
  
  CompilerIf #SpiderBasic
    If Ext$ = "SB" Or Ext$ = "SBI" Or Ext$ = "SBF" Or Ext$ = "SBP"
      ProcedureReturn #True
    EndIf
  CompilerElse
    If Ext$ = "PB" Or Ext$ = "PBI" Or Ext$ = "PBF" Or Ext$ = "PBP"
      ProcedureReturn #True
    EndIf
  CompilerEndIf
  
  ProcedureReturn #False
EndProcedure


; copy the config data part of a project file
;
Procedure CopyProjectConfig(*Source.ProjectFileConfig, *Dest.ProjectFileConfig)
  *Dest\FileName$   = *Source\FileName$
  
  *Dest\AutoLoad    = *Source\AutoLoad
  *Dest\AutoScan    = *Source\AutoScan
  *Dest\ShowPanel   = *Source\ShowPanel
  *Dest\ShowWarning = *Source\ShowWarning
EndProcedure

; Clear any allocated data in a project filelist file before removing it
;
Procedure ClearProjectFile(*File.ProjectFile)
  
  FreeSourceItemArray(@*File\Parser) ; has a 0-check and sets the value to 0
  
EndProcedure


; Unlink file from project. Set KeepData=#true if the project will not be closed
; (so #false on project close or IDE close)
;
Procedure UnlinkSourceFromProject(*Source.SourceFile, RescanFile)
  
  If *Source\ProjectFile
    *File.ProjectFile = *Source\ProjectFile
    *File\Source        = 0
    *Source\ProjectFile = 0
    RefreshSourceTitle(*Source)
    
    If *Source = *ActiveSource
      UpdateMenuStates()
      UpdateMainWindowTitle()
      ErrorLog_SyncState()
    EndIf
    
    ; Re-scan the file from disk if the project data is still needed
    ;
    If RescanFile And *File\AutoScan
      ScanFile(*File\FileName$, @*File\Parser)
    EndIf
  EndIf
  
EndProcedure


; Link a sourcefile to the project
; Just call this on all sourcefiles opened. Files outside of the project are handled correctly
;
Procedure LinkSourceToProject(*Source.SourceFile, *File.ProjectFile = 0)
  
  If *Source\FileName$ ; cannot link a non-saved file
    
    ; find project file (if not specified)
    If *File = 0
      ForEach ProjectFiles()
        If IsEqualFile(*Source\FileName$, ProjectFiles()\FileName$)
          *File = @ProjectFiles()
          Break
        EndIf
      Next ProjectFiles()
    EndIf
    
    If *Source\ProjectFile And *Source\ProjectFile <> *File
      UnlinkSourceFromProject(*Source, #True)
    EndIf
    
    ; check again, as the file may not be in the project at all
    If *File
      *Source\ProjectFile = *File
      *File\Source = *Source
      
      FreeSourceItemArray(@*File\Parser) ; free any data we have from a previous scan
      
      RefreshSourceTitle(*Source)
      If *Source = *ActiveSource
        UpdateMenuStates()
        UpdateMainWindowTitle()
        ErrorLog_SyncState()     ; the state may change as now the ProjectShowLog counts
      EndIf
    EndIf
  EndIf
  
EndProcedure

; Update the data kept on the project file, including the link to a sourcefile
Procedure UpdateProjectFile(*File.ProjectFile)
  
  ; clear any data scanned from disk
  FreeSourceItemArray(@*File\Parser) ; has a 0-check and sets the value to 0
  
  ; find the source that represents this file (if any)
  *Source.SourceFile = 0
  ForEach FileList()
    If @FileList() <> *ProjectInfo And FileList()\FileName$ <> "" And IsEqualFile(*File\FileName$, FileList()\FileName$)
      *Source = @FileList()
      Break
    EndIf
  Next FileList()
  ChangeCurrentElement(FileList(), *ActiveSource)
  
  If *Source
    If *Source\ProjectFile And *Source\ProjectFile <> *File
      UnlinkSourceFromProject(*Source, #True)
    EndIf
    
    If *Source\ProjectFile = 0 ; if nonzero, it equals our *File, so ok
      LinkSourceToProject(*Source, *File)
    EndIf
    
  Else
    *File\Source = 0
    
    ; scan the autocomplete info from disk if required
    If *File\AutoScan
      ScanFile(*File\Filename$, @*File\Parser)
    EndIf
  EndIf
  
EndProcedure

; Sets the default target from the target list, creating it if there is none
;
Procedure SetProjectDefaultTarget()
  
  If ListSize(ProjectTargets()) = 0
    ; No targets are present, create a new default one
    ;
    AddElement(ProjectTargets())
    SetCompileTargetDefaults(@ProjectTargets()) ; preference default values
    
    ProjectTargets()\ID = GetUniqueID()
    
    ; Set project specific stuff within the target
    ;
    ProjectTargets()\IsProject = #True
    ProjectTargets()\Name$     = Language("Compiler", "DefaultTargetName")
    ProjectTargets()\IsEnabled = #True
    ProjectTargets()\IsDefault = #True
    *DefaultTarget = @ProjectTargets()
    
  Else
    
    FirstElement(ProjectTargets())
    *DefaultTarget = @ProjectTargets() ; fallback, if no target has the default flag
    
    ForEach ProjectTargets()
      If ProjectTargets()\IsDefault
        *DefaultTarget = @ProjectTargets()
        Break
      EndIf
    Next ProjectTargets()
    
    ; make sure the flag value is consistent
    ForEach ProjectTargets()
      If *DefaultTarget = @ProjectTargets()
        ProjectTargets()\IsDefault = #True
      Else
        ProjectTargets()\IsDefault = #False
      EndIf
    Next ProjectTargets()
  EndIf
  
EndProcedure

Procedure ResizeProjectInfo(Width, Height)
  
  GetRequiredSize(#GADGET_ProjectInfo_OpenOptions, @Button1Width.l, @Button1Height.l)
  GetRequiredSize(#GADGET_ProjectInfo_OpenCompilerOptions, @Button2Width.l, @Button2Height.l)
  ButtonWidth  = Max(Button1Width, Max(Button2Width, 100))
  
  ; calculate height for info part
  TextHeight = GetRequiredHeight(#GADGET_ProjectInfo_Info)
  TextHeight = Max(TextHeight, Button1Height+Button2Height+5)
  InfoHeight = 15 + ProjectInfoFrameHeight + TextHeight
  If InfoHeight > (Height-60) / 2
    ; info size too great, cap it
    InfoHeight = (Height-60) / 2
  EndIf
  
  CompilerIf #CompileMacCocoa
    BorderOffset = 8
  CompilerElse
    BorderOffset = 0
  CompilerEndIf
  
  ; size for other parts
  PartHeight = (Height-60-InfoHeight) / 2
  
  ResizeGadget(#GADGET_ProjectInfo_FrameProject, 20-BorderOffset, 20-BorderOffset, Width-40, InfoHeight)
  ResizeGadget(#GADGET_ProjectInfo_Info, 30-BorderOffset, 25+ProjectInfoFrameHeight-BorderOffset, Width-65-ButtonWidth, InfoHeight-15-ProjectInfoFrameHeight)
  ResizeGadget(#GADGET_ProjectInfo_OpenOptions, Width-30-ButtonWidth-BorderOffset, 25+ProjectInfoFrameHeight-BorderOffset, ButtonWidth, Button1Height)
  ResizeGadget(#GADGET_ProjectInfo_OpenCompilerOptions, Width-30-ButtonWidth-BorderOffset, 30+ProjectInfoFrameHeight+Button1Height-BorderOffset, ButtonWidth, Button1Height)
  
  ResizeGadget(#GADGET_ProjectInfo_FrameFiles, 20-BorderOffset, InfoHeight+30-BorderOffset, Width-40, PartHeight)
  ResizeGadget(#GADGET_ProjectInfo_Files, 30-BorderOffset, InfoHeight+35+ProjectInfoFrameHeight-BorderOffset, Width-60, PartHeight-15-ProjectInfoFrameHeight)
  
  ResizeGadget(#GADGET_ProjectInfo_FrameTargets, 20-BorderOffset, InfoHeight+PartHeight+40-BorderOffset, Width-40, PartHeight)
  ResizeGadget(#GADGET_ProjectInfo_Targets, 30-BorderOffset, InfoHeight+PartHeight+45+ProjectInfoFrameHeight-BorderOffset, Width-60, PartHeight-15-ProjectInfoFrameHeight)
  
  CompilerIf #CompileWindows
    ; Will size the middle columns small, and the last as big as possible
    For i = 1 To 6
      If i <> 5 ; leave the "size" column alone
        SendMessage_(GadgetID(#GADGET_ProjectInfo_Files), #LVM_SETCOLUMNWIDTH, i, #LVSCW_AUTOSIZE_USEHEADER)
      EndIf
    Next i
    
    For i = 1 To 8
      If i <> 7 ; leave the "format" column alone
        SendMessage_(GadgetID(#GADGET_ProjectInfo_Targets), #LVM_SETCOLUMNWIDTH, i, #LVSCW_AUTOSIZE_USEHEADER)
      EndIf
    Next i
  CompilerEndIf
  
EndProcedure

Procedure.s ProjectInfo_Boolean(Input)
  If Input
    ProcedureReturn Language("Misc","Yes")
  Else
    ProcedureReturn ""
  EndIf
EndProcedure

; Apply project data changes
Procedure UpdateProjectInfo()
  If *ProjectInfo
    
    ; Project Info
    ;
    Text$ = Language("Project","ProjectName")+": " + ProjectName$ + #NewLine
    Text$ + Language("Project","ProjectFile")+": " + ProjectFile$
    
    If ProjectLastOpenDate
      Text$ + #NewLine + #NewLine
      Text$ + Language("Project","LastOpen")+": " + ReplaceString(ReplaceString(ReplaceString(Language("Project","LastOpenText"), "%date%", FormatDate(Language("Project","FileDateFormat"), ProjectLastOpenDate)), "%user%", ProjectLastOpenUser$), "%host%", ProjectLastOpenHost$) + #NewLine
      Text$ + Language("Project","LastOpenEditor")+": " + ProjectLastOpenEditor$
    EndIf
    
    If Trim(ProjectComments$) <> ""
      Text$ + #NewLine + #NewLine
      Text$ + Language("Project","Comments")+": "+#NewLine
      Text$ + ProjectComments$
    EndIf
    
    SetGadgetText(#GADGET_ProjectInfo_Info, Text$)
    
    ; File List
    ;
    ClearGadgetItems(#GADGET_ProjectInfo_Files)
    ForEach ProjectFiles()
      Text$ = CreateRelativePath(GetPathPart(ProjectFile$), ProjectFiles()\Filename$) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectFiles()\AutoLoad) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectFiles()\ShowWarning) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectFiles()\AutoScan) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectFiles()\ShowPanel) + Chr(10)
      
      Size = FileSize(ProjectFiles()\Filename$)
      If Size < 0 ; file missing
        Text$ + Chr(10) + Chr(10)
      Else
        Text$ + StrByteSize(Size) + Chr(10)
        Text$ + FormatDate(Language("Project","FileDateFormat"), GetFileDate(ProjectFiles()\Filename$, #PB_Date_Modified))
      EndIf
      
      If ProjectFiles()\AutoScan
        ImageID = OptionalImageID(#IMAGE_ProjectPanel_FileScanned)
      Else
        ImageID = OptionalImageID(#IMAGE_ProjectPanel_File)
      EndIf
      AddGadgetItem(#GADGET_ProjectInfo_Files, -1, Text$, ImageID)
      
      ; Associate the ProjectFile structure (for the Popup menu)
      SetGadgetItemData(#GADGET_ProjectInfo_Files, CountGadgetItems(#GADGET_ProjectInfo_Files)-1, @ProjectFiles())
    Next ProjectFiles()
    
    ; Target list
    ;
    ClearGadgetItems(#GADGET_ProjectInfo_Targets)
    ForEach ProjectTargets()
      Text$ = ProjectTargets()\Name$ + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectTargets()\Debugger) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectTargets()\EnableThread) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectTargets()\EnableASM) + Chr(10)
      Text$ + ProjectInfo_Boolean(ProjectTargets()\EnableOnError) + Chr(10)
      
      If ProjectTargets()\UseCompileCount
        Text$ + Str(ProjectTargets()\CompileCount) + Chr(10)
      Else
        Text$ + Chr(10)
      EndIf
      
      If ProjectTargets()\UseBuildCount
        Text$ + Str(ProjectTargets()\BuildCount) + Chr(10)
      Else
        Text$ + Chr(10)
      EndIf
      
      ; These are also not localized in the Compile Options/Preferences
      ;
      Select ProjectTargets()\ExecutableFormat
          CompilerIf #CompileWindows
          Case 0: Text$ + "Windows" + Chr(10)
          Case 1: Text$ + "Console" + Chr(10)
          Case 2: Text$ + "Dll" + Chr(10)
          CompilerEndIf
          
          CompilerIf #CompileLinux
          Case 0: Text$ + "Linux" + Chr(10)
          Case 1: Text$ + "Console" + Chr(10)
          Case 2: Text$ + ".so" + Chr(10)
          CompilerEndIf
          
          CompilerIf #CompileMac
          Case 0: Text$ + "MacOS" + Chr(10)
          Case 1: Text$ + "Console" + Chr(10)
          Case 2: Text$ + ".dylib" + Chr(10)
          CompilerEndIf
      EndSelect
      
      Text$ + ProjectTargets()\MainFile$
      AddGadgetItem(#GADGET_ProjectInfo_Targets, -1, Text$, ProjectTargetImage(@ProjectTargets()))
    Next ProjectTargets()
    
    ResizeProjectInfo(GadgetWidth(#GADGET_ProjectInfo), GadgetHeight(#GADGET_ProjectInfo))
  EndIf
  
EndProcedure

; Apply preferences changes
Procedure UpdateProjectInfoPreferences()
  If *ProjectInfo
    
    ; Find Project tab (position may have changed!) and update its text
    PushListPosition(FileList())
    ChangeCurrentElement(FileList(), *ProjectInfo)
    SetTabBarGadgetItemText(#GADGET_FilesPanel, ListIndex(FileList()), Language("Project","TabTitle") + " [" + ProjectName$ + "]")
    PopListPosition(FileList())
    
    SetGadgetText(#GADGET_ProjectInfo_FrameProject, Language("Project","ProjectInfo"))
    SetGadgetText(#GADGET_ProjectInfo_FrameFiles, Language("Project","FileTab"))
    SetGadgetText(#GADGET_ProjectInfo_FrameTargets, Language("Project","ProjectTargets"))
    
    SetGadgetText(#GADGET_ProjectInfo_OpenOptions, Language("Project","ProjectOptions"))
    SetGadgetText(#GADGET_ProjectInfo_OpenCompilerOptions, Language("Project","CompilerOptions"))
    
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","Filename"), 0)
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","FileLoadShort"), 1)
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","FileWarnShort"), 2)
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","FileScanShort"), 3)
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","FilePanelShort"), 4)
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","FileSize"), 5)
    SetGadgetItemText(#GADGET_ProjectInfo_Files, -1, Language("Project","FileModified"), 6)
    
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","TargetShort"), 0)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","DebugShort"), 1)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","ThreadShort"), 2)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","AsmShort"), 3)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","OnErrorShort"), 4)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","CompileCountShort"), 5)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","BuildCountShort"), 6)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","FormatShort"), 7)
    SetGadgetItemText(#GADGET_ProjectInfo_Targets, -1, Language("Project","InputFile"), 8)
    
    ; to autosize the columns on Windows
    ResizeProjectInfo(GadgetWidth(#GADGET_ProjectInfo), GadgetHeight(#GADGET_ProjectInfo))
    
    ; Theme icons and content get changed in a normal update
    UpdateProjectInfo()
  EndIf
EndProcedure

; Enter key handling for project file & target list
; For Windows this is done when handling the #MENU_Scintilla_Enter shortcut in UserInterface.pb
CompilerIf #CompileLinuxGtk
  ProcedureC ProjectInfo_EnterKeyHandler(*Widget, *Event.GdkEventKey, Gadget)
    Debug "Key event: " + *Event\keyval
    If *Event\keyval = #GDK_Return
      PostEvent(#PB_Event_Gadget, #WINDOW_Main, Gadget, #PB_EventType_LeftDoubleClick)
      
    ElseIf *Event\keyval = $FE20 ; #GDK_LeftTab
      If (*Event\state & (1 << 2)) ; Ctrl
        If (*Event\state & 1) ; Shift
          If KeyboardShortcuts(#MENU_NextOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_Tab
            ;ChangeCurrentFile(0)
            PostEvent(#PB_Event_Menu, #WINDOW_Main, #MENU_NextOpenedFile)
          ElseIf KeyboardShortcuts(#MENU_PreviousOpenedFile) = #PB_Shortcut_Control|#PB_Shortcut_Shift|#PB_Shortcut_Tab
            ;ChangeCurrentFile(1)
            PostEvent(#PB_Event_Menu, #WINDOW_Main, #MENU_PreviousOpenedFile)
          EndIf
        EndIf
      EndIf
      
    EndIf
  EndProcedure
CompilerEndIf


Procedure AddProjectInfo()
  If *ProjectInfo = 0
    
    ; The Project info is always at the beginning
    FirstElement(FileList())
    *ProjectInfo = InsertElement(FileList())
    
    If *ProjectInfo
      
      OpenGadgetList(#GADGET_SourceContainer)
      
      ; Create the ProjectInfo gadgets
      ;
      ContainerGadget(#GADGET_ProjectInfo, 0, 0, 0, 0, #PB_Container_Double)
      FrameGadget(#GADGET_ProjectInfo_FrameProject, 0, 0, 0, 0, Language("Project","ProjectInfo"))
      CompilerIf #CompileWindows
        ProjectInfoFlags = #SS_LEFTNOWORDWRAP
      CompilerEndIf
      TextGadget(#GADGET_ProjectInfo_Info, 0, 0, 0, 0, "", ProjectInfoFlags)
      ButtonGadget(#GADGET_ProjectInfo_OpenOptions, 0, 0, 0, 0, Language("Project","ProjectOptions"))
      ButtonGadget(#GADGET_ProjectInfo_OpenCompilerOptions, 0, 0, 0, 0, Language("Project","CompilerOptions"))
      
      FrameGadget(#GADGET_ProjectInfo_FrameFiles, 0, 0, 0, 0, Language("Project","FileTab"))
      ListIconGadget(#GADGET_ProjectInfo_Files, 0, 0, 300, 0, Language("Project","Filename"), 300, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect|#PB_ListIcon_MultiSelect)
      AddGadgetColumn(#GADGET_ProjectInfo_Files, 1, Language("Project","FileLoadShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Files, 2, Language("Project","FileWarnShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Files, 3, Language("Project","FileScanShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Files, 4, Language("Project","FilePanelShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Files, 5, Language("Project","FileSize"), 80)
      AddGadgetColumn(#GADGET_ProjectInfo_Files, 6, Language("Project","FileModified"), 60)
      
      CompilerIf #CompileWindows
        ; Make the settings columns centered for a better look
        For i = 1 To 4
          column.LVCOLUMN\mask = #LVCF_FMT
          column\fmt = #LVCFMT_CENTER
          SendMessage_(GadgetID(#GADGET_ProjectInfo_Files), #LVM_SETCOLUMN, i, @column)
        Next i
      CompilerEndIf
      
      FrameGadget(#GADGET_ProjectInfo_FrameTargets, 0, 0, 0, 0, Language("Project","ProjectTargets"))
      ListIconGadget(#GADGET_ProjectInfo_Targets, 0, 0, 200, 0, Language("Project","TargetShort"), 200, #PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 1, Language("Project","DebugShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 2, Language("Project","ThreadShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 3, Language("Project","AsmShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 4, Language("Project","OnErrorShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 5, Language("Project","CompileCountShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 6, Language("Project","BuildCountShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 7, Language("Project","FormatShort"), 60)
      AddGadgetColumn(#GADGET_ProjectInfo_Targets, 8, Language("Project","InputFile"), 200)
      
      CompilerIf #CompileLinuxGtk
        GTKSignalConnect(GadgetID(#GADGET_ProjectInfo_Files), "key-press-event", @ProjectInfo_EnterKeyHandler(), #GADGET_ProjectInfo_Files)
        GTKSignalConnect(GadgetID(#GADGET_ProjectInfo_Targets), "key-press-event", @ProjectInfo_EnterKeyHandler(), #GADGET_ProjectInfo_Targets)
      CompilerEndIf
      
      CompilerIf #CompileWindows
        ; Make the settings columns centered for a better look
        For i = 1 To 7
          column.LVCOLUMN\mask = #LVCF_FMT
          column\fmt = #LVCFMT_CENTER
          SendMessage_(GadgetID(#GADGET_ProjectInfo_Targets), #LVM_SETCOLUMN, i, @column)
        Next i
      CompilerEndIf
      
      CloseGadgetList()
      HideGadget(#GADGET_ProjectInfo, 1)
      
      ProjectInfoFrameHeight = Max(GadgetHeight(#GADGET_ProjectInfo_FrameProject, #PB_Gadget_RequiredSize) + 3, 10)
      
      ; *ActiveSource is modified in CreateEditorGadget()
      *RealActiveSource = *ActiveSource
      
      ; This creates a full Scintilla with the big callback, but it is never shown,
      ; and so it doesn't matter. This way, the code that expects a Scintilla to be
      ; present will work without crashing
      ;
      CreateEditorGadget()
      HideEditorGadget(*ProjectInfo\EditorGadget, 1) ; this is never visible
      
      ; Back to the active source.
      *ActiveSource = *RealActiveSource
      
      CloseGadgetList()
      
      ; Note:
      ;   The TabBarGadget cannot handle an Add with a number beyond the count of items
      ;   Probably a bug that should be fixed there. But this workaround will do the trick
      If CountTabBarGadgetItems(#GADGET_FilesPanel) = 0
        ; first item, use #PB_Default
        AddTabBarGadgetItem(#GADGET_FilesPanel, #PB_Default, Language("Project", "TabTitle") + " [" + ProjectName$ + "]")
      Else
        ; items exist: using 0 works
        AddTabBarGadgetItem(#GADGET_FilesPanel, 0, Language("Project", "TabTitle") + " [" + ProjectName$ + "]")
      EndIf
      
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, 0, #PB_Gadget_FrontColor, #COLOR_FilePanelFront)
      SetTabBarGadgetItemColor(#GADGET_FilesPanel, 0, #PB_Gadget_BackColor, #COLOR_ProjectInfo)
      
      SetTabBarGadgetItemImage(#GADGET_FilesPanel, 0, OptionalImageID(#IMAGE_FilePanel_Project))
      
      UpdateProjectInfo()
      ResizeMainWindow()
    EndIf
  EndIf
EndProcedure

Procedure RemoveProjectInfo()
  If *ProjectInfo
    Gadget = *ProjectInfo\EditorGadget
    
    ChangeCurrentElement(FileList(), *ProjectInfo)
    Index = ListIndex(FileList())
    DeleteElement(FileList())
    
    If *ActiveSource = *ProjectInfo ; currently visible
      FirstElement(FileList())
      *ActiveSource = 0
    Else
      ChangeCurrentElement(FileList(), *ActiveSource)
    EndIf
    
    RemoveTabBarGadgetItem(#GADGET_FilesPanel, Index)
    
    ; Its important to 0 this before the next ChangeActiveSourcecode()
    *ProjectInfo = 0
    
    ChangeActiveSourcecode()
    FreeEditorGadget(Gadget)
    
    If *ActiveSource
      SetActiveGadget(*ActiveSource\EditorGadget)
    EndIf
    
    FreeGadget(#GADGET_ProjectInfo)
  EndIf
EndProcedure

; Check the project version on the XML
; returns true/false to load/not load
;
Procedure CheckProjectVersion(Filename$)
  
  VersionString$ = GetXMLAttribute(MainXMLNode(#XML_LoadProject), "version")
  Creator$       = GetXMLAttribute(MainXMLNode(#XML_LoadProject), "creator")
  
  version = Int(ValD(VersionString$) * 100.0)
  If GetXMLAttribute(MainXMLNode(#XML_LoadProject), "minversion") = ""
    minversion = 0
  Else
    minversion = Int(ValD(GetXMLAttribute(MainXMLNode(#XML_LoadProject), "minversion")) * 100.0)
  EndIf
  
  If version < #Project_Version
    Text$ = Language("Project","VersionLow") + #NewLine
    Text$ + #NewLine + Language("Project","ProjectFile") + ": " + Filename$ + #NewLine
    Text$ + Language("Project","ProjectVersion") + ": " + VersionString$ + #NewLine
    Text$ + Language("Project","CurrentVersion") + ": " + #Project_VersionString + #NewLine
    Text$ + Language("Project","LastWrittenBy")  + ": " + Creator$ + #NewLine
    If CommandlineBuild = 0
      Text$ + #NewLine + Language("Project", "LoadAnyway")
      If MessageRequester(Language("Project","TitleShort"), Text$, #FLAG_Question|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
        ProcedureReturn #False
      EndIf
    Else
      PrintN(Text$)
      ProcedureReturn #False
    EndIf
    
    
  ElseIf version > #Project_Version And minversion <= #Project_Version
    Text$ = Language("Project","VersionHigh") + #NewLine
    Text$ + #NewLine + Language("Project","ProjectFile") + ": " + Filename$ + #NewLine
    Text$ + Language("Project","ProjectVersion") + ": " + VersionString$ + #NewLine
    Text$ + Language("Project","CurrentVersion") + ": " + #Project_VersionString + #NewLine
    Text$ + Language("Project","LastWrittenBy")  + ": " + Creator$ + #NewLine
    If CommandlineBuild = 0
      Text$ + #NewLine + Language("Project", "LoadAnyway")
      If MessageRequester(Language("Project","TitleShort"), Text$, #FLAG_Question|#PB_MessageRequester_YesNo) = #PB_MessageRequester_No
        ProcedureReturn #False
      EndIf
    Else
      PrintN(Text$)
      ProcedureReturn #False
    EndIf
    
  ElseIf version > #Project_Version
    Text$ = Language("Project","VersionTooHigh") + #NewLine
    Text$ + #NewLine + Language("Project","ProjectFile") + ": " + Filename$ + #NewLine
    Text$ + Language("Project","ProjectVersion") + ": " + VersionString$ + #NewLine
    Text$ + Language("Project","CurrentVersion") + ": " + #Project_VersionString + #NewLine
    Text$ + Language("Project","LastWrittenBy")  + ": " + Creator$
    
    If CommandlineBuild = 0
      MessageRequester(Language("Project","TitleShort"), Text$, #FLAG_Error)
    Else
      PrintN(Text$)
    EndIf
    ProcedureReturn #False
    
  EndIf
  
  ProcedureReturn #True
EndProcedure


; displays an error if it fails, returns true/false
;
Procedure LoadProject(Filename$)
  
  If IsProjectBusy = #True
    ProcedureReturn #False
  EndIf
  
  Error$  = ""
  Success = #False
  
  If IsProject And IsEqualFile(Filename$, ProjectFile$)
    ProcedureReturn #True ; there is no sense in reloading the project (it even causes trouble, as we load before we close/save)
  EndIf
  
  WarnFiles$ = "" ; files that were modified while closed
  
  ; Load the XML and validate the main node and namespace
  ;
  IsLoaded = 0
  If LoadXML(#XML_LoadProject, FileName$)
    If XMLStatus(#XML_LoadProject) = #PB_XML_Success And MainXMLNode(#XML_LoadProject)
      If ResolveXMLNodeName(MainXMLNode(#XML_LoadProject), "/") = #ProjectFileNamespace$ + "/project"
        IsLoaded = 1
      EndIf
    EndIf
  EndIf
  
  If IsLoaded
    
    If CheckProjectVersion(FileName$) And CloseProject() ; Close the previous project (If any). If the user cancel the previous project closing, we have to stop.
      Success = #True
      *Main   = MainXMLNode(#XML_LoadProject)
      
      IsProjectBusy = #True
      
      ; add new project to "Recent projects"
      ;
      If CommandlineBuild = 0
        RecentFiles_AddFile(FileName$, #True)
      EndIf
      
      ; Set the project default options, in case some key is not present
      IsProject         = 1
      IsProjectCreation = 0
      
      ProjectLastOpenDate    = 0
      ProjectLastOpenHost$   = ""
      ProjectLastOpenUser$   = ""
      ProjectLastOpenEditor$ = Xml_SingleLine(GetXMLAttribute(*Main, "creator"))
      
      ProjectFile$      = FileName$
      ProjectName$      = Language("Project","DefaultName")
      ProjectComments$  = ""
      ProjectCloseFiles = 1
      ProjectOpenMode   = #Project_Open_LoadLast
      ProjectShowLog    = 1
      AutoCloseBuildWindow = 0
      ResetList(ProjectFiles())
      
      BasePath$         = GetPathPart(FileName$)
      
      ; User-changable configuration
      ;
      *Config = GetSection(*Main, "config")
      If *Config
        *Options = XMLNodeFromPath(*Config, "options")
        If *Options
          ProjectName$      = Xml_SingleLine(GetXMLAttribute(*Options, "name"))
          ProjectCloseFiles = Xml_Boolean(GetXMLAttribute(*Options, "closefiles"), ProjectCloseFiles)
          ProjectOpenMode   = Xml_Integer(GetXMLAttribute(*Options, "openmode"))
        EndIf
        ProjectComments$  = Xml_MultiLine(ReadNode(*Config, "comment"))
        
        *BuildWindow = XMLNodeFromPath(*Config, "buildwindow")
        If *BuildWindow
          AutoCloseBuildWindow = Xml_Boolean(GetXMLAttribute(*BuildWindow, "autoclose"), AutoCloseBuildWindow)
        EndIf
      EndIf
      
      
      ; Automatically managed data
      ;
      *ConfigData = GetSection(*Main, "data")
      If *ConfigData
        *ViewPath = XMLNodeFromPath(*ConfigData, "explorer")
        If *ViewPath
          ProjectExplorerPath$   = ResolveRelativePath(BasePath$, Xml_SingleLine(GetXMLAttribute(*ViewPath, "view")))
          ProjectExplorerPattern = Xml_Integer(GetXMLAttribute(*ViewPath, "pattern"))
        EndIf
        
        *ShowLog = XMLNodeFromPath(*ConfigData, "log")
        If *ShowLog
          ProjectShowLog = Xml_Boolean(GetXMLAttribute(*ShowLog, "show"), ProjectShowLog)
        EndIf
        
        *LastOpen = XMLNodeFromPath(*ConfigData, "lastopen")
        If *LastOpen
          Date$ = XML_SingleLine(GetXMLAttribute(*LastOpen, "date"))
          If Date$ <> ""
            ProjectLastOpenDate = ParseDate("%yyyy-%mm-%dd %hh:%ii", Date$)
          EndIf
          
          ProjectLastOpenHost$ = Xml_SingleLine(GetXMLAttribute(*LastOpen, "host"))
          ProjectLastOpenUser$ = Xml_SingleLine(GetXMLAttribute(*LastOpen, "user"))
        EndIf
      EndIf
      
      ; This is important to set to 0 as when we load one of the project files below
      ; we have no target info yet, and this could be set from an old Project to an invalid address!
      ;
      *DefaultTarget = 0
      
      ; Project file list
      ; (load this even in commandline build mode, so the project is correctly saved back!)
      ;
      *Files = GetSection(*Main, "files")
      If *Files
        *File = ChildXMLNode(*Files)
        
        While *File
          If XMLNodeType(*File) = #PB_XML_Normal And GetXMLNodeName(*File) = "file"
            AddElement(ProjectFiles())
            ProjectFiles()\Filename$ = ResolveRelativePath(BasePath$, Xml_SingleLine(GetXMLAttribute(*File, "name")))
            
            *Config = XMLNodeFromPath(*File, "config")
            If *Config
              ProjectFiles()\AutoLoad    = Xml_Boolean(GetXMLAttribute(*Config, "load"))
              ProjectFiles()\AutoScan    = Xml_Boolean(GetXMLAttribute(*Config, "scan"))
              ProjectFiles()\ShowPanel   = Xml_Boolean(GetXMLAttribute(*Config, "panel"))
              ProjectFiles()\ShowWarning = Xml_Boolean(GetXMLAttribute(*Config, "warn"))
              ProjectFiles()\LastOpen    = Xml_Boolean(GetXMLAttribute(*Config, "lastopen"))
              ProjectFiles()\PanelState$ = Xml_SingleLine(GetXMLAttribute(*Config, "panelstate")) ; the default for this is "all open", so need no backward compatibility here
              ProjectFiles()\SortIndex   = Xml_Integer(GetXMLAttribute(*Config, "sortindex"))
            Else
              ProjectFiles()\AutoLoad    = 0
              ProjectFiles()\AutoScan    = IsCodeFile(ProjectFiles()\Filename$)
              ProjectFiles()\ShowPanel   = 1
              ProjectFiles()\ShowWarning = 1
              ProjectFiles()\LastOpen    = 0
              ProjectFiles()\PanelState$ = ""
              ProjectFiles()\SortIndex   = 999
            EndIf
            
            *Fingerprint = XMLNodeFromPath(*File, "fingerprint")
            If *Fingerprint
              ProjectFiles()\Md5$ = LCase(Xml_SingleLine(GetXMLAttribute(*Fingerprint, "md5")))
            EndIf
          EndIf
          
          *File = NextXMLNode(*File)
        Wend
        
      EndIf
      
      ; Project targets
      ;
      ClearList(ProjectTargets())
      
      *Targets = GetSection(*Main, "targets")
      If *Targets
        *Target = ChildXMLNode(*Targets)
        
        While *Target
          If XMLNodeType(*Target) = #PB_XML_Normal And GetXMLNodeName(*Target) = "target"
            AddElement(ProjectTargets())
            ProjectTargets()\ID = GetUniqueID()
            ProjectTargets()\IsProject = #True
            ProjectTargets()\IsEnabled = Xml_Boolean(GetXMLAttribute(*Target, "enabled"))
            ProjectTargets()\IsDefault = Xml_Boolean(GetXMLAttribute(*Target, "default"))
            ProjectTargets()\Name$     = Xml_SingleLine(GetXMLAttribute(*Target, "name"))
            
            ; loop through the entries
            ;
            *Entry = ChildXMLNode(*Target)
            While *Entry
              If XMLNodeType(*Entry) = #PB_XML_Normal
                Select GetXMLNodeName(*Entry)
                  Case "inputfile" :  ProjectTargets()\MainFile$         = Xml_SingleLine(GetXMLAttribute(*Entry, "value"))
                  Case "outputfile":  ProjectTargets()\OutputFile$       = Xml_SingleLine(GetXMLAttribute(*Entry, "value"))
                  Case "commandline": ProjectTargets()\Commandline$      = Xml_SingleLine(GetXMLAttribute(*Entry, "value"))
                  Case "executable":  ProjectTargets()\ExecutableName$   = ResolveRelativePath(BasePath$, Xml_SingleLine(GetXMLAttribute(*Entry, "value")))
                  Case "directory":   ProjectTargets()\CurrentDirectory$ = Xml_SingleLine(GetXMLAttribute(*Entry, "value"))
                  Case "subsystem":   ProjectTargets()\Subsystem$        = Xml_SingleLine(GetXMLAttribute(*Entry, "value"))
                  Case "linker":      ProjectTargets()\LinkerOptions$    = Xml_SingleLine(GetXMLAttribute(*Entry, "value"))
                  Case "watchlist":   ProjectTargets()\Watchlist$        = Xml_SingleLine(GetXMLNodeText(*Entry)) ; not stored as attribute as they may get big
                  Case "tools":       ProjectTargets()\EnabledTools$     = Xml_SingleLine(GetXMLNodeText(*Entry))
                    
                  Case "compiler"
                    ProjectTargets()\CustomCompiler = #True
                    ProjectTargets()\CompilerVersion$ = Xml_SingleLine(GetXMLAttribute(*Entry, "version"))
                    
                  Case "options"
                    ProjectTargets()\EnableASM     = Xml_Boolean(GetXMLAttribute(*Entry, "asm"))
                    ProjectTargets()\EnableThread  = Xml_Boolean(GetXMLAttribute(*Entry, "thread"))
                    ProjectTargets()\EnableXP      = Xml_Boolean(GetXMLAttribute(*Entry, "xpskin"))
                    ProjectTargets()\EnableWayland = Xml_Boolean(GetXMLAttribute(*Entry, "wayland"))
                    ProjectTargets()\EnableAdmin   = Xml_Boolean(GetXMLAttribute(*Entry, "admin"))
                    ProjectTargets()\EnableUser    = Xml_Boolean(GetXMLAttribute(*Entry, "user"))
                    ProjectTargets()\DPIAware      = Xml_Boolean(GetXMLAttribute(*Entry, "dpiaware"))
                    ProjectTargets()\DllProtection = Xml_Boolean(GetXMLAttribute(*Entry, "dllprotection"))
                    ProjectTargets()\SharedUCRT    = Xml_Boolean(GetXMLAttribute(*Entry, "shareducrt"))
                    ProjectTargets()\EnableOnError = Xml_Boolean(GetXMLAttribute(*Entry, "onerror"))
                    ProjectTargets()\Debugger      = Xml_Boolean(GetXMLAttribute(*Entry, "debug"))
                    ProjectTargets()\EnableUnicode = Xml_Boolean(GetXMLAttribute(*Entry, "unicode"))
                    ProjectTargets()\Optimizer     = Xml_Boolean(GetXMLAttribute(*Entry, "optimizer"))
                    
                    CompilerIf #SpiderBasic
                      ProjectTargets()\Optimizer    | Xml_Boolean(GetXMLAttribute(*Entry, "optimizejs")) ; backward compatibility (now named "optimizer")
                      ProjectTargets()\WebServerAddress$ = Xml_SingleLine(GetXMLAttribute(*Entry, "webserveraddress"))
                      ProjectTargets()\WindowTheme$  = Xml_SingleLine(GetXMLAttribute(*Entry, "windowtheme"))
                      ProjectTargets()\GadgetTheme$  = Xml_SingleLine(GetXMLAttribute(*Entry, "gadgettheme"))
                    CompilerEndIf
                    
                    CompilerIf #SpiderBasic
                    Case "export"
                      ProjectTargets()\WebAppName$            = Xml_SingleLine(GetXMLAttribute(*Entry, "webappname"))
                      ProjectTargets()\WebAppIcon$            = Xml_SingleLine(GetXMLAttribute(*Entry, "webappicon"))
                      ProjectTargets()\HtmlFilename$          = Xml_SingleLine(GetXMLAttribute(*Entry, "htmlfilename"))
                      ProjectTargets()\JavaScriptFilename$    = Xml_SingleLine(GetXMLAttribute(*Entry, "javascriptfilename"))
                      ProjectTargets()\JavaScriptPath$        = Xml_SingleLine(GetXMLAttribute(*Entry, "javascriptpath"))
                      ProjectTargets()\CopyJavaScriptLibrary  = Xml_Boolean   (GetXMLAttribute(*Entry, "copyjavascriptlibrary"))
                      ProjectTargets()\ExportCommandLine$     = Xml_SingleLine(GetXMLAttribute(*Entry, "exportcommandline"))
                      ProjectTargets()\ExportArguments$       = Xml_SingleLine(GetXMLAttribute(*Entry, "exportarguments"))
                      ProjectTargets()\EnableResourceDirectory = Xml_Boolean   (GetXMLAttribute(*Entry, "enableresourcedirectory"))
                      ProjectTargets()\ResourceDirectory$     = Xml_SingleLine(GetXMLAttribute(*Entry, "resourcedirectory"))
                      ProjectTargets()\WebAppEnableDebugger   = Xml_Boolean   (GetXMLAttribute(*Entry, "webappenabledebugger"))
                      
                      ProjectTargets()\iOSAppName$         = Xml_SingleLine(GetXMLAttribute(*Entry, "iosappname"))
                      ProjectTargets()\iOSAppIcon$         = Xml_SingleLine(GetXMLAttribute(*Entry, "iosappicon"))
                      ProjectTargets()\iOSAppVersion$      = Xml_SingleLine(GetXMLAttribute(*Entry, "iosappversion"))
                      ProjectTargets()\iOSAppPackageID$    = Xml_SingleLine(GetXMLAttribute(*Entry, "iosapppackageid"))
                      ProjectTargets()\iOSAppStartupImage$ = Xml_SingleLine(GetXMLAttribute(*Entry, "iosappstartupimage"))
                      ProjectTargets()\iOSAppOrientation   = Val(Xml_SingleLine(GetXMLAttribute(*Entry, "iosapporientation")))
                      ProjectTargets()\iOSAppFullScreen    = Xml_Boolean   (GetXMLAttribute(*Entry, "iosappfullscreen"))
                      ProjectTargets()\iOSAppOutput$       = Xml_SingleLine(GetXMLAttribute(*Entry, "iosappoutput"))
                      ProjectTargets()\iOSAppAutoUpload    = Xml_Boolean   (GetXMLAttribute(*Entry, "iosappautoupload"))
                      ProjectTargets()\iOSAppEnableResourceDirectory = Xml_Boolean   (GetXMLAttribute(*Entry, "iosappenableresourcedirectory"))
                      ProjectTargets()\iOSAppResourceDirectory$      = Xml_SingleLine(GetXMLAttribute(*Entry, "iosappresourcedirectory"))
                      ProjectTargets()\iOSAppEnableDebugger   = Xml_Boolean   (GetXMLAttribute(*Entry, "iosappenabledebugger"))
                      ProjectTargets()\iOSAppKeepAppDirectory = Xml_Boolean   (GetXMLAttribute(*Entry, "iosappkeepappdirectory"))
                      
                      ProjectTargets()\AndroidAppName$         = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappname"))
                      ProjectTargets()\AndroidAppIcon$         = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappicon"))
                      ProjectTargets()\AndroidAppVersion$      = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappversion"))
                      ProjectTargets()\AndroidAppCode          = Xml_Integer(GetXMLAttribute(*Entry, "androidappcode"))
                      ProjectTargets()\AndroidAppPackageID$    = Xml_SingleLine(GetXMLAttribute(*Entry, "androidapppackageid"))
                      ProjectTargets()\AndroidAppIAPKey$       = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappiapkey"))
                      ProjectTargets()\AndroidAppStartupImage$ = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappstartupimage"))
                      ProjectTargets()\AndroidAppStartupColor$ = Xml_SingleLine(GetXMLAttribute(*Entry, "androidstartupcolor"))
                      ProjectTargets()\AndroidAppOrientation   = Val(Xml_SingleLine(GetXMLAttribute(*Entry, "androidapporientation")))
                      ProjectTargets()\AndroidAppFullScreen    = Xml_Boolean   (GetXMLAttribute(*Entry, "androidappfullscreen"))
                      ProjectTargets()\AndroidAppOutput$       = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappoutput"))
                      ProjectTargets()\AndroidAppAutoUpload    = Xml_Boolean   (GetXMLAttribute(*Entry, "androidappautoupload"))
                      ProjectTargets()\AndroidAppEnableResourceDirectory = Xml_Boolean   (GetXMLAttribute(*Entry, "androidappenableresourcedirectory"))
                      ProjectTargets()\AndroidAppResourceDirectory$      = Xml_SingleLine(GetXMLAttribute(*Entry, "androidappresourcedirectory"))
                      ProjectTargets()\AndroidAppEnableDebugger   = Xml_Boolean   (GetXMLAttribute(*Entry, "androidappenabledebugger"))
                      ProjectTargets()\AndroidAppKeepAppDirectory = Xml_Boolean   (GetXMLAttribute(*Entry, "androidappkeepappdirectory"))
                      ProjectTargets()\AndroidAppInsecureFileMode = Xml_Boolean   (GetXMLAttribute(*Entry, "androidappinsecurefilemode"))
                    CompilerEndIf
                    
                  Case "purifier"
                    ProjectTargets()\EnablePurifier = Xml_Boolean(GetXMLAttribute(*Entry, "enable"))
                    ProjectTargets()\PurifierGranularity$ = Xml_SingleLine(GetXMLAttribute(*Entry, "granularity"))
                    
                  Case "temporaryexe"
                    If LCase(Xml_SingleLine(GetXMLAttribute(*Entry, "value"))) = "source"
                      ProjectTargets()\TemporaryExePlace = 1
                    EndIf
                    
                  Case "icon"
                    ProjectTargets()\IconName$ = Xml_SingleLine(GetXMLNodeText(*Entry))
                    ProjectTargets()\UseIcon   = Xml_Boolean(GetXMLAttribute(*Entry, "enable"))
                    
                  Case "format"
                    Select GetXMLAttribute(*Entry, "exe")
                      Case "console": ProjectTargets()\ExecutableFormat = 1
                      Case "dll"    : ProjectTargets()\ExecutableFormat = 2
                      Default       : ProjectTargets()\ExecutableFormat = 0
                    EndSelect
                    ProjectTargets()\CPU = Xml_Integer(GetXMLAttribute(*Entry, "cpu"))
                    
                  Case "debugger"
                    ProjectTargets()\CustomDebugger = Xml_Boolean(GetXMLAttribute(*Entry, "custom"))
                    Select GetXMLAttribute(*Entry, "type")
                      Case "standalone": ProjectTargets()\DebuggerType = 2
                      Case "console"   : ProjectTargets()\DebuggerType = 3
                      Default          : ProjectTargets()\DebuggerType = 1
                    EndSelect
                    
                  Case "warnings"
                    ProjectTargets()\CustomWarning = Xml_Boolean(GetXMLAttribute(*Entry, "custom"))
                    Select GetXMLAttribute(*Entry, "type")
                      Case "ignore": ProjectTargets()\WarningMode = 0
                      Case "error" : ProjectTargets()\WarningMode = 2
                      Default      : ProjectTargets()\WarningMode = 1
                    EndSelect
                    
                  Case "compilecount"
                    ProjectTargets()\UseCompileCount = Xml_Boolean(GetXMLAttribute(*Entry, "enable"))
                    ProjectTargets()\CompileCount    = Xml_Integer(GetXMLAttribute(*Entry, "value"))
                    
                  Case "buildcount"
                    ProjectTargets()\UseBuildCount = Xml_Boolean(GetXMLAttribute(*Entry, "enable"))
                    ProjectTargets()\BuildCount    = Xml_Integer(GetXMLAttribute(*Entry, "value"))
                    
                  Case "execonstant"
                    ProjectTargets()\UseCreateExe = Xml_Boolean(GetXMLAttribute(*Entry, "enable"))
                    
                  Case "versioninfo"
                    ProjectTargets()\VersionInfo = Xml_Boolean(GetXMLAttribute(*Entry, "enable"))
                    For i = 0 To 23
                      *Field = XMLNodeFromPath(*Entry, "field"+Str(i))
                      If *Field
                        ProjectTargets()\VersionField$[i] = Xml_SingleLine(GetXMLAttribute(*Field, "value")) ; the stuff is stored, even if disabled
                      EndIf
                    Next i
                    
                  Case "resources"
                    *Resource = ChildXMLNode(*Entry)
                    While *Resource And ProjectTargets()\NbResourceFiles < #MAX_ResourceFiles
                      If XMLNodeType(*Resource) = #PB_XML_Normal And GetXMLNodeName(*Resource) = "resource"
                        ProjectTargets()\ResourceFiles$[ProjectTargets()\NbResourceFiles] = Xml_SingleLine(GetXMLAttribute(*Resource, "value"))
                        ProjectTargets()\NbResourceFiles + 1
                      EndIf
                      *Resource = NextXMLNode(*Resource)
                    Wend
                    
                  Case "constants"
                    *Constant = ChildXMLNode(*Entry)
                    While *Constant And ProjectTargets()\NbConstants < #MAX_Constants
                      If XMLNodeType(*Constant) = #PB_XML_Normal And GetXMLNodeName(*Constant) = "constant"
                        ProjectTargets()\Constant$[ProjectTargets()\NbConstants] = Xml_SingleLine(GetXMLAttribute(*Constant, "value"))
                        ProjectTargets()\ConstantEnabled[ProjectTargets()\NbConstants] = Xml_Boolean(GetXMLAttribute(*Constant, "enable"))
                        ProjectTargets()\NbConstants + 1
                      EndIf
                      *Constant = NextXMLNode(*Constant)
                    Wend
                    
                EndSelect
              EndIf
              
              *Entry = NextXMLNode(*Entry)
            Wend
            
            ; Set the *Target\FileName$ field correctly (for compilation)
            ProjectTargets()\FileName$ = ResolveRelativePath(BasePath$, ProjectTargets()\MainFile$)
            
          EndIf
          
          *Target = NextXMLNode(*Target)
        Wend
      EndIf
      
      ; Ensure that there is a default target (create on if there are no targets)
      SetProjectDefaultTarget()
      
      If ProjectOpenMode = #Project_Open_LoadMain And CommandlineBuild = 0
        ; open the mainfile of the default target only
        If *DefaultTarget And *DefaultTarget\MainFile$
          LoadSourceFile(*DefaultTarget\FileName$) ; use the resolved path
        EndIf
      EndIf
      
      ; Sort project files according to their last position in the IDE
      SortStructuredList(ProjectFiles(), #PB_Sort_Ascending, OffsetOf(ProjectFile\SortIndex), #PB_Long)
      
      If CommandlineBuild = 0
        
        ; add our special project info tab
        AddProjectInfo()
        
        ; Link any previously open files to the project (do it before loading the project files as it's faster)
        ForEach FileList()
          If @FileList() <> *ProjectInfo
            LinkSourceToProject(@FileList())
          EndIf
        Next FileList()
        
        ; really load all the project file (do it after adding the special project tab for better look)
        ForEach ProjectFiles()
          If FileSize(ProjectFiles()\FileName$) < 0
            If MessageRequester(#ProductName$, LanguagePattern("Project","FileMissing", "%filename%", ProjectFiles()\Filename$), #PB_MessageRequester_YesNo|#FLAG_Question) = #PB_MessageRequester_Yes
              NewFileName$ = OpenFileRequester(Language("FileStuff","OpenFileTitle"), ProjectFiles()\FileName$, Language("Compiler","AllFilesPattern"), 0)
              
              ; If the user aborts, keep the old filename. The file will not be scanable etc,
              ; but it will be saved back to the project file with all options so maybe it is
              ; present on a later run again
              ;
              If NewFileName$
                ProjectFiles()\FileName$ = NewFileName$
                
                PushListPosition(ProjectFiles())
                LoadSourceFile(ProjectFiles()\FileName$)
                
                ; Flush events. So when many sources are opened at once, the User can see a bit the
                ; progress, instead of just an unresponsive window for quite a while.
                ; There is almost no flicker anymore, so it actually looks quite good.
                ;
                ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
                FlushEvents()
                PopListPosition(ProjectFiles())
              EndIf
            EndIf
            
          Else
            If ProjectFiles()\ShowWarning And ProjectFiles()\Md5$ <> LCase(FileFingerprint(ProjectFiles()\FileName$, #PB_Cipher_MD5))
              WarnFiles$ + #NewLine + ProjectFiles()\FileName$
            EndIf
            
            If ProjectOpenMode = #Project_Open_LoadAll Or (ProjectOpenMode = #Project_Open_LoadLast And ProjectFiles()\LastOpen) Or (ProjectOpenMode = #Project_Open_LoadDefault And ProjectFiles()\AutoLoad)
              PushListPosition(ProjectFiles())
              LoadSourceFile(ProjectFiles()\FileName$, 1, 0) ; can change the ProjectFiles() index
              
              ; Flush events. So when many sources are opened at once, the User can see a bit the
              ; progress, instead of just an unresponsive window for quite a while.
              ; There is almost no flicker anymore, so it actually looks quite good.
              ;
              ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
              FlushEvents()
              PopListPosition(ProjectFiles())
            EndIf
          EndIf
          
          ; Update the data kept on this file (source link or scanned data)
          UpdateProjectFile(@ProjectFiles())
        Next
        
        ; Display our file warning (if any)
        If WarnFiles$ <> ""
          MessageRequester(#ProductName$, Language("Project", "FilesChanged")+":"+#NewLine+WarnFiles$, #FLAG_Warning)
        EndIf
        
        ; Update the menu to reflect the new target list
        StartFlickerFix(#WINDOW_Main)
        CreateIDEMenu()
        StopFlickerFix(#WINDOW_Main, 1)
        
        ; clear project log
        ClearList(ProjectLog())
        
        ; Check if there is any file open from the project
        ;
        *ProjectSource.SourceFile = 0
        ForEach FileList()
          If FileList()\ProjectFile
            If @FileList() = *ActiveSource
              *ProjectSource = *ActiveSource ; use this and do not look further
              Break
            Else
              *ProjectSource = @FileList() ; continue search to find the last one in the list
            EndIf
          EndIf
        Next FileList()
        ChangeCurrentElement(FileList(), *ActiveSource)
        
        ; if no files from the project are open now, select the Info source
        ;
        If *ProjectSource = 0
          FirstElement(FileList()) ; switch the Project Info
        Else
          ChangeCurrentElement(FileList(), *ProjectSource) ; switch to this source
        EndIf
        ChangeActiveSourceCode()
        
      EndIf
      
      IsProjectBusy = #False
      
    Else
      ;
      ; The loading fails here, but we do not display a requester, as the
      ; check already did that (to ask the user)
      ;
      FreeXML(#XML_LoadProject)
      ProcedureReturn #False
    EndIf
    
  EndIf
  
  If Success = #False
    If CommandlineBuild = 0
      MessageRequester(Language("Project","TitleShort"), Language("Project","LoadError")+#NewLine+FileName$, #FLAG_Error)
    Else
      PrintN(Language("Project","LoadError"))
      PrintN(FileName$)
    EndIf
  ElseIf CommandlineBuild = 0
    UpdateProjectPanel()
    UpdateMenuStates() ; updated project related menu stuff
    UpdateMainWindowTitle() ; put the project name in the title
  EndIf
  
  ; Can exist even on failure
  If IsXML(#XML_LoadProject)
    FreeXML(#XML_LoadProject)
  EndIf
  
  ProcedureReturn Success
EndProcedure


; displays an error if it fails, returns true/false
;
Procedure SaveProject(ShowErrors)
  
  ; The main layout of the project files is as follows:
  ;
  ; root: "project"
  ;  - xmlns     (required): "http://www.purebasic.com/namespace" (important as this is checked!)
  ;  - version   (required): project file version (starts with 1.0)
  ;  - minversion(optional): minimum compatible file version (some sections may be unreadable)
  ;  - creator   (required): full PB version string of the file creator
  ;
  ; inside root: "section"
  ;  - name      (required): section name
  ;  - minversion(optional): minimum file version compatible with the section
  ;
  ; The loading code supports the optional minversion parts from the first version on
  ; to ensure future compatibility where possible.
  ;
  ; The content of each such section depends on the section name.
  ; See the save code for more info on that
  
  BasePath$ = GetPathPart(ProjectFile$)
  Success   = #False
  
  If CreateXML(#XML_SaveProject, #PB_UTF8)
    
    ; Generate main node
    ;
    *Main = CreateXMLNode(RootXMLNode(#XML_SaveProject), "project")
    SetXMLAttribute(*Main, "xmlns",   #ProjectFileNamespace$)
    SetXMLAttribute(*Main, "version", #Project_VersionString)
    SetXMLAttribute(*Main, "creator", DefaultCompiler\VersionString$)
    
    ; User-changable configuration
    ;
    *Config = NewSection(*Main, "config")
    *Options = AppendNode(*Config, "options")
    SetXMLAttribute(*Options, "closefiles", Str(ProjectCloseFiles))
    SetXMLAttribute(*Options, "openmode",   Str(ProjectOpenMode))
    SetXMLAttribute(*Options, "name",       ProjectName$)
    
    If ProjectComments$
      AppendNode(*Config, "comment", ProjectComments$)
    EndIf
    
    If AutoCloseBuildWindow
      *BuildWindow = AppendNode(*Config, "buildwindow")
      SetXMLAttribute(*BuildWindow, "autoclose", "1")
    EndIf
    
    ; Automatically managed data
    ;
    *ConfigData = NewSection(*Main, "data")
    *ViewPath = AppendNode(*ConfigData, "explorer")
    SetXMLAttribute(*ViewPath, "view",    CreateRelativePath(BasePath$, ProjectExplorerPath$))
    SetXMLAttribute(*ViewPath, "pattern", Str(ProjectExplorerPattern))
    
    *Showlog = AppendNode(*ConfigData, "log")
    SetXMLAttribute(*ShowLog, "show", Str(ProjectShowLog))
    
    ; For the ProjectInfo
    ;
    *LastOpen = AppendNode(*ConfigData, "lastopen")
    SetXMLAttribute(*LastOpen, "date", FormatDate("%yyyy-%mm-%dd %hh:%ii", Date()))
    SetXMLAttribute(*LastOpen, "user", UserName())
    SetXMLAttribute(*LastOpen, "host", ComputerName())
    
    ; Project file list
    ;
    *Files = NewSection(*Main, "files")
    
    ; Make sure Project panel expanded states are up to date
    StoreProjectPanelStates()
    
    ForEach ProjectFiles()
      *File = AppendNode(*Files, "file")
      SetXMLAttribute(*File, "name", CreateRelativePath(BasePath$, ProjectFiles()\FileName$))
      
      *FileConfig = AppendNode(*File, "config")
      SetXMLAttribute(*FileConfig, "load",      Str(ProjectFiles()\AutoLoad))
      SetXMLAttribute(*FileConfig, "scan",      Str(ProjectFiles()\AutoScan))
      SetXMLAttribute(*FileConfig, "panel",     Str(ProjectFiles()\ShowPanel))
      SetXMLAttribute(*FileConfig, "warn",      Str(ProjectFiles()\ShowWarning))
      SetXMLAttribute(*FileConfig, "lastopen",  Str(ProjectFiles()\LastOpen))
      SetXMLAttribute(*FileConfig, "sortindex", Str(ProjectFiles()\SortIndex))
      
      If ProjectFiles()\ShowPanel
        SetXMLAttribute(*FileConfig, "panelstate", ProjectFiles()\PanelState$)
      EndIf
      
      ; files are saved in CloseProject() before this, so its ok
      If ProjectFiles()\ShowWarning
        *Fingerprint = AppendNode(*File, "fingerprint")
        SetXMLAttribute(*Fingerprint, "md5", FileFingerprint(ProjectFiles()\FileName$, #PB_Cipher_MD5))
      EndIf
    Next ProjectFiles()
    
    ; Project target list
    ; We only write keys that have non-default values to not blow up the file
    ;
    *Targets = NewSection(*Main, "targets")
    
    ForEach ProjectTargets()
      *Target = AppendNode(*Targets, "target")
      SetXMLAttribute(*Target, "name", ProjectTargets()\Name$)
      SetXMLAttribute(*Target, "enabled", Str(ProjectTargets()\IsEnabled))
      SetXMLAttribute(*Target, "default", Str(ProjectTargets()\IsDefault))
      
      ; these are always set
      *Node = AppendNode(*Target, "inputfile")
      SetXMLAttribute(*Node, "value", ProjectTargets()\MainFile$)
      
      *Node = AppendNode(*Target, "outputfile")
      SetXMLAttribute(*Node, "value", ProjectTargets()\OutputFile$)
      
      If ProjectTargets()\CustomCompiler
        *Node = AppendNode(*Target, "compiler")
        SetXMLAttribute(*Node, "version", ProjectTargets()\CompilerVersion$)
      EndIf
      
      If ProjectTargets()\CommandLine$
        *Node = AppendNode(*Target, "commandline")
        SetXMLAttribute(*Node, "value", ProjectTargets()\CommandLine$)
      EndIf
      If ProjectTargets()\ExecutableName$
        ; this is a full path, so make it relative
        *Node = AppendNode(*Target, "executable")
        SetXMLAttribute(*Node, "value", CreateRelativePath(BasePath$, ProjectTargets()\ExecutableName$))
      EndIf
      If ProjectTargets()\CurrentDirectory$
        *Node = AppendNode(*Target, "directory")
        SetXMLAttribute(*Node, "value", ProjectTargets()\CurrentDirectory$) ; It's already a relative path
      EndIf
      
      *Options = AppendNode(*Target, "options")
      If ProjectTargets()\EnableASM
        SetXMLAttribute(*Options, "asm",     "1")
      EndIf
      If ProjectTargets()\EnableUnicode
        ; write back the found value for compatibility with pre-5.50 versions
        SetXMLAttribute(*Options, "unicode", "1")
      EndIf
      If ProjectTargets()\EnableThread
        SetXMLAttribute(*Options, "thread",  "1")
      EndIf
      If ProjectTargets()\EnableXP
        SetXMLAttribute(*Options, "xpskin",  "1")
      EndIf
      If ProjectTargets()\EnableWayland
        SetXMLAttribute(*Options, "wayland",  "1")
      EndIf
      If ProjectTargets()\EnableAdmin
        SetXMLAttribute(*Options, "admin",   "1")
      EndIf
      If ProjectTargets()\EnableUser
        SetXMLAttribute(*Options, "user",    "1")
      EndIf
      If ProjectTargets()\DPIAware
        SetXMLAttribute(*Options, "dpiaware",  "1")
      EndIf
      If ProjectTargets()\DllProtection
        SetXMLAttribute(*Options, "dllprotection",  "1")
      EndIf
      If ProjectTargets()\SharedUCRT
        SetXMLAttribute(*Options, "shareducrt",  "1")
      EndIf
      If ProjectTargets()\EnableOnError
        SetXMLAttribute(*Options, "onerror", "1")
      EndIf
      If ProjectTargets()\Debugger
        SetXMLAttribute(*Options, "debug",   "1")
      EndIf
      
      SetXMLAttribute(*Options, "optimizer", Str(ProjectTargets()\Optimizer))
      
      CompilerIf #SpiderBasic
        SetXMLAttribute(*Options, "webserveraddress", ProjectTargets()\WebServerAddress$)
        SetXMLAttribute(*Options, "windowtheme"  , ProjectTargets()\WindowTheme$)
        SetXMLAttribute(*Options, "gadgettheme"  , ProjectTargets()\GadgetTheme$)
        
        ; Add a new "export" section
        ;
        *Export = AppendNode(*Target, "export")
        SetXMLAttribute(*Export, "webappname"         , ProjectTargets()\WebAppName$)       ; Node won't be created if the value is empty
        SetXMLAttribute(*Export, "webappicon"         , ProjectTargets()\WebAppIcon$)       ; Node won't be created if the value is empty
        SetXMLAttribute(*Export, "htmlfilename"       , ProjectTargets()\HtmlFilename$)     ; Node won't be created if the value is empty
        SetXMLAttribute(*Export, "javascriptfilename" , ProjectTargets()\JavaScriptFilename$) ;
        SetXMLAttribute(*Export, "javascriptpath"     , ProjectTargets()\JavaScriptPath$)
        SetXMLAttribute(*Export, "copyjavascriptlibrary"  , Str(ProjectTargets()\CopyJavaScriptLibrary))
        SetXMLAttribute(*Export, "exportcommandline"  , ProjectTargets()\ExportCommandLine$)
        SetXMLAttribute(*Export, "exportarguments"    , ProjectTargets()\ExportArguments$)
        SetXMLAttribute(*Export, "enableresourcedirectory"  , Str(ProjectTargets()\EnableResourceDirectory))
        SetXMLAttribute(*Export, "resourcedirectory"  , ProjectTargets()\ResourceDirectory$)  ; Node won't be created if the value is empty
        SetXMLAttribute(*Export, "webappenabledebugger", Str(ProjectTargets()\WebAppEnableDebugger))
        
        SetXMLAttribute(*Export, "iosappname"         , ProjectTargets()\iOSAppName$)
        SetXMLAttribute(*Export, "iosappicon"         , ProjectTargets()\iOSAppIcon$)
        SetXMLAttribute(*Export, "iosappversion"      , ProjectTargets()\iOSAppVersion$)
        SetXMLAttribute(*Export, "iosapppackageid"    , ProjectTargets()\iOSAppPackageID$)
        SetXMLAttribute(*Export, "iosappstartupimage" , ProjectTargets()\iOSAppStartupImage$)
        SetXMLAttribute(*Export, "iosapporientation"  , Str(ProjectTargets()\iOSAppOrientation))
        SetXMLAttribute(*Export, "iosappfullscreen"   , Str(ProjectTargets()\iOSAppFullScreen))
        SetXMLAttribute(*Export, "iosappoutput"       , ProjectTargets()\iOSAppOutput$)
        SetXMLAttribute(*Export, "iosappautoupload"   , Str(ProjectTargets()\iOSAppAutoUpload))
        SetXMLAttribute(*Export, "iosappenableresourcedirectory", Str(ProjectTargets()\iOSAppEnableResourceDirectory))
        SetXMLAttribute(*Export, "iosappresourcedirectory", ProjectTargets()\iOSAppResourceDirectory$)
        SetXMLAttribute(*Export, "iosappenabledebugger", Str(ProjectTargets()\iOSAppEnableDebugger))
        SetXMLAttribute(*Export, "iosappkeepappdirectory", Str(ProjectTargets()\iOSAppKeepAppDirectory))
        
        SetXMLAttribute(*Export, "androidappname"         , ProjectTargets()\AndroidAppName$)
        SetXMLAttribute(*Export, "androidappicon"         , ProjectTargets()\AndroidAppIcon$)
        SetXMLAttribute(*Export, "androidappversion"      , ProjectTargets()\AndroidAppVersion$)
        SetXMLAttribute(*Export, "androidappcode"         , Str(ProjectTargets()\AndroidAppCode))
        SetXMLAttribute(*Export, "androidapppackageid"    , ProjectTargets()\AndroidAppPackageID$)
        SetXMLAttribute(*Export, "androidappiapkey"       , ProjectTargets()\AndroidAppIAPKey$)
        SetXMLAttribute(*Export, "androidappstartupimage" , ProjectTargets()\AndroidAppStartupImage$)
        SetXMLAttribute(*Export, "androidappstartupcolor" , ProjectTargets()\AndroidAppStartupColor$)
        SetXMLAttribute(*Export, "androidapporientation"  , Str(ProjectTargets()\AndroidAppOrientation))
        SetXMLAttribute(*Export, "androidappfullscreen"   , Str(ProjectTargets()\AndroidAppFullScreen))
        SetXMLAttribute(*Export, "androidappoutput"       , ProjectTargets()\AndroidAppOutput$)
        SetXMLAttribute(*Export, "androidappautoupload"   , Str(ProjectTargets()\AndroidAppAutoUpload))
        SetXMLAttribute(*Export, "androidappenableresourcedirectory", Str(ProjectTargets()\AndroidAppEnableResourceDirectory))
        SetXMLAttribute(*Export, "androidappresourcedirectory", ProjectTargets()\AndroidAppResourceDirectory$)
        SetXMLAttribute(*Export, "androidappenabledebugger", Str(ProjectTargets()\AndroidAppEnableDebugger))
        SetXMLAttribute(*Export, "androidappkeepappdirectory", Str(ProjectTargets()\AndroidAppKeepAppDirectory))
        SetXMLAttribute(*Export, "androidappinsecurefilemode", Str(ProjectTargets()\AndroidAppInsecureFileMode))
        
      CompilerEndIf
      
      If ProjectTargets()\EnablePurifier Or ProjectTargets()\PurifierGranularity$
        *Purifier = AppendNode(*Target, "purifier")
        SetXMLAttribute(*Purifier, "enable", Str(ProjectTargets()\EnablePurifier))
        
        If ProjectTargets()\PurifierGranularity$
          SetXMLAttribute(*Purifier, "granularity", ProjectTargets()\PurifierGranularity$)
        EndIf
      EndIf
      
      If ProjectTargets()\TemporaryExePlace
        *Node = AppendNode(*Target, "temporaryexe")
        SetXMLAttribute(*Node, "value", "source")
      EndIf
      
      If ProjectTargets()\Subsystem$
        *Node = AppendNode(*Target, "subsystem")
        SetXMLAttribute(*Node, "value", ProjectTargets()\Subsystem$)
      EndIf
      
      If ProjectTargets()\LinkerOptions$
        *Node = AppendNode(*Target, "linker")
        SetXMLAttribute(*Node, "value", ProjectTargets()\LinkerOptions$)
      EndIf
      
      If ProjectTargets()\IconName$ Or ProjectTargets()\UseIcon
        *Icon = AppendNode(*Target, "icon", ProjectTargets()\IconName$)
        SetXMLAttribute(*Icon, "enable", Str(ProjectTargets()\UseIcon))
      EndIf
      
      If ProjectTargets()\ExecutableFormat <> 0 Or ProjectTargets()\CPU <> 0
        *Format = AppendNode(*Target, "format")
        Select ProjectTargets()\ExecutableFormat
          Case 0: SetXMLAttribute(*Format, "exe", "default")
          Case 1: SetXMLAttribute(*Format, "exe", "console")
          Case 2: SetXMLAttribute(*Format, "exe", "dll")
        EndSelect
        SetXMLAttribute(*Format, "cpu", Str(ProjectTargets()\CPU))
      EndIf
      
      If ProjectTargets()\CustomDebugger
        *Debugger = AppendNode(*Target, "debugger")
        SetXMLAttribute(*Debugger, "custom", "1")
        Select ProjectTargets()\DebuggerType
          Case 1: SetXMLAttribute(*Debugger, "type", "ide")
          Case 2: SetXMLAttribute(*Debugger, "type", "standalone")
          Case 3: SetXMLAttribute(*Debugger, "type", "console")
        EndSelect
      EndIf
      
      If ProjectTargets()\CustomWarning
        *Warnings = AppendNode(*Target, "warnings")
        SetXMLAttribute(*Warnings, "custom", "1")
        Select ProjectTargets()\WarningMode
          Case 0: SetXMLAttribute(*Warnings, "type", "ignore")
          Case 1: SetXMLAttribute(*Warnings, "type", "display")
          Case 2: SetXMLAttribute(*Warnings, "type", "error")
        EndSelect
      EndIf
      
      If ProjectTargets()\UseCompileCount Or ProjectTargets()\CompileCount <> 0
        *CompileCount = AppendNode(*Target, "compilecount")
        SetXMLAttribute(*CompileCount, "enable", Str(ProjectTargets()\UseCompileCount))
        SetXMLAttribute(*CompileCount, "value", Str(ProjectTargets()\CompileCount))
      EndIf
      
      If ProjectTargets()\UseBuildCount Or ProjectTargets()\BuildCount <> 0
        *BuildCount = AppendNode(*Target, "buildcount")
        SetXMLAttribute(*BuildCount, "enable", Str(ProjectTargets()\UseBuildCount))
        SetXMLAttribute(*BuildCount, "value", Str(ProjectTargets()\BuildCount))
      EndIf
      
      If ProjectTargets()\UseCreateExe
        *CreateExe = AppendNode(*Target, "execonstant")
        SetXMLAttribute(*CreateExe, "enable", "1")
      EndIf
      
      WriteVersion = ProjectTargets()\VersionInfo
      If ProjectTargets()\VersionInfo
        ; still include the version info if it is non-empty, even if disabled
        For i = 0 To 23
          If ProjectTargets()\VersionField$[i] <> ""
            WriteVersion = 1
            Break
          EndIf
        Next i
      EndIf
      
      If WriteVersion
        *Version = AppendNode(*Target, "versioninfo")
        SetXMLAttribute(*Version, "enable", Str(ProjectTargets()\VersionInfo))
        For i = 0 To 23
          If ProjectTargets()\VersionField$[i] <> ""
            *Node = AppendNode(*Version, "field"+Str(i))
            SetXMLAttribute(*Node, "value", ProjectTargets()\VersionField$[i])
          EndIf
        Next i
      EndIf
      
      If ProjectTargets()\NbResourceFiles > 0
        *Resources = AppendNode(*Target, "resources")
        For i = 0 To ProjectTargets()\NbResourceFiles-1
          *Node = AppendNode(*Resources, "resource")
          SetXMLAttribute(*Node, "value", ProjectTargets()\ResourceFiles$[i])
        Next i
      EndIf
      
      If ProjectTargets()\NbConstants > 0
        *Constants = AppendNode(*Target, "constants")
        For i = 0 To ProjectTargets()\NbConstants-1
          *Constant = AppendNode(*Constants, "constant")
          SetXMLAttribute(*Constant, "value", ProjectTargets()\Constant$[i])
          SetXMLAttribute(*Constant, "enable", Str(ProjectTargets()\ConstantEnabled[i]))
        Next i
      EndIf
      
      If ProjectTargets()\Watchlist$
        AppendNode(*Target, "watchlist", ProjectTargets()\Watchlist$)
      EndIf
      
      If ProjectTargets()\EnabledTools$
        AppendNode(*Target, "tools", ProjectTargets()\EnabledTools$)
      EndIf
    Next ProjectTargets()
    
    ; Format the project to a more readable format
    ;
    FormatXML(#XML_SaveProject, #PB_XML_ReFormat, 2)
    
    ; Save the file
    ;
    If SaveXML(#XML_SaveProject, ProjectFile$)
      Success = #True
    EndIf
    
    FreeXML(#XML_SaveProject)
  EndIf
  
  If Success = #False And ShowErrors
    MessageRequester(Language("Project", "TitleShort"), Language("Project", "SaveError"), #FLAG_Error)
  EndIf
  
  ProcedureReturn Success
EndProcedure

Procedure OpenProject()
  
  If IsProjectBusy = #True
    ProcedureReturn
  EndIf
  
  If IsProjectCreation = 0
    
    If IsProject
      Path$ = GetPathPart(ProjectFile$)
    ElseIf *ActiveSource\FileName$
      Path$ = GetPathPart(*ActiveSource\FileName$)
    Else
      Path$ = SourcePath$
    EndIf
    
    FileName$ = OpenFileRequester(Language("Project","TitleOpen"), Path$, Language("Project","Pattern"), 0)
    If FileName$ <> ""
      LoadProject(FileName$) ; closes the old project if still open
    EndIf
    
  EndIf
  
EndProcedure

Procedure CloseProject(IsIDEShutdown = #False)
  
  ; If project is busy loading, don't allow close (prevents crash)
  If (IsProjectBusy = #True) And (IsIDEShutdown = #False)
    ProcedureReturn #False
  EndIf
  
  If IsProject
    
    IsProjectBusy = #True
    
    ; close options
    If IsWindow(#WINDOW_ProjectOptions)
      ProjectOptionsEvents(#PB_Event_CloseWindow)
    EndIf
    
    If IsWindow(#WINDOW_Option)
      ; close these only if they belong to the project (ie there is a project code open)
      If *ActiveSource\ProjectFile
        OptionWindowEvents(#PB_Event_CloseWindow)
      EndIf
    EndIf
    
    
    If IsWindow(#WINDOW_Build)
      BuildWindowEvents(#PB_Event_CloseWindow)
    EndIf
    
    ; Is there a debugger running for the project ?
    ;
    *Debugger.DebuggerData = FindDebuggerFromID(ProjectDebuggerID)
    If *Debugger
      Debugger_Kill(*Debugger)
    EndIf
    
    ; Update the "last open" state of all project files
    ;
    ForEach ProjectFiles()
      If ProjectFiles()\Source
        ProjectFiles()\LastOpen = #True
        PushListPosition(FileList())
        ForEach FileList()
          If ProjectFiles()\FileName$ = FileList()\FileName$
            ProjectFiles()\SortIndex = ListIndex(FileList())
            Break
          EndIf
        Next
        PopListPosition(FileList())
      Else
        ProjectFiles()\LastOpen = #False
        ProjectFiles()\SortIndex = 999
      EndIf
    Next ProjectFiles()
    
    If ProjectCloseFiles
      *RealActiveSource = *ActiveSource
      
      ; do not walk the FileList() as it gets modified when removing a source
      ForEach ProjectFiles()
        If ProjectFiles()\Source
          If *RealActiveSource = *ActiveSource
            *RealActiveSource = 0 ; we cannot switch back to this as it will be removed
          EndIf
          
          ; RemoveSource() can trigger a walk of the ProjectFiles() list too,
          ; So save/restore the position
          *ProjectFile = @ProjectFiles()
          
          ; save/close all codes that belong To the project If the option is set
          ; NOTE: On IDE shutdown this is done already anyway, so do not do it again
          ;   as the "do you want to save" question was already asked then (but the code not closed yet)
          ;
          If IsIDEShutdown Or CheckSourceSaved(ProjectFiles()\Source) = 1
            RemoveSource(ProjectFiles()\Source)
          Else
            Cancelled = #True ; The user can press "Cancel" when a source has been modified in the project and it doesn't want to close the project anymore
            Break             ; abort, keep the last source the active one
          EndIf
          
          ChangeCurrentElement(ProjectFiles(), *ProjectFile)
        EndIf
      Next ProjectFiles()
      
      If *RealActiveSource
        ChangeCurrentElement(FileList(), *RealActiveSource)
        ChangeActiveSourcecode(*RealActiveSource)
      EndIf
    EndIf
    
    ; Don't close the main project panel if the close has been cancelled
    ;
    If Cancelled = #False
      ; unlink all codes (do not keep any data).
      ForEach FileList()
        If @FileList() <> *ProjectInfo
          UnlinkSourceFromProject(@FileList(), #False)
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource)
      
      ; Save the project, and do not close if this is impossible
      ; (also saves the "last open" state)
      If IsIDEShutdown
        Result = SaveProject(#False)
      Else
        Result = SaveProject(#True)
      EndIf
      
      If Result = #False
        IsProjectBusy = #False
        ProcedureReturn #False
      EndIf
      
      ; clean up the file list
      ForEach ProjectFiles()
        ClearProjectFile(@ProjectFiles())
      Next ProjectFiles()
      ClearList(ProjectFiles())
      
      ClearList(ProjectTargets())
      ClearList(ProjectLog())
      
      ; Important to set this to 0 as it points to invalid memory else and lead to problems
      *DefaultTarget = 0
      
      RemoveProjectInfo()
      
      IsProject = 0
      UpdateProjectPanel()
      UpdateMenuStates()
      UpdateMainWindowTitle() ; remove the project name from the title
      
      ; Update the menu to reflect the now empty target list
      StartFlickerFix(#WINDOW_Main)
      CreateIDEMenu()
      StopFlickerFix(#WINDOW_Main, 1)
    Else
      IsProjectBusy = #False
      ProcedureReturn #False ; The project has not been closed.
    EndIf
    
    IsProjectBusy = #False
  EndIf
  
  ProcedureReturn #True
EndProcedure


Procedure UpdateProjectOptionStates()
  
  NoAdd = 1
  If GetGadgetState(#GADGET_Project_Explorer) <> -1
    Last  = CountGadgetItems(#GADGET_Project_Explorer)-1
    
    For i = 0 To Last
      If GetGadgetItemState(#GADGET_Project_Explorer, i) & #PB_Explorer_Selected And GetGadgetItemText(#GADGET_Project_Explorer, i, 0) <> ".."
        NoAdd = 0
        Break
      EndIf
    Next i
  EndIf
  
  DisableGadget(#GADGET_Project_AddFile, NoAdd)
  
  Selected = 0
  FileLoad = 0
  FileScan = 0
  FileWarn = 0
  FilePanel = 0
  
  If GetGadgetState(#GADGET_Project_FileList) <> -1
    Last  = CountGadgetItems(#GADGET_Project_FileList)-1
    
    For i = 0 To Last
      If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
        *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
        Selected + 1
        
        If Selected = 1 ; its the first file, so just apply the state
          FileLoad  = *File\AutoLoad
          FileScan  = *File\AutoScan
          FileWarn  = *File\ShowWarning
          FilePanel = *File\ShowPanel
        Else ; apply the inconsistent state if an entry does not match
          If FileLoad <> *File\AutoLoad:    FileLoad = -1:  EndIf
          If FileScan <> *File\AutoScan:    FileScan = -1:  EndIf
          If FileWarn <> *File\ShowWarning: FileWarn = -1:  EndIf
          If FilePanel <> *File\ShowPanel:  FilePanel = -1: EndIf
        EndIf
      EndIf
    Next i
  EndIf
  
  If Selected > 0
    Disable = 0
  Else
    Disable = 1
  EndIf
  
  If IsProjectCreation
    ; if a project is created, the main window is disabled, so this does not make much sense
    DisableGadget(#GADGET_Project_ViewFile, 1)
  Else
    DisableGadget(#GADGET_Project_ViewFile, Disable)
  EndIf
  
  DisableGadget(#GADGET_Project_RemoveFile, Disable)
  DisableGadget(#GADGET_Project_FileLoad,   Disable)
  DisableGadget(#GADGET_Project_FileScan,   Disable)
  DisableGadget(#GADGET_Project_FileWarn,   Disable)
  DisableGadget(#GADGET_Project_FilePanel,  Disable)
  
  SetGadgetState(#GADGET_Project_FileLoad,  FileLoad)
  SetGadgetState(#GADGET_Project_FileScan,  FileScan)
  SetGadgetState(#GADGET_Project_FileWarn,  FileWarn)
  SetGadgetState(#GADGET_Project_FilePanel, FilePanel)
  
EndProcedure

; returns #false if canceled
;
Procedure RecursiveAddFiles(ID, Base$, List Files.s())
  
  Select MessageRequester(Language("Project","Title"), Language("Project","AddDirectory")+#NewLine+Base$, #PB_MessageRequester_YesNoCancel|#FLAG_Question)
    Case #PB_MessageRequester_Yes
      If ExamineDirectory(ID, Base$, "*")
        While NextDirectoryEntry(ID)
          Name$ = DirectoryEntryName(ID)
          
          If DirectoryEntryType(ID) = #PB_DirectoryEntry_Directory
            If Name$ <> "." And Name$ <> ".."
              If RecursiveAddFiles(ID+1, Base$+Name$+#Separator, Files()) = #False
                FinishDirectory(ID)
                ProcedureReturn #False ; send the "cancel" out to the main level
              EndIf
            EndIf
            
          Else
            AddElement(Files())
            Files() = Base$ + Name$
            
          EndIf
        Wend
        FinishDirectory(ID)
      EndIf
      ProcedureReturn #True
      
    Case #PB_MessageRequester_No
      ProcedureReturn #True ; skip directory but do not cancel
      
    Case #PB_MessageRequester_Cancel
      ProcedureReturn #False
      
  EndSelect
  
EndProcedure

; Add a list of files to to the options dialog.
; the list may include directories and must be Chr(10) separated (like EventDropFiles())
;
Procedure AddProjectOptionFiles(FileList$)
  Protected NewList Files.s()
  Count = CountString(FileList$, Chr(10)) + 1
  
  ; Deselect all items in the gadget, as we only select newly added ones
  SetGadgetState(#GADGET_Project_FileList, -1)
  
  ; First gather recursively all directory content to add
  ; if directories are included (ask the user for every directory)
  ;
  For i = 1 To Count
    File$ = Trim(StringField(FileList$, i, Chr(10)))
    
    If FileSize(File$) = -2
      If Right(File$, 1) <> #Separator
        File$ + #Separator
      EndIf
      
      If RecursiveAddFiles(0, File$, Files()) = #False ; #false means user canceled
        UpdateProjectOptionStates()                    ; reflect the new gadget state
        ProcedureReturn
      EndIf
      
    Else
      AddElement(Files())
      Files() = File$
      
    EndIf
  Next i
  
  ; Filter files that are already in the project
  ;
  ForEach Files()
    ForEach ProjectConfig()
      If IsEqualFile(Files(), ProjectConfig()\FileName$)
        ; select this file in the file list (as we select all added files)
        Last = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = 1 To Last
          If GetGadgetItemData(#GADGET_Project_FileList, i) = @ProjectConfig()
            SetGadgetItemState(#GADGET_Project_FileList, i, #PB_ListIcon_Selected)
            Break
          EndIf
        Next i
        
        ; remove this file from the "to add" list
        DeleteElement(Files())
        Break
      EndIf
    Next ProjectConfig()
  Next Files()
  
  If ListSize(Files()) = 0
    UpdateProjectOptionStates() ; reflect the new gadget states
    ProcedureReturn
  EndIf
  
  ; Warn if there are many files to add
  ;
  If ListSize(Files()) > 50
    If MessageRequester(Language("Project","Title"), LanguagePattern("Project","AddManyFiles", "%filecount%", Str(ListSize(Files()))), #PB_MessageRequester_YesNo|#FLAG_Question) = #PB_MessageRequester_No
      UpdateProjectOptionStates() ; reflect the new gadget states
      ProcedureReturn
    EndIf
  EndIf
  
  ; Finally add the files
  ;
  LastElement(ProjectConfig())
  
  If IsProjectCreation
    BasePath$ = GetPathPart(NewProjectFile$)
  Else
    BasePath$ = GetPathPart(ProjectFile$)
  EndIf
  
  ForEach Files()
    AddElement(ProjectConfig())
    ProjectConfig()\FileName$   = Files()
    ProjectConfig()\AutoLoad    = 0
    ProjectConfig()\AutoScan    = IsCodeFile(Files())
    ProjectConfig()\ShowPanel   = 1
    ProjectConfig()\ShowWarning = 1
    
    AddGadgetItem(#GADGET_Project_FileList, -1, CreateRelativePath(BasePath$, Files()))
    Index = CountGadgetItems(#GADGET_Project_FileList)-1
    SetGadgetItemData(#GADGET_Project_FileList, Index, @ProjectConfig())
    SetGadgetItemState(#GADGET_Project_FileList, Index, #PB_ListIcon_Selected)
  Next Files()
  
  UpdateProjectOptionStates() ; reflect the new gadget states
  
EndProcedure

; for project creation only.
; Resolve/Change the project filename and the filelist
;
Procedure ProjectFileChange(NewFile$)
  If NewFile$ = ""
    NewProjectFile$ = ""
  Else
    ; Add extension if none present
    ;
    If GetExtensionPart(GetFilePart(NewFile$)) = ""
      NewFile$ + #ProjectFileExtension
    EndIf
    
    ; Resolve the new file by the current directory, because there it would be saved if
    ; we did not resolve anything. (the user should use a full path anyway)
    ;
    NewProjectFile$ = ResolveRelativePath(GetCurrentDirectory(), NewFile$)
    
    If GetGadgetText(#GADGET_Project_File) <> NewProjectFile$
      SetGadgetText(#GADGET_Project_File, NewProjectFile$)
    EndIf
  EndIf
  
  BasePath$ = GetPathPart(NewProjectFile$)
  Last = CountGadgetItems(#GADGET_Project_FileList)-1
  For i = 0 To Last
    *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
    SetGadgetItemText(#GADGET_Project_FileList, i, CreateRelativePath(BasePath$, *File\FileName$), 0)
  Next i
EndProcedure

Procedure ProjectOptionsEvents(EventID)
  Quit = 0
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    EventGadgetID = EventMenu()
  Else
    EventGadgetID = EventGadget()
  EndIf
  
  
  If EventID = #PB_Event_GadgetDrop
    Select EventGadget()
        
      Case #GADGET_Project_Name
        SetGadgetText(#GADGET_Project_Name, RemoveString(EventDropText(), #NewLine))
        
      Case #GADGET_Project_Comments
        SetGadgetText(#GADGET_Project_Comments, EventDropText())
        
      Case #GADGET_Project_FileList
        AddProjectOptionFiles(EventDropFiles())
        
    EndSelect
    
  ElseIf EventID = #PB_Event_Gadget
    Select EventGadgetID
        
      Case #GADGET_Project_Ok
        ProjectOK = 1
        
        ; Some required checks
        If Trim(GetGadgetText(#GADGET_Project_Name)) = ""
          ProjectOK = 0
          MessageRequester(Language("Project","Title"), Language("Project","NeedName"))
          
        ElseIf IsProjectCreation
          
          ; this also resolves relative names etc
          If GetGadgetText(#GADGET_Project_File) <> NewProjectFile$
            ProjectFileChange(GetGadgetText(#GADGET_Project_File))
          EndIf
          
          If NewProjectFile$ = ""
            ProjectOK = 0
            MessageRequester(Language("Project","Title"), Language("Project","NeedFile"))
            
          ElseIf FileSize(NewProjectFile$) > -1
            If MessageRequester(Language("Project","TitleNew"), Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_No
              ProjectOK = 0
            EndIf
            
          EndIf
          
          ; check if the filename is a writable location so we do not get the problem later
          If ProjectOK
            If OpenFile(#FILE_CheckProject, NewProjectFile$) = 0
              MessageRequester(Language("Project", "TitleNew"), Language("Project", "SaveError"), #FLAG_Error)
              ProjectOK = 0
            Else
              CloseFile(#FILE_CheckProject)
            EndIf
          EndIf
        EndIf
        
        If ProjectOK
          
          ; In case we create a new project. Now we have a project data
          OldProjectName$ = ProjectName$
          ProjectName$    = Trim(GetGadgetText(#GADGET_Project_Name))
          If IsProjectCreation
            IsProject    = #True
            ProjectFile$ = NewProjectFile$
            ProjectShowLog = #True ; always true initially
            
            ProjectLastOpenDate    = 0
            ProjectLastOpenHost$   = ""
            ProjectLastOpenUser$   = ""
            ProjectLastOpenEditor$ = ""
            
            ; no targets yet (a default one is created below)
            ClearList(ProjectTargets())
            ClearList(ProjectFiles()) ; filled with the config below
            ClearList(ProjectLog())
            
            ; add the info source
            AddProjectInfo()
            
            ; switch to the info source, so the user can directly get to the projects compiler options etc
            FirstElement(FileList())
            ChangeActiveSourceCode()
          ElseIf OldProjectName$ <> ProjectName$
            ;change name of Tab, if user changed the project name
            If *ProjectInfo
              PushListPosition(FileList())
              ChangeCurrentElement(FileList(), *ProjectInfo)
              SetTabBarGadgetItemText(#GADGET_FilesPanel, ListIndex(FileList()), Language("Project","TabTitle") + " [" + ProjectName$ + "]")
              PopListPosition(FileList())
            EndIf
          EndIf
          
          ; Update the options
          ProjectComments$ = GetGadgetText(#GADGET_Project_Comments)
          
          If GetGadgetState(#GADGET_Project_SetDefault)
            DefaultProjectFile$ = ProjectFile$
          ElseIf IsEqualFile(DefaultProjectFile$, ProjectFile$) ; do not unset if this was not the default project
            DefaultProjectFile$ = ""
          EndIf
          
          ProjectCloseFiles = GetGadgetState(#GADGET_Project_CloseAllFiles)
          
          If GetGadgetState(#GADGET_Project_OpenLoadLast)
            ProjectOpenMode = #Project_Open_LoadLast
          ElseIf GetGadgetState(#GADGET_Project_OpenLoadAll)
            ProjectOpenMode = #Project_Open_LoadAll
          ElseIf GetGadgetState(#GADGET_Project_OpenLoadDefault)
            ProjectOpenMode = #Project_Open_LoadDefault
          ElseIf GetGadgetState(#GADGET_Project_OpenLoadMain)
            ProjectOpenMode = #Project_Open_LoadMain
          Else
            ProjectOpenMode = #Project_Open_LoadNone
          EndIf
          
          ; Now remove any file from the real project file list if it is not in the config list
          ; We do not just do a ClearList() and re-fill it, because the ProjectPanel stores
          ; pointers to the entries!
          ;
          ForEach ProjectFiles()
            Found = 0
            ForEach ProjectConfig()
              If IsEqualFile(ProjectFiles()\Filename$, ProjectConfig()\Filename$)
                Found = 1
                Break
              EndIf
            Next ProjectConfig()
            
            If Found = 0
              If ProjectFiles()\Source
                *ProjectFile = @ProjectFiles()
                UnlinkSourceFromProject(ProjectFiles()\Source, #False)
                ChangeCurrentElement(ProjectFiles(), *ProjectFile)
              EndIf
              ClearProjectFile(@ProjectFiles())
              DeleteElement(ProjectFiles())
            EndIf
          Next ProjectFiles()
          
          ; Now add/update the current/new files
          ForEach ProjectConfig()
            Found = 0
            ForEach ProjectFiles()
              If IsEqualFile(ProjectFiles()\Filename$, ProjectConfig()\Filename$)
                Found = 1
                Break
              EndIf
            Next ProjectFiles()
            
            If Found = 0
              AddElement(ProjectFiles()) ; add new if needed
            EndIf
            
            ; copy config to file and update the file data (autocomplete etc)
            CopyProjectConfig(@ProjectConfig(), @ProjectFiles())
            UpdateProjectFile(@ProjectFiles())
          Next ProjectConfig()
          
          ClearList(ProjectConfig())
          
          ; ensure that the project has a default target (if it is new)
          SetProjectDefaultTarget()
          
          ; Update the menu to reflect the new target list
          StartFlickerFix(#WINDOW_Main)
          CreateIDEMenu()
          StopFlickerFix(#WINDOW_Main, 1)
          
          If SaveProject(#True)              ; do not save modified sources
            RecentFiles_AddFile(ProjectFile$, #True) ; add to recent projects in case we create a new project here
            Quit = 1
          EndIf
          
          UpdateMainWindowTitle() ; show name changes
        EndIf
        
      Case #GADGET_Project_Cancel
        Quit = 1
        
      Case #GADGET_Project_Panel
        ; Update the project file base if it changes on panel switches.
        ; This way if the user switches to the file panel, he will see the correct relative path always
        ;
        If IsProjectCreation
          If GetGadgetText(#GADGET_Project_File) <> NewProjectFile$
            ProjectFileChange(NewProjectFile$)
          EndIf
        EndIf
        
      Case #GADGET_Project_OpenOptions
        OpenOptionWindow(#True)
        
      Case #GADGET_Project_ChooseFile
        File$ = GetGadgetText(#GADGET_Project_File)
        If File$ = ""
          File$ = SourceDirectory$
        Else
          ; always resolve from the CurrentDirectory() as there is no basepath for project files
          File$ = ResolveRelativePath(GetCurrentDirectory(), File$)
        EndIf
        
        File$ = SaveFileRequester(Language("Project","TitleSave"), File$, Language("Project","Pattern"), 0)
        If File$ <> ""
          If GetExtensionPart(GetFilePart(File$)) = ""
            If SelectedFilePattern() = 0 ; project files
              File$ + #ProjectFileExtension
            EndIf
          EndIf
          
          ProjectFileChange(File$)
        EndIf
        
      Case #GADGET_Project_Explorer
        If EventType() = #PB_EventType_DragStart
          Last  = CountGadgetItems(#GADGET_Project_Explorer)-1
          Base$ = GetGadgetText(#GADGET_Project_Explorer)
          All$  = ""
          For i = 0 To Last
            State = GetGadgetItemState(#GADGET_Project_Explorer, i)
            If State & #PB_Explorer_Selected
              Name$ = GetGadgetItemText(#GADGET_Project_Explorer, i, 0)
              If Name$ <> ".."
                If State & #PB_Explorer_Directory
                  All$ + Base$ + Name$ + #Separator + Chr(10)
                Else
                  All$ + Base$ + Name$ + Chr(10)
                EndIf
              EndIf
            EndIf
          Next i
          
          If All$ <> ""
            DragFiles(Left(All$, Len(All$)-1), #PB_Drag_Copy) ; cut the final Chr(10)
          EndIf
          
        Else
          If ProjectExplorerPath$ <> GetGadgetText(#GADGET_Project_Explorer)
            ProjectExplorerPath$ = GetGadgetText(#GADGET_Project_Explorer)
            SetGadgetText(#GADGET_Project_ExplorerCombo, ProjectExplorerPath$)
          EndIf
          UpdateProjectOptionStates() ; update this on all changes (enables the "Add" button)
        EndIf
        
        CompilerIf #CompileWindows
          ; adjust the column size to any scrollbar changes etc
          SendMessage_(GadgetID(#GADGET_Project_Explorer), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
        CompilerEndIf
        
      Case #GADGET_Project_ExplorerCombo
        If ProjectExplorerPath$ <> GetGadgetText(#GADGET_Project_ExplorerCombo)
          ProjectExplorerPath$ = GetGadgetText(#GADGET_Project_ExplorerCombo)
          SetGadgetText(#GADGET_Project_Explorer, ProjectExplorerPath$)
          UpdateProjectOptionStates()
        EndIf
        
      Case #GADGET_Project_ExplorerPattern ; not present on OSX
        If ProjectExplorerPattern <> GetGadgetState(#GADGET_Project_ExplorerPattern)
          ProjectExplorerPattern = GetGadgetState(#GADGET_Project_ExplorerPattern)
          SetGadgetText(#GADGET_Project_Explorer, StringField(ExplorerPatternStrings$, ProjectExplorerPattern+1, "|"))
          UpdateProjectOptionStates()
        EndIf
        
      Case #GADGET_Project_FileList
        UpdateProjectOptionStates()
        
      Case #GADGET_Project_AddFile
        Last  = CountGadgetItems(#GADGET_Project_Explorer)-1
        Base$ = GetGadgetText(#GADGET_Project_Explorer)
        All$  = ""
        For i = 0 To Last
          State = GetGadgetItemState(#GADGET_Project_Explorer, i)
          If State & #PB_Explorer_Selected
            Name$ = GetGadgetItemText(#GADGET_Project_Explorer, i, 0)
            If Name$ <> ".."
              If State & #PB_Explorer_Directory And Right(Name$, 1) <> #Separator
                Name$ + #Separator ; drive names already have this!
              EndIf
              All$ + Base$ + Name$ + Chr(10)
            EndIf
          EndIf
        Next i
        
        If All$ <> ""
          AddProjectOptionFiles(Left(All$, Len(All$)-1)) ; cut the final Chr(10)
        EndIf
        
      Case #GADGET_Project_RemoveFile
        Last  = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = Last To 0 Step -1 ; step backwards to not modify indexes of other items!
          If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
            ChangeCurrentElement(ProjectConfig(), GetGadgetItemData(#GADGET_Project_FileList, i))
            DeleteElement(ProjectConfig())
            RemoveGadgetItem(#GADGET_Project_FileList, i)
          EndIf
        Next i
        UpdateProjectOptionStates() ; no more selected items
        
      Case #GADGET_Project_NewFile
        If IsProjectCreation
          If NewProjectFile$ <> ""
            Path$ = GetPathPart(NewProjectFile$)
          Else
            Path$ = SourcePath$
          EndIf
        Else
          Path$ = GetPathPart(ProjectFile$)
        EndIf
        
        FileName$ = SaveFileRequester(Language("FileStuff","SaveFileTitle"), Path$, Language("FileStuff","Pattern"), SelectedFilePattern)
        If FileName$ <> ""
          SelectedFilePattern = SelectedFilePattern()
          
          If GetExtensionPart(GetFilePart(FileName$)) = ""
            If SelectedFilePattern <= 1  ; (=all pb files or pb sources only)
              FileName$ + #SourceFileExtension
            ElseIf SelectedFilePattern = 2 ; (=pbi only)
              FileName$ + #IncludeFileExtension
            EndIf
          EndIf
          
          If FileSize(FileName$) > -1  ; file exist check
            If MessageRequester(#ProductName$, Language("FileStuff","FileExists")+#NewLine+Language("FileStuff","OverWrite"), #PB_MessageRequester_YesNo|#FLAG_Warning) = #PB_MessageRequester_No
              FileName$ = "" ; abort
            EndIf
          EndIf
          
          If FileName$ <> ""
            ; Try to create the file, then open it.
            ; This way we only add the file, if creating was possible
            If CreateFile(#FILE_SaveSource, FileName$)
              CloseFile(#FILE_SaveSource)
              If LoadSourceFile(FileName$)
                AddProjectOptionFiles(FileName$)
              EndIf
            Else
              MessageRequester(#ProductName$, Language("FileStuff","CreateError"), #FLAG_Error)
            EndIf
          EndIf
        EndIf
        
      Case #GADGET_Project_OpenFile
        If IsProjectCreation
          If NewProjectFile$ <> ""
            Path$ = GetPathPart(NewProjectFile$)
          Else
            Path$ = SourcePath$
          EndIf
        Else
          Path$ = GetPathPart(ProjectFile$)
        EndIf
        
        FileName$ = OpenFileRequester(Language("FileStuff","OpenFileTitle"), Path$, Language("FileStuff","Pattern"), SelectedFilePattern, #PB_Requester_MultiSelection)
        If FileName$ <> ""
          SelectedFilePattern = SelectedFilePattern()
          
          All$ = ""
          While FileName$ <> ""
            All$ + FileName$ + Chr(10)
            FileName$ = NextSelectedFileName()
          Wend
          
          AddProjectOptionFiles(Left(All$, Len(All$)-1)) ; cut the final Chr(10)
        EndIf
        
      Case #GADGET_Project_ViewFile
        Last  = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = 0 To Last
          If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
            *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
            
            If IsCodeFile(*File\FileName$)
              LoadSourceFile(*File\FileName$) ; will just switch to it if already loaded
            Else
              FileViewer_OpenFile(*File\FileName$)
            EndIf
          EndIf
        Next i
        
      Case #GADGET_Project_FileLoad
        State = GetGadgetState(#GADGET_Project_FileLoad) ; can only be 1 or 0 (-1 cannot be user set)
        Last  = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = 0 To Last
          If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
            *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
            *File\AutoLoad = State
          EndIf
        Next i
        
      Case #GADGET_Project_FileScan
        State = GetGadgetState(#GADGET_Project_FileScan) ; can only be 1 or 0 (-1 cannot be user set)
        Last  = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = 0 To Last
          If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
            *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
            *File\AutoScan = State
          EndIf
        Next i
        
      Case #GADGET_Project_FileWarn
        State = GetGadgetState(#GADGET_Project_FileWarn) ; can only be 1 or 0 (-1 cannot be user set)
        Last  = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = 0 To Last
          If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
            *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
            *File\ShowWarning = State
          EndIf
        Next i
        
      Case #GADGET_Project_FilePanel
        State = GetGadgetState(#GADGET_Project_FilePanel) ; can only be 1 or 0 (-1 cannot be user set)
        Last  = CountGadgetItems(#GADGET_Project_FileList)-1
        For i = 0 To Last
          If GetGadgetItemState(#GADGET_Project_FileList, i) & #PB_ListIcon_Selected
            *File.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
            *File\ShowPanel = State
          EndIf
        Next i
        
    EndSelect
    
    
  ElseIf EventID = #PB_Event_SizeWindow
    ProjectOptionsDialog\SizeUpdate()
    
    CompilerIf #CompileWindows
      ; autosize the explorerlist column
      SendMessage_(GadgetID(#GADGET_Project_Explorer), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
      SendMessage_(GadgetID(#GADGET_Project_FileList), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
    CompilerEndIf
    
  ElseIf EventID = #PB_Event_CloseWindow
    Quit = 1
    
  EndIf
  
  If Quit
    If IsProjectCreation
      DisableWindow(#WINDOW_Main, 0)
    EndIf
    
    If MemorizeWindow
      ProjectOptionsDialog\Close(@ProjectOptionsPosition)
    Else
      ProjectOptionsDialog\Close()
    EndIf
    
    ProjectOptionsDialog = 0
    IsProjectCreation    = 0
    
    ClearList(ProjectConfig())
    
    UpdateProjectInfo()
    UpdateProjectPanel()
    UpdateMenuStates() ; apply any project changes to the menu
  EndIf
  
EndProcedure

Procedure OpenProjectOptions(NewProject)
  
  If IsWindow(#WINDOW_ProjectOptions) And (NewProject = 0 Or IsProjectCreation)
    ; cannot open the window when already open
    ; also cannot create a new project if project creation is in progress
    SetWindowForeground(#WINDOW_ProjectOptions)
    ProcedureReturn
  EndIf
  
  If NewProject
    ; We need to close the previous project before opening a new one.
    ; This also ensures that any old ProjectOptions gets closed
    ;
    If CloseProject() = 0
      ProcedureReturn
    EndIf
  EndIf
  
  ProjectOptionsDialog = OpenDialog(?Dialog_ProjectOptions, WindowID(#WINDOW_Main), @ProjectOptionsPosition)
  If ProjectOptionsDialog
    EnsureWindowOnDesktop(#WINDOW_ProjectOptions)
    
    ; Reduce flickering a lot on Windows while resizing
    SmartWindowRefresh(#WINDOW_ProjectOptions, #True)
    
    EnableGadgetDrop(#GADGET_Project_Name,     #PB_Drop_Text,  #PB_Drag_Copy)
    EnableGadgetDrop(#GADGET_Project_Comments, #PB_Drop_Text,  #PB_Drag_Copy)
    EnableGadgetDrop(#GADGET_Project_FileList, #PB_Drop_Files, #PB_Drag_Copy)
    
    CompilerIf #CompileMac = 0 ; mac has only 1 column anyway
      RemoveGadgetColumn(#GADGET_Project_Explorer, 1)
      RemoveGadgetColumn(#GADGET_Project_Explorer, 1)
      RemoveGadgetColumn(#GADGET_Project_Explorer, 1)
    CompilerEndIf
    
    CompilerIf #CompileWindows
      ; autosize the explorerlist column
      SendMessage_(GadgetID(#GADGET_Project_Explorer), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
      SendMessage_(GadgetID(#GADGET_Project_FileList), #LVM_SETCOLUMNWIDTH, 0, #LVSCW_AUTOSIZE_USEHEADER)
    CompilerEndIf
    
    If NewProject
      IsProjectCreation = 1
      SetWindowTitle(#WINDOW_ProjectOptions, Language("Project","TitleNew"))
      SetGadgetText(#GADGET_Project_Ok, Language("Project", "CreateProject"))
      
      HideGadget(#GADGET_Project_OpenOptions, 1)
      HideGadget(#GADGET_Project_FileStatic, 1)
      HideGadget(#GADGET_Project_File, 0)
      HideGadget(#GADGET_Project_ChooseFile, 0)
      
      ; set the project defaults
      ;
      NewProjectFile$ = ""
      SetGadgetText(#GADGET_Project_File, "")
      SetGadgetText(#GADGET_Project_Name, Language("Project", "DefaultName"))
      
      SetGadgetState(#GADGET_Project_CloseAllFiles, 1)
      SetGadgetState(#GADGET_Project_OpenLoadLast, 1)
      
      ProjectExplorerPattern = 0 ; default pattern is "PB files"
      ProjectExplorerPath$   = SourcePath$
      ClearList(ProjectConfig()) ; no files in the list yet
      ProjectOptionsDialog\GuiUpdate() ; to resize from the new strings
      
      CompilerIf #CompileLinuxQt = 0
        ; On QT disabling the main window disables its child too so this will lock the IDE
        DisableWindow(#WINDOW_Main, 1)
      CompilerEndIf
      SetActiveGadget(#GADGET_Project_File)

    Else
      IsProjectCreation = 0
      
      SetGadgetText(#GADGET_Project_FileStatic, ProjectFile$)
      SetGadgetText(#GADGET_Project_Name,       ProjectName$)
      SetGadgetText(#GADGET_Project_Comments,   ProjectComments$)
      
      SetGadgetState(#GADGET_Project_SetDefault,    IsEqualFile(ProjectFile$, DefaultProjectFile$))
      SetGadgetState(#GADGET_Project_CloseAllFiles, ProjectCloseFiles)
      
      Select ProjectOpenMode
        Case #Project_Open_LoadLast:    SetGadgetState(#GADGET_Project_OpenLoadLast,    1)
        Case #Project_Open_LoadAll:     SetGadgetState(#GADGET_Project_OpenLoadAll,     1)
        Case #Project_Open_LoadDefault: SetGadgetState(#GADGET_Project_OpenLoadDefault, 1)
        Case #Project_Open_LoadMain:    SetGadgetState(#GADGET_Project_OpenLoadMain,    1)
        Default: SetGadgetState(#GADGET_Project_OpenLoadNone,    1)
      EndSelect
      
      BasePath$ = GetPathPart(ProjectFile$)
      
      ; copy file list and add it to the gadget
      ClearList(ProjectConfig())
      ForEach ProjectFiles()
        AddElement(ProjectConfig())
        CopyProjectConfig(@ProjectFiles(), @ProjectConfig())
        
        AddGadgetItem(#GADGET_Project_FileList, -1, CreateRelativePath(BasePath$, ProjectConfig()\FileName$))
        Index = CountGadgetItems(#GADGET_Project_FileList)-1
        SetGadgetItemData(#GADGET_Project_FileList, Index, @ProjectConfig())
      Next ProjectFiles()
      
    EndIf
    
    ; This also fills the explorer pattern in the project options and sets the correct state
    UpdateExplorerPatterns()

    CompilerIf #CompileLinux
      ; On Linux we have to check if ProjectExplorerPath$ is an accessible folder - otherwise a crash
      ; will occur because of a bug in the following SetGadgetText()!
      ; If ProjectExplorerPath$ is no folder then change it to home folder
      If FileSize(ProjectExplorerPath$) <> -2
        ProjectExplorerPath$ = GetHomeDirectory()
      EndIf
    CompilerEndIf

    SetGadgetText(#GADGET_Project_Explorer, ProjectExplorerPath$+StringField(ExplorerPatternStrings$, ProjectExplorerPattern+1, "|"))
    SetGadgetText(#GADGET_Project_ExplorerCombo, ProjectExplorerPath$)

    UpdateProjectOptionStates() ; disable some buttons as needed
  EndIf
  
EndProcedure


Procedure UpdateProjectOptionsWindow()
  
  ProjectOptionsDialog\LanguageUpdate()
  
  If IsProjectCreation
    SetWindowTitle(#WINDOW_ProjectOptions, Language("Project","TitleNew"))
    SetGadgetText(#GADGET_Project_Ok, Language("Project", "CreateProject"))
  EndIf
  
  ProjectOptionsDialog\GuiUpdate()
  
EndProcedure


Procedure AddProjectFile()
  If IsProject And *ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile = 0
    
    If *ActiveSource\FileName$ = "" ; file not saved yet
      If SaveSourceAs() <= 0        ; check for user abort too
        ProcedureReturn
      EndIf
    EndIf
    
    If IsWindow(#WINDOW_ProjectOptions)
      ; Config dialog is open, so add the file there
      
      ; Check if the file exists (check in the gadget, so we directly have the index)
      exists = 0
      last   = CountGadgetItems(#GADGET_Project_FileList)-1
      For i = 0 To last
        *ConfigFile.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
        If IsEqualFile(*ConfigFile\FileName$, *ActiveSource\FileName$)
          exists = 1
          SetGadgetState(#GADGET_Project_FileList, i)
          Break
        EndIf
      Next i
      
      If exists = 0
        LastElement(ProjectConfig())
        AddElement(ProjectConfig())
        ProjectConfig()\FileName$   = *ActiveSource\FileName$
        ProjectConfig()\AutoLoad    = 0
        ProjectConfig()\AutoScan    = 1
        ProjectConfig()\ShowPanel   = 1
        ProjectConfig()\ShowWarning = 1
        
        AddGadgetItem(#GADGET_Project_FileList, -1, CreateRelativePath(GetPathPart(ProjectFile$) , *ActiveSource\FileName$))
        Index = CountGadgetItems(#GADGET_Project_FileList)-1
        SetGadgetItemData(#GADGET_Project_FileList, Index, @ProjectConfig())
        SetGadgetState(#GADGET_Project_FileList, Index)
      EndIf
      
      
      UpdateProjectOptionStates()                 ; reflect the new gadget states
      SetGadgetState(#GADGET_Project_Panel, 1)    ; so the user notices that the config is open
      SetWindowForeground(#WINDOW_ProjectOptions)
      SetActiveGadget(#GADGET_Project_FileList)
      
    Else
      ; No config window, add the file to the project directly
      LastElement(ProjectFiles())
      
      AddElement(ProjectFiles())
      ProjectFiles()\FileName$   = *ActiveSource\FileName$
      ProjectFiles()\AutoLoad    = 0
      ProjectFiles()\AutoScan    = 1
      ProjectFiles()\ShowPanel   = 1
      ProjectFiles()\ShowWarning = 1
      
      UpdateProjectFile(@ProjectFiles())
      UpdateMenuStates()                   ; reflect the changed settings
      UpdateProjectInfo()
      UpdateProjectPanel()
      
    EndIf
    
  EndIf
EndProcedure

Procedure RemoveProjectFile()
  If IsProject And *ActiveSource <> *ProjectInfo And *ActiveSource\ProjectFile <> 0
    
    If IsWindow(#WINDOW_ProjectOptions)
      ; Config dialog is open, so remove the file there
      
      last = CountGadgetItems(#GADGET_Project_FileList)-1
      For i = 0 To last
        *ConfigFile.ProjectFileConfig = GetGadgetItemData(#GADGET_Project_FileList, i)
        If IsEqualFile(*ConfigFile\FileName$, *ActiveSource\FileName$)
          ChangeCurrentElement(ProjectConfig(), *ConfigFile)
          DeleteElement(ProjectConfig())
          RemoveGadgetItem(#GADGET_Project_FileList, i)
          Break
        EndIf
      Next i
      
      SetGadgetState(#GADGET_Project_FileList, -1)
      UpdateProjectOptionStates()                 ; reflect the new gadget states
      SetGadgetState(#GADGET_Project_Panel, 1)    ; so the user notices that the config is open
      SetWindowForeground(#WINDOW_ProjectOptions)
      SetActiveGadget(#GADGET_Project_FileList)
      
    Else
      ; No config window, remove the file from the project directly
      
      *File.ProjectFile = *ActiveSource\ProjectFile
      UnlinkSourceFromProject(*ActiveSource, #False)
      
      ClearProjectFile(*File)
      ChangeCurrentElement(ProjectFiles(), *File)
      DeleteElement(ProjectFiles())
      
      UpdateMenuStates()                   ; reflect the changed settings
      UpdateProjectInfo()
      UpdateProjectPanel()
      
    EndIf
  EndIf
EndProcedure
