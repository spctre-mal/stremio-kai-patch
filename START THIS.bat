@echo off
title Stremio Kai Patch

echo ==========================================
echo   Stremio Kai Patch by SPCTRE
echo ==========================================
echo.

REM Move to the folder where this BAT is located
cd /d "%~dp0"

REM Check if PowerShell exists
where powershell >nul 2>&1
if errorlevel 1 (
    echo ERROR: PowerShell not found.
    echo.
    pause
    exit /b
)

REM Check if patch.ps1 exists
if not exist "patch.ps1" (
    echo ERROR: patch.ps1 not found in this folder.
    echo.
    pause
    exit /b
)

echo Launching patch script...
echo.

REM Run PowerShell with execution policy bypass (session only)
powershell -NoProfile -ExecutionPolicy Bypass -File "patch.ps1"

echo.
echo ==========================================
echo Patch process finished.
echo ==========================================
echo.
pause
