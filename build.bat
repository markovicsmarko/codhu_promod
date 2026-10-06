@echo off
setlocal EnableExtensions

set "projectPath=%~dp0"
set "gamePath=%~1"

if not defined gamePath (
	for %%I in ("%projectPath%..\..") do set "candidatePath=%%~fI"
	if exist "%candidatePath%\raw\" if exist "%candidatePath%\bin\linker_pc.exe" set "gamePath=%candidatePath%"
)

if not defined gamePath set /p "gamePath=Enter the Call of Duty 4 root folder (contains raw, bin, and zone_source): "
set "gamePath=%gamePath:"=%"
if not defined gamePath (
	echo A Call of Duty 4 root folder is required.
	exit /b 2
)
for %%I in ("%gamePath%") do set "gamePath=%%~fI"

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
if not exist "%projectPath%7za.exe" (
	echo 7za.exe was not found beside build.bat.
	exit /b 2
)

for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss_fff"') do set "buildStamp=%%I"
if not defined buildStamp set "buildStamp=%RANDOM%_%RANDOM%"
set "buildPath=%gamePath%\codhu_builds\codhu_promod_%buildStamp%_%RANDOM%"
set "backupPath=%buildPath%\previous"
set "modPath=%gamePath%\Mods\codhu_promod"

mkdir "%backupPath%" 2>nul
if not exist "%backupPath%\" (
	echo Could not create build output folder: "%buildPath%"
	exit /b 2
)
if not exist "%modPath%\" mkdir "%modPath%"
if not exist "%modPath%\" (
	echo Could not create mod folder: "%modPath%"
	exit /b 2
)

for %%F in (mod.ff codhu_promod.iwd z_c_r.iwd) do (
	if exist "%modPath%\%%F" (
		copy /Y "%modPath%\%%F" "%backupPath%\mod_%%F" >nul
		if errorlevel 1 goto :backup_failed
	)
)

echo Building CODHU Promod from "%projectPath%"...
call "%projectPath%compile.bat" "%gamePath%" "%buildPath%"
if errorlevel 1 goto :build_failed

for %%F in (mod.ff codhu_promod.iwd z_c_r.iwd) do if not exist "%buildPath%\%%F" goto :missing_output

copy /Y "%buildPath%\mod.ff" "%modPath%\mod.ff" >nul
if errorlevel 1 goto :install_failed
copy /Y "%buildPath%\codhu_promod.iwd" "%modPath%\codhu_promod.iwd" >nul
if errorlevel 1 goto :install_failed
copy /Y "%buildPath%\z_c_r.iwd" "%modPath%\z_c_r.iwd" >nul
if errorlevel 1 goto :install_failed

echo Build complete: "%modPath%"
echo Build output and previous mod files are preserved in: "%buildPath%"
exit /b 0

:backup_failed
echo Could not preserve an existing mod file. No build was started.
echo Build folder: "%buildPath%"
exit /b 1

:build_failed
echo Build failed. Existing mod files were not installed over.
echo Build output and backups, if any, are in: "%buildPath%"
exit /b 1

:missing_output
echo A required build output is missing. Existing mod files were not changed.
echo Build folder: "%buildPath%"
exit /b 1

:install_failed
echo Installing build files failed. Existing mod files are backed up under: "%backupPath%"
exit /b 1
