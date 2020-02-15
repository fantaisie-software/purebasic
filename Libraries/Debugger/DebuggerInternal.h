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

/*
 * Debugger headers for use inside the debugger only
 */
#ifdef WINDOWS
  // VisualC++ 2005 and up time.h hack, to use 32 bits times
  //
  #include <winsock2.h> // Needs to be before Windows.h or we get trouble with double definitions in VC8
#endif


#define PB_ALLOW_PRINTF


#include <PureLibrary.h>
#include <Object/Object.h>
#include <LinkedList/LinkedList.h>
#include <Map/Map.h>
#include <Array/Array.h>

#include "OSSpecific.h"           // OS and processor specific debugger stuff
#include "DebuggerModule.h"       // stuff that is public to the libraries
#include "LibraryViewer.h"        // library viewer header
#include "Examine/Examine.h"      // non-public data enumeration function
#include "ExternalCommands.h"     // communication commands for the external debugger
#include "ExternalDebugger.h"     // this has its separate file as it is quite big
#include "LanguageSupport.h"      // the language functions

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

#ifndef WINDOWS
  #include <termios.h>
  #include <unistd.h>
  #include <sys/utsname.h>
  #include <stdarg.h>
#endif

struct CallStackStruct
{
  int ProcedureID;
  char *VariablesOffset;
  int Line;

  // list of saved procedure args. contains all the passed values, as they were on the stack (strings are copied if needed)
  char *ArgumentList;
};


/* DebuggerStep description
 *-1 = execution was never stopped before (console debug only)
 *  0 = run
 *  1 = usual step
 *  2 = stop           (console debug only)
 *  3 = first stop yet (console debug only)
 *  4 = Step Over      (external debugger)
 *  5 = Step Out       (external debugger)
 * generally: <= 0 means run, >0 means stop
 */

/* values for PB_ThreadData->Control
 * 0 = normal execution
 * 1 = program loaded, waiting for external debugger to send the run command. (external debugger only)
 * 2 = error
 * 3 = CallDebugger
 * 4 = end program without error (set by console debugger)
 * 5 = program ended (no error, not ended by debugger)
 * 6 = fatal error
 * 7 = dynamic breakpoint met
 * 8 = stopped by user (ctrl+c, external debugger or step result)
 * 9 = data breakpoint met
 *
 * values only present on the IDE side
 * -1 = program not loaded
 * -2 = step mode
 */
typedef struct ThreadDataStruct
{
  struct ThreadDataStruct *Next; // single linked list to be able to enumerate all threads

  int StepMode; // formerly global step stuff
  int StepCount;
  int StepDepth; // target callstackdepth for 'step out' and 'step over'
  int StepLine;  // line for 'step over' (this is the line to avoid)

  int CurrentLine; // currentline for this thread
  int LastExecutedLine; // last executed line (for breakpoints/profiling in threads)
  int LastProfiledLine; // different from last executed, as it is updated on PB_DEBUGGER_SetLine()
  int Control;     // runtime control value

  int PurifierCounter; // counter for purifier checks

  OS_THREADTYPE ThreadHandle; // to suspend/resume

  int IsSuspended; // set to one if the thread suspended itself.

  struct CallStackStruct *CallStack;
  int CallStackDepth;
  int CallStackSize; // size of the allocated callstack buffer
} PB_ThreadData;



// the thread local data only stores a pointer to our real memory, so the location never changes
// when the object lib does a realloc for the main thread.
// note: using the GetThreadMemory() here is fast enough, as it directly returns the pointer in non-thread mode
//
#define GetThreadLocals() PB_ThreadData *ThreadLocals = *(PB_ThreadData **)PB_Object_GetThreadMemory(PB_DEBUGGER_ThreadData)

// tells you if the code is currently halted (CallDebugger, breakpoint, or if it is running)
// if the threads are suspended, and the suspending threads Control value is "haltet", then the code is stopped
#define IsCodeExecuting() (PB_DEBUGGER_SuspensionFlag == 0 || PB_DEBUGGER_SuspendingThread->Control != 0)


