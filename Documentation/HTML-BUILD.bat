:: "Documentation\HTML-BUILD.bat"       v1.0.0 | 2020/11/30 | by Tristano Ajmone
:: -----------------------------------------------------------------------------
@ECHO OFF
ECHO.
ECHO ##############################################################################
ECHO #                                                                            #
ECHO #                    PureBasic Help HTML Preview Builder                     #
ECHO #                                                                            #
ECHO ##############################################################################
IF [%1]==[] GOTO :Instructions
:: Check that DocMaker is available:
SET DocMaker="%ProgramFiles%\PureBasic\SDK\DocMaker\DocMaker.exe"
IF NOT EXIST %DocMaker% GOTO :DocMakerNotFound
:: Track which locales will be converted:
SET _DE=0
SET _EN=0
SET _FR=0
IF /I %1==de SET _DE=1
IF /I %1==en SET _EN=1
IF /I %1==fr SET _FR=1
IF /I %1==all (
	SET _DE=1
	SET _EN=1
	SET _FR=1
)
:: Carry out the actual conversions:
IF %_DE% EQU 1 CALL :DocMakerBuild German
IF %_EN% EQU 1 CALL :DocMakerBuild English
IF %_FR% EQU 1 CALL :DocMakerBuild French
GOTO :EndScript

:DocMakerBuild
ECHO Building PureBasic %~1 Help: ".\%~1\HTML\".
RD /Q /S "%~dp0\%~1\HTML" >nul 2>&1
%DocMaker% /DOCUMENTATIONPATH "%~dp0" /OUTPUTPATH "%~dp0\%~1\HTML" /LANGUAGE %~1 /FORMAT Html /OS Windows
EXIT /B

:Instructions
ECHO Missing parameter! Invoke me with one of (de^|en^|fr^|all):
ECHO.
ECHO   de   -- Builds German documentation in:  "German\HTML\"
ECHO   en   -- Builds English documentation in: "English\HTML\"
ECHO   fr   -- Builds French documentation in:  "French\HTML\"
ECHO   all  -- Builds all three locales.
GOTO :EndScript

:DocMakerNotFound
ECHO ^*^*^* ERROR^!^!^! ^*^*^* Couldn't find DocMaker at the expected path:
ECHO.
ECHO   %DocMaker%
ECHO.
ECHO This script needs a standard PureBasic installation to be present on the system,
ECHO according to the system architecture -- i.e. PureBasic 32-bit on Windows 32-bit,
ECHO or PureBasic 64-bit edition on Windows 64-bit.
ECHO.
ECHO /// Aborting conversion ///
GOTO :EndScript

:EndScript
:: Only pause before quitting if the script was launched via File Explorer:
ECHO "%cmdcmdline%" | FINDSTR /IC:"%~dp0" >nul && PAUSE
EXIT /B
