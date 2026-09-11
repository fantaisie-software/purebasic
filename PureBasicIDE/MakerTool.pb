; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

; Maker Tool Panel Item 

EnableExplicit

;- Enumerations
#MAKER_Prefix_ToDo = "; TODO "
#MAKER_Prefix_Debug = "Debug "
#MAKER_Suffix_1 = " (^P1):"
#MAKER_Suffix_2 = " (^P2):"
#MAKER_Suffix_3 = " (^P3):"

Enumeration 
  #MAKER_ENUM_WindowEvents
  #MAKER_ENUM_GadgetEvents
  #MAKER_ENUM_VariableViewer
  #MAKER_ENUM_AdHoc
EndEnumeration

Enumeration 
  #MAKER_ITEMTYPE_Constant
  #MAKER_ITEMTYPE_Numeric
  #MAKER_ITEMTYPE_Unquoted
  #MAKER_ITEMTYPE_Quoted
EndEnumeration

Enumeration 
  #MAKER_MAKE_If
  #MAKER_MAKE_Select
  #MAKER_MAKE_ProcedureSkeleton
  #MAKER_MAKE_Declarations
  #MAKER_MAKE_TidyOnly
  #MAKER_MAKE_TemplateOnly
EndEnumeration

EnumerationBinary 
  #MAKER_OPTION_IncludeOptional
  #MAKER_OPTION_IncludeDebug
  #MAKER_OPTION_IncludeToDo
EndEnumeration

Enumeration 
  #MAKER_SUBTYPE_None
  #MAKER_SUBTYPE_Gadget
EndEnumeration

Enumeration
  #MAKER_TAB_Make
  #MAKER_TAB_Enum
  #MAKER_TAB_Template
  #MAKER_TAB_Code
EndEnumeration

Enumeration
  #MAKER_TEMPLATE_None
  #MAKER_TEMPLATE_FromTool
  #MAKER_TEMPLATE_AdHoc
EndEnumeration

EnumerationBinary 
  #MAKER_TIDY_TruncateColon
  #MAKER_TIDY_TruncateEquals
  #MAKER_TIDY_TruncateSemiColon
  #MAKER_TIDY_TruncateType
EndEnumeration

;- Structures
Structure MakerToolData Extends ToolsPanelEntry
  IsEnabled.b
  IsCurrent.b
  MaxW.u
  CurrentPanelTab.b
  CurrentMakeType.b
  CurrentEnumType.b
  CurrentSubType.b
  CurrentTemplateType.b
  CurrentOptions.i
  CurrentTidy.i
  CurrentGadget.i
  AdHocEnum$
  AdHocTemplate$
  Param1$
  Param2$
  Param3$
EndStructure

Structure MakerItem
  String$
  Type.b
EndStructure

