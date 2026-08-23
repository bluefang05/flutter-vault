@echo off
setlocal EnableExtensions
title PYMERD - FIX DIRECTO CACHE ADMOB

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0APLICAR_FIX_DIRECTO_CACHE_ADMOB.ps1"
set "RC=%ERRORLEVEL%"

echo.
echo ============================================================
if "%RC%"=="0" (
  echo   CORRECCION APLICADA Y APK COMPILADO
) else (
  echo   EL PROCESO TERMINO CON ERROR %RC%
)
echo ============================================================
echo.
pause
exit /b %RC%
