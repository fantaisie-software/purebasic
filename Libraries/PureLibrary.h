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

#ifndef PURELIBRARY_H
#define PURELIBRARY_H

#ifdef __cplusplus
  extern "C" {
#endif

#ifdef PB_MACOS  // MacOS is linux based
  #ifndef LINUX
    #define LINUX
  #endif
#endif

#ifdef X64
  #ifndef PB_64
    #define PB_64 // Automatically define this depending of the processors so we don't need to put both on commandline
  #endif
#endif


#ifdef PURIFIER
  #define M_PurifierFunction(Function)Function##_PURIFIER
  #define M_PurifierUnicodeFunction(Function)Function##_PURIFIER
#else
  #define M_PurifierFunction(Function)Function
  #define M_PurifierUnicodeFunction(Function)Function
#endif


#ifdef UNICODE
  #define M_AllocString(size) ((TCHAR *)M_Alloc(((size)+1)*sizeof(TCHAR)))
#else
  #define M_AllocString(size) ((TCHAR *)M_Alloc(size+1))
#endif

#ifdef THREAD
  #define M_ThreadUnicodeFunction(Function)Function##_THREAD
  #define M_UnicodeFunction(Function)Function
  #define M_ThreadFunction(Function)Function##_THREAD
#else
  #define M_ThreadUnicodeFunction(Function)Function
  #define M_UnicodeFunction(Function)Function
  #define M_ThreadFunction(Function)Function
#endif

#ifdef __cplusplus
  #define M_C_LINKAGE extern "C"
#else
  #define M_C_LINKAGE
#endif

// A small helper to simplify sharing headers between C/C++
// Replaces a C++ type with "void" if compiled with C. Only useful with pointer types.
//
#ifdef __cplusplus
  #define M_CPP(type) type
#else
  #define M_CPP(type) void
#endif

#ifdef WINDOWS

  // Warning, need to fix the float.h header for _longDouble (move the _longDouble on the 'struct' line)
  //
  #undef __STRLEN  // To disable the nasty LCC StrLen optim

  #ifndef WINVER
    #define WINVER 0x0400 // Use the headers for WIN95 and up (important for NT4.0 compatibility and the Menu lib for example)
  #endif

  #include <stdio.h>
  #include <windows.h>
  #include <wchar.h>

  #ifdef X86
    // We use the VC6 MSVCRT.dll, which doesn't have 'mktime32' but 'mktime'
    // Sadly, VC8 'time.inl' header defines 'mktime' as an inline static, so we can't undefine it
    // So we have change the _mktime32 to mktime32 and ignore the inline file (which is done with RC_INVOKED
    #define RC_INVOKED
      #define _gmtime32    gmtime
      #define _localtime32 localtime
      #define _mktime32    mktime

      #include <time.h>
    #undef RC_INVOKED
  #endif

  // Special macro to define a static GUID
  #define DEFINE_GUID_PB(name,l,w1,w2,b1,b2,b3,b4,b5,b6,b7,b8) static GUID name = { l,w1,w2,{ b1,b2,b3,b4,b5,b6,b7,b8}}

  #define PB_LITTLE_ENDIAN

  // mutex stuff
  #define M_MUTEX               CRITICAL_SECTION
  #define M_InitMutex(mutex)    InitializeCriticalSection(&(mutex))
  #define M_FreeMutex(mutex)    DeleteCriticalSection(&(mutex))
  #define M_LockMutex(mutex)    EnterCriticalSection(&(mutex))
  #define M_UnlockMutex(mutex)  LeaveCriticalSection(&(mutex))
  //#define M_TryLockMutex(mutex) TryEnterCriticalSection(&(mutex)) // returns nonzero if successfully locked. DO NOT USE, NOT EXISTING ON Win98

  // abstraction of thread local storage
  #define M_TLS                  DWORD
  #define M_TlsInit(key)         { key = TlsAlloc(); }
  #define M_TlsFree(key)         TlsFree(key)
  #define M_TlsRead(key)         TlsGetValue(key)
  #define M_TlsWrite(key, value) TlsSetValue(key, (LPVOID)(value))

  #define M_BACKSLASH '\\'

  #ifdef VISUALC
    #define _stdcall __stdcall
  #endif

  #define M_FILE HANDLE
  #define M_INSTANCE HINSTANCE
  #define M_INLINE(type) static __inline type
  #ifdef X86
    #define M_PBFUNCTION(type) M_C_LINKAGE type _stdcall
    #define M_PBVIRTUAL _stdcall
    #define M_SYSFUNCTION(type) M_C_LINKAGE type _stdcall
    #define M_SYSVIRTUAL _stdcall
    #define M_CALLBACK M_C_LINKAGE int _stdcall
  #else // X64 doesn't have several calling convetion
    #define M_PBFUNCTION(type) M_C_LINKAGE type
    #define M_PBVIRTUAL
    #define M_SYSFUNCTION(type) M_C_LINKAGE type
    #define M_SYSVIRTUAL
    #define M_CALLBACK M_C_LINKAGE int
  #endif
  // removed the extern
  #define M_FILE_ERROR (HANDLE)INVALID_HANDLE_VALUE

  // defines the extra Options for Gadget virtual functions. (to make changes easier in the future)
  #define M_GADGETVIRTUAL M_PBFUNCTION

  #define M_ReadFile(file,buffer,length,nbread) ReadFile(file, buffer, length, &nbread, 0)
  #define M_WriteFile(file,buffer,length,nbwrote) WriteFile(file, buffer, length, &nbwrote, 0)
  #define M_OpenFile(filename)           (HANDLE)CreateFile(filename, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
  #define M_OpenBinaryFile(filename)     (HANDLE)CreateFile(filename, GENERIC_READ, FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0)
  #define M_OpenWriteFile(filename)      (HANDLE)CreateFile(filename, GENERIC_READ | GENERIC_WRITE, FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_SHARE_DELETE, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
  #define M_OpenFileSequential(filename) (HANDLE)CreateFile(filename, GENERIC_READ, FILE_SHARE_WRITE | FILE_SHARE_READ | FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0)
  #define M_CreateFile(filename)         (HANDLE)CreateFile(filename, GENERIC_WRITE | GENERIC_READ, FILE_SHARE_READ, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
  #define M_Lof(result, file)            result = GetFileSize(file, 0)
  #define M_Seek(File, Position)         SetFilePointer(File, Position, 0, FILE_BEGIN);
  #define M_SeekQuad(File, Position)     SetFilePointer(File, ((int *)&Position)[0], ((int *)&Position)+1, FILE_BEGIN);
  #define M_RelativeSeek(File, Position) { LARGE_INTEGER __LargeInteger; __LargeInteger.QuadPart = Position; SetFilePointer(File, __LargeInteger.LowPart, &__LargeInteger.HighPart, FILE_CURRENT); } // If we don't specify the HighPosition, it fails to seek relative on > 4GB files !

  #define M_SetCurrentDirectory(path)    SetCurrentDirectory(path)
  #define M_CloseFile(file)              CloseHandle(file)
  #define M_DeleteFile(filename)         DeleteFile((TCHAR *)filename)

  #define M_Alloc(size) HeapAlloc(PB_MemoryBase, 0, size)
  #define M_AllocZero(size) HeapAlloc(PB_MemoryBase, HEAP_ZERO_MEMORY, size)
  #define M_Free(memory) HeapFree(PB_MemoryBase, 0, (LPVOID)(memory))
  #define M_ReAlloc(old, size) HeapReAlloc(PB_MemoryBase, HEAP_ZERO_MEMORY, old, size)
  #define M_ZeroMemory(memory, size) ZeroMemory((void *)(memory), (int)(size))

  #define M_GetProcAddress(library, functionname) GetProcAddress(library, functionname)
  #define M_LoadLibrary(name) LoadLibrary(name)
  #define M_FreeLibrary(library) FreeLibrary(library)
  #define M_Library HMODULE

  #define M_CopyMemory(destination, source, size) CopyMemory(destination, source, size);
  #define M_MoveMemory(destination, source, size) memmove(destination, source, size);

  // Unused on Windows as the API is unicode compliant
  #define StringToFilename(a)
  #define FreeFilename(a)

  // Thread stuffs
  #define M_PBTHREAD DWORD WINAPI
  #define M_CreateThread(Result, StackSize, ThreadRoutine, UserData) { \
        HANDLE Handle; \
        DWORD ThreadID; \
        if (Handle = CreateThread(0, StackSize, ThreadRoutine, UserData, 0, &ThreadID)) \
        { \
          CloseHandle(Handle); \
          Result = 1; \
        } \
      }

  #ifdef X64
    #define itoa _itoa // On x64, itoa is defined as _itoa.
  #endif

  // #include <winnls.h> /* For the CP_UTF8 constant - We don't include it because of some conflicts with win.h */
  // define this also in non-unicode mode, as it is needed in some places
  #define CP_UTF8 65001

  #ifdef UNICODE
    #ifndef NO_UNICODE_ALIASES
      #undef strlen
      #define strlen wcslen

      #undef strcat
      #define strcat wcscat

      #undef strcmp
      #define strcmp wcscmp

      // Once more LCC redefine the _wcsicmp so we have to workaround it..

      #if !defined(PELLES) && !defined(VISUALC)
        #undef _wcsicmp
        int  _wcsicmp(const wchar_t *, const wchar_t *);
      #endif

      #undef stricmp
      #define stricmp _wcsicmp

      #undef strncmp
      #define strncmp wcsncmp

      #undef strnicmp
      #define strnicmp _wcsnicmp

      #undef strcpy
      #define strcpy wcscpy

      #undef strncpy
      #define strncpy wcsncpy

      #undef strdup
      #define strdup _wcsdup

      #undef strchr
      #define strchr wcschr

      #undef strstr
      #define strstr wcsstr

      #ifndef NO_SPRINTF_ALIAS
        #undef sprintf
        #define sprintf pb_swprintf
      #endif

      #undef snprintf
      #define snprintf _snwprintf

      #undef printf
      #define printf wprintf

      #undef sscanf
      #define sscanf swscanf

      #undef fscanf
      #define fscanf fwscanf

      #undef fprintf
      #define fprintf fwprintf

      #undef scanf
      #define scanf wscanf

      #ifndef NO_ATOI_ALIAS
        #undef atoi
        #define atoi _wtoi
      #endif

      #undef itoa
      #define itoa _itow
    #endif
  #endif

  #ifdef VISUALC
    #if !defined(UNICODE) || defined(NO_UNICODE_ALIASES)
      #define strnicmp _strnicmp
      #define stricmp _stricmp
      #define strdup _strdup
      #define snprintf _snprintf
    #endif

    // used in some libs (Mail) directly
    #define wcsicmp _wcsicmp
    #define swprintf pb_swprintf
  #endif

