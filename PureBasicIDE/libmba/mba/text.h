#ifndef MBA_TEXT_H
#define MBA_TEXT_H

/* text - uniform multi-byte/wide text handling
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

#include <mba/allocator.h>

#if USE_WCHAR

#include <stdio.h>
#include <stdarg.h>
#include <wchar.h>
#include <wctype.h>

#define TEOF WEOF
typedef wint_t tint_t;
typedef wchar_t tchar;
#ifndef TEXT
#define TEXT(s) L##s
#undef _T
#define _T(s) L##s
#endif

/*
int fwprintf(FILE *stream, const wchar_t *format, ...);
int wprintf(const wchar_t *format, ...);
int vfwprintf(FILE *s, const wchar_t *format, va_list arg);
int vwprintf(const wchar_t *format, va_list arg);
int fwscanf(FILE *stream, const wchar_t *format, ...);
int wscanf(const wchar_t *format, ...);
int vfwscanf(FILE *s, const wchar_t *format, va_list arg);
int vwscanf(const wchar_t *format, va_list arg);
wint_t getwc_unlocked(FILE *stream);
wint_t getwchar_unlocked(void);
wint_t fgetwc_unlocked(FILE *stream);
wint_t fputwc_unlocked(wchar_t wc, FILE *stream);
wint_t putwc_unlocked(wchar_t wc, FILE *stream);
wint_t putwchar_unlocked(wchar_t wc);
wchar_t *fgetws_unlocked(wchar_t *ws, int n, FILE *stream);
int fputws_unlocked(const wchar_t *ws, FILE *stream);
*/

LIBMBA_API int _fputws(const wchar_t *buf, FILE *stream);

#define istalnum iswalnum
#define istalpha iswalpha
#define istcntrl iswcntrl
#define istdigit iswdigit
#define istgraph iswgraph
#define istlower iswlower
#define istprint iswprint
#define istpunct iswpunct
#define istspace iswspace
#define istupper iswupper
#define istxdigit iswxdigit
#define istblank iswblank
#define totlower towlower
#define totupper towupper
#define tcscpy wcscpy
#define tcsncpy wcsncpy
#define tcscat wcscat
#define tcsncat wcsncat
#define tcscmp wcscmp
#define tcsncmp wcsncmp
#define tcscoll wcscoll
#define tcsxfrm wcsxfrm
#define tcscoll_l wcscoll_l
#define tcsxfrm_l wcsxfrm_l
#define tcsdup wcsdup
#define tcschr wcschr
#define tcsrchr wcsrchr
#define tcschrnul wcschrnul
#define tcscspn wcscspn
#define tcsspn wcsspn
#define tcspbrk wcspbrk
#define tcsstr wcsstr
#if defined(_WIN32)
#define tcstok(s,d,p) wcstok(s,d)
#else
#define tcstok wcstok
#endif
#define tcslen wcslen
#define tcsnlen wcsnlen
#define tmemcpy wmemcpy
#define tmemmove wmemmove
#define tmemset wmemset
#define tmemcmp wmemcmp
#define tmemchr wmemchr
#define tcscasecmp wcscasecmp
#define tcsncasecmp wcsncasecmp
#define tcscasecmp_l wcscasecmp_l
#define tcsncasecmp_l wcsncasecmp_l
#define tcpcpy wcpcpy
#define tcpncpy wcpncpy
#define tcstod wcstod
#define tcstof wcstof
#define tcstold wcstold
#define tcstol wcstol
#define tcstoul wcstoul
#define tcstoq wcstoq
#define tcstouq wcstouq
#define tcstoll wcstoll
#define tcstoull wcstoull
#define tcstol_l wcstol_l
#define tcstoul_l wcstoul_l
#define tcstoll_l wcstoll_l
#define tcstoull_l wcstoull_l
#define tcstod_l wcstod_l
#define tcstof_l wcstof_l
#define tcstold_l wcstold_l
#define tcsftime wcsftime
/* Cannot mix wide character I/O with multi-byte string I/O
#define ftprintf fwprintf
#define tprintf wprintf
#define vftprintf vfwprintf
#define vtprintf vwprintf
#define ftscanf fwscanf
#define tscanf wscanf
#define vftscanf vfwscanf
#define vtscanf vwscanf
#define fgettc fgetwc
#define gettc getwc
#define gettchar getwchar
#define gettc_unlocked getwc_unlocked
#define gettchar_unlocked getwchar_unlocked
#define fgettc_unlocked fgetwc_unlocked
#define fputtc fputwc
#define puttc putwc
#define puttchar putwchar
#define fputtc_unlocked fputwc_unlocked
#define puttc_unlocked putwc_unlocked
#define puttchar_unlocked putwchar_unlocked
#define fgetts fgetws
#define fgetts_unlocked fgetws_unlocked
#define fputts_unlocked fputws_unlocked
#define ungettc ungetwc
*/
#define fputts _fputws
#if !defined(_WIN32)
#define stprintf swprintf
#define vstprintf vswprintf
#else
#define stprintf _snwprintf
#define vstprintf _vsnwprintf
#endif
#define stscanf swscanf
#define vstscanf vswscanf

