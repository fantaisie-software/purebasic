; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

;
; The IDE dialogs (dialogs/*.xml) are created with the PureBasic Dialog library.
; This file keeps the interface of the old DialogManager, so the IDE code doesn't change:
;
;   Dialog.DialogWindow = OpenDialog(?Dialog_Find, WindowID(#WINDOW_Main), @FindWindowPosition)
;
; The XML files are included in the executable and parsed when a dialog is opened. As the XML is read at
; runtime, all the constants used in it (ids, <compiler if="">) must be declared with 'Runtime'.
;

; Represents the size/position info for a dialog
;
Structure DialogPosition
  x.l
  y.l
  Width.l
  Height.l
  IsMaximized.l
EndStructure

Interface DialogWindow
  Window()          ; Get the #Window number of the dialog window
  Gadget(Name$)     ; Get the #Gadget number of the gadget where the 'name' tag is set to Name$ (case insensitive)
  Fold(Name$, State); Fold/Unfold an object based on its 'name' tag
  LanguageUpdate()  ; Update all language strings
  GuiUpdate()       ; Re-calculate and resize gui (call this when for example font sizes have changed, or after language updates)
  SizeUpdate()      ; call this after a #PB_Event_SizeWindow for a resizable dialog. (updates all sizes to fit the current window size)
  Close(*Sizing.DialogPosition = 0) ; close the window and free all data. fill the *Sizing structrue with data if present
EndInterface

Structure DialogLibraryWindow
  *VTable
  Dialog.i
EndStructure

; Read by the <compiler if="IDE_ProjectCompilerOptions"> blocks of dialogs/CompilerOptions.xml
Global IDE_ProjectCompilerOptions
Runtime IDE_ProjectCompilerOptions

; Gadget size calculation, also used outside of the dialogs
XIncludeFile ".." + #Separator + "DialogManager" + #Separator + "GetRequiredSize.pb"


; Returns the flags attribute of the named <window> (to know if it can be resized or maximized)
;
Procedure.s DialogLibrary_WindowFlags(*Node, Name$)
  Protected Flags$, *Child

  While *Node
    If XMLNodeType(*Node) = #PB_XML_Normal
      If LCase(GetXMLNodeName(*Node)) = "window"
        If LCase(GetXMLAttribute(*Node, "name")) = LCase(Name$)
          ProcedureReturn LCase(GetXMLAttribute(*Node, "flags"))
        EndIf
      Else
        Flags$ = DialogLibrary_WindowFlags(ChildXMLNode(*Node), Name$) ; <dialoggroup>
        If Flags$
          ProcedureReturn Flags$
        EndIf
      EndIf
    EndIf
    *Node = NextXMLNode(*Node)
  Wend

  ProcedureReturn ""
EndProcedure


Procedure DialogLibrary_Window(*THIS.DialogLibraryWindow)
  ProcedureReturn DialogWindow(*THIS\Dialog)
EndProcedure


Procedure DialogLibrary_Gadget(*THIS.DialogLibraryWindow, Name$)
  Protected Gadget = DialogGadget(*THIS\Dialog, Name$)

  If Gadget = -1
    ProcedureReturn 0 ; like the DialogManager
  EndIf

  ProcedureReturn Gadget
EndProcedure


Procedure DialogLibrary_Fold(*THIS.DialogLibraryWindow, Name$, State)
  FoldDialogElement(*THIS\Dialog, Name$, State)
EndProcedure


; The texts are updated for all the dialogs by DialogLanguage() when the language is loaded (see LoadLanguage())
;
Procedure DialogLibrary_LanguageUpdate(*THIS.DialogLibraryWindow)
EndProcedure


Procedure DialogLibrary_GuiUpdate(*THIS.DialogLibraryWindow)
  RefreshDialog(*THIS\Dialog)
EndProcedure


Procedure DialogLibrary_SizeUpdate(*THIS.DialogLibraryWindow)
  RefreshDialog(*THIS\Dialog)
EndProcedure


Procedure DialogLibrary_Close(*THIS.DialogLibraryWindow, *Sizing.DialogPosition)
  Protected Window = DialogWindow(*THIS\Dialog)

  If *Sizing
    If GetWindowState(Window) & #PB_Window_Minimize = 0
      *Sizing\IsMaximized = GetWindowState(Window) & #PB_Window_Maximize
      If *Sizing\IsMaximized = 0
        *Sizing\x      = WindowX(Window)
        *Sizing\y      = WindowY(Window)
        *Sizing\Width  = WindowWidth(Window)
        *Sizing\Height = WindowHeight(Window)
      EndIf
    EndIf
  EndIf

  FreeDialog(*THIS\Dialog) ; closes the window
  FreeMemory(*THIS)
EndProcedure


; *DataOffset is one of the Dialog_* labels of the DataSection below
;
Procedure OpenDialog(*DataOffset, ParentID = 0, *Sizing.DialogPosition = 0)
  Static Initialized
  Protected *THIS.DialogLibraryWindow, Xml, Name$, Flags$, x, y, Width, Height, *XmlStart, *XmlEnd

  If Initialized = 0
    UseDialogScintillaGadget() ; for the Templates and Projects dialogs
    Initialized = 1
  EndIf

  *XmlStart = PeekI(*DataOffset)
  *XmlEnd   = PeekI(*DataOffset + SizeOf(Integer))
  IDE_ProjectCompilerOptions = PeekI(*DataOffset + 2 * SizeOf(Integer))
  Name$     = PeekS(*DataOffset + 3 * SizeOf(Integer))

  Xml = CatchXML(#PB_Any, *XmlStart, *XmlEnd - *XmlStart)
  If Xml = 0
    ProcedureReturn 0
  EndIf

  If XMLStatus(Xml) <> #PB_XML_Success
    MessageRequester("Dialog", Name$ + ": " + XMLError(Xml) + " (line " + XMLErrorLine(Xml) + ")")
    FreeXML(Xml)
    ProcedureReturn 0
  EndIf

  Flags$ = DialogLibrary_WindowFlags(MainXMLNode(Xml), Name$)

  ; no saved position: centered
  x = #PB_Ignore
  y = #PB_Ignore
  If *Sizing And *Sizing\x <> -1 And *Sizing\y <> -1
    x = *Sizing\x
    y = *Sizing\y
  EndIf

  ; the saved size is only used for resizable dialogs (the dialog is never smaller than its content)
  If *Sizing And FindString(Flags$, "sizegadget") And *Sizing\Width <> -1 And *Sizing\Height <> -1
    Width  = *Sizing\Width
    Height = *Sizing\Height
  EndIf

  *THIS = AllocateMemory(SizeOf(DialogLibraryWindow))
  *THIS\VTable = ?DialogLibrary_VTable
  *THIS\Dialog = CreateDialog(#PB_Any)

  If OpenXMLDialog(*THIS\Dialog, Xml, Name$, x, y, Width, Height, ParentID) = 0
    MessageRequester("Dialog", Name$ + ": " + DialogError(*THIS\Dialog))
    FreeDialog(*THIS\Dialog)
    FreeMemory(*THIS)
    *THIS = 0

  ElseIf *Sizing And *Sizing\IsMaximized And FindString(Flags$, "maximizegadget")
    SetWindowState(DialogWindow(*THIS\Dialog), #PB_Window_Maximize)
    RefreshDialog(*THIS\Dialog)
  EndIf

  FreeXML(Xml) ; the dialog doesn't need it anymore
  ProcedureReturn *THIS
EndProcedure


Macro DialogLibrary_Quote
  "
EndMacro

; The window 'name' attribute is the label
Macro DialogLibrary_Dialog(Label, File, Project = 0)
  Label:
  Data.i ?DialogXml_#File, ?DialogXml_#File#_End, Project
  Data.s DialogLibrary_Quote#Label#DialogLibrary_Quote
EndMacro

Macro DialogLibrary_IncludeXml(File)
  DialogXml_#File:
  IncludeBinary "dialogs" + #Separator + DialogLibrary_Quote#File.xml#DialogLibrary_Quote
  DialogXml_#File#_End:
EndMacro


DataSection

  DialogLibrary_VTable:
  Data.i @DialogLibrary_Window()
  Data.i @DialogLibrary_Gadget()
  Data.i @DialogLibrary_Fold()
  Data.i @DialogLibrary_LanguageUpdate()
  Data.i @DialogLibrary_GuiUpdate()
  Data.i @DialogLibrary_SizeUpdate()
  Data.i @DialogLibrary_Close()

  ; Label, XML file (in dialogs/), 1 for the project version of the compiler options
  ;
  DialogLibrary_Dialog(Dialog_About, About)
  DialogLibrary_Dialog(Dialog_AddTools, AddTools)
  DialogLibrary_Dialog(Dialog_EditTools, AddTools)
  DialogLibrary_Dialog(Dialog_Build, Build)
  DialogLibrary_Dialog(Dialog_CompilerOptions, CompilerOptions)
  DialogLibrary_Dialog(Dialog_ProjectCompilerOptions, CompilerOptions, 1)
  DialogLibrary_Dialog(Dialog_DiffDialog, Diff)
  DialogLibrary_Dialog(Dialog_FileMonitor, FileMonitor)
  DialogLibrary_Dialog(Dialog_Find, Find)
  DialogLibrary_Dialog(Dialog_Goto, Goto)
  DialogLibrary_Dialog(Dialog_Grep, Grep)
  DialogLibrary_Dialog(Dialog_GrepOutput, Grep)
  DialogLibrary_Dialog(Dialog_History, History)
  DialogLibrary_Dialog(Dialog_HistoryShutdown, HistoryShutdown)
  DialogLibrary_Dialog(Dialog_Preferences, Preferences)
  DialogLibrary_Dialog(Dialog_ProjectOptions, Projects)
  DialogLibrary_Dialog(Dialog_StructureViewer, StructureViewer)
  DialogLibrary_Dialog(Dialog_Templates, Templates)
  DialogLibrary_Dialog(Dialog_Updates, Updates)
  CompilerIf #SpiderBasic
    DialogLibrary_Dialog(Dialog_CreateApp, CreateApp)
  CompilerEndIf

  DialogLibrary_IncludeXml(About)
  DialogLibrary_IncludeXml(AddTools)
  DialogLibrary_IncludeXml(Build)
  DialogLibrary_IncludeXml(CompilerOptions)
  DialogLibrary_IncludeXml(Diff)
  DialogLibrary_IncludeXml(FileMonitor)
  DialogLibrary_IncludeXml(Find)
  DialogLibrary_IncludeXml(Goto)
  DialogLibrary_IncludeXml(Grep)
  DialogLibrary_IncludeXml(History)
  DialogLibrary_IncludeXml(HistoryShutdown)
  DialogLibrary_IncludeXml(Preferences)
  DialogLibrary_IncludeXml(Projects)
  DialogLibrary_IncludeXml(StructureViewer)
  DialogLibrary_IncludeXml(Templates)
  DialogLibrary_IncludeXml(Updates)
  CompilerIf #SpiderBasic
    DialogLibrary_IncludeXml(CreateApp)
  CompilerEndIf

EndDataSection