#else

#endif

#ifdef LINUX
  /* Needed by pthread to have access to recursive mutexes
   */
  #ifndef _GNU_SOURCE
    #define _GNU_SOURCE
  #endif

  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <unistd.h>
  #include <unistd.h>
  #include <dlfcn.h>
  #include <pthread.h>
  #include <limits.h>

  // Defined in limits.h
  #define MAX_PATH PATH_MAX

  #ifdef POWERPC
    /* Believe it or not, there is a standard header which defines LITTLE_ENDIAN on a PPC processor ! (located in <stdlib.h>)
     */
    #ifdef LITTLE_ENDIAN
      #undef LITTLE_ENDIAN
    #endif

    #define M_SYSFUNCTION(a) M_C_LINKAGE a
    #define M_SYSVIRTUAL
    #define STDCALL_ATTRIBUTE
  #else
    #define PB_LITTLE_ENDIAN

    #ifdef X86
      #define M_SYSFUNCTION(a) M_C_LINKAGE a __attribute__((stdcall))
      #define STDCALL_ATTRIBUTE __attribute__((stdcall))
      #define M_SYSVIRTUAL __attribute__((stdcall))
    #else
      // x64 just have one calling convention
      #define M_SYSFUNCTION(a) M_C_LINKAGE a
      #define STDCALL_ATTRIBUTE
      #define M_SYSVIRTUAL
    #endif
  #endif

  M_SYSFUNCTION(void) itoa(int number, char *buffer, int base);

  /* Note: in the compiler lib, it is defined as unsigned, but in the libraries we use signed,
    *       so it works with C++ as well.
    */
  #ifdef QT
    typedef ushort pb_wchar_t;
  #else
    typedef unsigned short pb_wchar_t;
  #endif
  typedef pb_wchar_t pb_rune_t;

  #ifndef NO_WCHAR_T_ALIAS
    #define wchar_t pb_wchar_t
    #define rune_t pb_rune_t

    #define wcscat   pb_wcscat
    #define wcschr   pb_wcschr
    #define wcscmp   pb_wcscmp
    #define wcscpy   pb_wcscpy
    #define wcsdup   pb_wcsdup
    #define wcslen   pb_wcslen
    #define wcsicmp  pb_wcsicmp
    #define wcsnicmp pb_wcsnicmp
    #define wcsncmp  pb_wcsncmp
    #define wcsncpy  pb_wcsncpy
    #define wcsstr   pb_wcsstr
    #define wmemchr  pb_wmemchr
    #define itow     pb_itow
    #define wtoi     pb_wtoi
    #define swprintf pb_swprintf
  #endif

  pb_wchar_t *pb_wcscat(pb_wchar_t *s1, const pb_wchar_t *s2);
  pb_wchar_t *pb_wcschr(const pb_wchar_t *s, pb_wchar_t c);
  int      pb_wcscmp(const pb_wchar_t *s1, const pb_wchar_t *s2);
  pb_wchar_t *pb_wcscpy(pb_wchar_t *s1, const pb_wchar_t *s2);
  size_t   pb_wcslen(const pb_wchar_t *s);
  int      pb_wcsicmp(const pb_wchar_t *s1, const pb_wchar_t *s2);
  int      pb_wcsncmp(const pb_wchar_t *s1, const pb_wchar_t *s2, size_t n);
  int      pb_wcsnicmp(const pb_wchar_t *s1, const pb_wchar_t *s2, size_t n);
  pb_wchar_t *pb_wcsncpy(pb_wchar_t *s1, const pb_wchar_t *s2, size_t n);
  pb_wchar_t *pb_wcsdup(const pb_wchar_t *s);
  pb_wchar_t *pb_wcsstr(const pb_wchar_t *big, const pb_wchar_t *little);
  pb_wchar_t *pb_wmemchr(const pb_wchar_t *s, pb_wchar_t c, size_t n);
  void     pb_itow(int val, pb_wchar_t *dst, int radix);
  int      pb_wtoi(const pb_wchar_t *String);
  int      pb_swprintf(pb_wchar_t *Buffer, const pb_wchar_t *Format, ...);

  // #include <winnls.h> /* For the CP_UTF8 constant - We don't include it because of some conflicts with win.h */
  // define this also in non-unicode mode, as it is needed in some places
  #define CP_UTF8 65001
  #define CP_ACP 0

  #ifdef UNICODE
    #ifndef NO_TCHAR_TYPEDEF
      typedef pb_wchar_t TCHAR;
    #endif
    typedef unsigned short TBYTE;
    typedef unsigned short BCHAR;
    #define TEXT(a) ((TCHAR *)L##a)

    #ifndef NO_UNICODE_ALIASES
      #undef strlen
      #define strlen pb_wcslen

      #undef strcat
      #define strcat pb_wcscat

      #undef strcmp
      #define strcmp pb_wcscmp

      #undef stricmp
      #define stricmp pb_wcsicmp

      #undef strncmp
      #define strncmp pb_wcsncmp

      #undef strnicmp
      #define strnicmp pb_wcsnicmp

      #undef strcpy
      #define strcpy pb_wcscpy

      #undef strdup
      #define strdup pb_wcsdup

      #undef strncpy
      #define strncpy pb_wcsncpy

      #undef strchr
      #define strchr pb_wcschr

      #undef strstr
      #define strstr pb_wcsstr

      #ifndef NO_SPRINTF_ALIAS
        #undef sprintf
        #define sprintf pb_swprintf
      #endif

      //#undef printf
      //#define printf pb_wprintf

      //#undef sscanf
      //#define sscanf pb_swscanf

      #undef fscanf
      #define fscanf pb_fwscanf

      #undef fprintf
      #define fprintf pb_fwprintf

      #undef scanf
      #define scanf pb_wscanf

      #ifndef NO_ATOI_ALIAS
        #undef atoi
        #define atoi pb_wtoi
      #endif

      #undef itoa
      #define itoa pb_itow

    #else
      #define stricmp  strcasecmp  // For compatibility with LCC/Win32
      #define strnicmp strncasecmp // For compatibility with LCC/Win32
    #endif

  #else
    typedef char TCHAR;
    typedef unsigned char TBYTE;
    typedef unsigned char BCHAR;
    #define TEXT(a) a

    #define stricmp  strcasecmp  // For compatibility with LCC/Win32
    #define strnicmp strncasecmp // For compatibility with LCC/Win32
  #endif

  typedef pb_wchar_t WCHAR;

  #define MultiByteToWideChar(a,b,c,d,e,f)     SYS_MultiByteToWideChar(a,b,c,d,e,f)
  #define WideCharToMultiByte(a,b,c,d,e,f,g,h) SYS_WideCharToMultiByte(a,b,c,d,e,f,g,h)

  void  SYS_InitThreadString(void);
  void  SYS_FreeThreadString(void);

  //---------------------------------------

  #define SYS_StringToFilename M_UnicodeFunction(SYS_StringToFilename)
  #define SYS_FreeFilename     M_UnicodeFunction(SYS_FreeFilename)
  #define SYS_FilenameToBuffer M_UnicodeFunction(SYS_FilenameToBuffer)

  M_SYSFUNCTION(TCHAR *) SYS_StringToFilename(const WCHAR *Filename);
  M_SYSFUNCTION(void)    SYS_FreeFilename(const WCHAR *Filename);
  M_SYSFUNCTION(void)    SYS_FilenameToBuffer(const char *Filename, int PreviousPosition);

  #define StringToFilename(a)   a = SYS_StringToFilename(a)
  #define FreeFilename(a)       SYS_FreeFilename(a)
  #define FilenameToBuffer(a,b) SYS_FilenameToBuffer(a,b)

  //---------------------------------------

  #ifdef PB_MACOS

    #if defined(PB_USE_CFSTRING) || defined(PB_USE_NSSTRING)

      #include <CoreFoundation/CFString.h>

      #define SYS_StringToCFString M_UnicodeFunction(SYS_StringToCFString)
      #define SYS_FreeCFString     M_UnicodeFunction(SYS_FreeCFString)
      #define SYS_CFStringToBuffer M_UnicodeFunction(SYS_CFStringToBuffer)
      #define SYS_CopyCFString     M_UnicodeFunction(SYS_CopyCFString)

      M_SYSFUNCTION(TCHAR *) SYS_StringToCFString(const TCHAR *String);
      M_SYSFUNCTION(void)    SYS_FreeCFString(const TCHAR *String);
      M_SYSFUNCTION(void)    SYS_CFStringToBuffer(CFStringRef String, int PreviousPosition);
      M_SYSFUNCTION(void)    SYS_CopyCFString(TCHAR *Output, CFStringRef String, int OutputLength);

      #define StringToCFString(a)   a = SYS_StringToCFString(a)
      #define FreeCFString(a)       SYS_FreeCFString(a)
      #define CFStringToBuffer(a,b) SYS_CFStringToBuffer(a,b)
      #define CopyCFString(a,b,c)   SYS_CopyCFString(a,b,c)

    #endif

    // #define M_AllocateCFString(Text) CFStringCreateWithCString(0, Text, kCFStringEncodingMacRoman)

    // WARNING, this one can fails and return null with chars > 128
    //
    #define M_GetCFString(Text) CFStringGetCStringPtr(Text, kCFStringEncodingMacRoman)

    // The windows or ISO 1 encoding makes all crashing !

    // #define M_AllocateCFString(Text) CFStringCreateWithCString(0, Text, kCFStringEncodingISOLatin1)
    // #define M_GetCFString(Text) CFStringGetCStringPtr(Text, kCFStringEncodingISOLatin1)

    #ifdef UNICODE
      #define M_AllocateCFString(Text)               CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)Text, pb_wcslen(Text)*sizeof(TCHAR), kCFStringEncodingUnicode, false)
      #define M_AllocateCFStringLength(Text, Length) CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)Text, (Length)*sizeof(TCHAR), kCFStringEncodingUnicode, false)
    #else
      #define M_AllocateCFString(Text)               CFStringCreateWithCString(0, Text, kCFStringEncodingISOLatin1)
      #define M_AllocateCFStringLength(Text, Length) CFStringCreateWithBytes(kCFAllocatorDefault, (const UInt8 *)Text, Length, kCFStringEncodingISOLatin1, false)
    #endif

    // Can't be put in PureLibrary.h as it needs to be after the Carbon includes
    #ifndef CGFLOAT_DEFINED
      #if defined(__LP64__) && __LP64__
        typedef double CGFloat;
        #define CGFLOAT_MIN DBL_MIN
        #define CGFLOAT_MAX DBL_MAX
        #define CGFLOAT_IS_DOUBLE 1
      #else    /* !defined(__LP64__) || !__LP64__ */
        typedef float CGFloat;
        #define CGFLOAT_MIN FLT_MIN
        #define CGFLOAT_MAX FLT_MAX
        #define CGFLOAT_IS_DOUBLE 0
      #endif    /* !defined(__LP64__) || !__LP64__ */
      #define CGFLOAT_DEFINED 1
    #endif

  #endif

  // mutex stuff
  #define M_MUTEX               pthread_mutex_t
  #define M_InitMutex(mutex)    { pthread_mutexattr_t mutex_attr; pthread_mutexattr_init(&mutex_attr); pthread_mutexattr_settype(&mutex_attr, PTHREAD_MUTEX_RECURSIVE); pthread_mutex_init(&(mutex), &mutex_attr); pthread_mutexattr_destroy(&mutex_attr); }
  #define M_FreeMutex(mutex)    pthread_mutex_destroy(&(mutex))
  #define M_LockMutex(mutex)    pthread_mutex_lock(&(mutex))
  #define M_UnlockMutex(mutex)  pthread_mutex_unlock(&(mutex))
  // #define M_TryLockMutex(mutex) (!pthread_mutex_trylock(&(mutex))) // use NOT to have same result as on windows

  // abstraction of thread local storage
  #define M_TLS                  pthread_key_t
  #define M_TlsInit(key)         pthread_key_create(&(key), NULL)
  #define M_TlsFree(key)         pthread_key_delete(key)
  #define M_TlsRead(key)         pthread_getspecific(key)
  #define M_TlsWrite(key, value) pthread_setspecific(key, (const void *)(value))

  // Thread stuffs
  #define M_PBTHREAD void *
  #define M_CreateThread(Result, StackSize, ThreadRoutine, UserData) { \
        pthread_t tid; \
        pthread_attr_t attr; \
          pthread_attr_init(&attr); \
        pthread_attr_setstacksize(&attr, StackSize); \
        if (pthread_create(&tid, &attr, (void *)&ThreadRoutine, (void *)UserData) == 0) \
          Result = 1; \
        pthread_attr_destroy(&attr); \
      }

  #define M_BACKSLASH '/'
  #define M_FILE FILE *
  #define M_INSTANCE int
  #define M_PBFUNCTION(type) M_C_LINKAGE type
  #define M_INLINE(type) static inline type
  #define M_PBVIRTUAL
  #define M_FILE_ERROR 0
  #define M_CALLBACK M_C_LINKAGE int

  #define M_ReadFile(file,buffer,length,nbread) (nbread = fread(buffer, 1, length, file))
  #define M_WriteFile(file,buffer,length,nbwrote) (nbwrote = fwrite(buffer, 1, length, file)) // need to put parenthesis around, as we can use this in an if()
  #define M_OpenFile(filename) fopen((char *)filename, "r")
  #define M_OpenBinaryFile(filename) fopen((char *)filename, "rb")
  #define M_OpenWriteFile(filename) fopen((char *)filename, "r+")
  #define M_OpenFileSequential(filename) fopen((char *)filename, "r")
  #define M_CreateFile(filename) fopen((char *)filename, "w+")
  #define M_Lof(result, file) { struct stat StatBuffer; fflush(file); fstat(fileno(file), &StatBuffer); result = StatBuffer.st_size; }
  // Note: ftell & fseek do not properly map to 64bit types on x86, so use ftello & fseeko instead
  #define M_Seek(File, Position) fseeko(File, Position, SEEK_SET);
  #define M_SeekQuad(File, Position) fseeko(File, Position, SEEK_SET);
  #define M_RelativeSeek(File, Position) fseeko(File, Position, SEEK_CUR);

  #define M_SetCurrentDirectory(path)
  #define M_CloseFile(file)      fclose(file)
  #define M_DeleteFile(filename) unlink((char *)filename)

  #define M_Alloc(size) SYS_AllocateMemoryWithSize(size)
  #define M_AllocZero(size) SYS_AllocateMemoryWithSize(size)
  #define M_Free(memory) SYS_FreeMemoryWithSize((void *)(memory))
  #define M_ReAlloc(old, size) SYS_ReAllocateMemoryWithSize(old, size)
  #define M_ZeroMemory(memory, size) memset((void *)(memory), 0, (size_t)(size))

  #define M_GetProcAddress(library, functionname) dlsym(library, functionname)
  #define M_LoadLibrary(name) dlopen(name, RTLD_GLOBAL | RTLD_LAZY)
  #define M_FreeLibrary(library) dlclose(library)
  #define M_Library void *

  #define M_CopyMemory(destination, source, size) memcpy(destination, source, size);
  #define M_MoveMemory(destination, source, size) memmove(destination, source, size);
