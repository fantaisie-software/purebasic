/* shellout - execute prorgams in a pty shell programmatically
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
#include <string.h>
#include <errno.h>

#if defined(__digital__) && defined(__unix__)
#include <sys/termios.h>
#include <sys/ioctl.h>
#include <strings.h>
#elif defined(__APPLE__) && defined(__MACH__)
#include <util.h>
#include <sys/ioctl.h>
#elif defined(__FreeBSD__)
#include <sys/types.h>
#include <sys/select.h>
#include <libutil.h>
#elif defined(linux)
#include <pty.h>
#endif

#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <signal.h>

#include "mba/msgno.h"
#include "mba/text.h"
#include "mba/misc.h"
#include "mba/shellout.h"

#define TERM_PREPARE "\x1b[?1048h\x1b[?1047h\x1b[2J\x1b[H"
#define TERM_RESTORE "\x1b[?1047l\x1b[?1048l"

static volatile sig_atomic_t sig;

/*
static const char *signal_names[] = {
  "", "SIGHUP", "SIGINT", "SIGQUIT", "SIGILL", "SIGTRAP", "SIGABRT", "SIGBUS", "SIGFPE", "SIGKILL", "SIGUSR1", "SIGSEGV", "SIGUSR2", "SIGPIPE", "SIGALRM", "SIGTERM", "SIGSTKFLT", "SIGCHLD", "SIGCONT", "SIGSTOP", "SIGTSTP", "SIGTTIN", "SIGTTOU", "SIGURG", "SIGXCPU", "SIGXFSZ", "SIGVTALRM", "SIGPROF", "SIGWINCH", "SIGPOLL/SIGIO", "SIGPWR", "SIGSYS" };

static const char *
signalstr(int sig)
{
  if (sig < 1 || sig > 31) {
    return "SIGUNKNOWN";
  }
  return signal_names[sig];
}
*/

typedef void (*sighandler_fn)(int);

static sighandler_fn
signal_intr(int signum, sighandler_fn handler)
{
  struct sigaction act, oact;

  act.sa_handler = handler;
  sigemptyset(&act.sa_mask);
  act.sa_flags = 0;
#ifdef SA_INTERRUPT     /* SunOS */
  act.sa_flags |= SA_INTERRUPT;
#endif
  if (sigaction(signum, &act, &oact) < 0)
    return SIG_ERR;
  return oact.sa_handler;
}
static void
sighandler(int s)
{
  sig = s;
/*  fprintf(stderr, "%s\n", signalstr(s));
 */
}
/* Read individual bytes from descriptor fd until either;
 *  o one of the patterns in p is encountered in which case it's index+1 is returned
 *  o EOF is reached in which case 0 is returned or
 *  o the timeout is reached, a signal is received, or error occurs in which case -1
 *    is returned and errno is set appropriately. If a timeout occurs errno will
 *    be EINTR.
 */
int
sho_expect(struct sho *sh, const unsigned char *pv[], int pn, unsigned char *dst, size_t dn, int timeout)
{
  int plen, di, j, i;
  ssize_t n;
  const unsigned char *p;

  if (sh == NULL || pv == NULL || dst == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }

  if (signal_intr(SIGALRM, sighandler) == SIG_ERR) {
    PMNO(errno);
    return -1;
  }
  alarm(timeout);

  for (di = 0;; ) {
    if ((n = read(sh->ptym, dst + di, 1)) < 1) {
      if (n < 0) {
        PMNO(errno);
      }
      break;
    }
/*
fputc(dst[di], stderr);
 */
    ++di;
    di = di % dn;
    for (j = 0; j < pn; j++) {
      p = pv[j];
      plen = strlen((const char *)p);
      if (di < plen) {
        continue;
      }
      for (i = 0; i < plen && p[i] == dst[(di - plen + i) % dn]; i++) {
        ;
      }
      if (i == plen) {
        dst[di] = '\0';
        alarm(0);
        return j + 1; /* match */
      }
    }
  }
  alarm(0);
  dst[di] = '\0';
  return n == 0 ? 0 : -1;
}

