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
 * Internal header file for the object library with actual structure definitions
 * Use this only in the Object lib itself
 */

#include <Object/Object.h> // public header



struct PB_ObjectStructure // PB_Object
{
  int StructureSize;
  int IncrementStep;

  integer ObjectsNumber;            // defined integer for better alignment below
  integer **ElementTable;           // Table for static ID objects (2x * to check if the object number inside is 0 or not)
  PB_SimpleList *ListFirstElement;  // for PB_Any objects

  ObjectFreeFunction FreeID;        // to call when reallocating a static ID

  integer CurrentID;             // for the object enumeration without callback (static id)
  PB_SimpleList *CurrentElement; // (dynamic id)

  #ifdef THREAD
    // the mutex locking is now the only difference for the thread/nothread implementation
    M_MUTEX ObjectMutex;
  #endif
};



// Block allocator
//

//
// Note: The MergeLists() command makes use of the internals of this structure so it can
//   have a fast implementation. If you change anything here, make sure to make the needed
//   changes there as well.
//

struct PB_BlockStruct;

typedef struct PB_BlockElementStruct
{
  union
  {
    struct PB_BlockStruct        *Block;
    struct PB_BlockElementStruct *NextFree;
  };
} PB_BlockElement;

typedef struct PB_BlockStruct
{
  struct PB_BlockStruct *Next;
  struct PB_BlockStruct *Previous;
  PB_BlockElement *FirstFree;
  int Size;
  int NextIndex;
  int FreeCount;

  #ifdef PB_64
    int _alignment; // make sure all elements remain properly aligned (for access speed)
  #endif

  PB_BlockElement Elements[];
} PB_Block;

// for shared allocators
//
typedef struct PB_BlockSharedStruct
{
  struct PB_BlockSharedStruct *Next;    // linked list
  struct PB_BlockSharedStruct *Previous;
  struct PB_BlockAllocStruct  *Alloc;   // allocator
  integer StructureSize;
  int Flags;
  int RefCount;
} PB_BlockShared;

struct PB_BlockAllocStruct // PB_BlockAlloc
{
  PB_Block *FirstFullBlock;
  PB_Block *FirstFreeBlock;

  PB_BlockShared *Shared; // for shared allocators

  integer TotalAllocated;
  integer StructureSize;
  int     MinCount;
  int     MaxCount;
  int     NeedLock;

  M_MUTEX Mutex;       // locking is now determined by a flag
};

