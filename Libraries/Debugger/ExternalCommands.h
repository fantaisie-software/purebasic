/* === Copyright Notice ===
 *
 *
 *                  PureBasic source code file
 *
 *
 * This file is part of the PureBasic Software package. It may not
 * be distributed or published in source code or binary form without
 * the expressed permission by Fantaisie Software.
 *
 * By contributing modifications or additions to this file, you grant
 * Fantaisie Software the rights to use, modify and distribute your
 * work in the PureBasic package.
 *
 *
 * Copyright (C) 2000-2010 Fantaisie Software - all rights reserved
 *
 */



/* Note: Keep the comments in this file up to date as it is the only documentation
 *   for the individual debugger commands!
 *
 *   Keep this file in sync with DebuggerCommon.pb in the external debugger source.
 */



/* =======================================================================================
 *                             Commands sent from Debugger to Executable
 * =======================================================================================
 */


enum
{

  /* Command: Stop the program execution
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_Stop,

  /* Command: Step mode
   *
   *  Value1: Nb of steps to do (-1=step over, -2=step out)
   *  Value2:
   *    Data:
   */
  COMMAND_Step,

  /* Command: Continue program
   *
   *  Value1: if 1, there is a COMMAND_Continued sent in response, if 0, there isn't
   *  Value2:
   *    Data:
   */
  COMMAND_Run,

  /* Command: Manage breakpoints
   *
   *  Value1: action
   *      1 = set line breakpoint     (Value2 = line)
   *      2 = remove                  (Value2 = line)
   *      3 = clear all               (Value2 = file number, -1 for all files)
   *      4 = add data breakpoint     (Value2 = Procedure Index, -1=main code, -2=all code; DATA=Condition string, external format)
   *      5 = remove data breakpoint  (Value2 = BreakPointID)
   *      6 = clear data breakpoints
   *  Value2:
   *    Data:
   */
  COMMAND_BreakPoint,

  /* Command: Request register names and alayout
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetRegisterLayout,

  /* Command: Request register values
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetRegister,

  /* Command: Set a register
   *
   *  Value1: register index
   *  Value2:
   *    Data: new value (32bit or 64bit)
   */
  COMMAND_SetRegister,

  /* Command: Request stack trace
   *
   *  Value1: IsHexDisplay
   *  Value2:
   *    Data:
   */
  COMMAND_GetStack,

  /* Command: Request memory dump
   *
   *  Value1: 1 if endaddress relative to startaddress, 0 else
   *  Value2:
   *    Data: STRING(startaddr) NULL String(endaddr) NULL  (external format)
   */
  COMMAND_GetMemory,

  /* Command: Request name list of global variables
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetGlobalNames,

  /* Command: Request values of global variables
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetGlobals,

  /* Command: Request local variable name/values
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetLocals,

  /* Command: Request list of Arrays
   *
   *  Value1: IsGlobal
   *  Value2:
   *    Data:
   */
  COMMAND_GetArrayInfo,

  /* Command: Request list of LinkedLists
   *
   *  Value1: IsGlobal
   *  Value2:
   *    Data:
   */
  COMMAND_GetListInfo,

  /* Command: Request list of Maps
   *
   *  Value1: IsGlobal
   *  Value2:
   *    Data:
   */
  COMMAND_GetMapInfo,

  /* Command: Request Array, List, Map data
   *
   *  Value1: Range (0=all, 1=non-zero only, 2=range)
   *  Value2: PreferGlobal
   *    Data: name+null (range+null if Value=2), external format
   *          - name MUST include "()" at the end!, name can be an expression, range has to be numbers
   *          - name MUST include a module prefix if the object is inside a module
   */
  COMMAND_GetArrayListData,

  /* Command: Request Procedure history
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetHistory,

  /* Command: Request local variables of the history
   *
   *  Value1: Callstack index
   *  Value2:
   *    Data:
   */
  COMMAND_GetHistoryLocals,

  /* Command: Request procedure list
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetProcedures,

  /* Command: Request procedure statistics
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetProcedureStats,

  /* Command: Reset procedure statistics
   *
   *  Value1: procedure index (-1 = all procedures)
   *  Value2:
   *    Data:
   */
  COMMAND_ResetProcedureStats,

