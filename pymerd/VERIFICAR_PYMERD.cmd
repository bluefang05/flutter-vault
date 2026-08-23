@echo off
setlocal EnableExtensions
title PYMERD - VERIFICACION ADMOB API 21
set "PROJECT=C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd"
cd /d "%PROJECT%"

echo ============================================================
echo   VERIFICACION PYMERD
echo ============================================================
echo.

echo [1] Archivos locales del arreglo
if exist "pubspec_overrides.yaml" (echo OK pubspec_overrides.yaml) else (echo FALTA pubspec_overrides.yaml)
if exist "third_party\google_mobile_ads_5_3_1_agp9\android\build.gradle" (
  echo OK plugin local
) else (
  echo FALTA plugin local
)

echo.
echo [2] Dependencia resuelta
flutter pub deps --style=compact | findstr /I "google_mobile_ads"

echo.
echo [3] API minima configurada
findstr /N /C:"minSdk = 21" "android\app\build.gradle.kts"

echo.
echo [4] App ID de AdMob
findstr /N /C:"ca-app-pub-3322493998376707~6779988736" "android\app\src\main\AndroidManifest.xml"

echo.
echo [5] APK
if exist "build\app\outputs\flutter-apk\app-release.apk" (
  echo OK build\app\outputs\flutter-apk\app-release.apk
) else (
  echo AUN NO EXISTE EL APK
)

echo.
pause