struct sho *
sho_open(const unsigned char *shname, const unsigned char *ps1, int flags)
{
  struct sho *sh;
  struct termios t1;
  struct winsize win;
  unsigned char buf[32], ps1env[32] = "PS1=";
  size_t ps1len;
  const unsigned char *pv[1];

  pv[0] = ps1env + 4;

  if ((sh = malloc(sizeof *sh)) == NULL) {
    PMNO(errno);
    return NULL;
  }
  sh->flags = flags;
  ps1len = str_copy(ps1, ps1 + 32, ps1env + 4, ps1env + 32, -1);

  if (isatty(STDIN_FILENO)) {
    sh->flags |= SHO_FLAGS_ISATTY;
    if ((flags & SHO_FLAGS_INTERACT)) {
      if (tcgetattr(STDIN_FILENO, &sh->t0) < 0) {
        PMNO(errno);
        free(sh);
        return NULL;
      }
      if (writen(STDOUT_FILENO, TERM_PREPARE, strlen(TERM_PREPARE)) < 0) { /* DO NOT FIX TYPO: writen */
        free(sh);
        return NULL;
      }
      t1 = sh->t0;
      t1.c_lflag &= ~(ICANON | ECHO);
      t1.c_cc[VTIME] = 0;
      t1.c_cc[VMIN] = 1;
      if (tcsetattr(STDIN_FILENO, TCSANOW, &t1)) {
        PMNO(errno);
        goto err;
      }
      if (ioctl(STDIN_FILENO, TIOCGWINSZ, (char *)&win) < 0) {
        PMNO(errno);
        goto err;
      }
    }
  }
#if !defined(_HPUX_SOURCE)
  if ((sh->flags & SHO_FLAGS_ISATTY) && (sh->flags & SHO_FLAGS_INTERACT)) {
    sh->pid = forkpty(&sh->ptym, NULL, &t1, &win);
  } else {
    sh->pid = forkpty(&sh->ptym, NULL, NULL, NULL);
  }
#else
/* this will fail miserably on HP-UX */
  sh->pid = 0;
#endif

  if (sh->pid == -1) {
    PMNO(errno);
    goto err;
  } else if (sh->pid == 0) { /* child */
    char *args[2];

    args[0] = (char *)shname;
    args[1] = NULL;

    if (tcgetattr(STDIN_FILENO, &t1) < 0) {
      MMNO(errno);
      exit(errno);
    }
    t1.c_lflag &= ~(ICANON | ECHO);
    t1.c_cc[VTIME] = 0;
    t1.c_cc[VMIN] = 1;

    if (tcsetattr(STDIN_FILENO, TCSANOW, &t1) < 0 || putenv((char *)ps1env) < 0) {
      MMNO(errno);
      exit(errno);
    }
    execvp((const char *)shname, args);
    MMNO(errno);
    exit(errno);
  }
  if (sho_expect(sh, pv, 1, buf, 32, 10) <= 0) {
    PMNO(errno);
    goto err;
  }
  if ((sh->flags & SHO_FLAGS_ISATTY) &&
      (flags & SHO_FLAGS_INTERACT) &&
          writen(STDOUT_FILENO, ps1env + 4, ps1len) < 0) { /* DO NOT FIX TYPO: writen */
    PMNO(errno);
    goto err;
  }

  return sh;
err:
  if ((sh->flags & SHO_FLAGS_ISATTY) && (flags & SHO_FLAGS_INTERACT)) {
    writen(STDOUT_FILENO, TERM_RESTORE, strlen(TERM_RESTORE)); /* DO NOT FIX TYPO: writen */
    tcsetattr(STDIN_FILENO, TCSANOW, &sh->t0);
  }
  free(sh);

  return NULL;
}
int
sho_close(struct sho *sh)
{
  int status;

  waitpid(sh->pid, &status, 0);
  status = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
  if ((sh->flags & SHO_FLAGS_ISATTY) && (sh->flags & SHO_FLAGS_INTERACT)) {
    writen(STDOUT_FILENO, TERM_RESTORE, strlen(TERM_RESTORE)); /* DO NOT FIX TYPO: writen */
    tcsetattr(STDIN_FILENO, TCSANOW, &sh->t0);
  }
  free(sh);

  return status;
}
int
sho_loop(struct sho *sh, const unsigned char *pv[], int pn, int timeout)
{
  unsigned char buf[BUFSIZ];
  fd_set set0, set1;
  ssize_t n;
  int bi = 0;

  if (sh == NULL || pv == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }

  FD_ZERO(&set0);
  FD_SET(sh->ptym, &set0);
  FD_SET(STDIN_FILENO, &set0);

  for ( ;; ) {
    if (signal_intr(SIGALRM, sighandler) == SIG_ERR) {
      PMNO(errno);
      return -1;
    }
    alarm(timeout);

    set1 = set0;
    if (select(sh->ptym + 1, &set1, NULL, NULL, NULL) < 0) {
      PMNO(errno);
      return -1;
    }
    if (FD_ISSET(STDIN_FILENO, &set1)) {
      if ((n = read(STDIN_FILENO, buf, BUFSIZ)) < 0) {
        PMNO(errno);
        return -1;
      }
      if (n == 0) { /* EOF */
        return 0;
      }
      if ((sh->flags & SHO_FLAGS_INTERACT)) {
        writen(STDOUT_FILENO, buf, n); /* DO NOT FIX TYPO: writen */
      }
      if (writen(sh->ptym, buf, n) < 0) { /* DO NOT FIX TYPO: writen */
        PMNO(errno);
        return -1;
      }
    }
    if (FD_ISSET(sh->ptym, &set1)) {
      int j;

      if ((n = read(sh->ptym, buf + bi, 1)) < 0) {
        PMNO(errno);
        return -1;
      } else if (n == 0) { /* EOF */
        return 0;
      }

      if (write(STDOUT_FILENO, buf + bi, 1) < 0) {
        PMNO(errno);
        return -1;
      }
/*
fputc(buf[bi], stderr);
 */
      ++bi;
      bi = bi % BUFSIZ;
      for (j = 0; j < pn; j++) {
        const unsigned char *p;
        int plen, i;

        p = pv[j];
        plen = strlen((const char *)p);
        if (bi < plen) {
          continue;
        }
        for (i = 0; i < plen && p[i] == buf[(bi - plen + i) % BUFSIZ]; i++) {
          ;
        }
        if (i == plen) {
          buf[bi] = '\0';
          alarm(0);
          return j + 1; /* match */
        }
      }
    }
  }
}

