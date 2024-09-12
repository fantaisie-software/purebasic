; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Define these for easier crossplatform development, also without the IDE
;
CompilerIf Defined(CompileWindows, #PB_Constant) = 0
  CompilerSelect #PB_Compiler_OS
    CompilerCase #PB_OS_Windows
      #CompileWindows   = 1
      #CompileLinux     = 0
      #CompileLinuxGtk  = 0
      #CompileLinuxGtk2 = 0
      #CompileLinuxGtk3 = 0
      #CompileMac       = 0
      #CompileMacCocoa  = 0
      #CompileLinuxQt   = 0
      
    CompilerCase #PB_OS_Linux
      #CompileWindows   = 0
      #CompileLinux     = 1
      CompilerIf Subsystem("Gtk2")
        #CompileLinuxGtk  = 1
        #CompileLinuxGtk2 = 1
        #CompileLinuxGtk3 = 0
        #CompileLinuxQt   = 0
      CompilerElseIf Subsystem("Qt")
        #CompileLinuxGtk  = 0
        #CompileLinuxGtk2 = 0
        #CompileLinuxGtk3 = 0
        #CompileLinuxQt   = 1
      CompilerElse
        #CompileLinuxGtk  = 1
        #CompileLinuxGtk2 = 0
        #CompileLinuxGtk3 = 1
        #CompileLinuxQt   = 0
      CompilerEndIf
      #CompileMac       = 0
      #CompileMacCocoa  = 0
      
    CompilerCase #PB_OS_MacOS
      #CompileWindows   = 0
      #CompileLinux     = 0
      #CompileLinuxGtk  = 0
      #CompileLinuxGtk2 = 0
      #CompileLinuxGtk3 = 0
      #CompileMac       = 1
      #CompileMacCocoa  = 1
      
  CompilerEndSelect
CompilerEndIf


; Max number of children that any container can have.
;
#MAX_CHILDLIST = 100

Enumeration 1
  #DIALOG_Window
  #DIALOG_Shortcut ; not a real object, only used during dialog creation
  
  #DIALOG_Button
  #DIALOG_Checkbox
  #DIALOG_Image
  #DIALOG_Option
  #DIALOG_ListView
  #DIALOG_ListIcon
  #DIALOG_Tree
  #DIALOG_Container
  #DIALOG_ComboBox
  #DIALOG_Text
  #DIALOG_String
  #DIALOG_Panel
  #DIALOG_Tab
  #DIALOG_Scroll
  #DIALOG_Frame
  #DIALOG_Item
  #DIALOG_Column
  #DIALOG_Editor
  #DIALOG_Scintilla
  #DIALOG_ScrollBar
  #DIALOG_ProgressBar
  #DIALOG_ExplorerList
  #DIALOG_ExplorerTree
  #DIALOG_ExplorerCombo
  #DIALOG_Splitter
  #DIALOG_ShortcutGadget
  #DIALOG_ButtonImage
  #DIALOG_TrackBar
  #DIALOG_HyperLink
  
  ; virtual packing objects
  #DIALOG_VBox
  #DIALOG_HBox
  #DIALOG_Multibox
  #DIALOG_Singlebox
  #DIALOG_Gridbox
  #DIALOG_Empty
EndEnumeration

; Alignment Properties
;
Enumeration ; also used for left, center, right
  #Dlg_Align_Top = 1 ; do not include 0 for better testing
  #Dlg_Align_Center
  #Dlg_Align_Bottom
EndEnumeration

; Expansion Properties
;
Enumeration
  #Dlg_Expand_Yes = 1
  #Dlg_Expand_No
  #Dlg_Expand_Equal
  #Dlg_Expand_Item
EndEnumeration

; Represents the size/position info for a dialog
;
Structure DialogPosition
  x.l
  y.l
  Width.l
  Height.l
  IsMaximized.l
EndStructure


; Representation of the fixed values in the datasection
;
Structure DialogObjectData
  Type.l
  Gadget.l ; remains .l as here are no PB_Any objects
  Flags.l
  MinWidth.l
  MinHeight.l
  HasText.l
  KeyCount.l
EndStructure

; Representation of a shortcut in the datasection
;
Structure DialogShortcutData
  Type.l ; = #DIALOG_Shortcut
  Key.l
  MenuItem.l
EndStructure


; Functions implemented for each dialog object
;
; Note:
;   SizeRequestReal() should be the real function.
;   SizeRequest() should always be the DlgBase_SizeRequestWrapper()
;   function for all Objects. This wrapper properly checks for the
;   width="ignore" setting and applies it so it does not have to be done
;   in all code separately
;
;   Do not call SizeRequestReal() directly, but always call through
;   SizeRequest()
;
Interface DialogObject
  SizeRequest(*Width.LONG, *Height.LONG)
  SizeRequestReal(*Width.LONG, *Height.LONG)
  SizeApply(x, y, Width, Height)
  AddChild(Child.DialogObject)
  FoldApply(State)
  Find(Name$)
  Finish()
  Update()
  Destroy()
EndInterface


; The Window object (the main object of a dialog) implements more methods for public access
; by the user. Note that the DialogObject functions are designed to be called inside the
; Dialog files only.
;
Interface DialogWindow Extends DialogObject
  Window()          ; Get the #Window number of the dialog window
  Gadget(Name$)     ; Get the #Gadget number of the gadget where the 'name' tag is set to Name$ (case insensitive)
  Fold(Name$, State); Fold/Unfold an object based on its 'name' tag
  LanguageUpdate()  ; Update all language strings
  GuiUpdate()       ; Re-calculate and resize gui (call this when for example font sizes have changed, or after language updates)
  SizeUpdate()      ; call this after a #PB_Event_SizeWindow for a resizable dialog. (updates all sizes to fit the current window size)
  Close(*Sizing.DialogPosition = 0) ; close the window and free all data. fill the *Sizing structrue with data if present
EndInterface


Declare OpenDialog(*DataOffset.DialogObjectData, ParentID = 0, *Sizing.DialogPosition = 0)