  /* Command: Add variable to watchlist
   *
   *  Value1: Procedure index (-1 = Global)
   *  Value2:
   *    Data: Variable name/constant expression (UTF8)
   */
  COMMAND_WatchlistAdd,

  /* Command: Remove a variable from the watchlist
   *
   *  Value1: index (-1 = remove all)
   *  Value2:
   *    Data:
   */
  COMMAND_WatchlistRemove,

  /* Command: Get the full watchlist content
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetWatchlist,

  /* Command: Request list of registered libraries
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetLibraries,

  /* Command: Request the library object list
   *
   *  Value1: index in library table
   *  Value2:
   *    Data:
   */
  COMMAND_GetLibraryInfo,

  /* Command: Request text info about an object
   *
   *  Value1: library index
   *  Value2:
   *    Data: INTEGER: ObjectID
   */
  COMMAND_GetObjectText,

  /* Command: Request data of an object
   *
   *  Value1: library index
   *  Value2:
   *    Data: INTEGER: ObjectID
   */
  COMMAND_GetObjectData,

  /* Command: Start profiler counting
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_StartProfiler,

  /* Command: Stop profiler counting
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_StopProfiler,

  /* Command: Reset profiler counts
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_ResetProfiler,

  /* Command: Request profiler line offset array (with start index of each source file)
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetProfilerOffsets,

  /* Command: Request line count data array
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetProfilerData,

  /* Command: Evaluate expression (no structures are returned)
   *
   *  Value1: sender id (echoed back on response)
   *  Value2: line number for evaluation context (-1 for current line)
   *    Data: request string (external format)
   */
  COMMAND_EvaluateExpression,

  /* Command: Evaluate expression (allows structures in the result)
   *
   *  Value1: sender id (echoed back on response)
   *  Value2: line number for evaluation context (-1 for current line)
   *    Data: request string (external format)
   */
  COMMAND_EvaluateExpressionWithStruct,

  /* Command: Set a variable to a new value
   *
   *  Value1: sender id (echoed back)
   *  Value2: line number for evaluation context (-1 for current line)
   *    Data: STRING: lhs + NULL + rhs + NULL (external format, both can be expressions)
   */
  COMMAND_SetVariable,

  /* Command: Change the warning mode
   *
   *  Value1: mode
   *     1 = ignore
   *     2 = show warning
   *     3 = treat as error
   *  Value2:
   *    Data:
   */
  COMMAND_WarningMode,

  /* Command: Instruct the executable to quit (Network mode only, done directly in pipe mode)
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_Kill,

  /* Command: Request a file to be sent to the debugger (Network mode only)
   *
   *  Value1: file index
   *  Value2:
   *    Data:
   */
  COMMAND_GetFile,

  /* Command: Set the purifier intervals
   *  Value1:
   *  Value2:
   *    Data: 4x LONG (Global, Local, String, Dynamic) A value of 0 means check never
   */
  COMMAND_SetPurifier,

  /* Command: Get list of modules
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_GetModules,
};



/* =======================================================================================
 *                             Commands sent from Executable to Debugger
 * =======================================================================================
 */


enum
{

  /* Command: Indicate that exe is initialized
   *
   *  Value1: NbIncludeFiles
   *  Value2: DEBUGGER_Version
   *    Data: sourcepath + mainfilename + all inc files (ascii)
   *
   * NOTE: you have to send a COMMAND_Run after that to make the executable even run!
   */
  COMMAND_Init,


  /* Command: Indicate that the program ended
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_End,


  /* Command: Indicete the mode of the executable
   *
   *  Value1: Bitfield
   *   Bit0 = IsUnicode
   *   Bit1 = IsThread
   *   Bit2 = Is64Bit
   *   Bit3 = IsPurifier
   *  Value2:
   *   LowWord = Processor (1=x86,2=x64,3=ppc)
   *   HiWord  = OS (1=Windows,2=Linux, 3=OSX)
   *    Data:
   */
  COMMAND_ExeMode,


