@echo off
setlocal EnableExtensions
title PYMERD 0.1.0 - CIERRE TECNICO ADMOB API 21

set "PROJECT=C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd"
set "SCRIPT=%~dp0scripts\APLICAR_CIERRE_TECNICO_PYMERD.ps1"

if not exist "%PROJECT%\pubspec.yaml" (
  echo.
  echo ERROR: No se encontro PYMERD en:
  echo   %PROJECT%
  echo.
  pause
  exit /b 10
)

if not exist "%SCRIPT%" (
  echo.
  echo ERROR: Falta el script interno:
  echo   %SCRIPT%
  echo.
  pause
  exit /b 11
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -ProjectPath "%PROJECT%"
set "RESULT=%ERRORLEVEL%"

echo.
echo ============================================================
if "%RESULT%"=="0" (
  echo   PYMERD QUEDO PREPARADO Y EL APK FUE COMPILADO
) else (
  echo   EL PROCESO TERMINO CON ERROR %RESULT%
)
echo ============================================================
echo.
pause
exit /b %RESULT%
