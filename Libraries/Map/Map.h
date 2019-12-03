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

#ifndef PB_MAP_H
#define PB_MAP_H

#include <PureLibrary.h>
#include <Object/Object.h>

#define PB_AddMapElement     M_UnicodeFunction(PB_AddMapElement)
#define PB_AddMapElement2    M_UnicodeFunction(PB_AddMapElement2)
#define PB_CopyMap           M_UnicodeFunction(PB_CopyMap)
#define PB_CopyMap2          M_UnicodeFunction(PB_CopyMap2)
#define PB_CreateMapElement  M_UnicodeFunction(PB_CreateMapElement)
#define PB_DeleteMapElement  M_UnicodeFunction(PB_DeleteMapElement)
#define PB_DeleteMapElement2 M_UnicodeFunction(PB_DeleteMapElement2)
#define PB_FindMapElement    M_UnicodeFunction(PB_FindMapElement)
#define PB_GetMapElement     M_UnicodeFunction(PB_GetMapElement)
#define PB_MapKey            M_UnicodeFunction(PB_MapKey)
#define PB_InitMap           M_UnicodeFunction(PB_InitMap)
#define PB_Map_Hash          M_UnicodeFunction(PB_Map_Hash)
#define PB_Map_HashCaseInsensitive M_UnicodeFunction(PB_Map_HashCaseInsensitive)
#define PB_Map_FindMapElement M_UnicodeFunction(PB_Map_FindMapElement)

typedef struct PB_MapElementStructure
{
  struct PB_MapElementStructure *Next;
  union
  {
    TCHAR *String;
    integer Value;
  } Key;
}
PB_MapElement;


typedef struct PB_MapPositionStructure
{
  struct PB_MapPositionStructure *Next;
  PB_MapElement *Element;
  int Index;
} PB_MapPosition;

typedef struct PB_Map
{
  PB_MapElement  *CurrentElement;
  PB_MapElement **Table;
  PB_MapElement  *PreviousElement; // For DeleteMapElement() support
  PB_MapElement  *DummyElement;    // Map dummy element, to support access on element which doesn't exists
  integer        *StructureMap;
  int             CurrentIndex;
  int             PreviousIndex;   // For DeleteMapElement() support
  integer         ElementSize;
  int             ElementType;
  int             HashSize;
  int             NbElements;
  int             Flags;
  struct PB_Map  **Address;
  
  PB_MapPosition *PositionStack;
  
  // Every Map has its private allocator, so we can call ClearAll() for a fast ClearMap()
  // Also this way Lists in separate threads work without a lock for allocation
  PB_BlockAlloc *Allocator;
}
PB_Map;

#define PB_Map_CaseInsensitive  (1 << 0)
#define PB_Map_DynamicStructure (1 << 1)
#define PB_Map_Numeric          (1 << 2)
#define PB_Map_DummyElementInitialized (1 << 3)

#define PB_Map_NoElementCheck 0
#define PB_Map_ElementCheck   1

// Do nothing
#define PB_Map_NumericHash(Key) Key


M_PBFUNCTION(PB_MapElement *) PB_NextMapElement(PB_Map *Map);
M_PBFUNCTION(void *)          PB_FindMapElement(PB_Map *Map, const TCHAR *Key);
M_PBFUNCTION(void *)          PB_FindNumericMapElement(PB_Map *Map, integer Key);
M_PBFUNCTION(void)            PB_ResetMap(PB_Map *Map);
M_PBFUNCTION(void)            PB_ClearMap(PB_Map *Map);
M_PBFUNCTION(void *)          PB_AddMapElement(PB_Map *Map, const TCHAR *Key);
M_PBFUNCTION(void *)          PB_AddMapElement2(PB_Map *Map, const TCHAR *Key, int ElementCheck);
M_PBFUNCTION(void *)          PB_AddNumericMapElement(PB_Map *Map, integer Key);
M_PBFUNCTION(void *)          PB_AddNumericMapElement2(PB_Map *Map, integer Key, int ElementCheck);
M_PBFUNCTION(void *)          PB_DeleteNumericMapElement2(PB_Map *Map, integer Key);
M_PBFUNCTION(void *)          PB_DeleteNumericMapElement(PB_Map *Map);
M_PBFUNCTION(void *)          PB_DeleteMapElement2(PB_Map *Map, const TCHAR *Key);
M_PBFUNCTION(void *)          PB_DeleteMapElement(PB_Map *Map);
M_PBFUNCTION(PB_Map *)        PB_NewMap(integer ElementSize, int ElementType, integer *StructureMap, PB_Map **Address, int HashSize);
M_PBFUNCTION(PB_Map *)        PB_NewNumericMap(integer ElementSize, integer *StructureMap, PB_Map **Address, int HashSize);
M_PBFUNCTION(integer)         PB_CopyMap(PB_Map *Map, PB_Map *DestinationMap);
M_PBFUNCTION(integer)         PB_CopyMap2(PB_Map *Map, PB_Map *DestinationMap, int Clear);
M_PBFUNCTION(void)            PB_FreeMap(PB_Map *Map);
M_PBFUNCTION(PB_MapElement *) PB_GetMapElement(PB_Map *Map, const TCHAR *Key);
M_PBFUNCTION(void *)          PB_CreateMapElement(PB_Map *Map, const TCHAR *Key);
M_PBFUNCTION(PB_MapElement *) PB_GetNumericMapElement(PB_Map *Map, integer Key);
M_PBFUNCTION(integer)         PB_MapSize(PB_Map *Map);
M_PBFUNCTION(void)            PB_MapKey(PB_Map *Map, int PreviousPosition);
M_PBFUNCTION(void)            PB_PushMapPosition(PB_Map *Map);
M_PBFUNCTION(void)            PB_PopMapPosition(PB_Map *Map);

// Private functions
unsigned int PB_Map_Hash(const TCHAR *str);
unsigned int PB_Map_HashCaseInsensitive(const TCHAR *str);
M_PBFUNCTION(PB_MapElement *) PB_Map_FindMapElement(PB_Map *Map, const TCHAR *Key, int *Hash, PB_MapElement **PreviousElement); // does not change current

// define macros for the alloc/free functions to better test, debug and benchmark the optimized allocation
// Note: we don't use the generic 'M_AllocateElement' or it won't mix with LinkedList header
//
#define M_AllocateMapElement(Map)      PB_Object_BlockAlloc(((PB_Map *)Map)->Allocator)
#define M_FreeMapElement(Map, Element) PB_Object_BlockFree(((PB_Map *)Map)->Allocator, (void *)(Element))  

// define this only if there is a faster free method than calling M_FreeElement() on all items separately
#define M_FreeAllMapElements(Map)      PB_Object_BlockClearAll(((PB_Map *)Map)->Allocator)

#endif