  /* Command: Indicate that the program stopped
   *
   *  Value1: LineNumber
   *  Value2: PB_DEBUGGER_Control
   *    Data:
   */
  COMMAND_Stopped,


  /* Command: Indicate that the code is running again
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_Continued,


  /* Command: Send a value to debug output
   *
   *  Value1: type (5=long,8=string,9=float)
   *  Value2: Value
   *    Data: String Value if format=8 (external format)
   */
  COMMAND_Debug,


  /* Command: Debug a double value
   *
   *  Value1: double value
   *  Value2: high bytes of double value
   *    Data:
   */
  COMMAND_DebugDouble,


  /* Command: Debug a quad value
   *
   *  Value1: quad value
   *  Value2: high bytes of quad value
   *    Data:
   */
  COMMAND_DebugQuad,


  /* Command: The program stopped because of an error
   *
   *  Value1: LineNumber
   *  Value2: PB_DEBUGGER_Control
   *    Data: Message (ascii)
   *
   * NOTE: this always stops the program until a COMMAND_Run
   */
  COMMAND_Error,


  /* Command: Information about register names and layout of data in COMMAND_Register
   *
   *  Value1: count of registers
   *  Value2:
   *    Data:
   *     Array of WORD
   *       for each display name below, the real index in the registers array
   *       if high bit set (1<<15), then the register has a string representation (flags, condition, etc)
   *     Array of STRING
   *       register display names
   *
   *     The order of registers in the display can differ from the order in the array,
   *     that's why the WORD array tells the real order
   */
  COMMAND_RegisterLayout,


  /* Command: Send register values
   *
   *  Value1: are registers writable?
   *  Value2:
   *    Data: Regieter values (if DataSize=0: no register access)
   *     Array of INTEGER: register values
   *     Array of STRING: for each register with string representation: its string
   */
  COMMAND_Register, // send registers. Value1=are registers writable? if DataSize=0, no register access, otherwise DATA=array of register values.


  /* Command: Send a stack trace
   *
   *  Value1:
   *  Value2:
   *    Data: trace in text format, or message if stack is empty. No data if no access to registers
   */
  COMMAND_Stack,


  /* Command: Send a memory dump
   *
   *  Value1: Start address as quad (0 on error)
   *  Value2: high bytes of start address
   *    Data: raw memory, or error message (ascii)
   */
  COMMAND_Memory,


  /* Command: Send global variable names and types
   *
   *  Value1: NbVariables in the source
   *  Value2: NbVariables, counting each structure field individually (=number of sent entries)
   *    Data:
   *
   *    for each transmitted entry:
   *    BYTE: type (1=byte,3=word,5=long,7=structure,8=string,9=float,10=fixed,11=char,12=double,13=quad,21=integer)  (bit 7 is set when the variable is a pointer)
   *    BYTE: dynamictype (real type if type=TYPE_ARRAY etc for structured items. not used otherwise)
   *    BYTE: scope (0=main, 1=global, 2=threaded)
   *    LONG: sublevel (usually 0 except for structure members)
   *    STRING: name (0-terminated) (for structures includes the structure name, for array, list, map does not include the ())
   *    STRING: module name (0-terminated) (empty for structure members)
   *
   *    For a structure, you get one entry for each structure field, the "sublevel" value
   *    indicates how deep into the structure we are
   *    Example:
   *
   *    Structure Test
   *      Value1.l
   *      Value2.s
   *      structure.LONG
   *      Value3.w
   *    EndStructure
   *
   *    variable.Test
   *    test$
   *
   *    result:
   *
   *    7, 0, 0, "variable.test"
   *    5, 0, 1, "Value1"
   *    8, 0, 1, "Value2"
   *    7, 0, 1, "structure.LONG"
   *    5, 0, 2, "l"   <- content of the LONG structure
   *    3, 0, 1, "Value3"
   *    8, 0, 0, "test$"
   */
  COMMAND_GlobalNames,


