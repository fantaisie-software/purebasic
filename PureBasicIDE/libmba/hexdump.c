/* hexdump - print hexdump of memory to stream
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
#include <ctype.h>
#include <wchar.h>
#include <string.h>

#include "mba/hexdump.h"

#define HEXBUFSIZ 128

void
hexdump(FILE *stream, const void *src, size_t len, size_t width)
{
  unsigned int rows, pos, c, i;
  const char *start, *rowpos, *data;

  data = src;
  start = data;
  pos = 0;
  rows = (len % width) == 0 ? len / width : len / width + 1;
  for (i = 0; i < rows; i++) {
    rowpos = data;
    fprintf(stream, "%05x: ", pos);
    do {
      c = *data++ & 0xff;
      if ((size_t)(data - start) <= len) {
        fprintf(stream, " %02x", c);
      } else {
        fprintf(stream, "   ");
      }
    } while(((data - rowpos) % width) != 0);
    fprintf(stream, "  |");
    data -= width;
    do {
      c = *data++;
      if (isprint(c) == 0 || c == '\t') {
        c = '.';
      }
      if ((size_t)(data - start) <= len) {
        fprintf(stream, "%c", c);
      } else {
        fprintf(stream, " ");
      }
    } while(((data - rowpos) % width) != 0);
    fprintf(stream, "|\n");
    pos += width;
  }
  fflush(stream);
}

#if (__STDC_VERSION__ < 199901L) && defined(_WIN32)
#define snprintf _snprintf
#endif

int
shexdump(const void *src, size_t len, size_t width, char *dst, char *dlim)
{
  unsigned int rows, pos, c, i;
  const char *start, *dst_start, *rowpos, *data;

  if (dlim <= dst) {
    return 0;
  }
  dlim--;

  start = data = src;
  dst_start = dst;
  pos = 0;
  rows = (len % width) == 0 ? len / width : len / width + 1;
  for (i = 0; i < rows && dst < dlim; i++) {
    rowpos = data;
    dst += snprintf(dst, dlim - dst, "%05x: ", pos);
    do {
      c = *data++ & 0xff;
      if ((size_t)(data - start) <= len) {
        dst += snprintf(dst, dlim - dst, " %02x", c);
      } else {
        dst += snprintf(dst, dlim - dst, "   ");
      }
    } while(((data - rowpos) % width) != 0);
    dst += snprintf(dst, dlim - dst, "  |");
    data -= width;
    do {
      c = *data++;
      if (isprint(c) == 0 || c == '\t') {
        c = '.';
      }
      if ((size_t)(data - start) <= len) {
        dst += snprintf(dst, dlim - dst, "%c", c);
      } else {
        *dst += ' ';
      }
    } while(((data - rowpos) % width) != 0);
    dst += snprintf(dst, dlim - dst, "|\n");
    pos += width;
  }
  *dst = '\0';

  return dst - dst_start;
}

