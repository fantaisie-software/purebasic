/* pool - a container of recycleable objects
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
#include <errno.h>
#include <stdio.h>

#include "mba/msgno.h"
#include "mba/allocator.h"
#include "mba/iterator.h"
#include "mba/stack.h"
#include "mba/bitset.h"
#include "mba/pool.h"

int
pool_create(struct pool *p,
  unsigned int max_size,
  new_fn object_new,
  del_fn object_del,
  rst_fn object_rst,
  void *context,
  size_t size,
  int flags,
  struct allocator *al)
{
  if (p == NULL || object_new == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }
  if (max_size == 0 || max_size > POOL_SIZE_MAX) {
    max_size = POOL_SIZE_MAX;
  }
  p->al = al;
  if ((p->bitset = allocator_alloc(p->al, max_size / 8 + 1, 1)) == NULL ||
      stack_init(&p->stk, max_size, p->al) == -1) {
    PMNO(errno);
    allocator_free(p->al, p->bitset);
    return -1;
  }
  p->object_new = object_new;
  p->object_del = object_del;
  p->object_rst = object_rst;
  p->context = context;
  p->size = size;
  p->flags = flags;
  p->max_size = max_size;
  p->unused = 0;

  return 0;
}
int
pool_destroy(struct pool *p)
{
  if (p && (stack_deinit(&p->stk, p->object_del, p->context) +
        allocator_free(p->al, p->bitset)) != 0) {
    AMSG("");
    return -1;
  }

  return 0;
}
struct pool *
pool_new(unsigned int max_size,
  new_fn object_new,
  del_fn object_del,
  rst_fn object_rst,
  void *context,
  size_t size,
  int flags,
  struct allocator *al)
{
  struct pool *p;

  if ((p = allocator_alloc(al, sizeof *p, 0)) == NULL ||
      pool_create(p, max_size, object_new, object_del, object_rst,
        context, size, flags, al) == -1) {
    AMSG("");
    return NULL;
  }

  return p;
}

int
pool_del(struct pool *p)
{
  int ret = 0;

  if (p) {
    ret += pool_destroy(p);
    ret += allocator_free(p->al, p);
  }

  return ret ? -1 : 0;
}
void *
pool_get(struct pool *p)
{
  unsigned int lim, n;
  void *obj;

  if (p == NULL) {
    PMNO(errno = ERANGE);
    return NULL;
  }
  if (p->unused == 0 && stack_size(&p->stk) == p->max_size) {
    PMNF(errno = ERANGE, ": %d", p->max_size);
    return NULL;
  }

  lim = p->max_size / 8 + 1;
  if ((n = bitset_find_first(p->bitset, p->bitset + lim, 0)) == (unsigned int)-1) {
    PMNO(errno = ERANGE);
    return NULL;
  }

  if ((n == stack_size(&p->stk))) {
    size_t size = p->size == (size_t)-1 ? n : p->size;
    /* If p->size is -1 then 'size' is really the index. This is
     * only used by svsem.
     */
    if ((obj = p->object_new(p->context, size, p->flags)) == NULL) {
      AMSG("");
      return NULL;
    }
    if (stack_push(&p->stk, obj) == -1) {
      AMSG("");
      p->object_del(p->context, obj);
      return NULL;
    }
  } else {
    if ((obj = stack_get(&p->stk, n)) == NULL) {
      AMSG("");
      return NULL;
    }
    if (p->object_rst && p->object_rst(p->context, obj) == -1) {
      AMSG("");
      return NULL;
    }
    p->unused--;
  }

  bitset_set(p->bitset, n);

  return obj;
}
int
pool_release(struct pool *p, void *data)
{
  if (!data) return 0;

  if (p) {
    iter_t iter;
    int n;
    void *d;

    stack_iterate(&p->stk, &iter);
    for (n = 0; (d = stack_next(&p->stk, &iter)) != NULL; n++) {
      if (d == data) {
        bitset_unset(p->bitset, n);
        p->unused++;

        return 0;
      }
    }
  }

  PMNO(errno = EINVAL);
  return -1;
}
unsigned int
pool_size(struct pool *p)
{
  return p == NULL ? 0 : stack_size(&p->stk);
}
unsigned int
pool_unused(struct pool *p)
{
  return p == NULL ? 0 : p->unused;
}
void
pool_iterate(void *p, iter_t *iter)
{
  if (p) {            /* should we bother to check? */
    struct pool *p0 = p;
    stack_iterate(&p0->stk, iter);
  }
}
void *
pool_next(void *_p, iter_t *iter)
{
  struct pool *p = _p;
  return stack_next(&p->stk, iter);
}
int
pool_clean(struct pool *p)
{
  int idx;

  idx = stack_size(&p->stk);
  if (idx-- && p->object_del) {
    int count = 0;

    while (!bitset_isset(p->bitset, idx--)) {
      if (p->object_del(p->context, stack_pop(&p->stk)) == -1) {
        AMSG("");
        return -1;
      }
      count++;
    }

    if (stack_clean(&p->stk) == -1) {
      AMSG("");
      return -1;
    }

    return count;
  }

  return 0;
}

