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
 *  Header containing OS specific definitions
 */

// ----------------------------- Windows specific ---------------------------------
//
#ifdef WINDOWS

  #include <io.h>
  #include <direct.h>
  #include <stdio.h>
  #include <fcntl.h>

  #define STDIN_FILENO _fileno(stdin)
  #define getcwd _getcwd
  #define isatty _isatty
  #define fdopen _fdopen
  #define fileno _fileno

  // We redefine the standard streams and open the ones from GetStdHandle() so it works
  // also with the console from AllocConsole()
  //
  #undef stdin
  #undef stdout
  #undef stderr

  static FILE *stdin, *stdout, *stderr;

  #define _O_TEXT 0x4000  /* CR-LF in file becomes LF in memory. */

  #define unsetenv(_name_) SetEnvironmentVariable((_name_), NULL)

  #define wcsicmp _wcsicmp
  #define wcsnicmp _wcsnicmp

  // --------- end workarounds ------------

  /* Macro to preserve the GetLastError() api value on windows.
   */
  #define Preserve_GetLastError()  DWORD Win_LastError = GetLastError()
  #define Restore_GetLastError() SetLastError(Win_LastError)

  #define DelayMS(_time_) Sleep((DWORD)(_time_))
  #define ElapsedMS() GetTickCount()

  /* This one tries to trigger WaitWindowEvent() to return.
   * This is to make the debugger communication more responsive
   * On windows, we post a WM_NULL message to the queue
   *
   * The PostThreadMessage will simply fail if there is no message queue (ie no window)
   */
  extern DWORD PB_DEBUGGER_MainThreadID;
  #define ExitWaitWindowEvent() PostThreadMessage(PB_DEBUGGER_MainThreadID, WM_NULL, 0, 0)

  #define OS_STREAMTYPE  HANDLE
  #define OS_OpenPipeRead(pipe) ((HANDLE)pipe)   // on windows, the passed handle allreasy is open for reading/writing
  #define OS_OpenPipeWrite(pipe) ((HANDLE)pipe)
  #define OS_CloseStream(stream) CloseHandle(stream)

  // These are used in just very few places, so inline is ok
  // Thanks to MS standard-noncompliance, its "__inline" instead of the C99 "inline"
  //
  static __inline void OS_WriteStream(void *buffer, int size, HANDLE stream)
  {
    int byteswritten;
    WriteFile(stream, buffer, size, &byteswritten, NULL);
  }

  static __inline int OS_ReadStream(void *buffer, int size, HANDLE stream)
  {
    int result, bytesread, received = 0;
    do
    {
      result = ReadFile(stream, ((char *)buffer)+received, size-received, &bytesread, 0);
      received += bytesread;
    }
    while (received < size && result);

    return result;
  }

  #define OS_StreamEOF(stream) (0)  // todo

  // we cannot use the PureLibrary.h thread macros, as we need a thread handle to later
  // kill the thread
  //
  #define OS_THREADTYPE HANDLE

  #define OS_CreateThread(function, result_handle, result) \
    { \
      DWORD ___threadid; \
      if (result_handle = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)(function), 0, 0, &___threadid)) \
        result = 1; \
      else \
        result = 0; \
    } \

  #define OS_KillThread(t)   TerminateThread((HANDLE)(t), 0)
  #define OS_CloseThread(t)  CloseHandle((HANDLE)(t))
  #define OS_PauseThread(t)  SuspendThread((HANDLE)(t))
  #define OS_ResumeThread(t) ResumeThread((HANDLE)(t))

  // Networking
  //
  #define OS_INVALID_SOCKET INVALID_SOCKET
  #define OS_CloseSocket(s) closesocket(s)
  #define OS_SOCKETTYPE     SOCKET

  M_INLINE(int) OS_Disconnect(int result)
  {
    int Error;

    if (result == SOCKET_ERROR)
    {
      Error = WSAGetLastError();

      if (Error == WSAECONNABORTED || Error == WSAECONNRESET || Error == WSAENOTCONN  || Error == WSAESHUTDOWN)
        return 1;
    }

    return 0;
  }

  #define OS_DisconnectSend(r) OS_Disconnect(r)
  #define OS_DisconnectRecv(r) OS_Disconnect(r)

  #define OS_IOCTLSocket(s, c, b) ioctlsocket(s, c, b)

  M_INLINE(int) OS_InitNetwork()
  {
    WSADATA WinSockInfo;

    // We can call this multiple times (network lib does it too)
    // We just need the same amount of WSACleanup() calls to match it
    //
    if (WSAStartup(MAKEWORD(1, 1), &WinSockInfo) == 0)
      return 1;
    else
      return 0;
  }

  #define OS_EndNetwork() WSACleanup()

#endif


