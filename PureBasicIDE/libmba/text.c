/* text - uniform multi-byte/wide text handling
 * Copyright (c) 2003 Michael B. Allen <mba2000 ioplex.com>
 *
 * The MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#include <stdlib.h>
#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <wchar.h>
#include <wctype.h>

#include "mba/msgno.h"
#include "mba/text.h"

int
str_length(const unsigned char *src, const unsigned char *slim)
{
  const unsigned char *start = src;

  if (src == NULL || src >= slim) {
    return 0;
  }
  while (*src) {
    src++;
    if (src == slim) {
      return 0;
    }
  }

  return src - start;
}
int
wcs_length(const wchar_t *src, const wchar_t *slim)
{
  const wchar_t *start = src;

  if (src == NULL || src >= slim) {
    return 0;
  }
  while (*src) {
    src++;
    if (src == slim) {
      return 0;
    }
  }

  return src - start;
}
size_t
str_size(const unsigned char *src, const unsigned char *slim)
{
  const unsigned char *start = src;

  if (src == NULL || src >= slim) {
    return 0;
  }
  while (*src) {
    src++;
    if (src == slim) {
      return 0;
    }
  }

  return (src - start + 1) * sizeof *src;
}
size_t
wcs_size(const wchar_t *src, const wchar_t *slim)
{
  const wchar_t *start = src;

  if (src == NULL || src >= slim) {
    return 0;
  }
  while (*src) {
    src++;
    if (src == slim) {
      return 0;
    }
  }

  return (src - start + 1) * sizeof *src;
}
int
str_copy(const unsigned char *src, const unsigned char *slim,
    unsigned char *dst, unsigned char *dlim, int n)
{
  unsigned char *start = dst;

  if (dst == NULL || dst >= dlim) {
    return 0;
  }
  if (src == NULL || src >= slim) {
    *dst = '\0';
    return 0;
  }
  while (n-- && *src) {
    *dst++ = *src++;
    if (src == slim || dst == dlim) {
      dst = start;
      break;
    }
  }
  *dst = '\0';

  return dst - start;
}
int
wcs_copy(const wchar_t *src, const wchar_t *slim,
    wchar_t *dst, wchar_t *dlim, int n)
{
  wchar_t *start = dst;

  if (dst == NULL || dst >= dlim) {
    return 0;
  }
  if (src == NULL || src >= slim) {
    *dst = L'\0';
    return 0;
  }
  while (n-- && *src) {
    *dst++ = *src++;
    if (src == slim || dst == dlim) {
      dst = start;
      break;
    }
  }
  *dst = L'\0';

  return dst - start;
}
int
str_copy_new(const unsigned char *src,
  const unsigned char *slim,
  unsigned char **dst,
  int n,
  struct allocator *al)
{
  const unsigned char *start = src;
  size_t siz;

  if (dst == NULL) {
    return 0;
  }
  if (src == NULL || src >= slim) {
    *dst = NULL;
    return 0;
  }
  while (n-- && *src) {
    src++;
    if (src == slim) {
      *dst = NULL;
      return 0;
    }
  }
  siz = src - start + 1;
  if ((*dst = allocator_alloc(al, siz, 0)) == NULL) {
    return -1;
  }
  memcpy(*dst, start, siz);
  (*dst)[src - start] = '\0';

  return src - start;
}
int
wcs_copy_new(const wchar_t *src,
  const wchar_t *slim,
  wchar_t **dst,
  int n,
  struct allocator *al)
{
  const wchar_t *start = src;
  size_t siz;

  if (dst == NULL) {
    return 0;
  }
  if (src == NULL || src >= slim) {
    *dst = NULL;
    return 0;
  }
  while (n-- && *src) {
    src++;
    if (src == slim) {
      *dst = NULL;
      return 0;
    }
  }
  siz = (src - start + 1) * sizeof *src;
  if ((*dst = allocator_alloc(al, siz, 0)) == NULL) {
    return -1;
  }
  memcpy(*dst, start, siz);
  (*dst)[src - start] = L'\0';

  return src - start;
}
/* Standard UTF-8 decoder
 */
