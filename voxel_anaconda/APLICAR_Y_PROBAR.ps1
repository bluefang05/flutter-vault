$ErrorActionPreference = "Stop"

Write-Host "Voxel Anaconda v1.2 - limpieza" -ForegroundColor Cyan
flutter clean

Remove-Item ".\pubspec.lock" -ErrorAction SilentlyContinue

Write-Host "Resolviendo dependencias..." -ForegroundColor Cyan
flutter pub get

Write-Host "Ejecutando release..." -ForegroundColor Cyan
flutter run --release