#endif


#define strncpyz(out, in, length) { strncpy(out, in, length); out[length] = 0; }


#ifdef POWERPC
  typedef long quad;
#else
  #ifdef VISUALC
    typedef _int64 quad;
  #else
    typedef long long quad;
  #endif
#endif

#ifdef WINDOWS
  #define M_QUAD "I64" // prefix for use in format specifiers: printf("size = %"M_QUAD"d", value)
#else
  #define M_QUAD "ll"
#endif

#ifdef PB_64
  typedef quad integer;
  typedef unsigned long long unsigned_integer;
  #define M_INTEGER M_QUAD // prefix for use in format specifiers: printf("size = %"M_INTEGER"d", value)
#else
  typedef int integer;
  typedef unsigned int unsigned_integer;
  #define M_INTEGER ""
#endif

// for toupper, towupper, etc
//
#include <ctype.h>
#include <wctype.h>

#ifdef PB_MACOS
  // MacOS weirdness (10.3 mostly):
  // It redefines these to __towupper() after defining them normally,
  // which totally messes up, probably due to an optimisation. so undef them as a fix.
  //
  // doesn't OSX just suck sometimes ? So much for the nice comment :p
  #undef towupper
  #undef towlower
  #undef toupper
  #undef tolower
#endif

// Define the StringBase.h functions

