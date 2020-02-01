@echo off

:: Set the PureBasic home directory to a real x64 PureBasic installation (warning:
:: when compiling, the IDE will be overwritten with the new one.
set PUREBASIC_HOME=C:\PureBasic\Svn\v5.70\Build\PureBasic_x64


set PB_VS8=C:/Program Files (x86)/Microsoft Visual Studio 12.0
set PB_PLATEFORM_SDK=C:/Program Files/Microsoft SDKs/Windows/v7.0
set PB_DIRECTX7_SDK=C:/Program Files (x86)/Microsoft DirectX 9.0 SDK (December 2004)
set PB_DIRECTX9_SDK=C:/Program Files (x86)/Microsoft DirectX SDK (August 2009)


set PB_LIBRARIES=%CD%/Libraries
set PB_BUILDTARGET=%CD%/Build/x64


set PATH=%PB_VS8%/VC/bin;%PATH%
set PATH=%PB_VS8%/VC/bin/x86_amd64;%PATH%
set PATH=C:/Program Files (x86)/Microsoft DirectX SDK (August 2009)/Utilities/bin/x86;C:\Program Files\TortoiseSVN\bin;%PATH%


set PB_PROCESSOR=X64

set PATH=%PUREBASIC_HOME%/Compilers;%PATH%

set PB_VC8_ANSI=cl.exe -I"%PB_VS8%/VC/include" -I"%PB_LIBRARIES%" -DWINDOWS -DVISUALC -DX64 -DPB_64 -D_USING_V110_SDK71_ -I"%PB_PLATEFORM_SDK%/Include" -I"%PB_PLATEFORM_SDK%/Include/crt" -I. -I"%PB_DIRECTX9_SDK%/Include" -I"%PB_DIRECTX7_SDK%/Include" /nologo /GS- /D_CRT_NOFORCE_MANIFEST
set PB_VC8=%PB_VC8_ANSI% -DUNICODE
set PB_NASM=nasm.exe -DWINDOWS -fwin64 -O3
set PB_LINKER=link /LIBPATH:"%PB_PLATEFORM_SDK%/Lib/x64" /LIBPATH:"%PB_VS8%/VC/Lib/amd64"
set PB_LIBRARIAN=lib /nologo
set PB_LIBRARYMAKER="%PUREBASIC_HOME%/SDK/LibraryMaker.exe" /NOLOG /COMPRESSED /CONSTANT WINDOWS /CONSTANT %PB_PROCESSOR%
set PB_IOFIX=
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
