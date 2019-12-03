#ifndef MBA_EVAL_H
#define MBA_EVAL_H

/* eval - calculate a simple arithmetic expression
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

#include <mba/text.h>

struct eval;

typedef int (*symlook_fn)(const tchar *name, unsigned long *val, void *context);

LIBMBA_API struct eval *eval_new(symlook_fn symlook, void *context);
LIBMBA_API int eval_del(struct eval *eval);
LIBMBA_API int eval_expression(struct eval *eval,
		const tchar *expr,
		const tchar *elim,
		unsigned long *result);

#ifdef __cplusplus
}
#endif

#endif /* MBA_EVAL_H */

