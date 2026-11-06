@echo off

:: ************************************************************************
:: *             Windows Build Script without preconditions               *
:: ************************************************************************
::
:: This script is an optional replacement to build the IDE/Debugger on
:: Windows without the need to install any Unix tools such as make.
::
:: Run this script as follows:
::
::    MakeWindows.cmd <TargetPureBasicDirectory>
::
:: No previous setup or use of "BuildEnv.cmd" is required in this case.
:: For more information on the <TargetPureBasicDirectory> parameter, see 
:: the description of "BuildEnv.cmd" in the main directory.
::
:: NOTE:
:: The makefile is still the official way to build the IDE and debugger,
:: even on Windows. This script is for convenience only. If you make
:: any changes to this build script, the same changes must be made
:: (and tested) in the makefile as well!
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

@echo on

:: ************** Build steps start here *********************************

:: Set path of this script as current directory in case it was started from elsewhere
cd /d %~dp0

:: Clean/Reset the Build directory
IF EXIST Build\ rmdir /Q /S Build
mkdir Build

:: Create the "Build/dummy" file for compatibility with using the real makefile
type NUL > Build\dummy

:: Generate dialog files
@set DIALOGS=Find;Grep;Goto;CompilerOptions;AddTools;About;Preferences;Templates;StructureViewer;Projects;Build;Diff;FileMonitor;History;HistoryShutdown;CreateApp;Updates
PBCompiler /QUIET /CONSOLE ..\DialogManager\DialogCompiler.pb /EXE Build\DialogCompiler.exe
@FOR %%D IN (%DIALOGS%) DO Build\DialogCompiler.exe dialogs\%%D.xml Build\%%D.pb

:: Generate themes
PBCompiler /QUIET /CONSOLE tools\maketheme.pb /EXE Build\maketheme.exe
Build\maketheme.exe Build\DefaultTheme.zip data\DefaultTheme
Build\maketheme.exe %PUREBASIC_HOME%\Themes\SilkTheme.zip data\SilkTheme

:: Generate build info
PBCompiler /QUIET /CONSOLE tools/makebuildinfo.pb /EXE Build/makebuildinfo.exe
Build\makebuildinfo.exe Build

:: Generate version info resource
PBCompiler /QUIET /CONSOLE tools/makeversion.pb /EXE Build/makeversion.exe
Build\makeversion.exe ide Build/VersionInfo.rc data/PBSourceFile.ico

:: Compile the IDE
PBCompiler /QUIET PureBasic.pb /EXE %PUREBASIC_HOME%\PureBasic.exe /THREAD /UNICODE /XP /USER /ICON data/PBLogoBig.ico /DPIAWARE /RESOURCE Build/VersionInfo.rc
