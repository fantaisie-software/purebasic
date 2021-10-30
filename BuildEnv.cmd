@echo off

:: ************************************************************************
:: *         Setup the build Environment for builds on Windows            *
:: ************************************************************************
::
:: Run this script to setup a command shell with the proper environment
:: variables required for building the IDE and other programs in this 
:: repository.
::
:: The commandline for execution of this script is the following:
::
::    BuildEnv.cmd <TargetPureBasicDirectory>
::
:: The <TargetPureBasicDirectory> parameter is mandatory. It specifies 
:: the compiler to use and building the IDE will actually override 
:: the IDE and other resources within that target directory. It is 
:: therefore recommended to setup a dedicated PB installation for
:: IDE development and testing.
::
:: If the target directory is a SpiderBasic installation, the SB IDE 
:: will be built instead. Note that for this case you will need a 
:: regular PB installation available in the PATH as well.
::
:: By default this script will launch a command shell with the build
:: environment. You can suppress this by setting the PB_BATCH=1 env
:: variable before running this script.
::
:: ************************************************************************

:: Check presence of the mandatory argument
IF NOT [%1]==[] GOTO path_argument_ok

echo Invalid parameters: Missing argument for target PureBasic directory
pause
exit /b 1


:path_argument_ok

:: Set PUREBASIC_HOME and ensure the compiler and IDE are in the path
set PUREBASIC_HOME=%1
set PATH=%PUREBASIC_HOME%\Compilers;%PUREBASIC_HOME%;%PATH%

:: Check if this is PB or SB
IF EXIST %PUREBASIC_HOME%\Compilers\pbcompiler.exe (
    GOTO configure_purebasic
) ELSE (
    IF EXIST %PUREBASIC_HOME%\Compilers\sbcompiler.exe (
        GOTO configure_spiderbasic
    )
)

@echo Failed to detect PB or SB compiler in %PUREBASIC_HOME%
exit /b 1


:configure_purebasic

SET PB_JAVASCRIPT=

:: Detect processor architecture used by the compiler
%PUREBASIC_HOME%\Compilers\pbcompiler.exe /version | findstr /C:"(Windows - x64)" 1>nul

IF %ERRORLEVEL% EQU 0 (
    SET PB_PROCESSOR=X64
) ELSE (
    SET PB_PROCESSOR=X86
)

echo Setting environment for PureBasic %PB_PROCESSOR% in %PUREBASIC_HOME%
echo.

GOTO configure_common

:configure_spiderbasic

SET PB_JAVASCRIPT=1

echo Setting environment for SpiderBasic in %PUREBASIC_HOME%
echo.

GOTO configure_common

:configure_common

:: There should be no need to modify these:
set PB_WINDOWS=1
set PB_SUBSYSTEM=purelibraries/

:: Open command shell unless we are in batch mode:
IF DEFINED PB_BATCH GOTO end

cmd

:end
