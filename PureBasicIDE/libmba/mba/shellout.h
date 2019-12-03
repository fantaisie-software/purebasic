#ifndef MBA_SHELLOUT_H
#define MBA_SHELLOUT_H

/* shellout - execute programs in a pty shell programmatically
 */

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>
#include <termios.h>

#define SHO_FLAGS_INTERACT 0x0001
#define SHO_FLAGS_ISATTY   0x0100

struct sho {
	int flags;
	pid_t pid;
	int ptym;
	struct termios t0;
};

struct sho *sho_open(const unsigned char *shname, const unsigned char *ps1, int flags);
int sho_close(struct sho *sh);
int sho_expect(struct sho *sh, const unsigned char *pv[], int pn, unsigned char *dst, size_t dn, int timeout);
int sho_loop(struct sho *sh, const unsigned char *pv[], int pn, int timeout);

#ifdef __cplusplus
}
#endif

#endif /* MBA_SHELLOUT_H */
