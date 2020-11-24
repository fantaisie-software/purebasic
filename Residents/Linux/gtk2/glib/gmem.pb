#G_MEM_ALIGN = 4 ; #GLIB_SIZEOF_VOID_P
#G_MEM_ALIGN = 4 ; #GLIB_SIZEOF_LONG
Structure GMemVTable
 *malloc
 *realloc
 *free
 *calloc
 *try_malloc
 *try_realloc
EndStructure

#G_ALLOC_ONLY = 1
#G_ALLOC_AND_FREE = 2
#G_ALLOCATOR_LIST = (1)
#G_ALLOCATOR_SLIST = (2)
#G_ALLOCATOR_NODE = (3)
