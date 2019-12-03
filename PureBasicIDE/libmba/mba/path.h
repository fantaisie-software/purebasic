#ifndef MBA_PATH_H
#define MBA_PATH_H

/* path - manipulate file path names
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

LIBMBA_API int path_canon(const unsigned char *src, const unsigned char *slim,
		unsigned char *dst, unsigned char *dlim,
		int srcsep, int dstsep);
LIBMBA_API unsigned char *path_name(unsigned char *path, unsigned char *plim, int sep);

#ifdef __cplusplus
}
#endif

#endif /* MBA_PATH_H */