// ----------------------------- Unix specific ---------------------------------
//
#ifdef LINUX  // defined on OSX as well

  #include <pthread.h>
  #include <time.h>
  #include <stdlib.h>
  #include <signal.h>
  #include <string.h>
  #include <sys/time.h>

  #include <sys/socket.h>
  #include <sys/ioctl.h>
  #include <netdb.h>
  #include <netinet/in.h>
  #include <arpa/inet.h>
  #include <errno.h>
  #include <fcntl.h>
  #include <termios.h>
  #include <unistd.h>

  // there is no min in glibc !?
  // use inline function to avoid double evaluation
  static inline integer min(integer a, integer b)
  {
    if (a > b)
      return a;
    else
      return b;
  }

  /* Macro to preserve the GetLastError() api value on windows. (empty for linux/mac)
   */
  #define Preserve_GetLastError()
  #define Restore_GetLastError()

  #if defined(PB_MACOS)
    #if defined(PB_COCOA)
      // Tries to exit the WaitWindowEvent().
      // MacOS: Post an empty message to unlock the loop
      void PB_Cocoa_SendDummyEvent(); // prototype. Cocoa lib is always included if debugger is ON on OS X (done be the compiler)
      void PB_Cocoa_FlushDebuggerPool(); // prototype. Cocoa lib is always included if debugger is ON on OS X (done be the compiler)
      #define ExitWaitWindowEvent() PB_Cocoa_FlushDebuggerPool(); PB_Cocoa_SendDummyEvent()
    #else
      // Nothing on Carbon, it will lock (and we don't care)
      #define ExitWaitWindowEvent()
    #endif
  #else
    // Tries to exit the WaitWindowEvent().
    // Linux: This is done through an X message from the IDE/debugger now */
    #define ExitWaitWindowEvent()
  #endif

  // Those are a bit small to be exported functions, so use them
  // inline (they are not used that frequently, so no problem)
  //
  static inline int ElapsedMS()
  {
    struct timeval Time;
    gettimeofday(&Time, 0);

    return (Time.tv_sec*1000)+Time.tv_usec/1000;
  }

  static inline void DelayMS(int time)
  {
    struct timespec delay_time, remaining_time;
    delay_time.tv_sec = 0;
    delay_time.tv_nsec = time * 1000000;
    nanosleep(&delay_time, &remaining_time);
  }

  #define OS_STREAMTYPE FILE *

  static inline FILE * OS_OpenPipeRead(int pipe)
  {
    FILE *result = 0;
    if (result = fdopen(pipe, "rb")) setvbuf(result, 0, _IONBF, 0);
    return result;
  }

  static inline FILE * OS_OpenPipeWrite(int pipe)
  {
    FILE *result = 0;
    if (result = fdopen(pipe, "wb")) setvbuf(result, 0, _IONBF, 0);
    return result;
  }

  static inline int OS_ReadStream(void *buffer, int size, FILE *stream)
  {
    int result, received = 0;
    do
    {
      result = fread(((char *)buffer)+received, 1, size-received, stream);
      if (result == 0) return 0;
      received += result;
    }
    while (received < size);

    return 1;
  }

  #define OS_CloseStream(stream) fclose(stream)
  #define OS_WriteStream(buffer, size, stream) fwrite(buffer, 1, size, stream); fflush(stream)
  #define OS_StreamEOF(stream) feof(stream)

  #define OS_THREADTYPE pthread_t
  #define OS_CreateThread(function, result_handle, result) { result = (0 == pthread_create(&(result_handle), 0, (function), 0)); }
  #define OS_KillThread(t)   pthread_cancel((pthread_t)(t))
  #define OS_PauseThread(t)  pthread_kill((pthread_t)(t), SIGSTOP)
  #define OS_ResumeThread(t) pthread_kill((pthread_t)(t), SIGCONT)

  // nothing to be done here
  #define OS_CloseThread(t)

  // It's just not defined by default on Linux
  int fwide (FILE *fp, int mode);

  // Networking
  //
  #define OS_INVALID_SOCKET (-1)
  #define OS_CloseSocket(s) close(s)
  #define OS_SOCKETTYPE     int

  #define SOCKET_ERROR -1
  typedef struct hostent HOSTENT;

  #define OS_InitNetwork()  (1)
  #define OS_EndNetwork()

  #define OS_DisconnectSend(r) (((r) == -1) && (errno == ECONNRESET))
  #define OS_DisconnectRecv(r) ((r) == 0)

  #define OS_IOCTLSocket(s, c, b) ioctl(s, c, b)

  extern int    PB_ArgC;
  extern char **PB_ArgV;

#endif


// ----------------------------- Linux specific ---------------------------------
//
#if defined(LINUX) && !defined(PB_MACOS)
#endif


// ----------------------------- MacOS specific ---------------------------------
//
#ifdef PB_MACOS
#endif


// ----------------------------- X86 specific ---------------------------------
//
#ifdef X86

  #define GetAbsoluteAddress(Address) (*(char **)(Address))

#endif


// ----------------------------- X64 specific ---------------------------------
//
#ifdef X64

  #define GetAbsoluteAddress(Address) (*(char **)(Address))

#endif


// ----------------------------- PowerPC specific ---------------------------------
//
#ifdef POWERPC

  /* On PPC, only offset are stored in the debug structure, on Linux/Windows, real address is stored
   */
  extern int PB_DEBUGGER_VariableBase;

  #define GetAbsoluteAddress(Address) ((char *)(*(unsigned int *)(Address) + (unsigned int)&PB_DEBUGGER_VariableBase))

#endif