M_SYSFUNCTION(integer) SYS_UTF8ToAsciiLength(const unsigned char* in, integer inlen);
M_SYSFUNCTION(integer) SYS_UTF8LengthToBytes(const unsigned char* in, integer NbCharacters);

// Define the Utility.h functions

int SYS_IsUTF8(const char * string);
#define IsUTF8(a) SYS_IsUTF8(a)


char  *SYS_UTF16ToUTF8(const WCHAR *String);
WCHAR *SYS_UTF8ToUTF16(const char *String);

#define SYS_StringToAscii M_UnicodeFunction(SYS_StringToAscii)
#define SYS_FreeAscii     M_UnicodeFunction(SYS_FreeAscii)
#define SYS_AsciiToBuffer M_UnicodeFunction(SYS_AsciiToBuffer)
#define SYS_AsciiToString M_UnicodeFunction(SYS_AsciiToString)

M_SYSFUNCTION(char *)  SYS_StringToAscii(const TCHAR *Ascii);
M_SYSFUNCTION(void)    SYS_FreeAscii(const void *Ascii);
M_SYSFUNCTION(void)    SYS_AsciiToBuffer(const char *Ascii, int PreviousPosition);
M_SYSFUNCTION(TCHAR *) SYS_AsciiToString(const char *Ascii);

