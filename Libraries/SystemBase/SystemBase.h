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

#ifndef PB_SYSTEMBASE_H
#define PB_SYSTEMBASE_H

#define NO_UNICODE_ALIASES
#include <PureLibrary.h>

M_SYSFUNCTION(void) SYS_FreeStructureStrings(char *Area, integer *StructureMap);
M_SYSFUNCTION(void) SYS_CopyStructure(char *Destination, integer Length, integer *StructureMap, const char *Source);
M_SYSFUNCTION(void) SYS_InitDynamicStructure(char *Address, integer *StructureMap);
M_SYSFUNCTION(integer) SYS_IsDynamicStructure(integer *StructureMap);
M_SYSFUNCTION(void) SYS_AdjustStructurePointers(char *Address, integer *StructureMap);

M_SYSFUNCTION(void *) SYS_AllocateMemory(integer Size);
M_SYSFUNCTION(void *) SYS_AllocateMemoryFast(integer Size);
M_SYSFUNCTION(void)   SYS_AllocateDynamicStructure(integer **Address, integer *StructureMap);
M_SYSFUNCTION(void *) SYS_ReAllocateMemory(void *OldMemory, integer OldSize, integer NewSize);
M_SYSFUNCTION(void)   SYS_FreeMemory(void *Memory);
M_SYSFUNCTION(void *) SYS_AllocateMemoryWithSize(integer Size);
M_SYSFUNCTION(void *) SYS_AllocateMemoryWithSizeNoClear(integer Size);
M_SYSFUNCTION(void *) SYS_ReAllocateMemoryWithSize(void *OldMemoryP, integer NewSize);
M_SYSFUNCTION(void *) SYS_ReAllocateMemoryWithSizeNoClear(void *OldMemoryP, integer NewSize);
M_SYSFUNCTION(void)   SYS_FreeMemoryWithSize(void *Memory);
M_SYSFUNCTION(void)   SYS_ClearStructure(char *Address, integer Length, integer *StructureMap);

#define SYS_ulltoa M_UnicodeFunction(SYS_ulltoa)
#define SYS_lltoa  M_UnicodeFunction(SYS_lltoa)

M_SYSFUNCTION(TCHAR *) SYS_ulltoa(TCHAR *buf, unsigned long long val);
M_SYSFUNCTION(TCHAR *) SYS_lltoa(TCHAR *buf, long long val);
M_SYSFUNCTION(quad)    SYS_atoll(char *String);
M_SYSFUNCTION(char *)  SYS_ReplaceString(const char *string, const char *substr, const char *replacement);

M_SYSFUNCTION(void *) SYS_GetThreadedObject(void);

typedef void (M_PBVIRTUAL * ThreadCallbackType)(void *Data);
M_SYSFUNCTION(void) SYS_RegisterThreadCallback(ThreadCallbackType Callback, void *Data);

// Threaded Object stuff
extern integer PB_ThreadedObjectSize; // defined by the Compiler (available when threaded objects are used and in debug mode)

// Structure items markers
#define ST_End         -1
#define ST_StaticArray -2
#define ST_Structure   -3
#define ST_Array       -4
#define ST_List        -5
#define ST_Map         -6
#define ST_MultiArray  -7



// Dynamic functions, nested objects in structures
struct PB_Array;
struct PB_List;
struct PB_ListObject;
struct PB_ListHeader;
struct PB_Map;

typedef struct PB_Array * (M_SYSVIRTUAL *NewArrayProc)     (integer ElementSize, integer NbElements, int Type, integer *StructureMap, struct PB_Array **Address);
typedef struct PB_Array * (M_SYSVIRTUAL *NewMultiArrayProc)(integer NbDimensions, integer ElementSize, int Type, integer *StructureMap, integer *Address);
typedef struct PB_List *  (M_PBVIRTUAL *NewListProc)       (integer ElementSize, struct PB_ListObject *Object, integer *StructureMap, int ElementType);
typedef struct PB_Map *   (M_PBVIRTUAL *NewMapProc)        (integer ElementSize, int ElementType, integer *StructureMap, struct PB_Map **Address, int HashSize);

typedef integer (M_PBVIRTUAL *CopyArrayProc) (const struct PB_Array *Array, struct PB_Array *DestinationArray, int Clear);
typedef integer (M_PBVIRTUAL *CopyListProc)  (const struct PB_List *List, struct PB_List *DestinationList, int Clear);
typedef integer (M_PBVIRTUAL *CopyMapProc)   (struct PB_Map *Map, struct PB_Map *DestinationMap, int Clear);

typedef void (M_PBVIRTUAL *FreeArrayProc) (struct PB_Array *Array);
typedef void (M_PBVIRTUAL *FreeListProc)  (struct PB_List *List);
typedef void (M_PBVIRTUAL *FreeMapProc)   (struct PB_Map *Map);

extern NewMultiArrayProc SYS_DynamicNewMultiArray;
extern NewArrayProc      SYS_DynamicNewArray;
extern NewListProc       SYS_DynamicNewList;
extern NewMapProc        SYS_DynamicNewMap;

extern CopyArrayProc SYS_DynamicCopyArray;
extern CopyListProc  SYS_DynamicCopyList;
extern CopyMapProc   SYS_DynamicCopyMap;

extern FreeArrayProc SYS_DynamicFreeArray;
extern FreeListProc  SYS_DynamicFreeList;
extern FreeMapProc   SYS_DynamicFreeMap;


#ifdef X64
  // Helper function to convert from PB FPU stack to AMD64 SSE convention
  M_SYSFUNCTION(float) SYS_ConvertFloatFPU();
  M_SYSFUNCTION(double) SYS_ConvertDoubleFPU();
#endif


// Structure info & Examine state for runtime structures
// Note that all strings are in Ascii always!
typedef struct 
{
  char *StructureName;  // Name of the base structure
  char *ModuleName;     // Name of module containing the structure
  integer *DynamicMap;  // Pointer to 'Dynamic' structure map (or 0 if no dynamic elements in this struct)
  
  char *Name;           // Name of current element
  char  Kind;           // PB_Element_...
  char  Type;           // PB_Byte, PB_Long, ...
  char  Pointer;        // true for pointers
  int   Offset;         // Offset within structure
  void *Data;           // pointer to element data within the structure (for arrays this points to element 0)
  
  int   ArraySize;      // Static array: number of elements
  int   ElementSize;    // Static array: size of one element
  int   FixedLength;    // Fixed string: string size (in bytes!)
  void *StructureMap;   // Structure: structure map
  
  char *BaseData;       // Examine state: pointer to start of structure data
  char *Position;       // Examine state: current position within structure map
} PB_RuntimeStructure;

// Kinds of structure elements in a runtime structure
#define PB_Element_Value        1
#define PB_Element_StaticArray  2
#define PB_Element_Array        3
#define PB_Element_List         4
#define PB_Element_Map          5

// Examine a structure
M_SYSFUNCTION(void)    SYS_ExamineRuntimeStructure(PB_RuntimeStructure *State, void *DataPtr, void *StructureMap);
M_SYSFUNCTION(integer) SYS_NextRuntimeStructureElement(PB_RuntimeStructure *State);

// get location of static array field in runtime structure
#define M_StructureArrayField(State, index) ((void *)((char *)((State)->Data) + (State)->ElementSize * (index)))


#endif

