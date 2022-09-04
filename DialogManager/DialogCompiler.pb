; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
; Compiles a Dialog in xml format to a PB source datasection.
;
; The reason is that in the xml definition, we can use constants from the source,
; So the xml must be transformed into a PB file so it is compiled with the source, and
; the constants are known.
;
; CommandLine: xml_file pb_file

; Datasection structure:
;
; LONG: ObjectType
; LONG: ObjectID
; LONG: GadgetFlags
; LONG: minwidth  (or 0 if none)
; LONG: minheight (or 0 if none)
; LONG: 1 when either "lang" or "text" are set. 0 otherwise
; LONG: Number of extra option pairs
; String: ObjectName, LiteralText, LanguageGroup, LanguageKey
; String: OptionKey, OptionValue (pairs as much as the above number, can be none at all)
;
;   Any subitems, if object is a container
;
; LONG: -1 ; close item list (present for every element, also non-containers!)
;
; After the window objects -1 end, there are all shortcuts placed which were added for this
; window.they have this structure:
;
; LONG: ObjectType = #DIALOG_Shortcut
; LONG: Key
; LONG: ID
;
; At the end, another -1 to close the shortcut list
;
; Specal tags:
;
;  <dialoggroup>    - to group multiple dialogs in one file.. no special meaning otherwise
;  <compiler if=""> - compilerif block. pass a constant expr for the if
;  <compilerelse /> - compilerelse
;  <shortcut key="#KeyConstant" id="#IDConstant">
;

#EXIT_FAILURE = 1
#EXIT_SUCCESS = 0


Input$  = ProgramParameter()
Output$ = ProgramParameter()

; Input$  = "test.xml"
; Output$ = "test.pb"
; Input$  = "/home/freak/pbcvs/Fr34k/Sources/PureBasicIDE/dialogs/Find.xml"
; Output$ = "/home/freak/pbcvs/Fr34k/Sources/PureBasicIDE/dialogs/Dialog_Find.pb"

Structure ArgPair
  Name$
  Value$
EndStructure

Structure Shortcut
  Key$
  ID$
EndStructure

Global NewList Shortcuts.Shortcut()
Global Indent = 4, PreviousIndent = 2, parser

CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  #NewLineSequence = Chr(34)+"+Chr(13)+Chr(10)+"+Chr(34)
CompilerElse
  #NewLineSequence = Chr(34)+"+Chr(10)+"+Chr(34)
CompilerEndIf

; return true if the key is present, and makes this key the current element, Key must be uppercase
Procedure IsKey(List Args.ArgPair(), Key$)
  
  ForEach Args()
    If Args()\Name$ = Key$
      ProcedureReturn #True ; found
    EndIf
  Next Args()
  
  ProcedureReturn #False
EndProcedure

Procedure Error(Message$)
  Shared Output$
  OpenConsole()
  PrintN(Message$)
  CloseConsole()
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    MessageRequester("DialogCompiler", Message$)
  CompilerEndIf
  If IsFile(1)
    CloseFile(1)
  EndIf
  DeleteFile(Output$)
  End #EXIT_FAILURE
EndProcedure

