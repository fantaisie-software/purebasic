; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------

Structure WebViewBaseParameter
  command.i
EndStructure

Structure WebViewInitParameter Extends WebViewBaseParameter
  filename.s
  sourcePath.s
  List includes.s()
EndStructure

Structure WebViewErrorParameter Extends WebViewBaseParameter
  lineId.i
  text.s
EndStructure

Structure WebViewWarningParameter Extends WebViewBaseParameter
  lineId.i
  text.s
EndStructure

Structure WebViewDebugParameter Extends WebViewBaseParameter
  text.s
EndStructure


Structure WebViewControlDebugOutputParameter Extends WebViewBaseParameter
  value.i
  filename.s
EndStructure



; Settings here are also in Global variables because they are needed elsewhere

Procedure WebView_Callback(JsonParameters$)
  Debug JsonParameters$
  
  ; The callback always returns an array of parameters. In our case, we always have only one parameter, with a specific object
  ;
  ParseJSON(0, JsonParameters$)
    
  ; Get the first element of the parameter array
  ParameterJSON = GetJSONElement(JSONValue(0), 0)
  
  ; Get the base parameter, common to all commands
  ExtractJSONStructure(ParameterJSON, @BaseParameter.WebViewBaseParameter, WebViewBaseParameter)
  
  Debug BaseParameter\command
  
  ; Update the debugger structure
  *WebViewDebugger\Command\Command = BaseParameter\command
  *WebViewDebugger\Command\TimeStamp = Date()
    
  Select BaseParameter\command
      
    Case #COMMAND_Init ; Init
      
      ; Map the JSON to a PB structure
      ;
      ExtractJSONStructure(ParameterJSON, @InitParameter.WebViewInitParameter, WebViewInitParameter)
      Debug "****** Init"
      
      Debug "filename: "+ InitParameter\filename
      Debug "sourcePath: "+ InitParameter\sourcePath
      Debug "ListSize " + ListSize(InitParameter\Includes())
      ForEach InitParameter\Includes()
        Debug InitParameter\Includes()
      Next
      
      ; Map to the internal IDE debugger structure format, so we can reuse most of the code for the debugger
      ; It's a bit complex as it was though for native PureBasic executable 
      ;
      *WebViewDebugger\FileName$ = InitParameter\filename
      *WebViewDebugger\NbIncludedFiles = ListSize(InitParameter\includes())
      
      ; Calc the needed size. The buffer contains the source path, the main filename and all included files as UTF-8
      IncludeLength = Len(InitParameter\sourcePath) + 1
      IncludeLength + Len(InitParameter\filename) + 1
      
      ForEach InitParameter\Includes()
       IncludeLength + Len(InitParameter\Includes()) + 1 ; Include the null terminated char
      Next
        
      *WebViewDebugger\IncludedFiles = ReAllocateMemory(*WebViewDebugger\IncludedFiles, IncludeLength * 4) ; At most the UTF-8 encoding take 4 bytes per char
      
      *Output = *WebViewDebugger\IncludedFiles
      
      ; Write the source path as UTF-8 in the buffer
      *Output + PokeS(*Output, InitParameter\sourcePath, -1, #PB_UTF8) + 1
      
      ; Write the main filename as UTF-8 in the buffer
      *Output + PokeS(*Output, InitParameter\filename, -1, #PB_UTF8) + 1
      
      ; Write the includes as UTF-8 in the buffer
      ForEach InitParameter\Includes()
        *Output + PokeS(*Output, InitParameter\Includes(), -1, #PB_UTF8) + 1
      Next
      
      ; Close any previous window before launching a new one
      ;
      If IsWindow(*WebViewDebugger\Windows[#DEBUGGER_WINDOW_Debug])
        CloseWindow(*WebViewDebugger\Windows[#DEBUGGER_WINDOW_Debug])
      EndIf
      
      ; The output window is always created
      CreateDebugWindow(*WebViewDebugger)
      
    Case #COMMAND_Error
      
      ; Map the JSON To a PB Structure
      ;
      ExtractJSONStructure(ParameterJSON, @ErrorParameter.WebViewErrorParameter, WebViewErrorParameter)
      Debug "****** Error"
      
      ; Map to the internal IDE debugger structure format, so we can reuse most of the code for the debugger
      ;
      *WebViewDebugger\Command\Value1 = ErrorParameter\lineId
      *WebViewDebugger\CommandData = UTF8(ErrorParameter\text)
      DebuggerCallback(*WebViewDebugger)
      
    Case #COMMAND_Warning
      
      ; Map the JSON To a PB Structure
      ;
      ExtractJSONStructure(ParameterJSON, @WarningParameter.WebViewWarningParameter, WebViewWarningParameter)
      Debug "****** Warning"
      
      ; Map to the internal IDE debugger structure format, so we can reuse most of the code for the debugger
      ;
      *WebViewDebugger\Command\Value1 = WarningParameter\lineId
      *WebViewDebugger\CommandData = UTF8(WarningParameter\text)
      DebuggerCallback(*WebViewDebugger)
      
            
    Case #COMMAND_Debug
      
      ; Map the JSON To a PB Structure
      ;
      ExtractJSONStructure(ParameterJSON, @DebugParameter.WebViewDebugParameter, WebViewDebugParameter)
      Debug "****** Debug"
      Debug DebugParameter\text
      
      *WebViewDebugger\IsDebugMessage = #True
      *WebViewDebugger\DebugMessage$ = DebugParameter\text
      UpdateDebugOutputWindow(*WebViewDebugger)
      
      ; show the debug window if needed.
      ; Warning it needs to be the very last command of the 'Debug' block or the callback can recurse of HideWindow() and the message will be displayed out of order: https://forums.spiderbasic.com/viewtopic.php?t=2675
      ; It looks like activating a window process some event and the WebView callback is called again.
      ;
      If *WebViewDebugger\OutputFirstVisible
        OpenDebugWindow(*WebViewDebugger, #True)
      EndIf
      
    Case #COMMAND_ControlDebugOutput
      
      ; Map the JSON To a PB Structure
      ;
      ExtractJSONStructure(ParameterJSON, @ControlDebugOutputParameter.WebViewControlDebugOutputParameter, WebViewControlDebugOutputParameter)
      Debug "****** ControlDebugOutput"
      Debug ControlDebugOutputParameter\value
      
      *WebViewDebugger\Command\Value1 = ControlDebugOutputParameter\value
      
      ; Use a dynamic allocated memory for 'CommandData' as it could be automatically freed
      *WebViewDebugger\CommandData = AllocateMemory((Len(ControlDebugOutputParameter\filename)+1)*SizeOf(Character))
      PokeS(*WebViewDebugger\CommandData, ControlDebugOutputParameter\filename)
      
      *WebViewDebugger\Command\DataSize = Len(ControlDebugOutputParameter\filename)
      
      DebugOutput_DebuggerEvent(*WebViewDebugger)
     
  EndSelect
  
  ProcedureReturn UTF8("")
EndProcedure



Procedure WebView_CreateFunction(*Entry.ToolsPanelEntry)
  
  StringGadget(#GADGET_WebView_Url, 4, 4, 0, 25, "", #PB_String_ReadOnly)
  ButtonImageGadget(#GADGET_WebView_OpenBrowser, 0, 4, 25, 25, ImageID(#IMAGE_WebView_OpenBrowser))
  
  WebViewGadget(#GADGET_WebView_WebView, 0, 33, 0, 0, #PB_WebView_Debug)
  BindWebViewCallback(#GADGET_WebView_WebView, "spiderDebug", @WebView_Callback())
  
  WebViewOpen = #True
EndProcedure

Procedure WebView_DestroyFunction(*Entry.ToolsPanelEntry)
  
  WebViewOpen = #False
EndProcedure


Procedure WebView_ResizeHandler(*Entry.ToolsPanelEntry, PanelWidth, PanelHeight)
  
  ResizeGadget(#GADGET_WebView_Url        , #PB_Ignore   , #PB_Ignore, PanelWidth-35, #PB_Ignore)
  ResizeGadget(#GADGET_WebView_OpenBrowser, PanelWidth-27, #PB_Ignore, #PB_Ignore   , #PB_Ignore)
  ResizeGadget(#GADGET_WebView_WebView, #PB_Ignore, #PB_Ignore, PanelWidth, PanelHeight-GadgetY(#GADGET_WebView_WebView))
  
EndProcedure

Procedure WebView_EventHandler(*Entry.ToolsPanelEntry, EventGadgetID)
  
  Select EventGadgetID
    Case #GADGET_WebView_OpenBrowser
      OpenSpiderWebBrowser(GetGadgetText(#GADGET_WebView_Url))
  EndSelect

EndProcedure


Procedure WebView_PreferenceStart(*Entry.ToolsPanelEntry)
EndProcedure


Procedure WebView_PreferenceApply(*Entry.ToolsPanelEntry)
EndProcedure


Procedure WebView_PreferenceCreate(*Entry.ToolsPanelEntry)
EndProcedure


Procedure WebView_PreferenceDestroy(*Entry.ToolsPanelEntry)
EndProcedure


Procedure WebView_PreferenceEvents(*Entry.ToolsPanelEntry, EventGadgetID)
EndProcedure


Procedure WebView_PreferenceChanged(*Entry.ToolsPanelEntry, IsConfigOpen)
EndProcedure

Procedure SetWebViewUrl(Url$)
  SetGadgetText(#GADGET_WebView_Url, Url$)
  SetGadgetText(#GADGET_WebView_WebView, Url$)
  
  ActivateTool("WebView")
  SetActiveGadget(#GADGET_WebView_WebView)
EndProcedure


Procedure OpenSpiderWebBrowser(Url$)
  
  If Url$ = ""
    ProcedureReturn
  EndIf
  
  CompilerIf #CompileWindows
    If OptionWebBrowser$
      RunProgram(OptionWebBrowser$, Url$, "")
    Else
      RunProgram(Url$) ; Will launch the default browser
    EndIf
    
  CompilerElseIf #CompileLinux
    If OptionWebBrowser$
      RunProgram(OptionWebBrowser$, Url$, "")
    Else
      RunProgram("xdg-open", Url$, "") ; Will launch the default browser
    EndIf
    
  CompilerElseIf #CompileMac
    If OptionWebBrowser$
      RunProgram("open", "-a " + OptionWebBrowser$ + " " + Url$, "")
    Else
      RunProgram("open", Url$, "") ; Will launch the default browser
    EndIf
  CompilerEndIf
  
EndProcedure



;- Initialisation code
; This will make this Tool available to the editor
;
WebView_VT.ToolsPanelFunctions

WebView_VT\CreateFunction      = @WebView_CreateFunction()
WebView_VT\DestroyFunction     = @WebView_DestroyFunction()
WebView_VT\ResizeHandler       = @WebView_ResizeHandler()
WebView_VT\EventHandler        = @WebView_EventHandler()
WebView_VT\PreferenceStart     = @WebView_PreferenceStart()
WebView_VT\PreferenceApply     = @WebView_PreferenceApply()
WebView_VT\PreferenceCreate    = @WebView_PreferenceCreate()
WebView_VT\PreferenceDestroy   = @WebView_PreferenceDestroy()
WebView_VT\PreferenceEvents    = @WebView_PreferenceEvents()
WebView_VT\PreferenceChanged   = @WebView_PreferenceChanged()


AddElement(AvailablePanelTools())

AvailablePanelTools()\FunctionsVT          = @WebView_VT
AvailablePanelTools()\NeedPreferences      = 0 ; the one setting is stored in the global section
AvailablePanelTools()\NeedConfiguration    = 0
AvailablePanelTools()\PreferencesWidth     = 320
AvailablePanelTools()\PreferencesHeight    = 80
AvailablePanelTools()\NeedDestroyFunction  = 1
AvailablePanelTools()\ToolID$              = "WebView"
AvailablePanelTools()\PanelTitle$          = "WebViewShort"
AvailablePanelTools()\ToolName$            = "WebViewLong"
AvailablePanelTools()\PanelTabOrder        = 5

