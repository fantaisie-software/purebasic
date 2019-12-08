/* daemon - fork and daemonize a process
 * Copyright (c) 2004 Michael B. Allen <mba2000 ioplex.com>
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
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <time.h>

#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <fcntl.h>

#include "mba/msgno.h"
#include "mba/daemon.h"

FILE *logfp = NULL;

int
daemonlog(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  vfprintf(logfp, fmt, ap);
  va_end(ap);
  fputc('\n', logfp);
  fflush(logfp);
  return 0;
}

pid_t
daemonize(mode_t mask,
    const char *rundir,
    const char *pidpath,
    const char *lockpath,
    const char *logpath)
{
  pid_t pid;
  int fd;

  if (getppid() == 1) {                            /* already a daemon */
    return 0;
  }

  if ((pid = fork())) {
    return pid;
  }
                                            /* child (daemon) continues */
  setsid();                               /* obtain a new process group */
  umask(mask);                    /* set newly created file permissions */

                                                /* close all descriptors */
  for (fd = getdtablesize(); fd >= 0; fd--) {
    close(fd);
  }
            /* but stdin, stdout, and stderr are redirected to /dev/null */
  if ((fd = open("/dev/null", O_RDWR)) != 0 || dup(fd) != 1 || dup(fd) != 2) {
    return -1;
  }
  if (logpath) {                                  /* open the logfile */
    time_t start = time(NULL);

    if ((logfp = fopen(logpath, "a")) == NULL) {
      PMNF(errno, ": %s", logpath);
      return -1;
    }

    msgno_hdlr = daemonlog;
    daemonlog("log started: %s", ctime(&start));
  }

  if (lockpath) {
    if ((fd = open(lockpath, O_RDWR | O_CREAT, 0640)) == -1) {
      PMNF(errno, ": %s", lockpath);
      return -1;
    }
    if (lockf(fd, F_TLOCK, 0) == -1) {               /* can not lock */
      PMNF(errno, ": %s: Server already running.", lockpath);
      return -1;
    }
  }
                                            /* first instance continues */
  if (pidpath) {
    char str[10];

    if ((fd = open(pidpath, O_RDWR | O_CREAT, 0640)) == -1) {
      PMNO(errno);
      return -1;
    }
    sprintf(str, "%d\n", getpid());
    if (write(fd, str, strlen(str)) == -1) { /* write pid to lockfile */
      PMNO(errno);
      return -1;
    }
    close(fd);
  }

  if (rundir && chdir(rundir) == -1) {   /* change running directory */
    PMNF(errno, ": %s", rundir);
    return -1;
  }

  signal(SIGTSTP,SIG_IGN);                       /* ignore tty signals */
  signal(SIGTTOU,SIG_IGN);
  signal(SIGTTIN,SIG_IGN);

  return 0;
}

