;
; ------------------------------------------------------------
;
;   PureBasic - WebView example file
;
;    (c) 2024 - Fantaisie Software
;
; ------------------------------------------------------------
;

Procedure IncrementCallback(JsonParameters$)
  Static Count
  
  Debug #PB_Compiler_Procedure +": " + JsonParameters$
  
  Count + 1
  ProcedureReturn UTF8(~"{ \"count\": "+Str(Count)+ "}")
EndProcedure

Procedure ComputeCallback(JsonParameters$)
  
  Debug #PB_Compiler_Procedure +": " + JsonParameters$
  
  Dim Parameters(0)
  
  ; Extract the parameters from the JSON
  ParseJSON(0, JsonParameters$)
  ExtractJSONArray(JSONValue(0), Parameters())
  
  Debug "Parameter 1: " + Parameters(0)
  Debug "Parameter 2: " + Parameters(1)
    
  ProcedureReturn UTF8(Str(Parameters(0) + Parameters(1)))
EndProcedure

OpenWindow(0, 100, 100, 400, 400, "Hello", #PB_Window_SystemMenu | #PB_Window_Invisible)

WebViewGadget(0, 0, 0, 400, 400)
SetGadgetText(0, "file://" + #PB_Compiler_Home + "examples/sources/Data/WebView/webview.html")
  
BindWebViewCallback(0, "increment", @IncrementCallback())
BindWebViewCallback(0, "compute", @ComputeCallback())

; Show the window once the webview has been fully loaded
HideWindow(0, #False)

Repeat 
  Event = WaitWindowEvent()
Until Event = #PB_Event_CloseWindow
