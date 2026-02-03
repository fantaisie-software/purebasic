:: "Documentation\CHM-BUILD.bat" | v1.0.0 | 2026/02/03
:: Builds PureBasic CHM help files via DocMaker + HTML Help Workshop (hhc.exe).

@ECHO OFF
setlocal enableExtensions enableDelayedExpansion

ECHO.
ECHO ##############################################################################
ECHO #                                                                            #
ECHO # PureBasic Help CHM Builder                                                 #
ECHO #                                                                            #
ECHO ##############################################################################

IF [%1]==[] GOTO :Instructions

:: Check that DocMaker is available:
CALL :FindDocMaker
IF NOT EXIST !DocMaker! GOTO :DocMakerNotFound

:: Check that HTML Help Workshop compiler (hhc.exe) is available:
CALL :FindHhc
IF NOT EXIST !Hhc! GOTO :HhcNotFound

:: Track which locales will be converted:
SET _DE=0
SET _EN=0
SET _FR=0

IF /I %1==de  SET _DE=1
IF /I %1==en  SET _EN=1
IF /I %1==fr  SET _FR=1
IF /I %1==all (
  SET _DE=1
  SET _EN=1
  SET _FR=1
)

:: Carry out the actual conversions:
IF !_DE! EQU 1 CALL :DocMakerBuild German
IF !_EN! EQU 1 CALL :DocMakerBuild English
IF !_FR! EQU 1 CALL :DocMakerBuild French

GOTO :EndScript


:DocMakerBuild
SET "outDir=%~dp0%~1\CHM"

ECHO.
ECHO Building PureBasic %~1 CHM: ".\%~1\CHM\"

RD /Q /S "!outDir!" >nul 2>&1
MD "!outDir!" >nul 2>&1

:: DocMaker CLI parameters per official DocMaker Help:
:: /CHM requires /HTMLWORKSHOP with full path to hhc.exe
!DocMaker! ^
  /DOCUMENTATIONPATH "%~dp0" ^
  /OUTPUTPATH "!outDir!" ^
  /LANGUAGE %~1 ^
  /FORMAT Html ^
  /OS Windows ^
  /CHM ^
  /HTMLWORKSHOP !Hhc!

IF ERRORLEVEL 1 EXIT /B 1

:: Fallback: If DocMaker produced a .hhp but no .chm (depends on setup),
:: try compiling the generated project via hhc.exe directly.
SET hasChm=0
FOR /F "delims=" %%F IN ('dir /b /a:-d "!outDir!\*.chm" 2^>nul') DO SET hasChm=1

IF !hasChm! EQU 0 (
  FOR /F "delims=" %%P IN ('dir /b /a:-d "!outDir!\*.hhp" 2^>nul') DO (
    ECHO No CHM found yet - compiling "%%P" via hhc.exe ...
    !Hhc! "!outDir!\%%P"
  )
)

EXIT /B


:Instructions
ECHO Missing parameter! Invoke me with one of (de^|en^|fr^|all):
ECHO.
ECHO de  -- Builds German CHM in: "German\CHM\"
ECHO en  -- Builds English CHM in: "English\CHM\"
ECHO fr  -- Builds French CHM in: "French\CHM\"
ECHO all -- Builds all three locales.
ECHO.
ECHO Notes:
ECHO  - CHM requires HTML Help Workshop (hhc.exe) and DocMaker's /HTMLWORKSHOP parameter.
ECHO  - You can override the hhc.exe path via environment variable HHC, e.g.:
ECHO      set HHC=C:\Program Files (x86)\HTML Help Workshop\hhc.exe
GOTO :EndScript


:FindHhc
:: Allow user override: set HHC=full\path\hhc.exe
IF DEFINED HHC SET Hhc="!HHC!"
IF EXIST !Hhc! EXIT /B

:: Default installation paths:
SET Hhc="!ProgramFiles(x86)!\HTML Help Workshop\hhc.exe"
IF EXIST !Hhc! EXIT /B

SET Hhc="!ProgramFiles!\HTML Help Workshop\hhc.exe"
IF EXIST !Hhc! EXIT /B

EXIT /B


:FindDocMaker
:: This logic mirrors Documentation\HTML-BUILD.bat (DocMaker discovery).
:: Check if !DocMaker! is already valid:
IF EXIST !DocMaker! EXIT /B

:: Default location:
SET DocMaker="!ProgramFiles!\PureBasic\SDK\DocMaker\DocMaker.exe"
IF EXIST !DocMaker! EXIT /B

:: Relative to !PUREBASIC_HOME! (used in other build scripts):
SET DocMaker="!PUREBASIC_HOME!\SDK\DocMaker\DocMaker.exe"
IF EXIST !DocMaker! EXIT /B

:: Relative to environmental variables set for IDE tools:
CALL :ExtractProgramDir !PB_TOOL_IDE!
SET DocMaker="!ProgramDir!\SDK\DocMaker\DocMaker.exe"
IF EXIST !DocMaker! EXIT /B

CALL :ExtractProgramDir !PB_TOOL_Compiler!
SET DocMaker="!ProgramDir!\..\SDK\DocMaker\DocMaker.exe"
IF EXIST !DocMaker! EXIT /B

:: Read the command line created by IDE to open PureBasic files from explorer.exe:
FOR /f "Skip=2 Tokens=*" %%i IN ( 'Reg Query HKEY_CURRENT_USER\Software\Classes\PureBasic.exe\shell\open\command /ve' ) DO (
  SET str=%%i
  CALL :ExtractProgramDir !str:*REG_SZ =!
)

SET DocMaker="!ProgramDir!SDK\DocMaker\DocMaker.exe"
IF EXIST !DocMaker! EXIT /B

EXIT /B


:ExtractProgramDir
SET ProgramDir=%~dp1
EXIT /B


:DocMakerNotFound
ECHO *** ERROR!!! *** Couldn't find DocMaker at the expected path:
ECHO.
ECHO !DocMaker!
ECHO.
ECHO This script needs a standard PureBasic installation to be present on the system.
ECHO /// Aborting conversion ///
GOTO :EndScript


:HhcNotFound
ECHO *** ERROR!!! *** Couldn't find HTML Help Workshop compiler (hhc.exe).
ECHO.
ECHO Looked for:
ECHO   - Environment variable HHC
ECHO   - "!ProgramFiles(x86)!\HTML Help Workshop\hhc.exe"
ECHO   - "!ProgramFiles!\HTML Help Workshop\hhc.exe"
ECHO.
ECHO Install "HTML Help Workshop" and/or set:
ECHO   set HHC=full\path\to\hhc.exe
ECHO /// Aborting conversion ///
GOTO :EndScript


:EndScript
:: Only pause before quitting if the script was launched via File Explorer:
ECHO "!cmdcmdline!" | FINDSTR /IC:"%~0" >nul && PAUSE
EXIT /B
