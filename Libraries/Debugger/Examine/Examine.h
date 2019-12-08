/*
 *
 *  Header for Debugger data enumeration functions.
 *
 *  (mainly used by the Debugger itself, but also by a few libraries for debugging)
 *  NOTE: This API should not be public to allow easier changes.
 *
 */

#include <PureLibrary.h>

#define PointerSize sizeof(void *)
#define LongSize    sizeof(int)
#define WordSize    sizeof(short int)

// also defined in DebuggerInternal.h, but we need it here as well
typedef char xchar;

// scope values
#define SCOPE_MAIN     0
#define SCOPE_GLOBAL   1
#define SCOPE_THREADED 2
#define SCOPE_LOCAL    3
#define SCOPE_STATIC   4
#define SCOPE_SHARED   5

#define SCOPE_PARAMETER 6 // used only by Watchlist
#define SCOPE_MAX       6

// constants for code-context types
#define CONTEXT_EnterProcedure  1
#define CONTEXT_ExitProcedure   2
#define CONTEXT_EnterModule     3
#define CONTEXT_ExitModule      4
#define CONTEXT_UseModule       5
#define CONTEXT_UnuseModule     6

// mask out the bits with special meaning out of the variable Type field
#define POINTERMASK (1<<7)
#define PARAMMASK   (1<<6)

#define TYPEMASK        (~((char)(POINTERMASK|PARAMMASK)))
#define IGNORE_POINTER  (~((char)POINTERMASK))
#define IGNORE_PARAM    (~((char)PARAMMASK))

#define IS_POINTER(type) (((char)(type)) & POINTERMASK)
#define IS_PARAMETER(type) (((char)(type)) & PARAMMASK)

// PB Types as they appear in the debugger data lists
#define TYPE_BYTE         1
#define TYPE_WORD         3
#define TYPE_LONG         5
#define TYPE_STRUCTURE    7
#define TYPE_STRING       8
#define TYPE_FLOAT        9
#define TYPE_FIXEDSTRING 10
#define TYPE_CHARACTER   11
#define TYPE_DOUBLE      12
#define TYPE_QUAD        13
#define TYPE_INTEGER     21
#define TYPE_ASCII       24
#define TYPE_UNICODE     25

// only appears in some places (like parameter types, or structure)
#define TYPE_LINKEDLIST  14
#define TYPE_ARRAY       15
#define TYPE_MAP         22

// some spechial values
#define TYPE_MAX            25 // max possible value without pointer/parameter bit
#define TYPE_NONE            0
#define TYPE_LISTEND        -1
#define TYPE_STRUCTUREARRAY -2


#define IS_BYTE(type)        (((type) & TYPEMASK) == TYPE_BYTE)
#define IS_WORD(type)        (((type) & TYPEMASK) == TYPE_WORD)
#define IS_LONG(type)        (((type) & TYPEMASK) == TYPE_LONG)
#define IS_STRUCTURE(type)   (((type) & TYPEMASK) == TYPE_STRUCTURE)
#define IS_STRING(type)      (((type) & TYPEMASK) == TYPE_STRING)
#define IS_FLOAT(type)       (((type) & TYPEMASK) == TYPE_FLOAT)
#define IS_FIXEDSTRING(type) (((type) & TYPEMASK) == TYPE_FIXEDSTRING)
#define IS_CHARACTER(type)   (((type) & TYPEMASK) == TYPE_CHARACTER)
#define IS_DOUBLE(type)      (((type) & TYPEMASK) == TYPE_DOUBLE)
#define IS_QUAD(type)        (((type) & TYPEMASK) == TYPE_QUAD)
#define IS_INTEGER(type)     (((type) & TYPEMASK) == TYPE_INTEGER)
#define IS_ASCII(type)       (((type) & TYPEMASK) == TYPE_ASCII)
#define IS_UNICODE(type)     (((type) & TYPEMASK) == TYPE_UNICODE)
#define IS_LINKEDLIST(type)  (((type) & TYPEMASK) == TYPE_LINKEDLIST)
#define IS_ARRAY(type)       (((type) & TYPEMASK) == TYPE_ARRAY)
#define IS_MAP(type)         (((type) & TYPEMASK) == TYPE_MAP)


