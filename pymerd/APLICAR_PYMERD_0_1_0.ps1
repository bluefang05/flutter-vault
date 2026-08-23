$ErrorActionPreference = "Stop"
Write-Host "============================================="
Write-Host " PYME RD 0.1.0 - ESTABILIZACION"
Write-Host "============================================="

if (-not (Test-Path "pubspec.yaml")) {
    throw "Ejecuta este script dentro de la carpeta del proyecto pymerd."
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $env:USERPROFILE "Desktop\PYMERD_BACKUP_ANTES_010_$stamp"
New-Item -ItemType Directory -Force -Path $backup | Out-Null

$files = @(
    "pubspec.yaml",
    "android\app\build.gradle.kts",
    "lib\app_database.dart",
    "lib\app_repository.dart",
    "lib\screens\onboarding_page.dart",
    "lib\screens\more_page.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $target = Join-Path $backup $file
        New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
        Copy-Item $file $target -Force
    }
}

Write-Host "Backup creado en: $backup"
flutter clean
flutter pub get
dart format lib\app_database.dart lib\app_repository.dart lib\screens\onboarding_page.dart lib\screens\more_page.dart
flutter analyze
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

flutter build apk --release
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "Actualización aplicada."
Write-Host "Versión pública: 0.1.0"
Write-Host "Build: 1"
Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk"