  /* Command: Send global variables content
   *
   *  Value1: number of global variables
   *  Value2: number of transmied entries (see above)
   *    Data:
   *
   *    each entry looks like this:
   *    BYTE: type (see above)
   *    <-- variable value --> (whatever type that is)
   *
   *    if type = 7 (structure, no pointer) then there is no value
   *    (since the structure name obviously has no value)
   *
   *    for dynamic array: The value is a string giving the dimensions without () (ascii)
   *    for dynamic list: The value is INTEGER:INTEGER (size, current element)
   *    for dynamic map: The value is INTEGER:BYTE (:STRING) (size, iscurrentkey, current key (if any, in external format))
   */
  COMMAND_Globals, // send global variables


  /* Command: Send local variable names + values
   *
   *  Value1: index of the Procedure in the procedure bank
   *  Value2: number of transmitted values
   *    Data:
   *
   *    same as for the global names, except the structure is this:
   *    BYTE: type
   *    BYTE: dynamictype (real type if type=TYPE_ARRAY etc for structured items. not used otherwise)
   *    BYTE: scope
   *    LONG: sublevel
   *    STRING: name
   *    <--- variable value --->
   *    if type = 7 (structure, no pointer) then there is no value
   */
  COMMAND_Locals,


  /* Command: Send a list of arrays in the source
   *
   *  Value1: IsGlobal (Note: globals includes main and threaded!)
   *  Value2:number of arrays
   *    Data:
   *
   *    Foreach Array:
   *      STRING: name (if structured array, including .Type)
   *      STRING: module name
   *      STRING: dimensions (in form "(5, 1, 2)"
   *      BYTE: type
   *      BYTE: scope
   */
  COMMAND_ArrayInfo,


  /* Command: Send content of an array
   *
   *  Value1: array type
   *  Value2: Nb of returned items (includes structure subitems!)
   *    Data:
   *
   *    if there was an error, Value1 = 0, DATA= error message.
   *
   *    DATA:
   *    STRING: name of the array (example: "MyArray() or MyVAr\SubList()", echoed back from input) (external format)
   *
   *    If (type = 7) (structure, no pointer)
   *      there is a structuremap before the actual data
   *      Repeat
   *        BYTE: type (-1 = end of structure)
   *        BYTE: dynamictype (real type if type=TYPE_ARRAY etc for structured items. not used otherwise)
   *        LONG: sublevel (will always be > 0)
   *        STRING: item name
   *      Until type = -1
   *    EndIf
   *
   *    Foreach Returned entry
   *      If COMMAND_ArrayData
   *        STRING: index of current item (example: "5, 1, 4")
   *      EndIF
   *      IF COMMAND_ListData
   *        INTEGER: current item index
   *      EndIf
   *      IF COMMAND_MapData
   *        STRING: current item key (external string format)
   *      EndIf
   *      Entry data
   *      // NOTE: fixedlengt strings are passed normal as zero-terminated ones
   *      // NOTE: for a structured list/array/map, is the same as with global variables
   *    Next
   */
  COMMAND_ArrayData,


  /* Command: Send list of LinkedLists in the code
   *
   *  Value1: IsGlobal (Note: globals includes main and threaded!)
   *  Value2: number of lists
   *    Data:
   *
   *    ForEach List:
   *      STRING: name (if structured, includes type)
   *      STRING: module name
   *      BYTE: type
   *      BYTE: scope
   *      INTEGER: size  (0 = empty, -1 = uninitialized (NewList not yet called))
   *      INTEGER: current (-1 = no current element)
   */
  COMMAND_ListInfo, // send list of linkedlists in the source


  /* Command: Send the content of a linked list
   *
   *  See COMMAND_ArrayData for command structure
   */
  COMMAND_ListData,


  /* Command: Send list of Maps in the code
   *
   *  Value1: IsGlobal (Note: globals includes main and threaded!)
   *  Value2: number of maps
   *    Data:
   *
   *    ForEach Map
   *      STRING: name (if structured, includes type)
   *      STRING: module name
   *      BYTE: type
   *      BYTE: scope
   *      INTEGER: size  (0 = empty, -1 = uninitialized (NewMap not yet called))
   *      BYTE: IsCurrentKey
   *      If IsCurrentKey
   *        STRING: current key (external debugger format)
   *      EndIf
   */
  COMMAND_MapInfo, // send list of linkedlists in the source


