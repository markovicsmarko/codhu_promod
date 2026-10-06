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
set "mod_name=codhu_promod"

if not defined gamePath (
	echo Usage: compile.bat "<Call of Duty 4 root>" "<new build output folder>"
	exit /b 2
)

if not defined buildPath (
	echo A new, empty build output folder is required.
	exit /b 2
)

if exist "%buildPath%\%mod_name%.iwd" (
	echo Build output already exists: "%buildPath%\%mod_name%.iwd"
	exit /b 2
)
if exist "%buildPath%\z_c_r.iwd" (
	echo Build output already exists: "%buildPath%\z_c_r.iwd"
	exit /b 2
)

if not exist "%projectPath%7za.exe" (
	echo 7za.exe was not found beside compile.bat.
	exit /b 2
)

if not exist "%buildPath%\" (
	mkdir "%buildPath%"
	if errorlevel 1 (
		echo Could not create build output folder: "%buildPath%"
		exit /b 2
	)
)

pushd "%projectPath%"
"%projectPath%7za.exe" a -r -mx=9 -mpass=15 -mfb=258 -mmt=on -mtc=off -tzip "%buildPath%\%mod_name%.iwd" weapons images sound
if errorlevel 1 goto :archive_failed

"%projectPath%7za.exe" a -r -mx=9 -mpass=15 -mfb=258 -mmt=on -mtc=off -tzip "%buildPath%\z_c_r.iwd" promod_ruleset
if errorlevel 1 goto :archive_failed
popd

call "%projectPath%compile_fastfile.bat" "%gamePath%" "%buildPath%"
if errorlevel 1 exit /b 1

exit /b 0

:archive_failed
popd
echo IWD packaging failed. Partial files remain in "%buildPath%".
exit /b 1
