/* linkedlist - a singularly linked list
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
#include <string.h>
#include <limits.h>
#include <errno.h>
#include <stdio.h>

#include "mba/msgno.h"
#include "mba/iterator.h"
#include "mba/allocator.h"
#include "mba/linkedlist.h"

void
linkedlist_print(struct linkedlist *l)
{
  struct node *n = l->first;
  int idx = 0;
  while (n) {
    fprintf(stderr, "list node %d n=%p,data=%p\n", idx, n, n->data);
    n = n->ptr;
    idx++;
  }
}

static void
_cache_remove_by_node(struct linkedlist *l, struct node *n)
{
  struct cache_entry *ce;
  int i;

  for (i = 0; i < CACHE_SIZE; i++) {
    ce = l->cache + i;
    if (ce->ent == n) {
      ce->ent = NULL;
    }
  }
}
static void
_cache_update_by_index(struct linkedlist *l, unsigned int idx, int insert)
{
  struct cache_entry *ce;
  int i;

  for (i = 0; i < CACHE_SIZE; i++) {
    ce = l->cache + i;
    if (ce->ent && ce->idx >= idx) {
      ce->idx += insert ? 1 : -1;
    }
  }
}

int
linkedlist_init(struct linkedlist *l, unsigned int max_size, struct allocator *al)
{
  if (l == NULL) {
    errno = EINVAL;
    PMNO(errno);
    return -1;
  }
  memset(l, 0, sizeof *l);
  l->max_size = max_size == 0 ? INT_MAX : max_size;
  l->al = al;

  return 0;
}
int
linkedlist_deinit(struct linkedlist *l, del_fn data_del, void *context)
{
  int ret = 0;

  if (l) {
    struct node *next = l->first;

    while (next != NULL) {
      struct node *tmp;

      if (data_del) {
        ret += data_del(context, next->data);
      }
      tmp = next;
      next = next->ptr;
      ret += allocator_free(l->al, tmp);
    }
  }

  return ret ? -1 : 0;
}
struct linkedlist *
linkedlist_new(unsigned int max_size, struct allocator *al)
{
  struct linkedlist *l;

  if ((l = allocator_alloc(al, sizeof *l, 0)) == NULL) {
    PMNO(errno);
    return NULL;
  }
  linkedlist_init(l, max_size, al);

  return l;
}
int
linkedlist_del(struct linkedlist *l, del_fn data_del, void *context)
{
  int ret = 0;

  if (l) {
    ret = linkedlist_deinit(l, data_del, context) + allocator_free(l->al, l);
  }

  return ret ? -1 : 0;
}

int
linkedlist_clear(struct linkedlist *l, del_fn data_del, void *context)
{
  if (l) {
    int max_size = l->max_size;
    struct allocator *al = l->al;

    if (linkedlist_deinit(l, data_del, context) == -1) {
      AMSG("");
      return -1;
    }

    linkedlist_init(l, max_size, al);
  }

  return 0;
}
int
linkedlist_add(struct linkedlist *l, const void *data)
{
  struct node *n;

  if (l == NULL) {
    PMNF(errno = EINVAL, ": l=NULL");
    return -1;
  }
  if (l->size == l->max_size) {
    PMNF(errno = ERANGE, ": size=%u,max_size=%u", l->size, l->max_size);
    return -1;
  }
  if ((n = allocator_alloc(l->al, sizeof *n, 0)) == NULL) {
    PMNO(errno);
    return -1;
  }

  n->data = (void *)data;
  n->ptr = NULL;
  if (l->size == 0) {
    l->first = l->last = n;
  } else {
    l->last->ptr = n;
    l->last = n;
  }
  l->size++;

  return 0;
}
int
linkedlist_insert(struct linkedlist *l, unsigned int idx, const void *data)
{
  struct node *n;

  if (l == NULL || data == NULL) {
    PMNF(errno = ERANGE, ": l=%p,data=%p", l, data);
    return -1;
  }
  if (idx > l->size || l->size == l->max_size) {
    PMNF(errno = ERANGE, ": idx=%u,size=%u,max_size=%u", idx, l->size, l->max_size);
    return -1;
  }
  if ((n = allocator_alloc(l->al, sizeof *n, 0)) == NULL) {
    PMNO(errno);
    return -1;
  }
  n->data = (void *)data;
  n->ptr = NULL;
  if (l->size == 0) {
    l->first = l->last = n;
  } else {
    if (idx == 0) {
      n->ptr = l->first;
      l->first = n;
    } else if (idx == l->size) {
      l->last->ptr = n;
      l->last = n;
    } else {
      struct node *tmp;
      unsigned int i;

      tmp = l->first;
      n->ptr = tmp->ptr;
      for (i = 1; i < idx; i++) {
        tmp = tmp->ptr;
        n->ptr = tmp->ptr;
      }
      tmp->ptr = n;
    }
  }
  l->size++;

  _cache_update_by_index(l, idx, 1); /* increment cache entries with larger idx */

  return 0;
}
int
linkedlist_insert_sorted(struct linkedlist *l,
    cmp_fn cmp,
  void *context,
  void **replaced,
  const void *data)
{
  struct node *n, *p;
  int c;
  unsigned int idx;
  int ins = 1;

  if (l == NULL || cmp == NULL || data == NULL) {
    PMNF(errno = EINVAL, ": l=%p,cmp=%p,data=%p", l, cmp, data);
    return -1;
  }
  if (l->size == l->max_size) {
    PMNF(errno = ERANGE, ": size=%u,max_size=%u", l->size, l->max_size);
    return -1;
  }
  if ((n = allocator_alloc(l->al, sizeof *n, 0)) == NULL) {
    PMNO(errno);
    return -1;
  }
  n->data = (void *)data;

  idx = 0;
  p = NULL;
  n->ptr = l->first;
  while (n->ptr) {
    c = cmp(data, n->ptr->data, context);
    if (c < 0 || (replaced && c == 0)) {
      if (c == 0) {                             /* replace */
        struct node *rm = n->ptr;
        *replaced = rm->data;
        n->ptr = rm->ptr;
        _cache_remove_by_node(l, rm);
        allocator_free(l->al, rm);
        l->size--;
        ins = 0;
      }
      break;
    }
    p = n->ptr;
    n->ptr = n->ptr->ptr;
    idx++;
  }
  if (p) {
    p->ptr = n;
  } else {
    l->first = n;
  }
  if (n->ptr == NULL) {
    l->last = n;
  }
  l->size++;

  if (ins) {
    _cache_update_by_index(l, idx, 1); /* increment cache entries with larger idx */
  }

  return idx;
}
int
linkedlist_is_empty(const struct linkedlist *l)
{
  return l == NULL || l->size == 0;
}
unsigned int
linkedlist_size(const struct linkedlist *l)
{
  return l == NULL ? 0 : l->size;
}
void
linkedlist_iterate(void *l, iter_t *iter)
{
  if (l && iter) {
    iter->i1 = 0;
  }
}
void *
linkedlist_next(void *l, iter_t *iter)
{
  if (l && iter) {
    struct linkedlist *l0 = l;

    if (iter->i1 >= l0->size) {
      return NULL;
    }
    /* optimized using cache to be O(1) if elements accessed sequentially */
    return linkedlist_get(l0, iter->i1++);
  }

  return NULL;
}
void *
linkedlist_get(struct linkedlist *l, unsigned int idx)
{
  if (l == NULL) {
    errno = EINVAL;
    PMNF(errno, ": l=%p", l);
    return NULL;
  }

  if (idx >= l->size) {
    PMNF(errno = ERANGE, ": idx=%u,size=%u", idx, l->size);
    return NULL;
  }
  if (idx == 0) {
    return l->first->data;
  } else if (idx == l->size - 1) {
    return l->last->data;
  } else {
    unsigned int i, closest_idx = (unsigned int)-1;
    struct cache_entry *ce, *stale = NULL, *closest = NULL;

    for (i = 0; i < CACHE_SIZE && closest_idx; i++) {
      ce = l->cache + i;
      if (ce->ent == NULL) {
        stale = ce;
        continue;
      }
      if (idx >= ce->idx && (idx - ce->idx) < closest_idx) {
        closest_idx = ce->idx;
        closest = ce;
      } else if (stale == NULL) {
        stale = ce;
      }
    }
    if (closest_idx == (unsigned int)-1) {
      struct node *next = l->first;
      ce = stale;
      for (i = 0; i < idx; i++) {
        next = next->ptr;
      }
      ce->idx = i;
      ce->ent = next;
    } else {
      ce = closest;
      while (ce->idx < idx) {
        ce->idx++;
        ce->ent = ce->ent->ptr;
        if (ce->ent == NULL) {
          return NULL;
        }
      }
    }

    return ce->ent->data;
  }
}
void *
linkedlist_get_last(const struct linkedlist *l)
{
  if (l == NULL) {
    PMNF(errno = EINVAL, ": l=%p", l);
    return NULL;
  }
  if (l->size == 0) {
    return NULL;
  }
  return l->last->data;
}
void *
linkedlist_remove(struct linkedlist *l, unsigned int idx)
{
  void *result;
  struct node *tmp;

  if (l == NULL) {
    PMNF(errno = EINVAL, ": l=%p", l);
    return NULL;
  }
  if (idx >= l->size) {
    return NULL;
  }
  if (idx == 0) {
    result = l->first->data;
    tmp = l->first;
    l->first = l->first->ptr;
  } else {
    struct node *n;
    unsigned int i;

    n = l->first;
    for (i = 1; i < idx; i++) {
      n = n->ptr;
    }
    tmp = n->ptr;
    n->ptr = tmp->ptr;
    if (tmp == l->last) {
      l->last = n;
    }
    result = tmp->data;
  }
  _cache_remove_by_node(l, tmp);
  allocator_free(l->al, tmp);
  l->size--;

  _cache_update_by_index(l, idx, 0); /* decrement cache entries with larger idx */

  return result;
}
void *
linkedlist_remove_last(struct linkedlist *l)
{
  void *result;

  if (l == NULL) {
    PMNF(errno = EINVAL, ": l=%p", l);
    return NULL;
  }
  if (l->size == 0) {
    return NULL;
  }
  if (l->size == 1) {
    result = l->first->data;
    _cache_remove_by_node(l, l->first);
    allocator_free(l->al, l->first);
    l->first = l->last = NULL;
  } else {
    struct node *n;

    result = l->last->data;
    n = l->first;
    while (n->ptr != l->last) {
      n = n->ptr;
    }
    _cache_remove_by_node(l, l->last);
    allocator_free(l->al, l->last);
    l->last = n;
    n->ptr = NULL;
  }
  l->size--;

  return result;
}
void *
linkedlist_remove_data(struct linkedlist *l, const void *data)
{
  struct node *tmp;

  if (l == NULL || data == NULL) {
    PMNF(errno = EINVAL, ": l=%p", l);
    return NULL;
  }
  if (l->size == 0) {
    return NULL;
  }
  if (data == l->first->data) {
    tmp = l->first;
    l->first = l->first->ptr;
  } else {
    struct node *n;
    int idx = 1;

    for (n = l->first; n->ptr && n->ptr->data != data; n = n->ptr) {
      idx++;
    }
    if (n->ptr == NULL) {
      return NULL;
    }

    tmp = n->ptr;
    n->ptr = tmp->ptr;
    if (tmp == l->last) {
      l->last = n;
    }

    _cache_update_by_index(l, idx, 0); /* decrement cache entries with larger idx */
  }
  _cache_remove_by_node(l, tmp);
  allocator_free(l->al, tmp);
  l->size--;

  return (void *)data;
}
int
linkedlist_toarray(struct linkedlist *l, void *array[])
{
  struct node *n;
  int i;

  if (l == NULL || array == NULL) {
    PMNF(errno = EINVAL, ": l=%p", l);
    return -1;
  }

  n = l->first;
  for (i = 0; n; i++) {
    array[i] = n->data;
    n = n->ptr;
  }

  return 0;
}