ProcedureC StartElementHandler(user_data, *name, *args.INTEGER)
  NewList Args.ArgPair()
  
  Name$ = UCase(PeekS(*name, -1))
  
  ; The whole file may be surrounded by a <dialiggroup> tag, to include more
  ; than one dialog in a standard conform xml file (as one single "document" object is needed)
  ; We just ignore this tag
  ;
  If Name$ = "DIALOGGROUP"
    ProcedureReturn
  EndIf
  
  ; get the stuff in a PB format
  ;
  While *args\i
    AddElement(Args())
    Args()\Name$ = UCase(PeekS(*args\i, -1))
    *args + SizeOf(INTEGER)
    Args()\Value$ = PeekS(*args\i, -1)
    *args + SizeOf(INTEGER)
  Wend
  
  If PreviousIndent <> Indent
    PreviousIndent = Indent
    WriteStringN(1, "")
  EndIf
  
  If Name$ = "COMPILER" ; compilerif statement...
    If IsKey(Args(), "IF")
      WriteStringN(1, Space(Indent) + "CompilerIf " + Args()\Value$)
    Else
      Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "Invalid compilerif statement!")
    EndIf
    
    PreviousIndent = Indent
    Indent + 2
    ProcedureReturn
    
  ElseIf Name$ = "COMPILERELSE"
    WriteStringN(1, "")
    WriteStringN(1, Space(Indent-2) + "CompilerElse")
    WriteStringN(1, "")
    ProcedureReturn
    
  ElseIf Name$ = "SHORTCUT"
    AddElement(Shortcuts())
    If IsKey(Args(), "KEY")
      Shortcuts()\Key$ = Args()\Value$
    EndIf
    If IsKey(Args(), "ID")
      Shortcuts()\ID$ = Args()\Value$
    EndIf
    ProcedureReturn ; abort here!
  EndIf
  
  Select Name$
      
    Case "WINDOW" ; special case, it must have a "label" attribute
      Type$ = "#DIALOG_Window"
      
      If Indent <> 4 ; if it is not that, there is something wrong
        Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "WINDOW object must be at the main level!")
      EndIf
      
      If IsKey(Args(), "LABEL")
        WriteStringN(1, "  " + Args()\Value$ + ":")
        DeleteElement(Args())
      Else
        Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "WINDOW object must have a LABEL attribute!")
      EndIf
      
      
    Case "EMPTY":        Type$ = "#DIALOG_Empty"
    Case "VBOX":         Type$ = "#DIALOG_VBox"
    Case "HBOX":         Type$ = "#DIALOG_HBox"
    Case "MULTIBOX":     Type$ = "#DIALOG_Multibox"
    Case "SINGLEBOX":    Type$ = "#DIALOG_Singlebox"
    Case "GRIDBOX":      Type$ = "#DIALOG_Gridbox"
      
    Case "BUTTON":       Type$ = "#DIALOG_Button"
    Case "CHECKBOX":     Type$ = "#DIALOG_Checkbox"
    Case "IMAGE":        Type$ = "#DIALOG_Image"
    Case "OPTION":       Type$ = "#DIALOG_Option"
    Case "LISTVIEW":     Type$ = "#DIALOG_ListView"
    Case "LISTICON":     Type$ = "#DIALOG_ListIcon"
    Case "TREE":         Type$ = "#DIALOG_Tree"
    Case "CONTAINER":    Type$ = "#DIALOG_Container"
    Case "COMBOBOX":     Type$ = "#DIALOG_ComboBox"
    Case "TEXT":         Type$ = "#DIALOG_Text"
    Case "STRING":       Type$ = "#DIALOG_String"
    Case "PANEL":        Type$ = "#DIALOG_Panel"
    Case "TAB":          Type$ = "#DIALOG_Tab"
    Case "SCROLL":       Type$ = "#DIALOG_Scroll"
    Case "FRAME":        Type$ = "#DIALOG_Frame"
    Case "ITEM":         Type$ = "#DIALOG_Item"
    Case "COLUMN":       Type$ = "#DIALOG_Column"
    Case "EDITOR":       Type$ = "#DIALOG_Editor"
    Case "SCINTILLA":    Type$ = "#DIALOG_Scintilla"
    Case "SCROLLBAR":    Type$ = "#DIALOG_ScrollBar"
    Case "PROGRESSBAR":  Type$ = "#DIALOG_ProgressBar"
    Case "EXPLORERLIST": Type$ = "#DIALOG_ExplorerList"
    Case "EXPLORERTREE": Type$ = "#DIALOG_ExplorerTree"
    Case "EXPLORERCOMBO":Type$ = "#DIALOG_ExplorerCombo"
    Case "SPLITTER":     Type$ = "#DIALOG_Splitter"
    Case "SHORTCUTGADGET":Type$ = "#DIALOG_ShortcutGadget"
    Case "BUTTONIMAGE":  Type$ = "#DIALOG_ButtonImage"
    Case "TRACKBAR":     Type$ = "#DIALOG_TrackBar"
    Case "HYPERLINK":    Type$ = "#DIALOG_HyperLink"
      
    Default
      Error("Syntax Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + "Unknown Tag: " + PeekS(*name))
      
  EndSelect
  
  WriteStringN(1, Space(Indent) + "Data.l " + Type$)
  
  If IsKey(Args(), "ID")
    WriteString(1, Space(Indent) + "Data.l " + Args()\Value$)
    DeleteElement(Args())
  Else
    WriteString(1, Space(Indent) + "Data.l #PB_Any")
  EndIf
  
  If IsKey(Args(), "FLAGS")
    WriteString(1, ", " + Args()\Value$)
    DeleteElement(Args())
  ElseIf Name$ = "ITEM" And IsKey(Args(), "SUBLEVEL") ; for treegadget items (see preferences)
    WriteString(1, ", " + Args()\Value$)
    DeleteElement(Args())
  Else
    WriteString(1, ", 0")
  EndIf
  
  If IsKey(Args(), "WIDTH")
    If UCase(Args()\Value$) = "IGNORE"
      WriteString(1, ", -1") ; special value to indicate that this size should not be calculated
    Else
      WriteString(1, ", " + Args()\Value$)
    EndIf
    DeleteElement(Args())
  Else
    WriteString(1, ", 0")
  EndIf
  
  If IsKey(Args(), "HEIGHT")
    If UCase(Args()\Value$) = "IGNORE"
      WriteString(1, ", -1")
    Else
      WriteString(1, ", " + Args()\Value$)
    EndIf
    DeleteElement(Args())
  Else
    WriteString(1, ", 0")
  EndIf
  
  If IsKey(Args(), "TEXT")
    LiteralText$ = Args()\Value$
    DeleteElement(Args())
  EndIf
  
  HasText = 0
  If IsKey(Args(), "LANG")
    LanguageGroup$ = StringField(Args()\Value$, 1, ":")
    LanguageKey$   = StringField(Args()\Value$, 2, ":")
    HasText = 1
    DeleteElement(Args())
  EndIf
  
  If IsKey(Args(), "NAME")
    ObjectName$ = UCase(Args()\Value$) ; we store the name in ucase
    HasText = 1
    DeleteElement(Args())
  EndIf
  
  WriteStringN(1, ", " + Str(HasText) + ", " + Str(ListSize(Args())))
  WriteStringN(1, Space(Indent) + "Data.s " + Chr(34)+ObjectName$+Chr(34) + ", " + Chr(34)+ReplaceString(LiteralText$, "%newline%", #NewLineSequence)+Chr(34)+", "+Chr(34)+LanguageGroup$+Chr(34)+", "+Chr(34)+LanguageKey$+Chr(34))
  
  ForEach Args()
    WriteStringN(1, Space(Indent) + "Data.s " + Chr(34)+Args()\Name$+Chr(34)+", "+Chr(34)+Args()\Value$+Chr(34))
  Next Args()
  
  PreviousIndent = Indent
  Indent + 2
  
EndProcedure

ProcedureC EndElementHandler(user_data, *name)
  
  Name$ = UCase(PeekS(*name, -1))
  
  If Name$ = "DIALOGGROUP" Or Name$ = "COMPILERELSE" Or Name$ = "SHORTCUT"
    ProcedureReturn
  EndIf
  
  ; just finish whatever object is present
  ;
  Indent - 2
  PreviousIndent = Indent
  
  If Name$ = "COMPILER"
    WriteStringN(1, Space(Indent) + "CompilerEndIf")
  Else
    WriteStringN(1, Space(Indent) + "Data.l -1")
  EndIf
  
  WriteStringN(1, "")
  
  If Name$ = "WINDOW" ; when the window object is done, add all the shortcuts after
    ForEach Shortcuts()
      WriteStringN(1, Space(Indent) + "Data.l #DIALOG_Shortcut, " + Shortcuts()\Key$ + ", " + Shortcuts()\ID$)
    Next Shortcuts()
    
    ClearList(Shortcuts()) ; clear the list for the next window object
    WriteStringN(1, Space(Indent) + "Data.l -1")
    WriteStringN(1, "")
  EndIf
  
EndProcedure


If ReadFile(0, Input$) = 0 Or CreateFile(1, Output$) = 0
  Error("File I/O Error")
EndIf

parser = pb_XML_ParserCreate_(0)
length = Lof(0)
buffer = AllocateMemory(length)

If parser = 0 Or buffer = 0
  Error("Memory Error")
EndIf

ReadData(0, buffer, length)
CloseFile(0)

pb_XML_SetStartElementHandler_(parser, @StartElementHandler())
pb_XML_SetEndElementHandler_(parser, @EndElementHandler())


WriteStringN(1, "")
WriteStringN(1, ";")
WriteStringN(1, "; PureBasic IDE - Dialog Manager file")
WriteStringN(1, ";")
WriteStringN(1, "; Autogenerated from "+Chr(34)+Input$+Chr(34))
WriteStringN(1, "; Do not edit!")
WriteStringN(1, ";")
WriteStringN(1, "")
WriteStringN(1, "DataSection")
WriteStringN(1, "")

If pb_XML_Parse_(parser, buffer, length, #True) = #XML_STATUS_ERROR ; only output a message in case of error
  Error("Parser Error (Line " + Str(pb_XML_GetCurrentLineNumber_(parser)) + "): " + PeekS(pb_XML_ErrorString_(pb_XML_GetErrorCode_(parser))))
EndIf

WriteStringN(1, "")
WriteStringN(1, "EndDataSection")
WriteStringN(1, "")

CloseFile(1)
FreeMemory(buffer)
pb_XML_ParserFree_(parser)

End #EXIT_SUCCESS