// Compiler generated stuff
extern void  PB_EndFunctions(void);
extern int   PB_DEBUGGER_FullScreen;
extern const char *PB_DEBUGGER_IncludedFiles[];
extern char  PB_DEBUGGER_FileName;
extern char  PB_DEBUGGER_SourcePath;
extern char  PB_DEBUGGER_PureBasicPath;
extern char  PB_DEBUGGER_Language;
extern int   PB_DEBUGGER_VariableBank; // defined as int to directly read the number
extern int   PB_DEBUGGER_ProcedureBank;
extern int   PB_DEBUGGER_ArrayBank;
extern int   PB_DEBUGGER_LinkedListBank;
extern int   PB_DEBUGGER_MapBank;
extern int   PB_DEBUGGER_ConstantBank;
extern int   PB_DEBUGGER_LabelBank;
extern int   PB_DEBUGGER_ModuleBank;
extern int   PB_DEBUGGER_NbIncludedFiles;
extern int   PB_DEBUGGER_ValidLines[];
extern int   PB_DEBUGGER_Purifier;
extern int   PB_DEBUGGER_Version;
extern char  PB_DEBUGGER_CodeContextBank;

extern void  PB_DEBUGGER_ChangeString(xchar** target, xchar *value);

// Debugger.c
#ifdef PB_64
  #define SIZEOF_MainBuffer  36000000  // bigger for 64bit, as pointers etc take more space
#else
  #define SIZEOF_MainBuffer  18000000  // 18mb should be more than enough
#endif

#define SIZEOF_MaxStructureAnswer 1000000 // 1 mb max for the structure info answer (it uses the MainBuffer). Very large structures aren't useful to display anyway.

extern int   PB_DEBUGGER_WarningMode; // 0=ignore, 1=show, 2=treat as error
extern int   PB_DEBUGGER_External;
extern int   PB_DEBUGGER_ExternalUnicode;
extern int   PB_DEBUGGER_CallOnStart;
extern int   PB_DEBUGGER_CallOnEnd;
extern char *PB_DEBUGGER_MainBuffer;   // buffer for various debugger operations (especially external communication)
extern unsigned_integer PB_DEBUGGER_StackStart;

extern int *PB_DEBUGGER_ProfilerOffsetTable; // offset for each file (size = total number of files)
extern int  PB_DEBUGGER_ProfilerTableSize;   // total size of the DataTable
extern int *PB_DEBUGGER_ProfilerDataTable;   // actual line counts
extern int  PB_DEBUGGER_ProfilerRunning;     // profiler state

extern integer PB_DEBUGGER_Check(int LineNumber, integer *registers);
extern integer PB_DEBUGGER_Error(int Control, const char *Description);
extern integer PB_DEBUGGER_Warning(const char *Message);

// Breakpoints.c
#define PB_DEBUGGER_MaxBreakPoints 500
extern int PB_DEBUGGER_ExecBreakPoints[];    // real executable line numbers
extern int PB_DEBUGGER_UserBreakPoints[];    // line numbers as specified by the user
extern int PB_DEBUGGER_NbBreakPoints;

typedef struct
{
  xchar *Condition;      // condition in original format (Ascii or external) (M_Alloc, null-terminated)
  char  *ConditionUTF8;  // condition expression in UTF8 (M_Alloc, null-terminated)
  int    ProcedureID;    // ID in which to check for this condition (-1 for main program)
  int    BreakPointID;   // for external debugger
  char   LastError[400]; // error from last evaluation (same length as the error string buffer in ExpressionParser.c)
} PB_DataBreakPoint;

#define PB_DEBUGGER_MaxDataBreakPoints 50
extern PB_DataBreakPoint PB_DEBUGGER_DataBreakPoints[];
extern int PB_DEBUGGER_NbDataBreakPoints;

