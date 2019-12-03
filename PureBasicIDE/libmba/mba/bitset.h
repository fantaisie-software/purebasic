#ifndef MBA_BITSET_H
#define MBA_BITSET_H

/* bitset - a set of bits
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

LIBMBA_API int bitset_isset(void *ptr, int bit);
LIBMBA_API int bitset_set(void *ptr, int bit);
LIBMBA_API int bitset_unset(void *ptr, int bit);
LIBMBA_API void bitset_toggle(void *ptr, int bit);
LIBMBA_API int bitset_find_first(void *ptr, void *plim, int val);
LIBMBA_API void bitset_iterate(iter_t *iter);
LIBMBA_API int bitset_next(void *ptr, void *plim, iter_t *iter);

#ifdef __cplusplus
}
#endif

#endif /* MBA_BITSET_H */