#define StringToAscii(a)   a = (TCHAR *)SYS_StringToAscii(a)
#define ToAscii(a)         SYS_StringToAscii(a)
#define FreeAscii(a)       SYS_FreeAscii(a)
#define AsciiToBuffer(a,b) SYS_AsciiToBuffer(a,b)
#define AsciiToString(a)   a = (char *)SYS_AsciiToString(a)

//---------------------------------------

#define SYS_StringToUTF8  M_UnicodeFunction(SYS_StringToUTF8)
#define SYS_FreeUTF8      M_UnicodeFunction(SYS_FreeUTF8)
#define SYS_UTF8ToBuffer  M_UnicodeFunction(SYS_UTF8ToBuffer)
#define SYS_UTF8ToString  M_UnicodeFunction(SYS_UTF8ToString)

M_SYSFUNCTION(char *)  SYS_StringToUTF8(const TCHAR *UTF8);
M_SYSFUNCTION(void)    SYS_FreeUTF8(const void *UTF8);
M_SYSFUNCTION(void)    SYS_UTF8ToBuffer(const char *UTF8, int PreviousPosition);
M_SYSFUNCTION(TCHAR *) SYS_UTF8ToString(const char *UTF8);

#define StringToUTF8(a)   a = (TCHAR *)SYS_StringToUTF8(a)
#define ToUTF8(a)         SYS_StringToUTF8(a)
#define FreeUTF8(a)       SYS_FreeUTF8(a)
#define UTF8ToBuffer(a,b) SYS_UTF8ToBuffer(a,b)
#define UTF8ToString(a)   a = (char *)SYS_UTF8ToString(a)

