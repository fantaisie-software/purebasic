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

#ifndef PB_ARRAY_H
#define PB_ARRAY_H

#include <PureLibrary.h>


// On x86, all the array routine are in assembly, but we have some C functions
// which need to access the array data (like 'Sort' etc.)
//
// Assembly and C function share the same array structure
//
typedef struct PB_Array
{
  int       NbDimensions;
	integer   ElementSize;
	integer  *StructureMap;
	struct PB_Array **Address;
	integer   NbElements; // Warning, if you add or change an item, the compiler needs to be modified (for runtime array bound check)
	int       Type; 
} PB_Array;


M_SYSFUNCTION(void) SYS_ReAllocateArray(integer NbElements, integer **ArrayBase);
M_SYSFUNCTION(void) SYS_ReAllocateMultiArray(int NbDimensions, integer **ArrayBase);
M_SYSFUNCTION(void) SYS_FreeArray(PB_Array *Array);
M_PBFUNCTION(void) PB_FreeArray(PB_Array *Array);
M_PBFUNCTION(integer) PB_CopyArray2(const PB_Array *Array, PB_Array *DestinationArray, int Clear);
M_PBFUNCTION(integer) PB_CopyArray(const PB_Array *Array, PB_Array *DestinationArray);
M_SYSFUNCTION(PB_Array *) SYS_AllocateArray(integer ElementSize, integer NbElements, int Type, integer *StructureMap, PB_Array **Address);
M_SYSFUNCTION(PB_Array *) SYS_AllocateMultiArray(integer NbDimensions, integer ElementSize, int Type, integer *StructureMap, integer *Address);
M_PBFUNCTION(integer) PB_ArraySize2(PB_Array *Array, int Dimension);
M_PBFUNCTION(integer) PB_ArraySize(PB_Array *Array);

#endif
