/* === Copyright Notice ===
 *
 *
 *                  PureBasic source code file
 *
 *
 * This file is part of the PureBasic Software package. It may not
 * be distributed or published in source code or binary form without
 * the expressed permission by Fantaisie Software.
 *
 * By contributing modifications or additions to this file, you grant
 * Fantaisie Software the rights to use, modify and distribute your
 * work in the PureBasic package.
 *
 *
 * Copyright (C) 2000-2010 Fantaisie Software - all rights reserved
 *
 */

/*
 * External debugger header
 *
 * Defines the commands for external communication
 */


/* This value is defined here and in the gui debugger headers
 * increase the value any time something on the debugger communication changes
 * (new commands, new parameter, stuff like that)
 *
 * This will ensure, that programs compiled with an older version of the DebuggerModule
 * will be detected and no crashes result from that.
 *
 * -> Now 2 (first v4 debugger with LibraryViewer)
 * -> Now 3 (made some incompatible changes for use of expression parser)
 * -> Now 4 (64bits changes)
 * -> Now 5 (reworked communication protocol)
 * -> Now 6 (scope values changed with v4.40)
 * -> Now 7 (new network stuff and byte swapping)
 * -> Now 8 (changes to control the debugger from code)
 * -> Now 9 (changes for array, list, map in structure)
 * -> Now 10 (changes for module support)
 * -> Now 11 (changes for better module context when evaluating expressions)
 */
#define DEBUGGER_Version 11

// Default port for network mode (if the user choses nothing)
// The perfect port for geeks :p
//
#define DEBUGGER_DefaultPort 10101

// for easy debugging. they sent short messages to the gui debugger as debug commands

#define DebugMsg(string) { \
  struct CommandInfo _dbg_cmd; \
  char _dbg_buff[600]; \
  _dbg_cmd.Command  = COMMAND_Debug; \
  _dbg_cmd.Value1   = 8; \
  _dbg_cmd.DataSize = sprintf(_dbg_buff, "[Line %i] %s", __LINE__, string)+1; \
  ExternalDebugger_SendCommandWithData(&_dbg_cmd, _dbg_buff); }

#define DebugNr(string, number) { \
  struct CommandInfo _dbg_cmd; \
  char _dbg_buff[600]; \
  _dbg_cmd.Command  = COMMAND_Debug; \
  _dbg_cmd.Value1   = 8; \
  _dbg_cmd.DataSize = sprintf(_dbg_buff, "[Line %i] %s %d", __LINE__, string, number)+1; \
  ExternalDebugger_SendCommandWithData(&_dbg_cmd, _dbg_buff); }

/* Notes on the Endian issue:
 *   The external debugger signals its endian-ness with the options and the debugger lib does
 *   all the needed byte swapping with the below macros.
 *
 *   Since the swapping of the CommandInfo structure is the same for almost all commands it is
 *   handled in PB_DEBUGGER_ByteSwapIncomingCommand() and PB_DEBUGGER_ByteSwapOutgoingCommand().
 *   These functions are called by the communication plugins on sending and receiving.
 *   (note: this means the CommandInfo data is swapped after a send and should be re-filled)
 *
 *   The CommandData must be fully swapped by the caller.
 */
extern int PB_DEBUGGER_ByteSwap;
extern int PB_DEBUGGER_BigEndian;

/* Byte swapping macros
 *
 * Note: We do the swapping on the memory location, not when assigning the value.
 *   So you first assign the value normally and then call the swap macro for the swapping.
 *   The reason is that the special quad case below would not work if we do it with the
 *   direct assignment. Its also better for the (unicode)string conversion
 */
#define SWAP_CHAR(a, b) {unsigned char t = a; a = b; b = t; }

M_INLINE(void) bswap2(unsigned char *p)
{
  SWAP_CHAR(p[0], p[1]);
}

M_INLINE(void) bswap4(unsigned char *p)
{
  SWAP_CHAR(p[0], p[3]);
  SWAP_CHAR(p[1], p[2]);
}

M_INLINE(void) bswap8(unsigned char *p)
{
  SWAP_CHAR(p[0], p[7]);
  SWAP_CHAR(p[1], p[6]);
  SWAP_CHAR(p[2], p[5]);
  SWAP_CHAR(p[3], p[4]);
}

M_INLINE(void) bswap_quad(unsigned char *p)
{
  /* Note: The quad type is 4bytes on PPC (our only big endian platform so far), but
   *   in the debugger communication we always reserve 8 bytes for quads so in case of
   *   a quad, we have this on PPC: long(be) + 4byte garbage
   *
   *   So in this case we just swap the first 4 bytes and put the rest to 0 (will be the higher
   *   bytes of the x86 quad type). This works in both ppc->x86 and x86->ppc directions, we just
   *   get a truncation in the one direction which is unavoidable.
   *
   *   Note that if somebody runs a PPC debugger with an x64 exe (if we do a network debugging) it
   *   will work just fine, but all pointers get truncated of course. But who would do that anyway?
   */
  bswap4(p);
  *(int *)(p + 4) = 0;
}

