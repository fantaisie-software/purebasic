/* path - manipulate file path names
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
#include <errno.h>

#include "mba/msgno.h"

#define ST_START     1
#define ST_SEPARATOR 2
#define ST_NORMAL    3
#define ST_DOT1      4
#define ST_DOT2      5

int
path_canon(const unsigned char *src, const unsigned char *slim,
    unsigned char *dst, unsigned char *dlim,
    int srcsep, int dstsep)
{
  unsigned char *start = dst, *prev;
  int state = ST_START;

  while (src < slim && dst < dlim) {
    switch (state) {
      case ST_START:
        state = ST_SEPARATOR;
        if (*src == srcsep) {
          *dst++ = dstsep; src++;
          break;
        }
      case ST_SEPARATOR:
        if (*src == '\0') {
          *dst = '\0';
          return dst - start;
        } else if (*src == srcsep) {
          src++;
          break;
        } else if (*src == '.') {
          state = ST_DOT1;
        } else {
          state = ST_NORMAL;
        }
        *dst++ = *src++;
        break;
      case ST_NORMAL:
        if (*src == '\0') {
          *dst = '\0';
          return dst - start;
        } else if (*src == srcsep) {
          state = ST_SEPARATOR;
          *dst++ = dstsep; src++;
          break;
        }
        *dst++ = *src++;
        break;
      case ST_DOT1:
        if (*src == '\0') {
          dst--;
          *dst = '\0';
          return dst - start;
        } else if (*src == srcsep) {
          state = ST_SEPARATOR;
          dst--;
          break;
        } else if (*src == '.') {
          state = ST_DOT2;
          *dst++ = *src++;
          break;
        }
        state = ST_NORMAL;
        *dst++ = *src++;
        break;
      case ST_DOT2:
        if (*src == '\0' || *src == srcsep) {
                        /* note src is not advanced in this case */
          state = ST_SEPARATOR;
          dst -= 2;
          prev = dst - 1;
          if (dst == start || prev == start) {
            break;
          }
          do {
            dst--;
            prev = dst - 1;
          } while (dst > start && *prev != dstsep);
          break;
        }
        state = ST_NORMAL;
        *dst++ = *src++;
        break;
    }
  }

  PMNO(errno = ERANGE);
  return -1;
}
unsigned char *
path_name(unsigned char *path, unsigned char *plim, int sep)
{
  unsigned char *name = path;
  int state = 0;

  while (path < plim && *path) {
    if (state == 0) {
      if (*path != sep) {
        name = path;
        state = 1;
      }
    } else if (*path == sep) {
      state = 0;
    }
    path++;
  }

  return name;
}
