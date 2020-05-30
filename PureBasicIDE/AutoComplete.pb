;--------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
;--------------------------------------------------------------------------------------------

; NOTE: The AutoComplete seemed very slow on some systems, probably because the
;       much access to the Gadget content to add an item sorted takes simply too long.
;
; So we now use a LinkedList to build the whole list without sorting, then
; we sort it all at once before filling the gadget. This should give a speed increase.
;
;
Global NewList AutoCompleteModules.s()
Global NewList AutoCompleteList.s()
Global NewList AutoCompleteStack.s() ; sub-structures in structure mode
Global NewList DummyList.s()         ; for use in FindStructure() when content is not needed
Global AutoComplete_Start, AutoComplete_End ; range of displayed items in the gadget
Global AutoComplete_CurrentMaxWidth, AutoComplete_CurrentMaxHeight
Global AutoComplete_IsStructure
Global AutoComplete_StructureStart
Global AutoComplete_IsModule
Global AutoComplete_ModuleStart

; cache recent AutoComplete selections for structure and module autocomplete (to use in case no word is entered yet)
; the cache is on a per-module or per-structure basis
Global AutoComplete_CurrentStructure$ ; may include module prefix
Global AutoComplete_CurrentModule$
Global NewMap AutoComplete_LastStructureItem.s()  ; key and value is lowercase
Global NewMap AutoComplete_LastModuleItem.s()

Macro AutoComplete_Redraw()
  CompilerIf #CompileLinux
    FlushEvents()
  CompilerEndIf
EndMacro

