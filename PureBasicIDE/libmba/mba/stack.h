#ifndef MBA_STACK_H
#define MBA_STACK_H

/* stack - a dynamically resizing stack
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

struct stack {
	unsigned int max;
	unsigned int sp;
	unsigned int size;
	void **array;
	struct allocator *al;
};

LIBMBA_API int stack_init(struct stack *s, unsigned int max_size, struct allocator *al);
LIBMBA_API int stack_deinit(struct stack *s, del_fn data_del, void *context);
LIBMBA_API struct stack *stack_new(unsigned int max_size, struct allocator *al);
LIBMBA_API int stack_del(struct stack *s, del_fn data_del, void *context);
LIBMBA_API int stack_clear(struct stack *s, del_fn data_del, void *context);
LIBMBA_API int stack_clean(struct stack *s);

LIBMBA_API int stack_push(struct stack *s, void *data);
LIBMBA_API void *stack_pop(struct stack *s);
LIBMBA_API int stack_is_empty(const struct stack *s);
LIBMBA_API unsigned int stack_size(const struct stack *s);
LIBMBA_API void stack_iterate(void *s, iter_t *iter);
LIBMBA_API void *stack_next(void *s, iter_t *iter);
LIBMBA_API void *stack_peek(struct stack *s);
LIBMBA_API void *stack_get(struct stack *s, unsigned int idx);

#ifdef __cplusplus
}
#endif

#endif /* MBA_STACK_H */