extern M_PBFUNCTION(int) PB_DEBUGGER_AddDataBreakPoint(int ProcedureID, xchar *Condition, integer Length, int IsUnicode);
extern M_PBFUNCTION(void) PB_DEBUGGER_RemoveDataBreakPoint(int Index);
extern M_PBFUNCTION(void) PB_DEBUGGER_ClearDataBreakPoints();
extern M_PBFUNCTION(int) PB_DEBUGGER_CheckDataBreakPoints();

// WindowsErrorHandler.c or UnixErrorHandler.c
extern M_PBFUNCTION(void) PB_DEBUGGER_SetErrorHandler();

// CocoaExceptionHandler.m
#ifdef PB_COCOA
  extern M_PBFUNCTION(void) PB_DEBUGGER_CocoaExceptionHandler(void);
#endif

// Date.c
extern M_PBFUNCTION(int) PB_DEBUGGER_Timestamp();

// ThreadSupport.c
extern integer        PB_DEBUGGER_ThreadData;
extern PB_ThreadData *PB_DEBUGGER_FirstThread;
extern PB_ThreadData *PB_DEBUGGER_MainThread;
extern int            PB_DEBUGGER_SuspensionFlag;
extern PB_ThreadData *PB_DEBUGGER_SuspendingThread;

extern M_PBFUNCTION(void) PB_DEBUGGER_SuspendThreads();
extern M_PBFUNCTION(void) PB_DEBUGGER_ResumeThreads();
extern M_PBFUNCTION(void) PB_DEBUGGER_InitThreads();
extern M_PBFUNCTION(void) PB_DEBUGGER_EndThreads();

// UnicodeSupport.c

/* NOTE: For clarity in the code we use these 3 types of char declarations:
 * char    - indicates an ascii string
 * wchar_t - indicates a unicode string
 * xchar   - indicates that this string has the type of the executable, so unknown at compile time
 *           This is defined as a char really, so that it works well together with X_strlen()
 *           which returns a number of bytes always.
 *
 * These types (and only these) should be used consistently within the Debugger source!
 *
 * As for string length. The DebuggerModule ALWAYS works in bytes, not characters when dealing
 * with xchar strings. (since xchar is a char, adding length to such pointers works just well then)
 *
 * Using the TCHAR like in libs makes no sense, as there is no separate unicode-compilation of this source.
 * Also i think it is better to use a totally new type to avoid any confusion.
 *
 * The functions starting with X_ indicate that they work depending on the executables unicode mode.
 * The functions starting with E_ indicate that they work in the mode of the external debugger (those should only be a few)
 */

// already defined in Examine/Examine.h
//typedef char xchar;

/* Turns a literal ascii string into the executable mode format.
 * the returned type is char *, but the content is what the exe uses
 * Use this for the format specifier in X_fprintf_string() for example.
 */
#define X_TEXT(string) (PB_DEBUGGER_Unicode ? ((xchar *)L##string) : ((xchar *)string))

// a little macro to ensure that also uninitialized (== 0) PB string variables
// are handled correctly without much typing.
// we use a unicode nullstrting.. works for ascii too.
#define EnsureString(_string_) ((_string_) == 0 ? (xchar *)(L"") : (xchar *)(_string_))