Procedure CreateAutoCompleteWindow()
  ;
  ; Create the autocomplete window (hidden), so it is later only hidden/shown
  ;
  
  ; Note: I tried to remove the taskbar icon for linux, but the GTK_WINDOW_POPUP hack
  ;       (which does that well) has other trouble. (for example the window focus is not
  ;       properly managed) So we do not use this.
  
  If OpenWindow(#WINDOW_AutoComplete, 0, 0, 0, 0, "", #PB_Window_Invisible | #PB_Window_BorderLess, WindowID(#WINDOW_Main))
    ListViewGadget(#GADGET_AutoComplete_List, 0, 0, 0, 0)
    
    CompilerIf #CompileLinuxGtk2
      ; remove window taskbar icon
      ; Note: this marks the window as a "menu", so the WM does not add the taskbar icon,
      ;       but for normal windows this should probably not be used, as i don't know what
      ;       it does to window borders etc of a normal toplevel window
      ;
      ; NOTE: Marking the Window as MENU creates a lot of Gtk errors and a hell of a slowdown
      ;       when using compiz/XGL. Somehow it treats such windows very different, so do not use it!
      ;
      ; *Widget.GtkWidget = WindowID(#WINDOW_AutoComplete)
      ; gdk_window_set_type_hint_(*Widget\window, #GDK_WINDOW_TYPE_HINT_MENU)
      
      ; The "documented" way to remove the taskbar icon. Dunno why i did not find this before
      ; This is just a "hint", but most Linux window managers should support it.
      ; There are only problems on Gtk-Windows as far as i can find.
      ;
      *Widget.GtkWidget = WindowID(#WINDOW_AutoComplete)
      gtk_window_set_skip_taskbar_hint_(*Widget, #True)
      gtk_window_set_skip_pager_hint_(*Widget, #True)
      
      ; disable the automatic search feature of the TreeView
      gtk_tree_view_set_enable_search_(GadgetID(#GADGET_AutoComplete_List), #False)
      
    CompilerEndIf
    
    CompilerIf #CompileMac
      ; key handling for OSX
      AutoComplete_SetupRawKeyHandler()
    CompilerEndIf
    
    ; These shortcuts are now in the Preferences shortcut list, so they get added automatically below.
    ;     AddKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_Escape, #MENU_AutoComplete_Abort)
    ;     AddKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_Return, #MENU_AutoComplete_Ok)
    ;     AddKeyboardShortcut(#WINDOW_AutoComplete, #PB_Shortcut_Tab, #MENU_AutoComplete_Ok)
    
    ; put all main window shortcuts here too.
    CreateKeyboardShortcuts(#WINDOW_AutoComplete)
    
    AutoComplete_SetFocusCallback()
    AutoCompleteWindowReady = 1
  EndIf
  
EndProcedure


Procedure AutoComplete_AddItem(*Item.SourceItem)
  AddElement(AutoCompleteList())
  AutoCompleteList() = *Item\Name$
  
  If AutoCompleteAddBrackets
    Select *Item\Type
      Case #ITEM_Procedure, #ITEM_Declare
        If RemoveString(RemoveString(*Item\Prototype$, " "), Chr(9)) = "()"
          AutoCompleteList() + "()"
        Else
          AutoCompleteList() + "("
        EndIf
        
      Case #ITEM_Macro
        If RemoveString(RemoveString(*Item\Prototype$, " "), Chr(9)) = "()"
          AutoCompleteList() + "()"
        ElseIf FindString(*Item\Prototype$, "(", 1) <> 0 ; do not add brackets for none function macros
          AutoCompleteList() + "("
        EndIf
        
      Case #ITEM_Import
        If RemoveString(RemoveString(StringField(*Item\Type$, 2, Chr(9)), " "), Chr(9)) = "()"
          AutoCompleteList() + "()"
        Else
          AutoCompleteList() + "("
        EndIf
        
      Case #ITEM_Array, #ITEM_Map, #ITEM_UnknownBraced
        AutoCompleteList() + "("
        
      Case #ITEM_LinkedList
        AutoCompleteList() + "()"
        
      Case #ITEM_DeclareModule
        AutoCompleteList() + "::"
        
    EndSelect
  EndIf
EndProcedure

; Constants are separate as they are clearly marked by the first # char
; This way we only have to lookup one kind of item for this
;
Procedure AutoComplete_AddConstantsFromSorted(*Parser.ParserData, Bucket, *Ignore.SourceItem)
  
  If *Parser\SortedValid
    If Bucket < 0
      ; display full list, so we have to add from all buckets
      ;
      ForEach AutoCompleteModules()
        For Bucket = 0 To #PARSER_VTSize-1
          *Item.SourceItem = *Parser\Modules(UCase(AutoCompleteModules()))\Sorted\Constants[Bucket]
          While *Item
            If *Item <> *Ignore
              AddElement(AutoCompleteList())
              AutoCompleteList() = *Item\Name$
            EndIf
            *Item = *Item\NextSorted
          Wend
        Next Bucket
      Next AutoCompleteModules()
      
    Else
      ; We now add all items that match the first char, even when
      ; the exact match option is on, so we just have to lookup the one bucket
      ; and add all
      ;
      ForEach AutoCompleteModules()
        *Item.SourceItem = *Parser\Modules(UCase(AutoCompleteModules()))\Sorted\Constants[Bucket]
        While *Item
          If *Item <> *Ignore
            AddElement(AutoCompleteList())
            AutoCompleteList() = *Item\Name$
          EndIf
          *Item = *Item\NextSorted
        Wend
      Next AutoCompleteModules()
      
    EndIf
  EndIf
  
EndProcedure

Procedure AutoComplete_AddFromSorted(*Parser.ParserData, Bucket, *Ignore.SourceItem, SingleModuleOnly)
  
  If *Parser\SortedValid
    If Bucket < 0
      ; display full list, so we have to add from all buckets
      ;
      For Type = 0 To #ITEM_LastSorted
        If AutocompleteOptions(Type) And Type <> #ITEM_Constant  ; constants are separate
          
          If Type = #ITEM_DeclareModule
            ; module names are indexed in the main module
            ; do not show modules if a prefix:: is provided before the word
            If SingleModuleOnly = 0
              For Bucket = 0 To #PARSER_VTSize-1
                *Item.SourceItem = *Parser\MainModule\Indexed[Type]\Bucket[Bucket]
                While *Item
                  If *Item <> *Ignore
                    AutoComplete_AddItem(*Item)
                  EndIf
                  *Item = *Item\NextSorted
                Wend
              Next Bucket
            EndIf
            
          Else
            ; other stuff
            ForEach AutoCompleteModules()
              For Bucket = 0 To #PARSER_VTSize-1
                *Item.SourceItem = *Parser\Modules(UCase(AutoCompleteModules()))\Indexed[Type]\Bucket[Bucket]
                While *Item
                  If *Item <> *Ignore
                    AutoComplete_AddItem(*Item)
                  EndIf
                  *Item = *Item\NextSorted
                Wend
              Next Bucket
            Next AutoCompleteModules()
            
          EndIf
        EndIf
      Next Type
      
    Else
      ; We now add all items that match the first char, even when
      ; the exact match option is on, so we just have to lookup the one bucket
      ; and add all
      ;
      For Type = 0 To #ITEM_LastSorted
        If AutocompleteOptions(Type) And Type <> #ITEM_Constant ; constants are separate
          
          If Type = #ITEM_DeclareModule
            ; module names are indexed in the main module
            ; do not show modules if a prefix:: is provided before the word
            If SingleModuleOnly = 0
              *Item.SourceItem = *Parser\MainModule\Indexed[Type]\Bucket[Bucket]
              While *Item
                If *Item <> *Ignore
                  AutoComplete_AddItem(*Item)
                EndIf
                *Item = *Item\NextSorted
              Wend
            EndIf
            
          Else
            ; other stuff
            ForEach AutoCompleteModules()
              *Item.SourceItem = *Parser\Modules(UCase(AutoCompleteModules()))\Indexed[Type]\Bucket[Bucket]
              While *Item
                If *Item <> *Ignore
                  AutoComplete_AddItem(*Item)
                EndIf
                *Item = *Item\NextSorted
              Wend
            Next AutoCompleteModules()
            
          EndIf
        EndIf
      Next Type
      
    EndIf
  EndIf
  
EndProcedure

Procedure AutoComplete_FillNormal(WordStart$, ModulePrefix$)
  ; Declares are treated like procedures in AutoComplete and they have no
  ; separate prefs item, so just sync the settings for simplicity
  ;
  AutocompleteOptions(#ITEM_Declare) = AutocompleteOptions(#ITEM_Procedure)
  
  FirstChar$ = Left(WordStart$, 1)
  If AutoCompleteCharMatchOnly = 1 And FirstChar$ <> "#" And FirstChar$ <> "*"
    Length = 1
  Else  ; for constants, compare the second char!
    Length = 2
  EndIf
  
  ; We may not add the SourceItem right under the cursor, so check
  ; if there is one
  ;
  *CurrentItem = LocateSourceItem(@*ActiveSource\Parser, *ActiveSource\CurrentLine-1, *ActiveSource\CurrentColumnBytes-2)
  
  ; Check if we are inside a module here
  ;
  ClearList(AutoCompleteModules())
  If AutoComplete_IsModule
    ; a module prefix is given. so exclusively look at the public part of this module
    SingleModuleOnly = #True
    AddElement(AutoCompleteModules())
    AutoCompleteModules() = ModulePrefix$
  Else
    ; scan for open modules
    SingleModuleOnly = #False
    *ModuleStart.SourceItem = *CurrentItem
    ModuleStartLine = *ActiveSource\CurrentLine - 1
    If *ModuleStart = 0
      *ModuleStart = ClosestSourceItem(@*ActiveSource\Parser, @ModuleStartLine, *ActiveSource\CurrentColumnBytes-2)
    EndIf
    If *ModuleStart And FindModuleStart(@*ActiveSource\Parser, @ModuleStartLine, @*ModuleStart, AutoCompleteModules())
      AddElement(AutoCompleteModules())
      AutoCompleteModules() = *ModuleStart\Name$
      
      If *ModuleStart\Type = #ITEM_Module
        AddElement(AutoCompleteModules())
        AutoCompleteModules() = "IMPL::" + *ModuleStart\Name$
      EndIf
    Else
      AddElement(AutoCompleteModules())
      AutoCompleteModules() = ""
    EndIf
  EndIf
  
  If AutoCompleteCharMatchOnly = 0 Or SingleModuleOnly
    ; add all entries in these cases
    Bucket = -1
  Else
    Bucket = GetBucket(@WordStart$) ; for adding sorted stuff
  EndIf
  
  
  
  ; Note: Our LinkedList now contains all words that start with the wanted character even if
  ;   the AutoCompleteCharMatchOnly=2. We will filter this when displaying in the gadget
  ;   This way the list never needs to be rebuild while the window is open
  ;   (as the window closes when the first char is erased.)
  
  ; fill the list:
  ;
  If FirstChar$ = "#" Or WordStart$ = ""  ; constants
    
    ; add PB constants
    If AutocompletePBOptions(#PBITEM_Constant) And SingleModuleOnly = #False
      For i = 0 To ConstantListSize-1
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @ConstantList(i), #PB_String_NoCase, Length) = #PB_String_Equal
          AddElement(AutoCompleteList())
          AutoCompleteList() = ConstantList(i)
        EndIf
      Next i
    EndIf
    
    If AutoCompleteOptions(#ITEM_Constant)
      
      ; Add the constants from this source
      AutoComplete_AddConstantsFromSorted(@*ActiveSource\Parser, Bucket, *CurrentItem)
      
      ; Add constants from project sources
      If AutoCompleteProject And *ActiveSource\ProjectFile
        ForEach ProjectFiles()
          If ProjectFiles()\Source = 0
            AutoComplete_AddConstantsFromSorted(@ProjectFiles()\Parser, Bucket, *CurrentItem)
          ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *ActiveSource
            AutoComplete_AddConstantsFromSorted(@ProjectFiles()\Source\Parser, Bucket, *CurrentItem)
          EndIf
        Next ProjectFiles()
      EndIf
      
      ; Add constants from open files
      If AutoCompleteAllFiles
        ForEach FileList()
          If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And (AutoCompleteProject = 0 Or FileList()\ProjectFile = 0)
            AutoComplete_AddConstantsFromSorted(@FileList()\Parser, Bucket, *CurrentItem)
          EndIf
        Next FileList()
        ChangeCurrentElement(FileList(), *ActiveSource) ; important!
      EndIf
      
    EndIf
    
  EndIf
  
  If FirstChar$ <> "#"  ; functions or anything else
    
    ; add PB items
    If AutocompletePBOptions(#PBITEM_Keyword) And SingleModuleOnly = #False
      For i = 1 To #NbBasicKeywords
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @BasicKeywordsReal(i), 1, Length) = 0
          AddElement(AutoCompleteList())
          If AutoCompleteAddSpaces
            AutoCompleteList() = BasicKeywordsReal(i) + BasicKeywordsSpaces(i)
          Else
            AutoCompleteList() = BasicKeywordsReal(i)
          EndIf
        EndIf
      Next i
    EndIf
    
    If AutocompletePBOptions(#PBITEM_ASMKeyword) And SingleModuleOnly = #False
      For i = 1 To NbASMKeywords
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @ASMKeywords(i), 1, Length) = 0
          AddElement(AutoCompleteList())
          AutoCompleteList() = ASMKeywords(i)
        EndIf
      Next i
    EndIf
    
    If AutocompletePBOptions(#PBITEM_Function) And SingleModuleOnly = #False
      For i = 0 To NbBasicFunctions-1
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @BasicFunctions(i)\Name$, 1, Length) = 0
          AddElement(AutoCompleteList())
          If AutoCompleteAddBrackets
            If Left(BasicFunctions(i)\Proto$, 2) = "()"
              AutoCompleteList() = BasicFunctions(i)\Name$+"()"
            Else
              AutoCompleteList() = BasicFunctions(i)\Name$+"("
            EndIf
          Else
            AutoCompleteList() = BasicFunctions(i)\Name$
          EndIf
        EndIf
      Next i
    EndIf
    
    If AutocompletePBOptions(#PBITEM_APIFunction) And SingleModuleOnly = #False
      For i = 0 To NbApiFunctions-1
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @APIFunctions(i)\Name$, 1, Length) = 0
          AddElement(AutoCompleteList())
          AutoCompleteList() = APIFunctions(i)\Name$+"_"
          If AutoCompleteAddBrackets
            AutoCompleteList() + "("
          EndIf
        EndIf
      Next i
    EndIf
    
    If AutocompletePBOptions(#PBITEM_Structure) And SingleModuleOnly = #False
      For i = 0 To StructureListSize-1
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @StructureList(i), 1, Length) = 0
          AddElement(AutoCompleteList())
          AutoCompleteList() = StructureList(i)
        EndIf
      Next i
    EndIf
    
    If AutocompletePBOptions(#PBITEM_Interface) And SingleModuleOnly = #False
      For i = 0 To InterfaceListSize-1
        If AutoCompleteCharMatchOnly = 0 Or CompareMemoryString(@WordStart$, @InterfaceList(i), 1, Length) = 0
          AddElement(AutoCompleteList())
          AutoCompleteList() = InterfaceList(i)
        EndIf
      Next i
    EndIf
    
    ; Add items from current source (Global scope)
    ;
    ; Update the current source sorted data and use that
    ; It does nothing if the data is already sorted, and the sorting
    ; does not do much more than we would need to do here anyway (walk all source and check scope)
    ; so this should be fast enough
    ;
    SortParserData(@*ActiveSource\Parser, *ActiveSource)
    AutoComplete_AddFromSorted(@*ActiveSource\Parser, Bucket, *CurrentItem, SingleModuleOnly)
    
    ; Add items from the current source (local scope)
    ; For this, check backwards to see if there is even a procedure
    ; (do this only if needed)
    ;
    If SingleModuleOnly = #False And (AutocompleteOptions(#ITEM_Variable) | AutocompleteOptions(#ITEM_Array) | AutocompleteOptions(#ITEM_LinkedList) | AutocompleteOptions(#ITEM_Map))
      *ProcedureStart = 0
      
      If *CurrentItem
        ; we have a current item
        *Item.SourceItem = *CurrentItem
        Line = *ActiveSource\CurrentLine-1
        Parser_PreviousItem(*ActiveSource\Parser, *Item, Line)
      Else
        ; no current item, find the nearest one to start
        *Item.SourceItem = 0
        Line = *ActiveSource\CurrentLine-1
        While *Item = 0 And Line > 0
          Line - 1
          *Item = *ActiveSource\Parser\SourceItemArray\Line[Line]\Last
        Wend
      EndIf
      
      If FindProcedureStart(@*ActiveSource\Parser, @Line, @*Item)
        ; we are inside a procedure, so add all local stuff
        ; (if it is also global, no problem as it is already in the list then)
        ; No need to re-check anything with always global scope (like import, structure, etc)
        
        While *Item
          Select *Item\Type
              
            Case #ITEM_ProcedureEnd
              Break
              
            Case #ITEM_Macro
              While *Item And *Item\Type <> #ITEM_MacroEnd
                Parser_NextItem(*ActiveSource\Parser, *Item, Line)
              Wend
              
              If *Item = 0 ; Important check, as Parser_NextItem() below does not check this!
                Break
              EndIf
              
            Case #ITEM_Keyword
              SkipTo = 0
              Select *Item\Keyword
                Case #KEYWORD_Structure: SkipTo = #KEYWORD_EndStructure
                Case #KEYWORD_Interface: SkipTo = #KEYWORD_EndInterface
                Case #KEYWORD_Import   : SkipTo = #KEYWORD_EndImport
                Case #KEYWORD_ImportC  : SkipTo = #KEYWORD_EndImport
              EndSelect
              If SkipTo
                While *Item And (*Item\Type <> #ITEM_Keyword Or *Item\Keyword <> SkipTo)
                  Parser_NextItem(*ActiveSource\Parser, *Item, Line)
                Wend
                
                If *Item = 0 ; Important check, as Parser_NextItem() below does not check this!
                  Break
                EndIf
              EndIf
              
            Case #ITEM_Variable
              If *Item <> *CurrentItem And AutocompleteOptions(#ITEM_Variable) And *Item\Scope <> #SCOPE_GLOBAL And *Item\Scope <> #SCOPE_THREADED
                ; add shared too, as it can be an implicit declaration
                AutoComplete_AddItem(*Item)
              EndIf
              
            Case #ITEM_Array, #ITEM_LinkedList, #ITEM_Map
              If *Item <> *CurrentItem And AutocompleteOptions(*Item\Type) And *Item\Scope <> #SCOPE_GLOBAL And *Item\Scope <> #SCOPE_THREADED
                AutoComplete_AddItem(*Item)
              EndIf
              
            Case #ITEM_UnknownBraced
              If *Item <> *CurrentItem And *Item\Scope = #SCOPE_Shared
                ; its a shared array, list or map. need to resolve it to find out which
              EndIf
              
          EndSelect
          
          Parser_NextItem(*ActiveSource\Parser, *Item, Line)
        Wend
      EndIf
    EndIf
    
    ; Add items from project sources
    If AutoCompleteProject And *ActiveSource\ProjectFile
      ForEach ProjectFiles()
        If ProjectFiles()\Source = 0
          AutoComplete_AddFromSorted(@ProjectFiles()\Parser, Bucket, *CurrentItem, SingleModuleOnly)
        ElseIf ProjectFiles()\Source And ProjectFiles()\Source <> *ActiveSource
          AutoComplete_AddFromSorted(@ProjectFiles()\Source\Parser, Bucket, *CurrentItem, SingleModuleOnly)
        EndIf
      Next ProjectFiles()
    EndIf
    
    ; Add items from open files
    If AutoCompleteAllFiles
      ForEach FileList()
        If @FileList() <> *ProjectInfo And @FileList() <> *ActiveSource And (AutoCompleteProject = 0 Or FileList()\ProjectFile = 0)
          AutoComplete_AddFromSorted(@FileList()\Parser, Bucket, *CurrentItem, SingleModuleOnly)
        EndIf
      Next FileList()
      ChangeCurrentElement(FileList(), *ActiveSource) ; important!
    EndIf
    
  EndIf
EndProcedure


; AutoCompleteStack() contains any sub-structures that we are in
;
Procedure AutoComplete_FillStructured(WordStart$, StructName$, *BaseItem.SourceItem, BaseItemLine)
  
  If *BaseItem And StructName$ = ""  ; normal structure mode
                                     ; Only accept BaseItems that can be a structure
                                     ;
    If *BaseItem\Type = #ITEM_Variable Or *BaseItem\Type = #ITEM_Array Or *BaseItem\Type = #ITEM_LinkedList Or *BaseItem\Type = #ITEM_Map Or *BaseItem\Type = #ITEM_UnknownBraced
      
      ; resolve the type to know the structure
      ;
      Type$ = ResolveItemType(*BaseItem, BaseItemLine, @OutType.i)
      If Type$ = "" Or (Not (OutType = #ITEM_Variable Or OutType = #ITEM_Array Or OutType = #ITEM_LinkedList Or OutType = #ITEM_Map))
        ProcedureReturn
      EndIf
      
    Else
      ProcedureReturn
    EndIf
    IsOffsetOf = 0
    
  ElseIf StructName$ <> "" ; OffsetOf mode
    Type$ = StructName$
    IsOffsetOf = 1
    
  Else
    ProcedureReturn
    
  EndIf
  
  ; walk the AutoCompleteStack() to resolve sub-structures
  ; at the same time, add/prepare the structure items for display
  ;
  ResetList(AutoCompleteStack())
  AutoComplete_CurrentStructure$ = Type$
  
  Repeat
    If NextElement(AutoCompleteStack())
      Subitem$ = AutoCompleteStack()
    Else
      Subitem$ = ""
    EndIf
    SubItemFound = 0
    
    ClearList(AutoCompleteList())
    
    If FindStructure(Type$, AutoCompleteList())
      
      ; process the items
      ForEach AutoCompleteList()
        Select StructureFieldKind(AutoCompleteList())
          Case "Array": Bracket$ = "("
          Case "List" : Bracket$ = "()"
          Case "Map"  : Bracket$ = "("
          Default
            If FindString(AutoCompleteList(), "[", 1) ; static array
              Bracket$ = "["
            Else
              Bracket$ = ""
            EndIf
        EndSelect
        
        Entry$     = StructureFieldName(AutoCompleteList()) ; this cuts any "List " prefix
        EntryType$ = StructureFieldType(AutoCompleteList())
        
        Debug "Entry: " + Entry$
        If CompareMemoryString(@Entry$, @"StructureUnion", #PB_String_NoCase) = #PB_String_Equal
          DeleteElement(AutoCompleteList()) ; ignore this
          Continue
        ElseIf CompareMemoryString(@Entry$, @"EndStructureUnion", #PB_String_NoCase) = #PB_String_Equal
          DeleteElement(AutoCompleteList()) ; ignore this
          Continue
        EndIf
        
        If Subitem$ And CompareMemoryString(@Subitem$, @Entry$, #PB_String_NoCase) = #PB_String_Equal
          ; Repeat outer loop with the new sub-type
          Type$ = EntryType$
          AutoComplete_CurrentStructure$ = EntryType$
          SubItemFound = 1
          Break
        Else
          ; store the processed entry
          If AutoCompleteAddBrackets And IsOffsetOf = 0 ; any brackes in OffsetOf are a syntax error (with structures)
            If Bracket$
              AutoCompleteList() = Entry$ + Bracket$
            Else
              *ProtoItem.SourceItem = FindPrototype(EntryType$)
              If *ProtoItem And *ProtoItem\Prototype$
                If RemoveString(RemoveString(*ProtoItem\Prototype$, " "), Chr(9)) = "()"
                  AutoCompleteList() = Entry$ + "()"
                Else
                  AutoCompleteList() = Entry$ + "("
                EndIf
              ElseIf FindStructure(EntryType$, DummyList()) Or FindInterface(EntryType$, DummyList())
                AutoCompleteList() = Entry$ + "\"
              Else
                AutoCompleteList() = Entry$
              EndIf
            EndIf
          Else
            AutoCompleteList() = Entry$
          EndIf
        EndIf
      Next AutoCompleteList()
      
      ; If we get here and SubItem$ is not empty, it means we have a subitem without a match
      ; so do not offer any choices then
      If SubItem$ And SubItemFound = 0
        ClearList(AutoCompleteList())
        ProcedureReturn
      EndIf
      
    ElseIf FindInterface(Type$, AutoCompleteList())
      If Subitem$
        ; Interfaces can have no further nesting
        ClearList(AutoCompleteList())
        ProcedureReturn
      Else
        ; process the items
        ForEach AutoCompleteList()
          Entry$ = InterfaceFieldName(AutoCompleteList())
          
          If AutoCompleteAddBrackets
            ; for OffsetOF, we always need a "()", so add that then
            If IsOffsetOf Or Left(RemoveString(RemoveString(AutoCompleteList(), Chr(9)), " "), 2) = "()"
              AutoCompleteList() = Entry$ + "()"
            Else
              AutoCompleteList() = Entry$ + "("
            EndIf
          Else
            AutoCompleteList() = Entry$
          EndIf
        Next AutoCompleteList()
      EndIf
      
    Else
      ; error, structure type not found
      ProcedureReturn
    EndIf
  Until Subitem$ = ""
  
EndProcedure

; checks for the case of "OffsetOf(StructName\" in AutoComplete.
; TypeOf and SizeOf are treated the same way
; Returns "StructName" if true or empty string otherwise
;
Procedure.s AutoComplete_IsOffsetOf(Line$, Column)
  
  ; search the line backwards
  *Buffer = @Line$
  *Cursor.Character = *Buffer + Column * #CharSize
  
  ; Skip any whitespace
  While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
    *Cursor - #CharSize
  Wend
  
  ; need a '\' now
  If *Cursor >= *Buffer And *Cursor\c = '\'
    *Cursor - #CharSize
    
    ; whitespace
    While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
      *Cursor - #CharSize
    Wend
    
    ; need the struct name now
    *NameEnd = *Cursor
    
    While *Cursor >= *Buffer And ValidCharacters(*Cursor\c)
      *Cursor - #CharSize
    Wend
    
    If *Cursor >= *Buffer And *Cursor <> *NameEnd
      ; No need to be concerned with Line$ = "NAME\" only here, as that would not
      ; be an OffsetOf case anyway.
      Name$ = PeekS(*Cursor + #CharSize, (*NameEnd - *Cursor) / #CharSize)
      
      ; whitespace
      While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
        *Cursor - #CharSize
      Wend
      
      ; possible module operator
      If *Cursor >= *Buffer + 1 And *Cursor\c = ':' And PeekC(*Cursor-#CharSize) = ':'
        *Cursor - 2*#CharSize
        
        ; whitespace
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
          *Cursor - #CharSize
        Wend
        
        ; the prefix
        *NameEnd = *Cursor
        While *Cursor >= *Buffer And ValidCharacters(*Cursor\c)
          *Cursor - #CharSize
        Wend
        Name$ = PeekS(*Cursor + #CharSize, (*NameEnd - *Cursor) / #CharSize) + "::" + Name$
        
        ; whitespace
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
          *Cursor - #CharSize
        Wend
      EndIf
      
      ; need a '(' now
      If *Cursor >= *Buffer And *Cursor\c = '('
        *Cursor - #CharSize
        
        ; whitespace
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
          *Cursor - #CharSize
        Wend
        
        ; need "OffsetOf" now (we must be on the 'F' now then)
        If *Cursor >= *Buffer + 7*#CharSize And CompareMemoryString(*Cursor-7*#CharSize, @"OffsetOf", #PB_String_NoCase, 8) = #PB_String_Equal
          
          ; check what precedes the "OffsetOf"
          If *Cursor = *Buffer + 7*#CharSize Or ValidCharacters(PeekC(*Cursor - 8*#CharSize)) = 0
            ; success
            ProcedureReturn Name$
          EndIf
          
          ; same for TypeOf or SizeOf
        ElseIf *Cursor >= *Buffer + 5*#CharSize And CompareMemoryString(*Cursor-5*#CharSize, @"SizeOf", #PB_String_NoCase, 6) = #PB_String_Equal
          If *Cursor = *Buffer + 5*#CharSize Or ValidCharacters(PeekC(*Cursor - 6*#CharSize)) = 0
            ; success
            ProcedureReturn Name$
          EndIf
          
        ElseIf *Cursor >= *Buffer + 5*#CharSize And CompareMemoryString(*Cursor-5*#CharSize, @"TypeOf", #PB_String_NoCase, 6) = #PB_String_Equal
          If *Cursor = *Buffer + 5*#CharSize Or ValidCharacters(PeekC(*Cursor - 6*#CharSize)) = 0
            ; success
            ProcedureReturn Name$
          EndIf
          
          
        EndIf
      EndIf
    EndIf
  EndIf
  
  ProcedureReturn ""
EndProcedure

Procedure OpenAutoCompleteWindow()
  ;
  ; Note: We have a problem here:
  ;   On linux, OpenWindow() contains a PB_FlushEvents(), which can cause the ScintillaCallback
  ;   to receive event. Now if the user has autopopup on, and  types fast, it could trigger
  ;   multiple instances of this procedure to be running. (the next one is triggered while the first calls OpenWindow etc)
  ;
  ;   To solve it, we change the autocomplete handling to open the window only once (see CreateAutoCompleteWindow()),
  ;   and then only show/hide it, which will involve no FlushEvents() and thus should work safely
  ;
  If AutoCompleteWindowReady And *ActiveSource And *ActiveSource\IsCode
    
    ; First get the current word or check for Structured Autocomplete
    ;
    AutoComplete_IsStructure = #False
    AutoComplete_IsModule = #False
    AutoComplete_StructureStart = 0
    AutoComplete_ModuleStart = 0
    *BaseItem.SourceItem = 0
    WordStart$ = ""
    
    GetCursorPosition() ; Ensures than the fields are updated
    Line$ = GetCurrentLine()
    If ScanLine(*ActiveSource, *ActiveSource\CurrentLine-1) ; make sure the current line is up to date!
      UpdateFolding(*ActiveSource, *ActiveSource\CurrentLine-1, *ActiveSource\CurrentLine+2)
      
      ; Note: A full update of procedure browser etc at this point would be too costly,
      ;   as it would mean a re-update with every typed char if autocomplete is set to auto popup.
      ;   So we set a flag and defere the update until the active line is changed
      ;
      *ActiveSource\ParserDataChanged = #True
    EndIf
    
    If Line$
      SortParserData(@*ActiveSource\Parser, *ActiveSource)
      
      Column = *ActiveSource\CurrentColumnChars-1
      found = GetWordBoundary(@Line$, Len(Line$), Column, @StartIndex, @EndIndex, 1)
      
      ; This is for normal and structure mode
      If found
        WordStart$ = Mid(Line$, StartIndex+1, Column-StartIndex)
        ModulePrefix$ = GetModulePrefix(@Line$, Len(Line$), StartIndex)
      Else
        ModulePrefix$ = GetModulePrefix(@Line$, Len(Line$), Column)
      EndIf
      
      ; This is the structure mode check
      If found
        Column = StartIndex-1
      Else
        Column - 1 ; Column is the char after the cursor, but we want the one before it
      EndIf
      
      ; check the special OffsetOf case
      StructName$ = AutoComplete_IsOffsetOf(Line$, Column)
      If StructName$
        ; resolve any module stuff
        BaseItemLine = *ActiveSource\CurrentLine-1
        *BaseItem.SourceItem = ClosestSourceItem(@*ActiveSource\Parser, @BaseItemLine, CharsToBytes(Line$, 0, *ActiveSource\Parser\Encoding, Column))
        If *BaseItem
          StructName$ = ResolveStructureType(@*ActiveSource\Parser, *BaseItem, BaseItemLine, StructName$)
        EndIf
        
        If StructName$
          *BaseItem = 0
          AutoComplete_IsStructure = 1
          ClearList(AutoCompleteStack()) ; only OffsetOf(Struct\Field) is allowed
        EndIf
      EndIf
      
      
      If AutoComplete_IsStructure = 0
        ; Shared function to detect if this is a structure and get its base item
        StructName$ = ""
        BaseItemLine = *ActiveSource\CurrentLine-1
        AutoComplete_IsStructure = LocateStructureBaseItem(Line$, Column, @*BaseItem.SourceItem, @BaseItemLine, AutoCompleteStack())
      EndIf
      
      
      If AutoComplete_IsStructure
        ; need to find the location of the '\' to know when to close the window on backspaces
        *Buffer = @Line$
        *Cursor.Character = *Buffer + Column * #CharSize
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
          *Cursor - #CharSize
        Wend
        
        If *Cursor >= *Buffer And *Cursor\c = '\'
          AutoComplete_StructureStart = (*Cursor - *Buffer) / #CharSize
        EndIf
        
      ElseIf ModulePrefix$ <> ""
        
        ; need to find the location of the :: to know when the window should be closed (like with structures)
        AutoComplete_IsModule = #True
        AutoComplete_CurrentModule$ = ModulePrefix$
        
        *Buffer = @Line$
        *Cursor.Character = *Buffer + Column * #CharSize
        While *Cursor >= *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
          *Cursor - #CharSize
        Wend
        
        If *Cursor >= *Buffer And *Cursor\c = ':'
          AutoComplete_ModuleStart = (*Cursor - *Buffer) / #CharSize
        EndIf
        
      EndIf
      
    EndIf
    
    CompilerIf #PB_Compiler_Debugger
      Debug "--------- Autocomplete ---------------"
      Debug "Current line: " + Line$
      Debug "Current word: " + WordStart$
      Debug "Module prefix: " + ModulePrefix$
      Debug "Structure item: " + Str(*BaseItem)
      Debug "Structure name: " + StructName$ + " (for OffsetOf only)"
      If *BaseItem
        Debug "Structure item name: " + *BaseItem\Name$
        Debug "Strurture item input token: " + Str(*BaseItem\Type)
        Debug "Structure item resolved type: " + ResolveItemType(*BaseItem, BaseItemLine, @OutType)
        Debug "Structure item output token: " + Str(OutType)
      EndIf
      Debug "Structure Stack"
      ForEach AutocompleteStack()
        Debug "  " + AutoCompleteStack()
      Next
      Debug "------------Structure query-----------"
      Protected NewList _test.s()
      Debug "Result = " + Str(FindStructure(WordStart$, _test()))
      ForEach _test()
        Debug "  " + _test()
      Next
      Debug "------------Interface query-----------"
      ClearList(_test.s())
      Debug "Result = " + Str(FindInterface(WordStart$, _test()))
      ForEach _test()
        Debug "  " + _test()
      Next
      Debug "--------------------------------------"
    CompilerEndIf
    
    ClearList(AutoCompleteList())
    AutoComplete_Start = 0
    AutoComplete_End = -1
    
    If AutoComplete_IsStructure
      AutoComplete_FillStructured(WordStart$, StructName$, *BaseItem, BaseItemLine)
    ElseIf WordStart$ <> "" Or AutoComplete_IsModule
      AutoComplete_FillNormal(WordStart$, ModulePrefix$)
      ;      AutomationEvent_AutoComplete(AutoCompleteList()) ; send the event only for normal autocomplete, not for structured (as there modification makes no sense anyway)
    EndIf
    
    If AutoComplete_IsStructure Or AutoComplete_IsModule Or WordStart$ <> ""
      
      If ListSize(AutoCompleteList()) > 0
        
        ; NOW we do the sorting ...
        SortList(AutoCompleteList(), 2)
        
        ; cut double values
        Last$ = ""
        ForEach AutoCompleteList()
          ; Note: @List() returns the list element, not string pointer, therefore the PeekI()
          If CompareMemoryString(@Last$, PeekI(@AutoCompleteList()), 1) = 0
            DeleteElement(AutoCompleteList())
          Else
            Last$ = AutoCompleteList()
          EndIf
        Next AutoCompleteList()
        
        ; Now we check the charmatch options
        ; For Options 0 and 1, the list is exactly what must be displayed now,
        ; for the 2 option we need to filter
        ;
        If (AutoComplete_IsStructure Or AutoComplete_IsModule) And AutoCompleteCharMatchOnly = 1 And WordStart$ <> ""
          ; AutoComplete_FillStructured() and salso the module mode always adds the whole structure, so we must cut some stuff here
          
          AutoComplete_Start = -1
          ResetList(AutoCompleteList())
          While NextElement(AutoCompleteList())
            If CompareMemoryString(PeekI(@AutoCompleteList()), @WordStart$, 1, 1) >= 0
              AutoComplete_Start = ListIndex(AutoCompleteList())
              Break
            EndIf
          Wend
          
          AutoComplete_End = -1
          If AutoComplete_Start <> -1 And LastElement(AutoCompleteList())
            Repeat
              If CompareMemoryString(PeekI(@AutoCompleteList()), @WordStart$, 1, 1) <= 0
                AutoComplete_End = ListIndex(AutoCompleteList())
                Break
              EndIf
            Until Not PreviousElement(AutoCompleteList())
          EndIf
          
        ElseIf AutoCompleteCharMatchOnly <> 2
          AutoComplete_Start = 0
          AutoComplete_End = ListSize(AutoCompleteList())-1
          
        ElseIf ListSize(AutoCompleteList()) > 0
          
          ; find new start and end
          length = Len(WordStart$)
          
          AutoComplete_Start = -1
          ResetList(AutoCompleteList())
          While NextElement(AutoCompleteList())
            If CompareMemoryString(PeekI(@AutoCompleteList()), @WordStart$, 1, length) >= 0
              AutoComplete_Start = ListIndex(AutoCompleteList())
              Break
            EndIf
          Wend
          
          AutoComplete_End = -1
          If AutoComplete_Start <> -1 And LastElement(AutoCompleteList())
            Repeat
              If CompareMemoryString(PeekI(@AutoCompleteList()), @WordStart$, 1, length) <= 0
                AutoComplete_End = ListIndex(AutoCompleteList())
                Break
              EndIf
            Until Not PreviousElement(AutoCompleteList())
          EndIf
          
        EndIf
        
        ; If there is only one single possible match, and this matches exactly,
        ; then do not open the window
        ;
        If AutoComplete_Start >= 0 And AutoComplete_Start = AutoComplete_End And WordStart$
          SelectElement(AutoCompleteList(), AutoComplete_Start)
          If CompareMemoryString(PeekI(@AutoCompleteList()), @WordStart$, 1) = 0
            AutoComplete_Start = -1
          EndIf
        EndIf
        
        If AutoComplete_Start > AutoComplete_End Or AutoComplete_Start < 0  ; if the options are set that nothing was added, do not open the window
          AutoCompleteWindowOpen = 0
          
        Else
          
          CompilerIf #CompileMac
            ; Note: On OSX we have to re-create the Window every time, as otherwise the key forwarding to the Scintilla stops working.
            ;   To be further investigated if this causes any further trouble
            ;
            CreateAutoCompleteWindow()
          CompilerEndIf
          
          ; add items and find the closest item to select
          ClearGadgetItems(#GADGET_AutoComplete_List)
          SelectElement(AutoCompleteList(), AutoComplete_Start)
          
          Repeat
            AddGadgetItem(#GADGET_AutoComplete_List, -1, AutoCompleteList())
          Until ListIndex(AutoCompleteList()) = AutoComplete_End Or NextElement(AutoCompleteList()) = 0
          
          CompilerIf #CompileLinuxGtk2
            ; reset scrolling position on linux for a better look
            ; (as we never close the window, a horizontal scroll could remain from the last autocomplete)
            gtk_tree_view_scroll_to_point_(GadgetID(#GADGET_AutoComplete_List), 0, -1) ; scroll x=0 and ignore y
          CompilerEndIf
          
          Width = AutoCompleteWindowWidth
          Height = AutoCompleteWindowHeight
          AutoComplete_GetWordPosition(@X, @Y, @Width, @Height)
          
          AutoComplete_CurrentMaxWidth  = Width
          AutoComplete_CurrentMaxHeight = Height
          
          ResizeWindow(#WINDOW_AutoComplete, X, Y, Width, Height)
          ResizeGadget(#GADGET_AutoComplete_List, 0, 0, Width, Height)
          
          AutoComplete_AdjustWindowSize(Width, Height)
          
          CompilerIf #CompileMacCocoa
            HideWindow(#WINDOW_AutoComplete, 0, #PB_Window_NoActivate)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Up,     #MENU_AutocompleteUp)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Down,   #MENU_AutocompleteDown)
            AddKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Escape, #MENU_AutocompleteEscape)
          CompilerElse
            HideWindow(#WINDOW_AutoComplete, 0)
            SetActiveWindow(#WINDOW_AutoComplete)
            SetActiveGadget(#GADGET_AutoComplete_List)
          CompilerEndIf
          
          ; set the logical focus to the scintilla (not real focus),
          ; so the blinking cursor remains visible
          SendEditorMessage(#SCI_SETFOCUS, 1, 0)
          
          ; Update the selected item
          ; signal that this is the initial open, so we can select the last inserted item in structure or module mode
          AutoComplete_WordUpdate(#True)
          AutoCompleteWindowOpen = 1
          
        EndIf
        
      EndIf
    EndIf
  EndIf
  
EndProcedure


Procedure AutoComplete_Close()
  If AutoCompleteWindowOpen
    
    CompilerIf #CompileMacCocoa
      RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Up)
      RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Down)
      RemoveKeyboardShortcut(#WINDOW_Main, #PB_Shortcut_Escape)
    CompilerEndIf
    
    HideWindow(#WINDOW_AutoComplete, 1)
    ActivateMainWindow()
    AutoCompleteWindowOpen = 0
  EndIf
EndProcedure


Procedure AutoComplete_ChangeSelectedItem(Direction)
  If AutoCompleteWindowOpen
    Index = GetGadgetState(#GADGET_AutoComplete_List)
    
    If Direction = 0 ; Up
      SetGadgetState(#GADGET_AutoComplete_List, Index-1)
    Else ; Down
      SetGadgetState(#GADGET_AutoComplete_List, Index+1)
    EndIf
    
  EndIf
EndProcedure


Procedure AutoComplete_Insert()
  If AutoCompleteWindowOpen
    index = GetGadgetState(#GADGET_AutoComplete_List)
    If index <> -1
      
      AutoComplete_SelectWord()
      String$ = GetGadgetItemText(#GADGET_AutoComplete_List, index, 0)
      InsertCodeString(String$)
      
      ; cache this selection for a next popup
      If AutoComplete_IsStructure
        AutoComplete_LastStructureItem(LCase(AutoComplete_CurrentStructure$)) = LCase(String$)
      ElseIf AutoComplete_IsModule
        AutoComplete_LastModuleItem(LCase(AutoComplete_CurrentModule$)) = LCase(String$)
      EndIf
      
      AutoComplete_Close()
      
      ; tell the editor keyhandler that a (and which) Basic Keyword was inserted,
      ; to check for the second Tab/Enter key (for the End tag)
      ;
      If AutoCompleteAddEndKeywords And AutoComplete_IsStructure = 0 ; not inside structures!
        AutoCompleteKeywordInserted = IsBasicKeyword(RTrim(String$)) ; remember.. it might have a space at the end
        
        If BasicKeywordsEndKeywords(AutoCompleteKeywordInserted) = "" ; only if there is an end keyword!
          AutoCompleteKeywordInserted = 0
        EndIf
      EndIf
      
      
      If AutoComplete_IsStructure And Right(String$, 1) = "\" And AutoComplete_CheckAutoPopup()
        ; In structure mode, when inserting "substruct\", we should trigger a new autocomplete (when autopopup is on)
        OpenAutoCompleteWindow()
        
      ElseIf Right(String$, 2) = "::" And AutoComplete_CheckAutoPopup()
        ; same thing for module prefixes
        OpenAutoCompleteWindow()
        
      EndIf
      
    EndIf
  EndIf
EndProcedure

Procedure AutoComplete_InsertEndKeyword()
  If AutoCompleteKeywordInserted
    position = SendEditorMessage(#SCI_GETCURRENTPOS, 0, 0)
    SendEditorMessage(#SCI_REPLACESEL, 0, ToAscii(BasicKeywordsEndKeywords(AutoCompleteKeywordInserted)))  ; add the end word
    SendEditorMessage(#SCI_GOTOPOS, position, 0)
    AutoCompleteKeywordInserted = 0
  EndIf
EndProcedure

Procedure AutoCompleteWindowEvents(EventID)
  
  If AutoCompleteWindowOpen
      
    If EventID = #PB_Event_Menu
      MenuID = EventMenu()
      
      If MenuID = #MENU_AutoComplete_OK
        EventID = #PB_Event_Gadget
        EventGadgetID = #GADGET_AutoComplete_Ok
        
      ElseIf MenuID = #MENU_AutoComplete_Abort
        EventID = #PB_Event_Gadget
        EventGadgetID = #GADGET_AutoComplete_Abort
        
      Else
          
        
        ; main window menu events, close the autocomplete window and pass the event on
        MainWindowEvents(EventID)
        
        ; close the window after the main window processed the event (otherwise EventWindow() does a different output!?)
        ; note that the main window event could have already closed the window!!
        AutoComplete_Close()
        
        ProcedureReturn
        
      EndIf
    Else
      EventGadgetID = EventGadget()
    EndIf
    
    If EventID = #PB_Event_Gadget
      
      Select EventGadgetID
          
        Case #GADGET_AutoComplete_List
          CompilerIf #CompileLinux
            If EventType() = #PB_EventType_FirstCustomValue
              AutoComplete_WordUpdate(EventData())
            EndIf
          CompilerEndIf
          
          If EventType() = #PB_EventType_LeftDoubleClick
            AutoComplete_Insert()
          EndIf
          
        Case #GADGET_AutoComplete_Abort
          AutoComplete_Close()
          
          
        Case #GADGET_AutoComplete_Ok
          AutoComplete_Insert()
          
          
      EndSelect
      
    EndIf
    
  EndIf
  
EndProcedure


Procedure AutoComplete_CheckAutoPopup()
  
  If AutoPopupNormal Or AutoPopupStructures Or AutoPopupModules
    
    Line$ = GetCurrentLine()
    
    ; Debug "Check autopopup: " + Line$
    
    If Line$
      GetCursorPosition()
      
      ; Check the usual way for a word (same as AutoComplete_GetWord())
      Column = *ActiveSource\CurrentColumnChars-1
      found  = GetWordBoundary(@Line$, Len(Line$), Column, @StartIndex, @EndIndex, 1)
      
      If found And AutoPopupNormal And Column-StartIndex >= AutoCompletePopupLength
        ; word of enough length is found
        ProcedureReturn #True
        
      ElseIf AutoPopupStructures Or AutoPopupModules
        ; no word found (or not long enough), in structure/module mode, check if there is a \ or ::
        If found
          Column = StartIndex-1
        Else
          Column - 1 ; Column is the char after the cursor, but we want the one before it
        EndIf
        
        ; Skip any whitespace
        *Buffer = @Line$
        *Cursor.Character = *Buffer + Column * #CharSize
        While *Cursor > *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
          *Cursor - #CharSize
        Wend
        
        If AutoPopupStructures And *Cursor >= *Buffer And *Cursor\c = '\'
          ProcedureReturn #True
        ElseIf AutoPopupModules And *Cursor >= *Buffer + #CharSize And *Cursor\c = ':' And PeekC(*Cursor - #CharSize) = ':'
          ProcedureReturn #True
        EndIf
      EndIf
      
    EndIf
    
  EndIf
  
  ProcedureReturn #False
EndProcedure


Procedure AutoComplete_WordUpdate(IsInitial=#False)
  
  Word$ = ""
  LastChar = 0
  
  Line$ = GetCurrentLine()
  
  If Line$
    GetCursorPosition() ; Ensures than the fields are updated
    
    Column = *ActiveSource\CurrentColumnChars-1
    found = GetWordBoundary(@Line$, Len(Line$), Column, @StartIndex, @EndIndex, 1)
    
    If found
      Word$ = Mid(Line$, StartIndex+1, Column-StartIndex)
      
    ElseIf AutoComplete_IsStructure Or AutoComplete_IsModule
      If found
        Column = StartIndex-1
      Else
        Column - 1 ; Column is the char after the cursor, but we want the one before it
      EndIf
      
      ; we need to find out if the last char is still a '\', as anything else should force a close
      *Buffer = @Line$
      *Cursor.Character = *Buffer + Column * #CharSize
      While *Cursor > *Buffer And (*Cursor\c = ' ' Or *Cursor\c = 9)
        *Cursor - #CharSize
      Wend
      
      If *Cursor >= *Buffer ; remember the last non-whitespace char
        LastChar = *Cursor\c
        If *Cursor > *Buffer
          BeforeLastChar = PeekC(*Cursor - #CharSize)
        EndIf
      EndIf
    EndIf
  EndIf
  
  
  If AutoComplete_IsStructure And (*ActiveSource\CurrentColumnChars <= AutoComplete_StructureStart Or (Word$ = "" And LastChar <> '\'))
    AutoComplete_Close()
    
  ElseIf AutoComplete_IsModule And (*ActiveSource\CurrentColumnChars <= AutoComplete_ModuleStart Or (Word$ = "" And (Not (LastChar = ':' And BeforeLastChar = ':'))))
    AutoComplete_Close()
    
  ElseIf AutoComplete_IsStructure = 0 And AutoComplete_IsModule = 0 And (Word$ = "" Or Word$ = "*" Or Word$ = "#" Or (AutoPopupNormal And Len(Word$) < AutoCompletePopupLength))
    AutoComplete_Close()
    
  ElseIf AutoCompleteCharMatchOnly = 0 Or (AutoCompleteCharMatchOnly = 1 And AutoComplete_IsStructure = 0 And AutoComplete_IsModule = 0)
    ; If we display the full list, or only words that match the first char,
    ; the gadget items do never change (except if the word is empty in structure mode), so only update the position
    ;
    found = 0
    ForEach AutoCompleteList()
      result = CompareMemoryString(@Word$, PeekI(@AutoCompleteList()), 1)
      
      If result < 0
        If CompareMemoryString(@Word$, PeekI(@AutoCompleteList()), 1, Len(Word$)) = 0 ; only keep the window open when there is a possible match left
          SetGadgetState(#GADGET_AutoComplete_List, ListIndex(AutoCompleteList()))
          found = 1
        EndIf
        Break ; if this did not succeed, there are no more matches
        
      ElseIf result = 0
        SetGadgetState(#GADGET_AutoComplete_List, ListIndex(AutoCompleteList()))
        found = 1
        Break
      EndIf
    Next AutoCompleteList()
    
    If found = 0
      AutoComplete_Close()
    EndIf
    
  Else
    ; "Only Words that match the typed word" is on, we must find out which
    ; items to display and change the gadget content
    ;
    OldStart = AutoComplete_Start
    OldEnd   = AutoComplete_End
    
    If Word$ = ""
      ; this can happen in structure or module mode
      AutoComplete_Start = 0
      AutoComplete_End   = ListSize(AutoCompleteList())
      
    Else
      If (AutoComplete_IsStructure Or AutoComplete_IsModule) And AutoCompleteCharMatchOnly = 1
        Length = 1 ; for the first-char filtering in structure mode
      Else
        Length = Len(Word$)
      EndIf
      
      ; find new start and end
      AutoComplete_Start = -1
      ResetList(AutoCompleteList())
      While NextElement(AutoCompleteList())
        If CompareMemoryString(PeekI(@AutoCompleteList()), @Word$, 1, Length) >= 0
          AutoComplete_Start = ListIndex(AutoCompleteList())
          Break
        EndIf
      Wend
      
      
      AutoComplete_End = -1
      If AutoComplete_Start <> -1 And LastElement(AutoCompleteList())
        Repeat
          If CompareMemoryString(PeekI(@AutoCompleteList()), @Word$, 1, Length) <= 0
            AutoComplete_End = ListIndex(AutoCompleteList())
            Break
          EndIf
        Until Not PreviousElement(AutoCompleteList())
      EndIf
    EndIf
    
    If AutoComplete_End >= ListSize(AutoCompleteList())
      AutoComplete_End = ListSize(AutoCompleteList())-1
    EndIf
    
    ; If there is only one single possible match, and this matches exactly,
    ; then close the autocomplete window
    ;
    If AutoComplete_Start = AutoComplete_End And AutoComplete_Start <> -1
      SelectElement(AutoCompleteList(), AutoComplete_Start)
      If Word$ <> "" And CompareMemoryString(PeekI(@AutoCompleteList()), @Word$, 1) = 0
        AutoComplete_Start = -1
      EndIf
    EndIf
    
    If AutoComplete_Start > AutoComplete_End Or AutoComplete_Start = -1
      ; no more items to display
      AutoComplete_Close()
    Else
      
      ; add/remove gadget items as needed
      If OldStart < AutoComplete_Start
        For i = OldStart+1 To AutoComplete_Start
          RemoveGadgetItem(#GADGET_AutoComplete_List, 0)
        Next i
        AutoComplete_Redraw()
      ElseIf OldStart > AutoComplete_Start
        SelectElement(AutoCompleteList(), OldStart-1)
        Repeat
          AddGadgetItem(#GADGET_AutoComplete_List, 0, AutoCompleteList())
        Until ListIndex(AutoCompleteList()) = AutoComplete_Start Or PreviousElement(AutoCompleteList()) = 0
        AutoComplete_Redraw()
      EndIf
      
      If OldEnd > AutoComplete_End
        Last = CountGadgetItems(#GADGET_AutoComplete_List)-1
        For i = AutoComplete_End+1 To OldEnd
          RemoveGadgetItem(#GADGET_AutoComplete_List, Last)
          Last-1
        Next i
        AutoComplete_Redraw()
      ElseIf OldEnd < AutoComplete_End
        SelectElement(AutoCompleteList(), OldEnd+1)
        Repeat
          AddGadgetItem(#GADGET_AutoComplete_List, -1, AutoCompleteList())
        Until ListIndex(AutoCompleteList()) = AutoComplete_End Or NextElement(AutoCompleteList()) = 0
        AutoComplete_Redraw()
      EndIf
      
      ; call the OS function for dynamic resizing of the window
      ; do this before selecting the item for a correct selection
      AutoComplete_AdjustWindowSize(AutoComplete_CurrentMaxWidth, AutoComplete_CurrentMaxHeight)
      
      ; now find the right item to select
      If IsInitial And Word$ = "" And (AutoComplete_IsStructure Or AutoComplete_IsModule)
        
        ; select previous insertion (if possible)
        If AutoComplete_IsStructure
          Previous$ = AutoComplete_LastStructureItem(LCase(AutoComplete_CurrentStructure$))
        Else
          Previous$ = AutoComplete_LastModuleItem(LCase(AutoComplete_CurrentModule$))
        EndIf
        
        found = 0
        If Previous$ <> ""
          SelectElement(AutoCompleteList(), AutoComplete_Start)
          Repeat
            If Previous$ = LCase(AutoCompleteList())
              SetGadgetState(#GADGET_AutoComplete_List, ListIndex(AutoCompleteList())-AutoComplete_Start)
              found = 1
            EndIf
          Until ListIndex(AutoCompleteList()) = AutoComplete_End Or NextElement(AutoCompleteList()) = 0
        EndIf
        
        If found = 0
          ; previous selection is no longer available. select the first entry
          SetGadgetState(#GADGET_AutoComplete_List, 0)
        EndIf
        
      Else
        
        ; select best match
        SelectElement(AutoCompleteList(), AutoComplete_Start)
        found = 0
        Repeat
          result = CompareMemoryString(@Word$, PeekI(@AutoCompleteList()), 1)
          
          If result < 0
            If CompareMemoryString(@Word$, PeekI(@AutoCompleteList()), 1, Len(Word$)) = 0 ; only keep the window open when there is a possible match left
              SetGadgetState(#GADGET_AutoComplete_List, ListIndex(AutoCompleteList())-AutoComplete_Start)
              found = 1
            EndIf
            Break  ; if this did not succeed, there are no more items
            
          ElseIf result = 0
            SetGadgetState(#GADGET_AutoComplete_List, ListIndex(AutoCompleteList())-AutoComplete_Start)
            found = 1
            Break
          EndIf
        Until ListIndex(AutoCompleteList()) = AutoComplete_End Or NextElement(AutoCompleteList()) = 0
        
        If found=0
          AutoComplete_Close()
        EndIf
        
      EndIf
      
    EndIf
    
  EndIf
  
EndProcedure

CompilerIf #CompileLinux
  ; Move WordUpdate from Scintilla Callback to Event-Loop
  Macro AutoComplete_WordUpdate(IsInitial=#False)
    PostEvent(#PB_Event_Gadget, #WINDOW_AutoComplete, #GADGET_AutoComplete_List, #PB_EventType_FirstCustomValue, IsInitial)
  EndMacro
CompilerEndIf
