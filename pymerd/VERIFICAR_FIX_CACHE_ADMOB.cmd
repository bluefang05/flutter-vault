@echo off
set "FILE=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\google_mobile_ads-5.3.1\android\build.gradle"

echo ============================================================
echo   VERIFICACION GOOGLE MOBILE ADS 5.3.1
echo ============================================================
echo.

if not exist "%FILE%" (
  echo ERROR: No se encontro:
  echo %FILE%
  echo.
  pause
  exit /b 1
)

echo Archivo:
echo %FILE%
echo.

findstr /N /C:"for (def configuration : configurations)" "%FILE%"

echo.
echo No debe aparecer configurations.all:
findstr /N /C:"configurations.all" "%FILE%"

echo.
pause
