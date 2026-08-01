; --------------------------------------------------------------------------------------------
;  Copyright (c) Fantaisie Software. All rights reserved.
;  Dual licensed under the GPL and Fantaisie Software licenses.
;  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
; --------------------------------------------------------------------------------------------


;- Debugging options

; This value is a constant that selects the used communication interface
; NOTE: set this to one ONLY for debugging purposes!
;
; The No-Thread communication is slow and unresponsive (ie, while the GUI debugger is
; not reading data, the executable might lock), which is bad especially when multiple
; commands are being sent at once.
;
#NOTHREAD = 0

; For debugging:
; Set to 1 to get an output on the console whenever a command is sent/received
; Note: this is done with console, not debugger commands!
;
#PRINT_DEBUGGER_COMMANDS = 0

; For debugging:
; Set this to 1 and set a filename, and all communication (including sent data)
; is logged into that file. Set to 0 to disable
;
; Commands are logged as soon as the main thread processes them.
; So to debug a plugin directly, use #PRINT_DEBUGGER_COMMANDS
;
; NOTE: Works only reliable with one running debugger program
;   (in case of the IDE, do not start 2 debugging sessions in the IDE at once)
;
#LOG_DEBUGGER_COMMANDS = 0
#LOG_DEBUGGER_FILE     = "debug.log"

; Indicate that we are compiling the debugger (do not change this)
;
#PUREBASIC_DEBUGGER = 1

; The external debugger just has to tell the exe it endian-ness and the debugger.lib does all conversions
;
CompilerIf #PB_Compiler_Processor = #PB_Processor_PowerPC
  #DEBUGGER_BigEndian = #True
CompilerElse
  #DEBUGGER_BigEndian = #False
CompilerEndIf

#DEBUGGER_DefaultPort = 10101

;- Command data

; communication values
; see ExternalDebugger.c for a communications description

Structure CommandInfo
  Command.l
  Datasize.l
  Value1.l
  Value2.l
  TimeStamp.l
EndStructure

Structure CommandStackStruct
  Command.CommandInfo
  CommandData.i
EndStructure

