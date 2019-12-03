#ifndef MBA_TIME_H
#define MBA_TIME_H

/* time - supplimentary time functions
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

#if (__STDC_VERSION__ >= 199901L)
#include <stdint.h> /* C99 */
#elif defined(_XOPEN_SOURCE) && (_XOPEN_VERSION >= 500)
#include <inttypes.h> /* UNIX98 */
#elif defined(_MSC_VER)
typedef unsigned __int8 uint8_t;
typedef unsigned __int16 uint16_t;
typedef unsigned __int32 uint32_t;
typedef unsigned __int64 uint64_t;
#define MILLISECONDS_BETWEEN_1970_AND_1601 11644473600000Ui64
#else
#include <inttypes.h> /* punt! */
#endif

LIBMBA_API uint64_t time_current_millis(void);

#ifdef __cplusplus
}
#endif

#endif /* MBA_TIME_H */
