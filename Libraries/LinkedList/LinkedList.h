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

#ifndef PB_LINKEDLIST_H
#define PB_LINKEDLIST_H

#include <PureLibrary.h>
#include <Object/Object.h>

// for MoveElement()
//
#define PB_List_First  1
#define PB_List_Last   2
#define PB_List_Before 3
#define PB_List_After  4

typedef struct PB_ListHeader
{
  struct PB_ListHeader *Next;
  struct PB_ListHeader *Previous;
} PB_ListHeader;

typedef struct PB_ListPosition
{
  struct PB_ListPosition *Next;
  PB_ListHeader *Element;
} PB_ListPosition;

struct PB_ListObject;

typedef struct PB_List
{
  PB_ListHeader *First;
  PB_ListHeader *Last;
  PB_ListHeader *Current; // Don't move it, as it is used internally by the compiler
  PB_ListHeader **CurrentVariable;
  
  integer NbElements;
  integer Index;
  integer *StructureMap;
  
  // Every List has its private allocator, so we can call ClearAll() for a fast ClearList()
  // Also this way Lists in separate threads work without a lock for allocation
  PB_BlockAlloc *Allocator;
  
  // see PushListPosition.c
  PB_ListPosition *PositionStack;

  struct PB_ListObject *Object;

  integer ElementSize;      // moved here for better alignment on X64
  int ElementType;
  char IsIndexInvalid;
  char IsDynamic;
  char IsDynamicObject;
}
PB_List;


/* In PB, a list is a combo of the real list and the current element, to have a fast access to it.
 */
typedef struct PB_ListObject
{
  PB_List *List;
  PB_ListHeader *CurrentElement;
}
PB_ListObject;


typedef struct
{
  PB_ListHeader Header;
	union
	{
  	int   Long;
		char *String;
	} Type;
} PB_ListElement;

M_PBFUNCTION(PB_List *) PB_NewList(integer ElementSize, PB_ListObject *ListObject, integer *StructureMap, int ElementType);
M_PBFUNCTION(void *)  PB_AddElement(PB_List *List);     // Returns PB_ListHeader * (we use void * to avoid lot of cast when using it in C source (OS X))
M_PBFUNCTION(void *)  PB_CurrentElement(PB_List *List); // Returns PB_ListHeader *
M_PBFUNCTION(void *)  PB_FirstElement(PB_List *List);   // Returns PB_ListHeader *
M_PBFUNCTION(void *)  PB_InsertElement(PB_List *List);  // Returns PB_ListHeader *
M_PBFUNCTION(void *)  PB_LastElement(PB_List *List);    // Returns PB_ListHeader *
M_PBFUNCTION(void *)  PB_NextElement(PB_List *List);    // Returns PB_ListHeader *
M_PBFUNCTION(void *)  PB_PreviousElement(PB_List *List);// Returns PB_ListHeader *
M_PBFUNCTION(void *)  PB_SelectElement(PB_List *List, integer Index); // Returns PB_ListHeader *
M_PBFUNCTION(void)    PB_ResetList(PB_List *List);
M_PBFUNCTION(void)    PB_ChangeElement(PB_List *List, int NewElement);
M_PBFUNCTION(void)    PB_ChangeCurrentElement(PB_List *List, void *Element);
M_PBFUNCTION(integer) PB_ListSize(PB_List *List);
M_PBFUNCTION(void *)  PB_DeleteElement(PB_List *List);
M_PBFUNCTION(void *)  PB_DeleteElement2(PB_List *List, int Flags);
M_PBFUNCTION(void)    PB_FreeList(PB_List *List);
M_PBFUNCTION(void)    PB_ClearList(PB_List *List);
M_PBFUNCTION(integer) PB_ListIndex(PB_List *List);
M_PBFUNCTION(integer) PB_CopyList(const PB_List *List, PB_List *DestinationList);
M_PBFUNCTION(integer) PB_CopyList2(const PB_List *List, PB_List *DestinationList, int Clear);
M_PBFUNCTION(void)    PB_SwapElements(PB_List *LinkedList, PB_ListHeader *FirstElement, PB_ListHeader *SecondElement);

// define macros for the alloc/free functions to better test, debug and benchmark the optimized allocation
//
// #define M_AllocateElement(List)      ((PB_ListHeader *)M_Alloc(((PB_List *)(List))->ElementSize))
// #define M_FreeElement(List, Element) M_Free((char *)(Element))

#define M_AllocateElement(List)      ((PB_ListHeader *)PB_Object_BlockAlloc(((PB_List *)List)->Allocator))
#define M_FreeElement(List, Element) PB_Object_BlockFree(((PB_List *)List)->Allocator, (void *)(Element))

// define this only if there is a faster free method than calling M_FreeElement() on all items separately
#define M_FreeAllElements(List)      PB_Object_BlockClearAll(((PB_List *)List)->Allocator)

#endif

