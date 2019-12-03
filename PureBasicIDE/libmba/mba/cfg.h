#ifndef MBA_CFG_H
#define MBA_CFG_H

/* cfg - persistent configuration properties interface
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

#include <stdio.h>
#include <mba/iterator.h>
#include <mba/allocator.h>
#include <mba/linkedlist.h>
#include <mba/text.h>

struct cfg {
	struct linkedlist list;
	struct allocator *al;
	tchar buf[512];
};

LIBMBA_API int cfg_init(struct cfg *cfg, struct allocator *al);
LIBMBA_API int cfg_deinit(struct cfg *cfg);
LIBMBA_API struct cfg *cfg_new(struct allocator *al);
LIBMBA_API int cfg_del(struct cfg *cfg);

LIBMBA_API int cfg_load(struct cfg *cfg, const char *filename);
LIBMBA_API int cfg_load_str(struct cfg *cfg, const tchar *src, const tchar *slim);
LIBMBA_API int cfg_load_env(struct cfg *cfg);
LIBMBA_API int cfg_load_cgi_query_string(struct cfg *cfg, const tchar *qs, const tchar *qslim);
LIBMBA_API int cfg_store(struct cfg *cfg, const char *filename);
LIBMBA_API int cfg_fwrite(struct cfg *cfg, FILE *stream);

LIBMBA_API int cfg_get_str(struct cfg *cfg, tchar *dst, int dn, const tchar *def, const tchar *name);
LIBMBA_API int cfg_vget_str(struct cfg *cfg, tchar *dst, int dn, const tchar *def, const tchar *name, ...);
LIBMBA_API int cfg_get_short(struct cfg *cfg, short *dst, short def, const tchar *name);
LIBMBA_API int cfg_vget_short(struct cfg *cfg, short *dst, short def, const tchar *name, ...);
LIBMBA_API int cfg_get_int(struct cfg *cfg, int *dst, int def, const tchar *name);
LIBMBA_API int cfg_vget_int(struct cfg *cfg, int *dst, int def, const tchar *name, ...);
LIBMBA_API int cfg_get_long(struct cfg *cfg, long *dst, long def, const tchar *name);
LIBMBA_API int cfg_vget_long(struct cfg *cfg, long *dst, long def, const tchar *name, ...);
LIBMBA_API void cfg_iterate(void *cfg, iter_t *iter);
LIBMBA_API const tchar *cfg_next(void *cfg, iter_t *iter);
LIBMBA_API int cfg_clear(struct cfg *cfg);

#ifdef __cplusplus
}
#endif

#endif /* MBA_CFG_H */