#define text_length wcs_length
#define text_size wcs_size
#define text_copy wcs_copy
#define text_copy_new wcs_copy_new

#else

#include <string.h>
#include <ctype.h>

#define TEOF EOF
typedef int tint_t;
typedef unsigned char tchar;
#ifndef TEXT
#define TEXT(s) s
#undef _T
#define _T(s) s
#endif

#define istalnum isalnum
#define istalpha isalpha
#define istcntrl iscntrl
#define istdigit isdigit
#define istgraph isgraph
#define istlower islower
#define istprint isprint
#define istpunct ispunct
#define istspace isspace
#define istupper isupper
#define istxdigit isxdigit
#define istblank isblank
#define totlower tolower
#define totupper toupper
#define tcscpy strcpy
#define tcsncpy strncpy
#define tcscat strcat
#define tcsncat strncat
#define tcscmp strcmp
#define tcsncmp strncmp
#define tcscoll strcoll
#define tcsxfrm strxfrm
#define tcscoll_l strcoll_l
#define tcsxfrm_l strxfrm_l
#define tcsdup strdup
#define tcschr strchr
#define tcsrchr strrchr
#define tcschrnul strchrnul
#define tcscspn strcspn
#define tcsspn strspn
#define tcspbrk strpbrk
#define tcsstr strstr
#if defined(__GNUC__)
#define tcstok strtok_r
#else
#define tcstok(s,d,p) strtok(s,d)
#endif
#define tcslen strlen
#define tcsnlen strnlen
#define tmemcpy memcpy
#define tmemmove memmove
#define tmemset memset
#define tmemcmp memcmp
#define tmemchr memchr
#define tcscasecmp strcasecmp
#define tcsncasecmp strncasecmp
#define tcscasecmp_l strcasecmp_l
#define tcsncasecmp_l strncasecmp_l
#define tcpcpy stpcpy
#define tcpncpy stpncpy
#define tcstod strtod
#define tcstof strtof
#define tcstold strtold
#define tcstol strtol
#define tcstoul strtoul
#define tcstoq strtoq
#define tcstouq strtouq
#define tcstoll strtoll
#define tcstoull strtoull
#define tcstol_l strtol_l
#define tcstoul_l strtoul_l
#define tcstoll_l strtoll_l
#define tcstoull_l strtoull_l
#define tcstod_l strtod_l
#define tcstof_l strtof_l
#define tcstold_l strtold_l
#define tcsftime strftime
/* Cannot mix wide character I/O with multi-byte string I/O
#define ftprintf fprintf
#define tprintf printf
#define vftprintf vfprintf
#define vtprintf vprintf
#define ftscanf fscanf
#define tscanf scanf
#define vftscanf vfscanf
#define vtscanf vscanf
#define fgettc fgetc
#define gettc getc
#define gettchar getchar
#define gettc_unlocked getc_unlocked
#define gettchar_unlocked getchar_unlocked
#define fgettc_unlocked fgetc_unlocked
#define fputtc fputc
#define puttc putc
#define puttchar putchar
#define fputtc_unlocked fputc_unlocked
#define puttc_unlocked putc_unlocked
#define puttchar_unlocked putchar_unlocked
#define fgetts fgets
#define fgetts_unlocked fgets_unlocked
#define fputts_unlocked fputs_unlocked
#define ungettc ungetc
*/
#define fputts fputs
#if !defined(_WIN32)
#define stprintf snprintf
#define vstprintf vsnprintf
#else
#define stprintf _snprintf
#define vstprintf _vsnprintf
#endif
#define stscanf sscanf
#define vstscanf vsscanf