// We redefine these to have a clean external visible set of functions, but short names inside the sources themselves
//
#define CharSize         PB_DEBUGGER_CharSize
#define E_CharSize       PB_DEBUGGER_CharSizeExternal
#define X_fprintf_string PB_DEBUGGER_xfprint_string
#define X_sprintf        PB_DEBUGGER_xsprintf
#define X_sprintf_string PB_DEBUGGER_xsprintf_string
#define X_pbchar         PB_DEBUGGER_xpbchar
#define X_Ascii2XChar    PB_DEBUGGER_ascii2xchar
#define X_XChar2Ascii    PB_DEBUGGER_xchar2ascii
#define X_strlen         PB_DEBUGGER_xstrlen
#define X_memchr         PB_DEBUGGER_xmemchr
#define X_strcpy         PB_DEBUGGER_xstrcpy
#define X_strcat         PB_DEBUGGER_xstrcat
#define X_strcmp         PB_DEBUGGER_xstrcmp
#define X_stricmp        PB_DEBUGGER_xstricmp
#define X_strncmp        PB_DEBUGGER_xstrncmp
#define X_strnicmp       PB_DEBUGGER_xstrnicmp
#define X_strncpy        PB_DEBUGGER_xstrncpy
#define E_Convert        PB_DEBUGGER_econvert
#define E_ConvertN       PB_DEBUGGER_econvertn
#define E_ConvertedSize  PB_DEBUGGER_econvertedsize
#define E_strlen         PB_DEBUGGER_estrlen
#define E_strcpy         PB_DEBUGGER_estrcpy
#define E_External2Ascii PB_DEBUGGER_external2ascii
#define ulltoa           PB_DEBUGGER_ulltoa
#define lltoa            PB_DEBUGGER_lltoa
#define lltoh            PB_DEBUGGER_lltoh
#define wulltoa          PB_DEBUGGER_wulltoa
#define wlltoa           PB_DEBUGGER_wlltoa
#define wlltoh           PB_DEBUGGER_wlltoh
#define X_lltoa          PB_DEBUGGER_xlltoa
#define X_lltoh          PB_DEBUGGER_xlltoh
#define X_unescape       PB_DEBUGGER_xunescape


extern int CharSize;                    // size of exe character (initialized in PB_DEBUGGER_Start)
extern int E_CharSize;                  // this are redefined to longer names in DebuggerInternal.h

extern int                     X_fprintf_string(FILE *stream, xchar *format, xchar *string);
extern int                     X_sprintf(xchar *buffer, xchar *format, ...); // No M_FUNCTION() because of varargs
extern int                     X_sprintf_string(xchar *buffer, xchar *format, xchar *string);
extern M_PBFUNCTION(int)       X_pbchar(xchar *c);
extern M_PBFUNCTION(xchar *)   X_Ascii2XChar(xchar *target, char *source);
extern M_PBFUNCTION(char *)    X_XChar2Ascii(char *target, xchar *source);
extern M_PBFUNCTION(int)       X_strlen(xchar *string);
extern M_PBFUNCTION(xchar *)   X_memchr(xchar *str, xchar ch, int num);
extern M_PBFUNCTION(xchar *)   X_strcpy(xchar *str1, xchar *str2);
extern M_PBFUNCTION(xchar *)   X_strcat(xchar *str1, xchar *str2);
extern M_PBFUNCTION(int)       X_strcmp(xchar *str1, xchar *str2);
extern M_PBFUNCTION(int)       X_stricmp(xchar *str1, xchar *str2);
extern M_PBFUNCTION(int)       X_strncmp(xchar *str1, xchar *str2, size_t len);
extern M_PBFUNCTION(int)       X_strnicmp(xchar *str1, xchar *str2, size_t len);
extern M_PBFUNCTION(xchar *)   X_strncpy(xchar *str1, xchar *str2, int num);
extern M_PBFUNCTION(xchar *)   E_Convert(xchar *target, xchar *source);
extern M_PBFUNCTION(xchar *)   E_ConvertN(xchar *target, xchar *source, int size);
extern M_PBFUNCTION(int)       E_ConvertedSize(xchar *string);
extern M_PBFUNCTION(int)       E_strlen(xchar *string);
extern M_PBFUNCTION(xchar *)   E_strcpy(xchar *str1, xchar *str2);
extern M_PBFUNCTION(char *)    E_External2Ascii(char *target, xchar *source);
extern M_PBFUNCTION(char *)    ulltoa(char *buf, unsigned long long val);
extern M_PBFUNCTION(char *)    lltoa(char *buf, long long val);
extern M_PBFUNCTION(char *)    lltoh(char *buf, long long val);
extern M_PBFUNCTION(wchar_t *) wulltoa(wchar_t *buf, unsigned long long val);
extern M_PBFUNCTION(wchar_t *) wlltoa(wchar_t *buf, long long val);
extern M_PBFUNCTION(wchar_t *) wlltoh(wchar_t *buf, long long val);
extern M_PBFUNCTION(xchar *)   X_lltoa(xchar *buf, long long val);
extern M_PBFUNCTION(xchar *)   X_lltoh(xchar *buf, long long val);
extern M_PBFUNCTION(xchar *)   X_unescape(xchar *out, xchar *in, int len);

