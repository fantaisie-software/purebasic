; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


; Store color names in an array, for indexable lookup
Global Dim ColorName.s(#COLOR_Last_IncludingToolsPanel)

; Color Scheme structure
Structure ColorSchemeStruct
  Name$
  File$
  
  ColorValue.l[#COLOR_Last_IncludingToolsPanel + 1]
  
  IsIDEDefault.i
  IsAccessibility.i
EndStructure

; Global list of built-in / found schemes
Global NewList ColorScheme.ColorSchemeStruct()

; Color values with special meanings
#ColorSchemeValue_UseSysColor = -1
#ColorSchemeValue_Undefined   = -2



; Returns #True if the specified color scheme matches the user's current color settings, otherwise #False
Procedure ColorSchemeMatchesCurrentSettings(*ColorScheme.ColorSchemeStruct)
  Protected Result = #True
  
  For i = 0 To #COLOR_Last
    If i <> #COLOR_Selection And i <> #COLOR_SelectionFront ; selection colors may follow OS, so skip them for scheme match check
      If *ColorScheme\ColorValue[i] >= 0
        If *ColorScheme\ColorValue[i] <> Colors(i)\UserValue
          Result = #False
          Break
        EndIf
      EndIf
    EndIf
  Next i
  
  ProcedureReturn Result
EndProcedure

; Returns *ColorScheme which matches the user's current settings, otherwise #Null if no match
Procedure FindCurrentColorScheme()
  Protected *ColorScheme.ColorSchemeStruct = #Null
  
  ForEach ColorScheme()
    If ColorSchemeMatchesCurrentSettings(@ColorScheme())
      *ColorScheme = @ColorScheme()
      Break
    EndIf
  Next
  
  ProcedureReturn *ColorScheme
EndProcedure

; Guess the specified color for a given Color Scheme, falling back to its basic background/text colors
Procedure GuessColorSchemeColor(*ColorScheme.ColorSchemeStruct, index)
  Select index
    Case #COLOR_GlobalBackground
      Color = #White
    Case #COLOR_NormalText
      Color = $FFFFFF - *ColorScheme\ColorValue[#COLOR_GlobalBackground]
      
    Case #COLOR_CurrentLine, #COLOR_DisabledBack, #COLOR_LineNumberBack, #COLOR_PlainBackground, #COLOR_ProcedureBack, #COLOR_ToolsPanelBackColor
      Color = *ColorScheme\ColorValue[#COLOR_GlobalBackground] ; assume it should match global background
    Case #COLOR_DebuggerBreakPoint, #COLOR_DebuggerError, #COLOR_DebuggerLine, #COLOR_DebuggerWarning
      Color = *ColorScheme\ColorValue[#COLOR_GlobalBackground]
      
    Case #COLOR_SelectionFront
      CompilerIf #CompileWindows
        Color = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
      CompilerElse
        Color = *ColorScheme\ColorValue[#COLOR_GlobalBackground]
      CompilerEndIf
    Case #COLOR_Selection, #COLOR_SelectionRepeat
      CompilerIf #CompileWindows
        Color = GetSysColor_(#COLOR_HIGHLIGHT)
      CompilerElse
        Color = *ColorScheme\ColorValue[#COLOR_NormalText]
      CompilerEndIf
      
    Default
      Color = *ColorScheme\ColorValue[#COLOR_NormalText] ; otherwise, assume it should match normal foreground color
  EndSelect
  
  ProcedureReturn Color
EndProcedure

; Disable color preference gadgets if appropriate (eg. disable Selection and SelectionFront when Accessibility mode expects them to match system colors)
Procedure DisableSelectionColorGadgets(*ColorScheme.ColorSchemeStruct)
  CompilerIf #CompileWindows
    ShouldDisable = #False
    
    If EnableAccessibility
      ShouldDisable = #True ; Accessibility mode enabled - use system selection colors, don't allow user to change them
    Else
      If *ColorScheme
        If *ColorScheme\IsAccessibility
          ShouldDisable = #True ; Accessibility scheme selected - use system selection colors, don't allow user to change them
        ElseIf *ColorScheme\ColorValue[#COLOR_Selection] = #ColorSchemeValue_UseSysColor Or *ColorScheme\ColorValue[#COLOR_SelectionFront] = #ColorSchemeValue_UseSysColor
          ShouldDisable = #True ; Value of -1 (use system color) specified
        EndIf
      EndIf
    EndIf
    
    DisableGadget(#GADGET_Preferences_FirstColorText   + #COLOR_Selection,      ShouldDisable)
    DisableGadget(#GADGET_Preferences_FirstSelectColor + #COLOR_Selection,      ShouldDisable)
    DisableGadget(#GADGET_Preferences_FirstColorText   + #COLOR_SelectionFront, ShouldDisable)
    DisableGadget(#GADGET_Preferences_FirstSelectColor + #COLOR_SelectionFront, ShouldDisable)
  CompilerEndIf
EndProcedure

; Load the specified *ColorScheme to the Preferences gadgets
Procedure LoadColorSchemeToPreferencesWindow(*ColorScheme.ColorSchemeStruct)
  If *ColorScheme
    
    PreferenceToolsPanelFrontColor = *ColorScheme\ColorValue[#COLOR_ToolsPanelFrontColor]
    PreferenceToolsPanelBackColor  = *ColorScheme\ColorValue[#COLOR_ToolsPanelBackColor]
    
    For i = 0 To #COLOR_Last
      Colors(i)\PrefsValue = *ColorScheme\ColorValue[i]
    Next i
    
    CompilerIf #CompileWindows
      ; Special thing: On windows we always default back to the system colors in
      ; the PB standard scheme for screenreader support. The 'Accessibility'
      ; scheme has a special option to always use these colors, so it is not needed here.
      ;
      If *ColorScheme\IsIDEDefault Or *ColorScheme\IsAccessibility Or EnableAccessibility Or (Colors(#COLOR_Selection)\PrefsValue = #ColorSchemeValue_UseSysColor)
        Colors(#COLOR_Selection)\PrefsValue      = GetSysColor_(#COLOR_HIGHLIGHT)
        Colors(#COLOR_SelectionFront)\PrefsValue = GetSysColor_(#COLOR_HIGHLIGHTTEXT)
      EndIf
    CompilerEndIf
    
    For i = 0 To #COLOR_Last
      If Colors(i)\PrefsValue >= 0
        UpdatePreferenceSyntaxColor(i, Colors(i)\PrefsValue)
      Else
        Colors(i)\PrefsValue = GuessColorSchemeColor(*ColorScheme, i)
        UpdatePreferenceSyntaxColor(i, Colors(i)\PrefsValue)
      EndIf
    Next i
    
    DisableSelectionColorGadgets(*ColorScheme)
    
    If PreferenceToolsPanelFrontColor < 0
      PreferenceToolsPanelFrontColor = GuessColorSchemeColor(*ColorScheme, #COLOR_ToolsPanelFrontColor)
    EndIf
    If PreferenceToolsPanelBackColor < 0
      PreferenceToolsPanelBackColor = GuessColorSchemeColor(*ColorScheme, #COLOR_ToolsPanelBackColor)
    EndIf
    
    If IsImage(#IMAGE_Preferences_ToolsPanelFrontColor)
      UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelFrontColor, #IMAGE_Preferences_ToolsPanelFrontColor, PreferenceToolsPanelFrontColor)
    EndIf
    If IsImage(#IMAGE_Preferences_ToolsPanelBackColor)
      UpdateImageColorGadget(#GADGET_Preferences_ToolsPanelBackColor, #IMAGE_Preferences_ToolsPanelBackColor, PreferenceToolsPanelBackColor)
    EndIf
    
  EndIf
EndProcedure

; Find and remove a known color scheme by its name
Procedure RemoveColorSchemeIfExists(Name$)
  If Name$ <> ""
    ForEach ColorScheme()
      If ColorScheme()\Name$ = Name$
        DeleteElement(ColorScheme())
        Break
      EndIf
    Next
  EndIf
EndProcedure

; Read the specified *ColorScheme from data section (for built-in schemes)
Procedure ReadColorSchemeFromDataSection(*ColorScheme.ColorSchemeStruct)
  If *ColorScheme
    ; This assumes the NAME STRING data has already been read!
    *ColorScheme\File$ = ""
    Read.l *ColorScheme\ColorValue[#COLOR_ToolsPanelFrontColor]
    Read.l *ColorScheme\ColorValue[#COLOR_ToolsPanelBackColor]
    For i = 0 To #COLOR_Last
      Read.l *ColorScheme\ColorValue[i]
    Next i
  EndIf
  
  ProcedureReturn *ColorScheme
EndProcedure

; Load the specified *ColorScheme from file on disk (for external schemes)
Procedure LoadColorSchemeFromFile(*ColorScheme.ColorSchemeStruct, File$)
  Protected Result = #Null
  
  If File$
    ; Basic validation of color scheme file...
    If OpenPreferences(File$)
      Name$ = GetFilePart(File$, #PB_FileSystem_NoExtension)
      If PreferenceGroup("Sections") And (ReadPreferenceLong("IncludeColors", 0) = 1)
        If PreferenceGroup("Colors")
          
          If *ColorScheme
            RemoveColorSchemeIfExists(Name$)
            *ColorScheme\Name$ = Name$
            *ColorScheme\File$ = File$
            
            ; Load all defined colors into map...
            For i = 0 To #COLOR_Last_IncludingToolsPanel
              *ColorScheme\ColorValue[i] = #ColorSchemeValue_Undefined
              ColorValueString$ = ReadPreferenceString(ColorName(i), "")
              If ColorValueString$ <> ""
                If ReadPreferenceLong(ColorName(i) + "_Used", 1) = 1
                  If FindString(ColorValueString$, "RGB", 1, #PB_String_NoCase)
                    *ColorScheme\ColorValue[i] = ColorFromRGBString(ColorValueString$)
                  Else
                    *ColorScheme\ColorValue[i] = Val(ColorValueString$) & $00FFFFFF
                  EndIf
                EndIf
              EndIf
            Next i
            Result = *ColorScheme
            
          EndIf
          
        EndIf
      EndIf
      ClosePreferences()
    EndIf
  EndIf
  
  ProcedureReturn Result
EndProcedure

; Initialize color names, built-in color schemes, and external found color schemes
Procedure InitColorSchemes()
  
  ; Only need to initialize color schemes once
  If NbSchemes > 0
    ProcedureReturn
  EndIf
  
  ; Read color key names into indexable array
  Restore ColorKeys
  For i = 0 To #COLOR_Last
    Read.s ColorName(i)
  Next i
  ColorName(#COLOR_ToolsPanelFrontColor) = "ToolsPanel_FrontColor"
  ColorName(#COLOR_ToolsPanelBackColor)  = "ToolsPanel_BackColor"
  
  
  ; First, load embedded DataSection default color schemes
  ClearList(ColorScheme())
  Restore DefaultColorSchemes
  Read.s Name$
  While Name$ <> ""
    AddElement(ColorScheme())
    ColorScheme()\Name$ = Name$
    ReadColorSchemeFromDataSection(@ColorScheme())
    If ListIndex(ColorScheme()) = 0
      ColorScheme()\IsIDEDefault = #True
    EndIf
    Read.s Name$
  Wend
  NbSchemes = ListSize(ColorScheme())
  
  ; Then, scan 'ColorSchemes' subfolder!
  If PureBasicPath$
    Dir = ExamineDirectory(#PB_Any, PureBasicPath$ + #DEFAULT_ColorSchemePath, "*")
    If Dir
      While NextDirectoryEntry(Dir)
        If DirectoryEntryType(Dir) = #PB_DirectoryEntry_File
          File$ = PureBasicPath$ + #DEFAULT_ColorSchemePath + #PS$ + DirectoryEntryName(Dir)
          Select LCase(GetExtensionPart(File$))
            Case "prefs"
              AddElement(ColorScheme())
              If LoadColorSchemeFromFile(@ColorScheme(), File$)
                ; OK
              Else
                DeleteElement(ColorScheme())
              EndIf
          EndSelect
        EndIf
      Wend
      FinishDirectory(Dir)
    EndIf
  EndIf
  
  
  ; If additional schemes were found, sort schemes alphabetically, because it could become a long list
  If ListSize(ColorScheme()) > NbSchemes
    NbSchemes = ListSize(ColorScheme())
    SortStructuredList(ColorScheme(), #PB_Sort_Ascending | #PB_Sort_NoCase, OffsetOf(ColorSchemeStruct\Name$), #PB_String)
  EndIf
  
  ; Ensure "Accessibility" scheme always at bottom of list, for special handling
  ForEach ColorScheme()
    If ColorScheme()\Name$ = "Accessibility"
      ColorScheme()\IsAccessibility = #True
      MoveElement(ColorScheme(), #PB_List_Last)
    EndIf
  Next
  
EndProcedure
