;
; ------------------------------------------------------------
;
;   PureBasic - IDE Automation library
;
;    (c) 2010 - Fantaisie Software
;
; ------------------------------------------------------------
;

;
;
; This file provides a wrapper to the Automation.dll library
; and to the functionality exposed by the IDE.
;
; The available functions for communicating with the IDE
; are described below.
;
;

Prototype AUTO_ConnectToWindow(WindowID)
Prototype AUTO_ConnectToProcess(ProcessID)
Prototype AUTO_ConnectToProgram(Executable$)
Prototype AUTO_ConnectFromTool()
Prototype AUTO_ConnectToAny()
Prototype AUTO_Disconnect()

Prototype AUTO_LastErrorPtr()
Prototype AUTO_ClearError()

Prototype AUTO_RPC_NewCall(Function$, NbParameters)
Prototype AUTO_RPC_FreeCall(*Call)
Prototype AUTO_RPC_CallResponse(*Call, NbParameters)
Prototype AUTO_RPC_CallError(*Call, Message$)
Prototype AUTO_RPC_SendCall(*Call)
Prototype AUTO_RPC_SetLong(*Call, Index, Value.l)
Prototype AUTO_RPC_SetQuad(*Call, Index, Value.q)
Prototype AUTO_RPC_SetString(*Call, Index, Value$)
Prototype AUTO_RPC_SetMemory(*Call, Index, *Buffer, Size)
Prototype.l AUTO_RPC_GetLong(*Call, Index)
Prototype.q AUTO_RPC_GetQuad(*Call, Index)
Prototype AUTO_RPC_GetStringPtr(*Call, Index)
Prototype AUTO_RPC_GetMemorySize(*Call, Index)
Prototype AUTO_RPC_GetMemory(*Call, Index)
Prototype AUTO_RPC_CountParameters(*Call)
Prototype AUTO_RPC_GetFunctionPtr(*Call)
Prototype AUTO_RPC_SetCallback(Callback)
Prototype AUTO_RPC_ProcessEvents(Timeout)

Prototype AUTO_Event_AutoComplete(List Entries.s())

Macro AUTO_LastError()
  PeekS(AUTO_LastErrorPtr())
EndMacro

Macro AUTO_RPC_GetString(Call, Index)
  PeekS(AUTO_RPC_GetStringPtr(Call, Index))
EndMacro

Macro AUTO_RPC_GetFunction(Call)
  PeekS(AUTO_RPC_GetFunctionPtr(Call))
EndMacro

Global AUTO_ConnectToWindow.AUTO_ConnectToWindow
Global AUTO_ConnectToProcess.AUTO_ConnectToProcess
Global AUTO_ConnectToProgram.AUTO_ConnectToProgram
Global AUTO_ConnectFromTool.AUTO_ConnectFromTool
Global AUTO_ConnectToAny.AUTO_ConnectToAny
Global AUTO_Disconnect.AUTO_Disconnect
Global AUTO_LastErrorPtr.AUTO_LastErrorPtr
Global AUTO_ClearError.AUTO_ClearError
Global AUTO_RPC_NewCall.AUTO_RPC_NewCall
Global AUTO_RPC_FreeCall.AUTO_RPC_FreeCall
Global AUTO_RPC_CallResponse.AUTO_RPC_CallResponse
Global AUTO_RPC_CallError.AUTO_RPC_CallError
Global AUTO_RPC_SendCall.AUTO_RPC_SendCall
Global AUTO_RPC_SetLong.AUTO_RPC_SetLong
Global AUTO_RPC_SetQuad.AUTO_RPC_SetQuad
Global AUTO_RPC_SetString.AUTO_RPC_SetString
Global AUTO_RPC_SetMemory.AUTO_RPC_SetMemory
Global AUTO_RPC_GetLong.AUTO_RPC_GetLong
Global AUTO_RPC_GetQuad.AUTO_RPC_GetQuad
Global AUTO_RPC_GetStringPtr.AUTO_RPC_GetStringPtr
Global AUTO_RPC_GetMemorySize.AUTO_RPC_GetMemorySize
Global AUTO_RPC_GetMemory.AUTO_RPC_GetMemory
Global AUTO_RPC_CountParameters.AUTO_RPC_CountParameters
Global AUTO_RPC_GetFunctionPtr.AUTO_RPC_GetFunctionPtr
Global AUTO_RPC_SetCallback.AUTO_RPC_SetCallback
Global AUTO_RPC_ProcessEvents.AUTO_RPC_ProcessEvents