// ConsoleDebugger.c (ExternalDebugger.c has its own header as it is big)
extern M_PBFUNCTION(void) PB_DEBUGGER_InitConsole();
extern M_PBFUNCTION(void) PB_DEBUGGER_EndConsole();
extern M_PBFUNCTION(void) PB_DEBUGGER_StoppedConsole(integer *registers);
extern M_PBFUNCTION(void) PB_DEBUGGER_ErrorConsole(const char *Message);

extern FILE  *PB_DEBUGGER_ConsoleStream;
extern int    PB_DEBUGGER_HexDisplay;


// ExpressionParser.c
typedef enum
{
  TError,
  TEof,
  TNone, // to know when we are at the start of the input and for uninitialized values

  TModule,
  TColon,

  TAdd,
  TSub,
  TMul,
  TDiv,
  TOr,
  TAnd,
  TShl,
  TShr,
  TXor,
  TMod,
  TNot,

  TBoolAnd,
  TBoolOr,
  TBoolXor,
  TBoolNot,

  TEqual,
  TNotEqual,
  TLess,
  TMore,
  TLessEqual,
  TMoreEqual,

  TLParen,
  TRParen,
  TLBracket,
  TRBracket,
  TComma,
  TBackslash,
  TAt,
  TSharp,
  TQuestion,

  TInt,
  TFloat,
  TString,
  TIdent,
} PB_TokenType;

// information about a single token
typedef struct
{
  PB_TokenType Token;

  union {
    double    floatValue;  // TFloat
    quad      intValue;    // TInt
    xchar    *strValue;    // TString (M_Alloc'ed 0-terminated string in xchar format)

    // TIdent
    //   Points into the input buffer, so no allocation and no 0-termination!
    //   The format of the string is UTF-8, though only Ascii characters are accepted
    //   as a Identifier anyway.
    //
    struct {
      char *Name;
      integer Length;
    };
  };

  char IsLiteral;  // nonzero if the expression was a literal one (no variables, functions, etc)
  char IsBoolean;  // nonzero if the expression is a boolean result

  // in case intValue represents a pointer to a PB variable / structure element etc,
  // this data will be valid. (if type == 0, data is invalid)
  char  Type;
  char  DynamicType; // real type in case Type==TYPE_ARRAY etc
  char *Structuremap;
  int   Fixedlength;
} PB_TokenInfo;

// This is for the expression parser, which keeps everything in quads, even on 32bit OS
//
// With the /Wp64, even VC8 complains in 32bit mode, so use the linux one here too
//
#if defined(PB_64) || defined(POWERPC)// no quads on ppc (quad is defined as int there)
  #define pointer_to_quad(p)    ((quad)(p))
  #define quad_to_pointer(t, q) ((t)(q))
#else
  // need to cast to int here first
  #define pointer_to_quad(p)    ((quad)(int)(p))
  #define quad_to_pointer(t, q) ((t)(int)(q))
#endif

// Flags for expression parsing
#define EXPRESSION_FindVariable       1
#define EXPRESSION_FindArrayListMap   2
#define EXPRESSION_PreferGlobalList  4