  /* Command: Send the content of a Map
   *
   *  See COMMAND_ArrayData for command structure
   */
  COMMAND_MapData,


  /* Command: Send the current procedure history
   *
   *  Value1: number of procedures we are in
   *  Value2: PB_DEBUGGER_CurrentLine value
   *    Data:
   *    ForEach Procedure
   *      LONG: line where called from
   *      STRING: full procedure call
   */
  COMMAND_History,


  /* Command: Send history local variables
   *
   *  Value1: CallStackIndex
   *  Value2: Number of transmitted variables (including structure items)
   *    Data: Same as COMMAND_Locals data
   */
  COMMAND_HistoryLocals,


  /* Command: Send list of Procedures in the source
   *
   *  Value1: NbProcedures
   *  Value2:
   *    Data:
   *      For each procedure:
   *        STRING: name without ()
   *        STRING: module name or empty string
   */
  COMMAND_Procedures,


  /* Command: Send procedure statistics
   *
   *  Value1: NbProcedures
   *  Value2:
   *    Data: List of LONG with call counts
   */
  COMMAND_ProcedureStats,


  /* Command: Send error code if COMMAND_WatchlistAdd failed, if there is no error, this is not sent
   *
   *  Value1: item id
   *  Value2:
   *    Data: error message (ascii)
   */
  COMMAND_WatchlistError,


  /* Command: Send the full watchlist content (sorted by id)
   *
   *  Value1: number of items on the list
   *  Value2:
   *    Data:
   *
   *    ForEach Item
   *      BYTE: type
   *      BYTE: scope
   *      BYTE: isvalid (1 if the variable is valid (there is a value present), 0 if out of scope)
   *      LONG: procedure index (-1=global)
   *      STRING: name (utf8)
   *      IF isvalid
   *      <-- variable value -->
   *      EndIf
   */
  COMMAND_Watchlist, // send the full watchlist content (sorted by id) see below for DATA structure


  /* Command: Indicate that a single variable changed
   *
   *  Value1: index (if index = -1, then variable out of scope => Value2 holds real index)
   *  Value2: new value (except for string, quad, double, pointer, integer (even 32bit)
   *    Data: new value (for string, quad, etc)
   */
  COMMAND_WatchlistEvent,


  /* Command: Send library list
   *
   *  Value1: Number of libs
   *  Value2:
   *    Data:
   *
   *    ForEach Library
   *      STRING: LibraryID
   *      STRING: LibraryName
   *      STRING: TitleString (empty string if unsupported)
   *        LONG: LibraryInfo mask
   */
  COMMAND_Libraries,


  /* Command: Send object list of a library
   *
   *  Value1: Library index
   *  Value2: Nb of Objects (0 if no object display supported)
   *    Data: for each object: (INTEGER: id, STRING:Info)
   */
  COMMAND_LibraryInfo,


  /* Command: Identify the ObjectID for a following COMMAND_ObjectText or COMMAND_ObjectData
   *
   *  Value1: ObjectID (integer)
   *  Value2: high bytes of ObjectID
   *    Data:
   */
  COMMAND_ObjectID,


  /* Command: Send text information for the COMMAND_ObjectID object
   *
   *  Value1: Library index
   *  Value2:
   *    Data: text data (ascii) + NULL
   */
  COMMAND_ObjectText,


  /* Command: Send data of the COMMAND_ObjectID object
   *
   *  Value1: Library index
   *  Value2:
   *    Data: raw object data
   */
  COMMAND_ObjectData,


  /* Command: Send a list of offsets for each source file in the profiler table
   *
   *  Value1: NbSourceFiles
   *  Value2: Total number of lines in Profiler table
   *    Data: Array of longs (indexes into the ProfilerData array for each file)
   */
  COMMAND_ProfilerOffsets,


  /* Command: Send Profiler Table
   *
   *  Value1:
   *  Value2:
   *    Data: array of longs with line counts for ALL files (indexes into large array are found with COMMAND_ProfilerOffsets)
   */
  COMMAND_ProfilerData,


