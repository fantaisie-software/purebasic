#ifndef MBA_LINKEDLIST_H
#define MBA_LINKEDLIST_H

/* linkedlist - a singularly linked list
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

#include <mba/iterator.h>
#include <mba/allocator.h>
#include <mba/hashmap.h> /* cmp_fn */

#define CACHE_SIZE 2

struct node {
	struct node *ptr;
	void *data;
};
struct cache_entry {
	unsigned int idx;
	struct node *ent;
};
struct linkedlist {
	unsigned int max_size;
	unsigned int size;
	struct node *first;
	struct node *last;
	struct cache_entry cache[CACHE_SIZE];
	struct allocator *al;
};

LIBMBA_API int linkedlist_init(struct linkedlist *l, unsigned int max_size, struct allocator *al);
LIBMBA_API int linkedlist_deinit(struct linkedlist *l, del_fn data_del, void *context);
LIBMBA_API struct linkedlist *linkedlist_new(unsigned int max_size, struct allocator *al);
LIBMBA_API int linkedlist_del(struct linkedlist *l, del_fn data_del, void *context);
LIBMBA_API int linkedlist_clear(struct linkedlist *l, del_fn data_del, void *context);

LIBMBA_API int linkedlist_add(struct linkedlist *l, const void *data);
LIBMBA_API int linkedlist_insert(struct linkedlist *l, unsigned int idx, const void *data);
LIBMBA_API int linkedlist_insert_sorted(struct linkedlist *l,
    	cmp_fn cmp,
		void *context,
		void **replaced,
		const void *data);
LIBMBA_API int linkedlist_is_empty(const struct linkedlist *l);
LIBMBA_API unsigned int linkedlist_size(const struct linkedlist *l);
LIBMBA_API void *linkedlist_get(struct linkedlist *l, unsigned int idx);
LIBMBA_API void *linkedlist_get_last(const struct linkedlist *l);
LIBMBA_API void linkedlist_iterate(void *l, iter_t *iter);
LIBMBA_API void *linkedlist_next(void *l, iter_t *iter);
LIBMBA_API void *linkedlist_remove(struct linkedlist *l, unsigned int idx);
LIBMBA_API void *linkedlist_remove_last(struct linkedlist *l);
LIBMBA_API void *linkedlist_remove_data(struct linkedlist *l, const void *data);
LIBMBA_API int linkedlist_toarray(struct linkedlist *l, void *array[]);

#ifdef __cplusplus
}
#endif

#endif /* MBA_LINKEDLIST_H */

