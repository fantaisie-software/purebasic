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

#include <PureLibrary.h>


typedef struct
{
	int StartDrawing;
} PB_DebuggerGlobals;

typedef struct
{    
  char *Filename;     // default catalog filename (no path)
  char *Application;  // "Application" field of the catalog file  
  char *Group;        // group name (should be unique. use library name for example)
  int   Initialized;  // set to 0 initially, used by debugger to know what was loaded

  struct          
  {
    char *Key; 
    char *Value; 
  } Defaults[];       // default values for the group, ending with 2 null pointers or empty strings
} PB_Language;

M_PBFUNCTION(char *) PB_DEBUGGER_GetLanguage(PB_Language *data, const char *Key);
M_PBFUNCTION(void)   PB_DEBUGGER_SendTranslatedError(PB_Language *data, const char *Key);
M_PBFUNCTION(void)   PB_DEBUGGER_SendTranslatedErrorFunction(const char* FunctionName, PB_Language *data, const char *Key);
M_PBFUNCTION(void)   PB_DEBUGGER_SendTranslatedWarning(PB_Language *data, const char *Key);

char *PB_DEBUGGER_GetCommonLanguage(char *Key, ...);
void  PB_DEBUGGER_SendCommonError(char *Key, ...);
void  PB_DEBUGGER_SendCommonErrorFunction(const char *FunctionName, char *Key, ...);
void  PB_DEBUGGER_SendCommonWarning(char *Key, ...);

M_PBFUNCTION(void)     PB_DEBUGGER_SendError(const char *Message);
M_PBFUNCTION(void)     PB_DEBUGGER_SendWarning(const char *Message);
M_PBFUNCTION(integer)  PB_DEBUGGER_FileExists(const char *Filename);
M_PBFUNCTION(integer)  PB_DEBUGGER_CheckLabel(void *Label);


#define SendDebuggerError        PB_DEBUGGER_SendError
#define SendDebuggerWarning      PB_DEBUGGER_SendWarning
#define SendCommonError          PB_DEBUGGER_SendCommonError

#ifdef WINDOWS
  #define SendCommonErrorFunction(a, ...)  PB_DEBUGGER_SendCommonErrorFunction(__FUNCTION__, a, __VA_ARGS__)
#else
  // GCC needs a special syntax to get ride of the last comma when using __VA_ARGS__ without arguments
  // https://gcc.gnu.org/onlinedocs/gcc/Variadic-Macros.html
  //
  #define SendCommonErrorFunction(a, ...)  PB_DEBUGGER_SendCommonErrorFunction(__FUNCTION__, a, ## __VA_ARGS__)
#endif

#define SendCommonWarning        PB_DEBUGGER_SendCommonWarning
#define GetCommonLanguage        PB_DEBUGGER_GetCommonLanguage

// name the PB_Language definition "LanguageTable", and this macro can be used for simplicity
#define GetLanguage(Key)           PB_DEBUGGER_GetLanguage(&LanguageTable, Key)
#define SendTranslatedError(Key)   PB_DEBUGGER_SendTranslatedError(&LanguageTable, Key)
#define SendTranslatedWarning(Key) PB_DEBUGGER_SendTranslatedWarning(&LanguageTable, Key)
#define SendTranslatedErrorFunction(Key) PB_DEBUGGER_SendTranslatedErrorFunction(__FUNCTION__, &LanguageTable, Key)


/* Call this function to check if a procedure pointer is a PB procedure and if the arguments match.
 *   Procedure  - the procedure pointer
 *   ReturnType - expected return type (PB_Integer, PB_String, PB_Any, ...)
 *   Count      - number of expected arguments
 *   ...        - expected argument types
 *
 * Result will be one of the following constants.
 */
integer PB_DEBUGGER_CheckProcedure(void *Procedure, integer ReturnType, integer Count, ...); // use PB_String, PB_Integer, PB_Any, as arguments
#define PB_Procedure_Ok                  0 // procedure matches
#define PB_Procedure_NotFound            1 // not a valid procedure pointer (might be an external function though!)
#define PB_Procedure_WrongType           2 // prototype not matching


extern int PB_DEBUGGER_FullScreen;
extern int PB_DEBUGGER_Unicode;
extern int PB_DEBUGGER_Thread;
extern int PB_DEBUGGER_Purifier;
extern integer PB_DEBUGGER_Globals;


// Runtime flags checks for functions
//
M_PBFUNCTION(void) PB_DEBUGGER_CheckCombinationFlags(const char *FunctionName, const char *ParameterName, int Flags, int *FlagsList, int NbFlags);

#define CheckCombinationFlags(a, ...) { \
  static int __combinationflags##a[] = { __VA_ARGS__ }; \
  PB_DEBUGGER_CheckCombinationFlags(__FUNCTION__, #a, a,  __combinationflags##a, sizeof(__combinationflags##a) / sizeof(int)); }


M_PBFUNCTION(void) PB_DEBUGGER_CheckSingleFlags(const char *FunctionName, const char *ParameterName, int Flags, int *FlagsList, int NbFlags);

#define CheckSingleFlags(a, ...) { \
  static int __singleflags##a[] = { __VA_ARGS__ }; \
  PB_DEBUGGER_CheckSingleFlags(__FUNCTION__, #a, a,  __singleflags##a, sizeof(__singleflags##a) / sizeof(int)); }
  


M_PBFUNCTION(void) PB_DEBUGGER_CheckImageID(const char *FunctionName, void *ImageHandle, const char *ParameterName);
  
#define CheckImageID(a) PB_DEBUGGER_CheckImageID(__FUNCTION__, a, #a)





// Used by the keyboard, mouse and engine3d debug files
// 
void PB_ScreenDebug_IsScreen(const char *Message);

// for debugger parser support
struct PB_ObjectStructure; // so we don't need Object.h just for this
typedef integer (M_PBVIRTUAL *IsObjectFunction)(integer ObjectID);
typedef integer (M_PBVIRTUAL *ObjectIDFunction)(integer ObjectID);

M_PBFUNCTION(void) PB_DEBUGGER_RegisterObjects(char *Library, struct PB_ObjectStructure **Objects);
M_PBFUNCTION(void) PB_DEBUGGER_RegisterObjectFunctions(char *Library, IsObjectFunction *IsObject, ObjectIDFunction *ObjectID);

// Check if the given (runtime-) structure map contains ambiguous elements
// when any '*' or '$' are removed. If yes, raises a debugger error about it
M_PBFUNCTION(void) PB_DEBUGGER_CheckStructureSerializable(void *StructureMap);