int
utf8towc(const unsigned char *src, const unsigned char *slim, wchar_t *wc)
{
  const unsigned char *start = src;
  ptrdiff_t n = slim - src;

  if (n < 1) return 0;

  if (*src < 0x80) {
    *wc = *src;
  } else if ((*src & 0xE0) == 0xC0) {
    if (n < 2) return 0;
    *wc = (*src++ & 0x1F) << 6;
    if ((*src & 0xC0) != 0x80) {
      errno = EILSEQ;
      return -1;
    } else {
      *wc |= *src & 0x3F;
    }
    if (*wc < 0x80) {
      errno = EILSEQ;
      return -1;
    }
  } else if ((*src & 0xF0) == 0xE0) {
    if (n < 3) return 0;
    if (sizeof *wc < 3) {
      errno = EILSEQ; /* serrogates not supported */
      return -1;
    }
    *wc = (*src++ & 0x0F) << 12;
    if ((*src & 0xC0) != 0x80) {
      errno = EILSEQ;
      return -1;
    } else {
      *wc |= (*src++ & 0x3F) << 6;
      if ((*src & 0xC0) != 0x80) {
        errno = EILSEQ;
        return -1;
      } else {
        *wc |= *src & 0x3F;
      }
    }
    if (*wc < 0x800) {
      errno = EILSEQ;
      return -1;
    }
  } else if ((*src & 0xF8) == 0xF0) {
    if (n < 4) return 0;
    *wc = (*src++ & 0x07) << 18;
    if ((*src & 0xC0) != 0x80) {
      errno = EILSEQ;
      return -1;
    } else {
      *wc |= (*src++ & 0x3F) << 12;
      if ((*src & 0xC0) != 0x80) {
        errno = EILSEQ;
        return -1;
      } else {
        *wc |= (*src++ & 0x3F) << 6;
        if ((*src & 0xC0) != 0x80) {
          errno = EILSEQ;
          return -1;
        } else {
          *wc |= *src & 0x3F;
        }
      }
    }
    if (*wc < 0x10000) {
      errno = EILSEQ;
      return -1;
    }
  }
  src++;

  return src - start;
}
int
utf8casecmp(const unsigned char *str1, const unsigned char *str1lim,
    const unsigned char *str2, const unsigned char *str2lim)
{
  int n1, n2;
  wchar_t ucs1, ucs2;
  int ch1, ch2;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
  mbstate_t ps1, ps2;

  memset(&ps1, 0, sizeof(ps1));
  memset(&ps2, 0, sizeof(ps2));
  while (str1 < str1lim && str2 < str2lim) {
    if ((*str1 & 0x80) && (*str2 & 0x80)) {           /* both multibyte */
      if ((n1 = mbrtowc(&ucs1, (const char *)str1, str1lim - str1, &ps1)) < 0 ||
          (n2 = mbrtowc(&ucs2, (const char *)str2, str2lim - str2, &ps2)) < 0) {
#else
  while (str1 < str1lim && str2 < str2lim) {
    if ((*str1 & 0x80) && (*str2 & 0x80)) {           /* both multibyte */
      if ((n1 = mbtowc(&ucs1, (const char *)str1, str1lim - str1)) < 0 ||
          (n2 = mbtowc(&ucs2, (const char *)str2, str2lim - str2)) < 0) {
#endif

        PMNO(errno);
        return -1;
      }
      if (ucs1 != ucs2 && (ucs1 = towupper(ucs1)) != (ucs2 = towupper(ucs2))) {
        return ucs1 < ucs2 ? -1 : 1;
      }
      str1 += n1;
      str2 += n2;
    } else {                                /* neither or one multibyte */
      ch1 = *str1;
      ch2 = *str2;

      if (ch1 != ch2 && (ch1 = toupper(ch1)) != (ch2 = toupper(ch2))) {
        return ch1 < ch2 ? -1 : 1;
      } else if (ch1 == '\0') {
        return 0;
      }
      str1++;
      str2++;
    }
  }

  return 0;
}
int
utf8tolower(unsigned char *str, unsigned char *slim)
{
  unsigned char *start = str;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
  mbstate_t psw, psm;

  memset(&psw, 0, sizeof(psw));
  memset(&psm, 0, sizeof(psm));
#endif

  while (str < slim && *str) {
    if ((*str & 0x80) == 0) {
      *str = tolower(*str);
      ++str;
    } else {
      wchar_t wc, wcl;
      size_t n;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
      if ((n = mbrtowc(&wc, (const char *)str, slim - str, &psw)) == (size_t)-1) {
        PMNO(errno);
        return -1;
      }
      if ((wcl = towlower(wc)) != wc) {
/* These functions are flawed because there are a few characters that encode
 * as a different number of bytes depending on whether or not it's the
 * upper or lower case version of the UCS code. Right here we to see if
 * it didn't convert back to same size as lowercase and if so, return -1.
 */
        if (wcrtomb((char *)str, wcl, &psm) != n) {
#else
      if ((n = mbtowc(&wc, (const char *)str, slim - str)) == (size_t)-1) {
        PMNO(errno);
        return -1;
      }
      if ((wcl = towlower(wc)) != wc) {
        if ((size_t)wctomb((char *)str, wcl) != n) {
#endif
          PMNO(errno);
          return -1;
        }
      }
      str += n;
    }
  }

  return str - start;
}
int
utf8toupper(unsigned char *str, unsigned char *slim)
{
  unsigned char *start = str;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
  mbstate_t psw, psm;

  memset(&psw, 0, sizeof(psw));
  memset(&psm, 0, sizeof(psm));
#endif

  while (str < slim && *str) {
    if ((*str & 0x80) == 0 && 0) {
      *str = toupper(*str);
      ++str;
    } else {
      wchar_t wc, wcu;
      size_t n;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
      if ((n = mbrtowc(&wc, (const char *)str, slim - str, &psw)) == (size_t)-1) {
        PMNO(errno);
        return -1;
      }
      if ((wcu = towupper(wc)) != wc) {
        if (wcrtomb((char *)str, wcu, &psm) != n) {
#else
      if ((n = mbtowc(&wc, (const char *)str, slim - str)) == (size_t)-1) {
        PMNO(errno);
        return -1;
      }
      if ((wcu = towupper(wc)) != wc) {
        if ((size_t)wctomb((char *)str, wcu) != n) {
#endif
          PMNO(errno);
          return -1;
        }
      }
      str += n;
    }
  }

  return str - start;
}

/* Even though fputws is defined in C99 and UNIX98 we cannot safely mix
 * wide character I/O with regular so we might as well just unconditionally
 * use our own
 */
int
_fputws(const wchar_t *buf, FILE *stream)
{
  char mb[16];
  int n = 0;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
  mbstate_t ps;
    memset(&ps, 0, sizeof(ps));
    while (*buf) {
    if ((n = wcrtomb(mb, *buf, &ps)) == -1) {
#else
    while (*buf) {
    if ((n = wctomb(mb, *buf)) == -1) {
#endif
      PMNO(errno);
      return -1;
    }
    if (fwrite(mb, n, 1, stream) != 1) {
      PMNO(errno);
      return -1;
    }
    buf++;
  }
  return 0;
}

#if !defined(_GNU_SOURCE)

#if !defined(_BSD_SOURCE) && \
  !defined(_XOPEN_SOURCE_EXTENDED) && \
  !defined(_WIN32) && \
  !(defined(__APPLE__) && defined(__MACH__))
char *
strdup(const char *s)
{
  return s ? strcpy(malloc(strlen(s) + 1), s) : NULL;
}
#endif

wchar_t *
wcsdup(const wchar_t *s)
{
  return s ? wcscpy(malloc((wcslen(s) + 1) * sizeof *s), s) : NULL;
}
size_t
strnlen(const char *s, size_t maxlen)
{
  size_t len;
  for (len = 0; *s && len < maxlen; s++, len++);
  return len;
}

#if (__STDC_VERSION__ < 199901L) && \
  !defined(_BSD_SOURCE) && \
  (_XOPEN_VERSION < 500) && \
  !(defined(__APPLE__) && defined(__MACH__))
int
vsnprintf(char *str, size_t size, const char *format, va_list ap)
{
  (void)size;
  return vsprintf(str, format, ap);
}
#endif

size_t
wcsnlen(const wchar_t *s, size_t maxlen)
{
  size_t len;
  for (len = 0; *s && len < maxlen; s++, len++);
  return len;
}
int
wcscasecmp(const wchar_t *s1, const wchar_t *s2)
{
  wchar_t c1, c2;

  do {
    c1 = *s1++;
    c2 = *s2++;
    if (c1 == L'\0' || c2 == L'\0') {
      break;
    }
    if (c1 != c2) {
      c1 = towupper(c1);
      c2 = towupper(c2);
    }
  } while (c1 == c2);

  return c1 - c2;
}

#endif

/* "dumb" snprintf that just returns -1 if the buffer wasn't large enough
 */
int
dsnprintf(char *str, size_t size, const char *format, ...)
{
  va_list ap;
  int n;

  va_start(ap, format);
  n = vsnprintf(str, size, format, ap);
  va_end(ap);

  if (n < 0) {
    PMNO(errno);
    return -1;
  } else if ((size_t)n >= size) {
    PMNO(errno = ENOBUFS);
    return -1;
  }

  return n;
}