//---------------------------------------

#define SYS_StringToUTF16  M_UnicodeFunction(SYS_StringToUTF16)
#define SYS_FreeUTF16      M_UnicodeFunction(SYS_FreeUTF16)
#define SYS_UTF16ToBuffer  M_UnicodeFunction(SYS_UTF16ToBuffer)
#define SYS_UTF16ToString  M_UnicodeFunction(SYS_UTF16ToString)

M_SYSFUNCTION(TCHAR *) SYS_StringToUTF16(const TCHAR *UTF16);
M_SYSFUNCTION(void)    SYS_FreeUTF16(const TCHAR *UTF16);
M_SYSFUNCTION(void)    SYS_UTF16ToBuffer(const WCHAR *UTF16, int PreviousPosition);
M_SYSFUNCTION(TCHAR *) SYS_UTF16ToString(const WCHAR *UTF16);

#define StringToUTF16(a)   a = SYS_StringToUTF16(a)
#define ToUTF16(a)         SYS_StringToUTF16(a)
#define FreeUTF16(a)       SYS_FreeUTF16(a)
#define UTF16ToBuffer(a,b) SYS_UTF16ToBuffer(a,b)
#define UTF16ToString(a)   a = SYS_UTF16ToString(a)


// Define the StringBase.h functions