;- Declarations
Declare Maker_CreateFunction(*Entry.MakerToolData)
Declare Maker_DestroyFunction(*Entry.MakerToolData)
Declare Maker_EventHandler(*Entry.MakerToolData, EventGadgetID)
Declare Maker_ResizeHandler(*Entry.MakerToolData, PanelWidth, PanelHeight)
Declare Maker_ChangeEnumType(Force.i = #PB_Ignore)
Declare Maker_ChangeMakeType(Force.i = #PB_Ignore)
Declare Maker_ChangeSubType(Force.i = #PB_Ignore)
Declare Maker_ChangeTemplateType(Force.i = #PB_Ignore)
Declare Maker_ClearAll()
Declare Maker_DisableOptions(Optional.b, Dbug.b, ToDo.b)
Declare Maker_DisableSubType(State.b, Label.s = #Empty$)
Declare Maker_DisableTidy(SemiColon.b, Equals.b, Colon.b, Type.b)
Declare Maker_GetEnumList(Gadget.i)
Declare Maker_GetTemplate()
Declare Maker_GetVariableViewer()
Declare.s Maker_ReplacePlaceHolders(String$, Quotes.b = #False)
Declare Maker_MakeGeneral(Preamble$, First$, FirstIndent.b, Each$, EachIndent.b, Option$, OptionIndent.b, Last$, LastIndent.b)
Declare Maker_MakeDeclare()
Declare Maker_PasteButton()
Declare Maker_SwitchEnum(Gadget.b)
Declare Maker_UpdateCode()
Declare Maker_UpdateLabels(P1.S, P2.S, P3.S, Option.S)

;- Globals
Global NewList MakerEnumList.MakerItem()
Global NewList MakerTemplate.S()
Global NewList MakerOutput.S()
Global *Maker.MakerToolData

Procedure Maker_CreateFunction(*Entry.MakerToolData)
  ; Creates the gadgets for the selected layout.
  
  Define Icon, Index, Width
  
  ; Currently uses the same layout in both configurations.
  ; If *Entry\IsSeparateWindow
  
  PanelGadget(#GADGET_Maker_Panel, 0, 0, 0, 0)
  
  ; Make tab.
  AddGadgetItem(#GADGET_Maker_Panel, #MAKER_TAB_Enum, Language("Maker", "Make"))
  FrameGadget(#GADGET_Maker_FrameMake, 0, 0, 0, 0, Language("Maker", "Make")) 
  ComboBoxGadget(#GADGET_Maker_ComboMakeType, 0, 0, 0, 0)
  FrameGadget(#GADGET_Maker_FrameParam, 0, 0, 0, 0, Language("Maker", "Parameters")) 
  TextGadget(#GADGET_Maker_LabelParam1, 0, 0, 0, 0, #Empty$)
  StringGadget(#GADGET_Maker_StringParam1, 0, 0, 0, 0, #Empty$)
  TextGadget(#GADGET_Maker_LabelParam2, 0, 0, 0, 0, #Empty$)
  StringGadget(#GADGET_Maker_StringParam2, 0, 0, 0, 0, #Empty$)
  TextGadget(#GADGET_Maker_LabelParam3, 0, 0, 0, 0, #Empty$)
  StringGadget(#GADGET_Maker_StringParam3, 0, 0, 0, 0, #Empty$)
  
  ; Options frame.
  FrameGadget(#GADGET_Maker_FrameOption, 0, 0, 0, 0, Language("Maker", "Options")) 
  CheckBoxGadget(#GADGET_Maker_CheckOptional, 0, 0, 0, 0, Language("Maker", "OptionIf"))
  CheckBoxGadget(#GADGET_Maker_CheckDebug, 0, 0, 0, 0, Language("Maker", "OptionDebug"))
  CheckBoxGadget(#GADGET_Maker_CheckToDo, 0, 0, 0, 0, Language("Maker", "OptionToDo"))
  
  ; Tidy frame.
  FrameGadget(#GADGET_Maker_FrameTidy, 0, 0, 0, 0, Language("Maker", "Tidy")) 
  CheckBoxGadget(#GADGET_Maker_CheckType, 0, 0, 0, 0, Language("Maker", "TidyType"))
  CheckBoxGadget(#GADGET_Maker_CheckSemiColon, 0, 0, 0, 0, Language("Maker", "TidySemiColon"))
  CheckBoxGadget(#GADGET_Maker_CheckEquals, 0, 0, 0, 0, Language("Maker", "TidyEquals"))
  CheckBoxGadget(#GADGET_Maker_CheckColon, 0, 0, 0, 0, Language("Maker", "TidyColon"))
  
  ; Find widest label in the current language.
  SetGadgetText(#GADGET_Maker_LabelParam1, Language("Maker", "Custom") + #MAKER_Suffix_1)
  Width = GadgetWidth(#GADGET_Maker_LabelParam1, #PB_Gadget_RequiredSize)
  If Width > *Maker\MaxW
    *Maker\MaxW = Width
  EndIf
  SetGadgetText(#GADGET_Maker_LabelParam1, Language("Maker", "Unused") + #MAKER_Suffix_1)
  Width = GadgetWidth(#GADGET_Maker_LabelParam1, #PB_Gadget_RequiredSize)
  If Width > *Maker\MaxW
    *Maker\MaxW = Width
  EndIf
  SetGadgetText(#GADGET_Maker_LabelParam1, Language("Maker", "P1If") + #MAKER_Suffix_1)
  Width = GadgetWidth(#GADGET_Maker_LabelParam1, #PB_Gadget_RequiredSize)
  If Width > *Maker\MaxW
    *Maker\MaxW = Width
  EndIf
  SetGadgetText(#GADGET_Maker_LabelParam1, Language("Maker", "P1Procedure") + #MAKER_Suffix_1)
  Width = GadgetWidth(#GADGET_Maker_LabelParam1, #PB_Gadget_RequiredSize)
  If Width > *Maker\MaxW
    *Maker\MaxW = Width
  EndIf
  SetGadgetText(#GADGET_Maker_LabelParam1, Language("Maker", "P2Procedure") + #MAKER_Suffix_1)
  Width = GadgetWidth(#GADGET_Maker_LabelParam1, #PB_Gadget_RequiredSize)
  If Width > *Maker\MaxW
    *Maker\MaxW = Width
  EndIf
  
  ; Enumeration tab.
  AddGadgetItem(#GADGET_Maker_Panel, #MAKER_TAB_Enum, Language("Maker", "Enumeration"))
  TextGadget(#GADGET_Maker_LabelEnumType, 0, 0, 0, 0, Language("Maker", "Enumeration") + ":")
  ComboBoxGadget(#GADGET_Maker_ComboEnumType, 0, 0, 0, 0)
  TextGadget(#GADGET_Maker_LabelSubType, 0, 0, 0, 0, Language("Maker", "Type") + ":")
  ComboBoxGadget(#GADGET_Maker_ComboSubType, 0, 0, 0, 0)
  ListIconGadget(#GADGET_Maker_ListSelectEnum, 0, 0, 0, 0, Language("Maker", "Value") + " (^E)", 100, 
                 #PB_ListIcon_CheckBoxes | #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  EditorGadget(#GADGET_Maker_EditAdHocEnum, 0, 0, 0, 0)
  
  ; Template tab.
  AddGadgetItem(#GADGET_Maker_Panel, #MAKER_TAB_Template, Language("Maker", "Template"))
  TextGadget(#GADGET_Maker_LabelTemplate, 0, 0, 0, 0, Language("Maker", "Template") + ":")
  ComboBoxGadget(#GADGET_Maker_ComboTemplate, 0, 0, 0, 0)
  EditorGadget(#GADGET_Maker_EditTemplate, 0, 0, 0, 0)
  
  ; Code tab.
  AddGadgetItem(#GADGET_Maker_Panel, #MAKER_TAB_Code, Language("Maker", "Code"))
  EditorGadget(#GADGET_Maker_ResultCode, 0, 0, 0, 0, #PB_Editor_ReadOnly)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
  	; Default tab width on windows is too large.
  	Width = 5 
  	SendMessage_(GadgetID(#GADGET_Maker_ResultCode), #EM_SETTABSTOPS, 1, @Width)
	CompilerEndIf

  CloseGadgetList()
  
  ; Buttons
  Icon = ToolbarMenuImage(#MENU_RestartCompiler)
  ButtonImageGadget(#GADGET_Maker_ButtonRefresh, 0, 0, 0, 0, Icon)
  GadgetToolTip(#GADGET_Maker_ButtonRefresh, Language("Maker", "TipRefresh"))
  
  Icon = ToolbarMenuImage(#MENU_Copy)
  ButtonImageGadget(#GADGET_Maker_ButtonCopy, 0, 0, 0, 0, Icon)
  GadgetToolTip(#GADGET_Maker_ButtonCopy, Language("Maker", "TipCopy"))
  
  Icon = ToolbarMenuImage(#MENU_Paste)
  ButtonImageGadget(#GADGET_Maker_ButtonPaste, 0, 0, 0, 0, Icon)
  GadgetToolTip(#GADGET_Maker_ButtonPaste, Language("Maker", "TipPaste"))
  
  Icon = ToolbarMenuImage(#MENU_Kill)
  ButtonImageGadget(#GADGET_Maker_ButtonClear, 0, 0, 0, 0, Icon)
  GadgetToolTip(#GADGET_Maker_ButtonClear, Language("Maker", "TipClear"))
  
  ; Else
  ; EndIf
  
  If *Entry\IsSeparateWindow = 0 Or NoIndependentToolsColors = 0
    ToolsPanel_ApplyColors(#GADGET_Maker_ListSelectEnum)
    ToolsPanel_ApplyColors(#GADGET_Maker_EditAdHocEnum)
    ToolsPanel_ApplyColors(#GADGET_Maker_EditTemplate)
    ToolsPanel_ApplyColors(#GADGET_Maker_ResultCode)
  EndIf
  
  ; Create items for ComboMakeType.
  Index = 0
  AddGadgetItem(#GADGET_Maker_ComboMakeType, Index, Language("Maker", "MakeIf"))
  SetGadgetItemData(#GADGET_Maker_ComboMakeType, Index, #MAKER_MAKE_If)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboMakeType, Index, Language("Maker", "MakeSelect"))
  SetGadgetItemData(#GADGET_Maker_ComboMakeType, Index, #MAKER_MAKE_Select)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboMakeType, Index, Language("Maker", "MakeProcedure"))
  SetGadgetItemData(#GADGET_Maker_ComboMakeType, Index, #MAKER_MAKE_ProcedureSkeleton)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboMakeType, Index, Language("Maker", "MakeAdHoc"))
  SetGadgetItemData(#GADGET_Maker_ComboMakeType, Index, #MAKER_MAKE_TemplateOnly)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboMakeType, Index, Language("Maker", "MakeTidy"))
  SetGadgetItemData(#GADGET_Maker_ComboMakeType, Index, #MAKER_MAKE_TidyOnly)
  
  ; Create items for ComboEnumType.
  Index = 0
  AddGadgetItem(#GADGET_Maker_ComboEnumType, Index, Language("Maker", "EnumWindow"))
  SetGadgetItemData(#GADGET_Maker_ComboEnumType, Index, #MAKER_ENUM_WindowEvents)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboEnumType, Index, Language("Maker", "EnumGadget"))
  SetGadgetItemData(#GADGET_Maker_ComboEnumType, Index, #MAKER_ENUM_GadgetEvents)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboEnumType, Index, Language("ToolsPanel", "VariableViewerLong"))
  SetGadgetItemData(#GADGET_Maker_ComboEnumType, Index, #MAKER_ENUM_VariableViewer)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboEnumType, Index, Language("Maker", "AdHoc"))
  SetGadgetItemData(#GADGET_Maker_ComboEnumType, Index, #MAKER_ENUM_AdHoc)
  
  ; Disable ComboSubType.
  Maker_DisableSubType(#True)
  
  ; Create items for ComboTemplate.
  Index = 0
  AddGadgetItem(#GADGET_Maker_ComboTemplate, Index, Language("Maker", "None") )
  SetGadgetItemData(#GADGET_Maker_ComboTemplate, Index, #MAKER_TEMPLATE_None)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboTemplate, Index, Language("Maker", "TemplateTool"))
  SetGadgetItemData(#GADGET_Maker_ComboTemplate, Index, #MAKER_TEMPLATE_FromTool)
  Index + 1
  AddGadgetItem(#GADGET_Maker_ComboTemplate, Index, Language("Maker", "AdHoc"))
  SetGadgetItemData(#GADGET_Maker_ComboTemplate, Index, #MAKER_TEMPLATE_AdHoc)
  
  SetGadgetState(#GADGET_Maker_ComboTemplate, 0)
  
  ; Update gadgets.
  Maker_ChangeMakeType(#MAKER_MAKE_If)
  Maker_ChangeEnumType(#MAKER_ENUM_WindowEvents)
  Maker_ChangeSubType()
  Maker_ChangeTemplateType(#MAKER_TEMPLATE_None)
  
  *Entry\CurrentOptions = 0
  *Entry\CurrentTidy = 0
  *Entry\IsEnabled = 1
  
EndProcedure

Procedure Maker_DestroyFunction(*Entry.MakerToolData)
  ; Tidy up.
  
  *Entry\IsEnabled = 0
  
  ClearList(MakerEnumList())
  *Entry\AdHocEnum$ = #Empty$
  *Entry\AdHocTemplate$ = #Empty$
  *Entry\Param1$ = #Empty$
  *Entry\Param2$ = #Empty$
  *Entry\Param3$ = #Empty$
  *Entry\CurrentOptions = 0
  *Entry\CurrentTidy = 0
  
  FreeGadget(#GADGET_Maker_FrameMake)
  FreeGadget(#GADGET_Maker_ComboMakeType)
  FreeGadget(#GADGET_Maker_FrameParam)
  FreeGadget(#GADGET_Maker_LabelParam1)
  FreeGadget(#GADGET_Maker_StringParam1)
  FreeGadget(#GADGET_Maker_LabelParam2)
  FreeGadget(#GADGET_Maker_StringParam2)
  FreeGadget(#GADGET_Maker_LabelParam3)
  FreeGadget(#GADGET_Maker_StringParam3)
  FreeGadget(#GADGET_Maker_FrameOption)
  FreeGadget(#GADGET_Maker_CheckOptional)
  FreeGadget(#GADGET_Maker_CheckDebug)
  FreeGadget(#GADGET_Maker_CheckToDo)
  FreeGadget(#GADGET_Maker_FrameTidy)
  FreeGadget(#GADGET_Maker_CheckSemiColon)
  FreeGadget(#GADGET_Maker_CheckEquals)
  FreeGadget(#GADGET_Maker_CheckColon)
  FreeGadget(#GADGET_Maker_CheckType)
  FreeGadget(#GADGET_Maker_LabelEnumType)
  FreeGadget(#GADGET_Maker_ComboEnumType)
  FreeGadget(#GADGET_Maker_LabelSubType)
  FreeGadget(#GADGET_Maker_ComboSubType)
  FreeGadget(#GADGET_Maker_LabelTemplate)
  FreeGadget(#GADGET_Maker_ComboTemplate)
  FreeGadget(#GADGET_Maker_ListSelectEnum)
  FreeGadget(#GADGET_Maker_EditAdHocEnum)
  FreeGadget(#GADGET_Maker_EditTemplate)
  FreeGadget(#GADGET_Maker_ResultCode)
  FreeGadget(#GADGET_Maker_ButtonRefresh)
  FreeGadget(#GADGET_Maker_ButtonClear)
  FreeGadget(#GADGET_Maker_ButtonCopy)
  FreeGadget(#GADGET_Maker_Panel)
  
EndProcedure

Procedure Maker_EventHandler(*Entry.MakerToolData, EventGadgetID)
  ; Update state variables and despatch UI events to the right procedure.
  
  Define Index
  
  Select EventGadgetID
      
      ; Panel tabs.
    Case #GADGET_Maker_Panel
      If EventType() = #PB_EventType_Change
        *Maker\CurrentPanelTab = GetGadgetState(#GADGET_Maker_Panel)
        Select *Maker\CurrentPanelTab
            
          Case #MAKER_TAB_Enum
            If *Entry\CurrentEnumType = #MAKER_ENUM_AdHoc
              SetActiveGadget(#GADGET_Maker_EditAdHocEnum)
            Else
              SetActiveGadget(#GADGET_Maker_ListSelectEnum)
            EndIf
            
          Case #MAKER_TAB_Template
            If *Entry\CurrentTemplateType = #MAKER_TEMPLATE_AdHoc
              SetActiveGadget(#GADGET_Maker_EditTemplate)
            EndIf
            
          Case #MAKER_TAB_Code
            If *Maker\IsCurrent = #False
              Maker_UpdateCode()
            EndIf
        EndSelect 
        
      EndIf
      
      ; Make tab gadgets.
    Case #GADGET_Maker_ComboMakeType
      If EventType() = #PB_EventType_Change
        *Maker\IsCurrent = #False
        Index = GetGadgetState(#GADGET_Maker_ComboMakeType)
        If Index <> -1
          *Entry\CurrentMakeType = GetGadgetItemData(#GADGET_Maker_ComboMakeType, Index)
        EndIf
        Maker_ChangeMakeType()
      EndIf
      
    Case #GADGET_Maker_StringParam1, #GADGET_Maker_StringParam2, #GADGET_Maker_StringParam3
      *Maker\CurrentGadget = EventGadgetID
      If EventType() = #PB_EventType_Change
        *Maker\IsCurrent = #False
      EndIf
      
    Case #GADGET_Maker_CheckOptional, #GADGET_Maker_CheckDebug, #GADGET_Maker_CheckToDo
      *Maker\IsCurrent = #False
      *Maker\CurrentOptions = 0
      If GetGadgetState(#GADGET_Maker_CheckOptional) = #PB_Checkbox_Checked
        *Maker\CurrentOptions | #MAKER_OPTION_IncludeOptional
      EndIf
      If GetGadgetState(#GADGET_Maker_CheckDebug) = #PB_Checkbox_Checked
        *Maker\CurrentOptions | #MAKER_OPTION_IncludeDebug
      EndIf
      If GetGadgetState(#GADGET_Maker_CheckToDo) = #PB_Checkbox_Checked
        *Maker\CurrentOptions | #MAKER_OPTION_IncludeToDo
      EndIf
      
    Case #GADGET_Maker_CheckType, #GADGET_Maker_CheckSemiColon, #GADGET_Maker_CheckEquals, #GADGET_Maker_CheckColon
      *Maker\IsCurrent = #False
      *Maker\CurrentTidy = 0
      If GetGadgetState(#GADGET_Maker_CheckType) = #PB_Checkbox_Checked
        *Maker\CurrentTidy | #MAKER_TIDY_TruncateType
      EndIf
      If GetGadgetState(#GADGET_Maker_CheckSemiColon) = #PB_Checkbox_Checked
        *Maker\CurrentTidy | #MAKER_TIDY_TruncateSemiColon
      EndIf
      If GetGadgetState(#GADGET_Maker_CheckEquals) = #PB_Checkbox_Checked
        *Maker\CurrentTidy | #MAKER_TIDY_TruncateEquals
      EndIf
      If GetGadgetState(#GADGET_Maker_CheckColon) = #PB_Checkbox_Checked
        *Maker\CurrentTidy | #MAKER_TIDY_TruncateColon
      EndIf
      
      ; Enumeration tab gadgets.
    Case #GADGET_Maker_ComboEnumType
      If EventType() = #PB_EventType_Change
        *Maker\IsCurrent = #False
        Index = GetGadgetState(#GADGET_Maker_ComboEnumType)
        If Index <> -1
          *Entry\CurrentEnumType = GetGadgetItemData(#GADGET_Maker_ComboEnumType, Index)
        EndIf
        Maker_ChangeEnumType()
        
        Select #GADGET_Maker_ComboEnumType
          Case #MAKER_ENUM_GadgetEvents
            Maker_ChangeSubType()
        EndSelect
        SetGadgetText(#GADGET_Maker_ResultCode, #Empty$)
      EndIf
      
    Case #GADGET_Maker_ComboSubType
      *Maker\IsCurrent = #False
      Index = GetGadgetState(#GADGET_Maker_ComboSubType)
      If Index <> -1
        *Entry\CurrentSubType = GetGadgetItemData(#GADGET_Maker_ComboSubType, Index)
      EndIf
      Maker_ChangeSubType()
      SetGadgetText(#GADGET_Maker_ResultCode, #Empty$)
      
    Case #GADGET_Maker_EditAdHocEnum
      *Maker\IsCurrent = #False
      *Maker\CurrentGadget = EventGadgetID
      
    Case #GADGET_Maker_ListSelectEnum
      If EventType() = #PB_EventType_LeftClick
        *Maker\IsCurrent = #False
      EndIf
      
      ; Template tab gadgets.  
    Case #GADGET_Maker_ComboTemplate
      *Maker\IsCurrent = #False
      Index = GetGadgetState(#GADGET_Maker_ComboTemplate)
      If Index <> -1
        *Entry\CurrentTemplateType = GetGadgetItemData(#GADGET_Maker_ComboTemplate, Index)
      EndIf
      Maker_ChangeTemplateType()
      SetGadgetText(#GADGET_Maker_ResultCode, #Empty$)
      
    Case #GADGET_Maker_EditTemplate
      *Maker\IsCurrent = #False
      *Maker\CurrentGadget = EventGadgetID
      
      ; Buttons.
    Case #GADGET_Maker_ButtonRefresh
      Select GetGadgetState(#GADGET_Maker_Panel)
          
          ; Case #MAKER_TAB_Make
          ; Nothing required here currently.
          
        Case #MAKER_TAB_Enum
          If *Maker\CurrentEnumType = #MAKER_ENUM_VariableViewer
            Maker_GetVariableViewer()
          EndIf
          
        Case #MAKER_TAB_Template
          If *Maker\CurrentTemplateType = #MAKER_TEMPLATE_FromTool
            Maker_GetTemplate()
          EndIf
          
        Case #MAKER_TAB_Code
          Maker_UpdateCode()
          
      EndSelect  
      
    Case #GADGET_Maker_ButtonCopy
      If *Maker\IsCurrent = #False
        Maker_UpdateCode()
      EndIf
      SetClipboardText(GetGadgetText(#GADGET_Maker_ResultCode))
      
    Case #GADGET_Maker_ButtonPaste
      Maker_PasteButton()
      
    Case #GADGET_Maker_ButtonClear
      Maker_ClearAll()
      
  EndSelect
  
EndProcedure

Procedure Maker_ResizeHandler(*Entry.MakerToolData, PanelWidth, PanelHeight)
  ; Resize gadgets after a tool panel or window resize.
  
  Define DfltHeight = 25, FrameTop = 20, X, Y, Space, TabWidth, TabHeight
  Define.l Width, Height
  
  CompilerIf #CompileWindows
    Space = 5
  CompilerElse
    Space = 8 ; looks better on Linux/OSX with some more space
  CompilerEndIf
  
  ; Currently uses the same layout in both configurations.
  ; If *Entry\IsSeparateWindow
  
  ; Buttons.
  GetRequiredSize(#GADGET_Maker_ButtonRefresh, @Width, @Height)
  
  X = Space
  Y = PanelHeight - (Height + Space)
  ResizeGadget(#GADGET_Maker_ButtonRefresh, X, Y, Width, Height)
  
  X + (GadgetWidth(#GADGET_Maker_ButtonRefresh) + Space)
  ResizeGadget(#GADGET_Maker_ButtonCopy, X, Y, Width, Height)
  
  X + (GadgetWidth(#GADGET_Maker_ButtonCopy) + Space)
  ResizeGadget(#GADGET_Maker_ButtonPaste, X, Y, Width, Height)
  
  X + (GadgetWidth(#GADGET_Maker_ButtonCopy) + Space * 4)
  ResizeGadget(#GADGET_Maker_ButtonClear, X, Y, Width, Height)
  
  ; Tab panel
  Width = PanelWidth - (Space * 2)
  Height = PanelHeight - (GadgetHeight(#GADGET_Maker_ButtonRefresh) + Space * 3)
  ResizeGadget(#GADGET_Maker_Panel, Space, Space, Width, Height)
  
  TabWidth = GetGadgetAttribute(#GADGET_Maker_Panel, #PB_Panel_ItemWidth)
  TabHeight = GetGadgetAttribute(#GADGET_Maker_Panel, #PB_Panel_ItemHeight)
  
  ; Make tab.
  ; Make frame.
  Height = 25 + (Space * 6)
  Width = TabWidth - (Space * 2)
  ResizeGadget(#GADGET_Maker_FrameMake, Space, Space, Width, Height)
  Y = GadgetY(#GADGET_Maker_FrameMake) + FrameTop
  Width = GadgetWidth(#GADGET_Maker_FrameMake) - (Space * 2)
  Height = 25
  ResizeGadget(#GADGET_Maker_ComboMakeType, Space * 2, Y, Width, Height)
  
  ; Parameter frame.
  Y = GadgetY(#GADGET_Maker_FrameMake) + GadgetHeight(#GADGET_Maker_FrameMake) + Space
  Width = TabWidth - (Space * 2)
  Height = (DfltHeight * 3) + (Space * 9)
  ResizeGadget(#GADGET_Maker_FrameParam, Space, Y, Width, Height)
  
  ; Parameter gadgets.
  Y = GadgetY(#GADGET_Maker_FrameParam) + FrameTop
  ResizeGadget(#GADGET_Maker_LabelParam1, Space * 2, Y, *Maker\MaxW, DfltHeight)
  
  X = GadgetX(#GADGET_Maker_FrameParam) + (GadgetWidth(#GADGET_Maker_LabelParam1) + (3 * Space))
  Width = GadgetWidth(#GADGET_Maker_FrameParam) - (GadgetWidth(#GADGET_Maker_LabelParam1) + (4 * Space))
  ResizeGadget(#GADGET_Maker_StringParam1, X, Y, Width, DfltHeight)
  
  Y + (GadgetHeight(#GADGET_Maker_LabelParam1) + Space)
  ResizeGadget(#GADGET_Maker_LabelParam2, Space * 2, Y, *Maker\MaxW, DfltHeight)
  ResizeGadget(#GADGET_Maker_StringParam2, X, Y, Width, DfltHeight)
  
  Y + (GadgetHeight(#GADGET_Maker_LabelParam2) + Space)
  ResizeGadget(#GADGET_Maker_LabelParam3, Space * 2, Y, *Maker\MaxW, DfltHeight)
  ResizeGadget(#GADGET_Maker_StringParam3, X, Y, Width, DfltHeight)
  
  ; Options frame.
  Y = GadgetY(#GADGET_Maker_FrameParam) + GadgetHeight(#GADGET_Maker_FrameParam) + Space
  Width = TabWidth - (Space * 2)
  Height = (DfltHeight * 3) + (Space * 6)
  ResizeGadget(#GADGET_Maker_FrameOption, Space, Y, Width, Height)
  
  ; Options gadgets.
  X = Space * 2
  Y = GadgetY(#GADGET_Maker_FrameOption) + FrameTop
  Width = GadgetWidth(#GADGET_Maker_FrameOption) - (Space * 2)
  ResizeGadget(#GADGET_Maker_CheckOptional, X, Y, Width, DfltHeight)
  
  Y + DfltHeight
  ResizeGadget(#GADGET_Maker_CheckDebug, X, Y, Width, DfltHeight)
  
  Y + DfltHeight
  ResizeGadget(#GADGET_Maker_CheckToDo, X, Y, Width, DfltHeight)
  
  ; Tidy frame
  Y = GadgetY(#GADGET_Maker_FrameOption) + GadgetHeight(#GADGET_Maker_FrameOption) + Space
  Width = TabWidth - (Space * 2)
  Height = (DfltHeight * 4) + (Space * 6)
  ResizeGadget(#GADGET_Maker_FrameTidy, Space, Y, Width, Height)
  
  ; Tidy items.
  X = Space * 2
  Y = GadgetY(#GADGET_Maker_FrameTidy) + FrameTop
  Width = GadgetWidth(#GADGET_Maker_FrameTidy) - (Space * 2)
  ResizeGadget(#GADGET_Maker_CheckType, X, Y, Width, DfltHeight)
  
  Y + DfltHeight
  ResizeGadget(#GADGET_Maker_CheckSemiColon, X, Y, Width, DfltHeight)
  
  Y + DfltHeight
  ResizeGadget(#GADGET_Maker_CheckEquals, X, Y, Width, DfltHeight)
  
  Y + DfltHeight
  ResizeGadget(#GADGET_Maker_CheckColon, X, Y, Width, DfltHeight)
  
  ; Enumeration tab.
  ResizeGadget(#GADGET_Maker_LabelEnumType, Space, Space, GadgetWidth(#GADGET_Maker_LabelEnumType, #PB_Gadget_RequiredSize), DfltHeight)
  
  X = GadgetX(#GADGET_Maker_LabelEnumType) + GadgetWidth(#GADGET_Maker_LabelEnumType) + Space
  Width = TabWidth - (X + Space)
  ResizeGadget(#GADGET_Maker_ComboEnumType, X, Space, Width, DfltHeight)
  
  Y = GadgetY(#GADGET_Maker_LabelEnumType) + GadgetHeight(#GADGET_Maker_LabelEnumType) + Space
  ResizeGadget(#GADGET_Maker_LabelSubType, Space, Y, *Maker\MaxW, DfltHeight)
  ResizeGadget(#GADGET_Maker_ComboSubType, X, Y, Width, DfltHeight)
  
  Y = GadgetY(#GADGET_Maker_LabelSubType) + GadgetHeight(#GADGET_Maker_LabelSubType) + Space
  Width = TabWidth - (2 * Space)
  Height = TabHeight - (GadgetHeight(#GADGET_Maker_LabelEnumType) + GadgetHeight(#GADGET_Maker_LabelSubType) + (4 * Space))
  ResizeGadget(#GADGET_Maker_ListSelectEnum, Space, Y, Width, Height)
  SetGadgetItemAttribute(#GADGET_Maker_ListSelectEnum, 1, #PB_ListIcon_ColumnWidth, Int(Width * 0.9))
  ResizeGadget(#GADGET_Maker_EditAdHocEnum, Space, Y, Width, Height)
  
  ; Template tab.
  Width = GadgetWidth(#GADGET_Maker_LabelTemplate, #PB_Gadget_RequiredSize)
  ResizeGadget(#GADGET_Maker_LabelTemplate, Space, Space, Width, DfltHeight)
  
  X = GadgetX(#GADGET_Maker_LabelTemplate) + GadgetWidth(#GADGET_Maker_LabelTemplate) + (2 * Space)
  Width = TabWidth - (X + Space)
  ResizeGadget(#GADGET_Maker_ComboTemplate, X, Space, Width, DfltHeight)
  
  Y = GadgetY(#GADGET_Maker_LabelTemplate) + GadgetHeight(#GADGET_Maker_LabelTemplate) + Space
  Width = TabWidth - (2 * Space)
  Height = TabHeight - (GadgetY(#GADGET_Maker_LabelTemplate) + GadgetHeight(#GADGET_Maker_LabelTemplate) + 2 * Space)
  ResizeGadget(#GADGET_Maker_EditTemplate, Space, Y, Width, Height)
  
  ; Code tab.
  Width = TabWidth - (2 * Space)
  Height = TabHeight - (2 * Space)
  ResizeGadget(#GADGET_Maker_ResultCode, Space, Space, Width, Height)
  
  ; Else
  ; EndIf
  
EndProcedure

Procedure Maker_ChangeEnumType(Force.i = #PB_Ignore)
  ; Updates the ComboSubType and ListSelectEnum gadgets based on the selection in ComboEnumType. 
  ; Uses the Form Designer's reference lists for window and gadget events, see 'declare.pb'.
  
  Define i, Max, Mark
  
  ; Force a selection if specified.
  If Force <> #PB_Ignore
    
    For i = 0 To CountGadgetItems(#GADGET_Maker_ComboEnumType)
      If GetGadgetItemData(#GADGET_Maker_ComboEnumType, i) = Force
        *Maker\CurrentEnumType = Force
        SetGadgetState(#GADGET_Maker_ComboEnumType, i)
        Break
      EndIf
    Next i
    
  EndIf
  
  ; Update the other gadgets accordingly.
  Select *Maker\CurrentEnumType
      
    Case -1
      ; Nothing selected.
      Maker_DisableTidy(#True, #True, #True, #True)
      Maker_DisableSubType(#True)
      Maker_SwitchEnum(#GADGET_Maker_ListSelectEnum)
      ClearGadgetItems(#GADGET_Maker_ListSelectEnum)
      
    Case #MAKER_ENUM_WindowEvents
      Maker_DisableTidy(#True, #True, #True, #True)
      Maker_DisableSubType(#True)
      Maker_SwitchEnum(#GADGET_Maker_ListSelectEnum)
      
      ; Find the window item and load the event list.
      PushListPosition(Gadgets())
      
      ForEach Gadgets()
        If Gadgets()\type = #Form_Type_Window
          
          ClearGadgetItems(#GADGET_Maker_ListSelectEnum)  
          ForEach Gadgets()\Events()
            AddGadgetItem(#GADGET_Maker_ListSelectEnum, ListIndex(Gadgets()\Events()), Gadgets()\Events()\name)
          Next Gadgets()\Events()
          Break
          
        EndIf
      Next Gadgets()
      
      PopListPosition(Gadgets())
      
    Case #MAKER_ENUM_GadgetEvents
      Maker_DisableTidy(#True, #True, #True, #True)
      Maker_DisableSubType(#False, Language("Maker", "TypeGadget"))
      Maker_SwitchEnum(#GADGET_Maker_ListSelectEnum)
      
      ; Load gadget items into the combo.
      ClearGadgetItems(#GADGET_Maker_ComboSubType)
      i = 0
      
      PushListPosition(Gadgets())
      
      ForEach Gadgets()
        
        ; Skip unneeded components.
        If Gadgets()\type = #Form_Type_Window 
          ; Don't include window.
          Continue
          
        ElseIf ListSize(Gadgets()\Events()) = 0
          ; Don't include gadgets having no EventType() values.
          Continue
          
        ElseIf Gadgets()\type = #Form_Type_Toolbar
          ; Everything from Toolbar onwards is irrelevant.
          Break          
          
        EndIf
        
        ; Add gadget to the combo.
        AddGadgetItem(#GADGET_Maker_ComboSubType, i, Gadgets()\name)
        SetGadgetItemData(#GADGET_Maker_ComboSubType, i, Gadgets()\type)
        i + 1
        
      Next Gadgets()
      SetGadgetState(#GADGET_Maker_ComboSubType, 0)
      *Maker\CurrentSubType = GetGadgetItemData(#GADGET_Maker_ComboSubType, 0)
      Maker_ChangeSubType()
      
      PopListPosition(Gadgets())
      
    Case #MAKER_ENUM_VariableViewer
      Maker_DisableTidy(#True, #True, #True, #True)
      Maker_DisableSubType(#True)
      Maker_SwitchEnum(#GADGET_Maker_ListSelectEnum)
      Maker_GetVariableViewer()
      
    Case #MAKER_ENUM_AdHoc
      Maker_DisableTidy(#False, #False, #False, #False)
      Maker_DisableSubType(#True)
      Maker_SwitchEnum(#GADGET_Maker_EditAdHocEnum)
      SetActiveGadget(#GADGET_Maker_EditAdHocEnum)
      
  EndSelect
  
EndProcedure

Procedure Maker_ChangeMakeType(Force.i = #PB_Ignore)
  ; Update the UI after a ComboMakeType change.
  
  Define i
  
  ; Force a selection if specified.
  If Force <> #PB_Ignore
    
    For i = 0 To CountGadgetItems(#GADGET_Maker_ComboMakeType)
      If GetGadgetItemData(#GADGET_Maker_ComboMakeType, i) = Force
        SetGadgetState(#GADGET_Maker_ComboMakeType, i)
        *Maker\CurrentMakeType = Force
        Break
      EndIf
    Next i
    
  EndIf
  
  ; Update the other gadgets accordingly.
  Select *Maker\CurrentMakeType
      
    Case #MAKER_MAKE_If
      Maker_DisableOptions(#False, #False, #False)
      DisableGadget(#GADGET_Maker_ComboEnumType, #False)
      DisableGadget(#GADGET_Maker_EditTemplate, #False)
      Maker_UpdateLabels("P1If", "Custom", "Custom", "OptionIf")
      
    Case #MAKER_MAKE_Select
      Maker_DisableOptions(#False, #False, #False)
      DisableGadget(#GADGET_Maker_ComboEnumType, #False)
      Maker_UpdateLabels("P1If", "Custom", "Custom", "OptionSelect")
      
    Case #MAKER_MAKE_ProcedureSkeleton
      Maker_DisableOptions(#False, #False, #False)
      Maker_DisableTidy(#False, #False, #False, #False)
      Maker_DisableSubType(#True)
      Maker_SwitchEnum(#MAKER_ENUM_AdHoc)
      DisableGadget(#GADGET_Maker_EditTemplate, #True)
      Maker_ChangeEnumType(#MAKER_ENUM_AdHoc)
      Maker_ChangeTemplateType(#MAKER_TEMPLATE_None)
      Maker_UpdateLabels("P1Procedure", "P2Procedure", "Unused", "OptionProcedure")
      
    Case #MAKER_MAKE_TidyOnly
      Maker_DisableOptions(#True, #True, #True)
      Maker_DisableTidy(#False, #False, #False, #False)
      Maker_DisableSubType(#True)
      Maker_SwitchEnum(#MAKER_ENUM_AdHoc)
      Maker_ChangeTemplateType(#MAKER_TEMPLATE_None)
      Maker_UpdateLabels("Unused", "Unused", "Unused", "Unused")
      Maker_ChangeEnumType(#MAKER_ENUM_AdHoc)
      SetActiveGadget(#GADGET_Maker_EditAdHocEnum)
      
    Case #MAKER_MAKE_TemplateOnly
      Maker_SwitchEnum(#GADGET_Maker_ListSelectEnum)
      Maker_DisableOptions(#True, #True, #True)
      Maker_DisableTidy(#False, #False, #False, #False)
      Maker_DisableSubType(#True)
      DisableGadget(#GADGET_Maker_EditTemplate, #False)
      Maker_UpdateLabels("Custom", "Custom", "Custom", "Unused")
      Maker_ChangeTemplateType(#MAKER_TEMPLATE_AdHoc)
      
  EndSelect
  
EndProcedure

Procedure Maker_ChangeSubType(Force.i = #PB_Ignore)
  ; Load sub-type items to the list.
  
  Define i
  
  ; Force a selection if specified.
  If Force <> #PB_Ignore
    
    For i = 0 To CountGadgetItems(#GADGET_Maker_ComboSubType)
      If GetGadgetItemData(#GADGET_Maker_ComboSubType, i) = Force
        *Maker\CurrentSubType = Force
        SetGadgetState(#GADGET_Maker_ComboSubType, i)
        Break
      EndIf
    Next i
    
  Else
    *Maker\CurrentSubType = GetGadgetItemData(#GADGET_Maker_ComboSubType, 
                                              GetGadgetState(#GADGET_Maker_ComboSubType))
  EndIf
  
  If *Maker\CurrentSubType = -1
    ProcedureReturn
    
  ElseIf *Maker\CurrentEnumType = #MAKER_ENUM_GadgetEvents
    ; Load gadget events.
    PushListPosition(Gadgets())
    
    ; Find the right gadget.
    ForEach Gadgets()
      If Gadgets()\type = *Maker\CurrentSubType
        Break
      EndIf
    Next Gadgets()
    
    ClearGadgetItems(#GADGET_Maker_ListSelectEnum)
  
    ; Load the events to the list.
    ForEach Gadgets()\Events()
      AddGadgetItem(#GADGET_Maker_ListSelectEnum, ListIndex(Gadgets()\Events()), 
                    Gadgets()\Events()\name)
    Next Gadgets()\Events()
    
    PopListPosition(Gadgets())
    
  EndIf
  
EndProcedure

Procedure Maker_ChangeTemplateType(Force.i = #PB_Ignore)
  ; Update the template tab after a combo selection.
  
  Define i
  
  ; Force a selection if specified.
  If Force <> #PB_Ignore
    
    *Maker\CurrentTemplateType = Force
    
    For i = 0 To CountGadgetItems(#GADGET_Maker_ComboTemplate)
      If GetGadgetItemData(#GADGET_Maker_ComboTemplate, i) = Force
        SetGadgetState(#GADGET_Maker_ComboTemplate, i)
        Break
      EndIf
    Next i
    
  EndIf
  
  ; Update gadgets.
  Select *Maker\CurrentTemplateType
      
    Case #MAKER_TEMPLATE_None
      *Maker\AdHocTemplate$ = GetGadgetText(#GADGET_Maker_EditTemplate)
      SetGadgetText(#GADGET_Maker_EditTemplate, #Empty$)
      DisableGadget(#GADGET_Maker_EditTemplate, #True)
      
    Case #MAKER_TEMPLATE_FromTool
      ; Store current text as an ad-hoc template.
      *Maker\AdHocTemplate$ = GetGadgetText(#GADGET_Maker_EditTemplate)
      SetGadgetAttribute(#GADGET_Maker_EditTemplate, #PB_Editor_ReadOnly, 1)
      Maker_GetTemplate()
      
    Case #MAKER_TEMPLATE_AdHoc
      ; Load the ad-hoc template.
      ClearGadgetItems(#GADGET_Maker_EditTemplate)
      SetGadgetText(#GADGET_Maker_EditTemplate, *Maker\AdHocTemplate$)
      DisableGadget(#GADGET_Maker_EditTemplate, #False)
      SetGadgetAttribute(#GADGET_Maker_EditTemplate, #PB_Editor_ReadOnly, 0)
      SetActiveGadget(#GADGET_Maker_EditTemplate)
      
  EndSelect
  
EndProcedure

Procedure Maker_ClearAll()
  ; Reset gadgets and clear holding variables.
  
  SetGadgetText(#GADGET_Maker_StringParam1, #Empty$) 
  SetGadgetText(#GADGET_Maker_StringParam2, #Empty$) 
  SetGadgetText(#GADGET_Maker_StringParam3, #Empty$) 
  
  ClearGadgetItems(#GADGET_Maker_EditAdHocEnum)
  ClearGadgetItems(#GADGET_Maker_EditTemplate)
  ClearGadgetItems(#GADGET_Maker_ListSelectEnum)
  ClearGadgetItems(#GADGET_Maker_ResultCode)
  
  *Maker\AdHocEnum$ = #Empty$
  *Maker\AdHocTemplate$ = #Empty$
  *Maker\Param1$ = #Empty$
  *Maker\Param2$ = #Empty$
  *Maker\Param3$ = #Empty$
  
  ClearList(MakerEnumList())
  
EndProcedure

Procedure Maker_DisableOptions(Optional.b, Dbug.b, ToDo.b)
  ; Disable and clear option checkboxes, or enable them.
  ; Set parameters to #True or #False.
  
  DisableGadget(#GADGET_Maker_CheckOptional, Optional)
  If Optional = #True
    SetGadgetState(#GADGET_Maker_CheckOptional, #PB_Checkbox_Unchecked)
  EndIf
  
  DisableGadget(#GADGET_Maker_CheckDebug, Dbug)
  If Dbug = #True
    SetGadgetState(#GADGET_Maker_CheckDebug, #PB_Checkbox_Unchecked)
  EndIf
  
  DisableGadget(#GADGET_Maker_CheckToDo, ToDo)
  If ToDo = #True
    SetGadgetState(#GADGET_Maker_CheckToDo, #PB_Checkbox_Unchecked)
  EndIf
  
EndProcedure

Procedure Maker_DisableSubType(State.b, Label.s = #Empty$)
  ; Disable or enable ComboSubType and set the label.
  ; State - #True or #False
  ; Label - the key to the Language table item to display.
  
  If Label
    SetGadgetText(#GADGET_Maker_LabelSubType, Label + ":")
  EndIf
  
  HideGadget(#GADGET_Maker_LabelSubType, State)
  HideGadget(#GADGET_Maker_ComboSubType, State)
  DisableGadget(#GADGET_Maker_ComboSubType, State)
  
EndProcedure

Procedure Maker_DisableTidy(SemiColon.b, Equals.b, Colon.b, Type.b)
  ; Disable and clear tidy checkboxes, or enable them.
  ; Set parameters to #True or #False.
  
  DisableGadget(#GADGET_Maker_CheckSemiColon, SemiColon)
  If SemiColon = #True
    SetGadgetState(#GADGET_Maker_CheckSemiColon, #PB_Checkbox_Unchecked)
  EndIf
  
  DisableGadget(#GADGET_Maker_CheckEquals, Equals)
  If Equals = #True
    SetGadgetState(#GADGET_Maker_CheckEquals, #PB_Checkbox_Unchecked)
  EndIf
  
  DisableGadget(#GADGET_Maker_CheckColon, Colon)
  If Colon = #True
    SetGadgetState(#GADGET_Maker_CheckColon, #PB_Checkbox_Unchecked)
  EndIf
  
  DisableGadget(#GADGET_Maker_CheckType, Type)
  If Type = #True
    SetGadgetState(#GADGET_Maker_CheckType, #PB_Checkbox_Unchecked)
  EndIf
  
EndProcedure

Procedure Maker_GetEnumList(Gadget.i)
  ; Get enumeration items from the current gadget into MakerEnumList(),
  ; then perform any selected tidy actions.
  
  Define First, i, Max, Position
  Define Item$
  
  ClearList(MakerEnumList())
  
  Select Gadget
      
    Case #GADGET_Maker_ListSelectEnum
      Max = CountGadgetItems(#GADGET_Maker_ListSelectEnum) - 1
      
      For i = 0 To Max
        
        If (GetGadgetItemState(Gadget, i) & #PB_ListIcon_Checked)
          AddElement(MakerEnumList())
          Item$ = Trim(GetGadgetItemText(Gadget, i))
          MakerEnumList()\String$ = Item$
        EndIf
        
      Next i
      
    Case #GADGET_Maker_EditAdHocEnum
      Max = CountGadgetItems(#GADGET_Maker_EditAdHocEnum) - 1
      
      For i = 0 To Max
        
        Item$ = Trim(GetGadgetItemText(Gadget, i))
        If Item$
          AddElement(MakerEnumList())
          MakerEnumList()\String$ = Item$
        EndIf
        
      Next i
      
  EndSelect
  
  ForEach MakerEnumList()
    
    ; Truncate at colon.
    If (*Maker\CurrentTidy & #MAKER_TIDY_TruncateColon)
      Position = FindString(MakerEnumList()\String$, ":")
      If Position
        MakerEnumList()\String$ = Trim(Left(MakerEnumList()\String$, Position - 1))
      EndIf  
    EndIf
    
    ; Truncate at equals.
    If (*Maker\CurrentTidy & #MAKER_TIDY_TruncateEquals)
      Position = FindString(MakerEnumList()\String$, "=")
      If Position
        MakerEnumList()\String$ = Trim(Left(MakerEnumList()\String$, Position - 1))
      EndIf  
    EndIf
    
    ; Truncate at period.
    If (*Maker\CurrentTidy & #MAKER_TIDY_TruncateType)
      Position = FindString(MakerEnumList()\String$, ".")
      If Position
        MakerEnumList()\String$ = Trim(Left(MakerEnumList()\String$, Position - 1))
      EndIf  
    EndIf
    
    ; Truncate at semicolon.
    If (*Maker\CurrentTidy & #MAKER_TIDY_TruncateSemiColon)
      Position = FindString(MakerEnumList()\String$, ";")
      If Position 
        MakerEnumList()\String$ = Trim(Left(MakerEnumList()\String$, Position - 1))
      EndIf  
    EndIf
    
    ; Classify items.
    First = Asc(UCase(Left(MakerEnumList()\String$, 1)))
    
    If First = 34
      ; Double Quoted Alpha
      MakerEnumList()\Type = #MAKER_ITEMTYPE_Quoted
      
    ElseIf First = 35
      ; #Constant
      MakerEnumList()\Type = #MAKER_ITEMTYPE_Constant
      
    ElseIf First >= 65 And First <= 90 Or First >= 97 And First <= 122
      ; Unquoted Alpha
      MakerEnumList()\Type = #MAKER_ITEMTYPE_Unquoted
      
    ElseIf First >= 48 And First <= 57
      ; Numeric
      MakerEnumList()\Type = #MAKER_ITEMTYPE_Numeric
      
    EndIf
    
  Next MakerEnumList()
  
EndProcedure

Procedure Maker_GetTemplate()
  ; Load the selected template from the tool, or show a warning if it is inactive.
  
  Define TemplateIndex
  
  ClearGadgetItems(#GADGET_Maker_EditTemplate)
  
  If IsGadget(#GADGET_Template_Tree)
    ; Load the selected template.
    TemplateIndex = GetGadgetState(#GADGET_Template_Tree)
    If TemplateIndex <> -1
      SelectElement(Template(), TemplateIndex)
      SetGadgetText(#GADGET_Maker_EditTemplate, Template_Unescape(Template()\Code$))
    EndIf
    
  Else
    ; Tool is inactive.
    SetGadgetText(#GADGET_Maker_EditTemplate, Language("Maker", "ToolInactive"))
    
  EndIf
  
EndProcedure

Procedure Maker_GetVariableViewer()
  ; Load ListSelectEnum from the Variable Viewer list, or show a warning if it is inactive.
  
  Define i, Max
  
  ClearGadgetItems(#GADGET_Maker_ListSelectEnum)
  
  If *VariableViewer\IsEnabled And IsGadget(*VariableViewer\List)
    Max = CountGadgetItems(*VariableViewer\List)
    
    For i = 1 To Max
      If GetGadgetItemText(*VariableViewer\List, i) <> #Empty$
        AddGadgetItem(#GADGET_Maker_ListSelectEnum, i, GetGadgetItemText(*VariableViewer\List, i))
      EndIf
    Next i
    
  Else
    ; Variable viewer is inactive.
    AddGadgetItem(#GADGET_Maker_ListSelectEnum, 0, Language("Maker", "ToolInactive"))
    
  EndIf
  
EndProcedure

Procedure.s Maker_ReplacePlaceHolders(String$, Quotes.b = #False)
  ; Replace placeholders in String$ with real values.
  
  Define Replace$
  
  Replace$ = String$
  Replace$ = ReplaceString(Replace$, "^P1", *Maker\Param1$, #PB_String_NoCase)
  Replace$ = ReplaceString(Replace$, "^P2", *Maker\Param2$, #PB_String_NoCase)
  Replace$ = ReplaceString(Replace$, "^P3", *Maker\Param3$, #PB_String_NoCase)
  If ListIndex(MakerEnumList()) > -1
    
    If Quotes And MakerEnumList()\Type = #MAKER_ITEMTYPE_Unquoted
      Replace$ = ReplaceString(Replace$, "^E", #DQUOTE$ + MakerEnumList()\String$ + #DQUOTE$, #PB_String_NoCase)
    Else
      Replace$ = ReplaceString(Replace$, "^E", MakerEnumList()\String$, #PB_String_NoCase)
    EndIf
    
  EndIf
  
  ProcedureReturn Replace$
  
EndProcedure

Procedure Maker_MakeGeneral(Preamble$, First$, FirstIndent.b, Each$, EachIndent.b, Option$, OptionIndent.b, Last$, LastIndent.b)
  ; General purpose maker.
  
  ; Preamble$ - emitted before any list items, specify #Empty$ to omit.
  ; First$ - emitted on the first list item only, specify #Empty$ to omit.
  ; FirstIndent - indentation level for First$
  ; Each$ - emitted for each list item except the first, if specified.
  ; EachIndent - indentation level for Each$.
  ; Option$ - emitted after the list items.
  ; OptionIndent - indentation level for Option$.
  ; Last$ - emitted at the end.
  ; LastIndent - indentation level for Last$.
  
  Define.b First = #True
  Define i, j, MaxIndent = 3
  Define Line$
 
  ; Determine size of T$ needed and fill.
  If EachIndent + 1 > MaxIndent
    MaxIndent = EachIndent + 1
  EndIf
  If OptionIndent + 1 > MaxIndent
    MaxIndent = OptionIndent + 1
  EndIf
  If LastIndent + 1 > MaxIndent
    MaxIndent = LastIndent + 1
  EndIf
  
  Dim T$(MaxIndent)
  T$(0) = #Empty$
  For i = 1 To MaxIndent
    For j = 1 To i
      T$(i) + "^I"
    Next j
  Next i
  
  ; Add the opening.
  If Preamble$
    Line$ = Maker_ReplacePlaceHolders(Preamble$)
    AddElement(MakerOutput())
    MakerOutput() = Line$
    AddElement(MakerOutput())
  EndIf
  
  ; Add enumerated items.
  ForEach MakerEnumList()
    Line$ = #Empty$
    
    If ListIndex(MakerEnumList()) = 0 And First$
      Select MakerEnumList()\Type
          
        Case #MAKER_ITEMTYPE_Constant, #MAKER_ITEMTYPE_Numeric, #MAKER_ITEMTYPE_Quoted
          Line$ + T$(FirstIndent) + Maker_ReplacePlaceHolders(First$)
          
        Case #MAKER_ITEMTYPE_Unquoted
          Line$ + T$(FirstIndent) + Maker_ReplacePlaceHolders(First$, #True)
          
      EndSelect   
      
    Else
      Select MakerEnumList()\Type
          
        Case #MAKER_ITEMTYPE_Constant, #MAKER_ITEMTYPE_Numeric, #MAKER_ITEMTYPE_Quoted
          Line$ + T$(EachIndent) + Maker_ReplacePlaceHolders(Each$)
          
        Case #MAKER_ITEMTYPE_Unquoted
          Line$ + T$(EachIndent) + Maker_ReplacePlaceHolders(Each$, #True)
          
      EndSelect   
      
    EndIf
    AddElement(MakerOutput())
    MakerOutput() = Line$
  
    ; Add debug information, if specified.
    If (*Maker\CurrentOptions & #MAKER_OPTION_IncludeDebug)
      AddElement(MakerOutput())
      If First And First$
        MakerOutput() = T$(FirstIndent + 1)
      Else
        MakerOutput() = T$(EachIndent + 1) 
      EndIf
      MakerOutput() + #MAKER_Prefix_Debug + #DQUOTE$ + "- " + Trim(MakerEnumList()\String$, #DQUOTE$) + #DQUOTE$
    EndIf
    
    ; Add to-do information, if specified.
    If (*Maker\CurrentOptions & #MAKER_OPTION_IncludeToDo)
      AddElement(MakerOutput())
      If First
        MakerOutput() = T$(FirstIndent + 1)
      Else
        MakerOutput() = T$(EachIndent + 1) 
      EndIf
      MakerOutput() + #MAKER_Prefix_ToDo + #DQUOTE$ + Trim(MakerEnumList()\String$, #DQUOTE$) + #DQUOTE$
    EndIf
    
    ; Add template.
    If *Maker\CurrentTemplateType <> #MAKER_TEMPLATE_None And GetGadgetText(#GADGET_Maker_EditTemplate) <> #Empty$
      AddElement(MakerOutput())
      MakerOutput() = Maker_ReplacePlaceHolders(GetGadgetText(#GADGET_Maker_EditTemplate))
    EndIf
    
    ; Add blank line.
    AddElement(MakerOutput())
    
    First = #False
    
  Next MakerEnumList()
  
  ; Add optional item, if specified.
  If *Maker\CurrentOptions & #MAKER_OPTION_IncludeOptional
    AddElement(MakerOutput())
    MakerOutput() = T$(OptionIndent) + Maker_ReplacePlaceHolders(Option$)
    
    If (*Maker\CurrentOptions & #MAKER_OPTION_IncludeDebug)
      AddElement(MakerOutput())
      MakerOutput() = T$(OptionIndent + 1) + #MAKER_Prefix_Debug + #DQUOTE$ + "- " + Option$ + #DQUOTE$
    EndIf
    
    AddElement(MakerOutput())
  EndIf
  
  ; Add the closure, if specified.
  If Last$  
    AddElement(MakerOutput())
    MakerOutput() = T$(LastIndent) + Maker_ReplacePlaceHolders(Last$)
  EndIf
  
EndProcedure

Procedure Maker_MakeProcedure()
  ; Make a Procedure...EndProcedure block.
  
  Define Name$
  Dim T$(2)
  NewList Decs.S()
  NewList Procs.S()
  
  ; Set indentation.
  If *Maker\Param1$
    T$(1) = "^I"
    T$(2) = "^I^I"
  Else
    T$(1) = ""
    T$(2) = "^I"
  EndIf
    
  ForEach MakerEnumList()
    
    If MakerEnumList()\String$ = #Empty$
      Continue
    EndIf
    
    Name$ = Trim(*Maker\Param2$) + MakerEnumList()\String$
    
    ; If making from Window or Gadget events, remove constant prefixes.
    If *Maker\CurrentEnumType = #MAKER_ENUM_WindowEvents
      Name$ = ReplaceString(Name$, "#PB_Event_", #Empty$)
    ElseIf *Maker\CurrentEnumType = #MAKER_ENUM_GadgetEvents
      Name$ = ReplaceString(Name$, "#PB_EventType_", #Empty$)
    EndIf
    
    ; Add parentheses if missing.
    If Mid(Name$, Len(Name$) - 1, 1) = "(" And Right(Name$, 1) <> ")" 
      Name$ + ")"
    ElseIf FindString(Name$, "(") = 0 And FindString(Name$, ")") = 0
      Name$ + "()"
    EndIf
    
    ; Declaration.
    If *Maker\CurrentOptions & #MAKER_OPTION_IncludeOptional
      AddElement(Decs())
      Decs() = T$(1) + "Declare " + Name$
    EndIf
    
    ; Procedure.
    AddElement(Procs())
    Procs() = T$(1) + "Procedure " + Name$
    
    ; Debug entry, if requested.
    If (*Maker\CurrentOptions & #MAKER_OPTION_IncludeDebug)
      AddElement(Procs())
      Procs() = T$(2) + #MAKER_Prefix_Debug + #DQUOTE$ + Language("Maker", "DebugEntered") + #DQUOTE$ + " + #PB_Compiler_Procedure + " + #DQUOTE$ + "." + #DQUOTE$
    EndIf
    
    ; To Do item, or a blank line.
    If (*Maker\CurrentOptions & #MAKER_OPTION_IncludeToDo)
      AddElement(Procs())
      Procs() = T$(2) + #MAKER_Prefix_ToDo + Language("Maker", "ToDoImplement") + " " + Name$ + "."
      AddElement(Procs())
      Procs() = #Empty$
    Else
      AddElement(Procs())
      Procs() = #Empty$
    EndIf
    
    ; Debug exit, if requested.
    If (*Maker\CurrentOptions & #MAKER_OPTION_IncludeDebug)
      AddElement(Procs())
      Procs() = T$(2) + #MAKER_Prefix_Debug + #DQUOTE$ + Language("Maker", "DebugExited") + #DQUOTE$ + " + #PB_Compiler_Procedure + " + #DQUOTE$ + "." + #DQUOTE$
    EndIf
    
    AddElement(Procs())
    Procs() = T$(1) + "EndProcedure"
    AddElement(Procs())
    Procs() = #Empty$
    
  Next MakerEnumList()
  
  ; Build output.
  If *Maker\CurrentOptions & #MAKER_OPTION_IncludeOptional
    
    ; DecMod section.
    If *Maker\Param1$
      AddElement(MakerOutput())
      MakerOutput() = "DeclareModule " + *Maker\Param1$
      AddElement(MakerOutput())
    EndIf
    
    ForEach Decs()
      AddElement(MakerOutput())
      MakerOutput() = Decs()
    Next Decs()
    
    If *Maker\Param1$
      AddElement(MakerOutput())
      AddElement(MakerOutput())
      MakerOutput() = "EndDeclareModule"
      AddElement(MakerOutput())
    EndIf
    
  EndIf
  
  If *Maker\Param1$
    AddElement(MakerOutput())
    MakerOutput() = "Module " + *Maker\Param1$
    AddElement(MakerOutput())
  EndIf
  
  ForEach Procs()
    AddElement(MakerOutput())
    MakerOutput() = Procs()
  Next Procs()
  
  If *Maker\Param1$
    AddElement(MakerOutput())
    MakerOutput() = "EndModule"
  EndIf
  
EndProcedure

Procedure Maker_PasteButton()
  ; Try to paste somewhere sensible.
  
  Define Current$, Clip$ 
  Define NumLines, i
  
  Clip$ = ReplaceString(GetClipboardText(), #CRLF$, #LF$)
  Clip$ = ReplaceString(Clip$, #CR$, #LF$)
  NumLines = CountString(Clip$, #LF$) + 1
  
  Select *Maker\CurrentGadget
      
    Case #GADGET_Maker_Panel
      Select *Maker\CurrentPanelTab
          
          ; Case #MAKER_TAB_Make
          ; Can't paste here.
          
        Case #MAKER_TAB_Enum
          Current$ = GetGadgetText(#GADGET_Maker_EditAdHocEnum)
          Current$ + Clip$
          SetGadgetText(#GADGET_Maker_EditAdHocEnum, Current$)
          
        Case #MAKER_TAB_Template
          Current$ = GetGadgetText(#GADGET_Maker_EditAdHocEnum)
          Current$ + Clip$
          SetGadgetText(#GADGET_Maker_EditAdHocEnum, Current$)
          
          ; Case #MAKER_TAB_Code
          ; Can't paste here.
          
      EndSelect
      
    Case #GADGET_Maker_StringParam1, #GADGET_Maker_StringParam2, #GADGET_Maker_StringParam3
      SetGadgetText(*Maker\CurrentGadget, Clip$)
      
    Case #GADGET_Maker_EditAdHocEnum
      SetGadgetState(#GADGET_Maker_ComboEnumType, #MAKER_ENUM_AdHoc)
      Maker_SwitchEnum(#GADGET_Maker_EditAdHocEnum)
      If NumLines = 0
        AddGadgetItem(#GADGET_Maker_EditAdHocEnum, -1, Clip$)
      Else
        For i = 1 To NumLines + 1
          AddGadgetItem(#GADGET_Maker_EditAdHocEnum, -1, StringField(Clip$, i, #LF$))
        Next i
      EndIf
      
    Case #GADGET_Maker_EditTemplate
      SetGadgetState(#GADGET_Maker_ComboTemplate, #MAKER_TEMPLATE_AdHoc)
      Maker_ChangeTemplateType()
      AddGadgetItem(#GADGET_Maker_EditTemplate, -1, GetClipboardText())
      
    Default
      Maker_SwitchEnum(#GADGET_Maker_EditAdHocEnum)
      SetActiveGadget(#GADGET_Maker_EditAdHocEnum)
      SetGadgetText(#GADGET_Maker_EditAdHocEnum, GetClipboardText())
      
  EndSelect
  
EndProcedure

Procedure Maker_SwitchEnum(Gadget.b)
  ; Switch between showing ListSelectEnum or EditAdHocEnum.
  
  If Gadget = #GADGET_Maker_ListSelectEnum
    HideGadget(#GADGET_Maker_ListSelectEnum, #False)
    DisableGadget(#GADGET_Maker_ListSelectEnum, #False)
    HideGadget(#GADGET_Maker_EditAdHocEnum, #True)
    DisableGadget(#GADGET_Maker_EditAdHocEnum, #True)
    
  Else
    HideGadget(#GADGET_Maker_ListSelectEnum, #True)
    DisableGadget(#GADGET_Maker_ListSelectEnum, #True)
    HideGadget(#GADGET_Maker_EditAdHocEnum, #False)
    DisableGadget(#GADGET_Maker_EditAdHocEnum, #False)
    
  EndIf
  
EndProcedure

Procedure Maker_UpdateCode()
  ; Prepare the enum list and call a subcontractor procedure, then update the display.
  
  Define Line$, Tab$ 
  
  If *Maker\CurrentMakeType = -1
    ProcedureReturn
  EndIf
  
  ClearList(MakerOutput())
  
  ; Get the parameters.
  *Maker\Param1$ = GetGadgetText(#GADGET_Maker_StringParam1) 
  *Maker\Param2$ = GetGadgetText(#GADGET_Maker_StringParam2) 
  *Maker\Param3$ = GetGadgetText(#GADGET_Maker_StringParam3) 
  
  ClearGadgetItems(#GADGET_Maker_ResultCode)
  
  ; Get the list values, also performs tidy actions specified.
  If *Maker\CurrentEnumType = #MAKER_ENUM_AdHoc
    Maker_GetEnumList(#GADGET_Maker_EditAdHocEnum)
  Else
    Maker_GetEnumList(#GADGET_Maker_ListSelectEnum)
  EndIf
  
  Select *Maker\CurrentMakeType
      
    Case #MAKER_MAKE_If
      If *Maker\Param1$ = #Empty$ And (*Maker\CurrentOptions & #MAKER_OPTION_IncludeToDo) 
        AddElement(MakerOutput())
        MakerOutput() = #MAKER_Prefix_ToDo + Language("Maker", "ToDoMissingVariable")
      EndIf
      Maker_MakeGeneral(#Empty$, "If ^P1 = ^E", 0, "ElseIf ^P1 = ^E", 0, "Else", 0, "EndIf", 0)  
      
    Case #MAKER_MAKE_Select
      If *Maker\Param1$ = #Empty$ And (*Maker\CurrentOptions & #MAKER_OPTION_IncludeToDo)
        AddElement(MakerOutput())
        MakerOutput() = #MAKER_Prefix_ToDo + Language("Maker", "ToDoMissingVariable")
      EndIf
      Maker_MakeGeneral("Select ^P1", #Empty$, 0, "Case ^E", 1, "Default", 1, "EndSelect", 0)  
      
    Case #MAKER_MAKE_ProcedureSkeleton
      Maker_MakeProcedure()
      
    Case #MAKER_MAKE_TidyOnly
      ForEach MakerEnumList()
        AddElement(MakerOutput())
        MakerOutput() = MakerEnumList()\String$
      Next MakerEnumList()
      
    Case #MAKER_MAKE_TemplateOnly
      ; TODO I think this is incomplete - not using template tool?
      Maker_MakeGeneral(#Empty$, #Empty$, 0, GetGadgetText(#GADGET_Maker_EditTemplate), 0, #Empty$, 0, #Empty$, 0)  
      
  EndSelect
  
  ; Update the display.
  ClearGadgetItems(#GADGET_Maker_ResultCode)
  
  If RealTab
    Tab$ = #TAB$
  Else
    Tab$ = Space(TabLength)
  EndIf

  ForEach MakerOutput()
    Line$ = ReplaceString(MakerOutput(), "^I", Tab$)
    AddGadgetItem(#GADGET_Maker_ResultCode, -1, Line$)
  Next MakerOutput()

  *Maker\IsCurrent = #True
  
EndProcedure

Procedure Maker_UpdateLabels(P1.S, P2.S, P3.S, Option.S)
  ; Update parameter and option label text.
  
  SetGadgetText(#GADGET_Maker_LabelParam1, Language("Maker", P1) + #MAKER_Suffix_1)
  SetGadgetText(#GADGET_Maker_LabelParam2, Language("Maker", P2) + #MAKER_Suffix_2)
  SetGadgetText(#GADGET_Maker_LabelParam3, Language("Maker", P3) + #MAKER_Suffix_3)
  SetGadgetText(#GADGET_Maker_CheckOptional, Language("Maker", Option))
  
EndProcedure

;- Initialisation code
; This will make this Tool available to the editor.

Define Maker_VT.ToolsPanelFunctions

Maker_VT\CreateFunction      = @Maker_CreateFunction()
Maker_VT\DestroyFunction     = @Maker_DestroyFunction()
Maker_VT\ResizeHandler       = @Maker_ResizeHandler()
Maker_VT\EventHandler        = @Maker_EventHandler()
Maker_VT\PreferenceLoad      = #Null ; @Maker_PreferenceLoad()
Maker_VT\PreferenceSave      = #Null ; @Maker_PreferenceSave()
Maker_VT\PreferenceStart     = #Null ; @Maker_PreferenceStart()
Maker_VT\PreferenceApply     = #Null ; @Maker_PreferenceApply()
Maker_VT\PreferenceCreate    = #Null ; @Maker_PreferenceCreate()
Maker_VT\PreferenceDestroy   = #Null ; @Maker_PreferenceDestroy()
Maker_VT\PreferenceEvents    = #Null ; @Maker_PreferenceEvents()
Maker_VT\PreferenceChanged   = #Null ; @Maker_PreferenceChanged()

AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @Maker_VT
AvailablePanelTools()\NeedPreferences      = 0
AvailablePanelTools()\NeedConfiguration    = 0
AvailablePanelTools()\PreferencesWidth     = 0
AvailablePanelTools()\PreferencesHeight    = 0
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "Maker"
AvailablePanelTools()\PanelTitle$          = "Maker"
AvailablePanelTools()\ToolName$            = "Maker"
AvailablePanelTools()\ToolMinWindowHeight  = 530
AvailablePanelTools()\ToolMinWindowWidth   = 250

*Maker = @AvailablePanelTools()  ; Needed for tool procedures to access state info.

DisableExplicit
