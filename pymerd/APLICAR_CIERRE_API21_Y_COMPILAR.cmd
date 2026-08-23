@echo off
setlocal EnableExtensions
title PYMERD - CIERRE API 21
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0APLICAR_CIERRE_API21.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo ============================================================
if "%RC%"=="0" (
  echo   PYMERD API 21 PREPARADO Y APK COMPILADO
) else (
  echo   EL PROCESO TERMINO CON ERROR %RC%
)
echo ============================================================
echo.
pause
exit /b %RC%
