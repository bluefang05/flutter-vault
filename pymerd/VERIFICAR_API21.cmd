@echo off
setlocal
cd /d "C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd"
echo ============================================================
echo   VERIFICACION PYMERD API 21
echo ============================================================
echo.
echo [pubspec.yaml]
findstr /N /C:"dependency_overrides:" /C:"webview_flutter_android: 4.10.1" pubspec.yaml
echo.
echo [pubspec.lock]
findstr /N /C:"webview_flutter_android:" /C:"version: ""4.10.1""" pubspec.lock
echo.
echo [minSdk]
findstr /N /C:"minSdk = 21" android\app\build.gradle.kts
echo.
echo [AdMob]
findstr /N /C:"for (def configuration : configurations)" "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\google_mobile_ads-5.3.1\android\build.gradle"
echo.
echo [APK]
if exist build\app\outputs\flutter-apk\app-release.apk (
  echo OK build\app\outputs\flutter-apk\app-release.apk
) else (
  echo FALTA APK
)
echo.
pause