M_SYSFUNCTION(int)     SYS_FastAllocateString4(TCHAR **Address, const TCHAR *String);
M_SYSFUNCTION(int)     SYS_FastAllocateStringFree4(TCHAR **Address, const TCHAR *String);
M_SYSFUNCTION(int)     SYS_FreeString(const TCHAR *String);
M_SYSFUNCTION(TCHAR *) SYS_GetOutputBuffer(int Length, int PreviousPosition);
M_SYSFUNCTION(TCHAR *) SYS_GetOutputAddress(int PreviousPosition);
M_SYSFUNCTION(void)    SYS_ReduceStringSize(int);
M_SYSFUNCTION(int)     SYS_GetParameterIndex(const TCHAR *Parameter);
M_SYSFUNCTION(TCHAR *) SYS_ResolveParameter(int Index);
M_SYSFUNCTION(void)    SYS_SetString(const TCHAR *String, int PreviousStringPosition);
M_SYSFUNCTION(void)    SYS_SetNullString(int PreviousStringBase);
M_SYSFUNCTION(int)     SYS_UTF8ToAscii(unsigned char* out, integer *outlen, const unsigned char* in, integer *inlen);
M_SYSFUNCTION(int)     SYS_AsciiToUTF8(unsigned char* out, integer *outlen, const unsigned char* in, integer *inlen);
M_SYSFUNCTION(void)    SYS_FastStringCopy(TCHAR *Output, const TCHAR *Input, int Length);
M_SYSFUNCTION(int)     SYS_WideCharToMultiByte(int CodePage, int Flags, const WCHAR *String, int Length, char *Output, int OutputLength, WCHAR *DefaultChar, int *UsedDefaultChar);
M_SYSFUNCTION(int)     SYS_MultiByteToWideChar(int CodePage, int Flags, const char *String, int Length, WCHAR *Output, int OutputLength);
M_SYSFUNCTION(int)     SYS_GetStringBasePosition(void);
M_SYSFUNCTION(void)    SYS_SetStringBasePosition(int Position);



// for laziness and consistency with the other ...ToBuffer() macros :)
#define NullToBuffer(a) SYS_SetNullString(a)

typedef struct PB_StructureSimpleList
{
  struct PB_StructureSimpleList *Next;
  struct PB_StructureSimpleList *Previous;
} PB_SimpleList;


void *PB_SimpleList_Add     (void *FirstElement, int Size);
void *PB_SimpleList_AddAfter(void *PreviousElement, int Size);
void  PB_SimpleList_Remove  (void *FirstElement, PB_SimpleList *Element);
void *PB_SimpleList_IsID    (void *FirstElement, void *ID);
int   PB_SimpleList_Count   (void *FirstElement);
void  PB_SimpleList_Clear   (void *FirstElement);