  /* Command: Send the result of an evaluated expression
   *
   *  Value1: sender id
   *  Value2: result type (0=error, 1=empty, 2=quad, 3=double, 4=string, 5=struct, 6=long (osx only), 7=float (osx only))
   *    Data:
   *
   *      If failed (Value1 = 0)
   *        STRING: error message (ascii)
   *      ElseIf Not a structure
   *        Result (as QUAD, DOUBLE, STRING(external format), or nothing if Value2=1)
   *      ElseIf structure result
   *        STRING: structure name (ascii)
   *        LONG: Nb structure entries
   *        ForEach entry
   *          BYTE: type
   *          BYTE: dynamictype (for array, list, map)
   *          LONG: sublevel
   *          STRING: name
   *          <--- entry value --> (if type = 7 (structure, no pointer) then there is no value )
   *        ForEach
   *      EndIf
   *      STRING: the sent request string
   */
  COMMAND_Expression, // result of expression evaluation


  /* Command: Send the result of setting a variable
   *
   *  Same command data as COMMAND_Expression
   */
  COMMAND_SetVariableResult,


  /* Command: Indicate that there was a warning in the code
   *
   *  Value1: LineNumber
   *  Value2:
   *    Data: message (ascii)
   *
   *  Note: This is only sent if warningmode=1, else COMMAND_Error or nothing is sent
   */
  COMMAND_Warning,


  /* Command: Data Breakpoint status message
   *
   *  Value1: status
   *     1 = breakpoint added
   *     2 = cannot add breakpoint
   *     3 = error evaluating the breakpoint expression (DATA=error, ascii)
   *     4 = breakpoint evaluated ok, but returned #False (sent if there was an error previously)
   *     5 = breakpoint evaluated to #True (COMMAND_Stopped will follow)
   *  Value2: breakpoint ID
   *    Data:
   */
  COMMAND_DataBreakPoint,


  /* Command: Send the content of a source file
   *
   *  Value1: file index
   *  Value2: IsFileOK (=0 if file not accessible, then DATA=empty)
   *    Data: file content
   */
  COMMAND_File,


  /* Command: Control the Debug output window
   *
   *  Value1: command
   *     1 = show
   *     2 = clear
   *     3 = save to disk
   *     4 = put to clipboard
   *  Value2:
   *    Data: filename (external format) if Value1=3
   */
  COMMAND_ControlDebugOutput,


  /* Command: Control the Profiler window
   *
   *  Value1:
   *    1 = show
   *    2 = update state
   *  Value2: IsProfilerRunning
   *    Data:
   */
  COMMAND_ControlProfiler,


  /* Command: Control the Memory Viewer
   *
   *  Value1:
   *     1 = show
   *     2 = show with data range (COMMAND_Memory must follow with data)
   *  Value2:
   *    Data: INTEGER, INTEGER (start address, length) for the range field
   */
  COMMAND_ControlMemoryViewer,


  /* Command: Control the Library Viewer
   *
   *  Value1:
   *     1 = show (with optional library)
   *     2 = show with library and specific object
   *  Value2: Library Index (-1 if not specified)
   *    Data: INTEGER: ObjectID
   */
  COMMAND_ControlLibraryViewer,


  /* Command: Control the Waictlist (currently just shows the window)
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_ControlWatchlist,


  /* Command: Control the Variable Viewer (currently just shows the window)
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_ControlVariableViewer,


  /* Command: Control the Callstack (currently just shows the window)
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_ControlCallstack,


  /* Command: Control the Assembly Viewer (currently just shows the window)
   *
   *  Value1:
   *  Value2:
   *    Data:
   */
  COMMAND_ControlAssemblyViewer,


  /* Command: Set new purifier granularities
   *
   *  Value1: 1 = update granularities (only option for now)
   *  Value2:
   *    Data: 4x long (Purifier granularities)
   */
  COMMAND_ControlPurifier,


  /* Command: Send list of modules
   *
   *  Value1: Nb of Modules
   *  Value2:
   *    Data: Module names (0-terminated, ascii)
   */
  COMMAND_Modules,
};