M_INLINE(void) bswap_wstring(wchar_t *p)
{
  while (*p)
  {
    bswap2((unsigned char *)p);
    p++;
  }
}

#define ByteSwapWord(p)          if (PB_DEBUGGER_ByteSwap) bswap2((unsigned char *)(p))
#define ByteSwapUnicode(p)       if (PB_DEBUGGER_ByteSwap) bswap2((unsigned char *)(p))
#define ByteSwapLong(p)          if (PB_DEBUGGER_ByteSwap) bswap4((unsigned char *)(p))
#define ByteSwapQuad(p)          if (PB_DEBUGGER_ByteSwap) bswap_quad((unsigned char *)(p))
#define ByteSwapFloat(p)         if (PB_DEBUGGER_ByteSwap) bswap4((unsigned char *)(p))
#define ByteSwapDouble(p)        if (PB_DEBUGGER_ByteSwap) bswap8((unsigned char *)(p))
#define ByteSwapUnicodeString(p) if (PB_DEBUGGER_ByteSwap) bswap_wstring((wchar_t *)(p))
#define ByteSwapString(p)        if (PB_DEBUGGER_ByteSwap && PB_DEBUGGER_ExternalUnicode) bswap_wstring((wchar_t *)(p))

// Character values are transferred as longs in the debugger communication
#define ByteSwapCharacter(p) if (PB_DEBUGGER_ByteSwap) bswap4((unsigned char *)(p))

#ifdef PB_64
  #define ByteSwapInteger(p) if (PB_DEBUGGER_ByteSwap) bswap_quad((unsigned char *)(p))
#else
  #define ByteSwapInteger(p) if (PB_DEBUGGER_ByteSwap) bswap4((unsigned char *)(p))
#endif

// same macros without a check for the ByteSwap value
//
#define ByteSwapWordForce(p)          bswap2((unsigned char *)(p))
#define ByteSwapUnicodeForce(p)       bswap2((unsigned char *)(p))
#define ByteSwapLongForce(p)          bswap4((unsigned char *)(p))
#define ByteSwapQuadForce(p)          bswap_quad((unsigned char *)(p))
#define ByteSwapFloatForce(p)         bswap4((unsigned char *)(p))
#define ByteSwapDoubleForce(p)        bswap8((unsigned char *)(p))
#define ByteSwapUnicodeStringForce(p) bswap_wstring((wchar_t *)(p))
#define ByteSwapStringForce(p)        if (PB_DEBUGGER_ExternalUnicode) bswap_wstring((wchar_t *)(p))
#define ByteSwapCharacterForce(p)     bswap4((unsigned char *)(p))
#ifdef PB_64
  #define ByteSwapIntegerForce(p) bswap_quad((unsigned char *)(p))
#else
  #define ByteSwapIntegerForce(p) bswap4((unsigned char *)(p))
#endif

// Note: This structure remains the same for 32bits/64bits for compatibility.
//   This means that a command can send at max 2GB of data, but i think that is ok for the moment.
//   Structure size must be >= 16 for AES encryption
//
struct CommandInfo
{
  int Command;
  int DataSize;
  int Value1;
  int Value2;
  int TimeStamp;
};

extern void PB_DEBUGGER_ByteSwapIncomingCommand(struct CommandInfo *Command);
extern void PB_DEBUGGER_ByteSwapOutgoingCommand(struct CommandInfo *Command);


/* Functions provided by the communication plugins
 * - The structure stores no local data, as there is always only 1 instance of a plugin, so we can use globals
 * - If ExternalDebugger_Breakpoints() is called in a threaded way by the plugin, PB_DEBUGGER_ReceiveMutex must be locked while doing so
 * - PB_DEBUGGER_CommandWaiting must be kept up to date, as the code relies on it (should be decreased in Receive())
 */
typedef struct
{
  char *Name;                  // name string (first field of the PB_DEBUGGER_Communication string)
  int   ProvidesOptions;       // true if the plugin can read the options from the debugger (so its not the PB_DEBUGGER_Options env var)
  int  (*Connect)(char *Info); // info is the part of PB_DEBUGGER_Communication after "Name;"
  void (*Send)   (struct CommandInfo *Command, char *CommandData);
  int  (*Receive)(struct CommandInfo *Command, char **CommandData);
  void (*Close)  ();
} CommunicationPlugin;

