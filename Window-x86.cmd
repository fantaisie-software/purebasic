@echo off

:: Set the PureBasic home directory to a real x86 PureBasic installation (warning:
:: when compiling, the IDE will be overwritten with the new one.
set PUREBASIC_HOME=C:\PureBasic\Svn\v5.70\Build\PureBasic_x86


set PB_VS8=C:/Program Files (x86)/Microsoft Visual Studio 12.0
set PB_PLATEFORM_SDK=C:/Program Files/Microsoft SDKs/Windows/v7.0
set PB_DIRECTX7_SDK=C:/Program Files (x86)/Microsoft DirectX 9.0 SDK (December 2004)
set PB_DIRECTX9_SDK=C:/Program Files (x86)/Microsoft DirectX SDK (August 2009)


set PB_LIBRARIES=%CD%/Libraries
set PB_BUILDTARGET=%CD%/Build/x86


set PATH=%PB_VS8%/VC/bin;%PATH%
set PATH=C:/Program Files (x86)/Microsoft DirectX SDK (August 2009)/Utilities/bin/x86;C:\Program Files\TortoiseSVN\bin;%PATH%


set PB_PROCESSOR=X86

set PATH=%PUREBASIC_HOME%/Compilers;%PATH%

set PB_VC8_ANSI=cl.exe -I"%PB_VS8%/VC/include" -I"%PB_LIBRARIES%" -DWINDOWS -DVISUALC -DX86 -D_USING_V110_SDK71_ -I"%PB_PLATEFORM_SDK%/Include" -I"%PB_PLATEFORM_SDK%/Include/crt" -I. -I"%PB_DIRECTX9_SDK%/Include" -I"%PB_DIRECTX7_SDK%/Include" /nologo /arch:IA32 /GS- /D_CRT_NOFORCE_MANIFEST /D_USE_32BIT_TIME_T
set PB_VC8=%PB_VC8_ANSI% -DUNICODE
set PB_NASM=nasm -DWINDOWS -fwin32 -O3
set PB_LINKER=polink
set PB_LIBRARIAN=polib
set PB_LIBRARYMAKER="%PUREBASIC_HOME%/SDK/LibraryMaker.exe" /NOLOG /COMPRESSED /CONSTANT WINDOWS /CONSTANT %PB_PROCESSOR%
set PB_IOFIX="/D__iob_func=__p__iob" /D_gmtime32=gmtime /D_mktime32=mktime
set PB_OGREFLAGS=/MT /O2

set PB_OGRELIBRARIAN=lib /NOLOGO
set PB_WINDOWS=1
set PB_OBJ=obj
set PB_LIB=lib

:: set a default subsystem
set PB_SUBSYSTEM=purelibraries/

echo Setting environment for PureBasic %PB_PROCESSOR%
echo.


:: If we don't specify any args, we want to open a CMD. Else we can use this script to setup an env for batching
IF [%1]==[] GOTO opencmd

GOTO end

:opencmd

cmd

:end