extern M_PBFUNCTION(int) PB_DEBUGGER_ParseExpression(char *UTF8Input, int Flags, PB_TokenInfo *Result, char **ErrorMsg, PB_LineContext *context);
extern M_PBFUNCTION(int) PB_DEBUGGER_ParseExpressionAscii(char *AsciiInput, integer Length, int Flags, PB_TokenInfo *Result, char **ErrorMsg, PB_LineContext *context);
extern M_PBFUNCTION(int) PB_DEBUGGER_ParseExpressionExternal(xchar *ExternalInput, int Length, int Flags, PB_TokenInfo *Result, char **ErrorMsg, PB_LineContext *context);
extern M_PBFUNCTION(int) PB_DEBUGGER_TokenToBoolean(PB_TokenInfo *Token, char **ErrorMsg);


// Stack.c (and asm versions)
extern M_PBFUNCTION(integer) PB_DEBUGGER_GetStackInfo(unsigned_integer **start, unsigned_integer **limit); // *limit can be 0 if not available!
extern M_PBFUNCTION(void)    PB_DEBUGGER_PrintStack(FILE *stream, integer *registers, char **outbuffer, integer *size);

// Utilities.c
#define GetFixed  PB_DEBUGGER_GetFixed
#define FreeFixed PB_DEBUGGER_FreeFixed

extern M_PBFUNCTION(xchar *) GetFixed(xchar *String, int Length);
extern M_PBFUNCTION(void)    FreeFixed(xchar *RealString, xchar *Copy);

extern int PB_DEBUGGER_BreakpointSort(const void *a, const void *b); // no M_PBFUNCTION as this is used as a parameter for bsort/bsearch !
extern M_PBFUNCTION(int) PB_DEBUGGER_GetExecutableLine(int Line);
extern M_PBFUNCTION(const char *) PB_DEBUGGER_GetFileName(int Line);
extern M_PBFUNCTION(const char *) PB_DEBUGGER_GetRelativeFileName(int Line);
extern M_PBFUNCTION(int)  PB_DEBUGGER_IsValidMemory(unsigned_integer start, unsigned_integer size);
extern M_PBFUNCTION(int)  PB_DEBUGGER_IsValidMemoryStringMode(xchar *Pointer, int Length, int isUnicode); // Length in Characters!
extern M_PBFUNCTION(int)  PB_DEBUGGER_IsValidMemoryString(xchar *Pointer, int Length); // Length in Characters!
extern M_PBFUNCTION(int)  PB_DEBUGGER_MatchPattern(xchar *pattern, xchar *input, int caseinsensitive);
extern M_PBFUNCTION(void) PB_DEBUGGER_MemoryDump(FILE *stream, unsigned_integer start, unsigned_integer length, char *buffer, integer *size);
extern M_PBFUNCTION(void) PB_DEBUGGER_PrintStack(FILE *stream, integer *registers, char **outbuffer, integer *size); // only called on x86
extern M_PBFUNCTION(int)  PB_DEBUGGER_ModifyVariable(PB_TokenInfo *Target, PB_TokenInfo *Result, char **ErrorMsg);
extern M_PBFUNCTION(char *) PB_DEBUGGER_ExpressionFind(char *position, char target);

#ifndef POWERPC
  extern M_PBFUNCTION(char *) PB_DEBUGGER_FlagsRegister(char *output, integer flags);
#endif

// DebuggerLanguage.c
extern char *PB_DEBUGGER_LanguageTable[];

// Purifier.c
extern int PB_PURIFIER_GlobalGranularity;
extern int PB_PURIFIER_LocalGranularity;
extern int PB_PURIFIER_StringGranularity;
extern int PB_PURIFIER_DynamicGranularity;

// for debugging
#define _(s) printf(#s); printf("\n");

/* This is a special flag that adds a feature to the console debugger to better debug very weird things.
 * It should be disabled in release versions of the debugger as it degrades performance.
 * Enabling this enables 2 new console debugger commands:
 *   startprint - start printing each executed line number
 *   stopprint  - stop the priniting
 */
// #define PB_ENABLE_PRINTLINE

#ifdef PB_ENABLE_PRINTLINE
  extern int PB_DEBUGGER_PrintLines;
  extern int PB_DEBUGGER_LastPrintedFile;
#endif
