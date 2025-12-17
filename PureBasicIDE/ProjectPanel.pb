; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;
; We add/remove only the changed files from the Panel, this way the
; selection, scroll position and open nodes stay consistent
;
; For this, we store the ProjectFiles() pointer in the GadgetItemData
; Special values for the GadgetItemData:
;
#ProjectPanel_Directory    = 0
#ProjectPanel_InternalBase = -1
#ProjectPanel_ExternalBase = -2

Global ProjectPanelVisible
Global ProjectPanelMenuGadget

; Delete a file entry and all its parents if empty (recursive)
;
Procedure ProjectPanel_RemoveFile(Index)
  Sublevel = GetGadgetItemAttribute(#GADGET_ProjectPanel, Index, #PB_Tree_SubLevel)
  
  ; Only empty Items can be removed
  ;
  Last = CountGadgetItems(#GADGET_ProjectPanel)-1
  For i = Index+1 To Last
    Level = GetGadgetItemAttribute(#GADGET_ProjectPanel, i, #PB_Tree_SubLevel)
    If Level <= Sublevel
      Break
    ElseIf Level > Sublevel
      ; found a subitem, so abort
      ProcedureReturn
    EndIf
  Next i
  
  ; This item is empty, so remove it
  ; Do not remove the InternalBase item, so the gadget is only full empty when no project is open
  ;
  If GetGadgetItemData(#GADGET_ProjectPanel, Index) <> #ProjectPanel_InternalBase
    RemoveGadgetItem(#GADGET_ProjectPanel, Index)
    
    ; Find the parent and recurse
    If Sublevel > 0
      For ParentIndex = Index-1 To 0 Step -1
        If GetGadgetItemAttribute(#GADGET_ProjectPanel, ParentIndex, #PB_Tree_SubLevel) < Sublevel
          ProjectPanel_RemoveFile(ParentIndex)
          ProcedureReturn
        EndIf
      Next ParentIndex
    EndIf
  EndIf
  
EndProcedure

; Add all directories for a file, and the file entry itself (recursive)
;
Procedure ProjectPanel_AddFile(Filename$, ParentIndex, *File.ProjectFile)
  NewLevel  = GetGadgetItemAttribute(#GADGET_ProjectPanel, ParentIndex, #PB_Tree_SubLevel)+1
  Count     = CountGadgetItems(#GADGET_ProjectPanel)
  NewItem$  = StringField(Filename$, 1, #Separator)
  Separator = FindString(Filename$, #Separator, 1)
  
  ; Look if we can find the Item$ on the current sublevel, else look for a place to insert
  ;
  FoundIndex  = -1
  InsertIndex = -1
  
  For Index = ParentIndex+1 To Count-1
    Level = GetGadgetItemAttribute(#GADGET_ProjectPanel, Index, #PB_Tree_SubLevel)
    If Level = NewLevel
      *NewFile = GetGadgetItemData(#GADGET_ProjectPanel, Index)
      If Separator And *NewFile <> #ProjectPanel_Directory
        ; directories come before files
        InsertIndex = Index
        Break
        
      ElseIf Separator = 0 And *NewFile = #ProjectPanel_Directory
        ; files come after directories
        Continue
        
      Else
        Item$ = GetGadgetItemText(#GADGET_ProjectPanel, Index)
        Select CompareMemoryString(@NewItem$, @Item$, #PATH_CaseInsensitive)
            
          Case #PB_String_Lower
            InsertIndex = Index
            Break
            
          Case #PB_String_Equal
            FoundIndex = Index
            Break
            
        EndSelect
      EndIf
      
    ElseIf Level < NewLevel
      InsertIndex = Index
      Break
      
    EndIf
  Next Index
  
  If FoundIndex = -1 And InsertIndex = -1
    InsertIndex = Count
  EndIf
  
  If Separator
    ; Its a directory
    ;
    Filename$ = Right(Filename$, Len(Filename$)-Separator)
    
    If FoundIndex <> -1
      ProjectPanel_AddFile(Filename$, FoundIndex, *File)
      
      ; do not adjust the expanded state of this directory:
      ; the stored state was used when it was first added, and if it changed since,
      ; then the user did it, so do not alter that
      
    ElseIf InsertIndex <> -1
      AddGadgetItem(#GADGET_ProjectPanel, InsertIndex, NewItem$, OptionalImageID(#IMAGE_ProjectPanel_Directory), NewLevel)
      SetGadgetItemData(#GADGET_ProjectPanel, InsertIndex, #ProjectPanel_Directory)
      ProjectPanel_AddFile(Filename$, InsertIndex, *File)
      
      ; set the expanded state from the information for the added file.
      ; this should match the information for all other files in this directory, so we only
      ; need to set this on creation of the directory
      ;
      If Mid(*File\PanelState$, NewLevel+1, 1) <> "-"  ; expanded is the default if no info was found
        SetGadgetItemState(#GADGET_ProjectPanel, InsertIndex, #PB_Tree_Expanded)
      EndIf
    EndIf
    
  Else
    ; Its a file
    ;
    If InsertIndex <> -1
      If *File\AutoScan
        ImageID = OptionalImageID(#IMAGE_ProjectPanel_FileScanned)
      Else
        ImageID = OptionalImageID(#IMAGE_ProjectPanel_File)
      EndIf
      AddGadgetItem(#GADGET_ProjectPanel, InsertIndex, Filename$, ImageID, NewLevel)
      SetGadgetItemData(#GADGET_ProjectPanel, InsertIndex, *File)
    EndIf
    
  EndIf
  
EndProcedure

; Get the full path from a panel item
Procedure.s ProjectPanel_FullPath(Index)
  *File.ProjectFile = GetGadgetItemData(#GADGET_ProjectPanel, Index)
  
  Select *File
    Case #ProjectPanel_Directory
      ParentLevel = GetGadgetItemAttribute(#GADGET_ProjectPanel, Index, #PB_Tree_SubLevel)-1
      ParentIndex = Index-1
      While ParentIndex > 0 And ParentLevel < GetGadgetItemAttribute(#GADGET_ProjectPanel, ParentIndex, #PB_Tree_SubLevel)
        ParentIndex - 1
      Wend
      ProcedureReturn ProjectPanel_FullPath(ParentIndex) + GetGadgetItemText(#GADGET_ProjectPanel, Index) + #Separator
      
    Case #ProjectPanel_InternalBase
      ProcedureReturn GetPathPart(ProjectFile$)
      
    Case #ProjectPanel_ExternalBase
      ProcedureReturn ""
      
    Default ; its a ProjectFile structure
      ProcedureReturn *File\Filename$
      
  EndSelect
EndProcedure


Procedure ProjectPanel_InBasePath(Base$, Filename$)
  If Len(Base$) < Len(Filename$) And CompareMemoryString(@Base$, @Filename$, #PATH_CaseInsensitive, Len(Base$)) = #PB_String_Equal
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure ProjectPanel_IsFile(*File.ProjectFile)
  If *File = 0 Or *File = #ProjectPanel_Directory Or *File = #ProjectPanel_InternalBase Or *File = #ProjectPanel_ExternalBase
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure StoreProjectPanelStates()
  
  If ProjectPanelVisible
    
    ; This is needed to ensures consistency (project files could have been removed) as we used raw pointers in list item user data.
    UpdateProjectPanel()
    
    ;
    ; Each file stores the states expanded states of all its parent directories
    ; This stores some redundant information (common directories are stored with multiple files), but
    ; this way we can always reconstruct the visibility even if files are removed from the tree or added
    ;
    
    State$ = ""
    Count  = CountGadgetItems(#GADGET_ProjectPanel)
    Level  = 0
    
    For i = 0 To Count-1
      NewLevel = GetGadgetItemAttribute(#GADGET_ProjectPanel, i, #PB_Tree_SubLevel)
      If NewLevel > Level
        ; entered a directory (one level deeper at a time) ("i" must be > 0 now)
        If GetGadgetItemState(#GADGET_ProjectPanel, i-1) & #PB_Tree_Expanded
          State$ + "+" ; open
        Else
          State$ + "-" ; closed
        EndIf
      ElseIf NewLevel < Level
        ; left a directory (can be many levels at a time here), cut the states of the left directories
        State$ = Left(State$, NewLevel)
      EndIf
      Level = NewLevel
      
      *File.ProjectFile = GetGadgetItemData(#GADGET_ProjectPanel, i)
      If ProjectPanel_IsFile(*File)
        *File\PanelState$ = State$
      EndIf
    Next i
    
  EndIf
  
EndProcedure

Procedure UpdateProjectPanel()
  
  If ProjectPanelVisible
    
    If IsProject
      Base$ = GetPathPart(ProjectFile$)
      BaseLength = Len(Base$)
      
      ; Find the "internal" base item
      ;
      BaseIndex = -1
      BaseNew = 0
      last = CountGadgetItems(#GADGET_ProjectPanel)-1
      For i = 0 To last
        If GetGadgetItemData(#GADGET_ProjectPanel, i) = #ProjectPanel_InternalBase
          BaseIndex = i
          Break
        EndIf
      Next i
      
      ; Add any "internal" files that are not displayed yet
      ;
      ForEach ProjectFiles()
        If ProjectFiles()\ShowPanel And ProjectPanel_InBasePath(Base$, ProjectFiles()\FileName$)
          found = 0
          last = CountGadgetItems(#GADGET_ProjectPanel)-1
          For i = 0 To last
            If GetGadgetItemData(#GADGET_ProjectPanel, i) = @ProjectFiles()
              
              ; update the image in case the AutoScan setting was changed
              If ProjectFiles()\AutoScan
                If IsImage(#IMAGE_ProjectPanel_FileScanned)
                  SetGadgetItemImage(#GADGET_ProjectPanel, i, ImageID(#IMAGE_ProjectPanel_FileScanned))
                EndIf
              Else
                If IsImage(#IMAGE_ProjectPanel_File)
                  SetGadgetItemImage(#GADGET_ProjectPanel, i, ImageID(#IMAGE_ProjectPanel_File))
                EndIf
              EndIf
              
              found = 1
              Break
            EndIf
          Next i
          
          If found = 0
            ; Add the base item if not present yet
            ;
            If BaseIndex = -1
              AddGadgetItem(#GADGET_ProjectPanel, 0, Language("Project","InternalFiles"), OptionalImageID(#IMAGE_ProjectPanel_InternalFiles), 0)
              SetGadgetItemData(#GADGET_ProjectPanel, 0, #ProjectPanel_InternalBase)
              BaseIndex = 0
              BaseNew = 1
              BaseState$ = Left(ProjectFiles()\PanelState$, 1)
            EndIf
            
            ProjectPanel_AddFile(Right(ProjectFiles()\Filename$, Len(ProjectFiles()\Filename$)-BaseLength), BaseIndex, @ProjectFiles())
          EndIf
        EndIf
      Next ProjectFiles()
      
      If BaseNew And BaseState$ <> "-" ; expanded is the default if no state info available
        SetGadgetItemState(#GADGET_ProjectPanel, BaseIndex, #PB_Tree_Expanded)
      EndIf
      
      ; Find the "external" base item
      ;
      BaseIndex = -1
      BaseNew = 0
      last = CountGadgetItems(#GADGET_ProjectPanel)-1
      For i = 0 To last
        If GetGadgetItemData(#GADGET_ProjectPanel, i) = #ProjectPanel_ExternalBase
          BaseIndex = i
          Break
        EndIf
      Next i
      
      ; Add any external items that are not displayed yet
      ;
      ForEach ProjectFiles()
        If ProjectFiles()\ShowPanel And ProjectPanel_InBasePath(Base$, ProjectFiles()\FileName$) = #False
          found = 0
          last = CountGadgetItems(#GADGET_ProjectPanel)-1
          For i = 0 To last
            If GetGadgetItemData(#GADGET_ProjectPanel, i) = @ProjectFiles()
              
              ; update the image in case the AutoScan setting was changed
              If ProjectFiles()\AutoScan
                If IsImage(#IMAGE_ProjectPanel_FileScanned)
                  SetGadgetItemImage(#GADGET_ProjectPanel, i, ImageID(#IMAGE_ProjectPanel_FileScanned))
                EndIf
              Else
                If IsImage(#IMAGE_ProjectPanel_File)
                  SetGadgetItemImage(#GADGET_ProjectPanel, i, ImageID(#IMAGE_ProjectPanel_File))
                EndIf
              EndIf
              
              found = 1
              Break
            EndIf
          Next i
          
          If found = 0
            ; Now add the Base if not present yet
            ;
            If BaseIndex = -1
              BaseIndex = CountGadgetItems(#GADGET_ProjectPanel)
              AddGadgetItem(#GADGET_ProjectPanel, BaseIndex, Language("Project","ExternalFiles"), OptionalImageID(#IMAGE_ProjectPanel_ExternalFiles), 0)
              SetGadgetItemData(#GADGET_ProjectPanel, BaseIndex, #ProjectPanel_ExternalBase)
              BaseNew = 1
              BaseState$ = Left(ProjectFiles()\PanelState$, 1)
            EndIf
            
            ; Now, make sure the directory is present (as one node)
            ;
            Directory$ = GetPathPart(ProjectFiles()\FileName$)
            If Right(Directory$, 1) = #Separator
              Directory$ = Left(Directory$, Len(Directory$)-1)
            EndIf
            
            FoundIndex = -1
            InsertIndex = -1
            last = CountGadgetItems(#GADGET_ProjectPanel)-1
            For i = BaseIndex+1 To last
              If GetGadgetItemData(#GADGET_ProjectPanel, i) = #ProjectPanel_Directory
                Select CompareDirectories(Directory$, GetGadgetItemText(#GADGET_ProjectPanel, i))
                  Case #PB_String_Lower
                    InsertIndex = i
                    Break
                    
                  Case #PB_String_Equal
                    FoundIndex = i
                    Break
                EndSelect
              EndIf
            Next i
            
            ; if no index found yet, we must append at the end
            If FoundIndex = -1 And InsertIndex = -1
              InsertIndex = CountGadgetItems(#GADGET_ProjectPanel)
            EndIf
            
            If FoundIndex = -1
              FoundIndex = InsertIndex
              AddGadgetItem(#GADGET_ProjectPanel, FoundIndex, Directory$, OptionalImageID(#IMAGE_ProjectPanel_Directory), 1) ; always level 1
              SetGadgetItemData(#GADGET_ProjectPanel, FoundIndex, #ProjectPanel_Directory)
              
              ; add the file
              ProjectPanel_AddFile(GetFilePart(ProjectFiles()\FileName$), FoundIndex, @ProjectFiles())
              
              ; apply the expand state of the added directory (its always at sublevel 1 here)
              If Mid(ProjectFiles()\PanelState$, 2, 1) <> "-"
                SetGadgetItemState(#GADGET_ProjectPanel, FoundIndex, #PB_Tree_Expanded)
              EndIf
            Else
              ; add the file
              ProjectPanel_AddFile(GetFilePart(ProjectFiles()\FileName$), FoundIndex, @ProjectFiles())
            EndIf
            
          EndIf
        EndIf
      Next ProjectFiles()
      
      If BaseNew And BaseState$ <> "-" ; expanded is default
        SetGadgetItemState(#GADGET_ProjectPanel, BaseIndex, #PB_Tree_Expanded)
      EndIf
      
      ; Remove any no longer present files
      ; Do this after the adding, so we do not remove, then re-add subdirectories if not needed
      ; Step backwards, so removing an item does not change the indexes of other items
      ;
      For i = CountGadgetItems(#GADGET_ProjectPanel)-1 To 0 Step -1
        *File = GetGadgetItemData(#GADGET_ProjectPanel, i)
        If ProjectPanel_IsFile(*File)
          found = 0
          ForEach ProjectFiles()
            If *File = @ProjectFiles()
              found = 1
              Break
            EndIf
          Next ProjectFiles()
          
          If found = 0
            ProjectPanel_RemoveFile(i)
            
            ; If we remove an item, it may remove its parents too, so we must check the index
            Count = CountGadgetItems(#GADGET_ProjectPanel)
            If i > Count ; the next loop will decrease by 1 and it will be perfect then
              i = Count
            EndIf
          EndIf
        EndIf
      Next i
      
    Else
      ; project was closed
      ClearGadgetItems(#GADGET_ProjectPanel)
      
    EndIf
  EndIf
  
EndProcedure


Procedure ProjectPanel_CreateFunction(*Entry.ToolsPanelEntry)
  
  ; Note: The ProjectPanel menu is created in CreateIDEPopupMenu() as the ProjectInfo uses it too
  ;
  TreeGadget(#GADGET_ProjectPanel, 0, 0, 0, 0)
  ProjectPanelVisible = #True
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_ProjectPanel)
  EndIf
  
  UpdateProjectPanel()
  
EndProcedure

Procedure ProjectPanel_DestroyFunction(*Entry.ToolsPanelEntry)
  
  StoreProjectPanelStates() ; store expanded states
  
  FreeGadget(#GADGET_ProjectPanel)
  ProjectPanelVisible = #False
  
EndProcedure

Procedure ProjectPanel_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  If *Entry\IsSeparateWindow
    ResizeGadget(#GADGET_ProjectPanel, 5, 5, PanelWidth-10, PanelHeight-10)
  Else
    ResizeGadget(#GADGET_ProjectPanel, 0, 0, PanelWidth, PanelHeight)
  EndIf
  
EndProcedure

; The Menu is re-used by the ProjectInfo file list
; *Entry is 0 in this case
;
Procedure DisplayProjectPanelMenu(*Entry.ToolsPanelEntry, SourceGadget)
  ProjectPanelMenuGadget = SourceGadget
  Index = GetGadgetState(SourceGadget)
  
  ; The Add entry is always on
  If Index = -1
    DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Open, #True)
    DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenViewer, #True)
    DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenExplorer, #True)
    DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Rescan, #True)
    DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Remove, #True)
  Else
    *File.ProjectFile = GetGadgetItemData(SourceGadget, Index)
    If ProjectPanel_IsFile(*File)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Open, #False)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenViewer, #False)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenExplorer, #False)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Remove, #False)
      
      ; In ProjectInfo mode, there is multiselect, so do not disable this item then
      If *Entry = 0 Or *File\AutoScan
        DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Rescan, #False)
      Else
        DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Rescan, #True)
      EndIf
    Else
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Open, #False)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenViewer, #False)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Remove, #True)
      DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_Rescan, #False) ; can re-scan a full directory
      
      If *File = #ProjectPanel_ExternalBase
        DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenExplorer, #True)
      Else
        DisableMenuItem(#POPUPMENU_ProjectPanel, #MENU_ProjectPanel_OpenExplorer, #False)
      EndIf
    EndIf
  EndIf
  
  If *Entry And *Entry\IsSeparateWindow
    DisplayPopupMenu(#POPUPMENU_ProjectPanel, WindowID(*Entry\ToolWindowID))
  Else
    DisplayPopupMenu(#POPUPMENU_ProjectPanel, WindowID(#WINDOW_Main))
  EndIf
EndProcedure

Procedure ProjectPanelMenuEvent(MenuItemID)
  ; Make a list of all files that are selected with this entry (subitems)
  ; This handler is only called with real menu events, so there is no slowdown here
  ; (unlike the ProjectPanel_EventHandler() which gets called with other gadget events)
  ;
  Protected NewList *Files.ProjectFile()
  
  SelectedFolder$ = ""
  
  Index = GetGadgetState(ProjectPanelMenuGadget)
  If Index <> -1
    If ProjectPanelMenuGadget = #GADGET_ProjectPanel
      ; ProjectPanel mode (its a tree gadget)
      *File.ProjectFile = GetGadgetItemData(ProjectPanelMenuGadget, Index)
      If ProjectPanel_IsFile(*File)
        AddElement(*Files())
        *Files() = *File
        SelectedFolder$ = GetPathPart(*File\FileName$)
      Else
        SelectedFolder$ = ProjectPanel_FullPath(Index)
        
        Sublevel = GetGadgetItemAttribute(ProjectPanelMenuGadget, Index, #PB_Tree_SubLevel)
        Count    = CountGadgetItems(ProjectPanelMenuGadget)
        Index    + 1
        While Index < Count And GetGadgetItemAttribute(ProjectPanelMenuGadget, Index, #PB_Tree_SubLevel) > Sublevel
          *File = GetGadgetItemData(ProjectPanelMenuGadget, Index)
          If ProjectPanel_IsFile(*File)
            AddElement(*Files())
            *Files() = *File
          EndIf
          Index + 1
        Wend
      EndIf
      
    Else
      ; ProjectInfo mode (its a multiselect ListIcon)
      Last = CountGadgetItems(ProjectPanelMenuGadget) - 1
      For i = 0 To Last
        If GetGadgetItemState(ProjectPanelMenuGadget, i) & #PB_ListIcon_Selected
          AddElement(*Files())
          *Files() = GetGadgetItemData(ProjectPanelMenuGadget, i) ; stores the ProjectFile pointer
          
          ; The option applies only to the first file here
          If SelectedFolder$ = ""
            SelectedFolder$ = GetPathPart(*Files()\Filename$)
          EndIf
        EndIf
      Next i
    EndIf
    
  EndIf
  
  Select MenuItemID
      
    Case #MENU_ProjectPanel_Open
      ForEach *Files()
        LoadSourceFile(*Files()\FileName$)
      Next *Files()
      
    Case #MENU_ProjectPanel_OpenViewer
      ForEach *Files()
        FileViewer_OpenFile(*Files()\FileName$)
      Next *Files()
      
    Case #MENU_ProjectPanel_OpenExplorer
      If SelectedFolder$
        ShowExplorerDirectory(SelectedFolder$)
      EndIf
      
    Case #MENU_ProjectPanel_Rescan
      ForEach *Files()
        If *Files()\AutoScan And *Files()\Source = 0 ; no need to re-scan if currently open
          ScanFile(*Files()\Filename$, @*Files()\Parser)
        EndIf
      Next *Files()
      
    Case #MENU_ProjectPanel_Add
      FileName$ = OpenFileRequester(Language("FileStuff","OpenFileTitle"), GetPathPart(ProjectFile$), Language("FileStuff","Pattern"), SelectedFilePattern, #PB_Requester_MultiSelection)
      If FileName$ <> ""
        SelectedFilePattern = SelectedFilePattern()
        
        While FileName$ <> ""
          found = 0
          ForEach ProjectFiles()
            If IsEqualFile(ProjectFiles()\FileName$, FileName$)
              found = 1
              Break
            EndIf
          Next ProjectFiles()
          
          If found = 0
            Debug FileName$
            
            ; If the file doesn't exist, ask to create it, to ease the integration
            ; https://www.purebasic.fr/english/viewtopic.php?f=4&t=47521
            ;
            If FileSize(FileName$) < 0
              If MessageRequester(Language("FileStuff","AddNewFileTitle"), LanguagePattern("FileStuff","AddNewFileQuestion", "%filename%", Filename$), #PB_MessageRequester_YesNo | #FLAG_Question) = #PB_MessageRequester_Yes
                NewFile = CreateFile(#PB_Any, FileName$)
                If NewFile
                  CloseFile(NewFile)
                Else
                  MessageRequester(Language("FileStuff","AddNewFileTitle"), LanguagePattern("FileStuff","AddNewFileError", "%filename%", Filename$), #PB_MessageRequester_Ok | #FLAG_Error)
                EndIf
              EndIf
            EndIf
            
            LastElement(ProjectFiles())
            AddElement(ProjectFiles())
            ProjectFiles()\FileName$   = FileName$
            ProjectFiles()\AutoLoad    = 0
            ProjectFiles()\AutoScan    = IsCodeFile(Filename$)
            ProjectFiles()\ShowPanel   = 1
            ProjectFiles()\ShowWarning = 1
            UpdateProjectFile(@ProjectFiles())
          EndIf
          
          FileName$ = NextSelectedFileName()
        Wend
        
        UpdateMenuStates()
        UpdateProjectInfo()
        UpdateProjectPanel()
      EndIf
      
    Case #MENU_ProjectPanel_Remove
      If ListSize(*Files()) <= 1 Or MessageRequester(#ProductName$, LanguagePattern("Project","RemoveMany", "%count%", Str(ListSize(*Files()))), #PB_MessageRequester_YesNo|#FLAG_Question) = #PB_MessageRequester_Yes
        ForEach *Files()
          If *Files()\Source
            UnlinkSourceFromProject(*Files()\Source, #False)
          EndIf
          
          ClearProjectFile(*Files())
          ChangeCurrentElement(ProjectFiles(), *Files())
          DeleteElement(ProjectFiles())
        Next *Files()
        
        UpdateMenuStates()  ; reflect the changed settings
        UpdateProjectInfo()
        UpdateProjectPanel()
      EndIf
      
  EndSelect
  
EndProcedure




Procedure ProjectPanel_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  
  If EventGadgetID = #GADGET_ProjectPanel
    Index = GetGadgetState(#GADGET_ProjectPanel)
    
    Select EventType()
        
      Case #PB_EventType_DragStart
        If Index <> -1
          *File.ProjectFile = GetGadgetItemData(#GADGET_ProjectPanel, Index)
          If ProjectPanel_IsFile(*File)
            ; its a single file
            DragFiles(*File\FileName$)
            
          ElseIf *File = #ProjectPanel_Directory
            ; its a directory
            Files$   = ""
            Sublevel = GetGadgetItemAttribute(#GADGET_ProjectPanel, Index, #PB_Tree_SubLevel)
            Count    = CountGadgetItems(#GADGET_ProjectPanel)
            Index    + 1
            While Index < Count And GetGadgetItemAttribute(#GADGET_ProjectPanel, Index, #PB_Tree_SubLevel) > Sublevel
              *File = GetGadgetItemData(#GADGET_ProjectPanel, Index)
              If ProjectPanel_IsFile(*File)
                Files$ + *File\FileName$ + Chr(10)
              EndIf
              Index + 1
            Wend
            If Files$ <> ""
              DragFiles(Left(Files$, Len(Files$)-1)) ; cut the last Chr(10)
            EndIf
            
          EndIf
        EndIf
        
      Case #PB_EventType_LeftDoubleClick
        If Index <> -1
          *File.ProjectFile = GetGadgetItemData(#GADGET_ProjectPanel, Index)
          If ProjectPanel_IsFile(*File)
            LoadSourceFile(*File\FileName$, 1, 0) ; will just switch if open
          EndIf
        EndIf
        
      Case #PB_EventType_RightClick
        DisplayProjectPanelMenu(*Entry, #GADGET_ProjectPanel)
        
    EndSelect
    
  EndIf
  
EndProcedure





;- Initialisation code
; This will make this Tool available to the editor
;
ProjectPanel_VT.ToolsPanelFunctions

ProjectPanel_VT\CreateFunction   = @ProjectPanel_CreateFunction()
ProjectPanel_VT\DestroyFunction  = @ProjectPanel_DestroyFunction()
ProjectPanel_VT\ResizeHandler    = @ProjectPanel_ResizeHandler()
ProjectPanel_VT\EventHandler     = @ProjectPanel_EventHandler()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @ProjectPanel_VT
AvailablePanelTools()\NeedPreferences      = 0
AvailablePanelTools()\NeedConfiguration    = 0
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "ProjectPanel"
AvailablePanelTools()\PanelTitle$          = "ProjectPanelShort"
AvailablePanelTools()\ToolName$            = "ProjectPanelLong"
AvailablePanelTools()\PanelTabOrder        = 2


