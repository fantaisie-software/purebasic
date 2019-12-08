/* stack - a dynamically resizing stack
 * Copyright (c) 2001 Michael B. Allen <mba2000 ioplex.com>
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
#include <limits.h>
#include <assert.h>
#include <errno.h>
#include <stdio.h>

#include "mba/msgno.h"
#include "mba/iterator.h"
#include "mba/allocator.h"
#include "mba/stack.h"

#define STACK_INIT_SIZE 0

int
stack_init(struct stack *s, unsigned int max_size, struct allocator *al)
{
  if (s == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }

  memset(s, 0, sizeof *s);
  s->max = max_size ? max_size : INT_MAX;
  s->al = al;

  return 0;
}
int
stack_deinit(struct stack *s, del_fn data_del, void *context)
{
  int ret = 0;

  if (s) {
    if (data_del) {
      while (s->sp > 0) {
        ret += data_del(context, s->array[--(s->sp)]);
      }
    }
    ret += allocator_free(s->al, s->array);
  }

  return ret ? -1 : 0;
}
struct stack *
stack_new(unsigned int max_size, struct allocator *al)
{
  struct stack *s;

  if ((s = allocator_alloc(al, sizeof *s, 0)) == NULL) {
    PMNO(errno);
    return NULL;
  }
  if (stack_init(s, max_size, al) == -1) {
    PMNO(errno);
    allocator_free(al, s);
    return NULL;
  }

  return s;
}
int
stack_del(struct stack *s, del_fn data_del, void *context)
{
  int ret = 0;

  if (s) {
    ret += stack_deinit(s, data_del, context);
    ret += allocator_free(s->al, s);
  }

  return ret;
}
int
stack_clear(struct stack *s, del_fn data_del, void *context)
{
  int ret = 0;

  if (s && data_del) {
    while (s->sp > 0) {
      ret += data_del(s->array[--(s->sp)], context);
    }
  }

  return ret ? -1 : 0;
}
void
stack_iterate(void *s, iter_t *iter)
{
  if (s) {
    iter->i1 = 0;
  }
}
void *
stack_next(void *s, iter_t *iter)
{
  if (s) {
    struct stack *s0 = s;
    if (iter->i1 < s0->sp) {
      return s0->array[iter->i1++];
    }
  }

  return NULL;
}
void *
stack_peek(struct stack *s)
{
  if (s && s->sp > 0) {
    return s->array[s->sp - 1];
  }

  return NULL;
}
void *
stack_get(struct stack *s, unsigned int idx)
{
  if (s == NULL || s->sp == 0 || idx >= s->sp) {
    PMNO(errno = ERANGE);
    return NULL;
  }
  return s->array[idx];
}
int
stack_push(struct stack *s, void *data)
{
  if (s == NULL) {
    PMNF(errno = ERANGE, ": s=NULL");
    return -1;
  }
  if (s->sp == s->size) {
    void **new_array;
    unsigned int new_size;

    if (s->size == s->max) {
      PMNF(errno = ERANGE, ": size=%u,max=%u", s->size, s->max);
      return -1;
    }
    if (s->size * 2 > s->max) {
      new_size = s->max;
    } else if (s->size == 0) {
      new_size = 32;
    } else {
      new_size = s->size * 2;
    }

    new_array = allocator_realloc(s->al, s->array, sizeof *s->array * new_size);
    if (new_array == NULL) {
      PMNF(errno, ": new_size=%u,new_array=NULL,sp=%u", new_size, s->sp);
      return -1;
    }
    s->size = new_size;
    s->array = new_array;
  }
  assert(s->sp <= s->size);
  s->array[s->sp++] = data;

  return 0;
}
void *
stack_pop(struct stack *s)
{
  if (s == NULL || s->sp == 0) {
    return NULL;
  }
  if (s->sp < s->size / 4 && s->size > 32) {
    void **new_array;
    unsigned int new_size = s->size / 2;

    new_array = allocator_realloc(s->al, s->array, sizeof *s->array * new_size);
    if (new_array == NULL) {
      PMNF(errno, ": new_size=%u,new_array=NULL", new_size);
      return NULL;
    }
    s->array = new_array;
    s->size = new_size;
  }
  assert(s->sp > 0 && s->sp <= s->size);

  return s->array[--(s->sp)];
}
int
stack_is_empty(const struct stack *s)
{
  return s == NULL || s->sp == 0;
}
unsigned int
stack_size(const struct stack *s)
{
  return s == NULL ? 0 : s->sp;
}
int
stack_clean(struct stack *s)
{
  if (s && s->size > s->sp) {
    void **new_array;
    unsigned int new_size = s->sp;
    int ret = s->size - new_size;

    new_array = allocator_realloc(s->al, s->array, sizeof *s->array * new_size);
    if (new_size && new_array == NULL) {
      AMSG("");
      return -1;
    }
    s->array = new_array;
    s->size = new_size;

    return ret;
  }

  return 0;
}

