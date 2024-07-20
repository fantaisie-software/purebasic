; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


#WINDOW_Grep_Width  = 480
#WINDOW_Grep_Height = 235

Global GrepAbort

; Procedure CheckGrepAbort()
;
;   Repeat
;     Event = WindowEvent()
;
;     CompilerIf #CompileWindows
;       CompilerEvents(Event)
;     CompilerEndIf
;
;     If EventWindow() = #WINDOW_Grep
;       If Event = #PB_EventGadget And EventGadget() = #GADGET_Grep_Stop
;         Result = 1
;       EndIf
;     EndIf
;
;   Until Event = 0
;
;   ProcedureReturn Result
;
; EndProcedure

Procedure UpdateFindComboBox(GadgetID) ; Works the same for find & replace combo
  
  Text$ = GetGadgetText(GadgetID)
  
  If Text$
    For k=1 To CountGadgetItems(GadgetID)
      If GetGadgetItemText(GadgetID, k-1, 0) = Text$
        RemoveGadgetItem(GadgetID, k-1)
        Break
      EndIf
    Next
    
    AddGadgetItem(GadgetID, 0, Text$) ; Insert at the top of the list
  EndIf
  
  While CountGadgetItems(GadgetID) > FindHistorySize
    RemoveGadgetItem(GadgetID, CountGadgetItems(GadgetID)-1)
  Wend
  
  SetGadgetText(GadgetID, Text$)
  
EndProcedure