// A CallStackIndex of -1 access the global objects so we need to extra functions for that.
// The FindXXX() functions always check the locals first (if CallStackIndex != -1) and then the globals as well.
//
#define CALLSTACK_Global -1

typedef struct
{
  int   Line;              // line number
  int   ProcedureID;       // ID of current procedure (or -1 if none)
  char *Module;            // Name of current module or ""
  int   NbOpenModules;     // number of open modules
  char *OpenModules[50];   // array of open module names
} PB_LineContext;

// Variables.c
extern M_PBFUNCTION(int)    PB_DEBUGGER_ExamineVariables(int CallStackIndex);
extern M_PBFUNCTION(int)    PB_DEBUGGER_NextVariable(char **name, char **module, char *type, char *scope, char *public, char **value, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int)    PB_DEBUGGER_FindVariable(int CallStackIndex, char *searchname, char **realname, char *searchmodule, char **realmodule, char *type, char *scope, char **value, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int)    PB_DEBUGGER_LocateVariable(PB_LineContext *ctx, char *SearchName, char *ModulePrefix, char *type, char **value, char **structuremap, int *fixedlength);

// Procedures.c
extern M_PBFUNCTION(char *)  PB_DEBUGGER_GetProcedureInfo(int index, char **name, char *returntype, char *nbparameters, char *parametertypes);
extern M_PBFUNCTION(int)     PB_DEBUGGER_FindProcedure(char *name, char *module);
extern M_PBFUNCTION(char *)  PB_DEBUGGER_GetProcedureLocalMap(int ProcedureID, int MapIndex);
extern M_PBFUNCTION(int)     PB_DEBUGGER_GetProcedureID(int index);
extern M_PBFUNCTION(int)     PB_DEBUGGER_GetProcedureIndex(int ProcedureID);
extern M_PBFUNCTION(char *)  PB_DEBUGGER_GetProcedureName(int ProcedureID);
extern M_PBFUNCTION(char *)  PB_DEBUGGER_GetProcedureModule(int ProcedureID);
extern M_PBFUNCTION(char *)  PB_DEBUGGER_CopyProcedureArguments(int ProcedureID, char *VariablesOffset);
extern M_PBFUNCTION(xchar *) PB_DEBUGGER_GetProcedureCall(int callstackindex, char *Buffer);
extern M_PBFUNCTION(void)    PB_DEBUGGER_InitProcedureData();   // called by the debugger on startup to build procedure tables

// for GetProcedureLocalMap
#define PROCEDUREMAP_Variables   0
#define PROCEDUREMAP_Arrays      1
#define PROCEDUREMAP_LinkedLists 2
#define PROCEDUREMAP_Maps        3

// this is actually the same thing, but redefine it for future compatibility (ProcedureBank should not be used outside of Procedures.c)
#define PB_DEBUGGER_ProcedureCount() PB_DEBUGGER_ProcedureBank

extern int *PB_DEBUGGER_ProcedureCounts; // buffer that stores statistics about the procedures

