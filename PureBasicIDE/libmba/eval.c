/* eval - calculate a simple arithmetic expression
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
#include <ctype.h>
#include <errno.h>

#include "mba/varray.h"
#include "mba/stack.h"
#include "mba/msgno.h"
#include "mba/eval.h"

#if USE_WCHAR
#define T1PMNF(m,s) PMNF((m), ": %ls", (s))
#else
#define T1PMNF(m,s) PMNF((m), ": %s", (s))
#endif

#define TOK_TYPE_EMPTY   1
#define TOK_TYPE_BITOR   2
#define TOK_TYPE_BITAND  3
#define TOK_TYPE_BITXOR  4
#define TOK_TYPE_ADD     5
#define TOK_TYPE_SUB     6
#define TOK_TYPE_MUL     7
#define TOK_TYPE_DIV     8
#define TOK_TYPE_LEFTP   9
#define TOK_TYPE_RIGHTP  10
#define TOK_TYPE_VALUE   11

static const tchar *ops = (const tchar *)_T("0e|&^+-*/()");

struct eval {
  int err;
  struct varray *toks;
  int toki;
  struct stack *opstk;
  struct stack *stk;
  void *context;
  symlook_fn symlook;
};
struct tok {
  int type;
  unsigned long val;
};

typedef int (*trans_fn)(struct eval *eval, struct tok *tok);

struct eval *
eval_new(symlook_fn symlook, void *context)
{
  struct eval *eval;
  struct tok *em;

  if ((eval = malloc(sizeof *eval)) == NULL) {
    PMNO(errno);
    return NULL;
  }

  memset(eval, 0, sizeof *eval);
  if ((eval->toks = varray_new(sizeof(struct tok), NULL)) == NULL ||
      (eval->opstk = stack_new(4096, NULL)) == NULL ||
      (eval->stk = stack_new(4096, NULL)) == NULL ||
      (em = varray_get(eval->toks, eval->toki++)) == NULL) {
    AMSG("");
    eval_del(eval);
    return NULL;
  }
  eval->context = context;
  eval->symlook = symlook;
  em->type = TOK_TYPE_EMPTY;
  stack_push(eval->opstk, em);

  return eval;
}
int
eval_del(struct eval *eval)
{
  struct eval *e0 = eval;
  int ret = 0;

  if (e0) {
    ret += stack_del(e0->stk, NULL, NULL);
    ret += stack_del(e0->opstk, NULL, NULL);
    ret += varray_del(e0->toks);
    free(e0);
  }

  return ret ? -1 : 0;
}
static int
next(const tchar *src, const tchar *slim, tchar *dst, tchar *dlim)
{
  const tchar *start = src;

  if (dst >= dlim) {
    return 0;
  }
  dlim--;
  while (src < slim && *src && istspace(*src)) {
    src++;
  }
  if (src < slim && tcschr((const char *)ops + 2, *src)) {
    *dst++ = *src++;
  } else {
    while (src < slim && dst < dlim && *src &&
        istspace(*src) == 0 && tcschr((const char *)ops + 2, *src) == NULL) {
      *dst++ = *src++;
    }
  }
  *dst = _T('\0');

  return src - start;
}
static int
next_tok(struct eval *eval, const tchar *src, const tchar *slim, struct tok **tok)
{
  tchar buf[255];
  int ret, i;

  *tok = varray_get(eval->toks, eval->toki++);
  if ((ret = next(src, slim, buf, buf + 255)) > 0) {
    for (i = TOK_TYPE_BITOR; i < TOK_TYPE_VALUE; i++) {
      if (*buf == ops[i]) {
        break;
      }
    }
    (*tok)->type = i;
    if (i == TOK_TYPE_VALUE) {
      if (istdigit(*buf)) {
        (*tok)->val = tcstoul((const char *)buf, NULL, 0);
      } else {
        if (eval->symlook(buf, &(*tok)->val, eval->context) == -1) {
          T1PMNF(errno = ENOENT, buf);
          return -1;
        }
      }
    }
  } else {
    (*tok)->type = TOK_TYPE_EMPTY;
  }

  return ret;
}
static int
error(struct eval *eval, struct tok *tok)
{
  PMNO(errno = EILSEQ);
  (void)eval;
  (void)tok;
  return -1;
}
static int
output(struct eval *eval, struct tok *tok)
{
  return stack_push(eval->stk, tok);
}
static int
push(struct eval *eval, struct tok *tok)
{
  return stack_push(eval->opstk, tok);
}
static int
pop(struct eval *eval, struct tok *tok)
{
  struct tok *op = stack_pop(eval->opstk);
  struct tok *p2 = stack_pop(eval->stk);
  struct tok *p1 = stack_peek(eval->stk);

  switch (op->type) {
    case TOK_TYPE_BITOR:
      p1->val |= p2->val;
      break;
    case TOK_TYPE_BITAND:
      p1->val &= p2->val;
      break;
    case TOK_TYPE_BITXOR:
      p1->val ^= p2->val;
      break;
    case TOK_TYPE_ADD:
      p1->val += p2->val;
      break;
    case TOK_TYPE_SUB:
      p1->val -= p2->val;
      break;
    case TOK_TYPE_MUL:
      p1->val *= p2->val;
      break;
    case TOK_TYPE_DIV:
      p1->val /= p2->val;
      break;
    default:
      PMNO(errno = EINVAL);
      return -1;
  }

  (void)tok;
  return 0;
}
static int
pren(struct eval *eval, struct tok *tok)
{
  stack_pop(eval->opstk);
  (void)tok;
  return 0;
}
static const trans_fn trans_matrix[][9] = {
  { NULL, pop, pop, pop, pop, pop, pop, pop, error },           /* e */
  { push, pop, pop, pop, pop, pop, pop, pop, push },            /* | */
  { push, pop, pop, pop, pop, pop, pop, pop, push },            /* & */
  { push, pop, pop, pop, pop, pop, pop, pop, push },            /* ^ */
  { push, push, push, push, pop, pop, pop, pop, push },         /* + */
  { push, push, push, push, pop, pop, pop, pop, push },         /* - */
  { push, push, push, push, push, push, pop, pop, push },       /* * */
  { push, push, push, push, push, push, pop, pop, push },       /* / */
  { push, push, push, push, push, push, push, push, push },     /* ( */
  { error, pop, pop, pop, pop, pop, pop, pop, pren },           /* ) */
  { output, output, output, output, output, output, output, output, output }
};
int
eval_expression(struct eval *eval, const tchar *expr, const tchar *elim, unsigned long *result)
{
  struct tok *tok, *op;
  trans_fn fn;
  int n;

  if (eval == NULL || expr == NULL || expr > elim || result == NULL) {
    PMNO(errno = EINVAL);
    return -1;
  }
  if (expr == elim) {
    *result = 0;
    return 0;
  }
  do {
    if ((n = next_tok(eval, expr, elim, &tok)) == -1) {
      AMSG("");
      return -1;
    }

    do {
      op = stack_peek(eval->opstk);
      fn = trans_matrix[tok->type - 1][op->type - 1];
      if (fn && fn(eval, tok) == -1) {
        AMSG("");
        return -1;
      }
    } while (fn == pop);

    expr += n;
  } while (n);

  if ((tok = stack_pop(eval->stk))) {
    *result = tok->val;
  } else {
    *result = 0;
  }

  return 0;
}

