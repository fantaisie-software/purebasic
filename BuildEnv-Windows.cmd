@echo off

:: ************************************************************************
:: *         Setup the build Environment for builds on Windows            *
:: ************************************************************************
::
:: Run this script to setup a command shell with the proper environment
:: variables required for building the IDE and other programs in this 
:: repository.
::
:: Most settings should be autodetected. You can set the following variables
:: before running this script (for example in a wrapper) to specify different
:: values. You can also just set them as global environment variables in 
:: Windows if you do not need to change them often.
::
:: Possible settings:
::
::   SET PB_JAVASCRIPT=1
::
::      Build the SpiderBasic IDE (default is PureBasic IDE)
::
::   SET PUREBASIC_HOME=<path to PB installation>
::
::      Explicitly set a PureBasic installation to use. If this is not set
::      there is an attempt to find it in the PATH environment variable.
::
::      It is recommended to use a dedicated PB installation for IDE development
::      because a build of the IDE will override the IDE in the used PB 
::      directory.
::

:: Autodetect PB directory
IF DEFINED PUREBASIC_HOME GOTO purebasic_home_defined

:: Figure out the compiler name
IF DEFINED PB_JAVASCRIPT (
    SET PBCOMPILER_NAME=sbcompiler.exe
) ELSE (
    SET PBCOMPILER_NAME=pbcompiler.exe
)

FOR %%I IN (%PBCOMPILER_NAME%) DO SET PBCOMPILER_FULL_PATH=%%~$PATH:I

IF NOT DEFINED PBCOMPILER_FULL_PATH GOTO purebasic_home_error

@echo %PBCOMPILER_FULL_PATH%

set PUREBASIC_HOME=%PBCOMPILER_FULL_PATH:~0,-25%

GOTO purebasic_home_defined

:purebasic_home_error

@echo Cannot autodetect PureBasic directory. Please set PUREBASIC_HOME.
exit /b 1

:purebasic_home_defined

:: Autodetect processor architecture from PBCompiler version
IF DEFINED PB_JAVASCRIPT GOTO processor_defined
IF DEFINED PB_PROCESSOR GOTO processor_defined

"%PUREBASIC_HOME%\Compilers\pbcompiler.exe" /version | findstr /C:"(Windows - x64)" 1>nul

IF %ERRORLEVEL% EQU 0 (
    SET PB_PROCESSOR=X64
) ELSE (
    SET PB_PROCESSOR=X86
)

:processor_defined

:: There should be no need to modify these:
set PB_WINDOWS=1
set PB_SUBSYSTEM=purelibraries/
set PATH=%PUREBASIC_HOME%/Compilers;%PATH%

:: Done

echo Setting environment for PureBasic %PB_PROCESSOR% in %PUREBASIC_HOME%
echo.


:: If we don't specify any args, we want to open a CMD. Else we can use this script to setup an env for batching
IF [%1]==[] GOTO opencmd

GOTO end

:opencmd

cmd

:end