struct CommandStackStruct
{
  struct CommandInfo command;
  char *commanddata;
};

#define MAX_COMMANDSTACK 100



typedef struct
{
  int Command;
  void (*Handler)(struct CommandInfo *command, char *commanddata, integer *registers);
} ExternalCommandHandler;

typedef struct WatchlistObject
{
  char place;      // where is the variable stored? (1=variable, 2=linkedlist, 3=array)
  char type;       // PB variable type
  char scope;      // scope of the variable (SCOPE_XXX value (6=SCOPE_PARAMETER))
  char *name;      // name, as passed by the debugger (in utf8, for easier parsing)

  char *base;       // array/list/map base adderess (in local mode this is a relative offset, this has no meaning for variables
  char *address;    // address of the variable (for locals, this is relative to the variable bank) otherwise it is a direct address
                    // for arrays/linkedlists/maps, this is relative to the elements base (not the array base!)

  int ProcedureID;    // for local stuff: quick access from Enter/LeaveProcedure
  int ProcedureIndex; // procedure index, to identify the procedure with the IDE

  union {
    integer  index;   // 1-dim array, index
    integer *coords;  // for multidim array: pointer to index array, M_Alloc'ed
    xchar   *key;     // for maps: pointer to map key (in exe format, null for "current element mode"), M_Alloc'ed
  };

  int itemsize;       // for arrays.. size of one array item

  char nbdimensions;  // arrays only
  char isvalid;       // was the variable valid on the last check?

  union ObjectValue   // last seen value of this variable
  {
    char      b;
    unsigned char a;
    unsigned short int u;
    short int w;
    int       l;
    unsigned long s; // crc32 checksum of the string (so no extra buffer is needed)
    float     f;
    char     *p; // for pointer
    int       c; // store the character as an integer with X_pbchar()
    double    d;
    quad      q;
    integer   i;
    struct { // fixed length string.. store the length in here to save space
      unsigned long fixed; // crc
      int           length; // max length
    };
  } value;
} PB_WatchlistObject;

// watchlist place
#define WATCHLIST_Variable   1
#define WATCHLIST_Linkedlist 2
#define WATCHLIST_Array      3
#define WATCHLIST_Map        4

extern int PB_DEBUGGER_CommandWaiting;
extern struct CommandStackStruct PB_DEBUGGER_CommandStack[MAX_COMMANDSTACK];

extern M_MUTEX PB_DEBUGGER_ReceiveMutex;
extern M_MUTEX PB_DEBUGGER_SendMutex;
extern M_MUTEX PB_DEBUGGER_WatchlistMutex;


#define PB_DEBUGGER_MaxWatchlist 1000
extern PB_WatchlistObject PB_DEBUGGER_Watchlist[];
extern int PB_DEBUGGER_WatchlistSize;

#define PB_DEBUGGER_MaxLibrary 300
extern PB_LibraryInfo *PB_DEBUGGER_LibraryInfo[];
extern int PB_DEBUGGER_LibraryCount;

M_PBFUNCTION(void) PB_DEBUGGER_SendCommand(struct CommandInfo *command);
M_PBFUNCTION(void) PB_DEBUGGER_SendSimpleCommand(int Command, int Value1, int Value2);
M_PBFUNCTION(void) PB_DEBUGGER_SendCommandWithData(struct CommandInfo *command, const void *data);
M_PBFUNCTION(int)  PB_DEBUGGER_IncomingCommand(integer *registers);
M_PBFUNCTION(void) PB_DEBUGGER_StoppedExternal(integer *registers);
M_PBFUNCTION(void) PB_DEBUGGER_ErrorExternal(const char *Message);

M_PBFUNCTION(void) PB_DEBUGGER_SendLibraries(void);
M_PBFUNCTION(void) PB_DEBUGGER_SendLibraryData(int Command, int Library, integer ObjectID);

M_PBFUNCTION(void) PB_DEBUGGER_InitExternal();
M_PBFUNCTION(void) PB_DEBUGGER_EndExternal();

M_PBFUNCTION(void) PB_DEBUGGER_WatchlistEvent(int index);
M_PBFUNCTION(void) PB_DEBUGGER_CheckWatchlist();
void PB_DEBUGGER_ExternalBreakpoints(struct CommandInfo *command, char *commanddata, integer *registers);

// communication plugins
extern CommunicationPlugin PB_DEBUGGER_PipePlugin;
extern CommunicationPlugin PB_DEBUGGER_ServerPlugin;
extern CommunicationPlugin PB_DEBUGGER_ClientPlugin;

#ifdef WINDOWS
  extern CommunicationPlugin PB_DEBUGGER_NamedPipePlugin;
#else
  extern CommunicationPlugin PB_DEBUGGER_FifoPlugin;
#endif

