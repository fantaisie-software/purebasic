; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Not for linux for now, because of WebKitGtk instabilities
CompilerIf #CompileLinux = 0
  
  ; Settings here are also in Global variables because they are needed elsewhere
  Global Backup_UseHelpToolF1
  Global HelpToolHomeUrl$
  
  
  Procedure Help_CreateFunction(*Entry.ToolsPanelEntry)
    
    ButtonImageGadget(#GADGET_HelpTool_Back,    0, 0, 0, 0, ImageID(#IMAGE_Help_Back))
    ButtonImageGadget(#GADGET_HelpTool_Forward, 0, 0, 0, 0, ImageID(#IMAGE_Help_Forward))
    ButtonImageGadget(#GADGET_HelpTool_Home,    0, 0, 0, 0, ImageID(#IMAGE_Help_Home))
    ButtonImageGadget(#GADGET_HelpTool_Help,    0, 0, 0, 0, ImageID(#IMAGE_Help_OpenHelp))
    
    GadgetToolTip(#GADGET_HelpTool_Back,    Language("Help","Back"))
    GadgetToolTip(#GADGET_HelpTool_Forward, Language("Help","Forward"))
    GadgetToolTip(#GADGET_HelpTool_Home,    Language("Help","Home"))
    GadgetToolTip(#GADGET_HelpTool_Help,    Language("Help","OpenHelp"))
    
    CompilerIf #CompileWindows
      HelpToolHomeUrl$ = "mk:@MSITStore:" + PureBasicPath$ + #ProductName$ + ".chm::/Reference/reference.html"
    CompilerElse
      Select UCase(CurrentLanguage$)
        Case "FRANCAIS"
          HelpToolHomeUrl$ = "file://"+PureBasicPath$+"help/purebasic_french/reference/reference.html"
        Case "DEUTSCH"
          HelpToolHomeUrl$ = "file://"+PureBasicPath$+"help/purebasic_german/reference/reference.html"
        Default
          HelpToolHomeUrl$ = "file://"+PureBasicPath$+"help/purebasic/reference/reference.html"
      EndSelect
    CompilerEndIf
    
    WebGadget(#GADGET_HelpTool_Viewer, 0, 0, 0, 0, HelpToolHomeUrl$)
    
    HelpToolOpen = #True
    
  EndProcedure
  
  Procedure Help_DestroyFunction(*Entry.ToolsPanelEntry)
    
    HelpToolOpen = #False
    
  EndProcedure
  
  
  Procedure Help_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
    
    ; All the buttons should have the same size, so only call it once
    ;
    GetRequiredSize(#GADGET_HelpTool_Back, @Width.l, @Height.l)
    
    CompilerIf #CompileWindows
      Space = 5
    CompilerElse
      Space = 8 ; looks better on Linux/OSX with some more space
    CompilerEndIf
    
    x = 5
    ResizeGadget(#GADGET_HelpTool_Back,    x, 5, Width, Height): x + Width + Space
    ResizeGadget(#GADGET_HelpTool_Forward, x, 5, Width, Height): x + Width + Space
    ResizeGadget(#GADGET_HelpTool_Home,    x, 5, Width, Height): x + Width + Space
    If x > PanelWidth-5-Width
      ResizeGadget(#GADGET_HelpTool_Help,  x, 5, Width, Height)
    Else
      ResizeGadget(#GADGET_HelpTool_Help,  PanelWidth-5-Width, 5, Width, Height)
    EndIf
    
    ResizeGadget(#GADGET_HelpTool_Viewer, 0, 10+Height, PanelWidth, PanelHeight-Height-10)
    
  EndProcedure
  
  Procedure Help_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
    
    Select EventGadgetID
        
      Case #GADGET_HelpTool_Back
        SetGadgetState(#GADGET_HelpTool_Viewer, #PB_Web_Back)
        
      Case #GADGET_HelpTool_Forward
        SetGadgetState(#GADGET_HelpTool_Viewer, #PB_Web_Forward)
        
      Case #GADGET_HelpTool_Home
        SetGadgetText(#GADGET_HelpTool_Viewer, HelpToolHomeUrl$)
        
      Case #GADGET_HelpTool_Help
        CompilerIf #CompileWindows
          Page$ = GetGadgetText(#GADGET_HelpTool_Viewer)
          Page$ = Right(Page$, Len(Page$)-(FindString(Page$, "::", 1)+1))
          If Left(Page$, 1) = "/"
            Page$ = Right(Page$, Len(Page$)-1)
          EndIf
          OpenHelp(PureBasicPath$ + #ProductName$ + ".chm", Page$)
        CompilerElse
          OpenHelpWindow()
          SetGadgetText(#GADGET_Help_Viewer, GetGadgetText(#GADGET_HelpTool_Viewer))
        CompilerEndIf
        
    EndSelect
    
  EndProcedure
  
  
  Procedure Help_PreferenceStart(*Entry.ToolsPanelEntry)
    
    ; Use the backup variable during the PReferences changing
    Backup_UseHelpToolF1 = UseHelpToolF1
    
  EndProcedure
  
  
  Procedure Help_PreferenceApply(*Entry.ToolsPanelEntry)
    
    ; put the backup variable back
    UseHelpToolF1 = Backup_UseHelpToolF1
    
  EndProcedure
  
  
  
  Procedure Help_PreferenceCreate(*Entry.ToolsPanelEntry)
    
    CheckBoxGadget(#GADGET_Preferences_UseHelpToolF1, 10, 10, 300, 25, Language("Help","OpenF1"))
    SetGadgetState(#GADGET_Preferences_UseHelpToolF1, Backup_UseHelpToolF1)
    
    GetRequiredSize(#GADGET_Preferences_UseHelpToolF1, @Width, @Height)
    ResizeGadget(#GADGET_Preferences_UseHelpToolF1, 10, 10, Width, Height)
    
  EndProcedure
  
  
  Procedure Help_PreferenceDestroy(*Entry.ToolsPanelEntry)
    
    Backup_UseHelpToolF1 = GetGadgetState(#GADGET_Preferences_UseHelpToolF1)
    
  EndProcedure
  
  
  Procedure Help_PreferenceEvents(*Entry.ToolsPanelEntry, EventGadgetID)
    ;
    ; nothing to do here
    ;
  EndProcedure
  
  Procedure Help_PreferenceChanged(*Entry.ToolsPanelEntry, IsConfigOpen)
    
    If IsConfigOpen
      If UseHelpToolF1 <> GetGadgetState(#GADGET_Preferences_UseHelpToolF1)
        ProcedureReturn 1
      EndIf
      
    Else
      If UseHelpToolF1 <> Backup_UseHelpToolF1
        ProcedureReturn 1
      EndIf
      
    EndIf
    
    ProcedureReturn 0
  EndProcedure
  
  
  ;- Initialisation code
  ; This will make this Tool available to the editor
  ;
  Help_VT.ToolsPanelFunctions
  
  Help_VT\CreateFunction      = @Help_CreateFunction()
  Help_VT\DestroyFunction     = @Help_DestroyFunction()
  Help_VT\ResizeHandler       = @Help_ResizeHandler()
  Help_VT\EventHandler        = @Help_EventHandler()
  Help_VT\PreferenceStart     = @Help_PreferenceStart()
  Help_VT\PreferenceApply     = @Help_PreferenceApply()
  Help_VT\PreferenceCreate    = @Help_PreferenceCreate()
  Help_VT\PreferenceDestroy   = @Help_PreferenceDestroy()
  Help_VT\PreferenceEvents    = @Help_PreferenceEvents()
  Help_VT\PreferenceChanged   = @Help_PreferenceChanged()
  
  
  AddElement(AvailablePanelTools())
  
  AvailablePanelTools()\FunctionsVT          = @Help_VT
  AvailablePanelTools()\NeedPreferences      = 0 ; the one setting is stored in the global section
  AvailablePanelTools()\NeedConfiguration    = 1
  AvailablePanelTools()\PreferencesWidth     = 320
  AvailablePanelTools()\PreferencesHeight    = 80
  AvailablePanelTools()\NeedDestroyFunction  = 1
  AvailablePanelTools()\ToolID$              = "HelpTool"
  AvailablePanelTools()\PanelTitle$          = "HelpToolShort"
  AvailablePanelTools()\ToolName$            = "HelpToolLong"
  
CompilerEndIf
