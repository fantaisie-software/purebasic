/*
 * Header file used by all purifier library
 */

#define PURIFIER_COOKIE_SIZE 4
#define PURIFIER_COOKIE 0xBADF00D

typedef struct PB_PurifierMemoryBlock
{
  int *BeforeCookie; /* Directly store the before and after cookie address so the check is fast */
  int *AfterCookie;
} PB_PurifierMemoryBlock;


typedef struct
{
  PB_PurifierMemoryBlock *Bank;
  int Size;
  int CurrentBlock;
  int NbErased;
} PB_PurifierBank;


void PB_PURIFIER_AddMemory(void *Memory, integer Size);
void PB_PURIFIER_RemoveMemory(void *Memory);
int  PB_PURIFIER_CheckMemory(const void *Memory);

void PB_PURIFIER_AddStringMemory(void *Memory, integer Size);
void PB_PURIFIER_RemoveStringMemory(void *Memory);
