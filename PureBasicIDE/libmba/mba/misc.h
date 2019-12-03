#ifndef MBA_MISC_H
#define MBA_MISC_H

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _WIN32

#include <sys/types.h>

int copen(const char *pathname, int flags, mode_t mode, int *cre);
ssize_t readn(int fd, void *dst, size_t n);
ssize_t writen(int fd, const void *src, size_t n);

#endif

#ifdef __cplusplus
}
#endif

#endif /* MBA_MISC_H */