Procedure DisableGrepWindow(State)
  
  DisableGadget(#GADGET_Grep_FindWord, State)
  
  DisableGadget(#GADGET_Grep_Directory, State)
  DisableGadget(#GADGET_Grep_SelectDirectory, State)
  
  DisableGadget(#GADGET_Grep_Pattern, State)
  
  DisableGadget(#GADGET_Grep_MatchCase, State)
  DisableGadget(#GADGET_Grep_Recurse, State)
  DisableGadget(#GADGET_Grep_WholeWord, State)
  DisableGadget(#GADGET_Grep_NoComments, State)
  DisableGadget(#GADGET_Grep_NoStrings, State)
  
  DisableGadget(#GADGET_Grep_Cancel, State)
  DisableGadget(#GADGET_Grep_Find, State)
  
  If State
    DisableGadget(#GADGET_Grep_Stop, 0)
  Else
    DisableGadget(#GADGET_Grep_Stop, 1)
  EndIf
  
EndProcedure


Procedure SearchStringInFile(FileID, Filename$, String$, InitialPathLength)
  Quit = 0
  
  If ReadFile(FileID, Filename$)
    
    StringMode   = ReadStringFormat(FileID)  ; try to detect UTF8 bom
    FileLength   = Lof(FileID) - Loc(FileID) ; subtract bom size
    StringLength = Len(String$)
    BinaryCount  = 0 ; with more than 10 nontext chars, we consider it binary
    
    If FileLength And StringLength
      
      *BufferStart = AllocateMemory(FileLength+10)
      If *BufferStart
        
        ReadData(FileID, *BufferStart, FileLength)
        
        Line = 1
        *Buffer.Ascii = *BufferStart
        *BufferEnd   = *Buffer+FileLength
        *LineStart   = *BufferStart
        
        *NextAbortChecked = *Buffer + 50000
        
        If StringMode = #PB_UTF8
          *String = UTF8(String$)
          StringLength = StringByteLength(String$, #PB_UTF8)
        Else
          *String = Ascii(String$)
        EndIf
        
        While *Buffer < *BufferEnd
          
          If *Buffer >= *NextAbortCheck
            FlushEvents()
            If GrepAbort
              Quit = 1
              Break
            EndIf
            *NextAbortChecked = *Buffer + 50000
          EndIf
          
          If CompareMemoryString(*Buffer, *String, 1-GrepCaseSensitive, StringLength, StringMode) = 0 ; we always need the flag now for UTF8 files support
            
            If GrepWholeWord = 0 Or ((*Buffer = *LineStart Or ValidCharacters(PeekA(*Buffer-1)) = 0) And (*Buffer+StringLength = *BufferEnd Or ValidCharacters(PeekB(*Buffer+StringLength) & $FF) = 0) )
              
              If BinaryCount > 10 ; its a binary file
                LogLine$ = Filename$+": " + Language("Find","BinaryFile") + " (" + Str(*Buffer-*BufferStart) + ")"
                *Buffer+1 ; move on!
                
              Else
                LineLength = 0
                
                ; Now, go to the end of line to isolate it
                ;
                *Buffer = *LineStart
                
                While *Buffer < *BufferEnd And *Buffer\a <> 13 And *Buffer\a <> 10
                  LineLength+1
                  *Buffer+1
                Wend
                
                ; Note: we don't include the Chr(13) or Chr(10), it will be processed again in the next loop
                ;
                *Buffer = *LineStart ; Reset the buffer to the start of the line, and add the line length
                *Buffer + LineLength
                
                ; LogLine$ = Right(Filename$, Len(Filename$)-InitialPathLength-1)+": "+Str(Line)+" - "+PeekS(*LineStart, LineLength)
                
                LogLine$ = Filename$+": "+Str(Line)+" - "+ReplaceString(PeekS(*LineStart, LineLength, StringMode), Chr(9), "  ") ; Replace all Tab with 2 spaces
              EndIf
              
              AddGadgetItem(#GADGET_GrepOutput_List, -1, LogLine$)
              NbGrepFiles+1
              
            Else
              *Buffer+1  ; if WholeWord case is not met, move on!
              
            EndIf
            
          ElseIf GrepNoComments And *Buffer\a = ';' And BinaryCount < 10
            While *Buffer\a And *Buffer\a <> 13 And *Buffer\a <> 10  ; just skip the line
              *Buffer+1
            Wend
            
          ElseIf GrepNoStrings And *Buffer\a = '"' And BinaryCount < 10
            *Buffer + 1
            While *Buffer\a And *Buffer\a <> 13 And *Buffer\a <> 10 And *Buffer\a <> '"'  ; just skip to the next " or line end
              *Buffer+1
            Wend
            If *Buffer\a = '"'  ; otherwise there is an endless loop
              *Buffer+1
            EndIf
            
          ElseIf GrepNoStrings And *Buffer\a = '~' And PeekA(*Buffer + 1) = '"'
            *Buffer + 2
            While *Buffer\a And *Buffer\a <> 13 And *Buffer\a <> 10 And *Buffer\a <> '"'
              If *Buffer\a = '\'
                *Buffer + 1 ; skip \
                If *Buffer\a And *Buffer\a <> 13 And *Buffer\a <> 10
                  *Buffer + 1 ; skip escaped char if this is not the end of the line
                EndIf
              Else
                *Buffer+1
              EndIf
            Wend
            If *Buffer\a = '"'  ; otherwise there is an endless loop
              *Buffer+1
            EndIf
            
          ElseIf *Buffer\a = 10  ; Unix files..
            
            Line+1
            *Buffer+1
            *LineStart = *Buffer
            
          ElseIf *Buffer\a = 13 ; DOS compatible file line ending
            
            Line+1
            *Buffer+1
            
            If *Buffer\a = 10 ; Test is wrong, not a CRLF file
              *Buffer+1
            EndIf
            
            *LineStart = *Buffer
          Else
            
            ; check for binary bytes
            If *Buffer\a < 32 And  *Buffer\a <> 9 ; newline chars already checked
              BinaryCount  + 1
            EndIf
            
            *Buffer+1  ; Default case, just go on the next byte
            
          EndIf
        Wend
        
        FreeMemory(*String)
        FreeMemory(*BufferStart)
      EndIf
    EndIf
    
    CloseFile(FileID)
  EndIf
  
  ProcedureReturn Quit
EndProcedure


Procedure Grep(DirectoryID, Directory$, String$, PatternList$, InitialPathLength)
  Shared Grep_BaseDirectory$
  
  ; First, check only directories if recursing is on
  ;
  If GrepRecurse
    If ExamineDirectory(DirectoryID, Directory$, "")
      
      While NextDirectoryEntry(DirectoryID) And GrepAbort = 0
        FlushEvents() ; handle window and stop events
        
        If DirectoryEntryType(DirectoryID) = 2 And DirectoryEntryName(DirectoryID) <> ".." And DirectoryEntryName(DirectoryID) <> "."
          Grep(DirectoryID+1, Directory$+DirectoryEntryName(DirectoryID)+#Separator, String$, PatternList$, InitialPathLength)
        EndIf
      Wend
      
      FinishDirectory(DirectoryID)
    EndIf
  EndIf
  
  If GrepAbort
    ProcedureReturn
  EndIf
  
  ; Now check all the Patterns (if any)
  ; We need to keep track of already seen filenames, as one might match multiple patterns!
  ;
  NewList SearchedFiles.s()
  
  If Trim(PatternList$) = ""
    PatternList$ = "*.*"
  EndIf
  
  Index = 1
  Repeat
    Pattern$ = Trim(StringField(PatternList$, Index, ","))
    If Pattern$
      If ExamineDirectory(DirectoryID, Directory$, Pattern$)
        While NextDirectoryEntry(DirectoryID) And GrepAbort = 0
          FlushEvents() ; handle window and stop events
          
          If DirectoryEntryType(DirectoryID) = 1
            Filename$  = DirectoryEntryName(DirectoryID)
            Found = 0
            
            ForEach SearchedFiles()
              Searched$ = SearchedFiles() ; NOTE: @SearchedFiles() no longer returns the string pointer !?
              If IsEqualFile(Searched$, FileName$)
                Found = 1
                Break
              EndIf
            Next SearchedFiles()
            
            If Found = 0
              AddElement(SearchedFiles())
              SearchedFiles() = FileName$
              
              SetGadgetText(#GADGET_GrepOutput_Current, CreateRelativePath(Grep_BaseDirectory$, Directory$+FileName$))
              SearchStringInFile(#FILE_Grep, Directory$+Filename$, String$, InitialPathLength)
            EndIf
          EndIf
        Wend
        
        FinishDirectory(DirectoryID)
      EndIf
    EndIf
    
    Index + 1
  Until GrepAbort Or Pattern$ = "" Or Pattern$ = "*" Or Pattern$ = "*.*" ; we also abort on these patterns, as then all files are scanned
  
  ProcedureReturn GrepAbort
EndProcedure


Procedure OpenGrepOutputWindow()
  
  If IsWindow(#WINDOW_GrepOutput) = 0
    GrepOutputDialog = OpenDialog(?Dialog_GrepOutput, WindowID(#WINDOW_Main), @GrepOutputPosition)
    EnsureWindowOnDesktop(#WINDOW_GrepOutput)
  Else
    SetWindowForeground(#WINDOW_GrepOutput)
  EndIf
  
EndProcedure


Procedure GrepOutputWindowEvents(EventID)
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
    Case #PB_Event_CloseWindow
      Quit = 1
      
    Case #PB_Event_SizeWindow
      GrepOutputDialog\SizeUpdate()
      
    Case #PB_Event_Gadget
      Select GadgetID
          
        Case #GADGET_GrepOutput_List
          If EventType() = #PB_EventType_LeftDoubleClick
            Line$ = GetGadgetItemText(#GADGET_GrepOutput_List, GetGadgetState(#GADGET_GrepOutput_List), 0)
            
            Filename$  = StringField(Line$, 1, ":")
            If Len(Filename$) = 1 ; Probably only a letter of drive like 'C:'
              Filename$  = Filename$+":"+StringField(Line$, 2, ":")
            EndIf
            
            If Filename$ And Asc(Filename$) <> ';'  ; Not '; Search starting' or finished stuff
              
              If LoadSourceFile(FileName$)
                
                LineNumber = Val(StringField(Right(Line$, Len(Line$)-Len(Filename$)-2), 1, " "))
                ChangeActiveLine(LineNumber, -5)
              EndIf
            EndIf
            
          EndIf
          
        Case #GADGET_GrepOutput_Clear
          ClearGadgetItems(#GADGET_GrepOutput_List)
          
        Case #GADGET_GrepOutput_Close
          Quit = 1
          
      EndSelect
      
  EndSelect
  
  If Quit
    ; abort any ongoing search
    GrepAbort = 1
    
    If MemorizeWindow
      GrepOutputDialog\Close(@GrepOutputPosition)
    Else
      GrepOutputDialog\Close()
    EndIf
    
    GrepOutputDialog = 0
  EndIf
  
EndProcedure

Procedure OpenGrepWindow()
  
  If IsWindow(#WINDOW_Grep) = 0
    
    GrepWindowDialog = OpenDialog(?Dialog_Grep, WindowID(#WINDOW_Main), @GrepWindowPosition)
    If GrepWindowDialog
      EnsureWindowOnDesktop(#WINDOW_Grep)
      
      AddKeyboardShortcut(#WINDOW_Grep, #PB_Shortcut_Return, #GADGET_Grep_Find)
      AddKeyboardShortcut(#WINDOW_Grep, #PB_Shortcut_Escape, #GADGET_Grep_Cancel)
      
      EnableGadgetDrop(#GADGET_Grep_Directory, #PB_Drop_Files, #PB_Drag_Copy)
      
      For i = 1 To FindHistorySize
        If GrepFindHistory(i) <> ""
          AddGadgetItem(#GADGET_Grep_FindWord, -1, GrepFindHistory(i))
        EndIf
        
        If GrepDirectoryHistory(i) <> ""
          AddGadgetItem(#GADGET_Grep_Directory, -1, GrepDirectoryHistory(i))
        EndIf
        
        If GrepExtensionHistory(i) <> ""
          AddGadgetItem(#GADGET_Grep_Pattern, -1, GrepExtensionHistory(i))
        EndIf
      Next i
      
      If CountGadgetItems(#GADGET_Grep_Pattern) = 0
        AddGadgetItem(#GADGET_Grep_Pattern, -1, "*" + #SourceFileExtension)  ; Default to *.pb files, else it will find nothing
      EndIf
      SetGadgetState(#GADGET_Grep_Pattern, 0)
      SetGadgetState(#GADGET_Grep_Directory, 0)
      
      SetGadgetState(#GADGET_Grep_MatchCase,  GrepCaseSensitive)
      SetGadgetState(#GADGET_Grep_WholeWord,  GrepWholeWord)
      SetGadgetState(#GADGET_Grep_Recurse,    GrepRecurse)
      SetGadgetState(#GADGET_Grep_NoComments, GrepNoComments)
      SetGadgetState(#GADGET_Grep_NoStrings,  GrepNoStrings)
      
      SetGadgetState(#GADGET_Grep_FindWord, 0)
      GetSelection(@LineStart, @RowStart, @LineEnd, @RowEnd)
      
      If LineStart = LineEnd And RowStart <> RowEnd
        ; display the default selection in the box
        Line$ = Mid(GetLine(LineStart-1), RowStart, RowEnd-RowStart)
        SetGadgetText(#GADGET_Grep_FindWord, Line$)
      EndIf
      
      DisableGrepWindow(0)
      HideWindow(#WINDOW_Grep, 0)
    EndIf
    
  Else
    SetWindowForeground(#WINDOW_Grep)
  EndIf
  
  SelectComboBoxText(#GADGET_Grep_FindWord)
  SetActiveGadget(#GADGET_Grep_FindWord)
  
EndProcedure


Procedure UpdateGrepWindow()
  
  GrepWindowDialog\LanguageUpdate()
  
  While FindHistorySize < CountGadgetItems(#GADGET_Grep_FindWord)
    RemoveGadgetItem(#GADGET_Grep_FindWord, CountGadgetItems(#GADGET_Grep_FindWord)-1)
  Wend
  
  While FindHistorySize < CountGadgetItems(#GADGET_Grep_Directory)
    RemoveGadgetItem(#GADGET_Grep_Directory, CountGadgetItems(#GADGET_Grep_Directory)-1)
  Wend
  
  While FindHistorySize < CountGadgetItems(#GADGET_Grep_Pattern)
    RemoveGadgetItem(#GADGET_Grep_Pattern, CountGadgetItems(#GADGET_Grep_Pattern)-1)
  Wend
  
  GrepWindowDialog\GuiUpdate()
  
EndProcedure


Procedure GrepWindowEvents(EventID)
  Shared Grep_BaseDirectory$
  
  If EventID = #PB_Event_Menu     ; Little wrapper to map the shortcut events (identified as menu)
    EventID  = #PB_Event_Gadget   ; to normal gadget events...
    GadgetID = EventMenu()
  Else
    GadgetID = EventGadget()
  EndIf
  
  Select EventID
    Case #PB_Event_CloseWindow
      Quit = 1
      
    Case #PB_Event_GadgetDrop
      If GadgetID = #GADGET_Grep_Directory
        Path$ = StringField(EventDropFiles(), 1, Chr(10))
        If FileSize(Path$) <> -2 ; probably a file then
          Path$ = GetPathPart(Path$)
        EndIf
        SetGadgetText(#GADGET_Grep_Directory, Path$)
      EndIf
      
    Case #PB_Event_Gadget
      Select GadgetID
          
        Case #GADGET_Grep_SelectDirectory
          Directory$ = PathRequester("", GetGadgetText(#GADGET_Grep_Directory))
          If Directory$
            SetGadgetText(#GADGET_Grep_Directory, Directory$)
          EndIf
          
        Case #GADGET_Grep_UseCurrentDirectory
          If *ActiveSource = *ProjectInfo
            Directory$ = GetPathPart(ProjectFile$)
          ElseIf *ActiveSource And *ActiveSource\FileName$ <> ""
            Directory$ = GetPathPart(*ActiveSource\FileName$)
          Else
            Directory$ = GetCurrentDirectory()
          EndIf
          SetGadgetText(#GADGET_Grep_Directory, Directory$)
          
        Case #GADGET_Grep_Find
          Directory$ = GetGadgetText(#GADGET_Grep_Directory)
          If Directory$
            
            If Right(Directory$, 1) <> #Separator
              Directory$ + #Separator
            EndIf
            
            String$ = GetGadgetText(#GADGET_Grep_FindWord)
            If String$
              DisableGrepWindow(#True)
              OpenGrepOutputWindow()
              
              NbGrepFiles = 0
              
              ; get checkbox choices
              GrepCaseSensitive = GetGadgetState(#GADGET_Grep_MatchCase)
              GrepWholeWord     = GetGadgetState(#GADGET_Grep_WholeWord)
              GrepNoComments    = GetGadgetState(#GADGET_Grep_NoComments)
              GrepNoStrings     = GetGadgetState(#GADGET_Grep_NoStrings)
              GrepRecurse       = GetGadgetState(#GADGET_Grep_Recurse)
              
              AddGadgetItem(#GADGET_GrepOutput_List, -1, "; "+Language("Find","Started")+". '"+String$+"'...")
              Grep_BaseDirectory$ = Directory$
              
              GrepAbort = 0
              
              UpdateFindComboBox(#Gadget_Grep_FindWord)
              UpdateFindComboBox(#Gadget_Grep_Directory)
              UpdateFindComboBox(#Gadget_Grep_Pattern)
              
              If Grep(0, Directory$, String$, GetGadgetText(#GADGET_Grep_Pattern)+",", Len(Directory$))
                If IsWindow(#WINDOW_GrepOutput) ; the window could have been closed!
                  AddGadgetItem(#GADGET_GrepOutput_List, -1, "; "+Language("Find","Aborted")+". "+Str(NbGrepFiles)+" "+Language("Find","LinesFound")+".")
                EndIf
              Else
                AddGadgetItem(#GADGET_GrepOutput_List, -1, "; "+Language("Find","Finished")+". "+Str(NbGrepFiles)+" "+Language("Find","LinesFound")+".")
              EndIf
              
              If IsGadget(#GADGET_GrepOutput_Current) ; the window could have been closed!
                SetGadgetText(#GADGET_GrepOutput_Current, "")
              EndIf
              
              DisableGrepWindow(#False)
              
            Else
              MessageRequester(Language("Find","Info"), Language("Find","NeedString")+".", #FLAG_WARNING)
              SetActiveGadget(#GADGET_Grep_FindWord)
            EndIf
          Else
            MessageRequester(Language("Find","Info"), Language("Find","NeedPath")+".", #FLAG_WARNING)
            SetActiveGadget(#GADGET_Grep_Directory)
          EndIf
          
          
        Case #GADGET_Grep_Cancel
          Quit = 1
          
          ; the stop event now ends up here too, as the events are dispatched from the Grep function.
        Case #GADGET_Grep_Stop
          GrepAbort = 1
          
      EndSelect
      
  EndSelect
  
  If Quit
    ; abort any ongoing search
    GrepAbort = 1
    
    ; get checkbox choices
    GrepCaseSensitive = GetGadgetState(#GADGET_Grep_MatchCase)
    GrepWholeWord     = GetGadgetState(#GADGET_Grep_WholeWord)
    GrepNoComments    = GetGadgetState(#GADGET_Grep_NoComments)
    GrepNoStrings     = GetGadgetState(#GADGET_Grep_NoStrings)
    GrepRecurse       = GetGadgetState(#GADGET_Grep_Recurse)
    
    ; save patterns
    For i = 1 To FindHistorySize
      If CountGadgetItems(#GADGET_Grep_FindWord) >= i
        GrepFindHistory(i) = GetGadgetItemText(#GADGET_Grep_FindWord, i-1, 0)
      Else
        GrepFindHistory(i) = ""
      EndIf
      
      If CountGadgetItems(#GADGET_Grep_Directory) >= i
        GrepDirectoryHistory(i) = GetGadgetItemText(#GADGET_Grep_Directory, i-1, 0)
      Else
        GrepDirectoryHistory(i) = ""
      EndIf
      
      If CountGadgetItems(#GADGET_Grep_Pattern) >= i
        GrepExtensionHistory(i) = GetGadgetItemText(#GADGET_Grep_Pattern, i-1, 0)
      Else
        GrepExtensionHistory(i) = ""
      EndIf
    Next i
    
    If MemorizeWindow
      GrepWindowDialog\Close(@GrepWindowPosition)
    Else
      GrepWindowDialog\Close()
    EndIf
  EndIf
  
EndProcedure