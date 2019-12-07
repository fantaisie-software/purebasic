#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <stdarg.h>

#ifndef _WIN32
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#include "mba/msgno.h"
#include "mba/misc.h"

#ifndef _WIN32

int
copen(const char *pathname, int flags, mode_t mode, int *cre)
{
  int fd, max = 3; /* maximum attempts to open */

  if ((flags & O_CREAT) == 0) {
    if ((fd = open(pathname, flags, mode)) == -1) {
      PMNF(errno, ": %s", pathname);
      return -1;
    }
    *cre = 0;
    return fd;
  }
  while (max--) {
    if ((fd = open(pathname, flags & ~(O_CREAT | O_EXCL))) != -1) {
      *cre = 0;
      return fd;
    } else if (errno != ENOENT) {
      PMNF(errno, ": %s", pathname);
      return -1;
    }
    if ((fd = open(pathname, flags | O_EXCL, mode)) != -1) {
      *cre = 1;
      return fd;
    } else if (errno != EEXIST) {
      PMNF(errno, ": %s", pathname);
      return -1;
    }
  }

  PMNF(errno = EACCES, ": %s", pathname);
  return -1;
}

ssize_t
readn(int fd, void *dst, size_t n)
{
  size_t nleft;
  ssize_t nread;
  char *ptr;

  ptr = dst;
  nleft = n;
  while (nleft > 0) {
    if ((nread = read(fd, ptr, nleft)) < 0) {
      return nread;
    } else if (nread == 0) {
      break;
    }
    nleft -= nread;
    ptr += nread;
  }
  return n - nleft;
}
ssize_t
writen(int fd, const void *src, size_t n)
{
  size_t nleft;
  ssize_t nwritten;
  const char *ptr;

  ptr = src;
  nleft = n;
  while (nleft > 0) {
    if ((nwritten = write(fd, ptr, nleft)) < 0) {
      return nwritten;
    }
    nleft -= nwritten;
    ptr += nwritten;
  }
  return n;
}

#endif

/* Just for tcase tests. Otherwise dlopened code cannot resolve this
 * symbol
 */

int
tcase_printf(int verbose, const char *fmt, ...)
{
  int ret = 0;

  if (verbose) {
    va_list ap;
    va_start(ap, fmt);
    ret = vprintf(fmt, ap);
    fflush(stdout);
    va_end(ap);
  }

  return ret;
}

