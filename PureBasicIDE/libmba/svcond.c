/* svcond - POSIX-like condition variables implemented using SysV semaphores
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
#include <string.h>
#include <errno.h>

#include "mba/svsem.h"
#include "mba/svcond.h"
#include "mba/msgno.h"

int
svcond_destroy(svcond_t *cond)
{
  int ret = 0;

  if (svsem_wait(cond->blocked_lock) == -1) {
    AMSG("");
    return -1;
  }
  if (svsem_trywait(cond->unblock_lock) != 0) {
    AMSG("");
    svsem_post(cond->blocked_lock);
    return -1;
  }

  if (cond) {
    if (cond->blocked_lock) {
      ret += pool_release(cond->sempool, cond->blocked_lock);
      if (cond->block_queue) {
        ret += pool_release(cond->sempool, cond->block_queue);
        if (cond->unblock_lock) {
          ret += pool_release(cond->sempool, cond->unblock_lock);
          cond->unblock_lock = NULL;
        }
        cond->block_queue = NULL;
      }
      cond->blocked_lock = NULL;
    }
  }

  return ret ? -1 : 0;
}
int
svcond_create(svcond_t *cond, struct pool *sempool)
{
  struct _svs_data *sd;

  if (cond == NULL || sempool == NULL ||
      (sd = sempool->context) == NULL || sd->val != 1) {
    PMNO(errno = EINVAL);
    return -1;
  }

  memset(cond, sizeof *cond, 0);
  cond->sempool = sempool;

  if ((cond->blocked_lock = pool_get(sempool)) == NULL ||
      (cond->block_queue = pool_get(sempool)) == NULL ||
      (cond->unblock_lock = pool_get(sempool)) == NULL) {
    PMNO(errno = EAGAIN);
    svcond_destroy(cond);
    return -1;
  }
/*
MMSG("%d: %d %d %d", cond->blocked_lock->id,
  cond->blocked_lock->num,
  cond->block_queue->num,
  cond->unblock_lock->num);
*/

  cond->unblock_lock->flags |= SEM_UNDO;

  if (svsem_setvalue(cond->block_queue, 0) == -1) {
    PMNO(errno);
    svcond_destroy(cond);
    return -1;
  }

  return 0;
}
int
svcond_wait(svcond_t *cond, svsem_t *sem)
{
  int signals_left = 0;

  if (svsem_wait(cond->blocked_lock) == -1) {
    AMSG("");
    return -1;
  }
  cond->waiters_blocked++;
  svsem_post(cond->blocked_lock);

  svsem_post(sem);
  if (svsem_wait(cond->block_queue) == -1) {
    int err = errno;
    AMSG("");
    cond->waiters_blocked--;
    while (svsem_wait(sem) == -1 && errno == EINTR) {
      ;
    }
    errno = err;
    return -1;
  }

  if (svsem_wait(cond->unblock_lock) == -1) {
    int err = errno;
    AMSG("");
    while (svsem_wait(sem) == -1 && errno == EINTR) {
      ;
    }
    errno = err;
    return -1;
  }
  if ((signals_left = cond->waiters_to_unblock)) {
    cond->waiters_to_unblock--;
  }
  svsem_post(cond->unblock_lock);

  if (signals_left == 1) {
    svsem_post(cond->blocked_lock);
  }

  while (svsem_wait(sem) == -1) {
    if (errno != EINTR) {
      AMSG("");
      return -1;
    }
  }

  return 0;
}
static int
_svcond_signal(svcond_t *cond, int broadcast)
{
  int signals_to_issue;

  if (svsem_wait(cond->unblock_lock) == -1) {
    AMSG("");
    return -1;
  }
  if (cond->waiters_to_unblock) {
    if (cond->waiters_blocked == 0) {
      if (svsem_post(cond->unblock_lock) == -1) {
        AMSG("");
        return -1;
      }
      return 0;
    }
    if (broadcast) {
      cond->waiters_to_unblock += signals_to_issue = cond->waiters_blocked;
      cond->waiters_blocked = 0;
    } else {
      signals_to_issue = 1;
      cond->waiters_to_unblock++;
      cond->waiters_blocked--;
    }
  } else if (cond->waiters_blocked) {
    if (svsem_wait(cond->blocked_lock) == -1) {
      AMSG("");
      return -1;
    }
    if (broadcast) {
      signals_to_issue = cond->waiters_to_unblock = cond->waiters_blocked;
      cond->waiters_blocked = 0;
    } else {
      signals_to_issue = cond->waiters_to_unblock = 1;
      cond->waiters_blocked--;
    }
  } else {
    if (svsem_post(cond->unblock_lock) == -1) {
      AMSG("");
      return -1;
    }
    return 0;
  }
  if (svsem_post(cond->unblock_lock) == -1 ||
      svsem_post_multiple(cond->block_queue, signals_to_issue) == -1) {
    AMSG("");
    return -1;
  }

  return 0;
}
int
svcond_broadcast(svcond_t *cond)
{
  return _svcond_signal(cond, 1);
}
int
svcond_signal(svcond_t *cond)
{
  return _svcond_signal(cond, 0);
}

