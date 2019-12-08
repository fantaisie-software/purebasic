/* time - supplimentary time functions
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

#include "mba/time.h"

#ifdef _WIN32
#include <windows.h>

uint64_t
time_current_millis(void)
{
  FILETIME ftime;
  uint64_t ret;

  GetSystemTimeAsFileTime(&ftime);

  ret = ftime.dwHighDateTime;
  ret <<= 32Ui64;
  ret |= ftime.dwLowDateTime;
  ret = ret / 10000Ui64 - MILLISECONDS_BETWEEN_1970_AND_1601;

  return ret;
}

#else
#include <sys/time.h>

uint64_t
time_current_millis(void)
{
  struct timeval tval;

  if (gettimeofday(&tval, NULL) < 0) {
    return -1UL;
  }

  return tval.tv_sec * 1000LL + tval.tv_usec / 1000;
}

#endif

