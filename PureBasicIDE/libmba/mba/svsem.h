#ifndef MBA_SVSEM_H
#define MBA_SVSEM_H

/* svsem - POSIX-like semaphores implemented using SysV semaphores
 */

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>
#include <sys/sem.h> /* for SEM_UNDO */
#include <fcntl.h>
#include <mba/pool.h>
#include <mba/varray.h>

#define O_UNDO 0x80000

typedef struct {
	int id;
	int num;
	int flags;
	char name[17]; /* only svsem_create/destroy can access this member! */
} svsem_t;

struct _svs_data { /* context data for svsem pool */
	int id;
	int val;
	struct varray sems;
	char name[17];
};

int svsem_create(svsem_t *sem, int value, int undo);
int svsem_destroy(svsem_t *sem);
int svsem_open(svsem_t *sem, const char *path, int oflag, ... /* mode_t mode, int value */);
int svsem_close(svsem_t *sem);
int svsem_remove(svsem_t *sem);
int svsem_pool_create(struct pool *p,
		unsigned int max_size,
		unsigned int value, int undo,
		struct allocator *al);
int svsem_pool_destroy(struct pool *p);

int svsem_wait(svsem_t *sem);
int svsem_trywait(svsem_t *sem);
int svsem_post(svsem_t *sem);
int svsem_post_multiple(svsem_t *sem, int count);
int svsem_getvalue(svsem_t *sem, int *value);
int svsem_setvalue(svsem_t *sem, int value);

#ifdef __cplusplus
}
#endif

#endif /* MBA_SVSEM_H */