#define text_length str_length
#define text_size str_size
#define text_copy str_copy
#define text_copy_new str_copy_new

#endif

LIBMBA_API int str_length(const unsigned char *src, const unsigned char *slim);
LIBMBA_API int wcs_length(const wchar_t *src, const wchar_t *slim);
LIBMBA_API size_t str_size(const unsigned char *src, const unsigned char *slim);
LIBMBA_API size_t wcs_size(const wchar_t *src, const wchar_t *slim);
LIBMBA_API int str_copy(const unsigned char *src, const unsigned char *slim,
    unsigned char *dst, unsigned char *dlim, int n);
LIBMBA_API int wcs_copy(const wchar_t *src, const wchar_t *slim,
    wchar_t *dst, wchar_t *dlim, int n);
LIBMBA_API int str_copy_new(const unsigned char *src, const unsigned char *slim,
    unsigned char **dst, int n, struct allocator *al);
LIBMBA_API int wcs_copy_new(const wchar_t *src, const wchar_t *slim,
    wchar_t **dst, int n, struct allocator *al);

LIBMBA_API int utf8towc(const unsigned char *src, const unsigned char *slim, wchar_t *wc);
LIBMBA_API int utf8casecmp(const unsigned char *str1, const unsigned char *str1lim,
    const unsigned char *str2, const unsigned char *str2lim);
LIBMBA_API int utf8tolower(unsigned char *str, unsigned char *slim);
LIBMBA_API int utf8toupper(unsigned char *str, unsigned char *slim);

/* "dumb" snprintf returns -1 on overflow */
LIBMBA_API int dsnprintf(char *str, size_t size, const char *format, ...);

#if !defined(_GNU_SOURCE)

#if !defined(_BSD_SOURCE) && \
  !defined(_XOPEN_SOURCE_EXTENDED) && \
  !defined(_WIN32) && \
  !(defined(__APPLE__) && defined(__MACH__))
LIBMBA_API char *strdup(const char *s);
#endif

#ifndef WINDOWS
LIBMBA_API wchar_t *wcsdup(const wchar_t *s);
LIBMBA_API size_t strnlen(const char *s, size_t maxlen);

#if (__STDC_VERSION__ < 199901L) && \
  !defined(_BSD_SOURCE) && \
  (_XOPEN_VERSION < 500) && \
  !(defined(__APPLE__) && defined(__MACH__))
#include <stdarg.h>
int vsnprintf(char *str, size_t size, const char *format, va_list ap);
#endif

LIBMBA_API size_t wcsnlen(const wchar_t *s, size_t maxlen);
LIBMBA_API int wcscasecmp(const wchar_t *s1, const wchar_t *s2);
#endif

#endif /* _GNU_SOURCE */

/*
wchar_t *wcschrnul(const wchar_t *s, wchar_t wc);
int wcsncasecmp(const wchar_t *s1, const wchar_t *s2, size_t n);
wchar_t *wcpcpy(wchar_t *dest, const wchar_t *src);
wchar_t *wcpncpy(wchar_t *dest, const wchar_t *src, size_t n);
long long int wcstoq(const wchar_t *nptr, wchar_t **endptr, int base);
unsigned long long int wcstouq(const wchar_t *nptr, wchar_t **endptr, int base);
long long int wcstoll(const wchar_t *nptr, wchar_t **endptr, int base);
unsigned long long int wcstoull(const wchar_t *nptr, wchar_t **endptr, int base);
*/

#ifdef __cplusplus
}
#endif

#endif /* MBA_TEXT_H */