Global AUTO_Library
Global NewMap AUTO_EventCallbacks()

Procedure AUTO_EventCallback(*Call)
  Protected Count, Index
  
  Debug "event"
  Debug AUTO_RPC_GetFunction(*Call)
  
  Select AUTO_RPC_GetFunction(*Call)
      
    Case "AutoComplete"
      CallDebugger
      Protected NewList Entries.s()
      Protected AutoCompleteEvent.AUTO_Event_AutoComplete = AUTO_EventCallbacks("AutoComplete")
      
      If AutoCompleteEvent
        Count = AUTO_RPC_CountParameters(*Call)
        For Index = 0 To Count-1
          AddElement(Entries())
          Entries() = AUTO_RPC_GetString(*Call, Index)
        Next Index
        
        AutoCompleteEvent(Entries())
        
        AUTO_RPC_CallResponse(*Call, ListSize(Entries()))
        ForEach Entries()
          AUTO_RPC_SetString(*Call, ListIndex(Entries()), Entries())
        Next Entries()
      Else
        AUTO_RPC_CallError(*Call, "Event not registered")
      EndIf
      
      
  EndSelect
  
EndProcedure

Procedure AUTO_Initialize(Library$ = "")
  If Library$ = ""
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      CompilerIf #PB_Compiler_Unicode
        Library$ = #PB_Compiler_Home + "SDK\Automation\AutomationUnicode.dll"
      CompilerElse
        Library$ = #PB_Compiler_Home + "SDK\Automation\Automation.dll"
      CompilerEndIf
    CompilerElse
      CompilerError "todo"
    CompilerEndIf
  EndIf
  
  AUTO_Library = OpenLibrary(#PB_Any, Library$)
  If AUTO_Library
    AUTO_ConnectToWindow    = GetFunction(AUTO_Library, "AUTO_ConnectToWindow")
    AUTO_ConnectToProcess   = GetFunction(AUTO_Library, "AUTO_ConnectToProcess")
    AUTO_ConnectToProgram   = GetFunction(AUTO_Library, "AUTO_ConnectToProgram")
    AUTO_ConnectFromTool    = GetFunction(AUTO_Library, "AUTO_ConnectFromTool")
    AUTO_ConnectToAny       = GetFunction(AUTO_Library, "AUTO_ConnectToAny")
    AUTO_Disconnect         = GetFunction(AUTO_Library, "AUTO_Disconnect")
    AUTO_LastErrorPtr       = GetFunction(AUTO_Library, "AUTO_LastErrorPtr")
    AUTO_ClearError         = GetFunction(AUTO_Library, "AUTO_ClearError")
    AUTO_RPC_NewCall        = GetFunction(AUTO_Library, "AUTO_RPC_NewCall")
    AUTO_RPC_FreeCall       = GetFunction(AUTO_Library, "AUTO_RPC_FreeCall")
    AUTO_RPC_CallResponse   = GetFunction(AUTO_Library, "AUTO_RPC_CallResponse")
    AUTO_RPC_CallError      = GetFunction(AUTO_Library, "AUTO_RPC_CallError")
    AUTO_RPC_SendCall       = GetFunction(AUTO_Library, "AUTO_RPC_SendCall")
    AUTO_RPC_SetLong        = GetFunction(AUTO_Library, "AUTO_RPC_SetLong")
    AUTO_RPC_SetQuad        = GetFunction(AUTO_Library, "AUTO_RPC_SetQuad")
    AUTO_RPC_SetString      = GetFunction(AUTO_Library, "AUTO_RPC_SetString")
    AUTO_RPC_SetMemory      = GetFunction(AUTO_Library, "AUTO_RPC_SetMemory")
    AUTO_RPC_GetLong        = GetFunction(AUTO_Library, "AUTO_RPC_GetLong")
    AUTO_RPC_GetQuad        = GetFunction(AUTO_Library, "AUTO_RPC_GetQuad")
    AUTO_RPC_GetMemorySize  = GetFunction(AUTO_Library, "AUTO_RPC_GetMemorySize")
    AUTO_RPC_GetMemory      = GetFunction(AUTO_Library, "AUTO_RPC_GetMemory")
    AUTO_RPC_CountParameters= GetFunction(AUTO_Library, "AUTO_RPC_CountParameters")
    AUTO_RPC_GetFunctionPtr = GetFunction(AUTO_Library, "AUTO_RPC_GetFunctionPtr")
    AUTO_RPC_SetCallback    = GetFunction(AUTO_Library, "AUTO_RPC_SetCallback")
    AUTO_RPC_ProcessEvents  = GetFunction(AUTO_Library, "AUTO_RPC_ProcessEvents")
    
    AUTO_RPC_SetCallback(@AUTO_EventCallback())
  EndIf
  
  ProcedureReturn AUTO_Library
EndProcedure

Procedure AUTO_Shutdown()
  CloseLibrary(AUTO_Library)
EndProcedure

Procedure AUTO_RegisterEvent(Event$, Callback)
  Protected *Call = AUTO_RPC_NewCall("RegisterEvent", 1)
  Protected Result = #False
  If *Call
    AUTO_EventCallbacks(Event$) = Callback
    AUTO_RPC_SetString(*Call, 0, Event$)
    Result = AUTO_RPC_SendCall(*Call)
    AUTO_RPC_FreeCall(*Call)
  EndIf
  ProcedureReturn Result
EndProcedure

Procedure AUTO_UnregisterEvent(Event$)
  Protected *Call = AUTO_RPC_NewCall("UnregisterEvent", 1)
  Protected Result = #False
  If *Call
    AUTO_EventCallbacks(Event$) = Callback
    AUTO_RPC_SetString(*Call, 0, Event$)
    Result = AUTO_RPC_SendCall(*Call)
    AUTO_RPC_FreeCall(*Call)
  EndIf
  ProcedureReturn Result
EndProcedure

Macro AUTO_ProcessEvents(Timeout = -1)
  AUTO_RPC_ProcessEvents(Timeout)
EndMacro


Procedure AUTO_MenuCommand(Command$)
  Protected *Call = AUTO_RPC_NewCall("MenuCommand", 1)
  Protected Result = #False
  If *Call
    AUTO_RPC_SetString(*Call, 0, Command$)
    Result = AUTO_RPC_SendCall(*Call)
    AUTO_RPC_FreeCall(*Call)
  EndIf
  ProcedureReturn Result
EndProcedure



CompilerIf #PB_Compiler_Debugger
  
  Procedure AutoCompleteCallback(List Entries.s())
    Debug "have callback call"
    ForEach Entries()
      Debug Entries()
      Entries() + "XX"
    Next
  EndProcedure
  
  
  If AUTO_Initialize("C:\PureBasic\v4.60\SDK\Automation\Automation.dll")
    If AUTO_ConnectToAny()
      AUTO_RegisterEvent("AutoComplete", @AutoCompleteCallback())
      
      Debug AUTO_MenuCommand("Preferences")
      
      AUTO_ProcessEvents(100000)
      AUTO_Disconnect()
    Else
      Debug AUTO_LastError()
    EndIf
    
    AUTO_Shutdown()
  EndIf
  
CompilerEndIf