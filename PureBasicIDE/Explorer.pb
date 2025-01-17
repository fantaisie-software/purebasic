; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Note: The Explorer stores it's values in global variables instead of in the
; ToolsPanelEntry structure, because other editor parts (like FileViewer) access them
; as well.

Global Backup_ExplorerMode, Backup_ExplorerSavePath, Backup_ExplorerShowHidden
Global ExplorerSplitterApplied
Global *Explorer.ToolsPanelEntry ; for prefs creation
Global NewList ExplorerFavorites.s()

; Now also used by the Project management file explorer
;
Procedure UpdateExplorerPatterns()
  
  If ExplorerMode <> -1
    IsPattern = IsGadget(#GADGET_Explorer_Pattern)
  Else
    IsPattern = 0
  EndIf
  
  ; This is not present on OSX, and not when the projects window is closed
  IsProjectPattern = IsGadget(#GADGET_Project_ExplorerPattern)
  
  Count = 0
  
  If IsPattern
    ClearGadgetItems(#GADGET_Explorer_Pattern)
  EndIf
  If IsProjectPattern
    ClearGadgetItems(#GADGET_Project_ExplorerPattern)
  EndIf
  
  ExplorerPatternStrings$ = ""
  
  ; include the patterns from the AddTools menu
  ;
  i = 1
  While StringField(AddTools_PatternStrings$, i, "|") <> ""
    If IsPattern
      AddGadgetItem(#GADGET_Explorer_Pattern, -1, StringField(AddTools_PatternStrings$, i, "|"))
    EndIf
    If IsProjectPattern
      AddGadgetItem(#GADGET_Project_ExplorerPattern, -1, StringField(AddTools_PatternStrings$, i, "|"))
    EndIf
    
    ExplorerPatternStrings$ + StringField(AddTools_PatternStrings$, i+1, "|") + "|"
    i + 2
    Count + 1
  Wend
  
  ; read patterns from OpenFile() pattern (don't include the *.* one!)
  ;
  Pattern$ = Language("FileStuff","Pattern")
  For i = 1 To 9 Step 2
    If IsPattern
      AddGadgetItem(#GADGET_Explorer_Pattern, -1, StringField(Pattern$, i, "|"))
    EndIf
    If IsProjectPattern
      AddGadgetItem(#GADGET_Project_ExplorerPattern, -1, StringField(Pattern$, i, "|"))
    EndIf
    
    ExplorerPatternStrings$ + StringField(Pattern$, i+1, "|") + "|"
    Count + 1
  Next i
  
  ; read patterns from FileViewer patterns
  ;
  Pattern$ = Language("FileViewer","Pattern")
  CompilerIf #CompileWindows = 0
    ; have to remove the .ico pattern...
    ; it is a language string, so catch multiple forms
    Pattern$ = RemoveString(Pattern$, ", *.ico")
    Pattern$ = RemoveString(Pattern$, ",*.ico")
    Pattern$ = RemoveString(Pattern$, ";*.ico")
  CompilerEndIf
  
  i = 1
  Repeat
    Name$ = StringField(Pattern$, i, "|")
    If Name$ = ""
      Break
    EndIf
    
    If IsPattern
      AddGadgetItem(#GADGET_Explorer_Pattern, -1, Name$)
    EndIf
    If IsProjectPattern
      AddGadgetItem(#GADGET_Project_ExplorerPattern, -1, Name$)
    EndIf
    
    
    ExplorerPatternStrings$ + StringField(Pattern$, i+1, "|") + "|"
    i + 2
    Count + 1
  ForEver
  
  
  ; sanitize the selected patterns to avoid a crash when it is too high (may happen if you remove a tool!)
  ;
  If ExplorerPattern >= Count Or ExplorerPattern < -1
    ExplorerPattern = 0
  EndIf
  
  If ProjectExplorerPattern >= Count Or ProjectExplorerPattern < -1
    ProjectExplorerPattern = 0
  EndIf
  
  
  If IsPattern
    SetGadgetState(#GADGET_Explorer_Pattern, ExplorerPattern)
  EndIf
  
  If IsProjectPattern
    SetGadgetState(#GADGET_Project_ExplorerPattern, ProjectExplorerPattern)
  EndIf
  
EndProcedure

; Add favorites entry at the given position in the gadget
;
Procedure InsertFavorite(Position, Entry$)
  If Right(Entry$, 1) = #Separator
    ImageID = OptionalImageID(#IMAGE_Explorer_Directory)
    Name$ = GetFilePart(Left(Entry$, Len(Entry$)-1))
    If Name$ = "" ; It's root drive (C:\) (https://www.purebasic.fr/english/viewtopic.php?f=4&t=53810)
      Name$ = Left(Entry$, Len(Entry$)-1)
    EndIf
  Else
    Name$ = GetFilePart(Entry$)
    
    If IsPureBasicFile(Name$)
      ImageID = OptionalImageID(#IMAGE_Explorer_FilePB)
    Else
      ImageID = OptionalImageID(#IMAGE_Explorer_File)
    EndIf
  EndIf
  AddGadgetItem(#GADGET_Explorer_Favorites, Position, Name$, ImageID)
EndProcedure


Procedure Explorer_CreateFunction(*Entry.ToolsPanelEntry)
  
  ComboBoxGadget(#GADGET_Explorer_Pattern, 0, 0, 0, 0)
  UpdateExplorerPatterns()
  
  If Right(ExplorerPath$, 1) <> #Separator
    ExplorerPath$ + #Separator
  EndIf
  
  CompilerIf #CompileMac
    ExplorerPatternStrings$ = "" ; patterns not supported on mac yet
    FreeGadget(#GADGET_Explorer_Pattern)
  CompilerEndIf
  
  ExtraFlags = 0
  CompilerIf #CompileWindows = 0 ; so far not existing on windows
    If ExplorerShowHidden
      ExtraFlags = #PB_Explorer_HiddenFiles
    EndIf
  CompilerEndIf
  
  If ExplorerMode = 0
    ExplorerListGadget(#GADGET_Explorer, 0, 0, 0, 0, ExplorerPath$+StringField(ExplorerPatternStrings$, ExplorerPattern+1, "|"), #PB_Explorer_MultiSelect | #PB_Explorer_AutoSort | #PB_Explorer_FullRowSelect | ExtraFlags)
    
    CompilerIf #CompileMac = 0 ; on linux, there are 4 columns by default now too
      RemoveGadgetColumn(#GADGET_Explorer, 1)
      RemoveGadgetColumn(#GADGET_Explorer, 1)
      RemoveGadgetColumn(#GADGET_Explorer, 1)
    CompilerEndIf
    
    SetGadgetItemAttribute(#GADGET_Explorer, 0, #PB_Explorer_ColumnWidth, 150, 0)
  Else
    ExplorerTreeGadget(#GADGET_Explorer, 0, 0, 0, 0, ExplorerPath$+StringField(ExplorerPatternStrings$, ExplorerPattern+1, "|"), #PB_Explorer_AutoSort | ExtraFlags)
  EndIf
  
  ListIconGadget(#GADGET_Explorer_Favorites, 0, 0, 150, 0, Language("ToolsPanel","Favorites"), 150)
  SplitterGadget(#GADGET_Explorer_Splitter, 0, 0, 0, 0, #GADGET_Explorer, #GADGET_Explorer_Favorites, #PB_Splitter_SecondFixed)
  
  ButtonImageGadget(#GADGET_Explorer_AddFavorite, 0, 0, 0, 0, ImageID(#IMAGE_Explorer_AddFavorite))
  ButtonImageGadget(#GADGET_Explorer_RemoveFavorite, 0, 0, 0, 0, ImageID(#IMAGE_Explorer_RemoveFavorite))
  
  GadgetToolTip(#GADGET_Explorer_AddFavorite, Language("ToolsPanel","AddFavorite"))
  GadgetToolTip(#GADGET_Explorer_RemoveFavorite, Language("ToolsPanel","RemoveFavorite"))
  
  EnableGadgetDrop(#GADGET_Explorer_Favorites, #PB_Drop_Files, #PB_Drag_Copy)
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_Explorer)
    ToolsPanel_ApplyColors(#GADGET_Explorer_Favorites)
  EndIf
  
  ; apply the splitter position after the resize only
  ExplorerSplitterApplied = #False
  
  ; fill favorites list
  ForEach ExplorerFavorites()
    InsertFavorite(-1, ExplorerFavorites())
  Next ExplorerFavorites()
  
EndProcedure


Procedure Explorer_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  ; All the buttons should have the same size, so only call it once
  ;
  GetRequiredSize(#GADGET_Explorer_AddFavorite, @Width.l, @Height.l)
  
  CompilerIf #CompileWindows
    Space = 3
  CompilerElse
    Space = 6 ; looks better on Linux/OSX with some more space
  CompilerEndIf
  
  If *Entry\IsSeparateWindow
    CompilerIf #CompileWindows | #CompileLinux
      PatternHeight = GetRequiredHeight(#GADGET_Explorer_Pattern)
      ResizeGadget(#GADGET_Explorer_Pattern, 5, 5, PanelWidth-10, PatternHeight)
      ResizeGadget(#GADGET_Explorer_Splitter, 5, 10+PatternHeight, PanelWidth-10, PanelHeight-15-PatternHeight-Height)
    CompilerElse
      ResizeGadget(#GADGET_Explorer_Splitter, 5, 5, PanelWidth-10, PanelHeight-10-Height)
    CompilerEndIf
    ResizeGadget(#GADGET_Explorer_AddFavorite, PanelWidth-5-Space-2*Width, PanelHeight-Height, Width, Height)
    ResizeGadget(#GADGET_Explorer_RemoveFavorite, PanelWidth-5-Width, PanelHeight-Height, Width, Height)
  Else
    CompilerIf #CompileWindows | #CompileLinux
      PatternHeight = GetRequiredHeight(#GADGET_Explorer_Pattern)
      ResizeGadget(#GADGET_Explorer_Pattern, 0, 0, PanelWidth, PatternHeight)
      ResizeGadget(#GADGET_Explorer_Splitter, 0, PatternHeight+1, PanelWidth, PanelHeight-PatternHeight-7-Height)
    CompilerElse
      ResizeGadget(#GADGET_Explorer_Splitter, 0, 0, PanelWidth, PanelHeight-6-Height)
    CompilerEndIf
    ResizeGadget(#GADGET_Explorer_AddFavorite, PanelWidth-Space-2*Width, PanelHeight-Height-2, Width, Height)
    ResizeGadget(#GADGET_Explorer_RemoveFavorite, PanelWidth-Width, PanelHeight-Height-2, Width, Height)
  EndIf
  
  If ExplorerMode = 0
    SetGadgetItemAttribute(#GADGET_Explorer, 0, #PB_Explorer_ColumnWidth, GadgetWidth(#GADGET_Explorer)-8, 0)
  EndIf
  SetGadgetItemAttribute(#GADGET_Explorer_Favorites, 0, #PB_ListIcon_ColumnWidth, GadgetWidth(#GADGET_Explorer_Favorites)-8, 0)
  
  If GadgetHeight(#GADGET_Explorer_Splitter) > 0
    If ExplorerSplitterApplied = #False
      SetGadgetState(#GADGET_Explorer_Splitter, GadgetHeight(#GADGET_Explorer_Splitter)-ExplorerSplitter)
      ExplorerSplitterApplied = #True
    Else
      ExplorerSplitter = GadgetHeight(#GADGET_Explorer_Splitter) - GetGadgetState(#GADGET_Explorer_Splitter)
    EndIf
  EndIf
  
EndProcedure

; start enumeration of explorer entries
;
Procedure ExamineExplorerEntries(FilesOnly)
  Shared Explorer_CurrentItem, Explorer_FilesOnly
  
  Explorer_CurrentItem = 0
  Explorer_FilesOnly = FilesOnly
EndProcedure

; get next explorer entry (full path) or ""
;
Procedure.s NextExplorerEntry()
  Shared Explorer_CurrentItem, Explorer_FilesOnly
  Result$ = ""
  
  If ExplorerMode = 0 ; ExplorerList
    
    While Result$ = "" And Explorer_CurrentItem < CountGadgetItems(#GADGET_Explorer)
      If GetGadgetItemState(#GADGET_Explorer, Explorer_CurrentItem) & #PB_Explorer_Selected
        Entry$ = GetGadgetItemText(#GADGET_Explorer, Explorer_CurrentItem, 0)
        Directory$ = GetGadgetText(#GADGET_Explorer)
        
        If GetGadgetItemState(#GADGET_Explorer, Explorer_CurrentItem) & #PB_Explorer_File
          Result$ = ResolveRelativePath(CurrentDirectory$, Directory$ + Entry$) ; Ensure we really have a full path (use the initial current directory if not: https://www.purebasic.fr/english/viewtopic.php?f=4&t=55801)
          
        ElseIf Explorer_FilesOnly = 0
          Result$ = Directory$ + Entry$ + #Separator ; to distinguish directories
        EndIf
        
      EndIf
      Explorer_CurrentItem + 1
    Wend
    
  Else ; ExplorerTree
    
    ; one entry only
    If Explorer_CurrentItem = 0
      Explorer_CurrentItem = 1
      If GetGadgetState(#GADGET_Explorer) & #PB_Explorer_File
        Result$ = ResolveRelativePath(CurrentDirectory$, GetGadgetText(#GADGET_Explorer)) ; Ensure we really have a full path (use the initial current directory if not: https://www.purebasic.fr/english/viewtopic.php?f=4&t=55801)
        
      ElseIf Explorer_FilesOnly = 0
        Result$ = GetGadgetText(#GADGET_Explorer) + #Separator ; to distinguish directories
      EndIf
    EndIf
    
  EndIf
  
  ProcedureReturn Result$
EndProcedure

Procedure Explorer_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  
  Select EventGadgetID
      
    Case #GADGET_Explorer_AddFavorite
      ExamineExplorerEntries(#False)
      LastElement(ExplorerFavorites())
      Repeat
        FileName$ = NextExplorerEntry()
        If FileName$ <> ""
          ; remove duplicates
          ForEach ExplorerFavorites()
            If IsEqualFile(FileName$, ExplorerFavorites())
              RemoveGadgetItem(#GADGET_Explorer_Favorites, ListIndex(ExplorerFavorites()))
              DeleteElement(ExplorerFavorites())
            EndIf
          Next ExplorerFavorites()
          
          LastElement(ExplorerFavorites())
          AddElement(ExplorerFavorites())
          ExplorerFavorites() = FileName$
          InsertFavorite(-1, FileName$)
        EndIf
      Until FileName$ = ""
      
    Case #GADGET_Explorer_RemoveFavorite
      Index = GetGadgetState(#GADGET_Explorer_Favorites)
      If Index <> -1
        SelectElement(ExplorerFavorites(), Index)
        DeleteElement(ExplorerFavorites())
        RemoveGadgetItem(#GADGET_Explorer_Favorites, Index)
      EndIf
      
    Case #GADGET_Explorer_Favorites
      Index = GetGadgetState(#GADGET_Explorer_Favorites)
      If Index <> -1
        SelectElement(ExplorerFavorites(), Index)
        Entry$ = ExplorerFavorites()
        
        If EventType() = #PB_EventType_LeftDoubleClick
          If Right(Entry$, 1) = #Separator
            ; open directory in explorer
            SetGadgetText(#GADGET_Explorer, Entry$)
          Else
            ; open file
            LoadSourceFile(Entry$)
          EndIf
          
        ElseIf EventType() = #PB_EventType_DragStart
          DragFiles(Entry$, #PB_Drag_Copy)
          
        EndIf
        
      EndIf
      
    Case #GADGET_Explorer_Pattern
      If GetGadgetState(#GADGET_Explorer_Pattern) <> ExplorerPattern
        ExplorerPattern = GetGadgetState(#GADGET_Explorer_Pattern)
        SetGadgetText(#GADGET_Explorer, StringField(ExplorerPatternStrings$, ExplorerPattern+1, "|"))
      EndIf
      
      
    Case #GADGET_Explorer
      ExplorerPath$ = GetPathPart(GetGadgetText(#GADGET_Explorer))
      
      If EventType() = #PB_EventType_DragStart
        Files$ = ""
        Count  = CountGadgetItems(#GADGET_Explorer)
        For i  = 0 To Count-1
          If GetGadgetItemState(#GADGET_Explorer, i) & #PB_Explorer_Selected And GetGadgetItemText(#GADGET_Explorer, i, 0) <> ".."
            Files$ + GetGadgetText(#GADGET_Explorer) + GetGadgetItemText(#GADGET_Explorer, i, 0) + Chr(10)
          EndIf
        Next i
        
        If Files$ <> ""
          Files$ = Left(Files$, Len(Files$)-1)
          
          ; Drag only the filename when "alt" is pressed, so we can drag filenames
          ; to the source code which is quite cool
          ;
          ; Does not work on Linux, so lets keep it commented for now
          ;
          ;           If ModifierKeyPressed(#PB_Shortcut_Alt)
          ;             ; We must offer #PB_Drag_Move, as else Scintilla will not accept the drop, because the ALT key
          ;             ; indicates a move operation.
          ;             ;
          ;             DragText(ReplaceString(Files$, Chr(10), #NewLine), #PB_Drag_Copy|#PB_Drag_Move)
          ;           Else
          DragFiles(Files$, #PB_Drag_Copy)
          ;           EndIf
        EndIf
        
      ElseIf EventType() = #PB_EventType_LeftDoubleClick
        
        ExamineExplorerEntries(#True)
        Repeat
          FileName$ = NextExplorerEntry()
          If FileName$ <> ""
            LoadSourceFile(FileName$)
            
            ; Flush events. So when many sources are opened at once, the User can see a bit the
            ; progress, instead of just an unresponsive window for quite a while.
            ; There is almost no flicker anymore, so it actually looks quite good.
            ;
            ; Note: don't put this in the LoadSourceFile() routine as it can be call from the debugger and flushing the event will get another debug event !
            FlushEvents()
          EndIf
        Until FileName$ = ""
        
      EndIf
      
  EndSelect
  
EndProcedure

Procedure Explorer_FavoritesDropEvent()
  
  Position = GetGadgetState(#GADGET_Explorer_Favorites)
  File$ = StringField(EventDropFiles(), 1, Chr(10)) ; use only the first, ignore the rest
  Count = CountString(Files$, Chr(10)) + 1
  
  If Position < 0
    Position = 9999999 ; insert last
  EndIf
  
  ; make sure directories end with a separator
  If Right(File$, 1) <> #Separator
    If FileSize(File$) = -2
      File$ + #Separator
    EndIf
  EndIf
  
  ; remove any old entries equal to the dragged ones
  ForEach ExplorerFavorites()
    If IsEqualFile(File$, ExplorerFavorites())
      If ListIndex(ExplorerFavorites()) < Position
        ; deleted something before the new insert position so decrease it
        Position - 1
      EndIf
      RemoveGadgetItem(#GADGET_Explorer_Favorites, ListIndex(ExplorerFavorites()))
      DeleteElement(ExplorerFavorites())
    EndIf
  Next ExplorerFavorites()
  
  ; add the result
  If Position <= 0
    ResetList(ExplorerFavorites())
    AddElement(ExplorerFavorites())
  ElseIf Position < ListSize(ExplorerFavorites())
    SelectElement(ExplorerFavorites(), Position)
    InsertElement(ExplorerFavorites())
  Else
    LastElement(ExplorerFavorites())
    AddElement(ExplorerFavorites())
  EndIf
  ExplorerFavorites() = File$
  InsertFavorite(ListIndex(ExplorerFavorites()), File$)
  
EndProcedure


Procedure Explorer_PreferenceLoad(*Entry.ToolsPanelEntry)
  
  PreferenceGroup("Explorer")
  ExplorerMode               = ReadPreferenceLong  ("Mode", 0) ; 0=ExplorerList 1=ExplorerTree
  ExplorerPattern            = ReadPreferenceLong  ("Pattern", 0)
  ExplorerSavePath           = ReadPreferenceLong  ("SavePath", 1)
  ExplorerShowHidden         = ReadPreferenceLong  ("ShowHidden", 0)
  ExplorerSplitter           = ReadPreferenceLong  ("Splitter", 90)
  
  If ExplorerPath$ = "" ; only load this if not set by commandline
    ExplorerPath$            = ReadPreferenceString("Path", SourcePath$)
  EndIf
  
  Count = ReadPreferenceLong("Favorites", 0)
  ClearList(ExplorerFavorites())
  For i = 1 To Count
    Fav$ = ReadPreferenceString("Fav" + Str(i), "")
    If Fav$ <> ""
      AddElement(ExplorerFavorites())
      ExplorerFavorites() = Fav$
    EndIf
  Next i
  
EndProcedure


Procedure Explorer_PreferenceSave(*Entry.ToolsPanelEntry)
  
  PreferenceComment("")
  PreferenceGroup("Explorer")
  WritePreferenceLong  ("Mode",       ExplorerMode)
  WritePreferenceLong  ("Pattern",    ExplorerPattern)
  WritePreferenceLong  ("SavePath",   ExplorerSavePath)
  WritePreferenceLong  ("ShowHidden", ExplorerShowHidden)
  WritePreferenceLong  ("Splitter",   ExplorerSplitter)
  
  If ExplorerSavePath
    WritePreferenceString("Path",     ExplorerPath$)
  EndIf
  
  WritePreferenceLong("Favorites", ListSize(ExplorerFavorites()))
  ForEach ExplorerFavorites()
    WritePreferenceString("Fav" + Str(ListIndex(ExplorerFavorites())+1), ExplorerFavorites())
  Next ExplorerFavorites()
  
EndProcedure



Procedure Explorer_PreferenceStart(*Entry.ToolsPanelEntry)
  
  ; Use the backup variable during the PReferences changing
  Backup_ExplorerMode       = ExplorerMode
  Backup_ExplorerSavePath   = ExplorerSavePath
  Backup_ExplorerShowHidden = ExplorerShowHidden
  
EndProcedure


Procedure Explorer_PreferenceApply(*Entry.ToolsPanelEntry)
  
  ; put the backup variable back
  ExplorerMode       = Backup_ExplorerMode
  ExplorerSavePath   = Backup_ExplorerSavePath
  ExplorerShowHidden = Backup_ExplorerShowHidden
  
EndProcedure



Procedure Explorer_PreferenceCreate(*Entry.ToolsPanelEntry)
  
  Top = 10
  text = TextGadget(#PB_Any, 10, Top, 300, 25, Language("Preferences","ExplorerMode")+":"): Top + 25
  OptionGadget(#GADGET_Preferences_ExplorerMode0, 10, Top, 300, 25, Language("Preferences","ExplorerList")): Top + 25
  OptionGadget(#GADGET_Preferences_ExplorerMode1, 10, Top, 300, 25, Language("Preferences","ExplorerTree")): Top + 35
  
  CheckBoxGadget(#GADGET_Preferences_ExplorerSavePath, 10, Top, 300, 25, Language("Preferences","ExplorerSavePath")): Top + 25
  CheckBoxGadget(#GADGET_Preferences_ExplorerShowHidden, 10, Top, 300, 25, Language("Preferences","ShowHiddenFiles"))
  
  GetRequiredSize(#GADGET_Preferences_ExplorerMode0, @Width, @Height)
  Width = Max(Width, GetRequiredWidth(text))
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ExplorerMode1))
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ExplorerSavePath))
  Width = Max(Width, GetRequiredWidth(#GADGET_Preferences_ExplorerShowHidden))
  
  Top = 10
  ResizeGadget(text, 10, Top, Width, Height): Top + Height + 5
  ResizeGadget(#GADGET_Preferences_ExplorerMode0, 10, Top, Width, Height): Top + Height + 5
  ResizeGadget(#GADGET_Preferences_ExplorerMode1, 10, Top, Width, Height): Top + Height + 15
  ResizeGadget(#GADGET_Preferences_ExplorerSavePath, 10, Top, Width, Height): Top + Height + 5
  ResizeGadget(#GADGET_Preferences_ExplorerShowHidden, 10, Top, Width, Height): Top + Height + 10
  
  *Explorer\PreferencesWidth  = Max(320, Width) ; update sizes
  *Explorer\PreferencesHeight = Top
  
  CompilerIf #CompileWindows
    SetGadgetState(#GADGET_Preferences_ExplorerShowHidden, 1) ; No flag for this on windows.
    DisableGadget(#GADGET_Preferences_ExplorerShowHidden, 1)
  CompilerElse
    SetGadgetState(#GADGET_Preferences_ExplorerShowHidden, ExplorerShowHidden)
  CompilerEndIf
  
  CompilerIf #CompileMac
    SetGadgetState(#GADGET_Preferences_ExplorerMode0, 1)  ; ExplorerTree not working on OSX
    DisableGadget(#GADGET_Preferences_ExplorerMode1, 1)
  CompilerElse
    SetGadgetState(#GADGET_Preferences_ExplorerMode0 + Backup_ExplorerMode, 1)
  CompilerEndIf
  
  SetGadgetState(#GADGET_Preferences_ExplorerSavePath, Backup_ExplorerSavePath)
  
EndProcedure


Procedure Explorer_PreferenceDestroy(*Entry.ToolsPanelEntry)
  
  ; gadgets will be removed automatically.. just save the configuration here.
  
  If GetGadgetState(#GADGET_Preferences_ExplorerMode0)
    Backup_ExplorerMode = 0
  Else
    Backup_ExplorerMode = 1
  EndIf
  
  Backup_ExplorerShowHidden = GetGadgetState(#GADGET_Preferences_ExplorerShowHidden)
  Backup_ExplorerSavePath   = GetGadgetState(#GADGET_Preferences_ExplorerSavePath)
  
EndProcedure


Procedure Explorer_PreferenceEvents(*Entry.ToolsPanelEntry, EventGadgetID)
  ;
  ; nothing to do here
  ;
EndProcedure

Procedure Explorer_PreferenceChanged(*Entry.ToolsPanelEntry, IsConfigOpen)
  
  If IsConfigOpen
    If (GetGadgetState(#GADGET_Preferences_ExplorerMode0) And ExplorerMode <> 0) Or (GetGadgetState(#GADGET_Preferences_ExplorerMode0) = 0 And ExplorerMode <> 1) Or ExplorerSavePath <> GetGadgetState(#GADGET_Preferences_ExplorerSavePath)
      ProcedureReturn 1
    EndIf
    
    CompilerIf #CompileWindows = 0 ; not supported there yet
      If ExplorerShowHidden <> GetGadgetState(#GADGET_Preferences_ExplorerShowHidden)
        ProcedureReturn 1
      EndIf
    CompilerEndIf
    
  Else
    If ExplorerMode <> Backup_ExplorerMode Or ExplorerSavePath <> Backup_ExplorerSavePath
      ProcedureReturn 1
    EndIf
    
    CompilerIf #CompileWindows = 0 ; not supported there yet
      If ExplorerShowHidden <> Backup_ExplorerShowHidden
        ProcedureReturn 1
      EndIf
    CompilerEndIf
    
  EndIf
  
  ProcedureReturn 0
EndProcedure


;- Initialisation code
; This will make this Tool available to the editor
;
Explorer_VT.ToolsPanelFunctions

Explorer_VT\CreateFunction      = @Explorer_CreateFunction()
Explorer_VT\ResizeHandler       = @Explorer_ResizeHandler()
Explorer_VT\EventHandler        = @Explorer_EventHandler()
Explorer_VT\PreferenceLoad      = @Explorer_PreferenceLoad()
Explorer_VT\PreferenceSave      = @Explorer_PreferenceSave()
Explorer_VT\PreferenceStart     = @Explorer_PreferenceStart()
Explorer_VT\PreferenceApply     = @Explorer_PreferenceApply()
Explorer_VT\PreferenceCreate    = @Explorer_PreferenceCreate()
Explorer_VT\PreferenceDestroy   = @Explorer_PreferenceDestroy()
Explorer_VT\PreferenceEvents    = @Explorer_PreferenceEvents()
Explorer_VT\PreferenceChanged   = @Explorer_PreferenceChanged()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @Explorer_VT
AvailablePanelTools()\NeedPreferences      = 1
AvailablePanelTools()\NeedConfiguration    = 1
AvailablePanelTools()\PreferencesWidth     = 320
AvailablePanelTools()\PreferencesHeight    = 145
AvailablePanelTools()\NeedDestroyFunction  = 0
AvailablePanelTools()\ToolID$              = "Explorer"
AvailablePanelTools()\PanelTitle$          = "Explorer"
AvailablePanelTools()\ToolName$            = "Explorer"
AvailablePanelTools()\PanelTabOrder        = 3

*Explorer = @AvailablePanelTools()
