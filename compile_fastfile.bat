:: Copyright (c) 2009-2017 Andreas Göransson <andreas.goransson@gmail.com>
:: Copyright (c) 2009-2017 Indrek Ardel <indrek@ardel.eu>
::
:: This file is part of Call of Duty 4 Promod.
::
:: Call of Duty 4 Promod is licensed under Promod Modder Ethical Public License.
:: Terms of license can be found in LICENSE.md document bundled with the project.
:: CODHU build changes dated 2026-10-05.

@echo off
setlocal EnableExtensions

set "projectPath=%~dp0"
set "gamePath=%~1"
set "buildPath=%~2"
set "backupPath=%buildPath%\previous"
set "linkLog=%buildPath%\linker.log"

if not defined gamePath (
	echo Usage: compile_fastfile.bat "<Call of Duty 4 root>" "<build output folder>"
	exit /b 2
)
if not defined buildPath (
	echo A build output folder is required.
	exit /b 2
)
if not exist "%gamePath%\raw\" (
	echo CoD4 raw folder not found: "%gamePath%\raw"
	exit /b 2
)
if not exist "%gamePath%\bin\linker_pc.exe" (
	echo linker_pc.exe not found under: "%gamePath%\bin"
	exit /b 2
)
if not exist "%gamePath%\zone_source\" (
	echo zone_source folder not found: "%gamePath%\zone_source"
	exit /b 2
)
if not exist "%gamePath%\zone\english\" mkdir "%gamePath%\zone\english"
if not exist "%buildPath%\" mkdir "%buildPath%"
if not exist "%backupPath%\" mkdir "%backupPath%"

if exist "%gamePath%\zone_source\mod.csv" if not exist "%backupPath%\zone_source_mod.csv" (
	copy /Y "%gamePath%\zone_source\mod.csv" "%backupPath%\zone_source_mod.csv" >nul
	if errorlevel 1 goto :backup_failed
)
if exist "%gamePath%\zone\english\mod.ff" if not exist "%backupPath%\zone_english_mod.ff" (
	copy /Y "%gamePath%\zone\english\mod.ff" "%backupPath%\zone_english_mod.ff" >nul
	if errorlevel 1 goto :backup_failed
)

call :backupRawTree "localizedstrings" "%gamePath%\raw\english\localizedstrings" "english\localizedstrings"
if errorlevel 1 goto :backup_failed
call :backupRawTree "maps" "%gamePath%\raw\maps" "maps"
if errorlevel 1 goto :backup_failed
call :backupRawTree "mp" "%gamePath%\raw\mp" "mp"
if errorlevel 1 goto :backup_failed
call :backupRawTree "promod" "%gamePath%\raw\promod" "promod"
if errorlevel 1 goto :backup_failed
call :backupRawTree "shock" "%gamePath%\raw\shock" "shock"
if errorlevel 1 goto :backup_failed
call :backupRawTree "sound" "%gamePath%\raw\sound" "sound"
if errorlevel 1 goto :backup_failed
call :backupRawTree "soundaliases" "%gamePath%\raw\soundaliases" "soundaliases"
if errorlevel 1 goto :backup_failed
call :backupRawTree "ui_mp" "%gamePath%\raw\ui_mp" "ui_mp"
if errorlevel 1 goto :backup_failed
call :backupRawTree "xmodel" "%gamePath%\raw\xmodel" "xmodel"
if errorlevel 1 goto :backup_failed

xcopy "%projectPath%localizedstrings" "%gamePath%\raw\english\localizedstrings\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%maps" "%gamePath%\raw\maps\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%mp" "%gamePath%\raw\mp\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%promod" "%gamePath%\raw\promod\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%shock" "%gamePath%\raw\shock\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%sound" "%gamePath%\raw\sound\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%soundaliases" "%gamePath%\raw\soundaliases\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%ui_mp" "%gamePath%\raw\ui_mp\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed
xcopy "%projectPath%xmodel" "%gamePath%\raw\xmodel\" /E /I /Y >nul
if errorlevel 2 goto :copy_failed

copy /Y "%projectPath%mod.csv" "%gamePath%\zone_source\mod.csv" >nul
if errorlevel 1 goto :copy_failed

pushd "%gamePath%\bin"
linker_pc.exe -language english -compress mod -verbose > "%linkLog%" 2>&1
set "linkerResult=%ERRORLEVEL%"
popd
type "%linkLog%"
if not "%linkerResult%"=="0" goto :link_failed
findstr /C:"Linker summary:" "%linkLog%" >nul
if errorlevel 1 goto :link_failed
findstr /I /C:"Errors:" "%linkLog%" >nul
if not errorlevel 1 goto :link_failed
if not exist "%gamePath%\zone\english\mod.ff" goto :link_failed

copy /Y "%gamePath%\zone\english\mod.ff" "%buildPath%\mod.ff" >nul
if errorlevel 1 goto :copy_failed
exit /b 0

:copy_failed
echo A source or output copy failed. Earlier raw file copies may already have updated the tools folder.
echo Existing files were not deleted. Backups are in "%backupPath%".
if exist "%backupPath%\zone_english_mod.ff" copy /Y "%backupPath%\zone_english_mod.ff" "%gamePath%\zone\english\mod.ff" >nul
exit /b 1

:backup_failed
echo Could not preserve an existing linker input or output. Linking was not started.
exit /b 1

:link_failed
echo Fastfile linking failed or reported errors. The previous mod.ff backup, if present, is in "%backupPath%\zone_english_mod.ff".
if exist "%backupPath%\zone_english_mod.ff" copy /Y "%backupPath%\zone_english_mod.ff" "%gamePath%\zone\english\mod.ff" >nul
exit /b 1

:backupRawTree
setlocal EnableDelayedExpansion
set "sourceFolder=%projectPath%%~1"
set "targetFolder=%~2"
set "backupFolder=%backupPath%\raw\%~3"
for /r "!sourceFolder!" %%F in (*) do (
	set "sourceFile=%%~fF"
	set "relativeFile=!sourceFile:%sourceFolder%\=!"
	if exist "!targetFolder!\!relativeFile!" (
		for %%D in ("!backupFolder!\!relativeFile!") do if not exist "%%~dpD" mkdir "%%~dpD"
		copy /Y "!targetFolder!\!relativeFile!" "!backupFolder!\!relativeFile!" >nul
		if errorlevel 1 (
			endlocal
			exit /b 1
		)
	)
)
endlocal
exit /b 0