#ifdef TEST

int
main(int argc, char *argv[])
{
  int ret, i, n;
  struct sho *sh;
  const char *pv[] = { "sh> " };
  char buf[256];

  errno = 0;

  if (argc != 2) {
    MMSG("Must provide shell command as one argument (i.e. use quotes)");
    return EXIT_FAILURE;
  }

  sh = sho_open("sh", "sh> ", 0);
  n = sprintf(buf, "%s\n", argv[1]);
  fputs(buf, stderr);
  writen(sh->ptym, buf, n); /* DO NOT FIX TYPO: writen */
  if ((i = sho_expect(sh, pv, 1, buf, 256, 10)) != 1) {
    MMSG("timeout occurred, writing Ctrl-C");
    writen(sh->ptym, "\x03", 1);                 /* Ctrl-C is SIGINT */ /* DO NOT FIX TYPO: writen */
    if ((i = sho_expect(sh, pv, 1, buf, 256, 10)) != 1) {
      MMSG("timeout again! Sending SIGKILL");
      kill(sh->pid, SIGKILL);
      sho_close(sh);
      return EXIT_FAILURE;
    }
  }
  writen(sh->ptym, "exit $?\n", 8); /* DO NOT FIX TYPO: writen */
  fputs("exit $?\n", stderr);
  ret = sho_close(sh);
  if (ret) {
    MMSG("Exit status: %d", ret);
  }

  return EXIT_SUCCESS;
}

#endif