// Structures.c
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineStructure(char *structureinfo, char *structuredata);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextStructureField(char **fieldname, char *type, char *dynamictype, char **value, int *sublevel, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_GetStructureSize(char *structureinfo);

// Arrays.c
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineArrays(int CallStackIndex, int isWatchlistMode);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextArray(char **name, char **module, char *type, char *scope, char *public, char **address, char *nbdimensions, integer **offsets, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_FindArray(int CallStackIndex, int isWatchlistMode, char *searchname, char **realname, char *searchmodule, char **realmodule, char *type, char *scope, char **address, char *nbdimensions, integer **offsets, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineArrayParts(char *range, char type, char *address, char nbdimensions, integer *offsets, char *structuremap, int fixedlength, int *maxindexlength, char **errormessage);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextArrayPart(char *indexbuffer, char **value);
extern M_PBFUNCTION(integer) PB_DEBUGGER_ArraySize(char *address, int dimension);
extern M_PBFUNCTION(integer) PB_DEBUGGER_ArrayElements(char *address);
extern M_PBFUNCTION(char *) PB_DEBUGGER_ArrayElementPointer(char *address, integer index);
extern M_PBFUNCTION(integer) PB_DEBUGGER_ArrayDimensions(char *address);
extern M_PBFUNCTION(void) PB_DEBUGGER_ArrayOffsets(char *address, integer **dimensions, integer **offsets);
extern M_PBFUNCTION(void) PB_DEBUGGER_ArrayDimensionString(char *address, char *output);
extern M_PBFUNCTION(int) PB_DEBUGGER_LocateArrayListMap(PB_LineContext *ctx, char *SearchName, char *ModulePrefix, int PreferGlobals, char *type, char **address, char **structuremap, int *fixedlength);


// LinkedLists.c
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineLinkedLists(int CallStackIndex);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextLinkedList(char **name, char **module, char *type, char *scope, char *public, char **address, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_FindLinkedList(int CallStackIndex, char *searchname, char **realname, char *searchmodule, char **realmodule, char *type, char *scope, char **address, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineLinkedlistParts(char *range, char type, char *address, char *structuremap, integer *maxindex, char **errormessage);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextLinkedlistPart(integer *index, char **value);
extern M_PBFUNCTION(integer)         PB_DEBUGGER_ListIndex(char *address);
extern M_PBFUNCTION(integer)         PB_DEBUGGER_ListCount(char *address);
extern M_PBFUNCTION(PB_ListHeader *) PB_DEBUGGER_ListElement(char *address, integer index);
extern M_PBFUNCTION(PB_ListHeader *) PB_DEBUGGER_ListCurrent(char *address);

// Maps.c
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineMaps(int CallStackIndex);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextMap(char **name, char **module, char *type, char *scope, char *public, char **address, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_FindMap(int CallStackIndex, char *searchname, char **realname, char *searchmodule, char **realmodule, char *type, char *scope, char **address, char **structuremap, int *fixedlength);
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineMapParts(char *pattern, int checkzero, char type, char *address, char *structuremap, char **errormessage);
extern M_PBFUNCTION(int) PB_DEBUGGER_NextMapPart(char **key, char **value);
extern M_PBFUNCTION(integer) PB_DEBUGGER_MapSize(char *address);
extern M_PBFUNCTION(xchar *)  PB_DEBUGGER_MapCurrentKey(char *address);
extern M_PBFUNCTION(int)     PB_DEBUGGER_MapCurrentValue(char *address, char **value);
extern M_PBFUNCTION(int)     PB_DEBUGGER_FindMapElement(char *address, xchar *key, char **value);

// Labels.c
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineLabels();
extern M_PBFUNCTION(int) PB_DEBUGGER_NextLabel(char *public, char **name, char **module, char **address);
extern M_PBFUNCTION(int) PB_DEBUGGER_LocateLabel(PB_LineContext *ctx, char *SearchName, char *ModulePrefix, char **address);
extern M_PBFUNCTION(int) PB_DEBUGGER_IsLabel(char *Label);

// Modules.c
extern M_PBFUNCTION(int) PB_DEBUGGER_ExamineModules();
extern M_PBFUNCTION(int) PB_DEBUGGER_NextModule(char **name);
extern M_PBFUNCTION(int) PB_DEBUGGER_FindModule(char *searchname, char **realname);
extern M_PBFUNCTION(char *)PB_DEBUGGER_PrefixModule(char *name, char *module, char type);
#define PrefixModule(name, module, type) PB_DEBUGGER_PrefixModule(name, module, type)

// Misc.c
extern const char *      PB_DEBUGGER_ScopeNames[];
extern const char *      PB_DEBUGGER_TypeNames[];
#define ScopeName(scope) PB_DEBUGGER_ScopeNames[scope]
#define TypeName(type)   PB_DEBUGGER_TypeNames[(type) & TYPEMASK]

extern M_PBFUNCTION(int)     PB_DEBUGGER_TypeSize(char type, char *structuremap, int fixedlength);
extern M_PBFUNCTION(int)     PB_DEBUGGER_IsZeroValue(char type, char *address, char *structuremap);

// Context.c
extern M_PBFUNCTION(void) PB_DEBUGGER_GetLineContext(int line, PB_LineContext *ctx);
extern M_PBFUNCTION(PB_LineContext *) PB_DEBUGGER_CurrentContext();
extern M_PBFUNCTION(int)  PB_DEBUGGER_IsItemVisible(PB_LineContext *ctx, char *ModulePrefix, char ItemIsPublic, char *ItemModule);
extern M_PBFUNCTION(int)  PB_DEBUGGER_IsLocalItemVisible(PB_LineContext *ctx, char *ModulePrefix);
