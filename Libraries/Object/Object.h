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
 * Public header. Structures used by the object manager should be treated as opaque
 * on the outside which is why there are only forward declarations here.
 */

#ifndef PB_OBJECT_H
#define PB_OBJECT_H

#include <PureLibrary.h>

typedef void (*ThreadMemoryInitFunction)(void *Memory);
typedef void (*ThreadMemoryEndFunction)(void *Memory);

typedef int  (M_PBVIRTUAL *ObjectEnumerateAllCallback)(integer ID, void *Element, void *Data);
typedef void (M_PBVIRTUAL *ObjectFreeFunction)(integer ID);

struct PB_ObjectStructure;
typedef struct PB_ObjectStructure PB_Object;

M_PBFUNCTION(void *) PB_Object_GetOrAllocateID(PB_Object *Object, integer ID);
M_PBFUNCTION(void *) PB_Object_GetObject      (PB_Object *Object, integer DynamicOrArrayID);
M_PBFUNCTION(void *) PB_Object_IsObject       (PB_Object *Object, integer DynamicOrArrayID);
M_PBFUNCTION(void)   PB_Object_EnumerateAll   (PB_Object *Object, ObjectEnumerateAllCallback Callback, void *Data);
M_PBFUNCTION(void)   PB_Object_EnumerateStart (PB_Object *Object);
M_PBFUNCTION(void)   PB_Object_EnumerateStartRecursive(PB_Object *Object);
M_PBFUNCTION(void *) PB_Object_EnumerateNext  (PB_Object *Object, integer *ID);
M_PBFUNCTION(void *) PB_Object_EnumerateNextRecursive(PB_Object *Object, integer *ID);
M_PBFUNCTION(void)   PB_Object_EnumerateAbort (PB_Object *Object);
M_PBFUNCTION(void)   PB_Object_FreeID         (PB_Object *Object, integer DynamicOrArrayID);
M_PBFUNCTION(void)   PB_Object_CleanAll       (PB_Object *Object);
M_PBFUNCTION(PB_Object *) PB_Object_Init      (int StructureSize, int IncrementStep, ObjectFreeFunction FreeID);
M_PBFUNCTION(integer) PB_Object_Count         (PB_Object *Object);

// Special function which can be called by the debugger
void PB_Object_FreeObjects();

// Get direct access to the first Pointer inside the object or NULL
M_INLINE(void *) PB_Object_GetObjectDirect(PB_Object *Object, integer DynamicOrArrayID)
{
  void **ObjectData = (void **)PB_Object_GetObject(Object, DynamicOrArrayID);
  return ObjectData ? *ObjectData : NULL;
}

/* Simplify working with PB_Any values
 * - if id == PB_Any, returns (integer) pb_obj
 * - else returns id
 * - result is always type integer
 */
#define M_PBANY_ID(id, pb_obj) ((id) == PB_Any ? (integer)(pb_obj) : (id))

/* Simplify returning from PB_Any object creation functions:
 * - if pb_obj is null, returns null
 * - if id == PB_Any, returns pb_pbj
 * - if id != PB_Any, returns the first pointer value inside pb_obj
 * - result is always type (void *)
 */
#define M_PBANY_RESULT(id, pb_obj) (((id) == PB_Any || (pb_obj) == NULL) ? (void *)(pb_obj) : *(void **)(pb_obj))

// Threadlocal memory functions
//
// Note: PB_Object_InitThreadMemory() may only be called from a library init function! Initialization at a
//   later time will cause problems if other threads are already running
//
M_PBFUNCTION(void *)  PB_Object_GetThreadMemory(integer MemoryID);
M_PBFUNCTION(integer) PB_Object_InitThreadMemory(int Size, ThreadMemoryInitFunction InitFunction, ThreadMemoryEndFunction EndFunction);

// Block allocator
//
struct PB_BlockAllocStruct;
typedef struct PB_BlockAllocStruct PB_BlockAlloc;

// flags to decide locking (threadsafe behavior)
//
#define PB_Alloc_LockThreaded 0  // threadsafe depending on the exe's threadsafe mode
#define PB_Alloc_LockAlways   1  // always threadsafe
#define PB_Alloc_LockNever    2  // never threadsafe
#define PB_Alloc_Shared       4  // use a common allocator for the same size and lock flags

M_PBFUNCTION(PB_BlockAlloc *) PB_Object_CreateAllocator (integer StructureSize, int MinCount, int MaxCount, int Flags);
M_PBFUNCTION(void)            PB_Object_DestroyAllocator(PB_BlockAlloc *Alloc);
M_PBFUNCTION(void *)          PB_Object_BlockAlloc      (PB_BlockAlloc *Alloc);
M_PBFUNCTION(void *)          PB_Object_BlockAllocZero  (PB_BlockAlloc *Alloc);
M_PBFUNCTION(void)            PB_Object_BlockFree       (PB_BlockAlloc *Alloc, void *Data);
M_PBFUNCTION(void)            PB_Object_BlockClearAll   (PB_BlockAlloc *Alloc);


/* One-time (threadsafe) initialization functions
 *
 * Use like this:
 *
 *   // define your guard on the toplevel (can also be non-static)
 *   static PB_Object_Guard MyGuard = PB_OBJECT_GUARD_VALUE;
 *
 *   // use this wherever initialization may be needed (will be done just once)
 *   PB_Object_CallOnce(&MyGuard, &MyFunction);
 *
 * Note: Do not call PB_Object_InitThreadMemory in such an initialization function, as this
 *   may only be done from a real library init function (see above)
 *
 * The function PB_Object_InitOnce() can be used to initialize a PB_Object at a late time in
 * a simple way. *Output must be 0 before the call, and will be 0 after. There is no need for a Guard here
 */

#ifdef WINDOWS
  typedef union
  {
    PVOID *Ptr;
  } PB_Object_Guard;
  #define PB_OBJECT_GUARD_VALUE {0}

#else
  typedef pthread_once_t PB_Object_Guard;
  #define PB_OBJECT_GUARD_VALUE PTHREAD_ONCE_INIT
#endif

typedef void (*InitializeOnceFunction)();

M_PBFUNCTION(void) PB_Object_CallOnce(PB_Object_Guard *Guard, InitializeOnceFunction Function);
M_PBFUNCTION(void) PB_Object_InitOnce(PB_Object **Output, int StructureSize, int IncrementStep, ObjectFreeFunction FreeID);

#endif