; this is a special command constant, that doesn't come from the executable
; it is only sent internally from communication-thread to main thread to indicate
; a fatal error condition
; Value1 = 0 : no error
; Value1 = 1 : memory error
; Value1 = 2 : pipe error
; Value1 = 3 : exe quit unexpectedly (without #COMMAND_End)
; Value1 = 4 : exe start timeout reached
; Value1 = 5 : wrong exe version
; Value1 = 6 : Network connection failed
;
#COMMAND_FatalError = -1

#ERROR_None    = 0
#ERROR_Memory  = 1
#ERROR_Pipe    = 2
#ERROR_ExeQuit = 3
#ERROR_Timeout = 4
#ERROR_Version = 5
#ERROR_NetworkFail = 6

;- Commands: Debugger->executable
;
; For a detailed description see ExternalCommands.h in the debugger code
; Always keep these lists in sync!
;
Enumeration
  #COMMAND_Stop
  #COMMAND_Step
  #COMMAND_Run
  #COMMAND_BreakPoint
  #COMMAND_GetRegisterLayout
  #COMMAND_GetRegister
  #COMMAND_SetRegister
  #COMMAND_GetStack
  #COMMAND_GetMemory
  #COMMAND_GetGlobalNames
  #COMMAND_GetGlobals
  #COMMAND_GetLocals
  #COMMAND_GetArrayInfo
  #COMMAND_GetListInfo
  #COMMAND_GetMapInfo
  #COMMAND_GetArrayListData
  #COMMAND_GetHistory
  #COMMAND_GetHistoryLocals
  #COMMAND_GetProcedures
  #COMMAND_GetProcedureStats
  #COMMAND_ResetProcedureStats
  #COMMAND_WatchlistAdd
  #COMMAND_WatchlistRemove
  #COMMAND_GetWatchlist
  #COMMAND_GetLibraries
  #COMMAND_GetLibraryInfo
  #COMMAND_GetObjectText
  #COMMAND_GetObjectData
  #COMMAND_StartProfiler
  #COMMAND_StopProfiler
  #COMMAND_ResetProfiler
  #COMMAND_GetProfilerOffsets
  #COMMAND_GetProfilerData
  #COMMAND_EvaluateExpression
  #COMMAND_EvaluateExpressionWithStruct
  #COMMAND_SetVariable
  #COMMAND_WarningMode
  #COMMAND_Kill
  #COMMAND_GetFile
  #COMMAND_SetPurifier
  #COMMAND_GetModules
  
  #COMMAND_LastOutgoing
EndEnumeration

;- Commands: Executable->Debugger
;
Enumeration
  #COMMAND_Init
  #COMMAND_End
  #COMMAND_ExeMode
  #COMMAND_Stopped
  #COMMAND_Continued
  #COMMAND_Debug
  #COMMAND_DebugDouble
  #COMMAND_DebugQuad
  #COMMAND_Error
  #COMMAND_RegisterLayout
  #COMMAND_Register
  #COMMAND_Stack
  #COMMAND_Memory
  #COMMAND_GlobalNames
  #COMMAND_Globals
  #COMMAND_Locals
  #COMMAND_ArrayInfo
  #COMMAND_ArrayData
  #COMMAND_ListInfo
  #COMMAND_ListData
  #COMMAND_MapInfo
  #COMMAND_MapData
  #COMMAND_History
  #COMMAND_HistoryLocals
  #COMMAND_Procedures
  #COMMAND_ProcedureStats
  #COMMAND_WatchlistError
  #COMMAND_Watchlist
  #COMMAND_WatchlistEvent
  #COMMAND_Libraries
  #COMMAND_LibraryInfo
  #COMMAND_ObjectID
  #COMMAND_ObjectText
  #COMMAND_ObjectData
  #COMMAND_ProfilerOffsets
  #COMMAND_ProfilerData
  #COMMAND_Expression
  #COMMAND_SetVariableResult
  #COMMAND_Warning
  #COMMAND_DataBreakPoint
  #COMMAND_File
  #COMMAND_ControlDebugOutput
  #COMMAND_ControlProfiler
  #COMMAND_ControlMemoryViewer
  #COMMAND_ControlLibraryViewer
  #COMMAND_ControlWatchlist
  #COMMAND_ControlVariableViewer
  #COMMAND_ControlCallstack
  #COMMAND_ControlAssemblyViewer
  #COMMAND_ControlPurifier
  #COMMAND_Modules
  
  #COMMAND_LastIncoming
EndEnumeration

; For easier debugging of the debugger communications
; Don't forget to update this when the enumeration changes ;)
;
CompilerIf #PRINT_DEBUGGER_COMMANDS | #LOG_DEBUGGER_COMMANDS
  
  DataSection
    
    DebuggerCommands_Outgoing:
    Data$ "#COMMAND_Stop"
    Data$ "#COMMAND_Step"
    Data$ "#COMMAND_Run"
    Data$ "#COMMAND_BreakPoint"
    Data$ "#COMMAND_GetRegisterLayout"
    Data$ "#COMMAND_GetRegister"
    Data$ "#COMMAND_SetRegister"
    Data$ "#COMMAND_GetStack"
    Data$ "#COMMAND_GetMemory"
    Data$ "#COMMAND_GetGlobalNames"
    Data$ "#COMMAND_GetGlobals"
    Data$ "#COMMAND_GetLocals"
    Data$ "#COMMAND_GetArrayInfo"
    Data$ "#COMMAND_GetListInfo"
    Data$ "#COMMAND_GetMapInfo"
    Data$ "#COMMAND_GetArrayListData"
    Data$ "#COMMAND_GetHistory"
    Data$ "#COMMAND_GetHistoryLocals"
    Data$ "#COMMAND_GetProcedures"
    Data$ "#COMMAND_GetProcedureStats"
    Data$ "#COMMAND_ResetProcedureStats"
    Data$ "#COMMAND_WatchlistAdd"
    Data$ "#COMMAND_WatchlistRemove"
    Data$ "#COMMAND_GetWatchlist"
    Data$ "#COMMAND_GetLibraries"
    Data$ "#COMMAND_GetLibraryInfo"
    Data$ "#COMMAND_GetObjectText"
    Data$ "#COMMAND_GetObjectData"
    Data$ "#COMMAND_StartProfiler"
    Data$ "#COMMAND_StopProfiler"
    Data$ "#COMMAND_ResetProfiler"
    Data$ "#COMMAND_GetProfilerOffsets"
    Data$ "#COMMAND_GetProfilerData"
    Data$ "#COMMAND_EvaluateExpression"
    Data$ "#COMMAND_EvaluateExpressionWithStruct"
    Data$ "#COMMAND_SetVariable"
    Data$ "#COMMAND_WarningMode"
    Data$ "#COMMAND_Kill"
    Data$ "#COMMAND_GetFile"
    Data$ "#COMMAND_SetPurifier"
    Data$ "#COMMAND_GetModules"
    
    
    DebuggerCommands_Incoming:
    Data$ "#COMMAND_Init"
    Data$ "#COMMAND_End"
    Data$ "#COMMAND_ExeMode"
    Data$ "#COMMAND_Stopped"
    Data$ "#COMMAND_Continued"
    Data$ "#COMMAND_Debug"
    Data$ "#COMMAND_DebugDouble"
    Data$ "#COMMAND_DebugQuad"
    Data$ "#COMMAND_Error"
    Data$ "#COMMAND_RegisterLayout"
    Data$ "#COMMAND_Register"
    Data$ "#COMMAND_Stack"
    Data$ "#COMMAND_Memory"
    Data$ "#COMMAND_GlobalNames"
    Data$ "#COMMAND_Globals"
    Data$ "#COMMAND_Locals"
    Data$ "#COMMAND_ArrayInfo"
    Data$ "#COMMAND_ArrayData"
    Data$ "#COMMAND_ListInfo"
    Data$ "#COMMAND_ListData"
    Data$ "#COMMAND_MapInfo"
    Data$ "#COMMAND_MapData"
    Data$ "#COMMAND_History"
    Data$ "#COMMAND_HistoryLocals"
    Data$ "#COMMAND_Procedures"
    Data$ "#COMMAND_ProcedureStats"
    Data$ "#COMMAND_WatchlistError"
    Data$ "#COMMAND_Watchlist"
    Data$ "#COMMAND_WatchlistEvent"
    Data$ "#COMMAND_Libraries"
    Data$ "#COMMAND_LibraryInfo"
    Data$ "#COMMAND_ObjectID"
    Data$ "#COMMAND_ObjectText"
    Data$ "#COMMAND_ObjectData"
    Data$ "#COMMAND_ProfilerOffsets"
    Data$ "#COMMAND_ProfilerData"
    Data$ "#COMMAND_Expression"
    Data$ "#COMMAND_SetVariableResult"
    Data$ "#COMMAND_Warning"
    Data$ "#COMMAND_DataBreakPoint"
    Data$ "#COMMAND_File"
    Data$ "#COMMAND_ControlDebugOutput"
    Data$ "#COMMAND_ControlProfiler"
    Data$ "#COMMAND_ControlMemoryViewer"
    Data$ "#COMMAND_ControlLibraryViewer"
    Data$ "#COMMAND_ControlWatchlist"
    Data$ "#COMMAND_ControlVariableViewer"
    Data$ "#COMMAND_ControlCallstack"
    Data$ "#COMMAND_ControlAssemblyViewer"
    Data$ "#COMMAND_ControlPurifier"
    Data$ "#COMMAND_Modules"
    
  EndDataSection
  
CompilerEndIf


;- Debugger types

; Type value constants
;
#SCOPE_MAIN     = 0
#SCOPE_GLOBAL   = 1
#SCOPE_THREADED = 2
#SCOPE_LOCAL    = 3
#SCOPE_STATIC   = 4
#SCOPE_SHARED   = 5

#SCOPE_PARAMETER = 6  ; for the Watchlist only


#POINTERMASK    = 1 << 7
#PARAMMASK      = 1 << 6
#TYPEMASK       = $3F ; ~(#POINTERMASK|#PARAMMASK)
#IGNORE_POINTER = $7F ; ~#POINTERMASK
#IGNORE_PARAM   = $BF ; ~#PARAMMASK

Macro IS_POINTER(type)  : ((type) & #POINTERMASK): EndMacro
Macro IS_PARAMETER(type): ((type) & #PARAMMASK):   EndMacro

#TYPE_BYTE        =  1
#TYPE_WORD        =  3
#TYPE_LONG        =  5
#TYPE_STRUCTURE   =  7
#TYPE_STRING      =  8
#TYPE_FLOAT       =  9
#TYPE_FIXEDSTRING = 10
#TYPE_CHARACTER   = 11
#TYPE_DOUBLE      = 12
#TYPE_QUAD        = 13
#TYPE_INTEGER     = 21
#TYPE_LINKEDLIST  = 14
#TYPE_ARRAY       = 15
#TYPE_MAP         = 22
#TYPE_ASCII       = 24
#TYPE_UNICODE     = 25

#TYPE_MAX         = 25  ; maximum type value (without pointer/parameter bit)

; these will only work inside an If in PB
;
Macro IS_BYTE(type)       : (((type) & #TYPEMASK) = #TYPE_BYTE):        EndMacro
Macro IS_WORD(type)       : (((type) & #TYPEMASK) = #TYPE_WORD):        EndMacro
Macro IS_LONG(type)       : (((type) & #TYPEMASK) = #TYPE_LONG):        EndMacro
Macro IS_STRUCTURE(type)  : (((type) & #TYPEMASK) = #TYPE_STRUCTURE):   EndMacro
Macro IS_STRING(type)     : (((type) & #TYPEMASK) = #TYPE_STRING):      EndMacro
Macro IS_FLOAT(type)      : (((type) & #TYPEMASK) = #TYPE_FLOAT):       EndMacro
Macro IS_FIXEDSTRING(type): (((type) & #TYPEMASK) = #TYPE_FIXEDSTRING): EndMacro
Macro IS_CHARACTER(type)  : (((type) & #TYPEMASK) = #TYPE_CHARACTER):   EndMacro
Macro IS_DOUBLE(type)     : (((type) & #TYPEMASK) = #TYPE_DOUBLE):      EndMacro
Macro IS_QUAD(type)       : (((type) & #TYPEMASK) = #TYPE_QUAD):        EndMacro
Macro IS_INTEGER(type)    : (((type) & #TYPEMASK) = #TYPE_INTEGER):     EndMacro
Macro IS_LINKEDLIST(type) : (((type) & #TYPEMASK) = #TYPE_LINKEDLIST):  EndMacro
Macro IS_ARRAY(type)      : (((type) & #TYPEMASK) = #TYPE_ARRAY):       EndMacro
Macro IS_MAP(type)        : (((type) & #TYPEMASK) = #TYPE_MAP):         EndMacro
Macro IS_ASCII(type)      : (((type) & #TYPEMASK) = #TYPE_ASCII):       EndMacro
Macro IS_UNICODE(type)    : (((type) & #TYPEMASK) = #TYPE_UNICODE):     EndMacro


; Constants for the Mask of supported stuff in LibraryViewer:
;
#LIBRARYINFO_InfoOnly = $00000000 ;// only GetInfo() is implemented (GetInfo() must always be present!)
#LIBRARYINFO_Objects  = $00000001 ;// ExamineObjects() And NextObject() is implemented
#LIBRARYINFO_Text     = $00000002 ;// GetObjectText() is implemented
#LIBRARYINFO_Data     = $00000004 ;// GetObjectData() is implemented
#LIBRARYINFO_SwapData = $00000008 ;// SwapObjectData() is implemented

; Version of the DebuggerModule that this debugger was compiled
; for.. very important value.
; (Value2 of #COMMAND_Init)

; -> Now 2 (first v4 debugger with LibraryViewer)
; -> Now 3 (made some incompatible changes for use of expression parser)
; -> Now 4 (64bits changes)
; -> Now 5 (new communication methods with interfaces)
; -> Now 6 (Scope values changed in v4.40)
; -> Now 7 (network support and byte swapping)
; -> Now 8 (changes to control the debugger from code)
; -> Now 9 (changes for array, list, map in structure)
; -> Now 10 (changes for module support)
; -> Now 11 (changes for better module context when evaluating expressions)
; -> Now 12 (changes to support more included file in debugger (up to 8192))
#DEBUGGER_Version  = 12

; size of the stack for pending commands
; (a protection against overflow is in place)
;
#MAX_COMMANDSTACK = 800  ; make this big for good processing of many "Debug" statements

; Max number of (integer) registers in PB supported processors
; (currently 36 on POWERPC)
;
#MAX_REGISTERS = 36


; Helpers to get the line and the file from the debugger line (which includes both)
;
#DEBUGGER_DebuggerLineFileOffset = 20

Macro DebuggerLineGetLine(a)
  ((a) & ((1 << #DEBUGGER_DebuggerLineFileOffset)-1))
EndMacro

Macro DebuggerLineGetFile(a)
  (((a) >> #DEBUGGER_DebuggerLineFileOffset) & ((1 << (32-#DEBUGGER_DebuggerLineFileOffset))-1))
EndMacro

Macro MakeDebuggerLine(File, Line)
  ((File << #DEBUGGER_DebuggerLineFileOffset) | Line)
EndMacro

;- Communication interface

; the communication with the exe is generalized through this interface
;
; The DebuggerCommunication object is returned from the creation function
; for each implementation. From there all work the same on the outside.
; The object itself handles any threads, buffers, etc, so from the outside
; it looks like one command at a time only.
; (a buffer is required for good communication though, to ensure that the
;  exe does not hang while waiting for the IDE)
;
; - The Send() command does not set a timestamp etc. that must be done before the call.
; - Close() must handle the case where Connect() was not yet called too (for cleanup)
;
Interface Communication
  GetInfo.s()  ; get info string for the debugger exe (pipe handles, etc)
  Connect()    ; connect to exe (returns #true or #false)
  Disconnect() ; disconnect from exe (call before exe is termnated)
  Send(*Command.CommandInfo, *CommandData) ; send command (no returnvalue)
  Receive(*Command.CommandInfo, *pCommandData.INTEGER) ; receive command (returns #true if command received. errors go through as #COMMAND_FatalError)
  CheckErrors(*Command.CommandInfo, ProcessObject)     ; check for fatal errors (timeout/exe quit), return true on error
  Close()                                              ; free interface, call AFTER program is ended! (NO more calls allowed after this)
EndInterface

Structure CommunicationVtbl
  GetInfo.i
  Connect.i
  Disconnect.i
  Send.i
  Receive.i
  CheckErrors.i
  Close.i
EndStructure


;- GUI Constants

; menu constants used by the debugger
Enumeration
  #DEBUGGER_MENU_Return
  #DEBUGGER_MENU_Escape
  #DEBUGGER_MENU_WatchlistAdd
  #DEBUGGER_MENU_CopyVariable
  
  #DEBUGGER_MENU_ViewAll
  #DEBUGGER_MENU_ViewNonZero
  #DEBUGGER_MENU_ViewRange
  
  #DEBUGGER_MENU_Zoomin
  #DEBUGGER_MENU_Zoomout
  #DEBUGGER_MENU_File0
  #DEBUGGER_MENU_File255 = #DEBUGGER_MENU_File0+255
  
  #DEBUGGER_MENU_LAST ; after this, the IDE / standalone debugger can add additional shortcuts
EndEnumeration

#POPUPMENU_VariableViewer = 3  ; make sure this doesn't conflict with the IDE menus!
#POPUPMENU_ArrayViewer = 4     ; make sure this doesn't conflict with the IDE menus!
#POPUPMENU_Profiler = 7

; windows
; NOTE: there are offsets into the DebuggerData array
; the windows are all #PB_Any ones to have multiple running debuggers in the IDE
Enumeration
  #DEBUGGER_WINDOW_Network
  #DEBUGGER_WINDOW_Debug
  #DEBUGGER_WINDOW_Asm
  #DEBUGGER_WINDOW_Memory
  #DEBUGGER_WINDOW_Variable
  #DEBUGGER_WINDOW_History
  #DEBUGGER_WINDOW_WatchList
  #DEBUGGER_WINDOW_Library
  #DEBUGGER_WINDOW_Profiler
  #DEBUGGER_WINDOW_DataBreakPoints
  #DEBUGGER_WINDOW_Purifier
  
  #DEBUGGER_WINDOW_LAST ; last defined window (for structure size)
EndEnumeration


; gadgets (same as the windows)
Enumeration
  #DEBUGGER_GADGET_Network_Log
  #DEBUGGER_GADGET_Network_Abort
  #DEBUGGER_GADGET_Network_Password
  #DEBUGGER_GADGET_Network_Ok
  
  #DEBUGGER_GADGET_Debug_List
  #DEBUGGER_GADGET_Debug_Copy
  #DEBUGGER_GADGET_Debug_Clear
  #DEBUGGER_GADGET_Debug_Save
  #DEBUGGER_Gadget_Debug_Text
  #DEBUGGER_GADGET_Debug_Entry
  #DEBUGGER_GADGET_Debug_Display
  
  #DEBUGGER_GADGET_Asm_Panel
  #DEBUGGER_GADGET_Asm_Stack
  #DEBUGGER_GADGET_Asm_UpdateStack
  #DEBUGGER_GADGET_Asm_ScrollArea
  #DEBUGGER_GADGET_Asm_Message
  #DEBUGGER_GADGET_Asm_Text0
  #DEBUGGER_GADGET_Asm_TextMax = #DEBUGGER_GADGET_Asm_Text0 + #MAX_REGISTERS ; not all used, depending on the processor type
  #DEBUGGER_GADGET_Asm_Value0
  #DEBUGGER_GADGET_Asm_ValueMax = #DEBUGGER_GADGET_Asm_Value0 + #MAX_REGISTERS
  #DEBUGGER_GADGET_Asm_Set0
  #DEBUGGER_GADGET_Asm_SetMax = #DEBUGGER_GADGET_Asm_Set0 + #MAX_REGISTERS
  #DEBUGGER_GADGET_Asm_TextValue0
  #DEBUGGER_GADGET_Asm_TextValueMax = #DEBUGGER_GADGET_Asm_TextValue0 + #MAX_REGISTERS
  
  #DEBUGGER_GADGET_Memory_Text
  #DEBUGGER_GADGET_Memory_To
  #DEBUGGER_GADGET_Memory_Start
  #DEBUGGER_GADGET_Memory_End
  #DEBUGGER_GADGET_Memory_Display
  #DEBUGGER_GADGET_Memory_Editor
  #DEBUGGER_GADGET_Memory_Container
  #DEBUGGER_GADGET_Memory_List
  #DEBUGGER_GADGET_Memory_ViewType
  #DEBUGGER_GADGET_Memory_CopyText
  #DEBUGGER_GADGET_Memory_SaveText
  #DEBUGGER_GADGET_Memory_SaveRaw
  #DEBUGGER_GADGET_Memory_ChkformatDataSection
  #DEBUGGER_GADGET_Memory_Display_DataView
  
  #DEBUGGER_GADGET_Variable_Panel
  #DEBUGGER_GADGET_Variable_Splitter
  #DEBUGGER_GADGET_Variable_ProgressContainer
  #DEBUGGER_GADGET_Variable_Progress
  #DEBUGGER_GADGET_Variable_Global
  #DEBUGGER_GADGET_Variable_Local
  #DEBUGGER_GADGET_Variable_Update
  
  #DEBUGGER_GADGET_Variable_ArrayInfo
  #DEBUGGER_GADGET_Variable_LocalArrayInfo
  #DEBUGGER_GADGET_Variable_UpdateArray
  #DEBUGGER_GADGET_Variable_ArraySplitter
  
  #DEBUGGER_GADGET_Variable_ListInfo
  #DEBUGGER_GADGET_Variable_LocalListInfo
  #DEBUGGER_GADGET_Variable_UpdateList
  #DEBUGGER_GADGET_Variable_ListSplitter
  
  #DEBUGGER_GADGET_Variable_MapInfo
  #DEBUGGER_GADGET_Variable_LocalMapInfo
  #DEBUGGER_GADGET_Variable_UpdateMap
  #DEBUGGER_GADGET_Variable_MapSplitter
  
  #DEBUGGER_GADGET_Variable_Viewer
  #DEBUGGER_GADGET_Variable_AllItems
  #DEBUGGER_GADGET_Variable_NonZeroItems
  #DEBUGGER_GADGET_Variable_ItemRange
  #DEBUGGER_GADGET_Variable_InputRange
  #DEBUGGER_GADGET_Variable_InputName
  #DEBUGGER_GADGET_Variable_Container
  #DEBUGGER_GADGET_Variable_Text
  #DEBUGGER_GADGET_Variable_Display
  #DEBUGGER_GADGET_Variable_Copy
  #DEBUGGER_GADGET_Variable_Save
  #DEBUGGER_GADGET_Variable_ViewerProgress
  #DEBUGGER_GADGET_Variable_ViewerContainer
  
  #DEBUGGER_GADGET_History_Panel
  #DEBUGGER_GADGET_History_ScrollArea
  #DEBUGGER_GADGET_History_Update
  #DEBUGGER_GADGET_History_CurrentLine
  #DEBUGGER_GADGET_History_CurrentFile
  #DEBUGGER_GADGET_History_CurrentText
  #DEBUGGER_GADGET_History_CurrentContainer
  #DEBUGGER_GADGET_History_Updating
  #DEBUGGER_GADGET_History_Stats
  #DEBUGGER_GADGET_History_Reset
  #DEBUGGER_GADGET_History_ResetAll
  #DEBUGGER_GADGET_History_UpdateStats
  
  #DEBUGGER_GADGET_WatchList_List
  #DEBUGGER_GADGET_WatchList_Add
  #DEBUGGER_GADGET_WatchList_Remove
  #DEBUGGER_GADGET_WatchList_Clear
  #DEBUGGER_GADGET_WatchList_Procedure
  #DEBUGGER_GADGET_WatchList_Variable
  #DEBUGGER_GADGET_WatchList_Frame
  #DEBUGGER_GADGET_WatchList_Text1
  #DEBUGGER_GADGET_WatchList_Text2
  
  #DEBUGGER_GADGET_Breakpoint_List
  #DEBUGGER_GADGET_Breakpoint_Add
  #DEBUGGER_GADGET_Breakpoint_Remove
  #DEBUGGER_GADGET_Breakpoint_Clear
  #DEBUGGER_GADGET_Breakpoint_Procedure
  #DEBUGGER_GADGET_Breakpoint_Condition
  #DEBUGGER_GADGET_Breakpoint_Frame
  #DEBUGGER_GADGET_Breakpoint_Text1
  #DEBUGGER_GADGET_Breakpoint_Text2
  
  #DEBUGGER_GADGET_Library_Text1
  #DEBUGGER_GADGET_Library_LibraryList
  #DEBUGGER_GADGET_Library_ObjectList
  #DEBUGGER_GADGET_Library_ObjectText
  #DEBUGGER_GADGET_Library_ObjectData
  #DEBUGGER_GADGET_Library_ObjectData2
  #DEBUGGER_GADGET_Library_Container
  #DEBUGGER_GADGET_Library_Update
  #DEBUGGER_GADGET_Library_Splitter1
  #DEBUGGER_GADGET_Library_Splitter2
  
  #DEBUGGER_GADGET_Profiler_Start
  #DEBUGGER_GADGET_Profiler_Stop
  #DEBUGGER_GADGET_Profiler_Reset
  #DEBUGGER_GADGET_Profiler_Update
  #DEBUGGER_GADGET_Profiler_Container
  #DEBUGGER_GADGET_Profiler_Splitter
  #DEBUGGER_GADGET_Profiler_Files
  #DEBUGGER_GADGET_Profiler_Canvas
  ;#DEBUGGER_GADGET_Profiler_Preview
  #DEBUGGER_GADGET_Profiler_ScrollX
  #DEBUGGER_GADGET_Profiler_ScrollY
  #DEBUGGER_GADGET_Profiler_Zoomin
  #DEBUGGER_GADGET_Profiler_Zoomout
  #DEBUGGER_GADGET_Profiler_Zoomall
  #DEBUGGER_GADGET_Profiler_Drag
  #DEBUGGER_GADGET_Profiler_Select
  #DEBUGGER_GADGET_Profiler_Cross
  
  #DEBUGGER_GADGET_Purifier_Frame
  #DEBUGGER_GADGET_Purifier_TextGlobal
  #DEBUGGER_GADGET_Purifier_TrackbarGlobal
  #DEBUGGER_GADGET_Purifier_LinesGlobal
  #DEBUGGER_GADGET_Purifier_TextLocal
  #DEBUGGER_GADGET_Purifier_TrackbarLocal
  #DEBUGGER_GADGET_Purifier_LinesLocal
  #DEBUGGER_GADGET_Purifier_TextString
  #DEBUGGER_GADGET_Purifier_TrackbarString
  #DEBUGGER_GADGET_Purifier_LinesString
  #DEBUGGER_GADGET_Purifier_TextDynamic
  #DEBUGGER_GADGET_Purifier_TrackbarDynamic
  #DEBUGGER_GADGET_Purifier_LinesDynamic
  #DEBUGGER_GADGET_Purifier_Ok
  #DEBUGGER_GADGET_Purifier_Cancel
  #DEBUGGER_GADGET_Purifier_Apply
  
  #DEBUGGER_GADGET_LAST
EndEnumeration

; private drag value for profiler
;
#DRAG_Profiler = 0

;- DebuggerData Structure

; general local array of basic tyles
Structure Local_Array
  StructureUnion
    l.l[0]
    w.w[0]
    b.b[0]
    f.f[0]
    d.d[0]
    q.q[0]
    i.i[0]
    *p.Local_Array[0]
  EndStructureUnion
EndStructure

; structure for DataBreakPoints (its a linked list)
Structure DataBreakPoint
  *Next.DataBreakPoint
  *Previous.DataBreakPoint
  
  Condition$
  ProcedureName$
  ConditionTrue.l ; set to true when the breakpoint should be removed
  ID.l
EndStructure

; Representation of one debuged program
; the standalone will have only one such structure
; the IDE will create one for each executed program

Structure DebuggerData
  ID.i               ; unique ID to identify this debugger (unique while the IDE/debugger runs)
  
  ProcessObject.i    ; Process lib object for running exe (all OS now)
  
  CompilerIf #CompileWindows
    TerminationMutex.i ; mutex used to terminate the debugged program
  CompilerEndIf
  
  IsUnicode.l   ; unicode mode of the executable
  IsThread.l    ; thread mode of the executable
  Is64bit.l     ; is the executable a 64bit one ?
  IsPurifier.l  ; is the purifier enabled ?
  
  IsNetwork.l   ; true if the communication is network based
  Communication.Communication ; communication interface
  Command.CommandInfo         ; last processed incoming command (for easy access)
  *CommandData                ; pointer to any additional command data (for last processed command)
  
  FileName$           ; real source file as opposed to what is in the executable (something like /tmp/PB_EditorOutput.pb)
  NbIncludedFiles.l   ; nb of included sources
  *IncludedFiles      ; buffer with all filenames
  
  NbProcedures.l      ; number of procedures in this source
  *Procedures         ; buffer containing the procedure names
  
  ProgramState.l     ; PB_DEBUGGER_Control value (-1 = exe not loaded)
  LastProgramState.l ; Programstate after the last received command (that altered ProgramState!)
  ProgramEnded.l     ; On linux, we get a pipe error directly after the end command, so use a flag to ignore it then
  
  CanDestroy.l       ; the strcture is flagged for destructuion, only wait for all windows to be closed
  
  IsDebugOutputVisible.l ; special flag indicating if the debug output is visible or not
  IsWatchlistVisible.l   ; special flag indicating the watchlist state (as the window is always open, but invisible)
  DataBreakpointsVisible.l ; spechial flag indicating the state (we do not close it so we do not have to keep the breakpoint list in a separate place)
  
  *FirstDataBreakPoint.DataBreakPoint
  
  ArraySortColumn.b      ; sorting settings for VariableViewer Array/List info gadgets
  ArraySortDirection.b
  LocalArraySortColumn.b
  LocalArraySortDirection.b
  ListSortColumn.b
  ListSortDirection.b
  LocalListSortColumn.b
  LocalListSortDirection.b
  MapSortColumn.b
  MapSortDirection.b
  LocalMapSortColumn.b
  LocalMapSortDirection.b
  
  RegisterCount.l                  ; number of registers in processor
  RegisterIndex.l[#MAX_REGISTERS]  ; indexes in register array (high bit set if there is a text representation)
  RegisterName$[#MAX_REGISTERS]    ; register names for display
  
  *MemoryDump        ; currently displayed memory dump of the memory viewer
  MemoryDumpSize.i   ; size of the memory dump
  MemoryDumpStart.q  ; start address of the dump (in the exe memory)
  
  HistorySize.l      ; size of procedure history
  *History           ; pointer to the procedure history data
  
  NbLibraries.l      ; number of libraries registered with LibraryDebugger
  *LibraryList       ; pointer to list of registered libraries
  NbLibColumns.l     ; Number of columns currently in the ListIconGadget
  NbObjects.l        ; number of objects in the currently displayed library
  *ObjectList        ; pointer to array of object IDs LONG or QUAD, depending on exe mode!
  CurrentLibrary.l   ; Index of the currently displayed lib
  CurrentObject.l    ; Index of the currently displayed object
  CurrentObjectID.q  ; ObjectID of the currently displayed object
  CommandObjectID.q  ; ObjectID as sent by the COMMAND_ObjectID command
  *CurrentObjectData ; Currently displayed Object Data number (for the plugin)
  
  ProfilerRunning.l  ; state of the profiler
  *ProfilerFiles     ; Debugger_ProfilerList pointer with per-file info
  *ProfilerData      ; array of longs with counts for ALL includefiles
                     ;ProfilerPreview.i ; preview image
  ProfilerNumberLength.l ; length of the linenumbers part of the display (in digits)
  ProfilerRatioX.d       ; scale factor x
  ProfilerRatioY.d       ; scale factor y
  
  CompilerIf #CompileWindows
    ProfilerScrollCallback.i
  CompilerEndIf
  
  PurifierGlobal.l   ; purifier granularities (0 = disable)
  PurifierLocal.l
  PurifierString.l
  PurifierDynamic.l
  
  OutputStatusbar.i    ; status bar on Debugger output window
  OutputFirstVisible.l ; true as long as the debug output was not shown yet
  
  IsDebugMessage.l     ; Flag which indicate if there is a debug message to display
  DebugMessage$        ; Cached debug output message
  
  NbModules.l          ; module names
  Array ModuleNames.s(0)
  
  ;
  ; stuff only used by the IDE debugger
  ; ===================================================
  ;
  SourceID.i         ; unique ID of the main source (if any)
  TriggerTargetID.i  ; unique ID of the target that triggered the compile (not necessarily the main file!)
  
  ;   *SourceFile.l   ; pointer to associated sourcefile structure if any
  ;   *CompileSource.l; the source that triggered the compile (not necessarily the main file!)
  ;
  ;   CPUUsage.l     ; last polled cpu usage value (in %)
  ;   CPUOldUsage.l  ; previous polled cpu usage value
  ;   CPUDisplay.l   ; is displayed in graph?
  ;
  ;   CPUTime.l      ; last polled cpu time value  (in jiffers!) on windows, only indicates if RealCPUTime is valid (-1 = invalid, 1=valid)
  ;
  ;   CompilerIf #CompileWindows
  ;     RealCPUTime.LARGE_INTEGER ; real value for windows cpu monitor
  ;   CompilerEndIf
  ;
  ; ===================================================
  ;
  
  ;
  ; larger data arrays
  ;
  Windows.i[#DEBUGGER_WINDOW_LAST]  ; associated windows
  Gadgets.i[#DEBUGGER_GADGET_LAST]  ; associated gadgets
  
EndStructure

;- Other Structures



Structure Debugger_HistoryData
  Container.i  ; outside container gadget
  Line.i       ; textgadget showing called line
  File.i       ; textgadget showing called file
  Show.i       ; toggle button "show variables"
  Call.i       ; stringgadget showing procedure call
  Variables.i  ; VariableGadget for local variables
EndStructure

Structure Debugger_History
  item.Debugger_HistoryData[0]
EndStructure

Structure Debugger_LibraryData
  LibraryID$
  Name$
  TitleString$
  FunctionMask.l
EndStructure

Structure Debugger_LibraryList
  library.Debugger_LibraryData[0]
EndStructure

; info about a profiler file entry
Structure Debugger_ProfilerData
  Offset.l     ; first line in the big array
  Size.l       ; number of lines in this file
  Color.l      ; color for display
  ColorImage.i ; #PB_Any image for the color box
EndStructure

Structure Debugger_ProfilerList
  file.Debugger_ProfilerData[0]
EndStructure

; structure containing the procedure stats
;
Structure ProcedureStats_List
  callcount.l[0]
EndStructure


;- Global data

Global PureBasicPath$, DebuggerOutputFile$, MemoryViewerFile$

; Linux/Mac only: use a FIFO instead of a normal Pipe
;
Global DebuggerUseFIFO

; common preferences in ide and debugger
;
Global LogTimeStamp
Global CallDebuggerOnStart, CallDebuggerOnEnd
Global DebuggerMemorizeWindows, DebuggerOnTop, DebuggerBringToTop
Global EditorFontID ; for all editorgadgets

; communication timeout
Global DebuggerTimeout

Global DebuggerMainWindow ; windowid of the main debugger window (if any. the ide has none)

; the main window prefs are loaded/saved by the IDE too, so they do not get lost
Global DebuggerMainWindowX, DebuggerMainWindowY, DebuggerMainWindowWidth, DebuggerMainWindowHeight
Global IsDebuggerMaximized, IsMiniDebugger

; debug output window
Global DebugIsHex, DebugTimeStamp
Global DebugWindowX, DebugWindowY, DebugWindowWidth, DebugWindowHeight, DebugWindowMaximize
Global DebugSystemMessages ; windows/linux only
Global DebugOutputToErrorLog

; asm debug window
Global RegisterIsHex, StackIsHex, AutoStackUpdate
Global AsmWindowX, AsmWindowY, AsmWindowWidth, AsmWindowHeight, AsmWindowMaximize

; memory viewer
Global MemoryDisplayType, MemoryIsHex, MemoryOneColumnOnly
Global MemoryViewerX, MemoryViewerY, MemoryViewerWidth, MemoryViewerHeight
Global MemoryViewerMaximize

; variable viewer
Global VariableIsHex
Global VariableWindowX, VariableWindowY, VariableWindowWidth, VariableWindowHeight
Global VariableViewerMaximize

; history window
Global HistoryWindowX, HistoryWindowY, HistoryWindowWidth, HistoryWindowHeight
Global HistoryMaximize

; watchlist window
Global WatchListWindowX, WatchListWindowY, WatchListWindowWidth, WatchListWindowHeight, WatchListWindowMaximize

; library viewer
Global LibraryViewerX, LibraryViewerY, LibraryViewerWidth, LibraryViewerHeight
Global LibraryViewerSplitter1, LibraryViewerSplitter2
Global LibraryViewerMaximize

; profiler
Global ProfilerX, ProfilerY, ProfilerWidth, ProfilerHeight, ProfilerSplitter
Global ProfilerRunAtStart, ProfilerMaximize

; data breakpoints
Global DataBreakpointWindowX, DataBreakpointWindowY, DataBreakpointWindowWidth, DataBreakpointWindowHeight
Global DataBreakpointWindowMaximize

; purifier config (not resizable)
Global PurifierWindowX, PurifierWindowY

Global AutoOpenDebugOutput, AutoOpenAsmWindow, AutoOpenMemoryViewer, AutoOpenVariableViewer
Global AutoOpenHistory, AutoOpenWatchlist, AutoOpenLibraryViewer, AutoOpenProfiler, AutoOpenDataBreakpoints
Global AutoOpenPurifier

Global EnableMenuIcons ; from IDE settings (for profiler popup menu)

CompilerIf #SpiderBasic
  Global *WebViewDebugger.DebuggerData
CompilerEndIf


Global NewList RunningDebuggers.DebuggerData()

;- Procedure declarations

; this defines a callback that is called on each command
; received from the executable
Declare DebuggerCallback(*Debugger.DebuggerData)

; this must be implemented by both debuggers
; loads the given file and marks the given line with the cursor (no other marks)
; (currently used by profiler)
Declare Debugger_ShowLine(*Debugger.DebuggerData, Line)

; this must be implemented by both debuggers.
; It may only process window events, it MUST NOT call Debugger_ProcessIncomingCommands() again! (re-entry problems!)
Declare FlushEvents()

; this defines a callback that is called for each debugger window that is opened
; it allows IDE / standalone to add more shortcuts to each window (or do other tasks)
Declare Debugger_AddShortcuts(Window)

Declare SendDebuggerCommandWithData(*Debugger.DebuggerData, *Command.CommandInfo, *CommandData)
Declare SendDebuggerCommand(*Debugger.DebuggerData, *Command.CommandInfo)


Declare Debugger_UpdateWindowStates(*Debugger.DebuggerData)
Declare Debugger_ProcessEvents(EventWindowID, EventID)

Declare DebugOutput_DebuggerEvent(*Debugger.DebuggerData)
Declare AsmDebug_DebuggerEvent(*Debugger.DebuggerData)
Declare MemoryViewer_DebuggerEvent(*Debugger.DebuggerData)
Declare VariableDebug_DebuggerEvent(*Debugger.DebuggerData)
Declare History_DebuggerEvent(*Debugger.DebuggerData)
Declare WatchList_DebuggerEvent(*Debugger.DebuggerData)
Declare LibraryViewer_DebuggerEvent(*Debugger.DebuggerData)
Declare Profiler_DebuggerEvent(*Debugger.DebuggerData)
Declare DataBreakpoint_DebuggerEvent(*Debugger.DebuggerData)
Declare Purifier_DebuggerEvent(*Debugger.DebuggerData)

Declare OpenDebugWindow(*Debugger.DebuggerData, ActivateWindow)
Declare OpenAsmWindow(*Debugger.DebuggerData)
Declare OpenMemoryViewerWindow(*Debugger.DebuggerData)
Declare OpenVariableWindow(*Debugger.DebuggerData)
Declare OpenHistoryWindow(*Debugger.DebuggerData)
Declare OpenWatchListWindow(*Debugger.DebuggerData)
Declare OpenLibraryViewerWindow(*Debugger.DebuggerData)
Declare OpenProfilerWindow(*Debugger.DebuggerData)
Declare OpenDataBreakpointWindow(*Debugger.DebuggerData)
Declare OpenPurifierWindow(*Debugger.DebuggerData)

Declare UpdateDebugOutputWindow(*Debugger.DebuggerData)

Declare CreateWatchlistWindow(*Debugger.DebuggerData)
Declare CreateDebugWindow(*Debugger.DebuggerData)
Declare CreateDataBreakpointWindow(*Debugger.DebuggerData)
Declare LibraryViewer_Init()
Declare.s ScopeName(scope, type = 0)
Declare.s ModuleName(Name$, ModuleName$)

Declare ApplyDefaultPurifierOptions(*Debugger.DebuggerData, OptionString$)
Declare.s GetPurifierOptions(*Debugger.DebuggerData)

; a little hack to free PB created strings
; (to remove them from a allocatet memory buffer for example)
; what it does is poke the pointer into that structure and
; the SYS_FreeStructureStrings will then free it at the procedure end
;
Procedure FreePBString(ptrString)
  Protected String.STRING
  PokeI(@String, ptrString)
EndProcedure

CompilerIf Defined(PUREBASIC_IDE, #PB_Constant) = 0 ; only define if it is the standalone debugger
                                                    ; required stuff for the Highlighting Engine
  Structure SourceFileParser
    Encoding.l
  EndStructure
  
  Structure SourceFile
    EnableASM.l
    DebuggerData.i
    Parser.SourceFileParser
  EndStructure
  
  Procedure AddTools_Execute(Trigger, *Source.SourceFile)
  EndProcedure
  
  Procedure ChangeStatus(Message$)
  EndProcedure
  
  Procedure.s GenerateQuickHelpText(Word$)
  EndProcedure
  
  #FILE_LoadFunctions = 0
  #FILE_LoadAPI = 1
CompilerEndIf