#ifdef LINUX
  typedef integer (*FARPROC)();  // To have a function pointer as under Windows
#endif

extern M_INSTANCE PB_Instance;
extern int  *PB_MemoryBase;

/* Define our macros to handle the little/big endian problem smoothly
 * PowerPC = big endian
 * x86     = little endian
 */

// Force a swap
#define M_SwapShort(Number) ((((Number) << 8) & 0xFF00) | ((Number) >> 8))
#define M_SwapInt(Number)   (((Number) << 24) | (((Number) << 8) & 0x00FF0000) | (((Number) >> 8) & 0x0000FF00) | (((Number) >> 24) & 0x000000FF))

// Swap only if big endian
#ifdef PB_LITTLE_ENDIAN
  #define M_Short(Number) Number
  #define M_Int(Number)   Number
#else
  #define M_Short(Number) M_SwapShort(Number)
  #define M_Int(Number)   M_SwapInt(Number)
#endif


/* Used by File, Memory and Mail libraries
 * Note: PB_Ascii and PB_Unicode are defined below as standard types
 */
#define PB_UTF8  2

/* Unsupported format constants (for ReadStringFormat/WriteStringFormat)
 */
#define PB_UTF16BE 4
#define PB_UTF32   5
#define PB_UTF32BE 6

/* Used by ResizeGadget(), ResizeWindow()
 */
#define PB_Ignore (-0xFFFF)

/* Used by String functions and in a few other places
 * Mapped to native PB types
 */
#define PB_Byte 1
#define PB_Word 3
#define PB_Long 5
#define PB_Structure 7
#define PB_String 8
#define PB_Float 9
#define PB_FixedString 10 // used only internally in some libraries
#define PB_Character 11
#define PB_Double 12
#define PB_Quad 13
#define PB_Integer 21
#define PB_Ascii 24
#define PB_Unicode 25

#define PB_NativeTypeMask 0x1F

#define PB_ByteLength (1 << 6) // 64, must be bigger than the last native type mask

#define PB_Any (-1)
#define PB_Default (-1)
#define PB_All (-1)

#define PB_Absolute 0 // used by 3D engine and FileSeek()
#define PB_Relative 1

#define PB_Unit_Pixel            1
#define PB_Unit_Point            2
#define PB_Unit_Inch             3
#define PB_Unit_Millimeter       4

// Compiler flag build in each exe to allow runtime check for these modes
extern int PB_Compiler_Unicode;
extern int PB_Compiler_Thread;
extern int PB_Compiler_Purifier;
extern int PB_Compiler_Debugger;
extern int PB_Compiler_DPIAware;

// Internal debug routines
#if defined(WINDOWS) && !defined(NO_UNICODE_ALIASES)
  #define debugt(a) printf(TEXT("[%s:%i] %s\n"), TEXT(__FILE__), __LINE__, a);
  #define debugs(a) printf(TEXT("[%s:%i] %s\n"), TEXT(__FILE__), __LINE__, TEXT(a));
  #define debugi(a) printf(TEXT("[%s:%i] %s = %d\n"), TEXT(__FILE__), __LINE__, TEXT(#a), (int)a);
  #define debugf(a) printf(TEXT("[%s:%i] %s = %f\n"), TEXT(__FILE__), __LINE__, TEXT(#a), a);
  #define debugd(a) printf(TEXT("[%s:%i] %s = %g\n"), TEXT(__FILE__), __LINE__, TEXT(#a), a);
  #define debugp(a) printf(TEXT("[%s:%i] %s = %p\n"), TEXT(__FILE__), __LINE__, TEXT(#a), a);
#else
  #define debugt(a) printf("[%s:%i] %s\n", __FILE__, __LINE__, a);
  #define debugs(a) printf("[%s:%i] %s\n", __FILE__, __LINE__, a);
  #define debugi(a) printf("[%s:%i] %s = %d\n", __FILE__, __LINE__, #a, (int)a);
  #define debugf(a) printf("[%s:%i] %s = %f\n", __FILE__, __LINE__, #a, a);
  #define debugd(a) printf("[%s:%i] %s = %g\n", __FILE__, __LINE__, #a, a);
  #define debugp(a) printf("[%s:%i] %s = %p\n", __FILE__, __LINE__, #a, a);
#endif

// We can't alias debug_print() to printf() after the printf() declaration, so just check that when building the full packages (shouldn't occurs that often)
// We can then still use printf() while developping
// This trick doesn't work because of precompiled headers, needs to think about a new way
/* #ifdef PB_RELEASE
  #ifndef PB_ALLOW_PRINTF
    #undef printf
    #define printf(x, ...) PB_UNALLOWED_PRINTF_ERROR
  #endif
#endif */

// Include it at the very end as it can change the NO_UNICODE_ALIASES define
#include <FunctionPrototypes.h>
#include <SystemBase/SystemBase.h>


#ifdef __cplusplus
  } // extern "C"
#endif

#endif
