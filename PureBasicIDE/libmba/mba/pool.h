#ifndef MBA_POOL_H
#define MBA_POOL_H

/* pool - a container of recycleable objects
 */

#ifdef __cplusplus
extern "C" {
#endif

#ifndef LIBMBA_API
#ifdef WIN32
# ifdef LIBMBA_EXPORTS
#  define LIBMBA_API  __declspec(dllexport)
# else /* LIBMBA_EXPORTS */
#  define LIBMBA_API  __declspec(dllimport)
# endif /* LIBMBA_EXPORTS */
#else /* WIN32 */
# define LIBMBA_API extern
#endif /* WIN32 */
#endif /* LIBMBA_API */

#include <stddef.h>
#include <mba/stack.h>
#include <mba/iterator.h>
#include <mba/allocator.h>

#define POOL_SIZE_MAX 2040

typedef del_fn rst_fn;

struct pool {
	new_fn object_new;
	del_fn object_del;
	rst_fn object_rst;
	void *context;
	size_t size;
	int flags;
	unsigned char *bitset;
	unsigned int max_size;
	unsigned int unused;
	struct stack stk;
	struct allocator *al;
};

LIBMBA_API int pool_create(struct pool *p,
	unsigned int max_size,
	new_fn object_new,
	del_fn object_del,
	rst_fn object_rst,
	void *context,
	size_t size,
	int undo,
	struct allocator *al);
LIBMBA_API int pool_destroy(struct pool *p);
LIBMBA_API struct pool *pool_new(unsigned int max_size,
	new_fn object_new,
	del_fn object_del,
	rst_fn object_rst,
	void *context,
	size_t size,
	int flags,
	struct allocator *al);
LIBMBA_API int pool_del(struct pool *p);
LIBMBA_API int pool_clean(struct pool *p);

LIBMBA_API void *pool_get(struct pool *p);
LIBMBA_API int pool_release(struct pool *p, void *data);
LIBMBA_API unsigned int pool_size(struct pool *p);
LIBMBA_API unsigned int pool_unused(struct pool *p);
LIBMBA_API void pool_iterate(void *p, iter_t *iter);
LIBMBA_API void *pool_next(void *p, iter_t *iter);

#ifdef __cplusplus
}
#endif

#endif /* MBA_POOL_H */

