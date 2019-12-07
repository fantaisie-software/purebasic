/* cfg - persistent configuration properties interface
 * Copyright (c) 2002 Michael B. Allen <mba2000 ioplex.com>
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
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <stdarg.h>
#include <limits.h>
#include <wchar.h>

#include "mba/msgno.h"
#include "mba/iterator.h"
#include "mba/allocator.h"
#include "mba/linkedlist.h"
#include "mba/cfg.h"
#include "mba/text.h"

#if USE_WCHAR

#define T1PMNF(m,s) PMNF((m), ": %ls", (s))
#define T1AMSG(s) AMSG("%ls", (s))
#else
#define T1PMNF(m,s) PMNF((m), ": %s", (s))
#define T1AMSG(s) AMSG("%s", (s))
#endif

#if defined(__APPLE__) && defined(__MACH__)
#include <crt_externs.h>
#define environ (*_NSGetEnviron())
#endif

int
cfg_init(struct cfg *cfg, struct allocator *al)
{
  if (cfg == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }
  if ((linkedlist_init(&cfg->list, 0, al)) == -1) {
    AMSG("");
    return -1;
  }
  cfg->al = al;

  return 0;
}
int
cfg_deinit(struct cfg *cfg)
{
  if (cfg) {
    int ret = linkedlist_deinit(&cfg->list, allocator_free, cfg->al);
    return ret;
  }

  return 0;
}
struct cfg *
cfg_new(struct allocator *al)
{
  struct cfg *cfg;

  if ((cfg = allocator_alloc(al, sizeof *cfg, 0)) == NULL ||
      cfg_init(cfg, al) == -1) {
    PMNO(errno);
    return NULL;
  }

  return cfg;
}
int
cfg_del(struct cfg *cfg)
{
  int ret = 0;

  if (cfg) {
    ret += cfg_deinit(cfg);
    ret += allocator_free(cfg->al, cfg);
  }

  return ret ? -1 : 0;
}
static int
readline(tchar *buf, FILE *in)
{
  int ch, idx = 0, state = 0, ucs = 0, umul = 0, end = 0;

  if ((ch = fgetc(in)) == EOF) {
    return ferror(in) ? -1 : 0;
  }
  if (ch == _T('\n')) {
    buf[0] = _T('\0');
    return 1;
  }
  buf[idx++] = ch;
  while (idx < BUFSIZ && (ch = fgetc(in)) != -1) {
    switch (state) {
      case 2:
        if (ch != '\n' && istspace(ch)) {
          break;
        }
        state = 0;
      case 0:
        if (ch == '\\') {
          state = 1;
          continue;
        } else if (ch == '\n') {
          buf[end] = _T('\0');
          return idx + 1;
        } else if (ch == '=') {
          state = 2; /* trim leading space */
        } else if (isspace(ch) == 0) {
          end = idx + 1;
        }
        buf[idx++] = ch;
        break;
      case 1: /* escape character */
        state = 0;
        end = idx + 1;
        switch (ch) {
          case '\n':
            state = 2;
            break;
          case 't':
            buf[idx++] = _T('\t');
            break;
          case 'n':
            buf[idx++] = _T('\n');
            break;
          case 'r':
            buf[idx++] = _T('\r');
            break;
          case '\\':
          case '"':
          case '\'':
          case ' ':
            buf[idx++] = ch;
            break;
          case 'u':
            /* \uxxxx unicode escape */
            ucs = 0;
            umul = 1000;
            state = 3;
            break;
        }
        break;
      case 3: /* unicode escape digits */
        if (ch < '0' || ch > '9') {
          PMNO(errno = EINVAL);
          return -1;
        }
        ucs += (ch - '0') * umul;
        if (umul == 0) {
#if USE_WCHAR
          buf[idx++] = ucs;
#else /* convert mbs to ucs code */
          char mb[16];
          size_t n;
#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
          mbstate_t ps;
            memset(&ps, 0, sizeof(ps));
          if ((n = wcrtomb(mb, ucs, &ps)) != (size_t)-1) {
#else
          if ((n = wctomb(mb, ucs)) != (size_t)-1) {
#endif
            PMNO(errno);
            return -1;
          }
          if ((idx + n) >= BUFSIZ) {
            PMNO(errno = E2BIG);
            return -1;
          }
          memcpy(buf + idx, mb, n);
          idx += n;
#endif
          state = 0;
        }

        umul /= 10;
        break;
    }
  }
  if (idx >= BUFSIZ) {
    PMNO(errno = E2BIG);
    return -1;
  }
  buf[idx++] = _T('\0');
  return idx;
}
static int
writeline(tchar *buf, FILE *out)
{
#if USE_WCHAR
  unsigned char mb[16];
  int n = 0;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
  mbstate_t ps;
    memset(&ps, 0, sizeof(ps));
    while (*buf) {
    if ((n = wcrtomb(mb, *buf, &ps)) != -1) {
#else
    while (*buf) {
    if ((n = wctomb(mb, *buf)) != -1) {
#endif
      PMNO(errno);
      return -1;
    }
    if (fwrite(mb, n, 1, out) != 1) {
      PMNO(errno);
      return -1;
    }
    buf++;
  }
#else
  if (fputs((const char *)buf, out) == EOF && ferror(out)) {
    PMNO(errno);
    return -1;
  }
#endif
  return 0;
}
static int
validateline(const tchar *str, const tchar *end)
{
  int state;

  state = 0;
  for ( ; str < end; str++) {
    switch (state) {
      case 0:
        if (*str == _T('\0')) {
          return 1;
        } else if (*str == _T('#') || *str == _T('!')) {
          state = 3;
        } else if (istspace(*str) == 0) {
          state = 1;
        }
        break;
      case 1:
      case 2:
        if (*str == _T('\0')) {
          PMNO(errno = EINVAL);
          return -1;
        } else if (*str == _T('=')) {
          state = 3;
        } else if (istspace(*str)) {
          state = 2;
        } else if (state == 2) {
          PMNO(errno = EINVAL);
          return -1;
        }
        break;
      case 3:
        if (*str == _T('\0')) {
          return 0;
        }
        break;
    }
  }
  PMNO(errno = E2BIG);
  return -1;
}

int
cfg_load_str(struct cfg *cfg, const tchar *src, const tchar *slim)
{
  const tchar *end;
  tchar *line;
  int row, n;

  if (cfg == NULL || src == NULL || slim == NULL) {
    PMNF(errno = EINVAL, ": cfg=%p", cfg);
    return -1;
  }

  end = src;
  for (row = 1; *end; row++) {
    while (*end && *end != _T('\n')) {
      end++;
    }
    if ((n = text_copy_new(src, slim, &line, end - src, cfg->al)) == -1) {
      PMNO(errno);
      return -1;
    }
    if (validateline(line, line + n + 1) == -1 ||
        linkedlist_add(&cfg->list, line) == -1) {
      AMSG("line %d", row);
      linkedlist_clear(&cfg->list, allocator_free, cfg->al);
      return -1;
    }
    if (*end == _T('\0')) {
      break;
    }
    end = src = end + 1;
  }

  return 0;
}
#if !defined(_WIN32)
extern char **environ;
#endif
int
cfg_load_env(struct cfg *cfg)
{
  char **e;

  if (cfg == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }

  for (e = environ; *e; e++) {
    tchar *str;

#if USE_WCHAR
    size_t n;

#if (__STDC_VERSION__ >= 199901L) || (_XOPEN_VERSION >= 500)
    mbstate_t s;
    const char *var;

    var = *e;
    memset(&s, 0, sizeof(s));
    if ((n = mbsrtowcs(NULL, &var, 0, &s)) == (size_t)-1) {
      PMNO(errno);
      return -1;
    }
    n++;

    if ((str = allocator_alloc(cfg->al, n * sizeof *str, 0)) == NULL) {
      PMNO(errno);
      return -1;
    }
    memset(&s, 0, sizeof(s));
    if ((n = mbsrtowcs(str, &var, n, &s)) == (size_t)-1) {
      PMNO(errno);
      allocator_free(cfg->al, str);
      return -1;
    }
#else
    if ((n = mbstowcs(NULL, *e, 0)) == (size_t)-1) {
      PMNO(errno);
      return -1;
    }
    n++;

    if ((str = allocator_alloc(cfg->al, n * sizeof *str, 0)) == NULL) {
      PMNO(errno);
      return -1;
    }
    if ((n = mbstowcs(str, *e, n)) == (size_t)-1) {
      PMNO(errno);
      allocator_free(cfg->al, str);
      return -1;
    }
#endif
#else
    if (text_copy_new((const unsigned char *)*e,
          (const unsigned char *)*e + BUFSIZ,
          &str,
          BUFSIZ,
          cfg->al) == -1 || str == NULL) {
      PMNO(errno);
      return -1;
    }
#endif

    if (validateline(str, str + BUFSIZ) == -1 ||
        linkedlist_add(&cfg->list, str) == -1) {
      AMSG("%s", *e);
      linkedlist_clear(&cfg->list, allocator_free, cfg->al);
      allocator_free(cfg->al, str);
      return -1;
    }
  }

  return 0;
}
int
cfg_load_cgi_query_string(struct cfg *cfg, const tchar *qs, const tchar *qslim)
{
  int state, bi, term;
  tchar buf[BUFSIZ];

  if (cfg == NULL || qs == NULL || qs > qslim) {
    PMNO(errno = EINVAL);
    return -1;
  }

  state = 0;
  bi = 0;
  term = 0;
  do {
    if (qs == qslim || *qs == _T('\0')) {
      term = 1;
    } else {
      buf[bi] = *qs;
    }

    switch (state) {
      case 0:
        if (term) {
          return 0;
        } else if (*qs == _T('&') || *qs == _T('=') || istprint(*qs) == 0) {
          T1PMNF(errno = EINVAL, qs);
          return -1;
        }
        state = 1;
        break;
      case 1:
        if (term || *qs == _T('&')) {
          T1PMNF(errno = EINVAL, qs);
          return -1;
        } else if (*qs == _T('=')) {
          state = 2;
        }
        break;
      case 2:
        if (term || *qs == _T('&')) {
          tchar *str;

          buf[bi] = _T('\0');
          if (validateline(buf, buf + BUFSIZ) == -1 ||
              text_copy_new(buf, buf + BUFSIZ, &str, BUFSIZ, cfg->al) == -1 ||
              str == NULL ||
              linkedlist_add(&cfg->list, str) == -1) {
            T1AMSG(buf);
            return -1;
          }
          if (term) {
            return 0;
          }
          bi = 0;
          state = 0;
          break;
        } else if (*qs == _T('=')) {
          T1PMNF(errno = EINVAL, qs);
          return -1;
        }
        break;
    }
    if (state != 0 && ++bi == BUFSIZ) {
      T1PMNF(errno = EINVAL, qs);
      return -1;
    }
  } while (*qs++);

  return 0;
}
int
cfg_load(struct cfg *cfg, const char *filename)
{
  FILE *fp;
  int row, n;
  tchar buf[BUFSIZ];

  if (cfg == NULL || filename == NULL) {
    PMNF(errno = EINVAL, ": cfg=%p", cfg);
    return -1;
  }

  fp = fopen(filename, "r");
  if (fp == NULL) {
    PMNF(errno, ": %s", filename);
    return -1;
  }

  for (row = 1;; row++) {
    tchar *str;

    if ((n = readline(buf, fp)) == -1) {
      AMSG("");
      fclose(fp);
      return -1;
    } else if (n == 0) {
      break;
    }
    if (validateline(buf, buf + BUFSIZ) == -1 ||
          text_copy_new(buf, buf + BUFSIZ, &str, BUFSIZ, cfg->al) == -1 ||
          str == NULL ||
          linkedlist_add(&cfg->list, str) == -1) {
      AMSG("%s: line %d", filename, row);
      linkedlist_clear(&cfg->list, allocator_free, cfg->al);
      fclose(fp);
      return -1;
    }
  }
  fclose(fp);

  return 0;
}
int
cfg_fwrite(struct cfg *cfg, FILE *stream)
{
  tchar *line;
  iter_t iter;

  if (cfg == NULL || stream == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }

  linkedlist_iterate(&cfg->list, &iter);
  while ((line = linkedlist_next(&cfg->list, &iter)) != NULL) {
    if (writeline(line, stream) == -1) {
      AMSG("");
      return -1;
    }
    fputc('\n', stream);
  }

  return 0;
}
int
cfg_store(struct cfg *cfg, const char *filename)
{
  FILE *fp;
  int ret;

  if (cfg == NULL || filename == NULL) {
    PMNF(errno = EINVAL, ": cfg=%p", cfg);
    return -1;
  }

  fp = fopen(filename, "w");
  if (fp == NULL) {
    PMNF(errno, ": %s", filename);
    return -1;
  }

  ret = cfg_fwrite(cfg, fp);

  fclose(fp);

  return ret;
}

int
cfg_get_str(struct cfg *cfg, tchar *dst, int dn, const tchar *def, const tchar *name)
{
  tchar *str;
  const tchar *p;
  int state, n;
  iter_t iter;

  if (cfg == NULL || dst == NULL || name == NULL || *name == _T('\0')) {
    PMNO(errno = EINVAL);
    return -1;
  }

  linkedlist_iterate(&cfg->list, &iter);
  while ((str = linkedlist_next(&cfg->list, &iter)) != NULL) {
    state = 0;
    p = name;
    for ( ; state != 5; str++) {
      switch (state) {
        case 0:
          if (*str == _T('\0') || *str == _T('!') || *str == _T('#')) {
            state = 5;
            break;
          }
          if (istspace(*str)) {
            break;
          }
          state = 1;
        case 1:
          if (*p == _T('\0') && (istspace(*str) || *str == _T('='))) {
            state = 2;
          } else if (*str == *p) {
            p++;
            break;
          } else {
            state = 5;
            break;
          }
        case 2:
          if (*str == _T('=')) {
            state = 3;
          }
          break;
        case 3:
          n = tcslen((const char *)str);
          if (n >= dn) {
            PMNO(errno = ERANGE);
            return -1;
          }
          memcpy(dst, str, n * sizeof *dst);
          dst[n] = _T('\0');
          return 0;
      }
    }
  }
  if (def) {
    tcsncpy((char *)dst, (const char *)def, dn);
  } else {
    T1PMNF(errno = EFAULT, name);
    return -1;
  }
  return 0;
}
int
cfg_vget_str(struct cfg *cfg, tchar *dst, int dn,
      const tchar *def, const tchar *name, ...)
{
  tchar buf[128];
  va_list ap;

  va_start(ap, name);

  if (vstprintf((char *)buf, 128, (char *)name, ap) == -1) {
    PMNO(errno);
    return -1;
  }
  if (cfg_get_str(cfg, dst, dn, def, buf) == -1) {
    AMSG("");
    return -1;
  }

  va_end(ap);
  return 0;
}
int
cfg_get_short(struct cfg *cfg, short *dst, short def, const tchar *name)
{
  long ul;

  if (cfg_get_long(cfg, &ul, def, name) == -1) {
    AMSG("");
    return -1;
  }
  *dst = ul & 0xFFFF;
  return 0;
}
int
cfg_get_int(struct cfg *cfg, int *dst, int def, const tchar *name)
{
  long ul;

  if (cfg_get_long(cfg, &ul, def, name) == -1) {
    AMSG("");
    return -1;
  }
  *dst = ul;
  return 0;
}
int
cfg_get_long(struct cfg *cfg, long *dst, long def, const tchar *name)
{
  long ret;
  tchar buf[16];

  if (cfg_get_str(cfg, buf, 16, NULL, name) == 0) {
    if ((ret = tcstol((const char *)buf, NULL, 0)) == LONG_MIN || ret == LONG_MAX) {
      PMNO(errno);
      return -1;
    }
    *dst = ret;
  } else {
    *dst = def;
  }
  return 0;
}
int
cfg_vget_short(struct cfg *cfg, short *dst, short def, const tchar *name, ...)
{
  tchar buf[128];
  va_list ap;

  va_start(ap, name);

  if (vstprintf((char *)buf, 128, (const char *)name, ap) == -1) {
    PMNO(errno);
    return -1;
  }
  if (cfg_get_short(cfg, dst, def, buf) == -1) {
    AMSG("");
    return -1;
  }

  va_end(ap);
  return 0;
}
int
cfg_vget_int(struct cfg *cfg, int *dst, int def, const tchar *name, ...)
{
  tchar buf[128];
  va_list ap;

  va_start(ap, name);

  if (vstprintf((char *)buf, 128, (const char *)name, ap) == -1) {
    PMNO(errno);
    return -1;
  }
  if (cfg_get_int(cfg, dst, def, buf) == -1) {
    AMSG("");
    return -1;
  }

  va_end(ap);
  return 0;
}
int
cfg_vget_long(struct cfg *cfg, long *dst, long def, const tchar *name, ...)
{
  tchar buf[128];
  va_list ap;

  va_start(ap, name);

  if (vstprintf((char *)buf, 128, (const char *)name, ap) == -1) {
    PMNO(errno);
    return -1;
  }
  if (cfg_get_long(cfg, dst, def, buf) == -1) {
    AMSG("");
    return -1;
  }

  va_end(ap);
  return 0;
}
void
cfg_iterate(void *cfg, iter_t *iter)
{
  struct cfg *cfg0 = cfg;
  if (cfg0) {
    linkedlist_iterate(&cfg0->list, iter);
  }
}
const tchar *
cfg_next(void *cfg, iter_t *iter)
{
  struct cfg *cfg0 = cfg;
  tchar *str, *p;
  int state;

  if (cfg == NULL) {
    return NULL;
  }

  while ((str = linkedlist_next(&cfg0->list, iter)) != NULL) {
    state = 0;
    p = cfg0->buf;
    for ( ; state != 2; str++) {
      switch (state) {
        case 0:
          if (*str == _T('\0') || *str == _T('!') || *str == _T('#')) {
            state = 2;
            break;
          }
          if (istspace(*str)) {
            break;
          }
          state = 1;
        case 1:
          if ((istspace(*str) || *str == _T('='))) {
            *p = _T('\0');
            return cfg0->buf;
          } else if ((p - cfg0->buf) == 512) {
            return NULL;
          }
          *p++ = *str;
      }
    }
  }

  return NULL;
}
int
cfg_clear(struct cfg *cfg)
{
  if (cfg) {
    return linkedlist_clear(&cfg->list, (del_fn)allocator_free, cfg->al);
  }

  return 0;
}
