#ifndef MBA_SVCOND_H
#define MBA_SVCOND_H

/* svcond - POSIX-like condition variables implemented using SysV semaphores
 * Algorithm by Alexander Terekhov and Louis Thomas.
 */

#ifdef __cplusplus
extern "C" {
#endif

#include <mba/svsem.h>
#include <mba/pool.h>

typedef struct {
	struct pool *sempool;
	svsem_t *blocked_lock;
	svsem_t *block_queue;
	svsem_t *unblock_lock;
	int waiters_blocked;
	int waiters_to_unblock;
} svcond_t;

int svcond_create(svcond_t *cond, struct pool *sempool);
int svcond_destroy(svcond_t *cond);
int svcond_pool_create(struct pool *p, unsigned int max_size, struct allocator *al);
int svcond_pool_destroy(struct pool *p);

int svcond_wait(svcond_t *cond, svsem_t *lock);
int svcond_broadcast(svcond_t *cond);
int svcond_signal(svcond_t *cond);

#ifdef __cplusplus
}
#endif

#endif /* MBA_SVCOND_H */
